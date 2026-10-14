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
		
		$('.btn_lit.tableUtil').hide();
		
		gridList.setGrid({
	    	id : "gridList",
	    	url : "/mes/Work/WRK23/json/datalist.data",
	    	bigdata : false
	    });
		
		setGrid_wrk23('gridListSub1, gridListSub2, gridListSub3, gridListSub4, gridListSub5, gridListSub6');
		
		
		
		
		
		
// 		gridList.setGrid({
// 	    	id : "gridList",
// 	    	module : "System",
// 			command : "SYSLABEL"
// 	    });
		
// 		gridList.setGrid({
// 	    	id : "gridList2",
// 	    	module : "System",
// 			command : "SYSLABEL"
// 	    });
		
	});
	
	
	
	function setGrid_wrk23(cmaStr) {
// 		const loadUrl = "/mes/Master/MAS10/json/datalist.data";
		const cmaStrArr = cmaStr.split(',');
		for (let i = 0; i < cmaStrArr.length; i++) {
			gridList.setGrid({
		    	id : $.trim(cmaStrArr[i]),
		    	url : "/mes/Work/WRK23/json/datalist.data",
		    	bigdata : false,
		    	emptyMsgType : false
		    });
		}
	}
	
	
	
	function resetGrid_wrk23(cmaStr) {
		const cmaStrArr = cmaStr.split(',');
		for (let i = 0; i < cmaStrArr.length; i++) {
			gridList.resetGrid($.trim(cmaStrArr[i]) );
		}
	}
	
	

	function searchList() {
		if(validate.check("searchArea")){
			var param = inputList.setRangeParam("searchArea");
			
// 			console.log('param = ', param);
			
			resetGrid_wrk23('gridListSub1, gridListSub2, gridListSub3, gridListSub4, gridListSub5, gridListSub6');
			
			param.put("P_TYPE","LIST");
			
			gridList.gridList({
		    	id : "gridList",
		    	param : param
		    });
			
		}
	}
	
	
	
	function gridListEventRowDblclick(gridId, rowNum, colName) {
		if (gridId != 'gridList') return;
		
		if (!validate.check("searchArea")) return;
		
		var param = inputList.setRangeParam("searchArea");
		param.map.LOT_NO = gridList.getRowData('gridList', gridList.getFocusRowNum('gridList') ).map.LOT_NO;
// 		param.map.LOT_NO_M = gridList.getRowData('gridList', gridList.getFocusRowNum('gridList') ).map.LOT_NO_M;
// 		param.map.MATNR_M = gridList.getRowData('gridList', gridList.getFocusRowNum('gridList') ).map.MATNR_M;
		
		
		param.put("P_TYPE","SUB_LIST1");
		gridList.gridList({
			id : "gridListSub1",
			param : param
		});
		
		param.put("P_TYPE","SUB_LIST2");
		gridList.gridList({
			id : "gridListSub2",
			param : param
		});	
		
		param.put("P_TYPE","SUB_LIST3");
		gridList.gridList({
			id : "gridListSub3",
			param : param
		});	
		
		param.put("P_TYPE","SUB_LIST4");
		gridList.gridList({
			id : "gridListSub4",
			param : param
		});	
		
		param.put("P_TYPE","SUB_LIST5");
		gridList.gridList({
			id : "gridListSub5",
			param : param
		});	
		
		param.put("P_TYPE","SUB_LIST6");
		gridList.gridList({
			id : "gridListSub6",
			param : param
		});	
	}
	
	
	
	
	
	function saveData(){
		if(gridList.validationCheck("gridList", "all")){
			gridList.gridSave({
		    	id : "gridList",
		    	modifyType : "A"
		    });
		}
	}

	function commonBtnClick(btnName){
		//commonUtil.debugMsg("commonBtnClick : ", arguments);
		if(btnName == "Search"){
			searchList();
		}else if(btnName == "Save"){
			saveData();
		}
	}
	
	const barcode = () => {
		var url = "/mes/wrk/WRK23_POP01.page";
		page.linkPopOpen(url, "", "height=600,width=850");
	}
</script>
</head>
<body>
<%@ include file="/common/include/webdek/layout.jsp" %>
<!-- content -->
<div class="content_wrap">
	<div class="content_inner contentH_inner">
		<%@ include file="/common/include/webdek/title.jsp" %>
		<div class="content_serch" id="searchArea">
			<div class="btn_wrap">
				<div class="fl_l">
				</div>
				<div class="fl_r">
					<input type="button" id="button-0-1" CB="Search SEARCH BTN_SEARCH" />
