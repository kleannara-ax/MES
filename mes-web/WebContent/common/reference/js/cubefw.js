/*!
 * Cubefw JavaScript Library v1.1.0
 * http://cubefw.com/
 *
 * Copyright 2012, Sung-il Song
 * Released under the MIT, BSD, and GPL Licenses.
 *
 * Date: 2012-06-01
 */

/*
 * 데이터를 저장하고, JSON방식의 전송을 위한 데이터 변환 기능을 제공한다.
 */
CubeMap = function() {
	this.map = new Object();
};
CubeMap.prototype = {
	//데이터를 key, value 형태로 저장한다.
	put : function(key, value) {		
		this.map[key] = value;
	},
	//데이터를 저장시 동일한 key가 있는 경우 value를 구분자 ","로 연결하여 저장한다.
	putMulti : function(key, value) {
		if(this.get(key)){
			this.map[key] = this.get(key)+',\''+value+'\'';
		}else{
			this.map[key] = '\''+value+'\'';
		}
	},
	//value가 CubeMap 형태인 경우 맴버필드인 map만 저장한다.
	putMap : function(key, value) {
		this.map[key] = value.map;
	},
	//value가 CubeMap을 포함한 List인 경우 포함된 CubeMap의 맴버필드인 map을 추출하여 List로 저장한다.
	putMapList : function(key, value) {
		var list = new Array();
		for ( var i = 0; i < value.length; i++) {
			list.push(value[i].map);
		}
		this.map[key] = list;
	},
	//key로 저장된 value를 리턴한다.
	get : function(key) {
		return this.map[key];
	},
	//key를 사용하고 있는지 판단한다.
	containsKey : function(key) {
		return key in this.map;
	},
	//value로 저장된 값이 있는지 판단한다.
	containsValue : function(value) {
		for (var prop in this.map) {
			if (this.map[prop] == value)
				return true;
		}
		return false;
	},
	//map에 데이터가 없는지 판단한다.
	isEmpty : function() {
		return (this.size() == 0);
	},
	//map에 저장된 데이터를 모두 삭제한다.
	clear : function() {
		for (var prop in this.map) {
			delete this.map[prop];
		}
	},
	//key로 저장된 데이터를 삭제한다.
	remove : function(key) {
		delete this.map[key];
	},
	//저장된 데이터 key를 List에 담아 리턴한다.
	keys : function() {
		var keys = new Array();
		for (var prop in this.map) {
			keys.push(prop);
		}
		return keys;
	},
	//저장된 데이터 value를 List에 담아 리턴한다.
	values : function() {
		var values = new Array();
		for (var prop in this.map) {
			values.push(this.map[prop]);
		}
		return values;
	},
	//map에 저장된 데이터의 개수를 리턴한다.
	size : function() {
		var count = 0;
		for (var prop in this.map) {
			if(prop != null){
				count++;
			}
		}
		return count;
	},
	//map에 저장된 데이터를 JSON형태로 파싱하여 리턴한다.
	jsonString : function() {
		for (var prop in this.map) {
			this.map[prop] == cubeCommon.replaceAll(this.map[prop].toString(), "?", "? ");
		}
		return JSON.stringify(this.map);
	},
	toString : function() {
		return JSON.stringify(this.map);
	}
};

CubeConfig = function() {
	//this.LOADING_COUNT = 0;
	this.PERFORMANCE_TRACE_ADVICE = false; //데이터 바인드 성능을 화면에 출력할지 결정한다.
	//this.MOBILE = false;
	// jquery mobiel theme type set
	this.MOBILE_THEME_H = "";
	this.MOBILE_THEME_C = "";
	this.MOBILE_THEME_F = "";

	//this.LOADING_VIEW_TYPE = true;

	this.SEARCH_TYPE_ATT = "cubeSearchType";
	this.SEARCH_HELP = "cubeSearchHelp";
	this.SEARCH_CODE_ATT = "cubeSearchCode";
	this.SEARCH_HELP_ID_TAIL = "SearchHelp";
	this.SEARCH_HELP_DIALOG_ID = "cubeSearchHelpDialog";
	this.SEARCH_PARAM_ID = "cubeSearchParamId";
	this.SEARCH_SQL_COLNAME_ATT = "cubeSearchSqlColname";

	this.SEARCH_SINGLE = "cubeSearchSingle";
	this.SEARCH_SINGLE_DIALOG_ID = "cubeSearchSingleDialog";
	this.SEARCH_SINGLE_TABLE_ID = "cubeSearchSingleTableId";
	this.SEARCH_SINGLE_BUTTON_ID = "cubeSearchSingleButtonId";

	this.SEARCH_RANGE = "cubeSearchRange";
	this.SEARCH_RANGE_DIALOG_ID = "cubeSearchRangeDialog";
	this.SEARCH_RANGE_TABLE_ID = "cubeSearchRangeTableId";
	this.SEARCH_RANGE_BUTTON_ID = "cubeSearchRangeButtonId";

	this.DATA_GRID_ATT = "cubeDataGrid"; //grid 속성 부여
	this.DATA_ROW_ATT = "cubeDataRow"; // grid row 속성 부여
	this.DATA_ROW_DELETE_BTN = "cubeDataRowDeleteBtn"; // grid delete button 자동 생성
	this.DATA_ROW_COPY_BTN = "cubeDataRowCopyBtn"; // grid row copy button 자동 생성
	this.DATA_ROW_PRINT_NUM = "cubeDataRowPrintNum"; // grid row number view
	//this.DATA_ROW_STATE_CHECK = "cubeDataRowStateCheck";
	this.DATA_ROW_STATE_ATT = "cubeDataRowState"; // grid row state
	this.DATA_ROW_STATE_START = "S"; // grid scan row state
	this.DATA_ROW_STATE_READ = "R"; // grid data bind row 
	this.DATA_ROW_STATE_UPDATE = "U"; // grid data change row
	this.DATA_ROW_STATE_CREATE = "C"; // grid add row
	this.DATA_ROW_STATE_DELETE = "D"; // grid delete row
	this.DATA_ROW_CLASS = "cubeDataGrid"; // grid row class name - 기본 속성을 hidden으로 설정하여 데이터 바인더 이전에 화면에 노출되는 것을 방지
	this.DATA_COLUMN_CREATE_VALUE = "cubeDataCreateValue"; // grid row bind 에서는 readonly이지만 데이터 추가시는 입력이 가능하도록 변경되는 컬럼
	this.DATA_COLUMN_VALUE = "cubeDataValue"; // checkbos, radio, select등 데이터가 바인드 되더라도 단순한 value변경 만으로 데이터 표현이 어려운 경우 해당 att에 있는 값으로 value를 셋팅함
	this.DATA_COLUMN_NAME_HEAD = "CUBE_COL_"; // grid row data bind string head
	this.DATA_COLUMN_NAME_TAIL = "_*"; // grid row data bind string tail
	this.DATA_COLUMN_ROWNUM = "CUBE_DATA_ROWNUM"; // radio는 동일한 name값으로 그룹핑 되므로 row별 이름을 다르게 주기위해 row num을 자동으로 매핑해주는 기능
	//this.DATA_COLUMN_CODE_ATT = "cubeDataColCode"; 
	//this.DATA_COLUMN_NAME_ATT = "cubeDataColName";
	this.DATA_COLUMN_LABEL_ATT = "cubeDataColLabel"; // grid excel down column label mapping
	this.DATA_EXCEL_REQUEST_KEY = "cubeDataExcelRequest"; // 해당 request가 excel 데이터 요청임을 서버에 알리기 위한 request param
	this.DATA_EXCEL_FILENAME = "cubeDataGridExcel"; // grid xecel down file name
	this.DATA_EXCEL_LABEL_KEY = "cubeDataExcelLabel"; // excel에 사용된 label 데이터를 전달하기 위한 request param 
	this.DATA_EXCEL_LABEL_ORDER_KEY = "cubeDataExcelLabelOrder"; // excel 생성시 컬럼 순서를 전달하기 위한 request param 
	this.DATA_COMBO_ATT = "cubeDataCombo"; // grid row data combo view
	this.DATA_SEARCH_COMBO_ATT = "cubeDataSearchCombo"; // grid row data dynamic search combo view
	this.DATA_COMMON_COMBO_ATT = "cubeDataCommonCombo"; // grid row data common code combo view
	this.DATA_COMBO_SELECTED_TEXT_TAIL = "_CUBECOMBOTEXT"; // grid row data 추출시 combo에 표시된 text를 추출하기 위해 해당 combo의 name뒤에 붙이는 키

	this.DATA_GRID_PAGING_ATT = "cubeDataGridPaging"; // 특정 grid의 페이징 번호 정보를 표시하기 위한 속성
	//this.DATA_GRID_PAGING_EVENT_ATT = "cubeDataGridPagingEvent";
	this.DATA_GRID_PAGEINFO_ATT = "cubeDataGridPageinfo"; //특정 grid의 페이징 통합 정보를 표시하기 위한 속성
	//this.LIST_PAGE_ID_TAIL = "CubePage";
	this.LIST_PAGE_DEFAULT_COUNT = 10;//한 페이지당 표시개수
	this.LIST_PAGE_NUM_LIST_DEFAULT_COUNT = 10;//페이징 번호 표시개수
	this.LIST_PAGE_SELECT_NUM_ATT = "cubeListPageNum"; // 조회된 페이지 번호
	this.LIST_PAGE_COUNT_NUM_ATT = "cubeListPageCount"; // 페이지 수
	this.LIST_PAGE_TOTAL_COUNT_ATT = "cubeListPageTotalCount"; // 전체 카운트
	this.LIST_PAGE_MAX_ATT = "cubeListPageMax"; // 최고 페이지 번호
	this.LIST_PAGE_SELECT_NUM_KEY = "cubeListPageNumKey"; // 서버에 전달한 선택 페이지 번호 request param
	this.LIST_PAGE_COUNT_NUM_KEY = "cubeListPageCountKey"; // 서버에 전달한 페이지당 데이타 개수
	//this.LIST_PAGE_TOTAL_COUNT_KEY = "cubeListPageTotalCountKey"; 
	
	this.IMAGE_THUMBNAIL_SIZE_KEY = "cubeImageThumbnailSize"; // 이미지 업로드시 저장한 썸내일 이미지 속성

	this.DATA_CHECKBOX_OFF_ATT = "cubeDataCheckBoxOff"; // checkbox의 경우 체크 해지시 저장하고 싶은 value를 지정

	this.DATA_TYPE_ATT = "cubeDataType"; // UI Type 설정 속성
	this.DATA_TYPE_DATE = "date"; // 달력지정
	this.DATA_TYPE_SELECTDATE = "selectDate"; // 연, 월 선택이 가능한 달력지정
	this.DATA_TYPE_BUTTON = "button"; // Button 지정
	this.DATA_TYPE_EDITOR = "editor"; // Web Editor 지정
	this.DATA_TYPE_TREE = "tree"; // Tree 지정
	this.DATA_TREE_OPTION_ATT = "cubeDataTreeOption"; // Tree에서 필요한 속성 지정(ajax url, root title, open id)
	//this.DATA_TREE_JSON_URL_ATT = "cubeDataTreeJsonUrl";
	this.DATA_TREE_TITLE_KEY = "cubeDataTreeTitle"; // Tree 데이터 요청시 root에 표시할 title속성을 전달한 request param
	this.DATA_TREE_OPEN_ID_KEY = "cubeDataTreeOpenId"; // Tree 데이터 요청시 open해서 표시할 항목의 아이디를 전달한 request param
	this.DATA_TYPE_READ_EDITOR = "readEditor"; // Web editor에서 저장한 내용을 표현하기 위한 editor지정
	this.DATA_TYPE_CALENDAR = "calendar"; // full calendar 지정
	this.DATA_TYPE_TAB = "tab"; // tab 지정
	this.DATA_TYPE_MENU = "menu"; // menu 지정
	this.DATA_TYPE_ACCORDION = "accordion"; // accordion 지정
	this.DATA_TYPE_BOARD = "board"; // 게시판 지정
	this.DATA_TYPE_BOARD_GRID_ATT = "cubeDataBoardGrid"; // 게시판 내에 표현되는 grid 지정
	this.DATA_TYPE_FILE_GRID_ATT = "cubeDataFileGrid"; // 게시판 내에 표현되는 file grid 지정
	this.DATA_TYPE_COMMENT_GRID_ATT = "cubeDataCommentGrid"; // 게시판 내에 표현되는 comment grid 지정
	//boardCode, boardType, contentId, listType
	this.DATA_TYPE_BOARD_CODE_ATT = "cubeDataBoardCode"; // 게시판 내에 표현되는 board code를 저장하는 속성
	this.DATA_TYPE_BOARD_TYPE_ATT = "cubeDataBoardType"; // 게시판 내에 표현되는 board type을 저장하는 속성
	this.DATA_TYPE_BOARD_CONTENT_ID_ATT = "cubeDataBoardContentId"; // 게시판 내에 표현되는 board content id를 저장하는 속성
	this.DATA_TYPE_BOARD_LIST_TYPE_ATT = "cubeDataBoardListType"; // 게시판 내에 표현되는 board list type을 저장하는 속성
	this.CALENDAR_BTN_ATTR = "cubeCalendarBtn"; // full calendar navigation button 지정
	this.CALENDAR_DATE_ATTR = "cubeCalendarDate"; // full calendar date view 지정
	this.DATA_TYPE_GRID_BUTTON = "gridButton"; // grid내 표현되는 button 지정
	this.DATA_TYPE_MOBILE_NEXT = "mNext"; // mobile의 next button 지정
	this.DATA_TYPE_MOBILE_BACK = "mBack"; // mobile의 back button 지정
	this.DATA_TYPE_MOBILE_HOME = "mHome"; // mobile의 home button 지정
	this.DATA_TYPE_MOBILE_BTN = "mBtn"; // mobile의 button 지정
	
	this.DATA_BOARD_CODE_ATT = "cubeDataBoardCode"; // Board 표현시 필요한 옵션 지정(board list id, view type, content id)
	
	this.DATA_FILE_COUNT_ATT = "cubeDataFileCount"; // Board에 첨부된 파일의 개수를 저장하는 attr  

	this.DATA_VALIDATE_ATT = "cubeDataValidate"; // 화면 입력값에 대한 유효성 체크 내용을 설정
	//http://docs.jquery.com/Plugins/Validation#Plugin_methods
	this.DATA_VALIDATE_MSG = new CubeMap(); // 다국어 지원을 위한 데이터 입력
	this.DATA_VALIDATE_MSG.put("required","{0}필수 입력항목입니다.");
	this.DATA_VALIDATE_MSG.put("minlength","{0}{1}자 이상 입력하세요.");
	this.DATA_VALIDATE_MSG.put("maxlength","{0}{1}자 초과 입력이 불가합니다.");
	this.DATA_VALIDATE_MSG.put("rangelength","{0}{1}자 이상 {2}자 이하로 입력하세요.");
	this.DATA_VALIDATE_MSG.put("email","{0}메일 형식에 맞게 입력하세요.");
	this.DATA_VALIDATE_MSG.put("url","{0}URL 형식에 맞게 입력하세요.");
	this.DATA_VALIDATE_MSG.put("number","{0}숫자 형식에 맞게 입력하세요.");
	this.DATA_VALIDATE_MSG.put("tel","전화번호 형식이 맞지 않습니다.");
	this.DATA_VALIDATE_MSG.put("equalTo","{0}{1}값만 입력 가능합니다.");
	this.DATA_VALIDATE_MSG.put("pair","{0} 입력시 {1} 필수 입력항목입니다.");
	this.DATA_VALIDATE_MSG.put("equal","{0}와 {1}의 값이 같지 않습니다.");
	this.DATA_VALIDATE_MSG.put("between","{1} {0} 보다 큰 값이어야 합니다.");
	this.DATA_VALIDATE_MSG.put("min","{0}{1}이상의 값이어야 합니다.");
	this.DATA_VALIDATE_MSG.put("max","{0}{1}이하의 값이어야 합니다.");
	this.DATA_VALIDATE_MSG.put("remote","{0} 값이 유효하지 않습니다.");
	this.DATA_VALIDATE_MSG.put("duplication","{0} 이미 사용중인 값입니다.");
	
	this.DATA_VALIDATE_MSG.put("newError","오류가 발생했습니다.\n다시 시도해 주십시요.");
	this.DATA_VALIDATE_MSG.put("msgAnd","은(는)");
	
	this.DATA_VALIDATE_MSG.put("updateDataDelete","삭제하시면 수정한 정보는 반영되지 않습니다.\n삭제하시겠습니까?");
	this.DATA_VALIDATE_MSG.put("createDataDelete","새로 입력한 데이터를 삭제합니다.\n삭제하시겠습니까?");
	this.DATA_VALIDATE_MSG.put("deleteBtnLabel","삭제");
	this.DATA_VALIDATE_MSG.put("copyBtnLabel","복사");
	this.DATA_VALIDATE_MSG.put("cancleBtnLabel","취소");
	this.DATA_VALIDATE_MSG.put("saveDataEmpty","저장할 데이터가 없습니다.");
	this.DATA_VALIDATE_MSG.put("saveDataAlert","{0}건의 데이터를 저장합니다.\n저장하시겠습니까?");
	
	//저장할 데이터가 없습니다.

	this.WEEK_NAME = ["일요일", "월요일", "화요일", "수요일", "목요일", "금요일", "토요일"]; // full calendar에 표시될 요일
	
	this.DATE_AM = "오전"; // calendar에 표시 
	this.DATE_PM = "오후";

	this.DATA_LABEL_ATT = "cubeDataLabel"; // validate 메시지 표시에 필요한 label 지정

	this.SELECT_OPTION_DATA_ATT = "cubeSelectDataOption"; // data연동한 select의 option을 표시 하기 위한 속성
	this.SELECT_DATA_VALUE_COLUMN = "VALUE_COL"; // combo완성시 value에 해당하는 column id
	this.SELECT_DATA_TEXT_COLUMN = "TEXT_COL"; // combo완성시 text에 해당하는 column id

	var DATA_COLUMN_DIVISION_CHAR = "↑"; // 데이터 통합전송시 컬럼을 구분하기위한 구분자
	var DATA_ROW_DIVISION_CHAR = "↓"; // 데이터 통합전송시 행을 구분하기 위한 구분자
};

