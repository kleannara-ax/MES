GridBox = function(id) {
	this.id = id;//박스 아이디	
	this.name;
	this.$box = jQuery("#"+this.id);//박스 객체;//박스 객체
	if(this.$box.length == 0){
		alert(this.id+"에 해당하는 그리드가 존재하지 않습니다.");
		return;
	}
	this.$tableBox = this.$box.parent();
	this.$gridLayout = this.$box.parents("."+theme.GRID_BOX_CLASS);
	this.$gridBody = this.$gridLayout.find("."+theme.GRID_BODY_CLASS);
	if(this.$box.find("["+configData.GRID_HEAD+"]").length > 0){
		theme.createGridHead(this);
	}	
	this.$gridHead = this.$gridLayout.find("."+theme.GRID_HEAD_CLASS);
	this.headCells = new Array();
	this.headRowCount = 0;
	this.$gridBottom = this.$gridLayout.find("."+theme.GRID_BOTTOM_CLASS);
	this.$girdViewCount;
	this.defaultViewCount;
	this.$checkHead;
	this.rowNumType = false;
	this.$paging;
	this.$colFix;
	this.$headColFix;
	this.colFixType = false;
	this.colFixNum = -1;
	this.colFixWidthList;
	this.defaultLayOutData;
	this.invisibleLayOutData;
	this.visibleLayOutData;
	this.colTextMap = new DataMap();
	this.layoutColsMap = new DataMap();
	this.layoutDataMap = new DataMap();
	this.layoutType = false;
	this.headColDragType = true;
	this.sortType = true;
	
	this.totalView = false;
	this.totalColsMap = new DataMap();
	this.totalCols;
	this.totalShow = false;
	
	this.appendRow = false;
	
	this.tree;
	this.treeId;
	this.treeText;
	this.treeLvl;
	this.treePid;
	this.treeSeq;
	
	this.findBtnType;
	this.$findInput;
	this.$findInfo;
	this.findList;
	this.findIndex = -1;
	
	this.editable = true;
	this.module;
	this.command;
	this.url;
	this.bigdata = true;
	this.dataRequest = true;
	this.scrollType = false;
	this.scrollTop = 0;
	this.scrollLeft = 0;
	this.checkHead;
	this.pkcol = "";
	this.pkcolMap = new DataMap();
	this.addcolMap = new DataMap();
	this.pkcheck = true;
	this.validation;
	this.validationType = "CU";
	this.validationMap = new DataMap();
	this.duplication;
	this.duplicationList = new Array();
	
	this.bindArea;
	this.$area;
	this.$navBtnGroup;
	
	this.$rows;//최초 지정된 행 원본
	this.$dataRow;
	this.rowHtml;//행에 사용되는 기본 html
	this.rowNewHtml;//행추가 시 사용 html
	this.editableCols = new Array();//수정가능한 컬럼 리스트 Array
	this.editableColMap = new DataMap();//수정가능한 컬럼 Map
	this.viewCols = new Array();
	this.viewEditCols = new Array();
	this.sysCols = new Array();
	this.viewColMap = new DataMap();
	this.comboList = new Array();
	this.comboDataMap = new DataMap();
	//this.checkBox = new DataMap();//내부에서 사용된 채크박스	
	this.infoList = new Array();
	this.checkInfoList = new Array();
	
	//this.textData;
	this.cols = new Array();//컬럼명 리스트 Array
	this.data = new Array();//데이터 Array
	this.jsonData;
	this.mapData = new Array();
	this.viewDataList = new Array();//보여줄 데이터 Array
	this.modifyRow = new DataMap();//수정 데이터 집합 rownum, state
	this.modifyCols = new Array();//수정된 컬럼들의 집합 ruwnum(colname, colvalue)
	this.sourceCols = new Array();
	this.selectRow = new DataMap();//선택된 행 집합
	//this.states;//현재 상태
	this.inputCols = new DataMap();
	this.checkCols = new DataMap();
	this.selectCols = new DataMap();
	this.selectGroupCols = new DataMap();
	this.colTypeMap = new DataMap();
	this.rowCheckType = false;
	
	this.startRowNum = 0;
	this.endRowNum = 0;
	
	this.firstRowFocusType = true;
	this.focusRowNum = -1;
	this.focusColName;
	this.$focusInput;
	this.searchParam;
	this.bodyHeight;
	//this.$body;
	this.$bodyBox;
	this.rowHeight = theme.GRID_DEFAULT_ROW_HEIGHT;
	this.bodyBoxHeight;
	this.viewRowCount;
	
	this.selectType="";
	this.selectingType = 0;
	this.selectedData;
	this.selectedRows;
	this.selectedCols;
	this.selectedRowCheckType = true;
	
	this.readOnlyType = false;
	this.readOnlyColList;
	this.readOnlyColMap;
	this.readOnlyRowMap;
	this.readOnlyCellMap;
	
	this.colFormatMap = new DataMap();
	this.colSearchMap = new DataMap();
	this.colSearchMultiMap = new DataMap();
	this.colHtmlMap = new DataMap();
	this.colFunctionMap = new DataMap();
	
	this.sortColMap = new DataMap();
	this.sortColList = new Array();
	this.sortColNumList = new Array();
	this.sortTypeList = new Array();
	
	this.maxViewDataCell = 1000;
	
	this.emptyMsgType = true;
	
	this.viewFormat = true;
	
	//this.lastRowNum;
	this.$lastCol;
	
	this.autoNewRowType = false;
	this.autoCopyRowType = true;
	
	this.enterKeyType = "C";
	this.defaultRowStatus = configData.GRID_ROW_STATE_START;
	
	this.colGroupCols;
	
	this.pageListCount = 5;
	this.pageCount = 0;
	this.pageNum = 1;
	this.totalCount = 0;
	
	this.scrollPageCount = 0;
	this.pageEnd = false;
	
	this.pagingParam;
	
	this.appendPageCount = 0;
	
	this.gridHeadType = true;
	this.gridBottomType = true;
	this.gridScrollType = true;
	this.gridMobileType = false;
	
	this.colorType = false;
	
	this.excelConn = "common";
	this.excelCsvType = false;
	this.excelTextType = false;
	this.excelXType = true;
	this.excelTextDelimiter = ",";
	this.excelLabelView = true;
	this.excelRequestMaxRow = 0;
	this.excelDownloadCount = 0;
	this.excelRequestGridData = true;
	this.excelRequestGridSelectData = false;
	this.excelRequestViewCols = true;
	this.excelHeadRow = null;
	this.excelFileName = null;
	this.excelTempUrl = null;
	this.excelRequestEditableCols = false; // 2019.04.24 jw : Excel UploadForm Editable Column Only Option Added
	
	this.autoCompletMap = new DataMap();
	
	this.itemGrid;
	this.itemGridList;
	this.searchRowNum = -1;
	this.itemSearch = false;
	
	this.headGrid;
	this.$headGrid;
	
	this.headColgroupTagName = "colgroup";
	this.headColattTagName = "col";
	this.headTagName = "thead";
	this.headRowTagName = "tr";
	this.headColTagName = "th";
	this.bodyBoxTagName = "div";
	this.bodyTagName = "table";
	this.colgroupTagName = "colgroup";
	this.colattTagName = "col";
	this.rowTagName = "tr";
	this.colTagName = "td";
	
	this.defaultBodyTop;
	
	this.copyEventType = true;
	
	this.colNameIndex;
	
	this.editedClassType = true;
	
	this.sortableCols;
	this.sortableColMap;
	
	this.multisort = true;
	this.modifyRowCheck = true;
	this.focusRowCheck = false;
	
	this.colValueChangeEvent = false;
	
	this.selectRowClassView = true;
	
	this.subTotalCols;
	this.subTotalNums;
	this.$subTotalRow;
	this.sortGroupList;
	this.sortGroupMap;
	this.subTotalSumList;
	this.subTotalView;
	
	this.rowClickEventFn;
	this.rowDblClickEventFn;
	
	this.filterDataMap = null;
	this.filterViewType;
	
	this.deleteRowViewType = false;
	this.selectRowDeleteType = false;
	
	this.actionMap;
	
	this.checkBoxHtml;
	
	this.colTailMap = new DataMap();
	this.colHeadMap = new DataMap();
	
	this.addRowAppendType = true;
	this.sortSaveType = true;
	
	this.pageMoveNum = 0;
	
	this.addType = false;
	this.deleteType = false;
	this.columnEditType = false;
	this.totalType = false;
	this.excelDownType = false;
	this.colFixBtnType = false;
	
	this.scrollStopState = false;
	
	/*2019.03.12 이범준  layout save open 시 지정 컬럼 전달*/
	this.layoutSaveFormatData = "";
	this.excelLoader = false;
	
	this.rowCheckText = new DataMap();
	this.gridIconMap = new DataMap();
	
	this.scrollLoading = "";
	
	this.draggInitType = false;
	this.dataLoadStart = false;
	
	this.$totalViewRow;
	this.totalNumMap = new DataMap();
	
	this.inputRowNum = null;
	this.inputColName = null;
}

GridBox.prototype = {
	reset : function() {
		//this.textData = "";
		this.data = new Array();
		this.jsonData = null;
		this.mapData = new Array();
		this.viewDataList = new Array();
		this.modifyRow = new DataMap();
		this.modifyCols = new Array();
		this.sourceCols = new Array();
		this.selectRow = new DataMap();
		//this.states = null;
		this.focusRowNum = -1;
		this.$box.find("["+configData.GRID_ROW+"]").remove();
		this.startRowNum = 0;
		this.endRowNum = 0;
		
		this.pageNum = 1;
		this.pageEnd = false;
		
		//this.lastRowNum = -1;
		
		this.selectType = "";
		this.selectingType = 0;
		this.selectedData = null;
		this.selectedRows = null;
		this.selectedCols = null;
		
		this.readOnlyRowMap = null;
		this.readOnlyCellMap = null;
		
		this.findDataReset();
		this.sortColMap = new DataMap();
		
		this.resetColFix();
		
		this.filterViewType = false;
		this.filterDataMap = null;
		
		this.subTotalView = false;
		this.sortGroupMap = null;
		
		if(this.scrollPageCount > 0){
			this.scrollType = true;
		}else{
			this.scrollType = false;
		}
		
		this.scrollTop = 0;
		this.scrollLeft = 0;
		
		if(this.$checkHead){
			this.$checkHead.find("input").prop("checked", false);
		}		
		
		if(this.$bodyBox && this.$bodyBox.length > 0){
			this.$bodyBox.get(0).scrollTop = 0;
			this.$bodyBox.get(0).scrollLeft = 0;
		}
		if(this.$tableBox && this.$tableBox.length > 0){
			theme.setGridScrollMarginTop(this.$tableBox, "0px");
			theme.setGridScrollMarginBottom(this.$tableBox, "0px");
			/*
			this.$tableBox.css({
				"padding-bottom":"0px",
				"padding-top":"0px"
				});
			*/
		}
		//this.reloadComboData();
		if(this.$gridHead && this.$gridHead.length > 0){
			this.$gridHead.css({
				"margin-left" : "0px"
			});
		}
		
		this.setInfo(0);
		if(this.totalView || this.totalShow){
			this.viewTotal(false);
		}
		
		gridList.checkInputObj();
		this.scrollOff();
	},
	resetTool : function(resetType) {
		if(resetType == "find"){
		
		}else if(resetType == "sortStart"){
			this.sortReset();
			this.resetColFix();
		}else if(resetType == "sort"){
			this.findDataReset();
			this.resetSubTotal(true);
			//this.filterDataReset();
			this.resetColFix();
		}else if(resetType == "total"){
			this.resetColFix();
		}else if(resetType == "filter"){
			this.findDataReset();
			this.viewTotal(false);
			this.resetSubTotal(true);
			this.sortReset();
			this.resetColFix();
		}else if(resetType == "subTotal"){
			this.sortReset();
			this.resetColFix();
		}else if(resetType == "colFix"){
			this.findDataReset();
			this.viewTotal(false);
			this.resetSubTotal(true);
		}else{
			this.findDataReset();
			this.viewTotal(false);
			this.resetSubTotal(true);
			this.filterDataReset();
			this.sortReset();
			this.resetColFix();
		}
		this.setInfo();
	},
	changeRowHeight : function(rowHeight) {
		if(isNaN(rowHeight)){
			rowHeight = theme.GRID_DEFAULT_ROW_HEIGHT;
		}else{
			rowHeight = parseInt(rowHeight);
		}
		if(rowHeight != this.rowHeight){
			this.rowHeight = rowHeight;
			this.rowHtml = jQuery(this.rowHtml).css("height", this.rowHeight+"px").wrapAll("<div/>").parent().html();
			this.rowNewHtml = jQuery(this.rowNewHtml).css("height", this.rowHeight+"px").wrapAll("<div/>").parent().html();
			this.reloadView(true);
		}
	},
	reloadComboData : function() {
		if(this.comboList.length > 0){
			var reloadColList = new Array();
			var comboMap;
			for(var i=0;i<this.comboList.length;i++){
				comboMap = this.comboList[i];
				if(this.viewColMap.containsKey(comboMap.get(configData.GRID_COL_NAME))){
					reloadColList.push(i);
				}
			}
			if(reloadColList.length > 0){
				var $tmpObj = jQuery(this.rowHtml);
				var $tmpNewObj = jQuery(this.rowNewHtml);
				var $select;
				var colName;
				var comboType;
				var comboData;
				for(var i=0;i<reloadColList.length;i++){
					comboMap = this.comboList[reloadColList[i]];
					colName = comboMap.get(configData.GRID_COL_NAME);
					comboType = comboMap.get(configData.INPUT_COMBO_TYPE);
					comboData = comboMap.get(configData.INPUT_COMBO_OPTION);
					
					$select = $tmpObj.find("["+configData.GRID_COL_NAME+"="+colName+"]").find("select");
					inputList.reloadCombo($select, comboType, comboData);					
					
					$select.find("option").each(function(i, findElement){
						var $optionObj = jQuery(findElement);
						var tmpValue = $optionObj.attr("value");
						if(tmpValue){
							tmpValue = jQuery.trim(tmpValue);
						}else{
							tmpValue = "";
						}
						try{
							$optionObj.attr(configData.GRID_COL_DATA_NAME_OPTION_HEAD+colName+tmpValue+configData.GRID_COL_DATA_NAME_ATT_TAIL, '');
						}catch(e){
						}
					});
				}
				this.rowHtml = $tmpObj.clone().wrapAll("<div/>").parent().html();
				this.rowHtml = this.getRowHtml(this.rowHtml);
				this.rowNewHtml = this.getRowNewHtml(this.rowHtml);
			}			
		}
	},
	resetReadOnly : function() {
		this.readOnlyType = false;
		this.readOnlyColList = null;
		this.readOnlyColMap = null;
		this.readOnlyRowMap = null;
	},
	resetEditCols : function() {
		this.viewEditCols = new Array();
		for(var i=0;i<this.viewCols.length;i++){
			for(var j=0;j<this.editableCols.length;j++){
				if(this.viewCols[i] == this.editableCols[j]){
					this.viewEditCols.push(this.viewCols[i]);
					break;
				}
			}
		}
	},
	resetColFormat : function(colFormat, viewCols) {
		if(colFormat){
			this.colFormatMap = colFormat;
			
			if(viewCols){
				for(var i=0;i<viewCols.length;i++){
					var colName = viewCols[i];
					var colReplaceName = configData.GRID_COL_DATA_NAME_VIEW_HEAD+colName+configData.GRID_COL_DATA_NAME_TAIL;
					var tmpIndex = this.rowHtml.indexOf(colReplaceName);
					var tmpStr;
					if(tmpIndex == -1){
						colReplaceName = configData.GRID_COL_DATA_NAME_HEAD+colName+configData.GRID_COL_DATA_NAME_TAIL;
						tmpIndex = this.rowHtml.lastIndexOf(colReplaceName);
						tmpStr = this.rowHtml.substring(0,tmpIndex)+configData.GRID_COL_DATA_NAME_VIEW_HEAD+colName+configData.GRID_COL_DATA_NAME_TAIL+this.rowHtml.substring(tmpIndex+colReplaceName.length);
						this.rowHtml = tmpStr;
					}
				}
			}
		}else{
			this.colFormatMap = new DataMap();
			if(viewCols){
				for(var i=0;i<viewCols.length;i++){
					var colName = viewCols[i];
					var colReplaceName = configData.GRID_COL_DATA_NAME_VIEW_HEAD+colName+configData.GRID_COL_DATA_NAME_TAIL;
					var tmpIndex = this.rowHtml.indexOf(colReplaceName);
					var tmpStr;
					if(tmpIndex != -1){
						tmpStr = this.rowHtml.substring(0,tmpIndex)+configData.GRID_COL_DATA_NAME_HEAD+colName+configData.GRID_COL_DATA_NAME_TAIL+this.rowHtml.substring(tmpIndex+colReplaceName.length);
						this.rowHtml = tmpStr;
					}
				}
			}
		}		
	},
	resetColSearch : function(colSearch) {
		if(colSearch){
			this.colSearchMap = colSearch;
			this.colSearchMultiMap = new DataMap();
			this.colSearchMultiMap.put(configData.INPUT_RANGE_SINGLE_DATA, true);
		}else{
			this.colSearchMap = new DataMap();
			this.colSearchMultiMap = new DataMap();
		}		
	},
	changeCheckHead : function(checkType){
		var $obj = this.$checkHead.find("input");
		$obj.prop("checked", checkType);
		
		this.checkAll(checkType);
	},
	resetColFix: function() {
		if(this.colFixType){
			this.colFixNum = -1;
			this.colFixType = false;
			
			this.colFixWidthList = null;
			var $colList = this.$colFix.find(this.colgroupTagName+">"+this.colattTagName);
			var $bodyColList = this.$gridBody.find(this.colgroupTagName+">"+this.colattTagName);
			var tmpWidth;
			for(var i=0;i<$colList.length;i++){
				tmpWidth = commonUtil.getAttrNum($colList.eq(i),"width");
				tmpWidth+="px";
				$bodyColList.eq(i).attr("width",tmpWidth);
				$bodyColList.eq(i).css("width",tmpWidth);
			}
			
			tmpWidth = commonUtil.getCssNum(this.$colFix,"width");
			var tmpBodyWidth = commonUtil.getCssNum(this.$gridBody,"width");
			tmpBodyWidth += tmpWidth;
			this.$gridBody.css({
				"left":0,
				"width":tmpBodyWidth+"px"
			});
			this.$colFix.remove();
			this.$colFix = null;
			
			this.$headColFix.remove()
			this.$headColFix = null;
		}		
	},
	colFix : function() {
		this.resetTool("colFix");
		if(this.colFixType){
			this.resetColFix();
			return;
		}else{
			if(this.focusRowNum != -1 && this.focusColName){
				for(var i=0;i<this.viewCols.length;i++){
					if(this.focusColName == this.viewCols[i]){
						this.colFixNum = i;
						break;
					}
				}
				if(this.colFixNum >= 0){
					this.colFixType = true;
					this.colFixNum++;
					/*
					if(this.rowCheckType){
						this.colFixNum++;
					}
					if(this.rowNumType){
						this.colFixNum++;
					}
					*/
				}else{
					this.resetColFix();
					return;
				}
			}else{
				return;
			}
		}
		this.colFixWidthList = new Array();
		this.$colFix = this.$gridBody.clone(true);
		var $tmpList = this.$colFix.find(this.colgroupTagName+">"+this.colattTagName);
		var tmpWidth = 0;
		for(var i=0;i<$tmpList.length;i++){
			var tmpNum = commonUtil.getAttrNum($tmpList.eq(i),"width");
			tmpWidth += tmpNum;
		}
		
		var tmpBodyWidth = commonUtil.getCssNum(this.$gridBody,"width");
		if(tmpWidth < tmpBodyWidth){
			this.colFixType = false;
			return;
		}
		
		this.$colFix.find(this.colgroupTagName).find(this.colattTagName+":gt("+(this.colFixNum-1)+")").remove();
		this.$colFix.find(this.rowTagName).find(this.colTagName+":gt("+(this.colFixNum-1)+")").remove();
		//this.$colFix.find("tr").find("td:gt("+this.colFixNum+")").remove();
		var $colList = this.$colFix.find(this.colgroupTagName+">"+this.colattTagName);
		var tmpWidth = 0;
		
		this.$headColFix = jQuery("<div class='tableBody'><table><colgroup></colgroup><thead><tr height='24px'></tr></thead></table></div>");
		for(var i=0;i<$colList.length;i++){
			var tmpNum = commonUtil.getAttrNum($colList.eq(i),"width");
			this.colFixWidthList.push(tmpNum);
			tmpWidth += tmpNum;

			var $tmpColObj = jQuery("<col>");
			$tmpColObj.attr("width",tmpNum+"px");
			$tmpColObj.css({
				"width":tmpNum+"px"
			});
			this.$headColFix.find("tr").append("<th>"+this.colTextMap.get($colList.eq(i).attr(configData.GRID_COL_NAME))+"</th>");
			this.$headColFix.find("colgroup").append($tmpColObj);
		}

		tmpBodyWidth -= tmpWidth;
		tmpWidth = tmpWidth+"px";
		//var tmpTop = commonUtil.getCssNum(this.$colFix,"top")+commonUtil.getCssNum(this.$colFix,"padding-top");
		if(this.$gridBody.get(0).scrollWidth > this.$gridBody.innerWidth()){
			this.$colFix.css({
				"width":tmpWidth,
				"overflow-y":"hidden",
				"overflow-x":"scroll",
				"z-index" : 1000
			});
		}else{
			this.$colFix.css({
				"width":tmpWidth,
				"overflow":"hidden"
			});
		}
		
		//tmpTop -= commonUtil.getCssNum(this.$gridBody,"top");
		this.$headColFix.css({
			"width":tmpWidth,
			"overflow":"visible",
			"top" : "0px"
		});
		
		this.$gridBody.find(this.colgroupTagName+">"+this.colattTagName+":lt("+this.colFixNum+")").css("width","0px").css("width","0px");
		this.$gridBody.css({
			"left":tmpWidth,
			"width":tmpBodyWidth+"px"
		});
		
		this.$colFix.addClass(theme.GRID_COLFIXBODY_CLASS);
		this.$gridBody.parent().append(this.$colFix);
		this.$colFix.get(0).scrollTop = this.$bodyBox.get(0).scrollTop;
		this.$colFix.get(0).scrollHeight = this.$bodyBox.get(0).scrollHeight;
		
		this.$headColFix.addClass(theme.GRID_COLFIXHEAD_CLASS);
		this.$gridBody.parent().append(this.$headColFix);
		this.$headColFix.get(0).scrollTop = this.$bodyBox.get(0).scrollTop;
		
		this.setColFixEvent();
	},
	colFixScroll : function() {
		this.$colFix.remove();
		this.$colFix = this.$gridBody.clone(true);
		this.$colFix.find(this.colgroupTagName).find(this.colattTagName+":gt("+(this.colFixNum-1)+")").remove();
		this.$colFix.find(this.rowTagName).find(this.colTagName+":gt("+(this.colFixNum-1)+")").remove();
		var $colList = this.$colFix.find(this.colgroupTagName+">"+this.colattTagName);
		var tmpWidth = 0;
		for(var i=0;i<$colList.length;i++){
			tmpWidth += this.colFixWidthList[i];
			$colList.eq(i).attr("width",this.colFixWidthList[i]+"px");
			$colList.eq(i).css({
				"width":this.colFixWidthList[i]+"px"
			});
		}
		tmpWidth = tmpWidth+"px";
		//var tmpTop = commonUtil.getCssNum(this.$colFix,"top")+commonUtil.getCssNum(this.$colFix,"padding-top");
		if(this.$gridBody.get(0).scrollWidth > this.$gridBody.innerWidth()){
			this.$colFix.css({
				"width":tmpWidth,
				"overflow-y":"hidden",
				"overflow-x":"scroll",
				//"top": tmpTop+"px",
				"left" : "0px",
				"z-index" : 1000
			});
		}else{
			this.$colFix.css({
				"width":tmpWidth,
				"overflow":"hidden",
				"left" : "0px"
			});
		}
		
		this.$colFix.addClass(theme.GRID_COLFIXBODY_CLASS);
		this.$gridBody.parent().append(this.$colFix);
		this.$colFix.get(0).scrollTop = this.$bodyBox.get(0).scrollTop;
		this.$colFix.get(0).scrollHeight = this.$bodyBox.get(0).scrollHeight;
		
		this.setColFixEvent();
	},
	setColFixEvent : function(){
		var gridBox = this;
		this.$colFix.off("click");
		this.$colFix.click(function(event){
			var $obj = jQuery(event.target);
			var tmpTagName = $obj.get(0).tagName;
			if(tmpTagName == "INPUT" || tmpTagName == "SELECT"){
				var $colObj = $obj.parents("["+configData.GRID_COL+"]");
				var colType = $colObj.attr(configData.GRID_COL_TYPE);
				var colName = $colObj.attr(configData.GRID_COL_NAME);
				
				var $rowObj = $colObj.parents("["+configData.GRID_ROW+"]");
				if($rowObj.attr(configData.GRID_ROW_TOTAL_ATT)){
					return true;
				}
				var rowNum = $rowObj.attr(configData.GRID_ROW_NUM);
				
				if(colType == configData.GRID_COL_TYPE_ROWCHECK){
					if($obj.prop("checked")){
						gridBox.setRowCheck(rowNum, true, true);
					}else{
						gridBox.setRowCheck(rowNum, false, true);
					}
				}else if(colType == configData.GRID_COL_TYPE_CHECKBOX){
					if($obj.prop("checked")){
						gridBox.setColValue(rowNum, colName, site.defaultCheckValue, true);
					}else{
						gridBox.setColValue(rowNum, colName, " ", false);
					}
					if(gridBox.modifyRowCheck){
						$rowObj.find("["+configData.GRID_COL_TYPE+"="+configData.GRID_COL_TYPE_ROWCHECK+"]").find("input").prop("checked",true);
					}
				}
			}
			//gridBox.clickEvent($obj, event);
		});
		
		this.$colFix.find("select").each(function(i,findElement){
			var $obj = jQuery(findElement);
			var $colObj = $obj.parents("["+configData.GRID_COL+"]");
			var colName = $colObj.attr(configData.GRID_COL_NAME);
			var $rowObj = $colObj.parents("["+configData.GRID_ROW+"]");
			var rowNum = $rowObj.attr(configData.GRID_ROW_NUM);
			var colValue = gridBox.getColValue(rowNum, colName);
			var colText = $obj.find("option[value="+colValue+"]").text();
			$colObj.html(colText);
			$colObj.addClass(configData.GRID_COL_TYPE_TEXT_CLASS);
		});
	},
	checkSysColType : function(colName){
		return (colName == configData.GRID_COL_TYPE_ROWNUM || colName == configData.GRID_COL_TYPE_ROWCHECK || colName == configData.GRID_COL_TYPE_TREE);
	},
	getSubtotalSum : function(startRowNum, endRowNum){
		var totNumList = new Array();
		for(var i=0;i<this.subTotalNums.length;i++){
			totNumList.push(new Big(0));
		}
		var rowNum;
		var tmpNum;
		var totNum
		for(var i=startRowNum;i<=endRowNum;i++){
			rowNum = this.viewDataList[i];
			for(var j=0;j<this.subTotalNums.length;j++){
				tmpNum = this.getColValue(rowNum, this.subTotalNums[j]);
				if(!isNaN(tmpNum)){
					//totNum += new Number(tmpNum);
					totNumList[j] = totNumList[j].plus(tmpNum);
				}
			}
		}
		
		return totNumList;
	},
	createSubTotal : function(e) {
		//alert(this.sortGroupList);
		var groupMap;
		this.subTotalSumList = new Array();
		for(var i=0;i<this.subTotalNums.length;i++){
			this.subTotalSumList.push(new Big(0));
		}
		var totNumList;
		for(var i=0;i<this.sortGroupList.length;i++){
			groupMap = this.sortGroupList[i];
			totNumList = this.getSubtotalSum(groupMap.get("S"), groupMap.get("E"));
			for(var j=0;j<this.subTotalNums.length;j++){
				this.subTotalSumList[j] = this.subTotalSumList[j].plus(totNumList[j]);
			}
			groupMap.put("T", totNumList);
		}
		//alert(this.sortGroupList);
		//alert(totalList);
	},
	resetSubTotal : function(resetToolType){
		if(this.$subTotalRow && this.totalView){
			this.subTotalCols = null;
			this.subTotalNums = null;
			this.viewSubTotal(false, resetToolType);
		}
	},
	viewSubTotal : function(viewType, resetToolType){
		if(!this.$subTotalRow){
			var $totalTr = jQuery(this.rowNewHtml);
			$totalTr.find("input,select").remove();
			//this.subTotalRowHtml = $totalTr.wrapAll("<div/>").parent().html();
			this.$subTotalRow = $totalTr;
			this.$subTotalRow.attr(configData.GRID_ROW_TOTAL_ATT, "true");
			this.$subTotalRow.addClass(configData.GRID_ROW_SELECT_CLASS).css("font-weight","bold");
		}
		if(viewType == undefined){
			viewType = !this.totalView;
		}
		if(viewType){
			if(!resetToolType){
				this.resetTool("subTotal");
			}			
			for(var i=0;i<this.subTotalCols.length;i++){
				this.addSort(this.subTotalCols[i], true, false);
			}
			this.createSubTotal();
			this.totalView = true;
			this.subTotalView = true;
			this.reloadView(true);
		}else{
			this.sortGroupMap = null;
			this.totalView = false;
			this.subTotalView = false;
			this.sortReset(true);
		}
	},
	setTotalColtext : function(colName, colText){
		this.$totalViewRow.find("["+configData.GRID_COL_NAME+"="+colName+"]").text(colText);
	},
	viewTotal : function(viewType){
		/*
		if(this.subTotalCols){
			this.viewSubTotal(viewType);
			return;
		}
		*/
		if(this.subTotalView){
			return;
		}
		if(viewType == undefined){
			viewType = !this.totalView;
			theme.viewTotal(this, viewType);
		}
		var $trs = this.$gridHead.find(this.headTagName+" > "+this.headRowTagName);
		var bodyTop = commonUtil.getCssNum(this.$gridBody, "top");
		if(viewType){
			if($trs.length == this.headRowCount){
				var $totalTr = this.createTotalRow();
				if($totalTr){
					this.$gridHead.find(this.headTagName).append($totalTr);
					//bodyTop = parseInt(bodyTop*2);
					bodyTop += this.defaultBodyTop;
					this.$gridBody.css("top", bodyTop+"px");
					this.totalView = true;
					
					this.$totalViewRow = $totalTr;
					//event fn
					if(commonUtil.checkFn("gridListEventTotalViewEnd")){
						gridListEventTotalViewEnd(this.id, this.totalNumMap);
					}
				}else{
					this.totalView = false;
				}			
			}
		}else{
			if($trs.length > this.headRowCount){
				$trs.eq($trs.length-1).remove();
				//bodyTop = parseInt(bodyTop/2);
				bodyTop -= this.defaultBodyTop;
				this.$gridBody.css("top", bodyTop+"px");
				this.totalView = false;
			}
		}
	},
	createTotalRow : function(){
		//var $ths = this.$gridHead.find(this.headTagName+" > "+this.headRowTagName+":first").find(this.headColTagName);
		var $totalTr = jQuery("<"+this.headRowTagName+"></"+this.headRowTagName+">");
		var colName;
		var tmpHtml;
		var tNum;
		var createType = false;
		var tmpSumTxtView = false;
		var sumNum;
		/*
		for(var i=0;i<this.sysCols.length;i++){
			if(i==0){
				tmpHtml = "<"+this.headColTagName+" "+configData.GRID_COL_NAME+">∑</"+this.headColTagName+" "+configData.GRID_COL_NAME+">";
				tmpSumTxtView = true;
			}else{
				tmpHtml = "<"+this.headColTagName+" "+configData.GRID_COL_NAME+"></"+this.headColTagName+" "+configData.GRID_COL_NAME+">";
			}
			$totalTr.append(tmpHtml);
		}
		*/
		for(var i=0;i<this.viewCols.length;i++){
			colName = this.viewCols[i];
			if(this.totalColsMap.containsKey(colName)){
				tNum = this.totalColsMap.get(colName);
				tmpHtml = jQuery("<"+this.headColTagName+" "+configData.GRID_COL_NAME+"='"+colName+"' style='font-weight: bold;'></"+this.headColTagName+">");
				tmpHtml.addClass(configData.GRID_COL_TYPE_TEXT_RIGHT_CLASS);
				if(tNum == true){
					var numberType;
					if(this.colFormatMap.containsKey(colName)){
						var tmpList = this.colFormatMap.get(colName);
						if(tmpList.length > 1){
							numberType = tmpList[1];
						}
					}
					sumNum = this.sumColNum(colName);
					tmpHtml.text(sumNum, numberType);
					this.totalNumMap.put(colName, sumNum);
				}else{
					tmpHtml.text(tNum);
				}				
				createType = true;
			}else{
				if(tmpSumTxtView){
					tmpHtml = "<"+this.headColTagName+" "+configData.GRID_COL_NAME+"='"+colName+"'></"+this.headColTagName+" "+configData.GRID_COL_NAME+">";
				}else{
					tmpHtml = "<"+this.headColTagName+" "+configData.GRID_COL_NAME+">∑</"+this.headColTagName+" "+configData.GRID_COL_NAME+">";
					tmpSumTxtView = true;
				}				
			}
			$totalTr.append(tmpHtml);
		}
		if(createType){
			return $totalTr;
		}else{
			return createType;
		}		
	},
	getColSum : function(colName, numberType){
		var totNum = new Big(0);
		var rowNum;
		var tmpNum;
		for(var i=0;i<this.viewDataList.length;i++){
			rowNum = this.viewDataList[i];
			tmpNum = this.getColValue(rowNum, colName);
			if(tmpNum != "" && !isNaN(tmpNum)){
				//totNum += new Number(tmpNum);
				totNum = totNum.plus(tmpNum);
			}			
		}
		
		return totNum.toString();
	},
	sumColNum : function(colName, numberType){
		var totNum = this.getColSum(colName, numberType);
		if(isNaN(totNum)){
			totNum = 0;
		}else{
			totNum = uiList.getNumberViewFormat(new String(totNum), numberType);
		}
		
		return totNum;
	},
	maxColValue : function(colName){
		var maxTxt = "";
		var rowNum;
		var tmpTxt;
		for(var i=0;i<this.viewDataList.length;i++){
			rowNum = this.viewDataList[i];
			tmpTxt = this.getColValue(rowNum, colName);
			if(tmpTxt.length > maxTxt.length){
				maxTxt = tmpTxt;
			}			
		}
		
		return maxTxt;
	},
	changeSumColAll : function(){
		var colName;
		for(var i=0;i<this.viewCols.length;i++){
			colName = this.viewCols[i];
			if(this.colFormatMap.containsKey(colName)){
				var formatList = this.colFormatMap.get(colName);
				if(formatList[0] == configData.INPUT_FORMAT_NUMBER){
					this.changeSumColNum(colName, formatList[1]);
				}
			}
		}		
	},
	changeSumColNum : function(colName, numberType){
		var totNum = this.getColSum(colName, numberType);
		if(this.colFormatMap.containsKey(colName)){
			var formatList = this.colFormatMap.get(colName);
			totNum = uiList.getDataFormat(formatList, totNum, true);
		}

		this.$gridHead.find(this.headTagName+" > "+this.headRowTagName+":eq(1)").find("["+configData.GRID_COL_NAME+"="+colName+"]").text(totNum);
	},
	createCheckObj : function(){
		var $check = jQuery(theme.GRID_EDIT_CHECKBOX_HTML);
		$check.attr("value", site.defaultCheckValue);
		return $check;
	},
	setMobileHead : function(){
		this.$checkHead = this.$gridHead.find("["+configData.GRID_BTN_CHECK_ATT+"]");
		if(this.$checkHead){	
			var gridBox = this;
			
			var $check = this.createCheckObj();
			$check.attr(configData.GRID_CHECKBOX_ALL_ATT, "true");
			this.$checkHead.append($check);
			
			this.$checkHead.attr(configData.GRID_COL_VALUE, site.emptyValue);
			this.$checkHead.attr(configData.GRID_BOX, gridBox.id);
			this.$checkHead.click(function(event){
				var $obj = jQuery(event.target);
				var check = $obj.attr(configData.GRID_CHECKBOX_ALL_ATT);
				if(check){
					var checkType;					
					if($obj.prop("checked")){
						checkType = true;
					}else{
						checkType = false;
					}
					gridBox.checkAll(checkType);
				}
			});
		}
	},
	headColBg : function(colName, className){
		var $headTd = this.$gridHead.find(this.headTagName+" > "+this.headRowTagName+":first").find("> "+this.headColTagName+"["+configData.GRID_COL_NAME+"="+colName+"]");
		if(className){
			$headTd.addClass(className);
		}else{
			$headTd.removeClass(className);
		}
	},
	getHeadCells : function(){
		this.defaultBodyTop = commonUtil.getCssNum(this.$gridBody, "top");
		var $headRow = this.$gridHead.find(this.headTagName+" > "+this.headRowTagName);
		if($headRow.length == 0){
			this.layoutType = false;
			this.headColDragType = false;
		}else if($headRow.length == 1){
			this.headRowCount = 1;
			var $tmpCells = $headRow.eq(0).find("> "+this.headColTagName);
			for(var i=0;i<$tmpCells.length;i++){
				this.headCells.push($tmpCells.eq(i));
			}
		}else{
			this.headRowCount = $headRow.length;
			var rowTypes = new Array();
			var rowObj = new Array();
			this.excelHeadRow = new Array();
			var $tmpRowCols;
			var $tmpCell;
			var tmpRowspan;
			var tmpColspan;
			var colCount;
			for(var i=0;i<$headRow.length;i++){
				rowTypes[i] = new Array();
				rowObj[i] = new Array();
				this.excelHeadRow[i] = new Array();
			}
			
			for(var i=0;i<$headRow.length;i++){
				$tmpRowCols = $headRow.eq(i).find("> "+this.headColTagName);
				colCount = 0;				
				for(var j=0;j<$tmpRowCols.length;j++){
					while(rowTypes[i][colCount]){
						colCount++;
					}
					$tmpCell = $tmpRowCols.eq(j);
					rowObj[i][colCount] = $tmpRowCols.eq(j);
					tmpRowspan = $tmpCell.attr("rowspan");
					tmpColspan = $tmpCell.attr("colspan");
					if(tmpRowspan && tmpColspan){
						tmpRowspan = parseInt(tmpRowspan);
						tmpColspan = parseInt(tmpColspan);
						for(var k=i;k<i+tmpRowspan;k++){
							for(var l=colCount;l<colCount+tmpColspan;l++){
								rowTypes[k][l] = "A";
								this.excelHeadRow[k][l] = "B";
							}
						}
						this.excelHeadRow[i][colCount] = $tmpCell.text()+configData.DATA_CELL_SEPARATOR+"0"+configData.DATA_CELL_SEPARATOR+tmpRowspan+configData.DATA_CELL_SEPARATOR+tmpColspan;
						colCount += tmpColspan;
					}else if(tmpRowspan){
						tmpRowspan = parseInt(tmpRowspan);
						for(var k=i;k<i+tmpRowspan;k++){
							rowTypes[k][colCount] = "R";
							this.excelHeadRow[k][colCount] = "B";
						}
						this.excelHeadRow[i][colCount] = $tmpCell.text()+configData.DATA_CELL_SEPARATOR+commonUtil.getCssNum($tmpCell, "width")+configData.DATA_CELL_SEPARATOR+tmpRowspan+configData.DATA_CELL_SEPARATOR+"0";
						colCount++;
					}else if(tmpColspan){
						tmpColspan = parseInt(tmpColspan);
						for(var l=colCount;l<colCount+tmpColspan;l++){
							rowTypes[i][l] = "C";
							this.excelHeadRow[i][l] = "B";
						}
						this.excelHeadRow[i][colCount] = $tmpCell.text()+configData.DATA_CELL_SEPARATOR+"0"+configData.DATA_CELL_SEPARATOR+"0"+configData.DATA_CELL_SEPARATOR+tmpColspan;
						colCount += tmpColspan;
					}else{
						rowTypes[i][colCount] = "T";
						this.excelHeadRow[i][colCount] = $tmpCell.text()+configData.DATA_CELL_SEPARATOR+commonUtil.getCssNum($tmpCell, "width")+configData.DATA_CELL_SEPARATOR+"0"+configData.DATA_CELL_SEPARATOR+"0";
						colCount++;
					}
				}
			}
			/*
			var tmpStr = "";
			for(var i=0;i<$headRow.length;i++){
				tmpStr += this.excelHeadRow[i].toString()+"\n";
			}
			alert(tmpStr);
			*/
			for(var i=0;i<rowTypes[0].length;i++){
				for(var j=0;j<rowTypes.length;j++){
					if(rowTypes[j][i] == "T"){
						this.headCells[i] = rowObj[j][i];
						break;
					}
				}
				if(!this.headCells[i]){
					for(var j=0;j<rowTypes.length;j++){
						if(rowTypes[j][i] == "R"){
							this.headCells[i] = rowObj[j][i];
							break;
						}
					}
				}
				if(!this.headCells[i]){
					for(var j=0;j<rowTypes.length;j++){
						if(rowTypes[j][i] == "C"){
							this.headCells[i] = rowObj[j][i];
							break;
						}
					}
				}
				if(!this.headCells[i]){
					for(var j=0;j<rowTypes.length;j++){
						if(rowObj[j][i]){
							this.headCells[i] = rowObj[j][i];
							break;
						}
					}
				}
				if(!this.headCells[i]){
					alert("grid "+this.id+" head "+i+"번 cell이 정상적이지 않습니다.");
				}
				//commonUtil.consoleMsg(this.headCells[i].html());
			}
			//alert(this.headCells);
			var bodyTop = this.defaultBodyTop*$headRow.length;
			this.$gridBody.css("top", bodyTop+"px");
		}
	},
	setHead : function(){
		var gridBox = this;
		
		var $checkHeadList = this.$gridHead.find("["+configData.GRID_BTN_CHECK_ATT+"]");
		var $checkCol;
		var checkBtnValue;
		for(var i=0;i<$checkHeadList.length;i++){
			$checkCol = $checkHeadList.eq(i);
			var $check = this.createCheckObj();
			checkBtnValue = $checkCol.attr(configData.GRID_BTN_CHECK_ATT);
			if(checkBtnValue == "true"){
				this.$checkHead = $checkHeadList.eq(i);
				$check.attr(configData.GRID_CHECKBOX_ALL_ATT, "true");
			}
			$checkCol.append($check);
			$checkCol.attr(configData.GRID_COL_VALUE, site.emptyValue);
			$checkCol.attr(configData.LABEL_ATT, $checkCol.text());
			$checkCol.attr(configData.GRID_BOX, gridBox.id);
		}
		
		var $headCol = this.$gridHead.find(this.headColgroupTagName);
		if($headCol.length == 0){			
			$headCol = this.$gridBody.find(this.colgroupTagName).clone();
			this.$gridHead.find(this.headTagName).before($headCol);
		}
		$headCol = $headCol.find("> "+this.headColattTagName);
				
		//var $headTd = this.$gridHead.find(this.headTagName+" > "+this.headRowTagName+":first").find("> "+this.headColTagName);
		this.getHeadCells();
		//var $headTd = this.getHeadCells();
		var $rowCol = this.$gridBody.find(this.colgroupTagName);
		if($rowCol.length == 0){
			$rowCol = this.$gridHead.find(this.headColgroupTagName).clone();
			this.$gridBody.find(this.bodyTagName).prepend($rowCol);
		}
		$rowCol = $rowCol.find("> "+this.colattTagName);
		var $rowTd = this.$dataRow.find(this.colTagName);
		var rowColnameList;
		
		if(this.colNameIndex){
			rowColnameList = this.colNameIndex.split(",");
		}else{
			rowColnameList = new Array();
			for(var i=0;i<$rowTd.length;i++){
				rowColnameList.push($rowTd.eq(i).attr(configData.GRID_COL_NAME));
			}
		}
		
		if(this.$dataRow.length > 1){
			if($headCol.length != this.headCells.length){
				commonUtil.msg("Head "+this.headColattTagName+" 개수와 Head "+this.headColTagName+" 개수가 맞지 않습니다.\n"+this.id+" - Head "+this.headColattTagName+" : "+$headCol.length+" , Head "+this.headColTagName+" : "+this.headCells.length);
			}
			
			//if($rowCol.length != $rowTd.length){
			if(this.$dataRow.length == 1 && $rowCol.length != rowColnameList.length){
				commonUtil.msg("Row "+this.colattTagName+" 개수와 Row "+this.colTagName+" 개수가 맞지 않습니다.\n"+this.id+" - Row "+this.colattTagName+" : "+$rowCol.length+" , Row "+this.colTagName+" : "+$rowTd.length);
			}
		}
		
		this.defaultLayOutData = "";
		var colName;
		var colText;
		var widthNum;
		var thWidthNum;
		for(var i=0;i<this.headCells.length;i++){
			//colName = $rowTd.eq(i).attr(configData.GRID_COL_NAME);
			colName = rowColnameList[i];
			colText = this.headCells[i].text();
			if(this.sortableColMap && this.sortableColMap.containsKey(colName)){
				this.headCells[i].addClass(configData.GRID_COL_SORTABLE_CLASS);
			}
			if(colName){				
				this.headCells[i].attr(configData.GRID_COL_NAME, colName);
				this.headCells[i].attr(configData.GRID_COL_VALUE, colText);
				
				$headCol.eq(i).attr(configData.GRID_COL_NAME, colName);
				$rowCol.eq(i).attr(configData.GRID_COL_NAME, colName);

				this.cols.push(colName);
				
				this.colTextMap.put(colName, colText);
			}
			
			if(!this.checkSysColType(colName)){				
				if(!colText){
					alert("선언된 컬럼명 "+colName+" 라벨이 적용되지 않았습니다.");
				}
				var widthNum = $headCol.eq(i).attr("width");
				if(isNaN(widthNum)){
					widthNum = "100";
				}
				this.defaultLayOutData += colName+configData.DATA_COL_SEPARATOR
										+widthNum+configData.DATA_COL_SEPARATOR
										+this.headCells[i].attr(configData.GRID_COL_VALUE)+configData.DATA_ROW_SEPARATOR;
				
				this.setHeadTdHtml(this.headCells[i]);
			}
			if(this.layoutColsMap.containsKey(colName)){
				alert("선언된 컬럼명 "+colName+" 중복입니다.");
			}
			
			var layoutColList = new Array();
			layoutColList.push($headCol.eq(i));
			layoutColList.push(this.headCells[i]);
			layoutColList.push($rowCol.eq(i));
			layoutColList.push($rowTd.eq(i));
			this.layoutColsMap.put(colName, layoutColList);
			
			this.viewCols.push(colName);
			this.viewColMap.put(colName, true);
			
			if(colName == configData.GRID_COL_TYPE_ROWNUM || colName == configData.GRID_COL_TYPE_ROWCHECK){
				this.sysCols.push(colName);
			}
		}
		this.resetEditCols();
		
		//if(this.layoutType){
		if(this.headColDragType && this.draggInitType){
			//this.setHeadColDrag(this.$gridHead.find("."+theme.GRID_LAYOUT_HEAD_COL_LEFT_CLASS));
			this.setHeadColDrag(this.$gridHead.find("."+theme.GRID_LAYOUT_HEAD_COL_RIGHT_CLASS));
		}
		
		this.defaultLayOutData = this.defaultLayOutData.substring(0, this.defaultLayOutData.length-1);
		
		this.visibleLayOutData = this.defaultLayOutData;
		
		this.invisibleLayOutData = "";
		
		this.setGridColClass();
		
		var $colObj = $rowCol.filter("["+configData.GRID_COL_NAME+"="+configData.GRID_COL_TYPE_ROWNUM+"]");
		$colObj.addClass(configData.GRID_COL_TYPE_OBJECT_CLASS);
		$colObj = $rowCol.filter("["+configData.GRID_COL_NAME+"="+configData.GRID_COL_TYPE_ROWCHECK+"]");
		$colObj.addClass(configData.GRID_COL_TYPE_OBJECT_CLASS);
		
		//if(this.sortType){
			this.$gridHead.find(this.headTagName+" > "+this.headRowTagName).dblclick(function(event){
				var $obj = jQuery(event.target);
				if($obj.hasClass(theme.GRID_LAYOUT_HEAD_COL_RIGHT_CLASS)){
					return;
				}
				
				var checkAtt = $obj.find(":checkbox");
				if(checkAtt.length){
					return;
				}
				
				checkAtt = $obj.attr("type");
				if(checkAtt == "checkbox"){
					var $colObj = $obj.parents("["+configData.GRID_BTN_CHECK_ATT+"]");
					if($colObj){
						checkAtt = $colObj.attr(configData.GRID_BTN_CHECK_ATT);
						var checkType;
						if($obj.prop("checked")){
							checkType = true;
							$colObj.attr(configData.GRID_COL_VALUE, site.defaultCheckValue);
						}else{
							checkType = false;
							$colObj.attr(configData.GRID_COL_VALUE, site.emptyValue);
						}
						if(checkAtt == "true"){						
							gridBox.checkAll(checkType);
						}else{
							gridBox.dataCheckAll(checkAtt, checkType);
						}
					}
					
					return;
				}
				
				var colName = $obj.attr(configData.GRID_COL_NAME);

				if(colName == configData.GRID_COL_TYPE_ROWNUM){
					gridBox.setAutoColSizeAll();
				}
				if(!gridBox.sortType){
					return;
				}
				if(gridBox.viewDataList.length == 0){
					return;
				}
				if(colName){
					//gridBox.sortBtnView($obj, colName);
					
					/*
					gridBox.resetColFix();
					
					if(gridBox.subTotalCols && gridBox.totalView){
						gridBox.viewTotal(false);
					}
					
					if(!gridBox.multisort && gridBox.sortColList.length > 0 && gridBox.sortColList[0] != colName){						
						gridBox.sortReset();
					}
					*/
					gridBox.resetTool("sort");
					
					if(gridBox.sortableColMap && !gridBox.sortableColMap.containsKey(colName)){
						return;
					}
					
					var sortAtt = $obj.attr(configData.GRID_COL_SORT_ATT);
					var ascType = true;
					var tmpTxt = $obj.text();
					if(!sortAtt){
						sortAtt = configData.GRID_COL_SORT_DESC;
					}else if(sortAtt == configData.GRID_COL_SORT_ASC){
						tmpTxt = tmpTxt.substring(0, tmpTxt.indexOf("▲"));
					}else{
						tmpTxt = tmpTxt.substring(0, tmpTxt.indexOf("▼"));
					}
					
					if(sortAtt == configData.GRID_COL_SORT_ASC){
						ascType = false;
					}else{
						ascType = true;
					}
					
					var sortResult = gridBox.appendSort(colName, ascType, true);
					
					if(sortResult){						
						if(sortAtt == configData.GRID_COL_SORT_ASC){
							tmpTxt += "▼"+sortResult;
							$obj.attr(configData.GRID_COL_SORT_ATT, configData.GRID_COL_SORT_DESC);
						}else{
							tmpTxt += "▲"+sortResult;
							$obj.attr(configData.GRID_COL_SORT_ATT, configData.GRID_COL_SORT_ASC);
						}
						$obj.text(tmpTxt);
						
						//event fn
						if(commonUtil.checkFn("gridListEventDataSortViewEnd")){
							gridListEventDataSortViewEnd(gridBox.id);
						}
					}
				}		
			}).click(function(event){
				var $obj = jQuery(event.target);
				if($obj.hasClass(theme.GRID_LAYOUT_HEAD_COL_RIGHT_CLASS)){
					return;
				}
				
				var checkAtt = $obj.find(":checkbox");
				if(checkAtt.length){
					return;
				}
				
				checkAtt = $obj.attr("type");
				if(checkAtt == "checkbox"){
					var $colObj = $obj.parents("["+configData.GRID_BTN_CHECK_ATT+"]");
					if($colObj){
						checkAtt = $colObj.attr(configData.GRID_BTN_CHECK_ATT);
						var checkType;
						if($obj.prop("checked")){
							checkType = true;
							$colObj.attr(configData.GRID_COL_VALUE, site.defaultCheckValue);
						}else{
							checkType = false;
							$colObj.attr(configData.GRID_COL_VALUE, site.emptyValue);
						}
						if(checkAtt == "true"){						
							gridBox.checkAll(checkType);
						}else{
							gridBox.dataCheckAll(checkAtt, checkType);
						}
					}
					
					return;
				}
			});
		//}	
	},
	setHeadTdHtml : function($thObj) {
		var colName = $thObj.attr(configData.GRID_COL_NAME);
		var colText = $thObj.attr(configData.GRID_COL_VALUE);
		if(this.headColDragType){
			var checkType = false;
			if($thObj.attr(configData.GRID_BTN_CHECK_ATT)){
				var $checkCol = $thObj;
				var $check = this.createCheckObj();
				//$check.attr("value", colText);
				if(colText == site.defaultCheckValue){
					checkType = true;
					$check.attr("checked", "checked");
				}
				colText = $thObj.attr(configData.LABEL_ATT) + $check.wrapAll("<div/>").parent().html();
			}
			//var tmpTable = jQuery("<table class='thInTable' style='width:100%;' title=\""+$thObj.attr(configData.GRID_COL_VALUE)+"\"><tr><td style='width:10px;'></td><td "+configData.GRID_COL_NAME+"='"+colName+"' >"+colText+"</td><td style='width:3px;' class='"+theme.GRID_LAYOUT_HEAD_COL_RIGHT_CLASS+"'></td></tr></table>");
			var tmpTable = theme.gridHeadColObj($thObj, colName, colText);
			if($thObj.attr(configData.GRID_BTN_CHECK_ATT)){
				tmpTable.find("."+theme.GRID_LAYOUT_HEAD_COL_RIGHT_CLASS).removeClass(theme.GRID_LAYOUT_HEAD_COL_RIGHT_CLASS);
			}else{
				tmpTable.find("."+theme.GRID_LAYOUT_HEAD_COL_RIGHT_CLASS).attr(theme.GRID_COL_NAME, colName);
			}

			$thObj.text("");
			$thObj.html("");
			$thObj.append(tmpTable);
		}
	},
	setHeadText : function(colName, colText) {
		this.colTextMap.put(colName, colText);
		var list = this.defaultLayOutData.split(configData.DATA_ROW_SEPARATOR);
		var cols;
		for(var i=0;i<list.length;i++){
			cols = list[i].split(configData.DATA_COL_SEPARATOR);
			if(cols[0] == colName){
				cols[2] = colText;
				list[i] = cols.join(configData.DATA_COL_SEPARATOR);
				this.defaultLayOutData = list.join(configData.DATA_ROW_SEPARATOR);
				break;
			}
		}
		
		list = this.visibleLayOutData.split(configData.DATA_ROW_SEPARATOR);
		for(var i=0;i<list.length;i++){
			cols = list[i].split(configData.DATA_COL_SEPARATOR);
			if(cols[0] == colName){
				cols[2] = colText;
				list[i] = cols.join(configData.DATA_COL_SEPARATOR);
				this.visibleLayOutData = list.join(configData.DATA_ROW_SEPARATOR);
				break;
			}
		}
		
		list = this.invisibleLayOutData.split(configData.DATA_ROW_SEPARATOR);
		for(var i=0;i<list.length;i++){
			cols = list[i].split(configData.DATA_COL_SEPARATOR);
			if(cols[0] == colName){
				cols[2] = colText;
				list[i] = cols.join(configData.DATA_COL_SEPARATOR);
				this.invisibleLayOutData = list.join(configData.DATA_ROW_SEPARATOR);
				break;
			}
		}
		
		theme.gridHeadColText(this.$gridHead);
		//this.$gridHead.find(".thInTable td["+configData.GRID_COL_NAME+"="+colName+"]:eq(0)").text(colText);
	},
	setGridColClass : function() {
		return;
		var $rowCol = this.$gridBody.find(this.colgroupTagName+" > "+this.colattTagName);
		for(var i=0;i<this.viewCols.length;i++){
			var colName = this.viewCols[i];
			var $colObj = $rowCol.filter("["+configData.GRID_COL_NAME+"="+colName+"]");
			var tmpAtt = this.colTypeMap.get(colName);
			if(tmpAtt){
				var attList = tmpAtt.split(",");
				if(attList[0] == configData.GRID_COL_TYPE_ROWNUM){
					$colObj.addClass(configData.GRID_ROWNUM_CLASS);
					$colObj.addClass(configData.GRID_COL_TYPE_OBJECT_CLASS);
				}else if(attList[0] == configData.GRID_COL_TYPE_TEXT){
					if(attList[2]){
						if(attList[2] == "center"){
							$colObj.addClass(configData.GRID_COL_TYPE_TEXT_CENTER_CLASS);
						}else if(attList[2] == "right"){
							$colObj.addClass(configData.GRID_COL_TYPE_TEXT_RIGHT_CLASS);
						}						
					}else{
						$colObj.addClass(configData.GRID_COL_TYPE_TEXT_CLASS);
					}	
				}else if(attList[0] == configData.GRID_COL_TYPE_INPUT){
					if(this.pkcolMap.containsKey(attList[1])){
						$colObj.addClass(configData.GRID_COL_TYPE_TEXT_CLASS);
					}else{
						$colObj.addClass(configData.GRID_COL_TYPE_INPUT_TEXT_CLASS);
						$colObj.addClass(configData.GRID_EDIT_BACK_CLASS);
					}		
					if(this.colFormatMap.containsKey(attList[1])){
						var formatList = this.colFormatMap.get(attList[1]);
						if(formatList[0] == configData.INPUT_FORMAT_NUMBER){
							$colObj.addClass(configData.GRID_COL_TYPE_INPUT_NUMBER_CLASS);
						}
					}
				}else if(attList[0] == configData.GRID_COL_TYPE_ADD){
					$colObj.addClass(configData.GRID_COL_TYPE_TEXT_CLASS);	
					if(this.colFormatMap.containsKey(attList[1])){
						var formatList = this.colFormatMap.get(attList[1]);
						if(formatList[0] == configData.INPUT_FORMAT_NUMBER){
							$colObj.addClass(configData.GRID_COL_TYPE_INPUT_NUMBER_CLASS);
						}
					}
				}else if(attList[0] == configData.GRID_COL_TYPE_ROWCHECK){
					$colObj.addClass(configData.GRID_COL_TYPE_OBJECT_CLASS);
				}else if(attList[0] == configData.GRID_COL_TYPE_CHECKBOX){
					$colObj.addClass(configData.GRID_COL_TYPE_OBJECT_CLASS);
				}
				
				if(this.readOnlyType || (this.readOnlyColMap && this.readOnlyColMap.containsKey(colName))){
					$colObj.addClass(configData.GRID_COL_TYPE_DISABLE_CLASS);
					$colObj.removeClass(configData.GRID_EDIT_BACK_CLASS);
				}
			}
		}
	},
	setGridReadonlyClass : function(reviewEvent) {
		var $rowList = this.$box.find("["+configData.GRID_ROW_NUM+"]");
		var $row;
		var rowNum;
		for(var i=0;i<$rowList.length;i++){
			$row = $rowList.eq(i);
			rowNum = parseInt($row.attr(configData.GRID_ROW_NUM));
			
			if(reviewEvent){
				$row.find("."+configData.GRID_COL_TYPE_DISABLE_CLASS).addClass(configData.GRID_EDIT_BACK_CLASS).removeClass(configData.GRID_COL_TYPE_DISABLE_CLASS);
				$row.find("select,input").removeAttr("disabled");
				continue;
			}
			
			if(this.readOnlyType){
				$row.find("."+configData.GRID_EDIT_BACK_CLASS).addClass(configData.GRID_COL_TYPE_DISABLE_CLASS).removeClass(configData.GRID_EDIT_BACK_CLASS);
				$row.find("select,input").attr("disabled", "disabled");
			}else if(this.readOnlyRowMap){
				if(this.readOnlyRowMap.containsKey(rowNum)){
					if(this.readOnlyRowMap.get(rowNum)){
						$row.find("."+configData.GRID_EDIT_BACK_CLASS).addClass(configData.GRID_COL_TYPE_DISABLE_CLASS).removeClass(configData.GRID_EDIT_BACK_CLASS);
						$row.find("select,input").attr("disabled", "disabled");
					}else if(reviewEvent){
						$row.find("."+configData.GRID_COL_TYPE_DISABLE_CLASS).addClass(configData.GRID_EDIT_BACK_CLASS).removeClass(configData.GRID_COL_TYPE_DISABLE_CLASS);
						$row.find("select,input").removeAttr("disabled");
					}	
				}
			}else if(this.readOnlyColMap){
				for(var prop in this.readOnlyColMap.map){
					if(this.viewColMap.containsKey(prop) || this.gridMobileType){
						if(this.readOnlyColMap.get(prop)){
							$row.find("["+configData.GRID_COL_NAME+"="+prop+"]."+configData.GRID_EDIT_BACK_CLASS).addClass(configData.GRID_COL_TYPE_DISABLE_CLASS).removeClass(configData.GRID_EDIT_BACK_CLASS);
							$row.find("["+configData.GRID_COL_NAME+"="+prop+"]").find("select,input").attr("disabled", "disabled");
						}else{
							$row.find("["+configData.GRID_COL_NAME+"="+prop+"]."+configData.GRID_COL_TYPE_DISABLE_CLASS).addClass(configData.GRID_EDIT_BACK_CLASS).removeClass(configData.GRID_COL_TYPE_DISABLE_CLASS);
							$row.find("["+configData.GRID_COL_NAME+"="+prop+"]").find("select,input").removeAttr("disabled");
						}	
					}				
				}
			}else if(this.readOnlyCellMap){
				if(this.readOnlyCellMap.containsKey(rowNum)){
					var colMap = this.readOnlyCellMap.get(rowNum);
					for(var colName in colMap.map){
						if(this.viewColMap.containsKey(colName) || this.gridMobileType){
							if(colMap.get(colName)){
								$row.find("["+configData.GRID_COL_NAME+"="+colName+"]").addClass(configData.GRID_COL_TYPE_DISABLE_CLASS).removeClass(configData.GRID_EDIT_BACK_CLASS);
								$row.find("["+configData.GRID_COL_NAME+"="+colName+"]").find("select,input").attr("disabled", "disabled");
							}else{
								$row.find("["+configData.GRID_COL_NAME+"="+colName+"]").addClass(configData.GRID_EDIT_BACK_CLASS).removeClass(configData.GRID_COL_TYPE_DISABLE_CLASS);
								$row.find("["+configData.GRID_COL_NAME+"="+colName+"]").find("select,input").removeAttr("disabled");
							}	
						}						
					}
				}
			}
		}
		
	},
	setGridReadonlyClassOld : function(reviewEvent) {
		if(this.readOnlyType){
			this.$box.find("."+configData.GRID_EDIT_BACK_CLASS).addClass(configData.GRID_COL_TYPE_DISABLE_CLASS).removeClass(configData.GRID_EDIT_BACK_CLASS);
			this.$box.find("select,input").attr("disabled", "disabled");
			//this.$box.find("["+configData.GRID_COL_TYPE+"="+configData.GRID_COL_TYPE_INPUT+"]").addClass(configData.GRID_COL_TYPE_DISABLE_CLASS);
		}else if(reviewEvent){
			this.$box.find("."+configData.GRID_COL_TYPE_DISABLE_CLASS).addClass(configData.GRID_EDIT_BACK_CLASS).removeClass(configData.GRID_COL_TYPE_DISABLE_CLASS);
			this.$box.find("select,input").removeAttr("disabled");
			//this.$box.find("["+configData.GRID_COL_TYPE+"="+configData.GRID_COL_TYPE_INPUT+"]").removeClass(configData.GRID_COL_TYPE_DISABLE_CLASS);
		}
		if(this.readOnlyColMap){
			for(var prop in this.readOnlyColMap.map){
				if(this.viewColMap.containsKey(prop) || this.gridMobileType){
					if(this.readOnlyColMap.get(prop)){
						this.$box.find(this.colTagName).find("["+configData.GRID_COL_NAME+"="+prop+"]."+configData.GRID_EDIT_BACK_CLASS).addClass(configData.GRID_COL_TYPE_DISABLE_CLASS).removeClass(configData.GRID_EDIT_BACK_CLASS);
						this.$box.find(this.colTagName).find("["+configData.GRID_COL_NAME+"="+prop+"]").find("select,input").attr("disabled", "disabled");
					}else{
						this.$box.find(this.colTagName).find("["+configData.GRID_COL_NAME+"="+prop+"]."+configData.GRID_COL_TYPE_DISABLE_CLASS).addClass(configData.GRID_EDIT_BACK_CLASS).removeClass(configData.GRID_COL_TYPE_DISABLE_CLASS);
						this.$box.find(this.colTagName).find("["+configData.GRID_COL_NAME+"="+prop+"]").find("select,input").removeAttr("disabled");
					}	
				}				
			}
		}
		
		var tmpRowNum;
		
		if(this.readOnlyRowMap){
			for(var i=this.startRowNum;i<=this.endRowNum;i++){
				tmpRowNum = this.getRowNum(i);
				if(this.readOnlyRowMap.containsKey(tmpRowNum)){
					var $row = this.$box.find("["+configData.GRID_ROW_NUM+"="+tmpRowNum+"]");
					if(this.readOnlyRowMap.get(tmpRowNum)){
						$row.find("."+configData.GRID_EDIT_BACK_CLASS).addClass(configData.GRID_COL_TYPE_DISABLE_CLASS).removeClass(configData.GRID_EDIT_BACK_CLASS);
						$row.find("select,input").attr("disabled", "disabled");
						//$row.find("["+configData.GRID_COL_TYPE+"="+configData.GRID_COL_TYPE_INPUT+"]").addClass(configData.GRID_COL_TYPE_DISABLE_CLASS);
					}else{
						$row.find("."+configData.GRID_COL_TYPE_DISABLE_CLASS).addClass(configData.GRID_EDIT_BACK_CLASS).removeClass(configData.GRID_COL_TYPE_DISABLE_CLASS);
						$row.find("select,input").removeAttr("disabled");
						//$row.find("["+configData.GRID_COL_TYPE+"="+configData.GRID_COL_TYPE_INPUT+"]").removeClass(configData.GRID_COL_TYPE_DISABLE_CLASS);
					}	
				}
			}
			/*
			for(var prop in this.readOnlyRowMap.map){
				var $row = this.$box.find("["+configData.GRID_ROW_NUM+"="+prop+"]");
				if(this.readOnlyRowMap.get(prop)){
					$row.find("select,input").attr("disabled", "disabled").parent().addClass(configData.GRID_COL_TYPE_DISABLE_CLASS);
					$row.find("["+configData.GRID_COL_TYPE+"="+configData.GRID_COL_TYPE_INPUT+"]").addClass(configData.GRID_COL_TYPE_DISABLE_CLASS);
				}else{
					$row.find("select,input").removeAttr("disabled").parent().removeClass(configData.GRID_COL_TYPE_DISABLE_CLASS);
					$row.find("["+configData.GRID_COL_TYPE+"="+configData.GRID_COL_TYPE_INPUT+"]").removeClass(configData.GRID_COL_TYPE_DISABLE_CLASS);
				}					
			}
			*/
		}
		
		if(this.readOnlyCellMap){
			for(var i=this.startRowNum;i<=this.endRowNum;i++){
				tmpRowNum = this.getRowNum(i);
				if(this.readOnlyCellMap.containsKey(tmpRowNum)){
					var $row = this.$box.find("["+configData.GRID_ROW_NUM+"="+tmpRowNum+"]");
					var colMap = this.readOnlyCellMap.get(tmpRowNum);
					for(var colName in colMap.map){
						if(this.viewColMap.containsKey(colName) || this.gridMobileType){
							if(colMap.get(colName)){
								$row.find("["+configData.GRID_COL_NAME+"="+colName+"]").addClass(configData.GRID_COL_TYPE_DISABLE_CLASS).removeClass(configData.GRID_EDIT_BACK_CLASS);
								$row.find("["+configData.GRID_COL_NAME+"="+colName+"]").find("select,input").attr("disabled", "disabled");
							}else{
								$row.find("["+configData.GRID_COL_NAME+"="+colName+"]").addClass(configData.GRID_EDIT_BACK_CLASS).removeClass(configData.GRID_COL_TYPE_DISABLE_CLASS);
								$row.find("["+configData.GRID_COL_NAME+"="+colName+"]").find("select,input").removeAttr("disabled");
							}	
						}						
					}
					
				}
			}
			/*
			for(var prop in this.readOnlyCellMap.map){
				var $row = this.$box.find("["+configData.GRID_ROW_NUM+"="+prop+"]");
				var colMap = this.readOnlyCellMap.get(prop);
				for(var colName in colMap.map){					
					if(colMap.get(colName)){
						$row.find("["+configData.GRID_COL_NAME+"="+colName+"]").find("select,input").attr("disabled", "disabled").parent().addClass(configData.GRID_COL_TYPE_DISABLE_CLASS);
					}else{
						$row.find("["+configData.GRID_COL_NAME+"="+colName+"]").find("select,input").removeAttr("disabled").parent().removeClass(configData.GRID_COL_TYPE_DISABLE_CLASS);
					}	
				}								
			}
			*/
		}
	},
	resetVisibleLayOutData : function(colName, tmpWidth) {
		var vList = this.visibleLayOutData.split(configData.DATA_ROW_SEPARATOR);
		this.visibleLayOutData = "";
		var colList;
		for(var i=0;i<vList.length;i++){
			colList = vList[i].split(configData.DATA_COL_SEPARATOR);
			if(colList[0] == colName){
				colList[1] = tmpWidth;
			}
			if(isNaN(colList[1])){
				colList[1] = "100";
			}
			this.visibleLayOutData += colList[0]+configData.DATA_COL_SEPARATOR
			+colList[1]+configData.DATA_COL_SEPARATOR
			+this.colTextMap.get(colList[0])+configData.DATA_ROW_SEPARATOR;
		}
		this.visibleLayOutData = this.visibleLayOutData.substring(0, this.visibleLayOutData.length-1);
	},
	getLayOutData : function() {
		var vList = this.visibleLayOutData.split(configData.DATA_ROW_SEPARATOR);
		var tmpData = "";
		var colList;
		for(var i=0;i<vList.length;i++){
			colList = vList[i].split(configData.DATA_COL_SEPARATOR);
			if(isNaN(colList[1])){
				colList[1] = "100";
			}
			tmpData += colList[0]+configData.DATA_COL_SEPARATOR
			+colList[1];
			if(this.sortSaveType && this.sortColMap.containsKey(colList[0])){
				for(var j=0;j<this.sortColList.length;j++){
					if(this.sortColList[j] == colList[0]){
						tmpData += configData.DATA_COL_SEPARATOR + j + configData.DATA_COL_SEPARATOR + this.sortTypeList[j];
						break;
					}
				}
			}
			tmpData += configData.DATA_ROW_SEPARATOR;
		}
		tmpData = tmpData.substring(0, tmpData.length-1);
		return tmpData;
	},
	startHeadColWidth : function($dragObj, ui) {		
		var colName = $dragObj.attr(configData.GRID_COL_NAME);
		var $thObj = this.$gridHead.find(this.headColTagName+"["+configData.GRID_COL_NAME+"="+colName+"]");
		if($dragObj.attr(theme.GRID_LAYOUT_HEAD_COL_LEFT_CLASS)){
			
		}else{
			var $headCol = this.$gridHead.find(this.headColgroupTagName).find(this.headColattTagName+"["+configData.GRID_COL_NAME+"="+colName+"]");
			$thObj.attr(configData.GRID_COL_WIDTH, $headCol.attr("width"));
		}
	},
	changeHeadColWidth : function($dragObj, ui) {		
		var colName = $dragObj.attr(configData.GRID_COL_NAME);
		var $thObj = this.$gridHead.find(this.headColTagName+"["+configData.GRID_COL_NAME+"="+colName+"]");
		if($dragObj.attr(theme.GRID_LAYOUT_HEAD_COL_LEFT_CLASS)){
			
		}else{
			var $headCol = this.$gridHead.find(this.headColgroupTagName).find(this.headColattTagName+"["+configData.GRID_COL_NAME+"="+colName+"]");
			var $bodyCol = this.$gridBody.find(this.headColgroupTagName).find(this.headColattTagName+"["+configData.GRID_COL_NAME+"="+colName+"]");
			
			var thWidth = parseInt($thObj.attr(configData.GRID_COL_WIDTH));
			var minLeft = theme.GRID_COL_MINWIDTH - thWidth;
			ui.position.left = Math.max( minLeft, ui.position.left );
			var uiLeft = ui.position.left;
			//var colWidth = thWidth+uiLeft;
			var colWidth = theme.gridHeadColWidth(thWidth, uiLeft);
			
			$headCol.attr("width", colWidth);
			$bodyCol.attr("width", colWidth);
		}
	},
	setHeadColWidth : function($dragObj, ui) {
		var colName = $dragObj.attr(configData.GRID_COL_NAME);
		this.setHeadColWidthName(colName);
	},
	setHeadColWidthName : function(colName) {
		var $headCol = this.$gridHead.find(this.headColgroupTagName).find(this.headColattTagName+"["+configData.GRID_COL_NAME+"="+colName+"]");
		var tmpWidth = $headCol.attr("width");
		this.resetVisibleLayOutData(colName, tmpWidth);

		//var $headTd = this.$gridHead.find(this.headColTagName+"["+configData.GRID_COL_NAME+"="+colName+"]");
		var $headTd;
		for(var i=0;i<this.headCells.length;i++){
			if(this.headCells[i].attr(configData.GRID_COL_NAME) == colName){
				$headTd = this.headCells[i];
				break;
			}
		}
		var tmpHtml = $headTd.find("["+configData.GRID_COL_NAME+"="+colName+"]").eq(0).html();
		var $sortAttObj = $headTd.find("["+configData.GRID_COL_SORT_ATT+"]");
		
		this.setHeadTdHtml($headTd);
		$headTd.find("["+configData.GRID_COL_NAME+"="+colName+"]").eq(0).html(tmpHtml);
		if($sortAttObj.length > 0){
			var sortText = $sortAttObj.eq(0).attr(configData.GRID_COL_SORT_ATT);
			$headTd.find("["+configData.GRID_COL_NAME+"="+colName+"]").eq(0).attr(configData.GRID_COL_SORT_ATT, sortText );
		}
		if(this.draggInitType){
			this.setHeadColDrag($headTd.find("."+theme.GRID_LAYOUT_HEAD_COL_RIGHT_CLASS));
		}else{
			if(this.dataLoadStart){
				this.setHeadColDrag($headTd.find("."+theme.GRID_LAYOUT_HEAD_COL_RIGHT_CLASS));
			}
		}
	},
	startHeadColDrag : function() {
		if(!this.draggInitType){
			if(!this.dataLoadStart){
				this.dataLoadStart = true;
				this.setHeadColDrag(this.$gridHead.find("."+theme.GRID_LAYOUT_HEAD_COL_RIGHT_CLASS));
			}
		}
	},
	setHeadColDrag : function($dragObj) {
		var gridBox = this;
		$dragObj.draggable({ 
			axis: "x",
			//revert: true,
			start: function(event, ui) {
				var $obj = jQuery(event.target);
				//$obj.text(ui.position.left);
				gridBox.startHeadColWidth($obj, ui);
			},
			drag: function(event, ui) {
				var $obj = jQuery(event.target);
				if ((Browser.ie6) || (Browser.ie7) || (Browser.ie8)) {

				}else{
					gridBox.changeHeadColWidth($obj, ui);
				}				
			},
			stop: function(event, ui) {
				var $obj = jQuery(event.target);
				if ((Browser.ie6) || (Browser.ie7) || (Browser.ie8)) {
					gridBox.changeHeadColWidth($obj, ui);
				}				
				gridBox.setHeadColWidth($obj);
			}
		});
		
		$dragObj.dblclick(function(event){
			var $obj = $(event.target);
			gridBox.setAutoColSize($obj);
		});
	},
	setAutoColSizeAll : function() {
		for(var i=0;i<this.viewCols.length;i++){
			//commonUtil.consoleMsg(this.viewCols[i]);
			var colName = this.viewCols[i];
			if(!colName || colName == configData.GRID_COL_TYPE_ROWNUM || colName == configData.GRID_COL_TYPE_ROWCHECK){
				continue;
			}
			this.setAutoColSizeName(colName);
		}
			/*
		if(!colName || colName == configData.GRID_COL_TYPE_ROWCHECK){
			return;
		}
		if(colName == configData.GRID_COL_TYPE_ROWNUM){*/
	},
	setAutoColSize : function($obj) {
		var colName = $obj.attr(configData.GRID_COL_NAME);
		this.setAutoColSizeName(colName);
	},
	setAutoColSizeName : function(colName) {
		if(this.viewDataList.length == 0){
			return;
		}
		if(!colName || colName == configData.GRID_COL_TYPE_ROWNUM || colName == configData.GRID_COL_TYPE_ROWCHECK){
			return;
		}
		if(colName){
			var tmpMaxTxt = "";
			if(this.selectCols.containsKey(colName)){
				var $tmpSelect = this.selectCols.get(colName);
				var $options = $tmpSelect.find("option");
				var tmpTxt;
				for(var i=0;i<$options.length;i++){
					tmpTxt = $options.eq(i).text();
					if(tmpTxt.length > tmpMaxTxt.length){
						tmpMaxTxt = tmpTxt;
					}
				}
			}else{
				tmpMaxTxt = this.maxColValue(colName);
				if(this.colFormatMap.containsKey(colName)){
					var formatList = this.colFormatMap.get(colName);
					tmpMaxTxt = uiList.getDataFormat(formatList, tmpMaxTxt, true);
				}
			}				
			//alert(tmpMaxTxt);
			
			var $headCol = this.$gridHead.find(this.headColgroupTagName).find(this.headColattTagName+"["+configData.GRID_COL_NAME+"="+colName+"]");
			var $bodyCol = this.$gridBody.find(this.headColgroupTagName).find(this.headColattTagName+"["+configData.GRID_COL_NAME+"="+colName+"]");
			
			var tmpHeadText = this.colTextMap.get(colName);
			if(tmpHeadText.length >= tmpMaxTxt.length){
				tmpMaxTxt = tmpHeadText+" ";
			}
			
			var colWidth = tmpMaxTxt.length*theme.fontWidth;
			if(colWidth < 50){
				colWidth = 50;
			}
			
			$headCol.attr("width", colWidth);
			$bodyCol.attr("width", colWidth);
			
			this.setHeadColWidthName(colName);
		}
	},
	setLayout : function(reloadType) {
		var vList = this.visibleLayOutData.split(configData.DATA_ROW_SEPARATOR);
		var colList;
		var lList;
		
		if(this.headRowCount == 1){
			var hColList = new Array();
			var hTdList = new Array();
			var bColList = new Array();
			var bTdList = new Array();
			
			var tmpTotal = false;
			if(this.totalView){
				this.viewTotal(false);
				tmpTotal = true;
			}
			
			if(this.layoutColsMap.containsKey(configData.GRID_COL_TYPE_ROWNUM)){
				lList = this.layoutColsMap.get(configData.GRID_COL_TYPE_ROWNUM);
				hColList.push(lList[0]);
				hTdList.push(lList[1]);
				bColList.push(lList[2]);
				bTdList.push(lList[3]);	
			}
			
			if(this.layoutColsMap.containsKey(configData.GRID_COL_TYPE_ROWCHECK)){
				lList = this.layoutColsMap.get(configData.GRID_COL_TYPE_ROWCHECK);
				hColList.push(lList[0]);
				hTdList.push(lList[1]);
				bColList.push(lList[2]);
				bTdList.push(lList[3]);	
			}
			
			if(this.layoutColsMap.containsKey(configData.GRID_COL_TYPE_TREE)){
				lList = this.layoutColsMap.get(configData.GRID_COL_TYPE_TREE);
				hColList.push(lList[0]);
				hTdList.push(lList[1]);
				bColList.push(lList[2]);
				bTdList.push(lList[3]);	
			}
			
			this.viewCols = new Array();
			this.viewColMap = new DataMap();
			for(var i=0;i<this.sysCols.length;i++){
				this.viewCols.push(this.sysCols[i]);
				this.viewColMap.put(this.sysCols[i], true);
			}
			for(var i=0;i<vList.length;i++){
				colList = vList[i].split(configData.DATA_COL_SEPARATOR);
				if(this.layoutColsMap.containsKey(colList[0])){
					if(isNaN(colList[1])){
						colList[1] = "100";
					}
					lList = this.layoutColsMap.get(colList[0]);
					lList[0].attr("width", colList[1]);
					lList[2].attr("width", colList[1]);
					hColList.push(lList[0]);
					hTdList.push(lList[1]);
					bColList.push(lList[2]);
					bTdList.push(lList[3]);
					
					this.viewCols.push(colList[0]);
					this.viewColMap.put(colList[0], true);
				}			
			}
			this.resetEditCols();
			this.$gridHead.find(this.headColgroupTagName).find(this.headColattTagName).remove().end().append(hColList);
			this.$gridHead.find(this.headTagName+" > "+this.headRowTagName+":first").find(this.headColTagName).remove().end().append(hTdList);
			this.$gridBody.find(this.colgroupTagName).find(this.colattTagName).remove().end().append(bColList);
			
			//this.setHeadColDrag(this.$gridHead.find("."+theme.GRID_LAYOUT_HEAD_COL_LEFT_CLASS));
			if(this.draggInitType){
				this.setHeadColDrag(this.$gridHead.find("."+theme.GRID_LAYOUT_HEAD_COL_RIGHT_CLASS));
			}else{
				if(this.dataLoadStart){
					this.setHeadColDrag(this.$gridHead.find("."+theme.GRID_LAYOUT_HEAD_COL_RIGHT_CLASS));
				}
			}
			
			var $tmpDataRow = this.$dataRow.clone();
			$tmpDataRow.find(this.colTagName).remove().end().append(bTdList);
			
			var tmpHtml = $tmpDataRow.clone().wrapAll("<div/>").parent().html();
			this.rowHtml = tmpHtml;
			
			var tmpIndex;
			while((tmpIndex = tmpHtml.indexOf(configData.GRID_COL_DATA_NAME_HEAD)) != -1){
				tmpHtml = tmpHtml.substring(0,tmpIndex)+tmpHtml.substring(tmpHtml.indexOf(configData.GRID_COL_DATA_NAME_TAIL)+configData.GRID_COL_DATA_NAME_TAIL.length);
			}
			this.rowNewHtml = tmpHtml;

			if(reloadType != false){
				this.reloadView();
				
				hideLayoutSave();
			}
			
			if(tmpTotal){
				this.viewTotal(true);
			}			
			
			this.setGridColClass();
		}else{
			for(var i=0;i<vList.length;i++){
				colList = vList[i].split(configData.DATA_COL_SEPARATOR);
				if(this.layoutColsMap.containsKey(colList[0])){
					if(isNaN(colList[1])){
						colList[1] = "100";
					}
					lList = this.layoutColsMap.get(colList[0]);
					lList[0].attr("width", colList[1]);
					lList[2].attr("width", colList[1]);
				}	
			}
		}
		
		if(reloadType == false && this.sortColList.length > 0){
			var sortTxt;
			var $headColObj;
			for(var i=0;i<this.sortColList.length;i++){
				$headColObj = this.$gridHead.find(this.headTagName+" > "+this.headRowTagName+" > " + this.headColTagName+"["+configData.GRID_COL_NAME+"="+this.sortColList[i]+"]").find("["+configData.GRID_COL_NAME+"="+this.sortColList[i]+"]").eq(0);
				if(this.sortTypeList[i]){
					$headColObj.attr(configData.GRID_COL_SORT_ATT, configData.GRID_COL_SORT_ASC);
					sortTxt = $headColObj.text()+"▲"+(i+1);
				}else{
					$headColObj.attr(configData.GRID_COL_SORT_ATT, configData.GRID_COL_SORT_DESC);
					sortTxt = $headColObj.text()+"▼"+(i+1);
				}
				$headColObj.text(sortTxt);
			}			
		}
		
		if (Browser.ie){
			this.$gridBody.trigger("scroll");
		}
	},
	setLayoutData : function(json) {
		if(json && json.data){
			for(var i=0;i<json.data.length;i++){
				this.layoutDataMap.put(json.data[i]["LYOTID"], json.data[i]["LAYDAT"]);
			}
		}		
		if(this.layoutDataMap.containsKey("DEFAULT")){
			this.createLayoutData(this.layoutDataMap.get("DEFAULT"));
			this.setLayout(false);
		}
	},
	addLayoutData : function(lyotid, laydat) {
		this.layoutDataMap.put(lyotid, laydat);	
		if(lyotid == "DEFAULT"){
			this.createLayoutData(laydat);
			this.setLayout(false);
		}
	},
	createLayoutData : function(viewData) {
		var vList =this.defaultLayOutData.split(configData.DATA_ROW_SEPARATOR);
		var defaultColMap = new DataMap();
		var colList;
		for(var i=0;i<vList.length;i++){
			colList = vList[i].split(configData.DATA_COL_SEPARATOR);
			defaultColMap.put(colList[0], vList[i]);
		}
		
		vList = viewData.split(configData.DATA_ROW_SEPARATOR);
		var viewColList = new Array();
		var viewColMap = new DataMap();
		var hideColList = new Array();
		var sortColNum;
		var sortType;
		for(var i=0;i<vList.length;i++){
			colList = vList[i].split(configData.DATA_COL_SEPARATOR);			
			if(this.layoutColsMap.containsKey(colList[0])){
				var tmpLayoutRow = colList[0]+configData.DATA_COL_SEPARATOR
				+colList[1]+configData.DATA_COL_SEPARATOR
				+this.colTextMap.get(colList[0]);
				viewColList.push(tmpLayoutRow);
				viewColMap.put(colList[0], true);
			}
			if(colList[2]){
				sortColNum = parseInt(colList[2]);
				sortType = colList[3];
				if(sortType == "true"){
					sortType = true;
				}else{
					sortType = false;
				}
				this.sortColMap.put(colList[0], sortType);
				this.sortColList[sortColNum] = colList[0];
				for(var j=0;j<this.cols.length;j++){
					if(this.cols[j] == colList[0]){
						this.sortColNumList[sortColNum] = j;
						break;
					}
				}
				this.sortTypeList[sortColNum] = sortType;
			}
		}
		for(var prop in defaultColMap.map){
			if(!viewColMap.containsKey(prop)){
				hideColList.push(defaultColMap.get(prop));
			}
		}
		
		this.visibleLayOutData = viewColList.join(configData.DATA_ROW_SEPARATOR);
		this.invisibleLayOutData = hideColList.join(configData.DATA_ROW_SEPARATOR);
	},
	reloadView : function(focusType, startType){
		if(focusType != false){
			focusType = true;
		}
		
		if(startType != false){
			startType = true;
		}
		
		this.$box.find(
				"["+configData.GRID_ROW+"]").remove();
		
		if(this.scrollType){			
			var startRow = 0;
			var endRow = this.viewRowCount;
			this.setView(startRow, endRow);
			if(focusType && this.firstRowFocusType){
				this.firstRowFocus();
			}
		}else{
			this.setViewAll(focusType, startType);
		}
	},
	setBtnActive : function(btnType, activeType){
		if(this.$gridBottom){
			var $btn = this.$gridBottom.find("["+configData.GRID_BTN+"="+btnType+"]");
			if($btn){
				if(activeType){
					$btn.show();
				}else{
					$btn.hide();
				}
			}
		}
	},
	setBottom : function(){
		var gridBox = this;
		if(this.$gridBottom){
			this.$gridBottom.find("["+configData.GRID_BTN+"]").each(function(i, findElement){
				var $obj = jQuery(findElement);
				theme.setGridBtn(gridBox, $obj);
			});
			
			if(gridBox.pageCount){
				theme.setGridPgecountInfo(gridBox);
			}			
			
			this.$gridBottom.find("["+configData.GRID_INFO_AREA_ATT+"]").each(function(i, findElement){
				var $obj = jQuery(findElement);
				gridBox.infoList.push($obj);
			});
			
			this.$gridBottom.find("["+configData.GRID_CHECK_INFO_AREA_ATT+"]").each(function(i, findElement){
				var $obj = jQuery(findElement);
				gridBox.checkInfoList.push($obj);
			});
		}
	},
	setBtnView : function(btnName, viewType) {
		if(viewType == undefined){
			viewType = true;
		}
		var $btnObj = this.$gridBottom.find("["+configData.GRID_BTN+"="+btnName+"]");
		if(viewType){
			$btnObj.show();			
		}else{
			$btnObj.hide();
		}
	},
	gridExcelRequest : function(tempType) {
		if(tempType && tempType != "ALL"){
			if(this.excelTempUrl == ""){
				//event fn
				if(commonUtil.checkFn("gridExcelTempEmptyEvent")){
					gridExcelTempEmptyEvent(this.id);
				}
				return;
			}else if(this.excelTempUrl){
				var formHtml = "<form action='"+this.excelTempUrl+"' method='get'></form>";
				var $tempForm = jQuery(formHtml);
				jQuery($tempForm).hide().appendTo('body');
				$tempForm.submit();
				return;
			}
		}
		if(this.excelRequestMaxRow == 0 && site.excelRequestMaxRow > 0){
			this.excelRequestMaxRow = site.excelRequestMaxRow;
		}
		if(!tempType && this.excelRequestMaxRow){
			if(this.data.length == 0){
				commonUtil.msgBox(configData.MSG_MASTER_ROWEMPTY);
				return;
			}
			if(this.data.length > this.excelRequestMaxRow){
				commonUtil.msgBox("COMMON_EXCELREQUESTMAXROW");
				return;
			}
		}

		var param;
		//event fn
		if(commonUtil.checkFn("gridExcelDownloadEventBefore")){
			param = gridExcelDownloadEventBefore(this.id);
			if(param == false){
				return;
			}
		}else{
			if(validate.check(configData.SEARCH_AREA_ID)){
				param = inputList.setRangeParam(configData.SEARCH_AREA_ID);
			}else{
				$showPop.trigger("click");
				return;
			}			
		}
		if(!param){
			param = new DataMap();
		}
		
		var tmpFileName;
		if(param.containsKey(configData.DATA_EXCEL_REQUEST_FILE_NAME)){
			tmpFileName = param.get(configData.DATA_EXCEL_REQUEST_FILE_NAME);
		}else if(this.excelFileName){
			tmpFileName = this.excelFileName;
		}else{
			tmpFileName = configData.MENU_ID+this.id;
		}
		
		tmpFileName = tmpFileName+(this.excelDownloadCount==0?"":this.excelDownloadCount);
		
		param.put(configData.DATA_EXCEL_REQUEST_FILE_NAME, tmpFileName);
		
		var labelMap = new DataMap();
		var labelList = new Array();
		var widthList = new Array();
		var colList;
		var vList;
		var eList = this.editableColMap; // 2019.04.24 jw : ExcelUpload Form Editable Column Only Option Added
		
		if(tempType != "ALL" && this.excelRequestViewCols){
			vList = this.visibleLayOutData.split(configData.DATA_ROW_SEPARATOR);
		}else{
			vList = this.defaultLayOutData.split(configData.DATA_ROW_SEPARATOR);
		}
		
		for(var i=0;i<vList.length;i++){
			colList = vList[i].split(configData.DATA_COL_SEPARATOR);
			 // 2019.04.24 jw : Excel UploadForm Editable Column Only Option Added
			if(tempType == true && this.excelRequestEditableCols && eList && eList.size() > 0){
				if(!eList.containsKey(colList[0]) || eList.get(colList[0]) == configData.GRID_COL_TYPE_FILE){
					continue;
				}
			}
			
			labelList.push(colList[0]);
			labelMap.put(colList[0], this.colTextMap.get(colList[0]));
			widthList.push(colList[1]);
		}
		
		var formatMap = new DataMap();
		
		for(var prop in this.colFormatMap.map){
			if(this.colFormatMap.get(prop)[0] == configData.INPUT_FORMAT_NUMBER){
				formatMap.put(prop, configData.INPUT_FORMAT_NUMBER);
			}else if(this.colFormatMap.get(prop)[0] == configData.INPUT_FORMAT_DATE || this.colFormatMap.get(prop)[0] == configData.INPUT_FORMAT_CALENDER){
				formatMap.put(prop, configData.INPUT_FORMAT_DATE);
			}else if(this.colFormatMap.get(prop)[0] == configData.INPUT_FORMAT_DATE_MONTH || this.colFormatMap.get(prop)[0] == configData.INPUT_FORMAT_CALENDER_MONTH){
				formatMap.put(prop, configData.INPUT_FORMAT_DATE_MONTH); // 2019.03.07 jw : : Input Data Type Month Added
			}else if(this.colFormatMap.get(prop)[0] == configData.INPUT_FORMAT_DATETIME
					|| this.colFormatMap.get(prop)[0] == configData.INPUT_FORMAT_DATETIMESECOND
					|| this.colFormatMap.get(prop)[0] == configData.INPUT_FORMAT_TIME){
				formatMap.put(prop, this.colFormatMap.get(prop)[0]);
			}
		}
		
		param.put(configData.DATA_EXCEL_LABEL_KEY, labelMap);
		param.put(configData.DATA_EXCEL_LABEL_ORDER_KEY, labelList);
		param.put(configData.DATA_EXCEL_WIDTH_KEY, widthList);
		param.put(configData.DATA_EXCEL_FORMAT_KEY, formatMap);
		param.put(configData.DATA_EXCEL_COMBO_DATA_KEY, this.comboDataMap);
		param.put(configData.DATA_EXCEL_REQUEST_MAXROW_KEY, this.excelRequestMaxRow);
		
		if(this.excelHeadRow){
			if(this.excelDownloadCount == 0){
				for(var i=0;i<this.excelHeadRow.length;i++){
					if(this.rowNumType){
						this.excelHeadRow[i].shift();
					}
					if(this.rowCheckType){
						this.excelHeadRow[i].shift();
					}
				}
			}
			param.put(configData.DATA_EXCEL_MULTI_LABEL_KEY, this.excelHeadRow);
			/*
			var tmpStr = "";
			for(var i=0;i<this.excelHeadRow.length;i++){
				if(i != 0){
					tmpStr += configData.DATA_ROW_SEPARATOR;
				}
				tmpStr += this.excelHeadRow.join(configData.DATA_COL_SEPARATOR);
			}
			*/
		}
		
		// excel 전송을 위한 form tag를 초기화 한다.
		if(jQuery("#gridExcelForm").length){
			jQuery("#gridExcelForm").remove();
		}
		
		if(this.excelXType){
			param.put(configData.DATA_EXCEL_X_TYPE, "true");
		}else{
			param.put(configData.DATA_EXCEL_X_TYPE, "false");
		}
		
		var url;
		if(tempType == true){
			url = "/common/excel/temp.data";
			param.put(configData.DATA_EXCEL_COL_KEY_VIEW, "true");
		}else{
			if(this.excelRequestGridSelectData){
				var dataString = this.cols.join(configData.DATA_COL_SEPARATOR)+configData.DATA_ROW_SEPARATOR+this.getSelectDataString();
				param.put("dataString", dataString);
				url = "/common/excel/temp.data";
			}else if(this.excelRequestGridData){
				var dataString = this.cols.join(configData.DATA_COL_SEPARATOR)+configData.DATA_ROW_SEPARATOR+this.getDataStringAll();
				param.put("dataString", dataString);
				url = "/common/excel/temp.data";
				//param.put(configData.DATA_EXCEL_COL_KEY_VIEW, "true");
			}else{
				url = "/"+this.excelConn+"/"+this.module+"/excel/"+this.command+".data";
			}
		}
		
		if(param.containsKey("url")){
			url = param.get("url");
		}
		if(this.excelCsvType){
			param.put(configData.DATA_EXCEL_CSV_TYPE, "true");
			param.put(configData.DATA_EXCEL_LABEL_VIEW, this.excelLabelView);
		}else{
			param.put(configData.DATA_EXCEL_CSV_TYPE, "false");
		}
		
		if(this.excelTextType){
			param.put(configData.DATA_EXCEL_TEXT_KEY, "true");
			param.put(configData.DATA_EXCEL_DELIMITER_KEY, this.excelTextDelimiter);
			param.put(configData.DATA_EXCEL_LABEL_VIEW, this.excelLabelView);
		}else{
			param.put(configData.DATA_EXCEL_TEXT_KEY, "false");
		}
		
		if(this.excelLoader){
			$("#gridExcelLoading").show();
			param.put(configData.EXCEL_DOWN_TOKEN,"true");
		}
		
		var json = netUtil.sendData({
			url : "/common/excelParam/json/save.data",
			param : param
		});
		
		if(json && json.key){
			jQuery("#gridExcelForm").remove();
			if(this.excelLoader){
				var excelToken = param.get(configData.EXCEL_DOWN_TOKEN);
				excelDownInterval = setInterval(function(){
					var key = json.key;
					
					var excelDataParam = new DataMap();
					excelDataParam.put("key",key);
					
					jQuery.ajax({
						type: "post",
						url: "/common/excelParam/json/excelDownSuccess.data",
						async: true,
						data: excelDataParam.toString(),
						dataType: "json",			
						error: function(a, b, c){
							netUtil.sendData({
								url : "/common/excelParam/json/excelDownSessionRemove.data",
								param : excelDataParam
							});
							
							clearInterval(excelDownInterval);
							$("#gridExcelLoading").hide();
					    },
					    success: function (result) {
					    	if(result){
					    		if(result["result"] == "TRUE"){
					    			netUtil.sendData({
										url : "/common/excelParam/json/excelDownSessionRemove.data",
										param : excelDataParam
									});
					    			
									clearInterval(excelDownInterval);
									$("#gridExcelLoading").hide();
								}
					    	}else{
					    		netUtil.sendData({
									url : "/common/excelParam/json/excelDownSessionRemove.data",
									param : excelDataParam
								});
					    		
					    		clearInterval(excelDownInterval);
								$("#gridExcelLoading").hide();
					    	}
					    }
					});
				}, 500);
				
				var formHtml = "<form action='"+url+"' method='post' id='gridExcelForm'>"
				 			 + "<input type='text' name='"+configData.DATA_EXCEL_REQUEST_KEY+"' value=\""+json.key+"\" />"
				             + "<input type='text' name='"+configData.EXCEL_DOWN_TOKEN+"' value=\""+excelToken+"\" />"
				             + "</form>";
				jQuery(formHtml).hide().appendTo('body');
				jQuery("#gridExcelForm").submit();
			}else{
				// 비동기 전달을 위해 전달에 필요한 파라메터에 각 값들은 jsonString형태로 전송한다.
				var formHtml = "<form action='"+url+"' method='post' id='gridExcelForm'>"
							 + "<input type='text' name='"+configData.DATA_EXCEL_REQUEST_KEY+"' value=\""+json.key+"\" />"
							 + "</form>";
				jQuery(formHtml).hide().appendTo('body');
				jQuery("#gridExcelForm").submit();
			}
		}
		
		this.excelDownloadCount++;
	},
	gridExcelRequestOld : function() {
		if(this.excelRequestMaxRow){
			if(this.data.length == 0 || this.data.length > this.excelRequestMaxRow){
				commonUtil.msgBox("COMMON_EXCELREQUESTMAXROW");
				return;
			}
		}
		var param;
		//event fn
		if(commonUtil.checkFn("gridExcelDownloadEventBefore")){
			param = gridExcelDownloadEventBefore(this.id);
		}else{
			param = inputList.setRangeParam(configData.SEARCH_AREA_ID);
		}
		if(!param){
			param = new DataMap();
		}
		
		var paramStr = commonUtil.stringToMap(param);
		
		if(!param.containsKey(configData.DATA_EXCEL_REQUEST_FILE_NAME)){
			param.put(configData.DATA_EXCEL_REQUEST_FILE_NAME, this.id);
		}
		
		var labelMap = new DataMap();
		var labelList = new Array();
		
		var vList = this.visibleLayOutData.split(configData.DATA_ROW_SEPARATOR);
		var colList;
		for(var i=0;i<vList.length;i++){
			colList = vList[i].split(configData.DATA_COL_SEPARATOR);
			labelList.push(colList[0]);
			labelMap.put(colList[0], this.colTextMap.get(colList[0]));
		}
		var labelMapStr = commonUtil.stringToMap(labelMap);
		var labelListStr = commonUtil.stringToList(labelList);
		
		var formatMap = new DataMap();
		var tmpStr;
		for(var prop in this.colFormatMap.map){
			if(this.colFormatMap.get(prop)[0] == configData.INPUT_FORMAT_NUMBER){
				formatMap.put(prop, configData.INPUT_FORMAT_NUMBER);
			}
		}
		
		var formatMapStr = commonUtil.stringToMap(formatMap);
		
		param.put(configData.DATA_EXCEL_LABEL_KEY, labelMap);
		param.put(configData.DATA_EXCEL_LABEL_ORDER_KEY, labelList);
		param.put(configData.DATA_EXCEL_FORMAT_KEY, formatMap);
		
		// excel 전송을 위한 form tag를 초기화 한다.
		if(jQuery("#gridExcelForm").length){
			jQuery("#gridExcelForm").remove();
		}
		
		var url = "/"+this.excelConn+"/"+this.module+"/excel/"+this.command+".data";
		if(param.containsKey("url")){
			url = param.get("url");
		}
		if(this.excelCsvType){
			param.put(configData.DATA_EXCEL_CSV_TYPE, "true");
		}else{
			param.put(configData.DATA_EXCEL_CSV_TYPE, "false");
		}
		
		jQuery("#gridExcelForm").remove();
		
		// 비동기 전달을 위해 전달에 필요한 파라메터에 각 값들은 jsonString형태로 전송한다.
		var formHtml = "<form action='"+url+"' method='post' id='gridExcelForm'>"
					 //+ "<textarea name='"+configData.DATA_EXCEL_REQUEST_KEY+"'>"+param.jsonString()+"</textarea>"
					 + "<input type='text' name='"+configData.DATA_EXCEL_REQUEST_KEY+"' value=\""+paramStr+"\" />"
					 + "<input type='text' name='"+configData.DATA_EXCEL_LABEL_ORDER_KEY+"' value=\""+labelListStr+"\" />"
					 + "<input type='text' name='"+configData.DATA_EXCEL_LABEL_KEY+"' value=\""+labelMapStr+"\" />"
					 + "<input type='text' name='"+configData.DATA_EXCEL_FORMAT_KEY+"' value=\""+formatMapStr+"\" />"
					 + "<input type='text' name='"+configData.DATA_EXCEL_CSV_TYPE+"' value=\""+param.get(configData.DATA_EXCEL_CSV_TYPE)+"\" />"
					 + "<input type='text' name='"+configData.DATA_EXCEL_REQUEST_FILE_NAME+"' value=\""+param.get(configData.DATA_EXCEL_REQUEST_FILE_NAME)+"\" />"
					 + "</form>";
		jQuery(formHtml).hide().appendTo('body');
		jQuery("#gridExcelForm").submit();
	},
	setInfo : function(viewNum) {
		if(this.pageCount){
			viewNum = this.totalCount;
		}
		
		if(this.infoList.length){
			var infoTxt;
			if(viewNum){
				infoTxt = viewNum;
			}else{
				if(this.viewDataList.length != this.data.length){
					infoTxt = this.viewDataList.length+ " ("+this.data.length+")";
				}else{
					infoTxt = this.viewDataList.length;
				}				
			}
			infoTxt += " Record";
			if(this.scrollType){
				infoTxt += " *";
			}
			for(var i=0;i<this.infoList.length;i++){
				this.infoList[i].text(infoTxt);
			}
		}
		
		this.setCheckInfo();
	},
	setCheckInfo : function() {
		if(this.checkInfoList.length){
			var infoTxt = "("+this.selectRow.size()+"/"+this.viewDataList.length+")";

			for(var i=0;i<this.checkInfoList.length;i++){
				this.checkInfoList[i].text(infoTxt);
			}
		}
	},
	removeInputObj : function(){
		var $input = jQuery("#"+configData.GRID_EDIT_INPUT_ID);
		if($input){
			if($input.attr(configData.GRID_EDIT_INPUT_CHANGE_CHECK) != "true"){
				$input.trigger("change");
			}
			var $colObj = $input.parent();
			$colObj.removeClass("textViewChange");
			//var colValue = $colObj.attr(configData.GRID_COL_VALUE);
			//var colName = $colObj.attr(configData.GRID_COL_NAME);
			var rowNum = $input.attr(configData.GRID_INPUT_ROW_NUM);
			var colName = $input.attr(configData.GRID_INPUT_COL_NAME);
			var colValue = $input.val();
			var colFormat = $input.attr(configData.GRID_COL_FORMAT);			
			//if(this.colFormatMap.containsKey(colName)){
			if(colFormat){
				var formatList = colFormat.split(" ");
				colValue = uiList.getDataFormat(formatList, colValue, true);
			}else if(this.colFormatMap.containsKey(colName)){
				var formatList = this.colFormatMap.get(colName);
				colValue = uiList.getDataFormat(formatList, colValue, true);
			}
			
			try{
				$input.autocomplete({
					  source: []
				});
			}catch(e){}
			//$colObj.children().remove();
			$input.remove();
			$colObj.html("");
			$colObj.text(colValue);
			theme.removeInput($colObj);
		}
		
		this.inputRowNum = null;
		this.inputColName = null;
	},
	createInputObj : function($obj, rowNum, colText){
		if(gridList.checkInputObj()){
			this.removeInputObj();
		}
		var validateAtt;
		//var $input = jQuery(theme.GRID_EDIT_INPUT_HTML);
		var $input = theme.createInput($obj);
		var colName = $obj.attr(configData.GRID_COL_NAME);
		//var colValue = $obj.attr(configData.GRID_COL_VALUE);
		$input.attr(configData.GRID_INPUT_ROW_NUM, rowNum);
		$input.attr(configData.GRID_INPUT_COL_NAME, colName);
		//$input.attr(configData.GRID_COL_VALUE, colValue);
		//var colText = $obj.text();
		//$input.val(colText);
		//var colValue = this.getColValue(rowNum, colName);
		var colValue = colText;
		if(colValue == " " && this.checkSourceValue(rowNum, colName) == null){
			colValue = "";
		}
		//$obj.attr(configData.GRID_COL_OBJECT_VALUE, colValue);
		/*
		if(this.colFormatMap.containsKey(colName)){
			var formatList = this.colFormatMap.get(colName);
			if(formatList[0] == configData.INPUT_FORMAT_NUMBER && colValue == "0"){
				colValue = "";
			}
		}
		*/
		
		if(this.colHeadMap.containsKey(colName)){
			colValue = this.colHeadMap.get(colName) + colValue;
		}
		
		if(this.colTailMap.containsKey(colName)){
			colValue = colValue + this.colTailMap.get(colName);
		}
		
		$input.val(colValue);
		if(this.colFormatMap.containsKey(colName)){
			var colFormat;
			var formatList;
			//event fn
			if(commonUtil.checkFn("gridListEventColFormat")){
				colFormat = gridListEventColFormat(this.id, rowNum, colName);
			}
			if(colFormat){
				formatList = colFormat.split(" ");
			}else{
				colFormat = $obj.attr(configData.GRID_COL_FORMAT);
				formatList = this.colFormatMap.get(colName);
			}
			$obj.attr(configData.GRID_COL_FORMAT, colFormat);
			$input.attr(configData.GRID_COL_FORMAT, colFormat);
			var sizeList;
			if(formatList.length > 1){
				sizeList = formatList[1].split(",");
			}
			if(formatList[0] == configData.INPUT_FORMAT_STRING || formatList[0] == configData.INPUT_FORMAT_UPPERCASE || formatList[0] == configData.INPUT_FORMAT_LOWERCASE){
				if(sizeList){
					$input.attr("maxlength",sizeList[0]);
				}
				if(formatList[0] == configData.INPUT_FORMAT_UPPERCASE){
					$input.addClass(configData.INPUT_FORMAT_UPPERCASE_CLASS);
					/*
					$input.keyup(function(event){
						var tmpValue = $input.val();
						tmpValue = tmpValue.toUpperCase();
						$input.val(tmpValue);
					});
					*/
				}else if(formatList[0] == configData.INPUT_FORMAT_LOWERCASE){
					$input.addClass(configData.INPUT_FORMAT_LOWERCASE_CLASS);
					/*
					$input.keyup(function(event){
						var tmpValue = $input.val();
						tmpValue = tmpValue.toLowerCase();
						$input.val(tmpValue);
					});
					*/
				}
			}else if(formatList[0] == configData.INPUT_FORMAT_NUMBER){
				validateAtt = configData.VALIDATION_NUMBER;
				$input.addClass(configData.INPUT_NUMBER_CLASS);
				if(sizeList){
					var numberLength = parseInt(sizeList[0]);
					var commaLength = parseInt((maxLength-1)/3);
					var maxLength = numberLength + commaLength;
					if(sizeList.length > 1){
						maxLength += parseInt(sizeList[1])+1;
					}		
					$input.attr("maxlength",maxLength);
					$input.keyup(function(event){
						if(commonUtil.controllKeyCheck(event)){
							return;
						}
						
						var $obj = $(event.target);
						var tmpValue = $obj.val();
						var mark = "";
						if(tmpValue.charAt(0) == "-"){
							mark = "-";
							tmpValue = tmpValue.substring(1);
						}
						var tmpArray = tmpValue.split(",");
						var tmpMaxLength = numberLength+tmpArray.length-1;
						if(sizeList.length > 1){
							tmpMaxLength += parseInt(sizeList[1])+1;
						}
						$obj.attr("maxlength",tmpMaxLength);
						if(sizeList.length == 1){
							tmpValue = tmpValue.replace(/[^\d]+/g, '');
						}else{
							if(sizeList.length == 1){
								tmpValue = tmpValue.replace(/[^\d]+/g, '');
							}else{
								if(tmpValue.indexOf(".") != -1){
									var tmpNumber = tmpValue.split(".");
									tmpValue = tmpNumber[0].replace(/[^\d]+/g, '')
												+ site.decimalSeparator
												+ tmpNumber[1].replace(/[^\d]+/g, '');
								}else{
									tmpValue = tmpValue.replace(/[^\d]+/g, '');									
								}								
							}
						}
						$obj.val(mark+tmpValue);
					});
				}	
			}else if(formatList[0] == configData.INPUT_FORMAT_NUMBER_STRING){
				validateAtt = configData.VALIDATION_NUMBER;
				$input.addClass(configData.INPUT_NUMBER_CLASS);
				
				$input.attr("maxlength",formatList[1]);
				
				$input.keyup(function(event){
					if(commonUtil.controllKeyCheck(event)){
						return;
					}
					var $obj = $(event.target);
					var tmpValue = $obj.val();
					tmpValue = tmpValue.replace(/[^\d]+/g, '');
					$obj.val(tmpValue);				
				});
			}else if(formatList[0] == configData.INPUT_FORMAT_CALENDER){
				$input.attr("maxlength",site.COMMON_DATE_TYPE.length);
			}else if(formatList[0] == configData.INPUT_FORMAT_DATE){
				$input.attr("maxlength",site.COMMON_DATE_TYPE.length);
			}else if(formatList[0] == configData.INPUT_FORMAT_CALENDER_MONTH){ // 2019.03.07 jw : : Input Data Type Month Added
				$input.attr("maxlength",site.COMMON_DATE_MONTH_TYPE.length);
			}else if(formatList[0] == configData.INPUT_FORMAT_DATE_MONTH){ // 2019.03.07 jw : : Input Data Type Month Added
				$input.attr("maxlength",site.COMMON_DATE_MONTH_TYPE.length);
			}else if(formatList[0] == configData.INPUT_FORMAT_MONTH_SELECT){
				$input.attr("maxlength",site.COMMON_DATE_MONTH_TYPE.length);
			}else if(formatList[0] == configData.INPUT_FORMAT_TIME){
				$input.attr("maxlength",site.COMMON_TIME_TYPE.length);
			}
		}
		
		if(this.autoCompletMap.containsKey(colName)){
			uiList.setAutoComplete($input, this.autoCompletMap.get(colName));
		}

		var tmpAtt = $obj.attr(configData.VALIDATION_ATT);
		if(tmpAtt){
			var tmpAttList = tmpAtt.split(" ");
			for(var i=0;i<tmpAttList.length;i++){
				if(tmpAttList[i].split(",")[0] == configData.VALIDATION_PHONE){
					$input.css("IME-MODE","disabled");
					$input.attr("maxlength",12);
					$input.keyup(function(event){
						if(commonUtil.controllKeyCheck(event)){
							return;
						}
						var $obj = $(event.target);
						var tmpValue = $obj.val();
						tmpValue = tmpValue.replace(/[^\d]+/g, '');
						$obj.val(tmpValue);
					});
					break;
				}
			}
			if(validateAtt){
				validateAtt = tmpAtt + " " + validateAtt;
			}
			$obj.attr(configData.VALIDATION_ATT, validateAtt);
		}
		
		$input.attr(configData.GRID_ID_ATT, this.id);
		
		$input.css("width", "100%");
		$input.css("height", "100%");
		
		this.inputRowNum = rowNum;
		this.inputColName = colName;
		
		return $input;
	},
	getColObj : function($obj){
		var $colObj;
		if($obj.attr(configData.GRID_COL_TYPE) && $obj.attr(configData.GRID_COL_TYPE)){
			$colObj = $obj;
		}else{
			$colObj = $obj.parents("["+configData.GRID_COL+"]");
		}
		return $colObj;
	},
	setNextEditFocus : function(){
		var colIndex = 0;
		var tmpEditCols;
		if(this.gridMobileType){
			tmpEditCols = this.editableCols;
		}else{
			tmpEditCols = this.viewEditCols;
		}
		
		for(var i=0;i<tmpEditCols.length;i++){
			if(tmpEditCols[i] == this.focusColName && !this.checkReadOnly(this.focusRowNum, tmpEditCols[i])){
				colIndex = i;
				break;
			}
		}
		
		var tmpFocusViewRowNum = this.getViewRowNum(this.focusRowNum);
		var tmpNextRowNum;
		if(tmpFocusViewRowNum < this.viewDataList.length-1){
			tmpNextRowNum = this.viewDataList[tmpFocusViewRowNum+1];
		}else{
			tmpNextRowNum = this.focusRowNum;
		}		
		
		if(colIndex == tmpEditCols.length-1 && tmpFocusViewRowNum < this.viewDataList.length-1){
			this.setFocus(tmpNextRowNum, tmpEditCols[0]);
		}else{
			var nextColIndex = 0;
			for(var i=colIndex+1;i<tmpEditCols.length;i++){
				if(!this.checkReadOnly(this.focusRowNum, tmpEditCols[i])){
					nextColIndex = i;
					break;
				}
			}
			if(nextColIndex == 0){
				for(var i=0;i<tmpEditCols.length;i++){
					if(!this.checkReadOnly(tmpNextRowNum, tmpEditCols[i])){
						nextColIndex = i;
						break;
					}
				}
				if(tmpFocusViewRowNum == this.viewDataList.length-1){
					tmpNextRowNum = this.viewDataList[0];
				}else{
					tmpNextRowNum = this.viewDataList[tmpFocusViewRowNum+1];
				}				
				this.setFocus(tmpNextRowNum, tmpEditCols[nextColIndex]);
			}else{
				this.setFocus(this.focusRowNum, tmpEditCols[nextColIndex]);
			}			
		}
	},
	/*
	setNextEditObjFocus : function($obj){
		
		var $colObj = this.getColObj($obj);
		var $rowObj = $colObj.parent();
		var $editCols = $rowObj.find("["+configData.GRID_COL_TYPE+"]")
								.filter("["+configData.GRID_COL_TYPE+"!="+configData.GRID_COL_TYPE_TEXT+"]")
								.filter("["+configData.GRID_COL_TYPE+"!="+configData.GRID_COL_TYPE_ROWNUM+"]");
		var colIndex = $editCols.index($colObj);
		if(colIndex == $editCols.length-1){
			this.focusColName = $editCols.eq(0).attr(configData.GRID_COL_NAME);
			this.changeFocus($editCols.eq(0), 1, true);
		}else{
			this.changeFocus($editCols.eq(colIndex+1), 0, true);
		}
	},
	*/
	btnClickEvent : function(obj){
		var $btnObj = jQuery(obj);
		var rowNum = $btnObj.attr(configData.GRID_COL_TYPE_BTN_ROWNUM_ATT);
		var btnName = $btnObj.attr(configData.GRID_COL_TYPE_BTN_NAME_ATT);
		//event fn
		if(commonUtil.checkFn("gridListEventColBtnclick")){
			gridListEventColBtnclick(this.id, rowNum, btnName);			
		}
	},
	deleteBtnClickEvent : function(obj){
		var $btnObj = jQuery(obj);
		var rowNum = $btnObj.attr(configData.GRID_COL_TYPE_BTN_ROWNUM_ATT);
		var btnName = $btnObj.attr(configData.GRID_COL_TYPE_BTN_NAME_ATT);
		this.deleteRow(rowNum, true);
	},
	keydownEvent : function(event){
		if(!event){
			return;
		}
		
		var $obj = $(event.target);
		var code = event.keyCode;
		
		var gridBox = this;
		
		if(code == 38){
			commonUtil.cancleEvent(event);
			//var $colObj = this.getColObj($obj);
			//this.changeFocus($colObj, -1, true);
			this.moveFocus(-1);
		}else if(code == 40){
			commonUtil.cancleEvent(event);
			//var $colObj = this.getColObj($obj);
			//this.changeFocus($colObj, 1, true);
			this.moveFocus(1);
		}else if(code == 9){
			commonUtil.cancleEvent(event);
			//this.setNextEditObjFocus($obj);
			this.setNextEditFocus();
		}else if(code == 13){
			if(!site.gridSearchHelpEnter){
				commonUtil.cancleEvent(event);
				if(this.enterKeyType == "C"){
					//this.setNextEditObjFocus($obj);
					this.setNextEditFocus();
				}else{
					//var $colObj = this.getColObj($obj);
					//this.changeFocus($colObj, 1, true);
					this.moveFocus(1);
				}
			}
		}else if(code == 33){
			if(!event.shiftKey){
				this.pageMoveNum = -1;
			}
		}else if(code == 34){
			if(!event.shiftKey){
				this.pageMoveNum = 1;
			}
		}
		
		if($obj.attr("type") == "checkbox"){
			if(code == 32){
				this.checkboxChangeEvent($obj);
			}
		}else if($obj.get(0).tagName == "SELECT"){
			$obj.change(function(){
				gridBox.valueChangeEvent($obj);
			});
		}
		
		if(event.altKey){
			if(code == 86){
				commonUtil.cancleEvent(event);
				var copyData;
				if (window.clipboardData) { // Internet Explorer
					copyData = window.clipboardData.getData("Text").toString();
			    }else{ 
			    	var $sColObj = this.getColObj($obj);
			    	gridList.clipDataCopy(this.id, $sColObj);
			    }
				if(copyData){
					var $sColObj = this.getColObj($obj);
					this.copyDataView($sColObj, copyData);
				}	
			}else if(code == site.GRID_KEY_EVENT_ROWCOPY_CODE){
				if(!this.addType){
					return;
				}
				commonUtil.cancleEvent(event);
				var tmpCopyData = 0;
				var rowData = this.getRowData(this.focusRowNum);
				for(var i=0;i<this.viewCols.length;i++){
					if(i != 0){
						tmpCopyData += "\t";						
					}
					if(rowData.get(this.viewCols[i])){
						tmpCopyData += rowData.get(this.viewCols[i]);
					}else{
						tmpCopyData += site.emptyValue;
					}					
				}
				if(window.clipboardData) { // Internet Explorer
					window.clipboardData.setData("Text", tmpCopyData);
			    }else{
			    	if(this.copyEventType){
			    		window.prompt("Ctrl+C copy clipboard", tmpCopyData);
			    	}
			    }
			}else if(code == site.GRID_KEY_EVENT_ADDROW_CODE){
				if(!this.addType){
					return;
				}
				commonUtil.cancleEvent(event);
				this.addRow();
			}else if(code == site.GRID_KEY_EVENT_DELETEROW_CODE){
				if(!this.deleteType){
					return;
				}
				commonUtil.cancleEvent(event);
				if(this.selectRowDeleteType){
					this.deleteSelectRow();
				}else{
					this.deleteRow();
				}
			}else if(code == site.GRID_KEY_EVENT_LAYOUT_CODE){
				if(!this.columnEditType){
					return;
				}
				commonUtil.cancleEvent(event);
				layoutSave.setLauyout(this);
			}else if(code == site.GRID_KEY_EVENT_TOTAL_CODE){
				if(!this.totalType){
					return;
				}
				commonUtil.cancleEvent(event);
				this.viewTotal();
			}else if(code == site.GRID_KEY_EVENT_EXCELDOWN_CODE){
				if(!this.excelDownType){
					return;
				}
				commonUtil.cancleEvent(event);
				this.gridExcelRequest();
			}else if(code == site.GRID_KEY_EVENT_SORT_CODE){
				if(!this.sortType){
					return;
				}
				commonUtil.cancleEvent(event);
				this.sortReset();
				//this.$gridHead.find(this.headColTagName+"["+configData.GRID_COL_NAME+"="+this.focusColName+"]").trigger("dblclick");
				/*
				var tmpSortType;
				for(var i=0;i<this.sortColList.length;i++){
					if(this.focusColName == this.sortColList[i]){
						tmpSortType = this.sortTypeList[i];
						break;
					}
				}
				if(tmpSortType == undefined){
					tmpSortType = false;
				}
				this.appendSort(this.focusColName, !tmpSortType, true);
				*/
			}
		}
	},
	copyDataView : function($sColObj, copyData){
		copyData = commonUtil.replaceAll(copyData, "\r", "");
		var dataList = copyData.split("\n");
		if(dataList.length > 0){
			if(dataList[dataList.length-1] == ""){
				dataList.pop();
			}
		}
		var $sRowObj = $sColObj.parents("["+configData.GRID_ROW+"]");
		var sRowNum = $sRowObj.attr(configData.GRID_ROW_NUM);
		var sRowViewNum = this.getViewRowNum(sRowNum);
		var $cols = $sRowObj.find("> ["+configData.GRID_COL_TYPE+"!="+configData.GRID_COL_TYPE_TEXT+"]");
		var sColIdx = $cols.index($sColObj);
		var colList = new Array();
		var colName;
		// && this.editableColMap
		for(var i=sColIdx;i<$cols.length;i++){
			colName = $cols.eq(i).attr(configData.GRID_COL_NAME);
			colList.push(colName);
		}
		
		var tmpMaxCount = this.viewDataList.length - sRowViewNum;
		//2019.02.01 KHC : art + V시, 행이 안늘어남. autoNewRowType -> autoCopyRowType 변경
		if(this.addType && this.autoCopyRowType && tmpMaxCount < dataList.length){
			tmpMaxCount = dataList.length - tmpMaxCount;
			for(var i=0;i<tmpMaxCount;i++){
				if(this.autoCopyRowType){
					this.addRow(this.getRowData(sRowNum), false);
				}else{
					this.addRow(null, false);
				}							
			}						
		}

		var rowData;
		var rowNum;
		var $rowObj;
		var $colObj;
		for(var i=0;i<dataList.length;i++){
			rowNum = this.viewDataList[sRowViewNum+i];
			if(rowNum != undefined && dataList[i]){
				rowData = dataList[i].split("\t");
				$rowObj = this.$box.find("["+configData.GRID_ROW_NUM+"="+rowNum+"]");
				if(this.readOnlyRowMap && this.readOnlyRowMap.get(rowNum)){
					continue;
				}
				for(var j=0;j<rowData.length;j++){
					colName = colList[j];
					if(colName){
						if(this.readOnlyColMap && this.readOnlyColMap.get(colName)){
							continue;
						}
						if(this.readOnlyCellMap && this.readOnlyCellMap.containsKey(rowNum) && this.readOnlyCellMap.get(rowNum).get(colName)){
							continue;
						}
						this.setColValue(rowNum, colName, rowData[j], true, true, $rowObj);
					}else{
						break;
					}
				}
			}else{
				break;
			}
		}
	},
	multiDataView : function(startRowNum, colName, dataList){
		var rowNum;
		var $rowObj;
		var colValue;
		var sRowViewNum = this.getViewRowNum(startRowNum);
		var tmpMaxCount = this.viewDataList.length - sRowViewNum;
		if(this.addType && this.autoNewRowType && tmpMaxCount < dataList.length){
			tmpMaxCount = dataList.length - tmpMaxCount;
			var rowMapList = new Array();
			for(var i=0;i<tmpMaxCount;i++){
				if(this.autoCopyRowType){
					rowMapList = this.getRowData(startRowNum);
				}else{
					this.addRow(null, false);
				}							
			}						
		}
		for(var i=0;i<dataList.length;i++){
			rowNum = this.viewDataList[sRowViewNum+i];
			if(rowNum != undefined && dataList[i]){
				colValue = dataList[i];
				$rowObj = this.$box.find("["+configData.GRID_ROW_NUM+"="+rowNum+"]");
				if(this.readOnlyRowMap && this.readOnlyRowMap.get(rowNum)){
					continue;
				}
				if(this.readOnlyColMap && this.readOnlyColMap.get(colName)){
					continue;
				}
				if(this.readOnlyCellMap && this.readOnlyCellMap.containsKey(rowNum) && this.readOnlyCellMap.get(rowNum).get(colName)){
					continue;
				}
				this.setColValue(rowNum, colName, colValue, true, true, $rowObj);
			}else{
				break;
			}
		}
	},
	mouseoverEvent : function($obj){
		var $rowObj = $obj.parents("["+configData.GRID_ROW+"]");
		var rowNum = $rowObj.attr(configData.GRID_ROW_NUM);
		//this.lastRowNum = rowNum;
		$rowObj.addClass(configData.GRID_MOUSEOVER_CLASS);
	},
	mouseoutEvent : function($obj){
		var $rowObj = $obj.parents("["+configData.GRID_ROW+"]");
		$rowObj.removeClass(configData.GRID_MOUSEOVER_CLASS);
	},
	colBtnCreate : function($obj, $input, $btn, blurType){
		var colName = $obj.attr(configData.GRID_COL_NAME);
		var $headCol = this.$gridHead.find(this.headColgroupTagName).find(this.headColattTagName+"["+configData.GRID_COL_NAME+"="+colName+"]");
		var tmpWidth;
		try{
			tmpWidth = $obj.css("width");
			if(tmpWidth){
				if(tmpWidth.indexOf("px")){
					tmpWidth = tmpWidth.substring(0, tmpWidth.indexOf("px"));
				}
				tmpWidth = parseInt(tmpWidth);
				if(tmpWidth){
					if(this.viewCols[this.viewCols.length-1] ==colName ){
						tmpWidth -= 19;
					}
					tmpWidth = (tmpWidth - theme.GRID_BTN_WIDTH)+"px";
				}
			}			
		}catch(e){}
		if(!tmpWidth){
			tmpWidth = "80%";
		}
		//page.searchHelp($obj, searchCode);
		$input.css("width",tmpWidth);
		//var $searchBtn = jQuery("<button class='button type3' type='button' style='height:95%;'><img src='/common/images/ico_find.png' /></button>");
		$input.after($btn);

		this.$focusInput = $input;
		
		$btn.mouseover(function(event){
			$input.attr("btnType","over");
		});
		
		if(blurType == undefined){
			blurType = true;
		}
		
		if(blurType){
			$btn.mouseout(function(event){
				$input.attr("btnType","out");
			});
		}			
		
		var gridBox = this;
		
		//if(blurType){
			$input.blur(function(event){
				var $inputObj = $(event.target);
				gridBox.inputBlurEvent($inputObj);
			});
		//}
			
		$btn.parent().addClass("textViewChange");
	},
	inputBlurEvent : function($input){
		var $colObj = $input.parent();
		theme.removeInput($colObj);
		if($input.attr("btnType") == "over"){
			return;
		}
		if($input.attr(configData.GRID_EDIT_INPUT_CHANGE_CHECK) != "true"){
			$input.trigger("change");
		}
		//var colValue = $colObj.attr(configData.GRID_COL_VALUE);
		//var colName = $colObj.attr(configData.GRID_COL_NAME);
		var rowNum = $input.attr(configData.GRID_INPUT_ROW_NUM);
		var colName = $input.attr(configData.GRID_INPUT_COL_NAME);
		var colValue = $input.val();
		var colFormat = $input.attr(configData.GRID_COL_FORMAT);
		
		//$colObj.addClass(configData.GRID_COL_TYPE_INPUT_TEXT_CLASS);
		$colObj.text(colValue);
		
		if(this.colFormatMap.containsKey(colName)){
			//var colFormat = $input.attr(configData.GRID_COL_FORMAT);
			if(colFormat){
				var formatList = colFormat.split(" ");
				colValue = uiList.getDataFormat(formatList, colValue, true);
			}else{
				colValue = uiList.getDataFormat(this.colFormatMap.get(colName), colValue, true);
			}
		}
		//$input.remove();
		this.removeInputObj();
	},
	checkboxChangeEvent : function($obj, rowNum){
		//var $colObj = $obj.parent();
		var $colObj = $obj.parents("["+configData.GRID_COL+"]");
		var $rowObj = $obj.parents("["+configData.GRID_ROW+"]");
		if(rowNum == undefined){			
			rowNum = $rowObj.attr(configData.GRID_ROW_NUM);
		}
		var tmpType = $colObj.attr(configData.GRID_COL_TYPE);
		if(tmpType == configData.GRID_COL_TYPE_ROWCHECK){
			this.rowCheckSelect($obj, true);
			this.rowFocus(rowNum, true);					
			
			//event fn
			if(commonUtil.checkFn("gridListEventRowCheck")){
				gridListEventRowCheck(this.id, rowNum, $obj.prop("checked"));
			}
		}else{
			var colName = $colObj.attr(configData.GRID_COL_NAME);
			var tmpVal;
			if($obj.prop("checked")){
				tmpVal = site.defaultCheckValue;
				if($obj.attr(configData.GRID_COL_CHECK_RADIO)){
					var tmpRowNum;
					for(var i=0;i<this.viewDataList.length;i++){
						tmpRowNum = this.viewDataList[i];
						var tmpValue = this.getColValue(tmpRowNum, colName);
						if(tmpValue == site.defaultCheckValue){
							this.setColValue(tmpRowNum, colName, site.emptyValue);
							break;
						}
					}
				}						
			}else{
				tmpVal = site.emptyValue;
			}
			$colObj.attr(configData.GRID_COL_VALUE, tmpVal);
			this.bindGridData($colObj, $rowObj);
		}
	},
	createGridColInput : function($obj){
		
	},
	treeRowCheck : function(rowNum, checkType, $rowObj){
		if(this.tree && rowNum < this.data.length-1){
			if(checkType == undefined){
				checkType = true;
			}
			if(!$rowObj){
				$rowObj = this.$box.find("["+configData.GRID_ROW_NUM+"="+rowNum+"]");
			}
			var tmpLvlValue = this.getColValue(rowNum, this.treeLvl);
			var tmpNextLvlValue = this.getColValue(parseInt(rowNum)+1, this.treeLvl);
			if(tmpLvlValue < tmpNextLvlValue){
				var $nextRowObj = $rowObj.next();
				var tmpNextRowNum = parseInt($nextRowObj.attr(configData.GRID_ROW_NUM));
				while(tmpLvlValue < tmpNextLvlValue){
					var $tmpRowCheckObj = $nextRowObj.find("["+configData.GRID_COL_TYPE+"="+configData.GRID_COL_TYPE_ROWCHECK+"]").find("input");
					$tmpRowCheckObj.prop("checked", checkType);
					this.checkboxChangeEvent($tmpRowCheckObj, tmpNextRowNum);
					$nextRowObj = $nextRowObj.next();
					tmpNextRowNum = parseInt($nextRowObj.attr(configData.GRID_ROW_NUM));
					tmpNextLvlValue = this.getColValue(tmpNextRowNum, this.treeLvl);
				}
				this.rowFocus(rowNum, true);
			}
			/*
			rowNum = parseInt(rowNum);
			var $nextRowObj = $rowObj.next();
			var startRowNum = rowNum;
			var endRowNum = rowNum;
			var tmpLvlValue = this.getColValue(rowNum, this.treeLvl);
			var tmpNextLvlValue = this.getColValue(parseInt(rowNum)+1, this.treeLvl);
			if(tmpLvlValue < tmpNextLvlValue){
				endRowNum = parseInt($nextRowObj.attr(configData.GRID_ROW_NUM));
				$nextRowObj = $nextRowObj.next();
				tmpNextLvlValue = this.getColValue(endRowNum, this.treeLvl);
				while(tmpLvlValue < tmpNextLvlValue){
					endRowNum = parseInt($nextRowObj.attr(configData.GRID_ROW_NUM));
					$nextRowObj = $nextRowObj.next();
					tmpNextLvlValue = this.getColValue(endRowNum+1, this.treeLvl);
				}
				for(var i=startRowNum;i<=endRowNum;i++){
					this.setRowCheck(i, checkType, false);
				}
				this.rowFocus(rowNum, true);
			}
			*/
		}
	},
	clickEvent : function($obj, event){
		var tmpTagName = $obj.get(0).tagName;
			
		var gridBox = this;
		var $rowObj = $obj.parents("["+configData.GRID_ROW+"]");
		if($rowObj.attr(configData.GRID_ROW_TOTAL_ATT)){
			return true;
		}
		
		var rowNum = $rowObj.attr(configData.GRID_ROW_NUM);
		
		if (!(Browser.ie6) && !(Browser.ie7) && !(Browser.ie8)) {
			if(this.focusRowNum != rowNum){
				this.rowFocus(rowNum, true);
			}
		}else{
			if(this.focusRowNum != rowNum && tmpTagName != "SELECT"){
				this.rowFocus(rowNum, true);
			}
		}
		
		if($obj.attr("GClick") == "false"){
			return;
		}
		
		if(--this.selectingType == 0){
			this.resetSelected();
		}
		
		//var rowNum = this.lastRowNum;
		
		var colType = $obj.attr(configData.GRID_COL_TYPE);
		var colName = $obj.attr(configData.GRID_COL_NAME);
		
		if(!colType){
			colType = $obj.parents("["+configData.GRID_COL_TYPE+"]").attr(configData.GRID_COL_TYPE);
			colName = $obj.parents("["+configData.GRID_COL_NAME+"]").attr(configData.GRID_COL_NAME);
		}
		
		if(tmpTagName == "BUTTON"){
			if(this.rowClickEventFn){
				eval(this.rowClickEventFn+"(gridBox.id, rowNum, colName)");
			}else{
				//event fn
				if(commonUtil.checkFn("gridListEventRowClick")){
					gridListEventRowClick(gridBox.id, rowNum, colName);
				}
			}
			
			if($obj.attr("class") == configData.GRID_COL_TYPE_FILE_TYPE){
				var tmpFileType = $obj.prev().attr(configData.GRID_COL_TYPE_FILE_TYPE);
				gridList.fileChooser(this.id, rowNum, colName, $rowObj, $obj, tmpFileType, true); // 2019.03.20 jw : $rowObj Parameter Added
			}
			
			return true;
		}
		
		if(!this.gridMobileType && event && event.altKey){
			this.selectArea(this.focusRowNum, this.focusColName, rowNum, colName);
			return true;
		}

		//var $lastCol = this.$box.find("["+configData.GRID_ROW_NUM+"="+this.focusRowNum+"]").find("["+configData.GRID_COL_NAME+"="+this.focusColName+"]");
		//var lastColName = $lastCol.attr(configData.GRID_COL_NAME);

		if(rowNum != this.focusRowNum || (colName && this.focusColName && colName != this.focusColName)){
			if(this.$lastCol){
				var $tmpInput = this.$lastCol.find("input:text");
				if($tmpInput.length > 0){
					$tmpInput.trigger("change");
					this.inputBlurEvent($tmpInput);
				}
			}			
		}
		
		if(tmpTagName == "SELECT"){
			$obj.change(function(){
				gridBox.valueChangeEvent($obj);
			});
		}
		
		//ie에서 디저블된 checkbox를 더블클릭하는 경우 수정인식되는 문제 해결
		if($obj.attr("type") == "checkbox" && $obj.attr("disabled") != "disabled"){
			this.checkboxChangeEvent($obj, rowNum);
			if(this.tree && colType == configData.GRID_COL_TYPE_ROWCHECK){
				this.treeRowCheck(rowNum, $obj.prop("checked"), $rowObj);
				/*
				if(rowNum < this.data.length-1){
					var tmpLvlValue = this.getColValue(rowNum, this.treeLvl);
					var tmpNextLvlValue = this.getColValue(parseInt(rowNum)+1, this.treeLvl);
					if(tmpLvlValue < tmpNextLvlValue){
						var $nextRowObj = $rowObj.next();
						var tmpNextRowNum = parseInt($nextRowObj.attr(configData.GRID_ROW_NUM));
						while(tmpLvlValue < tmpNextLvlValue){
							var $tmpRowCheckObj = $nextRowObj.find("["+configData.GRID_COL_TYPE+"="+configData.GRID_COL_TYPE_ROWCHECK+"]").find("input");
							$tmpRowCheckObj.prop("checked", $obj.prop("checked"));
							this.checkboxChangeEvent($tmpRowCheckObj, tmpNextRowNum);
							$nextRowObj = $nextRowObj.next();
							tmpNextRowNum = parseInt($nextRowObj.attr(configData.GRID_ROW_NUM));
							tmpNextLvlValue = this.getColValue(tmpNextRowNum, this.treeLvl);
						}
						this.rowFocus(rowNum, true);
					}
				}
				*/
			}
		}
		
		this.focusColName = colName;
		this.$lastCol = null;
		
		if(colType){						
			if(colType == configData.GRID_COL_TYPE_INPUT){
				//this.focusColName = colName;
				this.$lastCol = $obj;
				
				var colReadOnlyCheck = false;
				if($obj.attr("disabled")){
					colReadOnlyCheck = true;
				}else if($obj.hasClass(configData.GRID_COL_TYPE_DISABLE_CLASS)){
					colReadOnlyCheck = true;
				}
				
				if(!colReadOnlyCheck){
					//$obj.removeClass(configData.GRID_COL_TYPE_INPUT_TEXT_CLASS);
					var colText = $obj.text();
					var $input = this.createInputObj($obj, rowNum, colText);
					$obj.html($input);
					$input.attr("GClick","false");
					$input.focus();
					$input.select();
					var normalInput = true;
					
					if(this.colFormatMap.containsKey(colName)){
						var formatList = this.colFormatMap.get(colName);
						if(formatList[0] == configData.INPUT_FORMAT_NUMBER){
						}else if(formatList[0] == configData.INPUT_FORMAT_CALENDER){
							var $btn = uiList.createCalender($input, this.id);
							this.colBtnCreate($obj, $input, $btn);
						}else if(formatList[0] == configData.INPUT_FORMAT_CALENDER_MONTH){ // 2019.03.07 jw : : Input Data Type Month Added
							var $btn = uiList.createCalender($input, this.id);
							this.colBtnCreate($obj, $input, $btn);
						}else if(formatList[0] == configData.INPUT_FORMAT_MONTH_SELECT){
							var $btn = uiList.createMonthSelect($input, this.id);
							this.colBtnCreate($obj, $input, $btn);
						}else if(formatList[0] == configData.INPUT_FORMAT_TIME){
							
						}else if(formatList[0] == configData.INPUT_FORMAT_BUTTON){
							normalInput = false;
							var iconClass = configData.BUTTON_ICON.get(formatList[1]);
							var $btn = jQuery("<button class='"+configData.BUTTON_CLASS+"' type='button' style='height:100%;'><span class='"+configData.BUTTON_ICON_CLASS+" "+iconClass+"'>Icon</span></button>");
							$btn.click(function(event){
								//event fn
								if(commonUtil.checkFn("gridListEventColBtnClick")){
									gridListEventColBtnClick(gridBox.id, rowNum, colName);
								}
							});
							this.colBtnCreate($obj, $input, $btn);
						}
					}
					
					var $searchBtn;
					
					if(this.colSearchMap.containsKey(colName)){
						var searchCode = this.colSearchMap.get(colName);
						var multyType = false;
						if(this.colSearchMultiMap.containsKey(colName)){
							multyType = true;
						}
						normalInput = false;
						$searchBtn = theme.getGridSearchBtn(gridBox, $input);
						$searchBtn.click(function(event){
							$input.attr("name", colName);
							page.searchHelp($input, searchCode, multyType, rowNum, gridBox.id);
						});
						this.colBtnCreate($obj, $input, $searchBtn);
						$input.keydown(function(event){
							var $obj = $(event.target);
							var code = event.keyCode;
							if(code!= 18 && event.altKey){
								if(code == site.COMMON_KEY_EVENT_SEARCH_HELP_CODE){
									$searchBtn.trigger("mouseover");
									$searchBtn.trigger("click");
								}
							}else if(site.gridSearchHelpEnter && code == 13){
								$searchBtn.trigger("mouseover");
								$searchBtn.trigger("click");															
							}
						});
						$searchBtn.attr("GClick","false");
						$searchBtn.children().attr("GClick","false");
					}

					$input.change(function(event){
						var $inputObj = $(event.target);
						$inputObj.attr(configData.GRID_EDIT_INPUT_CHANGE_CHECK, "true");
						//var colValue = $inputObj.attr(configData.GRID_COL_VALUE);
						var rowNum = $inputObj.attr(configData.GRID_INPUT_ROW_NUM);
						var colName = $inputObj.attr(configData.GRID_INPUT_COL_NAME);
						var colValue = gridBox.getColValue(rowNum, colName);
						if(colValue == " " && gridBox.checkSourceValue(rowNum, colName) == null){
						//if(colValue == " "){
							colValue = "";
						}
						var tmpValue = $inputObj.val();
						var tmpColHead = "";
						var tmpColTail = "";
						
						if(gridBox.colHeadMap.containsKey(colName)){
							tmpColHead = gridBox.colHeadMap.get(colName);
							if(tmpValue.indexOf(tmpColHead) == 0){
								tmpValue = tmpValue.substring(tmpColHead.length);
							}
						}
						
						if(gridBox.colTailMap.containsKey(colName)){
							tmpColTail = gridBox.colTailMap.get(colName);
							if(tmpValue.indexOf(tmpColTail) == (tmpValue.length - tmpColTail.length)){
								tmpValue = tmpValue.substring(0, (tmpValue.length - tmpColTail.length));
							}
						}
						
						if(gridBox.colFormatMap.containsKey(colName)){
							var formatList = gridBox.colFormatMap.get(colName);
							tmpValue = uiList.getDataFormat(formatList, tmpValue);
							var viewTmpValue = uiList.getDataFormat(formatList, tmpValue, true);							
							$inputObj.val(tmpColHead+viewTmpValue+tmpColTail);
						}
						
						if(colValue != tmpValue){
							gridBox.valueChangeEvent($inputObj);
						}
						if($searchBtn){
							$searchBtn.trigger("mouseout");
						}
					});
					if(normalInput){
						$input.blur(function(event){
							var $inputObj = $(event.target);
							gridBox.inputBlurEvent($inputObj);						
						});
					}
					$input.focus();
					
					
					//event fn
					if(commonUtil.checkFn("gridListEventInputColFocus")){
						gridListEventInputColFocus(gridBox.id, rowNum, colName);
					}
				}
			/*
			}else if(colType == configData.GRID_COL_TYPE_TREE){
				if(rowNum < this.data.length-1){
					var tmpLvlValue = this.getColValue(rowNum, this.treeLvl);
					var tmpNextLvlValue = this.getColValue(parseInt(rowNum)+1, this.treeLvl);
					if(tmpLvlValue < tmpNextLvlValue){
						var childViewType = $rowObj.attr("childViewType");
						var tmpViewType = false;
						if(childViewType == "false"){
							$rowObj.find("span").eq(0).text("-");
							tmpViewType = true;
						}else{
							$rowObj.find("span").eq(0).text("+");
							tmpViewType = false;
						}
						$rowObj.attr("childViewType", tmpViewType);
						var $nextRowObj = $rowObj.next();
						var tmpNextRowNum = parseInt($nextRowObj.attr(configData.GRID_ROW_NUM));
						while(tmpLvlValue < tmpNextLvlValue){
							if(tmpViewType){
								$nextRowObj.show();
								if($nextRowObj.find("span").eq(0).text() == "+"){
									$nextRowObj.find("span").eq(0).text("-");
									$nextRowObj.attr("childViewType", true);
								}
							}else{
								$nextRowObj.hide();
							}
							$nextRowObj = $nextRowObj.next();
							tmpNextRowNum = parseInt($nextRowObj.attr(configData.GRID_ROW_NUM));
							tmpNextLvlValue = this.getColValue(tmpNextRowNum, this.treeLvl);
						}
					}
				}
			*/
			}else if(colType == configData.GRID_COL_TYPE_FILE){
				var tmpFileType = $obj.attr(configData.GRID_COL_TYPE_FILE_TYPE);
				//2019.02.19 프로젝트수정
				if($obj.hasClass("btn_delY")){
					gridList.fileChooser(this.id, rowNum, colName, $rowObj, $obj, tmpFileType); // 2019.03.20 jw : $rowObj Parameter Added
				}else{
					gridList.fileChooser(this.id, rowNum, colName, $rowObj, $obj, tmpFileType, true); // 2019.03.20 jw : $rowObj Parameter Added
				}
			}else if(colType == configData.GRID_COL_TYPE_FILE_DOWNLOAD){ // 2019.03.20 jw : Grid Data Type FileDownload Added
				gridList.fileChooser(this.id, rowNum, colName, $rowObj, $obj, tmpFileType);
			}else if(colType == configData.GRID_COL_TYPE_BTN){
				if(commonUtil.checkFn("gridListEventColBtnclick")){
					gridListEventColBtnclick(this.id, rowNum, colName, $obj);
				}
			}else{
				//$obj.focus();
			}
			
			if(this.rowClickEventFn){
				eval(this.rowClickEventFn+"(gridBox.id, rowNum, colName)");
			}else{
				//event fn
				if(commonUtil.checkFn("gridListEventRowClick")){
					gridListEventRowClick(gridBox.id, rowNum, colName);
				}
			}
		}
	},
	dbclickEvent : function($obj){
		var $rowObj = $obj.parents("["+configData.GRID_ROW+"]");
		if($rowObj.attr(configData.GRID_ROW_TOTAL_ATT)){
			return;
		}
		
		var rowNum = $rowObj.attr(configData.GRID_ROW_NUM);
		var colType = $obj.attr(configData.GRID_COL_TYPE);
		if(colType == undefined){
			$obj = $obj.parents("["+configData.GRID_COL_TYPE+"]");
			colType = $obj.attr(configData.GRID_COL_TYPE);
		}
		
		var colName = $obj.attr(configData.GRID_COL_NAME);
		if(!colName){
			var $tmpObj = $obj.parents("["+configData.GRID_COL_NAME+"]");
			if($tmpObj){
				colName = $tmpObj.attr(configData.GRID_COL_NAME);
			}
		}
		var colValue = this.getColValue(rowNum, colName);
		
		if(this.itemGrid){
			this.searchRowNum = rowNum;
			//event fn
			if(commonUtil.checkFn("gridListEventItemGridSearch")){
				gridListEventItemGridSearch(this.id, rowNum, this.itemGridList);
			}
		}
			
		var textBlockType = true;
		if(this.rowDblClickEventFn){
			eval(this.rowDblClickEventFn+"(this.id, rowNum, colName, colValue)");
		}else{
			//event fn
			if(commonUtil.checkFn("gridListEventRowDblclick")){
				textBlockType = gridListEventRowDblclick(this.id, rowNum, colName, colValue);
			}
			if(textBlockType == undefined){
				textBlockType = true;
			}
		}
		if(this.id != configData.GRID_LAYOUT_SAVE_VISIBLE_ID && this.id != configData.GRID_LAYOUT_SAVE_INVISIBLE_ID && colType == configData.GRID_COL_TYPE_TEXT){
			if(textBlockType){
				commonUtil.textAllSelect($obj);
			}
		}else if(colType == configData.GRID_COL_TYPE_TREE){
			if(rowNum < this.data.length-1){
				var tmpLvlValue = this.getColValue(rowNum, this.treeLvl);
				var tmpNextLvlValue = this.getColValue(parseInt(rowNum)+1, this.treeLvl);
				if(tmpLvlValue < tmpNextLvlValue){
					var childViewType = $rowObj.attr("childViewType");
					var tmpViewType = false;
					if(childViewType == "false"){
						$rowObj.find("span").eq(0).text("-");
						tmpViewType = true;
					}else{
						$rowObj.find("span").eq(0).text("+");
						tmpViewType = false;
					}
					$rowObj.attr("childViewType", tmpViewType);
					var $nextRowObj = $rowObj.next();
					var tmpNextRowNum = parseInt($nextRowObj.attr(configData.GRID_ROW_NUM));
					while(tmpLvlValue < tmpNextLvlValue){
						if(tmpViewType){
							$nextRowObj.show();
							if($nextRowObj.find("span").eq(0).text() == "+"){
								$nextRowObj.find("span").eq(0).text("-");
								$nextRowObj.attr("childViewType", true);
							}
						}else{
							$nextRowObj.hide();
						}
						$nextRowObj = $nextRowObj.next();
						tmpNextRowNum = parseInt($nextRowObj.attr(configData.GRID_ROW_NUM));
						tmpNextLvlValue = this.getColValue(tmpNextRowNum, this.treeLvl);
					}
				}
			}
		}
	},
	selectStartEvent : function($obj){
		var $rowObj = $obj.parents("["+configData.GRID_ROW+"]");
		if($rowObj.attr(configData.GRID_ROW_TOTAL_ATT)){
			return false;
		}
		this.selectingType = 2;
		if($obj.attr(configData.GRID_COL_TYPE) == configData.GRID_COL_TYPE_ROWNUM){
			this.selectType = "row";
		}else{
			this.selectType = "";
		}
	},
	selectedEvent : function($obj){
	},
	selectingEvent : function($obj){
		if(this.$box.find(".ui-selecting").length > 0 && this.selectType == ""){
			if(this.$box.find(".ui-selecting:first").attr(configData.GRID_COL_TYPE) == configData.GRID_COL_TYPE_ROWNUM){
				this.selectType = "row";
			}else{
				this.selectType = "cell";
			}
		}
		if(this.selectType == "row"){
			var $rowObj = this.$box.find(".ui-selecting:last").parents("["+configData.GRID_ROW+"]");
			$rowObj.addClass("ui-selected");
		}
	},
	selectArea : function(startRow, startCol, endRow, endCol){		
		if(startRow > endRow){
			var tmpRow = startRow;
			startRow = endRow;
			endRow = tmpRow;
		}
		var startViewRowNum = this.getViewRowNum(startRow);
		var endViewRowNum = this.getViewRowNum(endRow);
		if(startViewRowNum > endViewRowNum){
			var tmpRow = startViewRowNum;
			startViewRowNum = endViewRowNum;
			endViewRowNum = tmpRow;
		}
		
		var startColIndex;
		var endColIndex;
		
		this.$box.find("["+configData.GRID_ROW_NUM+"="+this.focusRowNum+"]").removeClass(configData.GRID_ROW_FOCUS_CLASS);
		
		if(startCol == configData.GRID_COL_TYPE_ROWNUM && endCol == configData.GRID_COL_TYPE_ROWNUM){
			startColIndex = 0;
			endColIndex = this.viewCols.length -1;
			this.selectType = "row";
		}else{			
			for(var i=0;i<this.viewCols.length;i++){
				if(this.viewCols[i] == startCol){
					startColIndex = i;
				}
				if(this.viewCols[i] == endCol){
					endColIndex = i;
				}
			}
			if(startColIndex > endColIndex){
				var tmpNum = startColIndex;
				startColIndex = endColIndex;
				endColIndex = tmpNum;
			}
			this.selectType = "cell";
		}		
		
		this.selectedData = "";
		var rowNum;
		var $rowObj;
		var colValue;
		for(var i=startViewRowNum;i<=endViewRowNum;i++){
			rowNum = this.viewDataList[i];
			$rowObj = this.$box.find("["+configData.GRID_ROW_NUM+"="+rowNum+"]");
			if(this.selectType == "row"){
				$rowObj.addClass("ui-selected");
			}
			
			if(i > startViewRowNum){
				this.selectedData += "\n";
			}
			
			for(var j=startColIndex;j<=endColIndex;j++){
				colValue = this.getColValue(rowNum, this.viewCols[j]);
				if(this.selectType == "cell"){
					$rowObj.find("["+configData.GRID_COL_NAME+"="+this.viewCols[j]+"]").addClass("ui-selected");;
				}
				if(j > startColIndex){
					this.selectedData += "\t";
				}
				this.selectedData += colValue;
			}
		}			
		
		if(this.selectedData){
			//commonUtil.consoleMsg(startViewRowNum+","+endViewRowNum+","+startColIndex+","+endColIndex);
			this.selectedRows = [startViewRowNum, endViewRowNum];
			this.selectedCols = [startColIndex, endColIndex];
			this.selectingType = 1;
			if(window.clipboardData) { // Internet Explorer
				window.clipboardData.setData("Text", this.selectedData);
		    }else{
		    	if(this.copyEventType){
		    		window.prompt("Ctrl+C copy clipboard", this.selectedData);
		    	}
		    }
		}
	},
	getColIndex : function(colName){
		for(var i=0;i<this.viewCols.length;i++){
			if(this.viewCols[i] == colName){
				return i;
			}
		}
		return -1;
	},
	selectEndEvent : function($obj){
		var $rowObj = $obj.parents("["+configData.GRID_ROW+"]");
		if($rowObj.attr(configData.GRID_ROW_TOTAL_ATT)){
			return false;
		}
		var $selected = this.$box.find(".ui-selected");
		var selectCount = $selected.length;
		var startRowNum;
		var endRowNum;
		var startViewRowNum;
		var endViewRowNum;
		var startColIndex;
		var endColIndex;
		if(selectCount > 0){
			this.selectedData = "";
			if(this.selectType == "row"){
				var $selectRow = this.$box.find("["+configData.GRID_COL_TYPE+"="+configData.GRID_COL_TYPE_ROWNUM+"].ui-selected");
				startRowNum = parseInt($selectRow.eq(0).parent().attr(configData.GRID_ROW_NUM));
				endRowNum = parseInt($selectRow.eq($selectRow.length-1).parent().attr(configData.GRID_ROW_NUM));
				startViewRowNum = this.getViewRowNum(startRowNum);
				endViewRowNum = this.getViewRowNum(endRowNum);
				startColIndex = 0;
				endColIndex = this.viewCols.length-1;
				var $rowObj;
				var rowNum;
				var $cols;
				var colName;
				var colValue;
				var colCount;
				for(var i=0;i<$selectRow.length;i++){
					$rowObj = $selectRow.eq(i).parents("["+configData.GRID_ROW+"]");
					rowNum = $rowObj.attr(configData.GRID_ROW_NUM);
					if($rowObj.attr(configData.GRID_ROW_TOTAL_ATT)){
						continue;
					}
					//$cols = $rowObj.find("["+configData.GRID_COL_VALUE+"]");
					$cols = $rowObj.find("["+configData.GRID_COL_NAME+"]");
					if(i > 0){
						this.selectedData += "\n";
					}
					colCount = 0;
					for(var j=0;j<$cols.length;j++){
						//colValue = $cols.eq(j).attr(configData.GRID_COL_VALUE);
						colName = $cols.eq(j).attr(configData.GRID_COL_NAME);
						if(colName == configData.GRID_COL_TYPE_ROWNUM || colName == configData.GRID_COL_TYPE_ROWCHECK){
							continue;
						}
						if(colName == configData.GRID_COL_TYPE_TREE){
							colValue = this.getColValue(rowNum, this.treeText);
						}else{
							colValue = this.getColValue(rowNum, colName);
						}
						
						if(colCount > 0){
							this.selectedData += "\t";
						}
						this.selectedData += colValue;
						colCount++;
					}
				}
			}else{
				var $sColObj = $selected.eq(0);
				var $eColObj = $selected.eq($selected.length-1);
				var sColName = $sColObj.attr(configData.GRID_COL_NAME);
				var eColName = $eColObj.attr(configData.GRID_COL_NAME);
				var $sRowObj = $sColObj.parents("["+configData.GRID_ROW+"]");
				var sRowNum = parseInt($sRowObj.attr(configData.GRID_ROW_NUM));
				var $eRowObj = $eColObj.parents("["+configData.GRID_ROW+"]");
				var eRowNum = parseInt($eRowObj.attr(configData.GRID_ROW_NUM));
				
				//startRowNum = parseInt($sRowObj.attr(configData.GRID_ROW_VIEWNUM));
				//endRowNum = parseInt($eRowObj.attr(configData.GRID_ROW_VIEWNUM));
				//startViewRowNum = this.getViewRowNum(startRowNum);
				//endViewRowNum = this.getViewRowNum(endRowNum);
				startViewRowNum = this.getViewRowNum(sRowNum);
				endViewRowNum = this.getViewRowNum(eRowNum);
				startColIndex = this.getColIndex(sColName);
				endColIndex = this.getColIndex(eColName);
				
				var sRowCount = endViewRowNum - startViewRowNum + 1;
				var sColCount = selectCount / sRowCount;
				
				this.selectedData = "";
				var dataCount = 0;
				var colName;
				var colValue;
				var rowNum;
				for(var i=0;i<sRowCount;i++){
					if(i > 0){
						this.selectedData += "\n";
					}
					for(var j=0;j<sColCount;j++){
						//colValue = $selected.eq(dataCount).attr(configData.GRID_COL_VALUE);
						colName = $selected.eq(dataCount).attr(configData.GRID_COL_NAME);
						rowNum = this.getRowNum(startViewRowNum+i);
						if(colName == configData.GRID_COL_TYPE_TREE){
							colValue = this.getColValue(rowNum, this.treeText);
						}else{
							colValue = this.getColValue(rowNum, colName);
						}
						
						if(j > 0){
							this.selectedData += "\t";
						}
						this.selectedData += colValue;
						dataCount++;
					}
				}
			}
			
			if(this.selectedData){
				//commonUtil.consoleMsg(startViewRowNum+","+endViewRowNum+","+startColIndex+","+endColIndex);
				this.selectedRows = [startViewRowNum,endViewRowNum];
				this.selectedCols = [startColIndex, endColIndex];
				//this.selectingType--;
				if(window.clipboardData) { // Internet Explorer
					window.clipboardData.setData("Text", this.selectedData);
			    }else{
			    	if(this.copyEventType){
			    		window.prompt("Ctrl+C copy clipboard", this.selectedData);
			    	}
			    }
			}
		}
	},
	resetSelected : function(){		
		//this.$box.selectable("refresh");
		this.selectType = "";
		this.selectedData = "";
		this.selectedRows = null;
		this.selectedCols = null;
		this.$box.find(".ui-selected").removeClass("ui-selected");
	},
	setGrid : function(){
		if(this.actionMap){
			var colList = this.$box.find(this.rowTagName+" > "+this.colTagName);
			var attList;
			var removeType;
			var aCode;
			for(var i=colList.length-1;i>0;i--){
				attList = colList.eq(i).attr(configData.GRID_COL).split(",");
				if(attList.length > 1){
					if(this.actionMap[attList[1]]){
						aCode = this.actionMap[attList[1]];
						if(aCode.substring(0,1) == "!"){
							aCode = aCode.substring(1);
							removeType = uiList.actionMap.containsKey(aCode);
						}else{
							removeType = !uiList.actionMap.containsKey(aCode)
						}
						if(removeType){
							this.$gridHead.find(this.headColgroupTagName+" > "+this.headColattTagName+":eq("+i+")").remove();
							this.$gridHead.find(this.headRowTagName+" > "+this.headColTagName+":eq("+i+")").remove();
							this.$gridBody.find(this.colgroupTagName+" > "+this.colattTagName+":eq("+i+")").remove();
							this.$box.find(this.rowTagName+" > "+this.colTagName+":eq("+i+")").remove();
						}
					}
				}
			}
		}
		
		if(this.checkBoxHtml){
			theme.GRID_EDIT_CHECKBOX_HTML = this.checkBoxHtml;
			
		}
		if(!this.bigdata || !this.dataRequest){
			this.bigdata = false;
			this.dataRequest = false;
		}		
		
		if(this.pkcol){
			var pklist = this.pkcol.split(",");
			for(var i=0;i<pklist.length;i++){
				this.pkcolMap.put(pklist[i],true);
			}
			if(this.pkcheck){
				this.duplicationList.push(this.pkcol);
			}
		}
		
		if(this.pageCount){
			this.bigdata = false;
			this.sortType = false;
		}
		
		if(this.scrollPageCount || this.appendPageCount){
			this.sortType = true;
			this.scrollType = true;
			this.setScroll();
			this.setInfo();
		}
		
		var gridBox = this;
		
		if(this.tree){
			this.bigdata = false;
			this.sortType = false;
			this.appendRow = true;
			this.maxViewDataCell = 1000000000;
		}
		
		if(this.colGroupCols){
			this.colGroupCols = this.colGroupCols.split(",");
		}
		
		if(this.sortableCols){
			this.sortableCols = this.sortableCols.split(",");
			this.sortableColMap = new DataMap();
			for(var i=0;i<this.sortableCols.length;i++){
				this.sortableColMap.put(this.sortableCols[i], true);
			}
		}
		
		this.$box.attr(configData.GRID_BOX, "true");
		//this.$box.attr(configData.GRID_ROW_NUM, "0");		
		
		this.$box.keydown(function(event){
			var $obj = $(event.target);
			gridBox.keydownEvent(event);
		});
		
		if (!(Browser.ie6) && !(Browser.ie7) && !(Browser.ie8)) {
			this.$box.mouseover(function(event){
				var $obj = $(event.target);
				gridBox.mouseoverEvent($obj);					
			});
			
			this.$box.mouseout(function(event){
				var $obj = $(event.target);
				gridBox.mouseoutEvent($obj);					
			});
		}		
		
		if(this.itemGrid){
			this.itemGridList = this.itemGrid.split(",");
		}
		
		if(this.headGrid){
			this.$headGrid = gridList.gridMap.get(this.headGrid);
		}
		
		this.$box.click(function(event){
			var $obj = $(event.target);
			gridBox.clickEvent($obj, event);					
		});
		
		this.$box.dblclick(function(event){
			var $obj = $(event.target);
			gridBox.dbclickEvent($obj);
		});
		
		this.$gridHead.contextmenu(function(event) {
			var $obj = $(event.target);
			return false;
		});
		
		this.$box.contextmenu(function(event) {
			var $obj = $(event.target);
			return false;
		});
		
		var $dataRow = this.$box.find("["+configData.GRID_ROW+"]");
		
		if($dataRow.length){
			$dataRow.css("height",this.rowHeight+"px");
			$dataRow.attr(configData.GRID_ROW_NUM, configData.GRID_COL_DATA_NAME_ROWNUM);
			//$dataRow.attr(configData.GRID_ROW_VIEWNUM, configData.GRID_COL_DATA_NAME_ROWVIEWNUM);
			
			$dataRow.addClass(configData.GRID_COL_DATA_NAME_ROW_SELECT_CLASS_HEAD);
			$dataRow.addClass(configData.GRID_COL_DATA_NAME_ROW_FOCUS_CLASS_HEAD);
			if(this.colorType){
				$dataRow.addClass(configData.GRID_COLOR_ROW_TEXT_CLASS_HEAD);
				$dataRow.addClass(configData.GRID_COLOR_ROW_BG_CLASS_HEAD);
			}
			
			gridBox.$rows = $dataRow;
			
			$dataRow.find("["+ configData.GRID_COL +"]").each(function(i, findElement){
				var $obj = jQuery(findElement);
				var tmpAtt = $obj.attr(configData.GRID_COL);
				var attList = tmpAtt.split(",");
				
				gridBox.colTypeMap.put(attList[1], tmpAtt);
				
				$obj.attr(configData.GRID_COL_TYPE, attList[0]);
				
				if(attList.length > 1){
					$obj.attr(configData.GRID_COL_NAME, attList[1]);
				}
				
				if(gridBox.colorType){
					var colName;
					if(attList[0] == configData.GRID_COL_TYPE_ROWNUM || attList[0] == configData.GRID_COL_TYPE_ROWCHECK){
						colName = attList[0];
					}else{
						colName = attList[1];
					}
					var tmpClass = configData.GRID_COLOR_COL_TEXT_CLASS_HEAD+colName;
					tmpClass = tmpClass.toLowerCase()
					$obj.addClass(tmpClass);
					tmpClass = configData.GRID_COLOR_COL_BG_CLASS_HEAD+colName;
					tmpClass = tmpClass.toLowerCase()
					$obj.addClass(tmpClass);
				}
				
				var viewText;
				
				var validateAtt = $obj.attr(configData.VALIDATION_ATT);
				
				var formatAtt = $obj.attr(configData.GRID_COL_FORMAT);
				if(formatAtt){
					var formatList = formatAtt.split(" ");
					if(formatList[0] == configData.INPUT_FORMAT_NUMBER){
						$obj.addClass(configData.GRID_COL_TYPE_INPUT_NUMBER_CLASS);
						gridBox.totalColsMap.put(attList[1], true);
					}
						
					if((attList[0] == configData.GRID_COL_TYPE_INPUT || attList[0] == configData.GRID_COL_TYPE_ADD) 
							&& (formatList[0] == configData.INPUT_FORMAT_DATE || formatList[0] == configData.INPUT_FORMAT_CALENDER)){
						if(validateAtt && validateAtt.indexOf(configData.VALIDATION_DATE) == -1){
							validateAtt += " "+configData.VALIDATION_DATE;
						}else{
							validateAtt = configData.VALIDATION_DATE;
						}
					}
					
					// 2019.03.07 jw : : Input Data Type Month Added
					if((attList[0] == configData.GRID_COL_TYPE_INPUT || attList[0] == configData.GRID_COL_TYPE_ADD) 
							&& (formatList[0] == configData.INPUT_FORMAT_DATE_MONTH || formatList[0] == configData.INPUT_FORMAT_CALENDER_MONTH)){
						if(validateAtt && validateAtt.indexOf(configData.VALIDATION_DATE_MONTH) == -1){
							validateAtt += " "+configData.VALIDATION_DATE_MONTH;
						}else{
							validateAtt = configData.VALIDATION_DATE_MONTH;
						}
					}
					
					gridBox.colFormatMap.put(attList[1], formatList);
					viewText = configData.GRID_COL_DATA_NAME_VIEW_HEAD+attList[1]+configData.GRID_COL_DATA_NAME_TAIL;
				}
				
				if(validateAtt){
					gridBox.validationMap.put(attList[1], validateAtt);
				}
				
				var colHeadAtt = $obj.attr(configData.GRID_COL_VALUE_HEAD);
				if(colHeadAtt){
					colHeadAtt = uiList.getLabel(colHeadAtt);
					gridBox.colHeadMap.put(attList[1], colHeadAtt);
				}
				var colTailAtt = $obj.attr(configData.GRID_COL_VALUE_TAIL);
				if(colTailAtt){
					colTailAtt = uiList.getLabel(colTailAtt);
					gridBox.colTailMap.put(attList[1], colTailAtt);
				}
				
				if(attList[0] == configData.GRID_COL_TYPE_ROWNUM){
					$obj.text(configData.GRID_COL_DATA_NAME_ROWVIEW);
					$obj.attr(configData.GRID_COL_NAME, attList[0]);
					
					$obj.addClass(configData.GRID_ROWNUM_CLASS);
					$obj.addClass(configData.GRID_COL_TYPE_OBJECT_CLASS);
					gridBox.rowNumType = true;
				}else if(attList[0] == configData.GRID_COL_TYPE_BTN){
					$obj.addClass(configData.GRID_COL_DATA_NAME_READONLY_CLASS_HEAD+attList[1]);
					var bCode = $obj.attr(configData.GRID_COL_BUTTON).split(" ");
					var btnName = bCode[0];
					var bType = bCode[1];
					var lCode = bCode[2];
					var iconClass = configData.BUTTON_ICON.get(bType);
					var labelTxt = uiList.getLabel(lCode);
					var titleTxt = labelTxt;
					var valTxt = configData.GRID_COL_DATA_NAME_HEAD+attList[1]+configData.GRID_COL_DATA_NAME_TAIL;
					var btnHtml = "<button type='button' class='"+configData.BUTTON_CLASS+" "+configData.GRID_COL_TYPE_BTN_CLASS+valTxt+"' "
								+ " onclick='gridList.btnClick(\""+gridBox.id+"\",this)' >"
								+ "<span class='"+configData.BUTTON_ICON_CLASS+" "+iconClass+"'>Icon</span>"
								+ "<span class='"+configData.BUTTON_TEXT_CLASS+"'>"+labelTxt+"</span>"
								+ "</button>";
					var $btnObj = jQuery(btnHtml);
					$btnObj.attr(configData.GRID_COL_DATA_NAME_DISABLE_OBJECT_HEAD+attList[0]+configData.GRID_COL_DATA_NAME_ATT_TAIL, '');
					$btnObj.attr(configData.GRID_COL_TYPE_BTN_ROWNUM_ATT, configData.GRID_COL_DATA_NAME_ROWNUM);
					$btnObj.attr(configData.GRID_COL_TYPE_BTN_NAME_ATT, btnName);
					$btnObj.attr("title", titleTxt);
					
					$obj.append($btnObj);
					/* 김호영 2019-04-04 */
				}else if(attList[0] == configData.GRID_COL_TYPE_BTN2){
						$obj.addClass(configData.GRID_COL_DATA_NAME_READONLY_CLASS_HEAD+attList[1]);
						var bCode = $obj.attr(configData.GRID_COL_BUTTON).split(" ");
						//사용자 정의 클라스를 가져온다.
						var btnName = bCode[0];
						var bType = bCode[1];
						var lCode = bCode[2];
						
						var labelTxt = uiList.getLabel(lCode);
						var titleTxt = labelTxt;
						var valTxt = configData.GRID_COL_DATA_NAME_HEAD+attList[1]+configData.GRID_COL_DATA_NAME_TAIL;
						var btnHtml = "<button type='button' "
									+ " onclick='gridList.btnClick(\""+gridBox.id+"\",this)' >"
									+ "<span class='"+bType+"'>Icon</span>"
									+ "</button>";
						var $btnObj = jQuery(btnHtml);
						$btnObj.attr(configData.GRID_COL_DATA_NAME_DISABLE_OBJECT_HEAD+attList[0]+configData.GRID_COL_DATA_NAME_ATT_TAIL, '');
						$btnObj.attr(configData.GRID_COL_TYPE_BTN_ROWNUM_ATT, configData.GRID_COL_DATA_NAME_ROWNUM);
						$btnObj.attr(configData.GRID_COL_TYPE_BTN_NAME_ATT, btnName);
						$btnObj.attr("title", titleTxt);
						
						$obj.append($btnObj);
						/* 김호영 2019-04-04 */
				}else if(attList[0] == configData.GRID_COL_TYPE_ICON){
					/* 이범준 2019-04-05 : Icon 이미지 넣기*/
					$obj.addClass(configData.GRID_COL_DATA_NAME_READONLY_CLASS_HEAD+attList[1]);
					var bCode = $obj.attr(configData.GRID_COL_BUTTON).split(" ");
					var iconType = bCode[0];
				    var icon = '<div class="gridIcon-center">'
							 + '<span class="'+iconType+'">Icon</span>'
							 + '</div>';
					var $iconObj = jQuery(icon);
					
					gridBox.gridIconMap.put(gridBox.id,icon);
					
					$obj.append($iconObj);
			}else if(attList[0] == configData.GRID_COL_TYPE_INPUT){
					$obj.addClass(configData.GRID_COL_DATA_NAME_MODIFY_COL_HEAD+attList[1]);
					$obj.addClass(configData.GRID_COL_DATA_NAME_READONLY_CLASS_HEAD+attList[1]);
					gridBox.editableCols.push(attList[1]);
					gridBox.editableColMap.put(attList[1], configData.GRID_COL_TYPE_INPUT);
					//$obj.attr(configData.GRID_COL_VALUE, configData.GRID_COL_DATA_NAME_HEAD+attList[1]+configData.GRID_COL_DATA_NAME_TAIL);
					if(!viewText){
						viewText = configData.GRID_COL_DATA_NAME_HEAD+attList[1]+configData.GRID_COL_DATA_NAME_TAIL;
					}
					//$obj.text(configData.GRID_COL_DATA_NAME_HEAD+attList[1]+configData.GRID_COL_DATA_NAME_TAIL);
					if(gridBox.pkcolMap.containsKey(attList[1])){
						$obj.attr(configData.GRID_COL_TYPE_PK, attList[1]);
						//$obj.text(configData.GRID_COL_DATA_NAME_HEAD+attList[1]+configData.GRID_COL_DATA_NAME_TAIL);
						$obj.addClass(configData.GRID_COL_TYPE_TEXT_CLASS);
						$obj.attr(configData.GRID_COL_TYPE, configData.GRID_COL_TYPE_TEXT);
					}else{
						//$obj.text(configData.GRID_COL_DATA_NAME_HEAD+attList[1]+configData.GRID_COL_DATA_NAME_TAIL);
						$obj.addClass(configData.GRID_COL_TYPE_INPUT_TEXT_CLASS);
						$obj.addClass(configData.GRID_EDIT_BACK_CLASS);
					}
					
					if(attList[2]){
						gridBox.colSearchMap.put(attList[1], attList[2]);
					}
					if(attList[3]){
						gridBox.colSearchMultiMap.put(attList[1], true);
					}
					gridBox.inputCols.put(attList[1], true);
					
					var autoCompleteAtt = $obj.attr(configData.INPUT_AUTOCOMPLETE_NAME);
					if(autoCompleteAtt){
						gridBox.autoCompletMap.put(attList[1], autoCompleteAtt);
					}
				}else if(attList[0] == configData.GRID_COL_TYPE_ADD){
					$obj.addClass(configData.GRID_COL_DATA_NAME_MODIFY_COL_HEAD+attList[1]);
					$obj.addClass(configData.GRID_COL_DATA_NAME_READONLY_CLASS_HEAD+attList[1]);
					gridBox.editableCols.push(attList[1]);
					gridBox.editableColMap.put(attList[1], configData.GRID_COL_TYPE_ADD);
					//$obj.attr(configData.GRID_COL_VALUE, configData.GRID_COL_DATA_NAME_HEAD+attList[1]+configData.GRID_COL_DATA_NAME_TAIL);
					if(!viewText){
						viewText = configData.GRID_COL_DATA_NAME_HEAD+attList[1]+configData.GRID_COL_DATA_NAME_TAIL;
					}
					$obj.attr(configData.GRID_COL_TYPE_PK, attList[1]);
					$obj.addClass(configData.GRID_COL_TYPE_TEXT_CLASS);
					$obj.attr(configData.GRID_COL_TYPE, configData.GRID_COL_TYPE_TEXT);
					
					if(attList[2]){
						gridBox.colSearchMap.put(attList[1], attList[2]);
					}
					gridBox.addcolMap.put(attList[1],attList[1]);
				}else if(attList[0] == configData.GRID_COL_TYPE_DELETE){
					$obj.html(theme.getGridDeleteBtn(gridBox));
					$obj.attr(configData.GRID_COL_NAME, attList[0]);
				}else if(attList[0] == configData.GRID_COL_TYPE_ROWCHECK){
					//$obj.attr(configData.GRID_COL_VALUE, site.emptyValue);
					$obj.addClass(configData.GRID_COL_DATA_NAME_READONLY_CLASS_HEAD+attList[0]);
					$obj.addClass(configData.GRID_EDIT_BACK_CLASS);
					$obj.attr(configData.GRID_COL_NAME, attList[0]);
					
					var $check = gridBox.createCheckObj();
					$check.attr(configData.GRID_COL_DATA_NAME_ROWCHECK_HEAD, '');
					//$check.attr(configData.GRID_COL_TYPE,configData.GRID_COL_TYPE_ROWCHECK);
					if(attList[1]){
						$check.attr(configData.GRID_COL_CHECK_RADIO, "true");
						gridBox.$gridHead.find("["+configData.GRID_BTN_CHECK_ATT+"]").removeAttr(configData.GRID_BTN_CHECK_ATT);
					}
					$check.attr(configData.GRID_COL_DATA_NAME_CHECK_HEAD+attList[0]+configData.GRID_COL_DATA_NAME_ATT_TAIL, '');
					$check.attr(configData.GRID_COL_DATA_NAME_DISABLE_OBJECT_HEAD+attList[0]+configData.GRID_COL_DATA_NAME_ATT_TAIL, '');
					
					$obj.html($check);
					$obj.addClass(configData.GRID_COL_TYPE_OBJECT_CLASS);
					
					var tempRowCheckText = $obj.html();
					gridBox.rowCheckText.put(gridBox.id,tempRowCheckText);

					gridBox.rowCheckType = true;
				}else if(attList[0] == configData.GRID_COL_TYPE_CHECKBOX){
					$obj.addClass(configData.GRID_COL_DATA_NAME_MODIFY_COL_HEAD+attList[1]);
					$obj.addClass(configData.GRID_COL_DATA_NAME_READONLY_CLASS_HEAD+attList[1]);
					$obj.addClass(configData.GRID_EDIT_BACK_CLASS);
					
					//gridBox.checkBox.put(attList[1],"true");					
					
					//$obj.attr(configData.GRID_COL_VALUE, configData.GRID_COL_DATA_NAME_HEAD+attList[1]+configData.GRID_COL_DATA_NAME_TAIL);
					
					gridBox.editableCols.push(attList[1]);
					gridBox.editableColMap.put(attList[1], configData.GRID_COL_TYPE_CHECKBOX);
					var $check = jQuery(theme.GRID_EDIT_CHECKBOX_HTML);
					$check.attr("value", site.defaultCheckValue);
					$check.attr("name", attList[1]);
					$check.attr(configData.GRID_COL_DATA_NAME_CHECK_HEAD+attList[1]+configData.GRID_COL_DATA_NAME_ATT_TAIL, '');					
					//$check.attr(configData.GRID_COL_DATA_NAME_READONLY_HEAD+attList[1], '');
					$check.attr(configData.GRID_COL_DATA_NAME_DISABLE_OBJECT_HEAD+attList[1]+configData.GRID_COL_DATA_NAME_ATT_TAIL, '');
					
					if(attList[2]){
						$check.attr(configData.GRID_COL_CHECK_RADIO, "true");
					}
					$obj.html($check);
					$obj.addClass(configData.GRID_COL_TYPE_OBJECT_CLASS);
					
					gridBox.checkCols.put(attList[1], true);
				}else if(attList[0] == configData.GRID_COL_TYPE_SELECT){
					$obj.addClass(configData.GRID_COL_DATA_NAME_MODIFY_COL_HEAD+attList[1]);
					$obj.addClass(configData.GRID_COL_DATA_NAME_READONLY_CLASS_HEAD+attList[1]);
					$obj.addClass(configData.GRID_EDIT_BACK_CLASS);
					
					//$obj.attr(configData.GRID_COL_VALUE, configData.GRID_COL_DATA_NAME_HEAD+attList[1]+configData.GRID_COL_DATA_NAME_TAIL);
					gridBox.editableCols.push(attList[1]);
					gridBox.editableColMap.put(attList[1], configData.GRID_COL_TYPE_SELECT);
					
					var $select = $obj.find("select");
					$select.attr("value", configData.GRID_COL_DATA_NAME_HEAD+attList[1]+configData.GRID_COL_DATA_NAME_TAIL);
					$select.css("width","100%");
					$select.css("height","100%");
					//$select.attr(configData.GRID_COL_DATA_NAME_READONLY_HEAD+attList[1], '');
					$select.attr(configData.GRID_COL_DATA_NAME_DISABLE_OBJECT_HEAD+attList[1]+configData.GRID_COL_DATA_NAME_ATT_TAIL, '');
					
					var comboValueMap = new DataMap();
					$select.find("option").each(function(i, findElement){
						var $optionObj = jQuery(findElement);
						var tmpValue = $optionObj.attr("value");
						if(tmpValue){
							tmpValue = jQuery.trim(tmpValue);
						}else{
							tmpValue = "";
						}
						comboValueMap.put(tmpValue, $optionObj.text());
						try{
							$optionObj.attr(configData.GRID_COL_DATA_NAME_OPTION_HEAD+attList[1]+tmpValue+configData.GRID_COL_DATA_NAME_ATT_TAIL, '');
						}catch(e){}						
					});
					gridBox.comboDataMap.put(attList[1], comboValueMap);
					
					var comboType;
					var comboOption = $select.attr(configData.INPUT_COMMON_COMBO);
					if(comboOption){
						comboType = configData.INPUT_COMMON_COMBO;
					}else{
						comboOption = $select.attr(configData.INPUT_REASON_COMBO);
						if(comboOption){
							comboType = configData.INPUT_REASON_COMBO;
						}else{
							comboOption = $select.attr(configData.INPUT_COMBO);
							if(comboOption){
								comboType = configData.INPUT_COMBO;
							}
						}
					}
					
					if(comboOption){
						var comboMap = new DataMap();
						comboMap.put(configData.GRID_COL_NAME, attList[1]);
						comboMap.put(configData.INPUT_COMBO_TYPE, comboType);
						comboMap.put(configData.INPUT_COMBO_OPTION, comboOption);
						gridBox.comboList.push(comboMap);
					}
					
					if(gridBox.pkcolMap.containsKey(attList[1])){						
						$select.attr("disabled","disabled");
						$select.addClass(configData.GRID_COL_TYPE_DISABLE_CLASS);
						$obj.attr(configData.GRID_COL_TYPE_PK, attList[1]);
					}
					
					if(attList[2]){
						//$obj.attr(configData.GRID_COL_GROUP_KEY,attList[2]);
						//$obj.attr(configData.GRID_COL_GROUP,configData.GRID_COL_DATA_NAME_HEAD+attList[2]+configData.GRID_COL_DATA_NAME_TAIL);
						//$select.find("["+configData.INPUT_COMBO_OPTION_GROUP+"]").remove();
						var $tmpOptions = $select.find("option");
						for(var k=0;k<$tmpOptions.length;k++){
							if(!$tmpOptions.eq(k).attr(configData.INPUT_COMBO_OPTION_GROUP)){
								$tmpOptions.eq(k).attr(configData.INPUT_COMBO_OPTION_GROUP,configData.INPUT_COMBO_OPTION_GROUP);
							}
						}
						viewText = configData.GRID_COL_DATA_NAME_GROUPSELECT_HEAD+attList[1]+configData.GRID_COL_DATA_NAME_TAIL;
						$obj.html();
						gridBox.selectGroupCols.put(attList[1], attList[2]);
					}
					
					gridBox.selectCols.put(attList[1], $select);
				}else if(attList[0] == configData.GRID_COL_TYPE_TEXT){
					//$obj.attr(configData.GRID_COL_VALUE, configData.GRID_COL_DATA_NAME_HEAD+attList[1]+configData.GRID_COL_DATA_NAME_TAIL);
					if(!viewText){
						viewText = configData.GRID_COL_DATA_NAME_HEAD+attList[1]+configData.GRID_COL_DATA_NAME_TAIL;
					}
					//$obj.text(configData.GRID_COL_DATA_NAME_HEAD+attList[1]+configData.GRID_COL_DATA_NAME_TAIL);
					$obj.removeAttr(configData.GRID_COL);
					//$obj.removeAttr(configData.GRID_COL_TYPE);
					$obj.attr(configData.GRID_COL_TYPE, configData.GRID_COL_TYPE_TEXT);

					if(attList[2]){
						if(attList[2] == "center"){
							$obj.addClass(configData.GRID_COL_TYPE_TEXT_CENTER_CLASS);
						}else if(attList[2] == "right"){
							$obj.addClass(configData.GRID_COL_TYPE_TEXT_RIGHT_CLASS);
						}						
					}else{
						$obj.addClass(configData.GRID_COL_TYPE_TEXT_CLASS);
					}
				}else if(attList[0] == configData.GRID_COL_TYPE_TREE){
					$obj.attr(configData.GRID_COL_NAME, attList[0]);
					if(gridBox.tree){
						var treeData = gridBox.tree.split(",");
						gridBox.treeId = treeData[3];
						gridBox.treeText = treeData[1];
						gridBox.treeLvl = treeData[0];
						gridBox.treePid = treeData[2];
						gridBox.treeSeq = treeData[4];
						//$obj.attr(configData.GRID_COL_VALUE, configData.GRID_COL_DATA_NAME_HEAD+gridBox.treeId+configData.GRID_COL_DATA_NAME_TAIL);
						var tmpHtml = "<span "+configData.GRID_COL_TYPE_TREE_ICON_ATT+"='true' class='"+configData.GRID_COL_TYPE_TREE_LVL_CLASS+configData.GRID_COL_DATA_NAME_HEAD+gridBox.treeLvl+configData.GRID_COL_DATA_NAME_TAIL+"'>"
										+ configData.GRID_COL_DATA_NAME_HEAD+configData.GRID_COL_TYPE_TREE+configData.GRID_COL_DATA_NAME_TAIL +"</span>"
										+ "<span "+configData.GRID_COL_TYPE_TREE_TEXT_ATT+"='true' >"+configData.GRID_COL_DATA_NAME_HEAD+gridBox.treeText+configData.GRID_COL_DATA_NAME_TAIL+"</span>";
						$obj.html(tmpHtml);
					}					
				}else if(attList[0] == configData.GRID_COL_TYPE_HTML){
					//$obj.attr(configData.GRID_COL_VALUE, configData.GRID_COL_DATA_NAME_HEAD+attList[1]+configData.GRID_COL_DATA_NAME_TAIL);
					$obj.addClass(configData.GRID_COL_DATA_NAME_READONLY_CLASS_HEAD+attList[1]);
					$obj.removeAttr(configData.GRID_COL);
					$obj.attr(configData.GRID_COL_TYPE, configData.GRID_COL_TYPE_HTML);

					gridBox.colHtmlMap.put(attList[1], $obj.html());
				}else if(attList[0] == configData.GRID_COL_TYPE_FUNCTION){
					//$obj.attr(configData.GRID_COL_VALUE, configData.GRID_COL_DATA_NAME_HEAD+attList[1]+configData.GRID_COL_DATA_NAME_TAIL);
					$obj.addClass(configData.GRID_COL_DATA_NAME_READONLY_CLASS_HEAD+attList[1]);
					$obj.removeAttr(configData.GRID_COL);
					$obj.attr(configData.GRID_COL_TYPE, configData.GRID_COL_TYPE_FUNCTION);

					if(!viewText){
						viewText = configData.GRID_COL_DATA_NAME_HEAD+attList[1]+configData.GRID_COL_DATA_NAME_TAIL;
					}
					
					gridBox.colFunctionMap.put(attList[1], attList[2]);
				}else if(attList[0] == configData.GRID_COL_TYPE_FILE || attList[0] == configData.GRID_COL_TYPE_FILE_DOWNLOAD){ // 2019.03.20 jw : Grid Data Type FileDownload Added
					$obj.addClass(configData.GRID_COL_DATA_NAME_READONLY_CLASS_HEAD+attList[1]);
					gridBox.editableCols.push(attList[1]);
					gridBox.editableColMap.put(attList[1], configData.GRID_COL_TYPE_FILE);
					var tmpFileType;
					if(attList[2]){
						tmpFileType = attList[2];
					}else{
						tmpFileType = "single";
					}
					
					if(attList.length > 2){
						tmpFileType = attList[2];
					}
					//2019.02.19 프로젝트수정
					/*var tmpHtml = "<span class='btn_delY' fileType='"+tmpFileType+"'>"
								+configData.GRID_COL_DATA_NAME_HEAD+attList[1]+configData.GRID_COL_TYPE_FILE_TAIL+configData.GRID_COL_DATA_NAME_TAIL+"</span>";*/
					
					var tmpHtml = "<div class='btn_delY' fileType='"+tmpFileType+"'>"
					              +configData.GRID_COL_DATA_NAME_HEAD+attList[1]+configData.GRID_COL_TYPE_FILE_TAIL+configData.GRID_COL_DATA_NAME_TAIL+"</span></div>";
					
					if(attList[0] == configData.GRID_COL_TYPE_FILE){ // 2019.03.20 jw : Grid Data Type FileDownload Added
						tmpHtml += "<button type='button' class='fileType' title='file upload'><img src='/common/images/"+configData.BUTTON_ICON.get(configData.BUTTON_TYPE_GRID_FILE)+".png'></button>";
					}
					
					$obj.html(tmpHtml);
					$obj.addClass(configData.GRID_COL_TYPE_TEXT_CENTER_CLASS);
				}else if(attList[0] == configData.GRID_COL_TYPE_FILE_SIZE){
					var tmpHtml = "<div>"+configData.GRID_COL_DATA_NAME_HEAD+attList[1]+configData.GRID_COL_TYPE_FILE_SIZE_TAIL+configData.GRID_COL_DATA_NAME_TAIL+"</span></div>";
					
					$obj.html(tmpHtml);
					$obj.addClass(configData.GRID_COL_TYPE_TEXT_CENTER_CLASS);
				}
				
				if(gridBox.tree){
					$obj.attr(configData.GRID_COL_VALUE, configData.GRID_COL_DATA_NAME_HEAD+attList[1]+configData.GRID_COL_DATA_NAME_TAIL);
				}
				
				if(viewText){
					$obj.text(viewText);
				}
			});
			
			var tmpHtml = $dataRow.clone().wrapAll("<div/>").parent().html();
			
			tmpHtml = gridBox.getRowHtml(tmpHtml);
			
			gridBox.rowHtml = tmpHtml;

			gridBox.rowNewHtml = gridBox.getRowNewHtml(tmpHtml);
		}
		
		if(gridBox.totalCols){
			gridBox.totalColsMap = new DataMap();
			for(var i=0;i<gridBox.totalCols.length;i++){
				gridBox.totalColsMap.put(gridBox.totalCols[i], true);
			}
		}
		
		gridBox.$dataRow = $dataRow.clone();
		
		$dataRow.remove();		
		
		if(this.bindArea){	
			this.$area = jQuery("#"+this.bindArea);			
			this.$area.attr(configData.GRID_BIND_AREA_ATT, this.id);
			this.$area.find("input,select,textarea").each(function(i, findElement){
				var $bindObj = jQuery(findElement);
				
				$bindObj.change(function(event){
					var $obj = $(event.target);
					var objName = $obj.attr("name");			
					
					if(gridBox.focusRowNum != -1){
						//var $focusRow = gridBox.$box.find("["+configData.GRID_ROW_NUM+"="+gridBox.focusRowNum+"]");
						var colValue = $obj.val();
						if($obj.attr("type") == "checkbox" && !$obj.prop("checked")){
							colValue = site.emptyValue;
						}
						gridBox.setColValue(gridBox.focusRowNum, objName, colValue);
					}
				});
			});
			this.$navBtnGroup = this.$area.find("["+configData.GRID_NAV_BTN_ATT+"="+this.id+"]");
			if(this.$navBtnGroup.length > 0){
				var $btns = this.$navBtnGroup.find("a");
				$btns.eq(0).click(function(event){
					var $obj = jQuery(event.target);
					var tmpFocus = gridBox.getFocusRowNum();
					gridBox.firstRowFocus();
					if(commonUtil.checkFn("gridNaviFocusChange")){
						if(tmpFocus != gridBox.getFocusRowNum()){
							gridNaviFocusChange(gridBox.id);
						}
					}
				});
				
				$btns.eq(1).click(function(event){
					var $obj = jQuery(event.target);
					var tmpFocus = gridBox.getFocusRowNum();
					gridBox.preRowFocus();
					if(commonUtil.checkFn("gridNaviFocusChange")){
						if(tmpFocus != gridBox.getFocusRowNum()){
							gridNaviFocusChange(gridBox.id);
						}
					}
				});
				
				$btns.eq(2).click(function(event){
					var $obj = jQuery(event.target);
					var tmpFocus = gridBox.getFocusRowNum();
					gridBox.nextRowFocus();
					if(commonUtil.checkFn("gridNaviFocusChange")){
						if(tmpFocus != gridBox.getFocusRowNum()){
							gridNaviFocusChange(gridBox.id);
						}
					}
				});
				
				$btns.eq(3).click(function(event){
					var $obj = jQuery(event.target);
					var tmpFocus = gridBox.getFocusRowNum();
					gridBox.lastRowFocus();
					if(commonUtil.checkFn("gridNaviFocusChange")){
						if(tmpFocus != gridBox.getFocusRowNum()){
							gridNaviFocusChange(gridBox.id);
						}
					}
				});
			}
		}
		
		if(this.gridMobileType){
			this.gridHeadType = false;
			this.gridBottomType = true;
			this.gridScrollType = false;
			this.bigdata = false;
			this.dataRequest = false;
			this.sortType = false;
			this.setMobileHead();
			
			this.$bodyBox = this.$box.parents("div");
			/*
			this.$bodyBox.scroll(function(event){
				var tmpLeft = gridBox.$bodyBox.scrollLeft();
				if(gridBox.scrollLeft != tmpLeft){
					var tmpMargin = "-"+tmpLeft+"px";
					gridBox.scrollLeft = tmpLeft;
					if(gridBox.$gridHead.length > 0){
						gridBox.$gridHead.css({
							"margin-left" : tmpMargin
						});
					}
				}
			});
			*/
		}
		
		if(this.tree){
			this.modifyRowCheck = false;
			this.selectRowDeleteType = false;
		}
		
		if(this.rowCheckType == false){
			this.selectRowDeleteType = false;
		}
		
		if(this.gridBottomType){
			this.setBottom();
			this.setInfo();
		}
		
		if(this.gridScrollType){
			this.setHeight();
		}
		
		if(this.gridHeadType){
			this.setHead();
		}
		
		if ((Browser.ie6) || (Browser.ie7) || (Browser.ie8)) {

		}else if(!this.gridMobileType){
			this.$box.selectable({
				  delay: 150,
				  filter: "td",
				  selected: function( event, ui ) {
					  var $obj = $(event.target);
					  gridBox.selectedEvent($obj);
				  },
				  selecting: function( event, ui ) {
					  var $obj = $(event.target);
					  gridBox.selectingEvent($obj);
				  },
				  start: function( event, ui ) {
					  var $obj = $(event.target);
					  gridBox.selectStartEvent($obj);				  
				  },
				  stop: function( event, ui ) {
					  var $obj = $(event.target);
					  gridBox.selectEndEvent($obj);		  
				  }
			});
		}
		
		/*2019.02.27 이범준 [IE에서 데이터가 Grid에 바인드 될 동안 스크롤 인벤트를 딜레이 시텨 좀 더 유연하게 스크롤링 되도록 하는 로직을 추가 ]*/
		if((Browser.ie || Browser.ie6 || Browser.ie7 || Browser.ie8 || Browser.ie9 || Browser.ie10 || Browser.ie11)){
			$.fn.scrollStopped = function(callback) {
				var that = this, $this = $(that);
				$this.scroll(function(ev) {
					clearTimeout($this.data('scrollTimeout'));
					$this.data('scrollTimeout', setTimeout(callback.bind(that), 150, ev));
				});
			};
			 
			this.$bodyBox.scrollStopped(function(e){
				gridBox.scrollStopState = true;
				gridBox.scroll(e);
			});
		}
		
		if(this.gridScrollType){
			this.$bodyBox.scroll(function(event){
				gridBox.scroll(event);
			});
			
			this.$bodyBox.mousewheel(function(event) {
			    //console.log(event.deltaX, event.deltaY, event.deltaFactor);
			});
		}else if(!this.gridMobileType){
			this.setHeight();
			this.$bodyBox.scroll(function(event){
				gridBox.scrollHead(event);
				if(gridBox.colFixType){
					gridBox.colFixScroll();
				}
			});
		}
		
		if(this.totalView){
			theme.viewTotal(this, true);
		}
	},
	getRowHtml : function(tmpHtml){
		var tmpIndex;
		var tmpAttName;
		var tmpLen;
		
		tmpLen = configData.GRID_COL_DATA_NAME_ROWCHECK_HEAD.length;
		while((tmpIndex = tmpHtml.indexOf(configData.GRID_COL_DATA_NAME_ROWCHECK_HEAD+"=\"\"")) != -1){
			tmpHtml = tmpHtml.substring(0,tmpIndex+tmpLen)+tmpHtml.substring(tmpIndex+tmpLen+3);
		}
		
		for(var prop in this.checkCols.map){
			tmpAttName = configData.GRID_COL_DATA_NAME_CHECK_HEAD+prop+configData.GRID_COL_DATA_NAME_ATT_TAIL;
			tmpAttName = tmpAttName.toLowerCase();
			tmpLen = tmpAttName.length;
			while((tmpIndex = tmpHtml.indexOf(tmpAttName+"=\"\"")) != -1){
				tmpHtml = tmpHtml.substring(0,tmpIndex+tmpLen)+tmpHtml.substring(tmpIndex+tmpLen+3);
			}
			
			/*
			tmpAttName = configData.GRID_COL_DATA_NAME_READONLY_HEAD+prop;
			tmpAttName = tmpAttName.toLowerCase();
			tmpLen = tmpAttName.length;
			while((tmpIndex = tmpHtml.indexOf(tmpAttName+"=\"\"")) != -1){
				tmpHtml = tmpHtml.substring(0,tmpIndex+tmpLen)+tmpHtml.substring(tmpIndex+tmpLen+3);
			}
			*/
		}
		
		/*
		for(var prop in this.selectCols.map){
			tmpAttName = configData.GRID_COL_DATA_NAME_READONLY_HEAD+prop;
			tmpAttName = tmpAttName.toLowerCase();
			tmpLen = tmpAttName.length;
			while((tmpIndex = tmpHtml.indexOf(tmpAttName+"=\"\"")) != -1){
				tmpHtml = tmpHtml.substring(0,tmpIndex+tmpLen)+tmpHtml.substring(tmpIndex+tmpLen+3);
			}
		}
		*/
		
		return tmpHtml;
	},
	getRowNewHtml : function(tmpHtml){
		var tmpIndex;
		while((tmpIndex = tmpHtml.indexOf(configData.GRID_COL_DATA_NAME_HEAD)) != -1){
			tmpHtml = tmpHtml.substring(0,tmpIndex)+tmpHtml.substring(tmpHtml.indexOf(configData.GRID_COL_DATA_NAME_TAIL)+configData.GRID_COL_DATA_NAME_TAIL.length);
		}
		return tmpHtml;
	},
	valueChangeEvent : function($obj){
		//var $colObj = $obj.parent();
		var $colObj = $obj.parents("["+configData.GRID_COL+"]");
		if($colObj.length == 0){
			return;
		}
		var colName = $colObj.attr(configData.GRID_COL_NAME);
		var tmpValue = $obj.val();
		if(this.colHeadMap.containsKey(colName)){
			tmpColHead = this.colHeadMap.get(colName);
			if(tmpValue.indexOf(tmpColHead) == 0){
				tmpValue = tmpValue.substring(tmpColHead.length);
			}
		}
		
		if(this.colTailMap.containsKey(colName)){
			tmpColTail = this.colTailMap.get(colName);
			if(tmpValue.indexOf(tmpColTail) == (tmpValue.length - tmpColTail.length)){
				tmpValue = tmpValue.substring(0, (tmpValue.length - tmpColTail.length));
			}
		}
		if(this.tree){
			$colObj.attr(configData.GRID_COL_VALUE, tmpValue);
		}
		$colObj.attr(configData.GRID_COL_VALUE, tmpValue);
		this.bindGridData($colObj);
	},
	appendView : function(newHtml, prepandType, appendStart, appendEnd){
		if(!prepandType){
			prepandType = false;
		}
		
		if(prepandType){
			this.$box.prepend(newHtml);
		}else{
			this.$box.append(newHtml);
		}
		
		/*
		if(this.readOnlyType || this.readOnlyColMap || this.readOnlyRowMap || this.readOnlyCellMap){
			this.setGridReadonlyClass();
		}
		*/
		
		if(this.defaultRowStatus == configData.GRID_ROW_STATE_INSERT || this.defaultRowStatus == configData.GRID_ROW_STATE_UPDATE){
			if(appendStart == undefined){
				appendStart = this.startRowNum;
			}
			if(appendEnd == undefined){
				appendEnd = this.endRowNum;
			}
			for(var i=appendStart;i<=appendEnd;i++){
				this.setRowState(i, this.defaultRowStatus);
			}
		}
		
		if(this.colGroupCols){
			for(var i=this.colGroupCols.length-1;i>=0;i--){
				this.colGrouping(this.colGroupCols[i]);
			}			
		}
		
		return;		
	},
	sortBtnView : function($obj, colName) {
		var sortAtt = $obj.attr(configData.GRID_HEAD_SORT_ATT);
		if(sortAtt){
			$obj.find("button").remove();
			$obj.find("span").remove();
			$obj.removeAttr(configData.GRID_HEAD_SORT_ATT);
			$obj.removeClass(configData.GRID_HEAD_SORT_CLASS);
		}else{
			$obj.attr(configData.GRID_HEAD_SORT_ATT,"select");
			$obj.addClass(configData.GRID_HEAD_SORT_CLASS);
			var $upBtn = jQuery("<button class='"+this.GRID_HEAD_SORT_BTN_UP_CLASS+"'> ▲ </button>");
			$upBtn.click(function(event){
				var $obj = jQuery(event.target);
			});
			$obj.append($upBtn);
			var $downBtn = jQuery("<button class='"+this.GRID_HEAD_SORT_BTN_DOWN_CLASS+"'> ▼ </button>");
			$downBtn.click(function(event){
				var $obj = jQuery(event.target);
			});
			$obj.append($downBtn);

			$obj.parent().mouseout(function(event){
				var $obj = jQuery(event.target);
				$obj.find("button").remove();
				//$obj.find("span").remove();
				$obj.removeAttr(configData.GRID_HEAD_SORT_ATT);
				$obj.removeClass(configData.GRID_HEAD_SORT_CLASS);
				$obj.text($obj.attr(configData.GRID_COL_VALUE));
			});
		}
	},
	sortReset : function(focusType) {
		this.sortGroupMap = null;
		if(this.sortColList.length == 0){
			return;
		}
		commonUtil.displayLoading(true);
		for(var i=0;i<this.sortColList.length;i++){
			var $headTd = this.$gridHead.find(this.headColTagName+"["+configData.GRID_COL_NAME+"="+this.sortColList[i]+"]");
			var tmpHtml = $headTd.find("["+configData.GRID_COL_NAME+"="+this.sortColList[i]+"]").eq(0).html();
			this.setHeadTdHtml($headTd);
			this.setHeadColDrag($headTd.find("."+theme.GRID_LAYOUT_HEAD_COL_RIGHT_CLASS));
		}
		
		this.sortColMap = new DataMap();
		this.sortColList = new Array();
		this.sortColNumList = new Array();
		this.sortTypeList = new Array();
		
		this.viewDataList.sort(function(a, b){return a-b});
		
		this.reloadView(focusType);
		commonUtil.displayLoading(false);
		
		//event fn
		if(commonUtil.checkFn("gridListEventDataSortViewEnd")){
			gridListEventDataSortViewEnd(this.id);
		}
	},
	sortView : function() {
		if(this.sortColList.length == 1){
			this.sort(this.sortColList[0], this.sortTypeList[0], true);
		}else if(this.sortColList.length > 1){
			this.sort(this.sortColList[0], this.sortTypeList[0], false);
			this.sortColNumList = new Array();
			for(var i=0;i<this.sortColList.length;i++){
				for(var j=0;j<this.cols.length;j++){
					if(this.sortColList[i] == this.cols[j]){
						this.sortColNumList.push(j);
						break;
					}
				}				
			}
			for(var i=1;i<this.sortColList.length;i++){
				if(i == this.sortColList.length-1){
					this.sortMulti(i-1, this.sortColList[i], this.sortTypeList[i], true);
				}else{
					this.sortMulti(i-1, this.sortColList[i], this.sortTypeList[i], false);
				}				
			}
		}
	},
	appendSort : function(colName, ascType, viewType) {
		var sLeft = this.$bodyBox.get(0).scrollLeft;
		var dIndex = -1;
		var sortIndex;
		for(var i=0;i<this.cols.length;i++){
			if(colName == this.cols[i]){
				dIndex = i;
			}
		}
		if(dIndex == -1){
			return;
		}
		
		var tmpType = true;
		
		if(this.sortColList[this.sortColList.length-1] == colName){
			this.sortTypeList[this.sortColList.length-1] = ascType;
			sortIndex = this.sortColList.length;
		}else if(this.sortColMap.containsKey(colName)){
			for(var i=0;i<this.sortColList.length;i++){
				if(this.sortColList[i] == colName){
					this.sortTypeList[i] = ascType;
					sortIndex = i+1;
					break;
				}				
			}
			
			for(var i=0;i<this.sortColList.length;i++){
				if(i == 0){
					this.sort(this.sortColList[i], this.sortTypeList[i], viewType);
				}else{
					this.sortMulti(i-1, this.sortColList[i], this.sortTypeList[i], viewType);
				}
			}
			
			//return this.sortColList.length;
			tmpType = false;
		}else{
			//this.sortColMap.put(colName, true);
			this.sortColList.push(colName);		
			this.sortColNumList.push(dIndex);
			this.sortTypeList.push(ascType);
			sortIndex = this.sortColList.length;
		}
		
		if(tmpType){
			if(this.sortColList.length == 1){
				this.sort(colName, ascType, viewType);
			}else{
				this.sortMulti(this.sortColList.length-2, colName, ascType, viewType);
			}
		}
		
		this.findDataReset();
		
		this.$bodyBox.get(0).scrollLeft = sLeft;
		
		//this.$gridHead.find(this.headTagName+" > "+this.headRowTagName+" > "+this.headColTagName+"["+configData.GRID_COL_NAME+"='"+colName+"']").addClass(configData.GRID_SORT_COLOR[this.sortColList.length]);
		
		//return this.sortColList.length;
		return sortIndex;
	},
	addSort : function(colName, ascType, viewType) {
		
		if(this.sortColMap.containsKey(colName)){
			return;
		}
		
		var sLeft = this.$bodyBox.get(0).scrollLeft;
		var dIndex = -1;
		for(var i=0;i<this.cols.length;i++){
			if(colName == this.cols[i]){
				dIndex = i;
			}
		}
		if(dIndex == -1){
			return;
		}
		
		this.sortColMap.put(colName, true);
		this.sortColList.push(colName);		
		this.sortColNumList.push(dIndex);
		this.sortTypeList.push(ascType);
		if(this.sortColList.length == 1){
			this.sort(colName, ascType, viewType);
		}else{
			this.sortMulti(this.sortColList.length-2, colName, ascType, viewType);
		}
		
		this.findDataReset();
		
		this.$bodyBox.get(0).scrollLeft = sLeft;
		
		return this.sortColList.length;
	},
	sortValueText : function(colName, colValue) {
		var numLen = 0;
		var pointLen = 0;
		if(this.colFormatMap.containsKey(colName)){
			var formatList = this.colFormatMap.get(colName);
			if(formatList[0] == configData.INPUT_FORMAT_NUMBER){
				if(formatList[1]){
					var pointList = formatList[1].split(",");
					if(pointList[1]){
						numLen = parseInt(pointList[0]);
						pointLen = parseInt(pointList[1]);
					}else{
						numLen = parseInt(formatList[1]);
					}					
				}else{
					numLen = 20;
				}
			}
		}

		if(numLen){
			if(pointLen){
				if(!isNaN(colValue)){					
					var bigNum = new Big(colValue);
					var tmpNum = "0."+commonUtil.leftPadding("1", "0", pointLen);
					var divNum = new Big(tmpNum);
					colValue = bigNum.div(divNum)+"";
				}
				numLen += pointLen;
				colValue = commonUtil.leftPadding(colValue, "0", numLen);
			}else{
				colValue = commonUtil.leftPadding(colValue, "0", numLen);
			}
		}
		
		return colValue;
	},
	sortMulti : function(preCount, colName, ascType, viewType) {
		commonUtil.displayLoading(true);

		var preList = new Array();
		var sortList = new Array();
		var groupList = new Array();
		
		this.sortGroupList = new Array();
		this.sortGroupMap = new DataMap();
		
		var rowData;	
		var dIndex = this.sortColNumList[this.sortColNumList.length-1];
		for(var i=0;i<this.viewDataList.length;i++){
			rowData = this.data[this.viewDataList[i]].split(configData.DATA_COL_SEPARATOR);
			var preTxt = "";
			var groupTxt = "";
			for(var j=0;j<=preCount;j++){
				
				var tmpColName = this.sortColList[j];
				var tmpValue = this.sortValueText(tmpColName, rowData[this.sortColNumList[j]]);
				
				preTxt += tmpValue;
				//preTxt += rowData[this.sortColNumList[j]];
			}
			preList.push(preTxt);

			var tmpValue = this.sortValueText(colName, rowData[dIndex]);
			
			groupTxt = preTxt + tmpValue;
			groupList.push(groupTxt);
			
			var tmpTxt = tmpValue+commonUtil.leftPadding(this.viewDataList[i], "0", 7);
			sortList.push(tmpTxt);
		}
		
		var tempList;
		var tmpText;
		var tmpGroupText;
		var sIndex = -1;
		var eIndex = -1;
		var gIndex = 0;
		for(var i=0;i<preList.length;i++){
			if(tmpText != preList[i]){
				if(sIndex < eIndex){
					if(ascType){
						tempList.sort();
					}else{
						tempList.sort();
						tempList.reverse();
					}
					for(var j=sIndex;j<=eIndex;j++){
						sortList[j] = tempList[j-sIndex];
					}
				}
				tempList = new Array();				
				sIndex = i;			
				eIndex = -1;
				tmpText = preList[i];
			}else{
				eIndex = i;
			}
			tempList.push(sortList[i]);
			
			if(tmpGroupText != groupList[i]){
				if(i != 0){
					var groupMap = new DataMap();
					groupMap.put("S", gIndex);
					groupMap.put("E", i-1);
					this.sortGroupList.push(groupMap);
					this.sortGroupMap.put(i-1, groupMap);
				}
				tmpGroupText = groupList[i];
				gIndex = i;
			}
		}
		
		//if(gIndex == 0 || gIndex != preList.length-1){
			var groupMap = new DataMap();
			groupMap.put("S", gIndex);
			groupMap.put("E", preList.length-1);
			this.sortGroupList.push(groupMap);
			this.sortGroupMap.put(preList.length-1, groupMap);
		//}
		
		if(tempList.length > 0){
			if(ascType){
				tempList.sort();
			}else{
				tempList.sort();
				tempList.reverse();
			}
			for(var j=sIndex;j<=eIndex;j++){
				sortList[j] = tempList[j-sIndex];
			}
		}
		
		this.sortColMap.put(colName, ascType);
		
		var tmpNum;
		for(var i=0;i<sortList.length;i++){
			tmpNum = sortList[i];
			tmpNum = tmpNum.substring(tmpNum.length-7);
			this.viewDataList[i] = commonUtil.parseInt(tmpNum);
		}
		
		if(viewType){
			this.reloadView(false, false);
		}
		
		commonUtil.displayLoading(false);
	},
	sort : function(colName, ascType, viewType) {
		commonUtil.displayLoading(true);
		this.sortGroupList = new Array();
		this.sortGroupMap = new DataMap();
		
		var dIndex = -1;
		for(var i=0;i<this.cols.length;i++){
			if(colName == this.cols[i]){
				dIndex = i;
				break;
			}
		}
		
		var sortList = new Array();
		
		var rowData;
		for(var i=0;i<this.viewDataList.length;i++){
			rowData = this.data[this.viewDataList[i]].split(configData.DATA_COL_SEPARATOR);

			var tmpValue = this.sortValueText(colName, rowData[dIndex]);
			
			var tmpTxt = tmpValue+commonUtil.leftPadding(this.viewDataList[i], "0", 7);
			sortList.push(tmpTxt);
		}
		
		if(ascType){
			sortList.sort();
		}else{
			sortList.sort();
			sortList.reverse();
		}
		
		this.sortColMap.put(colName, ascType);
		
		var tmpNum;
		tmpTxt = sortList[0].substring(0,sortList[0].length-7);
		var gIndex = 0;
		for(var i=0;i<sortList.length;i++){
			tmpNum = sortList[i];
			tmpNum = tmpNum.substring(tmpNum.length-7);
			this.viewDataList[i] = commonUtil.parseInt(tmpNum);
			if(tmpTxt != sortList[i].substring(0,sortList[i].length-7)){
				var groupMap = new DataMap();
				groupMap.put("S", gIndex);
				groupMap.put("E", i-1);
				this.sortGroupList.push(groupMap);
				this.sortGroupMap.put(i-1, groupMap);
				
				tmpTxt = sortList[i].substring(0,sortList[i].length-7);
				gIndex = i;
			}
		}
		
		//if(gIndex == 0 || gIndex != sortList.length-1){
			var groupMap = new DataMap();
			groupMap.put("S", gIndex);
			groupMap.put("E", sortList.length-1);
			this.sortGroupList.push(groupMap);
			this.sortGroupMap.put(sortList.length-1, groupMap);
		//}
		
		if(viewType){
			this.reloadView(false, false);
		}
		commonUtil.displayLoading(false);
	},
	bindGridData : function($obj, $rowObj, eventType) {
		if(commonUtil.isJObjEmpty($rowObj)){
			$rowObj =$obj.parents("["+configData.GRID_ROW+"]");
		}
				
		var rowNum = $rowObj.attr(configData.GRID_ROW_NUM);
		var colName = $obj.attr(configData.GRID_COL_NAME);
		var colValue = $obj.attr(configData.GRID_COL_VALUE);
		//var colValue = this.getColValue(rowNum, colName);
		var colType = $obj.attr(configData.GRID_COL_TYPE);
		
		if(!eventType){
			var tmpAtt = this.colTypeMap.get(colName);
			if(tmpAtt){
				var attList = tmpAtt.split(",");
				if(attList[0] == configData.GRID_COL_TYPE_CHECKBOX){
					eventType = true;
				}else if(attList[0] == configData.GRID_COL_TYPE_INPUT){
					/*
					var colObjectValue = $obj.attr(configData.GRID_COL_OBJECT_VALUE);
					if(colObjectValue == colValue){
						eventType = false;
					}else{
						$obj.attr(configData.GRID_COL_OBJECT_VALUE, colValue);
						eventType = true;
					}
					*/
				}
			}
		}
		
		var colFormat = $obj.attr(configData.GRID_COL_FORMAT);
		//if(this.colFormatMap.containsKey(colName)){
		if(colFormat){
			//var formatList = this.colFormatMap.get(colName);
			var formatList = colFormat.split(" ");
			colValue = uiList.getDataFormat(formatList, colValue);
		}else if(this.colFormatMap.containsKey(colName)){
			var formatList = this.colFormatMap.get(colName);
			colValue = uiList.getDataFormat(formatList, colValue);
		}
		
		if(eventType == undefined){
			eventType = true;
		}
		
		this.setColValue(rowNum, colName, colValue, eventType, false, $rowObj, $obj);
		//this.setColValue(rowNum, colName, colValue, true, false);
	},
	itemLinkCheck : function(checkType, checkStart) {
		if(checkStart){
			if(this.headGrid && this.$headGrid.searchRowNum != -1){
				this.$headGrid.setRowCheck(this.$headGrid.searchRowNum, this.selectRow.size() > 0, false);
			}
			
			//if(this.itemGrid && !this.colValueChangeEvent){
			if(this.itemGrid){
				if(this.searchRowNum != -1){
					for(var i=0;i<this.itemGridList.length;i++){
						var itemBox = gridList.getGridBox(this.itemGridList[i]);
						if(itemBox.getDataCount() == 0){
							continue;
						}
						if(this.colValueChangeEvent){
							if(itemBox.selectRow.size() > 0){
								continue;
							}
						}
						gridList.checkAll(this.itemGridList[i], checkType, false);
					}
				}
			}
		}
	},
	rowCheckSelect : function($obj, checkStart) {
		var $rowObj = $obj.parents("["+configData.GRID_ROW+"]");
		var rowNum = $rowObj.attr(configData.GRID_ROW_NUM);
		var tmpVal;
		if($obj.prop("checked")){
			if($obj.attr(configData.GRID_COL_CHECK_RADIO)){
				for(var prop in this.selectRow.map){
					if(rowNum != prop){
						var $rowCheck = this.$box.find("["+configData.GRID_ROW_NUM+"="+prop+"]").find("["+configData.GRID_COL_TYPE+"="+configData.GRID_COL_TYPE_ROWCHECK+"]");
						if($rowCheck.length){
							$rowCheck.find("input").prop("checked", false);
						}
						this.selectRow.remove(prop);
					}
				}
				$obj.prop("checked",true);
				this.$box.find("["+configData.GRID_ROW_NUM+"]").removeClass(configData.GRID_ROW_SELECT_CLASS);
			}
			tmpVal = site.defaultCheckValue;
			this.selectRow.put(rowNum,"true");
			if(this.selectRowClassView){
				$rowObj.addClass(configData.GRID_ROW_SELECT_CLASS);
			}
		}else{
			tmpVal = site.emptyValue;
			this.selectRow.remove(rowNum);
			if(this.selectRowClassView){
				$rowObj.removeClass(configData.GRID_ROW_SELECT_CLASS);
			}
		}
			
		//var $colObj = $obj.parent();
		//$colObj.attr(configData.GRID_COL_VALUE, tmpVal);
		
		this.itemLinkCheck($obj.prop("checked"), checkStart);
		
		this.setCheckInfo();
	},
	setRowCheck : function(rowNum, checkType, checkStart) {
		var $rowObj = this.$box.find("["+configData.GRID_ROW_NUM+"="+rowNum+"]");
		if(this.rowCheckType){
			if(checkStart == undefined){
				checkStart = true;
			}
			if($rowObj.length > 0){
				var $checkObj = $rowObj.find("["+ configData.GRID_COL_TYPE +"=" + configData.GRID_COL_TYPE_ROWCHECK + "] > input");
				if($checkObj.length > 0){
					if(checkType){
						$checkObj.prop("checked", true);
					}else{
						$checkObj.prop("checked", false);
					}
					this.rowCheckSelect($checkObj, checkStart);
				}
				//this.checkboxChangeEvent($checkObj, checkType);
			}else{
				this.itemLinkCheck(checkType, checkStart);
			}
			if(checkStart){
				if(commonUtil.checkFn("gridListEventRowCheck")){
					gridListEventRowCheck(this.id, rowNum, checkType);
				}
			}
		}else if($rowObj.length > 0){
			if(checkType){
				$rowObj.addClass(configData.GRID_ROW_SELECT_CLASS);
			}else{
				$rowObj.removeClass(configData.GRID_ROW_SELECT_CLASS);
			}
		}
		if(checkType){
			this.selectRow.put(rowNum,"true");
		}else{
			this.selectRow.remove(rowNum);
		}
		this.setCheckInfo();	
	},
	dataCheckAll : function(colName, checkType){
		if(this.checkCols.containsKey(colName)){
			var colValue = site.emptyValue;
			if(checkType){
				colValue = site.defaultCheckValue;
			}
			for(var i=0;i<this.viewDataList.length;i++){
				this.setColValue(this.viewDataList[i], colName, colValue, false);
			}			
		}
	},
	checkAll : function(checkType, checkStart){
		if(!this.rowCheckType){
			return;
		}
		if(this.readOnlyType){
			return;
		}
		var colValue;
		var rowNum;
		
		if(checkType){
			colValue = site.defaultCheckValue;
			if(this.selectedRowCheckType && this.selectType != ""){
				for(var i=this.selectedRows[0];i<=this.selectedRows[1];i++){
					rowNum = this.viewDataList[i];
					if(!this.checkReadOnly(rowNum, configData.GRID_COL_TYPE_ROWCHECK)){
						this.selectRow.put(rowNum,"true");						
						$tmpRowObj = this.$box.find("["+configData.GRID_ROW_NUM+"="+rowNum+"]");
						$tmpRowObj.find("["+configData.GRID_COL_TYPE+"="+configData.GRID_COL_TYPE_ROWCHECK+"]").find("input[disabled!=disabled]").prop("checked", true);
						if(this.selectRowClassView){
							$tmpRowObj.addClass(configData.GRID_ROW_SELECT_CLASS);
						}
					}
				}
			}else{
				var $rowCheck = this.$box.find("["+configData.GRID_COL_TYPE+"="+configData.GRID_COL_TYPE_ROWCHECK+"]");
				$rowCheck.find("input[disabled!=disabled]").prop("checked", true);
				//$rowCheck.attr(configData.GRID_COL_VALUE, colValue);
				for(var i=0;i<this.viewDataList.length;i++){
					rowNum = this.viewDataList[i];
					if(!this.checkReadOnly(rowNum, configData.GRID_COL_TYPE_ROWCHECK)){
						this.selectRow.put(this.viewDataList[i],"true");
					}	
				}
				if(this.selectRowClassView){
					$rowCheck.find("input[disabled!=disabled]").parents(this.rowTagName).addClass(configData.GRID_ROW_SELECT_CLASS);
				}
			}			
		}else{
			colValue = site.emptyValue;
			if(this.selectedRowCheckType && this.selectType != ""){
				for(var i=this.selectedRows[0];i<=this.selectedRows[1];i++){
					rowNum = this.viewDataList[i];
					this.selectRow.remove(rowNum);
					$tmpRowObj = this.$box.find("["+configData.GRID_ROW_NUM+"="+rowNum+"]");
					$tmpRowObj.find("["+configData.GRID_COL_TYPE+"="+configData.GRID_COL_TYPE_ROWCHECK+"]").find("input[disabled!=disabled]").prop("checked", false);
					if(this.selectRowClassView){
						$tmpRowObj.removeClass(configData.GRID_ROW_SELECT_CLASS);
					}
				}
			}else{
				var $rowCheck = this.$box.find("["+configData.GRID_COL_TYPE+"="+configData.GRID_COL_TYPE_ROWCHECK+"]");
				$rowCheck.find("input").prop("checked", false);
				//$rowCheck.attr(configData.GRID_COL_VALUE, colValue);
				this.selectRow = new DataMap();
				if(this.selectRowClassView){
					$rowCheck.parent().removeClass(configData.GRID_ROW_SELECT_CLASS);
				}
			}
		}
		
		if(this.itemGrid){
			for(var i=0;i<this.itemGridList.length;i++){
				gridList.checkAll(this.itemGridList[i], checkType, checkStart);
			}
		}
		
		if(this.$checkHead){
			this.$checkHead.attr(configData.GRID_COL_VALUE, colValue);
			var $check = this.$checkHead.find("input");
			if(checkType){
				$check.prop("checked", true);
			}else{
				$check.prop("checked", false);
			}
		}
		
		if(this.headGrid && this.$headGrid.searchRowNum != -1){
			this.$headGrid.setRowCheck(this.$headGrid.searchRowNum, checkType, checkStart);
		}
		
		//event fn
		if(commonUtil.checkFn("gridListEventRowCheckAll")){
			gridListEventRowCheckAll(this.id, checkType);
		}
		
		this.setCheckInfo();
	},
	checkBlock : function(startRowNum, endRowNum, event){
		if(!this.rowCheckType){
			return;
		}
		
		var startViewRowNum = this.getViewRowNum(startRowNum);
		var endViewRowNum = this.getViewRowNum(endRowNum);
		
		var checkType = this.selectRow.containsKey(startRowNum);
		
		var tmpRowNum;
		for(var i=startRowNum+1;i<=endRowNum;i++){
			tmpRowNum = this.getRowNum(i);
			this.setRowCheck(rowNum, checkType, checkStart);
		}
		commonUtil.cancleEvent(event);
	},
	scrollOn : function(){
		this.setHeight();
		this.scrollType = true;
		/*
		var gridBox = this;
		this.$bodyBox.scroll(function(event){
			if(gridBox.scrollType){
				gridBox.scroll(event);
			}	
		});
		*/	
	},
	scrollOff : function(){
		this.scrollType = false;
	},	
	scrollResize : function(){
		if(this.colFixType){
			this.resetColFix();
		}
		if(this.scrollType){
			this.setHeight();
			this.setScrollTop();
			this.scrollEnd(null, true);
			this.setFocus(this.focusRowNum, this.focusColName);
		}
	},	
	setHeight : function() {
		//this.$body = this.$box.parents(this.bodyTagName);
		this.$bodyBox = this.$box.parents(this.bodyBoxTagName);
		var bodyH = this.$bodyBox.css("height");
		if(!bodyH){
			bodyH = "500px";
		}
		this.bodyBoxHeight = new Number(bodyH.substring(0, bodyH.length - 2));

		if(this.bodyBoxHeight == 0){
			var $tabBox = this.$bodyBox.parents("."+theme.GRID_TAB_BOX_CLASS);
			if($tabBox.length > 0){
				bodyH = $tabBox.css("height");
				this.bodyBoxHeight = new Number(bodyH.substring(0, bodyH.length - 2));
			}			
		}
		
		this.viewRowCount = parseInt(this.bodyBoxHeight/this.rowHeight)+1;
		
		/*2019.02.27 이범준[ 좀더 유연한 스크롤페이징을 하기 위해 제거 합니다.]*/
		/*if(this.scrollPageCount > 0){
			if(this.scrollPageCount < this.viewRowCount + 2){
				this.scrollPageCount = this.viewRowCount + 2;
			}else if(this.viewRowCount < this.scrollPageCount){
				this.viewRowCount = this.scrollPageCount;
			}
		}*/
		
		if(this.appendPageCount > 0){
			if(this.viewRowCount < this.appendPageCount){
				this.viewRowCount = this.appendPageCount;
			}
		}

	},
	setScroll : function(rowNum) {
		if(!this.scrollType){
			return;
		}
		if(!rowNum){
			rowNum = this.viewDataList.length;
		}
		
		var marginBottom = ((rowNum - this.viewRowCount) * this.rowHeight);
		if(marginBottom < 0){
			marginBottom = 0;
		}
		marginBottom = marginBottom + "px";
		//this.$tableBox.css("padding-bottom", marginBottom);
		theme.setGridScrollMarginBottom(this.$tableBox, marginBottom);
		//this.$bodyBox.get(0).scrollTop = 0;
	},
	setScrollTop : function() {
		//this.setScroll();
		this.$bodyBox.get(0).scrollTop = 0;
		if(this.scrollType){
			this.setMarginScroll(0, this.viewRowCount);
		}
	},
	setScrollBottom : function(rowNum) {
		//this.setScroll();
		this.$bodyBox.get(0).scrollTop = this.$bodyBox.get(0).scrollHeight;
	},
	scrollEventStop : function(tmpScrollTop) {
		if(this.scrollType){
			this.scrollType = false;
			this.$bodyBox.get(0).scrollTop = tmpScrollTop;
			this.scrollType = true;
		}
	},
	scrollHead : function(event) {
		if(event){
			commonUtil.cancleEvent(event);
		}
		var tmpLeft = this.$bodyBox.scrollLeft();
		if(this.scrollLeft != tmpLeft){
			var tmpMargin = "-"+tmpLeft+"px";
			this.scrollLeft = tmpLeft;
			if(this.$gridHead.length > 0){
				this.$gridHead.css({
					"margin-left" : tmpMargin
				});
			}
		}
	},
	scroll : function(event) {
		commonUtil.cancleEvent(event);
		
		if(this.pageEnd){
			this.scrollOn();
		}
		
		if(!this.gridMobileType){
			this.scrollHead();
		}
		
		if(!this.scrollType){
			if(this.colFixType){
				this.colFixScroll();
			}
			return;
		}
		
		if(this.scrollPageCount > 0){
			//this.$bodyBox.get(0).scrollTop = this.$bodyBox.get(0).scrollHeight;
			//this.viewRowCount = parseInt(this.bodyBoxHeight/this.rowHeight)+1;
			
			if(!this.pageEnd && ((this.$bodyBox.get(0).scrollHeight - this.$bodyBox.scrollTop()) < (this.viewRowCount*this.rowHeight))){
				if(this.pageEnd){
					return;
				}
				
				this.scrollOff();	//2019.02.18 프로젝트수정
				this.pageNum++;
				this.scrollPage();
			}else{
				/*2019.02.27 이범준 [IE에서 데이터가 Grid에 바인드 될 동안 스크롤 인벤트를 딜레이 시텨 좀 더 유연하게 스크롤링 되도록 하는 로직을 추가 (scrollStopState : true 일떄)]*/
				if((Browser.ie || Browser.ie6 || Browser.ie7 || Browser.ie8 || Browser.ie9 || Browser.ie10 || Browser.ie11) 
						&& (this.scrollStopState == false)){
					return;
				}
				
				this.scrollEnd(event);
			}
		}else{
			/*2019.02.27 이범준 [IE에서 데이터가 Grid에 바인드 될 동안 스크롤 인벤트를 딜레이 시텨 좀 더 유연하게 스크롤링 되도록 하는 로직을 추가 (scrollStopState : true 일떄)]*/
			if((Browser.ie || Browser.ie6 || Browser.ie7 || Browser.ie8 || Browser.ie9 || Browser.ie10 || Browser.ie11) 
					&& (this.scrollStopState == false)){
				return;
			}
			
			this.scrollEnd(event);
		}
		
		if(this.pageMoveNum != 0){
			//alert(this.pageMoveNum);
			var tmpViewNum = this.getViewRowNum(this.focusRowNum);
			tmpViewNum += this.viewRowCount*this.pageMoveNum;
			if(tmpViewNum < 0){
				tmpViewNum = 0;
			}else if(tmpViewNum >= this.viewDataList.length){
				tmpViewNum = this.viewDataList.length-1;
			}
			var tmpRowNum = this.getRowNum(tmpViewNum);
			if(this.focusColName){
				this.setFocus(tmpRowNum, this.focusColName);
			}else{
				this.rowFocus(tmpRowNum, true);
			}
			
			this.pageMoveNum = 0;
		}

		//this.$box.focus();
	},
	scrollEnd : function(event, appendRowType) {
		if(appendRowType == undefined){
			appendRowType = false;
		}
		var nowScroll = this.$bodyBox.scrollTop();
		if(this.scrollTop == nowScroll && !appendRowType){			
			return;
		}
		this.scrollTop = nowScroll;
		
		var startRow = Math.ceil(nowScroll/this.rowHeight)-1;
		var endRow = Math.floor((nowScroll+this.bodyBoxHeight)/this.rowHeight)-1;
		if(startRow < 0){
			startRow = 0;
		}else if(startRow > (this.viewDataList.length - this.viewRowCount)){
			startRow = this.viewDataList.length - this.viewRowCount + 2;
		}
		if(endRow >= this.viewDataList.length){
			endRow = this.viewDataList.length-1;
		}
		
		if(this.startRowNum <= startRow && this.endRowNum >= endRow){
			return;
		}		
		
		this.setMarginScroll(startRow, endRow);
		this.setScrollView(startRow, endRow);
		
		this.scrollStopState = false;
	},
	setMarginScroll : function(startRow, endRow) {
		this.scrollType = false;
		var height = (this.rowHeight * this.viewDataList.length) + "px";
		var marginTop = (this.rowHeight * startRow) + "px";
		var marginBottom = ((this.viewDataList.length - endRow) * this.rowHeight) + "px";
		theme.setGridScrollMarginTop(this.$tableBox,marginTop);
		theme.setGridScrollMarginBottom(this.$tableBox,marginBottom);
		/*
		this.$tableBox.css({
			"padding-bottom":marginBottom,
			"padding-top":marginTop
			});
		*/
		this.scrollType = true;
	},
	changeEndRow : function() {
		var startRow;
		var endRow;
		if(this.endRowNum == this.viewDataList.length-1){
			startRow = this.endRowNum - this.viewRowCount;
			endRow = this.endRowNum;
		}else{
			startRow = this.startRowNum;
			endRow = startRow + this.viewRowCount;
		}
		
		if(endRow >= this.viewDataList.length){
			endRow = this.viewDataList.length-1;
			startRow = endRow - this.viewRowCount;
			if(startRow < 0){
				startRow = 0;
			}
		}
		this.setMarginScroll(startRow, endRow);
		this.setScrollView(startRow, endRow);
	},
	changeStartRow : function() {
		var startRow = this.endRowNum - this.viewRowCount;
		var endRow = this.endRowNum;
		if(this.startRowNum == 0){
			startRow = this.startRowNum;
			endRow = this.viewRowCount;
		}else{
			startRow = this.endRowNum - this.viewRowCount;
			endRow = this.endRowNum;
		}
		if(startRow < 0){
			startRow = 0;
			endRow = startRow + this.viewRowCount;
			if(endRow >= this.viewDataList.length){
				endRow = this.viewDataList.length-1;
			}
		}
		this.setMarginScroll(startRow, endRow);
		this.setScrollView(startRow, endRow);
	},
	changeRow : function(changeNum) {
		var startRow = this.startRowNum+changeNum;
		var endRow = this.endRowNum+changeNum;
		if(startRow < 0){
			startRow = 0;
			endRow = this.viewRowCount;
		}else if(startRow > (this.viewDataList.length - this.viewRowCount)){
			startRow = this.viewDataList.length - this.viewRowCount + 2;
			endRow = this.viewDataList.length -1;
		}
		if(endRow >= this.viewDataList.length){
			endRow = this.viewDataList.length-1;
			startRow = endRow - this.viewRowCount;
		}
		this.setMarginScroll(startRow, endRow);
		this.setScrollView(startRow, endRow);
	},
	setScrollView : function(startRow, endRow) {
		this.scrollType = false;
		
		var ss = startRow;
		var ee = endRow;
		var rCount = 0;
		var appendHtml;
		var newHtml;
		
		/*
		if(ss < this.startRowNum){
			appendHtml = this.setRowViewHtml(ss, this.startRowNum-1);
			newHtml = appendHtml.join("\n");
			this.appendView(newHtml, true, ss, this.startRowNum-1);
		}else if(ss > this.startRowNum){
			//this.$box.children().remove();
			this.$box.find("tr:lt("+(ss-this.startRowNum)+")").remove();
		}
		
		if(ee > this.endRowNum){
			appendHtml = this.setRowViewHtml(this.endRowNum+1, ee);
			newHtml = appendHtml.join("\n");
			this.appendView(newHtml, false, this.endRowNum+1, ee);
		}else if(ee < this.endRowNum){
			this.$box.find("tr:gt("+(ee-this.startRowNum)+")").remove();
		}
		*/
		var appendHtml = this.setRowViewHtml(ss, ee);
		var newHtml = appendHtml.join("\n");
		this.$box.children().remove();
		this.appendView(newHtml);
		
		this.startRowNum = startRow;
		this.endRowNum = endRow;
		
		var focusViewRowNum = this.getViewRowNum(this.focusRowNum);
		if(startRow <= focusViewRowNum &&  focusViewRowNum <= endRow){
			this.rowFocus(this.focusRowNum, true);
			this.setFocusCol(this.focusRowNum, this.focusColName);
		}
		this.scrollType = true;
		
		if(this.colFixType){
			this.colFixScroll();
		}
	},
	findDataReset : function(findTxt) {
		if(this.findBtnType){
			this.findList = new Array();
			this.findIndex = -1;
			if(!findTxt){
				findTxt = "";
			}
			this.$findInput.val(findTxt);
			//this.$findInfo.text(" (0/0) ");
			theme.setGridFinddataInfo(this.$findInfo, 0, 0);
		}		
	},
	filterDataView : function(likeType) {
		if(this.filterDataMap == null){
			this.filterDataReset();
		}else{
			this.resetTool("filter");
			if(this.filterViewType || likeType){
				this.viewDataListReset();
			}
			var tmpViewList = new Array();
			var tmpViewType;
			var dataMap;
			var filterMap;
			var rowNum;
			var filterDataMapSize;			
			for(var i=0;i<this.viewDataList.length;i++){
				tmpViewType = true;
				rowNum = this.viewDataList[i];
				dataMap = this.getRowData(rowNum);
				filterDataMapSize = this.filterDataMap.size();
				searchData:
				for(var j=0;j<this.viewCols.length;j++){
					if(this.filterDataMap.containsKey(this.viewCols[[j]])){
						filterMap = this.filterDataMap.get(this.viewCols[[j]]);
						if(likeType){
							tmpViewType = false;
							for (var tmpValue in filterMap.map) {
								if(dataMap.get(this.viewCols[j]).toUpperCase().indexOf(tmpValue.toUpperCase()) != -1){
									filterDataMapSize--;
									if(filterDataMapSize == 0){
										tmpViewType = true;
										break searchData;
									}									
								}
							}
						}else{
							if(!filterMap.containsKey(dataMap.get(this.viewCols[j]))){
								tmpViewType = false;
								break;
							}
						}						
					}
				}
				if(tmpViewType){
					tmpViewList.push(rowNum);
				}		
			}
			if(tmpViewList.length == 0){
				commonUtil.msgBox("SYSTEM_DATAEMPTY");
				return;
			}
			this.viewDataList = tmpViewList;
			this.filterViewType = true;
			this.$box.find("["+configData.GRID_ROW+"]").remove();
			this.setViewStart();
		}
	},
	filterDataReset : function() {
		this.resetTool("filter");
		this.$box.find("["+configData.GRID_ROW+"]").remove();
		this.filterViewType = false;
		this.filterDataMap = null;
		this.viewDataList = new Array();
				
		this.viewDataListReset();
		this.setViewStart();
	},
	viewDataListReset : function() {
		this.viewDataList = new Array();
		for(var i=0;i<this.data.length;i++){
			if(this.isAvailRow(i)){
				this.viewDataList.push(i);
			}
		}
	},
	findData : function(findTxt) {
		this.findDataReset(findTxt);
		if(findTxt == ""){
			this.findDataReset();
			return;
		}
		var dataMap;
		var rowNum;
		for(var i=0;i<this.viewDataList.length;i++){
			rowNum = this.viewDataList[i];
			if(this.data[rowNum].toLowerCase().indexOf(findTxt.toLowerCase()) != -1){
				dataMap = this.getRowData(rowNum);
				for(var j=0;j<this.viewCols.length;j++){
					if(dataMap.containsKey(this.viewCols[j])){
						if(dataMap.get(this.viewCols[j]).toLowerCase().indexOf(findTxt.toLowerCase()) != -1){
							this.findList.push(rowNum+configData.DATA_COL_SEPARATOR+this.viewCols[j]);
						}
					}						
				}
			}
		}
		if(this.findList.length > 0){
			this.findDataFocus(0);
		}else{
			commonUtil.msgBox(configData.MSG_MASTER_ROWEMPTY);
		}	
	},
	findDataFocusMove : function(index) {
		var tmpIndex = this.findIndex;
		if(tmpIndex == -1){
			return;
		}
		if(index == -1 && tmpIndex !=0){
			tmpIndex--;
		}else if(index == 1 && tmpIndex != this.findList.length-1){
			tmpIndex++;
		}
		this.findDataFocus(tmpIndex);
	},
	findDataFocus : function(index) {
		var tmpData = this.findList[index].split(configData.DATA_COL_SEPARATOR);
		theme.setGridFinddataInfo(this.$findInfo, index+1, this.findList.length);
		var rowNum = parseInt(tmpData[0]);
		this.setFocus(rowNum, tmpData[1]);
		this.findIndex = index;
	},
	setFocus : function(rowNum, colName) {
		var $colObj;
		var rowViewNum = this.getViewRowNum(rowNum);
		if(this.scrollType){		
			if(this.startRowNum > rowViewNum || rowViewNum > this.endRowNum){
				this.focusRowNum = rowNum;
				this.focusColName = colName;
				this.$bodyBox.get(0).scrollTop = this.rowHeight * rowViewNum;
			}else{
				this.rowFocus(rowNum, true);
				if(colName){
					$colObj = this.setFocusCol(rowNum, colName, true);
				}
			}
		}else{
			this.$bodyBox.get(0).scrollTop = this.rowHeight * rowViewNum;
			this.rowFocus(rowNum, true);
			if(colName){
				$colObj = this.setFocusCol(rowNum, colName);
			}			
		}
		return $colObj;
	},
	setFocusCol : function(rowNum, colName, reloadType) {
		var $rowObj = this.$box.find("["+configData.GRID_ROW_NUM+"="+rowNum+"]");
		var $colObj;
		if($rowObj.length > 0){
			$colObj = $rowObj.find("["+configData.GRID_COL_NAME+"="+colName+"]");
			var colType = $colObj.attr(configData.GRID_COL_TYPE);
			if(colType == configData.GRID_COL_TYPE_INPUT){
				if($colObj.find("input").length == 0){
					$colObj.trigger("click");
				}else{
					$colObj.find("input").focus();
				}
			}else if(colType == configData.GRID_COL_TYPE_SELECT || colType == configData.GRID_COL_TYPE_CHECKBOX || colType == configData.GRID_COL_TYPE_ROWCHECK){
				$colObj.find("input,select").focus();
			}else{
				$colObj.focus();
				if(this.id != configData.GRID_LAYOUT_SAVE_VISIBLE_ID && this.id != configData.GRID_LAYOUT_SAVE_INVISIBLE_ID && colType == configData.GRID_COL_TYPE_TEXT){
					if (window.getSelection) {
				        var selected = window.getSelection();
				            selected.selectAllChildren($colObj.get(0));
				    } else if (document.body.createTextRange) {
				        var range = document.body.createTextRange();
				            range.moveToElementText($colObj.get(0));
				            range.select();
				    }
				}				
			}
		}
		
		this.focusColName = colName;

		return $colObj;
	},
	setData : function(dataString) {
		if(dataString.length >0){
			var list =dataString.split(configData.DATA_ROW_SEPARATOR);
			this.cols = list[0].split(configData.DATA_COL_SEPARATOR);
			this.data = list.slice(1,list.length);
			for(var i=0;i<this.data.length;i++){
				this.viewDataList[i] = i;
				if(this.tree){
					this.mapData[i] = this.getRowData(i);
				}
			}
			if(this.defaultRowStatus == configData.GRID_ROW_STATE_INSERT || this.defaultRowStatus == configData.GRID_ROW_STATE_UPDATE){
				for(var i=0;i<this.data.length;i++){
					this.setRowState(i, this.defaultRowStatus);
				}
			}
			this.mapData = new Array();
			this.setScroll();
			this.setInfo();
			return this.data.length;
		}else{
			return 0;
		}		
	},
	setRowData : function(rowNum, dataString) {
		this.data[rowNum] = dataString;
		if(this.mapData[rowNum]){
			this.getRowData(rowNum);
		}
	},
	replaceData : function(targetRowNum, sourceRowNum) {
		if(sourceRowNum == undefined){
			sourceRowNum = this.focusRowNum;
		}
		var tmpData = this.data[targetRowNum];
		this.setRowData(targetRowNum, this.data[sourceRowNum]);
		this.setRowData(sourceRowNum, tmpData);
		this.reloadView();
		this.rowFocus(targetRowNum);
	},
	replaceViewData : function(targetViewRowNum, sourceViewRowNum) {
		if(sourceViewRowNum == undefined){
			sourceViewRowNum = this.getViewRowNum(this.focusRowNum);
		}
		
		var tmpData = this.viewDataList[targetViewRowNum];
		this.viewDataList[targetViewRowNum] = this.viewDataList[sourceViewRowNum];
		this.viewDataList[sourceViewRowNum] = tmpData;
		this.reloadView();
		this.viewRowReset();
		var targetRowNum = this.getRowNum(targetViewRowNum);
		this.rowFocus(targetRowNum);
	},
	replaceViewTop : function(sourceViewRowNum) {
		if(sourceViewRowNum == undefined){
			sourceViewRowNum = this.getViewRowNum(this.focusRowNum);
		}
		var tmpData = this.viewDataList[sourceViewRowNum];
		
		this.viewDataList = this.viewDataList.slice(0,sourceViewRowNum).concat( this.viewDataList.slice(sourceViewRowNum+1));
		this.viewDataList.unshift(tmpData);
		
		this.reloadView();
		this.viewRowReset();
		var targetRowNum = this.getRowNum(0);
		this.rowFocus(targetRowNum);
	},
	replaceViewBottom : function(sourceViewRowNum) {
		if(sourceViewRowNum == undefined){
			sourceViewRowNum = this.getViewRowNum(this.focusRowNum);
		}
		var tmpData = this.viewDataList[sourceViewRowNum];
		
		this.viewDataList = this.viewDataList.slice(0,sourceViewRowNum).concat( this.viewDataList.slice(sourceViewRowNum+1));
		this.viewDataList.push(tmpData);
		
		this.reloadView();
		this.viewRowReset();
		var targetRowNum = this.getRowNum(this.viewDataList.length-1);
		this.rowFocus(targetRowNum);
	},
	resetCols : function(addCols) {
		if(addCols && addCols.length>0){
			this.cols = addCols;
		}else{
			this.cols = new Array();
		}		
	},
	appendCols : function(addCols) {
		this.cols = this.cols.concat(addCols);
	},
	appendList : function(dataList, viewType) {
		var strList = new Array();
		var map;
		for(var i=0;i<dataList.length;i++){
			map = dataList[i];
			var tmpStr = "";
			for(var j=0;j<this.cols.length;j++){
				if(map.containsKey(this.cols[j])){
					tmpStr += map.get(this.cols[j])+configData.DATA_COL_SEPARATOR;
				}else{
					tmpStr += configData.DATA_COL_SEPARATOR;
				}
				
			}
			tmpStr = tmpStr.substring(0,tmpStr.length-1);
			strList.push(tmpStr);
		}
		
		return this.dataAppend(strList, viewType);
	},
	appendDataList : function(dataString) {
		var list =dataString.split(configData.DATA_ROW_SEPARATOR);
		var appendData = list.slice(1,list.length);
		appendData = appendData.slice(this.data.length);
		
		return this.dataAppend(appendData);
	},
	dataAppend : function(appendData, viewType) {
		if(viewType == undefined){
			viewType = true;
		}
		
		var dataCount = this.data.length;
		var count = appendData.length+this.data.length;
		
		var oldViewCount = this.viewDataList.length;
		
		for(var i=this.data.length;i<count;i++){
			this.viewDataList[i] = i;
		}
		
		this.data = this.data.concat(appendData);
		
		if(this.defaultRowStatus == configData.GRID_ROW_STATE_INSERT || this.defaultRowStatus == configData.GRID_ROW_STATE_UPDATE){
			for(var i=dataCount;i<count;i++){
				this.setRowState(i, this.defaultRowStatus);
			}
		}

		this.checkScrollEvent();
		
		this.setInfo();
		this.setScroll();

		if(!this.scrollType){
			if(viewType){
				this.setView(oldViewCount, this.viewDataList.length, true);
			}
		}else{
			if(this.sortColList.length > 0){
				this.sortView();
			}
		}		
		
		return this.data.length;
	},
	checkScrollEvent : function() {
		if(!this.gridScrollType){
			this.setHeight();
			return;
		}
		if(this.scrollPageCount > 0){
			this.scrollOn();
		}else if(!this.gridMobileType && !this.scrollType && this.data.length*this.viewCols.length > this.maxViewDataCell){
			this.scrollOn();
		}
	},
	appendData : function(dataString) {
		this.data.push(dataString);
		this.setInfo();
		this.setScroll();
	},
	appendPageData : function(dataList) {
		var dataCount = this.data.length;
		var count = dataList.length+this.data.length;
		for(var i=dataCount;i<count;i++){
			this.viewDataList[i] = i;
		}
		
		this.data = this.data.concat(dataList);
		//this.data.push(dataList);
		this.setInfo();
		this.setScroll();
		if(this.scrollPageCount > 0){
			this.setMarginScroll(this.startRowNum, this.endRowNum);
		}		
		this.setView(this.startRowNum, this.endRowNum);
	},
	reloadData : function(dataString) {
		this.data = dataString.split(configData.DATA_ROW_SEPARATOR);
		for(var i=0;i<this.data.length;i++){
			this.viewDataList[i] = i;
		}
		this.setInfo();
		this.setScroll();
		return this.data.length;
	},
	setView : function(startRow, endRow, startType) {
		this.checkScrollEvent();
		if(startType == true && this.sortColList.length > 0){
			this.sortView();
			return;
		}
		
		var appendHtml = this.setRowViewHtml(startRow, endRow);
		
		if(appendHtml.length == 0){
			/*
			if(this.emptyMsgType){
				commonUtil.msgBox(configData.MSG_MASTER_ROWEMPTY);
			}
			
			this.reset();
			*/
		}else{
			if(commonUtil.checkFn("searchOpen")){
				searchOpen(false);
			}
			
			var newHtml = appendHtml.join("\n");
			
			this.appendView(newHtml);
		}

		if(startType == true){
			if(this.headGrid){
				if(this.data.length > 0){
					if(this.$headGrid.getSelectType(this.$headGrid.searchRowNum)){
						this.checkAll(true);
					}
				}
			}
			
			//event fn
			if(commonUtil.checkFn("gridListEventDataViewEnd")){
				gridListEventDataViewEnd(this.id, this.data.length);
			}
		}
		
		this.startRowNum = startRow;
		this.endRowNum = endRow;
		
		if(this.subTotalCols){
			
		}else{
			if(this.totalView){
				this.viewTotal(false);
				this.viewTotal(true);
			}
			
			if(this.totalShow){
				this.viewTotal(false);
				this.viewTotal(true);
			}
		}		
	},
	setViewStart : function(startType) {
		this.checkScrollEvent();
		var startRow = 0;
		var endRow = this.viewDataList.length-1;
		if(this.scrollType){
			endRow = this.viewRowCount;
			this.setScroll();
			this.setInfo();
		}
		this.setView(startRow, endRow, startType);
		if(this.firstRowFocusType){
			this.firstRowFocus();
		}
	},
	setViewAll : function(focusType, startType) {
		this.checkScrollEvent();
		if(startType != false){
			startType = true;
		}
		var startRow = 0;
		var endRow = this.viewDataList.length-1;
		if(this.scrollType){
			endRow = this.viewRowCount;
			this.setScroll();
			this.setInfo();
		}
		this.setView(startRow, endRow, startType);
		if(focusType && this.firstRowFocusType){
			this.firstRowFocus();
		}		
	},	
	checkReadOnly : function(rowNum, colName) {
		if(this.readOnlyType){
			return this.readOnlyType;
		}else if(this.readOnlyRowMap && this.readOnlyRowMap.containsKey(rowNum)){
			return this.readOnlyRowMap.get(rowNum);
		}else if(this.readOnlyColMap && this.readOnlyColMap.containsKey(colName)){
			return this.readOnlyColMap.get(colName);
		}else if(this.readOnlyCellMap && this.readOnlyCellMap.containsKey(rowNum)){
			var colMap = this.readOnlyCellMap.get(rowNum);
			if(colMap && colMap.containsKey(colName)){
				return colMap.get(colName);
			}
		}else{
			return false;
		}
	},
	reloadFnCol : function(colName, rowNum) {
		if(this.colFunctionMap.containsKey(colName)){
			var $rowObj;
			var $colObj;
			var colValue;
			var tmpHtml;
			if(rowNum != undefined){
				$rowObj = this.$box.find("["+configData.GRID_ROW_NUM+"="+rowNum+"]");
				if($rowObj.length > 0){
					$colObj = $rowObj.find("["+configData.GRID_COL_NAME+"="+colName+"]");
					colValue = this.getColValue(rowNum, colName);
					tmpHtml = eval(this.colFunctionMap.get(colName)+"('"+this.id+"', '"+rowNum+"', '"+colName+"', '"+colValue+"')");
					$colObj.html(tmpHtml);
				}
			}else{
				$rowObj = this.$box.find("["+configData.GRID_ROW_NUM+"]");
				if($rowObj.length > 0){
					for(var i=0;i<$rowObj.length;i++){
						rowNum = parseInt($rowObj.attr(configData.GRID_ROW_NUM));
						$colObj = $rowObj.eq(i).find("["+configData.GRID_COL_NAME+"="+colName+"]");
						colValue = this.getColValue(rowNum, colName);
						tmpHtml = eval(this.colFunctionMap.get(colName)+"('"+this.id+"', '"+rowNum+"', '"+colName+"', '"+colValue+"')");
						$colObj.html(tmpHtml);
					}
				}
			}
		}		
	},
	setRowViewHtml : function(startRow, endRow, numSetType) {
		if(numSetType == undefined){
			numSetType = true;
		}
		var appendHtml = new Array();
		var colValue;
		for(var i=startRow;i<=endRow;i++){
			var rowNum = this.viewDataList[i];
			var rowView;
			
			if(this.editable && this.modifyRow.get(rowNum) == configData.GRID_ROW_STATE_INSERT){
				rowView = configData.GRID_ROW_STATE_INSERT;
			}else if(this.editable && this.modifyRow.get(rowNum) == configData.GRID_ROW_STATE_UPDATE){
				rowView = configData.GRID_ROW_STATE_UPDATE;
			}else{
				rowView = i+1;
				if(this.pageCount){
					rowView += (this.pageNum-1)*this.pageCount;
				}
			}
			
			var tmpRowHtml = this.rowHtml;
			
			if(!this.data[rowNum]){
				continue;
			}
			
			var chk = false;
			if(commonUtil.checkFn("gridListCheckBoxDrawBeforeEvent")){
				chk = gridListCheckBoxDrawBeforeEvent(this.id, rowNum);
			}
			
			if(chk){
				var inputCheckBoxText = this.rowCheckText.get(this.id);
				if(tmpRowHtml.indexOf(inputCheckBoxText) == -1){
					var tmpLen   = configData.GRID_COL_DATA_NAME_ROWCHECK_HEAD.length;
					var tmpIndex = inputCheckBoxText.indexOf(configData.GRID_COL_DATA_NAME_ROWCHECK_HEAD+"=\"\"");
					if(tmpIndex > -1){
						inputCheckBoxText = inputCheckBoxText.substring(0,tmpIndex+tmpLen)+inputCheckBoxText.substring(tmpIndex+tmpLen+3);
					}
				}
				tmpRowHtml = tmpRowHtml.replace(inputCheckBoxText,"");
				tmpRowHtml = tmpRowHtml.replace("gcrc_rowCheck editable gridColObject","gcrc_rowCheck editable gridColObject gridColDisable");
				
				gridList.setRowReadOnly(this.id, rowNum, true, null);
			}
			
			var rowState = this.getRowState(rowNum);
			if(this.modifyRow.containsKey(rowNum)){
				var updatColMap = this.modifyCols[rowNum];
				if(updatColMap){
					for(var prop in updatColMap.map){
						if(!this.viewColMap.containsKey(prop)){
							continue;
						}
						colReplaceName = configData.GRID_COL_DATA_NAME_MODIFY_COL_HEAD+prop;
						if(this.editedClassType){
							tmpRowHtml = tmpRowHtml.replace(colReplaceName, configData.GRID_EDITED_BACK_CLASS);
						}								
					}
				}
			}
			if(rowState == configData.GRID_ROW_STATE_INSERT){
				if(this.pkcolMap.size() > 0 || this.addcolMap.size() > 0){
					var $rowObj = jQuery(tmpRowHtml);
					$rowObj.find("["+configData.GRID_COL_TYPE_PK+"]").each(function(i, findElement){
						var $obj = jQuery(findElement);
						var colType = $obj.attr(configData.GRID_COL_TYPE);
						if(colType == configData.GRID_COL_TYPE_TEXT){
							$obj.removeClass(configData.GRID_COL_TYPE_TEXT_CLASS);
							$obj.attr(configData.GRID_COL_TYPE, configData.GRID_COL_TYPE_INPUT);
							if(!$obj.attr(configData.VALIDATION_ATT)){
								$obj.attr(configData.VALIDATION_ATT, configData.VALIDATION_REQUIRED);
							}
							$obj.addClass(configData.GRID_EDIT_BACK_CLASS);
						}else if(colType == configData.GRID_COL_TYPE_SELECT){
							var $select = $obj.find("select");
							$select.removeAttr("disabled");
							$select.removeClass(configData.GRID_COL_TYPE_DISABLE_CLASS);
						}
					});
					tmpRowHtml = $rowObj.clone().wrapAll("<div/>").parent().html();
				}
			}
			
			var tmpData = this.data[rowNum].split(configData.DATA_COL_SEPARATOR);
			while(tmpRowHtml.indexOf(configData.GRID_COL_DATA_NAME_ROWNUM) != -1){
				tmpRowHtml = tmpRowHtml.replace(configData.GRID_COL_DATA_NAME_ROWNUM, rowNum);
			}
			while(tmpRowHtml.indexOf(configData.GRID_COL_DATA_NAME_ROWVIEW) != -1){
				tmpRowHtml = tmpRowHtml.replace(configData.GRID_COL_DATA_NAME_ROWVIEW, rowView);
			}
			
			/*
			while(tmpRowHtml.indexOf(configData.GRID_COL_DATA_NAME_ROWVIEWNUM) != -1){
				tmpRowHtml = tmpRowHtml.replace(configData.GRID_COL_DATA_NAME_ROWVIEWNUM, i);
			}
			*/
			var colReplaceName = "";
			var colClass = "";
			var rowData = new DataMap();
			var colName;
			for(var j=0;j<this.cols.length;j++){
				colName = this.cols[j];
				
				colValue = tmpData[j];
				if(colValue == site.emptyValue){
					colValue = "";
				}
				
				rowData.put(colName, colValue);
				if(this.colFunctionMap.containsKey(colName)){
					if(eval(this.colFunctionMap.get(colName))){
						var tmpHtml = eval(this.colFunctionMap.get(colName)+"('"+this.id+"', '"+i+"', '"+colName+"', '"+colValue+"')");
						colReplaceName = configData.GRID_COL_DATA_NAME_HEAD+colName+configData.GRID_COL_DATA_NAME_TAIL;
						tmpRowHtml = tmpRowHtml.replace(colReplaceName, tmpHtml);
					}					
				}
						
				if(this.colHeadMap.containsKey(colName)){
					colValue = this.colHeadMap.get(colName) + colValue;
				}
				
				if(this.colTailMap.containsKey(colName)){
					colValue = colValue + this.colTailMap.get(colName);
				}

				colReplaceName = configData.GRID_COL_DATA_NAME_HEAD+colName+configData.GRID_COL_DATA_NAME_TAIL;
				
				while(tmpRowHtml.indexOf(colReplaceName) != -1){
					tmpRowHtml = tmpRowHtml.replace(colReplaceName, colValue);
				}
				
				if(this.colFormatMap.containsKey(colName)){
					var formatList = this.colFormatMap.get(colName);
					colReplaceName = configData.GRID_COL_DATA_NAME_VIEW_HEAD+colName+configData.GRID_COL_DATA_NAME_TAIL;
					if(this.viewFormat){
						colValue = uiList.getDataFormat(formatList, colValue, true);
					}
					while(tmpRowHtml.indexOf(colReplaceName) != -1){
						tmpRowHtml = tmpRowHtml.replace(colReplaceName, colValue);
					}
				}
				
				if(this.rowCheckType){
					if(this.selectRow.containsKey(rowNum)){
						colReplaceName = configData.GRID_COL_DATA_NAME_ROWCHECK_HEAD;
						colReplaceName = colReplaceName.toLowerCase();
						tmpRowHtml = tmpRowHtml.replace(colReplaceName, "checked='checked'");
					}
				}
				
				if(this.checkCols.containsKey(colName)){
					colReplaceName = configData.GRID_COL_DATA_NAME_CHECK_HEAD+colName+configData.GRID_COL_DATA_NAME_ATT_TAIL;
					colReplaceName = colReplaceName.toLowerCase();
					if(colValue == site.defaultCheckValue){
						tmpRowHtml = tmpRowHtml.replace(colReplaceName, "checked='checked'");
					}else{
						tmpRowHtml = tmpRowHtml.replace(colReplaceName, "");
					}
				}
				
				if(this.selectCols.containsKey(colName)){
					if(this.selectGroupCols.containsKey(colName)){
						var $tmpSelect = this.selectCols.get(colName).clone();
						var gcolName = this.selectGroupCols.get(colName);
						var gvalue;
						for(var k=0;k<this.cols.length;k++){
							if(this.cols[k] == gcolName){
								gvalue = tmpData[k];
								break;
							}
						}
						if(gvalue){
							gvalue = jQuery.trim(gvalue);
						}
						
						var tmpGroupAtt;
						var $tmpGroupOptionList = $tmpSelect.find("["+configData.INPUT_COMBO_OPTION_GROUP+"]");
						if(gvalue){
							for(var k=0;k<$tmpGroupOptionList.length;k++){
								tmpGroupAtt = $tmpGroupOptionList.eq(k).attr(configData.INPUT_COMBO_OPTION_GROUP);
								if(tmpGroupAtt != configData.INPUT_COMBO_OPTION_GROUP && tmpGroupAtt != gvalue){
									$tmpGroupOptionList.eq(k).remove();
								}
							}
						}else{
							for(var k=0;k<$tmpGroupOptionList.length;k++){
								if($tmpGroupOptionList.eq(k).attr(configData.INPUT_COMBO_OPTION_GROUP) != configData.INPUT_COMBO_OPTION_GROUP){
									$tmpGroupOptionList.eq(k).remove();
								}
							}
						}						
						colReplaceName = configData.GRID_COL_DATA_NAME_GROUPSELECT_HEAD+colName+configData.GRID_COL_DATA_NAME_TAIL;
						tmpRowHtml = tmpRowHtml.replace(colReplaceName, $tmpSelect.wrapAll("<div/>").parent().html());
					}
					colReplaceName = configData.GRID_COL_DATA_NAME_OPTION_HEAD+colName+colValue+configData.GRID_COL_DATA_NAME_ATT_TAIL;
					colReplaceName = colReplaceName.toLowerCase();
					tmpRowHtml = tmpRowHtml.replace(colReplaceName, " selected='selected' "+colReplaceName);
				}
				
				if(this.colorType){
					//event fn
					if(commonUtil.checkFn("gridListColTextColorChange")){
						colClass = gridListColTextColorChange(this.id, rowNum, colName, colValue);
					}
					if(colClass){
						colReplaceName = configData.GRID_COLOR_COL_TEXT_CLASS_HEAD+colName;
						colReplaceName = colReplaceName.toLowerCase();
						tmpRowHtml = tmpRowHtml.replace(colReplaceName, colClass);
					}
					
					colClass = null;
					//event fn
					if(commonUtil.checkFn("gridListColBgColorChange")){
						colClass = gridListColBgColorChange(this.id, rowNum, colName, colValue);
					}
					if(colClass){
						colReplaceName = configData.GRID_COLOR_COL_BG_CLASS_HEAD+colName;
						colReplaceName = colReplaceName.toLowerCase();
						tmpRowHtml = tmpRowHtml.replace(colReplaceName, colClass);
					}
				}
				
				if(this.editableColMap.containsKey(colName)){
					if(this.readOnlyType){
						colReplaceName = configData.GRID_COL_DATA_NAME_READONLY_CLASS_HEAD+colName;
						//colReplaceName = colReplaceName.toLowerCase();
						tmpRowHtml = tmpRowHtml.replace(colReplaceName, configData.GRID_COL_TYPE_DISABLE_CLASS);
						
						colReplaceName = configData.GRID_COL_DATA_NAME_DISABLE_OBJECT_HEAD+colName+configData.GRID_COL_DATA_NAME_ATT_TAIL;
						colReplaceName = colReplaceName.toLowerCase();
						tmpRowHtml = tmpRowHtml.replace(colReplaceName, "disabled='disabled'");
					}else if(this.readOnlyRowMap && this.readOnlyRowMap.containsKey(rowNum)){
						colReplaceName = configData.GRID_COL_DATA_NAME_READONLY_CLASS_HEAD+colName;
						//colReplaceName = colReplaceName.toLowerCase();
						tmpRowHtml = tmpRowHtml.replace(colReplaceName, configData.GRID_COL_TYPE_DISABLE_CLASS);
						
						colReplaceName = configData.GRID_COL_DATA_NAME_DISABLE_OBJECT_HEAD+colName+configData.GRID_COL_DATA_NAME_ATT_TAIL;
						colReplaceName = colReplaceName.toLowerCase();
						tmpRowHtml = tmpRowHtml.replace(colReplaceName, "disabled='disabled'");
					}else if(this.readOnlyColMap && this.readOnlyColMap.containsKey(colName)){
						colReplaceName = configData.GRID_COL_DATA_NAME_READONLY_CLASS_HEAD+colName;
						//colReplaceName = colReplaceName.toLowerCase();
						tmpRowHtml = tmpRowHtml.replace(colReplaceName, configData.GRID_COL_TYPE_DISABLE_CLASS);
						
						colReplaceName = configData.GRID_COL_DATA_NAME_DISABLE_OBJECT_HEAD+colName+configData.GRID_COL_DATA_NAME_ATT_TAIL;
						colReplaceName = colReplaceName.toLowerCase();
						tmpRowHtml = tmpRowHtml.replace(colReplaceName, "disabled='disabled'");
					}else if(this.readOnlyCellMap &&this.readOnlyCellMap.containsKey(rowNum)){
						var colMap = this.readOnlyCellMap.get(rowNum);
						if(colMap.containsKey(colName)){
							if(colMap.get(colName)){
								colReplaceName = configData.GRID_COL_DATA_NAME_READONLY_CLASS_HEAD+colName;
								//colReplaceName = colReplaceName.toLowerCase();
								tmpRowHtml = tmpRowHtml.replace(colReplaceName, configData.GRID_COL_TYPE_DISABLE_CLASS);
								
								colReplaceName = configData.GRID_COL_DATA_NAME_DISABLE_OBJECT_HEAD+colName+configData.GRID_COL_DATA_NAME_ATT_TAIL;
								colReplaceName = colReplaceName.toLowerCase();
								tmpRowHtml = tmpRowHtml.replace(colReplaceName, "disabled='disabled'");
							}
						}
					}
				}
				
				//2019.04.05 특정조건 시 아이콘 이미지 삭제 event fn 
				var iconClassRemove = null;
				if(commonUtil.checkFn("gridListColIconRemove")){
					iconClassRemove = gridListColIconRemove(this.id, rowNum, colName, colValue);
				}
				
				if(iconClassRemove){
					var iconClassText = this.gridIconMap.get(this.id);
					if(typeof iconClassRemove == "boolean"){
						tmpRowHtml = tmpRowHtml.replace(iconClassText,"");
					}else if(typeof iconClassRemove == "string"){
						var icon = '<div class="gridIcon-center">'
							     + '<span class="'+iconClassRemove+'">Icon</span>'
							     + '</div>';
						tmpRowHtml = tmpRowHtml.replace(iconClassText,icon);
					}
				}
			}
			
			if(this.selectRow.containsKey(rowNum)){
				if(this.selectRowClassView && !chk){
					colReplaceName = configData.GRID_COL_DATA_NAME_ROW_SELECT_CLASS_HEAD;
					tmpRowHtml = tmpRowHtml.replace(colReplaceName, configData.GRID_ROW_SELECT_CLASS);
				}
				
				colReplaceName = configData.GRID_COL_DATA_NAME_CHECK_HEAD+configData.GRID_COL_TYPE_ROWCHECK;
				colReplaceName = colReplaceName.toLowerCase();
				tmpRowHtml = tmpRowHtml.replace(colReplaceName, "checked='checked'");
			}
			
			if(this.focusRowNum == rowNum){
				colReplaceName = configData.GRID_COL_DATA_NAME_ROW_FOCUS_CLASS_HEAD;
				tmpRowHtml = tmpRowHtml.replace(colReplaceName, configData.GRID_ROW_FOCUS_CLASS);
			}
			
			if(this.colorType){
				colClass = null; // 2019.04.01 jw : colClass 초기화 부분 누락되어 클래스 중복으로 들어가는 부분 변경
				
				//event fn
				if(commonUtil.checkFn("gridListRowTextColorChange")){
					colClass = gridListRowTextColorChange(this.id, rowNum, rowData);
				}
				if(colClass){
					colReplaceName = configData.GRID_COLOR_ROW_TEXT_CLASS_HEAD;
					tmpRowHtml = tmpRowHtml.replace(colReplaceName, colClass);
				}
				
				colClass = null;
				//event fn
				if(commonUtil.checkFn("gridListRowBgColorChange")){
					colClass = gridListRowBgColorChange(this.id, rowNum, rowData);
				}
				if(colClass){
					colReplaceName = configData.GRID_COLOR_ROW_BG_CLASS_HEAD;
					tmpRowHtml = tmpRowHtml.replace(colReplaceName, colClass);
				}
			}
			
			if(this.tree){
				colReplaceName = configData.GRID_COL_DATA_NAME_HEAD+configData.GRID_COL_TYPE_TREE+configData.GRID_COL_DATA_NAME_TAIL;
				var tmpTreeTxt = "";
				if(rowNum < this.data.length-1){
					var tmpLvlValue = this.getColValue(rowNum, this.treeLvl);
					var tmpNextLvlValue = this.getColValue(rowNum+1, this.treeLvl);
					if(tmpLvlValue < tmpNextLvlValue){
						tmpTreeTxt = "-";
					}
				}
				while(tmpRowHtml.indexOf(colReplaceName) != -1){
					tmpRowHtml = tmpRowHtml.replace(colReplaceName, tmpTreeTxt);
				}
			}
			
			if(this.rowCheckType){
				colName = configData.GRID_COL_TYPE_ROWCHECK;
				if(this.readOnlyType){
					colReplaceName = configData.GRID_COL_DATA_NAME_READONLY_CLASS_HEAD+colName;
					//colReplaceName = colReplaceName.toLowerCase();
					tmpRowHtml = tmpRowHtml.replace(colReplaceName, configData.GRID_COL_TYPE_DISABLE_CLASS);
					
					colReplaceName = configData.GRID_COL_DATA_NAME_DISABLE_OBJECT_HEAD+colName+configData.GRID_COL_DATA_NAME_ATT_TAIL;
					colReplaceName = colReplaceName.toLowerCase();
					tmpRowHtml = tmpRowHtml.replace(colReplaceName, "disabled='disabled'");
				}else if(this.readOnlyRowMap && this.readOnlyRowMap.containsKey(rowNum)){
					colReplaceName = configData.GRID_COL_DATA_NAME_READONLY_CLASS_HEAD+colName;
					//colReplaceName = colReplaceName.toLowerCase();
					tmpRowHtml = tmpRowHtml.replace(colReplaceName, configData.GRID_COL_TYPE_DISABLE_CLASS);
					
					colReplaceName = configData.GRID_COL_DATA_NAME_DISABLE_OBJECT_HEAD+colName+configData.GRID_COL_DATA_NAME_ATT_TAIL;
					colReplaceName = colReplaceName.toLowerCase();
					tmpRowHtml = tmpRowHtml.replace(colReplaceName, "disabled='disabled'");
				}else if(this.readOnlyColMap && this.readOnlyColMap.containsKey(colName)){
					colReplaceName = configData.GRID_COL_DATA_NAME_READONLY_CLASS_HEAD+colName;
					//colReplaceName = colReplaceName.toLowerCase();
					tmpRowHtml = tmpRowHtml.replace(colReplaceName, configData.GRID_COL_TYPE_DISABLE_CLASS);
					
					colReplaceName = configData.GRID_COL_DATA_NAME_DISABLE_OBJECT_HEAD+colName+configData.GRID_COL_DATA_NAME_ATT_TAIL;
					colReplaceName = colReplaceName.toLowerCase();
					tmpRowHtml = tmpRowHtml.replace(colReplaceName, "disabled='disabled'");
				}else if(this.readOnlyCellMap &&this.readOnlyCellMap.containsKey(rowNum)){
					var colMap = this.readOnlyCellMap.get(rowNum);
					if(colMap.containsKey(colName)){
						colReplaceName = configData.GRID_COL_DATA_NAME_READONLY_CLASS_HEAD+colName;
						//colReplaceName = colReplaceName.toLowerCase();
						tmpRowHtml = tmpRowHtml.replace(colReplaceName, configData.GRID_COL_TYPE_DISABLE_CLASS);
						
						colReplaceName = configData.GRID_COL_DATA_NAME_DISABLE_OBJECT_HEAD+colName+configData.GRID_COL_DATA_NAME_ATT_TAIL;
						colReplaceName = colReplaceName.toLowerCase();
						tmpRowHtml = tmpRowHtml.replace(colReplaceName, "disabled='disabled'");
					}
				}
			}
			
			appendHtml.push(tmpRowHtml);
			//if(this.sortGroupMap && this.sortGroupMap.containsKey(rowNum) && this.subTotalNums && this.subTotalNums.length > 0){
			if(this.subTotalView && this.sortGroupMap && this.sortGroupMap.containsKey(i)){
				var tmpvalue;
				var formatList;
				var totNumList = this.sortGroupMap.get(i).get("T");
				//tmpRowHtml = this.subTotalRowHtml;
				var $tmpSubObj = this.$subTotalRow.clone();
				for(var j=0;j<this.subTotalNums.length;j++){
					tmpvalue = totNumList[j].toString();
					formatList = this.colFormatMap.get(this.subTotalNums[j]);
					tmpvalue = uiList.getDataFormat(formatList, tmpvalue, true);
					$tmpSubObj.find("["+configData.GRID_COL_NAME+"="+this.subTotalNums[j]+"]").text(tmpvalue);
				}
				$tmpSubObj.find("["+configData.GRID_COL_NAME+"="+this.subTotalCols[0]+"]").text("Sub total ("+(this.sortGroupMap.get(i).get("E")-this.sortGroupMap.get(i).get("S")+1)+")");
				//$tmpSubObj.attr(configData.GRID_ROW_TOTAL_ATT, i);
				appendHtml.push($tmpSubObj.wrapAll("<div/>").parent().html());
				if(i == (this.viewDataList.length-1)){
					for(var j=0;j<this.subTotalNums.length;j++){
						tmpvalue = this.subTotalSumList[j].toString();
						formatList = this.colFormatMap.get(this.subTotalNums[j]);
						tmpvalue = uiList.getDataFormat(formatList, tmpvalue, true);
						$tmpSubObj.find("["+configData.GRID_COL_NAME+"="+this.subTotalNums[j]+"]").text(tmpvalue);
					}
					$tmpSubObj.find("["+configData.GRID_COL_NAME+"="+this.subTotalCols[0]+"]").text("Total");
					//$tmpSubObj.attr(configData.GRID_ROW_TOTAL_ATT, -1);
					appendHtml.push($tmpSubObj.wrapAll("<div/>").parent().html());
				}
			}
		}
		
		if(numSetType){
			this.startRowNum = startRow;
			this.endRowNum = endRow;
		}
		
		return appendHtml;
	},
	checkGridColor : function(rowNum, colName, removeType) {
		var colClass;
		var $rowObj = this.$box.find("["+configData.GRID_ROW_NUM+"="+rowNum+"]");
		if(colName){
			var $colObj = $rowObj.find("["+configData.GRID_COL_NAME+"="+colName+"]");
			var colValue = this.getColValue(rowNum, colName);
			//event fn
			if(commonUtil.checkFn("gridListColTextColorChange")){
				colClass = gridListColTextColorChange(this.id, rowNum, colName, colValue, removeType, true);
			}
			if(colClass){
				if(removeType){
					$colObj.removeClass(colClass);
				}else{
					$colObj.addClass(colClass);
				}
			}
			
			colClass = null;
			//event fn
			if(commonUtil.checkFn("gridListColBgColorChange")){
				colClass = gridListColBgColorChange(this.id, rowNum, colName, colValue, removeType, true);
			}
			
			if(colClass){
				if(removeType){
					$colObj.removeClass(colClass);
				}else{
					$colObj.addClass(colClass);
				}
			}
		}else{
			//event fn
			if(commonUtil.checkFn("gridListRowTextColorChange")){
				colClass = gridListRowTextColorChange(this.id, rowNum, removeType, true);
			}
			if(colClass){
				if(removeType){
					$rowObj.find(this.colTagName).removeClass(colClass);
				}else{
					$rowObj.find(this.colTagName).addClass(colClass);
				}
			}
			
			colClass = null;
			//event fn
			if(commonUtil.checkFn("gridListRowBgColorChange")){
				colClass = gridListRowBgColorChange(this.id, rowNum, removeType, true);
			}
			if(colClass){
				if(removeType){
					$rowObj.find(this.colTagName).removeClass(colClass);
					$rowObj.removeClass(colClass);
				}else{
					$rowObj.find(this.colTagName).addClass(colClass);
					$rowObj.addClass(colClass);
				}
			}
		}
	},
	removeGridColor : function(rowNum, colName, className) {
		var $rowObj = this.$box.find("["+configData.GRID_ROW_NUM+"="+rowNum+"]");
		if($rowObj.length > 0){
			if(colName){
				var $colObj = $rowObj.find("["+configData.GRID_COL_NAME+"="+colName+"]");
				$colObj.removeClass(className);
			}else{
				$rowObj.find(this.colTagName).removeClass(className);
				$rowObj.removeClass(className);
			}
		}
	},
	viewDataCheck : function(startRow, endRow) {
		var gridBox = this;
		for(var i=startRow;i<=endRow;i++){
			var rowNum = this.viewDataList[i];
			var $rowObj = this.$box.find("["+configData.GRID_ROW_NUM+"="+rowNum+"]");
			var rowState = this.getRowState(rowNum);
			
			if(rowState != configData.GRID_ROW_STATE_INSERT){
				if(this.modifyRow.containsKey(rowNum)){
					var updatColMap = this.modifyCols[rowNum];
					if(updatColMap){
						for(var prop in updatColMap.map){
							if(this.editedClassType){
								$rowObj.find("["+configData.GRID_COL_NAME+"="+prop+"]").addClass(configData.GRID_EDITED_BACK_CLASS);
							}							
						}
					}
				}
			}			
			
			if(rowState == configData.GRID_ROW_STATE_INSERT){
				//for(var prop in this.pkcolMap.map) {
					$rowObj.find("["+configData.GRID_COL_TYPE_PK+"]").each(function(i, findElement){
						var $obj = jQuery(findElement);
						//$obj.addClass(configData.GRID_EDIT_BACK_CLASS);
						
						var colType = $obj.attr(configData.GRID_COL_TYPE);
						if(colType == configData.GRID_COL_TYPE_TEXT){
							$obj.removeClass(configData.GRID_COL_TYPE_TEXT_CLASS);
							$obj.attr(configData.GRID_COL_TYPE, configData.GRID_COL_TYPE_INPUT);
							if(!$obj.attr(configData.VALIDATION_ATT)){
								$obj.attr(configData.VALIDATION_ATT, configData.VALIDATION_REQUIRED);
							}
						}else if(colType == configData.GRID_COL_TYPE_SELECT){
							var $select = $obj.find("select");
							$select.removeAttr("disabled");
							$select.removeClass(configData.GRID_COL_TYPE_DISABLE_CLASS);
						}
					});
				//}
			}	
			
			if(this.selectRow.containsKey(rowNum)){
				$rowObj.find("["+configData.GRID_COL_TYPE+"="+configData.GRID_COL_TYPE_ROWCHECK+"]").find("input").prop("checked",true);
				if(this.selectRowClassView){
					$rowObj.addClass(configData.GRID_ROW_SELECT_CLASS);
				}
			}
			if(this.focusRowNum == rowNum){
				$rowObj.addClass(configData.GRID_ROW_FOCUS_CLASS);
				if(rowState == configData.GRID_ROW_STATE_INSERT){
					$rowObj.find("["+configData.GRID_COL_TYPE+"="+configData.GRID_COL_TYPE_INPUT+"]:first").trigger("click");
				}
			}
		}
		//this.$box.show();
	},
	removeUnselect : function() {
		var selectData = new Array();;
		for(var prop in this.selectRow.map){
			selectData.push(this.data[prop]);
		}
		
		var dataString = this.cols.join(configData.DATA_COL_SEPARATOR)+configData.DATA_ROW_SEPARATOR;
		dataString += selectData.join(configData.DATA_ROW_SEPARATOR);
		this.reset();
		this.setData(dataString);
		this.setViewAll(true);
	},
	setReadOnlyProp : function(readonlyType, colList) {
		if(colList && colList.length > 0){
			if(readonlyType){
				this.readOnlyColList = colList;
				this.readOnlyColMap = new DataMap();
				for(var i=0;i<colList.length;i++){
					this.readOnlyColMap.put(colList[i], readonlyType);
				}
			}else{
				if(this.readOnlyColList && this.readOnlyColList.length > 0){
					for(var i=this.readOnlyColList.length-1;i>=0;i--){
						for(var j=0;j<colList.length;j++){
							if(this.readOnlyColList[i] == colList[j]){
								commonUtil.removeRow(this.readOnlyColList, i);
								break;
							}
						}
					}
				}
				if(this.readOnlyColMap){
					for(var i=0;i<colList.length;i++){
						this.readOnlyColMap.remove(colList[i]);
					}
				}				
			}
		}else{
			this.readOnlyType = readonlyType;
			this.readOnlyColList = null;
			this.readOnlyColMap = null;
			/*
			if(readonlyType){
				this.readOnlyType = readonlyType;
			}else{
				this.readOnlyType = readonlyType;
				this.readOnlyColList = null;
				this.readOnlyColMap = null;
			}
			*/		
		}
	},
	setReadOnly : function(readonlyType, colList) {	
		this.setReadOnlyProp(readonlyType, colList);
		if(!readonlyType && !colList){
			this.setGridReadonlyClass(true);
		}else{
			this.setGridReadonlyClass();
		}		
		if(this.data.length > 0){
			//this.reloadView();
		}
	},
	setRowReadOnly : function(rowNum, readonlyType, colList) {
		if(readonlyType instanceof Array){
			colList = readonlyType.slice(0);
			readonlyType = true;
		}
		
		var colMap;
		if(colList){
			colMap = new DataMap();
			for(var i=0;i<colList.length;i++){
				colMap.put(colList[i], readonlyType);
			}
			if(this.readOnlyCellMap == null){
				this.readOnlyCellMap = new DataMap();
			}
			if(this.readOnlyCellMap.containsKey(rowNum)){
				var tmpMap = this.readOnlyCellMap.get(rowNum);
				tmpMap.putAll(colMap);
				colMap = tmpMap;
			}	
			this.readOnlyCellMap.put(rowNum, colMap);
		}else{
			if(this.readOnlyRowMap == null){
				this.readOnlyRowMap = new DataMap();
			}
			this.readOnlyRowMap.put(rowNum, readonlyType);
		}		
		
		this.setRowReadOnlyCols(rowNum, readonlyType, colMap);
		
		/*
		if(readonlyType instanceof Array){
			var readOnlyColsMap = new DataMap();
			for(var i=0;i<readonlyType.length;i++){
				readOnlyColsMap.put(readonlyType[i], true);
			}
			
			this.readOnlyRowMap.remove(rowNum);
			this.readOnlyRowMap.put(rowNum, readOnlyColsMap);
			
			this.setRowReadOnlyCols(rowNum, readOnlyColsMap);
		}else{
			this.readOnlyRowMap.put(rowNum, readonlyType);
			this.setRowReadOnlyCols(rowNum, readonlyType);
		}
		*/
	},
	setRowReadOnlyCols : function(rowNum, readonlyType, colMap) {
		//if(rowNum >= this.startRowNum && rowNum <= this.endRowNum){
			var $row = this.$box.find("["+configData.GRID_ROW_NUM+"="+rowNum+"]");
			if($row.length > 0){
				if(colMap){
					for(var prop in colMap.map){
						if(this.viewColMap.containsKey(prop) || this.gridMobileType){
							if(colMap.get(prop)){
								$row.find("["+configData.GRID_COL_NAME+"="+prop+"]."+configData.GRID_EDIT_BACK_CLASS).addClass(configData.GRID_COL_TYPE_DISABLE_CLASS).removeClass(configData.GRID_EDIT_BACK_CLASS);
								$row.find("["+configData.GRID_COL_NAME+"="+prop+"]").find("select,input").attr("disabled", "disabled");
							}else{
								$row.find("["+configData.GRID_COL_NAME+"="+prop+"]."+configData.GRID_COL_TYPE_DISABLE_CLASS).addClass(configData.GRID_EDIT_BACK_CLASS).removeClass(configData.GRID_COL_TYPE_DISABLE_CLASS);
								$row.find("["+configData.GRID_COL_NAME+"="+prop+"]").find("select,input").removeAttr("disabled", "disabled");
							}	
						}
					}
				}else if(readonlyType){
					$row.find(this.colTagName).addClass(configData.GRID_COL_TYPE_DISABLE_CLASS);
					$row.find("select,input").attr("disabled", "disabled");
				}else{
					$row.find(this.colTagName).removeClass(configData.GRID_COL_TYPE_DISABLE_CLASS);
					$row.find("select,input").removeAttr("disabled", "disabled");
				}
			}			
		//}
	},
	setObjectReadOnly : function($obj, readonlyType) {
		if(readonlyType == undefined){
			readonlyType = true;
		}
		if(readonlyType){
			$obj.addClass(configData.GRID_COL_TYPE_DISABLE_CLASS);
			$obj.find("select,input").attr("disabled", "disabled");
		}else{
			$obj.removeClass(configData.GRID_COL_TYPE_DISABLE_CLASS);
			$obj.find("select,input").removeAttr("disabled", "disabled");
		}
	},
	/*
	setRowClass : function($rowObj) {
		var rowNum = $rowObj.attr(configData.GRID_ROW_NUM);
		
		//수정 컬럼 체크
		if(this.modifyRow.containsKey(rowNum)){
			var modifyCol = this.modifyCols[rowNum];
			if(updatColMap){
				for(var prop in updatColMap.map){
					$rowObj.find("["+configData.GRID_COL_NAME+"="+prop+"]")
					.addClass(configData.GRID_EDITED_BACK_CLASS);
				}
			}
		}
	},
	*/
	firstRowFocus : function() {
		if(this.viewDataList.length > 0){
			this.setScrollTop();
			var rowNum = this.viewDataList[0];
			this.rowFocus(rowNum, true);
		}		
	},
	preRowFocus : function() {
		if(this.viewDataList.length > 0){
			var lastRowNum = this.viewDataList[0];
			if(this.focusRowNum == lastRowNum){
				return;
			}else{
				var fViewRow = this.getViewRowNum(this.focusRowNum);
				fViewRow--;
				var rowNum = this.viewDataList[fViewRow];				
				this.rowFocus(rowNum, true);
			}			
		}		
	},
	nextRowFocus : function() {
		if(this.viewDataList.length > 0){
			var lastRowNum = this.viewDataList[this.viewDataList.length-1];
			if(this.focusRowNum == lastRowNum){
				return;
			}else{
				var fViewRow = this.getViewRowNum(this.focusRowNum);
				fViewRow++;
				var rowNum = this.viewDataList[fViewRow];				
				this.rowFocus(rowNum, true);
			}			
		}		
	},
	lastRowFocus : function() {
		if(this.viewDataList.length > 0){
			var rowNum = this.viewDataList[this.viewDataList.length-1];
			
			this.rowFocus(rowNum, true);
		}		
	},
	getViewRowNum : function(rowNum) {
		for(var i=0;i<this.viewDataList.length;i++){
			if(rowNum == this.viewDataList[i]){
				return i;
			}
		}
		
		return -1;
		//return parseInt(this.$box.find("["+configData.GRID_ROW_NUM+"="+rowNum+"]").attr(configData.GRID_ROW_VIEWNUM));
	},
	getRowNum : function(rowViewNum) {
		return this.viewDataList[rowViewNum];
		//return parseInt(this.$box.find("["+configData.GRID_ROW_VIEWNUM+"="+rowViewNum+"]").attr(configData.GRID_ROW_NUM));
	},
	rowFocus : function(rowNum, eventType, objFocusType) {
		if(this.focusRowNum != rowNum){
			if(this.itemGrid){
				if(this.searchRowNum != -1 && this.searchRowNum != rowNum){
					var modifyCheck = false;
					for(var i=0;i<this.itemGridList.length;i++){
						var count = gridList.getModifyRowCount(this.itemGridList[i]);
						if(count > 0){
							modifyCheck = true;
							break;
						}
					}
					if(modifyCheck){
						if(commonUtil.msgConfirm("COMMON_M0462")){
							
						}else{
							return;
						}
					}
					this.searchRowNum = -1;
					for(var i=0;i<this.itemGridList.length;i++){
						gridList.resetGrid(this.itemGridList[i])
					}
				}
			}
			
			if(this.autoNewRowType){
				if(this.viewDataList[this.viewDataList.length-1] == rowNum){
					this.addRow(null, false);
				}
			}/*else if(this.autoCopyRowType){
				if(this.viewDataList[this.viewDataList.length-1] == rowNum){
					this.addRow(this.getRowData(rowNum), false);
				}
			}*/
			if(this.focusRowNum != -1){
				this.$box.find("["+configData.GRID_ROW_NUM+"="+this.focusRowNum+"]").removeClass(configData.GRID_ROW_FOCUS_CLASS);
				if(this.colFixType){
					var $colFixRowObj = this.$colFix.find("["+configData.GRID_ROW_NUM+"="+this.focusRowNum+"]");
					$colFixRowObj.removeClass(configData.GRID_ROW_FOCUS_CLASS);
				}
			}
			
			var $rowObj = this.$box.find("["+configData.GRID_ROW_NUM+"="+rowNum+"]");
			$rowObj.addClass(configData.GRID_ROW_FOCUS_CLASS);
			
			if(this.colFixType){
				var $colFixRowObj = this.$colFix.find("["+configData.GRID_ROW_NUM+"="+rowNum+"]");
				$colFixRowObj.addClass(configData.GRID_ROW_FOCUS_CLASS);
			}

			/*
			if(rowNum != this.focusRowNum){
				var $lastCol = this.$box.find("["+configData.GRID_ROW_NUM+"="+this.focusRowNum+"]").find("["+configData.GRID_COL_NAME+"="+this.focusColName+"]");
				var $tmpInput = $lastCol.find("input");
				if($tmpInput){
					this.inputBlurEvent($tmpInput);
				}
			}
			*/
			this.focusRowNum = parseInt(rowNum);
			//this.lastRowNum = this.focusRowNum;
			
			this.setBindArea(rowNum);
			
			if(this.focusRowCheck){
				this.setRowCheck(rowNum, true, true);
			}
			
			if(objFocusType){
				if($rowObj.find("select:first").length > 0){
					$rowObj.find("select:first").focus();
				}else if($rowObj.find("["+configData.GRID_COL_TYPE+"="+configData.GRID_COL_TYPE_INPUT+"]:first").length > 0){
					$rowObj.find("["+configData.GRID_COL_TYPE+"="+configData.GRID_COL_TYPE_INPUT+"]:first").trigger("click");
				}else{
					$rowObj.find("["+configData.GRID_COL_TYPE+"]:first").trigger("click");
				}
			}

			if(eventType){
				//event fn
				if(commonUtil.checkFn("gridListEventRowFocus")){
					gridListEventRowFocus(this.id, rowNum);
				}
			}
		}
	},
	moveFocus : function(changeNum) {
		var rowViewNum = this.getViewRowNum(this.focusRowNum);
		rowViewNum += changeNum;
		if(rowViewNum < 0){
			return;
			rowViewNum = 0;
		}else if(rowViewNum > this.viewDataList.length-1){
			return;
			rowViewNum = this.viewDataList.length-1;
		}
		this.setFocus(this.getRowNum(rowViewNum), this.focusColName);
	},
	/*
	changeFocus : function($obj, changeNum, keyType) {
		var $rowObj = $obj.parent();
		var rowViewNum = parseInt($rowObj.attr(configData.GRID_ROW_VIEWNUM));
		rowViewNum += changeNum;
		if(rowViewNum < 0){
			return;
			rowViewNum = 0;
		}else if(rowViewNum > this.viewDataList.length-1){
			return;
			rowViewNum = this.viewDataList.length-1;
		}
		var rowNum = this.getRowNum(rowViewNum);
		if(this.scrollType){
			if(rowViewNum < this.startRowNum || rowViewNum > this.endRowNum){
				this.changeRow(changeNum);
			}
		}		
		var colName = $obj.attr(configData.GRID_COL_NAME);

		this.setFocus(rowNum, colName);
	},
	*/
	getFocusRowNum : function() {
		return this.focusRowNum;
	},
	eventDataBindEnd : function(excelLoadType, dataLength) {	
		//event fn
		if(commonUtil.checkFn("gridListEventDataBindEnd")){
			if(dataLength == undefined){
				dataLength = this.data.length;
			}
			gridListEventDataBindEnd(this.id, dataLength, excelLoadType);
		}
		if(this.itemGrid && this.itemSearch && this.data.length > 0){
			this.searchRowNum = this.viewDataList[0];
			//event fn
			if(commonUtil.checkFn("gridListEventItemGridSearch")){
				gridListEventItemGridSearch(this.id, this.viewDataList[0], this.itemGridList);
			}
		}
	},
	setBindArea : function(rowNum) {
		if(this.bindArea){
			if(rowNum != undefined){
				var rowData = this.getRowData(rowNum);
				dataBind.dataNameBind(rowData, this.$area);				
			}else{
				var rowData = new DataMap();
				for(var i=0;i<this.cols.length;i++){
					rowData.put(this.cols[i],"");
				}
				dataBind.dataNameBind(rowData, this.$area);
			}
		}
	},
	rowUp : function() {
		var rowViewNum = this.getViewRowNum(this.focusRowNum);
		if(this.focusRowNum == -1 || rowViewNum == 0){
			return;
		}		
		var preRowNum = this.viewDataList[rowViewNum-1];
		var preRowViewNum = this.getViewRowNum(preRowNum);
		var $rowObj = this.$box.find("["+configData.GRID_ROW_NUM+"="+this.focusRowNum+"]");
		var $preRowObj = this.$box.find("["+configData.GRID_ROW_NUM+"="+preRowNum+"]");
		var pid = this.getColValue(this.focusRowNum, this.treePid);
		var prePid = this.getColValue(preRowNum, this.treePid);
		if(pid != prePid){
			var tmpRowNum;
			var tmpPid;
			var tmpRowViewNum;
			var tmpNextRowViewNum;
			for(var i=preRowViewNum-1;i>=0;i--){
				tmpRowNum = this.viewDataList[i];
				tmpPid = this.getColValue(tmpRowNum, this.treePid);
				if(tmpPid == pid){
					tmpRowViewNum = i;
					break;
				}
			}
			if(tmpRowViewNum>=0){
				for(var i=rowViewNum+1;i<this.viewDataList.length;i++){
					tmpRowNum = this.viewDataList[i];
					tmpPid = this.getColValue(tmpRowNum, this.treePid);
					if(tmpPid == pid){
						tmpNextRowViewNum = i;
						break;
					}
				}
				if(!tmpNextRowViewNum){
					tmpNextRowViewNum = this.viewDataList.length;
				}
				var tmpRows = new Array();
				for(var i=rowViewNum;i<tmpNextRowViewNum;i++){
					tmpRowNum = this.viewDataList[i];
					var $tmpRowObj = this.$box.find("["+configData.GRID_ROW_NUM+"="+tmpRowNum+"]");
					tmpRows.push($tmpRowObj);
				}
				tmpRowNum = this.viewDataList[tmpRowViewNum];
				var $tmpRow = this.$box.find("["+configData.GRID_ROW_NUM+"="+tmpRowNum+"]");
				for(var i=0;i<tmpRows.length;i++){
					$tmpRow.before(tmpRows[i]);
				}
				
				var $rows = this.$box.find("["+configData.GRID_ROW_NUM+"]");
				this.viewDataList = new Array();
				for(var i=0;i<$rows.length;i++){
					tmpRowNum = parseInt($rows.eq(i).attr(configData.GRID_ROW_NUM));
					this.viewDataList[i] = tmpRowNum;
				}
				
				//this.resetSeq();
			}
		}else{
			var seq = this.getColValue(this.focusRowNum, this.treeSeq);
			var preSeq = this.getColValue(preRowNum, this.treeSeq);
			
			this.setColValue(this.focusRowNum, this.treeSeq, preSeq, true, true, $rowObj);
			//this.setColValue(this.focusRowNum, this.treeSeq, preSeq);
			//this.setColValue(preRowNum, this.treeSeq, seq);
			this.setColValue(preRowNum, this.treeSeq, seq, true, true, $preRowObj);
			
			this.viewDataList[rowViewNum-1] = this.focusRowNum;
			this.viewDataList[rowViewNum] = preRowNum;
			//$rowObj.attr(configData.GRID_ROW_VIEWNUM, preRowViewNum);
			//$preRowObj.attr(configData.GRID_ROW_VIEWNUM, rowViewNum);
			
			$preRowObj.before($rowObj);
		}		
		
		//this.rowFocus(preRowNum, false);
	},
	rowDown : function() {
		var rowViewNum = this.getViewRowNum(this.focusRowNum);
		if(this.focusRowNum == -1 || rowViewNum == this.viewDataList.length-1){
			return;
		}
		var nextRowNum = this.viewDataList[rowViewNum+1];
		var nextRowViewNum = this.getViewRowNum(nextRowNum);
		var $rowObj = this.$box.find("["+configData.GRID_ROW_NUM+"="+this.focusRowNum+"]");
		var $nextRowObj = this.$box.find("["+configData.GRID_ROW_NUM+"="+nextRowNum+"]");
		var pid = this.getColValue(this.focusRowNum, this.treePid);
		var nextPid = this.getColValue(nextRowNum, this.treePid);
		if(pid != nextPid){
			var tmpRowNum;
			var tmpPid;
			var tmpRowViewNum;
			var tmpNextRowViewNum;
			for(var i=nextRowViewNum+1;i<this.viewDataList.length;i++){
				tmpRowNum = this.viewDataList[i];
				tmpPid = this.getColValue(tmpRowNum, this.treePid);
				if(tmpPid == pid){
					tmpRowViewNum = i;
					break;
				}
			}
			if(tmpRowViewNum){
				for(var i=tmpRowViewNum+1;i<this.viewDataList.length;i++){
					tmpRowNum = this.viewDataList[i];
					tmpPid = this.getColValue(tmpRowNum, this.treePid);
					if(tmpPid == pid){
						tmpNextRowViewNum = i;
						break;
					}
				}
				if(!tmpNextRowViewNum){
					tmpNextRowViewNum = this.viewDataList.length;
				}
				var tmpRows = new Array();
				for(var i=rowViewNum;i<tmpRowViewNum;i++){
					tmpRowNum = this.viewDataList[i];
					var $tmpRowObj = this.$box.find("["+configData.GRID_ROW_NUM+"="+tmpRowNum+"]");
					tmpRows.push($tmpRowObj);
				}
				tmpRowNum = this.viewDataList[tmpNextRowViewNum-1];
				var $tmpRow = this.$box.find("["+configData.GRID_ROW_NUM+"="+tmpRowNum+"]");
				for(var i=tmpRows.length-1;i>=0;i--){
					$tmpRow.after(tmpRows[i]);
				}
				
				var $rows = this.$box.find("["+configData.GRID_ROW_NUM+"]");
				this.viewDataList = new Array();
				for(var i=0;i<$rows.length;i++){
					tmpRowNum = parseInt($rows.eq(i).attr(configData.GRID_ROW_NUM));
					this.viewDataList[i] = tmpRowNum;
				}
				
				//this.resetSeq();
			}
		}else{
			var seq = this.getColValue(this.focusRowNum, this.treeSeq);
			var nextSeq = this.getColValue(nextRowNum, this.treeSeq);
			
			this.setColValue(this.focusRowNum, this.treeSeq, nextSeq, true, true, $rowObj);
			//this.setColValue(this.focusRowNum, this.treeSeq, nextSeq);
			//this.setColValue(nextRowNum, this.treeSeq, seq);
			this.setColValue(nextRowNum, this.treeSeq, seq, true, true, $nextRowObj);
			
			this.viewDataList[rowViewNum+1] = this.focusRowNum;
			this.viewDataList[rowViewNum] = nextRowNum;
			//$rowObj.attr(configData.GRID_ROW_VIEWNUM, nextRowViewNum);
			//$nextRowObj.attr(configData.GRID_ROW_VIEWNUM, rowViewNum);
			
			$nextRowObj.after($rowObj);
		}
	},	
	copyRow : function(focusType) {
		if(this.focusRowNum>=0){
			var rowNum = this.data.length;
			
			var sourceData = this.getRowData(this.focusRowNum);
			//event fn
			if(commonUtil.checkFn("gridListEventRowCopyBefore")){
				sourceData = gridListEventRowCopyBefore(this.id, rowNum, sourceData);
				if(sourceData == false){
					return;
				}
			}
			var rowData = new Array();
			for(var i=0;i<this.cols.length;i++){
				if(sourceData && sourceData.containsKey(this.cols[i])){
					rowData[i] = sourceData.get(this.cols[i]);
				}else{
					rowData[i] = "";
				}			
			}
			this.appendData(rowData.join(configData.DATA_COL_SEPARATOR));
			
			this.setRowState(rowNum, configData.GRID_ROW_STATE_INSERT);
			
			var rowViewNum = this.getViewRowNum(this.focusRowNum);
			
			var tmpList = this.viewDataList.slice(0,rowViewNum+1);
			tmpList.push(rowNum);	
			this.viewDataList = tmpList.concat(this.viewDataList.slice(rowViewNum+1));
			
			this.appendViewRow(rowViewNum+1);
			
			var $newRow = this.$box.find("["+configData.GRID_ROW_NUM+"="+rowNum+"]");
			var $tmpRow = this.$box.find("["+configData.GRID_ROW_NUM+"="+this.focusRowNum+"]");
			$tmpRow.after($newRow);
			//$newRow.remove();
			
			if(this.editedClassType){
				$newRow.find("."+configData.GRID_EDIT_BACK_CLASS).addClass(configData.GRID_EDITED_BACK_CLASS);
			}			

			if(focusType){
				this.rowFocus(rowNum, true, true);
			}
			
			this.setInfo();
			
			//event fn
			if(commonUtil.checkFn("gridListEventRowCopyAfter")){
				gridListEventRowCopyAfter(this.id, rowNum);
			}
		}		
	},
	addRow : function(beforeData, focusType) {
		if(focusType == undefined){
			focusType = true;
		}
		this.startHeadColDrag();
		var rowNum = this.data.length;
		//if(this.appendRow && this.focusRowNum>=0){
		if(this.tree){
			var rowViewNum = this.getViewRowNum(this.focusRowNum);
			var preRowNum = this.viewDataList[rowViewNum-1];
			var nextRowNum = this.viewDataList[rowViewNum+1];	
			var mid = this.getColValue(this.focusRowNum, this.treeId);
			var preMid = this.getColValue(this.preRowNum, this.treeId);
			var nextMid = this.getColValue(this.nextRowNum, this.treeId);
			var pid = this.getColValue(this.focusRowNum, this.treePid);
			var prePid = this.getColValue(preRowNum, this.treePid);
			var nextPid = this.getColValue(nextRowNum, this.treePid);
			var rowData;
			if(mid == nextPid){
				beforeData = this.getRowData(nextRowNum);
			}else if(pid == nextPid){
				beforeData = this.getRowData(this.focusRowNum);
				var tmpLvl = this.getColValue(this.focusRowNum, this.treeLvl);
				tmpLvl = parseInt(tmpLvl)+1;
				beforeData.put(this.treePid, beforeData.get(this.treeId));
				beforeData.put(this.treeLvl, tmpLvl);
			}else{
				beforeData = this.getRowData(this.focusRowNum);
			}
			beforeData.remove(this.treeId);
		}
		//event fn
		if(commonUtil.checkFn("gridListEventRowAddBefore")){
			if(!beforeData){
				beforeData = gridListEventRowAddBefore(this.id, rowNum, beforeData);
				if(beforeData == false){
					return;
				}
			}
		}
		
		var rowData = new Array();
		for(var i=0;i<this.cols.length;i++){
			if(beforeData && beforeData.containsKey(this.cols[i])){
				rowData[i] = beforeData.get(this.cols[i]);
			}else{
				rowData[i] = "";
			}
		}
		this.appendData(rowData.join(configData.DATA_COL_SEPARATOR));
		
		this.setRowState(rowNum, configData.GRID_ROW_STATE_INSERT);
		/*
		this.modifyRow.put(rowNum, configData.GRID_ROW_STATE_INSERT);
		
		var rowData = this.getRowData(rowNum);
		this.modifyCols[rowNum] = rowData;
		this.sourceCols[rowNum] = rowData;
		*/
		
		//if(this.appendRow && this.focusRowNum>=0){
		if(this.tree){
			var rowViewNum = this.getViewRowNum(this.focusRowNum);
			var tmpList = this.viewDataList.slice(0,rowViewNum+1);
			tmpList.push(rowNum);			
			this.viewDataList = tmpList.concat(this.viewDataList.slice(rowViewNum+1));
			
			this.appendViewRow(rowViewNum+1);
			
			var $newRow = this.$box.find("["+configData.GRID_ROW_NUM+"="+rowNum+"]");
			var $tmpRow = this.$box.find("["+configData.GRID_ROW_NUM+"="+this.focusRowNum+"]");
			
			if(this.editedClassType){
				$newRow.find("."+configData.GRID_EDIT_BACK_CLASS).addClass(configData.GRID_EDITED_BACK_CLASS);
			}
			
			$tmpRow.after($newRow.clone());
			$newRow.remove();
			if(focusType){
				this.rowFocus(rowNum, true, true);
			}			
		}else{
			if(this.addRowAppendType){
				this.viewDataList.push(rowNum);

				this.endRowNum = this.viewDataList.length-1;
				if(this.scrollType){					
					if(this.viewDataList.length == 1){
						this.setHeight();
					}
					this.changeStartRow();
				}else{
					this.appendViewRow(this.viewDataList.length-1);
				}
				
				this.setScrollBottom();
				
				if(this.editedClassType){
					this.$bodyBox.find("["+configData.GRID_ROW+"]:last").find("."+configData.GRID_EDIT_BACK_CLASS).addClass(configData.GRID_EDITED_BACK_CLASS);
				}
				
				if(focusType){
					this.rowFocus(this.viewDataList[this.viewDataList.length-1], true, true);
				}
			}else{
				this.viewDataList.unshift(rowNum);
				
				if(this.scrollType){
					this.endRowNum = this.viewRowCount;
					if(this.viewDataList.length == 1){
						this.setHeight();
					}
					this.changeStartRow();
				}else{
					this.endRowNum = this.viewDataList.length-1;
					this.appendViewRow(0, true);
				}
				
				this.setScrollTop();
				
				if(this.editedClassType){
					this.$bodyBox.find("["+configData.GRID_ROW+"]:first").find("."+configData.GRID_EDIT_BACK_CLASS).addClass(configData.GRID_EDITED_BACK_CLASS);
				}
				
				if(focusType){
					this.rowFocus(this.viewDataList[0], true, true);
				}
			}			
		}
		
		if(this.tree){
			//this.resetSeq();
		}
		
		this.setInfo();
		
		//event fn
		if(commonUtil.checkFn("gridListEventRowAddAfter")){
			gridListEventRowAddAfter(this.id, rowNum);
		}
	},
	appendViewRow : function(rowViewNum, prependType) {
		var rowViewHtml;
		if(rowViewNum == undefined){
			rowViewNum = this.viewDataList.length-1;
		}

		rowViewHtml = this.setRowViewHtml(rowViewNum, rowViewNum, false);		
		
		var $rowObj = jQuery(rowViewHtml[0]);

		this.appendView($rowObj, prependType);
		//this.rowFocus(this.viewDataList[this.viewDataList.length-1], true, true);
		this.viewDataCheck(rowViewNum, rowViewNum);
	},
	deleteSelectRow : function() {
		if(this.selectRow.size() > 0){
			if(!confirm(commonUtil.getMsg(configData.MSG_MASTER_DELETE_CONFIRM))){
				return;
			}
			for(var prop in this.selectRow.map){
				this.deleteRow(prop, false);
			}
		}
	},
	deleteRow : function(rowNum, msgType) {
		if(rowNum == undefined){
			rowNum = this.focusRowNum;
		}
		if(msgType != false){
			msgType = true;
		}
		if(rowNum != -1){		
			if(msgType && !confirm(commonUtil.getMsg(configData.MSG_MASTER_DELETE_CONFIRM))){
				return;
			}
			
			if(this.tree){
				commonUtil.displayLoading(true);
				var gridBox = this;
				var pid = this.getColValue(rowNum, this.treeId);
				if(pid){
					this.$box.find("["+configData.GRID_COL_NAME+"="+this.treePid+"]").filter("["+configData.GRID_COL_VALUE+"="+pid+"]").each(function(i, findElement){
						var $obj = jQuery(findElement);
						var sRowNum = $obj.parent().attr(configData.GRID_ROW_NUM);
						gridBox.deleteRow(sRowNum, false);
					});
				}
				commonUtil.displayLoading(false);
			}
			
			var rowViewNum = this.getViewRowNum(rowNum);
			
			var $focusRow = this.$box.find("["+configData.GRID_ROW_NUM+"="+rowNum+"]");
			var focusRowState = this.getRowState(rowNum);
			var deleteType = true;
			if(focusRowState == configData.GRID_ROW_STATE_INSERT){
				this.setRowState(rowNum, configData.GRID_ROW_STATE_REMOVE);
				/*
				this.data = commonUtil.removeRow(this.data, rowNum);
				for(var i=0;i<this.viewDataList.length;i++){
					if(this.viewDataList[i] > rowNum){
						this.viewDataList[i] = this.viewDataList[i]-1;
					}
				}
				
				this.modifyRow.remove(rowNum);
				var tmpArray = new Array();
				for(var prop in this.modifyRow.map){
					if(prop > rowNum){
						tmpArray.push(prop);
					}
				}
				tmpArray.sort();
				for(var i=0;i<tmpArray.length;i++){
					this.modifyRow.put(tmpArray[i]-1, this.modifyRow.get(tmpArray[i]));
					this.modifyCols[tmpArray[i]-1] = this.modifyCols[tmpArray[i]];
					this.modifyRow.remove(tmpArray[i]);
					this.modifyCols[tmpArray[i]] = null;
				}
				
				this.selectRow.remove(rowNum);
				tmpArray = new Array();
				for(var prop in this.selectRow.map){
					if(prop > rowNum){
						tmpArray.push(prop);
					}
				}
				tmpArray.sort();
				for(var i=0;i<tmpArray.length;i++){
					this.selectRow.put(tmpArray[i]-1, this.selectRow.get(tmpArray[i]));
					this.selectRow.remove(tmpArray[i]);
				}
				
				var rowList = this.$box.find("["+configData.GRID_ROW_NUM+"]");
				var $rowObj;
				var tmpRowNum;
				var tmpRowViewNum;
				for(var i=0;i<rowList.length;i++){
					$rowObj = rowList.eq(i);
					tmpRowNum = $rowObj.attr(configData.GRID_ROW_NUM);
					//tmpRowViewNum = $rowObj.attr(configData.GRID_ROW_VIEWNUM);
					//tmpRowViewNum = this.getViewRowNum(tmpRowNum);
					if(tmpRowNum > rowNum){
						tmpRowNum = parseInt(tmpRowNum)-1;
						//tmpRowViewNum = parseInt(tmpRowViewNum)-1;
						$rowObj.attr(configData.GRID_ROW_NUM, tmpRowNum);
						//$rowObj.attr(configData.GRID_ROW_VIEWNUM, tmpRowViewNum);
					}
				}
				*/
			}else{
				//event fn
				if(commonUtil.checkFn("gridListEventRowRemove")){
					deleteType = gridListEventRowRemove(this.id, rowNum);
				}

				if(deleteType == false){
					return;
				}
				this.setRowState(rowNum, configData.GRID_ROW_STATE_DELETE);
			}
			this.viewDataList = commonUtil.removeRow(this.viewDataList, rowViewNum);
			$focusRow.remove();
			this.selectRow.remove(rowNum);
			
			rowViewNum--;
			var preRowNum = this.getRowNum(rowViewNum);		
			
			if(this.scrollType){
				this.changeEndRow();
			}else{
				this.viewRowReset();
			}
			
			this.setInfo();
			
			if(!preRowNum){
				preRowNum = this.getRowNum(0);
			}
			
			this.rowFocus(preRowNum);
			/*
			if(this.tree){
				var rowViewNum = this.getViewRowNum(rowNum);
				var nextRowNum = this.viewDataList[rowViewNum+1];
				this.resetSeq(10, nextRowNum);				
			}
			*/
			
			if(this.totalView){
				this.changeSumColAll();
			}
			
			//event fn
			if(commonUtil.checkFn("gridListEventRowRemoveAfter")){
				gridListEventRowRemoveAfter(this.id, rowNum);
			}
		}else{
			commonUtil.msgBox(configData.MSG_MASTER_ROW_SELECT);
		}
	},
	resetSeq : function(interval, startNum) {
		if(interval == undefined){
			interval = 10;
		}
		if(startNum == undefined){
			startNum = 0;
		}
		var seqNum = (startNum+1)*interval;
		var rowNum;
		for(var i=startNum;i<this.viewDataList.length;i++){
			rowNum =  this.viewDataList[i];
			this.setColValue(rowNum, this.treeSeq, commonUtil.leftPadding(seqNum, "0", 4));
			seqNum+=interval;
		}
		
		this.viewRowReset();
	},
	viewRowReset : function() {
		//var $rowList = this.$box.find("["+configData.GRID_ROW_NUM+"]");
		var $rowObj;
		var rowView;
		var rowNum;
		for(var i=0;i<this.viewDataList.length;i++){
			rowNum = this.viewDataList[i];
			$rowObj = this.$box.find("["+configData.GRID_ROW_NUM+"="+rowNum+"]");
			
			if(this.editable && this.modifyRow.get(rowNum) == configData.GRID_ROW_STATE_INSERT){
				rowView = configData.GRID_ROW_STATE_INSERT;
			}else if(this.editable && this.modifyRow.get(rowNum) == configData.GRID_ROW_STATE_UPDATE){
				rowView = configData.GRID_ROW_STATE_UPDATE;
			}else{
				rowView = i+1;
				if(this.pageCount){
					rowView += (this.pageNum-1)*this.pageCount;
				}
			}
			$rowObj.find("["+configData.GRID_COL_TYPE+"="+configData.GRID_COL_TYPE_ROWNUM+"]").text(rowView);
			//$rowObj.attr(configData.GRID_ROW_VIEWNUM, i);
		}
	},
	setComboOption : function(colName, comboType, comboData) {
		var $tmpObj = jQuery(this.rowHtml);
		var $tmpNewObj = jQuery(this.rowNewHtml);
		var $select = $tmpObj.find("["+configData.GRID_COL_NAME+"="+colName+"]").find("select");
		inputList.reloadCombo($select, comboType, comboData);
		
		$select.find("option").each(function(i, findElement){
			var $optionObj = jQuery(findElement);
			var tmpValue = $optionObj.attr("value");
			$optionObj.attr(configData.GRID_COL_DATA_NAME_OPTION_HEAD+colName+tmpValue+configData.GRID_COL_DATA_NAME_ATT_TAIL, '');
		});
		
		this.rowHtml = $tmpObj.clone().wrapAll("<div/>").parent().html();
		
		$select = $tmpNewObj.find("["+configData.GRID_COL_NAME+"="+colName+"]").find("select");
		inputList.reloadCombo($select, comboType, comboData);
		
		$select.find("option").each(function(i, findElement){
			var $optionObj = jQuery(findElement);
			var tmpValue = $optionObj.attr("value");
			$optionObj.attr(configData.GRID_COL_DATA_NAME_OPTION_HEAD+colName+tmpValue+configData.GRID_COL_DATA_NAME_ATT_TAIL, '');
		});
		
		this.rowNewHtml = $tmpNewObj.clone().wrapAll("<div/>").parent().html();
	},
	getColValue : function(rowNum, colName) {
		rowNum = parseInt(rowNum);
		if(this.modifyRow.containsKey(rowNum) && this.modifyRow.get(rowNum) != configData.GRID_ROW_STATE_DELETE && this.modifyCols[rowNum].containsKey(colName)){
			return this.modifyCols[rowNum].get(colName);
		}else if(this.mapData[rowNum]){
			return this.mapData[rowNum].get(colName);
		}else if(this.data[rowNum]){
			var rowData = this.data[rowNum].split(configData.DATA_COL_SEPARATOR);
			var colIndex;
			for(var i=0;i<this.cols.length;i++){
				if(colName == this.cols[i]){
					colIndex = i;
					break;
				}
			}
			var colValue = rowData[colIndex];
			if(this.colFormatMap.containsKey(colName)){
				var formatList = this.colFormatMap.get(colName);
				colValue = uiList.getDataFormat(formatList, colValue);
			}
			return colValue;
		}else{
			return undefined;
		}		
	},
	setAreaBind : function(rowNum, colName, colValue) {
		if(this.focusRowNum == rowNum && this.$area){
			var rowData;
			if(colName){
				rowData = new DataMap();
				rowData.put(colName, colValue);
			}else{
				rowData = this.getRowData(rowNum);
			}			
			dataBind.dataNameBind(rowData, this.$area);
		}
	},
	setRowState : function(rowNum, rowState) {
		if(this.modifyRow.containsKey(rowNum) && this.modifyRow.get(rowNum) == rowState){
			return;
		}
		if(rowState == configData.GRID_ROW_STATE_INSERT){
			this.modifyRow.put(rowNum, configData.GRID_ROW_STATE_INSERT);
			var rowData = this.getRowData(rowNum);
			this.modifyCols[rowNum] = new DataMap();
			this.modifyCols[rowNum].putAll(rowData);
			this.sourceCols[rowNum] = new DataMap();
			this.sourceCols[rowNum].putAll(rowData);
		}else if(rowState == configData.GRID_ROW_STATE_DELETE){
			this.modifyRow.put(rowNum, configData.GRID_ROW_STATE_DELETE);
		}else if(rowState == configData.GRID_ROW_STATE_REMOVE){
			this.modifyRow.put(rowNum, configData.GRID_ROW_STATE_REMOVE);
		}else if(rowState == configData.GRID_ROW_STATE_UPDATE){
			this.modifyRow.put(rowNum, configData.GRID_ROW_STATE_UPDATE);
		}else if(rowState == configData.GRID_ROW_STATE_READ){
			this.modifyRow.put(rowNum, configData.GRID_ROW_STATE_READ);
		}
	},
	checkSourceValue : function(rowNum, colName){
		var sourceColMap = this.sourceCols[rowNum];
		if(sourceColMap && sourceColMap.containsKey(colName)){
			return sourceColMap.get(colName);
		}else{
			return null;
		}
	},
	setColValue : function(rowNum, colName, colValue, eventType, viewType, $rowObj, $colObj, checkStart) {
		var state = this.getRowState(rowNum);
		
		if(!this.isAvailRow(rowNum)){
			return;
		}
		
		if(commonUtil.isJObjEmpty($rowObj) && (rowNum >= this.startRowNum && rowNum <= this.endRowNum)){
			$rowObj = this.$box.find("["+configData.GRID_ROW_NUM+"="+rowNum+"]");
			$colObj = $rowObj.find("["+configData.GRID_COL_NAME+"="+colName+"]");
		}
		
		if(this.colFormatMap.containsKey(colName)){
			var formatList = this.colFormatMap.get(colName);
			colValue = uiList.getDataFormat(formatList, colValue, true);
			colValue = uiList.getDataFormat(formatList, colValue);
		}
		
		if(checkStart == undefined){
			checkStart = true;
		}

		var modifyColMap = this.modifyCols[rowNum];
		var sourceColMap = this.sourceCols[rowNum];
		
		if(!modifyColMap){
			modifyColMap = new DataMap();
			this.modifyCols[rowNum] = modifyColMap;
		}
		
		var dataVal;
		if(sourceColMap){
			dataVal = sourceColMap.get(colName);
		}else{
			dataVal = this.getColValue(rowNum, colName);
		}
		
		var beforeVal;
		if(modifyColMap.containsKey(colName)){
			beforeVal = modifyColMap.get(colName);
		}
		
		var sourceVal = dataVal;
		
		if(dataVal == " " && this.checkSourceValue(rowNum, colName) == null){
			dataVal = "";
		}
		
		if(!sourceColMap){
			sourceColMap = new DataMap();
			this.sourceCols[rowNum] = sourceColMap;
		}
		
		if(viewType == undefined){
			viewType = true;
		}
		
		if(commonUtil.isJObjNotEmpty($rowObj)){
			var $obj = $colObj;
			if(commonUtil.isJObjEmpty($colObj)){
				$obj = $rowObj.find("["+configData.GRID_COL_NAME+"="+colName+"]");
			}
			if($obj){	
				var colType = $obj.attr(configData.GRID_COL_TYPE);
				var tmpColValue = colValue;
				var tmpColHead="";
				var tmpColTail="";
				if(viewType){					
					if(this.colFormatMap.containsKey(colName)){
						var formatList = this.colFormatMap.get(colName);
						tmpColValue = uiList.getDataFormat(formatList, tmpColValue, true);
					}
					
					if(this.colHeadMap.containsKey(colName)){
						tmpColHead = this.colHeadMap.get(colName);
						if(tmpColValue.indexOf(tmpColHead) == 0){
							tmpColHead = "";
						}
					}
					
					if(this.colTailMap.containsKey(colName)){
						tmpColTail = this.colTailMap.get(colName);
						if(tmpColValue.indexOf(tmpColTail) == (tmpColValue.length - tmpColTail.length)){
							tmpColTail = "";
						}
					}
					
					if(colType == configData.GRID_COL_TYPE_CHECKBOX){
						var $input = $obj.find("input");
						if(colValue == site.defaultCheckValue){
							$input.prop("checked", true);
						}else{
							$input.prop("checked", false);
						}
					}else if(colType == configData.GRID_COL_TYPE_SELECT){
						$obj.find("select").val(colValue);
					}else if(colType == configData.GRID_COL_TYPE_INPUT){
						if(this.inputRowNum == rowNum && this.inputColName == colName){
							var $inputObj = $obj.find("input");
							if($inputObj.length > 0){
								$inputObj.val(tmpColHead+colValue+tmpColTail);
							}else{
								$obj.text(tmpColHead+tmpColValue+tmpColTail);
							}							
						}else{
							$obj.text(tmpColHead+tmpColValue+tmpColTail);
						}
						/*
						var $inputObj = $obj.find("input");
						
						if($inputObj.length > 0){
							$inputObj.val(tmpColHead+colValue+tmpColTail);
						}else{
							$obj.text(tmpColHead+tmpColValue+tmpColTail);
						}
						*/
					}else if(colType == configData.GRID_COL_TYPE_HTML){
						$obj.find("[name='"+colName+"']").val(colValue);
					}else if(colType == configData.GRID_COL_TYPE_TEXT){
						$obj.text(tmpColHead+tmpColValue+tmpColTail);
					}
				}								
				
				if(viewType || colType != "input"){
					if(state == configData.GRID_ROW_STATE_INSERT){
						if(this.editedClassType){
							$obj.addClass(configData.GRID_EDITED_BACK_CLASS);
						}
					}else{					
						if(colValue != dataVal){						
							if(this.editedClassType){
								$obj.addClass(configData.GRID_EDITED_BACK_CLASS);
							}
						}else{
							if(this.editedClassType){
								$obj.removeClass(configData.GRID_EDITED_BACK_CLASS);
							}
						}
					}
				}				
				
				if(this.colFixType){
					var $chekColfix = $obj.parents("."+theme.GRID_COLFIXBODY_CLASS);
					if($chekColfix.length > 0){
						var $hiddenRowObj = this.$box.find("["+configData.GRID_ROW_NUM+"="+rowNum+"]");
						var $hiddenObj = $hiddenRowObj.find("["+configData.GRID_COL_NAME+"="+colName+"]");
						if($hiddenObj){
							if(colType == configData.GRID_COL_TYPE_CHECKBOX){
								var $hiddenInput = $hiddenObj.find("input");
								if(colValue == site.defaultCheckValue){
									$hiddenInput.prop("checked", true);
								}else{
									$hiddenInput.prop("checked", false);
								}
							}else if(colType == configData.GRID_COL_TYPE_SELECT){
								$hiddenObj.find("select").val(colValue);
							}else if(colType == configData.GRID_COL_TYPE_INPUT){
								$hiddenObj.text(tmpColHead+tmpColValue+tmpColTail);
							}else if(colType == configData.GRID_COL_TYPE_HTML){
								$hiddenObj.find("[name='"+colName+"']").val(colValue);
							}else if(colType == configData.GRID_COL_TYPE_TEXT){
								$hiddenObj.text(tmpColHead+tmpColValue+tmpColTail);
							}								
							
							if(state == configData.GRID_ROW_STATE_INSERT){
								if(this.editedClassType){
									$hiddenObj.addClass(configData.GRID_EDITED_BACK_CLASS);
								}
							}else{					
								if(colValue != dataVal){						
									if(this.editedClassType){
										$hiddenObj.addClass(configData.GRID_EDITED_BACK_CLASS);
									}
								}else{
									if(this.editedClassType){
										$hiddenObj.removeClass(configData.GRID_EDITED_BACK_CLASS);
									}
								}
							}
						}
					}
				}
			}
			if(this.tree){
				$obj.attr(configData.GRID_COL_VALUE, colValue);
			}
			//$obj.attr(configData.GRID_COL_VALUE, colValue);
			if(this.tree){
				var $treeCol = $rowObj.find("["+configData.GRID_COL_TYPE+"="+configData.GRID_COL_TYPE_TREE+"]");
				if(this.treeLvl == colName){
					var className = configData.GRID_COL_TYPE_TREE_LVL_CLASS+colValue;
					$treeCol.find("["+configData.GRID_COL_TYPE_TREE_ICON_ATT+"]").removeClass().addClass(className);
				}else if(this.treePid == colName){
					var $pcol = this.$box.find("["+configData.GRID_COL_NAME+"="+this.treePid+"]").filter("["+configData.GRID_COL_VALUE+"="+colValue+"]");
					var $prow = $pcol.parent();
					var plvl = $prow.find("["+configData.GRID_COL_NAME+"="+this.treeLvl+"]").attr(configData.GRID_COL_VALUE);
					plvl = parseInt(plvl)+1;
					var className = configData.GRID_COL_TYPE_TREE_LVL_CLASS+plvl;					
					$treeCol.find("["+configData.GRID_COL_TYPE_TREE_ICON_ATT+"]").removeClass().addClass(className);
					this.setColValue(rowNum, this.treeLvl, plvl);
				}else if(this.treeText == colName){
					$treeCol.find("["+configData.GRID_COL_TYPE_TREE_TEXT_ATT+"]").text(colValue);
				}
			}			
		}		
				
		if(state == configData.GRID_ROW_STATE_INSERT){
			this.modifyRow.put(rowNum, configData.GRID_ROW_STATE_INSERT);
			modifyColMap.put(colName, colValue);
			this.modifyData(rowNum, colName, colValue);
			//sourceColMap.put(colName, sourceVal);
			sourceColMap.put(colName, dataVal);
		}else{
			if(colValue != dataVal){
				this.modifyRow.put(rowNum, configData.GRID_ROW_STATE_UPDATE);
				modifyColMap.put(colName, colValue);
				//this.modifyData(rowNum, colName, colValue);
				if(!sourceColMap.containsKey(colName)){
					//sourceColMap.put(colName, sourceVal);
					sourceColMap.put(colName, dataVal);
				}
				if(commonUtil.isJObjNotEmpty($rowObj)){
					$rowObj.find("["+configData.GRID_COL_TYPE+"="+configData.GRID_COL_TYPE_ROWNUM+"]").text(configData.GRID_ROW_STATE_UPDATE);
				}				
			}else{
				if(modifyColMap && modifyColMap.containsKey(colName)){
					modifyColMap.remove(colName);
					if(modifyColMap.size() == 0){
						//this.modifyCols = commonUtil.removeRow(this.modifyCols, rowNum);
						this.modifyCols[rowNum] = null;
						this.modifyRow.remove(rowNum);
						var tmpViewRowNum = this.getViewRowNum(rowNum)+1;
						if(commonUtil.isJObjNotEmpty($rowObj)){
							$rowObj.find("["+configData.GRID_COL_TYPE+"="+configData.GRID_COL_TYPE_ROWNUM+"]").text(tmpViewRowNum);
						}
						if(this.rowCheckType && this.modifyRowCheck){
							this.setRowCheck(rowNum, false, checkStart);
						}						
					}
				}
			}
			this.modifyData(rowNum, colName, colValue);
		}
		
		if(eventType == undefined){
			eventType = true;
		}
		
		if(colValue != dataVal){
			if(this.rowCheckType && this.modifyRowCheck && eventType){
				this.colValueChangeEvent = true;
				this.setRowCheck(rowNum, true, checkStart);
				this.colValueChangeEvent = false;
			}
		}
		
		this.setAreaBind(rowNum, colName, colValue);

		//event fn
		if(commonUtil.checkFn("gridListEventColValueChange")){
			/*
			if(eventType){
				var tmpEventType = false;
				var tmpAtt = this.colTypeMap.get(colName);
				if(tmpAtt){
					var attList = tmpAtt.split(",");
					if(attList[0] == configData.GRID_COL_TYPE_CHECKBOX){
						tmpEventType = true;
					}
				}
				if(beforeVal == undefined ||  beforeVal != colValue){
					tmpEventType = true;
				}
				
				if(tmpEventType){
					gridListEventColValueChange(this.id, rowNum, colName, colValue);
				}
			}
			*/
			if(eventType && (beforeVal == undefined ||  beforeVal != colValue)){
				gridListEventColValueChange(this.id, rowNum, colName, colValue);
			}
		}
		
		if(this.totalView && this.totalColsMap.containsKey(colName)){
			var numberType;
			if(this.colFormatMap.containsKey(colName)){
				var tmpList = this.colFormatMap.get(colName);
				if(tmpList.length > 1){
					numberType = tmpList[1];
				}
			}
			this.changeSumColNum(colName, numberType);
		}
	},	
	modifyData : function(rowNum, colName, colValue) {
		var rowData = this.data[rowNum].split(configData.DATA_COL_SEPARATOR);
		var colIndex;
		for(var i=0;i<this.cols.length;i++){
			if(colName == this.cols[i]){
				colIndex = i;
				break;
			}
		}
		rowData[colIndex] = colValue;
		this.data[rowNum] = rowData.join(configData.DATA_COL_SEPARATOR);
		if(this.mapData[rowNum]){
			this.getRowData(rowNum).put(colName, colValue);
		}
	},
	getData : function(startRow, endRow) {
		var dataList = new Array();
		for(var i=startRow;i<=endRow;i++){
			/*
			var dataMap = new DataMap();
			var valList = this.data[i].split(configData.DATA_COL_SEPARATOR);
			for(var j=0;j<this.cols.length;j++){
				dataMap.put(this.cols[j], valList[j]);
			}
			*/
			dataList.push(this.getRowData(i));
		}
		return dataList;
	},
	getDataAll : function() {
		var dataList = new Array();
		var rowNum;
		for(var i=0;i<this.viewDataList.length;i++){
			rowNum = this.viewDataList[i];
			dataList.push(this.getRowData(rowNum));
		}
		return dataList;
	},
	getDataStringAll : function() {
		var dataList = new Array();
		var rowNum;
		for(var i=0;i<this.viewDataList.length;i++){
			rowNum = this.viewDataList[i];
			dataList.push(this.data[rowNum]);
		}
		return dataList.join(configData.DATA_ROW_SEPARATOR);;
	},
	getSelectDataString : function() {
		var dataList = new Array();
		for(var prop in this.selectRow.map){
			dataList.push(this.data[prop]);
		}
		return dataList.join(configData.DATA_ROW_SEPARATOR);;
	},
	isAvailRow : function(rowNum) {
		var state = this.getRowState(rowNum);
		if(state == configData.GRID_ROW_STATE_DELETE || state == configData.GRID_ROW_STATE_REMOVE){
			return false;
		}else{
			return true;
		}
	},
	getAvailData : function() {
		var dataList = new Array();
		for(var i=0;i<this.data.length;i++){
			if(this.isAvailRow(i)){
				dataList.push(this.getRowData(i));
			}
		}
		return dataList;
	},
	addMultiData : function(dataList) {
		for(var i=0;i<dataList.length;i++){
			this.appendData(rowData.join(configData.DATA_COL_SEPARATOR));
			this.mapData.push(rowMap);
			this.viewDataList.push(this.data.length-1);
		}
		this.setViewAll(true);
	},
	addData : function(rowMap) {
		var rowData = new Array();
		for(var i=0;i<this.cols.length;i++){
			var colVal = rowMap.get(this.cols[i]);
			if(!colVal){
				colVal = "";
			}
			rowData.push(colVal);
		}
		this.appendData(rowData.join(configData.DATA_COL_SEPARATOR));
		this.mapData.push(rowMap);
		this.viewDataList.push(this.data.length-1);
		this.setViewAll(true);
	},
	copyGridData : function(copyType, viewSortType) {
		var dataList = new Array();
		dataList.push(this.cols.join(configData.DATA_COL_SEPARATOR));
		if(!copyType){
			copyType = "all";
		}
		if(copyType == "all"){
			if(viewSortType){
				var rowNum;
				for(var i=0;i<this.viewDataList.length;i++){
					rowNum = this.viewDataList[i];
					dataList.push(this.data[rowNum]);
				}
			}else{
				for(var i=0;i<this.data.length;i++){
					dataList.push(this.data[i]);
				}
			}			
		}else if(copyType == "select"){
			if(viewSortType){
				var rowNum;
				for(var i=0;i<this.viewDataList.length;i++){
					rowNum = this.viewDataList[i];
					if(this.selectRow.containsKey(rowNum)){
						dataList.push(this.data[rowNum]);
					}
				}
			}else{
				for(var prop in this.selectRow.map){
					dataList.push(this.data[prop]);
				}
			}
		}else if(copyType == "modify"){
			if(viewSortType){
				var rowNum;
				for(var i=0;i<this.viewDataList.length;i++){
					rowNum = this.viewDataList[i];
					if(this.modifyRow.containsKey(rowNum)){
						dataList.push(this.data[rowNum]);
					}
				}
			}else{
				for(var prop in this.modifyRow.map){
					dataList.push(this.data[prop]);
				}
			}
		}
		
		return dataList.join(configData.DATA_ROW_SEPARATOR);
	},
	getSelectData : function(viewSortType) {
		var dataList = new Array();
		if(viewSortType){
			var rowNum;
			for(var i=0;i<this.viewDataList.length;i++){
				rowNum = this.viewDataList[i];
				if(this.selectRow.containsKey(rowNum)){
					dataList.push(this.getRowData(rowNum, site.emptyValue));
				}
			}
		}else{
			for(var prop in this.selectRow.map){
				dataList.push(this.getRowData(prop, site.emptyValue));
			}
		}
		
		return dataList;
	},
	getSelectTextData : function() {
		var dataList = new Array();
		for(var prop in this.selectRow.map){
			dataList.push(this.data[prop]);
		}
		return dataList;
	},
	getSelectPkData : function() {
		var dataList = new Array();
		for(var prop in this.selectRow.map){
			dataList.push(this.getRowPkData(prop));
		}
		return dataList;
	},
	getSelectModifyData : function() {
		return this.getSelectModifyList();
	},
	getSelectModifyList : function() {
		var selectList = new Array();
		for(var prop in this.selectRow.map){
			if(this.modifyCols[prop]){
				selectList.push(this.data[prop]);
			}
		}
		
		var list = new Array();
		for(var i=0;i<selectList.length;i++){
			var dataMap = new DataMap();
			var valList = selectList[i].split(configData.DATA_COL_SEPARATOR);
			for(var j=0;j<this.cols.length;j++){
				if(!valList[j]){
					valList[j] = site.emptyValue;
				}
				dataMap.put(this.cols[j],valList[j]);
			}
			list.push(dataMap);
		}
		
		return list;
	},
	getRowData : function(rownum, defaultValue) {
		if(this.data[rownum]){
			var dataMap = new DataMap();
			var valList = this.data[rownum].split(configData.DATA_COL_SEPARATOR);
			var colValue;
			var colName;
			dataMap.put(configData.GRID_ROW_NUM, rownum);
			dataMap.put(configData.GRID_ROW_STATE_ATT, this.getRowState(rownum));
			for(var i=0;i<this.cols.length;i++){
				colValue = valList[i];
				if(defaultValue && !colValue){
					colValue = defaultValue;
				}
				colName = this.cols[i];
				/*
				if(this.colFormatMap.containsKey(colName)){
					var formatList = this.colFormatMap.get(colName);
					colValue = uiList.getDataFormat(formatList, colValue);
				}
				*/
				dataMap.put(this.cols[i],colValue);
			}
			this.mapData[rownum] = dataMap;
			return dataMap;
		}else{
			return new DataMap();
		}		
	},
	getRowViewData : function(rownum, defaultValue) {
		var rowData = this.getRowData(rownum, defaultValue);
		var dataMap = new DataMap();
		for(var i=0;i<this.viewCols.length;i++){
			var colName = this.viewCols[i];
			var colValue = rowData.get(colName);
			dataMap.put(colName,colValue);
		}
		return dataMap;
	},
	getRowPkData : function(rownum) {
		if(!this.pkcol){
			return this.getRowData(rownum);
		}
		var dataMap = new DataMap();
		var rowData = this.getRowData(rownum);

		for (var prop in this.pkcolMap.map) {
			dataMap.put(prop, rowData.get(prop));
		}
		return dataMap;
	},
	getColModifyType : function(rowNum, colName) {
		if(this.modifyRow.containsKey(rowNum)){
			if(this.modifyCols[rowNum].containsKey(colName)){
				return true;
			}
		}
		return false;
	},
	getColData : function(rownum, colName, defaultValue, formatType) {
		var dataMap = new DataMap();
		if(this.data[rownum]){
			var valList = this.data[rownum].split(configData.DATA_COL_SEPARATOR);
			var colValue;
			if(formatType == undefined){
				formatType = true;
			}
			for(var i=0;i<this.cols.length;i++){
				if(colName == this.cols[i]){
					colValue = valList[i];
					if(defaultValue && !colValue){
						colValue = defaultValue;
					}
					if(formatType){
						if(this.colFormatMap.containsKey(colName)){
							var formatList = this.colFormatMap.get(colName);
							colValue = uiList.getDataFormat(formatList, colValue);
						}
					}
					return colValue;
				}
			}
		}
	},
	getModifyData : function(dataType) {
		// dataType - A 전체, M 수정된 데이터, E 수정된 로우 수정가능컬럼
		if(!dataType){
			dataType = 'M';
		}
		var dataList = new Array();
		//for(var i=0;i<=this.modifyRow.size();i++){
		var formatType = false;
		if(!Browser.ie){
			formatType = true;
		}
		
		for (var prop in this.modifyRow.map) {
			var rownum = prop;
			var state = this.modifyRow.get(rownum);
			if(state == configData.GRID_ROW_STATE_REMOVE){
				continue;
			}
			var rowMap;			
			if(dataType == 'M'){
				if(state == configData.GRID_ROW_STATE_INSERT){
					rowMap = this.getRowData(rownum, site.emptyValue);
				}else if(state == configData.GRID_ROW_STATE_DELETE){
					rowMap = this.getRowPkData(rownum);
				}else{
					rowMap = this.modifyCols[rownum];
					for(var prop in rowMap.map){
						if(!rowMap.get(prop)){
							rowMap.put(prop, site.emptyValue);
						}
					}
					if(this.pkcol){
						for (var prop in this.pkcolMap.map) {
							rowMap.put(prop, this.getColData(rownum, prop, site.emptyValue, formatType));
						}
					}
				}				
			}else if(dataType == 'E'){
				if(state == configData.GRID_ROW_STATE_DELETE){
					rowMap = this.getRowPkData(rownum);
				}else{
					rowMap = this.modifyCols[rownum];
					for(var i=0;i<this.editableCols.length;i++){
						var colData = this.getColData(rownum, this.editableCols[i], site.emptyValue, formatType);
						if(colData){
							
						}else if(state == configData.GRID_ROW_STATE_INSERT){
							colData = site.emptyValue;
						}
						rowMap.put(this.editableCols[i],colData);
					}
					if(this.pkcol){
						for (var prop in this.pkcolMap.map) {
							rowMap.put(prop, this.getColData(rownum, prop, site.emptyValue, formatType));
						}
					}
				}				
			}else if(dataType == 'A'){
				rowMap = this.getRowData(rownum, site.emptyValue);
			}			
			
			rowMap.put(configData.GRID_ROW_STATE_ATT, state);
			
			dataList.push(rowMap);
		}
		
		return dataList;
	},
	getModifyRowCount : function() {
		var count = this.modifyRow.size();
		for(var prop in this.modifyRow.map){
			if(this.modifyRow.get(prop) ==  configData.GRID_ROW_STATE_REMOVE){
				count--;
			}
		}
		return count;
	},
	getColsData : function(rowNum, colNameList) {
		var colsData = "";
		for(var i=0;i<colNameList.length;i++){
			colsData += this.getColData(rowNum, colNameList[i])+configData.DATA_COL_SEPARATOR;
		}
		
		return colsData.substring(0, colsData.length-1);
	},
	addValidation : function(colName, valAtt) {
		if(this.validationMap.containsKey(colName)){
			var tmpAtt = this.validationMap.get(colName);
			tmpAtt += " "+valAtt;
			this.validationMap.put(colName, tmpAtt);
		}else{
			this.validationMap.put(colName, valAtt);
		}
	},
	setValidation : function(colName, valAtt) {
		this.validationMap.put(colName, valAtt);
	},
	removeValidation : function(colName) {
		this.validationMap.remove(colName);
	},
	validationCheck : function(checkType) {
		if(this.validationMap.size() == 0){
			return true;
		}

		if(!checkType){
			checkType = configData.GRID_VALIDATION_TYPE_MODIFY;
		}
		
		if(checkType == "all"){
			checkType = configData.GRID_VALIDATION_TYPE_SELECT_MODIFY;
		}else if(checkType == "modify"){
			checkType = configData.GRID_VALIDATION_TYPE_MODIFY;
		}else if(checkType == "select"){
			checkType = configData.GRID_VALIDATION_TYPE_SELECT;
		}else if(checkType == "data"){
			checkType = configData.GRID_VALIDATION_TYPE_ALL;
		}
		
		var checkResult;
		for(var i=0;i<this.viewDataList.length;i++){
			var rowNum = this.viewDataList[i];
			if(!this.isAvailRow(rowNum)){
				continue;
			}
			if(checkType == configData.GRID_VALIDATION_TYPE_SELECT_MODIFY){
				checkResult = this.modifyRow.containsKey(rowNum) && this.selectRow.containsKey(rowNum);
			}else if(checkType == configData.GRID_VALIDATION_TYPE_MODIFY){
				checkResult = this.modifyRow.containsKey(rowNum);
			}else if(checkType == configData.GRID_VALIDATION_TYPE_SELECT){
				checkResult = this.selectRow.containsKey(rowNum);
			}else if(checkType == configData.GRID_VALIDATION_TYPE_ALL){
				checkResult = true;
			}
			if(checkResult){
				/*
				if(checkType == "all" && !this.selectRow.containsKey(rowNum)){
					continue;
				}
				*/
				var gtidId = this.id;
				for(var prop in this.validationMap.map){
					var valAtt = this.validationMap.get(prop);
					var colName;
					var colValue;
					while(valAtt.indexOf(configData.GRID_COL_DATA_NAME_HEAD) != -1){
						colName = valAtt.substring(valAtt.indexOf(configData.GRID_COL_DATA_NAME_HEAD)+configData.GRID_COL_DATA_NAME_HEAD.length, valAtt.indexOf(configData.GRID_COL_DATA_NAME_TAIL));
						colValue = this.getColValue(rowNum, colName);
						valAtt = valAtt.substring(0,valAtt.indexOf(configData.GRID_COL_DATA_NAME_HEAD))+colValue+valAtt.substring(valAtt.indexOf(configData.GRID_COL_DATA_NAME_TAIL)+configData.GRID_COL_DATA_NAME_TAIL.length);
					}
					
					var valList = valAtt.split(" ");
					for(var j=0;j<valList.length;j++){
						var ruleText;
						var optionText;
						var ruleList = valList[j].split(",");
						var msgCode = ruleList[1];
						if(ruleList[0].indexOf("(") == -1){
							ruleText = ruleList[0];
							if(ruleList.length == 1 && ruleList[0] == configData.VALIDATION_REQUIRED){
								 if(this.colTextMap.containsKey(prop)){
									 optionText = this.colTextMap.get(prop);
									 optionText = commonUtil.replaceAll(optionText, " ", "");
									 valList[j] = ruleText+"("+optionText+")";
								 }
							}
						}else{
							ruleText = ruleList[0].substring(0,ruleList[0].indexOf("("));
							optionText = ruleList[0].substring(ruleList[0].indexOf("(")+1, ruleList[0].length-1);
							if(ruleList.length == 1 && ruleText == configData.VALIDATION_REQUIRED){
								optionText = uiList.getLabel(optionText);
								optionText = commonUtil.replaceAll(optionText, " ", "");
								valList[j] = ruleText+"("+optionText+")";
							}
						}
						
						var valueText = this.getColData(rowNum, prop, "", false);					
						if(ruleText.indexOf("duplication") != -1){						
							if(!this.duplicationCheck(rowNum, prop, valueText)){
								var param = new Array();
								param.push(valueText);
								
								var msg = validate.getMsg(configData.VALIDATION_OBJECT_TYPE_GRID, rowNum, this.id, prop, valueText, "duplication", msgCode, param);
								commonUtil.msg(msg);
								setTimeout(function(){
									gridList.setColFocus(gtidId, rowNum, prop);
									}, 100);
								return false;
							}
						}else if(!validate.checkObject(valueText, valList[j], null, configData.VALIDATION_OBJECT_TYPE_GRID, this.id, rowNum, prop)){
							//this.setFocus(rowNum, prop);
							setTimeout(function(){
								gridList.setColFocus(gtidId, rowNum, prop);
								}, 100);

							return false;
						}
					}					
				}
				for(var j=0;j<this.duplicationList.length;j++){
					var dTxt = this.duplicationList[j];
					var dList = dTxt.split(",");
					var valueText = this.getColsData(rowNum, dList);
					var tmpRowNum;
					for(var k=0;k<this.viewDataList.length;k++){
						tmpRowNum = this.viewDataList[k];
						if(tmpRowNum != rowNum){
							var tmpValue = this.getColsData(tmpRowNum, dList);
							if(valueText == tmpValue){
								var param = new Array();
								param.push(valueText);
								var msg = validate.getMsg(configData.VALIDATION_OBJECT_TYPE_GRID, rowNum, this.id, dTxt, valueText, "duplication", null, param);
								commonUtil.msg(msg);
								this.setFocus(rowNum, dList[dList.length-1]);
								return false;
							}
						}			
					}
				}
			}
		}
		
		return true;
	},
	duplicationCheck : function(rowNum, colName, colValue) {
		var tmpRowNum;
		for(var i=0;i<this.viewDataList.length;i++){
			tmpRowNum = this.viewDataList[i];
			if(tmpRowNum != rowNum){
				var tmpValue = this.getColData(tmpRowNum, colName);
				if(colValue == tmpValue){
					return false;
				}
			}			
		}
		
		return true;
	},
	getSelectRowNumList : function(viewSortType) {
		var selectList = new Array();
		if(viewSortType){
			var rowNum;
			for(var i=0;i<this.viewDataList.length;i++){
				rowNum = this.viewDataList[i];
				if(this.selectRow.containsKey(rowNum)){
					selectList.push(rowNum);
				}
			}
		}else{
			for(var prop in this.selectRow.map){
				selectList.push(prop);
			}
		}
		
		return selectList;
	},
	getSelectType : function(rowNum) {
		return this.selectRow.containsKey(rowNum);
	},
	getSelectCount : function() {
		return this.selectRow.size();
	},
	getDataCount : function() {
		var count = this.data.length;
		for(var i=0;i<this.data.length;i++){
			if(this.getRowState(i) ==  configData.GRID_ROW_STATE_REMOVE){
				count--;
			}
		}
		return count;
	},
	getRowState : function(rowNum) {
		if(this.modifyRow.containsKey(rowNum)){
			return this.modifyRow.get(rowNum);
		}else{
			return configData.GRID_ROW_STATE_READ;
		}
	},
	getColObjRowNum : function($colObj) {
		var $rowObj = $colObj.parents("["+configData.GRID_ROW+"]");
		return $rowObj.attr(configData.GRID_ROW_NUM);
	},
	colGrouping : function(colName) {
		for(var i=0;i<this.editableCols.length;i++){
			if(this.editableCols[i] == colName){
				return;
			}
		}
		var $rowList = this.$box.find("["+configData.GRID_ROW_NUM+"]");
		var $startRow;
		var groupCount = 0;
		var startData;
		var gridBox = this;
		$rowList.each(function(index, findElement){
			var $row = jQuery(findElement);
			var rowNum = $row.attr(configData.GRID_ROW_NUM);
			var $col = $row.find('td['+configData.GRID_COL_NAME+'='+colName+']');
			//var tmpData = cubeCommon.getElementValue($col);
			var tmpData = gridBox.getColValue(rowNum, colName);
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
					$startRow.find('td['+configData.GRID_COL_NAME+'='+colName+']').attr('rowspan', groupCount);
				}
				groupCount = 1;
				$startRow = $row;
				startData = gridBox.getColValue(rowNum, colName);;
			}
		});
		if(groupCount > 1){
			$startRow.find('td['+configData.GRID_COL_NAME+'='+colName+']').attr('rowspan', groupCount);
		}
	},
	colColor : function(colName, checkFlag, maxVal, minVal) { 
		var $rowList = this.$box.find("["+configData.GRID_ROW_NUM+"]");
		var $startRow;
		var groupCount = 0;
		var startData;
		var gridBox = this;
		$rowList.each(function(index, findElement){
			var $row   = jQuery(findElement);
			var rowNum = $row.attr(configData.GRID_ROW_NUM);
			var $col   = $row.find(this.colTagName+'['+configData.GRID_COL_NAME+'='+colName+']');
			var colVal = gridBox.getColValue(rowNum, colName); 
			
			if(checkFlag) {
				if(maxVal && jQuery.trim(maxVal) != "") {
					if(parseInt(jQuery.trim(colVal)) > maxVal) { 
						$col.removeClass(configData.GRID_COL_TYPE_TEXT_CLASS); 
						$col.addClass(configData.GRID_COL_TYPE_TEXT_COLOR_RED_CLASS);
					}
				}

				if(minVal && jQuery.trim(minVal) != ""){
					if(parseInt(jQuery.trim(colVal)) < minVal) { 
						$col.removeClass(configData.GRID_COL_TYPE_TEXT_CLASS); 
						$col.addClass(configData.GRID_COL_TYPE_TEXT_COLOR_RED_CLASS); 
					}
				}
					
			} else {
				if(jQuery.trim(colVal) != "") {
					$col.removeClass(configData.GRID_COL_TYPE_TEXT_CLASS); 
					$col.addClass(configData.GRID_COL_TYPE_TEXT_COLOR_RED_CLASS);
					}
			}
		}); 
	},
	linkFirst : function() {
		this.linkPage(1);
	},
	linkPrev : function() {
		this.linkPage(this.pageNum-1);	
	},
	linkNext : function() {
		this.linkPage(this.pageNum+1);
	},
	linkLast : function() {
		var maxPage = parseInt(this.totalCount / this.pageCount);
		this.linkPage(maxPage);
	},
	linkPage : function(linkPage) {
		var maxPage = parseInt(this.totalCount / this.pageCount);
		if((this.totalCount % this.pageCount) != 0){
			maxPage++;
		}
		if(maxPage < 1){
			maxPage = 1;
		}
		if(linkPage < 1){
			linkPage = 1;
		}else if(linkPage > maxPage){
			linkPage = maxPage;
		}
		this.pageNum = linkPage;
		var param;
		//event fn
		if(commonUtil.checkFn("gridPageLinkEventBefore")){
			param = gridPageLinkEventBefore(this.id, linkPage);
		}else{
			param = inputList.setRangeParam(configData.SEARCH_AREA_ID);
		}
		
		param.put(configData.GRID_PAGE_SELECT_NUM_KEY, this.pageNum);
		param.put(configData.GRID_PAGE_COUNT_NUM_KEY, this.pageCount);
		param.put(configData.GRID_PAGE_REQUEST_TYPE_KEY, "paging");
		
		netUtil.send({
			module : this.module,
			command : this.command,
			url : this.url,
			bindType : "grid",
			bindId : this.id,
			sendType : "paging",
			param : param
		});
		
		param.put(configData.GRID_PAGE_REQUEST_TYPE_KEY, "count");
		netUtil.send({
			module : this.module,
			command : this.command,
			url : this.url,
			bindType : "grid",
			bindId : this.id,
			sendType : "count",
			param : param
		});
	},
	pageBind : function(count) {
		this.totalCount = count;
		this.setInfo();
		if(this.totalCount == 0){
			this.totalCount = 1;
		}
		var maxPage = parseInt(this.totalCount / this.pageCount);
		if((this.totalCount % this.pageCount) != 0){
			maxPage++;
		}

		var startPage= parseInt((this.pageNum/this.pageListCount));
		if(this.pageNum%this.pageListCount == 0){
			startPage--;
		}
		if(startPage < 0){
			startPage = 0;
		}
		startPage = startPage*this.pageListCount+1;
		
		var maxListPage = maxPage;
		if(maxListPage >= (startPage+this.pageListCount)){
			maxListPage = startPage+this.pageListCount-1;
		}
		
		//alert(this.pageNum+","+this.pageCount+","+this.totalCount);
		var $tmpObj = this.$paging.find("span");
		$tmpObj.find("a").remove();
		
		var gridBox = this;
		for(var i=startPage;i<=maxListPage;i++){
			var pagingTag = "<a href='#' onClick='gridList.pageList(\""+this.id+"\", \""+i+"\")'>";
			if(i == this.pageNum){
				pagingTag += "<b>"+i+"</b>";
			}else{
				pagingTag += i;
			}
			pagingTag += "</a>";
			$tmpObj.append(pagingTag);
		}
	},
	getItemGridViewCheck : function() {
		var rs = false;
		if(this.itemGrid){
			for(var i=0;i<this.itemGridList.length;i++){
				var count = gridList.getGridDataCount(this.itemGridList[i]);
				if(count > 0){
					rs = true;
					break;
				}
			}
		}
		
		return rs;
	},
	scrollPage : function(param) {
		if(this.pageEnd){
			this.scrollOn();
			return;
		}
		
		if(param){
			this.pagingParam = param;
			this.pagingParam.put(configData.GRID_PAGE_COUNT_NUM_KEY, this.scrollPageCount);
			this.pagingParam.put(configData.GRID_PAGE_REQUEST_TYPE_KEY, "paging");
		}
		
		this.pagingParam.put(configData.GRID_PAGE_SELECT_NUM_KEY, this.pageNum);
		
		/*2019.02.27 이범준 [Scroll page append 시  초기화 하기 위한  parmeter를 설정(scrollReset)]*/
		var scrollResetTf = false;
		var scrollLoad = "";
		
		if(param != undefined){
			var scrollReset = param.get("scrollReset");
			if(scrollReset){
				scrollResetTf = true;
			}
			
			var scrollLoading = param.get("scrollLoading");
			if(scrollLoading){
				scrollLoad = scrollLoading;
			}
		}else{
			if(this.scrollLoading != undefined && this.scrollLoading != null && this.scrollLoading != ""){
				scrollLoad = this.scrollLoading;
				$("#"+scrollLoad).show();
			}
		}
		
		netUtil.send({
			module : this.module,
			command : this.command,
			url : this.url,
			bindType : "grid",
			bindId : this.id,
			sendType : "scrollPaging",
			/*2019.02.27 이범준 [Scroll page append 시  초기화 하기 위한  parmeter를 설정(scrollReset)]*/
			scrollReset : scrollResetTf,
			param : this.pagingParam
		});
	},
	scrollPageAppend : function(gridId,data) {
		var dataString = commonUtil.datastringFromMap(data);
		if(dataString.length == 0){
			this.pageEnd = true;
			this.setScrollBottom();
			//event fn
			if(commonUtil.checkFn("gridEventPageEnd")){
				param = gridEventPageEnd(this.id, this.data.length);
			}
			return;
		}
		
		if(this.pageNum == 1){			
			this.setData(dataString);
			
			/*2019.02.27 이범준 [좀더 유연한 스크롤 페이징을 하기 위해 초기에 gird에 보여질 row수를 결정하는 로직을 변경.]*/
			//this.setViewAll(true);
			this.setViewStart(true);
		}else{
			if(dataString.length > 0){
				dataString = dataString.substring(dataString.indexOf(configData.DATA_ROW_SEPARATOR)+1);
				var list = dataString.split(configData.DATA_ROW_SEPARATOR);
				this.appendPageData(list);
			}else{
				this.pageEnd = true;
				return;
			}
		}
		
		/*2019.02.21 이범준 추가 ScrollPageAppend 후  gridListEventDataViewEnd 함수가 존재 할 경우, 실행*/
		if(commonUtil.checkFn("gridListEventDataViewEnd")){
			gridListEventDataViewEnd(this.id, this.data.length);
		}
	},
	appendPage : function(param, startType) {
		if(this.pageEnd){
			return;
		}
		if(startType && this.pageNum > 1){
			return;
		}
		if(param){
			this.pagingParam = param;
			this.pagingParam.put(configData.GRID_PAGE_COUNT_NUM_KEY, this.appendPageCount);
			this.pagingParam.put(configData.GRID_PAGE_REQUEST_TYPE_KEY, "paging");
		}
		
		this.pagingParam.put(configData.GRID_PAGE_SELECT_NUM_KEY, this.pageNum);
		
		this.pageNum++;
		netUtil.send({
			module : this.module,
			command : this.command,
			url : this.url,
			bindType : "grid",
			bindId : this.id,
			sendType : "appendPaging",
			param : this.pagingParam
		});
	},
	appendPageAppend : function(data) {
		var dataString = commonUtil.datastringFromMap(data);
		if(dataString.length == 0){
			this.pageEnd = true;
			this.setScrollBottom();
			//event fn
			if(commonUtil.checkFn("gridEventPageEnd")){
				param = gridEventPageEnd(this.id, this.data.length);
			}
			return;
		}
		if(this.pageNum == 2){
			this.setData(dataString);
			this.setViewAll(true);
		}else{
			dataString = dataString.substring(dataString.indexOf(configData.DATA_ROW_SEPARATOR)+1);
			var list = dataString.split(configData.DATA_ROW_SEPARATOR);
			this.startRowNum += this.appendPageCount;
			this.endRowNum = this.startRowNum+list.length;
			this.appendPageData(list);
		}
		this.eventDataBindEnd();
	},
	appendJson : function(data) {
		var dataString = commonUtil.datastringFromMap(data);
		var dataLength = 0;
		if(this.data.length == 0){
			dataLength = this.setData(dataString);
			this.setViewAll(true);
		}else{
			if(dataString.length > 0){
				dataString = dataString.substring(dataString.indexOf(configData.DATA_ROW_SEPARATOR)+1);
				var list = dataString.split(configData.DATA_ROW_SEPARATOR);
				dataLength = list.length;
				this.startRowNum = this.endRowNum + 1;
				this.endRowNum = this.endRowNum+list.length;
				this.appendPageData(list);
			}
		}

		this.eventDataBindEnd(null, dataLength);
	},
	colDataDistinctList : function(colName) {
		var colMap = new DataMap();
		var tmpValue;
		for(var i=0;i<this.data.length;i++){
			if(!this.isAvailRow(i)){
				continue;
			}
			tmpValue = this.getColValue(i, colName);
			if(jQuery.trim(tmpValue)){
				colMap.put(tmpValue, true);
			}
		}
		
		var tmpData = "";
		for(var prop in colMap.map) {
			tmpData += prop+configData.DATA_COL_SEPARATOR
			+0+configData.DATA_COL_SEPARATOR
			+prop+configData.DATA_ROW_SEPARATOR;
		}
		
		return tmpData.substring(0,tmpData.length-1);
	},
	toString : function() {
		return "GridBox";
	}
}