<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%> 
  <!DOCTYPE html>
<html>
  <body>
  <style>
    .btn {
        text-transform: capitalize;
        font-size: 15px;
        padding: 10px 19px;
        cursor: pointer
    }

    .m-b-20 {
        margin-bottom: 20px
    }

    .btn-md {
        padding: 10px 16px;
        font-size: 15px;
        line-height: 23px
    }  

    .heading{
      font-size: 21px;
    }

    #infoMessage p{
        color: red !important;
    }


    .btn-google {
        color: #545454;
        background-color: #ffffff;
        box-shadow: 0 1px 2px 1px #ddd;
    }


    .or-container {
        align-items: center;
        color: #ccc;
        display: flex;
        margin: 25px 0;
    }

    .line-separator {
        background-color: #ccc;
        flex-grow: 5;
        height: 1px;
    }

    .or-label {
        flex-grow: 1;
        margin: 0 15px;
        text-align: center;
    }
  </style>
  <div class="col-sm-5">
      <form name="frm" id="frm" method="post">
      <input type="hidden" name="mberNo"  id="mberNo" value="${map.mberNo}" >
      <h1 class="h3 mb-3 fw-normal">비밀번호 변경</h1>  
      <div class="form-floating">
          <input type="password" class="form-control" name="password" id="password" placeholder="새로운 비밀번호">
          <label for="id"></label>
      </div>
      <div class="form-floating">
          <input type="password" class="form-control" name="passwordConfirm" id="passwordConfirm" placeholder="새로운 비밀번호 확인">
          <label for="password"></label>
      </div>
      <div class="row">
          <div class="col-md-12">
              <button class="btn btn-primary w-100 py-2" type="button" onClick="changePassword()">비밀번호 변경</button>
          </div>
	  </div>
  </form>
  </main>
  </div>  
  <script>
	function changePassword(){
	    if ($("#password").val() == "") {
	        alert("비밀번호를 입력해주세요.");
	        return;
	    }
	    
		if(!checkPw($("#password").val())){
			alert("8자리 이상, 영문 대/소문자, 특수문자, 숫자를 조합해서 입력해주세요.");
			$("#password").focus();
			return;
		}
		
	    if ($("#passwordConfirm").val() == "") {
	        alert("비밀번호 확인을 입력해주세요.");
	        return;
	    }
		
		if(!($("#password").val() == $("#passwordConfirm").val())) {
			alert("비밀번호가 일지하지 않습니다.");
			$("#passwordConfirm").focus();
			return;
		}
	    
		var sendData = {};
		sendData.mberNo = $("#mberNo").val();
		sendData.password = $("#password").val();

	    $.ajax({
	        url: "/api/auth/changePassword",
	        type: "post",
	        contentType: "application/json",
	        data: JSON.stringify(sendData),
	        success: function (map){
                alert("비밀번호가 변경되었습니다.");
                goLink("/mba/auth/login");
	        },
	        error: function(request, status, error){
	            
	        }
	    });
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