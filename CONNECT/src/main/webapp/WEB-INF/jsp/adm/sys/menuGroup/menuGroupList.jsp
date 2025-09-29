<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<style>
  .page-wrap{max-width:1160px;margin:0 auto;}
  .page-title{font-weight:700;letter-spacing:.2px}
  .toolbar{display:flex;gap:8px;align-items:center}
  .card-surface{background:#fff;border:1px solid rgba(0,0,0,.06);border-radius:16px;box-shadow:0 4px 18px rgba(0,0,0,.04)}
  .table thead th{background:#f5f7fb;color:#5b6375;font-weight:600;border-bottom:1px solid rgba(0,0,0,.06)}
  .empty-row{color:#99a1b3}
  .row-click{cursor:pointer}
</style>

<section class="page-wrap">
  <div class="d-flex align-items-end justify-content-between mb-3">
    <h2 class="page-title mb-0">메뉴그룹 목록</h2>
    <div class="toolbar">
      <button class="btn btn-primary" type="button" onclick="goToMenuGroupModify()">등록</button>
      <button class="btn btn-outline-secondary" type="button" onclick="goToMenuGroup()">통합</button>
    </div>
  </div>

  <div class="card-surface p-2">
    <div class="table-responsive">
      <table class="table table-hover align-middle mb-0">
        <thead>
          <tr>
            <th style="width:90px;text-align:right;">ID</th>
            <th>메뉴그룹명</th>
            <th>비고</th>
            <th style="width:90px;">사용</th>
            <th style="width:200px;">생성일</th>
            <th style="width:110px;">관리</th>
          </tr>
        </thead>
        <tbody id="menuGroupListBody"></tbody>
      </table>
    </div>
  </div>
</section>

<script>
  // ▼ JavaGen 치환 스타일 유지
  const API_BASE = '/api/sys/menuGroup';
  const menuGroupIdParam = 'menuGroupId';

  $(function () {
    selectMenuGroupList();
  });

  function selectMenuGroupList() {
    $.ajax({
      url: API_BASE + '/selectMenuGroupList',
      type: 'post',
      contentType: 'application/json',
      data: JSON.stringify({}),
      success: function (map) {
        const list = map.result || [];
        let html = '';

        if (!list.length) {
          html += "<tr><td colspan='6' class='text-center empty-row py-5'>등록된 데이터가 없습니다.</td></tr>";
        } else {
          for (let i = 0; i < list.length; i++) {
            const r = list[i];
            let created = r.createdDt;
            if (created && typeof created === 'object') created = (created.value || String(created));

            html += "<tr class='row-click' onclick=\"goToMenuGroupModify('" + (r.menuGroupId) + "')\">";
            html += "  <td class='text-end'>" + (r.menuGroupId) + "</td>";
            html += "  <td>" + (r.menuGroupNm || '') + "</td>";
            html += "  <td>" + (r.rm || '') + "</td>";
            html += "  <td>" + ((r.useAt || 'Y') === 'Y' ? 'Y' : 'N') + "</td>";
            html += "  <td>" + (created || '') + "</td>";
            html += "  <td><button class='btn btn-sm btn-outline-primary' type='button' onclick=\"event.stopPropagation(); goToMenuGroupModify('" + (r.menuGroupId) + "')\">수정</button></td>";
            html += "</tr>";
          }
        }

        $('#menuGroupListBody').html(html);
      },
      error: function () {
        alert('목록 조회 중 오류 발생');
      }
    });
  }

  function goToMenuGroupModify(id) {
    let url = '/adm/sys/menuGroup/menuGroupModify';
    if (id) url += '?' + menuGroupIdParam + '=' + encodeURIComponent(id);
    location.href = url;
  }

  function goToMenuGroup() {
    location.href = '/adm/sys/menuGroup/menuGroup';
  }
</script>
