<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Grid default</title>
<%@ include file="/common/include/webdek/head.jsp" %>
<link rel="stylesheet" type="text/css" href="/common/theme/webdek/css/demo_layout.css">
<script type="text/javascript">
	$(document).ready(function(){
		/**Tree 생성.
		setGrid (tree : 1.level, 2.tree구조로 변경 될 컬럼, 3.부모 key, 4.primary key, 5. 정렬순서)
		td attribute : GCol="tree,컬럼명"
		*/
		gridList.setGrid({
	    	id : "gridList",
			module : "Demo",
			command : "GRIDTREE",
			tree : "LEVEL,MENULABEL,PMENUID,MENUID,SORTORDER"
	    });
	});

	function searchList(){
		if(validate.check("searchArea")){
			var param = inputList.setRangeParam("searchArea");

			gridList.gridList({
		    	id : "gridList",
		    	param : param
		    });
		}
	}

	function commonBtnClick(btnName){
		//commonUtil.debugMsg("commonBtnClick : ", arguments);
		if(btnName == "Search"){
			searchList();
		}
	}
	
	function gridListEventDataBindEnd(gridId, dataLength){
	    if(gridId == "gridList" && dataLength > 0){
	    	var list = gridList.getGridData(gridId, true);
	    	for(var i in list){
	    		var row = list[i];
	    		var rowNum = row.get(configData.GRID_ROW_NUM);
	    		var menuId = row.get("MENUID");
	    		
	    		var childrenList = list.filter(function(data){
	    			var pMenuId = data.get("PMENUID");
	    			return menuId == pMenuId;
	    		});
	    		if(childrenList.length == 0){
	    			var $row = $("#" + gridId + " tr[" + configData.GRID_ROW_NUM + "=" + rowNum +"]");
	    			var $treeObj = $row.find("td[" + configData.GRID_COL_TYPE + "=tree]");
	    			$treeObj.find("span").eq(0).css("background", "none");
	    		}
	    	}
	    }
	}
</script>
</head>
<body>
<%@ include file="/common/include/webdek/layout.jsp" %>
<!-- content -->
<div class="content_wrap">
	<div class="content_inner">
		<%@ include file="/common/include/webdek/title.jsp" %>
		<div class="content_serch" id="searchArea">
			<div class="btn_wrap">
				<div class="fl_l">
				</div>
				<div class="fl_r">
					<input type="button" CB="Search SEARCH BTN_SEARCH" />
				</div>
			</div>
			<div class="search_inner">
				<div class="search_wrap ">
					<dl>
						<dt CL="Search"></dt>
						<dd>
							<input type="text" class="input" name="MENUGID" IAname="MENUGID" UIFormat="U" value="DEV"/>
						</dd>
					</dl>
				</div>
				<div class="btn_tab">
					<input type="button" class="btn_more" value="more" onclick="searchMore()"/>
				</div>
			</div>
		</div>
        <div class="search_next_wrap">
			<div class="content_layout tabs">
				<ul class="tab tab_style02">
					<li><a href="#tab1-1"><span>일반</span></a></li>
				</ul>
				<div class="table_box section" id="tab1-1">
					<div class="table_list01">
						<div class="scroll">
							<table class="table_b">
								<tbody id="gridList">
									<tr CGRow="true">
										<td GH="40"  GCol="rownum">1</td>
										<td GH="200" GCol="tree,MENUNAME"></td>
										<td GH="100" GCol="text,MENUGID"></td>
										<td GH="100" GCol="text,MENUID"></td>
										<td GH="100" GCol="text,PMENUID"></td>
										<td GH="100" GCol="text,MENUNAME"></td>
										<td GH="150" GCol="text,URI"></td>
										<td GH="80"  GCol="text,SORTORDER" GF="N 10"></td>
									</tr>
								</tbody>
							</table>
						</div>
					</div>
					<div class="btn_lit tableUtil">
						<button type='button' GBtn="find"></button>
						<!-- 
						<button type="button" GBtn="up"></button>
						<button type="button" GBtn="down"></button>									
						<button type='button' GBtn="add"></button>
						<button type='button' GBtn="delete"></button>
						 -->
						<button type='button' GBtn="excel"></button>
						<span class='txt_total' >총 건수 : <span GInfoArea='true'>0</span></span>
					</div>
				</div>
			</div>
		</div>
	</div>
</div>
<!-- // content -->
<%@ include file="/common/include/webdek/bottom.jsp" %>
</body>
</html>