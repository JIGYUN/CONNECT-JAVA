package www.api.ord.orderItem.service;

import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import www.com.util.CommonDao;

@Service
public class OrderItemService {

    private final String namespace = "www.api.ord.orderItem.OrderItem";

    @Autowired
    private CommonDao dao;

    /**
     * 주문상품 목록 조회
     */
    public List<Map<String, Object>> selectOrderItemList(Map<String, Object> paramMap) {
        return dao.list(namespace + ".selectOrderItemList", paramMap);
    }

    /**
     * 주문상품 목록 수 조회
     */
    public int selectOrderItemListCount(Map<String, Object> paramMap) {
        Map<String, Object> resultMap = dao.selectOne(namespace + ".selectOrderItemListCount", paramMap);
        if (resultMap != null && resultMap.get("cnt") != null) {
            return Integer.parseInt(resultMap.get("cnt").toString());
        }
        return 0;
    }

    /**
     * 주문상품 단건 조회
     */
    public Map<String, Object> selectOrderItemDetail(Map<String, Object> paramMap) {
        return dao.selectOne(namespace + ".selectOrderItemDetail", paramMap);
    }

    /**
     * 주문상품 등록
     */
    @Transactional
    public void insertOrderItem(Map<String, Object> paramMap) {
        dao.insert(namespace + ".insertOrderItem", paramMap);
    }

    /**
     * 주문상품 수정
     */
    @Transactional
    public void updateOrderItem(Map<String, Object> paramMap) {
        dao.update(namespace + ".updateOrderItem", paramMap);
    }

    /**
     * 주문상품 삭제(soft delete)
     */
    @Transactional
    public void deleteOrderItem(Map<String, Object> paramMap) {
        dao.delete(namespace + ".deleteOrderItem", paramMap);
    }
}
