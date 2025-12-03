<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://www.springframework.org/security/tags" prefix="sec" %>

<sec:authentication property="principal.userId" var="authUserId" />
<sec:authentication property="principal.email" var="authEmail" />

<section>
    <!-- 로그인 사용자 정보 (읽기 전용) -->
    <div id="authInfo"
         data-sender-id="${authUserId}"
         data-sender-nm="${authEmail}">
    </div>

    <div class="d-flex align-items-center justify-content-between mb-3">
        <div>
            <h2 class="mb-0">메시지 (AI 자동번역)</h2>
            <small class="text-muted d-block">
                roomId:
                <span id="roomIdLabel"><c:out value="${param.roomId}" /></span>
            </small>
            <small class="text-muted d-block mt-1">
                로그인: <c:out value="${authEmail}" /> (ID: <c:out value="${authUserId}" />)
            </small>
        </div>
        <a class="btn btn-outline-secondary btn-sm" href="/cht/chatRoom/chatRoomList">채팅방 목록</a>
    </div>

    <!-- roomId 이동 컨트롤 -->
    <div class="mb-3" style="max-width: 420px;">
        <div class="input-group">
            <span class="input-group-text">roomId</span>
            <input
                type="number"
                id="roomIdInput"
                class="form-control"
                value="<c:out value='${param.roomId}'/>"
                aria-label="roomId"
            />
            <button class="btn btn-outline-primary" type="button" id="btnChangeRoom">이동</button>
        </div>
        <small class="text-muted">방 번호 변경 후 [이동]을 누르면 해당 roomId로 다시 조회합니다.</small>
    </div>

    <!-- senderId / senderNm + 대상 언어 선택 -->
    <div class="mb-3" style="max-width: 640px;">
        <div class="row g-2">
            <div class="col-12 col-md-4">
                <div class="form-group mb-0">
                    <label class="form-label mb-0">senderId</label>
                    <div class="form-control-plaintext fw-semibold">
                        <c:out value="${authUserId}" />
                    </div>
                </div>
            </div>
            <div class="col-12 col-md-8">
                <div class="form-group mb-0">
                    <label class="form-label mb-0">senderNm (email)</label>
                    <div class="form-control-plaintext fw-semibold">
                        <c:out value="${authEmail}" />
                    </div>
                </div>
            </div>
        </div>

        <!-- 대상 언어 선택 영역 (엔진은 QWEN 고정) -->
        <div class="row g-2 mt-2">
            <div class="col-12 col-md-6">
                <div class="form-group mb-0">
                    <label for="targetLangSelect" class="form-label mb-1">대상 언어</label>
                    <select id="targetLangSelect" class="form-control form-control-sm">
                        <option value="ko">한국어 (ko)</option>
                        <option value="en">영어 (en)</option>
                        <option value="ja">일본어 (ja)</option>
                        <option value="zh-CN">중국어 간체 (zh-CN)</option>
                    </select>
                    <small class="text-muted">
                        메시지 전송 시 번역될 언어를 선택합니다. 엔진은 Qwen으로 고정됩니다.
                    </small>
                </div>
            </div>
        </div>

        <small class="text-muted d-block mt-2">
            서버에서는 sec:authentication을 통해 userId / email을 사용하고,<br />
            React 모바일에서도 동일 키(senderId, senderNm)를 JSON payload에 넣어 전송합니다.
        </small>
    </div>

    <!-- 카카오톡 스타일 레이아웃 -->
    <div class="chat-wrap panel-elev">
        <!-- 메시지 영역 -->
        <div id="chatScroll" class="chat-body">
            <ul id="chatMessageListBody" class="chat-list"></ul>
        </div>

        <!-- 입력 영역 -->
        <div class="chat-input">
            <input
                type="text"
                id="msgInput"
                class="form-control"
                placeholder="메시지 입력 후 Enter"
                aria-label="메시지 내용 입력"
            />
            <button class="btn btn-primary" type="button" id="btnSendMsg">보내기</button>
        </div>
    </div>
</section>

<!-- jQuery -->
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<!-- SockJS + STOMP -->
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
        max-height: calc(100vh - 220px);
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

    /* 번역 결과 */
    .chat-translation {
        font-size: 11px;
        color: var(--chat-muted);
        margin-top: 2px;
    }
</style>

