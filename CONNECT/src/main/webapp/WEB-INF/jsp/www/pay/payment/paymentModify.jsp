<%@ page language="java" contentType="text/html; charset=UTF-8"%>

<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.2/dist/css/bootstrap.min.css"/>
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>

<style>
    :root{
        --bg:#f7f8fb; --card:#ffffff; --line:#e5e7eb; --text:#0f172a; --muted:#6b7280;
        --accent:#2563eb; --accent-soft:#dbeafe; --success:#16a34a;
    }
    body{ background:var(--bg); }

    .page-wrap{
        max-width: 720px;
        margin: 40px auto 60px;
        padding: 0 12px;
    }

    .complete-card{
        background: var(--card);
        border-radius: 18px;
        border: 1px solid var(--line);
        padding: 24px 22px;
        text-align: center;
    }

    .complete-icon{
        width: 56px;
        height: 56px;
        border-radius: 50%;
        border: 2px solid var(--accent-soft);
        display: flex;
        align-items: center;
        justify-content: center;
        margin: 0 auto 12px;
        color: var(--accent);
        font-size: 28px;
        background: #eff6ff;
    }

    .complete-title{
        font-size: 20px;
        font-weight: 800;
        color: var(--text);
        margin-bottom: 4px;
    }

    .complete-sub{
        font-size: 13px;
        color: var(--muted);
        margin-bottom: 16px;
    }

    .info-box{
        background: #f9fafb;
        border-radius: 14px;
        border: 1px solid var(--line);
        padding: 12px 14px;
        text-align: left;
        font-size: 13px;
        margin-bottom: 12px;
    }

    .info-row{
        display: flex;
        justify-content: space-between;
        margin-bottom: 6px;
    }

    .info-row:last-child{
        margin-bottom: 0;
    }

    .info-label{
        color: var(--muted);
    }

    .info-value{
        font-weight: 600;
        color: var(--text);
    }

    .info-value-em{
        font-weight: 800;
        color: #111827;
        font-size: 16px;
    }

    .btn-area{
        margin-top: 16px;
        display: flex;
        flex-wrap: wrap;
        gap: 8px;
    }

    .btn-area > a{
        flex: 1;
        min-width: 140px;
    }

    .notice-text{
        margin-top: 10px;
        font-size: 11px;
        color: var(--muted);
        text-align: left;
    }

    @media (max-width: 575px){
        .btn-area{
            flex-direction: column;
        }
    }
</style>

<div class="page-wrap">
    <div class="complete-card">
        <div class="complete-icon">
            ✓
        </div>
        <div class="complete-title">결제가 완료되었습니다</div>
        <div class="complete-sub">
            주문이 정상적으로 접수되었습니다. 아래 내용을 확인해 주세요.
        </div>

        <div class="info-box">
            <div class="info-row">
                <div class="info-label">주문번호</div>
                <div class="info-value" id="orderNo">-</div>
            </div>
            <div class="info-row">
                <div class="info-label">주문 금액</div>
                <div class="info-value" id="totalAmt">-</div>
            </div>
            <div class="info-row">
                <div class="info-label">쿠폰 할인</div>
                <div class="info-value" id="couponUseAmt">0원</div>
            </div>
            <div class="info-row">
                <div class="info-label">포인트 사용</div>
                <div class="info-value" id="pointUseAmt">0원</div>
            </div>
            <div class="info-row">
                <div class="info-label">최종 결제금액</div>
                <div class="info-value-em" id="payAmt">-</div>
            </div>
        </div>

        <div class="btn-area">
            <a href="/ord/order/orderList" class="btn btn-outline-secondary btn-sm">
                주문 내역 보기
            </a>
            <a href="/prd/product/productList" class="btn btn-outline-primary btn-sm">
                계속 쇼핑하기
            </a>
            <a href="/" class="btn btn-primary btn-sm">
                메인으로 이동
            </a>
        </div>

        <div class="notice-text">
            * 실제 포인트 차감 및 적립, 쿠폰 처리, PG 연동 내역은 추후 관리자 화면 및 정식 결제 모듈과 연동할 수 있습니다.<br/>
            * 주문 상세 정보는 "주문 내역 보기"에서 확인 가능합니다.
        </div>
    </div>
</div>

<script>
    $(function () {
        // 주문서에서 넘겨준 QueryString(orderNo, totalAmt, payAmt, pointUseAmt, couponUseAmt)을 읽는다.
        const params = new URLSearchParams(window.location.search);

        const orderNo      = params.get('orderNo') || '-';
        const totalAmt     = params.get('totalAmt');
        const payAmt       = params.get('payAmt');
        const pointUseAmt  = params.get('pointUseAmt');
        const couponUseAmt = params.get('couponUseAmt');

        $('#orderNo').text(orderNo);
        $('#totalAmt').text(totalAmt ? fmtMoney(totalAmt) + '원' : '-');
        $('#payAmt').text(payAmt ? fmtMoney(payAmt) + '원' : '-');

        // 포인트 사용
        let p = 0;
        if (pointUseAmt !== null && pointUseAmt !== undefined && pointUseAmt !== '') {
            const n = Number(pointUseAmt);
            if (!isNaN(n) && n > 0) p = n;
        }
        $('#pointUseAmt').text(p ? '-' + fmtMoney(p) + '원' : '0원');

        // 쿠폰 할인
        let c = 0;
        if (couponUseAmt !== null && couponUseAmt !== undefined && couponUseAmt !== '') {
            const n2 = Number(couponUseAmt);
            if (!isNaN(n2) && n2 > 0) c = n2;
        }
        $('#couponUseAmt').text(c ? '-' + fmtMoney(c) + '원' : '0원');
    });

    function fmtMoney(v) {
        if (v === null || v === undefined || v === '') return '0';
        const n = Number(v);
        if (isNaN(n)) return '0';
        return n.toLocaleString();
    }
</script>
