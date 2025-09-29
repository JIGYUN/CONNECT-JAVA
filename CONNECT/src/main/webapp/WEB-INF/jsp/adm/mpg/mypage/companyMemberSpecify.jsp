<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%> 
  <!DOCTYPE html>
<html>
  <body>
  <table class="table table-bordered table-sm">
      <thead>
            <tr>
	            <th scope="col">번호</th>
	            <th scope="col">부서</th>
	            <th scope="col">직위</th>  
	            <th scope="col">이름</th>  
	            <th scope="col">승인일</th>
	            <th scope="col">상태</th>
	            <th scope="col">업무 담당자 지정</th>
	            <th scope="col">업무이관</th>
	            <th scope="col">이관일</th>
	            <th scope="col">이관 상세</th>
            </tr> 
        </thead>
        <tbody id="managerTb">
	        <tr>
	            <td>1</td>
	            <td><a href="#"></a></td>
	            <td><a href="#"></a></td>
	            <td><a href="#"></a></td>
	            <td><a href="#"></a></td>
	            <td><a href="#"></a></td>
	            <td><a href="#"></a></td>
	            <td><a href="#"></a></td>
	            <td><a href="#"></a></td>
	        </tr>
        </tbody>
    </table>

    <form id="send-form">   
		<div class="form-row">
		    <div class="form-group col-md-6">
		        <label for="inputEmail4">이름</label>
		        <input type="email" class="form-control" id="mberNm" name="mberNm" placeholder="이름" readonly>
		    </div>
		    <div class="form-group col-md-6">
		        <label for="inputEmail4">휴대전화번호</label>  
		        <input type="text" class="form-control" id="cryalTelno" name="cryalTelno" placeholder="휴대전화번호" readonly>
		    </div>
		</div>  
		
		<div class="form-row">
		    <div class="form-group col-md-6">
		        <label for="inputPassword4">이메일</label>
		        <input type="text" class="form-control" id="email" name="email" placeholder="이메일">
		    </div>
		    <div class="form-group col-md-6">
		        <label for="inputPassword4">연락첰(사무실)</label>
		        <input type="text" class="form-control" id="managerTelno" name="managerTelno" placeholder="아메일"> 
		    </div>
		</div>

		<div class="form-row">
 		    <div class="form-group col-md-6">
		        <label for="inputEmail4">팩스번호</label>
		        <input type="text" class="form-control" id="managerFaxno" name="managerFaxno" placeholder="팩스번호">  
		    </div> 
		    <div class="form-group col-md-6">
		        <label for="inputPassword4">상태관리</label>
		        <input type="text" class="form-control" id="status" name="status" placeholder="상태관리">  
		    </div>  
		</div>
		
		<div class="form-row">
 		    <div class="form-group col-md-6">
		        <label for="inputEmail4">부서</label>
		        <input type="text" class="form-control" id="deptName" name="deptName" placeholder="부서">
		    </div> 
		    <div class="form-group col-md-6">
		        <label for="inputPassword4">직급</label>
		        <input type="text" class="form-control" id="dursName" name="dursName" placeholder="관심분야">
		    </div>  
		</div> 
		
		<div class="form-row">
		    <div class="form-group col-md-6"> 
		        <label for="inputPassword4">직위</label>
		        </br>
		        <select id="positionName" name="positionName">
		        	<option value="">선택하기</option>  
		        	<option value="사원">사원</option>
		        	<option value="주임">주임</option>
		        	<option value="대리">대리</option>  
		        	<option value="과장">과장</option>
		        	<option value="차장">차장</option>
		        	<option value="부장">부장</option>
		        	<option value="이사">이사</option>
		        	<option value="상무">상무</option>
		        	<option value="대표이사">대표이사</option>
		        	<option value="연구원">연구원</option>
		        	<option value="선임연구원">선임연구원</option>
		        	<option value="책임연구원">책임연구원</option>  
		        </select>
		    </div>
	    </div>
		
		<button type="button" class="btn btn-primary" onClick="modify()">수정하기</button>
		<input type="hidden" id="mberNo" name="mberNo" >  
		<input type="hidden" id="mberSeq" name="mberSeq" value=1>  
		<input type="hidden" id="mberSeCd" name="mberSeCd" value='A'>
		<input type="hidden" id="registerId" name="registerId" value='A'>
		<input type="hidden" id="changerId" name="changerId" value='A'>
		<input type="hidden" id="sportHdqrDeptCd" name="sportHdqrDeptCd" value='A'>
		<input type="hidden" id="cstmrSttusCd" name="cstmrSttusCd" value='A'>  
		<input type="hidden" id="dmstcOvseaSeCd" name="dmstcOvseaSeCd" value='A'>
		<input type="hidden" id="cstmrSeCd" name="cstmrSeCd" value='A'> 
		<input type="hidden" id="zrpctaxBsnmYn" name="zrpctaxBsnmYn" value='A'>   
		<input type="hidden" id="zrpctaxBsnmYn" name="nationCd" value='KO'>
		<input type="hidden" id="zrpctaxBsnmYn" name="ihidnum" value='910916'>
		<input type="hidden" name="duplicateYn" id="duplicateYn" >
    </form>  

  
  </div>
  
  <script>   
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
	
	var managerList = [];
	function selectManagerList() {
		var formData = {};
 		$.ajax({  
	        url: "/api/mypage/selectSpecifyManagerList",
	        type: "post",
	        contentType: "application/json;charset=utf-8",  
	        dataType :'json',
	 		data : JSON.stringify(formData), 
	        success: function (map){      
	        	$("#managerTb").empty();  
	        	console.log(map.result);  
	        	managerList = map.result; 
	        	if ( managerList.length > 0 ) {
	        		for (var i=0; i<managerList.length ; i++ ) { 
	        			var isWorkChecked = "";
	        			var isCalChecked = "";
	        			
	        			if (managerList[i].role == "2") {
	        				isWorkChecked = "checked";
	        			} else if (managerList[i].role == "3") {
	        				isCalChecked = "checked";
	        			}
	        			
		        		var txt ='' ;      
		        		txt+='<tr>';  
		        		txt+='    <td>' + (i + 1) + '</td>'; 
		        		txt+='    <td>' + managerList[i].deptName + '</td>';
		        		txt+='    <td>' + managerList[i].dursName + '</td>';
		        		txt+='    <td><a href="javascript:selectManagerDetail(' + i + ')">' + managerList[i].mberNm + '</a></td>';
		        		txt+='    <td>' + managerList[i].approveDt + '</td>';   
		        		txt+='    <td>' + managerList[i].status + '</td>';
	        			txt+='    <td><input type="radio" name="role" id="role" value="2" onclick="specifyMemeber(\'' + managerList[i].mberNo + '\',2)" ' + isWorkChecked + '> 업무 <input type="radio" name="role" id="role" value="2" onclick="specifyMemeber(\'' + managerList[i].mberNo + '\',3)" ' + isCalChecked + '> 계산서</td>';
		        		txt+='    <td>홍길동</td>';  
		        		txt+='    <td>2024.02.07</td>';
		        		txt+='    <td>김길동 - > 홍길동</td>';
		        	    txt+='</tr>';
	        			    
	        			$("#managerTb").append(txt);
	        		}
	        	}
	        },
	        error: function(request, status, error){      
	            
	        }
	   });
	}  
	
	function selectManagerDetail(i){
		console.log(managerList[i]);  
		$("#mberNo").val(managerList[i].mberNo);
		$("#mberNm").val(managerList[i].mberNm);
		$("#cryalTelno").val(managerList[i].cryalTelno);
		$("#email").val(managerList[i].email);
		$("#managerTelno").val(managerList[i].managerTelno);
		$("#managerFaxno").val(managerList[i].managerFaxno);
		$("#status").val(managerList[i].status);  
		$("#deptName").val(managerList[i].deptName); 
		$("#dursName").val(managerList[i].dursName);
		$("#positionName").val(managerList[i].positionName); 
	}
	
	function specifyMemeber(mberNo, role) {
		var formData = {};
		formData.role = role;
		formData.mberNo = mberNo;
		
 		$.ajax({
	        url: "/api/mypage/specifyMember", 
	        type: "post",
	        contentType: "application/json;charset=utf-8", 
	        dataType :'json',
	 		data : JSON.stringify(formData), 
	        success: function (map){
	        	alert("업무 담당자가 지정되었습니다.");
                selectManagerList();
	        },
	        error: function(request, status, error){
	            
	        }
	   });
	}
	
	function modify() {
 		var formData = $("#send-form").serializeObject();
 		console.log(formData);  
 		$.ajax({  
	        url: "/api/mypage/modifyManager",
	        type: "post",
	        contentType: "application/json;charset=utf-8", 
	        dataType :'json',
	 		data : JSON.stringify(formData),   
	        success: function (map){
                alert("수정이 완료되었습니다.");  
	        },
	        error: function(request, status, error){
	            
	        }
	   });
	}
	
    $(document).ready(function(){
    	selectManagerList();
        $("input[name=password]").keydown(function (key) {
            if(key.keyCode == 13){//키가 13이면 실행 (엔터는 13)
                goLogin();
            }
        });
    });
  </script>

  </body>
</html>