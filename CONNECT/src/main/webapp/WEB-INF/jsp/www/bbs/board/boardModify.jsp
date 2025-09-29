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
        .attach-card{ border:1px dashed #ced4da; border-radius:12px; padding:12px; }
        .file-pill{ display:inline-flex; align-items:center; gap:8px; padding:6px 10px; border:1px solid #e9ecef; border-radius:999px; margin:4px; font-size:.9rem; background:#fff; }
        .file-pill .rm{ cursor:pointer; color:#dc3545; font-weight:700; }
        .muted{ color:#6c757d; }
    </style>
</head>
<body class="container my-4">
    <h2 class="mb-3">게시판 수정</h2>

    <form id="boardForm" onsubmit="return false;">
        <!-- PK -->
        <input type="hidden" name="boardIdx" id="boardIdx" value="${param.boardIdx}" />

        <div class="form-group">
            <label>제목</label>
            <input type="text" class="form-control" name="title" id="title" value="${result.title}" placeholder="제목을 입력하세요" />
        </div>

        <!-- 서버 전송용 필드 -->
        <textarea id="contentMd" name="content" style="display:none;"><c:out value="${result.content}"/></textarea>
        <textarea id="contentHtml" name="contentHtml" style="display:none;"></textarea>

        <!-- 파일그룹 키(첨부 연동 핵심) -->
        <input type="hidden" id="fileGrpId" name="fileGrpId" value="${result.fileGrpId}" />

        <label class="mb-2 d-block">내용</label>
        <div class="editor-card">
            <div id="editor" style="height:460px;"></div>
        </div>

        <!-- 첨부 영역 -->
        <div class="attach-card mt-3">
            <div class="d-flex align-items-center mb-2">
                <strong class="mr-2">첨부파일</strong>
                <span class="muted">단건·다건 업로드, 선택 삭제 지원</span>
            </div>

            <!-- 1) 대기(로컬 선택) 파일 -->
            <div class="mb-2">
                <input type="file" id="attachPicker" multiple />
                <button type="button" class="btn btn-outline-secondary btn-sm ml-1" onclick="addPendingFiles()">선택 추가</button>
                <button type="button" class="btn btn-primary btn-sm ml-1" onclick="uploadPending()">업로드</button>
            </div>
            <div id="pendingBox" class="mb-2"></div>

            <!-- 2) 서버에 이미 올라간 파일 목록(삭제 체크 가능) -->
            <div id="serverAttachBox" class="mt-2"></div>
        </div>

        <div class="mt-3">
            <button type="button" class="btn btn-primary" onclick="saveBoard()">저장</button>
            <button type="button" class="btn btn-outline-secondary" onclick="location.href='/bbs/board/boardList'">목록</button>
        </div>
    </form>

    <script>
        // ===== 공통 상수 (기존 문법 유지) =====
        const API_BASE = '/api/bbs/board';
        const PK = 'boardIdx';
        let editor;

        // 첨부 업로드 API (공용 파일 모듈)
        const FILE_API = {
            uploadMulti: '/api/com/file/uploadMulti',
            list: '/api/com/file/list',
            download: function(id){ return '/api/com/file/download/' + id; }
        };

        // 로컬에서 선택된(아직 업로드 전) 파일 큐
        let pendingFiles = []; // { file: File, id: number }

        // ===== Editor 초기화 =====
        $(document).ready(function () {
            const initialMD = $('#contentMd').val() || '';

            editor = new toastui.Editor({
                el: document.querySelector('#editor'),
                height: '460px',
                initialEditType: 'wysiwyg',
                hideModeSwitch: true,
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
                                if (!url || url === 'error') { alert('이미지 업로드 실패'); return; }
                                if (editor.getCurrentMode && editor.getCurrentMode() !== 'wysiwyg') { editor.changeMode('wysiwyg', true); }
                                var alt = (blob && blob.name ? blob.name : 'image').replace(/\.[^/.]+$/, '').replace(/[\[\]\(\)!\\]/g, ' ').trim();
                                editor.exec('addImage', { imageUrl: url, altText: alt });
                            },
                            error: function (xhr) { alert('이미지 업로드 실패: ' + xhr.status); }
                        });
                        return false;
                    }
                }
            });

            if (editor.changeMode) editor.changeMode('wysiwyg', true);

            // 상세 조회 → 본문/첨부 세팅
            const id = $('#' + PK).val();
            if (id) {
                readBoard(id);
            } else if (initialMD) {
                editor.setHTML(initialMD);
                $('#contentHtml').val(initialMD);
            }

            // 초기 첨부 목록(SSR로 fileGrpId가 내려왔을 때)
            const initGid = $('#fileGrpId').val();
            if (initGid) { renderServerAttach(initGid); }
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
                    const result = map.result || map.board || map.data || map;
                    if (!result) { return; }

                    $('#title').val(result.title || '');

                    const html = result.contentHtml || result.content || '';
                    const md = result.markdown || result.contentMd || '';

                    if (html && html.trim() !== '') {
                        editor.setHTML(html);
                        $('#contentHtml').val(html);
                        $('#contentMd').val('');
                    } else if (md && md.trim() !== '') {
                        editor.setMarkdown(md);
                        $('#contentMd').val(md);
                        $('#contentHtml').val('');
                    } else {
                        editor.setHTML('');
                        $('#contentHtml').val('');
                        $('#contentMd').val('');
                    }

                    // 첨부 fileGrpId 있으면 목록 호출
                    if (result.fileGrpId) {
                        $('#fileGrpId').val(result.fileGrpId);
                        renderServerAttach(result.fileGrpId);
                    }
                },
                error: function () { alert('조회 실패'); }
            });
        }

        // ===== 첨부: 로컬 선택 추가/삭제/렌더 =====
        function addPendingFiles(){
            const input = $('#attachPicker')[0];
            if (!input || !input.files || !input.files.length) {
                alert('추가할 파일을 선택하세요.');
                return;
            }
            // FileList는 불변 → 우리 큐에 복사
            for (let i = 0; i < input.files.length; i++) {
                pendingFiles.push({ file: input.files[i], id: Date.now() + Math.random() });
            }
            // 선택창 초기화
            $('#attachPicker').val('');
            renderPending();
        }

        function removePending(idx){
            pendingFiles.splice(idx, 1);
            renderPending();
        }

        function renderPending(){
            const box = $('#pendingBox').empty();
            if (pendingFiles.length === 0) {
                box.append($('<div/>').addClass('muted').text('업로드 대기 파일 없음'));
                return;
            }
            const wrap = $('<div/>');
            pendingFiles.forEach(function(item, i){
                const pill = $('<span/>').addClass('file-pill');
                pill.append($('<span/>').text(item.file.name + ' (' + formatBytes(item.file.size) + ')'));
                pill.append($('<span/>').addClass('rm').attr('title','제거').text('×').on('click', function(){ removePending(i); }));
                wrap.append(pill);
            });
            box.append(wrap);
        }

        // ===== 첨부: 서버 목록(선택 삭제 UI) =====
        function renderServerAttach(fileGrpId){
            $('#serverAttachBox').empty().append($('<div/>').addClass('muted').text('첨부 불러오는 중...'));
            $.ajax({
                url: FILE_API.list,
                type: 'post',
                contentType: 'application/json',
                dataType: 'json',
                data: JSON.stringify({ fileGrpId: fileGrpId }),
                success: function(res){
                    const list = res.result || [];
                    const box = $('#serverAttachBox').empty();

                    if (list.length === 0) {
                        box.append($('<div/>').addClass('muted').text('등록된 첨부 없음'));
                        return;
                    }

                    const ul = $('<ul/>').addClass('list-unstyled mb-0');
                    list.forEach(function(f){
                        const li = $('<li/>').addClass('mb-1 d-flex align-items-center');
                        const del = $('<input/>').attr('type','checkbox').addClass('mr-2 del-file').val(f.fileId);
                        const a = $('<a/>').attr('href', FILE_API.download(f.fileId)).text(f.orgFileNm);
                        const meta = $('<span/>').addClass('muted ml-2').text('(' + formatBytes(f.fileSize) + ')');
                        li.append(del).append(a).append(meta);
                        ul.append(li);
                    });
                    box.append($('<div/>').text('등록된 첨부')).append(ul)
                       .append($('<div/>').addClass('muted mt-1').text('※ 삭제할 파일은 체크 후 저장을 누르세요.'));
                },
                error: function(){ $('#serverAttachBox').empty().append($('<div/>').addClass('text-danger').text('첨부 목록 로드 실패')); }
            });
        }

        // ===== 첨부: 업로드 실행 (공용 파일 API 사용) =====
        function uploadPending(){
            if (pendingFiles.length === 0) {
                alert('업로드할 파일이 없습니다.');
                return;
            }
            const fd = new FormData();
            const gid = $('#fileGrpId').val();
            if (gid) { fd.append('fileGrpId', gid); }
            pendingFiles.forEach(function(item){ fd.append('files', item.file); });

            $.ajax({
                url: FILE_API.uploadMulti,
                type: 'post',
                data: fd,
                processData: false,
                contentType: false,
                success: function(res){
                    // 서버에서 최종 그룹ID 수신 → 숨김 필드 업데이트
                    if (res.fileGrpId) {
                        $('#fileGrpId').val(res.fileGrpId);
                        renderServerAttach(res.fileGrpId);
                    }
                    // 대기 큐 비움
                    pendingFiles = [];
                    renderPending();
                    alert('업로드 완료');
                },
                error: function(){ alert('업로드 실패'); }
            });
        }

        // ===== SAVE (그대로 + fileGrpId, deleteFileIds 포함) =====
        function saveBoard() {
            const id = $('#' + PK).val();
            const url = id ? (API_BASE + '/updateBoard') : (API_BASE + '/insertBoard');

            if ($('#title').val().trim() === '') {
                alert('제목을 입력하세요.');
                return;
            }
            if (pendingFiles.length > 0) {
                if (!confirm('업로드 대기 파일이 있습니다. 먼저 업로드하시겠습니까?')) {
                    // 그대로 진행 가능하지만, 보통 업로드 후 저장 권장
                }
            }

            const md = editor.getMarkdown();
            const html = editor.getHTML();
            $('#contentMd').val(md);
            $('#contentHtml').val(html);

            // 삭제 체크된 파일 ID 수집
            const deleteIds = [];
            $('.del-file:checked').each(function(){ deleteIds.push($(this).val()); });

            const payload = $('#boardForm').serializeObject();
            if (deleteIds.length > 0) { payload.deleteFileIds = deleteIds; }

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

        // ===== 유틸 =====
        function formatBytes(bytes){
            if (!bytes && bytes !== 0) { return ''; }
            const units = ['B','KB','MB','GB','TB'];
            let i = 0, n = parseFloat(bytes);
            while (n >= 1024 && i < units.length - 1) { n /= 1024; i++; }
            return (Math.round(n * 10) / 10) + units[i];
        }
    </script>
</body>
</html>