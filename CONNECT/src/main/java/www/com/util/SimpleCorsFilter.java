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

public class SimpleCorsFilter implements Filter {

    // 개발용 허용 오리진 목록
    private static final Set<String> ALLOWED = new HashSet<String>(
        Arrays.asList("http://localhost:3000")
    );

    @Override
    public void init(FilterConfig filterConfig) throws ServletException { /* no-op */ }

    @Override
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest request = (HttpServletRequest) req;
        HttpServletResponse response = (HttpServletResponse) res;

        String origin = request.getHeader("Origin");
        if (origin != null && ALLOWED.contains(origin)) {
            // credentials 사용 시 '*' 금지 → 요청 Origin을 그대로 echo
            response.setHeader("Access-Control-Allow-Origin", origin);
            response.setHeader("Vary", "Origin");
            response.setHeader("Access-Control-Allow-Credentials", "true");
        }

        response.setHeader("Access-Control-Allow-Methods", "GET,POST,PUT,DELETE,OPTIONS");
        response.setHeader("Access-Control-Allow-Headers",
                "Origin,Content-Type,Accept,Authorization,X-Requested-With");
        response.setHeader("Access-Control-Max-Age", "3600");

        // 프리플라이트는 여기서 종료
        if ("OPTIONS".equalsIgnoreCase(request.getMethod())) {
            response.setStatus(HttpServletResponse.SC_OK);
            return;
        }

        chain.doFilter(req, res);
    }

    @Override
    public void destroy() { /* no-op */ }
}