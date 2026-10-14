<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>선별일지</title>
<%@ include file="/common/include/webdek/head.jsp" %>
<script type="text/javascript" src="/common/js/ezgencontrol.js"></script>
<link rel="stylesheet" type="text/css" href="/common/theme/webdek/css/demo_layout.css">
<%@ include file="/WEB-INF/jsp/common/commonApprvForm.jsp" %>
<script type="text/javascript">

	function searchList() {
		console.log("## searchList() START ##");
		
		var nCount = 0;

		// 초기화 
		gridList.resetGrid("qlt31List");
		
		loadingOpen();

		// 선별일지 조회
		var range = inputList.setRangeParam("searchArea");
		console.log("## searchList() > range = ", range);

		var range_data_param = range.get("RANGE_DATA_PARAM");
		var msrm_date = range_data_param.get("SCH_INSPR_DT_Range");
		var date = msrm_date.split('↓');
		var sDate = date[1];
		var eDate = date[2];

		var jsonObj = "{";
			// 검색 조건 > 자재코드(MATNR) 여부 확인
			if (($("#SCH_MATNR").val().trim() != "") && ($("#SCH_MATNR").val().trim() != undefined)) {
				jsonObj += "#SCH_MATNR# : #" + $("#SCH_MATNR").val().trim() + "#, ";  
			}
			jsonObj += "#SCH_SDATE# : #" + sDate + "#, ";
			jsonObj += "#SCH_EDATE# : #" + eDate + "#, ";
			jsonObj += "#SCH_INSPR_ID# : #" + $("#SCH_INSPR_ID").val().trim() + "#, ";
			jsonObj += "#SCH_INSPR_TM# : #" + $("#SCH_INSPR_TM").val().trim() + "#, ";
			jsonObj += "#SCH_MACH_CD# : #" + $("#SCH_MACH_CD").val().trim() + "#, ";
			jsonObj += "#SCH_PART_DIV# : #" + $("#SCH_PART_DIV").val().trim() + "#";			
			jsonObj += "}";

		var Qlt031_param = new DataMap();
		Qlt031_param.put("P_TYPE", "LIST");
		Qlt031_param.put("P_SEND_PARAM", jsonObj);
		console.log("## searchList() > Qlt031_param = ", Qlt031_param);

		gridList.gridList({
			id : "qlt31List",
			param : Qlt031_param
		});

		// var result = netUtil.sendData({
		// 	module : "Quality",
		// 	command : "QLT31_SP",
		// 	sendType : "map", 
		// 	param : Qlt031_param
		// });
		// console.log("## searchList() > QLT31_MAP > result = ", result);
		// if ((result != null) && (result != undefined)) {
		// 	if ((result.map != null) && (result.map != undefined)) {
		// 		if ((result.map.P_RS_LIST != null) && (result.map.P_RS_LIST != undefined)) {
		// 			gridList.appendJson('qlt31List', result.map.P_RS_LIST)
		// 		}
		// 	}
		// }
		// loadingClose();
		console.log("## searchList() EMD ##");	
	}

	// function searchList_BACKUP_20240909() {
	// 	console.log("## searchList() START ##");
		
	// 	var nCount = 0;

	// 	// 초기화 
	// 	gridList.resetGrid("qlt31List");
		
	// 	loadingOpen();

	// 	// 선별일지 기록(TB_QLT031) > 자재코드
	// 	var arrPSEQ = netUtil.sendData({
	// 		module : "Quality",
	// 		command : "QLT31_MATNR",
	// 		sendType : "list"
	// 	});
	// 	console.log("## searchList() > QLT31_MATNR > arrPSEQ = ", arrPSEQ);

	// 	if ((arrPSEQ.data != undefined) && (arrPSEQ.data != null)) {
	// 		$.each(arrPSEQ.data, function(index, eachObj) {
	// 			// console.log("## searchList() > QLT31_MATNR > eachObj = ", eachObj);

	// 			if ((eachObj != undefined) && (eachObj != null)) {
	// 				var Qlt031_param = new DataMap();
	// 				// Qlt031_param.put("INSPR_ID", $("#SES_USER_ID").val());
	// 				Qlt031_param.put("QLT31_SEQ", eachObj.SEQ);

	// 				// 검색 조건 > 자재코드(MATNR) 여부 확인
	// 				if (($("#SCH_MATNR").val().trim() != "") && ($("#SCH_MATNR").val().trim() != undefined)) {
	// 					Qlt031_param.put("SCH_MATNR", $("#SCH_MATNR").val().trim());
	// 				}

	// 				var range = inputList.setRangeParam("searchArea");
	// 				// console.log("## searchList() > range = ", range);
	// 				var range_data_param = range.get("RANGE_DATA_PARAM");
	// 				var msrm_date = range_data_param.get("SCH_INSPR_DT_Range");
	// 				var date = msrm_date.split('↓');
	// 				var sDate = date[1];
	// 				var eDate = date[2];
					
	// 				Qlt031_param.put("SCH_SDATE", sDate);
	// 				Qlt031_param.put("SCH_EDATE", eDate);

	// 				// 검색 조건 > 검사자 ID(INSPR_ID) 여부 확인
	// 				if (($("#SCH_INSPR_ID").val().trim() != "") && ($("#SCH_INSPR_ID").val().trim() != undefined)) {
	// 					Qlt031_param.put("SCH_INSPR_ID", $("#SCH_INSPR_ID").val().trim());
	// 				}

	// 				Qlt031_param.put("SCH_INSPR_ID", $("#SCH_INSPR_ID").val().trim());	// 검사자 ID
	// 				Qlt031_param.put("SCH_INSPR_TM", $("#SCH_INSPR_TM").val().trim());	// 검사시간대
	// 				Qlt031_param.put("SCH_MACH_CD", $("#SCH_MACH_CD").val().trim());	// 설비코드
	// 				Qlt031_param.put("SCH_PART_DIV", $("#SCH_PART_DIV").val().trim());	// 품목(KT/RT)

	// 				var arrQlt031 = netUtil.sendData({
	// 					module : "Quality",
	// 					command : "QLT31",
	// 					sendType : "list", 
	// 					param : Qlt031_param
	// 				});
	// 				console.log("## searchList() > QLT31_MATNR > arrQlt031 = ", arrQlt031);

	// 				if ((arrQlt031 != null) && (arrQlt031 != undefined)) {
	// 					if ((arrQlt031.data != null) && (arrQlt031.data != undefined)) {
	// 						nCount = nCount + arrQlt031.data.length;
	// 					}
	// 				}
	// 				gridList.appendJson('qlt31List', arrQlt031)
	// 			}
	// 		});

	// 		if (nCount == 0) {
	// 			commonUtil.msgBox("VALID_M0005"); 	// 조회된 데이터가 없습니다
	// 			loadingClose();
	// 			return;
	// 		}
	// 	} else {
	// 		commonUtil.msgBox("VALID_M0005"); 	// 조회된 데이터가 없습니다
	// 		loadingClose();
	// 		return;			
	// 	}
	// 	// loadingClose();
	// 	console.log("## searchList() EMD ##");
	// }

	function gridListEventDataBindEnd(gridId, dataLength){
		if(gridId == "qlt31List"){
			var list = gridList.getGridData(gridId);

			for(var i = 0; i < list.length; i++){
				if (list[i].get("CLSF_INPUTDT") != "") {
					gridList.setColValue(gridId, i,"CLSF_INPUTDT", list[i].get("CLSF_INPUTDT").substr(0, 16));
				}
				if (list[i].get("CLSF_MODDT") != "") {
					gridList.setColValue(gridId, i,"CLSF_MODDT", list[i].get("CLSF_MODDT").substr(0, 16));
				}
			}
		}
	}

	function commonBtnClick(btnName){
		console.log("## commonBtnClick> btnName = ", btnName);

		if(btnName == "Search"){
			searchList();
		}
	}

	$(document).ready(function(){

		gridList.setGrid({
			id : "qlt31List",
			url : "/mes/Quality/QLT31_SP/json/datalist.data",
			bigdata : false,
			colGroupCols : "MATNR,MATNR_NM,CLSF_LARGE,CLSF_INPUTDT,CLSF_MODDT"
		});

	});

