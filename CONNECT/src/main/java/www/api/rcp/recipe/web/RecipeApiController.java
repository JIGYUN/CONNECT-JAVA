package www.api.rcp.recipe.web;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import www.api.rcp.recipe.service.RecipeService;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/rcp/recipe")
public class RecipeApiController {

    @Autowired
    private RecipeService service;

    @PostMapping("/selectList")
    public Map<String, Object> selectList(@RequestBody Map<String, Object> param) {
        Map<String, Object> res = new HashMap<>();
        res.putAll(service.selectRecipeList(param));
        res.put("msg", "ok");
        return res;
    }

    @PostMapping("/selectDetail")
    public Map<String, Object> selectDetail(@RequestBody Map<String, Object> param) {
        Map<String, Object> res = new HashMap<>();
        res.putAll(service.selectRecipeDetail(param));
        res.put("msg", "ok");
        return res;
    }

    @PostMapping("/insert")
    public Map<String, Object> insert(@RequestBody Map<String, Object> param) {
        Map<String, Object> res = new HashMap<>();
        res.putAll(service.insertRecipe(param));
        res.put("msg", "ok");
        return res;
    }

    @PostMapping("/update")
    public Map<String, Object> update(@RequestBody Map<String, Object> param) {
        int cnt = service.updateRecipe(param);
        Map<String, Object> res = new HashMap<>();
        res.put("updated", cnt);
        res.put("msg", "ok");
        return res;
    }

    @PostMapping("/delete")
    public Map<String, Object> delete(@RequestBody Map<String, Object> param) {
        int cnt = service.deleteRecipe(param);
        Map<String, Object> res = new HashMap<>();
        res.put("deleted", cnt);
        res.put("msg", "ok");
        return res;
    }
}