<%@page language="java" contentType="text/html; charset=UTF-8"%>
<%@page import="com.namo.crossuploader.*"%>
<%@page import="java.io.*"%>
<%@page import="java.net.URLEncoder"%>

<%
	out.clear(); 
	FileDownload fileDownload = new FileDownload(request, response); 
	
	try { 
		// DB 등에 저장된 파일의 정보를 가져옵니다. 샘플에서는 session 객체에서 파일 정보를 관리하고 있습니다.  
		String saveDirPath = session.getAttribute("saveDirPath").toString(); 
		String lastSavedFileName = session.getAttribute("lastSavedFileName").toString(); 
		String fileNameAlias = session.getAttribute("fileName").toString(); 

		// 다운로드 할 파일 경로 설정
		String filePath = saveDirPath + lastSavedFileName; 

		// fileNameAlias는 웹서버 환경에 따라 적절히 인코딩 되어야 합니다.
		fileNameAlias = URLEncoder.encode(fileNameAlias, "UTF-8"); 
		// filePath에 지정된 파일을 fileNameAlias 이름으로 다운로드 합니다.  
		fileDownload.startDownload(filePath, fileNameAlias); 
		
		// 다른 유형의 다운로드 함수들
		// startDownload(String filePath); 
		// startDownload(String filePath, boolean attachment); 
		// startDownload(String filePath, boolean attachment, boolean resumable); 
		// startDownload(String filePath, String fileNameAlias, boolean attachment); 
		// startDownload(String filePath, String fileNameAlias, boolean attachment, boolean resumable); 
		// startStreamDownload(InputStream inputStream, String fileNameAlias, long fileSize, boolean attachment); 
	}
	catch(CrossUploaderException ex) {  
		System.out.println("다운로드 중 예외 발생 : " + ex.getMessage()); 	
	}
	catch(Exception ex) { 
		System.out.println("다운로드 중 예외 발생 : " + ex.getMessage()); 	
	}
%>