// 데이터 처리를 위한 객체
DataBind = function() {

};

DataBind.prototype = {
	// 데이터 전송을 위해 areaId에 있는 데이터를 map에 저장해준다.
	paramData : function(areaId, map, emptyType) {
		if(!map){ 
			map = new DataMap();
		}
		
		var $dataRange = commonUtil.getArea(areaId);
				
		dataBind.paramDataFilter(map, $dataRange, emptyType);
		
		return map;
	},
	// $dataRange에 있는 입력값들을 map에 저장해준다.
	paramDataFilter : function(map, $dataRange, emptyType) {
		if(emptyType == undefined){
			emptyType = false;
		}
		// 단순 input의 경우 name을 키로 value를 저장해준다.
		$dataRange.find("input").each(function(i, findElement){
			var $obj = jQuery(findElement);
			if(!$obj.attr("name")){
				return;
			}
			var type = $obj.attr("type");			
			if(type == "checkbox"){
				if($obj.prop("checked")){
					var multiCheck = $dataRange.find("[name='"+$obj.attr('name')+"']").length;
					if(multiCheck > 1){
						map.putMulti($obj.attr("name"), $obj.val());
					}else{
						map.put($obj.attr("name"), $obj.val());
					}
				// checked가 없는 경우 check off값이 있으면 셋팅해준다.
				}else if($obj.attr(configData.INPUT_CHECKBOX_EMPTY_ATT)){
					map.put($obj.attr("name"), $obj.attr(configData.INPUT_CHECKBOX_EMPTY_ATT));
				}
			}else if(type == "radio"){
				if($obj.prop("checked")){
					map.put($obj.attr("name"), $obj.val());
				}
			}else{
				if($obj.val()){
					var multiCheck = $dataRange.find("[name='"+$obj.attr('name')+"']").length;
					if(multiCheck > 1){
						map.putMulti($obj.attr("name"), $obj.val());
					}else{
						map.put($obj.attr("name"), $obj.val());
					}
					
					var formatAtt = $obj.attr(configData.INPUT_FORMAT);
					if(formatAtt){
						var formatList = formatAtt.split(" ");
						/*
						if(formatList[0] == configData.INPUT_FORMAT_CALENDER){
							map.put($obj.attr("name"),uiList.getDateDataFormat(map.get($obj.attr("name"))));
						}
						*/
						map.put($obj.attr("name"),uiList.getDataFormat(formatList, map.get($obj.attr("name"))));
					}
				}else if(emptyType){
					map.put($obj.attr("name"), site.emptyValue);
				}
			}			
		});
		// 단순 select 경우 name을 키로 value를 저장해준다.
		$dataRange.find("select").each(function(i, findElement){
			var $obj = jQuery(findElement);
			if(!$obj.attr("name")){
				return;
			}
			var comboTypeAttr = $obj.attr(configData.INPUT_COMBO_TYPE);
			if(comboTypeAttr){
				if($obj.val()){
					var tmpValues = $obj.val();
					if(typeof tmpValues != "string"){
						 tmpValues = "'"+$obj.val().join("','")+"'";
					}
					map.put($obj.attr("name"), tmpValues);
				}else{
					map.put($obj.attr("name"), site.emptyValue);
				}
			}else{
				if($obj.val()){
					var multiCheck = $dataRange.find("[name='"+$obj.attr('name')+"']").length;
					if(multiCheck > 1){
						map.putMulti($obj.attr("name"), $obj.val());
					}else{
						map.put($obj.attr("name"), $obj.val());
					}
				}else if(emptyType){
					map.put($obj.attr("name"), site.emptyValue);
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
				var multiCheck = $dataRange.find("[name='"+$obj.attr('name')+"']").length;
				if(multiCheck > 1){
					map.putMulti($obj.attr("name"), $obj.val());
				}else{
					map.put($obj.attr("name"), $obj.val());
				}
			}else if(emptyType){
				map.put($obj.attr("name"), site.emptyValue);
			}
		});
	},
	paramDataKeys : function(areaId) {
		var map = new DataMap();
		var $dataRange = commonUtil.getArea(areaId);
		var objList = $dataRange.find("input,select,textarea");
		var tmpName;
		for(var i=0;i<objList.length;i++){
			tmpName = objList.eq(i).attr("name");
			if(tmpName){
				map.put(tmpName,tmpName);
			}
		}
		return map;
	},
	// data를 areaId내이 객체 id들과 bind한다.
	dataBind : function(data, area) {
		var $dataArea;
		if(typeof area == "string"){
			$dataArea = commonUtil.getArea(area);
		}else{
			$dataArea = area;
		}
		
		var map;
		if(data instanceof DataMap){
			map = data.map;
		}else{
			map = data;
		}
		
		for (var prop in map) {
			var $obj = jQuery("#"+prop);
			if($obj.length){
				commonUtil.setElementValue($obj, data[prop]);
			}
		}
	},
	// map에 있는 데이터를 areaId내이 객체 name들과 bind한다.
	// name의 중복등으로 구분을 위한 tail이 붙어 있는 경우 key+tail로 name을 찾아 bind한다.
	dataNameBind : function(data, area, tail, emptyValue) {
		var $dataArea;
		if(typeof area == "string"){
			$dataArea = commonUtil.getArea(area);
		}else{
			$dataArea = area;
		}
		if(!tail){
			tail = "";
		}
		
		var map;
		if(data && data.map){
			map = data.map;
		}else{
			map = data;
		}
		
		for (var prop in map) {
			var $obj = $dataArea.find("[name='"+prop+tail+"']");
			if($obj.attr(configData.INPUT) && ($obj.attr(configData.INPUT).substring(0,1) == configData.INPUT_RANGE || $obj.attr(configData.INPUT).substring(0,1) == configData.INPUT_BETWEEN)){
				continue;
			}
			if($obj.length){
				if(emptyValue && map[prop] == emptyValue){
					map[prop] = "";
				}
				commonUtil.setElementValue($obj, map[prop]);
			}
		}
	},
	toString : function() {
		return "Bigdata";
	}
};

var dataBind = new DataBind();