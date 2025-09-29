package www.api.com.mail.web;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;
import www.api.com.mail.service.MailService;

import java.util.HashMap;
import java.util.Map;

@Controller
public class MailController {

    @Autowired
    private MailService mailService;

    /**
     * 즉시 발송 API
     * body: { to, cc?, bcc?, subject, bodyHtml, fileGrpId? }
     */
    @RequestMapping("/api/com/mail/sendNow")
    @ResponseBody
    public Map<String, Object> sendNow(@RequestBody HashMap<String, Object> map) {
        return mailService.sendNow(map);
    }
}