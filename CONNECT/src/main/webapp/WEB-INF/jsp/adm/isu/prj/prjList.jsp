<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<section>
    <h2 class="mb-3">이슈 목록</h2>

    <div class="mb-3">
        <button class="btn btn-primary" type="button" onclick="goToprjModify()">글쓰기</button>
        <button class="btn btn-outline-secondary" type="button" onclick="goToprj()">통합</button>
    </div>

    <div class="table-responsive">
        <table class="table table-hover align-middle">
            <thead class="thead-light">
                <tr>
                    <th style="width: 90px; text-align:right;">번호</th>
                    <th>제목</th>
                    <th style="width: 160px;">작성자</th>
                    <th style="width: 220px;">작성일</th>
                </tr>
            </thead>
            <tbody id="prjListBody"></tbody>
        </table>
    </div>
</section>

<script>
    // ▼ JavaGen 치환
    const API_BASE = '/api/isu/prj';
    const prjId = 'prjIdx';

    $(function () {
        selectprjList();
    });

    function selectprjList() {
        $.ajax({
            url: API_BASE + '/selectprjList',
            type: 'post',
            contentType: 'application/json',
            data: JSON.stringify({}),
            success: function (map) {
                const resultList = map.result || [];
                let html = '';

                if (!resultList.length) {
                    html += "<tr><td colspan='4' class='text-center text-muted'>등록된 데이터가 없습니다.</td></tr>";
                } else {
                    for (let i = 0; i < resultList.length; i++) {
                        const r = resultList[i];
                        let createDate = r.createDate;
                        if (createDate && typeof createDate === 'object') {
                            createDate = (createDate.value || String(createDate));
                        }

                        html += "<tr onclick=\"goToprjModify('" + (r.prjIdx) + "')\">";
                        html += "  <td class='text-right'>" + (r.prjIdx) + "</td>";
                        html += "  <td>" + (r.title) + "</td>";
                        html += "  <td>" + (r.createUser) + "</td>";
                        html += "  <td>" + (createDate) + "</td>";
                        html += "</tr>";
                    }
                }

                $('#prjListBody').html(html);
            },
            error: function () {
                alert('목록 조회 중 오류 발생');
            }
        });
    }

    function goToprjModify(id) {
        let url = '/adm/isu/prj/prjModify';
        if (id) url += '?' + prjId + '=' + encodeURIComponent(id);
        location.href = url;
    }

    function goToprj() {
        location.href = '/adm/isu/prj/prj';
    }
</script>
