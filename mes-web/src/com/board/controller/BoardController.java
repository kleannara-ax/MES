package com.board.controller;

import java.sql.SQLException;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.util.CookieGenerator;

import com.board.bean.CommonBoard;
import com.board.service.BoardService;
import com.common.bean.CommonConfig;
import com.common.bean.DataMap;
import com.common.controller.BaseController;
import com.common.service.CommonService;

@Controller
public class BoardController extends BaseController {
	
	private static Logger log = Logger.getLogger(BoardController.class);
	
	@Autowired
	private CommonService commonService;
	
	@Autowired
	private BoardService boardService;
	
	@Autowired
	private CommonBoard commonBoard;
	
	@RequestMapping("/board/{page}.*")
	public String page(@PathVariable String page, HttpServletRequest request, Map model) throws SQLException{
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		DataMap data = commonBoard.getBoard(map.getString("ID"));
		model.put("SQL_ID", data.getString("SQL_ID"));
		
		return "/board/"+page;
	}
	
	@RequestMapping("/board/{module}/{page}.*")
	public String mpage(@PathVariable String module, @PathVariable String page, HttpServletRequest request, Map model) throws SQLException{
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		DataMap data = commonBoard.getBoard(map.getString("ID"));
		model.put("SQL_ID", data.getString("SQL_ID"));
		
		return "/board/"+module+"/"+page;
	}
	
	@RequestMapping("/board/boardtmp.*")
	public String boardtmp(HttpServletRequest request, HttpServletResponse response, Map model) throws SQLException{
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		map.setModuleCommand("Board", "FWBDMA0010");
		
		DataMap data = commonService.getMap(map);
		String page = data.getString("TEMP_PATH")+"_"+map.getString("TYPE","list");
		
		model.put("TEMP_PATH", data.getString("TEMP_PATH"));
		model.put("ID", data.getString("ID"));
		
		if(map.getString("TYPE").equals("view")){
			map.setModuleCommand("Board", "FWBDCM0010");
			data = commonService.getMap(map);
			
			map.setModuleCommand("Board", "FWBDCM0013");
			List fileList = commonService.getList(map);
			data.put("fileList", fileList);
			
			model.put("data", data);
			
			DataMap cmap = new DataMap();
			cmap.setCookies(request);
			String viewCookieKey = "boardView-"+map.getString("CONTENT_ID");
			
			if(!cmap.containsKey(viewCookieKey)){
				CookieGenerator cg = new CookieGenerator();
				cg.setCookieName(viewCookieKey);
				cg.setCookieMaxAge(60*60*24*365);
				cg.addCookie(response, "view");
				
				map.setModuleCommand("Board", "FWBDCM0010V");
				int rs = commonService.update(map);
			}
		}else if(map.getString("TYPE").equals("edit")){
			map.setModuleCommand("Board", "FWBDCM0010");
			data = commonService.getMap(map);
			
			map.setModuleCommand("Board", "FWBDCM0013");
			List fileList = commonService.getList(map);
			data.put("fileList", fileList);
			
			map.setModuleCommand("Board", "FWBDCM0010C");
			
			DataMap content = commonService.getMap(map);
			
			data.put("CONTENT", content.getString("CONTENT"));
			
			model.put("data", data);
		}else if(map.getString("TYPE").equals("rewrite")){
			map.setModuleCommand("Board", "FWBDCM0010");
			data = commonService.getMap(map);
			
			map.setModuleCommand("Board", "FWBDCM0010C");
			
			DataMap content = commonService.getMap(map);
			
			data.put("CONTENT", content.getString("CONTENT"));
			
			model.put("data", data);
		}

		return page;
	}
	
	@RequestMapping("/board/boardContent.*")
	public String boardContent(HttpServletRequest request, Map model) throws SQLException{
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		map.setModuleCommand("Board", "FWBDCM0010C");
		
		DataMap data = commonService.getMap(map);
		
		model.put("CONTENT", data.getString("CONTENT"));

		return "/board/content";
	}
	
	@RequestMapping("/board/admin.*")
	public String admin() throws SQLException{
		
		return "/board/admin/admin";
	}
	
	@RequestMapping("/board/fileUp/boardContentInsert.*")
	public String boardContentInsert(HttpServletRequest request, Map model) throws SQLException{		
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);		
		
		int rs = boardService.boardContentInsert(map);
		
		map.put("data", rs);

		return "/common/fileAjaxUp";
	}
	
	@RequestMapping("/board/fileUp/boardContentUpdate.*")
	public String boardContentUpdate(HttpServletRequest request) throws SQLException{		
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		int rs = boardService.boardContentUpdate(map);
		
		map.put("data", rs);
		
		return "/common/fileAjaxUp";
	}
	
	@RequestMapping("/board/count/json/content.*")
	public String countContent(HttpServletRequest request, Map model) throws SQLException{		
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		map.setModuleCommand("Board", "FWBDCM0010P");

		int count = commonService.getCount(map);
		
		model.put("data", count);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/board/json/boardContentDelete.*")
	public String boardContentDelete(HttpServletRequest request, Map model) throws SQLException{		
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		int rs = boardService.boardContentDelete(map);
		
		model.put("data", rs);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/board/fileUp/boardContentRewrite.*")
	public String boardContentRewrite(HttpServletRequest request) throws SQLException{		
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);		
		
		int rs = boardService.boardContentRewrite(map);
		
		map.put("data", rs);
		
		return "/common/fileAjaxUp";
	}
}