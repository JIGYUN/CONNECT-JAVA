<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.2/dist/css/bootstrap.min.css"/>
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script src="/static/js/paging.js"></script>

<section>
    <h2 class="mb-3">지도 목록</h2>

    <div class="mb-3">
        <button class="btn btn-primary" type="button" onclick="goToMapModify()">글쓰기</button>
        <button class="btn btn-outline-secondary" type="button" onclick="goToMap()">통합</button>
    </div>

    <div class="table-responsive">
        <table class="table table-hover align-middle">
            <thead class="thead-light">
                <tr>
                    <th style="width: 90px; text-align:right;">번호</th>
                    <th>제목</th>
                    <th style="width: 220px;">작성일</th>
                </tr>
            </thead>
            <tbody id="mapListBody"></tbody>
        </table>
    </div>

    <!-- 페이징 -->
    <div id="pager"></div>
</section>

<script>
    const API_BASE = '/api/mmp/map';
    // 서버가 페이지 메타를 내려주는 표준 엔드포인트를 사용(없다면 이 이름으로 하나만 노출해줘)
    const API_LIST = API_BASE + '/selectMapListPaged';
    const PK = 'mapId';

    function getParam(name){
        const u = new URL(location.href);
        return u.searchParams.get(name);
    }
    const grpCd = getParam('grpCd') || '';

    // ---- 페이저 (JSP는 최소: create → onChange(loadPage) → update(meta)) ----
    let pager;
    $(function () {
        pager = Paging.create('#pager', function (page, size) {
            loadPage(page, size);
        }, { size: 20, maxButtons: 7, key: 'mapList', autoLoad: true });
    });

    function loadPage(page, size) {
        $.ajax({
            url: API_LIST,
            type: 'post',
            contentType: 'application/json',
            dataType: 'json',
            data: JSON.stringify({ page: page, size: size, grpCd: grpCd }),
            success: function (res) {
                renderRows(res.result || []);
                if (res.page) pager.update(res.page); // 메타(총건수/총페이지/현재페이지) 반영 및 저장은 paging.js가
            },
            error: function () {
                alert('목록 조회 중 오류 발생');
            }
        });
    }

    function renderRows(list) {
        const $tb = $('#mapListBody').empty();
        if (!list || !list.length) {
            $tb.append("<tr><td colspan='3' class='text-center text-muted'>등록된 데이터가 없습니다.</td></tr>");
            return;
        }
        for (let i = 0; i < list.length; i++) {
            const r = list[i];
            const id = r.mapId || r.MAP_ID;
            const title = r.title || r.TITLE || '';
            const createDate = r.createDate || r.CREATE_DATE || '';
            const tr = [
                "<tr onclick=\"goToMapDetail('" + id + "')\">",
                "  <td class='text-right'>" + id + "</td>",
                "  <td>" + escapeHtml(title) + "</td>",
                "  <td>" + createDate + "</td>",
                "</tr>"
            ].join('');
            $tb.append(tr);
        }
    }

    function goToMapModify(id) {
        let url = '/mmp/map/mapModify';
        const query = [];
        if (id) query.push(PK + '=' + encodeURIComponent(id));
        if (grpCd) query.push('grpCd=' + encodeURIComponent(grpCd));
        if (query.length) url += '?' + query.join('&');
        location.href = url;
    }

    function goToMapDetail(id) {
        let url = '/mmp/map/mapDetail';
        const query = [];
        if (id) query.push(PK + '=' + encodeURIComponent(id));
        if (grpCd) query.push('grpCd=' + encodeURIComponent(grpCd));
        if (query.length) url += '?' + query.join('&');
        location.href = url;
    }

    function goToMap() {
        let url = '/mmp/mapGrp/mapGrpList';
        if (grpCd) url += '?grpCd=' + encodeURIComponent(grpCd);
        location.href = url;
    }

    function escapeHtml(s) {
        return String(s || '')
            .replace(/&/g, '&amp;')
            .replace(/</g, '&lt;')
            .replace(/>/g, '&gt;')
            .replace(/"/g, '&quot;')
            .replace(/'/g, '&#39;');
    }
</script>  