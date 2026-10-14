package com.common.util;

import java.awt.Graphics2D;
import java.awt.Image;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.io.OutputStream;
import java.io.PrintStream;
import java.math.BigDecimal;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.Iterator;
import java.util.List;
import java.util.Properties;
import java.util.Scanner;

import javax.imageio.ImageIO;
import javax.swing.ImageIcon;

import org.apache.poi.hssf.usermodel.HSSFCell;
import org.apache.poi.hssf.usermodel.HSSFDateUtil;
import org.apache.poi.hssf.usermodel.HSSFRow;
import org.apache.poi.hssf.usermodel.HSSFSheet;
import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.apache.poi.poifs.filesystem.POIFSFileSystem;
import org.apache.poi.xssf.streaming.SXSSFWorkbook;
import org.apache.poi.xssf.usermodel.XSSFCell;
import org.apache.poi.xssf.usermodel.XSSFRow;
import org.apache.poi.xssf.usermodel.XSSFSheet;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

import com.common.bean.CommonConfig;
import com.common.bean.DataMap;
import com.opencsv.CSVReader;
import com.opencsv.CSVWriter;

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

	public List getXlsxFile(File file, int colNameRowNum) throws IOException {
		List list = new ArrayList();

		FileInputStream fis = new FileInputStream(file);
		XSSFWorkbook wb = new XSSFWorkbook(fis);
		XSSFSheet sheet = wb.getSheetAt(0);
		XSSFRow row;
		XSSFCell cell;

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

		SimpleDateFormat sf = new SimpleDateFormat("yyyyMMdd");
		colNameRowNum++;
		for (int r = colNameRowNum; r < rows; r++) {
			row = sheet.getRow(r);
			if (row != null) {
				DataMap rowData = new DataMap();
				for (int i = 0; i < cols; i++) {
					cell = row.getCell((short) i);
					String value = "";
					if (cell != null) {
						switch (cell.getCellType()) {
						case XSSFCell.CELL_TYPE_FORMULA:
							value = cell.getCellFormula();
							break;
						case XSSFCell.CELL_TYPE_NUMERIC:
							if(HSSFDateUtil.isCellDateFormatted(cell)){								
								value = sf.format(cell.getDateCellValue());								
							} else {
								value = new BigDecimal((double)cell.getNumericCellValue()).toString();
								/*
								if(value.indexOf(".") != -1){
									value = value.substring(0, value.indexOf("."));
								}
								*/
							}
							break;
						case XSSFCell.CELL_TYPE_STRING:
							value = cell.getStringCellValue();
							break;
						case XSSFCell.CELL_TYPE_BLANK:
							// value = cell.getBooleanCellValue()+"";
							value = " ";
							break;
						case XSSFCell.CELL_TYPE_ERROR:
							value = cell.getErrorCellValue() + "";
							break;
						}
					}
					rowData.put(colNames.get(i), value);
				}
				list.add(rowData);
			}
		}

		return list;
	}
	
	public List getXlsxFileCollist(File file, int colNameRowNum) throws IOException {
		List list = new ArrayList();

		FileInputStream fis = new FileInputStream(file);
		XSSFWorkbook wb = new XSSFWorkbook(fis);
		XSSFSheet sheet = wb.getSheetAt(0);
		XSSFRow row;
		XSSFCell cell;

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

	public List getXlsFile(File file, int colNameRowNum) throws FileNotFoundException, IOException {
		List list = new ArrayList();

		POIFSFileSystem fs = new POIFSFileSystem(new FileInputStream(file));
		HSSFWorkbook wb = new HSSFWorkbook(fs);
		HSSFSheet sheet = wb.getSheetAt(0);
		HSSFRow row;
		HSSFCell cell;

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

		SimpleDateFormat sf = new SimpleDateFormat("yyyyMMdd");
		colNameRowNum++;
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
							if(HSSFDateUtil.isCellDateFormatted(cell)){								
								value = sf.format(cell.getDateCellValue());								
							} else {
								value = new BigDecimal((double)cell.getNumericCellValue()).toString();
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

		return list;
	}
	
	public List getXlsFileCollist(File file, int colNameRowNum) throws FileNotFoundException, IOException {
		List list = new ArrayList();

		POIFSFileSystem fs = new POIFSFileSystem(new FileInputStream(file));
		HSSFWorkbook wb = new HSSFWorkbook(fs);
		HSSFSheet sheet = wb.getSheetAt(0);
		HSSFRow row;
		HSSFCell cell;

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

	public List getExcelFile(String path, String name, String userId) throws IOException {
		List list = new ArrayList();

		POIFSFileSystem excel = null;
		File file = new File(path, name);
		FileInputStream fis = new FileInputStream(file);
		try {
			excel = new POIFSFileSystem(fis);
			HSSFWorkbook workBook = new HSSFWorkbook(excel);
			HSSFSheet sheet = null;
			HSSFRow row = null;
			HSSFCell cell = null;

			if (workBook.getNumberOfSheets() > 0) {
				sheet = workBook.getSheetAt(0);
				if (sheet.getPhysicalNumberOfRows() > 1) {
					row = sheet.getRow(0);
					String[] colList = null;
					if (row.getPhysicalNumberOfCells() > 0) {
						colList = new String[row.getPhysicalNumberOfCells()];
						for (short i = 0; i < colList.length; i++) {
							cell = row.getCell(i);
							colList[i] = cell.getStringCellValue();
						}
						for (int i = 1; i < sheet.getPhysicalNumberOfRows(); i++) {
							row = sheet.getRow(i);
							DataMap map = new DataMap();
							for (short j = 0; j < colList.length; j++) {
								cell = row.getCell(j);
								String value = "";
								if (cell != null) {
									switch (cell.getCellType()) {
									case 0:
										value = String.valueOf(cell.getNumericCellValue());
										break;
									default:
										value = cell.getStringCellValue();
									}
								}
								map.put(colList[j], value);
							}
							map.put(CommonConfig.SES_USER_ID_KEY, userId);
							list.add(map);
						}
					}
				}
			}
		} finally {
			fis.close();
			file.delete();
		}

		return list;
	}
	
	public List getCsvFile(File file, int colNameRowNum, boolean mapType) throws FileNotFoundException, IOException{
		List list = new ArrayList();
		try {
            CSVReader reader = new CSVReader(new FileReader(file));
            //UTF-8
            //CSVReader reader = new CSVReader(new InputStreamReader(new FileInputStream(file), "UTF-8"), ",", '"', 1);
            String[] s;
            String[] cols = null;
            colNameRowNum--;
            int rowCount = 0;
            while ((s = reader.readNext()) != null) {
            	if(rowCount == colNameRowNum){
            		cols = s;
            	}else if(rowCount > colNameRowNum){
            		if(mapType){
            			DataMap row = new DataMap();
            			for(int i=0;i<cols.length;i++){
            				row.put(cols[i], s[i]);
            			}
            			list.add(row);
            		}else{
            			list.add(s);
            		}
            	}
            	rowCount++;
            }
        } catch (FileNotFoundException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        }
		
		return list;
	}
	
	public void writeCsv(File file, List<String[]> data) {
        try {
            CSVWriter cw = new CSVWriter(new FileWriter(file), ',', '"');
            Iterator<String[]> it = data.iterator();
            try {
                while (it.hasNext()) {
                    String[] s = (String[]) it.next();
                    cw.writeNext(s);
                }
            } finally {
                cw.close();
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
	
	public File writeExcel(HSSFWorkbook workbook, String filePath, String fileName) throws IOException {
		//HSSFWorkbook workbook = new HSSFWorkbook();
		File file = new File(filePath, fileName);
        FileOutputStream fos = null;
        try {
            fos = new FileOutputStream(file);
            workbook.write(fos);
        } finally {
            try {
                if(fos!=null) fos.close();
            } catch (IOException e) {
                // TODO Auto-generated catch block
            }
        }
        return file;
    }
	
	public File writeExcelX(SXSSFWorkbook workbook, String filePath, String fileName) throws IOException {
		//HSSFWorkbook workbook = new HSSFWorkbook();
		File file = new File(filePath, fileName);
        FileOutputStream fos = null;
        try {
            fos = new FileOutputStream(file);
            workbook.write(fos);
        } finally {
            try {
                if(fos!=null) fos.close();
            } catch (IOException e) {
                // TODO Auto-generated catch block
            }
        }
        return file;
    }
	
	/*
	 * path : 파일 디렉토리 경로 name : 파일명 cols : 컬럼명 배열 separator : 구분자
	 * 
	 * 지정된 파일을 읽어 cols로 지정된 컬럼명 기준으로 DataMap에 담는다.
	 */
	public List getSepFile(String path, String name, String[] cols, String separator) throws IOException {
		List list = new ArrayList();
		File file = new File(path, name);
		if (file.isFile()) {
			FileInputStream fis = new FileInputStream(file);
			Scanner s = new Scanner(fis);
			while (s.hasNext()) {
				String str = s.nextLine();
				if (str != null && !str.equals("")) {
					if (!this.stringEncoding.equals(this.fileEncoding)) {
						str = new String(str.getBytes(this.fileEncoding), this.stringEncoding);
					}
					String[] rowData = str.split(separator);
					DataMap row = new DataMap();
					for (int i = 0; i < rowData.length; i++) {
						String key;
						if (cols.length > (i + 1)) {
							key = cols[i];
						} else {
							key = " ";
						}
						row.put(key, rowData[i]);
					}
					list.add(row);
				}
			}
			s.close();
			fis.close();
		}
		return list;
	}

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
		OutputStream os = new FileOutputStream(file);
		PrintStream ps = new PrintStream(os);
		ps.print(sb.toString());
		ps.close();
		os.close();
	}

	public String getStringFile(String path, String name) throws IOException {
		File file = new File(path, name);
		StringBuilder sb = new StringBuilder();
		if (file.isFile()) {
			FileInputStream fis = new FileInputStream(file);
			Scanner s = new Scanner(fis);
			while (s.hasNext()) {
				sb.append(s.nextLine()).append("\r\n");
			}
			s.close();
			fis.close();
		}
		return sb.toString();
	}

	public void writeStringFile(String path, String name, String content) throws IOException {
		File file = new File(path, name);
		OutputStream os = new FileOutputStream(file);
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
			properties.load(new FileInputStream(file));
		} catch (IOException e) {
		}

		String avalue = properties.getProperty("a");
		System.out.println(avalue);
		properties.setProperty("a", "properties test");

		// Write properties file.
		try {
			properties.store(new FileOutputStream("example01.properties"), null);
		} catch (IOException e) {
		}
		
		return properties;
	}
	
	public String createNowDir(String path) throws IOException {
		Date date = new Date();
		SimpleDateFormat df = new SimpleDateFormat("yyyyMM");
		String ymd = df.format(date);
		
		path += "/" + ymd;
		
		File file = new File(path);
		
		if(!file.isDirectory()){
			file.mkdirs();
		}
		
		return ymd;
	}
	
	public boolean createDir(String path) throws IOException {
		File file = new File(path);
		
		if(!file.isDirectory()){
			return file.mkdirs();
		}
		
		return false;
	}
}