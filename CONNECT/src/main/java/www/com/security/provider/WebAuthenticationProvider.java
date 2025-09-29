package www.com.security.provider;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import javax.servlet.http.HttpServletRequest;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.AuthenticationProvider;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UsernameNotFoundException;

import www.api.mba.auth.service.AuthService;
import www.com.spring.web.HttpServletRequestProvider;
import www.com.user.service.UserVO;
import www.com.util.Sha256;
import www.com.util.StringUtil;

public class WebAuthenticationProvider implements AuthenticationProvider {

    private static final Logger logger = LoggerFactory.getLogger(WebAuthenticationProvider.class);

    @Autowired
    private AuthService authService;

    @Override
    public Authentication authenticate(Authentication authentication) throws AuthenticationException {
        HttpServletRequest request = HttpServletRequestProvider.getHttpServletRequest();
        String loginType = request.getParameter("loginType");  // "ADMIN" or "BASIC"
        String mberId    = request.getParameter("mberId");
        String mberPw    = request.getParameter("mberPw");

        try {
            if (!"".equals(StringUtil.nullConvert(loginType))) {
                return checkLogin(request, loginType, mberId, mberPw);
            } else {
                throw new UsernameNotFoundException("exception");
            }
        } catch (AuthenticationException ae) {
            throw ae; // 실패 핸들러로 위임
        } catch (Exception e) {
            logger.error("authenticate error", e);
            throw new UsernameNotFoundException("exception");
        }
    }

    private Authentication checkLogin(HttpServletRequest request, String loginType, String mberId, String mberPw) throws Exception {
        Map<String, Object> params = new HashMap<>();
        Sha256 sha256 = new Sha256();

        params.put("email", mberId);
        params.put("passwordHash", sha256.encrypt(mberPw));

        Map<String, Object> map = authService.selectLogin(params);
        if (map == null) {
            throw new UsernameNotFoundException("has no uniqid");
        }

        UserVO userVO = new UserVO(
            String.valueOf(map.get("userId")),
            String.valueOf(map.get("email")), 
            String.valueOf(map.get("passwordHash")),
            String.valueOf(map.get("userNm")),
            String.valueOf(map.get("nickNm")),
            String.valueOf(map.get("profileImgUrl")),
            String.valueOf(map.get("telno")),
            String.valueOf(map.get("authType")) // 'A' or 'U'
        );

        // ★ 관리자 화면에서 일반 계정이면: 인증 실패로 처리 → 실패 핸들러가 로그인 페이지로 리다이렉트
        if ("ADMIN".equalsIgnoreCase(loginType) && !"A".equalsIgnoreCase(userVO.getAuthType())) {
            throw new UsernameNotFoundException("not admin");
        }

        // 권한 부여
        List<GrantedAuthority> roles = new ArrayList<>();
        roles.add(new SimpleGrantedAuthority("EXTERNAL_AUTH"));
        roles.add(new SimpleGrantedAuthority("USER"));
        if ("A".equalsIgnoreCase(userVO.getAuthType())) {
            roles.add(new SimpleGrantedAuthority("ADMIN"));
        }
        userVO.setAuthorities(roles);

        return new UsernamePasswordAuthenticationToken(userVO, null, roles);
    }

    @Override
    public boolean supports(Class<?> authentication) {
        return UsernamePasswordAuthenticationToken.class.isAssignableFrom(authentication);
    }
}