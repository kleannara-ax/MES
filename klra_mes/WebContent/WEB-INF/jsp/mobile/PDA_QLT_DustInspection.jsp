<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
	String userid = (String)request.getSession().getAttribute(CommonConfig.SES_USER_ID_KEY);
	String username = (String)request.getSession().getAttribute(CommonConfig.SES_USER_NAME_KEY);
//	String machCd = (String)request.getSession().getAttribute(CommonConfig.SES_MACHINE);
	String plant = (String)request.getSession().getAttribute(CommonConfig.SES_USER_PLANT_KEY);

//	Object machObj = request.getSession().getAttribute(CommonConfig.SES_MACHINE);
//	if (machObj != null) machCd= (String)machObj;
%>
<!doctype html>
<head>
	<meta charset="utf-8">
	<meta name="viewport" content="user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, width=device-width, target-densitydpi=medium-dpi" />
	<meta name="format-detection" content="telephone=no" />
	<title>Mobile MES</title>
	<%@ include file="/mobile/include/head.jsp" %>
	<style type="text/css">
		.result-head-row {
			display: flex;
			align-items: center;
			justify-content: space-between;
			padding: 12px 14px 8px;
			background: #fff;
			gap: 12px;
		}

		.result-head {
			padding: 0;
			font-size: 14px;
			font-weight: 700;
			color: #475569;
			background: transparent;
		}

		.result-head-message {
			font-size: 13px;
			font-weight: 600;
			color: #2563eb;
			text-align: right;
			white-space: nowrap;
		}

		.tem4_content {
			background: #f4f7fb;
		}

		.filter-card {
			margin: 10px 12px 14px;
			padding: 14px;
			background: #fff;
			border: 1px solid #e5e7eb;
			border-radius: 14px;
			box-shadow: 0 8px 24px rgba(15, 23, 42, 0.06);
		}

		.filter-title {
			margin-bottom: 10px;
			font-size: 13px;
			font-weight: 700;
			color: #475569;
		}

		.filter-stack {
			display: flex;
			flex-direction: column;
			gap: 10px;
		}

		.field-block {
			display: flex;
			flex-direction: column;
			gap: 6px;
		}

		.field-label {
			font-size: 12px;
			font-weight: 700;
			color: #334155;
		}

		.date-row {
			display: flex;
			/*grid-template-columns: 1fr 12px 1fr;*/
			gap: 8px;
			align-items: center;
		}

		.date-sep {
			text-align: center;
			color: #64748b;
			font-weight: 700;
		}

		.dual-row {
			display: grid;
			grid-template-columns: 1fr 1fr;
			gap: 10px;
		}

		.filter-input,
		.filter-select {
			width: 100%;
			height: 40px;
			box-sizing: border-box;
			border: 1px solid #d6dbe4;
			border-radius: 10px;
			background: #fff;
			padding: 0 12px;
			font-size: 14px;
			color: #0f172a;
		}

		.filter-input:focus,
		.filter-select:focus {
			outline: none;
			border-color: #2563eb;
			box-shadow: 0 0 0 3px rgba(37, 99, 235, 0.12);
		}

		.action-row {
			display: grid;
			grid-template-columns: 1fr 1fr 1fr;
			gap: 8px;
			margin-top: 2px;
		}

		.tem4_content .select_box .action-btn {
			height: 42px !important;
			border-radius: 10px !important;
			font-size: 13px !important;
			font-weight: 700 !important;
			border: 1px solid transparent !important;
			cursor: pointer !important;
			width: 100% !important;
			padding: 0 !important;
		}

		.tem4_content .select_box .action-btn.primary {
			background: #1d4ed8 !important;
			color: #fff !important;
		}

		.tem4_content .select_box .action-btn.outline {
			background: #fff !important;
			color: #1d4ed8 !important;
			border-color: #93c5fd !important;
		}

		.tem4_content .select_box .action-btn.soft {
			background: #e2e8f0 !important;
			color: #334155 !important;
		}

		.result-card {
			margin: 0 12px 76px;
			background: #fff;
			border: 1px solid #e5e7eb;
			border-radius: 14px;
			box-shadow: 0 8px 24px rgba(15, 23, 42, 0.05);
			overflow: hidden;
		}

		.result-head {
			padding: 12px 14px 8px;
			font-size: 14px;
			font-weight: 700;
			color: #475569;
			background: #fff;
		}

		.result-table-wrap {
			overflow-x: auto;
			overflow-y: auto;
			max-height: calc(100vh - 310px);
		}

		.result-table {
			width: 100%;
			min-width: 980px;
			border-collapse: separate;
			border-spacing: 0;
			table-layout: fixed;
		}

		.result-table thead th {
			position: sticky;
			top: 0;
			z-index: 1;
			background: #eaf2fb;
			color: #0f172a;
			font-size: 15px;
			font-weight: 700;
			padding: 12px 8px;
			border-bottom: 1px solid #d8e3f0;
			border-right: 1px solid #d8e3f0;
			text-align: center;
		}

		.result-table thead th:last-child {
			border-right: none;
		}

		.result-table tbody td {
			background: #fff;
			color: #1e293b;
			font-size: 20px;
			padding: 11px 8px;
			border-bottom: 1px solid #eef2f7;
			text-align: center;
			white-space: nowrap;
			overflow: hidden;
			text-overflow: ellipsis;
		}

		.result-table tbody tr.selected td {
			background: #eff6ff;
		}

		.result-table tbody tr:hover td {
			background: #f8fbff;
		}

		.text-left { text-align: left !important; }
		.text-right { text-align: right !important; }

		.result-check {
			width: 22px;
			height: 22px;
		}

		.badge-yn {
			display: inline-flex;
			align-items: center;
			justify-content: center;
			min-width: 30px;
			height: 24px;
			padding: 0 8px;
			border-radius: 999px;
			font-size: 13px;
			font-weight: 700;
		}

		.badge-yn.y {
			background: #dbeafe;
			color: #1d4ed8;
		}

		.badge-yn.n {
			background: #e5e7eb;
			color: #475569;
		}

		#loading {
			display: none;
			position: fixed; /* 전체 화면 고정 */
			z-index: 999999; /* 테이블 sticky th(z-index:1)보다 훨씬 높게 설정 */
			top: 0;
			left: 0;
			width: 100vw;
			height: 100vh;
			background-color: rgba(0, 0, 0, 0.3); /* 배경을 약간 어둡게 해서 로딩 중임을 확실히 표시 */
		}

		/* 기존 .spinner 수정 */
		.spinner {
			position: absolute; /* relative에서 absolute로 변경 */
			top: 50%;
			left: 50%;
			transform: translate(-50%, -50%); /* 정확히 화면 정중앙 배치 */
			margin: 0;

			width: 50px; /* 크기를 조금 키움 */
			height: 50px;
			border-radius: 50%;
			border: 5px solid rgba(255, 255, 255, 0.3);
			border-top-color: #2563eb; /* 버튼 색상과 통일감 있는 파란색 */
			animation: spin 0.8s infinite linear;
		}

		@keyframes spin {
			from { transform: translate(-50%, -50%) rotate(0deg); }
			to { transform: translate(-50%, -50%) rotate(360deg); }
		}

		input:read-only { background-color: #e2e2e2; }
		select:disabled { background-color: #e2e2e2; }
	</style>
	<script>
		$(document).ready(function() {
			console.log("## 지분검사 > ##");

			var nowObj = new Date(); // 오늘 날짜 객체
			var now = nowObj.toISOString().split('T')[0]; // 오늘 (YYYY-MM-DD)

			var prevObj = new Date();
			prevObj.setDate(nowObj.getDate() - 7); // 오늘 날짜에서 7일을 뺌
			var sevenDaysAgo = prevObj.toISOString().split('T')[0]; // 7일 전 (YYYY-MM-DD)

			$("#PRFM_DT_STRT").val(sevenDaysAgo);
			$("#PRFM_DT_END").val(now);
		});

		// 자재코드, 자재명 선택하면 Checkbox CHECK
		function clickRow(selRow) {
			console.log("## clickRow( " + selRow + " ) > START ##");

			// 전체 false로 변경 후 선택한 애만 true - 2024/07/01 강지선 추가
			$("[id^=chkMATNR_]").prop("checked", false);
			$("#chkMATNR_" + selRow).prop("checked", true);

			// 선택된 행의 스타일을 변경
			$("#gridList tr").removeClass("selected");
			$("#chkMATNR_" + selRow).closest("tr").addClass("selected");

			console.log("## clickRow( " + selRow + " ) > END ##");
		}

		function closePage() {
			window.top.menuOpen();
		}

		function search() {
			console.log("## search() START ##");

			$('#resultList').empty();
			$('#resultList').html('<tr><td colspan="16" style="text-align:left; height:80px; padding-left: 150px;" valign="middle">조회된 Data가 없습니다.</td></tr>');

			$("#gridList").html("");

			var param = new DataMap();
			param.put("WERKS", "<%=plant%>");
			param.put("MACHINE", $("#MACHINE").val());
			param.put("DUST_INSP_YN", $("#DUST_INSP_YN").val());
			param.put("PRFM_DT_STRT", $("#PRFM_DT_STRT").val().toString().replace(/-/g, ""));
			param.put("PRFM_DT_END", $("#PRFM_DT_END").val().toString().replace(/-/g, ""));
			param.put("INSP_ITEM_CD", "P1P75");

			console.log("## search() > param = ", param);

			loadingManager.start();

			setTimeout(function () {
				var resultTemp = "";

				try {
					var resultJson = netUtil.sendData({
						url: "/mobile/Mobile/json/findJumboResultForInspection.data",
						param: param
					});

					console.log("## search() > resultJson = ", resultJson);

					if (resultJson != null && resultJson.result != null && resultJson.result != undefined) {
						for (var i = 0; i < resultJson.result.length; i++) {
							var row = resultJson.result[i];
							var inspBadge = row.INSP_YN === "Y"
									? '<span class="badge-yn y">Y</span>'
									: '<span class="badge-yn n">N</span>';

							var dustBadge = row.DUSTDATA === "N"
									? '<span class="badge-yn n">N</span>'
									: '<span class="badge-yn y">' + nvl(row.DUSTDATA) + '</span>';

							resultTemp += '<tr onclick="clickRow(' + i + ')">';
							resultTemp += '  <td><input type="checkbox" class="result-check" id="chkMATNR_' + i + '" value="' + i + '"></td>';
							resultTemp += '  <td id="PRFM_DT_' + i + '">' + formatDate(row.PRFM_DT) + '</td>';
							resultTemp += '  <td id="IND_BCD_' + i + '">' + nvl(row.IND_BCD) + '</td>';
							resultTemp += '  <td id="LOT_NO_' + i + '">' + nvl(row.LOT_NO) + '</td>';
							resultTemp += '  <td id="MATNR_' + i + '">' + nvl(row.MATNR) + '</td>';
							resultTemp += '  <td id="MATNR_NM_' + i + '" style="display: none;">' + nvl(row.MATNR_NM) + '</td>';
							resultTemp += '  <td id="BS_WGT_' + i + '" class="text-right">' + formatNumber(row.BS_WGT) + '</td>';
							resultTemp += '  <td id="WGT_' + i + '" class="text-right">' + formatNumber(row.WGT) + '</td>';
							// resultTemp += '  <td id="INSP_YN_' + i + '">' + inspBadge + '</td>';
							resultTemp += '  <td id="DUSTDATA_' + i + '">' + dustBadge + '</td>';
							resultTemp += '</tr>';
						}
					}

					$("#gridList").html(resultTemp);
					commonUtil.msg("조회가 완료되었습니다.");
				} catch (e) {
					console.log("## search() ERROR ##", e);
					commonUtil.msg("조회 중 오류가 발생했습니다.");
				} finally {
					loadingManager.end();
					console.log("## search() END ##");
				}
			}, 0);
		}


		function goInspection(){
			console.log("## goInspection() START ##");

			var row = getSingleSelectedRow();
			// var targetTab = "inspection";

			if (row == null) {
				commonUtil.msg("검사할 생산실적을 선택해주세요.");
				return;
			}

			// if(row.INSP_YN == "N"){
			// 	commonUtil.msg("지분검사 전, MES 점보롤 검사가 선행되어야 합니다. \n점보롤 검사 여부를 확인해 주세요.");
			// 	return;
			// }

			var url = "https://aiplatform.kleannara.com/ps-insp/page"
					// + "?tab="		+ targetTab
					+ "?IND_BCD="	+ encodeURIComponent(row.IND_BCD)
					+ "&LOT_NO="	+ encodeURIComponent(row.LOT_NO)
					+ "&MATNR="		+ encodeURIComponent(row.MATNR)
					+ "&MATNR_NM="	+ encodeURIComponent(row.MATNR_NM)
					+ "&USERID="	+ encodeURIComponent(row.USERID)
					+ "&USERNM="	+ encodeURIComponent(row.USERNM);

			window.open(url, "_blank");

			console.log("## goInspection() END ##");
		}

		function goResult(){
			console.log("## goResult() START ##");

			var row = getSingleSelectedRow();
			var targetTab = "history";

			if (row == null) {
				commonUtil.msg("검사결과 확인 할 생산실적을 선택해주세요.");
				return;
			}

			var url = "https://aiplatform.kleannara.com/ps-insp/page"
					+ "?tab="		+ targetTab
					+ "&IND_BCD="	+ encodeURIComponent(row.IND_BCD)
					+ "&USERID="	+ encodeURIComponent(row.USERID);

			window.open(url, "_blank");

			console.log("## goResult() END ##");
		}

		function getSingleSelectedRow() {
			console.log("## getSingleSelectedRow() START ##");
			var cnt = $("[id^=chkMATNR_]").length;
			var selectedIndex = -1;
			var checkedCount = 0;

			for (var i = 0; i < cnt; i++) {
				if ($("#chkMATNR_" + i).prop("checked") === true) {
					checkedCount++;
					selectedIndex = i;
				}
			}

			if (checkedCount === 0) {
				commonUtil.msg("대상을 선택해주세요.");
				return null;
			}

			if (checkedCount > 1) {
				commonUtil.msg("하나의 생산실적만 선택해주세요.");
				return null;
			}

			for (var i = 0; i < cnt; i++) {
				if ($("#chkMATNR_" + i).prop("checked")) {
					return {
						IND_BCD  : $("#IND_BCD_" + i).text(),
						LOT_NO   : $("#LOT_NO_" + i).text(),
						MATNR    : $("#MATNR_" + i).text(),
						MATNR_NM : $("#MATNR_NM_" + i).text(),
						USERID	 : $("#SES_USER_ID").val(),
						USERNM	 : $("#SES_USER_NM").val(),
						INSP_YN	 : $("#INSP_YN_" + i + " span").text(),
					};
				}
			}
			console.log("## getSingleSelectedRow() END ##");
		}

		function nvl(val) {
			if (val == null || val == undefined) {
				return "";
			}
			return String(val);
		}

		function formatNumber(val) {
			if (val == null || val == undefined || val === "") {
				return "";
			}

			var num = Number(val);
			if (isNaN(num)) {
				return val;
			}

			return num.toLocaleString(undefined, {
				minimumFractionDigits: 3,
				maximumFractionDigits: 3
			});
		}

		function formatDate(val) {
			if (val == null || val == undefined || val === "") {
				return "";
			}

			var str = String(val).replace(/[^0-9]/g, "");
			if (str.length !== 8) {
				return val;
			}

			return str.substring(0, 4) + "-" + str.substring(4, 6) + "-" + str.substring(6, 8);
		}

		const loadingManager = {
			start: () => {
				const el = document.querySelector('#loading');
				if(el) el.style.display = 'block';
			},
			end: () => {
				const el = document.querySelector('#loading');
				if(el) el.style.display = 'none';
			},
		}
	</script>
</head>
<body>
	<div id="loading">
		<div class="spinner"></div>
	</div>
	<input type="hidden" id="SES_USER_ID" value="<%=userid%>"/>
	<input type="hidden" id="SES_USER_NM" value="<%=username%>"/>

	<div class="main_wrap" id="CONTENT_VIEW">
		<div class="main_header">
			<ul>
				<li class="tit" id="title" style="width:100%;">지분검사</li>
			</ul>
		</div>
		<div class="tem4_content">
			<div class="select_box" id="bindArea">
				<div id="searchWrapArea">
					<div class="filter-card">
						<div class="filter-title">조회 조건</div>

						<div class="filter-stack">
							<div class="field-block">
								<div class="field-label">실적일자</div>
								<div class="date-row">
									<input type="text" class="filter-input" id="PRFM_DT_STRT" name="PRFM_DT_STRT" placeholder="YYYY-MM-DD" UIFormat="C S" />
									<div class="date-sep">~</div>
									<input type="text" class="filter-input" id="PRFM_DT_END" name="PRFM_DT_END" placeholder="YYYY-MM-DD" UIFormat="C S" />
								</div>
							</div>

							<div class="dual-row">
								<div class="field-block">
									<div class="field-label">생산호기</div>
									<select class="filter-select" id="MACHINE" name="MACHINE">
										<option value="">ALL</option>
										<option value="PM2">PM2</option>
										<option value="PM3">PM3</option>
									</select>
								</div>

								<div class="field-block">
									<div class="field-label">지분검사여부</div>
									<select class="filter-select" id="DUST_INSP_YN" name="DUST_INSP_YN">
										<option value="">ALL</option>
										<option value="Y">Y</option>
										<option value="N">N</option>
									</select>
								</div>
							</div>

							<div class="action-row">
								<button class="action-btn primary" onclick="search();">조회</button>
								<button class="action-btn outline" onclick="goInspection();">검사</button>
								<button class="action-btn soft" onclick="goResult();">결과보기</button>
							</div>
						</div>
					</div>

					<div class="result-card">
						<div class="result-head-row">
							<div class="result-head">생산실적 목록</div>
							<div class="result-head-message" id="inspectionMessage">재검사를 진행하면, 기존에 저장된 값은 삭제되고 새 결과로 변경 저장됩니다.</div>
						</div>

						<div class="result-table-wrap">
							<table class="result-table">
								<colgroup>
									<col style="width:50px;" />
									<col style="width:150px;" />
									<col style="width:150px;" />
									<col style="width:150px;" />
									<col style="width:200px;" />
<%--									<col style="width:0px;" />--%>
									<col style="width:100px;" />
									<col style="width:120px;" />
<%--									<col style="width:100px;" />--%>
									<col style="width:150px;" />
								</colgroup>
								<thead>
								<tr>
									<th>선택</th>
									<th>실적일자</th>
									<th>개별바코드</th>
									<th>LOT_NO</th>
									<th>자재코드</th>
<%--									<th>자재명</th>--%>
									<th>평량</th>
									<th>중량</th>
<%--									<th>점보롤 <br/>검사여부</th>--%>
									<th>지분 검사여부</th>
								</tr>
								</thead>
								<tbody id="gridList"></tbody>
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
						<td class="f_1" onclick ="closePage()" style="width:100%"><label CL='BTN_CLOSE'></label></td>
					</tr>
				</table>
			</div><!-- end footer_5 -->
		</div>
	</div>
</body>