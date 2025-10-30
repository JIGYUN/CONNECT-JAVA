package www.com.util;

import javax.servlet.*;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.*;
import java.util.regex.Pattern;

/**
 * CORS 필터 (자격증명 허용 + 와일드카드/서픽스 지원)
 *
 * - init-param 또는 ENV(CORS_ALLOWED_ORIGINS)에 CSV로 허용 오리진 지정
 *   예:
 *     http://localhost:3000,
 *     https://connect-react.pages.dev,
 *     https://*.connect-react.pages.dev
 *
 * - withCredentials=true일 때는 Access-Control-Allow-Origin 에 '*' 금지.
 *   요청 Origin을 그대로 echo 한다.
 *
 * - preflight(OPTIONS) 요청은 여기서 바로 204/403까지 응답하고 끝낸다.
 *   본 요청은 chain.doFilter()로 계속 내려간다.
 */
public class SimpleCorsFilter implements Filter {

    private static final String INIT_PARAM_ORIGINS = "cors.allowed.origins";
    private static final String INIT_PARAM_METHODS = "cors.allowed.methods";
    private static final String INIT_PARAM_HEADERS = "cors.allowed.headers";

    // 완전 일치 origin
    private final Set<String> allowedExact = new HashSet<>();
    // 와일드카드 (*.foo.bar) / suffix (.foo.bar) 대응용 정규식
    private final List<Pattern> allowedPatterns = new ArrayList<>();

    // 허용 HTTP 메서드
    private final Set<String> allowedMethods = new HashSet<>(
        Arrays.asList("GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS")
    );

    // 기본 허용 헤더
    private final Set<String> defaultAllowedHeaders = new HashSet<>(
        Arrays.asList("Origin", "Content-Type", "Accept", "Authorization", "X-Requested-With")
    );

    private static String trimToNull(String s) {
        if (s == null) return null;
        String t = s.trim();
        return t.isEmpty() ? null : t;
    }

    private static List<String> splitCsv(String csv) {
        if (csv == null) return Collections.emptyList();
        List<String> out = new ArrayList<>();
        for (String p : csv.split(",")) {
            String v = p.trim();
            if (!v.isEmpty()) out.add(v);
        }
        return out;
    }

    /**
     * "https://*.connect-react.pages.dev"
     *   -> ^https://([^.]+\.)*connect-react\.pages\.dev$
     *
     * "*.domain" 이 아닌 ".domain" (점으로 시작) 패턴도 지원:
     *   ".foo.bar" -> ^[a-z]+://([^.]+\.)*foo\.bar$
     */
    private static Pattern toWildcardPattern(String originToken) {
        // 1) "*.xxx" 스타일
        if (originToken.contains("*.")) {
            // 임시 치환 후 quote, 다시 wildcard 부분만 정규식으로 교체
            String replaced = originToken.replace("*.", "__WILDCARD__.");
            String esc = Pattern.quote(replaced);
            esc = esc.replace("__WILDCARD__", "([^.]+\\.)*");
            return Pattern.compile("^" + esc + "$");
        }

        // 2) ".xxx" 스타일(접미사만 준 경우)
        if (originToken.startsWith(".")) {
            // ".connect-react.pages.dev"
            String tail = originToken.substring(1); // "connect-react.pages.dev"
            // ^[a-z]+://([^.]+\.)*connect-react\.pages\.dev$
            return Pattern.compile(
                "^[a-z]+://([^.]+\\.)*" + Pattern.quote(tail) + "$"
            );
        }

        // 3) 기본적으로는 exact match만
        return null;
    }

    private void addAllowed(String token) {
        Pattern wildcard = toWildcardPattern(token);
        if (wildcard != null) {
            allowedPatterns.add(wildcard);
        } else {
            // 와일드카드/서픽스 아닌 경우 → 정확히 일치로만 허용
            allowedExact.add(token);
        }
    }

    @Override
    public void init(FilterConfig cfg) {
        String originsCsv = (cfg != null) ? trimToNull(cfg.getInitParameter(INIT_PARAM_ORIGINS)) : null;
        String methodsCsv = (cfg != null) ? trimToNull(cfg.getInitParameter(INIT_PARAM_METHODS)) : null;
        String headersCsv = (cfg != null) ? trimToNull(cfg.getInitParameter(INIT_PARAM_HEADERS)) : null;

        // web.xml에 없으면 환경변수(CORS_ALLOWED_ORIGINS) → 그래도 없으면 localhost만 허용
        if (originsCsv == null) originsCsv = trimToNull(System.getenv("CORS_ALLOWED_ORIGINS"));
        if (originsCsv == null) originsCsv = "http://localhost:3000";

        for (String t : splitCsv(originsCsv)) {
            addAllowed(t);
        }

        if (methodsCsv != null) {
            allowedMethods.clear();
            for (String t : splitCsv(methodsCsv)) {
                allowedMethods.add(t);
            }
        }

        if (headersCsv != null) {
            defaultAllowedHeaders.clear();
            for (String t : splitCsv(headersCsv)) {
                defaultAllowedHeaders.add(t);
            }
        }
    }

    private boolean isAllowedOrigin(String origin) {
        if (origin == null) return false;

        if (allowedExact.contains(origin)) return true;
        for (Pattern p : allowedPatterns) {
            if (p.matcher(origin).matches()) return true;
        }

        return false;
    }

    @Override
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
        throws IOException, ServletException {

        HttpServletRequest request = (HttpServletRequest) req;
        HttpServletResponse response = (HttpServletResponse) res;

        String origin = request.getHeader("Origin");
        boolean allowed = isAllowedOrigin(origin);

        if (allowed) {
            // 브라우저가 credentials 포함해서 호출할 수 있도록
            response.setHeader("Access-Control-Allow-Origin", origin);
            response.setHeader("Vary", "Origin");
            response.setHeader("Access-Control-Allow-Credentials", "true");

            // 허용 메서드
            response.setHeader(
                "Access-Control-Allow-Methods",
                String.join(",", allowedMethods)
            );

            // 허용 헤더(요청이 preflight에서 요구한 헤더 우선)
            String reqHeaders = request.getHeader("Access-Control-Request-Headers");
            if (reqHeaders != null && !reqHeaders.trim().isEmpty()) {
                response.setHeader("Access-Control-Allow-Headers", reqHeaders);
            } else {
                response.setHeader(
                    "Access-Control-Allow-Headers",
                    String.join(",", defaultAllowedHeaders)
                );
            }

            // preflight 캐시 시간(초)
            response.setHeader("Access-Control-Max-Age", "3600");

            // 실제 응답에서 노출 허용할 헤더
            response.setHeader("Access-Control-Expose-Headers", "Location,Link");
        }

        // 프리플라이트(OPTIONS)는 여기서 바로 종료
        if ("OPTIONS".equalsIgnoreCase(request.getMethod())) {
            response.setStatus(
                allowed
                    ? HttpServletResponse.SC_NO_CONTENT   // 204
                    : HttpServletResponse.SC_FORBIDDEN    // 403
            );
            return;
        }

        // 본 요청은 계속 진행
        chain.doFilter(req, res);
    }

    @Override
    public void destroy() {
        // 리소스 정리할 거 없음
    }
}
