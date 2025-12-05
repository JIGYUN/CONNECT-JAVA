package www.crt.web;

import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import www.com.user.service.UserSessionManager;

import java.util.HashMap;

/**
 * @ClassName   : WebCartItemController.java
 * @Description : 장바구니 상세 화면(Web) : 장바구니 상세 위한 클래스로 CRUD에 대한 컨트롤을 관리한다.
 * @author      : 정지균
 * @since       : 2025. 12. 04.
 */
@Controller
@RequestMapping("/crt") // 예) /bbs
public class WebCartItemController {

    /** 기본 페이지 */
    @RequestMapping("/cartItem/cartItem")
    public String page(ModelMap model, @RequestParam HashMap<String,Object> map) throws Exception {
        if (UserSessionManager.isUserLogined()) {
            model.put("userVO", UserSessionManager.getLoginUserVO());
        }
        model.put("map", map);
        return "crt/cartItem/cartItem"; // 예) bbs/board/board.jsp
    }

    /** 목록 페이지 */
    @RequestMapping("/cartItem/cartItemList")
    public String list(ModelMap model, @RequestParam HashMap<String,Object> map) throws Exception {
        if (UserSessionManager.isUserLogined()) {
            model.put("userVO", UserSessionManager.getLoginUserVO());
        }
        model.put("map", map);
        return "crt/cartItem/cartItemList"; // 예) bbs/board/boardList.jsp
    }

    /** 등록/수정 페이지 */
    @RequestMapping("/cartItem/cartItemModify")
    public String modify(ModelMap model, @RequestParam HashMap<String,Object> map) throws Exception {
        if (UserSessionManager.isUserLogined()) {
            model.put("userVO", UserSessionManager.getLoginUserVO());
        }
        model.put("map", map);
        return "crt/cartItem/cartItemModify"; // 예) bbs/board/boardModify.jsp
    }
}
