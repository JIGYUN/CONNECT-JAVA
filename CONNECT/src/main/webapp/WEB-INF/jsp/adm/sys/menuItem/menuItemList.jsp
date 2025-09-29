<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<style>
  .page-wrap { max-width: 1160px; margin: 0 auto; }
  .page-title { font-weight: 700; letter-spacing: .2px; }
  .toolbar { display: flex; gap: 8px; align-items: center; }
  .card-surface {
    background: #fff;
    border: 1px solid rgba(0,0,0,.06);
    border-radius: 16px;
    box-shadow: 0 4px 18px rgba(0,0,0,.04);
  }
  .table thead th { background:#f5f7fb; color:#5b6375; font-weight:600; border-bottom:1px solid rgba(0,0,0,.06); }
  .table th, .table td { vertical-align: middle; }
  .empty-row { color:#99a1b3; }
  /* 메뉴명 줄바꿈/세로 쏠림 방지 */
  .name-col { min-width:160px; white-space:nowrap; word-break:keep-all; }
  .badge-soft { background:#fff; border:1px solid rgba(0,0,0,.12); padding:3px 8px; border-radius:999px; font-size:.78rem; color:#5b6375; }
</style>

<section class="page-wrap">
  <div class="d-flex align-items-end justify-content-between mb-3">
    <h2 class="page-title mb-0">메뉴 관리</h2>
    <div class="toolbar">
      <button class="btn btn-primary" type="button" onclick="goToMenuItemModify()">등록</button>
      <button class="btn btn-outline-secondary" type="button" onclick="goToMenuItem()">통합</button>
    </div>
  </div>

  <div class="card-surface p-3 mb-3">
    <div class="row g-2 align-items-center">
      <div class="col-auto"><label for="filterMenuGroupId" class="col-form-label fw-semibold">메뉴그룹</label></div>
      <div class="col-5 col-md-3">
        <select id="filterMenuGroupId" class="form-select"></select>
      </div>
      <div class="col text-muted small">그룹을 선택하면 해당 그룹의 메뉴 트리가 표시됩니다.</div>
    </div>
  </div>

  <div class="card-surface p-2">
    <div class="table-responsive">
      <table class="table table-hover align-middle mb-0">
        <thead>
          <tr>
            <th style="width:70px; text-align:right;">ID</th>
            <th class="name-col">메뉴명</th>
            <th style="width:120px;">유형</th>
            <th style="width:220px;">경로/게시판</th>
            <th style="width:80px;">정렬</th>
            <th style="width:70px;">표시</th>
            <th style="width:70px;">사용</th>
            <th style="width:200px;">생성일</th>
            <th style="width:90px;">관리</th>
          </tr>
        </thead>
        <tbody id="menuItemListBody"></tbody>
      </table>
    </div>
  </div>
</section>

<script>
  // ▼ JavaGen 스타일 유지
  const API_ITEM  = '/api/sys/menuItem';
  const API_GROUP = '/api/sys/menuGroup';
  const menuIdParam = 'menuId';

  $(function () {
    // 변경 이벤트 등록
    $('#filterMenuGroupId').on('change', function () { selectMenuItemList(); });
    // 그룹 로드 후 최초 목록
    loadMenuGroupOptions();
  });

  function loadMenuGroupOptions() {
    $.ajax({
      url: API_GROUP + '/selectMenuGroupList',
      type: 'post',
      contentType: 'application/json',
      data: JSON.stringify({}),
      success: function (map) {
        const list = map.result || [];
        let html = '';
        for (let i = 0; i < list.length; i++) {
          const r = list[i];
          html += '<option value="' + (r.menuGroupId) + '">' + (r.menuGroupNm || ('#' + r.menuGroupId)) + '</option>';
        }
        $('#filterMenuGroupId').html(html);

        // 첫 로딩: 첫번째 그룹 선택 후 목록 호출
        if (list.length) {
          $('#filterMenuGroupId').val(list[0].menuGroupId);
          selectMenuItemList();
        } else {
          $('#menuItemListBody').html("<tr><td colspan='9' class='text-center empty-row py-5'>메뉴그룹이 없습니다.</td></tr>");
        }
      },
      error: function () { alert('메뉴그룹 조회 중 오류'); }
    });
  }

  function selectMenuItemList() {
    const groupId = $('#filterMenuGroupId').val();
    if (!groupId) {
      $('#menuItemListBody').html("<tr><td colspan='9' class='text-center empty-row py-5'>메뉴그룹을 선택하세요.</td></tr>");
      return;
    }

    $.ajax({
      url: API_ITEM + '/selectMenuItemList',
      type: 'post',
      contentType: 'application/json',
      data: JSON.stringify({ menuGroupId: groupId }), // 서버 필터 요청
      success: function (map) {
        // 서버가 필터를 무시해도 안전하게 동작하도록 클라이언트에서 한 번 더 필터
        const all = map.result || [];
        const list = all.filter(function(x){ return String(x.menuGroupId) === String(groupId); });

        const tree = buildTree(list);
        let html = '';

        if (!list.length) {
          html += "<tr><td colspan='9' class='text-center empty-row py-5'>데이터가 없습니다.</td></tr>";
        } else {
          traverseTree(tree, 'root', 0, function (r, depth) {
            let created = r.createdDt;
            if (created && typeof created === 'object') created = (created.value || String(created));

            const seBadge = '<span class="badge-soft">' + (r.menuSeCd || '') + '</span>';
            const path = (r.menuSeCd === 'BOARD')
              ? ('#' + (r.boardId || ''))
              : (r.pathUrl || '');

            html += "<tr>";
            html += "  <td class='text-end'>" + (r.menuId) + "</td>";
            html += "  <td class='name-col'>" + (indent(depth) + (r.menuNm || '')) + "</td>";
            html += "  <td>" + seBadge + "</td>";
            html += "  <td>" + path + "</td>";
            html += "  <td>" + (r.sortOrdr != null ? r.sortOrdr : '') + "</td>";
            html += "  <td>" + ((r.visibleAt || 'Y') === 'Y' ? 'Y' : 'N') + "</td>";
            html += "  <td>" + ((r.useAt || 'Y') === 'Y' ? 'Y' : 'N') + "</td>";
            html += "  <td>" + (created || '') + "</td>";
            html += "  <td><button class='btn btn-sm btn-outline-primary' type='button' onclick=\"goToMenuItemModify('" + (r.menuId) + "')\">수정</button></td>";
            html += "</tr>";
          });
        }
        $('#menuItemListBody').html(html);
      },
      error: function () { alert('목록 조회 중 오류 발생'); }
    });
  }

  // --- 트리 유틸 (키를 문자열로 정규화해서 타입불일치로 인한 누락 방지) ---
  function buildTree(list) {
    const byParent = {};
    for (let i = 0; i < list.length; i++) {
      const it = list[i];
      const parentKey = (it.upperMenuId == null || it.upperMenuId === 0 || it.upperMenuId === '0') ? 'root' : String(it.upperMenuId);
      if (!byParent[parentKey]) byParent[parentKey] = [];
      byParent[parentKey].push(it);
    }
    return byParent; // 'root' | menuId(string) -> children[]
  }

  function traverseTree(tree, parentKey, depth, cb) {
    const children = tree[parentKey] || [];
    children.sort(function(a,b){
      const s = (a.sortOrdr||0) - (b.sortOrdr||0);
      return s !== 0 ? s : ((a.menuId||0) - (b.menuId||0));
    });
    for (let i=0;i<children.length;i++) {
      cb(children[i], depth);
      traverseTree(tree, String(children[i].menuId), depth+1, cb);
    }
  }

  function indent(depth) {
    if (!depth) return '';
    var s = '';
    for (var i=0;i<depth;i++) s += '   '; // 얇은 공백
    return '└ ' + s;
  }

  function goToMenuItemModify(id) {
    const groupId = $('#filterMenuGroupId').val();
    let url = '/adm/sys/menuItem/menuItemModify';
    const qs = [];
    if (id) qs.push(menuIdParam + '=' + encodeURIComponent(id));
    if (groupId) qs.push('menuGroupId=' + encodeURIComponent(groupId));
    if (qs.length) url += '?' + qs.join('&');
    location.href = url;
  }
  function goToMenuItem() { location.href = '/adm/sys/menuItem/menuItem'; }
</script>