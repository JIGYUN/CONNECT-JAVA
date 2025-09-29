package www.api.brd.boardDef.service;

import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import www.com.util.CommonDao;

@Service
public class BoardDefService {

    private final String namespace = "www.api.brd.boardDef.BoardDef";

    @Autowired
    private CommonDao dao;

    /**
     * 템플릿 목록 조회
     */
    public List<Map<String, Object>> selectBoardDefList(Map<String, Object> paramMap) {
        return dao.list(namespace + ".selectBoardDefList", paramMap);
    }

    /**
     * 템플릿 목록 수 조회
     */
    public int selectBoardDefListCount(Map<String, Object> paramMap) {
        Map<String, Object> resultMap = dao.selectOne(namespace + ".selectBoardDefListCount", paramMap);
        if (resultMap != null && resultMap.get("cnt") != null) {
            return Integer.parseInt(resultMap.get("cnt").toString());
        }
        return 0;
    }

    /**
     * 템플릿 단건 조회
     */
    public Map<String, Object> selectBoardDefDetail(Map<String, Object> paramMap) {
        return dao.selectOne(namespace + ".selectBoardDefDetail", paramMap);
    }

    /**
     * 템플릿 등록
     */
    @Transactional
    public void insertBoardDef(Map<String, Object> paramMap) {
        dao.insert(namespace + ".insertBoardDef", paramMap);
    }

    /**
     * 템플릿 수정
     */
    @Transactional
    public void updateBoardDef(Map<String, Object> paramMap) {
        dao.update(namespace + ".updateBoardDef", paramMap);
    }

    /**
     * 템플릿 삭제
     */
    @Transactional
    public void deleteBoardDef(Map<String, Object> paramMap) {
        dao.delete(namespace + ".deleteBoardDef", paramMap);
    }
}
