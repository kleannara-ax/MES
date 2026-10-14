TreeBox = function(id) {
	this.id = id;
	this.$box = jQuery("#"+this.id);
	this.$box.addClass("ztree");
	this.editable = true;
	this.module;
	this.command;
	this.url = "";
	
	this.nameText = "name";
	this.pkCol = "IDKEY";
	this.pidCol = "PIDKEY";
	this.nameCol = "NAMEKEY";
	this.sortCol = "SORTKEY";
	this.rootData = "root";
	
	this.idKey = "id";
	this.pidKey = "pId";
	this.tIdKey = "tId";
	this.rootPid = "root";
	
	this.data;
	this.dataKeyList = [];
	this.treeKeyList = [];
	this.treeSortList = [];
	this.dataMap = new DataMap();
	this.beforeDataMap = new DataMap();
	this.modifyMap = new DataMap();
	this.beforeSortData = new DataMap();
	this.sortNodes = [];
	this.bindAreaNameList = [];
	
	this.bindArea;
	this.treeObj;
	this.validation;
	
	this.cols = new Array();
	
	this.msgType = true;
	this.isMove = true;
	this.isCheck = false;
	this.open = false
	this.isMoveNode = false;
	this.showRemoveBtn = false;
	
	this.clickBindAll = false;
	this.isInner = true;
	this.appendCodeView = false;
}

