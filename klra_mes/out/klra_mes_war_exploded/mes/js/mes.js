Mes = function() {
	this.$inputObj;
	this.searchOpenGridId;;
	this.param;
	this.popData;
};

Mes.prototype = {
	getDocSeq : function(docuty) {
		var param = new DataMap();
		param.put("DOCUTY", docuty);
		
		var json = netUtil.sendData({
			module : "Common",
			command : "DOCUSEQ",
			sendType : "insert",
			param : param
		});
		
		return json["data"];
	},	
	getNumSeq : function(numobj) {
		var param = new DataMap();
		param.put("NUMOBJ", numobj);
		
		var json = netUtil.sendData({
			module : "Common",
			command : "NROBJ",
			sendType : "insert",
			param : param
		});
		
		return json["data"];
	},
	toString : function() {
		return "Wms";
	}
};

var mes = new Mes();