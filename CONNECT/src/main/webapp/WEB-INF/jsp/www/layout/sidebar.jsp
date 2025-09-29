<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>  <!-- ✅ 이것만이 맞습니다 -->
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>  

<!-- 상단 헤더: TB_MENU_ITEM 연동 -->
<header class="site-header sticky-top"
        id="frontHeader"
        data-menu-group-id="1"><%-- 프론트: 1 / 관리자: 2 로 바꿔서 재사용 가능 --%>
    <nav class="navbar navbar-expand-lg nav-elevated">
        <div class="container">
            <!-- 브랜드 -->
            <a class="navbar-brand brand-wordmark" href="/">CONNECTT</a>

            <!-- 토글(모바일) -->
            <button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#mainNav"
                    aria-controls="mainNav" aria-expanded="false" aria-label="Toggle navigation">
                <span class="navbar-toggler-icon"></span>
            </button>

            <!-- 메뉴 + 액션 -->
            <div class="collapse navbar-collapse" id="mainNav">
                <!-- 좌측: 동적 내비 -->
                <ul class="navbar-nav mr-auto" id="navRoot"><!-- 여기로 렌더링 --></ul>

                <!-- 우측 액션 -->
                <div class="navbar-actions d-flex align-items-center">
                    <!-- 인증 안 된 경우: JOIN/LOGIN -->
                    <sec:authorize access="isAnonymous()">
                        <a class="btn btn-ghost mr-2" href="/mba/auth/join">JOIN</a>
                        <a class="btn btn-ghost-primary" href="/mba/auth/login">LOGIN</a>
                    </sec:authorize>

                    <!-- 인증 된 경우: 계정 드롭다운 -->
                    <sec:authorize access="isAuthenticated()">
                        <div class="dropdown">
                            <button class="btn btn-ghost dropdown-toggle" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                                <span class="avatar">
                                    <sec:authentication property="principal.nickNm" var="nick"/>
                                    <c:out value="${empty nick ? 'U' : fn:substring(nick,0,1)}"/>
                                </span>
                                <span>
                                    <c:out value="${nick}"/>
                                </span> 
                            </button>
                            <div class="dropdown-menu dropdown-menu-right">
                                <a class="dropdown-item" href="/mypage">MYPAGE</a>
                                <div class="dropdown-divider"></div>
                                <a class="dropdown-item text-danger" href="/mba/auth/logout">LOGOUT</a>
                            </div>
                        </div>
                    </sec:authorize>
                </div>
            </div>
        </div>
    </nav>
</header>

