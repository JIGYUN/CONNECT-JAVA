package www.com.util;

import java.io.File;

/**
 * File Util class
 * 
 * @author cmj
 *
 */
public class FileUtil {
	
	private FileUtil(){}
	
	/**
	 * 파일명의 확장자를 가져온다.
	 * 
	 * @param file
	 * @return 파일명의 확장자
	 */
	public static String getFileExtention(File file){
		String fileName = file.getName();
		String fileExt = "";
		if(fileName.indexOf(".") != -1){
			fileExt = fileName.substring(fileName.lastIndexOf(".") + 1).trim();
		}
		
		return fileExt;
	}
}
