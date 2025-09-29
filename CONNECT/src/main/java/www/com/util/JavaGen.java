package www.com.util;

import java.io.File;
import java.io.IOException;
import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

/**
 * <pre>
 * Project-Optimized JavaGen
 *  - VO/Interface/Impl 제거(옵션)
 *  - Controller + Service + Mapper XML 생성
 *  - HashMap 기반, 우리식 namespace 치환
 *  - DB 메타에서 컬럼 자동 추출 (env 우선)
 * </pre>
 */
public class JavaGen {

    /******************************************************************
     * 0) 생성 스위치
     ******************************************************************/
    private static final boolean GEN_CONTROLLER = true;
    private static final boolean GEN_SERVICE    = true;
    private static final boolean GEN_MAPPER_XML = true;

    // 확장 필요 시 ON
    private static final boolean GEN_DAO_JAVA   = false; // (안씀)
    private static final boolean GEN_IMPL       = false; // (안씀)
    private static final boolean GEN_VO         = false; // (안씀)
    
 // === JSP 생성 스위치 ===
    private static final boolean GEN_JSP        = true;
    private static final boolean JSP_OVERWRITE  = false; // true로 바꾸면 기존 파일 덮어씀

 // === JSP 연결 Web Controller 생성 ===
    private static final boolean GEN_WEB_CONTROLLER = true;

    // 템플릿 루트(컨트롤러용)  ※ api용(template_do_path)와 분리
    private static String template_web_root = "/www/smp";

    // 출력 패스/클래스명
    private static String web_ui_path, web_ui_java_name;
    
    // === JSP 템플릿/타겟 경로(웹 루트 기준) ===
    private static String jsp_template_root = "/WEB-INF/jsp/www/smp/sample";
    private static String jsp_target_base   = "/WEB-INF/jsp/www";

    /******************************************************************
     * 1) 프로젝트/모듈 설정
     ******************************************************************/
    private static String full_path= "/src/main/java";
    private static String up_pk_name ="www";          // 최상위 패키지
    private static String middle_pk_name = "api/bbs"; // 중분류 (슬래시 구분)
    private static String down_pk_name = "board";     // 하위 모듈(패키지) : 기본값(없으면 service_name lowerCamel 사용)

    private static String middle_pk_in_name = "bbs.board"; // 중분류 (슬래시 구분)
    
    
    private static String service_name = "Board";     // 모듈명(클래스 접두) : 대문자 시작 (예: Board, RankingGrp)
    private static String unitBizName  = "basic";
    private static String NaDa         = "정지균";	
    private static String screenTitle  = "게시판";
    private static String functionDesc = "CRUD";

    private static String db_table = "board";         // 테이블명
    private static String db_key   = "BOARD_IDX";            // PK 컬럼명(대문자 권장)

    // Controller 템플릿에서 쓰던 토큰 유지 (필요 시/템플릿에 있을 때만 치환)
    private static String db_idx = "get" + service_name + "Idx";

    /******************************************************************
     * 2) DB 연결(환경변수 우선) : JAVA_GEN_DB_*
     ******************************************************************/
    private static String dbType   = env("JAVA_GEN_DB_TYPE", "mysql");
    private static String driver   = env("JAVA_GEN_DB_DRIVER", "com.mysql.cj.jdbc.Driver");
    private static String user     = env("JAVA_GEN_DB_USER", "root");
    private static String password = env("JAVA_GEN_DB_PASSWORD", "1234");
    private static String server_ip= env("JAVA_GEN_DB_URL", "jdbc:mysql://127.0.0.1:3306/nfi");

    /******************************************************************
     * 3) 내부 경로/치환 설정 (건드리지 마세요)
     ******************************************************************/
    private static String maxUp_pkg_name = "www/api/bbs/board";    // www/api/bbs/board
    private static String service_templat_name = "Template";
    private static String template_do_path = "/www/api/smp/sample"; // 템플릿 루트

    private static String service_path, service_java_name;
    private static String web_path, web_java_name;

    private static String ctrlDescription = screenTitle+" 위한 클래스로 "+functionDesc+"에 대한 컨트롤을 관리한다.";
    private static String servDescription = screenTitle+" 위한 클래스로 "+functionDesc+"에 대한 서비스를 관리한다.";
    private static String implDescription = screenTitle+" 위한 클래스로 "+functionDesc+"에 대한 비지니스 로직을 처리한다.";
    private static String daoDescription  = screenTitle+" 정보를 DB에서  "+functionDesc+" 처리한다.";

