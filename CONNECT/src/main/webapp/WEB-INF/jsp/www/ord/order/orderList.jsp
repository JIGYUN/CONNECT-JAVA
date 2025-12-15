<%@ page language="java" contentType="text/html; charset=UTF-8" %>

<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.2/dist/css/bootstrap.min.css"/>
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>

<!-- 공통 페이징 -->
<script src="/static/js/paging.js"></script>

<style>
    :root{
        --bg:#f6f8fb;
        --card:#ffffff;
        --line:#e9edf3;
        --text:#0f172a;
        --muted:#6b7280;
    }
    body{
        background:var(--bg);
    }
    .page-title{
        font-size:26px;
        font-weight:800;
        color:var(--text);
        margin:12px 0 14px;
    }
    .table-hover tbody tr{
        cursor:pointer;
    }
    .card-wrap{
        border-radius:16px;
        border:1px solid var(--line);
        background:var(--card);
    }
</style>

<section class="container py-4">
    <div class="d-flex justify-content-between align-items-center mb-3">
        <h2 class="page-title mb-0">주문 내역</h2>

        <div>
            <button class="btn btn-primary btn-sm" type="button" onclick="goToOrderModify()">
                주문 작성(테스트)
            </button>
            <button class="btn btn-outline-secondary btn-sm" type="button" onclick="goToOrder()">
                장바구니 주문하기
            </button>
        </div>
    </div>

    <div class="table-responsive card-wrap p-2">
        <table class="table table-hover align-middle mb-2">
            <thead class="thead-light">
                <tr>
                    <th style="width: 80px; text-align: right;">번호</th>
                    <th style="width: 240px;">주문일시 / 주문번호</th>
                    <th>상품 정보</th>
                    <th style="width: 160px; text-align: right;">주문 금액</th>
                    <th style="width: 140px; text-align: center;">상태</th>
                </tr>
            </thead>
            <tbody id="orderListBody"></tbody>
        </table>

        <!-- 공통 페이징바 -->
        <div id="pager" class="mt-2"></div>
    </div>
</section>

