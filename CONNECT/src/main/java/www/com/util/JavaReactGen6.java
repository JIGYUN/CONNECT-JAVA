package www.com.util;

import java.io.File;
import java.io.IOException;
import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Properties;

/**
 * <pre>
 * Project-Optimized JavaGen (+ ReactGen)
 *
 * 1) Spring 서버 사이드
 *    - Controller / Service / Mapper XML / WebController / AdmWebController
 *    - JSP(웹/관리자) Scaffold
 *
 * 2) React 프런트 사이드 (Next.js / TypeScript)
 *    - /generated/react/shared/{module}/types.ts
 *    - /generated/react/shared/{module}/adapters.ts
 *    - /generated/react/shared/{module}/api/queries.ts
 *    - /generated/react/shared/{module}/index.ts
 *    - /generated/react/app/{module}/page.tsx (초기 1회만 Scaffold)
 *
 * 생성 기준:
 *    - DB 메타 (컬럼명, PK)
 *    - javagen.properties (pkg.*, service.name, db.*, react.* 힌트)
 *
 * 규칙:
 *    - "shared/*" 파일은 언제든 갱신(덮어쓰기) 가능 (데이터 계약/쿼리 규약)
 *    - "page.tsx"는 실제 화면이므로 최초만 생성하고 이후는 덮어쓰지 않음
 *
 * 목표:
 *    - 백엔드 테이블/서비스 선언 → JSP Admin + Spring API + React Hook + React Page 골격까지 즉시 한 번에 찍는다.
 *    - 찍힌 React 파일은 Next.js 레포(src/...)로 복사 후 커스터마이징/브랜딩만 하면 된다.
 */
public class JavaReactGen6 {

    /* ─────────────────────────────────────────────────────────────
     * 속성 로딩
     * ───────────────────────────────────────────────────────────── */
    private static final Properties PROPS = loadProps();

    private static Properties loadProps() {
        Properties p = new Properties();

        String profile = System.getProperty("profile",
            System.getenv().getOrDefault("JAVA_GEN_PROFILE", ""));
        String base = "javagen.properties";
        String prof = profile.isEmpty() ? null : "javagen-" + profile + ".properties";

        // 1) 작업 디렉터리 파일 우선
        try (java.io.FileInputStream in = new java.io.FileInputStream(base)) {
            p.load(in);
        } catch (java.io.IOException ignored) {}

        if (prof != null) {
            try (java.io.FileInputStream in = new java.io.FileInputStream(prof)) {
                p.load(in);
            } catch (java.io.IOException ignored) {}
        }

        // 2) 클래스패스 fallback
        ClassLoader cl = Thread.currentThread().getContextClassLoader();
        try (java.io.InputStream in = cl.getResourceAsStream(base)) {
            if (in != null) p.load(in);
        } catch (java.io.IOException ignored) {}

        if (prof != null) {
            try (java.io.InputStream in = cl.getResourceAsStream(prof)) {
                if (in != null) p.load(in);
            } catch (java.io.IOException ignored) {}
        }

        return p;
    }

    private static String prop(String key, String def) {
        // 1) -Dkey=val
        String v = System.getProperty(key);
        if (v != null) return v;
        // 2) ENV: key -> KEY / '.' -> '_' upper
        String envKey = key.replace('.', '_').toUpperCase();
        v = System.getenv(envKey);
        if (v != null) return v;
        // 3) properties
        v = PROPS.getProperty(key);
        if (v != null) {
            // ${ENV:default} 간단치환
            if (v.contains("${")) {
                int s = v.indexOf("${"), e = v.indexOf("}", s);
                if (s >= 0 && e > s) {
                    String token = v.substring(s + 2, e);
                    String[] parts = token.split(":", 2);
                    String env = System.getenv(parts[0]);
                    String dft = parts.length > 1 ? parts[1] : "";
                    v = v.substring(0, s) + (env != null ? env : dft) + v.substring(e + 1);
                }
            }
            return v;
        }
        return def;
    }

    private static boolean pbool(String key, boolean def) {
        return Boolean.parseBoolean(prop(key, String.valueOf(def)));
    }
    private static int pint(String key, int def) {
        return Integer.parseInt(prop(key, String.valueOf(def)));
    }

    /* ─────────────────────────────────────────────────────────────
     * 0) 생성 스위치
     * ───────────────────────────────────────────────────────────── */
    private static final boolean GEN_CONTROLLER     = true;
    private static final boolean GEN_SERVICE        = true;
    private static final boolean GEN_MAPPER_XML     = true;

    // 확장 OFF(필요시 ON)
    private static final boolean GEN_DAO_JAVA       = false;
    private static final boolean GEN_IMPL           = false;
    private static final boolean GEN_VO             = false;

    // JSP 생성
    private static final boolean GEN_JSP            = true;
    private static final boolean JSP_OVERWRITE      = false; // true일 경우 기존 JSP 덮어씀

    // JSP 연결 Controller
    private static final boolean GEN_WEB_CONTROLLER = true;

    // 관리자 JSP/Controller도 항상 생성
    private static final String ADM_PKG_UP               = "adm";
    private static final String ADM_TEMPLATE_WEB_ROOT    = "/adm/smp";
    private static final String ADM_JSP_TEMPLATE_ROOT    = "/WEB-INF/jsp/adm/smp/sample";
    private static final String ADM_JSP_TARGET_BASE      = "/WEB-INF/jsp/adm";

    // 사용자 JSP 템플릿/경로
    private static String template_web_root = "/www/smp";
    private static String jsp_template_root = "/WEB-INF/jsp/www/smp/sample";
    private static String jsp_target_base   = "/WEB-INF/jsp/www";

    // React 생성 스위치
    private static final boolean GEN_REACT_SHARED = true; // types/adapters/api/index
    private static final boolean GEN_REACT_PAGE   = true; // page.tsx Scaffold

    /* ─────────────────────────────────────────────────────────────
     * 1) 프로젝트/모듈 설정
     * ───────────────────────────────────────────────────────────── */
    private static String full_path = "/src/main/java";

    // 패키지/명칭
    private static String up_pk_name         = prop("pkg.up",         "www");
    private static String middle_pk_name     = prop("pkg.middle",     "api/bbs");
    private static String down_pk_name       = prop("pkg.down",       "board");
    private static String middle_pk_in_name  = prop("pkg.middle.in",  "bbs.board");

    private static String service_name       = prop("service.name",   "Board");   // PascalCase 모듈명
    private static String unitBizName        = prop("unit.biz",       "basic");
    private static String NaDa               = prop("author",         "정지균");
    private static String screenTitle        = prop("screen.title",   "게시판");   // 화면 타이틀 (뷰용)
    private static String functionDesc       = prop("function.desc",  "CRUD");

    // Controller 템플릿에서 쓰는 토큰(옛 규격 호환)
    private static String db_idx             = "get" + service_name + "Idx";

    /* ─────────────────────────────────────────────────────────────
     * 2) DB 연결 파라미터
     * ───────────────────────────────────────────────────────────── */
    private static String dbType    = prop("db.type",     "mysql");
    private static String driver    = prop("db.driver",   "com.mysql.cj.jdbc.Driver");
    private static String user      = prop("db.user",     "root");
    private static String password  = prop("db.password", "");
    private static String server_ip = prop("db.url",      "jdbc:mysql://127.0.0.1:3306/test");
    private static String db_table  = prop("db.table",    "TB_SAMPLE");
    private static String db_key    = prop("db.key",      "ID");

    /* ─────────────────────────────────────────────────────────────
     * 3) 내부 경로/치환 설정
     * ───────────────────────────────────────────────────────────── */
    private static String maxUp_pkg_name        = prop("maxUp_pkg_name",       "www/api/bbs/board");
    private static String service_templat_name  = prop("service_templat_name", "Template");
    private static String template_do_path      = prop("template_do_path",     "/www/api/smp/sample");

    private static String service_path, service_java_name;
    private static String web_path, web_java_name;

    // JSP Web Controller 위치
    private static String web_ui_path, web_ui_java_name;

    // 설명
    private static String ctrlDescription = screenTitle + " 위한 클래스로 " + functionDesc + "에 대한 컨트롤을 관리한다.";
    private static String servDescription = screenTitle + " 위한 클래스로 " + functionDesc + "에 대한 서비스를 관리한다.";
    private static String implDescription = screenTitle + " 위한 클래스로 " + functionDesc + "에 대한 비지니스 로직을 처리한다.";
    private static String daoDescription  = screenTitle + " 정보를 DB에서  " + functionDesc + " 처리한다.";

    private static String makeDayDescription = "";
    private static FileUtil2 fn = null;

    // 템플릿 내 패키지 플레이스홀더(정규식) → 실제 패키지
    private static String template_pkg_path = "res[.]template[.]";

    /* ─────────────────────────────────────────────────────────────
     * React 전용 설정 (추가)
     * ───────────────────────────────────────────────────────────── */

    // React 산출물을 어디에 생성할지 (기본: 프로젝트 루트/generated/react)
    // full_path (/절대경로/.../src/main/java) 기준으로 src/main/java 잘라내고 거기에 붙인다.
    private static String react_out_root_prop = prop("react.out.root", "/generated/react");

    // 캘린더/리치텍스트/ownerId 바인딩 등 hint
    private static boolean react_hasCalendar      = pbool("react.hasCalendar",      true);
    private static boolean react_hasRichText      = pbool("react.hasRichText",      true);
    private static boolean react_ownerBound       = pbool("react.ownerBound",       true);

    // hook 이름 suffix, 기본 ByDate
    private static String react_hookSuffix        = prop("react.query.hookNameSuffix", "ByDate");

    // 주 조회 파라미터(예: diaryDt)
    private static String react_primaryDateField  = prop("react.primaryDateField", "diaryDt");

    // upsert 인풋 required/optional 필드 정의(문자열 CSV)
    private static String react_upsert_required   = prop("react.upsert.required", "diaryDt,content");
    private static String react_upsert_optional   = prop("react.upsert.optional", "grpCd,ownerId");

    // alias / outbound 매핑은 dynamic으로 property에서 읽을 수 있게 헬퍼로 처리한다.

    /* ─────────────────────────────────────────────────────────────
     * DB 메타 캐시
     * ───────────────────────────────────────────────────────────── */
    private static List<String> db_list = null;               // 컬럼명 리스트 (원형)
    private static HashMap<String, String> db_map = null;     // 컬럼명 -> "type#remark"

