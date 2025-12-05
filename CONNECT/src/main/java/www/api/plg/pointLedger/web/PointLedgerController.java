package www.api.plg.pointLedger.web;

import java.math.BigDecimal;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import www.api.plg.pointLedger.service.PointLedgerService;
import www.com.user.service.UserSessionManager;

@Controller
public class PointLedgerController {

    @Autowired
    private PointLedgerService pointLedgerService;

    // 로그인 유저 PK 추출 (CartController랑 동일 패턴)
    private Long getLoginUserId() {
        if (!UserSessionManager.isUserLogined()) {
            return null;
        }
        return Long.valueOf(UserSessionManager.getLoginUserVO().getUserId());
    }

    // ===========================
    //  기존 Javagen CRUD API
    // ===========================

    /**
     * 목록 조회 (관리/테스트용)
     */
    @RequestMapping("/api/plg/pointLedger/selectPointLedgerList")
    @ResponseBody
    public Map<String, Object> selectPointLedgerList(@RequestBody HashMap<String, Object> map) throws Exception {
        Map<String, Object> resultMap = new HashMap<>();
        List<Map<String, Object>> result = pointLedgerService.selectPointLedgerList(map);
        resultMap.put("msg", "성공");
        resultMap.put("result", result);
        return resultMap;
    }

    /**
     * 단건 조회 (관리/테스트용)
     */
    @RequestMapping("/api/plg/pointLedger/selectPointLedgerDetail")
    @ResponseBody
    public Map<String, Object> selectPointLedgerDetail(@RequestBody HashMap<String, Object> map) throws Exception {
        Map<String, Object> resultMap = new HashMap<>();
        Map<String, Object> result = pointLedgerService.selectPointLedgerDetail(map);
        resultMap.put("msg", "성공");
        resultMap.put("result", result);
        return resultMap;
    }

    /**
     * 직접 등록 (관리용)
     */
    @RequestMapping("/api/plg/pointLedger/insertPointLedger")
    @ResponseBody
    public Map<String, Object> insertPointLedger(@RequestBody HashMap<String, Object> map) throws Exception {
        if (UserSessionManager.isUserLogined()) {
            map.put("createdBy", UserSessionManager.getLoginUserVO().getUserId());
            map.put("updatedBy", UserSessionManager.getLoginUserVO().getUserId());
        }
        Map<String, Object> resultMap = new HashMap<>();
        pointLedgerService.insertPointLedger(map);
        resultMap.put("msg", "등록 성공");
        return resultMap;
    }

    /**
     * 수정 (관리용)
     */
    @RequestMapping("/api/plg/pointLedger/updatePointLedger")
    @ResponseBody
    public Map<String, Object> updatePointLedger(@RequestBody HashMap<String, Object> map) throws Exception {
        if (UserSessionManager.isUserLogined()) {
            map.put("updatedBy", UserSessionManager.getLoginUserVO().getUserId());
        }
        Map<String, Object> resultMap = new HashMap<>();
        pointLedgerService.updatePointLedger(map);
        resultMap.put("msg", "수정 성공");
        return resultMap;
    }

    /**
     * 삭제 (관리용)
     */
    @RequestMapping("/api/plg/pointLedger/deletePointLedger")
    @ResponseBody
    public Map<String, Object> deletePointLedger(@RequestBody HashMap<String, Object> map) throws Exception {
        Map<String, Object> resultMap = new HashMap<>();
        pointLedgerService.deletePointLedger(map);
        resultMap.put("msg", "삭제 성공");
        return resultMap;
    }

    /**
     * 카운트 (관리/통계용)
     */
    @RequestMapping("/api/plg/pointLedger/selectPointLedgerListCount")
    @ResponseBody
    public Map<String, Object> selectPointLedgerListCount(@RequestBody HashMap<String, Object> map) throws Exception {
        Map<String, Object> resultMap = new HashMap<>();
        int count = pointLedgerService.selectPointLedgerListCount(map);
        resultMap.put("msg", "성공");
        resultMap.put("count", count);
        return resultMap;
    }

