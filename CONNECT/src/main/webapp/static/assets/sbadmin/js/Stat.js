var Stat = {
	// 스케줄 목록
	fnStat : function() {
		var surl = "/rest/household/stat";
		
		var sendData = {};
		$("#DivHouseholdStat").empty();
	    $.ajax({
	        url: surl,
	        type: "post", 
	        contentType: "application/json",
	        data: JSON.stringify(sendData),
	        success: function (workResultObj){
	        	console.log(workResultObj);
	            var data = workResultObj.results ;
	        	var list = data.householdStat;  
	        	if ( list.length > 0 ) {
	        		Stat.fnSetStat(list);
	        	} else {
	        		//$("#totalAmount").text("0");
	        		$("#DivHouseholdStat").empty(); 
	        	}
	        },
	        error: function(request, status, error){
	            
	        }  
	    }); 
	}, 
	// 스케줄 목록 그리기
	fnSetStat : function(list) {
		var txt ='' ;
		txt+='<li class="liStat"><span id="householdStat"></span></li>';
		  
		for (var i=0; i<list.length ; i++ ) {
			$("#DivHouseholdStat").append(txt);
			var target = $("#DivHouseholdStat li.liStat:last");
			Stat.setData(target, list[i] ); 
		} 
	}, 
	// 스케줄 목록 데이터 세팅
	setData : function(target, data) {   
		console.log(data.sumAmount);
		target.find("span#householdStat").html(data.month + "월 - " + Util.numberToComma(data.sumAmount) + "원");
	}
}