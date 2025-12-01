// filepath: src/main/java/www/api/cht/chat/ws/ChatAiStompController.java
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

@Controller
public class ChatAiStompController {

    private final ChatMessageService chatMessageService;
    private final SimpMessagingTemplate messagingTemplate;
    private final PushService pushService;
    private final AiEngineManager aiEngineManager;

    @Autowired
    public ChatAiStompController(ChatMessageService chatMessageService,
                                 SimpMessagingTemplate messagingTemplate,
                                 PushService pushService,
                                 AiEngineManager aiEngineManager) {
        this.chatMessageService = chatMessageService;
        this.messagingTemplate = messagingTemplate;
        this.pushService = pushService;
        this.aiEngineManager = aiEngineManager;
    }

    /**
     * 자동번역 전용 채팅 엔드포인트
     *
     * 클라이언트에서 /app/chat-ai/{roomId} 로 보내는 메시지 처리
     */
    @MessageMapping("/chat-ai/{roomId}")
    public void handleChatAi(@DestinationVariable("roomId") Long roomId,
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

        // 5.5) 번역 기본값 (없으면 auto/ko/LT)
        if (!payload.containsKey("sourceLang") || payload.get("sourceLang") == null) {
            payload.put("sourceLang", "auto");
        }
        if (!payload.containsKey("targetLang") || payload.get("targetLang") == null) {
            payload.put("targetLang", "ko"); // 필요하면 프론트에서 en 등으로 변경
        }
        if (!payload.containsKey("engine") || payload.get("engine") == null) {
            payload.put("engine", "LT"); // "LT" or "QWEN"
        }

        // 6) DB 저장 (XML에서 날짜는 NOW() 처리)
        chatMessageService.insertChatMessage(payload);

        // 7) AI 번역 호출 (동일 payload 기반)
        try {
            String translated = aiEngineManager.translate(payload);
            payload.put("translatedText", translated);
            payload.remove("translateErrorMsg");
        } catch (Exception e) {
            // 번역 실패해도 채팅은 그대로 흘려보냄
            payload.put("translateErrorMsg", e.getMessage());
        }

        // 8) 같은 roomId 구독자에게 브로드캐스트 (원문 + 번역 결과 포함)
        messagingTemplate.convertAndSend("/topic/chat-ai/" + roomId, payload);

        // 9) 채팅방 멤버에게 FCM 푸시 발송 (필요 없으면 이 부분만 빼도 됨)
        try {
            pushService.sendChatPushForRoom(payload);
        } catch (Exception e) {
            // 푸시 실패해도 채팅 기능에 영향 X
        }
    }
}
