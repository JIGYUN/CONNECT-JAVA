package www.api.cht.chatRoomUser.service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import www.com.util.CommonDao;

@Service
public class ChatRoomUserService {

    private final String namespace = "www.api.cht.chatRoomUser.ChatRoomUser";

    @Autowired
    private CommonDao dao;

    /**
     * 목록 조회
     */
    public List<Map<String, Object>> selectChatRoomUserList(Map<String, Object> paramMap) {
        return dao.list(namespace + ".selectChatRoomUserList", paramMap);
    }

    /**
     * 목록 수 조회
     */
    public int selectChatRoomUserListCount(Map<String, Object> paramMap) {
        Map<String, Object> resultMap = dao.selectOne(namespace + ".selectChatRoomUserListCount", paramMap);
        if (resultMap != null && resultMap.get("cnt") != null) {
            return Integer.parseInt(resultMap.get("cnt").toString());
        }
        return 0;
    }

    /**
     * 단건 조회
     */
    public Map<String, Object> selectChatRoomUserDetail(Map<String, Object> paramMap) {
        return dao.selectOne(namespace + ".selectChatRoomUserDetail", paramMap);
    }

    /**
     * 등록
     */
    @Transactional
    public void insertChatRoomUser(Map<String, Object> paramMap) {
        dao.insert(namespace + ".insertChatRoomUser", paramMap);
    }

    /**
     * 수정
     */
    @Transactional
    public void updateChatRoomUser(Map<String, Object> paramMap) {
        dao.update(namespace + ".updateChatRoomUser", paramMap);
    }

    /**
     * 삭제
     */
    @Transactional
    public void deleteChatRoomUser(Map<String, Object> paramMap) {
        dao.delete(namespace + ".deleteChatRoomUser", paramMap);
    }

    /**
     * ✅ 채팅방 입장용 upsert 로직
     *
     * - roomId + userId 기준으로 조회
     *   - 없음  → insertChatRoomUserForJoin 로 INSERT
     *   - USE_AT='Y' → 그대로 리턴 (중복 insert 방지)
     *   - USE_AT='N' → rejoinChatRoomUser 로 재입장 처리
     */
    @Transactional
    public Map<String, Object> joinChatRoomUser(Map<String, Object> paramMap) {
        Long roomId = toLong(paramMap.get("roomId"));
        Long userId = toLong(paramMap.get("userId"));

        if (roomId == null || userId == null) {
            throw new IllegalArgumentException("roomId / userId 필수");
        }

        Map<String, Object> keyMap = new HashMap<>();
        keyMap.put("roomId", roomId);
        keyMap.put("userId", userId);

        Map<String, Object> exists = dao.selectOne(namespace + ".selectOneByRoomIdAndUserId", keyMap);

        // 1) 최초 입장: 기록 없음 → INSERT
        if (exists == null) {
            Map<String, Object> insertParam = new HashMap<>();
            insertParam.put("roomId", roomId);
            insertParam.put("userId", userId);
            insertParam.put("roleCd", paramMap.getOrDefault("roleCd", "MEMBER"));
            insertParam.put("useAt", "Y");
            insertParam.put("createdBy", paramMap.get("userId"));
            insertParam.put("updatedBy", paramMap.get("userId"));

            dao.insert(namespace + ".insertChatRoomUserForJoin", insertParam);
            return dao.selectOne(namespace + ".selectOneByRoomIdAndUserId", keyMap);
        }

        // 2) 이미 활성 멤버 → 그대로 리턴
        Object useAtObj = exists.get("useAt");
        String useAt = (useAtObj != null) ? useAtObj.toString() : null;
        if ("Y".equals(useAt)) {
            return exists;
        }

        // 3) 이전에 나갔던 멤버 → 재입장
        Map<String, Object> rejoinParam = new HashMap<>();
        rejoinParam.put("roomId", roomId);
        rejoinParam.put("userId", userId);
        rejoinParam.put("updatedBy", paramMap.get("updatedBy"));

        dao.update(namespace + ".rejoinChatRoomUser", rejoinParam);
        return dao.selectOne(namespace + ".selectOneByRoomIdAndUserId", keyMap);
    }

    private Long toLong(Object v) {
        if (v == null) return null;
        if (v instanceof Long) return (Long) v;
        if (v instanceof Number) return ((Number) v).longValue();
        try {
            return Long.valueOf(v.toString());
        } catch (Exception e) {
            return null;
        }
    }
}
