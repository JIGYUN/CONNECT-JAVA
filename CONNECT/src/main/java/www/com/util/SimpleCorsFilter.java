package www.com.util;

import java.io.IOException;
import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;

import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * 아주 단순한 CORS 필터.
 * - 자격증명(쿠키) 허용: Access-Control-Allow-Credentials: true
 * - 허용 오리진은 init-param("cors.allowed.origins") 또는 환경변수 CORS_ALLOWED_ORIGINS 의 CSV로 설정
 *   예) http://localhost:3000,https://your-project.pages.dev,https://app.yourdomain.com
 * - 프리플라이트(OPTIONS) 요청은 여기서 200으로 종료
 * - 요청에 Access-Control-Request-Headers 가 있으면 그대로 echo 해서 허용
 */
public class SimpleCorsFilter implements Filter {

    private static final String INIT_PARAM_ORIGINS = "cors.allowed.origins";
    private static final String INIT_PARAM_METHODS = "cors.allowed.methods";
    private static final String INIT_PARAM_HEADERS = "cors.allowed.headers";

    private final Set<String> allowedOrigins = new HashSet<>();
    private final Set<String> allowedMethods = new HashSet<>(Arrays.asList(
            "GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"
    ));
    private final Set<String> defaultAllowedHeaders = new HashSet<>(Arrays.asList(
            "Origin", "Content-Type", "Accept", "Authorization", "X-Requested-With"
    ));

    private static String trimToNull(String s) {
        if (s == null) return null;
        String t = s.trim();
        return t.isEmpty() ? null : t;
    }

    private static void addCsv(Set<String> target, String csv) {
        if (csv == null) return;
        for (String p : csv.split(",")) {
            String v = p.trim();
            if (!v.isEmpty()) target.add(v);
        }
    }

    @Override
    public void init(FilterConfig cfg) throws ServletException {
        // 1) web.xml init-param 우선
        String originsCsv = cfg != null ? trimToNull(cfg.getInitParameter(INIT_PARAM_ORIGINS)) : null;
        String methodsCsv = cfg != null ? trimToNull(cfg.getInitParameter(INIT_PARAM_METHODS)) : null;
        String headersCsv = cfg != null ? trimToNull(cfg.getInitParameter(INIT_PARAM_HEADERS)) : null;

        // 2) 없으면 환경변수
        if (originsCsv == null) {
            originsCsv = trimToNull(System.getenv("CORS_ALLOWED_ORIGINS"));
        }
        // 3) 그래도 없으면 기본(로컬 개발)
        if (originsCsv == null) {
            originsCsv = "http://localhost:3000";
        }

        addCsv(allowedOrigins, originsCsv);
        if (methodsCsv != null) {
            allowedMethods.clear();
            addCsv(allowedMethods, methodsCsv);
        }
        if (headersCsv != null) {
            defaultAllowedHeaders.clear();
            addCsv(defaultAllowedHeaders, headersCsv);
        }
    }

    @Override
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest request  = (HttpServletRequest) req;
        HttpServletResponse response = (HttpServletResponse) res;

        String origin = request.getHeader("Origin");

        if (origin != null && allowedOrigins.contains(origin)) {
            // 자격증명 허용 시 '*' 금지 → 요청 Origin을 그대로 echo
            response.setHeader("Access-Control-Allow-Origin", origin);
            response.setHeader("Vary", "Origin");
            response.setHeader("Access-Control-Allow-Credentials", "true");

            // Methods
            response.setHeader("Access-Control-Allow-Methods", String.join(",", allowedMethods));

            // 요청 헤더 사전신고가 있으면 그대로 허용, 없으면 기본 헤더 세트 허용
            String reqHeaders = request.getHeader("Access-Control-Request-Headers");
            if (reqHeaders != null && !reqHeaders.trim().isEmpty()) {
                response.setHeader("Access-Control-Allow-Headers", reqHeaders);
            } else {
                response.setHeader("Access-Control-Allow-Headers", String.join(",", defaultAllowedHeaders));
            }

            // 캐시 시간
            response.setHeader("Access-Control-Max-Age", "3600");

            // 클라이언트에서 읽을 수 있게 노출할 헤더(필요 시 추가)
            response.setHeader("Access-Control-Expose-Headers", "Location,Link");
        }

        // Preflight 는 여기서 종료
        if ("OPTIONS".equalsIgnoreCase(request.getMethod())) {
            // Origin 이 없거나 미허용이면 일부 브라우저가 403으로 보기 쉽도록 403 반환도 가능.
            response.setStatus(allowedOrigins.contains(origin)
                    ? HttpServletResponse.SC_OK
                    : HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        chain.doFilter(req, res);
    }

    @Override
    public void destroy() { /* no-op */ }
}