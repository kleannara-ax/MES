package project.common.bean;

import project.mes.util.CommonUtil;

public class CommonConfig {
//	public final static String sessionDupUseyn="N"; // 다중로그인 적용여부, properties에 옮김

	public final static String SSO_PRODUCT_ID = "PRO_000621";
	public final static String SSO_SITE_URL = "mes.kleannara.com";

	// 운영
	public final static String SSO_SITE1 = "https://sso.kleannara.com";
	public final static String MES_SITE1 = "https://mes.kleannara.com";
	public final static String GW_SITE1 = "https://gw.kleannara.com";

	// 개발
	public final static String SSO_SITE = "https://ssodev.kleannara.com";
	public final static String MES_SITE = "https://mesdev.kleannara.com";
	public final static String GW_SITE = "https://gwdev.kleannara.com";
	
	public final static String REAL_SERVER_IP0 = "10.2.14.190";
	//개발자IP
	//public final static String REAL_SERVER_IP0 = "192.1.1.79";
	
	// 운영서버 IP
	public final static String REAL_SERVER_IP = "10.2.14.191";
	public final static String REAL_SERVER_IP1 = "10.2.14.192";

	public static boolean isRealServer () {
		return CommonUtil.getIp().equals(REAL_SERVER_IP) || CommonUtil.getIp().equals(REAL_SERVER_IP1);
	}

	public static boolean isDevServer () {
		return CommonUtil.getIp().equals(REAL_SERVER_IP0);
	}

	public static String getSSO_SITE(){
		if(isRealServer()) return SSO_SITE1;
		return SSO_SITE;
	}

	public static String getMES_SITE(){
		if(isRealServer()) return MES_SITE1;
		return MES_SITE;
	}

	public static String getGW_SITE(){
		if(isRealServer())  return GW_SITE1;
		return GW_SITE;
	}

	public final static String COMMAND_ATT_KEY = "commandKey";
	public final static String MODULE_ATT_KEY = "moduleKey";
	public final static String COMMAND_LIST_TAIL = "_LIST";
	public final static String COMMAND_MAP_TAIL = "_MAP";
	public final static String COMMAND_COUNT_TAIL = "_COUNT";
	public final static String COMMAND_OBJECT_TAIL = "_OBJECT";
	public final static String COMMAND_INSERT_TAIL = "_INSERT";
	public final static String COMMAND_UPDATE_TAIL = "_UPDATE";
	public final static String COMMAND_DELETE_TAIL = "_DELETE";
	public final static String COMMAND_VALIDATION_TAIL = "_VALIDATION";
	public final static String MENU_ID_KEY = "menuId";
	public final static String MENU_NM_KEY = "menuNm";
	public final static String PARAM_ATT_KEY = "ParamData";
	public final static String DEFAULT_DATA_KEY = "data";
	public final static String LIST_PAGE_SELECT_NUM_KEY = "listPageNumKey";
	public final static String LIST_PAGE_COUNT_NUM_KEY = "listPageCountKey";
	public final static String LIST_PAGE_TOTAL_COUNT_KEY = "listPageTotalCountKey";	
	public final static String LIST_PAGE_REQUEST_TYPE_KEY = "listPageRequestTypeKey";	
	public final static String DATA_ROW_STATE_KEY = "dataRowState";
	public final static String DATA_EXCEL_REQUEST_KEY = "dataExcelRequest";
	public final static String DATA_EXCEL_REQUEST_FILE_NAME = "dataGridExcel";
	public final static String DATA_EXCEL_LABEL_KEY = "dataExcelLabel";
	public final static String DATA_EXCEL_MULTI_LABEL_KEY = "dataExcelMultiLabel";
	public final static String DATA_EXCEL_FORMAT_KEY = "dataExcelFormat";
	public final static String DATA_EXCEL_FORMAT_NUMBER_KEY = "dataExcelFormatNumber";
	public final static String DATA_EXCEL_LABEL_ORDER_KEY = "dataExcelLabelOrder";
	public final static String DATA_EXCEL_WIDTH_KEY = "dataExcelWidth";
	public final static String DATA_EXCEL_COLNAME_ROWNUM_KEY = "dataExcelColnameRownum";
	public final static String DATA_EXCEL_CSV_KEY = "dataExcelCsvType";
	public final static String DATA_EXCEL_TEXT_KEY = "dataExcelTextType";
	public final static String DATA_EXCEL_DELIMITER_KEY = "dataExcelDelimiter";
	public final static String DATA_EXCEL_X_KEY = "dataExcelXType";
	public final static String DATA_EXCEL_LABEL_VIEW = "dataExcelLabelView";
	public final static String DATA_EXCEL_COL_KEY_VIEW = "dataExcelColKeyView";
	public final static String DATA_EXCEL_COMBO_DATA_KEY = "gridExcelComboData";
	public final static String DATA_EXCEL_REQUEST_MAXROW_KEY = "dataExcelRequestMaxrow";
	public final static String DATA_EXCEL_FONT_NAME = "Verdana";
	public final static String DATA_FORMAT_PARAM_ATT_KEY = "dataFormatParam";
	public final static String DATA_FORMAT_STRING = "S";
	public final static String DATA_FORMAT_NUMBER = "N";
	public final static String DATA_FORMAT_DATE = "D";
	public final static String DATA_FORMAT_TIME = "T";
	public final static String DATA_FORMAT_CALENDER = "C";
	public final static String DATA_FORMAT_DATETIME = "DT";
	public final static String DATA_FORMAT_DTS = "DTS";
	public final static String DATA_FORMAT_DATETIMESECOND = "DTS";
	
