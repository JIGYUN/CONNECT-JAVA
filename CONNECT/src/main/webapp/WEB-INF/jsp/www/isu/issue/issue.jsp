<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<section>
    <div class="d-flex justify-content-between align-items-center mb-3">
        <div>
            <h2 class="mb-0">Issue</h2>
            <small class="text-muted">프로젝트별 Jira-style 이슈 보드</small>
        </div>
        <div class="d-flex align-items-center">
            <!-- 신규 프로젝트 생성 버튼 -->  
            <button type="button" 
                    class="btn btn-outline-secondary btn-sm mr-2"
                    id="createProjectBtn"
                    data-toggle="modal"
                    data-target="#projectModal">
                + Project
            </button>

            <!-- 프로젝트 선택 -->
            <div class="mr-2">
                <select id="prjSelect" class="form-control form-control-sm"></select>
            </div>

            <!-- 이슈 생성 버튼 -->
            <button type="button"
                    class="btn btn-primary btn-sm"
                    id="createIssueBtn"
                    data-toggle="modal"
                    data-target="#issueModal"
                    disabled>
                Create
            </button>
        </div>
    </div>

    <!-- 칸반 보드 -->
    <div class="isu-board-wrapper">
        <div class="isu-board-column"
             data-status="TODO"
             ondragover="handleColumnDragOver(event)"
             ondragenter="handleColumnDragEnter(event)"
             ondragleave="handleColumnDragLeave(event)"
             ondrop="handleColumnDrop(event, 'TODO')">
            <div class="isu-board-column-header">
                <div class="isu-board-column-title">TO DO</div>
                <div class="isu-board-column-count" id="cnt_TODO">0</div>
            </div>
            <div id="col_TODO" class="isu-board-column-body"></div>
        </div>

        <div class="isu-board-column"
             data-status="IN_PROGRESS"
             ondragover="handleColumnDragOver(event)"
             ondragenter="handleColumnDragEnter(event)"
             ondragleave="handleColumnDragLeave(event)"
             ondrop="handleColumnDrop(event, 'IN_PROGRESS')">
            <div class="isu-board-column-header">
                <div class="isu-board-column-title">IN PROGRESS</div>
                <div class="isu-board-column-count" id="cnt_IN_PROGRESS">0</div>
            </div>
            <div id="col_IN_PROGRESS" class="isu-board-column-body"></div>
        </div>

        <div class="isu-board-column"
             data-status="IN_REVIEW"
             ondragover="handleColumnDragOver(event)"
             ondragenter="handleColumnDragEnter(event)"
             ondragleave="handleColumnDragLeave(event)"
             ondrop="handleColumnDrop(event, 'IN_REVIEW')">
            <div class="isu-board-column-header">
                <div class="isu-board-column-title">IN REVIEW</div>
                <div class="isu-board-column-count" id="cnt_IN_REVIEW">0</div>
            </div>
            <div id="col_IN_REVIEW" class="isu-board-column-body"></div>
        </div>

        <div class="isu-board-column"
             data-status="DONE"
             ondragover="handleColumnDragOver(event)"
             ondragenter="handleColumnDragEnter(event)"
             ondragleave="handleColumnDragLeave(event)"
             ondrop="handleColumnDrop(event, 'DONE')">
            <div class="isu-board-column-header">
                <div class="isu-board-column-title">DONE</div>
                <div class="isu-board-column-count" id="cnt_DONE">0</div>
            </div>
            <div id="col_DONE" class="isu-board-column-body"></div>
        </div>
    </div>
</section>

