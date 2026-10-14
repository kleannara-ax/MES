<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>MES</title>
<%@ include file="/common/include/webdek/head.jsp" %>
<script type="text/javascript">
	$(document).ready(function(){
		gridList.setGrid({
			id : "gridList",
	    	url : "/mes/quality/MAS_QLT_USER/json/datalist.data",
	    	bigdata : false,
	    	colHoldType : true,
	    	selectRowDeleteType : true
	    });
	});
	
	function comboEventDataBindeBefore(comboAtt){
		if(comboAtt == "mes,COMMONCOMBO"){
			var param = new DataMap();
			
			param.put("CMCDKY", "QLT_USER_GRP");
		} else if(comboAtt == "project.mes.dao.quality.QualityMapper,MACHINE"){
			var param = new DataMap();

			param.put("WERKS", "P200");
			param.put("PROC_CD", "RA");
		}
		return param;
	}
	
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
		if(gridList.getModifyRowCount("gridList") == 0 ){
			commonUtil.msgBox("MASTER_M0545");
			
			return;
		}
		if(!commonUtil.msgConfirm(configData.MSG_MASTER_SAVE_CONFIRM)){
			return;
		}
		if(gridList.validationCheck("gridList", "data")){
			// var list = gridList.getGridData("gridList");
			var list = gridList.getModifyList("gridList", "A");

			var param = new DataMap();

			param.put("list", list);

			var json = netUtil.sendData({
				url : "/mes/quality/MAS_QLT_USER/json/save.data",
				param : param
			});
			
			if(json){
				if(json.isSuccess){
					commonUtil.msgBox(configData.MSG_SYSTEM_SAVEOK);
					searchList();
				} else {
					commonUtil.msgBox(configData.MSG_SYSTEM_SAVEEMPTY);
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
	
	function selectcombo(){
		
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
						<dt CL="STD_QLT_USER_GRP">검사자항목그룹</dt>
						<dd>
							<select class="input" name="QLT_USER_GRP" Combo="mes,COMMONCOMBO">
								<option value="">All</option>
							</select>
						</dd>
					</dl>
					<dl>
						<dt CL="STD_MACHINE">생산호기</dt>
						<dd>
							<select class="input" name="MACH_CD" Combo="project.mes.dao.quality.QualityMapper,MACHINE">
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
					<li><a href="#tab1-1"><span CL="STD_GENERAL"></span></a></li>
				</ul>
				<div class="table_box section" id="tab1-1">
					<div class="table_list01">
						<div class="scroll">
							<table class="table_c">
								<tbody id="gridList">
									<tr CGRow="true">
										<td GH="40" GCol="rownum">1</td>
										<td GH="40" GCol="rowCheck"></td>
										<td GH="0" GCol="input,SEQ">SEQ</td>
										<td GH="180" GCol="select,QLT_USER_GRP" validate="required">
											<select class="input" CommonCombo="QLT_USER_GRP" style="text-align: center">검사자그룹
												<option value=""></option>
											</select>
										</td>
										<td GH="150" GCol="select,MACH_CD">
											<select class="input" Combo="project.mes.dao.quality.QualityMapper,MACHINE">설비호기
												<option value=""></option>
											</select>
										</td>
										<td GH="120" GCol="input,INSPR_NM" validate="required" style="text-align: center">검사자</td>
										<td GH="100" GCol="select,USE_YN">
											<select class="input" style="text-align: center">사용여부(Y/N)
												<option value=""></option>
												<option value="Y">Y</option>
												<option value="N">N</option>
											</select>
										</td>
										<td GH="140" GCol="text,REGDATE" style="text-align:center;">등록일시</td>
										<td GH="100" GCol="text,REGID">등록자</td>
										<td GH="140" GCol="text,UPDDATE" style="text-align:center;">수정일시</td>
										<td GH="100" GCol="text,UPDID">수정자</td>
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