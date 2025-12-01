<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<section>
    <div class="d-flex justify-content-between align-items-center mb-3">
        <div>
            <h2 class="mb-0">Projects</h2>
            <small class="text-muted">Jira-style 프로젝트 목록</small>
        </div>
        <button type="button"
                class="btn btn-primary"
                data-toggle="modal"
                data-target="#prjModal">
            새 프로젝트
        </button>
    </div>

    <div class="table-responsive">
        <table class="table table-hover align-middle">
            <thead class="thead-light">
                <tr>
                    <th style="width: 80px;">Key</th>
                    <th>이름</th>
                    <th style="width: 120px;">상태</th>
                    <th style="width: 180px;">생성일</th>
                    <th style="width: 80px; text-align:center;">관리</th>
                </tr>
            </thead>
            <tbody id="prjListBody"></tbody>
        </table>
    </div>
</section>

<!-- 프로젝트 생성 모달 -->
<div class="modal fade" id="prjModal" tabindex="-1" role="dialog" aria-labelledby="prjModalLabel"
     aria-hidden="true">
    <div class="modal-dialog" role="document">
        <form id="prjForm" class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="prjModalLabel">새 프로젝트 생성</h5>
                <button type="button" class="close" data-dismiss="modal" aria-label="닫기">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>
            <div class="modal-body">

                <div class="form-group">
                    <label for="prjKeyInput">Project Key</label>
                    <input type="text"
                           class="form-control"
                           id="prjKeyInput"
                           placeholder="예: DEMO"
                           maxlength="16"
                           required>
                    <small class="form-text text-muted">
                        이슈 키 앞에 붙는 짧은 코드 (영문 대문자 권장)
                    </small>
                </div>

                <div class="form-group">
                    <label for="prjNmInput">프로젝트 이름</label>
                    <input type="text"
                           class="form-control"
                           id="prjNmInput"
                           placeholder="프로젝트 이름"
                           required>
                </div>

                <div class="form-group">
                    <label for="prjDescInput">설명</label>
                    <textarea class="form-control"
                              id="prjDescInput"
                              rows="3"
                              placeholder="간단한 설명 (선택)"></textarea>
                </div>

                <div class="form-group">
                    <label for="statusSelect">상태</label>
                    <select id="statusSelect" class="form-control">
                        <option value="ACTIVE">ACTIVE</option>
                        <option value="ARCHIVED">ARCHIVED</option>
                    </select>
                </div>

                <div class="form-group">
                    <label for="colorInput">컬러 코드</label>
                    <input type="text"
                           class="form-control"
                           id="colorInput"
                           placeholder="#0052CC"
                           maxlength="16">
                    <small class="form-text text-muted">
                        선택값. 이슈 보드에서 프로젝트 배지 색으로 사용할 수 있음.
                    </small>
                </div>

            </div>
            <div class="modal-footer">
                <button type="button"
                        class="btn btn-outline-secondary"
                        data-dismiss="modal">취소</button>
                <button type="submit" class="btn btn-primary">생성</button>
            </div>
        </form>
    </div>
</div>

