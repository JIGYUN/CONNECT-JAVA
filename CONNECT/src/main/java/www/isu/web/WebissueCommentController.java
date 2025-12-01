package www.isu.web;

import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import www.com.user.service.UserSessionManager;

import java.util.HashMap;

/**
 * @ClassName   : WebissueCommentController.java
 * @Description : 이슈 화면(Web) : 이슈 위한 클래스로 CRUD에 대한 컨트롤을 관리한다.
 * @author      : 정지균
 * @since       : 2025. 11. 18.
 */
@Controller
@RequestMapping("/isu") // 예) /bbs
public class WebissueCommentController {

    /** 기본 페이지 */
    @RequestMapping("/issueComment/issueComment")
    public String page(ModelMap model, @RequestParam HashMap<String,Object> map) throws Exception {
        if (UserSessionManager.isUserLogined()) {
            model.put("userVO", UserSessionManager.getLoginUserVO());
        }
        model.put("map", map);
        return "isu/issueComment/issueComment"; // 예) bbs/board/board.jsp
    }

    /** 목록 페이지 */
    @RequestMapping("/issueComment/issueCommentList")
    public String list(ModelMap model, @RequestParam HashMap<String,Object> map) throws Exception {
        if (UserSessionManager.isUserLogined()) {
            model.put("userVO", UserSessionManager.getLoginUserVO());
        }
        model.put("map", map);
        return "isu/issueComment/issueCommentList"; // 예) bbs/board/boardList.jsp
    }

    /** 등록/수정 페이지 */
    @RequestMapping("/issueComment/issueCommentModify")
    public String modify(ModelMap model, @RequestParam HashMap<String,Object> map) throws Exception {
        if (UserSessionManager.isUserLogined()) {
            model.put("userVO", UserSessionManager.getLoginUserVO());
        }
        model.put("map", map);
        return "isu/issueComment/issueCommentModify"; // 예) bbs/board/boardModify.jsp
    }
}
