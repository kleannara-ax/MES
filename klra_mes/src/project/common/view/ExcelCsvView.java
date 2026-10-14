package project.common.view;

import java.io.OutputStream;
import java.io.OutputStreamWriter;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.web.servlet.view.AbstractView;

import project.common.bean.CommonConfig;

public class ExcelCsvView extends AbstractView {
	static final Logger log = LogManager.getLogger(ExcelCsvView.class.getName());
	
	public ExcelCsvView(){
		super.setContentType("text/csv; charset=MS949");
	}

	@Override
	protected void renderMergedOutputModel(Map model, HttpServletRequest request, HttpServletResponse response) throws Exception{
		
		StringBuilder sb = new StringBuilder();
		
		List labelList = (List)model.get("labelList");
		String str;
		
		if(model.get(CommonConfig.DATA_EXCEL_LABEL_VIEW).toString().equals("true")){
			for(int i=0;i<labelList.size();i++){
				str = labelList.get(i).toString();
				
				if(i != 0){
					sb.append(",");
				}
				sb.append(str);
			}
			sb.append("\n");
		}
		
		List colList = (List)model.get("colList");
		String[] dataList = (String[])model.get("dataList");
		Map<String,Integer> colMap = (Map)model.get("colMap");
		String[] data;
		
		for(int i=0;i<dataList.length-1;i++){
			data = dataList[i+1].split("↓");
			for(int j=0;j<colList.size();j++){
				if(j != 0){
					sb.append(",");
				}
				if(colMap.containsKey(colList.get(j))){
					str = data[colMap.get(colList.get(j))];
				}else{
					str = " ";
				}				
				str = str.replaceAll(",", "，");
				
				sb.append(str);
			}
			sb.append("\n");
		}
		
		String fileName = model.get("fileName").toString();
		fileName = new String(fileName.getBytes("UTF-8"), "8859_1");
		response.setContentType(super.getContentType());
		//response.setContentLength(sb.toString().toCharArray().length);
		response.setHeader("Content-Transfer-Encoding", "excel");
		response.setHeader("Content-Disposition", "attachment;fileName=\""+fileName+".csv\";");
		OutputStream out = response.getOutputStream();
		//PrintWriter writer = new PrintWriter(new OutputStreamWriter(out, "MS949"));
		//BufferedWriter writer = new BufferedWriter(new OutputStreamWriter(out, "MS949"));
		OutputStreamWriter writer = new OutputStreamWriter(out, "MS949");
		writer.write(sb.toString());
		writer.flush();
	}
}