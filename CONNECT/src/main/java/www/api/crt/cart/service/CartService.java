package www.api.crt.cart.service;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import www.com.util.CommonDao;

@Service
public class CartService {

    private final String cartNs     = "www.api.crt.cart.Cart";
    private final String cartItemNs = "www.api.crt.cartItem.CartItem";

    @Autowired
    private CommonDao dao;

    // ======================
    // 0) 공통 헬퍼
    // ======================

    /**
     * Map에서 숫자 필드를 최대한 관대하게 읽어온다.
     * - 1차: 주어진 key로 직접 조회
     * - 2차: entry 전체를 스캔하면서 key.equalsIgnoreCase(...)
     * - 값이 String이면 BigDecimal로 파싱 시도
     */
    private Number getNumberField(Map<String, Object> row, String... candidates) {
        if (row == null || candidates == null) {
            return null;
        }

        // 1차: 그대로 키 조회
        for (String k : candidates) {
            if (k == null) continue;
            if (row.containsKey(k)) {
                Object v = row.get(k);
                if (v == null) continue;
                if (v instanceof Number) {
                    return (Number) v;
                }
                try {
                    return new BigDecimal(v.toString());
                } catch (Exception ignore) {
                }
            }
        }

        // 2차: 키 전체 스캔 + 대소문자 무시
        for (Map.Entry<String, Object> e : row.entrySet()) {
            String key = e.getKey();
            if (key == null) continue;

            for (String cand : candidates) {
                if (cand == null) continue;
                if (key.equalsIgnoreCase(cand)) {
                    Object v = e.getValue();
                    if (v == null) continue;
                    if (v instanceof Number) {
                        return (Number) v;
                    }
                    try {
                        return new BigDecimal(v.toString());
                    } catch (Exception ignore) {
                    }
                }
            }
        }

        return null;
    }

    private Long getLongField(Map<String, Object> row, String... candidates) {
        Number n = getNumberField(row, candidates);
        if (n == null) return null;
        return n.longValue();
    }

    // ======================
    // 1) 기존 Javagen CRUD
    // ======================

    public List<Map<String, Object>> selectCartList(Map<String, Object> paramMap) {
        return dao.list(cartNs + ".selectCartList", paramMap);
    }

    public int selectCartListCount(Map<String, Object> paramMap) {
        Map<String, Object> resultMap = dao.selectOne(cartNs + ".selectCartListCount", paramMap);
        if (resultMap != null && resultMap.get("cnt") != null) {
            return Integer.parseInt(resultMap.get("cnt").toString());
        }
        return 0;
    }

    public Map<String, Object> selectCartDetail(Map<String, Object> paramMap) {
        return dao.selectOne(cartNs + ".selectCartDetail", paramMap);
    }

    @Transactional
    public void insertCart(Map<String, Object> paramMap) {
        dao.insert(cartNs + ".insertCart", paramMap);
    }

    @Transactional
    public void updateCart(Map<String, Object> paramMap) {
        dao.update(cartNs + ".updateCart", paramMap);
    }

    @Transactional
    public void deleteCart(Map<String, Object> paramMap) {
        dao.delete(cartNs + ".deleteCart", paramMap);
    }

    // ========================================
    // 2) 쇼핑몰용 장바구니 비즈니스 로직
    // ========================================

