package www.api.cht.chat.web;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

import www.api.cht.chat.service.ChatMessageService;
import www.com.user.service.UserSessionManager;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
public class ChatMessageController {

    @Autowired
    private ChatMessageService chatMessageService;

    /** 공통: 읽기용 (ownerId 스코프) */
    private void applyLoginForRead(Map<String, Object> map) {
        if (UserSessionManager.isUserLogined()) {
            map.put("ownerId", UserSessionManager.getLoginUserVO().getUserId());
        }
    }

    /** 공통: 생성용 (senderId, createdBy/updatedBy) */
    private void applyLoginForCreate(Map<String, Object> map) {
        if (UserSessionManager.isUserLogined()) {
            Long userId = Long.valueOf(UserSessionManager.getLoginUserVO().getUserId());
            String email = UserSessionManager.getLoginUserVO().getEmail();

            map.put("ownerId", userId);
            map.put("senderId", userId);
            // 일단 이메일을 표시 이름으로 사용 (필요하면 나중에 userNm으로 교체)
            map.put("senderNm", email);
            map.put("createdBy", userId);
            map.put("updatedBy", userId);
        }
    }

    /** 공통: 수정/삭제용 */
    private void applyLoginForUpdate(Map<String, Object> map) {
        if (UserSessionManager.isUserLogined()) {
            map.put("ownerId", UserSessionManager.getLoginUserVO().getUserId());
            map.put("updatedBy", UserSessionManager.getLoginUserVO().getEmail());
        }
    }

    /** 메시지 목록 조회 (roomId 기준, 최근 N개) */
    @RequestMapping("/api/cht/chatMessage/selectChatMessageList")
    @ResponseBody
    public Map<String, Object> selectChatMessageList(@RequestBody HashMap<String, Object> map) throws Exception {
        applyLoginForRead(map);
        // limit 기본값
        if (!map.containsKey("limit")) {
            map.put("limit", 50);
        }

        Map<String, Object> resultMap = new HashMap<>();
        List<Map<String, Object>> result = chatMessageService.selectChatMessageList(map);
        resultMap.put("msg", "성공");
        resultMap.put("result", result);
        return resultMap;
    }

    /** 메시지 단건 조회 */
    @RequestMapping("/api/cht/chatMessage/selectChatMessageDetail")
    @ResponseBody
    public Map<String, Object> selectChatMessageDetail(@RequestBody HashMap<String, Object> map) throws Exception {
        applyLoginForRead(map);

        Map<String, Object> resultMap = new HashMap<>();
        Map<String, Object> result = chatMessageService.selectChatMessageDetail(map);
        resultMap.put("msg", "성공");
        resultMap.put("result", result);
        return resultMap;
    }

    /** 메시지 등록 */
    @RequestMapping("/api/cht/chatMessage/insertChatMessage")
    @ResponseBody
    public Map<String, Object> insertChatMessage(@RequestBody HashMap<String, Object> map) throws Exception {
        applyLoginForCreate(map);

        Map<String, Object> resultMap = new HashMap<>();
        chatMessageService.insertChatMessage(map);
        resultMap.put("msg", "등록 성공");
        return resultMap;
    }

    /** 메시지 수정 (본문 수정 등 필요 시) */
    @RequestMapping("/api/cht/chatMessage/updateChatMessage")
    @ResponseBody
    public Map<String, Object> updateChatMessage(@RequestBody HashMap<String, Object> map) throws Exception {
        applyLoginForUpdate(map);

        Map<String, Object> resultMap = new HashMap<>();
        chatMessageService.updateChatMessage(map);
        resultMap.put("msg", "수정 성공");
        return resultMap;
    }

    /** 메시지 삭제(Soft) */
    @RequestMapping("/api/cht/chatMessage/deleteChatMessage")
    @ResponseBody
    public Map<String, Object> deleteChatMessage(@RequestBody HashMap<String, Object> map) throws Exception {
        applyLoginForUpdate(map);

        Map<String, Object> resultMap = new HashMap<>();
        chatMessageService.deleteChatMessage(map);
        resultMap.put("msg", "삭제 성공");
        return resultMap;
    }

    /** 메시지 개수 (옵션) */
    @RequestMapping("/api/cht/chatMessage/selectChatMessageListCount")
    @ResponseBody
    public Map<String, Object> selectChatMessageListCount(@RequestBody HashMap<String, Object> map) throws Exception {
        applyLoginForRead(map);

        Map<String, Object> resultMap = new HashMap<>();
        int count = chatMessageService.selectChatMessageListCount(map);
        resultMap.put("msg", "성공");
        resultMap.put("count", count);
        return resultMap;
    }
}
