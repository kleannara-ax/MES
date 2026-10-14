package project.mes.controller;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.apache.commons.lang3.StringUtils;
import org.apache.log4j.Logger;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.RequestMapping;
import project.common.bean.CommonConfig;
import project.common.bean.DataMap;
import project.common.controller.BaseController;
import project.common.service.CommonService;
import project.mes.bean.DataMesMap;
import project.mes.service.SsoGwService;
import project.mes.util.CommonUtil;

import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.net.HttpURLConnection;
import java.net.URL;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller("/")
public class SsoGwController extends BaseController {

    private static Logger log = Logger.getLogger(SsoGwController.class);

    @Autowired
    SsoGwService ssoGwService;

    @Autowired
    private CommonService commonService;

    /**
     * 통합결제 싱크 후처리
     *
     * @return getString
     *      apprState
     * -	0 : 작성중/임시저장/결재회수
     * -	1 : 결재요청(결재진행중)
     * -	2 : 결재완료(승인)
     * -	3 : 결재반려
     * bodyContents : {"formCd":"RULE01","apprState":"3","appKey01":"1319xx"
     * ,"appKey02":"","appKey03":"","appKey04":"","appKey05":""
     * ,"apprDocNo":"O2O영업팀202107-xxxx","apprId":"1321xxx"}
     */
    @RequestMapping(value = "/sso/approvalSync")
    public String approvalSync(HttpServletRequest request,Map model) throws IOException {

        String body = CommonUtil.getRequestBody(request);

        Map result = new HashMap();
        try {
            result.put("returnCode",0);
            result.put("returnDesc","OK");
            model.put("head", result);
            if(StringUtils.isEmpty(body)) {
                ssoGwService.insertLog("body null");
                return JSON_VIEW;
            }
            ssoGwService.insertLog("url:/sso/approvalSync start");
            ssoGwService.insertLog(body);
            ssoGwService.insertLog("url:/sso/approvalSync end");
//            Object obj = (Map)params.get("bodyContents");
            ObjectMapper mapper = new ObjectMapper();
            Map<String, Object> param = mapper.readValue(body, Map.class);
            if(param == null) {
                // TODO: err
                ssoGwService.insertLog("1. param null");
                return JSON_VIEW;
            }
//            Map<String,Object> param = (Map)obj;
            //현재는 user_id , sso 연동되고 나면 spro_id
            /* 프로세스별 처리 Start **********************************/

//            if (reqParam.isMissingNode() || reqParam.isNull()) {
//                throw new ApplicationException("요청 결과가 없습니다.");
//            }

            ssoGwService.insertLog("2. param ...");
            String formCd = CommonUtil.getMap(param,"formCd","");
            String appKey01 = CommonUtil.getMap(param,"appKey01",""); // DOC_ID
            String appKey02 = CommonUtil.getMap(param,"appKey02","");
            String appKey03 = CommonUtil.getMap(param,"appKey03","");
            String appKey04 = CommonUtil.getMap(param,"appKey04","");
            String appKey05 = CommonUtil.getMap(param,"appKey05","");
            String apprDocNo = CommonUtil.getMap(param,"apprDocNo","");
            String apprId = CommonUtil.getMap(param,"apprId","");
            String apprState = CommonUtil.getMap(param,"apprState","");
            //사후처리 전송시점   - (결재상태 필드 추가 : appr_status   (0 : 작성  1: 결재요청, 2:완료(승인), 3: 반려)


//            DataMap dm =new DataMap();
//            dm.setModuleCommand("mes", "GWAPPV");
//            dm.put("apprId", apprId);
//            dm.put("state", apprState);

            ssoGwService.insertLog("3. param ...");
            //결재정보 업데이트 정보 설정
            if("MES001".equals(formCd)) { // 성적검사서
                DataMap  apprParam = new DataMap();
                apprParam.setModuleCommand("mes", "MES001STA");
                apprParam.put("DOC_ID", appKey01);
                apprParam.put("APVR_STA", apprState);
                commonService.update(apprParam);
                ssoGwService.insertLog("결제처리");
            }
            else if("MES003".equals(formCd)) { // 페품
                DataMap  apprParam = new DataMap();
                apprParam.setModuleCommand("mes", "MES003STA");
                apprParam.put("DOC_ID", appKey01);
                apprParam.put("APVR_STA", apprState);
                commonService.update(apprParam);
                
                if("3".equals(apprState)) { //반려
                    DataMesMap updMap = new DataMesMap();
                    updMap.put("DOC_ID", appKey01);
                    updMap.setModuleCommand("mes", "MES001LIST");
                    List<DataMap> list = commonService.getList(updMap);
                    list = CommonUtil.converPageDataList(list);
                    if(list.size() > 0) {
                        updMap.put("P_TYPE", "SAVE1");
                        updMap.put("list", list);
                        updMap.setModuleCommand("Work", "WRK08");
                        String jsonStr = CommonUtil.mapToJson(updMap);
                        updMap.put("P_JSON_STR", jsonStr);
                        commonService.getMap(updMap);
                    }
                }
            }
        } catch (Exception e) {
            ssoGwService.insertLog("9. error ..."+e.getMessage());
            e.printStackTrace();
        }
        finally {
            ssoGwService.insertLog("10. final ...");
            return JSON_VIEW;
        }

    }


