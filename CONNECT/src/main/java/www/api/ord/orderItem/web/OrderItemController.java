package www.api.ord.orderItem.web;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

import www.api.ord.orderItem.service.OrderItemService;
import www.com.user.service.UserSessionManager;

@Controller
public class OrderItemController {

    @Autowired
    private OrderItemService orderItemService;

    /**
     * 주문상품 목록 조회
     */
    @RequestMapping("/api/ord/orderItem/selectOrderItemList")
    @ResponseBody
    public Map<String, Object> selectOrderItemList(@RequestBody HashMap<String, Object> map) throws Exception {
        Map<String, Object> resultMap = new HashMap<>();
        List<Map<String, Object>> result = orderItemService.selectOrderItemList(map);
        resultMap.put("ok", true);
        resultMap.put("msg", "성공");
        resultMap.put("result", result);
        return resultMap;
    }

    /**
     * 주문상품 단건 조회
     */
    @RequestMapping("/api/ord/orderItem/selectOrderItemDetail")
    @ResponseBody
    public Map<String, Object> selectOrderItemDetail(@RequestBody HashMap<String, Object> map) throws Exception {
        Map<String, Object> resultMap = new HashMap<>();
        Map<String, Object> result = orderItemService.selectOrderItemDetail(map);
        resultMap.put("ok", true);
        resultMap.put("msg", "성공");
        resultMap.put("result", result);
        return resultMap;
    }

    /**
     * 주문상품 등록
     */
    @RequestMapping("/api/ord/orderItem/insertOrderItem")
    @ResponseBody
    public Map<String, Object> insertOrderItem(@RequestBody HashMap<String, Object> map) throws Exception {
        if (UserSessionManager.isUserLogined()) {
            map.put("createUser", UserSessionManager.getLoginUserVO().getUserId());
        }
        Map<String, Object> resultMap = new HashMap<>();
        orderItemService.insertOrderItem(map);
        resultMap.put("ok", true);
        resultMap.put("msg", "등록 성공");
        return resultMap;
    }

    /**
     * 주문상품 수정
     */
    @RequestMapping("/api/ord/orderItem/updateOrderItem")
    @ResponseBody
    public Map<String, Object> updateOrderItem(@RequestBody HashMap<String, Object> map) throws Exception {
        if (UserSessionManager.isUserLogined()) {
            map.put("updateUser", UserSessionManager.getLoginUserVO().getUserId());
        }
        Map<String, Object> resultMap = new HashMap<>();
        orderItemService.updateOrderItem(map);
        resultMap.put("ok", true);
        resultMap.put("msg", "수정 성공");
        return resultMap;
    }

    /**
     * 주문상품 삭제(soft delete)
     */
    @RequestMapping("/api/ord/orderItem/deleteOrderItem")
    @ResponseBody
    public Map<String, Object> deleteOrderItem(@RequestBody HashMap<String, Object> map) throws Exception {
        if (UserSessionManager.isUserLogined()) {
            map.put("updatedBy", UserSessionManager.getLoginUserVO().getUserId());
        }
        Map<String, Object> resultMap = new HashMap<>();
        orderItemService.deleteOrderItem(map);
        resultMap.put("ok", true);
        resultMap.put("msg", "삭제 성공");
        return resultMap;
    }

    /**
     * 주문상품 개수
     */
    @RequestMapping("/api/ord/orderItem/selectOrderItemListCount")
    @ResponseBody
    public Map<String, Object> selectOrderItemListCount(@RequestBody HashMap<String, Object> map) throws Exception {
        Map<String, Object> resultMap = new HashMap<>();
        int count = orderItemService.selectOrderItemListCount(map);
        resultMap.put("ok", true);
        resultMap.put("msg", "성공");
        resultMap.put("count", count);
        return resultMap;
    }
}
