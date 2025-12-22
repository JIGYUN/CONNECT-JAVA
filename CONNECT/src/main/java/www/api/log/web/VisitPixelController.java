package www.api.log.web;

import java.io.OutputStream;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import www.api.log.service.VisitMainService;

@Controller
public class VisitPixelController {

    @Autowired
    private VisitMainService visitMainService;

    // 1x1 transparent gif (43 bytes)
    private static final byte[] GIF_1X1 = new byte[] {
        71,73,70,56,57,97,1,0,1,0,-128,0,0,0,0,0,-1,-1,-1,33,-7,4,1,0,0,1,0,44,0,0,0,0,1,0,1,0,0,2,2,68,1,0,59
    };

    @RequestMapping("/px/main.gif")
    public void mainPixel(
            @RequestParam(value = "site", required = false) String site,
            HttpServletRequest request,
            HttpServletResponse response
    ) throws Exception {

        String siteCd = normalizeSite(site);
        if (siteCd != null) {
            visitMainService.recordMainVisit(request, siteCd);
        }

        response.setContentType("image/gif");
        response.setHeader("Cache-Control", "no-store, no-cache, must-revalidate, max-age=0");
        response.setHeader("Pragma", "no-cache");
        response.setDateHeader("Expires", 0);

        OutputStream os = response.getOutputStream();
        os.write(GIF_1X1);
        os.flush();
    }

    private static String normalizeSite(String site) {
        if (site == null) return null;
        String v = site.trim().toUpperCase();
        if ("PC_MAIN".equals(v)) return "PC_MAIN";
        if ("REACT_MAIN".equals(v)) return "REACT_MAIN";
        return null;
    }
}
