<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>

<!-- Toast UI Editor CSS/JS -->
<link rel="stylesheet" href="https://uicdn.toast.com/editor/latest/toastui-editor.min.css" />
<script src="https://uicdn.toast.com/editor/latest/toastui-editor-all.min.js"></script>


<section>
    <h2 class="mb-3">테스트 <span id="pageTitle">수정</span></h2>

    <div class="mb-3">
        <button class="btn btn-primary" type="button" onclick="saveTestt()">저장</button>
        <c:if test="${not empty param.testtIdx}">
            <button class="btn btn-outline-danger" type="button" onclick="deleteTestt()">삭제</button>
        </c:if>
        <a class="btn btn-outline-secondary" href="/tst/testt/testtList">목록</a>
    </div>

    <form id="testtForm">
        <!-- PK 파라미터 (치환 대상) -->
        <input type="hidden" name="testtIdx" id="testtIdx" value="${param.testtIdx}"/>

        <div class="form-group" style="max-width: 640px;">
            <label for="grpCd">그룹코드</label>
            <input type="text" class="form-control" name="grpCd" id="grpCd"/>
        </div>

        <div class="form-group" style="max-width: 640px;">
            <label for="boardCd">게시판</label>
            <input type="text" class="form-control" name="boardCd" id="boardCd"/>
        </div>

        <div class="form-group" style="max-width: 640px;">
            <label for="categoryCd">카테고리</label>
            <input type="text" class="form-control" name="categoryCd" id="categoryCd"/>
        </div>

        <div class="form-group" style="max-width: 640px;">
            <label for="statusCd">상태</label>
            <input type="text" class="form-control" name="statusCd" id="statusCd"/>
        </div>

        <div class="form-group" style="max-width: 640px;">
            <label>공지</label>
            <div class="custom-control custom-checkbox">
                <input type="hidden" name="noticeAt" value="N"/>
                <input type="checkbox" class="custom-control-input" id="noticeAt_chk" name="noticeAt" value="Y"/>
                <label class="custom-control-label" for="noticeAt_chk">Y</label>
            </div>
        </div>

        <div class="form-group" style="max-width: 640px;">
            <label>고정</label>
            <div class="custom-control custom-checkbox">
                <input type="hidden" name="pinAt" value="N"/>
                <input type="checkbox" class="custom-control-input" id="pinAt_chk" name="pinAt" value="Y"/>
                <label class="custom-control-label" for="pinAt_chk">Y</label>
            </div>
        </div>

        <div class="form-group" style="max-width: 640px;">
            <label>비공개</label>
            <div class="custom-control custom-checkbox">
                <input type="hidden" name="secretAt" value="N"/>
                <input type="checkbox" class="custom-control-input" id="secretAt_chk" name="secretAt" value="Y"/>
                <label class="custom-control-label" for="secretAt_chk">Y</label>
            </div>
        </div>

        <div class="form-group" style="max-width: 640px;">
            <label for="title">제목</label>
            <input type="text" class="form-control" name="title" id="title"/>
        </div>

        <div class="form-group" style="max-width: 640px;">
            <label for="subTitle">부제목</label>
            <input type="text" class="form-control" name="subTitle" id="subTitle"/>
        </div>

        <div class="form-group" style="max-width: 840px;">
            <label for="summaryTxt">요약</label>
            <textarea class="form-control" name="summaryTxt" id="summaryTxt" rows="4"></textarea>
        </div>

        <div class="form-group" style="max-width: 960px;">
            <label for="contentHtml">내용</label>
            <div id="editor_contentHtml" style="height: 420px;"></div>
            <input type="hidden" name="contentHtml" id="contentHtml"/>
        </div>

        <div class="form-group" style="max-width: 640px;">
            <label for="tags">태그(콤마)</label>
            <input type="text" class="form-control" name="tags" id="tags"/>
        </div>

        <div class="form-group" style="max-width: 840px;">
            <label for="thumbUrl">썸네일URL</label>
            <input type="text" class="form-control" name="thumbUrl" id="thumbUrl"/>
        </div>

        <div class="form-group" style="max-width: 960px;">
            <label for="attachJson">첨부JSON</label>
            <textarea class="form-control" name="attachJson" id="attachJson" rows="6"></textarea>
        </div>

        <div class="form-group" style="max-width: 640px;">
            <label for="publishStartDt">노출시작</label>
            <input type="datetime-local" class="form-control" name="publishStartDt" id="publishStartDt"/>
        </div>

        <div class="form-group" style="max-width: 640px;">
            <label for="publishEndDt">노출종료</label>
            <input type="datetime-local" class="form-control" name="publishEndDt" id="publishEndDt"/>
        </div>

        <div class="form-group" style="max-width: 640px;">
            <label for="sortOrdr">정렬</label>
            <input type="number" class="form-control" name="sortOrdr" id="sortOrdr"/>
        </div>

        <div class="form-group" style="max-width: 640px;">
            <label for="placeNm">장소명</label>
            <input type="text" class="form-control" name="placeNm" id="placeNm"/>
        </div>

        <div class="form-group" style="max-width: 960px;">
            <label for="placeAddr">주소</label>
            <textarea class="form-control" name="placeAddr" id="placeAddr" rows="2"></textarea>
        </div>

        <div class="form-group" style="max-width: 640px;">
            <label for="lat">위도</label>
            <input type="number" class="form-control" name="lat" id="lat"/>
        </div>

        <div class="form-group" style="max-width: 640px;">
            <label for="lng">경도</label>
            <input type="number" class="form-control" name="lng" id="lng"/>
        </div>

        <div class="form-group" style="max-width: 640px;">
            <label>사용</label>
            <div class="custom-control custom-checkbox">
                <input type="hidden" name="useAt" value="N"/>
                <input type="checkbox" class="custom-control-input" id="useAt_chk" name="useAt" value="Y"/>
                <label class="custom-control-label" for="useAt_chk">Y</label>
            </div>
        </div>

        <div class="form-group" style="max-width: 640px;">
            <label for="createdBy">작성자</label>
            <input type="text" class="form-control" name="createdBy" id="createdBy"/>
        </div>

    </form>