    private static String makeDayDescription="";
    private static FileUtil2 fn = null ;

    // 템플릿 내 패키지 플레이스홀더(정규식) → 실제 패키지
    private static String template_pkg_path="res[.]template[.]";

    public static void main(String[] args) {
        StringUtil2 st= new StringUtil2(); 
        makeDayDescription = st.getDate();
        fn  = new FileUtil2();
        try { 
            File file = new File(".");
            full_path = file.getCanonicalPath()+ full_path;    // 물리 경로
        } catch (IOException e) {
            e.printStackTrace();
        }

        // down_pk_name 자동 보완 (없으면 service_name lowerCamel)
        if (isBlank(down_pk_name)) {
            down_pk_name = toLowerCamel(service_name);
        }

        // 패키지 경로/파일명 세팅
        getPaths();

        // 생성
        if (GEN_CONTROLLER) createController();
        if (GEN_SERVICE)    createService();
        if (GEN_MAPPER_XML) createSql();
        
        // ▼ JSP 생성
        if (GEN_JSP) createJsp();

        // 확장 OFF(필요시 ON)
        if (GEN_DAO_JAVA)   createMapperJava();
        if (GEN_IMPL)       createImpl();
        if (GEN_VO)         createVO();

        if (GEN_WEB_CONTROLLER) createWebController(); // ★ JSP 연결 컨트롤러
        
        System.out.println("=====================================================");
        System.out.println("생성이 완료되었습니다. 템플릿/치환 결과를 확인하세요.");
        System.out.println("=====================================================");
    }

    private static void getPaths() {
        StringBuilder br = new StringBuilder();

        // 패키지 경로 www/api/bbs/board
        br.append(up_pk_name);
        if (!"".equals(middle_pk_name)) {
            br.append("/").append(middle_pk_name);
        }
        if (!"".equals(down_pk_name)) {
            br.append("/").append(down_pk_name);
        }
        maxUp_pkg_name = br.toString();

        // Controller
        web_path = full_path + "/" + maxUp_pkg_name + "/web/";
        web_java_name = service_name + "Controller";

        // Service (단일 클래스)
        service_path = full_path + "/" + maxUp_pkg_name + "/service/";
        service_java_name = service_name + "Service";
        
        // ★ Web(JSP) Controller 패키지: www/{bbs}/web  → 예) www/bbs/web
        String bizSeg = getBizSeg(); // ex) bbs
        web_ui_path = full_path + "/" + up_pk_name + "/" + bizSeg + "/web/";
        web_ui_java_name = "Web" + service_name + "Controller"; // ex) WebBoardController
    }

    /** JSP 연결 Web 컨트롤러 생성 (www.bbs.web.Web{Service}Controller) */
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

            String bizSeg  = getBizSeg(); // ex) bbs
            String bizPath = (isBlank(middle_pk_in_name) ? bizSeg : middle_pk_in_name).replace(".", "/"); // ex) bbs/board

            String s = fn.readText(original_java);
            s = s.replaceAll("www[.]smp[.]web", up_pk_name + "." + bizSeg + ".web");
            s = s.replace("WebTemplateController", web_ui_java_name);
            s = s.replace("Template",  service_name);          // Board
            s = s.replace("template",  toLowerCamel(service_name)); // board
            s = s.replace("BIZ_SEG",   bizSeg);                // bbs
            s = s.replace("BIZ_PATH",  bizPath);               // bbs/board
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
    
    /** 컨트롤러 생성   */
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

            // 패키지/이름 치환
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

    /** 서비스(단일 클래스) 생성 */
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

