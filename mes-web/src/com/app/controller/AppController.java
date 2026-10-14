package com.app.controller;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.lang.reflect.InvocationTargetException;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import com.common.bean.CommonConfig;
import com.common.bean.CommonLabel;
import com.common.bean.CommonSearch;
import com.common.bean.CommonUser;
import com.common.bean.DataMap;
import com.common.bean.FileRepository;
import com.common.bean.SystemConfig;
import com.common.bean.TableColumn;
import com.common.bean.User;
import com.common.controller.BaseController;
import com.common.service.CommonService;
import com.common.util.PostRequest;
import com.common.util.SqlUtil;
import com.common.util.Util;

@Controller
public class AppController extends BaseController {
	
	private static Logger log = Logger.getLogger(AppController.class);
	
	@Autowired
	private CommonService commonService;

	@RequestMapping("/app/{module}/{type}/fileUp/{command}.*")
	public String fileUp(HttpServletRequest request, @PathVariable String module, @PathVariable String type, @PathVariable String command, Map model) throws FileNotFoundException, IOException{		
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		map.setModuleCommand(module, command);

		DataMap fileMap = map.getMap(CommonConfig.FILE_MAP_KEY);
		List list = fileMap.getList(CommonConfig.FILELIST_KEY);

		map.put("data", list);
		
		return "/common/fileAjaxUp";
	}

	@RequestMapping("/app/fileGroupUp/file.*")
	public String fileUpGroup(HttpServletRequest request, Map model) throws FileNotFoundException, IOException{		
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);

		DataMap fileMap = map.getMap(CommonConfig.FILE_MAP_KEY);
		String guuid = fileMap.getString(CommonConfig.FILEGROUP_KEY);
		List list = new ArrayList();
		list.add(guuid);
		
		map.put("data", list);
		
		return "/common/fileAjaxUp";
	}
	
	@RequestMapping("/app/image/fileUp/image.*")
	public String fileUpImageDummy(HttpServletRequest request, Map model) throws FileNotFoundException, IOException{		
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);

		DataMap fileMap = map.getMap(CommonConfig.FILE_MAP_KEY);
		List list = fileMap.getList(CommonConfig.FILELIST_KEY);

		map.put("data", list);
		
		return "/common/fileAjaxUp";
	}
	
	@RequestMapping("/app/image/fileGroupUp/image.*")
	public String fileGroupUpImageDummy(HttpServletRequest request, Map model) throws FileNotFoundException, IOException{		
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);

		DataMap fileMap = map.getMap(CommonConfig.FILE_MAP_KEY);
		String guuid = fileMap.getString(CommonConfig.FILEGROUP_KEY);
		List list = new ArrayList();
		list.add(guuid);

		map.put("data", list);
		
		return "/common/fileAjaxUp";
	}
	
	@RequestMapping("/app/image/fileUp/json.*")
	public String fileUpJsonImageDummy(HttpServletRequest request, Map model) throws FileNotFoundException, IOException{		
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);

		DataMap fileMap = map.getMap(CommonConfig.FILE_MAP_KEY);
	List list = fileMap.getList(CommonConfig.FILELIST_KEY);

		model.put("data", list);
		
		return JSON_VIEW;
	}
}