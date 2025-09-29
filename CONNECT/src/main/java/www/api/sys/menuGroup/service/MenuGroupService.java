package www.api.sys.menuGroup.service;

import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import www.com.util.CommonDao;

@Service
public class MenuGroupService {

    private final String namespace = "www.api.sys.menuGroup.MenuGroup";

    @Autowired
    private CommonDao dao;

    /**
     * 템플릿 목록 조회
     */
    public List<Map<String, Object>> selectMenuGroupList(Map<String, Object> paramMap) {
        return dao.list(namespace + ".selectMenuGroupList", paramMap);
    }

    /**
     * 템플릿 목록 수 조회
     */
    public int selectMenuGroupListCount(Map<String, Object> paramMap) {
        Map<String, Object> resultMap = dao.selectOne(namespace + ".selectMenuGroupListCount", paramMap);
        if (resultMap != null && resultMap.get("cnt") != null) {
            return Integer.parseInt(resultMap.get("cnt").toString());
        }
        return 0;
    }

    /**
     * 템플릿 단건 조회
     */
    public Map<String, Object> selectMenuGroupDetail(Map<String, Object> paramMap) {
        return dao.selectOne(namespace + ".selectMenuGroupDetail", paramMap);
    }

    /**
     * 템플릿 등록
     */
    @Transactional
    public void insertMenuGroup(Map<String, Object> paramMap) {
        dao.insert(namespace + ".insertMenuGroup", paramMap);
    }

    /**
     * 템플릿 수정
     */
    @Transactional
    public void updateMenuGroup(Map<String, Object> paramMap) {
        dao.update(namespace + ".updateMenuGroup", paramMap);
    }

    /**
     * 템플릿 삭제
     */
    @Transactional
    public void deleteMenuGroup(Map<String, Object> paramMap) {
        dao.delete(namespace + ".deleteMenuGroup", paramMap);
    }
}
