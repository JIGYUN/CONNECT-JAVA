<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>

<section>
    <h2 class="mb-3">쿠폰 발급 <span id="pageTitle">등록</span></h2>

    <div class="mb-3">
        <button class="btn btn-primary" type="button" onclick="saveCouponUser()">저장</button>
        <c:if test="${not empty param.couponUserId}">
            <button class="btn btn-outline-danger" type="button" onclick="deleteCouponUser()">삭제</button>
        </c:if>
        <a class="btn btn-outline-secondary" href="/adm/cop/couponUser/couponUserList">목록</a>
    </div>

    <form id="couponUserForm">
        <input type="hidden" name="couponUserId" id="couponUserId" value="${param.couponUserId}"/>

        <!-- 쿠폰 선택 영역 -->
        <div class="card mb-3" style="max-width: 840px;">
            <div class="card-header">
                쿠폰 선택
            </div>
            <div class="card-body">
                <input type="hidden" name="couponId" id="couponId"/>

                <div class="row g-2 align-items-center">
                    <div class="col-md-8">
                        <label class="form-label mb-1">선택된 쿠폰</label>
                        <input type="text"
                               class="form-control"
                               id="couponLabel"
                               value="선택된 쿠폰이 없습니다."
                               readonly>
                        <small class="text-muted" id="couponSubLabel"></small>
                    </div>
                    <div class="col-md-4 d-grid gap-2">
                        <button type="button"
                                class="btn btn-outline-primary"
                                onclick="openCouponSearchModal()">
                            쿠폰 검색
                        </button>
                    </div>
                </div>
            </div>
        </div>

        <!-- 사용자 선택 영역 -->
        <div class="card mb-3" style="max-width: 840px;">
            <div class="card-header">
                사용자 선택
            </div>
            <div class="card-body">
                <input type="hidden" name="userId" id="userId"/>

                <div class="row g-2 align-items-center">
                    <div class="col-md-8">
                        <label class="form-label mb-1">선택된 사용자</label>
                        <input type="text"
                               class="form-control"
                               id="userLabel"
                               value="선택된 사용자가 없습니다."
                               readonly>
                        <small class="text-muted" id="userSubLabel"></small>
                    </div>
                    <div class="col-md-4 d-grid gap-2">
                        <button type="button"
                                class="btn btn-outline-primary"
                                onclick="openUserSearchModal()">
                            사용자 검색
                        </button>
                        <button type="button"
                                class="btn btn-outline-secondary"
                                onclick="setCurrentUser()">
                            현재 로그인 사용자로 설정
                        </button>
                    </div>
                </div>
            </div>
        </div>

        <!-- 상태/주문/사용여부 -->
        <div class="row" style="max-width: 840px;">
            <div class="col-md-4">
                <div class="form-group mb-3">
                    <label for="statusCd">상태코드</label>
                    <select class="form-control" name="statusCd" id="statusCd">
                        <option value="ISSUED">ISSUED(발급)</option>
                        <option value="USED">USED(사용)</option>
                        <option value="EXPIRED">EXPIRED(만료)</option>
                        <option value="CANCELLED">CANCELLED(취소)</option>
                    </select>
                </div>
            </div>
            <div class="col-md-4">
                <div class="form-group mb-3">
                    <label for="orderId">주문 ID</label>
                    <input type="number"
                           class="form-control"
                           name="orderId"
                           id="orderId"
                           placeholder="사용된 주문 ID(선택)">
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

        <!-- 일시 -->
        <div class="row" style="max-width: 840px;">
            <div class="col-md-6">
                <div class="form-group mb-3">
                    <label for="issueDt">발급일(선택)</label>
                    <input type="datetime-local"
                           class="form-control"
                           name="issueDt"
                           id="issueDt">
                    <small class="form-text text-muted">비우면 서버에서 현재 시각으로 처리</small>
                </div>
            </div>

            <div class="col-md-6">
                <div class="form-group mb-3">
                    <label for="useDt">사용일(선택)</label>
                    <input type="datetime-local"
                           class="form-control"
                           name="useDt"
                           id="useDt">
                    <small class="form-text text-muted">USED 상태일 때 설정</small>
                </div>
            </div>
        </div>
    </form>
