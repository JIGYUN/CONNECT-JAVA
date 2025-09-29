package www.api.com.mail.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.CollectionUtils;
import org.springframework.web.util.HtmlUtils;
import www.api.com.file.service.FileService;
import www.com.util.CommonDao;
import www.com.util.CoreProperties;

import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeMessage;
import org.springframework.mail.javamail.MimeMessageHelper;

import java.io.File;
import java.nio.charset.StandardCharsets;
import java.util.*;

/**
 * 즉시 발송 + 잡/로그 저장 메일 서비스.
 *
 * 파라미터 예시:
 *  - to        : String("a@b.com,a2@b.com") | List<String>   (필수)
 *  - cc        : String | List<String>                         (선택)
 *  - bcc       : String | List<String>                         (선택)
 *  - subject   : String                                        (선택)
 *  - bodyHtml  : String (HTML)                                 (선택)
 *  - fileGrpId : Long                                          (선택, 그룹 내 전체 첨부)
 *  - from      : String                                        (선택, 없으면 properties mail.from)
 */
@Service
public class MailService {

    private static final String NS = "www.api.com.mail.Mail";
    private static final ObjectMapper MAPPER = new ObjectMapper();

    @Autowired
    private JavaMailSender mailSender;

    @Autowired
    private CommonDao dao;

    // 첨부(선택)
    @Autowired(required = false)
    private FileService fileService;

    /**
     * 즉시 발송 + DB 기록.
     * 성공/실패와 무관하게 TB_MAIL_JOB / TB_MAIL_LOG 기록을 남긴다.
     */
    @Transactional
    public Map<String, Object> sendNow(Map<String, Object> param) {
        Map<String, Object> res = new HashMap<>();
        Long jobId = null;

        // -------- 1) 파라미터 파싱 --------
        String subject = str(param.get("subject"));
        String bodyHtml = str(param.get("bodyHtml"));
        String from = !isEmpty(param.get("from"))
                ? str(param.get("from"))
                : CoreProperties.getProperty("mail.from");

        List<String> toList = normalizeAddr(param.get("to"));
        List<String> ccList = normalizeAddr(param.get("cc"));
        List<String> bccList = normalizeAddr(param.get("bcc"));

        if (CollectionUtils.isEmpty(toList)) {
            throw new IllegalArgumentException("required: to");
        }
        if (isEmpty(subject)) subject = "(제목 없음)";
        if (isEmpty(bodyHtml)) bodyHtml = "<p>(내용 없음)</p>";

        String toCsv  = String.join(",", toList);
        String ccCsv  = CollectionUtils.isEmpty(ccList)  ? null : String.join(",", ccList);
        String bccCsv = CollectionUtils.isEmpty(bccList) ? null : String.join(",", bccList);

        Long fileGrpId = toLong(param.get("fileGrpId"));

        String paramJson = toJsonSafe(param);

        // -------- 2) TB_MAIL_JOB : READY insert --------
        Map<String, Object> job = new HashMap<>();
        job.put("tmplCd",     str(param.get("tmplCd"))); // 없으면 null 저장
        job.put("subject",    subject);
        job.put("bodyHtml",   bodyHtml);
        job.put("to",         toCsv);
        job.put("cc",         ccCsv);
        job.put("bcc",        bccCsv);
        job.put("fileGrpId",  fileGrpId);
        job.put("paramJson",  paramJson);
        job.put("sendAt",     null);   // 즉시 발송: NOW() 조건에 맞게 Mapper에서 처리, 혹은 null 허용
        dao.insert(NS + ".insertMailJob", job);

        jobId = (job.get("jobId") instanceof Number) ? ((Number) job.get("jobId")).longValue() : null;

        // -------- 3) 상태: SENDING, TRY_CNT + 1 --------
        if (jobId != null) {
            Map<String, Object> upTry = new HashMap<>();
            upTry.put("jobId", jobId);
            upTry.put("lastErrMsg", null);
            dao.update(NS + ".increaseJobTry", upTry);

            Map<String, Object> upStat = new HashMap<>();
            upStat.put("jobId", jobId);
            upStat.put("statusCd", "SENDING");
            dao.update(NS + ".updateJobStatus", upStat);
        }

        // -------- 4) 메일 빌드 & 발송 --------
        boolean success = false;
        String lastErr = null;
        try {
            MimeMessage mime = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(mime, true, StandardCharsets.UTF_8.name());

            helper.setFrom(new InternetAddress(from));
            helper.setSubject(subject);
            helper.setText(bodyHtml, true);

            for (String t : toList)  helper.addTo(new InternetAddress(t));
            if (!CollectionUtils.isEmpty(ccList))  for (String c : ccList)  helper.addCc(new InternetAddress(c));
            if (!CollectionUtils.isEmpty(bccList)) for (String b : bccList) helper.addBcc(new InternetAddress(b));

            // 첨부
            if (fileGrpId != null && fileGrpId > 0 && fileService != null) {
                List<Map<String, Object>> files = fileService.listByGroup(fileGrpId);
                if (files != null) {
                    String root = CoreProperties.getProperty("file.upload.path");
                    for (Map<String, Object> f : files) {
                        String savePath  = str(f.get("savePath"));
                        String saveFile  = str(f.get("saveFileNm"));
                        String orgFileNm = str(f.get("orgFileNm"));
                        if (isEmpty(saveFile)) continue;

                        String base = root;
                        if (!base.endsWith("/") && !base.endsWith("\\")) base += File.separator;
                        if (!isEmpty(savePath)) base += (savePath + File.separator);

                        File disk = new File(base + saveFile);
                        if (disk.exists() && disk.isFile()) {
                            helper.addAttachment(orgFileNm, disk);
                        }
                    }
                }
            }

            mailSender.send(mime);
            success = true;
        } catch (Exception e) {
            lastErr = e.getClass().getSimpleName() + ": " + e.getMessage();
        }

        // -------- 5) 결과 기록 (상태/로그) --------
        if (jobId != null) {
            if (success) {
                Map<String, Object> upStat = new HashMap<>();
                upStat.put("jobId", jobId);
                upStat.put("statusCd", "SENT");
                dao.update(NS + ".updateJobStatus", upStat);

                Map<String, Object> log = new HashMap<>();
                log.put("jobId", jobId);
                log.put("subject", subject);
                log.put("toAddr", toCsv);
                log.put("resultCd", "SUCCESS");
                log.put("errMsg", null);
                dao.insert(NS + ".insertMailLog", log);
            } else {
                Map<String, Object> upTry = new HashMap<>();
                upTry.put("jobId", jobId);
                upTry.put("lastErrMsg", lastErr);
                dao.update(NS + ".increaseJobTry", upTry);

                Map<String, Object> upStat = new HashMap<>();
                upStat.put("jobId", jobId);
                upStat.put("statusCd", "FAIL");
                dao.update(NS + ".updateJobStatus", upStat);

                Map<String, Object> log = new HashMap<>();
                log.put("jobId", jobId);
                log.put("subject", subject);
                log.put("toAddr", toCsv);
                log.put("resultCd", "FAIL");
                log.put("errMsg", lastErr);
                dao.insert(NS + ".insertMailLog", log);
            }
        }

        // -------- 6) 응답 --------
        res.put("msg", success ? "ok" : "error");
        res.put("jobId", jobId);
        res.put("status", success ? "SENT" : "FAIL");
        res.put("to", toList);
        if (!success) res.put("error", lastErr);
        return res;
    }

