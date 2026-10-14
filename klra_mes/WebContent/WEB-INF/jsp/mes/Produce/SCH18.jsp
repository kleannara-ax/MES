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
	    	url : "/mes/Produce/SCH18/json/datalist.data",
	    	bigdata : false,
	    	colHoldType : true,
            colHold : "WERKS, PLANTNM, PROC_CD, PROC_NM, MACH_CD, MACH_NM"
	    });
		
		gridList.setGrid({
	    	id : "gridList2",
	    	url : "/mes/Produce/SCH18/json/datalist.data",
	    	bigdata : false,
	    	colHoldType : true,
            colHold : "WERKS, PLANTNM, PROC_CD, PROC_NM, MACH_CD, MACH_NM"
	    });
		
		flagset(1);
		//var werks;
	});

	function searchHelpEventCloseAfter(searchCode, multyType, selectData, rowData){
		if(searchCode == "PLANT"){
			reloadCombo();
		}
	}
	
	function reloadCombo(){
		//2022-09-21 여한진 판매문서번호는 PS만 보이도록 
		if($('#WERKS').val().toUpperCase() == 'P100'){
			$('#VBELN').show();
		}else{
			$('#VBELN').hide();
		}
		
		$comboObj = $("#MACHINE");
		inputList.reloadCombo($comboObj, configData.INPUT_COMBO, "Produce,MACHINE");
	}

	function comboEventDataBindeBefore(comboAtt){
		if(comboAtt == "Produce,MACHINE"){
			var param = new DataMap();
			
			param.put("WERKS", $("#WERKS").val().toUpperCase());
		}
		return param;
	}
	
	function flagset(flag){
		if(flag == 1){
			$('#WERKS').val('P100');
			werks = 'P100';
			$('#WERKS').attr('readonly', true);
		}else{
			$('#WERKS').val('');
			werks = '';
			$('#WERKS').attr('readonly', false);
		}
	}
	
	// 조회
	function searchList(){
		if(validate.check("searchArea")){
			var param = inputList.setRangeParam("searchArea");
			
			param.put("P_TYPE", "LIST");
			// configData.INPUT_RNAGE_DATA_PARAM : RANGE_DATA_PARAM
			// configData.DATA_COL_SEPARATOR : ↓
			/* const data = param.get("RANGE_DATA_PARAM").get("PRD_DT_Range").split("↓")
			const condi = data[1] + "," + data[2]
			param.put("OUT_SQL", condi) */
			 
			if(param.get('WERKS') == 'P100'){
				if(werks != 'P100'){
					alert('PS 탭에서 조회하세요.');
					return;
				}
				gridList.gridList({
			    	id : "gridList",
			    	param : param
			    });
			}else{
				gridList.gridList({
			    	id : "gridList2",
			    	param : param
			    });
			}
			
		}
	}
	
	// 버튼을 클릭한 경우
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
						<dt CL="STD_PLANT">플랜트</dt>
						<dd>
							<input type="text" class="input" id="WERKS" name="WERKS" validate="required" UIInput="S,PLANT" UIFormat="U" onkeyup="reloadCombo()"/>
						</dd>
					</dl>
					<dl>
						<dt CL="STD_PROC_CD">공정코드</dt>
						<dd>
							<input type="text" class="input" id="PROC_CD" name="PROC_CD" UIInput="SR,OP" UIFormat="U"/>
						</dd>
					</dl>
					<dl>
						<dt CL="STD_MACHINE">생산호기</dt>
						<dd>
							<select class="input" id="MACHINE" name="MACHINE" Combo="Produce,MACHINE">
								<option value="">All</option>
							</select>
						</dd>
					</dl>
					<dl>
						<dt CL="STD_PRD_DT">생산일자</dt>
						<dd>
							<input type="text" id="PRD_DT" name="PRD_DT" UIInput="B" UIFormat="C M1"/>
						</dd>
					</dl>
					
					<dl id = 'VBELN'>
						<dt CL="STD_VBELN">판매문서번호</dt>
						<dd><input type="text" id="VBELN" name="VBELN" class="input" UIInput="SR" UIFormat="U"/></dd>
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
					<li>
						<a href="#tab1-1" onclick='flagset(1);'><span>PS</span></a>
					</li>
					<li>
						<a href="#tab1-2" onclick='flagset(2);'><span>HL</span></a>
					</li>
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
										<td GH="100" GCol="text,WERKS" style="text-align: center;">플랜트코드</td>
										<td GH="140" GCol="text,PLANTNM" style="text-align: center;">플랜트명</td>
										<td GH="100" GCol="text,PROC_CD" style="text-align: center;">공정코드</td>
										<td GH="100" GCol="text,PROC_NM" style="text-align: center;">공정명</td>
										<td GH="100" GCol="text,MACH_CD" style="text-align: center;">설비코드</td>
										<td GH="140" GCol="text,MACH_NM" style="text-align: center;">설비명</td>
										<td GH="100" GCol="text,MACHINE" style="text-align: center;">생산호기</td>
										<!-- <td GH="200" GCol="text,MACHINE_NM">생산호기명</td> -->
										<td GH="150" GCol="text,WRK_ORDR_NO" style="text-align: center;">작업지시번호</td>
										<td GH="100" GCol="text,WRK_ORDR_SEQNO" style="text-align:center;">지시순번</td>
										<td GH="140" GCol="text,MATNR" style="text-align: center;">자재코드</td>
										<td GH="320" GCol="text,MATNR_NM" style="text-align: center;">자재명</td>
										<td GH="100" GCol="text,VBELN" style="text-align: center;">판매문서번호</td>
										<td GH="100" GCol="text,SPEC1" style="text-align: center;">규격</td>
										<td GH="100" GCol="text,PLN_UNIT" style="text-align: center;">단위</td>
										<!-- 20230213 여한진 하위 2개 컬럼 추가 및 수정 -->
										<td GH="100 지시수량" GCol="text,WRK_ORDR_QTY" GF="N 13,3">지시량</td>
										<td GH="100 지시중량(KG)" GCol="text,WRK_ORDR_WGT" GF="N 13,3">지시중량(KG)</td>
										
										<td GH="100" GCol="text,PRFM_UNIT" style="text-align: center;">단위</td>
										<!-- 20230213 여한진 하위 2개 컬럼 추가 및 수정 -->
										<td GH="100 실적수량" GCol="text,PRFM_QTY" GF="N 13,3">실적량</td>
										<td GH="100 실적중량(KG)" GCol="text,PRFM_WGT" GF="N 13,3">지시중량(KG)</td>
										
										<td GH="100" GCol="text,ACH_RATE" GF="N 5,3">달성률</td>
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
										<td GH="100" GCol="text,WERKS" style="text-align: center;">플랜트코드</td>
										<td GH="140" GCol="text,PLANTNM" style="text-align: center;">플랜트명</td>
										<td GH="100" GCol="text,PROC_CD" style="text-align: center;">공정코드</td>
										<td GH="100" GCol="text,PROC_NM" style="text-align: center;">공정명</td>
										<td GH="100" GCol="text,MACH_CD" style="text-align: center;">설비코드</td>
										<td GH="140" GCol="text,MACH_NM" style="text-align: center;">설비명</td>
										<td GH="100" GCol="text,MACHINE" style="text-align: center;">생산호기</td>
										<!-- <td GH="200" GCol="text,MACHINE_NM">생산호기명</td> -->
										<td GH="150" GCol="text,WRK_ORDR_NO" style="text-align: center;">작업지시번호</td>
										<td GH="100" GCol="text,WRK_ORDR_SEQNO" style="text-align:right;">지시순번</td>
										<td GH="140" GCol="text,MATNR" style="text-align: center;">자재코드</td>
										<td GH="320" GCol="text,MATNR_NM" style="text-align: center;">자재명</td>
										<td GH="100" GCol="text,VBELN" style="text-align: center;">판매문서번호</td>
										<td GH="100" GCol="text,SPEC1" style="text-align: center;">규격</td>
										<td GH="100" GCol="text,PLN_UNIT" style="text-align: center;">단위</td>
										<td GH="100" GCol="text,WRK_ORDR_QTY" GF="N 13,3">지시량</td>
										<td GH="100" GCol="text,PRFM_UNIT" style="text-align: center;">단위</td>
										<td GH="100" GCol="text,PRFM_QTY" GF="N 13,3">실적량</td>
										<td GH="100" GCol="text,ACH_RATE" GF="N 5,3">달성률</td>
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