    /**
     * ssoLogin
     *
     * @return String
     * @throws Exception
     */
    @RequestMapping(value = "/sso/assertionConsumer")
    public String ssoLogin(HttpSession session, HttpServletRequest request, HttpServletResponse response, ModelMap model) throws Exception {

        String rtnUrl = "common/error";

        // 상품(메뉴)별 인증요청 URL
//        String strUrl = "https://mesdev.kleannara.com/rest/security/encValidateProduct";
        String strUrl = CommonConfig.getSSO_SITE()+"/rest/security/encValidateProduct";

        // json message 구성
        String productId = CommonConfig.SSO_PRODUCT_ID; //MES 상품코드
        String encData = "";

        Cookie[] cookies = request.getCookies();
        if (cookies != null) {
            for (int i = 0; i < cookies.length; i++) {
                if (cookies[i].getName().equals("encData")) {
                    encData = cookies[i].getValue();
                }
            }
        }

        if (cookies == null || productId.length() == 0 || encData.length() == 0) {
            rtnUrl = "/sso/ssoLogin"; //일반 로그인 화면
        } else {

            String jsonMessage = "{";
            jsonMessage += "\"productId\":\"" + productId + "\"";
            jsonMessage += ",\"encData\":\"" + encData + "\"";
            jsonMessage += "}";

//            String jsonMessage =  "{\n" +
//                    "  \"sproId\": \"hnw.shyou\",\n" +
//                    "  \"password\": \"hnw.shyou"+request.getServerName()+productId+"\",\n" +
//                    "  \"loginIp\": \""+request.getServerName()+"\",\n" +
//                    "  \"productId\": \""+productId+"\",\n" +
//                    "  \"productName\": \"확장문서함\",\n" +
//                    "\"application\": \""+productId+"-"+request.getServerName()+"\",\n" +
//                    "\"useEncData\" : \"true\"\n" +
//                    "}";

            try {
                URL url = new URL(strUrl);
                HttpURLConnection con = (HttpURLConnection) url.openConnection();
                con.setConnectTimeout(5000); //서버에 연결되는 Timeout 시간 설정
                con.setReadTimeout(5000); // InputStream 읽어 오는 Timeout 시간 설정

                con.setRequestMethod("POST");

                //json으로 message를 전달하고자 할 때
                con.setRequestProperty("Content-Type", "application/json");
                con.setDoInput(true);
                con.setDoOutput(true); //POST 데이터를 OutputStream으로 넘겨 주겠다는 설정
                con.setUseCaches(false);
                con.setDefaultUseCaches(false);

                OutputStreamWriter wr = new OutputStreamWriter(con.getOutputStream());
                wr.write(jsonMessage); //json 형식의 message 전달
                wr.flush();

                StringBuilder sb = new StringBuilder();
                if (con.getResponseCode() == HttpURLConnection.HTTP_OK) {

                    //Stream을 처리해줘야 하는 귀찮음이 있음.
                    BufferedReader br = new BufferedReader(
                            new InputStreamReader(con.getInputStream(), "utf-8"));
                    String line;
                    while ((line = br.readLine()) != null) {
                        sb.append(line).append("\n");
                    }
                    br.close();

                    String returnJson = sb.toString();

                    // returnJson parsing
                    JSONObject jsonObj = new JSONObject(returnJson);

                    JSONObject jsonHead = new JSONObject(jsonObj.get("head").toString());
                    String returnCode = String.valueOf(jsonHead.get("returnCode"));
                    String returnDesc = String.valueOf(jsonHead.get("returnDesc"));
                    String sproId = "";
                    JSONObject jsonBody = new JSONObject(jsonObj.get("body").toString());
                    ssoGwService.insertLog("aaaaaaa sss");
                    ssoGwService.insertLog(returnCode);
                    ssoGwService.insertLog(jsonBody.toString());
                    ssoGwService.insertLog("aaaaaaa eee");
                    if (returnCode.equals("0")) {
                        sproId = String.valueOf(jsonBody.get("sproId"));
                        boolean isOk = ssoGwService.ssoLogin(sproId, request, model);
                        ssoGwService.insertLog(isOk?"true":"false");
                        rtnUrl = "redirect:/main.page";
                        if (!isOk) {
                            model.addAttribute("sproId", String.valueOf(jsonBody.get("sproId")));
                            model.addAttribute("isTrySso", "Y");
                            rtnUrl = "forward:/mes/index.page";
                        }
                        ssoGwService.insertLog(rtnUrl);
                    } else {
                        model.addAttribute("sproId", String.valueOf(jsonBody.get("sproId")));
                        model.addAttribute("isTrySso", "Y");
                        rtnUrl = "forward:/mes/index.page";
                    }
                } else {
                    System.out.println(con.getResponseCode());
                    rtnUrl = "redirect:/sso/ssoLogin.page";
                }
            } catch (Exception e) {
                System.err.println(e.getMessage());
            }
        }
        return rtnUrl;
    }

