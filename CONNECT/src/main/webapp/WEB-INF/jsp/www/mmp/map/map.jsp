<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>

<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.2/dist/css/bootstrap.min.css"/>
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>

<!-- Kakao Maps SDK -->
<script src="//dapi.kakao.com/v2/maps/sdk.js?appkey=b4eb6efe0b6e28aecabcfbb7bee56041&autoload=false&libraries=services,clusterer"></script>

<style>
    :root{
        --bg:#f6f8fb; --card:#ffffff; --line:#e9edf3; --text:#0f172a; --muted:#6b7280;
        --header-h:56px;
    }
    body{ background:var(--bg); }
    .map-wrap{
        position:relative;
        height:calc(100vh - var(--header-h) - 48px);
        min-height:520px;
        border:1px solid var(--line);
        border-radius:16px;
        box-shadow:0 4px 14px rgba(15,23,42,.05);
        background:#fff;
    }
    #map{ position:absolute; inset:0; border-radius:16px; }

    .toolbar{
        position:absolute; z-index:5; left:12px; right:12px; top:12px;
        display:flex; gap:8px; align-items:center; flex-wrap:wrap;
        padding:10px; background:rgba(255,255,255,.95);
        border:1px solid var(--line); border-radius:14px;
        box-shadow:0 4px 14px rgba(15,23,42,.08);
    }
    .toolbar .title{ font-weight:800; color:var(--text); margin-right:8px; }
    .badge-soft{ background:#eef2f7; color:#334155; border-radius:999px; padding:4px 10px; font-weight:600; }
    .btn, .form-control, .custom-select{ border-radius:12px; }
    .toolbar .spacer{ flex:1; }

    /* 라벨(커스텀 오버레이) */
    .label-pill{
        font-size:12px; line-height:1.2; white-space:nowrap;
        background:#fff; border:1px solid #e5e7eb; border-radius:999px;
        padding:4px 8px; box-shadow:0 2px 8px rgba(15,23,42,.08); color:#0f172a;
    }
    .label-pill .grp{ color:#64748b; }

    .iw{ font-size:14px; color:#0f172a; }
    .iw .ttl{ font-weight:700; margin-bottom:4px; }
    .iw .addr{ color:#6b7280; }
    .page-gap{ height:8px; }
</style>

<div class="container pt-3">
    <h2 class="mb-3">지도 전체보기</h2>

    <div class="map-wrap">
        <div id="map"></div>

        <div class="toolbar">
            <div class="title">지도 전체보기</div>
            <span id="countBadge" class="badge-soft">-건</span>

            <select id="selGroup" class="custom-select custom-select-sm" style="max-width:220px;">
                <option value="">전체 지도그룹</option>
            </select>

            <input id="keyword" class="form-control form-control-sm" style="width:220px;" placeholder="상호/주소 검색"/>
            <button id="btnSearch" class="btn btn-primary btn-sm" type="button">검색</button>

            <div class="spacer"></div>
            <button id="btnLabelOn"  class="btn btn-outline-secondary btn-sm" type="button">라벨 펼치기</button>
            <button id="btnLabelOff" class="btn btn-outline-secondary btn-sm" type="button">라벨 접기</button>
            <button id="btnFit" class="btn btn-outline-secondary btn-sm" type="button">전체보기</button>
            <button id="btnCluster" class="btn btn-outline-secondary btn-sm" type="button" data-on="1">클러스터 OFF</button>
            <button id="btnList" class="btn btn-outline-dark btn-sm" type="button">목록</button>
            <button id="btnGroup" class="btn btn-outline-dark btn-sm" type="button">그룹화면</button>
        </div>
    </div>

    <div class="page-gap"></div>
</div>

<script>
    /* ===== Utils ===== */
    function getParam(n){ try{ return new URL(location.href).searchParams.get(n); }catch(e){ return null; } }
    function debounce(fn, wait){ let t; return function(){ clearTimeout(t); t=setTimeout(fn, wait); }; }

    function setHeaderOffset(){
        var header=document.querySelector('header, .navbar, #header, .site-header, .app-header, .topbar');
        var h=56; if(header){ var r=header.getBoundingClientRect(); h=Math.max(40, Math.round(r.height)); }
        document.documentElement.style.setProperty('--header-h', h+'px');
    }
    function pickStr(obj, keys){
        for(let i=0;i<keys.length;i++){ const v=obj[keys[i]]; if(v!=null && String(v).trim()!=='') return String(v); }
        return '';
    }
    function pickNum(obj, keys){
        for(let i=0;i<keys.length;i++){
            const v=obj[keys[i]];
            if(v===0 || v==='0') return 0;
            if(v!=null && String(v).trim()!==''){ const n=parseFloat(v); if(isFinite(n)) return n; }
        }
        return NaN;
    }
    function escapeHtml(s){
        return String(s||'').replace(/&/g,'&amp;').replace(/</g,'&lt;')
            .replace(/>/g,'&gt;').replace(/"/g,'&quot;').replace(/'/g,'&#39;');
    }

    /* ===== Settings ===== */
    const API_LIST='/api/mmp/map/selectMapList';
    const grpCdParam=getParam('grpCd')||'';
    const DEFAULT_CENTER_COORD=[37.5665,126.9780];
    const DEFAULT_LEVEL=6;

    /* ===== Map state ===== */
    let map, clusterer=null, markers=[], bounds;
    let labelOverlays=[], labelsOn=false; // 라벨 토글 상태
    let groupsInited=false;

    $(function(){
        setHeaderOffset();
        window.addEventListener('resize', debounce(setHeaderOffset,150));

        kakao.maps.load(initMapApp);

        const link=document.createElement('link'); link.rel='icon'; link.href='data:,'; document.head.appendChild(link);

        // 네비게이션
        $('#btnList').on('click', function(){
            let url='/mmp/map/mapList'; if(grpCdParam) url+='?grpCd='+encodeURIComponent(grpCdParam); location.href=url;
        });
        $('#btnGroup').on('click', function(){
            let url='/mmp/mapGrp/mapGrpList'; if(grpCdParam) url+='?grpCd='+encodeURIComponent(grpCdParam); location.href=url;
        });

        // 검색
        $('#btnSearch').on('click', doSearch);
        $('#keyword').on('keydown', function(e){ if(e.key==='Enter') doSearch(); });

        // 그룹 변경 → 재조회
        $('#selGroup').on('change', doSearch);

        // 라벨 토글
        $('#btnLabelOn').on('click', function(){ setLabelsVisible(true); });
        $('#btnLabelOff').on('click', function(){ setLabelsVisible(false); });
    });

    function initMapApp(){
        if(!(window.kakao && kakao.maps)){ alert('Kakao Maps SDK 로드 실패'); return; }

        const center=new kakao.maps.LatLng(DEFAULT_CENTER_COORD[0], DEFAULT_CENTER_COORD[1]);
        map=new kakao.maps.Map(document.getElementById('map'), { center, level:DEFAULT_LEVEL });

        if(kakao.maps.MarkerClusterer){
            clusterer=new kakao.maps.MarkerClusterer({
                map, averageCenter:true, minLevel:6, calculator:[20,50,100,200], disableClickZoom:false
            });
        }else{
            $('#btnCluster').prop('disabled', true).text('클러스터 사용불가');
        }

        bounds=new kakao.maps.LatLngBounds();

        $('#btnFit').on('click', fitAll);
        $('#btnCluster').on('click', function(){
            if(!clusterer) return;
            const on=$(this).attr('data-on')==='1';
            if(on){ clusterer.clear(); markers.forEach(m=>m.setMap(map)); $(this).attr('data-on','0').text('클러스터 ON'); }
            else  { markers.forEach(m=>m.setMap(null)); clusterer.addMarkers(markers); $(this).attr('data-on','1').text('클러스터 OFF'); }
        });

        // 최초 로드
        loadList({ grpCd: grpCdParam, keyword: '' });
    }

    function doSearch(){
        const grpCd=$('#selGroup').val()||'';
        const keyword=$('#keyword').val().trim();
        loadList({ grpCd, keyword });
    }

    function loadList(params){
        $.ajax({
            url:API_LIST, type:'post', contentType:'application/json', dataType:'json',
            data: JSON.stringify(params||{}),
            success:function(res){
                const list=res.result || res.list || [];
                $('#countBadge').text((list.length||0)+'건');

                if(!groupsInited){
                    buildGroupOptions(list, grpCdParam);
                    groupsInited=true;
                }
                renderMarkers(list);
            },
            error:function(){ alert('지도 데이터 로드 실패'); }
        });
    }

    function buildGroupOptions(list, initialGrpCd){
        const uniq={}; const arr=[];
        list.forEach(r=>{
            const cd=pickStr(r,['grpCd','GRP_CD','groupCd','GROUP_CD'])||'';
            const nm=pickStr(r,['grpNm','GRP_NM','groupNm','GROUP_NM','grpName','GRP_NAME'])||(cd||'');
            const key=cd+'||'+nm; if(!uniq[key]){ uniq[key]=1; arr.push({cd,nm}); }
        });
        const $sel=$('#selGroup').empty().append('<option value="">전체 지도그룹</option>');
        arr.sort((a,b)=>String(a.nm).localeCompare(String(b.nm),'ko'));
        arr.forEach(g=> $sel.append($('<option/>').val(g.cd).text(g.nm||g.cd)));
        if(initialGrpCd && $sel.find('option[value="'+initialGrpCd+'"]').length) $sel.val(initialGrpCd);
    }

    function renderMarkers(list){
        // 정리
        if(markers.length){ if(clusterer) clusterer.clear(); markers.forEach(m=>m.setMap(null)); }
        if(labelOverlays.length){ labelOverlays.forEach(o=>o.setMap(null)); }
        markers=[]; labelOverlays=[]; bounds=new kakao.maps.LatLngBounds();

        for(let i=0;i<list.length;i++){
            const r=list[i];
            const lat=pickNum(r,['lat','LAT','latitude','LATITUDE','y','Y']);
            const lng=pickNum(r,['lng','LNG','longitude','LONGITUDE','x','X']);
            if(!isFinite(lat)||!isFinite(lng)) continue;

            const pos=new kakao.maps.LatLng(lat,lng);
            const title=pickStr(r,['title','TITLE','name','NAME','placeName','PLACE_NAME'])||'(제목 없음)';
            const grpNm=pickStr(r,['grpNm','GRP_NM','groupNm','GROUP_NM','grpName','GRP_NAME']);
            const addr =pickStr(r,['addr','ADDR','address','ADDRESS','roadAddress','ROAD_ADDRESS']);
            const mapId=r.mapId || r.MAP_ID;
            const label = grpNm ? (title+' - '+grpNm) : title;

            // 마커
            const marker=new kakao.maps.Marker({ position:pos, title:label });
            const iw=new kakao.maps.InfoWindow({ content: infoHTML(label, addr, mapId), removable:true });
            kakao.maps.event.addListener(marker,'click', function(){ iw.open(map, marker); });

            markers.push(marker);
            bounds.extend(pos);

            // 커스텀 라벨 오버레이 (처음에는 labelsOn 상태에 따라 표시)
            const ov=new kakao.maps.CustomOverlay({
                position: pos,
                yAnchor: 1.2,    // 마커 위쪽에 살짝 띄우기
                content: '<div class="label-pill">'+ escapeHtml(title) + (grpNm? ' <span class="grp">- '+ escapeHtml(grpNm) +'</span>' : '') +'</div>'
            });
            labelOverlays.push(ov);
        }

        const clusterOn=$('#btnCluster').attr('data-on')==='1';
        if(clusterer && clusterOn){ clusterer.addMarkers(markers); markers.forEach(m=>m.setMap(null)); }
        else { markers.forEach(m=>m.setMap(map)); }

        // 라벨 표시 상태 반영
        applyLabelsVisibility();

        fitAll();
    }

    function fitAll(){
        if(!markers.length){
            map.setCenter(new kakao.maps.LatLng(DEFAULT_CENTER_COORD[0], DEFAULT_CENTER_COORD[1]));
            map.setLevel(DEFAULT_LEVEL); return;
        }
        if(map.setBounds.length===2) map.setBounds(bounds,24); else map.setBounds(bounds,24,24,24,24);
    }

    function infoHTML(titleLine, addr, mapId){
        let link=''; if(mapId!=null && mapId!==''){
            let url='/mmp/map/mapDetail?mapId='+encodeURIComponent(mapId);
            const qGrp=$('#selGroup').val() || getParam('grpCd') || '';
            if(qGrp) url+='&grpCd='+encodeURIComponent(qGrp);
            link='<div><a href="'+url+'">상세보기 &rsaquo;</a></div>';
        }
        return '<div class="iw">'
             + '  <div class="ttl">'+ escapeHtml(titleLine) +'</div>'
             + (addr?('<div class="addr">'+ escapeHtml(addr) +'</div>'):'')
             + link
             + '</div>';
    }

    /* ===== Label toggle ===== */
    function setLabelsVisible(on){
        labelsOn = !!on;
        applyLabelsVisibility();
    }
    function applyLabelsVisibility(){
        if(!labelOverlays || !labelOverlays.length) return;
        if(labelsOn){ labelOverlays.forEach(o=>o.setMap(map)); }
        else{ labelOverlays.forEach(o=>o.setMap(null)); }
    }
</script>  