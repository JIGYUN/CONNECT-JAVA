<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>

<style>
  .page-wrap{max-width:760px;margin:0 auto;}
  .page-title{font-weight:700;letter-spacing:.2px}
  .card-surface{background:#fff;border:1px solid rgba(0,0,0,.06);border-radius:16px;box-shadow:0 4px 18px rgba(0,0,0,.04)}
</style>

<section class="page-wrap">
  <div class="d-flex align-items-end justify-content-between mb-3">
    <h2 class="page-title mb-0">메뉴그룹 <span id="pageTitle">등록</span></h2>
    <div class="d-flex gap-2">
      <button class="btn btn-primary" type="button" onclick="saveMenuGroup()">저장</button>
      <c:if test="${not empty param.menuGroupId}">
        <button class="btn btn-outline-danger" type="button" onclick="deleteMenuGroup()">삭제</button>
      </c:if>
      <a class="btn btn-outline-secondary" href="/adm/sys/menuGroup/menuGroupList">목록</a>
    </div>
  </div>

  <form id="menuGroupForm" class="card-surface p-3">
    <!-- PK -->
    <input type="hidden" name="menuGroupId" id="menuGroupId" value="${param.menuGroupId}"/>

    <div class="mb-3" style="max-width:520px;">
      <label for="menuGroupNm" class="form-label">메뉴그룹명</label>
      <input type="text" class="form-control" name="menuGroupNm" id="menuGroupNm"/>
    </div>

    <div class="mb-3" style="max-width:520px;">
      <label for="rm" class="form-label">비고</label>
      <input type="text" class="form-control" name="rm" id="rm" placeholder="선택 입력"/>
    </div>

    <div class="mb-2">
      <label class="form-label d-block">사용여부</label>
      <div class="form-check form-check-inline">
        <input class="form-check-input" type="radio" name="useAt" id="useY" value="Y" checked>
        <label class="form-check-label" for="useY">Y</label>
      </div>
      <div class="form-check form-check-inline">
        <input class="form-check-input" type="radio" name="useAt" id="useN" value="N">
        <label class="form-check-label" for="useN">N</label>
      </div>
    </div>
  </form>
</section>

<script>
  const API_BASE = '/api/sys/menuGroup';
  const PK = 'menuGroupId';

  $(document).ready(function () {
    const id = $("#" + PK).val();
    if (id && id !== "") {
      readMenuGroup(id);
      $("#pageTitle").text("수정");
    } else {
      $("#pageTitle").text("등록");
    }
  });

  function readMenuGroup(id) {
    const send = {}; send[PK] = id;

    $.ajax({
      url: API_BASE + "/selectMenuGroupDetail",
      type: "post",
      contentType: "application/json",
      dataType: "json",
      data: JSON.stringify(send),
      success: function (map) {
        const r = map.result || map.menuGroup || map;
        if (!r) return;

        $("#menuGroupNm").val(r.menuGroupNm || "");
        $("#rm").val(r.rm || "");
        $('input[name="useAt"][value="' + (r.useAt || 'Y') + '"]').prop('checked', true);

        $("#pageTitle").text("수정");
      },
      error: function () {
        alert("조회 중 오류 발생");
      }
    });
  }

  function saveMenuGroup() {
    const id = $("#" + PK).val();
    const url = id && id !== ""
      ? (API_BASE + "/updateMenuGroup")
      : (API_BASE + "/insertMenuGroup");

    if ($("#menuGroupNm").val() === "") {
      alert("메뉴그룹명을 입력해주세요.");
      return;
    }

    const formData = $("#menuGroupForm").serializeObject();

    $.ajax({
      url: url,
      type: "post",
      contentType: "application/json",
      dataType: "json",
      data: JSON.stringify(formData),
      success: function () {
        location.href = "/adm/sys/menuGroup/menuGroupList";
      },
      error: function () {
        alert("저장 중 오류 발생");
      }
    });
  }

  function deleteMenuGroup() {
    const id = $("#" + PK).val();
    if (!id || id === "") {
      alert("삭제할 대상의 PK가 없습니다.");
      return;
    }
    if (!confirm("정말 삭제하시겠습니까?")) return;

    const send = {}; send[PK] = id;

    $.ajax({
      url: API_BASE + "/deleteMenuGroup",
      type: "post",
      contentType: "application/json",
      dataType: "json",
      data: JSON.stringify(send),
      success: function () {
        alert("삭제 완료되었습니다.");
        location.href = "/adm/sys/menuGroup/menuGroupList";
      },
      error: function () {
        alert("삭제 중 오류 발생");
      }
    });
  }

  // serializeObject: 폼 → JSON (기존 스타일 유지)
  $.fn.serializeObject = function () {
    var obj = {};
    var arr = this.serializeArray();
    $.each(arr, function () { obj[this.name] = this.value; });
    return obj;
  };
</script>  