<!-- 스타일 --> 
<style>
    .site-header{ margin-top:.75rem; }
    .nav-elevated{ background:#fff; border-radius:14px; box-shadow:0 .25rem 1rem rgba(0,0,0,.06); padding:.5rem .75rem; }

    .brand-wordmark{ font-weight:800; letter-spacing:.06em; font-size:1.25rem; color:#111 !important; }

    .navbar-nav .nav-link{ padding:.5rem .75rem; font-weight:700; color:#6c757d !important; }
    .navbar-nav .nav-link:hover, .navbar-nav .nav-link.active{ color:#0d6efd !important; }

    /* 드롭다운(루트의 자식) */
    .dropdown-menu{ min-width:240px; border-radius:10px; border:1px solid #eef1f4; box-shadow:0 .75rem 1.5rem rgba(0,0,0,.08); }
    .dropdown-item{ font-weight:600; }
    .dropdown-item.active, .dropdown-item:active{ background:#eef2ff; color:#0d6efd; }
    .dropdown-item.sub{ padding-left:1.5rem; }

    .navbar-actions .btn{ border-radius:999px; }
    .btn-ghost{ background:transparent; border:1px solid rgba(0,0,0,.12); color:#495057; }
    .btn-ghost:hover{ background:rgba(0,0,0,.03); }
    .btn-ghost-primary{ border:1px solid rgba(13,110,253,.35); color:#0d6efd; background:transparent; }
    .btn-ghost-primary:hover{ background:rgba(13,110,253,.06); }

    .avatar{
        width:28px; height:28px; border-radius:50%; display:inline-flex; align-items:center; justify-content:center;
        background:#f1f3f5; margin-right:.5rem; font-weight:700; font-size:.85rem; color:#495057;
    }

    @media (max-width:576px){
        .brand-wordmark{ font-size:1.1rem; }
    }
</style>

<!-- 스크립트: 메뉴 트리 → 상단 내비 렌더 -->
<script>
    (function(){
        // jQuery 보장
        function start(){ try { buildTopNav(); } catch(e){ console && console.error(e); } }
        if (!window.jQuery) {
            var s = document.createElement('script');
            s.src = 'https://code.jquery.com/jquery-3.6.0.min.js';
            s.onload = start;
            document.head.appendChild(s);
        } else {
            start();
        }

        function buildTopNav(){
            var BASE_FRONT = '';      // 프론트 기본 prefix (공백)
            var BASE_ADMIN = '/adm';  // 관리자 기본 prefix(관리자에 쓰면 이 값으로 교체/분기)
            var currentPath = location.pathname;
            var groupId = document.getElementById('frontHeader').getAttribute('data-menu-group-id') || '1';
            var $root = $('#navRoot');  

            $.ajax({
                url: '/api/sys/menuItem/sideNav',
                type: 'GET',
                dataType: 'json',
                data: { menuGroupId: '1' },
                cache: false
            }).done(function(res){
                var list = pickArray(res).map(normalize).map(applyDefaultUrlForBoard)
                                         .filter(function(n){ return n.vis === 'Y' && n.use === 'Y'; });
                var tree = toTree(list);     // 루트(상위없음) 기준
                render(tree);
                bindHoverOpen();             // 데스크톱 호버 오픈
                applyActive(currentPath);    // 활성화 표시
            }).fail(function(){
                // 폴백: 고정 메뉴 몇 개
                $root.html(
                    '<li class="nav-item"><a class="nav-link" href="/mai/main/culture">INFO</a></li>'
                );
            });

            /* ---------- 파싱/정규화 ---------- */
            function pickArray(o){
                if (!o) return [];
                if (Array.isArray(o.sections)) return o.sections;
                if (Array.isArray(o.result))   return o.result;
                if (Array.isArray(o.data))     return o.data;
                if (Array.isArray(o))          return o;
                return [];
            }
            function normalize(r){
                var l = {};
                Object.keys(r || {}).forEach(function(k){ l[k.toLowerCase()] = r[k]; });
                // menu_se_cd: ROUTE / BOARD
                return {
                    id:      l.menuid || l.id || l['menu_id'],
                    pid:     l.uppermenuid || l.parentid || l['upper_menu_id'] || 0,
                    name:    first(l.menunm, l.name, l.title, l['menu_nm']),
                    url:     first(l.pathurl, l.url, l.href, l.link, l['path_url']),   // 비어있을 수 있음
                    icon:    first(l.iconkey, l.icon, l['icon_key']),
                    sort:    +(l.sortordr || l.sort || l['sort_ordr'] || 0) || 0,
                    vis:     (l.visibleat || l['visible_at'] || 'Y').toString().toUpperCase(),
                    use:     (l.useat || l['use_at'] || 'Y').toString().toUpperCase(),
                    type:    (l.menusecd || l['menu_se_cd'] || '').toString().toUpperCase(),
                    boardId: l.boardid || l['board_id']
                };
            }
            function first(){
                for (var i = 0; i < arguments.length; i++){
                    var v = arguments[i];
                    if (v !== undefined && v !== null && String(v) !== '') return v;
                }
                return '';
            }

            // BOARD + URL 없으면 기본 경로 생성(프론트 기준)
            function applyDefaultUrlForBoard(n){
                if (!n.url && n.type === 'BOARD' && n.boardId){
                    n.url = BASE_FRONT + '/brd/post/list.do?boardId=' + encodeURIComponent(n.boardId);
                }
                return n;
            }

            function toTree(list){
                var byId = {}, roots = [];
                list.forEach(function(n){ n.children = []; byId[n.id] = n; });
                list.forEach(function(n){
                    if (!n.pid || !byId[n.pid]) roots.push(n);
                    else byId[n.pid].children.push(n);
                });
                var cmp = function(a, b){ return (a.sort || 0) - (b.sort || 0); };
                roots.sort(cmp);
                list.forEach(function(n){ n.children.sort(cmp); });
                return roots;
            }

            /* ---------- 렌더(루트는 상단 항목, 자식은 드롭다운) ---------- */
            function render(roots){
                var html = [];
                roots.forEach(function(r){
                    var hasChild = (r.children || []).length > 0;
                    var url = r.url || '#';
                    var label = esc(r.name || '(메뉴)');
                    var active = url && currentPath.indexOf(url.split('?')[0]) === 0 ? ' active' : '';

                    if (!hasChild){
                        html.push(
                            '<li class="nav-item">' +
                            '  <a class="nav-link' + active + '" href="' + esc(url) + '">' + label + '</a>' +
                            '</li>'
                        );
                    } else {
                        // 부모에 URL이 있으면 드롭다운 첫 항목으로도 넣어줌(“전체” 역할)
                        var sub = [];
                        if (r.url){
                            sub.push('<a class="dropdown-item" href="' + esc(r.url) + '">' + label + '</a>');
                            sub.push('<div class="dropdown-divider"></div>');
                        }
                        r.children.forEach(function(c){
                            sub.push('<a class="dropdown-item sub" href="' + esc(c.url || '#') + '">' + esc(c.name || '(항목)') + '</a>');
                        });

                        html.push(
                            '<li class="nav-item dropdown">' +
                            '  <a class="nav-link dropdown-toggle' + active + '" href="#" role="button" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">' + label + '</a>' +
                            '  <div class="dropdown-menu">' + sub.join('') + '</div>' +
                            '</li>'
                        );
                    }
                });
                $root.html(html.join(''));
            }

            /* ---------- UX 바인딩 ---------- */
            function bindHoverOpen(){
                var canHover = window.matchMedia && window.matchMedia('(hover:hover)').matches;
                if (!canHover) return; // 모바일은 Bootstrap 기본 클릭 사용

                // 데스크톱: 호버시 열림/닫힘
                $('#navRoot .dropdown').each(function(){
                    var $dd = $(this),
                        $toggle = $dd.find('> .nav-link'),
                        $menu = $dd.find('> .dropdown-menu');
                    $dd.on('mouseenter', function(){
                        $dd.addClass('show'); $toggle.attr('aria-expanded','true'); $menu.addClass('show');
                    }).on('mouseleave', function(){
                        $dd.removeClass('show'); $toggle.attr('aria-expanded','false'); $menu.removeClass('show');
                    });
                });
            }

            function applyActive(path){
                // 자식 active → 부모 nav-link 도 active
                $('#navRoot .dropdown-menu a').each(function(){
                    var url = this.getAttribute('href') || '';
                    if (url && path.indexOf(url.split('?')[0]) === 0){
                        $(this).addClass('active');
                        $(this).closest('.dropdown').find('> .nav-link').addClass('active');
                    }
                });
            }

            function esc(s){
                return (s || '').replace(/[&<>"]/g, function(m){
                    return ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;'}[m]);
                });
            }
        }
    })();
</script>