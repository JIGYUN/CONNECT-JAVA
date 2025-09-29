<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<!-- Subnav (페이지 내 앵커) -->
<nav class="bg-white border rounded-pill px-3 py-2 mb-4 d-inline-flex align-items-center shadow-sm">
    <a class="nav-link py-0 px-2" href="#kpop">K-POP</a>
    <span class="text-muted">·</span>
    <a class="nav-link py-0 px-2" href="#culture">문화</a>
    <span class="text-muted">·</span>
    <a class="nav-link py-0 px-2" href="#hotspots">핫스팟</a>
    <span class="text-muted">·</span>
    <a class="nav-link py-0 px-2" href="#food">음식</a>
    <span class="text-muted">·</span>
    <a class="nav-link py-0 px-2" href="#etiquette">에티켓</a>
    <span class="text-muted">·</span>
    <a class="nav-link py-0 px-2" href="#help">도움말</a>
</nav>

<!-- Hero -->
<section class="culture-hero rounded-3 shadow-lg mb-5 position-relative overflow-hidden">
    <div class="container py-5 text-center text-white position-relative" style="z-index:2;">
        <h1 class="display-5 fw-bold mb-2">CONNECT · K-Welcome</h1>
        <p class="lead mb-4">
            K-POP과 한국 문화를 한 곳에서 — 공연·거리·미식·에티켓까지 여행에 필요한 모든 정보를 제공합니다.
        </p>
        <div class="d-flex justify-content-center gap-2">
            <a href="#hotspots" class="btn btn-light btn-lg me-2">핫스팟 보기</a>
            <a href="#help" class="btn btn-outline-light btn-lg">여행 도움말</a>
        </div>
    </div>
    <div class="culture-hero-glow"></div>
</section>

<!-- K-POP 섹션 -->
<section id="kpop" class="container mb-5">
    <div class="row align-items-center g-4">
        <div class="col-lg-6">
            <h2 class="h3 fw-bold mb-3">K-POP Experience</h2>
            <p class="text-muted mb-3">
                BTS·BLACKPINK 등 글로벌 스타로 확산된 한류는 공연·전시·팝업스토어로 이어지고 있습니다.
                서울의 홍대·강남·잠실 일대는 라이브 공연과 팬 이벤트가 활발한 대표 구역입니다.
            </p>
            <ul class="list-unstyled small mb-4">
                <li class="mb-2">• <b>라이브 클럽</b> : 홍대/합정 일대 인디·댄스 공연</li>
                <li class="mb-2">• <b>팝업/포토존</b> : 앨범 리스닝룸, 체험형 전시</li>
                <li class="mb-2">• <b>굿즈샵</b> : 기획사 MD, 협업 스토어</li>
            </ul>
            <a class="btn btn-primary" href="<c:url value='/bbs/board/boardList'/>">팬 팁 & 후기 보기</a>
        </div>
        <div class="col-lg-6">
            <!-- 반응형 유튜브 -->
            <div class="ratio ratio-16x9 rounded-3 shadow-sm overflow-hidden">
                <iframe
                    src="https://www.youtube.com/embed/gdZLi9oWNZg"
                    title="K-POP"
                    allowfullscreen
                    referrerpolicy="strict-origin-when-cross-origin"></iframe>
            </div>
        </div>
    </div>
</section>

<!-- 문화 & 추천 코스 -->
<section class="container py-5">
    <h2 class="h4 mb-4">K-Culture Highlights</h2>
<!-- 카드 그리드 -->
    <div class="row">

        <!-- 경복궁 -->
        <div class="col-md-4 mb-4">
            <div class="card shadow-sm h-100">
<!--                 <img class="card-img-top"
                     src="https://commons.wikimedia.org/wiki/Special:FilePath/Gyeongbokgung_Geunjeongjeon_2017-09-23_%282%29.jpg?width=1600"
                     alt="Gyeongbokgung Palace"> -->
                <div class="card-body">
                    <span class="badge badge-soft mb-2">Heritage</span>
                    <h5 class="card-title mb-2">경복궁 (Gyeongbokgung)</h5>
                    <p class="card-text text-muted mb-3">
                        조선의 정궁. 근정전·향원정 등 한국 궁궐의 미를 제대로 느낄 수 있어요.
                    </p>
                    <a class="btn btn-primary btn-block"
                       href="https://royal.cha.go.kr/ENG/contents/E101010000.do" target="_blank" rel="noopener">
                        공식 안내 보기
                    </a>
                </div>
            </div>
        </div>

        <!-- 홍대 -->
        <div class="col-md-4 mb-4">
            <div class="card shadow-sm h-100">
