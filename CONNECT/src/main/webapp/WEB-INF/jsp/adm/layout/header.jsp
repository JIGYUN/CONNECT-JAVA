<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>  <!-- ✅ 이것만이 맞습니다 -->
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %> 
<%@ taglib uri="http://www.springframework.org/security/tags" prefix="sec" %>
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

    <!-- CSS -->
    <link rel="stylesheet" href="<c:url value='/static/assets/css/bootstrap.min.css'/>">
    <link rel="stylesheet" href="<c:url value='/static/assets/css/front.css'/>">
    <link rel="stylesheet" href="<c:url value='/static/assets/css/bootstrap-datepicker.css'/>">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css">
    <link rel="stylesheet" href="<c:url value='/static/assets/css/admin.css'/>">

    <!-- JS -->
    <script src="<c:url value='/static/assets/js/jquery.min.js'/>"></script>
    <script src="<c:url value='/static/assets/js/bootstrap.min.js'/>"></script>
    <script src="<c:url value='/static/assets/js/common.js'/>"></script>
    <script src="<c:url value='/static/assets/js/paging.js'/>"></script>   
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
	<style>
	    .topbar{
		    height:56px;position:fixed;left:0;right:0;top:0;z-index:1100;
		    display:flex;align-items:center;justify-content:space-between;
		    padding:0 16px;border-bottom:1px solid #e5e7eb;background:#fff;
		    }
	    .brand{font-weight:800;letter-spacing:.08em}
	    .btn-login{padding:8px 12px;border-radius:10px;background:#2563eb;color:#fff;text-decoration:none}
	</style>
	
	<div class="topbar"> 
	    <div class="brand">CONNECT</div>
	    <div> 
            <sec:authorize ifNotGranted="EXTERNAL_AUTH">
                <a class="btn-login" href="/adm/mba/auth/login">로그인</a>
            </sec:authorize>  
	        <sec:authorize access="hasRole('EXTERNAL_AUTH')">
		        <a class="btn-login" href="/adm/mba/auth/logout">로그아웃</a>
	        </sec:authorize>
		    <%-- 로그인 상태일 땐 헤더 우측엔 아무 것도 두지 않음(좌하단이 계정 단일 진입점) --%>
	    </div>  
	</div>
</head>
<form>
	<input type="hidden" name="page" value="${map.page}" />
	<input type="hidden" name="pageSize" value="${map.pageSize}" />
</form>