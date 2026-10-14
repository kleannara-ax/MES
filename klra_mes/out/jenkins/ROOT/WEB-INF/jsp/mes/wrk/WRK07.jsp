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
	gridLayoutPadding = 160;
	$(document).ready(function(){
		gridList.setGrid({
			id : "gridList",
	    	url : "/mes/Work/WRK07/json/datalist.data",
	    	bigdata : false
	    });
		
		gridList.setGrid({
			id : "gridList2",
	    	url : "/mes/Work/WRK07/json/datalist.data",
	    	bigdata : false
	    });
	});

	// 조회
	function searchList() {
		if (validate.check("searchArea")) {
			gridList.resetGrid("gridList2");
			var range = inputList.setRangeParam("searchArea");
			var range_data_param = range.get("RANGE_DATA_PARAM");
			var prfm_dt = range_data_param.get("WRK_REQ_DT_Range");
			var date = prfm_dt.split('↓');
			var SDate = date[1];
			var EDate = date[2];
			
			var param = new DataMap();
			param.put("P_TYPE", "LIST");
			param.put("SDATE", SDate);
			param.put("EDATE", EDate);
			param.put("WERKS",$("#WERKS").val().toUpperCase());
	
			gridList.gridList({
				id : "gridList",
				param : param
			});
	
		}
	}
	
	function commonBtnClick(btnName){
		//commonUtil.debugMsg("commonBtnClick : ", arguments);
		if(btnName == "Search"){
			searchList();
		}else if(btnName == "Save"){
			saveData();
		}else if(btnName == "Approve"){
			approve();
		}else if(btnName == "Decide"){
			decide();
		}else if(btnName == "Back"){
			back();
		}else if(btnName == "DecideCancel"){
			decidecancel();
		}
	}
	
	
	
	function searchSubList(headRowNum){
		var rowVal1 = gridList.getColData("gridList", headRowNum, "WERKS");
		var rowVal2 = gridList.getColData("gridList", headRowNum, "WRK_ORDR_NO");
		var param = inputList.setRangeParam("searchArea");
		param.put("P_TYPE", "SUB_LIST");
		param.put("WERKS", rowVal1);
		param.put("WRK_ORDR_NO", rowVal2);

		gridList.gridList({
			id : "gridList2",
			param : param
		});
		
		lastFocusNum = headRowNum;
	}
	
	var lastFocusNum = 0;
	
	function gridListEventRowDblclick(gridId, rowNum){
		if(gridId == "gridList"){
			searchSubList(rowNum);
		}
	}
	
	function saveData(){
		
			if(gridList.getGridDataCount("gridList") == 0){
				alert("데이터를 조회하세요");
				
				return;
			}	
		
		
			if(gridList.validationCheck("gridList", "all")){
				var rowVal1 = gridList.getColData("gridList", lastFocusNum, "WERKS");
				var rowVal2 = gridList.getColData("gridList", lastFocusNum, "WRK_ORDR_NO");
				
				var param = new DataMap();
				param.put("P_TYPE","SAVE");

				param.put("WERKS", rowVal1);
				param.put("WRK_ORDR_NO", rowVal2);
				
				var json = netUtil.sendData({
					url : "/mes/Work/WRK07/json/datalist.data",
					param : param
				});
				
				if(json){
					if(json.data){
						searchList();
					}
				}
			}
		}
	
	function approve(){
		
		if(gridList.getGridDataCount("gridList") == 0){
			alert("데이터를 조회하세요");
			
			return;
		}
		
		if(gridList.validationCheck("gridList", "all")){
			var rowVal1 = gridList.getColData("gridList", lastFocusNum, "WERKS");
			var rowVal2 = gridList.getColData("gridList", lastFocusNum, "WRK_ORDR_NO");
			
			var param = new DataMap();
			param.put("P_TYPE","SAVE1");

			param.put("WERKS", rowVal1);
			param.put("WRK_ORDR_NO", rowVal2);
			
			var json = netUtil.sendData({
				url : "/mes/Work/WRK07/json/datalist.data",
				param : param
			});
			
			if(json){
				if(json.data){
					searchList();
				}
			}
		}
	}
	
	function decide(){
		
		if(gridList.getGridDataCount("gridList") == 0){
			alert("데이터를 조회하세요");
			
			return;
		}
		
		if(gridList.validationCheck("gridList", "all")){
			var rowVal1 = gridList.getColData("gridList", lastFocusNum, "WERKS");
			var rowVal2 = gridList.getColData("gridList", lastFocusNum, "WRK_ORDR_NO");
			
			var param = new DataMap();
			param.put("P_TYPE","SAVE3");

			param.put("WERKS", rowVal1);
			param.put("WRK_ORDR_NO", rowVal2);
			
			var json = netUtil.sendData({
				url : "/mes/Work/WRK07/json/datalist.data",
				param : param
			});
			
			if(json){
				if(json.data){
					searchList();
				}
			}
		}
	}
	
	function back(){
		
		if(gridList.getGridDataCount("gridList") == 0){
			alert("데이터를 조회하세요");
			
			return;
		}
		
		if(gridList.validationCheck("gridList", "all")){
			var rowVal1 = gridList.getColData("gridList", lastFocusNum, "WERKS");
			var rowVal2 = gridList.getColData("gridList", lastFocusNum, "WRK_ORDR_NO");
			
			var param = new DataMap();
			param.put("P_TYPE","SAVE2");

			param.put("WERKS", rowVal1);
			param.put("WRK_ORDR_NO", rowVal2);
			
			var json = netUtil.sendData({
				url : "/mes/Work/WRK07/json/datalist.data",
				param : param
			});
			
			if(json){
				if(json.data){
					searchList();
				}
			}
		}
	}
	
	function decidecancel(){
		
		if(gridList.getGridDataCount("gridList") == 0){
			alert("데이터를 조회하세요");
			
			return;
		}
		
		if(gridList.validationCheck("gridList", "all")){
			var rowVal1 = gridList.getColData("gridList", lastFocusNum, "WERKS");
			var rowVal2 = gridList.getColData("gridList", lastFocusNum, "WRK_ORDR_NO");
			
			var param = new DataMap();
			param.put("P_TYPE","SAVE4");

			param.put("WERKS", rowVal1);
			param.put("WRK_ORDR_NO", rowVal2);
			
			var json = netUtil.sendData({
				url : "/mes/Work/WRK07/json/datalist.data",
				param : param
			});
			
			if(json){
				if(json.data){
					searchList();
				}
			}
		}
	}
