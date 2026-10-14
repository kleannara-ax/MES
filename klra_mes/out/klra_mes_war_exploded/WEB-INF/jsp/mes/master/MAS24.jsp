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
		gridList.setGrid({
			id : "gridList",
	    	url : "/mes/Master/MAS24/json/datalist.data",
	    	bigdata : false
	    });
		
		gridList.setGrid({
			id : "gridList2",
	    	url : "/mes/Master/MAS24/json/datalist.data",
	    	bigdata : false,
	    	colHoldType : true,
	    	colHold : "WERKS,CHK_ITEM_CD,CHK_ITEM_NM,BIG_CAT_NM",
	    	selectRowDeleteType : true
	    });
	});
	
	function searchList(){
		if(validate.check("searchArea")){
			var param = inputList.setRangeParam("searchArea");
			
			param.put("P_TYPE", "LIST");
			
			gridList.gridList({
				id : "gridList",
				param : param
			});
			gridList.resetGrid("gridList2");
		}
	}
	
	function searchSubList(headRowNum){
		var MachCd = gridList.getColData("gridList", headRowNum, "MACH_CD");
		var Werks = gridList.getColData("gridList", headRowNum, "WERKS");
		var param = new DataMap();
		
		param.put("P_TYPE", "SUB_LIST");
		param.put("MACH_CD", MachCd);
		param.put("WERKS", Werks);
		
		gridList.gridList({
			id : "gridList2",
			param : param
		});
		
		lastFocusNum = headRowNum;
	}
	
	var lastFocusNum = 0;
	
	function gridListEventRowDblclick(gridId, rowNum){
		if(gridId == "gridList"){
			searchSubList(rowNum);
		}
	}
	
	/* function gridListEventDataBindEnd(gridId, dataLength){
		if(gridId == "gridList" && dataLength > 0){
			searchSubList(lastFocusNum);
		}
	} */
	
	function gridListEventColBtnClick(gridId, rowNum, colName){
		if(gridId = "gridList"){
			if(colName == "CHK_ITEM"){
				var url = "/mes/master/MAS24_POP.page";
				var werks = gridList.getColData("gridList", rowNum, "WERKS");
				
				var param = new DataMap();
				
				param.put("WERKS", werks);
				
				page.linkPopOpen(url, param, "height=500,width=1250");
			}
		}
	}
	
	function linkPopCloseEvent(data){
		var griddata = gridList.getGridData("gridList2");
		var count = gridList.getGridDataCount("gridList2");
		var chkitemcd1 = new Array();
		
		for(var i = 0; i < count; i++){
			chkitemcd1.push(gridList.getColData("gridList2", i, "CHK_ITEM_CD"));	// 기존에 있는 체크항목
		}
		
		for(var i = 0; i < data.length; i++){
			var chkitemcd2 = data[i].get("CHK_ITEM_CD");	// 추가할 체크항목
			
			if(chkitemcd1.indexOf(chkitemcd2) < 0){
				gridList.addNewRow("gridList2", data[i]);
			}
		}
	}
	
	function saveData(){
		if(gridList.getModifyRowCount("gridList2") == 0){
			commonUtil.msgBox("MASTER_M0545");
			
			return;
		}
		
		if(!commonUtil.msgConfirm(configData.MSG_MASTER_SAVE_CONFIRM)){
			return;
		}
		if(gridList.validationCheck("gridList2", "all")){
			var rowData = gridList.getRowData("gridList", gridList.getFocusRowNum("gridList"));
			var list = gridList.getModifyList("gridList2", "A");
			var param = new DataMap();
			
			param.put("P_TYPE","SUB_SAVE");
			param.put("head", rowData);
			param.put("list", list);
			
			netUtil.send({
				url : "/mes/Master/MAS24/json/datalist.data",
				param : param,
				successFunction : "savesuccessCallBack"
			});
		}
	}
	
	function savesuccessCallBack(json){
		if(json && json.data){
			commonUtil.msgBox(configData.MSG_SYSTEM_SAVEOK);
			
			gridList.resetGrid("gridList2");
			
			searchList();
		}
	}
	
	function commonBtnClick(btnName){
		if(btnName == "Search"){
			var param = new DataMap();
	        param.put("PROGID", "<%= menuId%>");
	        param.put("LGTYPE", "SEARCH");
	        var json = netUtil.sendData({
	            url: "/mes/system/json/saveLog.data",
	            param : param
	        });
			
			searchList();
		}else if(btnName == "Save"){
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
						<dt CL="STD_PLANT">플랜트</dt>
						<dd>
							<input type="text" class="input" name="WERKS" validate="required" UIInput="S,PLANT" UIFormat="U"/>
						</dd>
					</dl>
					
					<dl>
						<dt CL="STD_PROC_CD">공정</dt>
						<dd>
							<input type="text" class="input" name="M012.PROC_CD" UIInput="SR,OP" UIFormat="U"/>
						</dd>
					</dl>
					
					<dl>
						<dt CL="STD_MACH_CD">설비코드</dt>
						<dd>
							<input type="text" class="input" name="M012.MACH_CD" UIInput="SR,MACH" UIFormat="U"/>
						</dd>
					</dl>
					
				</div>
				<div class="btn_tab">
					<input type="button" class="btn_more" value="more" onclick="searchMore()"/>
				</div>
			</div>
		</div>
        <div class="content-horizontal-wrap" style="height: calc(100% - 95px);">
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
								<tbody id="gridList">
									<tr CGRow="true">
										<td GH="40" GCol="rownum">1</td>
										<td GH="100" GCol="text,WERKS" style="text-align:center;">플랜트코드</td>
										<td GH="100" GCol="text,MACH_CD" style="text-align:center;">설비코드</td>
										<td GH="160" GCol="text,MACH_NM">설비명</td>
										<td GH="80" GCol="btn,CHK_ITEM" GB="Add ADD BTN_ADDROW"></td>	<!-- 체크항목추가 -->
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
								<tbody id="gridList2">
									<tr CGRow="true">
										<td GH="40" GCol="rownum">1</td>
										<td GH="40" GCol="rowCheck"></td>
										<td GH="100" GCol="text,WERKS" style="text-align:center;">플랜트코드</td>
										<td GH="100" GCol="text,CHK_ITEM_CD" style="text-align:center;">공정체크항목코드</td>
										<td GH="140" GCol="text,CHK_ITEM_NM">공정체크항목명</td>
										<td gh="0" GCol="text,MID_CAT_NM">중분류명</td> 
										<td GH="100" GCol="text,BIG_CAT_NM">대분류명</td>
										<td GH="0" GCol="text,INPT_DIV">입력구분</td>
										<td GH="100" GCol="text,INPT_DIV_NM">입력구분(명)</td>
										<td GH="0" GCol="text,MSRM_CYC">측정주기</td>
										<td GH="100" GCol="text,MSRM_CYC_NM">측정주기(명)</td>
										<td GH="0" GCol="text,INPT_TYP">입력타입</td>
										<td GH="100" GCol="text,INPT_TYP_NM">입력타입(명)</td>
										<td GH="0" GCol="text,INPT_MTD">입력방법</td>
										<td GH="100" GCol="text,INPT_MTD_NM">입력방법(명)</td>
										<td GH="100" GCol="text,MSRM_MTD">측정방법</td>
										<td GH="100" GCol="text,MSRM_UNIT">측정단위</td>
										<td GH="100" GCol="input,STD_VAL1" GF="N 13,1">기준값(숫자)</td>
										<td GH="100" GCol="input,STD_VAL2">기준값(문자)</td>
										<td GH="100" GCol="input,UPP_VAL" GF="N 9,2">규격상한치</td>
										<td GH="100" GCol="input,LOW_VAL" GF="N 9,2">규격하한치</td>
										<td GH="100" GCol="text,INSP_STD_1">검사기준1</td>
										<td GH="100" GCol="text,INSP_STD_2">검사기준2</td>
										<td GH="100" GCol="text,USE_YN">사용여부</td>
										<td GH="0" GCol="input,RMK">비고</td>
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
						<jsp:param name="showAuthCd" value="1,2,3,6,9,10" />
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