    // gw login 여부
    @RequestMapping("/mes/gw/login/json/data.data")
    public String isGwLogin(HttpServletRequest request,Map model) throws SQLException, JsonProcessingException {
        DataMesMap map = CommonUtil.convertAll((DataMap) request.getAttribute(CommonConfig.PARAM_ATT_KEY));
//      상품(메뉴)별 인증요청 URL
//        String strUrl = "https://sso.kleannara.com/rest/security/encValidateProduct";
        String strUrl = CommonConfig.getSSO_SITE()+"/rest/security/encValidateProduct";

        // json message 구성
        String productId = CommonConfig.SSO_PRODUCT_ID; //MES 상품코드
        String encData = map.getString("encData");


        String jsonMessage = "{";
        jsonMessage += "\"productId\":\"" + productId + "\"";
        jsonMessage += ",\"encData\":\"" + encData + "\"";
        jsonMessage += "}";

        try {
            URL url = new URL(strUrl);
            HttpURLConnection con = (HttpURLConnection) url.openConnection();
            con.setConnectTimeout(5000); //서버에 연결되는 Timeout 시간 설정
            con.setReadTimeout(5000); // InputStream 읽어 오는 Timeout 시간 설정

            con.setRequestMethod("POST");

            //json으로 message를 전달하고자 할 때
            con.setRequestProperty("Content-Type", "application/json");
            con.setDoInput(true);
            con.setDoOutput(true); //POST 데이터를 OutputStream으로 넘겨 주겠다는 설정
            con.setUseCaches(false);
            con.setDefaultUseCaches(false);

            OutputStreamWriter wr = new OutputStreamWriter(con.getOutputStream());
            wr.write(jsonMessage); //json 형식의 message 전달
            wr.flush();

            String message = "";
            StringBuilder sb = new StringBuilder();
            if (con.getResponseCode() == HttpURLConnection.HTTP_OK) {

                //Stream을 처리해줘야 하는 귀찮음이 있음.
                BufferedReader br = new BufferedReader(
                        new InputStreamReader(con.getInputStream(), "utf-8"));
                String line;
                while ((line = br.readLine()) != null) {
                    sb.append(line).append("\n");
                }
                br.close();

                String returnJson = sb.toString();

                // returnJson parsing
                JSONObject jsonObj = new JSONObject(returnJson);

                JSONObject jsonHead = new JSONObject(jsonObj.get("head").toString());
                String returnCode = String.valueOf(jsonHead.get("returnCode"));
//                    String returnDesc = String.valueOf(jsonHead.get("returnDesc"));
//                    String sproId = "";
//                    if(jsonObj.get("body")!=null) {
//                        String bodyString = jsonObj.get("body").toString();
//                        JSONObject jsonBody = new JSONObject();
//                        ssoGwService.insertLog("aaaaaaa sss");
//                        ssoGwService.insertLog(returnCode);
//                        ssoGwService.insertLog(jsonBody.toString());
//                        ssoGwService.insertLog("aaaaaaa eee");
//                    }
                if (returnCode.equals("0")) {
                    model.put("login","Y");
                } else {
                    switch (returnCode) {
                        case "1": message = "SSO 통신 필수항목 값이 누락되었습니다.";
                        case "2": message = "SSO 사용자 정보가 맞지 않습니다.";
                        case "3": message = "SSO 인증키가 맞지 않습니다.";
                        case "4": message = "SSO복호화 실패 했습니다.";
                        case "5": message = "상품(메뉴) 권한이 없거나 맞지 않습니다.";
                        case "6": message = "사용자 IP가 맞지 않습니다.";
                        case "7": message = "사용 브라우저 정보가 맞지 않습니다.";
                        case "99": message = "SSO인증시 기타 오류가 발생했습니다.";
                    }
                    model.put("message", message);
                    model.put("login","N");
                }
            } else {
                model.put("message", "SSO 서버 연결 되지 않습니다. 관리자에게 문의하세요.");
                model.put("login","N");
            }
        } catch (Exception e) {
            model.put("message", e.getMessage());
            model.put("login","N");
            System.err.println(e.getMessage());
        }
        return JSON_VIEW;
    }

