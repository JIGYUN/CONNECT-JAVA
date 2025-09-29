<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>

<section>
    <div class="d-flex align-items-center justify-content-between">
        <h2 class="mb-3">Tasks</h2>
        <span class="badge badge-light align-self-center pill">grpCd: <span id="grpCdTxt"><c:out value="${grpCd}"/></span></span>
    </div>

    <!-- Calendar + Quick Add -->
    <div class="panel-elev mb-3">
        <div class="toolbar">
            <!-- Calendar -->
            <div class="calendar">
                <div class="cal-head">
                    <button class="btn btn-light" id="calPrev" aria-label="이전 달">&laquo;</button>
                    <div class="cal-title" id="calTitle">YYYY-MM</div>
                    <button class="btn btn-light" id="calNext" aria-label="다음 달">&raquo;</button>
                    <button class="btn btn-outline-secondary" id="btnToday" title="오늘로">오늘</button>
                </div>

                <!-- 요일 헤더 -->
                <div class="cal-grid-dow">
                    <div>일</div><div>월</div><div>화</div><div>수</div><div>목</div><div>금</div><div>토</div>
                </div>
                <!-- 날짜 바디 -->
                <div class="cal-grid-body" id="calBody"></div>
            </div>

            <!-- Quick Add -->
            <div class="quick-wrap">
                <div class="input-group">
                    <input type="search" id="titleInput" class="form-control" placeholder="할 일을 입력하고 Enter (예: 기획안 검토)" aria-label="제목 입력"/>
                    <div class="input-group-append">
                        <button class="btn btn-primary" id="btnAdd" type="button">추가</button>
                    </div>
                </div>
                <div class="muted small mt-2">선택한 날짜로 저장됩니다.</div>
            </div>
        </div>
    </div>

    <!-- List -->
    <div class="table-responsive panel-elev">
        <table class="table table-hover align-middle mb-0">
            <thead class="thead-light">
                <tr>
                    <th style="width:42px;">
                        <input type="checkbox" id="chkAll" aria-label="전체 선택"/>
                    </th>
                    <th style="width: 90px; text-align:right;">번호</th>
                    <th>제목</th>
                    <th style="width: 220px;">기한</th>
                    <th style="width: 100px; text-align:center;">관리</th>
                </tr>
            </thead>
            <tbody id="taskListBody"></tbody>
        </table>
    </div>

    <!-- 선택 날짜 보관 -->
    <input type="hidden" id="pickDate" />
</section>

<!-- jQuery (안 로드된 환경 대비) -->
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>

