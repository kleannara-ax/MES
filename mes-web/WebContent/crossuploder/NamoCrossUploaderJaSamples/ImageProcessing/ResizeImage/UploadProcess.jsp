<%@page language="java" contentType="text/html; charset=UTF-8"%>
<%@page import="com.namo.crossuploader.*"%>
<%@page import="com.namo.image.*"%>
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
		
		// saveDirPath에 지정한 경로로 파일 업로드를 시작합니다. 
		fileUpload.startUpload(saveDirPath); 	

		// 업로드 경로를 지정하지 않을 경우, 시스템의 임시 디렉토리로 파일 업로드를 시작합니다. 	
		// fileUpload.startUpload(); 

		// 입력한 name을 키로 갖는 마지막 FileItem 객체를 리턴합니다.
		// "files"는 UploadForm.jsp에서 입력한 값입니다. <input type="file" name="files"> 
		FileItem fileItem = fileUpload.getFileItem("files");

		if(fileItem != null) { 
			// saveDirPath 경로에 원본 파일명으로 저장(이동)합니다. 동일한 파일명이 존재할 경우 다른 이름으로 저장됩니다.
			fileItem.save(saveDirPath); 	
			
			// 다른 유형의 저장(이동) 함수들
			// save(); 
			// save(String saveDirPath, boolean overwrite);
			// saveAs(String saveDirPath, String fileName); 
			// saveAs(String saveDirPath, String fileName, boolean overwrite); 
						
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
			
			// 이미지 객체 생성.
			ImageTool image = ImageTool.getImage(fileItem);
			// 다른 유형의 Image 객체를 가져오는 함수들
			// getImage(File sourceFile);
			// getImage(String sourceFilePath);
			
			// image가 null이면, 지원되지 않는 이미지 포맷이거나 파일을 찾을 수 없는 경우입니다. 
			if(image != null) { 
				String imageFormatName = image.getFormatName();  
				int imageWidth = image.getWidth(); 
				int imageHeight = image.getHeight(); 
		
				// 기본적인 이미지 정보 출력 
				printBasicImageInfo(image, writer); 
				
		
				// autoMakeDirs를 true로 설정하면 파일 저장시 파일생성에 필요한 상위 디렉토리를 모두 생성합니다.
				image.setAutoMakeDirs(true); 
				
				// 저장할 이미지 파일 경로 및 이름 설정
				String imageSaveDirPath = saveDirPath + "image" + File.separator; 
				String imageFileName = "Converted_" + fileItem.getLastSavedFileName();
				
				/**
				* [ 이미지 변경을 위한 ImageProp 객체의 프로퍼티 ] 
				* setWidth : 생성할 이미지의 너비를 설정합니다. 기본 값은 원본 이미지의 너비입니다. 
				* setHeight : 생성할 이미지의 높이를 설정합니다. 기본 값은 원본 이미지의 높이입니다.
				* setRatio : 변경할 원본 이미지의 비율입니다. 비율에 따라 너비와 높이가 설정됩니다. 기본 값은 원본 이미지의 비율입니다.
				* 			 원본 크기 비율은 1.0f입니다. (예, 2.0f는 두배 크기, 0.5f는 원본의 1/2일 크기) 
				*			 너비, 높이를 명시적으로 입력하면 비율은 무시됩니다. 
				* setQuality : 생성할 이미지의 퀄리티를 설정합니다. 기본 값은 1.0f이며, 가장 높은 퀄리티입니다. 
				* setFormatName : 생성할 이미지의 포맷 설정합니다. 기본 값은 원본 이미지의 포맷입니다. 
				*				: 지원되지 않는 포맷 이름을 입력할 경우 예외가 발생합니다. 
				*/
				// 비율로 변경할 이미지 크기 변경 
				ImageProp imageProp = new ImageProp(); 
				imageProp.setRatio(0.5f); // 원본의 50% 비율 
				String ratioFilePath = image.convertAs(imageProp, imageSaveDirPath, imageFileName);  
				
				// 너비, 높이 지정으로 이미지 크기 변경
				imageProp.setWidth(100);
				imageProp.setHeight(100);
				String fixedFilePath = image.convertAs(imageProp, imageSaveDirPath, imageFileName);  
		
				// 다른 유형의 변경(이동) 함수들
				// convert(ImageProp imageProp); 
				// convert(ImageProp imageProp, String saveDirPath); 
				// convert(ImageProp imageProp, String saveDirPath, boolean overwrite);
				// convertAs(ImageProp imageProp, String saveDirPath, String fileName, boolean overwrite);
				
				// 변경된 이미지 파일 정보 출력
				printConvertedImageInfo(ratioFilePath, fixedFilePath, writer); 
			}
			else { 
				printBasicImageInfo(null, writer); 
			}
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

<%!public void printBasicImageInfo(ImageTool image, PrintWriter writer) { 
		String html = "<div class='form_area'><table class='form_table'><tbody>"; 
		html += "<tr><td class='form_table_title' colspan=2><b>기본적인 이미지 정보</b></td><tr>"; 
		if(image != null) { 
			html += "<tr><td>Image Format Name</td><td>" + image.getFormatName() + "</td></tr>"; 
			html += "<tr><td>Image Width</td><td>" + image.getWidth() + "</td></tr>"; 
			html += "<tr><td>Image Height</td><td>" + image.getHeight() + "</td></tr>"; 
		}
		else {
			html += "<tr><td colspan=2>지원되지 않는 이미지 포맷이거나 파일을 찾을 수 없습니다. </td></tr>"; 
		}
		html += "</tbody></table></div>";
		
		writer.println(html); 
	}

	public void printConvertedImageInfo(String ratioFilePath, String fixedFilePath, PrintWriter writer) { 
		String ratioFileName = ratioFilePath.substring(ratioFilePath.lastIndexOf(File.separator)+1);  
		String fixedFileName = fixedFilePath.substring(fixedFilePath.lastIndexOf(File.separator)+1);  

		String html = "<div class='form_area'><table class='form_table'><tbody>"; 
		html += "<tr><td class='form_table_title' colspan=2><b>이미지 변경 정보</b></td><tr>"; 
		html += "<tr><td>원본 이미지의 50% 비율로 수정한 이미지 파일의 경로</td><td>" + ratioFilePath + "</td></tr>"; 
		html += "<tr><td class='form_table_title' colspan=2><img src='/UploadDir/image/" + ratioFileName + "'></td><tr>"; 
		html += "<tr><td>너비 100, 높이 100 크기로 수정 한  이미지 파일의 경로</td><td>" + fixedFilePath + "</td></tr>"; 
		html += "<tr><td class='form_table_title' colspan=2><img src='/UploadDir/image/" + fixedFileName + "'></td><tr>"; 
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
	}%>