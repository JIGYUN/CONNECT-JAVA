package www.api.sys.cmmnCode.service;

import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import www.com.util.CommonDao;

@Service
public class CmmnCodeService {

    private final String namespace = "www.api.sys.cmmnCode.CmmnCode";

    @Autowired
    private CommonDao dao;

    /**
     * 템플릿 목록 조회
     */
    public List<Map<String, Object>> selectCmmnCodeList(Map<String, Object> paramMap) {
        return dao.list(namespace + ".selectCmmnCodeList", paramMap);
    }

    /**
     * 템플릿 목록 수 조회
     */
    public int selectCmmnCodeListCount(Map<String, Object> paramMap) {
        Map<String, Object> resultMap = dao.selectOne(namespace + ".selectCmmnCodeListCount", paramMap);
        if (resultMap != null && resultMap.get("cnt") != null) {
            return Integer.parseInt(resultMap.get("cnt").toString());
        }
        return 0;
    }

    /**
     * 템플릿 단건 조회
     */
    public Map<String, Object> selectCmmnCodeDetail(Map<String, Object> paramMap) {
        return dao.selectOne(namespace + ".selectCmmnCodeDetail", paramMap);
    }

    /**
     * 템플릿 등록
     */
    @Transactional
    public void insertCmmnCode(Map<String, Object> paramMap) {
        dao.insert(namespace + ".insertCmmnCode", paramMap);
    }

    /**
     * 템플릿 수정
     */
    @Transactional
    public void updateCmmnCode(Map<String, Object> paramMap) {
        dao.update(namespace + ".updateCmmnCode", paramMap);
    }

    /**
     * 템플릿 삭제
     */
    @Transactional
    public void deleteCmmnCode(Map<String, Object> paramMap) {
        dao.delete(namespace + ".deleteCmmnCode", paramMap);
    }
}