<!--                 <img class="card-img-top"
                     src="https://commons.wikimedia.org/wiki/Special:FilePath/Hongdae_street_night_scene_%2848952851238%29.jpg?width=1600"
                     alt="Hongdae Street"> -->
                <div class="card-body">
                    <span class="badge badge-soft mb-2">Youth</span>
                    <h5 class="card-title mb-2">홍대 (Hongdae)</h5>
                    <p class="card-text text-muted mb-3">
                        버스킹, 스트릿 패션, 개성 있는 카페로 가득한 K-트렌드의 심장.
                    </p>
                    <a class="btn btn-outline-primary btn-block"
                       href="https://english.visitseoul.net/attractions/Hongdae_/2690" target="_blank" rel="noopener">
                        지역 안내 보기
                    </a>
                </div>
            </div>
        </div>

        <!-- 한강 -->
        <div class="col-md-4 mb-4">
            <div class="card shadow-sm h-100">
<!--                 <img class="card-img-top"
                     src="https://commons.wikimedia.org/wiki/Special:FilePath/Hangang_River.jpg?width=1600"
                     alt="Han River"> -->
                <div class="card-body">
                    <span class="badge badge-soft mb-2">Chill</span>  
                    <h5 class="card-title mb-2">한강 (Han River)</h5>
                    <p class="card-text text-muted mb-3">
                        피크닉·따릉이·야경 명소. 서울을 가로지르는 힐링 스폿.
                    </p>
                    <a class="btn btn-outline-primary btn-block"
                       href="https://hangang.seoul.go.kr/archives/3563" target="_blank" rel="noopener">
                        공원 안내 보기
                    </a>
                </div>
            </div>
        </div>  
</section>  

<!-- 핫스팟(지도 + 추천 구역) -->
<section id="hotspots" class="container mb-5">
    <div class="d-flex align-items-center mb-3">
        <h2 class="h3 fw-bold mb-0 me-2">관광 핫스팟</h2>
        <span class="badge rounded-pill text-bg-primary">데이터 기반</span>
    </div>
    <div class="row g-4">
        <div class="col-lg-7">
            <!-- Folium 지도 결과(iframe) -->
            <div class="rounded-3 shadow-sm overflow-hidden">
                <iframe
                    src="<c:url value='/static/maps/seoul_hotspots.html'/>"
                    width="100%" height="520" style="border:0;"></iframe>
            </div>
            <p class="text-muted small mt-2">
                * 지도는 우리 DB(POI·친화도·착한업소) 기반으로 가중치 계산 후 시각화합니다.
            </p>
        </div>
        <div class="col-lg-5">
            <div class="list-group shadow-sm rounded-3">
                <a class="list-group-item list-group-item-action d-flex justify-content-between align-items-center">
                    명동·남대문 <span class="badge text-bg-secondary">쇼핑/환전</span>
                </a>
                <a class="list-group-item list-group-item-action d-flex justify-content-between align-items-center">
                    홍대·합정 <span class="badge text-bg-secondary">버스킹/클럽</span>
                </a>
                <a class="list-group-item list-group-item-action d-flex justify-content-between align-items-center">
                    종로·북촌 <span class="badge text-bg-secondary">전통/한복</span>
                </a>
                <a class="list-group-item list-group-item-action d-flex justify-content-between align-items-center">
                    잠실·석촌호수 <span class="badge text-bg-secondary">공연/파크</span>
                </a>
            </div>
            <div class="mt-3">
                <a class="btn btn-outline-primary me-2" href="<c:url value='/bbs/board/boardList'/>">현장 후기</a>
                <a class="btn btn-primary" href="<c:url value='/hhd/household/householdList'/>">예산 플래너</a>
            </div>
        </div>
    </div>
</section>

