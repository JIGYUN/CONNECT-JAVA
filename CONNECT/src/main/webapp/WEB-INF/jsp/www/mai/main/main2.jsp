<%@ page contentType="text/html; charset=UTF-8" language="java" %>

<!-- Main -->
<section class="hero-wrap">
    <div class="container">
        <div class="hero-panel">
            <div class="hero-grid">
                <!-- Left -->
                <div class="hero-left">
                    <div class="hero-badges">
                        <span class="badge-soft">CONNECT</span>
                        <span class="badge-soft badge-soft-2">Alpha</span>
                        <span class="badge-soft badge-soft-3">KST</span>
                    </div>

                    <h1 class="hero-title">
                        연결된 데이터로<br class="d-none d-md-block"/>
                        일상을 운영하다
                    </h1>

                    <p class="hero-sub">
                        공간·게시판·가계부·K-Welcome Analytics까지.<br/>
                        흩어진 기록을 <strong>하나의 흐름</strong>으로 묶는 개인 운영 플랫폼.
                    </p>

                    <div class="hero-actions">
                        <a href="/bbs/board/boardList" class="btn btn-light btn-lg btn-pill mr-2">
                            게시판
                        </a>
                        <a href="/hhd/household/householdList" class="btn btn-outline-light btn-lg btn-pill">
                            가계부
                        </a>
                    </div>

                    <div class="hero-meta">
                        <div class="meta-item">
                            <div class="meta-k">핵심</div>
                            <div class="meta-v">CRUD 자동화 · grpCd 라우팅 · 통합 로그</div>
                        </div>
                        <div class="meta-item">
                            <div class="meta-k">목표</div>
                            <div class="meta-v">데이터 기반 의사결정 + AI 기능 확장</div>
                        </div>
                    </div>
                </div>

                <!-- Right (visual card) -->
                <div class="hero-right d-none d-lg-block">
                    <div class="glass-card">
                        <div class="glass-top">
                            <div class="glass-dot dot-1"></div>
                            <div class="glass-dot dot-2"></div>
                            <div class="glass-dot dot-3"></div>
                            <div class="glass-title">Today</div>
                            <div class="glass-chip">LIVE</div>
                        </div>

                        <div class="glass-body">
                            <div class="stat-row">
                                <div class="stat-label">이번 달 지출</div>
                                <div class="stat-value">₩ 312,900</div>
                            </div>
                            <div class="stat-row">
                                <div class="stat-label">게시글</div>
                                <div class="stat-value">+ 3</div>
                            </div>
                            <div class="stat-row">
                                <div class="stat-label">KWI 갱신</div>
                                <div class="stat-value">1d ago</div>
                            </div>

                            <div class="mini-sep"></div>

                            <div class="mini-list">
                                <div class="mini-item">
                                    <div class="mini-bullet"></div>
                                    <div class="mini-text">새 글 등록</div>
                                    <div class="mini-time">방금</div>
                                </div>
                                <div class="mini-item">
                                    <div class="mini-bullet"></div>
                                    <div class="mini-text">교통비 12,300원</div>
                                    <div class="mini-time">2m</div>
                                </div>
                                <div class="mini-item">
                                    <div class="mini-bullet"></div>
                                    <div class="mini-text">대시보드 갱신</div>
                                    <div class="mini-time">어제</div>
                                </div>
                            </div>

                            <div class="glass-note">
                                * 샘플 UI (API 연결 전 더미)
                            </div>
                        </div>
                    </div>

                    <div class="hero-orb orb-1"></div>
                    <div class="hero-orb orb-2"></div>
                </div>
            </div>
        </div>
    </div>
</section>

