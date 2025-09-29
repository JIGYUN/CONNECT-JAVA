<%
/**************************************************************************************************************************
* Program Name  : 본인확인 중간역활 결과페이지 
* File Name     : pcc_V3_popup_seed
* Comment       :  해당 페이지는 중간역활 페이지이기뿐 요청페이지에서 결과페이지를  pcc_V3_result_seed 로 설정해서 retInfo 를 받아도 상관없음.
* History       : 
**************************************************************************************************************************/
%>

<%@ page  contentType = "text/html;charset=ksc5601"%>
<%
	response.setHeader("Cache-Control","no-cache");     
	response.setHeader("Pragma","no-cache");
%>

<%
	String param = "";
	//반드시 get과 post 방식 둘 다 받을수있게 허용해놔야함.
	String enc_retInfo   = request.getParameter("retInfo").trim(); //  안받아지면 회원사가 폐쇠망일 가능성이있으면 네트워크 in,out쪽 등록필요. 개발문서참고

	param= "?retInfo="+enc_retInfo;
%>
<html>
<head>
<script language="JavaScript">
	function end() {
		window.location.href = './pcc_V3_result_seed_v2.jsp<%=param%>';
		//self.close();
	}
</script>
</head>
<body onload="javascript:end()">
</body>
</html>