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
	    	url : "/mes/Master/MAS12/json/datalist.data",
	    	bigdata : false
	    });
		
		gridList.setGrid({
	    	id : "gridList2",
	    	url : "/mes/Master/MAS12/json/datalist.data",
	    	bigdata : false,
	    	selectRowDeleteType : true
	    });
		
	});
		
		function searchList(){
			gridList.resetGrid("gridList2");
			
			if(validate.check("searchArea")){
				var param = inputList.setRangeParam("searchArea");
				param.put("P_TYPE", "LIST");
				gridList.gridList({
					id : "gridList",
					param : param
				});
			}
		}
		
		function saveData(){
			if(gridList.validationCheck("gridList2", "data") && gridList.validationCheck("gridList", "data")){
				var list = gridList.getModifyData("gridList2", "A");
				var list1 = gridList.getModifyData("gridList", "A");
				
				if(list.length == 0 && list1.length == 0){
					commonUtil.msgBox("MASTER_M0545");
					return;
				} else{
					if(!commonUtil.msgConfirm(configData.MSG_MASTER_SAVE_CONFIRM)){
						return;
					}
				}

				var param = new DataMap();

				param.put("P_TYPE","SUB_SAVE");
				param.put("list", list);
				param.put("head", list1);

				netUtil.send({
					url : "/mes/Master/MAS12/json/datalist.data",
					param : param,
					successFunction : "saveSuccessCallBack"
				});
			}
		}
		
		function saveSuccessCallBack(json, status){
			if(json && json.data){
				commonUtil.msgBox(configData.MSG_SYSTEM_SAVEOK);
				searchList();
			}
		}
		
		function searchSubList(headRowNum){
			var werks = gridList.getColData("gridList", headRowNum, "WERKS");
			var storlocCd = gridList.getColData("gridList", headRowNum, "STOR_LOC_CD");
			var param = inputList.setRangeParam("searchArea");
			
			param.put("P_TYPE", "SUB_LIST");
			param.put("WERKS", werks);
			param.put("STOR_LOC_CD", storlocCd);

			gridList.gridList({
				id : "gridList2",
				param : param
			});
			
			lastFocusNum = headRowNum;
		}
		
		var lastFocusNum = 0;
		
		function gridListEventRowDblclick(gridId, rowNum){
			if(gridId == "gridList"){
				searchSubList(rowNum);
			}
		}

		function gridListEventRowAddBefore(gridId, rowNum) {
			if(gridId == "gridList2"){
				var STOR_LOC_CD = gridList.getColData("gridList", lastFocusNum, "STOR_LOC_CD");
				var WERKS = gridList.getColData("gridList", lastFocusNum, "WERKS");
				
				var newData = new DataMap();
				newData.put("STOR_LOC_CD", STOR_LOC_CD);
				newData.put("WERKS", WERKS);
				
				return newData;
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
				</div>
				<div class="btn_tab">
					<input type="button" class="btn_more" value="more" onclick="searchMore()"/>
				</div>
			</div>
		</div>
        <div class="search_next_wrap">
			<div class="content_layout tabs top_layout">
				<ul class="tab tab_style02">
					<li><a href="#tab1-1"><span>저장위치</span></a></li>
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
										<td GH="100" GCol="text,STOR_LOC_CD" validate="required" style="text-align:center;">저장위치코드</td>
										<td GH="140" GCol="text,STOR_LOC_NM">저장위치명</td>
										<td GH="140" GCol="input,WCS_STOR_LOC_CD" style="text-align:center;">WCS 저장위치</td>
										<td GH="0" GCol="text,RMK">비고</td>
										<td GH="140" GCol="text,REGDATE"style="text-align:center;"></td>
										<td GH="100" GCol="text,REGNM"></td>
										<td GH="140" GCol="text,UPDDATE"style="text-align:center;"></td>
										<td GH="100" GCol="text,UPDNM"></td>								
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
			<div class="content_layout tabs bottom_layout">
				<ul class="tab tab_style02">
					<li><a href="#tab1-2"><span >로케이션</span></a></li>
					<li class="btn_zoom_wrap">
                        <ul>
                            <li><button class="btn btn_bigger"><span>확대</span></button></li>
                        </ul>
                   	</li>
				</ul>
				<div class="table_box section" id="tab1-2">
					<div class="table_list01">
						<div class="scroll">
							<table class="table_c">
								<tbody id="gridList2">
									<tr CGRow="true">
										<td GH="40" GCol="rownum">1</td>
										<td GH="40" GCol="rowCheck"></td>
										<td GH="0" GCol="input,WERKS">플랜트</td>
										
										<td GH="0" GCol="input,STOR_LOC_CD" validate="required" style="text-align:center;">저장위치코드</td>
										<td GH="100" GCol="add,LOC_CD" validate="required" style="text-align:center;">로케이션코드</td>
										<td GH="180" GCol="input,LOC_NM">로케이션명</td>
										
										<td GH="140" GCol="text,REGDATE" style="text-align:center;"></td>
										<td GH="100" GCol="text,REGNM"></td>
										<td GH="140" GCol="text,UPDDATE" style="text-align:center;"></td>
										<td GH="100" GCol="text,UPDNM"></td>						
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