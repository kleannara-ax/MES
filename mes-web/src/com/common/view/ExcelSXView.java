package com.common.view;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;
import java.util.Map;

import javax.servlet.ServletOutputStream;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.CellStyle;
import org.apache.poi.ss.usermodel.DataFormat;
import org.apache.poi.ss.usermodel.Font;
import org.apache.poi.ss.usermodel.IndexedColors;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.ss.util.CellRangeAddress;
import org.apache.poi.xssf.streaming.SXSSFWorkbook;
import org.json.JSONArray;
import org.json.JSONException;
import org.springframework.web.servlet.view.AbstractView;

import com.common.bean.CommonConfig;

public class ExcelSXView extends AbstractView{

	private static final String CONTENT_TYPE = "application/vnd.ms-excel";
	
	private CellStyle cellStyle;
	private CellStyle numberStyle;
	private CellStyle doubleStyle;

	public ExcelSXView() {
	    setContentType(CONTENT_TYPE);
	}
	
	protected void renderMergedOutputModel(Map<String, Object> model, HttpServletRequest request, HttpServletResponse response) throws Exception {
		SXSSFWorkbook workbook = new SXSSFWorkbook(100);
	    try {
	        String fileName = model.get("fileName").toString();
			fileName = new String(fileName.getBytes("UTF-8"), "8859_1");
			String sheetName = model.get("sheetName").toString();
			Sheet sheet = createFirstSheet(workbook, sheetName);
			
			Font headerFont = workbook.createFont();
			headerFont.setFontName(CommonConfig.DATA_EXCEL_FONT_NAME);
	        headerFont.setBoldweight(Font.BOLDWEIGHT_BOLD);
	        
	        CellStyle headCellStyle = workbook.createCellStyle();            
			headCellStyle.setAlignment(CellStyle.ALIGN_CENTER);
			headCellStyle.setVerticalAlignment(CellStyle.VERTICAL_CENTER);
			headCellStyle.setFillForegroundColor(IndexedColors.GREY_25_PERCENT.getIndex());
			headCellStyle.setFillPattern(CellStyle.SOLID_FOREGROUND);  
			headCellStyle.setBorderRight(CellStyle.BORDER_THIN);
			headCellStyle.setBorderLeft(CellStyle.BORDER_THIN);   
			headCellStyle.setBorderTop(CellStyle.BORDER_THIN);   
			headCellStyle.setBorderBottom(CellStyle.BORDER_THIN);
			headCellStyle.setFont(headerFont);
			
			Font cellFont = workbook.createFont();
			cellFont.setFontName(CommonConfig.DATA_EXCEL_FONT_NAME);
			
			cellStyle = workbook.createCellStyle();            
			cellStyle.setBorderRight(CellStyle.BORDER_THIN);
			cellStyle.setBorderLeft(CellStyle.BORDER_THIN);   
			cellStyle.setBorderTop(CellStyle.BORDER_THIN);   
			cellStyle.setBorderBottom(CellStyle.BORDER_THIN);
			cellStyle.setFont(cellFont);
			
			numberStyle = workbook.createCellStyle();
			DataFormat format = workbook.createDataFormat();
			numberStyle.setDataFormat(format.getFormat(CommonConfig.VIEW_FORMAT_EXCEL_INT));
			numberStyle.setBorderRight(CellStyle.BORDER_THIN);
			numberStyle.setBorderLeft(CellStyle.BORDER_THIN);   
			numberStyle.setBorderTop(CellStyle.BORDER_THIN);   
			numberStyle.setBorderBottom(CellStyle.BORDER_THIN);
			
			doubleStyle = workbook.createCellStyle();
			DataFormat doubleFormat = workbook.createDataFormat();
			doubleStyle.setDataFormat(doubleFormat.getFormat(CommonConfig.VIEW_FORMAT_EXCEL_NUM));
			doubleStyle.setBorderRight(CellStyle.BORDER_THIN);
			doubleStyle.setBorderLeft(CellStyle.BORDER_THIN);   
			doubleStyle.setBorderTop(CellStyle.BORDER_THIN);   
			doubleStyle.setBorderBottom(CellStyle.BORDER_THIN);

			List labelList = (List)model.get("labelList");
			List widthList = (List)model.get("widthList");
			
			List multiLabelList = null;
			int multiRowCount = 0;
			if(model.containsKey("multiLabelList")){
				multiLabelList = (List)model.get("multiLabelList");
				multiRowCount = multiLabelList.size()-1;
			}
			
			createColumnLabel(sheet, labelList, multiLabelList, widthList, headCellStyle);
			
			Map formatMap = (Map)model.get("formatMap");
			
			Map comboMap = (Map)model.get("comboMap");
			
			List colList = (List)model.get("colList");
			String[] dataList = (String[])model.get("dataList");
			Map colMap = (Map)model.get("colMap");
			int maxRow = (Integer)model.get("maxRow");
			if(model.containsKey(CommonConfig.DATA_EXCEL_COL_KEY_VIEW)){
				createColumnKey(sheet, colList, headCellStyle);
				createRow(sheet, colList, colMap, dataList, maxRow, formatMap, comboMap, 2+multiRowCount, cellStyle);
			}else{
				createRow(sheet, colList, colMap, dataList, maxRow, formatMap, comboMap, 1+multiRowCount, cellStyle);
			}
			
			response.setContentType("application/octet-stream");
			response.setHeader("Content-Disposition", "attachment;fileName=\""+fileName+".xlsx\";");
	
	        ServletOutputStream out = response.getOutputStream();
	        workbook.write(out);
	
	        if (out != null) out.close();
	    } catch (Exception e) {
	        throw e;
	    } finally {
	        if (workbook != null) {
	        	workbook.dispose();
	        }
	    }
	}
	private Sheet createFirstSheet(Workbook workbook, String sheetName) {
		Sheet sheet = workbook.createSheet();
		workbook.setSheetName(0, sheetName);
		return sheet;
	}
	
