package www.api.com.comment.web;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;
import www.api.com.comment.service.CommentService;
import www.com.user.service.UserSessionManager;

import javax.servlet.http.HttpServletRequest;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
public class CommentController {

    @Autowired
    private CommentService commentService;

    private Long currentUserId() {
        try {
            if (UserSessionManager.isUserLogined()) {
                // 프로젝트 VO에 맞춰서 getUserId() / getIdx() 등으로 바꿔도 됨
                return Long.parseLong(UserSessionManager.getLoginUserVO().getUserId());
            }
        } catch (Throwable ignore) { } 
        return null;
    }

    /** 타겟별 목록 (닉네임/ME 포함) */
    @RequestMapping("/api/com/comment/listByTarget")
    @ResponseBody
    public Map<String, Object> listByTarget(@RequestBody HashMap<String, Object> param) {
        // 현재 로그인 사용자 → mapper 의 ME 계산에 사용
        Long uid = currentUserId();
        if (uid != null) param.put("viewerUserId", uid);

        List<Map<String, Object>> list = commentService.selectCommentListByTarget(param);
        Map<String, Object> res = new HashMap<>();
        res.put("msg", "성공");
        res.put("result", list);
        return res;
    }

    /** 등록 (root/child 공용) */
    @RequestMapping("/api/com/comment/insert")
    @ResponseBody
    public Map<String, Object> insert(@RequestBody HashMap<String, Object> param) {
        Long uid = currentUserId();
        if (uid == null) throw new RuntimeException("로그인이 필요합니다.");
        param.put("userId", uid);

        Map<String, Object> saved = commentService.insertComment(param);
        Map<String, Object> res = new HashMap<>();
        res.put("msg", "등록 성공");
        res.put("result", saved);
        return res;
    }

    /** 수정(본문/비밀) – 필요 시 */
    @RequestMapping("/api/com/comment/update")
    @ResponseBody
    public Map<String, Object> update(@RequestBody HashMap<String, Object> param) {
        Long uid = currentUserId();
        if (uid == null) throw new RuntimeException("로그인이 필요합니다.");
        param.put("userId", uid);

        int cnt = commentService.updateComment(param);
        Map<String, Object> res = new HashMap<>();
        res.put("msg", cnt > 0 ? "수정 성공" : "수정 대상 없음");
        res.put("count", cnt);
        return res;
    }

    /** 삭제(소프트) */
    @RequestMapping("/api/com/comment/delete")
    @ResponseBody
    public Map<String, Object> delete(@RequestBody HashMap<String, Object> param) {
        Long uid = currentUserId();
        if (uid == null) throw new RuntimeException("로그인이 필요합니다.");
        param.put("userId", uid);

        int cnt = commentService.deleteComment(param);
        Map<String, Object> res = new HashMap<>();
        res.put("msg", cnt > 0 ? "삭제 성공" : "삭제 권한 없음");
        res.put("count", cnt);
        return res;
    }
}