<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<section>
    <h2 class="mb-3">테스트 목록</h2>

    <div class="mb-3">
        <button class="btn btn-primary" type="button" onclick="goToTesttModify()">글쓰기</button>
        <button class="btn btn-outline-secondary" type="button" onclick="goToTestt()">통합</button>
    </div>

    <div class="table-responsive">
        <table class="table table-hover align-middle">
            <thead class="thead-light">
                <tr>
                                        <th class="text-nowrap" style="width: 90px; white-space:nowrap; text-align:right;">번호</th>
                    <th class="text-nowrap" style="width: 120px; white-space:nowrap;">상태</th>
                    <th class="text-nowrap" style="width: 80px; white-space:nowrap;">공지</th>
                    <th class="text-nowrap" style="width: 80px; white-space:nowrap;">고정</th>
                    <th class="text-nowrap" style="width: 90px; white-space:nowrap;">비공개</th>
                    <th class="text-nowrap" style="white-space:nowrap;">제목</th>
                    <th class="text-nowrap" style="width: 90px; white-space:nowrap; text-align:right;">정렬</th>
                    <th class="text-nowrap" style="width: 90px; white-space:nowrap; text-align:right;">조회수</th>
                    <th class="text-nowrap" style="width: 90px; white-space:nowrap; text-align:right;">추천수</th>
                    <th class="text-nowrap" style="width: 90px; white-space:nowrap; text-align:right;">댓글수</th>
                    <th class="text-nowrap" style="width: 80px; white-space:nowrap;">사용</th>
                    <th class="text-nowrap" style="width: 220px; white-space:nowrap;">작성일</th>
                    <th class="text-nowrap" style="width: 160px; white-space:nowrap;">작성자</th>
                </tr>
            </thead>
            <tbody id="testtListBody"></tbody>
        </table>
    </div>
</section>

<script>
    // ▼ JavaGen 치환
    const API_BASE = '/api/tst/testt';
    const testtIdx = 'testtIdx';

    $(function () {
        selectTesttList();
    });

    function fmtCell(v) {
        if (v === null || v === undefined) return '';
        if (typeof v === 'object') {
            if (v.value !== undefined && v.value !== null) return String(v.value);
            return String(v);
        }
        return String(v);
    }

    function selectTesttList() {
        $.ajax({
            url: API_BASE + '/selectTesttList',
            type: 'post',
            contentType: 'application/json',
            data: JSON.stringify({}),
            success: function (map) {
                const resultList = map.result || [];
                let html = '';

                if (!resultList.length) {
                    html += "<tr><td colspan='13' class='text-center text-muted'>등록된 데이터가 없습니다.</td></tr>";
                } else {
                    for (let i = 0; i < resultList.length; i++) {
                        const r = resultList[i];

                        html += "<tr onclick=\"goToTesttModify('" + (r.testtIdx) + "')\">";
                        html += "  <td class='text-right'>" + (fmtCell(r.testtIdx)) + "</td>";
                        html += "  <td>" + (fmtCell(r.statusCd)) + "</td>";
                        html += "  <td>" + (fmtCell(r.noticeAt)) + "</td>";
                        html += "  <td>" + (fmtCell(r.pinAt)) + "</td>";
                        html += "  <td>" + (fmtCell(r.secretAt)) + "</td>";
                        html += "  <td>" + (fmtCell(r.title)) + "</td>";
                        html += "  <td class='text-right'>" + (fmtCell(r.sortOrdr)) + "</td>";
                        html += "  <td class='text-right'>" + (fmtCell(r.viewCnt)) + "</td>";
                        html += "  <td class='text-right'>" + (fmtCell(r.likeCnt)) + "</td>";
                        html += "  <td class='text-right'>" + (fmtCell(r.commentCnt)) + "</td>";
                        html += "  <td>" + (fmtCell(r.useAt)) + "</td>";
                        html += "  <td>" + (fmtCell(r.createdDt)) + "</td>";
                        html += "  <td>" + (fmtCell(r.createdBy)) + "</td>";
                        html += "</tr>";
                    }
                }

                $('#testtListBody').html(html);
            },
            error: function () {
                alert('목록 조회 중 오류 발생');
            }
        });
    }

    function goToTesttModify(id) {
        let url = '/tst/testt/testtModify';
        if (id) url += '?' + testtIdx + '=' + encodeURIComponent(id);
        location.href = url;
    }

    function goToTestt() {
        location.href = '/tst/testt/testt';
    }
</script>
