<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>MES</title>
<%@ include file="/common/include/webdek/head.jsp" %>
<script type="text/javascript">
	$(document).ready(function(){
		// 설비조회
		gridList.setGrid({
	    	id : "gridListTop",
	    	url : "/mes/Produce/SCH21/json/datalist.data",
	    	bigdata : false
	    });
		
		// 설비별 월별 조회
		gridList.setGrid({
	    	id : "gridList",
	    	url : "/mes/Produce/SCH21/json/datalist.data",
	    	bigdata : false
	    });
		
		// 설비별 목표 항목정보 조회
		gridList.setGrid({
	    	id : "gridListSub",
	    	url : "/mes/Produce/SCH21/json/datalist.data",
	    	bigdata : false,
	    	selectRowDeleteType : true,
	    	colHoldType : true,
	    	colHold : "MACH_CD,MACH_NM,MACH_SHRT_NM,PROC_CD,WERKS"
	    });
	});
	
	// 설비조회
	const searchListTop = () => {
		if(validate.check("searchArea")){
			var param = inputList.setRangeParam("searchArea");
			param.put("P_TYPE","TOP");
			
			gridList.gridList({
				id : "gridListTop",
				param : param
			}); 
		}
	}
	
	// 설비별 월별 조회
	const searchList = (rowNum) => {
		// 설비코드
		const MACH_CD = gridList.getColData("gridListTop", rowNum, "MACH_CD");
		
		var param = inputList.setRangeParam("searchArea");
		param.put("P_TYPE", "LIST");
		param.put("MACH_CD", MACH_CD);

		gridList.gridList({
			id : "gridList",
			param : param
		});
	}
	
	// 설비별 목표 항목정보 조회
	const searchListSub = (rowNum) => {
		// 설비코드
		const MACH_CD = gridList.getColData("gridList", rowNum, "MACH_CD");
		// 월
		const PLN_MM = gridList.getColData("gridList", rowNum, "PLN_MM");
		
		var param = inputList.setRangeParam("searchArea");
		param.put("P_TYPE", "SUB_LIST");
		param.put("MACH_CD", MACH_CD);
		param.put("PLN_MM", PLN_MM);

		gridList.gridList({
			id : "gridListSub",
			param : param
		});
	}
	
	// 행 더블 클릭
	const gridListEventRowDblclick = (gridId, rowNum) => {
		if(gridId === "gridListTop"){
			searchList(rowNum);
			gridList.resetGrid("gridListSub")
		}else if(gridId == "gridList"){
			searchListSub(rowNum)
		}
	}
	
	// 저장
	const saveData = () => {
		if(validate.check("searchArea")){
			if(gridList.getModifyRowCount("gridListSub") == 0 ){
				commonUtil.msgBox("MASTER_M0545");
				return;
			}
			
			if(!commonUtil.msgConfirm(configData.MSG_MASTER_SAVE_CONFIRM)){
				return;
			}
			
			if(gridList.validationCheck("gridListSub", "all")){
				const list = gridList.getGridData("gridListSub");
		
				var param = new DataMap();
				
				param.put("P_TYPE","SAVE");
				param.put("list", list);
				
				// 포커스 된 행번호
				const rowNum = gridList.getSelectIndex("gridList")
				
				// 설비코드
				const MACH_CD = gridList.getColData("gridList", rowNum, "MACH_CD");
				// 월
				const PLN_MM = gridList.getColData("gridList", rowNum, "PLN_MM");
				
				param.put("WERKS",$("#WERKS").val())
				param.put("PLN_YR",$("#PLN_YR").val())
				param.put("MACH_CD", MACH_CD);
				param.put("PLN_MM",PLN_MM)
				
				netUtil.send({
					url : "/mes/Produce/SCH21/json/datalist.data",
					param : param,
					successFunction : "saveSuccessCallBack"
				});
			}
		}
	}
	
	// 저장 성공
	function saveSuccessCallBack(json){
		if(json && json.data){
			commonUtil.msgBox(configData.MSG_SYSTEM_SAVEOK);

			gridList.resetGrid("gridList")
			gridList.resetGrid("gridListSub")
		}
	}
	
	// 복사
	const copyData = () => {
		page.linkPopOpen("/mes/Produce/SCH21_POP01.page",null,"height=500,width=1000,resizable=yes");
	}
	
	// 버튼 클릭(저장, 조회)
	function commonBtnClick(btnName){
		if(btnName == "Search"){
			var param = new DataMap();
	        param.put("PROGID", "<%= menuId%>");
	        param.put("LGTYPE", "SEARCH");
	        var json = netUtil.sendData({
	            url: "/mes/system/json/saveLog.data",
	            param : param
	        });
			
	        searchListTop()
	        
	        gridList.resetGrid("gridList")
			gridList.resetGrid("gridListSub")
		}else if(btnName === "Save"){
			saveData()
		}else{
			copyData()
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
					<input type="button" id="button-0-3" CB="Copy COPY BTN_COPY"/>
					<input type="button" id="button-0-2" CB="Save SAVE BTN_SAVE"/>
				</div>
			</div>
			<div class="search_inner">
				<div class="search_wrap ">
					<dl>
						<dt CL="STD_PLANT">플랜트</dt>
						<dd>
							<input type="text" class="input" id="WERKS" name="WERKS" UIInput="S,PLANT" UIFormat="U" validate="required" />
						</dd>
					</dl>
					<dl>
						<dt CL="STD_MACH_CD">설비코드</dt>
						<dd>
							<input type="text" class="input" id="MACH_CD" name="MACH_CD" UIInput="S,MACH" UIFormat="U"/>
						</dd>
					</dl>
					<dl>
						<dt CL="STD_PLN_YR"></dt>
						<dd>
							<select class="input" id="PLN_YR" name="PLN_YR" CommonCombo="PLN_YR"></select>
						</dd>
					</dl>
				</div>
				<div class="btn_tab">
					<input type="button" class="btn_more" value="more" onclick="searchMore()"/>
				</div>
			</div>
		</div>
		
        <div class="search_next_wrap">
		<div class="content_layout tabs top_layout" style="height:40%">
			<ul class="tab tab_style02">
				<li><a href="#tab1-1"><span>일반</span></a></li>
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
							<tbody id="gridListTop">
								<tr CGRow="true">
									<td GH="100" GCol="text,MACH_CD" style="text-align:center;">설비코드</td>
									<td GH="140" GCol="text,MACH_NM">설비명</td>
									<td GH="100" GCol="text,MACH_SHRT_NM">설비명(단축)</td>
									<td GH="100" GCol="text,PROC_CD" style="text-align:center;">공정코드</td>
									<td GH="100" GCol="text,WERKS" style="text-align:center;">플랜트코드</td>
									<td GH="140" GCol="text,PROC_NM">공정명</td>
									<td GH="100" GCol="text,PROC_GRP_CD" style="text-align:center;">공정그룹코드</td>
									<td GH="100" GCol="text,PROC_GRP_NM">공정그룹명</td>
									<td GH="200" GCol="text,PLANTNM">플랜트명</td>
									<td GH="100" GCol="text,BUSICD" style="text-align:center;">사업부코드</td>
									<td GH="100" GCol="text,BUSINM">사업부명</td>
									<td GH="100" GCol="text,PROD_GRP_CD" style="text-align:center;">제품군코드</td>
									<td GH="100" GCol="text,PROD_GRP_NM">제품군명</td>
									<td GH="100" GCol="text,LINE" style="text-align:center;">라인</td>
									<td GH="100" GCol="text,IFMC" style="text-align:center;">인터폴더호기</td>
									<td GH="100" GCol="text,INST_DT" GF="D" style="text-align:center;">도입년월</td>
									<td GH="100" GCol="text,ASST_NO" >자산번호</td>
									<td GH="100" GCol="text,PRD_UNIT">셍신단위</td>
									<td GH="100" GCol="text,DISPO_DT" GF="D" style="text-align:center;">폐기년월</td>
									<td GH="100" GCol="text,SAP_WRK_CD" style="text-align:center;">SAP작업장코드</td>
									<td GH="100" GCol="text,SAP_WRK_NM">SAP작업장명</td>
									<td GH="100" GCol="text,SAP_COST_CD" style="text-align:center;">SAP코스트센터</td>
									<td GH="100" GCol="text,WCS_WRK_CD" style="text-align:center;">WCS설비코드</td>
									<td GH="100" GCol="text,WCS_WRK_NM">WCS설비명</td>
									<td GH="100" GCol="text,PRFM_GTHR_YN" style="text-align:center;">실적수집여부</td>
									<td GH="140" GCol="text,ABN_STD_TM" GF="T">비가동 기준시간</td>
									<td GH="140" GCol="text,CYCLE_TM" GF="T">싸이클타임</td>
									<td GH="140" GCol="text,WRK_CD" style="text-align:center;">SAP작업장코드(지시)</td>
									<td GH="100" GCol="text,MACHINE" style="text-align:center;">설비호기</td>
									<td GH="140" GCol="text,REGDATE" style="text-align:center;"></td>
									<td GH="100" GCol="text,REGNM"></td>
									<td GH="140" GCol="text,UPDDATE" style="text-align:center;"></td>
									<td GH="100" GCol="text,UPDNM"></td>
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
			<div class="content-horizontal-wrap h-wrap-min bottom_layout">
				<div class="content_layout tabs" style="float: left; width: calc(35% - 10px); height:144%">
					<ul class="tab tab_style02">
						<li><a href="#tab1-1"><span>일반</span></a></li>
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
											<td GH="0" GCol="text,MACH_CD">설비코드</td>
											<td GH="80" GCol="text,PLN_MM" style="text-align:center;">월</td>
											<td GH="100" GCol="text,REG_YN">등록여부</td>
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
				<div class="content_layout tabs" style="float: right; width: calc(65% - 10px); height:144%">
					<ul class="tab tab_style02">
						<li><a href="#tab1-1"><span>상세</span></a></li>
						<li class="btn_zoom_wrap">
	                        <ul>
	                            <li><button class="btn btn_bigger"><span>확대</span></button></li>
	                        </ul>
	                   	</li>
					</ul>
					<div class="table_box section" id="tab1-2">
						<div class="table_list01">
							<div class="scroll">
								<table class="table_c">
									<tbody id="gridListSub">
										<tr CGRow="true">
											<td GH="40" GCol="rownum">1</td>
											<td GH="40" GCol="rowCheck"></td>
											<td GH="100" GCol="text,MGMT_ITEM_CD" style="text-align: center;">관리항목코드</td>
											<td GH="200" GCol="text,MGMT_ITEM_NM">관리항목명</td>
											<td GH="100" GCol="text,UNIT_NM">단위명</td>
											<td GH="200" GCol="text,DEPT_NM">부서명</td>
											<td GH="150" GCol="input,BUSI_PLN_AMT" GF="N 10">사업계획량</td>
											<td GH="150" GCol="input,EXCTN_PLN_AMT" GF="N 10">실행계획량</td>
										</tr>									
									</tbody>
								</table>
							</div>
						</div>
						<jsp:include page="/WEB-INF/jsp/common/commonBtnAuth.jsp">
							<jsp:param name="authCd" value="2" />
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