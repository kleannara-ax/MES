package project.common.util;

import java.awt.Graphics2D;
import java.awt.Image;
import java.awt.image.BufferedImage;
import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.FileReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.PrintStream;
import java.math.BigDecimal;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.text.SimpleDateFormat;
import java.util.*;

import javax.imageio.ImageIO;
import javax.swing.ImageIcon;

import org.apache.poi.EncryptedDocumentException;
import org.apache.poi.hssf.usermodel.HSSFCell;
import org.apache.poi.hssf.usermodel.HSSFDateUtil;
import org.apache.poi.hssf.usermodel.HSSFRow;
import org.apache.poi.hssf.usermodel.HSSFSheet;
import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.apache.poi.openxml4j.exceptions.InvalidFormatException;
import org.apache.poi.poifs.filesystem.POIFSFileSystem;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.streaming.SXSSFCell;
import org.apache.poi.xssf.streaming.SXSSFRow;
import org.apache.poi.xssf.streaming.SXSSFSheet;
import org.apache.poi.xssf.streaming.SXSSFWorkbook;
import org.apache.poi.xssf.usermodel.XSSFCell;
import org.apache.poi.xssf.usermodel.XSSFRow;
import org.apache.poi.xssf.usermodel.XSSFSheet;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

import project.common.bean.CommonConfig;
import project.common.bean.DataMap;

public class FileUtil {
    private String fileEncoding = "UTF-8";
    private String stringEncoding = "UTF-8";

    public String getFileEncoding() {
        return fileEncoding;
    }

    public void setFileEncoding(String fileEncoding) {
        this.fileEncoding = fileEncoding;
    }

    public String getStringEncoding() {
        return stringEncoding;
    }

    public void setStringEncoding(String stringEncoding) {
        this.stringEncoding = stringEncoding;
    }

    public void setEncoding(String stringEncoding, String fileEncoding) {
        this.stringEncoding = stringEncoding;
        this.fileEncoding = fileEncoding;
    }

    public File getFile(String path, String name) throws IOException {
        File file = new File(path, name);
        return file;
    }

    public String[] getFileList(String path) throws IOException {
        String[] list = null;
        File file = new File(path);
        if (file.isDirectory()) {
            list = file.list();
        }
        return list;
    }

    public Boolean deleteFile(String path, String name) throws IOException {
        File file = new File(path, name);
        Boolean result = false;
        if (file.isFile()) {
            result = file.delete();
        }
        return result;
    }

    //메모리체크
    private static void printMemory(String step) {
        Runtime rt = Runtime.getRuntime();

        long max = rt.maxMemory() / 1024 / 1024;
        long total = rt.totalMemory() / 1024 / 1024;
        long free = rt.freeMemory() / 1024 / 1024;
        long used = total - free;

        System.out.printf(
                "[%s] Used=%dMB, Free=%dMB, Total=%dMB, Max=%dMB%n",
                step, used, free, total, max
        );
    }

