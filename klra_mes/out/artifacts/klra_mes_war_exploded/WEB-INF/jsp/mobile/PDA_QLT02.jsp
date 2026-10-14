<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
	String userid = (String)request.getSession().getAttribute(CommonConfig.SES_USER_ID_KEY);
	String username = (String)request.getSession().getAttribute(CommonConfig.SES_USER_NAME_KEY);
	String machCd = (String)request.getSession().getAttribute(CommonConfig.SES_MACH_CD);
	String plant = (String)request.getSession().getAttribute(CommonConfig.SES_USER_PLANT_KEY);

    Object machObj = request.getSession().getAttribute(CommonConfig.SES_MACH_CD);
    if (machObj != null) machCd= (String)machObj;

	String rcvDT = request.getParameter("sendDT");
	String rcvTM = request.getParameter("sendTM");
	String rcvMachCD = request.getParameter("sendMachCD");

%>
<!doctype html>
<head>
    <style type="text/css">
        button {float: right; }
        input:read-only {background-color: #e2e2e2;}
        select:DISABLED {background-color: #e2e2e2;}
    </style>
    <meta charset="utf-8">
    <meta name="viewport" content="user-scalable=yes, initial-scale=1.0, maximum-scale=3.0, minimum-scale=1.0, width=device-width, target-densitydpi=medium-dpi" />
    <meta name="format-detection" content="telephone=no" />
    <title>Mobile MES</title>
    <%@ include file="/mobile/include/head.jsp" %>
    <script>

		function addNewData() { // 신규 Data 추가
			console.log("## addNewData() START ##");

			var sendDT = $("#SCH_INSPR_DT").val();
			console.log("## addNewData() > sendDT = ", sendDT);

			var sendTM = $("#SCH_INSPR_TM").val();
			console.log("## addNewData() > sendTM = ", sendTM);

			var sendMachCD = $("#SCH_MACH_CD").val();
			console.log("## addNewData() > sendMachCD = ", sendMachCD);

			location.href = "/mobile/PDA_QLT02_NEW.page?sendDT=" + sendDT + "&sendTM=" + sendTM + "&sendMachCD=" + sendMachCD;

			console.log("## addNewData() END ##");
		}

		function changeNumber(selType, i) {
			console.log("## changeNumber() START ##");

			var orgNumber = $("#CLSF_RST_VAL_" + i).val();
			console.log("## changeNumber() > orgNumber = ", orgNumber);

			if (selType == 1) { // +1
				if ((orgNumber != null) && (orgNumber != undefined) && (orgNumber != "")) {
					if (Number(orgNumber) < 500) {
						$("#CLSF_RST_VAL_" + i).val(Number(orgNumber) + 1);
					} else {
						$("#CLSF_RST_VAL_" + i).val(orgNumber);
					}
				} else {
					$("#CLSF_RST_VAL_" + i).val(0);
				}
			} else {				// -1
				if ((orgNumber != null) && (orgNumber != undefined) && (orgNumber != "")) {
					if (Number(orgNumber) > 0) {
						$("#CLSF_RST_VAL_" + i).val(Number(orgNumber) - 1);
					} else {
						$("#CLSF_RST_VAL_" + i).val(orgNumber);
					}
				} else {
					$("#CLSF_RST_VAL_" + i).val(0);
				}
			}

			console.log("## changeNumber() END ##");
		}
		

		function searchList() { // Data 조회
			console.log("## searchList() START ##");
			
			// 속도 이슈로 인해 조회 필터 추가 - 2024/06/17 강지선
			if ($("#SCH_INSPR_DT").val() != "") {
				if (($("#SCH_INSPR_DT").val().trim() == null) || ($("#SCH_INSPR_DT").val().trim() == undefined) || ($("#SCH_INSPR_DT").val().trim() == "")) {
					commonUtil.msg("일자를 YYYY-MM-DD 형태로 입력해 주세요.");
					console.log("## SCH_INSPR_DT 없네 ## ");
					return;
				}
			} else {
				commonUtil.msg("일자를 YYYY-MM-DD 형태로 입력해 주세요.");
				console.log("## SCH_INSPR_DT가 이상하네 ## ");
				return;
			}
	
			console.log("## $('#SCH_INSPR_TM').val() = ", $("#SCH_INSPR_TM").val());
			if (($("#SCH_INSPR_TM :selected").val() == null) || ($("#SCH_INSPR_TM :selected").val() == "") || ($("#SCH_INSPR_TM").val() == null) || ($("#SCH_INSPR_TM").val() == "")) {
				commonUtil.msg("작업 시간대를 선택해 주세요.");
				console.log("## SCH_INSPR_TM 없네 ## ");
				$("#ADD_INSPR_TM").focus();
				return false;
			}

			if (($("#SCH_MACH_CD").val() == null) || ($("#SCH_MACH_CD").val() == undefined) || ($("#ADD_MACH_CD").val() == "")) {
				commonUtil.msg("호기를 선택해 주세요.");
				console.log("## SCH_MACH_CD 없네 ## ");
				$("#ADD_MACH_CD").focus();
				return false;
			}			

			$('#resultList').empty();
			$('#resultList').html('<tr><td colspan="16" style="text-align:left; height:80px; padding-left: 150px;" valign="middle">조회된 Data가 없습니다.</td></tr>');	// Initial Data row

			var resultTemp = "";
			loadingOpen();

			var param = new DataMap();
			param.put("SCH_MACH_CD", $("#SCH_MACH_CD").val().trim());
			param.put("SCH_INSPR_DT", $("#SCH_INSPR_DT").val().replace(/\-/g,"").trim());
			param.put("SCH_INSPR_TM", $("#SCH_INSPR_TM").val().trim());
			// param.put("SCH_INSPR_NM", $("#SES_USER_ID").val().trim());
			param.put("SCH_MATNR", $("#SCH_MATNR").val().trim());
			console.log("## searchList() > param = ", param);

			var resultJson = netUtil.sendData({
				module : "Mobile",
				command : "PDA_QLT31",
				sendType : "list",
				param : param
			});
			console.log("## searchList() > resultJson = ", resultJson);

			if (resultJson != null) {
				if ((resultJson.data != null) && (resultJson.data != undefined)) {
					$("#LIST_COUNT").val(resultJson.data.length);	// Hidden LIST_COUNT에 List count 할당

					for (var i = 0 ; i < resultJson.data.length ; i++) {
						var viewINSPR_DT = "";
						if ((resultJson.data[i].INSPR_DT != "") && (resultJson.data[i].INSPR_DT.length > 0)) {
							viewINSPR_DT = resultJson.data[i].INSPR_DT.substr(0, 4) + "-" + resultJson.data[i].INSPR_DT.substr(4, 2) + "-" + resultJson.data[i].INSPR_DT.substr(6, 2);
							$("#ORG_INSPR_DT").val(viewINSPR_DT);
						}

						if ((i > 0) && (i % 36 == 0)) {
							resultTemp = resultTemp + '<tr><td colspan="12" style="height: 1 px;background-color: #BBBBBB;"></td></tr>';
						}
					
						resultTemp = resultTemp + '<tr>';
						resultTemp = resultTemp + '	<td>' + viewINSPR_DT + '';
						resultTemp = resultTemp + '		<input type="hidden" id="INSPR_DT_' + i + '" value="' + viewINSPR_DT + '" name="INSPR_DT_' + i + '"  />';
						resultTemp = resultTemp + '		<input type="hidden" id="INSPR_TM_' + i + '" value="' + resultJson.data[i].INSPR_TM + '" name="INSPR_TM_' + i + '"  />';
						resultTemp = resultTemp + '	</td>';
						
						if (resultJson.data[i].INSPR_TM == "07001500") {
							resultTemp = resultTemp + '	<td>07:00 ~ 15:00</td>';
						} else if (resultJson.data[i].INSPR_TM == "07001900") {
							resultTemp = resultTemp + '	<td>07:00 ~ 19:00</td>';
						} else if (resultJson.data[i].INSPR_TM == "15002300") {
							resultTemp = resultTemp + '	<td>15:00 ~ 23:00</td>';
						} else if (resultJson.data[i].INSPR_TM == "19000700") {
							resultTemp = resultTemp + '	<td>19:00 ~ 07:00</td>';
						} else if (resultJson.data[i].INSPR_TM == "23000700") {
							resultTemp = resultTemp + '	<td>23:00 ~ 07:00</td>';
						}

						resultTemp = resultTemp + '	<td>';
						resultTemp = resultTemp + '		<input type="hidden" id="PART_DIV_' + i + '" value="' + resultJson.data[i].PART_DIV + '" name="PART_DIV_' + i + '"  />';
						resultTemp = resultTemp + '		' + resultJson.data[i].PART_DIV;
						resultTemp = resultTemp + '	</td>';

						resultTemp = resultTemp + '	<td>';
						resultTemp = resultTemp + '		<input type="hidden" id="MACH_CD_' + i + '" value="' + resultJson.data[i].MACH_CD + '" name="MACH_CD_' + i + '"  />';
						resultTemp = resultTemp + '		' + resultJson.data[i].MACH_CD;
						resultTemp = resultTemp + '	</td>';

						resultTemp = resultTemp + '	<td>';
						resultTemp = resultTemp + '		<input type="hidden" id="ARR_MATNR_' + i + '" value="' + resultJson.data[i].MATNR + '" name="MATNR_' + i + '"  />';
						resultTemp = resultTemp + '		' + resultJson.data[i].MATNR;
						resultTemp = resultTemp + '	</td>';
						// resultTemp = resultTemp + '	<td><span id="ARR_MATNR_' + i + '" name="ARR_MATNR_' + i + '" value="' + resultJson.data[i].MATNR + '"</span></td>';

						resultTemp = resultTemp + '	<td>';
						resultTemp = resultTemp + '		<input type="hidden" id="ARR_MATNR_NM_' + i + '" value="' + resultJson.data[i].MATNR_NM + '" name="ARR_MATNR_NM_' + i + '"  />';
						resultTemp = resultTemp + '		' + resultJson.data[i].MATNR_NM;
						resultTemp = resultTemp + '	</td>';
						// resultTemp = resultTemp + '	<td><input type="text" class="text" placeholder="자재명" id="ARR_MATNR_NM_' + i + '" name="ARR_MATNR_NM_' + i + '" value="' + resultJson.data[i].MATNR_NM + '" style="width: 250px; text-align:center;" UIFormat="S 12" readonly="readonly" /></td>';

						resultTemp = resultTemp + '	<td>' + resultJson.data[i].CLSF_LARGE + '</td>';
						resultTemp = resultTemp + '	<td>' + resultJson.data[i].CLSF_SMALL + '</td>';

						resultTemp = resultTemp + ' <td style="text-align:center;">';
						resultTemp = resultTemp + '		<span class="circle-border" onclick="javascript:changeNumber(1,' + i + ')">+</span>';
						resultTemp = resultTemp + '			<select class="selectVal" id="CLSF_RST_VAL_' + i + '" name="CLSF_RST_VAL_' + i + '" >';
						
						for (var j = 0 ; j < 501 ; j++) {
							var nTempVal = resultJson.data[i].CLSF_RST_VAL;
							if ((nTempVal != null) && (nTempVal != undefined) && (nTempVal != "")) {
								if (j == Number(nTempVal)) {
									resultTemp = resultTemp + '			<option value="' + j + '" selected>' + j + '</option>';
								} else {
									resultTemp = resultTemp + '			<option value="' + j + '">' + j + '</option>';
								}
							} else {
								resultTemp = resultTemp + '			<option value="' + j + '">' + j + '</option>';
							}
						}

						resultTemp = resultTemp + '			</select>';
						resultTemp = resultTemp + '		<span class="circle-border" onclick="javascript:changeNumber(0, ' + i + ')">-</span>';
						resultTemp = resultTemp + '		<input type="hidden" id="CLSF_LARGE_' + i + '" value="' + resultJson.data[i].CLSF_LARGE + '" />';
						resultTemp = resultTemp + '		<input type="hidden" id="CLSF_SMALL_' + i + '" value="' + resultJson.data[i].CLSF_SMALL + '" />';
						resultTemp = resultTemp + '	</td>';

						if (resultJson.data[i].INSTD_CFG == "Y") {
							resultTemp = resultTemp + '	<td>' + resultJson.data[i].INSPR_NM + '(대근)';
							resultTemp = resultTemp + '	<input type="hidden" id="INSTD_CFG_' + i + '" value="' + resultJson.data[i].INSTD_CFG + '" />';
							resultTemp = resultTemp + '	<input type="hidden" id="INSPR_NM_' + i + '" value="' + resultJson.data[i].INSPR_NM + '" />';
							resultTemp = resultTemp + '	</td>';
						} else {
							resultTemp = resultTemp + '	<td>' + resultJson.data[i].INSPR_NM;
							resultTemp = resultTemp + '	<input type="hidden" id="INSTD_CFG_' + i + '" value="' + resultJson.data[i].INSTD_CFG + '" />';
							resultTemp = resultTemp + '	<input type="hidden" id="INSPR_NM_' + i + '" value="' + resultJson.data[i].INSPR_NM + '" />';
							resultTemp = resultTemp + '	</td>';
						}

						resultTemp = resultTemp + '	<td>' + resultJson.data[i].CLSF_INPUTDT.substr(0, 16) + '</td>';
						resultTemp = resultTemp + '</tr>';
					}
				}
			}

			if (resultTemp != "") {
				$('#resultList').html(resultTemp);
			}
			loadingClose();
			commonUtil.msg("조회가 완료 되었습니다.");
			console.log("## searchList() END ##");
		}

		function upsertData() {
			console.log("## upsertData() START ##");
			

			var cntSmall = $("[id^=CLSF_SMALL_]").length;
			console.log("## upsertData() > cntSmall = ", cntSmall);

			if (cntSmall < 1) {
				commonUtil.msg("저장할 항목이 없습니다.");
				return false;
			}

			var cntRstVal = $("[id^=CLSF_RST_VAL_]").length;
			var totRstVal = 0;											// 저장 값 총 합 - validation 목적
			console.log("## upsertData() > cntRstVal = ", cntRstVal);

			for (var i = 0 ; i < cntRstVal ; i++) {
				totRstVal = totRstVal + Number($("#CLSF_RST_VAL_" + i).val());
			}
			console.log("## upsertData() > totRstVal = ", totRstVal);

			if (totRstVal == 0) {
				commonUtil.msg("결과값을 등록해 주세요.");
				return false;
			}

			loadingOpen();

			var nCount = 0;
			var sendList = []; 			// Update용 초기 Data object
			var json = null;			// Update 결과
			
			var param = new DataMap();
			var jsonObj = "[{";
			$.each($("[id^=CLSF_SMALL]"), function(seq, valueS) {

				jsonObj = jsonObj + "#P_INSPR_DT# : #" + $("#INSPR_DT_" + seq).val().replace(/\-/g,"") + "#,"; 
				jsonObj = jsonObj + "#P_INSPR_TM# : #" + $("#INSPR_TM_" + seq).val() + "#,";  
				jsonObj = jsonObj + "#P_INSPR_NM# : #" + $("#INSPR_NM_" + seq).val() + "#,";  
				jsonObj = jsonObj + "#P_INSTD_CFG# : #" + $("#INSTD_CFG_" + seq).val() + "#,";
				jsonObj = jsonObj + "#P_MARNR# : #" + $("#ARR_MATNR_" + seq).val() + "#,";
				jsonObj = jsonObj + "#P_MACH_CD# : #" + $("#MACH_CD_" + seq).val() + "#,";  
				jsonObj = jsonObj + "#P_PART_DIV# : #" + $("#PART_DIV_" + seq).val() + "#,";  
				jsonObj = jsonObj + "#P_CREATEUSER# : #" + $("#SES_USER_ID").val() + "#,";  
				jsonObj = jsonObj + "#P_UPDATEUSER# : #" + $("#SES_USER_ID").val() + "#,";  
				jsonObj = jsonObj + "#P_RMK1L# : ##,";  
				jsonObj = jsonObj + "#P_RMK2L# : ##,";  
				jsonObj = jsonObj + "#P_RMK3L# : ##,";  
				jsonObj = jsonObj + "#P_CLSF_LARGE# : #" + $("#CLSF_LARGE_" + seq).val() + "#,";  
				jsonObj = jsonObj + "#P_CLSF_SMALL# : #" + $("#CLSF_SMALL_" + seq).val() + "#,";  
				jsonObj = jsonObj + "#P_CLSF_RST_VAL# : #" + String($("#CLSF_RST_VAL_" + seq).val()).trim() + "#,";  
				jsonObj = jsonObj + "#P_RMK1S# : ##,"; 
				jsonObj = jsonObj + "#P_RMK2S# : ##,"; 
				jsonObj = jsonObj + "#P_RMK3S# : ##}"; 
				nCount++;
				console.log("## upsertData() > nCount = ", nCount);

				if (nCount < cntSmall) {
					jsonObj = jsonObj + ",{";
				}
			});
			jsonObj = jsonObj + "]";
			var sendParam = "{#list# : " + jsonObj + "}";

			param.put("P_SEND_PARAM", sendParam);
			console.log("## upsertData() > param = ", param);

			json = netUtil.sendData({
				module : "Mobile",
				command : "PDA_QLT02_S01",
				sendType : "map",
				param : param
			});
			console.log("## upsertData() > json = ", json);

			if ((json != null) && (json != '')) {
				if ((json.map != undefined) && (json.map != '')) {
					if (json.map.P_SUCCESS == "Y") {	// UPSERT
						loadingClose();
						commonUtil.msg("저장이 완료되었습니다.");
						searchList();
					} else {
						loadingClose();
						commonUtil.msg("저장에 실패했습니다.");					
					}
				}
			} else {
				loadingClose();
				commonUtil.msg("저장에 실패했습니다.");
			}
			loadingClose();
			console.log("## upsertData() END ##");
		}

		function closePage() {
			parent.location.reload(true);
		}

		function changeINSPR_DT() {
			console.log("## changeINSPR_DT() START ##");

			var dateRegex = /^\d{4}-\d{2}-\d{2}$/;
			var inputVal = $("#SCH_INSPR_DT").val();
			console.log("## inputVal > ", inputVal);
			
			if (dateRegex.test(inputVal)) {
				var dateParts = inputVal.split('-');
				var year = parseInt(dateParts[0], 10);
				var month = parseInt(dateParts[1], 10);
				var day = parseInt(dateParts[2], 10);
				var date = new Date(year, month - 1, day);

				if (date.getFullYear() === year && date.getMonth() + 1 === month && date.getDate() === day) {

					// D+1까지만 입력 가능 CHECK - 2024/06/18 황인영 책임님 요청, 강지선 작업
					var tmpToday = new Date();			// 오늘 날짜
					var tmpTomorrow = new Date();		// 내일 날짜
					tmpTomorrow.setDate(tmpToday.getDate() + 1);
					console.log("## 정상 > tmpTomorrow = ", tmpTomorrow);

					// 입력 날짜가 내일 이내인지 확인
					if (date > tmpTomorrow) {
						console.log("## 검사 일자가 내일이 아니네 ## ");
						commonUtil.msg("검사 일자는 내일까지의 날짜만 허용됩니다.");

						$("#SCH_INSPR_DT").val("");
						$("#INSPR_DT_0").val($("#ORG_INSPR_DT").val());
						
						return false;
					} else {
						console.log("## 정상 ## ");

						$("input[id^=INSPR_DT_]").val(inputVal);
						$("#ORG_INSPR_DT").val(inputVal);

						return true;
					}
				} else {
					console.log("## 형태가 아님 ## ");
					commonUtil.msg("YYYY-MM-DD 형태로 입력해 주세요.");

					$("#SCH_INSPR_DT").val("");
					$("#INSPR_DT_0").val($("#ORG_INSPR_DT").val());

					return;
				}
			} else {
				console.log("## 실패 ## ");
				commonUtil.msg("YYYY-MM-DD 형태로 입력해 주세요.");
				
				$("#SCH_INSPR_DT").val("");
				$("#INSPR_DT_0").val($("#ORG_INSPR_DT").val());

				return;
			}
			console.log("## changeINSPR_DT() END ##");
		}


		$(document).ready(function() {

			// Querystring 처리 
			var rcvDT = '<%=rcvDT%>'; 
			if ((rcvDT == "") || (rcvDT == null) || (rcvDT == "null")) {
				$("#SCH_INSPR_DT").val("");
			} else {
				$("#SCH_INSPR_DT").val(rcvDT);
			}

			var rcvTM = $("#RCV_INSPR_TM").val();; 
			if (rcvTM == "") {
				$("#SCH_INSPR_TM").val("").prop("selected", true);
			} else if (rcvTM == "07001500") {
				$("#SCH_INSPR_TM").val("07001500").prop("selected", true);
			} else if (rcvTM == "07001900") {
				$("#SCH_INSPR_TM").val("07001900").prop("selected", true);
			} else if (rcvTM == "15002300") {
				$("#SCH_INSPR_TM").val("15002300").prop("selected", true);
			} else if (rcvTM == "19000700") {
				$("#SCH_INSPR_TM").val("19000700").prop("selected", true);
			} else if (rcvTM == "23000700") {
				$("#SCH_INSPR_TM").val("23000700").prop("selected", true);
			}
			
			var rcvMachCD = $("#RCV_MACH_CD").val();
			console.log("## document.ready > rcvMachCD = ", rcvMachCD);

			var selMachCD = $("#SES_MACH_CD").val();
			console.log("## document.ready > selMachCD = ", selMachCD);

			if ((rcvMachCD != "") && (rcvMachCD != null) && (rcvMachCD != "null")) {
				console.log("## document.ready > rcvMachCD HERE = ", rcvMachCD);
				if (rcvMachCD == "TRA02") {
					$("#SCH_MACH_CD").val("TRA02").prop("selected", true);
				} else if (rcvMachCD == "TRA03") {
					$("#SCH_MACH_CD").val("TRA03").prop("selected", true);
				} else if (rcvMachCD == "TRA04") {
					$("#SCH_MACH_CD").val("TRA04").prop("selected", true);
				} else if (rcvMachCD == "TRA05") {
					$("#SCH_MACH_CD").val("TRA05").prop("selected", true);
				} else if (rcvMachCD == "TRA06") {
					$("#SCH_MACH_CD").val("TRA06").prop("selected", true);
				}
			} else {
				console.log("## document.ready > selMachCD HERE = ", selMachCD);
				if (selMachCD == "TRA02") {
					$("#SCH_MACH_CD").val("TRA02").prop("selected", true);
				} else if (selMachCD == "TRA03") {
					$("#SCH_MACH_CD").val("TRA03").prop("selected", true);
				} else if (selMachCD == "TRA04") {
					$("#SCH_MACH_CD").val("TRA04").prop("selected", true);
				} else if (selMachCD == "TRA05") {
					$("#SCH_MACH_CD").val("TRA05").prop("selected", true);
				} else if (selMachCD == "TRA06") {
					$("#SCH_MACH_CD").val("TRA06").prop("selected", true);
				}
			}

			$("#button-0-1").click(function(event) {
				console.log("## 조회 CLICK ##");
				searchList();
			});

			$("#button-0-2").click(function(event) {
				console.log("## 신규 CLICK ##");
				addNewData();
			});

		});
	
    </script>
</head>
<body>
<input type="hidden" id="RCV_MACH_CD" value="<%=rcvMachCD%>" />
<input type="hidden" id="RCV_INSPR_TM" value="<%=rcvTM%>" />

<input type="hidden" id="SES_MACH_CD" value="<%=machCd%>" />
<input type="hidden" id="SES_USER_ID" value="<%=userid%>" />
<input type="hidden" id="SES_USER_NAME" value="<%=username%>" />
<input type="hidden" id="LIST_COUNT" value="0" />
<input type="hidden" id="SEL_ROW_NO" value="0" />
<input type="hidden" id="ORG_INSPR_DT" />

<div class="main_wrap" id="CONTENT_VIEW">
	<div class="main_header">
		<ul>
			<li class="tit" id="title" style="width:100%;">선별일지</li>
		</ul>
	</div>
    <div class="tem4_content">
        <div class="select_box" id="bindArea">
            <div id="searchWrapArea">
				<table class="sch_detail_area">
					<tr style="height: 10px;"><td colspan="5"></td></tr>
					<tr>
						<td style="text-align:right; width: 120px;"><span style="margin-right: 10px;;">일자</span></td>
						<td style="text-align:left; width: 220px;">
							<input type="text" class="text" placeholder="YYYY-MM-DD" style="width: 150px; text-align:center;" id="SCH_INSPR_DT" name="SCH_INSPR_DT" onchange="changeINSPR_DT()" UIFormat="C S" />
						</td>
						<td style="text-align:right; width: 120px;"><span style="margin-right: 10px;;">작업시간대</span></td>
						<td style="text-align:left; width: 220px;">
							<select class="input" style="width: 156px; text-align:center;" id="SCH_INSPR_TM" name="SCH_INSPR_TM">
								<option value="07001500">07:00 ~ 15:00</option>
								<option value="07001900">07:00 ~ 19:00</option>
								<option value="15002300">15:00 ~ 23:00</option>
								<option value="19000700">19:00 ~ 07:00</option>
								<option value="23000700">23:00 ~ 07:00</option>
							</select>
						</td>
						<td style="text-align:center; width: 120px;" rowspan="2">
							<input type="button" id="button-0-1" CB="Search SEARCH BTN_DISPLAY" style=" width: 100px; height: 30px; font-size: 18px; margin-bottom: 5px;" />
							<input type="button" id="button-0-2" cb="New ADD 신규" style=" width: 100px; height: 30px; font-size: 18px; margin-bottom: 5px;" />
						</td>							
					</tr>
					<tr>
						<td style="text-align:right;"><span style="margin-right: 10px;;">호기</span></td>
						<td style="text-align:left;">
							<input type="text" class="text" id="SCH_MACH_CD" name="SCH_MACH_CD" style="width: 150px; text-align:center;" readonly="readonly" />
						</td>
						<td style="text-align:right;"><span style="margin-right: 10px;;">자재코드</span></td>
						<td style="text-align:left;" colspan="2">
							<input type="text" class="text" id="SCH_MATNR" name="SCH_MATNR" style="width: 150px; text-align:center;" UIFormat='S 12'/>
						</td>
					</tr>
					<tr style="height: 10px;"><td colspan="5"></td></tr>
				</table>

	            <div class="tableWrap_search3">
					<div class="tableHeaderIns">
						<table border="1">
							<colgroup>
								<col width="190px" />
								<col width="220px" />
								<col width="90px" />
								<col width="120px" />
								<col width="250px" />
								<col width="320px" />
								<col width="180px" />
								<col width="180px" />
								<col width="220px" />
								<col width="160px" />
								<col width="180px" />
							</colgroup>
							<thead>
								<tr >
									<th style="border: 1px solid black; background-color: #e4eefb;">일자</th>
									<th style="border: 1px solid black; background-color: #e4eefb;">작업시간대</th>
									<th style="border: 1px solid black; background-color: #e4eefb;">품목</th>
									<th style="border: 1px solid black; background-color: #e4eefb;">호기</th>
									<th style="border: 1px solid black; background-color: #e4eefb;">자재코드</th>
									<th style="border: 1px solid black; background-color: #e4eefb;">자재명</th>
									<th style="border: 1px solid black; background-color:#c8eeba; color:#000000; font-weight: bold; text-align:center;">대분류</th>
									<th style="border: 1px solid black; background-color:#c8eeba; color:#000000; font-weight: bold; text-align:center;">소분류</th>
									<th style="border: 1px solid black; background-color:#c8eeba; color:#000000; font-weight: bold; text-align:center;">결과</th>
									<th style="border: 1px solid black; background-color:#c8eeba; color:#000000; font-weight: bold; text-align:center;">검사자</th>
									<th style="border: 1px solid black; background-color:#c8eeba; color:#000000; font-weight: bold; text-align:center;">입력일시</th>
								</tr>
							</thead>

							<tbody id="resultList">

							</tbody>

						</table>
					</div>
	        	</div>
            </div>
        </div>

		<br /><br /><br />

        <!-- end table_body -->
        <div class="footer_5" style="position:fixed;">

            <table>
                <tr>
                    <td class="f_1" onclick ="closePage()" style="width:33%"><label CL='BTN_CLOSE'></label></td>
                    <td class="f_1" onclick ="upsertData();" style="width:33%">저장</td>
                </tr>
            </table>
        </div><!-- end footer_5 -->
    </div>
</div>

</body>