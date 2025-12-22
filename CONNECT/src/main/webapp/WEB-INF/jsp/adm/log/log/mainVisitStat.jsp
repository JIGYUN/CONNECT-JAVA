<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.2/dist/css/bootstrap.min.css"/>
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.1/dist/chart.umd.min.js"></script>

<div class="container-fluid py-3">

    <div class="d-flex align-items-center justify-content-between mb-3">
        <div>
            <h4 class="mb-1">메인 접속 통계</h4>
            <div class="text-muted small">동일 날짜 + 동일 IP + SITE(PC/REACT)는 1회만 카운트</div>
        </div>
        <div>
            <a href="/" class="btn btn-sm btn-outline-secondary">사이트 이동</a>
        </div>
    </div>

    <div class="card mb-3">
        <div class="card-body">
            <form id="frm" class="form-inline" onsubmit="return false;">
                <label class="mr-2 font-weight-bold">기간</label>
                <input type="date" id="fromDt" class="form-control form-control-sm mr-2"/>
                <span class="mr-2">~</span>
                <input type="date" id="toDt" class="form-control form-control-sm mr-2"/>
                <button type="button" id="btnSearch" class="btn btn-sm btn-primary">조회</button>

                <div class="ml-auto text-muted small">
                    API: <span class="font-weight-bold">/api/adm/log/mainVisitStat</span>
                </div>
            </form>
        </div>
    </div>

    <div class="row">
        <div class="col-md-4 mb-3">
            <div class="card">
                <div class="card-body">
                    <div class="text-muted small">오늘 PC 메인 UV</div>
                    <div class="h4 mb-0" id="todayPc">0</div>
                </div>
            </div>
        </div>
        <div class="col-md-4 mb-3">
            <div class="card">
                <div class="card-body">
                    <div class="text-muted small">오늘 React 메인 UV</div>
                    <div class="h4 mb-0" id="todayReact">0</div>
                </div>
            </div>
        </div>
        <div class="col-md-4 mb-3">
            <div class="card">
                <div class="card-body">
                    <div class="text-muted small">오늘 합계 UV</div>
                    <div class="h4 mb-0" id="todayTotal">0</div>
                </div>
            </div>
        </div>
    </div>

    <div class="card mb-3">
        <div class="card-body">
            <div class="d-flex align-items-center justify-content-between">
                <h5 class="mb-0">일자별 추이</h5>
                <div class="text-muted small">
                    기간 합계: PC <b id="sumPc">0</b> / React <b id="sumReact">0</b> / Total <b id="sumTotal">0</b>
                </div>
            </div>

            <!-- ✅ 여기: 캔버스 래퍼에 좌우 패딩 조금 -->
            <div class="mt-3 px-2">
                <canvas id="uvChart" height="90"></canvas>
            </div>
        </div>
    </div>

    <div class="card">
        <div class="card-body">
            <h5 class="mb-3">일자별 테이블</h5>
            <div class="table-responsive">
                <table class="table table-sm table-bordered mb-0">
                    <thead class="thead-light">
                        <tr>
                            <th style="width:160px;">일자</th>
                            <th style="width:140px;">PC 메인 UV</th>
                            <th style="width:140px;">React 메인 UV</th>
                            <th style="width:140px;">합계 UV</th>
                        </tr>
                    </thead>
                    <tbody id="tbodyRows">
                        <tr>
                            <td colspan="4" class="text-center text-muted py-4">조회 전</td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

</div>

