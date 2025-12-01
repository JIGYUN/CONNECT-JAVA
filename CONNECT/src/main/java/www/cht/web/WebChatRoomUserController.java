package www.cht.web;

import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import www.com.user.service.UserSessionManager;

import java.util.HashMap;

/**
 * @ClassName   : WebChatRoomUserController.java
 * @Description : 채팅방유저 화면(Web) : 채팅방유저 위한 클래스로 CRUD에 대한 컨트롤을 관리한다.
 * @author      : 정지균
 * @since       : 2025. 11. 19.
 */
@Controller
@RequestMapping("/cht") // 예) /bbs
public class WebChatRoomUserController {

    /** 기본 페이지 */
    @RequestMapping("/chatRoomUser/chatRoomUser")
    public String page(ModelMap model, @RequestParam HashMap<String,Object> map) throws Exception {
        if (UserSessionManager.isUserLogined()) {
            model.put("userVO", UserSessionManager.getLoginUserVO());
        }
        model.put("map", map);
        return "cht/chatRoomUser/chatRoomUser"; // 예) bbs/board/board.jsp
    }

    /** 목록 페이지 */
    @RequestMapping("/chatRoomUser/chatRoomUserList")
    public String list(ModelMap model, @RequestParam HashMap<String,Object> map) throws Exception {
        if (UserSessionManager.isUserLogined()) {
            model.put("userVO", UserSessionManager.getLoginUserVO());
        }
        model.put("map", map);
        return "cht/chatRoomUser/chatRoomUserList"; // 예) bbs/board/boardList.jsp
    }

    /** 등록/수정 페이지 */
    @RequestMapping("/chatRoomUser/chatRoomUserModify")
    public String modify(ModelMap model, @RequestParam HashMap<String,Object> map) throws Exception {
        if (UserSessionManager.isUserLogined()) {
            model.put("userVO", UserSessionManager.getLoginUserVO());
        }
        model.put("map", map);
        return "cht/chatRoomUser/chatRoomUserModify"; // 예) bbs/board/boardModify.jsp
    }
}