<!-- 음식 -->
<section id="food" class="container mb-5">
    <h2 class="h3 fw-bold mb-3">한국 음식 가이드</h2>
    <div class="row g-4">
        <div class="col-md-4">
            <div class="p-4 border rounded-3 h-100 shadow-sm">
                <h5 class="mb-2">비빔밥 & 불고기</h5>
                <p class="text-muted small mb-0">입문자도 부담 없는 대표 메뉴. 다국어 메뉴가 있는 매장을 추천합니다.</p>
            </div>
        </div>
        <div class="col-md-4">
            <div class="p-4 border rounded-3 h-100 shadow-sm">
                <h5 class="mb-2">김치·전·전골</h5>
                <p class="text-muted small mb-0">매운맛 고지 필요 시 “less spicy, please” 요청을 해보세요.</p>
            </div>
        </div>
        <div class="col-md-4">
            <div class="p-4 border rounded-3 h-100 shadow-sm">
                <h5 class="mb-2">길거리 간식</h5>
                <p class="text-muted small mb-0">떡볶이·호떡·붕어빵은 카드 결제 가능한 노점도 늘고 있어요.</p>
            </div>
        </div>
    </div>
</section>

<!-- 에티켓 & 유의사항 -->
<section id="etiquette" class="container mb-5">
    <h2 class="h3 fw-bold mb-3">여행 에티켓 & 유의 사항</h2>
    <div class="row g-4">
        <div class="col-md-6">
            <div class="border rounded-3 p-4 shadow-sm h-100">
                <h5 class="mb-3">기본 에티켓</h5>
                <ul class="small text-muted mb-0">
                    <li class="mb-2">실내 마스크 가이드·줄 서기·쓰레기 분리배출을 지켜주세요.</li>
                    <li class="mb-2">대중교통은 교통카드(T-money/후불카드)로 탑승합니다.</li>
                    <li class="mb-2">개인정보·촬영 동의 등 디지털 에티켓을 존중합니다.</li>
                </ul>
            </div>
        </div>
        <div class="col-md-6">
            <div class="border rounded-3 p-4 shadow-sm h-100">
                <h5 class="mb-3">바가지·사기 예방</h5>
                <ul class="small text-muted mb-3">
                    <li class="mb-2">호객행위/메뉴 미표시 시 가격 확인 후 이용하세요.</li>
                    <li class="mb-2">택시는 합법 플랫폼(카카오T 등) 또는 미터기 사용을 요청하세요.</li>
                </ul>
                <a class="btn btn-outline-danger w-100"
                   href="<c:url value='/report/new'/>">이상 거래/피해 신고하기</a>
            </div>
        </div>
    </div>
</section>

<!-- 결제/도움말 -->
<section id="help" class="container mb-5">
    <h2 class="h3 fw-bold mb-3">결제 & 도움말</h2>
    <div class="row g-4">
        <div class="col-md-4">
            <div class="p-4 border rounded-3 shadow-sm h-100">
                <h5 class="mb-2">결제</h5>
                <p class="small text-muted mb-2">해외카드(Visa/Master/JCB) 사용처를 지도에 표시합니다.</p>
                <span class="badge rounded-pill text-bg-primary">국제카드 가능</span>
                <span class="badge rounded-pill text-bg-success">착한업소</span>
                <span class="badge rounded-pill text-bg-secondary">다국어 메뉴</span>
            </div>
        </div>
        <div class="col-md-4">
            <div class="p-4 border rounded-3 shadow-sm h-100">
                <h5 class="mb-2">환율 & 환전</h5>
                <p class="small text-muted mb-0">명동·홍대·이태원 등 공신력 있는 환전소를 추천합니다.</p>
            </div>
        </div>
        <div class="col-md-4">
            <div class="p-4 border rounded-3 shadow-sm h-100">
                <h5 class="mb-2">긴급 연락처</h5>
                <ul class="small text-muted mb-0">
                    <li>관광경찰 1330 (다국어)</li>
                    <li>긴급 112/119</li>
                </ul>
            </div>
        </div>
    </div>
</section>

<!-- 스타일(페이지 한정) -->
<style>
    .culture-hero{
        background: linear-gradient(135deg,#0d6efd 0%,#6f42c1 55%,#20c997 100%);
    }
    .culture-hero-glow{
        position:absolute; inset:-40% -20% auto -20%;
        height:140%; pointer-events:none;
        background:
          radial-gradient(60% 40% at 20% 10%, rgba(255,255,255,.20), transparent 70%),
          radial-gradient(50% 35% at 80% 20%, rgba(255,255,255,.14), transparent 65%);
    }
    .hover-up{ transition: transform .18s ease, box-shadow .18s ease; }
    .hover-up:hover{
        transform: translateY(-4px);
        box-shadow: 0 .75rem 2rem rgba(0,0,0,.12)!important;
    }
</style>