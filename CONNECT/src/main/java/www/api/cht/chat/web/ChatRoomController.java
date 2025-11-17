package www.api.cht.chat.web;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

import www.api.cht.chat.service.ChatRoomService;
import www.com.user.service.UserSessionManager;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
public class ChatRoomController {

    @Autowired
    private ChatRoomService chatRoomService;

    /** 공통: 로그인 정보 세팅 */
    private void applyLoginForRead(Map<String, Object> map) {
        if (UserSessionManager.isUserLogined()) {
            map.put("ownerId", UserSessionManager.getLoginUserVO().getUserId());
        }
    }

    private void applyLoginForCreate(Map<String, Object> map) {
        if (UserSessionManager.isUserLogined()) {
            map.put("ownerId", UserSessionManager.getLoginUserVO().getUserId());
            map.put("createdBy", UserSessionManager.getLoginUserVO().getUserId());
            map.put("updatedBy", UserSessionManager.getLoginUserVO().getUserId());
        }
    }

    private void applyLoginForUpdate(Map<String, Object> map) {
        if (UserSessionManager.isUserLogined()) {
            map.put("ownerId", UserSessionManager.getLoginUserVO().getUserId());
            map.put("updatedBy", UserSessionManager.getLoginUserVO().getUserId());
        }
    }

    /** 채팅방 목록 조회 (ownerId, grpCd 기준) */
    @RequestMapping("/api/cht/chatRoom/selectChatRoomList")
    @ResponseBody
    public Map<String, Object> selectChatRoomList(@RequestBody HashMap<String, Object> map) throws Exception {
        applyLoginForRead(map);

        Map<String, Object> resultMap = new HashMap<>();
        List<Map<String, Object>> result = chatRoomService.selectChatRoomList(map);
        resultMap.put("msg", "성공");
        resultMap.put("result", result);
        return resultMap;
    }

    /** 채팅방 단건 조회 */
    @RequestMapping("/api/cht/chatRoom/selectChatRoomDetail")
    @ResponseBody
    public Map<String, Object> selectChatRoomDetail(@RequestBody HashMap<String, Object> map) throws Exception {
        applyLoginForRead(map);

        Map<String, Object> resultMap = new HashMap<>();
        Map<String, Object> result = chatRoomService.selectChatRoomDetail(map);
        resultMap.put("msg", "성공");
        resultMap.put("result", result);
        return resultMap;
    }

    /** 채팅방 등록 */
    @RequestMapping("/api/cht/chatRoom/insertChatRoom")
    @ResponseBody
    public Map<String, Object> insertChatRoom(@RequestBody HashMap<String, Object> map) throws Exception {
        applyLoginForCreate(map);

        Map<String, Object> resultMap = new HashMap<>();
        chatRoomService.insertChatRoom(map);
        resultMap.put("msg", "등록 성공");
        return resultMap;
    }

    /** 채팅방 수정 */
    @RequestMapping("/api/cht/chatRoom/updateChatRoom")
    @ResponseBody
    public Map<String, Object> updateChatRoom(@RequestBody HashMap<String, Object> map) throws Exception {
        applyLoginForUpdate(map);

        Map<String, Object> resultMap = new HashMap<>();
        chatRoomService.updateChatRoom(map);
        resultMap.put("msg", "수정 성공");
        return resultMap;
    }

    /** 채팅방 삭제(Soft) */
    @RequestMapping("/api/cht/chatRoom/deleteChatRoom")
    @ResponseBody
    public Map<String, Object> deleteChatRoom(@RequestBody HashMap<String, Object> map) throws Exception {
        applyLoginForUpdate(map);

        Map<String, Object> resultMap = new HashMap<>();
        chatRoomService.deleteChatRoom(map);
        resultMap.put("msg", "삭제 성공");
        return resultMap;
    }

    /** 채팅방 개수 */
    @RequestMapping("/api/cht/chatRoom/selectChatRoomListCount")
    @ResponseBody
    public Map<String, Object> selectChatRoomListCount(@RequestBody HashMap<String, Object> map) throws Exception {
        applyLoginForRead(map);

        Map<String, Object> resultMap = new HashMap<>();
        int count = chatRoomService.selectChatRoomListCount(map);
        resultMap.put("msg", "성공");
        resultMap.put("count", count);
        return resultMap;
    }
}
