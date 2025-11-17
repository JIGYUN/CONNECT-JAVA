package www.api.cht.chat.service;

import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import www.com.util.CommonDao;

@Service
public class ChatRoomService {

    // Mapper namespace와 맞춤
    private final String namespace = "www.api.cht.chat.ChatRoom";

    @Autowired
    private CommonDao dao;

    /** 채팅방 목록 조회 */
    public List<Map<String, Object>> selectChatRoomList(Map<String, Object> paramMap) {
        return dao.list(namespace + ".selectChatRoomList", paramMap);
    }

    /** 채팅방 목록 수 조회 */
    public int selectChatRoomListCount(Map<String, Object> paramMap) {
        Map<String, Object> resultMap = dao.selectOne(namespace + ".selectChatRoomListCount", paramMap);
        if (resultMap != null && resultMap.get("cnt") != null) {
            return Integer.parseInt(resultMap.get("cnt").toString());
        }
        return 0;
    }

    /** 채팅방 단건 조회 */
    public Map<String, Object> selectChatRoomDetail(Map<String, Object> paramMap) {
        return dao.selectOne(namespace + ".selectChatRoomDetail", paramMap);
    }

    /** 채팅방 등록 */
    @Transactional
    public void insertChatRoom(Map<String, Object> paramMap) {
        // 기본값
        if (!paramMap.containsKey("roomType") || paramMap.get("roomType") == null) {
            paramMap.put("roomType", "DIRECT");
        }
        dao.insert(namespace + ".insertChatRoom", paramMap);
    }

    /** 채팅방 수정 */
    @Transactional
    public void updateChatRoom(Map<String, Object> paramMap) {
        dao.update(namespace + ".updateChatRoom", paramMap);
    }

    /** 채팅방 삭제 (Soft Delete) */
    @Transactional
    public void deleteChatRoom(Map<String, Object> paramMap) {
        dao.update(namespace + ".deleteChatRoom", paramMap);
    }
}
