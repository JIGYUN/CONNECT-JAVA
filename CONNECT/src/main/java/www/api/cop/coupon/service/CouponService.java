// filepath: src/main/java/www/api/cop/coupon/service/CouponService.java
package www.api.cop.coupon.service;

import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import www.com.util.CommonDao;

@Service
public class CouponService {

    private static final String NAMESPACE = "www.api.cop.coupon.Coupon";

    @Autowired
    private CommonDao dao;

    /**
     * 쿠폰 목록 조회
     */
    public List<Map<String, Object>> selectCouponList(Map<String, Object> paramMap) {
        return dao.list(NAMESPACE + ".selectCouponList", paramMap);
    }

    /**
     * 쿠폰 목록 수 조회
     */
    public int selectCouponListCount(Map<String, Object> paramMap) {
        Map<String, Object> resultMap = dao.selectOne(NAMESPACE + ".selectCouponListCount", paramMap);
        if (resultMap != null && resultMap.get("cnt") != null) {
            return Integer.parseInt(resultMap.get("cnt").toString());
        }
        return 0;
    }

    /**
     * 쿠폰 단건 조회
     */
    public Map<String, Object> selectCouponDetail(Map<String, Object> paramMap) {
        return dao.selectOne(NAMESPACE + ".selectCouponDetail", paramMap);
    }

    /**
     * 쿠폰 등록
     */
    @Transactional
    public void insertCoupon(Map<String, Object> paramMap) {
        dao.insert(NAMESPACE + ".insertCoupon", paramMap);
    }

    /**
     * 쿠폰 수정
     */
    @Transactional
    public void updateCoupon(Map<String, Object> paramMap) {
        dao.update(NAMESPACE + ".updateCoupon", paramMap);
    }

    /**
     * 쿠폰 삭제
     */
    @Transactional
    public void deleteCoupon(Map<String, Object> paramMap) {
        dao.delete(NAMESPACE + ".deleteCoupon", paramMap);
    }
}
