package www.api.ord.order.service;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import www.api.cop.couponUser.service.CouponUserService;
import www.api.crt.cart.service.CartService;
import www.api.ord.orderItem.service.OrderItemService;
import www.api.pay.payment.service.PaymentService;
import www.api.pay.toss.service.TossPayService;
import www.api.plg.pointLedger.service.PointLedgerService;
import www.com.util.CommonDao;

@Service
public class OrderService {

    private static final Logger log = LoggerFactory.getLogger(OrderService.class);

    private final String namespace = "www.api.ord.order.Order";

    @Autowired
    private CommonDao dao;

    @Autowired
    private PaymentService paymentService;

    @Autowired
    private TossPayService tossPayService;

    @Autowired
    private PointLedgerService pointLedgerService;

    @Autowired
    private CartService cartService;

    @Autowired
    private OrderItemService orderItemService;

    @Autowired
    private CouponUserService couponUserService;

    public List<Map<String, Object>> selectOrderList(Map<String, Object> paramMap) {
        return dao.list(namespace + ".selectOrderList", paramMap);
    }

    public int selectOrderListCount(Map<String, Object> paramMap) {
        Map<String, Object> resultMap = dao.selectOne(namespace + ".selectOrderListCount", paramMap);
        if (resultMap != null && resultMap.get("cnt") != null) {
            return Integer.parseInt(resultMap.get("cnt").toString());
        }
        return 0;
    }

    public Map<String, Object> selectOrderDetail(Map<String, Object> paramMap) {
        return dao.selectOne(namespace + ".selectOrderDetail", paramMap);
    }

    @Transactional
    public void insertOrder(Map<String, Object> paramMap) {
        dao.insert(namespace + ".insertOrder", paramMap);
    }

