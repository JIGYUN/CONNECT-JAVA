// filepath: src/main/java/www/api/cop/coupon/web/CouponController.java
package www.api.cop.coupon.web;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import www.api.cop.coupon.service.CouponService;
import www.com.user.service.UserSessionManager;

@Controller
public class CouponController {

    @Autowired
    private CouponService couponService;

    /**
     * 쿠폰 목록 조회
     */
    @RequestMapping("/api/cop/coupon/selectCouponList")
    @ResponseBody
    public Map<String, Object> selectCouponList(@RequestBody HashMap<String, Object> map) throws Exception {
        Map<String, Object> resultMap = new HashMap<>();
        List<Map<String, Object>> result = couponService.selectCouponList(map);
        resultMap.put("ok", true);
        resultMap.put("result", result);
        return resultMap;
    }

    /**
     * 쿠폰 목록 개수 조회
     */
    @RequestMapping("/api/cop/coupon/selectCouponListCount")
    @ResponseBody
    public Map<String, Object> selectCouponListCount(@RequestBody HashMap<String, Object> map) throws Exception {
        Map<String, Object> resultMap = new HashMap<>();
        int count = couponService.selectCouponListCount(map);
        resultMap.put("ok", true);
        resultMap.put("count", count);
        return resultMap;
    }

    /**
     * 쿠폰 단건 조회
     */
    @RequestMapping("/api/cop/coupon/selectCouponDetail")
    @ResponseBody
    public Map<String, Object> selectCouponDetail(@RequestBody HashMap<String, Object> map) throws Exception {
        Map<String, Object> resultMap = new HashMap<>();
        Map<String, Object> result = couponService.selectCouponDetail(map);
        resultMap.put("ok", true);
        resultMap.put("result", result);
        return resultMap;
    }

    /**
     * 쿠폰 등록
     */
    @RequestMapping("/api/cop/coupon/insertCoupon")
    @ResponseBody
    public Map<String, Object> insertCoupon(@RequestBody HashMap<String, Object> map) throws Exception {
        if (UserSessionManager.isUserLogined()) {
            map.put("createdBy", UserSessionManager.getLoginUserVO().getUserId());
        }
        Map<String, Object> resultMap = new HashMap<>();
        couponService.insertCoupon(map);
        resultMap.put("ok", true);
        resultMap.put("msg", "등록 성공");
        return resultMap;
    }

    /**
     * 쿠폰 수정
     */
    @RequestMapping("/api/cop/coupon/updateCoupon")
    @ResponseBody
    public Map<String, Object> updateCoupon(@RequestBody HashMap<String, Object> map) throws Exception {
        if (UserSessionManager.isUserLogined()) {
            map.put("updatedBy", UserSessionManager.getLoginUserVO().getUserId());
        }
        Map<String, Object> resultMap = new HashMap<>();
        couponService.updateCoupon(map);
        resultMap.put("ok", true);
        resultMap.put("msg", "수정 성공");
        return resultMap;
    }

    /**
     * 쿠폰 삭제
     */
    @RequestMapping("/api/cop/coupon/deleteCoupon")
    @ResponseBody
    public Map<String, Object> deleteCoupon(@RequestBody HashMap<String, Object> map) throws Exception {
        Map<String, Object> resultMap = new HashMap<>();
        couponService.deleteCoupon(map);
        resultMap.put("ok", true);
        resultMap.put("msg", "삭제 성공");
        return resultMap;
    }
}
