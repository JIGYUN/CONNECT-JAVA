<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>

<section>
    <h2 class="mb-3">푸시 <span id="pageTitle">등록</span></h2>

    <div class="mb-3 d-flex gap-2">
        <button class="btn btn-primary" type="button" onclick="savePush('DRAFT')">저장(초안)</button>
        <button class="btn btn-dark" type="button" onclick="savePush('QUEUED')">발송 요청</button>
        <c:if test="${not empty param.msgId}">
            <button class="btn btn-outline-danger" type="button" onclick="deletePush()">삭제</button>
        </c:if>
        <a class="btn btn-outline-secondary" href="/adm/psh/push/pushList">목록</a>
    </div>

    <form id="pushForm">
        <!-- PK -->
        <input type="hidden" name="msgId" id="msgId" value="${param.msgId}"/>

        <!-- 제목 -->
        <div class="form-group mb-3" style="max-width: 720px;">
            <label for="title" class="form-label">제목<span class="text-danger">*</span></label>
            <input type="text" class="form-control" name="title" id="title" placeholder="예) 서비스 점검 안내" />
        </div>

        <!-- 내용(일반 텍스트) -->
        <div class="form-group mb-3" style="max-width: 900px;">
            <label for="bodyTxt" class="form-label">내용<span class="text-danger">*</span></label>
            <textarea
                class="form-control"
                id="bodyTxt"
                name="bodyTxt"
                rows="10"
                placeholder="발송 본문을 입력하세요…(텍스트/간단 HTML 허용)"
                style="font-family: system-ui, -apple-system, Segoe UI, Roboto, sans-serif;"></textarea>
        </div>

        <!-- 대상 최소 설정 -->
        <div class="form-group mb-3" style="max-width: 900px;">
            <label class="form-label">대상<span class="text-danger">*</span></label>
            <div class="form-check">
                <input class="form-check-input" type="radio" name="targetTypeCd" id="t_all" value="ALL" checked>
                <label class="form-check-label" for="t_all">전체</label>
            </div>
            <div class="form-check d-flex align-items-center gap-2 mt-1">
                <input class="form-check-input" type="radio" name="targetTypeCd" id="t_user" value="USER">
                <label class="form-check-label" for="t_user">특정 사용자</label>
                <input type="number" class="form-control" id="targetUserId" placeholder="USER_ID" style="max-width: 220px;">
            </div>
            <div class="form-check mt-1">
                <input class="form-check-input" type="radio" name="targetTypeCd" id="t_tokens" value="TOKENS">
                <label class="form-check-label" for="t_tokens">토큰 목록(줄바꿈으로 구분)</label>
                <textarea id="tokensArea" class="form-control mt-2" rows="3" placeholder="APA91b...\nAPA91c..."></textarea>
            </div>
        </div>

        <!-- 선택: 예약 발송 -->
        <div class="form-group mb-3" style="max-width: 420px;">
            <label for="scheduleDt" class="form-label">예약 일시(선택)</label>
            <input type="datetime-local" class="form-control" id="scheduleDt" />
            <div class="form-text">비우면 즉시 발송. 값이 있으면 서버에서 예약 처리.</div>
        </div>

        <!-- 선택: 클릭 링크 / 이미지 (최소 옵션) -->
        <div class="form-group mb-3" style="max-width: 720px;">
            <label class="form-label">옵션(선택)</label>
            <input type="url" class="form-control mb-2" id="clickUrl" placeholder="클릭 URL (선택)">
            <input type="url" class="form-control" id="imageUrl" placeholder="이미지 URL (선택)">
        </div>
    </form>
</section>