    //public List getXlsxFile(File file, int colNameRowNum) throws IOException {
//	public List getXlsxFile(String filename, int colNameRowNum) throws IOException, EncryptedDocumentException, InvalidFormatException {
    public List getXlsxFile(String filename, List<String> gridCols, String menuId) throws IOException, EncryptedDocumentException, InvalidFormatException {
        printMemory("START");

        List list = new ArrayList();
        DataFormatter formatter = new DataFormatter();

        printMemory("BEFORE WorkbookFactory");
        try (Workbook wb = WorkbookFactory.create(new File(filename))) {

            printMemory("AFTER WorkbookFactory");

            //FileInputStream fis = new FileInputStream(file);
            //XSSFWorkbook wb = new XSSFWorkbook(is);
            //XSSFSheet sheet = wb.getSheetAt(0);
            //XSSFRow row;
            //XSSFCell cell;
            // 1. 엑셀 파일 오픈
//            FormulaEvaluator evaluator = wb.getCreationHelper().createFormulaEvaluator();
            //현재는 그냥 첫번째(index 0) 탭을 가져옴
//		Sheet sheet = wb.getSheetAt(0);
            // 앞으로는 메뉴에 따라서 메뉴명이 적인 탭을 가져와야함
            // 3. 전체 시트를 돌면서 이름 매칭 확인
            Sheet sheet = null;
            int sheetCount = wb.getNumberOfSheets();
            for (int i = 0; i < sheetCount; i++) {
                String sheetName = wb.getSheetName(i);

                // 탭 이름에 menuId가 포함되어 있는지 확인 (대소문자 무시)
                if (sheetName != null && menuId != null
                        && sheetName.toUpperCase().contains(menuId.toUpperCase())) {
                    sheet = wb.getSheetAt(i);
                    printMemory("AFTER SHEET 1");
                    break; // 찾았으면 반복문 종료
                }
            }

            // 만약 못 찾았을 경우 방어 코드
            if (sheet == null) {
                if (sheetCount == 0) {
                    throw new RuntimeException("엑셀 파일에 시트가 없습니다.");
                }
                // menuId가 포함된 탭이 없으면 첫 번째 탭(0)을 기본으로 하거나 에러 처리
                sheet = wb.getSheetAt(0);
                printMemory("AFTER SHEET 2");
            }

            Row row;
            Cell cell;

            int rows; // No of rows
            int headerIdx = -1;
            rows = sheet.getPhysicalNumberOfRows();

            // 2. [자동 헤더 스캔 루프]
            // 상위 20개 행만 조사
            // 엑셀의 첫 번째 행부터 순회하며 "데이터의 시작점(헤더)"을 스스로 찾습니다.
            for (int i = 0; i < 20 && i <= sheet.getLastRowNum(); i++) {
                Row headRow = sheet.getRow(i);
                if (headRow == null) {
                    System.out.println("헤더 탐색 중 빈 행 스킵 - rowIndex: " + i);
                    continue;
                }
                // 1. 엑셀 행의 셀 값들을 Set으로 변환
                Set<String> excelHeaders = new HashSet<>();
                for (Cell headerCell : headRow) {
                    // 타입을 따지지 않고 화면에 보이는 텍스트 그대로 읽음
                    String cellValue = formatter.formatCellValue(headerCell).trim();
                    if (!cellValue.isEmpty()) {
                        excelHeaders.add(cellValue);
                    }
                }

                long matchCount = excelHeaders.stream()
                        .filter(header -> gridCols.stream()
                                .anyMatch(col -> col.trim().equalsIgnoreCase(header.trim()))) // 공백 제거 및 대소문자 무시
                        .count();

                // 2. 그리드 컬럼이 모두 포함되는지 확인 (그냥 containsAll 하나면 끝)
                if (!excelHeaders.isEmpty() && matchCount >= (excelHeaders.size() * 0.7)) {
                    // 헤더 찾았다! 이제 여기서 인덱스 따기
                    headerIdx = i;
                    break;
                }
            }

            // 헤더를 찾지 못한 경우 빈 리스트 반환
            if (headerIdx == -1) {
                throw new RuntimeException("엑셀 헤더를 찾을 수 없습니다. 업로드 양식과 컬럼명을 확인해주세요.");
            }

            // 3. 헤더 읽기 (컬럼 매핑 생성)
            List colNames = new ArrayList();
            int lotNoIdx = -1;
            int lotNoAaIdx = -1;
            int lotNoRaIdx = -1;
            int matnrIdx = -1;
            Row headerRow = sheet.getRow(headerIdx);

            if (headerRow == null) {
                throw new RuntimeException("헤더 행이 비어 있습니다. 업로드 파일을 확인해주세요.");
            }

            int cols = headerRow.getPhysicalNumberOfCells();

            for (int i = 0; i < cols; i++) {
                cell = headerRow.getCell((short) i);
                String headerName = cell != null ? formatter.formatCellValue(cell).trim() : "COL_" + i;

                if ("LOT_NO".equals(headerName)) {
                    lotNoIdx = i;
                } else if ("LOT_NO_AA".equals(headerName)) {
                    lotNoAaIdx = i;
                } else if ("LOT_NO_RA".equals(headerName)) {
                    lotNoRaIdx = i;
                } else if ("MATNR".equals(headerName)) {
                    matnrIdx = i;
                }
                colNames.add(headerName);
            }
// LOT_NO 는 필수일 수 없기때문에 ... 화면별로 IF문을 넣던지 그게아니라면 DB단에서 체크하는게 맞는거같음
//		if (lotNoIdx == -1) {
//			throw new RuntimeException("엑셀 파일에서 LOT_NO 컬럼을 찾을 수 없습니다.");
//		}

//		if (rows >= colNameRowNum) {
//			row = sheet.getRow(colNameRowNum);
//			if (row != null) {
//				cols = row.getPhysicalNumberOfCells();
//				for (int i = 0; i < cols; i++) {
//					cell = row.getCell((short) i);
//					if (cell != null) {
//						colNames.add(cell.getStringCellValue());
//					}
//				}
//			}
//		}

            SimpleDateFormat sf = new SimpleDateFormat("yyyyMMdd");
//		SimpleDateFormat sdf = new SimpleDateFormat("MM월 dd일");

            headerIdx++;
//            rows = 10;//test
            int rowCnt = 0;
            for (int r = headerIdx; r < rows; r++) {
                rowCnt++;
                if(rowCnt % 1000 == 0){
                    printMemory("ROW " + rowCnt);
                }
//                row = sheet.getRow(headerIdx); //test
                row = sheet.getRow(r);
                if (row == null || row.getZeroHeight()) {
                    System.out.println("데이터 행 스킵 - 빈 행 또는 숨김 행, rowIndex: " + r);
                    continue;
                }

                if ("QLT03_New".equals(menuId) || "QLT05_New".equals(menuId)) {
                    if (matnrIdx < 0) {
                        throw new RuntimeException("엑셀 파일에서 MATNR 컬럼을 찾을 수 없습니다.");
                    }
                }

                if ("QLT03_New".equals(menuId)) {
                    if (lotNoIdx < 0) {
                        throw new RuntimeException("엑셀 파일에서 LOT_NO 컬럼을 찾을 수 없습니다.");
                    }
                    // 필수 컬럼(lot_no) 값이 비어있으면 '데이터 없는 행'으로 간주
                    Cell lotCell = row.getCell(lotNoIdx);
                    String lotNo;
                    if (lotCell != null && lotCell.getCellType() == 2 /*구버전 int값*/) {
                        lotNo = "FORMULA_EXIST"; // 빈 값이 아니게 만들기 위해 임의의 텍스트 주입
                    } else {
                        // 일반 텍스트나 숫자 셀일 때만 안전하게 기존 포맷터로 읽기
                        lotNo = formatter.formatCellValue(lotCell).trim();
                    }
//                  String lotNo = formatter.formatCellValue(row.getCell(lotNoIdx)).trim();
//					String matnr = formatter.formatCellValue(row.getCell(matnrIdx)).trim();
                    if (lotNo.isEmpty()) {
                        System.out.println("데이터 행 스킵 - LOT_NO 없음, rowIndex: " + r);
                        continue; // 테두리만 있는 빈 행이거나 서식만 적용된 행이면 그냥 패스!
                    } else if (lotNo.matches(".*\\(\\d{2}:\\d{2}~\\d{2}:\\d{2}\\).*") /*&& matnrNm.isEmpty()*/) {
                        // 패턴: (숫자:숫자~숫자:숫자) 형식을 포함하는지 확인
                        System.out.println("데이터 행 스킵 - 시간대 행 또는 자재명 없음, rowIndex: " + r + ", LOT_NO: " + lotNo);
                        continue;
                    }
                } else if("QLT05_New".equals(menuId)){
                    if (lotNoAaIdx < 0) {
                        throw new RuntimeException("엑셀 파일에서 합지 LOT_NO 컬럼을 찾을 수 없습니다.");
                    }

                    try{
                        Cell lotCell = row.getCell(lotNoAaIdx);
                        String lotNo;
                        if (lotCell != null && lotCell.getCellType() == 2 /*구버전 int값*/) {
                            lotNo = "FORMULA_EXIST"; // 빈 값이 아니게 만들기 위해 임의의 텍스트 주입
                        } else {
                            // 일반 텍스트나 숫자 셀일 때만 안전하게 기존 포맷터로 읽기
                            lotNo = formatter.formatCellValue(lotCell).trim();
                        }

                        if (lotNo.isEmpty()) {
                            System.out.println("데이터 행 스킵 - 합지 LOT_NO 없음, rowIndex: " + r);
                            continue; // 테두리만 있는 빈 행이거나 서식만 적용된 행이면 그냥 패스!
                        }
                    } catch (Exception e) {
                        System.out.println("데이터 행 스킵 - LOT_NO, 자재코드 없음, rowIndex: " + r);
                        continue;
                    }

                } else if("QLT_insp_visual_chk".equals(menuId)){
                    if (lotNoRaIdx < 0) {
                        throw new RuntimeException("엑셀 파일에서 가공 LOT_NO 컬럼을 찾을 수 없습니다.");
                    }

                    try{
                        Cell lotCell = row.getCell(lotNoRaIdx);
                        String lotNo;
                        if (lotCell != null && lotCell.getCellType() == 2 /*구버전 int값*/) {
                            lotNo = "FORMULA_EXIST"; // 빈 값이 아니게 만들기 위해 임의의 텍스트 주입
                        } else {
                            // 일반 텍스트나 숫자 셀일 때만 안전하게 기존 포맷터로 읽기
                            lotNo = formatter.formatCellValue(lotCell).trim();
                        }

                        if (lotNo.isEmpty()) {
                            System.out.println("데이터 행 스킵 - LOT_NO, 자재코드 없음, rowIndex: " + r);
                            continue; // 테두리만 있는 빈 행이거나 서식만 적용된 행이면 그냥 패스!
                        }
                    } catch (Exception e) {
                        System.out.println("데이터 행 스킵 - LOT_NO, 자재코드 없음, rowIndex: " + r);
                        continue;
                    }
                }else {
//                    System.out.println("엑셀 데이터 유효성 체크필요???");
                    //todo : 다른 화면 체크로직인데 필요하나싶음 일단남겨놓음
//                    if (isRowCompletelyEmpty(row, formatter)) {
//                        System.out.println("데이터 행 스킵 - 서식만 있는 공백 행(숏서킷 감지), rowIndex: " + r);
//                        continue;
//                    }
                }

                DataMap rowData = new DataMap();
                String value;

                for (int i = 0; i < cols; i++) {
                    cell = row.getCell((short) i);
                    String colName = colNames.get(i).toString();

                    if (cell != null) {
                        CellType cellType = cell.getCellTypeEnum();

                        // 1. 숫자타입처리
                        if (cellType == CellType.NUMERIC) {
                            // 2. 그 다음 날짜 서식인지 확인
                            if (colName.contains("MSRM_DATE")) {
                                java.util.Date date = DateUtil.getJavaDate(cell.getNumericCellValue());
                                value = sf.format(date);
                            } else if (DateUtil.isCellDateFormatted(cell)) {
                                if (colName.endsWith("_TIME") || colName.contains("TIME")) {
                                    value = new SimpleDateFormat("HH:mm").format(cell.getDateCellValue());
                                } else {
                                    value = sf.format(cell.getDateCellValue());
                                }
                            } else {
                                // 날짜가 아닌 그냥 숫자
                                value = formatter.formatCellValue(cell).trim();
                                // 기존에 쓰던 로직임
                                // value = new BigDecimal((double)cell.getNumericCellValue()).toString();
                            }
                            //2. 수식 타입 처리
                        } else if (cellType == CellType.FORMULA) {
                            try {
                                CellType cachedType = cell.getCachedFormulaResultTypeEnum();
//                                CellValue cellValue = evaluator.evaluate(cell);
//                                CellType formulaType = cellValue.getCellTypeEnum();


                                if (cachedType == CellType.NUMERIC) {
//                                    double numberVal = cellValue.getNumberValue();
                                    double numberVal = cell.getNumericCellValue();

                                    if (colName.equals("MD")) {
                                        value = String.valueOf(Math.round(numberVal));
                                    } else if (colName.equals("ELONG")) {
                                        value = String.format("%.2f", Math.round(numberVal * 100) / 100.0);
                                    } else if (colName.endsWith("_HOUR") || colName.endsWith("_MIN")) {
                                        value = String.valueOf((int) Math.round(numberVal));
                                    } else if (colName.endsWith("_TIME") || colName.contains("TIME")) {
                                        if (DateUtil.isCellDateFormatted(cell)) {
                                            value = new SimpleDateFormat("HH:mm").format(cell.getDateCellValue());
                                        } else {
                                            value = formatter.formatCellValue(cell).trim();
                                        }
                                    } else if (colName.equals("MSRM_DATE")){
                                        if (DateUtil.isCellDateFormatted(cell)) {
                                            value = new SimpleDateFormat("yyyy-MM-dd").format(cell.getDateCellValue());
                                        } else {
                                            value = formatter.formatCellValue(cell);;
                                        }
                                    }
                                    /*else if(colName.equals("MATNR") || colName.equals("MACH_CD") || colName.equals("MACH_CD_TRA")){

                                    }*/ else {
//                                        value = cellValue.formatAsString().replace("\"", "");
                                        String formatString = cell.getCellStyle().getDataFormatString();

                                        if (formatString != null && formatString.contains("%")) {
                                            value = new java.text.DecimalFormat("0%").format(numberVal);
                                        } else if (numberVal == Math.floor(numberVal)) {
                                            value = String.valueOf((long) numberVal);
                                        } else {
                                            value = String.valueOf(numberVal);
                                        }
                                    }
                                } else if (cachedType == CellType.STRING) {
//                                    value = cellValue.getStringValue().trim();
                                    value = cell.getStringCellValue().trim();
                                    if (colName.contains("FNL_JDGM")) {
                                        if ("불합격".equals(value)) {
                                            value = "FAIL";
                                        } else if ("합격".equals(value)) {
                                            value = "PASS";
                                        }
                                    }
                                } else if (cachedType == CellType.BOOLEAN) {
//                                    value = String.valueOf(cellValue.getBooleanValue());
                                    value = String.valueOf(cell.getBooleanCellValue());
                                } else {
                                    value = " ";
                                }
                            } catch(Exception e){
                                System.out.println("수식 평가 실패, 공백 처리 - row: " + r + ", colName: " + colName);
                                value = " ";
                            }
                        } else if (cellType == CellType.BLANK) {
                            // [핵심] 여기서 컬럼의 성격에 따라 0 또는 ""을 결정합니다.
                            // 만약 해당 컬럼이 숫자형(N) 데이터라면 0으로 넣어주는 게 좋습니다.
//							if (isNumericColumn) {
//								cellValue = 0;
//							} else {
//								cellValue = "";
//							}
                            value = " ";
                            // 3. 나머지 (문자열 등)
                        } else {
//							if (colName.contains("MSRM_DATE")) {
//								java.util.Date date = DateUtil.getJavaDate(cell.getNumericCellValue());
//								value = sf.format(date);
//							}
                            value = formatter.formatCellValue(cell).trim();
                            if (colName.contains("FNL_JDGM")) {
                                if ("불합격".equals(value)) {
                                    value = "FAIL";
                                } else if ("합격".equals(value)) {
                                    value = "PASS";
                                }
                            }
                        }
                    } else {
                        value = " ";
                    }
                    rowData.put(colName, value);
//						switch (cell.getCellType()) {
//							case XSSFCell.CELL_TYPE_FORMULA:
//								value = cell.getCellFormula();
//								break;
//							case XSSFCell.CELL_TYPE_NUMERIC:
//								if(HSSFDateUtil.isCellDateFormatted(cell)){
//									value = sf.format(cell.getDateCellValue());
//								} else {
//									//DecimalFormat df = new DecimalFormat("#,###.#");
//									//df.format(num);
//									value = new BigDecimal((double)cell.getNumericCellValue()).toString();
//									/*
//									if(value.indexOf(".") != -1){
//										value = value.substring(0, value.indexOf("."));
//									}
//									*/
//								}
//								//value = (long) cell.getNumericCellValue() + "";
//								break;
//							case XSSFCell.CELL_TYPE_STRING:
//								value = cell.getStringCellValue();
//								break;
//							case XSSFCell.CELL_TYPE_BLANK:
//								// value = cell.getBooleanCellValue()+"";
//								value = " ";
//								break;
//							case XSSFCell.CELL_TYPE_ERROR:
//								value = cell.getErrorCellValue() + "";
//								break;
//						}
                }
                list.add(rowData);

                if(list.size() % 1000 == 0){
                    printMemory("LIST " + list.size());
                }
            }
            if (list.isEmpty()) {
                throw new RuntimeException("엑셀 데이터가 없습니다. 업로드 파일 형식 또는 필수값을 확인해주세요.");
            }

            printMemory("RETURN");
            return list;

        } catch (EncryptedDocumentException e) {
            System.out.println("암호화된 엑셀 파일입니다. filename: " + filename);
            throw e;
        } catch (InvalidFormatException e) {
            System.out.println("엑셀 파일 형식이 올바르지 않습니다. filename: " + filename);
            throw e;
        } catch (IOException e) {
            System.out.println("엑셀 파일 읽기 중 IO 오류가 발생했습니다. filename: " + filename);
            throw e;
        } catch (Exception e) {
            System.out.println("엑셀 업로드 처리 중 오류가 발생했습니다. filename: " + filename + ", message: " + e.getMessage());
            throw new RuntimeException("엑셀 업로드 처리 중 오류가 발생했습니다: " + e.getMessage(), e);
        } finally {
            printMemory("AFTER Workbook Close");
        }
    }

