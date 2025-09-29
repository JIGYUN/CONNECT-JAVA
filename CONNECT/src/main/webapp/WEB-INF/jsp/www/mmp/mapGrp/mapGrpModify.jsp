<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>

<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.2/dist/css/bootstrap.min.css"/>
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>

<link rel="stylesheet" href="https://uicdn.toast.com/editor/latest/toastui-editor.min.css" />
<script src="https://uicdn.toast.com/editor/latest/toastui-editor-all.min.js"></script>

<style>
    :root{ --bg:#f6f8fb; --card:#ffffff; --line:#e9edf3; --text:#0f172a; --muted:#6b7280; }
    body{ background:var(--bg); }
    .wrap{ max-width:960px; margin: 10px auto 40px; }
    .page-title{ font-size:26px; font-weight:800; color:var(--text); margin:12px 0 14px; }
    .card{ background:var(--card); border:1px solid var(--line); border-radius:16px; padding:16px; box-shadow:0 4px 16px rgba(15,23,42,.06); }
    .toolbar{ display:flex; gap:8px; align-items:center; flex-wrap:wrap; margin:8px 0 16px; }
    .btn,.form-control,.custom-select{ border-radius:12px; }
    .meta{ color:#6b7280; margin-top:-4px; }
    .file-thumbs{ display:flex; gap:8px; flex-wrap:wrap; margin-top:8px; }
    .file-thumbs a{ display:inline-block; border:1px solid var(--line); border-radius:10px; padding:6px 10px; font-size:.92rem; background:#fff; }
</style>

<div class="wrap">
    <h2 class="page-title">
        지도 그룹 <span id="modeText" class="text-muted" style="font-size:16px;">상세</span>
    </h2>

    <div class="toolbar">
        <button id="btnSave" class="btn btn-primary" type="button" onclick="save()">저장</button>
        <c:if test="${not empty param.mapGrpId}">
            <button id="btnDelete" class="btn btn-outline-danger" type="button" onclick="remove()">삭제</button>
        </c:if>
        <a class="btn btn-outline-secondary" href="/mmp/mapGrp/mapGrpList">목록</a>
        <div class="ml-auto"></div>
        <button class="btn btn-outline-secondary" type="button" onclick="goMap()">지도 보기</button>
        <button class="btn btn-outline-dark" type="button" onclick="goPlaceManage()">맛집 관리</button>
    </div>

    <div id="formCard" class="card">
        <form id="mapGrpForm" onsubmit="return false;">
            <!-- PK / 코드 -->
            <input type="hidden" id="mapGrpId" name="mapGrpId" value="${param.mapGrpId}"/>
            <input type="hidden" id="initGrpCd" value="${param.grpCd}"/>

            <div class="form-row">
                <div class="form-group col-md-8">
                    <label>그룹명 (필수)</label>
                    <input id="grpNm" name="grpNm" class="form-control" type="text" placeholder="예) 성시경의 먹을텐데 : 부산 맛집 리스트"/>
                </div>
                <div class="form-group col-md-8">
                    <label>그룹코드 (필수)</label> 
                    <input id="grpCd" name="grpCd" class="form-control" type="text" placeholder="예) sikyung"/>
                    <small class="text-muted">지도/맛집 진입 시 <code>?grpCd=코드</code> 형태로 사용됩니다.</small>
                </div>
                <div class="form-group col-md-4">
                    <label>사용 여부</label>
                    <select id="useAt" name="useAt" class="custom-select">
                        <option value="Y" selected>Y</option>
                        <option value="N">N</option>
                    </select>
                </div>
            </div>

            <div class="form-group">
                <label>설명</label>
                <div id="editor" style="height:280px;"></div>
                <input type="hidden" id="descTxt" name="descTxt"/>
            </div>

            <div class="form-row">
                <div class="form-group col-md-6">
                    <label>썸네일 파일그룹 ID (선택)</label>
                    <input id="thumbFileGrpId" name="thumbFileGrpId" class="form-control" type="number" min="0" placeholder="파일그룹 ID 숫자"/>
                    <small class="text-muted">값이 있으면 아래에 첨부 미리보기 노출</small>
                </div>
                <div class="form-group col-md-6">
                    <label>&nbsp;</label>
                    <div>
                        <button class="btn btn-outline-secondary" type="button" onclick="previewThumbs()">미리보기</button>
                        <a class="btn btn-outline-primary" href="/mmp/place/placeList" target="_blank">맛집 관리로 가기</a>
                    </div>
                </div>
            </div>

            <div id="thumbBox" class="file-thumbs"></div>

            <div class="meta" id="metaBox" style="margin-top:10px;"></div>
        </form>
    </div>
</div>

<script>
    const API = '/api/mmp/mapGrp';
    const FILE_API = { list: '/api/com/file/list', download: function (id) { return '/api/com/file/download/' + id; } };
    const PK  = 'mapGrpId';

    let editor;

    $(document).ready(function () {
        editor = new toastui.Editor({
            el: document.querySelector('#editor'),
            height: '280px',
            initialEditType: 'markdown',
            previewStyle: 'vertical',
            placeholder: '그룹 설명을 입력하세요...'
        });

        // 진입 파라미터: grpCd 우선, 없으면 mapGrpId
        const initGrpCd = ($('#initGrpCd').val() || getParam('grpCd') || '').trim();
        const initId = ($('#mapGrpId').val() || '').trim();

        if (initGrpCd) {
            $('#modeText').text('수정');
            load({ grpCd: initGrpCd });
        } else if (initId) {
            $('#modeText').text('수정');
            load({ mapGrpId: initId });
        } else {
            $('#modeText').text('등록');
            $('#useAt').val('Y');
        }
    });

    function getParam(name) {
        const url = new URL(location.href);
        return url.searchParams.get(name);
    }

    function load(key) {
        $.ajax({
            url: API + '/selectMapGrpDetail',
            type: 'post',
            contentType: 'application/json',
            dataType: 'json',
            data: JSON.stringify(key),
            success: function (map) {
                const r = map.result || {};
                $('#mapGrpId').val(r.mapGrpId || r.MAP_GRP_ID || $('#mapGrpId').val());
                $('#grpNm').val(r.grpNm || r.GRP_NM || '');
                $('#grpCd').val(r.grpCd || r.GRP_CD || '');
                $('#useAt').val(r.useAt || r.USE_AT || 'Y');
                $('#thumbFileGrpId').val(r.thumbFileGrpId || r.THUMB_FILE_GRP_ID || '');
                editor.setHTML(r.descTxt || r.DESC_TXT || '');
                renderMeta(r);
                previewThumbs();
            },
            error: function () {
                alert('상세 조회 오류');
            }
        });
    }

    function renderMeta(r) {
        const by  = r.createdBy || r.CREATED_BY || '';
        const cdt = r.createdDt || r.CREATED_DT || '';
        const uby = r.updatedBy || r.UPDATED_BY || '';
        const udt = r.updatedDt || r.UPDATED_DT || '';
        const parts = [];
        if (by || cdt) parts.push('생성: ' + (by ? '@' + by : '') + (cdt ? ' · ' + cdt : ''));
        if (uby || udt) parts.push('수정: ' + (uby ? '@' + uby : '') + (udt ? ' · ' + udt : ''));
        $('#metaBox').text(parts.join(' / '));
    }

    function save() {
        const name = $('#grpNm').val().trim();
        const code = $('#grpCd').val().trim();
        if (name === '') { alert('그룹명을 입력하세요.'); $('#grpNm').focus(); return; }
        if (code === '') { alert('그룹코드를 입력하세요.'); $('#grpCd').focus(); return; }

        $('#descTxt').val(editor.getHTML());

        const payload = {
            mapGrpId:       $('#mapGrpId').val() || null,
            grpNm:          $('#grpNm').val().trim(),
            grpCd:          $('#grpCd').val().trim(),
            descTxt:        $('#descTxt').val(),
            useAt:          $('#useAt').val() || 'Y',
            thumbFileGrpId: $('#thumbFileGrpId').val() || null
        };

        const hasId = !!payload.mapGrpId;
        const url = hasId ? (API + '/updateMapGrp') : (API + '/insertMapGrp');

        $.ajax({
            url: url,
            type: 'post',
            contentType: 'application/json',
            dataType: 'json',
            data: JSON.stringify(payload),
            success: function (res) {
                // 응답의 grpCd / mapGrpId 우선순위
                const resGrpCd = (res && (res.grpCd || res.GRP_CD)) || payload.grpCd;
                const resId = (res && (res.mapGrpId || res.MAP_GRP_ID)) || payload.mapGrpId;

                // 저장 후 상세로 유지: grpCd 우선
                if (resGrpCd) {
                    location.href = '/mmp/mapGrp/mapGrpList?grpCd=' + encodeURIComponent(resGrpCd);
                    return;
                }
                if (resId) {
                    location.href = '/mmp/mapGrp/mapGrpList?mapGrpId=' + encodeURIComponent(resId);
                    return;
                }
                // 안전망: 목록으로
                location.href = '/mmp/mapGrp/mapGrpList'; 
            },
            error: function () {
                alert('저장 오류');
            }
        });
    }

    function remove() {
        const id = $('#mapGrpId').val();
        const code = $('#grpCd').val().trim();

        if (!id && !code) { alert('삭제할 대상이 없습니다.'); return; }
        if (!confirm('정말 삭제하시겠습니까?')) return;

        // 서버는 mapGrpId 또는 grpCd 아무거나 받아서 삭제 가능하도록 구현되어 있어야 함
        const body = id ? { mapGrpId: id } : { grpCd: code };

        $.ajax({
            url: API + '/deleteMapGrp',
            type: 'post',
            contentType: 'application/json',
            dataType: 'json',
            data: JSON.stringify(body),
            success: function () {
                alert('삭제되었습니다.');
                location.href = '/mmp/mapGrp/mapGrpList';
            },
            error: function () {
                alert('삭제 오류');
            }
        });
    }

    function goMap() {
        const code = ($('#grpCd').val() || '').trim();
        const id = ($('#mapGrpId').val() || '').trim();
        if (code) { location.href = '/map/web?grpCd=' + encodeURIComponent(code); return; }
        if (id)   { location.href = '/map/web?mapGrpId=' + encodeURIComponent(id); return; }
        alert('먼저 저장하세요.');
    }

    function goPlaceManage() {
        const code = ($('#grpCd').val() || '').trim();
        const id = ($('#mapGrpId').val() || '').trim();
        if (code) { location.href = '/mmp/place/placeList?grpCd=' + encodeURIComponent(code); return; }
        if (id)   { location.href = '/mmp/place/placeList?mapGrpId=' + encodeURIComponent(id); return; }
        alert('먼저 저장하세요.');
    }

    function previewThumbs() {
        const gid = $('#thumbFileGrpId').val();
        const $box = $('#thumbBox').empty();
        if (!gid) { return; }
        $.ajax({
            url: FILE_API.list,
            type: 'post',
            contentType: 'application/json',
            dataType: 'json',
            data: JSON.stringify({ fileGrpId: gid }),
            success: function (res) {
                const list = res.result || [];
                if (!list.length) { $box.append($('<div/>').addClass('text-muted').text('첨부 없음')); return; }
                for (let i = 0; i < list.length; i++) {
                    const f = list[i];
                    const $a = $('<a/>')
                        .attr('href', FILE_API.download(f.fileId))
                        .attr('target','_blank')
                        .text((f.orgFileNm || '') + (f.fileSize != null ? (' (' + formatBytes(f.fileSize) + ')') : ''));
                    $box.append($a);
                }
            }
        });
    }

    function formatBytes(bytes) {
        if (!bytes && bytes !== 0) return '';
        const units = ['B','KB','MB','GB','TB'];
        let i = 0, n = parseFloat(bytes);
        while (n >= 1024 && i < units.length - 1) { n /= 1024; i++; }
        return (Math.round(n * 10) / 10) + units[i];
    }
</script> 