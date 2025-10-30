package www.com.util;

import javax.servlet.*;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.*;
import java.util.regex.Pattern;

/**
 * CORS 필터 (자격증명 허용 + 와일드카드/서픽스 지원)
 *
 * - web.xml 의 init-param `cors.allowed.origins` 에 CSV로 허용 오리진 지정
 *   예:
 *     http://localhost:3000,
 *     https://connect-react.pages.dev,
 *     https://*.connect-react.pages.dev
 *
 * - credentials 허용(Credentials=true) 시에는 "*" 금지.
 *   요청 Origin 그대로 Access-Control-Allow-Origin 으로 echo 한다.
 *
 * - OPTIONS 프리플라이트는 여기서 즉시 204/403 응답하고 체인 종료한다.
 *   실제 요청(GET/POST 등)은 체인 계속 내려간다.
 */
public class SimpleCorsFilter implements Filter {

    private static final String INIT_PARAM_ORIGINS = "cors.allowed.origins";
    private static final String INIT_PARAM_METHODS = "cors.allowed.methods";
    private static final String INIT_PARAM_HEADERS = "cors.allowed.headers";

    // 완전 일치 origin
    private final Set<String> allowedExact = new HashSet<>();
    // 와일드카드 (*.foo.bar) / 접미사 (.foo.bar) 대응용 정규식
    private final List<Pattern> allowedPatterns = new ArrayList<>();

    // 허용 메서드 세트
    private final Set<String> allowedMethods = new HashSet<>(
        Arrays.asList("GET","POST","PUT","PATCH","DELETE","OPTIONS")
    );

    // 기본 허용 헤더 세트
    private final Set<String> defaultAllowedHeaders = new HashSet<>(
        Arrays.asList("Origin","Content-Type","Accept","Authorization","X-Requested-With")
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
     * 와일드카드 토큰을 정규식으로 변환한다.
     *
     * 1) "https://*.connect-react.pages.dev"
     *    -> prefix="https://"
     *       suffix="connect-react.pages.dev"
     *    -> ^https://([^.]+\.)*connect-react\.pages\.dev$
     *
     * 2) ".connect-react.pages.dev"
     *    -> 어떤 스킴이든 허용
     *    -> ^[a-z]+://([^.]+\.)*connect-react\.pages\.dev$
     *
     * 3) 와일드카드가 전혀 없으면 null (정확히 일치 목록으로 처리)
     */
    private static Pattern toWildcardPattern(String token) {
        if (token == null) return null;
        String t = token.trim();
        if (t.isEmpty()) return null;

        // case A: 접두부에 "*.":   "https://*.connect-react.pages.dev"
        int starIdx = t.indexOf("*.");
        if (starIdx >= 0) {
            String prefix = t.substring(0, starIdx);          // "https://"
            String suffix = t.substring(starIdx + 2);         // "connect-react.pages.dev"
            String prefixEsc = Pattern.quote(prefix);         // https://  -> https://  (특수문자 이스케이프)
            String suffixEsc = Pattern.quote(suffix);         // connect-react.pages.dev -> connect\-react\.pages\.dev
            // ([^.]+\.)*  : aaa. / bbb.ccc. / (없을 수도)
            String regex = "^" + prefixEsc + "([^.]+\\.)*" + suffixEsc + "$";
            return Pattern.compile(regex);
        }

        // case B: 접두부 없이 ".domain" 형태만 준 경우
        //         ".connect-react.pages.dev"
        if (t.startsWith(".")) {
            String suffix = t.substring(1); // "connect-react.pages.dev"
            String suffixEsc = Pattern.quote(suffix);
            String regex = "^[a-z]+://([^.]+\\.)*" + suffixEsc + "$";
            return Pattern.compile(regex);
        }

        // 와일드카드 없으면 패턴 아님
        return null;
    }

    private void addAllowed(String token) {
        Pattern p = toWildcardPattern(token);
        if (p != null) {
            allowedPatterns.add(p);
        } else {
            // 와일드카드가 아니라면 완전일치로만 비교
            allowedExact.add(token);
        }
    }

    @Override
    public void init(FilterConfig cfg) {
        String originsCsv = (cfg != null) ? trimToNull(cfg.getInitParameter(INIT_PARAM_ORIGINS)) : null;
        String methodsCsv = (cfg != null) ? trimToNull(cfg.getInitParameter(INIT_PARAM_METHODS)) : null;
        String headersCsv = (cfg != null) ? trimToNull(cfg.getInitParameter(INIT_PARAM_HEADERS)) : null;

        // web.xml에 없으면 환경변수 CORS_ALLOWED_ORIGINS 보고
        // 그래도 없으면 localhost만 허용
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

        // 1) 정확히 일치
        if (allowedExact.contains(origin)) return true;

        // 2) 와일드카드/서픽스 패턴
        for (Pattern p : allowedPatterns) {
            if (p.matcher(origin).matches()) return true;
        }

        return false;
    }

    @Override
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
        throws IOException, ServletException {

        HttpServletRequest request  = (HttpServletRequest) req;
        HttpServletResponse response = (HttpServletResponse) res;

        String origin  = request.getHeader("Origin");
        boolean allow  = isAllowedOrigin(origin);

        if (allow) {
            // withCredentials=true 를 위한 세팅
            response.setHeader("Access-Control-Allow-Origin", origin);
            response.setHeader("Vary", "Origin");
            response.setHeader("Access-Control-Allow-Credentials", "true");

            // 허용 메서드
            response.setHeader(
                "Access-Control-Allow-Methods",
                String.join(",", allowedMethods)
            );

            // 클라이언트가 요구한 헤더 있으면 그대로 우선 허용
            String reqHeaders = request.getHeader("Access-Control-Request-Headers");
            if (reqHeaders != null && !reqHeaders.trim().isEmpty()) {
                response.setHeader("Access-Control-Allow-Headers", reqHeaders);
            } else {
                response.setHeader(
                    "Access-Control-Allow-Headers",
                    String.join(",", defaultAllowedHeaders)
                );
            }

            // preflight 캐시시간
            response.setHeader("Access-Control-Max-Age", "3600");

            // 실제 응답에서 브라우저가 읽을 수 있게 노출할 헤더
            response.setHeader("Access-Control-Expose-Headers", "Location,Link");
        }

        // 프리플라이트 요청인 경우 여기서 커트
        if ("OPTIONS".equalsIgnoreCase(request.getMethod())) {
            if (allow) {
                response.setStatus(HttpServletResponse.SC_NO_CONTENT); // 204
            } else {
                response.setStatus(HttpServletResponse.SC_FORBIDDEN);  // 403
            }
            return;
        }

        // 실제 요청은 계속 처리
        chain.doFilter(req, res);
    }

    @Override
    public void destroy() {
        // no-op
    }
}