</section>

<script>
    const API_BASE = '/api/tst/testt';
    const PK = 'testtIdx';

    const editors = {};

    $(document).ready(function () {

        editors['contentHtml'] = new toastui.Editor({
            el: document.querySelector('#editor_contentHtml'),
            height: '420px',
            initialEditType: 'markdown',
            previewStyle: 'vertical',
            placeholder: '내용을(를) 입력해주세요...'
        });


        const id = $("#" + PK).val();
        if (id && id !== "") {
            readTestt(id);
            $("#pageTitle").text("수정");
        } else {
            $("#pageTitle").text("등록");
        }
    });

    function readTestt(id) {
        const sendData = {};
        sendData[PK] = id;

        $.ajax({
            url: API_BASE + "/selectTesttDetail",
            type: "post",
            contentType: "application/json",
            dataType: "json",
            data: JSON.stringify(sendData),
            success: function (map) {
                const result = map.result || map.testt || map;
                if (!result) return;

                $('#grpCd').val(result.grpCd || "");
                $('#boardCd').val(result.boardCd || "");
                $('#categoryCd').val(result.categoryCd || "");
                $('#statusCd').val(result.statusCd || "");
                if ((result.noticeAt || "").toString().toUpperCase() === "Y") {
                    $('#noticeAt_chk').prop('checked', true);
                }
                if ((result.pinAt || "").toString().toUpperCase() === "Y") {
                    $('#pinAt_chk').prop('checked', true);
                }
                if ((result.secretAt || "").toString().toUpperCase() === "Y") {
                    $('#secretAt_chk').prop('checked', true);
                }
                $('#title').val(result.title || "");
                $('#subTitle').val(result.subTitle || "");
                $('#summaryTxt').val(result.summaryTxt || "");
                if (editors['contentHtml']) { editors['contentHtml'].setHTML(result.contentHtml || ""); }
                $('#tags').val(result.tags || "");
                $('#thumbUrl').val(result.thumbUrl || "");
                $('#attachJson').val(result.attachJson || "");
                $('#publishStartDt').val(result.publishStartDt || "");
                $('#publishEndDt').val(result.publishEndDt || "");
                $('#sortOrdr').val(result.sortOrdr || "");
                $('#placeNm').val(result.placeNm || "");
                $('#placeAddr').val(result.placeAddr || "");
                $('#lat').val(result.lat || "");
                $('#lng').val(result.lng || "");
                if ((result.useAt || "").toString().toUpperCase() === "Y") {
                    $('#useAt_chk').prop('checked', true);
                }
                $('#createdBy').val(result.createdBy || "");
            },
            error: function () {
                alert("조회 중 오류 발생");
            }
        });
    }

    function saveTestt() {
        const id = $("#" + PK).val();
        const url = id && id !== ""
            ? (API_BASE + "/updateTestt")
            : (API_BASE + "/insertTestt");

        if (($('#grpCd').val() || "").trim() === "") {
            alert("그룹코드을(를) 입력해주세요.");
            return;
        }

        if (($('#boardCd').val() || "").trim() === "") {
            alert("게시판을(를) 입력해주세요.");
            return;
        }

        if (($('#statusCd').val() || "").trim() === "") {
            alert("상태을(를) 입력해주세요.");
            return;
        }

        if (($('#title').val() || "").trim() === "") {
            alert("제목을(를) 입력해주세요.");
            return;
        }

        if (!editors['contentHtml'] || editors['contentHtml'].getHTML().trim() === "") {
            alert("내용을(를) 입력해주세요.");
            return;
        }


        $('#contentHtml').val(editors['contentHtml'].getHTML());

        const formData = $("#testtForm").serializeObject();

        $.ajax({
            url: url,
            type: "post",
            contentType: "application/json",
            dataType: "json",
            data: JSON.stringify(formData),
            success: function () {
                location.href = "/tst/testt/testtList";
            },
            error: function () {
                alert("저장 중 오류 발생");
            }
        });
    }

    function deleteTestt() {
        const id = $("#" + PK).val();
        if (!id || id === "") {
            alert("삭제할 대상의 PK가 없습니다.");
            return;
        }
        if (!confirm("정말 삭제하시겠습니까?")) return;

        const sendData = {};
        sendData[PK] = id;

        $.ajax({
            url: API_BASE + "/deleteTestt",
            type: "post",
            contentType: "application/json",
            dataType: "json",
            data: JSON.stringify(sendData),
            success: function () {
                alert("삭제 완료되었습니다.");
                location.href = "/tst/testt/testtList";
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
