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
<%@ include file="/WEB-INF/jsp/common/commonApprvForm.jsp" %>
<script type="text/javascript">
	$(document).ready(function(){
		gridList.setGrid({
	    	id : "gridList",
	    	url : "/mes/Quality/QLT07/json/datalist.data",
			bigdata : false
	    });
		
		gridList.setGrid({
	    	id : "gridList2",
	    	url : "/mes/Quality/QLT07/json/datalist.data",
			bigdata : false,
			colHoldType : true,
			colHold : "BIG_CAT_NM, MID_CAT_NM, INSP_ITEM_CD, INSP_ITEM_NM",
			colGroupCols : "BIG_CAT_NM,MID_CAT_NM"
	    });
	});

	function searchList(){
		if(validate.check("searchArea")){
			var werks = $("#WERKS").val().toUpperCase();
			if(werks != '' && werks != "P200" && werks != "P300" && werks != "P400" && werks != "P500"){
				alert("플랜트 정보가 없습니다.");
				return;
			}
			
			var range = inputList.setRangeParam("searchArea");
			var range_data_param = range.get("RANGE_DATA_PARAM");
			var msrm_date = range_data_param.get("MSRM_DATE_Range");
			var date = msrm_date == undefined ? '' : msrm_date.split('↓');
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
			
			var param = new DataMap();
			
			param.put("P_TYPE", "LIST");
			param.put("WERKS", werks);
			param.put("SDATE", SDate);
			param.put("EDATE", EDate);
			param.put("MATNR", Matnr.slice(0, -1));
			
			gridList.gridList({
		    	id : "gridList",
		    	param : param
		    });
			
			gridList.resetGrid("gridList2");
		}
	}
	
	function parse(str){
		if(str == undefined){
			return;
		}
		
		var y = str.substr(0, 4);
		var m = str.substr(4, 2);
		var d = str.substr(6, 2);
		var h = "00";
		var mm = "00";
		var s = "00";
		
		return y + '-' + m + '-' + d + ' ' + h + ':' + mm + ':' + s;
	}

	// 결제 띄우기
	function dataApprv() {
		var list = gridList.getSelectData("gridList");
		if(list.length == 0) {
			alert('결재할 데이터를 선택해 주세요.')
			return
		}else if(list.length > 1){
			alert('하나의 항목만 결제 가능합니다.');
			return;
		}
		var focusNum = gridList.getFocusRowNum("gridList");
		console.log(focusNum)
		var row = gridList.getRowData("gridList", focusNum);
		console.log(row);
		var apvr_sta = row.get("APVR_STA");

		/*
		if(apvr_sta == "1" || apvr_sta == "2"){
			alert("결재를 진행할 수 없습니다.");
			return;
		}
		 */
		
		var DOC_ID= row.get('DOC_ID')==undefined?'':row.get("DOC_ID");
		console.log('DOC_ID===',DOC_ID);
		var HTML = "";
		if(!DOC_ID){
			var param = new DataMap();
			param.put("INSP_ITEM_GRP_CD",row.get("INSP_ITEM_GRP_CD"))
			param.put("MATNR",row.get("MATNR"))
			param.put("WERKS",row.get("WERKS"))
			param.put("MSRM_DATE",row.get("MSRM_DATE"))
			param.put("PRC_SEQNO",row.get("PRC_SEQNO"))
			param.put("TYPE", "MES001");
			var json = netUtil.sendData({
				url : "/mes/gw/doc/json/data.data",
				param : param
			});
			if(json){
				if(json.data){
					DOC_ID = json.data.DOC_ID
					HTML = json.data.HTML;
				}
			}
		}
		if(!DOC_ID || !HTML) {
			alert('양식에 넣을 데이터가 없습니다.')
			return;
		}

		openApprvPop('MES001',DOC_ID,HTML)
	}

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
		}else if(btnName == "Save"){
			saveData();
		}else if(btnName == "Aprrove") {
			dataApprv()
		}else{
			// 2022-06-27 안상현, 검사성적서 출력
			reportPrint()
		}
	}
	
	// 검사성적서 출력
	const reportPrint = () => {
		const list = gridList.getSelectData("gridList")
		
		if(list.length !== 1){
			alert("출력 개수는 1개입니다.")
			return
		}else{
			if(list[0].get("IND_BCD") === " "){
				alert("개별바코드가 존재하지 않습니다.")
				return
			 	
			} else if(list[0].get("APVR_STA") !== "2"){
				alert("결재완료된 검사만 출력 가능합니다.")
				return
			}
		}
		
		// 공장지 정보 PK
		const WAREKY = "<%=wareky%>"
		
		let param = new DataMap()
		param.put("list", list)
		param.put("PRTTYP","MES")
		param.put("LANGKY", "KR")
		param.put("PROGID" , configData.MENU_ID)
		param.put("WAREKY", WAREKY)
		
		// 이지젠 파일명
		let fileName = "KLRA_QLT07_REPORT_LABEL.ezg";
		
		// 라벨
		param.put("LABEL01", "검 사 성 적 서")
		param.put("LABEL02", "귀중")
		param.put("LABEL03", WAREKY == "CP" ? "깨끗한나라(주) 청주공장" : "깨끗한나라(주) 음성공장")
		param.put("LABEL04", "1.품목 :")
		param.put("LABEL05", "2.규격 :")
		param.put("LABEL06", "3.Lot No :")
		param.put("LABEL07", "공장:")
		param.put("LABEL08", "TEL:")
		param.put("LABEL09", "FAX:")
		param.put("LABEL10", "본사:서울특별시 용산구 한남대로 98, 일신빌딩 4층")
		param.put("LABEL11", "TEL:02-2270-9200")
		param.put("LABEL12", "항목")
		param.put("LABEL13", "단위")
		param.put("LABEL14", "관리기준")
		param.put("LABEL15", "검사결과")
		param.put("LABEL16", "비고")
		param.put("LABEL17", "평량")
		param.put("LABEL18", "두께")
		param.put("LABEL19", "인장강도/MD")
		param.put("LABEL20", "종합결과")
		param.put("LABEL21", "상기와 같이 검사를 통보합니다.")
		
		let today = new Date()
		
		param.put("LABEL22", "")
		param.put("LABEL23", "")
		param.put("LABEL24", today.getFullYear()+"년"+"   "+(today.getMonth() + 1)+"월"+"   "+today.getDate()+"일")
		
		param.put("LABEL25", "품질관리팀(인)")
		param.put("LABEL26", "양식 D 204 - 02 - 01")
		param.put("LABEL27", "깨끗한나라(주)")
		param.put("LABEL28", "A4(297 x 210)")
		
		// 데이터
		// HEAD 정보 개별바코드
		param.put("VALUE01", list[0].get("IND_BCD"))	
		
		// HEAD 정보 공장지 정보 PK
		param.put("VALUE02", WAREKY)
		
		// HEAD 정보 검사일시
		param.put("VALUE03", list[0].get("MSRM_DATE"))
		
		// ITEM 정보 플랜트 코드
		param.put("VALUE04", list[0].get("WERKS"))
		
		// ITEM 정보 자재 코드
		param.put("VALUE05", list[0].get("MATNR"))
		
		// ITEM 정보 검사항목그룹코드
		param.put("VALUE06", list[0].get("INSP_ITEM_GRP_CD"))
		
		// ITEM 정보 처리순번
		param.put("VALUE07", list[0].get("PRC_SEQNO"))
		
		// ITEM 정보 검사일시
		param.put("VALUE08", list[0].get("MSRM_DATE"))
		
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
					<input type="button" id="button-0-3" CB="CHKLABEL PRINT_OUT BTN_CHKLABEL" />
					<input type="button" id="button-0-3" CB="Aprrove APPLY BTN_APPROVE" />
				</div>
			</div>
			<div class="search_inner">
				<div class="search_wrap ">
				
				  <dl>
						<dt CL="STD_PLANT">플랜트</dt>
						<dd>
							<input type="text" class="input" id="WERKS" name="WERKS" validate="required" UIInput="S,PLANT" UIFormat="U"/>
						</dd>
					</dl>
					<dl>
                        <dt>검사일자</dt>
                        <dd><input type="text" name="MSRM_DATE" UIInput="B" UIFORMAT="C M1" validate="required"/></dd>
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
					<li><a href="#tab1-1"><span>검사이력</span></a></li>
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
										<td GH="140" GCol="text,MSRM_DATE" style="text-align:center;">측정일시</td>
                                    	<td GH="0" GCol="text,PRC_SEQNO">처리순번</td>
                                    	<td GH="0" GCol="text,MSRM_NM">측정자</td>
                                    	<td GH="100" GCol="text,SMPL_AMT" GF="N 3">시료량</td>
                                    	<td GH="0" GCol="text,FNL_JDGM_NM">최종판정(명)</td>
										<td GH="100" GCol="text,LOT_NO">LOT번호</td>
										<td GH="110" GCol="text,IND_BCD">개별바코드</td>
										<td GH="0" GCol="text,VND_LOT_NO">업체로트번호</td>
										<td GH="0" GCol="text,SUPY_VND_BCD">공급업체바코드</td>
										<!-- 2022-08-29(월요일) 안상현, 부적합량 제거 -->
										<!-- <td GH="100" GCol="text,UCFMTY_AMT" GF="N 5">부적합량</td> -->
										<td GH="0" GCol="text,WRK_ORDR_NO">작업지시번호</td>
                                    	<td GH="0" GCol="text,WRK_ORDR_SEQNO">지시순번</td>
                                    	<td GH="0" GCol="text,MACH_CD" style="text-align:center;">설비</td>
                                    	<td GH="0" GCol="text,MACH_NM">설비(명)</td>
                                    	<td GH="100" GCol="text,PRFM_QTY" GF="N 13,0">실적수량</td>
                                    	<!-- 2022-06-27(월요일) 안상현, 조회버튼 옆의 출력 버튼으로 수정
											<td GH="100" GCol="btn,INSP_REP_PRN" GB="Prn PRN BTN_PRN">성적서 출력버튼</td>
										 -->
										<td GH="0" GCol="text,DRFT_ID">기안자</td>
										<td GH="0" GCol="text,DRFT_DATE">기안일시</td>
										<td GH="0" GCol="text,APVR_STA">결재상태</td>
										<td GH="130" GCol="text,APVR_STA_NM">결재상태(명)</td>
										<td GH="100" GCol="text,CFRM_NM">승인자</td>
										<td GH="100" GCol="text,CFRM_DATE" style="text-align:center;">승인일시</td>
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
						<jsp:param name="showAuthCd" value="1,2,3,7,9,10" />
					</jsp:include>				
				</div>
			</div>
			
			
			<div class="content_layout tabs bottom_layout">
				<ul class="tab tab_style02">
					<li><a href="#tab1-1"><span>검사결과</span></a></li>
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
										<td GH="100" GCol="text,BIG_CAT_NM">대분류</td>
										<td GH="100" GCol="text,MID_CAT_NM">중분류</td>
										<td GH="100" GCol="text,INSP_ITEM_CD" style="text-align:center;">검사항목코드</td>
										<td GH="100" GCol="text,INSP_ITEM_NM">검사항목명</td>
										<td GH="100" GCol="text,MSRM_CYC">측정주기</td>
										<td GH="100" GCol="text,MSRM_MTD">측정방법</td>
										<td GH="100" GCol="text,MSRM_ACC" GF="N 5">측정차수</td>
										<td GH="100" GCol="text,MSRM_UNIT">측정단위</td>
										<td GH="100" GCol="text,INSP_SPEC">시험규격</td>
										<td GH="100" GCol="text,STD_VAL" GF="N 9,2">기준값</td>
										<td GH="100" GCol="text,UPP_VAL" GF="N 9,2">상한치</td>
										<td GH="100" GCol="text,LOW_VAL" GF="N 9,2">하한치</td>
										<td GH="100" GCol="text,STD_SEL">기준선택값</td>
										<td GH="100" GCol="text,INSP_STD_1">기준선택값(1)</td>
										<td GH="100" GCol="text,INSP_STD_2">기준선택값(2)</td>
										<td GH="100" GCol="text,RST_VAL" GF="N 9,2">측정값</td>
										<td GH="100" GCol="text,RST_TXT">결과값(문자열)</td>
										<td GH="100" GCol="text,RST_SEL">판정</td>
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
						<jsp:param name="authCd" value="2" />
						<jsp:param name="showAuthCd" value="1,2,3,9,10" />
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