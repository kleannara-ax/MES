<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Grid default</title>
<%@ include file="/common/include/webdek/head.jsp" %>
<link rel="stylesheet" type="text/css" href="/common/theme/webdek/css/demo_layout.css">
<script type="text/javascript">
	var buttomAutoResize = false;
	$(document).ready(function(){
		
// 		gridList.setGrid({
// 			id : "gridList1",
// 	    	url : loadUrl,
// 	    	bigdata : false
// 	    });
		
		/* gridList.setGrid({
			id : "gridList1", module : "Common",
			command : "DASHBOARD_PRFM_CMPRD_TO_TRGT",
			firstRowFocusType : false,
			emptyMsgType : false
	    }); */
		gridList.setGrid({
			id : "gridList2", module : "Common",
			command : "DASHBOARD_PRD_STAT",
			emptyMsgType : false,
			firstRowFocusType : false,
			colGroupCols : "PLANT"
	    });
		/* gridList.setGrid({
			id : "gridList3", module : "Common",
			command : "",
			emptyMsgType : false,
			firstRowFocusType : false,
			colGroupCols : "PLANT"
	    }); */
		/* gridList.setGrid({
			id : "gridList4", module : "Common",
			command : "DASHBOARD_INDQT_STAT",
			emptyMsgType : false,
			firstRowFocusType : false,
			colGroupCols : "PLANT"
	    }); */
		gridList.setGrid({
			id : "gridList5", module : "Common",
			command : "DASHBOARD_DISPO_STAT",
			emptyMsgType : false,
			firstRowFocusType : false,
			colGroupCols : "PLANT"
	    });
		gridList.setGrid({
			id : "gridList6", module : "Common",
			command : "DASHBOARD_NON_OPERATE_STAT_ACCR",
			emptyMsgType : false,
			firstRowFocusType : false,
			colGroupCols : "PLANT"
	    });
		gridList.setGrid({
			id : "gridList7", module : "Common",
			command : "DASHBOARD_NON_OPERATE_STAT_CRNT",
			emptyMsgType : false,
			firstRowFocusType : false,
			colGroupCols : "PLANT"
	    });
		gridList.setGrid({
			id : "gridList8", module : "Common",
			command : "DASHBOARD_PLANT_DAILY_STATE",
			emptyMsgType : false,
			firstRowFocusType : false,
			colGroupCols : "PLANT"
	    });
		
// 		setGrid_dshBrd('gridList1, gridList2, gridList3, gridList4, gridList5, gridList6, gridList7');
		
		$('.btn_lit.tableUtil').hide();
		
		searchList();
	});
	
	
	function setGrid_dshBrd(cmaStr) {
		const loadUrl = "/mes/Master/MAS10/json/datalist.data";
		const cmaStrArr = cmaStr.split(',');
		for (let i = 0; i < cmaStrArr.length; i++) {
			gridList.setGrid({
				id : $.trim(cmaStrArr[i]),
		    	url : loadUrl,
		    	bigdata : false
		    });
		}
	}
	
	
	function loadGrdList_dshBrd(prm, cmaStr) {
		const cmaStrArr = cmaStr.split(',');
		for (let i = 0; i < cmaStrArr.length; i++) {
			gridList.gridList({
		    	id : $.trim(cmaStrArr[i]),
		    	param : prm
		    });
		}
	}
	
	
	function searchList() {
		if (validate.check("searchArea")) {
			var prm = inputList.setRangeParam("searchArea");
			
			prm.put("P_TYPE", "LIST");
			
			//loadGrdList_dshBrd(prm, 'gridList1, gridList2, gridList3, gridList4, gridList5, gridList6, gridList7');
			loadGrdList_dshBrd(prm, 'gridList2, gridList5, gridList6, gridList7, gridList8');
			//loadGrdList_dshBrd(prm, 'gridList2, gridList5, gridList6, gridList7');
		}
	}
	