    @Transactional
    public void insertOrderWithPayAndPoint(Map<String, Object> paramMap) {

        if (log.isDebugEnabled()) {
            log.debug("insertOrderWithPayAndPoint() 호출 - paramMap keys = {}", paramMap.keySet());
            log.debug("insertOrderWithPayAndPoint() raw.cartItemIds = {}", paramMap.get("cartItemIds"));
            log.debug("insertOrderWithPayAndPoint() raw.cartIds     = {}", paramMap.get("cartIds"));
            log.debug("insertOrderWithPayAndPoint() raw.cartIdList  = {}", paramMap.get("cartIdList"));
            log.debug("insertOrderWithPayAndPoint() raw.cartItemId  = {}", paramMap.get("cartItemId"));
        }

        dao.insert(namespace + ".insertOrder", paramMap);

        String orderNo = asString(firstNonNull(paramMap.get("orderNo"), paramMap.get("ORDER_NO")));

        Map<String, Object> findParam = new HashMap<>();
        findParam.put("orderNo", orderNo);

        Map<String, Object> orderRow = dao.selectOne(namespace + ".selectOrderByOrderNo", findParam);
        if (orderRow == null) {
            throw new IllegalStateException("주문 번호로 주문을 찾을 수 없습니다. orderNo=" + orderNo);
        }

        Long orderId = firstNonNullLong(
                orderRow.get("orderId"),
                orderRow.get("ORDER_ID"),
                orderRow.get("order_id"),
                orderRow.get("orderIdx"),
                orderRow.get("ORDERIDX")
        );

        if (orderId == null) {
            throw new IllegalStateException(
                    "ORDER_ID를 찾을 수 없습니다. orderNo=" + orderNo + ", mapKeys=" + orderRow.keySet()
            );
        }

        BigDecimal orderAmt = toBigDecimal(firstNonNull(paramMap.get("orderAmt"), paramMap.get("ORDER_AMT")));
        BigDecimal payAmt   = toBigDecimal(firstNonNull(paramMap.get("payAmt"),   paramMap.get("PAY_AMT")));

        Map<String, Object> payParam = new HashMap<>();
        payParam.put("orderId",        orderId);
        payParam.put("pgCd",           "LOCAL");
        payParam.put("pgMid",          "LOCAL");
        payParam.put("pgTid",          orderNo);
        payParam.put("payMethodCd",    paramMap.get("payMethodCd"));
        payParam.put("payTotalAmt",    orderAmt);
        payParam.put("payApprovedAmt", payAmt);
        payParam.put("payStatusCd",    paramMap.get("payStatusCd"));
        payParam.put("reqDt",          null);
        payParam.put("resDt",          null);
        payParam.put("rawRequestJson", "{}");
        payParam.put("rawResponseJson","{}");
        payParam.put("useAt",          "Y");
        payParam.put("createdBy",      paramMap.get("createdBy"));
        payParam.put("updatedBy",      paramMap.get("updatedBy"));

        paymentService.insertPayment(payParam);

        Long userId = toLong(firstNonNull(paramMap.get("userId"), paramMap.get("USER_ID")));
        String actor = asString(firstNonNull(paramMap.get("createdBy"), paramMap.get("CREATED_BY")));

        BigDecimal pointUseAmt  = toBigDecimal(firstNonNull(paramMap.get("pointUseAmt"),  paramMap.get("POINT_USE_AMT")));
        BigDecimal pointSaveAmt = toBigDecimal(firstNonNull(paramMap.get("pointSaveAmt"), paramMap.get("POINT_SAVE_AMT")));
        BigDecimal couponUseAmt = toBigDecimal(firstNonNull(paramMap.get("couponUseAmt"), paramMap.get("COUPON_USE_AMT")));
        if (couponUseAmt.compareTo(BigDecimal.ZERO) < 0) {
            couponUseAmt = BigDecimal.ZERO;
        }

        Long couponUserId = toLong(firstNonNull(paramMap.get("couponUserId"), paramMap.get("COUPON_USER_ID")));

        if (userId != null) {
            if (pointUseAmt.compareTo(BigDecimal.ZERO) > 0) {
                pointLedgerService.usePointForOrder(
                        userId,
                        actor,
                        pointUseAmt,
                        orderId,
                        "주문 포인트 사용 (" + orderNo + ")"
                );
            }

            if (pointSaveAmt.compareTo(BigDecimal.ZERO) > 0) {
                pointLedgerService.chargePoint(
                        userId,
                        actor,
                        pointSaveAmt,
                        "주문 포인트 적립 (" + orderNo + ")"
                );
            }
        }

        if (couponUserId != null && couponUseAmt.compareTo(BigDecimal.ZERO) > 0) {
            couponUserService.updateCouponAsUsed(couponUserId, orderId, actor);
        }

        List<Long> cartItemIds = extractCartItemIds(paramMap);

        if (log.isDebugEnabled()) {
            log.debug("extractCartItemIds 결과 = {}", cartItemIds);
        }

        if (cartItemIds.isEmpty()) {
            throw new IllegalStateException(
                    "선택된 장바구니 항목이 없습니다. cartItemIds 비어 있음. "
                            + "프런트나 컨트롤러에서 CART_ITEM_ID들을 cartItemIds/cartIds/cartIdList 중 하나로 전달해야 합니다."
            );
        }

        if (userId != null) {

            Map<String, Object> cartParam = new HashMap<>();
            cartParam.put("userId",      userId);
            cartParam.put("cartItemIds", cartItemIds);

            @SuppressWarnings("unchecked")
            List<Map<String, Object>> items =
                    (List<Map<String, Object>>) (List<?>) dao.list(
                            "www.api.crt.cartItem.CartItem.selectCartViewListByUser",
                            cartParam
                    );

            if (log.isDebugEnabled()) {
                log.debug("선택된 장바구니 조회 결과 건수 = {}",
                        (items == null ? 0 : items.size()));
            }

            if (items != null && !items.isEmpty()) {
                for (Map<String, Object> row : items) {

                    Long productId = firstNonNullLong(
                            row.get("productId"),
                            row.get("PRODUCT_ID")
                    );
                    if (productId == null) {
                        continue;
                    }

                    String productNm = firstNonEmptyString(
                            row.get("productNm"),
                            row.get("PRODUCT_NM"),
                            row.get("title"),
                            row.get("TITLE")
                    );
                    if (productNm == null || productNm.isEmpty()) {
                        productNm = "(상품명 미지정)";
                    }

                    int qty = toInt(firstNonNull(
                            row.get("qty"),
                            row.get("QTY")
                    ), 0);
                    if (qty <= 0) {
                        qty = 1;
                    }

                    BigDecimal unitPrice = firstNonZeroBigDecimal(
                            row.get("unitPrice"),
                            row.get("UNIT_PRICE"),
                            row.get("salePrice"),
                            row.get("SALE_PRICE")
                    );

                    BigDecimal discountAmt = firstNonZeroBigDecimal(
                            row.get("discountAmt"),
                            row.get("DISCOUNT_AMT")
                    );

                    BigDecimal lineAmt = firstNonZeroBigDecimal(
                            row.get("lineAmt"),
                            row.get("LINE_AMT")
                    );
                    if (lineAmt.compareTo(BigDecimal.ZERO) <= 0) {
                        lineAmt = unitPrice.multiply(BigDecimal.valueOf(qty));
                    }

                    Object optObj = firstNonNull(
                            row.get("optionJson"),
                            row.get("OPTION_JSON")
                    );
                    String optionJson = optObj != null ? String.valueOf(optObj) : "{}";

                    Map<String, Object> itemParam = new HashMap<>();
                    itemParam.put("orderId",    orderId);
                    itemParam.put("productId",  productId);
                    itemParam.put("productNm",  productNm);
                    itemParam.put("qty",        qty);
                    itemParam.put("unitPrice",  unitPrice);
                    itemParam.put("discountAmt",discountAmt);
                    itemParam.put("lineAmt",    lineAmt);
                    itemParam.put("statusCd",   "NORMAL");
                    itemParam.put("optionJson", optionJson);
                    itemParam.put("useAt",      "Y");
                    itemParam.put("createdBy",  paramMap.get("createdBy"));
                    itemParam.put("updatedBy",  paramMap.get("updatedBy"));

                    orderItemService.insertOrderItem(itemParam);

                    Long cartItemId = firstNonNullLong(
                            row.get("cartItemId"),
                            row.get("CART_ITEM_ID")
                    );
                    if (cartItemId != null) {
                        cartService.deleteCartItem(userId, cartItemId);
                    }
                }
            }
        }
    }