    public static boolean isRowCompletelyEmpty(Row row, DataFormatter formatter) {
        if (row == null) return true;

        for (Cell cell : row) {
            if (cell != null) {
                // 💡 셀 타입 비교를 과감히 지우고, 포맷터가 읽은 글자가 있는지만 검사합니다.
                String val = formatter.formatCellValue(cell).trim();
                if (!val.isEmpty()) {
                    return false; // ◀ 글자가 하나라도 나오는 순간 즉시 탈출 (유효 행)
                }
            }
        }
        return true; // 끝까지 다 돌았는데 싹 다 비어있으면 진짜 허수 Row
    }

    //public List getXlsxFileCollist(File file, int colNameRowNum) throws IOException {
    public List getXlsxFileCollist(String filename, int colNameRowNum) throws IOException, EncryptedDocumentException, InvalidFormatException {
        //FileInputStream fis = new FileInputStream(file);
        //XSSFWorkbook wb = new XSSFWorkbook(fis);
        //XSSFSheet sheet = wb.getSheetAt(0);
        //XSSFRow row;
        //XSSFCell cell;

        InputStream is = Files.newInputStream(Paths.get(filename));
        Workbook wb = WorkbookFactory.create(is);
        Sheet sheet = wb.getSheetAt(0);
        Row row;
        Cell cell;

        int rows; // No of rows
        rows = sheet.getPhysicalNumberOfRows();

        List colNames = new ArrayList();
        int cols = 0;

        if (rows >= colNameRowNum) {
            row = sheet.getRow(colNameRowNum);
            if (row != null) {
                cols = row.getPhysicalNumberOfCells();
                for (int i = 0; i < cols; i++) {
                    cell = row.getCell((short) i);
                    if (cell != null) {
                        colNames.add(cell.getStringCellValue());
                    }
                }
            }
        }

        return colNames;
    }

