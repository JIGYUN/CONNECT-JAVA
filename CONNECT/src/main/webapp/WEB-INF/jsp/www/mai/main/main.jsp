<%@ page contentType="text/html; charset=UTF-8" language="java" %>

<!-- Hero -->
<section class="hero-wrap">
    <div class="container">
        <div class="hero-panel shadow-lg">
            <div class="hero-content text-center">
                <h1 class="display-4 font-weight-bold mb-2">CONNECT</h1>
                <p class="lead mb-4">
                    데이터로 연결되는 공간 · 챗봇 · 커머스 · Analytics
                </p>
                <div class="d-flex justify-content-center flex-wrap">
                    <a href="/cht/chatRoom/chatBotRoomList" class="btn btn-light btn-lg mr-2 mb-2">
                        법률 챗봇
                    </a>
                    <a href="/prd/product/productList" class="btn btn-outline-light btn-lg mb-2">
                        쇼핑몰
                    </a>
                </div>
            </div>
        </div>
    </div>
</section>

<!-- ✅ 퀵 링크 바(게시판/가계부는 핵심 2개 아래로 내림) -->
<section class="container" style="margin-top:-10px; margin-bottom:10px;">
    <div class="quickbar shadow-sm">
        <div class="quickbar-left">
            <span class="quickbar-title">바로가기</span>
            <span class="quickbar-sub">핵심 기능은 상단, 나머지는 빠르게 이동</span>
        </div>
        <div class="quickbar-actions">
            <a href="/bbs/board/boardList" class="btn btn-outline-primary btn-sm btn-pill">게시판</a>
            <a href="/hhd/household/householdList" class="btn btn-outline-primary btn-sm btn-pill">가계부</a>
            <a href="/kwa/dashboard" class="btn btn-outline-primary btn-sm btn-pill">KWA 대시보드</a>
        </div>
    </div>
</section>

<!-- ✅ 핵심 기능 (법률 챗봇 / 쇼핑몰 / KWA) -->
<section class="container py-5">
    <div class="row">
        <!-- 법률 챗봇 -->
        <div class="col-md-4 mb-4">
            <div class="card shadow h-100 hover-up">
                <div class="card-body">
                    <div class="icon-badge">⚖</div>
                    <h5 class="card-title mt-3">법률 챗봇 (RAG)</h5>
                    <p class="card-text">
                        판례/FAQ 기반 벡터 검색 + LLM 답변. 질문 → 근거 → 답변 흐름으로 제공됩니다.
                    </p>
                    <a href="/cht/chatRoom/chatBotRoomList" class="btn btn-outline-primary btn-sm btn-pill">
                        채팅 시작
                    </a>
                </div>
            </div>
        </div>

        <!-- 쇼핑몰 -->
        <div class="col-md-4 mb-4">
            <div class="card shadow h-100 hover-up">
                <div class="card-body">
                    <div class="icon-badge icon-badge-2">🛒</div>
                    <h5 class="card-title mt-3">쇼핑몰</h5>
                    <p class="card-text">
                        상품 탐색 → 장바구니 → 주문/결제까지. 포인트 기반 결제 플로우를 지원합니다.
                    </p>
                    <a href="/prd/product/productList" class="btn btn-outline-primary btn-sm btn-pill">
                        상품 보러가기
                    </a>
                </div>
            </div>
        </div>

        <!-- KWA -->
        <div class="col-md-4 mb-4">
            <div class="card shadow h-100 hover-up">
                <div class="card-body">
                    <div class="icon-badge icon-badge-3">📊</div>
                    <h5 class="card-title mt-3">K-Welcome Analytics</h5>
                    <p class="card-text">
                        관광 핫스팟과 외국인 친화도 지수를 분석하는 데이터 보드.
                    </p>
                    <a href="/kwa/dashboard" class="btn btn-outline-primary btn-sm btn-pill">
                        대시보드
                    </a>
                </div>
            </div>
        </div>
    </div>
</section>

