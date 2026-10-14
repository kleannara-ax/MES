<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
	String plant = (String)request.getSession().getAttribute(CommonConfig.SES_USER_PLANT_KEY);
	String machCd = (String)request.getSession().getAttribute(CommonConfig.SES_MACH_CD);
%>
<!doctype html>
<head>
    <style type="text/css">
        button {float: right; }
        input:read-only {background-color: #e2e2e2;}
        select:DISABLED {background-color: #e2e2e2;}
    </style>
    <meta charset="utf-8">
    <meta name="viewport" content="user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, width=device-width, target-densitydpi=medium-dpi" />
    <meta name="format-detection" content="telephone=no" />
    <title>Mobile MES</title>
    <%@ include file="/mobile/include/head.jsp" %>
    <script>
    	var message = '';
    	
		$(document).ready(function(){
			if('<%=plant%>' != 'P100'){
			PlaySound('e');
			commonUtil.msgBox("HL생활용품팀이 관리하는 화면이 아닙니다.", null, null, function(){
				showMain()
			});
  		});
  
		// 바코드 스캔
		function onReadBarcode(){
			if($('#IND_BCD').val() == ''){
        		commonUtil.msgBox('바코드를 스캔하세요.', null, null, function(){
        			$('#IND_BCD').focus();
        		});
        		return;
        	}
			
			var ind_bcd = $('#IND_BCD').val();
            
 	       if(ind_bcd.length > 10){
     		   commonUtil.msgBox('존재하지 않는 바코드이므로 다시 스캔하세요.', null, null, function(){
     			  $('#IND_BCD').focus(); 
     		   });
     		   return;
       	   }
   			var param = new DataMap();
  	
			param.put("P_TYPE", "LIST");
			param.put("WERKS", '<%=plant%>');
			param.put("IND_BCD", $("#IND_BCD").val());

			netUtil.send({
				url : "/mobile/Mobile/PDA_WRK11/json/datalist.data",
				param : param,
				successFunction : "saveSuccessCallBack1"
			});
		}
      
		function saveSuccessCallBack1(json){
			if(json){
				var target1 = $('#list1');
				var target2 = $('#list2');
				var add_data = '';
				var add_data2 = '';
    	   
				var param = new DataMap();
	            param.put("PROGID", "<%= menuId%>");
	            param.put("LGTYPE", "SEARCH");
	            var json2 = netUtil.sendData({
	                url: "/mes/system/json/saveLog.data",
	                param : param
	            });
				
				if(json.data.length == 0){
					PlaySound("e");	
					commonUtil.msgBox(configData.MSG_MASTER_ROWEMPTY, null, null, function(){
						$("#IND_BCD").focus();
				        
			        	add_data += '<tr><th class="fl">포장 바코드</th></tr>';
						add_data += '<tr><th class="fl">포장 LOT NO</th></tr>';
						add_data += '<tr><th class="fl">지종명</th></tr>';          			        			
						add_data += '<tr><th class="fl">평량</th></tr>';          			 
						add_data += '<tr><th class="fl">규격</th></tr>';          			
						add_data += '<tr><th class="fl">속/매</th></tr>';          	
						
						add_data += '<tr><td><br></td></tr>';
						
						add_data += '<tr><th class="fl">권치수/연수</th></tr>';          			
						add_data += '<tr><th class="fl">중량</th></tr>';          			
						
						add_data += '<tr><td><br></td></tr>';
						
						add_data += '<tr><th class="fl">포장타입</th></tr>';          			
						add_data += '<tr><th class="fl">거래처</th></tr>';          		
						
						add_data2 += '<tr><th class="fl">포장실적상태</th></tr>'; 
						   
						target1.html(add_data);
						target2.html(add_data2);
					});
				} else if(json.data.length == 1){
					PlaySound("s");
	   		 	
					var value = json.data;
		     	    
					$.each(value, function (index, item){
						add_data += '<tr><th class="fl">포장 바코드</th>';
						add_data += '<td class="fl">' + item.IND_BCD + '</td></tr>';
						add_data += '<tr><th class="fl">포장 LOT ID</th>';
						add_data += '<td class="fl">' + item.LOT_NO + '</td></tr>';	
						add_data += '<tr><th class="fl">지종명</th>';          			
						add_data += '<td class="fl">' + item.PCODE_NM + '</td></tr>';          			
						add_data += '<tr><th class="fl">평량</th>';          			
						add_data += '<td class="fl">' + item.BS_WGT + '</td></tr>';
						add_data += '<tr><th class="fl">규격</th>';          			
						add_data += '<td class="fl">' + item.MATNR_SPEC + '</td></tr>';
						add_data += '<tr><th class="fl">속/매</th>';          			
						add_data += '<td class="fl">' + item.SMCNT + '</td></tr>';
						  
						add_data += '<tr><td><br></td></tr>';
						  
						add_data += '<tr><th class="fl">권치수/연수</th>';          			
						add_data += '<td class="fl">' + item.PRFM_QTY + '</td></tr>';
						add_data += '<tr><th class="fl">중량</th>';          			
						add_data += '<td class="fl">' + item.WGT + '</td></tr>';
						   
						add_data += '<tr><td><br></td></tr>';
						  
						add_data += '<tr><th class="fl">포장타입</th>';          			
						add_data += '<td class="fl">' + item.PACKTYPE + '</td></tr>';
						add_data += '<tr><th class="fl">거래처</th>';          			
						add_data += '<td class="fl">' + item.KUNNR + '</td></tr>';
						
						add_data2 += '<tr><th class="fl">포장실적상태</th>'; 
						add_data2 += '<td class="fl">' + item.STCK_STA + '</td></tr>';
						
						$("#PROD_TYPE").val(item.PROD_TYPE);
						$("#MACH_CD").val(item.MACH_CD);
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
  		//실적등록
		function prfmReg(){
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
  			
  			if($("#IND_BCD").val() == ''){
        		PlaySound('e');
        		commonUtil.msgBox("바코드를 스캔 또는 입력하세요.", null, null, function(){
        			$('#IND_BCD').focus();
        		});
        		return;
        	}
  			if($("#PROD_TYPE").val() == ""){
  				PlaySound("e");
  				commonUtil.msgBox("제품타입의 정보가 없으므로 바코드 스캔하세요.", null, null, function(){
  					$("#IND_BCD").focus();
  				});
  				return;
  			}
        	
			var param = new DataMap();
		  	
			param.put("P_TYPE", "SAVE");
			param.put("WERKS", '<%=plant%>');
			param.put("IND_BCD", $("#IND_BCD").val());
			param.put("MACH_CD", $("#MACH_CD").val());

			commonUtil.msgConfirm("실적 등록하시겠습니까?", null, function(){
				netUtil.send({
					url : "/mobile/Mobile/PDA_WRK11/json/datalist.data",
					param : param,
					successFunction : "saveSuccessCallBack2"
				});	
			}, function(){
				$('#IND_BCD').focus();	
			});
		}
  		
  		function saveSuccessCallBack2(json){
  			if(json.P_SUCCESS == 'Y'){
  				var param = new DataMap();
  				
  				//포장 실적 정보를 SAP에 송신
  				param.put("IFID", "MES_IF_128");
	            param.put("DOC_NO", json.DOC_NO1);
	            
	            var json2 = netUtil.sendData({
	            	url : "/mes/erpif/json/sendIF.data",
	            	param : param
	            });
	            
	            if(json2.data == 'SUCCESS'){
	  				//완제품 출고 WMS에 요청
					InterfaceSendDoc(json.DOC_NO3);
  				}else{
					message = message + '(SAP 포장실적) ' + json2.data + '\n';
				}
				//결과
				if(message == ''){
					commonUtil.msgBox("실적 등록되었습니다.", null, null, function(){
						resetData();
					});
				}else{
					commonUtil.msgBox(message, null, null, function(){
						$('#IND_BCD').focus();
					});
				}
  			}else{
  				commonUtil.msgBox(json.ERR_MSG, null, null, function(){
  					$('#IND_BCD').focus();
  				});
  			}
  		}
  		
  		function InterfaceSendDoc(DOCNO){
   			var ifid = "MES_IF_402";
   			
   			var json = netUtil.sendData({
   				url : "/common/api/json/"+ifid+"/send.data",
   				param : 'DOC_NO=' + DOCNO
   			});
   			
   			if(json){
   				if(json.result != 'SUCCESS'){
   					message = message + '(WMS 완제품 출고 요청) ' + json.result + '\n';
   				}
   			}
    	}
  		
  		//실적취소
  		function prfmCnl(){
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
  			
  			var indbcd = $("#IND_BCD").val();
            
        	if(indbcd == ''){
        		PlaySound("e");
        		commonUtil.msgBox("바코드 스캔 또는 입력하세요.", null, null, function(){
        			$("#IND_BCD").focus();
        		});
        		return;
        	}
        	if($("#PROD_TYPE").val() == ""){
  				PlaySound("e");
  				commonUtil.msgBox("제품타입의 정보가 없으므로 바코드 스캔하세요.", null, null, function(){
  					$("#IND_BCD").focus();
  				});
  				return;
  			}
  			
  			var param = new DataMap();
  		  	
			param.put("P_TYPE", "SAVE1");
			param.put("WERKS", '<%=plant%>');
			param.put("IND_BCD", $("#IND_BCD").val());
			param.put("MACH_CD", $("#MACH_CD").val());

			commonUtil.msgConfirm("실적 취소하시겠습니까?", null, function(){
				netUtil.send({
					url : "/mobile/Mobile/PDA_WRK11/json/datalist.data",
					param : param,
					successFunction : "saveSuccessCallBack3"
				});
			}, function(){
				$('#IND_BCD').focus();
			});
  		}
		
  		function saveSuccessCallBack3(json){
  			if(json.P_SUCCESS == 'Y'){
  				var param = new DataMap();
  				//포장 실적취소 SAP에 송신
  				param.put("IFID", "MES_IF_129");
	            param.put("DOC_NO", json.DOC_NO1);
	            
	            var json3 = netUtil.sendData({
	            	url : "/mes/erpif/json/sendIF.data",
	            	param : param
	            });
	            
				if(json3.data == 'SUCCESS'){
					if(json.DOC_NO3 != ''){
						//완제품 출고취소를 WMS에 요청
						InterfaceSendDoc2(json.DOC_NO3);
					}
				}else{
					message = message + '(SAP 실적 취소) ' + json3.data + '\n';
				}
				//결과
				if(message == ''){
					commonUtil.msgBox("실적취소되었습니다.", null, null, function(){
						resetData();
					});
				}else{
					commonUtil.msgBox(message, null, null, function(){
						$('#IND_BCD').focus();
					});
				}
  			}else{
  				commonUtil.msgBox(json.ERR_MSG, null, null, function(){
  					$('#IND_BCD').focus();
  				});
  			}
  		}
  		
  		function InterfaceSendDoc2(DOCNO){
   			var ifid = "MES_IF_402";
   			
   			var json = netUtil.sendData({
   				url : "/common/api/json/"+ifid+"/send.data",
   				param : 'DOC_NO=' + DOCNO
   			});
   			
   			if(json){
   				if(json.result != 'SUCCESS'){
   					message = message + '(WMS 완제품 출고 요청 취소) ' + json.result + '\n';
   				}
   			}
    	}
  		
		function resetData(){		// 초기화
			PlaySound('s');
		
			message = '';
			
			var target1 = $('#list1');
			var target2 = $('#list2');
			var add_data = '';
			var add_data2 = '';
        
        	add_data += '<tr><th class="fl">포장 바코드</th></tr>';
			add_data += '<tr><th class="fl">포장 LOT NO</th></tr>';
			add_data += '<tr><th class="fl">지종명</th></tr>';          			        			
			add_data += '<tr><th class="fl">평량</th></tr>';          			 
			add_data += '<tr><th class="fl">규격</th></tr>';          			
			add_data += '<tr><th class="fl">속/매</th></tr>';          	
			
			add_data += '<tr><td><br></td></tr>';
			
			add_data += '<tr><th class="fl">권치수/연수</th></tr>';          			
			add_data += '<tr><th class="fl">중량</th></tr>';          			
			
			add_data += '<tr><td><br></td></tr>';
			
			add_data += '<tr><th class="fl">포장타입</th></tr>';          			
			add_data += '<tr><th class="fl">거래처</th></tr>';          		
			
			add_data2 += '<tr><th class="fl">포장실적상태</th></tr>'; 
			   
			target1.html(add_data);
			target2.html(add_data2);
		
			$("#IND_BCD").val('');
			$("#IND_BCD").focus();
  		}
		
  		function fn_onfocus(objId){
 			$("#"+objId).select();
 	   	}
    </script>
</head>
<body>
<div class="main_wrap">
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
                        <th class="fl" CL="STD_BARCOD">바코드</th>
                        <td>
                            <input type="text" class="text" id="IND_BCD" placeholder="포장 바코드스캔 및 입력" onfocus="fn_onfocus(this.id)" 
                            onkeypress="commonUtil.enterKeyCheck(event, 'onReadBarcode()')" style="text-align:center;" autocomplete="off"/>
                        </td>
                    </tr>
                    <tr>
                        <th class="fl" CL="STD_PROD_TYPE">제품타입</th>
                        <td colspan="3">
							<input type="text" class="text" id="PROD_TYPE" readonly="readonly" style="text-align:center;"/>                        
						</td>
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
	                        <th class="fl">포장 바코드</th>
	                        <td class="fl"></td>
	                    </tr>
	                    <tr>
	                        <th class="fl">포장 LOT ID</th>
	                        <td class="fl"></td>
	                    </tr>
	                    <tr>
	                        <th class="fl">지종명</th>
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
	                        <th class="fl">속/매</th>
	                        <td class="fl"></td>
	                    </tr>
	                                        
	                    <tr>
	               			<td><br></td>
	           	   		</tr>
	           	   		
	                    <tr>
	                        <th class="fl">권치수/연수</th>
	                        <td class="fl"></td>
	                    </tr>
	                    <tr>
	                        <th class="fl">중량</th>
	                        <td class="fl"></td>
	                    </tr>
	                                        
	                    <tr>
	               			<td><br></td>
	           	   		</tr>
	           	   		
	                    <tr>
	                        <th class="fl">포장타입</th>
	                        <td class="fl"></td>
	                    </tr>
	                    <tr>
	                        <th class="fl">거래처</th>
	                        <td class="fl"></td>
	                    </tr>
	                                       
	                    <tr>
	               			<td><br></td>
	           	   		</tr>
                    </tbody>
                </table>
                <table class="mg-10 bd-c1">
                    <colgroup>
                        <col width="30%" />
                        <col width="70%" />
                    </colgroup>
                    <tbody id="list2">
                    	<tr>
	                        <th class="fl">포장 실적 상태</th>
	                        <td class="fl"></td>
	                    </tr>
                    </tbody>
                </table>
            </div>
        </div>

		<dd style="display:none;">
				<input type="text" class="input" id="MACH_CD"/>	<!-- 설비코드 -->
			</dd>

        <!-- end table_body -->
        <div class="footer_5" style="position:fixed;">

            <table>
                <tr>
                	
                    <td class="f_1" onclick ="showMain()" style="width:33%"><label CL='BTN_CLOSE'></label></td>
                    <td class="f_1" onclick ="prfmReg()" style="width:33%">실적등록</td>
                    <td class="f_1" onclick ="prfmCnl()" style="width:33%">실적취소</td>
                </tr>
            </table>
        </div><!-- end footer_5 -->
    </div>
</div>
</body>