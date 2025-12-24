package www.api.pay.toss.service;

import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.math.BigDecimal;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.*;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.fasterxml.jackson.databind.ObjectMapper;

import www.api.cop.couponUser.service.CouponUserService;
import www.api.ord.orderItem.service.OrderItemService;
import www.api.plg.pointLedger.service.PointLedgerService;
import www.api.crt.cart.service.CartService;
import www.com.user.service.UserSessionManager;
import www.com.util.CommonDao;

@Service
public class TossPayService {

    @Autowired
    private CommonDao dao;

    @Autowired
    private OrderItemService orderItemService;

    @Autowired
    private CartService cartService;

    @Autowired
    private PointLedgerService pointLedgerService;

    @Autowired
    private CouponUserService couponUserService;

    private final ObjectMapper om = new ObjectMapper();

    // 토스 시크릿키는 서버에서만
    @Value("#{ConfigProperties['toss.payments.secretKey']}")
    private String tossSecretKey;

    private final String orderNs = "www.api.ord.order.Order";
    private final String tossNs = "www.api.pay.toss.TossPay";

    @Transactional
    public Map<String, Object> prepareTossOrder(Map<String, Object> body) throws Exception {
        if (!UserSessionManager.isUserLogined()) {
            throw new IllegalStateException("LOGIN_REQUIRED");
        }

        String actor = UserSessionManager.getLoginUserVO().getUserId();
        Long userId = toLong(UserSessionManager.getLoginUserVO().getUserId());
        if (userId == null) {
            // USER_ID가 문자열인 경우 대비(프로젝트마다 타입이 다를 수 있음)
        }

        List<Long> cartItemIds = resolveIds(firstNonNull(body.get("cartItemIds"), body.get("cartIds")));
        if (cartItemIds.isEmpty()) {
            throw new IllegalArgumentException("EMPTY_CART_ITEM_IDS");
        }

        String orderNo = makeOrderNo();
        String orderName = asString(body.get("orderName"));
        if (orderName.isEmpty()) {
            orderName = "CONNECT 주문 결제";
        }

        BigDecimal totalProductAmt = toBigDecimal(body.get("totalProductAmt"));
        BigDecimal deliveryAmt = toBigDecimal(body.get("deliveryAmt"));
        BigDecimal orderAmt = toBigDecimal(body.get("orderAmt"));
        BigDecimal pointUseAmt = toBigDecimal(body.get("pointUseAmt"));
        BigDecimal pointSaveAmt = toBigDecimal(body.get("pointSaveAmt"));
        BigDecimal couponUseAmt = toBigDecimal(body.get("couponUseAmt"));
        BigDecimal payAmt = toBigDecimal(body.get("payAmt"));

        if (payAmt.compareTo(BigDecimal.ZERO) <= 0) {
            throw new IllegalArgumentException("INVALID_PAY_AMT");
        }

        // 주문 마스터 생성(PAY_READY)
        Map<String, Object> orderParam = new HashMap<>();
        orderParam.put("orderNo", orderNo);

        // USER_ID 타입이 프로젝트마다 달라서 문자열로 세팅(기존 코드 유지)
        orderParam.put("userId", UserSessionManager.getLoginUserVO().getUserId());

        orderParam.put("orderStatusCd", "ORDER_READY");
        orderParam.put("payStatusCd", "PAY_READY");
        orderParam.put("payMethodCd", "TOSS");

        orderParam.put("totalProductAmt", totalProductAmt);
        orderParam.put("totalDiscountAmt", BigDecimal.ZERO);
        orderParam.put("deliveryAmt", deliveryAmt);

        orderParam.put("orderAmt", orderAmt);
        orderParam.put("pointUseAmt", pointUseAmt);
        orderParam.put("pointSaveAmt", pointSaveAmt);
        orderParam.put("couponUseAmt", couponUseAmt);
        orderParam.put("payAmt", payAmt);

        orderParam.put("receiverNm", asString(body.get("receiverNm")));
        orderParam.put("receiverPhone", asString(body.get("receiverPhone")));
        orderParam.put("zipCode", asString(body.get("zipCode")));
        orderParam.put("addr1", asString(body.get("addr1")));
        orderParam.put("addr2", asString(body.get("addr2")));
        orderParam.put("deliveryMemo", asString(body.get("deliveryMemo")));

        orderParam.put("useAt", "Y");
        orderParam.put("createdBy", actor);
        orderParam.put("updatedBy", actor);

        dao.insert(orderNs + ".insertOrder", orderParam);

        Long orderId = toLong(orderParam.get("orderId"));
        if (orderId == null) {
            throw new IllegalStateException("ORDER_ID_NOT_GENERATED");
        }

        // 주문상품 생성(카트 기반) - 카트 삭제는 결제 성공 confirm 후에
        insertOrderItemsFromCart(orderId, actor, cartItemIds);

        // 결제(PAY_READY) 생성 + rawRequestJson에 후처리 정보 저장(추가 테이블 필요 없음)
        Map<String, Object> rawReq = new HashMap<>();
        rawReq.put("cartItemIds", cartItemIds);
        if (body.get("couponUserId") != null) {
            rawReq.put("couponUserId", toLong(body.get("couponUserId")));
        }
        rawReq.put("orderName", orderName);

        Map<String, Object> payParam = new HashMap<>();
        payParam.put("orderId", orderId);
        payParam.put("pgCd", "TOSS");
        payParam.put("pgMid", "TOSS");
        payParam.put("pgTid", null);
        payParam.put("payMethodCd", "TOSS");
        payParam.put("payTotalAmt", orderAmt);
        payParam.put("payApprovedAmt", BigDecimal.ZERO);
        payParam.put("payStatusCd", "PAY_READY");
        payParam.put("rawRequestJson", om.writeValueAsString(rawReq));
        payParam.put("rawResponseJson", "{}");
        payParam.put("useAt", "Y");
        payParam.put("createdBy", actor);
        payParam.put("updatedBy", actor);

        dao.insert(tossNs + ".insertTossPaymentPending", payParam);

        // 토스 결제창용 customerKey(유저 고정키)
        String customerKey = "U_" + UserSessionManager.getLoginUserVO().getUserId();

        Map<String, Object> result = new HashMap<>();
        result.put("orderId", orderId);
        result.put("orderNo", orderNo);
        result.put("amount", payAmt);
        result.put("orderName", orderName);
        result.put("customerKey", customerKey);

        return result;
    }

