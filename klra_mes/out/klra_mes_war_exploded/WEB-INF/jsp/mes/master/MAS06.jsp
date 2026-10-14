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
	
// 	setGridListA_mas06('MAS018_GRIDTREE');
	setGridListA_mas06('MAS018_GRIDTREESRCH');
	
	var param = inputList.setRangeParam("searchArea");
	param.map.COMPKY = 'KN';
	loadGrd_mas06('gridList_A', param);
	
// 	gridList.resetGrid('gridList_A');
// 	setGridListA_mas06('MAS018_GRIDTREESRCH');
	
	gridList.setGrid({
		id : "gridList",
		url : "/mes/Master/MAS06/json/datalist.data",
		bigdata : false,
		selectRowDeleteType : true
	});
	
// 	gridList.setGrid({
// 		id : "gridListSub",
// 		module : "System",
// 		command : "MAS018_GRIDSUB",
//     });
	
});


function setGridListA_mas06(cmd) {
	/**Tree 생성.
	setGrid (tree : 1.level, 2.tree구조로 변경 될 컬럼, 3.부모 key, 4.primary key, 5. 정렬순서)
	td attribute : GCol="tree,컬럼명"
	*/
	gridList.setGrid({
    	id : "gridList_A",
		module : "System",
		command : cmd,
		tree : "LVL,DEPT_NM,UP_DEPT_CD,DEPT_CD,DEPT_NM"
// 		tree : "LVL,DEPT_KR_NM,UP_DEPT_CD,DEPT_CD,DEPT_KR_NM"
// 		tree : "LVL,DEPT_KR_NM,UP_DEPT_CD,DEPT_CD,DEPT_CD"
// 		tree : "LVL,DEPT_KR_NM,UP_DEPT_CD,DEPT_CD,DISP_SEQ"
		
// 		tree : "LVL,DEPT_NM,UP_DEPT_CD,DEPT_CD,DEPT_CD"
// 		tree : "LVL,DEPT_NM,UP_DEPT_CD,DEPT_CD,DISP_SEQ"
// 		tree : "LVL,DEPT_CD,UP_DEPT_CD,DEPT_CD,DEPT_CD"
    });
}


function loadGrd_mas06(id, prm) {
	gridList.gridList({
    	id : id,
    	param : prm
    });
}



function searchList() {
	
	if (!validate.check("searchArea")) return;
	
	var param = inputList.setRangeParam("searchArea");
	param.map.COMPKY = 'KN';
	param.put("P_TYPE","LIST");
	
// 	setGridListA_mas06('MAS018_GRIDTREESRCH');
// 	setGridListA_mas06('MAS018_GRIDTREE');
	loadGrd_mas06('gridList_A', param);
	
	loadGrd_mas06('gridList', param);
}

function gridListEventRowDblclick(gridId, rowNum, colName) {
	if (gridId != 'gridList_A') return;
	
// 	var param = {P_TYPE: "DBCLCK_LIST"};
// 	param.DEPT_CD = gridList.getRowData('gridList_A', gridList.getFocusRowNum('gridList_A') ).map.DEPT_CD;
// 	console.log('param -> '+JSON.stringify(param) );
	var param = inputList.setRangeParam("searchArea");
	param.put("P_TYPE","DBCLCK_LIST");
	param.put("DEPT_KR_NM","");
	param.put("DEPT_CD", gridList.getRowData('gridList_A', gridList.getFocusRowNum('gridList_A') ).map.DEPT_CD);
// 	console.log('param -> '+param);
	
	loadGrd_mas06('gridList', param);
}

function gridListEventColValueChange(gridId, rowNum, colName, colValue) {
	if(gridId == "gridList") {
		if(colName == "UP_DEPT_CD") {
			var deptCd = new Array();
			
			for (var i = 0; i < gridList.getGridDataCount(gridId); i++) {
				deptCd.push(gridList.getColData(gridId, i, "DEPT_CD"));
			}
			
			if (deptCd.indexOf(colValue) < 0) {
				alert("부서정보가 있는 코드만 등록가능합니다.");
				gridList.setColValue(gridId, rowNum, colName, "");
				return;
			}
		}
	}
}

