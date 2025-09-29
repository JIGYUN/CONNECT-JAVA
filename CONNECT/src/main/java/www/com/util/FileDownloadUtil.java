package www.com.util;

import javax.servlet.http.HttpServletResponse;
import java.io.File;
import java.net.URLEncoder;
import java.nio.file.Files;

public class FileDownloadUtil {

    /** 파일을 스트리밍. inline=true 이면 브라우저 표시, false면 다운로드 */
    public static void write(HttpServletResponse resp, File file, String downloadName, boolean inline) throws Exception {
        if (file == null || !file.exists()) {
            resp.setStatus(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        String mime = Files.probeContentType(file.toPath());
        if (mime == null || mime.trim().isEmpty()) mime = "application/octet-stream";
        resp.setContentType(mime);

        // Content-Disposition
        String dispType = inline ? "inline" : "attachment";
        String enc = URLEncoder.encode(downloadName, "UTF-8").replaceAll("\\+", "%20");
        resp.setHeader("Content-Disposition", dispType + "; filename=\"" + enc + "\"");

        resp.setHeader("Content-Length", String.valueOf(file.length()));
        Files.copy(file.toPath(), resp.getOutputStream());
        resp.getOutputStream().flush();
    }
}