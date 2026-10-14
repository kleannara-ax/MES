<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%
String plant = (String) request.getSession().getAttribute(CommonConfig.SES_USER_PLANT_KEY);
%>
<!doctype html>
<head>
<style type="text/css">
button {
	float: right;
}

input:read-only {
	background-color: #e2e2e2;
}

select:DISABLED {
	background-color: #e2e2e2;
}
</style>
<meta charset="utf-8">
<meta name="viewport"
	content="user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, width=device-width, target-densitydpi=medium-dpi" />
<meta name="format-detection" content="telephone=no" />
<title>Mobile MES</title>
<%@ include file="/mobile/include/head.jsp"%>
<script>
	$(document).ready(function(){
		if('<%=plant%>' != 'P100'){
			PlaySound('e');
   			commonUtil.msgBox("HL생활용품팀이 PDA로 변경요청을 하지 않습니다.", null, null, function(){
   				showMain()
   			});
		}
		
		$('#IND_BCD').focus();
	});
	
	//바코드 유효성 체크
	function barcodeCheck(){
		var ind_bcd = $('#IND_BCD').val();
		
		if(ind_bcd == '' | ind_bcd == undefined){
   			PlaySound('e');
   			commonUtil.msgBox('바코드를 스캔하세요', null, null, function(){
   				$('#IND_BCD').focus();
   			});
   			return false;
		}
   		
		if(ind_bcd.length > 10){
			commonUtil.msgBox('존재하지 않는 바코드이므로 다시 스캔하세요.', null, null, function(){
				$('#IND_BCD').focus(); 
			});
			return false;
		}
		
		return true;
	}
   	
   	//바코드 스캔
	function onReadBarcode(){
		if(barcodeCheck()){
			var param = new DataMap();
		 	
			param.put("P_TYPE", "LIST");
			param.put("WERKS", '<%=plant%>');
			param.put("IND_BCD", $("#IND_BCD").val());
			param.put("INP_DT", $("#INP_DT").val());
			param.put("MATNR_FROM", $("#MATNR_FROM").text());
			
			console.log($("#INP_DT").val());

			netUtil.send({
				url : "/mobile/Mobile/PDA_WRK13_LAMI/json/datalist.data",
				param : param,
				successFunction : "saveSuccessCallBack1"
			});
		}
 	}
       
	function saveSuccessCallBack1(json){
		if(json && json.data){
			var param = new DataMap();
            param.put("PROGID", "<%=menuId%>");
            param.put("LGTYPE", "SEARCH");
            var json2 = netUtil.sendData({
                url: "/mes/system/json/saveLog.data",
                param : param
            });
			
			var target1 = $('#list1');
			var target2 = $('#list2');
			var add_data = '';
     	   	var add_data2 = '';
     	   
   		   	if(json.data.length == 0){
	   			PlaySound("e");
   			   	commonUtil.msgBox(configData.MSG_MASTER_ROWEMPTY, null, null, function(){
	   			   	$("#IND_BCD").focus();
	 			   
	   			 	add_data2 += '<tr><th class="fl">실적상태</th></tr>';
	   			   	
					add_data += '<tr><th class="fl">바코드</th></tr>';
					add_data += '<tr><th class="fl">변경전 자재코드</th></tr>';
					add_data += '<tr><th class="fl">변경전 자재명</th></tr>';
					add_data += '<tr><th class="fl">지종</th></tr>';          			        			
					add_data += '<tr><th class="fl">평량</th></tr>';          			 
					add_data += '<tr><th class="fl">규격</th></tr>';          			
					add_data += '<tr><th class="fl">중량</th></tr>';
// 					add_data += '<tr><td><br></td></tr>';
					add_data += '<tr><th class="fl">변경후 자재코드</th></tr>';          			
					add_data += '<tr><th class="fl">변경후 자재명</th></tr>';          		
					
					target1.html(add_data);
	  	       	   	target2.html(add_data2);
   			   	});
			} else if(json.data.length == 1){
				PlaySound("s");
    		 	
				var value = json.data;
 	     	    
				$.each(value, function (index, item){
					add_data2 += '<tr><th class="fl">실적상태</th>'; 
 	       		   	add_data2 += '<td class="fl">' + item.PRD_STA + '</td></tr>';
					
					add_data += '<tr><th class="fl">바코드</th>';
					add_data += '<td class="fl">' + item.IND_BCD + '</td></tr>';
					add_data += '<tr><th class="fl">변경전 자재코드</th>';
 	       		   	add_data += '<td class="fl" id ="MATNR_FROM">' + item.MATNR_FROM + '</td></tr>';
 	       			add_data += '<tr><th class="fl">변경전 자재명</th>';
 	       		   	add_data += '<td class="fl">' + item.MATNR_NM_FROM + '</td></tr>';
 	       		   	add_data += '<tr><th class="fl">지종</th>';          			
 	       		   	add_data += '<td class="fl">' + item.PCODE_NM + '</td></tr>';          			
 	       		   	add_data += '<tr><th class="fl">평량</th>';          			
 	       		   	add_data += '<td class="fl">' + item.BS_WGT + '</td></tr>'; 
	       		   	add_data += '<tr><th class="fl">규격</th>';          			
 		   	   	   	add_data += '<td class="fl">' + item.MATNR_SPEC + '</td></tr>';
	       		   	add_data += '<tr><th class="fl">중량</th>';          			
	       		   	add_data += '<td class="fl">' + item.WGT + '</td></tr>';
// 	       			add_data += '<tr><td><br></td></tr>';
					add_data += '<tr><th class="fl">변경후 자재코드</th>';
 	       		   	add_data += '<td class="fl">' + item.MATNR_TO + '</td></tr>';
 	       			add_data += '<tr><th class="fl">변경후 자재명</th>';
 	       		   	add_data += '<td class="fl">' + item.MATNR_NM_TO + '</td></tr>';
 	       		   
 	       	       	$("#PROD_TYPE").val(item.PROD_TYPE);	// 제품타입  ???
 	       	       	$("#STCK_QTY").val(item.STCK_QTY);		// 자재 재고수량
				});
 	       		
 	       	   	target1.html(add_data);
 	       	   	target2.html(add_data2);
 	       	   
				$("#IND_BCD").focus();
			}
		}
	}
       
    function showMain() {
    	window.top.menuOpen();
    }
    
    //변경요청 //1. TB_IFS009 INSERT
    function outRequest(){
    	var json = netUtil.sendData({
    		module : 'mes',
    		command : 'SYSTEMCHECK',
    		sendType : 'map'
    	});
    	
    	if(json.data.USE_YN == 'Y'){
    		commonUtil.msgBox('시스템 점검 중입니다. 1 ~ 5분 동안 잠시만 기다려 주세요.', null, null, function(){
    			$('#IND_BCD').focus();
    		});
    		return;
    	}
       	
    	if(barcodeCheck()){
        	if($("#STCK_QTY").val() == 0){
        		commonUtil.msgBox('재고수량이 0 이라 품목변경할 수 없습니다.', null, null, function(){
        			$('#IND_BCD').focus();
        		});
        		return;
        	}
        	
    		var param = new DataMap();
           	
           	param.put("P_TYPE", "SAVE1");
           	param.put("WERKS", '<%=plant%>');
           	param.put("IND_BCD", $("#IND_BCD").val());
           	param.put("INP_DT", $("#INP_DT").val());
           	param.put("MATNR_FROM", $("#MATNR_FROM").text());
           	
           	var jsonStr = JSON.stringify(param);

           	commonUtil.msgConfirm("변경요청 하시겠습니까?", null, function(){
           		netUtil.send({
              		url : "/mobile/Mobile/PDA_WRK13_LAMI/json/datalist.data",
               		param : param,
               		successFunction : "saveSuccessCallBack2"
               	});
           	}, function(){
           		$('#IND_BCD').focus();
           	});
    	}
	}
       
	//변경요청 CALLBACK //1. TB_IFS009 INSERT
    function saveSuccessCallBack2(json){
    	console.log("saveSuccessCallBack2");
    	console.log("json : " + json);
    	console.log("M_DOC_NO1 : " + json.DOC_NO1);
		if(json.P_SUCCESS == 'Y'){
			
			//2. SAP재고이전
			if(json.DOC_NO1 != ''){
				var param = new DataMap();
               	
               	param.put("IFID", "MES_IF_131");
                param.put("DOC_NO", json.DOC_NO1);
                
                var json2 = netUtil.sendData({
              		url : "/mes/erpif/json/sendIF.data",
                   	param : param
                });
                   
                if(json2.data == 'SUCCESS'){
                	//3. TB_INV001 UPDATE
                	invUpdate(); 
                }else{
                	var msg = '(SAP 재고이전) ' + json2.data;
                
                	param.put('P_TYPE', 'DELETE2');
					param.put("WERKS", '<%=plant%>');
		  			param.put("IND_BCD", $("#IND_BCD").val());
					
					var json4 = netUtil.sendData({
		           		url : "/mobile/Mobile/PDA_WRK13_LAMI/json/datalist.data",
		           		param : param
		           	});
					
// 					if(json4.P_SUCCESS == 'Y'){
// 						commonUtil.msgBox("", null, null, function(){
// 							resetData();
// 						});
// 					}
                	
                   	commonUtil.msgBox(msg, null, null, function(){
                   		$('#IND_BCD').focus();
                   	});
                }
   			}else{
   	   			commonUtil.msgBox(json.ERR_MSG, null, null, function(){
   	   				$('#IND_BCD').focus();
   	   			});
   			}
   		}else{
   			commonUtil.msgBox(json.ERR_MSG, null, null, function(){
   				$('#IND_BCD').focus();
   			});
   		}
	}
    
	//재고반영 //3. TB_INV001 UPDATE
    function invUpdate(){
    	var param = new DataMap();
       	
       	param.put("P_TYPE", "SAVE2");
       	param.put("WERKS", '<%=plant%>');
       	param.put("IND_BCD", $("#IND_BCD").val());
       	param.put("MATNR_FROM", $("#MATNR_FROM").text());
       	
       	var json3 = netUtil.sendData({
       		url : "/mobile/Mobile/PDA_WRK13_LAMI/json/datalist.data",
       		param : param
       	});
       	
       	if(json3.P_SUCCESS == 'Y'){
			commonUtil.msgBox("변경요청 완료되었습니다.", null, null, function(){
				resetData();
			});
       	}else{
       		//재고 반영 취소 //1. TB_IFS009 INSERT
       		commonUtil.msgBox(json3.ERR_MSG, null, null, function(){
  				param.put('P_TYPE', 'DELETE1');
				
				var json4 = netUtil.sendData({
	           		url : "/mobile/Mobile/PDA_WRK13_LAMI/json/datalist.data",
	           		param : param
	           	});
				
				if(json4.P_SUCCESS == 'Y'){
					param.put("IFID", "MES_IF_131");
					param.put("DOC_NO", json4.DOC_NO1);
					
					//2. SAP재고이전(취소)
					if(json4.DOC_NO1 != ''){
						var json5 = netUtil.sendData({
							url : "/mes/erpif/json/sendIF.data",
							param : param
						});
						
						if(json5.data == 'SUCCESS'){
							//재고이전 취소(SAP 재고이전 취소) 3. TB_INV001 UPDATE, TB_WRK024 UPDATE
							param.put('P_TYPE', 'DELETE2');
							param.put("WERKS", '<%=plant%>');
				  			param.put("IND_BCD", $("#IND_BCD").val());
							
							var json4 = netUtil.sendData({
				           		url : "/mobile/Mobile/PDA_WRK13_LAMI/json/datalist.data",
				           		param : param
				           	});
							
							if(json4.P_SUCCESS == 'Y'){
								commonUtil.msgBox("변경요청 취소되었습니다.", null, null, function(){
									resetData();
								});
							}
						}else{
							var msg = '(SAP 재고이전취소)' + json5.data;
							commonUtil.msgBox(msg, null, null, function(){
								$('#IND_BCD').focus();
							});
						}
					}
				}else{
					commonUtil.msgBox(json4.ERR_MSG, null, null, function(){
						resetData();
					});
				}
   			});
       	}
    }
    
    //변경요청 취소 //1. TB_IFS009 INSERT
    function outrReqCancel(){
    	var json = netUtil.sendData({
    		module : 'mes',
    		command : 'SYSTEMCHECK',
    		sendType : 'map'
    	});
    	
    	if(json.data.USE_YN == 'Y')	{
    		commonUtil.msgBox('시스템 점검 중입니다. 시스템 관리팀에 연락주시기 바랍니다.', null, null, function(){
    			$('#IND_BCD').focus();
    		});
    		return;
    	}
    	
  		if(barcodeCheck()){
  			var param = new DataMap();
  	       	
  	       	param.put("P_TYPE", "DELETE1");
  	       	param.put("WERKS", '<%=plant%>');
  			param.put("IND_BCD", $("#IND_BCD").val());

  			commonUtil.msgConfirm("변경요청 취소하시겠습니까?", null, function(){
  				netUtil.send({
  					url : "/mobile/Mobile/PDA_WRK13_LAMI/json/datalist.data",
  					param : param,
  					successFunction : "saveSuccessCallBack3"
  				});
  			}, function(){
  				$('#IND_BCD').focus();
  			});
  		}
	}

  	//변경요청 취소 callback
	function saveSuccessCallBack3(json) {
		if (json.P_SUCCESS == 'Y') {
			//2. SAP재고이전 취소
			var param = new DataMap();
			
			param.put("IFID", "MES_IF_131");
			param.put("DOC_NO", json.DOC_NO1);
			
			var json2 = netUtil.sendData({
				url : "/mes/erpif/json/sendIF.data",
				param : param
			});
			
			if(json2.data == 'SUCCESS'){
				//3. TB_INV001 UPDATE, TB_WRK024 UPDATE
				param.put('P_TYPE', 'DELETE2');
				param.put("WERKS", '<%=plant%>');
	  			param.put("IND_BCD", $("#IND_BCD").val());
				
				var json4 = netUtil.sendData({
	           		url : "/mobile/Mobile/PDA_WRK13_LAMI/json/datalist.data",
	           		param : param
	           	});
				
				if(json4.P_SUCCESS == 'Y'){
					commonUtil.msgBox("변경요청이 취소되었습니다.", null, null, function(){
						resetData();
					});
				}
			}else{
				var msg = '(SAP 재고이전 취소) ' + json2.data;
				
				commonUtil.msgBox(msg, null, null, function(){
					$('#IND_BCD').focus();
				});
			}
		}else{
			commonUtil.msgBox(json.ERR_MSG, null, null, function(){
				$('#IND_BCD').focus();
			});
		}
	}

	function resetData() { // 초기화
		PlaySound('s');

		var target1 = $('#list1');
		var target2 = $('#list2');
		var add_data = '';
		var add_data2 = '';

		add_data2 += '<tr><th class="fl">실적상태</th></tr>';

		add_data += '<tr><th class="fl">바코드</th></tr>';
		add_data += '<tr><th class="fl">변경전 자재코드</th></tr>';
		add_data += '<tr><th class="fl">변경전 자재명</th></tr>';
		add_data += '<tr><th class="fl">지종</th></tr>';
		add_data += '<tr><th class="fl">평량</th></tr>';
		add_data += '<tr><th class="fl">규격</th></tr>';
		add_data += '<tr><th class="fl">중량</th></tr>';
		// 		add_data += '<tr><td><br></td></tr>';
		add_data += '<tr><th class="fl">변경후 자재코드</th></tr>';
		add_data += '<tr><th class="fl">변경후 자재명</th></tr>';

		target1.html(add_data);
		target2.html(add_data2);

		$("#IND_BCD").val('');
		$("#IND_BCD").focus();
	}

	function fn_onfocus(objId) {
		$("#" + objId).select();
	}
