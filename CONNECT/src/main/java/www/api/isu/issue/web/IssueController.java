package www.api.isu.issue.web;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

import www.api.isu.issue.service.IssueService;
import www.com.user.service.UserSessionManager;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
public class IssueController {

    @Autowired
    private IssueService issueService;

    /**
     * 이슈 목록 조회
     */
    @RequestMapping("/api/isu/issue/selectIssueList")
    @ResponseBody
    public Map<String, Object> selectIssueList(@RequestBody HashMap<String, Object> map) throws Exception {
        Map<String, Object> resultMap = new HashMap<>();
        List<Map<String, Object>> result = issueService.selectIssueList(map);
        resultMap.put("msg", "성공");
        resultMap.put("result", result);
        return resultMap;
    }

    /**
     * 이슈 단건 조회
     */
    @RequestMapping("/api/isu/issue/selectIssueDetail")
    @ResponseBody
    public Map<String, Object> selectIssueDetail(@RequestBody HashMap<String, Object> map) throws Exception {
        Map<String, Object> resultMap = new HashMap<>();
        Map<String, Object> result = issueService.selectIssueDetail(map);
        resultMap.put("msg", "성공");
        resultMap.put("result", result);
        return resultMap;
    }

    /**
     * 이슈 등록
     */
    @RequestMapping("/api/isu/issue/insertIssue")
    @ResponseBody
    public Map<String, Object> insertIssue(@RequestBody HashMap<String, Object> map) throws Exception {
        if (UserSessionManager.isUserLogined()) {
            map.put("createdBy", UserSessionManager.getLoginUserVO().getEmail());
        }
        Map<String, Object> resultMap = new HashMap<>();
        issueService.insertIssue(map);
        resultMap.put("msg", "등록 성공");
        return resultMap;
    }

    /**
     * 이슈 수정
     */
    @RequestMapping("/api/isu/issue/updateIssue")
    @ResponseBody
    public Map<String, Object> updateIssue(@RequestBody HashMap<String, Object> map) throws Exception {
        if (UserSessionManager.isUserLogined()) {
            map.put("updatedBy", UserSessionManager.getLoginUserVO().getEmail());
        }
        Map<String, Object> resultMap = new HashMap<>();
        issueService.updateIssue(map);
        resultMap.put("msg", "수정 성공");
        return resultMap;
    }

    /**
     * 이슈 삭제
     */
    @RequestMapping("/api/isu/issue/deleteIssue")
    @ResponseBody
    public Map<String, Object> deleteIssue(@RequestBody HashMap<String, Object> map) throws Exception {
        Map<String, Object> resultMap = new HashMap<>();
        issueService.deleteIssue(map);
        resultMap.put("msg", "삭제 성공");
        return resultMap;
    }

    /**
     * 이슈 개수
     */
    @RequestMapping("/api/isu/issue/selectIssueListCount")
    @ResponseBody
    public Map<String, Object> selectIssueListCount(@RequestBody HashMap<String, Object> map) throws Exception {
        Map<String, Object> resultMap = new HashMap<>();
        int count = issueService.selectIssueListCount(map);
        resultMap.put("msg", "성공");
        resultMap.put("count", count);
        return resultMap;
    }

    /**
     * 칸반 보드용 이슈 목록 조회
     * body: { grpCd, prjId }
     */
    @RequestMapping("/api/isu/issue/selectIssueBoardList")
    @ResponseBody
    public Map<String, Object> selectIssueBoardList(@RequestBody HashMap<String, Object> map) throws Exception {
        Map<String, Object> resultMap = new HashMap<>();
        List<Map<String, Object>> result = issueService.selectIssueBoardList(map);
        resultMap.put("msg", "성공");
        resultMap.put("result", result);
        return resultMap;
    }

    /**
     * 칸반 보드에서 상태만 변경
     * body: { issueId, statusCd }
     */
    @RequestMapping("/api/isu/issue/updateIssueStatus")
    @ResponseBody
    public Map<String, Object> updateIssueStatus(@RequestBody HashMap<String, Object> map) throws Exception {
        if (UserSessionManager.isUserLogined()) {
            map.put("updatedBy", UserSessionManager.getLoginUserVO().getEmail());
        }
        issueService.updateIssueStatus(map);

        Map<String, Object> resultMap = new HashMap<>();
        resultMap.put("msg", "성공");
        return resultMap;
    }
}
