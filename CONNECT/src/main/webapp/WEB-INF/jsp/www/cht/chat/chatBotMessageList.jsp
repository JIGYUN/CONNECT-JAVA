<%-- filepath: src/main/webapp/WEB-INF/jsp/cht/chatMessage/chatBotMessageList.jsp --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://www.springframework.org/security/tags" prefix="sec" %>

<sec:authentication property="principal.userId" var="authUserId" />
<sec:authentication property="principal.email" var="authEmail" />

<section>
    <div id="authInfo"
         data-sender-id="${authUserId}"
         data-sender-nm="${authEmail}">
    </div>

    <div class="d-flex align-items-center justify-content-between mb-3">
        <div>
            <h2 class="mb-0">법률 챗봇</h2>
            <small class="text-muted d-block">
                roomId:
                <span id="roomIdLabel"><c:out value="${param.roomId}" /></span>
            </small>
            <small class="text-muted d-block mt-1">
                로그인: <c:out value="${authEmail}" /> (ID: <c:out value="${authUserId}" />)
            </small>
            <small class="text-muted d-block mt-1">
                모드: <span id="variantLabel" class="fw-semibold">CHAT_GRAPH_STREAM</span>
            </small>
        </div>
        <a class="btn btn-outline-secondary btn-sm" href="/cht/chatRoom/chatRoomList">채팅방 목록</a>
    </div>

    <div class="mb-3" style="max-width: 520px;">
        <div class="input-group">
            <span class="input-group-text">roomId</span>
            <input type="number" id="roomIdInput" class="form-control" value="<c:out value='${param.roomId}'/>" />
            <button class="btn btn-outline-primary" type="button" id="btnChangeRoom">이동</button>
        </div>
        <small class="text-muted">
            방 번호 변경 후 [이동]을 누르면 해당 roomId로 다시 조회합니다. (대화 기록은 roomId로 분리)
        </small>
    </div>

    <div class="mb-3" style="max-width: 520px;">
        <div class="row g-2 align-items-end">
            <div class="col-12 col-md-8">
                <label class="form-label mb-0">봇 버전 선택 (FastAPI)</label>
                <select id="botVariantSelect" class="form-control form-control-sm">
                    <option value="CHAT">CHAT (sync)</option>
                    <option value="CHAT_STREAM">CHAT_STREAM (SSE)</option>
                    <option value="CHAT_GRAPH">CHAT_GRAPH (sync)</option>
                    <option value="CHAT_GRAPH_STREAM" selected>CHAT_GRAPH_STREAM (SSE)</option>
                </select>
                <small class="text-muted d-block mt-1">
                    메시지 전송 시점의 선택값이 payload.botVariant로 서버에 전달됩니다.
                </small>
            </div>
            <div class="col-12 col-md-4">
                <label class="form-label mb-0">topK</label>
                <input id="topKInput" type="number" class="form-control form-control-sm" value="5" min="1" max="30" />
            </div>
        </div>
    </div>

    <div class="mb-3" style="max-width: 640px;">
        <div class="row g-2">
            <div class="col-12 col-md-4">
                <label class="form-label mb-0">내 ID (senderId)</label>
                <div class="form-control-plaintext fw-semibold"><c:out value="${authUserId}" /></div>
            </div>
            <div class="col-12 col-md-8">
                <label class="form-label mb-0">내 이메일 (senderNm)</label>
                <div class="form-control-plaintext fw-semibold"><c:out value="${authEmail}" /></div>
            </div>
        </div>
        <small class="text-muted">
            이 페이지는 “OpenAI(FastAPI) 챗봇” 전용입니다. (Qwen은 번역 모듈에서만 사용)
        </small>
    </div>

    <div class="chat-wrap panel-elev">
        <div id="chatScroll" class="chat-body">
            <ul id="chatMessageListBody" class="chat-list"></ul>
        </div>

        <div class="chat-input">
            <input type="text" id="msgInput" class="form-control" placeholder="질문을 입력 후 Enter" />
            <button class="btn btn-primary" type="button" id="btnSendMsg">보내기</button>
        </div>
    </div>
</section>

<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/sockjs-client@1.6.1/dist/sockjs.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/stompjs@2.3.3/lib/stomp.min.js"></script>

