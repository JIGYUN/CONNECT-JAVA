// filepath: src/main/java/www/api/cop/couponUser/service/CouponUserService.java
package www.api.cop.couponUser.service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import www.com.util.CommonDao;

@Service
public class CouponUserService {

    private static final String NAMESPACE = "www.api.cop.couponUser.CouponUser";

    @Autowired
    private CommonDao dao;

    /**
     * 쿠폰 사용자 목록 조회
     */
    public List<Map<String, Object>> selectCouponUserList(Map<String, Object> paramMap) {
        return dao.list(NAMESPACE + ".selectCouponUserList", paramMap);
    }

    /**
     * 쿠폰 사용자 목록 수 조회
     */
    public int selectCouponUserListCount(Map<String, Object> paramMap) {
        Map<String, Object> resultMap = dao.selectOne(NAMESPACE + ".selectCouponUserListCount", paramMap);
        if (resultMap != null && resultMap.get("cnt") != null) {
            return Integer.parseInt(resultMap.get("cnt").toString());
        }
        return 0;
    }

    /**
     * 쿠폰 사용자 단건 조회
     */
    public Map<String, Object> selectCouponUserDetail(Map<String, Object> paramMap) {
        return dao.selectOne(NAMESPACE + ".selectCouponUserDetail", paramMap);
    }

    /**
     * 쿠폰 발급(등록)
     */
    @Transactional
    public void insertCouponUser(Map<String, Object> paramMap) {
        dao.insert(NAMESPACE + ".insertCouponUser", paramMap);
    }

    /**
     * 쿠폰 사용자 정보 수정 (상태/사용일 등 - 공통용)
     */
    @Transactional
    public void updateCouponUser(Map<String, Object> paramMap) {
        dao.update(NAMESPACE + ".updateCouponUser", paramMap);
    }

    /**
     * 쿠폰 사용자 삭제
     */
    @Transactional
    public void deleteCouponUser(Map<String, Object> paramMap) {
        dao.delete(NAMESPACE + ".deleteCouponUser", paramMap);
    }

    /**
     * 주문 시 쿠폰 사용 처리
     * - TB_COUPON_USER.STATUS_CD = 'USED'
     * - TB_COUPON_USER.USE_AT    = 'N'
     * - TB_COUPON_USER.USE_DT    = NOW()
     * - TB_COUPON_USER.ORDER_ID  = 주문 ID
     */
    @Transactional
    public void updateCouponAsUsed(Long couponUserId, Long orderId, String updatedBy) {
        if (couponUserId == null || couponUserId <= 0L) {
            return;
        }

        Map<String, Object> param = new HashMap<>();
        param.put("couponUserId", couponUserId);
        param.put("orderId", orderId);
        param.put("statusCd", "USED");
        param.put("updatedBy", updatedBy);

        // mapper: NAMESPACE + ".updateCouponUserUse"
        dao.update(NAMESPACE + ".updateCouponUserUse", param);
    }
}
