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
			id :"gridList",
	    	url :"/mes/Work/WRK06/json/datalist.data",
	    	bigdata : false
	    });
		
		gridList.setGrid({
			id :"gridList2",
			url:"/mes/Work/WRK06/json/datalist.data",
			bigdata : false
		})
		
	});

	// 조회
	function searchList(){
		if(validate.check("searchArea")){
			var param = inputList.setRangeParam("searchArea");
			
			param.put("P_TYPE","LIST");
			
			gridList.gridList({
		    	id : "gridList",
		    	param : param
		    });
			
			gridList.resetGrid('gridList2');
		}
	}
	
	function searchSubList(headRowNum){
		var werks = gridList.getColData("gridList", headRowNum, "WERKS");
		var wrkordrno= gridList.getColData("gridList", headRowNum, "WRK_ORDR_NO");
		var param = inputList.setRangeParam("searchArea");
		
		param.put("P_TYPE", "SUB_LIST");
		param.put("WERKS", werks);
		param.put("WRK_ORDR_NO", wrkordrno);

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
	
	function gridListEventDataBindEnd(gridId, dataLength){
		if(gridId == 'gridList2'){
			var list = gridList.getGridData(gridId);
			
			for(var i = 0; i < dataLength; i++){
				if(list[i].get('STOR_LOC_FLG') == 'Y'){
					gridList.setRowReadOnly(gridId, i, true, ['STOR_LOC_CD','LOC_CD']);
				}
				if(list[i].get('MATNR_FLG') == 'Y'){
					gridList.setRowReadOnly(gridId, i, true, ['MATNR']);
				}
			}
		}
	}
	
	function gridListEventRowAddBefore(gridId, rowNum) {
		if(gridId == 'gridList'){
			var headCnt = gridList.getModifyRowCount("gridList");
			var listCnt = gridList.getModifyRowCount("gridList2");
			if(listCnt > 0 || headCnt > 0){
				commonUtil.msgBox("MASTER_M0702");//변경된 row를 저장 후 행추가 하십시오.
				return false;
			}else{
				var newData = new DataMap();
				
				newData.put('WERKS', $('#WERKS').val().toUpperCase());
				
				return newData;
			}
		}
		if(gridId == "gridList2"){
			var werks = gridList.getColData("gridList", lastFocusNum, "WERKS");
			var wrkordrno = gridList.getColData("gridList", lastFocusNum, "WRK_ORDR_NO");	//작업지시번호
			
			var newData = new DataMap();
			
			newData.put("WERKS", werks);
			newData.put("WRK_ORDR_NO", wrkordrno);
			
			return newData;
		}
	}
	
	function gridListEventColValueChange(gridId, rowNum, colName, colValue){
		if(gridId == 'gridList2'){
			if(colName == 'STOR_LOC_FLG'){
				if(colValue == 'Y'){
					gridList.setRowReadOnly(gridId, rowNum, true, ['STOR_LOC_CD', 'LOC_CD']);
					gridList.setColValue(gridId, rowNum, 'STOR_LOC_CD', '');
					gridList.setColValue(gridId, rowNum, 'STOR_LOC_NM', '');
					gridList.setColValue(gridId, rowNum, 'LOC_CD', '');
					gridList.setColValue(gridId, rowNum, 'LOC_NM', '');
				}else{
					gridList.setRowReadOnly(gridId, rowNum, false, ['STOR_LOC_CD', 'LOC_CD']);
				}
			}
			if(colName == 'MATNR_FLG'){
				if(colValue == 'Y'){
					gridList.setRowReadOnly(gridId, rowNum, true, ['MATNR']);
					gridList.setColValue(gridId, rowNum, 'MATNR', '');
				}else{
					gridList.setRowReadOnly(gridId, rowNum, false, ['MATNR']);
				}
			}
			if(colName == 'STOR_LOC_CD' || colName == 'LOC_CD'){
				var storlocflg = gridList.getColData(gridId, rowNum, 'STOR_LOC_FLG');
				
				if(storlocflg.trim() == ''){
					alert('저장위치구분을 먼저 선택하세요.');
					gridList.setColValue(gridId, rowNum, 'STOR_LOC_CD', '');
					gridList.setColValue(gridId, rowNum, 'STOR_LOC_NM', '');
					gridList.setColValue(gridId, rowNum, 'LOC_CD', '');
					gridList.setColValue(gridId, rowNum, 'LOC_NM', '');
					return;
				}
			}
			if(colName == 'MATNR'){
				var matnrflg = gridList.getColData(gridId, rowNum, 'MATNR_FLG');
				
				if(matnrflg.trim() == ''){
					alert('자재구분을 먼저 선택하세요.');
					gridList.setColValue(gridId, rowNum, 'MATNR', '');
					gridList.setColValue(gridId, rowNum, 'MATNR_NM', '');
					return;
				}
			}
		}
	}
	
	function searchHelpEventOpenBefore(searchCode, gridType, $inputObj, rowNum){
		var storlocCd = gridList.getColData('gridList2', rowNum, 'STOR_LOC_CD');
		var matnr = gridList.getColData('gridList2', rowNum, 'MATNR');
		var param = new DataMap();
		
		if(gridType == false){
			if(searchCode == 'LOCATION'){
				param.put('STOR_LOC_CD', storlocCd);
			}else if(searchCode == 'LOC'){
				param.put('STOR_LOC_CD', storlocCd);
			}else if(searchCode == 'MATKY'){
				param.put('MATNR', matnr);
			}
		}
		return param;
	}
	
	function searchHelpEventCloseAfter(searchCode, gridType, selectData, rowData){
		var storlocflg = gridList.getColData('gridList2', gridList.getFocusRowNum('gridList2'), 'STOR_LOC_FLG');
		var matnrflg = gridList.getColData('gridList2', gridList.getFocusRowNum('gridList2'), 'MATNR_FLG');
		
		if(gridType == false){
			if(storlocflg.trim() != ''){
				if(searchCode == 'LOC'){
					gridList.setColValue('gridList2', gridList.getFocusRowNum('gridList2'), 'STOR_LOC_NM', rowData.get('STOR_LOC_NM'));
				} else if(searchCode == 'LOCATION'){
					gridList.setColValue('gridList2', gridList.getFocusRowNum('gridList2'), 'STOR_LOC_CD', rowData.get('STOR_LOC_CD'));
					gridList.setColValue('gridList2', gridList.getFocusRowNum('gridList2'), 'LOC_NM', rowData.get('LOC_NM'));
				}
			}
			if(matnrflg.trim() != ''){
				if(searchCode == 'MATKY'){
					gridList.setColValue('gridList2', gridList.getFocusRowNum('gridList2'), 'MATNR_NM', rowData.get('MATNR_NM'));
				}
			}
		}
	}
	
	function gridListEventRowRemove(gridId, rowNum){
		if(gridId == 'gridList'){
			gridList.resetGrid('gridList2');
		}
	}
	
	// 저장
	function saveData(){
		//2020.04.14 ItemList없이 HeadList저장되는 오류 수정
		//var rowNum = 0;
		// 2020.04.16 아이템리스트 없을때 저장되는 오류 재수정
		var dCnt = 0;
		if(gridId = "gridList2"){
			for(var i = 0; i < gridList.getGridDataCount("gridList2"); i++) {
				if(gridList.getRowState(gridId, i) == configData.GRID_ROW_STATE_DELETE){
					dCnt++;
				}
			}
			if(gridList.getModifyRowCount("gridList") > 0) {
				if(gridList.getModifyData("gridList")[0].get("GRowState") != configData.GRID_ROW_STATE_DELETE
						&& gridList.getGridDataCount("gridList2") == dCnt) {
					commonUtil.msgBox("OUT_M0045");
					return;
				}
			}
		}

		if(gridList.getModifyRowCount("gridList") == 0 && gridList.getModifyRowCount("gridList2") == 0 ){
			commonUtil.msgBox("MASTER_M0545");
			return;
		}
		
		if(gridList.validationCheck("gridList", "data") && gridList.validationCheck("gridList2", "data")){
			var headNum = gridList.getGridDataCount("gridList") -1;

			if(gridList.getRowStatus("gridList",headNum) == "C" && gridList.getGridDataCount("gridList2") == 0){
				//alert(commonUtil.getMsg("OUT_M0045"));
				commonUtil.msgBox("OUT_M0045");   //처리를 위한 아이템이 존재하지 않습니다.
				return;
			}

			/* var headCnt = gridList.getGridDataCount("gridList");
			for(var i = 0; i < headCnt; i++){
				gridList.setColValue("gridList", i, "GRowState", gridList.getRowStatus("gridList", i));
			} */
			var head = gridList.getModifyData("gridList", "A");

			/* var listCnt = gridList.getGridDataCount("gridListSub");
			for(var i = 0; i < listCnt; i++){
				gridList.setColValue("gridListSub", i, "GRowState", gridList.getRowStatus("gridListSub", i));
			} */

			var list = gridList.getModifyData("gridList2", "A");
			
			for(var i = 0; i < list.length; i++){
				if(list[i].get('STOR_LOC_FLG') == 'N'){
					if(list[i].get('STOR_LOC_CD').trim() == ''){
						alert('선택한 항목 중 ' + (i+1) + '번째 저장위치코드를 입력바랍니다.');
						return;
					}
					if(list[i].get('LOC_CD').trim() == ''){
						alert('선택한 항목 중 ' + (i+1) + '번째 로케이션코드를 입력바랍니다.');
						return;
					}
				}
				if(list[i].get('MATNR_FLG') == 'N'){
					if(list[i].get('MATNR').trim() == ''){
						alert('선택한 항목 중 ' + (i+1) + '번째 자재코드를 입력바랍니다.');
						return;
					}
				}
				if(list[i].get('STOR_LOC_FLG').trim() == '' && list[i].get('STOR_LOC_CD').trim() == '' && list[i].get('MATNR_FLG').trim() == '' && list[i].get('MATNR').trim() == ''){
					alert('선택한 항목 중 ' + (i+1) +'번째 입력한 항목이 없습니다.');
					return;
				}
			}
			
			if(list.length >= 100){
				alert("100개 이상의 데이터를 처리할 수 없습니다.");
				return;
			}
			
			var param = new DataMap();
			
			param.put("P_TYPE","SAVE");
			param.put('head', head);
			param.put("list", list);
			
			if(!commonUtil.msgConfirm(configData.MSG_MASTER_SAVE_CONFIRM)){
				return;
			}
			
			var json = netUtil.sendData({
				url : "/mes/Work/WRK06/json/datalist.data",
				param : param
			});
			
			if(json.P_SUCCESS == 'Y'){
				commonUtil.msgBox(configData.MSG_SYSTEM_SAVEOK);
				gridList.resetGrid("gridList2");
				searchList();
			}
		}
	}
	
	
	// 버튼 클릭(조회, 저장)
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
					<input type="button" id="button-0-2" CB="Save SAVE BTN_SAVE" />
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
						<dt>지시일자</dt>
						<dd>
							<input type="text" class="input"  name="WRK_REQ_DT" UIInput="B" UIFormat="C M1"/>
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
					<li><a href="#tab1-1"><span CL="STD_GRD_WRK06_1">재고실사 지시정보</span></a></li>
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
										<td GH="40" GCol="rowCheck"></td>
										<td GH="100" GCol="text,WERKS,PLANT" style="text-align:center;">플랜트</td>
										<td GH="120" GCol="text,WRK_ORDR_NO" style="text-align:center;">작업지시번호</td>						
										<td GH="100" GCol="add,WRK_REQ_DT" GF="C" style="text-align:center;" validate="required">작업지시일자</td>
										<td GH="150" GCol="input,WRK_ORDR_RMK" GF="S 300">비고</td>
										<td GH="0" GCol="select,APVR_STA" style="text-align:center;"> <!-- 결재상태 -->
											<select class="input" CommonCombo="APVR_STA" style="text-align:center;"></select>
										</td>
										<td GH="0" GCol="text,APPR_NM" style="text-align:center;">승인자명</td>
										<td GH="0" GCol="text,APPR_DT" GF="D" style="text-align:center;">승인일자</td>
										<td GH="140" GCol="text,REGDATE" style="text-align:center;">등록일시</td>										
										<td GH="100" GCol="text,REGNM" style="text-align:center;">등록자ID</td>
									</tr>
								</tbody>
							</table>
						</div>
					</div>
					<jsp:include page="/WEB-INF/jsp/common/commonBtnAuth.jsp">
						<jsp:param name="authCd" value="1" />
						<jsp:param name="showAuthCd" value="1,2,3,4,5,6,9,10" />
					</jsp:include>
				</div>				
			</div>	
			
			<div class="content_layout tabs bottom_layout">
				<ul class="tab tab_style02">
					<li><a href="#tab1-1"><span CL="STD_GRD_WRK06_2">상세</span></a></li>
					<li class="btn_zoom_wrap">
						<ul>
							<li><button class="btn btn_bigger"><span>확대</span></button></li>
						</ul>
					</li>
				</ul>
				<div class="table_box section" id="tab1-1" >
					<div class="table_list01">
						<div class="scroll">
							<table class="table_c">
								<tbody id="gridList2">
									<tr CGRow="true">
										<td GH="40" GCol="rownum">1</td>	
										<td GH="40" GCol="rowCheck"></td>
										<td GH="0" GCol="text,WERKS,PLANT" style="text-align:center;">플랜트</td>
										<td GH="0" GCol="text,WRK_ORDR_NO" style="text-align:center;">작업지시번호</td>
										<td GH="0" GCol="text,WRK_ORDR_SEQNO" style="text-align:center;">작업지시순번</td>
										<td GH="100" GCol="select,STOR_LOC_FLG">
											<select CommonCombo="FLG" style="text-align:center;">          <!-- 작업지시구분 -->
												<option value=""> </option>
											</select>
										</td>
										<td GH="100" GCol="input,STOR_LOC_CD,LOC" style="text-align:center;">저장위치</td>	
										<td GH="100" GCol="text,STOR_LOC_NM" style="text-align:center;">저장위치명</td>
										<!-- 20230216 여한진 하위 2개 컬럼 추가 -->
										<td GH="100" GCol="input,LOC_CD,LOCATION" style="text-align:center;">로케이션</td>	
										<td GH="100" GCol="text,LOC_NM" style="text-align:center;">로케이션명</td>
										
										<td GH="100" GCol="select,MATNR_FLG">
											<select CommonCombo="FLG" style="text-align:center;">          <!-- 자재구분 -->
												<option value=""> </option>
											</select>
										</td>	
										<td GH="140" GCol="input,MATNR,MATKY" style="text-align:center;">자재</td>		
										<td GH="320" GCol="text,MATNR_NM" style="text-align:center;">자재명</td>	
									</tr>
								</tbody>
							</table>
						</div>
					</div>
					<jsp:include page="/WEB-INF/jsp/common/commonBtnAuth.jsp">
						<jsp:param name="authCd" value="1" />
						<jsp:param name="showAuthCd" value="1,2,3,4,5,6,9,10" />
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