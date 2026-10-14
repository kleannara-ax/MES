<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Grid default</title>
<%@ include file="/common/include/webdek/head.jsp" %>
<link rel="stylesheet" type="text/css" href="/common/theme/webdek/css/demo_layout.css">
<script type="text/javascript">
	$(document).ready(function(){
		gridList.setGrid({
	    	id : "gridList",
	    	url : "/mes/Work/WRK50/json/datalist.data",
	    	bigdata : false,
	    	colorType : true,
	    	colHoldType : true,
	    	colHold : 'WERKS, STOR_LOC_CD, LOT_NO, MATNR, MATNR_NM',
	    	firstRowFocusType : false
	    });
		
		gridList.setGrid({
	    	id : "gridList2",
	    	url : "/mes/Work/WRK50/json/datalist.data",
	    	bigdata : false,
	    	colorType : true,
	    	colHoldType : true,
	    	colHold : 'WERKS, STOR_LOC_CD, LOT_NO, MATNR, MATNR_NM',
	    	firstRowFocusType : false
	    });
		
		$("#tab1-1").show();	//화장지
		$("#tab1-2").hide();	//패드
	});

	// 조회
	/* function searchList(){
		if(validate.check("searchArea")){
			var searchdata = inputList.setRangeParam("searchArea");
			var date = searchdata.get('RANGE_DATA_PARAM').get('PRFM_DT_Range').split('↓');
			
			var param = new DataMap();
			
			param.put("P_TYPE", "LIST");
			param.put("WERKS", searchdata.get('WERKS'));
			param.put("STOR_LOC_CD", searchdata.get('STOR_LOC_CD'));
			param.put('LOT_NO', searchdata.get('LOT_NO'));
			param.put('MATNR', searchdata.get('MATNR'));
			param.put('WKDT', searchdata.get('WKDT'));
			param.put('FROM_PRD_DT', date[1]);
			param.put('TO_PRD_DT', date[2]);
			
			gridList.gridList({
		    	id : "gridList",
		    	param : param
		    });
		}
	} */
	
	function searchList(){
		if(validate.check("searchArea")){
			var werks = $("#WERKS").val().toUpperCase().trim();
			const param = inputList.setRangeParam("searchArea")
			param.put("P_TYPE", "LIST")
					
			/* var searchdata = inputList.setRangeParam("searchArea");
			/* var date = searchdata.get('RANGE_DATA_PARAM').get('PRFM_DT_Range').split('↓');
			var param = new DataMap();
			
	
			param.put("P_TYPE","LIST");
			param.put("WERKS", searchdata.get('WERKS'));
			param.put("STOR_LOC_CD", searchdata.get('STOR_LOC_CD'));
			param.put('LOT_NO', searchdata.get('LOT_NO'));
			param.put('MATNR', searchdata.get('MATNR'));
			param.put('WKDT', searchdata.get('WKDT'));
 			param.put('FROM_PRD_DT', date[1]);
			param.put('TO_PRD_DT', date[2]);  */
			
			//화장지
			if(werks == 'P100'){
								
				gridList.resetGrid("gridList2");
				
				$("#tab1-1").show();	//
				$("#tab1-2").hide();	//
				
				gridList.gridList({
			    	id : "gridList",
			    	param : param
			    });
				
			} else {
				//
				gridList.resetGrid("gridList");
				
				$("#tab1-1").hide();	//
				$("#tab1-2").show();	//
				
				gridList.gridList({
			    	id : "gridList2",
			    	param : param
			    });
				
			} 
		}
	}
	
	
	
	function Receive(){
		if($('#WERKS').val() == '')	return alert('플랜트 정보를 입력하세요.');
		if($('#WKDT').val() =='')	return alert('마감년월을 선택 및 입력하세요.');
		if(!commonUtil.msgConfirm("SAP 재고 정보 요청 하시겠습니까?")){
			return;
		}
		var param = new DataMap();
		
		param.put('IFTBL','TB_IFR050');
		
		netUtil.send({
			url : "/IF/map/json/IFRCVMAXPREVSEQ.data",
			param : param,
			successFunction : 'saveSuccessCallBack'
		});
	}	
	
	function saveSuccessCallBack(json){
		if(json&&json.data){
			var searchdata = inputList.setRangeParam("searchArea");
			var param = new DataMap();
			
			param.put("PREVSEQNO", json.data.LOGSEQNO);
			param.put('IFID', 'MES_IF_907');
			param.put('IFTBL','TB_IFR050');
			param.put("RFCFN", 'Z_MES_SAP_INV_INFO');
			param.put("RFCTBL", 'ET_DATA');
			param.put("RFCP1", 'ES_RETURN');
			param.put("SYSFR", 'SAP');
			param.put("SYSTO", 'MES');
			param.put("WERKS", searchdata.get('WERKS'));
			param.put("STOR_LOC_CD", searchdata.get('STOR_LOC_CD'));
			param.put('LOT_NO', searchdata.get('LOT_NO'));
			param.put('MATNR', searchdata.get('MATNR'));
			param.put('WKDT', searchdata.get('WKDT'));
			
			netUtil.send({
				module : 'Erpif',
				command : 'IFR050',
				sendType : 'delete',
				param : param
			});
			
			// 데이터 수신요청
			var json2 = netUtil.sendData({
				url : '/rfc/json/rfcCall.data',
				param : param
			});
		    
			if(json2.row_count > 0){
				commonUtil.msgBox("데이터 수신 완료했습니다.");
			} else {
				commonUtil.msgBox("수신된 데이터가 없습니다.");
			}
		}
		
		searchList();
	}
	
	function gridListColBgColorChange (gridId, rowNum, colName, colValue){
		if(gridId == 'gridList'){
			/* if(colName == 'WMS_STCK_QTY' || colName == 'SAP_STCK_QTY'){
				if(parseInt(colValue) > 0)	return configData.GRID_COLOR_BG_GREEN_CLASS;
			} */
			if(colName == 'SAP_DIFF_QTY'){
				if(parseInt(colValue) != 0)	return configData.GRID_COLOR_BG_GREEN_CLASS;
			}
		}
	}
	
	// 버튼 클릭(조회)
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
		}else{
			//SAP RFC 호출
			Receive();
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
					<input type='button' id='button-0-3' CB='Receive APPLY BTN_RFC_CALL'/>
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
						<dt CL="STD_STOR_LOC_CD">저장위치</dt>
						<dd>
							<input type="text" name="STOR_LOC_CD" id="STOR_LOC_CD" UIInput="S,LOC" UIFormat="U"/>
						</dd>
					</dl>
					<dl>
						<dt CL="STD_LOT_NO">LOT번호</dt>
						<dd>
							<input type="text" class='input' id="LOT_NO" name="LOT_NO" UIInput="S" UIFormat="U"/>
						</dd>
					</dl>
					<dl>
						<dt CL="STD_MATNR">자재코드</dt>
						<dd>
							<input type="text" name="MATNR" id="MATNR" UIInput="S,MATKY" UIFormat="U"/>
						</dd>
					</dl>
					<dl>
						<dt CL="STD_PRFM_DT">전기일자</dt>
						<dd>
							<input type="text" id="PRFM_DT" name="PRFM_DT" UIInput="B" UIFormat="C M1"/>
							<input type="hidden" name="WKDT" value='202303'/>
						</dd>
					</dl>
					<!-- <dl>
						<dt CL="STD_WKDT">마감년월</dt>
						<dd>
							<input type="text" class='input' id='WKDT' name="WKDT" UIFormat="MS" validate='required'/>
						</dd>
					</dl> -->
				</div>
				<div class="btn_tab">
					<input type="button" class="btn_more" value="more" onclick="searchMore()"/>
				</div>
			</div>
		</div>
        <div class="search_next_wrap">
			<div class="content_layout tabs">
				<ul class="tab tab_style02">
					<li><a href="#tab1-1"><span CL="STD_GRD_WRK50">리스트</span></a></li>
					<li class="btn_zoom_wrap">
						<ul>
							<li><button class="btn btn_bigger"><span>확대</span></button></li>
						</ul>
					</li>
				</ul>
				<div class="table_box section" id="tab1-1">
					<div class="table_list01">
						<!-- <div class="table_thead tableHeader" style="margin-left: 0px;">
							<table>
								<colgroup>
									<col width="100px"/>
									<col width="100px" />
									<col width="100px" />
									<col width="140px" />
									<col width="320px" />
									<col width="100px" />
									<col width="100px" />
									<col width="100px" />
									<col width="100px"/>
									<col width="100px" />
									<col width="120px" />
									<col width="120px" />
									<col width="120px" />
									<col width="120px" />
									<col width="120px" />
									<col width="120px" />
									<col width="120px" />
									<col width="120px" />
									<col width="100px" />
									<col width="100px" />
									<col width="100px" />
									<col width="100px" />
								</colgroup>
								<thead>
									<tr>
										<th rowspan="3" CL="STD_WERKS">플랜트</th>
										<th rowspan="3" CL="STD_STOR_LOC_CD">저장위치</th>
										<th rowspan="3" CL="STD_LOT_NO">LOT번호</th>
										<th rowspan="3" CL="STD_MATNR">자재코드</th>
										<th rowspan="3" CL="STD_MATNR_NM">자재명</th>
										<th rowspan='3' CL='STD_UNIT'>단위</th>
										<th rowspan="3" CL="STD_PRFM_QTY">실적량</th>
										<th rowspan="3" CL="STD_STCK_QTY">재고수량</th>
										<th rowspan="3" CL="STD_CNL_PRFM_QTY">취소량</th>
										<th colspan="4" CL="STD_MES_WMS">MES <-> WMS</th>
										<th rowspan="3" CL="STD_WMS_STCK_QTY">WMS<br />재고량</th>
										<th rowspan='3' CL='STD_WMS_USE_QTY'>WMS 가용수량</th>
										<th rowspan="3" CL="STD_WMS_DIFF_QTY">SAP<br />재고차이</th>
										<th colspan="4" CL="STD_MES_SAP">MES <-> SAP</th>
										<th rowspan="3" CL="STD_SAP_STCK_QTY">SAP<br />재고량</th>
										<th rowspan="3" CL="STD_SAP_DIFF_QTY">SAP<br />재고차이</th>
									</tr>
									<tr>
										<th colspan="2" CL="STD_WMS_SUCC">성공</th>
										<th colspan="2" CL="STD_WMS_FAIL">실패</th>
										<th colspan="2" CL="STD_SAP_SUCC">성공</th>
										<th colspan="2" CL="STD_SAP_FAIL">실패</th>
									</tr>
									<tr>
										<th CL="STD_WMS_SUCC_CNT">건수</th>
										<th CL="STD_WMS_SUCC_QTY">전송량</th>
										<th CL="STD_WMS_FAIL_CNT">건수</th>
										<th CL="STD_WMS_FAIL_QTY">사용량</th>
										
										<th CL="STD_SAP_SUCC_CNT">건수</th>
										<th CL="STD_SAP_SUCC_QTY">전송량</th>
										<th CL="STD_SAP_FAIL_CNT">건수</th>
										<th CL="STD_SAP_FAIL_QTY">사용량</th>
									</tr>
								</thead>
							</table>
						</div> -->
						<div class="scroll">
							<table class="table_b">
								<tbody id="gridList">
									<tr CGRow="true">
										<td GH='100' GCol="text,WERKS" style="text-align:center;">플랜트</td>
										<td GH='100' GCol="text,STOR_LOC_CD" style="text-align:center;">저장위치</td>
										<td GH='100' GCol="text,LOT_NO" style="text-align:center;">LOT번호</td>
										<td GH='140' GCol="text,MATNR" style="text-align:center;">자재코드</td>
										<td GH='280' GCol="text,MATNR_NM" style='text-align:center;'>자재명</td>
										<td GH='80' Gcol='text,UNIT' style='text-align:center;'>단위</td>
										<!-- <td GH='100' GCol="text,PRFM_QTY" GF="N 13,3">실적량</td> -->
										<td GH='100' GCol="text,STCK_QTY" GF="N 13,3">재고수량</td>
										<td GH='100 SAP저장위치' GCol="text,LGORT" style='text-align:center;'>SAP저장위치</td>
										<td GH='100' GCol="text,SAP_STCK_QTY" GF="N 10,3">SAP재고량</td>
										<td GH='100' GCol="text,SAP_DIFF_QTY" style='text-align:center;'>SAP재고차이</td>
										<td GH='110' GCol="text,WMS_STCK_QTY" GF="N 13,3">WMS재고량</td>
										
										<!-- <td GCol="text,CNL_PRFM_QTY" GF="N 13,3">취소량</td>
										<td GCol="text,WMS_SUCC_CNT" GF="N 13">건수</td>
										<td GCol="text,WMS_SUCC_QTY" GF="N 13,3">전송량</td>
										<td GCol="text,WMS_FAIL_CNT" GF="N 13">건수</td>
										<td GCol="text,WMS_FAIL_QTY" GF="N 13,3">전송량</td>
										<td GCol="text,WMS_STCK_QTY" GF="N 13,3">WMS재고량</td>
										<td Gcol='text,WMS_USE_QTY' GF='N 13,3'>WMS가용수량</td>
										<td GCol="text,WMS_DIFF_QTY" GF="N 10,3">WMS재고차이</td>
										<td GCol="text,SAP_SUCC_CNT" GF="N 13">건수</td>
										<td GCol="text,SAP_SUCC_QTY" GF="N 13,3">전송량</td>
										<td GCol="text,SAP_FAIL_CNT" GF="N 13">건수</td>
										<td GCol="text,SAP_FAIL_QTY" GF="N 13,3">전송량</td>
										<td GCol="text,SAP_STCK_QTY" GF="N 10,3">SAP재고량</td>
										<td GCol="text,SAP_DIFF_QTY" GF="N 10,3">SAP재고차이</td> -->
									</tr>
								</tbody>
							</table>
						</div>
					</div>
					<jsp:include page="/WEB-INF/jsp/common/commonBtnAuth.jsp">
                    	<jsp:param value="1" name="authCd"/>
                    	<jsp:param value="1,2,3,7,9,10" name="showAuthCd"/>
                    </jsp:include>
				</div>
				
				<div class="table_box section" id="tab1-2">
					<div class="table_list01">
						<div class="scroll">
							<table class="table_b">
								<tbody id="gridList2">
									<tr CGRow="true">
										<td GH='100' GCol="text,WERKS" style="text-align:center;">플랜트</td>
										<td GH='100' GCol="text,STOR_LOC_CD" style="text-align:center;">저장위치</td>
										<td GH='100' GCol="text,LOT_NO" style="text-align:center;">LOT번호</td>
										<td GH='140' GCol="text,MATNR" style="text-align:center;">자재코드</td>
										<td GH='280' GCol="text,MATNR_NM" style='text-align:center;'>자재명</td>
										<td GH='80' Gcol='text,UNIT' style='text-align:center;'>단위</td>
										<!-- <td GH='100' GCol="text,PRFM_QTY" GF="N 13,3">실적량</td> -->
										<td GH='100' GCol="text,STCK_QTY" GF="N 13,3">재고수량</td>
										
										<td GH='100' GCol="text,USE_QTY" GF="N 13,3">사용량</td>
										
										<td GH='100 SAP저장위치' GCol="text,LGORT" style='text-align:center;'>SAP저장위치</td>
										<td GH='100' GCol="text,SAP_STCK_QTY" GF="N 10,3">SAP재고량</td>
										<td GH='100' GCol="text,SAP_DIFF_QTY" GF="N 13,3">SAP재고차이</td>
										<td GH='100' GCol="text,DIFF_QTY" GF="N 13,3">차이수량</td>
										<!-- <td GH='110' GCol="text,WMS_STCK_QTY" GF="N 13,3">WMS재고량</td> -->
									</tr>
								</tbody>
							</table>
						</div>
					</div>
					<jsp:include page="/WEB-INF/jsp/common/commonBtnAuth.jsp">
                    	<jsp:param value="1" name="authCd"/>
                    	<jsp:param value="1,2,3,7,9,10" name="showAuthCd"/>
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