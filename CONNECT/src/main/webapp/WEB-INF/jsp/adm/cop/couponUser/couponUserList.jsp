<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<section>
    <h2 class="mb-3">쿠폰 발급 목록</h2>

    <div class="mb-3">
        <button class="btn btn-primary" type="button" onclick="goToCouponUserModify()">발급 등록</button>
        <button class="btn btn-outline-secondary" type="button" onclick="goToCouponUser()">쿠폰 템플릿 관리</button>
    </div>

    <div class="table-responsive">
        <table class="table table-hover align-middle">
            <thead class="thead-light">
                <tr>
                    <th style="width: 80px; text-align:right;">번호</th>
                    <th>쿠폰</th>
                    <th style="width: 130px;">사용자 ID</th>
                    <th style="width: 110px;">상태</th>
                    <th style="width: 170px;">발급일</th>
                    <th style="width: 170px;">사용일</th>
                </tr>
            </thead>
            <tbody id="couponUserListBody"></tbody>
        </table>
    </div>
</section>

<script>
    const API_BASE = '/api/cop/couponUser';
    const couponUserParamKey = 'couponUserId';

    $(function () {
        selectCouponUserList();
    });

    function selectCouponUserList() {
        $.ajax({
            url: API_BASE + '/selectCouponUserList',
            type: 'post',
            contentType: 'application/json',
            dataType: 'json',
            data: JSON.stringify({}),
            success: function (map) {
                const resultList = map.result || [];
                let html = '';

                if (!resultList.length) {
                    html += "<tr><td colspan='6' class='text-center text-muted'>등록된 발급 내역이 없습니다.</td></tr>";
                } else {
                    for (let i = 0; i < resultList.length; i++) {
                        const r = resultList[i] || {};

                        const id = r.couponUserId || '';
                        const couponNm = r.couponNm || '';
                        const couponCd = r.couponCd || '';
                        const userId = r.userId || '';
                        const statusCd = r.statusCd || '';
                        const issueDt = r.issueDt || '';
                        const useDt = r.useDt || '';

                        let couponLabel = couponNm || '';
                        if (couponCd) {
                            couponLabel = couponLabel
                                ? (couponLabel + ' (' + couponCd + ')')
                                : couponCd;
                        }
                        if (!couponLabel) {
                            couponLabel = '-';
                        }

                        const statusLabel = mapStatusLabel(statusCd);

                        html += "<tr style='cursor:pointer;' onclick=\"goToCouponUserModify('" + id + "')\">";
                        html += "  <td class='text-right'>" + (id || '-') + "</td>";
                        html += "  <td>" + escapeHtml(couponLabel) + "</td>";
                        html += "  <td>" + escapeHtml(userId || '-') + "</td>";
                        html += "  <td>" + statusLabel + "</td>";
                        html += "  <td>" + escapeHtml(issueDt || '-') + "</td>";
                        html += "  <td>" + escapeHtml(useDt || '-') + "</td>";
                        html += "</tr>";
                    }
                }

                $('#couponUserListBody').html(html);
            },
            error: function () {
                alert('발급 목록 조회 중 오류가 발생했습니다.');
            }
        });
    }

    function mapStatusLabel(statusCd) {
        const cd = (statusCd || '').toUpperCase();
        if (cd === 'USED') {
            return "<span class='badge badge-secondary'>사용 완료</span>";
        }
        if (cd === 'EXPIRED') {
            return "<span class='badge badge-dark'>기간 만료</span>";
        }
        if (cd === 'CANCELLED') {
            return "<span class='badge badge-warning'>취소</span>";
        }
        // ISSUED 등
        return "<span class='badge badge-success'>사용 가능</span>";
    }

    function goToCouponUserModify(id) {
        let url = '/cop/couponUser/couponUserModify';
        if (id) {
            url += '?' + couponUserParamKey + '=' + encodeURIComponent(id);
        }
        location.href = url;
    }

    function goToCouponUser() {
        location.href = '/cop/coupon/couponList'; // 쿠폰 템플릿 목록 URL에 맞게 수정
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
