package www.api.com.file.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;
import www.com.util.CommonDao;
import www.com.util.CoreProperties;

import java.io.File;
import java.time.LocalDate;
import java.util.*;

@Service
public class FileService {

    private static final String NS = "www.api.com.file.File";

    @Autowired
    private CommonDao dao;

    /** 안전한 베이스 경로 반환 (프로퍼티 없으면 tmp로 폴백) */
    private String basePath() {
        String v = CoreProperties.getProperty("file.upload.path");
        if (v == null || v.trim().isEmpty()) {
            String tmp = System.getProperty("java.io.tmpdir");
            System.out.println("[FILE] file.upload.path 미설정 → tmp 사용: " + tmp);
            return tmp;
        }
        return v;
    }

    /** 저장 경로: yyyy/MM/dd */
    private String todayPath() {
        LocalDate d = LocalDate.now();
        return String.format("%04d/%02d/%02d", d.getYear(), d.getMonthValue(), d.getDayOfMonth());
    }

    private static String ext(String name) {
        int i = (name == null) ? -1 : name.lastIndexOf('.');
        return i > -1 ? name.substring(i + 1).toLowerCase(Locale.ROOT) : "";
    }

    /** 파일그룹 생성 (없으면) */
    @Transactional
    public long ensureFileGroup(Long fileGrpId, Long createdBy, String desc) {
        if (fileGrpId != null && fileGrpId > 0) return fileGrpId;
        try {
            Map<String, Object> p = new HashMap<>();
            p.put("descTxt", desc);
            p.put("createdBy", createdBy);
            dao.insert(NS + ".insertFileGroup", p); // keyProperty로 fileGrpId 세팅됨
            return ((Number) p.get("fileGrpId")).longValue();
        } catch (Exception e) {
            System.err.println("[FILE] 파일그룹 생성 실패: " + e.getMessage());
            return -1L;
        }
    }

