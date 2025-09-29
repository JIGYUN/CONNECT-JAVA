$(document).ready(function() {
/*	 $("#date").val(Util.getToday("yyyy-mm-dd"));   
	 $("#date").datepicker({ 
		 format: 'yyyy-mm-dd'
		,autoclose: true
	 });
	 
	 $('#date').datepicker().on('changeDate', function (ev) {
		 Reminder.fnSrch();
	 });  */
	 
	 $("#DivSrchList").sortable(
     {
         update: function () {
	         var strItems = "";
			 
	         $("#DivSrchList strong").each(function (i) {
	             var div = $(this);
	             strItems += div.attr("id") + ':' + (i + 1) + ',';
	         });
		 	 
	         Reminder.fnOrder(strItems);
         }
    });
    
    $( "#DivSrchList" ).disableSelection();
	
	$("#title").keydown(function(key) {
		if (key.keyCode == 13) {
			Reminder.fnRegist();
		}
	});
	
	$("#updateTitle").keydown(function(key) {
		if (key.keyCode == 13) {
			Reminder.fnUpdate();
		}
	});
	 
	Reminder.fnSrch();
	
	$('#updateModal').on('shown.bs.modal', function () {
	    $('#updateTitle').focus();
	});
});

var Reminder = {
	// 스케줄 목록
	fnSrch : function() {
		var sendData = {};
		$("#DivSrchList").empty();
		sendData.dDt = $("#date").val(); 
		console.log(sendData); 
	    $.ajax({
	        url: "/rest/reminder/list", 
	        type: "post",  
	        contentType: "application/json",  
	        data: JSON.stringify(sendData),  
	        success: function (workResultObj){
	        	console.log(workResultObj);
	            var data = workResultObj.results;
	            
				var list = data.reminderList;
				if ( list.length > 0 ) {
					Reminder.fnSetList(list);
				} else {
					$("#DivSrchList").empty();
				}
	        },
	        error: function(request, status, error){
	            // openAlertPopup('에러!');
	        }
	    });
	}, 
	// 스케줄 목록 그리기
	fnSetList : function(list) {
		var txt ='' ;  
		txt+='<div class="media text-muted pt-3"> ';  
		txt+='  <svg class="bd-placeholder-img mr-2 rounded" width="24" height="24" xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMidYMid slice" focusable="false" role="img" aria-label="Placeholder: 32x32"><title>Placeholder</title><rect width="100%" height="100%" fill="#007bff"/><text x="50%" y="50%" fill="#007bff" dy=".3em">32x32</text></svg>'; 
		txt+='  <p class="media-body pb-3 mb-0 small lh-100 border-bottom border-gray">';   
		txt+='    <strong class="d-block text-gray-dark title" id="title">@username</strong>';   
	    txt+='  </p>';  
	    txt+=' </div>'; 
		
		for (var i=0; i<list.length ; i++ ) {
			$("#DivSrchList").append(txt);
			var target = $("#DivSrchList div.text-muted:last");
			Reminder.setData(target, list[i] );
		}
	},
	// 스케줄 목록 데이터 세팅
	setData : function(target, data) {
		target.attr("ondblclick", "Reminder.showUpdateModal('" + data.scheduleNo + "','" + data.title + "')"); 
		target.find("strong.title").text(data.title);          
		target.find("strong.title").attr("id", data.scheduleNo);    
	},
	// 스케줄 등록하기
	fnRegist : function() {
		var surl = "/rest/reminder/regist";
		
		var sendData = {};
		sendData.title = $("#title").val(); 
		sendData.dDt = $("#date").val(); 
		
	    $.ajax({
	        url: surl,
	        type: "post",  
	        contentType: "application/json",  
	        data: JSON.stringify(sendData),
	        success: function (workResultObj){
	            if(workResultObj.status == "success"){
	            	Reminder.fnSrch(); 
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
	showUpdateModal : function(reminderNo, title) {
		$("#reminderNo").val(reminderNo);
		$("#updateTitle").val(title);
		$('#updateModal').modal('show'); 
	},
	// 스케쥴 수정하기
	fnUpdate : function() {
		var surl = "/rest/reminder/update";
		
		var sendData = {};
		sendData.title = $("#updateTitle").val();
		sendData.reminderNo = $("#reminderNo").val();
		sendData.dDt = sendData.dDt = $("#date").val();
		
	    $.ajax({
	        url: surl,
	        type: "post",
	        contentType: "application/json",  
	        data: JSON.stringify(sendData),
	        success: function (workResultObj){
	            if(workResultObj.status == "success"){
	            	Reminder.fnSrch(); 
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
		var surl = "/rest/reminder/delete";
		
		var sendData = {};
		sendData.reminderNo = $("#reminderNo").val(); 
	    
	    $.ajax({
	        url: surl,
	        type: "post", 
	        contentType: "application/json",  
	        data: JSON.stringify(sendData),
	        success: function (workResultObj){
	            if(workResultObj.status == "success"){
	            	Reminder.fnSrch(); 
					$('#updateTitle').modal('hide');
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
		
		var sendData = {};
		sendData.orderArray = strItems;
		console.log(sendData);  
	    $.ajax({
	        url: "/rest/reminder/order",
	        type: "post",
	        contentType: "application/json",
	        data: JSON.stringify(sendData),
	        success: function (workResultObj){
	            if(workResultObj.status == "success"){
					Reminder.fnSrch();
	            } else{  
	            	alert("fail");
	            } 
	        }, 
	        error: function(request, status, error){
	            // openAlertPopup('에러!');
	        }  
	    }); 
	},
}