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
		$("#WERKS").val('P100');
		
		gridList.setGrid({
	    	id : "gridList",
	    	url : "/mes/Quality/QLT12/json/datalist.data",
	    	bigdata : false
	    });
		
		gridList.setGrid({
	    	id : "gridList2",
	    	url : "/mes/Quality/QLT12/json/datalist.data",
	    	bigdata : false,
	    	colHoldType:true,
			colHold:'BIG_CAT_NM,MID_CAT_NM,INSP_ITEM_CD,INSP_ITEM_NM',
			colGroupCols : "BIG_CAT_NM,MID_CAT_NM"
	    });
		
	});

	function searchList(){
		if(validate.check("searchArea")){
			/* var range = inputList.setRangeParam("searchArea");
			var range_data_param = range.get("RANGE_DATA_PARAM");
			var msrm_date = range_data_param.get("MSRM_DATE_Range");
			var date = msrm_date.split('↓');
			var SDate = parse(date[1]);
			var EDate = parse(date[2]);
			
			var matnr = range_data_param.get("MATNR_Single");
			var matnr_str = matnr == undefined ? '' : matnr.split('↓');
			var Matnr = "";
			
			for(var i = 0; i < matnr_str.length; i++){
				if(matnr_str[i].indexOf('E') == 0 || matnr_str[i].indexOf('OR') == 0){
					continue;
				}
				if(matnr_str[i].includes('%')){
					Matnr = Matnr + '^' + matnr_str[i].slice(0,-1) + '|';
				}else{
					Matnr = Matnr + '^' + matnr_str[i] + '|';	
				}
			} */
			
			var param = inputList.setRangeParam("searchArea");
			
			param.put("P_TYPE", "LIST");
			//param.put("WERKS", $("#WERKS").val().toUpperCase());
			/* param.put("SDATE", SDate);
			param.put("EDATE", EDate);
			param.put("MATNR", Matnr.slice(0, -1)); */
			
			gridList.gridList({
		    	id : "gridList",
		    	param : param
		    });
			
			gridList.resetGrid("gridList2");
		}
	}
	
	/* function parse(str){
		var y = str.substr(0, 4);
		var m = str.substr(4, 2);
		var d = str.substr(6, 2);
		var h = "00";
		var mm = "00";
		var s = "00";
		
		return y + '-' + m + '-' + d + ' ' + h + ':' + mm + ':' + s;
	} */
	
	function searchSubList(headRowNum){
		var MATNR = gridList.getColData("gridList", headRowNum, "MATNR");
		var WERKS = gridList.getColData("gridList", headRowNum, "WERKS");
		var MSRM_DATE = gridList.getColData("gridList", headRowNum, "MSRM_DATE");
		var PRC_SEQNO = gridList.getColData("gridList", headRowNum, "PRC_SEQNO");
		var PRDC_DT = gridList.getColData("gridList", headRowNum, "PRDC_DT");
		var SUPY_CD = gridList.getColData("gridList", headRowNum, "SUPY_CD");
		var param = new DataMap();
		
		param.put("P_TYPE", "SUB_LIST");
		param.put("MATNR", MATNR);
		param.put("WERKS", WERKS);
		param.put("MSRM_DATE", MSRM_DATE);
		param.put("PRC_SEQNO", PRC_SEQNO);
		
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
							<input type="text" class="input" id="WERKS" name="WERKS"  UIFormat="U" readonly="readonly"/>
						</dd>
					</dl>
					<dl>
						<dt>검사일자</dt>
						<dd><input type="text" name="MSRM_DATE" UIInput="B" UIFORMAT="C M1"/></dd>
					</dl>
					<dl>
                        <dt CL="STD_MATNR">자재코드</dt>
                        <dd><input type="text" name="MATNR" UIInput="SR,MATKY" UIFormat="U"/></dd>
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
					<li><a href="#tab1-1"><span CL="STD_GRD_QLT12_1">검사이력</span></a></li>
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
										<td GH="100" GCol="text,WERKS" style="text-align:center;">플랜트</td>
										<td GH="140" GCol="text,MSRM_DATE" style="test-align:center;">측정일시</td>
										<td GH="140" GCol="text,MATNR" style="text-align:center;">자재코드</td>
										<td GH="320" GCol="text,MATNR_NM">자재명</td>
										<td GH="0" GCol="text,PRC_SEQNO">처리순번</td>
										<td GH="0" GCol="text,MSRM_NM">측정자</td>
										<td GH="0" GCol="text,SMPL_AMT">시료량</td>
										<td GH="100" GCol="text,LOT_NO" style="text-align:center;">LOT번호</td>
										<td GH="120" GCol="text,IND_BCD" style="text-align:center;">개별바코드</td>
										<td GH="0" GCol="text,WRK_ORDR_NO">작업지시번호</td>
										<td GH="0" GCol="text,WRK_ORDR_SEQNO">작업지시번호순번</td>
										<td GH="0" GCol="text,MACH_CD">설비코드</td>
										<td GH="0" GCol="text,MACH_NM">설비명</td>
										<td GH="100" GCol="text,PRFM_QTY" GF="N 13">실적수량</td>
										<td GH="100" GCol="text,UCFMTY_AMT" GF="N 10">부적합량</td>
										<td GH='100' Gcol='text,UNIT' style='text-align:center;'>단위</td>
										<td GH="100" GCol="text,FNL_JDGM_NM">최종판정</td>
										<td GH="0" GCol="text,INSP_ITEM_GRP_CD" style="text-align:center;">검사항목그룹코드</td>
										<td GH="140" GCol="text,REGDATE" style="text-align:center;">등록일시</td>
										<td GH="100" GCol="text,REGNM">등록자</td>
										<td GH="140" GCol="text,UPDDATE" style="text-align:center;">수정일시</td>
										<td GH="100" GCol="text,UPDNM">수정자</td>
									</tr>
								</tbody>
							</table>
						</div>
					</div>
					<jsp:include page="/WEB-INF/jsp/common/commonBtnAuth.jsp">
						<jsp:param name="authCd" value="1"/>
						<jsp:param name="showAuthCd" value="1,2,3,7,9,10"/>
					</jsp:include>				
				</div>
			</div>
			<div class="content_layout tabs bottom_layout">
				<ul class="tab tab_style02">
					<li><a href="#tab2-1"><span CL="STD_GRD_QLT12_2">검사항목</span></a></li>
					<li class="btn_zoom_wrap">
						<ul>
							<li><button class="btn btn_bigger"><span>확대</span></button></li>
						</ul>
					</li>
				</ul>
				<div class="table_box section" id="tab2-1" >
					<div class="table_list01">
						<div class="scroll">
							<table class="table_b">
								<tbody id="gridList2">
									<tr CGRow="true">
										<td GH="40" GCol="rownum">1</td>
										<td GH="100" GCol="text,BIG_CAT_NM">대분류</td>
										<td GH="100" GCol="text,MID_CAT_NM">중분류</td>
										<td GH="100" GCol="text,INSP_ITEM_CD" style="text-align:center;">검사항목코드</td>
										<td GH="100" GCol="text,INSP_ITEM_NM">검사항목명</td>
										<td GH="100" GCol="text,MSRM_CYC">측정주기</td>
										<td GH="100" GCol="text,MSRM_MTD">측정방법</td>
										<td GH="100" GCol="text,MSRM_ACC" style="text-align:center;">측정차수</td>
										<td GH="100" GCol="text,MSRM_UNIT">측정단위</td>
										<td GH="100" GCol="text,INSP_SPEC">시험규격</td>
										<td GH="100" GCol="text,STD_VAL" GF="N 9,2">기준값</td>
										<td GH="100" GCol="text,UPP_VAL" GF="N 9,2">상한치</td>
										<td GH="100" GCol="text,LOW_VAL" GF="N 9,2">하한치</td>
										<td GH="100" GCol="text,STD_SEL" style="text-align:center;">기준선택값</td>
										<td GH="100" GCol="text,INSP_STD_1">기준선택값(1)</td>
										<td GH="100" GCol="text,INSP_STD_2">기준선택값(2)</td>
										<td GH="100" GCol="text,RST_VAL" GF="N 9,2">측정값</td>
										<td GH="100" GCol="text,RST_TXT">결과값(문자열)</td>
										<td GH="100" GCol="text,RST_SEL" style="text-align:center;">판정</td>
										<td GH="140" GCol="text,RMK">특이사항</td>
										<td GH="200" GCol="fileDownload,UUID">첨부파일</td>
										<td GH="0" GCol="fileDownload,UUID_FILEVIEW"></td>
										<td GH="100" GCol="text,FIT_YN">적합여부</td>
										<td GH="120" GCol="text,INSP_REP_YN">성적서 항목여부(Y/N)</td>
										<td GH="140" GCol="text,REGDATE" style="text-align:center;">등록일시</td>
										<td GH="100" GCol="text,REGNM">등록자</td>
										<td GH="140" GCol="text,UPDDATE" style="text-align:center;">수정일시</td>
										<td GH="100" GCol="text,UPDNM">수정자</td>	
									</tr>
								</tbody>
							</table>
						</div>
					</div>
					<jsp:include page="/WEB-INF/jsp/common/commonBtnAuth.jsp">
						<jsp:param name="authCd" value="1"/>
						<jsp:param name="showAuthCd" value="1,2,3,9,10"/>
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