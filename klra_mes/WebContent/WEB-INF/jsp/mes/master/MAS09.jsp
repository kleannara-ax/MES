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
	    	url : "/mes/Master/MAS09/json/datalist.data",
	    	bigdata: false,
	    	selectRowDeleteType : true
	    });
	});

	function searchList(){
		if(validate.check("searchArea")){
			var param = inputList.setRangeParam("searchArea");
			
			param.put("P_TYPE","LIST");
			param.put("WERKS", param.get("WERKS").trim());
			
			gridList.gridList({
		    	id : "gridList",
		    	param : param
		    });
		}
	}
	
	function gridListEventColValueChange(gridId, rowNum, colName, colValue){
		var werks = gridList.getColData(gridId, rowNum, 'WERKS');
		var machcd = gridList.getColData(gridId, rowNum, 'MACH_CD').substr(0, 3);
		
		if(colName == 'WRK_POT'){
			if(werks == 'P200'){
				if(machcd == 'TAA'){
					if(colValue != 'N'){
						alert("합지기는 미설정만 등록가능합니다.");
						gridList.setColValue(gridId, rowNum, colName, '');
					}
				}else if(machcd == 'TRA'){
					if(colValue == 'N'){
						alert("화장기 가공은 미설정 등록 불가능합니다.");
						gridList.setColValue(gridId, rowNum, colName, '');
					}
				}else{
					if(colValue != 'N'){
						alert("화장지 예외생산은 미설정만 등록가능합니다.");
						gridList.setColValue(gridId, rowNum, colName, '');
					}
				}
			}else if(werks == 'P300'){
				if(machcd == 'SRB'){
					if(colValue == 'N'){
						alert("생리대 가공은 미설정 등록 불가능합니다.");
						gridList.setColValue(gridId, rowNum, colName, '');
					}
				}else{
					if(colValue != 'N'){
						alert("생리대 예외생산은 미설정만 등록가능합니다.");
						gridList.setColValue(gridId, rowNum, colName, '');
					}
				}
			}else if(werks == 'P500'){
				if(machcd == 'BRC'){
					if(colValue == 'N'){
						alert("기저귀 가공은 미설정 등록 불가능합니다.");
						gridList.setColValue(gridId, rowNum, colName, '');
					}
				}else{
					if(colValue != 'N'){
						alert("기저귀 예외생산은 미설정만 등록가능합니다.");
						gridList.setColValue(gridId, rowNum, colName, '');
					}
				}
			}
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
			var list = gridList.getModifyList("gridList", "A");

			var param = new DataMap();

			param.put("P_TYPE","SAVE");
			param.put("list", list);

			var json = netUtil.sendData({
				url : "/mes/Master/MAS09/json/datalist.data",
				param : param
			});
			
			if(json){
				if(json.data){
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
							<input type="text" name="WERKS" validate="required" UIInput="S,PLANT" UIFormat="U"/>
						</dd>
					</dl>
					<dl>
						<dt CL="STD_IP_ADDRESS">IP</dt>
						<dd>
							<input class="input" type="text" name="IP_ADDRESS"/>
						</dd>
					</dl>
					<dl>
						<dt CL="STD_MACH_CD">설비</dt>
						<dd>
							<input type="text" name="M029.MACH_CD" UIInput="SR,MACH" UIFormat="U"/>
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
					<li><a href="#tab1-1"><span CL="STD_GENERAL">일반</span></a></li>
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
										<td GH="100" GCol="add,IP_ADDRESS" validate="required" GF="S 30" style="text-align:center;">IP</td>
										<td GH="100" GCol="add,WERKS,PLANT" validate="required" style="text-align:center;">플랜트</td>
										<td GH="100" GCol="add,MACH_CD,MACH" validate="required" style="text-align:center;">설비</td>
										<td GH="140" GCol="text,MACH_NM">설비명</td>
										<td GH="100" GCol="select,WRK_POT" validate="required">
											<select CommonCombo="WRKPOT">POP 위치정보
												<option value=""></option>
											</select>
										</td>
										<td GH="100" GCol="select,USE_YN">
											<select CommonCombo="USEYN">사용유무
												<option value=""></option>
											</select>
										</td>
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
						<jsp:param name="authCd" value="2" />
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