<!-- 최근 활동 -->
<section class="bg-light py-5">
    <div class="container">
        <div class="d-flex align-items-center mb-3">
            <h5 class="mb-0 mr-2">최근 활동</h5>
            <span class="text-muted small">샘플 행 — API 연결 전까지 더미</span>
        </div>
        <ul class="list-group list-group-flush">
            <li class="list-group-item d-flex justify-content-between align-items-center">
                법률 챗봇: 새 채팅방이 생성되었습니다.
                <span class="badge badge-pill badge-primary">NEW</span>
            </li>
            <li class="list-group-item d-flex justify-content-between align-items-center">
                쇼핑몰: 주문/결제 화면 개선(포인트 충전 유도)
                <span class="text-muted small">방금 전</span>
            </li>
            <li class="list-group-item d-flex justify-content-between align-items-center">
                KWI(친화도 지수) 보고서가 갱신되었습니다.
                <span class="text-muted small">어제</span>
            </li>
        </ul>
    </div>
</section>

<!-- 페이지 전용 스타일 -->
<style>
    /* ====== 공통 카드 호버 ====== */
    .hover-up { transition: transform .2s ease, box-shadow .2s ease; }
    .hover-up:hover {
        transform: translateY(-4px);
        box-shadow: 0 1rem 2rem rgba(0,0,0,.15) !important;
    }

    /* ====== HERO 대칭 여백 세팅 ====== */
    .hero-wrap {
        --outer: 40px;
        margin-block: var(--outer);
    }

    .hero-panel {
        --pad: clamp(56px, 7vw, 96px);
        --radius: 1rem;

        position: relative;
        border-radius: var(--radius);
        overflow: hidden;

        background: linear-gradient(135deg, #0d6efd 0%, #6f42c1 55%, #20c997 100%);
        box-shadow: 0 18px 48px rgba(24,39,75,.18);
    }

    .hero-panel::after{
        content:"";
        position:absolute; inset:0;
        background:
            radial-gradient(900px 300px at 10% -20%, rgba(255,255,255,.18), transparent 60%),
            radial-gradient(600px 220px at 90% 120%, rgba(255,255,255,.12), transparent 55%);
        pointer-events:none;
    }

    .hero-content{
        position:relative;
        z-index:1;
        padding-block: var(--pad);
        padding-inline: clamp(16px, 5vw, 64px);
        color:#fff;
        text-shadow: 0 2px 8px rgba(0,0,0,.18);
    }

    @media (max-width: 576px){
        .hero-content{ padding-block: clamp(44px, 8vw, 64px); }
        .hero-content .display-4{ font-size:2rem; }
        .hero-content .lead{ font-size:1rem; }
    }

    /* ✅ Quickbar */
    .quickbar{
        background:#fff;
        border: 1px solid rgba(0,0,0,.06);
        border-radius: 16px;
        padding: 12px 14px;
        display:flex;
        align-items:center;
        justify-content: space-between;
        gap: 12px;
    }
    .quickbar-title{
        font-weight: 800;
        color: #111827;
        margin-right: 10px;
    }
    .quickbar-sub{
        color: #6b7280;
        font-size: 12px;
    }
    .quickbar-actions{
        display:flex;
        gap: 8px;
        flex-wrap: wrap;
        justify-content:flex-end;
    }
    .btn-pill{ border-radius: 999px; }

    @media (max-width: 576px){
        .quickbar{ flex-direction: column; align-items: flex-start; }
        .quickbar-actions{ width:100%; justify-content:flex-start; }
    }

    /* ✅ 카드 아이콘 배지 */
    .icon-badge{
        width: 44px;
        height: 44px;
        border-radius: 14px;
        display:flex;
        align-items:center;
        justify-content:center;
        font-weight: 900;
        font-size: 18px;
        color: #0b2a66;
        background: rgba(13,110,253,.14);
        border: 1px solid rgba(13,110,253,.18);
    }
    .icon-badge-2{
        color: #2b1b5a;
        background: rgba(111,66,193,.12);
        border: 1px solid rgba(111,66,193,.18);
    }
    .icon-badge-3{
        color: #0a3d2f;
        background: rgba(32,201,151,.12);
        border: 1px solid rgba(32,201,151,.18);
    }
</style>