    @Transactional
    public void updateOrder(Map<String, Object> paramMap) {
        dao.update(namespace + ".updateOrder", paramMap);
    }

    @Transactional
    public void deleteOrder(Map<String, Object> paramMap) {
        dao.delete(namespace + ".deleteOrder", paramMap);
    }

    // =======================
    //  주문 취소 (TOSS 연동 포함)
    // =======================
    @Transactional
    public void cancelOrder(Map<String, Object> paramMap) {
        if (paramMap == null) {
            throw new IllegalArgumentException("paramMap is null");
        }

        Long orderId = firstNonNullLong(
                paramMap.get("orderId"),
                paramMap.get("orderIdx")
        );
        if (orderId == null) {
            throw new IllegalArgumentException("orderId/orderIdx 가 필요합니다.");
        }

        Map<String, Object> findParam = new HashMap<>();
        findParam.put("orderId", orderId);

        Map<String, Object> order = dao.selectOne(namespace + ".selectOrderForCancel", findParam);
        if (order == null) {
            throw new IllegalStateException("주문을 찾을 수 없습니다. orderId=" + orderId);
        }

        String orderStatusCd = asString(firstNonNull(order.get("orderStatusCd"), order.get("ORDER_STATUS_CD")));
        String payStatusCd   = asString(firstNonNull(order.get("payStatusCd"),   order.get("PAY_STATUS_CD")));
        String payMethodCd   = asString(firstNonNull(order.get("payMethodCd"),   order.get("PAY_METHOD_CD")));
        String useAt         = asString(firstNonNull(order.get("useAt"),         order.get("USE_AT")));

        if (!"Y".equalsIgnoreCase(useAt)) {
            throw new IllegalStateException("이미 삭제되었거나 사용안함 상태의 주문입니다.");
        }

        if ("ORDER_CANCEL".equals(orderStatusCd)) {
            throw new IllegalStateException("이미 취소된 주문입니다.");
        }

        Long userId = firstNonNullLong(order.get("userId"), order.get("USER_ID"));
        String orderNo = asString(firstNonNull(order.get("orderNo"), order.get("ORDER_NO")));

        String actor = asString(firstNonNull(
                paramMap.get("updatedBy"),
                paramMap.get("createdBy"),
                order.get("UPDATED_BY"),
                order.get("CREATED_BY")
        ));

        String cancelReason = asString(firstNonNull(paramMap.get("cancelReason"), paramMap.get("reason")));
        if (cancelReason.trim().isEmpty()) {
            cancelReason = "사용자 요청";
        }

        BigDecimal pointUseAmt  = firstNonZeroBigDecimal(order.get("pointUseAmt"),  order.get("POINT_USE_AMT"));
        BigDecimal pointSaveAmt = firstNonZeroBigDecimal(order.get("pointSaveAmt"), order.get("POINT_SAVE_AMT"));
        BigDecimal payAmt       = firstNonZeroBigDecimal(order.get("payAmt"),       order.get("PAY_AMT"));

        if (log.isDebugEnabled()) {
            log.debug(
                    "cancelOrder - orderId=" + orderId
                            + ", orderNo=" + orderNo
                            + ", statusCd=" + orderStatusCd
                            + ", payStatusCd=" + payStatusCd
                            + ", payMethodCd=" + payMethodCd
                            + ", pointUseAmt=" + pointUseAmt
                            + ", pointSaveAmt=" + pointSaveAmt
                            + ", payAmt=" + payAmt
            );
        }

        boolean tossPath = "TOSS".equalsIgnoreCase(payMethodCd);

        // 1) 결제 취소(토스면 PG 취소 호출)
        if ("PAY_DONE".equals(payStatusCd)) {
            if (tossPath) {
                Map<String, Object> tossBody = new HashMap<>();
                tossBody.put("orderId", orderId);
                tossBody.put("orderIdx", orderId);
                tossBody.put("cancelReason", cancelReason);

                Map<String, Object> tossRes;
                try {
                    tossRes = tossPayService.cancelTossPayment(tossBody);
                } catch (Exception e) {
                    throw new IllegalStateException("TOSS_CANCEL_EXCEPTION: " + e.getMessage(), e);
                }

                boolean ok = (tossRes != null) && Boolean.TRUE.equals(tossRes.get("ok"));
                if (!ok) {
                    String msg = tossRes == null ? "TOSS_CANCEL_FAILED" : String.valueOf(tossRes.get("message"));
                    throw new IllegalStateException(msg);
                }
            } else {
                // LOCAL/기타 PG는 기존 로직 유지
                paymentService.cancelPaymentByOrderId(orderId, actor);
            }
        }

        // 2) 포인트 롤백
        if (userId != null) {
            if (pointUseAmt.compareTo(BigDecimal.ZERO) > 0) {
                pointLedgerService.chargePoint(
                        userId,
                        actor,
                        pointUseAmt,
                        "주문 취소 포인트 환불 (" + orderNo + ")"
                );
            }

            if (pointSaveAmt.compareTo(BigDecimal.ZERO) > 0) {
                pointLedgerService.usePointForOrder(
                        userId,
                        actor,
                        pointSaveAmt,
                        orderId,
                        "주문 취소 포인트 적립 회수 (" + orderNo + ")"
                );
            }
        }

        // 3) 주문 상태 취소(토스 경로는 이미 업데이트 되었을 수도 있어서 updated==0을 실패로 보지 않음)
        Map<String, Object> upd = new HashMap<>();
        upd.put("orderId",  orderId);
        upd.put("updatedBy",actor);

        int updated = dao.update(namespace + ".updateOrderCancel", upd);
        if (updated <= 0 && !tossPath) {
            throw new IllegalStateException("주문 상태 업데이트에 실패했습니다. 이미 취소되었을 수 있습니다.");
        }
    }