    @Transactional
    public Map<String, Object> confirmFromRedirect(String paymentKey, String orderNo, String amountStr) throws Exception {
        Map<String, Object> out = new HashMap<>();
        out.put("ok", false);

        if (!UserSessionManager.isUserLogined()) {
            out.put("code", "LOGIN_REQUIRED");
            out.put("message", "login required");
            return out;
        }

        BigDecimal amount = toBigDecimal(amountStr);
        if (amount.compareTo(BigDecimal.ZERO) <= 0) {
            out.put("code", "INVALID_AMOUNT");
            out.put("message", "invalid amount");
            return out;
        }

        // orderNo 로 주문 조회
        Map<String, Object> find = new HashMap<>();
        find.put("orderNo", orderNo);

        Map<String, Object> orderRow = dao.selectOne(orderNs + ".selectOrderByOrderNo", find);
        if (orderRow == null) {
            out.put("code", "ORDER_NOT_FOUND");
            out.put("message", "order not found");
            return out;
        }

        Long orderId = firstNonNullLong(
            orderRow.get("orderId"),
            orderRow.get("ORDER_ID"),
            orderRow.get("orderIdx"),
            orderRow.get("ORDER_IDX")
        );

        if (orderId == null) {
            out.put("code", "ORDER_ID_MISSING");
            out.put("message", "orderId missing");
            return out;
        }

        BigDecimal expectedPayAmt = toBigDecimal(firstNonNull(orderRow.get("payAmt"), orderRow.get("PAY_AMT")));
        if (expectedPayAmt.compareTo(amount) != 0) {
            out.put("code", "AMOUNT_MISMATCH");
            out.put("message", "expected=" + expectedPayAmt + ", got=" + amount);
            return out;
        }

        String actor = UserSessionManager.getLoginUserVO().getUserId();

        // 결제(PAY_READY) 조회 → rawRequestJson에서 cartItemIds/couponUserId 복원
        Map<String, Object> pay = new HashMap<>();
        pay.put("orderId", orderId);

        Map<String, Object> paymentRow = dao.selectOne(tossNs + ".selectLatestPaymentByOrderId", pay);
        if (paymentRow == null) {
            out.put("code", "PAYMENT_NOT_FOUND");
            out.put("message", "payment not found");
            return out;
        }

        String rawReqJson = asString(firstNonNull(paymentRow.get("rawRequestJson"), paymentRow.get("RAW_REQUEST_JSON")));
        Map<String, Object> rawReq = parseJsonToMap(rawReqJson);

        List<Long> cartItemIds = new ArrayList<>();
        Object idsObj = rawReq.get("cartItemIds");
        if (idsObj instanceof List<?>) {
            for (Object o : (List<?>) idsObj) {
                Long id = toLong(o);
                if (id != null) cartItemIds.add(id);
            }
        }

        Long couponUserId = toLong(rawReq.get("couponUserId"));

        // 토스 confirm 호출(실패 시 예외)
        String confirmResJson = confirmToss(paymentKey, orderNo, amount);

        // 결제/주문 상태 반영 (최신 결제 1건만 업데이트하도록 XML에서 처리)
        Map<String, Object> updPay = new HashMap<>();
        updPay.put("orderId", orderId);
        updPay.put("pgTid", paymentKey);
        updPay.put("payApprovedAmt", amount);
        updPay.put("payStatusCd", "PAY_DONE");
        updPay.put("rawResponseJson", confirmResJson);
        updPay.put("updatedBy", actor);
        dao.update(tossNs + ".updateTossPaymentApproved", updPay);

        Map<String, Object> updOrder = new HashMap<>();
        updOrder.put("orderId", orderId);
        updOrder.put("orderStatusCd", "ORDER_DONE");
        updOrder.put("payStatusCd", "PAY_DONE");
        updOrder.put("payMethodCd", "TOSS");
        updOrder.put("updatedBy", actor);
        dao.update(tossNs + ".updateOrderAfterTossApproved", updOrder);

        // 포인트/쿠폰 후처리(결제 성공한 뒤에만)
        Long orderUserId = toLong(firstNonNull(orderRow.get("userId"), orderRow.get("USER_ID")));
        BigDecimal pointUseAmt = toBigDecimal(firstNonNull(orderRow.get("pointUseAmt"), orderRow.get("POINT_USE_AMT")));
        BigDecimal pointSaveAmt = toBigDecimal(firstNonNull(orderRow.get("pointSaveAmt"), orderRow.get("POINT_SAVE_AMT")));
        BigDecimal couponUseAmt = toBigDecimal(firstNonNull(orderRow.get("couponUseAmt"), orderRow.get("COUPON_USE_AMT")));
        BigDecimal totalAmt = toBigDecimal(firstNonNull(orderRow.get("orderAmt"), orderRow.get("ORDER_AMT")));

        if (orderUserId != null) {
            if (pointUseAmt.compareTo(BigDecimal.ZERO) > 0) {
                pointLedgerService.usePointForOrder(
                    orderUserId,
                    actor,
                    pointUseAmt,
                    orderId,
                    "토스 결제 + 포인트 사용 (" + orderNo + ")"
                );
            }

            if (pointSaveAmt.compareTo(BigDecimal.ZERO) > 0) {
                pointLedgerService.chargePoint(
                    orderUserId,
                    actor,
                    pointSaveAmt,
                    "토스 결제 포인트 적립 (" + orderNo + ")"
                );
            }
        }

        if (couponUserId != null && couponUseAmt.compareTo(BigDecimal.ZERO) > 0) {
            couponUserService.updateCouponAsUsed(couponUserId, orderId, actor);
        }

        // 카트 삭제(결제 성공 confirm 후)
        if (orderUserId != null && !cartItemIds.isEmpty()) {
            for (Long cartItemId : cartItemIds) {
                if (cartItemId == null) continue;
                cartService.deleteCartItem(orderUserId, cartItemId);
            }
        }

        out.put("ok", true);
        out.put("orderNo", orderNo);
        out.put("totalAmt", totalAmt);
        out.put("payAmt", amount);
        out.put("pointUseAmt", pointUseAmt);
        out.put("couponUseAmt", couponUseAmt);

        return out;
    }

