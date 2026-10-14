Mobile = function() {
	this.popData;
};

Mobile.prototype = {
	linkPopOpen : function(url, data) {
		this.popData = data;
		var sWidth = window.screen.availWidth;
		var sHeight = window.screen.availHeight;

		window.opener = self;
		window.open(url, url, "height="+sHeight+",width="+sWidth+",left=0,top=0,resizable=no");
	},
	getLinkPopData : function(menuId) {
		return window.opener.mobile.popData;
	},
	linkPopClose : function(data) {
		window.opener.mobile.popData = data;
		window.close();
		try{
			window.opener.linkPopCloseEvent(data);
		}catch(e){
			
		}
	},
	toString : function() {
		return "Mobile";
	}
};

var mobile = new Mobile();