// 	function saveData(){
// 		if(gridList.validationCheck("gridList", "all")){
// 			gridList.gridSave({
// 		    	id : "gridList",
// 		    	modifyType : "A"
// 		    });
// 		}
// 	}

	function commonBtnClick(btnName){
		//commonUtil.debugMsg("commonBtnClick : ", arguments);
		if(btnName == "Search"){
			searchList();
		}
// 		else if(btnName == "Save"){
// 			saveData();
// 		}
	}
	
	
	function opn_trgtMenu_from_dshbrd(trgtMenuNm) {
		if (trgtMenuNm == '설비별 생산 진행현황') {
			$(window.parent.frames[1].document).find('span:contains("모니터링")').click();
			$(window.parent.frames[1].document).find('span:contains("'+trgtMenuNm+'")').click();
		} else if (trgtMenuNm == '비가동 이력조회') {
			$(window.parent.frames[1].document).find('span:contains("공정현황")').click();
			$(window.parent.frames[1].document).find('span:contains("'+trgtMenuNm+'")').click();
		} else if (trgtMenuNm == "폐품 현황") {
			$(window.parent.frames[1].document).find('span:contains("공정현황")').click();
			$(window.parent.frames[1].document).find('span:contains("'+trgtMenuNm+'")').click();
		} else if (trgtMenuNm == '부적합 리스트') {
			$(window.parent.frames[1].document).find('span:contains("품질관리")').click();
			$(window.parent.frames[1].document).find('span:contains("부적합처리")').click();
			$(window.parent.frames[1].document).find('span:contains("'+trgtMenuNm+'")').click();
		} else if (trgtMenuNm == '일일 생산 실적현황') {
			$(window.parent.frames[1].document).find('span:contains("공정현황")').click();
			$(window.parent.frames[1].document).find('span:contains("'+trgtMenuNm+'")').click();
		}
	}
	
	
	function opn_trgtMenu_from_dshbrd_old(trgtMenuNm) {
// 		var leftFrmObj = window.document.getElementById('left');
// 		console.log('left doc = ', leftFrmObj);
// 		window.parent.frames[1].document
// 		leftFrmObj.searchList_left3(trgtMenuNm);
// 		var leftFrmObjCntnt = (leftFrmObj .contentWindow || leftFrmObj .contentDocument);
// 		leftFrmObjCntnt.searchList_left3(trgtMenuNm);
// 		window.document.getElementById('left').contentWindow.searchList_left3(trgtMenuNm);

// 		alert(trgtMenuNm);
// 		alert('ㄹㄷ');
// 		alert('ㄹㄷ = '+$(window.parent.frames[1].document).find('#menuSearch').val() );

		$(window.parent.frames[1].document).find('#menuSearch').val(trgtMenuNm);
		$(window.parent.frames[1].document).find('.btn.btn_search.btn_search_change').click();
		$(window.parent.frames[1].document).find('#menuSearch').val('');
		setTimeout(function() {
			$(window.parent.frames[1].document).find('span:contains("'+trgtMenuNm+'")').click();
		}, 700);
		
// 		$(window.parent.frames[1].document).find('span:contains("설비별 생산 진행현황")').click();
// 		window.document.getElementById('left').contentDocument.searchList_left3(trgtMenuNm);
// 		searchList_left3(trgtMenuNm);
	}
	
</script>
</head>
<body style="min-width:1394px;">
<%@ include file="/common/include/webdek/layout.jsp" %>
<!-- content -->
<div class="content_wrap">
	<div class="content_inner">
		<%@ include file="/common/include/webdek/title.jsp" %>
<!-- 		<div class="content_serch" id="searchArea"> -->
		
<!-- 			<div class="btn_wrap"> -->
<!-- 				<div class="fl_l"> -->
<!-- 				</div> -->
<!-- 				<div class="fl_r"> -->
<!-- 					<input type="button" CB="Search SEARCH BTN_SEARCH" /> -->
<!-- 					<input type="button" CB="Save SAVE BTN_SAVE" /> -->
<!-- 				</div> -->
<!-- 			</div> -->

