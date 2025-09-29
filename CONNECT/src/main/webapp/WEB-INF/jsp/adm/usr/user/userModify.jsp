<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>

<section>
  <h2 class="mb-3">회원 <span id="pageTitle">등록</span></h2>

  <div class="mb-3">
    <button class="btn btn-primary" type="button" onclick="saveUser()">저장</button>
    <c:if test="${not empty param.userId}">
      <button class="btn btn-outline-danger" type="button" onclick="deleteUser()">삭제</button>
    </c:if>
    <a class="btn btn-outline-secondary" href="/adm/usr/user/userList">목록</a>
  </div>

  <form id="userForm" autocomplete="off">
    <!-- PK -->
    <input type="hidden" name="userId" id="userId" value="${param.userId}"/>

    <div class="row" style="max-width:980px;">
      <div class="col-md-6">
        <div class="form-group">
          <label for="email">이메일</label>
          <input type="email" class="form-control" name="email" id="email" required />
        </div>

        <div class="form-group">
          <label for="password">비밀번호 <small class="text-muted">(수정 시 비워두면 변경 없음)</small></label>
          <input type="password" class="form-control" name="password" id="password" />
        </div>

        <div class="form-group">
          <label for="userNm">이름</label>
          <input type="text" class="form-control" name="userNm" id="userNm" />
        </div>

        <div class="form-group">
          <label for="telno">전화번호</label>
          <input type="text" class="form-control" name="telno" id="telno" />
        </div>
      </div>

      <div class="col-md-6">
        <div class="form-group">
          <label for="userSttsCd">상태</label>
          <select class="form-control" name="userSttsCd" id="userSttsCd">
            <option value="ACTIVE">ACTIVE</option>
            <option value="LOCK">LOCK</option>
            <option value="SUSPENDED">SUSPENDED</option>
          </select>
        </div>

        <div class="form-group">
          <label for="emailVrfctAt">이메일 인증</label>
          <select class="form-control" name="emailVrfctAt" id="emailVrfctAt">
            <option value="N">N</option>
            <option value="Y">Y</option>
          </select>
        </div>

        <div class="form-group">
          <label for="useAt">사용 여부</label>
          <select class="form-control" name="useAt" id="useAt">
            <option value="Y">Y</option>
            <option value="N">N</option>
          </select>
        </div>

        <!-- 운영툴 전용: AUTH_TYPE(U/A). 프론트 회원가입에서는 서버에서 무조건 U로 강제 -->
        <div class="form-group">
          <label for="authType">유형(A/U)</label>
          <select class="form-control" name="authType" id="authType">
            <option value="U">U (일반)</option>
            <option value="A">A (관리자)</option>
          </select>
        </div>

        <!-- 시스템 표시용(읽기전용) -->
        <div class="form-group">
          <label>최근 로그인</label>
          <input type="text" class="form-control" id="lastLoginDt" disabled />
        </div>
        <div class="form-group">
          <label>가입일</label>
          <input type="text" class="form-control" id="createdDt" disabled />
        </div>
      </div>
    </div>
  </form>
</section>

<script>
  const API_BASE = '/api/usr/user';
  const PK = 'userId';

  $(function(){
    const id = $("#" + PK).val();
    if (id) {
      $("#pageTitle").text("수정");
      readUser(id);
    } else {
      $("#pageTitle").text("등록");
      // 기본값
      $('#userSttsCd').val('ACTIVE');
      $('#emailVrfctAt').val('N');
      $('#useAt').val('Y');
      $('#authType').val('U');
    }
  });

  function fmt(dt){
    if (!dt) return '';
    if (typeof dt === 'object') dt = dt.value || String(dt);
    return String(dt).replace('T',' ').replace('.000Z','');
  }

  function readUser(id){
    const send = {}; send[PK] = id;

    $.ajax({
      url: API_BASE + '/selectUserDetail',
      type: 'post',
      contentType: 'application/json',
      dataType: 'json',
      data: JSON.stringify(send),
      success: function(map){
        const r = map.result || map.user || map;
        if (!r) return;

        $('#email').val(r.email || '');
        $('#userNm').val(r.userNm || '');
        $('#telno').val(r.telno || '');
        $('#userSttsCd').val(r.userSttsCd || 'ACTIVE');
        $('#emailVrfctAt').val(r.emailVrfctAt || 'N');
        $('#useAt').val(r.useAt || 'Y');
        $('#authType').val(r.authType || 'U');

        $('#lastLoginDt').val(fmt(r.lastLoginDt));
        $('#createdDt').val(fmt(r.createdDt));
      },
      error: function(){ alert('조회 중 오류 발생'); }
    });
  }

  function saveUser(){
    const id = $("#" + PK).val();
    const isUpdate = !!id;
    const url = isUpdate ? (API_BASE + '/updateUser') : (API_BASE + '/insertUser');

    // 기본 검증
    const email = $('#email').val();
    if (!email){ alert('이메일을 입력하세요.'); return; }
    if (!isUpdate && !$('#password').val()){ alert('비밀번호를 입력하세요.'); return; }

    // 폼 -> JSON
    const data = $('#userForm').serializeObject();

    // 비밀번호 비워두면 업데이트 시 제외(서버에서도 빈 문자열이면 무시하도록)
    if (isUpdate && (!data.password || data.password.trim()==='')) {
      delete data.password;
    }

    $.ajax({
      url, type:'post',
      contentType:'application/json',
      dataType:'json',
      data: JSON.stringify(data),
      success: function(){
        location.href='/adm/usr/user/userList';
      },
      error: function(){ alert('저장 중 오류 발생'); }
    });
  }

  function deleteUser(){
    const id = $("#" + PK).val();
    if (!id){ alert('삭제할 대상의 PK가 없습니다.'); return; }
    if (!confirm('정말 삭제하시겠습니까?')) return;

    const send = {}; send[PK] = id;

    $.ajax({
      url: API_BASE + '/deleteUser',
      type: 'post',
      contentType: 'application/json',
      dataType: 'json',
      data: JSON.stringify(send),
      success: function(){
        alert('삭제 완료되었습니다.');
        location.href='/adm/usr/user/userList';
      },
      error: function(){ alert('삭제 중 오류 발생'); }
    });
  }

  // serializeObject: 폼 → JSON
  $.fn.serializeObject = function () {
    let obj = {};
    const arr = this.serializeArray();
    $.each(arr, function () { obj[this.name] = this.value; });
    return obj;
  };
</script>  