// config를 사용하기 위해 전역변수로 선언한다.
var cubeConfig = new CubeConfig();

CubeCommon = function() {
	this.loadingViewType = true; // ajax호출시 자동으로 표시되는 loading의 표시 유무
	this.cubeLoadingCount = 0; // ajax의 비동기 호출 시 여러건의 call back을 감지하여 모두 완료되어야ㅣloading을 해지한다.
	this.$cubeFwAjaxIndicator; // loading시 화면을 블락한다. 
	this.$cubeFwIndicatorDiv; // loading이미지가 표시되는 영역
	this.$cubeFwUploadText; // ajax fileupload시 진행상태가 표시되는 영역
};
CubeCommon.prototype = {
	// loaging을 표시하기 위한 기본 영역을 생성한다.
	displayLoadingSet : function() {
		jQuery("<div id='cubeFwAjaxIndicator'></div>").appendTo('body');
		jQuery("<div id='cubeFwIndicatorDiv'><img alt='Indicator' src='/cubefw/images/indicator.gif' /> Loading... <span id='cubeFwUploadText'></span></div>").appendTo('body');
		
		this.$cubeFwAjaxIndicator = jQuery("#cubeFwAjaxIndicator");
		this.$cubeFwIndicatorDiv = jQuery("#cubeFwIndicatorDiv");
		this.$cubeFwUploadText = jQuery("#cubeFwUploadText");		
		
		this.$cubeFwAjaxIndicator.hide();
		this.$cubeFwIndicatorDiv.hide();
	},
	// logding을 사용하지 않도록 설정
	loadingViewOff : function() {
		this.loadingViewType = false;
	},
	// loading을 사용하도록 설정
	loadingViewOn : function() {
		this.loadingViewType = true;
	},
	// loading을 표시한다. type - true:표시, false:해지
	displayLoading : function(type) {
		if(!this.loadingViewType){
			return;
		}
		if(type){
			this.cubeLoadingCount++;
			if(this.cubeLoadingCount == 1){
				jQuery('body').mousemove(function(e){
					cubeCommon.$cubeFwIndicatorDiv.css({top:e.pageY, left:e.pageX+20});
				});
			
				this.$cubeFwAjaxIndicator.show();
				this.$cubeFwIndicatorDiv.show();
			}
		}else{
			this.cubeLoadingCount--;
			if(this.cubeLoadingCount == 0){
				this.$cubeFwAjaxIndicator.hide();
				this.$cubeFwIndicatorDiv.hide();
			}
		}
	},
	// 최초 loading 준비
	commonLoad : function(vId) {
		this.displayLoadingSet();
	},	
	// input에서 enter key조작시 특정 함수 호출
	enterKeyCheck : function(event, fncName) {
		if(event.keyCode == 13){
			try{
				eval(fncName);
			}catch(e){				
			}			
		}
	},
	// $obj jQuery객체에서 값을 셋팅한다.
	setElementValue : function($obj, data) {
		var tag = $obj[0].tagName;
		if(tag == "INPUT"){
			if($obj.attr("type") == 'checkbox'){
				if($obj.val() == data){
					$obj.attr("checked","checked");
				}
			}else if($obj.attr("type") == 'radio'){
				var rName = $obj.attr("name");
				jQuery('[name='+rName+']').each(function(i, findElement){
					$fObj = jQuery(findElement);
					if($fObj.val() == data){
						$fObj.attr("checked","checked");
						return;
					}
				});
			}else{
				$obj.val(data);
			}
		}else if(tag == "SELECT" || tag == "TEXTAREA"){
			$obj.val(data);
		}else{
			$obj.html(data);
		}
	},
	// $obj jQuery객체에 값을 추출한다.
	getElementValue : function($obj) {
		var tag = $obj.attr("tagName");
		if(tag == "INPUT" || tag == "SELECT" || tag == "TEXTAREA"){
			return $obj.val();
		}else{
			return $obj.html();
		}
	},
	// vId에 해당하는 jQuery객체를 가져온다. 지정 영역이 없는 경우 body전체를 영역으로 잡는다.
	getArea : function(vId) {
		var $obj;
		if(vId){
			if(typeof vId == "string"){
				$obj = jQuery("#"+vId);
			}else{
				$obj = jQuery(vId);
			}			
		}else{
			$obj = jQuery("body");
		}
		return $obj;
	},
	// obj의 타입을 가져온다.
	getObjType : function(obj) {
		var typeStr;
		if(obj instanceof Object){
			if(obj instanceof CubeMap){
				typeStr = "map";
			}else if(obj instanceof Array){
				typeStr = "array";
			}else if(obj instanceof jQuery){
				typeStr = "jquery";
			}else if(obj instanceof Element){
				typeStr = "element";
			}else{
				typeStr = "object";
			}
		}else{
			typeStr = (typeof obj);
		}
		return typeStr;
	},
	// obj의 값이 어떤 형태이건 jQuery객체로 반환한다.
	getJObj : function(obj) {
		var $obj;
		switch(this.getObjType(obj)){
			case "jquery":
				$obj = obj;
				break;
			case "string":
			case "number":
				$obj = jQuery("#"+obj);
				break;
			default:
				$obj = jQuery(obj);
		}
		return $obj;
	},
	// 지정한 obj의 id를 반환한다.
	getObjId : function(obj) {
		var idStr;
		switch(this.getObjType(obj)){
			case "element":
				idStr = obj.id;
				break;
			default:
				$obj = this.getJObj(obj).attr("id");
		}
		return $obj;
	},
	// obj가 어떤 형태이건 값이 없는지 판단한다.
	isEmpty : function(obj) {
		var isStr = false;
		if(obj){
			if(obj instanceof Object){
				if(obj instanceof CubeMap){
					isStr = (obj.size() == 0);
				}else if(obj instanceof Array){
					isStr = (obj.length == 0);
				}else if(obj instanceof jQuery){
					isStr = (obj.length == 0);
				}
			}
		}else{
			isStr = true;
		}
		return isStr;
	},
	// obj가 어떤 형태이건 값이 있는지 판단한다.
	isNotEmpty : function(obj) {
		return !this.isEmpty(obj);
	},
	// obj가 Empty이면 지정한 val을 리턴한다.
	NVL : function(obj, val) {
		if(obj){
			return obj;
		}else{
			return val;
		}
	},
	// popup을 open한다.
	popupOpen : function(url, width, height) {
		window.open(url,'cubePopup','width='+width+',height='+height+',scrollbars=yes');
	},
	// 해당 txt를 화면에 보여준다.
	msg : function(txt) {
		alert(txt);
	},
	// data의 길이가 len보다 작으면 왼쪽부터 char를 채운다.
	leftPadding : function(data, char, len) {
		if(typeof data == "string"){
			return this.fillString(char, len-data.length)+data;
		}else if(typeof data == "number"){
			this.dateZeroFormat(data+"", len);
		}
	},
	// char를 len개수만큼 만들어서 리턴한다.
	fillString : function(char, len) {
		var s = '', i = 0;
		while (i++ < len) { 
			s += char; 
		}
		return s;
	},
	// str에 포함된 char를 nChar로 변경한다.
	replaceAll : function(str, char, nChar) {
		var data;
		if(typeof str == "number"){
			data = str + "";
		}else{
			data = str;
		}
		data = data.split(char).join(nChar);
		/*
		var index = 0;
		while((index = data.indexOf(char, index)) != -1){
			data = data.substring(0, index)+nChar+data.substring(index+char.length);
		}
		*/
		return data;
	},
	toString : function() {
		return "CubeCommon";
	}
};

var cubeCommon = new CubeCommon();

// grid에서 선택된 row의 정보를 추출하기 위한 객체
CubeGridRow = function(obj) {
	this.$rowObj = jQuery(obj).parents("["+cubeConfig.DATA_ROW_ATT+"]"); // obj이 포함된 row객체를 찾는다.
	this.data = new CubeMap();	
	var $tmpData = this.data; // jQuery each문에서는 prototype의 this접근이 불가하므로 임시 변수에 담아준다.
	//row에 포함된 데이터 값들은 name을 key로 data에 put한다.
	this.$rowObj.find("input,textarea").each(function(i, findElement){
		var $obj = jQuery(findElement);
		$tmpData.put($obj.attr("name"), $obj.val());
	});
	// select의 경우 value와 text를 함께 추출하기 위해 구분한다. text는 select의 name에 cubeConfig.DATA_COMBO_SELECTED_TEXT_TAIL를 붙여 키로 저장한다.
	this.$rowObj.find("select").each(function(i, findElement){
		var $obj = jQuery(findElement);
		$tmpData.put($obj.attr("name"), $obj.val());
		$tmpData.put($obj.attr("name")+cubeConfig.DATA_COMBO_SELECTED_TEXT_TAIL, $obj.find("option:selected").text());
	});
};

CubeGridRow.prototype = {
	// 해당 row의 상태를 리턴한다. CRUD
	getRowStates : function() {
		return this.$rowObj.attr(cubeConfig.DATA_ROW_STATE_ATT);
	}
};

// ajax, form등의 데이터 통신을 위한 객체
CubeNet = function() {
	
};

