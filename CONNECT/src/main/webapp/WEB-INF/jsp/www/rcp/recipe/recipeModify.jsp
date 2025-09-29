<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>

<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.2/dist/css/bootstrap.min.css"/>
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>

<link rel="stylesheet" href="https://uicdn.toast.com/editor/latest/toastui-editor.min.css"/>
<script src="https://uicdn.toast.com/editor/latest/toastui-editor-all.min.js"></script>

<style>
    :root{ --bg:#f6f8fb; --card:#ffffff; --line:#e9edf3; --text:#0f172a; --muted:#6b7280; }
    body{ background:var(--bg); }
    .page-title{ font-size:26px; font-weight:800; color:var(--text); margin:12px 0 14px; }
    .panel{ background:var(--card); border:1px solid var(--line); border-radius:16px; padding:16px; box-shadow:0 4px 16px rgba(15,23,42,.06); }
    .btn, .form-control, .custom-select{ border-radius:12px; }
    .sec-title{ font-weight:700; margin:14px 0 8px; }
    .ing-row, .step-row{ border:1px dashed #e5e7eb; border-radius:12px; padding:10px; margin-bottom:8px; background:#fff; }
    .ing-grid{ display:grid; grid-template-columns: 1.2fr .6fr .6fr 1fr .6fr; gap:8px; }
    .step-grid{ display:grid; grid-template-columns: .2fr 1fr .4fr; gap:8px; align-items:start; }
</style>

<section class="container-fluid">
    <h2 class="page-title">레시피 <span id="modeText" class="text-muted" style="font-size:16px;">등록</span></h2>

    <div class="mb-3 d-flex align-items-center" style="gap:8px;">
        <button class="btn btn-primary" type="button" onclick="save()">저장</button>
        <c:if test="${not empty param.recipeId}">
            <button class="btn btn-outline-danger" type="button" onclick="remove()">삭제</button>
        </c:if>
        <a class="btn btn-outline-secondary" href="/rcp/recipe/recipeList">목록</a>
    </div>

    <div class="panel">
        <form id="recipeForm" onsubmit="return false;">
            <input type="hidden" id="recipeId" name="recipeId" value="${param.recipeId}"/>

            <div class="form-row">
                <div class="form-group col-md-7">
                    <label>제목 *</label>
                    <input id="title" name="title" class="form-control" placeholder="예) 김치볶음밥"/>
                </div>
                <div class="form-group col-md-5">
                    <label>레시피 코드(RECIPE_CD) *</label>
                    <input id="recipeCd" name="recipeCd" class="form-control" placeholder="예) kimchi-fried-rice"/>
                </div>
            </div>

            <div class="form-row">
                <div class="form-group col-md-7">
                    <label>부제목</label>
                    <input id="subtitle" name="subtitle" class="form-control" placeholder="짧은 소개"/>
                </div>
                <div class="form-group col-md-2">
                    <label>인분</label>
                    <input id="servings" name="servings" type="number" min="1" class="form-control"/>
                </div>
                <div class="form-group col-md-1">
                    <label>손질</label>
                    <input id="prepMin" name="prepMin" type="number" min="0" class="form-control" placeholder="분"/>
                </div>
                <div class="form-group col-md-1">
                    <label>조리</label>
                    <input id="cookMin" name="cookMin" type="number" min="0" class="form-control" placeholder="분"/>
                </div>
                <div class="form-group col-md-1">
                    <label>난이도</label>
                    <select id="difficultyCd" name="difficultyCd" class="custom-select">
                        <option value="">-</option>
                        <option value="EASY">EASY</option>
                        <option value="MEDIUM">MEDIUM</option>
                        <option value="HARD">HARD</option>
                    </select>
                </div>
            </div>

            <div class="form-row">
                <div class="form-group col-md-3">
                    <label>공개</label>
                    <select id="visibilityCd" name="visibilityCd" class="custom-select">
                        <option value="PUBLIC" selected>PUBLIC</option>
                        <option value="UNLISTED">UNLISTED</option>
                        <option value="PRIVATE">PRIVATE</option>
                    </select>
                </div>
                <div class="form-group col-md-3">
                    <label>대표 파일그룹ID</label>
                    <input id="fileGrpId" name="fileGrpId" type="number" min="0" class="form-control"/>
                </div>
                <div class="form-group col-md-6">
                    <label>태그 요약(쉼표 구분)</label>
                    <input id="tagSummary" name="tagSummary" class="form-control" placeholder="예) 한식,초간단,자취"/>
                </div>
            </div>

            <div class="sec-title">소개(본문)</div>
            <div id="introEditor" style="height:280px;"></div>
            <input type="hidden" id="introHtml" name="introHtml"/>

            <div class="sec-title">재료</div>
            <div id="ingBox"></div>
            <div class="mt-2">
                <button class="btn btn-outline-primary btn-sm" type="button" onclick="addIng()">+ 재료 추가</button>
            </div>

            <div class="sec-title">조리 단계</div>
            <div id="stepBox"></div>
            <div class="mt-2">
                <button class="btn btn-outline-primary btn-sm" type="button" onclick="addStep()">+ 단계 추가</button>
            </div>
        </form>
    </div>
</section>

<script>
    const API = '/api/rcp/recipe';
    let introEditor;

    $(document).ready(function(){
        introEditor = new toastui.Editor({
            el: document.querySelector('#introEditor'),
            height: '280px',
            initialEditType: 'markdown',
            previewStyle: 'vertical',
            placeholder: '레시피 소개/팁을 입력하세요...'
        });

        const id = $('#recipeId').val();
        if (id){
            $('#modeText').text('수정');
            load(id);
        } else {
            $('#modeText').text('등록');
            addIng();
            addStep();
        }
    });

    /* ===== 재료 UI ===== */
    function addIng(data){
        const r = data || {};
        const $row = $('<div/>').addClass('ing-row');
        const grid = $('<div/>').addClass('ing-grid');
        grid.append($('<input/>').addClass('form-control').attr('placeholder','재료명').val(r.ingNmTxt||''));
        grid.append($('<input/>').addClass('form-control').attr('placeholder','수량').val(r.qtyNum||''));
        grid.append($('<input/>').addClass('form-control').attr('placeholder','단위 ex) g,ml,컵').val(r.unitCd||''));
        grid.append($('<input/>').addClass('form-control').attr('placeholder','비고 ex) 다져서').val(r.noteTxt||''));
        grid.append($('<input/>').addClass('form-control').attr('placeholder','그룹 ex) 소스').val(r.groupNm||''));
        const del = $('<button/>').addClass('btn btn-outline-danger btn-sm mt-2').text('삭제').on('click', function(){ $row.remove(); });
        $row.append(grid).append(del);
        $('#ingBox').append($row);
    }

    /* ===== 단계 UI ===== */
    function addStep(data){
        const r = data || {};
        const $row = $('<div/>').addClass('step-row');
        const grid = $('<div/>').addClass('step-grid');
        grid.append($('<input/>').addClass('form-control').attr('placeholder','#').val(r.stepOrdr||''));
        grid.append($('<textarea/>').addClass('form-control').attr('rows',3).attr('placeholder','조리 단계 설명(HTML/텍스트)').val(r.instrHtml||''));
        grid.append($('<input/>').addClass('form-control').attr('placeholder','타이머(초)').val(r.timerSec||''));
        const del = $('<button/>').addClass('btn btn-outline-danger btn-sm mt-2').text('삭제').on('click', function(){ $row.remove(); });
        $row.append(grid).append(del);
        $('#stepBox').append($row);
    }

    /* ===== 로드/세이브 ===== */
    function load(id){
        $.ajax({
            url: API + '/selectDetail',
            type: 'post',
            contentType: 'application/json',
            dataType: 'json',
            data: JSON.stringify({ recipeId: id }),
            success: function(map){
                const base = map.recipe || {};
                $('#title').val(base.TITLE || base.title || '');
                $('#recipeCd').val(base.RECIPE_CD || base.recipeCd || '');
                $('#subtitle').val(base.SUBTITLE || base.subtitle || '');
                $('#servings').val(base.SERVINGS || base.servings || '');
                $('#prepMin').val(base.PREP_MIN || base.prepMin || '');
                $('#cookMin').val(base.COOK_MIN || base.cookMin || '');
                $('#difficultyCd').val(base.DIFFICULTY_CD || base.difficultyCd || '');
                $('#visibilityCd').val(base.VISIBILITY_CD || base.visibilityCd || 'PUBLIC');
                $('#fileGrpId').val(base.FILE_GRP_ID || base.fileGrpId || '');
                $('#tagSummary').val(base.TAG_SUMMARY || base.tagSummary || '');
                introEditor.setHTML(base.INTRO_HTML || base.introHtml || '');

                // 재료
                $('#ingBox').empty();
                const ings = map.ings || [];
                if (!ings.length) addIng();
                for (let i=0;i<ings.length;i++){
                    const g = ings[i];
                    addIng({
                        ingNmTxt: g.ING_NM_TXT || g.ingNmTxt,
                        qtyNum:   g.QTY_NUM || g.qtyNum,
                        unitCd:   g.UNIT_CD || g.unitCd,
                        noteTxt:  g.NOTE_TXT || g.noteTxt,
                        groupNm:  g.GROUP_NM || g.groupNm
                    });
                }

                // 단계
                $('#stepBox').empty();
                const steps = map.steps || [];
                if (!steps.length) addStep();
                for (let j=0;j<steps.length;j++){
                    const s = steps[j];
                    addStep({
                        stepOrdr:  s.STEP_ORDR || s.stepOrdr,
                        instrHtml: s.INSTR_HTML || s.instrHtml,
                        timerSec:  s.TIMER_SEC || s.timerSec
                    });
                }
            },
            error: function(){ alert('상세 조회 오류'); }
        });
    }

    function collectPayload(){
        $('#introHtml').val(introEditor.getHTML());
        const payload = {
            recipeId:   $('#recipeId').val() || null,
            recipeCd:   $('#recipeCd').val().trim(),
            title:      $('#title').val().trim(),
            subtitle:   $('#subtitle').val().trim(),
            introHtml:  $('#introHtml').val(),
            servings:   $('#servings').val(),
            prepMin:    $('#prepMin').val(),
            cookMin:    $('#cookMin').val(),
            difficultyCd: $('#difficultyCd').val(),
            visibilityCd: $('#visibilityCd').val(),
            fileGrpId:  $('#fileGrpId').val(),
            tagSummary: $('#tagSummary').val(),
            useAt:      'Y',
            steps: [],
            ings: []
        };

        // 재료
        $('#ingBox .ing-row').each(function(){
            const $i = $(this).find('input');
            payload.ings.push({
                ingNmTxt: $i.eq(0).val(),
                qtyNum:   $i.eq(1).val(),
                unitCd:   $i.eq(2).val(),
                noteTxt:  $i.eq(3).val(),
                groupNm:  $i.eq(4).val()
            });
        });

        // 단계
        $('#stepBox .step-row').each(function(){
            const $in = $(this).find('input,textarea');
            payload.steps.push({
                stepOrdr:  $in.eq(0).value || $in.eq(0).val(),
                instrHtml: $in.eq(1).val(),
                timerSec:  $in.eq(2).val()
            });
        });

        return payload;
    }

    function save(){
        const id = $('#recipeId').val();
        if (!$('#title').val().trim()){ alert('제목을 입력하세요.'); return; }
        if (!$('#recipeCd').val().trim()){ alert('레시피 코드를 입력하세요.'); return; }
        const url = id ? (API + '/update') : (API + '/insert');
        const body = collectPayload();

        $.ajax({
            url: url,
            type: 'post',
            contentType: 'application/json',
            dataType: 'json',
            data: JSON.stringify(body),
            success: function(res){
                if (!id && res.recipeId){
                    location.href = '/rcp/recipe/recipeModify?recipeId=' + encodeURIComponent(res.recipeId);
                } else {
                    alert('저장되었습니다.');
                }
            },
            error: function(xhr){ alert('저장 오류: ' + (xhr.responseText || xhr.status)); }
        });
    }

    function remove(){
        const id = $('#recipeId').val();
        if (!id){ alert('삭제 대상이 없습니다.'); return; }
        if (!confirm('정말 삭제하시겠습니까?')) return;
        $.ajax({
            url: API + '/delete',
            type: 'post',
            contentType: 'application/json',
            dataType: 'json',
            data: JSON.stringify({ recipeId: id }),
            success: function(){
                alert('삭제되었습니다.');
                location.href = '/rcp/recipe/recipeList';
            },
            error: function(){ alert('삭제 오류'); }
        });
    }
</script>