    /**
     * 토스 결제 취소:
     * - orderNo 또는 orderId로 최신 결제 조회
     * - paymentKey(PG_TID)로 Toss cancel API 호출
     * - 성공 시 TB_PAYMENT(PAY_CANCEL), TB_ORDER(ORDER_CANCEL/PAY_CANCEL)
     *
     * body:
     *  - orderNo or orderId(또는 orderIdx)
     *  - cancelReason(옵션)
     */
    @Transactional
    public Map<String, Object> cancelTossPayment(Map<String, Object> body) throws Exception {
        Map<String, Object> out = new HashMap<>();
        out.put("ok", false);

        if (!UserSessionManager.isUserLogined()) {
            out.put("code", "LOGIN_REQUIRED");
            out.put("message", "login required");
            return out;
        }

        String actor = UserSessionManager.getLoginUserVO().getUserId();

        String orderNo = asString(body.get("orderNo"));
        Long orderId = toLong(firstNonNull(body.get("orderId"), body.get("orderIdx")));

        Map<String, Object> orderRow = null;

        if (!orderNo.isEmpty()) {
            Map<String, Object> find = new HashMap<>();
            find.put("orderNo", orderNo);
            orderRow = dao.selectOne(orderNs + ".selectOrderByOrderNo", find);
            if (orderRow == null) {
                out.put("code", "ORDER_NOT_FOUND");
                out.put("message", "order not found");
                return out;
            }
            orderId = firstNonNullLong(
                orderRow.get("orderId"),
                orderRow.get("ORDER_ID"),
                orderRow.get("orderIdx"),
                orderRow.get("ORDER_IDX")
            );
        } else if (orderId != null) {
            Map<String, Object> find = new HashMap<>();
            find.put("orderId", orderId);
            find.put("orderIdx", orderId);
            orderRow = dao.selectOne(orderNs + ".selectOrderDetail", find);
            if (orderRow == null) {
                out.put("code", "ORDER_NOT_FOUND");
                out.put("message", "order not found");
                return out;
            }
        } else {
            out.put("code", "INVALID_PARAM");
            out.put("message", "orderNo or orderId required");
            return out;
        }

        if (orderId == null) {
            out.put("code", "ORDER_ID_MISSING");
            out.put("message", "orderId missing");
            return out;
        }

        String cancelReason = asString(body.get("cancelReason"));
        if (cancelReason.isEmpty()) {
            cancelReason = "사용자 요청";
        }

        // 최신 결제 조회
        Map<String, Object> payFind = new HashMap<>();
        payFind.put("orderId", orderId);

        Map<String, Object> paymentRow = dao.selectOne(tossNs + ".selectLatestPaymentByOrderId", payFind);
        if (paymentRow == null) {
            out.put("code", "PAYMENT_NOT_FOUND");
            out.put("message", "payment not found");
            return out;
        }

        String pgCd = asString(firstNonNull(paymentRow.get("PG_CD"), paymentRow.get("pgCd")));
        String payStatusCd = asString(firstNonNull(paymentRow.get("PAY_STATUS_CD"), paymentRow.get("payStatusCd")));
        String paymentKey = asString(firstNonNull(paymentRow.get("PG_TID"), paymentRow.get("pgTid")));
        BigDecimal approvedAmt = toBigDecimal(firstNonNull(paymentRow.get("PAY_APPROVED_AMT"), paymentRow.get("payApprovedAmt")));
        String prevRawRes = asString(firstNonNull(paymentRow.get("RAW_RESPONSE_JSON"), paymentRow.get("rawResponseJson")));

        if (!"TOSS".equalsIgnoreCase(pgCd)) {
            out.put("code", "NOT_TOSS_PAYMENT");
            out.put("message", "pgCd is not TOSS");
            return out;
        }

        if (!"PAY_DONE".equals(payStatusCd)) {
            out.put("code", "INVALID_PAY_STATUS");
            out.put("message", "payStatusCd=" + payStatusCd);
            return out;
        }

        if (paymentKey.isEmpty()) {
            out.put("code", "PAYMENT_KEY_MISSING");
            out.put("message", "PG_TID(paymentKey) missing");
            return out;
        }

        // Toss cancel 호출
        String cancelResJson = cancelToss(paymentKey, cancelReason);

        // RAW_RESPONSE_JSON 기존 승인 응답도 보존(덮어쓰기 방지)
        Map<String, Object> merged = new HashMap<>();
        merged.put("approvedRaw", prevRawRes);
        merged.put("cancelReason", cancelReason);
        merged.put("cancelRaw", cancelResJson);
        String mergedRawRes = om.writeValueAsString(merged);

        // 결제 취소 업데이트(최신 결제 1건만 업데이트하도록 XML에서 처리)
        Map<String, Object> updPay = new HashMap<>();
        updPay.put("orderId", orderId);
        updPay.put("payStatusCd", "PAY_CANCEL");
        updPay.put("rawResponseJson", mergedRawRes);
        updPay.put("updatedBy", actor);
        dao.update(tossNs + ".updateTossPaymentCanceled", updPay);

        // 주문 상태 취소 업데이트
        Map<String, Object> updOrder = new HashMap<>();
        updOrder.put("orderId", orderId);
        updOrder.put("orderStatusCd", "ORDER_CANCEL");
        updOrder.put("payStatusCd", "PAY_CANCEL");
        updOrder.put("payMethodCd", "TOSS");
        updOrder.put("updatedBy", actor);
        dao.update(tossNs + ".updateOrderAfterTossCanceled", updOrder);

        out.put("ok", true);
        out.put("orderId", orderId);
        out.put("orderNo", !orderNo.isEmpty() ? orderNo : asString(firstNonNull(orderRow.get("orderNo"), orderRow.get("ORDER_NO"))));
        out.put("canceledAmt", approvedAmt);
        out.put("message", "canceled");
        return out;
    }