<style>
    :root {
        --chat-bg: #f4f5f7;
        --chat-card: #ffffff;
        --chat-line: #e2e8f0;
        --chat-mine: #d1e8ff;
        --chat-other: #f3f4f6;
        --chat-text: #111827;
        --chat-muted: #6b7280;
    }

    .panel-elev {
        background: var(--chat-card);
        border-radius: 18px;
        border: 1px solid var(--chat-line);
        box-shadow: 0 8px 20px rgba(15, 23, 42, 0.08);
        padding: 12px;
    }

    .chat-wrap {
        display: flex;
        flex-direction: column;
        height: 540px;
        max-height: calc(100vh - 260px);
        background: var(--chat-bg);
    }

    .chat-body {
        flex: 1;
        overflow-y: auto;
        padding: 12px;
    }

    .chat-list {
        list-style: none;
        margin: 0;
        padding: 0;
    }

    .chat-item {
        margin-bottom: 10px;
        display: flex;
        flex-direction: column;
        max-width: 80%;
    }

    .chat-meta {
        font-size: 11px;
        color: var(--chat-muted);
        margin-bottom: 2px;
    }

    .chat-bubble {
        display: inline-block;
        padding: 8px 12px;
        border-radius: 18px;
        background: var(--chat-other);
        color: var(--chat-text);
        word-break: break-word;
        white-space: pre-wrap;
    }

    .chat-item.me {
        margin-left: auto;
        align-items: flex-end;
    }

    .chat-item.me .chat-bubble {
        background: var(--chat-mine);
    }

    .chat-badge {
        display: inline-flex;
        align-items: center;
        gap: 6px;
        margin-left: 6px;
        font-size: 10px;
        padding: 2px 8px;
        border-radius: 999px;
        border: 1px solid var(--chat-line);
        background: #fff;
        color: var(--chat-muted);
        vertical-align: middle;
    }

    .chat-input {
        display: flex;
        align-items: center;
        gap: 8px;
        padding: 8px 8px 4px;
        border-top: 1px solid var(--chat-line);
        background: var(--chat-card);
    }

    .chat-input .form-control {
        border-radius: 999px;
    }

    .chat-input .btn {
        border-radius: 999px;
        white-space: nowrap;
    }
</style>

