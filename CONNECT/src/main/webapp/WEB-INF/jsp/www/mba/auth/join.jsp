<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <title>회원가입 | CONNECT</title>
    <style>
        body {
            background:
                radial-gradient(1200px 420px at -5% -20%, #eef4ff 0%, transparent 45%),
                linear-gradient(180deg, #ffffff, #f8fafc 60%);
        }
        .signup-wrap {
            max-width: 880px;
            margin: 36px auto 80px;
            padding: 28px 28px 40px;
            background: #fff;
            border: 1px solid rgba(0, 0, 0, .06);
            border-radius: 18px;
            box-shadow: 0 8px 30px rgba(0, 0, 0, .06);
        }
        .section-heading { padding: 6px 4px 18px; margin: 0 0 18px; }
        .section-heading .title-gradient {
            margin: 0;
            font-weight: 800;
            line-height: 1.15;
            font-size: clamp(26px, 3.2vw, 34px);
            background: linear-gradient(90deg, #1d2430, #3a4e85 40%, #7a86ff 70%, #47d9c3 100%);
            -webkit-background-clip: text;
            background-clip: text;
            color: transparent;
            letter-spacing: .02em;
        }
        .section-heading .subtitle { margin: 8px 0 0; color: #6b778c; font-size: .95rem; }
        label { font-weight: 600; color: #3d4354; margin-bottom: 6px; }
        .form-control { height: 48px; border-radius: 12px; }
        .input-group > .form-control { border-top-right-radius: 0; border-bottom-right-radius: 0; }
        .input-group .btn { border-top-left-radius: 0; border-bottom-left-radius: 0; height: 48px; }
        .form-hint { margin-top: 6px; font-size: .86rem; color: #6b778c; }
        .feedback { margin-top: 6px; font-size: .86rem; }
        .feedback.ok { color: #18864b; }
        .feedback.warn { color: #b54708; }
        .feedback.err { color: #b42318; }
        .btn-primary { background: #0d6efd; border-color: #0d6efd; }
        .btn-primary:hover { background: #0b5ed7; border-color: #0b5ed7; }
        .btn-outline-primary { border-color: #0d6efd; color: #0d6efd; background: transparent; }
        .btn-outline-primary:hover { background: rgba(13, 110, 253, .06); }
        .btn-lg { padding: 10px 18px; border-radius: 12px; }
        .mb-16 { margin-bottom: 16px; }
        .mb-24 { margin-bottom: 24px; }
        .gap-12 { gap: 12px; }
    </style>
</head>
<body>
    <div class="signup-wrap container-fluid">
        <header class="section-heading">
            <h1 class="title-gradient">회원가입</h1>
            <p class="subtitle">간단한 정보만 입력하면 바로 시작할 수 있어요.</p>
        </header>

        <!-- TB_USER 매핑: email, userNm, telno, password -->
        <form id="send-form" autocomplete="off">
            <input type="hidden" id="duplicateYn" value="N" />
            <input type="hidden" name="authType" value="U" />

            <div class="row mb-24">
                <div class="col-md-6">
                    <label for="userNm">이름</label>
                    <input type="text" class="form-control" id="userNm" name="userNm" placeholder="이름" />
                    <div id="nmFb" class="feedback"></div>
                </div>

                <div class="col-md-6">
                    <label for="telno">전화번호 (선택)</label>
                    <input type="text" class="form-control" id="telno" name="telno" placeholder="010-1234-5678" />
                    <div class="form-hint">하이픈 포함/미포함 모두 가능</div>
                </div>
            </div>

            <div class="row mb-24">
                <div class="col-md-8">
                    <label for="email">이메일</label>
                    <div class="input-group">
                        <input type="email" class="form-control" id="email" name="email" placeholder="example@domain.com" />
                        <div class="input-group-append">
                            <button type="button" id="btn-dup" class="btn btn-outline-primary" onclick="duplicateEmail()">중복체크</button>
                        </div>
                    </div>
                    <div id="emailFb" class="feedback"></div>
                    <div class="form-hint">로그인 ID로 사용됩니다.</div>
                </div>  
            </div>

            <div class="row mb-24"> 
                <div class="col-md-6 mb-16">
                    <label for="passwordHash">비밀번호</label>
                    <input type="password" class="form-control" id="passwordHash" name="passwordHash" placeholder="8자 이상(영문/숫자/특수문자 2종 이상)" />
                    <div id="pwFb" class="feedback"></div>
                </div>

                <div class="col-md-6">
                    <label for="passwordConfirm">비밀번호 확인</label>
                    <input type="password" class="form-control" id="passwordConfirm" name="passwordConfirm" placeholder="비밀번호 확인" />
                    <div id="pw2Fb" class="feedback"></div>
                </div>
            </div>

            <div class="d-flex gap-12">
                <button type="button" id="btn-join" class="btn btn-primary btn-lg px-4" onclick="insert()">회원가입</button>
                <button type="button" class="btn btn-outline-primary btn-lg" onclick="goLink('/mba/auth/login')">로그인으로</button>
            </div>
        </form>
    </div>

    <script>
        /* ---------------- helpers ---------------- */
        $.fn.serializeObject = function () {
            var o = {};
            var a = this.serializeArray();

            $.each(a, function () {
                o[this.name] = this.value;
            });

            return o;
        };

        if (typeof goLink !== "function") {
            function goLink(p) {
                location.href = p;
            }
        }

        /* ---------------- validators ---------------- */
        function checkEmail(v) {
            var re = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
            return re.test(v);
        }

        function checkPw(v) {
            if (!v || v.length < 8) {
                return false;
            }

            var c1 = /[A-Za-z]/.test(v);
            var c2 = /[0-9]/.test(v);
            var c3 = /[^A-Za-z0-9]/.test(v);
            var score = (c1 ? 1 : 0) + (c2 ? 1 : 0) + (c3 ? 1 : 0);

            return score >= 2;
        }

        function setBtnBusy($btn, busy) {
            if (busy) {
                $btn.prop("disabled", true).data("txt", $btn.text()).text("처리중...");
            } else {
                $btn.prop("disabled", false).text($btn.data("txt") || $btn.text());
            }
        }

        /* ---------------- duplicate email ---------------- */
        function duplicateEmail() {
            var v = $("#email").val();

            if (v === "") {
                alert("이메일을 입력해주세요.");
                $("#email").focus();
                return;
            }

            if (!checkEmail(v)) {
                $("#emailFb").removeClass().addClass("feedback err").text("이메일 형식을 확인해주세요.");
                $("#email").focus();
                return;
            }

            setBtnBusy($("#btn-dup"), true);

            $.ajax({
                url: "/api/auth/duplicateId", 
                type: "post",
                contentType: "application/json;charset=utf-8",
                dataType: "json",
                data: JSON.stringify({ email: v }),
                success: function (map) {
                    if (map && map.result && map.result.cnt > 0) {
                        $("#duplicateYn").val("N");
                        $("#emailFb").removeClass().addClass("feedback err").text("이미 사용 중인 이메일입니다.");
                    } else {
                        $("#duplicateYn").val("Y");
                        $("#emailFb").removeClass().addClass("feedback ok").text("사용 가능한 이메일입니다.");
                    }
                },
                error: function () {
                    $("#emailFb").removeClass().addClass("feedback err").text("중복확인 중 오류가 발생했습니다.");
                },
                complete: function () {
                    setBtnBusy($("#btn-dup"), false);
                }
            });
        }

        /* ---------------- inline feedback ---------------- */
        $("#email").on("blur", function () {
            if ($(this).val()) {
                duplicateEmail();
            }
        });

        $("#passwordHash").on("input", function () {
            var v = $(this).val();

            if (!v) {
                $("#pwFb").removeClass().addClass("feedback").text("");
                return;
            }

            if (checkPw(v)) {
                $("#pwFb").removeClass().addClass("feedback ok").text("안전한 비밀번호입니다.");
            } else {
                $("#pwFb").removeClass().addClass("feedback warn").text("8자 이상, 영문/숫자/특수문자 2종 이상 권장");
            }
        });

        $("#passwordConfirm").on("input", function () {
            var ok = $("#passwordHash").val() && $("#passwordHash").val() === $(this).val();
            $("#pw2Fb").removeClass().addClass("feedback " + (ok ? "ok" : "warn")).text(ok ? "비밀번호가 일치합니다." : "비밀번호가 일치하지 않습니다.");
        });

        $("#userNm").on("blur", function () { 
            var v = $(this).val();
            $("#nmFb").removeClass().addClass("feedback " + (v ? "ok" : "warn")).text(v ? "" : "이름을 입력해주세요.");
        });

        /* ---------------- submit ---------------- */
        function insert() {
            if ($("#userNm").val() === "") {
                alert("이름을 입력해주세요.");
                $("#userNm").focus();
                return;
            }

            if ($("#email").val() === "") {
                alert("이메일을 입력해주세요.");
                $("#email").focus();
                return;
            }

            if (!checkEmail($("#email").val())) {
                alert("이메일 형식을 확인해주세요.");
                $("#email").focus();
                return;
            }

            if ($("#passwordHash").val() === "") {
                alert("비밀번호를 입력해주세요.");
                $("#passwordHash").focus();
                return;
            }

            if (!checkPw($("#passwordHash").val())) {
                alert("8자 이상, 영문/숫자/특수문자 2종 이상 조합을 권장합니다.");
                $("#passwordHash").focus();
                return;
            }

            if ($("#passwordConfirm").val() === "") {
                alert("비밀번호 확인을 입력해주세요.");
                $("#passwordConfirm").focus();
                return;
            }

            if ($("#passwordHash").val() !== $("#passwordConfirm").val()) {
                alert("비밀번호가 일치하지 않습니다.");
                $("#passwordConfirm").focus();
                return;
            }

            if ($("#duplicateYn").val() !== "Y") {
                var cont = confirm("이메일 중복체크가 완료되지 않았습니다. 계속하시겠습니까?");
                if (!cont) {
                    return;
                }
            }

            var data = $("#send-form").serializeObject();

            setBtnBusy($("#btn-join"), true);

            $.ajax({
                url: "/api/auth/insertJoin",
                type: "post",
                contentType: "application/json;charset=utf-8",
                dataType: "json",
                data: JSON.stringify(data),
                success: function () {
                    alert("회원가입이 완료되었습니다.");
                    goLink("/mba/auth/login");
                },
                error: function () {
                    alert("회원가입 중 오류가 발생했습니다.");
                },
                complete: function () {
                    setBtnBusy($("#btn-join"), false);
                }
            });
        }
    </script>
</body>
</html>