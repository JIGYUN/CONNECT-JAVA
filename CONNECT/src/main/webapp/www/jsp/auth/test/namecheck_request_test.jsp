<%@page import="jini.com.util.StringUtil"%>
<%@page contentType="text/html;charset=utf-8"%>
<%@page import="java.util.*"%> 
<%@page import="java.util.*,java.text.SimpleDateFormat"%>
<%
/**************************************************************************************************************************
* Program Name  : 본인확인 요청 Sample JSP (Real)  
* File Name     : pcc_V3_sample_seed.jsp
* Comment       : 
* History       : 
*
**************************************************************************************************************************/
%>
<%
    response.setHeader("Pragma", "no-cache" );
    response.setDateHeader("Expires", 0);
    response.setHeader("Pragma", "no-store");
    response.setHeader("Cache-Control", "no-cache" );
    
    String retUrl = (String)request.getParameter("retUrl");
%>
<!Doctype html>
<html lang="ko">
<head>
<title>본인실명확인 서비스 Sample 화면</title>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<script src="https://code.jquery.com/jquery-1.11.3.js" type="text/javascript"></script>
<script>
$(document).ready(function(){
	$("#userSel").change(function(){
		var valueArr = $(this).find("option:selected").val().split("||");
		$("#uniqId").val(valueArr[0]);
		$("#subUniqId").val(valueArr[1]);
		$("#name").val($(this).find("option:selected").text());
		$("#tel").val(valueArr[2]);
	});
	$("#userSel").change();
});
</script>
</head>
<body>
<select id="userSel">
	
	<% for(int i = 0; i < 10; i++) { %>
		<option value="test_uniqId_<%=i %>||test_subUniqId_<%=i %>||010-<%=i %><%=i %><%=i %><%=i %>-<%=i %><%=i %><%=i %><%=i %>">테스트<%=i %></option>
	<% } %>
	
</select>
<form name="reqPCCForm" method="post" action = "namecheck_response_test.jsp">
    <input type="hidden" name="loginType" value="n"/>
   	<input type="text" id="uniqId" name="uniqId"/> 고유키<br/>
   	<input type="text" id="subUniqId" name="subUniqId"/> 서브고유키<br/>
   	<input type="text" id="name" name="name"/> 이름<br/>
   	<input type="text" id="tel" name="tel"/> 전화번호<br/>
    <input type="text" id="retUrl" name="retUrl" value="<%=StringUtil.nullConvert(retUrl) %>"/>return url<br/>
    <input type="submit" value="확인"/>
</form>
</body>
</html>