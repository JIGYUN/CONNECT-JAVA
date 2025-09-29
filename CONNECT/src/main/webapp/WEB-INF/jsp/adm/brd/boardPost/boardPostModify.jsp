<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>

<link rel="stylesheet" href="https://uicdn.toast.com/editor/latest/toastui-editor.min.css" />
<script src="https://uicdn.toast.com/editor/latest/toastui-editor-all.min.js"></script>

<style>
    :root{ --bg:#f6f8fb; --card:#fff; --line:#e9edf3; --text:#0f172a; --muted:#6b7280; --primary:#1f6feb; }
    body{ background:var(--bg); }
    .page-title{ font-size:28px; font-weight:700; color:var(--text); }
    .toolbar{ display:flex; gap:8px; margin:12px 0 18px; flex-wrap:wrap; }
    .card{ background:var(--card); border:1px solid var(--line); border-radius:16px; box-shadow:0 2px 8px rgba(15,23,42,.04); }
    .card .card-body{ padding:20px; }
    .form-label{ font-weight:600; color:var(--muted); }
    .form-control,.form-select{ border-radius:12px; border-color:var(--line); }
    .form-control:focus,.form-select:focus{ border-color:var(--primary); box-shadow:0 0 0 .15rem rgba(31,111,235,.15); }
    .btn{ border-radius:12px; }
</style>

<section>
    <h2 class="page-title">게시글 <span id="pageTitle" class="text-muted" style="font-weight:600;font-size:18px;">수정</span></h2>

    <div class="toolbar">
        <button class="btn btn-primary" type="button" onclick="savePost()">저장</button>
        <c:if test="${not empty param.postId}">
            <button class="btn btn-outline-danger" type="button" onclick="deletePost()">삭제</button>
        </c:if>  
        <a class="btn btn-outline-secondary" href="/adm/brd/boardPost/boardPostList">목록</a>
    </div> 

    <form id="postForm" class="card" autocomplete="off">
        <input type="hidden" name="postId" id="postId" value="${param.postId}"/>
        <input type="hidden" name="contentMd" id="contentMd"/>
        <input type="hidden" name="contentHtml" id="contentHtml"/>

        <div class="card-body">
            <div class="row g-3">
                <div class="col-md-4">
                    <label for="boardId" class="form-label">게시판</label>
                    <select class="form-select" name="boardId" id="boardId"></select>
                </div>
                <div class="col-md-6">
                    <label for="title" class="form-label">제목</label>
                    <input type="text" class="form-control" name="title" id="title" placeholder="제목을 입력"/>
                </div>
                <div class="col-md-2">
                    <label for="postSttsCd" class="form-label">상태</label>
                    <select class="form-select" name="postSttsCd" id="postSttsCd">
                        <option value="PUBLISHED">게시</option>
                        <option value="DRAFT">임시저장</option>
                        <option value="HIDDEN">숨김</option>
                    </select>
                </div>
                <div class="col-md-3">
                    <label for="pinnedDt" class="form-label">고정 시작</label>
                    <input type="datetime-local" class="form-control" name="pinnedDt" id="pinnedDt"/>
                </div>
            </div>

            <div class="mt-3">
                <label class="form-label">본문</label>
                <div id="editor" style="height:420px;"></div>
            </div>
        </div>
    </form>
</section>

<script>
    const API_POST  = '/api/brd/boardPost';
    const API_BOARD = '/api/brd/boardDef';
    const PK = 'postId';
    let editor;

    $(function(){
        editor = new toastui.Editor({
            el: document.querySelector('#editor'),
            height: '420px',
            initialEditType: 'markdown',
            previewStyle: 'vertical',
            placeholder: '내용을 입력해주세요...'
        });

        loadBoards().then(function(){
            const id = $('#' + PK).val();
            if (id) { readPost(id); $('#pageTitle').text('수정'); }
            else {
                $('#pageTitle').text('등록');
                const u = new URL(location.href);
                const bid = u.searchParams.get('boardId');
                if (bid) $('#boardId').val(bid);
            }
        });
    });

    function loadBoards(){
        return $.ajax({
            url: API_BOARD + '/selectBoardDefList',
            type:'post',
            contentType:'application/json',
            data: JSON.stringify({}),
            success: function(map){
                const list = map.result || map.rows || [];
                let html = '';
                for (let i = 0; i < list.length; i++) {
                    const r  = list[i];
                    const id = r.boardId || r.BOARD_ID;
                    const nm = (r.boardNm || r.BOARD_NM || r.title || '');
                    const cd = (r.boardCd || r.BOARD_CD || '');
                    const label = nm ? (nm + (cd ? ' (' + cd + ')' : '')) : (cd || '');
                    html += '<option value="' + (id != null ? id : '') + '">' + label + '</option>';
                }
                $('#boardId').html(html);
            }
        });
    }

    function readPost(id){
        const body = {}; body[PK] = id;
        $.ajax({
            url: API_POST + '/selectBoardPostDetail',
            type:'post',
            contentType:'application/json',
            dataType:'json',
            data: JSON.stringify(body),
            success: function(map){
                const r = map.result || map.post || map;
                if(!r) return;
                $('#boardId').val(r.boardId || r.BOARD_ID);
                $('#title').val(r.title || r.TITLE || '');
                $('#postSttsCd').val(r.postSttsCd || r.POST_STTS_CD || 'PUBLISHED');

                let pinned = r.pinnedDt || r.PINNED_DT;
                if (pinned) { try { pinned = pinned.replace(' ', 'T').substring(0,16); } catch(e){} }
                $('#pinnedDt').val(pinned || '');

                const html = r.contentHtml || r.CONTENT_HTML || '';
                const md   = r.contentMd   || r.CONTENT_MD   || '';
                if (html) editor.setHTML(html); else if (md) editor.setMarkdown(md);
            },
            error: function(){ alert('조회 중 오류'); }
        });
    }

    function savePost(){
        const id = $('#' + PK).val();
        const url = id ? (API_POST + '/updateBoardPost') : (API_POST + '/insertBoardPost');

        if (!$('#boardId').val()) { alert('게시판을 선택하세요.'); $('#boardId').focus(); return; }
        if (!$('#title').val())   { alert('제목을 입력하세요.');   $('#title').focus();   return; }

        $('#contentMd').val(editor.getMarkdown());
        $('#contentHtml').val(editor.getHTML());

        const formData = $('#postForm').serializeObject();
        $.ajax({
            url: url,
            type:'post',
            contentType:'application/json',
            dataType:'json',
            data: JSON.stringify(formData), 
            success: function(){ location.href='/adm/brd/boardPost/boardPostList'; },
            error: function(){ alert('저장 중 오류'); }
        });
    }

    function deletePost(){
        const id = $('#' + PK).val();
        if (!id) { alert('삭제할 대상의 PK가 없습니다.'); return; }
        if (!confirm('정말 삭제하시겠습니까?')) return;

        const body = {}; body[PK] = id;
        $.ajax({
            url: API_POST + '/deleteBoardPost',
            type:'post',
            contentType:'application/json',
            data: JSON.stringify(body),
            success: function(){ alert('삭제 완료'); location.href='/adm/brd/boardPost/postList'; },
            error: function(){ alert('삭제 중 오류'); }
        });
    }

    $.fn.serializeObject = function(){  
        let obj = {}; const arr = this.serializeArray();
        $.each(arr, function(){ obj[this.name] = this.value; });
        return obj;
    };
</script>