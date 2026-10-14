<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>공정창고 조회</title>
<%@ include file="/common/include/webdek/head.jsp"%>
<script type="text/javascript">
	
	window.resizeTo("1000","900");
	
	var lotnoM;
	var machCd;
	var wrkordrno;
	var wrkordrseqno;
	
	$(document).ready(function(){
		configData.MENU_ID = "WRK10_POP01"; 
		
		var data = page.getLinkPopData();
		
		lotnoM = data.get('LOT_NO_M');
		machCd = data.get('MACH_CD');
		wrkordrno = data.get('WRK_ORDR_NO');
		wrkordrseqno = data.get('WRK_ORDR_SEQNO');
		
		$('#LOT_NO_M').val(lotnoM);
		
		gridList.setGrid({
	    	id : "gridList",
			url : "/mes/Work/WRK10/json/datalist.data",
			bigdata : false
	    });
		
		searchList();
	});
	
	function searchList(){
		var param = new DataMap();
		
		param.put("P_TYPE", "LIST_POP");
		param.put('LOT_NO_M', lotnoM);
		param.put('WRK_ORDR_NO', wrkordrno);
		param.put('WRK_ORDR_SEQNO', wrkordrseqno);
		
		gridList.gridList({
			id : "gridList",
			param : param
		});
	}
	
	function gridListEventColValueChange(gridId, rowNum, colName, colValue){
		if(gridId == 'gridList'){
			if(colName == 'SCRAP_QTY'){
				var prfmqty = gridList.getColData(gridId, rowNum, 'PRFM_QTY');
				if(Number(prfmqty) < Number(colValue)){
					gridList.setColValue(gridId, rowNum, "SCRAP_QTY", 0.000);
					gridList.setRowCheck(gridId, rowNum, false);
					gridList.setRowState(gridId, configData.GRID_ROW_STATE_READ, rowNum);
					gridList.reloadAll(gridId);
					return alert('실적량보다 폐품수량을 많이 입력할 수 없습니다.');
				}
			}
		}
	}
	
	//폐품량 입력
	function saveData(){
		if(gridList.validationCheck("gridList", "all")){			
			var list = gridList.getSelectData("gridList");
			
			if(list.length == 0) return alert('폐품등록할 바코드를 선택하세요.');
			
			for(var i = 0; i < list.length; i++){
				if(Number(list[i].get('SCRAP_QTY')) == 0) return alert('폐품수량을 입력하세요.');
			}
			
			var param = new DataMap();
			
			param.put('P_TYPE', 'LIST_POP_SAVE');
			param.put('MACH_CD', machCd);
			param.put('list', list);
			param.put('WERKS', 'P200');
			param.put('LOT_NO_M', lotnoM);
			
			if(!commonUtil.msgConfirm(configData.MSG_MASTER_SAVE_CONFIRM)){
				return;
			}
			
			netUtil.send({
				url : "/mes/Work/WRK10/json/datalist.data",
				param : param,
				successFunction : "saveSuccessCallBack"
			});
		}
	}
	
	function saveSuccessCallBack(json){
		if(json.P_SUCCESS == 'Y'){
			alert('폐품이 저장되었습니다.');
			page.linkPopClose();
		}
	}
	
	function commonBtnClick(btnName){
		if(btnName == "Save"){
			saveData();
		}else{
			//닫기
			page.linkPopClose();
		}
	}
</script>
</head>
<body>
	<%@ include file="/common/include/webdek/layout.jsp"%>
	<!-- content -->
	<div class="content_wrap">
		<div class="content_inner_pop">
			<%@ include file="/common/include/webdek/title.jsp"%>
			<div class="content_serch" id="searchArea">
				<div class="btn_wrap">
					<div class="fl_l">
					</div>
					<div class="fl_r">		
						<input type="button" id="button-0-2" CB="Save SAVE BTN_CONFIRM" />
						<input type='button' id='button-0-3' CB='Close DELETE BTN_CLOSE'/>
					</div>
				</div>
				<div class="search_inner">
					<div class="search_wrap">
						<dl style='text-align:center;'>
							<dt CL="STD_LOT_NO_M">투입LOT번호</dt>
							<dd>
								<input type="text" class="input" id="LOT_NO_M" readonly="readonly" />
							</dd>
						</dl>
					</div>
					<div class="btn_tab">
						<input type="button" class="btn_more" value="more" onclick="searchMore()" />
					</div>
				</div>
			</div>
			<div class="search_next_wrap" style="height: 94%;">
				<div class="content_layout tabs">
					<ul class="tab tab_style02">
						<li><a href="#tab1-1"><span>투입 자재 사용량 조회</span></a></li>
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
											<td GH="120" GCol="text,IND_BCD_M" style="text-align: center;"></td>	<!-- 투입개별바코드 -->
											<td GH="100" GCol="text,PRFM_QTY" GF='N 10,3'></td>						<!-- 생산량 -->
											<td GH="100" GCol="text,USE_QTY" GF="N 5,3"></td>						<!-- 사용량 -->
											<td GH="100" GCol="text,REST_QTY" GF="N 5,3"></td>						<!-- 잔량 -->
											<td GH="100" GCol="input,SCRAP_QTY" GF="N 10,3"></td>					<!-- 폐품수량 -->
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
	<%@ include file="/common/include/webdek/bottom.jsp"%>
</body>
</html>