<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>

<!-- Toast UI Editor CSS/JS -->
<link rel="stylesheet" href="https://uicdn.toast.com/editor/latest/toastui-editor.min.css" />
<script src="https://uicdn.toast.com/editor/latest/toastui-editor-all.min.js"></script>

<section>
    <h2 class="mb-3">게시판 정의 <span id="pageTitle">수정</span></h2>

    <div class="mb-3">
        <button class="btn btn-primary" type="button" onclick="saveCmmnCodeCl()">저장</button>
		<c:if test="${not empty param.codeClId}">
	        <button class="btn btn-outline-danger" type="button" onclick="deleteCmmnCodeCl()">삭제</button>
	    </c:if>
        <a class="btn btn-outline-secondary" href="/sys/cmmnCodeCl/cmmnCodeClList">목록</a>
    </div>
 
    <form id="cmmnCodeClForm">
        <!-- PK 파라미터 (치환 대상) -->
        <input type="hidden" name="codeClId" id="codeClId" value="${param.codeClId}"/>

        <div class="form-group" style="max-width: 640px;">
            <label for="title">제목</label>
            <input type="text" class="form-control" name="title" id="title"/>
        </div>

        <div class="form-group" style="max-width: 840px;">
            <label for="content">내용</label>
            <!-- Toast UI Editor 영역 -->
            <div id="editor" style="height: 400px;"></div>
            <!-- 실제 DB 전송용 hidden input -->
            <input type="hidden" name="content" id="content"/>
        </div>
    </form>
</section>

<script>
    const API_BASE = '/api/sys/cmmnCodeCl';
    const PK = 'codeClId';
    let editor;

    $(document).ready(function () {
        // Toast UI Editor 초기화
        editor = new toastui.Editor({
            el: document.querySelector('#editor'),
            height: '400px',
            initialEditType: 'markdown',   
            previewStyle: 'vertical',  
            placeholder: '내용을 입력해주세요...'
        });

        const id = $("#" + PK).val();
        if (id && id !== "") {
            readCmmnCodeCl(id);
            $("#pageTitle").text("수정");
        } else {
            $("#pageTitle").text("등록");
        }
    });

    function readCmmnCodeCl(id) {
        const sendData = {};
        sendData[PK] = id;

        $.ajax({
            url: API_BASE + "/selectCmmnCodeClDetail",
            type: "post",
            contentType: "application/json",
            dataType: "json",
            data: JSON.stringify(sendData),
            success: function (map) {
                const result = map.result || map.cmmnCodeCl || map;
                if (!result) return;

                $("#title").val(result.title || "");
                editor.setHTML(result.content || ""); // Toast UI Editor에 값 넣기
            },
            error: function () {
                alert("조회 중 오류 발생");
            }
        });
    }

    function saveCmmnCodeCl() {
        const id = $("#" + PK).val();
        const url = id && id !== ""
            ? (API_BASE + "/updateCmmnCodeCl")
            : (API_BASE + "/insertCmmnCodeCl");

        if ($("#title").val() === "") {
            alert("제목을 입력해주세요.");
            return;
        }
        if (editor.getHTML().trim() === "") {
            alert("내용을 입력해주세요.");
            return;
        }

        // Editor 값 hidden input에 동기화
        $("#content").val(editor.getHTML());

        const formData = $("#cmmnCodeClForm").serializeObject();

        $.ajax({
            url: url,
            type: "post",
            contentType: "application/json",
            dataType: "json",
            data: JSON.stringify(formData),
            success: function () {
                location.href = "/sys/cmmnCodeCl/cmmnCodeClList";
            },
            error: function () {
                alert("저장 중 오류 발생");
            }
        });
    }

    function deleteCmmnCodeCl() {
        const id = $("#" + PK).val();
        if (!id || id === "") {
            alert("삭제할 대상의 PK가 없습니다.");
            return;
        }
        if (!confirm("정말 삭제하시겠습니까?")) return;

        const sendData = {};
        sendData[PK] = id;

        $.ajax({
            url: API_BASE + "/deleteCmmnCodeCl",
            type: "post",
            contentType: "application/json",
            dataType: "json",
            data: JSON.stringify(sendData),
            success: function () {
                alert("삭제 완료되었습니다.");
                location.href = "/sys/cmmnCodeCl/cmmnCodeClList";
            },
            error: function () {
                alert("삭제 중 오류 발생");
            }
        });
    }

    // serializeObject: 폼 → JSON
    $.fn.serializeObject = function () {
        let obj = {};
        const arr = this.serializeArray();
        $.each(arr, function () {
            obj[this.name] = this.value;
        });
        return obj;
    };
</script> 
