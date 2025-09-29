<%@ page contentType="text/html; charset=UTF-8" language="java" %>

<!-- Hero -->
<section class="hero-wrap">
    <div class="container">
        <div class="hero-panel shadow-lg">
            <div class="hero-content text-center">
                <h1 class="display-4 font-weight-bold mb-2">CONNECT</h1>
                <p class="lead mb-4">
                    데이터로 연결되는 공간 · 게시판 · 가계부 · K-Welcome Analytics
                </p>
                <div class="d-flex justify-content-center">
                    <a href="/bbs/board/boardList" class="btn btn-light btn-lg mr-2">
                        게시판 가기
                    </a>
                    <a href="/hhd/household/householdList" class="btn btn-outline-light btn-lg">
                        가계부 가기
                    </a>
                </div>
            </div>
        </div>
    </div>
</section>

<!-- 주요 기능 -->
<section class="container py-5">
    <div class="row">
        <div class="col-md-4 mb-4">
            <div class="card shadow h-100 hover-up">
                <div class="card-body">
                    <h5 class="card-title">빠른 글쓰기</h5>
                    <p class="card-text">
                        제목 한 줄 입력 → Enter! 초간단 게시글 등록 플로우를 지원합니다.
                    </p>
                    <a href="/bbs/board/board" class="btn btn-outline-primary btn-sm">
                        지금 작성
                    </a>
                </div>
            </div>
        </div>
        <div class="col-md-4 mb-4">
            <div class="card shadow h-100 hover-up">
                <div class="card-body">
                    <h5 class="card-title">가계부 요약</h5>
                    <p class="card-text">
                        이번 달 지출 현황과 카테고리별 통계를 한눈에 확인하세요.
                    </p>
                    <a href="/hhd/household/householdList" class="btn btn-outline-primary btn-sm">
                        상세 보기
                    </a>
                </div>
            </div>
        </div>
        <div class="col-md-4 mb-4">
            <div class="card shadow h-100 hover-up">
                <div class="card-body">
                    <h5 class="card-title">K-Welcome Analytics</h5>
                    <p class="card-text">
                        관광 핫스팟과 외국인 친화도 지수를 분석하는 데이터 보드.
                    </p>
                    <a href="/kwa/dashboard" class="btn btn-outline-primary btn-sm">
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
                새 게시글이 등록되었습니다.
                <span class="badge badge-pill badge-primary">NEW</span>
            </li>
            <li class="list-group-item d-flex justify-content-between align-items-center">
                가계부: 교통비 12,300원 추가
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

    /* ====== HERO 대칭 여백 세팅 ======
       - --outer: 페이지와 히어로 카드 사이의 바깥 여백(상/하 동일)
       - --pad  : 카드 내부의 상/하 패딩(완벽 대칭)
    */
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

        /* 배경 그라디언트 */
        background: linear-gradient(135deg, #0d6efd 0%, #6f42c1 55%, #20c997 100%);

        /* 입체감 하이라이트 */
        box-shadow: 0 18px 48px rgba(24,39,75,.18);
    }
    /* 장식 하이라이트(빛감) */
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

        /* 상/하 완전 대칭 */
        padding-block: var(--pad);
        padding-inline: clamp(16px, 5vw, 64px);

        color:#fff;
        text-shadow: 0 2px 8px rgba(0,0,0,.18);
    }

    /* 모바일에서 폰트/여백 살짝 축소 */
    @media (max-width: 576px){
        .hero-content{ padding-block: clamp(44px, 8vw, 64px); }
        .hero-content .display-4{ font-size:2rem; }
        .hero-content .lead{ font-size:1rem; }
    }
</style> 