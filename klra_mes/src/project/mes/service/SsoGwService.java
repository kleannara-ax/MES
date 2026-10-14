package project.mes.service;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.json.simple.JSONObject;
import org.json.simple.parser.JSONParser;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.ui.ModelMap;
import project.common.airfw.User;
import project.common.bean.CommonConfig;
import project.common.bean.DataMap;
import project.common.bean.SystemConfig;
import project.common.dao.CommonDAO;
import project.common.service.CommonService;
import project.mes.controller.MesLoginController;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;
import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.net.HttpURLConnection;
import java.net.URL;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.*;

@Service
public class SsoGwService {

	static final Logger log = LogManager.getLogger(MesLoginController.class.getName());
	@Autowired
	public CommonDAO commonDao;

	@Autowired
	private SystemConfig systemConfig;

	@Autowired
	private CommonService commonService;

	public void insertLog(String logParam) {
		try{
			DataMap dataMap = new DataMap();
			dataMap.put("log",logParam);
			dataMap.setModuleCommand("Common", "SAVEGWPARAM");
			commonDao.insert(dataMap);
		}catch (Exception e) {
			log.error(e);
		}
	}


	public boolean ssoLogin(String sproId, HttpServletRequest request, ModelMap model) throws SQLException {
		HttpSession session = request.getSession();

//		String encPw = map.getString("PASSWD");
//		String plntky = map.getString("PLNTKY");// 플랜트
		String decPw = null;
		DataMap map = new DataMap();
		map.put("USERID", sproId);
		map.setModuleCommand(systemConfig.getCmmonType(), "USERCHECK");
		User user = (User)commonService.getObj(map);
		if (user != null) {
//			if (!user.getPassword().equals(map.getString("PASSWD"))) {
//				model.put("data", "F");
//				return false;
//			}

			commonService.update(systemConfig.getCmmonType()+".LOGIN", map);

			map.setModuleCommand("Common", "SYSGRIDCOL");
			map.put(CommonConfig.SES_USER_ID_KEY, user.getUserid());
			List<DataMap> list = commonService.getList(map);
			DataMap usrlo = new DataMap();
			DataMap row;
			//List data;
			String progid;
			for (int i = 0; i < list.size(); i++) {
				row = list.get(i);
				progid = row.getString("PROGID");
				if (usrlo.containsKey(progid)) {
					//data = usrlo.getList(progid);
					//data.add(row);
				} else {
					List newData = new ArrayList();
					newData.add(row);
					usrlo.put(progid, newData);
				}
			}

			user.setUsrlo(usrlo);

			session.setAttribute(CommonConfig.SES_MENU_GROUP_KEY, user.getMenugid());

			session.setAttribute(CommonConfig.SES_USER_OBJECT_KEY, user);
			session.setAttribute(CommonConfig.SES_USER_ID_KEY, user.getUserid());
			session.setAttribute(CommonConfig.SES_USER_NAME_KEY, user.getUsername());
			session.setAttribute(CommonConfig.SES_USER_COMPANY_KEY, user.getCompid());
			session.setAttribute(CommonConfig.SES_USER_LANGUAGE_KEY, "KR");
			session.setAttribute(CommonConfig.SES_USER_THEME_KEY, CommonConfig.SYSTEM_THEME_PATH);
			session.setAttribute(CommonConfig.SES_USER_WHAREHOUSE_KEY, "CP");
			session.setAttribute(CommonConfig.SES_USER_PLANT_KEY, "CP");


			String schema = "public";
			if(!"WDSCM".equals(user.getCompid())){
				schema = user.getCompid().toLowerCase();
			}
			session.setAttribute(CommonConfig.SES_SCHEMA, schema);

			// menu list
			map.put("LANGKY", map.getString("LANGKY"));
			map.put("USERID", user.getUserid());
			map.put("MENUGID", user.getMenugid());
			map.put("COMPID", user.getCompid());

			list = commonService.getList("Common.MENUTREE", map);

			session.setAttribute(CommonConfig.SES_USER_MENU_KEY, list);

			DataMap urlMap = new DataMap();
			String tmpUrl;
			for (int i = 0; i < list.size(); i++) {
				row = list.get(i);
				tmpUrl = row.getString("PGPATH");
				if (tmpUrl.trim().length() != 0) {
					if (tmpUrl.substring(0, 2).equals("./")) {
						tmpUrl = tmpUrl.substring(1);
					}
					if (tmpUrl.substring(tmpUrl.length() - 3).equals("jsp")) {
						tmpUrl = tmpUrl.substring(0, tmpUrl.length() - 3) + "page";
					}
					urlMap.put(tmpUrl, true);
				}
			}
			urlMap.put("/common/main.page", true);
			urlMap.put("/common/left.page", true);
			urlMap.put("/common/top.page", true);
			urlMap.put("/common/wintab.page", true);
			urlMap.put("/common/info.page", true);
			session.setAttribute(CommonConfig.SES_USER_URL_KEY, urlMap);
			// model.put("data", "S");


			map.setModuleCommand("System", "LOGIN_LOG");
			map.put("SES_USER_IP", request.getRemoteAddr());
			commonService.insert(map);

			log.debug(user);
			return true;
		} else {
			model.put("data", "N");
			return false;
		}
	}

