package adm.mai.adm;

import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("/adm/mai")   // ★ 핵심: /adm 접두사 포함
public class AdmMainController {

    @RequestMapping("/main/main")
    public String main(ModelMap model) throws Exception {
        return "adm/mai/main/main"; // 뷰: /WEB-INF/views/adm/mai/main/main.jsp (prefix/suffix에 맞춰)
    }
    
} 