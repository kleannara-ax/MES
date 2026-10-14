<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Board</title>
<%@ include file="/common/include/head.jsp" %>
<%@ include file="/board/include/head.jsp" %>
<script type="text/javascript">
	$(document).ready(function(){
		boardList.setBoard('<%=boardId%>','<%=boardSql%>');
	});
	
	function gridPageLinkEventBefore(gridId){
		var boardId = boardList.getBoardId(gridId);
		var param = new DataMap();
		param.put("ID", boardId);
		return param;
	}
	
	function gridListEventRowDblclick(gridId, rowNum){
		//commonUtil.debugMsg("gridListEventRowDblclick : ", arguments);
		var boardId = boardList.getBoardId(gridId);
		var rowData = gridList.getRowData(gridId, rowNum);
		this.location.href = boardList.getViewUrl(boardId, rowData.get("CONTENT_ID"));
	}
	
	function gridListEventDataBindEnd(gridId, dataLength){
		//commonUtil.debugMsg("gridListEventDataBindEnd : ", arguments);
		var $title = jQuery("#"+gridId).find("["+configData.GRID_COL_NAME+"=TITLE]");
		for(var i=0;i<dataLength;i++){
			var rowData = gridList.getRowData(gridId, i);
			if(rowData.get("DEPT") > '0'){				
				var dept = parseInt(rowData.get("DEPT"));
				var tmpLeft = dept*20;
				$title.eq(i).css("padding-left", tmpLeft+"px");		
			}
		}
	}
	
	function netUtilEventSetFormSuccess(formId, data){
		if(data){
			this.location.href = boardList.getViewUrlByForm(formId, parseInt(data));
		}
	}
	
	function commonBtnClick(btnName){
		if(btnName == "List"){
			this.location.href = boardList.getUrl('<%=boardId%>','list');
		}else if(btnName == "Search"){
			board.searchList();
		}else if(btnName == "Write"){
			this.location.href = boardList.getUrl('<%=boardId%>','write');
		}else if(btnName == "Save"){
			boardList.saveData('<%=boardId%>');
		}else if(btnName == "Edit"){
			this.location.href = boardList.getUrl('<%=boardId%>','edit');
		}else if(btnName == "Delete"){
			boardList.deleteContent('<%=boardId%>');
		}else if(btnName == "Rewrite"){
			this.location.href = boardList.getUrl('<%=boardId%>','rewrite');
		}
	}
</script>
</head>
<body>
<div class="contentHeader">
	<div class="util">
		<button CB="List SEARCH 목록보기"></button>
		<button CB="Search SEARCH BTN_DISPLAY"></button>
		<%
		if(compky.equals("IMF")){
		%>
		<button CB="Write SAVE 글쓰기"></button>
		<%
		}
		%>
		<button CB="Save SAVE STD_SAVE"></button>
		<button CB="Edit SAVE BTN_CHANGE"></button>
		<button CB="Delete DELETE BTN_DELETE"></button>
	</div>
</div>
<!-- content -->
<div class="content">
	<div class="innerContainer">
		<!-- contentContainer -->
		<div class="contentContainer">
			<div class="bottomSect type1">
				<div class="tabs">
					<ul class="tab type2">
						<li><a href="#tabs1-1"><span CL='STD_SEARCH'>탭메뉴1</span></a></li>
					</ul>
					<div id="tabs1-1">
						<div class="section type1">
							<jsp:include page="/board/boardtmp.page" flush="true">
								<jsp:param name="ID" value="<%=boardId%>" />
								<jsp:param name="TYPE" value="<%=boardType%>" />
							</jsp:include>
						</div>
					</div>
				</div>
			</div>
		</div>
		<!-- //contentContainer -->
	</div>
</div>
<!-- //content -->
<%@ include file="/common/include/bottom.jsp" %>
</body>
</html>