<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>

<!-- (선택) Toast UI Editor 로더: 사용은 안하지만 기존 로드 흐름 호환용 -->
<link rel="stylesheet" href="https://uicdn.toast.com/editor/latest/toastui-editor.min.css" />
<script src="https://uicdn.toast.com/editor/latest/toastui-editor-all.min.js"></script>

<style>
	:root{
		--bg:#f6f8fb; --card:#ffffff; --line:#e9edf3; --text:#0f172a; --muted:#6b7280; --primary:#1f6feb;
	}
	body{background:var(--bg);}
	.page-title{font-size:28px; font-weight:700; letter-spacing:.2px; color:var(--text);}
	.toolbar{display:flex; gap:8px; margin:12px 0 18px;}
	.card{background:var(--card); border:1px solid var(--line); border-radius:16px; box-shadow:0 2px 8px rgba(15,23,42,.04);}
	.card .card-body{padding:20px;}
	.form-label{font-weight:600; color:var(--muted);}
	.form-control,.form-select{border-radius:12px; border-color:var(--line);}
	.form-control:focus,.form-select:focus{border-color:var(--primary); box-shadow:0 0 0 .15rem rgba(31,111,235,.15);}
	.helper{font-size:12px; color:var(--muted);}
	.sticky-actions{position:sticky; top:0; background:var(--bg); padding:8px 0; z-index:2;}
	.btn{border-radius:12px;}
</style>

<section>
	<div class="sticky-actions">
		<h2 class="page-title">게시판 정의 <span id="pageTitle" class="text-muted" style="font-weight:600;font-size:18px;">수정</span></h2>
		<div class="toolbar">
			<button class="btn btn-primary" type="button" onclick="saveBoardDef()">저장</button>
			<c:if test="${not empty param.boardId}">
				<button class="btn btn-outline-danger" type="button" onclick="deleteBoardDef()">삭제</button>
			</c:if>
			<a class="btn btn-outline-secondary" href="/brd/boardDef/boardDefList">목록</a>
		</div>
	</div>

	<form id="boardDefForm" class="card" autocomplete="off">
		<input type="hidden" name="boardId" id="boardId" value="${param.boardId}"/>
		<div class="card-body">
			<div class="row g-3">
				<div class="col-md-4">
					<label for="boardCd" class="form-label">코드</label>
					<input type="text" class="form-control" name="boardCd" id="boardCd" maxlength="64" placeholder="NOTICE, QNA 등"/>
					<div class="helper">영문 대문자/숫자/언더스코어만</div>
				</div>
				<div class="col-md-5">
					<label for="boardNm" class="form-label">게시판명</label>
					<input type="text" class="form-control" name="boardNm" id="boardNm" maxlength="100" placeholder="공지사항"/>
				</div>
				<div class="col-md-3">
					<label for="slug" class="form-label">슬러그(URL)</label>
					<input type="text" class="form-control" name="slug" id="slug" maxlength="100" placeholder="notice"/>
				</div>

				<div class="col-md-3">
					<label for="readLvlCd" class="form-label">읽기권한</label>
					<select class="form-select" name="readLvlCd" id="readLvlCd">
						<option value="ANY">전체</option>
						<option value="MEMBER">회원</option>
						<option value="ADMIN">관리자</option>
					</select>
				</div>
				<div class="col-md-3">
					<label for="writeLvlCd" class="form-label">쓰기권한</label>
					<select class="form-select" name="writeLvlCd" id="writeLvlCd">
						<option value="MEMBER">회원</option>
						<option value="ADMIN">관리자</option>
					</select>
				</div>
				<div class="col-md-2">
					<label for="useCommentAt" class="form-label">댓글</label>
					<select class="form-select" name="useCommentAt" id="useCommentAt">
						<option value="Y">사용</option>
						<option value="N">미사용</option>
					</select>
				</div>
				<div class="col-md-2">
					<label for="useAttachAt" class="form-label">첨부</label>
					<select class="form-select" name="useAttachAt" id="useAttachAt">
						<option value="Y">사용</option>
						<option value="N">미사용</option>
					</select>
				</div>
				<div class="col-md-2">
					<label for="sortDefaultCd" class="form-label">기본정렬</label>
					<select class="form-select" name="sortDefaultCd" id="sortDefaultCd">
						<option value="LATEST">최신순</option>
						<option value="POPULAR">인기순</option>
						<option value="PINNED">고정우선</option>
					</select>
				</div>
				<div class="col-md-2">
					<label for="useAt" class="form-label">사용여부</label>
					<select class="form-select" name="useAt" id="useAt">
						<option value="Y">Y</option>
						<option value="N">N</option>
					</select>
				</div>
			</div>
		</div>
	</form>
