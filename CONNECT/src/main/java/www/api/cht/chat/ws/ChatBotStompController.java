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
import www.com.ai.AiEngineManager;

@Controller
public class ChatBotStompController {

    private final ChatMessageService chatMessageService;
    private final SimpMessagingTemplate messagingTemplate;
    private final AiEngineManager aiEngineManager;

    @Autowired
    public ChatBotStompController(ChatMessageService chatMessageService,
                                  SimpMessagingTemplate messagingTemplate,
                                  AiEngineManager aiEngineManager) {
        this.chatMessageService = chatMessageService;
        this.messagingTemplate = messagingTemplate;
        this.aiEngineManager = aiEngineManager;
    }

    @MessageMapping("/chat-bot/{roomId}")
    public void handleChatBot(@DestinationVariable("roomId") Long roomId,
                              Map<String, Object> payload) {

        final Map<String, Object> payloadFinal = (payload != null)
                ? new HashMap<String, Object>(payload)
                : new HashMap<String, Object>();

        payloadFinal.put("roomId", roomId);

        // senderId normalize
        Object senderIdRaw = payloadFinal.get("senderId");
        Long senderId = 0L;
        if (senderIdRaw instanceof Number) {
            senderId = ((Number) senderIdRaw).longValue();
        } else if (senderIdRaw != null) {
            try {
                senderId = Long.parseLong(senderIdRaw.toString());
            } catch (Exception ignore) {
                senderId = 0L;
            }
        }
        payloadFinal.put("senderId", senderId);

        // senderNm normalize
        Object senderNmRaw = payloadFinal.get("senderNm");
        String senderNm = (senderNmRaw != null) ? senderNmRaw.toString() : "UNKNOWN";
        if (senderNm.trim().isEmpty()) senderNm = "UNKNOWN";
        payloadFinal.put("senderNm", senderNm);

        // defaults
        if (!payloadFinal.containsKey("contentType") || payloadFinal.get("contentType") == null) payloadFinal.put("contentType", "TEXT");
        if (!payloadFinal.containsKey("readCnt") || payloadFinal.get("readCnt") == null) payloadFinal.put("readCnt", 0);
        if (!payloadFinal.containsKey("useAt") || payloadFinal.get("useAt") == null) payloadFinal.put("useAt", "Y");
        if (!payloadFinal.containsKey("createdBy") || payloadFinal.get("createdBy") == null) payloadFinal.put("createdBy", senderId);
        if (!payloadFinal.containsKey("updatedBy") || payloadFinal.get("updatedBy") == null) payloadFinal.put("updatedBy", senderId);

        if (!payloadFinal.containsKey("botVariant") || payloadFinal.get("botVariant") == null) {
            payloadFinal.put("botVariant", "CHAT_GRAPH_STREAM");
        }

        String content = "";
        Object contentRaw = payloadFinal.get("content");
        if (contentRaw != null) content = contentRaw.toString();
        if (content.trim().isEmpty()) return;

        // 1) 유저 메시지 저장 + 브로드캐스트
        try {
            chatMessageService.insertChatMessage(payloadFinal);
        } catch (Exception ignore) {
        }
        messagingTemplate.convertAndSend("/topic/chat-bot/" + roomId, payloadFinal);

        final String botVariant = payloadFinal.get("botVariant").toString().trim().toUpperCase();
        final String aiMsgId = "ai-" + roomId + "-" + System.currentTimeMillis();

        // 2) START
        Map<String, Object> start = new HashMap<String, Object>();
        start.put("roomId", roomId);
        start.put("ai", "Y");
        start.put("aiEvent", "START");
        start.put("aiMsgId", aiMsgId);
        start.put("botVariant", botVariant);
        messagingTemplate.convertAndSend("/topic/chat-bot/" + roomId, start);

        // 3) 비동기 처리
        new Thread(new Runnable() {
            @Override
            public void run() {
                try {
                    if (botVariant.contains("STREAM")) {
                        handleStream(roomId, aiMsgId, botVariant, payloadFinal);
                    } else {
                        handleNonStream(roomId, aiMsgId, botVariant, payloadFinal);
                    }
                } catch (Exception e) {
                    Map<String, Object> err = new HashMap<String, Object>();
                    err.put("roomId", roomId);
                    err.put("ai", "Y");
                    err.put("aiEvent", "ERROR");
                    err.put("aiMsgId", aiMsgId);
                    err.put("botVariant", botVariant);
                    err.put("errorMsg", e.getMessage());
                    messagingTemplate.convertAndSend("/topic/chat-bot/" + roomId, err);
                }
            }
        }).start();
    }