<!-- 			<div class="search_inner"> -->
<!-- 				<div class="search_wrap "> -->
<!-- 					<dl> -->
<!-- 						<dt CL="Search"></dt> -->
<!-- 						<dd> -->
<!-- 							<input type="text" class="input" name="Search" UIInput="S,SHAREMA" IAname="Search" UIFormat="U"/> -->
<!-- 						</dd> -->
<!-- 					</dl> -->
<!-- 				</div> -->
<!-- 				<div class="btn_tab"> -->
<!-- 					<input type="button" class="btn_more" value="more" onclick="searchMore()"/> -->
<!-- 				</div> -->
<!-- 			</div> -->
<!-- 		</div> -->
        <div class="search_next_wrap">
			<div class="content-horizontal-wrap tabs top_layout" style='height:53.5%;'>
				<%-- <ul class="tab tab_style02">
					<li>
						<a href="#tab1-1" style="padding: 10px 0px;">
							<img src="/common/theme/webdek/images/btn_to_right.png" width="15" height="15" />
							<span>목표대비 실적</span>
						</a>
					</li>
<!-- 					<li><a href="#tab1-2"><span>상세</span></a></li> -->
					<li class="btn_zoom_wrap">
						<ul>
							<!-- <li><button class="btn btn_smaller"><span>축소</span></button></li> -->
							<li><button class="btn btn_bigger"><span>확대</span></button></li>
						</ul>
					</li>
				</ul>
				<div class="table_box section" id="tab1-1">
					<div class="table_list01">
						<div class="table_thead tableHeader" style="margin-left: 0px;">
							<table>
								<colgroup>
									<col width="70px" />
									<col width="120px" />
									<col width="140px" />
									<col width="130px" />
									<col width="130px" />
									<col width="110px" />
									<col width="130px" />
									<col width="130px" />
									<col width="80px" />
									<col width="130px" />
									<col width="130px" />
									<col width="80px" />
								</colgroup>
								<thead>
									<tr>
										<th CL='STD_NUMBER' rowspan="2">번호</th>
										<th CL='STD_PROCESS' rowspan="2"></th>
										<th CL='STD_MACH_NM' rowspan="2"></th>
										<th CL='STD_MGMT_ITEM_NM' rowspan="2"></th>
										<th CL='STD_MGMT_DEPT_NM' rowspan="2"></th>
										<th CL='STD_UNIT' rowspan="2"></th>
										<th CL='STD_BUSI_PLN' colspan="3"></th>
										<th CL='STD_EXCTN_PLN' colspan="3"></th>
									</tr>
									<tr>
										<th CL='STD_GOALS'></th>
										<th CL='STD_PRFM'></th>
										<th CL='STD_ACH_RATE'></th>
										<th CL='STD_GOALS'></th>
										<th CL='STD_PRFM'></th>
										<th CL='STD_ACH_RATE'></th>
									</tr>
								</thead>
							</table>
						</div>
						<div class="scroll" style="height: calc(100% - 77px)">
							<table class="table_c1">
								<colgroup>
									<col width="70px" />
									<col width="120px" />
									<col width="140px" />
									<col width="130px" />
									<col width="130px" />
									<col width="110px" />
									<col width="130px" />
									<col width="130px" />
									<col width="80px" />
									<col width="130px" />
									<col width="130px" />
									<col width="80px" />
								</colgroup>
								<tbody id="gridList1">
									<tr CGRow="true">
										<td GCol="rownum" style="text-align:center;">1</td>
										<td GCol="text,PROCESS" style="text-align:left;">공정</td>
										<td GCol="text,MACH_NM" style="text-align:left;">설비명</td>
										<td GCol="text,MGMT_ITEM_NM" style="text-align:left;">관리항목명</td>
										<td GCol="text,MGMT_DEPT_NM" style="text-align:left;">관리부서</td>
										<td GCol="text,UNIT" style="text-align:left;">단위</td>
										<td GCol="text,BUSI_PLN_GOALS" style="text-align:right;" GF="N 9,2">목표</td>
										<td GCol="text,BUSI_PLN_PRFM" style="text-align:right;" GF="N 9,2">실적</td>
										<td GCol="text,BUSI_ACH_RATE" style="text-align:right;">달성율</td>
										<td GCol="text,EXCTN_PLN_GOALS" style="text-align:right;" GF="N 9,2">목표</td>
										<td GCol="text,EXCTN_PLN_PRFM" style="text-align:right;" GF="N 9,2">실적</td>
										<td GCol="text,EXCTN_ACH_RATE" style="text-align:right;">달성율</td>
