<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <title>게시판 수정</title>

    <!-- Bootstrap & jQuery -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.2/dist/css/bootstrap.min.css" />
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>

    <!-- Toast UI Editor -->
    <link rel="stylesheet" href="https://uicdn.toast.com/editor/latest/toastui-editor.min.css" />
    <script src="https://uicdn.toast.com/editor/latest/toastui-editor-all.min.js"></script>

    <style>
        .editor-card{ border:1px solid #e9ecef; border-radius:12px; padding:12px; }
    </style>
</head>
<body class="container my-4">
    <h2 class="mb-3">게시판 수정</h2>

    <form id="boardForm" onsubmit="return false;">
        <!-- PK -->
        <input type="hidden" name="boardIdx" id="boardIdx" value="${param.boardIdx}" />

        <div class="form-group">
            <label>제목</label>
            <input type="text" class="form-control" name="title" id="title"
                   value="${result.title}" placeholder="제목을 입력하세요" />
        </div>

        <!-- 서버 전송용 필드 -->
        <textarea id="contentMd" name="content" style="display:none;"><c:out value="${result.content}"/></textarea>
        <textarea id="contentHtml" name="contentHtml" style="display:none;"></textarea>

        <label class="mb-2 d-block">내용</label>
        <div class="editor-card">
            <div id="editor" style="height:460px;"></div>
        </div>

        <div class="mt-3">
            <button type="button" class="btn btn-primary" onclick="saveBoard()">저장</button>
            <button type="button" class="btn btn-outline-secondary"
                    onclick="location.href='/bbs/board/boardList'">목록</button>
        </div>
    </form>

    <script>
        // ===== 공통 상수 (기존 문법 유지) =====
        const API_BASE = '/api/bbs/board';
        const PK = 'boardIdx';
        let editor;

        // ===== Editor 초기화 =====
        $(document).ready(function () {
            const initialMD = $('#contentMd').val() || '';

            editor = new toastui.Editor({   
            	  el: document.querySelector('#editor'),
            	  height: '460px',
            	  initialEditType: 'wysiwyg',
            	  hideModeSwitch: true,          // ← 모드 전환 숨기고 WYSIWYG 고정
            	  placeholder: '내용을 입력해주세요...',
            	  toolbarItems: [
            	    ['heading','bold','italic','strike'],
            	    ['hr','quote'],
            	    ['ul','ol','task','indent','outdent'],
            	    ['table','image','link'],
            	    ['code','codeblock']
            	  ],  
                hooks: {
                	  addImageBlobHook: function (blob, callback) {
                	    const fd = new FormData();
                	    fd.append('file', blob);

                	    $.ajax({
                	        url: '/api/common/file/upload',
                	        type: 'POST',
                	        data: fd,
                	        processData: false,
                	        contentType: false,
                	        dataType: 'text',  
                	        success: function (url) {
	                	        if (!url || url === 'error') { 
	                	        	alert('이미지 업로드 실패'); 
	                	        	return; 
	                	        }
	
	                	        // WYSIWYG이 아니면 강제 전환
	                	        if (editor.getCurrentMode && editor.getCurrentMode() !== 'wysiwyg') {
	                	            editor.changeMode('wysiwyg', true);
	                	        }

                	        // alt 간단 정제
                	        var alt = (blob && blob.name ? blob.name : 'image')
                	                    .replace(/\.[^/.]+$/, '')
                	                    .replace(/[\[\]\(\)!\\]/g, ' ')
                	                    .trim();
                	        // ✅ 콜백 대신 에디터 명령으로 이미지 삽입 (항상 <img>로 들어감)
                	        editor.exec('addImage', { imageUrl: url, altText: alt });
                	        },
                	        error: function (xhr) {
                	        	alert('이미지 업로드 실패: ' + xhr.status);
                	        }
                	    });
                	    // 기본(텍스트) 삽입 막기
                	    return false;
                	  }
                 }
            });
            
            if (editor.changeMode) editor.changeMode('wysiwyg', true);

            // PK가 있으면 상세 조회 → 에디터/필드 세팅
            const id = $('#' + PK).val();
            if (id) {
                readBoard(id);
            } else if (initialMD) {
                // 신규 진입 + SSR 값이 있으면 초기 세팅 (fallback)
                editor.setHTML(initialMD);
                $('#contentHtml').val(initialMD);
            }
        });

        // ===== READ (기존 패턴 유지) =====
        function readBoard(id) {
            const sendData = {};
            sendData[PK] = id;

            $.ajax({
                url: API_BASE + '/selectBoardDetail',
                type: 'post',
                contentType: 'application/json',
                dataType: 'json',
                data: JSON.stringify(sendData),
                success: function (map) {
                    // 서버 응답 호환: result / board / data / map 자체
                    const result = map.result || map.board || map.data || map;
                    if (!result) return;

                    // 제목
                    $('#title').val(result.title || '');

                    // 본문: HTML 우선, 없으면 MD
                    const html = result.contentHtml || result.content || '';
                    const md   = result.markdown || result.contentMd || '';

                    if (html && html.trim() !== '') {
                        editor.setHTML(html);
                        $('#contentHtml').val(html);
                        $('#contentMd').val(''); // 선택
                    } else if (md && md.trim() !== '') {
                        editor.setMarkdown(md);
                        $('#contentMd').val(md);
                        $('#contentHtml').val(''); // 선택
                    } else {
                        editor.setHTML('');
                        $('#contentHtml').val('');
                        $('#contentMd').val('');
                    }
                },
                error: function () {
                    alert('조회 실패');
                }
            });
        }

        // ===== SAVE (그대로) =====
        function saveBoard() {
            const id = $('#' + PK).val();
            const url = id ? (API_BASE + '/updateBoard') : (API_BASE + '/insertBoard');

            if ($('#title').val().trim() === '') {
                alert('제목을 입력하세요.');
                return;
            }

            // Markdown / HTML 모두 준비 (서버에서 필요한 쪽 사용)
            const md = editor.getMarkdown();
            const html = editor.getHTML();
            $('#contentMd').val(md);
            $('#contentHtml').val(html);

            const payload = $('#boardForm').serializeObject();

            $.ajax({
                url: url,
                type: 'POST',
                contentType: 'application/json',
                dataType: 'json',
                data: JSON.stringify(payload),
                success: function () {
                    location.href = '/bbs/board/boardList';
                },
                error: function (xhr) {
                    alert('저장 실패: ' + (xhr.responseText || xhr.status));
                }
            });
        }

        // ===== 폼 → JSON (그대로) =====
        $.fn.serializeObject = function() {
            var obj = {};
            var arr = this.serializeArray();
            $.each(arr, function() { obj[this.name] = this.value; });
            return obj;
        };
    </script>
</body>
</html>  