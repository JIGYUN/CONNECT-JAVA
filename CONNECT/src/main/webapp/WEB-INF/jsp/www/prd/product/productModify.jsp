<%@ page language="java" contentType="text/html; charset=UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.2/dist/css/bootstrap.min.css"/>
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>

<style>
    :root {
        --bg: #f7f8fb;
        --card: #ffffff;
        --line: #e5e7eb;
        --text: #0f172a;
        --muted: #6b7280;
        --accent: #2563eb;
        --accent-soft: #dbeafe;
        --price: #e11d48;
        --success: #16a34a;
    }

    body {
        background: var(--bg);
    }

    .page-wrap {
        max-width: 1100px;
        margin: 16px auto 40px;
        padding: 0 12px;
    }

    .breadcrumb-sm {
        font-size: 12px;
        color: var(--muted);
        margin-bottom: 6px;
    }

    .product-header {
        display: flex;
        flex-wrap: wrap;
        gap: 24px;
    }

    .product-image-wrap {
        flex: 0 0 380px;
        max-width: 380px;
    }

    .product-main-card {
        background: var(--card);
        border-radius: 16px;
        border: 1px solid var(--line);
        padding: 16px;
    }

    .product-main-img {
        width: 100%;
        height: 340px;
        object-fit: contain;
        border-radius: 12px;
        background: #f9fafb;
    }

    .thumb-badges {
        margin-top: 8px;
        display: flex;
        justify-content: space-between;
        align-items: center;
        font-size: 11px;
        color: var(--muted);
    }

    .badge-rocket {
        font-size: 11px;
        border: 1px solid #4f46e5;
        color: #4f46e5;
        border-radius: 999px;
        padding: 2px 8px;
        font-weight: 600;
    }

    .badge-free {
        font-size: 11px;
        border: 1px solid #10b981;
        color: #059669;
        border-radius: 999px;
        padding: 2px 8px;
        font-weight: 600;
        margin-left: 4px;
    }

    .product-info-wrap {
        flex: 1;
        min-width: 260px;
    }

    .product-source {
        font-size: 12px;
        color: var(--muted);
        margin-bottom: 4px;
    }

    .product-title {
        font-size: 20px;
        font-weight: 800;
        color: var(--text);
        line-height: 1.4;
        margin-bottom: 6px;
    }

    .product-brand {
        font-size: 13px;
        color: var(--muted);
        margin-bottom: 8px;
    }

    .product-rating {
        font-size: 13px;
        color: #f97316;
        margin-bottom: 10px;
    }

    .product-rating .meta {
        font-size: 12px;
        color: var(--muted);
        margin-left: 4px;
    }

    .price-block {
        padding: 12px 14px;
        border-radius: 14px;
        background: var(--card);
        border: 1px solid var(--line);
        margin-bottom: 10px;
    }

    .price-row {
        display: flex;
        align-items: baseline;
        gap: 8px;
    }

    .price-sale {
        font-size: 26px;
        font-weight: 800;
        color: var(--price);
    }

    .price-list {
        font-size: 13px;
        color: #9ca3af;
        text-decoration: line-through;
    }

    .price-currency {
        font-size: 13px;
        color: var(--muted);
    }

    .ship-info {
        margin-top: 6px;
        font-size: 13px;
        color: var(--muted);
    }

    .ship-info span {
        font-weight: 600;
    }

    .point-info {
        margin-top: 6px;
        font-size: 13px;
        color: #047857;
    }

    .qty-card {
        background: var(--card);
        border-radius: 14px;
        border: 1px solid var(--line);
        padding: 12px 14px;
        margin-top: 10px;
    }

    .qty-row {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 8px;
    }

    .qty-input-group {
        display: flex;
        align-items: center;
        border-radius: 999px;
        border: 1px solid var(--line);
        overflow: hidden;
        background: #f9fafb;
    }

    .qty-btn {
        width: 32px;
        height: 30px;
        border: none;
        background: transparent;
        font-size: 16px;
        line-height: 1;
        cursor: pointer;
    }

    .qty-value {
        width: 50px;
        border-left: 1px solid var(--line);
        border-right: 1px solid var(--line);
        text-align: center;
        font-size: 14px;
        background: #ffffff;
    }

    .total-row {
        display: flex;
        justify-content: space-between;
        align-items: baseline;
        margin-top: 8px;
    }

    .total-label {
        font-size: 13px;
        color: var(--muted);
    }

    .total-price {
        font-size: 22px;
        font-weight: 800;
        color: #111827;
    }

    .action-row {
        display: flex;
        gap: 8px;
        margin-top: 14px;
    }

    .btn-cart {
        flex: 1;
        border-radius: 999px;
        border-width: 1px;
        font-size: 14px;
        font-weight: 600;
    }

    .btn-buy {
        flex: 1;
        border-radius: 999px;
        font-size: 14px;
        font-weight: 700;
    }

    .product-origin-link {
        margin-top: 10px;
        text-align: right;
        font-size: 12px;
    }

    .product-origin-link a {
        color: var(--accent);
        text-decoration: underline;
    }

    .detail-tabs {
        margin-top: 32px;
    }

    .detail-tabs .nav-link {
        padding: 8px 16px;
        font-size: 14px;
    }

    .detail-body {
        background: var(--card);
        border-radius: 16px;
        border: 1px solid var(--line);
        padding: 18px;
        margin-top: -1px;
    }

    #descriptionView img {
        max-width: 100%;
        height: auto;
    }

    @media (max-width: 767px) {
        .product-header {
            flex-direction: column;
        }
        .product-image-wrap {
            max-width: 100%;
        }
    }