<script>
    const API_PRJ_BASE = '/api/isu/prj';
    const PRJ_ID_PARAM = 'prjId';
    const FIXED_GRP_CD = 'JIRA'; // 필요하면 다른 grpCd로 바꿔서 사용

    (function () {
        loadProjectList();

        $('#prjForm').on('submit', function (e) {
            e.preventDefault();
            createProject();
        });
    })();

    function loadProjectList() {
        const payload = {
            grpCd: FIXED_GRP_CD,
            useAt: 'Y'
        };

        $.ajax({
            url: API_PRJ_BASE + '/selectprjList',
            type: 'post',
            contentType: 'application/json',
            dataType: 'json',
            data: JSON.stringify(payload),
            success: function (map) {
                const resultList = map.result || [];
                let html = '';

                if (!resultList.length) {
                    html += "<tr><td colspan='5' class='text-center text-muted'>등록된 프로젝트가 없습니다.</td></tr>";
                } else {
                    for (let i = 0; i < resultList.length; i++) {
                        const r = resultList[i];
                        const prjId = r.prjId;
                        const prjKey = r.prjKey || '';
                        const prjNm = r.prjNm || '';
                        const prjDesc = r.prjDesc || '';
                        const statusCd = r.statusCd || '';
                        const colorCd = r.colorCd || '';
                        let createdDt = r.createdDt;

                        if (createdDt && typeof createdDt === 'object') {
                            createdDt = (createdDt.value || String(createdDt));
                        }

                        html += "<tr onclick=\"goToIssueBoard('" + prjId + "')\">";
                        html += "  <td><strong>" + escapeHtml(prjKey) + "</strong></td>";
                        html += "  <td>";
                        html +=        escapeHtml(prjNm);
                        if (prjDesc) {
                            html += "<div class='text-muted' style='font-size:11px;'>" + escapeHtml(prjDesc) + "</div>";
                        }
                        html += "  </td>";
                        html += "  <td>";
                        html += "    <span class='badge badge-" + mapStatusToBadge(statusCd) + "'>";
                        html +=          escapeHtml(statusCd || 'UNKNOWN');
                        html += "    </span>";
                        if (colorCd) {
                            html += "    <span style='display:inline-block;width:12px;height:12px;border-radius:50%;margin-left:6px;background:" + escapeHtml(colorCd) + ";'></span>";
                        }
                        html += "  </td>";
                        html += "  <td>" + escapeHtml((createdDt || '').toString()) + "</td>";
                        html += "  <td class='text-center'>";
                        html += "    <button type='button' class='btn btn-outline-danger btn-sm'";
                        html += "            onclick=\"event.stopPropagation(); deleteProject('" + prjId + "')\">삭제</button>";
                        html += "  </td>";
                        html += "</tr>";
                    }
                }

                $('#prjListBody').html(html);
            },
            error: function () {
                alert('프로젝트 목록 조회 중 오류 발생');
            }
        });
    }

    function createProject() {
        const prjKey = ($('#prjKeyInput').val() || '').trim();
        const prjNm = ($('#prjNmInput').val() || '').trim();
        const prjDesc = ($('#prjDescInput').val() || '').trim();
        const statusCd = $('#statusSelect').val() || 'ACTIVE';
        const colorCd = ($('#colorInput').val() || '').trim();

        if (!prjKey || !prjNm) {
            alert('Project Key와 이름은 필수입니다.');
            return;
        }

        const payload = {
            grpCd: FIXED_GRP_CD,
            prjKey: prjKey,
            prjNm: prjNm,
            prjDesc: prjDesc,
            statusCd: statusCd,
            colorCd: colorCd,
            useAt: 'Y'
        };

        $.ajax({
            url: API_PRJ_BASE + '/insertprj',
            type: 'post',
            contentType: 'application/json',
            dataType: 'json',
            data: JSON.stringify(payload),
            success: function () {
                $('#prjModal').modal('hide');
                $('#prjForm')[0].reset();
                loadProjectList();
            },
            error: function (xhr) {
                alert('프로젝트 생성 실패: ' + (xhr.responseText || xhr.status));
            }
        });
    }

    function deleteProject(prjId) {
        if (!prjId) return;
        if (!confirm('이 프로젝트를 삭제하시겠습니까?')) return;

        const payload = {};
        payload[PRJ_ID_PARAM] = prjId;

        $.ajax({
            url: API_PRJ_BASE + '/deleteprj',
            type: 'post',
            contentType: 'application/json',
            dataType: 'json',
            data: JSON.stringify(payload),
            success: function () {
                loadProjectList();
            },
            error: function (xhr) {
                alert('삭제 실패: ' + (xhr.responseText || xhr.status));
            }
        });
    }

    // 프로젝트 클릭 → 해당 프로젝트 이슈 보드 (Jira처럼)
    function goToIssueBoard(prjId) {
        if (!prjId) return;
        var url = '/isu/issue/issueBoard?grpCd=' + encodeURIComponent(FIXED_GRP_CD)
                + '&prjId=' + encodeURIComponent(prjId);
        location.href = url;
    }

    function mapStatusToBadge(statusCd) {
        if (!statusCd) return 'secondary';
        if (statusCd === 'ACTIVE') return 'success';
        if (statusCd === 'ARCHIVED') return 'dark';
        return 'secondary';
    }

    function escapeHtml(s) {
        return String(s == null ? '' : s).replace(/[&<>"']/g, function (m) {
            return { '&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;' }[m];
        });
    }
</script>