	private void createColumnLabel(Sheet sheet, List<String> labelList, List<JSONArray> multiLabelList, List<String> widthList, CellStyle headCellStyle) throws NumberFormatException, JSONException {
		if(multiLabelList == null){
			Row firstRow = sheet.createRow(0);
			for(int i=0;i<labelList.size();i++){
				Cell cell = firstRow.createCell((short)i);
				cell.setCellStyle(headCellStyle);
				cell.setCellValue(labelList.get(i));
				//sheet.autoSizeColumn(i);
				sheet.setColumnWidth(i, Integer.parseInt(widthList.get(i))*(37));
			}
		}else{
			JSONArray tmpCelList;
			String[] tmpCellData;
			String tmpLabel;
			int tmpWidth;
			int tmpRowSapn;
			int tmpColSpan;
			for(int i=0;i<multiLabelList.size();i++){
				Row tmpRow = sheet.createRow(i);
				tmpCelList = multiLabelList.get(i);
				for(int j=0;j<tmpCelList.length();j++){
					if(!tmpCelList.getString(j).equals("B")){
						tmpCellData = tmpCelList.getString(j).split(CommonConfig.DATA_CELL_SEPARATOR);
						tmpRowSapn = Integer.parseInt(tmpCellData[2]);
						tmpColSpan = Integer.parseInt(tmpCellData[3]);
						if(tmpRowSapn == 0){
							tmpRowSapn = i;
						}else{
							tmpRowSapn = i+tmpRowSapn-1;
						}
						if(tmpColSpan == 0){
							tmpColSpan = j;
						}else{
							tmpColSpan = j+tmpColSpan-1;
						}
						sheet.addMergedRegion(new CellRangeAddress(i,tmpRowSapn,j,tmpColSpan));
					}
				}
				for(int j=0;j<tmpCelList.length();j++){
					if(!tmpCelList.getString(j).equals("B")){
						tmpCellData = tmpCelList.getString(j).split(CommonConfig.DATA_CELL_SEPARATOR);
						tmpLabel = tmpCellData[0];
						tmpWidth = Integer.parseInt(tmpCellData[1]);
						Cell cell = tmpRow.createCell((short)j);
						cell.setCellStyle(headCellStyle);
						cell.setCellValue(tmpLabel);
						//sheet.autoSizeColumn(i);
						if(tmpWidth != 0){
							sheet.setColumnWidth(j, tmpWidth*37);
						}						
					}else{
						Cell cell = tmpRow.createCell((short)j);
						cell.setCellStyle(headCellStyle);
						cell.setCellValue("");
					}
				}
			}
		}		
	}
	
