package www.com.util;

import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.IOException;
import java.net.URLEncoder;
import java.nio.file.*;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.UUID;

public class FileUploadUtil {

    // 1) 저장 루트 (시스템 프로퍼티 > 환경변수 > 기본값 순서)
    private static final String BASE_DIR =
            System.getProperty("upload.dir",
                    System.getenv().getOrDefault("UPLOAD_DIR",
                            "D:/upload")); // Linux면 "/data/upload" 등으로 교체 OK

    // 2) 이미지 업로드 전용(Toast UI용). 이미지가 아니면 예외
    public static String saveImageForEditor(MultipartFile file) throws IOException {
        if (file == null || file.isEmpty()) throw new IOException("empty file");
        String contentType = file.getContentType() == null ? "" : file.getContentType().toLowerCase();
        if (!contentType.startsWith("image/")) throw new IOException("not an image: " + contentType);

        String ext = getExt(file.getOriginalFilename());
        String saveName = UUID.randomUUID().toString().replace("-", "") + (ext.isEmpty() ? "" : "." + ext);
        String datePath = new SimpleDateFormat("yyyy/MM/dd").format(new Date()); // 예: 2025/09/04

        Path dir = Paths.get(BASE_DIR, "editor", datePath);
        Files.createDirectories(dir);

        Path saved = dir.resolve(saveName);
        Files.write(saved, file.getBytes());

        // Toast UI <img src="..."> 로 바로 보이도록 view URL 반환(Inline)
        String relPath = "editor/" + datePath + "/" + saveName;
        return "/api/common/file/image?path=" + urlEncode(relPath);
    }

    // 3) 범용 파일 저장(필요 시 사용)
    public static String save(MultipartFile file, String subDir) throws IOException {
        if (file == null || file.isEmpty()) throw new IOException("empty file");
        String ext = getExt(file.getOriginalFilename());
        String saveName = UUID.randomUUID().toString().replace("-", "") + (ext.isEmpty() ? "" : "." + ext);
        String datePath = new SimpleDateFormat("yyyy/MM/dd").format(new Date());

        Path dir = Paths.get(BASE_DIR, subDir == null ? "" : subDir, datePath);
        Files.createDirectories(dir);

        Path saved = dir.resolve(saveName);
        Files.write(saved, file.getBytes());

        String relPath = (subDir == null ? "" : subDir + "/") + datePath + "/" + saveName;
        return "/api/common/file/download?path=" + urlEncode(relPath);
    }

    // 내부 유틸
    private static String getExt(String name) {
        if (name == null) return "";
        int i = name.lastIndexOf('.');
        return (i >= 0) ? name.substring(i + 1) : "";
    }
    private static String urlEncode(String v) {
        try { return URLEncoder.encode(v, "UTF-8"); } catch (Exception e) { return v; }
    }

    /** 저장 루트 + 상대 경로로 실제 파일을 얻음 (경로 탐Traversal 방지) */
    public static File resolveFile(String relativePath) throws IOException {
        if (relativePath == null) throw new IOException("path is null");
        String safe = relativePath.replace("\\", "/");
        if (safe.contains("..")) throw new IOException("illegal path");

        Path p = Paths.get(BASE_DIR).resolve(safe).normalize();
        if (!p.startsWith(Paths.get(BASE_DIR))) throw new IOException("outside base dir");
        return p.toFile();
    }
    
    public static String saveImageReturnRelPath(MultipartFile file) throws IOException {
        if (file == null || file.isEmpty()) throw new IOException("empty file");
        String ext = getExt(file.getOriginalFilename());
        String saveName = UUID.randomUUID().toString().replace("-", "") + (ext.isEmpty()? "" : "."+ext);
        String datePath = new SimpleDateFormat("yyyy/MM/dd").format(new Date()); // 2025/09/04

        Path dir = Paths.get(BASE_DIR, "editor", datePath);
        Files.createDirectories(dir);
        Path saved = dir.resolve(saveName);
        Files.write(saved, file.getBytes());

        // <-- 컨트롤러에서 URL로 조립할 '상대 경로'만 반환
        return "editor/" + datePath + "/" + saveName;
    } 
}