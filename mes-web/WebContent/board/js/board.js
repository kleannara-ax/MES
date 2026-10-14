Board = function(boardId, boardSql) {
	this.id = boardId;
	this.sql = boardSql;
	this.contentId;
	this.listId = "boardList"+boardId;
	this.formId = "boardWrite"+boardId;
	this.fileAreaId = "boardFileListArea"+boardId;
	this.boardEditerId = "boardContent"+boardId;
	this.$writeForm;
	this.$editor;
	this.$fileList;	
	this.deleteFileList = new Array();
};

// 게시판 컨트롤에 필요한 작업을 처리한다.
Board.prototype = {
	setGrid : function() {
		var tmpGrid = jQuery("#"+this.listId);
		if(tmpGrid.length > 0){
			gridList.setGrid({
		    	id : this.listId,
				editable : false,
				module : "Board",
				command : this.sql,
				pageCount : 15
		    });
			
			gridList.pageList(this.listId, 1);
		}
	},
	setForm : function() {
		this.$editor = jQuery("#"+this.boardEditerId);
		if(this.$editor.length > 0){
			this.$writeForm = jQuery("#"+this.formId);
			this.$writeForm.append("<input type='hidden' name='ID' value='"+this.id+"' />");
			this.$writeForm.append("<input type='hidden' name='fileDeleteList' />");
			netUtil.setForm(this.formId);
			
			this.$fileList = jQuery("#"+this.fileAreaId);
		}
	},
	saveData : function() {
		this.$editor.val(CrossEditor.GetBodyValue(this.boardEditerId));
		if(this.deleteFileList.length > 0){
			var tmpVal = this.deleteFileList.join(" ");
			this.$writeForm.find("[name=fileDeleteList]").val(tmpVal);
		}
		netUtil.sendForm(this.formId);
	},
	searchList : function() {
		gridList.pageList(this.listId, 1);
	},
	deleteContent : function() {
		var param = new DataMap();
		param.put("CONTENT_ID", this.contentId);
		var json = netUtil.sendData({
			url : "/board/count/json/content.data",
			param : param
		});
		
		if(json && json.data != undefined){
			var pcount = parseInt(json.data);
			if(pcount == 0){
				if(confirm(commonUtil.getMsg(configData.MSG_MASTER_DELETE_CONFIRM))){
					var json = netUtil.sendData({
						url : "/board/json/boardContentDelete.data",
						param : param
					});
					
					if(json && json.data){
						commonBtnClick("List");
					}
				}				
			}else{
				alert("댓글이 있어 삭제가 불가능합니다.");
			}
		}
	},
	deleteFile : function(uuid, obj) {
		this.deleteFileList.push(uuid);
		var $obj = jQuery(obj);
		$obj.parent().next().remove();
		$obj.parent().remove();
	},
	appendFile : function() {
		var count = this.$fileList.find("input").length;
		this.$fileList.append("<br/><input type='file' name='file"+count+"'/>");
	},
	toString : function() {
		return "Board";
	}
};

BoardList = function() {
	this.BOARD_GRID_ID = "boardList";
	this.boardMap = new DataMap();
	this.uri;
	this.editUser = false;
	this.writeUser = false;
};

// 게시판 컨트롤에 필요한 작업을 처리한다.
BoardList.prototype = {
	setBoard : function(boardId, boardSql) {
		var board = new Board(boardId, boardSql);
		this.boardMap.put(boardId, board);
		board.setGrid();
		board.setForm();
	},	
	setUri : function(uri) {
		this.uri = uri;
	},
	setContentId : function(boardId, contentId) {
		this.boardMap.get(boardId).contentId = contentId;
	},
	saveData : function(boardId) {
		this.boardMap.get(boardId).saveData();
	},
	deleteContent : function(boardId) {
		this.boardMap.get(boardId).deleteContent();
	},
	appendFile : function(boardId) {
		this.boardMap.get(boardId).appendFile();
	},
	deleteFile : function(boardId, uuid, obj) {
		this.boardMap.get(boardId).deleteFile(uuid, obj);
	},
	getViewUrlByForm : function(formId, contentId) {
		var boardId = this.getFormId(formId);
		return this.getViewUrl(boardId, contentId);
	},
	getViewUrl : function(boardId, contentId) {
		var board = this.boardMap.get(boardId);
		
		if(contentId == undefined){
			contentId = board.contentId;
		}
		
		return this.uri+"?TYPE=view&ID="+board.id+"&CONTENT_ID="+contentId;
	},
	getUrl : function(boardId, boardType) {
		var board = this.boardMap.get(boardId);
		var tmpUtr = boardList.uri+"?TYPE="+boardType+"&ID="+boardId;
		
		if(board.contentId){
			tmpUtr += "&CONTENT_ID="+board.contentId;
		}
		
		return tmpUtr;
	},
	getBoardId : function(gridId) {
		return gridId.substring(9);
	},
	getFormId : function(formId) {
		return formId.substring(10);
	},
	toString : function() {
		return "BoardList";
	}
};

var boardList = new BoardList();