</script>
</head>
<body>
<%@ include file="/common/include/webdek/layout.jsp" %>
<!-- content -->
<div class="content_wrap">
	<div class="content_inner">
		<%@ include file="/common/include/webdek/title.jsp" %>
		<div class="content_serch" id="searchArea">
			<input type="hidden" id="SES_USER_ID" value="<%=userid%>" />
			<div class="btn_wrap">
				<div class="fl_l">
				</div>
				<div class="fl_r">
					<input type="button" id="button-0-1" CB="Search SEARCH BTN_SEARCH" />
				</div>
			</div>
			<div class="search_inner">
				<div class="search_wrap ">		
					<dl>
                        <dt>검사일자</dt>
                        <dd><input type="text" id="SCH_INSPR_DT" name="SCH_INSPR_DT" UIInput="B" UIFORMAT="C M1" validate="required"/></dd>
                    </dl>
					<dl>
                        <dt CL="STD_CLSF_WORKTM">검사시간대</dt>
						<dd>
							<select class="input" id="SCH_INSPR_TM" name="SCH_INSPR_TM">
								<option value="">ALL</option>
								<option value="07001500">07:00 ~ 15:00</option>
								<option value="07001900">07:00 ~ 19:00</option>
								<option value="15002300">15:00 ~ 23:00</option>
								<option value="19000700">19:00 ~ 07:00</option>
								<option value="23000700">23:00 ~ 07:00</option>
							</select>
						</dd>
                    </dl>
					<dl>
                        <dt CL="STD_INSPR_NM">검사자</dt>
                        <dd><input type="text" id="SCH_INSPR_ID" name="SCH_INSPR_ID" UIInput="S,INSPR_ID" UIFormat="U" /></dd>
                    </dl>
					<dl>
                        <dt CL="STD_MATNR">자재코드</dt>
                        <dd><input type="text" id="SCH_MATNR" name="SCH_MATNR" UIInput="S,MATKY" UIFormat="U" /></dd>
                    </dl>
					<dl>
                        <dt CL="STD_MACH_CD">설비코드</dt>
						<dd>
							<select class="input" id="SCH_MACH_CD" name="SCH_MACH_CD">
								<option value="">ALL</option>
								<option value="TRA03">3호기</option>
								<option value="TRA04">4호기</option>
								<option value="TRA05">5호기</option>
								<option value="TRA06">6호기</option>
							</select>
						</dd>
                    </dl>
					<dl>
                        <dt CL="STD_CLSF_ITEMCLS">품목</dt>
						<dd>
							<select class="input" id="SCH_PART_DIV" name="SCH_PART_DIV">
								<option value="">ALL</option>
								<option value="KT">KT</option>
								<option value="RT">RT</option>
							</select>
						</dd>
                    </dl>
				</div>
			</div>
		</div>
        <div class="search_next_wrap">
			<div class="content_layout tabs">
				<ul class="tab tab_style02">
					<li><a href="#tab1-1"><span CL="STD_GRD_QLT12_1">검사 이력</span></a></li>
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

								<tbody id="qlt31List">
									<tr CGRow="true">
										<td GH="90" GCol="text,INSPR_DT" GF="D" style="text-align:center;">일자</td>
										<td GH="100" GCol="text,INSPR_TM" style="text-align:center; font-weight: normal;">검사시간대</td>
										<td GH="100" GCol="text,INSPR_NM" style="text-align:center;">검사자</td>
										<td GH="80" GCol="text,PART_DIV" style="text-align:center;">품목</td>
										<td GH="80" GCol="text,MACH_CD" style="text-align:center;">설비코드</td>
										<td GH="120" GCol="text,MATNR" style="text-align:center;">자재코드</td>
										<td GH="260" GCol="text,MATNR_NM" style="text-align:center;">자재명</td>
										<td GH="80" GCol="text,BS_WGT" GF="N 10,1" style="text-align:center;">평량</td>
										<td GH="80" GCol="text,CLSF_STCNT" GF="N 10" style="text-align:center;">겹수</td>
										<td GH="80" GCol="text,CLSF_MCNT" GF="N 10" style="text-align:center;">길이/매</td>
										<td GH="80" GCol="text,CLSF_CTCNT" GF="N 10" style="text-align:center;">너비</td>
										<td GH="80" GCol="text,CLSF_ROLL_CNT" GF="N 10" style="text-align:center;">롤수</td>
										<td GH="120" GCol="text,CLSF_LARGE" style="text-align:center;">대분류</td>
										<td GH="140" GCol="text,CLSF_SMALL" style="text-align:center;">소분류</td>
										<td GH="100" GCol="text,CLSF_RST_VAL" GF="N 10" style="text-align:center;">data</td>
										<td GH="130" GCol="text,CLSF_INPUTDT" style="text-align:center; font-weight: normal;">최초입력일시</td>
										<td GH="140" GCol="text,CLSF_MODDT" style="text-align:center; font-weight: normal;">수정입력일시</td>
									</tr>
								</tbody>

							</table>
						</div>
					</div>
					<jsp:include page="/WEB-INF/jsp/common/commonBtnAuth.jsp">
						<jsp:param name="authCd" value="1" />
						<jsp:param name="showAuthCd" value="1,2,3,7,9,10" />
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