    // =======================
    //  내부 유틸
    // =======================

    private String asString(Object o) {
        return o == null ? "" : String.valueOf(o);
    }

    private Long toLong(Object o) {
        if (o == null) {
            return null;
        }
        try {
            return Long.parseLong(String.valueOf(o));
        } catch (NumberFormatException e) {
            return null;
        }
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

    private int toInt(Object o, int defaultValue) {
        if (o == null) {
            return defaultValue;
        }
        try {
            return Integer.parseInt(String.valueOf(o));
        } catch (NumberFormatException e) {
            return defaultValue;
        }
    }

    @SuppressWarnings("unchecked")
    private List<Long> extractCartItemIds(Map<String, Object> paramMap) {
        List<Long> ids = new ArrayList<>();
        if (paramMap == null) {
            return ids;
        }

        Object raw = firstNonNull(
                paramMap.get("cartItemIds"),
                paramMap.get("cartIds"),
                paramMap.get("cartIdList"),
                paramMap.get("cartItemId"),
                paramMap.get("cartId")
        );

        if (raw == null) {
            return ids;
        }

        if (raw instanceof List<?>) {
            for (Object o : (List<?>) raw) {
                Long id = toLong(o);
                if (id != null) {
                    ids.add(id);
                }
            }
            return ids;
        }

        if (raw instanceof String) {
            String s = ((String) raw).trim();
            if (!s.isEmpty()) {
                String[] parts = s.split(",");
                for (String p : parts) {
                    String trimmed = p.trim();
                    if (trimmed.isEmpty()) {
                        continue;
                    }
                    Long id = toLong(trimmed);
                    if (id != null) {
                        ids.add(id);
                    }
                }
            }
            return ids;
        }

        Long single = toLong(raw);
        if (single != null) {
            ids.add(single);
        }

        return ids;
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

    private Long firstNonNullLong(Object... arr) {
        Object o = firstNonNull(arr);
        return toLong(o);
    }

    private String firstNonEmptyString(Object... arr) {
        if (arr == null) {
            return null;
        }
        for (Object o : arr) {
            if (o == null) {
                continue;
            }
            String s = String.valueOf(o);
            if (!s.isEmpty()) {
                return s;
            }
        }
        return null;
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
