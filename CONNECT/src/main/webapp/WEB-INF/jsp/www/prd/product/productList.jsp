<%@ page language="java" contentType="text/html; charset=UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.2/dist/css/bootstrap.min.css"/>
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>

<style>
    :root{
        --bg:#f7f8fb; --card:#fff; --line:#e9edf3; --text:#0f172a; --muted:#667085; --accent:#2563eb; --price:#e11d48;
    }
    body{ background:var(--bg); }
    .page-title{ font-size:24px; font-weight:800; color:var(--text); margin:14px 0 16px; }

    /* ▼ 카드 넓이 확대: 기본 5열로 변경 */
    .grid{ display:grid; grid-template-columns: repeat(5, 1fr); grid-gap: 16px; }
    @media (max-width: 1399px){ .grid{ grid-template-columns: repeat(4,1fr);} }
    @media (max-width: 1199px){ .grid{ grid-template-columns: repeat(3,1fr);} }
    @media (max-width: 991px){  .grid{ grid-template-columns: repeat(2,1fr);} }
    @media (max-width: 575px){  .grid{ grid-template-columns: 1fr; } }

    .card-item{
        background:var(--card); border:1px solid var(--line); border-radius:16px; padding:12px;
        transition: box-shadow .15s ease, transform .15s ease; cursor:pointer; height:100%;
    }
    .card-item:hover{ box-shadow:0 8px 24px rgba(15,23,42,.08); transform: translateY(-2px); }
    .thumb{ width:100%; height:160px; object-fit:cover; border-radius:12px; background:#fafafa; }
    .title{ margin:8px 0 6px; font-weight:700; color:var(--text); line-height:1.35; display:-webkit-box;
            -webkit-line-clamp:2; -webkit-box-orient:vertical; overflow:hidden; min-height:3.4em; }
    .price-row{ display:flex; align-items:baseline; gap:8px; }
    .sale{ font-size:20px; font-weight:800; color:var(--price); }
    .listp{ font-size:13px; color:#94a3b8; text-decoration:line-through; }
    .meta{ font-size:12px; color:#64748b; }
    .badge-rocket{ font-size:11px; border:1px solid #4f46e5; color:#4f46e5; border-radius:999px; padding:2px 8px; }
    .badge-free{ font-size:11px; border:1px solid #10b981; color:#059669; border-radius:999px; padding:2px 8px; }
    .toolbar{ display:flex; gap:8px; margin-bottom:12px; }
    .empty{ grid-column:1/-1; text-align:center; color:var(--muted); padding:40px 0; }
</style>

<section class="container-fluid">
    <div class="d-flex justify-content-between align-items-center">
        <h2 class="page-title">쇼핑몰 상품</h2>
        <div class="toolbar">
            <button class="btn btn-primary" type="button" onclick="goToProductModify()">상품 등록</button>
            <a class="btn btn-outline-secondary" href="/prd/product/product">통합</a>
        </div>
    </div>

    <div id="grid" class="grid"></div>
</section>

<script>
    const API_BASE = '/api/prd/product';
    const PK = 'productId';

    $(function () { load(); });

    function load() {
        $.ajax({
            url: API_BASE + '/selectProductList',
            type: 'post',
            contentType: 'application/json',
            dataType: 'json',
            data: JSON.stringify({ limit: 60 }),
            success: function (map) {
                const list = map.result || [];
                render(list);
            },
            error: function () { alert('목록 조회 중 오류'); }
        });
    }

    function render(list) {
        const $grid = $('#grid');
        if (!list.length) {
            $grid.html('<div class="empty">등록된 상품이 없습니다.</div>');
            return;
        }
        let html = '';
        for (let i = 0; i < list.length; i++) {
            const r = list[i];
            const rocket = (r.sourceCd === 'CPNG') ? '<span class="badge-rocket">로켓</span>' : '';
            const free = (Number(r.shipFee || 0) === 0) ? '<span class="badge-free">무료배송</span>' : '';
            const listPriceHtml = (r.listPrice !== null && r.listPrice !== undefined && r.listPrice !== '')
                ? '<span class="listp">' + fmtMoney(r.listPrice) + ' ' + (r.currencyCd || 'KRW') + '</span>'
                : '';
            const ratingHtml = r.ratingAvg
                ? '★ ' + Number(r.ratingAvg).toFixed(2) + ' <span class="meta">(' + (r.reviewCnt || 0) + ')</span>'
                : '';

            html += ''
                + '<div class="card-item" onclick="goToProductDetail(' + r.productId + ')">'
                +   '<img class="thumb" src="' + (r.mainImgUrl || '') + '" '
                +        "onerror=\"this.src='https://via.placeholder.com/400x300?text=No+Image'\"/>"
                +   '<div class="title">' + (r.title || '') + '</div>'
                +   '<div class="price-row">'
                +       '<div class="sale">' + fmtMoney(r.salePrice) + ' ' + (r.currencyCd || 'KRW') + '</div>'
                +        listPriceHtml
                +   '</div>'
                +   '<div class="meta d-flex justify-content-between">'
                +       '<div>' + ratingHtml + '</div>'
                +       '<div>' + rocket + ' ' + free + '</div>'
                +   '</div>'
                + '</div>';
        }
        $grid.html(html);
    }

    function fmtMoney(v){
        if (v === null || v === undefined || v === '') return '-';
        const n = Number(v);
        if (isNaN(n)) return String(v);
        return n.toLocaleString();
    }

    function goToProductModify(id){
        let url = '/prd/product/productModify';
        if (id) url += '?' + PK + '=' + encodeURIComponent(id);
        location.href = url;
    }
    function goToProductDetail(id){ goToProductModify(id); }
</script> 