package www.com.oauth.service;

import www.com.oauth.GoogleOAuthService;
import www.com.user.service.UserVO;
import www.com.util.CommonDao;

import org.springframework.stereotype.Service;

import javax.annotation.Resource;
import java.util.HashMap;
import java.util.Map;

@Service
public class GoogleAuthService {

    @Resource private CommonDao dao;
    @Resource private GoogleOAuthService googleOAuthService;

    private String namespace = "www.api.mba.auth.GoogleAuth";
    
    // --- OAuth 위임 ---
    // --- OAuth 위임 (예외 전파) ---
    public String buildAuthUrl(String state) throws Exception {
        return googleOAuthService.buildAuthUrl(state);
    }

    public Map<String,String> exchangeCodeForToken(String code) throws Exception {
        return googleOAuthService.exchangeCodeForToken(code);
    }

    public Map<String,String> fetchUserInfo(String accessToken) throws Exception {
        return googleOAuthService.fetchUserInfo(accessToken);
    }
    // --- DB 처리 ---
    public void upsertUserFromGoogle(Map<String,String> userinfo){
        String email   = userinfo.get("email"); 
        String name    = userinfo.get("name");     // 구글 계정 표시명
        String picture = userinfo.get("picture");  // 프로필 이미지
        String sub     = userinfo.get("sub");      // 소셜 고유 ID

        Map<String,Object> p = new HashMap<>();
        p.put("email",         email);
        p.put("userNm",        name);              // 실명 자리에 우선 name 사용
        p.put("nickNm",      name);              // 닉네임도 초기값으로 name
        p.put("profileImgUrl", picture);
        p.put("socialSub",     sub);
        p.put("authType",      "G");
        p.put("createdBy",     email);
        p.put("updatedBy",     email);

        Map<String,Object> exist = dao.selectOne(namespace + ".selectByEmail", p);
        if (exist == null) {
            dao.insert(namespace + ".insertUserSocial", p);
        } else {
            dao.update(namespace + ".updateUserSocial", p);
        }
    }

    /** 세션에 올릴 사용자 (UserVO) */
    public UserVO loadSessionUser(String email){
        Map<String,Object> p = new HashMap<>();
        p.put("email", email);

        Map<String,Object> m = dao.selectOne(namespace + ".selectSessionUser", p);
        if (m == null || m.isEmpty()) return null;

        UserVO vo = new UserVO();
        vo.setUserId(asStr(m.get("userId")));
        vo.setEmail(asStr(m.get("email")));
        vo.setPasswordHash(asStr(m.get("passwordHash")));
        vo.setUserNm(asStr(m.get("userNm")));
        vo.setNickNm(asStr(m.get("nickNm")));
        vo.setProfileImgUrl(asStr(m.get("profileImgUrl")));
        vo.setTelno(asStr(m.get("telno")));
        vo.setAuthType(asStr(m.get("authType")));
        return vo;
    }
    private static String asStr(Object o){ return (o == null ? null : String.valueOf(o)); }
}