    /* ========= 유틸 ========= */

    private List<String> normalizeAddr(Object v) {
        if (v == null) return Collections.emptyList();
        if (v instanceof String) {
            String s = ((String) v).trim();
            if (s.isEmpty()) return Collections.emptyList();
            String[] parts = s.split("[,;\\s]+");
            List<String> out = new ArrayList<>();
            for (String p : parts) if (!p.trim().isEmpty()) out.add(p.trim());
            return out;
        }
        if (v instanceof Collection) {
            List<String> out = new ArrayList<>();
            for (Object o : (Collection<?>) v) {
                if (o != null && !o.toString().trim().isEmpty()) out.add(o.toString().trim());
            }
            return out;
        }
        return Collections.singletonList(v.toString().trim());
    }

    private String str(Object v) { return v == null ? "" : String.valueOf(v); }

    private boolean isEmpty(Object v) {
        if (v == null) return true;
        if (v instanceof String) return ((String) v).trim().isEmpty();
        return false;
    }

    private Long toLong(Object v) {
        if (v == null) return null;
        if (v instanceof Number) return ((Number) v).longValue();
        try { return Long.parseLong(String.valueOf(v)); } catch (Exception e) { return null; }
    }

    private String toJsonSafe(Object o) {
        try {
            return MAPPER.writeValueAsString(o);
        } catch (JsonProcessingException e) {
            // JSON 변환 실패 시 최소한의 정보라도 남긴다
            return "{\"error\":\"jsonSerializeFail\",\"msg\":\"" + e.getMessage().replace("\"","'") + "\"}";
        }
    }
}