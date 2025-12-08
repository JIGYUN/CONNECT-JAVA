// filepath: src/main/java/www/api/mba/auth/service/AuthService.java
package www.api.mba.auth.service;

import java.security.SecureRandom;
import java.util.Base64;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import egovframework.rte.fdl.cmmn.EgovAbstractServiceImpl;
import www.com.util.CommonDao;
import www.com.util.Sha256;

import www.com.oauth.service.GoogleAuthService;
import www.com.user.service.UserSessionManager;
import www.com.user.service.UserVO;

import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContext;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.security.web.context.HttpSessionSecurityContextRepository;

/**
 * 인증/회원 관련 서비스
 */
@Service
public class AuthService extends EgovAbstractServiceImpl {

    private Logger logger = LoggerFactory.getLogger(this.getClass());

    @Autowired
    private CommonDao dao;

    @Autowired
    private GoogleAuthService googleAuthService;

    private final String namespace = "www.api.mba.auth.Auth";

    private final SecureRandom rnd = new SecureRandom();

    /* ================== 기존 회원가입/일반 로그인 ================== */

    @Transactional(propagation = Propagation.REQUIRED)
    public void insertJoin(Map<String, Object> params) {
        Sha256 sha256 = new Sha256();
        params.put("password", sha256.encrypt(String.valueOf(params.get("password"))));
        dao.insert(namespace + ".insertJoin", params);
    }

    /**
     * 일반 로그인 (이메일 + 패스워드)
     */
    public Map<String, Object> selectLogin(Map<String, Object> params) {
        Sha256 sha256 = new Sha256();
        params.put("password", sha256.encrypt(String.valueOf(params.get("password"))));

        Map<String, Object> user = dao.selectOne(namespace + ".selectLogin", params);

        // 로그인 성공 시 FCM 토큰 업데이트
        if (user != null) {
            Object t = params.get("fcmToken");
            String token = (t == null) ? null : String.valueOf(t).trim();
            if (token != null && !token.isEmpty()) {
                Object uidObj = user.containsKey("USER_ID") ? user.get("USER_ID") : user.get("userId");
                Long userId = (uidObj == null) ? null : Long.valueOf(String.valueOf(uidObj));
                if (userId != null) {
                    Map<String, Object> up = new HashMap<>();
                    up.put("userId", userId);
                    up.put("fcmToken", token);

                    Object p = params.get("platformInfo");
                    String platformInfo = (p == null) ? null : String.valueOf(p).trim();
                    if (platformInfo != null && !platformInfo.isEmpty()) {
                        up.put("platformInfo", platformInfo);
                    }

                    dao.update(namespace + ".updateToken", up);
                }
            }
        }

        return user;
    }

    public Map<String, Object> selectIdPwFind(Map<String, Object> params) {
        return dao.selectOne(namespace + ".selectIdPwFind", params);
    }

    public Map<String, Object> duplicateId(Map<String, Object> params) {
        return dao.selectOne(namespace + ".duplicateId", params);
    }

    public Map<String, Object> findId(Map<String, Object> params) {
        return dao.selectOne(namespace + ".findId", params);
    }

    public int changePassword(Map<String, Object> params) {
        Sha256 sha256 = new Sha256();
        params.put("password", sha256.encrypt(String.valueOf(params.get("password"))));
        return dao.update(namespace + ".changePassword", params);
    }

    /* ================== 구글 로그인 임시 토큰 플로우 ================== */

    /**
     * 구글 로그인용 임시 로그인 토큰 발급
     * (구글 콜백에서 호출)
     */
    @Transactional(propagation = Propagation.REQUIRED)
    public String issueLoginToken(String email) {
        String tokenId = genTokenId();

        Map<String, Object> p = new HashMap<>();
        p.put("tokenId", tokenId);
        p.put("email", email);
        p.put("expiresMinutes", 5); // 5분 유효
        p.put("createdBy", email);

        dao.insert(namespace + ".insertLoginToken", p);

        logger.info("Issued login token for email={}, tokenId={}", email, tokenId);
        return tokenId;
    }

    /**
     * 임시토큰 소비 + Spring Security 세션 생성
     *  - 유효한 토큰인지 검증
     *  - TB_LOGIN_TOKEN.USED_AT = 'Y' 로 마킹
     *  - EMAIL 기준으로 UserVO 조회
     *  - SecurityContext + HttpSession(JSESSIONID) 생성
     *  - 프론트에 내려줄 UserVO 리턴
     */
    @Transactional(propagation = Propagation.REQUIRED)
    public UserVO consumeLoginTokenAndCreateSession(
            String tokenId,
            HttpServletRequest req,
            HttpServletResponse res
    ) {
        if (tokenId == null || tokenId.trim().isEmpty()) {
            logger.info("consumeLoginTokenAndCreateSession: tokenId empty");
            return null;
        }

        Map<String, Object> param = new HashMap<>();
        param.put("tokenId", tokenId);

        // 1) 유효 토큰 조회
        Map<String, Object> row = dao.selectOne(namespace + ".selectValidLoginToken", param);
        if (row == null) {
            logger.info("consumeLoginTokenAndCreateSession: no valid token. tokenId={}", tokenId);
            return null;
        }

        // MyBatis resultType=hashmap → 키가 EMAIL 또는 email 일 수 있음
        Object emailObj = row.get("email");
        if (emailObj == null) {
            emailObj = row.get("EMAIL");
        }
        String email = (emailObj == null) ? null : String.valueOf(emailObj);

        // 2) 토큰 사용 처리
        dao.update(namespace + ".markLoginTokenUsed", param);
        logger.info("Consumed login token tokenId={}, email={}", tokenId, email);

        if (email == null || email.trim().isEmpty()) {
            logger.warn("consumeLoginTokenAndCreateSession: email null, abort");
            return null;
        }

        // 3) 이메일로 UserVO 로드
        UserVO loginVo = googleAuthService.loadSessionUser(email);
        if (loginVo == null) {
            logger.warn("consumeLoginTokenAndCreateSession: user not found for email={}", email);
            return null;
        }

        // 4) Spring Security 컨텍스트 + 세션 구성
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

        return loginVo;
    }

    /* ================== 내부 util ================== */

    private String genTokenId() {
        byte[] b = new byte[32];
        rnd.nextBytes(b);
        return Base64.getUrlEncoder().withoutPadding().encodeToString(b);
    }
}
