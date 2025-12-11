// filepath: src/main/java/www/api/cop/couponUser/web/CouponUserController.java
package www.api.cop.couponUser.web;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

import www.api.cop.couponUser.service.CouponUserService;
import www.com.user.service.UserSessionManager;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
public class CouponUserController {

    @Autowired
    private CouponUserService couponUserService;

    /**
     * 쿠폰 발급 목록 조회 (관리자/공용)
     */
    @RequestMapping("/api/cop/couponUser/selectCouponUserList")
    @ResponseBody
    public Map<String, Object> selectCouponUserList(@RequestBody HashMap<String, Object> map) throws Exception {
        Map<String, Object> resultMap = new HashMap<>();
        List<Map<String, Object>> result = couponUserService.selectCouponUserList(map);
        resultMap.put("msg", "성공");
        resultMap.put("result", result);
        return resultMap;
    }

    /**
     * 로그인 사용자의 쿠폰 목록 (내 쿠폰함 - 전체)
     */
    @RequestMapping("/api/cop/couponUser/selectMyCouponList")
    @ResponseBody
    public Map<String, Object> selectMyCouponList(@RequestBody HashMap<String, Object> map) throws Exception {
        Map<String, Object> resultMap = new HashMap<>();

        if (!UserSessionManager.isUserLogined()) {
            resultMap.put("msg", "LOGIN_REQUIRED");
            resultMap.put("result", null);
            return resultMap;
        }

        map.put("userId", UserSessionManager.getLoginUserVO().getUserId());
        List<Map<String, Object>> result = couponUserService.selectCouponUserList(map);

        resultMap.put("msg", "성공");
        resultMap.put("result", result);
        return resultMap;
    }

    /**
     * 주문/결제 화면용 - 로그인 사용자의 '사용 가능' 쿠폰 목록
     */
    @RequestMapping("/api/cop/couponUser/selectMyAvailableCouponList")
    @ResponseBody
    public Map<String, Object> selectMyAvailableCouponList(@RequestBody HashMap<String, Object> map) throws Exception {
        Map<String, Object> resultMap = new HashMap<>();

        if (!UserSessionManager.isUserLogined()) {
            resultMap.put("msg", "LOGIN_REQUIRED");
            resultMap.put("result", null);
            return resultMap;
        }

        // 로그인 사용자 + 사용 가능 쿠폰만
        map.put("userId", UserSessionManager.getLoginUserVO().getUserId());
        // ★ 기존: "Y" 문자열 → 변경: boolean true
        map.put("availableOnly", Boolean.TRUE);

        List<Map<String, Object>> result = couponUserService.selectCouponUserList(map);

        resultMap.put("msg", "성공");
        resultMap.put("result", result);
        return resultMap;
    }

    /**
     * 발급 단건 조회
     */
    @RequestMapping("/api/cop/couponUser/selectCouponUserDetail")
    @ResponseBody
    public Map<String, Object> selectCouponUserDetail(@RequestBody HashMap<String, Object> map) throws Exception {
        Map<String, Object> resultMap = new HashMap<>();
        Map<String, Object> result = couponUserService.selectCouponUserDetail(map);
        resultMap.put("msg", "성공");
        resultMap.put("result", result);
        return resultMap;
    }

    /**
     * 발급 등록
     */
    @RequestMapping("/api/cop/couponUser/insertCouponUser")
    @ResponseBody
    public Map<String, Object> insertCouponUser(@RequestBody HashMap<String, Object> map) throws Exception {
        if (UserSessionManager.isUserLogined()) {
            map.put("createdBy", UserSessionManager.getLoginUserVO().getUserId());
            map.put("updatedBy", UserSessionManager.getLoginUserVO().getUserId());
        }
        Map<String, Object> resultMap = new HashMap<>();
        couponUserService.insertCouponUser(map);
        resultMap.put("msg", "등록 성공");
        return resultMap;
    }

    /**
     * 발급 정보 수정
     */
    @RequestMapping("/api/cop/couponUser/updateCouponUser")
    @ResponseBody
    public Map<String, Object> updateCouponUser(@RequestBody HashMap<String, Object> map) throws Exception {
        if (UserSessionManager.isUserLogined()) {
            map.put("updatedBy", UserSessionManager.getLoginUserVO().getUserId());
        }
        Map<String, Object> resultMap = new HashMap<>();
        couponUserService.updateCouponUser(map);
        resultMap.put("msg", "수정 성공");
        return resultMap;
    }

    /**
     * 발급 삭제
     */
    @RequestMapping("/api/cop/couponUser/deleteCouponUser")
    @ResponseBody
    public Map<String, Object> deleteCouponUser(@RequestBody HashMap<String, Object> map) throws Exception {
        Map<String, Object> resultMap = new HashMap<>();
        couponUserService.deleteCouponUser(map);
        resultMap.put("msg", "삭제 성공");
        return resultMap;
    }

    /**
     * 발급 개수
     */
    @RequestMapping("/api/cop/couponUser/selectCouponUserListCount")
    @ResponseBody
    public Map<String, Object> selectCouponUserListCount(@RequestBody HashMap<String, Object> map) throws Exception {
        Map<String, Object> resultMap = new HashMap<>();
        int count = couponUserService.selectCouponUserListCount(map);
        resultMap.put("msg", "성공");
        resultMap.put("count", count);
        return resultMap;
    }
}