	public final static String VIEW_FORMAT_DATE = "yyyy-MM-dd";
	public final static String VIEW_FORMAT_TIME = "HH:mm:ss";
	public final static String VIEW_FORMAT_DATETIME = "yyyy-MM-dd HH:mm";
	public final static String VIEW_FORMAT_DTS = "yyyy-MM-dd HH:mm:ss";
	public final static String VIEW_FORMAT_EXCEL_INT = "#,##0";
	public final static String VIEW_FORMAT_EXCEL_NUM = "#,###.##############################";
	public final static String VIEW_FORMAT_DATETIMESECOND = "yyyy-MM-dd HH:mm:ss";
	
	public final static String SES_USER_OBJECT_KEY = "SES_USER_OBJECT";
	public final static String SES_USER_ID_CHK_KEY = "SES_USER_CHK_ID"; //사용자 확인 ID
	public final static String SES_USER_ID_KEY = "SES_USER_ID"; //사용자ID
	public final static String SES_USER_TYPE_KEY = "SES_USER_TYPE_ID"; //사용자 계정 관리 type
	public final static String SES_USER_PW_KEY = "SES_USER_PW"; //사용자PW
	public final static String SES_LOGIN_ID_KEY = "SES_LOGIN_ID"; //로그인ID
	public final static String SES_MENU_GROUP_KEY = "SES_MENU_GROUP_KEY"; //메뉴그룹키
	public final static String SES_USER_LANGUAGE_KEY = "SES_LANGUAGE";//사용자기본언어
	public final static String SES_USER_WAREHOUSE_LANGUAGE_KEY = "SES_WAREKY_LANGUAGE";//창고기본언어
	public final static String SES_USER_OWNER_NATNKY_KEY = "SES_OWNER_NATION";//화주 기본 국가
	public final static String SES_USER_NAME_KEY = "SES_USER_NAME"; //사용자명
	public final static String SES_DEPT_SEQ_KEY   = "SES_DEPT_SEQ"; //사용자대표부서SEQ
	public final static String SES_DEPT_ID_KEY   = "SES_DEPT_ID"; //사용자대표부서ID
	public final static String SES_DEPT_NM_KEY   = "SES_DEPT_NM"; //사용자대표부서명
	public final static String SES_JPOS_ID_KEY   = "SES_JPOS_ID"; //사용자대표직위ID
	public final static String SES_JPOS_NM_KEY   = "SES_JPOS_NM"; //사용자대표직위명
	public final static String SES_DUTY_ID_KEY   = "SES_DUTY_ID"; //사용자대표직책ID
	public final static String SES_DUTY_NM_KEY   = "SES_DUTY_NM"; //사용자대표직책명
	public final static String SES_USER_COMPANY_KEY    = "SES_USER_COMPANY"; //회사ID
	public final static String SES_USER_A_COMPANY_KEY    = "SES_USER_A_COMPANY"; //고객사인경우 소속 회사ID
	public final static String SES_USER_COMPANY_NM_KEY 	   = "SES_USER_COMPANY_NM"; //회사명
	public final static String SES_USER_COMPANY_TYPE   = "SES_USER_COMPANY_TYPE"; //웹운영사,웹고객사,웹공급사,웹공통,모바일운영사,모바일고객사,모바일공급사-공통코드값으로 들어감
	public final static String SES_COMPANY_TYPE = "SES_COMPANY_TYPE"; //운영사,고객사,공급사,배송사
	public final static String SES_DEVICE_TYPE  = "SES_DEVICE_TYPE"; //MOBILE(M),PDA(P),WEB(W)
	public final static String SES_USER_CP_BZPSREGNO_KEY = "SES_USER_COMPANY_BIZ_REG_NO"; //회사사업자등록번호
	public final static String SES_USER_CP_CORPREGNO_KEY = "SES_USER_COMPANY_CPRP_REG_NO"; //회사법인등록번호
	public final static String SES_USER_OWNER_KEY      = "SES_OWNER";//회사대표자명
	public final static String SES_USER_PLANT_KEY      = "SES_PLNTKY";//플랜트
	public final static String SES_USER_WHAREHOUSE_KEY = "SES_WAREKY";//창고
	public final static String SES_USER_WHAREHOUSE_NM_KEY = "SES_WARENMKY";//창고명
	public final static String SES_USER_WHAREHOUSE_NEW_NM_KEY = "SES_WARENEWNMKY";//세션변경된 창고명
	public final static String SES_USER_LAYOUT_LIST_KEY = "SES_USER_LAYOUT";
	public final static String SES_USER_SEARCHPARAM_LIST_KEY = "SES_USER_SEARCHPARAM";
	public final static String SES_USER_SEARCHPARAM_DEFAULT_KEY = "SES_USER_SEARCHPARAM_DEFAULT";
	public final static String SES_USER_EMPL_ID_KEY = "SES_USER_EMPL_ID";
	public final static String SES_USER_INFO_KEY = "SES_USER_INFO_ID";
	public final static String SES_USER_IP_KEY = "SES_USER_IP";//접속IP
	public final static String SES_USER_ID_FORCERT_KEY = "SES_USER_ID_FORCERT";
	public final static String SES_USER_ACTION_HEAD_KEY = "SES_ACTION_";
	public final static String FILE_UPLOAD_PARAM_DATA= "FILE_UPLOAD_PARAM_DATA";//파일 업로드시 세션
	public final static String SES_USER_ROOT_MENU_KEY = "SES_ROOT_USER_MENU"; //사용자  최상위 메뉴
	public final static String SES_USER_MENU_KEY = "SES_USER_MENU"; //사용자 메뉴
	public final static String SES_USER_FMENU_KEY = "SES_USER_FMENU"; //사용자  즐겨찾기 메뉴
	public final static String SES_USER_URL_KEY = "SES_USER_URL"; //사용자 사용 가능 url
	public final static String SES_CURR_MENU_AUTH = "SES_MENU_AUTH";//접속메뉴
	public final static String SES_UROLKY      		= "SES_UROLKY";			//사용자 권한키 1.조회 2.조회+저장 3.ALL
	public final static String SES_USER_IP_GUBUN 	= "SES_USER_GUBUN";		//기존 접속여부 true, false
	
