package project.mobile.controller;

import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import project.common.airfw.User;
import project.common.bean.CommonConfig;
import project.common.bean.DataMap;
import project.common.controller.BaseController;
import project.common.service.CommonService;
import project.mobile.service.MobileService;

@Controller
public class MobileController extends BaseController {
	
	static final Logger log = LogManager.getLogger(MobileController.class.getName());
	
	@Autowired
	private CommonService commonService;

	@Autowired
	private MobileService mobileService;

	@RequestMapping("/mobile/{page}.*")
	public String page(@PathVariable String page){
		return "/mobile/"+page;
	}

	@RequestMapping("/mobile/{module}/{page}.*")
	public String mpage(@PathVariable String module, @PathVariable String page) throws SQLException{
		return "/mobile/"+module+"/"+page;
	}

	@RequestMapping("/mobile/index.*")
	public String index(HttpServletRequest request, Map model) throws SQLException{
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		map.setModuleCommand("Wms", "WAHMACOMBO");

		List list = commonService.getList(map);

		model.put("WAHMACOMBO", list);

		map.setModuleCommand("airfw", "COMCOMBO");
		map.put("CODE", "LANGKY");

		List list1 = commonService.getList(map);

		model.put("LANGKY", list1);

		map.setModuleCommand("airfw", "LOGINMSG");
		List list2 = commonService.getList(map);
		
		map.clear();
		model.put("MSG", list2);

		return "/mobile/index";
	}

	@RequestMapping("/mobile/plant/list.data")
	public String planList(HttpServletRequest request, Map model) throws SQLException{
		DataMap param = new DataMap();
		param.setModuleCommand("mes", "PLANT");
		List<DataMap> plantList = commonService.getList(param);
		
		param.clear();
		model.put("plantList", plantList);
		return JSON_VIEW;
	}

	@RequestMapping("/mobile/json/logout.*")
	public String logout(HttpServletRequest request, Map model) throws SQLException{
		request.getSession().invalidate();
		return JSON_VIEW;
	}

	@RequestMapping("/mobile/json/login.*")
	public String login(HttpServletRequest request, Map model) throws SQLException{
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		map.setModuleCommand("Common", "LOGIN");

		User user = (User)commonService.getObj(map);


		if(user != null){
			map.setModuleCommand("Common", "USRLO");
			map.put(CommonConfig.SES_USER_ID_KEY, user.getUserid());
			List<DataMap> list = commonService.getList(map);
			DataMap usrlo = new DataMap();
			DataMap row;
			//List data;
			String progid;
			for(int i=0;i<list.size();i++){
				row = list.get(i);
				progid = row.getString("PROGID");
				if(usrlo.containsKey(progid)){
					//data = usrlo.getList(progid);
					//data.add(row);
				}else{
					List newData = new ArrayList();
					newData.add(row);
					usrlo.put(progid, newData);
				}
			}

			user.setUsrlo(usrlo);
			usrlo.clear();
			map.setModuleCommand("Common", "USRPHC");
			list = commonService.getList(map);
			DataMap usrph = new DataMap();
			for(int i=0;i<list.size();i++){
				row = list.get(i);
				progid = row.getString("PROGID");
				if(usrph.containsKey(progid)){
					//data = usrph.getList(progid);
					//data.add(row);
				}else{
					List newData = new ArrayList();
					newData.add(row);
					usrph.put(progid, newData);
				}
			}
			list.clear();
			user.setUsrph(usrph);
			usrph.clear();
			request.getSession().setAttribute(CommonConfig.SES_USER_OBJECT_KEY, user);
			request.getSession().setAttribute(CommonConfig.SES_USER_ID_KEY, user.getUserid());
			request.getSession().setAttribute(CommonConfig.SES_USER_NAME_KEY, user.getNmlast());
			request.getSession().setAttribute(CommonConfig.SES_USER_WHAREHOUSE_KEY, map.getString("WAREKY"));
			request.getSession().setAttribute(CommonConfig.SES_USER_OWNER_KEY, user.getOwner());
			request.getSession().setAttribute(CommonConfig.SES_USER_COMPANY_KEY, user.getCompky());
			request.getSession().setAttribute(CommonConfig.SES_USER_LANGUAGE_KEY, map.getString("LANGKY"));
			request.getSession().setAttribute(CommonConfig.SES_USER_PLANT_KEY, map.getString("PLNTKY"));

			model.put("data", "S");

			log.debug(user);
		}else{
			model.put("data", "F");
		}
		map.clear();
		return JSON_VIEW;
	}