    //public List getXlsFile(File file, int colNameRowNum) throws FileNotFoundException, IOException {
    public List getXlsFile(String filename, int colNameRowNum, String targetTab) throws EncryptedDocumentException, InvalidFormatException, IOException {
        List list = new ArrayList();

        //POIFSFileSystem fs = new POIFSFileSystem(Files.newInputStream(Paths.get(filename)));
        //POIFSFileSystem fs = new POIFSFileSystem(new FileInputStream(file));
        //HSSFWorkbook wb = new HSSFWorkbook(fs);
        //HSSFSheet sheet = wb.getSheetAt(0);
        //HSSFRow row;
        //HSSFCell cell;
        InputStream is = Files.newInputStream(Paths.get(filename));
        Workbook wb = WorkbookFactory.create(is);
        Sheet sheet = wb.getSheetAt(0);
        Row row;
        Cell cell;

        int rows; // No of rows
        rows = sheet.getPhysicalNumberOfRows();

        List colNames = new ArrayList();
        int cols = 0;

        if (rows >= colNameRowNum) {
            row = sheet.getRow(colNameRowNum);
            if (row != null) {
                cols = row.getPhysicalNumberOfCells();
                for (int i = 0; i < cols; i++) {
                    cell = row.getCell((short) i);
                    if (cell != null) {
                        colNames.add(cell.getStringCellValue());
                    }
                }
            }
        }

        colNameRowNum++;
        SimpleDateFormat sf = new SimpleDateFormat("yyyyMMdd");
        for (int r = colNameRowNum; r < rows; r++) {
            row = sheet.getRow(r);
            if (row != null) {
                DataMap rowData = new DataMap();
                for (int i = 0; i < cols; i++) {
                    cell = row.getCell((short) i);
                    String value = "";
                    if (cell != null) {
                        switch (cell.getCellType()) {
                            case HSSFCell.CELL_TYPE_FORMULA:
                                value = cell.getCellFormula();
                                break;
                            case HSSFCell.CELL_TYPE_NUMERIC:
                                if (HSSFDateUtil.isCellDateFormatted(cell)) {
                                    value = sf.format(cell.getDateCellValue());
                                } else {
                                    //value = new BigDecimal((double)cell.getNumericCellValue()).toString();
                                    value = cell.getNumericCellValue() + "";
									/*
									if(value.indexOf(".") != -1){
										value = value.substring(0, value.indexOf("."));
									}
									*/
                                }
                                break;
                            case HSSFCell.CELL_TYPE_STRING:
                                value = cell.getStringCellValue();
                                break;
                            case HSSFCell.CELL_TYPE_BLANK:
                                // value = cell.getBooleanCellValue()+"";
                                value = " ";
                                break;
                            case HSSFCell.CELL_TYPE_ERROR:
                                value = cell.getErrorCellValue() + "";
                                break;
                        }
                    }
                    rowData.put(colNames.get(i), value);
                }
                list.add(rowData);
            }
        }
        colNames.clear();
        wb.close();
        is.close();

        return list;
    }

