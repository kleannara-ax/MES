<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%--
 ==============================================================================
  PROGRAM ID   : WRK55
  PROGRAM NAME : 화장지 실적 현황 (모니터링)
  DESCRIPTION  : MES 실적/사용량/폐품/잔량을 개별바코드 단위로 조회하고
                 1) 선행조건  생산량 = 사용량 + 폐품  불일치 시 행 전체 연한 빨간색
                 2) (예정) SAP 데이터 연동 버튼으로 SAP 값과 차이 비교
  URL          : /mes/wrk/WRK55.page
  DATA         : /mes/Work/WRK55/json/datalist.data  →  Work.WRK55_MAP → SP_WRK55_S01 (미작성)
  REVISION
  ---------- ------- ------------------------------------------------------------
  2026/10/15  1.0.0  화면 기본 설계 (DB 미연동, MOCK_MODE 로 레이아웃/판정 확인)
 ==============================================================================

  ■ 그리드 컬럼 정의 (SP_WRK55_S01 결과셋 컬럼명과 동일하게 맞출 것)
  ----------------------------------------------------------------------------
  [판정]   CHK_RSLT        판정 (정상 / 불일치)  ※ 화면에서 계산
           DIFF_QTY        차이 = 생산량 - (사용량 + 폐품)  ※ 화면에서 계산
  [기본]   WERKS, PROC_DIV(A:합지 T:가공 E:예외), MACH_CD, MACHINE, MACH_NM
           PRFM_DT 실적일자, PRD_DT 생산일자, ORDER_NO, WRK_ORDR_NO
           IND_BCD 개별바코드, LOT_NO, MATNR, MATNR_NM, UNIT
  [MES]    PRFM_QTY 생산량   TB_WRK001.PRFM_QTY
           USE_QTY  사용량   TB_INV003.USE_QTY       (확정 필요)
           DISPO_QTY 폐품    TB_WRK004.DISPO_QTY 합계
           RMD_QTY  잔량     TB_INV003.STCK_QTY / TB_IFS012.RSDQTY (확정 필요)
  [I/F]    IF_PRFM_RSLT  실적 전송결과   TB_IFS002/IFS019.ZRESULT
           IF_USE_RSLT   투입 전송결과   TB_IFS008.ZRESULT
           IF_DISPO_RSLT 폐품 전송결과   TB_IFS012.ZRESULT
           IF_MSG        오류 메시지     ZMESSAGE
  [SAP]    SAP_PRFM_QTY, SAP_USE_QTY, SAP_DISPO_QTY, SAP_DIFF_QTY, SAP_CHK_RSLT
           ※ SAP 데이터 연동(B안) 구현 시 채움. 지금은 빈 값.
