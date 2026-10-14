<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>MES</title>
<%@ include file="/common/include/webdek/head.jsp" %>
<script type="text/javascript">
	$(document).ready(function(){
		gridList.setGrid({
			id : "gridList",
			url : "/mes/Work/WRK42/json/datalist.data",
			bigdata : false,
	    	colHoldType : true,
	    	colHold : "WERKS,BARCOD,LOT_NO,RCDTXT,PRFM_BCD,WRK_DATE"
		});
		
		gridList.setGrid({
			id : "gridList2",
			url : "/mes/Work/WRK42/json/datalist.data",
			bigdata : false,
	    	colHoldType : true,
	    	colHold : "WERKS,BARCOD,LOT_NO,RCDTXT,PRFM_BCD,WRK_DATE"
		});
		
		$("#tab1-1").show();
		$("#tab1-2").hide();
	});
	
	function searchList(){
		if(validate.check("searchArea")){
			var param = inputList.setRangeParam("searchArea");
			/* var ind_bcd = param.get("IND_BCD");
			var lot_no = param.get("LOT_NO"); */
			
			/* var range_data_param = range.get("RANGE_DATA_PARAM");
			var prfm_dt = range_data_param.get("INP_DT_Range");*/
			
			var ind_bcd = param.get('RANGE_DATA_PARAM').get('IND_BCD_Single');
			var lot_no = param.get('RANGE_DATA_PARAM').get('LOT_NO_Single');
			
			if(ind_bcd == undefined && lot_no == undefined)
				{
					return alert('바코드, LOT번호 중 하나는 입력되어야 합니다.');
				}
			
				
			if(param.get("WERKS") == "P100"){
				$("#tab1-1").show();
				$("#tab1-2").hide();
				
				param.put("P_TYPE","LIST1");
				//param.put("IND_BCD", $("#IND_BCD").val()) // 개별바코드
				
				gridList.gridList({
					id : "gridList",
					param : param
				});
			} else{
				$("#tab1-1").hide();
				$("#tab1-2").show();
				
				param.put("P_TYPE","LIST2");
				//param.put("IND_BCD", $("#IND_BCD").val()) // 개별바코드
				
				gridList.gridList({
					id : "gridList2",
					param : param
				});
			}
		}
	}

	
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
	<div class="content_inner">
		<%@ include file="/common/include/webdek/title.jsp" %>
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
						<dt CL="플랜트">플랜트</dt>
						<dd>
							<input type="text" id="WERKS" name="WERKS" UIInput="S,PLANT" UIFormat="U" validate="required"/>
						</dd>
					</dl>
					<dl>
						<dt CL="STD_IND_BCD">개별바코드</dt>
						<dd>
							<input type="text" class="input" id="IND_BCD" name="IND_BCD" maxlength="20" UIInput="SR,INDBCD" UIFormat="U"/>
						</dd>
					</dl>
					<dl>
						<dt CL="LOT번호">LOT번호</dt>
						<dd>
							<!-- 2023-03-13(월요일) 안상현, LOT번호 RANGE 검색 추가 -->
							<input type="text" id="LOT_NO" class="input" name="LOT_NO" maxlength="10" UIInput="SR" UIFormat="U"/>
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
					<li><a href="#tab1-1"><span CL="STD_GRD_WRK42">리스트</span></a></li>
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
							<table class="table_b">
								<tbody id="gridList">
									<tr CGRow="true">
										<td GH="40" GCol="rownum">1</td>
										<td GH="100" Gcol="text,WERKS" style="text-align:center;">플랜트</td>	
										<td GH="160" GCol="text,BARCOD">바코드</td>
										<td GH="100" GCol="text,LOT_NO">LOT번호</td>
										<td GH="140" GCol="text,RCDTXT">이력내역</td>
										<td GH="140" GCol="text,PRFM_BCD">실적바코드</td>
										<td GH="140" GCol="text,WRK_DATE" style="text-align:center;">작업일시</td>
										<td GH="100" GCol="text,WRKNM">작업자</td>
										<td GH="100" GCol="text,WRK_CLASS" style="text-align:center;">반</td>
										<td GH="100" GCol="text,STOR_LOC_CD" style="text-align:center;">저장위치코드</td>
										<td GH="120" GCol="text,MACH_NM">설비명</td>
										<td GH="160" GCol="text,INP_MACH_NM">투입설비명</td>
										<td GH="100" GCol="text,PRFM_ROLLCNT" GF="N 13,0">실적권치수</td>
										<td GH="100" GCol="text,ROLLUNIT">권치수단위</td>
										
										<td GH="100" GCol="text,PRFM_PCNT" GF="N 13,1">실적연수</td>
										<td GH="100" GCol="text,RUNIT">연수단위</td>
										
										<td GH="100" GCol="text,PRFM_MCNT" GF="N 13,0">실적매수</td>
										<td GH="100" GCol="text,EAUNIT">매수단위</td>
										
										<td GH="100" GCol="text,PRFM_WGT" GF="N 13,3">실적중량</td>
										<td GH="100" GCol="text,WUNIT">중량단위</td>
										
										<!-- <td GH="100 폐품권치수" GCol="text,PRFM_DISPO_ROLLCNT" GF="N 13,0">실적폐품M</td>
										<td GH="100" GCol="text,DISPO_ROLLUNIT">폐품권치수단위</td>
										
										<td GH="100 폐품연수" GCol="text,PRFM_DISPO_PCNT" GF="N 13,3">실적폐품연수</td>
										<td GH="100" GCol="text,DISPO_RUNIT">폐품연수단위</td>
										
										<td GH="100 폐품중량" GCol="text,PRFM_DISPO_WGT" GF="N 13,3">실적폐품KG</td>
										<td GH="100" GCol="text,DISPO_WUNIT">폐품중량단위</td> -->
										
										<td GH="100" GCol="text,TM" GF="N 10">가동시간</td>
										<td GH="100" GCol="text,BCD_STA">바코드상태</td>
										<td GH="100" GCol="text,ERP_SDOC_NO">ERP확정번호</td>
										<td GH="100" GCol="text,ERP_SDOC_SEQNO">ERP확정SEQ</td>
										<td GH="100" GCol="text,END_YN" style="text-align:center;">자기완료</td>
										<td GH="100" GCol="text,UP_END_YN" style="text-align:center;">상위완료</td>
										<td GH="340" GCol="text,ERP_PRD_ERR_MSG">ERP PP(생산)에러메세지</td>
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
				<div class="table_box section" id="tab1-2">
					<div class="table_list01">
						<div class="scroll">
							<table class="table_b">
								<tbody id="gridList2">
									<tr CGRow="true">
										<td GH="40" GCol="rownum">1</td>	
										<td GH="100" Gcol="text,WERKS" style="text-align:center;">플랜트</td>
										<td GH="160" GCol="text,BARCOD">바코드</td>
										<td GH="100" GCol="text,LOT_NO">LOT번호</td>
										<td GH="140" GCol="text,RCDTXT">이력내역</td>
										<td GH="140" GCol="text,PRFM_BCD">실적바코드</td>
										<td GH="140" GCol="text,WRK_DATE" style="text-align:center;">작업일시</td>
										<td GH="100" GCol="text,WRKNM">작업자</td>
										<td GH="100" GCol="text,WRK_CLASS" style="text-align:center;">반</td>
										<td GH="100" GCol="text,STOR_LOC_CD" style="text-align:center;">저장위치코드</td>
										<td GH="120" GCol="text,MACH_NM">설비명</td>
										<td GH="100" GCol="text,PRFM_ROLLCNT" GF="N 13,0">실적권치수</td>
										<td GH="100" GCol="text,ROLLUNIT">권치수단위</td>
										
										<td GH="100" GCol="text,PRFM_WGT" GF="N 13,3">실적중량</td>
										<td GH="100" GCol="text,WUNIT">중량단위</td>
										
										<td GH="100" GCol="text,PLT_QTY" GF="N 13,1">PLT수량</td>
										<td GH="100" GCol="text,BOX_QTY" GF="N 13,0">BOX수량</td>
										<td GH="100" GCol="text,BAG_QTY" GF="N 13,0">BAG수량</td>
										<td GH="100" GCol="text,EA_QTY" GF="N 13,0">EA수량</td>
										<td GH="100" GCol="text,TM" GF="N 10">가동시간</td>
										<td GH="100" GCol="text,BCD_STA">바코드상태</td>
										<td GH="100" GCol="text,ERP_SDOC_NO">ERP확정번호</td>
										<td GH="100" GCol="text,ERP_SDOC_SEQNO">ERP확정SEQ</td>
										<td GH="100" GCol="text,END_YN" style="text-align:center;">자기완료</td>
										<td GH="100" GCol="text,UP_END_YN" style="text-align:center;">상위완료</td>
										<td GH="340" GCol="text,ERP_PRD_ERR_MSG">ERP PP(생산)에러메세지</td>
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