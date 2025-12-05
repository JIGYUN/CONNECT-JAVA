package www.api.pay.payment.service;

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
}
