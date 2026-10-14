package com.common.bean;

import java.io.File;
import java.io.IOException;
import java.util.UUID;

import org.springframework.stereotype.Repository;
import org.springframework.web.multipart.MultipartFile;

import com.common.util.FileUtil;

public class FileRepository {
	private String root;
    private String path;
    private String etcRelative;
    private String excelPath;
    private String imagePath;
    private String imageRelative;
    private String aviPath;
    private String aviRelative;
    private String lang;
    private String search;
    private String pageTempPath;
    private String pageCreatePath;
        
    private FileUtil fileUtil = new FileUtil();
    
	public String getRoot() {
		return root;
	}

	public void setRoot(String root) {
		this.root = root;
		this.path = this.root+"file/etc";
		this.etcRelative = "/file/etc";
		this.excelPath = this.root+"file/excel";
		this.imagePath = this.root+"file/image";
		this.aviPath = this.root+"file/avi";
		this.lang = this.root+"common/lang";
		this.imageRelative = "/file/image";
		this.aviRelative = "/file/avi";
		this.search = this.root+"WEB-INF/jsp/search";
		this.pageTempPath = this.root+"WEB-INF/jsp/common/tool/pagetemp";
		this.pageCreatePath = this.root+"WEB-INF/jsp/common/tool/pagecreate";
	}

	public String getPath() {
		return path;
	}

	public void setPath(String path) {
		this.path = path;
	}	

	public String getEtcRelative() {
		return etcRelative;
	}

	public void setEtcRelative(String etcRelative) {
		this.etcRelative = etcRelative;
	}

	public String getExcelPath() {
		return excelPath;
	}

	public void setExcelPath(String excelPath) {
		this.excelPath = excelPath;
	}

	public String getImagePath() {
		return imagePath;
	}

	public void setImagePath(String imagePath) {
		this.imagePath = imagePath;
	}

	public String getAviPath() {
		return aviPath;
	}

	public void setAviPath(String aviPath) {
		this.aviPath = aviPath;
	}	

	public String getImageRelative() {
		return imageRelative;
	}

	public void setImageRelative(String imageRelative) {
		this.imageRelative = imageRelative;
	}

	public String getAviRelative() {
		return aviRelative;
	}

	public void setAviRelative(String aviRelative) {
		this.aviRelative = aviRelative;
	}
	
	public String getLang() {
		return lang;
	}

	public void setLang(String lang) {
		this.lang = lang;
	}

	public String getSearch() {
		return search;
	}

	public void setSearch(String search) {
		this.search = search;
	}

	public String getPageTempPath() {
		return pageTempPath;
	}

	public void setPageTempPath(String pageTempPath) {
		this.pageTempPath = pageTempPath;
	}
	
	public String getPageCreatePath() {
		return pageCreatePath;
	}

	public void setPageCreatePath(String pageCreatePath) {
		this.pageCreatePath = pageCreatePath;
	}

	public String saveFile(MultipartFile sourcefile, String filePath) throws IOException{
        if ((sourcefile==null)||(sourcefile.isEmpty())) return null;
        String key = UUID.randomUUID().toString();
        String fileName = sourcefile.getOriginalFilename();
        fileName = key + fileName.substring(fileName.lastIndexOf(".")).toLowerCase();
        sourcefile.transferTo(fileUtil.getFile(filePath, fileName));
        return key;
    }
    
    public Boolean deleteFile(String uuid) throws IOException{
    	File file = fileUtil.getFile(path, uuid);
    	Boolean result = false;
        if(file.isFile()){
        	result = file.delete();
        }
        return result;
    }
    
    public boolean saveImageThumbnailFile(String orig, String target, int maxDim) throws IOException{    	
    	String separator = "/";//System.getProperty("file.separator");
    	String sourcefile = imagePath+separator+orig;
    	String targetfile = imagePath+separator+target;
        return fileUtil.createThumbnail(sourcefile, targetfile, maxDim);
    }

	@Override
	public String toString() {
		return "FileRepository [path=" + path + ", excelPath=" + excelPath
				+ ", imagePath=" + imagePath + ", imageRelative="
				+ imageRelative + ", aviPath=" + aviPath + ", aviRelative="
				+ aviRelative + ", lang=" + lang + ", fileUtil=" + fileUtil
				+ "]";
	}
}