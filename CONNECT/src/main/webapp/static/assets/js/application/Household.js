$(document).ready(function() {
	
	 $("#date").val(Util.getToday("yyyy-mm-dd"));   
	 $("#date").datepicker({ 
		 format: 'yyyy-mm-dd'
		,autoclose: true
	 });
	 
	 $('#date').datepicker().on('changeDate', function (ev) {
		 $("#totalAmount").text("0");
		 Household.fnSrch(); 
	 });  
	  
	 $("#DivSrchList").sortable( 
     { 	
         update: function () {
         var strItems = "";  

         $("#DivSrchList strong").each(function (i) {
             var div = $(this);   
             strItems += div.attr("id") + ':' + (i + 1) + ',';  
         });  
		
         Household.fnOrder(strItems);   
         }
     });
     
    $( "#DivSrchList" ).disableSelection();
	
	$("#title").keydown(function(key) {
		if (key.keyCode == 13) {
			$("#amount").focus();
		}
	});

	$("#amount").keydown(function(key) {
		if (key.keyCode == 13) {
			Household.fnRegist();
		}
	});

	$("#updateTitle").keydown(function(key) {
		if (key.keyCode == 13) {
			$("#updateAmount").focus();  
		}
	});

	$("#updateAmount").keydown(function(key) {
		if (key.keyCode == 13) {
			Household.fnUpdate();
		}
	});
	
	Household.fnSrch();
	
	$('#updateModal').on('shown.bs.modal', function () {
	    $('#updateTitle').focus(); 
	});
});

