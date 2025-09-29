package www.com.spring.web;

import javax.servlet.http.HttpServletRequest;

import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;

/**
 * 현재 Thread에 저장된 HttpServletRequest를 반환하는 class
 * webapplication의 web.xml에 아래와 같이 listener 등록이 되어있어야 사용가능하다.
 * 
 * <listener>
 *    	<listener-class>org.springframework.web.context.request.RequestContextListener</listener-class>
 * </listener>
 * 
 * 
 * @author cmj
 *
 */
public abstract class HttpServletRequestProvider {
	
	/**
	 * 현재 ThreadLocal에 저장된 HttpServletRequest를 가져온다.
	 * 
	 * @return ThreadLocal에 저장된 HttpServletRequest가 없으면 null을 반환한다.
	 */
	public static HttpServletRequest getHttpServletRequest(){
		ServletRequestAttributes requestAttributes = (ServletRequestAttributes)RequestContextHolder.getRequestAttributes();
		
		if(requestAttributes != null){
			return requestAttributes.getRequest();
		}
		
		return null;
	}
}
