<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>MES</title>
<%@ include file="/common/include/webdek/head.jsp" %>
<script type="text/javascript">
	$(document).ready(function() {
		gridList.setGrid({
			id : "gridList",
			editable : true,
			module : "Erpif",
			command : "ITFMAGRP",
// 			colHoldType: true,
// 			colHold : "IFID,IFKNM,SYSFR,SYSTO",
			sortType: false,
			bigdata : false,
		});

		searchList();
	});
	
	function searchList(){
		if(validate.check("searchArea")){
			var param = inputList.setRangeParam("searchArea");
			
			param.put("P_TYPE","LIST");
			
			gridList.gridList({
				id : "gridList",
				param : param
			});
		}
	}
	
	function saveData() {
		if(gridList.getModifyRowCount("gridList") == 0 ) {
			commonUtil.msgBox("MASTER_M0545");
			return;
		}
		
		if(!commonUtil.msgConfirm(configData.MSG_MASTER_SAVE_CONFIRM)) return;
		
		if(gridList.validationCheck("gridList", "all")) {
			var list = gridList.getGridData("gridList");
			
			var param = new DataMap();
			param.put("list", list);
// 			param.put("P_TYPE","SAVE");
// 			param.put("WERKS", $("#WERKS").val());
			
			var json = netUtil.sendData({
				url : "/common/json/saveITFMAGRP.data",
				param : param
			});
			
			if ( !(json && json.data) && json.data < 0) return;
			commonUtil.msgBox('처리 하였습니다.');
			searchList();
		}
	}
	
	function commonBtnClick(btnName) {
		//commonUtil.debugMsg("commonBtnClick : ", arguments);
		if(btnName == "Search"){
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
						<dt CL="STD_IFGRP_KNM" style="width: 110px;">회사</dt>
						<dd>
							<input type="text" class="input" name="IFGRP_KNM" value=""/>
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
					<li><a href="#tab1-1"><span CL="STD_GENERAL"></span></a></li>
					<li class="btn_zoom_wrap">
						<ul>
							<!-- <li><button class="btn btn_smaller"><span>축소</span></button></li> -->
							<li><button class="btn btn_bigger"><span>확대</span></button></li>
						</ul>
					</li>
				</ul>
				<div class="table_box section" id="tab1-1">
					<div class="table_list01">
						<div class="scroll">
							<table class="table_c">
								<tbody id="gridList">
									<tr CGRow="true">
										<td GH="80" GCol="rownum">1</td>
										<td GH="40" GCol="rowCheck"></td>
										<td GH="90" GCol="input,IFGRP_ID" style="text-align:center;">인터페이스 그룹</td>
										<td GH="120" GCol="input,IFGRP_KNM" style="text-align:left;">인터페이스 그룹명</td>
										<td GH="70" GCol="input,ASYNC_YN" style="text-align:center;">비동기여부</td>
										<td GH="70" GCol="input,PRORTY" style="text-align:right;">우선순위</td>
										<td GH="70" GCol="input,RSTAT" style="text-align:center;">실행상태</td>
										<td GH="130" GCol="text,RN_STR_TM" style="text-align:center;">실행시작시간</td>
										<td GH="130" GCol="text,RN_END_TM" style="text-align:center;">실행종료시간</td>
										<td GH="90" GCol="input,POLLTY" style="text-align:center;">실행주기</td>
										<td GH="130" GCol="input,POLLTM" style="text-align:right;" GF="N 13">실행시간</td>
										<td GH="70" GCol="input,USE_YN" style="text-align:center;">사용여부</td>
										<td GH="0" GCol="input,ORGN_IFGRP_ID" style="text-align:center;">인터페이스 그룹</td>
										<td GH="0" GCol="input,ORGN_IFGRP_KNM" style="text-align:left;">인터페이스 그룹명</td>
										<td GH="0" GCol="input,ORGN_ASYNC_YN" style="text-align:center;">비동기여부</td>
										<td GH="0" GCol="input,ORGN_PRORTY" style="text-align:right;">우선순위</td>
										<td GH="0" GCol="input,ORGN_RSTAT" style="text-align:center;">실행상태</td>
										<td GH="0" GCol="input,ORGN_POLLTY" style="text-align:center;">실행주기</td>
										<td GH="0" GCol="input,ORGN_POLLTM" style="text-align:right;" GF="N 13">실행시간</td>
										<td GH="0" GCol="input,ORGN_USE_YN" style="text-align:center;">사용여부</td>
									</tr>
								</tbody>
							</table>
						</div>
					</div>
					<jsp:include page="/WEB-INF/jsp/common/commonBtnAuth.jsp">
						<jsp:param name="authCd" value="1" />
						<jsp:param name="showAuthCd" value="1,2,4,5,9,10" />
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