<!DOCTYPE html>
<html lang="ko">
    <head>
        <meta charset="UTF-8" />
        <title>Jeong JiGyun – Full-Stack System Architect & AI-Oriented Developer</title>
        <meta name="viewport" content="width=device-width, initial-scale=1" />
        <style>
            :root {
                --bg: #050816;
                --bg-alt: #0b1020;
                --card: #111827;
                --card-soft: #020617;
                --accent: #38bdf8;
                --accent-soft: rgba(56, 189, 248, 0.1);
                --accent-2: #a855f7;
                --text: #e5e7eb;
                --muted: #9ca3af;
                --border: #1f2937;
                --radius-lg: 18px;
                --radius-xl: 24px;
                --shadow-soft: 0 24px 60px rgba(0, 0, 0, 0.75);
                --max-width: 1040px;
            }

            * {
                box-sizing: border-box;
            }

            body {
                margin: 0;
                font-family: system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI",
                    sans-serif;
                background:
                    radial-gradient(circle at top left, #1d283a 0, transparent 55%),
                    radial-gradient(circle at bottom right, #020617 0, transparent 55%),
                    var(--bg);
                color: var(--text);
                -webkit-font-smoothing: antialiased;
            }

            .page {
                min-height: 100vh;
                display: flex;
                align-items: flex-start;
                justify-content: center;
                padding: 32px 16px 48px;
            }

            .shell {
                width: 100%;
                max-width: var(--max-width);
                background: radial-gradient(circle at top, #020617 0, #020617 28%, #020617 50%, #020617 100%);
                border-radius: 28px;
                border: 1px solid rgba(148, 163, 184, 0.25);
                box-shadow: var(--shadow-soft);
                padding: 28px 24px 32px;
                position: relative;
                overflow: hidden;
            }

            @media (min-width: 900px) {
                .shell {
                    padding: 32px 32px 40px;
                }
            }

            .shell::before {
                content: "";
                position: absolute;
                inset: -40%;
                background:
                    radial-gradient(circle at 10% 0%, rgba(56, 189, 248, 0.08) 0, transparent 48%),
                    radial-gradient(circle at 90% 100%, rgba(168, 85, 247, 0.08) 0, transparent 50%);
                opacity: 1;
                pointer-events: none;
            }

            .shell-inner {
                position: relative;
                z-index: 1;
            }

            header.hero {
                display: flex;
                flex-direction: column;
                gap: 18px;
                margin-bottom: 28px;
            }

            @media (min-width: 800px) {
                header.hero {
                    flex-direction: row;
                    align-items: center;
                    justify-content: space-between;
                    gap: 32px;
                    margin-bottom: 36px;
                }
            }

            .hero-main {
                flex: 1;
            }

            .hero-kicker {
                display: inline-flex;
                align-items: center;
                gap: 6px;
                padding: 4px 10px;
                border-radius: 999px;
                background: rgba(15, 23, 42, 0.9);
                border: 1px solid rgba(148, 163, 184, 0.3);
                font-size: 11px;
                text-transform: uppercase;
                letter-spacing: 0.12em;
                color: var(--muted);
            }

            .hero-kicker-dot {
                width: 8px;
                height: 8px;
                border-radius: 999px;
                background: radial-gradient(circle, #22c55e 0, #16a34a 40%, #052e16 100%);
                box-shadow: 0 0 16px rgba(34, 197, 94, 0.7);
            }

            h1 {
                margin: 8px 0 4px;
                font-size: clamp(28px, 4vw, 34px);
                letter-spacing: 0.02em;
            }

            h1 span.highlight {
                background-image: linear-gradient(120deg, #38bdf8, #a855f7);
                -webkit-background-clip: text;
                background-clip: text;
                color: transparent;
            }

            .hero-role {
                font-size: 14px;
                color: var(--muted);
                text-transform: uppercase;
                letter-spacing: 0.16em;
                margin-bottom: 10px;
            }

            .hero-quote {
                font-size: 14px;
                color: #d1d5db;
                border-left: 3px solid rgba(148, 163, 184, 0.6);
                padding-left: 10px;
                margin: 0 0 12px;
            }

            .hero-desc {
                font-size: 14px;
                color: var(--muted);
                line-height: 1.6;
                max-width: 620px;
            }

            .hero-meta {
                display: grid;
                grid-template-columns: repeat(auto-fit, minmax(120px, 1fr));
                gap: 10px;
                margin-top: 14px;
            }

            .badge {
                display: inline-flex;
                align-items: center;
                gap: 6px;
                padding: 5px 10px;
                border-radius: 999px;
                background: rgba(15, 23, 42, 0.95);
                border: 1px solid rgba(55, 65, 81, 0.9);
                font-size: 11px;
                color: #e5e7eb;
            }

            .badge-dot {
                width: 7px;
                height: 7px;
                border-radius: 999px;
                background: var(--accent);
            }

            .hero-side {
                width: 100%;
                max-width: 260px;
                margin-top: 8px;
            }

            @media (min-width: 800px) {
                .hero-side {
                    margin-top: 0;
                }
            }

            .hero-card {
                background: radial-gradient(circle at top, #1f2937 0, #020617 60%);
                border-radius: 22px;
                border: 1px solid rgba(148, 163, 184, 0.25);
                padding: 14px 14px 16px;
                position: relative;
                overflow: hidden;
            }

            .hero-card::before {
                content: "";
                position: absolute;
                inset: -50%;
                background: radial-gradient(circle at 20% 0%, rgba(56, 189, 248, 0.22) 0, transparent 58%);
                opacity: 0.6;
                pointer-events: none;
            }

            .hero-card-inner {
                position: relative;
                z-index: 1;
            }

            .hero-card-title {
                font-size: 12px;
                text-transform: uppercase;
                letter-spacing: 0.15em;
                color: #9ca3af;
                margin-bottom: 8px;
            }

            .hero-card-name {
                font-size: 16px;
                font-weight: 600;
                margin-bottom: 3px;
            }

            .hero-card-role {
                font-size: 12px;
                color: #cbd5f5;
                margin-bottom: 10px;
            }

            .hero-card-chip-row {
                display: flex;
                flex-wrap: wrap;
                gap: 8px;
                margin-bottom: 10px;
            }

            .chip {
                padding: 4px 9px;
                border-radius: 999px;
                border: 1px solid rgba(148, 163, 184, 0.4);
                font-size: 11px;
                background: rgba(15, 23, 42, 0.85);
                color: #e5e7eb;
            }

            .hero-card-footer {
                display: flex;
                justify-content: space-between;
                align-items: center;
                font-size: 11px;
                color: #9ca3af;
            }

            .hero-card-pill {
                padding: 4px 8px;
                border-radius: 999px;
                background: rgba(15, 23, 42, 0.9);
                border: 1px solid rgba(56, 189, 248, 0.5);
                color: #bae6fd;
                font-size: 10px;
                text-transform: uppercase;
                letter-spacing: 0.16em;
            }

            main {
                display: grid;
                grid-template-columns: minmax(0, 1.6fr) minmax(0, 1.15fr);
                gap: 18px;
            }

            @media (max-width: 899px) {
                main {
                    grid-template-columns: minmax(0, 1fr);
                }
            }

            section {
                border-radius: var(--radius-lg);
                background: linear-gradient(135deg, rgba(15, 23, 42, 0.96), rgba(15, 23, 42, 0.96));
                border: 1px solid var(--border);
                padding: 16px 16px 18px;
                margin-bottom: 12px;
            }

            section.section-accent {
                background: radial-gradient(circle at 0 0, rgba(56, 189, 248, 0.12) 0, rgba(15, 23, 42, 0.98) 55%);
                border-color: rgba(56, 189, 248, 0.6);
            }

            section.section-soft {
                background: radial-gradient(circle at 100% 0, rgba(168, 85, 247, 0.16) 0, rgba(15, 23, 42, 0.98) 60%);
                border-color: rgba(55, 65, 81, 0.9);
            }

            section h2 {
                font-size: 15px;
                margin: 0 0 10px;
                text-transform: uppercase;
                letter-spacing: 0.18em;
                color: #9ca3af;
            }

            section h3 {
                font-size: 14px;
                margin: 12px 0 6px;
                color: #e5e7eb;
            }

            p {
                margin: 0 0 6px;
                font-size: 13px;
                line-height: 1.7;
                color: var(--muted);
            }

            ul {
                margin: 4px 0 8px 18px;
                padding: 0;
            }

            li {
                font-size: 13px;
                color: var(--muted);
                line-height: 1.6;
                margin-bottom: 3px;
            }

            .tag-row {
                display: flex;
                flex-wrap: wrap;
                gap: 6px;
                margin-top: 2px;
            }

            .tag {
                padding: 3px 7px;
                border-radius: 999px;
                border: 1px solid rgba(75, 85, 99, 0.9);
                font-size: 11px;
                color: #e5e7eb;
                background: rgba(15, 23, 42, 0.96);
            }

            .tag.tag-accent {
                border-color: rgba(56, 189, 248, 0.85);
                color: #e0f2fe;
                background: rgba(8, 47, 73, 0.9);
            }

            .grid-2 {
                display: grid;
                grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
                gap: 10px;
                margin-top: 4px;
            }

            .pill-list {
                display: flex;
                flex-wrap: wrap;
                gap: 6px;
                margin-top: 4px;
            }

            .pill {
                padding: 4px 8px;
                border-radius: 999px;
                font-size: 11px;
                background: rgba(15, 23, 42, 0.95);
                border: 1px solid rgba(55, 65, 81, 0.9);
                color: #e5e7eb;
            }

            .pill-ghost {
                background: rgba(15, 23, 42, 0.8);
                border-style: dashed;
            }

            .module-list {
                margin-top: 4px;
            }

            .module-item {
                padding: 7px 8px;
                border-radius: 10px;
                background: rgba(15, 23, 42, 0.95);
                border: 1px solid rgba(31, 41, 55, 0.95);
                margin-bottom: 4px;
            }

            .module-title {
                font-size: 13px;
                font-weight: 600;
                color: #e5e7eb;
                margin-bottom: 2px;
            }

            .module-meta {
                font-size: 11px;
                color: #9ca3af;
                margin-bottom: 2px;
            }

            .module-desc {
                font-size: 12px;
                color: #9ca3af;
            }

            .architecture-wrapper {
                background: radial-gradient(circle at top, rgba(15, 23, 42, 0.98) 0, rgba(15, 23, 42, 0.98) 60%);
                border-radius: 14px;
                border: 1px solid rgba(55, 65, 81, 0.9);
                padding: 10px;
                overflow: hidden;
            }

            .architecture-caption {
                font-size: 11px;
                color: #9ca3af;
                margin-top: 6px;
            }

            svg.arch-diagram {
                width: 100%;
                height: auto;
                display: block;
            }

            .contact-row {
                display: flex;
                flex-wrap: wrap;
                gap: 8px;
                margin-top: 6px;
            }

            .contact-link {
                padding: 6px 10px;
                border-radius: 999px;
                font-size: 12px;
                text-decoration: none;
                color: #e5e7eb;
                border: 1px solid rgba(55, 65, 81, 0.9);
                background: rgba(15, 23, 42, 0.96);
            }

            .contact-link-accent {
                border-color: rgba(56, 189, 248, 0.85);
                background: rgba(8, 47, 73, 0.96);
                color: #e0f2fe;
            }

            @media print {
                body {
                    background: #ffffff;
                    color: #111827;
                }

                .page {
                    padding: 0;
                }

                .shell {
                    box-shadow: none;
                    border-radius: 0;
                }

                .shell::before {
                    display: none;
                }

                section,
                .hero-card {
                    background: #ffffff !important;
                    border-color: #d1d5db !important;
                }

                .hero-kicker,
                .badge,
                .chip,
                .tag,
                .pill,
                .contact-link {
                    background: #ffffff !important;
                }
            }
        </style>
    </head>
    <body>
        <div class="page">
            <div class="shell">
                <div class="shell-inner">
                    <header class="hero">
                        <div class="hero-main">
                            <div class="hero-kicker">
                                <span class="hero-kicker-dot"></span>
                                <span>Full-Stack System Architect & AI-Oriented Developer</span>
                            </div>
                            <h1>
                                <span class="highlight">Jeong&nbsp;JiGyun</span>
                            </h1>
                            <div class="hero-role">connect platform · personal os builder</div>
                            <p class="hero-quote">
                                “레거시와 혼돈을 구조로 바꾸는 풀스택 설계자”
                            </p>
                            <p class="hero-desc">
                                eGovFrame + Spring MVC + MyBatis 기반 백엔드와 Next.js + TypeScript 기반
                                프론트를 동시에 다루며,&nbsp;일기·가계부·쇼핑몰·예약·게시판·채팅·푸시·지도·AI까지
                                아우르는 통합 플랫폼 <strong>CONNECT</strong>를 설계·구현해 온 풀스택
                                개발자입니다. 반복 작업을 없애기 위한 내부 도구(JavaGen/ReactGen)와
                                프로젝트 전역 규칙을 설계하며,&nbsp;지금은 이 기반 위에 AI/머신러닝을 올려
                                “스스로 진화하는 서비스”를 만드는 것을 목표로 하고 있습니다.
                            </p>
                            <div class="hero-meta">
                                <div class="badge">
                                    <span class="badge-dot"></span>
                                    <span>10+ years Java · Spring</span>
                                </div>
                                <div class="badge">
                                    <span class="badge-dot"></span>
                                    <span>Full-stack: eGov + Next.js/TS</span>
                                </div>
                                <div class="badge">
                                    <span class="badge-dot"></span>
                                    <span>System design &amp; refactoring</span>
                                </div>
                            </div>
                        </div>
                        <aside class="hero-side">
                            <div class="hero-card">
                                <div class="hero-card-inner">
                                    <div class="hero-card-title">profile snapshot</div>
                                    <div class="hero-card-name">정지균 Jeong&nbsp;JiGyun</div>
                                    <div class="hero-card-role">
                                        Full-Stack System Architect · AI-Oriented Developer
                                    </div>
                                    <div class="hero-card-chip-row">
                                        <div class="chip">Java · Spring MVC · eGovFrame</div>
                                        <div class="chip">MyBatis · MySQL</div>
                                        <div class="chip">Next.js · TypeScript(strict)</div>
                                        <div class="chip">DevOps · Naver Cloud · Cloudflare</div>
                                    </div>
                                    <div class="hero-card-footer">
                                        <div>Flagship: CONNECT 플랫폼</div>
                                        <div class="hero-card-pill">SYSTEM FIRST · CODE SECOND</div>
                                    </div>
                                </div>
                            </div>
                        </aside>
                    </header>

                    <main>
                        <!-- LEFT COLUMN -->
                        <div>
                            <section class="section-accent">
                                <h2>ABOUT</h2>
                                <p>
                                    저는 기능 단위 개발자가 아니라, <strong>“서비스 전체의 구조”를 먼저
                                    설계하는 개발자</strong>입니다. 테이블 하나를 만들 때도
                                    <em>회원/권한 → 데이터 구조 → 관리자 화면 → 운영 방식</em>까지 연결해서
                                    바라보고, 공통 컬럼·라우팅·응답 규격을 프로젝트 전역 규칙으로 통일하는
                                    것에 익숙합니다.
                                </p>
                                <p>
                                    혼자서도 한 회사 분량의 웹 서비스를 설계·구현할 수 있는 것을 목표로 했고,
                                    그 결과물로 <strong>개인 OS를 지향하는 CONNECT 플랫폼</strong>을
                                    구축해 왔습니다. 앞으로는 이 구조 위에 AI/ML을 얹어,
                                    <strong>“사용자 데이터와 함께 진화하는 서비스”</strong>를 만드는 것이
                                    다음 단계의 목표입니다.
                                </p>
                            </section>

                            <section>
                                <h2>DEVELOPER IDENTITY</h2>
                                <h3>한 줄 정의</h3>
                                <p>
                                    <strong>“망가진 구조를 다시 세우고, 하나의 일관된 시스템으로 통합하는
                                    풀스택 아키텍트”</strong>
                                </p>

                                <h3>강점</h3>
                                <ul>
                                    <li>
                                        <strong>시스템 관점 설계</strong> – 기능이 아니라 구조 먼저. 회원·권한·데이터·운영을
                                        하나의 그림으로 본 뒤, 모듈을 배치합니다.
                                    </li>
                                    <li>
                                        <strong>자가 자동화</strong> – 반복되는 CRUD·화면 작업은
                                        JavaGen/ReactGen 내부 도구로 자동화하여 개발 속도와 일관성을 동시에
                                        확보합니다.
                                    </li>
                                    <li>
                                        <strong>규칙·가드레일 설계</strong> – TypeScript strict, ESLint
                                        no-unsafe-*와 같은 난이도 높은 규칙을 프로젝트에 맞게 해석하고,
                                        재발 방지 규칙으로 정리하여 전체 코드베이스에 적용합니다.
                                    </li>
                                </ul>

                                <h3>현재 보완 중인 영역</h3>
                                <ul>
                                    <li>자동화 테스트(유닛/통합/E2E) 체계화</li>
                                    <li>Docker/Kubernetes 기반 배포·운영, 모니터링 스택</li>
                                    <li>머신러닝/딥러닝 모델 학습·배포 전체 파이프라인 경험</li>
                                </ul>
                            </section>

                            <section>
                                <h2>TECH STACK</h2>
                                <div class="grid-2">
                                    <div>
                                        <h3>Backend</h3>
                                        <div class="tag-row">
                                            <span class="tag tag-accent">Java · Spring MVC 4.x</span>
                                            <span class="tag">eGovFrame</span>
                                            <span class="tag">MyBatis(XML, CommonDao)</span>
                                            <span class="tag">RESTful API 설계</span>
                                            <span class="tag">세션 기반 인증 · JWT 설계 경험</span>
                                            <span class="tag">MySQL · ERD · 인덱싱</span>
                                        </div>
                                    </div>
                                    <div>
                                        <h3>Frontend</h3>
                                        <div class="tag-row">
                                            <span class="tag tag-accent">React · Next.js</span>
                                            <span class="tag">TypeScript(strict)</span>
                                            <span class="tag">ESLint (typescript-eslint strict)</span>
                                            <span class="tag">React Query</span>
                                            <span class="tag">모바일 우선 UI</span>
                                        </div>
                                    </div>
                                </div>

                                <div class="grid-2">
                                    <div>
                                        <h3>Infra / DevOps</h3>
                                        <div class="tag-row">
                                            <span class="tag">Naver Cloud (Tomcat · MySQL)</span>
                                            <span class="tag">Cloudflare Pages · Workers</span>
                                            <span class="tag">Cloudflare Tunnel</span>
                                            <span class="tag">GitHub Actions (빌드·배포 자동화 시도)</span>
                                        </div>
                                    </div>
                                    <div>
                                        <h3>Tools &amp; Automation</h3>
                                        <div class="tag-row">
                                            <span class="tag tag-accent">JavaGen – Spring CRUD 코드 생성</span>
                                            <span class="tag tag-accent">ReactGen – 목록/상세/폼 자동 생성</span>
                                            <span class="tag">공통 규칙 기반 템플릿 설계</span>
                                            <span class="tag">내부 생산성 도구 개발</span>
                                        </div>
                                    </div>
                                </div>

                                <h3>AI &amp; Data (진행 중)</h3>
                                <p>
                                    Python 기반 크롤링/텍스트 전처리를 수행하며, 머신러닝/딥러닝 수학 기초를
                                    학습 중입니다. 텍스트 분석, 감정 분석, 추천 시스템을 실제 서비스에
                                    연결하는 것을 다음 목표로 두고 있습니다.
                                </p>
                                <div class="pill-list">
                                    <span class="pill">Python · pandas · BeautifulSoup · Selenium</span>
                                    <span class="pill pill-ghost">텍스트 분석 · 감정 분석 입문</span>
                                    <span class="pill pill-ghost">개인 데이터 기반 추천/인사이트</span>
                                </div>
                            </section>
                        </div>

                        <!-- RIGHT COLUMN -->
                        <div>
                            <section class="section-soft">
                                <h2>FLAGSHIP PROJECT – CONNECT</h2>
                                <p>
                                    <strong>CONNECT</strong>는 하나의 계정과 하나의 그룹(<code>grpCd</code>) 아래에서
                                    <strong>일기, 할일, 가계부, 예약, 쇼핑몰, 게시판, 채팅, 푸시, 지도, AI</strong>까지
                                    확장 가능한 <strong>개인 OS 지향 통합 플랫폼</strong>입니다. 백엔드와
                                    관리자 웹, 모바일 프론트, 일부 인프라까지 전 영역을 직접 설계·구현하고
                                    있습니다.
                                </p>

                                <h3>핵심 공통 개념</h3>
                                <ul>
                                    <li>
                                        <strong>grpCd 기반 멀티 그룹 라우팅</strong> – 하나의 시스템에서 여러
                                        그룹/서비스를 동시에 운영할 수 있도록 설계.
                                    </li>
                                    <li>
                                        <strong>공통 감사 컬럼</strong> – <code>CREATED_DT, CREATED_BY,
                                        UPDATED_DT, UPDATED_BY</code>를 모든 테이블에 통일 적용.
                                    </li>
                                    <li>
                                        <strong>API Envelope 규약</strong> – <code>{ ok, result, error }</code> 형태
                                        통일, React/TS 클라이언트에서 안전 언래핑.
                                    </li>
                                </ul>

                                <h3>주요 모듈</h3>
                                <div class="module-list">
                                    <div class="module-item">
                                        <div class="module-title">Diary · 일기 모듈</div>
                                        <div class="module-meta">CKEditor · 감정/요약 AI 확장 타깃</div>
                                        <div class="module-desc">
                                            WYSIWYG 에디터 기반 일기 작성/관리. 향후 LLM을 활용한 하루/월간 요약과
                                            감정 분석 기능을 붙이기 위해 텍스트/메타데이터 구조를 설계했습니다.
                                        </div>
                                    </div>
                                    <div class="module-item">
                                        <div class="module-title">Ledger · 가계부 모듈</div>
                                        <div class="module-meta">월 매트릭스 UI · 지출 패턴 분석</div>
                                        <div class="module-desc">
                                            월 단위 매트릭스 UI를 가진 모바일 우선 가계부. 카테고리/메모/금액
                                            데이터를 기반으로, 지출 패턴 분석·이상치 탐지·카테고리 자동 분류
                                            모델을 연결할 계획입니다.
                                        </div>
                                    </div>
                                    <div class="module-item">
                                        <div class="module-title">Reservation · 예약 모듈</div>
                                        <div class="module-meta">
                                            모바일 카드/PC 테이블 동시 지원 · TS strict 규칙 레퍼런스
                                        </div>
                                        <div class="module-desc">
                                            날짜·시간 슬롯 기반 예약 시스템. TypeScript strict + React Query 규칙을
                                            가장 정교하게 적용한 모듈로, 훅 시그니처/쿼리키/DTO 규약이 잘 정리되어
                                            있습니다.
                                        </div>
                                    </div>
                                    <div class="module-item">
                                        <div class="module-title">E-Commerce · 쇼핑몰 모듈</div>
                                        <div class="module-meta">
                                            TB_PRODUCT · 주문/결제/환불(TB_PAYMENT_REFUND) 설계
                                        </div>
                                        <div class="module-desc">
                                            브랜드/모델/가격/평점 등을 가진 상품 테이블과, 결제·환불 프로세스를
                                            포함한 커머스 백엔드. 나중에 가격/수요 예측, 리뷰 기반 요약·추천
                                            모델과 자연스럽게 연결될 수 있도록 설계했습니다.
                                        </div>
                                    </div>
                                    <div class="module-item">
                                        <div class="module-title">Chat &amp; AI Chat · 채팅 모듈</div>
                                        <div class="module-meta">
                                            STOMP · <code>/topic/chat-ai/{room}</code> 구조 설계
                                        </div>
                                        <div class="module-desc">
                                            채팅방 생성/삭제와 메시지 저장, 그리고 AI 비서를 방 단위로 붙일 수 있는
                                            STOMP 토픽/엔드포인트 구조를 설계했습니다. 이후 OpenAI/자체 모델과
                                            연결하여 “우리 서비스 안의 AI”를 구현할 기반입니다.
                                        </div>
                                    </div>
                                </div>
                            </section>

                            <section>
                                <h2>SYSTEM ARCHITECTURE</h2>
                                <div class="architecture-wrapper">
                                    <!-- CONNECT SYSTEM ARCHITECTURE DIAGRAM (INLINE SVG) -->
                                    <svg
                                        class="arch-diagram"
                                        viewBox="0 0 960 540"
                                        xmlns="http://www.w3.org/2000/svg"
                                        role="img"
                                    >
                                        <title>CONNECT System Architecture Diagram</title>
                                        <desc>
                                            React/Next.js 프론트엔드와 Spring/eGovFrame 백엔드, MySQL 데이터베이스,
                                            Python AI 서비스, Naver Cloud와 Cloudflare 인프라를 층별로 표현한
                                            다이어그램입니다.
                                        </desc>

                                        <!-- Background -->
                                        <defs>
                                            <linearGradient id="bgGrad" x1="0" y1="0" x2="1" y2="1">
                                                <stop offset="0" stop-color="#020617" />
                                                <stop offset="1" stop-color="#020617" />
                                            </linearGradient>
                                            <linearGradient id="borderGrad" x1="0" y1="0" x2="1" y2="0">
                                                <stop offset="0" stop-color="#38bdf8" />
                                                <stop offset="1" stop-color="#a855f7" />
                                            </linearGradient>
                                        </defs>

                                        <rect
                                            x="0"
                                            y="0"
                                            width="960"
                                            height="540"
                                            fill="url(#bgGrad)"
                                            stroke="#111827"
                                        />

                                        <!-- Title -->
                                        <text
                                            x="480"
                                            y="40"
                                            fill="#e5e7eb"
                                            font-size="18"
                                            font-family="system-ui, -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif"
                                            text-anchor="middle"
                                        >
                                            CONNECT – System Architecture Overview
                                        </text>

                                        <!-- Frontend Box -->
                                        <rect
                                            x="80"
                                            y="80"
                                            width="800"
                                            height="80"
                                            rx="12"
                                            fill="#020617"
                                            stroke="#38bdf8"
                                            stroke-width="1.4"
                                        />
                                        <text
                                            x="100"
                                            y="110"
                                            fill="#bae6fd"
                                            font-size="13"
                                            font-family="system-ui, -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif"
                                        >
                                            Frontend (Mobile-first)
                                        </text>
                                        <text
                                            x="100"
                                            y="130"
                                            fill="#9ca3af"
                                            font-size="11"
                                            font-family="system-ui, -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif"
                                        >
                                            Next.js · React · TypeScript(strict) · React Query · Tailored UI for CONNECT
                                        </text>

                                        <!-- Frontend sub-boxes -->
                                        <rect
                                            x="360"
                                            y="96"
                                            width="150"
                                            height="48"
                                            rx="8"
                                            fill="#020617"
                                            stroke="#1f2937"
                                        />
                                        <text
                                            x="435"
                                            y="118"
                                            fill="#e5e7eb"
                                            font-size="11"
                                            text-anchor="middle"
                                            font-family="system-ui, -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif"
                                        >
                                            Mobile Web · SPA
                                        </text>
                                        <text
                                            x="435"
                                            y="132"
                                            fill="#9ca3af"
                                            font-size="10"
                                            text-anchor="middle"
                                            font-family="system-ui, -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif"
                                        >
                                            Diary · Ledger · Reservation · Shop
                                        </text>

                                        <rect
                                            x="530"
                                            y="96"
                                            width="150"
                                            height="48"
                                            rx="8"
                                            fill="#020617"
                                            stroke="#1f2937"
                                        />
                                        <text
                                            x="605"
                                            y="118"
                                            fill="#e5e7eb"
                                            font-size="11"
                                            text-anchor="middle"
                                            font-family="system-ui, -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif"
                                        >
                                            Admin / Backoffice
                                        </text>
                                        <text
                                            x="605"
                                            y="132"
                                            fill="#9ca3af"
                                            font-size="10"
                                            text-anchor="middle"
                                            font-family="system-ui, -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif"
                                        >
                                            JSP · Bootstrap · Management UI
                                        </text>

                                        <!-- API Layer Box -->
                                        <rect
                                            x="80"
                                            y="190"
                                            width="800"
                                            height="80"
                                            rx="12"
                                            fill="#020617"
                                            stroke="#38bdf8"
                                            stroke-width="1.4"
                                            stroke-dasharray="4 4"
                                        />
                                        <text
                                            x="100"
                                            y="220"
                                            fill="#bae6fd"
                                            font-size="13"
                                            font-family="system-ui, -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif"
                                        >
                                            API Layer
                                        </text>
                                        <text
                                            x="100"
                                            y="240"
                                            fill="#9ca3af"
                                            font-size="11"
                                            font-family="system-ui, -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif"
                                        >
                                            RESTful JSON APIs · { ok, result, error } Envelope · grpCd-based Routing
                                        </text>

                                        <!-- Backend Box -->
                                        <rect
                                            x="80"
                                            y="300"
                                            width="480"
                                            height="160"
                                            rx="14"
                                            fill="#020617"
                                            stroke="url(#borderGrad)"
                                            stroke-width="1.6"
                                        />
                                        <text
                                            x="100"
                                            y="330"
                                            fill="#e5e7eb"
                                            font-size="13"
                                            font-family="system-ui, -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif"
                                        >
                                            Backend – Spring MVC / eGovFrame
                                        </text>
                                        <text
                                            x="100"
                                            y="348"
                                            fill="#9ca3af"
                                            font-size="11"
                                            font-family="system-ui, -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif"
                                        >
                                            Java · Spring MVC 4.x · eGovFrame · MyBatis(XML) · CommonDao
                                        </text>

                                        <!-- Backend modules -->
                                        <rect
                                            x="100"
                                            y="360"
                                            width="140"
                                            height="40"
                                            rx="8"
                                            fill="#020617"
                                            stroke="#1f2937"
                                        />
                                        <text
                                            x="170"
                                            y="380"
                                            fill="#e5e7eb"
                                            font-size="10"
                                            text-anchor="middle"
                                            font-family="system-ui, -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif"
                                        >
                                            User · Auth · Group
                                        </text>

                                        <rect
                                            x="260"
                                            y="360"
                                            width="140"
                                            height="40"
                                            rx="8"
                                            fill="#020617"
                                            stroke="#1f2937"
                                        />
                                        <text
                                            x="330"
                                            y="374"
                                            fill="#e5e7eb"
                                            font-size="10"
                                            text-anchor="middle"
                                            font-family="system-ui, -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif"
                                        >
                                            Diary · Task · Ledger
                                        </text>
                                        <text
                                            x="330"
                                            y="388"
                                            fill="#9ca3af"
                                            font-size="9"
                                            text-anchor="middle"
                                            font-family="system-ui, -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif"
                                        >
                                            Personal OS Core
                                        </text>

                                        <rect
                                            x="100"
                                            y="410"
                                            width="140"
                                            height="40"
                                            rx="8"
                                            fill="#020617"
                                            stroke="#1f2937"
                                        />
                                        <text
                                            x="170"
                                            y="432"
                                            fill="#e5e7eb"
                                            font-size="10"
                                            text-anchor="middle"
                                            font-family="system-ui, -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif"
                                        >
                                            Reservation · Map
                                        </text>

                                        <rect
                                            x="260"
                                            y="410"
                                            width="140"
                                            height="40"
                                            rx="8"
                                            fill="#020617"
                                            stroke="#1f2937"
                                        />
                                        <text
                                            x="330"
                                            y="426"
                                            fill="#e5e7eb"
                                            font-size="10"
                                            text-anchor="middle"
                                            font-family="system-ui, -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif"
                                        >
                                            E-Commerce · Payment
                                        </text>
                                        <text
                                            x="330"
                                            y="440"
                                            fill="#9ca3af"
                                            font-size="9"
                                            text-anchor="middle"
                                            font-family="system-ui, -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif"
                                        >
                                            Product · Order · Refund
                                        </text>

                                        <!-- Generator box -->
                                        <rect
                                            x="420"
                                            y="340"
                                            width="120"
                                            height="80"
                                            rx="10"
                                            fill="#020617"
                                            stroke="#38bdf8"
                                            stroke-width="1.2"
                                            stroke-dasharray="3 3"
                                        />
                                        <text
                                            x="480"
                                            y="362"
                                            fill="#e5e7eb"
                                            font-size="10"
                                            text-anchor="middle"
                                            font-family="system-ui, -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif"
                                        >
                                            JavaGen · ReactGen
                                        </text>
                                        <text
                                            x="480"
                                            y="380"
                                            fill="#9ca3af"
                                            font-size="9"
                                            text-anchor="middle"
                                            font-family="system-ui, -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif"
                                        >
                                            CRUD · JSP · React
                                        </text>
                                        <text
                                            x="480"
                                            y="394"
                                            fill="#9ca3af"
                                            font-size="9"
                                            text-anchor="middle"
                                            font-family="system-ui, -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif"
                                        >
                                            Code Generation Engine
                                        </text>

                                        <!-- DB box -->
                                        <rect
                                            x="590"
                                            y="300"
                                            width="290"
                                            height="90"
                                            rx="12"
                                            fill="#020617"
                                            stroke="#38bdf8"
                                            stroke-width="1.3"
                                        />
                                        <text
                                            x="610"
                                            y="326"
                                            fill="#e5e7eb"
                                            font-size="13"
                                            font-family="system-ui, -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif"
                                        >
                                            Data Layer – MySQL
                                        </text>
                                        <text
                                            x="610"
                                            y="344"
                                            fill="#9ca3af"
                                            font-size="11"
                                            font-family="system-ui, -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif"
                                        >
                                            Unified Schema · Soft Delete · Audit Columns
                                        </text>

                                        <text
                                            x="610"
                                            y="362"
                                            fill="#9ca3af"
                                            font-size="10"
                                            font-family="system-ui, -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif"
                                        >
                                            TB_USER · TB_DIARY · TB_LEDGER · TB_RESERVATION · TB_PRODUCT · TB_PAYMENT_REFUND · ...
                                        </text>

                                        <!-- AI / ML box -->
                                        <rect
                                            x="590"
                                            y="408"
                                            width="290"
                                            height="90"
                                            rx="12"
                                            fill="#020617"
                                            stroke="#a855f7"
                                            stroke-width="1.3"
                                            stroke-dasharray="4 3"
                                        />
                                        <text
                                            x="610"
                                            y="436"
                                            fill="#e5e7eb"
                                            font-size="13"
                                            font-family="system-ui, -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif"
                                        >
                                            AI / ML Service (Planned)
                                        </text>
                                        <text
                                            x="610"
                                            y="454"
                                            fill="#9ca3af"
                                            font-size="11"
                                            font-family="system-ui, -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif"
                                        >
                                            Python · Text Analytics · Recommendation · Anomaly Detection
                                        </text>
                                        <text
                                            x="610"
                                            y="472"
                                            fill="#9ca3af"
                                            font-size="10"
                                            font-family="system-ui, -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif"
                                        >
                                            Diary Emotion &amp; Summary · Ledger Category/Pattern · K-POP Comment Insights
                                        </text>

                                        <!-- Infra labels -->
                                        <text
                                            x="130"
                                            y="515"
                                            fill="#9ca3af"
                                            font-size="10"
                                            font-family="system-ui, -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif"
                                        >
                                            Naver Cloud – Tomcat · MySQL
                                        </text>
                                        <text
                                            x="390"
                                            y="515"
                                            fill="#9ca3af"
                                            font-size="10"
                                            font-family="system-ui, -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif"
                                        >
                                            Cloudflare – Pages · Workers · Tunnel
                                        </text>
                                        <text
                                            x="710"
                                            y="515"
                                            fill="#9ca3af"
                                            font-size="10"
                                            font-family="system-ui, -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif"
                                        >
                                            GitHub Actions – CI/CD (Build &amp; Deploy)
                                        </text>

                                        <!-- Arrows (frontend -> backend -> db/ai) -->
                                        <path
                                            d="M480 160 L480 190"
                                            stroke="#38bdf8"
                                            stroke-width="1.4"
                                            marker-end="url(#arrowHead)"
                                        />
                                        <path
                                            d="M320 270 L320 300"
                                            stroke="#38bdf8"
                                            stroke-width="1.4"
                                            marker-end="url(#arrowHead)"
                                        />
                                        <path
                                            d="M520 380 L590 345"
                                            stroke="#38bdf8"
                                            stroke-width="1.3"
                                            stroke-dasharray="4 3"
                                        />
                                        <path
                                            d="M520 390 L590 450"
                                            stroke="#a855f7"
                                            stroke-width="1.3"
                                            stroke-dasharray="4 3"
                                        />

                                        <defs>
                                            <marker
                                                id="arrowHead"
                                                viewBox="0 0 10 10"
                                                refX="5"
                                                refY="5"
                                                markerWidth="6"
                                                markerHeight="6"
                                                orient="auto-start-reverse"
                                            >
                                                <path
                                                    d="M 0 0 L 10 5 L 0 10 z"
                                                    fill="#38bdf8"
                                                />
                                            </marker>
                                        </defs>
                                    </svg>

                                    <div class="architecture-caption">
                                        CONNECT는 모바일 우선 React/Next.js 프론트엔드와 Spring MVC/eGovFrame
                                        백엔드, MySQL 데이터 레이어, 향후 Python 기반 AI/ML 서비스를 결합한
                                        구조로 설계되어 있습니다. JavaGen/ReactGen 코드는 전체 모듈의 CRUD와
                                        화면 뼈대를 자동 생성하여 일관성과 생산성을 동시에 확보합니다.
                                    </div>
                                </div>
                            </section>

                            <section>
                                <h2>AI &amp; ML DIRECTION</h2>
                                <p>
                                    CONNECT 위에 다음과 같은 AI/ML 기능을 단계적으로 올릴 계획입니다.
                                </p>
                                <ul>
                                    <li>
                                        <strong>개인 데이터 인텔리전스</strong> – 일기/할일/가계부/예약/채팅 데이터를
                                        통합 분석하여 감정 타임라인, 습관 패턴, 지출 구조를 요약하고
                                        인사이트를 제공합니다.
                                    </li>
                                    <li>
                                        <strong>텍스트 분석 기반 서비스</strong> – K-POP 팬덤 댓글/게시글 크롤링 후,
                                        감정 분석/토픽 모델링을 통해 컴백·콘서트 등 이벤트 반응을 시각화합니다.
                                    </li>
                                    <li>
                                        <strong>추천 · 예측</strong> – 가계부 지출 카테고리 자동 분류, 상품 유사도
                                        추천, 시계열 기반 가격·수요 변화 예측 등.
                                    </li>
                                    <li>
                                        <strong>운영 인텔리전스</strong> – 로그인/결제/에러 로그 기반 이상 징후
                                        탐지로 서비스 안정성과 보안을 동시에 강화합니다.
                                    </li>
                                </ul>
                            </section>

                            <section>
                                <h2>CONTACT</h2>
                                <p>
                                    프로젝트 코드와 더 자세한 작업 내용은 요청 시 공유 가능합니다.  
                                    실제 코드/ERD/다이어그램/운영 로그까지 포함한 “구조 단위 포트폴리오”로
                                    대화하고 싶습니다.
                                </p>
                                <div class="contact-row">
                                    <!-- 이메일 / 깃허브 / 포트폴리오 링크는 직접 수정해서 사용 -->
                                    <a href="mailto:your.email@example.com" class="contact-link contact-link-accent">
                                        Email · your.email@example.com
                                    </a>
                                    <a href="https://github.com/your-github-id" class="contact-link" target="_blank" rel="noreferrer">
                                        GitHub · your-github-id
                                    </a>
                                    <a href="https://your-portfolio-link.example.com" class="contact-link" target="_blank" rel="noreferrer">
                                        CONNECT · Demo / Docs
                                    </a>
                                </div>
                            </section>
                        </div>
                    </main>
                </div>
            </div>
        </div>
    </body>
</html>