package com.mes.controller;

import java.io.FileNotFoundException;
import java.io.IOException;
import java.net.MalformedURLException;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.regex.Pattern;

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
import com.common.bean.User;
import com.common.controller.BaseController;
import com.common.service.CommonService;
import com.common.util.PostRequest;
import com.common.util.ShaUtil;
import com.common.util.SqlUtil;
import com.demo.service.DemoService;
import com.common.bean.DataMap;

@Controller
public class MesController extends BaseController {
	
	private static Logger log = Logger.getLogger(MesController.class);

	
	@Autowired
	private CommonService commonService;
	
	@Autowired
	private DemoService demoService;
	
	@RequestMapping("/mes/index/{page}.*")
	public String index(HttpServletRequest request, Map model, @PathVariable String page) throws SQLException{
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		map.setModuleCommand("Wms", "WAHMACOMBO");
		
		List list = commonService.getList(map);
		
		model.put("WAHMACOMBO", list);
		
		map.setModuleCommand("Common", "COMCOMBO");
		map.put("CODE", "LANGKY");
		
		List list1 = commonService.getList(map);
		
		model.put("LANGKY", list1);
		
		map.setModuleCommand("Common", "LOGINMSG");
		List list2 = commonService.getList(map);
		
		model.put("MSG", list2);
		
		return "/mes/"+page;
	}
	
	
	@RequestMapping("/mes/{page}.*")
	public String page(@PathVariable String page) throws SQLException{
		
		return "/mes/"+page;
	}
	
	@RequestMapping("/mes/{module}/{page}.*")
	public String mpage(@PathVariable String module, @PathVariable String page) throws SQLException{
		
		return "/mes/"+module+"/"+page;
	}
	
	@RequestMapping("/mes/{module}/paging/json/{command}.*")
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
	
	@RequestMapping("/mes/input/json/default.*")
	public String inputdefault(HttpServletRequest request, Map model) throws SQLException{		
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);

		model.put("data", map.get(CommonConfig.RANGE_SQL_KEY));
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/mes/fileUp/file.*")
	public String fileUpDummy(HttpServletRequest request, Map model) throws FileNotFoundException, IOException{		
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);

		List list = map.getList(CommonConfig.FILELIST_KEY);
		
		log.info(map);

		map.put("data", list);
		
