package com.common.view;

import java.io.File;
import java.io.FileInputStream;
import java.io.OutputStream;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.springframework.util.FileCopyUtils;
import org.springframework.web.servlet.view.AbstractView;

public class FileDownloadView extends AbstractView {
	public FileDownloadView(){
		super.setContentType("application/octet-stream");
	}

	@Override
	protected void renderMergedOutputModel(Map model,
			HttpServletRequest request,
			HttpServletResponse response) throws Exception{
		
		File file = (File) model.get("downloadFile");
		String fileName = (String)model.get("fileName");
		fileName = new String(fileName.getBytes("UTF-8"), "8859_1");
		response.setContentType(super.getContentType());
		response.setContentLength((int) file.length());
		response.setHeader("Content-Transfer-Encoding", "binary");
		response.setHeader("Content-Disposition", "attachment;fileName=\"" + fileName + "\";");
		OutputStream out = response.getOutputStream();
		FileInputStream fis = null;
		try{
			fis = new FileInputStream(file);
			FileCopyUtils.copy(fis, out);
		}catch (java.io.IOException ioe){
			ioe.printStackTrace();
		}finally{
			if (fis != null)
				fis.close();
		}
	}
}