    //public List getXlsFileCollist(File file, int colNameRowNum) throws FileNotFoundException, IOException {
    public List getXlsFileCollist(String filename, int colNameRowNum) throws IOException, EncryptedDocumentException, InvalidFormatException {
        //POIFSFileSystem fs = new POIFSFileSystem(new FileInputStream(file));
        //HSSFWorkbook wb = new HSSFWorkbook(fs);
        //HSSFSheet sheet = wb.getSheetAt(0);
        //HSSFRow row;
        //HSSFCell cell;

        InputStream is = Files.newInputStream(Paths.get(filename));
        Workbook wb = WorkbookFactory.create(is);
        Sheet sheet = wb.getSheetAt(0);
        Row row;
        Cell cell;

        int rows; // No of rows
        rows = sheet.getPhysicalNumberOfRows();

        List colNames = new ArrayList();
        int cols = 0;

        if (rows >= colNameRowNum) {
            row = sheet.getRow(colNameRowNum);
            if (row != null) {
                cols = row.getPhysicalNumberOfCells();
                for (int i = 0; i < cols; i++) {
                    cell = row.getCell((short) i);
                    if (cell != null) {
                        colNames.add(cell.getStringCellValue());
                    }
                }
            }
        }

        return colNames;
    }

    /*
     * public List getExcelFile(String path, String name, String userId) throws
     * IOException { List list = new ArrayList();
     *
     * POIFSFileSystem excel = null; File file = new File(path, name);
     * FileInputStream fis = new FileInputStream(file); try { excel = new
     * POIFSFileSystem(fis); HSSFWorkbook workBook = new HSSFWorkbook(excel);
     * HSSFSheet sheet = null; HSSFRow row = null; HSSFCell cell = null;
     *
     * if (workBook.getNumberOfSheets() > 0) { sheet = workBook.getSheetAt(0); if
     * (sheet.getPhysicalNumberOfRows() > 1) { row = sheet.getRow(0); String[]
     * colList = null; if (row.getPhysicalNumberOfCells() > 0) { colList = new
     * String[row.getPhysicalNumberOfCells()]; for (short i = 0; i < colList.length;
     * i++) { cell = row.getCell(i); colList[i] = cell.getStringCellValue(); } for
     * (int i = 1; i < sheet.getPhysicalNumberOfRows(); i++) { row =
     * sheet.getRow(i); DataMap map = new DataMap(); for (short j = 0; j <
     * colList.length; j++) { cell = row.getCell(j); String value = ""; if (cell !=
     * null) { switch (cell.getCellType()) { case 0: value =
     * String.valueOf(cell.getNumericCellValue()); break; default: value =
     * cell.getStringCellValue(); } } map.put(colList[j], value); }
     * map.put(CommonConfig.SES_USER_ID_KEY, userId); list.add(map); } } } } }
     * finally { fis.close(); file.delete(); }
     *
     * return list; }
     */