CubeNet.prototype = {
	// request, response모두 json으로 비동기 통신한다.
	// sendUrl - request url, [map] request parameter, [successFunction] 정상 callback 시 실행 함수, [failFunction] 실패 callback 시 실행 함수, [param] callback 함수에 전달한 데이터
	sendJsonAjax : function(sendUrl, map, successFunction, failFunction, param) {
		cubeCommon.displayLoading(true); // loading을 표현하기 위한 처리
		var jsonStr;
		if(map == null){
			jsonStr = "";
		}else if(typeof map == "string"){
			jsonStr = map;
		}else{
			jsonStr = map.jsonString();
		}
		jQuery.ajax({
			type: "post",
			url: sendUrl,
			data: jsonStr,
			dataType: "json",
			error: function(a, b, c){
				cubeCommon.displayLoading(false);
		        if(failFunction){
		        	try{
		        		eval(failFunction+"(a, b, c, param)");
		        	}catch(e){
			    	}		        	        			        				        	
		        }else{
		        	cubeNet.defaultFailFunction(a, b, c);
		        }		        
		    },
		    success: function (json) {
		    	try{
		    		if(successFunction != null){
			    		eval(successFunction+"(json, param)");
			    	}		    	
		    	}catch(e){	    		
		    	}
		    	cubeCommon.displayLoading(false);
		    }
		});
	},
	// request, response모두 json으로 동기 통신한다.
	// sendUrl - request url, [map] request parameter
	sendJsonData : function(sendUrl, map) {
		cubeCommon.displayLoading(true);
		var jsonStr;
		if(map == null){
			jsonStr = "";
		}else if(typeof map == "string"){
			jsonStr = map;
		}else{
			jsonStr = map.jsonString();
		}
		var returnData;
		jQuery.ajax({
			type: "post",
			url: sendUrl,
			async: false,
			data: jsonStr,
			dataType: "json",			
			error: function(a, b, c){				
		        cubeCommon.displayLoading(false);
		        cubeNet.defaultFailFunction(a, b, c);
		    },
		    success: function (json) {		    	
		    	cubeCommon.displayLoading(false);
		    	returnData = json;
		    }
		});
		return returnData;
	},
	// form 전송을 비동기로 처리한다.
	// formId - request form tag id, [successFunction] 정상 callback 시 실행 함수, [failFunction] 실패 callback 시 실행 함수, [param] callback 함수에 전달한 데이터
	sendFormAjax : function(formId, successFunction, failFunction, param) {
		var $formObj = jQuery("#"+formId);
		var sendUrl = $formObj.attr("action");
		$formObj.ajaxForm({
			type: "post",
			url: sendUrl,
			uploadProgress: function(event, position, total, percentComplete){
				cubeCommon.$cubeFwUploadText.html(percentComplete+"%");
		    },
			beforeSubmit:function() { 
				cubeCommon.displayLoading(true);
				return cubeValidate.validateCheck(formId);
		    },
		    error: function(a, b, c){			
		        if(failFunction){
		        	try{
		        		eval(failFunction+"(a, b, c, param)");
		        	}catch(e){	    		
			    	}
		        }else{
		        	cubeNet.defaultFailFunction(a, b, c);
		        }
		        cubeCommon.displayLoading(false);
		    },
		    success: function (data) {
		    	try{
		    		if(successFunction){
			    		eval(successFunction+"(data, param)");
			    	}		    	
		    	}catch(e){
		    	}
		    	cubeCommon.displayLoading(false);
		    }
		});
	},
	// formId의 form tag를 submit한다.
	sendForm : function(formId) {
		jQuery("#"+formId).trigger('submit');
	},
	// sendUrl에서 받은 html을 리턴한다.
	getHtmlData : function(sendUrl) {
		try{
			cubeCommon.displayLoading(true);
			var returnData;
			jQuery.ajax({
				type: "get",
				async: false,
				url: sendUrl,
				dataType: "html",
				error: function(a, b, c){				
			        cubeCommon.displayLoading(false);
			        cubeNet.defaultFailFunction(a, b, c);
			    },
			    success: function(html) {
			    	cubeCommon.displayLoading(false);
			    	returnData = html;
			    }
			});
			return returnData;
		}catch(e){
			cubeCommon.msg("CubeNet.getHtmlData : "+e);
		}
	},
	// ajax 실패 call back 함수가 없는 경우 기본 실행 함수
	defaultFailFunction : function(a, b, c) {
		cubeCommon.msg(cubeConfig.DATA_VALIDATE_MSG.get("netError")+ a +' / ' + b +' / ' + c);
	},	
	toString : function() {
		return "CubeNet";
	}
};

var cubeNet = new CubeNet();

// 데이터 처리를 위한 객체
CubeBind = function() {
	this.cubeDataGridMap = new CubeMap(); // grid 객체를 저장
	this.cubeDataGridRowMap = new CubeMap(); // grid에 bind될 row객체를 저장
	this.cubeDataGridPagingMap = new CubeMap(); // grid에 연결된 paging객체를 저장
	this.cubeDataGridPageinfoMap = new CubeMap(); // grid에 연결된 page info객체를 저장
	// this.cubeDataGridTitleMap = new CubeMap(); // 최초 row추가시 어떤 객체 뒤에 붙일지 판단 
};

