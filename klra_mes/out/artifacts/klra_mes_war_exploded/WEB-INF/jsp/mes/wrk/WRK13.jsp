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
	    	module : "System",
			command : "SYSLABEL"
	    });
		
		
	});

	function searchList(){
		if(validate.check("searchArea")){
			var param = inputList.setRangeParam("searchArea");

			gridList.gridList({
		    	id : "gridList",
		    	param : param
		    });
			
			
		}
	}
	function saveData(){
		if(gridList.validationCheck("gridList", "all")){
			gridList.gridSave({
		    	id : "gridList",
		    	modifyType : "A"
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
						<!-- <dt CL="STD_STCKY">생산호기</dt>
						<dd><select class="input" name="STCKY" CommonCombo="STCKY">
								
							</select>
						</dd> -->
					</dl>
					
					<dl>
						<!-- <dt CL="STD_PLANDT">지시일자</dt>
						<dd><input type="text" name="PLANDT" UIInput="R" UIFORMAT="C M1"/></dd> -->
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
							<table class="table_c">
								<tbody id="gridList">
									<tr CGRow="true">
										<td GH="100" GCol="text,라인교체일시"></td>
										<td GH="100" GCol="text,라인교체자"></td>
										<td GH="100" GCol="text,BARCODE"></td>
										<td GH="100" GCol="text,LOT_ID"></td>
										<td GH="100" GCol="text,밀롤실적일시"></td>
										<td GH="100" GCol="text,지종코드"></td>
										<td GH="100" GCol="text,PCODE">지종</td>
										<td GH="100" GCol="text,WEIGHT">평량</td>
										<td GH="100" GCol="text,WLEN">가로길이</td>
										<td GH="100" GCol="text,VLEN">세로길이</td>
										<td GH="100" GCol="text,권치수"></td>
										<td GH="100" GCol="text,중량"></td>
										<td GH="100" GCol="text,내수,수출"></td>
										<td GH="100" GCol="text,CUST_CD">거래처</td>
										<td GH="100" GCol="text,NATNKY">국가</td>
										<td GH="100" GCol="text,판매오더"></td>
										<td GH="100" GCol="text,밀롤호기"></td>
										<td GH="100" GCol="text,밀롤작업설비"></td>
										<td GH="100" GCol="text,MATNR">자재코드</td>
										<td GH="100" GCol="text,LOC_CD">로케이션코드</td>
										<td GH="100" GCol="text,번호"></td>
									
																
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