package www.api.com.file.web;

import org.apache.http.HttpHeaders;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import www.api.com.file.service.FileService;

import javax.servlet.http.HttpServletResponse;
import java.io.*;
import java.net.URLEncoder;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.*;

import www.com.util.CoreProperties;

@Controller
public class FileController {

    @Autowired private FileService fileService;

    /** 단건 업로드 */
    @PostMapping("/api/com/file/uploadOne")
    @ResponseBody
    public Map<String, Object> uploadOne(@RequestParam(value="fileGrpId", required=false) Long fileGrpId,
                                         @RequestParam(value="descTxt", required=false) String descTxt,
                                         @RequestParam("file") MultipartFile file) throws Exception {
        Map<String, Object> result = fileService.upload(fileGrpId, null, descTxt, Collections.singletonList(file));
        result.put("msg", "성공");
        return result;
    }

    /** 다건 업로드 */
    @PostMapping("/api/com/file/uploadMulti")
    @ResponseBody
    public Map<String, Object> uploadMulti(@RequestParam(value="fileGrpId", required=false) Long fileGrpId,
                                           @RequestParam(value="descTxt", required=false) String descTxt,
                                           @RequestParam("files") List<MultipartFile> files) throws Exception {
        Map<String, Object> result = fileService.upload(fileGrpId, null, descTxt, files);
        result.put("msg", "성공");
        return result;
    }

    /** 그룹 파일 목록 */
    @PostMapping("/api/com/file/list")
    @ResponseBody
    public Map<String, Object> list(@RequestBody Map<String, Object> map) {
        long fileGrpId = Long.parseLong(String.valueOf(map.get("fileGrpId")));
        Map<String, Object> out = new HashMap<>();
        out.put("msg", "성공");
        out.put("result", fileService.listByGroup(fileGrpId));
        return out;
    }

    /** 다운로드 */
    @GetMapping("/api/com/file/download/{fileId}")
    public void download(@PathVariable("fileId") long fileId, HttpServletResponse resp) throws Exception {
        Map<String, Object> f = fileService.getFile(fileId);
        if (f == null) {
            resp.setStatus(404); return;
        }

        String base = CoreProperties.getProperty("file.upload.path");
        String path = base + File.separator + f.get("savePath") + File.separator + f.get("saveFileNm");
        File file = new File(path);
        if (!file.exists()) {
            resp.setStatus(404); return;
        }

        String orgName = String.valueOf(f.get("orgFileNm"));
        String mime = String.valueOf(f.get("contentType"));
        String inlineTypes = CoreProperties.getProperty("file.download.inline.types", "");
        boolean inline = inlineTypes.equals("*") || mime.matches(inlineTypes.replace("*", ".*"));

        resp.setContentType(mime != null ? mime : "application/octet-stream");
        String cd = (inline ? "inline" : "attachment") + "; filename=\"" + URLEncoder.encode(orgName, "UTF-8").replaceAll("\\+", "%20") + "\"";
        resp.setHeader("Content-Disposition", cd);
        resp.setHeader("Content-Length", String.valueOf(file.length()));

        try (InputStream in = new BufferedInputStream(Files.newInputStream(file.toPath()));
             OutputStream out = new BufferedOutputStream(resp.getOutputStream())) {
            byte[] buf = new byte[8192];
            int n;
            while ((n = in.read(buf)) > -1) out.write(buf, 0, n);
        }

        fileService.increaseDownload(fileId);
    }
    
    /* =====================[ ⬇️ 여기부터 추가 ]===================== */

    /**
     * (1) 에디터 전용 업로드:
     *     - 단일 파일만 받음
     *     - 저장 후 인라인 표시 가능한 URL(/api/com/file/inline/{fileId})을 돌려줌
     * 응답: { ok:true, result:{ url, fileId, fileGrpId } }
     */
    @PostMapping("/api/com/file/uploadImageForEditor")
    @ResponseBody
    public Map<String, Object> uploadImageForEditor(
            @RequestParam(value="fileGrpId", required=false) Long fileGrpId,
            @RequestParam("file") MultipartFile file) throws Exception {

        Map<String, Object> out = new HashMap<>();
        // 기존 서비스 재사용(단건 업로드)
        Map<String, Object> r = fileService.upload(fileGrpId, null, "editor-image", Collections.singletonList(file));

        boolean ok = Boolean.TRUE.equals(r.get("success"));
        if (!ok) {
            out.put("ok", false);
            out.put("message", String.valueOf(r.get("message")));
            return out;
        }

        Long newGrpId = ((Number) r.get("fileGrpId")).longValue();
        @SuppressWarnings("unchecked")
        List<Map<String, Object>> saved = (List<Map<String, Object>>) r.get("files");

        if (saved == null || saved.isEmpty()) {
            out.put("ok", false);
            out.put("message", "파일 저장 실패");
            return out;
        }

        Map<String, Object> first = saved.get(0);

        // ⚠️ insertFile 매퍼에 useGeneratedKeys=“true”, keyProperty=“fileId”가 설정돼 있어야 아래가 채워짐
        Number fidNum = (Number) first.get("fileId");
        if (fidNum == null) {
            out.put("ok", false);
            out.put("message", "fileId 누락(매퍼 keyProperty 설정 필요)");
            return out;
        }
        long fileId = fidNum.longValue();

        String url = "/api/com/file/inline/" + fileId;

        Map<String, Object> result = new HashMap<>();
        result.put("url", url);
        result.put("fileId", fileId);
        result.put("fileGrpId", newGrpId);

        out.put("ok", true);
        out.put("result", result);
        return out;
    }

    /**
     * (2) 인라인 스트리밍:
     *     - 에디터/목록에서 <img src="...">로 바로 렌더링 가능
     *     - Content-Disposition: inline + 캐시 헤더
     */
    @GetMapping("/api/com/file/inline/{fileId}")
    public void inline(@PathVariable("fileId") long fileId, HttpServletResponse resp) throws Exception {
        Map<String, Object> f = fileService.getFile(fileId);
        if (f == null) { resp.setStatus(404); return; }

        String base = CoreProperties.getProperty("file.upload.path");
        String rel  = String.valueOf(f.get("savePath"));
        String name = String.valueOf(f.get("saveFileNm"));
        String org  = String.valueOf(f.get("orgFileNm"));
        String ctype = String.valueOf(f.get("contentType"));
        if (ctype == null || "null".equalsIgnoreCase(ctype) || ctype.isEmpty()) {
            ctype = "application/octet-stream";
        }

        Path p = Paths.get(base + File.separator + rel + File.separator + name);
        File file = p.toFile();
        if (!file.exists()) { resp.setStatus(404); return; }

        resp.setHeader("Content-Type", ctype);
        resp.setHeader("Content-Disposition", "inline; filename=\"" + URLEncoder.encode(org, "UTF-8").replaceAll("\\+", "%20") + "\"");
        resp.setHeader(HttpHeaders.CACHE_CONTROL, "public, max-age=31536000"); // 1년 캐시
        resp.setHeader("Content-Length", String.valueOf(file.length()));

        try (InputStream in = new BufferedInputStream(Files.newInputStream(p));
             OutputStream out = new BufferedOutputStream(resp.getOutputStream())) {
            byte[] buf = new byte[8192];
            int n;
            while ((n = in.read(buf)) > -1) out.write(buf, 0, n);
        }
    }

    /* =====================[ ⬆️ 여기까지 추가 ]===================== */
}