</script>
</head>
<body>
<%@ include file="/common/include/webdek/layout.jsp" %>
<!-- content -->
<div class="content_wrap" style="min-width: 1384px;">
	<div class="content_inner">
		<%@ include file="/common/include/webdek/title.jsp" %>
		<div class="content_serch" id="searchArea">
			<div class="btn_wrap">
				<div class="fl_l">
				</div>
				<div class="fl_r">
					<input type="button" id="button-0-1" CB="Search SEARCH BTN_SEARCH" />
					<input type="button" id="button-0-2" CB="Back DELETE BTN_BACK" />
					<input type="button" id="button-0-2" CB="Approve SAVE BTN_APPROVE" />
					<input type="button" id="button-0-2" CB="Decide SAVE BTN_DECIDE" />
					<input type="button" id="button-0-2" CB="DecideCancel DELETE BTN_DECIDECANCEL" />
					<!-- <input type="button" id="button-0-2" CB="Save SAVE BTN_SAVE" /> -->
				</div>
			</div>
			<div class="search_inner">
				<div class="search_wrap ">
					<dl>
						<dt CL="STD_PLANT">플랜트</dt>
						<dd>
							<input type="text" class="input" id="WERKS" name="WERKS" UIInput="S,PLANT" UIFormat="U" validate="required"/>
						</dd>
					</dl>
					<dl>
						<dt>지시요청일자</dt>
						<dd>
							<input type="text" class="input" name="WRK_REQ_DT" UIInput="B" UIFormat="C M1"/>
						</dd>
					</dl>
					
				</div>
				<div class="btn_tab">
					<input type="button" class="btn_more" value="more" onclick="searchMore()"/>
				</div>
			</div>
		</div>
        <div class="search_next_wrap">
			<div class="content-horizontal-wrap" >	
				<div class="content_layout tabs content_left">
					<ul class="tab tab_style02">
						<li><a href="#tab1-1"><span>재고실사지시정보</span></a></li>
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
								<table class="table_c">
									<tbody id="gridList">
										<tr CGRow="true">
											<td GH="40" GCol="rownum">1</td>
											<td GH="40" GCol="rowCheck"></td>
											<td GH="100" GCol="text,WERKS" style="text-align:center;"></td>			<!-- 플랜트 -->
											<td GH="100" GCol="text,WRK_ORDR_NO" style="text-align:center;"></td>			<!-- 지시번호 -->
											<td GH="140" GCol="text,WRK_REQ_DT" GF='D' style="text-align:center;"></td>	<!-- 지시일자 -->
											<td GH="0" GCol="text,APVR_STA" ></td>	<!-- 결재상태 -->
											<td GH="200" GCol="text,APVR_STA_NM" ></td>	<!-- 결재상태명 -->
											<td GH="100" GCol="text,REAL_INSP_DIV_NM"></td>			<!-- 실사구분명 -->
											<td GH="100" GCol="text,REAL_INSP_RMK"></td>			<!-- 실사사유 -->
											<td GH="140" GCol="text,START_DT" GF='D' style="text-align:center;"></td>	<!-- 시작일 -->
											<td GH="140" GCol="text,END_DT" GF='D' style="text-align:center;"></td>	<!-- 완료일 -->
											
											<td GH="100" GCol="text,STOR_LOC_CD" style="text-align:center;"></td><!-- 저장위치 -->
											<td GH="100" GCol="text,STOR_LOC_NM"></td>			<!-- 저장위치명-->
											
											<td GH="100" GCol="text,APPRNM" ></td>	<!-- 승인자명 -->
											<td GH="140" GCol="text,APPR_DT" GF='D' style="text-align:center;"></td>	<!-- 승인일자 -->
											
											<td GH="100" GCol="text,WRK_ORDR_RMK"></td>			<!-- 비고 -->						
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
				<div class="content_layout tabs content_right">
					<ul class="tab tab_style02">
						<li><a href="#tab1-1"><span>재고실사정보</span></a></li>
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
								<table class="table_c">
									<tbody id="gridList2">
										<tr CGRow="true">
											<td GH="40" GCol="rownum">1</td>
											<td GH="40" GCol="rowCheck"></td>
											<td GH="0" GCol="text,STOR_LOC_CD" style="text-align:center;"></td>			<!-- 저장위치 -->
											<td GH="0" GCol="text,STOR_LOC_NM"></td>			<!-- 저장위치명-->
											<td GH="180" GCol="text,MATNR" style="text-align:center;"></td>			<!-- 자재 -->
											<td GH="300" GCol="text,MATNR_NM"></td>			<!-- 자재명 -->
											<td GH="140" GCol="text,IND_BCD" style="text-align:center;"></td>			<!-- 바코드-->
											<td GH="100" GCol="text,UNIT" style="text-align:center;"></td>			<!-- 단위 -->
											<td GH="100" GCol="text,UNIT_NM"></td>			<!-- 단위명 -->
											<td GH="100" GCol="text,STCK_QTY" GF="N 13,3"></td>			<!-- 재고수량 -->
											<td GH="100" GCol="text,REAL_INSP_QTY" GF="N 13,3"></td>			<!-- 실사수량 -->
											<td GH="100" GCol="text,DIFF_QTY" GF="N 13,3"></td>			<!-- 차이수량 -->
											
											<td GH="140" GCol="text,REGDATE" style="text-align:center;"></td> 		<!-- 생성일자 -->										
											<td GH="100" GCol="text,REGNM"></td> 				<!-- 생성자명 -->
											<td GH="140" GCol="text,UPDDATE" style="text-align:center;"></td>		<!-- 수정일자 -->
											<td GH="100" GCol="text,UPDNM"></td> 				<!-- 수정자명 -->								
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
			</div>
		</div>
	</div>
</div>
<!-- // content -->
<%@ include file="/common/include/webdek/bottom.jsp" %>
</body>
</html>