CubeBind.prototype = {
	// combo 자동완성 기능 적용	
	comboScan : function(areaId) {
		try{
			var $scanArea = cubeCommon.getArea(areaId);
			
			// cubeDataCommonCombo="common code"
			var $dataCommonComboList = $scanArea.find("["+cubeConfig.DATA_COMMON_COMBO_ATT+"]");
			for(var i=0;i<$dataCommonComboList.length;i++){
				var commonCode = $dataCommonComboList.eq(i).attr(cubeConfig.DATA_COMMON_COMBO_ATT);
				var map = new CubeMap();
				map.put("ID", commonCode);
				
					var json = cubeNet.sendJsonData("/cubefw/CubeCommon/list/cubeJson/CFCMCD0011S.cube", map);
					this.selectBind($dataCommonComboList.eq(i), json.data);
				
			}
			
			// cubeDataCombo="모듈,sql id" - VALUE_COL, TEXT_COL
			var $dataComboList = $scanArea.find("["+cubeConfig.DATA_COMBO_ATT+"]");
			for(var i=0;i<$dataComboList.length;i++){
				var comboCode = $dataComboList.eq(i).attr(cubeConfig.DATA_COMBO_ATT).split(",");
					var json = cubeNet.sendJsonData("/cubefw/"+comboCode[0]+"/list/cubeJson/"+comboCode[1]+".cube");
					this.selectBind($dataComboList.eq(i), json.data);
			}
		}catch(e){
			cubeCommon.msg("CubeBind.comboScan : "+e);
		}
	},
	// 데이터 변화에 따라 새로운 combo data를 메핑해야 하는 경우 사용
	// cubeDataSearchCombo="모듈,sql id,request param id" - VALUE_COL, TEXT_COL
	// request param id 객체의 value를 추출하여 CODE키로 전송
	searchComboScan : function(tmpRowHtml) {
		try{
			var $tmpRowObj = jQuery(tmpRowHtml);
			
			var $dataComboList = $tmpRowObj.find("["+cubeConfig.DATA_SEARCH_COMBO_ATT+"]");
			for(var i=0;i<$dataComboList.length;i++){
				var comboCode = $dataComboList.eq(i).attr(cubeConfig.DATA_SEARCH_COMBO_ATT).split(",");
				var map = new CubeMap();
				map.put("CODE", jQuery("#"+comboCode[2]).val());
				
				var json = cubeNet.sendJsonData("/cubefw/"+comboCode[0]+"/list/cubeJson/"+comboCode[1]+".cube", map);
				this.selectBind($dataComboList.eq(i), json.data);
			}
			return $tmpRowObj.wrapAll("<div/>").parent();
		}catch(e){
			cubeCommon.msg("CubeBind.searchComboScan : "+e);
		}
	},
	// areaId 내에 포함된 grid를 찾아서 사용 가능하도록 준비시킴
	gridScan : function(areaId) {
		var $scanArea = cubeCommon.getArea(areaId);
		var $dataGridList = $scanArea.find("["+cubeConfig.DATA_GRID_ATT+"]");
		for(var i=0;i<$dataGridList.length;i++){
			this.gridInfoSave($dataGridList.eq(i));
		}
	},
	// $grid를 grid로 사용 가능하도록 준비시킴
	// rowAttr - default cubeConfig.DATA_ROW_ATT
	gridInfoSave : function($grid, rowAttr) {
		$grid = cubeCommon.getJObj($grid);
		rowAttr = cubeCommon.NVL(rowAttr, cubeConfig.DATA_ROW_ATT);
		
		var gridId = $grid.attr("id");
		this.cubeDataGridMap.put(gridId, $grid);			
		var $tmpObj = $grid.find('['+rowAttr+']');
		var $dataRow = $tmpObj.clone(true);
		$tmpObj.remove();
		$dataRow.removeClass(cubeConfig.DATA_ROW_CLASS);// grid row가 최초 화면에서 보이지 않도록 처리한 class를 제거해준다.
		$dataRow.attr(cubeConfig.DATA_ROW_STATE_ATT, cubeConfig.DATA_ROW_STATE_START);// grid row state를 초기화 한다. 'S'
		
		// grid에 자동생성 delete button 설정이 있는 경우 button을 추가해준다.
		$dataRow.find("["+ cubeConfig.DATA_ROW_DELETE_BTN +"]").each(function(i, findElement){
			$obj = jQuery(findElement);
			jQuery("<span onclick='cubeBind.gridRowDelete(this);' cubeDataType='gridButton'>"+cubeConfig.DATA_VALIDATE_MSG.get("deleteBtnLabel")+"</span>").appendTo($obj);
		});
		// grid에 copy button 설정이 있는 경우 button을 추가해준다.
		$dataRow.find("["+ cubeConfig.DATA_ROW_COPY_BTN +"]").each(function(i, findElement){
			$obj = jQuery(findElement);
			jQuery("<span onclick='cubeBind.gridRowCopy(this,\""+gridId+"\");' cubeDataType='gridButton'>"+cubeConfig.DATA_VALIDATE_MSG.get("copyBtnLabel")+"</span>").appendTo($obj);
		});
		
		// row가 있는 경우 map에 저장한다.
		if($dataRow.length){
			this.cubeDataGridRowMap.put(gridId, $dataRow.wrapAll("<div/>").parent().html());
			//alert(cubeDataGridRowMap.get(dataTableList[i].id));
		}
		
		// paging에 관련된 객체들을 저장해준다.
		var $paging = jQuery("["+cubeConfig.DATA_GRID_PAGING_ATT+"="+gridId+"]");
		this.cubeDataGridPagingMap.put(gridId, $paging);
		var $pageinfo = jQuery("["+cubeConfig.DATA_GRID_PAGEINFO_ATT+"="+gridId+"]");
		this.cubeDataGridPageinfoMap.put(gridId, $pageinfo);
		
		// grid에서 관리할 기본 데이터를 셋팅한다.
		$grid.attr(cubeConfig.LIST_PAGE_TOTAL_COUNT_ATT, "1");
		$grid.attr(cubeConfig.LIST_PAGE_SELECT_NUM_ATT, "1");
		$grid.attr(cubeConfig.LIST_PAGE_MAX_ATT, "1");
	},
	// gridId의 grid에 출력된 row의 개수를 저장한다.
	// row추가시 첫 row인지 판단하는 근거가 된다.
	gridRowPrintNum : function(gridId, num) {
		var $dataTable = cubeCommon.getJObj(gridId);
		num = cubeCommon.NVL(num, 0);
		$dataTable.attr(cubeConfig.DATA_ROW_PRINT_NUM, num);
	},	
	// gridId에 새로운 row를 추가해준다.
	gridNewRow : function(gridId) {
		var $dataTable = cubeCommon.getJObj(gridId);
		var tmpRowHtml = this.cubeDataGridRowMap.get(gridId);
		var $tmpRowObj = this.searchComboScan(tmpRowHtml);// row에 포함된 search combo가 있는지 확인해서 처리한다.
		$tmpRowObj.find("input,select,textarea").val(""); // 입력값들을 초기화 해준다.	
		tmpRowHtml = $tmpRowObj.html();

		// grid row data bind를 위한 표기값들을 지워준다.
		while(tmpRowHtml.indexOf(cubeConfig.DATA_COLUMN_NAME_HEAD) != -1){
			tmpRowHtml = tmpRowHtml.substring(0,tmpRowHtml.indexOf(cubeConfig.DATA_COLUMN_NAME_HEAD))
						+ tmpRowHtml.substring(tmpRowHtml.indexOf(cubeConfig.DATA_COLUMN_NAME_TAIL)+cubeConfig.DATA_COLUMN_NAME_TAIL.length);
		}

		var rowLength = $dataTable.attr(cubeConfig.DATA_ROW_PRINT_NUM); // 출력되어진 row개수를 구한다.
		rowLength = parseInt(rowLength)+1; // 1줄이 더 추가되므로 1을 더해준다.
		// 출력해야될 row에 row num을 찍어야 하는 부분이 있는지 확인해서 처리한다.
		while(tmpRowHtml.indexOf(cubeConfig.DATA_COLUMN_ROWNUM) != -1){
			tmpRowHtml = tmpRowHtml.replace(cubeConfig.DATA_COLUMN_ROWNUM, rowLength);
		}
		this.gridRowPrintNum(gridId, rowLength);// 출력되어진 row개수를 저장한다.
		return jQuery(tmpRowHtml);
	},
	// gridId에 row를 추가한다.
	gridAddRow : function(gridId) {
		var $newRow = this.gridNewRow(gridId); // 새로운 row를 생성한다.
		var $dataTable = jQuery("#"+gridId);
		var $dataRow = $dataTable.find("["+cubeConfig.DATA_ROW_ATT+"]"); // grid에 포함된 row를 찾는다.
		if($dataRow.length){ // row가 있는 경우 row들 가장 앞에 추가해준다.
			$dataRow.eq(0).before($newRow);
		}else{ // row가 없는 경우 가장 뒤에 추가해준다.
			$newRow.appendTo($dataTable);
		}
		// row를 처리하기전 화면에 보여주기 위한 사전 작업을 한다.
		this.bindGridBeforeView($dataTable.find('['+cubeConfig.DATA_ROW_STATE_ATT+'='+cubeConfig.DATA_ROW_STATE_START+']'), true);
	},
	// copyBtn이 포함된 row를 복사해서 추가해준다.
	gridRowCopy : function(copyBtn, gridId) {
		$obj = jQuery(copyBtn);
		$row = $obj.parents("["+cubeConfig.DATA_ROW_ATT+"]"); // copyBt이 포함된 row를 찾는다.
		
		var $newRow = this.gridNewRow(gridId); // 새로운 row를 생성한다.
		
		// 복사원본의 row에 입력된 값들을 생성된 row에 복사해준다.
		var $rowElements = $row.find("input,select,textarea");
		$newRow.find("input,select,textarea").each(function(i, findElement){
			$obj = jQuery(findElement);
			$obj.val($rowElements.eq(i).val());
			$obj.attr(cubeConfig.DATA_COLUMN_VALUE, $rowElements.eq(i).attr(cubeConfig.DATA_COLUMN_VALUE));	
		});

		$newRow.insertBefore($row); // 원본 row앞에 생성된 row를 추가한다.
		
		// row를 처리하기전 화면에 보여주기 위한 사전 작업을 한다.
		var $dataTable = jQuery("#"+gridId);
		this.bindGridBeforeView($dataTable.find('['+cubeConfig.DATA_ROW_STATE_ATT+'='+cubeConfig.DATA_ROW_STATE_START+']'), true);
	},
	// gridId에 data를 bind한다.
	// editGridType - grid가 edit가능한지 설정한다.
	// groupCount - row obj가 data의 여러 행을 처리하는 경우 개수를 설정한다.
	// appendType - true인 경우 기존 데이터를 삭제하지 않고 계속 추가한다.
	gridBind : function(gridId, data, editGridType, groupCount, appendType) {
		var start;
		if(cubeConfig.PERFORMANCE_TRACE_ADVICE){
			start = new Date();
		}
		if(!groupCount){
			groupCount = 1;
		}
		if(!appendType){
			appendType = false;
		}
		
		var $dataTable = cubeCommon.getJObj(gridId); // grid 객체를 가져온다.
		var $gridRows = $dataTable.find('['+cubeConfig.DATA_ROW_ATT+']'); // row집합을 가져온다.
		// data도 없고, row도 없으면 중단한다.
		if(data.length == 0 && $gridRows.length == 0){
			return;
		}
		
		var printRowNum = 0; // 화면에 출력된 row의 개수를 저장하기 위한 변수
		// append type이 아닌경우 기존 row를 삭제한다.
		if(!appendType){
			$gridRows.remove();
		}else{
			printRowNum = $gridRows.length;
		}
		var rowHtmlList = new Array(); // 추가된 row들의 html을 담을 객체
		var replaceCount = 0; // groupCount를 처리하기 위해 처리한 row의 개수를 저장한다.
		var colReplaceName = ""; // 데이터 처리 부분의 문자열
		var colNumTail = ""; // groupCount가 있는 경우 groupCount 구분을 위해 사용 [0],[1]...
		var rowHtml  = this.cubeDataGridRowMap.get(gridId); // row에 사용될 html
		var $rowObj = this.searchComboScan(rowHtml); // row에 search combo가 있는 경우 해당 combo에 데이터를 추가해준다.
		this.cubeDataGridRowMap.put(gridId, $rowObj.html()); // 수정된 row html을 다시 저장해준다.
		
		for(var i=0;i<data.length;i++){
			var tmpRowHtml  = this.cubeDataGridRowMap.get(gridId); // row의 html을 꺼내온다.
			// row에 rownum 표시가 필요한 경우 표시해준다.
			while(tmpRowHtml.indexOf(cubeConfig.DATA_COLUMN_ROWNUM) != -1){
				tmpRowHtml = tmpRowHtml.replace(cubeConfig.DATA_COLUMN_ROWNUM, i);
			}
			replaceCount = 0; // 처리한 row의 개수를 초기화 해준다.	
			while(replaceCount < groupCount){ // groupCount 만큼 row를 처리했는지 확인한다.
				// group count가 설정된 경우 처리한 문자열을 추가해준다.
				if(groupCount > 1){
					colNumTail = "["+replaceCount+"]";
				}else{
					colNumTail = "";
				}
				// data의 값들을 row의 지정 문자열에 replace해준다.
				for (var prop in data[i]) {			
					colReplaceName = cubeConfig.DATA_COLUMN_NAME_HEAD+prop+colNumTail+cubeConfig.DATA_COLUMN_NAME_TAIL;
					while(tmpRowHtml.indexOf(colReplaceName) != -1){
						tmpRowHtml = tmpRowHtml.replace(colReplaceName, data[i][prop]);
					}
				}
				replaceCount++; // row처리 후 count를 증가시킨다.
				
				// group count가 설정된 경우 data만 새로운 row로 가져온다.
				if(groupCount > 1 && replaceCount < groupCount){
					i++;
					if(i==data.length){
						break;
					}
				}
			}
			printRowNum++; // 화면에 보이는 row개수를 처리하기 위해 증가시킨다.
			rowHtmlList.push(tmpRowHtml); // row html을 저장하는 공간에 데이터가 입력된 row html을 추가해준다.
		}

		this.gridRowPrintNum(gridId, printRowNum); // 화면에 표시된 row개수를 저장해준다.
		
		if(cubeConfig.PERFORMANCE_TRACE_ADVICE){
			var end = new Date();
			var traceTime = (end - start)/1000;
			jQuery("<br/><span>row : "+data.length+" / second : "+traceTime+"</span>").appendTo("body");
		}
		var newHtml = $dataTable.html()+rowHtmlList.join("\n");
		$dataTable.html(newHtml);	
		
		// edit grid인 경우 화면에 표시된 데이터를 처리해준다.
		if(editGridType){
			this.bindGridBeforeView($dataTable.find('['+cubeConfig.DATA_ROW_STATE_ATT+'='+cubeConfig.DATA_ROW_STATE_START+']'));
		}
		
		if(cubeConfig.PERFORMANCE_TRACE_ADVICE){
			var end = new Date();
			var traceTime = (end - start)/1000;
			jQuery("<br/><span>row : "+data.length+" / second : "+traceTime+"</span>").appendTo("body");
		}
	},
	// edit grid인 경우 row들의 데이터 화면 표시를 위해 처리해준다.
	// new row인 경우 createType을 true로 지정한다.
	bindGridBeforeView : function($dataRow, createType) {
		// select인 경우 cubeDataValue속성에 있는 값으로 selected해준다.
		$dataRow.find("select["+cubeConfig.DATA_COLUMN_VALUE+"]").each(function(i, findElement){
			$obj = jQuery(findElement);
			$obj.val($obj.attr(cubeConfig.DATA_COLUMN_VALUE));			
		});
		
		// checkbox인 경우 cubeDataValue속성에 있는 값으로 checked해준다.
		$dataRow.find(":checkbox["+cubeConfig.DATA_COLUMN_VALUE+"]").each(function(i, findElement){
			$obj = jQuery(findElement);
			if($obj.val() == $obj.attr(cubeConfig.DATA_COLUMN_VALUE)){
				$obj.attr("checked","checked");
			}
		});
		
		// radio인 경우 cubeDataValue속성에 있는 값으로 checked해준다.
		$dataRow.find(":radio["+cubeConfig.DATA_COLUMN_VALUE+"]").each(function(i, findElement){
			$obj = jQuery(findElement);
			if($obj.val() == $obj.attr(cubeConfig.DATA_COLUMN_VALUE)){
				$obj.attr("checked","checked");
			}
		});	
		
		// 입력 값이 수정되면 row의 stat를 변경해주는 이벤트를 추가해준다.
		$dataRow.find("select,input,textarea").bind("change", function(event){
			$obj = jQuery(this);
			$row = $obj.parents("["+cubeConfig.DATA_ROW_ATT+"]");

			// row의 state에 따라서 처리해준다.
			switch($row.attr(cubeConfig.DATA_ROW_STATE_ATT)){
				case "R":
					cubeBind.gridRowStateChange($row, cubeConfig.DATA_ROW_STATE_UPDATE); // 조회 상태인 경우 수정으로 변경
					break;
			}				
		});
		
		cubeUI.typeCheck($dataRow); // 추가될 row에 button, calendar등의 data type 속성을 처리해준다.
		
		// new row인 경우 readonly 입력값 중 입력 가능하도록 변경해야 하는 부분을 처리해준다.
		if(createType){
			cubeBind.gridRowStateChange($dataRow, cubeConfig.DATA_ROW_STATE_CREATE);
			$dataRow.find("["+cubeConfig.DATA_COLUMN_CREATE_VALUE+"]").each(function(i, findElement){
				$obj = jQuery(findElement);
				$obj.removeAttr("readonly");
				$obj.removeClass("readonlyColumn");
			});
		}else{
			// new row가 아닌 경우 state를 R로 변경해준다.
			$dataRow.attr(cubeConfig.DATA_ROW_STATE_ATT, cubeConfig.DATA_ROW_STATE_READ);
		}		
	},
	// 해당 row의 상태를 stateAttr값으로 변경해 준다. CRUD
	gridRowStateChange : function($row, stateAttr) {
		$row.attr(cubeConfig.DATA_ROW_STATE_ATT, stateAttr);
		$row.find("["+cubeConfig.DATA_ROW_STATE_ATT+"]").each(function(i, findElement){
			cubeCommon.setElementValue(jQuery(findElement), $row.attr(cubeConfig.DATA_ROW_STATE_ATT));
		});
	},
	// 해당 row를 삭재해준다.
	gridRowDelete : function(deleteBtn) {
		$obj = jQuery(deleteBtn);
		$row = $obj.parents("["+cubeConfig.DATA_ROW_ATT+"]");

		switch($row.attr(cubeConfig.DATA_ROW_STATE_ATT)){
			case "U":
				// 수정 상태인 경우 확인 후 삭제처리한다.
				if(!confirm(cubeConfig.DATA_VALIDATE_MSG.get("updateDataDelete"))){
					$row.addClass("deleteRow"); // 삭제 로우 표시를 위한 class를 적용한다.
					break;
				}
			case "R":
				// 조회의 경우 삭제 처리한다.
				cubeBind.gridRowStateChange($row, cubeConfig.DATA_ROW_STATE_DELETE);
				$row.addClass("deleteRow");
				// 삭제 버튼을 삭제취소 버튼으로 변경한다.
				$row.find("["+ cubeConfig.DATA_ROW_DELETE_BTN +"]").find(".ui-button-text").text(cubeConfig.DATA_VALIDATE_MSG.get("cancleBtnLabel"));
				break;
			case "C":
				// 생성 row인 경우 row를 완전 삭제한다.
				if(confirm(cubeConfig.DATA_VALIDATE_MSG.get("createDataDelete"))){
					$row.remove();
				}
				break;
			case "D":
				// 삭제상태인 경우 삭제 취소 처리된다.
				cubeBind.gridRowStateChange($row, cubeConfig.DATA_ROW_STATE_READ);
				$row.removeClass("deleteRow");
				// 삭제 취소 버튼을 삭제버튼으로 변경한다.
				$row.find("["+ cubeConfig.DATA_ROW_DELETE_BTN +"]").find(".ui-button-text").text(cubeConfig.DATA_VALIDATE_MSG.get("deleteBtnLabel"));
				break;			
		}
	},	
	// data를 areaId내이 객체 id들과 bind한다.
	dataBind : function(data, areaId) {
		var start;
		if(cubeConfig.PERFORMANCE_TRACE_ADVICE){
			start = new Date();
		}
		
		var $dataArea = cubeCommon.getArea(areaId);
		
		for (var prop in data) {
			var $obj = jQuery("#"+prop);
			if($obj.length){
				// web editor인 경우 데이터 처리
				if($obj.attr(cubeConfig.DATA_TYPE_ATT) == cubeConfig.DATA_TYPE_EDITOR){
					$obj.val(data[prop]);
				}else{
					cubeCommon.setElementValue($obj, data[prop]);
				}			
			}
		}

		if(cubeConfig.PERFORMANCE_TRACE_ADVICE){
			var end = new Date();
			var traceTime = (end - start)/1000;
			jQuery("<br/><span>row : "+data.length+" / second : "+traceTime+"</span>").appendTo("body");
		}
	},
	// map에 있는 데이터를 areaId내이 객체 name들과 bind한다.
	// name의 중복등으로 구분을 위한 tail이 붙어 있는 경우 key+tail로 name을 찾아 bind한다.
	dataNameBind : function(map, areaId, tail) {
		var $dataArea = cubeCommon.getArea(areaId);
		if(!tail){
			tail = "";
		}
		var keyList = map.keys();
		for(var i=0;i<keyList.length;i++){
			var $obj = $dataArea.find("[name="+keyList[i]+tail+"]");
			var value = map.get(keyList[i]);
			if($obj.length){
				// web editor인 경우 데이터 처리
				if($obj.attr(cubeConfig.DATA_TYPE_ATT) == cubeConfig.DATA_TYPE_EDITOR){
					$obj.val(data[prop]);
				}else{
					cubeCommon.setElementValue($obj, value);
				}			
			}
		}
	},
	// map에 있는 데이터를 areaId내이 객체 id들과 bind한다.
	// id의 중복등으로 구분을 위한 tail이 붙어 있는 경우 key+tail로 id를 찾아 bind한다.
	dataIdBind : function(map, areaId, tail) {
		var $dataArea = cubeCommon.getArea(areaId);
		if(!tail){
			tail = "";
		}
		var keyList = map.keys();
		for(var i=0;i<keyList.length;i++){
			var $obj = $dataArea.find("[id="+keyList[i]+tail+"]");
			var value = map.get(keyList[i]);
			if($obj.length){
				if($obj.attr(cubeConfig.DATA_TYPE_ATT) == cubeConfig.DATA_TYPE_EDITOR){
					$obj.val(data[prop]);
				}else{
					cubeCommon.setElementValue($obj, value);
				}			
			}
		}
	},
	// areaId에 있는 입력값들을 삭제한다.
	dataClear : function(areaId) {
		var $dataArea = cubeCommon.getArea(areaId);
		
		$dataArea.find("input,select,textarea").each(function(i, findElement){
			var $obj = jQuery(findElement);
			cubeCommon.setElementValue($obj, "");
		});
	},
	// grid의 paging정보를 해당 gird를 바라보고 있는 grid info에 적용해준다.
	gridPageInfoBind : function(gridId) {
		var $gridPageInfo = this.cubeDataGridPageinfoMap.get(gridId);
		var $grid = this.cubeDataGridMap.get(gridId);
		for(var i=0;i<$gridPageInfo.length;i++){
			cubeCommon.setElementValue($gridPageInfo.eq(i).find("["+cubeConfig.LIST_PAGE_TOTAL_COUNT_ATT+"]"), $grid.attr(cubeConfig.LIST_PAGE_TOTAL_COUNT_ATT));
			cubeCommon.setElementValue($gridPageInfo.eq(i).find("["+cubeConfig.LIST_PAGE_SELECT_NUM_ATT+"]"), $grid.attr(cubeConfig.LIST_PAGE_SELECT_NUM_ATT));
			cubeCommon.setElementValue($gridPageInfo.eq(i).find("["+cubeConfig.LIST_PAGE_MAX_ATT+"]"), $grid.attr(cubeConfig.LIST_PAGE_MAX_ATT));
		}		
	},
	// gird의 page count(한페이지당 출력 개수)를 변경한다.
	gridPageCountChange : function(gridId, count) {
		var $grid = this.cubeDataGridMap.get(gridId);
		this.gridPageCountReset(gridId, count);
		var pageEvent = $grid.attr(cubeConfig.DATA_GRID_ATT);
		try{
			eval(pageEvent);// page count가 변경되어 다시 조회를 한다.
		}catch(e){
		}
	},
	// gird의 page count(한페이지당 출력 개수)를 설정한다.
	gridPageCountReset : function(gridId, count) {
		var $grid = this.cubeDataGridMap.get(gridId);
		$grid.attr(cubeConfig.LIST_PAGE_SELECT_NUM_ATT, "1");
		$grid.attr(cubeConfig.LIST_PAGE_COUNT_NUM_ATT, count);
	},
	// grid paging을 만들어 준다.
	gridPageBind : function(gridId, data) {
		var $gridPage = this.cubeDataGridPagingMap.get(gridId);
		var $grid = this.cubeDataGridMap.get(gridId);
		var pageNum = parseInt($grid.attr(cubeConfig.LIST_PAGE_SELECT_NUM_ATT));
		var pageCount = parseInt($grid.attr(cubeConfig.LIST_PAGE_COUNT_NUM_ATT));
		
		var totalCount = parseInt(data);
		$grid.attr(cubeConfig.LIST_PAGE_TOTAL_COUNT_ATT, totalCount);
		if(totalCount == 0){
			totalCount = 1;
		}
		var maxPage = parseInt(totalCount / pageCount);
		if((totalCount % pageCount) != 0){
			maxPage++;
		}
		
		var prevpage = (pageNum==1?1:(pageNum-1));	
		var nextPage = (pageNum==maxPage?maxPage:(pageNum+1));	
				
		$grid.attr(cubeConfig.LIST_PAGE_MAX_ATT, maxPage);
		var startPage= parseInt((pageNum/cubeConfig.LIST_PAGE_NUM_LIST_DEFAULT_COUNT));
		if(pageNum%cubeConfig.LIST_PAGE_NUM_LIST_DEFAULT_COUNT == 0){
			startPage--;
		}
		startPage = startPage*10+1;
		
		var maxListPage = maxPage;
		if(maxListPage >= (startPage+cubeConfig.LIST_PAGE_NUM_LIST_DEFAULT_COUNT)){
			maxListPage = startPage+cubeConfig.LIST_PAGE_NUM_LIST_DEFAULT_COUNT-1;
		}
		
		$gridPage.html(pageNum+","+pageCount+","+data);
		var pagingTag = "<div class='cubePageList'>"
					  + "<a href='#' alt='처음' onclick='cubeBind.gridPageChange(\""+gridId+"\",\"1\");return false;'"
					  + " class='cubePageBtn cubePageBtnFirst' >&nbsp;&nbsp;&nbsp;&nbsp;</a>"
					  + "<a href='#' alt='이전' onclick='cubeBind.gridPageChange(\""+gridId+"\",\""+prevpage+"\");return false;'"
					  + " class='cubePageBtn cubePageBtnPrev' >&nbsp;&nbsp;&nbsp;&nbsp;</a>";
		
		for(var i=startPage;i<=maxListPage;i++){		
			pagingTag += "<a href='#' onclick='cubeBind.gridPageChange(\""+gridId+"\",\""+i+"\");return false;' class='cubePageNum'>&nbsp;";
			if(i == pageNum){
				pagingTag += "<strong>"+i+"</strong>";
			}else{
				pagingTag += i;
			}
			pagingTag += "&nbsp;</a>";
		}
		pagingTag += "<a href='#' alt='다음' onclick='cubeBind.gridPageChange(\""+gridId+"\",\""+nextPage+"\");return false;'"
				   + " class='cubePageBtn cubePageBtnNext' >&nbsp;&nbsp;&nbsp;&nbsp;</a>"
				   + "<a href='#' alt='끝' onclick='cubeBind.gridPageChange(\""+gridId+"\",\""+maxPage+"\");return false;'"
				   + " class='cubePageBtn cubePageBtnLast' >&nbsp;&nbsp;&nbsp;&nbsp;</a>";
		
		pagingTag +="</span>";
		$gridPage.html(pagingTag);
	},
	// grid paging을 위한 정보를 map에 담아 리턴해준다.
	gridPageData : function(gridId, map) {
		if(!map){
			map = new CubeMap();
		}
		var $grid = this.cubeDataGridMap.get(gridId);
		var pageNum;
		if(!$grid.attr(cubeConfig.LIST_PAGE_SELECT_NUM_ATT)){
			$grid.attr(cubeConfig.LIST_PAGE_SELECT_NUM_ATT,'1');		
		}
		if(!$grid.attr(cubeConfig.LIST_PAGE_COUNT_NUM_ATT)){
			$grid.attr(cubeConfig.LIST_PAGE_COUNT_NUM_ATT,cubeConfig.LIST_PAGE_DEFAULT_COUNT);
		}
		var pageNum = $grid.attr(cubeConfig.LIST_PAGE_SELECT_NUM_ATT);	
		var pageCount = $grid.attr(cubeConfig.LIST_PAGE_COUNT_NUM_ATT);
		map.put(cubeConfig.LIST_PAGE_SELECT_NUM_KEY, pageNum);
		map.put(cubeConfig.LIST_PAGE_COUNT_NUM_KEY, pageCount);
		
		return map;
	},
	// grid page를 변경해준다.
	gridPageChange : function(gridId, pageNum) {
		var $grid = this.cubeDataGridMap.get(gridId);
		$grid.attr(cubeConfig.LIST_PAGE_SELECT_NUM_ATT, pageNum);
		var pageEvent = $grid.attr(cubeConfig.DATA_GRID_ATT);
		try{
			eval(pageEvent);
		}catch(e){
		}
	},
	// edit grid에 데이터를 추출해 map에 담아준다.
	sendGridParamData : function(gridId, map) {
		if(!map){
			map = new CubeMap();
		}
		var $grid = this.cubeDataGridMap.get(gridId);
		// grid에서 저장에 필요한 CUD row만 추춘해준다.
		var $dataRow = $grid.find("["+cubeConfig.DATA_ROW_ATT+"]").filter("["+cubeConfig.DATA_ROW_STATE_ATT+"!="+cubeConfig.DATA_ROW_STATE_READ+"]");
		// 저장할 데이터가 없는 경우 처리
		if($dataRow.length == 0){
			cubeCommon.msg(cubeConfig.DATA_VALIDATE_MSG.get("saveDataEmpty"));
			return;
		}else{
			// row에 설정된 validation을 체크한다.
			for(var i=0;i<$dataRow.length;i++){
				if(!cubeValidate.validateCheckObject($dataRow.eq(i))){
					return;
				}					
			}
			// 저장전 한번더 물어본다.
			if(confirm(jQuery.validator.format(cubeConfig.DATA_VALIDATE_MSG.get("saveDataAlert"),$dataRow.length))){
				var dataList = new Array();
				for(var i=0;i<$dataRow.length;i++){
					var data = new CubeMap();
					// row데이터를 data에 저장해준다.
					cubeBind.paramDataFilter(data, $dataRow.eq(i));
					data.put(cubeConfig.DATA_ROW_STATE_ATT, $dataRow.eq(i).attr(cubeConfig.DATA_ROW_STATE_ATT));
					var keyList = data.keys();
					// row num을 지정하기 위해 설정된 name key에서 row num을 제거해준다.
					for(var j=0;j<keyList.length;j++){						
						if(keyList[j].indexOf("-") != -1){
							data.put(keyList[j].substring(0,keyList[j].indexOf("-")), data.get(keyList[j]));
							data.remove(keyList[j]);
						}
					}
					dataList[i] = data;
				}
			}
		}
		
		map.put("list", dataList);
		
		return map;
	},
	// 데이터 전송을 위해 areaId에 있는 데이터를 map에 저장해준다.
	sendParamData : function(map, areaId) {
		if(!map){ 
			map = new CubeMap();
		}
		
		var $dataRange = cubeCommon.getArea(areaId);
				
		cubeBind.paramDataFilter(map, $dataRange);
		
		return map;
	},
	// $dataRange에 있는 입력값들을 map에 저장해준다.
	paramDataFilter : function(map, $dataRange) {
		// 단순 input의 경우 name을 키로 value를 저장해준다.
		$dataRange.find(":text,:hidden,:password").each(function(i, findElement){
			var $obj = jQuery(findElement);
			if(!$obj.attr("name")){
				return;
			}
			// 동일한 name이 있는 경우 map에 multi로 put해준다. 
			if($obj.attr("value")){
				var multiCheck = $dataRange.find("[name="+$obj.attr('name')+"]").length;
				if(multiCheck > 1){
					map.putMulti($obj.attr("name"), $obj.attr("value"));
				}else{
					map.put($obj.attr("name"), $obj.attr("value"));
				}
			}
		});
		
		// checked인 경우 check된 값을 저장해준다.
		$dataRange.find(":checkbox").each(function(i, findElement){		
			var $obj = jQuery(findElement);
			if(!$obj.attr("name")){
				return;
			}
			if($obj.attr("checked")){
				var multiCheck = $dataRange.find("[name="+$obj.attr('name')+"]").length;
				if(multiCheck > 1){
					map.putMulti($obj.attr("name"), $obj.attr("value"));
				}else{
					map.put($obj.attr("name"), $obj.attr("value"));
				}
			// checked가 없는 경우 check off값이 있으면 셋팅해준다.
			}else if($obj.attr(cubeConfig.DATA_CHECKBOX_OFF_ATT)){
				map.put($obj.attr("name"), $obj.attr(cubeConfig.DATA_CHECKBOX_OFF_ATT));
			}
		});
		// radio인 경우 check된 값만 저장해준다.
		$dataRange.find(":radio").filter("[checked=checked]").each(function(i, findElement){
			var $obj = jQuery(findElement);
			if(!$obj.attr("name")){
				return;
			}
			map.put($obj.attr("name"), $obj.attr("value"));
		});
		// 단순 select 경우 name을 키로 value를 저장해준다.
		$dataRange.find("select").each(function(i, findElement){
			var $obj = jQuery(findElement);
			if(!$obj.attr("name")){
				return;
			}
			if($obj.attr("value")){
				var multiCheck = $dataRange.find("[name="+$obj.attr('name')+"]").length;
				if(multiCheck > 1){
					map.putMulti($obj.attr("name"), $obj.attr("value"));
				}else{
					map.put($obj.attr("name"), $obj.attr("value"));
				}
			}
		});
		// 단순 textarea 경우 name을 키로 value를 저장해준다.
		$dataRange.find("textarea").each(function(i, findElement){
			var $obj = jQuery(findElement);
			if(!$obj.attr("name")){
				return;
			}
			if($obj.val()){
				var multiCheck = $dataRange.find("[name="+$obj.attr('name')+"]").length;
				if(multiCheck > 1){
					map.putMulti($obj.attr("name"), $obj.val());
				}else{
					map.put($obj.attr("name"), $obj.val());
				}
			}
		});
	},
	// combo에 data를 자동으로 셋팅해준다. VAL_COL, TEXT_COL
	selectBind : function(selectId, data) {
		var $selectObj = cubeCommon.getJObj(selectId);
		
		// combo에 bind된 기존 데이터는 삭제한다.
		$selectObj.find("["+cubeConfig.SELECT_OPTION_DATA_ATT+"]").remove();
		var selectHtml = $selectObj.html()+"\n"; // 기본 option을 포함한 html을 가진다.
		// data를 option으로 만들어준다.
		for(var i=0;i<data.length;i++){
			selectHtml += "<option "+cubeConfig.SELECT_OPTION_DATA_ATT+"='true'"
					+"  value='"+data[i][cubeConfig.SELECT_DATA_VALUE_COLUMN]+"'>"
					+data[i][cubeConfig.SELECT_DATA_TEXT_COLUMN]+"</option>\n";
		}
		$selectObj.html(selectHtml);
	},
	// excel file download를 요청한다.
	// url로 map데이터를 통한 요청을 하며, excel file생성을 위한 정보를 gridId내에서 가져온다.
	gridExcelRequest : function(url, map, gridId) {
		var $grid = this.cubeDataGridMap.get(gridId);
		var labelMap = new CubeMap(); // label을 저장하는 map
		var labelOrderMap = new CubeMap(); // label의 순서를 저장하는 map
		// grid내에서 excel label을 찾아 저장한다. 
		$grid.find('['+cubeConfig.DATA_COLUMN_LABEL_ATT+']').each(function(i,findElement){
			var $obj = jQuery(findElement);
			labelMap.put($obj.attr(cubeConfig.DATA_COLUMN_LABEL_ATT), cubeCommon.getElementValue($obj));
			labelOrderMap.put(i, $obj.attr(cubeConfig.DATA_COLUMN_LABEL_ATT));
		});
		// gird에 excel file name이 지정된 경우 저장한다.
		if($grid.attr(cubeConfig.DATA_EXCEL_FILENAME)){
			map.put(cubeConfig.DATA_EXCEL_FILENAME, $grid.attr(cubeConfig.DATA_EXCEL_FILENAME));
		}
		// excel 전송을 위한 form tag를 초기화 한다.
		if(jQuery("#cubeExcelForm").lehgth){
			jQuery("#cubeExcelForm").remove();
		}
		// 비동기 전달을 위해 전달에 필요한 파라메터에 각 값들은 jsonString형태로 전송한다.
		var formHtml = "<form action='"+url+"' method='post' id='cubeExcelForm'>"
					 + "<textarea name='"+cubeConfig.DATA_EXCEL_REQUEST_KEY+"'>"+map.jsonString()+"</textarea>"
					 + "<textarea name='"+cubeConfig.DATA_EXCEL_LABEL_KEY+"'>"+labelMap.jsonString()+"</textarea>"
					 + "<textarea name='"+cubeConfig.DATA_EXCEL_LABEL_ORDER_KEY+"'>"+labelOrderMap.jsonString()+"</textarea>"
					 + "</form>";
		jQuery(formHtml).hide().appendTo('body');
		jQuery("#cubeExcelForm").submit();
	},
	// fullCalendar에 데이터를 셋팅해준다.
	calendarBind : function(calendarId, data) {
		var $calendar = jQuery("#"+calendarId);
		$calendar.fullCalendar('addEventSource', data);
	},
	// fullCalendar에 데이터를 삭제해준다.
	calendarDataRemove : function(calendarId, eventObj) {
		var $calendar = jQuery("#"+calendarId);
		$calendar.fullCalendar('removeEventSource', eventObj.source);
	},
	// fullCalendar에서 nav버튼 동작을 처리한다.
	calendarNav : function(calendarId, type) {
		switch(type){
			case "prev":
				 $('#'+calendarId).fullCalendar(type);
				break;
			case "next":
				 $('#'+calendarId).fullCalendar(type);
				break;
			case "today":
				 $('#'+calendarId).fullCalendar(type);
				break;
			case "month":
				 $('#'+calendarId).fullCalendar('changeView', type);
				break;
			case "week":
				 $('#'+calendarId).fullCalendar('changeView', 'agendaWeek');
				break;
			case "day":
				 $('#'+calendarId).fullCalendar('changeView', 'agendaDay');
				break;
		}
		this.calendarDateSet(calendarId); // nav로 변경된 날자를 화면에 표시해준다.
		// nav버튼 클릭 후 화면별 처리가 필요한 경우 해당 이벤트를 지정하면 된다.
		try{
    		cubeCalendarEventNavClick(calendarId, type);
		}catch(e){}
	},
	// 변경된 fullCalendar에서 날자를 표시해준다.
	calendarDateSet : function(calendarId) {
		var tmpDate = jQuery.fullCalendar.formatDate(jQuery('#'+calendarId).fullCalendar('getDate'),'yyyy M월');
		jQuery("["+cubeConfig.CALENDAR_DATE_ATTR+"="+calendarId+"]").text(tmpDate);
	},
	// dateId에서 연월일을 변경해준다.
	dateSet : function(dateId, type, num) {
		var $selectObj = cubeCommon.getJObj(dateId);
		var date = new Date();
		if(type){
			if(num){
				switch(type){
					case 'D':
						date.setDate(date.getDate()+num);
						break;
					case 'M':
						if(num == 'S'){
							date.setDate(1);
						}else if(num == 'E'){
							date.setMonth(date.getMonth()+1);
							date.setDate(1);
							date.setDate(date.getDate()-1);
						}else{
							date.setMonth(date.getMonth()+num);
						}
						break;
					case 'Y':
						date.setDate(date.getFullYear()+num, date.getMonth(), date.getDate());
						break;
				}
				$selectObj.val(cubeUI.dateFormat(date, "yyyy-MM-dd"));
			}
			if(type == 'C'){
				$selectObj.val('');
			}
		}else{
			$selectObj.val(cubeUI.dateFormat(date, "yyyy-MM-dd"));
		}
	},	
	toString : function() {
		return "CubeBind";
	}
};