TreeBox.prototype = {
	setTree : function() {
		var treeBox = this;
		
		//
		this.setting = {
				edit: {
					enable: this.editable,
					drag: {
						isCopy: true,
						isMove: true,
						inner: this.isInner
					},
					showRemoveBtn: this.showRemoveBtn,
					showRenameBtn: false
				},
				check : {
					autoCheckTrigger : false,
					chkboxType : {"Y": "ps", "N": "ps"},
					chkStyle : "checkbox",
					enable : this.isCheck,
					nocheckInherit : false,
					radioType : "level"
				},
				key: {
					name : this.nameText,
					url : this.url
				},
				data: {
					simpleData: {
						enable: true,
						idKey: this.idKey,
						pIdKey: this.pidKey,
						rootPId: this.rootPid
					}
				},
				view: {
					dblClickExpand: true,
					txtSelectedEnable: false
				},
				callback: {
					onClick : function(event, treeId, treeNode){
						treeBox.clickEvent(treeNode);
					},
					beforeDrop : function(treeId, treeNodes, targetNode, moveType, isCopy){
						
					},
					onDrop : function(event, treeId, treeNodes, targetNode, moveType, isCopy){
						if(isCopy){
							for(var i = 0; i <treeNodes.length; i++){
								treeBox.addRow(treeNodes[i], targetNode);
							}
						}else{
							treeBox.checkSort();
						}
						
						if(commonUtil.checkFn("treeGridDropAfterEvent")){
							treeGridDropAfterEvent(treeId, treeNodes, targetNode, moveType, isCopy);
						}
					},
					beforeRemove : function(treeId, treeNode){
						return treeBox.removeRow(treeNode);
					},
					beforeEditName : function(treeId, treeNode){
						return treeBox.editRow(treeNode);
					},
					beforeClick: function(treeId, treeNode) {						

					}
				},
			};
		
		if(!this.isMove){
			this.setting["edit"]["drag"]["isCopy"] = false;
			this.setting["edit"]["drag"]["isMove"] = false;
		}
		
		$.fn.zTree.init(this.$box, this.setting, this.data);
		this.treeObj = $.fn.zTree.getZTreeObj(this.id);
		
		if(this.bindArea){
			var treeBox = this;
			jQuery("#"+this.bindArea).find("input,select,textarea").each(function(i, findElement){
				var $bindObj = jQuery(findElement);
				var name = $bindObj.attr("name");
				
				treeBox.bindAreaNameList.push(name);
				
				if(name == treeBox.pkCol){
					$bindObj.prop("readOnly", true);
				}
				
				$bindObj.change(function(event){
					var $obj = $(event.target);
					var objName = $obj.attr("name");			
					
					var focusNode = treeBox.getFocusRow();
					
					if(focusNode){
						var colValue = $obj.val();
						if($obj.attr("type") == "checkbox" && !$obj.prop("checked")){
							colValue = site.emptyValue;
						}
						treeBox.setColValue(focusNode, objName, colValue);
					}
				});
			});
		}
		if(this.editable){
			this.setInnerButtonEvent();
		}
	},
	isChangeData : function(treeId){
		if(treeId != "" && treeId != undefined){
			var dataMap = this.dataMap.get(treeId);
			var status = dataMap.get(configData.GRID_ROW_STATE_ATT);
			var pid  = dataMap.get(this.pidCol);
			var name = dataMap.get(this.nameCol);
			
			var beforeMapData = this.beforeDataMap.get(treeId);
			
			switch (status) {
			case configData.GRID_ROW_STATE_READ:
				dataMap.put(configData.GRID_ROW_STATE_ATT, configData.GRID_ROW_STATE_UPDATE);
				this.modifyMap.put(treeId,dataMap);
				break;
			case configData.GRID_ROW_STATE_UPDATE:
				var isRemoveMap = true;
				var keys = beforeMapData.keys();
				//sort 제외 sort는 modify에서 일괄처리
				var sortIndex = keys.indexOf(this.sortCol);
				if(sortIndex > -1){
					keys.splice(sortIndex, 1);
				}

				for(var i in keys){
					var key = keys[i];
					if(dataMap.get(key) != beforeMapData.get(key)){
						isRemoveMap = false;
					}
				}
				
				if(isRemoveMap){
					dataMap.put(configData.GRID_ROW_STATE_ATT,configData.GRID_ROW_STATE_READ);
					this.modifyMap.remove(treeId);
				}
				break;	
			default:
				break;
			}
		}
	},
	checkSort : function(){
		var sortStatus = false;
		
		var selectNodes = this.treeObj.getSelectedNodes();
		var selectNodesLength = selectNodes.length;
		
		if(selectNodesLength > 0){
			for(var i in selectNodes){
				var row = selectNodes[i];
				var tId = row[this.tIdKey];
				var pId = row[this.pidKey];
				
				var data = this.dataMap.get(tId);
				var status = data.get(configData.GRID_ROW_STATE_ATT);
				
				if(status != configData.GRID_ROW_STATE_INSERT &&
						status != configData.GRID_ROW_STATE_DELETE){
					
					var index = row.getIndex();
					
					var beforeSortData = this.beforeSortData.get(tId);
					var beforePid = beforeSortData.get(this.pidKey);
					var beforeIndex = beforeSortData.get("index");
					
					row[this.pidCol] = pId;
					data.put(this.pidCol, pId);
					
					this.isChangeData(tId);
					
					if((pId != beforePid) || (index != beforeIndex)){
						var arrIndex = this.sortNodes.indexOf(tId);
						if(arrIndex == -1){
							this.sortNodes.push(tId);
						}
					}else{
						var arrIndex = this.sortNodes.indexOf(tId);
						if(arrIndex > -1){
							this.sortNodes.splice(arrIndex, 1);
						}
					}
				}else{
					if(status == configData.GRID_ROW_STATE_INSERT){
						row[this.pidCol] = pId;
						data.put(this.pidCol, pId);
						
						this.isChangeData(tId);
					}
				}
			}
		}
		
		if(this.sortNodes.length > 0){
			this.isMoveNode = true;
		}else{
			this.isMoveNode = false;
		}
	},
	setInnerButtonEvent : function(){
		var treeBox = this;
		
		var $body = $("#"+treeBox.id).parent();
		var $div = $("<div>");
		var $ul = $("<ul>");
		var $li = $("<li>");
		var $button = $("<button>");
		var $span = $("<span>");
		
		var $contextMenu = $div.clone().addClass("context_menu").attr("id",treeBox.id + "_menu");
		var $root = $li.clone().attr({"id":treeBox.id + "_root_btn","onclick":"treeList.addNewRow('"+treeBox.id+"');"}).append($button.clone().addClass("root").append($span.clone().addClass("root_txt").text("ROOT 추가")));
		var $add = $li.clone().attr({"id":treeBox.id + "_add_btn","onclick":"treeList.addNewRow('"+treeBox.id+"');"}).append($button.clone().addClass("add").append($span.clone().text("추가")));
		var $del = $li.clone().attr({"id":treeBox.id + "_del_btn","onclick":"treeList.removeRow('"+treeBox.id+"');"}).append($button.clone().addClass("del").append($span.clone().text("삭제")));
		
		$body.append($contextMenu.append($ul.append($root).append($add).append($del)));
		
		document.addEventListener("mousedown", function() {
			if ((event.button == 2) || (event.which == 3)) {
				var arr = [];
				var $treeObject = $("#"+treeBox.id).find("ul,li,a,span");
				$treeObject.each(function(){
					var treeObjId = $(this).attr("id");
					arr.push(treeObjId);
				});
				arr.push($("#"+treeBox.id).parent().attr("id"));
				
				var targetId = $(event.target).attr("id");
				
				var isSelect = false;
				if(arr.indexOf(targetId) > -1){
					isSelect = true;
				}
				
				if(isSelect){
					$(document).contextmenu(function(){
						event.preventDefault();
					});
					
					treeBox.setSelectNodeInit(event);
					
					var top = event.offsetY;//(event.clientY - 40) + 35;
					var left = event.offsetX;//event.clientX;
					
					var showType = "root";
					var $nodeObjs = treeBox.treeObj.getSelectedNodes();
					if($nodeObjs.length > 0){
						if($nodeObjs.length == 1){
							showType = "add";
						}else{
							showType = "del";
						}
						var $nodeObj = $nodeObjs[$nodeObjs.length - 1];
						var id = $nodeObj["tId"];
						var $tLi = $("#"+id);
						var $tA = $("#"+id+"_a");
						
						var wWrap = 15;//48
						var wPadding = 0;
						var wIcon = $tA.prev().outerWidth(true);
						var wA = $tA.outerWidth(true);
						
						var $tUl = $tA.parents("ul");
						var $tUlLen = $tUl.length;
						$tUl.each(function(i){
							if((i + 1) < $tUlLen){
								wPadding = wPadding + 18;
							}
						});
						
						left = wWrap + wPadding + wIcon + wA;
						
						var docTarget = document.getElementById(id + "_a");
						//top = docTarget.getBoundingClientRect().top;
						top = docTarget.offsetTop;
					}
					var $context = $("#"+treeBox.id+"_menu");
					if($context.hasClass("on")){
						$context.hide();
						$context.removeClass("on");
						$context.css({"top": 0,"left": 0});
					}else{
						if(showType == "root"){
							$("#"+treeBox.id+"_root_btn").show();
							$("#"+treeBox.id+"_add_btn").hide();
							$("#"+treeBox.id+"_del_btn").hide();
						}else if(showType == "add"){
							$("#"+treeBox.id+"_root_btn").hide();
							$("#"+treeBox.id+"_add_btn").show();
							$("#"+treeBox.id+"_del_btn").show();
						}else{
							$("#"+treeBox.id+"_root_btn").hide();
							$("#"+treeBox.id+"_add_btn").hide();
							$("#"+treeBox.id+"_del_btn").show();
						}
						
						$context.show();
						$context.addClass("on");
						$context.css({"top": top,"left":left});
					}
				}else{
					$(document).unbind();
					var $context = $("#"+treeBox.id+"_menu");
					$context.hide();
					$context.removeClass("on");
					$context.css({"top": 0,"left": 0});
				}
		 	}
		});
		$("html").unbind("click").on("click",function(e){
			var $context = $("#"+treeBox.id+"_menu");
			
			var btnArr = [];
			$context.find("li").each(function(){
				var id = $(this).attr("id");
				if(id != undefined){
					if(id.indexOf("_del") == -1){
						btnArr.push($(this).attr("id"));
					}
				}
			});
			var btnId = $(e.target).parent().parent().attr("id");
			if(btnArr.indexOf(btnId) == -1){
				$context.hide();
				$context.removeClass("on");
				$context.css({"top": 0,"left": 0});
			}
			
			treeBox.setSelectNodeInit(e);
		});
	},
	setSelectNodeInit : function (e){
		var treeBox = this;
		
		var arr = [];
		var $treeObject = $("#"+this.id).find("a,span");
		$treeObject.each(function(){
			var treeObjId = $(this).attr("id");
			arr.push(treeObjId);
		});
		
		$("#"+treeBox.id+"_menu li").each(function(){
			arr.push($(this).attr("id"));
		});
		
		var isInit = false;
		var node = this.treeObj;
		var id = $(e.target).attr("id");
		if(id != undefined){
			if(arr.indexOf(id) == -1){
				var selectNodes = treeBox.treeObj.getSelectedNodes();
				for(var i = 0; i < selectNodes.length; i++){
					var selectNode = selectNodes[i];
					treeBox.treeObj.cancelSelectedNode(selectNode);
				}
				isInit = true;
			}
		}else{
			var selectNodes = treeBox.treeObj.getSelectedNodes();
			if(selectNodes.length > 1){
				isInit = true;
			}
		}
		if(isInit){
			$(".context_menu").hide();
			if(this.bindArea){
				var $bindInput = $("#"+this.bindArea).find("input,select,textarea");
				$bindInput.each(function(){
					var type = $(this).attr("type");
					switch (type) {
					case "select":
						var value = $(this).eq(0).val();
						$(this).val(value);
						break;
					case "checkbox":
						$(this).prop("checked",false);
						break;	
					case "radio":
						$(this).prop("checked",false);
						break;
					default:
						$(this).val("");
						break;
					}
				});
			}
		}
	},
	setData : function(data) {
		this.dataMap = new DataMap();
		this.dataKeyList = [];
		this.treeSortList = [];
		this.beforeDataMap = new DataMap();
		this.modifyMap = new DataMap();
		this.beforeSortData = new DataMap();
		this.sortNodes = [];
		this.isMoveNode = false;
		
		if(this.bindArea){
			var $bindInput = $("#"+this.bindArea).find("input,select,textarea");
			$bindInput.each(function(){
				var type = $(this).attr("type");
				switch (type) {
				case "select":
					var value = $(this).eq(0).val();
					$(this).val(value);
					break;
				case "checkbox":
					$(this).prop("checked",false);
					break;	
				case "radio":
					$(this).prop("checked",false);
					break;
				default:
					$(this).val("");
					break;
				}
			});
		}
		
		this.data = data;
		
		if(this.data){
			for(var i=0; i<this.data.length; i++){
				var key = this.id + "_" + (i+1);
				
				this.data[i][this.tIdKey] = this.id + "_" + (i+1);
				this.data[i][this.idKey] = this.data[i][this.pkCol];
				this.data[i][this.pidKey] = this.data[i][this.pidCol];
				if(this.appendCodeView){
					this.data[i][this.nameText] = "[ "+this.data[i][this.pkCol]+" ] " + this.data[i][this.nameCol];
				}else{
					this.data[i][this.nameText] = this.data[i][this.nameCol];
				}
				this.data[i][configData.GRID_ROW_STATE_ATT] = configData.GRID_ROW_STATE_READ;
				this.data[i][configData.GRID_ROW_NUM] = i;
			}
			
			var row = this.data[0];
		    if(row != null && row != undefined){
		    	var keys = Object.keys(row);
				if(keys.length > 0){
					for(var i in keys){
						var key = keys[i];
						if((key != this.idKey) && (key != this.nameText) 
								&& (key != this.pidKey) && (key != this.tIdKey)){
							this.dataKeyList.push(key);
						}
						this.treeKeyList.push(key);
					}
				}
		    }
		}
		
		$.fn.zTree.init(this.$box, this.setting, this.data);
		
		if(this.data.length > 0){
			var treeRootNode = this.treeObj.getNodes();
			var treeNodes = this.treeObj.transformToArray(treeRootNode);
			var treeNodesLen = treeNodes.length;
			if(treeNodesLen > 0){
				for(var i in treeNodes){
					var treeNode = treeNodes[i];
					
					var tId = treeNode["tId"];
					var pId = treeNode[this.pidKey];
					var pk = treeNode[this.pkCol];
					var sort = treeNode[this.sortCol];
					var level = treeNode["level"];
					var index = treeNode.getIndex();
					
					var map = new DataMap();
					for(var j in this.dataKeyList){
						var key = this.dataKeyList[j];
						map.put(key, treeNode[key]);   
					}
					map.put(this.tIdKey, tId);
					
					this.beforeDataMap.put(tId, map);
					this.dataMap.put(tId, map);
					
					map = new DataMap();
					map.put(this.pidKey, pId);
					map.put(this.pkCol, pk);
					map.put(this.sortCol, sort);
					map.put("level", level);
					map.put("index", index);
					
					var obj = new Object();
					for(var j in this.treeKeyList){
						var key = this.treeKeyList[j];
						obj[key] = treeNode[key];
					}
					this.treeSortList.push(obj);
					this.beforeSortData.put(tId, map);
				}
			}
		}
		
		$.fn.zTree.init(this.$box, this.setting, this.treeSortList);
		this.treeObj = $.fn.zTree.getZTreeObj(this.id);
	},
	getData : function() {
		var result = [];
		var data = this.dataMap;
		var keys = data.keys();
		if(keys.length > 0){
			for(var i in keys){
				var key = keys[i];
				result.push(data.get(key));
			}
		}
		return result;
	},
	getModifyData : function() {
		var flag = this.isMoveNode;
		
		var gridRowSatausAttr = configData.GRID_ROW_STATE_ATT;
		var gridReadStatus = configData.GRID_ROW_STATE_READ;
		var gridCreateStatus = configData.GRID_ROW_STATE_INSERT;
		var gridUpdateStatus = configData.GRID_ROW_STATE_UPDATE;
		var gridDeleteStatus = configData.GRID_ROW_STATE_DELETE;
		
		var result = [];
		var modifyData = this.modifyMap;
		var keys = modifyData.keys();
		if(keys.length > 0){
			for(var i in keys){
				var key = keys[i];
				
				var row = modifyData.get(key);
				
				var status = row.get(gridRowSatausAttr);
				row.put("isSort",false);
				row.put("isUpdate",true);
				
				if((status == gridCreateStatus) || (status == gridDeleteStatus)){
					flag = true;
					if(status == gridDeleteStatus){
						row.put("isSort",true);
					}
				}
				
				result.push(row);
			}
		}
		
		if(flag){
			var gridRowNum = configData.GRID_ROW_NUM;
			
			var treeRootNode = this.treeObj.getNodes();
			var treeNodes = this.treeObj.transformToArray(treeRootNode);
			
			for(var i in treeNodes){
				var node = treeNodes[i];
				var tId = node["tId"];
				var pId = node[this.pidCol];
				var rowNum = node[gridRowNum];
				var status = node[gridRowSatausAttr];
				
				var data = this.dataMap.get(tId);

				var beforePid = "";
				if((status == configData.GRID_ROW_STATE_INSERT)){
					pId = node[this.pidKey];
					beforePid = node[this.pidCol];
				}else{
					beforePid = this.beforeSortData.get(tId).get(this.pidKey);
				}
				
				if((pId != beforePid)|| (rowNum != i) 
						|| (status == configData.GRID_ROW_STATE_INSERT)){
					if(data){
						data.put(this.sortCol,i);
						data.put("isSort",true);
						
						if(status == configData.GRID_ROW_STATE_INSERT){
							data.put(this.pidCol,pId);
						}
						
						if(data.get(gridRowSatausAttr) == gridReadStatus){
							data.put(gridRowSatausAttr,gridUpdateStatus);
						}
						
						var isModify = this.modifyMap.containsKey(tId);
						if(isModify){
							var modify = this.modifyMap.get(tId);
							modify.put("isSort",true);
							modify.put("isUpdate",true);
							modify.put(this.sortCol,i);
							
							if(status == configData.GRID_ROW_STATE_INSERT){
								modify.put(this.pidCol,pId);
							}
							
							var list = result.filter(function(data){
								return data.get("tId") == tId;
							});
							if(list.length > 0){
								list[0].put("isSort", true);
								list[0].put("isUpdate", true);
								list[0].put(this.sortCol, i);
								if(status == configData.GRID_ROW_STATE_INSERT){
									list[0].put(this.pidCol, pId);
								}
							}
						}else{
							data.put("isUpdate",false);
							result.push(data);
						}
					}
				}
			}
		}
		
//		var table = [];
//		for(var i in result){
//			var resultData = result[i];
//			var obj = {};
//			obj["Tree ID "] = resultData.get("tId");
//			obj["메뉴"] = resultData.get("MENUNAME");
//			obj["정렬순서"] = resultData.get(this.sortCol);
//			
//			table.push(obj);
//		}
//		
//		console.table(table);
		
		return result;
	},
	getCheckData : function(){
		var result = [];
		var data = this.dataMap;
		if(data != undefined && data.size() > 0){
			var dataKeys = data.keys();
			var checkData = this.treeObj.getCheckedNodes(true);
			if(checkData.length > 0){
				for(var i in checkData){
					var row = checkData[i];
					var tId = row["tId"];
					result.push(new DataMap(data.get(tId)));
				}
			}
		}
		return result;
	},
	getRowData : function(rowNum) {
		var id = this.findRowNumToTid(this.id, rowNum);
		var data = this.dataMap.get(id);
		return data;
	},
	getFocusRow : function() {
		var nodes = this.treeObj.getSelectedNodes();
		if (nodes.length>0) {
			return nodes[0];
		}
		return null;
	},
	setColValue : function(treeNode, colName, colValue) {
		var id = treeNode[this.tIdKey];
		
		treeNode[colName] = colValue;
		
		var rowData = this.dataMap.get(id);
		if(colName == this.nameCol){
			if(this.appendCodeView){
				var code = treeNode[this.pkCol];
				if(code != null && code != undefined && code != ""){
					var codeAppendValue = "[ " + code + " ] " + colValue;
					treeNode.name = codeAppendValue;
				}
			}else{
				treeNode.name = colValue;
			}
			rowData.put(this.nameText,colValue);
			//this.treeObj.refresh();
			this.treeObj.editName(treeNode);
			this.treeObj.selectNode(treeNode);
			this.treeObj.cancelEditName();
		}
		
		if(colName == this.pkCol){
			treeNode[this.idKey] = colValue;
			if(this.modifyMap.containsKey(id)){
				this.modifyMap.get(id).put(this.idKey,colValue);
			}
			this.dataMap.get(id).put(this.idKey,colValue);
			
			if(treeNode.children != undefined && treeNode.children.length > 0){
				for(var  i = 0; i < treeNode.children.length; i++){
					var childNode = treeNode.children[i];
					childNode[this.pidCol] = colValue;
					childNode[this.pidKey] = colValue;
					
					this.dataMap.get(childNode[this.tIdKey]).put(this.pidCol,colValue);
					this.dataMap.get(childNode[this.tIdKey]).put(this.pidKey,colValue);
					
					if(this.modifyMap.containsKey(childNode[this.tIdKey])){
						this.modifyMap.get(childNode[this.tIdKey]).put(this.pidCol,colValue);
						this.modifyMap.get(childNode[this.tIdKey]).put(this.pidKey,colValue);
					}else{
						var childData = this.dataMap.get(childNode[this.tIdKey]);
						if(childData.get(configData.GRID_ROW_STATE_ATT) == configData.GRID_ROW_STATE_READ){
							childData.put(configData.GRID_ROW_STATE_ATT,configData.GRID_ROW_STATE_UPDATE);
							this.dataMap.get(childNode[this.tIdKey]).put(configData.GRID_ROW_STATE_ATT,configData.GRID_ROW_STATE_UPDATE);
						}
						this.modifyMap.put(childNode[this.tIdKey],this.dataMap.get(childNode[this.tIdKey]));
					}
				}
			}
		}
		
		rowData.put(colName,colValue);
		
		var modify = this.modifyMap;
		if(modify.containsKey(id)){
			this.modifyMap.get(id).put(colName,colValue);
		}else{
			if(rowData[configData.GRID_ROW_STATE_ATT] == configData.GRID_ROW_STATE_READ){
				rowData.put(configData.GRID_ROW_STATE_ATT,configData.GRID_ROW_STATE_UPDATE);
			}
			this.modifyMap.put(id,rowData);
		}
		
		if(this.bindArea){
			dataBind.dataNameBind(rowData, this.bindArea);
		}
		
		if(commonUtil.checkFn("treeGridColValueChangeEvent")){
			var data = this.dataMap.get(id);
			var rowNum = data.get(configData.GRID_ROW_NUM);
			if(rowData.get(configData.GRID_ROW_STATE_ATT) != configData.GRID_ROW_STATE_INSERT){
				var beforeData = this.beforeDataMap.get(id);
				var beforeVal = beforeData.get(colName); 
				if(beforeVal == undefined ||  beforeVal != colValue){
					treeGridColValueChangeEvent(this.id, id, rowNum, colName, colValue, treeNode);
				}
			}else{
				treeGridColValueChangeEvent(this.id, id, rowNum, colName, colValue, treeNode);
			}
		}
		
		this.isChangeData(id);
	},
	// 메뉴선택 event
	clickEvent : function(treeNode) {
		if(!this.editable){
			// 하위 메뉴가 존재할 경우
			if (treeNode.isParent) {
				this.treeObj.expandNode(treeNode);
				return false;
			// 페이지 실행
			} else {
				this.linkPage(treeNode);
				return true;
			}
		}else{
			var selectNodes = this.treeObj.getSelectedNodes();
			var selectNodesLength = selectNodes.length;
			
			if(this.bindArea){
				var $bindInput = $("#"+this.bindArea).find("input,select,textarea");
				if(selectNodesLength > 1){
					$bindInput.each(function(){
						var type = $(this).attr("type");
						switch (type) {
						case "select":
							var value = $(this).eq(0).val();
							$(this).val(value);
							break;
						case "checkbox":
							$(this).prop("checked",false);
							break;	
						case "radio":
							$(this).prop("checked",false);
							break;
						default:
							$(this).val("");
							break;
						}
					});				
				}else{
					var treeNodeId = selectNodes[0]["tId"];
					var rowData = this.dataMap.get(treeNodeId);
					dataBind.dataNameBind(rowData, this.bindArea);
					
					var $pkObj;
					var pkCol = this.pkCol;
					$bindInput.each(function(i, findElement){
						var name = $(findElement).attr("name");
						if(name == pkCol){
							$pkObj = $(findElement);
						}
					});
					
					if($pkObj){
						var status = rowData.get(configData.GRID_ROW_STATE_ATT);
						var insertStatus = configData.GRID_ROW_STATE_INSERT;
						
						if(status == insertStatus){
							$pkObj.prop("readOnly", false);
						}else{
							$pkObj.prop("readOnly", true);
						}
					}
				}
			}
		}
	},
	removeRows : function() {
		var nodes = this.treeObj.getSelectedNodes();
		if (nodes.length > 0) {
			if(this.msgType && !confirm(commonUtil.getMsg(configData.MSG_MASTER_DELETE_CONFIRM))){
				return false;
			}
			for(var i = 0; i < nodes.length; i++){
				var node = nodes[i];
				this.removeRow(node);
			}
			
			if(this.bindArea){
				var rowData = new DataMap();
				$("#"+this.bindArea).find("input,select").each(function(){
					var key = $(this).attr("name");
					rowData.put(key,"");
				});
				dataBind.dataNameBind(rowData, this.bindArea);
			}
		}
	},
	removeRow : function(treeNode) {
		if(treeNode != undefined){
			this.removeData(treeNode);
			if(treeNode.children != undefined && treeNode.children.length > 0){
				for(var i = 0; i < treeNode.children.length; i++){
					var node = treeNode.children[i];
					this.removeRow(node);
				}
			}
		}
	},
	removeData : function(treeNode) {
		var tId = treeNode[this.tIdKey];
		
		var data = this.dataMap.get(tId);
		var modifyData = this.modifyMap.get(tId);
		
		if(this.modifyMap.containsKey(tId)){
			if(modifyData.get(configData.GRID_ROW_STATE_ATT) == configData.GRID_ROW_STATE_INSERT){
				this.modifyMap.remove(tId);
				this.dataMap.remove(tId);
			}else{
				treeNode[configData.GRID_ROW_STATE_ATT] = configData.GRID_ROW_STATE_DELETE;
				data.put(configData.GRID_ROW_STATE_ATT,configData.GRID_ROW_STATE_DELETE);
				modifyData.put(tId, data);
			}
		}else{
			if(this.dataMap.containsKey(tId)){
				if(data.get(configData.GRID_ROW_STATE_ATT) == configData.GRID_ROW_STATE_INSERT){
					this.dataMap.remove(tId);
				}else{
					treeNode[configData.GRID_ROW_STATE_ATT] = configData.GRID_ROW_STATE_DELETE;
					data.put(configData.GRID_ROW_STATE_ATT,configData.GRID_ROW_STATE_DELETE);
					this.modifyMap.put(tId, data);
				}
			}
		}
		this.treeObj.removeNode(treeNode);
	},
	editRow : function(treeNode) {
		var tId = treeNode[this.tIdKey];
		var status = "";
		var rowData = new DataMap();
		if(this.modifyMap.containsKey(tId)){
			rowData = this.modifyMap.get(tId);
			status = rowData.get(configData.GRID_ROW_STATE_ATT);
		}else{
			status = configData.GRID_ROW_STATE_UPDATE;
			rowData = this.dataMap.get(tId);
		}
		
		if(this.bindArea){
			var data = dataBind.paramData(this.bindArea);
			rowData.putAll(data);
			rowData.put(configData.GRID_ROW_STATE_ATT,status);
		}
		
		this.modifyMap.put(tId, rowData);
		
		return false;
	},
	addRow : function(treeNode, targetNode) {
		if(targetNode){
			treeNode[this.pidCol] = targetNode[this.pkCol];
			treeNode[this.pidKey] = targetNode[this.idKey];
		}
	},
	addNewRow : function(isNodeFocus) {
		var treeBox = this;
		
		var newNode = new Object();
		for(var i=0;i<this.cols.length;i++){
			newNode[this.cols[i]] = "";
		}
		newNode[configData.GRID_ROW_STATE_ATT] = configData.GRID_ROW_STATE_INSERT;
		newNode[this.idKey] = "";
		newNode[this.pidKey] = "";
		newNode["name"] = "NEW";
		
		var parentNode;
		var nodes = this.treeObj.getSelectedNodes();
		if (nodes.length > 0) {			
			parentNode = nodes[0];
		}
		
		var param = null;
		if(commonUtil.checkFn("treeGridAddRowEventBefore")){
			param = treeGridAddRowEventBefore(this.id, parentNode, newNode);
		}
		
		if(!param){
			return;
		}
		
		newNode = this.treeObj.addNodes(parentNode,newNode);
		
		var obj = new DataMap();
		
		if(param != undefined && param != null && !param.isEmpty()){
			obj.putAll(param);
			var keys = param.keys();
			if(keys.length > 0){
				for(var i in keys){
					var key = keys[i];
					var value = param.get(key);
					
					newNode[0][key] = value;
				}
			}
		}
		
		if(newNode[0]["level"] > 0){
			newNode[0][this.pidCol] = parentNode[this.pkCol];
			newNode[0][this.pidKey] = parentNode[this.pkCol];
		}else{
			newNode[0][this.pidCol] = this.rootData;
			newNode[0][this.pidKey] = this.rootData;
		}
		
		var rowNum = 0;
		
		var tId = newNode[0][this.tIdKey];
		if(tId != null && tId != undefined && tId != ""){
			if(tId.indexOf("_") > -1){
				var numTxt = tId.split("_")[1];
				rowNum = Number(numTxt) - 1;
			}else{
				var rowNumList = this.getData();
				var rowNumSort = rowNumList.sort(function(n1, n2)  {
				  return n2.get(configData.GRID_ROW_NUM) - n1.get(configData.GRID_ROW_NUM);
				});
				
				var maxRowNum = rowNumSort[0].get(configData.GRID_ROW_NUM);
				
				rowNum = (maxRowNum + 1);
			}
		}
		
		newNode[0][configData.GRID_ROW_STATE_ATT] = configData.GRID_ROW_STATE_INSERT;
		newNode[0][configData.GRID_ROW_NUM] = rowNum;
		
		obj.put(this.tIdKey,newNode[0][this.tIdKey]);
		obj.put(this.pidCol,newNode[0][this.pidKey]);
		obj.put(configData.GRID_ROW_STATE_ATT,newNode[0][configData.GRID_ROW_STATE_ATT]);
		obj.put(configData.GRID_ROW_NUM,newNode[0][configData.GRID_ROW_NUM]);
		
		this.dataMap.put(tId,obj);
		this.modifyMap.put(tId,obj);
		
		if(commonUtil.checkFn("treeGridAddRowEventAfter")){
			param = treeGridAddRowEventAfter(this.id, parentNode, newNode);
			if(param != undefined && param != null && !param.isEmpty()){
				var keys = param.keys();
				if(keys.length > 0){
					for(var i in keys){
						var key = keys[i];
						var value = param.get(key);
						var data = this.dataMap.get(newNode[0]["tId"]);
						data.put(keys, value);
					}
				}
			}
		}
		
		if(isNodeFocus){
			this.treeObj.selectNode(newNode[0]);
			if(this.bindArea){
				var rowData = this.modifyMap.get(newNode[0].tId);
				dataBind.dataNameBind(param, this.bindArea);
			}
		}
	},
	moveRow : function(treeNode, targetNode) {
		
	},
	findRowNumToTid : function(rowNum){
		var treeBox = this;
		
		var arr = [];
		var keys = treeBox.dataMap.keys();
		
		if(keys.length > 0){
			for(var i in keys){
				var key = keys[i];
				arr.push(treeBox.dataMap.get(key));
			}
		}
		var tId = "";
		var numFilter = arr.filter(function (e) {
			return e.get(configData.GRID_ROW_NUM) == rowNum;
		});
		if(numFilter.length > 0){
			tId = numFilter[0].get(this.tIdKey);
		}
		
		return tId;
	},
	// 메뉴 선택 시 실행
	linkPage : function(treeNode){
		if(commonUtil.checkFn("changePage")){
			var id = treeNode[this.tIdKey];
			var rowData = this.dataMap.get(id);
			changePage(rowData);
		}		
	},
	getBeforeSortData : function(){
		var result = []; 
		
		var data = this.beforeSortData;
		if(data){
			var keys = data.keys();
			for(var i in keys){
				var key = keys[i];
				var map = data.get(key);
				var value = "".concat(map.get(this.pidKey),map.get(this.pkCol),map.get(this.sortCol));
			
				result.push(value);
			}
		}
		
		return result;
	},
	isSort : function(){
		var result = false;
		var modifyList = this.getModifyData();
		var sortList = modifyList.filter(function(data){
			return data.get("isSort") == true;
		});
		if(sortList.length > 0){
			result = true;
		}
		return result;
	},
	getAllNodes : function(){
		var result = [];
		
		var treeObj = this.treeObj;
		var nodes = treeObj.getNodes();
		var allNodes = treeObj.transformToArray(nodes);
		
		var data = this.dataMap;
		if(allNodes.length > 0){
			for(var i in allNodes){
				var row = allNodes[i];
				var tId = row[this.tIdKey];
				
				var dataRow = data.get(tId);
				dataRow.put(this.sortCol, i);
				
				result.push(dataRow);
			}
		} 
		
		return result;
	},
	getSortList : function(){
		var result = [];
		
		var nodes = this.getData();
		if(nodes.length > 0){
			for(var i in nodes){
				var row = nodes[i];
				result.push(Number(row.get(this.sortCol)));
			}
		}
		
		return result;
	},
	toString : function() {
		return "TreeObj";
	}
}

