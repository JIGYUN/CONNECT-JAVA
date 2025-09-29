package www.api.sys.menuGroup.web;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

import www.api.sys.menuGroup.service.MenuGroupService;
import www.com.user.service.UserSessionManager;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
public class MenuGroupController {

    @Autowired
    private MenuGroupService menuGroupService;

    /**
     * 게시판 목록 조회
     */
    @RequestMapping("/api/sys/menuGroup/selectMenuGroupList")
    @ResponseBody
    public Map<String, Object> selectMenuGroupList(@RequestBody HashMap<String, Object> map) throws Exception {
        Map<String, Object> resultMap = new HashMap<>();
        List<Map<String, Object>> result = menuGroupService.selectMenuGroupList(map);
        resultMap.put("msg", "성공");
        resultMap.put("result", result);
        return resultMap;
    }

    /**
     * 게시판 단건 조회
     */
    @RequestMapping("/api/sys/menuGroup/selectMenuGroupDetail")
    @ResponseBody
    public Map<String, Object> selectMenuGroupDetail(@RequestBody HashMap<String, Object> map) throws Exception {
        Map<String, Object> resultMap = new HashMap<>();
        Map<String, Object> result = menuGroupService.selectMenuGroupDetail(map);
        resultMap.put("msg", "성공");
        resultMap.put("result", result);
        return resultMap;
    }

    /**
     * 게시글 등록
     */
    @RequestMapping("/api/sys/menuGroup/insertMenuGroup")
    @ResponseBody
    public Map<String, Object> insertMenuGroup(@RequestBody HashMap<String, Object> map) throws Exception {
        if (UserSessionManager.isUserLogined()) {   	
        	map.put("createUser", UserSessionManager.getLoginUserVO().getEmail());
        }
        Map<String, Object> resultMap = new HashMap<>();
        menuGroupService.insertMenuGroup(map);
        resultMap.put("msg", "등록 성공");
        return resultMap;
    }

    /**
     * 게시글 수정
     */
    @RequestMapping("/api/sys/menuGroup/updateMenuGroup")
    @ResponseBody
    public Map<String, Object> updateMenuGroup(@RequestBody HashMap<String, Object> map) throws Exception {
        if (UserSessionManager.isUserLogined()) {   	
        	map.put("updateUser", UserSessionManager.getLoginUserVO().getEmail());
        }
        Map<String, Object> resultMap = new HashMap<>();
        menuGroupService.updateMenuGroup(map);
        resultMap.put("msg", "수정 성공");
        return resultMap;
    }

    /**
     * 게시글 삭제
     */
    @RequestMapping("/api/sys/menuGroup/deleteMenuGroup")
    @ResponseBody
    public Map<String, Object> deleteMenuGroup(@RequestBody HashMap<String, Object> map) throws Exception {
        Map<String, Object> resultMap = new HashMap<>();
        menuGroupService.deleteMenuGroup(map);
        resultMap.put("msg", "삭제 성공");
        return resultMap;
    }

    /**
     * 게시글 개수
     */
    @RequestMapping("/api/sys/menuGroup/selectMenuGroupListCount")
    @ResponseBody
    public Map<String, Object> selectMenuGroupListCount(@RequestBody HashMap<String, Object> map) throws Exception {
        Map<String, Object> resultMap = new HashMap<>();
        int count = menuGroupService.selectMenuGroupListCount(map);
        resultMap.put("msg", "성공");
        resultMap.put("count", count);
        return resultMap;
    }
}
