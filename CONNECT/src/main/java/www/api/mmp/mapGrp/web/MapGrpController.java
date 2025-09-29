package www.api.mmp.mapGrp.web;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

import www.api.mmp.mapGrp.service.MapGrpService;
import www.com.user.service.UserSessionManager;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
public class MapGrpController {

    @Autowired
    private MapGrpService mapGrpService;

    /**
     * 게시판 목록 조회
     */
    @RequestMapping("/api/mmp/mapGrp/selectMapGrpList")
    @ResponseBody
    public Map<String, Object> selectMapGrpList(@RequestBody HashMap<String, Object> map) throws Exception {
        Map<String, Object> resultMap = new HashMap<>();
        List<Map<String, Object>> result = mapGrpService.selectMapGrpList(map);
        resultMap.put("msg", "성공");
        resultMap.put("result", result);
        return resultMap;
    }

    /**
     * 게시판 단건 조회
     */
    @RequestMapping("/api/mmp/mapGrp/selectMapGrpDetail")
    @ResponseBody
    public Map<String, Object> selectMapGrpDetail(@RequestBody HashMap<String, Object> map) throws Exception {
        Map<String, Object> resultMap = new HashMap<>();
        Map<String, Object> result = mapGrpService.selectMapGrpDetail(map);
        resultMap.put("msg", "성공");
        resultMap.put("result", result);
        return resultMap;
    }

    /**
     * 게시글 등록
     */
    @RequestMapping("/api/mmp/mapGrp/insertMapGrp")
    @ResponseBody
    public Map<String, Object> insertMapGrp(@RequestBody HashMap<String, Object> map) throws Exception {
        if (UserSessionManager.isUserLogined()) {   	
        	map.put("createUser", UserSessionManager.getLoginUserVO().getEmail());
        }
        Map<String, Object> resultMap = new HashMap<>();
        mapGrpService.insertMapGrp(map);
        resultMap.put("msg", "등록 성공");
        return resultMap;
    }

    /**
     * 게시글 수정
     */
    @RequestMapping("/api/mmp/mapGrp/updateMapGrp")
    @ResponseBody
    public Map<String, Object> updateMapGrp(@RequestBody HashMap<String, Object> map) throws Exception {
        if (UserSessionManager.isUserLogined()) {   	
        	map.put("updateUser", UserSessionManager.getLoginUserVO().getEmail());
        }
        Map<String, Object> resultMap = new HashMap<>();
        mapGrpService.updateMapGrp(map);
        resultMap.put("msg", "수정 성공");
        return resultMap;
    }

    /**
     * 게시글 삭제
     */
    @RequestMapping("/api/mmp/mapGrp/deleteMapGrp")
    @ResponseBody
    public Map<String, Object> deleteMapGrp(@RequestBody HashMap<String, Object> map) throws Exception {
        Map<String, Object> resultMap = new HashMap<>();
        mapGrpService.deleteMapGrp(map);
        resultMap.put("msg", "삭제 성공");
        return resultMap;
    }

    /**
     * 게시글 개수
     */
    @RequestMapping("/api/mmp/mapGrp/selectMapGrpListCount")
    @ResponseBody
    public Map<String, Object> selectMapGrpListCount(@RequestBody HashMap<String, Object> map) throws Exception {
        Map<String, Object> resultMap = new HashMap<>();
        int count = mapGrpService.selectMapGrpListCount(map);
        resultMap.put("msg", "성공");
        resultMap.put("count", count);
        return resultMap;
    }
}
