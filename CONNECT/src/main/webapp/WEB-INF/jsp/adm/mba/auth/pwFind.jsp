<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%> 
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
<%!
	/*
	* spring applicationContext를 가져온다.
	*/
	ApplicationContext getApplicationContext(HttpServletRequest request){
		return WebApplicationContextUtils.getRequiredWebApplicationContext(request.getSession().getServletContext());
	}


	/*
	* Configuration bean객체를 가져온다. (config.xml)
	*/
	Configuration getConfiguration(HttpServletRequest request){
		return getApplicationContext(request).getBean(Configuration.class);
	}
%>  
<%  
    NiceID.Check.CPClient niceCheck = new  NiceID.Check.CPClient();
    
    //String sSiteCode = "CC896";			// NICE로부터 부여받은 사이트 코드
    //String sSitePassword = "eiUdJONUcgdq";		// NICE로부터 부여받은 사이트 패스워드
    

	String sSiteCode			= getConfiguration(request).getString("nice.sitecode");                               // 본인실명확인 사이트코드
	String sSitePassword		= getConfiguration(request).getString("nice.password");							      // 본인실명확인 비밀번호
	 
    
    String sRequestNumber = "REQ0000000001";        	// 요청 번호, 이는 성공/실패후에 같은 값으로 되돌려주게 되므로 
                                                    	// 업체에서 적절하게 변경하여 쓰거나, 아래와 같이 생성한다.
    sRequestNumber = niceCheck.getRequestNO(sSiteCode);
  	session.setAttribute("REQ_SEQ" , sRequestNumber);	// 해킹등의 방지를 위하여 세션을 쓴다면, 세션에 요청번호를 넣는다.
  	
   	String sAuthType = "M";      	// 없으면 기본 선택화면, M(휴대폰), X(인증서공통), U(공동인증서), F(금융인증서), S(PASS인증서), C(신용카드)
	String customize 	= "";		//없으면 기본 웹페이지 / Mobile : 모바일페이지
	String domain = request.getRequestURL().toString().replace(request.getRequestURI(),"");
	
	String retUrl = domain + "/www/jsp/auth/nice/";
    // CheckPlus(본인인증) 처리 후, 결과 데이타를 리턴 받기위해 다음예제와 같이 http부터 입력합니다.
	//리턴url은 인증 전 인증페이지를 호출하기 전 url과 동일해야 합니다. ex) 인증 전 url : http://www.~ 리턴 url : http://www.~
    String sReturnUrl = retUrl + "/checkplus_success.jsp";      // 성공시 이동될 URL
    String sErrorUrl = retUrl + "/checkplus_fail.jsp";          // 실패시 이동될 URL
  
    // 입력될 plain 데이타를 만든다. 
    String sPlainData = "7:REQ_SEQ" + sRequestNumber.getBytes().length + ":" + sRequestNumber +
                        "8:SITECODE" + sSiteCode.getBytes().length + ":" + sSiteCode +
                        "9:AUTH_TYPE" + sAuthType.getBytes().length + ":" + sAuthType +
                        "7:RTN_URL" + sReturnUrl.getBytes().length + ":" + sReturnUrl +
                        "7:ERR_URL" + sErrorUrl.getBytes().length + ":" + sErrorUrl +  
                        "9:CUSTOMIZE" + customize.getBytes().length + ":" + customize;
    
    String sMessage = "";
    String sEncData = "";
    
    int iReturn = niceCheck.fnEncode(sSiteCode, sSitePassword, sPlainData);
    if( iReturn == 0 )
    {
        sEncData = niceCheck.getCipherData();
    }
    else if( iReturn == -1)
    {
        sMessage = "암호화 시스템 에러입니다.";
    }    
    else if( iReturn == -2)
    {
        sMessage = "암호화 처리오류입니다.";
    }    
    else if( iReturn == -3)
    {
        sMessage = "암호화 데이터 오류입니다.";
    }    
    else if( iReturn == -9)
    {
        sMessage = "입력 데이터 오류입니다.";
    }    
    else
    {
        sMessage = "알수 없는 에러 입니다. iReturn : " + iReturn;
    }
%>
<!DOCTYPE html> 

<html>   
    <body>  
	<!-- 본인인증 서비스 팝업을 호출하기 위해서는 다음과 같은 form이 필요합니다. -->
	<form name="form_chk" method="post">
		<input type="hidden" name="m" value="checkplusService">						<!-- 필수 데이타로, 누락하시면 안됩니다. -->
		<input type="hidden" name="EncodeData" value="<%= sEncData %>">		<!-- 위에서 업체정보를 암호화 한 데이타입니다. -->
	</form>
    <form name="sendForm" id="sendForm">
    	<input type="hidden" class="form-control" name="mberNo" id="mberNo" />
    	<input type="hidden" class="form-control" name="di" id="di" />
    	<input type="hidden" class="form-control" name="birthday" id="birthday" />
    	<input type="hidden" class="form-control" name="gender" id="gender" />
    	<input type="hidden" class="form-control" name="mberNm" id="mberNm" />
    	<input type="hidden" class="form-control" name="cryalTelno" id="cryalTelno" />
    </form>
    <div class="col-sm-5">
      <form name="pwFrm" id="pwFrm" method="post" action="/com/auth/login">
      <input type="hidden" name="loginType" value="n" >
      <h1 class="h3 mb-3 fw-normal">비밀번호 찾기</h1>
      <div class="row">
          <div class="col-md-12">
              <button class="btn btn-primary w-100 py-2" type="button" onClick="fnPopup()">본인인증</button>
          </div>  
	  </div>    
  </form>

  </div>
  
  <script>   
  
	window.name ="Parent_window";  
	
	function fnPopup(){
		window.open('', 'popupChk', 'width=500, height=550, top=100, left=100, fullscreen=no, menubar=no, status=no, toolbar=no, titlebar=yes, location=no, scrollbar=no');
		document.form_chk.action = "https://nice.checkplus.co.kr/CheckPlusSafeModel/checkplus.cb";
		document.form_chk.target = "popupChk";
		document.form_chk.submit();
	}
	
	
	function checkDi(){
		//alert("시작");  
		
		var formData = $("#sendForm").serializeObject();
		$.ajax({
	        url: "/api/auth/checkDi",
	        type: "post",
	        contentType: "application/json",
	        dataType :'json',
	 		data : JSON.stringify(formData),  
	        success: function (map){
	        	var result = map.result;  
	        	//alert("시작2");   
	        	console.log(map);
	        	console.log(result);   
	        	if (result != null) {   
	        		$("#mberNo").val(result.mberNo);
		        	goPwFind();   
	        	} else {
	        		alert("가입된 아이디가 없습니다.");  
	        	}
	        	
	        },
	        error: function(request, status, error){
	            
	        }
		});  
	}
 
	
	function goPwFind(){
        $("#sendForm").attr("method","post");
        $("#sendForm").attr("action", "/mba/auth/pwFindProc");   
        $("#sendForm").submit();
	}
   

    $(document).ready(function(){
        $("input[name=password]").keydown(function (key) {
            if(key.keyCode == 13){//키가 13이면 실행 (엔터는 13)
                goLogin();
            }
        });
    });
  </script>

  </body>
</html>