package www.com.util;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.apache.commons.net.ftp.FTPClient;
import org.apache.commons.net.ftp.FTPFile;
import org.apache.commons.net.ftp.FTPReply;


public class FtpUtil {
	
	private static Log logger = LogFactory.getLog(FtpUtil.class);
	
	private FTPClient ftpClient;
	
	public FtpUtil() {
		

		ftpClient = new FTPClient();
	}

	
	/**
     * 서버와 연결
     * @param server  서버 주소
     * @param port 포트번호
     */
	
	public void connect(String server) {
		connect(server, 21);
	}
	
	public void connect(String server, int port) {
			try {
				ftpClient.connect(server, port);
				int reply;
		 		// 연결 시도후, 성공했는지 응답 코드 확인
				reply = ftpClient.getReplyCode();
				
				//active mode
				ftpClient.enterLocalActiveMode();
				
				//passive mode
				//ftpClient.enterLocalPassiveMode();
				
				//file type
				ftpClient.setFileType(ftpClient.BINARY_FILE_TYPE); // set binary type
				
				//ftpClient.setFileType(ftpClient.ASCII_FILE_TYPE); // set ascii type
				
				if(!FTPReply.isPositiveCompletion(reply)) {
					ftpClient.disconnect();
					logger.error("서버로부터 연결을 거부당했습니다");
				}
			} catch (IOException ioe) {
				if(ftpClient.isConnected()) {
					try {
						ftpClient.disconnect();
					} catch(IOException f) {
					//
						logger.debug(f.getMessage(), f);
					}
				}
				ioe.printStackTrace();
				logger.error("서버에 연결할 수 없습니다");
		 	}
	}
	
	public void connect(String server, int port, String user, String password) {
		connect(server, port);
		login(user, password);
	}

	
	/**
     * 서버로 로그인
     * @param user  접속아이디
     * @param password 비밀번호
     */
	public boolean login(String user, String password) {
	 	try {
	 		return ftpClient.login(user, password);
	 	}
	 	catch (IOException ioe) {
			logger.debug(ioe.getMessage(), ioe);
	 	}
	 	return false;
	}

	/**
     * 서버로 로그인
     * @param user  접속아이디
     * @param password 비밀번호
     */
	public boolean login(String user, String password, String server, int port) {
		connect(server, port);
		return login(user, password);
	}
	
	/**
	 * 서버와의 로그아웃.
	*/
	public boolean logout() {
		try {
			if (ftpClient.isConnected()) {
				return ftpClient.logout();
			}
		}
		catch (IOException ioe) {
			logger.debug(ioe.getMessage(), ioe);
		}
		return false;
	}
	
	 /**
     * 서버와의 연결을 끊는다.
     */
	public void disconnect() {
		try {
			ftpClient.disconnect();
		}
		catch (IOException ioe) {
			logger.debug(ioe.getMessage(), ioe);
		}
	}
	
	/**
	 * FTP의 ls 명령, 모든 파일 리스트를 가져온다.
	 * 
	 */
	public FTPFile[] list() {
		FTPFile[] files = null;
		try {
			files = ftpClient.listFiles();
			return files;
		}
		catch (IOException ioe) {
			logger.debug(ioe.getMessage(), ioe);
		}
		return null;
	}
		
	/**
	 * 파일을 전송 받는다.
	 * @param source(remote) - 원본
	 * @param target(local) - 받을곳
	 * @return
	 */
	public File get(String source, String target) {
		/*
		OutputStream output = null;
		
		try {
			output = new FileOutputStream(target);
			if (ftpClient.retrieveFile(source, output)) {
				File file = new File(target);
				return file;
			}
			output.close();
		}
		catch (IOException ioe) {
			ioe.printStackTrace();
		}
		*/
		/*
		OutputStream output = null;
		try {
			File local = new File(target);
			output = new FileOutputStream(local);
		}
		catch (FileNotFoundException fnfe) {
			fnfe.printStackTrace();
		}
		File file = new File(source);
		try {
			if (ftpClient.retrieveFile(source, output)) {
				return file;
			}
		}
		catch (IOException ioe) {
			ioe.printStackTrace();
		}
		*/
		
		OutputStream output = null;
		try {
			File local = new File(target);
			output = new FileOutputStream(local);
		}
		catch (FileNotFoundException fnfe) {
			fnfe.printStackTrace();
		}
		try {
			if (ftpClient.retrieveFile(source, output)) {
				File file = new File(source);
				
				return file;
			}
		}
		catch (IOException ioe) {
			logger.debug(ioe.getMessage(), ioe);
		}
		return null;
	}
	
	
	/**
	 * 파일을 전송 한다.
	 * @param source(local) - 원본
	 * @param target(remote) - 받을곳
	 * @return
	 */
	public boolean put(String source, String target) {
		InputStream input = null;
		
		try {
			input = new FileInputStream(source);
			//파일이 전송된다.
			if (ftpClient.storeFile(target, input)) {
				return true;
			}
		} catch (IOException ioe) {
			logger.debug(ioe.getMessage(), ioe);
		}
		return false;
	}
	
	/**
	 * 서버 디렉토리 이동
	 * 
	*/
	public void cd(String path) {
		try {
			ftpClient.changeWorkingDirectory(path);
		}
		catch (IOException ioe) {
			logger.debug(ioe.getMessage(), ioe);
		}
	}
	
}
