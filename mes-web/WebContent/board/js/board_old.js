Board = function() {
	this.boardMap = new CubeMap();// board code별 board box객체를 저장한다.
};

// 게시판 컨트롤에 필요한 작업을 처리한다.
Board.prototype = {
	// 게시판으로 설정된 객체를 적용해준다.
	checkBoard : function($obj) {
		if(!$obj){
			$obj = jQuery('body');
		}
		$obj.find('['+cubeConfig.DATA_TYPE_ATT+"="+cubeConfig.DATA_TYPE_BOARD+"]").each(function(i, findElement){
			var $boardBox = jQuery(findElement);
			// 게시판 표시를 위한 옵션을 확인한다. board id, view type, content id
			var boardCode = $boardBox.attr(cubeConfig.DATA_BOARD_CODE_ATT);
			var boardArgs = boardCode.split(",");
			var boardBoxId = $boardBox.attr("id");
			var boardType;
			var contentId;
			var listType;
			if(boardArgs.length > 1){
				boardCode = boardArgs[0];
				boardType = boardArgs[1];
				contentId = boardArgs[2];
				if(boardType == "list"){
					listType = boardArgs[2];
				}else if(boardArgs.length > 3){
					listType = boardArgs[3];
				}
			}else{
				boardType = "list";
			}			
			
			//cubeBoard.viewBoard($boardBox, boardCode, boardType, contentId, listType);
			switch(boardType){
				case "list"://게시판 목록 조회
					// 포함된 grid id를 가져온다.
					var boardListId = $boardBox.find("["+cubeConfig.DATA_GRID_ATT+"]").attr("id");
					cubeBoard.getContentList(boardCode, boardListId, $boardBox);// board grid에 데이터를 가져온다.				
					break;
				case "view"://게시글 조회			
					cubeBoard.getContent(contentId, boardBoxId);// 게시글 데이터를 가져온다.
					cubeBoard.getContentFileList(contentId, $boardBox);// 게시글에 연결된 file list를 가져온다.
					cubeBoard.getContentCommentList($boardBox);// 게시글에 연결된 comment list를 가져온다.
					var map = new CubeMap();
					map.put("CONTENT_ID", contentId);
					cubeNet.sendJsonAjax("/CubeCms/cubeJson/boardContentVisit.cube", map);//게시글 조회수 카운트 처리를 한다.	
					
					cubeBoard.setRequestUrl(boardCode, contentId);
					break;
				case "update":// 게시글 수정
					cubeUI.checkEditor($boardBox);
					// 수정화면에 포함된 form ajax를 처리하기 위한 선언
					cubeNet.sendFormAjax("boardForm", "cubeBoard.updateContentSuccess", null, contentId);
					cubeBoard.getContent(contentId, boardBoxId);// 게시글 데이터를 가져온다.
					cubeBoard.getContentFileList(contentId, $boardBox);// 게시글에 연결된 file list를 가져온다.
					break;
				case "rewrite":// 답글작성
					cubeUI.checkEditor($boardBox);
					// 수정화면에 포함된 form ajax를 처리하기 위한 선언
					cubeNet.sendFormAjax("boardForm", "cubeBoard.insertContentSuccess");
					var map = new CubeMap();
					map.put("CONTENT_ID", contentId);
					var json = cubeNet.sendJsonData("/cubefw/Board/map/cubeJson/CFBDCM0010.cube", map, "cubeBoard.getContentSuccess");
					json.data["TITLE"] = "Re:"+json.data["TITLE"];
					
					cubeBind.dataBind(json.data, boardBoxId);
					break;
				case "write":
					cubeUI.checkEditor($boardBox);
					$boardBox.find("[name=ID]").val(boardCode);
					cubeNet.sendFormAjax("boardForm", "cubeBoard.insertContentSuccess");
					break;
			}
		});
	},
	boardModify : function(itemObj, boardType) {
		var $iObj = cubeCommon.getJObj(itemObj);
		var $boardBox = $iObj.parents('['+cubeConfig.DATA_TYPE_ATT+"="+cubeConfig.DATA_TYPE_BOARD+"]");
		var content_id = $boardBox.find("[name=CONTENT_ID]").val();
		this.boardLink(boardType, content_id);
	},
	boardLink : function(boardType, content_id) {
		var tmpUrl = cubeConfig.REQUEST_URI+"?TYPE="+boardType;		
		if(content_id){
			tmpUrl = tmpUrl + "&ID="+content_id;
		}
		location.href = tmpUrl;
	},
	selectBoard : function(itemObj) {
		var $iObj = cubeCommon.getJObj(itemObj);
		var $boardBox = $iObj.parents('['+cubeConfig.DATA_TYPE_ATT+"="+cubeConfig.DATA_TYPE_BOARD+"]");
		var boardCode = $boardBox.attr(cubeConfig.DATA_TYPE_BOARD_CODE_ATT);
		var boardListId = $boardBox.find("["+cubeConfig.DATA_GRID_ATT+"]").attr("id");
		this.getContentList(boardCode, boardListId, $boardBox);
	},
	// 게시글 리스트를 가져온다.
	getContentList : function(boardCode, boardListId, $boardBox) {
		var map = new CubeMap();
		map.put("ID", boardCode);
		cubeBind.sendParamData(map, $boardBox.attr("id"));
		cubeBind.gridPageData(boardListId, map);// paging정보를 가져온다.
		cubeNet.sendJsonAjax("/cubefw/Board/count/cubeJson/CFBDCM0010.cube", map, "cubeBoard.getContentListCountSuccess", null, boardListId);
		cubeNet.sendJsonAjax("/cubefw/Board/paging/cubeJson/CFBDCM0010.cube", map, "cubeBoard.getContentListSuccess", null, boardListId);
	},
	getContentListCountSuccess : function(json, boardListId) {
		cubeBind.gridPageBind(boardListId, json.data);
		cubeBind.gridPageInfoBind(boardListId);
	},
	getContentListSuccess : function(json, boardListId) {
		cubeBind.gridBind(boardListId, json.data);
	},
	// 게시글을 가져온다.
	getContent : function(contentId, boardBoxId) {
		var map = new CubeMap();
		map.put("CONTENT_ID", contentId);
		cubeNet.sendJsonAjax("/cubefw/Board/map/cubeJson/CFBDCM0010.cube", map, "cubeBoard.getContentSuccess", null, boardBoxId);	
	},
	getContentSuccess : function(json, boardBoxId) {
		var $boardBox = cubeCommon.getJObj(boardBoxId);
		if(cubeConfig.SES_ROLE_DATA != "500"){
			if(cubeConfig.SES_USER_ID != json.data["CREATEUSER"]){			
				$boardBox.find("["+cubeConfig.CREATE_USER_ROLE_AREA+"]").remove();
			}
		}
		cubeBind.dataBind(json.data, boardBoxId);
		if(json.data["UUID"]){
			$boardBox.find("[titleImage]").html("<img width='100' src='"+json.data["FNAME"]+"' />");
		}
	},
	// 게시글에 포함된 파일 리스트를 가져온다.
	getContentFileList : function(contentId, $boardBox) {
		var $fileGrid = $boardBox.find("["+cubeConfig.DATA_GRID_ATT+"="+cubeConfig.DATA_TYPE_FILE_GRID_ATT+"]");
		if($fileGrid.length){
			var fileListId = $fileGrid.attr("id");
			var map = new CubeMap();
			map.put("CONTENT_ID", contentId);
			cubeNet.sendJsonAjax("/cubefw/CubeCms/list/cubeJson/CFBDCM0013.cube", map, "cubeBoard.getContentFileListSuccess", null, fileListId);
		}		
	},	
	getContentFileListSuccess : function(json, fileListId) {
		cubeBind.gridBind(fileListId, json.data);
	},
	// 게시글에 포함된 덧글 리스트를 가져온다.
	getContentCommentList : function($boardBox) {
		var $boardBox = cubeCommon.getJObj($boardBox);
		var contentId = $boardBox.attr(cubeConfig.DATA_TYPE_BOARD_CONTENT_ID_ATT);
		var $commentGrid = $boardBox.find("["+cubeConfig.DATA_TYPE_COMMENT_GRID_ATT+"]");
		if($commentGrid.length){
			commentListId = $commentGrid.attr("id");
			var map = new CubeMap();
			map.put("CONTENT_ID", contentId);
			cubeNet.sendJsonAjax("/cubefw/CubeCms/list/cubeJson/CFBDCM0011.cube", map, "cubeBoard.getContentCommentListSuccess", null, commentListId);
		}		
	},
	getContentCommentListSuccess : function(json, commentListId) {
		cubeBind.gridBind(commentListId, json.data);
	},
	// 게시글을 저장후 조회 화면으로 돌아간다.
	insertContentSuccess : function(json) {
		//this.boardLink("list");
		this.boardLink("view", json);
	},
	// 게시글을 수정한 후 조회 화면으로 돌아간다.
	updateContentSuccess : function(json, contentId) {
		this.boardLink("view", contentId);
	},
	// 게시글을 삭제합니다.
	deleteContent : function(itemObj) {
		var $obj = cubeCommon.getJObj(itemObj);
		var $boardBox = $obj.parents('['+cubeConfig.DATA_TYPE_ATT+"="+cubeConfig.DATA_TYPE_BOARD+"]");
		var boardBoxId = $boardBox.attr("id");
		if($boardBox.find("#PID")){
			if($boardBox.find("#PID").val() != $boardBox.find("#CONTENT_ID").val()){
				alert("부모글이 있는 경우 삭제가 불가합니다.");
				return;
			}
		}
		if(!confirm("삭제하시겠습니까?")){
			return;
		}
		var map = new CubeMap();
		var contentId = $boardBox.attr(cubeConfig.DATA_TYPE_BOARD_CONTENT_ID_ATT);
		map.put("CONTENT_ID", contentId);
		cubeBind.sendParamData(map, boardBoxId);
		cubeNet.sendJsonAjax("/cubefw/CubeCms/delete/cubeJson/CFBDCM0010.cube", map, "cubeBoard.deleteContentSuccess", null, boardBoxId);	
	},
	deleteContentSuccess : function(json, boardBoxId) {
		this.boardLink("list");
	},
	// 게시물에 덧글을 추가합니다.
	insertComment : function(commentBoxId) {
		var $obj = cubeCommon.getJObj(commentBoxId);
		var $boardBox = $obj.parents('['+cubeConfig.DATA_TYPE_ATT+"="+cubeConfig.DATA_TYPE_BOARD+"]");
		var boardBoxId = $boardBox.attr("id");
		
		var contentId = $boardBox.attr(cubeConfig.DATA_TYPE_BOARD_CONTENT_ID_ATT);
		var map = new CubeMap();
		map.put("CONTENT_ID", contentId);
		cubeBind.sendParamData(map, commentBoxId);
		cubeNet.sendJsonAjax("/cubefw/CubeCms/insert/cubeJson/CFBDCM0011.cube", map, "cubeBoard.insertCommentSuccess", null, boardBoxId);
	},
	insertCommentSuccess : function(json, boardBoxId) {
		this.getContentCommentList(boardBoxId);
	},
	// 게시글에 파일 입력 폼 추가
	addFileForm : function(fileListId) {
		var $fileList = jQuery("#"+fileListId);
		var fileCount = $fileList.attr(cubeConfig.DATA_FILE_COUNT_ATT);
		if(fileCount){
			fileCount = parseInt(fileCount)+1;			
		}else{
			fileCount = 1;
		}
		$fileList.attr(cubeConfig.DATA_FILE_COUNT_ATT, fileCount);
		var tmpHtml = "<div>"
					+ "<a href='#' onclick='cubeBoard.fileFormRemove(this)'>"
					+ "<img src='/cubefw/css/images/btn_del.gif'/>"
					+ "</a>"
					+ "<input type='file' name='FILE"+fileCount+"' />"
					+ "</div>";
		jQuery(tmpHtml).appendTo($fileList);
	},
	fileFormRemove : function(btnObj) {
		jQuery(btnObj).parent().remove();
	},
	fileChange : function(itemObj) {
		var $iObj = cubeCommon.getJObj(itemObj);
		var $boardBox = $iObj.parents('['+cubeConfig.DATA_TYPE_ATT+"="+cubeConfig.DATA_TYPE_BOARD+"]");
		var $fileGrid = $boardBox.find("["+cubeConfig.DATA_TYPE_FILE_GRID_ATT+"]");
		var $uuidObj = $fileGrid.find(".UUID");
		cubeBoard.contentFileDelete($uuidObj,$uuidObj.val());
	},
	contentFileDelete : function(btnObj, uuid) {
		var $fileDeleteListForm = jQuery("#fileDeleteList");
		var $obj = jQuery(btnObj);
		if($fileDeleteListForm.length){
			if($fileDeleteListForm.val()){
				$fileDeleteListForm.val($fileDeleteListForm.val()+" "+uuid);
			}else{
				$fileDeleteListForm.val(uuid);
			}
			var $rowObj = $obj.parents("["+cubeConfig.DATA_ROW_ATT+"]");
			//$rowObj.remove();
			$rowObj.css("text-decoration","line-through");
			$obj.remove();
		}else{
			var $formObj = jQuery(btnObj).parents("form");
			jQuery("<input type='hidden' name='fileDeleteList' id='fileDeleteList'/>").appendTo($formObj);
			this.contentFileDelete(btnObj, uuid);
		}		
	},
	contentCommentDelete : function(btnObj, commentId) {
		var $obj = jQuery(btnObj);
		var map = new CubeMap();
		map.put("COMMENT_ID", commentId);
		cubeNet.sendJsonAjax("/cubefw/CubeCms/delete/cubeJson/CFBDCM0011.cube", map);
		var $rowObj = $obj.parents("["+cubeConfig.DATA_ROW_ATT+"]");
		$rowObj.remove();
	},
	communityView : function(gid) {
		cubeCommon.popupOpen('/CubeCms/cubePage/communityView.cube?ID='+gid,'990','610');
	},	
	imageView : function(imgObj, imgSrc) {
		var $obj = cubeCommon.getJObj(imgObj);
		$obj.attr('src', imgSrc);
	},
	setRequestUrl : function(boardCode, contentId) {
		var tmpUrl = cubeConfig.REQUEST_URL;
		tmpUrl = tmpUrl.substring(0,tmpUrl.indexOf("/", 10));		
		
		cubeConfig.SHARE_URL = tmpUrl+"/cubeboard/share/"+boardCode+"_"+contentId+".cube";
	}
};

var board = new Board();