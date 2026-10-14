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
	$(document).ready(function() {
		gridList.setGrid({
			id : "gridList",
			url:"/mes/Work/WRK40/json/datalist.data",
			bigdata : false,
			colorType : true
		})
		
		// 자재그룹 select 제어
		/* 
		$("#MATNR_GRP_CD").find("option").map(function() {
			//20221017 여한진 약품에 관련되서 텍스트 말고 코드로 불러오기
			const text = $(this).val()
			
			// "약품 :" 문자열을 포함하지 않을 경우
			if(text.substr(0,1).indexOf("2") === -1){
				$(this).remove()
			}
		});
		*/
		$("#MATNR_GRP_CD").multipleSelect("checkAll")
		inputList.reloadCombo($("#MATNR_GRP_CD"), configData.INPUT_COMBO, "airfw,COMCOMBO")
	});
	
	function comboEventDataBindeBefore(comboAtt){
		if(comboAtt == "airfw,COMCOMBO"){
			var param = new DataMap();
			
			param.put("MENUID", "WRK40");
			param.put('CODE', 'MATKL')
		}
		return param;
	}

	
	function searchList() {  // 조회
		if (validate.check("searchArea")) {	
			// 2023-03-13(월요일) 안상현, RANGE 검색 추가
			const range = inputList.setRangeParam("searchArea")
			const range_data_param = range.get("RANGE_DATA_PARAM")
			const inp_dt = range_data_param.get("INV005.INP_DT_Range")
			const date = inp_dt.split("↓")
			const SDate = date[1]
			const EDate = date[2]
			
			const param = inputList.setRangeParam("searchArea")
			param.put("P_TYPE", "LIST")
			param.put("SDATE", SDate)
			param.put("EDATE", EDate)
			param.put("WERKS", $("#WERKS").val().toUpperCase()) // 플랜트 코드
			
			gridList.gridList({
		    	id : "gridList",
		    	param : param
		    })
		}
	}
	
	function gridListRowBgColorChange(gridId, rowNum){
		if(gridId == "gridList"){
			
			var werks = gridList.getColData("gridList", rowNum, "WERKS");
			
			if(werks == "합계"){
				return configData.GRID_COLOR_BG_GRAY_CLASS;
			}
		}
	}
	
	function gridListEventDataBindEnd(gridId, dataLength){
		if(gridId == 'gridList'){
			var list = gridList.getGridData(gridId);
			
			for(var i = 0; i < dataLength; i++){
				if(list[i].get('WERKS') == '합계'){
					gridList.setRowReadOnly(gridId, i, true, ['USE_CHG_QTY']);
				}
			}
		}
	}
	
	// 20220902 여한진 저장 추가
	function saveData(){
		if(gridList.validationCheck('gridList', 'modify')){
			var list = gridList.getSelectData('gridList');
			
			if(list.length == 0){
				alert('선택한 항목이 없습니다.');
				return;
			}
			
			if(gridList.getModifyRowCount('gridList') == 0){
				alert('선택한 항목에 대한 보정할 사용량을 입력하세요.');
				return;
			}
			
			var param = new DataMap();
			
			param.put('P_TYPE', 'SAVE');
			param.put('list', list);
			
			if(!commonUtil.msgConfirm(configData.MSG_MASTER_SAVE_CONFIRM)){
				return;
			}
			
			netUtil.send({
				url : '/mes/Work/WRK40/json/datalist.data',
				param : param,
				successFunction : 'saveSuccessCallBack'
			});
		}
	}
	
	function saveSuccessCallBack(json){
		if(json.P_SUCCESS == 'Y'){
			commonUtil.msgBox(configData.MSG_SYSTEM_SAVEOK);
			searchList();
		}else{
			alert(json.ERR_MSG);
		}
	}
	
	function commonBtnClick(btnName) {   // 버튼을 클릭한 경우(저장, 조회 등)
		if (btnName == "Search") {
			var param = new DataMap();
	        param.put("PROGID", "<%= menuId%>");
	        param.put("LGTYPE", "SEARCH");
	        var json = netUtil.sendData({
	            url: "/mes/system/json/saveLog.data",
	            param : param
	        });
			
			searchList();
		}else{
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
							<input type="text" class="input" id="WERKS" name="WERKS" UIInput='S,PLANT' UIFormat='U' validate='required'/>
						</dd>
					</dl>
					<dl>
						<dt CL="STD_INP_DT">투입일자</dt>
						<dd>
							<input type="text" class="input" name="INV005.INP_DT" UIInput="B" UIFORMAT="C M1"/>
						</dd>
					</dl>
					<dl>
						<dt CL="STD_PROC_CD">공정코드</dt>
						<dd>
							<!-- 2023-03-13(월요일) 안상현, 공정코드 RANGE 검색 추가 -->
							<input type="text" id="PROC_CD" name="PROC_CD" UIInput="SR,OP" UIFormat="U"/>
						</dd>
					</dl>
					<dl>
						<dt>자재그룹</dt>
						<dd>
							<select class="input" id="MATNR_GRP_CD" name="MATNR_GRP_CD" Combo="airfw,COMCOMBO" ComboType="MS">
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
					<li><a href="#tab1-1"><span CL="STD_GRD_WRK40">사용이력</span></a></li>
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
										<!-- 20220902 여한진 컬럼 수정 및 추가 -->
										<td GH="100" GCol="text,WERKS" style="text-align:center;">플랜트</td>
										<td GH="100" GCol="text,INP_DT" GF="C" style="text-align:center;">투입일자</td>
										<td GH="100" GCol="text,MACH_CD" style="text-align:center;">설비코드</td>
										<td GH="100" GCol="text,MACH_NM">설비명</td>	
										<td GH="140" GCol="text,MATNR" style="text-align:center;">자재코드</td>
										<td GH="320" GCol="text,MATNR_NM">자재명</td>
										<td GH='0' GCol='text,PDOC_NO'>문서번호</td>
										<td GH="100" GCol="text,USE_QTY" GF="N 10,3">사용량</td>
										<td GH='100' GCol='input,USE_CHG_QTY' GF='N 10,3' validate='required'>사용량보정</td>
										<td GH="80" GCol="text,UNIT" style="text-align:center;">단위</td>	
										<td GH="0" GCol="text,MATNR_GRP_CD" style="text-align:center;">자재그룹</td>	
										<td GH="0" GCol="text,MATNR_GRP_NM">자재그룹명</td>	
										<td GH="100" GCol="text,INP_NM">투입자명</td>
										<td GH="150" GCol="text,REGDATE" style="text-align:center;">등록일시</td>
										<td GH="100" GCol="text,REGNM">등록자</td>
										<td GH="150" GCol="text,UPDDATE" style="text-align:center;">수정일시</td>
										<td GH="100" GCol="text,UPDNM">수정자</td>
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