    public List getTextFile(File file, boolean emptyRemoveType) {
        List list = new ArrayList();
        try {
            BufferedReader in = new BufferedReader(new FileReader(file));
            String s;
            while ((s = in.readLine()) != null) {
                if (emptyRemoveType && s.equals("")) {
                    continue;
                }
                list.add(s);
            }
            in.close();
        } catch (FileNotFoundException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        }

        return list;
    }

    public int getTextFileLineCount(File file, boolean emptyRemoveType) {
        int count = 0;
        try {
            BufferedReader in = new BufferedReader(new FileReader(file));
            String s;
            while ((s = in.readLine()) != null) {
                if (emptyRemoveType && s.equals("")) {
                    continue;
                }
                count++;
            }
            in.close();
        } catch (FileNotFoundException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        }

        return count;
    }

    /*
     * path : 파일 디렉토리 경로 name : 파일명 cols : 컬럼명 배열 separator : 구분자
     *
     * 지정된 파일을 읽어 cols로 지정된 컬럼명 기준으로 DataMap에 담는다.
     */
    /*
     * public List getSepFile(String path, String name, String[] cols, String
     * separator) throws IOException { List list = new ArrayList(); File file = new
     * File(path, name); if (file.isFile()) { FileInputStream fis = new
     * FileInputStream(file); Scanner s = new Scanner(fis); while (s.hasNext()) {
     * String str = s.nextLine(); if (str != null && !str.equals("")) { if
     * (!this.stringEncoding.equals(this.fileEncoding)) { str = new
     * String(str.getBytes(this.fileEncoding), this.stringEncoding); } String[]
     * rowData = str.split(separator); DataMap row = new DataMap(); for (int i = 0;
     * i < rowData.length; i++) { String key; if (cols.length > (i + 1)) { key =
     * cols[i]; } else { key = " "; } row.put(key, rowData[i]); } list.add(row); } }
     * s.close(); fis.close(); } return list; }
     */