	private void createColumnKey(Sheet sheet, List<String> colList, CellStyle headCellStyle) {
		Row firstRow = sheet.createRow(1);
		for(int i=0;i<colList.size();i++){
			Cell cell = firstRow.createCell((short)i);
			cell.setCellStyle(headCellStyle);
			cell.setCellValue(colList.get(i));
			//sheet.autoSizeColumn(i);
		}
	}
	
	private void createRow(Sheet sheet, List<String> colList, Map<String,Integer> colMap, String[] dataList, int maxRow, Map formatMap, Map comboMap, int startRow, CellStyle cellStyle) {
		String[] data;
		
		String[] formatOption;
		for(int i=0;i<maxRow;i++){
			Row row = sheet.createRow(i+startRow);
			data = dataList[i+1].split("↓");
			for(int j=0;j<colList.size();j++){
				Cell cell = row.createCell((short)j);
				cell.setCellStyle(cellStyle);
				/*
				Object tmp = data.get(colList.get(j));
				String value = "";
				if(tmp instanceof BigDecimal){
					value = String.valueOf(((BigDecimal)tmp).floatValue());
				}else{
					value = tmp.toString();
				}
				cell.setCellValue(value);
				*/
				if(comboMap.containsKey(colList.get(j))){
					Map optionMap = (Map)((Map)comboMap.get(colList.get(j))).get("map");
					if(colMap.containsKey(colList.get(j))){
						if(optionMap.containsKey(data[colMap.get(colList.get(j))])){
							cell.setCellValue(optionMap.get(data[colMap.get(colList.get(j))]).toString());
						}else{
							cell.setCellValue(data[colMap.get(colList.get(j))]);
						}
					}else{
						cell.setCellValue(" ");
					}					
				}else if(formatMap.containsKey(colList.get(j))){
					/*if(formatMap.get(colList.get(j)).equals(CommonConfig.DATA_FORMAT_NUMBER)){
						if(colMap.containsKey(colList.get(j))){
							try{
								Double num = Double.parseDouble(data[colMap.get(colList.get(j))]);
								DecimalFormat df = new DecimalFormat("#,###.#");
								String value = df.format(num);
								cell.setCellValue(value);
								//cell.setCellValue(Double.parseDouble(data[colMap.get(colList.get(j))]));
							}catch(Exception e){
								cell.setCellValue(0);
							}						
						}else{
							cell.setCellValue(0);
						}
					}else */
					if(formatMap.get(colList.get(j)).equals(CommonConfig.DATA_FORMAT_DATE)){
						cell.setCellType(Cell.CELL_TYPE_STRING);
						if(colMap.containsKey(colList.get(j))){
							try{
								String value = data[colMap.get(colList.get(j))];
								SimpleDateFormat df = new SimpleDateFormat(CommonConfig.VIEW_FORMAT_DATE);
								int year = Integer.parseInt(value.substring(0, 4));
								int month = Integer.parseInt(value.substring(4, 6));
								int day = Integer.parseInt(value.substring(6, 8));
								if(year<1900 || month<1 || month > 12 || day<1 || day>31){
									cell.setCellValue(value);
								}else{
									Date date = new Date(year-1900, month-1, day);
									value = df.format(date);
									cell.setCellValue(value);
								}
							}catch(Exception e){
								cell.setCellValue(data[colMap.get(colList.get(j))]);
							}	
						}else{
							cell.setCellValue(" ");
						}
					}else if(formatMap.get(colList.get(j)).equals(CommonConfig.DATA_FORMAT_DATETIME)){
						cell.setCellType(Cell.CELL_TYPE_STRING);
						if(colMap.containsKey(colList.get(j))){
							try{
								String value = data[colMap.get(colList.get(j))];
								SimpleDateFormat df = new SimpleDateFormat(CommonConfig.VIEW_FORMAT_DATETIME);
								Date date = new Date(Integer.parseInt(value.substring(0, 4))-1900
												, Integer.parseInt(value.substring(4, 6))-1
												, Integer.parseInt(value.substring(6, 8))
												, Integer.parseInt(value.substring(8, 10))
												, Integer.parseInt(value.substring(10, 12)));
								value = df.format(date);
								cell.setCellValue(value);
							}catch(Exception e){
								cell.setCellValue(data[colMap.get(colList.get(j))]);
							}	
						}else{
							cell.setCellValue(" ");
						}
					}else if(formatMap.get(colList.get(j)).equals(CommonConfig.DATA_FORMAT_DTS)){
						cell.setCellType(Cell.CELL_TYPE_STRING);
						if(colMap.containsKey(colList.get(j))){
							try{
								String value = data[colMap.get(colList.get(j))];
								SimpleDateFormat df = new SimpleDateFormat(CommonConfig.VIEW_FORMAT_DTS);
								Date date = new Date(Integer.parseInt(value.substring(0, 4))-1900
										, Integer.parseInt(value.substring(4, 6))-1
										, Integer.parseInt(value.substring(6, 8))
										, Integer.parseInt(value.substring(8, 10))
										, Integer.parseInt(value.substring(10, 12))
										, Integer.parseInt(value.substring(12, 14)));
								value = df.format(date);
								cell.setCellValue(value);
							}catch(Exception e){
								cell.setCellValue(data[colMap.get(colList.get(j))]);
							}	
						}else{
							cell.setCellValue(" ");
						}
					}else if(formatMap.get(colList.get(j)).equals(CommonConfig.DATA_FORMAT_TIME)){
						cell.setCellType(Cell.CELL_TYPE_STRING);
						if(colMap.containsKey(colList.get(j))){
							try{
								String value = data[colMap.get(colList.get(j))];
								SimpleDateFormat df = new SimpleDateFormat(CommonConfig.VIEW_FORMAT_TIME);
								Date date = new Date();
								date.setHours(Integer.parseInt(value.substring(0, 2)));
								date.setMinutes(Integer.parseInt(value.substring(2, 4)));
								date.setSeconds(Integer.parseInt(value.substring(4, 6)));
								value = df.format(date);
								cell.setCellValue(value);
							}catch(Exception e){
								cell.setCellValue(data[colMap.get(colList.get(j))]);
							}	
						}else{
							cell.setCellValue(" ");
						}
					}else{
						formatOption = formatMap.get(colList.get(j)).toString().split(" ");
						
						if(formatOption[0].equals(CommonConfig.DATA_FORMAT_NUMBER)){
							if(colMap.containsKey(colList.get(j))){
								cell.setCellType(Cell.CELL_TYPE_NUMERIC);
								try{
									String value = data[colMap.get(colList.get(j))];
									if(value.indexOf(".") != -1){
										cell.setCellStyle(doubleStyle);
									}else{
										cell.setCellStyle(numberStyle);
									}
									Double num = Double.parseDouble(data[colMap.get(colList.get(j))]);
									cell.setCellValue(num);
								}catch(Exception e){
									cell.setCellValue(0);
								}						
							}else{
								cell.setCellValue(0);
							}
						}else if(formatOption[0].equals(CommonConfig.DATA_FORMAT_STRING)){
							cell.setCellType(Cell.CELL_TYPE_STRING);
							cell.setCellValue(data[colMap.get(colList.get(j))]);
						}else if(colMap.containsKey(colList.get(j))){
							cell.setCellValue(data[colMap.get(colList.get(j))]);
						}else{
							cell.setCellValue(" ");
						}
					}
				}else{
					if(colMap.containsKey(colList.get(j))){
						cell.setCellValue(data[colMap.get(colList.get(j))]);
					}else{
						cell.setCellValue(" ");
					}
				}
				
				//sheet.autoSizeColumn(j);
			}			
		}
	}
}