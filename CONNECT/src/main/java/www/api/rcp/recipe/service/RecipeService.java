package www.api.rcp.recipe.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import www.com.util.CommonDao;

import java.util.*;

@Service
public class RecipeService {

    private static final String NS = "www.api.rcp.recipe.Recipe";

    @Autowired
    private CommonDao dao;

    /* ===== 목록/상세 ===== */

    public Map<String, Object> selectRecipeList(Map<String, Object> param) {
        List<Map<String, Object>> list = dao.list(NS + ".selectRecipeList", param);
        int total = dao.selectOneInt(NS + ".selectRecipeListCount", param);
        Map<String, Object> res = new HashMap<>();
        res.put("list", list);
        res.put("total", total);
        return res;
    }

    public Map<String, Object> selectRecipeDetail(Map<String, Object> param) {
        Map<String, Object> base = dao.selectOne(NS + ".selectRecipeDetail", param);
        if (base == null) return Collections.emptyMap();
        Long recipeId = toLong(base.get("RECIPE_ID"), base.get("recipeId"));
        Map<String, Object> key = new HashMap<>();
        key.put("recipeId", recipeId);
        List<Map<String, Object>> steps = dao.list(NS + ".selectRecipeSteps", key);
        List<Map<String, Object>> ings  = dao.list(NS + ".selectRecipeIngs", key);
        Map<String, Object> out = new HashMap<>();
        out.put("recipe", base);
        out.put("steps", steps);
        out.put("ings", ings);
        return out;
    }

    /* ===== 등록/수정/삭제 ===== */

    @Transactional
    public Map<String, Object> insertRecipe(Map<String, Object> param) {
        // 기본값/필수값
        if (isEmpty(param.get("title"))) throw new IllegalArgumentException("title required");
        if (isEmpty(param.get("recipeCd"))) throw new IllegalArgumentException("recipeCd required");

        dao.insert(NS + ".insertRecipe", param); // keyProperty -> recipeId
        Long recipeId = toLong(param.get("recipeId"));
        upsertChildren(recipeId, param);
        Map<String, Object> res = new HashMap<>();
        res.put("recipeId", recipeId);
        return res;
    }

    @Transactional
    public int updateRecipe(Map<String, Object> param) {
        Long recipeId = toLong(param.get("recipeId"));
        if (recipeId == null) throw new IllegalArgumentException("recipeId required");
        int cnt = dao.update(NS + ".updateRecipe", param);
        upsertChildren(recipeId, param);
        return cnt;
    }

    @Transactional
    public int deleteRecipe(Map<String, Object> param) {
        Long recipeId = toLong(param.get("recipeId"));
        if (recipeId == null) throw new IllegalArgumentException("recipeId required");
        dao.delete(NS + ".deleteStepsByRecipe", param);
        dao.delete(NS + ".deleteIngsByRecipe", param);
        return dao.delete(NS + ".deleteRecipe", param);
    }

    /* ===== 내부 유틸 ===== */

    @SuppressWarnings("unchecked")
    private void upsertChildren(Long recipeId, Map<String, Object> param) {
        // 전체 갈아끼우기 전략
        Map<String, Object> key = new HashMap<>();
        key.put("recipeId", recipeId);

        dao.delete(NS + ".deleteStepsByRecipe", key);
        dao.delete(NS + ".deleteIngsByRecipe", key);

        List<Map<String, Object>> steps = (List<Map<String, Object>>) param.get("steps");
        if (steps != null) {
            int ordr = 1;
            for (Map<String, Object> s : steps) {
                Map<String, Object> row = new HashMap<>();
                row.put("recipeId", recipeId);
                row.put("stepOrdr", toInt(s.get("stepOrdr"), ordr));
                row.put("instrHtml", str(s.get("instrHtml")));
                row.put("timerSec", toInt(s.get("timerSec"), null));
                row.put("fileGrpId", toLong(s.get("fileGrpId")));
                dao.insert(NS + ".insertRecipeStep", row);
                ordr++;
            }
        }

        List<Map<String, Object>> ings = (List<Map<String, Object>>) param.get("ings");
        if (ings != null) {
            for (Map<String, Object> g : ings) {
                Map<String, Object> row = new HashMap<>();
                row.put("recipeId", recipeId);
                row.put("ingNmTxt", str(g.get("ingNmTxt")));
                row.put("qtyNum", toDecimalString(g.get("qtyNum"))); // DECIMAL-safe
                row.put("unitCd", str(g.get("unitCd")));
                row.put("noteTxt", str(g.get("noteTxt")));
                row.put("groupNm", str(g.get("groupNm")));
                dao.insert(NS + ".insertRecipeIng", row);
            }
        }
    }

    private String str(Object v) { return v == null ? null : String.valueOf(v); }
    private boolean isEmpty(Object v) { return v == null || (v instanceof String && ((String) v).trim().isEmpty()); }

    private Long toLong(Object... vs) {
        for (Object v : vs) {
            if (v == null) continue;
            if (v instanceof Number) return ((Number) v).longValue();
            try { return Long.parseLong(String.valueOf(v)); } catch (Exception ignore) {}
        }
        return null;
    }

    private Integer toInt(Object v, Integer defVal) {
        if (v == null) return defVal;
        if (v instanceof Number) return ((Number) v).intValue();
        try { return Integer.parseInt(String.valueOf(v)); } catch (Exception e) { return defVal; }
    }

    private String toDecimalString(Object v) {
        if (v == null) return null;
        String s = String.valueOf(v).trim();
        return s.isEmpty() ? null : s;
    }
}