<!-- 주요 기능 -->
<section class="container py-5">
    <div class="section-head">
        <h3 class="section-title">핵심 기능</h3>
        <p class="section-sub">단순 기능 나열이 아니라, “흐름”을 빠르게 만드는 도구들.</p>
    </div>

    <div class="row">
        <div class="col-md-4 mb-4">
            <div class="card card-modern h-100 hover-up">
                <div class="card-body">
                    <div class="icon-badge">✍</div>
                    <h5 class="card-title mt-3">빠른 글쓰기</h5>
                    <p class="card-text">
                        제목 한 줄 입력 → Enter. 입력 비용을 최소화한 게시글 등록 플로우.
                    </p>
                    <a href="/bbs/board/board" class="btn btn-outline-primary btn-sm btn-pill">
                        지금 작성
                    </a>
                </div>
            </div>
        </div>

        <div class="col-md-4 mb-4">
            <div class="card card-modern h-100 hover-up">
                <div class="card-body">
                    <div class="icon-badge icon-badge-2">₩</div>
                    <h5 class="card-title mt-3">가계부 요약</h5>
                    <p class="card-text">
                        이번 달 지출과 카테고리별 통계를 한 화면에. “관리”가 아닌 “조정”을 목표로.
                    </p>
                    <a href="/hhd/household/householdList" class="btn btn-outline-primary btn-sm btn-pill">
                        상세 보기
                    </a>
                </div>
            </div>
        </div>

        <div class="col-md-4 mb-4">
            <div class="card card-modern h-100 hover-up">
                <div class="card-body">
                    <div class="icon-badge icon-badge-3">📊</div>
                    <h5 class="card-title mt-3">K-Welcome Analytics</h5>
                    <p class="card-text">
                        관광 핫스팟과 외국인 친화도 지수를 분석하는 데이터 보드(확장 예정).
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
<section class="bg-soft py-5">
    <div class="container">
        <div class="section-head">
            <h3 class="section-title">최근 활동</h3>
            <p class="section-sub">API 연결 전까지는 더미 UI. 연결되면 로그/알림/피드로 확장.</p>
        </div>

        <div class="timeline">
            <div class="t-item">
                <div class="t-dot"></div>
                <div class="t-card">
                    <div class="t-top">
                        <div class="t-title">새 게시글이 등록되었습니다.</div>
                        <span class="t-badge">NEW</span>
                    </div>
                    <div class="t-sub">게시판 · board</div>
                </div>
            </div>

            <div class="t-item">
                <div class="t-dot"></div>
                <div class="t-card">
                    <div class="t-top">
                        <div class="t-title">가계부: 교통비 12,300원 추가</div>
                        <span class="t-time">방금 전</span>
                    </div>
                    <div class="t-sub">가계부 · household</div>
                </div>
            </div>

            <div class="t-item">
                <div class="t-dot"></div>
                <div class="t-card">
                    <div class="t-top">
                        <div class="t-title">KWI(친화도 지수) 보고서가 갱신되었습니다.</div>
                        <span class="t-time">어제</span>
                    </div>
                    <div class="t-sub">Analytics · kwa</div>
                </div>
            </div>
        </div>
    </div>
</section>

