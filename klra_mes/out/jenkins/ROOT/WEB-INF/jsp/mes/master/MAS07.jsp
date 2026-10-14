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
				url : "/mes/Master/MAS07/json/datalist.data",
				bigdata : false,
				colHoldType : true,
		    	colHold : "CUST_TYPE,CUST_CD,CUST_NM"
			});
		});

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
						<dt CL="STD_CUST_DIV">거래처유형</dt>
						<dd>
							<select class="input" name="CUST_DIV" CommonCombo="CUSTTYPE">
								<option value="">All</option>
							</select>
						</dd>
					</dl>
					<dl>
						<dt CL="STD_CUST_CD">거래처코드</dt>
						<dd>
							<input type="text" class="input" name="CUST_CD" UIInput="SR,CUST" UIFormat="U"/>
						</dd>
					</dl>
					<dl>
						<dt CL="STD_CUST_NM">거래처명</dt>
						<dd>
							<input type="text" class="input" name="CUST_NM" UIInput="SR"/>
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
							<!-- <li><button class="btn btn_smaller"><span>축소</span></button></li> -->
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
									<td GH="120" GCol="text,CUST_DIV" style="text-align:center;">거래처구분</td>
									<td GH="100" GCol="text,CUST_CD" validate="required" style="text-align:center;">거래처코드</td>
									<td GH="140" GCol="text,CUST_NM" validate="required" style="text-align:center;">거래처명</td>
									
									
									<td GH="0" GCol="text,PSTLZ">우편번호</td>
									<td GH="0" GCol="text,LAND1">국가키</td>
									<td GH="0" GCol="text,TELF2">휴대폰번호</td>
									<td GH="0" GCol="text,TELF3">팩스번호</td>
									<td GH="0" GCol="text,SMTP_ADDR">거래처담당자 email주소</td>
									<td GH="0" GCol="text,STCD2">사업자등록번호</td>
									<td GH="0" GCol="text,DL_YN">삭제여부</td>
									<td GH="0" GCol="text,KUNNR">판매처</td>
									<td GH="0" GCol="text,KUNNRT">판매처명</td>
									<td GH="0" GCol="text,KUNZP">영업자ID</td>
									<td GH="0" GCol="text,KUNZPT">영업사원명</td>
									<td GH="0" GCol="text,TELFZP">영업사원 휴대폰 번호</td>
									<td GH="0" GCol="text,J_1KFTIND">업태</td>
									<td GH="0" GCol="text,J_1KFTBUS">업종</td>
									<td GH="0" GCol="text,CNAME">거래처 담당자명</td>
									<td GH="0" GCol="text,CPHON">거래처 담당자 휴대폰번호</td>
									<td GH="0" GCol="text,PTNG01">거래처메모</td>
									<td GH="0" GCol="text,PTNL01">공급처구분</td>
									
									<td GH="100" GCol="text,J_1KFREPRE">대표자명</td>
									<td GH="100" GCol="text,TELF1" validate="tel((GRID_COL_TELF1_*))">전화번호</td>
									<td GH="140" GCol="text,ADDR1">도시</td>
									<td GH="300" GCol="text,ADDR2">번지 및 상세 주소</td>
									<td GH="140" GCol="text,REGDATE" style="text-align:center;">등록일시</td>
									<td GH="100" GCol="text,REGNM">등록자</td>
									<td GH="140" GCol="text,UPDDATE" style="text-align:center;">수정일시</td>
									<td GH="100" GCol="text,UPDNM">수정자</td>
								</tr>
								</tbody>
							</table>
						</div>
					</div>
					<div class="btn_lit tableUtil">
						<jsp:include page="/WEB-INF/jsp/common/commonBtnAuth.jsp">
						<jsp:param name="authCd" value="1" />
						<jsp:param name="showAuthCd" value="1,2,3,9,10" />
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