</section>

<script>
	const API_BASE = '/api/brd/boardDef';
	const PK = 'boardId';

	function normalizeCode(v){ return (v||'').toUpperCase().replace(/[^A-Z0-9_]/g,'').replace(/_+/g,'_'); }
	function slugify(v){ return (v||'').trim().toLowerCase().replace(/[^a-z0-9]+/g,'-').replace(/-+/g,'-').replace(/^-|-$|/g,''); }

	$(function () {
		$('#boardNm').on('input', function(){ if(!$('#slug').val()) $('#slug').val(slugify($(this).val())); });
		$('#boardCd').on('input', function(){
			const v = normalizeCode($(this).val());
			if($(this).val() !== v) $(this).val(v);
			if(!$('#slug').val()) $('#slug').val($(this).val().toLowerCase());
		});

		const id = $("#" + PK).val();
		if (id) { readBoardDef(id); $("#pageTitle").text("수정"); }
		else { $("#pageTitle").text("등록"); }
	});

	function readBoardDef(id) {
		const sendData = {}; sendData[PK] = id;
		$.ajax({
			url: API_BASE + "/selectBoardDefDetail",
			type: "post",
			contentType: "application/json",
			dataType: "json",
			data: JSON.stringify(sendData),
			success: function (map) {
				const r = map.result || map.boardDef || map;
				if (!r) return;
				$("#boardCd").val(r.boardCd || r.BOARD_CD || "");
				$("#boardNm").val(r.boardNm || r.BOARD_NM || "");
				$("#slug").val(r.slug || r.SLUG || "");
				$("#readLvlCd").val(r.readLvlCd || r.READ_LVL_CD || "ANY");
				$("#writeLvlCd").val(r.writeLvlCd || r.WRITE_LVL_CD || "MEMBER");
				$("#useCommentAt").val(r.useCommentAt || r.USE_COMMENT_AT || "Y");
				$("#useAttachAt").val(r.useAttachAt || r.USE_ATTACH_AT || "Y");
				$("#sortDefaultCd").val(r.sortDefaultCd || r.SORT_DEFAULT_CD || "LATEST");
				$("#useAt").val(r.useAt || r.USE_AT || "Y");
			},
			error: function () { alert("조회 중 오류 발생"); }
		});
	}

	function saveBoardDef() {
		const id = $("#" + PK).val();
		const url = id ? (API_BASE + "/updateBoardDef") : (API_BASE + "/insertBoardDef");

		if (!$("#boardCd").val()) { alert("코드를 입력해주세요."); $("#boardCd").focus(); return; }
		if (!$("#boardNm").val()) { alert("게시판명을 입력해주세요."); $("#boardNm").focus(); return; }

		$("#boardCd").val(normalizeCode($("#boardCd").val()));
		if (!$("#slug").val()) $("#slug").val($("#boardCd").val().toLowerCase());

		const formData = $("#boardDefForm").serializeObject();
		$.ajax({
			url, type:"post", contentType:"application/json", dataType:"json",
			data: JSON.stringify(formData),
			success: function(){ location.href="/brd/boardDef/boardDefList"; },
			error: function(){ alert("저장 중 오류 발생"); }
		});
	}

	function deleteBoardDef() {
		const id = $("#" + PK).val();
		if (!id) { alert("삭제할 대상의 PK가 없습니다."); return; }
		if (!confirm("정말 삭제하시겠습니까?")) return;

		const sendData = {}; sendData[PK] = id;
		$.ajax({
			url: API_BASE + "/deleteBoardDef",
			type: "post",
			contentType: "application/json",
			dataType: "json",
			data: JSON.stringify(sendData),
			success: function(){ alert("삭제 완료되었습니다."); location.href="/brd/boardDef/boardDefList"; },
			error: function(){ alert("삭제 중 오류 발생"); }
		});
	}

	// serializeObject: 폼 → JSON
	$.fn.serializeObject = function () {
		let obj = {}; const arr = this.serializeArray();
		$.each(arr, function(){ obj[this.name] = this.value; }); return obj;
	};
</script>