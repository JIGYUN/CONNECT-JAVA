package www.api.tsk.task.service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import www.com.util.CommonDao;

@Service
public class TaskService {

    private final String namespace = "www.api.tsk.task.Task";

    @Autowired
    private CommonDao dao;

    // ---------- 기존 목록/상세/카운트 ----------
    /** 템플릿 목록 조회 */
    public List<Map<String, Object>> selectTaskList(Map<String, Object> paramMap) {
        return dao.list(namespace + ".selectTaskList", paramMap);
    }

    /** 템플릿 목록 수 조회 */
    public int selectTaskListCount(Map<String, Object> paramMap) {
        Map<String, Object> resultMap = dao.selectOne(namespace + ".selectTaskListCount", paramMap);
        if (resultMap != null && resultMap.get("cnt") != null) {
            return Integer.parseInt(resultMap.get("cnt").toString());
        }
        return 0;
    }

    /** 템플릿 단건 조회 */
    public Map<String, Object> selectTaskDetail(Map<String, Object> paramMap) {
        coerceTaskNo(paramMap);
        return dao.selectOne(namespace + ".selectTaskDetail", paramMap);
    }

    // ---------- 신규: 날짜별 목록 ----------
    /** 선택일(YYYY-MM-DD) 목록 조회 (null이면 오늘) */
    public List<Map<String, Object>> selectTaskListByDate(Map<String, Object> paramMap) {
        return dao.list(namespace + ".selectTaskListByDate", paramMap);
    }

    // ---------- 등록/수정/토글/삭제 ----------
    /** 템플릿 등록 */
    @Transactional
    public void insertTask(Map<String, Object> paramMap) {
        // 기본값 보정
        paramMap.putIfAbsent("statusCd", "TODO");
        paramMap.putIfAbsent("useAt", "Y");
        dao.insert(namespace + ".insertTask", paramMap);
    }

    /** 템플릿 수정 */
    @Transactional
    public void updateTask(Map<String, Object> paramMap) {
        coerceTaskNo(paramMap);
        dao.update(namespace + ".updateTask", paramMap);
    }

    /** 상태 토글(TODO↔DONE) */
    @Transactional
    public void toggleTask(Map<String, Object> paramMap) {
        coerceTaskNo(paramMap);
        dao.update(namespace + ".toggleTaskStatus", paramMap);
    }

    /** Soft 삭제(USE_AT='N') */
    @Transactional
    public void deleteTask(Map<String, Object> paramMap) {
        coerceTaskNo(paramMap);
        dao.update(namespace + ".softDeleteTask", paramMap);
    }

    /** 하드 삭제(옵션) */
    @Transactional
    public void purgeTask(Map<String, Object> paramMap) {
        coerceTaskNo(paramMap);
        dao.delete(namespace + ".deleteTask", paramMap);
    }

    // ---------- 유틸 ----------
    /** 기존 클라이언트가 taskId로 보내와도 동작하도록 보정 */
    private void coerceTaskNo(Map<String, Object> map) {
        if (map == null) return;
        Object taskNo = map.get("taskNo");
        if (taskNo == null && map.get("taskId") != null) {
            map.put("taskNo", map.get("taskId"));
        }
    }
}