    private String confirmToss(String paymentKey, String orderId, BigDecimal amount) throws Exception {
        if (tossSecretKey == null || tossSecretKey.trim().isEmpty()) {
            throw new IllegalStateException("toss.payments.secretKey not set");
        }

        String endpoint = "https://api.tosspayments.com/v1/payments/confirm";
        URL url = new URL(endpoint);
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();

        String auth = Base64.getEncoder().encodeToString((tossSecretKey.trim() + ":").getBytes(StandardCharsets.UTF_8));

        conn.setRequestMethod("POST");
        conn.setConnectTimeout(5000);
        conn.setReadTimeout(15000);
        conn.setDoOutput(true);

        conn.setRequestProperty("Authorization", "Basic " + auth);
        conn.setRequestProperty("Content-Type", "application/json; charset=utf-8");

        Map<String, Object> body = new HashMap<>();
        body.put("paymentKey", paymentKey);
        body.put("orderId", orderId);
        body.put("amount", amount);

        String json = om.writeValueAsString(body);

        try (OutputStream os = conn.getOutputStream()) {
            os.write(json.getBytes(StandardCharsets.UTF_8));
        }

        int status = conn.getResponseCode();
        InputStream is = (status >= 200 && status < 300) ? conn.getInputStream() : conn.getErrorStream();
        String res = readAll(is);

        if (status < 200 || status >= 300) {
            throw new IllegalStateException("TOSS_CONFIRM_FAILED status=" + status + " body=" + res);
        }

        return res;
    }