    /*
     * path : 파일 디렉토리 경로 name : 파일명 cols : 컬럼명 배열 lsit : 데이터 리스트 separator : 구분자
     *
     * list에서 데이터를 읽어 DataMap에 들어있는 데이터를 cols순서대로 separator를 붙여 파일을 생성한다.
     */
    public void writeSepFile(String path, String name, String[] cols, List list, String separator) throws IOException {
        File file = new File(path, name);
        StringBuilder sb = new StringBuilder();
        DataMap row;
        for (int i = 0; i < list.size(); i++) {
            row = (DataMap) list.get(i);
            for (int j = 0; j < cols.length; j++) {
                String str = row.getString(cols[j]);
                if (!this.stringEncoding.equals(this.fileEncoding)) {
                    str = new String(str.getBytes(this.stringEncoding), this.fileEncoding);
                }
                sb.append(str);
                if (j < (cols.length - 1)) {
                    sb.append(separator);
                }
            }
            if (i < (list.size() - 1)) {
                sb.append("/r/n");
            }
        }
        String sfileName = file.getPath();
        //OutputStream os = new FileOutputStream(file);
        OutputStream os = Files.newOutputStream(Paths.get(sfileName));
        PrintStream ps = new PrintStream(os);
        ps.print(sb.toString());
        ps.close();
        os.close();
    }

