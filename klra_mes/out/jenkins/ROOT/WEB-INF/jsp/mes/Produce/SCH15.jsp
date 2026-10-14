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
			// 합지기
			gridList.setGrid({
				id : "gridList",
				url : "/mes/Produce/SCH15/json/datalist.data",
				bigdata : false,
				colHoldType : true,
                colHold : "WERKS,BUDAT,AUFNR,SEQ",
                colorType : true
			});
			
	 		// 하위 리스트
	 		gridList.setGrid({
				id : "gridListSub",
		    	url : "/mes/Produce/SCH15/json/datalist.data",
		    	bigdata : false
		    });
		});
		
		// 조회(HEADER)
		function searchList(){
			// VALIDATION
			if($("#WERKS").val() === "P100"){
				alert("PS 예외 생산 정보는 예외생산 오더 조회(PS)에서 확인가능합니다.")
				$("#WERKS").focus()
				return
			}
			
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
		
		// 행 더블 클릭
		function gridListEventRowDblclick(gridId, rowNum){
			if(gridId === "gridList") searchSubList(gridId, rowNum)
		}
		
		// 조회(오더 BOM)
		function searchSubList(gridId, rowNum){
			
			var param = inputList.setRangeParam("searchArea");
			
			param.put("P_TYPE", "SUB_LIST");
			param.put("AUFNR", gridList.getColData(gridId, rowNum, "AUFNR"));			
						
			gridList.gridList({
				id : "gridListSub",
				param : param
			});
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
							<input type="text" class="input" id="WERKS" name="WERKS" UIInput="S,PLANT" UIFormat="U" validate="required" />
						</dd>
					</dl>
					<dl>
						<dt CL="STD_MATNR">자재코드</dt>
						<dd>
							<input type="text" id="MATNR" name="MATNR" UIInput="SR,MATKY" UIFormat="U"/>
						</dd>
					</dl>
					<dl>
						<dt>생산요청일자</dt>
                        <dd><input type="text" id="GSTRS" name="GSTRS" UIInput="B" UIFORMAT="C M1"/></dd>
					</dl>
					<dl>
						<dt CL="STD_AUFNR">오더번호</dt>
						<dd>
							<input type="text" class="input" id="AUFNR" name="AUFNR" UIInput="SR" UIFormat="U" />
						</dd>
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
										<td GH="100" GCol="text,WERKS" style="text-align: center;">플랜트</td>
										<td GH="100" GCol="text,BUDAT" GF="C" style="text-align: center;">생산요청일자</td>
										<td GH="150" GCol="text,AUFNR" style="text-align: center;">오더번호</td>
										<td GH="60" GCol="text,SEQ" GF="N 10">작업순서</td>
										<td GH="160" GCol="text,BRAND_DESCR">브랜드</td>
										<td GH="250" GCol="text,MATNR" style="text-align: center;">자재코드</td>		
										<td GH="250" GCol="text,MATNR_NM">자재명</td>
										<td GH="100" GCol="text,FQTY" GF="N 13">오더량</td>
										<td GH="100" GCol="text,UNIT_NM" style="text-align: center;">단위명</td>
										<td GH="80" GCol="text,BS_WGT" GF="N 13">평량</td>
										<td GH="80" GCol="text,WLEN" GF="N 13">가로</td>
										<td GH="80" GCol="text,VLEN" GF="N 13">세로</td>
										<td GH="80" GCol="text,DELETEGBN" style="text-align: center;">삭제구분</td>
										<td GH="150" GCol="text,REGDATE" style="text-align: center;">등록일시</td>
										<td GH="100" GCol="text,REGNM">등록자</td>
										<td GH="150" GCol="text,UPDDATE" style="text-align: center;">수정일시</td>
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
			<div class="content_layout tabs bottom_layout">
				<ul class="tab tab_style02">
					<li><a href="#tab1-1"><span>상세</span></a></li>
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
								<tbody id="gridListSub">
								<tr CGRow="true">
									<td GH="40" GCol="rownum">1</td>
										<td GH="0" GCol="text,AUFNR" style="text-align:center;">오더번호</td>
										<td GH="100" GCol="text,POSNR" style="text-align:center;">오더Item번호</td>
										<td GH="200" GCol="text,MATNR" style="text-align: center;">자재코드</td>
										<td GH="300" GCol="text,MATNR_NM">자재명</td>
										<td GH="100" GCol="text,BDMNG" GF="N 10,3">오더BOM수량(기준정보)</td>
										<td GH="150" GCol="text,MEINS" style="text-align: center;">오더BOM단위(기준정보)</td>
										<td GH="150" GCol="text,MEINS_NM">오더BOM단위(명)</td>
										<td GH="0" GCol="text,BMENG" GF="N 10,3">BOM 수량</td>
										<td GH="0" GCol="text,BMEIN" style="text-align:center;">BOM 수량단위</td>
										<td GH="0" GCol="text,UNIT_NM" style="text-align:center;">BOM 수량단위 (명)</td>
										<td GH="100" GCol="text,LGORT" style="text-align:center;">저장위치</td>
										<td GH="100" GCol="text,STOR_LOC_NM">저장위치명</td>
										<td GH="100" GCol="text,DELETEYN" style="text-align:center;">삭제여부</td>								
										<td GH="150" GCol="text,REGDATE" style="text-align:center;">등록일시</td>
										<td GH="100" GCol="text,REGNM">등록자</td>
										<td GH="150" GCol="text,UPDDATE" style="text-align:center;">수정일시</td>
										<td GH="100" GCol="text,UPDNM">수정자</td>
								</tr>
								</tbody>
							</table>
						</div>
					</div>
					<jsp:include page="/WEB-INF/jsp/common/commonBtnAuth.jsp">
						<jsp:param name="authCd" value="3" />
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