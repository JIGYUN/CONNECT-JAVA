<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%> 
  <!DOCTYPE html>
<html>
  <body>
  <div class="col-sm-5">
      <form name="idFrm" id=" " method="post" action="/com/auth/login">
      <input type="hidden" class="form-control" name="mberSeCd" id="mberSeCd" value="${userVO.mberSeCd}">  
      <h1 class="h3 mb-3 fw-normal">개인정보수정</h1>
      <div class="form-floating">  
          <p id="idTxt">${userVO.mberId}</p> 
          <input type="hidden" class="form-control" name="id" id="id" value="${userVO.mberId}">  
          <label for="id"></label>
      </div>  
      <div class="form-floating">
          <input type="password" class="form-control" name="password" id="password" placeholder="비밀번호">  
          <label for="password"></label>
      </div>
      <div class="row" style="padding:5px;">
          <div class="col-md-12">
              <button class="btn btn-primary w-100 py-2" type="button" onClick="checkPassword()">확인</button>
          </div>
	  </div>  
      <div class="row" style="padding:5px;">
          <div class="col-md-12">
              <button class="btn btn-primary w-100 py-2" type="button" onClick="goLink('')">취소</button>
          </div>  
	  </div>
  </form>
  </div>  

  
  <form name="idPwFrm" id="idPwFrm" method="post">
  	  <input type="hidden" class="form-control" name="id" id="id" placeholder="아이디">
      <input type="hidden" class="form-control" name="mberNm" id="mberNm" placeholder="아이디">
      <input type="hidden" class="form-control" name="cryalTelno" id="cryalTelno" placeholder="전화번호">
  </form>  
  
  </div>
  
  <script>   
  
    function checkPassword(){
		
	    var sendData = {};
	    sendData.id = $("#id").val();
        sendData.password = $("#password").val();

        $.ajax({
            url: "/api/mypage/checkPassword",    
            type: "post",  
            contentType: "application/json", 
            data: JSON.stringify(sendData),
            success: function (map){
	        	var result = map.result;  
	        	if (result != null) {
	        		if ($("#mberSeCd").val() == "A") {
	        			goLink("/mpg/mypage/companyMemberModify");
	        		} else {
	        			goLink("/mpg/mypage/memberModify");
	        		}
		        	
	        	} else {
	        		alert("비밀번호가 맞지않습니다.");  
	        	}
            },
            error: function(request, status, error){
            
            }
        }); 
    }

  
	function goIdFind(){
		$("#mberNm").val($("#idMberNm").val());
		$("#cryalTelno").val($("#idCryalTelno").val());

        $("#idPwFrm").attr("method","post");   
        $("#idPwFrm").attr("action", "/mba/auth/idFindProc");
        $("#idPwFrm").submit();
	}
	
	function goPwFind(){  
		
	    if ($("#pwId").val() == "") {
	        alert("아이디를 입력해주세요.");  
	        return;
	    }
		
	    if ($("#pwMberNm").val() == "") {
	        alert("이름을 입력해주세요.");
	        return;
	    }

	    if ($("#pwCryalTelno").val() == "") {
	        alert("비밀번호를 입력해주세요.");
	        return;
	    }  
	    
		$("#mberNm").val($("#pwMberNm").val());
		$("#cryalTelno").val($("#pwCryalTelno").val());
		$("#id").val($("#pwId").val());

        $("#idPwFrm").attr("method","post");
        $("#idPwFrm").attr("action", "/mba/auth/pwFind");   
        $("#idPwFrm").submit();
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