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
  <meta name="google-signin-client_id" content="442434028472-3k5o0k7urabal0ff915pt58788v44pm1.apps.googleusercontent.com">
  <div class="col-sm-5">
      <form name="frm" id="frm" method="post">
      <input type="hidden" name="mberNm"  id="mberNm" value="${map.mberNm}" >
      <input type="hidden" name="cryalTelno" id="cryalTelno" value="${map.cryalTelno}" >
      <h1 class="h3 mb-3 fw-normal">아이디 찿기</h1>  
	  <div>
	      <p id="idTxt">아이디는 $$입니다.</p> 
	  </div>
      <!--<div class="form-check text-start my-3">
        <input class="form-check-input" type="checkbox" value="remember-me" id="flexCheckDefault">
        <label class="form-check-label" for="flexCheckDefault">
          Remember me
        </label>
      </div>-->
      <div class="row" style="padding:5px;">
          <div class="col-md-12">
              <button class="btn btn-primary w-100 py-2" type="button" onClick="goLink('/mba/auth/login')">Login</button>
          </div>
	  </div>
      <div class="row" style="padding:5px;">  
  	      <div class="col-md-12">
              <button class="btn btn-primary w-100 py-2" type="button" onClick="goLink('/mba/auth/pwFind')">비밀번호 찾기</button>
          </div>
	  </div>    
  </form>
  </main>
  </div>
  <script>
  	  function findId(){
		
		  var sendData = {};
		  sendData.cryalTelno = $("#cryalTelno").val();
	      sendData.mberNm = $("#mberNm").val();
	
	      $.ajax({
	          url: "/api/auth/findId",  
	          type: "post",
	          contentType: "application/json", 
	          data: JSON.stringify(sendData),  
	          success: function (map){
	        	  var id = map.result.id.slice(0, -3);      
	        	  $("#idTxt").text("아이디는" + id + "***입니다.");  
	          },
	          error: function(request, status, error){
	            
	          }
	      }); 
	  }


      $(document).ready(function(){
    	  findId();
      });
      
      
  </script>

  </body>
</html>