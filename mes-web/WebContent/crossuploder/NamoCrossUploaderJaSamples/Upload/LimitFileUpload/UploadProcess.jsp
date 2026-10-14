<%@page language="java" contentType="text/html; charset=UTF-8"%>
<%@page import="com.namo.crossuploader.*"%>
<%@page import="java.io.*"%>

<%
	PrintWriter writer = response.getWriter(); 
	FileUpload fileUpload = new FileUpload(request, response); 
	
	// 업로드 정보를 화면에 출력하기 위한 HTML 코드입니다. 신경쓰지 않으셔도 됩니다. 
	printHtmlHeader(writer);
	
	try { 
		// autoMakeDirs를 true로 설정하면 파일 저장 및 이동시 파일생성에 필요한 상위 디렉토리를 모두 생성합니다.
		fileUpload.setAutoMakeDirs(true);

		// 파일을 저장할 경로를 설정합니다.
		String saveDirPath = request.getRealPath("/");
		saveDirPath += ("UploadDir" + File.separator);
		
		/**
		* 허용 확장자
		*/
		// 허용할 파일 확장자를 설정합니다.
		// 확장자가 없는 파일을 허용하려면  {"jpg", "jpeg", "txt", ""} 처럼 배열을 만들어 주십시오. 
		String[] fileFilters = {"jpg", "jpeg", "txt"}; 
		fileUpload.setFileFilters(fileFilters);
		
		// 허용할 파일 확장자를 설정합니다. reverseFileFilter가 true 이면, 허용하지 않을 파일 확장자로 설정하게 됩니다.
		// setFileFilters(String[] fileFilters, boolean reverseFileFilter) 

		/**
		* 전체 Content-Length
		*/
		// 전체 Content-Length를 10MB로 제한합니다. 
		long maxTotalContentLength = 1024*1024*10; 
		fileUpload.setMaxTotalContentLength(maxTotalContentLength); 

		/**
		* 개별 파일 크기
		*/
		// 개별 파일 크기를 10KB로 제한합니다.
		long maxFileSize = 1024*10; 
		fileUpload.setMaxFileSize(maxFileSize); 
		
		// saveDirPath에 지정한 경로로 파일 업로드를 시작합니다. 
		fileUpload.startUpload(saveDirPath); 	

		// 업로드 경로를 지정하지 않을 경우, 시스템의 임시 디렉토리로 파일 업로드를 시작합니다. 	
		// fileUpload.startUpload(); 

		// 입력한 name을 키로 갖는 FileItem[] 객체를 리턴합니다.  
		// "files"는 UploadForm.jsp에서 입력한 값입니다. <input type="file" name="files"> 
		FileItem[] fileItems = fileUpload.getFileItems("files");

		if(fileItems != null) { 
			for(int i=0; i<fileItems.length; i++) {
				// saveDirPath 경로에 원본 파일명으로 저장(이동)합니다. 동일한 파일명이 존재할 경우 다른 이름으로 저장됩니다.
				fileItems[i].save(saveDirPath); 	
				
				// 다른 유형의 저장(이동) 함수들
				// save(); 
				// save(String saveDirPath, boolean overwrite);
				// saveAs(String saveDirPath, String fileName); 
				// saveAs(String saveDirPath, String fileName, boolean overwrite); 
				
				// FileItem 객체로 아래와 같은 정보를 가져올 수 있습니다. 
				String name = fileItems[i].getName();
				String fileName = fileItems[i].getFileName(); 
				String lastSavedDirPath = fileItems[i].getLastSavedDirPath(); 
				String lastSavedFilePath = fileItems[i].getLastSavedFilePath(); 
				String lastSavedFileName = fileItems[i].getLastSavedFileName(); 
				long fileSize = fileItems[i].getFileSize();
				String fileNameWithoutFileExt = fileItems[i].getFileNameWithoutFileExt(); 
				String fileExtension = fileItems[i].getFileExtension(); 
				String contentType = fileItems[i].getContentType(); 
				boolean saved = fileItems[i].isSaved(); 
				boolean emptyFie = fileItems[i].isEmptyFile(); 
			}
			// 업로드 정보 출력
			printFileUploadResult(fileItems, writer); 
		}
	}
	catch(CrossUploaderException ex) { 
		printExceptionMessage(ex.getMessage(), writer); 
	}
	catch(Exception ex) { 
		printExceptionMessage(ex.getMessage(), writer); 
		//  업로드 외 로직에서 예외 발생시 업로드 중인 모든 파일을 삭제합니다. 
		fileUpload.deleteUploadedFiles(); 
	}
	finally { 
		// 파일 업로드 객체에서 사용한 자원을 해제합니다. 
		fileUpload.clear(); 
		
		// 업로드 정보를 화면에 출력하기 위한 HTML 코드입니다. 신경쓰지 않으셔도 됩니다.  
		printHtmlFooter(writer); 
	}
