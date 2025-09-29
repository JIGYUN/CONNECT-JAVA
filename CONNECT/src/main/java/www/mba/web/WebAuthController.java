 package www.mba.web;

import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.support.SessionStatus;
import org.springframework.web.context.request.RequestAttributes;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;
import org.springframework.web.multipart.MultipartHttpServletRequest;
import org.springframework.web.servlet.view.RedirectView;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;

import java.util.HashMap;
import java.util.List;

/**
 * @ClassName   : WebAuthController.java
 * @Description : 인증관련 화면 홑출 컨트롤러
 * @author 정지균
 * @since 2024. 01. 12.
 * @version 1.0
 * @see
 * @Modification Information
 * <pre>
 *     since          author              description
 *  ===========    =============    ===========================
 *  2024. 01. 12.     정지균                   최초 생성
 * </pre>
 */
@Controller
@RequestMapping("/mba")
public class WebAuthController {

    /**
     * 로그인 페이지 호출
     */
    @RequestMapping(value="/auth/login")
    public String login(ModelMap model, @RequestParam HashMap<String, Object> map) throws Exception {
    	System.out.println("failYn = " + String.valueOf(map.get("failYn")));
    	/*******************************************************
        //기본값 처리  
        ******************************************************/

    	/*******************************************************
        //Service호출 
        ******************************************************/

        /*******************************************************
        //리턴값 처리
        ******************************************************/	

    	model.put("map", map);
        return "mba/auth/login";
    }
    
    /**
     * 회원가입 페이지 호출
     */
    @RequestMapping(value="/auth/join")
    public String getJoin(ModelMap model, @RequestParam HashMap<String, Object> map) throws Exception {
    	
    	/*******************************************************
        //기본값 처리 
        ******************************************************/

    	/*******************************************************
        //Service호출 
        ******************************************************/

        /*******************************************************
        //리턴값 처리
        ******************************************************/	

    	model.put("map", map);
        return "mba/auth/join";
    }
    
    
    /**
     * 회원가입 페이지 호출
     */
    @RequestMapping(value="/auth/jusoPopup")
    public String getJuso(ModelMap model, @RequestParam HashMap<String, Object> map) throws Exception {
    	
    	/*******************************************************
        //기본값 처리 
        ******************************************************/

    	/*******************************************************
        //Service호출 
        ******************************************************/

        /*******************************************************
        //리턴값 처리
        ******************************************************/	

    	model.put("map", map);
        return "juso/jusoPopup";
    }
    
    /**
     * 회원가입 페이지 호출
     */
    @RequestMapping(value="/auth/personalJoin")
    public String getPersonalJoin(ModelMap model, @RequestParam HashMap<String, Object> map) throws Exception {
    	
    	/*******************************************************
        //기본값 처리 
        ******************************************************/

    	/*******************************************************
        //Service호출 
        ******************************************************/

        /*******************************************************
        //리턴값 처리
        ******************************************************/	

    	model.put("map", map);
        return "mba/auth/personalJoin";
    }
    
    /**
     * 기업가입 페이지 호출
     */
    @RequestMapping(value="/auth/companyJoin")
    public String getCompanyJoin(ModelMap model, @RequestParam HashMap<String, Object> map) throws Exception {
    	
    	/*******************************************************
        //기본값 처리 
        ******************************************************/

    	/*******************************************************
        //Service호출 
        ******************************************************/

        /*******************************************************
        //리턴값 처리
        ******************************************************/	

    	model.put("map", map);
        return "mba/auth/companyJoin";
    }
    
    /**
     * 서류기업가입 페이지 호출
     */
    @RequestMapping(value="/auth/companyDocJoin")
    public String getCompanyDocJoin(ModelMap model, @RequestParam HashMap<String, Object> map) throws Exception {
    	
    	/*******************************************************
        //기본값 처리 
        ******************************************************/

    	/*******************************************************
        //Service호출 
        ******************************************************/

        /*******************************************************
        //리턴값 처리
        ******************************************************/	

    	model.put("map", map);
        return "mba/auth/companyDocJoin";
    }
    