		return "/common/fileAjaxUp";
	}
	
	@RequestMapping("/mes/json/range.*")
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
	
	@RequestMapping("/mes/input/json/gridList.*")
	public String gridList(HttpServletRequest request, Map model) throws SQLException, InterruptedException{		
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		map.setModuleCommand("Demo", "GRIDTEST");

		String listData = commonService.getTextList(map);
		
		model.put("data", listData);
		
		return TEXT_VIEW;
	}
	
	@RequestMapping("/mes/input/json/gridListJson.*")
	public String gridListJson(HttpServletRequest request, Map model) throws SQLException, InterruptedException{		
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		map.setModuleCommand("Demo", "GRIDTEST");

		List list = demoService.getList(map);
		
		model.put("data", list);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/mes/input/json/gridSave.*")
	public String gridSave(HttpServletRequest request, @PathVariable String module, @PathVariable String command, Map model) throws SQLException{		
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		map.setModuleCommand(module, command);
		
		DataMap data = demoService.gridSave(map);
		
		model.putAll(data);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/mes/hwls/json/saveDemoItem.*")
    public String saveDemoItem(HttpSession session, HttpServletRequest request, Map model) throws Exception{
    	DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		Object data = demoService.saveDemoItem(session,map);
		
		model.put("data", data);
		
		return JSON_VIEW;
    }
	
	@RequestMapping("/mes/hwls/json/saveFile.*")
    public String saveFile(HttpServletRequest request, Map model) throws Exception{
    	DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		Object data = demoService.saveFile(map);
		
		model.put("data", data);
		
		return JSON_VIEW;
    }
	
	@RequestMapping("/mes/json/loginChk.*")
	public String loginChk(HttpServletRequest request, Map model) throws SQLException{
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		String chkyn = "Y";		
		String userid     = map.get("USERID").toString();
		String newpasswd  = map.get("NEWPASSWD").toString();
		String newpasswd2 = map.get("NEWPASSWD2").toString();
		log.debug("사용자ID값(USERID):"+userid+"/(새 비밀번호 값):"+newpasswd+"/(새 비밀번호 확인값):"+newpasswd2);

				
		map.setModuleCommand("Common", "LOGINCHK");		
		User user = (User)commonService.getObj(map);		
		String oldpasswd = user.getPasswd();
		
		// 0. 기존 비밀번호와 같을 수 없습니다.
		if(oldpasswd.equals(newpasswd)){ 
			chkyn = "N";
			model.put("Msg", "기존 비밀번호와 같을 수 없습니다.");
		}
		
		// 1. 변경 비밀번호 두개가 일치하지 않습니다.1
		if(!newpasswd.equals(newpasswd2)){
			chkyn = "N";
			model.put("Msg", "변경 비밀번호 두개가 일치하지 않습니다.");
		}
		
		// 2. ID와 비밀번호는 같을 수 없습니다2
		if(userid.equals(newpasswd)){
			chkyn = "N";
			model.put("Msg", "ID와 비밀번호는 같을 수 없습니다");
		}
		
		// 3. 자리수 체크3
		if(newpasswd.length() <8 || newpasswd.length() >= 20){
			chkyn = "N";
			model.put("Msg", "자리수 체크 하십시오. 8자리 이상 20자리이하 입니다.");
		}
		
		// 4. 영문자 숫자 패턴 체크 
        // 영문, 숫자, 특수문자 2종 이상 혼용
 		int chk = 0;
		Pattern patt=Pattern.compile("[\\w&&[^_]]+");  //혼용
	    Pattern pnum=Pattern.compile("[\\d]+");  //0-9
	    Pattern pstr=Pattern.compile("[a-zA-Z]+");  //a-zA-Z
	    
	    if(!pnum.matcher(newpasswd).matches())chk ++; 
	    if(!pstr.matcher(newpasswd).matches())chk ++; 
	    if(!patt.matcher(newpasswd).matches())chk ++; 
        if(chk < 2){ 
        	chkyn = "N";
			model.put("Msg", "영문, 숫자, 특수문자 2종 이상 혼용");
        }
        
        // 5. 1234567890 / ABCDEFG 등 연속된 숫자가 4자리 이상이면 안될 것-> 역순 포함 
        if (!commonService.passwd_count(newpasswd)){
        	chkyn = "N";
			model.put("Msg", " 연속된 숫자가 4자리 이상이면 안됩니다.");
        }
		
		if(chkyn == "Y"){
			// SHA 256 - Passwd 암호화 .
			map.put("PASSWD",map.get("PASSWD").toString());
			
			if(user != null && !"V".equals(user.getDelmak()) ){		
				model.put("data", "S");
			}else if( user != null && "V".equals(user.getDelmak())){
				model.put("data","D");
			}else{
				model.put("data", "F");
			}	
		}else{
			model.put("data", "N");
		}
		
		return JSON_VIEW;
	}	
	
	@RequestMapping("/mes/json/updatepassword.*")
	public String updatepassword(HttpServletRequest request, Map model) throws SQLException{
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		String newPwd = map.get("NEWPASSWD").toString();
		String shaNewPasswd ="";
		
		try {
			shaNewPasswd = ShaUtil.toSha256String(newPwd);
			map.put("PASSWD",      shaNewPasswd);	
		} catch (IOException e) {
			e.printStackTrace();
		}
		
		map.setModuleCommand("Common", "PASSWORDNEW");
		int count = commonService.update(map);  
		model.put("data", count);
		
		return JSON_VIEW;
	}
}