<!-- 페이지 전용 스타일 -->
<style>
    /* ====== 기본 톤 ====== */
    :root{
        --bg:#f7f8fb;
        --card:#ffffff;
        --line:#e5e7eb;
        --text:#0f172a;
        --muted:#6b7280;

        --p:#0d6efd;
        --p2:#6f42c1;
        --p3:#20c997;

        --shadow: 0 18px 48px rgba(24,39,75,.14);
        --shadow2: 0 10px 22px rgba(24,39,75,.10);
        --r: 18px;
    }

    /* 섹션 헤더 */
    .section-head{ margin-bottom: 18px; }
    .section-title{
        font-weight: 800;
        color: var(--text);
        margin: 0 0 6px;
        letter-spacing: -0.3px;
    }
    .section-sub{
        margin: 0;
        color: var(--muted);
        font-size: 14px;
    }

    /* ====== 공통 카드 호버 ====== */
    .hover-up { transition: transform .18s ease, box-shadow .18s ease; }
    .hover-up:hover { transform: translateY(-5px); box-shadow: var(--shadow) !important; }

    .btn-pill{ border-radius: 999px; }

    /* ====== HERO ====== */
    .hero-wrap{
        --outer: 34px;
        margin-block: var(--outer);
    }

    .hero-panel{
        position: relative;
        border-radius: var(--r);
        overflow: hidden;
        box-shadow: var(--shadow);
        background: linear-gradient(135deg, var(--p) 0%, var(--p2) 58%, var(--p3) 120%);
        border: 1px solid rgba(255,255,255,.14);
    }

    /* 배경 장식 */
    .hero-panel::before{
        content:"";
        position:absolute; inset:0;
        background:
            radial-gradient(900px 320px at 12% -15%, rgba(255,255,255,.18), transparent 60%),
            radial-gradient(650px 260px at 92% 120%, rgba(255,255,255,.10), transparent 55%),
            linear-gradient(to bottom, rgba(255,255,255,.06), transparent 35%);
        pointer-events:none;
    }

    .hero-grid{
        position: relative;
        z-index: 1;
        display: grid;
        grid-template-columns: 1.2fr .8fr;
        gap: 18px;
        padding: clamp(22px, 3vw, 30px);
        align-items: stretch;
    }

    .hero-left{
        padding: clamp(18px, 2.6vw, 34px);
        border-radius: calc(var(--r) - 4px);
        background: rgba(255,255,255,.06);
        border: 1px solid rgba(255,255,255,.12);
        backdrop-filter: blur(6px);
    }

    .hero-badges{
        display:flex;
        gap: 8px;
        align-items:center;
        margin-bottom: 14px;
        flex-wrap: wrap;
    }

    .badge-soft{
        display:inline-flex;
        align-items:center;
        padding: 6px 10px;
        border-radius: 999px;
        font-size: 12px;
        font-weight: 700;
        color: rgba(255,255,255,.92);
        background: rgba(255,255,255,.14);
        border: 1px solid rgba(255,255,255,.18);
        letter-spacing: .2px;
    }
    .badge-soft-2{ background: rgba(255,255,255,.10); }
    .badge-soft-3{ background: rgba(255,255,255,.08); }

    .hero-title{
        color:#fff;
        font-weight: 900;
        letter-spacing: -0.6px;
        line-height: 1.08;
        margin: 0 0 10px;
        font-size: clamp(34px, 4.2vw, 54px);
        text-shadow: 0 10px 26px rgba(0,0,0,.20);
    }

    .hero-sub{
        color: rgba(255,255,255,.90);
        font-size: 16px;
        line-height: 1.65;
        margin: 0 0 18px;
        max-width: 560px;
        text-shadow: 0 6px 18px rgba(0,0,0,.18);
    }

    .hero-actions{ margin: 8px 0 18px; }

    .hero-meta{
        display: grid;
        grid-template-columns: 1fr;
        gap: 10px;
        margin-top: 8px;
    }
    .meta-item{
        display:flex;
        gap: 12px;
        align-items:flex-start;
        padding: 10px 12px;
        border-radius: 14px;
        background: rgba(255,255,255,.08);
        border: 1px solid rgba(255,255,255,.12);
    }
    .meta-k{
        min-width: 44px;
        font-size: 12px;
        font-weight: 800;
        color: rgba(255,255,255,.86);
        opacity: .9;
    }
    .meta-v{
        font-size: 13px;
        color: rgba(255,255,255,.92);
        line-height: 1.45;
    }

    /* Right visual */
    .hero-right{
        position: relative;
        padding: 10px;
        display:flex;
        align-items:center;
        justify-content:center;
    }

    .glass-card{
        width: 100%;
        max-width: 360px;
        border-radius: 18px;
        overflow: hidden;
        background: rgba(255,255,255,.14);
        border: 1px solid rgba(255,255,255,.20);
        backdrop-filter: blur(10px);
        box-shadow: 0 24px 60px rgba(0,0,0,.18);
        position: relative;
        z-index: 2;
    }

    .glass-top{
        display:flex;
        align-items:center;
        padding: 12px 14px;
        gap: 8px;
        border-bottom: 1px solid rgba(255,255,255,.18);
    }
    .glass-dot{
        width: 10px; height: 10px; border-radius: 999px;
        background: rgba(255,255,255,.55);
    }
    .dot-1{ opacity:.9; }
    .dot-2{ opacity:.65; }
    .dot-3{ opacity:.45; }

    .glass-title{
        margin-left: 6px;
        font-size: 13px;
        font-weight: 800;
        color: rgba(255,255,255,.90);
        letter-spacing: .2px;
    }
    .glass-chip{
        margin-left: auto;
        font-size: 11px;
        font-weight: 800;
        padding: 4px 10px;
        border-radius: 999px;
        color: rgba(255,255,255,.94);
        background: rgba(0,0,0,.18);
        border: 1px solid rgba(255,255,255,.18);
    }

    .glass-body{ padding: 14px 16px 16px; }
    .stat-row{
        display:flex;
        align-items:baseline;
        justify-content: space-between;
        padding: 8px 0;
        border-bottom: 1px dashed rgba(255,255,255,.18);
    }
    .stat-row:last-of-type{ border-bottom:none; }
    .stat-label{
        font-size: 12px;
        color: rgba(255,255,255,.85);
        font-weight: 700;
    }
    .stat-value{
        font-size: 16px;
        color: rgba(255,255,255,.96);
        font-weight: 900;
        letter-spacing: -0.2px;
    }

    .mini-sep{
        height: 1px;
        background: rgba(255,255,255,.18);
        margin: 12px 0;
    }

    .mini-list{ display:flex; flex-direction:column; gap: 8px; }
    .mini-item{
        display:flex; align-items:center; gap: 10px;
        padding: 8px 10px;
        border-radius: 12px;
        background: rgba(255,255,255,.08);
        border: 1px solid rgba(255,255,255,.12);
    }
    .mini-bullet{
        width: 8px; height: 8px; border-radius: 999px;
        background: rgba(255,255,255,.80);
    }
    .mini-text{
        font-size: 12px;
        font-weight: 800;
        color: rgba(255,255,255,.92);
    }
    .mini-time{
        margin-left:auto;
        font-size: 11px;
        color: rgba(255,255,255,.70);
        font-weight: 700;
    }
    .glass-note{
        margin-top: 10px;
        font-size: 11px;
        color: rgba(255,255,255,.70);
    }

    /* Orbs */
    .hero-orb{
        position:absolute;
        border-radius: 999px;
        filter: blur(0px);
        opacity: .55;
        z-index: 1;
    }
    .orb-1{
        width: 160px; height: 160px;
        right: 10px; top: -30px;
        background: rgba(255,255,255,.18);
        box-shadow: 0 0 0 1px rgba(255,255,255,.12) inset;
    }
    .orb-2{
        width: 220px; height: 220px;
        right: -60px; bottom: -70px;
        background: rgba(0,0,0,.14);
        box-shadow: 0 0 0 1px rgba(255,255,255,.10) inset;
    }

    /* ====== Cards ====== */
    .card-modern{
        border: 1px solid var(--line);
        border-radius: var(--r);
        box-shadow: var(--shadow2);
        overflow: hidden;
        background: var(--card);
    }
    .card-modern .card-title{
        font-weight: 800;
        color: var(--text);
        letter-spacing: -0.2px;
    }
    .card-modern .card-text{
        color: var(--muted);
        font-size: 14px;
        line-height: 1.6;
        margin-bottom: 14px;
    }

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

    /* ====== Timeline ====== */
    .bg-soft{ background: #f3f6fb; }

    .timeline{
        position: relative;
        margin-top: 16px;
        padding-left: 14px;
    }
    .timeline::before{
        content:"";
        position:absolute;
        left: 6px;
        top: 0;
        bottom: 0;
        width: 2px;
        background: rgba(15,23,42,.10);
        border-radius: 999px;
    }
    .t-item{
        position: relative;
        display:flex;
        gap: 12px;
        margin-bottom: 14px;
    }
    .t-dot{
        position:absolute;
        left: -2px;
        top: 14px;
        width: 14px; height: 14px;
        border-radius: 999px;
        background: #fff;
        border: 2px solid rgba(13,110,253,.55);
        box-shadow: 0 8px 20px rgba(13,110,253,.12);
    }
    .t-card{
        margin-left: 12px;
        flex: 1;
        background: #fff;
        border: 1px solid rgba(15,23,42,.10);
        border-radius: 16px;
        padding: 12px 14px;
        box-shadow: 0 10px 22px rgba(24,39,75,.08);
    }
    .t-top{
        display:flex;
        align-items:center;
        gap: 10px;
    }
    .t-title{
        font-weight: 800;
        color: var(--text);
        font-size: 14px;
        letter-spacing: -0.15px;
    }
    .t-sub{
        margin-top: 4px;
        font-size: 12px;
        color: var(--muted);
    }
    .t-badge{
        margin-left:auto;
        font-size: 11px;
        font-weight: 900;
        padding: 4px 10px;
        border-radius: 999px;
        color: #0b2a66;
        background: rgba(13,110,253,.12);
        border: 1px solid rgba(13,110,253,.18);
    }
    .t-time{
        margin-left:auto;
        font-size: 12px;
        font-weight: 800;
        color: rgba(15,23,42,.55);
    }

    /* ====== Responsive ====== */
    @media (max-width: 991px){
        .hero-grid{ grid-template-columns: 1fr; }
        .hero-left{ background: rgba(255,255,255,.08); }
    }
    @media (max-width: 576px){
        .hero-title{ font-size: 34px; }
        .hero-sub{ font-size: 14px; }
        .hero-actions .btn{ width: 100%; }
        .hero-actions .btn + .btn{ margin-left: 0 !important; margin-top: 10px; }
    }
</style>
