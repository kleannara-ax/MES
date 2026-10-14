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
	    	url : "/mes/Work/WRK09/json/datalist.data",
	    	bigdata : false,
	    	colHoldType : true,
	    	colHold : "WERKS,STOR_LOC_NM"
	    });
	});

	// 조회
	function searchList(){
		if(validate.check("searchArea")){
			
			var param = inputList.setRangeParam("searchArea");
			param.put("P_TYPE","LIST")
			param.put("WERKS", $("#WERKS").val().toUpperCase()) // 플랜트
			
			gridList.gridList({
				id : "gridList",
				param : param
			});
		}
	}
	
	// 버튼 클릭
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
							<input type="text" id="WERKS" name="WERKS" validate="required" UIInput="S,PLANT" UIFormat="U"/>
						</dd>
					</dl>
					<dl>
						<dt CL="STD_STOR_LOC_CD">저장위치</dt>
						<dd>
							<!-- 2023-03-13(월요일) 안상현, 저장위치 RANGE 검색 추가 -->
							<input type="text" id="STOR_LOC_CD" name="INV001.STOR_LOC_CD" UIInput="SR,LOC" UIFormat="U"/>
						</dd>
					</dl>
					<dl>
						<dt CL="STD_MATNR">자재코드</dt>
						<dd>
							<!-- 2023-03-13(월요일) 안상현, 자재코드 RANGE 검색 추가 -->
							<input type="text" name="INV001.MATNR" UIInput="SR,MATKY" UIFormat="U"/>
						</dd>
					</dl>
					<dl>
						<dt CL="STD_IND_BCD">개별바코드</dt>
						<dd>
							<!-- 2023-03-13(월요일) 안상현, 개별바코드 RANGE 검색 추가 --><!-- 20230314 여한진 개볇바코드 뷰생성하여 공통팝업 생성 -->
							<input type="text" class="input" id="IND_BCD" name="INV001.IND_BCD" UIInput="SR,INDBCD" UIFormat="U"/>
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
					<li><a href="#tab1-1"><span>재고정보</span></a></li>
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
										<td GH="100" GCol="text,STOR_LOC_CD" style="text-align:center;">저장위치코드</td>
										<td GH="100" GCol="text,STOR_LOC_NM" style="text-align:center;">저장위치명</td>
										<td GH="140" GCol="text,MATNR" style="text-align: center;">자재코드</td>
										<td GH="320" GCol="text,MATNR_NM" style="text-align:center;">자재명</td>
										<td GH="150" GCol="text,LOT_NO" style="text-align:center;">LOT번호</td>
										<td GH="150" GCol="text,IND_BCD" style="text-align:center;">개별바코드</td>
										<td GH="100" GCol="text,UNIT_NM" style="text-align:center;">단위명</td>
										<td GH="100" GCol="text,STCK_QTY" GF="N 10,3">재고수량</td>
										<td GH='100' GCol='text,STCK_STA' style="text-align:center;">재고상태</td>
										<td GH='100' GCol='text,UCFMTY_AMT' GF='N 13,3'>부적합수량</td>
										<td GH="100" GCol="text,REGDATE" GF="D" style="text-align: center;">등록일자</td>
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