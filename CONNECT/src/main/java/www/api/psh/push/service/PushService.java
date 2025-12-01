// filepath: src/main/java/www/api/psh/push/service/PushService.java
package www.api.psh.push.service;

import java.util.*;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import www.com.util.CommonDao;
import www.com.firebase.PushSenderMap;

@Service
public class PushService {

    private final String namespace = "www.api.psh.push.Push";

    @Autowired
    private CommonDao dao;

    @Autowired
    private PushSenderMap pushSender; // ★ FCM 발송 유틸 주입

    /**
     * 템플릿 목록 조회
     */
    public List<Map<String, Object>> selectPushList(Map<String, Object> paramMap) {
        return dao.list(namespace + ".selectPushList", paramMap);
    }

    /**
     * 템플릿 목록 수 조회
     */
    public int selectPushListCount(Map<String, Object> paramMap) {
        Map<String, Object> resultMap = dao.selectOne(namespace + ".selectPushListCount", paramMap);
        if (resultMap != null && resultMap.get("cnt") != null) {
            return Integer.parseInt(resultMap.get("cnt").toString());
        }
        return 0;
    }

    /**
     * 템플릿 단건 조회
     */
    public Map<String, Object> selectPushDetail(Map<String, Object> paramMap) {
        return dao.selectOne(namespace + ".selectPushDetail", paramMap);
    }

    /**
     * 템플릿 등록 + FCM 발송
     * - paramMap 키 약속:
     *   title, body, imageUrl, clickAction, ttlSec, highPriority, data(Map<String,String>)
     *   token(String) | tokens("a,b,c" 또는 List<String>) | topic(String)
     *   (없으면 DB에서 selectPushTargetTokens로 토큰 조회)
     * - 발송 결과는 paramMap["_sendResult"]로 되돌려줌.
     */
    @Transactional
    public void insertPush(Map<String, Object> paramMap) {
        // 1) 템플릿 저장
        dao.insert(namespace + ".insertPush", paramMap);

        // 2) 발송 payload 구성
        Map<String, Object> payload = buildPayload(paramMap);

        // 3) 타겟 추출: topic > token/tokens > DB 조회
        Map<String, Object> sendResult = Collections.emptyMap();
        try {
            String topic = str(paramMap, "topic");
            if (hasText(topic)) {
                sendResult = pushSender.sendToTopic(topic, payload);
            } else {
                List<String> tokens = resolveTokens(paramMap);
                if (!tokens.isEmpty()) {
                    if (tokens.size() == 1) {
                        sendResult = pushSender.sendToToken(tokens.get(0), payload);
                    } else {
                        sendResult = pushSender.sendToTokens(tokens, payload);
                    }
                } else {
                    // 대상이 없으면 NO_TARGET 표기
                    Map<String, Object> m = new HashMap<>();
                    m.put("successCnt", 0);
                    m.put("failCnt", 0);
                    m.put("failedTokens", Collections.emptyList());
                    m.put("lastErrorSummary", "NO_TARGET");
                    sendResult = m;
                }
            }
        } catch (Exception ex) {
            Map<String, Object> m = new HashMap<>();
            m.put("successCnt", 0);
            m.put("failCnt", 0);
            m.put("failedTokens", Collections.emptyList());
            m.put("lastErrorSummary", ex.getMessage());
            sendResult = m;
            // 발송 실패가 템플릿 저장까지 롤백되길 원하면 RuntimeException으로 다시 던져라.
            // throw new RuntimeException(ex);
        }

        // 4) 컨트롤러에서 읽어갈 수 있도록 결과 전달
        paramMap.put("_sendResult", sendResult);

        // (선택) 발송 로그 테이블에 기록하고 싶다면 아래와 같이 추가
        // Map<String,Object> log = new HashMap<>();
        // log.put("pushId", paramMap.get("pushId")); // insert 시 생성된 PK 사용
        // log.putAll(sendResult);
        // dao.insert(namespace + ".insertPushSendLog", log);
    }

    /**
     * 템플릿 수정
     */
    @Transactional
    public void updatePush(Map<String, Object> paramMap) {
        dao.update(namespace + ".updatePush", paramMap);
    }

    /**
     * 템플릿 삭제
     */
    @Transactional
    public void deletePush(Map<String, Object> paramMap) {
        dao.delete(namespace + ".deletePush", paramMap);
    }

    /* =================== 채팅 전용 헬퍼 =================== */

