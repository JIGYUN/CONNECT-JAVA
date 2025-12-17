// filepath: src/main/java/www/com/ai/AiEngineManager.java
package www.com.ai;

import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;

import java.net.HttpURLConnection;
import java.net.URL;

import java.nio.charset.StandardCharsets;

import java.util.HashMap;
import java.util.Map;

import javax.annotation.PostConstruct;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

@Component
public class AiEngineManager {

    // =============================
    // 기존 번역용 엔진 (QWEN/Libre)
    // =============================

    private final LibreTranslateClient libreTranslateClient;
    private final QwenTranslateClient qwenTranslateClient;

    // =============================
    // 신규: OpenAI FastAPI 챗봇
    // =============================

    private OpenAiFastApiClient openAiFastApiClient;

    /**
     * ✅ 환경별 주입 값
     * - 우선순위: OS 환경변수(LAWBOT_FASTAPI_BASE_URL) -> ConfigProperties(lawbot.fastapi.baseUrl) -> 기본값
     *
     * 운영(Render): https://lawbot-1mpd.onrender.com
     * 로컬: http://localhost:8000
     */
    @Value("#{T(java.lang.System).getenv('LAWBOT_FASTAPI_BASE_URL') ?: ConfigProperties['lawbot.fastapi.baseUrl'] ?: 'http://localhost:8000'}")
    private String openAiFastApiBaseUrl;

    @Value("#{T(java.lang.System).getenv('LAWBOT_FASTAPI_DEFAULT_TOP_K') ?: ConfigProperties['lawbot.fastapi.defaultTopK'] ?: '5'}")
    private String defaultTopKStr;

    private int defaultTopK = 5;

    public AiEngineManager() {
        // 기존 클래스 그대로 사용(너가 준 파일)
        this.libreTranslateClient = new LibreTranslateClient("http://localhost:5000");
        this.qwenTranslateClient = new QwenTranslateClient("http://localhost:11434", "qwen2.5:7b-instruct");
    }

    @PostConstruct
    public void init() {
        this.openAiFastApiBaseUrl = trimTrailingSlash(this.openAiFastApiBaseUrl);

        try {
            this.defaultTopK = Integer.parseInt((this.defaultTopKStr != null) ? this.defaultTopKStr.trim() : "5");
        } catch (Exception ignore) {
            this.defaultTopK = 5;
        }

        this.openAiFastApiClient = new OpenAiFastApiClient(this.openAiFastApiBaseUrl);

        System.out.println("[AI] FastAPI baseUrl=" + this.openAiFastApiBaseUrl + " defaultTopK=" + this.defaultTopK);
    }

    private void ensureFastApiClient() {
        if (this.openAiFastApiClient == null) {
            String base = trimTrailingSlash((this.openAiFastApiBaseUrl != null) ? this.openAiFastApiBaseUrl : "http://localhost:8000");
            this.openAiFastApiClient = new OpenAiFastApiClient(base);
        }
    }

    // =========================================================
    // 1) 번역: 기존 그대로 (QWEN은 번역만)
    // =========================================================

    public String translate(Map<String, Object> payload) throws Exception {

        if (payload == null) {
            payload = new HashMap<String, Object>();
        }

        String engine = getString(payload, "engine", "LT");
        String sourceLang = getString(payload, "sourceLang", "auto");
        String targetLang = getString(payload, "targetLang", "ko");

        // text -> content fallback
        String text = getString(payload, "text", null);
        if (text == null) {
            text = getString(payload, "content", "");
        }
        if (text == null) {
            text = "";
        }
        if (text.trim().isEmpty()) {
            return "";
        }

        if ("QWEN".equalsIgnoreCase(engine)) {
            return qwenTranslateClient.translate(text, sourceLang, targetLang);
        }
        return libreTranslateClient.translate(text, sourceLang, targetLang);
    }

    // =========================================================
    // 2) 챗봇 4버전( FastAPI(OpenAI) )
    // =========================================================

    public static enum BotVariant {
        CHAT,
        CHAT_STREAM,
        CHAT_GRAPH,
        CHAT_GRAPH_STREAM;

