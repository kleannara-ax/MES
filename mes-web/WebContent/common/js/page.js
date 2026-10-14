Page = function() {
	this.$inputObj;
	this.searchOpenGridId;
	this.param;
	this.popData;
	this.startRowNum;
};

Page.prototype = {
	getSearchObjName : function() {
		return this.$inputObj.name;
	},
	searchHelp : function($inputObj, searchCode, multyType, rowNum, gridId) {
		//event fn
		if(commonUtil.checkFn("searchHelpEventOpenBefore")){
			this.param = searchHelpEventOpenBefore(searchCode, multyType, $inputObj, rowNum);
			if(typeof this.param == "boolean"){
				if(!this.param){
					return;
				}
			}
		}else{
			this.param = null;
		}
		
		this.searchOpenGridId = gridId;
		this.startRowNum = rowNum;
		this.$inputObj = $inputObj;
		
		var url = "/common/page/searchHelp.page?SHLPKY="+searchCode;
		if(multyType == true){
			url += "&multyType=true";
		}		
		
		window.open(url, searchCode, "height=600,width=500,resizable=yes");
	},
	returnSearchHelp : function(data) {
		//alert(data);
		//this.$inputObj.val(data);
		
		if(this.$inputObj instanceof InputObj){
			if(this.$inputObj.$obj.attr("readonly") == "readonly" || this.$inputObj.$obj.attr("readonly") == "true"){
				return;
			}
			this.$inputObj.setSearchValue(data);
		}else{
			if(this.$inputObj.attr("readonly") == "readonly" || this.$inputObj.attr("readonly") == "true"){
				return;
			}
			if(typeof data == "string"){
				this.$inputObj.val(data);
				this.$inputObj.trigger("change");
				this.$inputObj.focus();
			}else{
				var colName = this.$inputObj.attr(configData.GRID_INPUT_COL_NAME);
				gridList.multiDataView(this.searchOpenGridId, this.startRowNum, colName, data);
			}			
		}
	},
	getSearchParam : function() {
		return this.param;
	},
	linkPageOpen : function(menuId, data) {
		window.top.linkPage(menuId, data);
	},
	getLinkPageData : function(menuId) {
		return window.top.getLinkData(menuId);
	},
	linkPopOpen : function(url, data, option) {
		if(!option){
			option = "height=600,width=1000,resizable=yes";
		}
		this.popData = data;
		window.open(url, configData.MENU_ID, option);
	},
	getLinkPopData : function(menuId) {
		return window.opener.page.popData;
	},
	linkPopClose : function(data) {
		window.opener.page.popData = data;
		try{
			window.opener.linkPopCloseEvent(data);
		}catch(e){
			
		}
		window.close();
	},
	getUserInfo : function() {
		var json = netUtil.sendData({
			url : "/common/userinfo.data"
		});
		return json.data;
	},
	toString : function() {
		return "Page";
	}
};

var page = new Page();