<!-- 										<td GCol="text,PROCESS" style="text-align:center;">공정</td> -->
<!-- 										<td GCol="text,MACH_NM" style="text-align:center;">설비명</td> -->
<!-- 										<td GCol="text,MGMT_ITEM_NM" style="text-align:center;">관리항목명</td> -->
<!-- 										<td GCol="text,MGMT_DEPT_NM" style="text-align:center;">관리부서</td> -->
<!-- 										<td GCol="text,UNIT" style="text-align:center;">단위</td> -->
<!-- 										<td GCol="text,BUSI_PLN_GOALS" style="text-align:right;" GF="N 9,2">목표</td> -->
<!-- 										<td GCol="text,BUSI_PLN_PRFM" style="text-align:right;" GF="N 9,2">실적</td> -->
<!-- 										<td GCol="text,BUSI_ACH_RATE" style="text-align:right;">달성율</td> -->
<!-- 										<td GCol="text,EXCTN_PLN_GOALS" style="text-align:right;" GF="N 9,2">목표</td> -->
<!-- 										<td GCol="text,EXCTN_PLN_PRFM" style="text-align:right;" GF="N 9,2">실적</td> -->
<!-- 										<td GCol="text,EXCTN_ACH_RATE" style="text-align:right;">달성율</td> -->
									</tr>									
								</tbody>
							</table>
						</div>
					</div>
					<jsp:include page="/WEB-INF/jsp/common/commonBtnAuth.jsp">
						<jsp:param name="authCd" value="1" />
						<jsp:param name="showAuthCd" value="1,2,3,9,10" />
					</jsp:include>	
				</div> --%>
				<div class="content-vertical-wrap content_left">	
					<div class="content_layout tabs content_H_3set" style="height: 440px;padding: 20px 35px;">
						<ul class="tab tab_style02">
							<li onclick="opn_trgtMenu_from_dshbrd('일일 생산 실적현황');">
								<a href="#tab1-1" style="padding: 10px 0px;">
									<img src="/common/theme/webdek/images/btn_to_right.png" width="15" height="15" />
									<span>생산 현황</span>
								</a>
							</li>
							<li class="btn_zoom_wrap">
								<ul>
									<!-- <li><button class="btn btn_smaller"><span>축소</span></button></li> -->
									<li><button class="btn btn_bigger"><span>확대</span></button></li>
								</ul>
							</li>
						</ul>
						<div class="table_box section" id="tab1-1">
							<div class="table_list01" style="height: 100%">
								<div class="table_thead tableHeader" style="margin-left: 0px;">
									<table>
										<colgroup>
											<col width="80px" />
											<col width="130px" />
											<col width="60px" />
											<col width="130px" />
											<col width="130px" />
											<col width="130px" />
										</colgroup>
										<thead>
											<tr>
												<th CL='STD_PLANT' rowspan="2"></th>
												<th CL='STD_PROCESS' rowspan="2"></th>
												<th CL='STD_UNIT' rowspan="2"></th>
												<th CL='STD_PRFM' colspan="3"></th>
		<!-- 										<th CL='STD_PRFM_WGT' colspan="3"></th> -->
											</tr>
											<tr>
												<th CL='STD_PRV_MNTH'></th>
												<th CL='STD_THIS_MNTH'></th>
												<th CL='STD_VRY_DAY'></th>
											</tr>
										</thead>
									</table>
								</div>
								<div class="scroll" style="height: calc(100% - 60px)">
									<table class="table_c1">
										<colgroup>
											<col width="80px" />
											<col width="130px" />
											<col width="60px" />
											<col width="130px" />
											<col width="130px" />
											<col width="130px" />
										</colgroup>
										<tbody id="gridList2">
											<tr CGRow="true">
												<td GCol="text,PLANT" style="text-align:center;">플랜트</td>
												<td GCol="text,PROCESS" style="text-align:left;">공정</td>
												<td GCol="text,UNIT" style="text-align:left;">단위</td>
												<td GCol="text,PRV_MNTH" style="text-align:right;" GF="N 13,2">전월</td>
												<td GCol="text,THIS_MNTH" style="text-align:right;" GF="N 13,2">당월</td>
												<td GCol="text,VRY_DAY" style="text-align:right;" GF="N 13,2">당일</td>
		<!-- 										<td GCol="text,PROCESS" style="text-align:center;">공정</td> -->
		<!-- 										<td GCol="text,PRV_MNTH" style="text-align:right;">전월</td> -->
		<!-- 										<td GCol="text,THIS_MNTH" style="text-align:right;" GF="N 13,2">당월</td> -->
		<!-- 										<td GCol="text,VRY_DAY" style="text-align:right;" GF="N 13,2">당일</td> -->
											</tr>									
										</tbody>
									</table>
								</div>
							</div>
		<%-- 					<jsp:include page="/WEB-INF/jsp/common/commonBtnAuth.jsp"> --%>
		<%-- 						<jsp:param name="authCd" value="1" /> --%>
		<%-- 						<jsp:param name="showAuthCd" value="1,2,3,9,10" /> --%>
		<%-- 					</jsp:include>	 --%>
						</div>
					</div>
				</div>
				<div class="content-vertical-wrap content_right">
					<div class="content_layout tabs content_H_3set" style="height: 440px;padding: 20px 35px;">
						<ul class="tab tab_style02">
							<li onclick="opn_trgtMenu_from_dshbrd('폐품 현황');">
								<a href="#tab1-1" style="padding: 10px 0px;">
									<img src="/common/theme/webdek/images/btn_to_right.png" width="15" height="15" />
									<span>폐품 현황(누적)</span>
								</a>
							</li>
							<li class="btn_zoom_wrap">
								<ul>
									<!-- <li><button class="btn btn_smaller"><span>축소</span></button></li> -->
									<li><button class="btn btn_bigger"><span>확대</span></button></li>
								</ul>
							</li>
						</ul>
						<div class="table_box section" id="tab1-1">
							<div class="table_list01" style="height: 100%">
								<div class="table_thead tableHeader" style="margin-left: 0px;">
									<table>
										<colgroup>
											<col width="80px" />
											<col width="120px" />
											<col width="60px" />
											<col width="130px" />
											<col width="130px" />
											<col width="130px" />
										</colgroup>
										<thead>
											<tr>
												<th CL='STD_PLANT' rowspan="2"></th>
												<th CL='STD_DISPO_DIV' rowspan="2"></th>
												<th CL='STD_UNIT' rowspan="2"></th>
												<th CL='STD_DISPO_CAPA' colspan="3"></th>
