<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Grid default</title>
<%@ include file="/common/include/webdek/head.jsp" %>
<script type="text/javascript" src="/common/js/ezgencontrol.js"></script>
<link rel="stylesheet" type="text/css" href="/common/theme/webdek/css/demo_layout.css">
<script type="text/javascript">
	$(document).ready(function(){
		gridList.setGrid({
	    	id : "gridList",
			url : "/mes/Quality/QLT02/json/datalist.data",
			bigdata : false,
			colHoldType : true,
			colHold : "INSP_ITEM_GRP_CD, WERKS, MATNR, MATNR_NM"
	    });
		/* 
		gridList.setGrid({
	    	id : "gridList2",
			url : "/mes/Quality/QLT02/json/datalist.data",
			bigdata : false,
			colHoldType : true,
			colHold : "INSP_ITEM_CD, INSP_ITEM_NM, BIG_CAT_NM, MID_CAT_NM"
	    });
		*/
		//searchList();
	});

	function searchList(){
		if(validate.check("searchArea")){
			var werks = $("#WERKS").val().toUpperCase();
			if(werks != '' && werks != "P100" && werks != "P200" && werks != "P300" && werks != "P400" && werks != "P500"){
				alert("플랜트 정보가 없습니다.");
				return;
			}
			
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
			}
			
			var supycd = range_data_param.get("SUPY_CD_Single");
			var supycd_str = supycd == undefined ? '' : supycd.split('↓');
			var Supycd = "";
			
			for(var i = 0; i < supycd_str.length; i++){
				if(supycd_str[i].indexOf('E') == 0 || supycd_str[i].indexOf('OR') == 0){
					continue;
				}
				if(supycd_str[i].includes('%')){
					Supycd = Supycd + '^' + supycd_str[i].slice(0,-1) + '|';
				}else{
					Supycd = Supycd + '^' + supycd_str[i] + '|';
				}
			} */	
				
			var param = inputList.setRangeParam("searchArea");
			
			param.put("P_TYPE", "LIST");
			/* param.put("WERKS", werks);
			param.put("SDATE", SDate);
			param.put("EDATE", EDate);
			param.put("MATNR", Matnr.slice(0, -1));
			param.put("SUPY_CD", Supycd.slice(0, -1)); */
			
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

	// 버튼 클릭(조회, 출력)
	function commonBtnClick(btnName){
		//commonUtil.debugMsg("commonBtnClick : ", arguments);
		if(btnName == "Search"){
			var param = new DataMap();
	        param.put("PROGID", "<%= menuId%>");
	        param.put("LGTYPE", "SEARCH");
	        var json = netUtil.sendData({
	            url: "/mes/system/json/saveLog.data",
	            param : param
	        });
			
			searchList();
		}else{
			reportPrint()
		}
	}
	
	// 입고 승인서 출력
	const reportPrint = () => {
		const list = gridList.getSelectData("gridList")
		
		if(list.length !== 1){
			alert("출력 개수는 1개입니다.")
			return
		}
		
		let param = new DataMap()
		param.put("list", list)
		param.put("PRTTYP","MES")
		param.put("LANGKY", "KR")
		param.put("PROGID" , configData.MENU_ID)
		param.put("WAREKY", "<%=wareky%>")
		
		// 이지젠 파일명
		let fileName = "KLRA_QLT02_INCOM_LABEL.ezg";
		
		// 라벨
		param.put("LABEL01" , "입고 승인서")
		param.put("LABEL02" , "제품표준서 번호")
		param.put("LABEL03" , "제품명")
		param.put("LABEL04" , "제조번호")
		param.put("LABEL05" , "제조년월")
		param.put("LABEL06" , "시험번호")
		param.put("LABEL07" , "입고수량")
		param.put("LABEL08" , "위의 제품은 HL품질관리팀 소정의 시험과")
		param.put("LABEL09" , "자체 품질관리 기준에 적합되었으므로")
		param.put("LABEL10" , "입고를 승인합니다.")
		param.put("LABEL11" , "구 분")
		param.put("LABEL12" , "패드생산팀")
		param.put("LABEL13" , "HL품질팀")
		param.put("LABEL14" , "최종 승인")
		param.put("LABEL15" , "서 명")
		param.put("LABEL16" , "일 자")
		
		// 데이터
		// 검사항목그룹코드
		param.put("VALUE02", list[0].get("INSP_ITEM_GRP_CD"))	
		// 품목코드
		param.put("VALUE03", list[0].get("MATNR"))
		// 플랜트코드
		param.put("VALUE04", list[0].get("WERKS"))
		// 처리순번
		param.put("VALUE05", list[0].get("PRC_SEQNO"))
		
		// 이력 테이블 INSERT
		const json = netUtil.sendData({
			url : "/mes/report/json/savePrtseq_LocBcd.data",
			param : param
		});
		
		param = new DataMap();
		const i_where = "AND PRT.PRTSEQ = '" + json.data + "'";
		
		WriteEZgenElement(fileName, i_where, "", '<%= langky%>', param, 1000, 1000)
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
					<input type="button" id="button-0-3" CB="Label PRINT_OUT BTN_LABEL" />
				</div>
			</div>
			<div class="search_inner">
				<div class="search_wrap ">
				
				  	<dl>
						<dt CL="STD_PLANT">플랜트</dt>
						<dd>
							<input type="text" id="WERKS" name="WERKS" UIInput="S,PLANT" UIFormat="U" validate="required"/>
						</dd>
					</dl>
					<dl>
						<dt>검사일자</dt>
						<dd><input type="text" id="MSRM_DATE" name="MSRM_DATE" UIInput="B" UIFORMAT="C M1"/></dd>
					</dl>
					<dl>
						<dt CL="STD_MATNR">자재코드</dt>
						<dd><input type="text" id="MATNR" name="MATNR" UIInput="SR,MATKY" UIFormat="U"/></dd>
					</dl>
					<dl>
						<dt CL="STD_SUPY_CD">공급업체</dt>
						<dd><input type="text" id="SUPY_CD" name="SUPY_CD" UIInput="SR,CUST" UIFormat="U"/></dd>
					</dl>
				</div>
				<div class="btn_tab">
					<input type="button" class="btn_more" value="more" onclick="searchMore()"/>
				</div>
			</div>
		</div>
        <div class="search_next_wrap">
			<!-- <div class="content_layout tabs top_layout"> -->
			<div class="content_layout tabs">
				<ul class="tab tab_style02">
					<li><a href="#tab1-1"><span CL="STD_GRD_QLT02">일반</span></a></li>
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
										<td GH="0" GCol="text,INSP_ITEM_GRP_CD" style="text-align:center;">검사항목그룹코드</td>
										<td GH="100" GCol="text,WERKS" style="text-align:center;">플랜트</td>
										<td GH="140" GCol="text,MATNR" style="text-align:center;">자재코드</td>
										<td GH="320" GCol="text,MATNR_NM">자재명</td>
										<td GH="100" GCol="text,RCVGDS_DT" style="text-align:center;">입고일자</td>
										<td GH="100" GCol="text,MSRM_NM">측정자</td>
										<td GH="140" GCol="text,MSRM_DATE" style="text-align:center;">측정일시</td>
										<td GH="0" GCol="text,PRC_SEQNO">처리순번</td>
										<td GH="100" GCol="text,VND_LOT_NO">업체로트번호</td>
										<td GH="120" GCol="text,SUPY_VND_BCD">공급업체바코드</td>
										<td GH="100" GCol="text,RCVGDS_QTY" GF="N 5,3">입고수량</td>
										<td GH="100" GCol="text,SMPL_AMT" GF="N 13,3">시료량</td>
										<td GH="100" GCol="text,UCFMTY_AMT" GF="N 13,3">부적합량</td>
										<td GH="100" GCol="text,UNIT" style="text-align:center;">단위</td>
										<td GH="100" GCol="text,UNIT_NM">단위(명)</td>
										<td GH="100" GCol="text,FNL_JDGM_NM">최종판정(명)</td>
										<td GH="100" GCol="text,PRDC_DT" style="text-align:center;">제조일자</td>
										<td GH="100" GCol="text,STOR_LOC_NM">저장위치(명)</td>
										<td GH="100" GCol="text,SUPY_CD">공급업체</td>
										<td GH="120" GCol="text,SUPY_NM">공급업체명</td>
										<td GH="0" GCol="text,STCK_STA_NM">재고상태(명)</td>
										<td GH="0" GCol="text,NTN_NM">국가 명</td>
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
						<jsp:param name="authCd" value="1" />
						<jsp:param name="showAuthCd" value="1,2,3,7,9,10" />
					</jsp:include>
				</div>
			</div>
			<%-- 
			<div class="content_layout tabs bottom_layout">
				<ul class="tab tab_style02">
					<li><a href="#tab1-1"><span>검사이력</span></a></li>
					<li class="btn_zoom_wrap">
						<ul>
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
										<td GH="40" GCol="rownum">1</td>
										<td GH="100" GCol="text,INSP_ITEM_CD" style="text-align:center;">검사항목코드</td>
										<td GH="100" GCol="text,INSP_ITEM_NM">검사항목명</td>
										<td GH="100" GCol="text,BIG_CAT_NM">대분류</td>
										<td GH="100" GCol="text,MID_CAT_NM">중분류</td>
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
										<td GH="120" GCol="text,INSP_REP_YN" style="text-align:center;">성적서 항목여부(Y/N)</td>
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
						<jsp:param name="authCd" value="2" />
						<jsp:param name="showAuthCd" value="1,2,3,9,10" />
					</jsp:include>
				</div>
			</div>
			--%>
		</div>
	</div>
</div>
<!-- // content -->
<%@ include file="/common/include/webdek/bottom.jsp" %>
</body>
</html>