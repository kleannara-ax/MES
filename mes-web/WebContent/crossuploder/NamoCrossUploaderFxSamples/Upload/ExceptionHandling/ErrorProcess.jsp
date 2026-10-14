<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="java.io.*"%>
<%@page import="org.json.simple.JSONArray"%>
<%@page import="org.json.simple.JSONObject"%>
<%@page import="org.json.simple.parser.JSONParser"%>
<%@page import="org.json.simple.parser.ParseException"%>

<%
	request.setCharacterEncoding("UTF-8");
	PrintWriter writer = response.getWriter();
	// 업로드 정보를 화면에 출력하기 위한 HTML 코드입니다. 신경쓰지 않으셔도 됩니다. 
	printHtmlHeader(writer); 
	
	try {
		/**
		* 기존에 업로드 된 정보를 삭제합니다.
		* 샘플에서는 JSON 타입으로 데이터를 교환하고 있습니다. 필요 시 다른 형식으로 조합해서 사용하실 수 있습니다.
		*/
		String uploadedFilesInfo = request.getParameter("uploadedFilesInfo"); 
		String osName = System.getProperty("os.name");
		if(uploadedFilesInfo != null) {
			JSONParser jsonParser = new JSONParser();
			Object obj = jsonParser.parse(uploadedFilesInfo); 
			JSONArray jsonArray = (JSONArray)obj; 
			for(int i=0; i<jsonArray.size(); i++) {
				JSONObject jsonObject = (JSONObject)jsonArray.get(i); 
				/**
				* UploadProcess.jsp에서 보낸 정보입니다.
				*/
				/*
				String name						= (String)jsonObject.get("name"); 
				String fileName					= (String)jsonObject.get("fileName"); 
				String lastSavedDirectoryPath	= (String)jsonObject.get("lastSavedDirectoryPath"); 
				String lastSavedFilePath		= (String)jsonObject.get("lastSavedFilePath"); 
				String lastSavedFileName		= (String)jsonObject.get("lastSavedFileName"); 
				String fileSize				= (String)jsonObject.get("fileSize"); 
				String fileNameWithoutFileExt	= (String)jsonObject.get("fileNameWithoutFileExt"); 
				String fileExtension			= (String)jsonObject.get("fileExtension"); 
				String contentType				= (String)jsonObject.get("contentType"); 
				String isSaved					= (String)jsonObject.get("isSaved"); 
				String isEmptyFile				= (String)jsonObject.get("isEmptyFile"); 
				*/ 
				String lastSavedFilePath		= (String)jsonObject.get("lastSavedFilePath"); 
				if(lastSavedFilePath != null) { 
					File delFile = new File(lastSavedFilePath);
					if(delFile.exists() && delFile.isFile()) { 
						delFile.delete(); 
						// 삭제된 파일 정보 출력
						printDeletedFilesInfo(lastSavedFilePath, writer); 
					}
				}
			}
		}
	}
	catch (ParseException ex) {
		printExceptionMessage(ex.getMessage(), writer); 
	}
	catch(Exception ex) { 
		printExceptionMessage(ex.getMessage(), writer); 
	}
	finally { 
		// 업로드 정보를 화면에 출력하기 위한 HTML 코드입니다. 신경쓰지 않으셔도 됩니다. 
		printHtmlFooter(writer); 
	}
%>

<%!
	public void printDeletedFilesInfo(String delFile, PrintWriter writer) { 
		if(delFile == null)
			return; 

		String html = ""; 
		html += "<div class='form_area'><table class='form_table'><tbody>"; 
		html += "<tr><td class='form_table_title' colspan=2><b>삭제된 파일 정보</b></td><tr>"; 
		html += "<tr><td>Deleted File</td><td>" + delFile + "</td></tr>"; 
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
	}

	public void printHtmlFooter(PrintWriter writer) { 
		writer.println("</body></html>"); 
		writer.flush();	
	}
%>