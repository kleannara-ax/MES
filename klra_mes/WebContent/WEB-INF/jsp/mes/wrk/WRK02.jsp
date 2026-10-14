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
			url : "/mes/Work/WRK02/json/datalist.data",
			bigdata : false
	    });
		
		gridList.setGrid({
	    	id : "gridList2",
	    	url : "/mes/Work/WRK02/json/datalist.data",
			bigdata : false,
			colHoldType : true,
			colHold : "MID_CAT_NM, BIG_CAT_NM, CHK_ITEM_NM"
	    });
	});
	
	function searchList(){
		if(validate.check("searchArea")){
			// 2023-03-13(월요일) 안상현, RANGE 검색 추가
			const range = inputList.setRangeParam("searchArea")
			const range_data_param = range.get("RANGE_DATA_PARAM")
			const chk_dt = range_data_param.get("W014.CHK_DT_Range")
			const date = chk_dt.split("↓")
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
		
		gridList.resetGrid("gridList2");
	}
	
	function searchSubList(headRowNum){
		var head = gridList.getRowData("gridList", headRowNum);
		
		var param = new DataMap();
		
		param.put("P_TYPE", "SUB_LIST");
		param.put("head", head);
		
		gridList.gridList({
			id : "gridList2",
			param : param
		});
	}
	
	function gridListEventRowDblclick(gridId, rowNum){
		if(gridId = "gridList"){
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
							<input type="text" class="input" id="WERKS" name="WERKS" validate="required" UIInput="S,PLANT" UIFormat="U"/>
						</dd>
					</dl>
					<dl>
						<dt>검사일자</dt>
						<dd>
							<input type="text" class="input" name="W014.CHK_DT" UIInput="B" UIFormat="C M1"/>
						</dd>
					</dl>
					<dl>
						<dt CL="STD_MACH_CD">설비코드</dt>
						<dd>
							<!-- 2023-03-13(월요일) 안상현, 설비코드 RANGE 검색 추가 -->
							<input type="text" class="input" name="W014.MACH_CD" UIInput="SR,MACH" UIFormat="U"/>
						</dd>
					</dl>
				</div>
				<div class="btn_tab">
					<input type="button" class="btn_more" value="more" onclick="searchMore()"/>
				</div>
			</div>
		</div>
        <div class="search_next_wrap">
			<div class="content-horizontal-wrap h-wrap-min">
				<div class="content_layout tabs content_left" style="width:44%;">
					<ul class="tab tab_style02">
						<li><a href="#tab1-1"><span CL="STD_GENERAL"></span></a></li>
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
											<td GH="100" GCol="text,CHK_DT" GF="D" style="text-align:center;">측정일자</td>
											<td GH="100" GCol="text,CHK_SEQNO" style="text-align:right;">차수</td>
											<td GH="100" GCol="text,MACH_CD" style="text-align:center;">설비코드</td>
											<td GH="140" GCol="text,MACH_NM">설비명</td>
											<td GH="100" GCol="text,REGNM">생성자명</td>
										</tr>
									</tbody>
								</table>
							</div>
						</div>
						<jsp:include page="/WEB-INF/jsp/common/commonBtnAuth.jsp">
							<jsp:param value="1" name="authCd"/>
							<jsp:param value="1,2,3,9,10" name="showAuthCd"/>
						</jsp:include>
					</div>
				</div>
				<div class="content_layout tabs content_right" style="width:calc(55% - 5px);">
					<ul class="tab tab_style02">
						<li><a href="#tab2-1"><span>공청제크 현황</span></a></li>
						<li class="btn_zoom_wrap">
	                        <ul>
	                            <li><button class="btn btn_bigger"><span>확대</span></button></li>
	                        </ul>
                    	</li>
					</ul>
					<div class="table_box section" id="tab2-1">
						<div class="table_list01">
							<div class="scroll">
								<table class="table_b">
									<tbody id="gridList2">
										<tr CGRow="true">
											<td GH="40" GCol="rownum">1</td>
											<td GH="0" GCol="text,CHK_ITEM_CD" style="text-align:center;">체크항목코드</td>
											<td GH="100" GCol="text,MID_CAT_NM">중분류명</td>
											<td GH="100" GCol="text,BIG_CAT_NM">중분류명</td>
											<td GH="100" GCol="text,CHK_ITEM_NM">검사항목명</td>
											<td GH="0" GCol="text,MATNR" style="text-align:center;">자재코드</td>
											<td GH="0" GCol="text,WRK_ORDR_NO">작업지시번호</td>
											<td GH="0" GCol="text,WRK_ORDR_SEQNO">작업지시번호 순번</td>
											<td GH="0" GCol="text,INPT_TYP_NM">입력타입(명)</td>
											<td GH="0" GCol="text,INPT_MTD_NM">입력방법(명)</td>
											<td GH="100" GCol="text,STD_VAL1" GF="N 13,1">기준값(숫자)</td>
											<td GH="100" GCol="text,STD_VAL2">기준값(문자)</td>
											<td GH="100" GCol="text,UPP_VAL" GF="N 13,1">상한치</td>
											<td GH="100" GCol="text,LOW_VAL" GF="N 13,1">하한치</td>
											<td GH="100" GCol="text,RST_VAL" GF="N 9,1">측정값</td>
											<td GH="100" GCol="text,RST_SEL">판정</td>
											<td GH="100" GCol="text,RST_TXT">결과값(문자열)</td>
											<td GH="0" GCol="text,CPK_YN">CPK 여부</td>
											<td GH="0" GCol="text,RMK">비고</td>
											<td GH="0" GCol="text,REGDATE"></td>
											<td GH="0" GCol="text,REGNM"></td>
											<td GH="0" GCol="text,UPDDATE"></td>
											<td GH="0" GCol="text,UPDNM"></td>
										</tr>
									</tbody>
								</table>
							</div>
						</div>
						<jsp:include page="/WEB-INF/jsp/common/commonBtnAuth.jsp">
							<jsp:param value="2" name="authCd"/>
							<jsp:param value="1,2,3,9,10" name="showAuthCd"/>
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