        public static BotVariant from(String s) {
            if (s == null) return CHAT_GRAPH_STREAM;
            String u = s.trim().toUpperCase();
            if ("CHAT".equals(u)) return CHAT;
            if ("CHAT_STREAM".equals(u)) return CHAT_STREAM;
            if ("CHAT_GRAPH".equals(u)) return CHAT_GRAPH;
            if ("CHAT_GRAPH_STREAM".equals(u)) return CHAT_GRAPH_STREAM;
            return CHAT_GRAPH_STREAM;
        }

        public boolean isStream() {
            return this == CHAT_STREAM || this == CHAT_GRAPH_STREAM;
        }

        public String path() {
            if (this == CHAT) return "/api/law/chat";
            if (this == CHAT_STREAM) return "/api/law/chat_stream";
            if (this == CHAT_GRAPH) return "/api/law/chat_graph";
            if (this == CHAT_GRAPH_STREAM) return "/api/law/chat_graph_stream";
            return "/api/law/chat_graph_stream";
        }
    }

    public static interface StreamCallback {
        void onToken(String delta);
        void onDone(String fullAnswer, Object sources);
        void onError(String errorMsg);
    }

    public Map<String, Object> chatWithOpenAiFastApi(Map<String, Object> payload) throws Exception {
        if (payload == null) payload = new HashMap<String, Object>();

        ensureFastApiClient();

        BotVariant variant = BotVariant.from(getString(payload, "botVariant", "CHAT_GRAPH"));
        if (variant.isStream()) {
            throw new Exception("non-stream 호출인데 stream variant가 들어왔습니다: " + variant.name());
        }

        String question = extractQuestion(payload);
        int topK = extractTopK(payload, this.defaultTopK);

        return openAiFastApiClient.chat(variant, question, topK);
    }

    public void chatWithOpenAiFastApiStream(Map<String, Object> payload, StreamCallback callback) throws Exception {
        if (payload == null) payload = new HashMap<String, Object>();
        if (callback == null) throw new Exception("callback is null");

        ensureFastApiClient();

        BotVariant variant = BotVariant.from(getString(payload, "botVariant", "CHAT_GRAPH_STREAM"));
        if (!variant.isStream()) {
            throw new Exception("stream 호출인데 non-stream variant가 들어왔습니다: " + variant.name());
        }

        String question = extractQuestion(payload);
        int topK = extractTopK(payload, this.defaultTopK);

        openAiFastApiClient.chatStream(variant, question, topK, callback);
    }

    private String extractQuestion(Map<String, Object> payload) {
        String q = getString(payload, "question", null);
        if (q != null && !q.trim().isEmpty()) return q;

        q = getString(payload, "content", null);
        if (q != null && !q.trim().isEmpty()) return q;

        q = getString(payload, "text", "");
        return q;
    }

    private int extractTopK(Map<String, Object> payload, int defaultValue) {
        Object v1 = payload.get("topK");
        if (v1 instanceof Number) return ((Number) v1).intValue();
        if (v1 != null) {
            try { return Integer.parseInt(v1.toString()); } catch (Exception ignore) {}
        }

        Object v2 = payload.get("top_k");
        if (v2 instanceof Number) return ((Number) v2).intValue();
        if (v2 != null) {
            try { return Integer.parseInt(v2.toString()); } catch (Exception ignore) {}
        }

        return defaultValue;
    }

    private String getString(Map<String, Object> map, String key, String defaultValue) {
        if (map == null) return defaultValue;
        Object v = map.get(key);
        if (v == null) return defaultValue;
        String s = v.toString();
        if (s.trim().isEmpty()) return defaultValue;
        return s;
    }

    // =========================================================
    // 내부: FastAPI(OpenAI) HTTP Client
    // =========================================================

    private static class OpenAiFastApiClient {

        private final String baseUrl;
        private final ObjectMapper om = new ObjectMapper();

        OpenAiFastApiClient(String baseUrl) {
            this.baseUrl = trimTrailingSlash(baseUrl);
        }