<!-- 												<th CL='STD_DISPO_WGT' colspan="3"></th> -->
											</tr>
											<tr>
												<th CL='STD_PRV_MNTH'></th>
												<th CL='STD_THIS_MNTH'></th>
												<th CL='STD_VRY_DAY'></th>
											</tr>
										</thead>
									</table>
								</div>
								<div class="scroll" style="height: calc(100% - 60px)">
									<table class="table_c1">
										<colgroup>
											<col width="80px" />
											<col width="120px" />
											<col width="60px" />
											<col width="130px" />
											<col width="130px" />
											<col width="130px" />
										</colgroup>
										<tbody id="gridList5">
											<tr CGRow="true">
												<td GCol="text,PLANT" style="text-align:center;">플랜트</td>
												<td GCol="text,DISPO_DIV" style="text-align:left;">폐품유형</td>
												<td GCol="text,UNIT" style="text-align:left;">단위</td>
												<td GCol="text,PRV_MNTH" style="text-align:right;" GF="N 13,2">전월</td>
												<td GCol="text,THIS_MNTH" style="text-align:right;" GF="N 13,2">당월</td>
												<td GCol="text,VRY_DAY" style="text-align:right;" GF="N 13,2">당일</td>
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
			<%-- <div class="content-horizontal-wrap h-wrap-min bottom_layout" style="min-height: 450px;">
				<div class="content-vertical-wrap content_right">
					<div class="content_layout tabs content_H_3set" style="height: 440px;">
						<ul class="tab tab_style02">
							<li>
								<a href="#tab1-1" style="padding: 10px 0px;">
									<img src="/common/theme/webdek/images/btn_to_right.png" width="15" height="15" />
									<span>수율 현황</span>
								</a>
							</li>
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
									<table class="table_c1">
										<tbody id="gridList3">
											<tr CGRow="true">
												<td GH="80" GCol="text,PLANT" style="text-align:center;">플랜트</td>
												<td GH="120" GCol="text,PROCESS" style="text-align:left;">공정</td>
												<td GH="120" GCol="text,THRTCL_OUTPUT_CNT" style="text-align:right;">이론생산량(개)</td>
												<td GH="120" GCol="text,OUTPUT_CNT" style="text-align:right;">생산량(개)</td>
												<td GH="110" GCol="text,PCKNG_QNTTY_BOX_DVD_Pallet" style="text-align:right;">포장량(BOX/Pallet)</td>
												<td GH="60" GCol="text,LOSS_PRCNTG" style="text-align:right;">LOSS(%)</td>
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
						<ul class="tab tab_style02">
							<li onclick="opn_trgtMenu_from_dshbrd('폐품 현황');">
								<a href="#tab1-1" style="padding: 10px 0px;">
									<img src="/common/theme/webdek/images/btn_to_right.png" width="15" height="15" />
									<span>폐품 현황(누적)</span>
								</a>
							</li>
							<li class="btn_zoom_wrap">
								<ul>
									<!-- <li><button class="btn btn_smaller"><span>축소</span></button></li> -->
									<li><button class="btn btn_bigger"><span>확대</span></button></li>
								</ul>
							</li>
						</ul>
						<div class="table_box section" id="tab1-1">
							<div class="table_list01">
								<div class="table_thead tableHeader" style="margin-left: 0px;">
									<table>
										<colgroup>
											<col width="80px" />
											<col width="120px" />
											<col width="60px" />
											<col width="130px" />
											<col width="130px" />
											<col width="130px" />
										</colgroup>
										<thead>
											<tr>
												<th CL='STD_PLANT' rowspan="2"></th>
												<th CL='STD_DISPO_DIV' rowspan="2"></th>
												<th CL='STD_UNIT' rowspan="2"></th>
												<th CL='STD_DISPO_CAPA' colspan="3"></th>
