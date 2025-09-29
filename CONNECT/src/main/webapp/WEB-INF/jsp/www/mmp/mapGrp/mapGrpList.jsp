<%@ page language="java" contentType="text/html; charset=UTF-8"%>

<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.2/dist/css/bootstrap.min.css"/>
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>

<style>
    :root{ --bg:#f6f8fb; --card:#ffffff; --line:#e9edf3; --text:#0f172a; --muted:#6b7280; }
    body{ background:var(--bg); }
    .page-title{ font-size:26px; font-weight:800; color:var(--text); margin:12px 0 14px; }
    .toolbar{ display:flex; gap:8px; align-items:center; margin:8px 0 16px; flex-wrap:wrap; }
    .toolbar .form-control,.toolbar .custom-select{ border-radius:12px; }
    .card-list{ display:grid; grid-template-columns:repeat(auto-fill,minmax(320px,1fr)); gap:14px; }
    .grp-card{ background:var(--card); border:1px solid var(--line); border-radius:16px; padding:16px; box-shadow:0 4px 16px rgba(15,23,42,.06); }
    .grp-title{ font-weight:700; font-size:18px; margin-bottom:4px; color:#111827; }
    .grp-desc{ color:#475569; font-size:.95rem; min-height:40px; }
    .grp-meta{ display:flex; gap:10px; align-items:center; color:#6b7280; font-size:.9rem; margin-top:8px; }
    .badge-soft{ background:#eef2ff; color:#4338ca; padding:.25rem .5rem; border-radius:999px; font-weight:600; }
    .badge-soft.off{ background:#fee2e2; color:#b91c1c; }
    .grp-actions{ display:flex; gap:8px; margin-top:12px; flex-wrap:wrap; }
    .btn{ border-radius:12px; }
</style>

<section class="container-fluid">
    <h2 class="page-title">지도 그룹</h2>

    <div class="toolbar">
        <input id="keyword" class="form-control" type="text" placeholder="제목/설명 검색"/>
        <select id="useAt" class="custom-select" style="max-width:140px;">
            <option value="">전체</option>
            <option value="Y" selected>사용중</option>
            <option value="N">사용안함</option>
        </select>
        <button class="btn btn-outline-secondary" type="button" onclick="reload()">검색</button>
        <div class="ml-auto"></div>
        <button class="btn btn-primary" type="button" onclick="goNew()">새 그룹</button>
        <button class="btn btn-outline-secondary" type="button" onclick="goUnified()">통합 지도</button>
    </div>

    <div id="listBox" class="card-list"></div>
    <div id="emptyBox" class="text-center text-muted" style="display:none; padding:40px 0;">등록된 그룹이 없습니다.</div>
</section>

<script>
    const API = '/api/mmp/mapGrp';
    const PK  = 'mapGrpId';

    $(function () {
        reload();
    });

    function reload() {
        const param = {
            keyword: $('#keyword').val() || '',
            useAt: $('#useAt').val() || ''
        };
        $.ajax({
            url: API + '/selectMapGrpList',
            type: 'post',
            contentType: 'application/json',
            dataType: 'json',
            data: JSON.stringify(param),
            success: function (map) {
                renderList(map.result || []);
            },
            error: function () {
                alert('목록 조회 오류');
            }
        });
    }

    function renderList(list) {
        const $box = $('#listBox').empty();
        $('#emptyBox').toggle(list.length === 0);

        for (let i = 0; i < list.length; i++) {
            const r = list[i];
            const id    = r.mapGrpId || r.MAP_GRP_ID;
            const name  = r.grpNm || r.GRP_NM || '(제목 없음)';
            const desc  = r.descTxt || r.DESC_TXT || '';
            const use   = (r.useAt || r.USE_AT || 'Y') === 'Y';
            const cuser = r.createdBy || r.CREATED_BY || '';
            const cdt   = (r.createdDt || r.CREATED_DT || '') + '';
            const grpCd = r.grpCd || r.GRP_CD || '';   // ★ grpCd 사용

            const $card = $('<div/>').addClass('grp-card');
            $card.append($('<div/>').addClass('grp-title').text(name));
            $card.append($('<div/>').addClass('grp-desc').text(desc || ''));
            const $meta = $('<div/>').addClass('grp-meta');
            $meta.append($('<span/>').addClass('badge-soft' + (use ? '' : ' off')).text(use ? '사용중' : '사용안함'));
            if (grpCd) $meta.append($('<span/>').text('#' + grpCd));  // 선택: grpCd 표시
            if (cuser) $meta.append($('<span/>').text('@' + cuser));
            if (cdt)   $meta.append($('<span/>').text(cdt));
            $card.append($meta);

            const $acts = $('<div/>').addClass('grp-actions');
            $acts.append($('<button/>').addClass('btn btn-sm btn-outline-primary').text('수정').on('click', function () { goDetail(id); }));
            $acts.append(
                $('<button/>')
                    .addClass('btn btn-sm btn-outline-secondary')
                    .text('상세보기')
                    .prop('disabled', !grpCd)
                    .attr('title', grpCd ? '' : 'GRP_CD가 없어 이동할 수 없습니다.')
                    .on('click', function () { goMapListByGrpCd(grpCd); })
            );
            $acts.append(
                    $('<button/>')
                        .addClass('btn btn-sm btn-outline-secondary')
                        .text('지도보기')
                        .prop('disabled', !grpCd)
                        .attr('title', grpCd ? '' : 'GRP_CD가 없어 이동할 수 없습니다.')
                        .on('click', function () { goMapListByGrp(grpCd); })
                );
            //$acts.append($('<button/>').addClass('btn btn-sm btn-outline-dark').text('맛집 관리').on('click', function () { goPlaceManage(id); }));
            $card.append($acts);
  
            $box.append($card);
        }
    }

    function goNew() {
        location.href = '/mmp/mapGrp/mapGrpModify';
    }

    function goDetail(id) {
        let url = '/mmp/mapGrp/mapGrpModify';
        if (id) url += '?' + PK + '=' + encodeURIComponent(id);
        location.href = url;
    }

    // ★ grpCd로 지도 목록으로 이동
    function goMapListByGrpCd(grpCd) {
        if (!grpCd) { alert('GRP_CD가 없습니다.'); return; }
        location.href = '/mmp/map/mapList?grpCd=' + encodeURIComponent(grpCd);
    }
    
    // ★ grpCd로 지도 전체보기로 이동
    function goMapListByGrp(grpCd) {
        if (!grpCd) { alert('GRP_CD가 없습니다.'); return; }
        location.href = '/mmp/map/map?grpCd=' + encodeURIComponent(grpCd);  
    }
 
    function goPlaceManage(id) {
        if (!id) return;
        location.href = '/mmp/place/placeList?' + PK + '=' + encodeURIComponent(id);
    }

    // ★ 통합 지도: grpCd 없이 목록으로
    function goUnified() {
        location.href = '/mmp/map/mapList';
    }
</script>