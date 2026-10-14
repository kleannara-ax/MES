<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>MES</title>
<%@ include file="/common/include/webdek/head.jsp" %>
<link rel="stylesheet" type="text/css" href="/common/theme/webdek/css/demo_layout.css">
<script type="text/javascript">
	$(document).ready(function(){
		gridList.setGrid({
	    	id : "gridList",
	    	url : "/mes/Inv/INV04/json/datalist.data",
	    	bigdata : false
	    });
		
		gridList.setGrid({
	    	id : "gridList2",
	    	url : "/mes/Inv/INV04/json/datalist.data",
	    	bigdata : false,
	    	colHoldType : true,
	    	colHold : "WERKS, INP_DT, INP_NM"
	    });
	});

	function searchList(){
		if(validate.check("searchArea")){
			var param = inputList.setRangeParam("searchArea");
			param.put("P_TYPE", "LIST");	
			param.put("MACH_CD", $("#MACH_CD").val().toUpperCase());	
			param.put("IND_BCD", $("#IND_BCD").val().toUpperCase());	
			
			gridList.gridList({
		    	id : "gridList",
		    	param : param
		    });
		}
	}
	
	function searchSubList(rowNum){
		var param = inputList.setRangeParam("searchArea");
		
		var list = gridList.getRowData("gridList", rowNum);
		
		param.put("P_TYPE", "SUB_LIST");
		param.put("list", list);
		
		gridList.gridList({
			id : "gridList2",
			param : param
		});
	}
	
	function gridListEventRowDblclick(gridId, rowNum){
		if(gridId == "gridList"){

			searchSubList(rowNum);
		}
	}
	
	function saveData(){
		if(gridList.getModifyRowCount("gridList") == 0){
			commonUtil.msgBox("SYSTEM_SAVEEMPTY");
			return;
		}
		
		if(gridList.validationCheck("gridList", "all")){
			var list = gridList.getModifyList("gridList", "A");
			var flag;
			
			for(var i = 0; i < list.length; i++){
				if(list[i].get('ADJST_REST_QTY') == '0.000'){
					flag = true;
				}
			}
			
			if(flag == true){
				if(!commonUtil.msgConfirm('투입한 잔량이 0이면 투입한 자재를 전부 사용했음을 의미합니다.\n 처리하시겠습니까?')){
					return;
				}
			}else{
				if(!commonUtil.msgConfirm(configData.MSG_MASTER_SAVE_CONFIRM)){
					return;
				}	
			}
			
			var param = new DataMap();
			
			param.put("P_TYPE", "SAVE");
			param.put("list", list);
			
			netUtil.send({
				url : "/mes/Inv/INV04/json/datalist.data",
				param : param,
				successFunction : "savesuccessCallBack"
			});
		}
	}
	
	function savesuccessCallBack(json){
		if(json){
			if(json.P_SUCCESS == 'Y'){
				commonUtil.msgBox(configData.MSG_SYSTEM_SAVEOK);
				searchList();
			}else{
				alert(json.ERR_MSG);
				searchList();
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
		} else if(btnName == "Save"){
		 	saveData();
		} else{
			PrintLabel();
		}
	}
	
	const barcode = () => {
		var url = "/mes/wrk/WRK23_POP01.page";
		page.linkPopOpen(url, "", "height=600,width=850");
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
					<!-- <input type="button" id="button-0-3" CB="Print PRINT_OUT BTN_LABEL"/> --><!-- PRINT10 -->
					<input type="button" id="button-0-2" CB="Save SAVE BTN_SAVE" />
									
				</div>
			</div>
			<div class="search_inner">
				<div class="search_wrap ">
					<dl>
						<dt CL="STD_PLANT">플랜트</dt>
						<dd>
							<input type="text" id="WERKS" name="WERKS" UIInput="S,PLANT" UIFormat="U" validate="required"/>
						</dd>
					</dl>
					<dl>
						<dt CL="STD_MACH_CD">설비코드</dt>
						<dd>
							<!-- 2023-03-13(월요일) 안상현, 설비코드 RANGE 검색 추가 -->
							<input type="text" id="MACH_CD" name="MACH_CD" UIInput="SR,MACH" UIFormat="U" />
						</dd>
					</dl>
					<dl>
						<dt CL="STD_INP_DT">투입일자</dt>
						<dd>
							<input type="text" name="INP_DT" UIInput="B" UIFormat="C M1"/>
						</dd>
					</dl>
					<dl>
						<dt CL="STD_MATNR">자재코드</dt>
						<dd>
							<input type="text" name="MATNR" UIInput="SR,MATKY" UIFormat="U"/>
						</dd>
					</dl>	
					
<!-- 					<dl>
						<dt CL="STD_IND_BCD">개별바코드</dt>
						<dd>
							<input type="text" class="input" id="IND_BCD" name="IND_BCD" maxlength="20"/>
							<button type="button" class="btn btn_search" onclick="barcode()">
								<span>search</span>
							</button>
						</dd>
					</dl> -->
					
					<dl>
						<dt CL="STD_IND_BCD">개별바코드</dt>
						<dd>
							<input type="text" class="input" id="IND_BCD" name="IND_BCD" maxlength="20" UIInput="SR,INDBCD" UIFormat="U"/>
					
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
					<li><a href="#tab1-1"><span>투입자재정보</span></a></li>
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
										<td GH="100" GCol="text,WERKS" style="text-align:center;">플랜트</td>		
										<td GH="100" GCol="text,MACH_CD" style="text-align:center;">설비코드</td>			
										<td GH="160" GCol="text,MACH_NM">설비명</td>			
										<td GH="140" GCol="text,MATNR" style="text-align:center;">자재코드</td>									
										<td GH="320" GCol="text,MATNR_NM">자재명</td>											
										<td GH="120" GCol="text,IND_BCD">개별바코드</td>		
										<td GH="0" GCol="text,SEQNO" style="text-align:right;">순번</td>			
										<td GH="100" GCol="text,INP_DT" GF="D" style="text-align:center;">투입일자</td>		
										<td GH="100" GCol="text,INP_QTY" GF="N 13,3">투입량</td>
										<td GH="100" GCol="input,ADJST_REST_QTY" GF="N 5,3">잔량조정량</td>
										<td GH="100" GCol="text,REST_QTY" GF="N 13,3">잔량</td>
										<td GH="100" GCol="text,UNIT">단위</td>							
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
						<jsp:param value="1,2,3,7,9,10" name="showAuthCd"/>
					</jsp:include>
				</div>				
			</div>
			
			<div class="content_layout tabs bottom_layout">
				<ul class="tab tab_style02">
					<li><a href="#tab2-1"><span>투입자재사용이력</span></a></li>
					<li class="btn_zoom_wrap">
						<ul>
							<li><button class="btn btn_bigger"><span>확대</span></button></li>
						</ul>
					</li>
				</ul>
				<div class="table_box section" id="tab2-1">
					<div class="table_list01">
						<div class="scroll">
							<table class="table_b">
								<tbody id="gridList2">
									<tr CGRow="true">
										<td GH="40" GCol="rownum">1</td>	
										<td GH="100" GCol="text,WERKS" style="text-align:center;">플랜트</td>
										<td GH="100" GCol="text,INP_DT" GF="D" style="text-align:center;">투입일자</td>
										<td GH="100" GCol="text,INP_NM">투입자명</td>		
										<td GH="100" GCol="text,MACH_CD" style="text-align:center;">설비코드</td>			
										<td GH="160" GCol="text,MACH_NM">설비명</td>			
										<td GH="140" GCol="text,MATNR" style="text-align:center;">자재코드</td>									
										<td GH="320" GCol="text,MATNR_NM">자재명</td>
										<td GH="120" GCol="text,IND_BCD">개별바코드</td>
										<td GH="140" GCol="text,IN_MATNR" style="text-align:center;">투입자재코드</td>									
										<td GH="320" GCol="text,IN_MATNR_NM">투입자재명</td>												
										<td GH="120" GCol="text,INP_IND_BCD">투입 개별바코드</td>		
										<td GH="0" GCol="text,SEQNO" style="text-align:right;">순번</td>
										<td GH="100" GCol="text,USE_QTY" GF="N 13,3">사용량</td>
										<td GH="100" GCol="text,UNIT">단위</td>
										<td GH="0" GCol="text,USE_DIV">구분</td>
										<td GH="100" GCol="text,USE_DIV_NM">자재사용량 보정</td>							
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
						<jsp:param value="2" name="authCd"/>
						<jsp:param value="1,2,3,7,9,10" name="showAuthCd"/>
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