	public Map post(String strUrl, String jsonMessage){

		Map result = null;
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


				result = new HashMap();

				String returnJson = sb.toString();

				// returnJson parsing
				JSONParser parser = new JSONParser();
				Object obj = parser.parse(returnJson);
				JSONObject jsonObj = (JSONObject) obj;
				System.out.println("## " +jsonObj.toJSONString());

				// head parsing
				Map headMap = (Map)jsonObj.get("head");
				String returnCode = Long.toString((Long)headMap.get("returnCode"));
				String returnDesc = (String)headMap.get("returnDesc");

				if (returnCode.equals("0")) {
					// body parsing
					Map bodyMap = (Map)jsonObj.get("body");

					result.put("bodyMap", bodyMap);
				}

				result.put("headMap", headMap);

			} else {
				System.out.println(con.getResponseMessage());
			}
		} catch (Exception e){
			System.err.println(e.toString());
		}

		return result;

	}

	public boolean isSsoEpUser(String id, String pw) {
		try {
			// TODO Auto-generated method stub
			// 상품(메뉴)별 인증요청 URL

			String strUrl = CommonConfig.getSSO_SITE()+"/rest/security/authenticate";

			// json message 구성
			String sproId = id;
			String password = pw;
			String productId = CommonConfig.SSO_PRODUCT_ID;
			String loginIp = "127.0.0.1"; //request.getRemoteAddr()
			String productName = "xxx"; //request.getHeader("user-agent")
			String application = CommonConfig.SSO_PRODUCT_ID;
			String useEncData = "false";
			String useEncPw = "true"; //패스워드 암호화 없이 보냄

			String jsonMessage = "{";
			jsonMessage += "\"sproId\":\"" + sproId + "\"";
			jsonMessage += ",\"password\":\"" + password + "\"";
			jsonMessage += ",\"loginIp\":\"" + loginIp + "\"";
			jsonMessage += ",\"productId\":\"" + productId + "\"";
			jsonMessage += ",\"productName\":\"" + productName + "\"";
			jsonMessage += ",\"application\":\"" + application + "\"";
			jsonMessage += ",\"useEncPw\":\"" + useEncPw + "\"";
			jsonMessage += ",\"useEncData\":\"" + useEncData + "\"";
			jsonMessage += "}";

			Map m = this.post(strUrl, jsonMessage);
			if (m != null && m.get("bodyMap") != null) {
				return true;
			}
			return false;
		}catch (Exception e) {
			return  false;
		}
	}

	/**
	 *
	 * @param1 factoryName 공장명
	 * @param1 itemName 품목
	 * @param1 factoryAddr 공장주소
	 * @param1 size 규격
	 * @param1 tel TEL
	 * @param1 fax fax
	 * @param1 lotNo LOT NO
	 * @param1 company 본사
	 * @param1 count 수량
	 * @param1 list (항목, 단위, 관리기준, 검사결과 , 비고)
	 * @return
	 */
	public String getScoreHtml(DataMap param, List<DataMap> list) {
		String factoryName = param.getString("factoryName");
		String itemName = param.getString("itemName");
		String factoryAddr = param.getString("factoryAddr");
		String size = param.getString("size");
		String tel = param.getString("tel");
		String fax = param.getString("fax");
		String lotNo = param.getString("lotNo");
		String company = param.getString("company");
		String companyAddr = param.getString("companyAddr");
		String companyTel = param.getString("companyTel");
		String count = param.getString("count");
		SimpleDateFormat sdt = new SimpleDateFormat("yyyyMMdd");
		Calendar sc = Calendar.getInstance();
		String sTime = sdt.format(sc.getTime());
		String YYYY = sTime.substring(0,4);
		String MM = sTime.substring(4,6);
		String DD = sTime.substring(6,8);

		String html = "<html><head></head><body> " +
				"<p style=\"line-height: 19.2px; text-align: center; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><br></p>\n" +
				"  <p style=\"line-height: 19.2px; text-align: center; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\">"
				+ "<strong style=\"font-size: 14pt;\">제목의 건, 아래와 같이 품의 하오니 검토 후 재가 바랍니다.</strong></p>\n" +
				"  <p style=\"line-height: 19.2px; text-align: center; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><br></p>\n" +
				"  <p style=\"line-height: 19.2px; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><br></p>\n" +
				"  <p style=\"line-height: 19.2px; text-align: center; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\">"
				+ "<strong style=\"font-size: 14pt;\">- 아 래 -</strong></p>\n" +
				"  <p style=\"line-height: 19.2px; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><br></p>\n" +
				"  <p style=\"line-height: 19.2px; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><strong style=\"font-size: 14pt;\">1.수신처:</strong></p>\n" +
				"  <p style=\"line-height: 19.2px; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><strong style=\"font-size: 14pt;\">2.내 용:&nbsp;</strong></p>"+
				"<table border=\"0\" cellspacing=\"0\" cellpadding=\"0\" style=\"word-break: break-all; width: 1060px; height: 20px; font-size: 12pt; border-collapse: collapse; border: 0px none rgb(0, 0, 0);\">\n" +
				"\t<tbody>\n" +
				"\t\t<tr>\n" +
				"\t\t</tr>\n" +
				"\t\t<tr>\n" +
				"\t\t</tr>\n" +
				"\t\t<tr>\n" +
				"\t\t</tr>\n" +
				"\t\t<tr>\n" +
				"\t\t</tr>\n" +
				"\t</tbody>\n" +
				"</table>\n" +
				"  <p style=\"line-height: 19.2px; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><br></p>\n" +
				"  \n" +
				"<table border=\"1\" cellspacing=\"0\" cellpadding=\"0\" style=\"word-break: break-all; width: 1060px; height: 20px; font-size: 12pt; border-collapse: collapse; border: 1px none rgb(0, 0, 0);\">\n" +
				"\t<tbody>\n" +
				"\t\t<tr>\n" +
				"\t\t\t<td style=\"border: 1px solid rgb(0, 0, 0); width: 1059px; height: 20px;\">\n" +
				"\t\t\t\t<p style=\"line-height: 19.2px; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\">&nbsp;"
				+ "<span style=\"font-size: 12pt; line-height: 19.2px; margin-top: 0px; margin-bottom: 0px; font-family: &quot;맑은 고딕&quot;;\"><br></span></p>"
				+ "<p style=\"line-height: 19.2px; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><br></p>&nbsp; &nbsp; &nbsp; &nbsp;\n" +
				"      \n" +
				"<table border=\"0\" cellspacing=\"0\" cellpadding=\"0\" style=\"word-break: break-all; width: 1049px; height: 80px; font-size: 12pt; border: 0px none rgb(0, 0, 0); border-collapse: collapse;\">\n" +
				"\t<tbody>\n" +
				"\t\t<tr>\n" +
				"\t\t\t<td colspan=\"10\" style=\"border: 0px solid rgb(0, 0, 0); width: 1098px; height: 20px;\">\n" +
				"\t\t\t\t<p style=\"line-height: 19.2px; text-align: center; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><br></p>"
				+ "<p style=\"line-height: 19.2px; text-align: center; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\">"
				+ "<strong style=\"font-size: 24pt;\">검 사 성 적 서</strong></p><p style=\"line-height: 19.2px; text-align: center; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><br></p>"
				+ "<p style=\"line-height: 19.2px; text-align: center; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><br></p>"
				+ "<p style=\"line-height: 19.2px; text-align: center; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><br></p>"
				+ "<p style=\"line-height: 19.2px; text-align: center; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><br></p>"
				+ "<p style=\"line-height: 19.2px; text-align: center; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><br></p>\n" +
				"\t\t\t</td>\n" +
				"\t\t</tr>\n" +
				"\t\t<tr>\n" +
				"\t\t\t<td colspan=\"10\" style=\"border: 0px solid rgb(0, 0, 0); width: 1098px; height: 20px;\">\n" +
				"\t\t\t\t<p style=\"line-height: 19.2px; text-align: center; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><br></p>"
				+ "<p style=\"line-height: 19.2px; text-align: center; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\">"
				+ "<b style=\"font-size: 16pt;\">귀중&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;"
				+ " &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;"+company+" "+factoryName+"</b></p>"
						+ "<p style=\"line-height: 19.2px; text-align: center; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><br></p>\n" +
				"\t\t\t</td>\n" +
				"\t\t</tr>\n" +
				"\t\t<tr>\n" +
				"\t\t\t<td style=\"border: 0px solid rgb(0, 0, 0); width: 138px; height: 20px;\">\n" +
				"\t\t\t\t<p style=\"line-height: 19.2px; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\">"
				+ "<span style=\"font-size: 16pt; line-height: 25.6px; margin-top: 0px; margin-bottom: 0px; font-family: &quot;맑은 고딕&quot;;\">&nbsp; 1.품</span>"
				+ "<span style=\"font-size: 16pt; line-height: 25.6px; margin-top: 0px; margin-bottom: 0px; font-family: &quot;맑은 고딕&quot;;\">"
				+ "<span style=\"font-size: 16pt; line-height: 25.6px; margin-top: 0px; margin-bottom: 0px; font-family: &quot;맑은 고딕&quot;;\">목 :</span></span></p>\n" +
				"\t\t\t</td>\n" +
				"\t\t\t<td colspan=\"3\" style=\"border: 0px solid rgb(0, 0, 0); width: 277px; height: 20px;\">\n" +
				"\t\t\t\t<p style=\"line-height: 19.2px; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\">"
				+ "<span style=\"font-size: 16pt; line-height: 25.6px; margin-top: 0px; margin-bottom: 0px; font-family: &quot;맑은 고딕&quot;;\">"+itemName+"</span></p>\n" +
				"\t\t\t</td>\n" +
//				"\t\t\t<td style=\"border: 0px solid rgb(0, 0, 0); width: 53px; height: 20px;\">\n" +
//				"\t\t\t\t<p style=\"line-height: 19.2px; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><br></p>\n" +
//				"\t\t\t</td>\n" +
				"\t\t\t<td style=\"border: 0px solid rgb(0, 0, 0); width: 57px; height: 20px;\">\n" +
				"\t\t\t\t<p style=\"line-height: 19.2px; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><br></p>\n" +
				"\t\t\t</td>\n" +
				"\t\t\t<td style=\"border: 0px solid rgb(0, 0, 0); width: 68px; height: 20px;\">\n" +
				"\t\t\t\t<p style=\"line-height: 19.2px; text-align: right; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\">"
				+ "<span style=\"font-size: 16pt; line-height: 25.6px; margin-top: 0px; margin-bottom: 0px; font-family: &quot;맑은 고딕&quot;;\">공장:</span></p>\n" +
				"\t\t\t</td>\n" +
				"\t\t\t<td colspan=\"4\" style=\"border: 0px solid rgb(0, 0, 0); width: 445px; height: 20px;\">\n" +
				"\t\t\t\t<p style=\"line-height: 19.2px; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\">"
				+ "<span style=\"font-size: 16pt; line-height: 25.6px; margin-top: 0px; margin-bottom: 0px; font-family: &quot;맑은 고딕&quot;;\">"+factoryAddr+"</span></p>\n" +
				"\t\t\t</td>\n" +
				"\t\t</tr>\n" +
				"\t\t<tr>\n" +
				"\t\t\t<td style=\"border: 0px solid rgb(0, 0, 0); width: 138px; height: 20px;\">\n" +
				"\t\t\t\t<p style=\"line-height: 19.2px; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\">"
				+ "<span style=\"font-size: 16pt; line-height: 25.6px; margin-top: 0px; margin-bottom: 0px; font-family: &quot;맑은 고딕&quot;;\">"
				+ "<span style=\"font-size: 16pt; line-height: 25.6px; margin-top: 0px; margin-bottom: 0px; font-family: &quot;맑은 고딕&quot;;\">&nbsp; 2.규격 "+size+":</span></span></p>\n" +
				"\t\t\t</td>\n" +
				"\t\t\t<td colspan=\"3\" style=\"border: 0px solid rgb(0, 0, 0); width: 277px; height: 20px;\">\n" +
				"\t\t\t\t<p style=\"line-height: 19.2px; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\">"
				+ "<span style=\"font-size: 16pt; line-height: 25.6px; margin-top: 0px; margin-bottom: 0px; font-family: &quot;맑은 고딕&quot;;\"></span></p>\n" +
				"\t\t\t</td>\n" +
//				"\t\t\t<td style=\"border: 0px solid rgb(0, 0, 0); width: 53px; height: 20px;\">\n" +
//				"\t\t\t\t<p style=\"line-height: 19.2px; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><br></p>\n" +
//				"\t\t\t</td>\n" +
				"\t\t\t<td style=\"border: 0px solid rgb(0, 0, 0); width: 57px; height: 20px;\">\n" +
				"\t\t\t\t<p style=\"line-height: 19.2px; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><br></p>\n" +
				"\t\t\t</td>\n" +
				"\t\t\t<td style=\"border: 0px solid rgb(0, 0, 0); width: 68px; height: 20px;\">\n" +
				"\t\t\t\t<p style=\"line-height: 19.2px; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><br></p>\n" +
				"\t\t\t</td>\n" +
				"\t\t\t<td colspan=\"4\" style=\"border: 0px solid rgb(0, 0, 0); width: 445px; height: 20px;\">\n" +
				"\t\t\t\t<p style=\"line-height: 19.2px; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\">"
				+ "<span style=\"font-size: 16pt; line-height: 25.6px; margin-top: 0px; margin-bottom: 0px; font-family: &quot;맑은 고딕&quot;;\">&nbsp; &nbsp; TEL:"+tel+"</span></p>\n" +
				"\t\t\t</td>\n" +
				"\t\t</tr>\n" +
				"\t\t<tr>\n" +
				"\t\t\t<td style=\"border: 0px solid rgb(0, 0, 0); width: 140px; height: 20px;\">\n" +
				"\t\t\t\t<p style=\"line-height: 19.2px; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\">"
				+ "<span style=\"font-size: 16pt; line-height: 25.6px; margin-top: 0px; margin-bottom: 0px; font-family: &quot;맑은 고딕&quot;;\">"
				+ "<span style=\"font-size: 16pt; line-height: 25.6px; margin-top: 0px; margin-bottom: 0px; font-family: &quot;맑은 고딕&quot;;\">&nbsp; 3.Lot No :</span></span></p>\n" +
				"\t\t\t</td>\n" +
				"\t\t\t<td colspan=\"3\" style=\"border: 0px solid rgb(0, 0, 0); width: 277px; height: 20px;\">\n" +
				"\t\t\t\t<p style=\"line-height: 19.2px; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\">"
				+ "<span style=\"font-size: 16pt; line-height: 25.6px; margin-top: 0px; margin-bottom: 0px; font-family: &quot;맑은 고딕&quot;;\">"+lotNo+"</span></p>\n" +
				"\t\t\t</td>\n" +
//				"\t\t\t<td style=\"border: 0px solid rgb(0, 0, 0); width: 53px; height: 20px;\">\n" +
//				"\t\t\t\t<p style=\"line-height: 19.2px; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><br></p>\n" +
//				"\t\t\t</td>\n" +
				"\t\t\t<td style=\"border: 0px solid rgb(0, 0, 0); width: 57px; height: 20px;\">\n" +
				"\t\t\t\t<p style=\"line-height: 19.2px; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><br></p>\n" +
				"\t\t\t</td>\n" +
				"\t\t\t<td style=\"border: 0px solid rgb(0, 0, 0); width: 68px; height: 20px;\">\n" +
				"\t\t\t\t<p style=\"line-height: 19.2px; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><br></p>\n" +
				"\t\t\t</td>\n" +
				"\t\t\t<td colspan=\"4\" style=\"border: 0px solid rgb(0, 0, 0); width: 445px; height: 20px;\">\n" +
				"\t\t\t\t<p style=\"line-height: 19.2px; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\">"
				+ "<span style=\"font-size: 16pt; line-height: 25.6px; margin-top: 0px; margin-bottom: 0px; font-family: &quot;맑은 고딕&quot;;\">&nbsp; &nbsp; FAX:"+fax+"</span></p>\n" +
				"\t\t\t</td>\n" +
				"\t\t</tr>\n" +
				"\t\t<tr>\n" +
				"\t\t\t<td style=\"border: 0px solid rgb(0, 0, 0); width: 138px; height: 20px;\">\n" +
				"\t\t\t\t<p style=\"line-height: 19.2px; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\">"
				+ "<span style=\"font-size: 16pt; line-height: 25.6px; margin-top: 0px; margin-bottom: 0px; font-family: &quot;맑은 고딕&quot;;\">"
				+ "<span style=\"font-size: 16pt; line-height: 25.6px; margin-top: 0px; margin-bottom: 0px; font-family: &quot;맑은 고딕&quot;;\">&nbsp; </span></span></p>\n" +
				"\t\t\t</td>\n" +
				"\t\t\t<td colspan=\"3\" style=\"border: 0px solid rgb(0, 0, 0); width: 277px; height: 20px;\">\n" +
//				"\t\t\t\t<p style=\"line-height: 19.2px; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><span style=\"font-size: 16pt; line-height: 25.6px; margin-top: 0px; margin-bottom: 0px; font-family: &quot;맑은 고딕&quot;;\">"+count+"</span></p>\n" +
				"\t\t\t</td>\n" +
//				"\t\t\t<td style=\"border: 0px solid rgb(0, 0, 0); width: 53px; height: 20px;\">\n" +
//				"\t\t\t\t<p style=\"line-height: 19.2px; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><br></p>\n" +
//				"\t\t\t</td>\n" +
				"\t\t\t<td style=\"border: 0px solid rgb(0, 0, 0); width: 57px; height: 20px;\">\n" +
				"\t\t\t\t<p style=\"line-height: 19.2px; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><br></p>\n" +
				"\t\t\t</td>\n" +
				"\t\t\t<td style=\"border: 0px solid rgb(0, 0, 0); width: 68px; height: 20px;\">\n" +
				"\t\t\t\t<p style=\"line-height: 19.2px; text-align: right; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\">"
				+ "<span style=\"font-size: 16pt; line-height: 25.6px; margin-top: 0px; margin-bottom: 0px; font-family: &quot;맑은 고딕&quot;;\">본사:</span></p>\n" +
				"\t\t\t</td>\n" +
				"\t\t\t<td colspan=\"4\" style=\"border: 0px solid rgb(0, 0, 0); width: 445px; height: 20px;\">\n" +
				"\t\t\t\t<p style=\"line-height: 19.2px; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\">"
				+ "<span style=\"font-size: 16pt; line-height: 25.6px; margin-top: 0px; margin-bottom: 0px; font-family: &quot;맑은 고딕&quot;;\">"+companyAddr+"</span></p>\n" +
				"\t\t\t</td>\n" +
				"\t\t</tr>\n" +
				"\t\t<tr>\n" +
				"\t\t\t<td style=\"border: 0px solid rgb(0, 0, 0); width: 138px; height: 20px;\">\n" +
				"\t\t\t\t<p style=\"line-height: 19.2px; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><br></p>\n" +
				"\t\t\t</td>\n" +
				"\t\t\t<td colspan=\"3\" style=\"border: 0px solid rgb(0, 0, 0); width: 277px; height: 20px;\">\n" +
				"\t\t\t\t<p style=\"line-height: 19.2px; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><br></p>\n" +
				"\t\t\t</td>\n" +
//				"\t\t\t<td style=\"border: 0px solid rgb(0, 0, 0); width: 53px; height: 20px;\">\n" +
//				"\t\t\t\t<p style=\"line-height: 19.2px; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><br></p>\n" +
//				"\t\t\t</td>\n" +
				"\t\t\t<td style=\"border: 0px solid rgb(0, 0, 0); width: 57px; height: 20px;\">\n" +
				"\t\t\t\t<p style=\"line-height: 19.2px; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><br></p>\n" +
				"\t\t\t</td>\n" +
				"\t\t\t<td style=\"border: 0px solid rgb(0, 0, 0); width: 68px; height: 20px;\">\n" +
				"\t\t\t\t<p style=\"line-height: 19.2px; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><br></p>\n" +
				"\t\t\t</td>\n" +
				"\t\t\t<td colspan=\"4\" style=\"border: 0px solid rgb(0, 0, 0); width: 211px; height: 20px;\">\n" +
				"\t\t\t\t<p style=\"line-height: 19.2px; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\">"
				+ "<span style=\"font-size: 16pt; line-height: 25.6px; margin-top: 0px; margin-bottom: 0px; font-family: &quot;맑은 고딕&quot;;\">&nbsp; &nbsp; TEL:"+companyTel+"</span></p>\n" +
				"\t\t\t</td>\n" +
				"\t\t</tr>\n" +
				"\t</tbody>\n" +
				"</table>\n" +
				"<p style=\"line-height: 19.2px; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><br></p>"
				+ "<p style=\"line-height: 19.2px; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><br></p>"
				+ "<p style=\"line-height: 19.2px; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><br></p>"
				+ "<p style=\"line-height: 19.2px; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><br></p>\n" +
				"      \n" +
				"<table border=\"1\" cellspacing=\"0\" cellpadding=\"0\" style=\"word-break: break-all; width: 1046px; font-size: 12pt; border-collapse: collapse; border: 1px none rgb(0, 0, 0); height: 174px;\">\n" +
				"\t<tbody>\n" +
				"\t\t<tr>\n" +
				"\t\t\t<td style=\"border: 0px solid rgb(0, 0, 0); width: 10px; height: 45px;\">\n" +
				"\t\t\t\t<p style=\"line-height: 19.2px; text-align: center; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\">"
				+ "<span style=\"font-size: 16pt; line-height: 25.6px; margin-top: 0px; margin-bottom: 0px; font-family: &quot;맑은 고딕&quot;;\"><br></span></p>\n" +
				"\t\t\t</td>\n" +
				"\t\t\t<td style=\"border:1px solid rgb(0,0,0);width:291px;height:45px;background-color:rgb(226,226,226)\">\n" +
				"\t\t\t\t<p style=\"line-height: 19.2px; text-align: center; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\">"
				+ "<span style=\"font-size: 16pt; line-height: 25.6px; margin-top: 0px; margin-bottom: 0px; font-family: &quot;맑은 고딕&quot;;\">항목</span></p>\n" +
				"\t\t\t</td>\n" +
				"\t\t\t<td style=\"border:1px solid rgb(0,0,0);width:92px;height:45px;background-color:rgb(226,226,226);\">\n" +
				"\t\t\t\t<p style=\"line-height: 19.2px; text-align: center; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\">"
				+ "<span style=\"font-size: 16pt; line-height: 25.6px; margin-top: 0px; margin-bottom: 0px; font-family: &quot;맑은 고딕&quot;;\">단위</span></p>\n" +
				"\t\t\t</td>\n" +
				"\t\t\t<td style=\"border:1px solid rgb(0,0,0);width:247px;height:45px;background-color:rgb(226,226,226)\">\n" +
				"\t\t\t\t<p style=\"line-height: 19.2px; text-align: center; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\">"
				+ "<span style=\"font-size: 16pt; line-height: 25.6px; margin-top: 0px; margin-bottom: 0px; font-family: &quot;맑은 고딕&quot;;\">관리기준</span></p>\n" +
				"\t\t\t</td>\n" +
				"\t\t\t<td style=\"border:1px solid rgb(0,0,0);width:113px;height:45px;background-color:rgb(226,226,226)\">\n" +
				"\t\t\t\t<p style=\"line-height: 19.2px; text-align: center; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\">"
				+ "<span style=\"font-size: 16pt; line-height: 25.6px; margin-top: 0px; margin-bottom: 0px; font-family: &quot;맑은 고딕&quot;;\">검사결과</span></p>\n" +
				"\t\t\t</td>\n" +
				"\t\t\t<td style=\"border:1px solid rgb(0,0,0);width:297px;height:45px;background-color:rgb(226,226,226)\">\n" +
				"\t\t\t\t<p style=\"line-height: 19.2px; text-align: center; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\">"
				+ "<span style=\"font-size: 16pt; line-height: 25.6px; margin-top: 0px; margin-bottom: 0px; font-family: &quot;맑은 고딕&quot;;\">비고</span></p>\n" +
				"\t\t\t</td>\n" +
				"\t\t</tr>\n" ;
				// 줄
				for(DataMap info: list){
					html+="\t\t<tr>\n" +
					"\t\t\t<td style=\"border: 0px solid rgb(0, 0, 0); width: 10px; height: 45px;\">\n" +
					"\t\t\t\t<p style=\"line-height: 19.2px; text-align: center; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\">"
					+ "<span style=\"font-size: 16pt; line-height: 25.6px; margin-top: 0px; margin-bottom: 0px; font-family: &quot;맑은 고딕&quot;;\"><br></span></p>\n" +
					"\t\t\t</td>\n" +
					"\t\t\t<td style=\"border: 1px solid rgb(0, 0, 0); width: 291px; height: 21px;\">\n" +
					"\t\t\t\t<p style=\"line-height: 19.2px; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;text-align:left\">"+info.getString("INSP_ITEM_NM")+"<br></p>\n" +
					"\t\t\t</td>\n" +
					"\t\t\t<td style=\"border: 1px solid rgb(0, 0, 0); width: 92px; height: 21px;\">\n" +
					"\t\t\t\t<p style=\"line-height: 19.2px; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;text-align:center\">"+info.getString("MSRM_UNIT")+"<br></p>\n" +
					"\t\t\t</td>\n" +
					"\t\t\t<td style=\"border: 1px solid rgb(0, 0, 0); width: 247px; height: 21px;\">\n" +
					"\t\t\t\t<p style=\"line-height: 19.2px; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;text-align:center\">"+info.getString("MGMT_STD")+"<br></p>\n" +
					"\t\t\t</td>\n" +
					"\t\t\t<td style=\"border: 1px solid rgb(0, 0, 0); width: 113px; height: 21px;\">\n" +
					"\t\t\t\t<p style=\"line-height: 19.2px; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;text-align:center\">"+info.getString("MSRM_RST")+"<br></p>\n" +
					"\t\t\t</td>\n" +
					"\t\t\t<td style=\"border: 1px solid rgb(0, 0, 0); width: 297px; height: 21px;\">\n" +
					"\t\t\t\t<p style=\"line-height: 19.2px; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;text-align:left\">"+info.getString("RMK")+"<br></p>\n" +
					"\t\t\t</td>\n" +
					"\t\t</tr>\n" ;
				}
				if(list.size() > 0) {
					html+="\t\t<tr>\n" +
							"\t\t\t<td style=\"border: 0px solid rgb(0, 0, 0); width: 10px; height: 45px;\">\n" +
							"\t\t\t\t<p style=\"line-height: 19.2px; text-align: center; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\">"
							+ "<span style=\"font-size: 16pt; line-height: 25.6px; margin-top: 0px; margin-bottom: 0px; font-family: &quot;맑은 고딕&quot;;\"><br></span></p>\n" +
							"\t\t\t</td>\n" +
							"\t\t\t<td style=\"border: 1px solid rgb(0, 0, 0); width: 291px; height: 21px;\" colspan=\"3\">\n" +
							"\t\t\t\t<p style=\"line-height: 19.2px; text-aligh:center;font-size: 16pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;text-align:center\"><b>종합결과</b><br></p>\n" +
							"\t\t\t</td>\n" +
							"\t\t\t<td style=\"border: 1px solid rgb(0, 0, 0); width: 92px; height: 21px;\">\n" +
							"\t\t\t\t<p style=\"line-height: 19.2px; font-size: 16pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px; text-align:center\">"+param.getString("FNL_JDGM_NM")+"<br></p>\n" +
							"\t\t\t</td>\n" +
							"\t\t\t<td style=\"border: 1px solid rgb(0, 0, 0); width: 297px; height: 21px;\">\n" +
							"\t\t\t\t<p style=\"line-height: 19.2px; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><br></p>\n" +
							"\t\t\t</td>\n" +
							"\t\t</tr>\n" ;
				}else {
					html +="\t\t<tr>\n" +
							"\t\t\t<td style=\"border: 0px solid rgb(0, 0, 0); width: 10px; height: 45px;\">\n" +
							"\t\t\t\t<p style=\"line-height: 19.2px; text-align: center; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\">"
							+ "<span style=\"font-size: 16pt; line-height: 25.6px; margin-top: 0px; margin-bottom: 0px; font-family: &quot;맑은 고딕&quot;;\"><br></span></p>\n" +
							"\t\t\t</td>\n" +
							"\t\t\t<td style=\"border: 1px solid rgb(0, 0, 0); width: 291px; height: 21px;\">\n" +
							"\t\t\t\t<p style=\"line-height: 19.2px; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><br></p>\n" +
							"\t\t\t</td>\n" +
							"\t\t\t<td style=\"border: 1px solid rgb(0, 0, 0); width: 92px; height: 21px;\">\n" +
							"\t\t\t\t<p style=\"line-height: 19.2px; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><br></p>\n" +
							"\t\t\t</td>\n" +
							"\t\t\t<td style=\"border: 1px solid rgb(0, 0, 0); width: 247px; height: 21px;\">\n" +
							"\t\t\t\t<p style=\"line-height: 19.2px; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><br></p>\n" +
							"\t\t\t</td>\n" +
							"\t\t\t<td style=\"border: 1px solid rgb(0, 0, 0); width: 113px; height: 21px;\">\n" +
							"\t\t\t\t<p style=\"line-height: 19.2px; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><br></p>\n" +
							"\t\t\t</td>\n" +
							"\t\t\t<td style=\"border: 1px solid rgb(0, 0, 0); width: 297px; height: 21px;\">\n" +
							"\t\t\t\t<p style=\"line-height: 19.2px; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><br></p>\n" +
							"\t\t\t</td>\n" +
							"\t\t</tr>\n" +
							"\t\t<tr>\n" +
							"\t\t\t<td style=\"border: 0px solid rgb(0, 0, 0); width: 10px; height: 45px;\">\n" +
							"\t\t\t\t<p style=\"line-height: 19.2px; text-align: center; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\">"
							+ "<span style=\"font-size: 16pt; line-height: 25.6px; margin-top: 0px; margin-bottom: 0px; font-family: &quot;맑은 고딕&quot;;\"><br></span></p>\n" +
							"\t\t\t</td>\n" +
							"\t\t\t<td style=\"border: 1px solid rgb(0, 0, 0); width: 291px; height: 21px;\">\n" +
							"\t\t\t\t<p style=\"line-height: 19.2px; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><br></p>\n" +
							"\t\t\t</td>\n" +
							"\t\t\t<td style=\"border: 1px solid rgb(0, 0, 0); width: 92px; height: 21px;\">\n" +
							"\t\t\t\t<p style=\"line-height: 19.2px; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><br></p>\n" +
							"\t\t\t</td>\n" +
							"\t\t\t<td style=\"border: 1px solid rgb(0, 0, 0); width: 247px; height: 21px;\">\n" +
							"\t\t\t\t<p style=\"line-height: 19.2px; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><br></p>\n" +
							"\t\t\t</td>\n" +
							"\t\t\t<td style=\"border: 1px solid rgb(0, 0, 0); width: 113px; height: 21px;\">\n" +
							"\t\t\t\t<p style=\"line-height: 19.2px; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><br></p>\n" +
							"\t\t\t</td>\n" +
							"\t\t\t<td style=\"border: 1px solid rgb(0, 0, 0); width: 297px; height: 21px;\">\n" +
							"\t\t\t\t<p style=\"line-height: 19.2px; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><br></p>\n" +
							"\t\t\t</td>\n" +
							"\t\t</tr>\n" +
							"\t\t<tr>\n" +
							"\t\t\t<td style=\"border: 0px solid rgb(0, 0, 0); width: 10px; height: 45px;\">\n" +
							"\t\t\t\t<p style=\"line-height: 19.2px; text-align: center; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\">"
							+ "<span style=\"font-size: 16pt; line-height: 25.6px; margin-top: 0px; margin-bottom: 0px; font-family: &quot;맑은 고딕&quot;;\"><br></span></p>\n" +
							"\t\t\t</td>\n" +
							"\t\t\t<td style=\"border: 1px solid rgb(0, 0, 0); width: 291px; height: 21px;\">\n" +
							"\t\t\t\t<p style=\"line-height: 19.2px; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><br></p>\n" +
							"\t\t\t</td>\n" +
							"\t\t\t<td style=\"border: 1px solid rgb(0, 0, 0); width: 92px; height: 21px;\">\n" +
							"\t\t\t\t<p style=\"line-height: 19.2px; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><br></p>\n" +
							"\t\t\t</td>\n" +
							"\t\t\t<td style=\"border: 1px solid rgb(0, 0, 0); width: 247px; height: 21px;\">\n" +
							"\t\t\t\t<p style=\"line-height: 19.2px; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><br></p>\n" +
							"\t\t\t</td>\n" +
							"\t\t\t<td style=\"border: 1px solid rgb(0, 0, 0); width: 113px; height: 21px;\">\n" +
							"\t\t\t\t<p style=\"line-height: 19.2px; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><br></p>\n" +
							"\t\t\t</td>\n" +
							"\t\t\t<td style=\"border: 1px solid rgb(0, 0, 0); width: 297px; height: 21px;\">\n" +
							"\t\t\t\t<p style=\"line-height: 19.2px; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><br></p>\n" +
							"\t\t\t</td>\n" +
							"\t\t</tr>\n" +
							"\t\t<tr>\n" +
							"\t\t\t<td style=\"border: 0px solid rgb(0, 0, 0); width: 10px; height: 45px;\">\n" +
							"\t\t\t\t<p style=\"line-height: 19.2px; text-align: center; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\">"
							+ "<span style=\"font-size: 16pt; line-height: 25.6px; margin-top: 0px; margin-bottom: 0px; font-family: &quot;맑은 고딕&quot;;\"><br></span></p>\n" +
							"\t\t\t</td>\n" +
							"\t\t\t<td style=\"border: 1px solid rgb(0, 0, 0); width: 291px; height: 21px;\">\n" +
							"\t\t\t\t<p style=\"line-height: 19.2px; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><br></p>\n" +
							"\t\t\t</td>\n" +
							"\t\t\t<td style=\"border: 1px solid rgb(0, 0, 0); width: 92px; height: 21px;\">\n" +
							"\t\t\t\t<p style=\"line-height: 19.2px; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><br></p>\n" +
							"\t\t\t</td>\n" +
							"\t\t\t<td style=\"border: 1px solid rgb(0, 0, 0); width: 247px; height: 21px;\">\n" +
							"\t\t\t\t<p style=\"line-height: 19.2px; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><br></p>\n" +
							"\t\t\t</td>\n" +
							"\t\t\t<td style=\"border: 1px solid rgb(0, 0, 0); width: 113px; height: 21px;\">\n" +
							"\t\t\t\t<p style=\"line-height: 19.2px; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><br></p>\n" +
							"\t\t\t</td>\n" +
							"\t\t\t<td style=\"border: 1px solid rgb(0, 0, 0); width: 297px; height: 21px;\">\n" +
							"\t\t\t\t<p style=\"line-height: 19.2px; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><br></p>\n" +
							"\t\t\t</td>\n" +
							"\t\t</tr>\n" +
							"\t\t<tr>\n" +
							"\t\t\t<td style=\"border: 0px solid rgb(0, 0, 0); width: 10px; height: 45px;\">\n" +
							"\t\t\t\t<p style=\"line-height: 19.2px; text-align: center; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\">"
							+ "<span style=\"font-size: 16pt; line-height: 25.6px; margin-top: 0px; margin-bottom: 0px; font-family: &quot;맑은 고딕&quot;;\"><br></span></p>\n" +
							"\t\t\t</td>\n" +
							"\t\t\t<td style=\"border: 1px solid rgb(0, 0, 0); width: 291px; height: 21px;\">\n" +
							"\t\t\t\t<p style=\"line-height: 19.2px; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><br></p>\n" +
							"\t\t\t</td>\n" +
							"\t\t\t<td style=\"border: 1px solid rgb(0, 0, 0); width: 92px; height: 21px;\">\n" +
							"\t\t\t\t<p style=\"line-height: 19.2px; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><br></p>\n" +
							"\t\t\t</td>\n" +
							"\t\t\t<td style=\"border: 1px solid rgb(0, 0, 0); width: 247px; height: 21px;\">\n" +
							"\t\t\t\t<p style=\"line-height: 19.2px; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><br></p>\n" +
							"\t\t\t</td>\n" +
							"\t\t\t<td style=\"border: 1px solid rgb(0, 0, 0); width: 113px; height: 21px;\">\n" +
							"\t\t\t\t<p style=\"line-height: 19.2px; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><br></p>\n" +
							"\t\t\t</td>\n" +
							"\t\t\t<td style=\"border: 1px solid rgb(0, 0, 0); width: 297px; height: 21px;\">\n" +
							"\t\t\t\t<p style=\"line-height: 19.2px; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><br></p>\n" +
							"\t\t\t</td>\n" +
							"\t\t</tr>\n";
				}
				// 줄 END
				html +="\t</tbody>\n" +
				"</table>\n" +
				"<p style=\"line-height: 19.2px; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><br></p>"
				+ "<p style=\"line-height: 19.2px; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><br></p>"
				+ "<p style=\"line-height: 19.2px; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><br></p>"
				+ "<p style=\"line-height: 19.2px; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><br></p>"
				+ "<p style=\"line-height: 19.2px; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><br></p>"
				+ "<p style=\"line-height: 19.2px; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><br></p>"
				+ "<p style=\"line-height: 19.2px; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><br></p>"
				+ "<p style=\"line-height: 19.2px; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><br></p>"
				+ "<p style=\"line-height: 19.2px; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><br></p>"
				+ "<p style=\"line-height: 19.2px; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><br></p>\n" +
						"      \n" +
						"<table border=\"0\" cellspacing=\"0\" cellpadding=\"0\" style=\"word-break: break-all; width: 1048px; height: 80px; font-size: 12pt; border: 0px none rgb(0, 0, 0); border-collapse: collapse;\">\n" +
						"\t<tbody>\n" +
						"\t\t<tr>\n" +
						"\t\t\t<td colspan=\"8\" style=\"border: 0px solid rgb(0, 0, 0); width: 768px; height: 20px;\">\n" +
						"\t\t\t\t<p style=\"line-height: 19.2px; text-align: center; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><br></p>"
						+ "<p style=\"line-height: 19.2px; text-align: center; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\">"
						+ "<strong style=\"font-size: 16pt;\">상기와 같이 검사를 통보합니다.</strong></p>"
						+ "<p style=\"line-height: 19.2px; text-align: center; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><br></p>\n" +
						"\t\t\t</td>\n" +
						"\t\t</tr>\n" +
						"\t\t<tr>\n" +
						"\t\t\t<td colspan=\"8\" style=\"border: 0px solid rgb(0, 0, 0); width: 596px; height: 20px;\">\n" +
						"\t\t\t\t<p style=\"line-height: 19.2px; text-align: right; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><br></p>"
						+ "<p style=\"line-height: 19.2px; text-align: right; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\">"
						+ "<span style=\"font-size: 12pt; line-height: 19.2px; margin-top: 0px; margin-bottom: 0px; font-family: &quot;맑은 고딕&quot;;\"><br></span></p>"
						+ "<p style=\"line-height: 19.2px; text-align: right; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\">"
						+ "<span style=\"font-size: 12pt; line-height: 19.2px; margin-top: 0px; margin-bottom: 0px; font-family: &quot;맑은 고딕&quot;;\"><br></span></p>"
						+ "<p style=\"line-height: 19.2px; text-align: right; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\">"
						+ "<span style=\"font-size: 14pt; line-height: 22.4px; margin-top: 0px; margin-bottom: 0px; font-family: &quot;맑은 고딕&quot;;\">"+YYYY+"년&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; "+MM+"월&nbsp; &nbsp; &nbsp; &nbsp; &nbsp;"+DD+"일&nbsp;</span>"
								+ "<span style=\"font-size: 12pt; line-height: 19.2px; margin-top: 0px; margin-bottom: 0px; font-family: &quot;맑은 고딕&quot;;\">&nbsp; &nbsp;</span></p>"
								+ "<p style=\"line-height: 19.2px; text-align: right; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><br></p>"
								+ "<p style=\"line-height: 19.2px; text-align: right; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><br></p>"
								+ "<p style=\"line-height: 19.2px; text-align: right; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><br></p>\n" +
						"\t\t\t</td>\n" +
						"\t\t</tr>\n" +
						"\t\t<tr>\n" +
						"\t\t\t<td colspan=\"8\" style=\"border: 0px solid rgb(0, 0, 0); width: 768px; height: 20px;\">\n" +
						"\t\t\t\t<p style=\"line-height: 19.2px; text-align: center; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><br></p>"
						+ "<p style=\"line-height: 19.2px; text-align: center; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\">"
						+ "<strong style=\"font-size: 16pt;\">품질관리팀 (인)</strong></p>"
						+ "<p style=\"line-height: 19.2px; text-align: center; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><br></p>\n" +
						"\t\t\t</td>\n" +
						"\t\t</tr>\n" +
						"\t</tbody>\n" +
						"</table>\n" +
						"<p style=\"line-height: 19.2px; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><br></p>"
						+ "<p style=\"line-height: 19.2px; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><br></p>"
						+ "<p style=\"line-height: 19.2px; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><br></p>"
						+ "<p style=\"line-height: 19.2px; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><br></p>\n" +
						"\t\t\t</td>\n" +
						"\t\t</tr>\n" +
						"\t\t<tr>\n" +
						"\t\t\t<td style=\"border: 0px solid rgb(0, 0, 0); width: 1059px; height: 20px;\">\n" +
						"\t\t\t\t<p style=\"line-height: 19.2px; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\">"
						+ "<span style=\"font-size: 12pt; line-height: 19.2px; margin-top: 0px; margin-bottom: 0px; font-family: &quot;맑은 고딕&quot;;\">&nbsp; &nbsp; &nbsp;&nbsp;</span>"
						+ "<span style=\"font-size: 12pt; line-height: 19.2px; margin-top: 0px; margin-bottom: 0px; font-family: &quot;맑은 고딕&quot;;\">양식 D 204 - 02 - 01&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; "
						+ "&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;&nbsp;</span>"
						+ "<span style=\"font-size: 12pt; line-height: 19.2px; margin-top: 0px; margin-bottom: 0px; font-family: &quot;맑은 고딕&quot;;\">깨끗한나라</span>"
						+ "<span style=\"text-align: center; font-size: 10pt; line-height: 16px; margin-top: 0px; margin-bottom: 0px; font-family: &quot;맑은 고딕&quot;;\">(주)&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; "
						+ "&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;&nbsp;</span>"
						+ "<span style=\"font-size: 12pt; line-height: 19.2px; margin-top: 0px; margin-bottom: 0px; font-family: &quot;맑은 고딕&quot;;\">A4(297 x 210)</span></p>\n" +
						"\t\t\t</td>\n" +
						"\t\t</tr>\n" +
						"\t</tbody>\n" +
						"</table>"+
				"</body></html>";
//		    html  = StringEscapeUtils.escapeHtml(html);
		return html;
	}



	/**
	 * 페기
	 * @param1
	 * @return
	 */
	public String getDisposalHtml(DataMap param, List<DataMap> list) {
		SimpleDateFormat sdt = new SimpleDateFormat("yyyyMMdd");
		Calendar sc = Calendar.getInstance();
		String sTime = sdt.format(sc.getTime());
		String YYYY = sTime.substring(0,4);
		String MM = sTime.substring(4,6);
		String DD = sTime.substring(6,8);

		String html = "<html><head></head><body> " +
				"<p style=\"line-height: 19.2px; text-align: center; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><br></p>\n" +
				"  <p style=\"line-height: 19.2px; text-align: center; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\">"
				+ "<strong style=\"font-size: 14pt;\">제목의 건, 아래와 같이 품의 하오니 검토 후 재가 바랍니다.</strong></p>\n" +
				"  <p style=\"line-height: 19.2px; text-align: center; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><br></p>\n" +
				"  <p style=\"line-height: 19.2px; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><br></p>\n" +
				"  <p style=\"line-height: 19.2px; text-align: center; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\">"
				+ "<strong style=\"font-size: 14pt;\">- 아 래 -</strong></p>\n" +
				"  <p style=\"line-height: 19.2px; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><br></p>\n" +
				"  <p style=\"line-height: 19.2px; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><strong style=\"font-size: 14pt;\">1.내 용:</strong></p>\n" +
				"  <p style=\"line-height: 19.2px; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"></p>\n" +
				"  <p style=\"line-height: 19.2px; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><strong style=\"font-size: 14pt;\">2.완제품 폐기 목록:&nbsp;</strong></p>"+
				"<table border=\"0\" cellspacing=\"0\" cellpadding=\"0\" style=\"word-break: break-all; width: 1060px; height: 20px; font-size: 12pt; border-collapse: collapse; border: 0px none rgb(0, 0, 0);\">\n" +
				"\t<tbody>\n" +
				"\t\t<tr>\n" +
				"\t\t</tr>\n" +
				"\t\t<tr>\n" +
				"\t\t</tr>\n" +
				"\t\t<tr>\n" +
				"\t\t</tr>\n" +
				"\t\t<tr>\n" +
				"\t\t</tr>\n" +
				"\t</tbody>\n" +
				"</table>\n" +
				"  <p style=\"line-height: 19.2px; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><br></p>\n" +
				"  \n" +
				"<table border=\"1\" cellspacing=\"0\" cellpadding=\"0\" style=\"word-break: break-all; width: 1046px; font-size: 12pt; border-collapse: collapse; border: 1px none rgb(0, 0, 0); /*height: 174px;*/\">\n" +
				"\t<tbody>\n" +
				"\t\t<tr style=\"height:55px\">\n" +
				"\t\t\t<td style=\"border: 0px solid rgb(0, 0, 0); width: 10px; height: 25px;\">\n" +
				"\t\t\t\t<p style=\"line-height: 19.2px; text-align: center; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\">"
				+ "<span style=\"font-size: 12pt; line-height: 25.6px; margin-top: 0px; margin-bottom: 0px; font-family: &quot;맑은 고딕&quot;;\"><br></span></p>\n" +
				"\t\t\t</td>\n" +
				"\t\t\t<td style=\"border:1px solid rgb(0,0,0);width:291px;height:55px;background-color:rgb(226,226,226)\">\n" +
				"\t\t\t\t<p style=\"line-height: 19.2px; text-align: center; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\">"
				+ "<span style=\"font-size: 12pt; line-height: 25.6px; margin-top: 0px; margin-bottom: 0px; font-family: &quot;맑은 고딕&quot;;\">자재 코드</span></p>\n" +
				"\t\t\t</td>\n" +
				"\t\t\t<td style=\"border:1px solid rgb(0,0,0);width:591px;height:55px;background-color:rgb(226,226,226);\">\n" +
				"\t\t\t\t<p style=\"line-height: 19.2px; text-align: center; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\">"
				+ "<span style=\"font-size: 12pt; line-height: 25.6px; margin-top: 0px; margin-bottom: 0px; font-family: &quot;맑은 고딕&quot;;\">제품명</span></p>\n" +
				"\t\t\t</td>\n" +
				"\t\t\t<td style=\"border:1px solid rgb(0,0,0);width:247px;height:55px;background-color:rgb(226,226,226)\">\n" +
				"\t\t\t\t<p style=\"line-height: 19.2px; text-align: center; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\">"
				+ "<span style=\"font-size: 12pt; line-height: 25.6px; margin-top: 0px; margin-bottom: 0px; font-family: &quot;맑은 고딕&quot;;\">수량(BAG)</span></p>\n" +
				"\t\t\t</td>\n" +
				"\t\t\t<td style=\"border:1px solid rgb(0,0,0);width:150px;height:55px;background-color:rgb(226,226,226)\">\n" +
				"\t\t\t\t<p style=\"line-height: 19.2px; text-align: center; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\">"
				+ "<span style=\"font-size: 12pt; line-height: 25.6px; margin-top: 0px; margin-bottom: 0px; font-family: &quot;맑은 고딕&quot;;\">생산호기</span></p>\n" +
				"\t\t\t</td>\n" +
				"\t\t\t<td style=\"border:1px solid rgb(0,0,0);width:597px;height:55px;background-color:rgb(226,226,226)\">\n" +
				"\t\t\t\t<p style=\"line-height: 19.2px; text-align: center; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\">"
				+ "<span style=\"font-size: 12pt; line-height: 25.6px; margin-top: 0px; margin-bottom: 0px; font-family: &quot;맑은 고딕&quot;;\">폐기사유</span></p>\n" +
				"\t\t\t</td>\n" +
				"\t\t\t<td style=\"border:1px solid rgb(0,0,0);width:297px;height:55px;background-color:rgb(226,226,226)\">\n" +
				"\t\t\t\t<p style=\"line-height: 19.2px; text-align: center; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\">"
				+ "<span style=\"font-size: 12pt; line-height: 25.6px; margin-top: 0px; margin-bottom: 0px; font-family: &quot;맑은 고딕&quot;;\">비고</span></p>\n" +
				"\t\t\t</td>\n" +
				"\t\t</tr>\n" ;
		// 줄
		for(DataMap m: list){
			Object mapInfo =  m.get("map");
			DataMap info = new DataMap();
			if(mapInfo!=null && !"".equals(mapInfo)) {info = (DataMap) mapInfo;}
			else info  = m;

			html+="\t\t<tr style=\"height:55px;\">\n" +
					"\t\t\t<td style=\"border: 0px solid rgb(0, 0, 0); width: 10px; height: 25px;\">\n" +
					"\t\t\t\t<p style=\"line-height: 19.2px; text-align: center; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\">"
					+ "<span style=\"font-size: 16pt; line-height: 25.6px; margin-top: 0px; margin-bottom: 0px; font-family: &quot;맑은 고딕&quot;;\"><br></span></p>\n" +
					"\t\t\t</td>\n" +
					"\t\t\t<td style=\"border: 1px solid rgb(0, 0, 0); width: 291px; height: 25px;\">\n" +
					"\t\t\t\t<p style=\"line-height: 19.2px; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;text-align:center\">"+info.getString("MATNR")+"<br></p>\n" +
					"\t\t\t</td>\n" +
					"\t\t\t<td style=\"border: 1px solid rgb(0, 0, 0); width: 92px; height: 25px;\">\n" +
					"\t\t\t\t<p style=\"line-height: 19.2px; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;text-align:center\">"+info.getString("MATNR_NM")+"<br></p>\n" +
					"\t\t\t</td>\n" +
					"\t\t\t<td style=\"border: 1px solid rgb(0, 0, 0); width: 247px; height: 25px;\">\n" +
					"\t\t\t\t<p style=\"line-height: 19.2px; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;text-align:center\">"+ info.getString("DISPO_QTY")+"<br></p>\n" +
					"\t\t\t</td>\n" +
					"\t\t\t<td style=\"border: 1px solid rgb(0, 0, 0); width: 113px; height: 25px;\">\n" +
					"\t\t\t\t<p style=\"line-height: 19.2px; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;text-align:center\">"+info.getString("MACHINE")+"<br></p>\n" +
					"\t\t\t</td>\n" +
					"\t\t\t<td style=\"border: 1px solid rgb(0, 0, 0); width: 297px; height: 25px;\">\n" +
					"\t\t\t\t<p style=\"line-height: 19.2px; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;text-align:left\">"+info.getString("DISPO_CAUSE")+"<br></p>\n" +
					"\t\t\t</td>\n" +
					"\t\t\t<td style=\"border: 1px solid rgb(0, 0, 0); width: 297px; height: 25px;\">\n" +
					"\t\t\t\t<p style=\"line-height: 19.2px; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;text-align:left\">"+info.getString("RMK")+"<br></p>\n" +
					"\t\t\t</td>\n" +
					"\t\t</tr>\n" ;
		}
		if(list.size() > 0) {
//			html+="\t\t<tr>\n" +
//					"\t\t\t<td style=\"border: 0px solid rgb(0, 0, 0); width: 10px; height: 45px;\">\n" +
//					"\t\t\t\t<p style=\"line-height: 19.2px; text-align: center; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><span style=\"font-size: 16pt; line-height: 25.6px; margin-top: 0px; margin-bottom: 0px; font-family: &quot;맑은 고딕&quot;;\"><br></span></p>\n" +
//					"\t\t\t</td>\n" +
//					"\t\t\t<td style=\"border: 1px solid rgb(0, 0, 0); width: 291px; height: 21px;\" colspan=\"3\">\n" +
//					"\t\t\t\t<p style=\"line-height: 19.2px; text-aligh:center;font-size: 16pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;text-align:center\"><b>종합결과</b><br></p>\n" +
//					"\t\t\t</td>\n" +
//					"\t\t\t<td style=\"border: 1px solid rgb(0, 0, 0); width: 92px; height: 21px;\">\n" +
//					"\t\t\t\t<p style=\"line-height: 19.2px; font-size: 16pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px; text-align:center\">"+param.getString("FNL_JDGM_NM")+"<br></p>\n" +
//					"\t\t\t</td>\n" +
//					"\t\t\t<td style=\"border: 1px solid rgb(0, 0, 0); width: 297px; height: 21px;\">\n" +
//					"\t\t\t\t<p style=\"line-height: 19.2px; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><br></p>\n" +
//					"\t\t\t</td>\n" +
//					"\t\t</tr>\n" ;
		}else {
			html +="\t\t<tr style=\"height:55px\">\n" +
					"\t\t\t<td style=\"border: 0px solid rgb(0, 0, 0); width: 10px; height: 25px;\">\n" +
					"\t\t\t\t<p style=\"line-height: 19.2px; text-align: center; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\">"
					+ "<span style=\"font-size: 16pt; line-height: 25.6px; margin-top: 0px; margin-bottom: 0px; font-family: &quot;맑은 고딕&quot;;\"><br></span></p>\n" +
					"\t\t\t</td>\n" +
					"\t\t\t<td style=\"border: 1px solid rgb(0, 0, 0); width: 291px; height: 25px;\">\n" +
					"\t\t\t\t<p style=\"line-height: 19.2px; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><br></p>\n" +
					"\t\t\t</td>\n" +
					"\t\t\t<td style=\"border: 1px solid rgb(0, 0, 0); width: 92px; height: 25px;\">\n" +
					"\t\t\t\t<p style=\"line-height: 19.2px; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><br></p>\n" +
					"\t\t\t</td>\n" +
					"\t\t\t<td style=\"border: 1px solid rgb(0, 0, 0); width: 247px; height: 25px;\">\n" +
					"\t\t\t\t<p style=\"line-height: 19.2px; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><br></p>\n" +
					"\t\t\t</td>\n" +
					"\t\t\t<td style=\"border: 1px solid rgb(0, 0, 0); width: 113px; height: 25px;\">\n" +
					"\t\t\t\t<p style=\"line-height: 19.2px; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><br></p>\n" +
					"\t\t\t</td>\n" +
					"\t\t\t<td style=\"border: 1px solid rgb(0, 0, 0); width: 297px; height: 25px;\">\n" +
					"\t\t\t\t<p style=\"line-height: 19.2px; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><br></p>\n" +
					"\t\t\t</td>\n" +
					"\t\t\t<td style=\"border: 1px solid rgb(0, 0, 0); width: 297px; height: 25px;\">\n" +
					"\t\t\t\t<p style=\"line-height: 19.2px; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><br></p>\n" +
					"\t\t\t</td>\n" +
					"\t\t</tr>\n" +
					"\t\t<tr style=\"height:55px\">\n" +
					"\t\t\t<td style=\"border: 0px solid rgb(0, 0, 0); width: 10px; height: 25px;\">\n" +
					"\t\t\t\t<p style=\"line-height: 19.2px; text-align: center; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\">"
					+ "<span style=\"font-size: 16pt; line-height: 25.6px; margin-top: 0px; margin-bottom: 0px; font-family: &quot;맑은 고딕&quot;;\"><br></span></p>\n" +
					"\t\t\t</td>\n" +
					"\t\t\t<td style=\"border: 1px solid rgb(0, 0, 0); width: 291px; height: 25px;\">\n" +
					"\t\t\t\t<p style=\"line-height: 19.2px; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><br></p>\n" +
					"\t\t\t</td>\n" +
					"\t\t\t<td style=\"border: 1px solid rgb(0, 0, 0); width: 92px; height: 25px;\">\n" +
					"\t\t\t\t<p style=\"line-height: 19.2px; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><br></p>\n" +
					"\t\t\t</td>\n" +
					"\t\t\t<td style=\"border: 1px solid rgb(0, 0, 0); width: 247px; height: 25px;\">\n" +
					"\t\t\t\t<p style=\"line-height: 19.2px; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><br></p>\n" +
					"\t\t\t</td>\n" +
					"\t\t\t<td style=\"border: 1px solid rgb(0, 0, 0); width: 113px; height: 25px;\">\n" +
					"\t\t\t\t<p style=\"line-height: 19.2px; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><br></p>\n" +
					"\t\t\t</td>\n" +
					"\t\t\t<td style=\"border: 1px solid rgb(0, 0, 0); width: 297px; height: 25px;\">\n" +
					"\t\t\t\t<p style=\"line-height: 19.2px; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><br></p>\n" +
					"\t\t\t</td>\n" +
					"\t\t\t<td style=\"border: 1px solid rgb(0, 0, 0); width: 297px; height: 25px;\">\n" +
					"\t\t\t\t<p style=\"line-height: 19.2px; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><br></p>\n" +
					"\t\t\t</td>\n" +
					"\t\t</tr>\n" +
					"\t\t<tr style=\"height:55px\">\n" +
					"\t\t\t<td style=\"border: 0px solid rgb(0, 0, 0); width: 10px; height: 25px;\">\n" +
					"\t\t\t\t<p style=\"line-height: 19.2px; text-align: center; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\">"
					+ "<span style=\"font-size: 16pt; line-height: 25.6px; margin-top: 0px; margin-bottom: 0px; font-family: &quot;맑은 고딕&quot;;\"><br></span></p>\n" +
					"\t\t\t</td>\n" +
					"\t\t\t<td style=\"border: 1px solid rgb(0, 0, 0); width: 291px; height: 25px;\">\n" +
					"\t\t\t\t<p style=\"line-height: 19.2px; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><br></p>\n" +
					"\t\t\t</td>\n" +
					"\t\t\t<td style=\"border: 1px solid rgb(0, 0, 0); width: 92px; height: 25px;\">\n" +
					"\t\t\t\t<p style=\"line-height: 19.2px; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><br></p>\n" +
					"\t\t\t</td>\n" +
					"\t\t\t<td style=\"border: 1px solid rgb(0, 0, 0); width: 247px; height: 25px;\">\n" +
					"\t\t\t\t<p style=\"line-height: 19.2px; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><br></p>\n" +
					"\t\t\t</td>\n" +
					"\t\t\t<td style=\"border: 1px solid rgb(0, 0, 0); width: 113px; height: 25px;\">\n" +
					"\t\t\t\t<p style=\"line-height: 19.2px; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><br></p>\n" +
					"\t\t\t</td>\n" +
					"\t\t\t<td style=\"border: 1px solid rgb(0, 0, 0); width: 297px; height: 25px;\">\n" +
					"\t\t\t\t<p style=\"line-height: 19.2px; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><br></p>\n" +
					"\t\t\t</td>\n" +
					"\t\t\t<td style=\"border: 1px solid rgb(0, 0, 0); width: 297px; height: 25px;\">\n" +
					"\t\t\t\t<p style=\"line-height: 19.2px; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><br></p>\n" +
					"\t\t\t</td>\n" +
					"\t\t</tr>\n" +
					"\t\t<tr style=\"height:55px;\">\n" +
					"\t\t\t<td style=\"border: 0px solid rgb(0, 0, 0); width: 10px; height: 25px;\">\n" +
					"\t\t\t\t<p style=\"line-height: 19.2px; text-align: center; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\">"
					+ "<span style=\"font-size: 16pt; line-height: 25.6px; margin-top: 0px; margin-bottom: 0px; font-family: &quot;맑은 고딕&quot;;\"><br></span></p>\n" +
					"\t\t\t</td>\n" +
					"\t\t\t<td style=\"border: 1px solid rgb(0, 0, 0); width: 291px; height: 25px;\">\n" +
					"\t\t\t\t<p style=\"line-height: 19.2px; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><br></p>\n" +
					"\t\t\t</td>\n" +
					"\t\t\t<td style=\"border: 1px solid rgb(0, 0, 0); width: 92px; height: 25px;\">\n" +
					"\t\t\t\t<p style=\"line-height: 19.2px; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><br></p>\n" +
					"\t\t\t</td>\n" +
					"\t\t\t<td style=\"border: 1px solid rgb(0, 0, 0); width: 247px; height: 25px;\">\n" +
					"\t\t\t\t<p style=\"line-height: 19.2px; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><br></p>\n" +
					"\t\t\t</td>\n" +
					"\t\t\t<td style=\"border: 1px solid rgb(0, 0, 0); width: 113px; height: 25px;\">\n" +
					"\t\t\t\t<p style=\"line-height: 19.2px; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><br></p>\n" +
					"\t\t\t</td>\n" +
					"\t\t\t<td style=\"border: 1px solid rgb(0, 0, 0); width: 297px; height: 25px;\">\n" +
					"\t\t\t\t<p style=\"line-height: 19.2px; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><br></p>\n" +
					"\t\t\t</td>\n" +
					"\t\t\t<td style=\"border: 1px solid rgb(0, 0, 0); width: 297px; height: 25px;\">\n" +
					"\t\t\t\t<p style=\"line-height: 19.2px; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><br></p>\n" +
					"\t\t\t</td>\n" +
					"\t\t</tr>\n" +
					"\t\t<tr style=\"height:55px\">\n" +
					"\t\t\t<td style=\"border: 0px solid rgb(0, 0, 0); width: 10px; height: 25px;\">\n" +
					"\t\t\t\t<p style=\"line-height: 19.2px; text-align: center; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\">"
					+ "<span style=\"font-size: 16pt; line-height: 25.6px; margin-top: 0px; margin-bottom: 0px; font-family: &quot;맑은 고딕&quot;;\"><br></span></p>\n" +
					"\t\t\t</td>\n" +
					"\t\t\t<td style=\"border: 1px solid rgb(0, 0, 0); width: 291px; height: 25px;\">\n" +
					"\t\t\t\t<p style=\"line-height: 19.2px; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><br></p>\n" +
					"\t\t\t</td>\n" +
					"\t\t\t<td style=\"border: 1px solid rgb(0, 0, 0); width: 92px; height: 25px;\">\n" +
					"\t\t\t\t<p style=\"line-height: 19.2px; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><br></p>\n" +
					"\t\t\t</td>\n" +
					"\t\t\t<td style=\"border: 1px solid rgb(0, 0, 0); width: 247px; height: 25px;\">\n" +
					"\t\t\t\t<p style=\"line-height: 19.2px; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><br></p>\n" +
					"\t\t\t</td>\n" +
					"\t\t\t<td style=\"border: 1px solid rgb(0, 0, 0); width: 113px; height: 25px;\">\n" +
					"\t\t\t\t<p style=\"line-height: 19.2px; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><br></p>\n" +
					"\t\t\t</td>\n" +
					"\t\t\t<td style=\"border: 1px solid rgb(0, 0, 0); width: 113px; height: 25px;\">\n" +
					"\t\t\t\t<p style=\"line-height: 19.2px; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><br></p>\n" +
					"\t\t\t</td>\n" +
					"\t\t\t<td style=\"border: 1px solid rgb(0, 0, 0); width: 297px; height: 25px;\">\n" +
					"\t\t\t\t<p style=\"line-height: 19.2px; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><br></p>\n" +
					"\t\t\t</td>\n" +
					"\t\t</tr>\n";
		}
		// 줄 END
		html +="\t</tbody>\n" +
				"</table>\n" +
//				"<p style=\"line-height: 19.2px; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><br></p><p style=\"line-height: 19.2px; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><br></p><p style=\"line-height: 19.2px; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><br></p><p style=\"line-height: 19.2px; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><br></p><p style=\"line-height: 19.2px; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><br></p><p style=\"line-height: 19.2px; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><br></p><p style=\"line-height: 19.2px; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><br></p><p style=\"line-height: 19.2px; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><br></p><p style=\"line-height: 19.2px; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><br></p><p style=\"line-height: 19.2px; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><br></p>\n" +
				"      \n" +
//				"<table border=\"0\" cellspacing=\"0\" cellpadding=\"0\" style=\"word-break: break-all; width: 1048px; height: 80px; font-size: 12pt; border: 0px none rgb(0, 0, 0); border-collapse: collapse;\">\n" +
//				"\t<tbody>\n" +
//				"\t\t<tr>\n" +
//				"\t\t\t<td colspan=\"8\" style=\"border: 0px solid rgb(0, 0, 0); width: 768px; height: 20px;\">\n" +
//				"\t\t\t\t<p style=\"line-height: 19.2px; text-align: center; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><br></p><p style=\"line-height: 19.2px; text-align: center; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><strong style=\"font-size: 16pt;\">상기와 같이 검사를 통보합니다.</strong></p><p style=\"line-height: 19.2px; text-align: center; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><br></p>\n" +
//				"\t\t\t</td>\n" +
//				"\t\t</tr>\n" +
//				"\t\t<tr>\n" +
//				"\t\t\t<td colspan=\"8\" style=\"border: 0px solid rgb(0, 0, 0); width: 596px; height: 20px;\">\n" +
//				"\t\t\t\t<p style=\"line-height: 19.2px; text-align: right; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><br></p><p style=\"line-height: 19.2px; text-align: right; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><span style=\"font-size: 12pt; line-height: 19.2px; margin-top: 0px; margin-bottom: 0px; font-family: &quot;맑은 고딕&quot;;\"><br></span></p><p style=\"line-height: 19.2px; text-align: right; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><span style=\"font-size: 12pt; line-height: 19.2px; margin-top: 0px; margin-bottom: 0px; font-family: &quot;맑은 고딕&quot;;\"><br></span></p><p style=\"line-height: 19.2px; text-align: right; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><span style=\"font-size: 14pt; line-height: 22.4px; margin-top: 0px; margin-bottom: 0px; font-family: &quot;맑은 고딕&quot;;\">"+YYYY+"년&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; "+MM+"월&nbsp; &nbsp; &nbsp; &nbsp; &nbsp;"+DD+"일&nbsp;</span><span style=\"font-size: 12pt; line-height: 19.2px; margin-top: 0px; margin-bottom: 0px; font-family: &quot;맑은 고딕&quot;;\">&nbsp; &nbsp;</span></p><p style=\"line-height: 19.2px; text-align: right; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><br></p><p style=\"line-height: 19.2px; text-align: right; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><br></p><p style=\"line-height: 19.2px; text-align: right; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><br></p>\n" +
//				"\t\t\t</td>\n" +
//				"\t\t</tr>\n" +
//				"\t\t<tr>\n" +
//				"\t\t\t<td colspan=\"8\" style=\"border: 0px solid rgb(0, 0, 0); width: 768px; height: 20px;\">\n" +
//				"\t\t\t\t<p style=\"line-height: 19.2px; text-align: center; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><br></p><p style=\"line-height: 19.2px; text-align: center; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><strong style=\"font-size: 16pt;\">품질관리팀 (인)</strong></p><p style=\"line-height: 19.2px; text-align: center; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><br></p>\n" +
//				"\t\t\t</td>\n" +
//				"\t\t</tr>\n" +
//				"\t</tbody>\n" +
//				"</table>\n" +
//				"<p style=\"line-height: 19.2px; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><br></p><p style=\"line-height: 19.2px; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><br></p><p style=\"line-height: 19.2px; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><br></p><p style=\"line-height: 19.2px; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><br></p>\n" +
//				"\t\t\t</td>\n" +
//				"\t\t</tr>\n" +
//				"\t\t<tr>\n" +
//				"\t\t\t<td style=\"border: 0px solid rgb(0, 0, 0); width: 1059px; height: 20px;\">\n" +
//				"\t\t\t\t<p style=\"line-height: 19.2px; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><span style=\"font-size: 12pt; line-height: 19.2px; margin-top: 0px; margin-bottom: 0px; font-family: &quot;맑은 고딕&quot;;\">&nbsp; &nbsp; &nbsp;&nbsp;</span><span style=\"font-size: 12pt; line-height: 19.2px; margin-top: 0px; margin-bottom: 0px; font-family: &quot;맑은 고딕&quot;;\">양식 D 204 - 02 - 01&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;&nbsp;</span><span style=\"font-size: 12pt; line-height: 19.2px; margin-top: 0px; margin-bottom: 0px; font-family: &quot;맑은 고딕&quot;;\">깨끗한나라</span><span style=\"text-align: center; font-size: 10pt; line-height: 16px; margin-top: 0px; margin-bottom: 0px; font-family: &quot;맑은 고딕&quot;;\">(주)&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;&nbsp;</span><span style=\"font-size: 12pt; line-height: 19.2px; margin-top: 0px; margin-bottom: 0px; font-family: &quot;맑은 고딕&quot;;\">A4(297 x 210)</span></p>\n" +
//				"\t\t\t</td>\n" +
//				"\t\t</tr>\n" +
//				"\t</tbody>\n" +
//				"</table>"+
				"  <p style=\"line-height: 10px; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><strong style=\"font-size: 14pt;\"></strong></p>"+
				"  <p style=\"line-height: 19.2px; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><strong style=\"font-size: 14pt;\">3.담당자 의견 :&nbsp;</strong></p>"+
				"  <p style=\"line-height: 19.2px; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><strong style=\"font-size: 14pt;\"></strong></p>"+
				"  <p style=\"line-height: 19.2px; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><strong style=\"font-size: 14pt;\"></strong></p>"+
				"  <p style=\"line-height: 19.2px; font-size: 12pt; font-family: &quot;맑은 고딕&quot;; margin-top: 0px; margin-bottom: 0px;\"><strong style=\"font-size: 14pt;\"></strong></p>"+
				"</body></html>";
//		    html  = StringEscapeUtils.escapeHtml(html);
		return html;
	}


	public static void main(String args[]) {
		SsoGwService s = new SsoGwService();
		boolean m = s.isSsoEpUser("hnw.shyou", "hnw.shyou1");
		System.out.println(m);
	}

	// 결제중인 건이 존재 하는지 체크
	public boolean haveAprving(List<DataMap> list) throws SQLException {
		boolean isApprv = false;
		for(DataMap info: list) {
			DataMap m = (DataMap) info.get("map");
			m.setModuleCommand("mes", "MES003DOCID");
			DataMap m2 = commonDao.getMap(m);
			String state = m2.getString("APVR_STA");
			
			if("1".equals(state) || "2".equals(state) || "3".equals(state)) {
				isApprv = true;
				break;
			}
		}
		return isApprv;
	}
}