package www.api.smp.sample.service;

import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import www.com.util.CommonDao;

@Service
public class TemplateService {

    private final String namespace = "www.api.BIZ_SEG.template.Template";

    @Autowired
    private CommonDao dao;

    /**
     * 템플릿 목록 조회
     */
    public List<Map<String, Object>> selectTemplateList(Map<String, Object> paramMap) {
        return dao.list(namespace + ".selectTemplateList", paramMap);
    }

    /**
     * 템플릿 목록 수 조회
     */
    public int selectTemplateListCount(Map<String, Object> paramMap) {
        Map<String, Object> resultMap = dao.selectOne(namespace + ".selectTemplateListCount", paramMap);
        if (resultMap != null && resultMap.get("cnt") != null) {
            return Integer.parseInt(resultMap.get("cnt").toString());
        }
        return 0;
    }

    /**
     * 템플릿 단건 조회
     */
    public Map<String, Object> selectTemplateDetail(Map<String, Object> paramMap) {
        return dao.selectOne(namespace + ".selectTemplateDetail", paramMap);
    }

    /**
     * 템플릿 등록
     */
    @Transactional
    public void insertTemplate(Map<String, Object> paramMap) {
        dao.insert(namespace + ".insertTemplate", paramMap);
    }

    /**
     * 템플릿 수정
     */
    @Transactional
    public void updateTemplate(Map<String, Object> paramMap) {
        dao.update(namespace + ".updateTemplate", paramMap);
    }

    /**
     * 템플릿 삭제
     */
    @Transactional
    public void deleteTemplate(Map<String, Object> paramMap) {
        dao.delete(namespace + ".deleteTemplate", paramMap);
    }
}