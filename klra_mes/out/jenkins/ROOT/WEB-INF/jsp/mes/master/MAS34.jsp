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
				url : "/mes/Master/MAS34/json/datalist.data",
				bigdata : false
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
						<dt CL="STD_PLANT">플랜트</dt>
						<dd>
							<input type="text" class="input" name="WERKS" value='P100' UIFormat="U" readonly="readonly"/>
						</dd>
					</dl>
					
					<dl>
                        <dt CL="STD_DT">일자</dt>
                        <dd><input type="text" name="DT" UIInput="B" UIFORMAT="C M1"/></dd>
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
									<td GH="100" GCol="text,WERKS" style="text-align:center;">플랜트</td>
									<td GH="100" GCol="text,DT" style="text-align:center;">일자</td>
									<td GH="100" GCol="text,WEIGHT_V" GF="N 13,3">베일중량</td>
									<td GH="100" GCol="text,WUNIT" style="text-align:center;">중량단위</td>
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