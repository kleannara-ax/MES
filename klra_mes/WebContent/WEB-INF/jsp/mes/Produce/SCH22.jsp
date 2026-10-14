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
	    	url : "/mes/Produce/SCH22/json/datalist.data",
	    	bigdata : false,
	    	pkcol :"WERKS",
	    	colHoldType : true,
	    	colHold : "PRD_REQ_DT,WRK_ORDR_NO,WRK_ORDR_SEQNO,MATNR,MATNR_NM",
	    	colorType : true
	    });
	});

	// 조회
	function searchList(){
		// VALIDATION
		if($("#WERKS").val().toUpperCase() === "P100"){
			alert("PS 예외 생산 정보는 예외생산 오더 조회(PS)에서 확인가능합니다.")
			$("#WERKS").focus()
			return
		}
		
		if(validate.check("searchArea")){
			var param = inputList.setRangeParam("searchArea");
	
			param.put("P_TYPE","LIST");
			
			gridList.gridList({
				id : "gridList",
				param : param
			});
		}
	}
	
	// 버튼(조회, 저장 등) 클릭
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
	
	// 2022-10-18(일요일) 안상현, 오더 삭제여부가 "오더 삭제"인 경우 오렌지로 라인 표시
 	function gridListRowColorChange(gridId, rowNum, rowData){
		if(gridId === "gridList" && rowData.get("USE_STATE") === "N"){
			return configData.GRID_COLOR_BG_ORANGE_CLASS;
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
							<input type="text" class="input" id="WERKS" name="WERKS"  UIInput="S,PLANT" UIFormat="U" validate="required" />
						</dd>
					</dl>
					<dl>
						<dt CL="STD_MATNR">자재코드</dt>
						<dd>
							<input type="text" id="MATNR" name="MATNR" UIInput="SR,MATKY" UIFormat="U"/>
						</dd>
					</dl>
					<dl>
						<dt CL="STD_PRD_REQ_DT">생성요청일자</dt>
                        <dd>
                        	<input type="text" name="PRD_REQ_DT" UIInput="B" UIFORMAT="C M1"/>
                        </dd>
					</dl>
					<dl>
						<dt>지시생성일자</dt>
                        <dd>
                        	<input type="text" name="ORDR_GEN_DT" UIInput="B" UIFORMAT="C"/>
                        </dd>
					</dl>
					<dl>
						<dt CL="STD_USE_FLAG">오더 삭제여부</dt>
						<dd>
							<select class="input" name="USE_FLAG" CommonCombo="USEFLAG">
								<option value="">All</option>
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
										<td GH="100" GCol="text,PRD_REQ_DT" GF="C" style="text-align: center;">생산요청일</td>
										<td GH="150" GCol="text,WRK_ORDR_NO" style="text-align: center;">작업지시번호</td>
										<td GH="140" GCol="text,MATNR" style="text-align: center;" >자재코드</td>
										<td GH="320" GCol="text,MATNR_NM" style="text-align: center;">자재명</td>
										<td GH="100" GCol="text,WRK_ORDR_QTY" GF="N 10,3">지시량</td>
										<td GH="100" GCol="text,WERKS" style="text-align:center;">플랜트</td>
										<td GH="100" GCol="text,ORDER_NO" style="text-align: center;">오더번호</td>
										<td GH="80" GCol="text,WRK_SEQNO" style="text-align: center;">작업순서</td>
										<td GH="100" GCol="text,UNIT" style="text-align: center;">단위</td>
										<td GH="250" GCol="text,WRK_ORDR_REMARK">작업지시비고</td>
										<td GH="100" GCol="text,USE_FLAG" style="text-align: center;">오더 삭제여부</td>
										<td GH="100" GCol="text,COMP_YN_NM" style="text-align:center;">작업지시상태 (N:대기 I:작업중 Y:완료 오더 삭제:작업지시 삭제)</td>
										<td GH="100" GCol="text,MACHINE" style="text-align: center;">생산호기</td>
										<td GH="100" GCol="text,ORDR_QTY" GF="N 10,3">오더량</td>
										<td GH="100" GCol="text,ORDR_GEN_DT" GF="C" style="text-align:center;">작업지시일자</td>
										<td GH="100" GCol="text,COMP_QTY" GF="N 10,3">완료수량</td>
										<td GH="150" GCol="text,PRD_STR_DTM" style="text-align:center;">생산시작시간</td>
										<td GH="150" GCol="text,PRD_END_DTM" style="text-align:center;">생산완료시간</td>
										<td GH="100" GCol="text,PCODE" style="text-align: center;" >지종코드</td>
										<td GH="100" GCol="text,PCODE_NM" style="text-align: center;">지종코드명</td>
										<td GH="100" GCol="text,BS_WGT" style="text-align: center;">평량</td>
										<td GH="100" GCol="text,WLEN" style="text-align: center;">가로길이</td>
										<td GH="100" GCol="text,VLEN" style="text-align: center;">세로길이</td>
										<td GH="100" GCol="text,PLT_PER_CNT" style="text-align: center;">팔레트당연수</td>
										<td GH="100" GCol="text,IN_PER_CNT" style="text-align: center;">속당매수</td>
										<td GH="100" GCol="text,MCNT" style="text-align: center;">매</td>
										<td GH="100" GCol="text,SCNT" style="text-align: center;">속</td>
										<td GH="100" GCol="text,KUNNR" style="text-align: center;">판매처코드</td>
										<td GH="140" GCol="text,KUNNRT" style="text-align: center;">판매처</td>
										<td GH="100" GCol="text,MACH_CD" style="text-align: center;">설비코드</td>
										<td GH="140" GCol="text,MACH_NM" style="text-align: center;">설비명</td>
										<td GH="150" GCol="text,REGDATE" style="text-align: center;">등록일시</td>
										<td GH="100" GCol="text,REGNM" style="text-align: center;">등록자</td>
										<td GH="150" GCol="text,UPDDATE" style="text-align: center;">수정일시</td>
										<td GH="100" GCol="text,UPDNM" style="text-align: center;">수정자</td>		
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