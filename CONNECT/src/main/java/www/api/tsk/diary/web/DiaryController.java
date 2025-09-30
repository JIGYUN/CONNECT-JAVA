package www.api.tsk.diary.web;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;
import www.api.tsk.diary.service.DiaryService;
import www.com.user.service.UserSessionManager;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
public class DiaryController {

    @Autowired
    private DiaryService diaryService;

    // 목록
    @PostMapping("/api/tsk/diary/selectDiaryList")
    @ResponseBody
    public Map<String, Object> selectDiaryList(@RequestBody HashMap<String, Object> map) {
        if (UserSessionManager.isUserLogined()) {
            map.put("ownerId", UserSessionManager.getLoginUserVO().getUserId());
        }
        Map<String, Object> res = new HashMap<>();
        List<Map<String, Object>> result = diaryService.selectDiaryList(map);
        res.put("ok", true); res.put("msg", "성공"); res.put("result", result);
        return res;
    }

    // 단건(기존: ID 기준)
    @PostMapping("/api/tsk/diary/selectDiaryDetail")
    @ResponseBody
    public Map<String, Object> selectDiaryDetail(@RequestBody HashMap<String, Object> map) {
        if (UserSessionManager.isUserLogined()) {
            map.put("ownerId", UserSessionManager.getLoginUserVO().getUserId());
        }
        Map<String, Object> res = new HashMap<>();
        Map<String, Object> result = diaryService.selectDiaryDetail(map);
        res.put("ok", true); res.put("msg", "성공"); res.put("result", result);
        return res;
    }

    // ✅ 신규: 날짜 기준 단건 조회 (달력뷰)
    @PostMapping("/api/tsk/diary/selectDiaryByDate")
    @ResponseBody
    public Map<String, Object> selectDiaryByDate(@RequestBody HashMap<String, Object> map) {
        if (UserSessionManager.isUserLogined()) {
            map.put("ownerId", UserSessionManager.getLoginUserVO().getUserId());
        }
        Map<String, Object> res = new HashMap<>();
        Map<String, Object> result = diaryService.selectDiaryByDate(map); // {grpCd, diaryDt}
        res.put("ok", true); res.put("msg", "성공"); res.put("result", result);
        return res;
    }

    // 등록
    @PostMapping("/api/tsk/diary/insertDiary")
    @ResponseBody
    public Map<String, Object> insertDiary(@RequestBody HashMap<String, Object> map) {
        if (UserSessionManager.isUserLogined()) {
            map.put("ownerId", UserSessionManager.getLoginUserVO().getUserId());
        }
        
        diaryService.insertDiary(map);
        Map<String, Object> res = new HashMap<>();
        res.put("ok", true); res.put("msg", "등록 성공");
        return res;
    }

    // 수정
    @PostMapping("/api/tsk/diary/updateDiary")
    @ResponseBody
    public Map<String, Object> updateDiary(@RequestBody HashMap<String, Object> map) {
        if (UserSessionManager.isUserLogined()) {
            map.put("ownerId", UserSessionManager.getLoginUserVO().getUserId());
        }
        diaryService.updateDiary(map);
        Map<String, Object> res = new HashMap<>();
        res.put("ok", true); res.put("msg", "수정 성공");
        return res;
    }

    // 삭제
    @PostMapping("/api/tsk/diary/deleteDiary")
    @ResponseBody
    public Map<String, Object> deleteDiary(@RequestBody HashMap<String, Object> map) {
        diaryService.deleteDiary(map);
        Map<String, Object> res = new HashMap<>();
        res.put("ok", true); res.put("msg", "삭제 성공");
        return res;
    }

    // 카운트
    @PostMapping("/api/tsk/diary/selectDiaryListCount")
    @ResponseBody
    public Map<String, Object> selectDiaryListCount(@RequestBody HashMap<String, Object> map) {
        int count = diaryService.selectDiaryListCount(map);
        Map<String, Object> res = new HashMap<>();
        res.put("ok", true); res.put("msg", "성공"); res.put("count", count);
        return res;
    }

    // ✅ 신규: 업서트(1일 1건)
    @PostMapping("/api/tsk/diary/upsertDiary")
    @ResponseBody
    public Map<String, Object> upsertDiary(@RequestBody HashMap<String, Object> map) {
        if (UserSessionManager.isUserLogined()) {
            map.put("ownerId", UserSessionManager.getLoginUserVO().getUserId());
        }
        diaryService.upsertDiary(map); // {grpCd?, diaryDt, content, fileGrpId?}
        Map<String, Object> res = new HashMap<>();
        res.put("ok", true); res.put("msg", "저장 성공");
        return res;
    }
}