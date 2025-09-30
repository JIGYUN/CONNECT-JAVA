package www.api.tsk.task.web;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

import www.api.tsk.task.service.TaskService;
import www.com.user.service.UserSessionManager;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
public class TaskController {

    @Autowired
    private TaskService taskService;

    /** 게시판 목록 조회 */
    @RequestMapping("/api/tsk/task/selectTaskList")
    @ResponseBody
    public Map<String, Object> selectTaskList(@RequestBody HashMap<String, Object> map) {
        if (UserSessionManager.isUserLogined()) {
            map.put("ownerId", UserSessionManager.getLoginUserVO().getUserId());
        }
        Map<String, Object> resultMap = new HashMap<>();
        List<Map<String, Object>> result = taskService.selectTaskList(map);
        resultMap.put("msg", "성공");
        resultMap.put("result", result);
        return resultMap;
    }

    /** 게시판 단건 조회 */
    @RequestMapping("/api/tsk/task/selectTaskDetail")
    @ResponseBody
    public Map<String, Object> selectTaskDetail(@RequestBody HashMap<String, Object> map) {
        if (UserSessionManager.isUserLogined()) {
            map.put("ownerId", UserSessionManager.getLoginUserVO().getUserId());
        }
        Map<String, Object> resultMap = new HashMap<>();
        Map<String, Object> result = taskService.selectTaskDetail(map);
        resultMap.put("msg", "성공");
        resultMap.put("result", result);
        return resultMap;
    }

    /** 게시글 등록 */
    @RequestMapping("/api/tsk/task/insertTask")
    @ResponseBody
    public Map<String, Object> insertTask(@RequestBody HashMap<String, Object> map) {
        if (UserSessionManager.isUserLogined()) {
            map.put("ownerId", UserSessionManager.getLoginUserVO().getUserId());
        }
        Map<String, Object> resultMap = new HashMap<>();
        taskService.insertTask(map);
        resultMap.put("msg", "등록 성공");
        return resultMap;
    }

    /** 게시글 수정 */
    @RequestMapping("/api/tsk/task/updateTask")
    @ResponseBody
    public Map<String, Object> updateTask(@RequestBody HashMap<String, Object> map) {
        if (UserSessionManager.isUserLogined()) {
            map.put("ownerId", UserSessionManager.getLoginUserVO().getUserId());
        }
        Map<String, Object> resultMap = new HashMap<>();
        taskService.updateTask(map);
        resultMap.put("msg", "수정 성공");
        return resultMap;
    }

    /** 게시글 삭제(Soft) */
    @RequestMapping("/api/tsk/task/deleteTask")
    @ResponseBody
    public Map<String, Object> deleteTask(@RequestBody HashMap<String, Object> map) {
        Map<String, Object> resultMap = new HashMap<>();
        taskService.deleteTask(map);
        resultMap.put("msg", "삭제 성공");
        return resultMap;
    }

    /** 게시글 개수 */
    @RequestMapping("/api/tsk/task/selectTaskListCount")
    @ResponseBody
    public Map<String, Object> selectTaskListCount(@RequestBody HashMap<String, Object> map) {
        if (UserSessionManager.isUserLogined()) {
            map.put("ownerId", UserSessionManager.getLoginUserVO().getUserId());
        }
        Map<String, Object> resultMap = new HashMap<>();
        int count = taskService.selectTaskListCount(map);
        resultMap.put("msg", "성공");
        resultMap.put("count", count);
        return resultMap;
    }

    // ===== 신규 =====

    /** 날짜별 목록(YYYY-MM-DD, null=오늘) */
    @RequestMapping("/api/tsk/task/selectTaskListByDate")
    @ResponseBody
    public Map<String, Object> selectTaskListByDate(@RequestBody HashMap<String, Object> map) {
        if (UserSessionManager.isUserLogined()) {
            map.put("ownerId", UserSessionManager.getLoginUserVO().getUserId());
        }
        Map<String, Object> resultMap = new HashMap<>();
        List<Map<String, Object>> result = taskService.selectTaskListByDate(map);
        resultMap.put("msg", "성공");
        resultMap.put("result", result);
        return resultMap;
    }

    /** 체크박스 토글(TODO/DONE) */
    @RequestMapping("/api/tsk/task/toggleTask")
    @ResponseBody
    public Map<String, Object> toggleTask(@RequestBody HashMap<String, Object> map) {
        if (UserSessionManager.isUserLogined()) {
            map.put("ownerId", UserSessionManager.getLoginUserVO().getUserId());
        }
        Map<String, Object> resultMap = new HashMap<>();
        taskService.toggleTask(map);
        resultMap.put("msg", "변경 성공");
        return resultMap;
    }
}