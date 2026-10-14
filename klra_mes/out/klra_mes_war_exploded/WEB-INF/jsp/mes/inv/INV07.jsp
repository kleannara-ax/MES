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
			url:"/mes/Inv/INV07/json/datalist.data",
			bigdata : false
		})
		
		/* // 자재그룹 select 제어
		$("#MATNR_GRP_CD").find("option").map(function(){
			//20221017 여한진 약품에 관련되서 텍스트 말고 코드로 불러오기
			const text = $(this).val()
			
			// "약품 :" 문자열을 포함하지 않을 경우
			if(text.substr(0,1).indexOf("2") === -1){
				$(this).remove()
			}
		}) */
		
		$('#MATNR_GRP_CD').multipleSelect('checkAll');
		inputList.reloadCombo($('#MATNR_GRP_CD'), configData.INPUT_COMBO, 'airfw,COMCOMBO');
	});

	function comboEventDataBindeBefore(comboAtt){
		if(comboAtt == "airfw,COMCOMBO"){
			var param = new DataMap();
			
			param.put("MENUID", 'INV07');
			param.put('CODE', 'MATKL')
		}
		return param;
	}
	
	// 조회
	function searchList(){
		if(validate.check("searchArea")){			
			var param = inputList.setRangeParam("searchArea");
			
			param.put("P_TYPE", "LIST");
			
			gridList.gridList({
		    	id : "gridList",
		    	param : param
		    });
		}
	}
	
	function gridListEventColValueChange(gridId, rowNum, colName, colValue){
		if(gridId == 'gridList'){
				var wmsStckqty = gridList.getColData(gridId, rowNum, 'WMS_STCK_QTY');
			if(colName == 'REQ_QTY'){
				if(wmsStckqty == '0' || wmsStckqty == ''){
					alert('WMS재고가 없습니다.');
					gridList.setColValue(gridId, rowNum, colName, "0");
					gridList.setRowState(gridId, configData.GRID_ROW_STATE_READ, rowNum);
					gridList.setRowCheck(gridId, rowNum, false);
					gridList.reloadAll("gridList");
				}else if(Number(wmsStckqty) < Number(colValue)){
					alert('WMS재고수량보다 많은 수량을 요청할 수 없습니다.');
					gridList.setColValue(gridId, rowNum, colName, "0");
					gridList.setRowState(gridId, configData.GRID_ROW_STATE_READ, rowNum);
					gridList.setRowCheck(gridId, rowNum, false);
					gridList.reloadAll("gridList");
				}
			}
		}
	}
	
	//불출요청
	function saveData(){
		var json = netUtil.sendData({
    		module : 'mes',
    		command : 'SYSTEMCHECK',
    		sendType : 'map'
    	});
    	
    	if(json.data.USE_YN == 'Y'){
    		alert('시스템 점검 중입니다. 1 ~ 5분 동안 잠시만 기다려 주세요.');
    		return;
    	}
		
		if(gridList.getModifyRowCount("gridList") == 0 ){
			commonUtil.msgBox("MASTER_M0545");
			return;
		}
		
		if(gridList.validationCheck("gridList", "all")){
			var list = gridList.getModifyList("gridList", "A");
			
			for(var i = 0; i < list.length; i++){
				if(list[i].get('KZAUS') == 'Y'){
					alert('선택한 ' + (i+1) + '번째 항목의 자재는 단종된 자재입니다.');
					return;
				}
				if(list[i].get('REQ_QTY') == '0.000'){
					alert('선택한 ' + (i + 1) + '번째 항목에 대한 요청수량을 입력하시기 바랍니다.');
					return;
				}
			}
			
			if(!commonUtil.msgConfirm('불출 요청하시겠습니까?')){
				return;
			}
			
			var param = new DataMap();
			
			param.put("P_TYPE","SAVE");
			param.put("list", list);
			
			netUtil.send({
				url : "/mes/Inv/INV07/json/datalist.data",
				param : param,
				successFunction : "savesuccessCallBack"
			});
		}
	}
	
	function savesuccessCallBack(json){
		if(json){
			if(json.P_SUCCESS == "Y"){
				var werks = $("#WERKS").val().toUpperCase();
				
				//자재불출요청
				var ifid = "MES_IF_201";
	   			
				var docno = json.DOC_NO1.split(',');
				var message = '';
				
				for(var i = 0; i < docno.length; i++){
					var json2 = netUtil.sendData({
		   				url : "/common/api/json/"+ifid+"/send.data",
		   				param : 'DOC_NO=' + docno
		   			});
		   			
	   				if(json2.result == 'SUCCESS'){
	   				}else {
	   					message = '(WMS 불출요청) ' + (i + 1) + '번째 오류는 ' + json2.result + '\n' + message;
	   				}
				}
				alert("약품 불출 요청 완료되었습니다.");
				searchList();
			}else{
				alert(json.ERR_MSG);
			}
		}
	}
	
	// 버튼을 클릭한 경우(저장, 조회 등)
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
		}else if(btnName == "Save"){
			saveData();
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
					<input type="button" id="button-0-2" CB="Save SAVE 불출요청" />
				</div>
			</div>
			<div class="search_inner">
				<div class="search_wrap">
					<dl>
						<dt CL="STD_PLANT">플랜트</dt>
						<dd>
							<input type="text" class="input" id="WERKS" name="WERKS" UIInput="S,PLANT" UIFormat="U" validate="required" />
						</dd>
					</dl>
					<dl>
						<dt>자재그룹</dt>
						<dd>
							<select class='input' id="MATNR_GRP_CD" name="MATNR_GRP_CD" Combo="airfw,COMCOMBO" ComboType="MS">
								<!-- <option value="">ALL</option> -->
							</select>
						</dd>
					</dl>
					<!-- 20230214 여한진 자재코드, 단종여부 검색조건 추가 -->
					<dl>
						<dt CL="STD_MATNR">자재코드</dt>
						<dd>
							<!-- 2023-03-13(월요일) 안상현, Range 검색 추가 -->
							<input type="text" name="MATNR" UIInput="SR,MATKY" UIFormat="U" />
						</dd>
					</dl>
					<dl>
						<dt CL='STD_KZAUS'>단종여부</dt>
						<dd>
							<select class='input' name="KZAUS">
								<option value="">ALL</option>
								<option value='Y'>Y</option>
								<option value='N'>N</option>
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
					<li><a href="#tab1-1"><span CL="STD_GENERAL">일반</span></a></li>
					<li class="btn_zoom_wrap">
						<ul>
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
										<td GH="100" GCol="text,WERKS" style="text-align:center;">플랜트</td>
										<td GH="140" GCol="text,MATNR" style="text-align:center;">자재코드</td>
										<td GH="320" GCol="text,MATNR_NM" style="text-align:center;">자재명</td>
										<td GH="0" GCol="text,MATNR_GRP_CD" style="text-align:center;">자재그룹</td>
										<td GH="160" GCol="text,MATNR_GRP_NM" style="text-align:center;">자재그룹명</td>
										<!-- 20230214 여한진 하위 컬럼 1개 추가 -->
										<td GH='100' GCol='text,KZAUS' style="text-align:center;">단종여부</td>
										
										<td GH="120" GCol="text,WMS_STCK_QTY" GF="N 13,3">WMS 재고수량</td>	
										<td GH="0" GCol="text,STOR_LOC_CD" style="text-align:center;">저장위치</td>
										<td GH="100" GCol="text,STOR_LOC_NM" style="text-align:center;">저장위치명</td>
										<td GH="100" GCol="text,STCK_QTY" GF="N 13,3">현 재고수량</td>
										<td GH="100" GCol="input,REQ_QTY" GF="N 5,3">요청수량</td>
										<td GH="80" GCol="text,UNIT" style="text-align:center;">단위</td>
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