	@RequestMapping("/mobile/main.*")
	public String main(HttpServletRequest request, Map model) throws SQLException{

		String langky = request.getSession().getAttribute(CommonConfig.SES_USER_LANGUAGE_KEY).toString();

		//model.put("label", commonLabel.getLabel(langky));
		//model.put("message", commonLabel.getMessage(langky));

		return "/mobile/main";
	}

	@RequestMapping("/mobile/Mobile/json/usrname.*")
	public String usrname(HttpServletRequest request, Map model) throws SQLException{
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);

		Object data = mobileService.usrname(map);
		map.clear();
		model.put("data", data);

		return JSON_VIEW;
	}

	// 설비호기 선택
	@RequestMapping("/mobile/Mobile/json/selInv.data")
	public String selInv(HttpServletRequest request, Map model) throws SQLException{
		DataMap param = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		request.getSession().setAttribute(CommonConfig.SES_PROC_CD,param.getString("PROC_CD"));
		request.getSession().setAttribute(CommonConfig.SES_MACH_CD,param.getString("MACH_CD"));
		param.clear();
		return JSON_VIEW;
	}

	// 설비기호명 가져오기
	@RequestMapping("/mobile/Mobile/json/gelInvNm.data")
	public String getInvNm(HttpServletRequest request, Map model) throws SQLException{
		DataMap param = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		Object procObj = request.getSession().getAttribute(CommonConfig.SES_PROC_CD);
		Object machObj = request.getSession().getAttribute(CommonConfig.SES_MACH_CD);
		String procNm = "";
		String machNm = "";
		String procCd = "";
		String machCd = "";
		if(procObj!= null) {
			procCd= (String) procObj;
			param.put("PROC_CD", procCd);
			param.setModuleCommand("mes", "PROC");
			DataMap procMap = commonService.getMap(param);
			procNm = procMap.getString("PROC_NM");
			procMap.clear();
		}
		if(machObj!= null) {
			machCd= (String) machObj;
			param.put("MACH_CD", machCd);
			param.setModuleCommand("mes", "MACH");
			DataMap procMap = commonService.getMap(param);
			machNm = procMap.getString("MACH_NM");
			procMap.clear();
		}
		param.clear();
		model.put("procNm",procNm);
		model.put("procCd",procCd);
		model.put("machNm",machNm);
		model.put("machCd",machCd);
		return JSON_VIEW;
	}
	
	//개별바코드별 10초내 중복요청 체크
	@RequestMapping("/mobile/Mobile/json/duplicationCheck.data")
	public String duplicationCheck(HttpServletRequest request, Map model) throws SQLException{
        DataMap map = (DataMap) request.getAttribute(CommonConfig.PARAM_ATT_KEY);
        String indBcd = map.getString("IND_BCD");

		Boolean duplicationCheckResult = mobileService.duplicationCheck(indBcd);
		map.clear();
		model.put("result", duplicationCheckResult);

		return JSON_VIEW;
	}

	//지분검사 실적조회
	@RequestMapping("/mobile/Mobile/json/findJumboResultForInspection.data")
	public String findJumboResultForInspection(HttpServletRequest request, Map model) throws Exception{
        DataMap map = (DataMap) request.getAttribute(CommonConfig.PARAM_ATT_KEY);

		List<DataMap> result = mobileService.findJumboResultForInspection(map);
		model.put("result", result);

		return JSON_VIEW;
	}

	//지분검사 값 입력
	@RequestMapping("/mobile/saveDustInspectionResult.data")
	public String saveDustInspectionResult(HttpServletRequest request, Map model) {
		DataMap map = (DataMap) request.getAttribute(CommonConfig.PARAM_ATT_KEY);

        int insertResult;
        try {
            insertResult = mobileService.saveDustInspectionResult(map);

			if(insertResult> 0){
				model.put("RS_CODE", "S");
				model.put("RS_MSG", "저장 성공");
			} else {
				model.put("RS_CODE", "E");
				model.put("RS_MSG", "저장 실패 - 저장된 데이터가 없습니다.");
			}
        } catch (Exception e) {
			e.printStackTrace(); // 혹은 logger.error("error", e);

			// 3. 에러 정보를 담아서 정상적으로 리턴 (JSON 응답)
			model.put("RS_CODE", "E");
			model.put("RS_MSG", "서버 오류 발생: " + e.getMessage());
        }
		return JSON_VIEW;
	}
}