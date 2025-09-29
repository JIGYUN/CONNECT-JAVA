<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>

<style>
    .page-wrap { max-width: 920px; margin: 0 auto; }
    .page-title { font-weight: 700; letter-spacing: .2px; }
    .toolbar { display: flex; gap: 8px; }
    .card-surface {
        background: #fff; border:1px solid rgba(0,0,0,.06); border-radius:16px; box-shadow:0 4px 18px rgba(0,0,0,.04);
    }
    .form-label { font-weight:600; color:#5b6375; }
    /* BS4/커스텀 호환: .btn-check 숨김 */
    .btn-check{
        position:absolute; clip:rect(0,0,0,0); width:1px; height:1px; margin:-1px; overflow:hidden; white-space:nowrap; border:0; padding:0;
    }
    .btn-toggle-group .btn { min-width:48px; }
    .btn-check:checked + .btn {
        border-color:#0d6efd;
        box-shadow: inset 0 0 0 1px rgba(13,110,253,.3);
        background: rgba(13,110,253,.06);
        color:#0d6efd;
    }
</style>

<section class="page-wrap">
    <div class="d-flex align-items-end justify-content-between mb-3">
        <h2 class="page-title mb-0">공통코드 <span id="pageTitle" class="text-muted" style="font-weight:500;">등록</span></h2>
        <div class="toolbar">
            <button class="btn btn-primary" type="button" onclick="saveCmmnCode()">저장</button>
            <c:if test="${not empty param.codeId}">
                <button class="btn btn-outline-danger" type="button" onclick="deleteCmmnCode()">삭제</button>
            </c:if>
            <a class="btn btn-outline-secondary" href="/adm/sys/cmmnCode/cmmnCodeList">목록</a>
        </div>
    </div>

    <div class="card-surface p-4">
        <form id="cmmnCodeForm">
            <!-- PK (수정 시만 값 존재) -->
            <input type="hidden" name="codeId" id="codeId" value="${param.codeId}"/>

            <div class="row g-3">
                <div class="col-md-6">
                    <label for="codeClId" class="form-label">코드그룹</label>
                    <select class="form-select" name="codeClId" id="codeClId">
                        <option value="">선택하세요</option>
                    </select>
                </div>

                <div class="col-md-6">
                    <label for="code" class="form-label">코드</label>
                    <input type="text" class="form-control" name="code" id="code" maxlength="60" placeholder="예) STATUS_ACTIVE"/>
                </div>

                <div class="col-md-8">
                    <label for="codeNm" class="form-label">코드명</label>
                    <input type="text" class="form-control" name="codeNm" id="codeNm" maxlength="100" placeholder="예) 활성"/>
                </div>

                <div class="col-md-2">
                    <label for="sortOrdr" class="form-label">정렬순서</label>
                    <input type="number" class="form-control" name="sortOrdr" id="sortOrdr" min="0" step="1" value="0"/>
                </div>

                <div class="col-md-4">
                    <label class="form-label d-block">사용여부</label>
                    <div class="btn-toggle-group" role="group" aria-label="useAt">
                        <input type="radio" class="btn-check" name="useAt" id="useY" value="Y" checked>
                        <label class="btn btn-outline-primary" for="useY">Y</label>
                        <input type="radio" class="btn-check" name="useAt" id="useN" value="N">
                        <label class="btn btn-outline-secondary" for="useN">N</label>
                    </div>
                </div>
            </div>
        </form>
    </div>
</section>

<script>
    const API_BASE = '/api/sys/cmmnCode';
    const API_CODE_CL = '/api/sys/cmmnCodeCl';
    const PK = 'codeId';

    $(document).ready(function () {
        loadCodeClOptions(function () {
            const qCl = getParam('codeClId');
            if (qCl) $('#codeClId').val(qCl);
            const id = $("#" + PK).val();
            if (id && id !== "") {
                readCmmnCode(id);
                $("#pageTitle").text("수정");
            } else {
                $("#pageTitle").text("등록");
            }
        });
    });

    function loadCodeClOptions(cb) {
        $.ajax({
            url: API_CODE_CL + '/selectCmmnCodeClList',
            type: 'post',
            contentType: 'application/json',
            data: JSON.stringify({}),
            success: function (map) {
                const list = map.result || [];
                let html = '<option value="">선택하세요</option>';
                for (let i = 0; i < list.length; i++) {
                    const r = list[i];
                    html += '<option value="' + (r.codeClId) + '">' + (r.codeClNm || ('#' + r.codeClId)) + '</option>';
                }
                $('#codeClId').html(html);
                if (typeof cb === 'function') cb();
            },
            error: function () { if (typeof cb === 'function') cb(); }
        });
    }

    function readCmmnCode(id) {
        const sendData = {}; sendData[PK] = id;
        $.ajax({
            url: API_BASE + "/selectCmmnCodeDetail",
            type: "post",
            contentType: "application/json",
            dataType: "json",
            data: JSON.stringify(sendData),
            success: function (map) {
                const r = map.result || map.cmmnCode || map;
                if (!r) return;
                $("#codeClId").val(r.codeClId || "");
                $("#code").val(r.code || "");
                $("#codeNm").val(r.codeNm || "");
                $("#sortOrdr").val(r.sortOrdr != null ? r.sortOrdr : 0);
                const useAt = (r.useAt || "Y");
                if (useAt === 'Y') $("#useY").prop("checked", true); else $("#useN").prop("checked", true);
            },
            error: function () { alert("조회 중 오류 발생"); }
        });
    }

    function saveCmmnCode() {
        if (!$('#codeClId').val()) { alert('코드그룹을 선택하세요.'); $('#codeClId').focus(); return; }
        if ($('#code').val().trim() === "") { alert("코드를 입력해주세요."); $('#code').focus(); return; }
        if ($('#codeNm').val().trim() === "") { alert("코드명을 입력해주세요."); $('#codeNm').focus(); return; }

        const id = $("#" + PK).val();
        const url = id && id !== "" ? (API_BASE + "/updateCmmnCode") : (API_BASE + "/insertCmmnCode");
        const formData = $("#cmmnCodeForm").serializeObject();

        $.ajax({
            url: url, type: "post", contentType: "application/json", dataType: "json",
            data: JSON.stringify(formData),
            success: function () { location.href = "/adm/sys/cmmnCode/cmmnCodeList"; },
            error: function () { alert("저장 중 오류 발생"); }
        });
    }

    function deleteCmmnCode() {
        const id = $("#" + PK).val();
        if (!id) { alert("삭제할 대상의 PK가 없습니다."); return; }
        if (!confirm("정말 삭제하시겠습니까?")) return;

        const sendData = {}; sendData[PK] = id;
        $.ajax({
            url: API_BASE + "/deleteCmmnCode", type: "post",
            contentType: "application/json", dataType: "json", data: JSON.stringify(sendData),
            success: function () { alert("삭제 완료되었습니다."); location.href = "/adm/sys/cmmnCode/cmmnCodeList"; },
            error: function () { alert("삭제 중 오류 발생"); }
        });
    }

    // 공통 유틸 (스타일 유지)
    $.fn.serializeObject = function () {
        let obj = {}; const arr = this.serializeArray();
        $.each(arr, function () { obj[this.name] = this.value; }); return obj;
    };
    function getParam(k) {
        const q = window.location.search.substring(1).split('&');
        for (let i = 0; i < q.length; i++) { const p = q[i].split('='); if (decodeURIComponent(p[0]) === k) return decodeURIComponent(p[1] || ''); }
        return '';
    }
</script> 