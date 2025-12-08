// filepath: src/main/java/www/com/oauth/GoogleOAuthService.java
package www.com.oauth;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.io.*;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.util.*;

import com.fasterxml.jackson.databind.ObjectMapper;

/** Google OAuth HTTP 담당 */
@Service("googleOAuthService")
public class GoogleOAuthService {

    @Value("#{ConfigProperties['google.oauth.clientId']}")
    private String clientId;

    @Value("#{ConfigProperties['google.oauth.clientSecret']}")
    private String clientSecret;

    @Value("#{ConfigProperties['google.oauth.redirectUri']}")
    private String redirectUri;

    @Value("#{ConfigProperties['google.oauth.scope']}")
    private String scope; // null 이면 기본값 사용

    private static final String AUTH_URL  = "https://accounts.google.com/o/oauth2/v2/auth";
    private static final String TOKEN_URL = "https://oauth2.googleapis.com/token";
    private static final String USERINFO  = "https://www.googleapis.com/oauth2/v3/userinfo";
    private static final ObjectMapper OM  = new ObjectMapper();

    /** 구글 인증 URL 생성 */
    public String buildAuthUrl(String state) throws Exception {
        String rawScope = (scope == null || scope.trim().isEmpty())
                ? "openid email profile"
                : scope.trim();

        String redirect = redirectUri;

        System.out.println("[GAuth] client_id(raw)=" + clientId);
        System.out.println("[GAuth] redirect_uri(raw)=" + redirect);
        System.out.println("[GAuth] scope(raw)=" + rawScope);

        String url = AUTH_URL
                + "?client_id=" + URLEncoder.encode(clientId, "UTF-8")
                + "&redirect_uri=" + URLEncoder.encode(redirect, "UTF-8")
                + "&response_type=code"
                + "&scope=" + URLEncoder.encode(rawScope, "UTF-8")
                + "&state=" + URLEncoder.encode(state, "UTF-8")
                + "&access_type=offline"
                + "&include_granted_scopes=true";

        System.out.println("[GAuth] AUTH_URL=" + url);
        return url;
    }

    /** code → access_token 교환 */
    public Map<String,String> exchangeCodeForToken(String code) throws Exception {
        Map<String,String> form = new LinkedHashMap<>();
        form.put("code", code);
        form.put("client_id", clientId);
        form.put("client_secret", clientSecret);
        form.put("redirect_uri", redirectUri);
        form.put("grant_type", "authorization_code");
        String resp = postForm(TOKEN_URL, form);
        @SuppressWarnings("unchecked")
        Map<String,Object> m = OM.readValue(resp, Map.class);
        return toStringMap(m);
    }

    /** access_token → /userinfo */
    public Map<String,String> fetchUserInfo(String accessToken) throws Exception {
        URL url = new URL(USERINFO);
        HttpURLConnection con = (HttpURLConnection) url.openConnection();
        con.setRequestMethod("GET");
        con.setRequestProperty("Authorization", "Bearer " + accessToken);
        String resp = readAll(con.getInputStream());
        @SuppressWarnings("unchecked")
        Map<String,Object> m = OM.readValue(resp, Map.class);
        return toStringMap(m);
    }

    /* ---------- helpers ---------- */

    private String postForm(String url, Map<String,String> form) throws Exception {
        String body = buildForm(form);
        HttpURLConnection con = (HttpURLConnection) new URL(url).openConnection();
        con.setRequestMethod("POST");
        con.setDoOutput(true);
        con.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");
        try (OutputStream os = con.getOutputStream()) {
            os.write(body.getBytes("UTF-8"));
        }
        InputStream is = (con.getResponseCode() >= 200 && con.getResponseCode() < 300)
                ? con.getInputStream() : con.getErrorStream();
        return readAll(is);
    }

    private String buildForm(Map<String,String> form) throws UnsupportedEncodingException {
        StringBuilder sb = new StringBuilder();
        for (Map.Entry<String,String> e : form.entrySet()) {
            if (sb.length() > 0) sb.append('&');
            sb.append(URLEncoder.encode(e.getKey(), "UTF-8"))
              .append('=')
              .append(URLEncoder.encode(e.getValue(), "UTF-8"));
        }
        return sb.toString();
    }

    private String readAll(InputStream is) throws IOException {
        try (BufferedReader br = new BufferedReader(new InputStreamReader(is, "UTF-8"))) {
            StringBuilder sb = new StringBuilder();
            String line;
            while ((line = br.readLine()) != null) sb.append(line);
            return sb.toString();
        }
    }

    private Map<String,String> toStringMap(Map<String,Object> src) {
        Map<String,String> d = new HashMap<>();
        if (src == null) return d;
        for (Map.Entry<String,Object> e : src.entrySet()) {
            d.put(e.getKey(), (e.getValue() == null) ? null : String.valueOf(e.getValue()));
        }
        return d;
    }
}
