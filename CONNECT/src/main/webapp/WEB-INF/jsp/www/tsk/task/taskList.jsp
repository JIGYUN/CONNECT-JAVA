<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<section>
    <h2 class="mb-3">지도 그룹 목록</h2>

    <div class="mb-3">
        <button class="btn btn-primary" type="button" onclick="goToTaskModify()">글쓰기</button>
        <button class="btn btn-outline-secondary" type="button" onclick="goToTask()">통합</button>
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
            <tbody id="taskListBody"></tbody>
        </table>
    </div>
</section>

<script>
    // ▼ JavaGen 치환
    const API_BASE = '/api/tsk/task';
    const taskId = 'taskIdx';

    $(function () {
        selectTaskList();
    });

    function selectTaskList() {
        $.ajax({
            url: API_BASE + '/selectTaskList',
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

                        html += "<tr onclick=\"goToTaskModify('" + (r.taskIdx) + "')\">";
                        html += "  <td class='text-right'>" + (r.taskIdx) + "</td>";
                        html += "  <td>" + (r.title) + "</td>";
                        html += "  <td>" + (r.createUser) + "</td>";
                        html += "  <td>" + (createDate) + "</td>";
                        html += "</tr>";
                    }
                }

                $('#taskListBody').html(html);
            },
            error: function () {
                alert('목록 조회 중 오류 발생');
            }
        });
    }

    function goToTaskModify(id) {
        let url = '/tsk/task/taskModify';
        if (id) url += '?' + taskId + '=' + encodeURIComponent(id);
        location.href = url;
    }

    function goToTask() {
        location.href = '/tsk/task/task';
    }
</script>
