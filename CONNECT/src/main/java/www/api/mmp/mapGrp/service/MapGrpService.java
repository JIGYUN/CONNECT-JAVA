package www.api.mmp.mapGrp.service;

import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import www.com.util.CommonDao;

@Service
public class MapGrpService {

    private final String namespace = "www.api.mmp.mapGrp.MapGrp";

    @Autowired
    private CommonDao dao;

    /**
     * 템플릿 목록 조회
     */
    public List<Map<String, Object>> selectMapGrpList(Map<String, Object> paramMap) {
        return dao.list(namespace + ".selectMapGrpList", paramMap);
    }

    /**
     * 템플릿 목록 수 조회
     */
    public int selectMapGrpListCount(Map<String, Object> paramMap) {
        Map<String, Object> resultMap = dao.selectOne(namespace + ".selectMapGrpListCount", paramMap);
        if (resultMap != null && resultMap.get("cnt") != null) {
            return Integer.parseInt(resultMap.get("cnt").toString());
        }
        return 0;
    }

    /**
     * 템플릿 단건 조회
     */
    public Map<String, Object> selectMapGrpDetail(Map<String, Object> paramMap) {
        return dao.selectOne(namespace + ".selectMapGrpDetail", paramMap);
    }

    /**
     * 템플릿 등록
     */
    @Transactional
    public void insertMapGrp(Map<String, Object> paramMap) {
        dao.insert(namespace + ".insertMapGrp", paramMap);
    }

    /**
     * 템플릿 수정
     */
    @Transactional
    public void updateMapGrp(Map<String, Object> paramMap) {
        dao.update(namespace + ".updateMapGrp", paramMap);
    }

    /**
     * 템플릿 삭제
     */
    @Transactional
    public void deleteMapGrp(Map<String, Object> paramMap) {
        dao.delete(namespace + ".deleteMapGrp", paramMap);
    }
}
