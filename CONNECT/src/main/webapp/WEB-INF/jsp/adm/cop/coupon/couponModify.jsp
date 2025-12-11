<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>

<section>
    <h2 class="mb-3">쿠폰 <span id="pageTitle">등록</span></h2>

    <div class="mb-3">
        <button class="btn btn-primary" type="button" onclick="saveCoupon()">저장</button>
        <c:if test="${not empty param.couponId}">
            <button class="btn btn-outline-danger" type="button" onclick="deleteCoupon()">삭제</button>
        </c:if>
        <a class="btn btn-outline-secondary" href="/cop/coupon/couponList">목록</a>
    </div>

    <form id="couponForm">
        <!-- PK -->
        <input type="hidden" name="couponId" id="couponId" value="${param.couponId}"/>

        <div class="row" style="max-width: 840px;">
            <div class="col-md-6">
                <div class="form-group mb-3">
                    <label for="couponCd">쿠폰 코드</label>
                    <input type="text" class="form-control" name="couponCd" id="couponCd" placeholder="예: WELCOME10"/>
                </div>
            </div>
            <div class="col-md-6">
                <div class="form-group mb-3">
                    <label for="couponNm">쿠폰명</label>
                    <input type="text" class="form-control" name="couponNm" id="couponNm" placeholder="예: 신규가입 10% 할인"/>
                </div>
            </div>
        </div>

        <div class="row" style="max-width: 840px;">
            <div class="col-md-4">
                <div class="form-group mb-3">
                    <label>쿠폰 타입</label>
                    <div>
                        <div class="form-check form-check-inline">
                            <input class="form-check-input" type="radio" name="couponTypeCd" id="couponTypeAmt" value="AMT" checked>
                            <label class="form-check-label" for="couponTypeAmt">정액(원)</label>
                        </div>
                        <div class="form-check form-check-inline">
                            <input class="form-check-input" type="radio" name="couponTypeCd" id="couponTypeRate" value="RATE">
                            <label class="form-check-label" for="couponTypeRate">정률(%)</label>
                        </div>
                    </div>
                </div>
            </div>

            <div class="col-md-4">
                <div class="form-group mb-3">
                    <label for="discountAmt">정액 할인금액(원)</label>
                    <input type="number" class="form-control" name="discountAmt" id="discountAmt" placeholder="예: 3000">
                </div>
            </div>

            <div class="col-md-4">
                <div class="form-group mb-3">
                    <label for="discountRate">정률 할인율(%)</label>
                    <input type="number" step="0.01" class="form-control" name="discountRate" id="discountRate" placeholder="예: 10">
                </div>
            </div>
        </div>

        <div class="row" style="max-width: 840px;">
            <div class="col-md-4">
                <div class="form-group mb-3">
                    <label for="maxDiscountAmt">정률 최대 할인금액(원)</label>
                    <input type="number" class="form-control" name="maxDiscountAmt" id="maxDiscountAmt" placeholder="예: 5000">
                    <small class="form-text text-muted">정률 쿠폰일 때만 사용 (없으면 비워둠)</small>
                </div>
            </div>

            <div class="col-md-4">
                <div class="form-group mb-3">
                    <label for="minOrderAmt">최소 주문금액(원)</label>
                    <input type="number" class="form-control" name="minOrderAmt" id="minOrderAmt" placeholder="예: 20000">
                </div>
            </div>
        </div>

        <div class="row" style="max-width: 840px;">
            <div class="col-md-4">
                <div class="form-group mb-3">
                    <label for="maxIssueCnt">전체 발급 제한(장)</label>
                    <input type="number" class="form-control" name="maxIssueCnt" id="maxIssueCnt" placeholder="NULL이면 무제한">
                </div>
            </div>

            <div class="col-md-4">
                <div class="form-group mb-3">
                    <label for="perUserMaxCnt">유저당 최대 보유(장)</label>
                    <input type="number" class="form-control" name="perUserMaxCnt" id="perUserMaxCnt" placeholder="NULL이면 무제한">
                </div>
            </div>

            <div class="col-md-4">
                <div class="form-group mb-3">
                    <label for="useAt">사용 여부</label>
                    <select class="form-control" name="useAt" id="useAt">
                        <option value="Y">Y</option>
                        <option value="N">N</option>
                    </select>
                </div>
            </div>
        </div>

        <div class="row" style="max-width: 840px;">
            <div class="col-md-6">
                <div class="form-group mb-3">
                    <label for="startDt">사용 시작일</label>
                    <input type="datetime-local" class="form-control" name="startDt" id="startDt">
                </div>
            </div>

            <div class="col-md-6">
                <div class="form-group mb-3">
                    <label for="endDt">사용 종료일</label>
                    <input type="datetime-local" class="form-control" name="endDt" id="endDt">
                </div>
            </div>
        </div>

        <div class="form-group mb-3" style="max-width: 840px;">
            <label for="memo">메모</label>
            <textarea class="form-control" name="memo" id="memo" rows="3" placeholder="내부용 메모를 입력하세요."></textarea>
        </div>
    </form>
</section>

