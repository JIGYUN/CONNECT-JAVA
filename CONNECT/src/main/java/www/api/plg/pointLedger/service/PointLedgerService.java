package www.api.plg.pointLedger.service;

import java.math.BigDecimal;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import www.com.util.CommonDao;

@Service
public class PointLedgerService {

    private final String namespace = "www.api.plg.pointLedger.PointLedger";

    @Autowired
    private CommonDao dao;

    /**
     * 포인트 원장 목록(관리/통계용)
     */
    public List<Map<String, Object>> selectPointLedgerList(Map<String, Object> paramMap) {
        return dao.list(namespace + ".selectPointLedgerList", paramMap);
    }

    /**
     * 포인트 원장 카운트(관리/통계용)
     */
    public int selectPointLedgerListCount(Map<String, Object> paramMap) {
        Map<String, Object> resultMap = dao.selectOne(namespace + ".selectPointLedgerListCount", paramMap);
        if (resultMap != null && resultMap.get("cnt") != null) {
            return Integer.parseInt(String.valueOf(resultMap.get("cnt")));
        }
        return 0;
    }

    /**
     * 포인트 원장 단건 조회(관리/통계용)
     */
    public Map<String, Object> selectPointLedgerDetail(Map<String, Object> paramMap) {
        return dao.selectOne(namespace + ".selectPointLedgerDetail", paramMap);
    }

    /**
     * 포인트 원장 직접 입력(관리용)
     */
    @Transactional
    public void insertPointLedger(Map<String, Object> paramMap) {
        dao.insert(namespace + ".insertPointLedger", paramMap);
    }

    /**
     * 포인트 원장 수정(관리용)
     */
    @Transactional
    public void updatePointLedger(Map<String, Object> paramMap) {
        dao.update(namespace + ".updatePointLedger", paramMap);
    }

    /**
     * 포인트 원장 삭제(관리용)
     */
    @Transactional
    public void deletePointLedger(Map<String, Object> paramMap) {
        dao.delete(namespace + ".deletePointLedger", paramMap);
    }

    // =======================
    //  포인트 사용자용 기능
    // =======================

    /**
     * 유저 포인트 요약 조회 (TB_USER.POINT_BALANCE)
     */
    public Map<String, Object> selectUserPointSummary(Long userId) {
        Map<String, Object> param = new HashMap<>();
        param.put("userId", userId);
        return dao.selectOne(namespace + ".selectUserPointSummary", param);
    }

    /**
     * 포인트 홈(잔액 + 최근 원장 목록) 조회
     */
    public Map<String, Object> selectMyPointHome(Long userId, int limit, int offset) {
        Map<String, Object> result = new HashMap<>();

        Map<String, Object> summary = selectUserPointSummary(userId);

        Map<String, Object> listParam = new HashMap<>();
        listParam.put("userId", userId);
        listParam.put("limit", limit);
        listParam.put("offset", offset);

        List<Map<String, Object>> items = dao.list(namespace + ".selectPointLedgerList", listParam);

        result.put("summary", summary);
        result.put("items", items);
        return result;
    }

    /**
     * 내부 공통: delta 만큼 포인트 변동
     *  - delta > 0 : 적립/충전
     *  - delta < 0 : 사용/차감
     */
    private Map<String, Object> applyPoint(Long userId,
                                           String actor,
                                           BigDecimal delta,
                                           Long orderId,
                                           String typeCd,
                                           String memo) {

        Map<String, Object> summary = selectUserPointSummary(userId);

        BigDecimal current = BigDecimal.ZERO;
        if (summary != null && summary.get("pointBalance") != null) {
            current = new BigDecimal(String.valueOf(summary.get("pointBalance")));
        }

        BigDecimal newBalance = current.add(delta);
        if (newBalance.compareTo(BigDecimal.ZERO) < 0) {
            throw new IllegalStateException("포인트 잔액이 부족합니다.");
        }

        // 1) 원장 한 줄 추가
        Map<String, Object> ledgerParam = new HashMap<>();
        ledgerParam.put("userId", userId);
        ledgerParam.put("orderId", orderId);
        ledgerParam.put("typeCd", typeCd);
        ledgerParam.put("amt", delta);
        ledgerParam.put("balanceAfter", newBalance);
        ledgerParam.put("memo", memo);
        ledgerParam.put("createdBy", actor);
        ledgerParam.put("updatedBy", actor);
        dao.insert(namespace + ".insertPointLedger", ledgerParam);

        // 2) 회원 잔액 반영
        Map<String, Object> updParam = new HashMap<>();
        updParam.put("userId", userId);
        updParam.put("pointBalance", newBalance);
        updParam.put("updatedBy", actor);
        dao.update(namespace + ".updateUserPointBalance", updParam);

        Map<String, Object> result = new HashMap<>();
        result.put("pointBalance", newBalance);
        return result;
    }

    /**
     * 포인트 충전/적립
     */
    @Transactional
    public Map<String, Object> chargePoint(Long userId, String actor, BigDecimal amt, String memo) {
        if (amt == null || amt.compareTo(BigDecimal.ZERO) <= 0) {
            return selectUserPointSummary(userId);
        }
        return applyPoint(userId, actor, amt, null, "CHARGE", memo);
    }

    /**
     * 주문에서 포인트 사용(차감)
     *  - amt : 사용하려는 양(양수)
     */
    @Transactional
    public Map<String, Object> usePointForOrder(Long userId,
                                                String actor,
                                                BigDecimal amt,
                                                Long orderId,
                                                String memo) {
        if (amt == null || amt.compareTo(BigDecimal.ZERO) <= 0) {
            return selectUserPointSummary(userId);
        }
        BigDecimal delta = amt.negate(); // 차감
        return applyPoint(userId, actor, delta, orderId, "USE", memo);
    }

    /**
     * 보유 포인트 요약 조회 (기존 JSP용)
     */
    public Map<String, Object> selectPointSummary(Map<String, Object> paramMap) {
        return dao.selectOne(namespace + ".selectPointSummary", paramMap);
    }
}
