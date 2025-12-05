package www.api.crt.cartItem.service;

import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import www.com.util.CommonDao;

@Service
public class CartItemService {

    private final String namespace = "www.api.crt.cartItem.CartItem";

    @Autowired
    private CommonDao dao;

    /**
     * 템플릿 목록 조회
     */
    public List<Map<String, Object>> selectCartItemList(Map<String, Object> paramMap) {
        return dao.list(namespace + ".selectCartItemList", paramMap);
    }

    /**
     * 템플릿 목록 수 조회
     */
    public int selectCartItemListCount(Map<String, Object> paramMap) {
        Map<String, Object> resultMap = dao.selectOne(namespace + ".selectCartItemListCount", paramMap);
        if (resultMap != null && resultMap.get("cnt") != null) {
            return Integer.parseInt(resultMap.get("cnt").toString());
        }
        return 0;
    }

    /**
     * 템플릿 단건 조회
     */
    public Map<String, Object> selectCartItemDetail(Map<String, Object> paramMap) {
        return dao.selectOne(namespace + ".selectCartItemDetail", paramMap);
    }

    /**
     * 템플릿 등록
     */
    @Transactional
    public void insertCartItem(Map<String, Object> paramMap) {
        dao.insert(namespace + ".insertCartItem", paramMap);
    }

    /**
     * 템플릿 수정
     */
    @Transactional
    public void updateCartItem(Map<String, Object> paramMap) {
        dao.update(namespace + ".updateCartItem", paramMap);
    }

    /**
     * 템플릿 삭제
     */
    @Transactional
    public void deleteCartItem(Map<String, Object> paramMap) {
        dao.delete(namespace + ".deleteCartItem", paramMap);
    }
}
