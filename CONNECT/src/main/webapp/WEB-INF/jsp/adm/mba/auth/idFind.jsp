<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%> 
  <!DOCTYPE html>
<html>
  <body>
  <div class="col-sm-5">
	  <form name="idFrm" id="idFrm" method="post"> 
	      <h1 class="h3 mb-3 fw-normal">아이디 찾기</h1>   
	      <div class="form-floating">  
	          <input type="text" class="form-control" name="mberNm" id="mberNm" placeholder="이름">
	          <label for="mberNm"></label>
	      </div>
	      <div class="form-floating">
	          <input type="text" class="form-control" name="cryalTelno" id="cryalTelno" placeholder="핸드폰번호">
	          <label for="cryalTelno"></label>  
	      </div>   
	      <p id="idFindTxt" style="color:red; display:none;" >입력하신 회원정보를 찾을 수 없습니다.</p>
	      <div class="row">
	          <div class="col-md-12">
	              <button class="btn btn-primary w-100 py-2" type="button" onClick="goIdFind()">아이디 찾기</button>
	          </div>
		  </div>
	  </form>
  </div>
    
  <script>   
	function goIdFind(){
			
	    if ($("#mberNm").val() == "") {
	        alert("이름을 입력해주세요.");
	        $("#mberNm").focus();
	        return;
	    }
	    
	    if ($("#cryalTelno").val() == "") {
	        alert("핸드폰번호를 입력해주세요.");
	        $("#cryalTelno").focus();
	        return;
	    }
		
	    var sendData = {};
		sendData.cryalTelno = $("#cryalTelno").val();
	    sendData.mberNm = $("#mberNm").val();
	
	    $.ajax({
	        url: "/api/auth/findId",  
	        type: "post",
	        contentType: "application/json", 
	        data: JSON.stringify(sendData),  
	        success: function (map){
	        	var result = map.result;  
	        	if (result != null) {   
	        		$("#idFrm").attr("method","post");   
		            $("#idFrm").attr("action", "/mba/auth/idFindProc");    
		            $("#idFrm").submit();
	        	} else { 
	        		$("#idFindTxt").show();  
	        	}
	        	
	            
	        },
	        error: function(request, status, error){
	            
	        }
	    }); 
    }
  </script>

  </body>
</html>