<!-- 												<th CL='STD_DISPO_WGT' colspan="3"></th> -->
											</tr>
											<tr>
												<th CL='STD_PRV_MNTH'></th>
												<th CL='STD_THIS_MNTH'></th>
												<th CL='STD_VRY_DAY'></th>
											</tr>
										</thead>
									</table>
								</div>
								<div class="scroll" style="height: calc(100% - 77px)">
									<table class="table_c1">
										<colgroup>
											<col width="80px" />
											<col width="120px" />
											<col width="60px" />
											<col width="130px" />
											<col width="130px" />
											<col width="130px" />
										</colgroup>
										<tbody id="gridList5">
											<tr CGRow="true">
												<td GCol="text,PLANT" style="text-align:center;">플랜트</td>
												<td GCol="text,DISPO_DIV" style="text-align:left;">폐품유형</td>
												<td GCol="text,UNIT" style="text-align:left;">단위</td>
												<td GCol="text,PRV_MNTH" style="text-align:right;" GF="N 13,2">전월</td>
												<td GCol="text,THIS_MNTH" style="text-align:right;" GF="N 13,2">당월</td>
												<td GCol="text,VRY_DAY" style="text-align:right;" GF="N 13,2">당일</td>
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
			</div> --%>
			<%-- <div class="content-horizontal-wrap h-wrap-min bottom_layout" style="min-height: 450px;">
				<div class="content-vertical-wrap content_left">	
					<div class="content_layout tabs content_H_3set" style="height: 440px;">
						 <ul class="tab tab_style02">
							<li onclick="opn_trgtMenu_from_dshbrd('부적합 리스트');">
								<a href="#tab1-1" style="padding: 10px 0px;">
									<img src="/common/theme/webdek/images/btn_to_right.png" width="15" height="15" />
									<span>부적합 현황(누적)</span>
								</a>
							</li>
							<li class="btn_zoom_wrap">
								<ul>
									<!-- <li><button class="btn btn_smaller"><span>축소</span></button></li> -->
									<li><button class="btn btn_bigger"><span>확대</span></button></li>
								</ul>
							</li>
						</ul>
						<div class="table_box section" id="tab1-1">
							<div class="table_list01">
								<div class="table_thead tableHeader" style="margin-left: 0px;">
									<table>
										<colgroup>
											<col width="70px" />
											<col width="120px" />
											<col width="60px" />
											<col width="130px" />
											<col width="130px" />
											<col width="130px" />
										</colgroup>
										<thead>
											<tr>
												<th CL='STD_PLANT' rowspan="2"></th>
												<th CL='STD_PROCESS' rowspan="2"></th>
												<th CL='STD_UNIT' rowspan="2"></th>
												<th CL='STD_UCFMTY_AMT' colspan="3"></th>
