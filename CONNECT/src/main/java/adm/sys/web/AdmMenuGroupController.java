package adm.sys.web;

import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import www.com.user.service.UserSessionManager;

import java.util.HashMap;

/**
 * @ClassName   : WebMenuGroupController.java
 * @Description : 게시판 정의 화면(Web) : 게시판 정의 위한 클래스로 CRUD에 대한 컨트롤을 관리한다.
 * @author      : 정지균
 * @since       : 2025. 09. 10.
 */
@Controller
@RequestMapping("/adm/sys") // 예) /bbs
public class AdmMenuGroupController {

    /** 기본 페이지 */
    @RequestMapping("/menuGroup/menuGroup")
    public String page(ModelMap model, @RequestParam HashMap<String,Object> map) throws Exception {
        if (UserSessionManager.isUserLogined()) {
            model.put("userVO", UserSessionManager.getLoginUserVO());
        }
        model.put("map", map);
        return "adm/sys/menuGroup/menuGroup"; // 예) bbs/board/board.jsp
    }

    /** 목록 페이지 */
    @RequestMapping("/menuGroup/menuGroupList")
    public String list(ModelMap model, @RequestParam HashMap<String,Object> map) throws Exception {
        if (UserSessionManager.isUserLogined()) {
            model.put("userVO", UserSessionManager.getLoginUserVO());
        }
        model.put("map", map);
        return "adm/sys/menuGroup/menuGroupList"; // 예) bbs/board/boardList.jsp
    }

    /** 등록/수정 페이지 */
    @RequestMapping("/menuGroup/menuGroupModify")
    public String modify(ModelMap model, @RequestParam HashMap<String,Object> map) throws Exception {
        if (UserSessionManager.isUserLogined()) {
            model.put("userVO", UserSessionManager.getLoginUserVO());
        }
        model.put("map", map);
        return "adm/sys/menuGroup/menuGroupModify"; // 예) bbs/board/boardModify.jsp
    }
}
