package www.api.mmp.map.service;

import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import www.com.pag.PagingHelper;
import www.com.util.CommonDao;

@Service
public class MapService {

    private final String namespace = "www.api.mmp.map.Map";

    @Autowired
    private CommonDao dao;

    /**
     * 템플릿 목록 조회 (비페이징)
     */
    public List<Map<String, Object>> selectMapList(Map<String, Object> paramMap) {
        return dao.list(namespace + ".selectMapList", paramMap);
    }

    /**
     * 템플릿 목록 수 조회 (기존 방식)
     */
    public int selectMapListCount(Map<String, Object> paramMap) {
        Map<String, Object> resultMap = dao.selectOne(namespace + ".selectMapListCount", paramMap);
        if (resultMap != null && resultMap.get("cnt") != null) {
            return Integer.parseInt(resultMap.get("cnt").toString());
        }
        return 0;
    }

    /**
     * 템플릿 단건 조회
     */
    public Map<String, Object> selectMapDetail(Map<String, Object> paramMap) {
        return dao.selectOne(namespace + ".selectMapDetail", paramMap);
    }

    /**
     * 템플릿 등록
     */
    @Transactional
    public void insertMap(Map<String, Object> paramMap) {
        dao.insert(namespace + ".insertMap", paramMap);
    }

    /**
     * 템플릿 수정
     */
    @Transactional
    public void updateMap(Map<String, Object> paramMap) {
        dao.update(namespace + ".updateMap", paramMap);
    }

    /**
     * 템플릿 삭제
     */
    @Transactional
    public void deleteMap(Map<String, Object> paramMap) {
        dao.delete(namespace + ".deleteMap", paramMap);
    }

    /**
     * 템플릿 목록 조회 (페이징) - PagingHelper 표준 포맷 반환
     * 입력 파라미터: page, size, grpCd 등
     * 반환: { list: [...], page: {page,size,total,totalPages,hasNext,hasPrev} }
     */
    public Map<String, Object> selectMapListPaged(Map<String, Object> paramMap) {
        return PagingHelper.run(
            dao,
            namespace + ".selectMapList",          // limit/offset 지원 목록 쿼리
            namespace + ".selectMapListCount",  // INT 단일 컬럼 카운트 쿼리
            paramMap
        );
    }
}