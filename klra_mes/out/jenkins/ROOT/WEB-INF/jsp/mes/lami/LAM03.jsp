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
			url : "/mes/Lam/LAM03/json/datalist.data",
			bigdata : false,
			colHoldType : true,
			colHold : "WERKS",
			colorType : true
	    });
		$("#WERKS").val('P100');
		//$("#MACHINE").val('PRD01');
	});
	// 조회
	function searchList(){
		if(validate.check("searchArea")){
			var param = inputList.setRangeParam("searchArea");
			param.put("P_TYPE","LIST");
			gridList.gridList({
				id : "gridList",
				param : param
			});
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
	
 	function gridListRowColorChange(gridId, rowNum, rowData){
		if(gridId === "gridList" && rowData.get("DELETEGBN") === "삭제"){
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
				<div class="search_wrap">
				  	<dl>
						<dt CL="STD_PLANT">플랜트</dt>
						<dd>							
							<input type="text" class="input" id="WERKS" name="WERKS"  readonly="readonly"/>
						</dd>
					</dl>
<!-- 					
					<dl>
						<dt CL="STD_MACHINE">생산호기</dt>
						<dd>
							<input type="text" class="input" id="MACHINE" name="MACHINE"  readonly="readonly"/>
						</dd>
					</dl>
-->					
					<dl>
						<dt CL="STD_BUDAT">생산요청일자</dt>
                        <dd><input type="text" id="BUDAT" name="GSTRP" UIInput="B" UIFORMAT="C M1"/></dd>
					</dl>
					<dl>
						<dt CL="STD_MATNR">자재코드</dt>
						<dd>
							<input type="text" id="MATNR" name="MATNR" UIInput="S,MATKY" UIFormat="U"/>
						</dd>
					</dl>
					
					<dl>
						<dt CL="STD_VBELN">판매문서번호</dt>
						<dd><input type="text" id="VBELN" name="VBELN" class="input" IAname="BS_WGT" UIFormat="U"/></dd>
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
										<td GH="100" GCol="text,WERKS" style="text-align:center;">플랜트</td>
										<td GH="100" GCol="text,AUFNR" style="text-align:center;">오더번호</td>
										<td GH="100" GCol="text,MRPO" style="text-align:center;">밀롤 오더 번호</td>
										<td GH="100" GCol="text,BUDAT" style="text-align:center;">생산요청일자</td>
										<td GH="100" GCol="text,MACHINE" style="text-align:center;">생산호기</td>
										<td GH="200" GCol="text,MATNR" style="text-align: center;" >자재코드</td>
										<td GH="300" GCol="text,MATNR_NM">자재명</td>
										<td GH="150" GCol="text,PCODE">지종코드</td>
										<td GH="100" GCol="text,BS_WGT" GF="N 10">평량</td>
										<td GH="100" GCol="text,VBELN">판매문서번호</td>
										<td GH="100" GCol="text,WLEN" GF="N 10">가로길이</td>
										<td GH="100" GCol="text,VLEN" GF="N 10">세로길이</td>
										<td GH="100" GCol="text,CNT" GF="N 10">수량</td>
										<td GH="100" GCol="text,TOT_WGT" GF="N 10,3">총중량</td>
										<td GH="150" GCol="text,UNIT">단위</td>
										<td GH="100" GCol="text,ZZATT1">팔레트당연수</td>
										<td GH="100" GCol="text,ZZATT2" GF="N 10">속당매수</td>
										<td GH="100" GCol="text,DOUBLEFLAG">쌍팔레트</td>
										<td GH="100" GCol="input,CUTTER">카터</td>
										<td GH="100" GCol="text,LAND1">내수/수출</td>
										<td GH="150" GCol="text,PACKTYPE">포장방법</td>
										<td GH="150" GCol="text,ORD_YN">오더완료</td>
										<td GH="150" GCol="text,RMK">비고</td>
										<td GH="150" GCol="text,REGDATE">등록일시</td>
										<td GH="100" GCol="text,REGNM">등록자</td>
										<td GH="150" GCol="text,UPDDATE">수정일시</td>
										<td GH="100" GCol="text,UPDNM">수정자</td>
										<td GH="150" GCol="text,DELETEGBN">삭제구분</td>
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
</div>
<!-- // content -->
<%@ include file="/common/include/webdek/bottom.jsp" %>
</body>
</html>