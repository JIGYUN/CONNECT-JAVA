package www.sys.web;

import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import www.com.user.service.UserSessionManager;

import java.util.HashMap;

/**
 * @ClassName   : WebCmmnCodeClController.java
 * @Description : 게시판 정의 화면(Web) : 게시판 정의 위한 클래스로 CRUD에 대한 컨트롤을 관리한다.
 * @author      : 정지균
 * @since       : 2025. 09. 09.
 */
@Controller
@RequestMapping("/sys") // 예) /bbs
public class WebCmmnCodeClController {

    /** 기본 페이지 */
    @RequestMapping("/cmmnCodeCl/cmmnCodeCl")
    public String page(ModelMap model, @RequestParam HashMap<String,Object> map) throws Exception {
        if (UserSessionManager.isUserLogined()) {
            model.put("userVO", UserSessionManager.getLoginUserVO());
        }
        model.put("map", map);
        return "sys/cmmnCodeCl/cmmnCodeCl"; // 예) bbs/board/board.jsp
    }

    /** 목록 페이지 */
    @RequestMapping("/cmmnCodeCl/cmmnCodeClList")
    public String list(ModelMap model, @RequestParam HashMap<String,Object> map) throws Exception {
        if (UserSessionManager.isUserLogined()) {
            model.put("userVO", UserSessionManager.getLoginUserVO());
        }
        model.put("map", map);
        return "sys/cmmnCodeCl/cmmnCodeClList"; // 예) bbs/board/boardList.jsp
    }

    /** 등록/수정 페이지 */
    @RequestMapping("/cmmnCodeCl/cmmnCodeClModify")
    public String modify(ModelMap model, @RequestParam HashMap<String,Object> map) throws Exception {
        if (UserSessionManager.isUserLogined()) {
            model.put("userVO", UserSessionManager.getLoginUserVO());
        }
        model.put("map", map);
        return "sys/cmmnCodeCl/cmmnCodeClModify"; // 예) bbs/board/boardModify.jsp
    }
}