    /**
     * 단건/다건 업로드 공용 (예외를 상위로 던지지 않음)
     * @return { success, message, fileGrpId, files(성공목록), failed(실패파일명목록) }
     */
    @Transactional
    public Map<String, Object> upload(Long fileGrpId, Long createdBy, String desc, List<MultipartFile> files) {
        Map<String, Object> result = new HashMap<>();
        List<Map<String, Object>> saved = new ArrayList<>();
        List<String> failed = new ArrayList<>();

        if (files == null || files.isEmpty()) {
            result.put("success", false);
            result.put("message", "업로드할 파일이 없습니다.");
            result.put("fileGrpId", fileGrpId);
            result.put("files", saved);
            result.put("failed", failed);
            return result;
        }

        long grpId = ensureFileGroup(fileGrpId, createdBy, desc);
        if (grpId <= 0) {
            result.put("success", false);
            result.put("message", "파일 그룹 생성에 실패했습니다.");
            result.put("fileGrpId", fileGrpId);
            result.put("files", saved);
            result.put("failed", failed);
            return result;
        }

        String relPath = todayPath();
        File dir = new File(basePath(), relPath);
        if (!dir.exists()) {
            try {
                boolean ok = dir.mkdirs();
                if (!ok) {
                    result.put("success", false);
                    result.put("message", "업로드 디렉터리를 생성할 수 없습니다: " + dir.getAbsolutePath());
                    result.put("fileGrpId", grpId);
                    result.put("files", saved);
                    result.put("failed", failed);
                    return result;
                }
            } catch (Exception e) {
                System.err.println("[FILE] 디렉터리 생성 실패: " + e.getMessage());
                result.put("success", false);
                result.put("message", "업로드 디렉터리 생성 중 오류가 발생했습니다.");
                result.put("fileGrpId", grpId);
                result.put("files", saved);
                result.put("failed", failed);
                return result;
            }
        }

        System.out.println("[FILE] basePath = " + basePath() + ", relPath = " + relPath);

        long totalSize = 0L;
        int cnt = 0;

        for (MultipartFile mf : files) {
            if (mf == null || mf.isEmpty()) continue;

            String orgName = mf.getOriginalFilename();
            String e = ext(orgName);
            String saveName = UUID.randomUUID().toString().replace("-", "");
            String contentType = Optional.ofNullable(mf.getContentType()).orElse("application/octet-stream");
            long size = 0L;
            String finalFileName = saveName + (e.isEmpty() ? "" : "." + e);

            // 1) 실제 파일 저장
            File dest = new File(dir, finalFileName);
            try {
                mf.transferTo(dest);
                size = dest.length(); // 저장 후 실제 사이즈
            } catch (Exception io) {
                System.err.println("[FILE] 저장 실패 (" + orgName + "): " + io.getMessage());
                failed.add(orgName != null ? orgName : "(no-name)");
                // 실패 파일이 남아있으면 정리 시도
                try { if (dest.exists()) dest.delete(); } catch (Exception ignore) {}
                continue; // 다음 파일
            }

            // 2) DB 기록
            try {
                Map<String, Object> rec = new HashMap<>();
                rec.put("fileGrpId", grpId);
                rec.put("orgFileNm", orgName);
                rec.put("saveFileNm", finalFileName);
                rec.put("savePath", relPath);
                rec.put("extNm", e);
                rec.put("contentType", contentType);
                rec.put("fileSize", size);
                rec.put("createdBy", createdBy);

                dao.insert(NS + ".insertFile", rec);

                saved.add(rec);
                totalSize += size;
                cnt++;
            } catch (Exception dbEx) {
                System.err.println("[FILE] DB 기록 실패 (" + orgName + "): " + dbEx.getMessage());
                failed.add(orgName != null ? orgName : "(no-name)");
                // 디스크에 저장된 파일 롤백 시도
                try { File f = new File(dir, finalFileName); if (f.exists()) f.delete(); } catch (Exception ignore) {}
            }
        }

        // 3) 그룹 집계(성공분만)
        if (cnt > 0) {
            try {
                Map<String, Object> agg = new HashMap<>();
                agg.put("fileGrpId", grpId);
                agg.put("plusCnt", cnt);
                agg.put("plusSize", totalSize);
                dao.update(NS + ".updateFileGroupAgg", agg);
            } catch (Exception ex) {
                System.err.println("[FILE] 그룹 집계 업데이트 실패: " + ex.getMessage());
                // 집계 실패는 업로드 자체를 실패로 돌리진 않음
            }
        }

        // 4) 결과 구성
        boolean ok = !saved.isEmpty();
        String msg;
        if (ok && failed.isEmpty()) {
            msg = "업로드 성공 (" + cnt + "건)";
        } else if (ok) {
            msg = "일부 업로드 성공 (" + cnt + "건), 실패 " + failed.size() + "건";
        } else {
            msg = "업로드 실패";
        }

        result.put("success", ok);
        result.put("message", msg);
        result.put("fileGrpId", grpId);
        result.put("files", saved);
        result.put("failed", failed);
        return result;
    }

    public List<Map<String, Object>> listByGroup(long fileGrpId) {
        try {
            return dao.list(NS + ".selectFilesByGroup", Collections.singletonMap("fileGrpId", fileGrpId));
        } catch (Exception e) {
            System.err.println("[FILE] 목록 조회 실패: " + e.getMessage());
            return Collections.emptyList();
        }
    }

    public Map<String, Object> getFile(long fileId) {
        try {
            return dao.selectOne(NS + ".selectFileById", Collections.singletonMap("fileId", fileId));
        } catch (Exception e) {
            System.err.println("[FILE] 단건 조회 실패: " + e.getMessage());
            return null;
        }
    }

    @Transactional
    public void increaseDownload(long fileId) {
        try {
            dao.update(NS + ".increaseDownload", Collections.singletonMap("fileId", fileId));
        } catch (Exception e) {
            System.err.println("[FILE] 다운로드 카운트 증가 실패(fileId=" + fileId + "): " + e.getMessage());
        }
    }
}