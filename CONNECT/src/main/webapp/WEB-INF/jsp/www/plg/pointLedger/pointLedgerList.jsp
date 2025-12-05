<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.2/dist/css/bootstrap.min.css"/>
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>

<style>
    :root {
        --bg:#f7f8fb;
        --card:#ffffff;
        --line:#e5e7eb;
        --text:#0f172a;
        --muted:#6b7280;
        --accent:#2563eb;
        --danger:#dc2626;
        --success:#16a34a;
    }

    body { background: var(--bg); }

    .page-wrap {
        max-width: 960px;
        margin: 16px auto 40px;
        padding: 0 12px;
    }

    .page-title {
        font-size: 24px;
        font-weight: 800;
        color: var(--text);
        margin-bottom: 16px;
    }

    .point-summary-card {
        background: var(--card);
        border-radius: 16px;
        border: 1px solid var(--line);
        padding: 16px 18px;
        margin-bottom: 16px;
    }

    .point-balance {
        font-size: 26px;
        font-weight: 800;
        color: #111827;
    }

    .point-balance-label {
        font-size: 13px;
        color: var(--muted);
    }

    .charge-card {
        background: var(--card);
        border-radius: 16px;
        border: 1px solid var(--line);
        padding: 16px 18px;
        margin-bottom: 16px;
    }

    .charge-label {
        font-size: 13px;
        color: var(--muted);
        margin-bottom: 4px;
    }

    .charge-input-group {
        display: flex;
        align-items: center;
        gap: 8px;
        margin-bottom: 10px;
    }

    .charge-input-group input[type="number"] {
        flex: 1;
    }

    .history-card {
        background: var(--card);
        border-radius: 16px;
        border: 1px solid var(--line);
        padding: 12px 14px;
    }

    .history-title {
        font-size: 15px;
        font-weight: 700;
        margin-bottom: 8px;
        color: var(--text);
    }

    .history-sub {
        font-size: 12px;
        color: var(--muted);
    }

    .table-sm th,
    .table-sm td {
        font-size: 13px;
        vertical-align: middle;
    }

    .amt-plus { color: #16a34a; font-weight: 600; }
    .amt-minus { color: #dc2626; font-weight: 600; }

</style>

<div class="page-wrap">
    <h2 class="page-title">포인트 충전</h2>

    <!-- 상단: 현재 잔액 -->
    <div class="point-summary-card">
        <div class="d-flex justify-content-between align-items-center">
            <div>
                <div class="point-balance-label">현재 보유 포인트</div>
                <div class="point-balance" id="pointBalance">0 P</div>
            </div>
            <div class="text-right">
                <div class="point-balance-label">
                    <span id="userName"></span>
                    <span id="userEmail" class="d-block"></span>
                </div>
            </div>
        </div>
    </div>

    <!-- 충전 영역 -->
    <div class="charge-card">
        <div class="charge-label">충전 금액 (원/P)</div>
        <div class="charge-input-group">
            <input
                type="number"
                min="100"
                step="100"
                id="chargeAmt"
                class="form-control"
                placeholder="충전할 금액을 입력하세요 (예: 10000)"
            />
            <button type="button" class="btn btn-outline-secondary btn-sm" onclick="setQuickAmt(10000)">+1만</button>
            <button type="button" class="btn btn-outline-secondary btn-sm" onclick="setQuickAmt(50000)">+5만</button>
            <button type="button" class="btn btn-outline-secondary btn-sm" onclick="setQuickAmt(100000)">+10만</button>
        </div>

        <div class="charge-label">메모 (선택)</div>
        <textarea
            id="chargeMemo"
            class="form-control mb-3"
            rows="2"
            placeholder="예) 카드 결제 예정, 이벤트용 적립 등"
        ></textarea>

        <div class="d-flex justify-content-between align-items-center">
            <small class="text-muted">
                * 지금은 내부 충전만 됩니다. 나중에 PG 연동 시 이 버튼에서 실제 결제 연동하면 됨.
            </small>
            <button
                type="button"
                class="btn btn-primary"
                onclick="submitCharge()"
            >
                포인트 충전
            </button>
        </div>
    </div>

    <!-- 하단: 거래 내역 -->
    <div class="history-card">
        <div class="d-flex justify-content-between align-items-center mb-2">
            <div class="history-title">포인트 충전/사용 내역</div>
            <div class="history-sub">최근 50건 기준</div>
        </div>

        <div class="table-responsive">
            <table class="table table-sm table-hover mb-0">
                <thead class="thead-light">
                    <tr>
                        <th style="width: 140px;">일시</th>
                        <th style="width: 80px;">구분</th>
                        <th style="width: 120px; text-align:right;">변동 금액</th>
                        <th style="width: 120px; text-align:right;">거래 후 잔액</th>
                        <th>메모</th>
                    </tr>
                </thead>
                <tbody id="pointHistoryBody">
                </tbody>
            </table>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@4.6.2/dist/js/bootstrap.bundle.min.js"></script>

<script>
    const API_BASE = '/api/plg/pointLedger';

    $(function () {
        loadPointHome();
    });

    function fmtMoney(v) {
        if (v === null || v === undefined || v === '') return '0';
        const n = Number(v);
        if (isNaN(n)) return String(v);
        return n.toLocaleString();
    }

    function labelType(typeCd) {
        if (!typeCd) return '';
        const t = String(typeCd).toUpperCase();
        if (t === 'CHARGE' || t === 'EARN') return '충전';
        if (t === 'USE' || t === 'PAY') return '사용';
        if (t === 'REFUND') return '환불';
        return typeCd;
    }

    function signByType(typeCd) {
        if (!typeCd) return '';
        const t = String(typeCd).toUpperCase();
        if (t === 'CHARGE' || t === 'EARN' || t === 'REFUND') return '+';
        return '-';
    }

    function handleLoginRequired(map) {
        if (map && map.msg === 'LOGIN_REQUIRED') {
            alert('로그인이 필요한 서비스입니다.');
            location.href = '/mba/auth/login';
            return true;
        }
        return false;
    }

    function loadPointHome() {
        const payload = {
            limit: 50,
            offset: 0
        };

        $.ajax({
            url: API_BASE + '/selectMyPointHome',
            type: 'post',
            contentType: 'application/json',
            dataType: 'json',
            data: JSON.stringify(payload),
            success: function (map) {
                if (!map) {
                    alert('포인트 조회 중 오류가 발생했습니다.');
                    return;
                }
                if (handleLoginRequired(map)) {
                    return;
                }
                if (map.msg !== '성공') {
                    alert(map.msg || '포인트 조회 중 오류가 발생했습니다.');
                    return;
                }

                const result = map.result || {};
                const summary = result.summary || {};
                const items = result.items || [];

                // 상단 요약
                $('#pointBalance').text(fmtMoney(summary.pointBalance || 0) + ' P');
                $('#userName').text(summary.userNm ? (summary.userNm + '님') : '');
                $('#userEmail').text(summary.email || '');

                // 거래 내역
                renderHistory(items);
            },
            error: function () {
                alert('포인트 조회 중 서버 오류가 발생했습니다.');
            }
        });
    }

    function renderHistory(list) {
        const $body = $('#pointHistoryBody');
        if (!list || !list.length) {
            $body.html(
                "<tr><td colspan='5' class='text-center text-muted'>거래 내역이 없습니다.</td></tr>"
            );
            return;
        }

        let html = '';
        for (let i = 0; i < list.length; i++) {
            const r = list[i];
            const createdDt = r.createdDt || '';
            const typeCd = r.typeCd || '';
            const amt = Number(r.amt || 0);
            const balanceAfter = Number(r.balanceAfter || 0);
            const memo = r.memo || '';

            const sign = signByType(typeCd);
            const cls = sign === '+' ? 'amt-plus' : 'amt-minus';

            html += '<tr>';
            html += '  <td>' + escapeHtml(createdDt) + '</td>';
            html += '  <td>' + escapeHtml(labelType(typeCd)) + '</td>';
            html += '  <td class="text-right ' + cls + '">' + sign + fmtMoney(Math.abs(amt)) + '</td>';
            html += '  <td class="text-right">' + fmtMoney(balanceAfter) + '</td>';
            html += '  <td>' + escapeHtml(memo) + '</td>';
            html += '</tr>';
        }

        $body.html(html);
    }

    function getChargeAmt() {
        const raw = $('#chargeAmt').val();
        const n = Number(raw);
        if (!n || isNaN(n) || n <= 0) return 0;
        return Math.floor(n);
    }

    function setQuickAmt(plus) {
        const current = getChargeAmt();
        const next = current + plus;
        $('#chargeAmt').val(next);
    }

    function submitCharge() {
        const amt = getChargeAmt();
        if (amt <= 0) {
            alert('충전할 금액을 입력해주세요.');
            $('#chargeAmt').focus();
            return;
        }

        if (!confirm(fmtMoney(amt) + '원을 충전하시겠습니까?')) {
            return;
        }

        const memo = ($('#chargeMemo').val() || '').trim();

        const payload = {
            amt: amt,
            memo: memo
        };

        $.ajax({
            url: API_BASE + '/charge',
            type: 'post',
            contentType: 'application/json',
            dataType: 'json',
            data: JSON.stringify(payload),
            success: function (map) {
                if (!map) {
                    alert('충전 중 오류가 발생했습니다.');
                    return;
                }
                if (handleLoginRequired(map)) {
                    return;
                }
                if (map.msg !== '성공') {
                    alert(map.msg || '충전 중 오류가 발생했습니다.');
                    return;
                }

                alert('포인트가 충전되었습니다.');
                $('#chargeAmt').val('');
                $('#chargeMemo').val('');
                loadPointHome();
            },
            error: function () {
                alert('충전 중 서버 오류가 발생했습니다.');
            }
        });
    }

    function escapeHtml(s) {
        return String(s || '').replace(/[&<>"']/g, function (m) {
            return {
                '&': '&amp;',
                '<': '&lt;',
                '>': '&gt;',
                '"': '&quot;',
                "'": '&#39;'
            }[m];
        });
    }
</script>
