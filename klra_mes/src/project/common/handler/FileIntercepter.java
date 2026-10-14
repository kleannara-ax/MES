package project.common.handler;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.UUID;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.multipart.MultipartHttpServletRequest;
import org.springframework.web.servlet.handler.HandlerInterceptorAdapter;

import project.common.bean.CommonConfig;
import project.common.bean.DataMap;
import project.common.bean.FileRepository;
import project.common.bean.UriInfo;
import project.common.service.CommonService;

public class FileIntercepter extends HandlerInterceptorAdapter {
	
	static final Logger log = LogManager.getLogger(FileIntercepter.class.getName());
	
	@Autowired
	private FileRepository respository;
	
	@Autowired
	private CommonService commonService;
	
	private DataMap imageExtNameMap;
	
	public FileIntercepter(){
		imageExtNameMap = new DataMap();
		imageExtNameMap.put("bmp", true);
		imageExtNameMap.put("gif", true);
		imageExtNameMap.put("jpg", true);
		imageExtNameMap.put("jpeg", true);
		imageExtNameMap.put("jpe", true);
		imageExtNameMap.put("jfif", true);
		imageExtNameMap.put("jp2", true);
		imageExtNameMap.put("j2c", true);
		imageExtNameMap.put("png", true);
		imageExtNameMap.put("ai", true);
		imageExtNameMap.put("psd", true);
		imageExtNameMap.put("tga", true);
		imageExtNameMap.put("taga", true);
		imageExtNameMap.put("tif", true);
	}

