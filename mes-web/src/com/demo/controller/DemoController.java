package com.demo.controller;

import java.io.FileNotFoundException;
import java.io.IOException;
import java.net.MalformedURLException;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;
import java.util.Locale;
import java.util.Map;

import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.util.CookieGenerator;

import com.board.service.BoardService;
import com.common.bean.CommonConfig;
import com.common.bean.DataMap;
import com.common.controller.BaseController;
import com.common.service.CommonService;
import com.common.util.PostRequest;
import com.common.util.SqlUtil;
import com.demo.service.DemoService;
import com.common.bean.DataMap;

@Controller
public class DemoController extends BaseController {
	
	private static Logger log = Logger.getLogger(DemoController.class);

	
	@Autowired
	private CommonService commonService;
	
	@Autowired
	private DemoService demoService;
	
	
	@RequestMapping("/demo/{page}.*")
	public String page(@PathVariable String page) throws SQLException{
		
		return "/demo/"+page;
	}
	
	@RequestMapping("/demo/{module}/{page}.*")
	public String mpage(@PathVariable String module, @PathVariable String page) throws SQLException{
		
		return "/demo/"+module+"/"+page;
	}
	
	@RequestMapping("/demo/{module}/paging/json/{command}.*")
	public String paging(HttpServletRequest request, @PathVariable String module, @PathVariable String command, Map model) throws SQLException{		
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		map.setModuleCommand(module, command);
		
		if(map.getString(CommonConfig.LIST_PAGE_REQUEST_TYPE_KEY).equals("paging")){
			List list = commonService.getPagingList(map);
			
			model.put("data", list);
		}else{
			int count = commonService.getCount(map);
			
			model.put("data", count);
		}		
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/demo/input/json/default.*")
	public String inputdefault(HttpServletRequest request, Map model) throws SQLException{		
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);

		model.put("data", map.get(CommonConfig.RANGE_SQL_KEY));
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/demo/fileUp/file.*")
	public String fileUpDummy(HttpServletRequest request, Map model) throws FileNotFoundException, IOException{		
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);

		List list = map.getList(CommonConfig.FILELIST_KEY);
		
		log.info(map);

		map.put("data", list);
		
		return "/common/fileAjaxUp";
	}
	
	@RequestMapping("/demo/json/range.*")
	public String range(HttpServletRequest request, Map model) throws FileNotFoundException, IOException{		
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);

		DataMap rangeMap = map.getMap(CommonConfig.RNAGE_DATA_MAP);
		
		SqlUtil sqlUtil = new SqlUtil();
		
		String rSql1 = sqlUtil.getRangeSql(rangeMap);
		map.put("RANGE_SQL_1", rSql1);
		
		sqlUtil.removeRangeKey(rangeMap, "AI.SMBLNR");             // 자재문서번호
		sqlUtil.changeRangeKey(rangeMap, "AI.SKUKEY", "SKUKEY");   // 자재코드
		sqlUtil.changeRangeKey(rangeMap, "AI.LOTA05", "LOTA05");   // 검사LOT번호
		String rSql2 = sqlUtil.getRangeSql(rangeMap);
		map.put("RANGE_SQL_2", rSql2);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/demo/input/json/gridList.*")
	public String gridList(HttpServletRequest request, Map model) throws SQLException, InterruptedException{		
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		map.setModuleCommand("Demo", "GRIDTEST");

		String listData = commonService.getTextList(map);
		
		model.put("data", listData);
		
		return TEXT_VIEW;
	}
	
