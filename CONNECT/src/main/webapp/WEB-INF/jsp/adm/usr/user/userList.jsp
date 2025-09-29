<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<section>
  <h2 class="mb-3">회원 목록</h2>

  <div class="mb-3">
    <button class="btn btn-primary" type="button" onclick="goToUserModify()">등록</button>
    <button class="btn btn-outline-secondary" type="button" onclick="goToUser()">통합</button>
  </div>

  <div class="table-responsive">
    <table class="table table-hover align-middle">
      <thead class="thead-light">
        <tr>
          <th style="width: 90px; text-align:right;">번호</th>
          <th style="width: 260px;">이메일</th>
          <th style="width: 160px;">이름</th>
          <th style="width: 120px;">상태</th>
          <th style="width: 100px;">유형</th>
          <th style="width: 200px;">최근 로그인</th>
          <th style="width: 200px;">가입일</th>
        </tr>
      </thead>
      <tbody id="userListBody"></tbody>
    </table>
  </div>
</section>

<script>
  // ▼ JavaGen 치환
  const API_BASE = '/api/usr/user';
  const PK = 'userId';

  $(function () {
    selectUserList();
  });

  function fmt(dt){
    if (!dt) return '';
    if (typeof dt === 'object') dt = dt.value || String(dt);
    return String(dt).replace('T',' ').replace('.000Z','');
  }

  function selectUserList() {
    $.ajax({
      url: API_BASE + '/selectUserList',
      type: 'post',
      contentType: 'application/json',
      data: JSON.stringify({}),
      success: function (map) {
        const list = map.result || [];
        let html = '';

        if (!list.length) {
          html += "<tr><td colspan='7' class='text-center text-muted'>등록된 데이터가 없습니다.</td></tr>";
        } else {
          for (let i = 0; i < list.length; i++) {
            const r = list[i];
            html += "<tr onclick=\"goToUserModify('" + (r.userId) + "')\">";
            html += "  <td class='text-right'>" + (r.userId ?? '') + "</td>";
            html += "  <td>" + (r.email ?? '') + "</td>";
            html += "  <td>" + (r.userNm ?? '') + "</td>";
            html += "  <td>" + (r.userSttsCd ?? '') + "</td>";
            html += "  <td>" + (r.authType ?? '') + "</td>";
            html += "  <td>" + fmt(r.lastLoginDt) + "</td>";
            html += "  <td>" + fmt(r.createdDt) + "</td>";
            html += "</tr>";
          }
        }
        $('#userListBody').html(html);
      },
      error: function () { alert('목록 조회 중 오류 발생'); }
    });
  }

  function goToUserModify(id) {
    let url = '/adm/usr/user/userModify';
    if (id) url += '?' + PK + '=' + encodeURIComponent(id);
    location.href = url;
  }
  function goToUser() { location.href = '/adm/usr/user/user'; }
</script>