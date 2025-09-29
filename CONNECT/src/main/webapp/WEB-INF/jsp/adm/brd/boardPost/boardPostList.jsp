<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<style>
    :root{ --bg:#f6f8fb; --card:#fff; --line:#e9edf3; --text:#0f172a; --muted:#6b7280; }
    body{ background:var(--bg); }
    .page-title{ font-size:28px; font-weight:700; color:var(--text); }
    .toolbar{ display:flex; gap:8px; margin:12px 0 18px; flex-wrap:wrap; align-items:center; }
    .table-card{ background:var(--card); border:1px solid var(--line); border-radius:16px; box-shadow:0 2px 8px rgba(15,23,42,.04); }
    .table{ margin-bottom:0; }
    .table thead th{ font-weight:700; color:#475569; background:#f3f5f8; border-bottom:1px solid var(--line); }
    .table tbody tr{ cursor:pointer; }
    .table tbody tr:hover{ background:#f9fbff; }
    .btn,.form-select,.form-control{ border-radius:12px; }
    #boardSel{ text-transform:none; color:inherit; }
</style>

<section>
    <h2 class="page-title">게시글 목록</h2>

    <div class="toolbar">
        <select id="boardSel" class="form-select" style="width:260px"></select>
        <input id="kw" class="form-control" placeholder="제목 검색" style="width:260px"/>
        <button class="btn btn-outline-secondary" type="button" id="btnSearch">검색</button>
        <button class="btn btn-primary ms-auto" type="button" onclick="goToPostModify()">WRITE</button>
    </div>

    <div class="table-responsive table-card">
        <table class="table table-hover align-middle">
            <thead>
                <tr>
                    <th style="width:90px;text-align:right;">ID</th>
                    <th>TITLE</th>
                    <th style="width:120px;">STATUS</th>
                    <th style="width:120px;">VIEWS</th>
                    <th style="width:200px;">CREATED</th>
                </tr>
            </thead>
            <tbody id="postListBody">
                <tr><td colspan="5" class="text-center text-muted">Loading…</td></tr>
            </tbody>
        </table>
    </div>
</section>

<script>
    const API_POST  = '/api/brd/boardPost';
    const API_BOARD = '/api/brd/boardDef';
    const PK_PARAM  = 'postId';

    $(function () {
        // 초기 로드: 게시판 목록 → 선택값 반영 → 목록 조회
        loadBoards().then(function () {
            bindEvents();
            reload();
        });
    });

    function bindEvents() {
        // 게시판 선택 시 즉시 갱신
        $('#boardSel').on('change', function () {
            reload();
        });
        // 검색 버튼
        $('#btnSearch').on('click', function () {
            reload();
        });
        // 엔터로 검색
        $('#kw').on('keyup', function (e) {
            if (e.key === 'Enter') reload();
        });
    }

    function text(v) {
        return (v == null ? '' : String(v));
    }

    function loadBoards() {
        return $.ajax({
            url: API_BOARD + '/selectBoardDefList',
            type: 'post',
            contentType: 'application/json',
            data: JSON.stringify({}),
            success: function (map) {
                const list = map.result || map.rows || [];
                let html = '<option value="">— 전체 게시판 —</option>';

                for (let i = 0; i < list.length; i++) {
                    const r  = list[i];
                    const id = r.boardId || r.BOARD_ID;
                    const nm = text(r.boardNm || r.BOARD_NM || r.title || '');
                    const cd = text(r.boardCd || r.BOARD_CD || '');
                    // nm 있으면 "nm (cd)", 없으면 "cd"만
                    const label = nm ? (nm + (cd ? ' (' + cd + ')' : '')) : (cd || '');
                    html += '<option value="' + (id != null ? id : '') + '">' + label + '</option>';
                }
                $('#boardSel').html(html);

                // URL의 boardId 우선 선택, 없으면 첫 게시판 자동 선택
                const u = new URL(window.location.href);
                const qBid = u.searchParams.get('boardId');
                if (qBid) {
                    $('#boardSel').val(qBid);
                } else if (list.length) {
                    const first = list[0].boardId || list[0].BOARD_ID;
                    if (first != null) $('#boardSel').val(String(first));
                }
            },
            error: function () {
                $('#boardSel').html('<option value="">(게시판 로드 실패)</option>');
            }
        });
    }

    function reload() {
        // 로딩 표시
        $('#postListBody').html('<tr><td colspan="5" class="text-center text-muted">Loading…</td></tr>');

        const boardId = $('#boardSel').val();
        const kw = $('#kw').val() || '';

        // 바인딩 편차 대비: 소/대문자 키 모두 전송
        const body = {};
        if (boardId) {
            body.boardId = Number(boardId);
            body.BOARD_ID = Number(boardId);
        }
        if (kw) {
            body.kw = kw;
            body.title = kw;
            body.TITLE = kw;
        }

        $.ajax({
            url: API_POST + '/selectBoardPostList',
            type: 'post',
            contentType: 'application/json',
            data: JSON.stringify(body),
            success: function (map) {
                const list = map.result || map.rows || [];
                renderRows(list);
            },
            error: function () {
                $('#postListBody').html('<tr><td colspan="5" class="text-center text-danger">목록 조회 오류</td></tr>');
            }
        });
    }

    function renderRows(list) {
        if (!list || !list.length) {
            $('#postListBody').html('<tr><td colspan="5" class="text-center text-muted">데이터가 없습니다.</td></tr>');
            return;
        }

        let html = '';
        for (let i = 0; i < list.length; i++) {
            const r = list[i];
            const id = r.postId || r.POST_ID;
            const title = text(r.title || r.TITLE);
            const stts = text(r.postSttsCd || r.POST_STTS_CD);
            const views = (r.viewCnt != null ? r.viewCnt : (r.VIEW_CNT != null ? r.VIEW_CNT : 0));
            let created = r.createdDt || r.CREATED_DT || '';
            if (created && typeof created === 'object') created = (created.value || String(created));

            html += '<tr onclick="goToPostModify(\'' + (id != null ? id : '') + '\')">'
                 +  '<td class="text-end">' + (id != null ? id : '') + '</td>'
                 +  '<td>' + title + '</td>'
                 +  '<td>' + stts + '</td>'
                 +  '<td>' + views + '</td>'
                 +  '<td>' + (created || '') + '</td>'
                 +  '</tr>';
        }
        $('#postListBody').html(html);
    }
   
    function goToPostModify(id) {
        const bid = $('#boardSel').val();
        let url = '/adm/brd/boardPost/boardPostModify';
        const q = [];
        if (id)  q.push(PK_PARAM + '=' + encodeURIComponent(id));
        if (bid) q.push('boardId=' + encodeURIComponent(bid));
        if (q.length) url += '?' + q.join('&');
        location.href = url;
    }
</script>