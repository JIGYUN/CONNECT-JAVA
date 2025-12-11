<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!-- 포트폴리오 전용 스타일 (Scoped) -->
<style>
    :root {
        --pf-primary: #2E5CFF; /* CONNECT 메인 컬러 참조 */
        --pf-secondary: #9D50BB;
        --pf-dark: #1a1f36;
        --pf-gray: #697386;
        --pf-bg: #f7f9fc;
    }

    .pf-wrapper {
        font-family: 'Noto Sans KR', sans-serif;
        color: var(--pf-dark);
        line-height: 1.6;
        padding-bottom: 80px;
    }

    /* 애니메이션 */
    .fade-up {
        animation: fadeUp 0.8s cubic-bezier(0.165, 0.84, 0.44, 1) forwards;
        opacity: 0;
        transform: translateY(20px);
    }
    .delay-1 { animation-delay: 0.1s; }
    .delay-2 { animation-delay: 0.2s; }
    .delay-3 { animation-delay: 0.3s; }
    .delay-4 { animation-delay: 0.4s; }

    @keyframes fadeUp {
        to { opacity: 1; transform: translateY(0); }
    }

    /* 히어로 섹션 */
    .pf-hero {
        background: linear-gradient(135deg, var(--pf-primary) 0%, var(--pf-secondary) 100%);
        border-radius: 16px;
        padding: 4rem 2rem;
        color: white;
        text-align: center;
        box-shadow: 0 10px 30px rgba(46, 92, 255, 0.2);
        margin-bottom: 3rem;
        position: relative;
        overflow: hidden;
    }
    .pf-hero::before {
        content: ''; position: absolute; top: -50%; left: -50%; width: 200%; height: 200%;
        background: radial-gradient(circle, rgba(255,255,255,0.1) 0%, transparent 60%);
        transform: rotate(45deg);
    }
    .pf-hero h1 { font-weight: 800; font-size: 2.5rem; margin-bottom: 0.5rem; letter-spacing: -0.5px; }
    .pf-hero .role { font-size: 1.1rem; opacity: 0.9; font-weight: 500; margin-bottom: 1.5rem; }
    .pf-hero .slogan { 
        background: rgba(255,255,255,0.15); 
        display: inline-block; padding: 0.5rem 1.5rem; 
        border-radius: 99px; font-size: 0.95rem; backdrop-filter: blur(5px);
    }

    /* 섹션 공통 */
    .pf-section-title {
        font-size: 1.75rem; font-weight: 700; margin-bottom: 1.5rem;
        display: flex; align-items: center; gap: 10px;
    }
    .pf-section-title::before {
        content: ''; display: block; width: 6px; height: 28px;
        background: var(--pf-primary); border-radius: 3px;
    }

    /* 카드 스타일 */
    .pf-card {
        background: white; border-radius: 12px;
        border: 1px solid #eef2f6;
        padding: 2rem; height: 100%;
        transition: transform 0.3s ease, box-shadow 0.3s ease;
    }
    .pf-card:hover {
        transform: translateY(-5px);
        box-shadow: 0 12px 24px rgba(0,0,0,0.06);
        border-color: rgba(46, 92, 255, 0.3);
    }

    /* About Me */
    .identity-box {
        background: #f8faff; border-left: 4px solid var(--pf-primary);
        padding: 1.5rem; border-radius: 0 8px 8px 0; margin: 1.5rem 0;
    }
    .identity-box strong { color: var(--pf-primary); font-size: 1.1rem; }

    /* Tech Stack */
    .tech-category { margin-bottom: 1rem; }
    .tech-category h5 { font-size: 1rem; font-weight: 700; color: var(--pf-gray); text-transform: uppercase; margin-bottom: 0.8rem; letter-spacing: 0.5px; }
    .tech-badge {
        display: inline-block; padding: 6px 12px; margin: 0 4px 8px 0;
        background: #f1f5f9; color: #334155; border-radius: 6px;
        font-size: 0.9rem; font-weight: 600; border: 1px solid #e2e8f0;
    }
    .tech-badge.core { background: #eff6ff; color: var(--pf-primary); border-color: #bfdbfe; }

    /* Project CONNECT */
    .project-hero {
        background: linear-gradient(to right, #141E30, #243B55);
        color: white; padding: 2.5rem; border-radius: 12px 12px 0 0;
    }
    .project-body {
        border: 1px solid #eef2f6; border-top: none;
        border-radius: 0 0 12px 12px; padding: 2.5rem; background: white;
    }
    .module-grid {
        display: grid; grid-template-columns: repeat(auto-fill, minmax(200px, 1fr)); gap: 1rem; margin-top: 1.5rem;
    }
    .module-item {
        background: #f8f9fa; padding: 1rem; border-radius: 8px; border: 1px solid #eee;
    }
    .module-item h6 { font-weight: 700; margin-bottom: 0.5rem; color: #333; }
    .module-item p { font-size: 0.85rem; color: #666; margin: 0; line-height: 1.4; }

    /* Values & Contact */
    .value-item { display: flex; gap: 1rem; margin-bottom: 1.5rem; }
    .value-icon {
        width: 48px; height: 48px; border-radius: 12px; background: #eef2ff;
        color: var(--pf-primary); display: flex; align-items: center; justify-content: center;
        font-size: 1.25rem; flex-shrink: 0;
    }
    .contact-btn {
        display: inline-flex; align-items: center; justify-content: center;
        padding: 0.75rem 2rem; border-radius: 50px; font-weight: 700;
        background: var(--pf-dark); color: white; text-decoration: none;
        transition: all 0.2s;
    }
    .contact-btn:hover { background: var(--pf-primary); color: white; transform: scale(1.05); }

    @media (max-width: 768px) {
        .pf-hero { padding: 3rem 1.5rem; }
        .pf-hero h1 { font-size: 2rem; }
        .module-grid { grid-template-columns: 1fr; }
    }
</style>

<div class="pf-wrapper">

    <!-- 1. Hero Section -->
    <div class="pf-hero fade-up">
        <h1>Jeong JiGyun</h1>
        <div class="role">Full-Stack System Architect & AI-Oriented Developer</div>
        <div class="slogan">
            “레거시와 혼돈을 구조로 바꾸는 풀스택 설계자”
        </div>
    </div>

    <div class="row">
        <!-- 2. About Me (Left) -->
        <div class="col-lg-7 mb-4 fade-up delay-1">
            <div class="pf-card">
                <h2 class="pf-section-title">About Me</h2>
                <p>
                    저는 웹·서버·모바일을 모두 직접 설계하고 구현하는 풀스택 개발자입니다.<br>
                    <strong>eGovFrame + Spring MVC</strong> 기반의 백엔드와 <strong>Next.js + TypeScript</strong> 기반의 프론트를 동시에 다루며,
                    혼자서도 한 회사 수준의 통합 서비스를 끝까지 끌고 가는 것을 목표로 합니다.
                </p>
                <div class="identity-box">
                    <strong>Core Identity</strong><br>
                    “망가진 구조를 다시 세우고, 하나의 일관된 시스템으로 통합하는 풀스택 아키텍트”
                </div>
                <ul class="pl-3 text-muted">
                    <li>10년 이상의 Java(Spring) 실무 경험</li>
                    <li>반복 작업을 싫어하여 <strong>JavaGen / ReactGen</strong> 등 자동화 툴 직접 제작</li>
                    <li>현재 <strong>AI·머신러닝</strong>을 결합하여 “스스로 진화하는 서비스” 구현 중</li>
                </ul>
            </div>
        </div>

        <!-- 3. Work Values (Right) -->
        <div class="col-lg-5 mb-4 fade-up delay-2">
            <div class="pf-card" style="background: #fcfdfe;">
                <h2 class="pf-section-title">Work Style</h2>
                
                <div class="value-item">
                    <div class="value-icon">🏗️</div>
                    <div>
                        <h5 class="font-weight-bold m-0">구조 우선</h5>
                        <small class="text-muted">기능보다 시스템 안에서의 위치와 역할을 먼저 정의</small>
                    </div>
                </div>
                <div class="value-item">
                    <div class="value-icon">🛡️</div>
                    <div>
                        <h5 class="font-weight-bold m-0">재발 방지</h5>
                        <small class="text-muted">한 번 겪은 문제는 프로젝트 규칙으로 승화</small>
                    </div>
                </div>
                <div class="value-item">
                    <div class="value-icon">⚡</div>
                    <div>
                        <h5 class="font-weight-bold m-0">자동화 지향</h5>
                        <small class="text-muted">반복되는 CRUD와 화면 작업은 코드로 대체</small>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- 4. Flagship Project -->
    <div class="row mb-5 fade-up delay-3">
        <div class="col-12">
            <h2 class="pf-section-title">Flagship Project</h2>
            <div class="shadow-sm" style="border-radius: 12px; overflow: hidden;">
                <!-- Project Header -->
                <div class="project-hero">
                    <div class="d-flex justify-content-between align-items-end flex-wrap">
                        <div>
                            <h3 class="font-weight-bold mb-1">CONNECT</h3>
                            <p class="mb-0 text-white-50">나 혼자 만드는 개인 OS이자, 통합 웹 플랫폼</p>
                        </div>
                        <span class="badge badge-light text-primary mt-2">In Progress</span>
                    </div>
                </div>
                <!-- Project Body -->
                <div class="project-body">
                    <p class="lead" style="font-size: 1rem; color: #555;">
                        하나의 계정과 그룹(grpCd) 아래에서 일기, 가계부, 쇼핑몰, 게시판, 채팅, AI까지 확장 가능한 구조로 설계된 풀스택 통합 플랫폼입니다.
                    </p>
                    
                    <hr class="my-4">

                    <h5 class="font-weight-bold">🛠 Key Modules</h5>
                    <div class="module-grid">
                        <div class="module-item">
                            <h6>Ledger (가계부)</h6>
                            <p>월 단위 매트릭스 UI, 지출 패턴 분석 및 ML 이상치 탐지 타깃</p>
                        </div>
                        <div class="module-item">
                            <h6>E-Commerce</h6>
                            <p>상품/주문/결제/환불 프로세스 완벽 구현 (실무 수준)</p>
                        </div>
                        <div class="module-item">
                            <h6>Reservation</h6>
                            <p>날짜·시간 슬롯 예약, 모바일 카드뷰/PC 테이블뷰 동시 지원</p>
                        </div>
                        <div class="module-item">
                            <h6>Chat & AI</h6>
                            <p>STOMP 기반 실시간 채팅 + OpenAI 연동 상담 봇 구조 설계</p>
                        </div>
                        <div class="module-item">
                            <h6>Automation</h6>
                            <p>JavaGen/ReactGen을 통한 CRUD 코드 및 UI 100% 자동 생성</p>
                        </div>
                    </div>

                    <div class="alert alert-primary mt-4 mb-0 d-flex align-items-center" role="alert">
                        <span class="mr-3" style="font-size:1.5rem;">🤖</span>
                        <div>
                            <strong>AI & Data Intelligence</strong><br>
                            개인 데이터(일기, 지출, 습관)를 통합 분석하여 "나 전용 코파일럿" 제공 및 이상 징후 탐지 시스템 구축 중
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- 5. Tech Stack -->
    <div class="fade-up delay-4">
        <h2 class="pf-section-title">Tech Stack</h2>
        <div class="row">
            <!-- Backend -->
            <div class="col-md-6 mb-4">
                <div class="pf-card">
                    <div class="tech-category">
                        <h5>Backend</h5>
                        <div>
                            <span class="tech-badge core">Java</span>
                            <span class="tech-badge core">Spring MVC 4.x</span>
                            <span class="tech-badge">eGovFrame</span>
                            <span class="tech-badge">MyBatis (XML/CommonDao)</span>
                            <span class="tech-badge">MySQL (ERD/Index)</span>
                            <span class="tech-badge">JWT / Session</span>
                        </div>
                    </div>
                    <div class="tech-category mb-0">
                        <h5>AI & Data</h5>
                        <div>
                            <span class="tech-badge core">Python</span>
                            <span class="tech-badge">Pandas</span>
                            <span class="tech-badge">Selenium</span>
                            <span class="tech-badge">Machine Learning (Basic)</span>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Frontend & DevOps -->
            <div class="col-md-6 mb-4">
                <div class="pf-card">
                    <div class="tech-category">
                        <h5>Frontend</h5>
                        <div>
                            <span class="tech-badge core">React</span>
                            <span class="tech-badge core">Next.js</span>
                            <span class="tech-badge core">TypeScript (Strict)</span>
                            <span class="tech-badge">React Query</span>
                            <span class="tech-badge">Bootstrap / Tailwind</span>
                        </div>
                    </div>
                    <div class="tech-category mb-0">
                        <h5>Infra & Tools</h5>
                        <div>
                            <span class="tech-badge">Naver Cloud</span>
                            <span class="tech-badge">Tomcat</span>
                            <span class="tech-badge">Cloudflare Pages/Workers</span>
                            <span class="tech-badge">GitHub Actions</span>
                            <span class="tech-badge">Docker (Learning)</span>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- 6. Footer Call to Action -->
    <div class="text-center mt-5 fade-up delay-4">
        <p class="mb-4 text-muted">
            “코드를 넘어서, 서비스 전체의 구조와 진화를 설계하는 개발자를 지향합니다.”
        </p>
        <a href="mailto:email@example.com" class="contact-btn shadow">
            Contact Me
        </a>
        <div class="mt-3">
            <a href="#" class="text-muted mx-2">GitHub</a>
            <span class="text-muted">|</span>
            <a href="#" class="text-muted mx-2">Project Demo</a>
        </div>
    </div>

</div>