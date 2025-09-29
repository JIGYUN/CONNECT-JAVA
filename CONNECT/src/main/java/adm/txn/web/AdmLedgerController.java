package adm.txn.web;

import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import www.com.user.service.UserSessionManager;

import java.util.HashMap;

/**
 * @ClassName   : WebLedgerController.java
 * @Description : 가게부 화면(Web) : 가게부 위한 클래스로 CRUD에 대한 컨트롤을 관리한다.
 * @author      : 정지균
 * @since       : 2025. 09. 29.
 */
@Controller
@RequestMapping("/adm/txn") // 예) /bbs
public class AdmLedgerController {

    /** 기본 페이지 */
    @RequestMapping("/ledger/ledger")
    public String page(ModelMap model, @RequestParam HashMap<String,Object> map) throws Exception {
        if (UserSessionManager.isUserLogined()) {
            model.put("userVO", UserSessionManager.getLoginUserVO());
        }
        model.put("map", map);
        return "adm/txn/ledger/ledger"; // 예) bbs/board/board.jsp
    }

    /** 목록 페이지 */
    @RequestMapping("/ledger/ledgerList")
    public String list(ModelMap model, @RequestParam HashMap<String,Object> map) throws Exception {
        if (UserSessionManager.isUserLogined()) {
            model.put("userVO", UserSessionManager.getLoginUserVO());
        }
        model.put("map", map);
        return "adm/txn/ledger/ledgerList"; // 예) bbs/board/boardList.jsp
    }

    /** 등록/수정 페이지 */
    @RequestMapping("/ledger/ledgerModify")
    public String modify(ModelMap model, @RequestParam HashMap<String,Object> map) throws Exception {
        if (UserSessionManager.isUserLogined()) {
            model.put("userVO", UserSessionManager.getLoginUserVO());
        }
        model.put("map", map);
        return "adm/txn/ledger/ledgerModify"; // 예) bbs/board/boardModify.jsp
    }
}