<script>
(function () {
    var chart = null;

    function pad2(n) {
        return (n < 10 ? '0' : '') + n;
    }

    function fmtDate(d) {
        return d.getFullYear() + '-' + pad2(d.getMonth() + 1) + '-' + pad2(d.getDate());
    }

    function setDefaultRangeIfEmpty() {
        var $from = $('#fromDt');
        var $to = $('#toDt');

        if ($from.val() && $to.val()) return;

        var now = new Date();
        var to = fmtDate(now);

        var fromD = new Date(now.getTime());
        fromD.setDate(fromD.getDate() - 14);
        var from = fmtDate(fromD);

        $from.val(from);
        $to.val(to);
    }

    function num(v) {
        if (v === null || v === undefined) return 0;
        var n = parseInt(String(v), 10);
        if (isNaN(n)) return 0;
        return n;
    }

    function escapeHtml(s) {
        if (s === null || s === undefined) return '';
        return String(s)
            .replace(/&/g, '&amp;')
            .replace(/</g, '&lt;')
            .replace(/>/g, '&gt;')
            .replace(/"/g, '&quot;')
            .replace(/'/g, '&#39;');
    }

    function renderTable(rows) {
        var $tb = $('#tbodyRows');
        if (!rows || rows.length === 0) {
            $tb.html('<tr><td colspan="4" class="text-center text-muted py-4">데이터 없음</td></tr>');
            return;
        }

        var html = '';
        for (var i = 0; i < rows.length; i++) {
            var r = rows[i] || {};
            html += ''
                + '<tr>'
                + '<td>' + escapeHtml(r.visitDt) + '</td>'
                + '<td>' + num(r.pcMainUv) + '</td>'
                + '<td>' + num(r.reactMainUv) + '</td>'
                + '<td><b>' + num(r.totalUv) + '</b></td>'
                + '</tr>';
        }
        $tb.html(html);
    }

    function renderChart(rows) {
        var labels = [];
        var pcData = [];
        var reactData = [];

        // rows DESC -> 차트는 ASC
        if (rows && rows.length > 0) {
            for (var i = rows.length - 1; i >= 0; i--) {
                var r = rows[i] || {};
                labels.push(String(r.visitDt || ''));
                pcData.push(num(r.pcMainUv));
                reactData.push(num(r.reactMainUv));
            }
        }

        var canvas = document.getElementById('uvChart');
        if (!canvas) return;

        if (chart) {
            chart.destroy();
            chart = null;
        }

        chart = new Chart(canvas, {
            type: 'line',
            data: {
                labels: labels,
                datasets: [
                    { label: 'PC_MAIN UV', data: pcData, tension: 0.25 },
                    { label: 'REACT_MAIN UV', data: reactData, tension: 0.25 }
                ]
            },
            options: {
                responsive: true,

                // ✅ 여기: 그래프 영역 자체에 패딩 주기 (왼쪽 딱 붙는 느낌 완화)
                layout: {
                    padding: {
                        left: 14,
                        right: 10,
                        top: 6,
                        bottom: 6
                    }
                },

                plugins: {
                    legend: {
                        display: true,
                        labels: {
                            padding: 12
                        }
                    }
                },

                scales: {
                    x: {
                        // ✅ 핵심: 카테고리 축 양끝 여백
                        offset: true,
                        ticks: {
                            padding: 8
                        }
                    },
                    y: {
                        beginAtZero: true,
                        ticks: {
                            padding: 8
                        }
                    }
                }
            }
        });
    }

    function applyStat(res) {
        var result = res && res.result ? res.result : null;
        if (!res || res.ok !== true || !result) {
            $('#tbodyRows').html('<tr><td colspan="4" class="text-center text-danger py-4">조회 실패</td></tr>');
            return;
        }

        var today = result.today || {};
        var sum = result.sum || {};
        var rows = result.rows || [];

        $('#todayPc').text(num(today.pcMainUv));
        $('#todayReact').text(num(today.reactMainUv));
        $('#todayTotal').text(num(today.totalUv));

        $('#sumPc').text(num(sum.pcMainUv));
        $('#sumReact').text(num(sum.reactMainUv));
        $('#sumTotal').text(num(sum.totalUv));

        renderChart(rows);
        renderTable(rows);
    }

    function loadStat() {
        var fromDt = $('#fromDt').val();
        var toDt = $('#toDt').val();

        $('#tbodyRows').html('<tr><td colspan="4" class="text-center text-muted py-4">조회 중...</td></tr>');

        $.ajax({
            url: '/api/adm/log/mainVisitStat',
            method: 'GET',
            dataType: 'json',
            data: { fromDt: fromDt, toDt: toDt }
        }).done(function (res) {
            applyStat(res);
        }).fail(function () {
            $('#tbodyRows').html('<tr><td colspan="4" class="text-center text-danger py-4">API 오류</td></tr>');
        });
    }

    $('#btnSearch').on('click', function () {
        loadStat();
    });

    setDefaultRangeIfEmpty();
    loadStat();
})();
</script>
