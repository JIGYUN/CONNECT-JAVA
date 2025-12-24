<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>

<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.2/dist/css/bootstrap.min.css"/>
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@4.6.2/dist/js/bootstrap.bundle.min.js"></script>

<!-- Toss Payments (B안: 결제창) -->
<script src="https://js.tosspayments.com/v2/standard"></script>

<style>
    :root{
        --bg:#f7f8fb; --card:#ffffff; --line:#e5e7eb; --text:#0f172a; --muted:#6b7280;
        --accent:#2563eb; --danger:#dc2626;
    }
    body{ background:var(--bg); }

    .page-wrap{
        max-width: 1100px;
        margin: 16px auto 40px;
        padding: 0 12px;
    }

    .page-title{
        font-size: 24px;
        font-weight: 800;
        color: var(--text);
        margin: 12px 0 16px;
    }

    .order-layout{
        display: flex;
        flex-wrap: wrap;
        gap: 16px;
        align-items: flex-start;
    }

    .order-left{
        flex: 1 1 620px;
        min-width: 320px;
        display: flex;
        flex-direction: column;
        gap: 16px;
    }

    .order-right{
        flex: 0 0 320px;
        max-width: 360px;
    }

    .card-box{
        background: var(--card);
        border-radius: 16px;
        border: 1px solid var(--line);
        padding: 16px 18px;
    }

    .card-title-sm{
        font-size: 15px;
        font-weight: 700;
        margin-bottom: 10px;
        color: var(--text);
    }

    .form-label-sm{
        font-size: 13px;
        font-weight: 600;
        color: var(--muted);
        margin-bottom: 4px;
    }

    .form-control-sm2{
        font-size: 13px;
        padding: 6px 8px;
        height: auto;
    }

    .addr-row{
        display: flex;
        gap: 8px;
        margin-bottom: 6px;
    }

    .addr-row > div{
        flex: 1;
    }

    .order-items-empty{
        text-align: center;
        padding: 32px 0;
        font-size: 14px;
        color: var(--muted);
    }

    .order-item-row{
        display: flex;
        align-items: flex-start;
        gap: 10px;
        padding: 10px 0;
        border-top: 1px solid var(--line);
    }
    .order-item-row:first-of-type{
        border-top: none;
    }

    .order-thumb{
        flex: 0 0 64px;
        width: 64px;
        height: 64px;
        border-radius: 8px;
        background: #f3f4f6;
        object-fit: contain;
    }

    .order-item-main{
        flex: 1;
    }

    .order-item-title{
        font-size: 13px;
        font-weight: 600;
        color: var(--text);
        margin-bottom: 2px;
    }

    .order-item-meta{
        font-size: 11px;
        color: var(--muted);
        margin-bottom: 2px;
    }

    .order-item-price{
        font-size: 13px;
        font-weight: 700;
        margin-bottom: 2px;
    }

    .order-item-qty{
        font-size: 12px;
        color: var(--muted);
    }

    .summary-row{
        display: flex;
        justify-content: space-between;
        font-size: 14px;
        margin-bottom: 6px;
    }

    .summary-row .label{
        color: var(--muted);
    }

    .summary-row .value{
        font-weight: 600;
    }

    .summary-row.total{
        font-size: 18px;
        font-weight: 800;
        margin-top: 6px;
    }

    .summary-row.total .label{
        color: var(--text);
    }

    .summary-row.minus .value{
        color: var(--danger);
    }

    .summary-row.pay .value{
        color: #111827;
        font-size: 20px;
    }

    .point-balance{
        font-size: 12px;
        color: var(--muted);
        margin-bottom: 4px;
    }

    .point-input-row{
        display: flex;
        gap: 8px;
        align-items: center;
        margin-bottom: 6px;
    }

    .point-input-row input{
        max-width: 150px;
    }

    .btn-order-submit{
        width: 100%;
        margin-top: 12px;
        font-weight: 700;
        border-radius: 999px;
        padding: 10px 0;
    }

    .btn-order-back{
        width: 100%;
        margin-top: 6px;
        border-radius: 999px;
        font-size: 13px;
    }

    .final-pay-text{
        font-size: 13px;
        color: var(--muted);
        margin-top: 4px;
        line-height: 1.45;
    }

    @media (max-width: 767px){
        .order-layout{
            flex-direction: column;
        }
        .order-right{
            max-width: 100%;
        }
    }
