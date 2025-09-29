<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <title>회원가입 | CONNECT</title>

    <style>
        /* ---- Page Background (subtle, premium) ---- */
        body{
            background:
                radial-gradient(1200px 420px at -5% -20%, #eef4ff 0%, transparent 45%),
                linear-gradient(180deg, #ffffff, #f8fafc 60%);
        }

        /* ---- Elegant Section Heading ---- */
        .section-heading{
            padding: 28px 24px 20px;
            margin: 16px 0 24px;
            position: relative;
        }
        .section-heading .eyebrow{
            display: inline-block;
            font-size: .78rem;
            letter-spacing: .16em;
            font-weight: 600;
            color: #7382a3;
            text-transform: uppercase;
            margin-bottom: 6px;
        }
        .section-heading .title-gradient{
            margin: 0;
            font-weight: 800;
            line-height: 1.15;
            font-size: clamp(26px, 3.2vw, 36px);
            background: linear-gradient(90deg, #1d2430, #3a4e85 40%, #7a86ff 70%, #47d9c3 100%);
            -webkit-background-clip: text;
            background-clip: text;
            color: transparent;
            letter-spacing: .02em;
        }
        .section-heading::after{
             display: none;   /* or content: none; */  
        }
        .section-heading .subtitle{
            margin: 10px 0 0;
            color: #6b778c;
            font-size: .96rem;
        }

        /* ---- Form Area (full-width, clean) ---- */
        .form-wrap{
            width: 100%;
            padding: 32px 24px 56px;
        }

        .form-control{
            height: 48px;
            border-radius: 12px;
        }
        .input-group > .form-control{
            border-top-right-radius: 0;
            border-bottom-right-radius: 0;
        }
        .input-group .btn{
            border-top-left-radius: 0;
            border-bottom-left-radius: 0;
            height: 48px;
        }

        .btn-primary{ background:#0d6efd; border-color:#0d6efd; }
        .btn-primary:hover{ background:#0b5ed7; border-color:#0b5ed7; }
        .btn-outline-primary{ border-color:#0d6efd; color:#0d6efd; background:transparent; }
        .btn-outline-primary:hover{ background:rgba(13,110,253,.06); }

        .mb-24{ margin-bottom:24px; }
        .gap-12{ gap:12px; }
        @media (min-width: 768px){
            .px-md-48{ padding-left:48px; padding-right:48px; }
        }
    </style>
</head>
<body>

    <!-- Elegant Heading (no hero box) -->
    <header class="section-heading container-fluid px-md-48">
       <!--  <span class="eyebrow">ACCOUNT</span> -->
        <h1 class="title-gradient">회원가입</h1>
        <p class="subtitle">간단한 정보만 입력하면 바로 시작할 수 있어요.</p>
    </header>
   
    <!-- Full-width form -->
    <div class="container-fluid form-wrap px-md-48">
        <form id="send-form" autocomplete="off">
            <input type="hidden" id="duplicateYn" name="duplicateYn" value="N" />

            <!-- 이름 / 이메일 -->
            <div class="row mb-24">
                <div class="col-md-6 mb-24">
                    <label for="mberNm">이름</label>
                    <input type="text" class="form-control" id="mberNm" name="mberNm" placeholder="이름" />
                </div>
<!--                 <div class="col-md-6 mb-24">
                    <label for="email">이메일</label>
                    <input type="text" class="form-control" id="email" name="email" placeholder="이메일" />
                </div> -->
            </div>

            <!-- 아이디 + 중복체크 -->
            <div class="row mb-24">
                <div class="col-md-6">
                    <label for="id">아이디</label>
                    <div class="input-group">  
                        <input type="text" class="form-control" id="id" name="id" placeholder="이메일을 입력해주세요" />
                        <div class="input-group-append">
                            <button type="button" class="btn btn-outline-primary" onclick="duplicateId()">아이디 중복체크</button>
                        </div>
                    </div>
                </div>
            </div>

            <!-- 비밀번호 / 확인 -->
            <div class="row mb-24">
                <div class="col-md-6 mb-24">
                    <label for="password">비밀번호</label>
                    <input type="password" class="form-control" id="password" name="password" placeholder="비밀번호" />
                </div>
                <div class="col-md-6 mb-24">
                    <label for="passwordConfirm">비밀번호 확인</label>
                    <input type="password" class="form-control" id="passwordConfirm" name="passwordConfirm" placeholder="비밀번호 확인" />
                </div>
            </div>

            <div class="d-flex gap-12">
                <button type="button" class="btn btn-primary btn-lg px-4" onclick="insert()">회원가입</button>
                <button type="button" class="btn btn-outline-primary btn-lg" onclick="goLink('/mba/auth/login')">로그인으로</button>
            </div>
        </form>
    </div>

    <script>
        function duplicateId() {
            if ($("#id").val() === "") {
                alert("아이디를 입력해주세요.");
                $("#id").focus();
                return;
            }
            var formData = { id: $("#id").val() };
            $.ajax({
                url: "/api/auth/duplicateId",
                type: "post",
                contentType: "application/json;charset=utf-8",
                dataType: "json",
                data: JSON.stringify(formData),
                success: function (map) {
                    if (map.result && map.result.cnt > 0) {
                        alert("이미 사용중인 아이디 입니다.");
                        $("#duplicateYn").val("N");
                    } else {
                        alert("사용가능한 아이디 입니다.");
                        $("#duplicateYn").val("Y");
                    }
                },
                error: function () {
                    alert("중복확인 중 오류가 발생했습니다.");
                }
            });
        }

        function insert() {
            if ($("#id").val() === "") {
                alert("아이디를 입력해주세요.");
                $("#id").focus();
                return;
            }
            if (typeof checkId === "function" && !checkId($("#id").val())) {
                alert("6-12자의 영문, 숫자, 기호(- _ )만 사용 가능합니다.");
                $("#id").focus();
                return;
            }
            if ($("#password").val() === "") {
                alert("비밀번호를 입력해주세요.");
                $("#password").focus();
                return;
            }
            if (typeof checkPw === "function" && !checkPw($("#password").val())) {
                alert("8자리 이상, 영문 대/소문자, 특수문자, 숫자를 조합해서 입력해주세요.");
                $("#password").focus();
                return;
            }
            if ($("#passwordConfirm").val() === "") {
                alert("비밀번호 확인을 입력해주세요.");
                $("#passwordConfirm").focus();
                return;
            }
            if ($("#password").val() !== $("#passwordConfirm").val()) {
                alert("비밀번호가 일치하지 않습니다.");
                $("#passwordConfirm").focus();
                return;
            }
            if ($("#duplicateYn").val() !== "Y") {
                if (!confirm("아이디 중복체크가 완료되지 않았습니다. 계속하시겠습니까?")) return;
            }

            var formData = $("#send-form").serializeObject();
            $.ajax({
                url: "/api/auth/insertJoin",
                type: "post",
                contentType: "application/json;charset=utf-8",
                dataType: "json",
                data: JSON.stringify(formData),
                success: function () {
                    alert("회원가입이 완료되었습니다.");
                    goLink("/mba/auth/login");
                },
                error: function () {
                    alert("회원가입 중 오류가 발생했습니다.");
                }
            });
        }

        // serializeObject helper
        $.fn.serializeObject = function () {
            var obj = {}, arr = this.serializeArray();
            $.each(arr, function () { obj[this.name] = this.value; });
            return obj;
        };

        // fallback for goLink if not provided globally
        if (typeof goLink !== "function") {
            function goLink(path) { location.href = path; }
        }
    </script>
</body>
</html>  