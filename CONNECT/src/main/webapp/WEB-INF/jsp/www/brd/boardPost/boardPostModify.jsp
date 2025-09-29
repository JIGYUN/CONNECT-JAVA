<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>

<link rel="stylesheet" href="https://uicdn.toast.com/editor/latest/toastui-editor.min.css" />
<script src="https://uicdn.toast.com/editor/latest/toastui-editor-all.min.js"></script>

<style>
    :root{ --bg:#f6f8fb; --card:#ffffff; --line:#e9edf3; --text:#0f172a; --muted:#6b7280; }
    body{ background:var(--bg); }
    .page-title{ font-size:28px; font-weight:700; color:var(--text); margin-bottom:12px; }
    .toolbar{ display:flex; gap:10px; align-items:center; flex-wrap:wrap; margin:8px 0 18px; }
    .card{ background:var(--card); border:1px solid var(--line); border-radius:16px; box-shadow:0 2px 8px rgba(15,23,42,.05); padding:18px; }
    .form-label{ font-weight:600; color:#334155; }
    .btn,.form-select,.form-control{ border-radius:12px; }
    .attach-card{ background:var(--card); border:1px dashed var(--line); border-radius:16px; padding:14px; margin-top:14px; }
    .file-pill{ display:inline-flex; align-items:center; gap:8px; padding:6px 10px; border:1px solid var(--line); border-radius:999px; margin:4px; font-size:.9rem; background:#fff; }
    .file-pill .rm{ cursor:pointer; color:#dc3545; font-weight:700; }
    .muted{ color:var(--muted); }

    /* 댓글 */
    .cmt-wrap{ margin-top:20px; }
    .cmt-card{ background:#fff; border:1px solid #e9edf3; border-radius:14px; box-shadow:0 2px 8px rgba(15,23,42,.05); padding:14px; }
    .cmt-title{ font-weight:700; color:#0f172a; margin-bottom:10px; }
    .cmt-new{ display:flex; gap:8px; align-items:flex-start; margin:8px 0 14px; }
    .cmt-new textarea{ flex:1; height:80px; border-radius:10px; }
    .cmt-list{ margin:0; padding:0; list-style:none; }
    .cmt-item{ padding:12px 10px; border-top:1px solid #f1f4f9; }
    .cmt-item:first-child{ border-top:none; }
    .cmt-meta{ display:flex; gap:10px; font-size:.9rem; color:#6b7280; margin-bottom:6px; }
    .cmt-body{ white-space:pre-wrap; line-height:1.55; }
    .cmt-actions{ display:flex; gap:8px; margin-top:6px; }
    .cmt-actions .btn-sm{ padding:2px 8px; border-radius:10px; }
    .cmt-reply{ margin-top:10px; margin-left:24px; padding-left:12px; border-left:2px solid #eef2f7; }
    .cmt-muted{ color:#9aa4b2; }
    .cmt-secret{ display:flex; align-items:center; gap:6px; }
</style>

<!-- 로그인 사용자 ID/NM 주입 (없는 경우 빈값) -->
<script>
    window.CURRENT_USER_ID = '${sessionScope.loginUser.userId}';
    window.CURRENT_USER_NM = '${sessionScope.loginUser.userNm}';
</script>

<section>
    <h2 class="page-title">게시글 <span id="pageTitle" class="text-muted" style="font-size:16px;">등록</span></h2>

    <div class="toolbar">
        <button class="btn btn-primary" type="button" onclick="saveBoardPost()">저장</button>
        <c:if test="${not empty param.postId}">
            <button class="btn btn-outline-danger" type="button" onclick="deleteBoardPost()">삭제</button>
        </c:if>
        <a id="btnList" class="btn btn-outline-secondary" href="/brd/boardPost/boardPostList">목록</a>
    </div>

    <form id="boardPostForm" class="card" onsubmit="return false;">
        <input type="hidden" name="postId" id="postId" value="${param.postId}"/>
        <input type="hidden" name="fileGrpId" id="fileGrpId" value="${result.fileGrpId}"/>
        <!-- 선택 UI 제거: 메뉴에서 전달된 boardId만 사용 -->
        <input type="hidden" name="boardId" id="boardId" value="${param.boardId}"/>

        <div class="row g-3">
            <div class="col-12">
                <label for="title" class="form-label">제목</label>
                <input type="text" class="form-control" name="title" id="title" placeholder="제목을 입력하세요">
            </div>
            <div class="col-12">
                <label class="form-label">내용</label>
                <div id="editor" style="height: 460px;"></div>
                <input type="hidden" name="contentMd" id="contentMd"/>
                <input type="hidden" name="contentHtml" id="contentHtml"/>
            </div>
        </div>

        <div class="attach-card">
            <div class="d-flex align-items-center mb-2">
                <strong class="mr-2">첨부파일</strong>
                <span class="muted">다중 업로드 · 선택 삭제 지원</span>
            </div>

            <div class="mb-2">
                <input type="file" id="attachPicker" multiple />
                <button type="button" class="btn btn-outline-secondary btn-sm ml-1" onclick="addPendingFiles()">선택 추가</button>
                <button type="button" class="btn btn-outline-dark btn-sm ml-1" onclick="clearPending()">초기화</button>
            </div>
            <div id="pendingBox" class="mb-2"></div>

            <div id="serverAttachBox" class="mt-2"></div>
        </div>
    </form>

    <!-- 댓글 -->
    <div class="cmt-wrap">
        <div class="cmt-card">
            <div class="cmt-title">댓글</div>
            <div class="cmt-new">
                <textarea id="cmtContent" class="form-control" placeholder="댓글을 입력하세요."></textarea>
                <div class="cmt-secret">
                    <input type="checkbox" id="cmtSecret"/><label for="cmtSecret" class="mb-0">비밀</label>
                </div>
                <button type="button" class="btn btn-primary" onclick="cmtAddRoot()">등록</button>
            </div>
            <ul id="cmtList" class="cmt-list"></ul>
        </div>
    </div>
</section>

<script>
    const API_POST = '/api/brd/boardPost';
    const FILE_API = { list: '/api/com/file/list', download: function(id){ return '/api/com/file/download/' + id; } };
    const PK       = 'postId';
    let editor;
    let pendingFiles = [];

    /* 댓글 API */
    const CMT_API = {
        listByTarget: '/api/com/comment/listByTarget',
        insert:       '/api/com/comment/insert',
        update:       '/api/com/comment/update',
        delete:       '/api/com/comment/delete'
    };
    const CMT_TARGET_TY = 'BOARD_POST';
    function cmtTargetId(){ return $('#postId').val(); }

    $(document).ready(function () {
        // boardId 보정: 쿼리스트링 → hidden에 주입
        var qBoard = getParam('boardId');
        if (qBoard && !$('#boardId').val()) {
            $('#boardId').val(qBoard);
        }

        // 목록 버튼: 현재 boardId를 유지해 회귀
        $('#btnList').attr('href', '/brd/boardPost/boardPostList' + (qBoard ? ('?boardId=' + encodeURIComponent(qBoard)) : ''));

        editor = new toastui.Editor({
            el: document.querySelector('#editor'),
            height: '460px',
            initialEditType: 'markdown',
            previewStyle: 'vertical',
            placeholder: '내용을 입력해주세요...',
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
                            var alt = (blob && blob.name ? blob.name : 'image').replace(/\.[^/.]+$/, '').replace(/[\[\]\(\)!\\]/g, ' ').trim();
                            editor.exec('addImage', { imageUrl: url, altText: alt });
                        },
                        error: function (xhr) { alert('이미지 업로드 실패: ' + xhr.status); }
                    });
                    return false;
                }
            }
        });

        const id = $("#" + PK).val();
        if (id) {
            readBoardPost(id);
            $("#pageTitle").text("수정");
        } else {
            // 신규 등록 시: boardId 없으면 비정상 진입 → 저장 전에 가드
            $("#pageTitle").text("등록");
        }

        const initGid = $('#fileGrpId').val();
        if (initGid) { renderServerAttach(initGid); }
        renderPending();

        cmtLoad();
    });

    function getParam(name){
        const url = new URL(location.href);
        return url.searchParams.get(name);
    }

    function readBoardPost(id) {
        const sendData = {}; sendData[PK] = id;
        $.ajax({
            url: API_POST + "/selectBoardPostDetail",
            type: "post",
            contentType: "application/json",
            dataType: "json",
            data: JSON.stringify(sendData),
            success: function (map) {
                const r = map.result || map.boardPost || map;
                if (!r) return;
                // 서버 데이터 기준으로 hidden boardId 세팅
                $("#boardId").val(r.boardId || r.BOARD_ID);
                $("#title").val(r.title || r.TITLE || "");
                const html = r.contentHtml || r.CONTENT_HTML || '';
                const md   = r.contentMd   || r.CONTENT_MD   || '';
                if (html) editor.setHTML(html);
                else      editor.setMarkdown(md);
                if (r.fileGrpId || r.FILE_GRP_ID) {
                    const gid = r.fileGrpId || r.FILE_GRP_ID;
                    $("#fileGrpId").val(gid);
                    renderServerAttach(gid);
                }
            },
            error: function () { alert("조회 중 오류 발생"); }
        });
    }

    /* ===== 첨부(로컬 큐) ===== */
    function addPendingFiles(){
        const input = $('#attachPicker')[0];
        if (!input || !input.files || !input.files.length) { alert('추가할 파일을 선택하세요.'); return; }
        for (let i=0;i<input.files.length;i++){ pendingFiles.push({ file: input.files[i], id: Date.now() + Math.random() }); }
        $('#attachPicker').val('');
        renderPending();
    }

    function clearPending(){
        pendingFiles = [];
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

    /* ===== 첨부(서버 목록) ===== */
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

    /* ===== 저장(멀티파트) ===== */
    function saveBoardPost() {
        const id  = $("#" + PK).val();
        const url = id ? (API_POST + "/updateBoardPostWithFiles") : (API_POST + "/insertBoardPostWithFiles");

        if (!$('#boardId').val()) { alert("잘못된 접근입니다. (게시판 정보 없음)"); return; }
        if ($("#title").val() === "") { alert("제목을 입력해주세요."); $("#title").focus(); return; }
        const html = editor.getHTML().trim();
        if (html === "") { alert("내용을 입력해주세요."); return; }

        $("#contentMd").val(editor.getMarkdown());
        $("#contentHtml").val(html);

        const fd = new FormData();
        if (id) fd.append("postId", id);
        fd.append("boardId", $('#boardId').val());
        fd.append("title", $('#title').val());
        fd.append("content", $('#contentMd').val());
        fd.append("contentHtml", $('#contentHtml').val());
        if ($('#fileGrpId').val()) fd.append("fileGrpId", $('#fileGrpId').val());

        for (let i=0;i<pendingFiles.length;i++){ fd.append("files", pendingFiles[i].file); }
        $('.del-file:checked').each(function(){ fd.append("deleteFileIds", $(this).val()); });

        $.ajax({
            url: url,
            type: "post",
            data: fd,
            processData: false,
            contentType: false,
            success: function (res) {
                if (res && res.fileGrpId) { $('#fileGrpId').val(res.fileGrpId); }
                const b = $('#boardId').val();
                location.href = "/brd/boardPost/boardPostList" + (b ? ("?boardId=" + encodeURIComponent(b)) : "");
            },
            error: function (xhr) {
                alert("저장 중 오류 발생: " + (xhr.responseText || xhr.status));
            }
        });
    }

    function deleteBoardPost() {
        const id = $("#" + PK).val();
        if (!id) { alert("삭제할 대상이 없습니다."); return; }
        if (!confirm("정말 삭제하시겠습니까?")) return;

        const sendData = {}; sendData[PK] = id;

        $.ajax({
            url: API_POST + "/deleteBoardPost",
            type: "post",
            contentType: "application/json",
            dataType: "json",
            data: JSON.stringify(sendData),
            success: function () {
                const b = $('#boardId').val();
                alert("삭제 완료되었습니다.");
                location.href = "/brd/boardPost/boardPostList" + (b ? ("?boardId=" + encodeURIComponent(b)) : "");
            },
            error: function () { alert("삭제 중 오류 발생"); }
        });
    }

    /* ===== 댓글: 목록/등록/답글/삭제 ===== */
    function cmtLoad(){
        $.ajax({
            url: CMT_API.listByTarget,
            type: 'post',
            contentType: 'application/json',
            dataType: 'json',
            data: JSON.stringify({ targetTyCd: CMT_TARGET_TY, targetId: cmtTargetId() }),
            success: function(res){
                renderCommentList(res.result || []);
            },
            error: function(){ alert('댓글을 불러오지 못했습니다.'); }
        });
    }

    function safeUserName(r){
        var nm = r.userNm || r.USER_NM;
        if (nm && typeof nm === 'object') {
            nm = nm.userNm || nm.name || nm.nickNm || nm.nick || '';
        }
        if (!nm || nm === '[object Object]') {
            var uid = r.userId || r.USER_ID;
            nm = uid ? ('User#' + uid) : '익명';
        }
        return nm;
    }

    function isMine(r){
        if (r.me === true || r.ME === 'Y') return true;
        var uid = r.userId || r.USER_ID;
        return (window.CURRENT_USER_ID && uid && String(uid) === String(window.CURRENT_USER_ID));
    }

    function renderCommentList(list){
        const $ul = $('#cmtList').empty();
        if (!list.length){
            $ul.append($('<li/>').addClass('cmt-item cmt-muted').text('첫 댓글을 남겨보세요.'));
            return;
        }
        list.forEach(function(r){
            const id        = r.commentId || r.COMMENT_ID;
            const depth     = r.depth || r.DEPTH || 0;
            const created   = r.createdDt || r.CREATED_DT || '';
            const isSecret  = (r.secretAt || r.SECRET_AT) === 'Y';
            const isDeleted = !!r.deletedDt || !!r.DELETED_DT;
            const me        = isMine(r);

            const li = $('<li/>').addClass('cmt-item').toggleClass('cmt-reply', depth === 1);

            const meta = $('<div/>').addClass('cmt-meta')
                .append($('<span/>').text(safeUserName(r)))
                .append($('<span/>').addClass('cmt-muted').text(created));
            if (isSecret){ meta.append($('<span/>').addClass('badge badge-secondary').text('비밀')); }
            li.append(meta);

            const text = isDeleted ? '삭제된 댓글입니다.'
                        : isSecret ? '비밀 댓글입니다.'
                        : (r.content || r.CONTENT || '');
            li.append($('<div/>').addClass('cmt-body').text(text));

            if (!isDeleted){
                const actions = $('<div/>').addClass('cmt-actions');
                actions.append($('<button/>').addClass('btn btn-outline-secondary btn-sm').text('답글')
                    .on('click', function(){ openReplyBox(id); }));
                if (me){
                    actions.append($('<button/>').addClass('btn btn-outline-danger btn-sm').text('삭제')
                        .on('click', function(){ cmtDelete(id); }));
                }
                li.append(actions);
            }

            $ul.append(li);
        });
    }

    function cmtAddRoot(){
        const content = $('#cmtContent').val().trim();
        if (content === ''){ alert('내용을 입력하세요.'); return; }
        $.ajax({
            url: CMT_API.insert,
            type: 'post',
            contentType: 'application/json',
            dataType: 'json',
            data: JSON.stringify({
                targetTyCd: CMT_TARGET_TY,
                targetId:   cmtTargetId(),
                content:    content,
                secretAt:   $('#cmtSecret').is(':checked') ? 'Y' : 'N'
            }),
            success: function(){
                $('#cmtContent').val('');
                $('#cmtSecret').prop('checked', false);
                cmtLoad();
            },
            error: function(xhr){ alert('댓글 등록 실패: ' + (xhr.responseText || xhr.status)); }
        });
    }

    function openReplyBox(parentId){
        $('.cmt-replybox').remove();
        const box = $('<div/>').addClass('cmt-replybox cmt-reply');
        const ta  = $('<textarea/>').addClass('form-control').attr('rows',3).attr('placeholder','답글을 입력하세요.');
        const sec = $('<label/>').addClass('ml-2 mb-0').append(
            $('<input/>').attr('type','checkbox').addClass('mr-1')
        ).append('비밀');
        const btn = $('<button/>').attr('type','button').addClass('btn btn-primary btn-sm ml-2').text('등록')
            .on('click', function(){
                const content = ta.val().trim();
                const secret  = sec.find('input').is(':checked') ? 'Y' : 'N';
                if (content === ''){ alert('내용을 입력하세요.'); return; }
                cmtAddChild(parentId, content, secret);
            });

        const ctrl = $('<div/>').addClass('d-flex align-items-start mt-2').append(ta).append(sec).append(btn);
        $('#cmtList').append(box.append(ctrl));
    }

    function cmtAddChild(parentId, content, secretAt){
        $.ajax({
            url: CMT_API.insert,
            type: 'post',
            contentType: 'application/json',
            dataType: 'json',
            data: JSON.stringify({
                targetTyCd:      CMT_TARGET_TY,
                targetId:        cmtTargetId(),
                parentCommentId: parentId,
                content:         content,
                secretAt:        secretAt || 'N'
            }),
            success: function(){
                $('.cmt-replybox').remove();
                cmtLoad();
            },
            error: function(xhr){ alert('답글 등록 실패: ' + (xhr.responseText || xhr.status)); }
        });
    }

    function cmtDelete(commentId){
        if (!confirm('정말 삭제하시겠습니까?')) return;
        $.ajax({
            url: CMT_API.delete,
            type: 'post',
            contentType: 'application/json',
            dataType: 'json',
            data: JSON.stringify({ commentId: commentId }),
            success: function(){ cmtLoad(); },
            error: function(xhr){ alert('삭제 실패: ' + (xhr.responseText || xhr.status)); }
        });
    }

    /* serializeObject / util */
    $.fn.serializeObject = function () {
        var obj = {};
        var arr = this.serializeArray();
        $.each(arr, function () { obj[this.name] = this.value; });
        return obj;
    };

    function formatBytes(bytes){
        if (!bytes && bytes !== 0) { return ''; }
        const units = ['B','KB','MB','GB','TB'];
        let i = 0, n = parseFloat(bytes);
        while (n >= 1024 && i < units.length - 1) { n /= 1024; i++; }
        return (Math.round(n * 10) / 10) + units[i];
    }
</script>