<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>MES</title>
<%@ include file="/common/include/webdek/head.jsp"%>
<link rel="stylesheet" type="text/css"
	href="/common/theme/webdek/css/demo_layout.css">
<script type="text/javascript">
	var rownum = 0;
	var data;
     $(document).ready(function(){
         gridList.setGrid({
             id : "gridList",
             url : "/mes/Work/WRK45/json/datalist.data",
             bigdata : false,
 	    	colHoldType : true,
 	    	colHold : "BARCODE_NO,RCVGDS_DT,LIFT_DT,BCD,LOT_NO",
 	    	colorType : true
         });
         
         $("#button-0-5").hide();
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
     
     function gridListEventRowDblclick(gridId, rowNum, colName){
     	var barcode_no = gridList.getColData(gridId, rowNum, "BARCODE_NO");
     	var param = new DataMap();
     	
     	param.put("BARCODE_NO", barcode_no);
     	
     	netUtil.send({
     		//url : "/mes/Work/WRK45/json/datalist.data",
     		//bigdata : false,
     		module : "Work",
     		command : "WRK45_LIST",
     		bindId : "tab1-1",
     		bindType : "field",
     		sendType : "map",
     		param : param
     	});
     }
     
     function gridListRowBgColorChange(gridId, rowNum){
 		if(gridId == "gridList"){
 			
 			var docno = gridList.getColData("gridList", rowNum, "DOC_NO");
 			var sdocno = gridList.getColData("gridList", rowNum, "SDOC_SEQNO");
 			var cdocno = gridList.getColData("gridList", rowNum, "CDOC_NO");
 			
 			if(docno.trim() != "" && sdocno.trim() == ""){
 				return configData.GRID_COLOR_BG_ORANGE_CLASS;
 			}
 			if(cdocno.trim() != "" && sdocno.trim() == ""){
 				return configData.GRID_COLOR_BG_YELLOW_CLASS;
 			}
 		}
 	 }
     
     function liftOut(){
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
     		var rowData = gridList.getRowData("gridList", gridList.getFocusRowNum("gridList"));
     		
     		var list = gridList.getSelectData('gridList');
     		
     		if(list.length > 1)	return alert('하나의 바코드만을 선택할 수 있습니다.');
     		
     		data = rowData;
     		
     		if(rowData.get('STO_DOC_NO').trim() == '')	return alert('STO 문서번호가 없어서 출고를 진행할 수 없습니다. WMS에 문의바랍니다.');
     		
	      	if(rowData.get("LIFT_DT").trim() != ""){
	      		alert("이미 출고가 되었습니다.");
	      		return;
	      	}
	      	
			if(!commonUtil.msgConfirm("출고하시겠습니까?")){
				return;
			}
	 		
			var param = new DataMap();
			
			param.put("P_TYPE", "SAVE");
			param.put("list", rowData);
			
			netUtil.send({
		    	url : "/mes/Work/WRK45/json/datalist.data",
		    	param : param,
		    	successFunction : "savesuccessCallBack"
		    });
 		}
 	}
     
    function savesuccessCallBack(json){
    	if(json){
			if(json.P_SUCCESS == "Y"){
				var param = new DataMap();
				
				param.put("IFID", "MES_IF_145");
           		param.put("DOC_NO", json.DOC_NO);
                      
                var json2 = netUtil.sendData({
              		url : "/mes/erpif/json/sendIF.data",
                   	param : param
                });
                   
                if(json2){
                   	if(json2.data == 'SUCCESS'){
                   		param.put("P_TYPE", "SAVE");
            			param.put("list", data);
                   		
                   		var json3 = netUtil.sendData({
               		    	url : "/mes/Work/WRK45_1/json/datalist.data",
               		    	param : param
               		    });
                   		
                   		if(json3){
                   			if(json3.P_SUCCESS == "Y"){
                   				alert("출고되었습니다.");
                   				searchList();
                   			}
                   		}
                   	}else{
                   		alert('(SAP 밀롤 리프트 출고) ' + json2.data);
                   		searchList();
                   	}
                }
			}else{
				alert(json.ERR_MSG);
				searchList();
			}
		}
    }
     
    function liftoutCancle(){
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
     		var rowData = gridList.getRowData("gridList", gridList.getFocusRowNum("gridList"));
         	
     		data = rowData;
     		
	      	if(rowData.get("LIFT_DT").trim() == ""){
	      		alert("출고가 되지 않았습니다.");
	      		return;
	      	} else if(rowData.get("CNL_RMK").trim() == ""){
	      		alert("출고 취소사유를 입력하시기 바랍니다.");
	      		return;
	      	}
      	
			if(!commonUtil.msgConfirm("출고취소하시겠습니까?")){
				return;
			}
 		
 			var param = new DataMap();
 			
 			param.put("P_TYPE", "SUB_SAVE");
 			param.put("list", rowData);
 			
 			netUtil.send({
 		    	url : "/mes/Work/WRK45/json/datalist.data",
 		    	param : param,
 		    	successFunction : "savesuccessCallBack2"
 		    });
 		}
 	}
     
    function savesuccessCallBack2(json){
     	if(json){
			if(json.P_SUCCESS == "Y"){
				var param  = new DataMap();
		
				param.put("IFID", "MES_IF_145");
           		param.put("DOC_NO", json.DOC_NO);
                    
                var json2 = netUtil.sendData({
               		url : "/mes/erpif/json/sendIF.data",
                 	param : param
                });
                 
                if(json2){
                 	if(json2.data == 'SUCCESS'){
                 		param.put("P_TYPE", "SUB_SAVE");
             			param.put("list", data);
                 		
                 		var json3 = netUtil.sendData({
             		    	url : "/mes/Work/WRK45_1/json/datalist.data",
             		    	param : param
             		    });
                 		
                 		if(json3){
                 			if(json3.P_SUCCESS == "Y"){
                 				alert("출고취소되었습니다.");
                 				searchList();
                 			}else{
                 				alert(json.ERR_MSG);
                 				searchList();
                 			}
                 		}
                 	}else{
                 		alert('(SAP 밀롤 리프트 출고 취소) ' + json2.data);
                 		searchList();
                 	}
                }
			}else{
				alert(json.ERR_MSG);
				searchList();
			}
		}
    }
     
    function gridListEventRowCheck(gridId, rowNum, checkType){
    	if(gridId == "gridList"){
     		if(checkType == true){
     			var docno = gridList.getColData("gridList", rowNum, "DOC_NO");
     			var sdocno = gridList.getColData("gridList", rowNum, "SDOC_SEQNO");
     			var cdocno = gridList.getColData('gridList', rowNum, 'CDOC_NO');
     			
     			if(docno.trim() != "" && sdocno.trim() == ""){
     				$("#button-0-5").show();
     			}
     			if(sdocno.trim() == '' && cdocno.trim() == '')	$('#button-0-5').show();
     			rownum = rowNum;
     		}else{
     			$("#button-0-5").hide();
     		}
   		}
    }
     
    //재전송
    function ReSend(){
    	var json = netUtil.sendData({
    		module : 'mes',
    		command : 'SYSTEMCHECK',
    		sendType : 'map'
    	});
    	
    	if(json.data.USE_YN == 'Y'){
    		alert('시스템 점검 중입니다. 1 ~ 5분 동안 잠시만 기다려 주세요.');
    		return;
    	}
    	
   		var docno = gridList.getColData("gridList", rownum, "DOC_NO");
   		var cdocno = gridList.getColData('gridList', rownum, 'CDOC_NO');
     	var list = gridList.getSelectData('gridList');
     	
     	if(list.length > 1)	return alert('하나의 바코드만을 재전송 처리할 수 있습니다.');
   		
   		var param = new DataMap();
     	
     	param.put("IFID", "MES_IF_145");
     	
     	if(docno.trim() != ""){
     		param.put("DOC_NO", docno);
     	}
     	if(cdocno.trim() != '')	param.put('DOC_NO', cdocno);
            
        netUtil.send({
   			url : "/mes/erpif/json/sendIF.data",
         	param : param,
         	successFunction : "savesuccessCallBack3"
        });
    }
     
    function savesuccessCallBack3(json){
     	if(json){
     		if(json.data == "SUCCESS"){
     			alert("재전송 성공!");
     		}else{
     			alert('(SAP 밀롤 리프트 출고 재전송) ' + json.data);
     		}
   		}
     	searchList();
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
        } else if (btnName == "Liftout") {
			//출고
			liftOut();
		} else if (btnName == "LiftoutCancle") {
			//출고취소
			liftoutCancle();
		} else {
			//재전송
			ReSend();
		}
    }
