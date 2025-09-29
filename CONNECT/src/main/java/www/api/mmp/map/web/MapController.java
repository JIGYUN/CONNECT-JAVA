package www.api.mmp.map.web;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

import www.api.mmp.map.service.MapService;
import www.com.user.service.UserSessionManager;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
public class MapController {

    @Autowired
    private MapService mapService;

    /**
     * 게시판 목록 조회 (비페이징, 기존)
     */
    @RequestMapping(value = "/api/mmp/map/selectMapList", method = RequestMethod.POST)
    @ResponseBody
    public Map<String, Object> selectMapList(@RequestBody HashMap<String, Object> map) {
        Map<String, Object> resultMap = new HashMap<>();
        List<Map<String, Object>> result = mapService.selectMapList(map);
        resultMap.put("msg", "성공");
        resultMap.put("result", result);
        return resultMap;
    }

    /**
     * 게시판 단건 조회
     */
    @RequestMapping(value = "/api/mmp/map/selectMapDetail", method = RequestMethod.POST)
    @ResponseBody
    public Map<String, Object> selectMapDetail(@RequestBody HashMap<String, Object> map) {
        Map<String, Object> resultMap = new HashMap<>();
        Map<String, Object> result = mapService.selectMapDetail(map);
        resultMap.put("msg", "성공");
        resultMap.put("result", result);
        return resultMap;
    }

    /**
     * 게시글 등록
     */
    @RequestMapping(value = "/api/mmp/map/insertMap", method = RequestMethod.POST)
    @ResponseBody
    public Map<String, Object> insertMap(@RequestBody HashMap<String, Object> map) {
        if (UserSessionManager.isUserLogined()) {
            map.put("createUser", UserSessionManager.getLoginUserVO().getEmail());
        }
        Map<String, Object> resultMap = new HashMap<>();
        mapService.insertMap(map);
        resultMap.put("msg", "등록 성공");
        return resultMap;
    }

    /**
     * 게시글 수정
     */
    @RequestMapping(value = "/api/mmp/map/updateMap", method = RequestMethod.POST)
    @ResponseBody
    public Map<String, Object> updateMap(@RequestBody HashMap<String, Object> map) {
        if (UserSessionManager.isUserLogined()) {
            map.put("updateUser", UserSessionManager.getLoginUserVO().getEmail());
        }
        Map<String, Object> resultMap = new HashMap<>();
        mapService.updateMap(map);
        resultMap.put("msg", "수정 성공");
        return resultMap;
    }

    /**
     * 게시글 삭제
     */
    @RequestMapping(value = "/api/mmp/map/deleteMap", method = RequestMethod.POST)
    @ResponseBody
    public Map<String, Object> deleteMap(@RequestBody HashMap<String, Object> map) {
        Map<String, Object> resultMap = new HashMap<>();
        mapService.deleteMap(map);
        resultMap.put("msg", "삭제 성공");
        return resultMap;
    }

    /**
     * 게시글 개수 (기존)
     */
    @RequestMapping(value = "/api/mmp/map/selectMapListCount", method = RequestMethod.POST)
    @ResponseBody
    public Map<String, Object> selectMapListCount(@RequestBody HashMap<String, Object> map) {
        Map<String, Object> resultMap = new HashMap<>();
        int count = mapService.selectMapListCount(map);
        resultMap.put("msg", "성공");
        resultMap.put("count", count);
        return resultMap;
    }

    /**
     * 지도 목록(페이징) - 신규
     * 요청: { page, size, grpCd, ... }
     * 응답: { ok:true, result:[...], page:{...} }
     */
    @RequestMapping(value = "/api/mmp/map/selectMapListPaged", method = RequestMethod.POST)
    @ResponseBody
    public Map<String, Object> selectMapListPaged(@RequestBody HashMap<String, Object> map) {
        Map<String, Object> helperOut = mapService.selectMapListPaged(map);

        Map<String, Object> res = new HashMap<>();
        res.put("ok", true);
        res.put("result", helperOut.get("list"));
        res.put("page", helperOut.get("page"));
        return res;
    }
}