package www.api.isu.issueComment.web;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

import www.api.isu.issueComment.service.issueCommentService;
import www.com.user.service.UserSessionManager;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
public class issueCommentController {

    @Autowired
    private issueCommentService issueCommentService;

    /**
     * 게시판 목록 조회
     */
    @RequestMapping("/api/isu/issueComment/selectissueCommentList")
    @ResponseBody
    public Map<String, Object> selectissueCommentList(@RequestBody HashMap<String, Object> map) throws Exception {
        Map<String, Object> resultMap = new HashMap<>();
        List<Map<String, Object>> result = issueCommentService.selectissueCommentList(map);
        resultMap.put("msg", "성공");
        resultMap.put("result", result);
        return resultMap;
    }

    /**
     * 게시판 단건 조회
     */
    @RequestMapping("/api/isu/issueComment/selectissueCommentDetail")
    @ResponseBody
    public Map<String, Object> selectissueCommentDetail(@RequestBody HashMap<String, Object> map) throws Exception {
        Map<String, Object> resultMap = new HashMap<>();
        Map<String, Object> result = issueCommentService.selectissueCommentDetail(map);
        resultMap.put("msg", "성공");
        resultMap.put("result", result);
        return resultMap;
    }

    /**
     * 게시글 등록
     */
    @RequestMapping("/api/isu/issueComment/insertissueComment")
    @ResponseBody
    public Map<String, Object> insertissueComment(@RequestBody HashMap<String, Object> map) throws Exception {
        if (UserSessionManager.isUserLogined()) {   	
        	map.put("createUser", UserSessionManager.getLoginUserVO().getEmail());
        }
        Map<String, Object> resultMap = new HashMap<>();
        issueCommentService.insertissueComment(map);
        resultMap.put("msg", "등록 성공");
        return resultMap;
    }

    /**
     * 게시글 수정
     */
    @RequestMapping("/api/isu/issueComment/updateissueComment")
    @ResponseBody
    public Map<String, Object> updateissueComment(@RequestBody HashMap<String, Object> map) throws Exception {
        if (UserSessionManager.isUserLogined()) {   	
        	map.put("updateUser", UserSessionManager.getLoginUserVO().getEmail());
        }
        Map<String, Object> resultMap = new HashMap<>();
        issueCommentService.updateissueComment(map);
        resultMap.put("msg", "수정 성공");
        return resultMap;
    }

    /**
     * 게시글 삭제
     */
    @RequestMapping("/api/isu/issueComment/deleteissueComment")
    @ResponseBody
    public Map<String, Object> deleteissueComment(@RequestBody HashMap<String, Object> map) throws Exception {
        Map<String, Object> resultMap = new HashMap<>();
        issueCommentService.deleteissueComment(map);
        resultMap.put("msg", "삭제 성공");
        return resultMap;
    }

    /**
     * 게시글 개수
     */
    @RequestMapping("/api/isu/issueComment/selectissueCommentListCount")
    @ResponseBody
    public Map<String, Object> selectissueCommentListCount(@RequestBody HashMap<String, Object> map) throws Exception {
        Map<String, Object> resultMap = new HashMap<>();
        int count = issueCommentService.selectissueCommentListCount(map);
        resultMap.put("msg", "성공");
        resultMap.put("count", count);
        return resultMap;
    }
}