	@Override
	public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {
		DataMap params = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		UriInfo uriInfo = (UriInfo)request.getAttribute(CommonConfig.REQUEST_URI_INFO_KEY);
		
		if(uriInfo.getDataType().equals("fileDown")){
			params.put(CommonConfig.MODULE_ATT_KEY, CommonConfig.FILE_MODULE);
			params.put(CommonConfig.COMMAND_ATT_KEY, CommonConfig.FILE_TABLE_NAME);
		}else if(uriInfo.getDataType().equals("fileUp") || uriInfo.getDataType().equals("fileGroupUp")){
			MultipartHttpServletRequest fileRequest = (MultipartHttpServletRequest)request;		
			
			DataMap fileParam = new DataMap();
			fileParam.put(CommonConfig.MODULE_ATT_KEY, CommonConfig.FILE_MODULE);
			fileParam.put(CommonConfig.COMMAND_ATT_KEY, CommonConfig.FILE_TABLE_NAME);
			
			String guuid = fileRequest.getParameter("GUUID");
			if(guuid != null && guuid.equals("")){
				guuid = UUID.randomUUID().toString();
			}
			fileParam.put("GUUID", guuid);
			
			String fileType = fileRequest.getParameter("FILE_TYPE");
			if(fileType == null){
				fileType = "all";
			}
			
			List uuidList = new ArrayList();
			//List saveNameList = new ArrayList();
			List fileInfoList = new ArrayList();
			Iterator it = fileRequest.getFileNames();
			//DataMap fileMap = new DataMap();
			while(it.hasNext()){
				String fName = it.next().toString();
				MultipartFile file = fileRequest.getFile(fName);
				if(file.isEmpty()){
					continue;
				}
				String uuid = null;
				
				String fileName = file.getOriginalFilename();
		        String extName = fileName.substring(fileName.lastIndexOf(".")+1).toLowerCase();
		        
				if(uriInfo.getWorkType().equals("image") || fileType.equals("image")){
					if(!imageExtNameMap.containsKey(extName)){
						throw new IOException("image file check error!");
					}
					//uuid = respository.saveImsageFile(file, respository.getImagePath());
					uuid = respository.saveFile(file, respository.getImagePath());
					if(uriInfo.getModule().equals("editor")){
						fileParam.put("STYPE", "eimg");
					}else{
						fileParam.put("STYPE", "img");
					}					
				}else if(uriInfo.getWorkType().equals("avi")){
					uuid = respository.saveFile(file, respository.getAviPath());
					if(uriInfo.getModule().equals("editor")){
						fileParam.put("STYPE", "eavi");
					}else{
						fileParam.put("STYPE", "avi");
					}
				}else if(uriInfo.getWorkType().equals("excel")){
					uuid = respository.saveFile(file, respository.getExcelPath());
					fileParam.put("STYPE", "etc");
				}else{
					uuid = respository.saveFile(file, respository.getPath());
					fileParam.put("STYPE", "etc");
				}
				
				//fileMap.put(fName, uuid);
				uuidList.add(uuid);
				fileParam.put("UUID", uuid);				
				
		        fileParam.put("MIME", extName);
		        fileParam.put("RPATH", respository.getImageRelative());
				if(uriInfo.getWorkType().equals("image") || fileType.equals("image")){
					fileParam.put("PATH", respository.getImagePath());
					fileParam.put("RPATH", respository.getImageRelative());
					fileName = uuid + "." + extName;
					fileParam.put("FNAME", fileName);
				}else if(uriInfo.getWorkType().equals("avi")){
					fileParam.put("PATH", respository.getAviPath());
					fileParam.put("RPATH", respository.getAviRelative());
					fileName = uuid + "." + extName;
					fileParam.put("FNAME", fileName);
				}else if(uriInfo.getWorkType().equals("excel")){
					fileParam.put("PATH", respository.getExcelPath());
					fileParam.put("RPATH", respository.getEtcRelative());
					fileName = uuid + "." + extName;
					fileParam.put("FNAME", fileName);
				}else{
					fileParam.put("PATH", respository.getPath());
					fileParam.put("RPATH", respository.getEtcRelative());
					fileName = uuid + "." + extName;
					fileParam.put("FNAME", fileName);
				}
				
				//saveNameList.add(fileName);
				
				fileParam.put("NAME", file.getOriginalFilename());				
				fileParam.put("BYTE", String.valueOf(file.getSize()));
				
				fileParam.put("SES_USER_ID", params.getString(CommonConfig.SES_USER_ID_KEY));
				
				commonService.insert(fileParam);
				
				fileInfoList.add(fileParam);
				
				if(uriInfo.getWorkType().equals("image") || fileType.equals("image")){
					String thumbnail = fileRequest.getParameter(CommonConfig.IMAGE_THUMBNAIL_SIZE_KEY);
					if(thumbnail != null){
						try{
							String[] tKeys = thumbnail.split(",");
							DataMap fmap = new DataMap(fileParam);
							fmap.put(CommonConfig.COMMAND_ATT_KEY, CommonConfig.FILE_THUMBNAIL_TABLE_NAME);
							for(int i=0;i<tKeys.length;i++){
								int maxDim = Integer.parseInt(tKeys[i]);
								String tName = uuid+maxDim+"."+extName;
								respository.saveImageThumbnailFile(fileName, tName, maxDim);
								fmap.put("PIXEL", String.valueOf(maxDim));
								fmap.put("FNAME", tName);
								
								commonService.insert(fmap);
							}
							fmap.clear();
						}catch(Exception e){
							log.error("IMAGE_THUMBNAIL_SIZE_KEY",e);
						}						
					}
				}
			}
			params.put(CommonConfig.MODULE_ATT_KEY, CommonConfig.FILE_MODULE);
			params.put(CommonConfig.COMMAND_ATT_KEY, CommonConfig.FILE_TABLE_NAME);
			
			//params.put(CommonConfig.FILE_MAP_KEY, fileMap);
			//params.put(CommonConfig.FILENAMELIST_KEY, saveNameList);
			DataMap fileMap = new DataMap();
			fileMap.put(CommonConfig.FILEINFOLIST_KEY, fileInfoList);
			fileMap.put(CommonConfig.FILEGROUP_KEY, guuid);
			fileMap.put(CommonConfig.FILELIST_KEY, uuidList);
			params.put(CommonConfig.FILE_MAP_KEY, fileMap);
		}
		
		request.setAttribute(CommonConfig.PARAM_ATT_KEY, params);
		
		return super.preHandle(request, response, handler);
	}
}
