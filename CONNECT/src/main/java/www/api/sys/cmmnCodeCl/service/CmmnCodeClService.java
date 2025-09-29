package www.api.sys.cmmnCodeCl.service;

import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import www.com.util.CommonDao;

@Service
public class CmmnCodeClService {

    private final String namespace = "www.api.sys.cmmnCodeCl.CmmnCodeCl";

    @Autowired
    private CommonDao dao;

    /**
     * 템플릿 목록 조회
     */
    public List<Map<String, Object>> selectCmmnCodeClList(Map<String, Object> paramMap) {
        return dao.list(namespace + ".selectCmmnCodeClList", paramMap);
    }

    /**
     * 템플릿 목록 수 조회
     */
    public int selectCmmnCodeClListCount(Map<String, Object> paramMap) {
        Map<String, Object> resultMap = dao.selectOne(namespace + ".selectCmmnCodeClListCount", paramMap);
        if (resultMap != null && resultMap.get("cnt") != null) {
            return Integer.parseInt(resultMap.get("cnt").toString());
        }
        return 0;
    }

    /**
     * 템플릿 단건 조회
     */
    public Map<String, Object> selectCmmnCodeClDetail(Map<String, Object> paramMap) {
        return dao.selectOne(namespace + ".selectCmmnCodeClDetail", paramMap);
    }

    /**
     * 템플릿 등록
     */
    @Transactional
    public void insertCmmnCodeCl(Map<String, Object> paramMap) {
        dao.insert(namespace + ".insertCmmnCodeCl", paramMap);
    }

    /**
     * 템플릿 수정
     */
    @Transactional
    public void updateCmmnCodeCl(Map<String, Object> paramMap) {
        dao.update(namespace + ".updateCmmnCodeCl", paramMap);
    }

    /**
     * 템플릿 삭제
     */
    @Transactional
    public void deleteCmmnCodeCl(Map<String, Object> paramMap) {
        dao.delete(namespace + ".deleteCmmnCodeCl", paramMap);
    }
}
