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

    .cart-card{
        background: var(--card);
        border-radius: 16px;
        border: 1px solid var(--line);
        padding: 16px 18px;
    }

    .cart-header-row{
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 8px;
    }

    .cart-tools{
        display: flex;
        gap: 8px;
        align-items: center;
        font-size: 13px;
        color: var(--muted);
    }

    .cart-table{
        width: 100%;
        border-collapse: collapse;
        font-size: 13px;
    }
    .cart-table th,
    .cart-table td{
        border-top: 1px solid var(--line);
        padding: 8px 6px;
        vertical-align: middle;
    }
    .cart-table thead th{
        border-top: none;
        background:#f9fafb;
        font-weight: 600;
        color: var(--muted);
    }

    .cart-thumb{
        width: 64px;
        height: 64px;
        border-radius: 8px;
        background:#f3f4f6;
        object-fit: contain;
    }

    .cart-title{
        font-size: 13px;
        font-weight: 600;
        color: var(--text);
        margin-bottom: 2px;
    }

    .cart-meta{
        font-size: 11px;
        color: var(--muted);
    }

    .cart-empty{
        text-align: center;
        padding: 32px 0;
        color: var(--muted);
    }

    .cart-footer{
        display: flex;
        justify-content: space-between;
        margin-top: 12px;
        align-items: center;
        gap: 8px;
        flex-wrap: wrap;
    }

    .btn-order-selected{
        min-width: 160px;
        font-weight: 700;
        border-radius: 999px;
    }

    .btn-continue{
        border-radius: 999px;
        font-size: 13px;
    }

    .amount-summary{
        font-size: 14px;
        color: var(--muted);
    }
    .amount-summary strong{
        font-size: 16px;
        color: var(--text);
    }
</style>

<div class="page-wrap">
    <h2 class="page-title">장바구니</h2>

    <div class="cart-card">
        <div class="cart-header-row">
            <div class="cart-tools">
                <div class="form-check mb-0">
                    <input class="form-check-input" type="checkbox" id="chkAll" onclick="toggleAll(this)"/>
                    <label class="form-check-label" for="chkAll">전체 선택</label>
                </div>
                <button type="button" class="btn btn-sm btn-outline-secondary" onclick="deleteSelected()">
                    선택 삭제
                </button>
            </div>
            <div class="amount-summary">
                상품 합계: <strong id="cartSumProduct">0원</strong>
            </div>
        </div>

        <div id="cartTableWrap">
            <!-- 장바구니 테이블 -->
        </div>

        <div class="cart-footer">
            <div>
                <button type="button" class="btn btn-outline-secondary btn-continue" onclick="goProductList()">
                    쇼핑 계속하기
                </button>
            </div>
            <div>
                <button type="button" class="btn btn-primary btn-order-selected" onclick="goToOrderPage()">
                    선택 상품 주문하기
                </button>
            </div>
        </div>
    </div>
</div>

