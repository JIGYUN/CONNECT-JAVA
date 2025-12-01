package www.api.isu.issueComment.service;

import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import www.com.util.CommonDao;

@Service
public class issueCommentService {

    private final String namespace = "www.api.isu.issueComment.issueComment";

    @Autowired
    private CommonDao dao;

    /**
     * 템플릿 목록 조회
     */
    public List<Map<String, Object>> selectissueCommentList(Map<String, Object> paramMap) {
        return dao.list(namespace + ".selectissueCommentList", paramMap);
    }

    /**
     * 템플릿 목록 수 조회
     */
    public int selectissueCommentListCount(Map<String, Object> paramMap) {
        Map<String, Object> resultMap = dao.selectOne(namespace + ".selectissueCommentListCount", paramMap);
        if (resultMap != null && resultMap.get("cnt") != null) {
            return Integer.parseInt(resultMap.get("cnt").toString());
        }
        return 0;
    }

    /**
     * 템플릿 단건 조회
     */
    public Map<String, Object> selectissueCommentDetail(Map<String, Object> paramMap) {
        return dao.selectOne(namespace + ".selectissueCommentDetail", paramMap);
    }

    /**
     * 템플릿 등록
     */
    @Transactional
    public void insertissueComment(Map<String, Object> paramMap) {
        dao.insert(namespace + ".insertissueComment", paramMap);
    }

    /**
     * 템플릿 수정
     */
    @Transactional
    public void updateissueComment(Map<String, Object> paramMap) {
        dao.update(namespace + ".updateissueComment", paramMap);
    }

    /**
     * 템플릿 삭제
     */
    @Transactional
    public void deleteissueComment(Map<String, Object> paramMap) {
        dao.delete(namespace + ".deleteissueComment", paramMap);
    }
}
