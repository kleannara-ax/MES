DataMap = function(obj) {
	if(obj){
		this.map = obj;
	}else{
		this.map = new Object();
	}
};
DataMap.prototype = {
	//데이터를 key, value 형태로 저장한다.
	put : function(key, value) {		
		this.map[key] = value;
	},
	//데이터를 저장시 동일한 key가 있는 경우 value를 구분자 ","로 연결하여 저장한다.
	putMulti : function(key, value) {
		if(this.get(key)){
			this.map[key] = this.get(key)+','+value;
		}else{
			this.map[key] = value;
		}
	},
	//value가 DataMap 형태인 경우 맴버필드인 map만 저장한다.
	putMap : function(key, value) {
		this.map[key] = value.map;
	},
	putObject : function(value) {
		for (var prop in value) {
			this.map[prop] = value[prop];
		}		
	},
	putAll : function(value) {
		for (var prop in value.map) {
			this.map[prop] = value.get(prop);
		}		
	},
	//value가 DataMap을 포함한 List인 경우 포함된 DataMap의 맴버필드인 map을 추출하여 List로 저장한다.
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
			if(this.map[prop]){
				this.map[prop] == commonUtil.replaceAll(this.map[prop].toString(), "?", "? ");
			}
		}
		return JSON.stringify(this.map);
	},
	toString : function() {
		return JSON.stringify(this.map);
	}
};