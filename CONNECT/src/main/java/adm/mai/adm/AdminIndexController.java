package adm.mai.adm;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("/adm")
public class AdminIndexController {

    // /adm 또는 /adm/ 로 접근 시 관리자 메인으로
    @GetMapping({"", "/"})
    public String index() {
        return "redirect:/adm/mai/main/main";
    }
}

