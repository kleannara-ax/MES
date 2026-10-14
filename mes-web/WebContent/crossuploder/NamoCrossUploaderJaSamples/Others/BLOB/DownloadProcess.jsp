<%@page language="java" contentType="text/html; charset=UTF-8"%>
<%@page import="com.namo.crossuploader.*"%>
<%@page import="java.io.*"%>
<%@page import="java.net.URLEncoder"%>
<%@page import="java.sql.*"%>

<%
	out.clear(); 
	FileDownload fileDownload = new FileDownload(request, response); 
	Connection con = null; 
	PreparedStatement pstmt = null;
	ResultSet rs = null; 
	InputStream fis = null; 
	
	try { 
		// 테스트를 위해 session 객체에 저장해 놓은 DB의 id 컬럼 값을 가져온다.   
		String id = session.getAttribute("id").toString(); 

		String user = "user"; 
		String password = "password"; 
		//Class.forName("org.gjt.mm.mysql.Driver");
		Class.forName("com.mysql.jdbc.Driver").newInstance();  
		con = DriverManager.getConnection("jdbc:mysql://localhost:3306/blob_db", user, password);

		String query = "SELECT id, filename, filedata FROM blob_table WHERE id =" + id; 
		pstmt = con.prepareStatement(query); 

		pstmt.clearParameters();
		rs = pstmt.executeQuery();

		if (rs != null && rs.next()) {
			String filename = rs.getString("filename");
			Blob filedata = rs.getBlob("filedata");
			fis = filedata.getBinaryStream();
			
			// fileNameAlias는 웹서버 환경에 따라 적절히 인코딩 되어야 합니다.
			String fileNameAlias = URLEncoder.encode(filename, "UTF-8"); 
			long fileSize = filedata.length();  
			boolean attachment = false; 
			// filePath에 지정된 파일을 fileNameAlias 이름으로 다운로드 합니다.  

			fileDownload.startStreamDownload(fis, fileNameAlias, fileSize, attachment); 
			
			// 다른 유형의 다운로드 함수들
			// startDownload(String filePath); 
			// startDownload(String filePath, boolean attachment); 
			// startDownload(String filePath, boolean attachment, boolean resumable); 
			// startDownload(String filePath, String fileNameAlias); 
			// startDownload(String filePath, String fileNameAlias, boolean attachment); 
			// startDownload(String filePath, String fileNameAlias, boolean attachment, boolean resumable); 
		}
	}
	catch(CrossUploaderException ex) {  
		System.out.println("다운로드 중 예외 발생 : " + ex.getMessage()); 	
	}
	catch(Exception ex) { 
		System.out.println("다운로드 중 예외 발생 : " + ex.getMessage()); 	
	}
	finally { 
		// DB 연결 종료
		if(fis != null)
			fis.close(); 
		if(rs != null)
			rs.close();
		if(pstmt != null)
			pstmt.close(); 
		if(con != null)
			con.close(); 	
	}
%>