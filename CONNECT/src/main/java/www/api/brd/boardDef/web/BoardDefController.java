package www.api.brd.boardDef.web;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

import www.api.brd.boardDef.service.BoardDefService;
import www.com.user.service.UserSessionManager;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
public class BoardDefController {

    @Autowired
    private BoardDefService boardDefService;

    /**
     * 게시판 목록 조회
     */
    @RequestMapping("/api/brd/boardDef/selectBoardDefList")
    @ResponseBody
    public Map<String, Object> selectBoardDefList(@RequestBody HashMap<String, Object> map) throws Exception {
        Map<String, Object> resultMap = new HashMap<>();
        List<Map<String, Object>> result = boardDefService.selectBoardDefList(map);
        resultMap.put("msg", "성공");
        resultMap.put("result", result);
        return resultMap;
    }

    /**
     * 게시판 단건 조회
     */
    @RequestMapping("/api/brd/boardDef/selectBoardDefDetail")
    @ResponseBody
    public Map<String, Object> selectBoardDefDetail(@RequestBody HashMap<String, Object> map) throws Exception {
        Map<String, Object> resultMap = new HashMap<>();
        Map<String, Object> result = boardDefService.selectBoardDefDetail(map);
        resultMap.put("msg", "성공");
        resultMap.put("result", result);
        return resultMap;
    }

    /**
     * 게시글 등록
     */
    @RequestMapping("/api/brd/boardDef/insertBoardDef")
    @ResponseBody
    public Map<String, Object> insertBoardDef(@RequestBody HashMap<String, Object> map) throws Exception {
        if (UserSessionManager.isUserLogined()) {   	
        	map.put("createUser", UserSessionManager.getLoginUserVO().getEmail());
        }
        Map<String, Object> resultMap = new HashMap<>();
        boardDefService.insertBoardDef(map);
        resultMap.put("msg", "등록 성공");
        return resultMap;
    }

    /**
     * 게시글 수정
     */
    @RequestMapping("/api/brd/boardDef/updateBoardDef")
    @ResponseBody
    public Map<String, Object> updateBoardDef(@RequestBody HashMap<String, Object> map) throws Exception {
        if (UserSessionManager.isUserLogined()) {   	
        	map.put("updateUser", UserSessionManager.getLoginUserVO().getEmail());
        }
        Map<String, Object> resultMap = new HashMap<>();
        boardDefService.updateBoardDef(map);
        resultMap.put("msg", "수정 성공");
        return resultMap;
    }

    /**
     * 게시글 삭제
     */
    @RequestMapping("/api/brd/boardDef/deleteBoardDef")
    @ResponseBody
    public Map<String, Object> deleteBoardDef(@RequestBody HashMap<String, Object> map) throws Exception {
        Map<String, Object> resultMap = new HashMap<>();
        boardDefService.deleteBoardDef(map);
        resultMap.put("msg", "삭제 성공");
        return resultMap;
    }

    /**
     * 게시글 개수
     */
    @RequestMapping("/api/brd/boardDef/selectBoardDefListCount")
    @ResponseBody
    public Map<String, Object> selectBoardDefListCount(@RequestBody HashMap<String, Object> map) throws Exception {
        Map<String, Object> resultMap = new HashMap<>();
        int count = boardDefService.selectBoardDefListCount(map);
        resultMap.put("msg", "성공");
        resultMap.put("count", count);
        return resultMap;
    }
}
