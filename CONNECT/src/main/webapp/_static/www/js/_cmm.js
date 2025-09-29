$(document).ready(function(){
	$('.board_top_tab a').each(function(){
		idx = $(this).data('tabMenuIdx');

		if (_p_path.indexOf('/' + idx + '/') != -1){
			$(this).parent().addClass('tab_click');
		}
	});
	
	$('.owl_list_top a').each(function(){
		idx = $(this).data('tabMenuIdx');
		
		if (_p_path.indexOf('/' + idx + '/') != -1){
			$(this).addClass('on');
		}
	});
});

/* 인쇄 공통 */
function info_print(val) {
	var printPop = window.open('/www/jsp/print.jsp?menuIdx='+val, 'printPop', 'height=' + screen.height + ',width=' + screen.width + 'fullscreen=yes');
}

function is_ie() {
	if(navigator.userAgent.toLowerCase().indexOf("chrome") != -1) return false;
	if(navigator.userAgent.toLowerCase().indexOf("msie") != -1) return true;
	if(navigator.userAgent.toLowerCase().indexOf("windows nt") != -1) return true;
	return false;
}

function snsShared(shareType) {
	var url = location.href;
	var text = document.title;
	
	if(shareType == 'qr') {
		$('.qrBox > img').attr('src','https://chart.googleapis.com/chart?cht=qr&chs=150x150&chl='+encodeURIComponent(url));
		$(".qrBox > img").attr('alt', text + ' 바로가기 QR코드 URL : ' + url);
	} else if(shareType == 'kakao') {
		href ='https://story.kakao.com/share?url=' + encodeURIComponent(url);
		window.open(href, 'kakaoStoryShare', 'width=720, height=600, scrollbars=yes, resizable=yes');
	} else if(shareType == 'naver') {
		href = 'http://share.naver.com/web/shareView.nhn?url=' +  encodeURIComponent(url) + '&title=' + encodeURIComponent(text);
		window.open(href, 'blogShare', 'width=400, height=450, scrollbars=yes, resizable=yes');
	} else if(shareType == 'facebook') {
		href = 'https://www.facebook.com/sharer/sharer.php?u=' + encodeURIComponent(url);
		window.open(href, 'facebookShare', 'width=640, height=340, scrollbars=yes, resizable=yes');
	} else if(shareType == 'twitter') {
		href = 'https://twitter.com/intent/tweet?text=' + encodeURIComponent(text) + '&url='+ encodeURIComponent(url);
		window.open(href, 'twitterShare', 'width=600, height=455, scrollbars=yes, resizable=yes');
	} else if(shareType == 'copy') {
		if( is_ie() ) {
			window.clipboardData.setData('Text', url);
			alert('현재 페이지 URL주소가 복사되었습니다.\n붙여넣기 또는 Ctrl+V로 사용 가능합니다.');
			return;
		}
		
		prompt('Ctrl+C를 눌러 복사하세요.', url);
	}
}