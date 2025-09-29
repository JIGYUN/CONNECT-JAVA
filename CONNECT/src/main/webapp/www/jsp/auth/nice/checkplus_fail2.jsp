<%@ page  contentType = "text/html;charset=ksc5601"%>
<%@ page import ="java.util.*,java.text.SimpleDateFormat"%>
<%@include file="/WEB-INF/jsp/www/com/inc/common_top.jsp" %>
<%@page import="java.net.URLEncoder"%>
<%@page import="java.util.Enumeration"%>
<%@page import="java.util.List"%>
<%@page import="java.util.Locale"%>
<%@page import="java.util.Iterator"%>
<%@page import="org.springframework.web.context.support.WebApplicationContextUtils"%>
<%@page import="org.springframework.context.ApplicationContext"%>
<%@page import="org.apache.commons.configuration.Configuration"%>
<%@page import="org.springframework.validation.Errors"%>
<%@page import="org.springframework.validation.ObjectError"%>
<%@page import="org.springframework.context.MessageSource"%>
<%@page import="org.springframework.web.servlet.support.RequestContext"%>
<%@page import="org.springframework.validation.BindingResult"%>

<%
        //날짜 생성
        Calendar today = Calendar.getInstance();
        SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMddHHmmss");
        String day = sdf.format(today.getTime());

        java.util.Random ran = new Random();
        //랜덤 문자 길이
        int numLength = 6;
        String randomStr = "";

        for (int i = 0; i < numLength; i++) {
            //0 ~ 9 랜덤 숫자 생성
            randomStr += ran.nextInt(10);
        }

		//reqNum은 최대 40byte 까지 사용 가능
        String reqNum = "123456789";   //sample 페이지와 result 페이지가  동일하지 않으면 결과페이지 복호화 시 에러
		String certDate=day;

		String type = StringUtil.nullConvert(request.getParameter("type"));
		
		if(!StringUtil.isEmpty(type)) {
			session.setAttribute("type", type);
		}
		
		String exVar = "0000000000000000"; // 복호화용 임시필드
		String certGb = "H"; // 인증구분 H: 휴대폰
		String addVar = "";
		
		String domain = request.getRequestURL().toString().replace(request.getRequestURI(),"");
		
		String retUrl = domain.replace("http", "32http") + "/www/jsp/auth/nice/pcc_V3_popup_seed_v2.jsp";
		
	    //01. 암호화 모듈 선언
		com.sci.v2.pccv2.secu.SciSecuManager seed  = new com.sci.v2.pccv2.secu.SciSecuManager();
		
		//02. 1차 암호화
		String encStr = "";
		String reqInfo      = id+"^"+srvNo+"^"+reqNum+"^"+certDate+"^"+certGb+"^"+addVar+"^"+exVar;  // 데이터 암호화

		seed.setInfoPublic(id, sciAuthKey);  //bizsiren.com > 회원사전용 로그인후 확인. 

		encStr               = seed.getEncPublic(reqInfo);
		
		//03. 위변조 검증 값 생성
		com.sci.v2.pccv2.secu.hmac.SciHmac hmac = new com.sci.v2.pccv2.secu.hmac.SciHmac();
		String hmacMsg  = seed.getEncReq(encStr,"HMAC");

		//03. 2차 암호화
		reqInfo  = seed.getEncPublic(encStr + "^" + hmacMsg + "^" + "0000000000000000");  //2차암호화

		//04. 회원사 ID 처리를 위한 암호화
		reqInfo = seed.EncPublic(reqInfo + "^" + id + "^"  + "00000000");

%>

<html>
    <head>
        <title>서울신용평가정보 본인실명확인서비스  테스트</title>
        <script language=javascript>
			function openPCCWindow(){ 
				//창을 오픈할때 크롬 및 익스플로어 양쪽 다 테스트 하시길 바랍니다.
				document.reqPCCForm.action = 'https://pcc.siren24.com/pcc_V3/jsp/pcc_V3_j10_v2.jsp';
				document.reqPCCForm.submit();
			}
		</script>
    </head>
    <body onload="return openPCCWindow();">
		<!-- 본인실명확인서비스 요청 form --------------------------->
		<form name="reqPCCForm" method="post">
			<input type="hidden" name="reqInfo"    value = "<%=reqInfo%>">
			<input type="hidden" name="retUrl"      value = "<%=retUrl%>">
			<input type="hidden" name="verSion"	value = "2">				 <!--모듈 버전정보-->
		</form>
	</body>
</html>