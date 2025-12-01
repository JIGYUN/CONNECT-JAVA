// filepath: src/main/java/www/com/ai/LibreTranslateClient.java
package www.com.ai;

import java.io.*;
import java.net.HttpURLConnection;
import java.net.URL;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

public class LibreTranslateClient {

    private final String baseUrl; // 예: "http://localhost:5000"
    private final ObjectMapper om = new ObjectMapper();

    public LibreTranslateClient(String baseUrl) {
        this.baseUrl = baseUrl;
    }

    public String translate(String text, String sourceLang, String targetLang) {
        try {
            URL url = new URL(baseUrl + "/translate");
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("POST");
            conn.setConnectTimeout(5000);
            conn.setReadTimeout(20000);
            conn.setRequestProperty("Content-Type", "application/json");
            conn.setDoOutput(true);

            // LibreTranslate API 스펙에 맞는 바디
            String bodyJson = om.writeValueAsString(om.createObjectNode()
                .put("q", text)
                .put("source", sourceLang) // "auto" 지원 여부는 실제 이미지 설정에 따라 다름
                .put("target", targetLang)
                .put("format", "text"));

            try (OutputStream os = conn.getOutputStream()) {
                os.write(bodyJson.getBytes("UTF-8"));
            }

            int status = conn.getResponseCode();
            InputStream is = (status >= 200 && status < 300)
                ? conn.getInputStream()
                : conn.getErrorStream();

            String resp = readAll(is);

            if (status < 200 || status >= 300) {
                throw new IllegalStateException("LT HTTP " + status + " : " + resp);
            }

            JsonNode root = om.readTree(resp);
            String translated = root.path("translatedText").asText("");
            return translated.trim();
        } catch (Exception e) {
            throw new RuntimeException("LT translate failed: " + e.getMessage(), e);
        }
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
