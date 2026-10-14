package com.common.view;

import java.io.BufferedWriter;
import java.io.OutputStream;
import java.io.OutputStreamWriter;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.log4j.Logger;
import org.springframework.web.servlet.view.AbstractView;

public class TextFileView extends AbstractView {
	private static Logger log = Logger.getLogger(TextFileView.class);
	
	public TextFileView(){
		super.setContentType("text/pain; charset=MS949");
	}

	@Override
	protected void renderMergedOutputModel(Map model,
			HttpServletRequest request,
			HttpServletResponse response) throws Exception{
		String fileName = model.get("fileName").toString();
		fileName = new String(fileName.getBytes("UTF-8"), "8859_1");
		String data = model.get("data").toString();
		response.setContentType(super.getContentType());
		//response.setContentLength(sb.toString().toCharArray().length);
		response.setHeader("Content-Transfer-Encoding", "binary");
		response.setHeader("Content-Disposition", "attachment;fileName=\""+fileName+"\";");
		OutputStream out = response.getOutputStream();
		BufferedWriter writer = new BufferedWriter(new OutputStreamWriter(out, "MS949"));
		writer.write(data.toCharArray());
		writer.flush();
	}
}