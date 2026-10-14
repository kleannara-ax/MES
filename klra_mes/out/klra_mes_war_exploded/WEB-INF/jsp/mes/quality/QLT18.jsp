<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>선별일지 Master</title>
<%@ include file="/common/include/webdek/head.jsp" %>
<script type="text/javascript" src="/common/js/ezgencontrol.js"></script>
<link rel="stylesheet" type="text/css" href="/common/theme/webdek/css/demo_layout.css">
<%@ include file="/WEB-INF/jsp/common/commonApprvForm.jsp" %>
<script type="text/javascript">
	
	function searchList() {
		console.log("## searchList() START ##");
		loadingOpen();
		if(validate.check("searchArea")){
			var param = new DataMap();
			param.put("SCH_MATNR", $("#SCH_MATNR").val().trim());
			param.put("SCH_MACH_CD", $("#SCH_MACH_CD").val().trim());
			param.put("SCH_PART_DIV", $("#SCH_PART_DIV").val().trim());

			gridList.gridList({
				id : "qlt30List",
				param : param
			});
		}
		loadingClose();
		console.log("## searchList() EMD ##");
	}
	
	function saveData() {
		console.log("## saveData() START ##");
		loadingOpen();

		if (gridList.validationCheck("qlt30List", "all")) {
			var list = gridList.getGridData("qlt30List");
			console.log("## saveData() > list = ", list);

			// GRowState(C / D / U ) 구분 - 2024/05/03 강지선
			if(list.length == 0) {
				commonUtil.msgBox("VALID_M0570"); 	// 수정하신 데이터가 없습니다.
				return;
			} else {
				// 다 건 Insert
				var nCount = 0;		// 초기값
				var json = null;	// 처리 결과 초기값

				for (var i = 0 ; i < list.length ; i++) {
		
					if ((list[i].map.GRowState == 'C') || (list[i].map.GRowState == 'U')) { // CREATE or UPDATE
						console.log("## saveData() > list[" + i + "].map.MATNR = ", list[i].map.MATNR);

						var param = new DataMap();

						var jsonObj = "{";
						jsonObj = jsonObj + "#P_MATNR# : #" + list[i].map.MATNR + "#,"; 
						jsonObj = jsonObj + "#P_MATNR_NM# : #" + list[i].map.MATNR_NM + "#,";  
						jsonObj = jsonObj + "#P_MACH_CD# : #" + list[i].map.MACH_CD + "#,";  
						jsonObj = jsonObj + "#P_PART_DIV# : #" + list[i].map.PART_DIV + "#,";  
						jsonObj = jsonObj + "#P_BS_WGT# : #" + list[i].map.BS_WGT + "#,";  
						jsonObj = jsonObj + "#P_CLSF_STCNT# : #" + list[i].map.CLSF_STCNT + "#,";  
						jsonObj = jsonObj + "#P_CLSF_MCNT# : #" + list[i].map.CLSF_MCNT + "#,";  
						jsonObj = jsonObj + "#P_CLSF_CTCNT# : #" + list[i].map.CLSF_CTCNT + "#,";  
						jsonObj = jsonObj + "#P_CLSF_ROLL_CNT# : #" + list[i].map.CLSF_ROLL_CNT + "#,";  
						jsonObj = jsonObj + "#P_CREATEUSER# : #" + $("#SES_USER_ID").val() + "#,";  
						jsonObj = jsonObj + "#P_UPDATEUSER# : #" + $("#SES_USER_ID").val() + "#,";  
						jsonObj = jsonObj + "#P_RMK1# : ##,";  
						jsonObj = jsonObj + "#P_RMK2# : ##,";  
						jsonObj = jsonObj + "#P_RMK3# : ##";  
						jsonObj = jsonObj + "}";
						// console.log("## saveData() > INSERT > jsonObj = ", jsonObj);
						param.put("P_SEND_PARAM", jsonObj);
						console.log("## saveData() > INSERT > param = ", param);

						json = netUtil.sendData({
							module : "Quality",
							command : "QLT18",
							sendType : "map",
							param : param
						});
						console.log("## saveData() > INSERT > json = ", json);

					} else if (list[i].map.GRowState == 'D') { // DELETE
						var param = new DataMap();

						var jsonObj = "{";
						jsonObj = jsonObj + "#P_MATNR# : #" + list[i].map.MATNR + "#,"; 
						jsonObj = jsonObj + "#P_MATNR_NM# : #" + list[i].map.MATNR_NM + "#,";  
						jsonObj = jsonObj + "#P_MACH_CD# : #" + list[i].map.MACH_CD + "#,";  
						jsonObj = jsonObj + "#P_PART_DIV# : #" + list[i].map.PART_DIV + "#,";  
						jsonObj = jsonObj + "#P_BS_WGT# : #" + list[i].map.BS_WGT + "#,";  
						jsonObj = jsonObj + "#P_CLSF_STCNT# : #" + list[i].map.CLSF_STCNT + "#,";  
						jsonObj = jsonObj + "#P_CLSF_MCNT# : #" + list[i].map.CLSF_MCNT + "#,";  
						jsonObj = jsonObj + "#P_CLSF_CTCNT# : #" + list[i].map.CLSF_CTCNT + "#,";  
						jsonObj = jsonObj + "#P_CLSF_ROLL_CNT# : #" + list[i].map.CLSF_ROLL_CNT + "#,";  
						jsonObj = jsonObj + "#P_CREATEUSER# : #" + $("#SES_USER_ID").val() + "#,";  
						jsonObj = jsonObj + "#P_UPDATEUSER# : #" + $("#SES_USER_ID").val() + "#,";  
						jsonObj = jsonObj + "#P_RMK1# : ##,";  
						jsonObj = jsonObj + "#P_RMK2# : ##,";  
						jsonObj = jsonObj + "#P_RMK3# : ##";  
						jsonObj = jsonObj + "}";
						// console.log("## saveData() > INSERT > jsonObj = ", jsonObj);
						param.put("P_SEND_PARAM", jsonObj);
						param.put("MATNR", list[i].map.MATNR);
						console.log("## saveData() > DELETE > param = ", param);

						json = netUtil.sendData({
							module : "Quality",
							command : "QLT18",
							sendType : "delete",
							param : param
						});

					} else {
						json = {
							data : 1
						};
						console.log("## saveData() > ELSE > json = ", json);
					}
				}
				loadingClose();
				commonUtil.msgBox("MASTER_M0564"); 	// 저장 완료되었습니다.

				searchList();
			}
		}

		loadingClose();
		console.log("## saveData() END ##");
	}


	$(document).ready(function(){

		gridList.setGrid({
			id : "qlt30List",
			module : "Quality",
			command : "QLT18"
		});
		
		$("#button-0-1").click(function(event) {
			console.log("## 조회 CLICK ##");
			searchList();
		});

		$("#button-0-2").click(function(event) {
			console.log("## 저장 CLICK ##");
			saveData();
		});

		// 신규 입력한 자재코드 
		 $("td[name='addMATNR']").on('change focus', function() {
			console.log("## Add MATNR = ", $(this).text());
		});

		searchList();
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
					<input type="button" id="button-0-2" CB="Save SAVE BTN_SAVE" />
				</div>
			</div>
			<div class="search_inner">
				<div class="search_wrap ">
					<dl>
						<dt CL="STD_MATNR">자재코드</dt>
						<dd>
							<input type="text" id="SCH_MATNR" name="MATNR" UIInput="S,MATKY" UIFormat="U"/>
						</dd>
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
					<li><a href="#tab1-1"><span CL="STD_GRD_QLT17">자재코드 별 정보</span></a></li>
					<li class="btn_zoom_wrap">
						<ul>
							<li><button class="btn btn_bigger"><span>확대</span></button></li>
						</ul>
					</li>
				</ul>
				<div class="table_box section" id="tab1-1">
					<div class="table_list01">
						<div class="scroll">
							<table class="table_c">
								<tbody id="qlt30List">
									<tr CGRow="true">
										<td GH="50" GCol="rownum">1</td>
										<td GH="50" GCol="rowCheck"></td>
										<td GH="120" GCol="add,MATNR,MATKY" style="text-align:center;" name="addMATNR">자재코드</td>
										<td GH="300" GCol="input,MATNR_NM" style="text-align:left; margin-left: 5px;">자재명</td>
										<td GH="100" GCol="select,MACH_CD" validate="required" style="text-align:center;">
											<select class="input" name="MACH_CD" style="text-align:center;">설비코드
												<option value="">선택</option>
												<option value="TRA03">TRA03</option>
												<option value="TRA04">TRA04</option>
												<option value="TRA05">TRA05</option>
												<option value="TRA06">TRA06</option>
											</select>
										</td>
										<td GH="100" GCol="select,PART_DIV" validate="required" style="text-align:center;">
											<select class="input" name="PART_DIV" style="text-align:center;">품목구분
												<option value="">선택</option>
												<option value="KT">KT</option>
												<option value="RT">RT</option>
											</select>
										</td>
										<td GH="100" GCol="input,BS_WGT" GF="N 10,1" validate="required" style="text-align:center;">평량</td>
										<td GH="100" GCol="input,CLSF_STCNT" GF="N 10" validate="required" style="text-align:center;">겹수</td>
										<td GH="100" GCol="input,CLSF_MCNT" GF="N 10" validate="required" style="text-align:center;">길이/매</td>
										<td GH="100" GCol="input,CLSF_CTCNT" GF="N 10" validate="required" style="text-align:center;">너비</td>
										<td GH="100" GCol="input,CLSF_ROLL_CNT" GF="N 10" validate="required" style="text-align:center;">롤수</td>
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