    /** Mapper XML 생성 (resources/.../Template.xml → *Sql.xml) */
    private static void createSql() {
        try {
            String original_xml = full_path.replace("java", "resources") + "/config/www/sqlmap/oracle/Template.xml";
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

            // DB 메타에서 토큰 채우기 (db_list 세팅)
            HashMap columnMap = getTableMap();
            List<String> cols = db_list; // 대문자 컬럼명 리스트

            StringBuilder columns_      = new StringBuilder(); // SELECT 컬럼
            StringBuilder columnsAdd_   = new StringBuilder(); // INSERT 컬럼
            StringBuilder values_       = new StringBuilder(); // INSERT VALUES
            StringBuilder columnUpdate_ = new StringBuilder(); // UPDATE SET 절(동적)

            for (String key : cols) {
                String U = key.toUpperCase();               // DB 컬럼(대문자)
                String camel = convert2CamelCase(U);        // 파라미터명(카멜)

                // --- SELECT: 날짜 컬럼은 문자열로 포맷해서 반환 (MySQL/MariaDB일 때) ---
                if (columns_.length() > 0) columns_.append("\t\t\t,");
                if (isMySQLFamily() && isDateLike(U)) {
                    columns_.append("DATE_FORMAT(").append(U).append(", '%Y-%m-%d %H:%i:%s') AS ").append(U).append("\n");
                } else {
                    columns_.append(U).append("\n");
                }

                // PK는 INSERT/UPDATE 대상에서 제외
                if (db_key.equalsIgnoreCase(U)) continue;

                // --- INSERT: 컬럼/값 ---
                if (columnsAdd_.length() > 0) columnsAdd_.append("\t\t\t,");
                columnsAdd_.append(U).append("\n");

                if (values_.length() > 0) values_.append("\t\t\t,");
                if (isMySQLFamily() && isDateLike(U)) {
                    // 문자열(yyyy-MM-dd HH:mm:ss) → DATETIME, 값 없으면 NOW()
                    values_.append("IFNULL(STR_TO_DATE(#{" + camel + "}, '%Y-%m-%d %H:%i:%s'), NOW())\n");
                } else {
                    values_.append("#{").append(camel).append("}\n");
                }

                // --- UPDATE: 넘어온 값만 세팅 (문자열 → 날짜 변환 포함) ---
                columnUpdate_.append("\t\t\t<if test='").append(camel).append(" != null and ").append(camel).append(" != \"\"'>\n");
                if (isMySQLFamily() && isDateLike(U)) {
                    columnUpdate_.append("\t\t\t\t").append(U)
                                 .append(" = STR_TO_DATE(#{").append(camel).append("}, '%Y-%m-%d %H:%i:%s'),\n");
                } else {
                    columnUpdate_.append("\t\t\t\t").append(U).append(" = #{").append(camel).append("},\n");
                }
                columnUpdate_.append("\t\t\t</if>\n");
            }

            // 토큰 치환
            newLine = newLine.replaceAll("values_",        values_.toString());
            newLine = newLine.replaceAll("columnsAdd_",    columnsAdd_.toString());
            newLine = newLine.replaceAll("columns_",       columns_.toString());
            newLine = newLine.replaceAll("table_",         db_table);
            newLine = newLine.replaceAll("columnUpdate_",  columnUpdate_.toString());
            newLine = newLine.replaceAll("columnId_",      db_key.toUpperCase());
            newLine = newLine.replaceAll("valueId_",       "#{" + convert2CamelCase(db_key) + "}");

            // 패키지/네임스페이스/명칭 치환
            newLine = newLine.replaceAll("com.basic.admin.sample", maxUp_pkg_name.replaceAll("/", "."));
            newLine = newLine.replaceAll("Template", service_name);
            newLine = newLine.replaceAll("template", toLowerCamel(service_name));

            fn.writeText(target_xml, newLine);

        } catch (Exception e) {
            e.printStackTrace();
        }
    }
    
