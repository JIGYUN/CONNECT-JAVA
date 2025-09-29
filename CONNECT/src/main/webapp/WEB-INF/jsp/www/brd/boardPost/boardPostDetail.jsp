<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>

<!-- Toast UI Viewer (뷰어 전용) -->
<link rel="stylesheet" href="https://uicdn.toast.com/editor/latest/toastui-editor.min.css" />
<script src="https://uicdn.toast.com/editor/latest/toastui-editor-all.min.js"></script>

<!-- Bootstrap는 레이아웃 기준으로 이미 포함돼 있다고 가정 -->

<style>
    /* ===== Design Tokens ===== */
    :root{
        --bg:#f7f8fb;
        --card:#ffffff;
        --line:#e9edf3;
        --text:#0f172a;
        --muted:#64748b;
        --accent:#2563eb;

        --radius:18px;
        --shadow:0 6px 18px rgba(15,23,42,.06);

        /* spacing scale */
        --s-1:6px;   --s0:10px;  --s1:14px;  --s2:18px;
        --s3:24px;   --s4:32px;  --s5:40px;  --s6:56px;
    }

    body{ background:var(--bg); color:var(--text); }

    /* page container */
    .container-narrow{ max-width:920px; margin:0 auto; padding:var(--s4) var(--s2) var(--s6); }

    /* header */
    .page-header{ padding:var(--s2) 0 var(--s1); }
    .toolbar{ display:flex; gap:var(--s0); flex-wrap:wrap; }
    .btn{ border-radius:12px !important; }
    .btn-outline-secondary, .btn-outline-dark, .btn-outline-primary{ border-width:1px; }

    /* title & meta */
    .title{ font-size:30px; font-weight:800; letter-spacing:-.01em; margin:var(--s1) 0 var(--s2); }
    .meta{ display:flex; flex-wrap:wrap; align-items:center; gap:var(--s0); color:var(--muted); font-size:13px; }
    .meta .dot{ width:4px; height:4px; border-radius:50%; background:#cbd5e1; display:inline-block; margin:0 var(--s0); }

    /* card shells */
    .card{ background:var(--card); border:1px solid var(--line); border-radius:var(--radius); box-shadow:var(--shadow); }
    .content-card{ padding:var(--s4) var(--s4) var(--s3); }
    .divider{ height:1px; background:var(--line); margin:var(--s3) 0; }

    /* tags (optional) */
    .tags{ margin-top:var(--s1); }
    .tag{ display:inline-block; padding:6px 12px; border:1px solid var(--line); border-radius:999px; margin:6px 8px 0 0; font-size:12px; color:#334155; background:#fff; }

    /* toast viewer typography */
    .tui-editor-contents{ line-height:1.8; font-size:16px; color:var(--text); }
    .tui-editor-contents p{ margin:1.1em 0; }
    .tui-editor-contents h1{ font-size:28px; margin:1.2em 0 .6em; font-weight:800; }
    .tui-editor-contents h2{ font-size:24px; margin:1.1em 0 .5em; font-weight:700; }
    .tui-editor-contents h3{ font-size:20px; margin:1em 0 .5em; font-weight:700; }
    .tui-editor-contents img{ max-width:100%; border-radius:12px; display:block; margin:1.1em auto; }
    .tui-editor-contents blockquote{ border-left:3px solid #e2e8f0; margin:1.1em 0; padding:.1em 1em; color:#475569; background:#f8fafc; border-radius:8px; }
    .tui-editor-contents pre{ border-radius:12px; padding:14px 16px; }

    /* vote */
    .vote-row{ display:flex; justify-content:space-between; align-items:center; margin-top:var(--s3); }
    .vote-box{ display:flex; gap:var(--s1); align-items:center; }
    .vote-btn{ border:1px solid var(--line); background:#fff; padding:10px 14px; border-radius:12px; font-weight:700; line-height:1; }
    .vote-btn:hover{ box-shadow:0 6px 14px rgba(15,23,42,.06); transform:translateY(-1px); transition:.15s ease; }
    .vote-btn.active-like{ color:#fff; background:var(--accent); border-color:var(--accent); }
    .vote-btn.active-dislike{ color:#fff; background:#334155; border-color:#334155; }
    .net{ font-size:13px; color:var(--muted); }

    /* attachments */
    .attach{ padding:var(--s3) var(--s4); }
    .attach h6{ font-weight:800; font-size:14px; margin:0 0 var(--s1); }
    .attach ul{ list-style:none; padding:0; margin:0; }
    .attach li{ display:flex; justify-content:space-between; align-items:center; padding:12px 0; border-top:1px solid #f1f5f9; }
    .attach li:first-child{ border-top:none; }
    .attach .size{ color:var(--muted); font-size:12px; }

    /* comments (간격만 개선) */
    .cmt-wrap{ margin-top:var(--s3); }
    .cmt-card{ background:#fff; border:1px solid var(--line); border-radius:var(--radius); box-shadow:var(--shadow); padding:var(--s3); }
    .cmt-title{ font-weight:800; color:var(--text); margin-bottom:var(--s1); font-size:16px; }
    #cmtList > li{ padding:14px 0; border-top:1px solid #f1f5f9; }
    #cmtList > li:first-child{ border-top:none; }
    .replybox{ margin-left:22px; padding-left:12px; border-left:2px solid #eef2f7; }

    /* bottom nav */
    .nav-bottom{ display:flex; justify-content:space-between; gap:var(--s1); margin-top:var(--s3); }
</style>
<script>
    // 로그인 사용자
    window.CURRENT_USER_ID = '${sessionScope.loginUser.userId}';
    window.CURRENT_USER_NM = '${sessionScope.loginUser.userNm}';
</script>

<div class="container-narrow">
    <!-- 헤더 / 상단 툴바 -->
    <div class="page-header">
        <div class="toolbar">
            <a href="/brd/boardPost/boardPostList" class="btn btn-outline-secondary">목록</a>
            <c:if test="${not empty param.postId}">
                <a href="/brd/boardPost/boardPostModify?postId=${param.postId}" class="btn btn-outline-primary">수정</a>
            </c:if>
            <button class="btn btn-outline-dark" type="button" onclick="copyUrl()">링크복사</button>
        </div>
    </div>

    <!-- 본문 카드 -->
    <div class="card content-card">
        <div class="meta" id="meta">
            <!-- 작성자/일시/조회수는 로딩 후 채움 -->
        </div>
        <h1 class="title" id="title">제목</h1>
        <div class="tags" id="tags"></div>

        <div id="viewer" class="viewer"></div>

        <div class="divider"></div>

        <!-- 추천/비추천 + 공유 -->
        <div class="vote-row">
            <div class="vote-box" id="voteBox" data-target-ty="POST" data-group-ty="BOARD">
                <button type="button" class="vote-btn js-like">👍 <span class="js-like-cnt">0</span></button>
                <button type="button" class="vote-btn js-dislike">👎 <span class="js-dislike-cnt">0</span></button>
                <span class="net">NET <b class="js-net">0</b></span>
            </div>
            <div class="toolbar">
                <a class="btn btn-outline-secondary btn-sm" id="btnPrev" href="#">이전글</a>
                <a class="btn btn-outline-secondary btn-sm" id="btnNext" href="#">다음글</a>
            </div>
        </div>

        <!-- 첨부 -->
        <div class="attach" id="attachBox">
            <h6>첨부파일</h6>
            <div class="text-muted small">첨부가 없어요.</div>
        </div>
    </div>

    <!-- 댓글 -->
    <div class="cmt-wrap">
        <div class="cmt-card">
            <div class="cmt-title">댓글</div>
            <div class="d-flex align-items-start mb-2">
                <textarea id="cmtContent" class="form-control" rows="3" placeholder="댓글을 입력하세요."></textarea>
                <div class="ml-2 d-flex align-items-center">
                    <input type="checkbox" id="cmtSecret" class="mr-1"><label for="cmtSecret" class="mb-0">비밀</label>
                </div>
                <button class="btn btn-primary ml-2" type="button" onclick="cmtAddRoot()">등록</button>
            </div>
            <ul id="cmtList" class="list-unstyled mb-0"></ul>
        </div>
    </div>

    <!-- 하단 네비 -->
    <div class="nav-bottom">
        <a href="/brd/boardPost/boardPostList" class="btn btn-outline-secondary">목록으로</a>
        <c:if test="${not empty param.postId}">
            <a href="/brd/boardPost/boardPostModify?postId=${param.postId}" class="btn btn-primary">수정하기</a>
        </c:if>
    </div>
</div>

<script>
    /* ===== 상수/API 경로 ===== */
    const API_POST = '/api/brd/boardPost';
    const FILE_API = { list: '/api/com/file/list', download: id => '/api/com/file/download/' + id };
    const FEED_API = { count:'/api/feed/count', vote:'/api/feed/vote', view:'/api/feed/view' };
    const CMT_API  = {
        listByTarget:'/api/com/comment/listByTarget',
        insert:'/api/com/comment/insert',
        delete:'/api/com/comment/delete'
    };
    const CMT_TARGET_TY = 'BOARD_POST';

    /* ===== 상태 ===== */
    let viewer, postId = '${param.postId}', boardIdFromQuery = getParam('boardId');

    /* ===== 초기화 ===== */
    $(async function(){
        viewer = new toastui.Editor.factory({
            el: document.querySelector('#viewer'),
            viewer: true,
            height: 'auto',
            initialValue: '불러오는 중...'
        });

        if (!postId){ location.replace('/brd/boardPost/boardPostList'); return; }

        await loadDetail(postId);
        await increaseView(postId);
        await initVoteUI(postId);
        await loadComments();
    });

    /* ===== 유틸 ===== */
    function getParam(name){ const url = new URL(location.href); return url.searchParams.get(name); }
    function fmtBytes(bytes){
        if (bytes == null) return '';
        const u = ['B','KB','MB','GB']; let i=0; let n=+bytes;
        while(n>=1024 && i<u.length-1){ n/=1024; i++; }
        return (Math.round(n*10)/10)+u[i];
    }
    function copyUrl(){
        const t=document.createElement('textarea'); t.value=location.href; document.body.appendChild(t);
        t.select(); document.execCommand('copy'); t.remove(); alert('링크가 복사되었습니다.');
    }
    function safe(r, ...keys){
        for (let k of keys){ if (r[k] != null) return r[k]; }
        return '';
    }

    /* ===== 상세 로드 ===== */
    async function loadDetail(id){
        const res = await $.ajax({
            url: API_POST + "/selectBoardPostDetail",
            type: "post",
            contentType: "application/json",
            dataType: "json",
            data: JSON.stringify({ postId: id })
        });

        const r = res.result || res.boardPost || res;
        const title = safe(r, 'title','TITLE');
        const writer = safe(r, 'writerNm','WRITER_NM','userNm','USER_NM') || '익명';
        const created = safe(r, 'createdDt','CREATED_DT');
        const views = safe(r, 'viewCnt','VIEW_CNT') || 0;
        const boardId = safe(r, 'boardId','BOARD_ID');
        const fileGrpId = safe(r, 'fileGrpId','FILE_GRP_ID');
        const html = safe(r, 'contentHtml','CONTENT_HTML');
        const md   = safe(r, 'contentMd','CONTENT_MD');
        const tags = (safe(r, 'tagTxt','TAG_TXT') || '').split(',').map(s=>s.trim()).filter(Boolean);

        $('#title').text(title);
        $('#meta').html(
            '<span>'+ writer +'</span><span class="dot"></span>' +
            '<span>'+ (created || '') +'</span><span class="dot"></span>' +
            '<span>조회 '+ views +'</span>'
        );

    	 // loadDetail() 내부 렌더 부분 교체
        if (html && html.trim() !== '') {
            const $v = $('#viewer');
            $v.removeClass().addClass('tui-editor-contents viewer'); // 타이포 클래스
            $v.html(html);
        } else {
            if (!viewer) {
                viewer = new toastui.Editor.factory({
                    el: document.querySelector('#viewer'),
                    viewer: true,
                    height: 'auto',
                    initialValue: md || ''
                });
            } else {
                viewer.setMarkdown(md || '');
            }
        }
   
        // 태그
        const $tags = $('#tags').empty();
        tags.forEach(t => $tags.append($('<span/>').addClass('tag').text('# ' + t)));

        // 첨부
        renderAttach(fileGrpId);

        // 이전/다음 (있으면 링크 세팅) — 없으면 비활성화
        try{
            const nav = await $.ajax({
                url: API_POST + "/selectPrevNext",
                type: "post",
                contentType: "application/json",
                dataType: "json",
                data: JSON.stringify({ postId: id, boardId: boardId })
            });
            const prev = nav.prev, next = nav.next;
            if (prev && (prev.postId || prev.POST_ID)){
                $('#btnPrev').attr('href','/brd/boardPost/boardPostView?postId='+ (prev.postId || prev.POST_ID));
            } else { $('#btnPrev').addClass('disabled').attr('tabindex','-1'); }
            if (next && (next.postId || next.POST_ID)){
                $('#btnNext').attr('href','/brd/boardPost/boardPostView?postId='+ (next.postId || next.POST_ID));
            } else { $('#btnNext').addClass('disabled').attr('tabindex','-1'); }
        }catch(e){ $('#btnPrev,#btnNext').addClass('disabled').attr('tabindex','-1'); }

        // voteBox 메타 주입
        $('#voteBox').attr('data-target-id', id)
                     .attr('data-group-id', boardId ? boardId : (boardIdFromQuery || ''));
    }

    /* ===== 첨부 렌더 ===== */
    async function renderAttach(fileGrpId){
        const $box = $('#attachBox').empty().append('<h6>첨부파일</h6>');
        if (!fileGrpId){ $box.append('<div class="text-muted small">첨부가 없어요.</div>'); return; }

        try{
            const res = await $.ajax({
                url: FILE_API.list,
                type: 'post',
                contentType: 'application/json',
                dataType: 'json',
                data: JSON.stringify({ fileGrpId: fileGrpId })
            });
            const list = res.result || [];
            if (!list.length){ $box.append('<div class="text-muted small">첨부가 없어요.</div>'); return; }

            const ul = $('<ul/>');
            list.forEach(f=>{
                const id = f.fileId || f.FILE_ID;
                const nm = f.orgFileNm || f.ORG_FILE_NM;
                const sz = f.fileSize || f.FILE_SZ;
                const li = $('<li/>');
                const left = $('<div/>').append($('<a/>').attr('href', FILE_API.download(id)).text(nm));
                const right = $('<div/>').addClass('size').text(fmtBytes(sz));
                li.append(left).append(right);
                ul.append(li);
            });
            $box.append(ul);
        }catch(e){
            $box.append('<div class="text-danger small">첨부 불러오기 실패</div>');
        }
    }

    /* ===== 조회수 증가 ===== */
    async function increaseView(id){
        try{
            await $.ajax({
                url: FEED_API.view,
                method: 'POST',
                contentType: 'application/json',
                data: JSON.stringify({ targetTyCd:'POST', targetId:id, groupTyCd:'BOARD', groupId: $('#voteBox').data('group-id') })
            });
        }catch(e){}
    }

    /* ===== 투표 UI ===== */
    async function initVoteUI(id){
        const box = $('#voteBox');
        const ty  = box.data('target-ty'), gty = box.data('group-ty');
        const gid = box.data('group-id');

        // 카운트 초기화
        try{
            const res = await $.get(FEED_API.count, { targetTyCd:ty, targetId:id });
            if (res && res.ok){ applyVote(box, res.cnt.likeCnt || 0, res.cnt.dislikeCnt || 0, 0); }
        }catch(e){}

        // 클릭 핸들러
        $(document).on('click','.js-like, .js-dislike', async function(){
            const isLike = $(this).hasClass('js-like');
            const cur = box.data('state') || 0;
            let next = 0;
            if (isLike) next = (cur === 1 ? 0 : 1);
            else        next = (cur === -1 ? 0 : -1);

            try{
                const res = await $.ajax({
                    url: FEED_API.vote, method:'POST', contentType:'application/json',
                    data: JSON.stringify({
                        userId: window.CURRENT_USER_ID, targetTyCd:ty, targetId:id,
                        groupTyCd:gty, groupId:gid, newVal:next
                    })
                });
                if (res && res.ok){
                    applyVote(box, res.cnt.likeCnt, res.cnt.dislikeCnt, next);
                }
            }catch(e){}
        });
    }

    function applyVote(box, likeCnt, dislikeCnt, state){
        box.find('.js-like-cnt').text(likeCnt);
        box.find('.js-dislike-cnt').text(dislikeCnt);
        box.find('.js-net').text(likeCnt - dislikeCnt);
        box.data('state', state);
        box.find('.js-like').toggleClass('active-like', state===1);
        box.find('.js-dislike').toggleClass('active-dislike', state===-1);
    }

    /* ===== 댓글 ===== */
    async function loadComments(){
        try{
            const res = await $.ajax({
                url: CMT_API.listByTarget, type:'post', contentType:'application/json', dataType:'json',
                data: JSON.stringify({ targetTyCd: CMT_TARGET_TY, targetId: postId })
            });
            renderCommentList(res.result || []);
        }catch(e){ $('#cmtList').html('<li class="text-muted">댓글 로드 실패</li>'); }
    }

    function renderCommentList(list){
        const $ul = $('#cmtList').empty();
        if (!list.length){ $ul.append('<li class="text-muted">첫 댓글을 남겨보세요.</li>'); return; }
        list.forEach(r=>{
            const id = r.commentId || r.COMMENT_ID;
            const depth = r.depth || r.DEPTH || 0;
            const created = r.createdDt || r.CREATED_DT || '';
            const isSecret = (r.secretAt || r.SECRET_AT) === 'Y';
            const isDeleted = !!r.deletedDt || !!r.DELETED_DT;
            const userNm = r.userNm || r.USER_NM || ('User#' + (r.userId || r.USER_ID || ''));
            const li = $('<li/>').addClass('py-2').css('border-top','1px solid #f1f5f9');
            if (depth===1) li.css({marginLeft:'18px', paddingLeft:'12px', borderLeft:'2px solid #eef2f7'});

            const head = $('<div/>').addClass('d-flex align-items-center text-muted').css('gap','8px')
                .append($('<span/>').text(userNm))
                .append($('<span/>').text(created));
            const bodyTxt = isDeleted ? '삭제된 댓글입니다.' : (isSecret ? '비밀 댓글입니다.' : (r.content || r.CONTENT || ''));
            const body = $('<div/>').addClass('mt-1').text(bodyTxt);

            const actions = $('<div/>').addClass('mt-1');
            actions.append($('<button/>').addClass('btn btn-outline-secondary btn-sm').text('답글')
                .on('click',()=>openReplyBox(id)));
            if (String(window.CURRENT_USER_ID||'') === String(r.userId || r.USER_ID || '')){
                actions.append($('<button/>').addClass('btn btn-outline-danger btn-sm ml-1').text('삭제')
                    .on('click',()=>cmtDelete(id)));
            }

            if (!isDeleted) li.append(head).append(body).append(actions);
            else li.append(head).append(body);
            $ul.append(li);
        });
    }

    function openReplyBox(parentId){
        $('.replybox').remove();
        const box = $('<div/>').addClass('replybox mt-2 d-flex align-items-start');
        const ta = $('<textarea/>').addClass('form-control').attr('rows',3).attr('placeholder','답글을 입력하세요.');
        const sec = $('<label/>').addClass('ml-2 mb-0').append($('<input type="checkbox" class="mr-1">')).append('비밀');
        const btn = $('<button/>').addClass('btn btn-primary ml-2').text('등록').on('click', async ()=>{
            const content = ta.val().trim(); if (!content){ alert('내용을 입력하세요.'); return; }
            try{
                await $.ajax({
                    url: CMT_API.insert, type:'post', contentType:'application/json', dataType:'json',
                    data: JSON.stringify({
                        targetTyCd:CMT_TARGET_TY, targetId:postId,
                        parentCommentId: parentId, content: content,
                        secretAt: sec.find('input').is(':checked') ? 'Y' : 'N'
                    })
                });
                $('.replybox').remove(); loadComments();
            }catch(e){ alert('등록 실패'); }
        });
        $('#cmtList').append(box.append(ta).append(sec).append(btn));
    }

    async function cmtAddRoot(){
        const content = $('#cmtContent').val().trim(); if (!content){ alert('내용을 입력하세요.'); return; }
        try{
            await $.ajax({
                url: CMT_API.insert, type:'post', contentType:'application/json', dataType:'json',
                data: JSON.stringify({
                    targetTyCd:CMT_TARGET_TY, targetId:postId,
                    content:content, secretAt: $('#cmtSecret').is(':checked') ? 'Y' : 'N'
                })
            });
            $('#cmtContent').val(''); $('#cmtSecret').prop('checked', false); loadComments();
        }catch(e){ alert('등록 실패'); }
    }

    async function cmtDelete(commentId){
        if (!confirm('정말 삭제하시겠습니까?')) return;
        try{
            await $.ajax({
                url: CMT_API.delete, type:'post', contentType:'application/json', dataType:'json',
                data: JSON.stringify({ commentId })
            });
            loadComments();
        }catch(e){ alert('삭제 실패'); }
    }
</script>