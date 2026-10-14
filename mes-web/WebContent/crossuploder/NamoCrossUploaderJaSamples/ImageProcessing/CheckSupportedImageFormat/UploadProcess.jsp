<%@page language="java" contentType="text/html; charset=UTF-8"%>
<%@page import="com.namo.crossuploader.*"%>
<%@page import="com.namo.image.*"%>
<%@page import="java.io.*"%>

<%
	PrintWriter writer = response.getWriter(); 
	
	// 업로드 정보를 화면에 출력하기 위한 HTML 코드입니다. 신경쓰지 않으셔도 됩니다. 
	printHtmlHeader(writer); 
	
	try { 
		// 참고용 샘플이며, 업로드 한 이미지가 지원 가능한 이미지인지 판단하는 API는 각 이미지 파일 처리 샘플 내에서 확인 가능합니다.
		String[] readerFormatNames = ImageTool.getReaderFormatNames(); 
		String[] writerFormatNames = ImageTool.getWriterFormatNames(); 
		String[] readerMimeTypes = ImageTool.getReaderMimeTypes(); 
		String[] writerMimeTypes = ImageTool.getWriterMimeTypes(); 
		
		printSupportedImageInfo(readerFormatNames, writerFormatNames, readerMimeTypes, writerMimeTypes, writer);  
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
	public void printSupportedImageInfo(String[] readerFormatNames, String[] writerFormatName, 
			String[] readerMimeTypes, String[] writerMimeTypes, PrintWriter writer) { 

		String html = "<div class='form_area'><table class='form_table'><tbody><tr>"; 
		html += "<td><b>읽기 가능한 이미지 포맷 이름</b></td>";  
		if(readerFormatNames != null) {
			for(int i=0; i<readerFormatNames.length; i++)
				html += "<td>" + readerFormatNames[i] + "</td>";  
		}
		html += "</tr></tbody></table></div>";
		
		html += "<div class='form_area'><table class='form_table'><tbody><tr>"; 
		html += "<td><b>쓰기 가능한 이미지 포맷 이름</b></td>"; 
		if(writerFormatName != null) {
			for(int i=0; i<writerFormatName.length; i++)
				html += "<td>" + writerFormatName[i] + "</td>";  
		}
		html += "</tr></tbody></table></div>";
		
		html += "<div class='form_area'><table class='form_table'><tbody><tr>"; 
		html += "<td><b>읽기 가능한 이미지 마임 타입</b></td>"; 
		if(readerMimeTypes != null) {
			for(int i=0; i<readerMimeTypes.length; i++)
				html += "<td>" + readerMimeTypes[i] + "</td>";  
		}
		html += "</tr></tbody></table></div>"; 
				
				
		html += "<div class='form_area'><table class='form_table'><tbody><tr>"; 
		html += "<td><b>쓰기 가능한  이미지 마임 타입</b></td>"; 
		if(writerMimeTypes != null) {
			for(int i=0; i<writerMimeTypes.length; i++)
				html += "<td>" + writerMimeTypes[i] + "</td>";  
		}
		html += "</tr></tbody></table></div>"; 
		
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
	}%>