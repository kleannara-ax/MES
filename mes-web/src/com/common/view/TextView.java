package com.common.view;

import java.io.BufferedWriter;
import java.io.CharArrayWriter;
import java.io.DataOutputStream;
import java.io.OutputStream;
import java.io.OutputStreamWriter;
import java.net.URLEncoder;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.log4j.Logger;
import org.springframework.web.servlet.view.AbstractView;

import com.common.controller.CommonController;

public class TextView extends AbstractView {
	private static Logger log = Logger.getLogger(TextView.class);
	
	public TextView(){
		super.setContentType("text/plain; charset=UTF-8");
	}

	@Override
	protected void renderMergedOutputModel(Map model,
			HttpServletRequest request,
			HttpServletResponse response) throws Exception{
		String str = model.get("data").toString();
		response.setContentType(super.getContentType());
		response.setCharacterEncoding("UTF-8");
		//response.setContentLength(str.length());
		OutputStream out = response.getOutputStream();
		BufferedWriter writer = new BufferedWriter(new OutputStreamWriter(out, "UTF-8"));
		writer.write(str.toCharArray());
		writer.flush();
	}
}