<!-- 					<input type="button" id="button-0-2" CB="Save SAVE BTN_SAVE" /> -->
<!-- 					<input type="button" CB="Delete DELETE BTN_DELETE" /> -->
				</div>
			</div>
			<div class="search_inner">
				<div class="search_wrap ">
					<dl>
						<dt CL="STD_PLANT">플랜트</dt>
						<dd>
							<input type="text" class="input" id="WERKS" name="WERKS" UIInput="S,PLANT" UIFormat="U"/>
						</dd>
					</dl>
					<dl>
						<dt>바코드 / LOT번호</dt>
						<dd>
							<input type="text" class="input" id="IND_BCD" name="IND_BCD" validate="required" UIFormat="U"/>
							<button type="button" class="btn btn_search" onclick="barcode()">
								<span>search</span>
							</button>
						</dd>
					</dl>
				</div>
				<div class="btn_tab">
					<input type="button" class="btn_more" value="more" onclick="searchMore()"/>
				</div>
			</div>
		</div>
        <div class="search_next_wrap">
			<div class="content-horizontal-wrap h-wrap-min" >
<!-- 				<div class="content_layout tabs content_left" style="min-height: 470px;"> -->
<!-- 				<div class="content_layout tabs content_left" style="height: 1890px;"> -->
				<div class="content_layout tabs content_left" >
					
					<ul class="tab tab_style02">
						<li><a href="#tab1-1"><span CL="STD_GRD_WRK23_1">일반</span></a></li>
<!-- 						<li><a href="#tab1-2"><span>상세</span></a></li> -->
						<li class="btn_zoom_wrap">
							<ul>
								<!-- <li><button class="btn btn_smaller"><span>축소</span></button></li> -->
								<li><button class="btn btn_bigger"><span>확대</span></button></li>
							</ul>
						</li>
					</ul>
					<div class="table_box section" id="tab1-1">
					<div class="table_list01">
						<div class="table_thead tableHeader" style="margin-left: 0px;">
							<table>
								<colgroup>
									<col width="70px" />
									<col width="110px" />
									
									<col width="120px" />
									<col width="120px" />
									<col width="300px" />
									<col width="90px" />
									<col width="140px" />
									<col width="90px" />
									<col width="90px" />
									
									<col width="120px" />
									<col width="120px" />
									<col width="300px" />
									<col width="90px" />
									<col width="140px" />
									<col width="90px" />
									<col width="90px" />
								</colgroup>
								<thead>
									<tr>
										<th CL='STD_NUMBER' rowspan="2">번호</th>
										<th CL='STD_PROC_NM' rowspan="2">공정명</th>
										<th CL='STD_EXCTN_PLN_PRFM' colspan="7"></th>
										<th CL='STD_INPUT' colspan="7"></th>
									</tr>
									<tr>
										<th CL='STD_IND_BCD'></th>
										<th CL='STD_MATNR'></th>
										<th CL='STD_MATNR_NM'></th>
										<th CL='STD_MACH_NM'></th>
										<th CL='STD_WRK_ORDR_NO'></th>
										<th CL='STD_LOT_NO'></th>
										<th CL='STD_PRFM_QTY'></th>
										
										<th CL='STD_IND_BCD_M'></th>
										<th CL='STD_MATNR_M'></th>
										<th CL='STD_MATNR_NM_M'></th>
										<th CL='STD_MACH_NM_M'></th>
										<th CL='STD_SUB_WRK_ORDR_NO'></th>
										<th CL='STD_LOT_NO_M'></th>
										<th CL='STD_IN_QTY'></th>
									</tr>
								</thead>
							</table>
						</div>
						<div class="scroll" style="height: calc(100% - 77px)">
							<table class="">
								<colgroup>
									<col width="70px" />
									<col width="110px" />
									
									<col width="120px" />
									<col width="120px" />
									<col width="300px" />
									<col width="90px" />
									<col width="140px" />
									<col width="90px" />
									<col width="90px" />
									
									<col width="120px" />
									<col width="120px" />
									<col width="300px" />
									<col width="90px" />
									<col width="140px" />
									<col width="90px" />
									<col width="90px" />
								</colgroup>
								<tbody id="gridList">
									<tr CGRow="true">
										<td GCol="rownum" style="text-align:center;">1</td>
										
										<td GCol="text,PROC_NM" style="text-align:left;"></td>
										<td GCol="text,IND_BCD" style="text-align:center;"></td>
										<td GCol="text,MATNR" style="text-align:center;"></td>
										<td GCol="text,MATNR_NM" style="text-align:left;"></td>
										<td GCol="text,MACH_NM" style="text-align:left;"></td>
										<td GCol="text,WRK_ORDR_NO" style="text-align:left;"></td>
										<td GCol="text,LOT_NO" style="text-align:center;"></td>
										<td GCol="text,PRFM_QTY" style="text-align:right;" GF="N 13,2"></td>
										
										<td GCol="text,IND_BCD_M" style="text-align:center;"></td>
										<td GCol="text,MATNR_M" style="text-align:center;"></td>
										<td GCol="text,MATNR_NM_M" style="text-align:left;"></td>
										<td GCol="text,MACH_NM_M" style="text-align:left;"></td>
										<td GCol="text,SUB_WRK_ORDR_NO" style="text-align:left;"></td>
										<td GCol="text,LOT_NO_M" style="text-align:center;"></td>
										<td GCol="text,IN_QTY" style="text-align:right;" GF="N 13,2"></td>
									</tr>									
								</tbody>
							</table>
						</div>
					</div>
