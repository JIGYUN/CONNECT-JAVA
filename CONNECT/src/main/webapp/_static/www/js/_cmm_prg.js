var _callBackAddressId, _callBackAddrDetailId, callBackZipCodeId;
// 이메일 도메인체크 정규식 (도메인 주소 형식이 *.* 만 가능)
var chkDomainExp = /((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.)|(([\w-]+\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})(\]?)$/;
// 이메일 아이디체크 정규식 (영문, 숫자, 특수기호(-_.) 만 가능)
var chkEmailIdExp = /^[-A-Za-z0-9_]+[-A-Za-z0-9_.]*$/;
// 전화번호 정규식
var chkTelExp = /^[0-9]{2,3}-[0-9]{3,4}-[0-9]{4}$/;
// 아이디 정규식
var chkIdExp = /^[a-zA-Z]+[a-zA-Z0-9!@#$%^&*]{3,15}$/;
// 비밀번호 정규식
var chkPwExp = /^(?=.*[a-zA-Z])(?=.*[~!@#$*()])(?=.*[0-9]).{9,16}$/;


/**
 * 
 * @param callBackAddress 		주소ID
 * @param callBackAddrDetail	상세주소ID
 * @param callBackZipCode		우편번호 (-포함)
 */
function openJusoPopup(callBackAddressId, callBackAddrDetailId, callBackZipCodeId){
	new daum.Postcode({
        oncomplete: function(data) {
            // 팝업에서 검색결과 항목을 클릭했을때 실행할 코드를 작성하는 부분.

            // 각 주소의 노출 규칙에 따라 주소를 조합한다.
            // 내려오는 변수가 값이 없는 경우엔 공백('')값을 가지므로, 이를 참고하여 분기 한다.
            var addr = ''; // 주소 변수
            var extraAddr = ''; // 참고항목 변수

            //사용자가 선택한 주소 타입에 따라 해당 주소 값을 가져온다.
            if (data.userSelectedType === 'R') { // 사용자가 도로명 주소를 선택했을 경우
                addr = data.roadAddress;
            } else { // 사용자가 지번 주소를 선택했을 경우(J)
                addr = data.jibunAddress;
            }

            // 사용자가 선택한 주소가 도로명 타입일때 참고항목을 조합한다.
            /*if(data.userSelectedType === 'R'){
                // 법정동명이 있을 경우 추가한다. (법정리는 제외)
                // 법정동의 경우 마지막 문자가 "동/로/가"로 끝난다.
                if(data.bname !== '' && /[동|로|가]$/g.test(data.bname)){
                    extraAddr += data.bname;
                }
                // 건물명이 있고, 공동주택일 경우 추가한다.
                if(data.buildingName !== '' && data.apartment === 'Y'){
                    extraAddr += (extraAddr !== '' ? ', ' + data.buildingName : data.buildingName);
                }
                // 표시할 참고항목이 있을 경우, 괄호까지 추가한 최종 문자열을 만든다.
                if(extraAddr !== ''){
                    extraAddr = ' (' + extraAddr + ')';
                }
                // 조합된 참고항목을 해당 필드에 넣는다.
                document.getElementById("sample6_extraAddress").value = extraAddr;
            
            } else {
                document.getElementById("sample6_extraAddress").value = '';
            }*/

            // 우편번호와 주소 정보를 해당 필드에 넣는다.
            document.getElementById(callBackZipCodeId).value = data.zonecode;
            document.getElementById(callBackAddressId).value = addr;
            // 커서를 상세주소 필드로 이동한다.
            document.getElementById(callBackAddrDetailId).focus();
        }
    }).open();
}

var CBA_window; 
var isLocal = false;
function openCBAWindow(frm) { 
	CBA_window = window.open('', 'CbaV2Window', 'width=410, height=450, resizable=0, scrollbars=no, status=0, titlebar=0, toolbar=0, left=300, top=200' );

    if(CBA_window == null){ 
		 alert(" ※ 윈도우 XP SP2 또는 인터넷 익스플로러 7 사용자일 경우에는 \n    화면 상단에 있는 팝업 차단 알림줄을 클릭하여 팝업을 허용해 주시기 바랍니다. \n\n※ MSN,야후,구글 팝업 차단 툴바가 설치된 경우 팝업허용을 해주시기 바랍니다.");
    }

	if(isLocal)	frm.action = '/www/jsp/auth/namecheck_request_local.jsp';
	else frm.action = '/www/jsp/auth/namecheck_request.jsp';
	frm.target = 'CbaV2Window';
	frm.submit();
}
function openGPINWindow(frm){
	CBA_window = window.open('', 'GpinWindow', 'width=410, height=450, resizable=0, scrollbars=no, status=0, titlebar=0, toolbar=0, left=300, top=200' );

    if(CBA_window == null){ 
		 alert(" ※ 윈도우 XP SP2 또는 인터넷 익스플로러 7 사용자일 경우에는 \n    화면 상단에 있는 팝업 차단 알림줄을 클릭하여 팝업을 허용해 주시기 바랍니다. \n\n※ MSN,야후,구글 팝업 차단 툴바가 설치된 경우 팝업허용을 해주시기 바랍니다.");
    }

	if(isLocal)	frm.action = '/www/jsp/auth/gpin_request_local.jsp';
	else frm.action = '/www/jsp/auth/gpin_request.jsp';
	frm.target = 'GpinWindow';
	frm.submit();
}
//modal 표시
function showModal(txt){
	txt = txt || '';
	
	try{
    	$.blockUI({ message: txt }); 
	}catch(e){}
}

//modal 숨기기
function hideModal(){
	try{
		$.unblockUI();
	}catch(e){}
}

//화면 확대축소
var _view_scale = 1;

function scaleIn() {
	_view_scale *= 1.25;
	zoom(_view_scale);
}
function scaleOut() {
	_view_scale /= 1.25;
	zoom(_view_scale);
}
 
function zoom(scale) {
	var body = document.body;
	body.style.zoom = scale;  // IE
	body.style.webkitTransform = 'scale('+scale+')';  // Webkit(chrome)
	body.style.webkitTransformOrigin = '0 0';
	body.style.mozTransform = 'scale('+scale+')';  // Mozilla(firefox)
	body.style.mozTransformOrigin = '0 0';
	body.style.oTransform = 'scale('+scale+')';  // Opera
	body.style.oTransformOrigin = '0 0';
}

/*
 * input 태그에 숫자만 입력 받는 event 등록
 * */
function inputNumberOnly(idArray){
	if($.isArray(idArray)){
		$(idArray).each(function(){
			$('#' + this).keydown(function(e){
				
				// Allow: backspace, delete, tab, escape, enter, ctrl+A and .
				if ($.inArray(e.keyCode, [46, 8, 9, 27, 13, 110, 190]) !== -1 ||
						// Allow: Ctrl+A
						(e.keyCode == 65 && e.ctrlKey === true) || 
						// Allow: home, end, left, right
						(e.keyCode >= 35 && e.keyCode <= 39) ||
						// Allow: numLock keycodes	
						(e.keyCode >= 96 && e.keyCode <= 105)) {
					// let it happen, don't do anything
					return;
				}
				
				var charValue = String.fromCharCode(e.keyCode)
				, valid = /^[0-9]+$/.test(charValue);
				
				if (!valid) {
					e.preventDefault();
				}
			});
		});
	}
}

/*
 * Detect mobile browser
 * @return true : mobile, false : else 
 * */
function isMobileBrowser(){
	var a = navigator.userAgent||navigator.vendor||window.opera;
	
	if(/(android|bb\d+|meego).+mobile|avantgo|bada\/|blackberry|blazer|compal|elaine|fennec|hiptop|iemobile|ip(hone|od)|iris|kindle|lge |maemo|midp|mmp|mobile.+firefox|netfront|opera m(ob|in)i|palm( os)?|phone|p(ixi|re)\/|plucker|pocket|psp|series(4|6)0|symbian|treo|up\.(browser|link)|vodafone|wap|windows ce|xda|xiino/i.test(a)||/1207|6310|6590|3gso|4thp|50[1-6]i|770s|802s|a wa|abac|ac(er|oo|s\-)|ai(ko|rn)|al(av|ca|co)|amoi|an(ex|ny|yw)|aptu|ar(ch|go)|as(te|us)|attw|au(di|\-m|r |s )|avan|be(ck|ll|nq)|bi(lb|rd)|bl(ac|az)|br(e|v)w|bumb|bw\-(n|u)|c55\/|capi|ccwa|cdm\-|cell|chtm|cldc|cmd\-|co(mp|nd)|craw|da(it|ll|ng)|dbte|dc\-s|devi|dica|dmob|do(c|p)o|ds(12|\-d)|el(49|ai)|em(l2|ul)|er(ic|k0)|esl8|ez([4-7]0|os|wa|ze)|fetc|fly(\-|_)|g1 u|g560|gene|gf\-5|g\-mo|go(\.w|od)|gr(ad|un)|haie|hcit|hd\-(m|p|t)|hei\-|hi(pt|ta)|hp( i|ip)|hs\-c|ht(c(\-| |_|a|g|p|s|t)|tp)|hu(aw|tc)|i\-(20|go|ma)|i230|iac( |\-|\/)|ibro|idea|ig01|ikom|im1k|inno|ipaq|iris|ja(t|v)a|jbro|jemu|jigs|kddi|keji|kgt( |\/)|klon|kpt |kwc\-|kyo(c|k)|le(no|xi)|lg( g|\/(k|l|u)|50|54|\-[a-w])|libw|lynx|m1\-w|m3ga|m50\/|ma(te|ui|xo)|mc(01|21|ca)|m\-cr|me(rc|ri)|mi(o8|oa|ts)|mmef|mo(01|02|bi|de|do|t(\-| |o|v)|zz)|mt(50|p1|v )|mwbp|mywa|n10[0-2]|n20[2-3]|n30(0|2)|n50(0|2|5)|n7(0(0|1)|10)|ne((c|m)\-|on|tf|wf|wg|wt)|nok(6|i)|nzph|o2im|op(ti|wv)|oran|owg1|p800|pan(a|d|t)|pdxg|pg(13|\-([1-8]|c))|phil|pire|pl(ay|uc)|pn\-2|po(ck|rt|se)|prox|psio|pt\-g|qa\-a|qc(07|12|21|32|60|\-[2-7]|i\-)|qtek|r380|r600|raks|rim9|ro(ve|zo)|s55\/|sa(ge|ma|mm|ms|ny|va)|sc(01|h\-|oo|p\-)|sdk\/|se(c(\-|0|1)|47|mc|nd|ri)|sgh\-|shar|sie(\-|m)|sk\-0|sl(45|id)|sm(al|ar|b3|it|t5)|so(ft|ny)|sp(01|h\-|v\-|v )|sy(01|mb)|t2(18|50)|t6(00|10|18)|ta(gt|lk)|tcl\-|tdg\-|tel(i|m)|tim\-|t\-mo|to(pl|sh)|ts(70|m\-|m3|m5)|tx\-9|up(\.b|g1|si)|utst|v400|v750|veri|vi(rg|te)|vk(40|5[0-3]|\-v)|vm40|voda|vulc|vx(52|53|60|61|70|80|81|83|85|98)|w3c(\-| )|webc|whit|wi(g |nc|nw)|wmlb|wonu|x700|yas\-|your|zeto|zte\-/i.test(a.substr(0,4))){
		return true;
	}
	
	return false;
}

//새창 아이콘
$(function(){
	
	//console.log($('#gnb').data('linkIcon'));

	$('#gnb a, #lnb a').each(function(){
		var _t = $.trim($(this).attr('target')),
			_dep = $(this).data('menuDepth');
		
		if('_blank' == _t && '1' != _dep){
			$(this).html($(this).html() 
				+ '<img src="/_static/www/img/icon_link.gif" alt="새창 아이콘" style="margin: 7px 0 0 4px;"/>');
		}
	});

	//댓글 iframe resize
	$(window).on('message', function(e){		
		try{
			var obj = e.originalEvent.data;
			if(obj && typeof obj == 'string'){
				obj = $.parseJSON(obj);

				if(obj.from){
					if(obj.from == 'cmt'){
						if($('#reply_frame').height() < 665){
							$('#reply_frame').css({
								"height" : obj.height
							});
						}
					}
				}
			}
		}catch(e){}
	});
});

/* 필수항목 validate id */
function _validateId(contentField) {
	return $.trim($('#' + contentField).val()).length > 0 ? true : false;
}

function _validateIdFlag(contentField) {
	if($.trim($('#' + contentField).val()).length == 0) {
		alert($('#' + contentField).parent().parent().find('th').text()+'을(를) 입력하세요.');
		$('#' + contentField).focus();
		return false;
	}
	
	return true;
}

function _validateIdArray(contentField) {
	for(i = 0; i < contentField.length; i++) {
		if($.trim($('#' + contentField[i]).val()).length == 0) {
			alert($('#' + contentField[i]).parent().parent().find('th').text()+'을(를) 입력하세요.');
			$('#' + contentField[i]).focus();
			return false;
		}
	}
	
	return true;
}

/* 필수항목 validate name */
function _validateNm(contentFieNm) {
	return $('[name=' + contentFieNm + ']').is(':checked');
}

/* 비밀번호패턴 정규식 */
function isValidFormPassword(pw) {
	if (!chkPwExp.test(pw)) {
		return false;
	}
	
	return true;
}

/* 등록, 수정, 삭제 confirm */
function _confirm(crud) {
	var msg = "";
	
	if(crud == 'C') msg = "등록 하시겠습니까?";
	if(crud == 'U') msg = "수정 하시겠습니까?";
	if(crud == 'D') msg = "삭제 하시겠습니까?";
	if(crud == 'R') msg = "취소 하시겠습니까?";

	return msg;
}

/* 숫자만 추출 */
function getNumber(input) {
	var str = input.replace(/[^0-9]/g, '');

	return str;
}

/* Input 숫자만 입력 허용 */
function chkNumber(event) {
	if (event.key >= 0 && event.key <= 9) {
		return true;
	} else {
		return false;
	}
}