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
	    	url : "/mes/Inv/INV03/json/datalist.data",
	    	bigdata : false,
	    	selectRowDeleteType : true,
	    	colHoldType : true,
	    	colHold : "WERKS, INP_DT, INP_NM, MACHINE, MAT_LINE_CD, WRK_METH"
	    });
		$("#WERKS").val('P100');
	});

	function comboEventDataBindeBefore(comboAtt){
		if(comboAtt == "Produce,MACHINE"){
			var param = new DataMap();
			
			param.put("WERKS", 'P100');
		}
		return param;
	}

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
			
			for(var i = 0; i < list.length; i++){
				gridList.setRowReadOnly(gridId, i, true, ["MACHINE", "MAT_LINE_CD", "WRK_METH", "MATNR"]);
			}
		}
	}
	
	function gridListEventColValueChange(gridId, rowNum, colName, colValue){
		if(gridId == "gridList"){
			if(colName == "INP_DT"){
				var param = new DataMap();
				
				param.put("WERKS", "P100");
				param.put("INP_DT", colValue);
				
				var json = netUtil.sendData({
					module   : "Inv",
					command  : "INPDT",
					sendType : "list",
					param : param
				});
				
				if(json.data.length > 0){
					if(json.data[0].WEIGHT_V.trim() == ""){
						alert("투입일자에 베일중량 값이 없습니다.");
						gridList.setColValue(gridId, rowNum, colName, "");
					}
					gridList.setColValue(gridId, rowNum, "WEIGHT_V", json.data[0].WEIGHT_V);
				} else{
					alert("투입일자에 베일중량 정보가 없습니다.");
					gridList.setColValue(gridId, rowNum, colName, "");
				}
				
			} else if(colName == "SUPY_CD"){
				var param = new DataMap();
				param.put("SUPY_CD", colValue);
				
				var json = netUtil.sendData({
					module   : "Inv",
					command  : "SUPY_CD",
					sendType : "count",
					param : param
				});
				
				if(json.data <= 0){
					alert("공급업체 정보가 없습니다.");
					gridList.setColValue(gridId, rowNum, colName, "");
				}
			}
		}
	}
	
	function saveData(){
		if(gridList.getModifyRowCount("gridList") == 0){
			commonUtil.msgBox("MASTER_M0545");
			return;
		}
		
		if(gridList.validationCheck("gridList", "data")){
			var list = gridList.getModifyList("gridList", "A");
			
			for(var i = 0; i < list.length; i++){
				var inqty = list[i].get("IN_QTY");
				
				if(inqty == " "){
					alert("투입량을 입력해주시기 바랍니다.");
					return;
				}
			}
			
			if(!commonUtil.msgConfirm(configData.MSG_MASTER_SAVE_CONFIRM)){
				return;
			}
			
			var param = new DataMap();
			
			param.put("P_TYPE", "SAVE");
			param.put("list", list);
			
			netUtil.send({
				url : "/mes/Inv/INV03/json/datalist.data",
				param : param,
				successFunction : "saveSuccessCallBack",
			});
		}
	}

	function saveSuccessCallBack(json){
		if(json && json.data){
			commonUtil.msgBox(configData.MSG_SYSTEM_SAVEOK);
			searchList();
		}
	}
	
	function commonBtnClick(btnName){
		if(btnName == "Search"){
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
					<input type="button" id="button-1-1" CB="Search SEARCH BTN_SEARCH" />				
					<input type="button" id="button-1-2" CB="Save SAVE BTN_SAVE" />
				</div>
			</div>
			<div class="search_inner">
				<div class="search_wrap ">
					<dl>
						<dt CL="STD_INP_DT">투입일자</dt>
						<dd>
							<input type="text" name="I006.INP_DT" UIInput="B" UIFormat="C M1"/>
						</dd>
					</dl>
					<dl>
						<dt CL="STD_MATNR">자재코드</dt>
						<dd>
							<input type="hidden" name="WERKS" value='P100'/>
							<input type="text" name="I006.MATNR" UIInput="SR,MATKY" UIFormat="U"/>
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
					<li><a href="#tab1-1"><span CL="STD_GRD_INV03">사용이력</span></a></li>
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
										<td GH="0" GCol="text,WERKS" style="text-align:center;">플랜트</td>
										<td GH="100" GCol="add,INP_DT" style="text-align:center;" GF="C" validate="required">투입일자</td>
										<td GH="100" GCol="text,INP_NM">투입자명</td>			
										<td GH="100" GCol="select,MACHINE" validate="required">
											<select Combo="Produce,MACHINE">호기
												<option value=""></option>
											</select>
										</td>				
										<td GH="100" GCol="select,MAT_LINE_CD" >
											<select CommonCombo="MATLINECD">원료라인
												<option value=""></option>
											</select>
										</td>				
										<td GH="100" GCol="select,WRK_METH" >
											<select CommonCombo="WRKMETH">근무방식
												<option value=""></option>
											</select>
										</td>
										<td GH="140" GCol="input,MATNR,MATKY" style="text-align:center;" validate="required">자재코드</td>		
										<td GH="320" GCol="text,MATNR_NM">자재명</td>			
										<td GH="100" GCol="input,SUPY_CD,CUST" style="text-align:center;">공급업체</td>			
										<td GH="130" GCol="text,SUPY_NM">공급업체명</td>
										<td GH="100" GCol="text,WEIGHT_V" GF="N 13">베일당중량</td>			
										<td GH="100" GCol="input,WEIGHT_QTY" GF="N 13">베일수</td>
										<td GH="100 수량단위" GCol="text,EAUNIT" style="text-align:center;">베일수단위(수량단위)</td>
										<td GH="100" GCol="text,USE_QTY" GF="N 13">사용량</td>
										<td GH="100" GCol="text,UNIT" style="text-align:center;">단위</td>	
										<td GH="0" GCol="text,WRK_CLASS">반</td>			
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
						<jsp:param value="1" name="authCd"/>
						<jsp:param value="1,2,3,4,5,6,7,9,10" name="showAuthCd"/>
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