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
	    	url : "/mes/Master/MAS08/json/datalist.data",
	    	bigdata : false,
	    	selectRowDeleteType : true
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
	function saveData(){
			if(gridList.getModifyRowCount("gridList") == 0 ){
			commonUtil.msgBox("MASTER_M0545");
			
			return;
		}
			if(!commonUtil.msgConfirm(configData.MSG_MASTER_SAVE_CONFIRM)){
				return;
			}
		if(gridList.validationCheck("gridList", "data")){
			var list = gridList.getGridData("gridList");

			var param = new DataMap();
			
			param.put("P_TYPE","SAVE");
			param.put("list", list);

			var json = netUtil.sendData({
				url : "/mes/Master/MAS08/json/datalist.data",
				param : param
			});
			if(json){
				if(json.data){
					commonUtil.msgBox(configData.MSG_SYSTEM_SAVEOK);
					searchList();
				}
			}
			
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
					<input type="button" id="button-0-2" CB="Save SAVE BTN_SAVE" />
				</div>
			</div>
			<div class="search_inner">
				<div class="search_wrap ">
					<dl>
						<dt CL="STD_PLANT">플랜트</dt>
						<dd>
							<input type="text" class="input" name="WERKS" validate="required" UIInput="S,PLANT" UIFormat="U"/>
						</dd>
					</dl>
					<dl>
						<dt CL="STD_PROC_NM">공정명</dt>
						<dd>
							<input type="text" class="input" name="PROC_NM" UIInput="SR"/>
						</dd>
					</dl>
					<dl>
						<dt CL="STD_PROC_GRP_CD">공정그룹</dt>
						<dd>
							<select class="input" name="PROC_GRP_CD" CommonCombo="PROCGRP">
								<option value="">All</option>
							</select>
						</dd>
					</dl>
					<dl>
						<dt CL="STD_PROD_GRP_CD">제품군</dt>
						<dd>
							<select class="input" name="PROD_GRP_CD" CommonCombo="PRODGRP">
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
										<td GH="40" GCol="rownum">1</td>
										<td GH="40" GCol="rowCheck"></td>
										<td GH="100" GCol="input,PROC_CD" validate="required" style="text-align:center;">공정코드</td>
										<td GH="140" GCol="input,PROC_NM" validate="required">공정명</td>
										<td GH="160" GCol="select,PROC_GRP_CD">
											<select class="input" CommonCombo="PROCGRP" validate="required"><!-- 공정그룹코드 -->
												<option value=""></option>
											</select>
										</td>
										<td GH="100" GCol="input,WERKS,PLANT" validate="required" style="text-align:center;">플랜트코드</td>
										<td GH="160" GCol="text,PLANTNM">플랜트명</td>
										<td GH="120" GCol="select,BUSICD">
											<select class="input" CommonCombo="BUSICD"><!-- 사업부코드 -->
												<option value=""></option>
											</select>
										</td>
										<td GH="140" GCol="select,PROD_GRP_CD">
											<select class="input" CommonCombo="PRODGRP" validate="required"><!-- 제품군 코드 -->
												<option value=""></option>
											</select>
										</td>
										<!-- 2022-09-20(화요일) 안상현, 김성하 총괄님 지시로 표시순서 컬럼 추가 -->
										<td GH="80" GCol="input,DISP_SEQ" GF="N 8">표시순서</td>
										<td GH="140" GCol="text,REGDATE" style="text-align:center;">등록일시</td>
										<td GH="100" GCol="text,REGNM">등록자</td>
										<td GH="140" GCol="text,UPDDATE" style="text-align:center;">수정일시</td>
										<td GH="100" GCol="text,UPDNM">수정자</td>
									</tr>
								</tbody>
							</table>
						</div>
					</div>
					<jsp:include page="/WEB-INF/jsp/common/commonBtnAuth.jsp">
						<jsp:param name="authCd" value="1" />
						<jsp:param name="showAuthCd" value="1,2,3,4,5,6,9,10" />
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