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

    /** 메시지 등록 + 채팅방의 마지막 메시지 정보 갱신 */
    @Transactional
    public void insertChatMessage(Map<String, Object> paramMap) {
        // 기본값
        if (!paramMap.containsKey("contentType") || paramMap.get("contentType") == null) {
            paramMap.put("contentType", "TEXT");
        }
        if (!paramMap.containsKey("useAt") || paramMap.get("useAt") == null) {
            paramMap.put("useAt", "Y");
        }
        if (!paramMap.containsKey("readCnt") || paramMap.get("readCnt") == null) {
            paramMap.put("readCnt", 0);
        }

        dao.insert(namespace + ".insertChatMessage", paramMap);

        // 방의 마지막 메시지 내용/시간 업데이트
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
}
