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
			url:"/mes/Inv/INV05/json/datalist.data",
			bigdata : false,
			colorType : true
		})
		
		gridList.setGrid({
			id : "gridList2",
			url:"/mes/Inv/INV05/json/datalist.data",
			bigdata : false
		})
	});
	
	/* function searchList() {
		if (validate.check("searchArea")) {
			var param = inputList.setRangeParam("searchArea");
			/* var range_data_param = range.get("RANGE_DATA_PARAM");
			var prfm_dt = range_data_param.get("INP_DT_Range");
			var date = prfm_dt.split('↓');
			var SDate = date[1];
			var EDate = date[2];
			
			var param = new DataMap();
			param.put("P_TYPE", "LIST");
			param.put("SDATE", SDate);
			param.put("EDATE", EDate);
			param.put("WERKS", range.get('WERKS'));
			param.put("PROC_CD", range.get('PROC_CD'));
			param.put("MATNR", range.get('MATNR'));

			gridList.gridList({
				id : "gridList",
				param : param
			});
		}
	}*/
	
	function searchList() {
		if (validate.check("searchArea")) {
			var range = inputList.setRangeParam("searchArea");
			var range_data_param = range.get("RANGE_DATA_PARAM");
			var prfm_dt = range_data_param.get("INP_DT_Range");
			var date = prfm_dt.split('↓');
			var SDate = date[1];
			var EDate = date[2];
			
			var param = new DataMap();
			param.put("P_TYPE", "LIST");
			param.put("SDATE", SDate);
			param.put("EDATE", EDate);
			param.put("WERKS", range.get('WERKS'));
			param.put("PROC_CD", range.get('PROC_CD'));
			param.put("MATNR", range.get('MATNR'));
			gridList.gridList({
				id : "gridList",
				param : param
			});
		}
	}
	
	function searchSubList(rowNum)
	{
		var list = gridList.getRowData('gridList', rowNum)
		var range = inputList.setRangeParam("searchArea");
		var range_data_param = range.get("RANGE_DATA_PARAM");
		var prfm_dt = range_data_param.get("INP_DT_Range");
		var date = prfm_dt.split('↓');
		var SDate = date[1];
		var EDate = date[2];
		
		var param = new DataMap();
		
		param.put("P_TYPE", "SUB_LIST");
		param.put('list', list);
		param.put('WERKS', range.get('WERKS'));
		param.put("SDATE", SDate);
		param.put("EDATE", EDate);
		
		gridList.gridList({
			id : "gridList2",
			param : param
		});
	}

	function gridListEventRowDblclick(gridId, rowNum){
		if(gridId == "gridList"){
			searchSubList(rowNum);
		}
	}
	
	//마감
	function finish(){
		var json = netUtil.sendData({
    		module : 'mes',
    		command : 'SYSTEMCHECK',
    		sendType : 'map'
    	});
    	
    	if(json.data.USE_YN == 'Y'){
    		alert('시스템 점검 중입니다. 1 ~ 5분 동안 잠시만 기다려 주세요.');
    		return;
    	}
		
		if(gridList.validationCheck("gridList", "all")){
			var range = inputList.setRangeParam("searchArea");
			var range_data_param = range.get("RANGE_DATA_PARAM");
			var prfm_dt = range_data_param.get("INP_DT_Range");
			var date = prfm_dt.split('↓');
			var SDate = date[1];
			var EDate = date[2];
			
			var param = new DataMap();
			param.put("P_TYPE", "SAVE");
			param.put("SDATE", SDate);
			param.put("EDATE", EDate);
			param.put("WERKS", range.get('WERKS'));
			param.put("PROC_CD", range.get('PROC_CD'));
			param.put("MATNR", range.get('MATNR'));
			
			if(!commonUtil.msgConfirm('마감 처리하시겠습니까?')){
				return;
			}
			
			netUtil.send({
				url : "/mes/Inv/INV05/json/datalist.data",
				param : param,
				successFunction : "saveSuccessCallBack"
			});
		}
	}

	function saveSuccessCallBack(json){
		if(json.P_SUCCESS == 'Y'){			
			if(json.DOC_NO1 == '' && json.DOC_NO2 == '')	return alert('이미 마감 처리가 완료되었습니다. 재마감 처리 가능합니다.');
			if(json.DOC_NO1 != ''){
				var param = new DataMap();
				//SAP 자재투입량 취소
				param.put("IFID", "MES_IF_143");
	            param.put("DOC_NO", json.DOC_NO1);
	            
	            var json2 = netUtil.sendData({
	            	url : "/mes/erpif/json/sendIF.data",
	            	param : param
	            });
	            
	            if(json2.data == 'SUCCESS'){
	            	//SAP 자재투입량 실적
	            	interfaceRfcDocno(json.DOC_NO2);
	            }else	return alert('(SAP 자재투입량 취소) ' + json2.data);
			}else{
				//SAP 자재투입량 실적
	        	interfaceRfcDocno(json.DOC_NO2);
			}
			
			alert("마감 처리되었습니다.");
			searchList();
			
		}else{
			alert(json.ERR_MSG);
		}
	}
	
	function interfaceRfcDocno(DOC_NO){
		if(DOC_NO != ''){
			var param = new DataMap();
			var range = inputList.setRangeParam("searchArea");
			var chkWerks = range.get('WERKS');

			// 약품투입 사업부별 분기를 위한 처리
			if (chkWerks == 'P200') {
				param.put("IFID", "MES_IF_148");
			} else {
				param.put("IFID", "MES_IF_130");
			}
			
	        param.put("DOC_NO", DOC_NO);
	        
	        var json = netUtil.sendData({
	        	url : "/mes/erpif/json/sendIF.data",
	        	param : param
	        });
	        
	        if(json.data != 'SUCCESS')	return alert('(SAP 자재투입량) ' + json.data);
       	}
	}
	
	//보정
	function revise(){
		var rowData = gridList.getSelectData("gridList");
		
		if(rowData.length == 0){
			alert("항목을 선택하세요.");
			return;
		}
		
		if(gridList.getModifyRowCount("gridList") == 0 ){
			commonUtil.msgBox("MASTER_M0545");
			return;
		}
		
		if(gridList.validationCheck("gridList", "all")){
			var param = new DataMap();
			
			param.put("P_TYPE","SAVE1");
			param.put('list', rowData);
			
			if(!commonUtil.msgConfirm(configData.MSG_MASTER_SAVE_CONFIRM)){
				return;
			}
			
			var json = netUtil.sendData({
				url : "/mes/Inv/INV05/json/datalist.data",
				param : param
				
			});
			
			if(json.P_SUCCESS == 'Y'){
				searchList();
			}
		}
	}
	

	function commonBtnClick(btnName){
		if(btnName == "Search"){
			searchList();
		}else if(btnName == "Finish"){
			finish();
		}else if(btnName == "Revise"){
			revise();
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
					<input type="button" id="button-0-2" CB="Revise SAVE BTN_REVISE" />					
					<input type="button" id="button-0-2" CB="Finish SAVE BTN_FINISH" />
				</div>
			</div>
			<div class="search_inner">
				<div class="search_wrap ">
			
					<dl>
						<dt>플랜트</dt>
						<dd>
							<input type="text" class="input"  name="WERKS" id="WERKS" UIInput="S,PLANT" UIFormat="U" validate="required"/>
						</dd>
					</dl>
					
					<dl>
						<dt>투입일자</dt>
						<dd>
							<input type="text" class="input" name="INP_DT" id="INP_DT" UIInput="B" UIFormat="C M1"/>
						</dd>
					</dl>
					<dl>
						<dt>공정코드</dt>
						<dd>
							<input type="text" class="input"  name="PROC_CD" id="PROC_CD" UIInput="S,OP" UIFormat="U" validate="required"/>
						</dd>
					</dl>
					
					<dl>
						<dt>자재코드</dt>
						<dd>
							<input type="text" class="input"  name="MATNR" id="MATNR" UIInput="S,MATKY" UIFormat="U"/>
						</dd>
					</dl>

				</div>
				<div class="btn_tab">
					<input type="button" class="btn_more" value="more" onclick="searchMore()"/>
				</div>
			</div>
		</div>
        <div class="search_next_wrap">
			<div class="content_layout tabs top_layout">
				<ul class="tab tab_style02">
					<li><a href="#tab1-1"><span>사용이력</span></a></li>
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
										<td GH="100" GCol="text,WERKS" style="text-align:center;"></td> 					<!-- 플랜트 -->
										<td GH="100" GCol="text,INP_DT" GF='D' style="text-align:center;"></td>				<!-- 투입일자 -->		
										<td GH="100" GCol="text,MACH_CD" style="text-align:center;"></td>					<!-- 설비코드 -->
										<td GH="100" GCol="text,MATNR" style="text-align:center;"></td>						<!-- 자재코드 -->
										<td GH="200" GCol="text,MATNR_NM"></td>												<!-- 자재명 -->	
										<td GH="100" GCol="text,USE_QTY" GF="N 13,3"></td>									<!-- 투입량 -->	
										<td GH="100" GCol="input,USE_CHG_QTY" GF="N 10,3"></td>									<!-- 투입보정량 -->											
										<td GH="80" GCol="text,UNIT" style="text-align:center;"></td>						<!-- 단위 -->		
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
			<div class="content_layout tabs bottom_layout">
				<ul class="tab tab_style02">
					<li><a href="#tab1-1"><span>자재코드별 재고현황</span></a></li>
					<li class="btn_zoom_wrap">
						<ul>
							<!-- <li><button class="btn btn_smaller"><span>축소</span></button></li> -->
							<li><button class="btn btn_bigger"><span>확대</span></button></li>
						</ul>
					</li>
				</ul>
				<div class="table_box section" id="tab1-1" >
					<div class="table_list01">
						<div class="scroll">
							<table class="table_b">
								<tbody id="gridList2">
									<tr CGRow="true">
										<td GH="100" GCol="text,MATNR_GRP_CD" style="text-align:center;"></td>			<!-- 자재그룹 -->	
										<td GH="120" GCol="text,MATNR_GRP_NM"></td>			<!-- 자재그룹명 -->							
										<td GH="100" GCol="text,MATNR" style="text-align:center;"></td>		<!-- 자재코드 -->
										<td GH="200" GCol="text,MATNR_NM"></td>		<!-- 자재명 -->
										<td GH="100" GCol="text,AVAIL_QTY" GF="N 13,3"></td>			<!-- 가용재고 -->
										<td GH="100" GCol="text,TOT_USE_QTY" GF="N 13,3"></td>			<!-- 총사용량 -->
										<td GH="100" GCol="text,REST_QTY" GF='N 13,3'></td>		<!-- 잔량 -->
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