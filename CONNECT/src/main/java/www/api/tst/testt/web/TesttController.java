package www.api.tst.testt.web;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

import www.api.tst.testt.service.TesttService;
import www.com.user.service.UserSessionManager;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
public class TesttController {

    @Autowired
    private TesttService testtService;

    /**
     * 게시판 목록 조회
     */
    @RequestMapping("/api/tst/testt/selectTesttList")
    @ResponseBody
    public Map<String, Object> selectTesttList(@RequestBody HashMap<String, Object> map) throws Exception {
        Map<String, Object> resultMap = new HashMap<>();
        List<Map<String, Object>> result = testtService.selectTesttList(map);
        resultMap.put("msg", "성공");
        resultMap.put("result", result);
        return resultMap;
    }

    /**
     * 게시판 단건 조회
     */
    @RequestMapping("/api/tst/testt/selectTesttDetail")
    @ResponseBody
    public Map<String, Object> selectTesttDetail(@RequestBody HashMap<String, Object> map) throws Exception {
        Map<String, Object> resultMap = new HashMap<>();
        Map<String, Object> result = testtService.selectTesttDetail(map);
        resultMap.put("msg", "성공");
        resultMap.put("result", result);
        return resultMap;
    }

    /**
     * 게시글 등록
     */
    @RequestMapping("/api/tst/testt/insertTestt")
    @ResponseBody
    public Map<String, Object> insertTestt(@RequestBody HashMap<String, Object> map) throws Exception {
        if (UserSessionManager.isUserLogined()) {   	
        	map.put("createUser", UserSessionManager.getLoginUserVO().getUserId());
        }
        Map<String, Object> resultMap = new HashMap<>();
        testtService.insertTestt(map);
        resultMap.put("msg", "등록 성공");
        return resultMap;
    }

    /**
     * 게시글 수정
     */
    @RequestMapping("/api/tst/testt/updateTestt")
    @ResponseBody
    public Map<String, Object> updateTestt(@RequestBody HashMap<String, Object> map) throws Exception {
        if (UserSessionManager.isUserLogined()) {   	
        	map.put("updateUser", UserSessionManager.getLoginUserVO().getUserId());
        }
        Map<String, Object> resultMap = new HashMap<>();
        testtService.updateTestt(map);
        resultMap.put("msg", "수정 성공");
        return resultMap;
    }

    /**
     * 게시글 삭제
     */
    @RequestMapping("/api/tst/testt/deleteTestt")
    @ResponseBody
    public Map<String, Object> deleteTestt(@RequestBody HashMap<String, Object> map) throws Exception {
        Map<String, Object> resultMap = new HashMap<>();
        testtService.deleteTestt(map);
        resultMap.put("msg", "삭제 성공");
        return resultMap;
    }

    /**
     * 게시글 개수
     */
    @RequestMapping("/api/tst/testt/selectTesttListCount")
    @ResponseBody
    public Map<String, Object> selectTesttListCount(@RequestBody HashMap<String, Object> map) throws Exception {
        Map<String, Object> resultMap = new HashMap<>();
        int count = testtService.selectTesttListCount(map);
        resultMap.put("msg", "성공");
        resultMap.put("count", count);
        return resultMap;
    }
}
