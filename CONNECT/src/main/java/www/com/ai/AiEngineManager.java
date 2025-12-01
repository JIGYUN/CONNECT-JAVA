// filepath: src/main/java/www/com/ai/AiEngineManager.java
package www.com.ai;

import java.util.HashMap;
import java.util.Map;

import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.http.client.SimpleClientHttpRequestFactory;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestClientException;
import org.springframework.web.client.RestTemplate;

/**
 * 공통 AI 엔진 매니저.
 *
 * - translate(...)      : 자동 번역 (LibreTranslate / Qwen 번역)
 * - chatWithQwen(...)   : Qwen 일반 챗봇
 *
 * 실제 HTTP 엔드포인트(호스트/포트/모델명)는 아래 상수만 변경해 쓰면 된다.
 */
@Component
public class AiEngineManager {

    // === 환경 상수 (필요하면 properties로 빼도 됨) ===

    /** LibreTranslate 기본 URL (Docker 컨테이너 등) */
    private static final String LIBRE_BASE_URL = "http://localhost:5000";

    /** Qwen 서버 기본 URL (예: Ollama / LM Studio / 직접 띄운 서버) */
    private static final String QWEN_BASE_URL = "http://localhost:11434";

    /**
     * Qwen 모델명 (Ollama 사용 예: "qwen2.5:7b-instruct")
     * 실제 사용하는 모델명에 맞게 수정.
     */
    private static final String QWEN_MODEL_NAME = "qwen2.5:7b-instruct";

    // === 내부 클라이언트 ===

    private final LibreTranslateClient libreClient;
    private final QwenClient qwenClient;

    public AiEngineManager() {
        this.libreClient = new LibreTranslateClient(LIBRE_BASE_URL);
        this.qwenClient = new QwenClient(QWEN_BASE_URL, QWEN_MODEL_NAME);
    }

    /**
     * 자동 번역 엔진 (LibreTranslate / Qwen 번역 모드)에 연결하는 메서드.
     *
     * payload 예시:
     * {
     *   "text"       : "안녕",
     *   "sourceLang" : "auto",
     *   "targetLang" : "en",
     *   "engine"     : "LT" or "QWEN"
     * }
     *
     * text가 없으면 content 필드도 fallback으로 사용.
     */
    public String translate(Map<String, Object> payload) throws Exception {

        if (payload == null) {
            payload = new HashMap<String, Object>();
        }

        String engine = getString(payload, "engine", "LT");
        if (engine == null) {
            engine = "LT";
        }

        // text → content 순으로 텍스트 추출
        String text = null;
        Object textRaw = payload.get("text");
        if (textRaw != null) {
            text = textRaw.toString();
        } else {
            Object contentRaw = payload.get("content");
            if (contentRaw != null) {
                text = contentRaw.toString();
            }
        }
        if (text == null) {
            text = "";
        }

        String sourceLang = getString(payload, "sourceLang", "auto");
        String targetLang = getString(payload, "targetLang", "ko");

        if (text.trim().isEmpty()) {
            return "";
        }

        if ("QWEN".equalsIgnoreCase(engine)) {
            // Qwen 번역 모드 (시스템 프롬프트로 "번역기" 역할 주입)
            return qwenClient.translate(text, sourceLang, targetLang);
        } else {
            // 기본은 LibreTranslate
            return libreClient.translate(text, sourceLang, targetLang);
        }
    }

    /**
     * Qwen 기반 일반 챗봇.
     *
     * @param userText 사용자가 입력한 문장
     * @return Qwen 챗봇의 응답
     */
    public String chatWithQwen(String userText) throws Exception {
        if (userText == null) {
            userText = "";
        }
        return qwenClient.chat(userText);
    }

    // ========================================================================
    // 내부 유틸
    // ========================================================================

    private String getString(Map<String, Object> map, String key, String defaultValue) {
        if (map == null) {
            return defaultValue;
        }
        Object v = map.get(key);
        if (v == null) {
            return defaultValue;
        }
        String s = v.toString();
        if (s.trim().isEmpty()) {
            return defaultValue;
        }
        return s;
    }

    // ========================================================================
    // LibreTranslate 클라이언트
    // ========================================================================

