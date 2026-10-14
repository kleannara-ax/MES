<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Grid default</title>
<%@ include file="/common/include/webdek/head.jsp" %>
<link rel="stylesheet" type="text/css" href="/common/theme/webdek/css/demo_layout.css">
<%@ include file="/WEB-INF/jsp/common/commonApprvForm.jsp" %>
<script type="text/javascript">
	$(document).ready(function(){
		gridList.setGrid({
			id : "gridList",
	    	url : "/mes/Work/WRK08/json/datalist.data",
	    	bigdata : false,
	    	colHoldType : true,
	    	colHold : "WERKS,STOR_LOC_CD,STOR_LOC_NM,MATNR,MATNR_NM"
	    });
	});
	
	function searchList(){
		if(validate.check("searchArea")){
			var param = inputList.setRangeParam("searchArea");
	
			param.put("P_TYPE","LIST");
			
			gridList.gridList({
		    	id : "gridList",
		    	param : param
		    });
		}
	}


	// 결제 띄우기
	function dataApprv() {
		var list = gridList.getSelectData("gridList");
		if(list == 0) {
			alert('결재할 데이터를 선택해 주세요.')
			return
		}
		// var focusNum = gridList.getFocusRowNum("gridList");
		// console.log(focusNum)
		// var row = gridList.getRowData("gridList", focusNum);
		// console.log(row);
		// var apvr_sta = row.get("APVR_STA");

		for(var info of list) {
			if (info.get('APVR_STA') == "1" || info.get('APVR_STA') == "2" || info.get('APVR_STA') == "3") {
				alert("결재중건을 제외하고 결제하셔야 합니다.");
				return;
			}
		}
		// var DOC_ID= row.get('DOC_ID')==undefined?'':row.get("DOC_ID");
		// console.log('DOC_ID===',DOC_ID);
		var DOC_ID = '';
		var HTML = "";
		if(!DOC_ID){
			var param = new DataMap();
			param.put("list", list);
			param.put("TYPE", "MES003");
			var json = netUtil.sendData({
				url : "/mes/gw/doc/json/data.data",
				param : param
			});
			if(json){
				if(json.data){
					if(json.data.message && json.data.message.length > 0) {
						alert(json.data.message)
						return
					}
					DOC_ID = json.data.DOC_ID
					HTML = json.data.HTML;
				}
			}
		}
		if(!DOC_ID || !HTML) {
			alert('양식에 넣을 데이터가 없습니다.')
			return;
		}

		openApprvPop('MES003',DOC_ID,HTML)
	}

	function gridListEventRowDblclick(gridId, rowNum){
		if(gridId === "gridList") {
			var focusNum = gridList.getFocusRowNum("gridList");
			 console.log(focusNum)
			var row = gridList.getRowData("gridList", focusNum);
			 console.log(row);
			var apvr_sta = row.get("APVR_STA");
			var DOC_ID = row.get("DOC_ID");//'M00000247';//row.get("DOC_ID");
			var HTML = "";
			if(apvr_sta == '1' || apvr_sta == '2' || apvr_sta == '3' ) {
				var param = new DataMap();
				param.put("DOC_ID", DOC_ID);
				param.put("aprv", "VIEW");
				param.put("TYPE", "MES003");
				var json = netUtil.sendData({
					url : "/mes/gw/doc/json/data.data",
					param : param
				});
				if(json){
					if(json.data){
						DOC_ID = json.data.DOC_ID
						HTML = json.data.HTML;
					}
				}
			}else {
				alert('결제건이 아닙니다.')
				return
			}
			if(!DOC_ID || !HTML) {
				alert('양식에 넣을 데이터가 없습니다.')
				return;
			}

			openApprvPop('MES003',DOC_ID,HTML)
		}
	}


	function pass(){
		if(gridList.getGridDataCount("gridList") == 0){
			alert("데이터를 조회하세요.");
			
			return;
		}
		if(gridList.getSelectData("gridList") == 0){
			alert("데이터를 선택하세요.");
			
			return;
		}
		dataApprv()
		//if(gridList.validationCheck("gridList", "data")){
			// var list = gridList.getSelectData("gridList");
			//
			// var param = new DataMap();
			//
			// param.put("P_TYPE","SAVE");
			// param.put("list", list);
			//
			// var json = netUtil.sendData({
			// 	url : "/mes/Work/WRK08/json/datalist.data",
			// 	param : param
			// });
			// if(json){
			// 	if(json.data){
			// 		alert("결재되었습니다.");
			// 		searchList();
			// 		}
			// 	}
			// }
	}
	
	function cancel(){
		if(gridList.getGridDataCount("gridList") == 0){
			alert("데이터를 조회하세요.");
			
			return;
		}
		if(gridList.getSelectData("gridList") == 0){
			alert("데이터를 선택하세요.");
			
			return;
		}
		if(gridList.validationCheck("gridList", "data")){
			var list = gridList.getSelectData("gridList");

			var param = new DataMap();
			
			param.put("P_TYPE","SAVE1");
			param.put("list", list);
			
			var json = netUtil.sendData({
				url : "/mes/Work/WRK08/json/datalist.data",
				param : param
			});
			if(json){
				if(json.data){
					alert("반려되었습니다.");
					searchList();
					}
				}
			}
		}
	
	function fail(){
		var json = netUtil.sendData({
    		module : 'mes',
    		command : 'SYSTEMCHECK',
    		sendType : 'map'
    	});
    	
    	if(json.data.USE_YN == 'Y'){
    		alert('시스템 점검 중입니다. 1 ~ 5분 동안 잠시만 기다려 주세요.');
    		return;
    	}
		
		if(gridList.getGridDataCount("gridList") == 0){
			alert("데이터를 조회하세요.");
			
			return;
		}
		if(gridList.getSelectData("gridList") == 0){
			alert("데이터를 선택하세요.");
			
			return;
		}
		
		if(gridList.validationCheck("gridList", "data")){
			var list = gridList.getSelectData("gridList");
			
			for(var i = 0; i < list.length; i++){
				var apvrsta = list[i].get("APVR_STA");
				
				if(apvrsta != "2"){
					alert("결제 완료된 항목만 폐기처리 가능");
					return;
				}
			}
			
			var param = new DataMap();
			
			param.put("P_TYPE","SAVE2");
			param.put("list", list);
		
			if(!commonUtil.msgConfirm("폐기 처리하시겠습니까?")){
				return;
			}	
			
			netUtil.send({
				url : "/mes/Work/WRK08/json/datalist.data",
				param : param,
				successFunction : "savesuccessCallBack"
			});
		}
	}
	
	function savesuccessCallBack(json){
		if(json){
			if(json.P_SUCCESS == 'Y'){
			   //20220724 여한진 RFC 호출 SAP에 재고이전
			   var param = new DataMap();
	           
	           param.put("IFID", "MES_IF_131");
	           param.put("DOC_NO", json.DOC_NO);
	           
	           var json2 = netUtil.sendData({
	        	   url : "/mes/erpif/json/sendIF.data",
	           	   param : param
	           });
	  		
	           if(json2){
	        	   if(json2.data == "SUCCESS"){
	           	   	  alert("폐기 처리되었습니다. ");
		          	  searchList();
	           	   }else{
	           			alert('(SAP 재고이전) ' + json2.data);
	           			searchList();
	           	   }
	    	   }
			}else{
				alert(json.ERR_MSG);
			}
		}
	}
	
	function commonBtnClick(btnName){
		//commonUtil.debugMsg("commonBtnClick : ", arguments);
		if(btnName == "Search"){
			searchList();
		}else if(btnName == "Pass"){
			pass();
		
		}else if(btnName == "Fail"){
			fail();
		
		}else if(btnName == "Cancel"){
			cancel();
		
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
<%--					<input type="button" id="button-0-4" CB="Cancel DELETE BTN_BACK" />--%>
					<input type="button" id="button-0-3" CB="Pass SAVE BTN_APPROVE"/> 
					<input type="button" id="button-0-4" CB="Fail DELETE BTN_DISCARD" /> 			
				</div>
			</div>
			<div class="search_inner">
				<div class="search_wrap ">
					<dl>
						<dt CL="STD_PLANT">플랜트</dt>
						<dd>
							<input type="text" class="input" name="WERKS" validate="required" id="WERKS" UIInput="S,PLANT" UIFormat="U"/>
						</dd>
					</dl>
					
					<dl>
						<dt>실적일자</dt>
						<dd>
							<input type="text" class="input" name="PRFM_DT" UIInput="B" UIFormat="C M1"/>
						</dd>
					</dl>
					
					<dl>
						<dt>자재코드</dt>
						<dd>
							<input type="text" class="input" name="MATNR"  id="MATNR" UIInput="SR,MATKY" UIFormat="U"/>
						</dd>
					</dl>
					
					<dl>
						<dt>LOT번호</dt>
						<dd>
							<input type="text" class="input" name="LOT_NO"  id="LOT_NO" UIInput="SR" UIFormat="U"/>
						</dd>
					</dl>
					
					<dl>
						<dt>결재상태</dt>
						<dd>
							<select class="input" name="APVR_STA" id="APVR_STA" CommonCombo="APVR_STA">
								<option value=""></option>
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
					<li><a href="#tab1-1"><span>재고정보</span></a></li>
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
										<td GH="40" GCol="rowCheck"></td>
										<td GH="100" GCol="text,WERKS"  style="text-align:center;"></td>		<!-- 플랜트 -->
										<td GH="100" GCol="text,STOR_LOC_CD" style="text-align:center;">저장위치</td>
										<td GH="100" GCol="text,STOR_LOC_NM">저장위치명</td>
										<td GH="100" GCol="text,MATNR" style="text-align:center;">자재코드</td>		
										<td GH="180" GCol="text,MATNR_NM" >자재코드명</td>		
										<td GH="100" GCol="text,LOT_NO" style="text-align:center;">lot번호</td>		
										<td GH="140" GCol="text,IND_BCD" style="text-align:center;"></td>		<!-- 개별바코드 -->	
										<td GH="140" GCol="text,PRFM_DT" GF='D' style="text-align:center;">실적일자</td>		
										<td GH="40" GCol="text,UNIT" style="text-align:center;">단위</td>		
										<td GH="100" GCol="text,UNIT_NM">단위명</td>		
										<td GH="100" GCol="text,DISPO_QTY" GF='N 13,3'>폐기수량</td>		
										<td GH="60" GCol="text,STCK_STA" style="text-align:center;">재고상태</td>	
										<td GH="160" GCol="text,STCK_STA_NM">재고상태명</td>		
										<td GH="60" GCol="text,APVR_STA" style="text-align:center;">결재상태</td>	
										<td GH="160" GCol="text,APVR_STA_NM">결재상태명</td>		
										<td GH="100" GCol="text,CFRM_ID">승인자</td>
										<td GH="140" GCol="text,CFRM_DATE" style="text-align:center;">승인일시</td>	
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