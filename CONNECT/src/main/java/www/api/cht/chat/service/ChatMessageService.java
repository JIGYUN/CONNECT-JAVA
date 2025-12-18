// filepath: src/main/java/www/api/cht/chat/service/ChatMessageService.java
package www.api.cht.chat.service;

import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import www.com.util.CommonDao;

@Service
public class ChatMessageService {

    // 메시지용 Mapper
    private final String namespace = "www.api.cht.chat.ChatMessage";
    // 방 정보 업데이트용 Mapper
    private final String roomNamespace = "www.api.cht.chat.ChatRoom";

    // TB_CHAT_ROOM.LAST_MSG_CONTENT 길이(VARCHAR) 초과 방지용
    // 너 컬럼 길이에 맞춰 조절해. (보통 200~500)
    private static final int LAST_MSG_CONTENT_MAX = 300;

    @Autowired
    private CommonDao dao;

    /** 메시지 목록 조회 */
    public List<Map<String, Object>> selectChatMessageList(Map<String, Object> paramMap) {
        return dao.list(namespace + ".selectChatMessageList", paramMap);
    }

    /** 메시지 목록 수 조회 */
    public int selectChatMessageListCount(Map<String, Object> paramMap) {
        Map<String, Object> resultMap = dao.selectOne(namespace + ".selectChatMessageListCount", paramMap);
        if (resultMap != null && resultMap.get("cnt") != null) {
            return Integer.parseInt(resultMap.get("cnt").toString());
        }
        return 0;
    }

    /** 메시지 단건 조회 */
    public Map<String, Object> selectChatMessageDetail(Map<String, Object> paramMap) {
        return dao.selectOne(namespace + ".selectChatMessageDetail", paramMap);
    }

    /**
     * 메시지 등록 + 채팅방의 마지막 메시지 정보 갱신
     *
     * 핵심 수정:
     * - TB_CHAT_MESSAGE.CONTENT는 TEXT라 길이 제한 없음
     * - TB_CHAT_ROOM.LAST_MSG_CONTENT는 VARCHAR라 길이 제한 있음
     *   => lastMsgContent(잘린 미리보기)로 업데이트하도록 분리
     */
    @Transactional
    public void insertChatMessage(Map<String, Object> paramMap) {

        // --- 기본값 세팅 ---
        if (!paramMap.containsKey("contentType") || paramMap.get("contentType") == null) {
            paramMap.put("contentType", "TEXT");
        }
        if (!paramMap.containsKey("useAt") || paramMap.get("useAt") == null) {
            paramMap.put("useAt", "Y");
        }
        if (!paramMap.containsKey("readCnt") || paramMap.get("readCnt") == null) {
            paramMap.put("readCnt", 0);
        }

        // --- 메시지 INSERT ---
        dao.insert(namespace + ".insertChatMessage", paramMap);

        // --- 마지막 메시지 업데이트용 content 미리보기 생성 ---
        String content = "";
        Object contentObj = paramMap.get("content");
        if (contentObj != null) {
            content = contentObj.toString();
        }

        // 줄바꿈/탭 정리(원하면 제거 가능)
        String preview = normalizeForLastMessage(content);
        if (preview.length() > LAST_MSG_CONTENT_MAX) {
            preview = preview.substring(0, LAST_MSG_CONTENT_MAX);
        }

        // mapper가 #{content}로 LAST_MSG_CONTENT를 받는 구조라면
        // 여기서 content를 덮어써도 "메시지 insert 이후"라 TB_CHAT_MESSAGE에는 영향 없음.
        // 단, 화면/다른 로직에서 paramMap의 content를 계속 쓰는 경우가 있으면
        // lastMsgContent 키를 쓰도록 mapper를 바꾸는 게 정석이다.
        paramMap.put("lastMsgContent", preview);

        // --- 방의 마지막 메시지 내용/시간 업데이트 ---
        // ✅ 권장: updateChatRoomLastMessage에서 LAST_MSG_CONTENT = #{lastMsgContent}로 받게 수정
        // (현재는 에러 로그 상 #{content}로 업데이트하고 있어서 터졌음)
        dao.update(roomNamespace + ".updateChatRoomLastMessage", paramMap);
    }

    /** 메시지 수정 */
    @Transactional
    public void updateChatMessage(Map<String, Object> paramMap) {
        dao.update(namespace + ".updateChatMessage", paramMap);
    }

    /** 메시지 삭제 (Soft Delete) */
    @Transactional
    public void deleteChatMessage(Map<String, Object> paramMap) {
        dao.update(namespace + ".deleteChatMessage", paramMap);
    }

    /**
     * 채팅방 목록용 마지막 메시지 미리보기 정리
     * - 공백/개행 정리(리스트에서 한 줄로 보기 위함)
     */
    private String normalizeForLastMessage(String s) {
        if (s == null) return "";
        String t = s;

        // CRLF/LF/탭을 공백으로
        t = t.replace("\r\n", " ").replace("\n", " ").replace("\r", " ").replace("\t", " ");

        // 연속 공백 축약(간단 버전)
        while (t.contains("  ")) {
            t = t.replace("  ", " ");
        }

        return t.trim();
    }
}
