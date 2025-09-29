<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/www/jsp/inc/common_top.jsp" %>
<%
	Throwable ex = (Throwable)request.getAttribute("javax.servlet.error.exception");

	if(ex != null){
		ex.printStackTrace();
	}
%>
<!DOCTYPE HTML>
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="ko" lang="ko">
<head>
<title>ktr</title>
</head>
<body>

<script type="text/javascript">

<!--
	
	alert("<spring:message code="fail.common.msg"/>");

//-->

</script>	
</body>
</html>
