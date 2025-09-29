package www.api.com.file.web;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import www.api.com.file.service.FileService;

import javax.servlet.http.HttpServletResponse;
import java.io.*;
import java.net.URLEncoder;
import java.nio.file.Files;
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
}