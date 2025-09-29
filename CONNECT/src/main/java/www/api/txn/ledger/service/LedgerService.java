package www.api.txn.ledger.service;

import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import www.com.util.CommonDao;

@Service
public class LedgerService {

    private final String namespace = "www.api.txn.ledger.Ledger";

    @Autowired
    private CommonDao dao;

    /**
     * 템플릿 목록 조회
     */
    public List<Map<String, Object>> selectLedgerList(Map<String, Object> paramMap) {
        return dao.list(namespace + ".selectLedgerList", paramMap);
    }

    /**
     * 템플릿 목록 수 조회
     */
    public int selectLedgerListCount(Map<String, Object> paramMap) {
        Map<String, Object> resultMap = dao.selectOne(namespace + ".selectLedgerListCount", paramMap);
        if (resultMap != null && resultMap.get("cnt") != null) {
            return Integer.parseInt(resultMap.get("cnt").toString());
        }
        return 0;
    }

    /**
     * 템플릿 단건 조회
     */
    public Map<String, Object> selectLedgerDetail(Map<String, Object> paramMap) {
        return dao.selectOne(namespace + ".selectLedgerDetail", paramMap);
    }

    /**
     * 템플릿 등록
     */
    @Transactional
    public void insertLedger(Map<String, Object> paramMap) {
        dao.insert(namespace + ".insertLedger", paramMap);
    }

    /**
     * 템플릿 수정
     */
    @Transactional
    public void updateLedger(Map<String, Object> paramMap) {
        dao.update(namespace + ".updateLedger", paramMap);
    }

    /**
     * 템플릿 삭제
     */
    @Transactional
    public void deleteLedger(Map<String, Object> paramMap) {
        dao.delete(namespace + ".deleteLedger", paramMap);
    }
}
