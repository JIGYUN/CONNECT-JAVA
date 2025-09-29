<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>

<section>
    <h2 class="mb-3">가게부 수정</h2>

    <div class="mb-3">
        <button class="btn btn-primary" type="button" onclick="saveHousehold()">저장</button>
        <button class="btn btn-outline-danger" type="button" onclick="deleteHousehold()">삭제</button>
        <a class="btn btn-outline-secondary" href="/hhd/household/householdList">목록</a>
    </div>

    <form id="householdForm">
        <!-- PK 파라미터 (치환 대상) -->
        <input type="hidden" name="householdIdx" id="householdIdx" value="${param.householdIdx}"/>

        <div class="form-group" style="max-width: 640px;">
            <label for="title">제목</label>
            <input type="text" class="form-control" name="title" id="title"/>
        </div>

        <div class="form-group" style="max-width: 840px;">
            <label for="content">내용</label>
            <textarea class="form-control" name="content" id="content" rows="10"></textarea>
        </div>
    </form>
</section>

<script>
    /* ===== 치환 토큰 =====
       - hhd: 비즈 세그먼트
       - Household/household: 서비스명
       - householdIdx: householdIdx 등
    */
    const API_BASE = '/api/hhd/household';
    const PK = 'householdIdx';

    $(document).ready(function () {
        const id = $("#" + PK).val();
        if (id && id !== "") {
            readHousehold(id);
        }
    });

    function readHousehold(id) {
        const sendData = {};
        sendData[PK] = id;

        $.ajax({
            url: API_BASE + "/selectHouseholdDetail",
            type: "post",
            contentType: "application/json",
            dataType: "json",
            data: JSON.stringify(sendData),
            success: function (map) {
                const result = map.result || map.household || map;
                if (!result) return;

                $("#title").val(result.title || "");
                $("#content").val(result.content || "");
                $("#createUser").val(result.createUser || "");
            },
            error: function () {
                alert("조회 중 오류 발생");
            }
        });
    }

    function saveHousehold() {
        const id = $("#" + PK).val();
        const url = id && id !== ""
            ? (API_BASE + "/updateHousehold")
            : (API_BASE + "/insertHousehold");

        if ($("#title").val() === "") {
            alert("제목을 입력해주세요.");
            return;
        }
        if ($("#content").val() === "") {
            alert("내용을 입력해주세요.");
            return;
        }

        const formData = $("#householdForm").serializeObject();

        $.ajax({
            url: url,
            type: "post",
            contentType: "application/json",
            dataType: "json",
            data: JSON.stringify(formData),
            success: function () {
                location.href = "/hhd/household/householdList";
            },
            error: function () {
                alert("저장 중 오류 발생");
            }
        });
    }

    function deleteHousehold() {
        const id = $("#" + PK).val();
        if (!id || id === "") {
            alert("삭제할 대상의 PK가 없습니다.");
            return;
        }
        if (!confirm("정말 삭제하시겠습니까?")) return;

        const sendData = {};
        sendData[PK] = id;

        $.ajax({
            url: API_BASE + "/deleteHousehold",
            type: "post",
            contentType: "application/json",
            dataType: "json",
            data: JSON.stringify(sendData),
            success: function () {
                alert("삭제 완료되었습니다.");
                location.href = "/hhd/household/householdList";
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
