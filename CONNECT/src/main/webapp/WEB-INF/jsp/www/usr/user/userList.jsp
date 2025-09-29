<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<section>
    <h2 class="mb-3">게시판 정의 목록</h2>

    <div class="mb-3">
        <button class="btn btn-primary" type="button" onclick="goToUserModify()">글쓰기</button>
        <button class="btn btn-outline-secondary" type="button" onclick="goToUser()">통합</button>
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
            <tbody id="userListBody"></tbody>
        </table>
    </div>
</section>

<script>
    // ▼ JavaGen 치환
    const API_BASE = '/api/usr/user';
    const userId = 'userIdx';

    $(function () {
        selectUserList();
    });

    function selectUserList() {
        $.ajax({
            url: API_BASE + '/selectUserList',
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

                        html += "<tr onclick=\"goToUserModify('" + (r.userIdx) + "')\">";
                        html += "  <td class='text-right'>" + (r.userIdx) + "</td>";
                        html += "  <td>" + (r.title) + "</td>";
                        html += "  <td>" + (r.createUser) + "</td>";
                        html += "  <td>" + (createDate) + "</td>";
                        html += "</tr>";
                    }
                }

                $('#userListBody').html(html);
            },
            error: function () {
                alert('목록 조회 중 오류 발생');
            }
        });
    }

    function goToUserModify(id) {
        let url = '/usr/user/userModify';
        if (id) url += '?' + userId + '=' + encodeURIComponent(id);
        location.href = url;
    }

    function goToUser() {
        location.href = '/usr/user/user';
    }
</script>
