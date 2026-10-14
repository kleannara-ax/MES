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
		* 폼 데이터 정보를 처리합니다.
		*/
		String textTitle = request.getParameter("textTitle");			// 제목 
		String radioCate = request.getParameter("radioCate");			// 게시판 선택
		String[] checkInter = request.getParameterValues("checkInter");	// 관심 분야
		String memoTextarea = request.getParameter("memoTextarea");		// 메모 
		printFormUploadResult(textTitle, radioCate, checkInter, memoTextarea, writer); 

		/**
		* 업로드 된 파일 정보를 처리합니다.
		* 샘플에서는 JSON 타입으로 데이터를 교환하고 있습니다. 필요 시 다른 형식으로 조합해서 사용하실 수 있습니다.
		*/
		String uploadedFilesInfo = request.getParameter("uploadedFilesInfo"); 
		if(uploadedFilesInfo != null) {
			JSONParser jsonParser = new JSONParser();
			Object obj = jsonParser.parse(uploadedFilesInfo); 
			JSONArray jsonArray = (JSONArray)obj; 
			for(int i=0; i<jsonArray.size(); i++) {
				//JSONObject jsonObject = (JSONObject)jsonArray.get(i); 
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
			}
			// 업로드 정보 출력
			printFileUploadResult(obj, writer); 
		}


		/**
		* addUploadedFile로 추가한 파일 정보를 처리합니다.
		* 샘플에서는 JSON 타입으로 데이터를 교환하고 있습니다. 필요 시 다른 형식으로 조합해서 사용하실 수 있습니다.
		*/
		String modifiedFilesInfo = request.getParameter("modifiedFilesInfo"); 
		if(modifiedFilesInfo != null) {
			JSONParser jsonParser = new JSONParser();
			Object obj = jsonParser.parse(modifiedFilesInfo); 
			JSONArray jsonArray = (JSONArray)obj; 
			for(int i=0; i<jsonArray.size(); i++) {
				//JSONObject jsonObject = (JSONObject)jsonArray.get(i); 
				/*
				String fileId    				= (String)jsonObject.get("fileId"); 
				String fileName					= (String)jsonObject.get("fileName"); 
				String fileSize				= (String)jsonObject.get("fileSize"); 
				String isDeleted				= (String)jsonObject.get("isDeleted"); 
				*/ 
			}
			// addUploadedFile로 추가한 파일 정보 출력
			printModifiedFileUploadResult(obj, writer); 
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
	public void printFileUploadResult(Object obj, PrintWriter writer) { 
		if(obj == null)
			return; 

		String html = ""; 
		JSONArray jsonArray = (JSONArray)obj; 
		for(int i=0; i<jsonArray.size(); i++) {
			JSONObject jsonObject = (JSONObject)jsonArray.get(i); 
			html += "<div class='form_area'><table class='form_table'><tbody>"; 
			html += "<tr><td class='form_table_title' colspan=2><b>" + (i+1) + "번째 파일 업로드 정보</b></td><tr>"; 
			html += "<tr><td>Name</td><td>" + (String)jsonObject.get("name") + "</td></tr>"; 
			html += "<tr><td>File Name</td><td>" + (String)jsonObject.get("fileName") + "</td></tr>"; 
			html += "<tr><td>Last Saved Directory Path</td><td>" + (String)jsonObject.get("lastSavedDirectoryPath") + "</td></tr>"; 
			html += "<tr><td>Last Saved File Path</td><td>" + (String)jsonObject.get("lastSavedFilePath") + "</td></tr>"; 
			html += "<tr><td>Last Saved File Name</td><td>" + (String)jsonObject.get("lastSavedFileName") + "</td></tr>"; 
			html += "<tr><td>File Size</td><td>" + (String)jsonObject.get("fileSize") + "</td></tr>";
			html += "<tr><td>File Name without File Ext</td><td>" + (String)jsonObject.get("fileNameWithoutFileExt") + "</td></tr>"; 
			html += "<tr><td>File Extension</td><td>" + (String)jsonObject.get("fileExtension") + "</td></tr>"; 
			html += "<tr><td>Content Type</td><td>" + (String)jsonObject.get("contentType") + "</td></tr>"; 
			html += "<tr><td>Is Saved</td><td>" + (String)jsonObject.get("isSaved") + "</td></tr>"; 
			html += "<tr><td>Is EmptyFile</td><td>" + (String)jsonObject.get("isEmptyFile") + "</td></tr>"; 
			html += "</tbody></table></div>";
		}
		writer.println(html); 
	}

	public void printModifiedFileUploadResult(Object obj, PrintWriter writer) { 
		if(obj == null)
			return; 

		String html = ""; 
		JSONArray jsonArray = (JSONArray)obj; 
		for(int i=0; i<jsonArray.size(); i++) {
			JSONObject jsonObject = (JSONObject)jsonArray.get(i); 
			html += "<div class='form_area'><table class='form_table'><tbody>"; 
			html += "<tr><td class='form_table_title' colspan=2><b>" + (i+1) + "번째 수정 모드 파일 정보</b></td><tr>"; 
			html += "<tr><td>File Id</td><td>" + (String)jsonObject.get("fileId") + "</td></tr>"; 
			html += "<tr><td>File Name</td><td>" + (String)jsonObject.get("fileName") + "</td></tr>"; 
			html += "<tr><td>File Size</td><td>" + (String)jsonObject.get("fileSize") + "</td></tr>";
			html += "<tr><td>Is Deleted</td><td>" + (String)jsonObject.get("isDeleted") + "</td></tr>"; 
			html += "</tbody></table></div>";
		}
		writer.println(html); 
	}

	public void printFormUploadResult(String textTitle, String radioCate, String[] checkInter, String memoTextarea, PrintWriter writer) { 
		String html = "<div class='form_area'><table class='form_table'><tbody>"; 
		html += "<tr><td class='form_table_title' colspan=2><b>폼 데이터 업로드 정보</b></td><tr>"; 
		if(textTitle != null)
			html += "<tr><td>제목</td><td>" + textTitle + "</td></tr>"; 
		if(radioCate != null)
			html += "<tr><td>게시판 선택</td><td>" + radioCate + "</td></tr>"; 
		if(checkInter != null) { 
			for(int i=0; i<checkInter.length; i++)
				html += "<tr><td>" + (i+1) + "번째 관심 분야</td><td>" + checkInter[i] + "</td></tr>"; 
		}
		if(memoTextarea != null) 
			html += "<tr><td>메모</td><td>" + memoTextarea + "</td></tr>"; 
			
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