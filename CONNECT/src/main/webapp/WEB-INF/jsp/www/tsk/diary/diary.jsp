<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<link rel="icon" href="data:,">
<link rel="stylesheet" href="https://uicdn.toast.com/editor/latest/toastui-editor.min.css" />
<script src="https://uicdn.toast.com/editor/latest/toastui-editor-all.min.js"></script>

<section>
    <h2 class="mb-3">일기</h2>

    <!-- 달력 -->
    <div class="card p-3 mb-3" style="max-width: 960px; border-radius:16px; border:1px solid #e9edf3;">
        <div class="d-flex align-items-center justify-content-between mb-2">
            <div class="d-flex align-items-center">
                <button id="btnPrevMonth" type="button" class="btn btn-light btn-sm mr-2" aria-label="이전 달">&laquo;</button>
                <div id="calMonthLabel" class="font-weight-bold" style="font-size:18px;"></div>
                <button id="btnNextMonth" type="button" class="btn btn-light btn-sm ml-2" aria-label="다음 달">&raquo;</button>
            </div>
            <div><button id="btnToday" type="button" class="btn btn-outline-dark btn-sm">오늘</button></div>
        </div>
        <div id="calendarGrid" class="table-responsive"></div>
    </div>

    <!-- 에디터 -->
    <div class="card p-3" style="max-width: 960px; border-radius:16px; border:1px solid #e9edf3;">
        <div class="d-flex align-items-center justify-content-between mb-2">
            <span id="selectedDateBadge" class="badge badge-pill badge-light" style="font-size:14px; border:1px solid #e9edf3; color:#111827; background:#fff; padding:8px 12px;">날짜 선택</span>
            <div>
                <button id="btnClear" class="btn btn-outline-secondary btn-sm mr-1" type="button">비우기</button>
                <button id="btnSave" class="btn btn-primary btn-sm" type="button">저장</button>
            </div>
        </div>
        <div id="diaryEditor" style="height: 460px;"></div>
        <small class="text-muted d-block mt-2">이미지 삽입은 에디터의 “이미지” 버튼 사용</small>
    </div>
</section>