<!-- 												<th CL='STD_UCFMTY_AMT_WGT' colspan="3"></th> -->
											</tr>
											<tr>
												<th CL='STD_PRV_MNTH'></th>
												<th CL='STD_THIS_MNTH'></th>
												<th CL='STD_VRY_DAY'></th>
											</tr>
										</thead>
									</table>
								</div>
								<div class="scroll" style="height: calc(100% - 77px)">
									<table class="table_c1">
										<colgroup>
											<col width="70px" />
											<col width="120px" />
											<col width="60px" />
											<col width="130px" />
											<col width="130px" />
											<col width="130px" />
										</colgroup>
										<tbody id="gridList4">
											<tr CGRow="true">
												<td GCol="text,PLANT" style="text-align:center;">플랜트</td>
												<td GCol="text,PROCESS" style="text-align:left;">공정</td>
<!-- 												<td GCol="text,PROCESS" style="text-align:left;">공정</td> -->
												<td GCol="text,UNIT" style="text-align:left;">단위</td>
												<td GCol="text,PRV_MNTH" style="text-align:right;" GF="N 9,2">전월</td>
												<td GCol="text,THIS_MNTH" style="text-align:right;" GF="N 9,2">당월</td>
												<td GCol="text,VRY_DAY" style="text-align:right;" GF="N 9,2">당일</td>
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
				<div class="content-vertical-wrap content_right">
					<div class="content_layout tabs content_H_3set" style="height: 440px;">
						
					</div>
				</div>
			</div> --%>
			<div class="content-horizontal-wrap h-wrap-min bottom_layout" style="min-height: 440px;">
				<div class="content-vertical-wrap content_left">	
					<div class="content_layout tabs content_H_3set" style="height: 440px;padding: 20px 35px;">
						<ul class="tab tab_style02">
							<li onclick="opn_trgtMenu_from_dshbrd('비가동 이력조회');">
								<a href="#tab1-1" style="padding: 10px 0px;">
									<img src="/common/theme/webdek/images/btn_to_right.png" width="15" height="15" />
									<span>비가동 현황(누적)</span>
								</a>
							</li>
