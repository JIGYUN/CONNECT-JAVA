package www.api.pay.toss.web;

import java.util.HashMap;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

import www.api.pay.toss.service.TossPayService;

@Controller
public class TossPayController {

    @Autowired
    private TossPayService tossPayService;

    /**
     * 토스 결제 준비:
     * - 주문/주문상품/결제(PAY_READY) 생성
     * - 결제창에 필요한 orderNo, amount, customerKey 반환
     */
    @RequestMapping("/api/pay/toss/prepare")
    @ResponseBody
    public Map<String, Object> prepare(@RequestBody HashMap<String, Object> body) throws Exception {
        Map<String, Object> resultMap = new HashMap<>();

        Map<String, Object> result = tossPayService.prepareTossOrder(body);

        resultMap.put("ok", true);
        resultMap.put("msg", "성공");
        resultMap.put("result", result);
        return resultMap;
    }

    /**
     * 토스 결제 성공 리다이렉트:
     * - paymentKey/orderId/amount 파라미터로 confirm 수행
     * - 성공 시 결제완료 페이지로 이동
     */
    @RequestMapping(value = "/pay/toss/success", method = RequestMethod.GET)
    public String success(HttpServletRequest req) throws Exception {

        String paymentKey = nvl(req.getParameter("paymentKey"));
        String orderId = nvl(req.getParameter("orderId")); // = orderNo 로 사용
        String amountStr = nvl(req.getParameter("amount"));

        if (paymentKey.isEmpty() || orderId.isEmpty() || amountStr.isEmpty()) {
            return "redirect:/pay/toss/fail?code=INVALID_PARAM&message=missing_params";
        }

        Map<String, Object> result = tossPayService.confirmFromRedirect(paymentKey, orderId, amountStr);

        boolean ok = Boolean.TRUE.equals(result.get("ok"));
        if (!ok) {
            String code = String.valueOf(result.get("code"));
            String message = String.valueOf(result.get("message"));
            return "redirect:/pay/toss/fail?code=" + url(code) + "&message=" + url(message);
        }

        // 결제완료 화면 이동(기존 페이지 재사용)
        String orderNo = String.valueOf(result.get("orderNo"));
        String totalAmt = String.valueOf(result.get("totalAmt"));
        String payAmt = String.valueOf(result.get("payAmt"));
        String pointUseAmt = String.valueOf(result.get("pointUseAmt"));
        String couponUseAmt = String.valueOf(result.get("couponUseAmt"));

        String q =
            "?orderNo=" + url(orderNo) +
            "&totalAmt=" + url(totalAmt) +
            "&payAmt=" + url(payAmt) +
            "&pointUseAmt=" + url(pointUseAmt) +
            "&couponUseAmt=" + url(couponUseAmt);

        return "redirect:/pay/payment/paymentModify" + q;
    }

    /**
     * 토스 결제 실패 리다이렉트:
     * - 토스가 code/message를 준다(없을 수도 있음)
     */
    @RequestMapping(value = "/pay/toss/fail", method = RequestMethod.GET)
    @ResponseBody
    public String fail(HttpServletRequest req) {
        String code = nvl(req.getParameter("code"));
        String message = nvl(req.getParameter("message"));
        return "TOSS_FAIL code=" + code + " message=" + message;
    }

    /**
     * 토스 결제 취소(서버 호출):
     * - orderNo 또는 orderId로 결제(paymentKey=PG_TID)를 찾아 Toss cancel API 호출
     * - 성공 시 TB_PAYMENT(PAY_CANCEL), TB_ORDER(ORDER_CANCEL/PAY_CANCEL) 업데이트
     *
     * body 예:
     * {
     *   "orderNo": "O20251224123456123",
     *   "cancelReason": "사용자 요청"
     * }
     */
    @RequestMapping("/api/pay/toss/cancel")
    @ResponseBody
    public Map<String, Object> cancel(@RequestBody HashMap<String, Object> body) throws Exception {
        Map<String, Object> resultMap = new HashMap<>();

        Map<String, Object> result = tossPayService.cancelTossPayment(body);

        boolean ok = Boolean.TRUE.equals(result.get("ok"));
        resultMap.put("ok", ok);
        resultMap.put("msg", ok ? "성공" : String.valueOf(result.get("message")));
        resultMap.put("result", result);

        return resultMap;
    }

    private String nvl(String s) {
        return s == null ? "" : s.trim();
    }

    private String url(String s) {
        if (s == null) return "";
        try {
            return java.net.URLEncoder.encode(s, "UTF-8");
        } catch (Exception e) {
            return "";
        }
    }
}
