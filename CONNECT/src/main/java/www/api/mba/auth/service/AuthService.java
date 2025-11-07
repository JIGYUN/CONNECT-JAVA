package www.api.mba.auth.service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;
import egovframework.rte.fdl.cmmn.EgovAbstractServiceImpl;
import www.com.util.CommonDao;
import www.com.util.Sha256;
import www.api.mba.auth.service.AuthService;

/**
 * 조직관리1 정보 관리 구현 클래스
 *
 * @author 정지균
 * @since 2024.01.12
 */
@Service
public class AuthService extends EgovAbstractServiceImpl {

    private Logger logger = LoggerFactory.getLogger(this.getClass());

    @Autowired
    private CommonDao dao;

    
    private String namespace = "www.api.mba.auth.Auth";

    /**
     * 회원가입
     *
     * @author 정지균
     * @since 2024.01.12
     */
    @Transactional(propagation = Propagation.REQUIRED)
    public void insertJoin(Map<String, Object> params) {
    	Sha256 sha256 = new Sha256();
    	params.put("password", sha256.encrypt(String.valueOf(params.get("password"))));
    	
        dao.insert(namespace+".insertJoin", params);  		//마스터 인서트 
    }

    /**
     * 로그인
     * - 비밀번호 해시 → 사용자 조회
     * - 조회 성공(=로그인 성공)이고 fcmToken 파라미터가 있을 때만 TB_USER 토큰 업데이트
     */
    public Map<String, Object> selectLogin(Map<String, Object> params) {
        // 1) 비밀번호 해시
        Sha256 sha256 = new Sha256();
        params.put("password", sha256.encrypt(String.valueOf(params.get("password"))));

        // 2) 로그인 시도
        Map<String, Object> user = dao.selectOne(namespace + ".selectLogin", params);

        // 3) 로그인 성공 시에만 토큰 업데이트
        if (user != null) {
            // 프론트가 보낸 fcmToken 키가 "존재"할 때만 동작 (값이 null이면 DB를 NULL로 클리어)
        	// fcmToken이 비어있지 않을 때만 토큰 업데이트 수행
        	Object t = params.get("fcmToken");
        	String token = (t == null) ? null : String.valueOf(t).trim();
        	if (token != null && !token.isEmpty()) {
        	    // USER_ID 추출(대소문자 혼용 대비)
        	    Object uidObj = user.containsKey("USER_ID") ? user.get("USER_ID") : user.get("userId");
        	    Long userId = (uidObj == null) ? null : Long.valueOf(String.valueOf(uidObj));

        	    if (userId != null) {
        	        Map<String, Object> up = new HashMap<>();
        	        up.put("userId", userId);
        	        up.put("fcmToken", token); // 빈값 아님(위에서 검증)

        	        // 선택: 플랫폼 정보가 있을 때만 반영(빈문자면 미포함)
        	        Object p = params.get("platformInfo");
        	        String platformInfo = (p == null) ? null : String.valueOf(p).trim();
        	        if (platformInfo != null && !platformInfo.isEmpty()) {
        	            up.put("platformInfo", platformInfo);
        	        }

        	        dao.update(namespace + ".updateToken", up);
        	    }
        	}
        }

        return user;
    }

    /**
     * 아이디비밀번호찾기
     *
     * @author 정지균
     * @since 2024.01.12
     * @param Map 조회 조건
     * @return List 조회 결과
     */
    public Map<String, Object> selectIdPwFind(Map<String, Object> params) {
        return dao.selectOne(namespace + ".selectIdPwFind", params);
    }
    
    /**
     * 아이디 중복체크 
     *
     * @author 정지균
     * @since 2024.01.12
     * @param Map 조회 조건
     * @return List 조회 결과
     */
    public Map<String, Object> duplicateId(Map<String, Object> params) {
        return dao.selectOne(namespace + ".duplicateId", params);
    }
    
    
    /**
     * 아이디 찾기 
     *
     * @author 정지균
     * @since 2024.01.12
     * @param Map 조회 조건
     * @return List 조회 결과
     */
    public Map<String, Object> findId(Map<String, Object> params) {
        return dao.selectOne(namespace + ".findId", params);
    }
    
    /**
     * 비밀번호 변경 
     *
     * @author 정지균
     * @since 2024.01.12
     * @param Map 조회 조건
     * @return List 조회 결과
     */
    public int changePassword(Map<String, Object> params) {
    	Sha256 sha256 = new Sha256();
    	params.put("password", sha256.encrypt(String.valueOf(params.get("password"))));
        return dao.update(namespace + ".changePassword", params);
    }
 
}
