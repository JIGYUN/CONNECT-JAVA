// filepath: src/main/java/www/com/util/FirebaseAdminHolder.java
package www.com.firebase;

import com.google.auth.oauth2.GoogleCredentials;
import com.google.firebase.FirebaseApp;
import com.google.firebase.FirebaseOptions;
import com.google.firebase.messaging.FirebaseMessaging;

import java.io.ByteArrayInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.util.Base64;
import java.util.List;
import java.util.Objects;

/**
 * Firebase Admin SDK 단일 초기화/재사용 홀더.
 *
 * ─ 우선순위(크리덴셜 소스):
 *   1) 환경변수 CONNECT_FIREBASE_CRED
 *      - 파일 경로  (예: /opt/connect/xxx.json)
 *      - 또는 "base64:..." 형태(Base64 인코딩된 JSON)
 *   2) 시스템프로퍼티 CONNECT_FIREBASE_CRED (-DCONNECT_FIREBASE_CRED=...)
 *   3) 클래스패스 리소스 "/firebase-admin.json" (옵션)
 *
 * ─ 사용법:
 *   FirebaseMessaging fm = FirebaseAdminHolder.getMessaging();
 *   fm.send(message);
 */
public final class FirebaseAdminHolder {

    private static volatile FirebaseApp app;
    private static volatile FirebaseMessaging messaging;

    private FirebaseAdminHolder() {}

    /** 외부에서 강제로 초기화 경로를 지정하고 싶을 때(선택). */
    public static void initWithPath(String credPathOrBase64) {
        initInternal(credPathOrBase64, true);
    }

    /** FirebaseMessaging 핸들 가져오기(없으면 자동 초기화). */
    public static FirebaseMessaging getMessaging() {
        ensureInitialized();
        return messaging;
    }

    /** FirebaseApp 핸들(필요 시). */
    public static FirebaseApp getApp() {
        ensureInitialized();
        return app;
    }

    /** 필요 시 한 번만 초기화. */
    private static void ensureInitialized() {
        if (messaging != null) return;
        synchronized (FirebaseAdminHolder.class) {
            if (messaging != null) return;
            // 우선순위대로 자격증명 소스 선택
            String source = firstNonEmpty(
                    getenv("CONNECT_FIREBASE_CRED"),
                    System.getProperty("CONNECT_FIREBASE_CRED"),
                    // 마지막 fallback: 클래스패스의 고정 파일명(옵션)
                    "classpath:/firebase-admin.json"
            );
            initInternal(source, false);
        }
    }

    /** 실제 초기화 로직 */
    private static void initInternal(String credSource, boolean forceReinit) {
        try {
            if (app != null && !forceReinit) {
                // 이미 초기화되어 있으면 재사용
                return;
            }
            GoogleCredentials credentials = resolveCredentials(credSource);

            FirebaseOptions options = FirebaseOptions.builder()
                    .setCredentials(Objects.requireNonNull(credentials, "GoogleCredentials is null"))
                    .build();

            // 이미 기본 App 이 있다면 재활용, 없으면 생성
            List<FirebaseApp> apps = FirebaseApp.getApps();
            if (apps == null || apps.isEmpty()) {
                app = FirebaseApp.initializeApp(options);
            } else {
                // 동일 JVM 내에서 여러 번 초기화 시도 방지
                app = FirebaseApp.getInstance();
            }
            messaging = FirebaseMessaging.getInstance(app);

            // 종료 훅(선택)
            Runtime.getRuntime().addShutdownHook(new Thread(() -> {
                try { FirebaseApp.getInstance().delete(); } catch (Throwable ignore) {}
            }));

            System.out.println("[FirebaseInit] FirebaseApp initialized. source=" + safePrint(credSource));
        } catch (Exception e) {
            System.err.println("[FirebaseInit] FAIL to initialize: " + e.getMessage());
            throw new IllegalStateException("Firebase initialization failed", e);
        }
    }

    /** credSource를 실제 GoogleCredentials로 변환 */
    private static GoogleCredentials resolveCredentials(String source) throws Exception {
        if (isBlank(source)) {
            // classpath 기본값 시도
            InputStream is = fromClasspath("/firebase-admin.json");
            if (is == null) throw new IllegalStateException("No credentials source provided");
            return GoogleCredentials.fromStream(is);
        }

        // "classpath:/path" 지원
        if (source.startsWith("classpath:")) {
            String path = source.substring("classpath:".length());
            InputStream is = fromClasspath(path.startsWith("/") ? path : ("/" + path));
            if (is == null) throw new IllegalStateException("Classpath resource not found: " + source);
            return GoogleCredentials.fromStream(is);
        }

        // "base64:xxxxx" 지원
        if (source.startsWith("base64:")) {
            String b64 = source.substring("base64:".length());
            byte[] json = Base64.getDecoder().decode(b64);
            return GoogleCredentials.fromStream(new ByteArrayInputStream(json));
        }

        // 파일 경로로 처리
        File f = new File(source);
        if (!f.exists()) throw new IllegalStateException("Credentials file not found: " + f.getAbsolutePath());
        try (InputStream in = new FileInputStream(f)) {
            return GoogleCredentials.fromStream(in);
        }
    }

    private static InputStream fromClasspath(String p) {
        return FirebaseAdminHolder.class.getResourceAsStream(p);
    }

    private static String getenv(String k) {
        try { return System.getenv(k); } catch (Throwable ignore) { return null; }
    }

    private static boolean isBlank(String s) {
        return s == null || s.trim().isEmpty();
    }

    private static String firstNonEmpty(String... arr) {
        for (String s : arr) if (!isBlank(s)) return s;
        return null;
    }

    private static String safePrint(String s) {
        if (isBlank(s)) return "(none)";
        if (s.startsWith("base64:")) return "base64:(hidden)";
        if (s.startsWith("classpath:")) return s;
        // 파일경로는 앞부분만
        return s.length() > 64 ? s.substring(0, 64) + "..." : s;
    }
}