    // ===========================
    //  사용자 포인트 API
    // ===========================

    /**
     * 내 포인트 홈 (잔액 + 최근 거래내역)
     * body: { limit, offset }
     */
    @RequestMapping("/api/plg/pointLedger/selectMyPointHome")
    @ResponseBody
    public Map<String, Object> selectMyPointHome(@RequestBody(required = false) HashMap<String, Object> body)
            throws Exception {

        Map<String, Object> res = new HashMap<>();

        Long userId = getLoginUserId();
        if (userId == null) {
            res.put("msg", "LOGIN_REQUIRED");
            return res;
        }

        int limit = 50;
        int offset = 0;

        if (body != null) {
            Object limitObj = body.get("limit");
            Object offsetObj = body.get("offset");

            if (limitObj != null) {
                try {
                    limit = Integer.parseInt(String.valueOf(limitObj));
                } catch (NumberFormatException ignore) {}
            }
            if (offsetObj != null) {
                try {
                    offset = Integer.parseInt(String.valueOf(offsetObj));
                } catch (NumberFormatException ignore) {}
            }
        }

        Map<String, Object> result = pointLedgerService.selectMyPointHome(userId, limit, offset);
        res.put("msg", "성공");
        res.put("result", result);
        return res;
    }

    /**
     * 포인트 충전
     * body: { amt, memo }
     */
    @RequestMapping("/api/plg/pointLedger/charge")
    @ResponseBody
    public Map<String, Object> charge(@RequestBody HashMap<String, Object> body) throws Exception {

        Map<String, Object> res = new HashMap<>();

        Long userId = getLoginUserId();
        if (userId == null) {
            res.put("msg", "LOGIN_REQUIRED");
            return res;
        }

        Object amtObj = body.get("amt");
        if (amtObj == null) {
            res.put("msg", "충전 금액을 입력해주세요.");
            return res;
        }

        BigDecimal amt;
        try {
            amt = new BigDecimal(String.valueOf(amtObj));
        } catch (NumberFormatException e) {
            res.put("msg", "충전 금액 형식이 올바르지 않습니다.");
            return res;
        }

        if (amt.compareTo(BigDecimal.ZERO) <= 0) {
            res.put("msg", "충전 금액은 0보다 커야 합니다.");
            return res;
        }

        String memo = body.get("memo") != null ? String.valueOf(body.get("memo")) : null;

        String actorEmail = null;
        if (UserSessionManager.isUserLogined()) {
            actorEmail = UserSessionManager.getLoginUserVO().getUserId();
        }

        Map<String, Object> result = pointLedgerService.chargePoint(userId, actorEmail, amt, memo);
        res.put("msg", "성공");
        res.put("result", result);
        return res;
    }
    
    /**
     * 보유 포인트 요약 조회
     * URL: /api/plg/pointLedger/selectPointSummary
     */
    @RequestMapping("/api/plg/pointLedger/selectPointSummary")
    @ResponseBody
    public Map<String, Object> selectPointSummary(@RequestBody(required = false) HashMap<String, Object> map)
            throws Exception {

        Map<String, Object> resultMap = new HashMap<>();

        // 로그인 체크
        if (!UserSessionManager.isUserLogined()) {
            resultMap.put("ok", false);
            resultMap.put("msg", "LOGIN_REQUIRED");
            return resultMap;
        }

        if (map == null) {
            map = new HashMap<>();
        }

        // ★ 여기 userId 컬럼명은 네 TB_POINT_LEDGER 구조에 맞춰서 수정
        map.put("userId", UserSessionManager.getLoginUserVO().getUserId());

        Map<String, Object> summary = pointLedgerService.selectPointSummary(map);

        resultMap.put("ok", true);
        resultMap.put("msg", "성공");
        resultMap.put("result", summary);

        return resultMap;
    }
    
}
