package www.api.isu.issue.service;

import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import www.com.util.CommonDao;

@Service
public class IssueService {

    private final String namespace = "www.api.isu.issue.Issue";

    @Autowired
    private CommonDao dao;

    /**
     * 이슈 목록 조회
     */
    public List<Map<String, Object>> selectIssueList(Map<String, Object> paramMap) {
        return dao.list(namespace + ".selectIssueList", paramMap);
    }

    /**
     * 이슈 목록 수 조회
     */
    public int selectIssueListCount(Map<String, Object> paramMap) {
        Map<String, Object> resultMap = dao.selectOne(namespace + ".selectIssueListCount", paramMap);
        if (resultMap != null && resultMap.get("cnt") != null) {
            return Integer.parseInt(resultMap.get("cnt").toString());
        }
        return 0;
    }

    /**
     * 이슈 단건 조회
     */
    public Map<String, Object> selectIssueDetail(Map<String, Object> paramMap) {
        return dao.selectOne(namespace + ".selectIssueDetail", paramMap);
    }

    /**
     * 이슈 등록
     */
    @Transactional
    public void insertIssue(Map<String, Object> paramMap) {
        dao.insert(namespace + ".insertIssue", paramMap);
    }

    /**
     * 이슈 수정
     */
    @Transactional
    public void updateIssue(Map<String, Object> paramMap) {
        dao.update(namespace + ".updateIssue", paramMap);
    }

    /**
     * 이슈 삭제
     */
    @Transactional
    public void deleteIssue(Map<String, Object> paramMap) {
        dao.delete(namespace + ".deleteIssue", paramMap);
    }

    /**
     * 칸반 보드용 이슈 목록 (프로젝트 단위)
     */
    public List<Map<String, Object>> selectIssueBoardList(Map<String, Object> paramMap) {
        return dao.list(namespace + ".selectIssueBoardList", paramMap);
    }

    /**
     * 칸반 보드에서 상태만 변경
     */
    @Transactional
    public void updateIssueStatus(Map<String, Object> paramMap) {
        dao.update(namespace + ".updateIssueStatus", paramMap);
    }
}
