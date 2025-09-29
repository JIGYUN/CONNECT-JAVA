<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<style>
	:root{
		--bg:#f6f8fb; --card:#ffffff; --line:#e9edf3; --text:#0f172a; --muted:#6b7280;
	}
	body{background:var(--bg);}
	.page-title{font-size:28px; font-weight:700; color:var(--text);}
	.toolbar{display:flex; gap:8px; margin:12px 0 18px;}
	.table-card{background:var(--card); border:1px solid var(--line); border-radius:16px; box-shadow:0 2px 8px rgba(15,23,42,.04);}
	.table{margin-bottom:0;}
	.table thead th{font-weight:700; color:#475569; background:#f3f5f8; border-bottom:1px solid var(--line);}
	.table tbody tr{cursor:pointer;}
	.table tbody tr:hover{background:#f9fbff;}
	.badge{border-radius:999px; font-weight:600; padding:.25rem .5rem;}
	.badge-yn{background:#eef2ff; color:#3730a3;}
	.code{font-family:ui-monospace,SFMono-Regular,Menlo,Monaco,Consolas,"Liberation Mono","Courier New",monospace; font-weight:600;}
	.btn{border-radius:12px;}
</style>

<section>
	<h2 class="page-title">게시판 정의 목록</h2>

	<div class="toolbar">
		<button class="btn btn-primary" type="button" onclick="goToBoardDefModify()">WRITE</button>
		<button class="btn btn-outline-secondary" type="button" onclick="goToBoardDef()">통합</button>
	</div>

	<div class="table-responsive table-card">
		<table class="table table-hover align-middle">
			<thead>
				<tr>
					<th style="width:90px;text-align:right;">ID</th>
					<th style="width:160px;">CODE</th>
					<th>NAME</th>
					<th style="width:180px;">SLUG</th>
					<th style="width:120px;">READ</th>
					<th style="width:120px;">WRITE</th>
					<th style="width:90px;">USE</th>
					<th style="width:200px;">CREATED</th>
				</tr>
			</thead>
			<tbody id="boardDefListBody">
				<tr><td colspan="8" class="text-center text-muted">Loading…</td></tr>
			</tbody>
		</table>
	</div>
</section>

<script>
	const API_BASE = '/api/brd/boardDef';
	const PK_PARAM = 'boardId';

	$(function(){ selectBoardDefList(); });

	function selectBoardDefList() {
		$.ajax({
			url: API_BASE + '/selectBoardDefList',
			type: 'post',
			contentType: 'application/json',
			data: JSON.stringify({}),
			success: function (map) {
				const list = map.result || map.rows || [];
				let html = '';

				if (!list.length) {
					html += "<tr><td colspan='8' class='text-center text-muted'>등록된 데이터가 없습니다.</td></tr>";
				} else {
					for (let i = 0; i < list.length; i++) {
						const r = list[i];
						const id   = r.boardId || r.BOARD_ID || r.id;
						const cd   = r.boardCd || r.BOARD_CD || '';
						const nm   = r.boardNm || r.BOARD_NM || '';
						const slug = r.slug || r.SLUG || '';
						const rlv  = r.readLvlCd || r.READ_LVL_CD || '';
						const wlv  = r.writeLvlCd || r.WRITE_LVL_CD || '';
						const use  = r.useAt || r.USE_AT || 'Y';
						let created = r.createdDt || r.CREATED_DT || r.createDate || '';

						if (created && typeof created === 'object') created = (created.value || String(created));

						html += "<tr onclick=\"goToBoardDefModify('" + (id || '') + "')\">";
						html += "  <td class='text-end'>" + (id || '') + "</td>";
						html += "  <td class='code'>" + cd + "</td>";
						html += "  <td>" + nm + "</td>";
						html += "  <td>/" + slug + "</td>";
						html += "  <td>" + rlv + "</td>";
						html += "  <td>" + wlv + "</td>";
						html += "  <td><span class='badge badge-yn'>" + use + "</span></td>";
						html += "  <td>" + (created || '') + "</td>";
						html += "</tr>";
					}
				}
				$('#boardDefListBody').html(html);
			},
			error: function () { 
				$('#boardDefListBody').html("<tr><td colspan='8' class='text-center text-danger'>목록 조회 중 오류</td></tr>");
			}
		});
	}

	function goToBoardDefModify(id) {
		let url = '/brd/boardDef/boardDefModify';
		if (id) url += '?' + PK_PARAM + '=' + encodeURIComponent(id);
		location.href = url;
	}
	function goToBoardDef() { location.href = '/brd/boardDef/boardDef'; }
</script>