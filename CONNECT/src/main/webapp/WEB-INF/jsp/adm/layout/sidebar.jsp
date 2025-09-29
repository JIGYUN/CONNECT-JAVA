<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>  <!-- ✅ 이것만이 맞습니다 -->
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib uri="http://www.springframework.org/security/tags" prefix="sec" %>

<c:set var="currentPath" value="${pageContext.request.requestURI}" />

<style>
    :root{ --sb-w:240px; --sb-w-collapsed:64px; }

    /* 본문 */
    body.admin-body{ margin:0; background:#f6f7fb; }
    .admin-main{ margin-left:var(--sb-w); padding:20px; padding-top:76px; transition:margin-left .18s ease; }
    body.sb-collapsed .admin-main{ margin-left:var(--sb-w-collapsed); }

    /* 사이드바 */
    .sidebar{
        position:fixed; inset:56px auto 0 0; width:var(--sb-w);
        background:#fff; border-right:1px solid #e5e7eb; padding:12px;
        transition:width .18s ease; z-index:1000;
    }
    body.sb-collapsed .sidebar{ width:var(--sb-w-collapsed); }
    .sidebar-inner{ height:calc(100vh - 56px - 24px); display:flex; flex-direction:column; }

    /* 불릿/여백 강제 제거 (중요) */
    ul.nav{ list-style:none !important; margin:0 !important; padding-left:0 !important; }
    ul.nav li{ list-style:none !important; }
    ul.nav li::marker{ content:''; }

    /* 상단 토글 */
    .topline{ display:flex; justify-content:flex-end; margin:2px 4px 10px; }
    .sb-btn{ width:30px; height:30px; border:1px solid #d1d5db; border-radius:8px; background:#fff;
             display:flex; align-items:center; justify-content:center; cursor:pointer; }
    .sb-btn:hover{ background:#eef2ff; }
    .sb-btn svg{ width:18px; height:18px; }
 
    /* 항목 */
    .link{ display:flex; align-items:center; gap:10px; padding:10px 12px; border-radius:10px;
           color:#1f2937; text-decoration:none; transition:background .15s; }
    .link:hover{ background:#eef2ff; }
    .link.active{ background:#2563eb; color:#fff; }
    .icon{ width:18px; opacity:.9; flex:0 0 18px; }
    .lbl{ white-space:nowrap; }

    /* 부모행 + 펼침 버튼 */
    .parent{ display:flex; align-items:center; gap:6px; }
    .parent .link{ flex:1; padding-right:6px; }
    .chev-btn{
        margin-left:auto; width:28px; height:28px;
        border-radius:8px; background:transparent; border:1px solid transparent;
        display:flex; align-items:center; justify-content:center; cursor:pointer;
    }
    .chev-btn:hover{ background:#eef2ff; }
    .chev-btn svg{ width:16px; height:16px; opacity:.7; transition:transform .18s; }
    .chev-btn.open svg{ transform:rotate(90deg); }
    body.sb-collapsed .chev-btn{ display:none; }

    /* 서브메뉴 */
    .submenu{ display:none; margin:6px 0 10px 6px; padding-left:8px; border-left:1px dashed #d1d5db; }
    .submenu.open{ display:block; }
    .sublink{ display:block; padding:8px 10px; margin:4px 0; border-radius:8px; color:#4b5563; text-decoration:none; }
    .sublink:hover{ background:#eef2ff; }
    .sublink.active{ background:#2563eb22; color:#111; border:1px solid #2563eb55; }

    /* 접힘 상태 */
    body.sb-collapsed .lbl{ display:none; }
    body.sb-collapsed .submenu{ display:none !important; }
    body.sb-collapsed .link{ justify-content:center; padding:10px 0; }

    /* 하단 사용자 */
    .userbar{ margin-top:auto; position:relative; }
    .userchip{ width:100%; display:flex; align-items:center; gap:10px; border:1px solid #e5e7eb;
               border-radius:12px; background:#fff; padding:8px 10px; cursor:pointer; }
    .avatar{ width:28px; height:28px; border-radius:50%; background:#1f2937; color:#fff;
             display:flex; align-items:center; justify-content:center; font-weight:700; font-size:12px; }
    .meta{ display:flex; flex-direction:column; min-width:0; }
    .meta .name{ font-weight:700; line-height:1.2; }
    .meta .mail{ font-size:12px; color:#6b7280; overflow:hidden; text-overflow:ellipsis; white-space:nowrap; max-width:140px; }
    .usermenu{ position:absolute; bottom:52px; left:0; right:0; background:#fff; border:1px solid #e5e7eb;
               border-radius:12px; box-shadow:0 8px 24px rgba(0,0,0,.08); padding:6px; display:none; }
    .usermenu.open{ display:block; }
    .usermenu a{ display:block; padding:10px 12px; border-radius:8px; color:#111; text-decoration:none; }
    .usermenu a:hover{ background:#f3f4f6; }

    .login-block{ display:block; text-align:center; padding:10px 12px; border-radius:10px; background:#2563eb; color:#fff; text-decoration:none; }
</style>

<!-- 관리자(2) / 프론트(1) 자동 판별 -->
<aside class="sidebar"
       data-menu-group-id="${empty param.menuGroupId ? (fn:startsWith(currentPath,'/adm') ? '2' : '1') : param.menuGroupId}">
    <div class="sidebar-inner">
        <div class="topline">
            <button id="sb-toggle" class="sb-btn" title="사이드바 접기/펼치기">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6">
                    <rect x="3" y="4" width="18" height="16" rx="2"></rect>
                    <line x1="8" y1="4" x2="8" y2="20"></line>
                </svg>
            </button>
        </div>

        <ul class="nav" id="adminNav"></ul>

        <div class="userbar">
            <sec:authorize ifNotGranted="EXTERNAL_AUTH">
                <a class="login-block" href="/adm/mba/auth/login">로그인</a>
            </sec:authorize>
            <sec:authorize access="hasRole('EXTERNAL_AUTH')">
                <button id="userMenuBtn" class="userchip" type="button">
                    <span class="avatar">${fn:substring(sessionScope.loginUser.userNm != null ? sessionScope.loginUser.userNm : 'U',0,1)}</span>
                    <span class="meta">
                        <span class="name">${sessionScope.loginUser.userNm}</span>
                        <span class="mail">${sessionScope.loginUser.email}</span>
                    </span>
                </button>
                <div id="userMenu" class="usermenu" role="menu" aria-label="사용자 메뉴">
                    <a href="/admin/profile" role="menuitem">프로필</a>
                    <a href="/adm/mba/auth/logout" role="menuitem">로그아웃</a>
                </div>
            </sec:authorize>
        </div>
    </div>
</aside>

<script>
(function(){
    // jQuery 보장
    if (!window.jQuery) {
        var s = document.createElement('script');
        s.src = 'https://code.jquery.com/jquery-3.6.0.min.js';
        s.onload = init; document.head.appendChild(s);
    } else { init(); }

    function init(){
        var currentPath = '<c:out value="${currentPath}"/>';
        var $nav = $('#adminNav');
        var groupId = '2';

        $.ajax({
            url: '/api/sys/menuItem/sideNav',  
            type: 'GET',
            dataType: 'json',
            data: { menuGroupId: groupId },
            cache: false,
            success: function(res){
                var src = pickArray(res);
                if (!src.length){ fallback(); return; }

                var items = src.map(normalize);
                var tree  = toTree(items);
                render(tree);
                bind();
            },
            error: function(){ fallback(); }
        });

        function fallback(){
            $nav.html('<li><a class="link" href="/adm/mai/main/main">'
                + icon('dashboard') + '<span class="lbl">대시보드</span></a></li>');
            bind();
        }

        /* ---------- helpers ---------- */
        function pickArray(o){
            if (!o) return [];
            if (Array.isArray(o.sections)) return o.sections;
            if (Array.isArray(o.result))   return o.result;
            if (Array.isArray(o.data))     return o.data;
            if (Array.isArray(o))          return o;
            return [];
        }
        function normalize(row){
            var l = {}; Object.keys(row||{}).forEach(function(k){ l[k.toLowerCase()] = row[k]; });
            return {
                id:   l.menuid || l.id || l['menu_id'],
                pid:  l.uppermenuid || l.parentid || l['upper_menu_id'] || 0,
                name: nz(l.menunm, l.name, l.title, l['menu_nm']),
                url:  nz(l.pathurl, l.url, l.href, l.link, l['path_url']),
                icon: nz(l.iconkey, l.icon, l['icon_key']),
                sort: +(l.sortordr || l.sort || l['sort_ordr'] || 0) || 0,
                vis:  (l.visibleat || l['visible_at'] || 'Y').toString().toUpperCase(),
                use:  (l.useat || l['use_at'] || 'Y').toString().toUpperCase()
            };
        }
        function nz(){ for(var i=0;i<arguments.length;i++){ var v=arguments[i]; if(v!==undefined&&v!==null&&String(v)!=='') return v; } return ''; }

        function toTree(list){
            // visible/use 필터
            list = list.filter(function(n){ return n.vis==='Y' && n.use==='Y'; });

            var byId={}, roots=[]; 
            list.forEach(function(n){ n.children=[]; byId[n.id]=n; });
            list.forEach(function(n){
                if (!n.pid || !byId[n.pid]) roots.push(n);
                else byId[n.pid].children.push(n);
            });
            var cmp = function(a,b){ return (a.sort||0)-(b.sort||0); };
            roots.sort(cmp); list.forEach(function(n){ n.children.sort(cmp); });
            return roots;
        }

        /* ---------- render ---------- */
        function render(nodes){
            $nav.html(nodes.map(renderNode).join(''));

            function renderNode(n){
                var hasChild = (n.children||[]).length>0;
                var label = (n.name||'(메뉴)')+'';
                var url   = (n.url||'')+'';
                var iconK = (n.icon||'dot')+'';
                var id    = (n.id!=null ? n.id : Math.random().toString(36).slice(2));
                var active= (url && currentPath.indexOf(url)===0) ? 'active' : '';

                if (!hasChild){
                    return ''+
                        '<li>'+
                        '  <a class="link '+active+'" href="'+esc(url||'#')+'">'+
                        icon(iconK)+'<span class="lbl">'+esc(label)+'</span>'+
                        '  </a>'+
                        '</li>';
                }

                var sec   = 'sec-'+id;
                var open  = (localStorage.getItem('sb.open.'+sec)==='1') ? 'open' : '';
                var subs  = (n.children||[]).map(function(c){
                    var act = (c.url && currentPath.indexOf(c.url)===0) ? 'active' : '';
                    return '<a class="sublink '+act+'" href="'+esc(c.url||'#')+'"><span class="lbl">'+esc(c.name||'(항목)')+'</span></a>';
                }).join('');

                return ''+
                    '<li>'+
                    '  <div class="parent">'+
                    '    <a class="link '+active+'" href="'+esc(url||'#')+'" data-section="'+sec+'" data-url="'+esc(url)+'">'+
                    icon(iconK)+'<span class="lbl">'+esc(label)+'</span>'+
                    '    </a>'+
                    '    <button type="button" class="chev-btn '+open+'" data-section="'+sec+'" aria-label="펼치기">'+
                    '      <svg viewBox="0 0 24 24" fill="currentColor"><path d="M9 6l6 6-6 6"/></svg>'+
                    '    </button>'+
                    '  </div>'+
                    '  <div id="submenu-'+sec+'" class="submenu '+open+'">'+subs+'</div>'+
                    '</li>';
            }
        }

        /* ---------- bind ---------- */
        function bind(){
            // 펼침/접기 버튼
            $(document).off('click.chev').on('click.chev', '.sidebar .chev-btn', function(e){
                e.preventDefault();
                var sec = $(this).data('section');
                var $sub = $('#submenu-'+sec);
                $(this).toggleClass('open');
                $sub.toggleClass('open');
                localStorage.setItem('sb.open.'+sec, $sub.hasClass('open') ? '1' : '0');
            });

            // 부모 라벨: URL 없으면 폴더처럼 동작
            $(document).off('click.parentlink').on('click.parentlink', '.sidebar .parent .link', function(e){
                var url = $(this).data('url');
                if (!url){ e.preventDefault(); $('.sidebar .chev-btn[data-section="'+$(this).data('section')+'"]').trigger('click'); }
            });

            // 사이드바 접기/펼치기
            var key = 'sb.collapsed', btn = document.getElementById('sb-toggle');
            var apply = function(v){ document.body.classList.toggle('sb-collapsed', v); };
            apply(localStorage.getItem(key)==='1');
            btn.addEventListener('click', function(){
                var v = !document.body.classList.contains('sb-collapsed');
                apply(v); localStorage.setItem(key, v?'1':'0');
            });

            // 사용자 메뉴
            var userBtn = document.getElementById('userMenuBtn');
            var menu = document.getElementById('userMenu');
            if (userBtn && menu){
                userBtn.addEventListener('click', function(e){ e.stopPropagation(); menu.classList.toggle('open'); });
                document.addEventListener('click', function(){ menu.classList.remove('open'); });
            }
        }

        /* ---------- small utils ---------- */
        function icon(key){
            switch((key||'').toLowerCase()){
                case 'dashboard':
                    return '<svg class="icon" viewBox="0 0 24 24" fill="currentColor"><path d="M3 13h8V3H3v10zm0 8h8v-6H3v6zm10 0h8V11h-8v10zm0-18v6h8V3h-8z"/></svg>';
                case 'board':
                    return '<svg class="icon" viewBox="0 0 24 24" fill="currentColor"><path d="M4 6h16v2H4V6zm0 5h16v2H4v-2zm0 5h10v2H4v-2z"/></svg>';
                case 'user':
                    return '<svg class="icon" viewBox="0 0 24 24" fill="currentColor"><path d="M12 12a5 5 0 1 0-5-5 5 5 0 0 0 5 5Zm0 2c-5 0-9 2.5-9 5v1h18v-1c0-2.5-4-5-9-5Z"/></svg>';
                case 'menu':
                    return '<svg class="icon" viewBox="0 0 24 24" fill="currentColor"><path d="M3 6h18v2H3V6Zm0 5h18v2H3v-2Zm0 5h18v2H3v-2Z"/></svg>';
                default:
                    return '<svg class="icon" viewBox="0 0 24 24" fill="currentColor"><circle cx="12" cy="12" r="2.5"/></svg>';
            }
        }
        function esc(s){ return (s||'').replace(/[&<>"]/g,function(m){return({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;'}[m]);});}
    }
})();
</script>            