<script>
    const API_BASE = '/api/cop/coupon';
    const PK = 'couponId';

    $(document).ready(function () {
        const id = $('#' + PK).val();
        if (id && id !== '') {
            $('#pageTitle').text('수정');
            readCoupon(id);
        } else {
            $('#pageTitle').text('등록');
            // 기본값 세팅
            $('#useAt').val('Y');
            // 타입 기본: 정액
            $('input[name="couponTypeCd"][value="AMT"]').prop('checked', true);
        }

        // 타입에 따라 필드 안내 정도만
        $('input[name="couponTypeCd"]').on('change', function () {
            updateTypeHint();
        });
        updateTypeHint();
    });

    function updateTypeHint() {
        const type = $('input[name="couponTypeCd"]:checked').val();
        if (type === 'AMT') {
            $('#discountAmt').prop('disabled', false);
            $('#discountRate').prop('disabled', true);
        } else if (type === 'RATE') {
            $('#discountAmt').prop('disabled', true);
            $('#discountRate').prop('disabled', false);
        } else {
            $('#discountAmt').prop('disabled', false);
            $('#discountRate').prop('disabled', false);
        }
    }

    function readCoupon(id) {
        const sendData = {};
        sendData[PK] = id;

        $.ajax({
            url: API_BASE + '/selectCouponDetail',
            type: 'post',
            contentType: 'application/json',
            dataType: 'json',
            data: JSON.stringify(sendData),
            success: function (map) {
                const r = map.result || map.coupon || map;
                if (!r) return;

                $('#couponCd').val(r.couponCd || '');
                $('#couponNm').val(r.couponNm || '');
                $('input[name="couponTypeCd"][value="' + (r.couponTypeCd || 'AMT') + '"]').prop('checked', true);
                $('#discountAmt').val(r.discountAmt != null ? r.discountAmt : '');
                $('#discountRate').val(r.discountRate != null ? r.discountRate : '');
                $('#maxDiscountAmt').val(r.maxDiscountAmt != null ? r.maxDiscountAmt : '');
                $('#minOrderAmt').val(r.minOrderAmt != null ? r.minOrderAmt : '');
                $('#maxIssueCnt').val(r.maxIssueCnt != null ? r.maxIssueCnt : '');
                $('#perUserMaxCnt').val(r.perUserMaxCnt != null ? r.perUserMaxCnt : '');
                $('#useAt').val(r.useAt || 'Y');
                $('#memo').val(r.memo || '');

                $('#startDt').val(toLocalDatetimeValue(r.startDt));
                $('#endDt').val(toLocalDatetimeValue(r.endDt));

                updateTypeHint();
            },
            error: function () {
                alert('쿠폰 조회 중 오류가 발생했습니다.');
            }
        });
    }

    function saveCoupon() {
        const id = $('#' + PK).val();
        const url = id && id !== ''
            ? (API_BASE + '/updateCoupon')
            : (API_BASE + '/insertCoupon');

        const couponCd = $('#couponCd').val().trim();
        const couponNm = $('#couponNm').val().trim();
        const type = $('input[name="couponTypeCd"]:checked').val();
        const discountAmt = $('#discountAmt').val();
        const discountRate = $('#discountRate').val();
        const startDt = $('#startDt').val();
        const endDt = $('#endDt').val();

        if (!couponCd) {
            alert('쿠폰 코드를 입력하세요.');
            $('#couponCd').focus();
            return;
        }
        if (!couponNm) {
            alert('쿠폰명을 입력하세요.');
            $('#couponNm').focus();
            return;
        }
        if (!startDt || !endDt) {
            alert('사용 시작일과 종료일을 모두 입력하세요.');
            return;
        }
        if (type === 'AMT' && (!discountAmt || Number(discountAmt) <= 0)) {
            alert('정액 쿠폰은 할인금액(원)을 입력해야 합니다.');
            $('#discountAmt').focus();
            return;
        }
        if (type === 'RATE' && (!discountRate || Number(discountRate) <= 0)) {
            alert('정률 쿠폰은 할인율(%)을 입력해야 합니다.');
            $('#discountRate').focus();
            return;
        }

        const formData = $('#couponForm').serializeObject();

        $.ajax({
            url: url,
            type: 'post',
            contentType: 'application/json',
            dataType: 'json',
            data: JSON.stringify(formData),
            success: function () {
                location.href = '/cop/coupon/couponList';
            },
            error: function () {
                alert('쿠폰 저장 중 오류가 발생했습니다.');
            }
        });
    }

    function deleteCoupon() {
        const id = $('#' + PK).val();
        if (!id || id === '') {
            alert('삭제할 쿠폰 ID가 없습니다.');
            return;
        }
        if (!confirm('정말 삭제하시겠습니까?')) return;

        const sendData = {};
        sendData[PK] = id;

        $.ajax({
            url: API_BASE + '/deleteCoupon',
            type: 'post',
            contentType: 'application/json',
            dataType: 'json',
            data: JSON.stringify(sendData),
            success: function () {
                alert('삭제되었습니다.');
                location.href = '/cop/coupon/couponList';
            },
            error: function () {
                alert('쿠폰 삭제 중 오류가 발생했습니다.');
            }
        });
    }

    // yyyy-MM-dd HH:mm:ss -> datetime-local 값(yyyy-MM-ddTHH:mm)
    function toLocalDatetimeValue(str) {
        if (!str) return '';
        // "2025-12-09 12:34:56" → "2025-12-09T12:34"
        return str.replace(' ', 'T').substring(0, 16);
    }

    // serializeObject: 폼 → JSON
    $.fn.serializeObject = function () {
        const obj = {};
        const arr = this.serializeArray();
        $.each(arr, function () {
            obj[this.name] = this.value;
        });
        return obj;
    };
</script>
