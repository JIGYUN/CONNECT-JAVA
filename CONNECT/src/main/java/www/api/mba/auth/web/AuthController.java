package www.api.mba.auth.web;

import java.util.HashMap;
import java.util.Map;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;


import www.api.mba.auth.service.AuthService;
 
/**
 * 조직관리1 정보 관리 Request를 Servlet으로 Mapping하고 ViewPage로 결과값을 리턴해주는 컨트롤 클래스
 *
 * @author 정지균
 * @since 2024.01.12
 */
@Controller
public class AuthController {

    private Logger logger = LoggerFactory.getLogger(this.getClass());

    @Autowired
    private AuthService authService;

    /**
     * 회원가입
     *
     * @author 정지균
     * @since 2024.01.12
     * @param MciRequest 저장할 데이터
     * @param Model 저장 결과
     * @return
     * @throws Exception
     */
    @RequestMapping("/api/auth/insertJoin")
    @ResponseBody
    public Map<String, Object> insertJoin(@RequestBody HashMap<String, Object> map) throws Exception
    {
        Map<String, Object> resultMap = new HashMap<>();
        authService.insertJoin(map);
        
        resultMap.put("msg", "성공적으로 등록되었습니다.");
        return resultMap;
    }
    
    /**
     * 로그인
     *
     * @author 정지균
     * @since 2024.01.12
     * @param MciRequest 조회 조건
     * @param Model 조회 결과
     * @return
     * @throws Exception
     */
    @RequestMapping("/api/auth/selectLogin")
    @ResponseBody
    public Map<String, Object> selectLogin(@RequestBody HashMap<String, Object> map) throws Exception
    {
        Map<String, Object> resultMap = new HashMap<>();
        resultMap.put("msg", "성공");
        resultMap.put("result", authService.selectLogin(map));
        return resultMap;
    }

    /**
     * 아이디비밀번호찾기
     *
     * @author 정지균
     * @since 2024.01.12
     * @param MciRequest 조회 조건
     * @param Model 조회 결과
     * @return
     * @throws Exception
     */
    @RequestMapping("/api/auth/selectIdPwFind")
    @ResponseBody
    public Map<String, Object> selectIdPwFind(@RequestBody HashMap<String, Object> map) throws Exception
    {
        Map<String, Object> resultMap = new HashMap<>();
        resultMap.put("msg", "성공");
        resultMap.put("result", authService.selectIdPwFind(map));
        return resultMap;
    }
    

    /**
     * 아이디 중복체크
     *
     * @author 정지균
     * @since 2024.01.12
     * @param MciRequest 조회 조건
     * @param Model 조회 결과
     * @return
     * @throws Exception
     */
    @RequestMapping("/api/auth/duplicateId")
    @ResponseBody
    public Map<String, Object> duplicateId(@RequestBody HashMap<String, Object>  map) throws Exception
    {
        Map<String, Object> resultMap = new HashMap<>();
        resultMap.put("msg", "성공");
        resultMap.put("result", authService.duplicateId(map));
        return resultMap;
    }
    
    /**
     * 아이디 중복체크
     *
     * @author 정지균
     * @since 2024.01.12
     * @param MciRequest 조회 조건
     * @param Model 조회 결과
     * @return
     * @throws Exception
     */
    @RequestMapping("/api/auth/findId")
    @ResponseBody
    public Map<String, Object> findId(@RequestBody HashMap<String, Object>  map) throws Exception
    {
        Map<String, Object> resultMap = new HashMap<>();
        resultMap.put("msg", "성공");
        resultMap.put("result", authService.findId(map));
        return resultMap;
    }
    
    /**
     * 비밀번호 변경
     *
     * @author 정지균
     * @since 2024.01.12
     * @param MciRequest 조회 조건
     * @param Model 조회 결과
     * @return
     * @throws Exception
     */
    @RequestMapping("/api/auth/changePassword")
    @ResponseBody 
    public Map<String, Object> changePassword(@RequestBody HashMap<String, Object>  map) throws Exception
    {
        Map<String, Object> resultMap = new HashMap<>();
        authService.changePassword(map);
        
        resultMap.put("msg", "성공적으로 변경되었습니다.");
        return resultMap;
    }
    
}