    /**
     * LibreTranslate HTTP 클라이언트.
     *
     * 기본 API 스펙(공식 Docker 이미지 기준):
     *   POST /translate
     *   Content-Type: application/json
     *   {
     *     "q": "Hello",
     *     "source": "auto",
     *     "target": "ko",
     *     "format": "text"
     *   }
     *
     *   응답:
     *   {
     *     "translatedText": "안녕하세요"
     *   }
     */
    private static class LibreTranslateClient {

        private final String baseUrl;
        private final RestTemplate restTemplate;

        LibreTranslateClient(String baseUrl) {
            this.baseUrl = trimTrailingSlash(baseUrl);
            this.restTemplate = createRestTemplate();
        }

        String translate(String text, String sourceLang, String targetLang) throws Exception {
            String url = baseUrl + "/translate";

            Map<String, Object> body = new HashMap<String, Object>();
            body.put("q", text);
            body.put("source", sourceLang != null ? sourceLang : "auto");
            body.put("target", targetLang != null ? targetLang : "ko");
            body.put("format", "text");

            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);

            HttpEntity<Map<String, Object>> entity = new HttpEntity<Map<String, Object>>(body, headers);

            try {
                ResponseEntity<Map> resp = restTemplate.exchange(
                    url,
                    HttpMethod.POST,
                    entity,
                    Map.class
                );

                if (!resp.getStatusCode().is2xxSuccessful()) {
                    throw new Exception("LibreTranslate HTTP " + resp.getStatusCodeValue());
                }

                Map respBody = resp.getBody();
                if (respBody == null) {
                    throw new Exception("LibreTranslate 응답 body가 null 입니다.");
                }

                Object translated = respBody.get("translatedText");
                if (translated == null) {
                    throw new Exception("LibreTranslate 응답에 translatedText 필드가 없습니다.");
                }

                return translated.toString();

            } catch (RestClientException e) {
                throw new Exception("LibreTranslate 호출 실패: " + e.getMessage(), e);
            }
        }

        private static RestTemplate createRestTemplate() {
            SimpleClientHttpRequestFactory factory = new SimpleClientHttpRequestFactory();
            factory.setConnectTimeout(5000);
            factory.setReadTimeout(30000);
            return new RestTemplate(factory);
        }

