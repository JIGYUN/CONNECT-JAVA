package www.smp.web;

import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import www.com.user.service.UserSessionManager;

import java.util.HashMap;

/**
 * @ClassName   : WebTemplateController.java
 * @Description : screenTitle 화면(Web) : ctrlDescription
 * @author      : NaDa
 * @since       : 2012. 00. 00.
 */
@Controller
@RequestMapping("/BIZ_SEG") // 예) /bbs
public class WebTemplateController {

    /** 기본 페이지 */
    @RequestMapping("/template/template")
    public String page(ModelMap model, @RequestParam HashMap<String,Object> map) throws Exception {
        if (UserSessionManager.isUserLogined()) {
            model.put("userVO", UserSessionManager.getLoginUserVO());
        }
        model.put("map", map);
        return "BIZ_PATH/template"; // 예) bbs/board/board.jsp
    }

    /** 목록 페이지 */
    @RequestMapping("/template/templateList")
    public String list(ModelMap model, @RequestParam HashMap<String,Object> map) throws Exception {
        if (UserSessionManager.isUserLogined()) {
            model.put("userVO", UserSessionManager.getLoginUserVO());
        }
        model.put("map", map);
        return "BIZ_PATH/templateList"; // 예) bbs/board/boardList.jsp
    }

    /** 등록/수정 페이지 */
    @RequestMapping("/template/templateModify")
    public String modify(ModelMap model, @RequestParam HashMap<String,Object> map) throws Exception {
        if (UserSessionManager.isUserLogined()) {
            model.put("userVO", UserSessionManager.getLoginUserVO());
        }
        model.put("map", map);
        return "BIZ_PATH/templateModify"; // 예) bbs/board/boardModify.jsp
    }
}