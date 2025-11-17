package www.api.cht.chat.ws;

import java.util.HashMap;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.messaging.handler.annotation.DestinationVariable;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Controller;

import www.api.cht.chat.service.ChatMessageService;

@Controller
public class ChatStompController {

    private final ChatMessageService chatMessageService;
    private final SimpMessagingTemplate messagingTemplate;

    @Autowired
    public ChatStompController(ChatMessageService chatMessageService,
                               SimpMessagingTemplate messagingTemplate) {
        this.chatMessageService = chatMessageService;
        this.messagingTemplate = messagingTemplate;
    }

    /**
     * 클라이언트에서 /app/chat/{roomId} 로 보내는 메시지 처리
     *
     * payload 예시(JSON)
     * {
     *   "senderId": 123,
     *   "senderNm": "user@example.com",
     *   "content": "안녕",
     *   "contentType": "TEXT"
     * }
     */
    @MessageMapping("/chat/{roomId}")
    public void handleChat(@DestinationVariable("roomId") Long roomId,
                           Map<String, Object> payload) {

        if (payload == null) {
            payload = new HashMap<>();
        }

        // 1) roomId 강제 세팅
        payload.put("roomId", roomId);

        // 2) senderId 정규화 (Number or String → Long)
        Object senderIdRaw = payload.get("senderId");
        Long senderId = null;

        if (senderIdRaw != null) {
            if (senderIdRaw instanceof Number) {
                senderId = ((Number) senderIdRaw).longValue();
            } else {
                try {
                    senderId = Long.parseLong(senderIdRaw.toString());
                } catch (NumberFormatException e) {
                    // 잘못된 값이면 0으로
                    senderId = 0L;
                }
            }
        }

        if (senderId == null) {
            senderId = 0L; // NOT NULL 컬럼 때문에 최소 0 보장
        }
        payload.put("senderId", senderId);

        // 3) senderNm 정규화
        Object senderNmRaw = payload.get("senderNm");
        String senderNm = (senderNmRaw != null) ? senderNmRaw.toString() : "UNKNOWN";
        payload.put("senderNm", senderNm);

        // 4) 기본값 셋팅 (contentType, readCnt, useAt)
        if (!payload.containsKey("contentType") || payload.get("contentType") == null) {
            payload.put("contentType", "TEXT");
        }

        if (!payload.containsKey("readCnt") || payload.get("readCnt") == null) {
            payload.put("readCnt", 0);
        }

        if (!payload.containsKey("useAt") || payload.get("useAt") == null) {
            payload.put("useAt", "Y");
        }

        // 5) createdBy / updatedBy 기본값 (TB_CHAT_MESSAGE 컬럼 타입에 맞게 String으로 사용)
        if (!payload.containsKey("createdBy") || payload.get("createdBy") == null) {
            payload.put("createdBy", senderId);
        }
        if (!payload.containsKey("updatedBy") || payload.get("updatedBy") == null) {
            payload.put("updatedBy", senderId);
        }

        // 6) DB 저장 (날짜 컬럼은 XML에서 NOW() 처리)
        chatMessageService.insertChatMessage(payload);

        // 7) 같은 roomId를 구독 중인 모든 클라이언트에게 브로드캐스트
        messagingTemplate.convertAndSend("/topic/chat/" + roomId, payload);
    }
}
