package www.api.sys.cmmnCode.web;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

import www.api.sys.cmmnCode.service.CmmnCodeService;
import www.com.user.service.UserSessionManager;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
public class CmmnCodeController {

    @Autowired
    private CmmnCodeService cmmnCodeService;

    /**
     * 게시판 목록 조회
     */
    @RequestMapping("/api/sys/cmmnCode/selectCmmnCodeList")
    @ResponseBody
    public Map<String, Object> selectCmmnCodeList(@RequestBody HashMap<String, Object> map) throws Exception {
        Map<String, Object> resultMap = new HashMap<>();
        List<Map<String, Object>> result = cmmnCodeService.selectCmmnCodeList(map);
        resultMap.put("msg", "성공");
        resultMap.put("result", result);
        return resultMap;
    }

    /**
     * 게시판 단건 조회
     */
    @RequestMapping("/api/sys/cmmnCode/selectCmmnCodeDetail")
    @ResponseBody
    public Map<String, Object> selectCmmnCodeDetail(@RequestBody HashMap<String, Object> map) throws Exception {
        Map<String, Object> resultMap = new HashMap<>();
        Map<String, Object> result = cmmnCodeService.selectCmmnCodeDetail(map);
        resultMap.put("msg", "성공");
        resultMap.put("result", result);
        return resultMap;
    }

    /**
     * 게시글 등록
     */
    @RequestMapping("/api/sys/cmmnCode/insertCmmnCode")
    @ResponseBody
    public Map<String, Object> insertCmmnCode(@RequestBody HashMap<String, Object> map) throws Exception {
        if (UserSessionManager.isUserLogined()) {   	
        	map.put("createUser", UserSessionManager.getLoginUserVO().getEmail());
        }
        Map<String, Object> resultMap = new HashMap<>();
        cmmnCodeService.insertCmmnCode(map);
        resultMap.put("msg", "등록 성공");
        return resultMap;
    }

    /**
     * 게시글 수정
     */
    @RequestMapping("/api/sys/cmmnCode/updateCmmnCode")
    @ResponseBody
    public Map<String, Object> updateCmmnCode(@RequestBody HashMap<String, Object> map) throws Exception {
        if (UserSessionManager.isUserLogined()) {   	
        	map.put("updateUser", UserSessionManager.getLoginUserVO().getEmail());
        }
        Map<String, Object> resultMap = new HashMap<>();
        cmmnCodeService.updateCmmnCode(map);
        resultMap.put("msg", "수정 성공");
        return resultMap;
    }

    /**
     * 게시글 삭제
     */
    @RequestMapping("/api/sys/cmmnCode/deleteCmmnCode")
    @ResponseBody
    public Map<String, Object> deleteCmmnCode(@RequestBody HashMap<String, Object> map) throws Exception {
        Map<String, Object> resultMap = new HashMap<>();
        cmmnCodeService.deleteCmmnCode(map);
        resultMap.put("msg", "삭제 성공");
        return resultMap;
    }

    /**
     * 게시글 개수
     */
    @RequestMapping("/api/sys/cmmnCode/selectCmmnCodeListCount")
    @ResponseBody
    public Map<String, Object> selectCmmnCodeListCount(@RequestBody HashMap<String, Object> map) throws Exception {
        Map<String, Object> resultMap = new HashMap<>();
        int count = cmmnCodeService.selectCmmnCodeListCount(map);
        resultMap.put("msg", "성공");
        resultMap.put("count", count);
        return resultMap;
    }
}