    private String cancelToss(String paymentKey, String cancelReason) throws Exception {
        if (tossSecretKey == null || tossSecretKey.trim().isEmpty()) {
            throw new IllegalStateException("toss.payments.secretKey not set");
        }

        String pk = paymentKey == null ? "" : paymentKey.trim();
        if (pk.isEmpty()) {
            throw new IllegalArgumentException("paymentKey is empty");
        }

        String encodedPk;
        try {
            encodedPk = URLEncoder.encode(pk, "UTF-8");
        } catch (Exception e) {
            encodedPk = pk;
        }

        String endpoint = "https://api.tosspayments.com/v1/payments/" + encodedPk + "/cancel";
        URL url = new URL(endpoint);
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();

        String auth = Base64.getEncoder().encodeToString((tossSecretKey.trim() + ":").getBytes(StandardCharsets.UTF_8));

        conn.setRequestMethod("POST");
        conn.setConnectTimeout(5000);
        conn.setReadTimeout(15000);
        conn.setDoOutput(true);

        conn.setRequestProperty("Authorization", "Basic " + auth);
        conn.setRequestProperty("Content-Type", "application/json; charset=utf-8");
        conn.setRequestProperty("Idempotency-Key", UUID.randomUUID().toString());

        Map<String, Object> body = new HashMap<>();
        body.put("cancelReason", (cancelReason == null || cancelReason.trim().isEmpty()) ? "사용자 요청" : cancelReason.trim());

        String json = om.writeValueAsString(body);

        try (OutputStream os = conn.getOutputStream()) {
            os.write(json.getBytes(StandardCharsets.UTF_8));
        }

        int status = conn.getResponseCode();
        InputStream is = (status >= 200 && status < 300) ? conn.getInputStream() : conn.getErrorStream();
        String res = readAll(is);

        if (status < 200 || status >= 300) {
            throw new IllegalStateException("TOSS_CANCEL_FAILED status=" + status + " body=" + res);
        }

        return res;
    }

