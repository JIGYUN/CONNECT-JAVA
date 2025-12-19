package www.api.tst.testt.service;

import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import www.com.util.CommonDao;

@Service
public class TesttService {

    private final String namespace = "www.api.tst.testt.Testt";

    @Autowired
    private CommonDao dao;

    /**
     * 템플릿 목록 조회
     */
    public List<Map<String, Object>> selectTesttList(Map<String, Object> paramMap) {
        return dao.list(namespace + ".selectTesttList", paramMap);
    }

    /**
     * 템플릿 목록 수 조회
     */
    public int selectTesttListCount(Map<String, Object> paramMap) {
        Map<String, Object> resultMap = dao.selectOne(namespace + ".selectTesttListCount", paramMap);
        if (resultMap != null && resultMap.get("cnt") != null) {
            return Integer.parseInt(resultMap.get("cnt").toString());
        }
        return 0;
    }

    /**
     * 템플릿 단건 조회
     */
    public Map<String, Object> selectTesttDetail(Map<String, Object> paramMap) {
        return dao.selectOne(namespace + ".selectTesttDetail", paramMap);
    }

    /**
     * 템플릿 등록
     */
    @Transactional
    public void insertTestt(Map<String, Object> paramMap) {
        dao.insert(namespace + ".insertTestt", paramMap);
    }

    /**
     * 템플릿 수정
     */
    @Transactional
    public void updateTestt(Map<String, Object> paramMap) {
        dao.update(namespace + ".updateTestt", paramMap);
    }

    /**
     * 템플릿 삭제
     */
    @Transactional
    public void deleteTestt(Map<String, Object> paramMap) {
        dao.delete(namespace + ".deleteTestt", paramMap);
    }
}
