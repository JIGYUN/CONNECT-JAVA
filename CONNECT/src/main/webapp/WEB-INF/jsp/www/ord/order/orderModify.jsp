<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>

<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.2/dist/css/bootstrap.min.css"/>
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>

<style>
    :root{
        --bg:#f7f8fb; --card:#ffffff; --line:#e5e7eb; --text:#0f172a; --muted:#6b7280;
        --accent:#2563eb; --accent-soft:#dbeafe; --danger:#dc2626; --success:#16a34a;
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
        <!-- LEFT: 배송지 + 주문 상품 -->
        <div class="order-left">
            <!-- 배송지 정보 -->
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

            <!-- 주문 상품 -->
            <div class="card-box">
                <div class="card-title-sm">주문 상품</div>
                <div id="orderItemList">
                    <!-- 장바구니 기반 주문 상품 목록 -->
                </div>
            </div>
        </div>

        <!-- RIGHT: 결제 정보 -->
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

                <div class="point-balance">
                    보유 포인트: <span id="pointBalance">0 P</span>
                </div>
                <div class="point-input-row">
                    <input type="text"
                           class="form-control form-control-sm2"
                           id="pointUseAmt"
                           placeholder="사용할 포인트"
                           oninput="onChangePointInput(this)"/>
                    <button type="button"
                            class="btn btn-sm btn-outline-secondary"
                            onclick="useMaxPoint()">
                        전액 사용
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
                    현재는 <strong>포인트 전액 결제</strong>만 가능합니다. 주문 금액만큼 포인트를 사용해야 결제가 진행됩니다.
                </div>

                <button type="button"
                        class="btn btn-primary btn-order-submit"
                        onclick="submitOrder()">
                    결제하기
                </button>
                <button type="button"
                        class="btn btn-outline-secondary btn-order-back"
                        onclick="goBackToCart()">
                    장바구니로 돌아가기
                </button>
            </div>
        </div>
    </div>
</div>

<script>
    const CART_API_BASE = '/api/crt/cart';
    const ORDER_API_BASE = '/api/ord/order';
    const POINT_API_BASE = '/api/plg/pointLedger'; // 보유 포인트 요약용 (없으면 에러 없이 무시)

    const NO_IMAGE_URL = '/static/img/no-image-150.png';

    let gProductTotal = 0;
    let gShipTotal = 0;
    let gPointBalance = 0;

    // 선택된 장바구니 CART_ITEM_ID 목록 (URL ?cartIds=값 기준)
    let gSelectedCartIds = [];

    $(function () {
        loadCartForOrder();
        loadPointSummary();
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

    // URL 에서 cartIds 읽기: ?cartIds=1,3,5
    function getSelectedCartIdsFromUrl() {
        const params = new URLSearchParams(window.location.search);
        const idsStr = params.get('cartIds');
        if (!idsStr) return [];
        return idsStr
            .split(',')
            .map(function (s) { return s.trim(); })
            .filter(function (s) { return !!s; });
    }

    // 1) 장바구니 기반 주문 상품 조회
    function loadCartForOrder() {
        // 선택 주문이면 [id...], 전체 주문이면 []
        gSelectedCartIds = getSelectedCartIdsFromUrl();

        const payload = {};
        if (gSelectedCartIds.length > 0) {
            // 서버에서 cartItemIds로 받도록 맞춘다.
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
                    location.href = '/usr/login';
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

        if (!list.length) {
            $wrap.html('<div class="order-items-empty">주문할 상품이 없습니다. 장바구니에서 상품을 담아 주세요.</div>');
        } else {
            let html = '';
            for (let i = 0; i < list.length; i++) {
                const r = list[i];

                const img =
                    r.mainImgUrl || r.mainimgurl || NO_IMAGE_URL;

                const title = r.title || '';
                const brandNm = r.brandNm || r.brandnm || '';

                let unitPriceRaw = r.unitPrice;
                if (unitPriceRaw === null || unitPriceRaw === undefined || unitPriceRaw === '') {
                    unitPriceRaw = r.unitprice;
                }
                if (unitPriceRaw === null || unitPriceRaw === undefined || unitPriceRaw === '') {
                    unitPriceRaw = r.salePrice;
                }
                if (unitPriceRaw === null || unitPriceRaw === undefined || unitPriceRaw === '') {
                    unitPriceRaw = r.saleprice;
                }
                let unitPrice = Number(unitPriceRaw || 0);
                if (isNaN(unitPrice)) unitPrice = 0;

                let shipFeeRaw = r.shipFee;
                if (shipFeeRaw === null || shipFeeRaw === undefined || shipFeeRaw === '') {
                    shipFeeRaw = r.shipfee;
                }
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

        // 백엔드 합계가 있으면 우선 사용
        let productTotalRes = Number(result.productTotal || result.producttotal || 0);
        if (isNaN(productTotalRes) || productTotalRes === 0) {
            productTotalRes = gProductTotal;
        }
        let shipTotalRes = Number(result.shipTotal || result.shiptotal || 0);
        if (isNaN(shipTotalRes) || shipTotalRes === 0) {
            shipTotalRes = gShipTotal;
        }

        gProductTotal = productTotalRes;
        gShipTotal = shipTotalRes;

        recalcPaymentSummary();
    }

    // 2) 포인트 잔액 조회 (있으면 쓰고, 없으면 0으로 둔다)
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
                let balRaw =
                    res.pointBalance || res.pointbalance ||
                    res.balance || res.point || 0;
                let bal = Number(balRaw || 0);
                if (isNaN(bal) || bal < 0) bal = 0;
                gPointBalance = bal;
                $('#pointBalance').text(fmtMoney(gPointBalance) + ' P');
                recalcPaymentSummary();
            },
            error: function () {
                // 포인트 API 아직 없으면 조용히 무시
            }
        });
    }

    // 3) 포인트 입력 변경 시
    function onChangePointInput(el) {
        const raw = (el.value || '').replace(/,/g, '').replace(/\s+/g, '');
        let n = Number(raw || 0);
        if (!n || isNaN(n) || n < 0) n = 0;

        const orderAmt = gProductTotal + gShipTotal;
        if (n > gPointBalance) n = gPointBalance;
        if (n > orderAmt) n = orderAmt;

        el.value = n ? n.toLocaleString() : '';
        recalcPaymentSummary();
    }

    function useMaxPoint() {
        const orderAmt = gProductTotal + gShipTotal;
        let use = gPointBalance;
        if (use > orderAmt) use = orderAmt;
        $('#pointUseAmt').val(use ? use.toLocaleString() : '');
        recalcPaymentSummary();
    }

    function getPointUseValue() {
        const v = ($('#pointUseAmt').val() || '').replace(/,/g, '').trim();
        let n = Number(v || 0);
        if (!n || isNaN(n) || n < 0) n = 0;
        const orderAmt = gProductTotal + gShipTotal;
        if (n > gPointBalance) n = gPointBalance;
        if (n > orderAmt) n = orderAmt;
        return n;
    }

    function recalcPaymentSummary() {
        const orderAmt = gProductTotal + gShipTotal;
        const pointUse = getPointUseValue();
        const payAmt = orderAmt - pointUse;

        $('#sumProduct').text(fmtMoney(gProductTotal) + '원');
        $('#sumShip').text(fmtMoney(gShipTotal) + '원');
        $('#sumOrder').text(fmtMoney(orderAmt) + '원');
        $('#sumPointUse').text('-' + fmtMoney(pointUse) + '원');
        $('#sumPay').text(fmtMoney(payAmt) + '원');

        // 안내 문구 동적 변경
        const $msg = $('#finalPayText');
        if (orderAmt <= 0) {
            $msg.text('주문할 상품을 담은 후 결제를 진행해 주세요.');
            return;
        }

        if (gPointBalance < orderAmt) {
            $msg.text(
                '보유 포인트(' + fmtMoney(gPointBalance) + ' P)가 주문 금액(' +
                fmtMoney(orderAmt) + '원)보다 적어 결제를 진행할 수 없습니다.'
            );
        } else if (payAmt > 0) {
            $msg.text('현재는 포인트 전액 결제만 가능합니다. 포인트 사용 금액을 주문 금액과 동일하게 맞춰 주세요.');
        } else {
            $msg.text('결제 버튼 클릭 시 주문이 저장되고, 결제완료 화면으로 이동합니다.');
        }
    }

    function goBackToCart() {
        location.href = '/crt/cart/cartList';
    }

    // 4) 주문 저장 + 결제완료 화면으로 이동
    function submitOrder() {
        // 선택된 장바구니 항목 없이 직접 접근한 경우 방어
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

        if (!receiverNm) {
            alert('받는 사람 이름을 입력하세요.');
            $('#receiverNm').focus();
            return;
        }
        if (!receiverPhone) {
            alert('연락처를 입력하세요.');
            $('#receiverPhone').focus();
            return;
        }
        if (!addr1) {
            alert('기본 주소를 입력하세요.');
            $('#addr1').focus();
            return;
        }

        const orderAmt = gProductTotal + gShipTotal;
        const pointUse = getPointUseValue();
        const payAmt = orderAmt - pointUse;
        const pointSave = Math.floor(gProductTotal * 0.01); // 예시: 상품금액의 1%

        // ▼ 핵심: 포인트가 부족하면 결제 자체 불가
        if (gPointBalance < orderAmt) {
            alert(
                '보유 포인트가 부족하여 결제를 진행할 수 없습니다.\n\n' +
                '주문 금액: ' + fmtMoney(orderAmt) + '원\n' +
                '보유 포인트: ' + fmtMoney(gPointBalance) + ' P'
            );
            return;
        }

        // ▼ 포인트 전액 사용이 아니면 결제 불가 (카드 결제 미지원)
        if (payAmt !== 0) {
            alert(
                '현재는 포인트 전액 결제만 가능합니다.\n\n' +
                '주문 금액 전체를 포인트로 결제해 주세요.'
            );
            $('#pointUseAmt').focus();
            return;
        }

        const orderNo = makeOrderNo();

        const payload = {
            orderNo: orderNo,
            // 서버에서 userId는 세션 기반으로 처리(컬럼이 NOT NULL이면 컨트롤러에서 보완)
            orderStatusCd: 'ORDER_DONE',
            payStatusCd: 'PAY_DONE',
            payMethodCd: 'POINT',   // 전액 포인트 결제만 허용

            totalProductAmt: gProductTotal,
            totalDiscountAmt: 0,
            deliveryAmt: gShipTotal,
            orderAmt: orderAmt,
            pointUseAmt: pointUse,
            pointSaveAmt: pointSave,
            couponUseAmt: 0,
            payAmt: payAmt,        // 0 이어야 함

            receiverNm: receiverNm,
            receiverPhone: receiverPhone,
            zipCode: $('#zipCode').val().trim(),
            addr1: addr1,
            addr2: $('#addr2').val().trim(),
            deliveryMemo: $('#deliveryMemo').val().trim(),

            useAt: 'Y',

            // 선택한 장바구니 항목들
            cartItemIds: gSelectedCartIds
        };

        if (!confirm('주문을 진행하시겠습니까?\n\n결제 방식: 포인트 전액 결제\n결제 금액: ' + fmtMoney(orderAmt) + '원')) {
            return;
        }

        $.ajax({
            url: ORDER_API_BASE + '/insertOrder',
            type: 'post',
            contentType: 'application/json',
            dataType: 'json',
            data: JSON.stringify(payload),
            success: function (map) {
                if (!map) {
                    alert('주문 저장 중 오류가 발생했습니다.');
                    return;
                }
                if (map.msg === 'LOGIN_REQUIRED') {
                    alert('로그인이 필요한 서비스입니다.');
                    location.href = '/usr/login';
                    return;
                }
                if (map.msg !== '등록 성공' && map.msg !== '성공') {
                    alert(map.msg || '주문 저장 중 오류가 발생했습니다.');
                    return;
                }

                const q =
                    '?orderNo=' + encodeURIComponent(orderNo) +
                    '&totalAmt=' + encodeURIComponent(orderAmt) +
                    '&payAmt=' + encodeURIComponent(payAmt) +
                    '&pointUseAmt=' + encodeURIComponent(pointUse);

                location.href = '/pay/payment/paymentModify' + q;
            },
            error: function () {
                alert('주문 저장 중 서버 오류가 발생했습니다.');
            }
        });
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
        const rand = Math.floor(Math.random() * 900) + 100; // 3자리 랜덤
        return 'O' + y + m + day + h + mi + s + rand;
    }
</script>