%>

<%!
	public void printFileUploadResult(FileItem[] fileItems, PrintWriter writer) { 
		if(fileItems == null)
			return; 
	
		String html = ""; 
		for(int i=0; i<fileItems.length; i++) { 
			html += "<div class='form_area'><table class='form_table'><tbody>"; 
			html += "<tr><td class='form_table_title' colspan=2><b>" + (i+1) + "번째 파일 업로드 정보</b></td><tr>"; 
			html += "<tr><td>Name</td><td>" + fileItems[i].getName() + "</td></tr>"; 
			html += "<tr><td>File Name</td><td>" + fileItems[i].getFileName() + "</td></tr>"; 
			html += "<tr><td>Last Saved Directory Path</td><td>" + fileItems[i].getLastSavedDirPath() + "</td></tr>"; 
			html += "<tr><td>Last Saved File Path</td><td>" + fileItems[i].getLastSavedFilePath() + "</td></tr>"; 
			html += "<tr><td>Last Saved File Name</td><td>" + fileItems[i].getLastSavedFileName() + "</td></tr>"; 
			html += "<tr><td>File Size</td><td>" + fileItems[i].getFileSize() + "</td></tr>";
			html += "<tr><td>File Name without File Ext</td><td>" + fileItems[i].getFileNameWithoutFileExt() + "</td></tr>"; 
			html += "<tr><td>File Extension</td><td>" + fileItems[i].getFileExtension() + "</td></tr>"; 
			html += "<tr><td>Content Type</td><td>" + fileItems[i].getContentType() + "</td></tr>"; 
			html += "<tr><td>Saved</td><td>" + fileItems[i].isSaved() + "</td></tr>"; 
			html += "<tr><td>Is EmptyFile</td><td>" + fileItems[i].isEmptyFile() + "</td></tr>"; 
			html += "</tbody></table></div>";
		} 
		writer.println(html); 
	}
	
	public void printExceptionMessage(String message, PrintWriter writer) { 
		String html = "<div class='form_area'><table class='form_table'><tbody>"; 
		html += "<tr><td class='form_table_title' colspan=2><b>예외가 발생했습니다.</b></td><tr>"; 
		html += "<tr><td>예외 메시지: </td><td>" + message + "</td></tr>"; 
		html += "</tbody></table></div>";
	
		writer.println(html); 
	}
	
	public void printHtmlHeader(PrintWriter writer) { 
		String html = "<html><head>"; 
		html += "<meta http-equiv='content-type' content='text/html; charset=utf-8'>";
		html += "<link rel='stylesheet' type='text/css' href='../../css/common.css'/>"; 
		html += "<title>파일 업로드 정보입니다</title></head>";
		html += "<body>";
	
		writer.println(html); 
		writer.flush();	
	}
	public void printHtmlFooter(PrintWriter writer) { 
		writer.println("</body></html>"); 
		writer.flush();	
	}
%>