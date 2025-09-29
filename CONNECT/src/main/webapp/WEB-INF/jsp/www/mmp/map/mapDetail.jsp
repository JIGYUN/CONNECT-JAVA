<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8"/>
    <title>지도 상세</title>

    <!-- Bootstrap & jQuery -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.2/dist/css/bootstrap.min.css"/>
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>

    <!-- Kakao Maps -->
    <script src="https://dapi.kakao.com/v2/maps/sdk.js?appkey=b4eb6efe0b6e28aecabcfbb7bee56041&autoload=false&libraries=services"></script>

    <style>
        :root{
            --bg:#f7f8fb; --card:#fff; --line:#e9edf3; --text:#0f172a; --muted:#667085; --accent:#2563eb;
            --radius:18px; --shadow:0 8px 24px rgba(15,23,42,.06);
            --s0:10px; --s1:14px; --s2:18px; --s3:24px; --s4:32px; --s5:40px;
        }
        body{ background:var(--bg); color:var(--text); }
        .container-narrow{ max-width:960px; margin:0 auto; padding:var(--s4) var(--s2) var(--s5); }
        .toolbar{ display:flex; gap:var(--s0); flex-wrap:wrap; margin-bottom:var(--s2); }
        .btn{ border-radius:12px !important; }
        .card{ background:var(--card); border:1px solid var(--line); border-radius:var(--radius); box-shadow:var(--shadow); }
        .hero{ padding:var(--s4); margin-bottom:var(--s3); }
        .title{ font-size:30px; font-weight:800; letter-spacing:-.01em; margin:0 0 var(--s1); }
        .meta{ color:var(--muted); font-size:13px; display:flex; gap:12px; flex-wrap:wrap; }
        .grid{ display:grid; grid-template-columns: 1.1fr .9fr; gap:var(--s3); }
        @media (max-width: 992px){ .grid{ grid-template-columns: 1fr; } }
        .info-card{ padding:var(--s3); }
        .info-row{ display:flex; align-items:flex-start; gap:12px; padding:14px 0; border-top:1px solid #f1f5f9; }
        .info-row:first-child{ border-top:none; padding-top:0; }
        .info-label{ width:90px; color:#475569; font-weight:700; font-size:13px; }
        .info-value{ flex:1; }
        .chip{ display:inline-block; padding:6px 12px; border:1px solid var(--line); border-radius:999px; background:#fff; font-size:12px; color:#334155; margin:6px 8px 0 0; }
        #mapBox{ padding:var(--s2); }
        #kmap{ height:420px; border-radius:14px; }
        .map-actions{ display:flex; gap:10px; flex-wrap:wrap; margin-top:var(--s2); }

        /* 분석 섹션 */
        .analysis-card{ margin-top:var(--s3); padding:var(--s3); }
        .analysis-head{ display:flex; align-items:center; gap:10px; margin-bottom:12px; }
        .analysis-title{ font-weight:800; font-size:18px; margin:0; }
        .analysis-sub{ color:#6b7280; font-size:13px; }
        .img-frame{ position:relative; overflow:hidden; border-radius:14px; border:1px solid var(--line); }
        .img-frame img{ display:block; width:100%; height:auto; }
        .skeleton{
            height:360px;
            background: linear-gradient(90deg,#f6f7f9 0%,#edf1f7 50%,#f6f7f9 100%);
            background-size: 200% 100%;
            animation: shimmer 1.1s infinite;
            border-radius:14px;
        }
        @keyframes shimmer{ 0%{background-position:200% 0;} 100%{background-position:-200% 0;} }
        .analysis-actions{ display:flex; gap:8px; margin-top:10px; }
        .muted{ color:#6b7280; }

        .divider{ height:1px; background:var(--line); margin:var(--s3) 0; }
        .attach{ padding:var(--s2) var(--s3) var(--s3); }
        .attach h6{ font-weight:800; font-size:14px; margin:0 0 var(--s1); }
        .attach ul{ list-style:none; margin:0; padding:0; }
        .attach li{ display:flex; justify-content:space-between; align-items:center; padding:10px 0; border-top:1px solid #f1f5f9; }
        .attach li:first-child{ border-top:none; }
        .size{ color:var(--muted); font-size:12px; }
    </style>
</head>
<body>
<div class="container-narrow">
    <!-- 상단 툴바 -->
    <div class="toolbar">
        <a class="btn btn-outline-secondary" href="/mmp/map/mapList<c:if test='${not empty param.grpCd}'>?grpCd=${param.grpCd}</c:if>">목록</a>
        <c:if test="${not empty param.mapId}"><a class="btn btn-outline-primary" href="/mmp/map/mapModify?mapId=${param.mapId}">수정</a></c:if>
        <button class="btn btn-outline-dark" type="button" onclick="copyUrl()">링크복사</button>
        <div class="ml-auto"></div>
    </div>

    <!-- 히어로 -->
    <div class="card hero">
        <h1 id="title" class="title">불러오는 중…</h1>
        <div id="meta" class="meta"></div>
        <div id="tags" class="mt-2"></div>
    </div>

    <!-- 본문 그리드 -->
    <div class="grid">
        <!-- 좌: 정보 -->
        <div class="card info-card">
            <div class="info-row"><div class="info-label">표시명</div><div id="mapNm" class="info-value">—</div></div>
            <div class="info-row"><div class="info-label">주소</div><div id="addr" class="info-value">—</div></div>
            <div class="info-row"><div class="info-label">좌표</div><div id="coord" class="info-value">—</div></div>
            <div class="info-row"><div class="info-label">메모</div><div id="memo" class="info-value text-break">—</div></div>
        </div>

        <!-- 우: 지도 -->
        <div class="card" id="mapBox">
            <div id="kmap"></div>
            <div class="map-actions">
                <button class="btn btn-primary btn-sm" type="button" id="btnDirection">길찾기</button>
                <button class="btn btn-outline-secondary btn-sm" type="button" id="btnCopyAddr">주소 복사</button>
                <button class="btn btn-outline-secondary btn-sm" type="button" id="btnCopyCoord">좌표 복사</button>
                <a class="btn btn-outline-dark btn-sm" target="_blank" id="btnOpenKakao">카카오맵에서 보기</a>
            </div>
        </div>
    </div>

    <!-- 첨부(선택) -->
    <div id="attachCard" class="card attach mt-3" style="display:none;">
        <h6>첨부파일</h6>
        <ul id="attachList"></ul>
    </div>

    <!-- 댓글 분석(시연용 이미지) -->
    <div class="card analysis-card" id="analysisCard">
        <div class="analysis-head">
            <h3 class="analysis-title mb-0">댓글 분석</h3>
            <div class="analysis-sub">파이썬 모델 결과(시연) · 분포(SCORE)</div>
        </div>

        <div class="img-frame">
            <div id="distSkeleton" class="skeleton"></div>
            <img id="distImg" src="" alt="분석 이미지" style="display:none;"/>
        </div>
    </div>     

    <!-- 숨김 파라미터 -->
    <input type="hidden" id="mapId" value="${param.mapId}"/> 
    <input type="hidden" id="grpCd" value="${param.grpCd}"/>
</div>

<!-- 라이트박스(부트스트랩 모달) -->
<div class="modal fade" id="imgModal" tabindex="-1" role="dialog" aria-hidden="true">
  <div class="modal-dialog modal-dialog-centered modal-lg" role="document">
    <div class="modal-content" style="background:#0b1020;">
      <div class="modal-body p-0">
        <img id="imgModalPic" src="" class="img-fluid" alt="분석 이미지 확대" />
      </div>
      <div class="modal-footer py-2">
        <button type="button" class="btn btn-light btn-sm" data-dismiss="modal">닫기</button>
      </div>
    </div>
  </div>
</div>

<!-- Bootstrap JS (모달용) -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@4.6.2/dist/js/bootstrap.bundle.min.js"></script>

<script>
const API = '/api/mmp/map';
const FILE_API = { list:'/api/com/file/list', download: id => '/api/com/file/download/' + id };
const DIST_IMG_PATH = '/static/assets/img/dist_-HMjbflpVIg.png';  

function copyToClipboard(text){
    const t = document.createElement('textarea'); t.value = text; document.body.appendChild(t);
    t.select(); document.execCommand('copy'); document.body.removeChild(t);
}
function copyUrl(){ copyToClipboard(location.href); alert('링크가 복사되었습니다.'); }
function fmtCoord(lat,lng){ return lat && lng ? (Number(lat).toFixed(6) + ', ' + Number(lng).toFixed(6)) : '—'; }
function safe(r, ...keys){ for (let k of keys){ if (r && r[k] != null) return r[k]; } return ''; }
function esc(s){ return String(s||'').replace(/[&<>"]/g, c=>({ '&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;' }[c])); }
function bytes(n){ if (n==null) return ''; const u=['B','KB','MB','GB']; let i=0,x=+n; while(x>=1024&&i<u.length-1){x/=1024;i++;} return (Math.round(x*10)/10)+u[i]; }

let map, marker, infowindow;

kakao.maps.load(async function(){
    map = new kakao.maps.Map(document.getElementById('kmap'), { center:new kakao.maps.LatLng(37.5665,126.9780), level:4 });
    infowindow = new kakao.maps.InfoWindow({removable:false});

    const id = $('#mapId').val();
    if (!id){ $('#title').text('대상을 찾을 수 없습니다.'); initAnalysis(''); return; }
    await loadDetail(id);
});

async function loadDetail(id){
    try{
        const res = await $.ajax({
            url: API + '/selectMapDetail', type:'post', contentType:'application/json', dataType:'json',
            data: JSON.stringify({ mapId:id })
        });
        const r = res.result || res.map || res;

        const title = safe(r, 'title','TITLE') || '지도 포인트';
        const name  = safe(r, 'mapNm','MAP_NM');
        const addr  = safe(r, 'content','CONTENT');   // 임시: 주소/메모로 사용하던 필드
        const lat   = Number(safe(r, 'lat','LAT'));
        const lng   = Number(safe(r, 'lng','LNG','lon','LON'));
        const created = safe(r,'createdDt','CREATED_DT');
        const updated = safe(r,'updatedDt','UPDATED_DT');
        const tags    = (safe(r,'tagTxt','TAG_TXT') || '').split(',').map(s=>s.trim()).filter(Boolean);
        const fileGrpId = safe(r,'fileGrpId','FILE_GRP_ID');

        $('#title').text(title);
        $('#mapNm').text(name || '—');
        $('#addr').text(addr || '—');
        $('#coord').text(fmtCoord(lat,lng));
        $('#memo').text(safe(r,'memo','MEMO') || '—');

        let meta=[]; if (created) meta.push('작성 ' + created); if (updated) meta.push('수정 ' + updated);
        $('#meta').text(meta.join(' · '));

        const $tags = $('#tags').empty(); tags.forEach(t => $tags.append($('<span/>').addClass('chip').text('# ' + t)));

        if (isFinite(lat) && isFinite(lng)){
            const ll = new kakao.maps.LatLng(lat, lng);
            marker = new kakao.maps.Marker({ position: ll }); marker.setMap(map);
            map.setCenter(ll); map.setLevel(3);
            const iw = '<div style="padding:6px 8px;font-size:13px;"><b>'+ esc(name || title) +'</b>'
                      + (addr ? '<div style="color:#6b7280;">'+ esc(addr) +'</div>' : '') + '</div>';
            infowindow.setContent(iw); infowindow.open(map, marker);

            $('#btnDirection').off('click').on('click', function(){
                const url = 'https://map.kakao.com/link/to/' + encodeURIComponent(name || title) + ',' + lat + ',' + lng;
                window.open(url, '_blank');
            });
            $('#btnOpenKakao').attr('href','https://map.kakao.com/link/map/' + encodeURIComponent(name || title) + ',' + lat + ',' + lng);
            $('#btnCopyAddr').off('click').on('click', ()=>{ copyToClipboard(addr || ''); alert('주소를 복사했습니다.'); });
            $('#btnCopyCoord').off('click').on('click', ()=>{ copyToClipboard(lat + ', ' + lng); alert('좌표를 복사했습니다.'); });
        }

        if (fileGrpId){ renderAttach(fileGrpId); }

        // 분석 섹션 초기화(타이틀을 ALT에 반영)
        initAnalysis(title);

    }catch(e){
        $('#title').text('상세를 불러오지 못했습니다.');
        initAnalysis('');
    }
}

function renderAttach(fileGrpId){
    $.ajax({
        url: FILE_API.list, type:'post', contentType:'application/json', dataType:'json',
        data: JSON.stringify({ fileGrpId }),
        success: function(res){
            const list = res.result || [];
            if (!list.length) return;
            $('#attachCard').show();
            const $ul = $('#attachList').empty();
            list.forEach(f=>{
                const id = f.fileId || f.FILE_ID;
                const nm = f.orgFileNm || f.ORG_FILE_NM;
                const sz = f.fileSize || f.FILE_SZ;
                const li = $('<li/>')
                    .append($('<a/>').attr('href', FILE_API.download(id)).text(nm))
                    .append($('<span/>').addClass('size').text(bytes(sz)));
                $ul.append(li);
            });
        }
    });
}

/* ====== 분석 섹션 ====== */
function initAnalysis(titleText){
    const $img = $('#distImg');
    const $skel = $('#distSkeleton');
    const src = DIST_IMG_PATH + '?t=' + Date.now(); // 캐시 무시

    $img
      .attr('alt', (titleText ? (titleText + ' — ') : '') + '댓글 분석 분포 이미지')
      .attr('title', (titleText ? (titleText + ' · ') : '') + '댓글 분석(시연)');

    // 로드/에러 핸들러
    $img.off('load error').on('load', function(){
        $skel.hide(); $img.show();
        $('#btnDownload').attr('href', DIST_IMG_PATH);
        $('#imgModalPic').attr('src', DIST_IMG_PATH);
    }).on('error', function(){
        $skel.replaceWith(
            '<div class="p-4 text-center text-muted" style="border:1px dashed var(--line); border-radius:14px;">'
          + '분석 이미지를 불러오지 못했습니다. 경로 <code>' + DIST_IMG_PATH + '</code> 를 확인해 주세요.'
          + '</div>'
        );
    });

    // 최초 로드
    $img.hide(); $skel.show(); $img.attr('src', src);

    // 액션 버튼
    $('#btnRefresh').off('click').on('click', function(){
        $img.hide(); $skel.show();
        $img.attr('src', DIST_IMG_PATH + '?t=' + Date.now());
    });
    $('#btnZoom').off('click').on('click', function(){ $('#imgModal').modal('show'); });
}
</script>
</body>
</html>