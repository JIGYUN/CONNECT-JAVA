package www.com.util;

import javax.servlet.*;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.*;
import java.util.regex.Pattern;

/**
 * CORS 필터(자격증명 허용 + 와일드카드/서픽스 지원)
 * - init-param 또는 ENV(CORS_ALLOWED_ORIGINS)에서 CSV로 허용 오리진 설정
 * - 항목 예: http://localhost:3000, https://connect-react.pages.dev, https://*.connect-react.pages.dev
 * - withCredentials=true 시 Access-Control-Allow-Origin 은 요청 Origin 그대로 echo(절대 '* '금지)
 */
public class SimpleCorsFilter implements Filter {

    private static final String INIT_PARAM_ORIGINS = "cors.allowed.origins";
    private static final String INIT_PARAM_METHODS = "cors.allowed.methods";
    private static final String INIT_PARAM_HEADERS = "cors.allowed.headers";

    private final Set<String> allowedExact = new HashSet<>();      // 완전 일치
    private final List<Pattern> allowedPatterns = new ArrayList<>(); // 와일드카드/서픽스 패턴
    private final Set<String> allowedMethods = new HashSet<>(Arrays.asList("GET","POST","PUT","PATCH","DELETE","OPTIONS"));
    private final Set<String> defaultAllowedHeaders = new HashSet<>(Arrays.asList("Origin","Content-Type","Accept","Authorization","X-Requested-With"));

    private static String trimToNull(String s){ if(s==null) return null; s=s.trim(); return s.isEmpty()?null:s; }

    private static List<String> splitCsv(String csv){
        if(csv==null) return Collections.emptyList();
        List<String> out=new ArrayList<>();
        for(String p: csv.split(",")){ String v=p.trim(); if(!v.isEmpty()) out.add(v); }
        return out;
    }

    private static Pattern toWildcardPattern(String origin){
        // 예: https://*.connect-react.pages.dev  ->  ^https://([^.]+\.)*connect-react\.pages\.dev$
        String esc = Pattern.quote(origin.replace("*.","__WILDCARD__."));
        esc = esc.replace("__WILDCARD__", "([^.]+\\.)*");
        return Pattern.compile("^" + esc + "$");
    }

    private void addAllowed(String token){
        if(token.contains("*.")){
            allowedPatterns.add(toWildcardPattern(token));
        }else if(token.startsWith(".")){ // .example.com 처럼 서픽스만 준 경우
            allowedPatterns.add(Pattern.compile("^[a-z]+://([^.]+\\.)*" + Pattern.quote(token.substring(1)) + "$"));
        }else{
            allowedExact.add(token);
        }
    }

    @Override public void init(FilterConfig cfg){
        String originsCsv = cfg!=null ? trimToNull(cfg.getInitParameter(INIT_PARAM_ORIGINS)) : null;
        String methodsCsv = cfg!=null ? trimToNull(cfg.getInitParameter(INIT_PARAM_METHODS)) : null;
        String headersCsv = cfg!=null ? trimToNull(cfg.getInitParameter(INIT_PARAM_HEADERS)) : null;

        if(originsCsv==null) originsCsv = trimToNull(System.getenv("CORS_ALLOWED_ORIGINS"));
        if(originsCsv==null) originsCsv = "http://localhost:3000";

        for(String t: splitCsv(originsCsv)) addAllowed(t);

        if(methodsCsv!=null){ allowedMethods.clear(); for(String t: splitCsv(methodsCsv)) allowedMethods.add(t); }
        if(headersCsv!=null){ defaultAllowedHeaders.clear(); for(String t: splitCsv(headersCsv)) defaultAllowedHeaders.add(t); }
    }

    private boolean isAllowedOrigin(String origin){
        if(origin==null) return false;
        if(allowedExact.contains(origin)) return true;
        for(Pattern p: allowedPatterns) if(p.matcher(origin).matches()) return true;
        return false;
    }

    @Override public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain) throws IOException, ServletException {
        HttpServletRequest request  = (HttpServletRequest) req;
        HttpServletResponse response = (HttpServletResponse) res;

        String origin = request.getHeader("Origin");
        boolean allowed = isAllowedOrigin(origin);

        if(allowed){
            response.setHeader("Access-Control-Allow-Origin", origin); // credentials=true이면 '*' 금지
            response.setHeader("Vary", "Origin");
            response.setHeader("Access-Control-Allow-Credentials", "true");
            response.setHeader("Access-Control-Allow-Methods", String.join(",", allowedMethods));

            String reqHeaders = request.getHeader("Access-Control-Request-Headers");
            response.setHeader("Access-Control-Allow-Headers",
                    (reqHeaders!=null && !reqHeaders.trim().isEmpty()) ? reqHeaders : String.join(",", defaultAllowedHeaders));

            response.setHeader("Access-Control-Max-Age", "3600");
            response.setHeader("Access-Control-Expose-Headers", "Location,Link");
        }

        if ("OPTIONS".equalsIgnoreCase(request.getMethod())) {
            response.setStatus(allowed ? HttpServletResponse.SC_NO_CONTENT : HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        chain.doFilter(req, res);
    }

    @Override public void destroy() {}
}