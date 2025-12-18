<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<section>
    <div class="d-flex align-items-center justify-content-between mb-3">
        <h2 class="mb-0">채팅방</h2>
        <button type="button" class="btn btn-outline-secondary btn-sm" onclick="selectChatRoomList()">새로고침</button>
    </div>

    <!-- 빠른 방 생성 -->
    <div class="mb-3" style="max-width: 640px;">
        <div class="input-group">
            <input
                type="search"
                id="roomNmInput"
                class="form-control"
                placeholder="채팅방 이름 입력 후 Enter"
                aria-label="채팅방 이름 입력"
            />
            <button class="btn btn-primary" type="button" id="btnAddRoom">추가</button>
        </div>
    </div>

    <div class="table-responsive">
        <table class="table table-hover align-middle mb-0">
            <thead class="thead-light">
                <tr>
                    <th style="width: 90px; text-align:right;">번호</th>
                    <th>채팅방</th>
                    <th style="width: 260px;">마지막 메시지</th>
                    <th style="width: 180px;">마지막 시각</th>
                    <th style="width: 90px; text-align:center;">관리</th>
                </tr>
            </thead>
            <tbody id="chatRoomListBody"></tbody>
        </table>
    </div>
</section>

<!-- jQuery (레이아웃에서 안 넣었을 대비) -->
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>

<script>
    // ▼ JavaGen 치환 포인트 유지 (값만 현재 스키마에 맞게 수정)
    const API_BASE = '/api/cht/chatRoom';
    const roomId = 'roomId';   // TB_CHAT_ROOM.ROOM_ID → Camel: roomId

    (function () {
        bindHandlers();
        selectChatRoomList();
    })();

    function bindHandlers() {
        const input = document.getElementById('roomNmInput');
        const btnAdd = document.getElementById('btnAddRoom');

        input.addEventListener('keydown', function (e) {
            if (e.key === 'Enter') {
                const nm = (input.value || '').trim();
                if (nm) insertRoom(nm);
            }
        });

        btnAdd.addEventListener('click', function () {
            const nm = (input.value || '').trim();
            if (nm) insertRoom(nm);
        });
    }

    function selectChatRoomList() {
    	
        const payload = {
            roomType: "ai",
        };

        $.ajax({
            url: API_BASE + '/selectChatRoomList',
            type: 'post',
            contentType: 'application/json',
            dataType: 'json',
            data: JSON.stringify(payload),   // ownerId는 서버에서 세션 기반 세팅
            success: function (map) {
                const list = map && map.result ? map.result : [];
                renderChatRoomRows(list);
            },
            error: function () {
                alert('채팅방 목록 조회 중 오류가 발생했습니다.');
            }
        });
    }

    function insertRoom(roomNm) {
        const payload = {
            roomNm: roomNm,
            roomType: "ai",
            // 필요하면 grpCd 추가: grpCd: 'personal'
        };

        $.ajax({
            url: API_BASE + '/insertChatRoom',
            type: 'post',
            contentType: 'application/json',
            dataType: 'json',
            data: JSON.stringify(payload),
            success: function () {
                document.getElementById('roomNmInput').value = '';
                // 일단은 리스트 다시 로드 (바로 채팅 들어가려면 새 방 클릭)
                selectChatRoomList();
            },
            error: function (xhr) {
                alert('채팅방 등록 실패: ' + (xhr.responseText || xhr.status));
            }
        });
    }

    function deleteRoom(id) {
        if (!id) return;
        if (!confirm('해당 채팅방을 삭제하시겠습니까?')) return;

        const sendData = {};
        sendData[roomId] = id;

        $.ajax({
            url: API_BASE + '/deleteChatRoom',
            type: 'post',
            contentType: 'application/json',
            dataType: 'json',
            data: JSON.stringify(sendData),
            success: function () {
                selectChatRoomList();
            },
            error: function (xhr) {
                alert('삭제 실패: ' + (xhr.responseText || xhr.status));
            }
        });
    }

    // ✅ 채팅방 행 클릭 시 → 해당 roomId의 메시지 목록 화면으로 이동
    function goToChatRoomModify(id) {
        let url = '/cht/chatMessage/chatAiMessageList';
        if (id) {
            url += '?roomId=' + encodeURIComponent(id);
        }
        location.href = url;
    }

    function renderChatRoomRows(list) {
        let html = '';

        if (!list.length) {
            html += "<tr><td colspan='5' class='text-center text-muted py-4'>등록된 채팅방이 없습니다.</td></tr>";
        } else {
            for (let i = 0; i < list.length; i++) {
                const r = list[i] || {};
                const id = r.roomId;
                const nm = r.roomNm || '';
                const lastMsg = r.lastMsgContent || '';
                let lastDt = r.lastMsgSentDt || r.updatedDt || r.createdDt || '';

                if (lastDt && typeof lastDt === 'object') {
                    lastDt = lastDt.value || String(lastDt);
                }

                html += "<tr onclick=\"goToChatRoomModify('" + (id) + "')\">";
                html += "  <td class='text-right'>" + (id ?? '') + "</td>";
                html += "  <td>" + escapeHtml(nm) + "</td>";
                html += "  <td title='" + escapeHtml(lastMsg) + "'>"
                      +      (escapeHtml(truncate(lastMsg, 40))) + "</td>";
                html += "  <td>" + escapeHtml(lastDt) + "</td>";
                html += "  <td class='text-center'>";
                html += "    <button type='button' class='btn btn-outline-danger btn-sm'";
                html += "            aria-label='채팅방 " + (id ?? '') + " 삭제'";
                html += "            onclick=\"event.stopPropagation(); deleteRoom('" + (id) + "')\">삭제</button>";
                html += "  </td>";
                html += "</tr>";
            }
        }

        $('#chatRoomListBody').html(html);
    }

    function truncate(s, max) {
        s = String(s || '');
        if (s.length <= max) return s;
        return s.substring(0, max - 1) + '…';
    }

    function escapeHtml(s) {
        return String(s || '').replace(/[&<>"']/g, function (m) {
            return { '&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;' }[m];
        });
    }
</script>
