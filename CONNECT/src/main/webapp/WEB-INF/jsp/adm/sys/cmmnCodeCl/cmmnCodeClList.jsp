<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<style>
    :root{ --bg:#f6f8fb; --card:#ffffff; --line:#e9edf3; --text:#0f172a; --muted:#6b7280; }
    body{ background:var(--bg); }
    .page-title{ font-size:28px; font-weight:700; color:var(--text); margin-bottom:12px; }
    .toolbar{ display:flex; gap:10px; align-items:center; flex-wrap:wrap; margin:8px 0 18px; }
    .table-card{ background:var(--card); border:1px solid var(--line); border-radius:16px; box-shadow:0 2px 8px rgba(15,23,42,.05); }
    .table{ margin-bottom:0; }
    .table thead th{ font-weight:700; color:#475569; background:#f3f5f8; border-bottom:1px solid var(--line); }
    .table tbody tr{ cursor:pointer; }
    .table tbody tr:hover{ background:#f9fbff; }
    .btn,.form-select,.form-control{ border-radius:12px; }
    .mono{ font-family: ui-monospace,SFMono-Regular,Menlo,Monaco,Consolas,"Liberation Mono","Courier New",monospace; }
    .ms-auto{ margin-left:auto; }
    #useAt{ width:120px; }
</style>

<section>
    <h2 class="page-title">코드그룹 목록</h2>

    <div class="toolbar">
        <input id="qCl" class="form-control mono" placeholder="그룹값 (예: BOARD_READ_LVL)" style="width:280px;">
        <input id="qNm" class="form-control" placeholder="그룹명 검색" style="width:220px;">
        <select id="useAt" class="form-select">
            <option value="">전체</option>
            <option value="Y">사용</option>
            <option value="N">미사용</option>
        </select>
        <button class="btn btn-outline-secondary" type="button" id="btnSearch">검색</button>

        <button class="btn btn-primary ms-auto" type="button" onclick="goToCmmnCodeClModify()">신규 그룹</button>
        <button class="btn btn-outline-secondary" type="button" onclick="goToCmmnCodeCl()">통합</button>
    </div>

    <div class="table-responsive table-card">
        <table class="table table-hover align-middle">
            <thead>
                <tr>
                    <th style="width:90px; text-align:right;">번호</th>
                    <th style="width:280px;">그룹값</th>
                    <th>그룹명</th>
                    <th style="width:90px; text-align:center;">사용</th>
                    <th style="width:200px;">생성일</th>
                </tr>
            </thead>
            <tbody id="cmmnCodeClListBody">
                <tr><td colspan="5" class="text-center text-muted">Loading…</td></tr>
            </tbody>
        </table>
    </div>
</section>

<script>
    // ▼ API & PK
    const API_BASE = '/api/sys/cmmnCodeCl';
    const PK_PARAM = 'codeClId';

    $(function () {
        bindEvents();
        reload();
    });

    function bindEvents(){
        $('#btnSearch').on('click', reload);
        $('#qCl,#qNm').on('keyup', function(e){ if (e.key === 'Enter') reload(); });
        $('#useAt').on('change', reload);
    }

    function reload(){
        const data = {
            codeCl: $('#qCl').val(),
            codeClNm: $('#qNm').val(),
            useAt: $('#useAt').val()
        };

        $.ajax({
            url: API_BASE + '/selectCmmnCodeClList',
            type: 'post',
            contentType: 'application/json',
            data: JSON.stringify(data),
            success: function (map) {
                const list = map.result || map.list || [];
                let html = '';

                if (!list.length) {
                    html += "<tr><td colspan='5' class='text-center text-muted'>등록된 데이터가 없습니다.</td></tr>";
                } else {
                    for (let i = 0; i < list.length; i++) {
                        const r = list[i];
                        const id = r.codeClId || r.CODE_CL_ID;
                        const cl = r.codeCl || r.CODE_CL || '';
                        const nm = r.codeClNm || r.CODE_CL_NM || '';
                        const use = (r.useAt || r.USE_AT || '').toUpperCase() === 'Y' ? 'Y' : 'N';
                        const created = r.createdDt || r.CREATED_DT || '';

                        html += "<tr onclick=\"goToCmmnCodeClModify('" + id + "')\">";
                        html += "  <td class='text-end'>" + id + "</td>";
                        html += "  <td class='mono'>" + escapeHtml(cl) + "</td>";
                        html += "  <td>" + escapeHtml(nm) + "</td>";
                        html += "  <td class='text-center'>" + use + "</td>";
                        html += "  <td>" + escapeHtml(created) + "</td>";
                        html += "</tr>";
                    }
                }
                $('#cmmnCodeClListBody').html(html);
            },
            error: function () {
                $('#cmmnCodeClListBody').html("<tr><td colspan='5' class='text-center text-danger'>목록 조회 중 오류</td></tr>");
            }
        });
    }

    function goToCmmnCodeClModify(id) {
        let url = '/adm/sys/cmmnCodeCl/cmmnCodeClModify';
        if (id) url += '?' + PK_PARAM + '=' + encodeURIComponent(id);
        location.href = url;
    }

    function goToCmmnCodeCl() {
        location.href = '/adm/sys/cmmnCodeCl/cmmnCodeCl';
    }

    // utils
    function escapeHtml(s){
        if (s == null) return '';
        return String(s)
            .replace(/&/g,'&amp;')
            .replace(/</g,'&lt;')
            .replace(/>/g,'&gt;')
            .replace(/"/g,'&quot;')
            .replace(/'/g,'&#39;');
    }
</script>