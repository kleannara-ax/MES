<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Grid default</title>
<%@ include file="/common/include/webdek/head.jsp"%>
<link rel="stylesheet" type="text/css"
	href="/common/theme/webdek/css/demo_layout.css">
<script type="text/javascript">
	$(document).ready(function() {
		gridList.setGrid({
			id : "gridList",
			url : "/mes/Work/WRK51/json/datalist.data",
			bigdata : false,
			colorType : true,
			colHoldType : true,
			colHold : "WERKS, LOT_NO, MATNR, UNIT, PRFM_CNT, PRFM_QTY"
		});
	});

	// 조회
	const searchList = () => {
		// 검색 조건 validation
		if(validate.check("searchArea")){
			var param = inputList.setRangeParam("searchArea");
			param.put("P_TYPE","LIST");
			
			gridList.gridList({
				id : "gridList",
				param : param
			});
		}
	}
	
	function gridListColBgColorChange (gridId, rowNum, colName, colValue){
		if(gridId == 'gridList'){
			if(colName == 'M_2000' || colName == 'S_2000' || colName == 'M_2500' || colName == 'S_2500' || colName == 'M_2700' || colName == 'S_2700'
					|| colName == 'M_2600' || colName == 'S_2600' || colName == 'M_3100' || colName == 'S_3100' || colName == 'M_3000' || colName == 'S_3000'){
				if(parseInt(colValue) > 0)	return configData.GRID_COLOR_BG_GREEN_CLASS;
			}
		}
	}
	
	// 버튼 클릭(조회)
	function commonBtnClick(btnName) {
		if (btnName == "Search") {
			var param = new DataMap();
            param.put("PROGID", "<%= menuId%>");
            param.put("LGTYPE", "SEARCH");
            var json = netUtil.sendData({
                url: "/mes/system/json/saveLog.data",
                param : param
            });

            searchList();
		}
	}
