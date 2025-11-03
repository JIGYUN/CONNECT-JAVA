<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>

<section>
    <!-- 헤더 -->
    <div class="d-flex align-items-center justify-content-between">
        <h2 class="mb-3">예약 / 일정</h2>
        <span class="badge badge-light align-self-center pill">
            grpCd:
            <span id="grpCdTxt"><c:out value="${grpCd}"/></span>
        </span>
    </div>

    <!-- 달력 + 빠른 예약 등록 -->
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

            
                <!-- 날짜 표시 -->
                <div class="mb-2 small text-muted">
                    선택 날짜: <span id="selDateText" class="font-weight-bold">-</span>
                </div>

                <!-- 입력 블럭 -->
                <div class="input-group mb-2 flex-wrap" style="row-gap:8px;">
                    <!-- 시작/종료 (datetime-local로 변경) -->
                    <div class="d-flex flex-column" style="gap:8px; width:100%;">
                        <div class="input-group" style="max-width:300px;">
                            <div class="input-group-prepend">
                                <span class="input-group-text">시작</span>
                            </div>
                            <input
                                type="datetime-local"
                                id="startAt"
                                class="form-control"
                                aria-label="시작 일시 선택">
                        </div>

                        <div class="input-group" style="max-width:300px;">
                            <div class="input-group-prepend">
                                <span class="input-group-text">종료</span>
                            </div>
                            <input
                                type="datetime-local"
                                id="endAt"
                                class="form-control"
                                aria-label="종료 일시 선택">
                        </div>

                        <!-- 상태 선택 (statusCd 노출/입력) -->
                        <div class="input-group" style="max-width:220px;">
                            <div class="input-group-prepend">
                                <span class="input-group-text">상태</span>
                            </div>
                            <select id="statusSelect" class="form-control" aria-label="상태 선택">
                                <option value="SCHEDULED" selected>SCHEDULED</option>
                                <option value="PENDING">PENDING</option>
                                <option value="APPROVED">APPROVED</option>
                                <option value="DONE">DONE</option>
                                <option value="CANCELLED">CANCELLED</option>
                            </select>
                        </div> 
		                <div class="input-group" style="max-width:120px;">
		                    <div class="input-group-prepend">
		                        <span class="input-group-text">인원</span>    
		                    </div>
		                    <input type="number"
		                           id="capacityCntInput"
		                           class="form-control"
		                           min="1"
		                           step="1" 
		                           placeholder="예: 3"
		                           aria-label="인원/좌석 수">
		                </div>
                    </div>

                    <!-- 제목 -->
                    <input
                        type="search"
                        id="titleInput"
                        class="form-control mt-2"
                        placeholder="제목 / 약속명 (예: 미팅, 병원예약)"
                        aria-label="제목 입력"/>

                    <!-- 장소/대상 -->
                    <input
                        type="text"
                        id="resourceNmInput"
                        class="form-control mt-2"
                        placeholder="장소 / 상대 / 룸이름 등"
                        aria-label="장소/대상 입력"/>

                    <div class="input-group-append mt-2" style="width:100%; display:flex; justify-content:flex-end;">
                        <button class="btn btn-primary" id="btnAdd" type="button">등록</button>
                    </div>
                </div>

                <div class="muted small">
                    선택한 날짜 범위와 상태로 예약을 저장합니다.
                </div>
            </div>
        </div>
    </div>

    <!-- 목록 -->
    <div class="table-responsive panel-elev">
        <table class="table table-hover align-middle mb-0">
            <thead class="thead-light">
                <tr>
                    <th style="width:42px;">
                        <input type="checkbox" id="chkAll" aria-label="전체 선택"/>
                    </th>
                    <th style="width: 90px; text-align:right;">번호</th>
                    <th>제목 / 장소</th>
                    <th style="width: 220px;">시간</th>
                    <th style="width: 110px; text-align:center;">상태</th>
                    <th style="width: 90px; text-align:center;">관리</th>
                </tr>
            </thead>
            <tbody id="reservationListBody"></tbody>
        </table>
    </div>

    <!-- 선택 날짜 hidden -->
    <input type="hidden" id="pickDate" />
</section>

<!-- jQuery CDN fallback -->
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>

