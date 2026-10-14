TreeBox = function(id) {
	this.id = id;
	this.$box = jQuery("#"+this.id);
	this.$box.addClass("ztree");
	this.editable = true;
	this.module;
	this.command;
	this.url;
	
	this.pkCol = "IDKEY";
	this.pidCol = "PIDKEY";
	this.nameCol = "NAMEKEY";
	this.sortCol = "SORTKEY";
	this.rootData = "root";
	
	this.data;
	this.bindArea;
	
	this.treeObj;
	
	this.validation;
	
	this.cols = new Array();
	
	this.editable = true;
	this.idKey = "ID";
	this.pidKey = "PID";
	this.rootPid = 0;
	
	this.msgType = true;
	
	this.modifyMap = new DataMap();
}

TreeBox.prototype = {
	setTree : function() {
		var treeBox = this;
		
		this.setting = {
				edit: {
					enable: this.editable,
					showRemoveBtn: false,
					showRenameBtn: false
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
					txtSelectedEnable: true
				},
				callback: {
					onClick : function(event, treeId, treeNode){
						//commonUtil.debugMsg("tree click : ", arguments);
						treeBox.clickEvent(treeNode);
					},
					onDrop : function(event, treeId, treeNodes, targetNode, moveType, isCopy){
						//commonUtil.debugMsg("tree onDrop : ", arguments);
						if(isCopy){
							for(var i=0;i<treeNodes.length;i++){
								treeBox.addRow(treeNodes[i], targetNode);
							}
						}else{
							if(moveType == "inner"){
								for(var i=0;i<treeNodes.length;i++){
									treeBox.moveRow(treeNodes[i], targetNode);
								}
							}
						}
					},
					beforeRemove : function(treeId, treeNode){
						return treeBox.removeRow(treeNode);
					},
					beforeEditName : function(treeId, treeNode){
						return treeBox.editRow(treeNode);
					}
				},
			};
		
		$.fn.zTree.init($("#"+this.id), this.setting, this.data);
		this.treeObj = $.fn.zTree.getZTreeObj(this.id);
		
		if(this.bindArea){
			var treeBox = this;
			jQuery("#"+this.bindArea).find("input,select,textarea").each(function(i, findElement){
				var $bindObj = jQuery(findElement);
				
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
	},
	setData : function(data) {
		this.data = data;
		$.fn.zTree.init($("#"+this.id), this.setting, this.data);
		this.treeObj = $.fn.zTree.getZTreeObj(this.id);
		
		if(commonUtil.checkFn("treeListEventDataBindEnd")){
			treeListEventDataBindEnd(this.id, this.data.length);
		}
	},
	getData : function() {
		var nodes = this.treeObj.transformToArray(this.treeObj.getNodes());
		var list = new Array();
		var node;
		for(var i=0;i<nodes.length;i++){
			node = nodes[i];
			var dataMap = new DataMap(node);
			if(this.modifyMap.containsKey(node.tId)){
				dataMap.put(configData.GRID_ROW_STATE_ATT, this.modifyMap(node.tId));
			}else{
				dataMap.put(configData.GRID_ROW_STATE_ATT, configData.GRID_ROW_STATE_START);
			}
			dataMap.put(this.sortCol, (i+1)*10 );
			list.push(dataMap);
		}
		return list;
	},
	getModifyData : function() {
		var nodes = this.treeObj.transformToArray(this.treeObj.getNodes());
		var keyList = new Array();
		var list = new Array();
		var node;
		for(var i=0;i<nodes.length;i++){
			node = nodes[i];
			if(this.modifyMap.containsKey(node.tId)){
				var dataMap = new DataMap(node);
				dataMap.put(configData.GRID_ROW_STATE_ATT, this.modifyMap.get(node.tId));
				list.push(dataMap);
			}
			keyList.push(node[this.pkCol]);
		}
		
		var map = new DataMap();
		map.put("list", list);
		map.put("keyList", keyList);
		
		return map;
	},
	getRowData : function(rowNum) {
		var nodes = this.treeObj.getNodes();
		return new DataMap(nodes[rowNum]);
	},
	getFocusRow : function() {
		var nodes = this.treeObj.getSelectedNodes();
		if (nodes.length>0) {
			return nodes[0];
		}
		return null;
	},
	setColValue : function(treeNode, colName, colValue) {
		commonUtil.debugMsg("setColValue : ", arguments);
		treeNode[colName] = colValue;
		if(!this.modifyMap.containsKey(colName)){
			this.modifyMap.put(treeNode.tId, configData.GRID_ROW_STATE_UPDATE);
		}
		if(colName == this.nameCol){
			treeNode.name = colValue;
			//this.treeObj.editName(treeNode);
			//this.treeObj.selectNode(treeNode);
			this.treeObj.refresh();
			this.treeObj.selectNode(treeNode);
		}
	},
	clickEvent : function(treeNode) {
		alert(treeNode.tId);
		if(this.bindArea){
			dataBind.dataNameBind(treeNode, this.bindArea);
		}
	},
	removeRows : function() {
		var nodes = this.treeObj.getSelectedNodes();
		if (nodes.length>0) {
			if(this.msgType && !confirm(commonUtil.getMsg(configData.MSG_MASTER_DELETE_CONFIRM))){
				return false;
			}
			for(var i=0;i<nodes.length;i++){
				if(this.modifyMap.get(nodes[i].tId) == configData.GRID_ROW_STATE_INSERT){
					this.modifyMap.remove(nodes[i].tId);
				}else{
					this.modifyMap.put(nodes[i].tId, configData.GRID_ROW_STATE_DELETE);
				}
				this.treeObj.removeNode(nodes[i]);
			}
		}
	},
	removeRow : function(treeNode) {
		if(this.msgType && !confirm(commonUtil.getMsg(configData.MSG_MASTER_DELETE_CONFIRM))){
			return false;
		}
		//alert(treeNode.tId);
		if(this.modifyMap.get(treeNode.tId) == configData.GRID_ROW_STATE_INSERT){
			this.modifyMap.remove(treeNode.tId);
		}else{
			this.modifyMap.put(treeNode.tId, configData.GRID_ROW_STATE_DELETE);
		}		
		return false;
	},
	editRow : function(treeNode) {
		if(this.modifyMap.get(treeNode.tId) != configData.GRID_ROW_STATE_INSERT){
			this.modifyMap.put(treeNode.tId, configData.GRID_ROW_STATE_UPDATE);
		}		
		//alert(treeNode.tId);
		return false;
	},
	addRow : function(treeNode, targetNode) {
		this.modifyMap.put(treeNode.tId, configData.GRID_ROW_STATE_INSERT);
		if(targetNode){
			treeNode[this.pidCol] = targetNode[this.pkCol];
			treeNode[this.pidKey] = targetNode[this.idKey];
		}
		
		//alert(treeNode.tId);
	},
	addNewRow : function() {
		var newNode = new Object();
		for(var i=0;i<this.cols.length;i++){
			newNode[this.cols[i]] = "";
		}
		newNode[this.idKey] = 0;
		newNode[this.pidKey] = 0;
		newNode["name"] = "NEW";
		
		var parentNode;
		var nodes = this.treeObj.getSelectedNodes();
		if (nodes.length>0) {			
			parentNode = nodes[0];
			newNode[this.pidCol] = parentNode[this.pkCol];
			newNode[this.pidKey] = parentNode[this.idKey];
		}
		
		newNode = this.treeObj.addNodes(parentNode,newNode);
		this.modifyMap.put(newNode[0].tId, configData.GRID_ROW_STATE_INSERT);
		alert(newNode[0].tId);
		this.treeObj.selectNode(newNode[0]);
	},
	moveRow : function(treeNode, targetNode) {
		if(this.modifyMap.get(treeNode.tId) != configData.GRID_ROW_STATE_INSERT){
			this.modifyMap.put(treeNode.tId, configData.GRID_ROW_STATE_UPDATE);
		}
		if(targetNode){
			treeNode[this.pidCol] = targetNode[this.pkCol];
			treeNode[this.pidKey] = targetNode[this.idKey];
		}
		alert(treeNode.tId);
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
	viewJsonData : function(treeId, json) {
		var treeBox = this.treeMap.get(treeId);
		treeBox.setData(json.data);
		
		if(json.data.length > 0){
			if(commonUtil.checkFn("searchOpen")){
				searchOpen(false);
			}
		}
	},
	addNewRow : function(treeId) {
		var treeBox = this.treeMap.get(treeId);
		return treeBox.addNewRow();
	},
	removeRow : function(treeId) {
		var treeBox = this.treeMap.get(treeId);
		return treeBox.removeRows();
	},
	getData : function(treeId) {
		var treeBox = this.treeMap.get(treeId);
		return treeBox.getData();
	},
	getModifyData : function(treeId) {
		var treeBox = this.treeMap.get(treeId);
		return treeBox.getModifyData();
	},
	getRowData : function(treeId, rowNum) {
		var treeBox = this.treeMap.get(treeId);
		return treeBox.getRowData(rowNum);
	},
	toString : function() {
		return "TreeList";
	}
}

var treeList = new TreeList();