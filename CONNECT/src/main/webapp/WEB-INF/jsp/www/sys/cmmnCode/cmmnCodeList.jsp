<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<style>
    /* ---- Modern / Simple / Premium ---- */
    .page-wrap { max-width: 1160px; margin: 0 auto; }
    .page-title { font-weight: 700; letter-spacing: .2px; }
    .toolbar { display: flex; gap: 8px; align-items: center; }
    .filters { display: grid; grid-template-columns: 240px 180px 1fr 100px; gap: 8px; }
    .card-surface {
        background: #fff;
        border: 1px solid rgba(0,0,0,.06);
        border-radius: 16px;
        box-shadow: 0 4px 18px rgba(0,0,0,.04);
    }
    .table thead th {
        background: #f5f7fb;
        color: #5b6375;
        font-weight: 600;
        border-bottom: 1px solid rgba(0,0,0,.06);
    }
    .table tbody tr { cursor: pointer; }
    .table tbody tr:hover { background: #f9fbff; }
    .empty-row { color:#99a1b3; }
</style>

<section class="page-wrap">
    <div class="d-flex align-items-end justify-content-between mb-3">
        <h2 class="page-title mb-0">공통코드 목록</h2>
        <div class="toolbar">
            <button class="btn btn-primary" type="button" onclick="goToCmmnCodeModify()">글쓰기</button>
            <button class="btn btn-outline-secondary" type="button" onclick="goToCmmnCode()">통합</button>
        </div>
    </div>

    <div class="card-surface p-3 mb-3">
        <div class="filters">
            <select id="filterCodeClId" class="form-select">
                <option value="">코드그룹 전체</option>
            </select>
            <select id="searchField" class="form-select">
                <option value="code">코드</option>
                <option value="codeNm">코드명</option>
            </select>
            <input id="searchText" class="form-control" placeholder="검색어 입력" />
            <button class="btn btn-outline-primary" type="button" onclick="selectCmmnCodeList()">검색</button>
        </div>
    </div>

    <div class="card-surface p-2">
        <div class="table-responsive">
            <table class="table table-hover align-middle mb-0">
                <thead>
                    <tr>
                        <th style="width: 90px; text-align:right;">ID</th>
                        <th style="width: 160px;">그룹</th>
                        <th style="width: 180px;">코드</th>
                        <th>코드명</th>
                        <th style="width: 90px;">정렬</th>
                        <th style="width: 90px;">사용</th>
                        <th style="width: 200px;">생성일</th>
                    </tr>
                </thead>
                <tbody id="cmmnCodeListBody"></tbody>
            </table>
        </div>
    </div>
</section>

<script>
    // ▼ JavaGen 치환/엔드포인트
    const API_BASE = '/api/sys/cmmnCode';
    const API_CODE_CL = '/api/sys/cmmnCodeCl';
    const codeId = 'cmmnCodeIdx'; // 기존 스타일 유지(파라미터 키)

    $(function () {
        loadCodeClOptions(function () {
            selectCmmnCodeList();
        });

        // 엔터로 검색
        $('#searchText').on('keydown', function (e) {
            if (e.keyCode === 13) selectCmmnCodeList();
        });
        $('#filterCodeClId').on('change', function () {
            selectCmmnCodeList();
        });
    });

    function loadCodeClOptions(cb) {
        $.ajax({
            url: API_CODE_CL + '/selectCmmnCodeClList',
            type: 'post',
            contentType: 'application/json',
            data: JSON.stringify({}),
            success: function (map) {
                const list = map.result || map.list || [];
                const $sel = $('#filterCodeClId');
                for (var i = 0; i < list.length; i++) {
                    var r = list[i];
                    var id = pick(r, ['codeClId','codeClID','cmmnCodeClId','cmmnCodeClIdx','id']);
                    var nm = pick(r, ['codeClNm','name','title','nm','clNm','clName']);
                    if (id != null && id !== '') {
                        $sel.append('<option value="'+ id +'">'+ (nm || ('#'+id)) +'</option>');
                    }
                }
                if (typeof cb === 'function') cb();
            },
            error: function () {
                // 그룹이 없어도 목록은 조회 가능
                if (typeof cb === 'function') cb();
            }
        });
    }

    function selectCmmnCodeList() {
        var send = {};
        var cl = $('#filterCodeClId').val();
        if (cl !== '') send.codeClId = cl;

        var sf = $('#searchField').val();
        var st = $('#searchText').val();
        if (st && st.trim() !== '') {
            send.searchField = sf;
            send.searchText = st.trim();
        }

        $.ajax({
            url: API_BASE + '/selectCmmnCodeList',
            type: 'post',
            contentType: 'application/json',
            data: JSON.stringify(send),
            success: function (map) {
                const resultList = map.result || map.list || [];
                var html = '';

                if (!resultList.length) {
                    html += "<tr><td colspan='7' class='text-center empty-row py-5'>데이터가 없습니다.</td></tr>";
                } else {
                    for (var i = 0; i < resultList.length; i++) {
                        var r = resultList[i];
                        var _codeId    = pick(r, ['codeId','cmmnCodeId','cmmnCodeIdx','id']);
                        var _codeClId  = pick(r, ['codeClId','codeClID']);
                        var _code      = pick(r, ['code']);
                        var _codeNm    = pick(r, ['codeNm','name','title']);
                        var _sortOrdr  = pick(r, ['sortOrdr','sort','order','ord']);
                        var _useAt     = pick(r, ['useAt']);
                        var _createdDt = safeDate(pick(r, ['createdDt','createDate','createdAt']));

                        html += "<tr onclick=\"goToCmmnCodeModify('" + (_codeId) + "')\">";
                        html += "  <td class='text-right'>" + (_codeId || '') + "</td>";
                        html += "  <td>" + (_codeClId || '') + "</td>";
                        html += "  <td>" + (_code || '') + "</td>";
                        html += "  <td>" + (_codeNm || '') + "</td>";
                        html += "  <td>" + (_sortOrdr != null ? _sortOrdr : '') + "</td>";
                        html += "  <td>" + ((_useAt || 'Y') === 'Y' ? 'Y' : 'N') + "</td>";
                        html += "  <td>" + (_createdDt || '') + "</td>";
                        html += "</tr>";
                    }
                }

                $('#cmmnCodeListBody').html(html);
            },
            error: function () {
                alert('목록 조회 중 오류 발생');
            }
        });
    }

    function goToCmmnCodeModify(id) {
        // 선택한 그룹을 글쓰기로 넘겨 편의 제공
        var cl = $('#filterCodeClId').val();
        var qs = [];
        if (id) qs.push(codeId + '=' + encodeURIComponent(id));
        if (cl) qs.push('codeClId=' + encodeURIComponent(cl));
        var url = '/adm/sys/cmmnCode/cmmnCodeModify';
        if (qs.length) url += '?' + qs.join('&');
        location.href = url;
    }

    function goToCmmnCode() {
        location.href = '/adm/sys/cmmnCode/cmmnCode';
    }

    // ---- helpers ----
    function pick(obj, keys) {
        for (var i = 0; i < keys.length; i++) {
            var k = keys[i];
            if (obj != null && Object.prototype.hasOwnProperty.call(obj, k)) return obj[k];
        }
        return null;
    }
    function safeDate(v) {
        if (!v) return '';
        if (typeof v === 'object') return (v.value || String(v));
        return String(v);
    }
</script>