    /** JSP 생성: TemplateList.jsp / TemplateModify.jsp → {board}List.jsp / {board}Modify.jsp */
    private static void createJsp() {
        try {
            // 웹 루트
            String webRoot = full_path.replace("/src/main/java", "/src/main/webapp");

            // 템플릿 파일
            String tplList = webRoot + jsp_template_root + "/TemplateList.jsp";
            String tplMod  = webRoot + jsp_template_root + "/TemplateModify.jsp";

            // 타겟 디렉터리: /WEB-INF/jsp/www/{bbs/board}/
            String bizPath   = (isBlank(middle_pk_in_name) ? "bbs" : middle_pk_in_name).replace(".", "/");
            String targetDir = webRoot + jsp_target_base + "/" + bizPath + "/";

            // 파일명: 소문자 서비스명 + List/Modify.jsp (예: boardList.jsp, boardModify.jsp)
            String svcLower = toLowerCamel(service_name);
            String outList  = targetDir + svcLower + "List.jsp";
            String outMod   = targetDir + svcLower + "Modify.jsp";
            String outMain   = targetDir + svcLower + ".jsp";

            // 치환 값
            String svcUpper = service_name;                // Template → Board
            String pkParam  = convert2CamelCase(db_key);   // PK_PARAM → boardIdx
            String bizSeg   = getBizSeg();                 // BIZ_SEG  → bbs
            String title    = screenTitle;                 // screenTitle → 게시판

            fn.makeDirectory(targetDir);

            // 목록 JSP
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

            // 수정 JSP
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
            
            // === 통합 페이지: template.jsp (한 화면 입력/삭제) ===
            String tplUnified = tplList.replace("TemplateList.jsp", "Template.jsp"); // /smp/sample/Template.jsp

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

    // middle_pk_in_name에서 비즈 세그먼트(bbs)만 추출
    private static String getBizSeg() {
        if (isBlank(middle_pk_in_name)) return "bbs";
        int i = middle_pk_in_name.indexOf('.');
        return (i >= 0) ? middle_pk_in_name.substring(0, i) : middle_pk_in_name;
    }
    
    /* ===== 이하: 확장용(기본 OFF) ===== */
    private static void createMapperJava() { /* 미사용 - 자리만 남김 */ }
    private static void createImpl()       { /* 미사용 - 자리만 남김 */ }
    private static void createVO()         { /* 미사용 - 자리만 남김 */ }

    /******************************************************************
     * DB 메타 조회 (환경변수 기반 접속) - 컬럼/타입/주석 수집
     ******************************************************************/
    private static List db_list = null;
    private static HashMap db_map = null;

    private static HashMap getTableMap() {
        if (db_list != null) return db_map;

        Connection conn = null;
        ResultSet rs = null;

        List<String> arrList= new ArrayList<>();
        HashMap<String, String> columnMap= new HashMap<>();

        try{
            java.util.Properties info = new java.util.Properties();
            info.put("remarksReporting","true");
            info.put("user", user);
            info.put("password", password);

            Class.forName(driver);
            conn = DriverManager.getConnection(server_ip, info);
            DatabaseMetaData meta = conn.getMetaData();
            rs = meta.getColumns(null, null, db_table.toUpperCase(), "%");

            while(rs.next()) {
                String col = rs.getString("COLUMN_NAME");
                String typeName = rs.getString("TYPE_NAME");
                String remark   = rs.getString("REMARKS");

                String sTypeStr;
                if ("CLOB".equalsIgnoreCase(typeName) || "BLOB".equalsIgnoreCase(typeName)) sTypeStr = "clob";
                else if ("NUMBER".equalsIgnoreCase(typeName) || "INTEGER".equalsIgnoreCase(typeName) || "LONG".equalsIgnoreCase(typeName)) sTypeStr = "int";
                else sTypeStr = "string";

                columnMap.put(col, sTypeStr + "#" + (remark != null ? remark : ""));
                arrList.add(col);
            }

            db_list = arrList;
            db_map  = columnMap;

        } catch(Exception e) {
            System.out.println("[JavaGen][WARN] DB 메타 조회 실패: " + e.getMessage());
            // 최소한 PK만이라도 들어가도록 보정
            db_list = new ArrayList<>();
            db_list.add(db_key);
            db_map  = new HashMap<>();
            db_map.put(db_key, "string#");
        } finally{
            try { if (rs != null) rs.close(); } catch (Exception ignore) {}
            try { if (conn != null) conn.close(); } catch (Exception ignore) {}
        }
        return db_map;
    }

    /******************************************************************
     * 유틸
     ******************************************************************/
    private static String convert2CamelCase(String underScore){
        if(underScore.indexOf('_') < 0 && Character.isLowerCase(underScore.charAt(0)))
            return underScore;
        StringBuilder result = new StringBuilder();
        boolean nextUpper = false;
        int len = underScore.length();
        for(int i = 0; i < len; i++) {
            char c = underScore.charAt(i);
            if(c == '_') { nextUpper = true; continue; }
            if(nextUpper) { result.append(Character.toUpperCase(c)); nextUpper = false; }
            else { result.append(Character.toLowerCase(c)); }
        }
        return result.toString();
    }

    private static String toLowerCamel(String s) {
        if (s == null || s.isEmpty()) return s;
        return Character.toLowerCase(s.charAt(0)) + s.substring(1);
    }

    private static String lcFirst(String s) { return toLowerCamel(s); }

    private static boolean isBlank(String s) { return s == null || s.trim().isEmpty(); }

    private static String env(String key, String def) {
        String v = System.getenv(key);
        return (v == null || v.isEmpty()) ? def : v;
    }
    
    private static boolean isMySQLFamily() {
        String t = (dbType == null) ? "" : dbType.toLowerCase();
        return t.contains("mysql") || t.contains("mariadb");
    }

    private static boolean isDateLike(String upperName) {
        // 자주 쓰는 패턴 확장 가능: REG_DATE, MOD_DT, CREATE_TIME 등
        return upperName.endsWith("_DATE") || upperName.endsWith("_DT") || upperName.endsWith("_TIME");
    }
}