<style>
    :root{
        --bg:#f6f8fb; --card:#ffffff; --line:#e9edf3; --text:#0f172a; --muted:#6b7280;
        --accent:#1f6feb; --pill:#f3f5f8; --ring:#dbeafe; --sel:#e0ecff;
    }
    body{ background:var(--bg); }
    .panel-elev{ background:var(--card); border:1px solid var(--line); border-radius:16px; box-shadow:0 6px 16px rgba(15,23,42,.05); padding:16px; }
    .toolbar{ display:grid; grid-template-columns: 1fr 1fr; gap:16px; align-items:start; }
    @media (max-width: 992px){ .toolbar{ grid-template-columns: 1fr; } }
    .pill{ font-size:12px; padding:4px 10px; border-radius:999px; border:1px solid var(--line); color:#475569; background:#fff; }
    .muted{ color: var(--muted); }

    /* Calendar */
    .calendar{ width:100%; }
    .cal-head{ display:flex; align-items:center; gap:8px; margin-bottom:8px; }
    .cal-title{ font-weight:800; color:var(--text); margin-right:auto; letter-spacing:.3px; }
    .cal-grid-dow{ display:grid; grid-template-columns: repeat(7, 1fr); gap:6px; margin-bottom:6px; }
    .cal-grid-dow > div{ text-align:center; font-size:12px; color:#64748b; font-weight:700; padding:6px 0; border:1px solid var(--line); border-radius:10px; background:#fff; }
    .cal-grid-body{ display:grid; grid-template-columns: repeat(7, 1fr); gap:6px; background:#fff; border:1px solid var(--line); border-radius:12px; padding:12px; min-height:264px; }
    .cal-cell{ border:1px solid var(--line); border-radius:10px; background:#fff; height:40px; display:flex; align-items:center; justify-content:center; cursor:pointer; transition:.05s; user-select:none; font-weight:600; color:#334155; font-size:14px; }
    .cal-cell:hover{ background:#f8fafc; }
    .cal-cell.is-other{ opacity:.35; }
    .cal-cell.is-today{ box-shadow:0 0 0 2px var(--ring) inset; }
    .cal-cell.is-selected{ background:var(--sel); border-color:#c7d2fe; }

    /* Table/list */
    .table thead th{ background:#f3f5f8; border-bottom:1px solid var(--line); color:#475569; font-weight:700; font-size:13px; vertical-align:middle; }
    .table tbody tr{ cursor:pointer; transition:background .08s ease; }
    .table tbody tr:hover{ background:#f9fbff; }
    .title-cell{ display:flex; flex-direction:column; }
    .title-main{ font-weight:600; color:#0f172a; word-break:break-word; }
    .title-sub{ font-size:12px; color:#6b7280; word-break:break-word; }
    .row-done .title-main{ text-decoration:line-through; color:#9ca3af; }

    .status-badge{ font-size:11px; border-radius:999px; padding:2px 8px; border:1px solid var(--line); color:#334155; background:#fff; display:inline-block; font-weight:600; }
    .status-SCHEDULED{ background:#eef2ff; border-color:#c7d2fe; color:#3730a3; }
    .status-PENDING{ background:#fff7ed; border-color:#fed7aa; color:#9a3412; }
    .status-APPROVED{ background:#ecfdf5; border-color:#a7f3d0; color:#065f46; }
    .status-DONE{ background:#dcfce7; border-color:#86efac; color:#065f46; }
    .status-CANCELLED{ background:#fee2e2; border-color:#fecaca; color:#991b1b; }

    .btn-ghost{ border:1px solid var(--line); color:#64748b; background:#fff; }
    .btn-ghost:hover{ color:#0f172a; border-color:#cbd5e1; background:#f8fafc; }
</style>

<script>
    // ===== Config =====
    var API_BASE = '/api/rsv/reservation';
    var reservationIdField = 'reservationId';

    var grpEl = document.getElementById('grpCdTxt');
    var DEFAULT_GRP_CD = grpEl && grpEl.textContent ? grpEl.textContent : 'personal';

    // ===== State =====
    var selectedDate = null; // Date 객체(일 단위)
    var viewYear = null;
    var viewMonth = null;

    // ===== Init =====
    (function initPage(){
        initTodayState();      // 오늘 날짜/시간 기본 세팅
        renderCalendar();      // 42칸 캘린더 찍기
        bindCalendarHandlers();
        bindQuickAddHandlers();
        bindTableHandlers();
        selectReservationList(); // 오늘 일정 로딩
    })();

    // ===== 날짜/시간 유틸 =====
    function to2(n){ return ('0'+n).slice(-2); }
    function toYMD(d){ return d.getFullYear() + '-' + to2(d.getMonth()+1) + '-' + to2(d.getDate()); }
    function toLocalDatetimeValue(d){ return toYMD(d) + 'T' + to2(d.getHours()) + ':' + to2(d.getMinutes()); }

    // "YYYY-MM-DD[ T]HH:mm[:ss]" → JS Date (local)
    function parseLocalDateTime(str){
        if (!str) return null;
        if (typeof str === 'object' && str.value){ str = str.value; }
        str = String(str).replace('T',' ').trim();
        var m = /^(\d{4})-(\d{2})-(\d{2})(?:\s(\d{2}):(\d{2})(?::(\d{2}))?)?$/.exec(str);
        if (!m) return null;
        var Y=+m[1], Mo=+m[2]-1, D=+m[3], h=+(m[4]||0), mi=+(m[5]||0), s=+(m[6]||0);
        return new Date(Y,Mo,D,h,mi,s);
    }
    function getStartMillis(row){
        var dt = parseLocalDateTime(row.resvStartDt);
        return dt ? dt.getTime() : Number.MAX_SAFE_INTEGER;
    }
    function formatRange(startDt, endDt){
        var s = parseLocalDateTime(startDt);
        var e = parseLocalDateTime(endDt);
        if (!s && !e) return '-';
        var ymd = s ? toYMD(s) : (e ? toYMD(e) : '');
        var sh  = s ? (to2(s.getHours())+':'+to2(s.getMinutes())) : '--:--';
        var eh  = e ? (to2(e.getHours())+':'+to2(e.getMinutes())) : '--:--';
        return ymd ? (ymd + ' ' + sh + ' ~ ' + eh) : (sh + ' ~ ' + eh);
    }
    function fullDateTime(dtStr){
        var d = parseLocalDateTime(dtStr);
        return d ? (toYMD(d)+' '+to2(d.getHours())+':'+to2(d.getMinutes())) : '';
    }
    function escapeHtml(s){
        return String(s).replace(/[&<>"']/g, function (m) {
            return {'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[m] || m;
        });
    }

    // ===== State init/update =====
    function initTodayState(){
        var now = new Date();
        selectedDate = new Date(now.getFullYear(), now.getMonth(), now.getDate());
        viewYear  = selectedDate.getFullYear();
        viewMonth = selectedDate.getMonth();

        // 선택일 표기/보관
        var ymd = toYMD(selectedDate);
        document.getElementById('pickDate').value = ymd;
        document.getElementById('selDateText').textContent = ymd;

        // 시작은 현재 시각, 종료는 +1시간 기본
        var startAt = document.getElementById('startAt');
        var endAt   = document.getElementById('endAt');
        startAt.value = toLocalDatetimeValue(now);
        endAt.value   = toLocalDatetimeValue(new Date(now.getTime() + 60*60*1000));
    }
    function setSelectedDate(d){
        selectedDate = new Date(d.getFullYear(), d.getMonth(), d.getDate());
        viewYear  = selectedDate.getFullYear();
        viewMonth = selectedDate.getMonth();

        var ymd = toYMD(selectedDate);
        document.getElementById('pickDate').value = ymd;
        document.getElementById('selDateText').textContent = ymd;

        renderCalendar();
        selectReservationList();
    }

    // ===== Calendar =====
    function renderCalendar(){
        var title = viewYear + "년 " + to2(viewMonth+1) + "월";
        document.getElementById('calTitle').textContent = title;

        var body = document.getElementById('calBody');
        body.innerHTML = '';

        var first = new Date(viewYear, viewMonth, 1);
        var startDow = first.getDay();

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
            var justDay = new Date(cellDate.getFullYear(), cellDate.getMonth(), cellDate.getDate());
            if (justDay.getTime() === today.getTime()) cell.classList.add('is-today');
            if (selectedDate && justDay.getTime() === selectedDate.getTime()) cell.classList.add('is-selected');

            (function(dRef){
                cell.addEventListener('click', function(e){
                    e.preventDefault();
                    setSelectedDate(dRef);
                });
            })(justDay);

            body.appendChild(cell);
        }
    }
    function bindCalendarHandlers(){
        document.getElementById('calPrev').addEventListener('click', function(){
            viewMonth -= 1; if (viewMonth < 0){ viewMonth = 11; viewYear -= 1; }
            renderCalendar();
        });
        document.getElementById('calNext').addEventListener('click', function(){
            viewMonth += 1; if (viewMonth > 11){ viewMonth = 0; viewYear += 1; }
            renderCalendar();
        });
        document.getElementById('btnToday').addEventListener('click', function(){
            initTodayState(); renderCalendar(); selectReservationList();
        });
    }

    // ===== Quick Add / Table handlers =====
    function bindQuickAddHandlers(){
        document.getElementById('btnAdd').addEventListener('click', doInsertReservation);
        document.getElementById('titleInput').addEventListener('keydown', function(e){
            if (e.key === 'Enter'){ doInsertReservation(); }
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

    // ===== API 호출 =====
    function selectReservationList(){
        var ymd = document.getElementById('pickDate').value;
        var payload = { grpCd: DEFAULT_GRP_CD, resvDate: ymd };

        $.ajax({
            url: API_BASE + '/selectReservationListByDate',
            type: 'post',
            contentType: 'application/json',
            data: JSON.stringify(payload),
            success: function (map) {
                var list = (map.result && map.result.list) ? map.result.list : (map.result || []);
                list.sort(function(a,b){ return getStartMillis(a) - getStartMillis(b); });
                renderRows(list);
            },
            error: function () { alert('목록 조회 중 오류 발생'); }
        });
    }

    function doInsertReservation(){
        var startVal   = (document.getElementById('startAt').value || '').trim();
        var endVal     = (document.getElementById('endAt').value || '').trim();
        var title      = (document.getElementById('titleInput').value || '').trim();
        var resourceNm = (document.getElementById('resourceNmInput').value || '').trim();
        var statusCd   = (document.getElementById('statusSelect').value || 'SCHEDULED').toUpperCase();

        if (!title){ alert('제목을 입력하세요.'); return; }
        if (!startVal){ alert('시작 일시를 선택하세요.'); return; }

        // 종료가 비었거나 시작 이전이면 시작과 동일하게 맞춤
        if (!endVal || (parseLocalDateTime(endVal) && parseLocalDateTime(startVal) && parseLocalDateTime(endVal) < parseLocalDateTime(startVal))){
            endVal = startVal;
        }

        var capRaw = (document.getElementById('capacityCntInput').value || '').trim();
        var capacityCnt = capRaw ? parseInt(capRaw,10) : null;
        if (Number.isNaN(capacityCnt)) capacityCnt = null;

        var payload = {
            grpCd: DEFAULT_GRP_CD,
            title: title,
            resourceNm: resourceNm,
            capacityCnt: capacityCnt,
            resvStartDt: startVal,  // YYYY-MM-DDTHH:mm
            resvEndDt:   endVal,    // YYYY-MM-DDTHH:mm
            statusCd:    statusCd
        };

        $.ajax({
            url: API_BASE + '/insertReservation',
            type: 'post',
            contentType: 'application/json',
            dataType: 'json',
            data: JSON.stringify(payload),
            success: function () {
                // 입력값 리셋 (제목만 비우고 시간은 유지)
                document.getElementById('titleInput').value = '';
                selectReservationList();
            },
            error: function (xhr) { alert('등록 실패: ' + (xhr.responseText || xhr.status)); }
        });
    }

    function updateStatus(id, statusCd){
        var payload = {}; payload[reservationIdField] = id; payload['statusCd'] = statusCd;

        $.ajax({
            url: API_BASE + '/updateReservationStatus',
            type: 'post',
            contentType: 'application/json',
            dataType: 'json',
            data: JSON.stringify(payload),
            success: function () {
                // 부분 UI 갱신
                var tr = document.getElementById('row-'+id);
                if (tr){
                    tr.classList.toggle('row-done', statusCd === 'DONE');
                    var badge = tr.querySelector('.status-badge');
                    if (badge){
                        badge.className = 'status-badge status-' + statusCd;
                        badge.textContent = statusCd;
                    }
                }
            },
            error: function (xhr) { alert('상태 변경 실패: ' + (xhr.responseText || xhr.status)); }
        });
    }

    function toggleStatusByCheckbox(id, checked){
        // 체크 → DONE / 해제 → SCHEDULED
        updateStatus(id, checked ? 'DONE' : 'SCHEDULED');
    }

    function deleteRow(id){
        if (!id) return;
        if (!confirm('삭제하시겠습니까?')) return;

        var payload = {}; payload[reservationIdField] = id;

        $.ajax({
            url: API_BASE + '/deleteReservation',
            type: 'post',
            contentType: 'application/json',
            dataType: 'json',
            data: JSON.stringify(payload),
            success: function () { selectReservationList(); },
            error: function (xhr) { alert('삭제 실패: ' + (xhr.responseText || xhr.status)); }
        });
    }

    // ===== Row / Table 렌더 =====
    function renderRows(list){
        var html = '';

        if (!list.length){
            html += "<tr><td colspan='6' class='text-center text-muted py-4'>등록된 예약이 없습니다.</td></tr>";
        } else {
            for (var i=0; i<list.length; i++){
                var r = list[i];

                var id           = r.reservationId;
                var title        = (r.title != null ? r.title : '');
                var resourceNm   = (r.resourceNm != null ? r.resourceNm : '');
                var statusCd     = (r.statusCd != null ? String(r.statusCd).toUpperCase() : 'SCHEDULED');
                var rangeTxt     = formatRange(r.resvStartDt, r.resvEndDt);
                var fullStartTxt = fullDateTime(r.resvStartDt);

                var checked      = (statusCd === 'DONE');
                var rowCls       = checked ? 'row-done' : '';
                var badgeCls     = 'status-badge status-' + statusCd;

                html += "<tr id='row-"+id+"' class='"+rowCls+"' onclick=\"goToReservationModify('"+(id)+"')\">";

                // 체크박스 (DONE/SCHEDULED 토글)
                html += "  <td onclick='event.stopPropagation();'>";
                html += "    <input id='chk-"+id+"' type='checkbox' class='row-chk' "+(checked?'checked':'')+" ";
                html += "           aria-label='항목 "+(id||'')+" 완료 여부' ";
                html += "           onchange=\"toggleStatusByCheckbox('"+id+"', this.checked)\">";
                html += "  </td>";

                // 번호
                html += "  <td class='text-right'>"+(id || '')+"</td>";

                // 제목 / 장소
                html += "  <td>";
                html += "    <div class='title-cell'>";
                html += "      <div class='title-main'>"+escapeHtml(title)+"</div>";
                if (resourceNm){ html += "  <div class='title-sub'>"+escapeHtml(resourceNm)+"</div>"; }
                html += "    </div>";
                html += "  </td>";

                // 시간
                html += "  <td title='"+escapeHtml(fullStartTxt)+"'>"+escapeHtml(rangeTxt)+"</td>";

                // 상태(배지 + 드롭다운)
                html += "  <td class='text-center' onclick='event.stopPropagation();'>";
                html += "      <span class='"+badgeCls+"' style='margin-right:6px;'>"+escapeHtml(statusCd)+"</span>";
                html += "      <select class='form-control form-control-sm' style='display:inline-block; width:auto;' ";
                html += "              onchange=\"updateStatus('"+id+"', this.value)\">";
                ["SCHEDULED","PENDING","APPROVED","DONE","CANCELLED"].forEach(function(opt){
                    var sel = (opt === statusCd) ? " selected" : "";
                    html += "<option value='"+opt+"'"+sel+">"+opt+"</option>";
                });
                html += "      </select>";
                html += "  </td>";

                // 관리(삭제)
                html += "  <td class='text-center' onclick='event.stopPropagation();'>";
                html += "      <button type='button' class='btn btn-sm btn-ghost' onclick=\"deleteRow('"+(id)+"')\">삭제</button>";
                html += "  </td>";

                html += "</tr>";
            }
        }

        document.getElementById('reservationListBody').innerHTML = html;
    }

    // ===== 페이지 이동 =====
    function goToReservationModify(id){
        var url = '/rsv/reservation/reservationModify';
        if (id){ url += '?' + reservationIdField + '=' + encodeURIComponent(id); }
        location.href = url;
    }
</script>
