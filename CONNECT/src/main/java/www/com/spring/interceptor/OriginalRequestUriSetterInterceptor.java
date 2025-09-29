package www.com.spring.interceptor;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import org.springframework.web.servlet.handler.HandlerInterceptorAdapter;

/**
 * 브라우저에서 요청한 request uri 값 request attribute에 저장한다.
 * WAS 벤더에 따라 request.getAttribute("javax.servlet.include.request_uri"); 값이 제대로 안먹히는 경우가 있어 추가함.
 * 특히 Spring security를 사용하면 발생하는 경우가 많음. 
 * 
 * @author cmj
 *
 */
public class OriginalRequestUriSetterInterceptor extends HandlerInterceptorAdapter {

	/**
	 * 브라우저에서 요청한 request uri 값 request attribute 저장 키 
	 */
	public static String ORIGINAL_REQUEST_URI_ATTR_KEY = OriginalRequestUriSetterInterceptor.class.getName() + ".originalRequestURI";
	

	@Override
	public boolean preHandle(HttpServletRequest request,
			HttpServletResponse response, Object handler) throws Exception {
		
		if(request.getAttribute(ORIGINAL_REQUEST_URI_ATTR_KEY) == null){
			request.setAttribute(ORIGINAL_REQUEST_URI_ATTR_KEY, request.getRequestURI());
		}		
		
		return true; 
	}
}