var cubeBind = new CubeBind();

CubeUI = function() {
	this.selectTreeNode = new CubeMap();
};

CubeUI.prototype = {
	// UI로 설정된 객체를 UI로 지정해준다.
	typeCheck : function($obj) {
		if(!$obj){
			$obj = jQuery('body');
		}
		// calendar 지정
		$obj.find('['+cubeConfig.DATA_TYPE_ATT+"="+cubeConfig.DATA_TYPE_DATE+"]").datepicker(
				{ dateFormat: 'yy-mm-dd',
					showOn: 'button', 
					autoSize: true,
					buttonImage: '/cubefw/images/btn_calendar.gif',					
					buttonImageOnly: true,
					showButtonPanel: true
					 });
		var now = new Date();
		var tmpRange = (now.getFullYear()-110)+":"+(now.getFullYear()+10);
		// 연,월 combo가 표시되는 calendar 지정
		$obj.find('['+cubeConfig.DATA_TYPE_ATT+"="+cubeConfig.DATA_TYPE_SELECTDATE+"]").datepicker(
				{ dateFormat: 'yy-mm-dd',
					showOn: 'button', 
					autoSize: true,
					buttonImage: '/cubefw/images/btn_calendar.gif', 
					buttonImageOnly: true,
					showButtonPanel: true,
					changeMonth: true,
					changeYear: true,
					yearRange: tmpRange
					 });
		
		// button 지정
		$obj.find('['+cubeConfig.DATA_TYPE_ATT+"="+cubeConfig.DATA_TYPE_BUTTON+"]").button();
		
		// grid에 포함된 button 지정
		$obj.find('['+cubeConfig.DATA_TYPE_ATT+"="+cubeConfig.DATA_TYPE_GRID_BUTTON+"]").button();
		
		// tab 지정
		$obj.find('['+cubeConfig.DATA_TYPE_ATT+"="+cubeConfig.DATA_TYPE_TAB+"]").tabs();
		
		// menu 지정
		$obj.find('['+cubeConfig.DATA_TYPE_ATT+"="+cubeConfig.DATA_TYPE_MENU+"]").menu();
		
		// accordion 지정
		$obj.find('['+cubeConfig.DATA_TYPE_ATT+"="+cubeConfig.DATA_TYPE_ACCORDION+"]").accordion();
	},
	// web editor로 지정했던 객체를 초기화 해준다.
	resetEditor : function(editorId){
		var hEd = CKEDITOR.instances[editorId];
	    if (hEd) {
	        CKEDITOR.remove(hEd);
	    }
	},
	// web editor를 지정해준다.
	checkEditor : function($obj) {
		if(!$obj){
			$obj = jQuery('body');
		}
		
		// 에디터 툴바 옵션		
		var myToolbar =  
            [     
                { name: 'document', items : [ 'Source','-','DocProps','Preview','Print','-','Templates' ]  },
                { name: 'clipboard', items : [ 'Cut','Copy','Paste','PasteText','PasteFromWord','-','Undo','Redo' ] },
                { name: 'editing', items : [ 'Find','Replace','-','SelectAll','-','Scayt' ] },
                { name: 'insert', items : [ 'Image','Flash','Table','HorizontalRule','SpecialChar','Iframe' ] },
                        '/',
                { name: 'styles', items : [ 'Font','FontSize' ] },
                { name: 'colors', items : [ 'TextColor','BGColor' ] },
                { name: 'basicstyles', items : [ 'Bold','Italic','Strike','-','RemoveFormat' ] },
                { name: 'paragraph', items : [ 'NumberedList','BulletedList','-','JustifyLeft','JustifyCenter','JustifyRight','JustifyBlock' ] },
                { name: 'links', items : [ 'Link','Unlink' ] },
                { name: 'tools', items : [ 'Maximize','-','About' ] }
            ];
		
		// web editor를 지정해준다.
		$obj.find('['+cubeConfig.DATA_TYPE_ATT+"="+cubeConfig.DATA_TYPE_EDITOR+"]").ckeditor(
				{
		            toolbar : myToolbar,
		            filebrowserBrowseUrl : '',
		            filebrowserUploadUrl : '/cubefw/editor/cubeUp/image.cube',
		            filebrowserFlashUploadUrl: '/cubefw/editor/cubeUp/avi.cube'
			    });
		
		// 조회용 web editor를 위한 툴바 옵션
		var noneToolbar =  
            [     
                { name: 'tools', items : [ 'Maximize' ]  },
            ];
		
		// 조회용 web editor를 지정해준다.
		$obj.find('['+cubeConfig.DATA_TYPE_ATT+"="+cubeConfig.DATA_TYPE_READ_EDITOR+"]").each(function(i, findElement){
			jQuery(findElement).ckeditor(
					{
			            toolbar : noneToolbar,
			            readOnly : true
				    });
		});
	},
	// full calendar를 지정해준다.
	// data - 초기 데이터값
	checkCalendar : function(data, $obj) {
		if(!$obj){
			$obj = jQuery('body');
		}
		if(!data){
			data = "";
		}
		
		$obj.find('['+cubeConfig.DATA_TYPE_ATT+"="+cubeConfig.DATA_TYPE_CALENDAR+"]").fullCalendar({
			theme: true,
			/*header: {
				left: 'prev,next today',
				center: 'title',
				right: 'month,agendaWeek,agendaDay'
			},*/
			header: false,
			titleFormat: {
				month: 'yyyy MMMM',
				week: "yyyy MMM d{ '&#8212;' d }",
				day: 'yyyy, MMM d, dddd '
			},
			monthNames: ['1월','2월','3월','4월','5월','6월','7월','8월','9월','10월','11월','12월'],
			monthNamesShort: ['1월','2월','3월','4월','5월','6월','7월','8월','9월','10월','11월','12월'],
			dayNames: ['일요일','월요일','화요일','수요일','목요일','금요일','토요일'],
			dayNamesShort: ['일요일','월요일','화요일','수요일','목요일','금요일','토요일'],
			buttonText: {
				prev: '&nbsp;&#9668;&nbsp;',
				next: '&nbsp;&#9658;&nbsp;',
				prevYear: '&nbsp;&lt;&lt;&nbsp;',
				nextYear: '&nbsp;&gt;&gt;&nbsp;',
				today: ' 오늘 ',
				month: ' 월 ',
				week: ' 주 ',
				day: ' 일 '
			},
			selectable: true,
			selectHelper: true,
			select: function(start, end, allDay) {
				try{
					cubeCalendarEventSelect(start, end, allDay, this);
				}catch(e){}	
			},
			editable: true,
			events: data,
			eventClick: function(calEvent, jsEvent, view) {
				try{
					cubeCalendarEventClick(calEvent, jsEvent, view, this);
				}catch(e){}		        
		    },
		    dayClick: function(date, allDay, jsEvent, view) {
		    	try{
		    		cubeCalendarDayClick(date, allDay, jsEvent, view, this);
				}catch(e){}			        
		    },
		    eventDrop: function(event,dayDelta,minuteDelta,allDay,revertFunc) {
		    	try{
		    		cubeCalendarEventDrop(event, dayDelta, minuteDelta, allDay, revertFunc, this);
				}catch(e){}		        
		    },
		    eventResize: function(event,dayDelta,minuteDelta,revertFunc) {
		    	try{
		    		cubeCalendarEventResize(event, dayDelta, minuteDelta, revertFunc, this);
				}catch(e){}
		    },
		    eventAfterRender: function(event, element, view) {
		    	//데이터를 적용한 다음 발생하는 이벤트
		    	try{
		    		cubeCalendarEventAfterRender(event, element, view, this);
				}catch(e){}
		    },
		    loading: function(bool){
				if (bool){
					cubeCommon.displayLoading(true);
				}else{
					cubeCommon.displayLoading(false);
				}
			}
		});
		
		// full calendar에 nav button을 표시해준다.
		jQuery("["+cubeConfig.CALENDAR_BTN_ATTR+"]").each(function(i, findElement){
			var $cObj = jQuery(findElement);
			var refObjId = $cObj.attr(cubeConfig.CALENDAR_BTN_ATTR);
			var tmpWidth = jQuery("#"+refObjId).css("width");
			tmpWidth = (tmpWidth?tmpWidth:"100%");
			var tmpDate = $.fullCalendar.formatDate($('#'+refObjId).fullCalendar('getDate'),'yyyy M월');
			var appendHtml = "<table class='cubeCalendarBtnBox'  cellpadding='0' cellspacing='0'><tr>"
							+"<td width='35%'>"							
							+" <a href='#' onClick='cubeBind.calendarNav(\""+refObjId+"\",\"today\");return false;'>"
							+" <img src='/cubefw/images/btn_calendar_today.gif' />"
							+" </a>"
							+"</td>"
							+"<td style='text-align:center' width='10%'>"							
							+" <a href='#' onClick='cubeBind.calendarNav(\""+refObjId+"\",\"prev\");return false;'>"
							+" <img src='/cubefw/images/btn_calendar_prev.gif' />"
							+" </a>"
							+"</td>"
							+"<td style='text-align:center;' width='10%' cubeCalendarDate='"+refObjId+"'><font size='7'><b>"							
							+tmpDate							
							+"</b></font></td>"
							+"<td style='text-align:center;' width='10%'>"							
							+" <a href='#' onClick='cubeBind.calendarNav(\""+refObjId+"\",\"next\");return false;'>"
							+" <img src='/cubefw/images/btn_calendar_next.gif' />"
							+" </a>"
							+"</td>"
							+"<td style='text-align:right' width='35%'>"
							+" <a href='#' onClick='cubeBind.calendarNav(\""+refObjId+"\",\"month\");return false;'>"
							+" <img src='/cubefw/images/btn_calendar_month.gif' />"
							+" </a>"
							+" <a href='#' onClick='cubeBind.calendarNav(\""+refObjId+"\",\"week\");return false;'>"
							+" <img src='/cubefw/images/btn_calendar_week.gif' />"
							+" </a>"
							+" <a href='#' onClick='cubeBind.calendarNav(\""+refObjId+"\",\"day\");return false;'>"
							+" <img src='/cubefw/images/btn_calendar_day.gif' />"
							+" </a>"
							+"</td>"
							+"</tr></table>";
			jQuery(appendHtml).css("width",tmpWidth).appendTo($cObj);
		});
	},
	// tree 지정
	checkTree : function($obj) {
		if(!$obj){
			$obj = jQuery('body');
		}
		$.jstree._themes = "/cubefw/css/jstree/";
		$obj.find('['+cubeConfig.DATA_TYPE_ATT+"="+cubeConfig.DATA_TYPE_TREE+"]").each(function(i, findElement){
			var $tObj = jQuery(findElement);
			cubeUI.loadTree($tObj);
		});
			 
	},
	// $tObj를 tree로 만들어준다.
	// 특정 노드를 열린 상태로 만들기 위해 노드의 id를 selectId로 전달한다.
	loadTree : function($tObj, selectId) {
		$tObj = cubeCommon.getJObj($tObj);
		var tId = $tObj.attr("id");
		// tree를 설정하기 위한 옵션을 가져온다. url, root text, open id
		var treeOption = $tObj.attr(cubeConfig.DATA_TREE_OPTION_ATT);
		// option에서 selectId처리시 treeOptionList[2]가 없는 경우를 대비하기 위해 추가로 설정해준다.
		if(selectId){
			treeOption += ","+selectId;
		}
		var treeOptionList = treeOption.split(",");
		var jsonDataUrl = treeOptionList[0];
		var param = new CubeMap();
		param.put(cubeConfig.DATA_TREE_TITLE_KEY, treeOptionList[1]);
		if(selectId){
			treeOptionList[2] = selectId;
		}
		// open node 설정이 있는 경우 param을 저장한다.
		if(treeOptionList.length > 2){
			param.put(cubeConfig.DATA_TREE_OPEN_ID_KEY, treeOptionList[2]);
		}
		// 설정 option에 따라 데이터를 가져온다.
		var jsonData = cubeNet.sendJsonData(jsonDataUrl, param);
		$tObj.jstree({
			"themes" : {
				 "theme" : "classic",  
				 "dots" : true,
				 "icons" : true
				},
			"json_data" : {
					"data" : jsonData.data
			  	},
		  	"contextmenu" : {					
			     "items" : {
			    	 "ccp" : false
			     }
		  	},
			"plugins" : ["themes","json_data","ui","crrm","dnd","contextmenu","types"]
		})
		.bind("create.jstree", function (e, data) { 
			cubeUI.selectTreeNode.put(tId, data);
			try{
				cubeTreeEventCreate(e, data, $tObj);
			}catch(e){}
		})
		.bind("remove.jstree", function (e, data) { 
			cubeUI.selectTreeNode.put(tId, data);
			try{
				cubeTreeEventRemove(e, data, $tObj);
			}catch(e){}
		})
		.bind("rename.jstree", function (e, data) { 
			cubeUI.selectTreeNode.put(tId, data);
			try{
				cubeTreeEventRename(e, data, $tObj);
			}catch(e){}
		})
		.bind("move_node.jstree", function (e, data) { 
			cubeUI.selectTreeNode.put(tId, data);
			try{
				cubeTreeEventMove(e, data, $tObj);
			}catch(e){}
			//data.rslt.op - old parent, data.rslt.np - new parent, data.rslt.o - self
		})
		.bind("select_node.jstree", function (e, data) {
			cubeUI.selectTreeNode.put(tId, data);
			try{
				cubeTreeEventSelectNode(e, data, $tObj);
			}catch(e){} 
		});
	},
	// table의 colNum에 해당하는 td중 연속해서 같은 값을 가진 경우 rowspan을 해준다.
	colGrouping : function(tableId, colNum) {
		var $obj = jQuery("#"+tableId);
		var $rowList = $obj.find("tr");
		var $startRow;
		var groupCount = 0;
		var startData;
		$rowList.each(function(index, findElement){
			var $row = jQuery(findElement);
			var $col = $row.find('td').eq(colNum);
			var tmpData = cubeCommon.getElementValue($col);
			if(index == 0){
				groupCount = 1;
				$startRow = $row;
				startData = tmpData;
				return;
			}		
			if(startData == tmpData){
				$col.remove();
				groupCount++;
			}else{
				if(groupCount > 1){
					$startRow.find('td').eq(colNum).attr('rowspan', groupCount);
				}
				groupCount = 1;
				$startRow = $row;
				startData = cubeCommon.getElementValue($row.find('td').eq(colNum));
			}
		});
		if(groupCount > 1){
			$startRow.find('td').eq(colNum).attr('rowspan', groupCount);
		}
	},
	// 날자 형식에 맞춰서 출력해준다.
	dateFormat : function(date, format) {		 
	    return format.replace(/(yyyy|yy|MM|dd|E|hh|mm|ss|a\/p)/gi, function($1) {
	        switch ($1) {
	            case "yyyy": return date.getFullYear();
	            case "yy": return cubeCommon.leftPadding(date.getFullYear() % 1000, '0', 2);
	            case "MM": return cubeCommon.leftPadding(date.getMonth() + 1, '0', 2);
	            case "dd": return cubeCommon.leftPadding(date.getDate(), '0', 2);
	            case "E": return cubeConfig.WEEK_NAME[date.getDay()];
	            case "HH": return cubeCommon.leftPadding(date.getHours(), '0', 2);
	            case "hh": return cubeCommon.leftPadding(((h = date.getHours() % 12) ? h : 12), '0', 2);
	            case "mm": return cubeCommon.leftPadding(date.getMinutes(), '0', 2);
	            case "ss": return cubeCommon.leftPadding(date.getSeconds(), '0', 2);
	            case "a/p": return date.getHours() < 12 ? cubeConfig.DATE_AM : cubeConfig.DATE_PM;
	            default: return $1;
	        }
	    });
	},
	// tabId에서 선택산 index를 open해준다.
	tabOpen : function(tabId, index) {
		jQuery("#"+tabId).tabs("option","active",index);
	},
	zeroFormat : function() {
		return "CubeUI";
	},
	toString : function() {
		return "CubeUI";
	}
};

