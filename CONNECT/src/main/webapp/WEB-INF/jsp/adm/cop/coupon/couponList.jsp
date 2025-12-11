<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<section>
    <h2 class="mb-3">쿠폰 목록</h2>

    <div class="mb-3">
        <button class="btn btn-primary" type="button" onclick="goToCouponForm()">쿠폰 등록</button>
    </div>

    <div class="table-responsive">
        <table class="table table-hover align-middle">
            <thead class="thead-light">
                <tr>
                    <th style="width: 80px; text-align:right;">ID</th>
                    <th style="width: 140px;">쿠폰코드</th>
                    <th>쿠폰명</th>
                    <th style="width: 140px;">타입/할인</th>
                    <th style="width: 260px;">사용기간</th>
                    <th style="width: 80px;">사용여부</th>
                    <th style="width: 160px;">등록일</th>
                </tr>
            </thead>
            <tbody id="couponListBody"></tbody>
        </table>
    </div>
</section>

<script>
    const API_BASE = '/api/cop/coupon';
    const PK = 'couponId';

    $(function () {
        selectCouponList();
    });

    function selectCouponList() {
        $.ajax({
            url: API_BASE + '/selectCouponList',
            type: 'post',
            contentType: 'application/json',
            data: JSON.stringify({}),
            success: function (map) {
                const resultList = map.result || [];
                let html = '';

                if (!resultList.length) {
                    html += "<tr><td colspan='7' class='text-center text-muted'>등록된 쿠폰이 없습니다.</td></tr>";
                } else {
                    for (let i = 0; i < resultList.length; i++) {
                        const r = resultList[i] || {};
                        const couponId = r.couponId || '';
                        const couponCd = r.couponCd || '';
                        const couponNm = r.couponNm || '';
                        const typeCd = r.couponTypeCd || '';
                        const discountRate = r.discountRate || null;
                        const discountAmt = r.discountAmt || null;
                        const startDt = r.startDt || '';
                        const endDt = r.endDt || '';
                        const useAt = r.useAt || '';
                        const createdDt = r.createdDt || '';
                        const createdBy = r.createdBy || '';

                        let typeLabel = '';
                        if (typeCd === 'RATE') {
                            typeLabel = '정률';
                        } else if (typeCd === 'AMT') {
                            typeLabel = '정액';
                        } else {
                            typeLabel = typeCd || '-';
                        }

                        let discountLabel = '';
                        if (typeCd === 'RATE' && discountRate != null && discountRate !== '') {
                            discountLabel = discountRate + '%';
                        } else if (typeCd === 'AMT' && discountAmt != null && discountAmt !== '') {
                            discountLabel = numberFormat(discountAmt) + '원';
                        } else {
                            discountLabel = '-';
                        }

                        let useLabel = '';
                        if (useAt === 'Y') {
                            useLabel = "<span class='badge bg-success'>Y</span>";
                        } else if (useAt === 'N') {
                            useLabel = "<span class='badge bg-secondary'>N</span>";
                        } else {
                            useLabel = useAt || '-';
                        }

                        const periodLabel = (startDt || '') + ' ~ ' + (endDt || '');

                        html += "<tr style='cursor:pointer;' onclick=\"goToCouponForm('" + encodeURIComponent(couponId) + "')\">";
                        html += "  <td class='text-end'>" + couponId + "</td>";
                        html += "  <td>" + escapeHtml(couponCd) + "</td>";
                        html += "  <td>" + escapeHtml(couponNm) + "</td>";
                        html += "  <td>" + typeLabel + " / " + discountLabel + "</td>";
                        html += "  <td>" + periodLabel + "</td>";
                        html += "  <td>" + useLabel + "</td>";
                        html += "  <td>" + (createdDt || '') + "</td>";
                        html += "</tr>";
                    }
                }

                $('#couponListBody').html(html);
            },
            error: function () {
                alert('쿠폰 목록 조회 중 오류가 발생했습니다.');
            }
        });
    }
 	
    function goToCouponForm(id) {
        let url = '/adm/cop/coupon/couponModify';
        if (id) {
            url += '?' + PK + '=' + id;
        }
        location.href = url;
    }

    // 숫자 포맷 (3자리 콤마)
    function numberFormat(val) {
        const n = Number(val);
        if (isNaN(n)) return val;
        return n.toLocaleString('ko-KR');
    }

    // XSS 방지용 간단 escape
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
