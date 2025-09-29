package www.com.user.service;

import www.com.session.AuthenticationException;

import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContext;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.web.context.HttpSessionSecurityContextRepository;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

/**
 * 홈페이지 사용자의 인증 정보 객체를 가져오고 설정한다.
 */
public abstract class UserSessionManager {

    /** 로그인 사용자 VO를 가져온다. 인증이 없으면 AuthenticationException */
    public static UserVO getLoginUserVO() {
        if (isUserLogined()) {
            Object principal = SecurityContextHolder.getContext().getAuthentication().getPrincipal();
            return (UserVO) principal;
        }
        throw new AuthenticationException();
    }

    /** 사용자 인증 여부 */
    public static boolean isUserLogined() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        return auth != null && auth.getPrincipal() instanceof UserVO;
    }

    /** OAuth 등 수동 로그인 성공 후 SecurityContext + 세션 저장 */
    public static void setLoginUserVO(UserVO vo, HttpServletRequest req) {
        UsernamePasswordAuthenticationToken auth =
            new UsernamePasswordAuthenticationToken(vo, vo.getPassword(), vo.getAuthorities());

        // 빈 컨텍스트 만들어 채워 넣는 게 안전
        SecurityContext context = SecurityContextHolder.createEmptyContext();
        context.setAuthentication(auth);
        SecurityContextHolder.setContext(context);

        HttpSession session = req.getSession(true);
        session.setAttribute(HttpSessionSecurityContextRepository.SPRING_SECURITY_CONTEXT_KEY, context);

        // 프로젝트에서 직접 쓰는 세션 키가 있으면 같이 저장(선택)
        session.setAttribute("LOGIN_USER", vo);
    }

    /** ✅ 로그아웃/초기화용 */
    public static void clearAuthentication() {
        // SecurityContext 초기화
        SecurityContextHolder.clearContext();

        // 세션에 저장된 SecurityContext 제거
        ServletRequestAttributes attrs = (ServletRequestAttributes) RequestContextHolder.getRequestAttributes();
        if (attrs != null) {
            HttpSession session = attrs.getRequest().getSession(false);
            if (session != null) {
                session.removeAttribute(HttpSessionSecurityContextRepository.SPRING_SECURITY_CONTEXT_KEY);
            }
        }
    }
}