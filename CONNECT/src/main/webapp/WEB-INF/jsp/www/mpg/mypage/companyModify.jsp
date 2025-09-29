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
<script language='javascript'>
	window.name ="Parent_window";  
	
	function fnPopup(){
		window.open('', 'popupChk', 'width=500, height=550, top=100, left=100, fullscreen=no, menubar=no, status=no, toolbar=no, titlebar=yes, location=no, scrollbar=no');
		document.form_chk.action = "https://nice.checkplus.co.kr/CheckPlusSafeModel/checkplus.cb";
		document.form_chk.target = "popupChk";
		document.form_chk.submit();
	}
</script>
<!DOCTYPE html>
<html>
    <body>
    <h1 class="h3 mb-3 fw-normal">회원가입</h1> 
	<!-- 본인인증 서비스 팝업을 호출하기 위해서는 다음과 같은 form이 필요합니다. -->
	<form name="form_chk" method="post">
		<input type="hidden" name="m" value="checkplusService">						<!-- 필수 데이타로, 누락하시면 안됩니다. -->
		<input type="hidden" name="EncodeData" value="<%= sEncData %>">		<!-- 위에서 업체정보를 암호화 한 데이타입니다. -->
	</form> 
    <form id="send-form">
    	<input type="hidden" class="form-control" id="di" name="di" />
    	<input type="hidden" class="form-control" id="birthday" name="birthday"/>
    	<input type="hidden" class="form-control" id="gender" name="gender" />
		<div class="form-row">
		    <div class="form-group col-md-6">
		        <label for="inputEmail4">이름</label>
		        <input type="email" class="form-control" id="mberNm" name="mberNm" placeholder="이름" readonly="readonly" value="정지균">
		    </div>
		    <div class="form-group col-md-6">
		        <label for="inputEmail4">휴대전화번호</label>
		        <input type="text" class="form-control" id="cryalTelno" name="cryalTelno" placeholder="휴대전화번호" readonly="readonly" value="01071120423">
		        <button type="button" class="btn btn-primary" onClick="fnPopup()">본인인증</button>
		    </div>
		</div>
		
		<div class="form-row">
		    <div class="form-group col-md-6">
		        <label for="inputPassword4">아이디</label>
		        <input type="text" class="form-control" id="id" name="id" placeholder="아이디">
		        <button type="button" class="btn btn-primary" onClick="duplicateId()">아이디 중복체크</button>
		    </div>  
		    <div class="form-group col-md-6">
		        <label for="inputPassword4">이메일</label>
		        <input type="text" class="form-control" id="email" name="email" placeholder="이메일">
		    </div>
		</div>
		
		<div class="form-row">
		    <div class="form-group col-md-6">
		        <label for="inputEmail4">비밀번호</label>
		        <input type="password" class="form-control" id="password" name="password" placeholder="비밀번호">
		    </div>
		    <div class="form-group col-md-6">
		        <label for="inputPassword4">비밀번호 확인</label>
		        <input type="password" class="form-control" id="passwordConfirm" name="passwordConfirm" placeholder="비밀번호 확인">
		    </div>
		</div>
		</br> 
		<h1 class="h3 mb-3 fw-normal">업체정보</h1>

		<div class="form-row"> 
		    <div class="form-group col-md-6">
		        <label for="inputEmail4">기업명</label>
		        <input type="text" class="form-control" id="cstmrNm" name="cstmrNm" placeholder="업체명">
		    </div>
		    <div class="form-group col-md-6">
		        <label for="inputPassword4">사업자 등록번호</label>
		        <input type="text" class="form-control" id="bizrno" name="bizrno" placeholder="사업자등록번호">
		    </div>
		</div>
		
		<div class="form-row">
		    <div class="form-group col-md-6">
		        <label for="inputEmail4">대표자</label>
		        <input type="text" class="form-control" id="rprsntvNm" name="rprsntvNm" placeholder="대표자명">
		    </div>
		    <div class="form-group col-md-6">
		        <label for="inputEmail4">연락처(대표번호)</label>
		        <input type="text" class="form-control" id="comTelno" name="comTelno" placeholder="대표 전화번호">
		    </div>
		</div>
		
		<div class="form-row">
		    <div class="form-group col-md-6">
		        <label for="inputPassword4">대표 팩스번호</label>
		        <input type="text" class="form-control" id="comFaxno" name="comFaxno" placeholder="대표 팩스번호">
		    </div>
		    
		    <div class="form-group col-md-6">
		        <label for="inputEmail4">사업장주소</label>
		        <input type="text" class="form-control" id="detailAdres" name="detailAdres" placeholder="주소" style="margin-bottom:8px;">
		        <input type="text" class="form-control" id="deptName8" name="deptName8" placeholder="상세주소" style="margin-bottom:8px;">
		        <input type="text" class="form-control" id="deptName9" name="deptName9" placeholder="상세주소2">
		    </div>
		</div>
		
		<h1 class="h3 mb-3 fw-normal">담당자 정보</h1>

		<div class="form-row"> 
		    <div class="form-group col-md-6">
		        <label for="inputEmail4">연락처(사무실)</label>
		        <input type="text" class="form-control" id="managerTelno" name="managerTelno" placeholder="연락처(사무실)">
		    </div>
		    <div class="form-group col-md-6">
		        <label for="inputPassword4">팩스번호</label>
		        <input type="text" class="form-control" id="managerFaxno" name="managerFaxno" placeholder="팩스번호">
		    </div>
		</div>
		
		<div class="form-row">
		    <div class="form-group col-md-6">
		        <label for="inputEmail4">부서</label>
		        <input type="text" class="form-control" id="deptName" name="deptName" placeholder="부서">
		    </div>
		    <div class="form-group col-md-6">
		        <label for="inputPassword4">직급</label>
		        <input type="text" class="form-control" id="dursName" name="dursName" placeholder="직급">
		    </div>
		    <div class="form-group col-md-6">
		        <label for="inputPassword4">직위</label>
		        <input type="text" class="form-control" id="positionName" name="positionName" placeholder="직위">
		    </div>
		</div>
		
		<div class="form-row">
		    <div class="form-group col-md-6">
		        <label for="inputPassword4">사업자등록증</label>
		        <input type="text" class="form-control" id="comFaxno33" name="comFaxno33" placeholder="사업자등록증을 첨부해주세요.">
		        <button type="button" class="btn btn-primary">첨부하기</button>
		    </div>
		    
		    <div class="form-group col-md-6">
		        <label for="inputPassword4">재직증명서</label>
		        <input type="text" class="form-control" id="comFaxno44" name="comFaxno44" placeholder="재직증명서를 첨부해주세요.">
		        <button type="button" class="btn btn-primary" >첨부하기</button>
		    </div>
		</div>

		<button type="button" class="btn btn-primary" onClick="insert()">회원가입</button>
		<input type="hidden" id="mberSeq" name="mberSeq" value = 1> 
		<input type="hidden" id="mberSeCd" name="mberSeCd" value = 'A'>
		<input type="hidden" id="registerId" name="registerId" value = 'A'>
		<input type="hidden" id="changerId" name="changerId" value = 'A'>
		<input type="hidden" id="sportHdqrDeptCd" name="sportHdqrDeptCd" value = 'A'>
		<input type="hidden" id="cstmrSttusCd" name="cstmrSttusCd" value = 'A'>
		<input type="hidden" id="dmstcOvseaSeCd" name="dmstcOvseaSeCd" value = 'A'>
		<input type="hidden" id="cstmrSeCd" name="cstmrSeCd" value = 'A'> 
		<input type="hidden" id="zrpctaxBsnmYn" name="zrpctaxBsnmYn" value = 'A'>   
		<input type="hidden" id="nationCd" name="nationCd" value = 'KO'>     
	</form>
    <script>
  	
	function insert() {
		
		if($("#id").val() == "") {
			alert("아이디를 입력해주세요.");
			$("#id").focus(); 
			return;
		}
				
		if(!checkId($("#id").val())){
			alert("6-12자의 영문, 숫자, 기호(- _ )만 사용 가능합니다.");
			$("#id").focus();
			return;
		}  
		
		if($("#email").val() == "") {  
			alert("이메일을 입력해주세요.");  
			$("#email").focus();
			return;
		}
		
		if($("#password").val() == "") {
			alert("비밀번호를 입력해주세요.");
			$("#password").focus();
			return;
		}
		
		if(!checkPw($("#password").val())){
			alert("8자리 이상, 영문 대/소문자, 특수문자, 숫자를 조합해서 입력해주세요.");
			$("#password").focus();
			return;
		}  
		
		if($("#passwordConfirm").val() == "") {
			alert("비밀번호 확인을 입력해주세요.");
			$("#passwordConfirm").focus();
			return;
		}

		if(!($("#password").val() == $("#passwordConfirm").val())) {
			alert("비밀번호가 일지하지 않습니다.");
			$("#passwordConfirm").focus();
			return;  
		}
		
		if($("#job").val() == "") {
			alert("직업을 선택하세요.");
			$("#job").focus();
			return;
		}
		
		if($("#interestField").val() == "") {
			alert("관심분야를 선택해주세요."); 
			$("#interestField").focus();
			return;
		}
		
		if($("#detailAdres").val() == "") {
			alert("주소를 입력해주세요."); 
			$("#detailAdres").focus();
			return;
		}
		
 		var formData = $("#send-form").serializeObject();
 		console.log(formData);  
 		$.ajax({
	        url: "/api/auth/insertCompanyMember", 
	        type: "post",
	        contentType: "application/json;charset=utf-8", 
	        dataType :'json',
	 		data : JSON.stringify(formData), 
	        success: function (map){
	        	console.log("map >> " + map)
                alert("등록이 완료되었습니다.");
	        },
	        error: function(request, status, error){
	            
	        }
	   });
	}
	
	function duplicateId() {
		if($("#id").val() == ""){
			alert("아이디를 입력해주세요.");
			$("#id").focus();
			return;
		}  
		
		var formData = {};
		formData.id = $("#id").val();

 		$.ajax({
	        url: "/api/auth/duplicateId",
	        type: "post",
	        contentType: "application/json;charset=utf-8", 
	        dataType :'json',
	 		data : JSON.stringify(formData), 
	        success: function (map){
	        	console.log("map >> " + result)
				if (map.result.cnt > 0) {
					alert("이미 사용중인 아이디 입니다.");
					return;
				} else {
					alert("사용가능한 아이디 입니다.");
					return;
				}
	        },
	        error: function(request, status, error){
	            
	        }
	   });
	}
	
	function identify() {
		
	}

	$(document).ready(function(){
        $("input[name=name]").keydown(function (key) {
            if(key.keyCode == 13){//키가 13이면 실행 (엔터는 13)
            	insert();
            }
        });
    });
  </script>
  </body>

</html>