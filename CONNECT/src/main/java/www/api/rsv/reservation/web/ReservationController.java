package www.api.rsv.reservation.web;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

import www.api.rsv.reservation.service.ReservationService;
import www.com.user.service.UserSessionManager;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
public class ReservationController {

    @Autowired
    private ReservationService reservationService;

    /**
     * 게시판 목록 조회
     */
    @RequestMapping("/api/rsv/reservation/selectReservationList")
    @ResponseBody
    public Map<String, Object> selectReservationList(@RequestBody HashMap<String, Object> map) throws Exception {
        Map<String, Object> resultMap = new HashMap<>();
        List<Map<String, Object>> result = reservationService.selectReservationList(map);
        resultMap.put("msg", "성공");
        resultMap.put("result", result);
        return resultMap;
    }
    
    /**
     * 게시판 목록 조회
     */
    @RequestMapping("/api/rsv/reservation/selectReservationListByDate")
    @ResponseBody
    public Map<String, Object> selectReservationListByDate(@RequestBody HashMap<String, Object> map) throws Exception {
        if (UserSessionManager.isUserLogined()) {
            map.put("ownerId", UserSessionManager.getLoginUserVO().getUserId());
        }
        Map<String, Object> resultMap = new HashMap<>();
        List<Map<String, Object>> result = reservationService.selectReservationListByDate(map);
        resultMap.put("msg", "성공");
        resultMap.put("result", result);
        return resultMap;
    }

    /**
     * 게시판 단건 조회
     */
    @RequestMapping("/api/rsv/reservation/selectReservationDetail")
    @ResponseBody
    public Map<String, Object> selectReservationDetail(@RequestBody HashMap<String, Object> map) throws Exception {
        Map<String, Object> resultMap = new HashMap<>();
        Map<String, Object> result = reservationService.selectReservationDetail(map);
        resultMap.put("msg", "성공");
        resultMap.put("result", result);
        return resultMap;
    }

    /**
     * 게시글 등록
     */
    @RequestMapping("/api/rsv/reservation/insertReservation")
    @ResponseBody
    public Map<String, Object> insertReservation(@RequestBody HashMap<String, Object> map) throws Exception {
        if (UserSessionManager.isUserLogined()) {
            map.put("ownerId", UserSessionManager.getLoginUserVO().getUserId());
        }
        Map<String, Object> resultMap = new HashMap<>();
        reservationService.insertReservation(map);
        resultMap.put("msg", "등록 성공");
        return resultMap;
    }

    /**
     * 게시글 수정
     */
    @RequestMapping("/api/rsv/reservation/updateReservation")
    @ResponseBody
    public Map<String, Object> updateReservation(@RequestBody HashMap<String, Object> map) throws Exception {
        if (UserSessionManager.isUserLogined()) {
            map.put("ownerId", UserSessionManager.getLoginUserVO().getUserId());
        }
        Map<String, Object> resultMap = new HashMap<>();
        reservationService.updateReservation(map);
        resultMap.put("msg", "수정 성공");
        return resultMap;
    }
    
    /**
     * 게시글 수정
     */
    @RequestMapping("/api/rsv/reservation/updateReservationStatus")
    @ResponseBody
    public Map<String, Object> updateReservationStatus(@RequestBody HashMap<String, Object> map) throws Exception {
        if (UserSessionManager.isUserLogined()) {
            map.put("ownerId", UserSessionManager.getLoginUserVO().getUserId());
        }
        Map<String, Object> resultMap = new HashMap<>();
        reservationService.updateReservationStatus(map);
        resultMap.put("msg", "수정 성공");
        return resultMap;
    }

    /**
     * 게시글 삭제
     */
    @RequestMapping("/api/rsv/reservation/deleteReservation")
    @ResponseBody
    public Map<String, Object> deleteReservation(@RequestBody HashMap<String, Object> map) throws Exception {
        Map<String, Object> resultMap = new HashMap<>();
        reservationService.deleteReservation(map);
        resultMap.put("msg", "삭제 성공");
        return resultMap;
    }

    /**
     * 게시글 개수
     */
    @RequestMapping("/api/rsv/reservation/selectReservationListCount")
    @ResponseBody
    public Map<String, Object> selectReservationListCount(@RequestBody HashMap<String, Object> map) throws Exception {
        if (UserSessionManager.isUserLogined()) {
            map.put("ownerId", UserSessionManager.getLoginUserVO().getUserId());
        }
        Map<String, Object> resultMap = new HashMap<>();
        int count = reservationService.selectReservationListCount(map);
        resultMap.put("msg", "성공");
        resultMap.put("count", count);
        return resultMap;
    }
}
