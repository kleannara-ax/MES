package project.common.view;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import javax.servlet.ServletOutputStream;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.xml.crypto.Data;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
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

import project.common.aop.PerformanceTraceAdvice;
import project.common.bean.CommonConfig;
import project.common.bean.DataMap;

public class ExcelSXView extends AbstractView{
	static final Logger log = LogManager.getLogger(ExcelSXView.class);

	private static final String CONTENT_TYPE = "application/vnd.ms-excel";

	private CellStyle cellStyle;
	private CellStyle numberStyle;
	private CellStyle doubleStyle;
	private CellStyle qltNumberStyle;
	private CellStyle qltDoubleStyle;
	private CellStyle qltMinuteStyle;

	public ExcelSXView() {
	    setContentType(CONTENT_TYPE);
	}
	
	protected void renderMergedOutputModel(Map<String, Object> model, HttpServletRequest request, HttpServletResponse response) throws Exception {
		SXSSFWorkbook workbook = new SXSSFWorkbook();
	    try {
	        String fileName = model.get("fileName").toString();
			fileName = new String(fileName.getBytes("UTF-8"), "8859_1");
			DataMap paramData = (DataMap) request.getAttribute("ParamData");
			String menuId = paramData.getString("menuId");
			String sheetName = model.get("sheetName").toString();
			Sheet sheet = createFirstSheet(workbook, sheetName);
			
			Font headerFont = workbook.createFont();
			headerFont.setFontName(CommonConfig.DATA_EXCEL_FONT_NAME);
	        //headerFont.setBoldweight(Font.BOLDWEIGHT_BOLD);
	        
	        CellStyle headCellStyle = workbook.createCellStyle();            
			//headCellStyle.setAlignment(CellStyle.ALIGN_CENTER);
			//headCellStyle.setVerticalAlignment(CellStyle.VERTICAL_CENTER);
			headCellStyle.setFillForegroundColor(IndexedColors.GREY_25_PERCENT.getIndex());
			//headCellStyle.setFillPattern(CellStyle.SOLID_FOREGROUND);  
			//headCellStyle.setBorderRight(CellStyle.BORDER_THIN);
			//headCellStyle.setBorderLeft(CellStyle.BORDER_THIN);   
			//headCellStyle.setBorderTop(CellStyle.BORDER_THIN);   
			//headCellStyle.setBorderBottom(CellStyle.BORDER_THIN);
			headCellStyle.setFont(headerFont);
			
			Font cellFont = workbook.createFont();
			cellFont.setFontName(CommonConfig.DATA_EXCEL_FONT_NAME);
			
			cellStyle = workbook.createCellStyle();            
			//cellStyle.setBorderRight(CellStyle.BORDER_THIN);
			//cellStyle.setBorderLeft(CellStyle.BORDER_THIN);   
			//cellStyle.setBorderTop(CellStyle.BORDER_THIN);   
			//cellStyle.setBorderBottom(CellStyle.BORDER_THIN);
			cellStyle.setFont(cellFont);
			
			numberStyle = workbook.createCellStyle();
			DataFormat format = workbook.createDataFormat();
			numberStyle.setDataFormat(format.getFormat(CommonConfig.VIEW_FORMAT_EXCEL_INT));
			//numberStyle.setBorderRight(CellStyle.BORDER_THIN);
			//numberStyle.setBorderLeft(CellStyle.BORDER_THIN);   
			//numberStyle.setBorderTop(CellStyle.BORDER_THIN);   
			//numberStyle.setBorderBottom(CellStyle.BORDER_THIN);
			
			doubleStyle = workbook.createCellStyle();
			DataFormat doubleFormat = workbook.createDataFormat();
			doubleStyle.setDataFormat(doubleFormat.getFormat(CommonConfig.VIEW_FORMAT_EXCEL_NUM));
			//doubleStyle.setBorderRight(CellStyle.BORDER_THIN);
			//doubleStyle.setBorderLeft(CellStyle.BORDER_THIN);   
			//doubleStyle.setBorderTop(CellStyle.BORDER_THIN);   
			//doubleStyle.setBorderBottom(CellStyle.BORDER_THIN);

			qltNumberStyle = workbook.createCellStyle();
			qltNumberStyle.cloneStyleFrom(numberStyle);
			qltNumberStyle.setDataFormat(
					format.getFormat("#,##0;-#,##0;;")
			);

			qltDoubleStyle = workbook.createCellStyle();
			qltDoubleStyle.cloneStyleFrom(doubleStyle);
			qltDoubleStyle.setDataFormat(
					doubleFormat.getFormat("#,##0.00;-#,##0.00;;")
			);

			qltMinuteStyle = workbook.createCellStyle();
			qltMinuteStyle.cloneStyleFrom(cellStyle);
			qltMinuteStyle.setDataFormat(doubleFormat.getFormat("00"));

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
			
			Map<String, String> formatNumberMap = (Map)model.get("formatNumberMap");
			Map numberFormatMap = new HashMap();
			Iterator<String> it = formatNumberMap.keySet().iterator();
			while(it.hasNext()){
				String key = it.next();
				String value = formatNumberMap.get(key);
				if(!value.equals("")){
					String[] numberFormat = value.split(",");
					String tmpFormat = "#,##0";
					CellStyle tmpNumberStyle = workbook.createCellStyle();
					
					if(numberFormat.length > 1){						
						tmpFormat += "."; 
						Integer size = Integer.valueOf(numberFormat[1]);
						for(int i=0;i<size;i++){
							tmpFormat += "0";
						}
						tmpNumberStyle.setDataFormat(format.getFormat(tmpFormat));
						numberFormatMap.put(key, tmpNumberStyle);
					}				
				}				
			}
			
			Map comboMap = (Map)model.get("comboMap");
			
			List colList = (List)model.get("colList");
			String[] dataList = (String[])model.get("dataList");
			Map colMap = (Map)model.get("colMap");
			int maxRow = (Integer)model.get("maxRow");
			if(model.containsKey(CommonConfig.DATA_EXCEL_COL_KEY_VIEW)){
				createColumnKey(sheet, colList, headCellStyle);
				createRow(sheet, colList, colMap, dataList, maxRow, formatMap, comboMap, 2+multiRowCount, cellStyle, numberFormatMap, menuId);
			}else{
				createRow(sheet, colList, colMap, dataList, maxRow, formatMap, comboMap, 1+multiRowCount, cellStyle, numberFormatMap, menuId);
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
			for (int i = 0; i < multiLabelList.size(); i++) {
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
						try {
							sheet.addMergedRegion(new CellRangeAddress(i,tmpRowSapn,j,tmpColSpan));
						} catch (Exception e) {
							// TODO: handle exception
						}
					}
				}
				for (int j = 0; j < tmpCelList.length(); j++) {
					if (!tmpCelList.getString(j).equals("B")) {
						tmpCellData = tmpCelList.getString(j).split(CommonConfig.DATA_CELL_SEPARATOR);
						tmpLabel = tmpCellData[0];
						tmpWidth = Integer.parseInt(tmpCellData[1]);
						Cell cell = tmpRow.createCell((short)j);
						cell.setCellStyle(headCellStyle);
						cell.setCellValue(tmpLabel);
						//sheet.autoSizeColumn(i);
						if (tmpWidth != 0) {
							sheet.setColumnWidth(j, tmpWidth * 37);
						}
					} else {
						Cell cell = tmpRow.createCell((short)j);
						cell.setCellStyle(headCellStyle);
						cell.setCellValue("");
					}
				}
			}
		}		
	}
	
	private void createColumnKey(Sheet sheet, List<String> colList, CellStyle headCellStyle) {
//		Row firstRow = sheet.createRow(1);
		int lastRowNum = sheet.getLastRowNum();
		// 시트가 비어있고 첫 행(0번)도 없는 경우를 대비
		Row newRow;
		if (lastRowNum == 0 && sheet.getRow(0) == null) {
			newRow = sheet.createRow(0); // 완전 처음이면 0번부터 시작
		} else {
			newRow = sheet.createRow(lastRowNum + 1); // 그 외엔 다음 줄에 생성
		}

		for(int i=0;i<colList.size();i++){
			Cell cell = newRow.createCell((short)i);
			cell.setCellStyle(headCellStyle);
			cell.setCellValue(colList.get(i));
			//sheet.autoSizeColumn(i);
		}
	}
	
	private String getValue(String[] data, Map<String,Integer> colMap, List<String> colList, int j){
		if(colMap.get(colList.get(j)) >= data.length){
			return "";
		}else{
			return data[colMap.get(colList.get(j))];
		}
	}
	
	
	private void createRow(Sheet sheet, List<String> colList, Map<String,Integer> colMap, String[] dataList, int maxRow, Map formatMap, Map comboMap, int startRow, CellStyle cellStyle, Map numberFormatMap, String menuId) {
		String[] data;
		
		String[] formatOption;
		int dataIndex;


		boolean isQltMenu = "QLT03_New".equals(menuId) || "QLT05_New".equals(menuId) || "QLT_insp_visual_chk".equals(menuId);

		for (int i = 0; i < maxRow; i++) {
			Row row = sheet.createRow(i + startRow);
			data = dataList[i + 1].split("↓");
			for (int j = 0; j < colList.size(); j++) {
				String colName = colList.get(j);

				boolean hasColumn = colMap.containsKey(colName);

				String value = hasColumn
						? getValue(data, colMap, colList, j)
						: "";

				Object format = formatMap.get(colName);

				Cell cell = row.createCell((short) j);
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

				//콤보박스
				if (comboMap.containsKey(colName)) {
					@SuppressWarnings("unchecked")
					Map<?, ?> comboItem = (Map<?, ?>) comboMap.get(colName);
					Map<String, String> optionMap = (comboItem != null) ? (Map<String, String>) comboItem.get("map") : null;
					if (hasColumn) {
						if (optionMap != null && optionMap.containsKey(value)) {
							// 1. 값 추출 (null 안전하게 변환)
							String optionVal = String.valueOf(optionMap.get(value));

							// 2. 품질관리 메뉴일 때만 대괄호([..]) 제거
							if (isQltMenu) {
								optionVal = optionVal.replaceAll("\\[.*?\\]", "");
							}

							cell.setCellValue(optionVal);
						} else {
							cell.setCellValue(value);
						}
					} else {
						cell.setCellValue(" ");
					}
				} else if (formatMap.containsKey(colName)) {
					/*if(formatMap.get(colName).equals(CommonConfig.DATA_FORMAT_NUMBER)){
						if(hasColumn){
							try{
								Double num = Double.parseDouble(getValue(data, colMap, colList, j));
								DecimalFormat df = new DecimalFormat("#,###.#");
								String value = df.format(num);
								cell.setCellValue(value);
								//cell.setCellValue(Double.parseDouble(getValue(data, colMap, colList, j)));
							}catch(Exception e){
								cell.setCellValue(0);
							}						
						}else{
							cell.setCellValue(0);
						}
					}else */
					if (CommonConfig.DATA_FORMAT_DATE.equals(format)) {
						cell.setCellType(Cell.CELL_TYPE_STRING);
						if (hasColumn) {
							try {
//								String value = getValue(data, colMap, colList, j);
								SimpleDateFormat df = new SimpleDateFormat(CommonConfig.VIEW_FORMAT_DATE);
								int year = Integer.parseInt(value.substring(0, 4));
								int month = Integer.parseInt(value.substring(4, 6));
								int day = Integer.parseInt(value.substring(6, 8));
								if (year < 1900 || month < 1 || month > 12 || day < 1 || day > 31) {
									cell.setCellValue(value);
								} else {
									Date date = new Date(year - 1900, month - 1, day);
									value = df.format(date);
									cell.setCellValue(value);
								}
							} catch (Exception e) {
								cell.setCellValue(value);
							}
						} else {
							cell.setCellValue(" ");
						}
					} else if (CommonConfig.DATA_FORMAT_DATETIME.equals(format)) {
						cell.setCellType(Cell.CELL_TYPE_STRING);
						if (hasColumn) {
							try {
//								String value = getValue(data, colMap, colList, j);
								SimpleDateFormat df = new SimpleDateFormat(CommonConfig.VIEW_FORMAT_DATETIME);
								Date date = new Date(Integer.parseInt(value.substring(0, 4)) - 1900
										, Integer.parseInt(value.substring(4, 6)) - 1
										, Integer.parseInt(value.substring(6, 8))
										, Integer.parseInt(value.substring(8, 10))
										, Integer.parseInt(value.substring(10, 12)));
								value = df.format(date);
								cell.setCellValue(value);
							} catch (Exception e) {
								cell.setCellValue(value);
							}
						} else {
							cell.setCellValue(" ");
						}
					} else if (CommonConfig.DATA_FORMAT_DTS.equals(format)) {
						cell.setCellType(Cell.CELL_TYPE_STRING);
						if (hasColumn) {
							try {
//								String value = getValue(data, colMap, colList, j);
								SimpleDateFormat df = new SimpleDateFormat(CommonConfig.VIEW_FORMAT_DTS);
								Date date = new Date(Integer.parseInt(value.substring(0, 4)) - 1900
										, Integer.parseInt(value.substring(4, 6)) - 1
										, Integer.parseInt(value.substring(6, 8))
										, Integer.parseInt(value.substring(8, 10))
										, Integer.parseInt(value.substring(10, 12))
										, Integer.parseInt(value.substring(12, 14)));
								value = df.format(date);
								cell.setCellValue(value);
							} catch (Exception e) {
								cell.setCellValue(value);
							}
						} else {
							cell.setCellValue(" ");
						}
					} else if (CommonConfig.DATA_FORMAT_TIME.equals(format)) {
						cell.setCellType(Cell.CELL_TYPE_STRING);
						if (hasColumn) {
							try {
//								String value = getValue(data, colMap, colList, j);
								SimpleDateFormat df = new SimpleDateFormat(CommonConfig.VIEW_FORMAT_TIME);
								Date date = new Date();
								date.setHours(Integer.parseInt(value.substring(0, 2)));
								date.setMinutes(Integer.parseInt(value.substring(2, 4)));
								date.setSeconds(Integer.parseInt(value.substring(4, 6)));
								value = df.format(date);
								cell.setCellValue(value);
							} catch (Exception e) {
								cell.setCellValue(value);
							}
						} else {
							cell.setCellValue(" ");
						}
					} else {
						formatOption = format.toString().split(" ");

						if (formatOption[0].equals(CommonConfig.DATA_FORMAT_NUMBER)) {
							if (hasColumn) {
								cell.setCellType(Cell.CELL_TYPE_NUMERIC);
								try {
//									String value = getValue(data, colMap, colList, j);
									//스타일지정
//									log.info("{} {}", colName, numberFormatMap.containsKey(colName));
									if (numberFormatMap.containsKey(colName)) {
										if(isQltMenu){
											cell.setCellStyle(qltDoubleStyle);
										}else{
											CellStyle tmpNumberStyle = (CellStyle) numberFormatMap.get(colName);
											cell.setCellStyle(tmpNumberStyle);
										}
									} else {
										if(isQltMenu){
											if(colName.startsWith("TIME_")){
												cell.setCellStyle(qltMinuteStyle);
											}else if(value != null && value.contains(".")){
												cell.setCellStyle(qltDoubleStyle);
											}else{
												cell.setCellStyle(qltNumberStyle);
											}
										}else{
											if(value != null && value.contains(".")){
												cell.setCellStyle(doubleStyle);
//												log.info("cell style={}", cell.getCellStyle().getDataFormatString());
											}else{
												cell.setCellStyle(numberStyle);
											}
										}
									}

									if(value == null || value.trim().isEmpty()) {
										if(isQltMenu){
											cell.setCellValue("");
										}else{
											cell.setCellValue(0);
										}
									} else {
										Double num = Double.parseDouble(value);

//										log.info("before cell : value={}, num={}", value, num);

										if (isQltMenu && Double.compare(num, 0D) == 0 && !colName.startsWith("TIME_")) {
											cell.setCellType(Cell.CELL_TYPE_STRING);
											cell.setCellValue("");
										} else {
											cell.setCellValue(num);

//											log.info("cellType={}", cell.getCellType());
//											log.info("numeric={}", cell.getNumericCellValue());
//											log.info("style format={}", cell.getCellStyle().getDataFormatString());
										}

									}
								} catch (Exception e) {
									log.error("Excel Number Convert Error : menuId={}, col={}, value={}",
											menuId, colName, value, e);
									cell.setCellValue(0);
								}
							} else {
								cell.setCellValue(0);
							}

						} else if (formatOption[0].equals(CommonConfig.DATA_FORMAT_STRING)) {
							cell.setCellType(Cell.CELL_TYPE_STRING);
							cell.setCellValue(value);
						} else if (hasColumn) {
							cell.setCellValue(value);
						} else {
							cell.setCellValue(" ");
						}
					}
				} else {
					if (hasColumn) {
						dataIndex = (Integer) colMap.get(colName);
						if (dataIndex < data.length) {
							cell.setCellValue(value);
						} else {
							cell.setCellValue(CommonConfig.DATA_COL_EMPTY_VALUE);
						}
					} else {
						cell.setCellValue(CommonConfig.DATA_COL_EMPTY_VALUE);
					}
				}

				//sheet.autoSizeColumn(j);
			}
		}
	}
}