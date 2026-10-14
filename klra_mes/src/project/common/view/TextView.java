package project.common.view;

import java.io.BufferedWriter;
import java.io.OutputStream;
import java.io.OutputStreamWriter;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.web.servlet.view.AbstractView;

public class TextView extends AbstractView {
	static final Logger log = LogManager.getLogger(TextView.class.getName());
	
	public TextView(){
		super.setContentType("text/plain; charset=UTF-8");
	}

	@Override
	protected void renderMergedOutputModel(Map model, HttpServletRequest request, HttpServletResponse response) throws Exception{
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