<%@ page contentType="text/html;charset=UTF-8" language="java" %>

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
</section>

<script>
    const API_BASE = '/api/mmp/map';
    const PK = 'mapId';

    function getParam(name){
        const u = new URL(location.href);
        return u.searchParams.get(name);
    }

    const grpCd = getParam('grpCd') || '';

    $(function () {
        selectMapList();
    });

    function selectMapList() {
        $.ajax({
            url: API_BASE + '/selectMapList',
            type: 'post',
            contentType: 'application/json',
            data: JSON.stringify({ grpCd: grpCd }),
            success: function (map) {
                const resultList = map.result || [];
                let html = '';

                if (!resultList.length) {
                    html += "<tr><td colspan='3' class='text-center text-muted'>등록된 데이터가 없습니다.</td></tr>";
                } else {
                    for (let i = 0; i < resultList.length; i++) {
                        const r = resultList[i];
                        let createDate = r.createDate || r.CREATE_DATE;
                        html += "<tr onclick=\"goToMapModify('" + (r.mapId || r.MAP_ID) + "')\">";
                        html += "  <td class='text-right'>" + (r.mapId || r.MAP_ID) + "</td>";
                        html += "  <td>" + (r.title || r.TITLE || '') + "</td>";
                        html += "  <td>" + (createDate || '') + "</td>";
                        html += "</tr>";
                    }
                }

                $('#mapListBody').html(html);
            },
            error: function () {
                alert('목록 조회 중 오류 발생');
            }
        });
    }

    function goToMapModify(id) {
        let url = '/adm/mmp/map/mapModify';
        const query = [];
        if (id) query.push(PK + '=' + encodeURIComponent(id));
        if (grpCd) query.push('grpCd=' + encodeURIComponent(grpCd));
        if (query.length) url += '?' + query.join('&');
        location.href = url;
    }

    function goToMap() {
        let url = '/adm/mmp/mapGrp/mapGrpList';   
        if (grpCd) url += '?grpCd=' + encodeURIComponent(grpCd);
        location.href = url;
    }
</script>