<!-- 						<div class="table_list01"> -->
<!-- 							<div class="scroll"> -->
<!-- 								<table class="table_c"> -->
<!-- 									<tbody id="gridList"> -->
<!-- 										<tr CGRow="true"> -->
<!-- 											<td GH="40" GCol="rownum">1</td> -->
<!-- 											<td GH="90" GCol="text,IND_BCD" style="text-align:center;"></td> -->
<!-- 											<td GH="90" GCol="text,MATNR" style="text-align:center;"></td> -->
<!-- 											<td GH="90" GCol="text,MATNR_NM" style="text-align:left;"></td> -->
<!-- 											<td GH="90" GCol="text,MACH_NM" style="text-align:left;"></td> -->
<!-- 											<td GH="90" GCol="text,WRK_ORDR_NO" style="text-align:center;"></td> -->
<!-- 											<td GH="90" GCol="text,LOT_NO" style="text-align:center;"></td> -->
<!-- 											<td GH="90" GCol="text,PRFM_QTY" style="text-align:right;"></td> -->
											
<!-- 											<td GH="90" GCol="text,IND_BCD_M" style="text-align:center;"></td> -->
<!-- 											<td GH="90" GCol="text,MATNR_M" style="text-align:center;"></td> -->
<!-- 											<td GH="90" GCol="text,MATNR_NM_M" style="text-align:left;"></td> -->
<!-- 											<td GH="90" GCol="text,MACH_NM_M" style="text-align:left;"></td> -->
<!-- 											<td GH="90" GCol="text,SUB_WRK_ORDR_NO" style="text-align:center;"></td> -->
<!-- 											<td GH="90" GCol="text,LOT_NO_M" style="text-align:center;"></td> -->
<!-- 											<td GH="90" GCol="text,IN_QTY" style="text-align:right;"></td> -->
<!-- 										</tr> -->
<!-- 									</tbody> -->
<!-- 								</table> -->
<!-- 							</div> -->
<!-- 						</div> -->
						<jsp:include page="/WEB-INF/jsp/common/commonBtnAuth.jsp">
							<jsp:param name="authCd" value="1" />
							<jsp:param name="showAuthCd" value="1,2,9,10" />
						</jsp:include>
					</div>
				
				</div>
				
				
				<div class="content-vertical-wrap content_right">
					
<!-- 					<div class="content_layout tabs bottom_layout" style="height: 400px;"> -->
					<div class="content_layout tabs bottom_layout" style="height: 300px;">
						<ul class="tab tab_style02">
							<li><a href="#tab1-1"><span CL="STD_GRD_WRK23_2">오더/지시</span></a></li>
