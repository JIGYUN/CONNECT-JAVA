// filepath: src/main/java/www/com/ai/QwenTranslateClient.java
package www.com.ai;

import java.io.*;
import java.net.HttpURLConnection;
import java.net.URL;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

public class QwenTranslateClient {

    private final String baseUrl; // 예: "http://localhost:11434"
    private final String model;   // 예: "qwen2.5:7b-instruct"
    private final ObjectMapper om = new ObjectMapper();

    public QwenTranslateClient(String baseUrl, String model) {
        this.baseUrl = baseUrl;
        this.model = model;
    }

    public String translate(String text, String sourceLang, String targetLang) {
        try {
            URL url = new URL(baseUrl + "/api/chat");
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("POST");
            conn.setConnectTimeout(5000);
            conn.setReadTimeout(60000);
            conn.setRequestProperty("Content-Type", "application/json");
            conn.setDoOutput(true);

            // Qwen에게 던질 프롬프트 (단순 버전)
            String prompt = buildPrompt(text, sourceLang, targetLang);

            // Ollama chat 포맷
            String bodyJson = om.writeValueAsString(om.createObjectNode()
                .put("model", model)
                .put("stream", false)
                .set("messages", om.createArrayNode()
                    .add(om.createObjectNode()
                        .put("role", "user")
                        .put("content", prompt))));

            try (OutputStream os = conn.getOutputStream()) {
                os.write(bodyJson.getBytes("UTF-8"));
            }

            int status = conn.getResponseCode();
            InputStream is = (status >= 200 && status < 300)
                ? conn.getInputStream()
                : conn.getErrorStream();

            String resp = readAll(is);

            if (status < 200 || status >= 300) {
                // 여기서 400이면 그대로 던짐 → ChatAiStompController에서 translateErrorMsg로 들어감
                throw new IllegalStateException("QWEN HTTP " + status + " : " + resp);
            }

            JsonNode root = om.readTree(resp);
            String content = root.path("message").path("content").asText(""); // Ollama 응답 구조
            return content.trim();
        } catch (Exception e) {
            throw new RuntimeException("QWEN translate failed: " + e.getMessage(), e);
        }
    }

    private String buildPrompt(String text, String sourceLang, String targetLang) {
        // 필요하면 sourceLang 써서 "auto detect" 프롬프트 넣어도 됨
        return "Translate the following text into " + targetLang + ":\n\n" + text;
    }

    private String readAll(InputStream is) throws IOException {
        if (is == null) return "";
        try (BufferedReader br = new BufferedReader(new InputStreamReader(is, "UTF-8"))) {
            StringBuilder sb = new StringBuilder();
            String line;
            while ((line = br.readLine()) != null) {
                sb.append(line).append('\n');
            }
            return sb.toString();
        }
    }
}
