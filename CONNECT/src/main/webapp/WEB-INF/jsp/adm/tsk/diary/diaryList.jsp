<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<section>
    <h2 class="mb-3">쇼핑몰 목록</h2>

    <div class="mb-3">
        <button class="btn btn-primary" type="button" onclick="goToDiaryModify()">글쓰기</button>
        <button class="btn btn-outline-secondary" type="button" onclick="goToDiary()">통합</button>
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
            <tbody id="diaryListBody"></tbody>
        </table>
    </div>
</section>

<script>
    // ▼ JavaGen 치환
    const API_BASE = '/api/tsk/diary';
    const diaryId = 'diaryIdx';

    $(function () {
        selectDiaryList();
    });

    function selectDiaryList() {
        $.ajax({
            url: API_BASE + '/selectDiaryList',
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

                        html += "<tr onclick=\"goToDiaryModify('" + (r.diaryIdx) + "')\">";
                        html += "  <td class='text-right'>" + (r.diaryIdx) + "</td>";
                        html += "  <td>" + (r.title) + "</td>";
                        html += "  <td>" + (r.createUser) + "</td>";
                        html += "  <td>" + (createDate) + "</td>";
                        html += "</tr>";
                    }
                }

                $('#diaryListBody').html(html);
            },
            error: function () {
                alert('목록 조회 중 오류 발생');
            }
        });
    }

    function goToDiaryModify(id) {
        let url = '/adm/tsk/diary/diaryModify';
        if (id) url += '?' + diaryId + '=' + encodeURIComponent(id);
        location.href = url;
    }

    function goToDiary() {
        location.href = '/adm/tsk/diary/diary';
    }
</script>
