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
      <h1 class="h3 mb-3 fw-normal">로그인실패</h1>  
	  <div> 
	      <p id="idTxt">로그인에 실패했습니다.</p> 
	  </div>
      <!--<div class="form-check text-start my-3">
        <input class="form-check-input" type="checkbox" value="remember-me" id="flexCheckDefault">
        <label class="form-check-label" for="flexCheckDefault">
          Remember me
        </label>
      </div>-->
      <div class="row">
          <div class="col-md-12">
              <button class="btn btn-primary w-100 py-2" type="button" onClick="goLink('/mba/auth/login')">Login</button>
          </div>
	  </div>
  </form>
  </main>
  </div>
  <script>

      
      
  </script>

  </body>
</html>