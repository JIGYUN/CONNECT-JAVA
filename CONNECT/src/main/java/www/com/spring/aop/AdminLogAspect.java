package www.com.spring.aop;

import javax.servlet.http.HttpServletRequest;
import www.com.spring.web.HttpServletRequestProvider;
import org.aspectj.lang.ProceedingJoinPoint;
import org.aspectj.lang.annotation.Around;
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.annotation.Pointcut;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

/**
 * www관리자 로그 aop
 * 
 * @author cmj
 *
 */
@Aspect
@Component
public class AdminLogAspect {

	
	@Pointcut("@within(org.springframework.stereotype.Controller) && @annotation(org.springframework.web.bind.annotation.RequestMapping)"
			+ " && !execution(* lnb(..))"
			+ " && !execution(* www.com.web.CommonController.validator(..))"
			+ " && !execution(* www.com.web.CommonController.main(..))"
			+ " && !execution(* www.com.web.CommonController.blank(..))"
			+ " && !execution(* www.com.web.CommonController.loginForm(..))"
			+ " && !execution(* www.men.menu.web.MenuController.menu(..))"
			+ " && !execution(* www.com.node.web.CommonNodeController.getNode*(..))"
	)
	public void addAdminLog(){}
	
	@SuppressWarnings("all")
	@Around("addAdminLog()")
	public Object addAdminLog(ProceedingJoinPoint joinPoint) throws Throwable{
		
		Object returnObj = null;
		Throwable throwable = null;
		
		try {
			/* controller target logic 실행 */
		 	returnObj = joinPoint.proceed();
		} catch (Exception e1) { throwable = e1; }
		
		
		try {
			Object[] args = joinPoint.getArgs();
			
			HttpServletRequest request = HttpServletRequestProvider.getHttpServletRequest();
			
			// aop target class + method location 정보
			//String methodInvokeLocation = joinPoint.getSignature().toLongString();
			String methodInvokeLocation = joinPoint.getSignature().toShortString();

			
		} catch (Exception e) { e.printStackTrace(); }
		
		
		// controller logic 실행 시 에러가 있었으면 throw 한다.
		if(throwable != null){
			throw throwable;
		}
		
		return returnObj;
	}
}
