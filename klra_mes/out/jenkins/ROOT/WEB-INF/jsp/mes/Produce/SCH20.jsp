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
	    	url : "/mes/Produce/SCH20/json/datalist.data",
	    	bigdata : false
	    });
		
		gridList.setGrid({
	    	id : "gridListSub",
	    	url : "/mes/Produce/SCH20/json/datalist.data",
	    	bigdata : false,
	    	selectRowDeleteType : true
	    });
	});
	
	// 조회(HEADER)
	function searchList(){
		if(validate.check("searchArea")){
			gridList.resetGrid("gridListSub")
			
			var param = inputList.setRangeParam("searchArea");
			param.put("P_TYPE","LIST");
			
			gridList.gridList({
				id : "gridList",
				param : param
			});
		}
	}
	
	// 조회(ITEM)
	const searchSubList = (gridId,rowNum) => {
		const data = gridList.getRowData(gridId, rowNum)
		
		const param = new DataMap();
		param.put("P_TYPE","SUB_LIST");
		param.put("WERKS",data.get("WERKS"))
		param.put("MACH_CD",data.get("MACH_CD"))
		param.put("PLN_YR",$("#PLN_YR").val())
		
		gridList.gridList({
			id : "gridListSub",
			param : param
		});
	}
	
	// 저장
	function saveData(){
		if(gridList.getModifyRowCount("gridListSub") == 0 ){
			commonUtil.msgBox("MASTER_M0545");
			return;
		}
		
		if(!commonUtil.msgConfirm(configData.MSG_MASTER_SAVE_CONFIRM)){
			return;
		}
		
		if(gridList.validationCheck("gridListSub", "all")){
			var list = gridList.getGridData("gridListSub");
	
			var param = new DataMap();
			
			param.put("P_TYPE","SAVE");
			param.put("list", list);
			
			// getRowData : 행 데이터
			// getFocusRowNum : 포커스가 위치한 행 번호
			const row = gridList.getFocusRowNum("gridList")
			const data = gridList.getRowData("gridList", row)
			param.put("WERKS",data.get("WERKS"))
			param.put("MACH_CD",data.get("MACH_CD"))
			param.put("PLN_YR",$("#PLN_YR").val())
	
			var json = netUtil.sendData({
				url : "/mes/Produce/SCH20/json/datalist.data",
				param : param
			});
			
			if(json){
				if(json.data){
					searchSubList("gridList",row) // 조회(ITEM)
				}
			}
		}
	}
	
	// 복사
	function copyData(){
		page.linkPopOpen("/mes/Produce/SCH20_POP01.page",null,"height=1000,width=600,resizable=yes");
	}
	
	// 버튼 클릭(조회, 저장 등)
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
		}else if(btnName === "Save"){
			saveData()
		}else{
			copyData()
		}
	}
	
	// 행 더블클릭
	const gridListEventRowDblclick = (gridId, rowNum, colName, colValue) => {
		if(gridId === "gridList"){
			searchSubList(gridId,rowNum)
		}
	}
	
	// 행 추가 하기 전 호출(조회를 하지 않고 행 추가 방지)
	const gridListEventRowAddBefore = (gridId, rowNum, beforeData) => {
		// getFocusRowNum : 포커스가 위치한 행 번호
		const row = gridList.getFocusRowNum("gridList")
		if(row === -1){
			alert("조회를 먼저 실행하고 행 추가가 가능합니다.")
			return false
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
						<dt CL="STD_MACH_CD"></dt>
						<dd>
							<input type="text" class="input" name="MACH_CD" UIInput="S,MACH" UIFormat="U"/>
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
			<div class="content-horizontal-wrap" style="height: calc(100%);">
				<div class="content_layout tabs" style="float: left; width: calc(35% - 10px);">
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
								<table class="table_b">
									<tbody id="gridList">
										<tr CGRow="true">
											<td GH="40" GCol="rownum">1</td>
											<td GH="40" GCol="rowCheck"></td>
											<td GH="100" GCol="text,WERKS" style="text-align:center;">플랜트</td>
											<td GH="100" GCol="text,MACH_CD" style="text-align:center;">설비코드</td>
											<td GH="200" GCol="text,MACH_NM">설비명</td>
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
				<div class="content_layout tabs" style="float: right; width: calc(65% - 10px);">
					<ul class="tab tab_style02">
						<li><a href="#tab1-2"><span CL="STD_DETAIL">상세</span></a></li>
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
											<td GH="300" GCol="input,MGMT_ITEM_NM">관리항목명</td>
											<td GH="150" GCol="select,UNIT"> <!-- 단위 -->
												<select class="input" CommonCombo="UNIT">
													<option value=""></option>
												</select>
											</td>
											<td GH="150" GCol="input,DEPT_CD,DEPT">부서코드</td>
											<td GH="200" GCol="text,DEPT_NM">부서명</td>
										</tr>
									</tbody>
								</table>
							</div>
						</div>
						<jsp:include page="/WEB-INF/jsp/common/commonBtnAuth.jsp">
							<jsp:param name="authCd" value="2" />
							<jsp:param name="showAuthCd" value="1,2,3,4,5,6,9,10" />
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