<!-- 							<li><a href="#tab1-2"><span>상세</span></a></li> -->
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
									<table class="">
										<tbody id="gridListSub1">
											<tr CGRow="true">
												<td GH="40" GCol="rownum">1</td>
												<td GH="90" GCol="text,ORDER_NO" style="text-align:center;"></td>
												<td GH="110" GCol="text,MACH_NM" style="text-align:left;"></td>
												<td GH="110" GCol="text,MATNR" style="text-align:center;">자재코드</td>
												<td GH="280" GCol="text,MATNR_NM" style="text-align:left;"></td>
												<td GH="90" GCol="text,UNIT" style="text-align:center;"></td>
												<td GH="90" GCol="text,ORDER_QTY" style="text-align:right;" GF="N 13,2"></td>
												<td GH="90" GCol="text,ORDER_DIV" style="text-align:center;"></td>
												<td GH="90" GCol="text,RMK" style="text-align:left;"></td>
												<td GH="140" GCol="text,WRK_ORDR_NO" style="text-align:left;"></td>
												<td GH="90" GCol="text,WRK_SEQNO" style="text-align:right;"></td>
												<td GH="90" GCol="text,FQTY" style="text-align:right;" GF="N 13,2"></td>
												<td GH="90" GCol="text,WRK_ORDR_REMARK" style="text-align:left;"></td>
											</tr>
										</tbody>
									</table>
								</div>
							</div>
							<jsp:include page="/WEB-INF/jsp/common/commonBtnAuth.jsp">
								<jsp:param name="authCd" value="1" />
								<jsp:param name="showAuthCd" value="1,2,9,10" />
							</jsp:include>
						</div>
					</div>
					
					
					
					
					
<!-- 					<div class="content_layout tabs bottom_layout" style="height: 400px; margin-top: 20px;"> -->
					<div class="content_layout tabs bottom_layout" style="height: 300px; margin-top: 20px;">
						<ul class="tab tab_style02">
							<li><a href="#tab1-1"><span CL="STD_GRD_WRK23_3">자재입고현황</span></a></li>
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
									<table class="">
										<tbody id="gridListSub2">
											<tr CGRow="true">
												<td GH="40" GCol="rownum">1</td>
												<td GH="110" GCol="text,MATNR" style="text-align:center;"></td>
												<td GH="280" GCol="text,MATNR_NM" style="text-align:left;"></td>
												<td GH="90" GCol="text,PRDC_DT" GF='D' style="text-align:center;"></td>
												<td GH="90" GCol="text,SUPY" style="text-align:center;"></td>
												<td GH="90" GCol="text,VND_LOT_NO" style="text-align:center;"></td>
												<td GH="120" GCol="text,BARCODE_NO" style="text-align:center;"></td>
												<td GH="90" GCol="text,UNIT" style="text-align:center;"></td>
												<td GH="90" GCol="text,QTY" style="text-align:right;"  GF="N 13,2"></td>
												<td GH="90" GCol="text,RCVGDS_DT" GF='D' style="text-align:center;"></td>
												<td GH="90" GCol="text,DSTBT_DDLIN" GF='D' style="text-align:center;"></td>
											</tr>
										</tbody>
									</table>
								</div>
							</div>
							<jsp:include page="/WEB-INF/jsp/common/commonBtnAuth.jsp">
								<jsp:param name="authCd" value="1" />
								<jsp:param name="showAuthCd" value="1,2,9,10" />
							</jsp:include>
						</div>
					</div>
					
					
					
					
					
					<div class="content_layout tabs bottom_layout" style="height: 300px; margin-top: 20px;">
						<ul class="tab tab_style02">
							<li><a href="#tab1-1"><span CL="STD_GRD_WRK23_4">투입현황</span></a></li>
