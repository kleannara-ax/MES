<%@page language="java" contentType="text/html; charset=UTF-8"%>
<%@page import="com.namo.crossuploader.*"%>
<%@page import="java.io.*"%>
<%@page import="java.net.*"%>
<%@page import="java.sql.*"%>

<%
	PrintWriter writer = response.getWriter(); 
	FileUpload fileUpload = new FileUpload(request, response); 
	Connection con = null; 
	PreparedStatement pstmt = null; 
	ResultSet rs = null; 
	InputStream fis = null; 
	
	// 업로드 정보를 화면에 출력하기 위한 HTML 코드입니다. 신경쓰지 않으셔도 됩니다. 
	printHtmlHeader(writer); 
	
	try { 
		// autoMakeDirs를 true로 설정하면 파일 저장 및 이동시 파일생성에 필요한 상위 디렉토리를 모두 생성합니다.
		fileUpload.setAutoMakeDirs(true);

		// 파일을 저장할 경로를 설정합니다.
		String saveDirPath = request.getRealPath("/");
		saveDirPath += ("UploadDir" + File.separator);
		
		// saveDirPath에 지정한 경로로 파일 업로드를 시작합니다. 
		fileUpload.startUpload(saveDirPath); 	

		// 업로드 경로를 지정하지 않을 경우, 시스템의 임시 디렉토리로 파일 업로드를 시작합니다. 	
		// fileUpload.startUpload(); 

		// 입력한 name을 키로 갖는 마지막 FileItem 객체를 리턴합니다.
		// "files"는 UploadForm.jsp에서 입력한 값입니다. <input type="file" name="files"> 
		FileItem fileItem = fileUpload.getFileItem("files");

		if(fileItem != null && fileItem.isEmptyFile() == false) { 
			// saveDirPath 경로에 원본 파일명으로 저장(이동)합니다. 동일한 파일명이 존재할 경우 다른 이름으로 저장됩니다.
			//fileItem.save(saveDirPath); 	
			
			// 다른 유형의 저장(이동) 함수들
			// save(); 
			// save(String saveDirPath, boolean overwrite);
			// saveAs(String saveDirPath, String fileName); 
			// saveAs(String saveDirPath, String fileName, boolean overwrite); 
			
			/**
			* BLOB 저장
			* 파일 저장 전 임시파일인 상태에서 파로 처리합니다. 파일 저장이 필요하면 save 함수를 호출해 주십시오.
			* save 함수를 호출하지 않았기 때문에 임시파일은 직접 삭제해줘야 합니다.  
			* BLOB 저장 외에 파일 저장이 필요할 경우, 위 save() 계열 저장 함수를 호출해 주십시오.
			*/ 
			fis = fileItem.getInputStream(); 	
			if(fis != null) {
				String user = "user"; 
				String password = "password"; 
				// Class.forName("org.gjt.mm.mysql.Driver");
				Class.forName("com.mysql.jdbc.Driver").newInstance();  
				con = DriverManager.getConnection("jdbc:mysql://localhost:3306/blob_db", user, password); 
			
				String query = "INSERT INTO blob_table (filename, filedata) VALUES (?, ?)"; 
				pstmt = con.prepareStatement(query, Statement.RETURN_GENERATED_KEYS); 
				pstmt = con.prepareStatement(query, new String[]{"id"});
			
				pstmt.setString(1, fileItem.getFileName());
				// 파일 스트림을 BLOB 타입에 저장
				pstmt.setBinaryStream(2, fis, (int)fileItem.getFileSize()); 
				pstmt.executeUpdate();
				rs = pstmt.getGeneratedKeys();
				if (rs != null && rs.next()) {
				    long id = rs.getInt(1);
					// 테스트를 위해 BLOB 타입으로 저장한 id 컬럼 값을 session 객체에 저장해 놓는다.  
					session.setAttribute("id", id);
				}
				
				// 임심파일 형태로 남아있는 파일을 삭제
				if(fileItem.isSaved() == false)
					fileItem.deleteFile(); 
			}

			// FileItem 객체로 아래와 같은 정보를 가져올 수 있습니다. 
			String name = fileItem.getName();
			String fileName = fileItem.getFileName(); 
			String lastSavedDirPath = fileItem.getLastSavedDirPath(); 
			String lastSavedFilePath = fileItem.getLastSavedFilePath(); 
			String lastSavedFileName = fileItem.getLastSavedFileName(); 
			long fileSize = fileItem.getFileSize(); 
			String fileNameWithoutFileExt = fileItem.getFileNameWithoutFileExt(); 
			String fileExtension = fileItem.getFileExtension(); 
			String contentType = fileItem.getContentType(); 
			boolean saved = fileItem.isSaved();
			boolean emptyFie = fileItem.isEmptyFile(); 
			
			// 업로드 정보 출력
			printFileUploadResult(fileItem, writer); 
			// 다운로드 페이지 출력
			printFileDownloadPage(fileItem, writer); 
		}
		else { 
			printExceptionMessage("빈 파일입니다.", writer);  
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
		
		// DB 연결 종료
		if(fis != null)
			fis.close(); 
		if(rs != null)
			rs.close(); 
		if(pstmt != null)
			pstmt.close(); 
		if(con != null)
			con.close(); 
		
		// 업로드 정보를 화면에 출력하기 위한 HTML 코드입니다. 신경쓰지 않으셔도 됩니다.  
		printHtmlFooter(writer);
	}
%>

<%!
	public void printFileDownloadPage(FileItem fileItem, PrintWriter writer) { 
		String html = "<div class='form_area'><table class='form_table'><tbody>"; 
		html += "<tr><td class='form_table_title'>파일 다운로드</td><tr>"; 
		html += "<tr><td><a href='DownloadProcess.jsp'>";
		html += fileItem.getFileName() + " 파일을 다운로드 하십시오.</a></td></tr>"; 
		html += "</tbody></table></div>";
		
		writer.println(html); 
	}

	public void printFileUploadResult(FileItem fileItem, PrintWriter writer) { 
		String html = "<div class='form_area'><table class='form_table'><tbody>"; 
		html += "<tr><td class='form_table_title' colspan=2><b>파일 업로드 정보</b></td><tr>"; 
		html += "<tr><td>Name</td><td>" + fileItem.getName() + "</td></tr>"; 
		html += "<tr><td>File Name</td><td>" + fileItem.getFileName() + "</td></tr>"; 
		html += "<tr><td>Last Saved Directory Path</td><td>" + fileItem.getLastSavedDirPath() + "</td></tr>"; 
		html += "<tr><td>Last Saved File Path</td><td>" + fileItem.getLastSavedFilePath() + "</td></tr>"; 
		html += "<tr><td>Last Saved File Name</td><td>" + fileItem.getLastSavedFileName() + "</td></tr>"; 
		html += "<tr><td>File Size</td><td>" + fileItem.getFileSize() + "</td></tr>"; 
		html += "<tr><td>File Name without File Ext</td><td>" + fileItem.getFileNameWithoutFileExt() + "</td></tr>"; 
		html += "<tr><td>File Extension</td><td>" + fileItem.getFileExtension() + "</td></tr>"; 
		html += "<tr><td>Content Type</td><td>" + fileItem.getContentType() + "</td></tr>"; 
		html += "<tr><td>Saved</td><td>" + fileItem.isSaved() + "</td></tr>"; 
		html += "<tr><td>Is EmptyFile</td><td>" + fileItem.isEmptyFile() + "</td></tr>"; 
		html += "</tbody></table></div>";
		
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