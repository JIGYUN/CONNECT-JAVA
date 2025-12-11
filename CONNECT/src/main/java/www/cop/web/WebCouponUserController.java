package www.cop.web;

import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import www.com.user.service.UserSessionManager;

import java.util.HashMap;

/**
 * @ClassName   : WebCouponUserController.java
 * @Description : 쿠폰 화면(Web) : 쿠폰 위한 클래스로 CRUD에 대한 컨트롤을 관리한다.
 * @author      : 정지균
 * @since       : 2025. 12. 09.
 */
@Controller
@RequestMapping("/cop") // 예) /bbs
public class WebCouponUserController {

    /** 기본 페이지 */
    @RequestMapping("/couponUser/couponUser")
    public String page(ModelMap model, @RequestParam HashMap<String,Object> map) throws Exception {
        if (UserSessionManager.isUserLogined()) {
            model.put("userVO", UserSessionManager.getLoginUserVO());
        }
        model.put("map", map);
        return "cop/couponUser/couponUser"; // 예) bbs/board/board.jsp
    }

    /** 목록 페이지 */
    @RequestMapping("/couponUser/couponUserList")
    public String list(ModelMap model, @RequestParam HashMap<String,Object> map) throws Exception {
        if (UserSessionManager.isUserLogined()) {
            model.put("userVO", UserSessionManager.getLoginUserVO());
        }
        model.put("map", map);
        return "cop/couponUser/couponUserList"; // 예) bbs/board/boardList.jsp
    }

    /** 등록/수정 페이지 */
    @RequestMapping("/couponUser/couponUserModify")
    public String modify(ModelMap model, @RequestParam HashMap<String,Object> map) throws Exception {
        if (UserSessionManager.isUserLogined()) {
            model.put("userVO", UserSessionManager.getLoginUserVO());
        }
        model.put("map", map);
        return "cop/couponUser/couponUserModify"; // 예) bbs/board/boardModify.jsp
    }
}
