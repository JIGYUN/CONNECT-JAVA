package www.api.isu.prj.service;

import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import www.com.util.CommonDao;

@Service
public class prjService {

    private final String namespace = "www.api.isu.prj.prj";

    @Autowired
    private CommonDao dao;

    /**
     * 템플릿 목록 조회
     */
    public List<Map<String, Object>> selectprjList(Map<String, Object> paramMap) {
        return dao.list(namespace + ".selectprjList", paramMap);
    }

    /**
     * 템플릿 목록 수 조회
     */
    public int selectprjListCount(Map<String, Object> paramMap) {
        Map<String, Object> resultMap = dao.selectOne(namespace + ".selectprjListCount", paramMap);
        if (resultMap != null && resultMap.get("cnt") != null) {
            return Integer.parseInt(resultMap.get("cnt").toString());
        }
        return 0;
    }

    /**
     * 템플릿 단건 조회
     */
    public Map<String, Object> selectprjDetail(Map<String, Object> paramMap) {
        return dao.selectOne(namespace + ".selectprjDetail", paramMap);
    }

    /**
     * 템플릿 등록
     */
    @Transactional
    public void insertprj(Map<String, Object> paramMap) {
        dao.insert(namespace + ".insertprj", paramMap);
    }

    /**
     * 템플릿 수정
     */
    @Transactional
    public void updateprj(Map<String, Object> paramMap) {
        dao.update(namespace + ".updateprj", paramMap);
    }

    /**
     * 템플릿 삭제
     */
    @Transactional
    public void deleteprj(Map<String, Object> paramMap) {
        dao.delete(namespace + ".deleteprj", paramMap);
    }
}
