<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<section>
    <h2 class="mb-3">푸시 로그</h2>

    <div class="mb-3 d-flex gap-2">
        <button class="btn btn-primary" type="button" onclick="goToPushModify()">글쓰기</button>
        <button class="btn btn-outline-secondary" type="button" onclick="goToPush()">통합</button>
    </div>

    <div class="table-responsive">
        <table class="table table-hover align-middle">
            <thead class="thead-light">
                <tr>
                    <th style="width: 90px; text-align:right;">번호</th>
                    <th style="width: 260px;">제목</th>
                    <th>내용</th> <!-- ★ 추가 -->
                    <th style="width: 160px;">대상</th>
                    <th style="width: 120px;">상태</th>
                    <th style="width: 140px;">성공/실패</th>
                    <th style="width: 280px;">예약/발송 구간</th>
                    <th style="width: 180px;">작성일</th>
                </tr>
            </thead>
            <tbody id="pushListBody"></tbody>
        </table>
    </div>
</section>

<script>
    // ▼ JavaGen 치환
    const API_BASE = '/api/psh/push';

    $(function () {
        selectPushList();
    });

    // ───────────────────────── helpers ─────────────────────────
    function htmlEscape(s) {
        if (s == null) return '';
        return String(s)
            .replace(/&/g, '&amp;')
            .replace(/</g, '&lt;')
            .replace(/>/g, '&gt;')
            .replace(/"/g, '&quot;')
            .replace(/'/g, '&#39;');
    }

    function safeStr(v) {
        if (v == null) return '';
        if (typeof v === 'object') {
            if ('value' in v && v.value != null) return String(v.value);
            try { return JSON.stringify(v); } catch (e) { return String(v); }
        }
        return String(v);
    }

    function fmtDate(v) {
        const s = safeStr(v);
        if (!s) return '';
        return s.replace('T', ' ').replace('Z', '');
    }

    function trimText(s, maxLen) {
        const t = String(s || '').replace(/\s+/g, ' ').trim();
        if (!t) return '';
        return t.length > maxLen ? (t.slice(0, maxLen - 1) + '…') : t;
    }

    function toId(r) {
        return r.msgIdx ?? r.msgId ?? r.MSG_ID ?? r.id ?? r.ID ?? '';
    }

    function targetLabel(r) {
        const type = (r.targetTypeCd || r.TARGET_TYPE_CD || '').toString();
        const cnt  = Number(r.targetCnt ?? r.TARGET_CNT ?? 0) || 0;
        return type ? (htmlEscape(type) + (cnt ? ' (' + cnt + ')' : '')) : '';
    }

    function statusLabel(r) {
        const s = (r.statusCd || r.STATUS_CD || '').toString();
        return htmlEscape(s);
    }

    function successFail(r) {
        const ok = Number(r.successCnt ?? r.SUCCESS_CNT ?? 0) || 0;
        const ng = Number(r.failCnt ?? r.FAIL_CNT ?? 0) || 0;
        return ok + ' / ' + ng;
    }

    function scheduleWindow(r) {
        const sch  = fmtDate(r.scheduleDt ?? r.SCHEDULE_DT);
        const sBeg = fmtDate(r.sendStartDt ?? r.SEND_START_DT);
        const sEnd = fmtDate(r.sendEndDt ?? r.SEND_END_DT);
        const a = [];
        if (sch)  a.push('예약: ' + htmlEscape(sch));
        if (sBeg || sEnd) a.push('발송: ' + htmlEscape((sBeg || '') + (sEnd ? ' ~ ' + sEnd : '')));
        return a.join('<br>');
    }

    function createdAt(r) {
        return fmtDate(r.createdDt ?? r.createDate ?? r.CREATED_DT ?? r.CREATE_DATE);
    }

    function bodyLabel(r) {
        // 다양한 키 대응: BODY_TXT / bodyTxt / BODY / BODY_TEXT 등
        const raw =
            r.bodyTxt ?? r.BODY_TXT ??
            r.body ?? r.BODY ??
            r.bodyText ?? r.BODY_TEXT ?? '';
        return htmlEscape(trimText(raw, 100)); // 100자 이내로 표시
    }

    // ───────────────────────── list ─────────────────────────
    function selectPushList() {
        $.ajax({
            url: API_BASE + '/selectPushList',
            type: 'post',
            contentType: 'application/json',
            data: JSON.stringify({}),
            success: function (map) {
                const resultList = (map && map.result) ? map.result : [];
                var html = '';

                if (!resultList.length) {
                    html += "<tr><td colspan='8' class='text-center text-muted'>등록된 데이터가 없습니다.</td></tr>";
                } else {
                    for (var i = 0; i < resultList.length; i++) {
                        var r = resultList[i];
                        var id = toId(r);
                        var title = htmlEscape(r.title ?? r.TITLE ?? '(제목 없음)');

                        html += "<tr onclick=\"goToPushModify('" + id + "')\" style='cursor:pointer;'>";
                        html += "  <td class='text-right'>" + id + "</td>";
                        html += "  <td>" + title + "</td>";
                        html += "  <td class='text-muted'>" + bodyLabel(r) + "</td>"; // ★ 내용 셀
                        html += "  <td>" + targetLabel(r) + "</td>";
                        html += "  <td>" + statusLabel(r) + "</td>";
                        html += "  <td>" + successFail(r) + "</td>";
                        html += "  <td>" + scheduleWindow(r) + "</td>";
                        html += "  <td>" + htmlEscape(createdAt(r)) + "</td>";
                        html += "</tr>";
                    }
                }

                $('#pushListBody').html(html);
            },
            error: function () {
                alert('목록 조회 중 오류 발생');
            }
        });
    }

    // ───────────────────────── nav ─────────────────────────
    function goToPushModify(id) {
        var url = '/adm/psh/push/pushModify';
        if (id) url += '?msgIdx=' + encodeURIComponent(id);
        location.href = url;
    }

    function goToPush() {
        location.href = '/adm/psh/push/push';
    }
</script>
