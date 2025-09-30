<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>

<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.2/dist/css/bootstrap.min.css"/>
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>

<link rel="stylesheet" href="https://uicdn.toast.com/editor/latest/toastui-editor.min.css"/>
<script src="https://uicdn.toast.com/editor/latest/toastui-editor-all.min.js"></script>

<section class="container" style="max-width: 980px;">
    <h2 class="my-3">상품 <span id="pageTitle">등록</span></h2>

    <div class="mb-3">
        <button class="btn btn-primary" type="button" onclick="saveProduct()">저장</button>
        <c:if test="${not empty param.productId}">
            <button class="btn btn-outline-danger" type="button" onclick="deleteProduct()">삭제</button>
        </c:if>
        <a class="btn btn-outline-secondary" href="/prd/product/productList">목록</a>
    </div>

    <form id="frm">
        <input type="hidden" name="productId" id="productId" value="${param.productId}"/>

        <div class="form-row">
            <div class="form-group col-md-8">
                <label>제목</label>
                <input type="text" class="form-control" name="title" id="title" required/>
            </div>
            <div class="form-group col-md-4">
                <label>브랜드</label>
                <input type="text" class="form-control" name="brandNm" id="brandNm"/>
            </div>
        </div>

        <div class="form-row">
            <div class="form-group col-md-3">
                <label>판매가</label>
                <input type="number" class="form-control" name="salePrice" id="salePrice" step="0.01"/>
            </div>
            <div class="form-group col-md-3">
                <label>정가</label>
                <input type="number" class="form-control" name="listPrice" id="listPrice" step="0.01"/>
            </div>
            <div class="form-group col-md-2">
                <label>통화</label>
                <input type="text" class="form-control" name="currencyCd" id="currencyCd" value="KRW"/>
            </div>
            <div class="form-group col-md-2">
                <label>평점</label>
                <input type="number" class="form-control" name="ratingAvg" id="ratingAvg" step="0.01" max="5"/>
            </div>
            <div class="form-group col-md-2">
                <label>리뷰수</label>
                <input type="number" class="form-control" name="reviewCnt" id="reviewCnt"/>
            </div>
        </div>

        <div class="form-row">
            <div class="form-group col-md-8">
                <label>대표 이미지 URL</label>
                <input type="text" class="form-control" name="mainImgUrl" id="mainImgUrl"/>
            </div>
            <div class="form-group col-md-4">
                <label>원본 상품 URL</label>
                <input type="text" class="form-control" name="productUrl" id="productUrl"/>
            </div>
        </div>

        <div class="form-row">
            <div class="form-group col-md-3">
                <label>수집처</label>
                <select class="form-control" name="sourceCd" id="sourceCd">
                    <option value="CPNG">쿠팡</option>
                    <option value="GMRK">G마켓</option>
                    <option value="NVSH">네이버쇼핑</option>
                </select>
            </div>
            <div class="form-group col-md-3">
                <label>라우팅키(GRP_CD)</label>
                <input type="text" class="form-control" name="grpCd" id="grpCd" value="sikyung"/>
            </div>
            <div class="form-group col-md-3">
                <label>배송비</label>
                <input type="number" class="form-control" name="shipFee" id="shipFee" step="0.01"/>
            </div>
            <div class="form-group col-md-3">
                <label>외부 상품ID</label>
                <input type="text" class="form-control" name="sourcePid" id="sourcePid"/>
            </div>
        </div>

        <div class="form-group">
            <label>상세 설명</label>
            <div id="editor" style="height: 360px;"></div>
            <input type="hidden" name="descriptionTxt" id="descriptionTxt"/>
        </div>
    </form>
</section>

<script>
    const API_BASE = '/api/prd/product';
    const PK = 'productId';
    let editor;

    $(function(){
        editor = new toastui.Editor({
            el: document.querySelector('#editor'),
            height: '360px',
            initialEditType: 'wysiwyg',
            previewStyle: 'vertical',
            placeholder: '상세 설명을 입력하세요...'
        });

        const id = $('#' + PK).val();
        if (id) {
            $('#pageTitle').text('수정');
            readProduct(id);
        } else {
            $('#pageTitle').text('등록');
        }
    });

    function readProduct(id){
        const p = {}; p[PK] = id;
        $.ajax({
            url: API_BASE + '/selectProductDetail',
            type: 'post',
            contentType: 'application/json',
            dataType: 'json',
            data: JSON.stringify(p),
            success: function(map){
                const r = map.result || {};
                $('#title').val(r.title || '');
                $('#brandNm').val(r.brandNm || '');
                $('#salePrice').val(r.salePrice || '');
                $('#listPrice').val(r.listPrice || '');
                $('#currencyCd').val(r.currencyCd || 'KRW');
                $('#ratingAvg').val(r.ratingAvg || '');
                $('#reviewCnt').val(r.reviewCnt || '');
                $('#mainImgUrl').val(r.mainImgUrl || '');
                $('#productUrl').val(r.productUrl || '');
                $('#sourceCd').val(r.sourceCd || 'CPNG');
                $('#grpCd').val(r.grpCd || 'sikyung');
                $('#shipFee').val(r.shipFee || '');
                $('#sourcePid').val(r.sourcePid || '');
                editor.setHTML(r.descriptionTxt || '');
            },
            error: function(){ alert('조회 중 오류'); }
        });
    }

    function saveProduct(){
        if (!$('#title').val()) { alert('제목을 입력하세요.'); return; }
        $('#descriptionTxt').val(editor.getHTML());

        const id = $('#' + PK).val();
        const url = id ? (API_BASE + '/updateProduct') : (API_BASE + '/insertProduct');
        const data = $('#frm').serializeObject();

        $.ajax({
            url: url, type: 'post', contentType: 'application/json', dataType: 'json',
            data: JSON.stringify(data),
            success: function(){ location.href = '/prd/product/productList'; },
            error: function(){ alert('저장 중 오류'); }
        });
    }

    function deleteProduct(){
        const id = $('#' + PK).val();
        if (!id){ alert('삭제 대상이 없습니다.'); return; }
        if (!confirm('정말 삭제하시겠습니까?')) return;

        const p = {}; p[PK] = id;
        $.ajax({
            url: API_BASE + '/deleteProduct', type: 'post',
            contentType: 'application/json', dataType: 'json',
            data: JSON.stringify(p),
            success: function(){ alert('삭제 완료'); location.href='/prd/product/productList'; },
            error: function(){ alert('삭제 중 오류'); }
        });
    }

    // serializeObject
    $.fn.serializeObject = function () {
        const o = {}; const a = this.serializeArray();
        for (let i=0;i<a.length;i++){ o[a[i].name] = a[i].value; }
        return o;
    };
</script>