    /* ─────────────────────────────────────────────────────────────
     * main
     * ───────────────────────────────────────────────────────────── */
    public static void main(String[] args) {
        StringUtil2 st = new StringUtil2();
        makeDayDescription = st.getDate();
        fn = new FileUtil2();

        try {
            File file = new File(".");
            full_path = file.getCanonicalPath() + full_path; // /abs/project/path/src/main/java
        } catch (IOException e) {
            e.printStackTrace();
        }

        // down_pk_name 자동 보완 (없으면 service_name lowerCamel)
        if (isBlank(down_pk_name)) {
            down_pk_name = toLowerCamel(service_name);
        }

        // 패키지/경로 세팅
        getPaths();

        // 스프링/마이바티스/JSP 생성
        if (GEN_CONTROLLER)        createController();
        if (GEN_SERVICE)          createService();
        if (GEN_MAPPER_XML)       createSql();

        if (GEN_JSP)              createJsp();
        if (GEN_JSP)              createAdminJsp();

        if (GEN_WEB_CONTROLLER)   createWebController();
        if (GEN_WEB_CONTROLLER)   createAdminWebController();

        // 확장 OFF (필요시 ON)
        if (GEN_DAO_JAVA)         createMapperJava();
        if (GEN_IMPL)             createImpl();
        if (GEN_VO)               createVO();

        // React 생성
        if (GEN_REACT_SHARED)     createReactShared();
        if (GEN_REACT_PAGE)       createReactPage();

        System.out.println("=====================================================");
        System.out.println("생성이 완료되었습니다. 템플릿/치환 결과를 확인하세요.");
        System.out.println("=====================================================");
    }

    /* ─────────────────────────────────────────────────────────────
     * 경로 계산
     * ───────────────────────────────────────────────────────────── */
    private static void getPaths() {
        StringBuilder br = new StringBuilder();

        // 예: www/api/tsk/diary
        br.append(up_pk_name);
        if (!"".equals(middle_pk_name)) {
            br.append("/").append(middle_pk_name);
        }
        if (!"".equals(down_pk_name)) {
            br.append("/").append(down_pk_name);
        }
        maxUp_pkg_name = br.toString();

        // Controller API용
        web_path = full_path + "/" + maxUp_pkg_name + "/web/";
        web_java_name = service_name + "Controller";

        // Service
        service_path = full_path + "/" + maxUp_pkg_name + "/service/";
        service_java_name = service_name + "Service";

        // Web(JSP) UI Controller
        String bizSeg = getBizSeg(); // 예: tsk
        web_ui_path = full_path + "/" + up_pk_name + "/" + bizSeg + "/web/";
        web_ui_java_name = "Web" + service_name + "Controller";
    }

