package www.com.util;

import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.io.RandomAccessFile;
import java.util.StringTokenizer;

/**
 * <pre>
 * Statements
 * <pre>
 *
 * @ClassName   : FileUtil.java
 * @Description : 클래스 설명을 기술합니다.
 * @author John Doe
 * @since 2012. 2. 21.
 * @version 1.0
 * @see
 * @Modification Information
 * <pre>
 *     since          author              description
 *  ===========    =============    ===========================
 *  2012. 2. 21.     John Doe     최초 생성
 * </pre>
 */

public class FileUtil2 {
/** 파일 존재 유무 확인 */
    
    public static boolean fileExists(String fileName) throws ClassNotFoundException, IOException {
        File file = new File(fileName);
        return file.isFile();
    }

    /** 파일 사지으 */
    
    public static long getFileSize(String fileName) throws ClassNotFoundException, IOException {
        long fileLength = 0;
        File file = new File(fileName);

        if(file.exists()) fileLength = file.length();
        else fileLength = 0;

        return fileLength;
    }
    
    public static boolean writeText(String filePath,String txt){
        FileWriter fw = null;

        try {
          //  mkdir(filePath); 
            fw = new FileWriter( filePath);
            fw.write(txt);
            fw.flush();
            fw.close();
        } catch(Exception e) {
            return false;
        } finally {
            try {
                if(fw != null) fw.close();
            } catch(IOException ie) {
                ie.printStackTrace();
            }
        }
        return true;
    }
    

    public static boolean writeLog(String saveDir, String fname, String log, boolean reFile){
        FileWriter fw = null;

        try {
            mkdir(saveDir); 
            fw = new FileWriter( saveDir + fname , reFile);
            fw.write(log);
            fw.flush();
            fw.close();
        } catch(Exception e) {
            return false;
        } finally {
            try {
                if(fw != null) fw.close();
            } catch(IOException ie) {
                ie.printStackTrace();
            }
        }
        return true;
    }
    
    public  String  readText(String filePath) throws Exception{ 
        
        File file = new File(filePath);  
        RandomAccessFile raf = new RandomAccessFile(file,"rw");  
         
        
        StringUtil2 sul = new StringUtil2();
        
        String line = null; 
        String newLine  = ""; 
        
       // raf.seek(10);  
        while((line = raf.readLine()) != null){  
           newLine +=   sul.toKor(line,"UTF-8") +"\n";
           
        }
       // raf.seek(10);  
      //  raf.write("javamaster\r\n".getBytes());  
        raf.close();  
        return newLine;
        
      }
    
    public static void mkdir(String localPath) throws Exception {
        StringTokenizer st = new StringTokenizer(localPath,"/");
        StringBuffer temp = new StringBuffer();
        temp.append("/");

        while (st.hasMoreTokens()) {
            temp.append(st.nextToken());
            temp.append("/");
            makeDirectory(temp.toString());
        }
    }
    
    public static void makeDirectory(String directory) throws Exception{
        File file = new File(directory);
        if(file.exists() && file.isDirectory()) {
            return;
        } else {
            file.mkdirs();
            try {
                 //chmodFile(directory,"777");
            } catch(Exception e) {
                throw e;
            }
            return;
        }
    }
    
    
    public static void chmodFile(String fileName, String mode) throws ClassNotFoundException, IOException, InterruptedException  {
        Process p = Runtime.getRuntime().exec("/bin/chmod "+ mode + " " + fileName);
        p.waitFor();
    }
}
