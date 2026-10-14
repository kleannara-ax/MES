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
	var werks;
	
	$(document).ready(function(){
		gridList.setGrid({
	    	id : "gridList",
			url : "/mes/Quality/QLT16/json/datalist.data",
			bigdata : false
	    });
	});

	function searchList(){
		if(validate.check("searchArea")){
			/* var range = inputList.setRangeParam("searchArea");
			var range_data_param = range.get("RANGE_DATA_PARAM");
			var msrm_date = range_data_param.get("MSRM_DATE_Range");
			var date = msrm_date.split('↓');
			var SDate = parse(date[1]);
			var EDate = parse(date[2]);
			
			var matnr = range_data_param.get("MATNR_Single");
			var matnr_str = matnr == undefined ? '' : matnr.split('↓');
			var Matnr = "";
			
			for(var i = 0; i < matnr_str.length; i++){
				if(matnr_str[i].indexOf('E') == 0 || matnr_str[i].indexOf('OR') == 0){
					continue;
				}
				if(matnr_str[i].includes('%')){
					Matnr = Matnr + '^' + matnr_str[i].slice(0,-1) + '|';
				}else{
					Matnr = Matnr + '^' + matnr_str[i] + '|';	
				}
			} */
			
			var param = inputList.setRangeParam("searchArea");
			
			param.put("P_TYPE", "LIST");
			/* param.put("WERKS", range.get('WERKS'));
			param.put("SDATE", SDate);
			param.put("EDATE", EDate);
			param.put("MATNR", Matnr.slice(0, -1)); */
			
			gridList.gridList({
		    	id : "gridList",
		    	param : param
		    });
			
			werks = param.get('WERKS');
		}
	}

	/* function parse(str){
		var y = str.substr(0, 4);
		var m = str.substr(4, 2);
		var d = str.substr(6, 2);
		var h = "00";
		var mm = "00";
		var s = "00";
		
		return y + '-' + m + '-' + d + ' ' + h + ':' + mm + ':' + s;
	} */
	
	// 2022-09-28(수요일) 안상현, 품질팀 요청사항으로 인하여, 품질 재검사에 품질처리방법 추가
	function gridListEventDataBindEnd(gridId, dataLength){
		if(gridId == "gridList"){
			var list = gridList.getGridData(gridId);
			
			for(var i = 0; i < dataLength; i++){
				var upddate = list[i].get("UPDDATE");
				
				if(upddate != ""){
					gridList.setRowReadOnly(gridId, i, true, ["MEDIAT_AMT","PRC_QC_MTD"]);
				}
			}
		}
	}
	
	function saveData() {
		var json = netUtil.sendData({
    		module : 'mes',
    		command : 'SYSTEMCHECK',
    		sendType : 'map'
    	});
    	
    	if(json.data.USE_YN == 'Y'){
    		alert('시스템 점검 중입니다. 1 ~ 5분 동안 잠시만 기다려 주세요.');
    		return;
    	}
		// VALIDATION
		const data = gridList.getSelectData("gridList")
		
		if(data.length == 0){
			commonUtil.msgBox('OUT_M0103');
			return;
		}
		
		var message = '';
		
		for(let i = 0; i < data.length; i++){
			if(data[i].get('IND_BCD').trim() == ''){
				alert('바코드 정보가 없습니다.');
				return;
			}
			var param = new DataMap();
			
			param.put('WERKS', data[i].get('WERKS'));
			param.put('MATNR', data[i].get('MATNR'));
			param.put('IND_BCD', data[i].get('IND_BCD'));
			console.log("## saveData("+ i +") > param = ", param);
			console.log(" ");

			// var json = netUtil.sendData({
			// 	module : 'Quality',
			// 	command : 'INV01_UCFMTYFLG',
			// 	sendType : 'count',
			// 	param : param
			// });
			
			// if(json.data == 1){
			// 	alert('선택한 것 중' + (i + 1) + '번째 항목은 이미 부분폐품 처리가 되어서 적합처리를 할 수 없습니다.');
			// 	return;
			// }
		}
		
		if(!commonUtil.msgConfirm(configData.MSG_MASTER_SAVE_CONFIRM)){
			return;
		}
		
		if(!commonUtil.msgConfirm('조정을 하면 다시 수정할 수 없습니다.\n 계속 진행하시겠습니까?')){
			return;
		}
		
		if(gridList.validationCheck("gridList", "all")){
			var list = gridList.getSelectData("gridList");
			
			var param = new DataMap();
			
			param.put("P_TYPE", "SAVE");
			param.put("list", list);
			
			netUtil.send({
				url : "/mes/Quality/QLT16/json/datalist.data",
				param : param,
				successFunction : "saveSuccessCallBack"
			});
		}
	}
	
	function saveSuccessCallBack(json){
		if(json.P_SUCCESS == 'Y'){
			if(werks == 'P100' || werks == 'P200'){
				if(json.DOC_NO != ''){
					var param = new DataMap();
					//SAP 재고이전
		        	param.put("IFID", "MES_IF_131");
			        param.put("DOC_NO", json.DOC_NO);
			        
			        var json = netUtil.sendData({
			        	url : "/mes/erpif/json/sendIF.data",
			        	param : param
			        });
			        
			        if(json.data != 'SUCCESS'){
			        	searchList();
			        	return alert('SAP(재고이전)' + json.data);
			        }
				}
			}
			commonUtil.msgBox(configData.MSG_SYSTEM_SAVEOK);
			searchList();
		}else{
			alert(json.ERR_MSG);
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
	  
	// 그리드 컬럼 값 변경 시 호출
	function gridListEventColValueChange(gridId, rowNum, colName, colValue){
		  
		if(colName === "MEDIAT_AMT"){
			// MEDIAT_AMT : 조정량(합격량)
			// UCFMTY_AMT : 부적합량
			if(Number(colValue) > Number(gridList.getColData(gridId, rowNum, "UCFMTY_AMT"))){
				alert("조정량(합격량)이 부적합량보다 큽니다.")
				gridList.setRowState(gridId, configData.GRID_ROW_STATE_READ, rowNum)
     			gridList.setRowCheck(gridId, rowNum, false)
     			gridList.setColValue(gridId, rowNum, "MEDIAT_AMT", gridList.getColData(gridId, rowNum, "UCFMTY_AMT"))
     			gridList.reloadAll(gridId);
				return
			 }
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
					<input type="button" id="button-0-2" CB="Save SAVE BTN_SAVE"/>
				</div>
			</div>
			<div class="search_inner">
				<div class="search_wrap ">
				  	<dl>
						<dt CL="STD_PLANT">플랜트</dt>
						<dd>
							<input type="text" class="input" id="WERKS" name="WERKS" validate="required" UIInput="S,PLANT" UIFormat="U"/>
						</dd>
					</dl>
					<dl>
						<dt CL="STD_MSRM_DATE">판정일자</dt>
						<dd>
							<input type="text" name="MSRM_DATE" UIInput="B" UIFormat="C M1"/>
						</dd>
					</dl>
					<dl>
						<dt CL="STD_MATNR">자재코드</dt>
						<dd>
							<input type="text" name="MATNR" UIInput="SR,MATKY" UIFormat="U"/>
						</dd>
					</dl>
					<dl>
                        <dt CL="STD_INSP_YN">검사여부</dt>
                        <dd>
                            <select class="input" name="INSP_YN">
                            	<option value="">All</option>
                            	<option value="Y">Y</option>
                            	<option value="N">N</option>
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
					<li><a href="#tab1-1"><span CL="STD_GRD_QLT16">리스트</span></a></li>
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
										<td GH="40" GCol="rownum"></td>
										<td GH="40" GCol="rowCheck"></td>
										<td GH="100" GCol="text,WERKS" style="text-align:center;">플랜트</td>
										<td GH="0" GCol="text,INSP_ITEM_GRP_CD">검사그룹항목코드</td>
										<td GH="140" GCol="text,MSRM_DATE" style="text-align:center;">판정일시</td>
										<td GH="140" GCol="text,MATNR" style="text-align:center;">자재코드</td>
										<td GH="0" GCol="text,MATNR_DIV">자재구분</td>
										<td GH="320" GCol="text,MATNR_NM">자재명</td>
										<td GH="0" GCol="text,PRC_SEQNO">처리순번</td>
										<td GH="100" GCol="text,LOT_NO" style="text-align:center;">LOT번호</td>
										<td GH="120" GCol="text,IND_BCD" style="text-align:center;">개별바코드</td>
										<td GH="0" GCol="text,VND_LOT_NO" style="text-align:center;">공급업체LOT번호</td>
										<td GH="0" GCol="text,SUPY_VND_BCD" style="text-align:center;">공급업체바코드</td>
										<td GH="100" GCol="text,UNIT" style="text-align:center;">단위</td>
										<td GH="100" GCol="text,UNIT_NM">단위(명)</td>
										<td GH='100' GCol='text,STCK_QTY' GF='N 13,3'>재고량</td>
										<td GH="100" GCol="text,UCFMTY_AMT" GF="N 10,3">부적합량</td>
										<!-- 2022-09-28(수요일) 안상현, 품질팀 요청사항으로 인하여, 품질 재검사에 품질처리방법 추가 -->
										<td GH="110" GCol="select,PRC_QC_MTD">
											<select CommonCombo="PRC_MTD"><!-- 품질처리방법 -->
												<option value=""></option>
											</select>
										</td>
										<td GH="100" GCol="input,MEDIAT_AMT" GF="N 10,3">조정량(합격량)</td>
										<td GH="0" GCol="text,DEPT_CD" style="text-align:center;">부서코드</td>
										<td GH="0" GCol="text,PRC_MTD" style="text-align:center;">처리방법</td>
										<td GH="100" GCol="text,PRC_MTD_NM">처리방법(명)</td>
										<td GH="0" GCol="select,FNL_JDGM">
											<select CommonCombo="FNL_JDGM"><!-- 판정 -->
												<option value=""></option>
											</select>
										</td>
										<td GH="100" GCol="text,RMK" GF="S 20">비고</td>
										<td GH="0" GCol="text,STOR_LOC_CD" style="text-align:center;">저장위치코드
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
						<jsp:param value="1" name="authCd"/>
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