package www.com.oauth.web;

import www.com.oauth.service.GoogleAuthService;
import www.com.user.service.UserSessionManager;
import www.com.user.service.UserVO;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.net.URLEncoder;
import java.security.SecureRandom;
import java.util.Base64;
import java.util.Map;

// ★ 핵심: SecurityContext 직접 생성/저장에 필요한 import
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContext;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.security.web.context.HttpSessionSecurityContextRepository;

@Controller
public class GoogleAuthController {

    @Resource private GoogleAuthService googleAuthService;
    private final SecureRandom rnd = new SecureRandom();

    @RequestMapping("/auth/google/login")
    public void login(HttpServletRequest req, HttpServletResponse res) throws Exception {
        String state = genState();
        req.getSession(true).setAttribute("GOOGLE_STATE", state);
        res.sendRedirect(googleAuthService.buildAuthUrl(state));
    }

    @RequestMapping("/auth/google/callback")
    public void callback(HttpServletRequest req, HttpServletResponse res) throws Exception {
        String error = req.getParameter("error");
        if (error != null) {
            res.sendRedirect(req.getContextPath()+"/mba/auth/login?err="+URLEncoder.encode(error, "UTF-8"));
            return;
        }

        String state = req.getParameter("state");
        String expected = (String) req.getSession().getAttribute("GOOGLE_STATE");
        if (expected == null || !expected.equals(state)) {
            res.sendRedirect(req.getContextPath()+"/mba/auth/login?err=state_mismatch");
            return;
        }

        String code = req.getParameter("code");
        Map<String,String> token  = googleAuthService.exchangeCodeForToken(code);
        String accessToken = token.get("access_token");
        if (accessToken == null) {
            res.sendRedirect(req.getContextPath()+"/mba/auth/login?err=token_null");
            return;
        }

        Map<String,String> uinfo  = googleAuthService.fetchUserInfo(accessToken);
        googleAuthService.upsertUserFromGoogle(uinfo);

        UserVO loginVo = googleAuthService.loadSessionUser(uinfo.get("email"));
        if (loginVo == null) {
            res.sendRedirect(req.getContextPath()+"/mba/auth/login?err=user_not_found");
            return;
        }

        // ---------- 핵심: 시큐리티 컨텍스트를 '명시적으로' 세션에 저장 ----------
        // 1) 빈 컨텍스트 생성
        SecurityContext context = SecurityContextHolder.createEmptyContext();

        // 2) 인증 토큰 구성 (+ 요청 정보 details 세팅 권장)
        UsernamePasswordAuthenticationToken auth =
            new UsernamePasswordAuthenticationToken(loginVo, loginVo.getPassword(), loginVo.getAuthorities());
        auth.setDetails(new WebAuthenticationDetailsSource().buildDetails(req));

        // 3) 컨텍스트에 인증 주입
        context.setAuthentication(auth);
        SecurityContextHolder.setContext(context);

        // 4) 리파지토리로 세션에 강제 저장
        HttpSessionSecurityContextRepository repo = new HttpSessionSecurityContextRepository();
        repo.setAllowSessionCreation(true);                 // 세션 생성 허용
        repo.saveContext(context, req, res);                // ★ 저장 트리거

        // (선택) 세션 고정화 방지
        try { req.changeSessionId(); } catch (Throwable ignore) {}

        // 우리 유틸에서도 병행 저장 원하면 유지
        UserSessionManager.setLoginUserVO(loginVo, req);

        req.getSession().removeAttribute("GOOGLE_STATE");
        res.sendRedirect(req.getContextPath()+"/");
    }

    private String genState() {
        byte[] b = new byte[16];
        rnd.nextBytes(b);
        return Base64.getUrlEncoder().withoutPadding().encodeToString(b);
    }
}