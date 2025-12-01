// filepath: src/main/java/www/api/cht/chat/ws/ChatBotStompController.java
package www.api.cht.chat.ws;

import java.util.HashMap;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.messaging.handler.annotation.DestinationVariable;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Controller;

import www.api.cht.chat.service.ChatMessageService;
import www.api.psh.push.service.PushService;
import www.com.ai.AiEngineManager;

/**
 * Qwen 기반 일반 챗봇 전용 WebSocket 컨트롤러
 *
 * STOMP 엔드포인트:
 *   - send    : /app/chat-bot/{roomId}
 *   - subscribe: /topic/chat-bot/{roomId}
 *
 * 프론트에서 이 채널만 쓰면 "번역"이 아니라 "일반 챗봇"으로 동작한다.
 */
@Controller
public class ChatBotStompController {

    private final ChatMessageService chatMessageService;
    private final SimpMessagingTemplate messagingTemplate;
    private final PushService pushService;
    private final AiEngineManager aiEngineManager;

    @Autowired
    public ChatBotStompController(ChatMessageService chatMessageService,
                                  SimpMessagingTemplate messagingTemplate,
                                  PushService pushService,
                                  AiEngineManager aiEngineManager) {
        this.chatMessageService = chatMessageService;
        this.messagingTemplate = messagingTemplate;
        this.pushService = pushService;
        this.aiEngineManager = aiEngineManager;
    }

    /**
     * 클라이언트에서 /app/chat-bot/{roomId} 로 보내는 메시지 처리
     *
     * payload 예시(JSON)
     * {
     *   "roomId"   : 99,
     *   "content"  : "한국에서 가볼 만한 관광지 추천해 줘",
     *   "ownerId"  : 1,
     *   "senderId" : 1,
     *   "senderNm" : "wlrbs1111@gmail.com"
     * }
     *
     * 브로드캐스트:
     *   1) 사용자가 보낸 메시지 (senderId = 로그인 사용자의 ID)
     *   2) Qwen 챗봇의 응답 메시지 (senderId = 0, senderNm = "QWEN-BOT")
     */
    @MessageMapping("/chat-bot/{roomId}")
    public void handleChatBot(@DestinationVariable("roomId") Long roomId,
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
                    senderId = 0L;
                }
            }
        }
        if (senderId == null) {
            senderId = 0L;
        }
        payload.put("senderId", senderId);

        // 3) senderNm 정규화
        Object senderNmRaw = payload.get("senderNm");
        String senderNm = (senderNmRaw != null) ? senderNmRaw.toString() : "";
        if (senderNm.trim().isEmpty()) {
            senderNm = "UNKNOWN";
        }
        payload.put("senderNm", senderNm);

        // 4) contentType, readCnt, useAt 기본값
        if (!payload.containsKey("contentType") || payload.get("contentType") == null) {
            payload.put("contentType", "TEXT");
        }
        if (!payload.containsKey("readCnt") || payload.get("readCnt") == null) {
            payload.put("readCnt", 0);
        }
        if (!payload.containsKey("useAt") || payload.get("useAt") == null) {
            payload.put("useAt", "Y");
        }

        // 5) createdBy / updatedBy 기본값
        if (!payload.containsKey("createdBy") || payload.get("createdBy") == null) {
            payload.put("createdBy", senderId);
        }
        if (!payload.containsKey("updatedBy") || payload.get("updatedBy") == null) {
            payload.put("updatedBy", senderId);
        }

        // 6) 사용자 메시지 DB 저장
        chatMessageService.insertChatMessage(payload);

        // 7) 사용자 메시지를 먼저 브로드캐스트 (사용자가 바로 보이도록)
        messagingTemplate.convertAndSend("/topic/chat-bot/" + roomId, payload);

        // 8) Qwen 챗봇 호출
        String userText = "";
        Object contentRaw = payload.get("content");
        if (contentRaw != null) {
            userText = contentRaw.toString();
        }

        String botAnswer;
        try {
            // ★ 실제 Qwen 호출 로직은 AiEngineManager 내부에서 구현
            //   (지금은 더미 구현 → 나중에 HTTP 연동으로 교체)
            botAnswer = aiEngineManager.chatWithQwen(userText);
            if (botAnswer == null) {
                botAnswer = "";
            }
        } catch (Exception e) {
            botAnswer = "(QWEN-CHATBOT 오류: " + e.getMessage() + ")";
        }

        // 9) 챗봇 응답 payload 생성
        Map<String, Object> botPayload = new HashMap<>();
        botPayload.put("roomId", roomId);
        botPayload.put("content", botAnswer);
        botPayload.put("contentType", "TEXT");
        botPayload.put("senderId", 0L);                  // 봇 ID (0 고정)
        botPayload.put("senderNm", "QWEN-BOT");          // 봇 이름
        botPayload.put("readCnt", 0);
        botPayload.put("useAt", "Y");
        botPayload.put("createdBy", senderId);          // 누가 대화를 유발했는지
        botPayload.put("updatedBy", senderId);

        // 10) DB 저장 (봇 메시지도 남기고 싶으면)
        chatMessageService.insertChatMessage(botPayload);

        // 11) 챗봇 응답 브로드캐스트
        messagingTemplate.convertAndSend("/topic/chat-bot/" + roomId, botPayload);

        // 12) 필요하면 FCM 푸시 (선택)
        try {
            pushService.sendChatPushForRoom(botPayload);
        } catch (Exception e) {
            // 푸시 실패해도 채팅 기능에는 영향 X
        }
    }
}
