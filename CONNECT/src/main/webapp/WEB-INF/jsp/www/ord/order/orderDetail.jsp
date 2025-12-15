<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<section class="container py-4">
    <div class="d-flex justify-content-between align-items-center mb-3">
        <h2 class="mb-0">주문 상세</h2>
        <div>
            <button type="button" class="btn btn-outline-secondary btn-sm" onclick="goToOrderList()">
                목록으로
            </button>
            <!-- 주문취소(결제/포인트 포함) 버튼 -->
            <button type="button"
                    class="btn btn-danger btn-sm ml-1"
                    id="btn-cancel-order">
                주문취소
            </button>
        </div>
    </div>

    <!-- 오류/안내 메시지 -->
    <div id="orderAlert" class="alert alert-warning d-none" role="alert"></div>

    <!-- 상단: 주문 정보 + 배송지 정보 -->
    <div class="row">
        <div class="col-lg-7 mb-3">
            <div class="card h-100">
                <div class="card-header">
                    주문 정보
                </div>
                <div class="card-body">
                    <dl class="row mb-1">
                        <dt class="col-sm-4">주문번호</dt>
                        <dd class="col-sm-8" id="field-orderNo"></dd>

                        <dt class="col-sm-4">주문일시</dt>
                        <dd class="col-sm-8" id="field-orderDt"></dd>

                        <dt class="col-sm-4">주문 상태</dt>
                        <dd class="col-sm-8" id="field-orderStatus"></dd>

                        <dt class="col-sm-4">결제 상태</dt>
                        <dd class="col-sm-8" id="field-payStatus"></dd>

                        <dt class="col-sm-4">결제 수단</dt>
                        <dd class="col-sm-8" id="field-payMethod"></dd>
                    </dl>

                    <hr/>

                    <dl class="row mb-1">
                        <dt class="col-sm-4">상품 금액 합계</dt>
                        <dd class="col-sm-8" id="field-totalProductAmt"></dd>

                        <dt class="col-sm-4">할인 금액 합계</dt>
                        <dd class="col-sm-8" id="field-totalDiscountAmt"></dd>

                        <dt class="col-sm-4">배송비</dt>
                        <dd class="col-sm-8" id="field-deliveryAmt"></dd>

                        <dt class="col-sm-4">주문 금액</dt>
                        <dd class="col-sm-8" id="field-orderAmt"></dd>

                        <dt class="col-sm-4">포인트 사용</dt>
                        <dd class="col-sm-8" id="field-pointUseAmt"></dd>

                        <dt class="col-sm-4">포인트 적립</dt>
                        <dd class="col-sm-8" id="field-pointSaveAmt"></dd>

                        <dt class="col-sm-4">쿠폰 사용</dt>
                        <dd class="col-sm-8" id="field-couponUseAmt"></dd>

                        <dt class="col-sm-4">최종 결제 금액</dt>
                        <dd class="col-sm-8 font-weight-bold" id="field-payAmt"></dd>
                    </dl>
                </div>
            </div>
        </div>

        <div class="col-lg-5 mb-3">
            <div class="card h-100">
                <div class="card-header">
                    배송지 정보
                </div>
                <div class="card-body">
                    <dl class="row mb-1">
                        <dt class="col-sm-4">받는 사람</dt>
                        <dd class="col-sm-8" id="field-receiverNm"></dd>

                        <dt class="col-sm-4">연락처</dt>
                        <dd class="col-sm-8" id="field-receiverPhone"></dd>

                        <dt class="col-sm-4">우편번호</dt>
                        <dd class="col-sm-8" id="field-zipCode"></dd>

                        <dt class="col-sm-4">주소</dt>
                        <dd class="col-sm-8" id="field-addr"></dd>

                        <dt class="col-sm-4">배송 메모</dt>
                        <dd class="col-sm-8" id="field-deliveryMemo"></dd>
                    </dl>
                </div>
            </div>
        </div>
    </div>

    <!-- 주문 상품 목록 (이미지 포함) -->
    <div class="card mb-3">
        <div class="card-header">
            주문 상품
        </div>
        <div class="card-body p-0">
            <div class="table-responsive mb-0">
                <table class="table table-sm mb-0">
                    <thead class="thead-light">
                        <tr>
                            <th style="width:60px; text-align:center;">No</th>
                            <th style="width:80px; text-align:center;">이미지</th>
                            <th>상품명</th>
                            <th style="width:110px; text-align:right;">단가</th>
                            <th style="width:80px; text-align:right;">수량</th>
                            <th style="width:110px; text-align:right;">배송비</th>
                            <th style="width:120px; text-align:right;">합계</th>
                        </tr>
                    </thead>
                    <tbody id="orderItemBody"></tbody>
                </table>
            </div>
        </div>
    </div>

    <!-- 결제 내역 -->
    <div class="card mb-3">
        <div class="card-header">
            결제 내역
        </div>
        <div class="card-body p-0">
            <div class="table-responsive mb-0">
                <table class="table table-sm mb-0">
                    <thead class="thead-light">
                        <tr>
                            <th style="width:60px; text-align:center;">No</th>
                            <th style="width:200px;">결제일시</th>
                            <th style="width:140px; text-align:right;">결제 금액</th>
                            <th style="width:140px;">결제수단</th>
                            <th style="width:140px;">결제상태</th>
                            <th>비고</th>
                        </tr>
                    </thead>
                    <tbody id="paymentBody"></tbody>
                </table>
            </div>
        </div>
    </div>