        private static String trimTrailingSlash(String s) {
            if (s == null) return "";
            if (s.endsWith("/")) return s.substring(0, s.length() - 1);
            return s;
        }
    }

    // ========================================================================
    // Qwen 클라이언트 (Ollama /api/chat 예제 기준)
    // ========================================================================

    /**
     * Qwen 클라이언트.
     *
     * 여기서는 Ollama 스타일 /api/chat 인터페이스를 기준으로 작성:
     *
     *   POST {baseUrl}/api/chat
     *   {
     *     "model": "qwen2.5:7b-instruct",
     *     "stream": false,
     *     "messages": [
     *       {"role": "system", "content": "..."},
     *       {"role": "user",   "content": "..."}
     *     ]
     *   }
     *
     * 응답 예시:
     *   {
     *     "model": "...",
     *     "created_at": "...",
     *     "message": {
     *       "role": "assistant",
     *       "content": "..."
     *     }
     *   }
     *
     * 만약 네 환경이 다르다면, 아래 chat()/translate() 내부만 적절히 고치면 된다.
     */
    private static class QwenClient {

        private final String baseUrl;
        private final String modelName;
        private final RestTemplate restTemplate;

        QwenClient(String baseUrl, String modelName) {
            this.baseUrl = trimTrailingSlash(baseUrl);
            this.modelName = modelName;
            this.restTemplate = createRestTemplate();
        }

        /**
         * 일반 챗봇 모드.
         * - 한국어로 물어보면 한국어로,
         * - 영어로 물어보면 영어로 답하도록 system 프롬프트를 설계.
         */
        String chat(String userText) throws Exception {
            String url = baseUrl + "/api/chat";

            Map<String, Object> systemMsg = new HashMap<String, Object>();
            systemMsg.put("role", "system");
            systemMsg.put("content",
                "You are a helpful general-purpose assistant in a 1:1 chat room.\n"
                    + "- NEVER just translate the user's message.\n"
                    + "- Always answer the question or respond naturally.\n"
                    + "- If the user uses Korean, answer in Korean.\n"
                    + "- If the user clearly uses another language, answer in that language.\n"
                    + "- Keep answers concise but helpful.\n"
            );

            Map<String, Object> userMsg = new HashMap<String, Object>();
            userMsg.put("role", "user");
            userMsg.put("content", userText);

            Map<String, Object> body = new HashMap<String, Object>();
            body.put("model", modelName);
            body.put("stream", Boolean.FALSE);
            body.put("messages", new Map[]{systemMsg, userMsg});

            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);

            HttpEntity<Map<String, Object>> entity = new HttpEntity<Map<String, Object>>(body, headers);

            try {
                ResponseEntity<Map> resp = restTemplate.exchange(
                    url,
                    HttpMethod.POST,
                    entity,
                    Map.class
                );

                if (!resp.getStatusCode().is2xxSuccessful()) {
                    throw new Exception("Qwen(chat) HTTP " + resp.getStatusCodeValue());
                }

                Map respBody = resp.getBody();
                if (respBody == null) {
                    throw new Exception("Qwen(chat) 응답 body가 null 입니다.");
                }

                Object messageObj = respBody.get("message");
                if (!(messageObj instanceof Map)) {
                    throw new Exception("Qwen(chat) 응답의 message 필드가 Map 이 아닙니다.");
                }

                Map messageMap = (Map) messageObj;
                Object contentObj = messageMap.get("content");
                if (contentObj == null) {
                    throw new Exception("Qwen(chat) 응답의 content 필드가 없습니다.");
                }

                return contentObj.toString();

            } catch (RestClientException e) {
                throw new Exception("Qwen(chat) 호출 실패: " + e.getMessage(), e);
            }
        }

        /**
         * Qwen을 "번역기"로 사용하는 모드.
         * - system 프롬프트로 번역 역할을 강제.
         */
        String translate(String text, String sourceLang, String targetLang) throws Exception {
            String url = baseUrl + "/api/chat";

            String src = (sourceLang != null && !sourceLang.trim().isEmpty())
                ? sourceLang.trim() : "auto";
            String tgt = (targetLang != null && !targetLang.trim().isEmpty())
                ? targetLang.trim() : "ko";

            Map<String, Object> systemMsg = new HashMap<String, Object>();
            systemMsg.put("role", "system");
            systemMsg.put("content",
                "You are a translation engine.\n"
                    + "- Detect the source language if needed.\n"
                    + "- Translate the user's message from '" + src + "' to '" + tgt + "'.\n"
                    + "- Return ONLY the translated sentence, no explanations, no quotes.\n"
            );

            Map<String, Object> userMsg = new HashMap<String, Object>();
            userMsg.put("role", "user");
            userMsg.put("content", text);

            Map<String, Object> body = new HashMap<String, Object>();
            body.put("model", modelName);
            body.put("stream", Boolean.FALSE);
            body.put("messages", new Map[]{systemMsg, userMsg});

            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);

            HttpEntity<Map<String, Object>> entity = new HttpEntity<Map<String, Object>>(body, headers);

            try {
                ResponseEntity<Map> resp = restTemplate.exchange(
                    url,
                    HttpMethod.POST,
                    entity,
                    Map.class
                );

                if (!resp.getStatusCode().is2xxSuccessful()) {
                    throw new Exception("Qwen(translate) HTTP " + resp.getStatusCodeValue());
                }

                Map respBody = resp.getBody();
                if (respBody == null) {
                    throw new Exception("Qwen(translate) 응답 body가 null 입니다.");
                }

                Object messageObj = respBody.get("message");
                if (!(messageObj instanceof Map)) {
                    throw new Exception("Qwen(translate) 응답의 message 필드가 Map 이 아닙니다.");
                }

                Map messageMap = (Map) messageObj;
                Object contentObj = messageMap.get("content");
                if (contentObj == null) {
                    throw new Exception("Qwen(translate) 응답의 content 필드가 없습니다.");
                }

                return contentObj.toString();

            } catch (RestClientException e) {
                throw new Exception("Qwen(translate) 호출 실패: " + e.getMessage(), e);
            }
        }

        private static RestTemplate createRestTemplate() {
            SimpleClientHttpRequestFactory factory = new SimpleClientHttpRequestFactory();
            factory.setConnectTimeout(5000);
            factory.setReadTimeout(60000);
            return new RestTemplate(factory);
        }

        private static String trimTrailingSlash(String s) {
            if (s == null) return "";
            if (s.endsWith("/")) return s.substring(0, s.length() - 1);
            return s;
        }
    }
}