<script>
    const CART_API_BASE = '/api/crt/cart';
    const NO_IMAGE_URL = '/static/img/no-image-150.png';

    let gCartList = [];

    $(function () {
        loadCart();
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

    function loadCart() {
        $.ajax({
            url: CART_API_BASE + '/selectCartView',
            type: 'post',
            contentType: 'application/json',
            dataType: 'json',
            data: JSON.stringify({}),
            success: function (map) {
                if (!map) {
                    alert('장바구니 조회 중 오류가 발생했습니다.');
                    return;
                }
                if (map.msg === 'LOGIN_REQUIRED') {
                    alert('로그인이 필요한 서비스입니다.');
                    location.href = '/usr/login';
                    return;
                }
                if (map.msg !== '성공') {
                    alert(map.msg || '장바구니 조회 중 오류가 발생했습니다.');
                    return;
                }
                const result = map.result || {};
                gCartList = result.items || [];
                renderCartTable();
            },
            error: function () {
                alert('장바구니 조회 중 서버 오류가 발생했습니다.');
            }
        });
    }

    function renderCartTable() {
        const $wrap = $('#cartTableWrap');
        if (!gCartList.length) {
            $wrap.html('<div class="cart-empty">장바구니에 담긴 상품이 없습니다.</div>');
            $('#cartSumProduct').text('0원');
            return;
        }

        let html = '';
        html += '<table class="cart-table">';
        html += '  <thead>';
        html += '    <tr>';
        html += '      <th style="width:40px;"></th>';
        html += '      <th colspan="2">상품 정보</th>';
        html += '      <th style="width:80px;">수량</th>';
        html += '      <th style="width:100px;">상품 금액</th>';
        html += '    </tr>';
        html += '  </thead>';
        html += '  <tbody>';

        let sumProduct = 0;

        for (let i = 0; i < gCartList.length; i++) {
            const r = gCartList[i];

            // ★ 각 행의 고유 키: cartItemId 기준
            const cartItemId =
                r.cartItemId || r.cartitemid || r.id;

            const img = r.mainImgUrl || r.mainimgurl || NO_IMAGE_URL;
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

            let qty = Number(r.qty || 1);
            if (!qty || isNaN(qty) || qty <= 0) qty = 1;

            const lineAmt = unitPrice * qty;
            sumProduct += lineAmt;

            html += '    <tr>';
            html += '      <td class="text-center">';
            html += '        <input type="checkbox" name="cartChk" class="cart-chk" data-cart-id="' + escapeHtml(String(cartItemId)) + '"/>';
            html += '      </td>';
            html += '      <td style="width:72px;">';
            html += '        <img class="cart-thumb" src="' + img + '" onerror="this.onerror=null;this.src=\'' + NO_IMAGE_URL + '\';"/>';
            html += '      </td>';
            html += '      <td>';
            html += '        <div class="cart-title">' + escapeHtml(title) + '</div>';
            html += '        <div class="cart-meta">' + (brandNm ? ('브랜드: ' + escapeHtml(brandNm)) : '') + '</div>';
            html += '      </td>';
            html += '      <td class="text-center">' + qty + '</td>';
            html += '      <td class="text-right">' + fmtMoney(lineAmt) + '원</td>';
            html += '    </tr>';
        }

        html += '  </tbody>';
        html += '</table>';

        $wrap.html(html);
        $('#cartSumProduct').text(fmtMoney(sumProduct) + '원');
        $('#chkAll').prop('checked', false);
    }

    function toggleAll(chk) {
        const flag = $(chk).is(':checked');
        $('.cart-chk').prop('checked', flag);
    }

    function deleteSelected() {
        const ids = [];
        $('input[name="cartChk"]:checked').each(function () {
            const cid = $(this).data('cartId');
            if (cid !== null && cid !== undefined && cid !== '') {
                ids.push(String(cid));
            }
        });

        if (ids.length === 0) {
            alert('삭제할 상품을 선택해 주세요.');
            return;
        }

        if (!confirm('선택한 상품을 장바구니에서 삭제하시겠습니까?')) {
            return;
        }

        $.ajax({
            url: CART_API_BASE + '/deleteCartItems',
            type: 'post',
            contentType: 'application/json',
            dataType: 'json',
            data: JSON.stringify({ cartIds: ids }),
            success: function (map) {
                if (!map) {
                    alert('삭제 중 오류가 발생했습니다.');
                    return;
                }
                if (map.msg === 'LOGIN_REQUIRED') {
                    alert('로그인이 필요한 서비스입니다.');
                    location.href = '/usr/login';
                    return;
                }
                if (map.msg !== '삭제 성공' && map.msg !== '성공') {
                    alert(map.msg || '삭제 중 오류가 발생했습니다.');
                    return;
                }
                loadCart();
            },
            error: function () {
                alert('삭제 중 서버 오류가 발생했습니다.');
            }
        });
    }

    // 선택된 cartItemId 들만 주문 페이지로 넘긴다
    function goToOrderPage() {
        const ids = [];
        $('input[name="cartChk"]:checked').each(function () {
            const cid = $(this).data('cartId');
            if (cid !== null && cid !== undefined && cid !== '') {
                ids.push(String(cid));
            }
        });

        if (ids.length === 0) {
            alert('주문할 상품을 선택해 주세요.');
            return;
        }

        // 주문/결제 페이지로 cartIds 전달 (값은 cartItemId)
        location.href = '/ord/order/orderModify?cartIds=' + encodeURIComponent(ids.join(','));
    }

    function goProductList() {
        // 원하는 상품 리스트 URL로 교체
        location.href = '/prd/product/productList';
    }
</script>
