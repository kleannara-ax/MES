<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>WMS</title>
<%@ include file="/common/include/webdek/head.jsp" %>
<script type="text/javascript">
	$(document).ready(function(){
		//setTopSize(800);
	 	gridList.setGrid({
	    	id : "gridList",
			editable : true,
			module : "System",
			command : "LG03"
		}); 
	});
	
	function searchList(){
		var param = inputList.setRangeParam("searchArea");
		
		gridList.gridList({
	    	id : "gridList",
	    	param : param
	    });
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
					<input type="button" CB="Search SEARCH BTN_SEARCH" />
				</div>
			</div>
			<div class="search_inner">
				<div class="search_wrap ">
					<dl>
						<dt CL="STD_LOGDAT"></dt>
						<dd>
							<input type="text" name="SL.LOGDAT" UIInput="R" UIFormat="C N" />
						</dd>
					</dl>
					<dl>
						<dt CL="STD_LOGTYP"></dt>
						<dd>
							<!-- <select name="DELETEYN" class="input" CommonCombo="DELYN" ComboCodeView=false>
								<option value="" CL="STD_ALL"></option>
							</select> -->
							<select Combo="System,LOGTYP_ROLE_COMBO" name="LOGTYP" validate="required" style="width:160px">
								<option value="">------- 선택 -------</option>
							</select>
						</dd>
					</dl>
					<dl>
						<dt CL="STD_LOGUSR"></dt>
						<dd>
							<input type="text" name="SL.LOGUSR" UIInput="R,SHUSRMA" size="8px" />
						</dd>
					</dl>
					<dl>
						<dt CL="STD_LOGUNM"></dt>
						<dd>
							<input type="text" name="US.NMLAST" UIInput="R"  validate="required"/>
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
				</ul>
				<div class="table_box section" id="tab1-1">
					<div class="table_list01">
						<div class="scroll">
							<table class="table_c">
								<tbody id="gridList">
									<tr CGRow="true">
										<td GH="40 STD_NUMBER" GCol="rownum">번호</td>
										<td GH="100 STD_LOGDAT" GCol="text,LOGDAT" GF="C">이력일자</td>
										<td GH="100 STD_LOGTIM" GCol="text,LOGTIM" GF="T">로그인시간</td>
										<td GH="100 STD_LOGTYP" GCol="text,LOGTYP">로그타입</td>
										<td GH="140 STD_LOGTNM" GCol="text,LOGTNM">로그타입명</td>
										<td GH="100 STD_LOGUSR" GCol="text,LOGUSR">로그사용자ID</td>
										<td GH="100 STD_LOGUNM" GCol="text,NMLAST">로그사용자명</td>
										<td GH="100 STD_LOGIPA" GCol="text,LOGIPA">로그IP</td>
										<td GH="100 STD_PROGID" GCol="text,PROGID">이력일자</td>
										<td GH="100 STD_PROGNM" GCol="text,PROGNM">이력일자</td>
										<td GH="180 STD_REMARK" GCol="text,REMARK">비고</td>
									</tr>
								</tbody>
							</table>
						</div>
					</div>
					<div class="btn_lit tableUtil">
						<button type="button" GBtn="find"></button>
						<button type="button" GBtn="sortReset"></button>
						<button type="button" GBtn="copy"></button>
						<button type="button" GBtn="layout"></button>
						<button type="button" GBtn="total"></button>
						<button type="button" GBtn="excel"></button>
						<span class='txt_total' >총 건수 : <span GInfoArea='true'>4</span></span>
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