<!-- 							<li><a href="#tab1-2"><span>상세</span></a></li> -->
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
									<table class="">
										<tbody id="gridListSub3">
											<tr CGRow="true">
												<td GH="40" GCol="rownum">1</td>
												<td GH="90" GCol="text,INP_DT" GF='D' style="text-align:center;"></td>
												<td GH="110" GCol="text,MACH_NM" style="text-align:left;"></td>
												<td GH="90" GCol="text,LOT_NO" style="text-align:center;"></td>
												<td GH="120" GCol="text,IND_BCD" style="text-align:center;"></td>
												<td GH="90" GCol="text,INPT_SEQNO" style="text-align:right;"></td>
												<td GH="110" GCol="text,MATNR" style="text-align:center;"></td>
												<td GH="280" GCol="text,MATNR_NM" style="text-align:left;"></td>
												<td GH="90" GCol="text,UNIT" style="text-align:center;"></td>
												<td GH="90" GCol="text,INP_QTY" style="text-align:right;" GF="N 13,2"></td>
												<td GH="150" GCol="text,IND_BCD_M2" style="text-align:center;"></td>
												<td GH="110" GCol="text,LOT_NO_M2" style="text-align:center;"></td>
												<td GH="110" GCol="text,MATNR_M2" style="text-align:center;"></td>
												<td GH="80" GCol="text,CHG_FLG" style="text-align:center;"></td>
												<td GH="130" GCol="text,STR_DATE" style="text-align:center;"></td>
											</tr>
										</tbody>
									</table>
								</div>
							</div>
							<jsp:include page="/WEB-INF/jsp/common/commonBtnAuth.jsp">
								<jsp:param name="authCd" value="1" />
								<jsp:param name="showAuthCd" value="1,2,9,10" />
							</jsp:include>
						</div>
					</div>
					
					
					
					
					
					<div class="content_layout tabs bottom_layout" style="height: 300px; margin-top: 20px;">
						<ul class="tab tab_style02">
							<li><a href="#tab1-1"><span CL="STD_GRD_WRK23_5">실적현황</span></a></li>
<!-- 							<li><a href="#tab1-2"><span>상세</span></a></li> -->
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
									<table class="">
										<tbody id="gridListSub4">
											<tr CGRow="true">
												<td GH="40" GCol="rownum">1</td>
												<td GH="90" GCol="text,PRFM_DT" GF="D" style="text-align:center;"></td>
												<td GH="110" GCol="text,PROC_NM" style="text-align:left;"></td>
												<td GH="110" GCol="text,MACH_NM" style="text-align:left;"></td>
												<td GH="110" GCol="text,MACHINE" style="text-align:left;"></td>
												<td GH="90" GCol="text,LOT_NO" style="text-align:center;"></td>
												<td GH="120" GCol="text,IND_BCD" style="text-align:center;"></td>     
												<td GH="110" GCol="text,MATNR" style="text-align:center;"></td>       
												<td GH="280" GCol="text,MATNR_NM" style="text-align:left;"></td>    
												<td GH="90" GCol="text,PRODUNIT" style="text-align:center;">실적단위</td>   
												    
												<td GH="90" GCol="text,PLT_QTY" style="text-align:right;" GF="N 13,1"></td>     
												<td GH="90" GCol="text,BOX_QTY" style="text-align:right;" GF="N 13"></td>     
												<td GH="90" GCol="text,BAG_QTY" style="text-align:right;" GF="N 13"></td>     
												<td GH="90" GCol="text,EA_QTY" style="text-align:right;" GF="N 13"></td>      
												<td GH="90" GCol="text,WGT" style="text-align:right;" GF="N 13,2"></td>     
												<td GH="90" GCol="text,WUNIT" style="text-align:center;">중량단위</td>        
												       
												<td GH="90" GCol="text,ROLLCNT" style="text-align:right;" GF="N 13,3">권치수</td>    
												<td GH="90" GCol="text,ROLLUNIT" style="text-align:center;"></td>       
												<td GH="90 연수" GCol="text,R_PRFM_QTY" style="text-align:right;" GF="N 13,3">연수</td>     
												<td GH="90" GCol="text,RUNIT" style="text-align:center;">연수단위</td>    
												       
												<td GH="90" GCol="text,VLEN" style="text-align:right;" GF="N 4"></td>        
												<td GH="90" GCol="text,WLEN" style="text-align:right;" GF="N 4"></td>        
												<td GH="140" GCol="text,PRD_STR_DATE" style="text-align:center;"></td>
												<td GH="140" GCol="text,PRD_END_DATE" style="text-align:center;"></td>
												<td GH="90" GCol="text,WRK_CLASS" style="text-align:center;"></td>   
												<td GH="90" GCol="text,WRK_SHIFT" style="text-align:center;"></td>
											</tr>
										</tbody>
									</table>
								</div>
							</div>
							<jsp:include page="/WEB-INF/jsp/common/commonBtnAuth.jsp">
								<jsp:param name="authCd" value="1" />
								<jsp:param name="showAuthCd" value="1,2,9,10" />
							</jsp:include>
						</div>
					</div>
					
					
					
					
					
					<div class="content_layout tabs bottom_layout" style="height: 300px; margin-top: 20px;">
						<ul class="tab tab_style02">
							<li><a href="#tab1-1"><span CL="STD_GRD_WRK23_6">품질현황(부적합)</span></a></li>
