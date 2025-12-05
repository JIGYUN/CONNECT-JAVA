package adm.ord.web;

import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import www.com.user.service.UserSessionManager;

import java.util.HashMap;

/**
 * @ClassName   : WebOrderItemController.java
 * @Description : 주문 화면(Web) : 주문 위한 클래스로 CRUD에 대한 컨트롤을 관리한다.
 * @author      : 정지균
 * @since       : 2025. 12. 04.
 */
@Controller
@RequestMapping("/adm/ord") // 예) /bbs
public class AdmOrderItemController {

    /** 기본 페이지 */
    @RequestMapping("/orderItem/orderItem")
    public String page(ModelMap model, @RequestParam HashMap<String,Object> map) throws Exception {
        if (UserSessionManager.isUserLogined()) {
            model.put("userVO", UserSessionManager.getLoginUserVO());
        }
        model.put("map", map);
        return "adm/ord/orderItem/orderItem"; // 예) bbs/board/board.jsp
    }

    /** 목록 페이지 */
    @RequestMapping("/orderItem/orderItemList")
    public String list(ModelMap model, @RequestParam HashMap<String,Object> map) throws Exception {
        if (UserSessionManager.isUserLogined()) {
            model.put("userVO", UserSessionManager.getLoginUserVO());
        }
        model.put("map", map);
        return "adm/ord/orderItem/orderItemList"; // 예) bbs/board/boardList.jsp
    }

    /** 등록/수정 페이지 */
    @RequestMapping("/orderItem/orderItemModify")
    public String modify(ModelMap model, @RequestParam HashMap<String,Object> map) throws Exception {
        if (UserSessionManager.isUserLogined()) {
            model.put("userVO", UserSessionManager.getLoginUserVO());
        }
        model.put("map", map);
        return "adm/ord/orderItem/orderItemModify"; // 예) bbs/board/boardModify.jsp
    }
}