        Map<String, Object> chat(BotVariant variant, String question, int topK) throws Exception {
            String url = baseUrl + variant.path();

            Map<String, Object> req = new HashMap<String, Object>();
            req.put("question", (question != null) ? question : "");
            req.put("top_k", topK);

            String reqJson = om.writeValueAsString(req);

            HttpURLConnection conn = null;
            try {
                conn = (HttpURLConnection) new URL(url).openConnection();
                conn.setRequestMethod("POST");
                conn.setConnectTimeout(5000);
                conn.setReadTimeout(180000);
                conn.setDoOutput(true);
                conn.setRequestProperty("Content-Type", "application/json; charset=utf-8");
                conn.setRequestProperty("Accept", "application/json");

                try (OutputStream os = conn.getOutputStream()) {
                    os.write(reqJson.getBytes(StandardCharsets.UTF_8));
                    os.flush();
                }

                int status = conn.getResponseCode();
                InputStream is = (status >= 200 && status < 300) ? conn.getInputStream() : conn.getErrorStream();
                String resp = readAll(is);

                if (status < 200 || status >= 300) {
                    throw new Exception("FastAPI HTTP " + status + " : " + resp);
                }

                Map<String, Object> out = new HashMap<String, Object>();
                out.put("botVariant", variant.name());

                String answer = extractAnswerFromJson(resp);
                Object sources = extractSourcesFromJson(resp);

                out.put("answer", (answer != null) ? answer : "");
                out.put("sources", sources);

                return out;

            } finally {
                if (conn != null) {
                    try { conn.disconnect(); } catch (Exception ignore) {}
                }
            }
        }

        void chatStream(BotVariant variant, String question, int topK, StreamCallback callback) throws Exception {
            String url = baseUrl + variant.path();

            Map<String, Object> req = new HashMap<String, Object>();
            req.put("question", (question != null) ? question : "");
            req.put("top_k", topK);

            String reqJson = om.writeValueAsString(req);

            HttpURLConnection conn = null;
            try {
                conn = (HttpURLConnection) new URL(url).openConnection();
                conn.setRequestMethod("POST");
                conn.setConnectTimeout(5000);
                conn.setReadTimeout(180000);
                conn.setDoOutput(true);
                conn.setRequestProperty("Content-Type", "application/json; charset=utf-8");
                conn.setRequestProperty("Accept", "*/*");

                try (OutputStream os = conn.getOutputStream()) {
                    os.write(reqJson.getBytes(StandardCharsets.UTF_8));
                    os.flush();
                }

                int status = conn.getResponseCode();
                InputStream is = (status >= 200 && status < 300) ? conn.getInputStream() : conn.getErrorStream();
                if (is == null) throw new Exception("FastAPI stream InputStream null, status=" + status);

                if (status < 200 || status >= 300) {
                    throw new Exception("FastAPI stream HTTP " + status + " : " + readAll(is));
                }

                String ctype = conn.getHeaderField("Content-Type");
                String ctypeLower = (ctype != null) ? ctype.toLowerCase() : "";
                boolean isSse = ctypeLower.contains("text/event-stream");

                StringBuilder full = new StringBuilder();
                Object sources = null;

                if (!isSse) {
                    InputStreamReader rd = new InputStreamReader(is, StandardCharsets.UTF_8);
                    char[] buf = new char[1024];
                    int n;
                    while ((n = rd.read(buf)) != -1) {
                        if (n <= 0) continue;
                        String chunk = new String(buf, 0, n);
                        if (chunk.isEmpty()) continue;

                        full.append(chunk);
                        callback.onToken(chunk);
                    }

                    String merged = full.toString().trim();
                    String ans = tryExtractAnswerFromJson(merged);
                    if (ans != null) {
                        callback.onDone(ans, sources);
                    } else {
                        callback.onDone(merged, sources);
                    }
                    return;
                }

                BufferedReader br = new BufferedReader(new InputStreamReader(is, StandardCharsets.UTF_8));
                String line;
                while ((line = br.readLine()) != null) {
                    String t = line.trim();
                    if (t.isEmpty()) continue;

                    if (t.startsWith("event:") || t.startsWith("id:") || t.startsWith("retry:")) {
                        continue;
                    }

                    String data = t;
                    if (t.startsWith("data:")) {
                        data = t.substring("data:".length()).trim();
                    }

                    if (data.isEmpty()) continue;
                    if ("[DONE]".equals(data)) break;

                    if (data.startsWith("{") && data.endsWith("}")) {
                        try {
                            JsonNode root = om.readTree(data);

                            JsonNode choices = root.get("choices");
                            if (choices != null && choices.isArray() && choices.size() > 0) {
                                JsonNode deltaNode = choices.get(0).get("delta");
                                if (deltaNode != null) {
                                    JsonNode contentNode = deltaNode.get("content");
                                    if (contentNode != null && !contentNode.isNull()) {
                                        String d = contentNode.asText("");
                                        if (!d.isEmpty()) {
                                            full.append(d);
                                            callback.onToken(d);
                                        }
                                        continue;
                                    }
                                }
                            }

                            String d2 = extractDelta(root);
                            if (d2 != null && !d2.isEmpty()) {
                                full.append(d2);
                                callback.onToken(d2);
                                continue;
                            }

                            String ans = extractAnswer(root);
                            if (ans != null && !ans.isEmpty()) {
                                full.setLength(0);
                                full.append(ans);
                                continue;
                            }

                            Object s2 = extractSources(root);
                            if (s2 != null) {
                                sources = s2;
                            }

                        } catch (Exception jsonFail) {
                            full.append(data);
                            callback.onToken(data);
                        }
                    } else {
                        full.append(data);
                        callback.onToken(data);
                    }
                }

                callback.onDone(full.toString(), sources);

            } catch (Exception e) {
                callback.onError(e.getMessage());
            } finally {
                if (conn != null) {
                    try { conn.disconnect(); } catch (Exception ignore) {}
                }
            }
        }