</style>

<div class="page-wrap">
    <h2 class="page-title">주문/결제</h2>

    <div class="order-layout">
        <!-- LEFT -->
        <div class="order-left">
            <div class="card-box">
                <div class="card-title-sm">배송지 정보</div>
                <form id="shippingForm">
                    <div class="form-group">
                        <label class="form-label-sm" for="receiverNm">받는 사람</label>
                        <input type="text" class="form-control form-control-sm2" id="receiverNm" name="receiverNm" placeholder="이름을 입력하세요"/>
                    </div>
                    <div class="form-group">
                        <label class="form-label-sm" for="receiverPhone">연락처</label>
                        <input type="text" class="form-control form-control-sm2" id="receiverPhone" name="receiverPhone" placeholder="예: 010-1234-5678"/>
                    </div>

                    <div class="form-group">
                        <label class="form-label-sm">주소</label>
                        <div class="addr-row">
                            <div style="flex:0 0 110px;">
                                <input type="text" class="form-control form-control-sm2" id="zipCode" name="zipCode" placeholder="우편번호"/>
                            </div>
                            <div>
                                <button type="button" class="btn btn-sm btn-outline-secondary btn-block" onclick="alert('주소 검색은 나중에 연동');">
                                    주소 검색
                                </button>
                            </div>
                        </div>
                        <div class="addr-row">
                            <div>
                                <input type="text" class="form-control form-control-sm2" id="addr1" name="addr1" placeholder="기본 주소"/>
                            </div>
                        </div>
                        <div class="addr-row">
                            <div>
                                <input type="text" class="form-control form-control-sm2" id="addr2" name="addr2" placeholder="상세 주소"/>
                            </div>
                        </div>
                    </div>

                    <div class="form-group mb-0">
                        <label class="form-label-sm" for="deliveryMemo">배송 메모</label>
                        <textarea class="form-control form-control-sm2" id="deliveryMemo" name="deliveryMemo" rows="2" placeholder="예: 부재 시 문 앞에 놓아주세요."></textarea>
                    </div>
                </form>
            </div>

            <div class="card-box">
                <div class="card-title-sm">주문 상품</div>
                <div id="orderItemList"></div>
            </div>
        </div>

        <!-- RIGHT -->
        <div class="order-right">
            <div class="card-box">
                <div class="card-title-sm">결제 정보</div>

                <div class="summary-row">
                    <span class="label">상품 금액 합계</span>
                    <span class="value" id="sumProduct">0원</span>
                </div>
                <div class="summary-row">
                    <span class="label">배송비 합계</span>
                    <span class="value" id="sumShip">0원</span>
                </div>
                <div class="summary-row total">
                    <span class="label">주문 금액</span>
                    <span class="value" id="sumOrder">0원</span>
                </div>

                <hr/>

                <div class="form-group">
                    <label class="form-label-sm" for="couponSelect">사용할 쿠폰</label>
                    <select id="couponSelect" class="form-control form-control-sm2" onchange="onChangeCouponSelect(this)">
                        <option value="">쿠폰 선택 안 함</option>
                    </select>
                    <div class="final-pay-text" id="couponDescText" style="margin-top:4px;">
                        사용 가능한 쿠폰이 있을 경우 여기에서 선택할 수 있습니다.
                    </div>
                </div>

                <div class="summary-row minus">
                    <span class="label">쿠폰 할인</span>
                    <span class="value" id="sumCouponUse">-0원</span>
                </div>

                <hr/>

                <div class="point-balance">
                    보유 포인트: <span id="pointBalance">0 P</span>
                </div>
                <div class="point-input-row">
                    <input type="text"
                           class="form-control form-control-sm2"
                           id="pointUseAmt"
                           placeholder="사용할 포인트"
                           oninput="onChangePointInput(this)"/>
                    <button type="button" class="btn btn-sm btn-outline-secondary" onclick="useMaxPoint()">
                        최대 사용
                    </button>
                </div>

                <div class="summary-row minus">
                    <span class="label">포인트 사용</span>
                    <span class="value" id="sumPointUse">-0원</span>
                </div>

                <hr/>

                <div class="summary-row pay">
                    <span class="label">최종 결제금액</span>
                    <span class="value" id="sumPay">0원</span>
                </div>

                <div class="final-pay-text" id="finalPayText">
                    포인트를 일부 사용하고, 나머지는 카드(토스)로 결제할 수 있습니다.
                </div>

                <button type="button" class="btn btn-primary btn-order-submit" onclick="submitOrderOrToss()">
                    결제하기
                </button>

                <button type="button" class="btn btn-outline-secondary btn-order-back" onclick="goBackToCart()">
                    장바구니로 돌아가기
                </button>
            </div>
        </div>
    </div>