</section>

<script>
    const ORDER_API_BASE   = '/api/ord/order';
    const ORDER_ID_PARAM   = 'orderIdx';
    const NO_IMAGE_URL     = '/static/img/no-image-150.png';

    // 현재 주문 상태 전역
    let CURRENT_ORDER_ID     = null;
    let CURRENT_ORDER_STATUS = '';
    let CURRENT_PAY_STATUS   = '';

    $(function () {
        const orderId = getOrderId();
        if (!orderId) {
            showAlert('잘못된 접근입니다. 주문 식별자가 없습니다.');
            return;
        }
        CURRENT_ORDER_ID = orderId;

        // 주문취소 버튼 클릭 바인딩
        $('#btn-cancel-order').on('click', function () {
            onClickCancelOrder();
        });

        loadOrderFullDetail(orderId);
    });

    // ===================== 공통 유틸 =====================

    function getOrderId() {
        // URL 쿼리에서만 읽는다 (JSP 태그 사용 X)
        try {
            const u = new URL(location.href);
            return u.searchParams.get(ORDER_ID_PARAM);
        } catch (e) {
            return null;
        }
    }

    function showAlert(msg) {
        const $alert = $('#orderAlert');
        $alert.text(msg || '');
        if (msg) {
            $alert.removeClass('d-none').addClass('show');
        } else {
            $alert.addClass('d-none').removeClass('show');
        }
    }

    function escapeHtml(s) {
        return String(s || '').replace(/[&<>"']/g, function (m) {
            return { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', '\'': '&#39;' }[m];
        });
    }

    function unwrapVal(raw) {
        if (raw === null || raw === undefined) {
            return '';
        }
        if (typeof raw === 'object') {
            if (Object.prototype.hasOwnProperty.call(raw, 'value') && raw.value != null) {
                return String(raw.value);
            }
            const keys = Object.keys(raw);
            if (keys.length === 1 && raw[keys[0]] != null) {
                return String(raw[keys[0]]);
            }
            return JSON.stringify(raw);
        }
        return String(raw);
    }

    function getFieldVal(row, logicalName) {
        if (!row) return '';
        const lower = logicalName.toLowerCase();
        const snake = logicalName.replace(/([A-Z])/g, function (m) {
            return '_' + m.toLowerCase();
        });
        const cands = [logicalName, logicalName.toLowerCase(), snake, snake.toUpperCase()];
        for (let i = 0; i < cands.length; i++) {
            const k = cands[i];
            if (Object.prototype.hasOwnProperty.call(row, k) && row[k] != null) {
                return unwrapVal(row[k]);
            }
        }
        for (const k in row) {
            if (!Object.prototype.hasOwnProperty.call(row, k)) continue;
            if (k.toLowerCase() === lower && row[k] != null) {
                return unwrapVal(row[k]);
            }
        }
        return '';
    }

    function formatDateTime(raw) {
        const v = unwrapVal(raw);
        return v || '';
    }

    function formatNumber(val) {
        const v = unwrapVal(val);
        if (!v) return '0';
        const num = Number(v);
        if (Number.isNaN(num)) return v;
        return num.toLocaleString('ko-KR');
    }

    function formatMoney(val) {
        return formatNumber(val) + '원';
    }

    function mapOrderStatusLabel(cd) {
        switch (cd) {
            case 'ORDER_DONE':   return '주문완료';
            case 'ORDER_WAIT':   return '주문대기';
            case 'ORDER_CANCEL': return '주문취소';
            default:             return cd || '';
        }
    }

    function mapPayStatusLabel(cd) {
        switch (cd) {
            case 'PAY_DONE':   return '결제완료';
            case 'PAY_WAIT':   return '결제대기';
            case 'PAY_CANCEL': return '결제취소';
            default:           return cd || '';
        }
    }

    function mapPayMethodLabel(cd) {
        switch (cd) {
            case 'CARD':  return '카드';
            case 'POINT': return '포인트';
            case 'BANK':  return '무통장입금';
            default:      return cd || '';
        }
    }

    function renderStatusBadge(cd, label) {
        const text = label || cd || '';
        if (!text) return '';
        let cls = 'badge-secondary';
        switch (cd) {
            case 'PAY_WAIT':
            case 'ORDER_WAIT':
                cls = 'badge-warning';
                break;
            case 'PAY_DONE':
            case 'ORDER_DONE':
                cls = 'badge-success';
                break;
            case 'PAY_CANCEL':
            case 'ORDER_CANCEL':
                cls = 'badge-danger';
                break;
            case 'DELIVERY':
            case 'DELIVERY_READY':
                cls = 'badge-info';
                break;
            default:
                cls = 'badge-secondary';
        }
        return '<span class="badge ' + cls + '">' + escapeHtml(text) + '</span>';
    }

    // 주문취소 버튼 상태 갱신
    function updateCancelButton() {
        const $btn = $('#btn-cancel-order');

        if (!CURRENT_ORDER_ID) {
            $btn.prop('disabled', true).addClass('d-none');
            return;
        }

        // 이미 주문취소 or 결제취소 상태면 버튼 비활성화
        if (CURRENT_ORDER_STATUS === 'ORDER_CANCEL' || CURRENT_PAY_STATUS === 'PAY_CANCEL') {
            $btn.prop('disabled', true)
                .removeClass('d-none')
                .text('취소 완료');
            return;
        }

        // 기본: 노출 + 활성화
        $btn.prop('disabled', false)
            .removeClass('d-none')
            .text('주문취소');
    }

    // ===================== 주문취소(결제/포인트 포함) 호출 =====================

    function onClickCancelOrder() {
        if (!CURRENT_ORDER_ID) {
            alert('주문 식별자가 없습니다.');
            return;
        }

        // 상태 체크: 이미 취소인 경우 방어
        if (CURRENT_ORDER_STATUS === 'ORDER_CANCEL') {
            alert('이미 취소된 주문입니다.');
            return;
        }

        const confirmMsg =
            '해당 주문을 취소하시겠습니까?\n' +
            '결제취소 및 포인트 환불(사용분 복구, 적립분 취소)이 함께 처리됩니다.';

        if (!confirm(confirmMsg)) {
            return;
        }

        const payload = {
            orderId: CURRENT_ORDER_ID,
            orderIdx: CURRENT_ORDER_ID
        };

        const $btn = $('#btn-cancel-order');
        $btn.prop('disabled', true).text('취소 처리중...');

        $.ajax({
            url: ORDER_API_BASE + '/cancelOrder', // 서버에서 주문/결제/포인트 취소까지 처리하는 API
            type: 'post',
            contentType: 'application/json',
            dataType: 'json',
            data: JSON.stringify(payload),
            success: function (map) {
                const ok  = map && map.ok !== false;
                const msg = (map && map.msg) || (ok ? '주문이 취소되었습니다.' : '주문 취소에 실패했습니다.');

                alert(msg);

                if (ok) {
                    // 다시 상세정보 로드해서 상태/버튼 갱신
                    loadOrderFullDetail(CURRENT_ORDER_ID);
                } else {
                    $btn.prop('disabled', false).text('주문취소');
                }
            },
            error: function () {
                alert('주문 취소 중 서버 오류가 발생했습니다.');
                $btn.prop('disabled', false).text('주문취소');
            }
        });
    }

    // ===================== API 호출 =====================

    function loadOrderFullDetail(orderId) {
        const payload = {
            orderId: orderId,
            orderIdx: orderId
        };

        $.ajax({
            url: ORDER_API_BASE + '/selectOrderFullDetail',
            type: 'post',
            contentType: 'application/json',
            dataType: 'json',
            data: JSON.stringify(payload),
            success: function (map) {
                if (!map || map.ok === false) {
                    loadOrderDetailOnly(orderId);
                    return;
                }
                if (map.msg === 'LOGIN_REQUIRED') {
                    alert('로그인이 필요한 서비스입니다.');
                    location.href = '/mba/auth/login';
                    return;
                }
                const detail   = map.result || {};
                const order    = detail.order || detail.orderInfo || detail;
                const items    = detail.items || detail.orderItems || [];
                const payments = detail.payments || detail.paymentList || [];

                renderOrderSummary(order);
                renderOrderItems(items);
                renderPayments(payments);
            },
            error: function () {
                loadOrderDetailOnly(orderId);
            }
        });
    }

    function loadOrderDetailOnly(orderId) {
        $.ajax({
            url: ORDER_API_BASE + '/selectOrderDetail',
            type: 'post',
            contentType: 'application/json',
            dataType: 'json',
            data: JSON.stringify({ orderId: orderId, orderIdx: orderId }),
            success: function (map) {
                if (!map) {
                    showAlert('주문 정보를 불러오는 중 오류가 발생했습니다.');
                    return;
                }
                if (map.msg === 'LOGIN_REQUIRED') {
                    alert('로그인이 필요한 서비스입니다.');
                    location.href = '/mba/auth/login';
                    return;
                }
                const order = map.result || map;
                renderOrderSummary(order);
                renderOrderItems([]);
                renderPayments([]);
                showAlert('주문 기본 정보만 조회되었습니다. (상품/결제 내역은 API 구현 필요)');
            },  
            error: function () {
                showAlert('주문 정보를 불러오는 중 서버 오류가 발생했습니다.');
            }
        });
    }

    // ===================== 렌더 =====================

    function renderOrderSummary(order) {
        if (!order) {
            showAlert('주문 정보를 찾을 수 없습니다.');
            return;
        }

        showAlert('');

        const orderNo = getFieldVal(order, 'orderNo');
        const orderDt = formatDateTime(
            getFieldVal(order, 'orderDt') || getFieldVal(order, 'createdDt')
        );

        const orderStatusCd = getFieldVal(order, 'orderStatusCd');
        const payStatusCd   = getFieldVal(order, 'payStatusCd');
        const payMethodCd   = getFieldVal(order, 'payMethodCd');

        const orderStatusNm = mapOrderStatusLabel(orderStatusCd);
        const payStatusNm   = mapPayStatusLabel(payStatusCd);
        const payMethodNm   = mapPayMethodLabel(payMethodCd);

        // 전역 상태 갱신
        CURRENT_ORDER_STATUS = orderStatusCd || '';
        CURRENT_PAY_STATUS   = payStatusCd || '';
        updateCancelButton();

        $('#field-orderNo').text(orderNo || '');
        $('#field-orderDt').text(orderDt || '');
        $('#field-orderStatus').html(renderStatusBadge(orderStatusCd, orderStatusNm));
        $('#field-payStatus').html(renderStatusBadge(payStatusCd, payStatusNm));
        $('#field-payMethod').text(payMethodNm || '');

        $('#field-totalProductAmt').text(formatMoney(getFieldVal(order, 'totalProductAmt')));
        $('#field-totalDiscountAmt').text(formatMoney(getFieldVal(order, 'totalDiscountAmt')));
        $('#field-deliveryAmt').text(formatMoney(getFieldVal(order, 'deliveryAmt')));
        $('#field-orderAmt').text(formatMoney(getFieldVal(order, 'orderAmt')));
        $('#field-pointUseAmt').text(formatMoney(getFieldVal(order, 'pointUseAmt')));
        $('#field-pointSaveAmt').text(formatMoney(getFieldVal(order, 'pointSaveAmt')));
        $('#field-couponUseAmt').text(formatMoney(getFieldVal(order, 'couponUseAmt')));
        $('#field-payAmt').text(formatMoney(getFieldVal(order, 'payAmt')));

        const receiverNm    = getFieldVal(order, 'receiverNm');
        const receiverPhone = getFieldVal(order, 'receiverPhone');
        const zipCode       = getFieldVal(order, 'zipCode');
        const addr1         = getFieldVal(order, 'addr1');
        const addr2         = getFieldVal(order, 'addr2');
        const deliveryMemo  = getFieldVal(order, 'deliveryMemo');

        $('#field-receiverNm').text(receiverNm || '');
        $('#field-receiverPhone').text(receiverPhone || '');
        $('#field-zipCode').text(zipCode || '');

        const addrText = (addr1 || '') + (addr2 ? (' ' + addr2) : '');
        $('#field-addr').text(addrText.trim());
        $('#field-deliveryMemo').text(deliveryMemo || '');
    }

    function renderOrderItems(items) {
        const $tb = $('#orderItemBody');
        $tb.empty();

        if (!items || !items.length) {
            $tb.append(
                '<tr><td colspan="7" class="text-center text-muted">주문 상품 정보가 없습니다.</td></tr>'
            );
            return;
        }

        for (let i = 0; i < items.length; i++) {
            const r  = items[i];
            const no = i + 1;

            const title =
                getFieldVal(r, 'title') ||
                getFieldVal(r, 'productTitle') ||
                getFieldVal(r, 'productNm') ||
                '(상품명 미확인)';

            // 이미지 URL 여러 키 후보 지원 (장바구니/상품 리스트와 동일 컨벤션)
            const imgUrlRaw =
                getFieldVal(r, 'mainImgUrl') ||
                getFieldVal(r, 'mainimgurl') ||
                getFieldVal(r, 'productImgUrl') ||
                getFieldVal(r, 'imageUrl') ||
                getFieldVal(r, 'imgUrl') ||
                '';
            const imgUrl = imgUrlRaw || NO_IMAGE_URL;

            const qtyRaw = getFieldVal(r, 'qty') || '1';
            let qty = Number(qtyRaw);
            if (!qty || Number.isNaN(qty) || qty <= 0) qty = 1;

            let unitPriceRaw =
                getFieldVal(r, 'unitPrice') ||
                getFieldVal(r, 'salePrice') ||
                getFieldVal(r, 'price') ||
                '0';
            let unitPrice = Number(unitPriceRaw);
            if (Number.isNaN(unitPrice)) unitPrice = 0;

            let shipFeeRaw =
                getFieldVal(r, 'shipFee') ||
                getFieldVal(r, 'deliveryAmt') ||
                '0';
            let shipFee = Number(shipFeeRaw);
            if (Number.isNaN(shipFee)) shipFee = 0;

            const productAmt = unitPrice * qty;
            const lineTotal  = productAmt + shipFee;

            let tr = '<tr>';
            tr += '  <td class="text-center">' + no + '</td>';
            tr += '  <td class="text-center">';
            tr += '    <img'
                + ' src="' + escapeHtml(imgUrl) + '"'
                + ' class="img-thumbnail"'
                + ' style="width:54px;height:54px;object-fit:contain;"'
                + ' onerror="this.onerror=null;this.src=\'' + NO_IMAGE_URL + '\';"'
                + ' />';
            tr += '  </td>';
            tr += '  <td>' + escapeHtml(title) + '</td>';
            tr += '  <td class="text-right">' + formatMoney(unitPrice) + '</td>';
            tr += '  <td class="text-right">' + qty + '</td>';
            tr += '  <td class="text-right">' + formatMoney(shipFee) + '</td>';
            tr += '  <td class="text-right font-weight-bold">' + formatMoney(lineTotal) + '</td>';
            tr += '</tr>';

            $tb.append(tr);
        }
    }

    function renderPayments(payments) {
        const $tb = $('#paymentBody');
        $tb.empty();

        if (!payments || !payments.length) {
            $tb.append(
                '<tr><td colspan="6" class="text-center text-muted">별도의 결제 내역이 없습니다. (주문 정보의 결제금액을 참고하세요.)</td></tr>'
            );
            return;
        }

        for (let i = 0; i < payments.length; i++) {
            const r  = payments[i];
            const no = i + 1;

            const payDt = formatDateTime(
                getFieldVal(r, 'payDt') || getFieldVal(r, 'createdDt') || getFieldVal(r, 'REQ_DT')
            );
            const payAmt = formatMoney(
                getFieldVal(r, 'payAmt') ||
                getFieldVal(r, 'payApprovedAmt') ||
                getFieldVal(r, 'payTotalAmt') ||
                '0'
            );
            const payMethodCd = getFieldVal(r, 'payMethodCd');
            const payStatusCd = getFieldVal(r, 'payStatusCd');
            const payMethodNm = mapPayMethodLabel(payMethodCd);
            const payStatusNm = mapPayStatusLabel(payStatusCd);
            const payStatusBadge = renderStatusBadge(payStatusCd, payStatusNm);

            const note =
                getFieldVal(r, 'memo') ||
                getFieldVal(r, 'note') ||
                '';

            let tr = '<tr>';
            tr += '  <td class="text-center">' + no + '</td>';
            tr += '  <td>' + escapeHtml(payDt) + '</td>';
            tr += '  <td class="text-right">' + payAmt + '</td>';
            tr += '  <td>' + escapeHtml(payMethodNm || payMethodCd || '') + '</td>';
            tr += '  <td>' + payStatusBadge + '</td>';
            tr += '  <td>' + escapeHtml(note) + '</td>';
            tr += '</tr>';

            $tb.append(tr);
        }
    }

    // ===================== 이동 =====================

    function goToOrderList() {
        location.href = '/ord/order/orderList';
    }
</script>
