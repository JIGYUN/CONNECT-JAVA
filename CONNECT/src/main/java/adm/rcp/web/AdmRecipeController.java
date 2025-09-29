 package adm.rcp.web;

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
@RequestMapping("/adm/rcp")
public class AdmRecipeController {

    /**
     * 레시피 목록
     */
    @RequestMapping(value="/recipe/recipeList")
    public String getRecipeList(ModelMap model, @RequestParam HashMap<String, Object> map) throws Exception {
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
        return "adm/rcp/recipe/recipeList";
    }
    
    /**
     * 레시피 상세
     */
    @RequestMapping(value="/recipe/recipeModify")
    public String getRecipeModify(ModelMap model, @RequestParam HashMap<String, Object> map) throws Exception {
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
        return "adm/rcp/recipe/recipeModify";
    }
 
}