</script>
</head>
<body>
	<%@ include file="/common/include/webdek/layout.jsp"%>
	<!-- content -->
	<div class="content_wrap">
		<div class="content_inner">
			<%@ include file="/common/include/webdek/title.jsp"%>
			<div class="content_serch" id="searchArea">
				<div class="btn_wrap">
					<div class="fl_l"></div>
					<div class="fl_r">
						<input type="button" id="button-0-1" CB="Search SEARCH BTN_SEARCH" />
					</div>
				</div>
				<div class="search_inner">
					<div class="search_wrap ">
						<dl>
							<dt>전기일</dt>
							<dd>
								<input type="text" name="RCVGDS_DT" UIInput="B" UIFormat="C M1" />
							</dd>
						</dl>
						<dl>
							<dt>작업대상 바코드</dt>
							<dd>
								<input type="text" class="input" id="BARCODE_NO" name="BARCODE_NO" UIInput="SR" UIFormat="U"/>
							</dd>
						</dl>
					</div>
					<div class="btn_tab">
						<input type="button" class="btn_more" value="more" onclick="searchMore()" />
					</div>
				</div>
			</div>
			<div class="search_next_wrap">
				<div class="content_layout tabs top_layout" style="height: 30%;">
					<ul class="tab tab_style02">
						<li><a href="#tab1-1"><span CL="STD_GRD_WRK45_1">리스트</span></a></li>
						<li class="btn_zoom_wrap">
							<ul>
								<li><button class="btn btn_bigger"><span>확대</span></button></li>
							</ul>
						</li>
					</ul>
					<div class="table_box" id="tab1-1">
						<div class="inner_search_wrap">
							<table class="detail_table" id="detail">
								<colgroup>
									<col width="6%" />
									<col width="7%" />
									<col width="6%" />
									<col width="7%" />
									<col width="6%" />
									<col width="7%" />
									<col width="6%" />
									<col width="7%" />
									<col width="6%" />
									<col width="7%" />
								</colgroup>
								<tbody>
									<tr>
										<th>업체바코드</th>
										<td><input type="text" class="input" name="BARCODE_NO"
											readonly="readonly" style="width: 100%;" /></td>
										<th>LOT(배치번호)</th>
										<td><input type="text" class="input" name="LOT_NO"
											readonly="readonly" style="width: 100%;" /></td>
										<th CL="STD_BCD">바코드</th>
										<td><input type="text" class="input" name="BCD"
											readonly="readonly" style="width: 100%;" /></td>
										<th>전기일</th>
										<td><input type="text" class="input" name="RCVGDS_DT"
											UIFormat="D" readonly="readonly" style="width: 100%;" /></td>
										<th>컨테이너</th>
										<td><input type="text" class="input" name="CON_NO"
											readonly="readonly" style="width: 100%;" /></td>
									</tr>
									<tr>
										<th>공급업체</th>
										<td><input type="text" class="input" name="SUPY_CD"
											readonly="readonly" style="width: 100%;" /></td>
										<th>공급업체명</th>
										<td colspan="3"><input type="text" class="input"
											name="SUPY_NM" readonly="readonly" style="width: 100%;" /></td>
										<th>업체지종</th>
										<td colspan="3"><input type="text" class="input"
											name="PCODE_SUPPY" readonly="readonly" style="width: 70%;" />
										</td>
									</tr>
									<tr>
										<th>Roll No</th>
										<td><input type="text" class="input" name="ROLL_NO"
											readonly="readonly" style="width: 100%;" /></td>
										<th>SAP자재번호</th>
										<td colspan="3"><input type="text" class="input"
											name="MATNR" readonly="readonly" style="width: 100%;" /></td>
										<th>SAP지종코드</th>
										<td><input type="text" class="input" name="PCODE"
											readonly="readonly" style="width: 100%;" /></td>
										<th>SAP지종명</th>
										<td><input type="text" class="input" name="PCODE_NM"
											readonly="readonly" style="width: 100%;" /></td>
									</tr>
									<tr>
										<th>평량</th>
										<td><input type="text" class="input" name="BS_WGT"
											UIFormat="N 13,3" readonly="readonly" style="width: 100%;" />
										</td>
										<th>MR지폭</th>
										<td><input type="text" class="input" name="MWIDTH"
											UIFormat="N 13,3" readonly="readonly" style="width: 100%;" />
										</td>
										<th>MR권치수</th>
										<td><input type="text" class="input" name="MROLLCNT"
											UIFormat="N 13,3" readonly="readonly" style="width: 100%;" />
										</td>
										<th>환산중량</th>
										<td><input type="text" class="input" name="MBRGEW"
											UIFormat="N 13,3" readonly="readonly" style="width: 100%;" />
										</td>
										<th>지관인치</th>
										<td><input type="text" class="input" name="CORE"
											UIFormat="N 13,3" readonly="readonly" style="width: 100%;" />
										</td>
									</tr>
								</tbody>
							</table>
						</div>
					</div>
				</div>

				<div class="btn_wrap">
					<div class="fl_l">
						<input type="button" id="button-0-3" CB="Liftout SAVE BTN_LIFTOUT" />
						<input type="button" id="button-0-4" CB="LiftoutCancle CANCEL BTN_LIFTOUTCANCLE" /> 
						<input type="button" id="button-0-5" CB="ReSend APPLY 재전송" />
					</div>
					<div class="fl_r"></div>
				</div>

				<div class="content_layout tabs bottom_layout" style="height: 63%;">
					<ul class="tab tab_style02">
						<li><a href="#tab2-1"><span CL="STD_GRD_WRK45_2">출고</span></a></li>
						<li class="btn_zoom_wrap">
							<ul>
								<li><button class="btn btn_bigger">
										<span>확대</span>
									</button></li>
							</ul>
						</li>
					</ul>
					<div class="table_box section" id="tab2-1">
						<div class="table_list01">
							<div class="scroll">
								<table class="table_c">
									<tbody id="gridList">
										<tr CGRow="true">
											<td GH="40" GCol="rownum">1</td>
											<td GH="40" GCol="rowCheck"></td>
											<td GH="100" GCol="text,BARCODE_NO">업체바코드</td>
											<td GH="100" GCol="text,RCVGDS_DT" style="text-align: center;" GF="D">입고일자</td>
											<td GH="100" GCol="text,LIFT_DT" style="text-align: center;" GF="D">출고일자</td>
											<td GH="100" GCol="text,BCD" style="text-align: center;">바코드</td>
											<td GH="100" GCol="text,LOT_NO" style="text-align: center;">LOT NO</td>
											<td GH="140" GCol="text,MATNR" style="text-align: center;">자재코드</td>
											<td GH="100" GCol="text,SUPY_CD" style="text-align: center;">공급업체코드</td>
											<td GH="100" GCol="text,ZFBLNO">B/L관리번호</td>
											<td GH="100" GCol="text,CON_NO">컨테이너 NO</td>
											<td GH="100" GCol="text,ROLL_NO">ROLL ID</td>
											<td GH="100" GCol="text,PCODE" style="text-align: center;">지종</td>
											<td GH="100" GCol="text,MWIDTH" GF="N 13,3">MR지폭</td>
											<td GH="100" GCol="text,MROLLCNT" GF="N 13,3">MR권치수</td>
											<td GH="100" GCol="text,UNIT_L" style="text-align: center;">길이단위</td>
											<td GH="100" GCol="text,NET_WGT" GF="N 13,3">NET중량</td>
											<td GH="100" GCol="text,WGT_MUL" GF="N 13,3">중량배수</td>
											<td GH="100" GCol="text,CORE" GF="N 20,3">지관</td>
											<td GH="150" GCol="text,PCODE_SUPPY" style="text-align: center;">고객 지종</td>
											<td GH="100" GCol="text,BS_WGT" GF="N 13,3">평량</td>
											<td GH="100" GCol="text,MBRGEW" GF="N 13,3">MR중량</td>
											<td GH="100" GCol="text,UNIT" style="text-align: center;">단위</td>
											<td GH="100" GCol="text,STO_DOC_NO">STO문서번호</td>
											<td GH="100" GCol="text,WRK_STA" style="text-align: center;">작업상태</td>
											<td GH="500" GCol="input,CNL_RMK" GF="S 1000">취소사유</td>
											<td GH="100" GCol="text,RMK_1">비고</td>
											<td GH="100" GCol="text,RMK_2"></td>
											<td GH="100" GCol="text,RMK_3"></td>
											<td GH="100" GCol="text,RMK_4"></td>
											<td GH="100" GCol="text,RMK_5"></td>
											<td GH="100" GCol="text,WRK_CLASS" style="text-align: center;">작업반</td>
											<td GH="100" GCol="text,WRK_SHIFT" style="text-align: center;">작업조</td>
											<td GH="0" GCol="text,DOC_NO">MES문서번호</td>
											<td GH="0" GCol="text,DOC_SEQNO">MES문서번호 순번</td>
											<td GH="0" GCol="text,SDOC_NO">SAP문서번호</td>
											<td GH="0" GCol="text,SDOC_SEQNO">SAP문서번호 순번</td>
											<td GH="0" GCol="text,CDOC_NO">취소문서번호</td>
											<td GH="0" GCol="text,CDOC_SEQNO">취소문서번호 순번</td>
											<td GH="140" GCol="text,REGDATE" style="text-align: center;"></td>
											<td GH="140" GCol="text,UPDDATE" style="text-align: center;"></td>
											<td GH="100" GCol="text,UPDNM"></td>
										</tr>
									</tbody>
								</table>
							</div>
						</div>
						<jsp:include page="/WEB-INF/jsp/common/commonBtnAuth.jsp">
							<jsp:param name="authCd" value="2" />
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