    /**
     * 유저 장바구니에 상품 추가
     *
     * @return 최종 cartItemId (신규 추가 또는 수량 증가된 항목의 PK)
     */
    @Transactional
    public long addCartItem(long userId, long productId, int qty) {
        if (qty <= 0) {
            qty = 1;
        }

        // 1) ACTIVE 카트 조회
        Map<String, Object> cartParam = new HashMap<>();
        cartParam.put("userId", userId);

        Map<String, Object> cartRow =
            dao.selectOne(cartNs + ".selectActiveCartByUser", cartParam);

        Long cartId = getLongField(cartRow, "cartId", "CART_ID", "cart_id");

        // 2) 없으면 새 ACTIVE 카트 생성
        if (cartId == null) {
            Map<String, Object> newCart = new HashMap<>();
            newCart.put("userId", userId);
            newCart.put("createdBy", String.valueOf(userId));
            dao.insert(cartNs + ".insertActiveCart", newCart);

            Map<String, Object> cartRow2 =
                dao.selectOne(cartNs + ".selectActiveCartByUser", cartParam);
            cartId = getLongField(cartRow2, "cartId", "CART_ID", "cart_id");
            if (cartId == null) {
                throw new IllegalStateException("장바구니 생성에 실패했습니다.");
            }
        }

        // 3) 상품 정보 조회 (가격/배송비)
        Map<String, Object> productParam = new HashMap<>();
        productParam.put("productId", productId);
        Map<String, Object> product =
            dao.selectOne(cartItemNs + ".selectProductForCart", productParam);

        if (product == null) {
            throw new IllegalArgumentException("상품을 찾을 수 없습니다. productId=" + productId);
        }

        Number salePriceNum = getNumberField(product,
            "salePrice", "SALE_PRICE", "sale_price");
        long unitPrice = (salePriceNum != null) ? salePriceNum.longValue() : 0L;

        // 4) 이미 같은 상품이 카트에 있는지 확인
        Map<String, Object> itemParam = new HashMap<>();
        itemParam.put("cartId", cartId);
        itemParam.put("productId", productId);

        Map<String, Object> cartItem =
            dao.selectOne(cartItemNs + ".selectCartItemByCartAndProduct", itemParam);

        if (cartItem == null) {
            // 신규 추가
            long lineAmt = unitPrice * qty;

            Map<String, Object> insertParam = new HashMap<>();
            insertParam.put("cartId", cartId);
            insertParam.put("productId", productId);
            insertParam.put("qty", qty);
            insertParam.put("unitPrice", unitPrice);
            insertParam.put("discountAmt", 0L);
            insertParam.put("lineAmt", lineAmt);
            insertParam.put("optionJson", "{}");
            insertParam.put("useAt", "Y");
            insertParam.put("createdBy", String.valueOf(userId));
            insertParam.put("updatedBy", String.valueOf(userId));

            dao.insert(cartItemNs + ".insertCartItem", insertParam);
        } else {
            // 기존 수량 + 추가
            Number oldQtyNum = getNumberField(cartItem,
                "qty", "QTY", "cartQty", "CART_QTY");
            int oldQty = (oldQtyNum != null) ? oldQtyNum.intValue() : 0;
            int newQty = oldQty + qty;
            if (newQty <= 0) {
                newQty = 1;
            }

            long lineAmt = unitPrice * newQty;

            Long cartItemId = getLongField(cartItem,
                "cartItemId", "CART_ITEM_ID", "cart_item_id");
            if (cartItemId == null) {
                throw new IllegalStateException(
                    "장바구니 항목 PK(cartItemId)를 확인할 수 없습니다. rowKeys=" + cartItem.keySet()
                );
            }

            Map<String, Object> updateParam = new HashMap<>();
            updateParam.put("cartItemId", cartItemId);
            updateParam.put("qty", newQty);
            updateParam.put("lineAmt", lineAmt);
            updateParam.put("updatedBy", String.valueOf(userId));

            dao.update(cartItemNs + ".updateCartItemQty", updateParam);
        }

        // 5) 최종 cartItemId 조회해서 리턴
        Map<String, Object> finalItem =
            dao.selectOne(cartItemNs + ".selectCartItemByCartAndProduct", itemParam);

        if (finalItem == null) {
            throw new IllegalStateException("장바구니 항목 조회에 실패했습니다.(row=null)");
        }

        Long finalId = getLongField(finalItem,
            "cartItemId", "CART_ITEM_ID", "cart_item_id");
        if (finalId == null) {
            throw new IllegalStateException(
                "장바구니 항목 조회에 실패했습니다.(PK null, rowKeys=" + finalItem.keySet() + ")"
            );
        }

        return finalId.longValue();
    }

