CommonLabel = function() {
	this.label = new DataMap();
};

CommonLabel.prototype = {
	getLabel : function(key, type) {
		// ex) <td GH="80" GCol="btn,CREATEUSER" GB="Search SEARCH BTN_SEARCH"></td>
		// key : BTN_SEARCH
		// type : 1
		// label-KR.js의 값을 가지고 있다
		// ltxt : "BTN_SEARCH↓조회"
		var ltxt = labelObj[key]; 
		if(ltxt){
			// configData.DATA_COL_SEPARATOR : ↓
			// ltxt.split("1")[1] : 조회
			return ltxt.split(configData.DATA_COL_SEPARATOR)[type];
		}else{
			return key;
		}
	},
	toString : function() {
		return "CommonLabel";
	}
};

var commonLabel = new CommonLabel();

CommonMessage = function() {
	this.message = new DataMap();
};

CommonMessage.prototype = {
	getMessage : function(key) {
		var mtxt = this.message.get(key);
		if(mtxt){
			// configData.DATA_COL_SEPARATOR : ↓
			return mtxt.split(configData.DATA_COL_SEPARATOR)[1];
		}else{
			return key;
		}
	},
	toString : function() {
		return "CommonMessage";
	}
};

var commonMessage = new CommonMessage();