    private String readAll(InputStream is) throws Exception {
        if (is == null) return "";
        StringBuilder sb = new StringBuilder();
        try (BufferedReader br = new BufferedReader(new InputStreamReader(is, StandardCharsets.UTF_8))) {
            String line;
            while ((line = br.readLine()) != null) {
                sb.append(line);
            }
        }
        return sb.toString();
    }

    private void insertOrderItemsFromCart(Long orderId, String actor, List<Long> cartItemIds) {
        Map<String, Object> cartParam = new HashMap<>();
        cartParam.put("userId", UserSessionManager.getLoginUserVO().getUserId());
        cartParam.put("cartItemIds", cartItemIds);

        @SuppressWarnings("unchecked")
        List<Map<String, Object>> items =
            (List<Map<String, Object>>) (List<?>) dao.list(
                "www.api.crt.cartItem.CartItem.selectCartViewListByUser",
                cartParam
            );

        if (items == null || items.isEmpty()) {
            throw new IllegalStateException("CART_ITEMS_NOT_FOUND");
        }

        for (Map<String, Object> row : items) {
            Long productId = firstNonNullLong(row.get("productId"), row.get("PRODUCT_ID"));
            if (productId == null) continue;

            String productNm = firstNonEmptyString(
                row.get("productNm"),
                row.get("PRODUCT_NM"),
                row.get("title"),
                row.get("TITLE")
            );
            if (productNm == null || productNm.isEmpty()) {
                productNm = "(상품명 미지정)";
            }

            int qty = toInt(firstNonNull(row.get("qty"), row.get("QTY")), 1);
            if (qty <= 0) qty = 1;

            BigDecimal unitPrice = firstNonZeroBigDecimal(
                row.get("unitPrice"),
                row.get("UNIT_PRICE"),
                row.get("salePrice"),
                row.get("SALE_PRICE")
            );

            BigDecimal discountAmt = firstNonZeroBigDecimal(row.get("discountAmt"), row.get("DISCOUNT_AMT"));
            BigDecimal lineAmt = unitPrice.multiply(BigDecimal.valueOf(qty));

            String optionJson = "{}";
            Object optObj = firstNonNull(row.get("optionJson"), row.get("OPTION_JSON"));
            if (optObj != null) optionJson = String.valueOf(optObj);

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
            itemParam.put("createdBy", actor);
            itemParam.put("updatedBy", actor);

            orderItemService.insertOrderItem(itemParam);
        }
    }

