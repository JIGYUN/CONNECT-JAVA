package www.api.log.service;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.util.HashMap;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import www.com.util.CommonDao;

@Service
public class VisitMainService {

    private final String namespace = "www.api.log.VisitMain";

    @Autowired
    private CommonDao dao;

    public boolean recordMainVisit(HttpServletRequest request, String siteCd) {
        String ip = getClientIp(request);
        if (ip == null || ip.trim().isEmpty()) {
            ip = "0.0.0.0";
        }

        String ipHash = sha256Hex(ip);
        String ipMask = maskIp(ip);
        String ua = safeTrunc(request.getHeader("User-Agent"), 500);

        Map<String, Object> param = new HashMap<String, Object>();
        param.put("siteCd", safeTrunc(siteCd, 20));
        param.put("ipHash", ipHash);
        param.put("ipMask", safeTrunc(ipMask, 80));
        param.put("userAgent", ua);

        int affected = dao.insert(namespace + ".insertVisitMainIgnore", param);
        return affected > 0;
    }

    private static String getClientIp(HttpServletRequest request) {
        String ip;

        ip = headerFirstIp(request.getHeader("CF-Connecting-IP"));
        if (ip != null) return ip;

        ip = headerFirstIp(request.getHeader("X-Real-IP"));
        if (ip != null) return ip;

        ip = headerFirstIp(request.getHeader("X-Forwarded-For"));
        if (ip != null) return ip;

        return request.getRemoteAddr();
    }

    private static String headerFirstIp(String headerVal) {
        if (headerVal == null) return null;
        String v = headerVal.trim();
        if (v.isEmpty()) return null;
        int comma = v.indexOf(',');
        if (comma >= 0) v = v.substring(0, comma).trim();
        if (v.isEmpty()) return null;
        return v;
    }

    private static String maskIp(String ip) {
        if (ip == null) return null;

        // IPv4: a.b.c.d -> a.b.c.0/24
        String[] parts = ip.split("\\.");
        if (parts.length == 4) {
            return parts[0] + "." + parts[1] + "." + parts[2] + ".0/24";
        }

        // IPv6: 앞 4블록만 남기고 ::/64 느낌으로
        String norm = ip;
        int pct = norm.indexOf('%'); // fe80::...%12 같은 zone 제거
        if (pct >= 0) norm = norm.substring(0, pct);

        String[] blocks = norm.split(":");
        StringBuilder sb = new StringBuilder();
        int cnt = 0;
        for (int i = 0; i < blocks.length && cnt < 4; i++) {
            String b = blocks[i];
            if (b == null) continue;
            if (b.isEmpty()) continue;
            if (sb.length() > 0) sb.append(":");
            sb.append(b);
            cnt++;
        }
        if (sb.length() == 0) return "::/64";
        sb.append("::/64");
        return sb.toString();
    }

    private static String sha256Hex(String s) {
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] dig = md.digest(s.getBytes(StandardCharsets.UTF_8));
            StringBuilder sb = new StringBuilder(dig.length * 2);
            for (int i = 0; i < dig.length; i++) {
                int v = dig[i] & 0xff;
                if (v < 16) sb.append('0');
                sb.append(Integer.toHexString(v));
            }
            return sb.toString();
        } catch (Exception e) {
            return "0000000000000000000000000000000000000000000000000000000000000000";
        }
    }

    private static String safeTrunc(String s, int maxLen) {
        if (s == null) return null;
        if (s.length() <= maxLen) return s;
        return s.substring(0, maxLen);
    }
}
