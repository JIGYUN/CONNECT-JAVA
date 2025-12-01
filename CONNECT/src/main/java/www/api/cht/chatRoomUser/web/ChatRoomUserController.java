// filepath: www/api/cht/chatRoomUser/web/ChatRoomUserController.java
package www.api.cht.chatRoomUser.web;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

import www.api.cht.chatRoomUser.service.ChatRoomUserService;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
public class ChatRoomUserController {

    @Autowired
    private ChatRoomUserService chatRoomUserService;

    /**
     * 목록 조회
     */
    @RequestMapping("/api/cht/chatRoomUser/selectChatRoomUserList")
    @ResponseBody
    public Map<String, Object> selectChatRoomUserList(@RequestBody HashMap<String, Object> map) throws Exception {
        Map<String, Object> resultMap = new HashMap<>();
        List<Map<String, Object>> result = chatRoomUserService.selectChatRoomUserList(map);
        resultMap.put("msg", "성공");
        resultMap.put("result", result);
        return resultMap;
    }

    /**
     * 단건 조회
     */
    @RequestMapping("/api/cht/chatRoomUser/selectChatRoomUserDetail")
    @ResponseBody
    public Map<String, Object> selectChatRoomUserDetail(@RequestBody HashMap<String, Object> map) throws Exception {
        Map<String, Object> resultMap = new HashMap<>();
        Map<String, Object> result = chatRoomUserService.selectChatRoomUserDetail(map);
        resultMap.put("msg", "성공");
        resultMap.put("result", result);
        return resultMap;
    }

    /**
     * 등록
     */
    @RequestMapping("/api/cht/chatRoomUser/insertChatRoomUser")
    @ResponseBody
    public Map<String, Object> insertChatRoomUser(@RequestBody HashMap<String, Object> map) throws Exception {
        // 여기서부터는 일반 CRUD 용도 (필요 시 세션 사용해도 됨)
        Map<String, Object> resultMap = new HashMap<>();
        chatRoomUserService.insertChatRoomUser(map);
        resultMap.put("msg", "등록 성공");
        return resultMap;
    }

    /**
     * 수정
     */
    @RequestMapping("/api/cht/chatRoomUser/updateChatRoomUser")
    @ResponseBody
    public Map<String, Object> updateChatRoomUser(@RequestBody HashMap<String, Object> map) throws Exception {
        Map<String, Object> resultMap = new HashMap<>();
        chatRoomUserService.updateChatRoomUser(map);
        resultMap.put("msg", "수정 성공");
        return resultMap;
    }

    /**
     * 삭제
     */
    @RequestMapping("/api/cht/chatRoomUser/deleteChatRoomUser")
    @ResponseBody
    public Map<String, Object> deleteChatRoomUser(@RequestBody HashMap<String, Object> map) throws Exception {
        Map<String, Object> resultMap = new HashMap<>();
        chatRoomUserService.deleteChatRoomUser(map);
        resultMap.put("msg", "삭제 성공");
        return resultMap;
    }

    /**
     * 목록 개수
     */
    @RequestMapping("/api/cht/chatRoomUser/selectChatRoomUserListCount")
    @ResponseBody
    public Map<String, Object> selectChatRoomUserListCount(@RequestBody HashMap<String, Object> map) throws Exception {
        Map<String, Object> resultMap = new HashMap<>();
        int count = chatRoomUserService.selectChatRoomUserListCount(map);
        resultMap.put("msg", "성공");
        resultMap.put("count", count);
        return resultMap;
    }

    /**
     * ✅ 채팅방 입장용: 프론트에서 전달한 roomId + userId + senderNm 으로 멤버 upsert
     *
     * POST /api/cht/chatRoomUser/joinRoom
     * body: {
     *   "roomId": 123,
     *   "userId": 1,
     *   "senderNm": "user@example.com",
     *   "roleCd": "MEMBER"   // 옵션, 없으면 기본값 MEMBER
     * }
     */
    @RequestMapping("/api/cht/chatRoomUser/joinRoom")
    @ResponseBody
    public Map<String, Object> joinRoom(@RequestBody HashMap<String, Object> map) throws Exception {

        Object roomIdObj = map.get("roomId");
        Object userIdObj = map.get("userId");

        if (roomIdObj == null || userIdObj == null) {
            throw new IllegalArgumentException("roomId, userId 는 필수입니다.");
        }

        // userId 숫자 변환 (Long)
        Long userId;
        if (userIdObj instanceof Number) {
            userId = ((Number) userIdObj).longValue();
        } else {
            userId = Long.valueOf(userIdObj.toString());
        }
        map.put("userId", userId);

        // ROLE_CD 기본값
        Object roleObj = map.get("roleCd");
        if (roleObj == null || roleObj.toString().trim().isEmpty()) {
            map.put("roleCd", "MEMBER");
        }

        // 감사 컬럼: senderNm 이 있으면 그걸, 없으면 userId 문자열로
        Object senderNmObj = map.get("senderNm");
        String auditValue = senderNmObj != null
                ? senderNmObj.toString()
                : String.valueOf(userId);

        map.put("createdBy", auditValue);
        map.put("updatedBy", auditValue);

        // 서비스에서 upsert 처리 (없으면 insert, 있으면 reactivate 등)
        Map<String, Object> roomUser = chatRoomUserService.joinChatRoomUser(map);

        Map<String, Object> resultMap = new HashMap<>();
        resultMap.put("msg", "성공");
        resultMap.put("result", roomUser);
        return resultMap;
    }
}