    /**
     * ✅ 채팅 메시지용 푸시 발송
     * - chatPayload: ChatStompController에서 넘겨준 payload 그대로 사용
     *   (roomId, senderId, senderNm, content 필수)
     * - TB_CHAT_ROOM_USER + 디바이스 토큰 테이블 기준으로
     *   selectPushTargetTokens 에서 roomId, excludeUserId 로 대상 조회.
     */
    @Transactional
    @SuppressWarnings("unchecked")
    public Map<String, Object> sendChatPushForRoom(Map<String, Object> chatPayload) {

        Long roomId = toLong(chatPayload.get("roomId"));
        Long senderId = toLong(chatPayload.get("senderId"));
        String senderNm = str(chatPayload, "senderNm");
        String content = str(chatPayload, "content");

        if (!hasText(content)) {
            content = "(메시지 없음)";
        }

        // 1) 푸시 템플릿 paramMap 구성
        Map<String, Object> paramMap = new HashMap<>();

        // ■ 제목 / 본문
        String title;
        if (hasText(senderNm)) {
            title = senderNm + "님의 새 메시지";
        } else {
            title = "새 채팅 메시지";
        }
        paramMap.put("title", title);
        paramMap.put("body", content);

        // ■ 클릭 시 이동 경로 (웹 기준, 필요에 따라 앱 딥링크로 바꾸면 됨)
        if (roomId != null) {
            paramMap.put("clickAction", "/cht/chatMessage/chatMessageList?roomId=" + roomId);
        }

        // ■ 우선순위
        paramMap.put("highPriority", true);

        // ■ data payload (앱에서 분기 처리용)
        Map<String, String> data = new HashMap<>();
        data.put("type", "CHAT_MESSAGE");
        if (roomId != null) {
            data.put("roomId", String.valueOf(roomId));
        }
        if (senderId != null) {
            data.put("senderId", String.valueOf(senderId));
        }
        if (hasText(senderNm)) {
            data.put("senderNm", senderNm);
        }
        paramMap.put("data", data);

        // ■ 대상 조회용 파라미터
        //  - selectPushTargetTokens 에서 roomId 기준으로 방 참여자 토큰을 조회
        //  - excludeUserId 는 보낸 사람 제외용
        if (roomId != null) {
            paramMap.put("roomId", roomId);
        }
        if (senderId != null) {
            paramMap.put("excludeUserId", senderId);
        }

        // 2) 공통 insertPush 로 템플릿 저장 + FCM 발송
        insertPush(paramMap);

        // 3) insertPush 에서 채워넣은 발송 결과 반환
        Object resultObj = paramMap.get("_sendResult");
        if (resultObj instanceof Map) {
            return (Map<String, Object>) resultObj;
        }
        return Collections.emptyMap();
    }

    /* ====================== helpers ====================== */

    @SuppressWarnings("unchecked")
    private Map<String, Object> buildPayload(Map<String, Object> p) {
        Map<String, Object> m = new HashMap<>();
        copyIfPresent(p, m, "title");
        copyIfPresent(p, m, "body");
        copyIfPresent(p, m, "imageUrl");
        copyIfPresent(p, m, "clickAction");
        copyIfPresent(p, m, "ttlSec");
        copyIfPresent(p, m, "highPriority");

        Object data = p.get("data");
        if (data instanceof Map) {
            m.put("data", (Map<String, Object>) data);
        } else if (data instanceof String) {
            // data가 JSON String으로 들어오는 경우를 대비(컨트롤러에서 파싱해주는게 더 안전)
            // 여기서는 단순히 키=값;키=값 형태를 지원 예시
            Map<String, String> parsed = new HashMap<>();
            String s = ((String) data).trim();
            for (String part : s.split(";")) {
                String[] kv = part.split("=", 2);
                if (kv.length == 2) parsed.put(kv[0].trim(), kv[1].trim());
            }
            m.put("data", parsed);
        }
        return m;
    }

    /** paramMap에서 토큰 결정: token/tokens 우선, 없으면 DB 조회 */
    @SuppressWarnings("unchecked")
    private List<String> resolveTokens(Map<String, Object> p) {
        // 1) 단일 토큰
        String token = str(p, "token");
        if (hasText(token)) return Collections.singletonList(token.trim());

        // 2) 다중 토큰: List<String> 또는 CSV String
        Object tokensObj = p.get("tokens");
        if (tokensObj instanceof List) {
            List<?> raw = (List<?>) tokensObj;
            return raw.stream()
                    .filter(Objects::nonNull)
                    .map(x -> String.valueOf(x).trim())
                    .filter(this::hasText)
                    .collect(Collectors.toList());
        } else if (tokensObj instanceof String) {
            String s = ((String) tokensObj).trim();
            if (!s.isEmpty()) {
                return Arrays.stream(s.split(","))
                        .map(String::trim)
                        .filter(this::hasText)
                        .collect(Collectors.toList());
            }
        }

        // 3) DB 조회 (예: roomId / excludeUserId 등으로 대상 디바이스 토큰 조회)
        List<Map<String, Object>> rows = dao.list(namespace + ".selectPushTargetTokens", p);
        if (rows == null) return Collections.emptyList();
        List<String> fromDb = new ArrayList<>();
        for (Map<String, Object> r : rows) {
            Object v = r.get("token");
            if (v != null) {
                String t = String.valueOf(v).trim();
                if (!t.isEmpty()) fromDb.add(t);
            }
        }
        return fromDb;
    }

    private static void copyIfPresent(Map<String, Object> src, Map<String, Object> dst, String key) {
        Object v = src.get(key);
        if (v != null) dst.put(key, v);
    }

    private static String str(Map<String, Object> p, String k) {
        Object v = p.get(k);
        return v == null ? null : String.valueOf(v);
    }

    private boolean hasText(String s) {
        return s != null && !s.trim().isEmpty();
    }

    private Long toLong(Object v) {
        if (v == null) return null;
        if (v instanceof Number) {
            return ((Number) v).longValue();
        }
        try {
            return Long.parseLong(v.toString());
        } catch (NumberFormatException ex) {
            return null;
        }
    }
}