var cubeUI = new CubeUI();

CubeBoard = function() {
	this.boardMap = new CubeMap();// board code별 board box객체를 저장한다.
};

// 게시판 컨트롤에 필요한 작업을 처리한다.
CubeBoard.prototype = {
	// 게시판으로 설정된 객체를 적용해준다.
	checkBoard : function($obj) {
		if(!$obj){
			$obj = jQuery('body');
		}
		$obj.find('['+cubeConfig.DATA_TYPE_ATT+"="+cubeConfig.DATA_TYPE_BOARD+"]").each(function(i, findElement){
			var $boardBox = jQuery(findElement);
			// 게시판 표시를 위한 옵션을 확인한다. board id, view type, content id
			var boardCode = $boardBox.attr(cubeConfig.DATA_BOARD_CODE_ATT);
			var boardArgs = boardCode.split(",");
			var boardType;
			var contentId;
			var listType;
			if(boardArgs.length > 1){
				boardCode = boardArgs[0];
				boardType = boardArgs[1];
				contentId = boardArgs[2];
				if(boardType == "list"){
					listType = boardArgs[2];
				}else if(boardArgs.length > 3){
					listType = boardArgs[3];
				}
			}else{
				boardType = "list";
			}			
			
			cubeBoard.viewBoard($boardBox, boardCode, boardType, contentId, listType);
		});
	},
	// 게시판에 포함된 grid를 셋팅한다.
	boardGridScan : function($scanArea){
		// 게시물 목록 grid에 grid처리를 위한 attr을 셋팅해준다.
		var $dataGridList = $scanArea.find("["+cubeConfig.DATA_TYPE_BOARD_GRID_ATT+"]");
		for(var i=0;i<$dataGridList.length;i++){
			$dataGridList.eq(i).attr(cubeConfig.DATA_GRID_ATT, $dataGridList.eq(i).attr(cubeConfig.DATA_TYPE_BOARD_GRID_ATT));
		}
		
		// 게시물 파일 목록 grid에 grid처리를 위한 attr을 셋팅해준다.
		$dataGridList = $scanArea.find("["+cubeConfig.DATA_TYPE_FILE_GRID_ATT+"]");
		for(var i=0;i<$dataGridList.length;i++){
			$dataGridList.eq(i).attr(cubeConfig.DATA_GRID_ATT, $dataGridList.eq(i).attr(cubeConfig.DATA_TYPE_FILE_GRID_ATT));
		}
		
		// 게시물 목록 grid에 grid처리를 위한 attr을 셋팅해준다.
		$dataGridList = $scanArea.find("["+cubeConfig.DATA_TYPE_COMMENT_GRID_ATT+"]");
		for(var i=0;i<$dataGridList.length;i++){
			$dataGridList.eq(i).attr(cubeConfig.DATA_GRID_ATT, $dataGridList.eq(i).attr(cubeConfig.DATA_TYPE_COMMENT_GRID_ATT));
		}
	},
	// board내 특정 item을 이용해 board box에 저장된 속성으로 간단하게 view board를 실행한다.
	selectBoard : function(itemObj, boardType, contentId) {
		var $iObj = cubeCommon.getJObj(itemObj);
		var $boardBox = $iObj.parents('['+cubeConfig.DATA_TYPE_ATT+"="+cubeConfig.DATA_TYPE_BOARD+"]");
		var boardCode = $boardBox.attr(cubeConfig.DATA_TYPE_BOARD_CODE_ATT);
		this.viewBoard($boardBox, boardCode, boardType, contentId);
	},
	// board box id를 이용해 board box에 저장된 속성으로 간단하게 view board를 실행한다.
	selectBoardBox : function(boardboxId, boardType) {
		var $boardBox = cubeCommon.getJObj(boardboxId);
		var boardCode = $boardBox.attr(cubeConfig.DATA_TYPE_BOARD_CODE_ATT);
		this.viewBoard($boardBox, boardCode, boardType);
	},
	// 선택한 게시판을 보여준다.
	viewBoard : function($boardBox, boardCode, boardType, contentId, listType) {
		cubeUI.resetEditor("CONTENT");// board에 사용된 web editor가 중복되는 것을 막기위해 reset해준다.	
		$boardBox = cubeCommon.getJObj($boardBox);
		if(boardCode){
			$boardBox.attr(cubeConfig.DATA_TYPE_BOARD_CODE_ATT, boardCode);
		}else{
			boardCode = $boardBox.attr(cubeConfig.DATA_TYPE_BOARD_CODE_ATT);
		}
		if(boardType){
			$boardBox.attr(cubeConfig.DATA_TYPE_BOARD_TYPE_ATT, boardType);
		}else{
			boardType = $boardBox.attr(cubeConfig.DATA_TYPE_BOARD_TYPE_ATT);
		}
		// board 내부에 content_id가 있는 경우 가져온다.
		if(contentId){
			$boardBox.attr(cubeConfig.DATA_TYPE_BOARD_CONTENT_ID_ATT, contentId);			
		}else{
			contentId = $boardBox.attr(cubeConfig.DATA_TYPE_BOARD_CONTENT_ID_ATT);
		}
		if(listType){
			$boardBox.attr(cubeConfig.DATA_TYPE_BOARD_LIST_TYPE_ATT, listType);			
		}else{
			listType = "";
		}
		var boardBoxId = $boardBox.attr("id");
		// 선택한 board의 templet html을 가져온다.
		var sendUrl = "/CubeCms/cubePage/boardView.cube?ID="+boardCode+"&BOARDBOX="+boardBoxId+"&TYPE="+boardType+"&CONTENT_ID="+contentId+"&LIST_TYPE="+listType;
		var boardHtml = cubeNet.getHtmlData(sendUrl);
		// 가져온 html에서 body내부만 추출한다.
		boardHtml = boardHtml.substring(boardHtml.indexOf("<body>")+6,boardHtml.indexOf("</body>"));		
		$boardBox.children().remove();// 가져온 html을 표시하기 위해 board box를 초기화 한다.
		$boardBox.html(boardHtml);// 가져온 html을 board box에 표시한다.
		this.boardMap.put(boardCode, $boardBox);// board code에 해당하는 board box를 저장한다.
		// board box내에 새로운 html이 표현되어 기본적인 cubefw 사용을 위한 처리를 한다.
		cubeBind.comboScan(boardBoxId);
		this.boardGridScan($boardBox);
		cubeBind.gridScan(boardBoxId);		
		cubeUI.typeCheck($boardBox);
		cubeUI.checkEditor($boardBox);
		// board type별로 작업을 처리한다.
		switch(boardType){
			case "list"://게시판 목록 조회
				// 포함된 grid id를 가져온다.
				var boardListId = $boardBox.find("["+cubeConfig.DATA_TYPE_BOARD_GRID_ATT+"]").attr("id");
				this.getContentList(boardCode, boardListId);// board grid에 데이터를 가져온다.
				break;
			case "view"://게시글 조회			
				this.getContent(contentId, boardBoxId);// 게시글 데이터를 가져온다.
				this.getContentFileList(contentId, $boardBox);// 게시글에 연결된 file list를 가져온다.
				this.getContentCommentList($boardBox);// 게시글에 연결된 comment list를 가져온다.
				var map = new CubeMap();
				map.put("CONTENT_ID", contentId);
				cubeNet.sendJsonAjax("/CubeCms/cubeJson/boardContentVisit.cube", map);//게시글 조회수 카운트 처리를 한다.
				break;
			case "update":// 게시글 수정
				// 수정화면에 포함된 form ajax를 처리하기 위한 선언
				cubeNet.sendFormAjax("boardForm", "cubeBoard.updateContentSuccess", null, boardBoxId);
				this.getContent(contentId, boardBoxId);// 게시글 데이터를 가져온다.
				this.getContentFileList(contentId, $boardBox);// 게시글에 연결된 file list를 가져온다.
				break;
			case "write":
				cubeNet.sendFormAjax("boardForm", "cubeBoard.insertContentSuccess", null, boardBoxId);
				break;
		}
	},
	// 게시글 리스트를 가져온다.
	getContentList : function(boardCode, boardListId) {
		var map = new CubeMap();
		map.put("ID", boardCode);
		cubeBind.gridPageData(boardListId, map);// paging정보를 가져온다.
		cubeNet.sendJsonAjax("/cubefw/CubeCms/count/cubeJson/CFBDCM0010.cube", map, "cubeBoard.getContentListCountSuccess", null, boardListId);
		cubeNet.sendJsonAjax("/cubefw/CubeCms/paging/cubeJson/CFBDCM0010.cube", map, "cubeBoard.getContentListSuccess", null, boardListId);
	},
	getContentListCountSuccess : function(json, boardListId) {
		cubeBind.gridPageBind(boardListId, json.data);
		cubeBind.gridPageInfoBind(boardListId);
	},
	getContentListSuccess : function(json, boardListId) {
		cubeBind.gridBind(boardListId, json.data);
	},
	// 게시글을 가져온다.
	getContent : function(contentId, boardBoxId) {
		var map = new CubeMap();
		map.put("CONTENT_ID", contentId);
		cubeNet.sendJsonAjax("/cubefw/CubeCms/map/cubeJson/CFBDCM0010.cube", map, "cubeBoard.getContentSuccess", null, boardBoxId);
	},
	getContentSuccess : function(json, boardBoxId) {
		cubeBind.dataBind(json.data, boardBoxId);
	},
	// 게시글에 포함된 파일 리스트를 가져온다.
	getContentFileList : function(contentId, $boardBox) {
		var $fileGrid = $boardBox.find("["+cubeConfig.DATA_TYPE_FILE_GRID_ATT+"]");
		if($fileGrid.length){
			fileListId = $fileGrid.attr("id");
			var map = new CubeMap();
			map.put("CONTENT_ID", contentId);
			cubeNet.sendJsonAjax("/cubefw/CubeCms/list/cubeJson/CFBDCM0013.cube", map, "cubeBoard.getContentFileListSuccess", null, fileListId);
		}		
	},	
	getContentFileListSuccess : function(json, fileListId) {
		cubeBind.gridBind(fileListId, json.data);
	},
	// 게시글에 포함된 덧글 리스트를 가져온다.
	getContentCommentList : function($boardBox) {
		$boardBox = cubeCommon.getJObj($boardBox);
		var contentId = $boardBox.attr(cubeConfig.DATA_TYPE_BOARD_CONTENT_ID_ATT);
		var $commentGrid = $boardBox.find("["+cubeConfig.DATA_TYPE_COMMENT_GRID_ATT+"]");
		if($commentGrid.length){
			commentListId = $commentGrid.attr("id");
			var map = new CubeMap();
			map.put("CONTENT_ID", contentId);
			cubeNet.sendJsonAjax("/cubefw/CubeCms/list/cubeJson/CFBDCM0011.cube", map, "cubeBoard.getContentCommentListSuccess", null, commentListId);
		}		
	},
	getContentCommentListSuccess : function(json, commentListId) {
		cubeBind.gridBind(commentListId, json.data);
	},
	// 게시글을 저장후 조회 화면으로 돌아간다.
	insertContentSuccess : function(json, boardBoxId) {
		cubeBoard.selectBoardBox(boardBoxId, "list");
	},
	// 게시글을 수정한 후 조회 화면으로 돌아간다.
	updateContentSuccess : function(json, boardBoxId) {
		cubeBoard.selectBoardBox(boardBoxId, "view");
	},
	// 게시글을 삭제합니다.
	deleteContent : function(itemObj) {
		var $obj = cubeCommon.getJObj(itemObj);
		var $boardBox = $obj.parents('['+cubeConfig.DATA_TYPE_ATT+"="+cubeConfig.DATA_TYPE_BOARD+"]");
		var boardBoxId = $boardBox.attr("id");
		if($boardBox.find("#PID")){
			if($boardBox.find("#PID").val() != $boardBox.find("#CONTENT_ID").val()){
				alert("부모글이 있는 경우 삭제가 불가합니다.");
				return;
			}
		}
		if(!confirm("삭제하시겠습니까?")){
			return;
		}
		var map = new CubeMap();
		cubeBind.sendParamData(map, boardBoxId);
		cubeNet.sendJsonAjax("/cubefw/CubeCms/delete/cubeJson/CFBDCM0010.cube", map, "cubeBoard.deleteContentSuccess", null, boardBoxId);
	},
	deleteContentSuccess : function(json, boardBoxId) {
		cubeBoard.selectBoardBox(boardBoxId, "list");
	},
	// 게시물에 덧글을 추가합니다.
	insertComment : function(commentBoxId) {
		var $obj = cubeCommon.getJObj(commentBoxId);
		var $boardBox = $obj.parents('['+cubeConfig.DATA_TYPE_ATT+"="+cubeConfig.DATA_TYPE_BOARD+"]");
		var boardBoxId = $boardBox.attr("id");
		
		var contentId = $boardBox.attr(cubeConfig.DATA_TYPE_BOARD_CONTENT_ID_ATT);
		var map = new CubeMap();
		map.put("CONTENT_ID", contentId);
		cubeBind.sendParamData(map, commentBoxId);
		cubeNet.sendJsonAjax("/cubefw/CubeCms/insert/cubeJson/CFBDCM0011.cube", map, "cubeBoard.insertCommentSuccess", null, boardBoxId);
	},
	insertCommentSuccess : function(json, boardBoxId) {
		this.getContentCommentList(boardBoxId);
	},
	// 게시글에 파일 입력 폼 추가
	addFileForm : function(fileListId) {
		var $fileList = jQuery("#"+fileListId);
		var fileCount = $fileList.attr(cubeConfig.DATA_FILE_COUNT_ATT);
		if(fileCount){
			fileCount = parseInt(fileCount)+1;			
		}else{
			$fileList.attr(cubeConfig.DATA_FILE_COUNT_ATT, '1');
			fileCount = 1;
		}
		var tmpHtml = "<div>"
					+ "<a href='#' onclick='cubeBoard.fileFormRemove(this)'>"
					+ "<img src='/cubefw/css/images/btn_del.gif'/>"
					+ "</a>"
					+ "<input type='file' name='FILE"+fileCount+"' />"
					+ "</div>";
		jQuery(tmpHtml).appendTo($fileList);
	},
	fileFormRemove : function(btnObj) {
		jQuery(btnObj).parent().remove();
	},
	contentFileDelete : function(btnObj, uuid) {
		var $fileDeleteListForm = jQuery("#fileDeleteList");
		var $obj = jQuery(btnObj);
		if($fileDeleteListForm.length){
			if($fileDeleteListForm.val()){
				$fileDeleteListForm.val($fileDeleteListForm.val()+" "+uuid);
			}else{
				$fileDeleteListForm.val(uuid);
			}
			var $rowObj = $obj.parents("["+cubeConfig.DATA_ROW_ATT+"]");
			//$rowObj.remove();
			$rowObj.css("text-decoration","line-through");
			$obj.remove();
		}else{
			var $formObj = jQuery(btnObj).parents("form");
			jQuery("<input type='hidden' name='fileDeleteList' id='fileDeleteList'/>").appendTo($formObj);
			this.contentFileDelete(btnObj, uuid);
		}		
	},
	contentCommentDelete : function(btnObj, commentId) {
		var $obj = jQuery(btnObj);
		var map = new CubeMap();
		map.put("COMMENT_ID", commentId);
		cubeNet.sendJsonAjax("/cubefw/CubeCms/delete/cubeJson/CFBDCM0011.cube", map);
		var $rowObj = $obj.parents("["+cubeConfig.DATA_ROW_ATT+"]");
		$rowObj.remove();
	}
};