    /**
     * 담당자가입 페이지 호출
     */
    @RequestMapping(value="/auth/companyManagerJoin")
    public String getCompanyManagerJoin(ModelMap model, @RequestParam HashMap<String, Object> map) throws Exception {
    	
    	/*******************************************************
        //기본값 처리 
        ******************************************************/

    	/*******************************************************
        //Service호출 
        ******************************************************/

        /*******************************************************
        //리턴값 처리
        ******************************************************/	

    	model.put("map", map);
        return "mba/auth/companyManagerJoin";
    }
    
    
    /**
     * 아이디/비밀번호 찾긱 페이지 호출
     */
    @RequestMapping(value="/auth/idPwFind")
    public String getIdPwFind(ModelMap model, @RequestParam HashMap<String, Object> map) throws Exception {
    	
    	/*******************************************************
        //기본값 처리 
        ******************************************************/

    	/*******************************************************
        //Service호출 
        ******************************************************/

        /*******************************************************
        //리턴값 처리
        ******************************************************/	

    	model.put("map", map);
        return "mba/auth/idPwFind";
    }
    
    /**
     * 아이디 찾긱 페이지 호출
     */
    @RequestMapping(value="/auth/idFind")
    public String getIdFind(ModelMap model, @RequestParam HashMap<String, Object> map) throws Exception {
    	System.out.println("cryalTelno = " + map.get("cryalTelno"));
    	System.out.println("mberNm = " + map.get("mberNm"));
    	/*******************************************************  
        //기본값 처리 
        ******************************************************/

    	/*******************************************************
        //Service호출 
        ******************************************************/

        /*******************************************************
        //리턴값 처리
        ******************************************************/
    	model.put("map", map);
        return "mba/auth/idFind";  
    }
    
    /**
     * 비밀번호 찾긱 페이지 호출
     */
    @RequestMapping(value="/auth/pwFind")
    public String getPwFind(ModelMap model, @RequestParam HashMap<String, Object> map) throws Exception {
    	
    	/*******************************************************
        //기본값 처리 
        ******************************************************/

    	/*******************************************************
        //Service호출 
        ******************************************************/

        /*******************************************************
        //리턴값 처리
        ******************************************************/	

    	model.put("map", map);
        return "mba/auth/pwFind";
    }
    
    /**
     * 아이디 찾긱 페이지 호출
     */
    @RequestMapping(value="/auth/idFindProc")
    public String getIdFindProc(ModelMap model, @RequestParam HashMap<String, Object> map) throws Exception {
    	System.out.println("cryalTelno = " + map.get("cryalTelno"));
    	System.out.println("mberNm = " + map.get("mberNm"));
    	/*******************************************************
        //기본값 처리 
        ******************************************************/

    	/*******************************************************
        //Service호출 
        ******************************************************/

        /*******************************************************
        //리턴값 처리
        ******************************************************/
    	model.put("map", map);
        return "mba/auth/idFindProc";  
    }
    
    /**
     * 비밀번호 찾긱 페이지 호출
     */
    @RequestMapping(value="/auth/pwFindProc")
    public String getPwFindProc(ModelMap model, @RequestParam HashMap<String, Object> map) throws Exception {
    	
    	/*******************************************************
        //기본값 처리 
        ******************************************************/

    	/*******************************************************
        //Service호출 
        ******************************************************/

        /*******************************************************
        //리턴값 처리
        ******************************************************/	

    	model.put("map", map);
        return "mba/auth/pwFindProc"; 
    }
    
    /**
     * 로그인실패
     */
    @RequestMapping(value="/auth/loginFail")
    public String getLoginFail(ModelMap model, @RequestParam HashMap<String, Object> map) throws Exception {
    	
    	/*******************************************************
        //기본값 처리 
        ******************************************************/

    	/*******************************************************
        //Service호출 
        ******************************************************/

        /*******************************************************
        //리턴값 처리
        ******************************************************/	

    	model.put("map", map);
        return "mba/auth/loginFail";
    }

 
}