<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Grid default</title>
<%@ include file="/common/include/webdek/head.jsp" %>
<link rel="stylesheet" type="text/css" href="/common/theme/webdek/css/demo_layout.css">

<script src="/common/js/chart/chartJs/Chart.min.js"></script>
<!-- <script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/2.4.0/Chart.min.js"></script> -->

<script type="text/javascript">
	
	//차트변수
	let chrt1Line, chrt2Line;
	let cnfg_chrt1Line, cnfg_chrt2Line;
	
	let G_chrt1LineDataObj = {}, G_chrt2LineDataObj = {};

	let G_chrtBgColor = [
		 "#3e95cd"
		,"#8e5ea2"
		,"#3cba9f"
		,"#e8c3b9"
		,"#c45850"
		,'rgba(255, 206, 86, 0.2)'
		,'rgba(75, 192, 192, 0.2)'
		,'rgba(153, 102, 255, 0.2)'
		,'rgba(255, 99, 132, 0.2)'
		,'rgba(54, 162, 235, 0.2)'
		,'rgba(255, 99, 132, 1)'
		,'rgba(54, 162, 235, 1)'
		,'rgba(255, 206, 86, 1)'
		,'rgba(75, 192, 192, 1)' 
		,'rgba(153, 102, 255, 1)'
		,'rgba(255, 159, 64, 1)' 
	];

	$(document).ready(function() {
		gridList.setGrid({
			id : "gridList1",
	    	url : "/mes/Spc/SPC01/json/datalist.data",
	    	bigdata : false
	    });
		gridList.setGrid({
	    	id : "gridList2",
	    	url : "/mes/Spc/SPC01/json/datalist.data",
	    	bigdata : false
	    });
		gridList.setGrid({
	    	id : "gridList3",
	    	url : "/mes/Spc/SPC01/json/datalist.data",
	    	bigdata : false
	    });
		
		$('#gridList3_tab1 .tableUtil.tableUtil').hide();
		
		setChrt1Line_spc01();
		setChrt2Line_spc01();
		
		hideOrInit_chrtAll_spc01();
		
	});

	function hideOrInit_chrt_spc01(chrtSlctr, cnfg, chrt) {
		$('#'+chrtSlctr).hide();
		cnfg.data.datasets = [];
		chrt.update();
	}

	function hideOrInit_chrtAll_spc01() {
		hideOrInit_chrt_spc01('chrt1Line', cnfg_chrt1Line, chrt1Line);
		hideOrInit_chrt_spc01('chrt2Line', cnfg_chrt2Line, chrt2Line);
	}

	// 검사항목그룹 셋팅
	function comboEventDataBindeBefore(comboAtt) {
		if(comboAtt == "mes,COMMONCOMBO") {
			var param = new DataMap();
			param.put("CMCDKY", "INSPCAT");
		}
		return param;
	}
	
	function searchList() {
		
		if (!validate.check("searchArea")) return;
			
		let prm = inputList.setRangeParam("searchArea");
		
		let msrmDtArr = inputList.getRangeDataParam().get("MSRM_DATE_Range").split('↓');
		prm.map.MSRM_DATE_ST = msrmDtArr[1];
		prm.map.MSRM_DATE_ED = msrmDtArr[2];
		
		prm.put("P_TYPE", "LIST1");
		gridList.gridList({
				id : 'gridList1',
			param : prm
		});
		
		hideOrInit_chrtAll_spc01();
		gridList.resetGrid("gridList2");
		gridList.resetGrid("gridList3");
		
	}	
	
	function gridListEventRowDblclick(gridId, rowNum) {  // gridList 행 더블 클릭
		
		if (gridId == "gridList3") return;
	
		let prm = inputList.setRangeParam("searchArea");
		
		let msrmDtArr = inputList.getRangeDataParam().get("MSRM_DATE_Range").split('↓');
		prm.map.MSRM_DATE_ST = msrmDtArr[1];
		prm.map.MSRM_DATE_ED = msrmDtArr[2];
		
		let srchGrdId = '';
		
		if (gridId == "gridList1") {
			gridList.resetGrid("gridList3");
			hideOrInit_chrtAll_spc01();
			prm.map.MATNR = gridList.getRowData(gridId, gridList.getFocusRowNum(gridId) ).map.MATNR;
			prm.map.WERKS = gridList.getRowData(gridId, gridList.getFocusRowNum(gridId) ).map.WERKS;
			prm.put("P_TYPE","LIST2");
			srchGrdId = 'gridList2';
		} else if (gridId == "gridList2") {
			prm.map.MATNR = gridList.getRowData(gridId, gridList.getFocusRowNum(gridId) ).map.MATNR;
			prm.map.WERKS = gridList.getRowData(gridId, gridList.getFocusRowNum(gridId) ).map.WERKS;
			prm.map.INSP_ITEM_GRP_CD = gridList.getRowData(gridId, gridList.getFocusRowNum(gridId) ).map.INSP_ITEM_GRP_CD;
			prm.map.INSP_ITEM_CD = gridList.getRowData(gridId, gridList.getFocusRowNum(gridId) ).map.INSP_ITEM_CD;
			prm.put("P_TYPE","LIST3");
			srchGrdId = 'gridList3';
		}
	
	
		gridList.gridList({
			id : srchGrdId,
			param : prm
		});
	
	
		if (gridId != "gridList2") return;
		
			prm.put("P_TYPE","CHRT1");
			netUtil.send({
			   url : "/mes/Spc/SPC01/json/datalist.data",
			   param : prm,
			   successFunction : 'loadChrt1Line'
			});
	
			prm.put("P_TYPE","CHRT2");
			netUtil.send({
			   url : "/mes/Spc/SPC01/json/datalist.data",
			   param : prm,
			   successFunction : 'loadChrt2Line'
			});
	}
	
	function getSettedDatasetOptObj(labelNm) {
		let obj = {fill: false, lineTension: 0, borderWidth: 2};
		let strObj = JSON.stringify(obj);
		let newObj = JSON.parse(strObj);
		newObj.label = labelNm;
		return newObj;
	}
	
	
	function loadChrt1Line(json, status) {
		if (!json || !json.data || json.data.length <= 0) return;
		
		let labelArr = [];
		let X_AVG = getSettedDatasetOptObj('평균(x)');
		let X_UCL = getSettedDatasetOptObj('X-UCL');
		let X_CL = getSettedDatasetOptObj('X-CL');
		let X_LCL = getSettedDatasetOptObj('X-LCL');
		X_AVG.borderColor = '#3e95cd';
		X_AVG.backgroundColor = '#3e95cd';
		X_UCL.borderColor = '#8e5ea2';
		X_UCL.backgroundColor = '#8e5ea2';
		
		X_CL.borderColor = '#3cba9f';
		X_CL.backgroundColor = '#3cba9f';
		
		X_LCL.borderColor = '#e8c3b9';
		X_LCL.backgroundColor = '#e8c3b9';
		
		let xAvgArr = [], xUclArr = [], xClArr = [], xLclArr = [];
		
		$.each(json.data, function(idx, itm) {
			labelArr.push(itm.MSRM_DAY);
			xAvgArr.push(itm.X);
			xUclArr.push(itm.X_UCL);
			xClArr.push(itm.X_CL);
			xLclArr.push(itm.X_LCL);
		});
		
// 		X_CL.borderDash = [20, 30];
		X_CL.borderDash = [10, 10];
		
		X_AVG.data = xAvgArr;
		X_UCL.data = xUclArr;
		X_CL.data = xClArr;
		X_LCL.data = xLclArr;
		
		let datasets = [];
		datasets.push(X_AVG);
		datasets.push(X_UCL);
		datasets.push(X_CL);
		datasets.push(X_LCL);
		
		cnfg_chrt1Line.data.labels = labelArr;
		cnfg_chrt1Line.data.datasets = datasets;
		chrt1Line.update();
		
		$('#chrt1Line').show();
		
	}
	
	function loadChrt2Line(json, status) {
		if (!json || !json.data || json.data.length <= 0) return;
		
		let labelArr = [];
		let R_RNG = getSettedDatasetOptObj('범위(R)');
		let R_UCL = getSettedDatasetOptObj('R-UCL');
		let R_CL = getSettedDatasetOptObj('R-CL');
		let R_LCL = getSettedDatasetOptObj('R-LCL');
		R_RNG.borderColor = '#3e95cd';
		R_RNG.backgroundColor = '#3e95cd';
		R_UCL.borderColor = '#8e5ea2';
		R_UCL.backgroundColor = '#8e5ea2';
		R_CL.borderColor = '#3cba9f';
		R_CL.backgroundColor = '#3cba9f';
		R_LCL.borderColor = '#e8c3b9';
		R_LCL.backgroundColor = '#e8c3b9';
		
		let rRngArr = [], rUclArr = [], rClArr = [], rLclArr = [];
		$.each(json.data, function(idx, itm) {
			labelArr.push(itm.MSRM_DAY);
			rRngArr.push(itm.R);
			rUclArr.push(itm.R_UCL);
			rClArr.push(itm.R_CL);
			rLclArr.push(itm.R_LCL);
		});
		
// 		R_CL.borderDash = [20, 30];
		R_CL.borderDash = [10, 10];
		
		R_RNG.data = rRngArr;
		R_UCL.data = rUclArr;
		R_CL.data = rClArr;
		R_LCL.data = rLclArr;
		
		let datasets = [];
		datasets.push(R_RNG);
		datasets.push(R_UCL);
		datasets.push(R_CL);
		datasets.push(R_LCL);
		
		cnfg_chrt2Line.data.labels = labelArr;
		cnfg_chrt2Line.data.datasets = datasets;
		chrt2Line.update();
		
		$('#chrt2Line').show();
		
	}
	
	function setChrt1Line_spc01() {
		const ctx = document.getElementById('chrt1Line').getContext('2d');
		
		cnfg_chrt1Line = {
		    type: 'line',
		    data: {
		        labels: [],
		        datasets: []
		    },
		    options: {
		    	// 안상현
		    	
		        responsive: true,
		        tooltips: {
		            mode: 'index',
		            intersect: false,
		        },
		        hover: {
		            mode: 'nearest',
		            intersect: true
		        },
		        scales: {
		            yAxes: [{
		                display: true,
		                ticks: {
		                    suggestedMin: 0,
		                }
		            }]
		        }
		    }
		};
		
		chrt1Line = new Chart(ctx, cnfg_chrt1Line);
	}
	
	function setChrt2Line_spc01() {
		const ctx = document.getElementById('chrt2Line').getContext('2d');
		
		cnfg_chrt2Line = {
		    type: 'line',
		    data: {
		        labels: [],
		        datasets: []
		    },
		    options: {
		    	// 안상현
		    	
		        responsive: true,
		        tooltips: {
		            mode: 'index',
		            intersect: false,
		        },
		        hover: {
		            mode: 'nearest',
		            intersect: true
		        },
		        scales: {
		            yAxes: [{
		                display: true,
		                ticks: {
		                    suggestedMin: 0,
		                }
		            }]
		        }
		    }
		};
		
		chrt2Line = new Chart(ctx, cnfg_chrt2Line);
	}
	
	function commonBtnClick(btnName) {   // 버튼 클릭
		if (btnName == "Search") {
			searchList();
		}
	}
	
