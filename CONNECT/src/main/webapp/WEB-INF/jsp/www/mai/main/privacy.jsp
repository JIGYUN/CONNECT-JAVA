<%@ page contentType="text/html; charset=UTF-8" language="java" pageEncoding="UTF-8"%>
<!doctype html>
<html lang="ko">
<head>
    <meta charset="utf-8">
    <title>개인정보처리방침 | CONNECT</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <!-- 네가 쓰는 Bootstrap 4.6 기준 -->
    <link rel="stylesheet" href="/static/bootstrap-4.6.2.min.css">
    <style>
        body { font-family: -apple-system, BlinkMacSystemFont, "Apple SD Gothic Neo", Segoe UI, Roboto, "Noto Sans KR", "Malgun Gothic", sans-serif; }
        .container { max-width: 960px; }
        h1 { margin: 24px 0; }
        h2 { margin-top: 32px; font-size: 1.25rem; }
        .small { color:#666; }
        .card { border-radius: 12px; }
        .badge-sec { background:#f1f3f5; color:#333; border:1px solid #e9ecef; }
        table tr td{ vertical-align: top; }
        .mono { font-family: ui-monospace, Menlo, Consolas, monospace; }
        .muted { color:#6c757d; }
    </style>
</head>
<body>
<div class="container my-4">
    <h1 class="h3">개인정보처리방침</h1>
    <p class="small muted">
        시행일: <strong>2025-10-13</strong> &nbsp;|&nbsp;
        서비스명: <strong>CONNECT</strong> &nbsp;|&nbsp;
        서비스 URL: <a href="https://connectt.duckdns.org" target="_blank">https://connectt.duckdns.org</a>
    </p>

    <div class="card p-4 mb-4">
        <p>
            CONNECT(이하 “회사”)는 「개인정보 보호법」, 「정보통신망법」 등 관련 법령을 준수하며,
            이용자의 개인정보를 안전하게 보호하기 위해 다음과 같이 개인정보처리방침을 수립·공개합니다.
            본 방침은 웹사이트 및 안드로이드 애플리케이션(웹뷰 포함)에 공통 적용됩니다.
        </p>
    </div>

    <h2>1. 수집하는 개인정보 항목 및 수집방법</h2>
    <div class="mb-3">
        <ol>
            <li><b>회원가입/로그인</b> (선택 적용)
                <ul>
                    <li>필수: 이메일, 비밀번호, 닉네임</li>
                    <li>선택: 프로필 이미지</li>
                </ul>
            </li>
            <li><b>서비스 이용 시 자동수집</b>
                <ul>
                    <li>기기·브라우저 정보(모델명, OS/앱 버전, 사용자 에이전트), 접속 IP, 쿠키/세션, 방문/활동 로그, 오류 로그</li>
                    <li>(앱) 푸시 토큰(수신 동의 시), 딥링크 이벤트</li>
                </ul>
            </li>
            <li><b>문의/고객지원</b>: 이메일, 문의 내용 및 첨부파일</li>
            <li><b>파일 업로드 사용 시</b>: 사용자가 선택한 사진/파일의 메타데이터 일부</li>
        </ol>
        <p class="muted small">※ 수집항목은 기능 추가/변경에 따라 달라질 수 있으며, 회사는 변경 시 본 방침을 개정·고지합니다.</p>
    </div>

    <h2>2. 개인정보의 처리 목적</h2>
    <ul>
        <li>회원관리: 본인확인, 부정 이용 방지, 문의 응대</li>
        <li>서비스 제공: 컨텐츠 제공, 게시판/지도/파일 업로드 등 기능 운영</li>
        <li>안정화/품질: 로그·오류 분석, 성능 개선, 보안 모니터링</li>
        <li>고지·문의: 공지사항 전달, 정책 변경 안내</li>
        <li>(선택) 마케팅/알림: 푸시 알림·이벤트 안내(수신 동의 시)</li>
    </ul>

    <h2>3. 보유 및 이용 기간</h2>
    <table class="table table-bordered">
        <tbody>
        <tr>
            <td class="w-25"><b>회원정보</b></td>
            <td>탈퇴 시까지. 단, 관계 법령에 따른 보존이 필요한 경우 해당 기간 동안 보관</td>
        </tr>
        <tr>
            <td><b>로그/접속기록</b></td>
            <td>최대 1년(보안/품질 목적). 법령상 보존 요구 시 그 기간</td>
        </tr>
        <tr>
            <td><b>문의/지원 기록</b></td>
            <td>처리 완료 후 3년</td>
        </tr>
        <tr>
            <td><b>쿠키</b></td>
            <td>브라우저 설정 또는 앱 재설치/캐시 삭제 시까지</td>
        </tr>
        </tbody>
    </table>

    <h2>4. 제3자 제공</h2>
    <p>회사는 이용자의 개인정보를 원칙적으로 외부에 제공하지 않습니다. 다만, 법령에 근거가 있거나 수사기관의 적법한 요청이 있는 경우 제공할 수 있습니다.</p>

    <h2>5. 처리의 위탁</h2>
    <p>회사는 서비스 운영을 위해 다음 업무를 위탁할 수 있습니다.</p>
    <table class="table table-sm">
        <thead><tr><th>수탁업체</th><th>위탁업무</th><th>보관국가</th></tr></thead>
        <tbody>
        <tr><td>호스팅/IaaS (예: Oracle/Naver Cloud)</td><td>서버·네트워크 인프라 운영</td><td>대한민국 또는 선택한 리전</td></tr>
        <tr><td>CDN/메일/알림(선택)</td><td>정적자원 전송, 메일/푸시 발송</td><td>사업자 리전</td></tr>
        </tbody>
    </table>
    <p class="small muted">※ 실제 사용중인 수탁업체가 있다면 실명·연락처·위탁 범위를 구체적으로 기입하세요.</p>

    <h2>6. 국외이전(해당 시)</h2>
    <p>국외 리전에 서버/분석·CDN 서비스를 이용하는 경우, 개인정보가 해당 국가로 이전·보관될 수 있습니다. 이전되는 항목, 국가, 일시, 보관기간, 보호조치를 명시합니다. (해당 없으면 “없음”으로 표기)</p>

    <h2>7. 이용자의 권리 및 행사 방법</h2>
    <ul>
        <li>이용자는 회사에 대해 개인정보 열람·정정·삭제·처리정지·동의철회를 요구할 수 있습니다.</li>
        <li>앱/웹 설정 또는 고객센터를 통해 요청 가능하며, 회사는 지체 없이 조치합니다. 법령상 보관의무가 있는 경우 그 범위 내에서 제한될 수 있습니다.</li>
    </ul>

    <h2>8. 아동의 개인정보 보호</h2>
    <p>회사는 만 14세 미만 아동의 회원가입 시 법정대리인의 동의를 받습니다. (해당 기능이 없으면 “아동 대상 서비스가 아닙니다”라고 명시)</p>

    <h2>9. 안전성 확보 조치</h2>
    <ul>
        <li>관리적 조치: 내부관리계획 수립·시행, 임직원 교육</li>
        <li>기술적 조치: 접근권한 관리, 비밀번호/전송구간 암호화(HTTPS), 로그·보안 모니터링, 취약점 점검</li>
        <li>물리적 조치: 서버 접근 통제, 백업/DR</li>
    </ul>

    <h2>10. 쿠키 및 유사기술</h2>
    <p>서비스 품질 개선과 로그인 유지 등을 위해 쿠키를 사용합니다. 이용자는 브라우저 설정에서 쿠키 저장을 거부하거나 삭제할 수 있습니다. 앱은 웹뷰 쿠키/스토리지로 세션을 관리할 수 있습니다.</p>

    <h2>11. 개인정보 보호책임자</h2>
    <table class="table table-bordered">
        <tbody>
        <tr><td class="w-25">책임자</td><td><b>정지균</b></td></tr>
        <tr><td>연락처</td><td>이메일: <a href="mailto:connnect3000@gmail.com">connnect3000@gmail.com</a> / 전화: 010-0000-0000</td></tr>
<!--         <tr><td>주소</td><td>(선택) 주소 기재</td></tr> -->
        </tbody>
    </table>
	
    <h2>12. 고지의 의무</h2>
    <p>법령·정책 또는 보안 기술의 변경에 따라 본 방침을 개정하는 경우, 웹사이트 공지사항/앱 공지 등을 통해 고지하고 시행일을 명시합니다.</p>

    <hr>
    <p class="small muted">  
        최종 업데이트: 2025-10-13<br>
        문의: <a href="mailto:connnect3000@gmail.com">connnect3000@gmail.com</a>
    </p>
</div>
</body>
</html>