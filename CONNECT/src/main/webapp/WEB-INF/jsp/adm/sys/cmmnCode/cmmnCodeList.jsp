<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<style>
    .page-wrap { max-width: 1160px; margin: 0 auto; }
    .page-title { font-weight: 700; letter-spacing: .2px; }
    .toolbar { display: flex; gap: 8px; align-items: center; }
    .card-surface {
        background: #fff;
        border: 1px solid rgba(0,0,0,.06);
        border-radius: 16px;
        box-shadow: 0 4px 18px rgba(0,0,0,.04);
    }
    .table thead th { background:#f5f7fb; color:#5b6375; font-weight:600; border-bottom:1px solid rgba(0,0,0,.06); }
    .empty-row { color:#99a1b3; }
    #cmmnCodeListBody tr[data-id] { cursor: pointer; }
</style>

<section class="page-wrap">
    <div class="d-flex align-items-end justify-content-between mb-3">
        <h2 class="page-title mb-0">공통코드 목록</h2>
        <div class="toolbar">
            <button class="btn btn-primary" type="button" onclick="goToCmmnCodeModify()">등록</button>
            <button class="btn btn-outline-secondary" type="button" onclick="goToCmmnCode()">통합</button>
        </div>
    </div>

    <div class="card-surface p-3 mb-3">
        <div class="row g-2 align-items-center">
            <div class="col-auto"><label for="filterCodeClId" class="col-form-label fw-semibold">코드그룹</label></div>
            <div class="col-4 col-md-3">
                <select id="filterCodeClId" class="form-select">
                    <option value="">전체</option>
                </select>
            </div>
            <div class="col text-muted small">그룹을 선택하면 해당 그룹의 공통코드만 표시됩니다.</div>
        </div>
    </div>

    <div class="card-surface p-2">
        <div class="table-responsive">
            <table class="table table-hover align-middle mb-0">
                <thead>
                    <tr>
                        <th style="width: 90px; text-align:right;">ID</th>
                        <th style="width: 120px;">그룹ID</th>
                        <th style="width: 220px;">코드</th>
                        <th>코드명</th>
                        <th style="width: 90px;">정렬</th>
                        <th style="width: 90px;">사용</th>
                        <th style="width: 200px;">생성일</th>
                        <th style="width: 100px;">관리</th>
                    </tr>
                </thead>
                <tbody id="cmmnCodeListBody"></tbody>
            </table>
        </div>
    </div>
</section>

<script>
    // ▼ JavaGen 스타일 유지
    const API_BASE = '/api/sys/cmmnCode';
    const API_CODE_CL = '/api/sys/cmmnCodeCl';
    const codeIdParam = 'codeId'; // 수정 진입 파라미터 통일

    $(function () {
        // 옵션 로딩 → URL의 codeClId를 선택해두고 → 목록 조회
        loadCodeClOptions(function () {
            const qCl = getParam('codeClId');
            if (qCl) $('#filterCodeClId').val(qCl);
            selectCmmnCodeList();
        });

        // 그룹 변경 시 목록 갱신 + 주소 쿼리 갱신(뒤로가기 대응)
        $('#filterCodeClId').on('change', function () {
            const cl = $('#filterCodeClId').val();
            const qs = cl ? ('?codeClId=' + encodeURIComponent(cl)) : '';
            history.replaceState(null, '', location.pathname + qs);
            selectCmmnCodeList();
        });

        // 행 전체 클릭으로도 수정 진입
        $('#cmmnCodeListBody').on('click', 'tr[data-id]', function () {
            goToCmmnCodeModify($(this).data('id'));
        });
    });

    function loadCodeClOptions(cb) {
        $.ajax({
            url: API_CODE_CL + '/selectCmmnCodeClList',
            type: 'post',
            contentType: 'application/json',
            data: JSON.stringify({}),
            success: function (map) {
                const list = map.result || [];
                let html = '<option value="">전체</option>';
                for (let i = 0; i < list.length; i++) {
                    const r = list[i];
                    const id = r.codeClId || r.CODE_CL_ID || r.code_cl_id;
                    const nm = r.codeClNm || r.CODE_CL_NM || r.code_cl_nm || ('#' + id);
                    html += '<option value="' + id + '">' + nm + '</option>';
                }
                $('#filterCodeClId').html(html);
                if (typeof cb === 'function') cb();
            },
            error: function () { if (typeof cb === 'function') cb(); }
        });
    }

    function selectCmmnCodeList() {
        const send = {};
        const cl = $('#filterCodeClId').val();
        if (cl !== '') send.codeClId = cl;

        $.ajax({
            url: API_BASE + '/selectCmmnCodeList',
            type: 'post',
            contentType: 'application/json',
            data: JSON.stringify(send),
            success: function (map) {
                let list = map.result || [];
                // ★ 백엔드가 아직 codeClId 필터를 적용하지 않아도 프론트에서 보조 필터
                if (cl !== '') {
                    list = list.filter(function (r) {
                        const rid = (r.codeClId || r.CODE_CL_ID || r.code_cl_id) + '';
                        return rid === cl + '';
                    });
                }

                let html = '';
                if (!list.length) {
                    html += "<tr><td colspan='8' class='text-center empty-row py-5'>데이터가 없습니다.</td></tr>";
                } else {
                    for (let i = 0; i < list.length; i++) {
                        const r = list[i];
                        const id       = r.codeId    || r.CODE_ID    || r.code_id;
                        const codeClId = r.codeClId  || r.CODE_CL_ID || r.code_cl_id;
                        const code     = r.code      || r.CODE       || r.code_value;
                        const codeNm   = r.codeNm    || r.CODE_NM    || r.code_nm;
                        const sortOrdr = (r.sortOrdr != null ? r.sortOrdr : (r.SORT_ORDR != null ? r.SORT_ORDR : ''));
                        const useAt    = (r.useAt || r.USE_AT || 'Y') === 'Y' ? 'Y' : 'N';
                        let createdDt  = r.createdDt || r.CREATED_DT || r.created_dt;
                        if (createdDt && typeof createdDt === 'object') createdDt = (createdDt.value || String(createdDt));

                        html += "<tr data-id='" + id + "'>";
                        html += "  <td class='text-end'>" + id + "</td>";
                        html += "  <td>" + codeClId + "</td>";
                        html += "  <td>" + (code || '') + "</td>";
                        html += "  <td>" + (codeNm || '') + "</td>";
                        html += "  <td>" + sortOrdr + "</td>";
                        html += "  <td>" + useAt + "</td>";
                        html += "  <td>" + (createdDt || '') + "</td>";
                        html += "  <td><button class='btn btn-sm btn-outline-primary' type='button' onclick=\"goToCmmnCodeModify('" + id + "')\">수정</button></td>";
                        html += "</tr>";
                    }
                }
                $('#cmmnCodeListBody').html(html);
            },
            error: function () { alert('목록 조회 중 오류 발생'); }
        });
    }

    function goToCmmnCodeModify(id) {
        const cl = $('#filterCodeClId').val();
        let url = '/adm/sys/cmmnCode/cmmnCodeModify';
        const qs = [];
        if (id) qs.push(codeIdParam + '=' + encodeURIComponent(id));
        if (cl) qs.push('codeClId=' + encodeURIComponent(cl));
        if (qs.length) url += '?' + qs.join('&');
        location.href = url;
    }

    function goToCmmnCode() { location.href = '/adm/sys/cmmnCode/cmmnCode'; }

    // 쿼리파라미터 읽기 (스타일 유지)
    function getParam(k) {
        const q = window.location.search.substring(1).split('&');
        for (let i = 0; i < q.length; i++) {
            const p = q[i].split('=');
            if (decodeURIComponent(p[0]) === k) return decodeURIComponent(p[1] || '');
        }
        return '';
    }
</script>  