</script>
</head>
<body style="min-width:1394px;">
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
					<input type="button" CB="Search SEARCH BTN_SEARCH" />
				</div>
			</div>

			<div class="search_inner">
				
				<div class="search_wrap ">
					<dl>
						<dt CL="STD_WERKS">플랜트</dt>
						<dd>
							<input type="text" class="input" id="WERKS" name="WERKS" UIInput="S,PLANT" UIFormat="U" validate="" onkeyup=""/>
						</dd>
					</dl>
					
					<dl>
						<dt CL="STD_INSP_ITEM_GRP_CD">검사항목그룹</dt>
						<dd>
							<select class="input" name="INSP_ITEM_GRP_CD" Combo="mes,COMMONCOMBO" validate="">
								<option value="">All</option>
							</select>
						</dd>
					</dl>
					
					<dl>
						<dt CL="STD_INSP_ITEM_NM">검사항목명</dt>
						<dd>
							<input type="text" class="input" name="INSP_ITEM_NM"/>
						</dd>
					</dl>
					
					<dl>
						<dt CL="STD_MSRM_DATE">측정일자</dt>
						<dd>
							<input type="text" id="MSRM_DATE" name="MSRM_DATE" UIInput="B" UIFORMAT="C M1"/>
						</dd>
					</dl>
					
					<dl>
						<dt CL="STD_MATNR"></dt>
						<dd>
							<input type="text" class="input" name="MATNR" id="MATNR" UIInput="S,MATKY" UIFormat="U"/>
						</dd>
					</dl>
				</div>
				
				<div class="btn_tab">
					<input type="button" class="btn_more" value="more" onclick="searchMore()"/>
				</div>
			</div>
		</div>
        <div class="search_next_wrap">
			<div class="content_layout tabs top_layout" style="height: 40%;">
				<ul class="tab tab_style02">
					<li>
						<a href="#tab1-1" style="padding: 10px 0px;">
							<span>CP/CPK</span>
						</a>
					</li>
					<li class="btn_zoom_wrap">
						<ul>
							<li><button class="btn btn_bigger"><span>확대</span></button></li>
						</ul>
					</li>
				</ul>
				<div class="table_box section" id="tab1-1">
					<div class="table_list01">
						<div class="scroll">
							<table class="table_c1">
								<tbody id="gridList1">
									<tr CGRow="true">
										<td GH="40" GCol="rownum">1</td>
										<td GH="70" GCol="text,WERKS" style="text-align:center;">플랜트</td>
										<td GH="100" GCol="text,MACH_CD" style="text-align: center;">설비코드</td>
										<td GH="130" GCol="text,MACH_NM">설비명</td>
										<td GH="140" GCol="text,MATNR" style="text-align: center;">자재코드</td> 
										<td GH="320" GCol="text,MATNR_NM">자재명</td>
										<td GH="100" GCol="text,PASS_CNT" style="text-align: right;">적합수량</td>
										<td GH="100" GCol="text,FAIL_CNT" style="text-align: right;">부적합수량</td>
										<td GH="100" GCol="text,UCFMTY_AMT" style="text-align: right;">부적합량</td>
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
			
			<div class="content-horizontal-wrap h-wrap-min bottom_layout" style="height: 65%;">
				<div class="content_layout tabs content_left" style="width: 29%;">
					<ul class="tab tab_style02">
						<li onclick="">
							<a href="#tab1-1" style="padding: 10px 0px;"></a>
						</li>
						<li class="btn_zoom_wrap">
							<ul>
								<li><button class="btn btn_bigger"><span>확대</span></button></li>
							</ul>
						</li>
					</ul>
					<div class="table_box section" id="gridList2_tab1">
						<div class="table_list01">
							<div class="scroll">
								<table class="table_b">
									<tbody id="gridList2">
										<tr CGRow="true">
											<td GH="40" GCol="rownum"></td>
											<td GH="150" GCol="text,INSP_ITEM" style="text-align: left;">검사항목</td>
											<td GH="50" GCol="text,STD_VAL_SPEC" style="text-align: right;">SPEC</td>
											<td GH="50" GCol="text,UPP_VAL_USL" style="text-align: right;">USL</td>
											<td GH="50" GCol="text,LOW_VAL_LSL" style="text-align: right;">LSL</td>
											<td GH="50" GCol="text,MSRM_CNT" style="text-align: right;">측정수량</td>
										</tr>
									</tbody>
								</table>
							</div>
						</div>
						<jsp:include page="/WEB-INF/jsp/common/commonBtnAuth.jsp">
							<jsp:param name="authCd" value="1" />
							<jsp:param name="showAuthCd" value="1,2,9" />
						</jsp:include>
					</div>
				</div>
				
				<div class="content_layout tabs content_right" style="width: 70%;">
					<ul class="tab tab_style02">
						<li>
							<a href="#tab1-1" style="padding: 10px 0px;"></a>
						</li>
						<li class="btn_zoom_wrap">
							<ul>
								<li><button class="btn btn_bigger"><span>확대</span></button></li>
							</ul>
						</li>
					</ul>
					<div class="table_box section" id="gridList3_tab1" style="height: 20%;">
						<div class="table_list01">
							<div class="scroll">
								<table class="table_b">
									<tbody id="gridList3">
										<tr CGRow="true">
											<td GH="70" GCol="text,AVG" style="text-align: right;"></td>
											<td GH="70" GCol="text,POP" style="text-align: right;"></td>
											<td GH="70" GCol="text,STDDEV_WITHIN" style="text-align: right;"></td>
											<td GH="90" GCol="text,STDDEV_OVERALL" style="text-align: right;"></td>
											<td GH="70" GCol="text,K" style="text-align: right;"></td>
											<td GH="70" GCol="text,PP" style="text-align: right;"></td>
											<td GH="70" GCol="text,PPL" style="text-align: right;"></td>
											<td GH="70" GCol="text,PPU" style="text-align: right;"></td>
											<td GH="70" GCol="text,PPK" style="text-align: right;"></td>
											<td GH="70" GCol="text,CP" style="text-align: right;"></td>
											<td GH="70" GCol="text,CPL" style="text-align: right;"></td>
											<td GH="70" GCol="text,CPU" style="text-align: right;"></td>
											<td GH="70" GCol="text,CPK" style="text-align: right;"></td>
											<td GH="70" GCol="text,PASS_RATE" style="text-align: right;"></td>
											<td GH="70" GCol="text,OBS" style="text-align: right;"></td>
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
					
					<canvas id="chrt1Line" width="1000vw" height="150vh"></canvas>
					<canvas id="chrt2Line" width="1000vw" height="150vh"></canvas>
			</div>
		</div>
	</div>
</div>
<!-- // content -->
<%@ include file="/common/include/webdek/bottom.jsp" %>
</body>
</html>