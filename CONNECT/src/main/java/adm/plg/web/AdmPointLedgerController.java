package adm.plg.web;

import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import www.com.user.service.UserSessionManager;

import java.util.HashMap;

/**
 * @ClassName   : WebPointLedgerController.java
 * @Description : 포인트 거래 원장 화면(Web) : 포인트 거래 원장 위한 클래스로 CRUD에 대한 컨트롤을 관리한다.
 * @author      : 정지균
 * @since       : 2025. 12. 04.
 */
@Controller
@RequestMapping("/adm/plg") // 예) /bbs
public class AdmPointLedgerController {

    /** 기본 페이지 */
    @RequestMapping("/pointLedger/pointLedger")
    public String page(ModelMap model, @RequestParam HashMap<String,Object> map) throws Exception {
        if (UserSessionManager.isUserLogined()) {
            model.put("userVO", UserSessionManager.getLoginUserVO());
        }
        model.put("map", map);
        return "adm/plg/pointLedger/pointLedger"; // 예) bbs/board/board.jsp
    }

    /** 목록 페이지 */
    @RequestMapping("/pointLedger/pointLedgerList")
    public String list(ModelMap model, @RequestParam HashMap<String,Object> map) throws Exception {
        if (UserSessionManager.isUserLogined()) {
            model.put("userVO", UserSessionManager.getLoginUserVO());
        }
        model.put("map", map);
        return "adm/plg/pointLedger/pointLedgerList"; // 예) bbs/board/boardList.jsp
    }

    /** 등록/수정 페이지 */
    @RequestMapping("/pointLedger/pointLedgerModify")
    public String modify(ModelMap model, @RequestParam HashMap<String,Object> map) throws Exception {
        if (UserSessionManager.isUserLogined()) {
            model.put("userVO", UserSessionManager.getLoginUserVO());
        }
        model.put("map", map);
        return "adm/plg/pointLedger/pointLedgerModify"; // 예) bbs/board/boardModify.jsp
    }
}
