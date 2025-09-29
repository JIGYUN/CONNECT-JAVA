package www.com.oauth;

import org.springframework.stereotype.Service;
import org.springframework.beans.factory.annotation.Value;

import java.io.*;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.util.*;

import com.fasterxml.jackson.databind.ObjectMapper;

import www.com.util.CoreProperties;

/** Google OAuth HTTP 담당 */
@Service("googleOAuthService") // ← @Resource 이름 매칭
public class GoogleOAuthService {

    private String clientId = CoreProperties.getProperty("google.oauth.clientId");

    private String clientSecret  = CoreProperties.getProperty("google.oauth.clientSecret");

    private String redirectUri  = CoreProperties.getProperty("google.oauth.redirectUri");

    // properties에 없으면 기본값 사용
    @Value("${google.oauth.scope:openid email profile}") 
    private String scope;
    
    private static final String AUTH_URL  = "https://accounts.google.com/o/oauth2/v2/auth";
    private static final String TOKEN_URL = "https://oauth2.googleapis.com/token";
    private static final String USERINFO  = "https://www.googleapis.com/oauth2/v3/userinfo";
    private static final ObjectMapper OM  = new ObjectMapper();

    /** 구글 인증 URL 생성 */
 // www/com/oauth/GoogleOAuthService.java
    public String buildAuthUrl(String state) throws Exception {
        // 설정값(프로퍼티) – 예: google.oauth.redirectUri=http://localhost:8080/auth/google/callback
        // 예: google.oauth.scope=openid email profile
        String redirect = redirectUri;              // 원본 그대로
        String auth = "https://accounts.google.com/o/oauth2/v2/auth";
        	
        String url = auth
                + "?client_id=" + URLEncoder.encode(clientId, "UTF-8")
                + "&redirect_uri=" + URLEncoder.encode(redirect, "UTF-8")
                + "&response_type=code"
                + "&scope=" + URLEncoder.encode(scope, "UTF-8")   // ← 꼭 인코딩!
                + "&state=" + URLEncoder.encode(state, "UTF-8")
                + "&access_type=offline"
                + "&include_granted_scopes=true";

        // 디버그
        System.out.println("[GAuth] redirect_uri(raw)=" + redirect);
        System.out.println("[GAuth] scope(raw)=" + scope);
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
        try(OutputStream os = con.getOutputStream()){
            os.write(body.getBytes("UTF-8"));
        }
        InputStream is = (con.getResponseCode() >= 200 && con.getResponseCode() < 300)
                ? con.getInputStream() : con.getErrorStream();
        return readAll(is);
    }

    private String buildForm(Map<String,String> form) throws UnsupportedEncodingException {
        StringBuilder sb = new StringBuilder();
        for(Map.Entry<String,String> e : form.entrySet()){
            if(sb.length()>0) sb.append('&');
            sb.append(URLEncoder.encode(e.getKey(), "UTF-8"))
              .append('=')
              .append(URLEncoder.encode(e.getValue(), "UTF-8"));
        }
        return sb.toString();
    }

    private String readAll(InputStream is) throws IOException {
        try(BufferedReader br = new BufferedReader(new InputStreamReader(is, "UTF-8"))){
            StringBuilder sb = new StringBuilder(); String line;
            while((line = br.readLine()) != null) sb.append(line);
            return sb.toString();
        }
    }

    private Map<String,String> toStringMap(Map<String,Object> src){
        Map<String,String> d = new HashMap<>();
        if(src==null) return d;
        for(Map.Entry<String,Object> e: src.entrySet()){
            d.put(e.getKey(), e.getValue()==null? null : String.valueOf(e.getValue()));
        }
        return d;
    }
}