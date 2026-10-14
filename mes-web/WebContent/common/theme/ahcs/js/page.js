Page = function() {
	this.$inputObj;
	this.searchOpenGridId;;
	this.param;
	this.popData;
};

Page.prototype = {
	getSearchObjName : function() {
		return this.$inputObj.name;
	},
	searchHelp : function($inputObj, searchCode, multyType) {
		try{
			this.param = searchHelpEventOpenBefore(searchCode, multyType, $inputObj);
			if(typeof this.param == "boolean"){
				if(!this.param){
					return;
				}
			}
		}catch(e){
			this.param = null;
		}
		
		this.$inputObj = $inputObj;
		
		var url = "/ahcs/page/searchHelp.page?INQ_PUP_ID="+searchCode;
		if(multyType){
			url += "&multyType=true";
		}
		
		window.open(url, searchCode, "height=600,width=1000,resizable=yes");
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
			this.$inputObj.val(data);
			this.$inputObj.trigger("change");
			this.$inputObj.focus();
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
	linkPopOpen : function(url, data) {
		this.popData = data;
		window.open(url, configData.MENU_ID, "height=600,width=1000,resizable=yes");
	},
	getLinkPopData : function(menuId) {
		return window.opener.page.popData;
	},
	linkPopClose : function(data) {
		window.opener.page.popData = data;
		window.close();
		try{
			window.opener.linkPopCloseEvent(data);
		}catch(e){
			
		}
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