<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<section>
    <h2 class="mb-3">가게부</h2> 

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

    <!-- 입력 -->
    <div class="card p-3 mb-3" style="max-width: 960px; border-radius:16px; border:1px solid #e9edf3;">
        <div class="mb-2 d-flex align-items-center justify-content-between">
            <span id="selectedDateBadge" class="badge badge-pill badge-light" style="font-size:14px; border:1px solid #e9edf3; color:#111827; background:#fff; padding:8px 12px;">날짜 선택</span>
            <div class="custom-control custom-checkbox">
                <input type="checkbox" class="custom-control-input" id="fixedAtInput">
                <label class="custom-control-label" for="fixedAtInput">고정</label>
            </div>
        </div>

        <div class="form-row">
            <div class="form-group col-md-4">
                <label class="small text-muted mb-1">제목(계정명)</label>
                <input id="accountNmInput" type="text" class="form-control" placeholder="예: 점심 - 김밥" />
            </div>
            <div class="form-group col-md-3">
                <label class="small text-muted mb-1">카테고리</label>
                <input id="categoryInput" type="text" class="form-control" placeholder="예: 식비 / 교통" />
            </div>
            <div class="form-group col-md-3">
                <label class="small text-muted mb-1">금액</label>
                <div class="input-group">
                    <div class="input-group-prepend"><span class="input-group-text bg-white">₩</span></div>
                    <input id="amountInput" type="number" step="0.01" min="0" class="form-control" placeholder="0" />
                </div>
            </div>
            <div class="form-group col-md-2">
                <label class="small text-muted mb-1 d-block">유형</label>
                <div class="btn-group btn-group-toggle d-flex" data-toggle="buttons">
                    <label id="btnIn"  class="btn btn-outline-success active" style="border-radius:8px 0 0 8px;">
                        <input type="radio" name="ioType" value="IN" checked /> 수입
                    </label>
                    <label id="btnOut" class="btn btn-outline-danger" style="border-radius:0 8px 8px 0;">
                        <input type="radio" name="ioType" value="OUT" /> 지출
                    </label>
                </div>
            </div>
        </div>

        <div class="text-right">
            <small class="text-muted mr-2">Enter 키로도 저장됩니다.</small>
            <button id="btnAdd" class="btn btn-primary" type="button">추가</button>
        </div>
    </div>

    <!-- 목록 -->
    <div class="card p-3" style="border-radius:16px; border:1px solid #e9edf3;">
        <div class="d-flex align-items-center justify-content-between mb-2">
            <div class="font-weight-bold">목록</div>
            <div class="d-flex align-items-center">
                <div class="custom-control custom-checkbox mr-3">
                    <input type="checkbox" class="custom-control-input" id="fixedOnlyFilter">
                    <label class="custom-control-label" for="fixedOnlyFilter">고정만 보기</label>
                </div>
                <div id="dailyKpi" class="text-muted small"></div>
            </div>
        </div>
        <div class="table-responsive">
            <table class="table table-hover align-middle mb-0">
                <thead class="thead-light">
                    <tr>
                        <th style="width:90px; text-align:right;">번호</th>
                        <th>제목 / 카테고리</th>
                        <th style="width:160px; text-align:right;">금액</th>
                        <th style="width:120px;">고정</th>
                        <th style="width:180px;">작성일</th>
                        <th style="width:90px; text-align:center;">관리</th>
                    </tr>
                </thead>
                <tbody id="ledgerListBody"></tbody>
            </table>
        </div>
    </div>
</section>

