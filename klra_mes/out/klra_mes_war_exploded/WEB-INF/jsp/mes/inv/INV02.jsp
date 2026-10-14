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
			url:"/mes/Inv/INV02/json/datalist.data",
			bigdata : false
		})
		
		// 자재그룹 select 제어
		/* 2023-03-13(월요일) 안상현, 자재그룹 검색 조건 수정
		$("#MATNR_GRP_CD").find("option").map(function(){
			//20221017 여한진 약품에 관련되서 텍스트 말고 코드로 불러오기
			const text = $(this).val()
			
			// "약품 :" 문자열을 포함하지 않을 경우
			if(text.substr(0,1).indexOf("2") === -1){
				$(this).remove()
			}
		})
		*/
		
		$("#MATNR_GRP_CD").multipleSelect("checkAll")
		inputList.reloadCombo($("#MATNR_GRP_CD"), configData.INPUT_COMBO, "airfw,COMCOMBO")
	});

	// 조회
	function searchList(){
		if(validate.check("searchArea")){			
			var param = inputList.setRangeParam("searchArea");
			
			// HEADER 조회
			param.put("P_TYPE", "LIST");
			
			gridList.gridList({
		    	id : "gridList",
		    	param : param
		    });
		}
	}
	
	// 저장(HEADER)
	function saveData(){
		if(gridList.getModifyRowCount("gridList") == 0 ){
			commonUtil.msgBox("MASTER_M0545");
			return;
		}
		
		// 설비코드 VALIDATION
		if($("#MACH_CD").val() === ""){
			alert("설비코드를 선택하세요.")
			$("#MACH_CD").focus()
			return 
		}
		
		if($("#MACH_CD").val().length != 5){
			alert("설비코드가 올바르지 않습니다.")
			$("#MACH_CD").focus()
			return 
		}
		
		// 작업조 VALIDATION
		if($("#WRK_SHIFT").val() === ""){
			alert("작업조를 선택하세요.")
			$("#WRK_SHIFT").focus()
			return 
		}
		
		if(!commonUtil.msgConfirm(configData.MSG_MASTER_SAVE_CONFIRM)){
			return;
		}
		
		var list = gridList.getModifyData("gridList", "A");
		for(let i = 0; i < list.length; i++){
			if(list[i].get("INP_QTY_BF") == " "){
				list[i].put("INP_QTY_BF","0")
			}
		}
		
		var param = new DataMap();
		
		param.put("P_TYPE","SAVE");
		param.put("list",list);

		//param.put("WERKS", $("#WERKS").val().toUpperCase())
		
		const INP_DT = $("#INP_DT").val()
		param.put("INP_DT", INP_DT.replace(/-/g,""))
		
		param.put("MACH_CD", $("#MACH_CD").val().toUpperCase())
		//param.put("MATNR_GRP_CD", $("#MATNR_GRP_CD").val())
		param.put("WRK_SHIFT", $("#WRK_SHIFT").val())
		
		var json = netUtil.sendData({
			url : "/mes/Inv/INV02/json/datalist.data",
			param : param
		});
		
		if(json){
			if(json.P_SUCCESS == "Y"){
				alert("완료되었습니다.")
				searchList();
			}else if(json.P_SUCCESS == "N"){
				alert(json.MSG);
			}
		}
	}
	
	// 행 추가 후에 실행
	const gridListEventRowAddAfter = (gridId, rowNum) => {
		// 플랜트코드 P100 고정
		gridList.setColValue(gridId, rowNum, "WERKS", "P100")
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
	
	// 팝업창에서 선택 시
	function searchHelpEventCloseAfter(searchCode, multyType, selectData, rowData){
		// 설비코드 팝업창 선택 시 
		if(searchCode === "MACH"){
			reloadCombo()
		}
	}
	
	// 수동으로 설비코드 입력 시
	function reloadCombo(){
		$comboObj = $("#WRK_SHIFT")
		
		// WRK_SHIFT SELECT BOX 값 셋팅
		inputList.reloadCombo($comboObj, configData.INPUT_COMBO, "Inv,WRK_SHIFT");
	}
	
	// combo 자동 생성 시 데이터 조회 PARAMETER 전달
	function comboEventDataBindeBefore(comboAtt){
		if(comboAtt == "Inv,WRK_SHIFT"){
			var param = new DataMap();
			
			param.put("MACH_CD", $("#MACH_CD").val().toUpperCase());
		}
		
		// 2023-03-13(월요일) 안상현, 자재그룹 검색 조건 수정
		if(comboAtt == "airfw,COMCOMBO"){
			var param = new DataMap();
			
			param.put("MENUID", "INV07")
			param.put("CODE", "MATKL")
		}
		return param;
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
				<div class="search_wrap">
					<dl>
						<dt CL="STD_PLANT">플랜트</dt>
						<dd>
							<input type="text" class="input" id="WERKS" name="WERKS" UIInput="S,PLANT" UIFormat="U" validate="required" />
							<input type="hidden" id="MACH_GUBUN" name="MACH_GUBUN" value="INPUT" />
							<input type="hidden" id="MATKY_GUBUN" name="MATKY_GUBUN" value="INPUT" />
						</dd>
					</dl>
					<dl>
						<dt CL="STD_MACH_CD">설비코드</dt>
						<dd>
							<input type="text" class="input" id="MACH_CD" name="MACH_CD" UIInput="S,MACH" UIFormat="U" onkeyup="reloadCombo()" validate="required" />
						</dd>
					</dl>
					<dl>
						<dt>자재그룹</dt>
						<dd>
							<!-- 2023-03-13(월요일) 안상현, 자재그룹 RANGE 검색 추가 -->
							<select class="input" id="MATNR_GRP_CD" name="MATNR_GRP_CD" Combo="airfw,COMCOMBO" ComboType="MS">
							</select>
						</dd>
					</dl>
					<dl>
						<dt CL="STD_MATNR">자재코드</dt>
						<dd>
							<!-- 2023-03-13(월요일) 안상현, 자재코드 RANGE 검색 추가 -->
							<input type="text" name="MATNR" UIInput="SR,MATKY" UIFormat="U"/>
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
					<li><a href="#tab1-1"><span CL="STD_GRD_INV02">투입약품</span></a></li>
					<li style="padding-top: 9px;">
						<span style="font-size : inherit; font-weight: bold;">투입일자</span>&nbsp;
                    </li>
                    <li style="padding-top: 5px;">
                    	<input type="text" class="input" style="width:80px" id="INP_DT" name="INP_DT" UIFORMAT="C N" />
                    </li>
                    <li style="padding-top: 4px;">&nbsp;&nbsp;<span style="font-size : 18px;">/</span>&nbsp;&nbsp;</li>
                    <li style="padding-top: 9px;">
						<span style="font-size : inherit; font-weight: bold;">작업반</span>&nbsp;
                    </li>
                    <li style="padding-top: 5px;">
                    	<input type="text" class="input" style="width:20px" id="WRK_CLASS" name="WRK_CLASS" value="<%=(String) request.getSession().getAttribute(CommonConfig.SES_WRK_CLASS) %>" readonly />
                    </li>
                    <li style="padding-top: 4px;">&nbsp;&nbsp;<span style="font-size : 18px;">/</span>&nbsp;&nbsp;</li>
                    <li style="padding-top: 9px;">
						<span style="font-size : inherit; font-weight: bold;">작업조</span>&nbsp;
                    </li>
                    <li style="padding-top: 5px;">
                    	<select class="input" id="WRK_SHIFT" name="WRK_SHIFT" Combo="Inv,WRK_SHIFT" validate="required">
                    		<option value="">선택</option>
						</select>
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
							<table class="table_c">
								<tbody id="gridList">
									<tr CGRow="true">
										<td GH="40" GCol="rownum">1</td>	
										<td GH="40" GCol="rowCheck"></td>
										<td GH="80" GCol="text,WERKS" style="text-align:center;">플랜트</td>
										<td GH="80" GCol="text,MATNR_GRP_CD" style="text-align:center;">자재그룹</td>
										<td GH="200" GCol="text,MATNR_GRP_NM" style="text-align:center;">자재그룹명</td>	
										<td GH="140" GCol="text,MATNR" style="text-align:center;">자재코드</td>
										<td GH="320" GCol="text,MATNR_NM" style="text-align:center;">자재명</td>
										<td GH="60" GCol="text,UNIT" style="text-align:center;">단위</td>
										<td GH="100" GCol="text,STOR_LOC_CD" style="text-align:center;">저장위치</td>
										<td GH="100" GCol="text,STOR_LOC_NM" style="text-align:center;">저장위치명</td>
										<td GH="100" GCol="text,STCK_QTY" GF="N 13,3">현재고</td>
										<td GH="100" GCol="input,INP_QTY" GF="N 13,3">투입량</td>
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