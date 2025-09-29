<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>

<style>
    .page-wrap { max-width: 960px; margin: 0 auto; }
    .page-title { font-weight: 700; letter-spacing: .2px; }
    .card-surface {
        background: #fff;
        border: 1px solid rgba(0,0,0,.06);
        border-radius: 16px;
        box-shadow: 0 4px 18px rgba(0,0,0,.04);
    }
    .fieldset-title { font-weight:600; color:#5b6375; }
</style>

<section class="page-wrap">
    <div class="d-flex align-items-end justify-content-between mb-3">
        <h2 class="page-title mb-0">메뉴 <span id="pageTitle">등록</span></h2>
        <div class="d-flex gap-2">
            <button class="btn btn-primary" type="button" onclick="saveMenuItem()">저장</button>
            <c:if test="${not empty param.menuId}">
                <button class="btn btn-outline-danger" type="button" onclick="deleteMenuItem()">삭제</button>
            </c:if>
            <a class="btn btn-outline-secondary" href="/adm/sys/menuItem/menuItemList">목록</a>
        </div>
    </div>

    <form id="menuItemForm" class="card-surface p-3">
        <input type="hidden" name="menuId" id="menuId" value="${param.menuId}"/>

        <div class="row g-3">
            <div class="col-md-4">
                <label class="form-label">메뉴그룹</label>
                <select class="form-select" id="menuGroupId" name="menuGroupId"></select>
            </div>
            <div class="col-md-4">
                <label class="form-label">상위메뉴</label>
                <select class="form-select" id="upperMenuId" name="upperMenuId">
                    <option value="">(루트)</option>
                </select>
            </div>
            <div class="col-md-4">
                <label class="form-label">정렬순서</label>
                <input type="number" class="form-control" id="sortOrdr" name="sortOrdr" value="0"/>
            </div>

            <div class="col-md-6">
                <label class="form-label">메뉴명</label>
                <input type="text" class="form-control" id="menuNm" name="menuNm"/>
            </div>
            <div class="col-md-3">
                <label class="form-label">아이콘 키</label>
                <input type="text" class="form-control" id="iconKey" name="iconKey" placeholder="optional"/>
            </div>
            <div class="col-md-3">
                <label class="form-label">접근권한</label>
                <select class="form-select" id="reqRoleCd" name="reqRoleCd"></select>
            </div>

            <div class="col-12">
                <div class="fieldset-title mb-1">메뉴유형</div>
                <div>
                    <div class="form-check form-check-inline">
                        <input class="form-check-input" type="radio" name="menuSeCd" id="typeRoute" value="ROUTE" checked>
                        <label class="form-check-label" for="typeRoute">ROUTE</label>
                    </div>
                    <div class="form-check form-check-inline">
                        <input class="form-check-input" type="radio" name="menuSeCd" id="typeBoard" value="BOARD">
                        <label class="form-check-label" for="typeBoard">BOARD</label>
                    </div>
                    <div class="form-check form-check-inline">
                        <input class="form-check-input" type="radio" name="menuSeCd" id="typeExternal" value="EXTERNAL">
                        <label class="form-check-label" for="typeExternal">EXTERNAL</label>
                    </div>
                </div>
            </div>

            <div class="col-md-7 type-field type-route">
                <label class="form-label">경로(URL/라우트)</label>
                <input type="text" class="form-control" id="pathUrl" name="pathUrl" placeholder="/m/notice 또는 /about 또는 https://..."/>
            </div>
            <div class="col-md-5 type-field type-board" style="display:none;">
                <label class="form-label">게시판</label>
                <select class="form-select" id="boardId" name="boardId">
                    <option value="">선택</option>
                </select>
            </div>

            <div class="col-md-6">
                <label class="form-label d-block">표시여부</label>
                <div class="form-check form-check-inline">
                    <input class="form-check-input" type="radio" name="visibleAt" id="visibleY" value="Y" checked>
                    <label class="form-check-label" for="visibleY">Y</label>
                </div>
                <div class="form-check form-check-inline">
                    <input class="form-check-input" type="radio" name="visibleAt" id="visibleN" value="N">
                    <label class="form-check-label" for="visibleN">N</label>
                </div>
            </div>

            <div class="col-md-6">
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
        </div>
    </form>
</section>

<script>
    const API_GRP     = '/api/sys/menuGroup';
    const API_BASE    = '/api/sys/menuItem';
    const API_BOARD   = '/api/brd/boardDef';
    const API_CODE_CL = '/api/sys/cmmnCodeCl';
    const API_CODE    = '/api/sys/cmmnCode';
    const PK          = 'menuId';

    $(document).ready(function () {
        loadMenuGroups(function () {
            const qs = new URLSearchParams(window.location.search);
            const mg = qs.get('menuGroupId');
            if (mg) $('#menuGroupId').val(mg);
            loadUpperMenuOptions('');
        });
        loadBoards();
        loadReqRoleOptions();

        $('input[name="menuSeCd"]').on('change', updateTypeFields);
        $('#menuGroupId').on('change', function () { loadUpperMenuOptions(''); });

        const id = $("#" + PK).val();
        if (id && id !== "") {
            readMenuItem(id);
            $("#pageTitle").text("수정");
        } else {
            $("#pageTitle").text("등록");
        }
        updateTypeFields();
    });

    function loadMenuGroups(cb) {
        $.ajax({
            url: API_GRP + "/selectMenuGroupList",
            type: "post",
            contentType: "application/json",
            dataType: "json",
            data: JSON.stringify({}),
            success: function (map) {
                const list = map.result || [];
                let html = '';
                for (let i = 0; i < list.length; i++) {
                    const r = list[i];
                    html += '<option value="'+(r.menuGroupId)+'">'+(r.menuGroupNm || ('#'+r.menuGroupId))+'</option>';
                }
                $("#menuGroupId").html(html);
                if (cb) cb();
            }
        });
    }

    // 그룹 변경 시 상위메뉴 재구성 (백엔드가 필터를 무시해도 프론트에서 강제 필터)
    function loadUpperMenuOptions(selectedUpperId) {
        const mg = $('#menuGroupId').val();
        if (!mg) { $('#upperMenuId').html('<option value="">(루트)</option>'); return; }

        const selfId = $('#menuId').val();
        $.ajax({
            url: API_BASE + "/selectMenuItemList",
            type: "post",
            contentType: "application/json",
            dataType: "json",
            data: JSON.stringify({ menuGroupId: Number(mg) }), // 숫자로 전달
            success: function (map) {
                // ── 핵심: 안전하게 프론트에서 그룹 필터 적용 ──
                const raw  = map.result || [];
                const list = raw.filter(function(x){ return String(x.menuGroupId) === String(mg); });

                let html = '<option value="">(루트)</option>';
                list.sort(function(a,b){
                    const s = (a.sortOrdr||0) - (b.sortOrdr||0);
                    return s !== 0 ? s : (a.menuId - b.menuId);
                });

                for (let i = 0; i < list.length; i++) {
                    const r = list[i];
                    if (selfId && String(r.menuId) === String(selfId)) continue; // 자기 자신 제외
                    const label = (r.upperMenuId ? ' └ ' : '') + r.menuNm;
                    html += '<option value="'+(r.menuId)+'">'+label+'</option>';
                }
                $('#upperMenuId').html(html);

                // 명시적 선택(없으면 루트)
                $('#upperMenuId').val(
                    (selectedUpperId !== undefined && selectedUpperId !== null && selectedUpperId !== '')
                        ? String(selectedUpperId) : ''
                );
            }
        });
    }

    function loadBoards() {
        $.ajax({
            url: API_BOARD + "/selectBoardDefList",
            type: "post",
            contentType: "application/json",
            dataType: "json",
            data: JSON.stringify({ useAt: 'Y' }),
            success: function (map) {
                const list = map.result || [];
                let html = '<option value="">선택</option>';
                for (let i = 0; i < list.length; i++) {
                    const r = list[i];
                    html += '<option value="'+(r.boardId)+'">'+(r.boardNm || r.boardCd || ('#'+r.boardId))+'</option>';
                }
                $('#boardId').html(html);
            }
        });
    }

    function loadReqRoleOptions() {
        $.ajax({
            url: API_CODE_CL + "/selectCmmnCodeClList",
            type: "post",
            contentType: "application/json",
            dataType: "json",
            data: JSON.stringify({}),
            success: function (map) {
                const cls = (map.result || []);
                const roleCl = cls.find(function (x) { return x.codeCl === 'REQ_ROLE'; });
                if (!roleCl) {
                    $('#reqRoleCd').html('<option value="ANY">ANY</option><option value="MEMBER">MEMBER</option><option value="ADMIN">ADMIN</option>');
                    return;
                }
                $.ajax({
                    url: API_CODE + "/selectCmmnCodeList",
                    type: "post",
                    contentType: "application/json",
                    dataType: "json",
                    data: JSON.stringify({ codeClId: roleCl.codeClId }),
                    success: function (map2) {
                        const list = map2.result || [];
                        let html = '';
                        for (let i=0;i<list.length;i++) {
                            const r = list[i];
                            html += '<option value="'+(r.code)+'">'+(r.codeNm||r.code)+'</option>';
                        }
                        $('#reqRoleCd').html(html);
                    }
                });
            }
        });
    }

    function updateTypeFields() {
        const v = $('input[name="menuSeCd"]:checked').val();
        $('.type-field').hide();
        if (v === 'BOARD') $('.type-board').show();
        else $('.type-route').show();
    }

    function readMenuItem(id) {
        const send = {}; send[PK] = id;
        $.ajax({
            url: API_BASE + "/selectMenuItemDetail",
            type: "post",
            contentType: "application/json",
            dataType: "json",
            data: JSON.stringify(send),
            success: function (map) {
                const r = map.result || map.menuItem || map;
                if (!r) return;

                // 그룹 세팅 후 해당 그룹 기준으로 상위메뉴 로드 + 선택값 적용
                $('#menuGroupId').val(r.menuGroupId);
                loadUpperMenuOptions(r.upperMenuId);

                $('#sortOrdr').val(r.sortOrdr || 0);
                $('#menuNm').val(r.menuNm || '');
                $('#iconKey').val(r.iconKey || '');
                $('#reqRoleCd').val(r.reqRoleCd || 'ANY');

                const t = r.menuSeCd || 'ROUTE';
                $('input[name="menuSeCd"][value="'+t+'"]').prop('checked', true);
                if (t === 'BOARD') {
                    $('#boardId').val(r.boardId || '');
                    $('#pathUrl').val('');
                } else {
                    $('#pathUrl').val(r.pathUrl || '');
                    $('#boardId').val('');
                }
                updateTypeFields();

                $('input[name="visibleAt"][value="'+(r.visibleAt||'Y')+'"]').prop('checked', true);
                $('input[name="useAt"][value="'+(r.useAt||'Y')+'"]').prop('checked', true);

                $("#pageTitle").text("수정");
            },
            error: function(){ alert('조회 중 오류 발생'); }
        });
    }

    function saveMenuItem() {
        const id  = $("#" + PK).val();
        const url = (id && id !== "") ? (API_BASE + "/updateMenuItem") : (API_BASE + "/insertMenuItem");

        if ($("#menuGroupId").val() === "") { alert("메뉴그룹을 선택해주세요."); return; }
        if ($("#menuNm").val() === "")      { alert("메뉴명을 입력해주세요."); return; }

        const type = $('input[name="menuSeCd"]:checked').val();
        if (type === 'BOARD' && !$('#boardId').val()) { alert('게시판을 선택해주세요.'); return; }
        //if ((type === 'ROUTE' || type === 'EXTERNAL') && !$('#pathUrl').val()) { alert('경로(URL)를 입력해주세요.'); return; }

        var form = $("#menuItemForm").serializeObject();  

        if (type === 'BOARD') { form.pathUrl = ''; }
        else { form.boardId = ''; }

        form.menuGroupId = Number(form.menuGroupId);
        form.upperMenuId = form.upperMenuId ? Number(form.upperMenuId) : null;
        form.sortOrdr    = form.sortOrdr ? Number(form.sortOrdr) : 0;

        if (type === 'BOARD') form.boardId = Number(form.boardId);
        else                  form.boardId = null;

        $.ajax({
            url: url,
            type: "post",
            contentType: "application/json",
            dataType: "json",
            data: JSON.stringify(form),
            success: function () { location.href = "/adm/sys/menuItem/menuItemList"; },
            error: function () { alert("저장 중 오류 발생"); }
        });
    }

    function deleteMenuItem() {
        const id = $("#" + PK).val();
        if (!id || id === "") { alert("삭제할 대상의 PK가 없습니다."); return; }
        if (!confirm("정말 삭제하시겠습니까?")) return;

        const send = {}; send[PK] = id;
        $.ajax({
            url: API_BASE + "/deleteMenuItem",
            type: "post",
            contentType: "application/json",
            dataType: "json",
            data: JSON.stringify(send),
            success: function () {
                alert("삭제 완료되었습니다.");
                location.href = "/adm/sys/menuItem/menuItemList";
            },
            error: function () { alert("삭제 중 오류 발생"); }
        });
    }

    $.fn.serializeObject = function () {
        var obj = {};
        var arr = this.serializeArray();
        $.each(arr, function () { obj[this.name] = this.value; });
        return obj;
    };
</script> 