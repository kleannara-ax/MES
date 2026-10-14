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
			url : "/mes/Produce/SCH06/json/datalist.data",
			bigdata : false,
			colHoldType : true,
			colHold : "WERKS,BUDAT,AUFNR,MRPO",
			colorType : true
	    });
		$("#WERKS").val('P100');
	});

	function comboEventDataBindeBefore(comboAtt){
		if(comboAtt == "Produce,MACHINE"){
			var param = new DataMap();
			
			param.put("WERKS", 'P100');
		}
		return param;
	}

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
	
	// 2022-10-19(수요일) 안상현, 삭제구분이 "삭제"인 경우, 라인 오렌지
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
					<dl>
						<dt CL="STD_MACHINE">생산호기</dt>
						<dd>
							<select class="input" name="MACHINE" Combo="Produce,MACHINE">
								<option value="">All</option>
							</select>
						</dd>
					</dl>
					<dl>
						<dt CL="STD_BUDAT">생산요청일자</dt>
                        <dd><input type="text" id="BUDAT" name="BUDAT" UIInput="B" UIFORMAT="C M1"/></dd>
					</dl>
					<dl>
						<dt CL="STD_MATNR">자재코드</dt>
						<dd>
							<input type="text" id="MATNR" name="MATNR" UIInput="SR,MATKY" UIFormat="U"/>
						</dd>
					</dl>
					
					<dl>
						<dt CL="STD_VBELN">판매문서번호</dt>
						<dd><input type="text" id="VBELN" name="VBELN" class="input" IAname="BS_WGT" UIInput="SR" UIFormat="U"/></dd>
					</dl>
					<!-- 20230210 여한진 오더번호, 지종코드, 평량, 포장타입, 오더완료 검색조건 추가 -->
					<dl>
						<dt CL="STD_ORDER_NO">오더번호</dt>
						<dd>							
							<input type="text" class="input" name="AUFNR" UIInput="SR"/>
						</dd>
					</dl>
					<dl>
						<dt CL="STD_PCODE">지종코드</dt>
						<dd>							
							<input type="text" class="input" name="PCODE" UIInput='SR,PCODE' UIFormat="U"/>
						</dd>
					</dl>
					<dl>
						<dt CL="STD_BS_WGT">평량</dt>
						<dd>							
							<input type="text" class="input" name="BS_WGT" UIInput="SR"/>
						</dd>
					</dl>
					<dl>
						<dt CL="STD_PACKTYPE">포장타입</dt>
						<dd>
							<select class="input" name="PACKTYPE" commonCombo='PACK_TYPE'>
								<option value="">All</option>
							</select>
						</dd>
					</dl>
					<dl>
						<dt CL="STD_ORD_YN">오더완료</dt>
						<dd>
							<select class="input" name="COMP_YN">
								<option value="">All</option>
								<option value="N">대기</option>
								<option value="I">진행중</option>
								<option value="Y">완료</option>
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
					<li><a href="#tab1-1"><span CL="STD_GRD_SCH06">리스트</span></a></li>
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
										<td GH="100" GCol="text,BUDAT" GF="C" style="text-align:center;">생산요청일</td>
										<td GH="100" GCol="text,AUFNR" style="text-align:center;">오더번호</td>
										<td GH="100" GCol="text,MRPO" style="text-align:center;">밀롤 LOT</td>
										<td GH="100" GCol="text,MACHINE" style="text-align: center;">생산호기</td>
										<td GH="140" GCol="text,MATNR" style="text-align: center;">자재코드</td>
										<td GH="320" GCol="text,MATNR_NM" style="text-align: center;">자재명</td>
										<td GH="100" GCol="text,PCODE" style="text-align: center;">지종코드</td>
										<td GH="0" GCol="text,VBELN" style="text-align: center;">판매문서번호</td>
										<td GH="100" GCol="text,BS_WGT" style="text-align: center;">평량</td>
										<td GH="100" GCol="text,WLEN" style="text-align: center;">가로길이</td>
										<td GH="100" GCol="text,VLEN" style="text-align: center;">세로길이</td>
										<td GH="100" GCol="text,CNT" GF='N 10,3'>수량</td>
										<td GH='100 수량단위' GCol='text,OUNIT' style="text-align: center;"></td>
										<td GH="100" GCol="text,TOT_WGT" GF="N 10,3">총중량</td>
										<td GH="100 중량단위" GCol="text,WUNIT" style="text-align: center;">단위</td>
										<td GH="100" GCol="text,ZZATT1" GF='N 10,1'>팔레트당 연수</td>
										<td GH="100 연수단위" GCol="text,RUNIT" style="text-align: center;"></td>
										<td GH="100" GCol="text,ZZATT2" GF='N 10'>속당연수</td>
										<td GH="100 매수단위" GCol="text,EAUNIT" style="text-align: center;"></td>
										<td GH="100" GCol="text,DOUBLEFLAG" style="text-align: center;">쌍팔레트</td>
										<td GH="100" GCol="text,CUTTER" style="text-align: center;">카터</td>
										<td GH="100" GCol="text,LAND1" style="text-align: center;">내수/수출</td>
										<td GH="100" GCol="text,PACKTYPE" style="text-align: center;">포장방법</td>
										<td GH="100" GCol="text,ORD_YN" style="text-align: center;">오더완료</td>
										<td GH="300" GCol="text,RMK">비고</td>
										<td GH="80" GCol="text,DELETEGBN" style="text-align: center;">삭제구분</td>
										<td GH="150" GCol="text,REGDATE" style="text-align: center;">등록일시</td>
										<!-- <td GH="100" GCol="text,REGNM" style="text-align: center;">등록자</td> -->
										<td GH="150" GCol="text,UPDDATE" style="text-align: center;">수정일시</td>
										<!-- <td GH="100" GCol="text,UPDNM" style="text-align: center;">수정자</td> -->			
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