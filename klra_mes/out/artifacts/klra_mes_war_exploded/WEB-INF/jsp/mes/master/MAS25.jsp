<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Grid default</title>
<%@ include file="/common/include/webdek/head.jsp" %>
<style type="text/css">
 .content_wrap{background: none;}
</style>
<script type="text/javascript">
	$(document).ready(function(){
		gridList.setGrid({
			id : "gridList",
			url : "/mes/Master/MAS25/json/datalist.data",
			bigdata : false,
			colHoldType : true,
	    	colHold : "COMPKY,WAREKY,NAME01,DELMAK",
	    	selectRowDeleteType : true
		});
		searchList();
	});
	
	function searchList(){
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
		if(gridList.getModifyRowCount("gridList") == 0 ){
			commonUtil.msgBox("MASTER_M0545");
			
			return;
		}
		if(!commonUtil.msgConfirm(configData.MSG_MASTER_SAVE_CONFIRM)){
			return;
		}
		if(gridList.validationCheck("gridList", "all")){
			var list = gridList.getGridData("gridList");

			var param = new DataMap();

			param.put("P_TYPE","SAVE");
			param.put("list", list);

			var json = netUtil.sendData({
				url : "/mes/Master/MAS25/json/datalist.data",
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
				<div class="fl_r">
					<input type="button" id="button-0-1" CB="Search SEARCH BTN_SEARCH" />
					<input type="button" id="button-0-2" CB="Save SAVE BTN_SAVE" />
				</div>
			</div>
		</div>
		<div class="search_next_wrap noSearch">
			<div class="content_layout tabs">
				<ul class="tab tab_style02">
					<li><a href="#tabs1-1" CL='STD_GENERAL'><span>일반</span></a></li>
					<li class="btn_zoom_wrap">
						<ul>
							<!-- <li><button class="btn btn_smaller"><span>축소</span></button></li> -->
							<li><button class="btn btn_bigger"><span>확대</span></button></li>
						</ul>
					</li>  
				</ul>
				<div class="table_box section" id="tabs1-1">
					<div class="table_list01">
						<div class="scroll">
							<table class="table_c">
								<tbody id="gridList">
									<tr CGRow="true">
										<td GH="40" GCol="rownum">1</td>
										<td GH="40" GCol="rowCheck"></td>
										<td GH="100" GCol="text,COMPKY" style="text-align:center;">회사</td>
										<td GH="100" GCol="text,WAREKY" style="text-align:center;">거점</td>
										<td GH="100" GCol="input,NAME01" GF="S 180">거점명</td>
										<td GH="100" GCol="check,DELMAK">삭제</td>
										<td GH="100" GCol="input,NAME02" GF="S 180">대표자이름</td>
										<td GH="260" GCol="input,ADDR01" GF="S 180">대표주소</td>
										<td GH="100" GCol="input,POSTCD" GF="S 30">우편번호</td>
										<td GH="100" GCol="input,NATNKY" style="text-align:center;">국가</td>
										<td GH="100" GCol="input,VATREG" GF="S 20">사업자등록번호</td>
										<td GH="100" GCol="input,FAXTL1" GF="S 20">팩스번호</td>
										<td GH="100" GCol="input,TELN01" GF="S 20" validate="tel(GRID_COL_TELN01_*)">전화번호</td>
										<td GH="100" GCol="input,WADN01" GF="S 60">관리자명</td>
										<td GH="100" GCol="input,WADT01" GF="S 60">관리자연락처</td>
										<td GH="100" GCol="input,WADM01" GF="S 60" validate="email(GRID_COL_WADM01_*)">e-Mail</td>
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