TreeList = function() {
	this.treeMap = new DataMap();
}

TreeList.prototype = {	
	setTree : function(options) {
		var treeBox = new TreeBox(options.id);
		
		var opts = jQuery.extend(treeBox, options);
		
		treeBox.setTree();
		
		this.treeMap.put(options.id, treeBox);
	},
	treeList : function(options) {
		var listDefaults = new Object({
			id : null,
	    	param : null,
	    	command : null
		});
		
		var opts = jQuery.extend(listDefaults, options);
				
		var treeBox = this.treeMap.get(opts.id);

		if(!opts.command){
			opts.command = treeBox.command;
		}
		
		var sendUrl = treeBox.url;
		if(options.url){
			sendUrl = treeBox.url; 
		}
		
		netUtil.send({
			module : treeBox.module,
			command : opts.command,
			url : sendUrl,
			bindType : "tree",
			bindId : treeBox.id,
			sendType : "list",
			param : opts.param
		});
	},
	
	treeAndCallBack : function(options, fnc) {
		var listDefaults = new Object({
			id : null,
			param : null,
			command : null
		});
		
		var opts = jQuery.extend(listDefaults, options);
		
		var treeBox = this.treeMap.get(opts.id);
		
		if(!opts.command){
			opts.command = treeBox.command;
		}
		
		var sendUrl = treeBox.url;
		if(options.url){
			sendUrl = treeBox.url; 
		}
		
		netUtil.sendAndCallBack({
			module : treeBox.module,
			command : opts.command,
			url : sendUrl,
			bindType : "tree",
			bindId : treeBox.id,
			sendType : "list",
			param : opts.param
		}, fnc);
	},
	
	viewJsonData : function(treeId, json) {
		var treeBox = this.treeMap.get(treeId);
		treeBox.setData(json.data);
		
		if(commonUtil.checkFn("searchOpen")){
			searchOpen(false);
		}
		
		if(commonUtil.checkFn("treeListEventDataBindEnd")){
			treeListEventDataBindEnd(treeId, json.data.length);
		}
	},
	addNewRow : function(treeId, isNodeFocus) {
		var treeBox = this.treeMap.get(treeId);
		return treeBox.addNewRow(isNodeFocus);
	},
	removeRow : function(treeId) {
		var treeBox = this.treeMap.get(treeId);
		return treeBox.removeRows();
	},
	openNodeAll : function(treeId) {
		var treeBox = this.treeMap.get(treeId);
		return treeBox.treeObj.expandAll(true);
	},
	closeNodeAll : function(treeId) {
		var treeBox = this.treeMap.get(treeId);
		return treeBox.treeObj.expandAll(false);
	},
	toggleNodeAll : function(treeId,$obj){
		$obj = $($obj);
		if($obj.hasClass("node_open")){
			$obj.removeClass("node_open");
			$obj.find("span").text("전체 node 열기");
			this.closeNodeAll(treeId);
		}else{
			$obj.addClass("node_open");
			$obj.find("span").text("전체 node 닫기");
			this.openNodeAll(treeId);
		}
	},
	getData : function(treeId) {
		var treeBox = this.treeMap.get(treeId);
		return treeBox.getData();
	},
	getModifyData : function(treeId) {
		var treeBox = this.treeMap.get(treeId);
		return treeBox.getModifyData();
	},
	getCheckData : function(treeId) {
		var treeBox = this.treeMap.get(treeId);
		return treeBox.getCheckData();
	},
	getRowData : function(treeId, rowNum) {
		var treeBox = this.treeMap.get(treeId);
		return treeBox.getRowData(rowNum);
	},
	setColValue : function (treeId, rowNum, colName, colValue){
		var treeBox = this.treeMap.get(treeId);
		if(treeBox.editable){
			var tId = treeBox.findRowNumToTid(rowNum);
			var treeNode = treeBox.treeObj.getNodeByTId(tId);
			
			treeBox.setColValue(treeNode, colName, colValue);
		}
	},
	findRowNumToTid : function(treeId, rowNum){
		var treeBox = this.treeMap.get(treeId);
		return treeBox.findRowNumToTid(rowNum);
	},
	selectNode : function(treeId, menuId){
		var treeBox = this.treeMap.get(treeId);
		var node = treeBox.treeObj.getNodeByParam("MENUID", menuId);
		treeBox.treeObj.selectNode(node, false, true);
	},
	linkPage : function(treeId, menuId){
		var treeBox = this.treeMap.get(treeId);
		var node = treeBox.treeObj.getNodeByParam("MENUID", menuId);
		treeBox.treeObj.selectNode(node, false, true);
		treeBox.linkPage(node);
	},
	checkNode : function(treeId, menuId){
		var treeBox = this.treeMap.get(treeId);
		var node = treeBox.treeObj.getNodeByParam("MENUID", menuId);
		return (node ? true : false);
	},
	getNode : function(treeId, menuId){
		var treeBox = this.treeMap.get(treeId);
		var node = treeBox.treeObj.getNodeByParam("MENUID", menuId);
		return node;
	},
	addNode : function(treeId, newNode, data){
		var treeBox = this.treeMap.get(treeId);
		var node = treeBox.treeObj.addNodes(null, newNode);
		
		var tId = node[0][treeBox.tIdKey];
		var newData = new DataMap();
		newData.putAll(data);
		newData.put(treeBox.tIdKey, tId);
		newData.put(treeBox.pidCol, treeBox.rootPid);
		newData.put(treeBox.pidKey, treeBox.rootPid);
		var rowNum = 0;
		if(tId.indexOf("_") > -1){
			rowNum = Number(tId.split("_")[1]) - 1;
		}
		newData.put(configData.GRID_ROW_NUM, rowNum);
		
		var sortDataMap = new DataMap();
		sortDataMap.put(treeBox.pidKey, treeBox.rootPid);
		sortDataMap.put(treeBox.pkCol, newData.get(treeBox.pkCol));
		sortDataMap.put(treeBox.sortCol, newData.get(treeBox.sortCol));
		sortDataMap.put("level", node[0]["level"]);
		sortDataMap.put("index", node[0].getIndex());
		
		treeBox.dataMap.put(tId, newData);
		treeBox.beforeDataMap.put(tId, newData);
		treeBox.beforeSortData.put(tId, sortDataMap);
	},
	removeNode : function(treeId, node){
		var treeBox = this.treeMap.get(treeId);
		treeBox.treeObj.removeNode(node);
	},
	getBindAreaNameKeyList : function(treeId) {
		var treeBox = this.treeMap.get(treeId);
		return treeBox.bindAreaNameList;
	},
	getBeforeSortData : function(treeId){
		var treeBox = this.treeMap.get(treeId);
		return treeBox.getBeforeSortData();
	},
	isSort : function(treeId){
		var treeBox = this.treeMap.get(treeId);
		return treeBox.isSort();
	},
	getAllNodes : function(treeId){
		var treeBox = this.treeMap.get(treeId);
		return treeBox.getAllNodes();
	},
	getSortList : function(treeId){
		var treeBox = this.treeMap.get(treeId);
		return treeBox.getSortList();
	},
	toString : function() {
		return "TreeList";
	}
}

var treeList = new TreeList();