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
		    	url : "/mes/Master/MAS04/json/datalist.data",
		    	bigdata : false,
		    	pkcol :"EMPLY_NO",
		    	selectRowDeleteType : true
		    });
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
		
		function gridListEventDataBindEnd(gridId, dataLength){
			if(gridId == "gridList"){
				var list = gridList.getGridData(gridId);
				
				for(var i = 0; i < dataLength; i++){
					gridList.setRowReadOnly(gridId, i, true, ["EMPLY_DIV"]);
				}
			}
		}
		
		function saveData(){
			if(gridList.validationCheck("gridList", "data")){
				if(gridList.getModifyRowCount("gridList") == 0){
					commonUtil.msgBox("MASTER_M0545");
					return;
				}
				
				var list = gridList.getSelectData("gridList");
				
				if(!commonUtil.msgConfirm(configData.MSG_MASTER_SAVE_CONFIRM)){
					return;
				}

				var param = new DataMap();

				param.put("P_TYPE", "SAVE");
				param.put("list", list);

				netUtil.send({
					url : "/mes/Master/MAS04/json/datalist.data",
					param : param,
					successFunction : "savesuccessCallBack"
				});
			}
		}
		
		function savesuccessCallBack(json){
			if(json&&json.data){
				commonUtil.msgBox(configData.MSG_SYSTEM_SAVEOK);
				searchList();
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
					<dt CL="STD_EMPLY_NO">사원번호</dt>
					<dd><input type="text" class="input" name="EMPLY_NO" UIFormat="U" UIInput="SR"/></dd>
					</dl>
					<dl>
						<dt>사원명</dt>
						<dd><input type="text" class="input" name="EMPLY_KR_NM" UIInput="SR"/></dd>
					</dl>
					<dl>
						<dt CL="STD_DEPT_CD">부서코드</dt>
						<dd>
							<input type="text" class="input" name="DEPT_CD" UIFormat="U" UIInput="SR,DEPT"/>
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
									<td GH="100" GCol="add,EMPLY_NO" validate="required" style="text-align:center;"></td>			<!--사원번호-->       
									<td GH="100" GCol="add,EMPLY_KR_NM"></td>			<!--사원명(한글)-->    
									<td GH="120" GCol="add,EMPLY_EN_NM"></td>			<!--사원명(영문)-->    
									<td GH="100" GCol="add,WAREKY,WARE" style="text-align:center;"></td>				<!--소속공장(CP,UP)--> 
									<td GH="100" GCol="text,WARE_NM">공장지명</td>				<!--소속공장(CP,UP)--> 
									<td GH="100" GCol="add,DEPT_CD,DEPT" style="text-align:center;"></td>				<!--부서코드-->       
									<td GH="110" GCol="text,DEPT_NM"></td>				<!-- 부서명 -->
									<td GH="100" GCol="input,PROC_CD,OP" style="text-align:center;"></td>				<!--공정코드-->
									<td GH="100" GCol="text,PROC_NM"></td>				<!-- 공정명 -->       
									<td GH="100" GCol="input,WRK_TEAM" style="text-align:center;"></td>				<!--작업팀명-->       
									<td GH="100" GCol="input,WRK_CLASS" style="text-align:center;" GF="N 13"></td>			<!--작업반명-->       
									<td GH="200" GCol="input,EMAIL" validate="email"></td>				<!--이메일-->         	
									<td GH="100" GCol="input,WRK_SHIFT"></td>			<!--작업조-->         
									<td GH="100" GCol="select,RETR_YN">
										<select>
											<option value=""></option>
											<option value="Y">Y</option>
											<option value="N">N</option>
										</select>
									</td>				<!--퇴직여부(Y/N)-->
									<td GH="100" GCol="input,EMPLY_DIV"></td>				<!--직원구분-->       
									<td GH="100" GCol="add,DUT_CD" style="text-align:center;"></td>				<!--직책코드-->        
									<td GH="100" GCol="add,DUT_NM"></td>				<!--직책명-->          
									<td GH="100" GCol="add,PST_CD" style="text-align:center;"></td>				<!--직위코드-->        
									<td GH="100" GCol="add,PST_NM"></td>				<!--직위명-->          
									<td GH="100" GCol="input,SYNC_SEQNO" style="text-align:right;" GF="NS"></td>			<!--동기화차수-->   
									<td GH="140" GCol="text,REGDATE" style="text-align:center;"></td>
									<td GH="100" GCol="text,REGNM"></td>
									<td GH="140" GCol="text,UPDDATE" style="text-align:center;"></td>
									<td GH="100" Gcol="text,UPDNM"></td>
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