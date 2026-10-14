CommonLabel = function() {
	this.label = new DataMap();
};

CommonLabel.prototype = {
	getLabel : function(key, type) {
		/*
		if(this.label.containsKey(key)){
			var ltxt = this.label.get(key);
			return ltxt.split(configData.DATA_COL_SEPARATOR)[type];
		}else{
			return key;
		}
		*/
		var ltxt = labelObj[key];
		if(ltxt){
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