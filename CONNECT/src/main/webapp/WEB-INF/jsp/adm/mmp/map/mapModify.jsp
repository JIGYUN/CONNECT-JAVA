<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%> 
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <title>지도 ${empty param.mapId ? '등록' : '수정'}</title>

    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.2/dist/css/bootstrap.min.css"/>
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>

    <!-- Kakao Maps JS SDK : JavaScript 키 사용 -->
    <script src="https://dapi.kakao.com/v2/maps/sdk.js?appkey=b4eb6efe0b6e28aecabcfbb7bee56041&autoload=false&libraries=services"></script>
    
    <style>
        .panel { border:1px solid #e9ecef; border-radius:12px; }
        #kmap { height:420px; border-radius:12px; }
        .help-text { color:#6c757d; font-size:.9rem; }
        .search-panel { padding:12px; }
        .place-item { padding:10px 8px; border-top:1px solid #f1f3f5; cursor:pointer; }
        .place-item:hover { background:#f8f9fa; }
        .place-name { font-weight:600; }
        .place-addr { color:#6c757d; font-size:.9rem; }
        .pagination { margin:10px 0 0; }
        .iw-wrap{ font-size:13px; line-height:1.4; padding:6px 8px; }
        .iw-name{ font-weight:700; }
        .iw-addr{ color:#6c757d; }
    </style>
</head>
<body class="container my-4">

<h3 class="mb-3">지도 포인트 ${empty param.mapId ? '등록' : '수정'}</h3>

<form id="mapForm" onsubmit="return false;">
    <input type="hidden" id="mapId" name="mapId" value="${param.mapId}" />
    <!-- grpCd 유지 -->
    <input type="hidden" id="grpCd" name="grpCd" value="${param.grpCd}" />

    <div class="form-row">
        <div class="form-group col-md-8">
            <label>제목</label>
            <input type="text" class="form-control" id="title" name="title" placeholder="예) 을지로 노포 투어" />
        </div>
    </div>

    <div class="form-row">
        <div class="form-group col-md-6">
            <label>지도 표시명</label>
            <input type="text" class="form-control" id="mapNm" name="mapNm" placeholder="마커에 보일 이름" />
        </div>
        <div class="form-group col-md-6">
            <label>좌표</label>
            <div class="form-row">
                <div class="col">
                    <input type="text" class="form-control" id="lat" name="lat" placeholder="37.5665" />
                </div>
                <div class="col">
                    <input type="text" class="form-control" id="lng" name="lng" placeholder="126.9780" />
                </div>
            </div>
            <small class="help-text">지도를 클릭하면 자동으로 채워집니다. (마커 드래그 가능)</small>
        </div>
    </div>

    <div class="form-group">
        <label>내용</label>
        <textarea class="form-control" id="content" name="content" rows="5" placeholder="설명/메모 등"></textarea>
    </div>

    <div class="row">
        <div class="col-lg-8 mb-3">
            <div class="panel p-2">
                <div class="d-flex align-items-center justify-content-between">
                    <span class="help-text">지도 클릭 시 좌표/제목/주소 자동 입력 · 마커 드래그 가능</span>
                    <div>
                        <button type="button" class="btn btn-outline-secondary btn-sm" onclick="moveToLatLng()">좌표로 이동</button>
                        <button type="button" class="btn btn-outline-secondary btn-sm" onclick="resetSeoul()">서울 중심</button>
                    </div>
                </div>
                <div id="kmap" class="mt-2"></div>
            </div>
        </div>

        <div class="col-lg-4 mb-3">
            <div class="panel search-panel">
                <div class="input-group">
                    <input type="text" class="form-control" id="keyword" placeholder="예) 명동교자, 홍대 카페, 강남 맛집" />
                    <div class="input-group-append">
                        <button type="button" class="btn btn-primary" onclick="doSearch(1)">검색</button>
                    </div>
                </div>
                <small class="help-text d-block mt-1">검색 결과 클릭 시 이름/주소/좌표가 자동 입력됩니다.</small>

                <div id="searchResult" class="mt-2" style="max-height:320px; overflow:auto;"></div>
                <nav><ul id="pager" class="pagination justify-content-center"></ul></nav>
            </div>
        </div>
    </div>

    <div class="d-flex">
        <button type="button" class="btn btn-primary mr-2" onclick="saveMap()">저장</button>
        <c:if test="${not empty param.mapId}">
            <button type="button" class="btn btn-outline-danger mr-2" onclick="deleteMap()">삭제</button>
        </c:if>
        <button type="button" class="btn btn-outline-secondary" onclick="backToList()">목록</button>
    </div>
</form>

<script>
const API_BASE = '/api/mmp/map';
const PK = 'mapId';

function getParam(name){
    const u = new URL(location.href);
    return u.searchParams.get(name);
}

function backToList(){
    const gc = $('#grpCd').val() || getParam('grpCd') || '';
    let url = '/adm/mmp/map/mapList';
    if (gc) url += '?grpCd=' + encodeURIComponent(gc);
    location.href = url;
}

$.fn.serializeObject = function () {
    const obj = {};
    const arr = this.serializeArray();
    $.each(arr, function(){ obj[this.name] = this.value; });
    return obj;
};
function goLink(path){ location.href = path; }

function escapeHtml(s){
    return String(s||'')
        .replace(/&/g, '&amp;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        .replace(/"/g, '&quot;')
        .replace(/'/g, '&#39;');
}
function deriveShortName(addr){
    if (!addr){ return '선택 지점'; }
    var tokens = String(addr).split(' ');
    var last = tokens[tokens.length-1] || addr;
    return last;
}

/* ====== Enter 로 검색 ====== */
$('#keyword').on('keydown', function(e){
    if (e.key === 'Enter') {
        e.preventDefault();
        doSearch(1);
    }
});

/* Kakao Map */
let map, marker, places, geocoder, infowindow;

kakao.maps.load(function(){
    map = new kakao.maps.Map(document.getElementById('kmap'), {
        center: new kakao.maps.LatLng(37.5665, 126.9780),
        level: 5
    });
    places     = new kakao.maps.services.Places();
    geocoder   = new kakao.maps.services.Geocoder();
    infowindow = new kakao.maps.InfoWindow({removable: false});

    kakao.maps.event.addListener(map, 'click', function(e){
        var lat = e.latLng.getLat();
        var lng = e.latLng.getLng();
        setMarker(lat, lng, true);
        reverseFill(lat, lng);
    });

    var id = $("#"+PK).val();
    if (id) readMap(id);

    $('#mapNm, #content').on('input', updateMarkerUI);
});

function setMarker(lat, lng, writeInputs){
    var ll = new kakao.maps.LatLng(lat, lng);

    if (!marker) {
        marker = new kakao.maps.Marker({ position: ll, draggable: true });
        marker.setMap(map);

        kakao.maps.event.addListener(marker, 'dragend', function(){
            var p = marker.getPosition();
            var la = p.getLat().toFixed(6), lo = p.getLng().toFixed(6);
            $('#lat').val(la); $('#lng').val(lo);
            reverseFill(la, lo);
        });

        kakao.maps.event.addListener(marker, 'click', updateMarkerUI);
    } else {
        marker.setPosition(ll);
    }
    map.setCenter(ll);

    if (writeInputs) {
        $('#lat').val(Number(lat).toFixed(6));
        $('#lng').val(Number(lng).toFixed(6));
    }
    updateMarkerUI();
}

function updateMarkerUI(){
    if (!marker) return;
    var name = ($('#mapNm').val() || '').trim();
    var addr = ($('#content').val() || '').trim();

    if (name){ marker.setTitle(name); } else { marker.setTitle(''); }

    var html  = '<div class="iw-wrap">';
    html += '<div class="iw-name">' + escapeHtml(name || '선택 지점') + '</div>';
    if (addr){
        html += '<div class="iw-addr">' + escapeHtml(addr) + '</div>';
    }
    html += '</div>';

    infowindow.setContent(html);
    infowindow.open(map, marker);
}

function reverseFill(lat, lng){
    geocoder.coord2Address(Number(lng), Number(lat), function(result, status){
        if (status === kakao.maps.services.Status.OK && result.length){
            var road  = result[0].road_address && result[0].road_address.address_name;
            var jibun = result[0].address && result[0].address.address_name;
            var addrFull = road || jibun || '';

            var shortName = deriveShortName(addrFull);

            $('#mapNm').val(shortName);
            $('#title').val(shortName);
            $('#content').val(addrFull);

        } else {
            var fallback = '위치: ' + String(lat) + ', ' + String(lng);
            $('#mapNm').val('선택 지점');
            $('#title').val('선택 지점');
            $('#content').val(fallback);
        }
        updateMarkerUI();
    });
}

function moveToLatLng(){
    var lat = parseFloat($('#lat').val());
    var lng = parseFloat($('#lng').val());
    if (isFinite(lat) && isFinite(lng)) {
        setMarker(lat, lng, false);
        map.setLevel(4);
        reverseFill(lat, lng);
    } else {
        alert('올바른 좌표를 입력하세요.');
    }
}
function resetSeoul(){
    map.setCenter(new kakao.maps.LatLng(37.5665, 126.9780));
    map.setLevel(5);
}

/* 검색 */
var lastKeyword = '';
function doSearch(page){
    var kw = ($('#keyword').val() || '').trim();
    if (!kw) { alert('검색어를 입력하세요.'); return; }
    lastKeyword = kw;

    places.keywordSearch(kw, placesCB, { page: page || 1, size: 10 });
}

function placesCB(data, status, pagination){
    var $list = $('#searchResult').empty();
    $('#pager').empty();

    if (status !== kakao.maps.services.Status.OK) {
        $list.append('<div class="text-muted small py-3">검색 결과가 없습니다.</div>');
        return;
    }

    for (var i=0; i<data.length; i++){
        (function(p){
            var $item = $('<div class="place-item"></div>');
            $('<div class="place-name"></div>').text(p.place_name || '').appendTo($item);
            $('<div class="place-addr"></div>').text(p.road_address_name || p.address_name || '').appendTo($item);

            $item.on('click', function(){
                var lat = Number(p.y), lng = Number(p.x);
                $('#mapNm').val(p.place_name || '');
                $('#title').val(p.place_name || '');
                $('#content').val(p.road_address_name || p.address_name || '');
                setMarker(lat, lng, true);
                map.setLevel(4);
                updateMarkerUI();
            });
            $list.append($item);
        })(data[i]);
    }

    var $pager = $('#pager');
    function mk(num, active, label){
        return '<li class="page-item ' + (active?'active':'') + '">' +
               '<a class="page-link" href="javascript:void(0)" onclick="doSearch(' + num + ')">' + (label||num) + '</a>' +
               '</li>';
    }
    if (pagination.current > 1) $pager.append(mk(pagination.current-1, false, '&laquo;'));
    for (var j=1; j<=pagination.last; j++) $pager.append(mk(j, j===pagination.current, null));
    if (pagination.current < pagination.last) $pager.append(mk(pagination.current+1, false, '&raquo;'));
}

/* CRUD */
function readMap(id){
    var send = {}; send[PK] = id;
    $.ajax({
        url: API_BASE + '/selectMapDetail',
        type: 'post',
        contentType: 'application/json',
        dataType: 'json',
        data: JSON.stringify(send),
        success: function(res){
            var r = res.result || res.map || res;
            if (!r) return;

            $('#title').val(r.title || '');
            $('#mapNm').val(r.mapNm || r.map_nm || '');
            $('#content').val(r.content || '');
            $('#lat').val(r.lat || '');
            $('#lng').val(r.lng || r.lon || '');
            if (r.grpCd || r.GRP_CD) $('#grpCd').val(r.grpCd || r.GRP_CD);

            if (r.lat && r.lng) {
                setMarker(Number(r.lat), Number(r.lng), false);
                updateMarkerUI();
            }
        },
        error: function(){ alert('조회 중 오류가 발생했습니다.'); }
    });
}

function saveMap(){
    if (!$('#title').val().trim())  { alert('제목을 입력하세요.'); return; }
    if (!$('#mapNm').val().trim())  { alert('지도 표시명을 입력하세요.'); return; }
    if (!$('#lat').val().trim() || !$('#lng').val().trim()) { alert('좌표를 입력하거나 지도에서 선택하세요.'); return; }

    var id  = $("#"+PK).val();
    var url = id ? (API_BASE + '/updateMap') : (API_BASE + '/insertMap');
    var body= $('#mapForm').serializeObject(); // grpCd 포함

    $.ajax({
        url: url, type: 'post', contentType:'application/json', dataType:'json',
        data: JSON.stringify(body),
        success: function(){
            backToList();
        },
        error: function(){ alert('저장 중 오류가 발생했습니다.'); }
    });
}

function deleteMap(){
    var id = $("#"+PK).val();
    if (!id) { alert('삭제할 대상의 PK가 없습니다.'); return; }
    if (!confirm('정말 삭제하시겠습니까?')) return;

    var send = {}; send[PK]=id;
    $.ajax({
        url: API_BASE + '/deleteMap', type:'post', contentType:'application/json', dataType:'json',
        data: JSON.stringify(send),
        success: function(){
            backToList();
        },
        error: function(){ alert('삭제 중 오류가 발생했습니다.'); }
    });
}
</script>
</body>
</html> 