<!-- ▽ 프로젝트 생성 모달 -->
<div class="modal fade" id="projectModal" tabindex="-1" role="dialog" aria-labelledby="projectModalLabel"
     aria-hidden="true">
    <div class="modal-dialog" role="document">
        <form id="projectForm" class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="projectModalLabel">새 프로젝트 생성</h5>
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
                           placeholder="예: DEMO, CONNECT"
                           required>
                    <small class="form-text text-muted">
                        이슈 키 prefix 로 사용됩니다. (예: DEMO-1, DEMO-2)
                    </small>
                </div>

                <div class="form-group">
                    <label for="prjNmInput">Project Name</label>
                    <input type="text"
                           class="form-control"
                           id="prjNmInput"
                           placeholder="프로젝트 이름"
                           required>
                </div>

                <div class="form-group">
                    <label for="prjDescInput">Description</label>
                    <textarea id="prjDescInput"
                              class="form-control"
                              rows="3"
                              placeholder="선택사항"></textarea>
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

<!-- ▽ 이슈 생성 모달 -->
<div class="modal fade" id="issueModal" tabindex="-1" role="dialog" aria-labelledby="issueModalLabel"
     aria-hidden="true">
    <div class="modal-dialog" role="document">
        <form id="issueForm" class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="issueModalLabel">새 이슈 생성</h5>
                <button type="button" class="close" data-dismiss="modal" aria-label="닫기">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>
            <div class="modal-body">

                <div class="form-group">
                    <label for="summaryInput">Summary</label>
                    <input type="text"
                           class="form-control"
                           id="summaryInput"
                           placeholder="무엇을 해야 하나요?"
                           required>
                </div>

                <div class="form-group">
                    <label for="issueTypeSelect">Issue Type</label>
                    <select id="issueTypeSelect" class="form-control">
                        <option value="TASK">Task</option>
                        <option value="BUG">Bug</option>
                        <option value="STORY">Story</option>
                    </select>
                </div>

                <div class="form-group">
                    <label for="prioritySelect">Priority</label>
                    <select id="prioritySelect" class="form-control">
                        <option value="MEDIUM">Medium</option>
                        <option value="HIGH">High</option>
                        <option value="LOW">Low</option>
                    </select>
                </div>

                <div class="form-group">
                    <label for="dueDtInput">Due Date</label>
                    <input type="date"
                           class="form-control"
                           id="dueDtInput">
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

<!-- ▽ 이슈 댓글 모달 -->
<div class="modal fade" id="issueCommentModal" tabindex="-1" role="dialog" aria-labelledby="issueCommentModalLabel"
     aria-hidden="true">
    <div class="modal-dialog modal-lg" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <div>
                    <h5 class="modal-title" id="issueCommentModalLabel">Issue Comments</h5>
                    <small class="text-muted" id="issueCommentIssueHeader"></small>
                </div>
                <div>
                    <button type="button"
                            class="btn btn-outline-secondary btn-sm mr-2"
                            id="issueDetailBtn">
                        상세 화면
                    </button>
                    <button type="button" class="close" data-dismiss="modal" aria-label="닫기">
                        <span aria-hidden="true">&times;</span>
                    </button>
                </div>
            </div>
            <div class="modal-body">

                <div id="issueCommentList" class="mb-3" style="max-height: 320px; overflow-y:auto;">
                    <!-- 댓글 목록 렌더링 -->
                </div>

                <div class="form-group mb-0">
                    <label for="issueCommentInput">새 댓글</label>
                    <textarea id="issueCommentInput"
                              class="form-control"
                              rows="3"
                              placeholder="댓글을 입력하고 Ctrl+Enter 또는 등록 버튼을 누르세요."></textarea>
                    <div class="d-flex justify-content-between align-items-center mt-2">
                        <small class="text-muted">Session 로그인 계정으로 작성자 자동 설정</small>
                        <button type="button"
                                class="btn btn-primary btn-sm"
                                onclick="submitIssueComment()">
                            등록
                        </button>
                    </div>
                </div>

            </div>
        </div>
    </div>
</div>

