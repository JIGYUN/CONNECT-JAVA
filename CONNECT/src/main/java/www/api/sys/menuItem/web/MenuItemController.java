package www.api.sys.menuItem.web;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

import www.api.sys.menuItem.service.MenuItemService;
import www.com.user.service.UserSessionManager;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;

@Controller
public class MenuItemController {

    @Autowired
    private MenuItemService menuItemService;

    /**
     * 게시판 목록 조회
     */
    @RequestMapping("/api/sys/menuItem/selectMenuItemList")
    @ResponseBody
    public Map<String, Object> selectMenuItemList(@RequestBody HashMap<String, Object> map) throws Exception {
        Map<String, Object> resultMap = new HashMap<>();
        List<Map<String, Object>> result = menuItemService.selectMenuItemList(map);
        resultMap.put("msg", "성공");
        resultMap.put("result", result);
        return resultMap;
    }

    /**
     * 게시판 단건 조회
     */
    @RequestMapping("/api/sys/menuItem/selectMenuItemDetail")
    @ResponseBody
    public Map<String, Object> selectMenuItemDetail(@RequestBody HashMap<String, Object> map) throws Exception {
        Map<String, Object> resultMap = new HashMap<>();
        Map<String, Object> result = menuItemService.selectMenuItemDetail(map);
        resultMap.put("msg", "성공");
        resultMap.put("result", result);
        return resultMap;
    }
    
    @GetMapping("/api/sys/menuItem/sideNav")
    @ResponseBody
    public Map<String, Object> sideNav(
            @RequestParam(value = "menuGroupId", required = false) String menuGroupId,
            HttpServletRequest request) {

        // 값이 없으면 URL로 추정: /adm*면 2(관리자), 그 외 1(프론트)
        if (menuGroupId == null || menuGroupId.trim().isEmpty()) {
            String uri = request.getRequestURI();
            menuGroupId = (uri != null && uri.startsWith("/adm")) ? "2" : "1";
        }

        List<String> roleList = new ArrayList<>();
        roleList.add("USER");
        roleList.add("EXTERNAL_AUTH");
        if (UserSessionManager.isUserLogined()
                && "A".equalsIgnoreCase(UserSessionManager.getLoginUserVO().getAuthType())) {
            roleList.add("ADMIN");
        }

        List<Map<String, Object>> sections =
                menuItemService.selectSidebarTree(menuGroupId, roleList);

        Map<String, Object> result = new HashMap<>();
        result.put("msg", "성공");
        result.put("sections", sections);
        return result;
    }

    /**
     * 게시글 등록
     */
    @RequestMapping("/api/sys/menuItem/insertMenuItem")
    @ResponseBody
    public Map<String, Object> insertMenuItem(@RequestBody HashMap<String, Object> map) throws Exception {
        if (UserSessionManager.isUserLogined()) {   	
        	map.put("createUser", UserSessionManager.getLoginUserVO().getEmail());
        }
        Map<String, Object> resultMap = new HashMap<>();
        menuItemService.insertMenuItem(map);
        resultMap.put("msg", "등록 성공");
        return resultMap;
    }

    /**
     * 게시글 수정
     */
    @RequestMapping("/api/sys/menuItem/updateMenuItem")
    @ResponseBody
    public Map<String, Object> updateMenuItem(@RequestBody HashMap<String, Object> map) throws Exception {
        if (UserSessionManager.isUserLogined()) {
        	map.put("updateUser", UserSessionManager.getLoginUserVO().getEmail());
        }
        Map<String, Object> resultMap = new HashMap<>();
        menuItemService.updateMenuItem(map);
        resultMap.put("msg", "수정 성공");
        return resultMap;
    }

    /**
     * 게시글 삭제
     */
    @RequestMapping("/api/sys/menuItem/deleteMenuItem")
    @ResponseBody
    public Map<String, Object> deleteMenuItem(@RequestBody HashMap<String, Object> map) throws Exception {
        Map<String, Object> resultMap = new HashMap<>();
        menuItemService.deleteMenuItem(map);
        resultMap.put("msg", "삭제 성공");
        return resultMap;
    }

    /**
     * 게시글 개수
     */
    @RequestMapping("/api/sys/menuItem/selectMenuItemListCount")
    @ResponseBody
    public Map<String, Object> selectMenuItemListCount(@RequestBody HashMap<String, Object> map) throws Exception {
        Map<String, Object> resultMap = new HashMap<>();
        int count = menuItemService.selectMenuItemListCount(map);
        resultMap.put("msg", "성공");
        resultMap.put("count", count);
        return resultMap;
    }
}
