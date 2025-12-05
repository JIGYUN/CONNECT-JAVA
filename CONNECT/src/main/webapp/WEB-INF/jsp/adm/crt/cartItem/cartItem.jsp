<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<section>
    <h2 class="mb-3">장바구니 상세</h2>

    <div class="mb-3">
        <a class="btn btn-outline-secondary" href="/crt/cartItem/cartItemList">목록</a>
    </div>

    <div class="mb-3" style="max-width: 640px;">
        <input
            type="search"
            id="titleInput"
            class="form-control"
            placeholder="제목 입력 후 Enter"
            aria-label="제목 입력"
        />
    </div>

    <div class="table-responsive">
        <table class="table table-hover align-middle">
            <thead class="thead-light">
                <tr>
                    <th style="width: 90px; text-align:right;">번호</th>
                    <th>제목</th>
                    <th style="width: 220px;">작성일</th>
                    <th style="width: 90px; text-align:center;">관리</th>
                </tr>
            </thead>
            <tbody id="cartItemListBody"></tbody>
        </table>
    </div>
</section>

<script>
    // ▼ JavaGen 치환 포인트 유지
    const API_BASE = '/api/crt/cartItem';
    const cartItemId = 'cartItemIdx';

    (function () {
        selectCartItemList();

        const input = document.getElementById('titleInput');
        input.addEventListener('keydown', function (e) {
            if (e.key === 'Enter') {
                const title = (input.value || '').trim();
                if (title) insertTitle(title);
            }
        });
    })();

    function selectCartItemList() {
        $.ajax({
            url: API_BASE + '/selectCartItemList',
            type: 'post',
            contentType: 'application/json',
            data: JSON.stringify({}),
            success: function (map) {
                const resultList = map.result || [];
                let html = '';

                if (!resultList.length) {
                    html += "<tr><td colspan='4' class='text-center text-muted'>등록된 데이터가 없습니다.</td></tr>";
                } else {
                    for (let i = 0; i < resultList.length; i++) {
                        const r = resultList[i];
                        let createDate = r.createDate;
                        if (createDate && typeof createDate === 'object') {
                            createDate = (createDate.value || String(createDate));
                        }

                        html += "<tr onclick=\"goToCartItemModify('" + (r.cartItemIdx) + "')\">";
                        html += "  <td class='text-right'>" + (r.cartItemIdx ?? '') + "</td>";
                        html += "  <td>" + (escapeHtml(r.title ?? '')) + "</td>";
                        html += "  <td>" + (escapeHtml(createDate ?? '')) + "</td>";
                        html += "  <td class='text-center'>";
                        html += "    <button type='button' class='btn btn-outline-danger btn-sm'";
                        html += "            aria-label='항목 " + (r.cartItemIdx ?? '') + " 삭제'";
                        html += "            onclick=\"event.stopPropagation(); deleteRow('" + (r.cartItemIdx) + "')\">삭제</button>";
                        html += "  </td>";
                        html += "</tr>";
                    }
                }

                $('#cartItemListBody').html(html);
            },
            error: function () {
                alert('목록 조회 중 오류 발생');
            }
        });
    }

    function insertTitle(title) {
        const payload = { title: title };

        $.ajax({
            url: API_BASE + '/insertCartItem',
            type: 'post',
            contentType: 'application/json',
            dataType: 'json',
            data: JSON.stringify(payload),
            success: function () {
                document.getElementById('titleInput').value = '';
                selectCartItemList();
            },
            error: function (xhr) {
                alert('등록 실패: ' + (xhr.responseText || xhr.status));
            }
        });
    }

    function deleteRow(id) {
        if (!id) return;

        const sendData = {};
        sendData[cartItemId] = id;

        $.ajax({
            url: API_BASE + '/deleteCartItem',
            type: 'post',
            contentType: 'application/json',
            dataType: 'json',
            data: JSON.stringify(sendData),
            success: function () {
                selectCartItemList();
            },
            error: function (xhr) {
                alert('삭제 실패: ' + (xhr.responseText || xhr.status));
            }
        });
    }

    function goToCartItemModify(id) {
        let url = '/crt/cartItem/cartItemModify';
        if (id) url += '?' + cartItemId + '=' + encodeURIComponent(id);
        location.href = url;
    }

    function escapeHtml(s) {
        return String(s).replace(/[&<>"']/g, function (m) {
            return { '&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;' }[m];
        });
    }

    function goToCartItemList() {
        location.href = '/crt/cartItem/cartItemList';
    }
</script>