<style>
    .isu-board-wrapper {
        display: flex;
        gap: 16px;
        overflow-x: auto;
    }
    .isu-board-column {
        flex: 1 0 240px;
        background: #f4f5f7;
        border-radius: 8px;
        padding: 8px;
        max-height: 600px;
        display: flex;
        flex-direction: column;
        transition: background 0.1s ease;
    }
    .isu-board-column-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        padding: 4px 4px 8px;
        border-bottom: 1px solid #dfe1e6;
        margin-bottom: 4px;
    }
    .isu-board-column-title {
        font-weight: 600;
        font-size: 13px;
        text-transform: uppercase;
    }
    .isu-board-column-count {
        font-size: 11px;
        color: #6b778c;
        padding: 0 6px;
        border-radius: 999px;
        background: #e1e4ea;
    }
    .isu-board-column-body {
        padding-top: 4px;
        overflow-y: auto;
    }
    .isu-board-column-hover {
        background: #e9f2ff;
    }
    .isu-issue-card {
        background: #ffffff;
        border-radius: 6px;
        padding: 8px 10px;
        margin-bottom: 8px;
        box-shadow: 0 1px 2px rgba(9,30,66,0.25);
        font-size: 12px;
        cursor: grab;
    }
    .isu-issue-card:active {
        cursor: grabbing;
    }
    .isu-issue-card:hover {
        box-shadow: 0 4px 8px rgba(9,30,66,0.25);
    }
    .isu-issue-key {
        font-weight: 600;
        margin-right: 4px;
        color: #42526e;
        font-size: 11px;
    }
    .isu-issue-summary {
        display: block;
        margin-bottom: 4px;
        word-break: break-word;
    }
    .isu-issue-meta {
        margin-bottom: 4px;
    }
    .isu-issue-meta .badge {
        font-size: 10px;
        margin-right: 3px;
    }
    .isu-issue-actions .btn {
        font-size: 10px;
        padding: 2px 6px;
    }

    /* 댓글 리스트용 */
    .isu-comment-item {
        padding: 6px 4px;
        border-bottom: 1px solid #eee;
        font-size: 13px;
    }
    .isu-comment-header {
        display: flex;
        justify-content: space-between;
        margin-bottom: 2px;
    }
    .isu-comment-author {
        font-weight: 600;
    }
    .isu-comment-date {
        font-size: 11px;
        color: #888;
    }
    .isu-comment-body {
        white-space: pre-wrap;
        word-break: break-word;
    }
</style>

