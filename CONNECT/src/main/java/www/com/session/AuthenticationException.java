package www.com.session;

import javax.servlet.http.HttpServletRequest;

import www.com.spring.web.HttpServletRequestProvider;
import www.com.util.StringUtil;

/**
 * 관리자 로그인이 안되었을때 Exception
 * 
 * @author cmj
 *
 */
public class AuthenticationException extends RuntimeException{

	private static final long serialVersionUID = -5207210073248439416L;
	
	/**
	 * 사용자(관리자)세션이 없을때 되돌아갈 URL정보 파라미터명
	 */
	public static final String AUTHENTICATION_FAIL_RETURN_URL_PARAMETER_NAME = "_rtnUrl";
	
	private String returnUrl;

	public String getReturnUrl() {
		HttpServletRequest httpServletRequest = HttpServletRequestProvider.getHttpServletRequest();
		if(StringUtil.nullConvert(httpServletRequest.getParameter(AUTHENTICATION_FAIL_RETURN_URL_PARAMETER_NAME)).length() > 0){
			return StringUtil.nullConvert(httpServletRequest.getParameter(AUTHENTICATION_FAIL_RETURN_URL_PARAMETER_NAME));
		}
		
		return StringUtil.nullConvert(returnUrl);
	}

	public void setReturnUrl(String returnUrl) {
		this.returnUrl = returnUrl;
	}
}
