package www.cht.web;

import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import www.com.user.service.UserSessionManager;

import java.util.HashMap;

/**
 * @ClassName   : WebChatRoomController.java
 * @Description : 예약 화면(Web) : 예약 위한 클래스로 CRUD에 대한 컨트롤을 관리한다.
 * @author      : 정지균
 * @since       : 2025. 11. 14.
 */
@Controller
@RequestMapping("/cht") // 예) /bbs
public class WebChatRoomController {

    /** 기본 페이지 */
    @RequestMapping("/chatRoom/chatRoom")
    public String page(ModelMap model, @RequestParam HashMap<String,Object> map) throws Exception {
        if (UserSessionManager.isUserLogined()) {
            model.put("userVO", UserSessionManager.getLoginUserVO());
        }
        model.put("map", map);
        return "cht/chat/chatRoom"; // 예) bbs/board/board.jsp
    }

    /** 목록 페이지 */
    @RequestMapping("/chatRoom/chatRoomList")
    public String list(ModelMap model, @RequestParam HashMap<String,Object> map) throws Exception {
        if (UserSessionManager.isUserLogined()) {
            model.put("userVO", UserSessionManager.getLoginUserVO());
        }
        model.put("map", map);
        return "cht/chat/chatRoomList"; // 예) bbs/board/boardList.jsp
    }

    /** 등록/수정 페이지 */
    @RequestMapping("/chatRoom/chatRoomModify")
    public String modify(ModelMap model, @RequestParam HashMap<String,Object> map) throws Exception {
        if (UserSessionManager.isUserLogined()) {
            model.put("userVO", UserSessionManager.getLoginUserVO());
        }
        model.put("map", map);
        return "cht/chat/chatRoomModify"; // 예) bbs/board/boardModify.jsp
    }
}
