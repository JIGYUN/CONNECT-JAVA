<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<html>
<head>
	<title>게시판 목록</title>
	<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
	<style>
		table {
			width: 100%;
			border-collapse: collapse;
		}
		th, td {
			border: 1px solid #ccc;
			padding: 8px;
			text-align: left;
		}
		th {
			background-color: #f2f2f2;
		}
	</style>
</head>
<body>
	<h2>📋 게시판 목록</h2>

	<table>
		<thead>
			<tr>
				<th>번호</th>
				<th>제목</th>
				<th>작성자</th>
				<th>작성일</th>
				<th>삭제</th>
			</tr>
		</thead>
		<tbody id="boardListBody">
			<!-- 목록 비동기로 로딩됨 -->
		</tbody>
	</table>

	<script>
		$(document).ready(function() {
			selectBoardList();
		});

		function selectBoardList() {
			$.ajax({
				url: '/api/board/selectBoardList',
				type: 'POST',
				contentType: 'application/json',
				data: JSON.stringify({}),
				success: function(response) {
					var list = response.resultList;
					var tbody = $("#boardListBody");
					tbody.empty();

					if (list.length === 0) {
						tbody.append("<tr><td colspan='5'>데이터가 없습니다.</td></tr>");
					} else {
						list.forEach(function(item, index) {
							var row = "<tr>";
							row += "<td>" + (index + 1) + "</td>";
							row += "<td><a href='/board/view.jsp?BOARD_IDX=" + item.BOARD_IDX + "'>" + item.TITLE + "</a></td>";
							row += "<td>" + item.CREATE_USER + "</td>";
							row += "<td>" + item.CREATE_DATE + "</td>";
							row += "<td><button onclick='deleteBoard(" + item.BOARD_IDX + ")'>삭제</button></td>";
							row += "</tr>";
							tbody.append(row);
						});
					}
				},
				error: function() {
					alert("목록 조회 실패");
				}
			});
		}

		function deleteBoard(idx) {
			if (!confirm("정말 삭제하시겠습니까?")) return;

			$.ajax({
				url: '/api/board/deleteBoard',
				type: 'POST',
				contentType: 'application/json',
				data: JSON.stringify({ BOARD_IDX: idx }),
				success: function(response) {
					alert("삭제되었습니다.");
					selectBoardList();
				},
				error: function() {
					alert("삭제 실패");
				}
			});
		}
	</script>
</body>
</html>