	@RequestMapping("/demo/input/json/gridListJson.*")
	public String gridListJson(HttpServletRequest request, Map model) throws SQLException, InterruptedException{		
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		map.setModuleCommand("Demo", "GRIDTEST");

		List list = demoService.getList(map);
		
		model.put("data", list);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/demo/input/json/gridSave.*")
	public String gridSave(HttpServletRequest request, @PathVariable String module, @PathVariable String command, Map model) throws SQLException{		
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		map.setModuleCommand(module, command);
		
		DataMap data = demoService.gridSave(map);
		
		model.putAll(data);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/api/json/master.*")
	public String api_master(Map model) throws MalformedURLException{
		
		log.info("ApiScheduled.apiMaster");
		SimpleDateFormat dfDate = new SimpleDateFormat("yyyyMMddHHmmss", Locale.KOREAN);
		Date currentTime = new Date();
		String mTime = dfDate.format(currentTime);
		
		PostRequest post = new PostRequest("UTF-8");
		//String url = API_URL+"/gateway/koLoadInfo/v1/load_info/"+mTime;
		//String url = "https://gateway.openapi.t-money.co.kr:5556/gateway/koLoadInfo/v1/load_info/"+mTime;
		String url = "https://devgateway.openapi.t-money.co.kr:5556/gateway/koLoadInfo/v1/load_info/"+mTime;
		DataMap data = post.jsonGet(url);
		
		model.put("data", data);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/api/json/ibt.*")
	public String api_ibt(Map model) throws MalformedURLException{
		
		log.info("ApiScheduled.apiMaster");
		SimpleDateFormat dfDate = new SimpleDateFormat("yyyyMMddHHmmss", Locale.KOREAN);
		Date currentTime = new Date();
		String mTime = dfDate.format(currentTime);
		
		PostRequest post = new PostRequest("UTF-8");
		//String url = API_URL+"/gateway/koLoadInfo/v1/load_info/"+mTime;
		//String url = "https://gateway.openapi.t-money.co.kr:5556/gateway/koLoadInfo/v1/load_info/"+mTime;
		String url = "https://devgateway.openapi.t-money.co.kr:5556/gateway/koIbtList/v1/ibt_list/20190219/0000/010/700/0/0/9";
		
		DataMap data = post.jsonGet(url);
		
		model.put("data", data);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/api/json/ibtinfo.*")
	public String api_ibtinfo(Map model) throws MalformedURLException{
		
		log.info("ApiScheduled.apiMaster");
		SimpleDateFormat dfDate = new SimpleDateFormat("yyyyMMddHHmmss", Locale.KOREAN);
		Date currentTime = new Date();
		String mTime = dfDate.format(currentTime);
		
		PostRequest post = new PostRequest("UTF-8");
		//String url = API_URL+"/gateway/koLoadInfo/v1/load_info/"+mTime;
		//String url = "https://gateway.openapi.t-money.co.kr:5556/gateway/koLoadInfo/v1/load_info/"+mTime;
		String url = "https://devgateway.openapi.t-money.co.kr:5556/gateway/koMyArrList/v1/my_arr_list/20190219/000000/010/700/02";
		DataMap data = post.jsonGet(url);
		
		model.put("data", data);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/api/json/arr.*")
	public String api_arr(Map model) throws MalformedURLException{
		
		log.info("ApiScheduled.apiMaster");
		SimpleDateFormat dfDate = new SimpleDateFormat("yyyyMMddHHmmss", Locale.KOREAN);
		Date currentTime = new Date();
		String mTime = dfDate.format(currentTime);
		
		PostRequest post = new PostRequest("UTF-8");
		//String url = API_URL+"/gateway/koLoadInfo/v1/load_info/"+mTime;
		//String url = "https://gateway.openapi.t-money.co.kr:5556/gateway/koLoadInfo/v1/load_info/"+mTime;
		String url = "https://devgateway.openapi.t-money.co.kr:5556/gateway/koArrList/v1/arr_list/700";
		DataMap data = post.jsonGet(url);
		
		model.put("data", data);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/demo/hwls/json/saveDemoItem.*")
    public String saveDemoItem(HttpSession session, HttpServletRequest request, Map model) throws Exception{
    	DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		Object data = demoService.saveDemoItem(session,map);
		
		model.put("data", data);
		
		return JSON_VIEW;
    }
	
	@RequestMapping("/demo/hwls/json/saveFile.*")
    public String saveFile(HttpServletRequest request, Map model) throws Exception{
    	DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		Object data = demoService.saveFile(map);
		
		model.put("data", data);
		
		return JSON_VIEW;
    }
}