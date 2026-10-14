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
    <meta name="viewport" content="user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, width=device-width, target-densitydpi=medium-dpi" />
    <meta name="format-detection" content="telephone=no" />
    <title>Mobile MES</title>
    <%@ include file="/mobile/include/head.jsp" %>
    <script>

		function searchMATNR() {	// 자재코드 검색
			console.log("## searchMATNR() START ##");

			// 자재코드 선택 전 Validation 추가 - 2024/06/11 강지선
			if ($("#ADD_INSPR_DT").val() != "") {
				if (($("#ADD_INSPR_DT").val().trim() == null) || ($("#ADD_INSPR_DT").val().trim() == undefined) || ($("#ADD_INSPR_DT").val().trim() == "")) {
					commonUtil.msg("일자를 YYYY-MM-DD 형태로 입력해 주세요.");
					console.log("## changeNumber() > ADD_INSPR_DT 실패 ## ");
					return;
				}
			} else {
				commonUtil.msg("일자를 YYYY-MM-DD 형태로 입력해 주세요.");
				console.log("## changeNumber() > ADD_INSPR_DT 실패 (2) ## ");
				return;
			}
	
			console.log("## $('#ADD_INSPR_TM').val() = ", $("#ADD_INSPR_TM").val());
			if (($("#ADD_INSPR_TM :selected").val() == null) || ($("#ADD_INSPR_TM :selected").val() == "") || ($("#ADD_INSPR_TM").val() == null) || ($("#ADD_INSPR_DT").val() == "")) {
				commonUtil.msg("작업 시간대를 선택해 주세요.");
				console.log("## changeNumber() > ADD_INSPR_TM 실패 ## ");
				$("#ADD_INSPR_TM").focus();
				return false;
			}

			if (($("#ADD_PART_DIV").val() == null) || ($("#ADD_PART_DIV").val() == undefined) || ($("#ADD_PART_DIV").val() == "")) {
				commonUtil.msg("품목을 선택해 주세요.");
				console.log("## changeNumber() > ADD_PART_DIV 실패 ## ");
				$("#ADD_PART_DIV").focus();
				return false;
			}

			if (($("#ADD_MACH_CD").val() == null) || ($("#ADD_MACH_CD").val() == undefined) || ($("#ADD_MACH_CD").val() == "")) {
				commonUtil.msg("호기를 선택해 주세요.");
				console.log("## changeNumber() > ADD_MACH_CD 실패 ## ");
				$("#ADD_MACH_CD").focus();
				return false;
			}

			loadingOpen();

			$("#MATNR_List").empty();
			$("#MATNR_LAYER").show();
			$("#CONTENT_VIEW").hide();
			
			popupMATNR();

			console.log("## searchMATNR() END ##");
		}

		function hidePopup() {	// 자재코드 검색 Popup
			console.log("## hidePopup() START ##");

			$("#CONTENT_VIEW").show();
			$("#S_MATNR").val("");
			$("#MATNR_LAYER").hide();

			console.log("## hidePopup() END ##");
		}

		function changeNumber(selType, i) {
			// console.log("## changeNumber() START ##");

			// 결과 입력 전 Validation 추가 - 2024/06/10 강지선
			if ($("#ADD_INSPR_DT").val() != "") {
				if (($("#ADD_INSPR_DT").val().trim() == null) || ($("#ADD_INSPR_DT").val().trim() == undefined) || ($("#ADD_INSPR_DT").val().trim() == "")) {
					commonUtil.msg("일자를 YYYY-MM-DD 형태로 입력해 주세요.");
					console.log("## changeNumber() > ADD_INSPR_DT 실패 ## ");
					return;
				}
			} else {
				commonUtil.msg("일자를 YYYY-MM-DD 형태로 입력해 주세요.");
				console.log("## changeNumber() > ADD_INSPR_DT 실패 (2) ## ");
				return;
			}
	
			console.log("## $('#ADD_INSPR_TM').val() = ", $("#ADD_INSPR_TM").val());
			if (($("#ADD_INSPR_TM :selected").val() == null) || ($("#ADD_INSPR_TM :selected").val() == "") || ($("#ADD_INSPR_TM").val() == null) || ($("#ADD_INSPR_DT").val() == "")) {
				commonUtil.msg("작업 시간대를 선택해 주세요.");
				console.log("## changeNumber() > ADD_INSPR_TM 실패 ## ");
				$("#ADD_INSPR_TM").focus();
				return false;
			}

			if (($("#ADD_PART_DIV").val() == null) || ($("#ADD_PART_DIV").val() == undefined) || ($("#ADD_PART_DIV").val() == "")) {
				commonUtil.msg("품목을 선택해 주세요.");
				console.log("## changeNumber() > ADD_PART_DIV 실패 ## ");
				$("#ADD_PART_DIV").focus();
				return false;
			}

			if (($("#ADD_MACH_CD").val() == null) || ($("#ADD_MACH_CD").val() == undefined) || ($("#ADD_MACH_CD").val() == "")) {
				commonUtil.msg("호기를 선택해 주세요.");
				console.log("## changeNumber() > ADD_MACH_CD 실패 ## ");
				$("#ADD_MACH_CD").focus();
				return false;
			}

			console.log("## $('#ADD_MATNR'.val() = ", $("#ADD_MATNR").val());
			if (($("#ADD_MATNR").val() == null) || ($("#ADD_MATNR").val() == undefined) || ($("#ADD_MATNR").val() == "")) {
				commonUtil.msg("자재코드를 선택해 주세요.");
				console.log("## changeNumber() > ADD_MATNR 실패 ## ");
				$("#ADD_MATNR").focus();
				return false;
			}

			var orgNumber = $("#CLSF_RST_VAL_" + i).val();
			// console.log("## changeNumber() > orgNumber = ", orgNumber);

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

			// console.log("## changeNumber() END ##");
		}

		function selectMATNR() {	// 자재코드 검색 Layer에서 선택
			console.log("## selectMATNR() > START ##");

			// 선택한 자재코드 & data setting
			var cntChkMATNR = $("[id^=chkMATNR_]").length;
			console.log("## selectMATNR() > cntChkMATNR = ", cntChkMATNR);

			var cntChecked = 0; 		// Checked Count

			for (var i = 0 ; i < cntChkMATNR ; i++) {
				if ($("#chkMATNR_" + i).prop("checked") == true) {
					cntChecked++;
				}
			}
			if (cntChecked < 1) {
				PlaySound('e');
				commonUtil.msg("자재코드를 선택해 주세요.");
				return;
			} else if(cntChecked > 1){
				PlaySound('e');
				commonUtil.msg("하나의 자재코드만 선택해 주세요.");
       			return;
       		}

			for (var i = 0 ; i < cntChkMATNR ; i++) {
				console.log("## $('#selMATNR_' + i).val() = ", $("#selMATNR_" + i).val());

				if ($("#chkMATNR_" + i).prop("checked") == true) {
					$("#ADD_MATNR").val($("#selMATNR_" + i).val());
					$("#ADD_MATNR_NM").val($("#selMATNR_NM_" + i).val());
					$("#ADD_MACH_CD").val($("#selMACH_CD_" + i).val());
					$("#ADD_PART_DIV").val($("#selPART_DIV_" + i).val());
				}
			}

			// 신규 입력할 row 생성
			//					14			10			3			  2				  4				  1			   1
			//CLSF_TITLE_L : '제품불량', '폴리백불량', '입수불량', '폴리백 인쇄불량', '손잡이테이프', '제조일자 불량', '그 외'];
			var resultTemp = "";

			var chkParam = new DataMap();
			chkParam.put("CHK_MATNR", $("#ADD_MATNR").val());
			chkParam.put("CHK_INSPR_DT", $("#ADD_INSPR_DT").val().replace(/\-/g,""));
			chkParam.put("CHK_INSPR_TM", $("#ADD_INSPR_TM").val());
			chkParam.put("CHK_MACH_CD", $("#ADD_MACH_CD").val());
			chkParam.put("CHK_PART_DIV", $("#ADD_PART_DIV").val());
			console.log("## selectMATNR() > chkParam = ", chkParam);

			// Step 1 - INSPR_DT + INSPR_TM + MACH_CD + MACH_CD + PART_DIV 조건으로 저장 데이터 확인
			var chkData = netUtil.sendData({
				module : "Quality",
				command : "QLT31",
				sendType : "list",
				param : chkParam
			});
			console.log("## selectMATNR() > chkData = ", chkData);

			if ((chkData != null) && (chkData.data != null) && (chkData.data.length > 0)) {
				// 기존 데이터 표시
				for (var i = 0 ; i < chkData.data.length ; i++) {
					resultTemp = resultTemp + '<tr">';

					if (i == 0) {
						resultTemp = resultTemp + '  <td rowspan="15">' + chkData.data[i].CLSF_LARGE + '</td>';
					} else if (i == 15) {
						resultTemp = resultTemp + '  <td rowspan="10">' + chkData.data[i].CLSF_LARGE + '</td>';
					} else if (i == 25) {
						resultTemp = resultTemp + '  <td rowspan="3">' + chkData.data[i].CLSF_LARGE + '</td>';
					} else if (i == 28) {
						resultTemp = resultTemp + '  <td rowspan="2">' + chkData.data[i].CLSF_LARGE + '</td>';
					} else if (i == 30) {
						resultTemp = resultTemp + '  <td rowspan="4">' + chkData.data[i].CLSF_LARGE + '</td>';
					} else if ((i == 34) || (i == 35) || (i == 36))  {
						resultTemp = resultTemp + '  <td>' + chkData.data[i].CLSF_LARGE + '</td>';
					}

					resultTemp = resultTemp + '  <td style="background-color:#FFFFFF;">' + chkData.data[i].CLSF_SMALL;
					resultTemp = resultTemp + '		<input type="hidden" id="CLSF_LARGE_' + i + '" value="' + chkData.data[i].CLSF_LARGE + '" />';
					resultTemp = resultTemp + '		<input type="hidden" id="CLSF_SMALL_' + i + '" value="' + chkData.data[i].CLSF_SMALL + '" />';
					resultTemp = resultTemp + '  </td>';
					resultTemp = resultTemp + '  <td style="text-align:center;">';
					resultTemp = resultTemp + '<span onclick="javascript:changeNumber(1, ' + i + ')">▲</span>&nbsp;';
					resultTemp = resultTemp + '		<select  class="input" style="width: 70px; text-align:center;" id="CLSF_RST_VAL_' + i + '" name="CLSF_RST_VAL_' + i + '" >';
					
					for (var j = 0 ; j < 501 ; j++) {
						if (j == Number(chkData.data[i].CLSF_RST_VAL)) {
							resultTemp = resultTemp + '			<option value="' + j + '" selected>' + j + '</option>';
						} else {
							resultTemp = resultTemp + '			<option value="' + j + '">' + j + '</option>';
						}
					}

					resultTemp = resultTemp + '		</select>';
					resultTemp = resultTemp + '&nbsp;<span onclick="javascript:changeNumber(0, ' + i + ')">▼</span>';
					resultTemp = resultTemp + '  </td>';
					resultTemp = resultTemp + '</tr>';
				}

			} else {	
				// 기존 데이터가 없으니 신규 입력
				var param = new DataMap();
				param.put("MATNR", $("#ADD_MATNR").val());

				var clsfSmallList = netUtil.sendData({
					module : "Mobile",
					command : "PDA_TB_QLT_CLSF",
					sendType : "list",
					param : param
				});
				console.log("## selectMATNR() > clsfSmallList = ", clsfSmallList);

				if (clsfSmallList != null) {
					if ((clsfSmallList.data != null) && (clsfSmallList.data != undefined)) {

						for (var i = 0 ; i < clsfSmallList.data.length ; i++) {
							resultTemp = resultTemp + '<tr">';

							if (i == 0) {
								resultTemp = resultTemp + '  <td rowspan="15">' + clsfSmallList.data[i].CLSF_TITLE_L + '</td>';
							} else if (i == 15) {
								resultTemp = resultTemp + '  <td rowspan="10">' + clsfSmallList.data[i].CLSF_TITLE_L + '</td>';
							} else if (i == 25) {
								resultTemp = resultTemp + '  <td rowspan="3">' + clsfSmallList.data[i].CLSF_TITLE_L + '</td>';
							} else if (i == 28) {
								resultTemp = resultTemp + '  <td rowspan="2">' + clsfSmallList.data[i].CLSF_TITLE_L + '</td>';
							} else if (i == 30) {
								resultTemp = resultTemp + '  <td rowspan="4">' + clsfSmallList.data[i].CLSF_TITLE_L + '</td>';
							} else if ((i == 34) || (i == 35) || (i == 36))  {
								resultTemp = resultTemp + '  <td>' + clsfSmallList.data[i].CLSF_TITLE_L + '</td>';
							}

							resultTemp = resultTemp + '  <td style="background-color:#FFFFFF;">' + clsfSmallList.data[i].CLSF_TITLE_S;
							resultTemp = resultTemp + '		<input type="hidden" id="CLSF_LARGE_' + i + '" value="' + clsfSmallList.data[i].CLSF_TITLE_L + '" />';
							resultTemp = resultTemp + '		<input type="hidden" id="CLSF_SMALL_' + i + '" value="' + clsfSmallList.data[i].CLSF_TITLE_S + '" />';
							resultTemp = resultTemp + '  </td>';
							resultTemp = resultTemp + '  <td style="text-align:center;">';
							resultTemp = resultTemp + '<span class="circle-border" onclick="javascript:changeNumber(1, ' + i + ')">+</span>&nbsp;';
							resultTemp = resultTemp + '		<select class="selectVal" id="CLSF_RST_VAL_' + i + '" name="CLSF_RST_VAL_' + i + '" >';
							
							for (var j = 0 ; j < 501 ; j++) {
								if (j == Number(clsfSmallList.data[i].CLSF_RST_VAL)) {
									resultTemp = resultTemp + '			<option value="' + j + '" selected>' + j + '</option>';
								} else {
									resultTemp = resultTemp + '			<option value="' + j + '">' + j + '</option>';
								}
							}

							resultTemp = resultTemp + '		</select>';
							resultTemp = resultTemp + '&nbsp;<span class="circle-border" onclick="javascript:changeNumber(0, ' + i + ')">-</span>';
							resultTemp = resultTemp + '  </td>';
							resultTemp = resultTemp + '</tr>';
						}
					}
				}
			}

			if (resultTemp != "") {
				$('#insertList').html(resultTemp);
			}

			// CONTENT_VIEW > mapping 완료 후 layer close
			hidePopup();

			console.log("## selectMATNR() > END ##");
		}

		// 자재코드, 자재명 선택하면 Checkbox CHECK
		function clickRow(selRow) {
			console.log("## clickRow( " + selRow + " ) > START ##");

			// 전체 false로 변경 후 선택한 애만 true - 2024/07/01 강지선 추가
			$("[id^=chkMATNR_]").prop("checked", false);
			$("#chkMATNR_" + selRow).prop("checked", true);

			// 선택된 행의 스타일을 변경
			$(".tem4_content .scrollCSS tr").removeClass("selected");
			$("#chkMATNR_" + selRow).closest("tr").addClass("selected");

			console.log("## clickRow( " + selRow + " ) > END ##");
		}

		function popupMATNR() {
			console.log("## popupMATNR() START ##");

			$('#resultList').empty();
			$('#resultList').html('<tr><td colspan="16" style="text-align:left; height:80px; padding-left: 150px;" valign="middle">조회된 Data가 없습니다.</td></tr>');	// Initial Data row

			var resultTemp = "";
			$("#MATNR_List").html(""); // 초기화

			var param = new DataMap();
			if (($("#ADD_PART_DIV :selected").val() != "") && ($("#ADD_PART_DIV :selected").val() != null)) {
				param.put("SEL_PART_DIV", $("#ADD_PART_DIV :selected").val());
			}
			if (($("#ADD_MACH_CD").val() != "") && ($("#ADD_MACH_CD").val() != null)) {
				param.put("SEL_MACH_CD", $("#ADD_MACH_CD").val());
			}
			console.log("## popupMATNR() > param = ", param);

			var resultJson = netUtil.sendData({
				module : "Quality",
				command : "QLT18",
				sendType : "list",
				param : param
			});
			console.log("## popupMATNR() > resultJson = ", resultJson);

			if (resultJson != null) {
				if ((resultJson.data != null) && (resultJson.data != undefined)) {
					for (var i = 0 ; i < resultJson.data.length ; i++) {
						resultTemp = resultTemp + '<tr class="grsl_ grfo_" style="height: 25px;">';
						resultTemp = resultTemp + '		<td width="10%">';
						resultTemp = resultTemp + '			<input type="checkbox" id="chkMATNR_' + i + '" style="width: 30px; height: 30px;" value="' + i + '">';
						resultTemp = resultTemp + '			<input type="hidden" id="selMATNR_' + i + '" value="' + resultJson.data[i].MATNR + '">';
						resultTemp = resultTemp + '			<input type="hidden" id="selMATNR_NM_' + i + '" value="' + resultJson.data[i].MATNR_NM + '">';
						resultTemp = resultTemp + '			<input type="hidden" id="selMACH_CD_' + i + '" value="' + resultJson.data[i].MACH_CD + '">';
						resultTemp = resultTemp + '			<input type="hidden" id="selPART_DIV_' + i + '" value="' + resultJson.data[i].PART_DIV + '">';
						resultTemp = resultTemp + '		</td>';
						resultTemp = resultTemp + '		<td width="25%" style="text-align:center;" ontouch="clickRow(' + i + ')" onclick="clickRow(' + i + ')">' + resultJson.data[i].MATNR + '</td>';
						resultTemp = resultTemp + '		<td width="65%" style="text-align:left;" ontouch="clickRow(' + i + ')" onclick="clickRow(' + i + ')">' + resultJson.data[i].MATNR_NM + '</td>';
						// resultTemp = resultTemp + '		<td width="7%" style="text-align:center;">' + resultJson.data[i].BS_WGT + '</td>';
						// resultTemp = resultTemp + '		<td width="7%" style="text-align:center;">' + resultJson.data[i].CLSF_STCNT + '</td>';
						// resultTemp = resultTemp + '		<td width="7%" style="text-align:center;">' + resultJson.data[i].CLSF_MCNT + '</td>';
						// resultTemp = resultTemp + '		<td width="7%" style="text-align:center;">' + resultJson.data[i].CLSF_CTCNT + '</td>';
						// resultTemp = resultTemp + '		<td width="7%" style="text-align:center;">' + resultJson.data[i].CLSF_ROLL_CNT + '</td>';
						resultTemp = resultTemp + '</tr>';
					}
				}
			}

			$("#MATNR_List").html(resultTemp);
			loadingClose();
			commonUtil.msg("조회가 완료 되었습니다.");

			console.log("## popupMATNR() END ##");
		}


		function saveData() {
			console.log("## saveData() START ##");
			
			// validation
			if ($("#ADD_INSPR_DT").val() != "") {
				if (($("#ADD_INSPR_DT").val().trim() == null) || ($("#ADD_INSPR_DT").val().trim() == undefined) || ($("#ADD_INSPR_DT").val().trim() == "")) {
					commonUtil.msg("일자를 YYYY-MM-DD 형태로 입력해 주세요.");
					return;
				}
			} else {
				commonUtil.msg("일자를 YYYY-MM-DD 형태로 입력해 주세요.");
				return;
			}
	
			console.log("## $('#ADD_INSPR_TM').val() = ", $("#ADD_INSPR_TM").val());
			if (($("#ADD_INSPR_TM :selected").val() == null) || ($("#ADD_INSPR_TM :selected").val() == "") || ($("#ADD_INSPR_TM").val() == null) || ($("#ADD_INSPR_DT").val() == "")) {
				commonUtil.msg("작업 시간대를 선택해 주세요.");
				$("#ADD_INSPR_TM").focus();
				return false;
			}

			if (($("#ADD_PART_DIV").val() == null) || ($("#ADD_PART_DIV").val() == undefined) || ($("#ADD_PART_DIV").val() == "")) {
				commonUtil.msg("품목을 선택해 주세요.");
				$("#ADD_PART_DIV").focus();
				return false;
			}

			if (($("#ADD_MACH_CD").val() == null) || ($("#ADD_MACH_CD").val() == undefined) || ($("#ADD_MACH_CD").val() == "")) {
				commonUtil.msg("호기를 선택해 주세요.");
				$("#ADD_MACH_CD").focus();
				return false;
			}

			var cfgYN = "N";			// 대근 여부(Y/N)
			if (($("#ADD_INSPR_NM").val() == null) || ($("#ADD_INSPR_NM").val() == undefined) || ($("#ADD_INSPR_NM").val() == "")) {
				commonUtil.msg("검사자를 선택해 주세요.");
				$("#ADD_INSPR_NM").focus();
				return false;
			} else {
				if ($("#ADD_INSPR_NM").val() == "CFG") {	// 대근 선택 > ADD_INSPR_NM_CFG CHECK
					cfgYN = "Y";
					if (($("#ADD_INSPR_NM_CFG").val() == null) || ($("#ADD_INSPR_NM_CFG").val() == undefined) || ($("#ADD_INSPR_NM_CFG").val() == "")) {
						commonUtil.msg("(대근)검사자 이름을 입력해 주세요.");
						$("#ADD_INSPR_NM").focus();
						return false;
					} else {
						console.log("## saveData() > $('#ADD_INSPR_NM_CFG').val().length = ", $("#ADD_INSPR_NM_CFG").val().length);

						if ($("#ADD_INSPR_NM_CFG").val().length < 2) {
							commonUtil.msg("(대근)검사자 이름을 2자 이상 입력해 주세요.");
							$("#ADD_INSPR_NM_CFG").focus();
							return false;
						} else if ($("#ADD_INSPR_NM_CFG").val().length > 30) {
							commonUtil.msg("(대근)검사자 이름을 30자 미만으로 입력해 주세요.");
							$("#ADD_INSPR_NM_CFG").focus();
							return false;
						}
					}
				}
			}

			if (($("#ADD_MATNR").val() == null) || ($("#ADD_MATNR").val() == undefined) || ($("#ADD_MATNR").val() == "")) {
				commonUtil.msg("자재코드를 선택해 주세요.");
				$("#ADD_MATNR").focus();
				return false;
			}

			var cntSmall = $("[id^=CLSF_SMALL_]").length;
			if (cntSmall < 1) {
				commonUtil.msg("저장할 항목이 없습니다.");
				return false;
			}

			var cntRstVal = $("[id^=CLSF_RST_VAL_]").length;
			var totRstVal = 0;											// 저장 값 총 합 - validation 목적

			for (var i = 0 ; i < cntRstVal ; i++) {
				totRstVal = totRstVal + Number($("#CLSF_RST_VAL_" + i).val());
			}

			if (totRstVal == 0) {
				commonUtil.msg("결과값을 등록해 주세요.");
				return false;
			}

			loadingOpen();
			console.log("## saveDat() > cfgYN = ", cfgYN);

			var nCount = 0;
			var json = null;			// UPSERT 결과
			var param = new DataMap();

			var jsonObj = "[{";
			$.each($("[id^=CLSF_SMALL]"), function(seq, valueS) {

				jsonObj = jsonObj + "#P_INSPR_DT# : #" + $("#ADD_INSPR_DT").val().replace(/\-/g,"") + "#,"; 
				jsonObj = jsonObj + "#P_INSPR_TM# : #" + $("#ADD_INSPR_TM").val() + "#,";  

				if (cfgYN == "Y") {
					jsonObj = jsonObj + "#P_INSPR_NM# : #" + $("#ADD_INSPR_NM_CFG").val() + "#,";
					jsonObj = jsonObj + "#P_INSTD_CFG# : #Y#,";
				} else {
					jsonObj = jsonObj + "#P_INSPR_NM# : #" + $("#ADD_INSPR_NM").val() + "#,";
					jsonObj = jsonObj + "#P_INSTD_CFG# : #N#,";
				}

				jsonObj = jsonObj + "#P_MARNR# : #" + $("#ADD_MATNR").val() + "#,";  
				jsonObj = jsonObj + "#P_MACH_CD# : #" + $("#ADD_MACH_CD").val() + "#,";  
				jsonObj = jsonObj + "#P_PART_DIV# : #" + $("#ADD_PART_DIV").val() + "#,";  
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
				// console.log("## saveData() > nCount = ", nCount);

				if (nCount < cntSmall) {
					jsonObj = jsonObj + ",{";
				}
			});
			jsonObj = jsonObj + "]";
			var sendParam = "{#list# : " + jsonObj + "}";

			param.put("P_SEND_PARAM", sendParam);
			console.log("## saveData() > param = ", param);

			json = netUtil.sendData({
				module : "Mobile",
				command : "PDA_QLT02_S01",
				sendType : "map",
				param : param
			});
			console.log("## saveData() > json = ", json);

			if ((json != null) && (json != '')) {
				if ((json.map != undefined) && (json.map != '')) {
					if (json.map.P_SUCCESS == "Y") {
						loadingClose();
						commonUtil.msg("저장이 완료되었습니다.");
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
			console.log("## saveData() END ##");
		}

		function closePage() {
			var sendDT = $("#ADD_INSPR_DT").val();
			console.log("## closePage() > sendDT = ", sendDT);

			var sendTM = $("#ADD_INSPR_TM").val();
			console.log("## closePage() > sendTM = ", sendTM);

			var sendMachCD = $("#ADD_MACH_CD").val();
			console.log("## closePage() > sendMachCD = ", sendMachCD);

			// 창 닫을 때 입력해둔 헤더값 초기화 - 2024/06/11 강지선
			$("#ADD_INSPR_DT").val("");
			$("#ADD_INSPR_TM").val("");
			$("#ADD_PART_DIV").val("");
			$("#ADD_MACH_CD").val("");

			location.href = "/mobile/PDA_QLT02.page?sendDT=" + sendDT + "&sendTM=" + sendTM + "&sendMachCD=" + sendMachCD;
		}

		function changeINSPR_DT() {
			console.log("## changeINSPR_DT() START ##");

			// 신규 입력 시 일자 변경 > 입력 결과값 초기화 - 2024/06/05 PI 김지은 선임 요청, 강지선 작업
			$("[id^=CLSF_RST_VAL_]").val("0");

			var thisSelect = $("#ADD_INSPR_DT").val();
			var dateRegex = /^\d{4}-\d{2}-\d{2}$/;
			
			if (dateRegex.test(thisSelect)) {
				var dateParts = thisSelect.split('-');
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
						commonUtil.msg("검사 일자는 내일까지의 날짜만 허용됩니다.");
						$("#ADD_INSPR_DT").val("");
						console.log("## 실패 ## ");
						return false;
					} else {
						return true;
					}
				} else {
					commonUtil.msg("YYYY-MM-DD 형태로 입력해 주세요.");
					$("#ADD_INSPR_DT").val("");
					console.log("## 실패 ## ");
					return false;
				}
			} else {
				commonUtil.msg("YYYY-MM-DD 형태로 입력해 주세요.");
				$("#ADD_INSPR_DT").val("");
				console.log("## 실패 ## ");
				return false;
			}

			console.log("## changeINSPR_DT() END ##");
		}

		function changeINSPR_TM() {
			console.log("## changeINSPR_TM() START ##");
			console.log("## $($ADD_INSPR_TM).val() = ", $("#ADD_INSPR_TM").val());

			// 신규 입력 시 일자 변경 > 입력 결과값 초기화 - 2024/06/05 PI 김지은 선임 요청, 강지선 작업
			$("[id^=CLSF_RST_VAL_]").val("0");

			console.log("## changeINSPR_TM() END ##");
		}

		function changePART_DIV() {
			console.log("## changePART_DIV() START ##");
			console.log("## $(#ADD_PART_DIV).val() = ", $("#ADD_PART_DIV").val());

			// 품목이 변경되는거면 자재코드 다시 선택 필요 - 2024/06/10 강지선 
			$("#ADD_MATNR").val("");
			$("#ADD_MATNR_NM").val("");

			// 신규 입력 시 일자 변경 > 입력 결과값 초기화 - 2024/06/05 PI 김지은 선임 요청, 강지선 작업
			$("[id^=CLSF_RST_VAL_]").val("0");

			console.log("## changePART_DIV() END ##");
		}

		// 검사자 선택
		function changeINSPR_NM() {
			console.log("## changeINSPR_NM() START ##");
			console.log("## $(#ADD_INSPR_NM).val() = ", $("#ADD_INSPR_NM").val());

			// 대근 선택 시 직접 입력칸 show - 2024/06/26 황인영 책임 요청, 강지선 작업
			if ($("#ADD_INSPR_NM").val() == "CFG") {
				$("#ADD_INSPR_NM_CFG").show();
			} else {
				$("#ADD_INSPR_NM_CFG").hide();
			}

			console.log("## changeINSPR_NM() END ##");
		}

		// 선택한 호기 별 검사자 목록 조회 - 2024/06/26 강지선
		function getInsprUserList(selMachCD) {
			console.log("## getInsprUserList( " + selMachCD + " ) START ##");
			loadingOpen();

			var param = new DataMap();
			param.put("MACH_CD", selMachCD);
			console.log("## getInsprUserList() > param = ", param);

			var userList = netUtil.sendData({
				module : "Mobile",
				command : "PDA_TB_QLT_USER",
				sendType : "list",
				param : param
			});
			console.log("## getInsprUserList() > userList = ", userList);

			if ((userList != null) && (userList.data != null) && (userList.data.length > 0)) {
				// 검사자 option
				for (var i = 0 ; i < userList.data.length ; i++) {
					$("#ADD_INSPR_NM").append(new Option(userList.data[i].INSPR_NM, userList.data[i].INSPR_NM));
				}
			}
			$("#ADD_INSPR_NM").append(new Option("대근(직접입력)", "CFG"));

			loadingClose();
			console.log("## getInsprUserList( " + selMachCD + " ) END ##");
		}

		$(document).ready(function() {

			console.log("## 선별일지 > ADD ##");

			// Querystring 처리 
			var rcvDT = '<%=rcvDT%>'; 
			$("#ADD_INSPR_DT").val(rcvDT);

			var rcvTM = '<%=rcvTM%>'; 
			if (rcvTM == "") {
				$("#ADD_INSPR_TM").val("").prop("selected", true);
			} else if (rcvTM == "07001500") {
				$("#ADD_INSPR_TM").val("07001500").prop("selected", true);
			} else if (rcvTM == "07001900") {
				$("#ADD_INSPR_TM").val("07001900").prop("selected", true);
			} else if (rcvTM == "15002300") {
				$("#ADD_INSPR_TM").val("15002300").prop("selected", true);
			} else if (rcvTM == "19000700") {
				$("#ADD_INSPR_TM").val("19000700").prop("selected", true);
			}

			var rcvMachCD = '<%=rcvMachCD%>';
			var machCd = '<%=machCd%>';

			if ((rcvMachCD == "") || (rcvMachCD == null) || (rcvMachCD == undefined)) {
				$("#ADD_MACH_CD").val(machCd);
				getInsprUserList(machCd);
			} else {
				$("#ADD_MACH_CD").val(rcvMachCD);
				getInsprUserList(rcvMachCD);
			}

		});
	
    </script>
</head>
<body>
<input type="hidden" id="SES_USER_ID" value="<%=userid%>" />
<input type="hidden" id="SES_MACH_CD" value="<%=machCd%>" />

<div class="main_wrap" id="CONTENT_VIEW">
	<div class="main_header">
		<ul>
			<li class="tit" id="title" style="width:100%;">선별일지 추가</li>
		</ul>
	</div>
    <div class="tem4_content">
        <div class="select_box" id="bindArea">
            <div id="searchWrapArea">
				<table class="sch_detail_area">
					<tr style="height: 10px;"><td colspan="6"></td></tr>
					<tr>
						<td style="text-align:right; width: 120px;"><span style="margin-right: 5px;;">일자</span></td>
						<td style="text-align:left; width: 200px;">
							<input type="text" class="text" placeholder="YYYY-MM-DD" style="width: 130px; text-align:center;" id="ADD_INSPR_DT" name="ADD_INSPR_DT" onchange="changeINSPR_DT()" UIFormat="C S" />
						</td>
						<td style="text-align:right; width: 110px;"><span style="margin-right: 5px;;">작업시간대</span></td>
						<td style="text-align:left; width: 160px;">
							<select class="input" style="width: 150px; text-align:center;" id="ADD_INSPR_TM" name="ADD_INSPR_TM" onchange="changeINSPR_TM()">
								<option value="">― 선택 ―</option>
								<option value="07001500">07:00 ~ 15:00</option>
								<option value="07001900">07:00 ~ 19:00</option>
								<option value="15002300">15:00 ~ 23:00</option>
								<option value="19000700">19:00 ~ 07:00</option>
								<option value="23000700">23:00 ~ 07:00</option>
							</select>
						</td>
						<td style="text-align:right; width: 60px;" ><span style="margin-right: 5px;;">품목</span></td>
						<td style="text-align:left;">
							<select class="input" style="width: 100px; text-align:center;" id="ADD_PART_DIV" name="ADD_PART_DIV" onchange="changePART_DIV()">
								<option value="">― 선택 ―</option>
								<option value="KT">KT</option>
								<option value="RT">RT</option>
							</select>
						</td>							
					</tr>
					<tr>
						<td style="text-align:right;"><span style="margin-right: 4px;;">호기</span></td>
						<td style="text-align:left;"><input type="text" class="text" id="ADD_MACH_CD" name="ADD_MACH_CD" style="width: 170px; text-align:center; border: 0px;" readonly="readonly" /></td>
						<td style="text-align:right;"><span style="margin-right: 10px;;">검사자</span></td>
						<td style="text-align:left;" colspan="3">
							<select class="input" style="width: 150px; text-align:center;" id="ADD_INSPR_NM" name="ADD_INSPR_NM" onchange="changeINSPR_NM()">
								<option value="">― 선택 ―</option>
							</select>
							<input type="text" class="text" id="ADD_INSPR_NM_CFG" name="ADD_INSPR_NM_CFG" style="width: 156px; text-align:left; padding-left: 10px; display: none;" maxlength="30"/>
						</td>
					</tr>
					<tr>
						<td style="text-align:right;"><span style="margin-right: 4px;;">자재코드</span></td>
						<td style="text-align:left;"><input type="text" class="text" placeholder="자재코드 선택" id="ADD_MATNR" name="ADD_MATNR" style="width: 170px; text-align:center;" UIFormat="S 12" onclick="searchMATNR();" /></td>
						<td style="text-align:right;"><span style="margin-right: 10px;;">자재명</span></td>
						<td style="text-align:left;" colspan="3">							
							<input type="text" class="text" id="ADD_MATNR_NM" name="ADD_MATNR_NM" style="width: 80%; text-align:left; padding-left: 10px; border: 0px;" readonly="readonly" />
						</td>
					</tr>
					<tr style="height: 10px;"><td colspan="6"></td></tr>
				</table>

	            <div class="tableWrap_search3">
					<div class="tableHeaderIns">
						<table border="1">
							<colgroup>
								<!-- <col width="70px" />
								<col width="70px" />
								<col width="70px" />
								<col width="70px" />
								<col width="70px" /> -->
								<col width="23%" />
								<col width="50%" />
								<col width="27%" />
							</colgroup>
							<thead>
								<tr>
									<!-- <th style="border: 1px solid black; background-color:#b8d2f3; color:#000000; font-weight: bold; text-align:center; width:70px;">평량</span></th>
									<th style="border: 1px solid black; background-color:#b8d2f3; color:#000000; font-weight: bold; text-align:center; width:70px;">겹수</th>
									<th style="border: 1px solid black; background-color:#b8d2f3; color:#000000; font-weight: bold; text-align:center; width:70px;">길이/매</th>
									<th style="border: 1px solid black; background-color:#b8d2f3; color:#000000; font-weight: bold; text-align:center; width:70px;">너비</th>
									<th style="border: 1px solid black; background-color:#b8d2f3; color:#000000; font-weight: bold; text-align:center; width:70px;">롤수</th> -->
									<th style="border: 1px solid black; background-color:#c8eeba; color:#000000; font-weight: bold; text-align:center; width:100px;">대분류</th>
									<th style="border: 1px solid black; background-color:#c8eeba; color:#000000; font-weight: bold; text-align:center; width:100px;">소분류</th>
									<th style="border: 1px solid black; background-color:#c8eeba; color:#000000; font-weight: bold; text-align:center; width:100px;">결과</th>
								</tr>
							</thead>

							<tbody id="insertList">

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
                    <td class="f_1" onclick ="saveData();" style="width:33%">저장</td>
                </tr>
            </table>
        </div><!-- end footer_5 -->
    </div>
</div>

<div class="main_wrap" id="MATNR_LAYER" style="display: none;">
	<div class="main_header">
		<ul>
			<li class="tit" id="title" style="width:100%;">선별일지 자재코드 검색</li>
		</ul>
	</div>
	<div class="tem4_content">
		<div class="tableWrap_search3">
			<div class="scrollCSS">
				<table border="1">
					<colgroup>
						<col width="10%" />
						<col width="25%" />
						<col width="65%" />
						<!-- <col width="7%" />
						<col width="7%" />
						<col width="7%" />
						<col width="7%" />
						<col width="7%" /> -->
					</colgroup>
					<thead>
						<tr>
							<th style="border: 1px solid black;">선택</th>
							<th style="border: 1px solid black;">자재코드</th>
							<th style="border: 1px solid black;">자재명</th>
							<!-- <th style="border: 1px solid black;">평량</th>
							<th style="border: 1px solid black;">겹수</th>
							<th style="border: 1px solid black;">길이/매</th>
							<th style="border: 1px solid black;">너비</th>
							<th style="border: 1px solid black;">롤수</th> -->
						</tr>
					</thead>

					<tbody id="MATNR_List">

					</tbody>
				</table>
			</div>
		</div>
		<br /><br /><br />
		<!-- end table_body -->
		<div class="footer_5" style="position:fixed;">
			<table>
				<tr>
					<td class=f_1 onclick="hidePopup();" style="width: 50%"><label>닫기</label></td>
					<td class=f_1 onclick="selectMATNR();" style="width: 50%;"><label >선택</label></td>
				</tr>
			</table>
		</div>
		<!-- end footer_5 -->
	</div>
</div>

</body>