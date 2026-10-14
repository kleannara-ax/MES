<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>공정창고 조회</title>
<%@ include file="/common/include/webdek/head.jsp"%>
<script type="text/javascript">
	var werks;
	var matnr;
	var matnr_nm;
	var prdDt;
	var prdDtfm;
	
	window.resizeTo("1700","900");
	
	$(document).ready(function(){
		configData.MENU_ID = "QLT06_POP01"; 
		
		var data = page.getLinkPopData();
		dataBind.dataNameBind(data[0], "searchArea");
		
		werks = data[0].get("WERKS");
		matnr = data[0].get("MATNR");
		matnr_nm = data[0].get("MATNR_NM");
		//prdDt = data[0].get("PRD_DT");
		
		//prdDtfm = prdDt==undefined ? "" : prdDt.replace(/(\d{4})(\d{2})(\d{2})/, '$1-$2-$3');
		
		$("#WERKS").val(werks);
		$("#MATNR").val(matnr);
		$("#MATNR_NM").val(matnr_nm);
		//$("#PRD_DT").val(prdDtfm);
		
		gridList.setGrid({
	    	id : "gridList",
			url : "/mes/Quality/QLT06_POP01/json/datalist.data",
			bigdata : false,
			colHoldType : true,
			colHold : "WERKS, STOR_LOC_CD, STOR_LOC_NM, IND_BCD, MATNR, MATNR_NM"
	    });
		
		searchList();
	});
	
	function searchList(){
		if(validate.check("searchArea")){
			var param = inputList.setRangeParam("searchArea");
			
			param.put("P_TYPE", "LIST");
			param.put("WERKS", werks);
			param.put("MATNR", matnr);
			
			gridList.gridList({
				id : "gridList",
				param : param
			});
		}
	}
	
	function saveData(){
		var json = netUtil.sendData({
    		module : 'mes',
    		command : 'SYSTEMCHECK',
    		sendType : 'map'
    	});
    	
    	if(json.data.USE_YN == 'Y'){
    		alert('시스템 점검 중입니다. 1 ~ 5분 동안 잠시만 기다려 주세요.');
    		return;
    	}
		
		if(gridList.validationCheck("gridList", "all")){
			
			if($("#FNL_JDGM").val() == ""){
				alert("선택된 항목에 대해 판정값을 선택하시기 바랍니다.");
				return;
			}
			
			var list = gridList.getSelectData("gridList");
			
			if(list.length == 0){
				alert("판정할 재고를 선택하시기 바랍니다.");
				return;
			}
			
			if(!commonUtil.msgConfirm(configData.MSG_MASTER_SAVE_CONFIRM)){
				return;
			}
			
			var param = new DataMap();
			
			param.put("P_TYPE", "SAVE");
			param.put("list", list);
			param.put("FNL_JDGM", $("#FNL_JDGM").val());
			
			netUtil.send({
				url : "/mes/Quality/QLT06_POP01/json/datalist.data",
				param : param,
				successFunction : "saveSuccessCallBack"
			});
		}
	}
	
	function saveSuccessCallBack(json){
		if(json.P_SUCCESS =='Y'){
			var message = '';
			if(json.DOC_NO != ''){
				var param = new DataMap();
	            
	            var ifid = 'MES_IF_901';
	            
	            var json2 = netUtil.sendData({
	            	url : "/common/api/json/"+ifid+"/send.data",
	   				param : 'DOC_NO=' + json.DOC_NO
	            });
	            
	            if(json2.result == 'SUCCESS'){
	    		}else {
	    			message = '(WMS 품질검사결과) ' + json2.result;
	    		}
			}
			if(message == ''){
				commonUtil.msgBox(configData.MSG_SYSTEM_SAVEOK);
			}else{
				alert(message);
			}
			page.linkPopClose();
		}
    }
	
	function commonBtnClick(btnName){
		if(btnName == "Search"){
			var param = new DataMap();
	        param.put("PROGID", "<%=menuId%>");
			param.put("LGTYPE", "SEARCH");
			var json = netUtil.sendData({
				url : "/mes/system/json/saveLog.data",
				param : param
			});

			searchList();
		} else if (btnName == "Save") {
			saveData();
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
			<div class="content_serch_pop" id="searchArea">
				<div class="btn_wrap">
					<div class="fl_l"></div>
					<div class="fl_r">
						<input type="button" id="button-0-1" CB="Search SEARCH BTN_SEARCH" />
						<input type="button" id="button-0-2" CB="Save SAVE BTN_SAVE" />
					</div>
				</div>
				<div class="search_inner">
					<div class="search_wrap">
						<dl>
							<dt CL="STD_PLANT">플랜트</dt>
							<dd>
								<input type="text" class="input" id="WERKS" name="WERKS"
									readonly="readonly" />
							</dd>
						</dl>
						<dl>
							<dt CL="STD_MATNR">자재</dt>
							<dd>
								<input type="text" class="input" id="MATNR" name="MATNR"
									readonly="readonly" />
							</dd>
						</dl>
						<dl>
							<dt CL="STD_MATNR_NM">자재명</dt>
							<dd>
								<input type="text" class="input" id="MATNR_NM" name="MATNR_NM"
									readonly="readonly" style='width: 300px;' />
							</dd>
						</dl>
						<!-- <dl>
							<dt CL="STD_PRDC_DT">제조일자</dt>
							<dd>
								<input type="text" class="input" id="PRD_DT" name="PRD_DT" readonly="readonly" />
							</dd>
						</dl> -->
					</div>
					<div class="search_wrap_pop">
						<dl>
							<dt CL="STD_FNL_JDGM">최종판정</dt>
							<dd>
								<select class="input" id="FNL_JDGM" name="FNL_JDGM"
									CommonCombo="FNL_JDGM">
									<option value=""></option>
								</select>
							</dd>
						</dl>
					</div>
					<div class="btn_tab">
						<input type="button" class="btn_more" value="more"
							onclick="searchMore()" />
					</div>
				</div>
			</div>
			<div class="search_next_wrap" style="height: 86%;">
				<div class="content_layout tabs">
					<ul class="tab tab_style02">
						<li><a href="#tab1-1"><span>공정창고 재고현황</span></a></li>
						<li class="btn_zoom_wrap">
							<ul>
								<li><button class="btn btn_bigger">
										<span>확대</span>
									</button></li>
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
											<td GH="100" GCol="text,WERKS" style="text-align: center;">플랜트</td>
											<td GH="100" GCol="text,STOR_LOC_CD"
												style="text-align: center;">저장위치코드</td>
											<td GH="120" GCol="text,STOR_LOC_NM">저장위치명</td>
											<td GH="120" GCol="text,IND_BCD">개별바코드</td>
											<td GH="140" GCol="text,MATNR" style="text-align: center;">자재코드</td>
											<td GH="320" GCol="text,MATNR_NM">자재명</td>
											<td GH="0" GCol="text,LOC_CD" style="text-align: center;">로케이션코드</td>
											<td GH="100" GCol="text,LOC_NM">로케이션명</td>
											<td GH="100" GCol="text,VND_LOT_NO">공급업체 로트번호</td>
											<td GH="100" GCol="text,STCK_QTY" GF="N 13">재고수량</td>
											<td GH="0" GCol="text,UNIT">단위</td>
											<td GH="100" GCol="text,UNIT_NM">단위명</td>
											<td GH="0" GCol="text,SUPY_CD" style="text-align: center;">공급업체코드</td>
											<td GH="100" GCol="text,SUPY_NM">공급업체명</td>
											<td GH="0" GCol="text,STCK_STA" style="text-align: center;">재고상태</td>
											<td GH="100" GCol="text,STCK_STA_NM">재고상태</td>
											<td GH="0" GCol="text,FNL_JDGM">최종판정</td>
											<td GH="80" GCol="text,FNL_JDGM_NM">최종판정</td>
											<td GH="0" GCol="text,MSRM_DATE">측정일시</td>
											<td GH="0" GCol="text,INSPR_ID">검사자</td>
											<td GH="100" GCol="text,INSPR_NM">검사자</td>
											<td GH="140" GCol="text,REGDATE" style="text-align: center;">등록일시</td>
											<td GH="0" GCol="text,DOC_NO">MES 전송문서번호</td>
											<td GH="0" GCol="text,DOC_SEQNO">MES 전송문서번호순번</td>
											<td GH='0' GCol='text,WDOC_NO'>WMS문서번호</td>
											<td GH='0' GCol='text,WDOC_SEQNO'>WMS문서순번</td>
											<td GH="0" GCol="text,DLFL">삭제 지시자</td>
											<td GH='100' GCol='text,LOT_NUM'>WMSLOT번호</td>
											<td GH='100' GCol='text,RCVGDS_QTY'>입고수량</td>
											<td GH='100' GCol='text,STOR_KY'>WMS저장키</td>
											<td GH='0' GCol='text,NTN_CD'>국가코드</td>
											<td GH='0' GCol='text,CRSPD_CD'>거래처코드</td>
											<td GH='0' GCol='text,PRDC_DT'>제조일자</td>
											<td GH='0' GCol='text,RCVGDS_DT'>입고일자</td>
											<td GH='0' GCol='text,DSTBT_DDLIN'>유통기한</td>
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