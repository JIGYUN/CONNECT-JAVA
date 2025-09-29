<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>

<style>
    :root{ --bg:#f6f8fb; --card:#ffffff; --line:#e9edf3; --text:#0f172a; --muted:#6b7280; }
    body{ background:var(--bg); }
    .page-title{ font-size:28px; font-weight:700; color:var(--text); margin-bottom:12px; }
    .toolbar{ display:flex; gap:10px; align-items:center; flex-wrap:wrap; margin:8px 0 18px; }
    .card{ background:var(--card); border:1px solid var(--line); border-radius:16px; box-shadow:0 2px 8px rgba(15,23,42,.05); padding:18px; max-width:760px; }
    .form-label{ font-weight:600; color:#334155; }
    .btn,.form-select,.form-control{ border-radius:12px; }
    .mono{ font-family: ui-monospace,SFMono-Regular,Menlo,Monaco,Consolas,"Liberation Mono","Courier New",monospace; }
    .hint{ color:#6b7280; font-size:12px; margin-top:6px; }
</style>

<section>
    <h2 class="page-title">코드그룹 <span id="pageTitle" class="text-muted" style="font-size:16px;">등록</span></h2>

    <div class="toolbar">
        <button class="btn btn-primary" type="button" onclick="saveCmmnCodeCl()">저장</button>
        <c:if test="${not empty param.codeClId}">
            <button class="btn btn-outline-danger" type="button" onclick="deleteCmmnCodeCl()">삭제</button>
        </c:if>
        <a class="btn btn-outline-secondary" href="/adm/sys/cmmnCodeCl/cmmnCodeClList">목록</a>
    </div>

    <form id="cmmnCodeClForm" class="card">
        <input type="hidden" name="codeClId" id="codeClId" value="${param.codeClId}"/>

        <div class="mb-3">
            <label for="codeCl" class="form-label">그룹값 (CODE_CL)</label>
            <input type="text" class="form-control mono" name="codeCl" id="codeCl" placeholder="예) BOARD_READ_LVL">
            <div class="hint">영문 대문자/언더스코어 권장. 예: <span class="mono">BOARD_READ_LVL</span></div>
        </div>

        <div class="mb-3">
            <label for="codeClNm" class="form-label">그룹명 (CODE_CL_NM)</label>
            <input type="text" class="form-control" name="codeClNm" id="codeClNm" placeholder="예) 게시판읽기권한">
        </div>

        <div class="mb-3">
            <label for="useAt" class="form-label">사용여부 (USE_AT)</label>
            <select id="useAt" name="useAt" class="form-select">
                <option value="Y">Y</option>
                <option value="N">N</option>
            </select>
        </div>
    </form>
</section>

<script>
    const API_BASE = '/api/sys/cmmnCodeCl';
    const PK = 'codeClId';

    $(document).ready(function () {
        // 신규/수정 분기
        const id = $("#" + PK).val();
        if (id && id !== "") {
            readCmmnCodeCl(id);
            $("#pageTitle").text("수정");
        } else {
            $("#pageTitle").text("등록");
        }

        // 입력 보조: codeCl을 항상 대문자/언더스코어 스타일로
        $('#codeCl').on('input', function(){
            const v = $(this).val().toUpperCase().replace(/[^A-Z0-9_]/g,'_');
            $(this).val(v);
        });
    });

    function readCmmnCodeCl(id) {
        const sendData = {};  
        sendData[PK] = id;

        $.ajax({
            url: API_BASE + "/selectCmmnCodeClDetail",
            type: "post",
            contentType: "application/json",
            dataType: "json",
            data: JSON.stringify(sendData),
            success: function (map) {
                const r = map.result || map.cmmnCodeCl || map;
                if (!r) return;

                $("#codeCl").val(r.codeCl || r.CODE_CL || "");
                $("#codeClNm").val(r.codeClNm || r.CODE_CL_NM || "");
                $("#useAt").val((r.useAt || r.USE_AT || 'Y').toUpperCase() === 'N' ? 'N' : 'Y');
            },
            error: function () {
                alert("조회 중 오류 발생");
            }
        });
    }

    function saveCmmnCodeCl() {
        const id = $("#" + PK).val();
        const url = id && id !== ""
            ? (API_BASE + "/updateCmmnCodeCl")
            : (API_BASE + "/insertCmmnCodeCl");

        // 검증
        if ($("#codeCl").val().trim() === "") {
            alert("그룹값을 입력해주세요.");
            $("#codeCl").focus();
            return;
        }
        if ($("#codeClNm").val().trim() === "") {
            alert("그룹명을 입력해주세요.");
            $("#codeClNm").focus();
            return;
        }

        // 전송 데이터
        const formData = $("#cmmnCodeClForm").serializeObject();

        $.ajax({
            url: url,
            type: "post",
            contentType: "application/json",
            dataType: "json",
            data: JSON.stringify(formData),
            success: function () {
                location.href = "/adm/sys/cmmnCodeCl/cmmnCodeClList";
            },
            error: function () {
                alert("저장 중 오류 발생");
            }
        });
    }

    function deleteCmmnCodeCl() {
        const id = $("#" + PK).val();
        if (!id || id === "") {
            alert("삭제할 대상의 PK가 없습니다.");
            return;
        }
        if (!confirm("정말 삭제하시겠습니까?")) return;

        const sendData = {};
        sendData[PK] = id;

        $.ajax({
            url: API_BASE + "/deleteCmmnCodeCl",
            type: "post",
            contentType: "application/json",
            dataType: "json",
            data: JSON.stringify(sendData),
            success: function () {
                alert("삭제 완료되었습니다.");
                location.href = "/adm/sys/cmmnCodeCl/cmmnCodeClList";
            },
            error: function () {
                alert("삭제 중 오류 발생");
            }
        });
    }

    // serializeObject: 폼 → JSON
    $.fn.serializeObject = function () {
        var obj = {};
        var arr = this.serializeArray();
        $.each(arr, function () { obj[this.name] = this.value; });
        return obj;
    };
</script>  