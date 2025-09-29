<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://www.springframework.org/security/tags" prefix="sec" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>  <!-- ✅ 이것만이 맞습니다 -->
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>   

<head>
    <title>CONNECT</title>  

    <!-- Meta -->
    <meta charset="utf-8">
    <meta http-equiv="pragma" content="no-cache">
    <meta name="google" content="notranslate">
    <meta name="description" content="ktr ADMIN" />
    <meta name="keywords" content="ktr">
    <meta name="author" content="ktr" />
    <%-- 내부망 http 테스트에서는 CSP 업그레이드 사용 금지
    <meta http-equiv="Content-Security-Policy" content="upgrade-insecure-requests">
    --%>

    <!-- Bootstrap core CSS -->
    <link rel="stylesheet" href="<c:url value='/static/assets/css/bootstrap.min.css'/>">
    <!-- Custom styles -->
    <link rel="stylesheet" href="<c:url value='/static/assets/css/front.css'/>">
    <link rel="stylesheet" href="<c:url value='/static/assets/css/bootstrap-datepicker.css'/>">

    <!-- JS (문서 하단 로딩 권장이나, 현 구조 유지) -->
    <script src="<c:url value='/static/assets/js/paging.js'/>"></script>  
    <script src="<c:url value='/static/assets/js/jquery.min.js'/>"></script>
    <script src="<c:url value='/static/assets/js/bootstrap.min.js'/>"></script>
    <script src="<c:url value='/static/assets/js/common.js'/>"></script>
    
    <!-- CDN은 https 고정 또는 스킴 상대 // 사용 -->
    <script src="https://code.jquery.com/ui/1.12.1/jquery-ui.js"></script>
    <script src="<c:url value='/static/assets/js/bootstrap-datepicker.js'/>"></script>

    <script> 
	$(document).ready(function() {
		$("#" + window.location.pathname.split('/')[3]).addClass("active"); 
	});

	function go(url) {
		const frm = document.getElementById("frm");
		frm.action = url;
		frm.submit();
	} 

</script>
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Noto+Sans+KR&display=swap');
        body{
          font-family: 'Noto Sans KR', sans-serif;
        }
    </style>
</head>
<form>  
	<input type="hidden" name="page" value="${map.page}" />
	<input type="hidden" name="pageSize" value="${map.pageSize}" />
</form>