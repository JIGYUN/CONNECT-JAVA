$.fn.serializeObject = function() {
    var result = {};
    var extend = function(i, element) {
        var node = result[element.name]
        if ("undefined" !== typeof node && node !== null) {
            if ($.isArray(node)) {
                node.push(element.value)
	        } else {
	            result[element.name] = [node, element.value]
	        }
        } else {
            result[element.name] = element.value
        }
    }

    $.each(this.serializeArray(), extend);
    return result;
}

function checkId(id) {
    var reg= /^[a-zA-z0-9-_]{6,12}$/;
    return reg.test(id);
}


function checkPw(pw) {
	var reg = /^(?=.*[a-zA-Z])(?=.*[0-9])(?=.*[!@#$%^&*?_]).{8,50}$/;
	return reg.test(pw);
}

//이메일 정규식 체크
function checkEmail(email) {
	var reg = /^[0-9a-zA-Z]([-_\.]?[0-9a-zA-Z])*@[0-9a-zA-Z]([-_\.]?[0-9a-zA-Z])*\.[a-zA-Z]{2,3}$/i;
	return reg.test(email);
}

function goLink(link) {
	location.href = link;
}

function openJusoPopup(){
	var pop = window.open("/mba/auth/jusoPopup","pop","width=590,height=420, scrollbars=yes, resizable=yes");
}

function jusoCallBack(roadFullAddr,roadAddrPart1,addrDetail,roadAddrPart2,engAddr, jibunAddr, zipNo, admCd, rnMgtSn, bdMgtSn,detBdNmList,bdNm,bdKdcd,siNm,sggNm,emdNm,liNm,rn,udrtYn,buldMnnm,buldSlno,mtYn,lnbrMnnm,lnbrSlno,emdNo){
    // 팝업페이지에서 주소입력한 정보를 받아서, 현 페이지에 정보를 등록합니다.
	$("#zip").val(zipNo);
    $("#detailAdres").val(roadAddrPart1);
    $("#detailAdres2").val(addrDetail);
}