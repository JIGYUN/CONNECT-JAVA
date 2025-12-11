<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<section>
    <h2 class="mb-3">내 쿠폰함</h2>
    <p class="text-muted small">
        발급된 쿠폰과 사용 가능 기간, 사용 여부를 확인할 수 있습니다.
    </p>

    <div class="table-responsive">
        <table class="table table-hover align-middle">
            <thead class="thead-light">
                <tr>
                    <th style="width: 80px; text-align:right;">번호</th>
                    <th>쿠폰</th>
                    <th style="width: 110px;">할인</th>
                    <th style="width: 110px;">상태</th>
                    <th style="width: 190px;">사용 가능 기간</th>
                    <th style="width: 170px;">발급일</th>
                    <th style="width: 170px;">사용일</th>
                </tr>
            </thead>
            <tbody id="myCouponListBody"></tbody>
        </table>
    </div>
</section>

<script>
    const API_BASE = '/api/cop/couponUser';

    $(function () {
        loadMyCouponList();
    });

    function loadMyCouponList() {
        $.ajax({
            url: API_BASE + '/selectMyCouponList',
            type: 'post',
            contentType: 'application/json',
            dataType: 'json',
            data: JSON.stringify({}),
            success: function (map) {
                const list = map.result || [];
                renderMyCouponList(list);
            },
            error: function () {
                alert('내 쿠폰 목록 조회 중 오류가 발생했습니다.');
            }
        });
    }

    function renderMyCouponList(list) {
        const $tbody = $('#myCouponListBody');
        let html = '';

        if (!list.length) {
            html += "<tr><td colspan='7' class='text-center text-muted'>보유한 쿠폰이 없습니다.</td></tr>";
            $tbody.html(html);
            return;
        }

        for (let i = 0; i < list.length; i++) {
            const r = list[i] || {};

            const couponUserId = r.couponUserId || '';
            const couponNm = r.couponNm || '';
            const couponCd = r.couponCd || '';
            const couponTypeCd = r.couponTypeCd || '';
            const discountRate = r.discountRate;
            const discountAmt = r.discountAmt;
            const issueDt = r.issueDt || '';
            const useDt = r.useDt || '';
            const statusCd = r.statusCd || '';
            const useAt = r.useAt || '';
            const startDt = r.couponStartDt || '';
            const endDt = r.couponEndDt || '';

            let couponLabel = couponNm || '';
            if (couponCd) {
                couponLabel = couponLabel
                    ? (couponLabel + ' (' + couponCd + ')')
                    : couponCd;
            }
            if (!couponLabel) {
                couponLabel = '-';
            }

            const discountLabel = buildDiscountLabel(couponTypeCd, discountRate, discountAmt);
            const statusLabel = buildStatusLabel(statusCd, useDt, endDt);

            let periodLabel = '-';
            if (startDt && endDt) {
                periodLabel = startDt + ' ~ ' + endDt;
            } else if (endDt) {
                periodLabel = '~ ' + endDt;
            }

            html += '<tr>';
            html += "  <td class='text-right'>" + (couponUserId || '-') + '</td>';
            html += '  <td>' + escapeHtml(couponLabel) + '</td>';
            html += '  <td>' + discountLabel + '</td>';
            html += '  <td>' + statusLabel + '</td>';
            html += '  <td>' + escapeHtml(periodLabel) + '</td>';
            html += '  <td>' + escapeHtml(issueDt || '-') + '</td>';
            html += '  <td>' + escapeHtml(useDt || '-') + '</td>';
            html += '</tr>';
        }

        $tbody.html(html);
    }

    function buildDiscountLabel(typeCd, rate, amt) {
        const cd = (typeCd || '').toUpperCase();

        if (cd === 'RATE' && rate != null && rate !== '') {
            return rate + '%';
        }
        if (cd === 'AMT' && amt != null && amt !== '') {
            return numberFormat(amt) + '원';
        }
        return '-';
    }

    function buildStatusLabel(statusCd, useDt, endDt) {
        const cd = (statusCd || '').toUpperCase();

        if (cd === 'USED' || (useDt && useDt !== '')) {
            return "<span class='badge badge-secondary'>사용 완료</span>";
        }
        if (cd === 'EXPIRED') {
            return "<span class='badge badge-dark'>기간 만료</span>";
        }
        if (cd === 'CANCELLED') {
            return "<span class='badge badge-warning'>취소</span>";
        }
        // 기본값: 발급 상태
        return "<span class='badge badge-success'>사용 가능</span>";
    }

    function numberFormat(val) {
        const n = Number(val);
        if (isNaN(n)) return val;
        return n.toLocaleString('ko-KR');
    }

    function escapeHtml(str) {
        if (!str) return '';
        return String(str)
            .replace(/&/g, '&amp;')
            .replace(/</g, '&lt;')
            .replace(/>/g, '&gt;')
            .replace(/"/g, '&quot;')
            .replace(/'/g, '&#39;');
    }
</script>
