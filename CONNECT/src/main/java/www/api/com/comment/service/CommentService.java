package www.api.com.comment.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import www.com.util.CommonDao;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class CommentService {

    private static final String namespace = "www.api.com.comment.Comment";

    @Autowired
    private CommonDao dao;

    /** 타겟별 코멘트 리스트 (비페이징, 정렬완료) */
    public List<Map<String, Object>> selectCommentListByTarget(Map<String, Object> param) {
        // 기대 파라미터: targetTyCd, targetId
        return dao.list(namespace + ".selectCommentListByTarget", param);
    }

    /** 타겟별 카운트 */
    public int selectCommentCountByTarget(Map<String, Object> param) {
        return dao.selectOneInt(namespace + ".selectCommentCountByTarget", param);
    }

    /** 단건 조회 */
    public Map<String, Object> selectCommentById(Map<String, Object> param) {
        return dao.selectOne(namespace + ".selectCommentById", param);
    }

    /**
     * 코멘트 등록
     * - 파라미터 필수: targetTyCd, targetId, content, userId
     * - 옵션: parentCommentId(있으면 대댓글)
     * - 반환: commentId, depth, rootOrdr, childOrdr 포함
     */
    @Transactional
    public Map<String, Object> insertComment(Map<String, Object> param) {
        Map<String, Object> p = new HashMap<>(param);

        // 필수값 체크는 호출부(or AOP)에서 해도 되지만, 안전하게 최소 체크
        if (p.get("targetTyCd") == null || p.get("targetId") == null || p.get("userId") == null || p.get("content") == null) {
            throw new IllegalArgumentException("required: targetTyCd, targetId, userId, content");
        }

        // DEPTH/순번 결정
        Long parentId = toLong(p.get("parentCommentId"));
        int depth = (parentId != null && parentId > 0) ? 1 : 0;
        p.put("depth", depth);

        // ROOT_ORDR
        int rootOrdr = dao.selectOneInt(namespace + ".selectNextRootOrdr", p);
        p.put("rootOrdr", rootOrdr);

        // CHILD_ORDR (대댓글만)
        if (depth == 1) {
            int childOrdr = dao.selectOneInt(namespace + ".selectNextChildOrdr", p);
            p.put("childOrdr", childOrdr);
        } else {
            p.put("childOrdr", null);
            p.put("parentCommentId", null);
        }

        // 기본값
        if (p.get("secretAt") == null) p.put("secretAt", "N");

        // INSERT
        dao.insert(namespace + ".insertComment", p);

        // 부모 REPLY_CNT +1
        if (depth == 1) {
            Map<String, Object> up = new HashMap<>();
            up.put("parentCommentId", parentId);
            dao.update(namespace + ".increaseParentReplyCnt", up);
        }

        // p에는 commentId(keyProperty) 포함됨
        return p;
    }

    /**
     * 코멘트 수정 (작성자만)
     * - 파라미터: commentId, userId, content, secretAt
     * - 반환: 업데이트 건수
     */
    @Transactional
    public int updateComment(Map<String, Object> param) {
        if (param.get("commentId") == null || param.get("userId") == null) {
            throw new IllegalArgumentException("required: commentId, userId");
        }
        if (param.get("secretAt") == null) param.put("secretAt", "N");
        return dao.update(namespace + ".updateComment", param);
    }

    /**
     * 코멘트 삭제(소프트) - 작성자만
     * - 파라미터: commentId, userId
     * - 반환: 업데이트 건수
     */
    @Transactional
    public int deleteComment(Map<String, Object> param) {
        if (param.get("commentId") == null || param.get("userId") == null) {
            throw new IllegalArgumentException("required: commentId, userId");
        }
        return dao.update(namespace + ".softDeleteComment", param);
    }

    private Long toLong(Object v) {
        if (v == null) return null;
        if (v instanceof Number) return ((Number) v).longValue();
        try { return Long.parseLong(String.valueOf(v)); } catch (Exception e) { return null; }
    }
}