	public final static String SES_ROOT_COMP_LIST = "SES_ROOT_COMP_LIST";//권할별 회사 리스트
	public final static String SES_ROOT_COMPID = "SES_ROOT_COMPID";//선택된 회사 코드
	public final static String SES_ROOT_COMP_MENULIST = "SES_ROOT_COMP_MENULIST";//회사별 root 메뉴 리스트
	public final static String SES_ROOT_MENUID = "SES_ROOT_MENUID";//선택된 root 메뉴 ID
	public final static String SES_ROOT_MENU_COMPLIST = "SES_ROOT_MENU_COMPLIST";//선택된 root menuid 에서 접근 가능한 회사코드 리스트
	public final static String SES_ROOT_SUB_MENULIST = "SES_ROOT_SUB_MENULIST";//root menuid 하위의 메뉴 리스트
	public final static String SES_ROOT_SUB_MENU = "SES_ROOT_SUB_MENU";//root menuid 하위의 선택된 menu
	
	public final static String FILE_MAP_KEY = "COMMON_FILE_MAP";
	public final static String FILELIST_KEY = "fileList";
	//public final static String FILENAMELIST_KEY = "fileNameList";
	public final static String FILEINFOLIST_KEY = "fileInfoList";
	public final static String FILEGROUP_KEY = "fileGroup";
	public final static String FILE_MODULE = "System";
	public final static String FILE_TABLE_NAME = "SYSFILE";
	public final static String FILE_THUMBNAIL_TABLE_NAME = "SYSFILETN";
	public final static String IMAGE_THUMBNAIL_SIZE_KEY = "imageThumbnailSize";
	
