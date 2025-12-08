// filepath: src/main/java/www/api/mba/auth/web/AuthController.java
package www.api.mba.auth.web;

import java.util.HashMap;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;

import www.api.mba.auth.service.AuthService;
import www.com.user.service.UserVO;

/**
 * 인증/회원 관련 API 컨트롤러
 */
@Controller
public class AuthController {

    private Logger logger = LoggerFactory.getLogger(this.getClass());

    @Autowired
    private AuthService authService;

    /** 회원가입 */
    @RequestMapping("/api/auth/insertJoin")
    @ResponseBody
    public Map<String, Object> insertJoin(@RequestBody HashMap<String, Object> map) throws Exception {
        Map<String, Object> resultMap = new HashMap<>();
        authService.insertJoin(map);
        resultMap.put("msg", "성공적으로 등록되었습니다.");
        return resultMap;
    }

    /** 일반 로그인 */
    @RequestMapping("/api/auth/selectLogin")
    @ResponseBody
    public Map<String, Object> selectLogin(@RequestBody HashMap<String, Object> map) throws Exception {
        Map<String, Object> resultMap = new HashMap<>();
        resultMap.put("msg", "성공");
        resultMap.put("result", authService.selectLogin(map));
        return resultMap;
    }

    /** 아이디/비밀번호 찾기 */
    @RequestMapping("/api/auth/selectIdPwFind")
    @ResponseBody
    public Map<String, Object> selectIdPwFind(@RequestBody HashMap<String, Object> map) throws Exception {
        Map<String, Object> resultMap = new HashMap<>();
        resultMap.put("msg", "성공");
        resultMap.put("result", authService.selectIdPwFind(map));
        return resultMap;
    }

    /** 아이디 중복 체크 */
    @RequestMapping("/api/auth/duplicateId")
    @ResponseBody
    public Map<String, Object> duplicateId(@RequestBody HashMap<String, Object> map) throws Exception {
        Map<String, Object> resultMap = new HashMap<>();
        resultMap.put("msg", "성공");
        resultMap.put("result", authService.duplicateId(map));
        return resultMap;
    }

    /** 아이디 찾기 */
    @RequestMapping("/api/auth/findId")
    @ResponseBody
    public Map<String, Object> findId(@RequestBody HashMap<String, Object> map) throws Exception {
        Map<String, Object> resultMap = new HashMap<>();
        resultMap.put("msg", "성공");
        resultMap.put("result", authService.findId(map));
        return resultMap;
    }

    /** 비밀번호 변경 */
    @RequestMapping("/api/auth/changePassword")
    @ResponseBody
    public Map<String, Object> changePassword(@RequestBody HashMap<String, Object> map) throws Exception {
        Map<String, Object> resultMap = new HashMap<>();
        authService.changePassword(map);
        resultMap.put("msg", "성공적으로 변경되었습니다.");
        return resultMap;
    }

    /**
     * 현재 로그인 유저 조회 (기존 /api/me)
     *  - React/세션 공통으로 사용 가능
     */
    @RequestMapping("/api/me")
    @ResponseBody
    public Map<String, Object> me() {
        System.out.println("/api/me 시작");
        Map<String, Object> resp = new HashMap<>();

        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth == null || !auth.isAuthenticated()) {
            resp.put("ok", false);
            resp.put("error", "UNAUTHENTICATED");
            return resp;
        }

        Object principal = auth.getPrincipal();
        if (!(principal instanceof UserVO)) {
            resp.put("ok", false);
            resp.put("error", "INVALID_PRINCIPAL");
            return resp;
        }

        UserVO u = (UserVO) principal;
        Map<String, Object> result = new HashMap<>();
        System.out.println("userId = " + u.getUserId());

        result.put("userId", u.getUserId());
        result.put("email", u.getEmail());
        result.put("userNm", u.getUserNm());
        result.put("nickNm", u.getNickNm());
        result.put("profileImgUrl", u.getProfileImgUrl());
        result.put("authType", u.getAuthType());

        resp.put("ok", true);
        resp.put("result", result);
        return resp;
    }

    /**
     * 구글 로그인 완료 (React 전용)
     *  - 클라이언트에서 loginToken 을 보내면
     *  - 토큰 검증 + 세션 생성 후 User 정보 반환
     */
    @RequestMapping("/api/auth/google/complete")
    @ResponseBody
    public Map<String, Object> googleComplete(
            @RequestBody Map<String, Object> body,
            HttpServletRequest req,
            HttpServletResponse res
    ) {
        Map<String, Object> resp = new HashMap<>();

        Object t = body.get("token");
        String token = (t == null) ? null : String.valueOf(t);

        if (token == null || token.trim().isEmpty()) {
            resp.put("ok", false);
            resp.put("error", "TOKEN_REQUIRED");
            return resp;
        }

        UserVO u = authService.consumeLoginTokenAndCreateSession(token.trim(), req, res);
        if (u == null) {
            resp.put("ok", false);
            resp.put("error", "TOKEN_INVALID_OR_USER_NOT_FOUND");
            return resp;
        }

        Map<String, Object> result = new HashMap<>();
        result.put("userId", u.getUserId());
        result.put("email", u.getEmail());
        result.put("userNm", u.getUserNm());

        resp.put("ok", true);
        resp.put("result", result);

        return resp;
    }
}
