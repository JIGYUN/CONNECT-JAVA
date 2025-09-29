package www.api.sys.menuItem.service;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import www.com.util.CommonDao;

@Service
public class MenuItemService {

    private final String namespace = "www.api.sys.menuItem.MenuItem";

    @Autowired
    private CommonDao dao;

    /**
     * 템플릿 목록 조회
     */
    public List<Map<String, Object>> selectMenuItemList(Map<String, Object> paramMap) {
        return dao.list(namespace + ".selectMenuItemList", paramMap);
    }

    /**
     * 템플릿 목록 수 조회
     */
    public int selectMenuItemListCount(Map<String, Object> paramMap) {
        Map<String, Object> resultMap = dao.selectOne(namespace + ".selectMenuItemListCount", paramMap);
        if (resultMap != null && resultMap.get("cnt") != null) {
            return Integer.parseInt(resultMap.get("cnt").toString());
        }
        return 0;
    }

    /**
     * 템플릿 단건 조회
     */
    public Map<String, Object> selectMenuItemDetail(Map<String, Object> paramMap) {
        return dao.selectOne(namespace + ".selectMenuItemDetail", paramMap);
    }
    
    // 메뉴 트리 조회 (사이드바)
    public List<Map<String, Object>> selectSidebarTree(String menuGroupId, List<String> roleList) {
        Map<String, Object> p = new HashMap<>();
        p.put("menuGroupId", menuGroupId);
        p.put("roleList", roleList);

        List<Map<String, Object>> rows = dao.list(namespace + ".selectMenuItemForSidebar", p);
        // id -> row 맵 + children 초기화
        Map<Long, Map<String, Object>> byId = new LinkedHashMap<>();
        for (Map<String, Object> r : rows) {
            r.put("children", new ArrayList<Map<String, Object>>());
            Object id = r.get("menuId");
            if (id != null) byId.put(((Number) id).longValue(), r);
        }
        // 루트 목록
        List<Map<String, Object>> roots = new ArrayList<>();
        for (Map<String, Object> r : rows) {
            Object up = r.get("upperMenuId");
            if (up == null) {
                roots.add(r);
            } else {
                Map<String, Object> parent = byId.get(((Number) up).longValue());
                if (parent != null) {
                    @SuppressWarnings("unchecked")
                    List<Map<String, Object>> ch = (List<Map<String, Object>>) parent.get("children");
                    ch.add(r);
                } else {
                    roots.add(r); // 부모가 비활성인 경우 안전하게 루트로
                }
            }
        }
        return roots;
    }

    /**
     * 템플릿 등록
     */
    @Transactional
    public void insertMenuItem(Map<String, Object> paramMap) {
        dao.insert(namespace + ".insertMenuItem", paramMap);
    }

    /**
     * 템플릿 수정
     */
    @Transactional
    public void updateMenuItem(Map<String, Object> paramMap) {
        dao.update(namespace + ".updateMenuItem", paramMap);
    }

    /**
     * 템플릿 삭제
     */
    @Transactional
    public void deleteMenuItem(Map<String, Object> paramMap) {
        dao.delete(namespace + ".deleteMenuItem", paramMap);
    }
}
