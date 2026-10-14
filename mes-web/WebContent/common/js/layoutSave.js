LayoutSave = function() {
	this.$invisibleGrid;
	this.$visibleGrid;
	this.$grid;
	this.layoutMoveType = true;
};

LayoutSave.prototype = {
	setLauyout : function($grid) {
		if($grid instanceof String){
			$grid = jQuery("#"+$grid);
		}
		if($grid.headRowCount > 1){
			this.layoutMoveType = false;
		}
		if(!this.$invisibleGrid){
			this.$invisibleGrid = gridList.getGridBox(configData.GRID_LAYOUT_SAVE_INVISIBLE_ID);
			this.$visibleGrid = gridList.getGridBox(configData.GRID_LAYOUT_SAVE_VISIBLE_ID);
		}
		this.$grid = $grid;
				
		this.setGridData(this.$invisibleGrid, this.$grid.invisibleLayOutData);
		this.setGridData(this.$visibleGrid, this.$grid.visibleLayOutData);
		
		showLayoutSave();
	},
	setGridData : function($grid, data) {
		if(data){
			data = configData.GRID_LAYOUT_SAVE_COLNAME+configData.DATA_COL_SEPARATOR
					+configData.GRID_LAYOUT_SAVE_COLWIDTH+configData.DATA_COL_SEPARATOR
					+configData.GRID_LAYOUT_SAVE_COLTEXT+configData.DATA_ROW_SEPARATOR					
					+data;
			
			$grid.reset();
			$grid.setData(data);
			$grid.setViewStart();
		}else{
			var addCols = new Array();
			addCols.push(configData.GRID_LAYOUT_SAVE_COLNAME);
			addCols.push(configData.GRID_LAYOUT_SAVE_COLWIDTH);
			addCols.push(configData.GRID_LAYOUT_SAVE_COLTEXT);
			$grid.reset();
			$grid.resetCols(addCols);
		}
	},
	moveLeft : function() {
		if(this.layoutMoveType){
			if(this.$visibleGrid.selectedData){
				var rowNum;
				var rowData;
				for(var i=this.$visibleGrid.selectedRows[0];i<=this.$visibleGrid.selectedRows[1];i++){
					rowNum = this.$visibleGrid.getRowNum(i);
					rowData = this.$visibleGrid.getRowData(rowNum);
					this.$invisibleGrid.addRow(rowData);
				}
				for(var i=this.$visibleGrid.selectedRows[1];i>=this.$visibleGrid.selectedRows[0];i--){
					rowNum = this.$visibleGrid.getRowNum(i);
					this.$visibleGrid.deleteRow(rowNum, false);
				}
			}else{
				var focusRowNum = this.$visibleGrid.getFocusRowNum();
				if(!isNaN(focusRowNum) && focusRowNum != -1){
					var rowData = this.$visibleGrid.getRowData(focusRowNum);
					this.$invisibleGrid.addRow(rowData);
					this.$visibleGrid.deleteRow(focusRowNum, false);
				}				
			}			
		}
	},
	moveLeftAll : function() {
		if(this.layoutMoveType){
			var rowDataList = this.$visibleGrid.getDataAll();
			for(var i=0;i<rowDataList.length;i++){
				this.$invisibleGrid.addRow(rowDataList[i]);
			}
			this.$visibleGrid.reset();
		}
	},
	moveRight : function() {
		if(this.layoutMoveType){
			if(this.$invisibleGrid.selectedData){
				var rowNum;
				var rowData;
				for(var i=this.$invisibleGrid.selectedRows[0];i<=this.$invisibleGrid.selectedRows[1];i++){
					rowNum = this.$invisibleGrid.getRowNum(i);
					rowData = this.$invisibleGrid.getRowData(rowNum);
					this.$visibleGrid.addRow(rowData);
				}
				for(var i=this.$invisibleGrid.selectedRows[1];i>=this.$invisibleGrid.selectedRows[0];i--){
					rowNum = this.$invisibleGrid.getRowNum(i);
					this.$invisibleGrid.deleteRow(rowNum, false);
				}
			}else{
				var focusRowNum = this.$invisibleGrid.getFocusRowNum();
				if(!isNaN(focusRowNum) && focusRowNum != -1){
					var rowData = this.$invisibleGrid.getRowData(focusRowNum);
					this.$visibleGrid.addRow(rowData);
					this.$invisibleGrid.deleteRow(focusRowNum, false);
				}
			}
		}
	},
	moveRightAll : function() {
		if(this.layoutMoveType){
			var rowDataList = this.$invisibleGrid.getDataAll();
			for(var i=0;i<rowDataList.length;i++){
				this.$visibleGrid.addRow(rowDataList[i]);
			}
			this.$invisibleGrid.reset();
		}		
	},
	confirmLayout : function() {
		this.$grid.invisibleLayOutData = this.$invisibleGrid.getDataStringAll();
		this.$grid.visibleLayOutData = this.$visibleGrid.getDataStringAll();
		this.$grid.setLayout();
	},
	moveUp : function() {
		if(this.layoutMoveType){
			if(this.$visibleGrid.selectedData){
				if(this.$visibleGrid.selectedRows[0] == 0){
					return;
				}
				for(var i=this.$visibleGrid.selectedRows[0];i<=this.$visibleGrid.selectedRows[1];i++){
					this.$visibleGrid.replaceViewData(i-1,i);
				}
				var startRowNum = this.$visibleGrid.getRowNum(this.$visibleGrid.selectedRows[0]-1);
				var endRowNum = this.$visibleGrid.getRowNum(this.$visibleGrid.selectedRows[1]-1);
				//var tmpFocusRowNum = this.$visibleGrid.selectedRows[0] + parseInt((this.$visibleGrid.selectedRows[1] - this.$visibleGrid.selectedRows[0])/2);
				var tmpFocusRowNum = this.$visibleGrid.selectedRows[0]-1;
				tmpFocusRowNum = this.$visibleGrid.getRowNum(tmpFocusRowNum);
				this.$visibleGrid.setFocus(tmpFocusRowNum, "COLTEXT");
				this.$visibleGrid.selectArea(startRowNum, "COLTEXT", endRowNum, "COLTEXT");
			}else{
				var focusRowNum = this.$visibleGrid.getFocusRowNum();
				var focusRowViewNum = this.$visibleGrid.getViewRowNum(focusRowNum);
				if(focusRowViewNum == 0){
					return;
				}
				this.$visibleGrid.replaceViewData(focusRowViewNum-1);
				this.$visibleGrid.setFocus(focusRowNum, "COLTEXT");
			}
		}		
	},
	moveTop : function() {
		if(this.layoutMoveType){
			if(this.$visibleGrid.selectedData){
				if(this.$visibleGrid.selectedRows[0] == 0){
					return;
				}
				var endRowViewNum = this.$visibleGrid.selectedRows[1];
				var countViewNum = this.$visibleGrid.selectedRows[1] - this.$visibleGrid.selectedRows[0];
				for(var i=this.$visibleGrid.selectedRows[1];i>=this.$visibleGrid.selectedRows[0];i--){
					this.$visibleGrid.replaceViewTop(endRowViewNum);
				}
				var startRowNum = this.$visibleGrid.getRowNum(0);
				var endRowNum = this.$visibleGrid.getRowNum(countViewNum);
				this.$visibleGrid.setFocus(startRowNum, "COLTEXT");
				this.$visibleGrid.selectArea(startRowNum, "COLTEXT", endRowNum, "COLTEXT");
			}else{
				var focusRowNum = this.$visibleGrid.getFocusRowNum();
				var focusRowViewNum = this.$visibleGrid.getViewRowNum(focusRowNum);
				if(focusRowViewNum == 0){
					return;
				}
				this.$visibleGrid.replaceViewTop();
				this.$visibleGrid.setFocus(focusRowNum, "COLTEXT");
			}			
		}		
	},
	moveDown : function() {
		if(this.layoutMoveType){
			if(this.$visibleGrid.selectedData){
				if(this.$visibleGrid.selectedRows[1] == this.$visibleGrid.viewDataList.length-1){
					return;
				}
				for(var i=this.$visibleGrid.selectedRows[1];i>=this.$visibleGrid.selectedRows[0];i--){
					this.$visibleGrid.replaceViewData(i+1,i);
				}
				var startRowNum = this.$visibleGrid.getRowNum(this.$visibleGrid.selectedRows[0]+1);
				var endRowNum = this.$visibleGrid.getRowNum(this.$visibleGrid.selectedRows[1]+1);
				//var tmpFocusRowNum = this.$visibleGrid.selectedRows[0] + parseInt((this.$visibleGrid.selectedRows[1] - this.$visibleGrid.selectedRows[0])/2);
				var tmpFocusRowNum = this.$visibleGrid.selectedRows[0]+1;
				tmpFocusRowNum = this.$visibleGrid.getRowNum(tmpFocusRowNum);
				this.$visibleGrid.setFocus(tmpFocusRowNum, "COLTEXT");
				this.$visibleGrid.selectArea(startRowNum, "COLTEXT", endRowNum, "COLTEXT");
			}else{
				var focusRowNum = this.$visibleGrid.getFocusRowNum();
				var focusRowViewNum = this.$visibleGrid.getViewRowNum(focusRowNum);
				if(focusRowViewNum == this.$visibleGrid.viewDataList.length-1){
					return;
				}
				this.$visibleGrid.replaceViewData(focusRowViewNum+1);
				this.$visibleGrid.setFocus(focusRowNum, "COLTEXT");
			}
		}
	},
	moveBottom : function() {
		if(this.layoutMoveType){
			if(this.$visibleGrid.selectedData){
				if(this.$visibleGrid.selectedRows[1] == this.$visibleGrid.viewDataList.length-1){
					return;
				}
				var startRowViewNum = this.$visibleGrid.selectedRows[0];
				var countViewNum = this.$visibleGrid.selectedRows[1] - this.$visibleGrid.selectedRows[0];
				for(var i=this.$visibleGrid.selectedRows[0];i<=this.$visibleGrid.selectedRows[1];i++){
					this.$visibleGrid.replaceViewBottom(startRowViewNum);
				}
				var startRowNum = this.$visibleGrid.getRowNum(this.$visibleGrid.viewDataList.length-1-countViewNum);
				var endRowNum = this.$visibleGrid.getRowNum(this.$visibleGrid.viewDataList.length-1);
				this.$visibleGrid.setFocus(endRowNum, "COLTEXT");
				this.$visibleGrid.selectArea(startRowNum, "COLTEXT", endRowNum, "COLTEXT");
			}else{
				var focusRowNum = this.$visibleGrid.getFocusRowNum();
				var focusRowViewNum = this.$visibleGrid.getViewRowNum(focusRowNum);
				if(focusRowViewNum == this.$visibleGrid.viewDataList.length-1){
					return;
				}
				this.$visibleGrid.replaceViewBottom();
				this.$visibleGrid.setFocus(focusRowNum, "COLTEXT");
			}
		}
	},
	saveLayout : function($grid) {
		if($grid){
			this.$grid = $grid;
		}	
		if(this.$visibleGrid.getDataStringAll()){
			this.confirmLayout();
			
			var param = new DataMap();
			param.put("PROGID", configData.MENU_ID);
			param.put("COMPID", this.$grid.id);
			param.put("LYOTID", "DEFAULT");
			//param.put("LAYDAT", this.$grid.visibleLayOutData);
			param.put("LAYDAT", this.$grid.getLayOutData());
			var sendType;
			if(this.$grid.layoutDataMap.containsKey("DEFAULT")){
				sendType = "update";
			}else{
				sendType = "insert";
				this.$grid.layoutDataMap.put("DEFAULT",this.$grid.visibleLayOutData);
			}
			
			netUtil.send({
				module : "Common",
				command : "USRLO",
				bindId : this.$grid.id,
				bindType : "layout",
				sendType : sendType,
				param :param
			});		
		}
	},
	resetLayout : function($grid) {
		if($grid){
			this.$grid = $grid;
		}
		if(this.$grid.headRowCount > 1){
			this.layoutMoveType = false;
		}
		if(!this.$invisibleGrid){
			this.$invisibleGrid = gridList.getGridBox(configData.GRID_LAYOUT_SAVE_INVISIBLE_ID);
			this.$visibleGrid = gridList.getGridBox(configData.GRID_LAYOUT_SAVE_VISIBLE_ID);
		}
				
		this.setGridData(this.$invisibleGrid, "");
		this.setGridData(this.$visibleGrid, this.$grid.defaultLayOutData);
		
		//showLayoutSave();
	},
	layoutRowDblclick : function(gridId, rowNum, colName, colValue) {
		if(gridId == configData.GRID_LAYOUT_SAVE_VISIBLE_ID){
			this.moveLeft();
		}else if(gridId == configData.GRID_LAYOUT_SAVE_INVISIBLE_ID){
			this.moveRight();
		}
	},
	toString : function() {
		return "LayoutSave";
	}
}

var layoutSave = new LayoutSave();