    // legacy -> SSO 로그인 전달요청
    @RequestMapping("/sso/ssoLoginProduct.page")
    public String ssoLoginProduct(HttpServletRequest request) {
        return "/sso/ssoLoginProduct";
    }

    // legacy -> SSO 로그인 요청
    @RequestMapping("/sso/ssoLogin.page")
    public String ssoLogin(HttpServletRequest request) {
        return "/sso/ssoLogin";
    }

    // sso -> legacy 로그아웃 요청
    @RequestMapping("/sso/ssoLogout.page")
    public String ssoLogout(HttpServletRequest request) {
        // return "/sso/ssoLogout";
//        return "redirect:/mes/index.page";
        return "forward:/mes/json/logout.page";
    }

    @RequestMapping(value = "/gw/apprv")
    public String appApprv(HttpSession session, HttpServletRequest request, HttpServletResponse response, ModelMap model) throws Exception {
//        String html = ssoGwService.getScoreHtml("aaa","1111","2222","3333","4444","55555","6666","1111","77777","","123",null);
//        model.put("html",html);
        return "/gw/apprv";
    }

    @RequestMapping(value = "/gw/apprv1")
    public String appApprv1(HttpSession session, HttpServletRequest request, HttpServletResponse response, ModelMap model) throws Exception {
        return "/gw/apprv";
    }

