<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8"/>
    <title>레시피 상세</title>

    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.2/dist/css/bootstrap.min.css"/>
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>

    <!-- Toast UI Viewer (본문 렌더) -->
    <link rel="stylesheet" href="https://uicdn.toast.com/editor/latest/toastui-editor.min.css"/>
    <script src="https://uicdn.toast.com/editor/latest/toastui-editor-all.min.js"></script>

    <style>
        :root{
            --bg:#f7f8fb; --card:#fff; --line:#e9edf3; --text:#0f172a; --muted:#667085; --accent:#2563eb;
            --radius:18px; --shadow:0 8px 24px rgba(15,23,42,.06);
            --s0:10px; --s1:14px; --s2:18px; --s3:24px; --s4:32px; --s5:40px;
        }
        body{ background:var(--bg); color:var(--text); }
        .container-narrow{ max-width:980px; margin:0 auto; padding:var(--s4) var(--s2) var(--s5); }

        .toolbar{ display:flex; gap:var(--s0); flex-wrap:wrap; margin-bottom:var(--s2); }
        .btn{ border-radius:12px !important; }

        /* Hero */
        .hero{ background:var(--card); border:1px solid var(--line); border-radius:var(--radius); box-shadow:var(--shadow); padding:var(--s4); margin-bottom:var(--s3); }
        .title{ font-size:32px; font-weight:900; letter-spacing:-.01em; margin:0 0 var(--s1); }
        .subtitle{ color:#334155; margin:4px 0 var(--s1); }
        .meta{ color:var(--muted); font-size:13px; display:flex; gap:12px; flex-wrap:wrap; }

        /* Grid */
        .grid{ display:grid; grid-template-columns: .9fr 1.1fr; gap:var(--s3); }
        @media (max-width: 992px){ .grid{ grid-template-columns:1fr; } }

        .card{ background:var(--card); border:1px solid var(--line); border-radius:var(--radius); box-shadow:var(--shadow); }
        .card-sec{ padding:var(--s3); }
        .sec-title{ font-weight:800; margin:0 0 var(--s1); font-size:16px; }

        /* Viewer typography */
        .tui-editor-contents{ line-height:1.8; font-size:16px; color:var(--text); }
        .tui-editor-contents p{ margin:1.1em 0; }
        .tui-editor-contents img{ max-width:100%; border-radius:14px; display:block; margin:1.1em auto; }

        /* Chips/Badges */
        .chip{ display:inline-block; padding:6px 12px; border:1px solid var(--line); border-radius:999px; background:#fff; font-size:12px; color:#334155; margin:6px 8px 0 0; }

        /* Ingredients */
        .ing-group{ margin-bottom:var(--s2); }
        .ing-item{ display:flex; justify-content:space-between; gap:10px; padding:10px 0; border-top:1px solid #f1f5f9; }
        .ing-item:first-child{ border-top:none; }
        .ing-name{ font-weight:600; }
        .ing-meta{ color:var(--muted); font-size:13px; white-space:nowrap; }

        /* Steps */
        .step{ display:flex; align-items:flex-start; gap:12px; padding:14px 0; border-top:1px solid #f1f5f9; }
        .step:first-child{ border-top:none; }
        .step-num{ width:36px; height:36px; border-radius:10px; background:#eef2ff; color:#1d4ed8; font-weight:800; display:flex; align-items:center; justify-content:center; }
        .step-body{ flex:1; }
        .step-tools{ display:flex; gap:8px; margin-top:6px; }
        .timer{ font-variant-numeric: tabular-nums; font-weight:700; color:#334155; }

        /* Gallery */
        .gallery{ display:grid; grid-template-columns: repeat(3,1fr); gap:12px; }
        @media (max-width: 576px){ .gallery{ grid-template-columns: repeat(2,1fr); } }
        .thumb{ border:1px solid var(--line); border-radius:12px; overflow:hidden; background:#fff; }
        .thumb img{ width:100%; height:140px; object-fit:cover; display:block; }
        .thumb a{ display:block; padding:8px 10px; font-size:13px; color:#334155; text-decoration:none; }
        .size{ color:var(--muted); font-size:12px; }

        .divider{ height:1px; background:var(--line); margin:var(--s3) 0; }
    </style>
</head>
<body>
<div class="container-narrow">
    <!-- 상단 툴바 -->
    <div class="toolbar">
        <a class="btn btn-outline-secondary" href="/rcp/recipe/recipeList">목록</a>
        <c:if test="${not empty param.recipeId}">
            <a class="btn btn-outline-primary" href="/rcp/recipe/recipeModify?recipeId=${param.recipeId}">수정</a>
        </c:if>
        <button class="btn btn-outline-dark" type="button" onclick="copyUrl()">링크복사</button>
        <button class="btn btn-outline-secondary" type="button" onclick="window.print()">인쇄</button>
        <div class="ml-auto"></div>
    </div>

    <!-- 히어로 -->
    <div class="hero">
        <h1 id="title" class="title">불러오는 중…</h1>
        <div id="subtitle" class="subtitle"></div>
        <div id="meta" class="meta"></div>
        <div id="tags"></div>
    </div>

    <!-- 본문 -->
    <div class="grid">
        <!-- 좌: 소개/갤러리 -->
        <div class="card card-sec">
            <div class="sec-title">소개</div>
            <div id="intro" class="tui-editor-contents"></div>

            <div id="gallerySec" class="divider" style="display:none;"></div>
            <div id="galleryWrap" style="display:none;">
                <div class="sec-title">사진</div>
                <div id="gallery" class="gallery"></div>
            </div>
        </div>

        <!-- 우: 메타/재료/단계 -->
        <div class="card card-sec">
            <div class="sec-title">정보</div>
            <div class="mb-2">
                <span class="chip" id="chipServings">인분: -</span>
                <span class="chip" id="chipTime">시간: -</span>
                <span class="chip" id="chipDiff">난이도: -</span>
                <span class="chip" id="chipVis">공개: -</span>
            </div>

            <div class="divider"></div>

            <div class="sec-title">재료</div>
            <div id="ingBox"></div>

            <div class="divider"></div>

            <div class="sec-title">조리 단계</div>
            <div id="stepBox"></div>
        </div>
    </div>

    <!-- hidden key -->
    <input type="hidden" id="recipeId" value="${param.recipeId}"/>
</div>

<script>
const API = '/api/rcp/recipe';
const FILE_API = { list:'/api/com/file/list', download:id=>('/api/com/file/download/'+id) };

function copyToClipboard(text){ const t=document.createElement('textarea'); t.value=text; document.body.appendChild(t); t.select(); document.execCommand('copy'); t.remove(); }
function copyUrl(){ copyToClipboard(location.href); alert('링크가 복사되었습니다.'); }
function safe(o,...ks){ for (let k of ks){ if (o && o[k]!=null) return o[k]; } return ''; }
function bytes(n){ if(n==null)return''; const u=['B','KB','MB','GB']; let i=0,x=+n; while(x>=1024 && i<u.length-1){ x/=1024; i++; } return (Math.round(x*10)/10)+u[i]; }
function esc(s){ return String(s||'').replace(/[&<>"]/g,c=>({ '&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;' }[c])); }

$(async function(){
    const id = $('#recipeId').val();
    if (!id){ $('#title').text('대상을 찾을 수 없습니다.'); return; }
    await loadDetail(id);
});

async function loadDetail(id){
    try{
        const res = await $.ajax({
            url: API + '/selectDetail', type:'post', contentType:'application/json', dataType:'json',
            data: JSON.stringify({ recipeId:id })
        });

        const r = res.recipe || res.result || {};
        const ings = res.ings || [];
        const steps = res.steps || [];

        // 헤더
        const title = safe(r,'TITLE','title') || '레시피';
        const subtitle = safe(r,'SUBTITLE','subtitle');
        const created = safe(r,'CREATED_DT','createdDt');
        const updated = safe(r,'UPDATED_DT','updatedDt');
        const tagSummary = safe(r,'TAG_SUMMARY','tagSummary');
        const fileGrpId = safe(r,'FILE_GRP_ID','fileGrpId');

        $('#title').text(title);
        $('#subtitle').text(subtitle || '').toggle(!!subtitle);
        $('#meta').text(([created?('작성 '+created):'', updated?('수정 '+updated):''].filter(Boolean).join(' · ')));

        const $tags = $('#tags').empty();
        (tagSummary||'').split(',').map(s=>s.trim()).filter(Boolean).forEach(t=>$tags.append($('<span/>').addClass('chip').text('# '+t)));

        // 소개 뷰어: HTML 우선, 없으면 Markdown
        const introHtml = safe(r,'INTRO_HTML','introHtml');
        const introBox = $('#intro');
        if (introHtml){
            introBox.html(introHtml).addClass('tui-editor-contents');
        } else {
            const md = safe(r,'INTRO_MD','introMd') || '';
            new toastui.Editor.factory({ el: introBox[0], viewer:true, initialValue: md, height:'auto' });
        }

        // 정보 칩
        const servings = safe(r,'SERVINGS','servings');
        const prep = Number(safe(r,'PREP_MIN','prepMin') || 0);
        const cook = Number(safe(r,'COOK_MIN','cookMin') || 0);
        const diff = safe(r,'DIFFICULTY_CD','difficultyCd') || '-';
        const vis  = safe(r,'VISIBILITY_CD','visibilityCd') || '-';
        $('#chipServings').text('인분: ' + (servings||'-'));
        $('#chipTime').text('시간: ' + (prep+cook ? (prep?('손질 '+prep+'분 '):'') + (cook?('조리 '+cook+'분'):'') : '-'));
        $('#chipDiff').text('난이도: ' + diff);
        $('#chipVis').text('공개: ' + vis);

        // 재료 (그룹별 묶음)
        renderIngredients(ings);

        // 단계
        renderSteps(steps);

        // 갤러리
        if (fileGrpId) renderGallery(fileGrpId);

    }catch(e){
        $('#title').text('상세를 불러오지 못했습니다.');
    }
}

/* ===== 재료 ===== */
function renderIngredients(list){
    const $box = $('#ingBox').empty();
    if (!list.length){ $box.append('<div class="text-muted">등록된 재료가 없습니다.</div>'); return; }

    // 그룹별
    const groups = {};
    list.forEach(g=>{
        const name = safe(g,'GROUP_NM','groupNm') || '기본';
        (groups[name] = groups[name] || []).push(g);
    });

    Object.keys(groups).forEach(gname=>{
        const $g = $('<div/>').addClass('ing-group');
        $g.append($('<div/>').addClass('font-weight-bold mb-1').text(gname));
        groups[gname].forEach(it=>{
            const nm = safe(it,'ING_NM_TXT','ingNmTxt');
            const qty = safe(it,'QTY_NUM','qtyNum');
            const unit = safe(it,'UNIT_CD','unitCd');
            const note = safe(it,'NOTE_TXT','noteTxt');
            const $row = $('<div/>').addClass('ing-item');
            $row.append($('<div/>').addClass('ing-name').text(nm));
            const meta = [qty, unit, note].filter(Boolean).join(' · ');
            $row.append($('<div/>').addClass('ing-meta').text(meta));
            $g.append($row);
        });
        $box.append($g);
    });
}

/* ===== 단계 ===== */
function renderSteps(steps){
    const $box = $('#stepBox').empty();
    if (!steps.length){ $box.append('<div class="text-muted">등록된 단계가 없습니다.</div>'); return; }

    steps
      .map(s=>({
          n: Number(s.STEP_ORDR ?? s.stepOrdr ?? 0) || 0,
          html: safe(s,'INSTR_HTML','instrHtml'),
          sec: Number(s.TIMER_SEC ?? s.timerSec ?? 0) || 0
      }))
      .sort((a,b)=>a.n-b.n)
      .forEach(s=>{
          const $row = $('<div/>').addClass('step');
          $row.append($('<div/>').addClass('step-num').text(s.n || '•'));

          const $body = $('<div/>').addClass('step-body tui-editor-contents');
          if (s.html && /<[a-z][\s\S]*>/i.test(s.html)) $body.html(s.html);
          else $body.text(s.html || '');

          const $tools = $('<div/>').addClass('step-tools');
          if (s.sec>0){
              const $timer = $('<span/>').addClass('timer').text(formatSec(s.sec));
              const $btn = $('<button/>').addClass('btn btn-outline-primary btn-sm').text('타이머 시작');
              let t=null, left=s.sec;
              $btn.on('click', function(){
                  if (t){ clearInterval(t); t=null; left=s.sec; $timer.text(formatSec(left)); $(this).text('타이머 시작'); return; }
                  $(this).text('정지');
                  t=setInterval(()=>{
                      left--; $timer.text(formatSec(Math.max(0,left)));
                      if (left<=0){ clearInterval(t); t=null; $(this).text('타이머 시작'); try{ new Audio('https://actions.google.com/sounds/v1/alarms/alarm_clock.ogg').play(); }catch(e){} }
                  },1000);
              });
              $tools.append($btn).append($('<span/>').addClass('text-muted ml-2').append($timer));
          }
          $row.append($body).append($tools);
          $box.append($row);
      });
}
function formatSec(s){ const m=Math.floor(s/60), r=s%60; return (m<10?'0':'')+m+':'+(r<10?'0':'')+r; }

/* ===== 갤러리 ===== */
function renderGallery(fileGrpId){
    $.ajax({
        url: FILE_API.list, type:'post', contentType:'application/json', dataType:'json',
        data: JSON.stringify({ fileGrpId }),
        success: function(res){
            const list = res.result || [];
            if (!list.length) return;
            $('#gallerySec,#galleryWrap').show();
            const $g = $('#gallery').empty();
            list.forEach(f=>{
                const id = f.fileId || f.FILE_ID;
                const nm = f.orgFileNm || f.ORG_FILE_NM;
                const sz = f.fileSize || f.FILE_SZ;
                const url = FILE_API.download(id);
                const $t = $('<div/>').addClass('thumb');
                $t.append($('<a/>').attr('href', url).attr('target','_blank').append($('<img/>').attr('src', url)));
                $t.append($('<a/>').attr('href', url).attr('target','_blank').html(esc(nm)+' <span class="size">('+bytes(sz)+')</span>'));
                $g.append($t);
            });
        }
    });
}
</script>
</body>
</html>  