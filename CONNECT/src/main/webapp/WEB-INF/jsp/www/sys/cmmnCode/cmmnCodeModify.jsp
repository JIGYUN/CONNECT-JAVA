<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>

<style>
    .page-wrap { max-width: 920px; margin: 0 auto; }
    .page-title { font-weight: 700; letter-spacing: .2px; }
    .toolbar { display: flex; gap: 8px; }
    .card-surface {
        background: #fff;
        border: 1px solid rgba(0,0,0,.06);
        border-radius: 16px;
        box-shadow: 0 4px 18px rgba(0,0,0,.04);
    }
    .form-label { font-weight: 600; color: #5b6375; }
</style>

<section class="page-wrap">
    <div class="d-flex align-items-end justify-content-between mb-3">
        <h2 class="page-title mb-0">공통코드 <span id="pageTitle" class="text-muted" style="font-weight:500;">수정</span></h2>
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
            <!-- PK (치환 대상) -->
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

                <div class="col-md-2">
                    <label class="form-label d-block">사용여부</label>
                    <div class="btn-group" role="group" aria-label="useAt">
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
        // 그룹 옵션 먼저 적재
        loadCodeClOptions(function () {
            const id = $("#" + PK).val();
            if (id && id !== "") {
                readCmmnCode(id);
                $("#pageTitle").text("수정");
            } else {
                // 목록에서 그룹을 넘겨온 경우 기본 선택
                const qCl = getParam('codeClId');
                if (qCl) $('#codeClId').val(qCl);
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
                const list = map.result || map.list || [];
                const $sel = $('#codeClId');
                for (var i = 0; i < list.length; i++) {
                    var r = list[i];
                    var id = pick(r, ['codeClId','codeClID','cmmnCodeClId','cmmnCodeClIdx','id']);
                    var nm = pick(r, ['codeClNm','name','title','nm','clNm','clName']);
                    if (id != null && id !== '') {
                        $sel.append('<option value="'+ id +'">'+ (nm || ('#'+id)) +'</option>');
                    }
                }
                if (typeof cb === 'function') cb();
            },
            error: function () {
                if (typeof cb === 'function') cb();
            }
        });
    }

    function readCmmnCode(id) {
        var sendData = {};
        sendData[PK] = id;

        $.ajax({
            url: API_BASE + "/selectCmmnCodeDetail",
            type: "post",
            contentType: "application/json",
            dataType: "json",
            data: JSON.stringify(sendData),
            success: function (map) {
                var r = map.result || map.cmmnCode || map;

                $('#codeClId').val(pick(r, ['codeClId','codeClID']) || '');
                $('#code').val(pick(r, ['code']) || '');
                $('#codeNm').val(pick(r, ['codeNm','name','title']) || '');
                var so = pick(r, ['sortOrdr','sort','order','ord']);
                $('#sortOrdr').val(so != null ? so : 0);
                var ua = (pick(r, ['useAt']) || 'Y');
                if (ua === 'N') $('#useN').prop('checked', true); else $('#useY').prop('checked', true);
            },
            error: function () {
                alert("조회 중 오류 발생");
            }
        });
    }

    function saveCmmnCode() {
        var id = $("#" + PK).val();
        var url = id && id !== "" ? (API_BASE + "/updateCmmnCode") : (API_BASE + "/insertCmmnCode");

        // 필수값 체크
        if (!$('#codeClId').val()) {
            alert('코드그룹을 선택하세요.');
            $('#codeClId').focus();
            return;
        }
        if ($('#code').val().trim() === "") {
            alert("코드를 입력해주세요.");
            $('#code').focus();
            return;
        }
        if ($('#codeNm').val().trim() === "") {
            alert("코드명을 입력해주세요.");
            $('#codeNm').focus();
            return;
        }

        var formData = $("#cmmnCodeForm").serializeObject();

        $.ajax({
            url: url,
            type: "post",
            contentType: "application/json",
            dataType: "json",
            data: JSON.stringify(formData),
            success: function () {
                location.href = "/adm/sys/cmmnCode/cmmnCodeList";
            },
            error: function () {
                alert("저장 중 오류 발생");
            }
        });
    }

    function deleteCmmnCode() {
        var id = $("#" + PK).val();
        if (!id || id === "") {
            alert("삭제할 대상의 PK가 없습니다.");
            return;
        }
        if (!confirm("정말 삭제하시겠습니까?")) return;

        var sendData = {};
        sendData[PK] = id;

        $.ajax({
            url: API_BASE + "/deleteCmmnCode",
            type: "post",
            contentType: "application/json",
            dataType: "json",
            data: JSON.stringify(sendData),
            success: function () {
                alert("삭제 완료되었습니다.");
                location.href = "/adm/sys/cmmnCode/cmmnCodeList";
            },
            error: function () {
                alert("삭제 중 오류 발생");
            }
        });
    }

    // ---- helpers ----
    $.fn.serializeObject = function () {
        var obj = {};
        var arr = this.serializeArray();
        $.each(arr, function () {
            obj[this.name] = this.value;
        });
        return obj;
    };
    function getParam(k) {
        var s = window.location.search.substring(1).split('&');
        for (var i = 0; i < s.length; i++) {
            var p = s[i].split('=');
            if (decodeURIComponent(p[0]) === k) return decodeURIComponent(p[1] || '');
        }
        return '';
    }
    function pick(obj, keys) {
        for (var i = 0; i < keys.length; i++) {
            var k = keys[i];
            if (obj != null && Object.prototype.hasOwnProperty.call(obj, k)) return obj[k];
        }
        return null;
    }
</script> 