    private void handleNonStream(Long roomId, String aiMsgId, String botVariant, Map<String, Object> payloadFinal) throws Exception {
        Map<String, Object> resp = aiEngineManager.chatWithOpenAiFastApi(payloadFinal);

        String answer = "";
        Object answerObj = resp.get("answer");
        if (answerObj != null) answer = answerObj.toString();

        Object sources = resp.get("sources");

        Map<String, Object> done = buildAiFinalMessage(roomId, aiMsgId, botVariant, answer, sources);

        // 최종 1건만 저장(토큰은 저장 안 함)
        try {
            chatMessageService.insertChatMessage(done);
        } catch (Exception ignore) {
        }

        done.put("aiEvent", "DONE");
        messagingTemplate.convertAndSend("/topic/chat-bot/" + roomId, done);
    }

    private void handleStream(Long roomId, String aiMsgId, String botVariant, Map<String, Object> payloadFinal) throws Exception {
        final StringBuilder full = new StringBuilder();

        aiEngineManager.chatWithOpenAiFastApiStream(payloadFinal, new AiEngineManager.StreamCallback() {
            @Override
            public void onToken(String delta) {
                if (delta == null || delta.isEmpty()) return;

                full.append(delta);

                Map<String, Object> token = new HashMap<String, Object>();
                token.put("roomId", roomId);
                token.put("ai", "Y");
                token.put("aiEvent", "TOKEN");
                token.put("aiMsgId", aiMsgId);
                token.put("botVariant", botVariant);
                token.put("delta", delta);

                messagingTemplate.convertAndSend("/topic/chat-bot/" + roomId, token);
            }

            @Override
            public void onDone(String fullAnswer, Object sources) {
                String answer = (fullAnswer != null && !fullAnswer.trim().isEmpty())
                        ? fullAnswer
                        : full.toString();

                Map<String, Object> done = buildAiFinalMessage(roomId, aiMsgId, botVariant, answer, sources);

                try {
                    chatMessageService.insertChatMessage(done);
                } catch (Exception ignore) {
                }

                done.put("aiEvent", "DONE");
                messagingTemplate.convertAndSend("/topic/chat-bot/" + roomId, done);
            }

            @Override
            public void onError(String errorMsg) {
                Map<String, Object> err = new HashMap<String, Object>();
                err.put("roomId", roomId);
                err.put("ai", "Y");
                err.put("aiEvent", "ERROR");
                err.put("aiMsgId", aiMsgId);
                err.put("botVariant", botVariant);
                err.put("errorMsg", errorMsg);
                messagingTemplate.convertAndSend("/topic/chat-bot/" + roomId, err);
            }
        });
    }

    private Map<String, Object> buildAiFinalMessage(Long roomId, String aiMsgId, String botVariant, String answer, Object sources) {
        Map<String, Object> m = new HashMap<String, Object>();
        m.put("roomId", roomId);

        // DB insert 최소 필드
        m.put("senderId", 0L);
        m.put("senderNm", "AI");
        m.put("contentType", "AI");

        String safeAnswer = (answer != null) ? answer : "";
        m.put("content", safeAnswer);

        m.put("readCnt", 0);
        m.put("useAt", "Y");
        m.put("createdBy", 0L);
        m.put("updatedBy", 0L);

        // 브로드캐스트 메타
        m.put("ai", "Y");
        m.put("aiMsgId", aiMsgId);
        m.put("botVariant", botVariant);

        // 화면 방어용(혹시 content가 비는 구현 섞여도 표시되게)
        m.put("answer", safeAnswer);
        if (sources != null) {
            m.put("sources", sources);
        }

        return m;
    }
}