</style>

<div class="page-wrap">
    <div class="breadcrumb-sm">
        홈 &gt; 쇼핑몰 &gt; 상품 상세
    </div>

    <div class="product-header">
        <!-- 좌측: 메인 이미지 -->
        <div class="product-image-wrap">
            <div class="product-main-card">
                <img id="mainImg" class="product-main-img"
                     src="/no-image-600x400.png"
                     alt="상품 이미지"
                     onerror="this.onerror=null;this.src='/no-image-600x400.png';"/>
                <div class="thumb-badges">
                    <div>
                        <span id="badgeRocket" class="badge-rocket" style="display:none;">로켓</span>
                        <span id="badgeFree" class="badge-free" style="display:none;">무료배송</span>
                    </div>
                    <div id="sourceText"></div>
                </div>
            </div>

            <div class="product-origin-link">
                <a href="#" id="originLink" target="_blank" style="display:none;">
                    원본 상품 페이지 열기 &raquo;
                </a>
            </div>
        </div>

        <!-- 우측: 상품 정보 -->
        <div class="product-info-wrap">
            <div class="product-source" id="sourceCdText"></div>
            <div class="product-title" id="title">상품 제목 로딩 중...</div>
            <div class="product-brand" id="brandNm"></div>

            <div class="product-rating" id="ratingArea" style="display:none;"></div>

            <div class="price-block">
                <div class="price-row">
                    <div class="price-sale" id="salePrice">0</div>
                    <div class="price-currency" id="currencyCd">KRW</div>
                    <div class="price-list" id="listPrice" style="display:none;"></div>
                </div>
                <div class="ship-info" id="shipInfo"></div>
                <div class="point-info" id="pointInfo"></div>
            </div>

            <div class="qty-card">
                <div class="qty-row">
                    <div class="font-weight-bold">수량</div>
                    <div class="qty-input-group">
                        <button type="button" class="qty-btn" onclick="changeQty(-1)">-</button>
                        <input type="text" id="qty" class="qty-value" value="1" oninput="onChangeQtyInput(this)"/>
                        <button type="button" class="qty-btn" onclick="changeQty(1)">+</button>
                    </div>
                </div>
                <div class="total-row">
                    <div class="total-label">총 상품금액 (배송비 포함)</div>
                    <div class="total-price" id="totalPrice">0원</div>
                </div>
            </div>

            <div class="action-row">
                <button type="button" class="btn btn-outline-secondary btn-cart" onclick="addToCart()">
                    장바구니
                </button>
                <button type="button" class="btn btn-primary btn-buy" onclick="buyNow()">
                    바로 구매
                </button>
            </div>
        </div>
    </div>

    <!-- 상세 / 리뷰 / 문의 탭 -->
    <div class="detail-tabs">
        <ul class="nav nav-tabs" id="detailTab" role="tablist">
            <li class="nav-item">
                <a class="nav-link active" id="tab-desc" data-toggle="tab" href="#tabDesc"
                   role="tab" aria-controls="tabDesc" aria-selected="true">상세정보</a>
            </li>
            <li class="nav-item">
                <a class="nav-link" id="tab-review" data-toggle="tab" href="#tabReview"
                   role="tab" aria-controls="tabReview" aria-selected="false">리뷰 (예정)</a>
            </li>
            <li class="nav-item">
                <a class="nav-link" id="tab-qna" data-toggle="tab" href="#tabQna"
                   role="tab" aria-controls="tabQna" aria-selected="false">문의 (예정)</a>
            </li>
        </ul>

        <div class="detail-body tab-content">
            <div class="tab-pane fade show active" id="tabDesc" role="tabpanel" aria-labelledby="tab-desc">
                <div id="descriptionView">
                    <div class="text-muted" id="descEmpty" style="display:none;">
                        등록된 상세 설명이 없습니다.
                    </div>
                </div>
            </div>
            <div class="tab-pane fade" id="tabReview" role="tabpanel" aria-labelledby="tab-review">
                <p class="text-muted mb-0">
                    리뷰/평점 기능은 추후 구현 예정입니다.
                </p>
            </div>
            <div class="tab-pane fade" id="tabQna" role="tabpanel" aria-labelledby="tab-qna">
                <p class="text-muted mb-0">
                    상품 문의 기능은 추후 구현 예정입니다.
                </p>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@4.6.2/dist/js/bootstrap.bundle.min.js"></script>