</script>
</head>
<body>
	<%@ include file="/common/include/webdek/layout.jsp"%>
	<!-- content -->
	<div class="content_wrap">
		<div class="content_inner">
			<%@ include file="/common/include/webdek/title.jsp"%>
			<div class="content_serch" id="searchArea">
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
						<dt CL="STD_PLANT">플랜트</dt>
						<dd>
							<input type="text" id='WERKS' name="WERKS" UIInput="S,PLANT" UIFormat="U" validate='required'/>
						</dd>
					</dl>
					<dl>
						<dt CL="STD_LOT_NO">LOT번호</dt>
						<dd>
							<input type="text" class='input' name="LOT_NO" UIInput="SR" UIFormat="U"/>
						</dd>
					</dl>
					<dl>
						<dt CL="STD_IND_BCD">개별바코드</dt>
						<dd>
							<input type="text" class='input' name="IND_BCD" UIInput="SR,INDBCD" UIFormat="U"/>
						</dd>
					</dl>
					<dl>
						<dt CL="STD_MATNR">자재코드</dt>
						<dd>
							<input type="text" name="MATNR" UIInput="SR,MATKY" UIFormat="U"/>
						</dd>
					</dl>
					</div>
					<div class="btn_tab">
						<input type="button" class="btn_more" value="more" onclick="searchMore()" />
					</div>
				</div>
			</div>
			<div class="search_next_wrap">
				<div class="content_layout tabs">
					<ul class="tab tab_style02">
						<li><a href="#tab1-1"><span>일반</span></a></li>
						<li class="btn_zoom_wrap">
							<ul>
								<li><button class="btn btn_bigger"><span>확대</span></button></li>
							</ul>
						</li>
					</ul>
					<div class="table_box section" id="tab1-1">
						<div class="table_list01">
							<div class="table_thead tableHeader" style="margin-left: 0px;">
								<table>
									<colgroup>
										<col width="100px"/>
										<col width="100px" />
										<col width="140px" />
										<col width="100px" />
										<col width="100px" />
										<col width="100px" />
										<col width="100px" />
										<col width="100px" />
										<col width="100px"/>
										<col width="100px" />
										<col width="100px" />
										<col width="100px" />
										<col width="100px" />
										<col width="100px" />
										<col width="100px" />
										<col width="100px" />
										<col width="100px" />
										<col width="100px" />
									</colgroup>
									<thead>
										<tr>
											<th rowspan="2" CL="STD_WERKS">플랜트</th>
											<th rowspan="2" CL="STD_LOT_NO">LOT번호</th>
											<th rowspan="2" CL="STD_MATNR">자재코드</th>
											<th rowspan='2' CL='STD_UNIT'>단위</th>
											<th rowspan="2" CL="STD_PRFM_CNT">실적건수</th>
											<th rowspan="2" CL="STD_PRFM_QTY">실적량</th>
											<th colspan="2" CL="STD_STOR_2000">2000저장위치</th>
											<th colspan="2" CL="STD_STOR_2500">2500저장위치</th>
											<th colspan="2" CL="STD_STOR_2700">2700저장위치</th>
											<th colspan='2' CL="STD_STOR_2600">2600저장위치</th>
											<th colspan="2" CL="STD_STOR_3100">3100저장위치</th>
											<th colspan="2" CL="STD_STOR_3000">3000저장위치</th>
										</tr>                       
										<tr>                        
											<th CL="STD_M_2000">MES(2000)</th>
											<th CL="STD_S_2000">SAP(2000)</th>
											<th CL="STD_M_2500">MES(2500)</th>
											<th CL="STD_S_2500">SAP(2500)</th>
											<th CL="STD_M_2700">MES(2700)</th>
											<th CL="STD_S_2700">SAP(2700)</th>
											<th CL="STD_M_2600">MES(2600)</th>
											<th CL="STD_S_2600">SAP(2600)</th>
											<th CL="STD_M_3100">MES(3100)</th>
											<th CL="STD_S_3100">SAP(3100)</th>
											<th CL="STD_M_3000">MES(3000)</th>
											<th CL="STD_S_3000">SAP(3000)</th>
										</tr>
									</thead>
								</table>
							</div>
							<div class="scroll" style="height: calc(100% - 70px)">
								<table class="table_b">
									<tbody id="gridList">
										<tr CGRow="true">
											<td GCol="text,WERKS" style="text-align:center;">플랜트</td>
											<td GCol="text,LOT_NO" style="text-align:center;">LOT번호</td>											
											<td GCol="text,MATNR" style="text-align:center;">자재코드</td>
											<td GCol="text,UNIT" style="text-align:center;">단위</td>
											<td GCol="text,PRFM_CNT" GF='N 10'>실적개수</td>
											<td GCol="text,PRFM_QTY" GF="N 13,2">실적수량</td>
											<td GCol="text,M_2000" GF="N 13,2">MES_2000</td>
											<td GCol="text,S_2000" GF="N 13,2">SAP_2000</td>
											<td GCol="text,M_2500" GF="N 13,2">MES_2500</td>
											<td GCol="text,S_2500" GF="N 13,2">SAP_2500</td>
											<td GCol="text,M_2700" GF="N 13,2">MES_2700</td>
											<td GCol="text,S_2700" GF="N 13,2">SAP_2700</td>
											<td GCol="text,M_2600" GF="N 13,2">MES_2600</td>
											<td GCol="text,S_2600" GF="N 13,2">SAP_2600</td>
											<td GCol="text,M_3100" GF="N 13,2">MES_3100</td>
											<td GCol="text,S_3100" GF="N 13,2">SAP_3100</td>
											<td GCol="text,M_3000" GF="N 13,2">MES_3000</td>
											<td GCol="text,S_3000" GF="N 13,2">SAP_3000</td>
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
	<%@ include file="/common/include/webdek/bottom.jsp"%>
</body>
</html>