<script>
    const API_ISSUE = '/api/isu/issue';
    const API_PRJ = '/api/isu/prj';
    const API_ISSUE_COMMENT = '/api/isu/issueComment';

    const STATUS_COLUMNS = [
        { code: 'TODO',        label: 'TO DO' },
        { code: 'IN_PROGRESS', label: 'IN PROGRESS' },
        { code: 'IN_REVIEW',   label: 'IN REVIEW' },
        { code: 'DONE',        label: 'DONE' }
    ];

    let currentGrpCd = getQueryParam('grpCd') || 'JIRA';
    let currentPrjId = null;
    let issueBoardCache = [];

    // 드래그 중인 이슈 ID
    let dragIssueId = null;

    // 댓글 모달에서 사용할 현재 이슈 정보
    let currentIssueIdForComment = null;
    let currentIssueKeyForComment = '';
    let currentIssueSummaryForComment = '';

    (function () {
        bindProjectSelect();
        bindProjectForm();
        bindIssueForm();
        bindCommentKeydown();
        loadProjectList();
    })();

    function bindProjectSelect() {
        $('#prjSelect').on('change', function () {
            const prjId = $(this).val();
            currentPrjId = prjId || null;
            $('#createIssueBtn').prop('disabled', !currentPrjId);
            loadIssueBoard();
        });
    }

    // 프로젝트 생성 폼 submit
    function bindProjectForm() {
        $('#projectForm').on('submit', function (e) {
            e.preventDefault();
            createProject();
        });
    }

    function bindIssueForm() {
        $('#issueForm').on('submit', function (e) {
            e.preventDefault();
            createIssue();
        });
    }

    function bindCommentKeydown() {
        $('#issueCommentInput').on('keydown', function (e) {
            if (e.key === 'Enter' && e.ctrlKey) {
                e.preventDefault();
                submitIssueComment();
            }
        });
    }

    // 프로젝트 목록 로드 (preferredPrjKey: 새로 만든 프로젝트를 자동 선택용)
    function loadProjectList(preferredPrjKey) {
        const payload = {
            grpCd: currentGrpCd,
            useAt: 'Y'
        };

        $.ajax({
            url: API_PRJ + '/selectprjList',
            type: 'post',
            contentType: 'application/json',
            dataType: 'json',
            data: JSON.stringify(payload),
            success: function (map) {
                const list = map.result || [];
                const $sel = $('#prjSelect');
                $sel.empty();

                if (!list.length) {
                    $sel.append('<option value="">프로젝트 없음</option>');
                    $('#createIssueBtn').prop('disabled', true);
                    renderEmptyBoard();
                    return;
                }

                let selectedPrjIdFromQuery = getQueryParam('prjId');
                let defaultPrjId = null;
                let preferredPrjId = null;

                for (let i = 0; i < list.length; i++) {
                    const p = list[i];
                    const prjId = p.prjId;
                    const prjKey = p.prjKey;
                    const text = (prjKey || '') + ' - ' + (p.prjNm || '');
                    const opt = $('<option/>').val(prjId).text(text);
                    $sel.append(opt);

                    if (!defaultPrjId) {
                        defaultPrjId = prjId;
                    }
                    if (preferredPrjKey && prjKey === preferredPrjKey) {
                        preferredPrjId = prjId;
                    }
                }

                if (preferredPrjId) {
                    currentPrjId = preferredPrjId;
                    $sel.val(String(preferredPrjId));
                } else if (selectedPrjIdFromQuery) {
                    currentPrjId = selectedPrjIdFromQuery;
                    $sel.val(selectedPrjIdFromQuery);
                } else {
                    currentPrjId = defaultPrjId;
                    $sel.val(defaultPrjId);
                }

                $('#createIssueBtn').prop('disabled', !currentPrjId);
                loadIssueBoard();
            },
            error: function () {
                alert('프로젝트 목록 조회 중 오류 발생');
                renderEmptyBoard();
            }
        });
    }

    // ▽ 프로젝트 생성 (보드 화면에서 바로 추가)
    function createProject() {
        const prjKey = ($('#prjKeyInput').val() || '').trim();
        const prjNm  = ($('#prjNmInput').val() || '').trim();
        const prjDesc = ($('#prjDescInput').val() || '').trim();

        if (!prjKey) {
            alert('Project Key 를 입력하세요.');
            return;
        }
        if (!prjNm) {
            alert('Project Name 을 입력하세요.');
            return;
        }

        const payload = {
            grpCd: currentGrpCd,
            prjKey: prjKey,
            prjNm: prjNm,
            prjDesc: prjDesc || null,
            useAt: 'Y'
        };

        $.ajax({
            url: API_PRJ + '/insertprj',
            type: 'post',
            contentType: 'application/json',
            dataType: 'json',
            data: JSON.stringify(payload),
            success: function () {
                $('#projectModal').modal('hide');
                $('#projectForm')[0].reset();

                // 방금 만든 prjKey 우선 선택해서 보드 로드
                loadProjectList(prjKey);
            },
            error: function (xhr) {
                alert('프로젝트 생성 실패: ' + (xhr.responseText || xhr.status));
            }
        });
    }

    // 보드용 이슈 목록 로드
    function loadIssueBoard() {
        if (!currentPrjId) {
            renderEmptyBoard();
            return;
        }

        const payload = {
            grpCd: currentGrpCd,
            prjId: currentPrjId
        };

        $.ajax({
            url: API_ISSUE + '/selectIssueBoardList',
            type: 'post',
            contentType: 'application/json',
            dataType: 'json',
            data: JSON.stringify(payload),
            success: function (map) {
                issueBoardCache = map.result || [];
                renderBoard(issueBoardCache);
            },
            error: function () {
                alert('이슈 보드 조회 중 오류 발생');
                renderEmptyBoard();
            }
        });
    }

    // 이슈 생성
    function createIssue() {
        if (!currentPrjId) {
            alert('먼저 프로젝트를 선택하세요.');
            return;
        }

        const summary = ($('#summaryInput').val() || '').trim();
        const issueTypeCd = $('#issueTypeSelect').val() || 'TASK';
        const priorityCd = $('#prioritySelect').val() || 'MEDIUM';
        const dueDateRaw = $('#dueDtInput').val() || '';

        if (!summary) {
            alert('Summary를 입력하세요.');
            return;
        }

        const payload = {
            grpCd: currentGrpCd,
            prjId: currentPrjId,
            summary: summary,
            issueTypeCd: issueTypeCd,
            priorityCd: priorityCd,
            statusCd: 'TODO',
            dueDt: dueDateRaw ? dueDateRaw + ' 00:00:00' : null,
            useAt: 'Y'
        };

        $.ajax({
            url: API_ISSUE + '/insertIssue',
            type: 'post',
            contentType: 'application/json',
            dataType: 'json',
            data: JSON.stringify(payload),
            success: function () {
                $('#issueModal').modal('hide');
                $('#issueForm')[0].reset();
                loadIssueBoard();
            },
            error: function (xhr) {
                alert('이슈 생성 실패: ' + (xhr.responseText || xhr.status));
            }
        });
    }

    // 칸반 보드 렌더링
    function renderBoard(list) {
        const countByStatus = {
            TODO: 0,
            IN_PROGRESS: 0,
            IN_REVIEW: 0,
            DONE: 0
        };

        STATUS_COLUMNS.forEach(function (col) {
            const colId = '#col_' + col.code;
            const $body = $(colId);
            $body.empty();

            const items = list.filter(function (r) {
                return (r.statusCd === col.code);
            });

            countByStatus[col.code] = items.length;

            if (!items.length) {
                $body.append(
                    "<div class='text-muted' style='font-size:11px; padding:4px 2px;'>이슈 없음</div>"
                );
                return;
            }

            items.forEach(function (r) {
                const issueId = r.issueId;
                const issueKey = r.issueKey || '';
                const summary = r.summary || '';
                const typeCd = r.issueTypeCd || '';
                const priorityCd = r.priorityCd || '';
                const dueDt = r.dueDt || '';

                let html = '';
                html += '<div class="isu-issue-card"';
                html += ' data-issue-id="' + issueId + '"';
                html += ' data-issue-key="' + escapeHtml(issueKey) + '"';
                html += ' data-issue-summary="' + escapeHtml(summary) + '"';
                html += ' draggable="true"';
                html += ' ondragstart="handleCardDragStart(event, \'' + issueId + '\')"';
                html += ' onclick="handleIssueCardClick(this)">';
                html += '  <span class="isu-issue-key">' + escapeHtml(issueKey) + '</span>';
                html += '  <span class="isu-issue-summary">' + escapeHtml(summary) + '</span>';
                html += '  <div class="isu-issue-meta mb-1">';
                if (typeCd) {
                    html += '    <span class="badge badge-secondary">' + escapeHtml(typeCd) + '</span>';
                }
                if (priorityCd) {
                    html += '    <span class="badge badge-info">' + escapeHtml(priorityCd) + '</span>';
                }
                if (dueDt) {
                    html += '    <span class="badge badge-light">' + escapeHtml(dueDt.substring(0, 10)) + '</span>';
                }
                html += '  </div>';
                html += '  <div class="isu-issue-actions btn-group btn-group-sm" role="group">';
                getAvailableStatusActions(r.statusCd).forEach(function (action) {
                    html += '    <button type="button" class="btn btn-outline-primary"';
                    html += '            onclick="event.stopPropagation(); changeStatus(\'' + issueId + '\', \'' + action.code + '\')">';
                    html +=          escapeHtml(action.label);
                    html += '    </button>';
                });
                html += '  </div>';
                html += '</div>';

                $body.append(html);
            });
        });

        Object.keys(countByStatus).forEach(function (st) {
            $('#cnt_' + st).text(countByStatus[st] || 0);
        });
    }

    function renderEmptyBoard() {
        STATUS_COLUMNS.forEach(function (col) {
            $('#col_' + col.code).html(
                "<div class='text-muted' style='font-size:11px; padding:4px 2px;'>이슈 없음</div>"
            );
            $('#cnt_' + col.code).text('0');
        });
    }

    // 상태 전환 정의 (버튼용)
    function getAvailableStatusActions(currentStatus) {
        if (currentStatus === 'TODO') {
            return [{ code: 'IN_PROGRESS', label: 'Start' }];
        }
        if (currentStatus === 'IN_PROGRESS') {
            return [
                { code: 'TODO',        label: 'Backlog' },
                { code: 'IN_REVIEW',   label: 'Review' }
            ];
        }
        if (currentStatus === 'IN_REVIEW') {
            return [
                { code: 'IN_PROGRESS', label: 'Re-open' },
                { code: 'DONE',        label: 'Done' }
            ];
        }
        if (currentStatus === 'DONE') {
            return [{ code: 'IN_REVIEW', label: 'Undo' }];
        }
        return [];
    }

    // ───────────────── 드래그 & 드롭 핸들러 ─────────────────

    function handleCardDragStart(ev, issueId) {
        dragIssueId = issueId;
        if (ev && ev.dataTransfer) {
            ev.dataTransfer.effectAllowed = 'move';
            ev.dataTransfer.setData('text/plain', String(issueId));
        }
    }

    function handleColumnDragOver(ev) {
        if (!dragIssueId) return;
        ev.preventDefault();
        if (ev && ev.dataTransfer) {
            ev.dataTransfer.dropEffect = 'move';
        }
    }

    function handleColumnDragEnter(ev) {
        if (!dragIssueId) return;
        ev.preventDefault();
        const target = ev.currentTarget || ev.target;
        $(target).addClass('isu-board-column-hover');
    }

    function handleColumnDragLeave(ev) {
        const target = ev.currentTarget || ev.target;
        $(target).removeClass('isu-board-column-hover');
    }

    function handleColumnDrop(ev, nextStatus) {
        if (!dragIssueId) return;
        ev.preventDefault();
        const target = ev.currentTarget || ev.target;
        $(target).removeClass('isu-board-column-hover');

        const issueIdFromDnd = (ev.dataTransfer && ev.dataTransfer.getData('text/plain')) || dragIssueId;
        const finalIssueId = issueIdFromDnd || dragIssueId;

        dragIssueId = null;

        if (!finalIssueId) {
            return;
        }

        // 로컬 캐시 + 화면 즉시 갱신
        applyLocalStatusChange(finalIssueId, nextStatus);

        // 서버 상태 갱신 (optimistic)
        changeStatus(finalIssueId, nextStatus, { optimistic: true });
    }

    function applyLocalStatusChange(issueId, nextStatus) {
        const idStr = String(issueId);

        for (let i = 0; i < issueBoardCache.length; i++) {
            const row = issueBoardCache[i];
            if (String(row.issueId) === idStr) {
                row.statusCd = nextStatus;
                break;
            }
        }

        renderBoard(issueBoardCache);
    }

    // 상태 변경 (버튼/드래그 공통)
    function changeStatus(issueId, nextStatus, options) {
        if (!issueId || !nextStatus) return;

        const optimistic = options && options.optimistic;

        const payload = {
            issueId: issueId,
            statusCd: nextStatus
        };

        $.ajax({
            url: API_ISSUE + '/updateIssueStatus',
            type: 'post',
            contentType: 'application/json',
            dataType: 'json',
            data: JSON.stringify(payload),
            success: function () {
                if (!optimistic) {
                    loadIssueBoard();
                }
            },
            error: function (xhr) {
                alert('상태 변경 실패: ' + (xhr.responseText || xhr.status));
                loadIssueBoard();
            }
        });
    }

    // ───────────────── 이슈 상세 / 댓글 연동 ─────────────────

    // 카드 클릭 시: 댓글 모달 열기
    function handleIssueCardClick(el) {
        const issueId = el.getAttribute('data-issue-id');
        const issueKey = el.getAttribute('data-issue-key') || '';
        const summary = el.getAttribute('data-issue-summary') || '';

        openIssueComments(issueId, issueKey, summary);
    }

    function openIssueComments(issueId, issueKey, summary) {
        if (!issueId) return;

        currentIssueIdForComment = issueId;
        currentIssueKeyForComment = issueKey || '';
        currentIssueSummaryForComment = summary || '';

        const headerText = (issueKey ? issueKey + ' - ' : '') + summary;
        $('#issueCommentIssueHeader').text(headerText);

        // 상세 화면 버튼 링크 설정
        $('#issueDetailBtn').off('click').on('click', function () {
            goToIssueDetail(issueId);
        });

        $('#issueCommentInput').val('');
        renderIssueCommentList([]); // 초기화

        loadIssueComments(issueId);

        $('#issueCommentModal').modal('show');
    }

    function loadIssueComments(issueId) {
        if (!issueId) return;

        const payload = {
            issueId: issueId
        };

        $.ajax({
            url: API_ISSUE_COMMENT + '/selectissueCommentList',
            type: 'post',
            contentType: 'application/json',
            dataType: 'json',
            data: JSON.stringify(payload),
            success: function (map) {
                const list = map.result || [];
                renderIssueCommentList(list);
            },
            error: function (xhr) {
                alert('댓글 조회 실패: ' + (xhr.responseText || xhr.status));
            }
        });
    }

    function renderIssueCommentList(list) {
        const $list = $('#issueCommentList');
        $list.empty();

        if (!list.length) {
            $list.append(
                "<div class='text-muted' style='font-size:12px;'>등록된 댓글이 없습니다.</div>"
            );
            return;
        }

        for (let i = 0; i < list.length; i++) {
            const r = list[i];
            const author = r.createUser || r.createuser || r.writer || '';
            const createDate = r.createDate || r.createdDt || r.created_dt || '';
            const content = r.content || '';   // ★ DB 컬럼 content 사용

            let html = '';
            html += "<div class='isu-comment-item'>";
            html += "  <div class='isu-comment-header'>";
            html += "    <span class='isu-comment-author'>" + escapeHtml(author || '익명') + "</span>";
            if (createDate) {
                html += "    <span class='isu-comment-date'>" + escapeHtml(String(createDate)) + "</span>";
            }
            html += "  </div>";
            html += "  <div class='isu-comment-body'>" + escapeHtml(content) + "</div>";
            html += "</div>";

            $list.append(html);
        }
    }

    function submitIssueComment() {
        if (!currentIssueIdForComment) {
            alert('이슈가 선택되지 않았습니다.');
            return;
        }

        const txt = ($('#issueCommentInput').val() || '').trim();
        if (!txt) {
            alert('댓글 내용을 입력하세요.');
            return;
        }

        const payload = {
            issueId: currentIssueIdForComment,
            content: txt    // ★ 서버로도 content 키로 전송
        };

        $.ajax({
            url: API_ISSUE_COMMENT + '/insertissueComment',
            type: 'post',
            contentType: 'application/json',
            dataType: 'json',
            data: JSON.stringify(payload),
            success: function () {
                $('#issueCommentInput').val('');
                loadIssueComments(currentIssueIdForComment);
            },
            error: function (xhr) {
                alert('댓글 등록 실패: ' + (xhr.responseText || xhr.status));
            }
        });
    }

    function goToIssueDetail(issueId) {
        if (!issueId) return;
        var url = '/isu/issue/issueModify?issueId=' + encodeURIComponent(issueId);
        location.href = url;
    }

    function escapeHtml(s) {
        return String(s == null ? '' : s).replace(/[&<>"']/g, function (m) {
            return { '&':'&amp;','<':'&lt;','>':'&gt;', '"':'&quot;', "'":'&#39;' }[m];
        });
    }

    function getQueryParam(name) {
        const params = new URLSearchParams(window.location.search || '');
        return params.get(name);
    }
</script>