<script>
    const API_BASE      = '/api/prd/product';
    const PK            = 'productId';
    const CART_API_BASE = '/api/crt/cart';
    const CART_LIST_URL = '/crt/cart/cartList';
    const NO_IMAGE_URL  = '/no-image-600x400.png';

    // JSP 파라미터에서 productId 주입
    const PRODUCT_ID = Number('<c:out value="${param.productId}" />') || 0;

    let gSalePrice = 0;
    let gShipFee   = 0;

    $(function () {
        if (!PRODUCT_ID) {
            alert('잘못된 접근입니다. 상품 번호가 없습니다.');
            history.back();
            return;
        }
        loadProductDetail(PRODUCT_ID);
    });

    function fmtMoney(v) {
        if (v === null || v === undefined || v === '') return '-';
        const n = Number(v);
        if (isNaN(n)) return String(v);
        return n.toLocaleString();
    }

    function getField(row, camel, lower) {
        let v = row[camel];
        if (v === undefined || v === null || v === '') {
            v = row[lower];
        }
        return v;
    }

    function loadProductDetail(id) {
        const p = {};
        p[PK] = id;

        $.ajax({
            url: API_BASE + '/selectProductDetail',
            type: 'post',
            contentType: 'application/json',
            dataType: 'json',
            data: JSON.stringify(p),
            success: function (map) {
                const r = map.result || {};
                renderDetail(r);
            },
            error: function () {
                alert('상품 조회 중 오류가 발생했습니다.');
            }
        });
    }

    function renderDetail(r) {
        const titleRaw       = getField(r, 'title', 'title');
        const brandRaw       = getField(r, 'brandNm', 'brandnm');

        const saleRaw        = getField(r, 'salePrice', 'saleprice');
        const salePrice      = Number(saleRaw || 0);

        const listRaw        = getField(r, 'listPrice', 'listprice');
        const listPrice      = (listRaw !== null && listRaw !== undefined && listRaw !== '')
            ? Number(listRaw) : null;

        const currencyCd     = getField(r, 'currencyCd', 'currencycd') || 'KRW';

        const ratingRaw      = getField(r, 'ratingAvg', 'ratingavg');
        const ratingAvg      = (ratingRaw !== null && ratingRaw !== undefined && ratingRaw !== '')
            ? Number(ratingRaw) : null;

        const reviewRaw      = getField(r, 'reviewCnt', 'reviewcnt');
        const reviewCnt      = Number(reviewRaw || 0);

        const mainImgUrl     = getField(r, 'mainImgUrl', 'mainimgurl') || '';
        const productUrl     = getField(r, 'productUrl', 'producturl') || '';
        const sourceCd       = getField(r, 'sourceCd', 'sourcecd') || '';
        const grpCd          = getField(r, 'grpCd', 'grpcd') || '';

        const shipRaw        = getField(r, 'shipFee', 'shipfee');
        const shipFee        = Number(shipRaw || 0);

        const descriptionTxt = getField(r, 'descriptionTxt', 'descriptiontxt') || '';

        gSalePrice = salePrice;
        gShipFee   = shipFee;

        const title   = titleRaw || '상품명 미등록';
        const brandNm = brandRaw || '';

        $('#title').text(title);
        if (brandNm) {
            $('#brandNm').text('브랜드: ' + brandNm);
        } else {
            $('#brandNm').text('');
        }

        let sourceLabel = '';
        if (sourceCd === 'CPNG')      sourceLabel = '쿠팡';
        else if (sourceCd === 'GMRK') sourceLabel = 'G마켓';
        else if (sourceCd === 'NVSH') sourceLabel = '네이버쇼핑';
        else if (sourceCd)           sourceLabel = sourceCd;

        const grpText = grpCd ? (' · ' + grpCd) : '';
        $('#sourceCdText').text(sourceLabel ? (sourceLabel + grpText) : (grpCd ? grpCd : '상품 정보'));
        $('#sourceText').text(sourceLabel || '');

        if (mainImgUrl) {
            $('#mainImg').attr('src', mainImgUrl);
        } else {
            $('#mainImg').attr('src', NO_IMAGE_URL);
        }

        if (sourceCd === 'CPNG') {
            $('#badgeRocket').show();
        } else {
            $('#badgeRocket').hide();
        }
        if (shipFee === 0) {
            $('#badgeFree').show();
        } else {
            $('#badgeFree').hide();
        }

        $('#salePrice').text(fmtMoney(salePrice) + '원');
        $('#currencyCd').text(currencyCd);

        if (listPrice !== null && !isNaN(listPrice) && listPrice > salePrice) {
            $('#listPrice')
                .text(fmtMoney(listPrice) + '원')
                .show();
        } else {
            $('#listPrice').hide();
        }

        let shipInfoText = '';
        if (shipFee === 0) {
            shipInfoText = '<span>무료배송</span> · 도서/산간 일부 추가 배송비 발생 가능';
        } else {
            shipInfoText = '배송비 <span>' + fmtMoney(shipFee) + '원</span>';
        }
        $('#shipInfo').html(shipInfoText);

        if (ratingAvg !== null && !isNaN(ratingAvg) && ratingAvg > 0) {
            const ratingHtml =
                '★ ' + ratingAvg.toFixed(2) +
                '<span class="meta"> · 리뷰 ' + fmtMoney(reviewCnt) + '개</span>';
            $('#ratingArea').html(ratingHtml).show();
        } else {
            $('#ratingArea').hide();
        }

        if (productUrl) {
            $('#originLink').attr('href', productUrl).show();
        } else {
            $('#originLink').hide();
        }

        if (descriptionTxt && descriptionTxt.trim() !== '') {
            $('#descriptionView').html(descriptionTxt);
            $('#descEmpty').hide();
        } else {
            $('#descriptionView').html('');
            $('#descEmpty').show();
        }

        recalcTotal();
    }

    function getQty() {
        const v = $('#qty').val();
        const n = Number(v);
        if (!n || isNaN(n) || n <= 0) return 1;
        if (n > 99) return 99;
        return Math.floor(n);
    }

    function setQty(n) {
        let q = n;
        if (q <= 0) q = 1;
        if (q > 99) q = 99;
        $('#qty').val(q);
        recalcTotal();
    }

    function changeQty(delta) {
        const current = getQty();
        setQty(current + delta);
    }

    function onChangeQtyInput(el) {
        const val = Number(el.value);
        if (!val || isNaN(val) || val <= 0) {
            el.value = '1';
        } else if (val > 99) {
            el.value = '99';
        }
        recalcTotal();
    }

    function recalcTotal() {
        const qty          = getQty();
        const productTotal = gSalePrice * qty;
        const total        = productTotal + gShipFee;

        $('#totalPrice').text(fmtMoney(total) + '원');

        const point = Math.floor(productTotal * 0.01);
        if (point > 0) {
            $('#pointInfo').text('구매 시 약 ' + fmtMoney(point) + ' P 적립 예정 (추후 포인트 시스템 연동)');
        } else {
            $('#pointInfo').text('');
        }
    }

    function handleLoginRequired(map) {
        if (map && map.msg === 'LOGIN_REQUIRED') {
            alert('로그인이 필요한 서비스입니다.');
            location.href = '/mba/auth/login';
            return true;
        } 
        return false;
    }

    function addToCart() {
        const qty = getQty();
        const payload = {
            productId: PRODUCT_ID,
            qty: qty
        };

        $.ajax({
            url: CART_API_BASE + '/addItem',
            type: 'post',
            contentType: 'application/json',
            dataType: 'json',
            data: JSON.stringify(payload),
            success: function (map) {
                if (!map) {
                    alert('장바구니 담기 중 오류가 발생했습니다.');
                    return;
                }
                if (handleLoginRequired(map)) {
                    return;
                }
                if (map.msg !== '성공') {
                    alert(map.msg || '장바구니 담기 중 오류가 발생했습니다.');
                    return;
                }

                if (confirm('장바구니에 담았습니다.\n장바구니로 이동하시겠습니까?')) {
                    location.href = CART_LIST_URL;
                }
            },
            error: function () {
                alert('장바구니 담기 중 서버 오류가 발생했습니다.');
            }
        });
    }

    function buyNow() {
        const qty = getQty();
        const payload = {
            productId: PRODUCT_ID,
            qty: qty
        };

        $.ajax({
            url: CART_API_BASE + '/addItem',
            type: 'post',
            contentType: 'application/json',
            dataType: 'json',
            data: JSON.stringify(payload),
            success: function (map) {
                if (!map) {
                    alert('구매 준비 중 오류가 발생했습니다.');
                    return;
                }
                if (handleLoginRequired(map)) {
                    return;
                }
                if (map.msg !== '성공') {
                    alert(map.msg || '구매 준비 중 오류가 발생했습니다.');
                    return;
                }

                // ★ 서버에서 cartItemId 받아서 해당 상품만 주문페이지에 노출
                var cartItemIdRaw = map.cartItemId;
                if (cartItemIdRaw === null || cartItemIdRaw === undefined || cartItemIdRaw === '') {
                    // cartItemId 못 받으면 예전 방식으로 전체 주문페이지로 이동
                    console.warn('cartItemId not returned, fallback to full order page');
                    location.href = '/ord/order/orderModify';
                    return;
                }
                var cartItemId = String(cartItemIdRaw);

                // 선택한 한 개만 보이도록 cartIds 쿼리스트링으로 전달
                location.href = '/ord/order/orderModify?cartIds=' + encodeURIComponent(cartItemId);
            },
            error: function () {
                alert('구매 준비 중 서버 오류가 발생했습니다.');
            }
        });
    }
</script>