	public final static String FORMAT_DATE_KEY = "FORMAT_DATE";
	public final static String FORMAT_TIME_KEY = "FORMAT_TIME";
	
	public final static String INPUT_SEARCH_PARAM_KET = "inputSearchParam";
	
	public final static String RANGE_SQL_COUNT_KEY = "RANGE_SQL_COUNT";
	public final static String RANGE_SQL_KEY = "RANGE_SQL";
	public final static String RANGE_PRE_SQL_KEY = "RANGE_PRE_SQL";
	public final static String RANGE_PRE_PARAM_KEY = "RANGE_PRE_PARAM";
	public final static String RNAGE_DATA_PARAM_KEY = "RANGE_DATA_PARAM";
	public final static String INPUT_PARAM_GROUP = "PGroup";
	public final static String RANGE_TYPE_SINGLE = "Single";
	public final static String RANGE_TYPE_RANGE = "Range";
	public final static String RNAGE_DATA_MAP = "RANGE_DATA_MAP";
	public final static String RNAGE_LOGICAL_OPERATOR_KEY = "LOGICALOPER";
	public final static String RNAGE_OPERATOR_KEY = "OPER";
	public final static String RNAGE_SINGLE_DATA_KEY = "DATA";
	public final static String RNAGE_FROM_KEY = "FROM";
	public final static String RNAGE_TO_KEY = "TO";
	
	public final static String WHARE_SQL = "WHARE_SQL";

	public final static String VALIDATION_SQL_KEY = "VALIDATION_SQL";
	
	public final static String REQUEST_URI_INFO_KEY = "REQUEST_URI_INFO";
	
	public final static String REQUEST_LAYOUT_INFO_KEY = "REQUEST_LAYOUT_INFO";
	
	public final static String REQUEST_URL = "requestUrl";
	public final static String REQUEST_URI = "requestUri";
	
	public final static String ASYNC_DAO_KEY = "asyncDaoKey";
	public final static String ASYNC_DAO_UUID = "asyncDaoUUID";
	
	public final static String GRID_REQUEST_VIEW_COUNT = "GRequestViewCount";
	public final static String GRID_REQUEST_VALIDATION_KEY = "GRequestValidationKey";
	public final static String GRID_REQUEST_VALIDATION_TYPE = "GRequestValidationType";
	
	public final static String GRID_ROW_STATE_ATT = "GRowState";
	
	public final static String GRID_ROW_DATA_CLONE_KEY = "GRowDataClone";

    public static String SYSTEM_THEME = "";
	public static String SYSTEM_THEME_PATH = "";
	public static String SYSTEM_MAPKEY = "";
	public static String SYSTEM_MAPKEY2 = "";
	public final static String SES_USER_THEME_KEY = "SES_USER_THEME";
	public final static String SES_USER_THEME_COLOR_KEY = "SES_USER_THEME_COLOR";
	
	public final static String DATA_COL_SEPARATOR = "↓";
	public final static String DATA_ROW_SEPARATOR = "↑";
	public final static String DATA_CELL_SEPARATOR = "↕";
	
	public final static String FILE_GROUP_FILE_ID = "HRK_FILE_ID"; //파일 GROUP ID
	
	public final static String EXCEL_DATA_VALIDATION_BEANNAME = "beanName";
	public final static String EXCEL_DATA_VALIDATION_FUNCNAME = "funcName";
	public final static String EXCEL_DATA_VALIDATION_RESULT_CODE = "RESULT_CODE";
	public final static String EXCEL_DATA_VALIDATION_RESULT_MSG = "RESULT_MSG";
	
	public final static String DATA_COL_EMPTY_VALUE = "";
	
	public final static String MEMBERSHIP_APPLY_CODE = "membershipAplcod";
	
	//접속 환경
	public final static String SES_ENV_KEY = "SES_ENV";
	
	//schema
	public final static String SES_SCHEMA = "SES_SCHEMA";

	public final static String SAP_JCO_SYSID = "jco.client.sysid";

	public final static String SES_PROC_CD= "SES_PROC_CD"; //공정코드
	public final static String SES_MACH_CD= "SES_MACH_CD"; //설비코드
	
	// 2022-07-21(목요일) 안상현, 작업반 추가
	public final static String SES_WRK_CLASS = "SES_WRK_CLASS";
}