<style>
:root{ --line:#e9edf3; --text:#0f172a; }
.table td, .table th{ vertical-align:middle; }
.skeleton{ background:linear-gradient(90deg,#f3f4f6 25%,#e5e7eb 37%,#f3f4f6 63%); background-size:400% 100%; animation:shimmer 1.2s ease-in-out infinite; color:transparent; }
@keyframes shimmer{0%{background-position:100% 0}100%{background-position:-100% 0}}
.amount-in{ color:#0ea5e9; font-weight:700; font-variant-numeric:tabular-nums; }
.amount-out{ color:#ef4444; font-weight:700; font-variant-numeric:tabular-nums; }
.badge-fixed{ background:#111827; color:#fff; border-radius:12px; padding:2px 8px; }
</style>

<script>
(function(){
    var API_BASE = '/api/txn/ledger';
    var txnIdKey = 'txnId';

    var viewYear, viewMonth, selectedDate;

    function pad(n){ return (n<10?'0':'') + n; }
    function fmtDate(d){ return d.getFullYear()+'-'+pad(d.getMonth()+1)+'-'+pad(d.getDate()); }
    function isSameDate(a,b){ return a.getFullYear()===b.getFullYear() && a.getMonth()===b.getMonth() && a.getDate()===b.getDate(); }
    function esc(s){ return String(s||'').replace(/[&<>"']/g,function(m){return {'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[m];}); }
    function toNumber(x){ var n = Number(String(x||'').replace(/,/g,'')); return isNaN(n)?0:n; }
    function fmtMoney(n){ n = Number(n||0); return n.toLocaleString('ko-KR', {maximumFractionDigits:2}); }

    function init(){
        var today = new Date();
        viewYear = today.getFullYear();
        viewMonth = today.getMonth();
        selectedDate = fmtDate(today);

        renderCalendar();
        pickDate(selectedDate);

        document.getElementById('btnPrevMonth').addEventListener('click', function(){ moveMonth(-1); });
        document.getElementById('btnNextMonth').addEventListener('click', function(){ moveMonth(1); });
        document.getElementById('btnToday').addEventListener('click', goToday);
        document.getElementById('btnAdd').addEventListener('click', submitForm);

        ['accountNmInput','categoryInput','amountInput'].forEach(function(id){
            document.getElementById(id).addEventListener('keydown', function(e){ if(e.key === 'Enter') submitForm(); });
        });

        document.getElementById('calendarGrid').addEventListener('click', function(e){
            var td = e.target; while(td && td.tagName!=='TD') td=td.parentNode;
            if(td && td.getAttribute('data-date')) pickDate(td.getAttribute('data-date'));
        });

        document.getElementById('ledgerListBody').addEventListener('click', function(e){
            var t = e.target;
            if(t.matches && t.matches('button[data-delete]')){ e.stopPropagation(); return deleteRow(t.getAttribute('data-delete')); }
        });

        document.getElementById('fixedOnlyFilter').addEventListener('change', function(){
            loadList(selectedDate);
        });
    }

    // 달력
    function renderCalendar(){
        document.getElementById('calMonthLabel').textContent = viewYear + '. ' + pad(viewMonth+1);
        var weekdays=['일','월','화','수','목','금','토'], html='';
        html += '<table class="table table-sm mb-0" style="border:1px solid var(--line); border-radius:12px; overflow:hidden;">';
        html += '<thead class="thead-light"><tr>';
        for(var i=0;i<7;i++) html += '<th class="text-center" style="width:14.28%;">'+weekdays[i]+'</th>';
        html += '</tr></thead><tbody>';

        var first=new Date(viewYear,viewMonth,1), last=new Date(viewYear,viewMonth+1,0);
        var startIdx=first.getDay(), total=last.getDate(), day=1-startIdx;

        for(var r=0;r<6;r++){
            html += '<tr>';
            for(var c=0;c<7;c++){
                var d=new Date(viewYear,viewMonth,day), inMonth=(d.getMonth()===viewMonth);
                var ymd=fmtDate(d), isSel=(ymd===selectedDate), isToday=isSameDate(d,new Date());
                var cls='text-center align-middle'+(inMonth?'':' text-muted')+(isSel?' font-weight-bold':'');
                var capsule='display:inline-block; min-width:28px; line-height:28px; border-radius:14px;';
                if(isSel) capsule+='background:#111827; color:#fff;'; else if(isToday) capsule+='border:1px solid #111827; color:#111827;'; else if(!inMonth) capsule+='color:#9aa4b2;';
                html += '<td class="'+cls+'" data-date="'+ymd+'" style="height:48px; cursor:pointer; border-top:1px solid #f1f3f7;"><div style="'+capsule+'">'+d.getDate()+'</div></td>';
                day++;
            }
            html += '</tr>';
            if(day>total && (startIdx+total)<=r*7+6) break;
        }
        html += '</tbody></table>';
        document.getElementById('calendarGrid').innerHTML = html;
    }
    function moveMonth(delta){ viewMonth+=delta; if(viewMonth<0){viewMonth=11;viewYear--;} if(viewMonth>11){viewMonth=0;viewYear++;} renderCalendar(); }
    function goToday(){ var t=new Date(); viewYear=t.getFullYear(); viewMonth=t.getMonth(); pickDate(fmtDate(t)); renderCalendar(); }
    function pickDate(ymd){ selectedDate=ymd; document.getElementById('selectedDateBadge').textContent = selectedDate; renderCalendar(); loadList(ymd); }

    // 목록
    function loadList(dateStr){
        renderSkeletonRows();

        var fixedOnly = document.getElementById('fixedOnlyFilter').checked;
        var filter = fixedOnly
            ? { fixedOnly: true }                 // 날짜 무시
            : { searchDate: dateStr, ledgerDate: dateStr, txnDt: dateStr, createDate: dateStr, from: dateStr, to: dateStr };

        fetch(API_BASE + '/selectLedgerList', {
            method:'POST', headers:{'Content-Type':'application/json'}, body:JSON.stringify(filter)
        }).then(function(r){return r.json();}).then(function(map){
            var rows = (map && map.result) ? map.result : (map && map.result && map.result.rows ? map.result.rows : []);
            if(!rows || !rows.length){
                document.getElementById('ledgerListBody').innerHTML = "<tr><td colspan='6' class='text-center text-muted'>데이터가 없습니다.</td></tr>";
                document.getElementById('dailyKpi').textContent = '총 0건';
                return;
            }
            var inSum=0, outSum=0, html='';
            for(var i=0;i<rows.length;i++){
                var r = rows[i];
                var id   = r.txnId || r.TXN_ID;
                var ttl  = r.accountNm || r.ACCOUNT_NM || '';
                var cat  = r.categoryNm || r.CATEGORY_NM || '';
                var io   = (r.ioType || r.IO_TYPE || '').toString().toUpperCase();
                var amt  = toNumber(r.amount || r.AMOUNT);
                var day  = r.txnDt || r.TXN_DT || r.createdDt || r.CREATED_DT || '';
                var fixed = (r.fixedAt || r.FIXED_AT || 'N') === 'Y';
                if(typeof day==='object'){ day = day.value || String(day); }

                if(io==='IN') inSum += amt; else if(io==='OUT') outSum += amt;
                var sign = (io==='IN')?'+':'-';
                var cls  = (io==='IN')?'amount-in':'amount-out';
                var catStr = cat ? ('<span class="text-muted small ml-2">#'+esc(cat)+'</span>') : '';
                var fixedStr = fixed ? '<span class="badge-fixed">고정</span>' : '';

                html += "<tr data-id='"+esc(id)+"'>";
                html += "  <td class='text-right'>"+esc(id)+"</td>";
                html += "  <td>"+esc(ttl)+catStr+"</td>";
                html += "  <td class='text-right "+cls+"'>"+sign+fmtMoney(amt)+"</td>";
                html += "  <td>"+fixedStr+"</td>";
                html += "  <td>"+esc(day)+"</td>";
                html += "  <td class='text-center'><button type='button' class='btn btn-outline-danger btn-sm' data-delete='"+esc(id)+"'>삭제</button></td>";
                html += "</tr>";
            }
            document.getElementById('ledgerListBody').innerHTML = html;
            var net = inSum - outSum;
            document.getElementById('dailyKpi').textContent = '총 '+rows.length+'건 · 수입 '+fmtMoney(inSum)+' · 지출 '+fmtMoney(outSum)+' · 순변화 '+fmtMoney(net);
        }).catch(function(){ alert('목록 조회 중 오류'); });
    }
    function renderSkeletonRows(){
        var h='';
        for(var i=0;i<3;i++){
            h += "<tr><td class='text-right'><span class='skeleton'>0000</span></td><td><span class='skeleton'>제목</span></td><td class='text-right'><span class='skeleton'>0</span></td><td><span class='skeleton'>고정</span></td><td><span class='skeleton'>YYYY-MM-DD</span></td><td class='text-center'><span class='skeleton'>버튼</span></td></tr>";
        }
        document.getElementById('ledgerListBody').innerHTML = h;
        document.getElementById('dailyKpi').textContent='';
    }

    // 저장
    function submitForm(){
        var accountNm = document.getElementById('accountNmInput').value.trim();
        var categoryNm = document.getElementById('categoryInput').value.trim();
        var amount = toNumber(document.getElementById('amountInput').value);
        var ioType = document.querySelector('input[name="ioType"]:checked').value;
        var fixedAt = document.getElementById('fixedAtInput').checked ? 'Y' : 'N';
        if(!accountNm){ document.getElementById('accountNmInput').focus(); return; }
        if(!(amount>0)){ document.getElementById('amountInput').focus(); return; }

        var d = selectedDate;
        var payload = {
            accountNm: accountNm,
            categoryNm: categoryNm,
            amount: amount,
            ioType: ioType,
            fixedAt: fixedAt,
            currencyCd: 'KRW',
            ledgerDate: d, createDate: d, txnDt: d
        };

        fetch(API_BASE + '/insertLedger', {
            method:'POST', headers:{'Content-Type':'application/json'}, body:JSON.stringify(payload)
        }).then(function(r){
            if(!r.ok) throw new Error('등록 실패');
            return r.json();
        }).then(function(){
            document.getElementById('accountNmInput').value='';
            document.getElementById('categoryInput').value='';
            document.getElementById('amountInput').value='';
            document.getElementById('fixedAtInput').checked=false;
            document.getElementById('accountNmInput').focus();
            loadList(d);
        }).catch(function(e){ alert(e.message); });
    }

    // 삭제
    function deleteRow(id){
        var sendData = {}; sendData[txnIdKey] = id;
        fetch(API_BASE + '/deleteLedger', {
            method:'POST', headers:{'Content-Type':'application/json'}, body:JSON.stringify(sendData)
        }).then(function(r){ if(!r.ok) throw new Error('삭제 실패'); return r.json(); })
        .then(function(){ loadList(selectedDate); }).catch(function(e){ alert(e.message); });
    }

    // start
    init();
})();
</script>