</section>

<!-- 쿠폰 검색 모달 -->
<div class="modal fade" id="couponSearchModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-scrollable">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">쿠폰 검색</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="닫기"></button>
            </div>
            <div class="modal-body">
                <div class="row g-2 mb-2">
                    <div class="col-8">
                        <input type="text"
                               id="couponSearchKeyword"
                               class="form-control"
                               placeholder="쿠폰명 또는 코드로 검색">
                    </div>
                    <div class="col-4 d-grid">
                        <button type="button" class="btn btn-outline-primary" onclick="filterCouponList()">
                            검색
                        </button>
                    </div>
                </div>

                <div class="table-responsive" style="max-height: 400px;">
                    <table class="table table-hover align-middle mb-0">
                        <thead class="thead-light">
                            <tr>
                                <th style="width:80px;">ID</th>
                                <th style="width:140px;">코드</th>
                                <th>쿠폰명</th>
                                <th style="width:120px;">유형</th>
                                <th style="width:120px;">할인</th>
                            </tr>
                        </thead>
                        <tbody id="couponSearchTbody">
                        </tbody>
                    </table>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button"
                        class="btn btn-outline-secondary"
                        data-bs-dismiss="modal">닫기</button>
            </div>
        </div>
    </div>
</div>

<!-- 사용자 검색 모달 -->
<div class="modal fade" id="userSearchModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-scrollable">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">사용자 검색</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="닫기"></button>
            </div>
            <div class="modal-body">
                <div class="row g-2 mb-2">
                    <div class="col-8">
                        <input type="text"
                               id="userSearchKeyword"
                               class="form-control"
                               placeholder="ID / 이름 / 이메일 검색">
                    </div>
                    <div class="col-4 d-grid">
                        <button type="button" class="btn btn-outline-primary" onclick="searchUserList()">
                            검색
                        </button>
                    </div>
                </div>

                <div class="table-responsive" style="max-height: 400px;">
                    <table class="table table-hover align-middle mb-0">
                        <thead class="thead-light">
                            <tr>
                                <th style="width:80px;">ID</th>
                                <th style="width:160px;">로그인ID</th>
                                <th>이름</th>
                                <th style="width:220px;">이메일</th>
                            </tr>
                        </thead>
                        <tbody id="userSearchTbody">
                        </tbody>
                    </table>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button"
                        class="btn btn-outline-secondary"
                        data-bs-dismiss="modal">닫기</button>
            </div>
        </div>
    </div>
</div>