    /* ─────────────────────────────────────────────────────────────
     * 관리자 JSP 연결 컨트롤러
     * ───────────────────────────────────────────────────────────── */
    private static void createAdminWebController() {
        try {
            String bizSeg  = getBizSeg(); // 예: tsk
            String bizPath = (isBlank(middle_pk_in_name) ? bizSeg : middle_pk_in_name).replace(".", "/");

            String ctrlDir  = full_path + "/" + ADM_PKG_UP + "/" + bizSeg + "/web/";
            String ctrlName = "Adm" + service_name + "Controller";

            String tplRoot  = full_path + ADM_TEMPLATE_WEB_ROOT + "/web/";
            String original_java = tplRoot + "AdmTemplateController.java";

            if (fn.fileExists(ctrlDir + ctrlName + ".java")) {
                System.out.println(ctrlDir + ctrlName + ".java 이미 존재. 생략");
                return;
            }
            if (!fn.fileExists(original_java)) {
                System.out.println("admin web controller 템플릿 없음: " + original_java);
                return;
            }

            String s = fn.readText(original_java);
            s = s.replaceAll("adm[.]smp[.]web", ADM_PKG_UP + "." + bizSeg + ".web");
            s = s.replace("AdmTemplateController", ctrlName);
            s = s.replace("Template",  service_name);
            s = s.replace("template",  toLowerCamel(service_name));
            s = s.replace("BIZ_SEG",   bizSeg);
            s = s.replace("BIZ_PATH",  bizPath);
            s = s.replace("screenTitle", screenTitle);
            s = s.replace("ctrlDescription", ctrlDescription);
            s = s.replace("2012. 00. 00.", makeDayDescription);
            s = s.replace("unitBizName", unitBizName);
            s = s.replace("NaDa", NaDa);

            fn.makeDirectory(ctrlDir);
            fn.writeText(ctrlDir + ctrlName + ".java", s);
            System.out.println("생성: " + ctrlDir + ctrlName + ".java");
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /* ─────────────────────────────────────────────────────────────
     * JSP 연결 Web 컨트롤러 (www.tsk.web.WebDiaryController 등)
     * ───────────────────────────────────────────────────────────── */
    private static void createWebController() {
        try {
            String tplRoot = full_path + template_web_root + "/web/";
            String original_java = tplRoot + "WebTemplateController.java";

            if (fn.fileExists(web_ui_path + "/" + web_ui_java_name + ".java")) {
                System.out.println(web_ui_path + " 안에 같은 파일이 존재합니다. 생성하지 않습니다.");
                return;
            }
            if (!fn.fileExists(original_java)) {
                System.out.println("web controller 템플릿 파일이 존재하지 않습니다. (" + original_java + ")");
                return;
            }

            String bizSeg  = getBizSeg(); // ex) tsk
            String bizPath = (isBlank(middle_pk_in_name) ? bizSeg : middle_pk_in_name).replace(".", "/"); // tsk/diary

            String s = fn.readText(original_java);
            s = s.replaceAll("www[.]smp[.]web", up_pk_name + "." + bizSeg + ".web");
            s = s.replace("WebTemplateController", web_ui_java_name);
            s = s.replace("Template",  service_name);
            s = s.replace("template",  toLowerCamel(service_name));
            s = s.replace("BIZ_SEG",   bizSeg);
            s = s.replace("BIZ_PATH",  bizPath);
            s = s.replace("screenTitle", screenTitle);
            s = s.replace("ctrlDescription", ctrlDescription);
            s = s.replace("2012. 00. 00.", makeDayDescription);
            s = s.replace("unitBizName", unitBizName);
            s = s.replace("NaDa", NaDa);

            fn.makeDirectory(web_ui_path);
            fn.writeText(web_ui_path + "/" + web_ui_java_name + ".java", s);
            System.out.println("생성: " + web_ui_path + web_ui_java_name + ".java");
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /* ─────────────────────────────────────────────────────────────
     * API Controller (www.api.tsk.diary.web.DiaryController)
     * ───────────────────────────────────────────────────────────── */
    private static void createController() {
        try {
            String tplRoot = full_path + template_do_path + "/web/";
            String original_java = tplRoot + service_templat_name + "Controller.java";

            if (fn.fileExists(web_path + "/" + web_java_name + ".java")) {
                System.out.println(web_path + " 안에 같은 파일이 존재합니다. 생성하지 않습니다.");
                return;
            }
            if (!fn.fileExists(original_java)) {
                System.out.println("controller 템플릿 파일이 존재하지 않습니다.");
                return;
            }
            System.out.println("controller 템플릿 복사 중…");
            String newLine = fn.readText(original_java);

            String bizSeg  = getBizSeg(); // ex) tsk
            String bizPath = (isBlank(middle_pk_in_name) ? bizSeg : middle_pk_in_name).replace(".", "/");

            newLine = newLine.replace("BIZ_SEG", bizSeg);
            newLine = newLine.replace("BIZ_PATH", bizPath);

            newLine = newLine.replaceAll("www.api.smp.sample", maxUp_pkg_name.replaceAll("/", "."));
            newLine = newLine.replaceAll("TemplateController", web_java_name);
            newLine = newLine.replaceAll("TemplateService", service_java_name);
            newLine = newLine.replaceAll("templateService", lcFirst(service_java_name));
            newLine = newLine.replaceAll("Template", service_name);
            newLine = newLine.replaceAll("template", toLowerCamel(service_name));
            newLine = newLine.replaceAll("screenTitle", screenTitle);
            newLine = newLine.replaceAll("getIdx", db_idx);
            newLine = newLine.replaceAll("ctrlDescription", ctrlDescription);
            newLine = newLine.replaceAll("2012. 00. 00.", makeDayDescription);
            newLine = newLine.replaceAll("unitBizName", unitBizName);
            newLine = newLine.replaceAll("NaDa", NaDa);

            fn.makeDirectory(web_path);
            fn.writeText(web_path + "/" + web_java_name + ".java", newLine);

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /* ─────────────────────────────────────────────────────────────
     * Service (www.api.tsk.diary.service.DiaryService)
     * ───────────────────────────────────────────────────────────── */
    private static void createService() {
        try {
            String tplRoot = full_path + template_do_path + "/service/";
            String original_java = tplRoot + service_templat_name + "Service.java";

            if (fn.fileExists(service_path + "/" + service_java_name + ".java")) {
                System.out.println(service_path + " 안에 파일이 존재합니다. 생성하지 않습니다.");
                return;
            }
            if (!fn.fileExists(original_java)) {
                System.out.println("service 템플릿 파일이 존재하지 않습니다.");
                return;
            }
            System.out.println("service 템플릿 복사 중…");
            String newLine = fn.readText(original_java);

            String bizSeg  = getBizSeg(); // ex) tsk
            String bizPath = (isBlank(middle_pk_in_name) ? bizSeg : middle_pk_in_name).replace(".", "/");

            newLine = newLine.replace("BIZ_SEG", bizSeg);
            newLine = newLine.replace("BIZ_PATH", bizPath);

            newLine = newLine.replaceAll("www.api.smp.sample", maxUp_pkg_name.replaceAll("/", "."));
            newLine = newLine.replaceAll("TemplateService", service_java_name);
            newLine = newLine.replaceAll("templateService", lcFirst(service_java_name));
            newLine = newLine.replaceAll(template_pkg_path, up_pk_name + "." + middle_pk_name + ".");
            newLine = newLine.replaceAll("Template", service_name);
            newLine = newLine.replaceAll("template", toLowerCamel(service_name));
            newLine = newLine.replaceAll("servDescription", servDescription);
            newLine = newLine.replaceAll("screenTitle", screenTitle);
            newLine = newLine.replaceAll("2012. 00. 00.", makeDayDescription);
            newLine = newLine.replaceAll("unitBizName", unitBizName);
            newLine = newLine.replaceAll("NaDa", NaDa);

            fn.makeDirectory(service_path);
            fn.writeText(service_path + "/" + service_java_name + ".java", newLine);

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /* ─────────────────────────────────────────────────────────────
     * Mapper XML(MyBatis)
     *    resources/config/www/sqlmap/mysql/Template.xml
     *    → DiarySql.xml
     *    DB 메타에서 컬럼 자동 추출
     * ───────────────────────────────────────────────────────────── */
    private static void createSql() {
        try {
            String original_xml = full_path.replace("java", "resources")
                + "/config/www/sqlmap/mysql/Template.xml";
            String target_xml   = original_xml.replace("Template", service_name + "Sql");

            if (fn.fileExists(target_xml)) {
                System.out.println(target_xml + " 이(가) 이미 존재합니다. 생성하지 않습니다.");
                return;
            }
            if (!fn.fileExists(original_xml)) {
                System.out.println("sql 템플릿 파일이 존재하지 않습니다.");
                return;
            }
            System.out.println("mapper XML 템플릿 복사 중…");

            String newLine  = fn.readText(original_xml);

            // DB 메타
            getTableMap();
            List<String> cols = db_list; // 대문자 컬럼 리스트 (TB_DIARY 등)

            StringBuilder columns_      = new StringBuilder(); // SELECT 컬럼
            StringBuilder columnsAdd_   = new StringBuilder(); // INSERT 컬럼
            StringBuilder values_       = new StringBuilder(); // INSERT VALUES
            StringBuilder columnUpdate_ = new StringBuilder(); // UPDATE SET 절

            for (String key : cols) {
                String U     = key.toUpperCase();
                String camel = convert2CamelCase(U);

                // SELECT
                if (columns_.length() > 0) columns_.append("\t\t\t,");
                if (isMySQLFamily() && isDateLike(U)) {
                    columns_.append("DATE_FORMAT(")
                        .append(U)
                        .append(", '%Y-%m-%d %H:%i:%s') AS ")
                        .append(U)
                        .append("\n");
                } else {
                    columns_.append(U).append("\n");
                }

                // PK는 insert/update에서 제외
                if (db_key.equalsIgnoreCase(U)) continue;

                // INSERT COLUMNS
                if (columnsAdd_.length() > 0) columnsAdd_.append("\t\t\t,");
                columnsAdd_.append(U).append("\n");

                // INSERT VALUES
                if (values_.length() > 0) values_.append("\t\t\t,");
                if (isMySQLFamily() && isDateLike(U)) {
                    values_.append(mysqlDateInsertExpr(camel)).append("\n");
                } else {
                    values_.append("#{").append(camel).append("}\n");
                }

                // UPDATE
                columnUpdate_.append("\t\t\t<if test='")
                    .append(camel)
                    .append(" != null and ")
                    .append(camel)
                    .append(" != \"\"'>\n");

                if (isMySQLFamily() && isDateLike(U)) {
                    columnUpdate_.append("\t\t\t\t")
                        .append(U)
                        .append(" = ")
                        .append(mysqlDateParseExpr(camel))
                        .append(",\n");
                } else {
                    columnUpdate_.append("\t\t\t\t")
                        .append(U)
                        .append(" = #{")
                        .append(camel)
                        .append("},\n");
                }
                columnUpdate_.append("\t\t\t</if>\n");
            }

            // 치환
            newLine = newLine.replaceAll("values_",       values_.toString());
            newLine = newLine.replaceAll("columnsAdd_",   columnsAdd_.toString());
            newLine = newLine.replaceAll("columns_",      columns_.toString());
            newLine = newLine.replaceAll("table_",        db_table);
            newLine = newLine.replaceAll("columnUpdate_", columnUpdate_.toString());
            newLine = newLine.replaceAll("columnId_",     db_key.toUpperCase());
            newLine = newLine.replaceAll(
                "valueId_",
                "#{" + convert2CamelCase(db_key) + "}"
            );

            newLine = newLine.replaceAll("com.basic.admin.sample", maxUp_pkg_name.replaceAll("/", "."));
            newLine = newLine.replaceAll("Template", service_name);
            newLine = newLine.replaceAll("template", toLowerCamel(service_name));

            fn.writeText(target_xml, newLine);

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /* ─────────────────────────────────────────────────────────────
     * JSP 생성 (웹)
     * ───────────────────────────────────────────────────────────── */
    private static void createJsp() {
        try {
            String webRoot = full_path.replace("/src/main/java", "/src/main/webapp");

            String tplList = webRoot + jsp_template_root + "/TemplateList.jsp";
            String tplMod  = webRoot + jsp_template_root + "/TemplateModify.jsp";

            String bizPath   = (isBlank(middle_pk_in_name) ? "tsk" : middle_pk_in_name).replace(".", "/");
            String targetDir = webRoot + jsp_target_base + "/" + bizPath + "/";

            String svcLower = toLowerCamel(service_name);
            String outList  = targetDir + svcLower + "List.jsp";
            String outMod   = targetDir + svcLower + "Modify.jsp";
            String outMain  = targetDir + svcLower + ".jsp";

            String svcUpper = service_name;
            String pkParam  = convert2CamelCase(db_key);
            String bizSeg   = getBizSeg();
            String title    = screenTitle;

            fn.makeDirectory(targetDir);

            // List.jsp
            if (!fn.fileExists(tplList)) {
                System.out.println("JSP 템플릿 없음: " + tplList);
            } else {
                if (!JSP_OVERWRITE && fn.fileExists(outList)) {
                    System.out.println(outList + " 이미 존재. 생성 생략");
                } else {
                    String s = fn.readText(tplList);
                    s = s.replace("BIZ_SEG", bizSeg);
                    s = s.replace("Template",  svcUpper);
                    s = s.replace("template",  svcLower);
                    s = s.replace("PK_PARAM",  pkParam);
                    s = s.replace("screenTitle", title);
                    fn.writeText(outList, s);
                    System.out.println("생성: " + outList);
                }
            }

            // Modify.jsp
            if (!fn.fileExists(tplMod)) {
                System.out.println("JSP 템플릿 없음: " + tplMod);
            } else {
                if (!JSP_OVERWRITE && fn.fileExists(outMod)) {
                    System.out.println(outMod + " 이미 존재. 생성 생략");
                } else {
                    String s = fn.readText(tplMod);
                    s = s.replace("BIZ_SEG", bizSeg);
                    s = s.replace("Template",  svcUpper);
                    s = s.replace("template",  svcLower);
                    s = s.replace("PK_PARAM",  pkParam);
                    s = s.replace("screenTitle", title);
                    fn.writeText(outMod, s);
                    System.out.println("생성: " + outMod);
                }
            }

            // 통합(단일 화면)
            String tplUnified = tplList.replace("TemplateList.jsp", "Template.jsp");
            if (!fn.fileExists(tplUnified)) {
                System.out.println("JSP 템플릿 없음: " + tplUnified);
            } else {
                if (!JSP_OVERWRITE && fn.fileExists(outMain)) {
                    System.out.println(outMain + " 이미 존재. 생성 생략");
                } else {
                    String s = fn.readText(tplUnified);
                    s = s.replace("BIZ_SEG", bizSeg);
                    s = s.replace("Template",  svcUpper);
                    s = s.replace("template",  svcLower);
                    s = s.replace("PK_PARAM",  pkParam);
                    s = s.replace("screenTitle", title);
                    fn.writeText(outMain, s);
                    System.out.println("생성: " + outMain);
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /* ─────────────────────────────────────────────────────────────
     * JSP 생성 (관리자)
     * ───────────────────────────────────────────────────────────── */
    private static void createAdminJsp() {
        try {
            String webRoot = full_path.replace("/src/main/java", "/src/main/webapp");
            String tplList = webRoot + ADM_JSP_TEMPLATE_ROOT + "/TemplateList.jsp";
            String tplMod  = webRoot + ADM_JSP_TEMPLATE_ROOT + "/TemplateModify.jsp";
            String tplUnified = tplList.replace("TemplateList.jsp", "Template.jsp");

            String bizSeg   = getBizSeg();
            String bizPath  = (isBlank(middle_pk_in_name) ? bizSeg : middle_pk_in_name).replace(".", "/");
            String targetDir= webRoot + ADM_JSP_TARGET_BASE + "/" + bizPath + "/";

            String svcLower = toLowerCamel(service_name);
            String svcUpper = service_name;
            String pkParam  = convert2CamelCase(db_key);

            fn.makeDirectory(targetDir);

            java.util.function.Function<String,String> fx = s -> s
                .replace("BIZ_SEG", bizSeg)
                .replace("Template",  svcUpper)
                .replace("template",  svcLower)
                .replace("PK_PARAM",  pkParam)
                .replace("screenTitle", screenTitle);

            if (fn.fileExists(tplList)) {
                String out = targetDir + svcLower + "List.jsp";
                if (!JSP_OVERWRITE && fn.fileExists(out)) {
                    System.out.println(out + " 존재. 생략");
                } else {
                    fn.writeText(out, fx.apply(fn.readText(tplList)));
                    System.out.println("생성: " + out);
                }
            } else {
                System.out.println("Admin JSP 템플릿 없음: " + tplList);
            }

            if (fn.fileExists(tplMod)) {
                String out = targetDir + svcLower + "Modify.jsp";
                if (!JSP_OVERWRITE && fn.fileExists(out)) {
                    System.out.println(out + " 존재. 생략");
                } else {
                    fn.writeText(out, fx.apply(fn.readText(tplMod)));
                    System.out.println("생성: " + out);
                }
            } else {
                System.out.println("Admin JSP 템플릿 없음: " + tplMod);
            }

            if (fn.fileExists(tplUnified)) {
                String out = targetDir + svcLower + ".jsp";
                if (!JSP_OVERWRITE && fn.fileExists(out)) {
                    System.out.println(out + " 존재. 생략");
                } else {
                    fn.writeText(out, fx.apply(fn.readText(tplUnified)));
                    System.out.println("생성: " + out);
                }
            } else {
                System.out.println("Admin JSP 템플릿 없음: " + tplUnified);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /* ─────────────────────────────────────────────────────────────
     * ReactGen: shared (types/adapters/api/index)
     * ───────────────────────────────────────────────────────────── */
    private static void createReactShared() {
        try {
            // DB 메타 확보
            getTableMap();

            // 모듈명
            String modulePascal = service_name;              // Diary
            String moduleCamel  = toLowerCamel(service_name); // diary

            // 프로젝트 루트 (full_path = /abs/.../src/main/java)
            String projectRoot = full_path.replace("/src/main/java", "");
            String reactRoot   = projectRoot + react_out_root_prop; // /abs/.../generated/react

            // 출력 디렉토리 (/generated/react/shared/diary)
            String sharedDir   = reactRoot + "/shared/" + moduleCamel;
            fn.makeDirectory(sharedDir);

            // Hook/Endpoint 정보
            String apiBasePath    = "/api/" + middle_pk_in_name.replace(".", "/"); // /api/tsk/diary
            String selectFnName   = "select" + modulePascal + react_hookSuffix;    // selectDiaryByDate
            String upsertFnName   = "upsert" + modulePascal;                       // upsertDiary

            // types.ts
            String typesTs = buildReactTypesTs(modulePascal, moduleCamel);
            fn.writeText(sharedDir + "/types.ts", typesTs);
            System.out.println("생성: " + sharedDir + "/types.ts");

            // adapters.ts
            String adaptersTs = buildReactAdaptersTs(modulePascal, moduleCamel);
            fn.writeText(sharedDir + "/adapters.ts", adaptersTs);
            System.out.println("생성: " + sharedDir + "/adapters.ts");

            // api/queries.ts
            String queriesDir = sharedDir + "/api";
            fn.makeDirectory(queriesDir);
            String queriesTs = buildReactQueriesTs(
                modulePascal,
                moduleCamel,
                apiBasePath,
                selectFnName,
                upsertFnName
            );
            fn.writeText(queriesDir + "/queries.ts", queriesTs);
            System.out.println("생성: " + queriesDir + "/queries.ts");

            // index.ts
            String indexTs = buildReactIndexTs(moduleCamel);
            fn.writeText(sharedDir + "/index.ts", indexTs);
            System.out.println("생성: " + sharedDir + "/index.ts");

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /* ─────────────────────────────────────────────────────────────
     * ReactGen: page.tsx scaffold (최초 1회만)
     * ───────────────────────────────────────────────────────────── */
    private static void createReactPage() {
        try {
            // 모듈명
            String modulePascal = service_name;              // Diary
            String moduleCamel  = toLowerCamel(service_name); // diary

            // 프로젝트 루트
            String projectRoot = full_path.replace("/src/main/java", "");
            String reactRoot   = projectRoot + react_out_root_prop; // /generated/react

            String pageDir     = reactRoot + "/app/" + moduleCamel;
            fn.makeDirectory(pageDir);

            String pageFile    = pageDir + "/page.tsx";

            // 이미 있으면 덮어쓰면 안 된다 (UI는 커스터마이징 존)
            if (fn.fileExists(pageFile)) {
                System.out.println(pageFile + " 이미 존재. 생성 생략");
                return;
            }

            String pageTsx = buildReactPageTsx(modulePascal, moduleCamel);
            fn.writeText(pageFile, pageTsx);
            System.out.println("생성: " + pageFile);

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /* ─────────────────────────────────────────────────────────────
     * React 템플릿 빌더: types.ts
     * ───────────────────────────────────────────────────────────── */
    private static String buildReactTypesTs(String modulePascal, String moduleCamel) {
        // db_list: ["DIARY_ID","YMD","CONTENT",...]
        // db_map : { "YMD" -> "string#설명", "OWNER_ID" -> "int#..." }
        StringBuilder entryFields = new StringBuilder();

        for (String colUpper : db_list) {
            String camel = convert2CamelCase(colUpper);
            String typeInfo = db_map.get(colUpper);
            String baseType = "string";
            if (typeInfo != null) {
                int idx = typeInfo.indexOf('#');
                String t0 = (idx >= 0 ? typeInfo.substring(0, idx) : typeInfo);
                // int -> number, 나머지 -> string
                if ("int".equalsIgnoreCase(t0) || "long".equalsIgnoreCase(t0) || "number".equalsIgnoreCase(t0)) {
                    baseType = "number";
                } else {
                    baseType = "string";
                }
            }

            // PK는 'id'로 매핑
            if (colUpper.equalsIgnoreCase(db_key)) {
                entryFields.append("    id?: Id | null;\n");
                continue;
            }

            // 일반 필드
            // number -> number | null
            // string/clob -> string | null
            String tsType;
            if ("number".equals(baseType)) {
                tsType = "number | null";
            } else {
                tsType = "string | null";
            }

            entryFields.append("    ").append(camel).append("?: ").append(tsType).append(";\n");
        }

        // UpsertInput
        // required -> string (또는 추후 룰 확장)
        // optional -> string | null
        List<String> reqList = csvToList(react_upsert_required);
        List<String> optList = csvToList(react_upsert_optional);

        StringBuilder upsertFields = new StringBuilder();

        for (String f : reqList) {
            String trimmed = f.trim();
            if (trimmed.isEmpty()) continue;
            // ownerId 같은 케이스에선 number|null이 맞지만,
            // 우선 string으로 두고 이후 커스터마이징에서 조정 가능하도록 둔다.
            if ("ownerId".equals(trimmed)) {
                upsertFields.append("    ").append(trimmed).append(": Id | null;\n");
            } else {
                upsertFields.append("    ").append(trimmed).append(": string;\n");
            }
        }
        for (String f : optList) {
            String trimmed = f.trim();
            if (trimmed.isEmpty()) continue;
            if ("ownerId".equals(trimmed)) {
                upsertFields.append("    ").append(trimmed).append("?: Id | null;\n");
            } else {
                upsertFields.append("    ").append(trimmed).append("?: string | null;\n");
            }
        }

        StringBuilder sb = new StringBuilder();
        sb.append("// filepath: src/shared/").append(moduleCamel).append("/types.ts\n");
        sb.append("import type { Id } from '@/shared/types/common';\n\n");
        sb.append("/**\n");
        sb.append(" * ").append(modulePascal).append("Entry\n");
        sb.append(" * - DB 테이블 ").append(db_table).append(" 기반 자동생성\n");
        sb.append(" * - PK: ").append(db_key).append("\n");
        sb.append(" */\n");
        sb.append("export type ").append(modulePascal).append("Entry = {\n");
        sb.append(entryFields);
        sb.append("};\n\n");
        sb.append("/**\n");
        sb.append(" * ").append(modulePascal).append("UpsertInput\n");
        sb.append(" * - 업서트 API 파라미터 표준\n");
        sb.append(" */\n");
        sb.append("export type ").append(modulePascal).append("UpsertInput = {\n");
        sb.append(upsertFields);
        sb.append("};\n");

        return sb.toString();
    }

    /* ─────────────────────────────────────────────────────────────
     * React 템플릿 빌더: adapters.ts
     * 서버 ↔ 프런트 변환기
     * ───────────────────────────────────────────────────────────── */
    private static String buildReactAdaptersTs(String modulePascal, String moduleCamel) {
        // alias 규칙:
        //   기본: [DB_COL_UPPER, camelCase]
        //   react.alias.<camelCase>=CSV 있으면 추가
        //
        // adaptInXxx(row: unknown): XxxEntry
        //   - result/data/item 래핑 5단계 언랩
        //   - 각 필드 pickStr/pickNum으로 추출
        //
        // adaptOutXxx(input: XxxEntry): Record<string, unknown>
        //   - DB 컬럼명 대문자를 key로, input.camel 값을 value로
        //   - PK는 input.id로

        String moduleEntry = modulePascal + "Entry";

        StringBuilder pickVarsBuilder = new StringBuilder(); // const field = pick...(o, ["A","a",...])
        StringBuilder retObjBuilder   = new StringBuilder(); // return { id:..., camel:... }
        StringBuilder outMapBuilder   = new StringBuilder(); // OUTBOUND map

        for (String colUpper : db_list) {
            String camel = convert2CamelCase(colUpper);
            boolean isPk = colUpper.equalsIgnoreCase(db_key);

            // guess numeric vs string
            String typeInfo = db_map.get(colUpper);
            String baseType = "string";
            if (typeInfo != null) {
                int idx = typeInfo.indexOf('#');
                String t0 = (idx >= 0 ? typeInfo.substring(0, idx) : typeInfo);
                if ("int".equalsIgnoreCase(t0) || "long".equalsIgnoreCase(t0) || "number".equalsIgnoreCase(t0)) {
                    baseType = "number";
                } else {
                    baseType = "string";
                }
            }

            // alias list
            List<String> aliasList = new ArrayList<>();
            aliasList.add(colUpper);                // "DIARY_ID"
            aliasList.add(camel);                   // "diaryId"
            // property 확장: react.alias.diaryId=ID,id,DiaryId ...
            String aliasProp = prop("react.alias." + camel, "");
            if (!isBlank(aliasProp)) {
                for (String tok : csvToList(aliasProp)) {
                    if (!isBlank(tok) && !aliasList.contains(tok)) {
                        aliasList.add(tok.trim());
                    }
                }
            }
            // PK는 'id','ID'도 자동으로 넣어준다.
            if (isPk) {
                if (!aliasList.contains("id")) aliasList.add("id");
                if (!aliasList.contains("ID")) aliasList.add("ID");
            }

            // aliasList → TS array literal
            StringBuilder arr = new StringBuilder();
            arr.append("[");
            for (int i = 0; i < aliasList.size(); i++) {
                if (i > 0) arr.append(",");
                arr.append("\"").append(aliasList.get(i)).append("\"");
            }
            arr.append("]");

            // pick 함수 (pickNum / pickStr)
            String pickFn = ("number".equals(baseType) ? "pickNum" : "pickStr");
            String varName = (isPk ? "idField" : camel + "Field");

            pickVarsBuilder.append("    const ").append(varName)
                .append(" = ").append(pickFn).append("(o, ")
                .append(arr).append(");\n");

            // 리턴 객체
            if (isPk) {
                // id?: Id | null
                retObjBuilder.append("        id: ").append(varName).append(" ?? null,\n");
            } else {
                // 일반
                // string -> string | null (or number | null)
                retObjBuilder.append("        ").append(camel)
                    .append(": ").append(varName).append(" ?? null,\n");
            }

            // adaptOut
            // PK면 input.id, 아니면 input.camel
            outMapBuilder.append("        ").append(colUpper.toUpperCase())
                .append(": ");
            if (isPk) {
                outMapBuilder.append("input.id ?? null");
            } else {
                outMapBuilder.append("input.").append(camel).append(" ?? null");
            }
            outMapBuilder.append(",\n");
        }

        StringBuilder sb = new StringBuilder();
        sb.append("// filepath: src/shared/").append(moduleCamel).append("/adapters.ts\n");
        sb.append("import type { ").append(moduleEntry).append(" } from '@/shared/").append(moduleCamel).append("/types';\n\n");
        sb.append("const isRec = (v: unknown): v is Record<string, unknown> =>\n");
        sb.append("    typeof v === 'object' && v !== null;\n\n");
        sb.append("function pickStr(o: Record<string, unknown>, keys: string[]): string | null {\n");
        sb.append("    for (const k of keys) {\n");
        sb.append("        const v = o[k];\n");
        sb.append("        if (typeof v === 'string' && v.trim() !== '') return v;\n");
        sb.append("    }\n");
        sb.append("    return null;\n");
        sb.append("}\n\n");
        sb.append("function pickNum(o: Record<String, unknown>, keys: string[]): number | null {\n");
        sb.append("    for (const k of keys) {\n");
        sb.append("        const v = o[k];\n");
        sb.append("        if (typeof v === 'number' && Number.isFinite(v)) return v;\n");
        sb.append("        if (typeof v === 'string') {\n");
        sb.append("            const n = Number(v);\n");
        sb.append("            if (Number.isFinite(n)) return n;\n");
        sb.append("        }\n");
        sb.append("    }\n");
        sb.append("    return null;\n");
        sb.append("}\n\n");
        sb.append("/** result/data/item 래핑을 최대 5단계 언랩 */\n");
        sb.append("function unwrapRow(row: unknown): Record<string, unknown> {\n");
        sb.append("    let cur: unknown = row;\n");
        sb.append("    for (let i = 0; i < 5; i++) {\n");
        sb.append("        if (!isRec(cur)) break;\n");
        sb.append("        const next =\n");
        sb.append("            (isRec(cur['result']) && cur['result']) ||\n");
        sb.append("            (isRec(cur['data']) && cur['data'])   ||\n");
        sb.append("            (isRec(cur['item']) && cur['item']);\n");
        sb.append("        if (next) {\n");
        sb.append("            cur = next;\n");
        sb.append("            continue;\n");
        sb.append("        }\n");
        sb.append("        break;\n");
        sb.append("    }\n");
        sb.append("    return isRec(cur) ? cur : {};\n");
        sb.append("}\n\n");
        sb.append("/** 서버 → 프런트 표준화 */\n");
        sb.append("export function adaptIn").append(modulePascal).append("(row: unknown): ").append(moduleEntry).append(" {\n");
        sb.append("    const o = unwrapRow(row);\n");
        sb.append(pickVarsBuilder);
        sb.append("\n");
        sb.append("    return {\n");
        sb.append(retObjBuilder);
        sb.append("    };\n");
        sb.append("}\n\n");
        sb.append("/** 프런트 → 서버 (업서트/전송용) */\n");
        sb.append("export function adaptOut").append(modulePascal).append("(input: ").append(moduleEntry).append("): Record<string, unknown> {\n");
        sb.append("    return {\n");
        sb.append(outMapBuilder);
        sb.append("    };\n");
        sb.append("}\n");

        return sb.toString();
    }

    /* ─────────────────────────────────────────────────────────────
     * React 템플릿 빌더: api/queries.ts
     * - React Query 훅
     * - keyByDate, getByDate 등
     * ───────────────────────────────────────────────────────────── */
    private static String buildReactQueriesTs(
        String modulePascal,
        String moduleCamel,
        String apiBasePath,
        String selectFnName,
        String upsertFnName
    ) {
        // ex) useDiaryByDate / useUpsertDiary
        String hookSelectName = "use" + modulePascal + react_hookSuffix;   // useDiaryByDate
        String hookUpsertName = "useUpsert" + modulePascal;                // useUpsertDiary
        String moduleEntry    = modulePascal + "Entry";
        String upsertInput    = modulePascal + "UpsertInput";

        // queryKey builder 함수명
        String keyFnName      = "key" + modulePascal + react_hookSuffix;   // keyDiaryByDate

        // enabled 조건: ownerBound=true이면 ownerId !== null까지 체크
        String enabledCond;
        if (react_ownerBound) {
            // diaryDt && ownerId !== null
            enabledCond = "!!" + react_primaryDateField + " && ownerId !== null";
        } else {
            enabledCond = "!!" + react_primaryDateField;
        }

        // build file
        StringBuilder sb = new StringBuilder();
        sb.append("// filepath: src/shared/").append(moduleCamel).append("/api/queries.ts\n");
        sb.append("import { useQuery, useMutation, useQueryClient, type QueryKey } from '@tanstack/react-query';\n");
        sb.append("import { postJson } from '@/shared/core/apiClient';\n");
        sb.append("import type { ").append(moduleEntry).append(", ").append(upsertInput).append(" } from '@/shared/").append(moduleCamel).append("/types';\n");
        sb.append("import { adaptIn").append(modulePascal).append(" } from '@/shared/").append(moduleCamel).append("/adapters';\n\n");
        sb.append("const isRec = (v: unknown): v is Record<string, unknown> => typeof v === 'object' && v !== null;\n\n");
        sb.append("const normGrp = (g?: string | null) => (g && g.trim() ? g : null);\n");
        sb.append("const normOwner = (o?: number | null) => (typeof o === 'number' && Number.isFinite(o) ? o : null);\n\n");
        sb.append("function ").append(keyFnName).append("(")
          .append(react_primaryDateField).append(": string, grpCd?: string | null, ownerId?: number | null): QueryKey {\n");
        sb.append("    return ['").append(moduleCamel).append("/byDate', ")
          .append(react_primaryDateField).append(", normGrp(grpCd), normOwner(ownerId)];\n");
        sb.append("}\n\n");
        sb.append("/** 서버 응답 → 첫 레코드 추출 */\n");
        sb.append("function extractOne(v: unknown): ").append(moduleEntry).append(" | null {\n");
        sb.append("    const unwrapList = (x: unknown): unknown => {\n");
        sb.append("        if (Array.isArray(x)) return x;\n");
        sb.append("        if (isRec(x) && Array.isArray(x['result'])) return x['result'];\n");
        sb.append("        if (isRec(x) && Array.isArray(x['rows']))   return x['rows'];\n");
        sb.append("        if (isRec(x) && Array.isArray(x['list']))   return x['list'];\n");
        sb.append("        return x;\n");
        sb.append("    };\n\n");
        sb.append("    let cur: unknown = v;\n");
        sb.append("    for (let i = 0; i < 5; i++) {\n");
        sb.append("        const list = unwrapList(cur);\n");
        sb.append("        if (Array.isArray(list)) {\n");
        sb.append("            return list.length ? adaptIn").append(modulePascal).append("(list[0]) : null;\n");
        sb.append("        }\n");
        sb.append("        if (\n");
        sb.append("            isRec(cur) &&\n");
        sb.append("            (isRec(cur['result']) || isRec(cur['data']) || isRec(cur['item']))\n");
        sb.append("        ) {\n");
        sb.append("            cur = (cur['result'] as unknown)\n");
        sb.append("               || (cur['data'] as unknown)\n");
        sb.append("               || (cur['item'] as unknown);\n");
        sb.append("            continue;\n");
        sb.append("        }\n");
        sb.append("        break;\n");
        sb.append("    }\n");
        sb.append("    return isRec(cur) ? adaptIn").append(modulePascal).append("(cur) : null;\n");
        sb.append("}\n\n");

        // API 경로들
        sb.append("const API = {\n");
        sb.append("    selectByDate: '").append(apiBasePath).append("/").append(selectFnName).append("',\n");
        sb.append("    upsert:       '").append(apiBasePath).append("/").append(upsertFnName).append("',\n");
        sb.append("};\n\n");

        // fetcher
        sb.append("async function getByDate(")
          .append(react_primaryDateField).append(": string, grpCd?: string | null, ownerId?: number | null): Promise<")
          .append(moduleEntry).append(" | null> {\n");
        sb.append("    const payload = {\n");
        sb.append("        ").append(react_primaryDateField).append(",\n");
        sb.append("        grpCd: normGrp(grpCd),\n");
        sb.append("        ownerId: normOwner(ownerId),\n");
        sb.append("    };\n");
        sb.append("    const data = await postJson<unknown>(API.selectByDate, payload);\n");
        sb.append("    return extractOne(data);\n");
        sb.append("}\n\n");

        // useXxxByDate
        sb.append("export function ").append(hookSelectName)
          .append("(p: { ").append(react_primaryDateField).append(": string; grpCd?: string | null; ownerId?: number | null }) {\n");
        sb.append("    const ").append(react_primaryDateField).append(" = p.")
          .append(react_primaryDateField).append(";\n");
        sb.append("    const grpCd   = normGrp(p.grpCd ?? null);\n");
        sb.append("    const ownerId = normOwner(p.ownerId ?? null);\n\n");
        sb.append("    return useQuery<").append(moduleEntry).append(" | null, Error>({\n");
        sb.append("        queryKey: ").append(keyFnName).append("(")
          .append(react_primaryDateField).append(", grpCd, ownerId),\n");
        sb.append("        queryFn: () => getByDate(")
          .append(react_primaryDateField).append(", grpCd, ownerId),\n");
        sb.append("        enabled: ").append(enabledCond).append(",\n");
        sb.append("        retry: 0,\n");
        sb.append("        refetchOnWindowFocus: false,\n");
        sb.append("        refetchOnReconnect: false,\n");
        sb.append("        staleTime: 2000,\n");
        sb.append("    });\n");
        sb.append("}\n\n");

        // useUpsertXxx
        sb.append("export function ").append(hookUpsertName)
          .append("(ctx: { grpCd?: string | null; ownerId?: number | null }) {\n");
        sb.append("    const qc = useQueryClient();\n");
        sb.append("    const grpCd   = normGrp(ctx.grpCd ?? null);\n");
        sb.append("    const ownerId = normOwner(ctx.ownerId ?? null);\n\n");
        sb.append("    return useMutation<void, Error, ").append(upsertInput).append(">({\n");
        sb.append("        mutationFn: async (input) => {\n");
        sb.append("            const body: ").append(upsertInput).append(" = {\n");
        sb.append("                ").append(react_primaryDateField).append(": input.")
          .append(react_primaryDateField).append(",\n");
        sb.append("                content: (input as Record<string, unknown>)['content'] as string,\n");
        sb.append("                grpCd:   (input as Record<string, unknown>)['grpCd'] ?? grpCd ?? null,\n");
        sb.append("                ownerId: normOwner(((input as Record<string, unknown>)['ownerId'] as number | null) ?? ownerId),\n");
        sb.append("            };\n");
        sb.append("            await postJson<unknown>(API.upsert, body);\n");
        sb.append("        },\n");
        sb.append("        onSuccess: (_d, v) => {\n");
        sb.append("            const keyDate = (v as Record<string, unknown>)['")
          .append(react_primaryDateField).append("'];\n");
        sb.append("            const keyStr = typeof keyDate === 'string' ? keyDate.slice(0,10) : '';\n");
        sb.append("            if (keyStr) {\n");
        sb.append("                qc.invalidateQueries({ queryKey: ")
          .append(keyFnName).append("(keyStr, grpCd, ownerId) });\n");
        sb.append("            } else {\n");
        sb.append("                qc.invalidateQueries({ queryKey: ['")
          .append(moduleCamel).append("/byDate'] });\n");
        sb.append("            }\n");
        sb.append("        },\n");
        sb.append("    });\n");
        sb.append("}\n");

        return sb.toString();
    }

    /* ─────────────────────────────────────────────────────────────
     * React 템플릿 빌더: index.ts
     * ───────────────────────────────────────────────────────────── */
    private static String buildReactIndexTs(String moduleCamel) {
        StringBuilder sb = new StringBuilder();
        sb.append("// filepath: src/shared/").append(moduleCamel).append("/index.ts\n");
        sb.append("'use client';\n\n");
        sb.append("export * from './types';\n");
        sb.append("export * from './adapters';\n");
        sb.append("export * from './api/queries';\n");
        return sb.toString();
    }

    /* ─────────────────────────────────────────────────────────────
     * React 템플릿 빌더: page.tsx scaffold
     * (캘린더/에디터/저장 버튼 포함)
     * ───────────────────────────────────────────────────────────── */
    private static String buildReactPageTsx(String modulePascal, String moduleCamel) {
        // 예: Diary -> useDiaryByDate, useUpsertDiary
        String hookSelectName = "use" + modulePascal + react_hookSuffix;  // e.g. useDiaryByDate
        String hookUpsertName = "useUpsert" + modulePascal;               // e.g. useUpsertDiary
        String upsertInput    = modulePascal + "UpsertInput";             // e.g. DiaryUpsertInput
        String entryType      = modulePascal + "Entry";                   // e.g. DiaryEntry

        // 페이지 컴포넌트 이름 (DiaryPage)
        String pageComponent  = modulePascal + "Page";

        // 캘린더 row 높이 등(하드코딩으로 바로 문자열에 넣는다)
        String CAL_ROW_H_PX        = "56";
        String DAY_H_PX            = "32";
        String MIN_EDITOR_HEIGHT_PX= "420";

        StringBuilder sb = new StringBuilder();
        sb.append("// filepath: src/app/").append(moduleCamel).append("/page.tsx\n");
        sb.append("'use client';\n\n");
        sb.append("import { useEffect, useMemo, useRef, useState, type ComponentType } from 'react';\n");
        sb.append("import { useSearchParams } from 'next/navigation';\n");
        sb.append("import { ").append(hookSelectName).append(", ").append(hookUpsertName)
          .append(" } from '@/shared/").append(moduleCamel).append("';\n");
        sb.append("import type { ").append(entryType).append(", ").append(upsertInput)
          .append(" } from '@/shared/").append(moduleCamel).append("';\n");
        sb.append("import type { UseMutationResult, UseQueryResult } from '@tanstack/react-query';\n");
        sb.append("import { useOwnerIdValue } from '@/shared/core/owner';\n\n");

        sb.append("const PAGE_MAX_WIDTH = 1140;\n");
        sb.append("const MIN_EDITOR_HEIGHT = ").append(MIN_EDITOR_HEIGHT_PX).append(";\n");
        sb.append("const CAL_ROW_H = ").append(CAL_ROW_H_PX).append(";\n");
        sb.append("const DAY_H = ").append(DAY_H_PX).append(";\n\n");

        sb.append("const pad = (n: number) => (n < 10 ? `0${n}` : `${n}`);\n");
        sb.append("const toYMD = (d: Date) => `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())}`;\n\n");

        sb.append("function makeMonthMatrix(year: number, month0: number) {\n");
        sb.append("    const first = new Date(year, month0, 1);\n");
        sb.append("    const last = new Date(year, month0 + 1, 0);\n");
        sb.append("    const startIdx = first.getDay();\n");
        sb.append("    const total = last.getDate();\n");
        sb.append("    const rows: Date[][] = [];\n");
        sb.append("    let day = 1 - startIdx;\n");
        sb.append("    for (let r = 0; r < 6; r++) {\n");
        sb.append("        const row: Date[] = [];\n");
        sb.append("        for (let c = 0; c < 7; c++) row.push(new Date(year, month0, day++));\n");
        sb.append("        rows.push(row);\n");
        sb.append("        if (day > total && startIdx + total <= r * 7 + 6) break;\n");
        sb.append("    }\n");
        sb.append("    return rows;\n");
        sb.append("}\n\n");

        sb.append("const isRec = (v: unknown): v is Record<string, unknown> => typeof v === 'object' && v !== null;\n\n");

        // UploadAdapter
        sb.append("class UploadAdapter {\n");
        sb.append("    loader: { file: Promise<File> };\n");
        sb.append("    constructor(loader: { file: Promise<File> }) {\n");
        sb.append("        this.loader = loader;\n");
        sb.append("    }\n");
        sb.append("    async upload() {\n");
        sb.append("        const file = await this.loader.file;\n");
        sb.append("        const fd = new FormData();\n");
        sb.append("        fd.append('file', file);\n");
        sb.append("        const res = await fetch('/api/common/file/upload', { method: 'POST', body: fd });\n");
        sb.append("        const ct = (res.headers.get('content-type') || '').toLowerCase();\n");
        sb.append("        let url = '';\n");
        sb.append("        if (ct.includes('application/json')) {\n");
        sb.append("            const j = (await res.json()) as unknown;\n");
        sb.append("            if (isRec(j) && typeof j['url'] === 'string') url = j['url'];\n");
        sb.append("            if (!url && isRec(j) && typeof j['fileUrl'] === 'string') url = j['fileUrl'];\n");
        sb.append("            const r = isRec(j) && isRec(j['result']) ? j['result'] : null;\n");
        sb.append("            if (!url && r && typeof r['url'] === 'string') url = r['url'];\n");
        sb.append("            if (!url && r && typeof r['fileUrl'] === 'string') url = r['fileUrl'];\n");
        sb.append("        } else {\n");
        sb.append("            url = await res.text();\n");
        sb.append("        }\n");
        sb.append("        if (!url) throw new Error('no url');\n");
        sb.append("        return { default: url };\n");
        sb.append("    }\n");
        sb.append("    abort() {}\n");
        sb.append("}\n\n");

        sb.append("function CustomUploadAdapterPlugin(editor: {\n");
        sb.append("    plugins: { get(name: string): { createUploadAdapter?: (loader: { file: Promise<File> }) => unknown } };\n");
        sb.append("}) {\n");
        sb.append("    const repo = editor.plugins.get('FileRepository');\n");
        sb.append("    repo.createUploadAdapter = (loader: { file: Promise<File> }) => new UploadAdapter(loader);\n");
        sb.append("}\n\n");

        // CKEditor type defs
        sb.append("type CKEditorLike = {\n");
        sb.append("    getData(): string;\n");
        sb.append("    setData(s: string): void;\n");
        sb.append("    editing: {\n");
        sb.append("        view: {\n");
        sb.append("            document: { getRoot(): unknown };\n");
        sb.append("            change(cb: (writer: { setStyle: (prop: string, val: string, element: unknown) => void }) => void): void;\n");
        sb.append("        };\n");
        sb.append("    };\n");
        sb.append("};\n\n");

        sb.append("type CKEditorProps = {\n");
        sb.append("    editor: unknown;\n");
        sb.append("    data?: string;\n");
        sb.append("    onChange?: (evt: unknown, editor: CKEditorLike) => void;\n");
        sb.append("    onReady?: (editor: unknown) => void;\n");
        sb.append("    config?: unknown;\n");
        sb.append("};\n");
        sb.append("type CKEditorComponent = ComponentType<CKEditorProps>;\n\n");

        // safe pick
        sb.append("function pickHtmlSafe(v: ").append(entryType).append(" | null | undefined): string {\n");
        sb.append("    if (!v) return '';\n");
        sb.append("    const bodyVal = (typeof v['content'] === 'string' && v['content'])\n");
        sb.append("        || (typeof v['body'] === 'string' && v['body'])\n");
        sb.append("        || '';\n");
        sb.append("    return bodyVal;\n");
        sb.append("}\n\n");

        // component
        sb.append("export default function ").append(pageComponent).append("() {\n");
        sb.append("    const today = useMemo(() => new Date(), []);\n");
        sb.append("    const [viewYear, setViewYear] = useState(today.getFullYear());\n");
        sb.append("    const [viewMonth0, setViewMonth0] = useState(today.getMonth());\n");
        sb.append("    const [selected, setSelected] = useState(toYMD(today));\n\n");

        sb.append("    const searchParams = useSearchParams();\n");
        sb.append("    const grpCdParam = searchParams.get('grpCd') ?? undefined;\n");
        sb.append("    const grpCd: string | null = grpCdParam ?? null;\n\n");

        sb.append("    const ownerIdParam = useOwnerIdValue() ?? undefined;\n");
        sb.append("    const ownerId: number | null = ownerIdParam ?? null;\n\n");

        sb.append("    const q: UseQueryResult<").append(entryType).append(" | null, Error> = ")
          .append(hookSelectName).append("({\n");
        sb.append("        ").append(react_primaryDateField).append(": selected,\n"); // <- this still depends on react_primaryDateField
        sb.append("        grpCd,\n");
        sb.append("        ownerId,\n");
        sb.append("    });\n\n");

        sb.append("    const upsert: UseMutationResult<void, Error, ").append(upsertInput).append(", unknown> = ")
          .append(hookUpsertName).append("({ grpCd, ownerId });\n\n");

        sb.append("    const isBusy = q.isLoading || q.isFetching;\n\n");

        sb.append("    const [CKE, setCKE] = useState<null | { CKEditor: CKEditorComponent; ClassicEditor: unknown }>(null);\n");
        sb.append("    const editorRef = useRef<CKEditorLike | null>(null);\n");
        sb.append("    const settingByCode = useRef(false);\n\n");

        sb.append("    useEffect(() => {\n");
        sb.append("        let mounted = true;\n");
        sb.append("        (async () => {\n");
        sb.append("            const m = await import('@ckeditor/ckeditor5-react');\n");
        sb.append("            const CKEditor = (m as unknown as { CKEditor: CKEditorComponent }).CKEditor;\n");
        sb.append("            const ClassicEditor = (await import('@ckeditor/ckeditor5-build-classic')).default as unknown;\n");
        sb.append("            if (mounted) {\n");
        sb.append("                setCKE({ CKEditor, ClassicEditor });\n");
        sb.append("            }\n");
        sb.append("        })();\n");
        sb.append("        return () => {\n");
        sb.append("            mounted = false;\n");
        sb.append("        };\n");
        sb.append("    }, []);\n\n");

        sb.append("    const [content, setContent] = useState('');\n");
        sb.append("    useEffect(() => {\n");
        sb.append("        if (isBusy) return;\n");
        sb.append("        setContent(pickHtmlSafe(q.data));\n");
        sb.append("    }, [isBusy, q.data, selected]);\n\n");

        sb.append("    useEffect(() => {\n");
        sb.append("        const ed = editorRef.current;\n");
        sb.append("        if (!ed) return;\n");
        sb.append("        const cur = ed.getData() ?? '';\n");
        sb.append("        if (cur !== content) {\n");
        sb.append("            settingByCode.current = true;\n");
        sb.append("            ed.setData(content || '');\n");
        sb.append("            setTimeout(() => {\n");
        sb.append("                settingByCode.current = false;\n");
        sb.append("            }, 0);\n");
        sb.append("        }\n");
        sb.append("    }, [content]);\n\n");

        sb.append("    const onSave = async () => {\n");
        sb.append("        const body: ").append(upsertInput).append(" = {\n");
        sb.append("            ").append(react_primaryDateField).append(": selected,\n");
        sb.append("            content: content || '',\n");
        sb.append("            grpCd,\n");
        sb.append("            ownerId,\n");
        sb.append("        };\n");
        sb.append("        await upsert.mutateAsync(body);\n");
        sb.append("        alert('저장되었습니다.');\n");
        sb.append("    };\n\n");

        sb.append("    const matrix = useMemo(() => makeMonthMatrix(viewYear, viewMonth0), [viewYear, viewMonth0]);\n");
        sb.append("    const moveMonth = (d: number) => {\n");
        sb.append("        let m = viewMonth0 + d;\n");
        sb.append("        let y = viewYear;\n");
        sb.append("        if (m < 0) { m = 11; y--; }\n");
        sb.append("        if (m > 11) { m = 0; y++; }\n");
        sb.append("        setViewYear(y);\n");
        sb.append("        setViewMonth0(m);\n");
        sb.append("    };\n");
        sb.append("    const pick = (d: Date) => setSelected(toYMD(d));\n\n");

        sb.append("    const goToday = () => {\n");
        sb.append("        const t = new Date();\n");
        sb.append("        setViewYear(t.getFullYear());\n");
        sb.append("        setViewMonth0(t.getMonth());\n");
        sb.append("        setSelected(toYMD(t));\n");
        sb.append("    };\n\n");

        sb.append("    return (\n");
        sb.append("        <div className=\"").append(moduleCamel).append("-root\" style={{ maxWidth: PAGE_MAX_WIDTH, margin: '0 auto', padding: 16 }}>\n");
        sb.append("            {/* 헤더 */}\n");
        sb.append("            <div className=\"header\">\n");
        sb.append("                <div className=\"nav\">\n");
        sb.append("                    <button className=\"btn-icon\" onClick={() => moveMonth(-1)} aria-label=\"이전 달\">«</button>\n");
        sb.append("                    <div className=\"month\">{viewYear}. {pad(viewMonth0 + 1)}</div>\n");
        sb.append("                    <button className=\"btn-icon\" onClick={() => moveMonth(1)} aria-label=\"다음 달\">»</button>\n");
        sb.append("                </div>\n");
        sb.append("                <div className=\"ctrl\">\n");
        sb.append("                    <button className=\"pill\" onClick={goToday}>오늘</button>\n");
        sb.append("                    <div className=\"pill pill-ghost\">선택: <b>{selected}</b></div>\n");
        sb.append("                    <button className=\"btn-primary\" onClick={onSave} disabled={upsert.isPending}>\n");
        sb.append("                        {upsert.isPending ? '저장중…' : '저장'}\n");
        sb.append("                    </button>\n");
        sb.append("                </div>\n");
        sb.append("            </div>\n\n");

        sb.append("            {/* 달력 */}\n");
        sb.append("            <div className=\"calendar-wrap\" style={{ border: '1px solid #e9edf3', borderRadius: 12, overflow: 'hidden', marginBottom: 12 }}>\n");
        sb.append("                <table className=\"").append(moduleCamel).append("-calendar\">\n");
        sb.append("                    <thead><tr>{['일','월','화','수','목','금','토'].map((d) => <th key={d}>{d}</th>)}</tr></thead>\n");
        sb.append("                    <tbody>\n");
        sb.append("                    {matrix.map((row, ri) => (\n");
        sb.append("                        <tr key={ri}>\n");
        sb.append("                            {row.map((d, ci) => {\n");
        sb.append("                                const inMonth = d.getMonth() === viewMonth0;\n");
        sb.append("                                const dayStr = toYMD(d);\n");
        sb.append("                                const isSel = dayStr === selected;\n");
        sb.append("                                const isToday = toYMD(d) === toYMD(today);\n");
        sb.append("                                return (\n");
        sb.append("                                    <td key={ci} title={dayStr} onClick={() => pick(d)}>\n");
        sb.append("                                        <div\n");
        sb.append("                                            className=\"day\"\n");
        sb.append("                                            style={{\n");
        sb.append("                                                background: isSel ? '#111827' : undefined,\n");
        sb.append("                                                color: isSel ? '#fff' : isToday ? '#111827' : inMonth ? '#0f172a' : '#9aa4b2',\n");
        sb.append("                                                border: !isSel && isToday ? '1px solid #111827' : undefined,\n");
        sb.append("                                            }}\n");
        sb.append("                                        >\n");
        sb.append("                                            {d.getDate()}\n");
        sb.append("                                        </div>\n");
        sb.append("                                    </td>\n");
        sb.append("                                );\n");
        sb.append("                            })}\n");
        sb.append("                        </tr>\n");
        sb.append("                    ))}\n");
        sb.append("                    </tbody>\n");
        sb.append("                </table>\n");
        sb.append("            </div>\n\n");

        sb.append("            {/* 로딩 배지 */}\n");
        sb.append("            {isBusy && (\n");
        sb.append("                <div className=\"loadingPill\">\n");
        sb.append("                    <span className=\"dot\" />\n");
        sb.append("                    불러오는 중…\n");
        sb.append("                </div>\n");
        sb.append("            )}\n\n");

        sb.append("            {/* CKEditor */}\n");
        sb.append("            <div className=\"editorCard\" style={{ border: '1px solid #e9edf3', borderRadius: 12, padding: 12, background: '#fff' }}>\n");
        sb.append("                {CKE ? (\n");
        sb.append("                    <CKE.CKEditor\n");
        sb.append("                        key={`").append(moduleCamel).append("-${selected}`}\n");
        sb.append("                        editor={CKE.ClassicEditor}\n");
        sb.append("                        data={content}\n");
        sb.append("                        onChange={(_evt, editor) => {\n");
        sb.append("                            if (settingByCode.current) return;\n");
        sb.append("                            setContent(editor.getData());\n");
        sb.append("                        }}\n");
        sb.append("                        onReady={(editor) => {\n");
        sb.append("                            const ed = editor as CKEditorLike;\n");
        sb.append("                            editorRef.current = ed;\n");
        sb.append("                            const view = ed.editing.view;\n");
        sb.append("                            const root = view.document.getRoot();\n");
        sb.append("                            view.change((writer) => {\n");
        sb.append("                                writer.setStyle('min-height', `${MIN_EDITOR_HEIGHT}px`, root);\n");
        sb.append("                            });\n");
        sb.append("                            if (content && ed.getData() !== content) {\n");
        sb.append("                                settingByCode.current = true;\n");
        sb.append("                                ed.setData(content);\n");
        sb.append("                                setTimeout(() => {\n");
        sb.append("                                    settingByCode.current = false;\n");
        sb.append("                                }, 0);\n");
        sb.append("                            }\n");
        sb.append("                        }}\n");
        sb.append("                        config={{ placeholder: '내용을 작성하세요…', extraPlugins: [CustomUploadAdapterPlugin] }}\n");
        sb.append("                    />\n");
        sb.append("                ) : (\n");
        sb.append("                    <div style={{ padding: 12, color: '#6b7280' }}>에디터 로딩 중…</div>\n");
        sb.append("                )}\n");
        sb.append("                <div className=\"hint\">이미지는 에디터의 이미지 버튼/붙여넣기로 업로드됩니다.</div>\n");
        sb.append("            </div>\n\n");

        // styled-jsx 내부에서는 상수 이름 안 쓰고 숫자(px) 박음
        sb.append("            <style jsx>{`\n");
        sb.append("                .header{\n");
        sb.append("                    display:flex; align-items:center; justify-content:space-between;\n");
        sb.append("                    gap:12px; flex-wrap:wrap; margin-bottom:12px;\n");
        sb.append("                }\n");
        sb.append("                .nav{ display:flex; align-items:center; gap:8px; }\n");
        sb.append("                .month{ font-size:18px; font-weight:700; color:#0f172a; }\n");
        sb.append("                .btn-icon{\n");
        sb.append("                    width:38px; height:38px; border-radius:10px; border:1px solid #e5e7eb;\n");
        sb.append("                    background:#fff; line-height:38px; text-align:center;\n");
        sb.append("                }\n");
        sb.append("                .ctrl{ display:flex; align-items:center; gap:8px; flex-wrap:wrap; }\n");
        sb.append("                .pill{\n");
        sb.append("                    height:38px; display:inline-flex; align-items:center; gap:6px;\n");
        sb.append("                    padding:0 12px; border-radius:999px; border:1px solid #e5e7eb;\n");
        sb.append("                    background:#fff; color:#111827; font-size:14px;\n");
        sb.append("                }\n");
        sb.append("                .pill-ghost{ background:#f8fafc; }\n");
        sb.append("                .btn-primary{\n");
        sb.append("                    height:38px; padding:0 14px; border-radius:10px; background:#111827;\n");
        sb.append("                    color:#fff; font-weight:700; border:none;\n");
        sb.append("                }\n");
        sb.append("                .btn-primary[disabled]{ opacity:.6; }\n");
        sb.append("                @media (max-width: 560px){\n");
        sb.append("                    .ctrl{ width:100%; justify-content:flex-end; }\n");
        sb.append("                    .pill-ghost{ flex:1; min-width:220px; justify-content:center; }\n");
        sb.append("                }\n");
        sb.append("                .").append(moduleCamel).append("-calendar { width: 100%; table-layout: fixed; border-collapse: collapse; }\n");
        sb.append("                .").append(moduleCamel).append("-calendar thead tr { background: #f8fafc; color: #0f172a; }\n");
        sb.append("                .").append(moduleCamel).append("-calendar th { padding: 10px 0; font-weight: 700; }\n");
        sb.append("                .").append(moduleCamel).append("-calendar td {\n");
        sb.append("                    height: ").append(CAL_ROW_H_PX).append("px !important;\n");
        sb.append("                    padding: 0;\n");
        sb.append("                    text-align: center;\n");
        sb.append("                    border-top: 1px solid #f1f3f7;\n");
        sb.append("                    vertical-align: middle;\n");
        sb.append("                    cursor: pointer;\n");
        sb.append("                }\n");
        sb.append("                .").append(moduleCamel).append("-calendar td .day {\n");
        sb.append("                    display: inline-flex;\n");
        sb.append("                    align-items: center;\n");
        sb.append("                    justify-content: center;\n");
        sb.append("                    min-width: 32px;\n");
        sb.append("                    height: ").append(DAY_H_PX).append("px;\n");
        sb.append("                    line-height: ").append(DAY_H_PX).append("px;\n");
        sb.append("                    padding: 0 6px;\n");
        sb.append("                    border-radius: 16px;\n");
        sb.append("                    user-select: none;\n");
        sb.append("                }\n");
        sb.append("                .loadingPill{\n");
        sb.append("                    display:inline-flex; align-items:center; gap:6px; padding:6px 10px;\n");
        sb.append("                    border:1px solid #e5e7eb; border-radius:999px; background:#f8fafc; color:#374151;\n");
        sb.append("                    font-size:12px; margin-bottom:8px;\n");
        sb.append("                }\n");
        sb.append("                .loadingPill .dot{\n");
        sb.append("                    width:8px; height:8px; border-radius:999px;\n");
        sb.append("                    box-shadow:0 0 0 2px rgba(96,165,250,.25); background:#60a5fa;\n");
        sb.append("                }\n");
        sb.append("                .hint{ margin-top:8px; color:#6b7280; font-size:12px; }\n");
        sb.append("            `}</style>\n\n");

        // global 스타일에서도 숫자 리터럴 바로
        sb.append("            <style jsx global>{`\n");
        sb.append("                .ck-editor { width: 100%; }\n");
        sb.append("                .ck-editor__editable_inline { min-height: ").append(MIN_EDITOR_HEIGHT_PX).append("px; }\n");
        sb.append("                .ck.ck-editor__main > .ck-editor__editable { padding: 16px 18px; }\n");
        sb.append("                .ck-content { min-height: ").append(MIN_EDITOR_HEIGHT_PX).append("px; }\n");
        sb.append("            `}</style>\n");

        sb.append("        </div>\n");
        sb.append("    );\n");
        sb.append("}\n");

        return sb.toString();
    }

    /* ─────────────────────────────────────────────────────────────
     * 이하: ReactGen / 전체 유틸 / DB 메타 / 공통 유틸
     * ───────────────────────────────────────────────────────────── */

    // CSV 파서를 단순하게
    private static List<String> csvToList(String csv) {
        List<String> out = new ArrayList<>();
        if (csv == null || csv.trim().isEmpty()) return out;
        String[] arr = csv.split(",");
        for (String a : arr) {
            String t = a.trim();
            if (!t.isEmpty()) out.add(t);
        }
        return out;
    }

    // middle_pk_in_name="tsk.diary" → "tsk"
    private static String getBizSeg() {
        if (isBlank(middle_pk_in_name)) return "tsk";
        int i = middle_pk_in_name.indexOf('.');
        return (i >= 0) ? middle_pk_in_name.substring(0, i) : middle_pk_in_name;
    }

    /* 이하 createMapperJava/createImpl/createVO는 아직 미사용, 자리만 유지 */
    private static void createMapperJava() { /* 미사용 - 자리만 남김 */ }
    private static void createImpl()       { /* 미사용 - 자리만 남김 */ }
    private static void createVO()         { /* 미사용 - 자리만 남김 */ }

    /* ─────────────────────────────────────────────────────────────
     * DB 메타 조회
     * ───────────────────────────────────────────────────────────── */
    private static HashMap<String, String> getTableMap() {
    if (db_list != null) return db_map;

    Connection conn = null;
    ResultSet rs = null;

    List<String> arrList = new ArrayList<>();
    HashMap<String, String> columnMap = new HashMap<>();

    try {
        Properties info = new Properties();
        info.put("remarksReporting", "true");

        // MySQL/MariaDB 계열은 JDBC 메타에서 REMARKS(컬럼 COMMENT)가 비는 경우가 많아서,
        // 1) useInformationSchema 활성화
        // 2) 그래도 비면 information_schema.columns로 fallback
        if (isMySQLFamily()) {
            info.put("useInformationSchema", "true");
        }

        info.put("user", user);
        info.put("password", password);

        Class.forName(driver);
        conn = DriverManager.getConnection(server_ip, info);

        DatabaseMetaData meta = conn.getMetaData();

        String catalog = null;
        try {
            String url = server_ip;
            int s = url.lastIndexOf('/');
            if (s >= 0) {
                catalog = url.substring(s + 1);
                int q = catalog.indexOf('?');
                if (q >= 0) catalog = catalog.substring(0, q);
            }
        } catch (Exception ignore) {}

        // MySQL/MariaDB fallback: information_schema.columns에서 컬럼 코멘트 직접 조회
        Map<String, String> mysqlCommentMap = null;
        if (isMySQLFamily()) {
            mysqlCommentMap = loadMySqlColumnComments(conn, catalog, db_table);
        }

        rs = meta.getColumns(catalog, null, db_table, "%");

        while (rs.next()) {
            String col = rs.getString("COLUMN_NAME");
            String typeName = rs.getString("TYPE_NAME");
            String remark = rs.getString("REMARKS");

            if ((remark == null || remark.trim().isEmpty()) && mysqlCommentMap != null && col != null) {
                String cm = mysqlCommentMap.get(col);
                if (cm != null) remark = cm;
            }

            String sTypeStr = detectTypeFromTypeName(typeName);

            columnMap.put(col, sTypeStr + "#" + (remark != null ? remark : ""));
            arrList.add(col);
        }

        if (arrList.isEmpty()) {
            System.out.println("[JavaGen][WARN] DB 메타 결과가 비었습니다. fallback으로 PK만 사용합니다.");
            arrList.add(db_key);
            columnMap.put(db_key, "string#");
        }

        db_list = arrList;
        db_map = columnMap;

    } catch (Exception e) {
        System.out.println("[JavaGen][WARN] DB 메타 조회 실패: " + e.getMessage());
        db_list = new ArrayList<>();
        db_list.add(db_key);
        db_map = new HashMap<>();
        db_map.put(db_key, "string#");
    } finally {
        try { if (rs != null) rs.close(); } catch (Exception ignore) {}
        try { if (conn != null) conn.close(); } catch (Exception ignore) {}
    }
    return db_map;
}

private static String detectTypeFromTypeName(String typeName) {
    if (typeName == null) return "string";
    String t = typeName.toUpperCase();

    // 긴 텍스트/JSON은 textarea/editor로 쓰는 케이스가 많아서 clob 취급
    if (t.contains("TEXT") || t.contains("CLOB") || t.contains("BLOB") || t.contains("JSON")) {
        return "clob";
    }

    // 숫자 전반을 number(input type="number")로 처리하기 위해 int 그룹으로 묶음
    if (t.matches(".*(TINYINT|SMALLINT|MEDIUMINT|INT|INTEGER|BIGINT|NUMBER|DECIMAL|NUMERIC|FLOAT|DOUBLE|REAL).*")) {
        return "int";
    }

    return "string";
}

private static Map<String, String> loadMySqlColumnComments(Connection conn, String catalog, String tableName) {
    Map<String, String> map = new HashMap<>();
    if (conn == null || tableName == null || tableName.trim().isEmpty()) return map;

    String schema = (catalog != null && !catalog.trim().isEmpty()) ? catalog : null;
    try {
        if (schema == null || schema.trim().isEmpty()) {
            schema = conn.getCatalog();
        }
    } catch (Exception ignore) {}

    if (schema == null || schema.trim().isEmpty()) return map;

    String sql =
        "SELECT COLUMN_NAME, COLUMN_COMMENT " +
        "  FROM information_schema.COLUMNS " +
        " WHERE TABLE_SCHEMA = ? " +
        "   AND TABLE_NAME = ?";

    try (PreparedStatement ps = conn.prepareStatement(sql)) {
        ps.setString(1, schema);
        ps.setString(2, tableName);

        try (ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                String col = rs.getString(1);
                String cmt = rs.getString(2);
                if (col != null && cmt != null && !cmt.trim().isEmpty()) {
                    map.put(col, cmt);
                }
            }
        }
    } catch (Exception e) {
        System.out.println("[JavaGen][WARN] MySQL column_comment 조회 실패: " + e.getMessage());
    }

    return map;
}

    /* ─────────────────────────────────────────────────────────────
     * 유틸
     * ───────────────────────────────────────────────────────────── */

    private static String convert2CamelCase(String underScore) {
        if (underScore.indexOf('_') < 0 && Character.isLowerCase(underScore.charAt(0)))
            return underScore;
        StringBuilder result = new StringBuilder();
        boolean nextUpper = false;
        int len = underScore.length();
        for (int i = 0; i < len; i++) {
            char c = underScore.charAt(i);
            if (c == '_') {
                nextUpper = true;
                continue;
            }
            if (nextUpper) {
                result.append(Character.toUpperCase(c));
                nextUpper = false;
            } else {
                result.append(Character.toLowerCase(c));
            }
        }
        return result.toString();
    }

    private static String toLowerCamel(String s) {
        if (s == null || s.isEmpty()) return s;
        return Character.toLowerCase(s.charAt(0)) + s.substring(1);
    }

    private static String lcFirst(String s) {
        return toLowerCamel(s);
    }

    private static boolean isBlank(String s) {
        return s == null || s.trim().isEmpty();
    }

    private static boolean isMySQLFamily() {
        String t = (dbType == null) ? "" : dbType.toLowerCase();
        return t.contains("mysql") || t.contains("mariadb");
    }

    private static boolean isDateLike(String upperName) {
        // 자주 쓰는 패턴 확장 가능
        return upperName.endsWith("_DATE")
            || upperName.endsWith("_DT")
            || upperName.endsWith("_TIME");
    }

    /**
     * MySQL DATETIME 문자열 파서
     * bindParam -> "STR_TO_DATE(...)"
     */
    private static String mysqlDateParseExpr(String camelParamName) {
        String bind = "#{" + camelParamName + "}";
        // 1) 'T'→' ' 2) 밀리초 제거 3) 'Z' 제거
        String norm =
            "REPLACE(REPLACE(SUBSTRING_INDEX(REPLACE(" + bind + ", 'T',' '), '.', 1),'Z',''),'T',' ')";
        // 4) 초 없으면 ':00' 보강
        String padSec =
            "CONCAT(" + norm + ", CASE WHEN LENGTH(" + norm + ")=16 THEN ':00' ELSE '' END)";
        // 빈문자열이면 NULL
        return "STR_TO_DATE(NULLIF(" + padSec + ",''), '%Y-%m-%d %H:%i:%s')";
    }

    /** INSERT 전용: NULL/빈값이면 NOW() */
    private static String mysqlDateInsertExpr(String camelParamName) {
        return "IFNULL(" + mysqlDateParseExpr(camelParamName) + ", NOW())";
    }
}
