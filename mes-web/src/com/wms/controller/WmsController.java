package com.wms.controller;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;
import java.util.Map;
import java.util.regex.Pattern;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;

import com.common.bean.CommonConfig;
import com.common.bean.CommonLabel;
import com.common.bean.DataMap;
import com.common.bean.UriInfo;
import com.common.bean.User;
import com.common.controller.BaseController;
import com.common.service.CommonService;
import com.common.util.ShaUtil;
import com.common.bean.DataMap;

@Controller
public class WmsController extends BaseController {
	
	private static Logger log = Logger.getLogger(WmsController.class);

	@Autowired
	private CommonLabel commonLabel;	
	
	@Autowired
	private CommonService commonService;
	
	@RequestMapping("/wms/index/{page}.*")
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
		
		return "/wms/"+page;
	}

	@RequestMapping("/wms/common/json/leftMenu.*")
	public String leftMenu(HttpServletRequest request, Map model) throws SQLException{
		String langky = request.getSession().getAttribute(CommonConfig.SES_USER_LANGUAGE_KEY).toString();
		String userid = request.getSession().getAttribute(CommonConfig.SES_USER_ID_KEY).toString();
		
		DataMap map = new DataMap("Common", "MENUTREE");
		map.put("LANGKY", langky);
		map.put("USERID", userid);
		
		List<DataMap> list = commonService.getList(map);
		
		model.put("list", list);
		
		return "/wms/left";
	}
	
	@RequestMapping("/wms/{page}.*")
	public String page(@PathVariable String page) throws SQLException{
		
		return "/wms/"+page;
	}
	
	@RequestMapping("/wms/{module}/{page}.*")
	public String mpage(@PathVariable String module, @PathVariable String page) throws SQLException{
		
		return "/wms/"+module+"/"+page;
	}
	
	@RequestMapping("/wms/common/json/getDocSeq.*")
	public String getDocSeq(HttpServletRequest request, Map model) throws SQLException{				
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		map.setModuleCommand("Common", "DOCUSEQ");
		
		Object docseq = commonService.insert(map);
		
		model.put("DOCNO", docseq);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/wms/common/json/changeWareky.*")
	public String login(HttpServletRequest request, Map model) throws SQLException{
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		map.setModuleCommand("Wms", "OWNER");
		
		DataMap data = (DataMap)commonService.getMap(map);
		
		if(data.containsKey("OWNER")){
			User user = (User)request.getSession().getAttribute(CommonConfig.SES_USER_OBJECT_KEY);
			user.setOwner(data.getString("OWNER"));
			request.getSession().setAttribute(CommonConfig.SES_USER_WHAREHOUSE_KEY, map.getString("WAREKY"));
			request.getSession().setAttribute(CommonConfig.SES_USER_OWNER_KEY, user.getOwner());
			
			model.put("data", "S");
		}else{
			model.put("data", "F");
		}	
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/wms/common/common_ezprint.*")
	public String ezpage(HttpServletRequest request, Map model) throws SQLException{
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		UriInfo uriInfo = (UriInfo)request.getAttribute(CommonConfig.REQUEST_URI_INFO_KEY);
		model.put("filename", map.get("filename"));
		model.put("andvalue", map.get("andvalue"));
		model.put("width", map.get("width"));
		model.put("height", map.get("height"));
		model.put("url", uriInfo.getUrl());
		return "/wms/common/common_ezprint";
	}
	
	@RequestMapping("/wms/common/userinfo.*")
	public String userInfo(HttpSession session, HttpServletRequest request, Map model) throws SQLException{
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		
		Object obj = session.getAttribute(CommonConfig.SES_USER_INFO_KEY);
		DataMap data = null;
		
		if(obj != null){
			data = (DataMap)obj;
		}
		
		model.put("data", data);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/wms/json/loginChk.*")
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
	
	@RequestMapping("/wms/json/updatepassword.*")
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