<script>
    const API_BASE = '/api/cop/couponUser';
    const PK = 'couponUserId';

    // 쿠폰/사용자 검색용 API (사용자 API는 실제 프로젝트에 맞게 수정 필요)
    const COUPON_SEARCH_API = '/api/cop/coupon/selectCouponList';
    const USER_SEARCH_API = '/api/usr/user/selectUserList'; // TODO: 실제 사용자 목록 API로 변경

    let couponSearchCache = [];
    let userSearchLastKeyword = '';

    $(document).ready(function () {
        const id = $('#' + PK).val();
        if (id && id !== '') {
            $('#pageTitle').text('수정');
            readCouponUser(id);
        } else {
            $('#pageTitle').text('등록');
            $('#statusCd').val('ISSUED');
            $('#useAt').val('Y');
        }
    });

    function readCouponUser(id) {
        const sendData = {};
        sendData[PK] = id;

        $.ajax({
            url: API_BASE + '/selectCouponUserDetail',
            type: 'post',
            contentType: 'application/json',
            dataType: 'json',
            data: JSON.stringify(sendData),
            success: function (map) {
                const r = map.result || map.couponUser || map;
                if (!r) return;

                // 쿠폰
                $('#couponId').val(r.couponId != null ? r.couponId : '');
                const couponNm = r.couponNm || '';
                const couponCd = r.couponCd || '';
                applyCouponLabel(r.couponId, couponNm, couponCd, r.couponTypeCd, r.discountRate, r.discountAmt);

                // 사용자
                $('#userId').val(r.userId != null ? r.userId : '');
                applyUserLabel(r.userId, r.userNm, r.loginId, r.email);

                // 기타
                $('#statusCd').val(r.statusCd || 'ISSUED');
                $('#orderId').val(r.orderId != null ? r.orderId : '');
                $('#useAt').val(r.useAt || 'Y');

                $('#issueDt').val(toLocalDatetimeValue(r.issueDt));
                $('#useDt').val(toLocalDatetimeValue(r.useDt));
            },
            error: function () {
                alert('쿠폰 발급 정보 조회 중 오류가 발생했습니다.');
            }
        });
    }

    function saveCouponUser() {
        const id = $('#' + PK).val();
        const url = id && id !== ''
            ? (API_BASE + '/updateCouponUser')
            : (API_BASE + '/insertCouponUser');

        const couponId = $('#couponId').val().trim();
        const userId = $('#userId').val().trim();

        if (!couponId) {
            alert('쿠폰을 선택해주세요.');
            openCouponSearchModal();
            return;
        }
        if (!userId) {
            alert('사용자를 선택해주세요.');
            openUserSearchModal();
            return;
        }

        const formData = $('#couponUserForm').serializeObject();

        $.ajax({
            url: url,
            type: 'post',
            contentType: 'application/json',
            dataType: 'json',
            data: JSON.stringify(formData),
            success: function () {
                location.href = '/adm/cop/couponUser/couponUserList';
            },
            error: function () {
                alert('저장 중 오류가 발생했습니다.');
            }
        });
    }

    function deleteCouponUser() {
        const id = $('#' + PK).val();
        if (!id || id === '') {
            alert('삭제할 쿠폰 발급 ID가 없습니다.');
            return;
        }
        if (!confirm('정말 삭제하시겠습니까?')) return;

        const sendData = {};
        sendData[PK] = id;

        $.ajax({
            url: API_BASE + '/deleteCouponUser',
            type: 'post',
            contentType: 'application/json',
            dataType: 'json',
            data: JSON.stringify(sendData),
            success: function () {
                alert('삭제되었습니다.');
                location.href = '/adm/cop/couponUser/couponUserList';
            },
            error: function () {
                alert('삭제 중 오류가 발생했습니다.');
            }
        });
    }

    // ========================
    // 쿠폰 검색
    // ========================

    function openCouponSearchModal() {
        if (!couponSearchCache.length) {
            loadCouponListFromServer(function () {
                renderCouponSearchTable('');
                showCouponModal();
            });
        } else {
            renderCouponSearchTable('');
            showCouponModal();
        }
    }

    function showCouponModal() {
        $('#couponSearchKeyword').val('');
        const modalEl = document.getElementById('couponSearchModal');
        const modal = new bootstrap.Modal(modalEl);
        modal.show();
    }

    function loadCouponListFromServer(callback) {
        $.ajax({
            url: COUPON_SEARCH_API,
            type: 'post',
            contentType: 'application/json',
            dataType: 'json',
            data: JSON.stringify({}),
            success: function (map) {
                couponSearchCache = map.result || [];
                if (typeof callback === 'function') callback();
            },
            error: function () {
                alert('쿠폰 목록 조회 중 오류가 발생했습니다.');
            }
        });
    }

    function filterCouponList() {
        const keyword = $('#couponSearchKeyword').val().trim();
        renderCouponSearchTable(keyword);
    }

    function renderCouponSearchTable(keyword) {
        const $tbody = $('#couponSearchTbody');
        $tbody.empty();

        const lower = (keyword || '').toLowerCase();

        const filtered = couponSearchCache.filter(function (r) {
            if (!lower) return true;
            const nm = (r.couponNm || '').toString().toLowerCase();
            const cd = (r.couponCd || '').toString().toLowerCase();
            return nm.indexOf(lower) !== -1 || cd.indexOf(lower) !== -1;
        });

        if (!filtered.length) {
            $tbody.append(
                "<tr><td colspan='5' class='text-center text-muted'>검색 결과가 없습니다.</td></tr>"
            );
            return;
        }

        for (let i = 0; i < filtered.length; i++) {
            const r = filtered[i] || {};

            const couponId = r.couponId || '';
            const couponCd = r.couponCd || '';
            const couponNm = r.couponNm || '';
            const couponTypeCd = r.couponTypeCd || '';
            const discountRate = r.discountRate != null ? r.discountRate : '';
            const discountAmt = r.discountAmt != null ? r.discountAmt : '';

            let discountLabel = '-';
            if (couponTypeCd === 'RATE' && discountRate !== '') {
                discountLabel = discountRate + '%';
            } else if (couponTypeCd === 'AMT' && discountAmt !== '') {
                discountLabel = numberFormat(discountAmt) + '원';
            }

            let html = '';
            html += "<tr style='cursor:pointer;' onclick=\"selectCouponFromModal('" + couponId + "')\">";
            html += "  <td>" + couponId + "</td>";
            html += "  <td>" + escapeHtml(couponCd) + "</td>";
            html += "  <td>" + escapeHtml(couponNm) + "</td>";
            html += "  <td>" + escapeHtml(couponTypeCd || '') + "</td>";
            html += "  <td>" + discountLabel + "</td>";
            html += "</tr>";

            $tbody.append(html);
        }
    }

    function selectCouponFromModal(couponId) {
        const r = couponSearchCache.find(function (item) {
            return String(item.couponId) === String(couponId);
        }) || {};

        $('#couponId').val(r.couponId || '');

        applyCouponLabel(
            r.couponId,
            r.couponNm,
            r.couponCd,
            r.couponTypeCd,
            r.discountRate,
            r.discountAmt
        );

        const modalEl = document.getElementById('couponSearchModal');
        const modal = bootstrap.Modal.getInstance(modalEl);
        if (modal) modal.hide();
    }

    function applyCouponLabel(couponId, couponNm, couponCd, couponTypeCd, discountRate, discountAmt) {
        const $label = $('#couponLabel');
        const $sub = $('#couponSubLabel');

        if (!couponId) {
            $label.val('선택된 쿠폰이 없습니다.');
            $sub.text('');
            return;
        }

        const nm = couponNm || '';
        const cd = couponCd || '';

        let discountLabel = '';
        if (couponTypeCd === 'RATE' && discountRate != null && discountRate !== '') {
            discountLabel = discountRate + '% 할인';
        } else if (couponTypeCd === 'AMT' && discountAmt != null && discountAmt !== '') {
            discountLabel = numberFormat(discountAmt) + '원 할인';
        }

        let main = nm || ('쿠폰 #' + couponId);
        if (cd) {
            main += ' (' + cd + ')';
        }

        $label.val(main);
        $sub.text(discountLabel);
    }

    // ========================
    // 사용자 검색
    // ========================

    function openUserSearchModal() {
        $('#userSearchKeyword').val(userSearchLastKeyword);
        searchUserList();
        const modalEl = document.getElementById('userSearchModal');
        const modal = new bootstrap.Modal(modalEl);
        modal.show();
    }

    function searchUserList() {
        const keyword = $('#userSearchKeyword').val().trim();
        userSearchLastKeyword = keyword;

        // 실제 사용자 API 파라미터는 프로젝트에 맞게 조정
        const sendData = { keyword: keyword };

        $.ajax({
            url: USER_SEARCH_API,
            type: 'post',
            contentType: 'application/json',
            dataType: 'json',
            data: JSON.stringify(sendData),
            success: function (map) {
                const list = map.result || [];
                renderUserSearchTable(list);
            },
            error: function () {
                alert('사용자 목록 조회 중 오류가 발생했습니다.');
            }
        });
    }

    function renderUserSearchTable(list) {
        const $tbody = $('#userSearchTbody');
        $tbody.empty();

        if (!list.length) {
            $tbody.append(
                "<tr><td colspan='4' class='text-center text-muted'>검색 결과가 없습니다.</td></tr>"
            );
            return;
        }

        for (let i = 0; i < list.length; i++) {
            const r = list[i] || {};

            const userId = r.userId != null ? r.userId : '';
            const loginId = r.loginId || r.username || '';
            const userNm = r.userNm || r.name || '';
            const email = r.email || '';

            let html = '';
            html += "<tr style='cursor:pointer;' onclick=\"selectUserFromModal('" + userId + "')\">";
            html += "  <td>" + userId + "</td>";
            html += "  <td>" + escapeHtml(loginId) + "</td>";
            html += "  <td>" + escapeHtml(userNm) + "</td>";
            html += "  <td>" + escapeHtml(email) + "</td>";
            html += "</tr>";

            $tbody.append(html);
        }
    }

    function selectUserFromModal(userId) {
        // 선택된 row를 다시 찾는다
        // (실제 필드는 프로젝트에 맞게 조정)
        const $rows = $('#userSearchTbody tr');
        let selectedInfo = null;

        $rows.each(function () {
            const tds = $(this).find('td');
            if (!tds.length) return;

            const rowUserId = $(tds[0]).text().trim();
            if (rowUserId === String(userId)) {
                selectedInfo = {
                    userId: rowUserId,
                    loginId: $(tds[1]).text().trim(),
                    userNm: $(tds[2]).text().trim(),
                    email: $(tds[3]).text().trim()
                };
            }
        });

        $('#userId').val(selectedInfo ? selectedInfo.userId : '');
        if (selectedInfo) {
            applyUserLabel(selectedInfo.userId, selectedInfo.userNm, selectedInfo.loginId, selectedInfo.email);
        }

        const modalEl = document.getElementById('userSearchModal');
        const modal = bootstrap.Modal.getInstance(modalEl);
        if (modal) modal.hide();
    }

    function applyUserLabel(userId, userNm, loginId, email) {
        const $label = $('#userLabel');
        const $sub = $('#userSubLabel');

        if (!userId) {
            $label.val('선택된 사용자가 없습니다.');
            $sub.text('');
            return;
        }

        let main = '';
        if (userNm) main += userNm;
        if (loginId) {
            if (main) main += ' / ';
            main += loginId;
        }
        if (!main) main = 'USER #' + userId;

        $label.val(main);

        let sub = 'ID: ' + userId;
        if (email) sub += ' · ' + email;

        $sub.text(sub);
    }

    // 로그인 사용자로 세팅 (userId만 세팅, 라벨은 단순 표시)
    function setCurrentUser() {
        $.ajax({
            url: '/api/usr/user/selectLoginUser', // TODO: 실제 로그인 사용자 조회 API로 변경
            type: 'post',
            contentType: 'application/json',
            dataType: 'json',
            data: JSON.stringify({}),
            success: function (map) {
                const r = map.result || map.user || map;
                if (!r) {
                    alert('로그인 사용자 정보를 가져올 수 없습니다.');
                    return;
                }

                const userId = r.userId != null ? r.userId : '';
                const userNm = r.userNm || r.name || '';
                const loginId = r.loginId || r.username || '';
                const email = r.email || '';

                $('#userId').val(userId);
                applyUserLabel(userId, userNm, loginId, email);
            },
            error: function () {
                alert('로그인 사용자 정보 조회 중 오류가 발생했습니다.');
            }
        });
    }

    // ========================
    // 공통 유틸
    // ========================

    function toLocalDatetimeValue(str) {
        if (!str) return '';
        return str.replace(' ', 'T').substring(0, 16);
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

    $.fn.serializeObject = function () {
        const obj = {};
        const arr = this.serializeArray();
        $.each(arr, function () {
            obj[this.name] = this.value;
        });
        return obj;
    };
</script>