</div>

<script>
    const CART_API_BASE = '/api/crt/cart';
    const POINT_API_BASE = '/api/plg/pointLedger';
    const COUPON_API_BASE = '/api/cop/couponUser';

    // 기존 포인트 전액결제 API
    const ORDER_API_BASE = '/api/ord/order';

    // ✅ 토스 준비 API (신규)
    const TOSS_API_BASE = '/api/pay/toss';

    const NO_IMAGE_URL = '/static/img/no-image-150.png';

    // ✅ 여기에 test_ck_... 넣어 (프론트엔 클라이언트키만)
    // ✅ test_sk_... 절대 넣지마.
    const TOSS_CLIENT_KEY = 'test_ck_vZnjEJeQVxz0d4g4q4KY8PmOoBN0';

    let gProductTotal = 0;
    let gShipTotal = 0;
    let gPointBalance = 0;  

    let gCouponList = [];
    let gSelectedCouponUserId = null;
    let gCouponUseAmt = 0;

    let gSelectedCartIds = [];
    let gFirstProductTitle = '';

    $(function () {
        loadCartForOrder();
        loadPointSummary();
        loadCouponListForOrder();
    });

    function fmtMoney(v) {
        if (v === null || v === undefined || v === '') return '0';
        const n = Number(v);
        if (isNaN(n)) return '0';
        return n.toLocaleString();
    }

    function escapeHtml(str) {
        if (str === null || str === undefined) return '';
        return String(str)
            .replace(/&/g, '&amp;')
            .replace(/</g, '&lt;')
            .replace(/>/g, '&gt;');
    }

    function getSelectedCartIdsFromUrl() {
        const params = new URLSearchParams(window.location.search);
        const idsStr = params.get('cartIds');
        if (!idsStr) return [];
        return idsStr
            .split(',')
            .map(function (s) { return s.trim(); })
            .filter(function (s) { return !!s; });
    }

    function loadCartForOrder() {
        gSelectedCartIds = getSelectedCartIdsFromUrl();

        const payload = {};
        if (gSelectedCartIds.length > 0) {
            payload.cartItemIds = gSelectedCartIds;
        }

        $.ajax({
            url: CART_API_BASE + '/selectCartView',
            type: 'post',
            contentType: 'application/json',
            dataType: 'json',
            data: JSON.stringify(payload),
            success: function (map) {
                if (!map) {
                    alert('주문 상품 조회 중 오류가 발생했습니다.');
                    return;
                }
                if (map.msg === 'LOGIN_REQUIRED') {
                    alert('로그인이 필요한 서비스입니다.');
                    location.href = '/mba/auth/login';
                    return;
                }
                if (map.msg !== '성공') {
                    alert(map.msg || '주문 상품 조회 중 오류가 발생했습니다.');
                    return;
                }
                const result = map.result || {};
                renderOrderItems(result);
            },
            error: function () {
                alert('주문 상품 조회 중 서버 오류가 발생했습니다.');
            }
        });
    }

    function renderOrderItems(result) {
        const list = result.items || [];
        const $wrap = $('#orderItemList');

        gProductTotal = 0;
        gShipTotal = 0;
        gFirstProductTitle = '';

        if (!list.length) {
            $wrap.html('<div class="order-items-empty">주문할 상품이 없습니다. 장바구니에서 상품을 담아 주세요.</div>');
        } else {
            let html = '';
            for (let i = 0; i < list.length; i++) {
                const r = list[i];

                const img = r.mainImgUrl || r.mainimgurl || NO_IMAGE_URL;

                const title = r.title || '';
                if (i === 0) {
                    gFirstProductTitle = title;
                }

                const brandNm = r.brandNm || r.brandnm || '';

                let unitPriceRaw = r.unitPrice;
                if (unitPriceRaw === null || unitPriceRaw === undefined || unitPriceRaw === '') unitPriceRaw = r.unitprice;
                if (unitPriceRaw === null || unitPriceRaw === undefined || unitPriceRaw === '') unitPriceRaw = r.salePrice;
                if (unitPriceRaw === null || unitPriceRaw === undefined || unitPriceRaw === '') unitPriceRaw = r.saleprice;

                let unitPrice = Number(unitPriceRaw || 0);
                if (isNaN(unitPrice)) unitPrice = 0;

                let shipFeeRaw = r.shipFee;
                if (shipFeeRaw === null || shipFeeRaw === undefined || shipFeeRaw === '') shipFeeRaw = r.shipfee;

                let shipFee = Number(shipFeeRaw || 0);
                if (isNaN(shipFee)) shipFee = 0;

                let qty = Number(r.qty || 1);
                if (!qty || isNaN(qty) || qty <= 0) qty = 1;

                const lineProductAmt = unitPrice * qty;
                const lineTotal = lineProductAmt + shipFee;

                gProductTotal += lineProductAmt;
                gShipTotal += shipFee;

                html += ''
                    + '<div class="order-item-row">'
                    + '  <div>'
                    + '    <img class="order-thumb" src="' + img + '"'
                    + '         onerror="this.onerror=null;this.src=\'' + NO_IMAGE_URL + '\';"/>'
                    + '  </div>'
                    + '  <div class="order-item-main">'
                    + '    <div class="order-item-title">' + escapeHtml(title) + '</div>'
                    + '    <div class="order-item-meta">' + (brandNm ? ('브랜드: ' + escapeHtml(brandNm)) : '') + '</div>'
                    + '    <div class="order-item-price">' + fmtMoney(unitPrice) + '원</div>'
                    + '    <div class="order-item-qty">수량 ' + qty + '개'
                    + (shipFee ? ' · 배송비 ' + fmtMoney(shipFee) + '원' : ' · 무료배송')
                    + ' · 합계 ' + fmtMoney(lineTotal) + '원</div>'
                    + '  </div>'
                    + '</div>';
            }
            $wrap.html(html);
        }

        // 서버 합계 우선
        let productTotalRes = Number(result.productTotal || result.producttotal || 0);
        if (isNaN(productTotalRes) || productTotalRes === 0) productTotalRes = gProductTotal;

        let shipTotalRes = Number(result.shipTotal || result.shiptotal || 0);
        if (isNaN(shipTotalRes) || shipTotalRes === 0) shipTotalRes = gShipTotal;

        gProductTotal = productTotalRes;
        gShipTotal = shipTotalRes;

        recalcPaymentSummary();
    }

    function loadPointSummary() {
        $.ajax({
            url: POINT_API_BASE + '/selectPointSummary',
            type: 'post',
            contentType: 'application/json',
            dataType: 'json',
            data: JSON.stringify({}),
            success: function (map) {
                if (!map) return;
                const res = map.result || map;

                let balRaw = res.pointBalance || res.pointbalance || res.balance || res.point || 0;
                let bal = Number(balRaw || 0);
                if (isNaN(bal) || bal < 0) bal = 0;

                gPointBalance = bal;
                $('#pointBalance').text(fmtMoney(gPointBalance) + ' P');

                recalcPaymentSummary();
            },
            error: function () {}
        });
    }

    function loadCouponListForOrder() {
        $.ajax({
            url: COUPON_API_BASE + '/selectMyAvailableCouponList',
            type: 'post',
            contentType: 'application/json',
            dataType: 'json',
            data: JSON.stringify({}),
            success: function (map) {
                if (!map) return;
                const list = (map && map.result) ? map.result : [];
                gCouponList = list || [];
                renderCouponSelect();
                recalcPaymentSummary();
            },
            error: function () {}
        });
    }

    function renderCouponSelect() {
        const $sel = $('#couponSelect');
        let html = '<option value="">쿠폰 선택 안 함</option>';

        for (let i = 0; i < gCouponList.length; i++) {
            const c = gCouponList[i];
            const couponUserId = c.couponUserId || c.couponuserid;

            const nm = c.couponNm || c.couponnm || '';
            const code = c.couponCd || c.couponcd || '';
            const type = (c.couponTypeCd || c.coupontypecd || '').toUpperCase();
            const rate = c.discountRate || c.discountrate || 0;
            const amt = c.discountAmt || c.discountamt || 0;

            let benefit = '';
            if (type === 'RATE') benefit = rate + '%';
            else benefit = fmtMoney(amt) + '원';

            const label = (nm || code || '쿠폰') + ' [' + benefit + ']';
            html += '<option value="' + couponUserId + '">' + label + '</option>';
        }

        $sel.html(html);
        updateCouponDescText();
    }

    function onChangeCouponSelect(sel) {
        const v = sel.value || '';
        gSelectedCouponUserId = v ? v : null;
        updateCouponDescText();
        recalcPaymentSummary();
    }

    function getSelectedCouponObj() {
        if (!gSelectedCouponUserId) return null;
        for (let i = 0; i < gCouponList.length; i++) {
            const c = gCouponList[i];
            const id = String(c.couponUserId || c.couponuserid || '');
            if (id && id === String(gSelectedCouponUserId)) return c;
        }
        return null;
    }

    function updateCouponDescText() {
        const $txt = $('#couponDescText');

        if (!gCouponList.length) {
            $txt.text('사용 가능한 쿠폰이 없습니다.');
            return;
        }
        if (!gSelectedCouponUserId) {
            $txt.text('쿠폰을 선택하지 않았습니다.');
            return;
        }

        const c = getSelectedCouponObj();
        if (!c) {
            $txt.text('쿠폰 정보를 찾을 수 없습니다.');
            return;
        }

        const nm = c.couponNm || c.couponnm || '';
        const code = c.couponCd || c.couponcd || '';
        const type = (c.couponTypeCd || c.coupontypecd || '').toUpperCase();
        const rate = c.discountRate || c.discountrate || 0;
        const amt = c.discountAmt || c.discountamt || 0;

        const benefit = (type === 'RATE') ? (rate + '%') : (fmtMoney(amt) + '원');
        const nameText = nm || code || '쿠폰';

        $txt.text('[' + benefit + '] ' + nameText + ' 쿠폰이 선택되었습니다.');
    }

    function computeCouponDiscount(baseOrderAmt) {
        if (!gSelectedCouponUserId) return 0;

        const c = getSelectedCouponObj();
        if (!c) return 0;

        if (!baseOrderAmt || isNaN(baseOrderAmt) || baseOrderAmt <= 0) return 0;

        const type = (c.couponTypeCd || c.coupontypecd || '').toUpperCase();
        const rateRaw = c.discountRate || c.discountrate || 0;
        const amtRaw = c.discountAmt || c.discountamt || 0;

        let discount = 0;

        if (type === 'RATE') {
            let rate = Number(rateRaw || 0);
            if (isNaN(rate) || rate <= 0) rate = 0;
            discount = Math.floor(baseOrderAmt * rate / 100.0);
        } else {
            let amt = Number(amtRaw || 0);
            if (isNaN(amt) || amt <= 0) amt = 0;
            discount = amt;
        }

        if (discount < 0) discount = 0;
        if (discount > baseOrderAmt) discount = baseOrderAmt;

        return discount;
    }

    function onChangePointInput(el) {
        const raw = (el.value || '').replace(/,/g, '').replace(/\s+/g, '');
        let n = Number(raw || 0);
        if (!n || isNaN(n) || n < 0) n = 0;

        const baseOrderAmt = gProductTotal + gShipTotal;
        const couponDiscount = computeCouponDiscount(baseOrderAmt);
        const orderAmt = baseOrderAmt - couponDiscount;

        if (n > gPointBalance) n = gPointBalance;
        if (n > orderAmt) n = orderAmt;

        el.value = n ? n.toLocaleString() : '';
        recalcPaymentSummary();
    }

    function useMaxPoint() {
        const baseOrderAmt = gProductTotal + gShipTotal;
        const couponDiscount = computeCouponDiscount(baseOrderAmt);
        const orderAmt = baseOrderAmt - couponDiscount;

        let use = gPointBalance;
        if (use > orderAmt) use = orderAmt;

        $('#pointUseAmt').val(use ? use.toLocaleString() : '');
        recalcPaymentSummary();
    }

    function getPointUseValue(orderAmt) {
        const v = ($('#pointUseAmt').val() || '').replace(/,/g, '').trim();
        let n = Number(v || 0);
        if (!n || isNaN(n) || n < 0) n = 0;

        if (n > gPointBalance) n = gPointBalance;
        if (n > orderAmt) n = orderAmt;

        return n;
    }

    function recalcPaymentSummary() {
        const baseOrderAmt = gProductTotal + gShipTotal;
        const couponDiscount = computeCouponDiscount(baseOrderAmt);
        gCouponUseAmt = couponDiscount;

        const orderAmt = baseOrderAmt - couponDiscount;
        const pointUse = getPointUseValue(orderAmt);
        const payAmt = orderAmt - pointUse;

        $('#sumProduct').text(fmtMoney(gProductTotal) + '원');
        $('#sumShip').text(fmtMoney(gShipTotal) + '원');
        $('#sumOrder').text(fmtMoney(baseOrderAmt) + '원');
        $('#sumCouponUse').text('-' + fmtMoney(couponDiscount) + '원');
        $('#sumPointUse').text('-' + fmtMoney(pointUse) + '원');
        $('#sumPay').text(fmtMoney(payAmt) + '원');

        const $msg = $('#finalPayText');

        if (baseOrderAmt <= 0) {
            $msg.text('주문할 상품을 담은 후 결제를 진행해 주세요.');
            return;
        }

        if (payAmt === 0) {
            $msg.text('포인트 전액 결제됩니다.');
            return;
        }

        $msg.text('포인트를 일부 사용하고, 나머지 ' + fmtMoney(payAmt) + '원은 카드(토스)로 결제됩니다.');
    }

    function goBackToCart() {
        location.href = '/crt/cart/cartList';
    }

    // =========================
    // 결제 실행(포인트=기존 / 토스=신규)
    // =========================
    function submitOrderOrToss() {
        if (!gSelectedCartIds || gSelectedCartIds.length === 0) {
            alert('잘못된 접근입니다.\n장바구니에서 주문할 상품을 선택한 뒤 주문/결제를 진행해 주세요.');
            goBackToCart();
            return;
        }

        if (gProductTotal <= 0 && gShipTotal <= 0) {
            alert('주문할 상품이 없습니다. 장바구니에서 상품을 담아 주세요.');
            return;
        }

        const receiverNm = $('#receiverNm').val().trim();
        const receiverPhone = $('#receiverPhone').val().trim();
        const addr1 = $('#addr1').val().trim();

        if (!receiverNm) { alert('받는 사람 이름을 입력하세요.'); $('#receiverNm').focus(); return; }
        if (!receiverPhone) { alert('연락처를 입력하세요.'); $('#receiverPhone').focus(); return; }
        if (!addr1) { alert('기본 주소를 입력하세요.'); $('#addr1').focus(); return; }

        const baseOrderAmt = gProductTotal + gShipTotal;
        const couponDiscount = computeCouponDiscount(baseOrderAmt);
        const orderAmt = baseOrderAmt - couponDiscount;
        const pointUse = getPointUseValue(orderAmt);
        const payAmt = orderAmt - pointUse;

        // 적립 포인트 예시(상품금액의 1%)
        const pointSave = Math.floor(gProductTotal * 0.01);

        if (payAmt === 0) {
            // =========================
            // A) 포인트 전액 결제: 기존 로직 그대로
            // =========================
            submitPointOnlyOrder(baseOrderAmt, orderAmt, couponDiscount, pointUse, pointSave, payAmt);
            return;
        }

        // =========================
        // B) 토스 결제창(B안): 주문(대기) 생성 → 결제창 띄우기
        // =========================
        prepareTossOrderAndOpenPay(baseOrderAmt, orderAmt, couponDiscount, pointUse, pointSave, payAmt);
    }

    function submitPointOnlyOrder(baseOrderAmt, orderAmt, couponDiscount, pointUse, pointSave, payAmt) {
        const payload = {
            orderNo: makeOrderNo(),
            orderStatusCd: 'ORDER_DONE',
            payStatusCd: 'PAY_DONE',
            payMethodCd: 'POINT',

            totalProductAmt: gProductTotal,
            totalDiscountAmt: 0,
            deliveryAmt: gShipTotal,
            orderAmt: orderAmt,
            pointUseAmt: pointUse,
            pointSaveAmt: pointSave,
            couponUseAmt: couponDiscount,
            payAmt: payAmt,

            receiverNm: $('#receiverNm').val().trim(),
            receiverPhone: $('#receiverPhone').val().trim(),
            zipCode: $('#zipCode').val().trim(),
            addr1: $('#addr1').val().trim(),
            addr2: $('#addr2').val().trim(),
            deliveryMemo: $('#deliveryMemo').val().trim(),

            useAt: 'Y',
            cartItemIds: gSelectedCartIds
        };

        if (gSelectedCouponUserId) {
            payload.couponUserId = Number(gSelectedCouponUserId);
        }

        if (!confirm('포인트 전액 결제(0원)로 주문을 진행합니다. 계속?')) return;

        $.ajax({
            url: ORDER_API_BASE + '/insertOrder',
            type: 'post',
            contentType: 'application/json',
            dataType: 'json',
            data: JSON.stringify(payload),
            success: function (map) {
                if (!map) { alert('주문 저장 중 오류가 발생했습니다.'); return; }
                if (map.msg === 'LOGIN_REQUIRED') { alert('로그인이 필요한 서비스입니다.'); location.href = '/mba/auth/login'; return; }
                if (map.msg !== '등록 성공' && map.msg !== '성공') { alert(map.msg || '주문 저장 중 오류가 발생했습니다.'); return; }

                const q =
                    '?orderNo=' + encodeURIComponent(payload.orderNo) +
                    '&totalAmt=' + encodeURIComponent(baseOrderAmt) +
                    '&payAmt=' + encodeURIComponent(payAmt) +
                    '&pointUseAmt=' + encodeURIComponent(pointUse) +
                    '&couponUseAmt=' + encodeURIComponent(couponDiscount);

                location.href = '/pay/payment/paymentModify' + q;
            },
            error: function () { alert('주문 저장 중 서버 오류가 발생했습니다.'); }
        });
    }

    function prepareTossOrderAndOpenPay(baseOrderAmt, orderAmt, couponDiscount, pointUse, pointSave, payAmt) {
        if (!window.TossPayments) {
            alert('토스 SDK 로딩 실패');
            return;
        }
        if (!TOSS_CLIENT_KEY || TOSS_CLIENT_KEY.indexOf('test_ck_') !== 0) {
            alert('TOSS_CLIENT_KEY(test_ck_...)를 세팅해.');
            return;
        }

        const orderName = buildOrderNameForToss();

        const payload = {
            orderName: orderName,
            totalProductAmt: gProductTotal,
            deliveryAmt: gShipTotal,
            orderAmt: orderAmt,
            pointUseAmt: pointUse,
            pointSaveAmt: pointSave,
            couponUseAmt: couponDiscount,
            payAmt: payAmt,

            receiverNm: $('#receiverNm').val().trim(),
            receiverPhone: $('#receiverPhone').val().trim(),
            zipCode: $('#zipCode').val().trim(),
            addr1: $('#addr1').val().trim(),
            addr2: $('#addr2').val().trim(),
            deliveryMemo: $('#deliveryMemo').val().trim(),

            cartItemIds: gSelectedCartIds
        };

        if (gSelectedCouponUserId) {
            payload.couponUserId = Number(gSelectedCouponUserId);
        }

        $.ajax({
            url: TOSS_API_BASE + '/prepare',
            type: 'post',
            contentType: 'application/json',
            dataType: 'json',
            data: JSON.stringify(payload),
            success: function (map) {
                if (!map || map.ok !== true) {
                    alert((map && map.msg) ? map.msg : '토스 결제 준비 실패');
                    return;
                }

                const res = map.result || {};
                const orderNo = res.orderNo || '';
                const amount = Number(res.amount || 0);
                const customerKey = res.customerKey || '';

                if (!orderNo || amount <= 0 || !customerKey) {
                    alert('토스 결제 준비 응답이 비정상입니다.');
                    return;
                }

                openTossPayWindow(orderNo, orderName, amount, customerKey);
            },
            error: function () {
                alert('토스 결제 준비 API 호출 실패');
            }
        });
    }

    function openTossPayWindow(orderNo, orderName, amount, customerKey) {
        const tossPayments = TossPayments(TOSS_CLIENT_KEY);
        const payment = tossPayments.payment({ customerKey: customerKey });

        const successUrl = window.location.origin + '/pay/toss/success';
        const failUrl = window.location.origin + '/pay/toss/fail';

        payment.requestPayment({
            method: 'CARD',
            amount: {
                currency: 'KRW',
                value: amount
            },
            orderId: orderNo,
            orderName: orderName,
            successUrl: successUrl,
            failUrl: failUrl
        }).catch(function (e) {
            alert('결제창 호출 실패: ' + (e && e.message ? e.message : 'unknown'));
        });
    }

    function buildOrderNameForToss() {
        if (gFirstProductTitle && gSelectedCartIds && gSelectedCartIds.length > 1) {
            return gFirstProductTitle + ' 외 ' + (gSelectedCartIds.length - 1) + '건';
        }
        if (gFirstProductTitle) return gFirstProductTitle;
        return 'CONNECT 주문 결제';
    }

    function makeOrderNo() {
        const d = new Date();
        const pad = function (n) { return n < 10 ? '0' + n : '' + n; };
        const y = d.getFullYear();
        const m = pad(d.getMonth() + 1);
        const day = pad(d.getDate());
        const h = pad(d.getHours());
        const mi = pad(d.getMinutes());
        const s = pad(d.getSeconds());
        const rand = Math.floor(Math.random() * 900) + 100;
        return 'O' + y + m + day + h + mi + s + rand;
    }
</script>
