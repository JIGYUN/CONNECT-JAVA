<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8"/>
    <title>로그인 | CONNECT</title>

    <style>
        /* ─────────────────────────── 배경 ─────────────────────────── */
        .auth-shell{
            min-height:100vh;
            display:flex;
            align-items:flex-start;
            justify-content:center;
            padding-top: clamp(48px, 9vh, 108px);
            background:
                radial-gradient(1000px 400px at 10% -10%, #e7f1ff 0%, transparent 55%),
                radial-gradient(800px 300px at 100% 10%, #fff2f2 0%, transparent 50%),
                linear-gradient(180deg, #ffffff, #f7f9fb 60%);
        }
        /* 카드 */
        .auth-shell .glass-card{
            background:rgba(255,255,255,.85);
            backdrop-filter:blur(10px);
            border:1px solid rgba(255,255,255,.5);
            border-radius:1.25rem;
            box-shadow:0 10px 30px rgba(0,0,0,.06);
        }
        .auth-shell .brand{ font-weight:800; letter-spacing:.06em; }
        .auth-shell .form-control{ width:100%; height:48px; border-radius:.75rem; padding:0 12px; border:1px solid #dfe3ea; }
        .auth-shell .btn{ height:44px; border-radius:.75rem; width:100%; cursor:pointer; }
        .auth-shell .btn-primary{ background:#0d6efd; border:1px solid #0d6efd; color:#fff; }
        .auth-shell .btn-primary:hover{ background:#0b5ed7; border-color:#0b5ed7; }
        .auth-shell .btn-ghost{ border:1px solid rgba(13,110,253,.35); color:#0d6efd; background:#fff; }
        .auth-shell .btn-ghost:hover{ background:rgba(13,110,253,.06); }
        .auth-shell .help-error{ color:#dc3545; font-size:.9rem; }
        .auth-shell .divider{ display:flex; align-items:center; gap:12px; color:#8a95a6; margin:12px 0 10px; }
        .auth-shell .divider .line{ height:1px; background:linear-gradient(90deg, transparent, #e6ebf2, transparent); flex:1; }
        .auth-shell #googleWrap{ width:100%; }
        .auth-shell #googleBtn{
            width:100%; height:44px; border-radius:.75rem; border:1px solid #dfe3ea; background:#fff;
            display:flex; align-items:center; justify-content:center; gap:10px; color:#444; text-decoration:none;
        }
        .auth-shell #googleBtn:hover{ box-shadow:0 4px 14px rgba(0,0,0,.08); }
        .auth-shell #googleIcon{ width:18px; height:18px; display:inline-block;
            background-image:url('https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg'); background-size:cover; }
        @media (min-width:576px){ .auth-shell .glass-card{ max-width:420px; margin:0 auto; margin-top:50px;} }
        @media (max-width:575.98px){ .auth-shell{ padding-top:40px; } }
        .mb-1{ margin-bottom:.25rem; } .mb-2{ margin-bottom:.5rem; } .mb-3{ margin-bottom:1rem; } .mb-4{ margin-bottom:1.5rem; }
        .p-4{ padding:1.5rem; } .p-md-5{ padding:2rem; } .h4{ font-size:1.25rem; }
        .text-muted{ color:#6c757d; } .w-100{ width:100%; }
        .container{ width:100%; max-width:1140px; padding:0 12px; }
        .row{ display:flex; justify-content:center; }
        .col{ width:100%; max-width:480px; }
        label{ display:block; margin-bottom:.25rem; color:#374151; font-size:.9rem; }
    </style>
</head>
<body>

<div class="auth-shell">
    <div class="container">
        <div class="row">
            <div class="col">
                <div class="glass-card p-4 p-md-5">
                    <h1 class="brand h4 mb-1" id="brandTitle">CONNECT</h1>
                    <p class="text-muted mb-4" id="brandSub">계정에 로그인하세요</p>

                    <!-- action/hidden 값은 스크립트에서 /adm 여부에 따라 설정 -->
                    <form id="frm" method="post" action="" autocomplete="off" novalidate>
                        <input type="hidden" name="loginType" id="loginType" value=""/>

                        <div class="form-group mb-3">
                            <label for="mberId">아이디</label>
                            <input type="text" class="form-control" id="mberId" name="mberId" placeholder="아이디"/>
                        </div>

                        <div class="form-group mb-2">
                            <label for="mberPw">비밀번호</label>
                            <input type="password" class="form-control" id="mberPw" name="mberPw" placeholder="비밀번호"/>
                        </div>

                        <c:if test="${param.failYn == 'Y'}">
                            <div class="help-error mb-2">입력하신 회원정보를 찾을 수 없습니다.</div>
                        </c:if>

                        <button type="button" class="btn btn-primary w-100 mb-2" id="loginBtn">Login</button>

                        <div class="divider">
                            <span class="line"></span><span>또는</span><span class="line"></span>
                        </div>

                        <!-- Google Sign-In -->
                        <div id="googleWrap" class="mb-3">
                            <a id="googleBtn" href="#" rel="nofollow">
                                <span id="googleIcon" aria-hidden="true"></span>
                                <span>Sign in with Google</span>
                            </a>
                        </div>

                        <button type="button" class="btn btn-ghost w-100" id="joinBtn">회원가입</button>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>
 
<script>
    (function () {
        var isAdmin = location.pathname.indexOf('/adm/') === 0;

        // 처리 URL과 loginType 분기 (시큐리티 filterProcessesUrl과 반드시 일치)
        var action = isAdmin ? '/adm/mba/auth/loginProc' : '/com/auth/loginProc';
        var type   = isAdmin ? 'ADMIN' : 'BASIC';

        document.getElementById('frm').setAttribute('action', action);
        document.getElementById('loginType').value = type;

        // 헤더/부가 버튼 분기
        if (isAdmin) {
            document.getElementById('brandSub').textContent = '관리자 계정으로 로그인하세요';
            // 관리영역에선 회원가입 버튼 숨김
            document.getElementById('joinBtn').style.display = 'none';
            // (필요 시) 구글 SSO 경로도 어드민 전용으로 바꾸고 싶다면 아래 사용
            // document.getElementById('googleBtn').setAttribute('href', '/adm/mba/auth/google/start');
        } else {
            document.getElementById('googleBtn').setAttribute('href', '/com/auth/google/start');
            document.getElementById('joinBtn').addEventListener('click', function(){
                location.href = '/mba/auth/join';
            });
        }

        // 로그인 버튼
        document.getElementById('loginBtn').addEventListener('click', goLogin);

        // Enter 제출
        var pw = document.getElementById('mberPw');
        if (pw) {
            pw.addEventListener('keydown', function(e){
                if (e.key === 'Enter' || e.keyCode === 13) goLogin();
            });
        }

        function goLogin(){
            var id = document.getElementById('mberId').value.trim();
            var pw = document.getElementById('mberPw').value;

            if (!id) { alert('아이디를 입력해주세요.'); return; }
            if (!pw) { alert('비밀번호를 입력해주세요.'); return; }

            // POST 전송 (필터는 postOnly=true)
            document.getElementById('frm').submit();
        }
    })();
</script>
</body>
</html>  