    @RequestMapping("/mes/gw/doc/json/data.data")
    public String proceduleMes(HttpServletRequest request,Map model) throws SQLException, JsonProcessingException {
        // 검사성적서
        DataMesMap map = CommonUtil.convertAll((DataMap) request.getAttribute(CommonConfig.PARAM_ATT_KEY));
        String type = map.getString("TYPE");
        String html = "";
        DataMap data = new DataMap();
        if("MES001".equals(type)) {
            map.setModuleCommand("mes",map.getString("TYPE"));
            data = commonService.getMap(map);
            map.put("DOC_ID", data.getString("DOC_ID"));
            if( StringUtils.isEmpty(data.getString("DOC_ID")) || StringUtils.isBlank(data.getString("DOC_ID"))) {
                map.setModuleCommand("mes","APPRVDOC");
                DataMap docData = commonService.getMap(map);
                map.setModuleCommand("mes",map.getString("TYPE"));
                map.put("DOC_ID", docData.get("DOC_ID"));
                commonService.update(map);
            }
//            map.setModuleCommand("mes","APRVDOCDATA"); //수정전
//            List<DataMap> list = commonService.getList(map);
            map.setModuleCommand("Quality","QLT07");
            String jsonSTR = CommonUtil.mapToJson(map);
            map.put("P_JSON_STR", jsonSTR);
            map.put("P_TYPE","APVR");
            commonService.getMap(map);
            List<DataMap> list = CommonUtil.processList(map, "P_RS_LIST");
//
            map.setModuleCommand("mes","DOC_BAS");
            DataMap basicInfo = commonService.getMap(map);
            if(basicInfo!=null && list != null &&list.size() > 0) {
                DataMap row = list.get(0);
                String factoryName = basicInfo.getString("NAME01");
                String factoryAddr = basicInfo.getString("ADDR01");
                String fax = basicInfo.getString("FAXTL1");
                String tel = basicInfo.getString("TELN01");
                String itemName = row.getString("MATNR_NM");
                String size = row.getString("MATNR_SPEC"); // 사이즈를 규격?
                String locNo = row.getString("LOT_NO");
                String count = list.size() + ""; // 나중에 수정
                String company = "";
                String companyAddr = "";
                String companyTel = "";
                map.setModuleCommand("mes", "COMPANY");
                DataMap companyInfo = commonService.getMap(map);
                if(companyInfo!=null) {
                    company = companyInfo.getString("NAME02");
                    companyAddr = companyInfo.getString("ADDR01");
                    companyTel = companyInfo.getString("TELN01");
                }
                
                DataMap param = new DataMap();
                param.put("factoryName",factoryName);
                param.put("itemName", itemName);
                param.put("factoryAddr",factoryAddr);
                param.put("size",size);
                param.put("tel",tel);
                param.put("fax",fax);
                param.put("locNo",locNo);
                param.put("company",company);
                param.put("companyAddr",companyAddr);
                param.put("companyTel",companyTel);
                param.put("count",count);
                param.put("FNL_JDGM_NM", row.getString("FNL_JDGM_NM")); //종합결과
                html = ssoGwService.getScoreHtml(param,list);
                // html = ssoGwService.getScoreHtmlPage(param,list,request);
            }
        }
        // 재고실사
        if("MES002".equals(type)) {
        }
        // 페기
        if("MES003".equals(type)) {
            List<DataMap> list = null;
            if("VIEW".equals(map.getString("aprv"))) {
                map.setModuleCommand("mes","MES001LIST");
                list =  commonService.getList(map);
                list = CommonUtil.converPageDataList(list);
            }else {
                list = map.getList("list");
                if(ssoGwService.haveAprving(list)) {
                    data.put("message", "결재중인 데이터가 존재 합니다. 조회후 다시 선택하세요.");
                    model.put("data", data);
                    return JSON_VIEW;
                }
                map.setModuleCommand("mes","APPRVDOC");
                DataMap docData = commonService.getMap(map);
                map.setModuleCommand("mes",map.getString("TYPE"));
                map.put("DOC_ID", docData.get("DOC_ID"));
                for(DataMap info: list) {
                    DataMap uMap = (DataMap) info.get("map");
//                  if("".equals(uMap.getString("APVR_STA")) || "0".equals(uMap.getString("APVR_STA"))) {
                    uMap.put("DOC_ID", docData.get("DOC_ID"));
                    uMap.put("USERID", map.get("SES_USER_ID"));
                    uMap.setModuleCommand("mes","MES003DOCID");
                    commonService.update(uMap);
//                  }
                }
                map.put("P_TYPE", "LIST2");
                map.setModuleCommand("Work", "WRK08");
                String jsonStr = CommonUtil.mapToJson(map);
                map.put("P_JSON_STR", jsonStr);
                commonService.getMap(map);
                list = CommonUtil.processList(map, "P_RS_LIST");
                list = CommonUtil.converPageDataList(list);
            }
            if(list.size() > 0) {
                DataMap param = new DataMap();
                html = ssoGwService.getDisposalHtml(param,list);
            }
        }
        data.put("HTML",html);
        data.put("DOC_ID", map.getString("DOC_ID"));
        model.put("data", data);
        return JSON_VIEW;
    }

    @RequestMapping(value = "/gw/getdocId")
    public String getDocId(HttpSession session, HttpServletRequest request, HttpServletResponse response, ModelMap model) throws Exception {
        return "/gw/apprv";
    }

    @RequestMapping("/gw/html/MES001.*")
    public String htmlPage(String page){
        return "/gw/MES001";
    }

}