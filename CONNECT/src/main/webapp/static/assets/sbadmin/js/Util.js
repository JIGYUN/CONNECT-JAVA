var Util = {
		
		// 숫자만 입력받습니다.
		onlyNumber : function(obj) {
			$(obj).val( $(obj).val().replace(/[^0-9]/g, ''));
		}, 
		
		// 원하는 숫자의 소수점을 버리고 가져옵니다.
		// number = 1000: 소수점 3자리수 이후는 절삭합니다
		// number = 100: 소수점 2자리수 이후는 절삭합니다
		cutDecimal : function(value, number) {
			value = Math.floor(value*number) / number;
			return value;
		},
		
		// 해당숫자에 comma를 추가합니다.
		numberToComma : function(x) {
			return x.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
		}, 
		
		// 원하는 String의 null을 체크합니다.
		chkStrNull : function(str) {
			if (str == null) {
				str = "";
			}
			return str;
		},
		
		// 원하는 Number의 null을 체크합니다.
		chkNumNull : function(str) {
			if (str == null) {
				str = 0;
			}
			return str;
		},
		
		
		// 입력값이 Null인지 체크합니다.
		isNull : function(sValue) {
		    if( new String(sValue).valueOf() == "undefined")
		        return true;
		    if( sValue == null )
		        return true;
		    if( sValue.toString().trim().length == 0 )
		        return true;
		    return false;
		},
		
		// 해당글자내에서 특정글자를 원하는글자로 모두 변경합니다.
		replaceAll : function(str, searchStr, replaceStr) {
			return str.split(searchStr).join(replaceStr);
		},
		
		// 원하는 형식의 오늘날짜를 가져옵니다.
		getToday : function(format) {
			var date = new Date(); 
		    var year = date.getFullYear();              //yyyy
		    var month = (1 + date.getMonth());          //M
		    month = month >= 10 ? month : '0' + month;  //month 두자리로 저장
		    var day = date.getDate();                   //d
		    day = day >= 10 ? day : '0' + day;          //day 두자리로 저장
		    
		    var today = "";
		    
		    if (format == "yyyy-mm-dd") {
		    	today =  year + '-' + month + '-' + day;
		    } else if (format == "yyyymmdd") {
		    	today =  year + month + day;
		    } else  if (format == "yyyy:mm:dd") {
		    	today =  year + ':' + month + ':' + day;
		    } else  if (format == "yyyy.mm.dd") {
		    	today =  year + '.' + month + '.' + day;
		    } else  if (format == "yyyy/mm/dd") {
		    	today =  year + '/' + month + '/' + day;
		    }
		    
		    return today;
		},
		
		// 원하는 형식의 어제날짜를 가져옵니다.
		getYesterday : function(format) {
			var date = new Date();
			date.setDate(date.getDate() - 1); // <-- add this to make it "yesterday"
		    var year = date.getFullYear();              //yyyy
		    var month = (1 + date.getMonth());          //M
		    month = month >= 10 ? month : '0' + month;  //month 두자리로 저장
		    var day = date.getDate();                   //d
		    day = day >= 10 ? day : '0' + day;          //day 두자리로 저장
		    
		    var yesterday = "";
		    
		    if (format == "yyyy-mm-dd") {
		    	yesterday =  year + '-' + month + '-' + day;
		    } else if (format == "yyyymmdd") {
		    	yesterday =  year + month + day;
		    } else  if (format == "yyyy:mm:dd") {
		    	yesterday =  year + ':' + month + ':' + day;
		    } else  if (format == "yyyy.mm.dd") {
		    	yesterday =  year + '.' + month + '.' + day;
		    } else  if (format == "yyyy/mm/dd") {
		    	yesterday =  year + '/' + month + '/' + day;
		    }
		    
		    return yesterday;
		},  
		
		// 현재 날짜 시분초를 가져옵니다.
		getTodayTime : function() {
			var date = new Date(); 
		    var year = date.getFullYear();              //yyyy
		    var month = (1 + date.getMonth());          //M
		    var day = date.getDate();                   //d
		    var hours = date.getHours(); // 시
		    var minutes = date.getMinutes();  // 분
		    var seconds = date.getSeconds();  // 초  
		    var milliseconds = date.getMilliseconds(); // 밀리초

		    month = month >= 10 ? month : '0' + month;  //month 두자리로 저장
		    day = day >= 10 ? day : '0' + day;          //day 두자리로 저장
		    hours = hours >= 10 ? hours : '0' + hours;  //hours 두자리로 저장    
		    minutes = minutes >= 10 ? minutes : '0' + minutes;  //minutes 두자리로 저장    
		    seconds = seconds >= 10 ? seconds : '0' + seconds;  //seconds 두자리로 저장    
		    milliseconds = milliseconds >= 10 ? milliseconds : '0' + milliseconds;  //milliseconds 두자리로 저장
		     
		    var today = "";
		    today =  year + '-' + month + '-' + day + " " + hours + ":" + minutes + ":" + seconds;
		     
		    return today;
		},
		
		// html 태그를 문자 html로 변환합니다.
		// Script 공격 방지 보안
		escapeHtml : function(str) {
			return str.replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/\"/g, "&quot;").replace(/\'/g, "&apos;");
		},
		
		// 문자 html을 html로 변환합니다
		// 글자로된 html을 html로변환해서 태그가 표현될수있게함
		unescapeHtml : function(str) {
			return str.replace(/&lt;/g, "<").replace(/&gt;/g, ">").replace(/&quot;/g, "\"").replace(/&apos;/g, "\'");
		},
		
		/* 비밀번호 유효성 검사 */ 
		chkPwd : function(pwd) {
			// 8~20자 사이의 영어 소문자, 영어 대문자, 숫자, 특수문자 조합
		    var chk = false;
			if(!/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[$@$!%*?&])[A-Za-z\d$@$!%*?&]{8,20}/.test(pwd)){
				chk = true;
			}
			return chk; 
		},
		
		/* 3자리 연속 비밀번호 유효성 검사 */ 
		chkPwdThreeContinue : function(pwd) {
		    var chk = false;
			if(/(.)\1\1/.test(pwd)){
				chk = true; 
			}
			return chk;
		},
		
		// 특수문자 유효성 체크
		chkSpecialChar : function(val) {
			var pattern = /[^가-힣ㄱ-ㅎㅏ-ㅣa-zA-Z0-9 ]/gi;
			var chk = false;
			if (pattern.test(val)) {
				chk = true;
			}
			return chk;
		},
		
		// 이메일 유효성 검사
		chkEmail : function(email) {
			var re = /^([\w-]+(?:\.[\w-]+)*)@((?:[\w-]+\.)*\w[\w-]{0,66})\.([a-z]{2,6}(?:\.[a-z]{2})?)$/i;
			return re.test(email);
		},
		
		// 아이디 유효성 검사
		chkId : function(input) {
			//영문하고 숫자만 들어갔는지 확인
			var regex = /^[a-zA-z][a-zA-z0-9]{5,15}$/gi;
			if (!regex.test(input)) {
			    alert("ID는 영문자로 시작하여 숫자를 포함할 수 있으며(한글 및 특수문자 제외), 6자리 이상 16자리 이하입니다.");
			    return;
			}
		},

}