var Household = {
	// 스케줄 목록
	fnSrch : function() {
		var surl = "/rest/household/list";
		
		var sendData = {};
		sendData.formType = "1";
		sendData.dDt = $("#date").val();
		$("#DivSrchList").empty();
		console.log(sendData);
	    $.ajax({
	        url: surl,
	        type: "post", 
	        contentType: "application/json",
	        data: JSON.stringify(sendData),
	        success: function (workResultObj){
	        	console.log(workResultObj);
	            var data = workResultObj.results ;
	        	var list = data.householdList;  
	        	if ( list.length > 0 ) {
	        		Household.fnSetList(list);
	        	} else {
	        		$("#totalAmount").text("0");
	        		$("#DivSrchList").empty(); 
	        	}
	        },
	        error: function(request, status, error){
	            
	        }  
	    }); 
	}, 
	// 스케줄 목록 그리기
	fnSetList : function(list) {
		var txt ='' ;
		txt+='<div class="media text-muted pt-3"> ';
		txt+='  <svg class="bd-placeholder-img mr-2 rounded" width="24" height="24" xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMidYMid slice" focusable="false" role="img" aria-label="Placeholder: 32x32"><title>Placeholder</title><rect width="100%" height="100%" fill="#007bff"/><text x="50%" y="50%" fill="#007bff" dy=".3em">32x32</text></svg>'; 
		txt+='  <p class="media-body pb-3 mb-0 small lh-100 border-bottom border-gray">';   
		txt+='      <strong class="d-block text-gray-dark order">';   
		txt+='  	    <span class="title">';
		txt+='  	    </span>';
		txt+='          <span class="amount">';
		txt+='          </span>';
		txt+='          <input type="hidden" class="amountVal">';
		txt+='      </strong>';
	    txt+='  </p>';
	    txt+=' </div>';
		
		for (var i=0; i<list.length ; i++ ) {
			$("#DivSrchList").append(txt);
			var target = $("#DivSrchList div.text-muted:last");
			Household.setData(target, list[i] ); 
			if (list.length == (i + 1)) { 
				Household.fnTotalCount();
			}
		}
	},
	// 스케줄 목록 데이터 세팅
	setData : function(target, data) {
		target.attr("ondblclick", "Household.showUpdateModal('" + data.householdNo + "','" + data.title + "','" + data.amount + "')");
		console.log(data.amount);
		target.find("input.amountVal").val(data.amount);
	 	target.find("span.amount").text("[" + data.amount+ "]");
		target.find("span.title").text(data.title);
		target.find("strong.order").attr("id", data.householdNo);
	},
	// 스케줄 등록하기
	fnRegist : function() {
		var surl = "/rest/household/regist";

		if($("#title").val() == "") {
			alert("제목을 입력해주세요.");
			$("#title").focus();
			return;  
		}
		
		if($("#amount").val() == "") {
			alert("금액을 입력해주세요.");
			$("#amount").focus();
			return;  
		}

		var sendData = {};
		sendData.title = $("#title").val(); 
		sendData.amount = $("#amount").val();  
		sendData.dDt = $("#date").val();
		console.log($("#amount").val());
	    console.log(sendData);
	    $.ajax({
	        url: surl,
	        type: "post", 
	        contentType: "application/json", 
	        data: JSON.stringify(sendData),
	        success: function (workResultObj){
	            if(workResultObj.status == "success"){
	            	Household.fnSrch(); 
					$("#title").val("");
					$("#amount").val("");
					$("#title").focus();
	            } else{
	            	alert("fail");
	            }
	        },
	        error: function(request, status, error){
	            // openAlertPopup('에러!');
	        }
	    });
	},
	// 업데이트 모달보여주기
	showUpdateModal : function(householdNo, title, amount) {
		$("#householdNo").val(householdNo);
		$("#updateTitle").val(title);
		$("#updateAmount").val(amount);
		$('#updateModal').modal('show');
	}, 
	// 스케쥴 수정하기
	fnUpdate : function() {
		var surl = "/rest/household/update";

		if($("#updateTitle").val() == "") {
			alert("Please enter title");
			$("#updateTitle").focus();
			return;  
		}
		
		if($("#updateAmount").val() == "") {
			alert("Please enter amount");
			$("#updateAmount").focus();
			return;  
		}
		sendData = {};
		sendData.title = $("#updateTitle").val();
		sendData.amount = $("#updateAmount").val();
		sendData.householdNo = $("#householdNo").val();
		sendData.dDt = sendData.dDt = $("#date").val();
	    
	    $.ajax({
	        url: surl,
	        type: "post", 
	        contentType: "application/json", 
	        data: JSON.stringify(sendData),
	        success: function (workResultObj){
	            if(workResultObj.status == "success"){
	            	Household.fnSrch(); 
					$('#updateModal').modal('hide');  
	            } else{  
	            	alert("fail");
	            }
	        }, 
	        error: function(request, status, error){
	            // openAlertPopup('에러!');
	        }  
	    });
	},
	// 스케쥴 삭제하기
	fnDelete : function() {
		var surl = "/rest/household/delete";
		
		var sendData = {};
		sendData.householdNo = $("#householdNo").val(); 
	    
	    $.ajax({
	        url: surl,
	        type: "post", 
	        contentType: "application/json", 
	        data: JSON.stringify(sendData),
	        success: function (workResultObj){
	            if(workResultObj.status == "success"){
	            	Household.fnSrch(); 
					$('#updateModal').modal('hide');
	            } else{  
	            	alert("fail");
	            }
	        }, 
	        error: function(request, status, error){
	            // openAlertPopup('에러!');
	        }  
	    }); 
	},	
	// 스케쥴 순서 맞추기
	fnOrder : function(strItems) {
		console.log(strItems);  
		var surl = "/rest/household/order";
		
		var sendData = {}; 
		sendData.orderArray = strItems;
	    $.ajax({
	        url: surl,
	        type: "post",
	        contentType: "application/json", 
	        data: JSON.stringify(sendData), 
	        success: function (workResultObj){
	            if(workResultObj.status == "success"){
	            	Household.fnSrch();   
	            } else{   
	            	alert("fail"); 
	            }
	        }, 
	        error: function(request, status, error){
	            // openAlertPopup('에러!');
	        }  
	    }); 
	},
	// 숫자 새기
	fnTotalCount : function() { 
		var totalAmount = 0;
	    $("#DivSrchList .amountVal").each(function (i) {
	        var amount = Number($(this).val());
			console.log("amount = " + amount);
			totalAmount = totalAmount + amount;
	    });
	    console.log("totalAmount = " + totalAmount);
	    $("#totalAmount").text(totalAmount);
	}
}