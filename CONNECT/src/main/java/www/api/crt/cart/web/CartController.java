package www.api.crt.cart.web;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import www.api.crt.cart.service.CartService;
import www.com.user.service.UserSessionManager;

@Controller
public class CartController {

    @Autowired
    private CartService cartService;

    /**
     * 로그인 유저 ID 추출
     *  - 앞으로 CREATED_BY / UPDATED_BY 에는 항상 이 userId 문자열을 사용
     */
    private Long getLoginUserId() {
        if (!UserSessionManager.isUserLogined()) {
            return null;
        }
        return Long.valueOf(UserSessionManager.getLoginUserVO().getUserId());
    }

    // =========================
    // 1) 기존 Javagen CRUD API
    // =========================

    /**
     * 카트 목록 조회 (관리자/테스트용)
     */
    @RequestMapping("/api/crt/cart/selectCartList")
    @ResponseBody
    public Map<String, Object> selectCartList(@RequestBody HashMap<String, Object> map) throws Exception {
        Map<String, Object> resultMap = new HashMap<>();
        List<Map<String, Object>> result = cartService.selectCartList(map);
        resultMap.put("msg", "성공");
        resultMap.put("result", result);
        return resultMap;
    }

    /**
     * 카트 단건 조회 (관리자/테스트용)
     */
    @RequestMapping("/api/crt/cart/selectCartDetail")
    @ResponseBody
    public Map<String, Object> selectCartDetail(@RequestBody HashMap<String, Object> map) throws Exception {
        Map<String, Object> resultMap = new HashMap<>();
        Map<String, Object> result = cartService.selectCartDetail(map);
        resultMap.put("msg", "성공");
        resultMap.put("result", result);
        return resultMap;
    }

    /**
     * 카트 등록 (관리자/테스트용)
     */
    @RequestMapping("/api/crt/cart/insertCart")
    @ResponseBody
    public Map<String, Object> insertCart(@RequestBody HashMap<String, Object> map) throws Exception {
        Map<String, Object> resultMap = new HashMap<>();
        cartService.insertCart(map);
        resultMap.put("msg", "등록 성공");
        return resultMap;
    }

    /**
     * 카트 수정 (관리자/테스트용)
     */
    @RequestMapping("/api/crt/cart/updateCart")
    @ResponseBody
    public Map<String, Object> updateCart(@RequestBody HashMap<String, Object> map) throws Exception {
        Map<String, Object> resultMap = new HashMap<>();
        cartService.updateCart(map);
        resultMap.put("msg", "수정 성공");
        return resultMap;
    }

    /**
     * 카트 삭제 (관리자/테스트용)
     */
    @RequestMapping("/api/crt/cart/deleteCart")
    @ResponseBody
    public Map<String, Object> deleteCart(@RequestBody HashMap<String, Object> map) throws Exception {
        Map<String, Object> resultMap = new HashMap<>();
        cartService.deleteCart(map);
        resultMap.put("msg", "삭제 성공");
        return resultMap;
    }

    /**
     * 카트 개수 (관리자/테스트용)
     */
    @RequestMapping("/api/crt/cart/selectCartListCount")
    @ResponseBody
    public Map<String, Object> selectCartListCount(@RequestBody HashMap<String, Object> map) throws Exception {
        Map<String, Object> resultMap = new HashMap<>();
        int count = cartService.selectCartListCount(map);
        resultMap.put("msg", "성공");
        resultMap.put("count", count);
        return resultMap;
    }

    // ==========================================
    // 2) 쇼핑몰 장바구니 API (실제 화면에서 사용하는 부분)
    // ==========================================

    /**
     * 장바구니 담기
     * body: { productId, qty }
     *
     * result:
     *  - msg: "성공"
     *  - result: "ADDED"
     *  - cartItemId: long (신규 또는 갱신된 CART_ITEM_ID)
     */
    @RequestMapping("/api/crt/cart/addItem")
    @ResponseBody
    public Map<String, Object> addItem(@RequestBody Map<String, Object> body) {
        Map<String, Object> res = new HashMap<>();

        Long userId = getLoginUserId();
        if (userId == null) {
            res.put("msg", "LOGIN_REQUIRED");
            return res;
        }

        Object pidObj = body.get("productId");
        Object qtyObj = body.get("qty");

        if (pidObj == null) {
            res.put("msg", "productId is required");
            return res;
        }

        long productId = Long.parseLong(String.valueOf(pidObj));
        int qty = 1;
        if (qtyObj != null) {
            qty = Integer.parseInt(String.valueOf(qtyObj));
        }

        long cartItemId = cartService.addCartItem(userId, productId, qty);

        res.put("msg", "성공");
        res.put("result", "ADDED");
        res.put("cartItemId", cartItemId);
        return res;
    }

