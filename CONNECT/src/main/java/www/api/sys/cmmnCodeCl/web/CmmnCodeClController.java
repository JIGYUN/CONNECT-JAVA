package www.api.sys.cmmnCodeCl.web;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

import www.api.sys.cmmnCodeCl.service.CmmnCodeClService;
import www.com.user.service.UserSessionManager;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
public class CmmnCodeClController {

    @Autowired
    private CmmnCodeClService cmmnCodeClService;

    /**
     * 게시판 목록 조회
     */
    @RequestMapping("/api/sys/cmmnCodeCl/selectCmmnCodeClList")
    @ResponseBody
    public Map<String, Object> selectCmmnCodeClList(@RequestBody HashMap<String, Object> map) throws Exception {
        Map<String, Object> resultMap = new HashMap<>();
        List<Map<String, Object>> result = cmmnCodeClService.selectCmmnCodeClList(map);
        resultMap.put("msg", "성공");
        resultMap.put("result", result);
        return resultMap;
    }

    /**
     * 게시판 단건 조회
     */
    @RequestMapping("/api/sys/cmmnCodeCl/selectCmmnCodeClDetail")
    @ResponseBody
    public Map<String, Object> selectCmmnCodeClDetail(@RequestBody HashMap<String, Object> map) throws Exception {
        Map<String, Object> resultMap = new HashMap<>();
        Map<String, Object> result = cmmnCodeClService.selectCmmnCodeClDetail(map);
        resultMap.put("msg", "성공");
        resultMap.put("result", result);
        return resultMap;
    }

    /**
     * 게시글 등록
     */
    @RequestMapping("/api/sys/cmmnCodeCl/insertCmmnCodeCl")
    @ResponseBody
    public Map<String, Object> insertCmmnCodeCl(@RequestBody HashMap<String, Object> map) throws Exception {
        if (UserSessionManager.isUserLogined()) {   	
        	map.put("createUser", UserSessionManager.getLoginUserVO().getEmail());
        }
        Map<String, Object> resultMap = new HashMap<>();
        cmmnCodeClService.insertCmmnCodeCl(map);
        resultMap.put("msg", "등록 성공");
        return resultMap;
    }

    /**
     * 게시글 수정
     */
    @RequestMapping("/api/sys/cmmnCodeCl/updateCmmnCodeCl")
    @ResponseBody
    public Map<String, Object> updateCmmnCodeCl(@RequestBody HashMap<String, Object> map) throws Exception {
        if (UserSessionManager.isUserLogined()) {   	
        	map.put("updateUser", UserSessionManager.getLoginUserVO().getEmail());
        }
        Map<String, Object> resultMap = new HashMap<>();
        cmmnCodeClService.updateCmmnCodeCl(map);
        resultMap.put("msg", "수정 성공");
        return resultMap;
    }

    /**
     * 게시글 삭제
     */
    @RequestMapping("/api/sys/cmmnCodeCl/deleteCmmnCodeCl")
    @ResponseBody
    public Map<String, Object> deleteCmmnCodeCl(@RequestBody HashMap<String, Object> map) throws Exception {
        Map<String, Object> resultMap = new HashMap<>();
        cmmnCodeClService.deleteCmmnCodeCl(map);
        resultMap.put("msg", "삭제 성공");
        return resultMap;
    }

    /**
     * 게시글 개수
     */
    @RequestMapping("/api/sys/cmmnCodeCl/selectCmmnCodeClListCount")
    @ResponseBody
    public Map<String, Object> selectCmmnCodeClListCount(@RequestBody HashMap<String, Object> map) throws Exception {
        Map<String, Object> resultMap = new HashMap<>();
        int count = cmmnCodeClService.selectCmmnCodeClListCount(map);
        resultMap.put("msg", "성공");
        resultMap.put("count", count);
        return resultMap;
    }
}
