<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
	<title>게시판 상세</title>
	<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
</head>
<body>
	<h2>게시판 상세</h2>

	<form id="boardForm">
		<input type="hidden" name="boardIdx" id="boardIdx" value="${param.boardIdx}"/>

		<table border="1" width="100%">
			<tr>
				<th>제목</th>
				<td><input type="text" name="title" id="title" value=""/></td>
			</tr>
			<tr>
				<th>내용</th>
				<td><textarea name="content" id="content" rows="10" cols="60"></textarea></td>
			</tr>
			<tr>
				<th>작성자</th>
				<td><input type="text" name="createUser" id="createUser" value=""/></td>
			</tr>
		</table>
	</form>

	<br/>
	<button onclick="saveBoard()">저장</button>
	<button onclick="deleteBoard()">삭제</button>
	<button onclick="goList()">목록</button>

	<script type="text/javascript">
		$(document).ready(function(){
			var boardIdx = $("#boardIdx").val();
			if(boardIdx){
				selectBoardDetail(boardIdx);
			}
		});

		function selectBoardDetail(boardIdx){
			$.ajax({
				url: "/api/board/selectBoardDetail",
				type: "post",
				contentType: "application/json",
				data: JSON.stringify({ boardIdx: boardIdx }),
				success: function(map){
					var data = map.result;
					$("#title").val(data.title);
					$("#content").val(data.content);
					$("#createUser").val(data.createUser);
				},
				error: function(request, status, error){
					alert("상세 조회 실패");
				}
			});
		}

		function saveBoard(){
			var sendData = {
				boardIdx: $("#boardIdx").val(),
				title: $("#title").val(),
				content: $("#content").val(),
				createUser: $("#createUser").val()
			};

			var url = sendData.boardIdx ? "/api/board/updateBoard" : "/api/board/insertBoard";

			$.ajax({
				url: url,
				type: "post",
				contentType: "application/json",
				data: JSON.stringify(sendData),
				success: function(map){
					alert("저장되었습니다.");
					goList();
				},
				error: function(request, status, error){
					alert("저장 실패");
				}
			});
		}

		function deleteBoard(){
			var boardIdx = $("#boardIdx").val();
			if(!boardIdx){
				alert("삭제할 데이터가 없습니다.");
				return;
			}
			if(!confirm("삭제하시겠습니까?")) return;

			$.ajax({
				url: "/api/board/deleteBoard",
				type: "post",
				contentType: "application/json",
				data: JSON.stringify({ boardIdx: boardIdx }),
				success: function(map){
					alert("삭제되었습니다.");
					goList();
				},
				error: function(request, status, error){
					alert("삭제 실패");
				}
			});
		}

		function goList(){
			location.href = "BoardList.jsp";
		}
	</script>
</body>
</html>