    private Map<String, Object> parseJsonToMap(String json) {
        if (json == null || json.trim().isEmpty()) return new HashMap<>();
        try {
            @SuppressWarnings("unchecked")
            Map<String, Object> m = om.readValue(json, Map.class);
            return m == null ? new HashMap<>() : m;
        } catch (Exception e) {
            return new HashMap<>();
        }
    }

    private List<Long> resolveIds(Object raw) {
        List<Long> result = new ArrayList<>();
        if (raw == null) return result;

        if (raw instanceof List<?>) {
            for (Object o : (List<?>) raw) {
                Long id = toLong(o);
                if (id != null) result.add(id);
            }
            return result;
        }

        if (raw instanceof String) {
            String s = ((String) raw).trim();
            if (!s.isEmpty()) {
                String[] parts = s.split(",");
                for (String p : parts) {
                    Long id = toLong(p.trim());
                    if (id != null) result.add(id);
                }
            }
            return result;
        }

        Long single = toLong(raw);
        if (single != null) result.add(single);

        return result;
    }

    private String makeOrderNo() {
        Calendar c = Calendar.getInstance();
        int y = c.get(Calendar.YEAR);
        int m = c.get(Calendar.MONTH) + 1;
        int d = c.get(Calendar.DAY_OF_MONTH);
        int hh = c.get(Calendar.HOUR_OF_DAY);
        int mm = c.get(Calendar.MINUTE);
        int ss = c.get(Calendar.SECOND);
        int rand = (int) (Math.random() * 900) + 100;

        return "O"
            + y
            + pad2(m)
            + pad2(d)
            + pad2(hh)
            + pad2(mm)
            + pad2(ss)
            + rand;
    }

    private String pad2(int n) {
        return (n < 10) ? ("0" + n) : String.valueOf(n);
    }

    private String asString(Object o) {
        return o == null ? "" : String.valueOf(o).trim();
    }

    private Object firstNonNull(Object... arr) {
        if (arr == null) return null;
        for (Object o : arr) {
            if (o != null) return o;
        }
        return null;
    }

    private Long firstNonNullLong(Object... arr) {
        Object o = firstNonNull(arr);
        return toLong(o);
    }

    private String firstNonEmptyString(Object... arr) {
        if (arr == null) return null;
        for (Object o : arr) {
            if (o == null) continue;
            String s = String.valueOf(o);
            if (!s.isEmpty()) return s;
        }
        return null;
    }

    private Long toLong(Object o) {
        if (o == null) return null;
        try {
            return Long.parseLong(String.valueOf(o));
        } catch (Exception e) {
            return null;
        }
    }

    private int toInt(Object o, int def) {
        if (o == null) return def;
        try {
            return Integer.parseInt(String.valueOf(o));
        } catch (Exception e) {
            return def;
        }
    }

    private BigDecimal toBigDecimal(Object o) {
        if (o == null) return BigDecimal.ZERO;
        try {
            return new BigDecimal(String.valueOf(o));
        } catch (Exception e) {
            return BigDecimal.ZERO;
        }
    }

    private BigDecimal firstNonZeroBigDecimal(Object... arr) {
        if (arr == null) return BigDecimal.ZERO;
        for (Object o : arr) {
            BigDecimal v = toBigDecimal(o);
            if (v.compareTo(BigDecimal.ZERO) > 0) return v;
        }
        return BigDecimal.ZERO;
    }
}