<style>
    :root{
        --bg:#f6f8fb; --card:#ffffff; --line:#e9edf3; --text:#0f172a; --muted:#6b7280; --accent:#1f6feb;
        --pill:#f3f5f8; --ring:#dbeafe; --sel:#e0ecff;
    }
    body{ background:var(--bg); }
    .panel-elev{
        background:var(--card);
        border:1px solid var(--line);
        border-radius:16px;
        box-shadow:0 6px 16px rgba(15,23,42,.05);
        padding:16px;
    }
    .toolbar{
        display:grid; grid-template-columns: 1fr 1fr; gap:16px; align-items:start;
    }
    @media (max-width: 992px){ .toolbar{ grid-template-columns: 1fr; } }

    .pill{ font-size:12px; padding:4px 10px; border-radius:999px; border:1px solid var(--line); color:#475569; background:#fff; }
    .muted{ color: var(--muted); }

    /* Calendar */
    .calendar{ width:100%; }
    .cal-head{ display:flex; align-items:center; gap:8px; margin-bottom:8px; }
    .cal-title{ font-weight:800; color:var(--text); margin-right:auto; letter-spacing:.3px; }

    .cal-grid-dow{
        display:grid; grid-template-columns: repeat(7, 1fr); gap:6px; margin-bottom:6px;
    }
    .cal-grid-dow > div{
        text-align:center; font-size:12px; color:#64748b; font-weight:700; padding:6px 0;
        border:1px solid var(--line); border-radius:10px; background:#fff;
    }

    .cal-grid-body{
        display:grid; grid-template-columns: repeat(7, 1fr); gap:6px;
        background:#fff; border:1px solid var(--line); border-radius:12px; padding:12px;
        min-height:264px; /* 6주(6*44px) 보장 */
    }
    .cal-cell{
        border:1px solid var(--line); border-radius:10px; background:#fff; height:40px;
        display:flex; align-items:center; justify-content:center; cursor:pointer;
        transition:transform .05s ease, box-shadow .05s ease, background .15s ease;
        user-select:none; font-weight:600; color:#334155;
    }
    .cal-cell:hover{ background:#f8fafc; }
    .cal-cell.is-other{ opacity:.35; }
    .cal-cell.is-today{ box-shadow:0 0 0 2px var(--ring) inset; }
    .cal-cell.is-selected{ background:var(--sel); border-color:#c7d2fe; }

    /* Quick Add */
    .quick-wrap{ margin-left:auto; max-width:520px; width:100%; }
    .input-group .form-control{ height:38px; }
    .input-group .btn{ height:38px; }

    /* Table */
    .table thead th{ background:#f3f5f8; border-bottom:1px solid var(--line); color:#475569; font-weight:700; }
    .table tbody tr{ cursor:pointer; transition:background .08s ease; }
    .table tbody tr:hover{ background:#f9fbff; }
    .title-cell{ display:flex; align-items:center; gap:8px; }
    .title-text{ font-weight:600; color:var(--text); }
    .row-done .title-text{ text-decoration:line-through; color:#9ca3af; }
    .status-badge{
        margin-left:4px; font-size:11px; border-radius:999px; padding:2px 8px; border:1px solid var(--line);
        color:#334155; background:#fff;
    }
    .status-done{ background:#ecfdf5; border-color:#a7f3d0; color:#065f46; }
    .status-todo{ background:#eef2ff; border-color:#c7d2fe; color:#3730a3; }
    .btn-ghost{ border:1px solid var(--line); color:#64748b; background:#fff; }
    .btn-ghost:hover{ color:#0f172a; border-color:#cbd5e1; background:#f8fafc; }
</style>

<script>
    // ===== Config =====
    var API_BASE = '/api/tsk/task';
    var taskId   = 'taskId';   
    var grpEl    = document.getElementById('grpCdTxt');
    var DEFAULT_GRP_CD = grpEl ? grpEl.textContent : 'personal'; // (옵셔널 체이닝 미사용)

    // ===== State =====
    var selectedDate = null;   // Date 객체 (선택일)
    var viewYear = null;       // 캘린더 뷰 기준 년
    var viewMonth = null;      // 0-11
  
    // ===== Init =====
    (function () {
        initTodayState();          // 오늘로 상태 세팅
        renderCalendar();          // 6주(42칸) 렌더
        bindCalendarHandlers();
        bindQuickAdd();
        bindTableHandlers();
        selectTaskList();          // 오늘 목록 로드
    })();

    // ===== State helpers =====
    function initTodayState(){
        var now = new Date();
        selectedDate = new Date(now.getFullYear(), now.getMonth(), now.getDate());
        viewYear  = selectedDate.getFullYear();
        viewMonth = selectedDate.getMonth();
        document.getElementById('pickDate').value = toYMD(selectedDate);
    }
    function setSelectedDate(d){
        selectedDate = new Date(d.getFullYear(), d.getMonth(), d.getDate());
        viewYear  = selectedDate.getFullYear();
        viewMonth = selectedDate.getMonth();
        document.getElementById('pickDate').value = toYMD(selectedDate);
        renderCalendar();
        selectTaskList();
    }

    // ===== Calendar render (42칸 고정) =====
    function renderCalendar(){
        var title = viewYear + "년 " + ('0'+(viewMonth+1)).slice(-2) + "월";
        document.getElementById('calTitle').textContent = title;

        var body = document.getElementById('calBody');
        body.innerHTML = '';

        var first = new Date(viewYear, viewMonth, 1);
        var startDow = first.getDay(); // 0:일 ~ 6:토

        for (var i = 0; i < 42; i++){
            var dayNum = i - startDow + 1;
            var cellDate = new Date(viewYear, viewMonth, dayNum);

            var cell = document.createElement('button');
            cell.type = 'button';
            cell.className = 'cal-cell';
            cell.setAttribute('data-date', toYMD(cellDate));
            cell.textContent = cellDate.getDate();

            if (cellDate.getMonth() !== viewMonth) cell.classList.add('is-other');

            var today = new Date(); today.setHours(0,0,0,0);
            var thisDay = new Date(cellDate.getFullYear(), cellDate.getMonth(), cellDate.getDate());
            if (thisDay.getTime() === today.getTime()) cell.classList.add('is-today');

            if (selectedDate && thisDay.getTime() === selectedDate.getTime()) cell.classList.add('is-selected');

            (function(dRef){
                cell.addEventListener('click', function(e){
                    e.preventDefault();
                    setSelectedDate(dRef);
                });
            })(thisDay);

            body.appendChild(cell);
        }
    }

    // ===== Calendar handlers =====
    function bindCalendarHandlers(){
        document.getElementById('calPrev').addEventListener('click', function(){
            viewMonth -= 1;
            if (viewMonth < 0){ viewMonth = 11; viewYear -= 1; }
            renderCalendar();
        });
        document.getElementById('calNext').addEventListener('click', function(){
            viewMonth += 1;
            if (viewMonth > 11){ viewMonth = 0; viewYear += 1; }
            renderCalendar();
        });
        document.getElementById('btnToday').addEventListener('click', function(){
            initTodayState();      // 오늘로 확정 세팅(빈값 방지)
            renderCalendar();
            selectTaskList();
        });
    }

    // ===== Quick add / table =====
    function bindQuickAdd(){
        var input = document.getElementById('titleInput');
        document.getElementById('btnAdd').addEventListener('click', function(){
            var t = (input.value || '').trim();
            if (t) insertTitle(t);
        });
        input.addEventListener('keydown', function(e){
            if (e.key === 'Enter'){
                var t = (input.value || '').trim();
                if (t) insertTitle(t);
            }
        });
    }
    function bindTableHandlers(){
        document.getElementById('chkAll').addEventListener('change', function(){
            var checked = this.checked;
            var nodes = document.querySelectorAll('.row-chk');
            for (var i=0; i<nodes.length; i++){
                if (nodes[i].checked !== checked){
                    nodes[i].checked = checked;
                    nodes[i].dispatchEvent(new Event('change'));
                }
            }
        });
    }

    // ===== API =====
    function selectTaskList() {
        var dueDate = document.getElementById('pickDate').value; // YYYY-MM-DD
        var payload = { grpCd: DEFAULT_GRP_CD, dueDate: dueDate };

        $.ajax({
            url: API_BASE + '/selectTaskListByDate',
            type: 'post',
            contentType: 'application/json',
            data: JSON.stringify(payload),
            success: function (map) {
                var list = (map.result && map.result.list) ? map.result.list : (map.result || []);
                renderRows(list);
            },
            error: function () { alert('목록 조회 중 오류 발생'); }
        });
    }

    function insertTitle(title) {
        var payload = {
            title: title,
            grpCd: DEFAULT_GRP_CD,
            dueDt: document.getElementById('pickDate').value || toYMD(new Date())
        };
        $.ajax({
            url: API_BASE + '/insertTask',
            type: 'post',
            contentType: 'application/json',
            dataType: 'json',
            data: JSON.stringify(payload),
            success: function () {
                document.getElementById('titleInput').value = '';
                selectTaskList();
            },
            error: function (xhr) {
                alert('등록 실패: ' + (xhr.responseText || xhr.status));
            }
        });
    }

    function deleteRow(id) {
        if (!id) return;
        if (!confirm('삭제하시겠습니까?')) return;

        var payload = {}; payload[taskId] = id;
        $.ajax({
            url: API_BASE + '/deleteTask',
            type: 'post',
            contentType: 'application/json',
            dataType: 'json',
            data: JSON.stringify(payload),
            success: function () { selectTaskList(); },
            error: function (xhr) { alert('삭제 실패: ' + (xhr.responseText || xhr.status)); }
        });
    }

    function onRowChkChanged(id, checked){
        var payload = {}; payload[taskId] = id; payload['statusCd'] = checked ? 'DONE' : 'TODO';
        $.ajax({
            url: API_BASE + '/toggleTask', 
            type: 'post',
            contentType: 'application/json',
            dataType: 'json',
            data: JSON.stringify(payload),
            success: function(){
                var tr = document.getElementById('row-'+id);
                if (tr){
                    tr.classList.toggle('row-done', checked);
                    var pill = tr.querySelector('.status-badge');
                    if (pill){
                        pill.classList.toggle('status-done', checked);
                        pill.classList.toggle('status-todo', !checked);
                        pill.textContent = checked ? '완료' : '진행중';
                    }   
                }
            },
            error: function(xhr){
                alert('상태 변경 실패: ' + (xhr.responseText || xhr.status));
                var chk = document.getElementById('chk-'+id);
                if (chk) chk.checked = !checked; // 되돌림
            }
        });
    }

    // ===== Render =====
    function renderRows(list){
        var html = '';
        if (!list.length){
            html += "<tr><td colspan='5' class='text-center text-muted py-4'>등록된 데이터가 없습니다.</td></tr>";
        } else {
            for (var i = 0; i < list.length; i++){
                var r = list[i];
                var id       = r.taskId;
                var title    = (r.title != null ? r.title : '');
                var statusCd = (r.statusCd != null ? String(r.statusCd) : 'TODO').toUpperCase();
                var dueTxt   = fmtDateMaybe(r.dueDt) || '-';
                var checked  = (statusCd === 'DONE');
                var rowCls   = checked ? 'row-done' : '';
                var badgeCls = checked ? 'status-badge status-done' : 'status-badge status-todo';
                var badgeTxt = checked ? '완료' : '진행중';

                html += "<tr id='row-"+id+"' class='"+rowCls+"' onclick=\"goToTaskModify('"+(id)+"')\">";
                html += "  <td onclick='event.stopPropagation();'>";
                html += "    <input id='chk-"+id+"' type='checkbox' class='row-chk' "+(checked?'checked':'')+" ";
                html += "           aria-label='항목 "+(id || '')+" 완료' ";
                html += "           onchange=\"onRowChkChanged('"+id+"', this.checked)\">";
                html += "  </td>";
                html += "  <td class='text-right'>"+(id || '')+"</td>";
                html += "  <td>";
                html += "    <div class='title-cell'>";
                html += "      <div class='title-text'>"+escapeHtml(title)+"</div>";
                html += "      <span class='"+badgeCls+"'>"+badgeTxt+"</span>";
                html += "    </div>";
                html += "  </td>";
                html += "  <td>"+escapeHtml(dueTxt)+"</td>";
                html += "  <td class='text-center' onclick='event.stopPropagation();'>";
                html += "    <button type='button' class='btn btn-sm btn-ghost'";
                html += "            aria-label='항목 "+(id || '')+" 삭제'";
                html += "            onclick=\"deleteRow('"+(id)+"')\">삭제</button>";
                html += "  </td>";
                html += "</tr>";
            }
        }
        document.getElementById('taskListBody').innerHTML = html;
    }

    // ===== Navigation =====
    function goToTaskModify(id) {
        var url = '/tsk/task/taskModify';
        if (id) url += '?' + taskId + '=' + encodeURIComponent(id);
        location.href = url;
    }

    // ===== Utils =====
    function escapeHtml(s) {
        return String(s).replace(/[&<>"']/g, function (m) {
            return { '&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;' };
        }); 
    }  
    function fmtDateMaybe(v){
        if (!v) return '';
        if (typeof v === 'object' && v.value) v = v.value;
        return String(v).replace('T',' ').slice(0,16);
    }
    function toYMD(d){
        var y = d.getFullYear();
        var m = ('0'+(d.getMonth()+1)).slice(-2);
        var dd= ('0'+d.getDate()).slice(-2);
        return y + '-' + m + '-' + dd;
    }
</script>  