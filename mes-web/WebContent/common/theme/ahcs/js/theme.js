Theme = function() {
	this.$inputObj;
	this.searchOpenGridId;;
	this.param;
	this.popData;
	
	this.INPUT_SEARCH_CLASS = "searchInput";
	this.INPUT_RANGE_CLASS = "normalInput";
	this.INPUT_NUMBER_CLASS = "inputNumber";
	this.INPUT_BUTTON_CLASS = "searchInput";
	this.INPUT_NORMAL_CLASS = "normalInput";
	
	this.GRID_CALENDAR_ICON = "/common/theme/ahcs/images/btn/btn_icon_calendar.gif";
	this.INPUT_CALENDAR_ICON = "/common/theme/ahcs/images/btn/btn_icon_calendar.gif";
	
	this.GRID_BTN_WIDTH = 27;
	this.GRID_DEFAULT_ROW_HEIGHT = 15;
	this.GRID_COL_MINWIDTH = 30;
	
	this.findViewType = false;
};

Theme.prototype = {
	setGridBtn : function(gridBox, $obj) {
		$obj.addClass("button");
		$obj.addClass("type4");
		var btnType = $obj.attr(configData.GRID_BTN);
		var btnLabelKey = "";
		var tmpHtml;
		if(btnType == configData.GRID_BTN_FIND){
			gridBox.findBtnType = true;
			btnLabelKey = "BTN_FINDDATA";
			var labelTxt = uiList.getLabel(btnLabelKey);
			
			var tmpInputHtml = "<span class='search_box input_skipTitle'>"
                             + "<input class='search_box' type='text'><button class='search_btn' type='button'  title='"+labelTxt+"' value='"+labelTxt+"'></button>"
                             + "</span><span></span>"
                             + "<button class='prev' type='button' value='이전'></button>"
                             + "<button class='next' type='button' value='다음'></button>";

			var $tmpObj = jQuery(tmpInputHtml);
			$obj.append($tmpObj);
			gridBox.$findInput = $tmpObj.find("input");
			gridBox.$findInfo = jQuery("<div class='page_num'><span>0</span> / 0</div>");//$tmpObj.find("span").eq(1);
			$obj.before(gridBox.$findInfo);
			
			var $tmpBtn = $tmpObj.find("button");
			$tmpBtn.eq(0).click(function(event){
				var $obj = jQuery(event.target);
				var tmpTxt = gridBox.$findInput.val();
				gridBox.findData(tmpTxt);			
			});
			$tmpBtn.eq(1).click(function(event){
				gridBox.findDataFocusMove(-1);			
			});
			$tmpBtn.eq(2).click(function(event){
				gridBox.findDataFocusMove(1);			
			});
			
			$obj.addClass("search_wrap");
		}else if(btnType == configData.GRID_BTN_SORT_RESET){
			tmpHtml = "<img src='/common/images/ico_btn5.png' />";
			$obj.click(function(event){
				gridBox.sortReset();
			});
			
			btnLabelKey = "BTN_SORTRESET";
			$obj.addClass("btn_reset");
		}else if(btnType == configData.GRID_BTN_UP){
			tmpHtml = "▲";
			$obj.click(function(event){
				gridBox.rowUp();
			});
			btnLabelKey = "BTN_ROWUP";
		}else if(btnType == configData.GRID_BTN_DOWN){
			tmpHtml = "▼";
			$obj.click(function(event){
				gridBox.rowDown();
			});
			btnLabelKey = "BTN_ROWDOWN";
		}else if(btnType == configData.GRID_BTN_ADD){
			tmpHtml = "<img src='/common/images/grid_icon_04.png' />";
			$obj.addClass(configData.GRID_BTN_ADD);
			$obj.click(function(event){
				gridBox.addRow();
			});
			btnLabelKey = "BTN_ADDROW";
		}else if(btnType == configData.GRID_BTN_DELETE){
			tmpHtml = "<img src='/common/images/grid_icon_02.png' />";
			$obj.addClass("del");
			$obj.click(function(event){
				if(gridBox.selectRowDeleteType){
					gridBox.deleteSelectRow();
				}else{
					gridBox.deleteRow();
				}
			});
			btnLabelKey = "BTN_DELETEROW";
		}else if(btnType == configData.GRID_BTN_LAYOUT){
			tmpHtml = "<img src='/common/images/grid_icon_07.png' />";
			gridBox.layoutType = true;
			$obj.click(function(event){
				layoutSave.setLauyout(gridBox);
			});
			btnLabelKey = "BTN_LAYOUT";
			$obj.addClass("btn_layout");
		}else if(btnType == configData.GRID_BTN_FILTER){
			tmpHtml = "<img src='/common/images/ico_btn8.png' />";
			gridBox.layoutType = true;
			$obj.click(function(event){
				gridList.filterLayoutView(gridBox.id);
			});
			btnLabelKey = "BTN_FILTER";
			$obj.addClass("btn_filter");
		}else if(btnType == configData.GRID_BTN_TOTAL){
			tmpHtml = "<img src='/common/images/grid_icon_08.png' />";
			$obj.click(function(event){
				gridBox.viewTotal();
			});
			btnLabelKey = "BTN_TOTAL";
			$obj.addClass("btn_total");
		}else if(btnType == configData.GRID_BTN_SUB_TOTAL){
			tmpHtml = "<img src='/common/images/ico_btn7.png' />";
			$obj.click(function(event){
				gridList.subTotalLayoutView(gridBox.id);
			});
			btnLabelKey = "BTN_SUB_TOTAL";
			$obj.addClass("btn_total2");
		}else if(btnType == configData.GRID_BTN_EXCEL){
			tmpHtml = "<img src='/common/images/ico_btn9.png' />";
			$obj.click(function(event){
				gridBox.gridExcelRequest();
			});
			btnLabelKey = "BTN_EXCELDN";
			$obj.addClass("btn_down");
		}else if(btnType == configData.GRID_BTN_EXCEL_VIEW){
			tmpHtml = "<img src='/common/images/ico_btn9.png' />";
			$obj.click(function(event){
				gridBox.excelRequestGridData = true;
				gridBox.gridExcelRequest();
				gridBox.excelRequestGridData = false;
			});
			btnLabelKey = "BTN_EXCELVIEW";
			$obj.addClass("btn_export");
		}else if(btnType == configData.GRID_BTN_EXCEL_UP){
			$obj.addClass("excel");
			$obj.addClass("pop_open4");
			$obj.attr("href", "#fileupload_pop_layout");
			$obj.click(function(event){
				gridList.excelUpLayoutView(gridBox.id);
			});
			btnLabelKey = "BTN_EXCELUP";
			//$obj.addClass("btn_export");
		}else if(btnType == configData.GRID_BTN_CHECK){
			tmpHtml = "<img src='/common/images/grid_icon_02.png' />";
			$obj.click(function(event){
				if(gridBox.$checkHead){
					gridBox.changeCheckHead(true);
				}
			});
			btnLabelKey = "BTN_CHECKALL";
		}else if(btnType == configData.GRID_BTN_WRITE){
			tmpHtml = "<img src='/common/images/grid_icon_01.png' />";
			$obj.click(function(event){
				//event fn
				if(commonUtil.checkFn("gridListEventBtnClick")){
					gridListEventBtnClick(gridBox.id, configData.GRID_BTN_WRITE);
				}
			});
			btnLabelKey = "BTN_WRITE";
		}else if(btnType == configData.GRID_BTN_COPY){
			tmpHtml = "<img src='/common/images/grid_icon_15.png' />";
			$obj.addClass(configData.GRID_BTN_COPY);
			$obj.click(function(event){
				gridBox.copyRow();
			});
			btnLabelKey = "BTN_COPY";
		}else if(btnType == configData.GRID_BTN_PAGE_VIEW_COUNT){
			tmpHtml = "<option value='5'>5 보기</option>"
					+ "<option value='10' selected='selected'>10 보기</option>"
					+ "<option value='20'>20 보기</option>"
					+ "<option value='50'>50 보기</option>"
					+ "<option value='100'>100 보기</option>";
			$obj.click(function(event){
				gridBox.$gridBody.removeClass("list_5");
				gridBox.$gridBody.removeClass("list_10");
				gridBox.$gridBody.removeClass("list_20");
				gridBox.$gridBody.removeClass("list_50");
				gridBox.$gridBody.removeClass("list_100");
				gridBox.$gridBody.addClass("list_"+$obj.val());
				gridBox.scrollResize();
			});
			btnLabelKey = "BTN_COUNT";
			
			gridBox.$girdViewCount = $obj;
		}else if(btnType == configData.GRID_BTN_COLFIX){
			tmpHtml = "<img src='/common/images/ico_btn5.png' />";
			$obj.click(function(event){
				gridBox.colFix();
			});
			btnLabelKey = "BTN_COLFIX";
			$obj.addClass("btn_colfix");
		}
		
		if(tmpHtml){
			$obj.append(tmpHtml);
			if(btnType == configData.GRID_BTN_PAGE_VIEW_COUNT && gridBox.defaultViewCount > 0){
				gridBox.$gridBody.removeClass("list_5");
				gridBox.$gridBody.removeClass("list_10");
				gridBox.$gridBody.removeClass("list_20");
				gridBox.$gridBody.removeClass("list_50");
				gridBox.$gridBody.removeClass("list_100");
				gridBox.$gridBody.addClass("list_"+gridBox.defaultViewCount);
				gridBox.$girdViewCount.val(gridBox.defaultViewCount+"");
			}
			if(btnLabelKey){
				var labelTxt = uiList.getLabel(btnLabelKey);
				$obj.attr("title", labelTxt);
			}else{
				$obj.attr("title", btnType);
			}
		}
	},
	setGridPgecountInfo : function(gridBox) {
		var tmpHtml = "<div class='paging'>"
			+ "<a href='#'><img src='/common/images/btn_first.png' /></a>"
			+ "	<a href='#'><img src='/common/images/btn_prev.png' /></a>"
			+ "<span></span>"
			+ "	<a href='#'><img src='/common/images/btn_next.png' /></a>"
			+ "<a href='#'><img src='/common/images/btn_last.png' /></a>"
			+ "</div>";
		gridBox.$paging = jQuery(tmpHtml);
		var $tmpLink = gridBox.$paging.find("a");
		$tmpLink.eq(0).click(function(event){
			gridBox.linkFirst();
		});
		$tmpLink.eq(1).click(function(event){
			gridBox.linkPrev();
		});
		$tmpLink.eq(2).click(function(event){
			gridBox.linkNext();
		});
		$tmpLink.eq(3).click(function(event){
			gridBox.linkLast();
		});
		
		gridBox.$gridBottom.find(">div").eq(0).after(gridBox.$paging);
	},
	setGridFinddataInfo : function($findInfo, findIndex, findCount){
		$findInfo.html("<span>"+findIndex+"</span> / "+findCount);
	},
	getGridSearchBtn : function(gridBox, $input){
		var iconClass = configData.BUTTON_ICON.get(configData.BUTTON_TYPE_SEARCH);
		var $searchBtn = jQuery("<button class='search_btn' type='button' style='height:100%;'></button>");
		return $searchBtn;
	},
	getInputSearchBtn : function(inputObj){
		var $searchBtn = jQuery("<button class='search_btn' type='button' value='검색'></button>");
		return $searchBtn;
	},
	getInputRangeDash : function(inputObj){
		return "<span class='num_bar'>~</span>";
	},
	getInputRangeBtn : function(inputObj){
		var $rangeBtn = jQuery("<button class='num_btn open_search_pop_option' type='button' value='옵션설정'></button>");
		return $rangeBtn;
	},
	getMultiValueBtn : function(inputObj, labelText){
		var $valueBtn = jQuery("<button class='"+configData.BUTTON_CLASS+"' type='button' style='margin-left:10px;'></button>");
		$valueBtn.append("<span class='"+configData.BUTTON_TEXT_CLASS+"'style='margin-left:10px;'>"+labelText+"</span>");
		return $valueBtn;
	},
	setInputCalendarEffect : function($input){
		$input.next(".ui-datepicker-trigger").css({
			"margin-left":"5px",
			"margin-right":"6px",
			"opacity":"0.6"
			});
	},
	setGridCalendarEffect : function($input){
		$input.next(".ui-datepicker-trigger").css({
			"margin-left":"5px",
			"opacity":"0.6"
			});
	},
	getGridDeleteBtn : function(gridBox){
		var $btnObj = jQuery("<button class='button type3' type='button' onclick='gridList.deleteBtnClick(\""+gridBox.id+"\",this)'><img src='/common/images/grid_icon_10.png' /></button>");
		$btnObj.attr(configData.GRID_COL_TYPE_BTN_ROWNUM_ATT, configData.GRID_COL_DATA_NAME_ROWNUM);
		return $btnObj;
	},
	saveVariant : function(){
		var map = dataBind.paramData("saveVariant");						
		if(!map.containsKey("saveVariantPARMKY") || $.trim(map.get("saveVariantPARMKY")) == ""){
			commonUtil.msgBox(configData.VALIDATE_MSG_GROUPKEY+"_"+configData.VALIDATION_REQUIRED);
			$("#saveVariant").find("[name=saveVariantPARMKY]").focus();
			return;
		}
		map.put("PARMKY", map.get("saveVariantPARMKY"));
		if(!map.containsKey("saveVariantSHORTX") || $.trim(map.get("saveVariantSHORTX")) == ""){
			commonUtil.msgBox(configData.VALIDATE_MSG_GROUPKEY+"_"+configData.VALIDATION_REQUIRED);
			$("#saveVariant").find("[name=saveVariantSHORTX]").focus();
			return;
		}
		map.put("SHORTX", map.get("saveVariantSHORTX"));
		map.put("DEFCHK", map.get("saveVariantDEFCHK"));
		var $getVariantList = jQuery("#getVariantList");
		if($getVariantList.find("[value="+map.get("PARMKY")+"]").length > 0){
			map.put("UCOUNT", "1");
		}
		
		map.put("PROGID", configData.MENU_ID);
		var param = inputList.getSearchAreaVariant();
		map.put("saveVariant", param);
		//alert(map.toString());
		var json = netUtil.sendData({
			url : "/ahcs/variant/json/insert.data",
	    	param : map
		});
		if(json && json.data){
			//alert(JSON.stringify(json));
			if($getVariantList.find("[value="+map.get("PARMKY")+"]").length == 0){
				var tmpHtml = "<option value='"+map.get("PARMKY")+"'>["+map.get("PARMKY")+"]"+map.get("SHORTX")+"</option>";
				$getVariantList.append(tmpHtml);
			}else{
				$getVariantList.find("[value="+map.get("PARMKY")+"]").text(map.get("SHORTX"));
			}					
		}
		
		hideSaveVariant();
	},
	deleteVariant : function(){
		var $getVariantList = jQuery("#getVariantList");
		var tmpValue = $getVariantList.val();
		if(tmpValue){
			var param = new DataMap();
			param.put("PARMKY", tmpValue);
			param.put("PROGID", configData.MENU_ID);
			var json = netUtil.sendData({
				url : "/ahcs/variant/json/delete.data",
		    	param : param
			});
			if(json && json.data){
				//alert(JSON.stringify(json));
				$getVariantList.find("[value="+tmpValue+"]").remove();
			}
		}
	},
	changeVariant : function(obj) {
		//var $getVariantList = jQuery(obj);
		var $getVariantList = jQuery("#getVariantList");
		//alert($getVariantList.val());
		var param = new DataMap();
		param.put("PARMKY", $getVariantList.val());
		param.put("PROGID", configData.MENU_ID);
		var json = netUtil.sendData({
			module : "AHCS",
			command : "USRPIV",
	    	param : param
		});
		if(json && json.data){
			//alert(JSON.stringify(json));
			var defMap = new DataMap();
			for(var i=0;i<json.data.length;i++){
				defMap.put(json.data[i]["CTRLID"],json.data[i]["CTRVAL"]);
			}
			inputList.bindSearchAreaDefaultParam(defMap);
			
			var tmpDesc = $getVariantList.find("option[value="+param.get("PARMKY")+"]").text();
			tmpDesc = tmpDesc.substring(tmpDesc.indexOf("]")+1);
			var $saveVariantInput = jQuery("#saveVariant input");
			$saveVariantInput.eq(0).val(param.get("PARMKY"));
			$saveVariantInput.eq(1).val(tmpDesc);
		}
		
		hideGetVariant();
	},
	createGridHead : function(gridBox) {
		var $ghList = gridBox.$box.find("["+configData.GRID_HEAD+"]");
		var $gh;
		var attList;
		var colType;
		var colName;
		var lblTxt;
		var colHtml = "";
		var thHtml = "";
		var ghbtn = "";
		for(var i=0;i<$ghList.length;i++){
			$gh = $ghList.eq(i);
			attList = $gh.attr(configData.GRID_HEAD).split(" ");
			colHtml += "<col width='"+attList[0]+"'/>";
			lblTxt = "";
			ghbtn = "";
			if(attList.length == 1){
				attList = $gh.attr(configData.GRID_COL).split(",");
				if(attList[0] == configData.GRID_COL_TYPE_ROWNUM){
					lblTxt = uiList.getLabel("STD_NUMBER");
				}else if(attList[0] == configData.GRID_COL_TYPE_ROWCHECK){
					ghbtn = " GBtnCheck='true'";
				}else if(attList[0] == configData.GRID_COL_TYPE_CHECKBOX){
					ghbtn = " GBtnCheck='"+attList[1]+"'";
				}
				if(attList.length > 1){
					lblTxt = uiList.getLabel("STD_"+attList[1]);
				}
			}else{				
				lblTxt = uiList.getLabel(attList[1]);
			}
			thHtml += "<th"+ghbtn+">"+lblTxt+"</th>";
		}
		
		var tmpHtml = "<table class='"+configData.GRID_HEAD_CLASS+"'>"
			+ "<colgroup>"
			+ colHtml
			+ "</colgroup>"
			+ "<thead></tr>"
			+ thHtml
			+ "</tr></thead>";
		var $headDiv = gridBox.$gridLayout.find(".grid_head");
		if($headDiv.length > 0){
			$headDiv.html(tmpHtml);
		}else{
			tmpHtml = "<div class='grid_head'>"+tmpHtml+"</div>";
			gridBox.$gridBody.before(tmpHtml);
		}
		gridBox.$gridBody.find("colgroup").remove();
		tmpHtml = "<colgroup>"+ colHtml+ "</colgroup>";
		gridBox.$box.before(tmpHtml);
		
		var $utilDiv = gridBox.$gridLayout.find(".grid_control");
		if($utilDiv.length == 0){
			tmpHtml = "<div class='grid_control tableUtil'>"
					+ "<div class='left_wrap'>총 조회건수<span GInfoArea='true'>0</span></div>"
					+ "<div class='right_wrap'>"
					+ "<div GBtn='find'></div>"
					+ "<div class='util'>"
					+ "<a href='#' GBtn='filter'>필터</a>"
					+ "<a href='#' GBtn='sortReset'>새로고침</a>"
					+ "<a href='#' GBtn='layout'>레이아웃</a>"
					+ "<a href='#' GBtn='colFix'>셀고정</a>"
					+ "<a href='#' GBtn='total'>합계</a>"
					+ "<a href='#' GBtn='subTotal'>부분합계</a>"
					+ "<a href='#' GBtn='excel'>다운로드</a>"
					+ "<a href='#' GBtn='excelView'>엑셀익스포트</a>"
					+ "</div>"
					+ "</div>"
					+ "</div>";
			gridBox.$gridLayout.append(tmpHtml);
		}
	},
	toString : function() {
		return "Theme";
	}
};

var theme = new Theme();