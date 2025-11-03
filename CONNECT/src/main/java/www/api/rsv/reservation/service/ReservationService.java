package www.api.rsv.reservation.service;

import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import www.com.util.CommonDao;

@Service
public class ReservationService {

    private final String namespace = "www.api.rsv.reservation.Reservation";

    @Autowired
    private CommonDao dao;

    /**
     * 템플릿 목록 조회
     */
    public List<Map<String, Object>> selectReservationList(Map<String, Object> paramMap) {
        return dao.list(namespace + ".selectReservationList", paramMap);
    }

    /**
     * 템플릿 목록 수 조회
     */
    public int selectReservationListCount(Map<String, Object> paramMap) {
        Map<String, Object> resultMap = dao.selectOne(namespace + ".selectReservationListCount", paramMap);
        if (resultMap != null && resultMap.get("cnt") != null) {
            return Integer.parseInt(resultMap.get("cnt").toString());
        }
        return 0;
    }

    /**
     * 템플릿 목록 조회
     */
    public List<Map<String, Object>> selectReservationListByDate(Map<String, Object> paramMap) {
        return dao.list(namespace + ".selectReservationListByDate", paramMap);
    }
    
    /**
     * 템플릿 수정
     */
    @Transactional
    public void updateReservationStatus(Map<String, Object> paramMap) {
        dao.update(namespace + ".updateReservationStatus", paramMap);
    }
    
    /**
     * 템플릿 단건 조회
     */
    public Map<String, Object> selectReservationDetail(Map<String, Object> paramMap) {
        return dao.selectOne(namespace + ".selectReservationDetail", paramMap);
    }

    /**
     * 템플릿 등록
     */
    @Transactional
    public void insertReservation(Map<String, Object> paramMap) {
        dao.insert(namespace + ".insertReservation", paramMap);
    }

    /**
     * 템플릿 수정
     */
    @Transactional
    public void updateReservation(Map<String, Object> paramMap) {
        dao.update(namespace + ".updateReservation", paramMap);
    }

    /**
     * 템플릿 삭제
     */
    @Transactional
    public void deleteReservation(Map<String, Object> paramMap) {
        dao.delete(namespace + ".deleteReservation", paramMap);
    }
}