<script>
    // ===== 상수/API =====
    const ORDER_API_BASE = '/api/ord/order';
    const ORDER_ID_PARAM = 'orderIdx';

    // 총 건수(처음 한 번만 서버에서 가져오고 이후 재사용)
    let gTotalCount = null;

    // 전역 페이저
    let pager = null;

    $(function () {
        // 공통 페이징과 연결
        pager = Paging.create('#pager', function (page, size) {
            // 첫 호출 시에는 totalCount 없으니 count 먼저 → 이후 페이지 로딩
            if (gTotalCount === null) {
                loadOrderTotalCount()
                    .then(function () {
                        loadOrderPage(page, size);
                    })
                    .catch(function () {
                        alert('주문 건수 조회 중 오류가 발생했습니다.');
                    });
            } else {
                loadOrderPage(page, size);
            }
        }, {
            size: 10,
            maxButtons: 7,
            key: 'orderList',
            autoLoad: true   // 첫 페이지 자동 조회
        });
    });

    // ===== 공통 유틸 =====

    function escapeHtml(str) {
        if (str === null || str === undefined) {
            return '';
        }
        return String(str)
            .replace(/&/g, '&amp;')
            .replace(/</g, '&lt;')
            .replace(/>/g, '&gt;')
            .replace(/"/g, '&quot;')
            .replace(/'/g, '&#39;');
    }

    function unwrapVal(raw) {
        if (raw === null || raw === undefined) {
            return '';
        }
        if (typeof raw === 'object') {
            if (Object.prototype.hasOwnProperty.call(raw, 'value') && raw.value != null) {
                return String(raw.value);
            }
            const keys = Object.keys(raw);
            if (keys.length === 1 && raw[keys[0]] != null) {
                return String(raw[keys[0]]);
            }
            return JSON.stringify(raw);
        }
        return String(raw);
    }

    function getFieldVal(row, logicalName) {
        if (!row) {
            return '';
        }

        const lower = logicalName.toLowerCase();
        const snake = logicalName.replace(/([A-Z])/g, function (m) {
            return '_' + m.toLowerCase();
        });

        const candidates = [
            logicalName,
            logicalName.toLowerCase(),
            snake,
            snake.toUpperCase()
        ];

        for (let i = 0; i < candidates.length; i++) {
            const key = candidates[i];
            if (Object.prototype.hasOwnProperty.call(row, key) && row[key] != null) {
                return unwrapVal(row[key]);
            }
        }

        for (const k in row) {
            if (!Object.prototype.hasOwnProperty.call(row, k)) continue;
            if (k.toLowerCase() === lower && row[k] != null) {
                return unwrapVal(row[k]);
            }
        }

        return '';
    }

    function formatDateTime(raw) {
        const v = unwrapVal(raw);
        return v || '';
    }

    function formatNumber(val) {
        const v = unwrapVal(val);
        if (!v) {
            return '0';
        }
        const num = Number(v);
        if (Number.isNaN(num)) {
            return v;
        }
        return num.toLocaleString('ko-KR');
    }

    function mapOrderStatusLabel(cd) {
        switch (cd) {
            case 'ORDER_DONE':
                return '주문완료';
            case 'ORDER_WAIT':
                return '주문대기';
            case 'ORDER_CANCEL':
                return '주문취소';
            default:
                return cd || '';
        }
    }

    function mapPayStatusLabel(cd) {
        switch (cd) {
            case 'PAY_DONE':
                return '결제완료';
            case 'PAY_WAIT':
                return '결제대기';
            case 'PAY_CANCEL':
                return '결제취소';
            default:
                return cd || '';
        }
    }

    function renderStatusBadge(statusCd, statusNm) {
        const label = statusNm || statusCd || '';
        if (!label) {
            return '';
        }

        let cls = 'badge-secondary';
        switch (statusCd) {
            case 'PAY_WAIT':
            case 'ORDER_WAIT':
                cls = 'badge-warning';
                break;
            case 'PAY_DONE':
            case 'ORDER_DONE':
                cls = 'badge-success';
                break;
            case 'PAY_CANCEL':
            case 'ORDER_CANCEL':
                cls = 'badge-danger';
                break;
            case 'DELIVERY':
            case 'DELIVERY_READY':
                cls = 'badge-info';
                break;
            default:
                cls = 'badge-secondary';
        }

        return '<span class="badge ' + cls + '">' + escapeHtml(label) + '</span>';
    }

    // ===== API 호출 =====

    // 1) 전체 건수
    function loadOrderTotalCount() {
        return new Promise(function (resolve, reject) {
            $.ajax({
                url: ORDER_API_BASE + '/selectOrderListCount',
                type: 'post',
                contentType: 'application/json',
                dataType: 'json',
                data: JSON.stringify({}),
                success: function (map) {
                    if (!map) {
                        reject();
                        return;
                    }
                    if (map.msg === 'LOGIN_REQUIRED') {
                        alert('로그인이 필요한 서비스입니다.');
                        location.href = '/mba/auth/login';
                        return;
                    }
                    if (map.msg !== '성공') {
                        alert(map.msg || '주문 건수 조회 중 오류가 발생했습니다.');
                        reject();
                        return;
                    }

                    let c = Number(map.count || 0);
                    if (isNaN(c) || c < 0) {
                        c = 0;
                    }
                    gTotalCount = c;
                    resolve();
                },
                error: function () {
                    reject();
                }
            });
        });
    }

    // 2) 목록 (page/size → JS에서 offset 계산 → LIMIT/OFFSET 그대로 사용)
    function loadOrderPage(page, size) {
        const p = Number(page) || 1;
        const s = Number(size) || 10;
        const offset = (p - 1) * s;

        $.ajax({
            url: ORDER_API_BASE + '/selectOrderList',
            type: 'post',
            contentType: 'application/json',
            dataType: 'json',
            data: JSON.stringify({
                limit: s,
                offset: offset
            }),
            success: function (map) {
                if (!map) {
                    alert('주문 목록 조회 중 오류가 발생했습니다.');
                    return;
                }
                if (map.msg === 'LOGIN_REQUIRED') {
                    alert('로그인이 필요한 서비스입니다.');
                    location.href = '/mba/auth/login';
                    return;
                }
                if (map.msg !== '성공') {
                    alert(map.msg || '주문 목록 조회 중 오류가 발생했습니다.');
                    return;
                }

                const list = map.result || [];

                // JS에서 페이징 메타 직접 계산해서 pager.update에 넘긴다
                const total = (gTotalCount != null) ? gTotalCount : list.length + offset;
                const totalPages = total > 0 ? Math.ceil(total / s) : 0;
                const meta = {
                    page: p,
                    size: s,
                    total: total,
                    totalPages: totalPages,
                    offset: offset,
                    limit: s
                };

                renderOrderList(list, meta);
                pager.update(meta);
            },
            error: function () {
                alert('주문 목록 조회 중 서버 오류가 발생했습니다.');
            }
        });
    }

    // ===== 렌더링 =====

    function renderOrderList(list, meta) {
        const resultList = list || [];
        const $tbody = $('#orderListBody');
        $tbody.empty();

        const page = meta && meta.page ? Number(meta.page) : 1;
        const size = meta && meta.size ? Number(meta.size) : (resultList.length || 10);
        let totalCount = meta && meta.total != null ? Number(meta.total) : 0;
        if (!totalCount || isNaN(totalCount)) {
            totalCount = resultList.length + ((page - 1) * size);
        }

        if (!resultList.length) {
            $tbody.append(
                '<tr><td colspan="5" class="text-center text-muted">주문 내역이 없습니다.</td></tr>'
            );
            return;
        }

        const startNo = totalCount - ((page - 1) * size);

        for (let i = 0; i < resultList.length; i++) {
            const r = resultList[i];

            const no = startNo - i;

            const orderDt = formatDateTime(
                getFieldVal(r, 'orderDt') || getFieldVal(r, 'createdDt')
            );
            const orderNo = getFieldVal(r, 'orderNo');

            let productSummary = getFieldVal(r, 'productSummary');
            if (!productSummary) {
                // SQL에서 이미 항상 상품명 나오도록 잡아놨지만,
                // 혹시라도 누락되면 데이터 점검 필요 문구만 출력
                productSummary = '상품명 확인 필요(데이터 점검 필요)';
            }

            const totalAmtRaw =
                getFieldVal(r, 'totalAmt') ||
                getFieldVal(r, 'orderAmt') ||
                '0';
            const totalAmt = formatNumber(totalAmtRaw);

            const orderStatusCd = getFieldVal(r, 'orderStatusCd');
            const payStatusCd = getFieldVal(r, 'payStatusCd');

            const orderStatusNm = mapOrderStatusLabel(orderStatusCd);
            const payStatusNm = mapPayStatusLabel(payStatusCd);

            const orderStatusBadge = renderStatusBadge(orderStatusCd, orderStatusNm);
            const payStatusBadge = renderStatusBadge(payStatusCd, payStatusNm);

            const orderId =
                getFieldVal(r, 'orderId') ||
                getFieldVal(r, 'orderIdx');

            let rowHtml = '<tr';
            if (orderId) {
                rowHtml += ' onclick="goToOrderModify(\'' + encodeURIComponent(orderId) + '\')"';
            }
            rowHtml += '>';

            rowHtml += '  <td class="text-center align-middle">' + no + '</td>';
            rowHtml += '  <td class="align-middle">';
            rowHtml += '    <div>주문일시: ' + escapeHtml(orderDt) + '</div>';
            rowHtml += '    <div>주문번호: ' + escapeHtml(orderNo) + '</div>';
            rowHtml += '  </td>';
            rowHtml += '  <td class="align-middle">' + escapeHtml(productSummary) + '</td>';
            rowHtml += '  <td class="text-right align-middle">' + totalAmt + '원</td>';
            rowHtml += '  <td class="text-center align-middle">';
            if (orderStatusBadge) {
                rowHtml += '    <div>' + orderStatusBadge + '</div>';
            }
            if (payStatusBadge) {
                rowHtml += '    <div class="mt-1">' + payStatusBadge + '</div>';
            }
            rowHtml += '  </td>';
            rowHtml += '</tr>';

            $tbody.append(rowHtml);
        }
    }

    // ===== 페이지 이동 =====

    function goToOrderModify(encodedId) { 
        let url = '/ord/order/orderDetail';
        if (encodedId) {
            url += '?' + ORDER_ID_PARAM + '=' + encodedId;
        }
        location.href = url;
    }

    function goToOrder() {
        location.href = '/ord/order/order';
    }
</script>
