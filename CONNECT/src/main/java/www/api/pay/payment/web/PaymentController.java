// filepath: src/main/java/www/api/pay/payment/web/PaymentController.java
package www.api.pay.payment.web;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import www.api.pay.payment.service.PaymentService;
import www.com.user.service.UserSessionManager;

@Controller
public class PaymentController {

    @Autowired
    private PaymentService paymentService;

    /**
     * 결제 목록 조회
     */
    @RequestMapping("/api/pay/payment/selectPaymentList")
    @ResponseBody
    public Map<String, Object> selectPaymentList(@RequestBody HashMap<String, Object> map) throws Exception {
        Map<String, Object> resultMap = new HashMap<>();
        List<Map<String, Object>> result = paymentService.selectPaymentList(map);
        resultMap.put("ok", true);
        resultMap.put("msg", "성공");
        resultMap.put("result", result);
        return resultMap;
    }

    /**
     * 결제 단건 조회
     */
    @RequestMapping("/api/pay/payment/selectPaymentDetail")
    @ResponseBody
    public Map<String, Object> selectPaymentDetail(@RequestBody HashMap<String, Object> map) throws Exception {
        Map<String, Object> resultMap = new HashMap<>();
        Map<String, Object> result = paymentService.selectPaymentDetail(map);
        resultMap.put("ok", true);
        resultMap.put("msg", "성공");
        resultMap.put("result", result);
        return resultMap;
    }

    /**
     * 결제 등록
     */
    @RequestMapping("/api/pay/payment/insertPayment")
    @ResponseBody
    public Map<String, Object> insertPayment(@RequestBody HashMap<String, Object> map) throws Exception {
        if (UserSessionManager.isUserLogined()) {
            // 감사 컬럼 규칙: CREATED_BY
            map.put("createdBy", UserSessionManager.getLoginUserVO().getUserId());
            map.put("updatedBy", UserSessionManager.getLoginUserVO().getUserId());
        }
        Map<String, Object> resultMap = new HashMap<>();
        paymentService.insertPayment(map);
        resultMap.put("ok", true);
        resultMap.put("msg", "등록 성공");
        return resultMap;
    }

    /**
     * 결제 수정
     */
    @RequestMapping("/api/pay/payment/updatePayment")
    @ResponseBody
    public Map<String, Object> updatePayment(@RequestBody HashMap<String, Object> map) throws Exception {
        if (UserSessionManager.isUserLogined()) {
            // 감사 컬럼 규칙: UPDATED_BY
            map.put("updatedBy", UserSessionManager.getLoginUserVO().getUserId());
        }
        Map<String, Object> resultMap = new HashMap<>();
        paymentService.updatePayment(map);
        resultMap.put("ok", true);
        resultMap.put("msg", "수정 성공");
        return resultMap;
    }

    /**
     * 결제 삭제(soft delete)
     */
    @RequestMapping("/api/pay/payment/deletePayment")
    @ResponseBody
    public Map<String, Object> deletePayment(@RequestBody HashMap<String, Object> map) throws Exception {
        if (UserSessionManager.isUserLogined()) {
            map.put("updatedBy", UserSessionManager.getLoginUserVO().getUserId());
        }
        Map<String, Object> resultMap = new HashMap<>();
        paymentService.deletePayment(map);
        resultMap.put("ok", true);
        resultMap.put("msg", "삭제 성공");
        return resultMap;
    }

    /**
     * 결제 개수
     */
    @RequestMapping("/api/pay/payment/selectPaymentListCount")
    @ResponseBody
    public Map<String, Object> selectPaymentListCount(@RequestBody HashMap<String, Object> map) throws Exception {
        Map<String, Object> resultMap = new HashMap<>();
        int count = paymentService.selectPaymentListCount(map);
        resultMap.put("ok", true);
        resultMap.put("msg", "성공");
        resultMap.put("count", count);
        return resultMap;
    }
}