<script>
    const API_BASE = '/api/cht/chatMessage';
    const msgIdKey = 'msgId';
    const BOT_VARIANT_KEY = 'chatBotVariant';

    // ✅ 빈 상태 row id 고정
    const EMPTY_ROW_ID = 'chat-empty-row';

    let stompClient = null;
    let stompConnected = false;

    (function () {
        initRoomIdFromParam();
        initBotVariantUi();
        bindHandlers();
        selectChatMessageList();
        connectStomp();
    })();

    function getAuthSenderId() {
        const authEl = document.getElementById('authInfo');
        if (!authEl) return null;
        const raw = authEl.getAttribute('data-sender-id');
        if (!raw) return null;
        const n = Number(raw);
        return Number.isNaN(n) ? null : n;
    }

    function getAuthSenderNm() {
        const authEl = document.getElementById('authInfo');
        if (!authEl) return '';
        return authEl.getAttribute('data-sender-nm') || '';
    }

    function initRoomIdFromParam() {
        const paramVal = '<c:out value="${param.roomId}" />';
        const input = document.getElementById('roomIdInput');

        if (paramVal && paramVal !== '' && paramVal !== 'null') {
            input.value = paramVal;
            document.getElementById('roomIdLabel').textContent = paramVal;
            return;
        }

        input.value = '1';
        document.getElementById('roomIdLabel').textContent = '1';
    }

    function initBotVariantUi() {
        const sel = document.getElementById('botVariantSelect');
        const label = document.getElementById('variantLabel');
        if (!sel || !label) return;

        const saved = localStorage.getItem(BOT_VARIANT_KEY);
        if (saved) sel.value = saved;

        label.textContent = sel.value || 'CHAT_GRAPH_STREAM';

        sel.addEventListener('change', function () {
            const v = sel.value || 'CHAT_GRAPH_STREAM';
            localStorage.setItem(BOT_VARIANT_KEY, v);
            label.textContent = v;
        });
    }

    function bindHandlers() {
        const roomInput = document.getElementById('roomIdInput');
        const msgInput = document.getElementById('msgInput');
        const btnSend = document.getElementById('btnSendMsg');
        const btnChangeRoom = document.getElementById('btnChangeRoom');

        btnChangeRoom.addEventListener('click', function () {
            const v = roomInput.value;
            if (!v) return alert('roomId를 입력해 주세요.');
            const n = Number(v);
            if (Number.isNaN(n)) return alert('roomId는 숫자만 가능합니다.');
            location.href = '/cht/chatMessage/chatBotMessageList?roomId=' + encodeURIComponent(n);
        });

        msgInput.addEventListener('keydown', function (e) {
            if (e.key === 'Enter') sendMessage();
        });

        btnSend.addEventListener('click', function () {
            sendMessage();
        });
    }

    function currentRoomId() {
        const v = document.getElementById('roomIdInput').value;
        if (v === null || v === '') return null;
        const n = Number(v);
        return Number.isNaN(n) ? null : n;
    }

    function connectStomp() {
        const roomIdVal = currentRoomId();
        if (roomIdVal === null) return;

        const socket = new SockJS('/ws-stomp');
        stompClient = Stomp.over(socket);

        stompClient.connect({}, function () {
            stompConnected = true;
            subscribeRoom(roomIdVal);
        }, function (error) {
            console.error('STOMP 연결 실패:', error);
            stompConnected = false;
        });
    }

    function subscribeRoom(roomIdVal) {
        if (!stompClient || !stompConnected) return;

        stompClient.subscribe('/topic/chat-bot/' + roomIdVal, function (frame) {
            try {
                const body = JSON.parse(frame.body);
                handleIncoming(body);
                scrollToBottom();
            } catch (e) {
                console.error('메시지 파싱 오류:', e, frame.body);
            }
        });
    }

    function selectChatMessageList() {
        const roomIdVal = currentRoomId();
        const payload = {};
        if (roomIdVal !== null) payload.roomId = roomIdVal;
        payload.limit = 50;

        $.ajax({
            url: API_BASE + '/selectChatMessageList',
            type: 'post',
            contentType: 'application/json',
            dataType: 'json',
            data: JSON.stringify(payload),
            success: function (map) {
                const list = map && map.result ? map.result : [];
                renderMessageRows(list);
                scrollToBottom();
            },
            error: function () {
                alert('메시지 목록 조회 중 오류가 발생했습니다.');
            }
        });
    }

    function sendMessage() {
        const roomIdVal = currentRoomId();
        const msgInput = document.getElementById('msgInput');
        const content = (msgInput.value || '').trim();

        if (roomIdVal === null) return alert('roomId를 먼저 입력해 주세요.');
        if (!content) return alert('메시지 내용을 입력해 주세요.');

        const senderIdNum = getAuthSenderId();
        const senderNmVal = getAuthSenderNm().trim();

        if (senderIdNum === null) return alert('로그인 정보(senderId)를 확인할 수 없습니다.');
        if (!senderNmVal) return alert('로그인 정보(senderNm)를 확인할 수 없습니다.');

        const botVariant = (document.getElementById('botVariantSelect').value || 'CHAT_GRAPH_STREAM').trim();
        const topKVal = Number(document.getElementById('topKInput').value || '5');
        const topK = (Number.isNaN(topKVal) || topKVal < 1) ? 5 : topKVal;

        const payload = {
            roomId: roomIdVal,
            senderId: senderIdNum,
            senderNm: senderNmVal,
            content: content,
            contentType: 'TEXT',
            botVariant: botVariant,
            topK: topK
        };

        if (!stompClient || !stompConnected) return alert('WebSocket 연결이 아직 준비되지 않았습니다.');

        // ✅ 보내기 직전에 빈 상태 제거(UX)
        clearEmptyStateRow();

        stompClient.send('/app/chat-bot/' + roomIdVal, {}, JSON.stringify(payload));
        msgInput.value = '';
        msgInput.focus();
    }

    function handleIncoming(r) {
        const aiEvent = (r && r.aiEvent) ? String(r.aiEvent) : '';
        if (!aiEvent) {
            appendOneMessage(r);
            return;
        }

        const aiMsgId = (r && r.aiMsgId) ? String(r.aiMsgId) : '';
        if (!aiMsgId) {
            appendOneMessage(r);
            return;
        }

        if (aiEvent === 'START') {
            ensureAiMessageShell(r);
            setAiMeta(aiMsgId, 'START');
            return;
        }

        if (aiEvent === 'TOKEN') {
            ensureAiMessageShell(r);
            const delta = (r && r.delta) ? String(r.delta) : '';
            appendAiDelta(aiMsgId, delta);
            return;
        }

        if (aiEvent === 'DONE') {
            ensureAiMessageShell(r);

            const content =
                (r && r.content) ? String(r.content) :
                (r && r.answer) ? String(r.answer) :
                (r && r.result && r.result.answer) ? String(r.result.answer) :
                '';

            setAiFullContent(aiMsgId, content);
            setAiMeta(aiMsgId, 'DONE');
            return;
        }

        if (aiEvent === 'ERROR') {
            ensureAiMessageShell(r);
            const errorMsg = (r && r.errorMsg) ? String(r.errorMsg) : 'AI ERROR';
            setAiFullContent(aiMsgId, 'ERROR: ' + errorMsg);
            setAiMeta(aiMsgId, 'ERROR');
            return;
        }

        appendOneMessage(r);
    }

    // ✅ 핵심: 빈 상태 li 제거
    function clearEmptyStateRow() {
        const empty = document.getElementById(EMPTY_ROW_ID);
        if (empty && empty.parentNode) empty.parentNode.removeChild(empty);
    }

    function ensureAiMessageShell(r) {
        const aiMsgId = (r && r.aiMsgId) ? String(r.aiMsgId) : '';
        if (!aiMsgId) return;

        // ✅ AI 메시지가 생기는 순간 빈 상태 제거
        clearEmptyStateRow();

        const liId = 'ai-li-' + aiMsgId;
        if (document.getElementById(liId)) return;

        const ul = document.getElementById('chatMessageListBody');
        if (!ul) return;

        const botVariant = (r && r.botVariant) ? String(r.botVariant) : '';
        const badge = botVariant ? ("<span class='chat-badge'>" + escapeHtml(botVariant) + "</span>") : "";

        const li = document.createElement('li');
        li.id = liId;
        li.className = 'chat-item';

        const metaId = 'ai-meta-' + aiMsgId;
        const bubbleId = 'ai-bubble-' + aiMsgId;

        li.innerHTML =
            "<div class='chat-meta' id='" + metaId + "'>AI" + badge + "</div>" +
            "<div class='chat-bubble' id='" + bubbleId + "' title='aiMsgId: " + escapeHtml(aiMsgId) + "'></div>";

        ul.appendChild(li);
    }

    function appendAiDelta(aiMsgId, delta) {
        if (!delta) return;
        const bubble = document.getElementById('ai-bubble-' + aiMsgId);
        if (!bubble) return;
        bubble.textContent = (bubble.textContent || '') + delta;
    }

    function setAiFullContent(aiMsgId, content) {
        const bubble = document.getElementById('ai-bubble-' + aiMsgId);
        if (!bubble) return;
        bubble.textContent = content || '';
    }

    function setAiMeta(aiMsgId, stateText) {
        const meta = document.getElementById('ai-meta-' + aiMsgId);
        if (!meta) return;

        const base = meta.getAttribute('data-base');
        if (!base) {
            meta.setAttribute('data-base', meta.innerHTML);
        }

        const baseHtml = meta.getAttribute('data-base');
        meta.innerHTML = baseHtml + " · " + escapeHtml(stateText || '');
    }

    function renderMessageRows(list) {
        let html = '';

        if (!list.length) {
            // ✅ 빈 상태 row에 ID 부여
            html += "<li id='" + EMPTY_ROW_ID + "' class='text-center text-muted py-4'>등록된 메시지가 없습니다.</li>";
        } else {
            for (let i = 0; i < list.length; i++) {
                const r = list[i] || {};
                html += buildMessageItemHtml(r);
            }
        }

        $('#chatMessageListBody').html(html);
    }

    function appendOneMessage(r) {
        // ✅ 일반 메시지가 추가되는 순간에도 빈 상태 제거
        clearEmptyStateRow();

        const ul = document.getElementById('chatMessageListBody');
        if (!ul) return;

        const li = document.createElement('li');
        li.className = getMessageItemClass(r);
        li.innerHTML = buildMessageInnerHtml(r);
        ul.appendChild(li);
    }

    function buildMessageItemHtml(r) {
        const inner = buildMessageInnerHtml(r);
        const cls = getMessageItemClass(r);
        return "<li class='" + cls + "'>" + inner + "</li>";
    }

    function getMessageItemClass(r) {
        const senderId = r && r.senderId;
        const mySenderIdVal = getAuthSenderId();

        let isMe = false;
        if (mySenderIdVal !== null && senderId != null) {
            const senderNum = Number(senderId);
            if (!Number.isNaN(senderNum) && senderNum === mySenderIdVal) {
                isMe = true;
            }
        }

        return isMe ? 'chat-item me' : 'chat-item';
    }

    function buildMessageInnerHtml(r) {
        const id = r[msgIdKey];
        const senderNm = r.senderNm || '';
        const content = r.content || '';
        let sentDt = r.sentDt || '';

        if (sentDt && typeof sentDt === 'object') {
            sentDt = sentDt.value || String(sentDt);
        }

        const safeSender = escapeHtml(senderNm || '익명');
        const safeDt = escapeHtml(sentDt || '');
        const safeContent = escapeHtml(content);
        const msgIdStr = (id !== null && id !== undefined) ? String(id) : '';

        let html = '';
        html += "<div class='chat-meta'>";
        html += safeSender;
        if (safeDt) html += " · " + safeDt;
        html += "</div>";

        html += "<div class='chat-bubble' title='ID: " + escapeHtml(msgIdStr) + "'>" + safeContent + "</div>";
        return html;
    }

    function scrollToBottom() {
        const sc = document.getElementById('chatScroll');
        if (!sc) return;
        sc.scrollTop = sc.scrollHeight;
    }

    function escapeHtml(s) {
        return String(s || '').replace(/[&<>"']/g, function (m) {
            return {
                '&': '&amp;',
                '<': '&lt;',
                '>': '&gt;',
                '"': '&quot;',
                "'": '&#39;'
            }[m];
        });
    }
</script>
