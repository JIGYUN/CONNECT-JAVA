 package www.mai.web;

import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.RequestMapping;
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
 * @ClassName   : WebMemberController.java
 * @Description : 로그인관련 화면 홑출 컨트롤러
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
@RequestMapping("/mai")
public class WebMainController {

    /**
     * 메인 페이지 호출
     */
    @RequestMapping(value="/main/main")
    public String main(ModelMap model) throws Exception {
        return "mai/main/main";
    }
    
    /**
     * 메인 페이지 호출
     */
    @RequestMapping(value="/main/culture")
    public String culture(ModelMap model) throws Exception {
        return "mai/main/culture"; 
    }
    
    @RequestMapping("/main/file")
    public String file(ModelMap model) throws Exception {
        return "mai/main/file"; // 뷰: /WEB-INF/views/adm/mai/main/main.jsp (prefix/suffix에 맞춰)
    }
    
    @RequestMapping("/main/mail")
    public String mail(ModelMap model) throws Exception {
        return "mai/main/mail"; // 뷰: /WEB-INF/views/adm/mai/main/main.jsp (prefix/suffix에 맞춰)  
    }
    
    @RequestMapping(value="/privacy")
    public String privacy(ModelMap model) throws Exception {
        return "mai/main/privacy";
    }

}