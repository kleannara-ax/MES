package com.common.controller;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import com.common.bean.CommonConfig;
import com.common.bean.DataMap;

public class BaseController {
	
	public final String TEXT_VIEW = "textView";
	public final String TEXT_FILE_VIEW = "textFileView";
	public final String JSON_VIEW = "jsonView";
	public final String EXCEL_VIEW = "excelView";
	//public final String EXCEL_X_VIEW = "excelXView";
	public final String EXCEL_X_VIEW = "excelSXView";
	public final String FILE_VIEW = "downloadView";
	public final String CSV_VIEW = "csvView";
	public final String EXCEL_TEXT_VIEW = "excelTextView";
	
	public String excelView(DataMap param, Map model, String data){		
		//DataMap labelMap = ((DataMap)param.get(CommonConfig.DATA_EXCEL_LABEL_KEY)).getMap("map");
		//List colList = (List)param.get(CommonConfig.DATA_EXCEL_LABEL_ORDER_KEY);
		//StringUtility sUtil = new StringUtility();
		//DataMap labelMap = new DataMap(sUtil.getStringToMap(param.getString(CommonConfig.DATA_EXCEL_LABEL_KEY)));
		//DataMap formatMap = new DataMap(sUtil.getStringToMap(param.getString(CommonConfig.DATA_EXCEL_FORMAT_KEY)));
		//List<String> colList = sUtil.getStringToList(param.getString(CommonConfig.DATA_EXCEL_LABEL_ORDER_KEY));
		
		DataMap labelMap = param.getMap(CommonConfig.DATA_EXCEL_LABEL_KEY);
		DataMap formatMap = param.getMap(CommonConfig.DATA_EXCEL_FORMAT_KEY);
		List<String> colList = param.getList(CommonConfig.DATA_EXCEL_LABEL_ORDER_KEY);
		
		List<String> labelList = new ArrayList();
		List<String> widthList = param.getList(CommonConfig.DATA_EXCEL_WIDTH_KEY);
		
		String[] dataList = data.split(CommonConfig.DATA_ROW_SEPARATOR);
		if(param.getInt(CommonConfig.DATA_EXCEL_REQUEST_MAXROW_KEY) > 0){
			int maxRow = param.getInt(CommonConfig.DATA_EXCEL_REQUEST_MAXROW_KEY);
			if(dataList.length-1 > maxRow){
				model.put("maxRow", maxRow);
			}else{
				model.put("maxRow", dataList.length-1);
			}
		}else{
			model.put("maxRow", dataList.length-1);
		}
		String[] cols = dataList[0].split(CommonConfig.DATA_COL_SEPARATOR);
		DataMap colMap = new DataMap();
		for(int i=0;i<cols.length;i++){
			colMap.put(cols[i], i);
		}
		model.put("colMap", colMap);
		
		for(int i=0;i<colList.size();i++){
			labelList.add(labelMap.getString(colList.get(i)));
		}
		
		String fileName = param.getString(CommonConfig.DATA_EXCEL_REQUEST_FILE_NAME);
		fileName = (fileName.equals(""))?"excel":fileName;
		
		DataMap comboDataMap = param.getMap(CommonConfig.DATA_EXCEL_COMBO_DATA_KEY);
		
		model.put("fileName", fileName);
		model.put("sheetName", "sheet1");
		model.put("labelList", labelList);
		model.put("widthList", widthList);
		model.put("formatMap", formatMap);
		model.put("colList", colList);
		model.put("dataList", dataList);
		model.put("comboMap", comboDataMap);
		if(param.containsKey(CommonConfig.DATA_EXCEL_MULTI_LABEL_KEY)){
			List multiList =  param.getList(CommonConfig.DATA_EXCEL_LABEL_ORDER_KEY);
			model.put("multiLabelList", param.getList(CommonConfig.DATA_EXCEL_MULTI_LABEL_KEY));
		}
		if(param.containsKey(CommonConfig.DATA_EXCEL_COL_KEY_VIEW)){
			model.put(CommonConfig.DATA_EXCEL_COL_KEY_VIEW, "true");
			return EXCEL_VIEW;
		}
		
		model.put(CommonConfig.DATA_EXCEL_LABEL_VIEW, param.getString(CommonConfig.DATA_EXCEL_LABEL_VIEW));
		
		if(param.containsKey(CommonConfig.DATA_EXCEL_DELIMITER_KEY)){
			model.put(CommonConfig.DATA_EXCEL_DELIMITER_KEY, param.getString(CommonConfig.DATA_EXCEL_DELIMITER_KEY));
		}
		
		if(param.containsKey(CommonConfig.DATA_EXCEL_TEXT_KEY) && param.getString(CommonConfig.DATA_EXCEL_TEXT_KEY).equals("true")){
			return EXCEL_TEXT_VIEW;
		}else if(param.containsKey(CommonConfig.DATA_EXCEL_CSV_KEY) && param.getString(CommonConfig.DATA_EXCEL_CSV_KEY).equals("true")){
			return CSV_VIEW;
		}else if(param.containsKey(CommonConfig.DATA_EXCEL_X_KEY) && param.getString(CommonConfig.DATA_EXCEL_X_KEY).equals("true")){
			return EXCEL_X_VIEW;
		}else{
			return EXCEL_VIEW;
		}
	}
	
	public String excelView(DataMap param, Map model, List<Map> list){
		StringBuilder sb = new StringBuilder();
		if(list.size() > 0){
			Map row = list.get(0);
			Iterator it = row.keySet().iterator();			
			while(it.hasNext()){
				sb.append(it.next().toString()).append("↓");
			}
			sb.append("↑");
			for(int i=0;i<list.size();i++){
				row = list.get(i);
				it = row.keySet().iterator();
				while(it.hasNext()){
					sb.append(row.get(it.next())).append("↓");
				}
				sb.append("↑");
			}
		}
		
		return excelView(param, model, sb.toString());
	}
}