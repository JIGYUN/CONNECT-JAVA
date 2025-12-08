// filepath: src/main/java/www/com/oauth/web/GoogleAuthController.java
package www.com.oauth.web;

import www.com.oauth.service.GoogleAuthService;
import www.api.mba.auth.service.AuthService;
import www.com.user.service.UserSessionManager;
import www.com.user.service.UserVO;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import javax.annotation.Resource;
import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.net.URLDecoder;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.security.SecureRandom;
import java.util.Base64;
import java.util.Map;

import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContext;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.security.web.context.HttpSessionSecurityContextRepository;

@Controller
public class GoogleAuthController {

    private static final String SESSION_KEY_STATE = "GOOGLE_STATE_NONCE";
    private static final String COOKIE_STATE      = "GOOGLE_STATE_NONCE";

    // state = "<nonce>.<base64url(redirect)>"
    private static final String STATE_SEP = ".";

    @Resource
    private GoogleAuthService googleAuthService;

    @Resource
    private AuthService authService;

    private final SecureRandom rnd = new SecureRandom();

    /** 애플리케이션 컨텍스트 경로 (URL 조합용) */
    private String appCtx(HttpServletRequest req) {
        String ctx = req.getContextPath();
        if (ctx == null || "/".equals(ctx) || ctx.isEmpty()) {
            return "";
        }
        return ctx;
    }

    /** 쿠키 path 용 */
    private String cookiePath(HttpServletRequest req) {
        String ctx = appCtx(req);
        return ctx.isEmpty() ? "/" : ctx;
    }

    /** state 문자열 생성: "<nonce>.<base64url(redirect)>" */
    private String buildState(String nonce, String redirect) {
        if (redirect == null) {
            redirect = "";
        } else {
            redirect = redirect.trim();
        }

        if (redirect.isEmpty()) {
            return nonce;
        }

        String encodedRedirect = Base64.getUrlEncoder()
                .withoutPadding()
                .encodeToString(redirect.getBytes(StandardCharsets.UTF_8));

        return nonce + STATE_SEP + encodedRedirect;
    }

    /** state 파싱 결과 구조체 */
    private static final class StateInfo {
        final String nonce;
        final String redirect;

        StateInfo(String nonce, String redirect) {
            this.nonce = nonce;
            this.redirect = redirect;
        }
    }

    /** state 문자열 파싱: "<nonce>.<base64url(redirect)>" */
    private StateInfo parseState(String rawState) {
        if (rawState == null || rawState.isEmpty()) {
            return new StateInfo(null, null);
        }

        int idx = rawState.indexOf(STATE_SEP);
        if (idx < 0) {
            // redirect 포함 안 된 state
            return new StateInfo(rawState, null);
        }

        String nonce = rawState.substring(0, idx);
        String encodedRedirect = rawState.substring(idx + 1);

        if (encodedRedirect.isEmpty()) {
            return new StateInfo(nonce, null);
        }

        try {
            byte[] decoded = Base64.getUrlDecoder().decode(encodedRedirect);
            String redirect = new String(decoded, StandardCharsets.UTF_8);
            return new StateInfo(nonce, redirect);
        } catch (Exception e) {
            // 디코드 실패하면 redirect 는 무시
            return new StateInfo(nonce, null);
        }
    }

    /** 1단계: 우리 서버 -> 구글 로그인 */
    @RequestMapping("/auth/google/login")
    public void login(HttpServletRequest req, HttpServletResponse res) throws Exception {
        // React 에서 encodeURIComponent 로 줬으므로 한 번 더 디코드
        String redirect = req.getParameter("redirect");
        if (redirect != null && !redirect.trim().isEmpty()) {
            redirect = URLDecoder.decode(redirect.trim(), "UTF-8");
        } else {
            redirect = null;
        }

        String nonce = genState();
        String state = buildState(nonce, redirect);

        // 세션에 nonce 저장
        req.getSession(true).setAttribute(SESSION_KEY_STATE, nonce);
        System.out.println("[GAuth] LOGIN sessionId=" + req.getSession().getId());
        System.out.println("[GAuth] login: nonce=" + nonce);
        System.out.println("[GAuth] login: redirect=" + redirect);

        // nonce 쿠키 저장
        Cookie c = new Cookie(COOKIE_STATE, nonce);
        c.setHttpOnly(true);
        c.setPath(cookiePath(req));
        c.setMaxAge(5 * 60);
        res.addCookie(c);

        String authUrl = googleAuthService.buildAuthUrl(state);
        System.out.println("[GAuth] AUTH_URL=" + authUrl);

        res.sendRedirect(authUrl);
    }

