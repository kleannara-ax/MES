<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="com.namo.crossuploader.*"%>
<%@page import="java.io.*"%>
<%@page import="org.json.simple.JSONObject"%>

<%
	PrintWriter writer = response.getWriter();
	FileUpload fileUpload = new FileUpload(request, response); 
	
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

		/**
		* 입력한 file 태그의 name을 키로 갖는 FileItem[] 객체를 리턴합니다.  
		* NamoCrossUploader Client Flex Edition의 name은 "CU_FILE" 입니다.
		*/
		FileItem fileItem = fileUpload.getFileItem("CU_FILE"); 

		if(fileItem != null) { 
			// saveDirPath 경로에 원본 파일명으로 저장(이동)합니다. 동일한 파일명이 존재할 경우 다른 이름으로 저장됩니다.
			fileItem.save(saveDirPath); 	
			
			// 다른 유형의 저장(이동) 함수들
			/*
			save(); 
			save(String saveDirPath, boolean overwrite);
			saveAs(String saveDirPath, String fileName); 
			saveAs(String saveDirPath, String fileName, boolean overwrite); 
			*/ 
			
			// FileItem 객체로 아래와 같은 정보를 가져올 수 있습니다. 추가적으로 필요한 정보가 있을 경우 JSONObject 객체에 추가해 주십시오.
			// 교환할 데이터는 JSON 타입이 아니어도 되며, Javascript에서 파싱할 적절한 형태로 조합하시면 됩니다.
			// LastSavedDirectoryPath, LastSavedFileName에는 Windwos 경로에 대한 예외처리가 되어 있습니다. 서버 환경에 맞게 적절히 수정해 주십시오.
			JSONObject jsonObject = new JSONObject();

			jsonObject.put("name", fileItem.getName()); 
			jsonObject.put("fileName", fileItem.getFileName()); 
			jsonObject.put("lastSavedDirectoryPath", fileItem.getLastSavedDirPath().replaceAll("\\\\", "/")); 
			jsonObject.put("lastSavedFilePath", fileItem.getLastSavedFilePath().replaceAll("\\\\", "/")); 
			jsonObject.put("lastSavedFileName", fileItem.getLastSavedFileName()); 
			jsonObject.put("fileSize", Long.toString(fileItem.getFileSize())); 
			jsonObject.put("fileNameWithoutFileExt", fileItem.getFileNameWithoutFileExt()); 
			jsonObject.put("fileExtension", fileItem.getFileExtension()); 
			jsonObject.put("contentType", fileItem.getContentType()); 
			jsonObject.put("isSaved", Boolean.toString(fileItem.isSaved())); 
			jsonObject.put("isEmptyFile", Boolean.toString(fileItem.isEmptyFile())); 

			StringWriter stringWriter = new StringWriter();
			jsonObject.writeJSONString(stringWriter);
			writer.println(jsonObject.toString());
		}
	}
	catch(CrossUploaderException ex) {
		response.setStatus(response.SC_INTERNAL_SERVER_ERROR);
	}
	catch(Exception ex) {
		// 업로드 외 로직에서 예외 발생시 업로드 중인 모든 파일을 삭제합니다. 
		fileUpload.deleteUploadedFiles(); 
		response.setStatus(response.SC_INTERNAL_SERVER_ERROR);
	}
	finally { 
		// 파일 업로드 객체에서 사용한 자원을 해제합니다. 
		fileUpload.clear(); 
	}
%>