<!-- 							<li><a href="#tab1-2"><span>상세</span></a></li> -->
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
									<table class="">
										<tbody id="gridListSub5">
											<tr CGRow="true">
												<td GH="40" GCol="rownum">1</td>
												<td GH="130" GCol="text,INSP_DATE" style="text-align:center;"></td>
												<td GH="120" GCol="text,INSP_TYPE" style="text-align:left;"></td>
												<td GH="110" GCol="text,MATNR" style="text-align:center;"></td>
												<td GH="280" GCol="text,MATNR_NM" style="text-align:left;"></td>
												<td GH="90" GCol="text,LOT_NO" style="text-align:center;"></td>
												<td GH="120" GCol="text,IND_BCD" style="text-align:center;"></td>
												<td GH="90" GCol="text,UNIT" style="text-align:center;"></td>
												<td GH="90" GCol="text,FNL_JDGM" style="text-align:center;"></td>
												<td GH="90" GCol="text,UCFMTY_AMT" style="text-align:right;" GF="N 13"></td>
												<td GH="90" GCol="text,PRC_MTD" style="text-align:center;"></td>
												<td GH="110" GCol="text,RMK" style="text-align:left;"></td>
											</tr>
										</tbody>
									</table>
								</div>
							</div>
							<jsp:include page="/WEB-INF/jsp/common/commonBtnAuth.jsp">
								<jsp:param name="authCd" value="1" />
								<jsp:param name="showAuthCd" value="1,2,9,10" />
							</jsp:include>
						</div>
					</div>
					
					
					
					
					
					<div class="content_layout tabs bottom_layout" style="height: 300px; margin-top: 20px;">
						<ul class="tab tab_style02">
							<li><a href="#tab1-1"><span CL="STD_GRD_WRK23_7">완제품 입고현황(WMS)</span></a></li>
<!-- 							<li><a href="#tab1-2"><span>상세</span></a></li> -->
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
									<table class="">
										<tbody id="gridListSub6">
											<tr CGRow="true">
												<td GH="40" GCol="rownum">1</td>
												<td GH="90" GCol="text,RCVGDS_DT" style="text-align:center;"></td>
												<td GH="120" GCol="text,IND_BCD" style="text-align:center;"></td>
												<td GH="110" GCol="text,MATNR" style="text-align:center;"></td>
												<td GH="280" GCol="text,MATNR_NM" style="text-align:left;"></td>
												<td GH="90" GCol="text,UNIT" style="text-align:center;"></td>
												<td GH='100' Gcol='text,QTY' GF='N 13,1'>수량</td>
												<td GH="90" GCol="text,PLT_QTY" style="text-align:right;" GF="N 13,1"></td>     
												<td GH="90" GCol="text,BOX_QTY" style="text-align:right;" GF="N 13"></td>     
												<td GH="90" GCol="text,BAG_QTY" style="text-align:right;" GF="N 13"></td>     
												<td GH="90" GCol="text,EA_QTY" style="text-align:right;" GF="N 13"></td>      
												<td GH="90" GCol="text,WGT" style="text-align:right;" GF="N 13,2"></td>   
												<td GH="90" GCol="text,PCODE_NM" style="text-align:left;"></td>
												<td GH="90" GCol="text,BS_WGT" style="text-align:right;" GF="N 20"></td>
												<td GH="90" GCol="text,VLEN" style="text-align:right;" GF="N 4"></td>        
												<td GH="90" GCol="text,WLEN" style="text-align:right;" GF="N 4"></td> 
												<td GH="90" GCol="text,CON_TYPE" style="text-align:center;"></td>
												<td GH="90" GCol="text,PACKTYPE" style="text-align:center;"></td>
												<td GH="90" GCol="text,EMPLY_NM" style="text-align:center;"></td>
												<td GH="90" GCol="text,REQ_STA" style="text-align:center;"></td>
											</tr>
										</tbody>
									</table>
								</div>
							</div>
							<jsp:include page="/WEB-INF/jsp/common/commonBtnAuth.jsp">
								<jsp:param name="authCd" value="1" />
								<jsp:param name="showAuthCd" value="1,2,9,10" />
							</jsp:include>
						</div>
					</div>
				</div>
			</div>
		</div>
	</div>
</div>
<!-- // content -->
<%@ include file="/common/include/webdek/bottom.jsp" %>
</body>
</html>