</script>
</head>
<body>
	<div class="main_wrap">
		<div class="main_header">
			<ul>
				<li class="tit" id="title" style="width: 100%;">품목변경_라미네이팅</li>
			</ul>
		</div>
		<div class="tem4_content">
			<div class="select_box" id="bindArea">
				<div id="searchArea">
					<table>
						<colgroup>
							<col width="120px" />
							<col />
						</colgroup>
						<tbody>
							<tr>
								<th class="fl">바코드</th>
								<td colspan="3"><input type="text" class="text" inputmode="none"
									id="IND_BCD" name="IND_BCD" placeholder="바코드스캔 및 입력"
									onfocus="fn_onfocus(this.id)"
									onkeypress="commonUtil.enterKeyCheck(event, 'onReadBarcode()')"
									style="text-align: center;" autocomplete="off" /></td>
							</tr>
							<tr>
								<th class="fl">전기일</th>
								<td colspan="3"><input type="text" class="text" id="INP_DT" inputmode="none"
									UIFormat="C N" style="width: 90%; text-align: center; float: left;" /></td>
							</tr>
							<input type="hidden" id="STCK_QTY"/>
						</tbody>
					</table>

					<table class="mg-10 bd-c1">
						<colgroup>
							<col width="30%" />
							<col width="70%" />
						</colgroup>
						<tbody id="list2">
							<tr>
								<th class="fl">실적 상태</th>
								<td class="fl"></td>
							</tr>
						</tbody>
					</table>

					<table class="mg-10 bd-c1">
						<colgroup>
							<col width="30%" />
							<col width="70%" />
						</colgroup>
						<tbody id="list1">

							<tr>
								<th class="fl">바코드</th>
								<td class="fl"></td>
							</tr>
							<tr>
								<th class="fl">변경전 자재코드</th>
								<td class="fl"></td>
							</tr>
							<tr>
								<th class="fl">변경전 자재명</th>
								<td class="fl"></td>
							</tr>
							<tr>
								<th class="fl">지종</th>
								<td class="fl"></td>
							</tr>
							<tr>
								<th class="fl">평량</th>
								<td class="fl"></td>
							</tr>
							<tr>
								<th class="fl">규격</th>
								<td class="fl"></td>
							</tr>
							<tr>
								<th class="fl">중량</th>
								<td class="fl"></td>
							</tr>
<!-- 							<tr> -->
<!-- 								<td><br></td> -->
<!-- 							</tr> -->
							<tr>
								<th class="fl">변경후 자재코드</th>
								<td class="fl"></td>
							</tr>
							<tr>
								<th class="fl">변경후 자재명</th>
								<td class="fl"></td>
							</tr>

						</tbody>
					</table>
				</div>
			</div>

			<div class="footer_4" style="height: 60px;"></div>

			<!-- end table_body -->
			<div class="footer_5" style="position: fixed;">
				<table>
					<tr>
						<td class="f_1" onclick="showMain()" style="width: 25%"><label CL='BTN_CLOSE'></label></td>
						<td class="f_1" onclick="outRequest()" style="width: 25%"><label>변경요청</label></td>
						<td class="f_1" onclick="outrReqCancel()" style="width: 25%"><label>변경요청취소</label></td>
<!-- 						<td class="f_1" onclick="" style="width: 25%"><label>요청이력조회</label></td> -->
					</tr>
				</table>
			</div>
			<!-- end footer_5 -->
		</div>
	</div>
</body>