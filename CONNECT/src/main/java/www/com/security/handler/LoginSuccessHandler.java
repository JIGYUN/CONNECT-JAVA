package www.com.security.handler;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import www.com.util.StringUtil;

import org.springframework.security.core.Authentication;
import org.springframework.security.web.authentication.SavedRequestAwareAuthenticationSuccessHandler;

public class LoginSuccessHandler extends SavedRequestAwareAuthenticationSuccessHandler
{
	@Override
	public void onAuthenticationSuccess(final HttpServletRequest request, final HttpServletResponse response, final Authentication authentication)
            throws IOException, ServletException {
		
		String retUrl = StringUtil.nullConvert(request.getParameter("retUrl"));
		
	    if (retUrl.length() > 0) {
	      response.sendRedirect(retUrl);
	      return;
	    }
	    
    	super.onAuthenticationSuccess(request, response, authentication);
    }
	
}

