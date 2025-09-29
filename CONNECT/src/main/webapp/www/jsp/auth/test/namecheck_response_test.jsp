<%@page import="jini.com.util.StringUtil"%>
<%
/**************************************************************************************************************************
* Program Name  : 본인확인 결과 수신 Sample JSP 
* File Name     : pcc_V3_result_seed.jsp
* Comment       : 
* History       :  
*
**************************************************************************************************************************/
%>
<%@page contentType="text/html;charset=utf-8"%>
<%@page import="java.util.*" %> 
<%	
	String uniqId = StringUtil.nullConvert(request.getParameter("uniqId"));
	String subUniqId = StringUtil.nullConvert(request.getParameter("subUniqId"));
	String name = StringUtil.nullConvert(request.getParameter("name"));
	String tel = StringUtil.nullConvert(request.getParameter("tel"));
	String retUrl = StringUtil.nullConvert(request.getParameter("retUrl"));

	session.setAttribute("uniqId", uniqId);
	session.setAttribute("subUniqId", subUniqId);
	session.setAttribute("userId", uniqId);
	session.setAttribute("name",name);
	session.setAttribute("tel",tel);
%>
<!Doctype html>
<html lang="ko">
    <head>
        <title>서울신용평가정보 본인확인서비스  테스트</title>
        <meta http-equiv="Content-Type" content="text/html; charset=utf-8">

		<script type="text/javascript">
			function end() {
				opener.location.href = "/com/user/login?loginType=n&retUrl="+encodeURIComponent('<%=retUrl%>');
				self.close();
			}
		</script>
    </head>
	<body onload="end();">
	</body>
</html>