    /** 2단계: 구글 콜백 */
    @RequestMapping("/auth/google/callback")
    public void callback(HttpServletRequest req, HttpServletResponse res) throws Exception {
        System.out.println("[GAuth] >>> callback ENTER");
        System.out.println("[GAuth] CALLBACK session=" +
                (req.getSession(false) != null ? req.getSession(false).getId() : "null"));

        String error = req.getParameter("error");
        if (error != null) {
            System.out.println("[GAuth] error from google = " + error);
            redirectWithError(req, res, "google_error=" + URLEncoder.encode(error, "UTF-8"));
            return;
        }

        String rawState = req.getParameter("state");
        StateInfo stateInfo = parseState(rawState);
        String stateNonce       = stateInfo.nonce;
        String redirectFromState = stateInfo.redirect;

        // 기대 nonce 로드 (세션 -> 쿠키)
        String expectedNonce = null;
        if (req.getSession(false) != null) {
            expectedNonce = (String) req.getSession(false).getAttribute(SESSION_KEY_STATE);
        }
        if (expectedNonce == null && req.getCookies() != null) {
            for (Cookie ck : req.getCookies()) {
                if (COOKIE_STATE.equals(ck.getName())) {
                    expectedNonce = ck.getValue();
                    break;
                }
            }
        }

        System.out.println("[GAuth] stateRaw=" + rawState
                + ", stateNonce=" + stateNonce
                + ", redirectFromState=" + redirectFromState
                + ", expectedNonce=" + expectedNonce);

        // 로컬 여부
        String host = req.getServerName();
        boolean isLocalHost = "localhost".equalsIgnoreCase(host)
                || "127.0.0.1".equals(host);

        // nonce 검증
        if (stateNonce == null || expectedNonce == null || !expectedNonce.equals(stateNonce)) {
            if (isLocalHost) {
                System.out.println("[GAuth] LOCAL DEV: nonce mismatch지만 진행");
            } else {
                System.out.println("[GAuth] NONCE_MISMATCH (PROD)");
                redirectWithError(req, res, "state_mismatch");
                return;
            }
        }

        String code = req.getParameter("code");
        System.out.println("[GAuth] code=" + code);

        Map<String, String> token = googleAuthService.exchangeCodeForToken(code);
        System.out.println("[GAuth] tokenResp=" + token);

        String accessToken = token.get("access_token");
        if (accessToken == null) {
            System.out.println("[GAuth] access_token null");
            redirectWithError(req, res, "token_null");
            return;
        }

        Map<String, String> uinfo = googleAuthService.fetchUserInfo(accessToken);
        System.out.println("[GAuth] uinfo=" + uinfo);

        // TB_USER upsert
        googleAuthService.upsertUserFromGoogle(uinfo);

        // 세션용 유저 로드
        UserVO loginVo = googleAuthService.loadSessionUser(uinfo.get("email"));
        System.out.println("[GAuth] loginVo=" + loginVo);
        if (loginVo == null) {
            redirectWithError(req, res, "user_not_found");
            return;
        }

        // ── 1) (자바/JSP용) Spring Security 세션 구성 ──
        SecurityContext context = SecurityContextHolder.createEmptyContext();
        UsernamePasswordAuthenticationToken auth =
                new UsernamePasswordAuthenticationToken(
                        loginVo,
                        loginVo.getPassword(),
                        loginVo.getAuthorities()
                );
        auth.setDetails(new WebAuthenticationDetailsSource().buildDetails(req));
        context.setAuthentication(auth);
        SecurityContextHolder.setContext(context);

        HttpSessionSecurityContextRepository repo = new HttpSessionSecurityContextRepository();
        repo.setAllowSessionCreation(true);
        repo.saveContext(context, req, res);

        try {
            req.changeSessionId();
        } catch (Throwable ignore) {
        }

        UserSessionManager.setLoginUserVO(loginVo, req);

        // nonce 정리
        if (req.getSession(false) != null) {
            req.getSession(false).removeAttribute(SESSION_KEY_STATE);
        }
        Cookie clear = new Cookie(COOKIE_STATE, "");
        clear.setPath(cookiePath(req));
        clear.setMaxAge(0);
        clear.setHttpOnly(true);
        res.addCookie(clear);

        // ── 2) 리다이렉트 대상 결정 ──
        String target;
        boolean isReactRedirect = redirectFromState != null
                && redirectFromState.startsWith("http");

        if (isReactRedirect) {
            // React → 임시 로그인 토큰 발급
            System.out.println("[GAuth] React loginToken flow 시작");
            String loginToken = authService.issueLoginToken(loginVo.getEmail());
            System.out.println("[GAuth] loginToken=" + loginToken);

            String base = redirectFromState.trim();
            String sep = base.contains("?") ? "&" : "?";
            target = base + sep + "loginToken=" + URLEncoder.encode(loginToken, "UTF-8");
            System.out.println("[GAuth] (REACT) redirecting to: " + target);
        } else if (redirectFromState != null && !redirectFromState.trim().isEmpty()) {
            // 서버 내부 경로 리다이렉트 (JSP 등)
            target = redirectFromState.trim();
            System.out.println("[GAuth] (JSP) redirecting to: " + target);
        } else {
            String ctx = appCtx(req);
            target = ctx.isEmpty() ? "/" : ctx + "/";
            System.out.println("[GAuth] redirecting to ctx root: " + target);
        }

        res.sendRedirect(target);
    }

    private void redirectWithError(HttpServletRequest req, HttpServletResponse res, String err) throws Exception {
        String rawState = req.getParameter("state");
        StateInfo stateInfo = parseState(rawState);
        String redirect = stateInfo.redirect;

        String ctx = appCtx(req);
        if (redirect != null && !redirect.trim().isEmpty()) {
            String base = redirect.trim();
            String sep = base.contains("?") ? "&" : "?";
            String target = base + sep + "err=" + URLEncoder.encode(err, "UTF-8");
            System.out.println("[GAuth] redirectWithError -> " + target);
            res.sendRedirect(target);
        } else {
            String target = (ctx.isEmpty() ? "" : ctx)
                    + "/mba/auth/login?err=" + URLEncoder.encode(err, "UTF-8");
            System.out.println("[GAuth] redirectWithError(fallback) -> " + target);
            res.sendRedirect(target);
        }
    }

    private String genState() {
        byte[] b = new byte[16];
        rnd.nextBytes(b);
        return Base64.getUrlEncoder().withoutPadding().encodeToString(b);
    }
}
