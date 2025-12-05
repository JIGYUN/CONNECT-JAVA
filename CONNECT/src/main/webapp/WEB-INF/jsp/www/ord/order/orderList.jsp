<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<section class="container py-4">
    <div class="d-flex justify-content-between align-items-center mb-3">
        <h2 class="mb-0">주문 내역</h2>

        <div>
            <button class="btn btn-primary btn-sm" type="button" onclick="goToOrderModify()">
                주문 작성(테스트)
            </button>
            <button class="btn btn-outline-secondary btn-sm" type="button" onclick="goToOrder()">
                장바구니 주문하기
            </button>
        </div>
    </div>

    <div class="table-responsive">
        <table class="table table-hover align-middle mb-0">
            <thead class="thead-light">
                <tr>
                    <th style="width: 80px; text-align: right;">번호</th>
                    <th style="width: 240px;">주문일시 / 주문번호</th>
                    <th>상품 정보</th>
                    <th style="width: 160px; text-align: right;">주문 금액</th>
                    <th style="width: 120px;">상태</th>
                </tr>
            </thead>
            <tbody id="orderListBody"></tbody>
        </table>
    </div>
</section>

<script>
    // API 엔드포인트 및 파라미터 키
    const ORDER_API_BASE = '/api/ord/order';
    const ORDER_ID_PARAM = 'orderIdx';

    $(function () {
        loadOrderList();
    });

    // --------------------------
    // 유틸리티
    // --------------------------

    function formatDateTime(raw) {
        if (!raw) {
            return '';
        }

        // Javagen 날짜 오브젝트 대응 (예: { value: '2025-12-05 12:34:56' })
        if (typeof raw === 'object') {
            if (raw.value) {
                return String(raw.value);
            }
            return String(raw);
        }

        return String(raw);
    }

    function formatNumber(val) {
        if (val === null || val === undefined || val === '') {
            return '0';
        }
        const num = Number(val);
        if (Number.isNaN(num)) {
            return String(val);
        }
        return num.toLocaleString('ko-KR');
    }

    function renderStatusBadge(statusCd, statusNm) {
        const label = statusNm || statusCd || '';
        if (!label) {
            return '';
        }

        // 아주 단순한 코드별 색 구분 (필요 없으면 전부 secondary로)
        let cls = 'badge-secondary';
        switch (statusCd) {
            case 'PAY_WAIT':
                cls = 'badge-warning';
                break;
            case 'PAY_DONE':
                cls = 'badge-success';
                break;
            case 'CANCEL':
                cls = 'badge-danger';
                break;
            case 'DELIVERY':
                cls = 'badge-info';
                break;
            default:
                cls = 'badge-secondary';
        }

        return '<span class="badge ' + cls + '">' + label + '</span>';
    }

    // --------------------------
    // 목록 조회
    // --------------------------

    function loadOrderList() {
        $.ajax({
            url: ORDER_API_BASE + '/selectOrderList',
            type: 'post',
            contentType: 'application/json',
            dataType: 'json',
            data: JSON.stringify({}),
            success: function (map) {
                if (!map) {
                    alert('주문 목록 조회 중 오류가 발생했습니다.');
                    return;
                }

                if (map.msg === 'LOGIN_REQUIRED') {
                    alert('로그인이 필요한 서비스입니다.');
                    location.href = '/usr/login';
                    return;
                }

                if (map.msg !== '성공') {
                    alert(map.msg || '주문 목록 조회 중 오류가 발생했습니다.');
                    return;
                }

                const list = map.result || [];
                renderOrderList(list);
            },
            error: function () {
                alert('주문 목록 조회 중 서버 오류가 발생했습니다.');
            }
        });
    }

    function renderOrderList(list) {
    	const resultList = list; 
    	let html = '';

    	if (!resultList.length) {
    	    html += "<tr><td colspan='5' class='text-center text-muted'>주문 내역이 없습니다.</td></tr>";
    	} else {
    	    for (let i = 0; i < resultList.length; i++) {
    	        const r = resultList[i];

    	        // 번호는 그냥 프런트에서 역순 번호로
    	        const no = resultList.length - i;

    	        const orderDt = r.orderDt || r.createdDt || '';
    	        const orderNo = r.orderNo || '';
    	        const productSummary = r.productSummary || '(상품 정보 없음)';
    	        const totalAmt = (r.totalAmt != null ? r.totalAmt : r.orderAmt) || 0;
    	        const status = r.orderStatusNm || r.orderStatusCd || '-';

    	        html += '<tr>';
    	        html += '  <td class="text-center">' + no + '</td>';
    	        html += '  <td>';
    	        html += '    <div>주문일시: ' + orderDt + '</div>';
    	        html += '    <div>주문번호: ' + orderNo + '</div>';
    	        html += '  </td>';
    	        html += '  <td>' + productSummary + '</td>';
    	        html += '  <td class="text-right">' + totalAmt.toLocaleString() + '원</td>';
    	        html += '  <td class="text-center">' + status + '</td>';
    	        html += '</tr>';
    	    }
    	}

    	$('#orderListBody').html(html);
    }
    // --------------------------
    // 페이지 이동
    // --------------------------

    function goToOrderModify(id) {
        let url = '/ord/order/orderModify';
        if (id) {
            url += '?' + ORDER_ID_PARAM + '=' + encodeURIComponent(id);
        }
        location.href = url;
    }

    // 장바구니 → 주문작성(통합 주문) 화면
    function goToOrder() {
        location.href = '/ord/order/order';
    }
</script>
