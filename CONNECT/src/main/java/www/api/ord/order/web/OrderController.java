// filepath: src/main/java/www/api/ord/order/web/OrderController.java
package www.api.ord.order.web;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

import www.api.ord.order.service.OrderService;
import www.api.ord.orderItem.service.OrderItemService;
import www.api.pay.payment.service.PaymentService;
import www.com.user.service.UserSessionManager;

@Controller
public class OrderController {

    @Autowired
    private OrderService orderService;

    @Autowired
    private OrderItemService orderItemService;

    @Autowired
    private PaymentService paymentService;

    /**
     * 주문 목록 조회
     */
    @RequestMapping("/api/ord/order/selectOrderList")
    @ResponseBody
    public Map<String, Object> selectOrderList(@RequestBody HashMap<String, Object> map) throws Exception {
        Map<String, Object> resultMap = new HashMap<>();
        
        
        if (!UserSessionManager.isUserLogined()) {
            resultMap.put("ok", false);
            resultMap.put("msg", "LOGIN_REQUIRED");
            return resultMap;
        }

        // 로그인 사용자 정보
        String userId = UserSessionManager.getLoginUserVO().getUserId();

        map.put("userId", userId);
        
        List<Map<String, Object>> result = orderService.selectOrderList(map);
        
        resultMap.put("ok", true);
        resultMap.put("msg", "성공");
        resultMap.put("result", result);
        return resultMap;
    }

    /**
     * 주문 단건 조회
     */
    @RequestMapping("/api/ord/order/selectOrderDetail")
    @ResponseBody
    public Map<String, Object> selectOrderDetail(@RequestBody HashMap<String, Object> map) throws Exception {
        Map<String, Object> resultMap = new HashMap<>();
        Map<String, Object> result = orderService.selectOrderDetail(map);
        resultMap.put("ok", true);
        resultMap.put("msg", "성공");
        resultMap.put("result", result);
        return resultMap;
    }

    /**
     * 주문 + 주문상품 + 결제 통합 상세 조회
     * - 파라미터: { "orderId": 123 } 기준
     */
    @RequestMapping("/api/ord/order/selectOrderFullDetail")
    @ResponseBody
    public Map<String, Object> selectOrderFullDetail(@RequestBody HashMap<String, Object> map) throws Exception {
        Map<String, Object> order = orderService.selectOrderDetail(map);
        List<Map<String, Object>> items = orderItemService.selectOrderItemList(map);
        List<Map<String, Object>> payments = paymentService.selectPaymentList(map);

        Map<String, Object> detail = new HashMap<>();
        detail.put("order", order);
        detail.put("items", items);
        detail.put("payments", payments);

        Map<String, Object> resultMap = new HashMap<>();
        resultMap.put("ok", true);
        resultMap.put("msg", "성공");
        resultMap.put("result", detail);
        return resultMap;
    }

    /**
     * 주문 등록(주문 + 결제 + 포인트 사용/적립까지 한 번에 처리)
     *
     * 기대 입력(JSON):
     * {
     *   "orderNo": "...",
     *   "orderAmt": 12345,
     *   "payAmt": 12345,
     *   "cartIds": [20, 21]        // 혹은 "20,21"
     *   // 또는
     *   "cartItemIds": [20, 21]    // 혹은 "20,21"
     * }
     */
    @RequestMapping("/api/ord/order/insertOrder")
    @ResponseBody
    public Map<String, Object> insertOrder(@RequestBody HashMap<String, Object> map) throws Exception {
        Map<String, Object> resultMap = new HashMap<>();

        if (!UserSessionManager.isUserLogined()) {
            resultMap.put("ok", false);
            resultMap.put("msg", "LOGIN_REQUIRED");
            return resultMap;
        }

        // 로그인 사용자 정보
        String userId = UserSessionManager.getLoginUserVO().getUserId();
        String userEmail = UserSessionManager.getLoginUserVO().getEmail();

        map.put("userId", userId);
        map.put("createdBy", userId);
        map.put("updatedBy", userId);

        // ==========================
        // 선택된 장바구니 ID 정규화
        // ==========================
        List<Long> cartItemIds = resolveCartItemIdsFromBody(map);

        // 서비스가 바로 쓸 수 있도록 표준 키로 세팅
        if (!cartItemIds.isEmpty()) {
            map.put("cartItemIds", cartItemIds);
        }

        // 주문 + 결제 + 포인트를 하나의 트랜잭션으로 처리
        orderService.insertOrderWithPayAndPoint(map);

        resultMap.put("ok", true);
        resultMap.put("msg", "등록 성공");
        return resultMap;
    }

    /**
     * 주문 수정
     */
    @RequestMapping("/api/ord/order/updateOrder")
    @ResponseBody
    public Map<String, Object> updateOrder(@RequestBody HashMap<String, Object> map) throws Exception {
        if (UserSessionManager.isUserLogined()) {
            String userId = UserSessionManager.getLoginUserVO().getUserId();
            String userEmail = UserSessionManager.getLoginUserVO().getEmail();
            map.put("userId", userId);
            map.put("updatedBy", userId);
        }
        Map<String, Object> resultMap = new HashMap<>();
        orderService.updateOrder(map);
        resultMap.put("ok", true);
        resultMap.put("msg", "수정 성공");
        return resultMap;
    }

