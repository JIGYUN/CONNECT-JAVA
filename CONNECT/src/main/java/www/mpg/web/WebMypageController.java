 package www.mpg.web;

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

import www.com.user.service.UserSessionManager;
import www.com.user.service.UserVO;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;

import java.util.HashMap;
import java.util.List;

/**
 * @ClassName   : WebMypageController.java
 * @Description : 마이페잊지 화면 호출 컨트롤러
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
@RequestMapping("/mpg")
public class WebMypageController {

    /**
     * 비밀번호 확인
     */
    @RequestMapping(value="/mypage/passwordCheck")
    public String getPasswordCheck(ModelMap model, @RequestParam HashMap<String, Object> map) throws Exception {
    	
        if (UserSessionManager.isUserLogined()) {
        	model.put("userVO", UserSessionManager.getLoginUserVO());
        }
    	
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
        return "mpg/mypage/passwordCheck";
    }
    
    /**
     * 회원수정
     */
    @RequestMapping(value="/mypage/memberModify")
    public String getMemberModify(ModelMap model, @RequestParam HashMap<String, Object> map) throws Exception {
        if (UserSessionManager.isUserLogined()) {
        	model.put("userVO", UserSessionManager.getLoginUserVO());
        }
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
        return "mpg/mypage/memberModify";
    }
    
    /**
     * 법인 회원 수정
     */
    @RequestMapping(value="/mypage/companyMemberModify")
    public String getCompanyMemberModify(ModelMap model, @RequestParam HashMap<String, Object> map) throws Exception {
        if (UserSessionManager.isUserLogined()) {
        	model.put("userVO", UserSessionManager.getLoginUserVO());
        }
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
        return "mpg/mypage/companyMemberModify";
    }
    
    
    /**
     * 담당자 승인
     */
    @RequestMapping(value="/mypage/companyMemberApprove")
    public String getCompanyMembmerApprove(ModelMap model, @RequestParam HashMap<String, Object> map) throws Exception {
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
        return "mpg/mypage/companyMemberApprove";  
    }
    
    /**
     * 법인 정보 수저'ㅇ
     */
    @RequestMapping(value="/mypage/companyModify")
    public String getCompanyModify(ModelMap model, @RequestParam HashMap<String, Object> map) throws Exception {
    	
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
        return "mpg/mypage/companyModify";
    }
    
    /**
     * 업무 담당자 지정
     */
    @RequestMapping(value="/mypage/companyMemberSpecify")
    public String getCompanyMemberSpecify(ModelMap model, @RequestParam HashMap<String, Object> map) throws Exception {
    	
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
        return "mpg/mypage/companyMemberSpecify";
    }

 
}