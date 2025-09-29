<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>  <!-- ✅ 이것만이 맞습니다 -->
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<aside id="admin-aside" class="admin-aside">
  <div class="aside-head">
    <a href="/admin" class="brand">CONNECT</a>
    <button id="asideToggle" class="icon-btn" aria-label="Toggle"><i class="bi bi-layout-sidebar-inset"></i></button>
  </div>

  <nav class="aside-nav">
    <ul class="nav flex-column">
      <c:choose>
        <c:when test="${not empty adminMenus}">
          <c:forEach var="m" items="${adminMenus}">
            <li class="nav-item">
              <a class="nav-link" href="${m.pathUrl}">
                <i class="bi bi-grid"></i><span>${m.menuNm}</span>
              </a>
            </li>
          </c:forEach>
        </c:when>
        <c:otherwise>
          <li class="nav-item"><a class="nav-link" href="/admin"><i class="bi bi-speedometer2"></i><span>대시보드</span></a></li>
          <li class="nav-item"><a class="nav-link" href="/admin/boards"><i class="bi bi-columns-gap"></i><span>게시판</span></a></li>
          <li class="nav-item"><a class="nav-link" href="/admin/users"><i class="bi bi-people"></i><span>사용자</span></a></li>
          <li class="nav-item"><a class="nav-link" href="/admin/menus"><i class="bi bi-list"></i><span>메뉴관리</span></a></li>
        </c:otherwise> 
      </c:choose>
    </ul> 
  </nav>
</aside>

<!-- 활성/토글 스크립트 --> 
<script>
(function(){
  var path = location.pathname;
  document.querySelectorAll('#admin-aside .nav-link').forEach(function(a){
    if (path === '/' && a.getAttribute('href') === '/admin') a.classList.add('active');
    if (path.indexOf(a.getAttribute('href')) === 0) a.classList.add('active');
  });

  // 접기 유지 (localStorage)
  const aside = document.getElementById('admin-aside');
  const key = 'adminAsideCollapsed';
  if (localStorage.getItem(key) === '1') aside.classList.add('collapsed');
  document.getElementById('asideToggle').addEventListener('click', function(){
    aside.classList.toggle('collapsed');
    localStorage.setItem(key, aside.classList.contains('collapsed') ? '1' : '0');
  });
})();
</script>