    /**
     * 주문 삭제(soft delete)
     */
    @RequestMapping("/api/ord/order/deleteOrder")
    @ResponseBody
    public Map<String, Object> deleteOrder(@RequestBody HashMap<String, Object> map) throws Exception {
        if (UserSessionManager.isUserLogined()) {
            String userId = UserSessionManager.getLoginUserVO().getUserId();
            String userEmail = UserSessionManager.getLoginUserVO().getEmail();
            map.put("userId", userId);
            map.put("updatedBy", userId);
        }
        Map<String, Object> resultMap = new HashMap<>();
        orderService.deleteOrder(map);
        resultMap.put("ok", true);
        resultMap.put("msg", "삭제 성공");
        return resultMap;
    }

    /**
     * 주문 개수
     */
    @RequestMapping("/api/ord/order/selectOrderListCount")
    @ResponseBody
    public Map<String, Object> selectOrderListCount(@RequestBody HashMap<String, Object> map) throws Exception {
        Map<String, Object> resultMap = new HashMap<>();
        int count = orderService.selectOrderListCount(map);
        resultMap.put("ok", true);
        resultMap.put("msg", "성공");
        resultMap.put("count", count);
        return resultMap;
    }

    /**
     * 주문 취소(결제 취소 + 포인트 사용/적립 롤백까지 한 번에 처리)
     *
     * 기대 입력(JSON):
     * {
     *   "orderId": 123   // 또는 "orderIdx": 123
     * }
     *
     * - 이미 취소된 주문에 대해선 서비스 레벨에서 방어(예외/무시) 처리 가정
     * - 컨트롤러는 로그인·파라미터 검증 + 공통 응답만 담당
     */
    @RequestMapping("/api/ord/order/cancelOrder")
    @ResponseBody
    public Map<String, Object> cancelOrder(@RequestBody HashMap<String, Object> map) throws Exception {
        Map<String, Object> resultMap = new HashMap<>();

        if (!UserSessionManager.isUserLogined()) {
            resultMap.put("ok", false);
            resultMap.put("msg", "LOGIN_REQUIRED");
            return resultMap;
        }

        // 로그인 사용자 정보
        String userId = UserSessionManager.getLoginUserVO().getUserId();
        String userEmail = UserSessionManager.getLoginUserVO().getEmail();

        map.put("userId", userId);
        map.put("updatedBy", userId);

        // orderId / orderIdx 정규화
        Object orderIdObj = map.get("orderId");
        if (orderIdObj == null) {
            orderIdObj = map.get("orderIdx");
        }
        if (orderIdObj == null) {
            resultMap.put("ok", false);
            resultMap.put("msg", "INVALID_ORDER_ID");
            return resultMap;
        }

        String orderIdStr = String.valueOf(orderIdObj).trim();
        if (orderIdStr.isEmpty()) {
            resultMap.put("ok", false);
            resultMap.put("msg", "INVALID_ORDER_ID");
            return resultMap;
        }

        // 서비스 계층에서 혼동 없도록 두 키 모두 세팅
        map.put("orderId", orderIdStr);
        map.put("orderIdx", orderIdStr);

        // 주문 취소 + 결제 취소 + 포인트 롤백을 하나의 트랜잭션으로 처리
        // (실제 구현: OrderService.cancelOrderWithPayAndPoint(map) 에서 담당)
        orderService.cancelOrder(map);

        resultMap.put("ok", true);
        resultMap.put("msg", "취소 성공");
        return resultMap;
    }

    // ==========================
    // 내부 유틸 – cartIds 정규화
    // ==========================

    /**
     * Body(map)에서 cartItemIds / cartIds 를 모아서 List<Long>으로 정규화
     *
     * 지원 케이스:
     * - { "cartItemIds": [20,21] }
     * - { "cartItemIds": "20,21" }
     * - { "cartIds": [20,21] }
     * - { "cartIds": "20,21" }
     * - { "cartIds": "20" }
     */
    private List<Long> resolveCartItemIdsFromBody(Map<String, Object> map) {
        List<Long> result = new ArrayList<>();
        if (map == null) {
            return result;
        }

        // 1) cartItemIds 우선
        Object raw = map.get("cartItemIds");
        extractIdsIntoList(raw, result);

        // 2) 비어 있으면 cartIds 도 시도
        if (result.isEmpty()) {
            Object cartIdsRaw = map.get("cartIds");
            extractIdsIntoList(cartIdsRaw, result);
        }

        return result;
    }

    /**
     * Object(raw) → result(List<Long>)에 숫자 ID 추가
     * - List<?> 인 경우: 각 요소를 Long 변환
     * - String 인 경우: "20,21,22" 스플릿 후 Long 변환
     * - 그 외: 단일 값 Long 변환
     */
    private void extractIdsIntoList(Object raw, List<Long> result) {
        if (raw == null) {
            return;
        }

        // List 형태일 때: [20, "21", 22L ...]
        if (raw instanceof List<?>) {
            for (Object o : (List<?>) raw) {
                Long id = parseLongSafe(o);
                if (id != null) {
                    result.add(id);
                }
            }
            return;
        }

        // 문자열: "20,21,22" 또는 "20"
        if (raw instanceof String) {
            String s = ((String) raw).trim();
            if (!s.isEmpty()) {
                String[] parts = s.split(",");
                for (String p : parts) {
                    String trimmed = p.trim();
                    if (trimmed.isEmpty()) {
                        continue;
                    }
                    Long id = parseLongSafe(trimmed);
                    if (id != null) {
                        result.add(id);
                    }
                }
            }
            return;
        }

        // 그 외 단일 값
        Long single = parseLongSafe(raw);
        if (single != null) {
            result.add(single);
        }
    }

    private Long parseLongSafe(Object o) {
        if (o == null) return null;
        try {
            return Long.parseLong(String.valueOf(o));
        } catch (NumberFormatException e) {
            return null;
        }
    }
}