var cubeBoard = new CubeBoard();

CubeValidate = function() {

};

// 설정된 validate에 대한 확인을 해준다.
CubeValidate.prototype = {
	validateCheck : function(vId) {
		var $obj = cubeCommon.getArea(vId);
		return this.validateCheckObject($obj);
	},
	validateCheckObject : function($obj) {
		var $checkList = $obj.find("["+cubeConfig.DATA_VALIDATE_ATT+"]");
		
		var checkResult = true;
		var $findObj;
		var errorMsg;
		
		for(var index=0;index<$checkList.length;index++){
			$findObj = $checkList.eq(index);
			if($findObj.attr("readonly")){
				continue;
			}
			var valAtt = $findObj.attr(cubeConfig.DATA_VALIDATE_ATT);
			var labelAtt = $findObj.attr(cubeConfig.DATA_LABEL_ATT);
			if(labelAtt){
				labelAtt += this.msg("msgAnd");
			}else{
				labelAtt = "";
			}
			var valList = valAtt.split(" ");
			for(var i=0;i<valList.length;i++){
				var ruleText;
				var optionText;
				if(valList[i].indexOf("(") == -1){
					ruleText = valList[i];
					optionText = "true";
				}else{
					ruleText = valList[i].substring(0,valList[i].indexOf("("));
					optionText = valList[i].substring(valList[i].indexOf("(")+1, valList[i].length-1);
				}
				
				var valueText = $findObj.val();
				valueText = $.trim(valueText);
				$findObj.val(valueText);
				var valueLength = valueText.length;
				
				if(ruleText == "required"){
					var inputType = $findObj.attr("type");
					if(inputType == "checkbox" || inputType == "radio"){
						var nameText = $findObj.attr("name");
						if($obj.find("[name="+nameText+"]").filter("[checked=checked]").length == 0){
							valueText = "";
						}
					}
					if(valueText == ""){
						errorMsg = jQuery.validator.format(this.msg(ruleText), labelAtt);
						checkResult = false;
						break;
					}
				}else if(ruleText == "minlength"){
					var minNum = parseInt(optionText);
					if(valueLength < minNum){
						errorMsg = jQuery.validator.format(this.msg(ruleText), labelAtt, optionText);
						checkResult = false;
						break;
					}
				}else if(ruleText == "maxlength"){
					var maxNum = parseInt(optionText);
					if(valueLength > maxNum){
						errorMsg = jQuery.validator.format(this.msg(ruleText), labelAtt, optionText);
						checkResult = false;
						break;
					}
				}else if(ruleText == "rangelength"){
					var optionList = optionText.split(",");
					var minNum = parseInt(optionList[0]);
					var maxNum = parseInt(optionList[1]);
					if(valueLength < minNum || valueLength > maxNum){
						errorMsg = jQuery.validator.format(this.msg(ruleText), labelAtt, minNum, maxNum);
						checkResult = false;
						break;
					}
				}else if(ruleText == "email"){
					if(valueText){
						var regCheck = /^((([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+(\.([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+)*)|((\x22)((((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(([\x01-\x08\x0b\x0c\x0e-\x1f\x7f]|\x21|[\x23-\x5b]|[\x5d-\x7e]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(\\([\x01-\x09\x0b\x0c\x0d-\x7f]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]))))*(((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(\x22)))@((([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.)+(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))$/i.test(valueText);
						if(!regCheck){
							errorMsg = jQuery.validator.format(this.msg(ruleText), labelAtt);
							checkResult = false;
							break;
						}
					}
				}else if(ruleText == "url"){
					if(valueText){
						var regCheck = /^(https?|ftp):\/\/(((([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:)*@)?(((\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5])\.(\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5])\.(\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5])\.(\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5]))|((([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.)+(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.?)(:\d*)?)(\/((([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:|@)+(\/(([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:|@)*)*)?)?(\?((([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:|@)|[\uE000-\uF8FF]|\/|\?)*)?(\#((([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:|@)|\/|\?)*)?$/i.test(valueText);
						if(!regCheck){
							errorMsg = jQuery.validator.format(this.msg(ruleText), labelAtt);
							checkResult = false;
							break;
						}
					}
				}else if(ruleText == "number"){
					if(valueText){
						var regCheck = /^-?(?:\d+|\d{1,3}(?:,\d{3})+)(?:\.\d+)?$/.test(valueText);
						if(!regCheck){
							errorMsg = jQuery.validator.format(this.msg(ruleText), labelAtt);
							checkResult = false;
							break;
						}
					}
				}else if(ruleText == "digits"){
					if(valueText){
						var regCheck = /^\d+$/.test(valueText);
						if(!regCheck){
							errorMsg = jQuery.validator.format(this.msg(ruleText), labelAtt);
							checkResult = false;
							break;
						}
					}
				}else if(ruleText == "tel"){
					if(valueText){
						var regCheck = /^\d{3}-\d{3,4}-\d{4}$/.test(valueText);
						if(!regCheck){
							errorMsg = jQuery.validator.format(this.msg(ruleText), labelAtt);
							checkResult = false;
							break;
						}
					}
				}else if(ruleText == "equalTo"){
					if(valueText != optionText){
						errorMsg = jQuery.validator.format(this.msg(ruleText), labelAtt, optionText);
						checkResult = false;
						break;
					}
				}else if(ruleText == "min"){
					if(isNaN(valueText)){
						errorMsg = jQuery.validator.format(this.msg("number"), labelAtt);
						checkResult = false;
						break;
					}
					var minNum = parseFloat(optionText);
					var valueNum = parseFloat(valueText)
					if(valueNum < minNum){
						errorMsg = jQuery.validator.format(this.msg(ruleText), labelAtt, minNum);
						checkResult = false;
						break;
					}
				}else if(ruleText == "max"){
					if(isNaN(valueText)){
						errorMsg = jQuery.validator.format(this.msg("number"), labelAtt);
						checkResult = false;
						break;
					}
					var maxNum = parseFloat(optionText);
					var valueNum = parseFloat(valueText)
					if(valueNum > maxNum){
						errorMsg = jQuery.validator.format(this.msg(ruleText), labelAtt, maxNum);
						checkResult = false;
						break;
					}
				}else if(ruleText == "pair"){
					var $pObj = jQuery("#"+optionText);
					var pValueText = $pObj.val();
					var pLabelAtt = $pObj.attr(cubeConfig.DATA_LABEL_ATT);
					if(pLabelAtt){
						pLabelAtt += this.msg("msgAnd");
					}else{
						pLabelAtt = "";
					}
					if(valueText != "" && pValueText == ""){					
						errorMsg = jQuery.validator.format(this.msg(ruleText), labelAtt.substring(0, labelAtt.length-4), pLabelAtt);
						checkResult = false;
						$findObj = $pObj;
						break;
					}
					if(valueText == "" && pValueText != ""){					
						errorMsg = jQuery.validator.format(this.msg(ruleText), pLabelAtt.substring(0, pLabelAtt.length-4), labelAtt);
						checkResult = false;
						break;
					}
				}else if(ruleText == "between"){
					var $pObj = jQuery("#"+optionText);
					var pValueText = $pObj.val();
					var pLabelAtt = $pObj.attr(cubeConfig.DATA_LABEL_ATT);
					if(pLabelAtt){
						pLabelAtt += this.msg("msgAnd");
					}else{
						pLabelAtt = "";
					}
					if(valueText > pValueText){				
						errorMsg = jQuery.validator.format(this.msg(ruleText), labelAtt, pLabelAtt.substring(0, pLabelAtt.length-4));
						checkResult = false;
						$findObj = $pObj;
						break;
					}
				}else if(ruleText == "equal"){
					var $pObj = jQuery("#"+optionText);
					var pValueText = $pObj.val();
					var pLabelAtt = $pObj.attr(cubeConfig.DATA_LABEL_ATT);
	
					if(valueText != pValueText){				
						errorMsg = jQuery.validator.format(this.msg(ruleText), labelAtt.substring(0, labelAtt.length-4), pLabelAtt);
						checkResult = false;
						$findObj = $pObj;
						break;
					}
				}else if(ruleText == "remote"){
					var remoteRs = false;
					try{
						remoteRs = eval(optionText+"('"+valueText+"')");
					}catch(e){}
					if(!remoteRs){
						errorMsg = jQuery.validator.format(this.msg(ruleText), labelAtt);
						checkResult = false;
						break;
					}
				}else if(ruleText == "duplication"){
					var remoteRs = false;
					try{
						remoteRs = eval(optionText+"('"+valueText+"')");
					}catch(e){}
					if(!remoteRs){
						errorMsg = jQuery.validator.format(this.msg(ruleText), valueText);
						checkResult = false;
						break;
					}
				}
			}
			if(!checkResult){
				break;
			}
		}
		
		if(checkResult){
			return true;
		}else{
			cubeCommon.msg(errorMsg);
			$findObj.focus();
			return false;
		}
	},
	msg : function(txt) {
		return cubeConfig.DATA_VALIDATE_MSG.get(txt);
	},
	toString : function() {
		return "CubeValidate";
	}
};

var cubeValidate = new CubeValidate();