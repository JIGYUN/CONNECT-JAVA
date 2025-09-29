<%@ page language="java" contentType="text/html; charset=UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>

<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.2/dist/css/bootstrap.min.css"/>
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>

<!-- 공통 페이징 -->
<script src="/static/js/paging.js"></script>

<style>
    :root{ --bg:#f6f8fb; --card:#ffffff; --line:#e9edf3; --text:#0f172a; --muted:#6b7280; }
    body{ background:var(--bg); }
    .page-title{ font-size:26px; font-weight:800; color:var(--text); margin:12px 0 14px; }
    .toolbar{ display:flex; gap:8px; align-items:center; flex-wrap:wrap; margin:8px 0 16px; }
    .btn,.form-control{ border-radius:12px; }
    .table-hover tbody tr{ cursor:pointer; }
</style>

<section class="container-fluid">
    <h2 class="page-title">게시글 목록</h2>

    <div class="toolbar">
        <input id="keyword" class="form-control" type="text" placeholder="제목/내용 검색"/>
        <button id="btnSearch" class="btn btn-outline-secondary" type="button">검색</button>
        <div class="ml-auto"></div>
        <a id="btnNew" class="btn btn-primary" href="#">새 글</a>
    </div>

    <div class="table-responsive card p-2" style="border-radius:16px; border:1px solid var(--line); background:#fff;">
        <table class="table table-hover align-middle mb-2">
            <thead class="thead-light">
                <tr>
                    <th style="width: 90px; text-align:right;">번호</th>
                    <th>제목</th>
                    <th style="width: 220px;">작성일</th>
                </tr>
            </thead>
            <tbody id="postTbody"></tbody>
        </table>

        <!-- 페이징 -->
        <div id="pager"></div>
    </div>
</section>

<script>
    // ===== 상수/API =====
    const API_LIST = '/api/brd/boardPost/selectBoardPostListPaged';

    // 메뉴에서 전달된 boardId만 사용(쿼리 > 서버주입 우선)
    var BOARD_ID = (function(){
        var v = '${param.boardId}';
        if (v && v !== '') return v;
        try {
            var u = new URL(location.href);
            return u.searchParams.get('boardId');
        } catch(e){ return null; }
    })();

    // 전역 페이저
    var pager;

    $(function () {
        // 새 글 버튼: 현재 boardId 유지
        $('#btnNew').attr('href', '/brd/boardPost/boardPostModify' + (BOARD_ID ? ('?boardId=' + encodeURIComponent(BOARD_ID)) : ''));

        // 최소 연결: create → autoLoad=true 로 초기 1회 onChange 호출만
        pager = Paging.create('#pager', function (page, size) {
            loadPage(page, size);
        }, { size: 20, maxButtons: 7, key: 'boardPost', autoLoad: true });

        // 검색(키워드만, 별도 세션 저장 없음)
        $('#btnSearch').on('click', function () {
            pager.go(1, true);
        });
        $('#keyword').on('keydown', function (e) {
            if (e.key === 'Enter') pager.go(1, true);
        });
    });

    // ===== 목록 로딩 =====
    function loadPage (page, size) {
        $.ajax({
            url: API_LIST,
            type: 'post',
            contentType: 'application/json',
            dataType: 'json',
            data: JSON.stringify({
                page   : page,
                size   : size,
                boardId: BOARD_ID || null,
                kw: $('#keyword').val() || null   
            }),
            success: function (res) {
                renderRows(res.result || []);
                // 서버 메타를 pager에 단 한 번 반영
                if (res.page) pager.update(res.page);
            },
            error: function () {
                alert('목록 조회 실패');
            }
        });
    }

    // ===== 렌더 =====
    function renderRows (rows) {
        var $tb = $('#postTbody').empty();
        if (!rows || !rows.length) {
            $tb.append('<tr><td colspan="3" class="text-center text-muted">등록된 데이터가 없습니다.</td></tr>');
            return;
        }
        for (var i = 0; i < rows.length; i++) {
            var r = rows[i];
            var id = r.POST_ID || r.postId;
            var title = r.TITLE || r.title || '(제목 없음)';
            var created = r.CREATED_DT || r.createdDt || '';
            var tr = '<tr onclick="goDetail(' + id + ')">';
            tr += '  <td class="text-right">' + id + '</td>';
            tr += '  <td>' + escapeHtml(title) + '</td>';
            tr += '  <td>' + created + '</td>';
            tr += '</tr>';
            $tb.append(tr);
        }
    }

    // ===== 상세 이동 =====
    function goDetail (id) {
        if (!id) return;
        location.href = '/brd/boardPost/boardPostModify?postId=' + encodeURIComponent(id)
                      + (BOARD_ID ? ('&boardId=' + encodeURIComponent(BOARD_ID)) : '');
    }

    // ===== HTML escape =====
    function escapeHtml (s) {
        return String(s || '')
            .replace(/&/g, '&amp;')
            .replace(/</g, '&lt;')
            .replace(/>/g, '&gt;')
            .replace(/"/g, '&quot;')
            .replace(/'/g, '&#39;');
    }
</script>  