    //public String getStringFile(String path, String name) throws IOException {
    //	File file = new File(path, name);
    //	StringBuilder sb = new StringBuilder();
    //	if (file.isFile()) {
    //		FileInputStream fis = new FileInputStream(file);
    //		Scanner s = new Scanner(fis);
    //		while (s.hasNext()) {
    //			sb.append(s.nextLine()).append("\r\n");
    //		}
    //		s.close();
    //		fis.close();
    //	}
    //	return sb.toString();
    //}

    public void writeStringFile(String path, String name, String content) throws IOException {
        File file = new File(path, name);
        String sfileName = file.getPath();
        //OutputStream os = new FileOutputStream(file);
        OutputStream os = Files.newOutputStream(Paths.get(sfileName));
        PrintStream ps = new PrintStream(os, true, "UTF-8");
        ps.print(content.toString());
        ps.close();
        os.close();
    }

    public boolean createThumbnail(String loadFile, String saveFile, int maxDim) throws IOException {
        File save = new File(saveFile.replaceAll("/", "\\" + File.separator));
        FileInputStream fis = new FileInputStream(loadFile.replaceAll("/", "\\" + File.separator));
        BufferedImage im = ImageIO.read(fis);

        Image inImage = new ImageIcon(loadFile).getImage();

        double scale = (double) maxDim / (double) inImage.getHeight(null);
        if (inImage.getWidth(null) > inImage.getHeight(null)) {
            scale = (double) maxDim / (double) inImage.getWidth(null);
        }

        int scaledW = (int) (scale * inImage.getWidth(null));
        int scaledH = (int) (scale * inImage.getHeight(null));

        BufferedImage thumb = new BufferedImage(scaledW, scaledH, BufferedImage.TYPE_INT_RGB);
        Graphics2D g2 = thumb.createGraphics();

        g2.drawImage(im, 0, 0, scaledW, scaledH, null);
        return ImageIO.write(thumb, "jpg", save);
    }

    public Properties loadProperties(String path, String fname) {
        Properties properties = new Properties();
        // Read properties file.
        try {
            File file = new File(path, fname);
            String sfileName = file.getPath();
            properties.load(Files.newInputStream(Paths.get(sfileName)));
            //properties.load(new FileInputStream(file));
        } catch (IOException e) {
        }


        /*
         * if(false) { String avalue = properties.getProperty("a");
         * System.out.println(avalue); properties.setProperty("a", "properties test");
         *
         * // Write properties file. try { properties.store(new
         * FileOutputStream("example01.properties"), null); } catch (IOException e) { }
         * }
         */

        return properties;
    }

    public String createNowDir(String path) throws IOException {
        Date date = new Date();
        SimpleDateFormat df = new SimpleDateFormat("yyyyMM");
        String ymd = df.format(date);

        path += "/" + ymd;

        File file = new File(path);

        if (!file.isDirectory()) {
            file.mkdirs();
        }

        return ymd;
    }

    public boolean createDir(String path) throws IOException {
        File file = new File(path);

        if (!file.isDirectory()) {
            return file.mkdirs();
        }

        return false;
    }
}