package www.com.util;

import java.io.*;
import java.util.*;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.context.support.MessageSourceAccessor;


/**
 * properties값들을 파일로부터 읽어와   Globals클래스의 정적변수로 로드시켜주는 클래스로
 *   문자열 정보 기준으로 사용할 전역변수를 시스템 재시작으로 반영할 수 있도록 한다.
 * @author 박대규
 * @since 2010.01.05
 * @version 1.0
 * @see
 * <pre>
 * << 개정이력(Modification Information) >>
 *   
 *   수정일      수정자           수정내용
 *  -------    --------    ---------------------------
 *   2010.01.5  박대규          최초 생성
 *
 * Copyright (C) 2010 by KL-Net  All right reserved.
 * </pre>
 */
public class CoreProperties {
	
	private static final Logger logger = LoggerFactory.getLogger(CoreProperties.class);
	
	//프로퍼티값 로드시 에러발생하면 반환되는 에러문자열 
	public static final String ERR_CODE =" EXCEPTION OCCURRED";
	public static final String ERR_CODE_FNFE =" EXCEPTION(FNFE) OCCURRED";
	public static final String ERR_CODE_IOE =" EXCEPTION(IOE) OCCURRED";
	
	//파일구분자
    static final char FILE_SEPARATOR     = File.separatorChar;
    
	//프로퍼티 파일의 물리적 위치
    public  static final String GLOBALS_PROPERTIES_FILE 
        //= "D:/project/egov/workspace/egovcmm/target/classes/egovframework/cmm/utl/globals.properties";
        = System.getProperty("user.home") + System.getProperty("file.separator") + "Config.properties";
    
    protected static MessageSourceAccessor messageSourceAccessor = null;
    
    private static InputStream openConfigStream() throws IOException {
        // 1) 환경변수/시스템 프로퍼티
        String hint = System.getenv("CONNECT_CONFIG");
        if (hint == null || hint.isEmpty()) {
            hint = System.getProperty("connect.config");
        }
        if (hint != null && !hint.isEmpty()) {
            try {
                // URL 형식(file:/..., file:///C:/...) 먼저 시도
                return new java.io.BufferedInputStream(new java.net.URL(hint).openStream());
            } catch (Exception ignore) {
                // 일반 파일 경로도 허용(C:\..., /opt/...)
                return new java.io.BufferedInputStream(new java.io.FileInputStream(hint));
            }
        }
        // 2) 사용자 홈 fallback (기존 로직 유지)
        java.io.File home = new java.io.File(System.getProperty("user.home"), "Config.properties");
        if (home.exists()) {
            return new java.io.BufferedInputStream(new java.io.FileInputStream(home));
        }
        // 3) classpath fallback (기존)
        java.io.InputStream cp = CoreProperties.class.getResourceAsStream("/config/Config.properties");
        return (cp != null) ? new java.io.BufferedInputStream(cp) : null;
    }

    public static String getProperty(String keyName){
        String value = ERR_CODE;
        try (InputStream in = openConfigStream()) {
            if (in == null) return value;
            Properties props = new Properties();
            props.load(in);
            String v = props.getProperty(keyName);
            return (v != null) ? v.trim() : value;
        } catch (Exception e) {
            logger.warn("@Exception " + e.getMessage());
            return value;
        }
    }
	
	/**
	 * properties를 가지고 와서 값이 없다면 defaultvalue 를 가지고 옵시다.
	 * @param key
	 * @param defaultValue
	 * @return
	 */
    public static String getProperty(String key, String defaultValue) {
        try {
            String value = null;
            debug(GLOBALS_PROPERTIES_FILE + " : " + key);
            FileInputStream fis = null;
            try{
                Properties props = new Properties();
                fis  = new FileInputStream(GLOBALS_PROPERTIES_FILE);
                props.load(new java.io.BufferedInputStream(fis));
                //value = props.getProperty(key).trim(); //시큐어코딩대상
                
                //2015.05.11 시큐어코딩처리
                if (props != null) {
                	value = props.getProperty(key).trim();
                }

            }catch(Exception e){
                throw e;
            }finally{
                try {
                    if (fis != null) fis.close();
                } catch (Exception ex) {
            		logger.warn("예외 발생");
                    
                }
                
            }
            return value;
        }
        catch(Exception e) {
            debug("defaultValue->" + defaultValue);
            return defaultValue;
        }
    }
    
	
	/**
	 * 주어진 파일에서 인자로 주어진 문자열을 Key값으로 하는 프로퍼티 값을 반환한다
	 * @param fileName String
	 * @param key String
	 * @return String
	 */
	public static String loadGetProperty(String fileName, String key){
		FileInputStream fis = null;
		try{
			java.util.Properties props = new java.util.Properties();
			fis  = new FileInputStream(fileName);
			props.load(new java.io.BufferedInputStream(fis));
			fis.close();

			//String value = props.getProperty(key); //시큐어코딩대상
			
			//2015.05.11 시큐어코딩처리
			String value = null;
			if (props != null) {
				value = props.getProperty(key);
			}
			
			return value;
		}catch(java.io.FileNotFoundException fne){
			return ERR_CODE_FNFE;
		}catch(java.io.IOException ioe){
			return ERR_CODE_IOE;
		}finally{
			try {
				if (fis != null) fis.close();
			} catch (Exception ex) {
				logger.warn("예외 발생");				
				
			}
		}
	}
	
	

	
	/**
	 * 주어진 프로파일의 내용을 파싱하여 (key-value) 형태의 구조체 배열을 반환한다.
	 * @param property String
	 * @return ArrayList
	 */
	public static ArrayList loadPropertyFile(String property){

		// key - value 형태로 된 배열 결과
		ArrayList keyList = new ArrayList();
		
		String src = property.replace('\\', FILE_SEPARATOR).replace('/', FILE_SEPARATOR);
		FileInputStream fis = null;
		try
		{   
			
			File srcFile = new File(src);
			if (srcFile.exists()) {
				
				java.util.Properties props = new java.util.Properties();
				fis  = new FileInputStream(src);
				props.load(new java.io.BufferedInputStream(fis));
				fis.close();
				
				int i = 0;
				Enumeration plist = props.propertyNames();
				if (plist != null) {
					while (plist.hasMoreElements()) {
						Map map = new HashMap();
						String key = (String)plist.nextElement();
						map.put(key, props.getProperty(key));
						keyList.add(map);
					}
				}
			}
		} catch (Exception ex){
			logger.warn("예외 발생");			
		    
		} finally {
			try {
				if (fis != null) fis.close();
			} catch (Exception ex) {
				logger.warn("예외 발생");				
				
			}
		}
		
		return keyList;
	}
	/**
	 * 시스템 로그를 출력한다.
	 * @param obj Object
	 */	
	private static void debug(Object obj) {
		if (obj instanceof java.lang.Exception) {
			((Exception)obj).printStackTrace();
		}
	}

	public void setMessageSourceAccessor(MessageSourceAccessor messageSourceAccessor) {
		CoreProperties.messageSourceAccessor = messageSourceAccessor;
	}
	
	public static MessageSourceAccessor getMessageSourceAccessor() {
		return messageSourceAccessor;
	}
	
}

