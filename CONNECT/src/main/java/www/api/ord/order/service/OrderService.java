// filepath: src/main/java/www/api/ord/order/service/OrderService.java
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

import www.api.crt.cart.service.CartService;
import www.api.ord.orderItem.service.OrderItemService;
import www.api.pay.payment.service.PaymentService;
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
    private PointLedgerService pointLedgerService;

    // 장바구니 → 주문상품 생성에 사용
    @Autowired
    private CartService cartService;

    @Autowired
    private OrderItemService orderItemService;

    /**
     * 주문 목록 조회
     */
    public List<Map<String, Object>> selectOrderList(Map<String, Object> paramMap) {
        return dao.list(namespace + ".selectOrderList", paramMap);
    }

    /**
     * 주문 목록 수 조회
     */
    public int selectOrderListCount(Map<String, Object> paramMap) {
        Map<String, Object> resultMap = dao.selectOne(namespace + ".selectOrderListCount", paramMap);
        if (resultMap != null && resultMap.get("cnt") != null) {
            return Integer.parseInt(resultMap.get("cnt").toString());
        }
        return 0;
    }

    /**
     * 주문 단건 조회
     */
    public Map<String, Object> selectOrderDetail(Map<String, Object> paramMap) {
        return dao.selectOne(namespace + ".selectOrderDetail", paramMap);
    }

    /**
     * 기본 주문 등록 (단독 사용 시)
     */
    @Transactional
    public void insertOrder(Map<String, Object> paramMap) {
        dao.insert(namespace + ".insertOrder", paramMap);
    }

    /**
     * 주문 + 결제 + 포인트 + 장바구니 → 주문상품
     */
    @Transactional
    public void insertOrderWithPayAndPoint(Map<String, Object> paramMap) {

        if (log.isDebugEnabled()) {
            log.debug("insertOrderWithPayAndPoint() 호출 - paramMap keys = {}", paramMap.keySet());
            log.debug("insertOrderWithPayAndPoint() raw.cartItemIds = {}", paramMap.get("cartItemIds"));
            log.debug("insertOrderWithPayAndPoint() raw.cartIds     = {}", paramMap.get("cartIds"));
            log.debug("insertOrderWithPayAndPoint() raw.cartIdList  = {}", paramMap.get("cartIdList"));
            log.debug("insertOrderWithPayAndPoint() raw.cartItemId  = {}", paramMap.get("cartItemId"));
        }

        // ==========================
        // 1) 주문 마스터 저장
        // ==========================
        dao.insert(namespace + ".insertOrder", paramMap);

        // 프런트에서 넘겨주는 주문번호(orderNo 기준)
        String orderNo = asString(firstNonNull(paramMap.get("orderNo"), paramMap.get("ORDER_NO")));

        Map<String, Object> findParam = new HashMap<>();
        findParam.put("orderNo", orderNo);

        Map<String, Object> orderRow = dao.selectOne(namespace + ".selectOrderByOrderNo", findParam);
        if (orderRow == null) {
            throw new IllegalStateException("주문 번호로 주문을 찾을 수 없습니다. orderNo=" + orderNo);
        }

        // 컬럼 키가 alias / 대소문자 섞여 있을 수 있으니 여러 키로 방어
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

        // ==========================
        // 2) 결제 저장 (TB_PAYMENT)
        // ==========================
        BigDecimal orderAmt = toBigDecimal(firstNonNull(paramMap.get("orderAmt"), paramMap.get("ORDER_AMT")));
        BigDecimal payAmt   = toBigDecimal(firstNonNull(paramMap.get("payAmt"),   paramMap.get("PAY_AMT")));

        Map<String, Object> payParam = new HashMap<>();
        payParam.put("orderId", orderId);
        payParam.put("pgCd", "LOCAL");                   // 내부 테스트 PG
        payParam.put("pgMid", "LOCAL");                  // 가맹점 ID
        payParam.put("pgTid", orderNo);                  // 트랜잭션 ID = 주문번호
        payParam.put("payMethodCd", paramMap.get("payMethodCd"));
        payParam.put("payTotalAmt", orderAmt);           // 총 결제 대상 금액
        payParam.put("payApprovedAmt", payAmt);          // 실제 결제 금액
        payParam.put("payStatusCd", paramMap.get("payStatusCd"));
        payParam.put("reqDt", null);                     // mapper 에서 NOW()
        payParam.put("resDt", null);
        payParam.put("rawRequestJson", "{}");
        payParam.put("rawResponseJson", "{}");
        payParam.put("useAt", "Y");
        payParam.put("createdBy", paramMap.get("createdBy"));
        payParam.put("updatedBy", paramMap.get("updatedBy"));

        paymentService.insertPayment(payParam);

        // ==========================
        // 3) 포인트 사용/적립
        // ==========================
        Long userId = toLong(firstNonNull(paramMap.get("userId"), paramMap.get("USER_ID")));
        String actor = asString(firstNonNull(paramMap.get("createdBy"), paramMap.get("CREATED_BY")));

        BigDecimal pointUseAmt  = toBigDecimal(firstNonNull(paramMap.get("pointUseAmt"),  paramMap.get("POINT_USE_AMT")));
        BigDecimal pointSaveAmt = toBigDecimal(firstNonNull(paramMap.get("pointSaveAmt"), paramMap.get("POINT_SAVE_AMT")));

        if (userId != null) {

            // 포인트 사용(차감)
            if (pointUseAmt.compareTo(BigDecimal.ZERO) > 0) {
                pointLedgerService.usePointForOrder(
                    userId,
                    actor,
                    pointUseAmt,
                    orderId,
                    "주문 포인트 사용 (" + orderNo + ")"
                );
            }

            // 포인트 적립(충전)
            if (pointSaveAmt.compareTo(BigDecimal.ZERO) > 0) {
                // 기존 구현처럼 ORDER_ID 없이 적립
                pointLedgerService.chargePoint(
                    userId,
                    actor,
                    pointSaveAmt,
                    "주문 포인트 적립 (" + orderNo + ")"
                );
            }
        }

        // ==========================
        // 4) 장바구니 → 주문상품(TB_ORDER_ITEM)
        // ==========================

        // 주문 화면에서 넘어온 선택 장바구니 ID 목록
        // 지원 키:
        //  - cartItemIds (List, "1,2,3", 단일 값)
        //  - cartIds
        //  - cartIdList
        //  - cartItemId / cartId (단일 값)
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
            cartParam.put("userId", userId);
            cartParam.put("cartItemIds", cartItemIds); // 무조건 선택 항목만

            @SuppressWarnings("unchecked")
            List<Map<String, Object>> items =
                (List<Map<String, Object>>) (List<?>) dao.list(
                    "www.api.crt.cartItem.CartItem.selectCartViewListByUser",
                    cartParam
                );

            if (log.isDebugEnabled()) {
                log.debug("선택된 장바구니 조회 결과 건수 = {}", (items == null ? 0 : items.size()));
            }

            if (items != null && !items.isEmpty()) {
                for (Map<String, Object> row : items) {

                    Long productId = firstNonNullLong(
                        row.get("productId"),
                        row.get("PRODUCT_ID")
                    );
                    if (productId == null) {
                        // 상품 ID 없으면 스킵
                        continue;
                    }

                    // 상품명: productNm / PRODUCT_NM / title / TITLE 중 첫 번째
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

                    // 주문상품 파라미터
                    Map<String, Object> itemParam = new HashMap<>();
                    itemParam.put("orderId", orderId);
                    itemParam.put("productId", productId);
                    itemParam.put("productNm", productNm);
                    itemParam.put("qty", qty);
                    itemParam.put("unitPrice", unitPrice);
                    itemParam.put("discountAmt", discountAmt);
                    itemParam.put("lineAmt", lineAmt);
                    itemParam.put("statusCd", "NORMAL");
                    itemParam.put("optionJson", optionJson);
                    itemParam.put("useAt", "Y");
                    itemParam.put("createdBy", paramMap.get("createdBy"));
                    itemParam.put("updatedBy", paramMap.get("updatedBy"));

                    // TB_ORDER_ITEM INSERT
                    orderItemService.insertOrderItem(itemParam);

                    // 장바구니 항목 소프트 삭제
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

        // 여기까지 Tx 안에서:
        // - TB_ORDER: 1건
        // - TB_PAYMENT: 1건
        // - TB_POINT_LEDGER: USE/CHARGE
        // - TB_ORDER_ITEM: 선택한 장바구니 수 만큼
        // - TB_CART_ITEM: 해당 항목 USE_AT='N'
    }

    /**
     * 주문 수정
     */
    @Transactional
    public void updateOrder(Map<String, Object> paramMap) {
        dao.update(namespace + ".updateOrder", paramMap);
    }

    /**
     * 주문 삭제(soft delete)
     */
    @Transactional
    public void deleteOrder(Map<String, Object> paramMap) {
        dao.delete(namespace + ".deleteOrder", paramMap);
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

    /**
     * 장바구니 ID 추출
     *
     * 지원 키:
     * - cartItemIds : [1,2,3] 또는 "1,2,3" 또는 "1"
     * - cartIds     : [1,2,3] 또는 "1,2,3"
     * - cartIdList  : [1,2,3]
     * - cartItemId  : 단일 값
     * - cartId      : 단일 값
     */
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

        // List 형태: [1, "2", 3L ...]
        if (raw instanceof List<?>) {
            for (Object o : (List<?>) raw) {
                Long id = toLong(o);
                if (id != null) {
                    ids.add(id);
                }
            }
            return ids;
        }

        // 문자열: "1,2,3" 또는 "1"
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

        // 그 외 단일 값 (숫자 등)
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