<script>
    const API_BASE = '/api/psh/push';
    const PK = 'msgId';

    $(function () {
        // 상세 로드
        const id = $('#' + PK).val();
        if (id) { $('#pageTitle').text('수정'); readPush(id); }
        // 대상 토글
        $('input[name="targetTypeCd"]').on('change', toggleTargetFields);
        toggleTargetFields();
    });

    function toggleTargetFields() {
        const v = $('input[name="targetTypeCd"]:checked').val();
        $('#targetUserId').prop('disabled', v !== 'USER').toggleClass('bg-light', v !== 'USER');
        $('#tokensArea').prop('disabled', v !== 'TOKENS').toggleClass('bg-light', v !== 'TOKENS');
    }

    // 상세 조회 → 폼 채움
    function readPush(id) {
        const payload = {}; payload[PK] = id;
        $.ajax({
            url: API_BASE + '/selectPushDetail',
            type: 'post',
            contentType: 'application/json',
            dataType: 'json',
            data: JSON.stringify(payload),
            success: function (map) {
                const r = map.result || map.push || map || {};
                $('#title').val(r.title || '');
                $('#bodyTxt').val(r.bodyTxt || r.content || r.BODY_TXT || '');

                const t = (r.targetTypeCd || r.TARGET_TYPE_CD || 'ALL').toString();
                $('input[name="targetTypeCd"][value="'+t+'"]').prop('checked', true);
                $('#targetUserId').val(r.targetUserId || r.TARGET_USER_ID || '');
                try {
                    const tokens = r.tokensJson || r.TOKENS_JSON || '';
                    if (tokens) {
                        const arr = Array.isArray(tokens) ? tokens : JSON.parse(tokens);
                        $('#tokensArea').val(arr.join('\n'));
                    }
                } catch {}

                $('#clickUrl').val(r.clickUrl || r.CLICK_URL || '');
                $('#imageUrl').val(r.imageUrl || r.IMAGE_URL || '');

                const sched = r.scheduleDt || r.SCHEDULE_DT || '';
                if (sched) $('#scheduleDt').val(toLocalInputValue(sched));

                toggleTargetFields();
            },
            error: function () { alert('조회 중 오류 발생'); }
        });
    }

    // 저장/발송: statusCd = DRAFT | QUEUED
    function savePush(statusCd) {
        const id = $('#' + PK).val();
        const url = id ? (API_BASE + '/updatePush') : (API_BASE + '/insertPush');

        const title = ($('#title').val() || '').trim();
        const bodyTxt = ($('#bodyTxt').val() || '').trim();
        if (!title) { alert('제목을 입력하세요.'); return; }
        if (!bodyTxt) { alert('내용을 입력하세요.'); return; }

        const targetTypeCd = $('input[name="targetTypeCd"]:checked').val();
        let targetUserId = null, tokensJson = null;

        if (targetTypeCd === 'USER') {
            const n = Number($('#targetUserId').val());
            if (!Number.isFinite(n) || n <= 0) { alert('USER_ID를 올바르게 입력하세요.'); return; }
            targetUserId = n;
        } else if (targetTypeCd === 'TOKENS') {
            const lines = ($('#tokensArea').val() || '').split(/\r?\n/).map(s => s.trim()).filter(Boolean);
            if (!lines.length) { alert('토큰을 1개 이상 입력하세요.'); return; }
            tokensJson = JSON.stringify(lines);
        }

        const schedRaw = $('#scheduleDt').val();
        const clickUrl = ($('#clickUrl').val() || '').trim() || null;
        const imageUrl = ($('#imageUrl').val() || '').trim() || null;

        const payload = clean({
            msgId: id ? Number(id) : undefined,
            title,
            bodyTxt,                                 // textarea 값
            targetTypeCd,
            targetUserId: targetUserId ?? undefined,
            tokensJson: tokensJson ?? undefined,
            scheduleDt: schedRaw ? schedRaw + ':00' : undefined,
            clickUrl: clickUrl ?? undefined,
            imageUrl: imageUrl ?? undefined,
            statusCd,                                // DRAFT or QUEUED
            priorityCd: 'NORMAL',
            ttlSec: 3600
        });

        $.ajax({
            url: url,
            type: 'post',
            contentType: 'application/json',
            dataType: 'json',
            data: JSON.stringify(payload),
            success: function () { location.href = '/adm/psh/push/pushList'; },
            error: function () { alert('저장 중 오류 발생'); }
        });
    }

    function deletePush() {
        const id = $('#' + PK).val();
        if (!id) { alert('삭제할 대상이 없습니다.'); return; }
        if (!confirm('정말 삭제하시겠습니까?')) return;

        const payload = {}; payload[PK] = Number(id);
        $.ajax({
            url: API_BASE + '/deletePush',
            type: 'post',
            contentType: 'application/json',
            dataType: 'json',
            data: JSON.stringify(payload),
            success: function () {
                alert('삭제 완료되었습니다.');
                location.href = '/adm/psh/push/pushList';
            },
            error: function () { alert('삭제 중 오류 발생'); }
        });
    }

    // utils
    function clean(o) {
        const r = {};
        Object.keys(o).forEach(k => { if (o[k] !== undefined) r[k] = o[k]; });
        return r;
    }
    function toLocalInputValue(dt) {
        try {
            if (typeof dt === 'string' && dt.includes('T')) return dt.slice(0, 16);
            const d = new Date(dt);
            if (isNaN(d.getTime())) return '';
            const pad = n => (n < 10 ? '0' + n : '' + n);
            return d.getFullYear() + '-' + pad(d.getMonth() + 1) + '-' + pad(d.getDate()) +
                   'T' + pad(d.getHours()) + ':' + pad(d.getMinutes());
        } catch { return ''; }
    }
</script>