function saveData() {
	if(gridList.getModifyRowCount("gridList") == 0 ) {
		commonUtil.msgBox("MASTER_M0545");
		return;
	}
	
	if (!commonUtil.msgConfirm(configData.MSG_MASTER_SAVE_CONFIRM)) {
		return;
	}
	
	if (gridList.validationCheck("gridList", "data")) {
		var list = gridList.getModifyList("gridList", "A");

		var param = new DataMap();
		
		param.put("P_TYPE", "SAVE");
		param.put("list", list);

		var json = netUtil.sendData({
			url : "/mes/Master/MAS06/json/datalist.data",
			param : param
		});
		
		if (json) {
			if (json.data) {
				commonUtil.msgBox(configData.MSG_SYSTEM_SAVEOK);
				searchList();
			}
		}
	}
}

function commonBtnClick(btnName) {
	//commonUtil.debugMsg("commonBtnClick : ", arguments);
	if (btnName == "Search") {
		var param = new DataMap();
        param.put("PROGID", "<%= menuId%>");
        param.put("LGTYPE", "SEARCH");
        var json = netUtil.sendData({
            url: "/mes/system/json/saveLog.data",
            param : param
        });
		
		searchList();
	} else if (btnName == "Save") {
		saveData();
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
					<input type="button" id="button-0-1" CB="Search SEARCH BTN_SEARCH" />
					<input type="button" id="button-0-2" CB="Save SAVE BTN_SAVE" />
				</div>
			</div>
			<div class="search_inner">
				<div class="search_wrap ">
					<dl>
						<dt>부서명</dt>
						<dd><input type="text" class="input" name="DEPT_KR_NM" UIInput="SR"/></dd>
					</dl>
				</div>
				<div class="btn_tab">
					<input type="button" class="btn_more" value="more" onclick="searchMore()"/>
				</div>
			</div>
		</div>
        <div class="content-horizontal-wrap" style="height: calc(100% - 80px);">
			<div class="content_layout tabs" style="float: left; width: calc(35% - 10px);">
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
								<tbody id="gridList_A">
									<tr CGRow="true">
										<td GH="40"  GCol="rownum">1</td>
										<td GH="100" GCol="text,DEPT_CD" style="text-align:center;">부서코드</td>
										<td GH="250" GCol="tree,DEPT_NM">부서명</td>
<!-- 										<td GH="100" GCol="text,MNUG_INCLD_YN" style="text-align:center;">메뉴그룹포함여부</td> -->
										<td GH="80" GCol="text,USR_CNT" style="text-align:center;">유저숫자</td>
<!-- 										<td GH="80" GCol="text,MENU_CNT" style="text-align:center;">메뉴숫자</td> -->
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
			<div class="content_layout tabs" style="float: right; width: calc(65% - 10px);">
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
								<tbody id="gridList">
								<tr CGRow="true">
									<td GH="40" GCol="rownum">1</td>
									<td GH="40" GCol="rowCheck"></td>
									<td GH="100" GCol="add,COMPKY,OWNER" style="text-align:center;" validate="required">회사코드</td>
									<td GH="100" GCol="add,DEPT_CD" style="text-align:center;" validate="required">부서코드</td>
									<td GH="140" GCol="add,DEPT_KR_NM">부서명(한글)</td>
									<td GH="100" GCol="add,DEPT_EN_NM">부서명(영어)</td>
									<td GH="100" GCol="add,UP_DEPT_CD,DEPT" style="text-align:center;" validate="required">상위 부서코드</td>
									<td GH="140" GCol="text,UP_DEPT_KR_NM">상위 부서명(한글)</td>
									<td GH="100" GCol="text,UP_DEPT_EN_NM">상위 부서명(영어)</td>
									<td GH="100" GCol="input,DISP_SEQ" GF="N 2">정렬 순서</td>
									<td GH="100" GCol="input,SYNC_SEQNO" GF="N 2">SSO 동기화 차수</td>
									<td GH="120" GCol="select,USE_YN">
											<select name="USE_YN" CommonCombo="USEYN">
												<option value=""></option>사용여부
											</select></td>
									<td GH="140" GCol="text,REGDATE" style="text-align:center;">등록일시</td>
									<td GH="100" GCol="text,REGNM">등록자</td>
									<td GH="140" GCol="text,UPDDATE" style="text-align:center;">수정일시</td>
									<td GH="100" GCol="text,UPDNM">수정자</td>
								</tr>
								</tbody>
							</table>
						</div>
					</div>
					<jsp:include page="/WEB-INF/jsp/common/commonBtnAuth.jsp">
						<jsp:param name="authCd" value="1" />
						<jsp:param name="showAuthCd" value="1,2,3,4,5,6,9,10" />
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