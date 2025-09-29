<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>

<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.2/dist/css/bootstrap.min.css"/>
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>

<style>
    :root{ --bg:#f6f8fb; --card:#ffffff; --line:#e9edf3; --text:#0f172a; --muted:#6b7280; }
    body{ background:var(--bg); }
    .page-title{ font-size:26px; font-weight:800; color:var(--text); margin:12px 0 14px; }
    .toolbar{ display:flex; gap:8px; align-items:center; flex-wrap:wrap; margin:8px 0 16px; }
    .btn, .form-control, .custom-select{ border-radius:12px; }
    .table thead th{ border-top:none; }
</style>

<section class="container-fluid">
    <h2 class="page-title">레시피 목록</h2>

    <div class="toolbar">
        <input id="keyword" class="form-control" style="max-width:260px;" placeholder="제목/태그 검색"/>
        <select id="visibilityCd" class="custom-select" style="max-width:160px;">
            <option value="">공개 전체</option>
            <option value="PUBLIC" selected>PUBLIC</option>
            <option value="UNLISTED">UNLISTED</option>
            <option value="PRIVATE">PRIVATE</option>
        </select>
        <button class="btn btn-outline-secondary" type="button" onclick="reload()">검색</button>
        <div class="ml-auto"></div>
        <button class="btn btn-primary" type="button" onclick="goNew()">새 레시피</button>
    </div>

    <div class="table-responsive card">
        <table class="table table-hover align-middle mb-0">
            <thead class="thead-light">
                <tr>
                    <th style="width:90px; text-align:right;">ID</th>
                    <th>제목</th>
                    <th style="width:140px;">공개</th>
                    <th style="width:160px;">난이도</th>
                    <th style="width:220px;">작성일</th>
                </tr>
            </thead>
            <tbody id="listBody"></tbody>
        </table>
    </div>
</section>

<script>
    const API = '/api/rcp/recipe';

    $(function(){
        reload();
    });

    function reload(){
        const param = {
            keyword: $('#keyword').val() || '',
            visibilityCd: $('#visibilityCd').val() || '',
            useAt: 'Y'
        };
        $.ajax({
            url: API + '/selectList',
            type: 'post',
            contentType: 'application/json',
            data: JSON.stringify(param),
            success: function(map){
                render(map.list || []);
            },
            error: function(){ alert('목록 조회 오류'); }
        });
    }

    function render(list){
        const $tb = $('#listBody').empty();
        if (!list.length){
            $tb.append("<tr><td colspan='5' class='text-center text-muted'>등록된 레시피가 없습니다.</td></tr>");
            return;
        }
        for (let i=0;i<list.length;i++){
            const r = list[i];
            const id  = r.RECIPE_ID || r.recipeId;
            const cd  = r.RECIPE_CD || r.recipeCd || '';
            const ttl = r.TITLE || r.title || '';
            const vis = r.VISIBILITY_CD || r.visibilityCd || '';
            const diff= r.DIFFICULTY_CD || r.difficultyCd || '';
            const cdt = r.CREATED_DT || r.createdDt || '';
            let tr  = "<tr onclick=\"goEdit('" + id + "')\">";
            tr += "  <td class='text-right'>" + id + "</td>";
            tr += "  <td>" + escapeHtml(ttl) + (cd ? " <span class='badge badge-light'>"+ escapeHtml(cd) +"</span>" : "") + "</td>";
            tr += "  <td>" + vis + "</td>";
            tr += "  <td>" + (diff || '-') + "</td>";
            tr += "  <td>" + (cdt || '') + "</td>";
            tr += "</tr>";
            $tb.append(tr);
        }
    }

    function goNew(){  
        location.href = '/adm/rcp/recipe/recipeModify';
    }

    function goEdit(id){
        location.href = '/adm/rcp/recipe/recipeModify?recipeId=' + encodeURIComponent(id);
    }

    function escapeHtml(s){
        return String(s||'')
            .replace(/&/g,'&amp;').replace(/</g,'&lt;')
            .replace(/>/g,'&gt;').replace(/"/g,'&quot;').replace(/'/g,'&#39;');
    }
</script>