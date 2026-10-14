ConfigData = function() {
	this.PERFORMANCE_TRACE_ADVICE = false; //데이터 바인드 성능을 화면에 출력할지 결정한다.
	this.START_TIME;
	this.DEBUG_MODE = false;
	
	this.MAX_MENU_TAB = 10;
	
	this.DATA_COL_SEPARATOR = "↓";
	this.DATA_ROW_SEPARATOR = "↑";
	this.DATA_CELL_SEPARATOR = "↕";
	
	this.COMMON_MENU_ID_KEY = "menuId";
	
	this.COMMON_DATE_TYPE = "yyyy-mm-dd";
	this.COMMON_DATE_TYPE_UI = "yy-mm-dd";
	this.COMMON_DATE_MONTH_TYPE = "yyyy-mm"; // 2019.03.07 jw : : Input Data Type Month Added
	this.COMMON_DATE_MONTH_TYPE_UI = "yy-mm"; // 2019.03.07 jw : : Input Data Type Month Added
	this.COMMON_TIME_TYPE = "HH:MM:SS";
	this.COMMON_DATETIME_TYPE = "yyyy-mm-dd HH:MM";
	this.COMMON_DATETIMESECOND_TYPE = "yyyy-mm-dd HH:MM:SS";
	
	this.MENU_ID;
	
	this.SEARCH_AREA_ID = "searchArea";
	this.SEARCH_DEFAULT_FN = "searchList";
	
	this.IMAGE_THUMBNAIL_SIZE = "imageThumbnailSize";
	
	this.GRID_BOX = "GBox";
	
	this.GRID_BOX_CLASS = "section";
	this.GRID_HEAD_CLASS = "tableHeader";
	this.GRID_BODY_CLASS = "tableBody";
	this.GRID_BOTTOM_CLASS = "tableUtil";
	this.GRID_TAB_BOX_CLASS = "bottomSect";
	this.GRID_COLFIXHEAD_CLASS = "colFixHead";
	this.GRID_COLFIXBODY_CLASS = "colFixBody";
	
	this.GRID_COL_DATA_NAME_HEAD = "GRID_COL_";
	this.GRID_COL_DATA_NAME_TAIL = "_*";
	this.GRID_COL_DATA_NAME_VIEW_HEAD = "GRID_COL_GC_VIEW_";
	this.GRID_COL_DATA_NAME_ROWNUM = "GRID_COL_GC_ROWNUM_*";
	this.GRID_COL_DATA_NAME_ROWVIEW = "GRID_COL_GC_ROWVIEW_*";
	this.GRID_COL_DATA_NAME_ROWVIEWNUM = "GRID_COL_GC_ROWVIEWNUM_*";
	this.GRID_COL_DATA_NAME_COMBODATA_HEAD = "GRID_COL_COMBODATA_";
	this.GRID_COL_DATA_NAME_GROUPSELECT_HEAD = "GRID_COL_GROUPSELECT_";
	this.GRID_COL_DATA_NAME_CHECK_HEAD = "gcch_";
	this.GRID_COL_DATA_NAME_ROWCHECK_HEAD = "gcro_";
	this.GRID_COL_DATA_NAME_READONLY_HEAD = "gcre_";
	this.GRID_COL_DATA_NAME_OPTION_HEAD = "gcop_";
	this.GRID_COL_DATA_NAME_MODIFY_COL_HEAD = "gcmo_";
	this.GRID_COL_DATA_NAME_ROW_STATE_HEAD = "grst_";
	this.GRID_COL_DATA_NAME_ROW_SELECT_CLASS_HEAD = "grsl_";
	this.GRID_COL_DATA_NAME_ROW_FOCUS_CLASS_HEAD = "grfo_";
	this.GRID_COL_DATA_NAME_READONLY_CLASS_HEAD = "gcrc_";
	this.GRID_COL_DATA_NAME_DISABLE_OBJECT_HEAD = "gcdo_";
	this.GRID_COL_DATA_NAME_ATT_TAIL = "_a";
	
	this.GRID_COLOR_ROW_TEXT_CLASS_HEAD = "gcrt_";
	this.GRID_COLOR_ROW_BG_CLASS_HEAD = "gcrb_";
	this.GRID_COLOR_COL_TEXT_CLASS_HEAD = "gcct_";
	this.GRID_COLOR_COL_BG_CLASS_HEAD = "gccb_";
	
	this.GRID_COLOR_TEXT_RED_CLASS = "gridColorTextRed";
	this.GRID_COLOR_TEXT_BLUE_CLASS = "gridColorTextBlue";
	this.GRID_COLOR_TEXT_YELLOW_CLASS = "gridColorTextYellow";
	this.GRID_COLOR_TEXT_GRAY_CLASS = "gridColorTextGray";
	this.GRID_COLOR_TEXT_GREEN_CLASS = "gridColorTextGreen";
	this.GRID_COLOR_BG_RED_CLASS = "gridColorBgRed";
	this.GRID_COLOR_BG_BLUE_CLASS = "gridColorBgBlue";
	this.GRID_COLOR_BG_YELLOW_CLASS = "gridColorBgYellow";
	this.GRID_COLOR_BG_SKYBLUE_CLASS = "gridColorBgSkyblue";
	this.GRID_COLOR_BG_GRAY_CLASS = "gridColorBgGray";
	this.GRID_COLOR_BG_GREEN_CLASS = "gridColorBgGreen";
	this.GRID_COLOR_BG_ORANGE_CLASS = "gridColorBgOrange";
	
	this.GRID_COL_TYPE_TEXT_CLASS = "gridColText";
	this.GRID_COL_TYPE_TEXT_COLOR_RED_CLASS = "gridColTextColorRed"; 
	this.GRID_COL_TYPE_INPUT_TEXT_CLASS = "gridColInputText";
	this.GRID_COL_TYPE_TEXT_CENTER_CLASS = "gridColTextCenter";
	this.GRID_COL_TYPE_TEXT_RIGHT_CLASS = "gridColTextRight";
	this.GRID_COL_TYPE_INPUT_NUMBER_CLASS = "gridColInputNumber";
	this.GRID_COL_TYPE_OBJECT_CLASS = "gridColObject";
	this.GRID_COL_TYPE_DISABLE_CLASS = "gridColDisable";
	
	this.GRID_HEAD = "GH";
	this.GRID_COL = "GCol";
	this.GRID_COL_VALUE_TAIL = "GCVT"; // Grid col value tail
	this.GRID_COL_VALUE_HEAD = "GCVH"; // Grid col value head
	
	this.GRID_COL_TYPE = "GColType";
	this.GRID_COL_TYPE_CHECKBOX = "check";
	this.GRID_COL_TYPE_BTN = "btn";
	this.GRID_COL_TYPE_BTN2 = "btn2";  //2019.04.04 김호영 : Grid Data Type btn2 Added
	this.GRID_COL_TYPE_INPUT = "input";
	this.GRID_COL_TYPE_ADD = "add";
	this.GRID_COL_TYPE_SELECT = "select";
	this.GRID_COL_TYPE_COMBO = "combo";
	this.GRID_COL_TYPE_ROWNUM = "rownum";
	this.GRID_COL_TYPE_DELETE = "delete";
	this.GRID_COL_TYPE_ROWCHECK = "rowCheck";
	this.GRID_COL_TYPE_HTML = "html";
	this.GRID_COL_TYPE_TEXT = "text";
	this.GRID_COL_TYPE_FUNCTION = "fn";
	this.GRID_COL_TYPE_FILE = "file";
	this.GRID_COL_TYPE_FILE_SIZE = "fileSize";
	this.GRID_COL_TYPE_FILE_DOWNLOAD = "fileDownload"; // 2019.03.20 jw : Grid Data Type FileDownload Added
	this.GRID_COL_TYPE_FILE_TYPE = "fileType";
	this.GRID_COL_TYPE_FILE_TAIL = "_FILEVIEW";
	this.GRID_COL_TYPE_FILE_SIZE_TAIL = "_FILESIZEVIEW";
	this.GRID_COL_TYPE_TREE = "tree";
	this.GRID_COL_TYPE_TREE_ICON_ATT = "treeIcon";
	this.GRID_COL_TYPE_TREE_TEXT_ATT = "treeText";
	this.GRID_COL_TYPE_TREE_LVL_CLASS = "gridTreeLvl";
	this.GRID_COL_TYPE_ICON = "icon"; //2019.04.05 이범준 : 그리드에 아이콘 이미지  넣기
	
	this.GRID_COL_TYPE_BTN_ROWNUM_ATT = "btnRowNum";
	this.GRID_COL_TYPE_BTN_NAME_ATT = "btnName";
	this.GRID_COL_TYPE_BTN_CLASS = "gridColBtn";
	
	this.GRID_COL_READONLY = "readonly";
	
	this.GRID_COL_TYPE_PK = "GColTypePK";
	
	this.GRID_COL_NAME = "GColName";
	this.GRID_COL_VALUE = "GColValue";
	this.GRID_COL_OBJECT_VALUE = "GColObjectValue";
	this.GRID_COL_GROUP = "GColGroup";
	this.GRID_COL_GROUP_KEY = "GColGroupKey";
	this.GRID_COL_CHECK_RADIO = "GColCheckRadio";
	this.GRID_COL_WIDTH = "GColWidth";
	
	this.GRID_COL_FORMAT = "GF";
	this.GRID_COL_BUTTON = "GB";
	
	this.GRID_COL_SORT_ATT = "GCSort";
	this.GRID_COL_SORT_ASC = "ASC";
	this.GRID_COL_SORT_DESC = "DESC";
	
	this.GRID_ROW = "CGRow";
	//2022.03.21 [행고정] 컬럼 그룹 지정
	this.GRID_HEAD_COL_GROUP = "HCGroup";
	
	this.GRID_ROWNUM_CLASS = "rownum";
	this.GRID_ROW_SELECT_CLASS = "active";
	this.GRID_ROW_FOCUS_CLASS = "focusRow";
	this.GRID_COL_SORTABLE_CLASS = "sortableCol";
	this.GRID_MOUSEOVER_CLASS = "gridMouseOver";
	this.GRID_EDIT_BACK_CLASS = "editable";
	this.GRID_EDITED_BACK_CLASS = "editabled";
	//this.GRID_UNEDIT_BACK_CLASS = "unEditable";
	//this.GRID_EDIT_CHECKBOX_CLASS = "checkbox";
	//this.GRID_EDIT_SELECT_CLASS = "select";
	this.GRID_COL_COMBO_CLASS = "comboCol";
	
	this.GRID_ROW_STATE_ATT = "GRowState";
	this.GRID_ROW_STATE_START = "S";
	this.GRID_ROW_STATE_READ = "R";
	this.GRID_ROW_STATE_INSERT = "C";
	this.GRID_ROW_STATE_UPDATE = "U";
	this.GRID_ROW_STATE_DELETE = "D";
	this.GRID_ROW_STATE_REMOVE = "E";
	
	this.GRID_ROW_TOTAL_ATT = "GRowTotal";
	
	this.GRID_ROW_READONLY_ATT = "GRowReadonly";
	
	this.GRID_ROW_NUM = "GRowNum";
	this.GRID_ROW_VIEWNUM = "GRowViewNum";
	
	this.GRID_EDIT_ATT = "GEdit";
	
	this.GRID_VALIDATION_TYPE_MODIFY = "M";
	this.GRID_VALIDATION_TYPE_SELECT = "S";
	this.GRID_VALIDATION_TYPE_SELECT_MODIFY = "SM";
	this.GRID_VALIDATION_TYPE_ALL = "A";
	
	this.GRID_BTN = "GBtn";
	
	this.GRID_BTN_CHECK = "check";
	this.GRID_BTN_FIND = "find";
	this.GRID_BTN_UP = "up";
	this.GRID_BTN_DOWN= "down";
	this.GRID_BTN_ADD = "add";
	this.GRID_BTN_DELETE = "delete";
	this.GRID_BTN_LAYOUT = "layout";
	this.GRID_BTN_FILTER = "filter";
	this.GRID_BTN_TOTAL = "total";
	this.GRID_BTN_SUB_TOTAL = "subTotal";
	this.GRID_BTN_EXCEL = "excel";
	this.GRID_BTN_EXCEL_ALL = "excelAll";
	this.GRID_BTN_EXCEL_UP = "excelUpload";
	this.GRID_BTN_EXCEL_VIEW = "excelView";
	this.GRID_BTN_SORT_RESET = "sortReset";
	this.GRID_BTN_WRITE = "write";
	this.GRID_BTN_COPY = "copy";
	this.GRID_BTN_COLFIX = "colFix";
	this.GRID_BTN_PAGE_VIEW_COUNT = "viewCount";
	
	this.GRID_BTN_CHECK_ATT = "GBtnCheck";
	
	this.GRID_BTN_FIND_STATE_ATT = "GBtnFindState";
	this.GRID_BTN_FIND_STATE_VIEW = "view";
	
	this.DATA_EXCEL_REQUEST_KEY = "dataExcelRequest";
	this.DATA_EXCEL_LABEL_KEY = "dataExcelLabel";
	this.DATA_EXCEL_MULTI_LABEL_KEY = "dataExcelMultiLabel";
	this.DATA_EXCEL_FORMAT_KEY = "dataExcelFormat";
	this.DATA_EXCEL_FORMAT_NUMBER_KEY = "dataExcelFormatNumber";
	this.DATA_EXCEL_LABEL_ORDER_KEY = "dataExcelLabelOrder";
	this.DATA_EXCEL_WIDTH_KEY = "dataExcelWidth";
	this.DATA_EXCEL_REQUEST_FILE_NAME = "dataGridExcel";
	this.DATA_EXCEL_COLNAME_ROWNUM = "dataExcelColnameRownum";
	this.DATA_EXCEL_CSV_TYPE = "dataExcelCsvType";
	this.DATA_EXCEL_TEXT_KEY = "dataExcelTextType";
	this.DATA_EXCEL_X_TYPE = "dataExcelXType";
	this.DATA_EXCEL_DELIMITER_KEY = "dataExcelDelimiter";
	this.DATA_EXCEL_LABEL_VIEW = "dataExcelLabelView";
	this.DATA_EXCEL_COL_KEY_VIEW = "dataExcelColKeyView";
	this.DATA_EXCEL_UPLOAD_FORM_ID = "gridExcelUploadForm";
	this.DATA_EXCEL_COMBO_DATA_KEY = "gridExcelComboData";
	this.DATA_EXCEL_REQUEST_MAXROW_KEY = "dataExcelRequestMaxrow";
	
	this.DATA_FILE_UPLOAD_FORM_ID = "fileUploadForm";
	this.DATA_FILE_UPLOAD_FILENAME_ID = "fileNameView";
	this.DATA_FILE_UPLOAD_FILEIMAGE_ID = "fileImageView";
	this.DATA_M_FILE_UPLOAD_FORM_ID = "mFileUploadForm";
	
	this.GRID_PAGE_SELECT_NUM_KEY = "listPageNumKey";
	this.GRID_PAGE_COUNT_NUM_KEY = "listPageCountKey";
	this.GRID_PAGE_REQUEST_TYPE_KEY = "listPageRequestTypeKey";
	
	this.DATA_FORMAT_PARAM_KEY = "dataFormatParam";
	
	this.GRID_CHECKBOX_ALL_ATT = "GCheckAll";
	
	this.GRID_INFO_AREA_ATT = "GInfoArea";
	this.GRID_CHECK_INFO_AREA_ATT = "GCheckInfoArea";
	
	this.GRID_REQUEST_VIEW_COUNT = "GRequestViewCount";
	this.GRID_REQUEST_VALIDATION_KEY = "GRequestValidationKey";
	this.GRID_REQUEST_VALIDATION_TYPE = "GRequestValidationType";
	
	this.GRID_EDIT_INPUT_ID = "GEditInputId";
	//this.GRID_EDIT_INPUT_HTML = "<input id='"+this.GRID_EDIT_INPUT_ID+"' type='text' style='margin-right:-5px;margin-left:-5px;' class='GEditBack'/>";
	this.GRID_EDIT_INPUT_CHANGE_CHECK = "GEInputChangeCheck";
	//this.GRID_EDIT_INPUT_HTML = "<input type='text' class='GEditBack' id="" />";
	//this.GRID_EDIT_CHECKBOX_HTML = "<input type='checkbox' class='GEditBack' />";
	
	this.GRID_LAYOUT_SAVE_INVISIBLE_ID = "invisibleList";
	this.GRID_LAYOUT_SAVE_VISIBLE_ID = "visibleList";
	this.GRID_LAYOUT_SAVE_COLNAME = "COLNAME";
	this.GRID_LAYOUT_SAVE_COLTEXT = "COLTEXT";
	this.GRID_LAYOUT_SAVE_COLWIDTH = "COLWIDTH";
	this.GRID_LAYOUT_SAVE_COLNAME_ATT = "layoutColName";
	this.GRID_LAYOUT_SAVE_COLWIDTH_ATT = "layoutColWidth";
	
	this.GRID_LAYOUT_HEAD_COL_LEFT_CLASS = "GLHeadColLeft";
	this.GRID_LAYOUT_HEAD_COL_RIGHT_CLASS = "GLHeadColRight";
	this.GRID_LAYOUT_HEAD_COL_MIN_ATT = "GLHeadColMin";
	this.GRID_LAYOUT_HEAD_COL_MAX_ATT = "GLHeadColMax";
	this.GRID_LAYOUT_HEAD_COL_INDEX_ATT = "GLHeadColIndex";
	
	this.GRID_HEAD_SORT_ATT = "gridHeadSort";
	this.GRID_HEAD_SORT_BTN_ATT = "gridHeadSortBtn";
	this.GRID_HEAD_SORT_CLASS = "gridHeadSort";
	this.GRID_HEAD_SORT_BTN_UP_CLASS = "gridHeadSortBtnUp";
	this.GRID_HEAD_SORT_BTN_DOWN_CLASS = "gridHeadSortBtnDown";
	
	this.GRID_NAV_BTN_ATT = "GNBtn";
	
	this.GRID_ID_ATT = "GridId";
	
	this.GRID_FILTER_COL_ID = "filterColList";
	this.GRID_FILTER_DATA_ID = "filterDataList";
	
	this.GRID_SUBTOTAL_COL_ID = "subTotalColList";
	this.GRID_SUBTOTAL_DATA_ID = "subTotalDataList";
	
	this.GRID_TREE_LVL_CLASS = new DataMap();
	this.GRID_TREE_LVL_CLASS_1 = "gridTreeLvl1";
	this.GRID_TREE_LVL_CLASS_2 = "gridTreeLvl2";
	this.GRID_TREE_LVL_CLASS_3 = "gridTreeLvl3";
	this.GRID_TREE_LVL_CLASS_4 = "gridTreeLvl4";
	this.GRID_TREE_LVL_CLASS_5 = "gridTreeLvl5";
	this.GRID_TREE_LVL_CLASS_6 = "gridTreeLvl6";
	this.GRID_TREE_LVL_CLASS_7 = "gridTreeLvl7";
	this.GRID_TREE_LVL_CLASS_8 = "gridTreeLvl8";
	this.GRID_TREE_LVL_CLASS_9 = "gridTreeLvl9";
	
	this.GRID_INPUT_ROW_NUM = "GIRowNum";
	this.GRID_INPUT_COL_NAME = "GIColName";
		
	this.INPUT = "UIInput";
	this.INPUT_SEARCH = "S";
	this.INPUT_RANGE = "R";
	this.INPUT_SHORT_RANGE = "SR";
	this.INPUT_BETWEEN = "B";
	this.INPUT_MULTIPLE = "M";	
	this.INPUT_RADIO = "O";
	this.INPUT_TEXT = "I";
	this.INPUT_RNAGE_SQL = "RANGE_SQL";
	this.INPUT_RNAGE_DATA_PARAM = "RANGE_DATA_PARAM";
	this.INPUT_SEARCH_CLASS = "searchInput";
	this.INPUT_RANGE_CLASS = "normalInput";
	this.INPUT_NUMBER_CLASS = "inputNumber";
	this.INPUT_BUTTON_CLASS = "searchInput";
	this.INPUT_NORMAL_CLASS = "normalInput";
	this.INPUT_CALENDAR_CLASS = "calendarInput";
	this.INPUT_MONTH_SELECT_CLASS = "monthpicker";
	this.INPUT_TIME_SELECT_CLASS = "timepicker";
	this.INPUT_PARAM_GROUP  = "PGroup";
	
	this.INPUT_FORMAT = "UIFormat";
	this.INPUT_FORMAT_STRING = "S";
	this.INPUT_FORMAT_NUMBER = "N";
	this.INPUT_FORMAT_NUMBER_STRING = "NS";
	this.INPUT_FORMAT_KO_STRING = "KO";	
	this.INPUT_FORMAT_DATE = "D";
	this.INPUT_FORMAT_CALENDER = "C";
	this.INPUT_FORMAT_DATE_MONTH = "DM"; // 2019.03.07 jw : : Input Data Type Month Added
	this.INPUT_FORMAT_CALENDER_MONTH = "CM"; // 2019.03.07 jw : : Input Data Type Month Added
	this.INPUT_FORMAT_DATETIME = "DT";
	this.INPUT_FORMAT_DATETIMESECOND = "DTS";
	this.INPUT_FORMAT_TIME = "T";
	this.INPUT_FORMAT_MONTH_SELECT = "MS";
	this.INPUT_FORMAT_TIMEHM_SELECT = "THM";
	this.INPUT_FORMAT_BUTTON = "B";
	this.INPUT_FORMAT_UPPERCASE = "U";
	this.INPUT_FORMAT_LOWERCASE = "L";
	
	this.INPUT_FORMAT_UPPERCASE_CLASS = "textUpperFormat";
	this.INPUT_FORMAT_LOWERCASE_CLASS = "textLowerFormat";
	
	this.INPUT_SAVE = "UISave";
	this.INPUT_SAVE_FALSE = "false";
	this.INPUT_SAVE_TRUE = "true";
	
	this.INPUT_FORMAT_CALENDER_NOW = "N";
	this.INPUT_FORMAT_CALENDER_YESTERDAY = "Y";
	this.INPUT_FORMAT_CALENDER_TOMORROW = "T";
	this.INPUT_FORMAT_CALENDER_FIRST = "F"; // 2019.02.25 jw : Input UIFormat Default Value "F" Added
	this.INPUT_FORMAT_CALENDER_LAST = "L"; // 2019.02.25 jw : Input UIFormat Default Value "L" Added
	this.INPUT_FORMAT_CALENDER_FIRST_DAY = "FD"; // 2019.03.11 jw : Input UIFormat Default Value "FD" Added
	this.INPUT_FORMAT_CALENDER_LAST_DAY = "LD"; // 2019.03.11 jw : Input UIFormat Default Value "LD" Added
	this.INPUT_FORMAT_CALENDER_MONTH1 = "M1";
	this.INPUT_FORMAT_CALENDER_MONTH2 = "M2"; // 2019.02.25 jw : Input UIFormat Default Value "M2" Added
	this.INPUT_FORMAT_CALENDER_MONTH3 = "M3"; // 2019.03.11 jw : Input UIFormat Default Value "M3" Added
	this.INPUT_FORMAT_CALENDER_WEEK1 = "W1";
	
	this.INPUT_FORMAT_CALENDER_MONTH_NOW = "N"; // 2019.03.07 jw : : Input Data Type Month Added
	this.INPUT_FORMAT_CALENDER_MONTH_FIRST = "F"; // 2019.03.07 jw : : Input Data Type Month Added
	this.INPUT_FORMAT_CALENDER_MONTH_LAST = "L"; // 2019.03.07 jw : : Input Data Type Month Added
	this.INPUT_FORMAT_CALENDER_MONTH_BETWEEN = "MM"; // 2019.03.07 jw : : Input Data Type Month Added
	
	this.INPUT_COMBO = "Combo";
	this.INPUT_COMBO_TYPE = "ComboType";
	this.INPUT_SEARCH_COMBO = "SC";
	this.INPUT_MULTIPLE_COMBO = "MC";
	this.INPUT_MULTIPLE_SEARCH_COMBO = "MS";
	this.INPUT_COMMON_COMBO = "CommonCombo";
	this.INPUT_REASON_COMBO = "ReasonCombo";
	this.INPUT_COMBO_OPTION = "UIOption";
	this.INPUT_COMBO_OPTION_GROUP = "UIOptionGroup";
	this.INPUT_COMBO_GROUP_COL_ATT = "ComboGroupCol";
	this.INPUT_COMBO_GROUP_COL = "GROUP_COL";
	this.INPUT_COMBO_VALUE_COL = "VALUE_COL";
	this.INPUT_COMBO_TEXT_COL = "TEXT_COL";
	this.INPUT_COMBO_CODE_VIEW_TYPE = "ComboCodeView";
	
	this.INPUT_CHECKBOX_EMPTY_ATT = "CheckEmptyVal";
	
	this.INPUT_RANGE_SINGLEGRID_ID = "rangeSingleList";
	this.INPUT_RANGE_RANGEGRID_ID = "rangeRangeList";
	this.INPUT_RANGE_LOGICAL = "LOGICAL";
	this.INPUT_RANGE_OPERATOR = "OPER";
	this.INPUT_RANGE_SINGLE_DATA = "DATA";
	this.INPUT_RANGE_RANGE_FROM = "FROM";
	this.INPUT_RANGE_RANGE_TO = "TO";
	this.INPUT_RANGE_TYPE_SINGLE = "Single";
	this.INPUT_RANGE_TYPE_RANGE = "Range";
	this.INPUT_RANGE_NAME = "UIRange";
	
	this.INPUT_AUTOCOMPLETE_COUNT = 10;
	this.INPUT_AUTOCOMPLETE_NAME = "IAname";
	this.INPUT_AUTOCOMPLETE_COOKIE_NAME = "IAcookie";
	
	this.INPUT_SEARCH_PARAM_KET = "inputSearchParam";
	
	this.MIDDLE_AREA = "commonMiddleArea";
	this.CENTER_AREA = "commonCenterArea";
	
	this.MSG_MASTER_ROWEMPTY = "SYSTEM_DATAEMPTY"; //조회된 데이터가 없습니다.
	this.MSG_MASTER_DELETE_CONFIRM = "SYSTEM_DELCONFIRM"; //삭제하시겠습니까?
	this.MSG_MASTER_ROW_SELECT = "SYSTEM_ROWSEMPTY"; //선택된 데이터가 없습니다.
	this.MSG_MASTER_SAVE_CONFIRM = "SYSTEM_SAVECF";  //저장하시겠습니까?
	
	this.MSG_SYSTEM_EXCELMAXROW = "SYSTEM_EXCELMAXR"; //다운로드 가능한 최대행 개수를 초과했습니다.
	this.MSG_SYSTEM_EXCELFORMAT = "SYSTEM_EXCELFM"; //엑셀 형식이 유효하지 않습니다.
	this.MSG_SYSTEM_SAVEEMPTY = "SYSTEM_SAVEEMPTY"; // 변경된 데이터가 없습니다.
	this.MSG_SYSTEM_SAVEOK = "SYSTEM_SAVEOK"; // 저장 완료되었습니다.
	this.MSG_SYSTEM_DELETEOK = "SYSTEM_DELETEOK"; // 삭제 되었습니다.
	
	this.MSG_MASTER_LOADING = "MASTER_LOADING"; //다른 명령 실행중으로 중복 실행이 불가합니다.
	this.MSG_MASTER_MAX_MENU_TAB = "MASTER_MAX_MENU_TAB"; //윈도우탭의 최대 개수를 초과했습니다.
	this.MSG_WINDOWMAX = "MASTER_WINDOWMAX"; //메뉴탭 최대 개수는 {0}개 입니다.
	this.MSG_EXECUTE_ERROR = "EXECUTE_ERROR"; //실패하였습니다.
	this.MSG_EXECUTE_APPLY = "EXECUTE_APPLY"; //성공하였습니다.
	
	this.MSG_MOUSEWHEEL_EVENT_STOP = "SYSTEM_MWHEELC"; //마우스 휠 클릭은 사용할 수 없습니다.
	this.MSG_SELECTDATA = "SYSTEM_SELECTDATA"; //선택하세요.
	this.MSG_MODIFY_ITEM_CHECK = "SYSTEM_MODIFYITEMCHECK"; //아이템에 수정된 데이터가 있습니다.\n새로운 데이터를 조회 하시겠습니까?
	this.MSG_MASTER_FILEDOWN_CONFIRM = "SYSTEM_FILEDCONFIRM"; //{0} 파일을 다운로드 하시겠습니까? COMMON_M0503
	
	this.MSG_GROUPKEY = "MSG";
		
	this.ACTION_ATT = "CA";
	
	this.LABEL_ATT = "CL";
	
	this.SHORT_KET_ATT = "CS";
	
	/*
	this.COMMON_KEY_EVENT_SEARCH_CODE = 70;//f - 조회
	this.COMMON_KEY_EVENT_SAVE_CODE = 83;//s - 저장
	this.COMMON_KEY_EVENT_CREATE_CODE = 67;//c - 생성
	this.COMMON_KEY_EVENT_SEARCH_HELP_CODE = 65;//a - search help
	this.COMMON_KEY_EVENT_DOCUMENT_LINK_CODE = 68;//d 도큐먼트 링크
	this.COMMON_KEY_EVENT_SEARCH_POP_CODE = 87;//w 조회창 전환
	
	this.COMMON_KEY_EVENT_SEARCH = "F";
	this.COMMON_KEY_EVENT_SAVE = "S";
	this.COMMON_KEY_EVENT_CREATE = "C";
	this.COMMON_KEY_EVENT_DOCUMENT_LINK = "D";
	this.COMMON_KEY_EVENT_SEARCH_POP = "W";
	*/
	
	this.BUTTON_COMMAND_SEARCH = "Search";
	this.BUTTON_COMMAND_SAVE = "Save";
	this.BUTTON_COMMAND_CREATE = "Create";
		
	this.BUTTON_ATT = "CB";
	this.BUTTON_TYPE_ATT = "CBtnType";
	this.BUTTON_NAME_ATT = "CBtnName";
	this.BUTTON_ACTIVE_TYPE_ATT = "CBtnActiveType";
	this.BUTTON_MODIFY_CHECK_ATT = "CBtnModifyCheck";
	
	this.BUTTON_CLASS = "button";
	this.BUTTON_ICON_CLASS = "top_icon";
	this.BUTTON_TEXT_CLASS = "top_icon_text";
	this.BUTTON_INACTIVE_CLASS = "bInactive";
	
	this.BUTTON_TYPE_SEARCH = "SEARCH";
	this.BUTTON_TYPE_EXECUTE = "EXECUTE";
	this.BUTTON_TYPE_PREV = "PREV";
	this.BUTTON_TYPE_ADD = "ADD";
	this.BUTTON_TYPE_SAVE = "SAVE";
	this.BUTTON_TYPE_PENCIL = "PENCIL";
	this.BUTTON_TYPE_EXPAND = "EXPAND";
	this.BUTTON_TYPE_REFLECT = "REFLECT";
	this.BUTTON_TYPE_CLOSE = "CLOSE";
	this.BUTTON_TYPE_CHECK = "CHECK";
	this.BUTTON_TYPE_PRINT = "PRINT";
	this.BUTTON_TYPE_SEND = "SEND";
	this.BUTTON_TYPE_WORK = "WORK";
	this.BUTTON_TYPE_SPEAK = "SPEAK";
	this.BUTTON_TYPE_FILE = "FILE";
	this.BUTTON_TYPE_COPY = "COPY";
	this.BUTTON_TYPE_UP = "UP";
	this.BUTTON_TYPE_DOWN = "DOWN";
	this.BUTTON_TYPE_INSFLD = "INSFLD";
	this.BUTTON_TYPE_CART = "CART";
	this.BUTTON_TYPE_ALLOCATE = "ALLOCATE";
	this.BUTTON_TYPE_NOTE = "NOTE";
	this.BUTTON_TYPE_CREATE = "CREATE";
	this.BUTTON_TYPE_RECALL = "RECALL";
	this.BUTTON_TYPE_SAVEAS = "SAVEAS";
	this.BUTTON_TYPE_DELETE = "DELETE";
	this.BUTTON_TYPE_WCANCLE = "WCANCLE";
	this.BUTTON_TYPE_CALENDER = "CALENDER";
	this.BUTTON_TYPE_GETVARIANT = "GETVARIANT";
	this.BUTTON_TYPE_SAVEVARIANT = "SAVEVARIANT";
	this.BUTTON_TYPE_APPROVE = "APPROVE";
	this.BUTTON_TYPE_REJECT = "REJECT";	
	this.BUTTON_TYPE_GRID_FILE = "GRID_FILE";
	
	this.BUTTON_ICON = new DataMap();
	this.BUTTON_ICON.put(this.BUTTON_TYPE_SEARCH, "top_icon_03");
	this.BUTTON_ICON.put(this.BUTTON_TYPE_EXECUTE, "top_icon_01");
	this.BUTTON_ICON.put(this.BUTTON_TYPE_PREV, "top_icon_31");
	this.BUTTON_ICON.put(this.BUTTON_TYPE_ADD, "top_icon_02");
	this.BUTTON_ICON.put(this.BUTTON_TYPE_SAVE, "top_icon_06");
	this.BUTTON_ICON.put(this.BUTTON_TYPE_PENCIL, "top_icon_04");
	this.BUTTON_ICON.put(this.BUTTON_TYPE_EXPAND, "top_icon_05");
	this.BUTTON_ICON.put(this.BUTTON_TYPE_REFLECT, "top_icon_23");
	this.BUTTON_ICON.put(this.BUTTON_TYPE_CLOSE, "top_icon_08");
	this.BUTTON_ICON.put(this.BUTTON_TYPE_CHECK, "top_icon_08");
	this.BUTTON_ICON.put(this.BUTTON_TYPE_PRINT, "top_icon_09");
	this.BUTTON_ICON.put(this.BUTTON_TYPE_SEND, "top_icon_10");
	this.BUTTON_ICON.put(this.BUTTON_TYPE_WORK, "top_icon_11");
	this.BUTTON_ICON.put(this.BUTTON_TYPE_SPEAK, "top_icon_12");
	this.BUTTON_ICON.put(this.BUTTON_TYPE_FILE, "top_icon_13");
	this.BUTTON_ICON.put(this.BUTTON_TYPE_COPY, "top_icon_14");
	this.BUTTON_ICON.put(this.BUTTON_TYPE_UP, "top_icon_15");
	this.BUTTON_ICON.put(this.BUTTON_TYPE_DOWN, "top_icon_16");
	this.BUTTON_ICON.put(this.BUTTON_TYPE_INSFLD, "top_icon_17");
	this.BUTTON_ICON.put(this.BUTTON_TYPE_CART, "top_icon_18");
	this.BUTTON_ICON.put(this.BUTTON_TYPE_ALLOCATE, "top_icon_19");
	this.BUTTON_ICON.put(this.BUTTON_TYPE_NOTE, "top_icon_20");
	this.BUTTON_ICON.put(this.BUTTON_TYPE_CREATE, "top_icon_21");
	this.BUTTON_ICON.put(this.BUTTON_TYPE_RECALL, "top_icon_22");
	this.BUTTON_ICON.put(this.BUTTON_TYPE_SAVEAS, "top_icon_07");
	this.BUTTON_ICON.put(this.BUTTON_TYPE_DELETE, "top_icon_25");
	this.BUTTON_ICON.put(this.BUTTON_TYPE_WCANCLE, "top_icon_24");
	this.BUTTON_ICON.put(this.BUTTON_TYPE_CALENDER, "top_icon_20");
	this.BUTTON_ICON.put(this.BUTTON_TYPE_GETVARIANT, "top_icon_26");
	this.BUTTON_ICON.put(this.BUTTON_TYPE_SAVEVARIANT, "top_icon_27");
	this.BUTTON_ICON.put(this.BUTTON_TYPE_APPROVE, "top_icon_28");
	this.BUTTON_ICON.put(this.BUTTON_TYPE_REJECT, "top_icon_29");
	
	this.BUTTON_ICON.put(this.BUTTON_TYPE_GRID_FILE, "grid_icon_16");
	
	this.VALIDATION_ATT = "validate";
	this.VALIDATION_REQUIRED   ="required";    
	this.VALIDATION_MINLENGTH  ="minlength";   
	this.VALIDATION_MAXLENGTH  ="maxlength";   
	this.VALIDATION_RANGELENGTH="rangelength"; 
	this.VALIDATION_EMAIL	   ="email";       
	this.VALIDATION_URL	   ="url";         
	this.VALIDATION_NUMBER	   ="number";      
	this.VALIDATION_TEL	   ="tel";
	this.VALIDATION_PHONE	   ="phone";
	this.VALIDATION_EQUALTO	   ="equalTo";     
	this.VALIDATION_PAIR 	   ="pair";       
	this.VALIDATION_EQUAL	   ="equal";       
	this.VALIDATION_BETWEEN	   ="between";     
	this.VALIDATION_MIN	   ="min";         
	this.VALIDATION_MAX	   ="max";         
	this.VALIDATION_REMOTE	   ="remote";      
	this.VALIDATION_DUPLICATION="duplication";
	this.VALIDATION_DATE="date";
	this.VALIDATION_DATE_MONTH = "month"; // 2019.03.07 jw : : Input Data Type Month Added
	
	this.VALIDATION_OBJECT_TYPE = "valObjType";
	this.VALIDATION_OBJECT_TYPE_GRID = "grid";
	this.VALIDATION_OBJECT_TYPE_INPUT = "input";
	this.VALIDATION_OBJECT_TYPE_RANGE = "range";

	
	this.VALIDATE_MSG_GROUPKEY = "VALID";
	
	this.VALIDATE_MSG = new DataMap();
//	this.VALIDATE_MSG.put("required","{0}필수 입력항목입니다.");						//VALID_required
//	this.VALIDATE_MSG.put("minlength","{0}은(는){1}자 이상 입력하세요.");			    //VALID_minlength
//	this.VALIDATE_MSG.put("maxlength","{0}은(는){1}자 초과 입력이 불가합니다.");			//VALID_maxlength	    
//	this.VALIDATE_MSG.put("rangelength","{0}은(는){1}자 이상 {2}자 이하로 입력하세요."); //VALID_rangelength
//	this.VALIDATE_MSG.put("email","{0}메일 형식에 맞게 입력하세요.");				    //VALID_email
//	this.VALIDATE_MSG.put("url","{0}URL 형식에 맞게 입력하세요.");						//VALID_url
//	this.VALIDATE_MSG.put("number","{0}숫자 형식에 맞게 입력하세요.");					//VALID_number
//	this.VALIDATE_MSG.put("tel","전화번호 형식이 맞지 않습니다.");						//VALID_tel
//	this.VALIDATE_MSG.put("equalTo","{0}은(는){1}값만 입력 가능합니다.");				//VALID_equalTo
//	this.VALIDATE_MSG.put("pair","{0} 입력시 {1} 필수 입력항목입니다.");				//VALID_pair
//	this.VALIDATE_MSG.put("equal","{0}와 {1}의 값이 같지 않습니다.");					//VALID_equal
//	this.VALIDATE_MSG.put("between","{1}은(는) {0} 보다 큰 값이어야 합니다.");			//VALID_between
//	this.VALIDATE_MSG.put("min","{0}은(는) {1}이상의 값이어야 합니다.");				//VALID_min
//	this.VALIDATE_MSG.put("max","{0}은(는) {1}이하의 값이어야 합니다.");				//VALID_max
//	this.VALIDATE_MSG.put("max","{0}은(는) {1}이하의 값이어야 합니다.");
//	this.VALIDATE_MSG.put("remote","{0} 값이 유효하지 않습니다.");						//VALID_remote
//	this.VALIDATE_MSG.put("duplication","{0} 이미 사용중인 값입니다.");				//VALID_duplication
//	this.VALIDATE_MSG.put("date","날짜형식이 맞지않습니다.");							//VALID_date
//	this.VALIDATE_MSG.put("excel","엑셀형식이 맞지않습니다.");							//VALID_excel
//	this.VALIDATE_MSG.put("image","이미지형식이 맞지않습니다.");							//VALID_image
	
	this.EXCEL_DOWN_TOKEN = "excelDownToken";
	
	//2020.12.09 이범준
	this.isMobile = false;
};

// config를 사용하기 위해 전역변수로 선언한다.
var configData = new ConfigData();