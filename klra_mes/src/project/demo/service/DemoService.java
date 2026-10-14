package project.demo.service;

import java.util.List;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import project.common.bean.CommonConfig;
import project.common.bean.DataMap;
import project.common.dao.CommonDAO;
import project.common.util.FileUtil;

@Service("demoService")
public class DemoService{
	
	static final Logger log = LogManager.getLogger(DemoService.class.getName());
	
	@Autowired
	public CommonDAO commonDao;
	
	@Transactional(rollbackFor = Exception.class)
	public int saveSingleFileDemo(DataMap map) throws Exception {
		int count = 0;
		try {
			log.debug(map);
			DataMap fileMap = map.getMap(CommonConfig.FILE_MAP_KEY);
			List<DataMap> fileInfoList = fileMap.getList(CommonConfig.FILEINFOLIST_KEY);
			int fileInfoListSize = fileInfoList.size();
			if(fileInfoListSize > 0){
				DataMap row = fileInfoList.get(0).getMap("map");
				row.put("ATTACH", row.getString("UUID"));
				row.put("SHORTX", "Single File Upload");
				row.setModuleCommand("Demo", "SYSFILEDEMO");
				commonDao.insert(row);
				count++;
				row.clear();
			}
			fileInfoList.clear();
			fileMap.clear();
		} catch (Exception e) {
			throw new Exception(e.getMessage());
		}
		return count;
	}
	
	@Transactional
	public int saveSysFileDemo(DataMap map) throws Exception {
		int count = 0;
		
		List<DataMap> list = map.getList("list");
		int listSize = list.size();
		try {
			if(listSize > 0){
				for (int i = 0; i < listSize; i++) {
					DataMap row = list.get(i).getMap("map");
					map.clonSessionData(row);
					row.setModuleCommand("Demo", "SYSFILEDEMO");
					
					String uuid = row.getString("UUID");
					String attach = row.getString("ATTACH");
					
					String gRowStatus = row.getString(CommonConfig.GRID_ROW_STATE_ATT);
					switch (gRowStatus) {
					case "C":
						commonDao.insert(row);
						break;
					case "U":
						commonDao.update(row);
						
						if(!"".equals(uuid)){
							String path = row.getString("PATH");
							String name = row.getString("FNAME");
							if(!"".equals(path) && !"".equals(name) && !uuid.equals(attach)){
								FileUtil fileUtil = new FileUtil();
								
								boolean result = fileUtil.deleteFile(path, name);
								if(result){
									DataMap sysFileMap = new DataMap();
									sysFileMap.put("UUID", uuid);
									sysFileMap.setModuleCommand("System", "SYSFILE");
									
									commonDao.delete(sysFileMap);
								}
								log.debug("Origin File Delete[ "+ row.get("SEQ") +" ] :: " + (result?"success":"false"));
							}
						}
						break;
					case "D":
						commonDao.delete(row);
						
						String path = row.getString("PATH");
						String name = row.getString("FNAME");
						if(!"".equals(path) && !"".equals(name)){
							FileUtil fileUtil = new FileUtil();
							
							boolean result = fileUtil.deleteFile(path, name);
							if(result){
								DataMap sysFileMap = new DataMap();
								sysFileMap.put("UUID", uuid);
								sysFileMap.setModuleCommand("System", "SYSFILE");
								
								commonDao.delete(sysFileMap);
								sysFileMap.clear();
							}
							log.debug("File Delete[ "+ row.get("SEQ") +" ] :: " + (result?"success":"false"));
						}else{
							log.debug("No File Delete[ "+ row.get("SEQ") +" ]");
						}
						break;	
					default:
						break;
					}
					row.clear();
					count++;
				}
			}
		} catch (Exception e) {
			throw new Exception(e.getMessage());
		}
		list.clear();
		return count;
	}
}