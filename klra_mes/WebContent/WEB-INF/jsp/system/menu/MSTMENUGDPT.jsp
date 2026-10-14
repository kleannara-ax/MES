<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>MES</title>
<%@ include file="/common/include/webdek/head.jsp" %>
<script type="text/javascript">




$(document).ready(function(){
	/**Tree 생성.
	setGrid (tree : 1.level, 2.tree구조로 변경 될 컬럼, 3.부모 key, 4.primary key, 5. 정렬순서)
	td attribute : GCol="tree,컬럼명"
	*/
	gridList.setGrid({
    	id : "gridList",
		module : "System",
		command : "MAS018_GRIDTREE",
		tree : "LVL,DEPT_NM,UP_DEPT_CD,DEPT_CD,DEPT_NM"
// 		tree : "LVL,DEPT_KR_NM,UP_DEPT_CD,DEPT_CD,DEPT_KR_NM"
// 		tree : "LVL,DEPT_KR_NM,UP_DEPT_CD,DEPT_CD,DEPT_CD"
// 		tree : "LVL,DEPT_KR_NM,UP_DEPT_CD,DEPT_CD,DISP_SEQ"
		
// 		tree : "LVL,DEPT_NM,UP_DEPT_CD,DEPT_CD,DEPT_CD"
// 		tree : "LVL,DEPT_NM,UP_DEPT_CD,DEPT_CD,DISP_SEQ"
// 		tree : "LVL,DEPT_CD,UP_DEPT_CD,DEPT_CD,DEPT_CD"
    });
	
	gridList.setGrid({
		id : "gridListSub",
		module : "System",
		command : "MAS018_GRIDSUB",
    });
});

function mstMenuGdpt_gridSubListLoad(param) {
	gridList.gridList({
		id : "gridListSub",
		param : param
	});	
}

function searchList() {
	if (!validate.check("searchArea")) return;
	
	var param = inputList.setRangeParam("searchArea");

	gridList.gridList({
    	id : "gridList",
    	param : param
    });
// 	mstMenuGdpt_gridSubListLoad(param);
}

function mstMenuGdpt_gridListRowClick() {
	if (!validate.check("searchArea")) return;
	
	var prmObj = inputList.setRangeParam("searchArea");
	prmObj.map.DEPT_CD = gridList.getRowData('gridList', gridList.getFocusRowNum('gridList') ).map.DEPT_CD;
	
// 	console.log('prmObj = ', prmObj);
	mstMenuGdpt_gridSubListLoad(prmObj);
}

function gridListEventRowDblclick(gridId, rowNum, colName) {
	if (!(gridId == 'gridList')) return;
	mstMenuGdpt_gridListRowClick();
}



function saveData(flg) {
	
// 	if (gridList.getModifyRowCount("gridList") == 0
// 		|| gridList.getModifyRowCount("gridListSub") == 0) {
// 		commonUtil.msgBox("MASTER_M0545");
// 		return;
// 	}
	
// 	var focusIdx = gridList.getSelectIndex('gridList');
// 	console.log('getSelectIndex = ', focusIdx);
// 	if (!focusIdx) return alert('부서를 선택해 주십시요.');
	
// 	console.log('validationCheck gridList = ', gridList.validationCheck("gridList", "select") );
// 	console.log('validationCheck gridListSub = ', gridList.validationCheck("gridListSub", "select") );


	var list = gridList.getSelectData("gridListSub");
// 	console.log('getSelectData = ', JSON.stringify(gridList.getSelectData("gridListSub") ) );
	if (list.length < 1) return alert('처리할 메뉴그룹을 선택해 주십시오.');
	
	if (!commonUtil.msgConfirm('처리 하겠습니까?')) return;
// 	if (!commonUtil.msgConfirm(configData.MSG_MASTER_SAVE_CONFIRM)) return;
	
// 	if (gridList.validationCheck("gridList", "select")
// 		|| gridList.validationCheck("gridListSub", "select") ) return;
	
	var param = new DataMap();
	var DEPT_CD = gridList.getRowData('gridList', gridList.getFocusRowNum('gridList') ).map.DEPT_CD;
	
// 	param.put("P_TYPE","SAVE");
	param.put("list", list);		
	param.put("DEPT_CD", DEPT_CD);
	param.put("saveCd", flg);
	
	var json = netUtil.sendData({
		url : "/system/json/saveMstMenuGdpt.data",
		param : param
// 		successFunction : function (json, status) {
// 			if( !(json && json.data && json.data > 0) ) return;
// 			commonUtil.msgBox(configData.MSG_SYSTEM_SAVEOK);
// // 			searchList();
// 		}
	});
// 	console.log('json = ', JSON.stringify(json) );
	if ( !(json && json.data) && json.data < 0) return;
// 	commonUtil.msgBox(configData.MSG_SYSTEM_SAVEOK);
	commonUtil.msgBox('처리 하였습니다.');
	mstMenuGdpt_gridListRowClick();
}

function commonBtnClick(btnName) {
	//commonUtil.debugMsg("commonBtnClick : ", arguments);
	if(btnName == "Search") searchList();
	else if(btnName == "Save") saveData('C');
	else if(btnName == "Delete") saveData('D');
}