    /**
     * 로그인 유저 장바구니 조회 (상품 정보 + 합계)
     *  - body.cartItemIds / body.cartIds 가 있으면 선택된 것만
     *  - 없으면 전체 장바구니
     *
     * 예)
     *  POST /api/crt/cart/selectCartView
     *  { "cartItemIds": [5,7] }
     */
    @RequestMapping("/api/crt/cart/selectCartView")
    @ResponseBody
    public Map<String, Object> selectCartView(@RequestBody(required = false) Map<String, Object> body) {
        Map<String, Object> res = new HashMap<>();

        Long userId = getLoginUserId();
        if (userId == null) {
            res.put("msg", "LOGIN_REQUIRED");
            return res;
        }

        // === 선택된 cartItemIds 파싱 ===
        List<Long> cartItemIds = new ArrayList<>();
        if (body != null) {
            Object idsObj = body.get("cartItemIds");
            if (!(idsObj instanceof List)) {
                // 다른 이름(cartIds)으로 오는 경우도 방어
                idsObj = body.get("cartIds");
            }
            if (idsObj instanceof List) {
                @SuppressWarnings("unchecked")
                List<Object> rawList = (List<Object>) idsObj;
                for (Object o : rawList) {
                    if (o == null) continue;
                    try {
                        long id = Long.parseLong(String.valueOf(o));
                        cartItemIds.add(id);
                    } catch (NumberFormatException ignore) {
                    }
                }
            }
        }

        Map<String, Object> view;
        if (cartItemIds.isEmpty()) {
            // 전체
            view = cartService.getCartView(userId);
        } else {
            // 선택된 항목만
            view = cartService.getCartView(userId, cartItemIds);
        }

        res.put("msg", "성공");
        res.put("result", view);
        return res;
    }

    /**
     * 장바구니 수량 변경
     * body: { cartItemId, qty }
     */
    @RequestMapping("/api/crt/cart/updateItemQty")
    @ResponseBody
    public Map<String, Object> updateItemQty(@RequestBody Map<String, Object> body) {
        Map<String, Object> res = new HashMap<>();

        Long userId = getLoginUserId();
        if (userId == null) {
            res.put("msg", "LOGIN_REQUIRED");
            return res;
        }

        Object idObj  = body.get("cartItemId");
        Object qtyObj = body.get("qty");

        if (idObj == null || qtyObj == null) {
            res.put("msg", "cartItemId, qty are required");
            return res;
        }

        long cartItemId = Long.parseLong(String.valueOf(idObj));
        int qty         = Integer.parseInt(String.valueOf(qtyObj));

        cartService.updateCartItemQty(userId, cartItemId, qty);

        res.put("msg", "성공");
        res.put("result", "UPDATED");
        return res;
    }

    /**
     * 장바구니 항목 삭제 (단건)
     * body: { cartItemId }
     */
    @RequestMapping("/api/crt/cart/deleteItem")
    @ResponseBody
    public Map<String, Object> deleteItem(@RequestBody Map<String, Object> body) {
        Map<String, Object> res = new HashMap<>();

        Long userId = getLoginUserId();
        if (userId == null) {
            res.put("msg", "LOGIN_REQUIRED");
            return res;
        }

        Object idObj = body.get("cartItemId");
        if (idObj == null) {
            res.put("msg", "cartItemId is required");
            return res;
        }

        long cartItemId = Long.parseLong(String.valueOf(idObj));
        cartService.deleteCartItem(userId, cartItemId);

        res.put("msg", "성공");
        res.put("result", "DELETED");
        return res;
    }

    /**
     * 장바구니 항목 삭제 (다건) – 선택 삭제용
     * body: { cartItemIds: [1,2,3] }
     */
    @RequestMapping("/api/crt/cart/deleteCartItems")
    @ResponseBody
    public Map<String, Object> deleteCartItems(@RequestBody Map<String, Object> body) {
        Map<String, Object> res = new HashMap<>();

        Long userId = getLoginUserId();
        if (userId == null) {
            res.put("msg", "LOGIN_REQUIRED");
            return res;
        }

        Object idsObj = body.get("cartItemIds");
        if (!(idsObj instanceof List)) {
            // cartIds 이름으로 보내는 경우도 방어
            idsObj = body.get("cartIds");
        }

        if (!(idsObj instanceof List)) {
            res.put("msg", "cartItemIds is required");
            return res;
        }

        @SuppressWarnings("unchecked")
        List<Object> rawList = (List<Object>) idsObj;
        List<Long> idList = new ArrayList<>();

        for (Object o : rawList) {
            if (o == null) continue;
            long id = Long.parseLong(String.valueOf(o));
            idList.add(id);
        }

        for (Long id : idList) {
            cartService.deleteCartItem(userId, id);
        }

        res.put("msg", "성공");
        res.put("result", "DELETED");
        return res;
    }
}
