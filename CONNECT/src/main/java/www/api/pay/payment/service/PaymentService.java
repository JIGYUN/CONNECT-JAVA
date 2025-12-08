// filepath: src/main/java/www/api/pay/payment/service/PaymentService.java
package www.api.pay.payment.service;

import java.math.BigDecimal;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import www.com.util.CommonDao;

@Service
public class PaymentService {

    private final String namespace = "www.api.pay.payment.Payment";

    @Autowired
    private CommonDao dao;

    /**
     * 결제 목록 조회
     */
    public List<Map<String, Object>> selectPaymentList(Map<String, Object> paramMap) {
        return dao.list(namespace + ".selectPaymentList", paramMap);
    }

    /**
     * 결제 목록 수 조회
     */
    public int selectPaymentListCount(Map<String, Object> paramMap) {
        Map<String, Object> resultMap = dao.selectOne(namespace + ".selectPaymentListCount", paramMap);
        if (resultMap != null && resultMap.get("cnt") != null) {
            return Integer.parseInt(resultMap.get("cnt").toString());
        }
        return 0;
    }

    /**
     * 결제 단건 조회
     */
    public Map<String, Object> selectPaymentDetail(Map<String, Object> paramMap) {
        return dao.selectOne(namespace + ".selectPaymentDetail", paramMap);
    }

    /**
     * 결제 등록
     */
    @Transactional
    public void insertPayment(Map<String, Object> paramMap) {
        dao.insert(namespace + ".insertPayment", paramMap);
    }

    /**
     * 결제 수정
     */
    @Transactional
    public void updatePayment(Map<String, Object> paramMap) {
        dao.update(namespace + ".updatePayment", paramMap);
    }

    /**
     * 결제 삭제(soft delete)
     */
    @Transactional
    public void deletePayment(Map<String, Object> paramMap) {
        dao.delete(namespace + ".deletePayment", paramMap);
    }

    // ============================
    //  결제 취소 + 환불 기록
    // ============================
    @Transactional
    public void cancelPaymentByOrderId(Long orderId, String actor) {
        if (orderId == null) {
            return;
        }

        Map<String, Object> findParam = new HashMap<>();
        findParam.put("orderId", orderId);

        // 1) 마지막 PAY_DONE 결제 한 건 조회
        Map<String, Object> payRow = dao.selectOne(namespace + ".selectLastPayDoneByOrderId", findParam);
        if (payRow == null) {
            // 이미 취소됐거나 결제가 없을 수 있음 → 조용히 리턴
            return;
        }

        Long paymentId = firstNonNullLong(
                payRow.get("paymentId"),
                payRow.get("PAYMENT_ID")
        );

        BigDecimal approvedAmt = firstNonZeroBigDecimal(
                payRow.get("payApprovedAmt"),
                payRow.get("PAY_APPROVED_AMT"),
                payRow.get("payTotalAmt"),
                payRow.get("PAY_TOTAL_AMT")
        );

        if (paymentId == null) {
            // 결제 PK가 없으면 환불 기록 남길 수 없음
            return;
        }

        if (approvedAmt.compareTo(BigDecimal.ZERO) <= 0) {
            approvedAmt = BigDecimal.ZERO;
        }

        if (actor == null) {
            actor = "";
        }

        // PG_CANCEL_TID는 일단 기존 PG_TID 재사용 (실 PG 연동 시 실제 취소 TID로 교체 가능)
        Object pgTidObj = firstNonNull(payRow.get("pgTid"), payRow.get("PG_TID"));
        String pgCancelTid = pgTidObj != null ? String.valueOf(pgTidObj) : null;

        // 2) TB_PAYMENT_REFUND 에 환불 이력 기록
        Map<String, Object> refundParam = new HashMap<>();
        refundParam.put("paymentId", paymentId);
        refundParam.put("orderId", orderId);
        refundParam.put("orderItemId", null); // 전체 주문 환불이므로 일단 NULL (부분 환불 구현 시 세팅)
        refundParam.put("refundAmt", approvedAmt);
        refundParam.put("refundStatusCd", "REFUND_DONE");            // 예: REQ / DONE 등 코드 테이블과 맞춰 사용
        refundParam.put("refundReason", "주문 취소에 따른 전체 환불");
        refundParam.put("pgCancelTid", pgCancelTid);
        refundParam.put("useAt", "Y");
        refundParam.put("createdBy", actor);
        refundParam.put("updatedBy", actor);

        dao.insert(namespace + ".insertPaymentRefund", refundParam);

        // 3) TB_PAYMENT 결제 상태를 PAY_CANCEL 로 변경
        Map<String, Object> updParam = new HashMap<>();
        updParam.put("orderId", orderId);
        updParam.put("payStatusCd", "PAY_CANCEL");
        updParam.put("updatedBy", actor);

        dao.update(namespace + ".updatePaymentStatusByOrderId", updParam);
    }

    // ============================
    //  내부 유틸
    // ============================

    private Long firstNonNullLong(Object... arr) {
        Object o = firstNonNull(arr);
        if (o == null) {
            return null;
        }
        try {
            return Long.parseLong(String.valueOf(o));
        } catch (NumberFormatException e) {
            return null;
        }
    }

    private Object firstNonNull(Object... arr) {
        if (arr == null) {
            return null;
        }
        for (Object o : arr) {
            if (o != null) {
                return o;
            }
        }
        return null;
    }

    private BigDecimal toBigDecimal(Object o) {
        if (o == null) {
            return BigDecimal.ZERO;
        }
        try {
            return new BigDecimal(String.valueOf(o));
        } catch (NumberFormatException e) {
            return BigDecimal.ZERO;
        }
    }

    private BigDecimal firstNonZeroBigDecimal(Object... arr) {
        if (arr == null) {
            return BigDecimal.ZERO;
        }
        for (Object o : arr) {
            BigDecimal v = toBigDecimal(o);
            if (v.compareTo(BigDecimal.ZERO) > 0) {
                return v;
            }
        }
        return BigDecimal.ZERO;
    }
}