    /**
     * 유저 장바구니 조회 (전체)
     *  - 내부적으로는 빈 리스트로 호출해서 "전체" 의미로 처리
     */
    public Map<String, Object> getCartView(long userId) {
        return getCartView(userId, new ArrayList<Long>());
    }

    /**
     * 유저 장바구니 조회 (선택된 cartItemId만)
     *
     * @param userId      사용자 PK
     * @param cartItemIds 선택 cartItemId 리스트 (null 또는 empty면 전체)
     */
    public Map<String, Object> getCartView(long userId, List<Long> cartItemIds) {
        Map<String, Object> param = new HashMap<>();
        param.put("userId", userId);

        @SuppressWarnings("unchecked")
        List<Map<String, Object>> allItems =
            (List<Map<String, Object>>) dao.list(cartItemNs + ".selectCartViewListByUser", param);

        List<Map<String, Object>> items = new ArrayList<>();

        if (cartItemIds == null || cartItemIds.isEmpty()) {
            // 전체 카트
            items.addAll(allItems);
        } else {
            // 선택된 cartItemId만 필터
            Set<Long> idSet = new HashSet<>(cartItemIds);
            for (Map<String, Object> row : allItems) {
                Long cartItemId = getLongField(row,
                    "cartItemId", "CART_ITEM_ID", "cart_item_id");
                if (cartItemId != null && idSet.contains(cartItemId)) {
                    items.add(row);
                }
            }
        }

        long productTotal = 0L;
        long shipTotal    = 0L;

        for (Map<String, Object> row : items) {
            Number unitPriceNum = getNumberField(row,
                "unitPrice", "UNIT_PRICE", "unit_price", "salePrice", "SALE_PRICE");
            Number qtyNum = getNumberField(row,
                "qty", "QTY", "cartQty", "CART_QTY");
            Number shipFeeNum = getNumberField(row,
                "shipFee", "SHIP_FEE", "ship_fee");

            long unitPrice = (unitPriceNum != null) ? unitPriceNum.longValue() : 0L;
            int qty        = (qtyNum != null)       ? qtyNum.intValue()         : 0;
            long shipFee   = (shipFeeNum != null)   ? shipFeeNum.longValue()    : 0L;

            productTotal += unitPrice * qty;
            shipTotal    += shipFee;
        }

        long totalAmt = productTotal + shipTotal;

        Map<String, Object> result = new HashMap<>();
        result.put("items", items);
        result.put("productTotal", productTotal);
        result.put("shipTotal", shipTotal);
        result.put("totalAmt", totalAmt);

        return result;
    }

    /**
     * 장바구니 수량 변경
     */
    @Transactional
    public void updateCartItemQty(long userId, long cartItemId, int qty) {
        if (qty <= 0) {
            qty = 1;
        }

        Map<String, Object> param = new HashMap<>();
        param.put("cartItemId", cartItemId);

        Map<String, Object> item =
            dao.selectOne(cartItemNs + ".selectCartItemSimpleById", param);

        if (item == null) {
            throw new IllegalArgumentException("장바구니 항목을 찾을 수 없습니다. cartItemId=" + cartItemId);
        }

        Number unitPriceNum = getNumberField(item,
            "unitPrice", "UNIT_PRICE", "unit_price", "salePrice", "SALE_PRICE");
        long unitPrice = (unitPriceNum != null) ? unitPriceNum.longValue() : 0L;
        long lineAmt   = unitPrice * qty;

        Map<String, Object> updateParam = new HashMap<>();
        updateParam.put("cartItemId", cartItemId);
        updateParam.put("qty", qty);
        updateParam.put("lineAmt", lineAmt);
        updateParam.put("updatedBy", String.valueOf(userId));

        dao.update(cartItemNs + ".updateCartItemQty", updateParam);
    }

    /**
     * 장바구니 항목 삭제 (USE_AT = 'N')
     */
    @Transactional
    public void deleteCartItem(long userId, long cartItemId) {
        Map<String, Object> param = new HashMap<>();
        param.put("cartItemId", cartItemId);
        param.put("updatedBy", String.valueOf(userId));

        dao.update(cartItemNs + ".softDeleteCartItem", param);
    }
}