function gridListEventDataBindEnd(gridId, dataLength) {
//     if (gridId != "gridList" && dataLength <= 0) return;
    if (gridId != "gridList") return;
   	var list = gridList.getGridData(gridId, true);
   	for (var i in list) {
   		var row = list[i];
   		var rowNum = row.get(configData.GRID_ROW_NUM);
   		var menuId = row.get("DEPT_CD");
   		
   		var childrenList = list.filter(function(data){
   			var pMenuId = data.get("UP_DEPT_CD");
   			return menuId == pMenuId;
   		});
   		if (childrenList.length == 0) {
   			var $row = $("#" + gridId + " tr[" + configData.GRID_ROW_NUM + "=" + rowNum +"]");
   			var $treeObj = $row.find("td[" + configData.GRID_COL_TYPE + "=tree]");
   			$treeObj.find("span").eq(0).css("background", "none");
   		}
   	}
   	
	if (!validate.check("searchArea")) return;
	var prmObj = inputList.setRangeParam("searchArea");
	prmObj.map.DEPT_CD = gridList.getRowData('gridList', gridList.getFocusRowNum('gridList') ).map.DEPT_CD;
   	mstMenuGdpt_gridSubListLoad(prmObj);
//    	mstMenuGdpt_gridSubListLoad(inputList.setRangeParam("searchArea") );
   	
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
					<input type="button" id="button-0-1" CB="Search SEARCH BTN_SEARCH" />
					<input type="button" id="button-0-2" CB="Save SAVE BTN_SAVE" />
					<input type="button" CB="Delete DELETE BTN_DELETE" />
				</div>
			</div>
			<div class="search_inner">
				<div class="search_wrap ">
					<dl>
						<dt CL="STD_COMPKY">회사</dt>
						<dd>
							<input type="text" class="input" name="COMPKY" value="KN"/>
						</dd>
					</dl>
				</div>
				<div class="btn_tab">
					<input type="button" class="btn_more" value="more" onclick="searchMore()"/>
				</div>
			</div>
		</div>
        <div class="content-horizontal-wrap" style="height: calc(100% - 125px);">
			<div class="content_layout tabs" style="float: left; width: calc(60% - 10px);">
				<ul class="tab tab_style02">
					<li><a href="#tab1-1"><span CL="STD_GENERAL"></span></a></li>
					<li class="btn_zoom_wrap">
						<ul>
							<li><button class="btn btn_bigger"><span>확대</span></button></li>
						</ul>
					</li>
				</ul>
				<div class="table_box section" id="tab1-1">
					<div class="table_list01">
						<div class="scroll">
							<table class="table_b">
								<tbody id="gridList">
									<tr CGRow="true">
										<td GH="40"  GCol="rownum">1</td>
										<td GH="100" GCol="text,DEPT_CD" style="text-align:center;">부서코드</td>
										<td GH="250" GCol="tree,DEPT_NM">부서명</td>
										<td GH="100" GCol="text,MNUG_INCLD_YN" style="text-align:center;">메뉴그룹포함여부</td>
										<td GH="80" GCol="text,USR_CNT" style="text-align:center;">유저숫자</td>
										<td GH="80" GCol="text,MENU_CNT" style="text-align:center;">메뉴숫자</td>
									</tr>
								</tbody>
							</table>
						</div>
					</div>
					<jsp:include page="/WEB-INF/jsp/common/commonBtnAuth.jsp">
						<jsp:param name="authCd" value="1" />
						<jsp:param name="showAuthCd" value="1,2,3,9,10" />
					</jsp:include>
				</div>
			</div>
			<div class="content_layout tabs" style="float: right; width: calc(40% - 10px);">
				<ul class="tab tab_style02">
					<li><a href="#tab1-2"><span CL="STD_DETAIL"></span></a></li>
					<li class="btn_zoom_wrap">
						<ul>
							<li><button class="btn btn_bigger"><span>확대</span></button></li>
						</ul>
					</li>
				</ul>
				<div class="table_box section" id="tab1-2">
					<div class="table_list01">
						<div class="scroll">
							<table class="table_c">
								<tbody id="gridListSub">
									<tr CGRow="true">
										<td GH="40" GCol="rownum">1</td>
										<td GH="40" GCol="rowCheck"></td>
										<td GH="0" GCol="text,COMPKY">회사ID</td>
										<td GH="100" GCol="text,MENUGROUPID">메뉴그룹ID</td>
										<td GH="200" GCol="text,MENUGNAME">메뉴그룹이름</td>
										<td GH="80" GCol="text,DPT_INCLD_YN">부서포함여부</td>
									</tr>
								</tbody>
							</table>
						</div>
					</div>
					<jsp:include page="/WEB-INF/jsp/common/commonBtnAuth.jsp">
						<jsp:param name="authCd" value="1" />
						<jsp:param name="showAuthCd" value="1,2,3,9,10" />
					</jsp:include>

				</div>
			</div>
		</div>
	</div>
</div>
<!-- // content -->
<%@ include file="/common/include/webdek/bottom.jsp" %>
</body>
</html>