        private String extractDelta(JsonNode root) {
            if (root == null) return null;
            if (root.has("delta")) return root.get("delta").asText("");
            if (root.has("token")) return root.get("token").asText("");
            if (root.has("content")) return root.get("content").asText("");
            return null;
        }

        private String extractAnswer(JsonNode root) {
            if (root == null) return null;

            if (root.has("result")) {
                JsonNode result = root.get("result");
                if (result != null && result.isObject()) {
                    JsonNode a = result.get("answer");
                    if (a != null && !a.isNull()) return a.asText("");
                }
            }

            if (root.has("answer")) {
                JsonNode a = root.get("answer");
                if (a != null && !a.isNull()) return a.asText("");
            }

            return null;
        }

        private Object extractSources(JsonNode root) {
            if (root == null) return null;

            if (root.has("result")) {
                JsonNode result = root.get("result");
                if (result != null && result.isObject()) {
                    JsonNode s = result.get("sources");
                    if (s != null && !s.isNull()) return s;
                }
            }

            if (root.has("sources")) {
                JsonNode s = root.get("sources");
                if (s != null && !s.isNull()) return s;
            }

            return null;
        }

        private String tryExtractAnswerFromJson(String maybeJson) {
            if (maybeJson == null) return null;
            String s = maybeJson.trim();
            if (!(s.startsWith("{") && s.endsWith("}"))) return null;

            try {
                JsonNode root = om.readTree(s);
                String ans = extractAnswer(root);
                return (ans != null && !ans.trim().isEmpty()) ? ans.trim() : null;
            } catch (Exception e) {
                return null;
            }
        }

        private String extractAnswerFromJson(String respJson) throws Exception {
            if (respJson == null) return "";
            JsonNode root = om.readTree(respJson);

            String ans = extractAnswer(root);
            return (ans != null) ? ans : "";
        }

        private Object extractSourcesFromJson(String respJson) {
            if (respJson == null) return null;
            try {
                JsonNode root = om.readTree(respJson);
                return extractSources(root);
            } catch (Exception e) {
                return null;
            }
        }

        private static String readAll(InputStream is) throws Exception {
            if (is == null) return "";
            BufferedReader br = new BufferedReader(new InputStreamReader(is, StandardCharsets.UTF_8));
            StringBuilder sb = new StringBuilder();
            String line;
            while ((line = br.readLine()) != null) {
                sb.append(line).append('\n');
            }
            return sb.toString();
        }
    }

    private static String trimTrailingSlash(String s) {
        if (s == null) return "";
        String t = s.trim();
        if (t.endsWith("/")) return t.substring(0, t.length() - 1);
        return t;
    }
}