<script>
    const API_BASE = '/api/cht/chatMessage';
    const msgIdKey = 'msgId';

    let stompClient = null;
    let stompConnected = false;

    // 기본 번역 옵션
    const DEFAULT_TARGET_LANG = 'ko'; // 대상 언어 기본값
    // 엔진은 QWEN 고정
    const FIXED_ENGINE = 'QWEN';

    // 현재 선택된 대상 언어
    let currentTargetLang = DEFAULT_TARGET_LANG;

    (function () {
        initAuthInfo();
        initRoomIdFromParam();
        joinChatRoomUserOnEnter();
        bindHandlers();
        initTargetLangSelect();     // ★ 대상 언어 선택 초기화
        selectChatMessageList();    // 과거 기록 (번역 필드는 없으면 안 나옴)
        connectStomp();
    })();

    function initAuthInfo() {
        const authEl = document.getElementById('authInfo');
        if (!authEl) {
            return;
        }

        const senderId = authEl.getAttribute('data-sender-id');
        const senderNm = authEl.getAttribute('data-sender-nm') || '';

        if (senderId) {
            sessionStorage.setItem('senderId', senderId);
        }
        if (senderNm) {
            sessionStorage.setItem('senderNm', senderNm);
        }
    }

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
        } else {
            const sp = new URLSearchParams(location.search);
            const qRoom = sp.get('roomId');
            if (qRoom) {
                input.value = qRoom;
                document.getElementById('roomIdLabel').textContent = qRoom;
            }
        }
    }

    // 대상 언어 선택 초기화
    function initTargetLangSelect() {
        const el = document.getElementById('targetLangSelect');
        if (!el) return;

        // 초기값 세팅
        el.value = DEFAULT_TARGET_LANG;
        currentTargetLang = el.value || DEFAULT_TARGET_LANG;

        el.addEventListener('change', function () {
            const val = el.value;
            if (val === 'ko' || val === 'en' || val === 'ja' || val === 'zh-CN') {
                currentTargetLang = val;
            } else {
                currentTargetLang = DEFAULT_TARGET_LANG;
            }
        });
    }

    // 채팅방 입장 시 TB_CHAT_ROOM_USER에 upsert
    function joinChatRoomUserOnEnter() {
        const roomIdVal = currentRoomId();
        const senderIdNum = getAuthSenderId();

        if (roomIdVal === null || senderIdNum === null) {
            return;
        }

        const payload = {
            roomId: roomIdVal
            // userId 는 서버에서 UserSessionManager 로 세팅
        };

        $.ajax({
            url: '/api/cht/chatRoomUser/joinRoom',
            type: 'post',
            contentType: 'application/json',
            dataType: 'json',
            data: JSON.stringify(payload),
            success: function () {},
            error: function (xhr) {
                console.error('채팅방 입장 처리 실패', xhr);
            }
        });
    }

    function bindHandlers() {
        const roomInput = document.getElementById('roomIdInput');
        const msgInput = document.getElementById('msgInput');
        const btnSend = document.getElementById('btnSendMsg');
        const btnChangeRoom = document.getElementById('btnChangeRoom');

        btnChangeRoom.addEventListener('click', function () {
            const v = roomInput.value;
            if (!v) {
                alert('roomId를 입력해 주세요.');
                return;
            }
            const n = Number(v);
            if (Number.isNaN(n)) {
                alert('roomId는 숫자만 가능합니다.');
                return;
            }
            // 이 JSP에 대응하는 URL로 맞춰서 수정
            location.href = '/cht/chatMessage/chatMessageAiList?roomId=' + encodeURIComponent(n);
        });

        roomInput.addEventListener('keydown', function (e) {
            if (e.key === 'Enter') {
                selectChatMessageList();
            }
        });

        msgInput.addEventListener('keydown', function (e) {
            if (e.key === 'Enter') {
                sendMessage();
            }
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

    /* ---------- STOMP 연결 & 구독 ---------- */

    function connectStomp() {
        const roomIdVal = currentRoomId();
        if (roomIdVal === null) {
            return;
        }

        const socket = new SockJS('/ws-stomp');
        stompClient = Stomp.over(socket);
        // stompClient.debug = null;

        stompClient.connect({}, function () {
            stompConnected = true;
            subscribeRoom(roomIdVal); // AI 파이프라인 전용
        }, function (error) {
            console.error('STOMP 연결 실패:', error);
            stompConnected = false;
        });
    }

    function subscribeRoom(roomIdVal) {
        if (!stompClient || !stompConnected) return;

        // ✅ AI 파이프라인 채널
        stompClient.subscribe('/topic/chat-ai/' + roomIdVal, function (frame) {
            try {
                const body = JSON.parse(frame.body);
                appendOneMessage(body);
                scrollToBottom();
            } catch (e) {
                console.error('메시지 파싱 오류:', e, frame.body);
            }
        });
    }

    /* ---------- REST로 기존 메시지 조회 ---------- */

    function selectChatMessageList() {
        const roomIdVal = currentRoomId();
        const payload = {};

        if (roomIdVal !== null) {
            payload.roomId = roomIdVal;
        }
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

    /* ---------- 메시지 전송 (STOMP) ---------- */

    function sendMessage() {
        const roomIdVal = currentRoomId();
        const msgInput = document.getElementById('msgInput');
        const content = (msgInput.value || '').trim();

        if (roomIdVal === null) {
            alert('roomId를 먼저 입력해 주세요.');
            return;
        }
        if (!content) {
            alert('메시지 내용을 입력해 주세요.');
            return;
        }

        const senderIdNum = getAuthSenderId();
        const senderNmVal = getAuthSenderNm().trim();

        if (senderIdNum === null) {
            alert('로그인 정보(senderId)를 확인할 수 없습니다. 다시 로그인 후 이용해 주세요.');
            return;
        }
        if (!senderNmVal) {
            alert('로그인 정보(senderNm)를 확인할 수 없습니다. 다시 로그인 후 이용해 주세요.');
            return;
        }

        const payload = {
            roomId: roomIdVal,
            senderId: senderIdNum,
            senderNm: senderNmVal,
            content: content,
            contentType: 'TEXT',
            // AI 번역 옵션
            targetLang: currentTargetLang,
            engine: FIXED_ENGINE
        };

        if (!stompClient || !stompConnected) {
            alert('WebSocket 연결이 아직 준비되지 않았습니다.');
            return;
        }

        // ✅ AI 파이프라인 엔드포인트
        stompClient.send('/app/chat-ai/' + roomIdVal, {}, JSON.stringify(payload));

        msgInput.value = '';
        msgInput.focus();
    }

    /* ---------- 렌더링 ---------- */

    function renderMessageRows(list) {
        let html = '';

        if (!list.length) {
            html += "<li class='text-center text-muted py-4'>등록된 메시지가 없습니다.</li>";
        } else {
            for (let i = 0; i < list.length; i++) {
                const r = list[i] || {};
                html += buildMessageItemHtml(r);
            }
        }

        $('#chatMessageListBody').html(html);
    }

    function appendOneMessage(r) {
        const ul = document.getElementById('chatMessageListBody');
        if (!ul) return;
        const li = document.createElement('li');
        li.className = getMessageItemClass(r);
        const msgId = r && r[msgIdKey];
        if (msgId !== null && msgId !== undefined) {
            li.setAttribute('data-msg-id', String(msgId));
        }
        li.innerHTML = buildMessageInnerHtml(r);
        ul.appendChild(li);
    }

    function buildMessageItemHtml(r) {
        const inner = buildMessageInnerHtml(r);
        const cls = getMessageItemClass(r);
        const msgId = r && r[msgIdKey];
        const dataAttr = (msgId !== null && msgId !== undefined)
            ? " data-msg-id='" + String(msgId) + "'"
            : '';
        return "<li class='" + cls + "'" + dataAttr + ">" + inner + "</li>";
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

        const translatedText = r.translatedText || '';
        const translateErrorMsg = r.translateErrorMsg || '';
        const engineUsed = r.engine || '';
        const targetLangUsed = r.targetLang || '';

        const safeSender = escapeHtml(senderNm || '익명');
        const safeDt = escapeHtml(sentDt || '');
        const safeContent = escapeHtml(content);
        const msgIdStr = (id !== null && id !== undefined) ? String(id) : '';

        let html = '';

        // 상단 메타
        html += "<div class='chat-meta'>";
        html += safeSender;
        if (safeDt) {
            html += " · " + safeDt;
        }
        if (engineUsed) {
            html += " · 엔진: " + escapeHtml(engineUsed);
        }
        if (targetLangUsed) {
            html += " · target: " + escapeHtml(targetLangUsed);
        }
        html += "</div>";

        // 본문 (원문)
        html += "<div class='chat-bubble' title='ID: " + (msgIdStr || '') + "'>" + safeContent + "</div>";

        // 번역 결과
        if (translatedText) {
            html += "<div class='chat-translation'>" + escapeHtml(translatedText) + "</div>";
        } else if (translateErrorMsg) {
            html += "<div class='chat-translation'>번역 실패: " + escapeHtml(translateErrorMsg) + "</div>";
        }

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
