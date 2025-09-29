package www.com.spring.interceptor;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;
import org.springframework.web.multipart.MultipartHttpServletRequest;
import org.springframework.web.servlet.handler.HandlerInterceptorAdapter;

/**
 * MultipartHttpServletRequest를 RequestContextHolder에서도 사용할 수 있게하는 interceptor
 * RequestContextHolder에 세팅하여도 Multipart파일은 사용할 수 없으며 parameter값만 받아올 수 있다.
 * 
 * @author cmj
 *
 */
public class MultipartRequestContextHolderInterceptor extends HandlerInterceptorAdapter {
	
	private static final Logger logger = LoggerFactory.getLogger(MultipartRequestContextHolderInterceptor.class); 

	@Override
	public boolean preHandle(HttpServletRequest request,
			HttpServletResponse response, Object handler) throws Exception {
		
		try {
			//request가 MultipartHttpServletRequest면 RequestContextHolder에 세팅해준다.
			if(request instanceof MultipartHttpServletRequest){
				RequestContextHolder.setRequestAttributes(new ServletRequestAttributes(request));
			}
		} catch (Exception e) {
			//ignore
			logger.error(e.getMessage(), e);
		}
		
		return true; 
	}
}

