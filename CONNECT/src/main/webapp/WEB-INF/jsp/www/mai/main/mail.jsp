<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>

<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.2/dist/css/bootstrap.min.css"/>
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>

<style>
    :root{ --bg:#f6f8fb; --card:#ffffff; --line:#e9edf3; --text:#0f172a; --muted:#6b7280; }
    body{ background:var(--bg); }
    .wrap{ max-width:860px; margin:24px auto 60px; }
    .card{ background:var(--card); border:1px solid var(--line); border-radius:16px; padding:18px; box-shadow:0 4px 16px rgba(15,23,42,.06); }
    .title{ font-size:22px; font-weight:800; color:var(--text); margin-bottom:14px; }
    .form-control, .btn{ border-radius:12px; }
    .muted{ color:#6b7280; }
    .result{ white-space:pre-wrap; background:#0b1220; color:#cbd5e1; padding:12px; border-radius:12px; font-family:ui-monospace, Menlo, Consolas, monospace; }
</style>

<div class="wrap">
    <div class="title">메일 테스트 발송</div>
    <div class="card">
        <form id="mailForm" onsubmit="return false;">
            <div class="form-group">
                <label>받는사람 (쉼표/공백/세미콜론 구분 가능)</label>
                <input type="text" class="form-control" id="to" name="to" placeholder="user1@example.com, user2@example.com"/>
            </div>
            <div class="form-row">
                <div class="form-group col-md-6">
                    <label>CC</label>
                    <input type="text" class="form-control" id="cc" name="cc" placeholder="(선택)"/>
                </div>
                <div class="form-group col-md-6">
                    <label>BCC</label>
                    <input type="text" class="form-control" id="bcc" name="bcc" placeholder="(선택)"/>
                </div>
            </div>
            <div class="form-group">
                <label>제목</label>
                <input type="text" class="form-control" id="subject" name="subject" placeholder="메일 제목"/>
            </div>
            <div class="form-group">
                <label>본문(HTML)</label>
                <textarea class="form-control" id="bodyHtml" name="bodyHtml" rows="8" placeholder="<h3>안녕하세요</h3><p>본문...</p>"></textarea>
                <small class="muted">예: 그룹 지도 링크 <code>&lt;a href="/map/web?grpCd=sikyung"&gt;열기&lt;/a&gt;</code></small>
            </div>
            <div class="form-group">
                <label>첨부 파일그룹 ID (선택)</label>
                <input type="number" class="form-control" id="fileGrpId" name="fileGrpId" min="0" placeholder="예) 123"/>
            </div>
            <div class="d-flex">
                <button type="button" class="btn btn-primary mr-2" onclick="sendNow()">발송</button>
                <button type="button" class="btn btn-outline-secondary" onclick="fillSample()">샘플 입력</button>
            </div>
        </form>
        <div id="out" class="result mt-3" style="display:none;"></div>
    </div>
</div>

<script>
    function sendNow(){
        const payload = {
            to: $('#to').val(),
            cc: $('#cc').val(),
            bcc: $('#bcc').val(),
            subject: $('#subject').val(),
            bodyHtml: $('#bodyHtml').val()
        };
        const gid = $('#fileGrpId').val();
        if (gid) payload.fileGrpId = Number(gid);

        $.ajax({
            url: '/api/com/mail/sendNow',
            type: 'post',
            contentType: 'application/json',
            dataType: 'json',
            data: JSON.stringify(payload),
            success: function(res){
                $('#out').show().text(JSON.stringify(res, null, 2));
                alert('발송 시도 결과: ' + (res.msg || ''));
            },
            error: function(xhr){
                $('#out').show().text(xhr.responseText || ('HTTP ' + xhr.status));
                alert('발송 실패');
            }
        });
    }

    function fillSample(){
        $('#to').val('user@example.com');
        $('#subject').val('[지도] 성시경의 맛집 리스트');
        $('#bodyHtml').val('<h3>성시경의 먹을텐데</h3><p><a href="/map/web?grpCd=sikyung" target="_blank">그룹 지도 보기</a></p>');
        $('#fileGrpId').val('');
    }
</script>