<!-- 							<li><a href="#tab1-2"><span>상세</span></a></li> -->
							<li class="btn_zoom_wrap">
								<ul>
									<!-- <li><button class="btn btn_smaller"><span>축소</span></button></li> -->
									<li><button class="btn btn_bigger"><span>확대</span></button></li>
								</ul>
							</li>
						</ul>
						<div class="table_box section" id="tab1-1">
							<div class="table_list01" style="height: 100%;">
								<div class="table_thead tableHeader" style="margin-left: 0px;">
									<table>
										<colgroup>
											<col width="100px" />
											<col width="140px" />
											<col width="130px" />
											<col width="130px" />
											<col width="130px" />
										</colgroup>
										<thead>
											<tr>
												<th CL='STD_PLANT' rowspan="2"></th>
												<th CL='STD_TYPE' rowspan="2"></th>
												<th CL='STD_TIME_MIN' colspan="3"></th>
											</tr>
											<tr>
												<th CL='STD_PRV_MNTH'></th>
												<th CL='STD_THIS_MNTH'></th>
												<th CL='STD_VRY_DAY'></th>
											</tr>
										</thead>
									</table>
								</div>
								<div class="scroll" style="height: calc(100% - 60px)">
									<table class="table_c1">
										<colgroup>
											<col width="100px" />
											<col width="140px" />
											<col width="130px" />
											<col width="130px" />
											<col width="130px" />
										</colgroup>
										<tbody id="gridList6">
											<tr CGRow="true">
												<td GCol="text,PLANT" style="text-align:center;">플랜트</td>
												<td GCol="text,TYPE" style="text-align:left;">유형</td>
												<td GCol="text,PRV_MNTH" style="text-align:right;"  GF="N 13">전월</td>
												<td GCol="text,THIS_MNTH" style="text-align:right;" GF="N 13">당월</td>
												<td GCol="text,VRY_DAY" style="text-align:right;" GF="N 13">당일</td>
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
				<div class="content-vertical-wrap content_right">
					<div class="content_layout tabs content_H_3set" style="height: 440px;padding: 20px 35px;">
						<ul class="tab tab_style02">
							<li onclick="opn_trgtMenu_from_dshbrd('설비별 생산 진행현황');">
								<a href="#tab1-1" style="padding: 10px 0px;">
									<img src="/common/theme/webdek/images/btn_to_right.png" width="15" height="15" />
									<span>비가동 상태(현재)</span>
								</a>
							</li>
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
									<table class="table_c1">
										<tbody id="gridList7">
											<tr CGRow="true">
												<td GH="80" GCol="text,PLANT" style="text-align:center;">플랜트</td>
												<td GH="110" GCol="text,PROCESS" style="text-align:left;">공정</td>
												<td GH="140" GCol="text,MACH_NM" style="text-align:left;">설비명</td>
												<td GH="120" GCol="text,RSN" style="text-align:left;">사유</td>
												<td GH="130" GCol="text,OCCR_TIME" style="text-align:center;">발생시간</td>
												<td GH="120" GCol="text,LAPSE_TM" style="text-align:right;" GF="N 20">경과시간(분)</td>
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
			<div class="content-horizontal-wrap h-wrap-min bottom_layout" style="min-height: 440px;">
				<div class="content-vertical-wrap content_left">	
					<div class="content_layout tabs content_H_3set" style="height: 440px;padding: 20px 35px;">
						<ul class="tab tab_style02">
							<li >
								<a href="#tab1-1" style="padding: 10px 0px;">
									<img src="/common/theme/webdek/images/btn_to_right.png" width="15" height="15" />
									<span>PS 재고현황(단위 : KG)</span>
								</a>
							</li>
<!-- 							<li><a href="#tab1-2"><span>상세</span></a></li> -->
							<li class="btn_zoom_wrap">
								<ul>
									<!-- <li><button class="btn btn_smaller"><span>축소</span></button></li> -->
									<li><button class="btn btn_bigger"><span>확대</span></button></li>
								</ul>
							</li>
						</ul>
						<div class="table_box section" id="tab1-1">
							<div class="table_list01" style="height: 100%;">
								<div class="scroll" style="height: calc(100% - 60px)">
									<table class="table_c1">
										<tbody id="gridList8">
											<tr CGRow="true">
												<td GH="150" GCol="text,LOC_CD" style="text-align:center;">저장위치</td>
												<td GH="150" GCol="text,PCNT" style="text-align:right;">수량</td>
												<td GH="150" GCol="text,WGT" style="text-align:right;"  GF="N 13">중량</td>
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
				<div class="content-vertical-wrap content_right">
				</div>
			</div>
		</div>
	</div>
</div>
<!-- // content -->
<%@ include file="/common/include/webdek/bottom.jsp" %>
</body>
</html>