package www.api.tsk.diary.service;

import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import www.com.util.CommonDao;

@Service
public class DiaryService {

    private final String namespace = "www.api.tsk.diary.Diary";

    @Autowired
    private CommonDao dao;

    public List<Map<String, Object>> selectDiaryList(Map<String, Object> paramMap) {
        return dao.list(namespace + ".selectDiaryList", paramMap);
    }

    public int selectDiaryListCount(Map<String, Object> paramMap) {
        Map<String, Object> r = dao.selectOne(namespace + ".selectDiaryListCount", paramMap);
        if (r != null && r.get("cnt") != null) return Integer.parseInt(String.valueOf(r.get("cnt")));
        return 0;
    }

    public Map<String, Object> selectDiaryDetail(Map<String, Object> paramMap) {
        return dao.selectOne(namespace + ".selectDiaryDetail", paramMap);
    }

    // ✅ 날짜 단건
    public Map<String, Object> selectDiaryByDate(Map<String, Object> paramMap) {
        return dao.selectOne(namespace + ".selectDiaryByDate", paramMap);
    }

    @Transactional
    public void insertDiary(Map<String, Object> paramMap) {
        dao.insert(namespace + ".insertDiary", paramMap);
    }

    @Transactional
    public void updateDiary(Map<String, Object> paramMap) {
        dao.update(namespace + ".updateDiary", paramMap);
    }

    @Transactional
    public void deleteDiary(Map<String, Object> paramMap) {
        dao.delete(namespace + ".deleteDiary", paramMap);
    }

    // ✅ 업서트(1일 1건)
    @Transactional
    public void upsertDiary(Map<String, Object> paramMap) {
        dao.insert(namespace + ".upsertDiary", paramMap); // ON DUPLICATE KEY UPDATE
    }
}