<style>
:root{ --line:#e9edf3; --text:#0f172a; }
.table td, .table th{ vertical-align:middle; }
.skeleton{ background:linear-gradient(90deg,#f3f4f6 25%,#e5e7eb 37%,#f3f4f6 63%); background-size:400% 100%; animation:shimmer 1.2s ease-in-out infinite; color:transparent; }
@keyframes shimmer{0%{background-position:100% 0}100%{background-position:-100% 0}}
</style>

<script>
(function(){
    // ===== API =====
    var DIARY_API = {
        select: '/api/tsk/diary/selectDiaryByDate',
        upsert: '/api/tsk/diary/upsertDiary'
    };
    var FILE_UPLOAD_API = '/api/common/file/upload';

    // ===== 상태 =====
    var viewYear, viewMonth, selectedDate;
    var editor;
    var GRP_CD = (window.GRP_CD || getParam('grpCd')) || null;

    // ===== 유틸 =====
    function pad(n){ return (n<10?'0':'') + n; }
    function fmtDate(d){ return d.getFullYear()+'-'+pad(d.getMonth()+1)+'-'+pad(d.getDate()); }
    function isSameDate(a,b){ return a.getFullYear()===b.getFullYear() && a.getMonth()===b.getMonth() && a.getDate()===b.getDate(); }
    function getParam(name){ try{ var u=new URL(location.href); return u.searchParams.get(name); }catch(e){ return null; } }

    // ===== 초기화 (에디터 먼저) =====
    function init(){
        editor = new toastui.Editor({
            el: document.querySelector('#diaryEditor'),
            height: '460px',
            initialEditType: 'markdown',
            previewStyle: 'vertical',
            placeholder: '오늘의 일기를 작성하세요...',
            hooks: {
                addImageBlobHook: function (blob, callback) {
                    var fd = new FormData(); fd.append('file', blob);
                    fetch(FILE_UPLOAD_API, { method: 'POST', body: fd })
                      .then(function(resp){ var ct=(resp.headers.get('content-type')||'').toLowerCase(); return ct.indexOf('json')>-1?resp.json():resp.text(); })
                      .then(function(body){
                          var url = (typeof body==='string') ? body : (body && (body.url || body.fileUrl || (body.result && (body.result.url || body.result.fileUrl))));
                          if(!url){ alert('이미지 업로드 실패'); return; }
                          var alt=(blob&&blob.name?blob.name:'image').replace(/\.[^/.]+$/,'').replace(/[\[\]\(\)!\\]/g,' ').trim();
                          callback(url, alt);
                      }).catch(function(){ alert('이미지 업로드 실패'); });
                    return false;
                }
            }
        });

        var today = new Date();
        viewYear = today.getFullYear();
        viewMonth = today.getMonth();
        selectedDate = fmtDate(today);

        document.getElementById('btnPrevMonth').addEventListener('click', function(){ moveMonth(-1); });
        document.getElementById('btnNextMonth').addEventListener('click', function(){ moveMonth(1); });
        document.getElementById('btnToday').addEventListener('click', goToday);
        document.getElementById('btnSave').addEventListener('click', saveDiary);
        document.getElementById('btnClear').addEventListener('click', function(){ if(confirm('현재 일기를 비울까요?')) editor.setHTML(''); });
        document.getElementById('calendarGrid').addEventListener('click', function(e){
            var td=e.target; while(td && td.tagName!=='TD') td=td.parentNode;
            if(td && td.getAttribute('data-date')) pickDate(td.getAttribute('data-date'));
        });

        renderCalendar();
        pickDate(selectedDate);
    }

    // ===== 달력 =====
    function renderCalendar(){
        document.getElementById('calMonthLabel').textContent = viewYear + '. ' + pad(viewMonth+1);
        var weekdays=['일','월','화','수','목','금','토'], html='';
        html+='<table class="table table-sm mb-0" style="border:1px solid var(--line); border-radius:12px; overflow:hidden;">';
        html+='<thead class="thead-light"><tr>'; for(var i=0;i<7;i++) html+='<th class="text-center" style="width:14.28%;">'+weekdays[i]+'</th>'; html+='</tr></thead><tbody>';

        var first=new Date(viewYear,viewMonth,1), last=new Date(viewYear,viewMonth+1,0);
        var startIdx=first.getDay(), total=last.getDate(), day=1-startIdx;
        for(var r=0;r<6;r++){
            html+='<tr>';
            for(var c=0;c<7;c++){
                var d=new Date(viewYear,viewMonth,day), inMonth=(d.getMonth()===viewMonth);
                var ymd=fmtDate(d), isSel=(ymd===selectedDate), isToday=isSameDate(d,new Date());
                var cls='text-center align-middle'+(inMonth?'':' text-muted')+(isSel?' font-weight-bold':'');
                var capsule='display:inline-block; min-width:28px; line-height:28px; border-radius:14px;';
                if(isSel) capsule+='background:#111827; color:#fff;';
                else if(isToday) capsule+='border:1px solid #111827; color:#111827;';
                else if(!inMonth) capsule+='color:#9aa4b2;';
                html+='<td class="'+cls+'" data-date="'+ymd+'" style="height:48px; cursor:pointer; border-top:1px solid #f1f3f7;"><div style="'+capsule+'">'+d.getDate()+'</div></td>';
                day++;
            }
            html+='</tr>';
            if(day>total && (startIdx+total)<=r*7+6) break;
        }
        html+='</tbody></table>';
        document.getElementById('calendarGrid').innerHTML = html;
    }
    function moveMonth(delta){ viewMonth+=delta; if(viewMonth<0){viewMonth=11;viewYear--;} if(viewMonth>11){viewMonth=0;viewYear++;} renderCalendar(); }
    function goToday(){ var t=new Date(); viewYear=t.getFullYear(); viewMonth=t.getMonth(); pickDate(fmtDate(t)); renderCalendar(); }
    function pickDate(ymd){ selectedDate=ymd; document.getElementById('selectedDateBadge').textContent=selectedDate; renderCalendar(); loadDiary(ymd); }

    // ===== API 연동 =====
    function loadDiary(dateStr){
        if(!editor){ setTimeout(function(){ loadDiary(dateStr); }, 30); return; }
        editor.setHTML('<p class="skeleton">로딩 중...</p>');
        var body={ diaryDt: dateStr }; if(GRP_CD) body.grpCd=GRP_CD;

        fetch(DIARY_API.select, { method:'POST', headers:{'Content-Type':'application/json'}, body:JSON.stringify(body) })
          .then(function(r){ return r.json(); })
          .then(function(map){
              var r=(map&&map.result)?map.result:map;
              var html=(r&&(r.contentHtml||r.CONTENT_HTML))||(r&&(r.content||r.CONTENT))||'';
              editor.setHTML(html||'');
          })
          .catch(function(){ editor.setHTML(''); alert('일기 불러오기 실패'); });
    }
    function saveDiary(){
        if(!selectedDate){ alert('날짜를 먼저 선택하세요.'); return; }
        var html=editor.getHTML().trim();
        var body={ diaryDt:selectedDate, content:html }; if(GRP_CD) body.grpCd=GRP_CD;

        fetch(DIARY_API.upsert, { method:'POST', headers:{'Content-Type':'application/json'}, body:JSON.stringify(body) })
          .then(function(r){ if(!r.ok) throw new Error(); return r.json(); })
          .then(function(){ alert('저장되었습니다.'); })
          .catch(function(){ alert('저장 실패'); });
    }

    init();
})();
</script>