--%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>MES</title>
<%@ include file="/common/include/webdek/head.jsp" %>
<style type="text/css">
	/* 판정/차이 컬럼 강조 (행 배경색은 공통 gridColorBgRed = #FFCBCB 사용) */
	#gridList td[gcolname="CHK_RSLT"],
	#gridList td[gcolname="DIFF_QTY"] { font-weight: bold; }
	.wrk55_legend { display:inline-block; margin-left:10px; line-height:28px; font-size:12px; }
	.wrk55_legend i { display:inline-block; width:14px; height:14px; margin:0 4px -2px 0; background:#FFCBCB; border:1px solid #e0a0a0; }
</style>
<script type="text/javascript">
	/* ------------------------------------------------------------------
	 * 설정
	 * ------------------------------------------------------------------ */
	// true : DB 미연동 상태에서 샘플 데이터로 화면/판정 확인
	// false: SP_WRK55_S01 연동 후 실제 조회
	var MOCK_MODE = true;

	// 수량 비교 허용오차 (소수점 3자리 기준 반올림 오차 무시)
	var QTY_TOLERANCE = 0.001;

	var CHK_OK = "정상";
	var CHK_NG = "불일치";

	$(document).ready(function() {
		gridList.setGrid({
			id : "gridList",
			url : "/mes/Work/WRK55/json/datalist.data",
			bigdata : false,
			colorType : true,          // 행/컬럼 색상 이벤트 사용
			colHoldType : true,
			colHold : "CHK_RSLT, DIFF_QTY, PRFM_DT, MACHINE, IND_BCD",
			gridScrollType : false
		});
	});

	/* ------------------------------------------------------------------
	 * 조회
	 * ------------------------------------------------------------------ */
	function searchList() {
		if (!validate.check("searchArea")) {
			return;
		}

		var param = inputList.setRangeParam("searchArea");
		param.put("P_TYPE", "LIST");
		param.put("WERKS", "P200");

		// 실적일자 From~To 분리 (WRK53 방식)
		var rangeData = param.get("RANGE_DATA_PARAM");
		if (rangeData && rangeData.get("PRFM_DT_Range")) {
			var dt = rangeData.get("PRFM_DT_Range").split("↓");
			param.put("SDATE", dt[1]);
			param.put("EDATE", dt[2]);
		}
		param.put("PROC_DIV", $("#PROC_DIV").val());
		param.put("CHK_FILTER", $("#CHK_FILTER").val());
		param.put("IF_FILTER", $("#IF_FILTER").val());

		if (MOCK_MODE) {
			bindMockData();
			return;
		}

		gridList.gridList({
			id : "gridList",
			param : param
		});
	}

	/* ------------------------------------------------------------------
	 * 판정 로직 : 생산량 = 사용량 + 폐품
	 * ------------------------------------------------------------------ */
	function toNum(v) {
		if (v === undefined || v === null || v === "") return 0;
		var n = parseFloat(String(v).replace(/,/g, ""));
		return isNaN(n) ? 0 : n;
	}

	function calcDiff(rowData) {
		var prfm  = toNum(rowData.get("PRFM_QTY"));
		var use   = toNum(rowData.get("USE_QTY"));
		var dispo = toNum(rowData.get("DISPO_QTY"));
		return (Math.round((prfm - (use + dispo)) * 1000) / 1000) + 0;   // -0 방지
	}

	function isBalanced(rowData) {
		return Math.abs(calcDiff(rowData)) < QTY_TOLERANCE;
	}

	// 데이터에 판정/차이 컬럼을 채워 넣음 (SP 에서 계산해 내려줘도 화면에서 재계산)
	function applyCheck(list) {
		var result = [];
		var filter = $("#CHK_FILTER").val();
		for (var i = 0; i < list.length; i++) {
			var row = list[i];
			row.put("DIFF_QTY", String(calcDiff(row)));   // 그리드는 숫자 0 을 빈값으로 처리하므로 문자열로
			row.put("CHK_RSLT", isBalanced(row) ? CHK_OK : CHK_NG);

			if (filter === "NG" && row.get("CHK_RSLT") !== CHK_NG) continue;
			if (filter === "OK" && row.get("CHK_RSLT") !== CHK_OK) continue;
			result.push(row);
		}
		return result;
	}

	// 행 배경색 : 불일치 → 연한 빨간색 (configData.GRID_COLOR_BG_RED_CLASS = #FFCBCB)
	function gridListRowBgColorChange(gridId, rowNum, rowData) {
		if (gridId !== "gridList" || !rowData || typeof rowData.get !== "function") {
			return;
		}
		if (!isBalanced(rowData)) {
			return configData.GRID_COLOR_BG_RED_CLASS;
		}
	}

	// I/F 전송결과 오류(E) 셀은 글자 빨간색
	function gridListColTextColorChange(gridId, rowNum, colName, colValue) {
		if (gridId !== "gridList") return;
		if ((colName === "IF_PRFM_RSLT" || colName === "IF_USE_RSLT" || colName === "IF_DISPO_RSLT")
				&& colValue === "E") {
			return configData.GRID_COLOR_TEXT_RED_CLASS;
		}
		if (colName === "CHK_RSLT" && colValue === CHK_NG) {
			return configData.GRID_COLOR_TEXT_RED_CLASS;
		}
	}

	// 실제 조회 완료 후 : 판정 컬럼 계산 → 재바인딩 (행 색상 반영)
	var rebinding = false;
	function gridListEventDataBindEnd(gridId, dataLength) {
		if (gridId !== "gridList" || rebinding || dataLength === 0) return;

		var list = applyCheck(gridList.getGridData(gridId));
		rebinding = true;
		gridList.resetGrid(gridId);
		gridList.setGridData(gridId, list);
		rebinding = false;
		setSummary(list);
	}

	function setSummary(list) {
		var ng = 0;
		for (var i = 0; i < list.length; i++) {
			if (list[i].get("CHK_RSLT") === CHK_NG) ng++;
		}
		$("#SUM_TOTAL").text(list.length);
		$("#SUM_NG").text(ng);
	}

	/* ------------------------------------------------------------------
	 * SAP 데이터 연동 (B안 예정)
	 * ------------------------------------------------------------------ */
	function sapSync() {
		var list = gridList.getGridData("gridList");
		if (!list || list.length === 0) {
			alert("먼저 조회해 주세요.");
			return;
		}
		// TODO(B안): 조회된 오더/LOT/자재/실적일자 키로 SAP RFC 호출
		//   → SAP_PRFM_QTY / SAP_USE_QTY / SAP_DISPO_QTY 채움
		//   → SAP_DIFF_QTY = MES 값 - SAP 값, SAP_CHK_RSLT 판정
		//   예) netUtil.send({ url : "/mes/Work/WRK55/json/sapCompare.data", param : ..., successFunction : ... })
		alert("SAP 데이터 연동 기능은 준비 중입니다.\n(SAP RFC 확정 후 구현 예정)");
	}

	/* ------------------------------------------------------------------
	 * 버튼
	 * ------------------------------------------------------------------ */
	function commonBtnClick(btnName) {
		if (btnName == "Search") {
			var param = new DataMap();
			param.put("PROGID", "<%= menuId%>");
			param.put("LGTYPE", "SEARCH");
			netUtil.sendData({
				url : "/mes/system/json/saveLog.data",
				param : param
			});
			searchList();
		} else if (btnName == "SapSync") {
			sapSync();
		}
	}

	/* ------------------------------------------------------------------
	 * MOCK 데이터 (DB 연동 전 화면 확인용) - MOCK_MODE=false 이면 사용 안 함
	 * ------------------------------------------------------------------ */
	function bindMockData() {
		var src = [
			// PROC_DIV, MACH_CD, MACHINE, MACH_NM, PRFM_DT, IND_BCD, LOT_NO, MATNR, MATNR_NM, UNIT, PRFM, USE, DISPO, RMD, IF실적, IF투입, IF폐품
			["T","TRA01","1호기","가공기 1호기","20261014","T2610140001","2610140001","3100001","화장지 30m 30롤","BOX", 120, 115, 5, 0, "S","S","S"],
			["T","TRA01","1호기","가공기 1호기","20261014","T2610140002","2610140002","3100001","화장지 30m 30롤","BOX", 100,  96, 2, 2, "S","S","S"],
			["T","TRA02","2호기","가공기 2호기","20261014","T2610140003","2610140003","3100002","화장지 27m 24롤","BOX",  80,  80, 0, 0, "S","S",""],
			["A","HAP01","합지1","합지기 1호기","20261014","A2610140001","2610140A01","2100010","합지 원단 3겹","KG", 1500.5, 1480.5, 20, 0, "S","E","S"],
			["E","TPG01","예외1","예외생산","20261014","E2610140001","2610140E01","3100009","화장지 예외","BOX",  10,   7, 1, 2, "","",""]
		];
		var list = [];
		for (var i = 0; i < src.length; i++) {
			var r = src[i], m = new DataMap();
			m.put("WERKS", "P200");          m.put("PROC_DIV", r[0]);
			m.put("MACH_CD", r[1]);          m.put("MACHINE", r[2]);      m.put("MACH_NM", r[3]);
			m.put("PRFM_DT", r[4]);          m.put("PRD_DT", r[4]);
			m.put("ORDER_NO", "10000" + (i + 1)); m.put("WRK_ORDR_NO", "WO" + r[4] + "0" + (i + 1));
			m.put("IND_BCD", r[5]);          m.put("LOT_NO", r[6]);
			m.put("MATNR", r[7]);            m.put("MATNR_NM", r[8]);     m.put("UNIT", r[9]);
			m.put("PRFM_QTY", String(r[10]));  m.put("USE_QTY", String(r[11]));
			m.put("DISPO_QTY", String(r[12])); m.put("RMD_QTY", String(r[13]));
			m.put("IF_PRFM_RSLT", r[14]);    m.put("IF_USE_RSLT", r[15]); m.put("IF_DISPO_RSLT", r[16]);
			m.put("IF_MSG", r[15] === "E" ? "투입량 전송 오류(샘플)" : "");
			list.push(m);
		}
		list = applyCheck(list);
		gridList.resetGrid("gridList");
		gridList.setGridData("gridList", list);
		setSummary(list);
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
					<span class="wrk55_legend"><i></i>생산량 ≠ 사용량 + 폐품</span>
					<span class="wrk55_legend">조회 <b id="SUM_TOTAL">0</b>건 / 불일치 <b id="SUM_NG" style="color:red;">0</b>건</span>
				</div>
				<div class="fl_r">
					<input type="button" id="button-0-1" CB="Search SEARCH BTN_SEARCH" />
					<input type="button" id="button-0-2" CB="SapSync APPLY SAP데이터연동" />
				</div>
			</div>
			<div class="search_inner">
				<div class="search_wrap ">
					<dl>
						<dt CL="STD_PLANT">플랜트</dt>
						<dd>
							<input type="text" class="input" id="WERKS" name="WERKS" value="P200" readonly />
						</dd>
					</dl>
					<dl>
						<dt CL="STD_PRFM_DT">실적일자</dt>
						<dd>
							<input type="text" class="input" id="PRFM_DT" name="PRFM_DT" UIInput="B" UIFormat="C M1" validate="required"/>
						</dd>
					</dl>
					<dl>
						<dt CL="STD_PROC_DIV">공정구분</dt>
						<dd>
							<select class="input" id="PROC_DIV" name="PROC_DIV">
								<option value="">All</option>
								<option value="A">합지기</option>
								<option value="T">가공기</option>
								<option value="E">예외생산</option>
							</select>
						</dd>
					</dl>
					<dl>
						<dt CL="STD_MACH_CD">설비코드</dt>
						<dd>
							<input type="text" class="input" name="MACH_CD" UIInput="SR,MACH" UIFormat="U"/>
						</dd>
					</dl>
					<dl>
						<dt CL="STD_ORDER_NO">오더번호</dt>
						<dd>
							<input type="text" class="input" name="ORDER_NO" UIInput="SR" UIFormat="U"/>
						</dd>
					</dl>
					<dl>
						<dt CL="STD_MATNR">자재코드</dt>
						<dd>
							<input type="text" class="input" name="MATNR" UIInput="SR,MATKY" UIFormat="U"/>
						</dd>
					</dl>
					<dl>
						<dt CL="STD_LOT_NO">LOT번호</dt>
						<dd>
							<input type="text" class="input" name="LOT_NO" UIInput="SR,LOTNO" UIFormat="U"/>
						</dd>
					</dl>
					<dl>
						<dt CL="STD_IND_BCD">개별바코드</dt>
						<dd>
							<input type="text" class="input" name="IND_BCD" UIInput="SR,INDBCD" UIFormat="U"/>
						</dd>
					</dl>
					<dl>
						<dt>판정</dt>
						<dd>
							<select class="input" id="CHK_FILTER" name="CHK_FILTER">
								<option value="">All</option>
								<option value="NG">불일치만</option>
								<option value="OK">정상만</option>
							</select>
						</dd>
					</dl>
					<dl>
						<dt>전송상태</dt>
						<dd>
							<select class="input" id="IF_FILTER" name="IF_FILTER">
								<option value="">All</option>
								<option value="S">성공</option>
								<option value="E">오류</option>
								<option value="N">미전송</option>
							</select>
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
					<li><a href="#tab1-1"><span>화장지 실적 현황</span></a></li>
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
										<!-- 판정 -->
										<td GH="70 판정" GCol="text,CHK_RSLT" style="text-align:center;"></td>
										<td GH="90 차이" GCol="text,DIFF_QTY" GF="N 13,3"></td>
										<!-- 기본 정보 -->
										<td GH="90 실적일자" GCol="text,PRFM_DT" GF="D" style="text-align:center;"></td>
										<td GH="90 생산일자" GCol="text,PRD_DT" GF="D" style="text-align:center;"></td>
										<td GH="0" GCol="text,WERKS"></td>
										<td GH="0" GCol="text,PROC_DIV"></td>
										<td GH="0" GCol="text,MACH_CD"></td>
										<td GH="80 생산호기" GCol="text,MACHINE" style="text-align:center;"></td>
										<td GH="120 설비명" GCol="text,MACH_NM"></td>
										<td GH="100 오더번호" GCol="text,ORDER_NO" style="text-align:center;"></td>
										<td GH="130 작업지시번호" GCol="text,WRK_ORDR_NO" style="text-align:center;"></td>
										<td GH="120 개별바코드" GCol="text,IND_BCD" style="text-align:center;"></td>
										<td GH="110 LOT번호" GCol="text,LOT_NO" style="text-align:center;"></td>
										<td GH="100 자재코드" GCol="text,MATNR" style="text-align:center;"></td>
										<td GH="220 자재명" GCol="text,MATNR_NM"></td>
										<td GH="60 단위" GCol="text,UNIT" style="text-align:center;"></td>
										<!-- MES 수량 -->
										<td GH="100 생산량" GCol="text,PRFM_QTY" GF="N 13,3"></td>
										<td GH="100 사용량" GCol="text,USE_QTY" GF="N 13,3"></td>
										<td GH="100 폐품" GCol="text,DISPO_QTY" GF="N 13,3"></td>
										<td GH="100 잔량" GCol="text,RMD_QTY" GF="N 13,3"></td>
										<!-- I/F 전송 결과 (A안) -->
										<td GH="80 실적전송" GCol="text,IF_PRFM_RSLT" style="text-align:center;"></td>
										<td GH="80 투입전송" GCol="text,IF_USE_RSLT" style="text-align:center;"></td>
										<td GH="80 폐품전송" GCol="text,IF_DISPO_RSLT" style="text-align:center;"></td>
										<td GH="200 전송메시지" GCol="text,IF_MSG"></td>
										<!-- SAP 비교 (B안 예정) -->
										<td GH="100 SAP생산량" GCol="text,SAP_PRFM_QTY" GF="N 13,3"></td>
										<td GH="100 SAP사용량" GCol="text,SAP_USE_QTY" GF="N 13,3"></td>
										<td GH="100 SAP폐품" GCol="text,SAP_DISPO_QTY" GF="N 13,3"></td>
										<td GH="100 SAP차이" GCol="text,SAP_DIFF_QTY" GF="N 13,3"></td>
										<td GH="80 SAP판정" GCol="text,SAP_CHK_RSLT" style="text-align:center;"></td>
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
