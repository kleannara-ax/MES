<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
	String procCd = (String)request.getSession().getAttribute(CommonConfig.SES_PROC_CD);
	String machCd = (String)request.getSession().getAttribute(CommonConfig.SES_MACH_CD);
	String plant = (String)request.getSession().getAttribute(CommonConfig.SES_USER_PLANT_KEY);
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
    	$(document).ready(function(){
			var ProcCd = "<%=procCd%>";
        	
        	if(ProcCd != "CA"){
        		PlaySound("e");
        		commonUtil.msgBox("재단 공정하는 화면입니다.", null, null, function(){
        			showMain();	
        		});
        	}
    		
        	$("#MACH_CD").val("<%=machCd%>");
        	
        	PlaySound("s");
        	
        	$('#IND_BCD').focus();
        });
    	
    	// 바코드 스캔
        function onReadBarcode(){
    		if($('#IND_BCD').val() == ''){
    			commonUtil.msgBox('바코드를 스캔하세요', null, null, function(){
    				$('#IND_BCD').focus();
    			});
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
  		   param.put("PROC_CD", '<%=procCd%>');
  		   param.put("IND_BCD", $("#IND_BCD").val());

  		   netUtil.send({
  			   url : "/mobile/Mobile/PDA_WRK02/json/datalist.data",
  			   param : param,
  			   successFunction : "saveSuccessCallBack1"
  		   });
        }
        
        function saveSuccessCallBack1(json){
     	   if(json && json.data){
     		  var param = new DataMap();
              param.put("PROGID", "<%= menuId%>");
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
		     			   
					 	add_data += '<tr><th class="fl">밀롤 바코드</th></tr>';
						add_data += '<tr><th class="fl">밀롤 LOT NO</th></tr>';
						add_data += '<tr><th class="fl">작업지시 번호</th></tr>';          		        			
						add_data += '<tr><th class="fl">작업지시 순번</th></tr>';          			          			
						add_data += '<tr><th class="fl">오더번호</th></tr>';          		         			
						add_data += '<tr><th class="fl">자재(제품)코드</th></tr>';          
						add_data += '<tr><th class="fl">지종</th></tr>';          			 
						add_data += '<tr><th class="fl">평량</th></tr>';          			  
						add_data += '<tr><th class="fl">생산일자</th></tr>';          			 
						add_data += '<tr><th class="fl">작업자</th></tr>';        
						add_data += '<tr><td><br></td></tr>';
						add_data += '<tr><th class="fl">권치수</th></tr>';          			
						add_data += '<tr><th class="fl">지관</th></tr>';          			
						add_data += '<tr><th class="fl">중량</th></tr>';       
						add_data += '<tr><td><br></td></tr>';
						add_data += '<tr><th class="fl">규격</th></tr>';          			
						add_data += '<tr><th class="fl">거래처</th></tr>';          		
	     			   
	     			   target1.html(add_data);
		  	       	   target2.html(add_data2);
	   			   });
	     	  } else if(json.data.length == 1){
     			   PlaySound("s");
 	    		
	 	 		   var target1 = $('#list1');
	 	 		   var target2 = $('#list2');
	 	     	   var value = json.data;
	 	     	   var add_data = '';
	 	     	   var add_data2 = '';
	 	     	    
	 	     	   $.each(value, function (index, item){
	 	     		   add_data += '<tr><th class="fl">밀롤 바코드</th>';
	 	       		   add_data += '<td class="fl">' + item.IND_BCD + '</td></tr>';
	 	       		   add_data += '<tr><th class="fl">밀롤 LOT NO</th>';
	 	       		   add_data += '<td class="fl">' + item.LOT_NO + '</td></tr>';	
	 	       		   add_data += '<tr><th class="fl">작업지시 번호</th>';          			
	 	       		   add_data += '<td class="fl">' + item.WRK_ORDR_NO + '</td></tr>';          			
	 	       		   add_data += '<tr><th class="fl">작업지시 순번</th>';          			
	 	       		   add_data += '<td class="fl">' + item.WRK_ORDR_SEQNO + '</td></tr>';          			
	 	       		   add_data += '<tr><th class="fl">오더번호</th>';          			
	 	       		   add_data += '<td class="fl">' + item.ORDER_NO + '</td></tr>';          			
	 	       		   add_data += '<tr><th class="fl">자재(제품)코드</th>';          			
	 	       		   add_data += '<td class="fl">' + item.MATNR + '</td></tr>'; 
	 	       		   add_data += '<tr><th class="fl">지종</th>';          			
		       		   add_data += '<td class="fl">' + item.PCODE + '</td></tr>';   
		       		   add_data += '<tr><th class="fl">평량</th>';          			
		       		   add_data += '<td class="fl">' + item.BS_WGT + '</td></tr>';   
	 	       		   add_data += '<tr><th class="fl">생산일자</th>';          			
	 	       		   add_data += '<td class="fl">' + item.PRD_DT.substr(0, 4) + '-' + item.PRD_DT.substr(4, 2) + '-' + item.PRD_DT.substr(6, 2) + '</td></tr>';  
	 	       		   add_data += '<tr><th class="fl">작업자</th>';          			
		       		   add_data += '<td class="fl">' + item.NMLAST + '</td></tr>';
		       		   
		       		   add_data += '<tr><td><br></td></tr>';
		       		   
		       		   add_data += '<tr><th class="fl">권치수</th>';          			
		       		   add_data += '<td class="fl">' + item.ROLLCNT + '</td></tr>';
		       		   add_data += '<tr><th class="fl">지관</th>';          			
		       		   add_data += '<td class="fl">' + item.CORE + '</td></tr>';
		       		   add_data += '<tr><th class="fl">중량</th>';          			
		       		   add_data += '<td class="fl">' + item.STCK_QTY + '</td></tr>';
		       		   
		       		   add_data += '<tr><td><br></td></tr>';
		       			
		       		   add_data += '<tr><th class="fl">규격</th>';          			
	       		   	   add_data += '<td class="fl">' + item.MATNR_SPEC + '</td></tr>';
			       	   add_data += '<tr><th class="fl">거래처</th>';          			
			       	   add_data += '<td class="fl">' + item.CUST_NM + '</td></tr>';
		       		   
	 	       		   add_data2 += '<tr><td class="fl">' + item.STCK_STA + '</td></tr>';
	 	       		   
	 	       	       $("#STCK_STA").val(item.STCK_STA);	// 재고상태
	 	       	       $("#MATNR").val(item.MATNR);			// 자재
	 	       	       
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
        
        function wrkInput(){	// 공정투입
        	var indbcd = $("#IND_BCD").val();
        
        	if(indbcd == ''){
        		PlaySound('e');
        		commonUtil.msgBox("바코드 스캔 또는 입력하세요.", null, null, function(){
        			$("#IND_BCD").focus();
        		});
        		return;
        	}
        	
        	if(indbcd.length > 10){
     		   commonUtil.msgBox('존재하지 않는 바코드이므로 다시 스캔하세요.', null, null, function(){
     			  $('#IND_BCD').focus(); 
     		   });
     		   return;
       	   }
        	
        	var stcksta = $("#STCK_STA").val();
        	
        	if(stcksta != "투입가능"){
        		PlaySound('e');
        		commonUtil.msgBox("공정 투입 불가한 바코드입니다. (" + stcksta + ")", null, null, function(){
        			$("#IND_BCD").focus();	
        		});
        		return;
        	}
        	
        	var param = new DataMap();
        	
        	param.put("P_TYPE", "SAVE");
        	param.put("WERKS", '<%=plant%>');
        	param.put("PROC_CD", '<%=procCd%>');
        	param.put("MACH_CD",$("#MACH_CD").val());
        	param.put("IND_BCD", $("#IND_BCD").val());
        	
        	commonUtil.msgConfirm('공정에 투입하시겠습니까?', null, function(){
        		netUtil.send({
            		url : "/mobile/Mobile/PDA_WRK02/json/datalist.data",
            		param : param,
            		successFunction : "savesuccessCallBack2"
            	});
        	}, function(){
        		$('#IND_BCD').focus();
        	});
        }
        
        function savesuccessCallBack2(json){
        	if(json.P_SUCCESS == 'Y'){
        		commonUtil.msgBox("공정 투입 완료되었습니다.", null, null, function(){
        			resetData();
        		});
        	}else{
        		commonUtil.msgBox(json.ERR_MSG, null, null, function(){
        			$('#IND_BCD').focus();
        		});
        	}
        }
        
        function inputCancle(){
        	var indbcd = $("#IND_BCD").val();
            
        	if(indbcd == ''){
        		PlaySound('e');
        		commonUtil.msgBox("바코드 스캔 또는 입력하세요.", null, null, function(){
        			$('#IND_BCD').focus();
        		});
        		return;
        	}
        	
        	if(indbcd.length > 10){
     		   commonUtil.msgBox('존재하지 않는 바코드이므로 다시 스캔하세요.', null, null, function(){
     			  $('#IND_BCD').focus(); 
     		   });
     		   return;
       	   }
        	
			var param = new DataMap();
        	
        	param.put("P_TYPE", "SUB_SAVE1");
        	param.put("WERKS", '<%=plant%>');
        	param.put("PROC_CD", '<%=procCd%>');
        	param.put("MACH_CD",$("#MACH_CD").val());
        	param.put("IND_BCD", $("#IND_BCD").val());
        	param.put("MATNR", $("#MATNR").val());
        	
        	commonUtil.msgConfirm('투입 취소하시겠습니까?', null, function(){
        		netUtil.send({
            		url : "/mobile/Mobile/PDA_WRK02/json/datalist.data",
            		param : param,
            		successFunction : "savesuccessCallBack3"
            	});
        	}, function(){
        		$('#IND_BCD').focus();
        	});
        }
        
        function savesuccessCallBack3(json){
        	if(json.P_SUCCESS == 'Y'){
        		commonUtil.msgBox("공정투입취소되었습니다.", null, null, function(){
        			resetData();
        		});
        	}else{
        		commonUtil.msgBox(json.ERR_MSG, null, null, function(){
        			$('#IND_BCD').focus();
        		});
        	}
        }
        
        function resetData(){		// 초기화
        	PlaySound('s');
        
    		$("#STCK_STA").val('');
    		$("#MATNR").val('');
    		$("#IND_BCD").val('');
    		$("#IND_BCD").focus();
    		
    		var target1 = $('#list1');
			var target2 = $('#list2');
			var add_data = '';
			var add_data2 = '';
    		
    		add_data += '<tr><th class="fl">밀롤 바코드</th></tr>';
			add_data += '<tr><th class="fl">밀롤 LOT NO</th></tr>';
			add_data += '<tr><th class="fl">작업지시 번호</th></tr>';          		        			
			add_data += '<tr><th class="fl">작업지시 순번</th></tr>';          			          			
			add_data += '<tr><th class="fl">오더번호</th></tr>';          		         			
			add_data += '<tr><th class="fl">자재(제품)코드</th></tr>';          
			add_data += '<tr><th class="fl">지종</th></tr>';          			 
			add_data += '<tr><th class="fl">평량</th></tr>';          			  
			add_data += '<tr><th class="fl">생산일자</th></tr>';          			 
			add_data += '<tr><th class="fl">작업자</th></tr>';        
			add_data += '<tr><td><br></td></tr>';
			add_data += '<tr><th class="fl">권치수</th></tr>';          			
			add_data += '<tr><th class="fl">지관</th></tr>';          			
			add_data += '<tr><th class="fl">중량</th></tr>';       
			add_data += '<tr><td><br></td></tr>';
			add_data += '<tr><th class="fl">규격</th></tr>';          			
			add_data += '<tr><th class="fl">거래처</th></tr>';          		
			   
			target1.html(add_data);
			target2.html(add_data2);
        }
        function fn_onfocus(objId){
       		$("#"+objId).select();
       	   }
    </script>
</head>
<body>
<div class="main_wrap">
	<div class="main_header">
		<ul>
			<li class="tit" id="title" style="width:100%;">재단 공정</li>
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
                        <th class="fl" CL="STD_BARCOD">바코드</th>
                        <td colspan="3">
							<input type="text" class="text" id="IND_BCD" name="IND_BCD" placeholder="밀롤 바코드스캔 및 입력" autocomplete="off"
							onfocus="fn_onfocus(this.id)" onkeypress="commonUtil.enterKeyCheck(event, 'onReadBarcode()')" style="text-align:center;"/>                        
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
	                        <th class="fl">밀롤바코드</th>
	                        <td class="fl"></td>
                  	 	</tr>
                    	<tr>
	                        <th class="fl">밀롤 LOT NO</th>
	                        <td class="fl"></td>
                  	 	</tr>
                    	<tr>
	                        <th class="fl">작업지시 번호</th>
	                        <td class="fl"></td>
                  	 	</tr>
                    	<tr>
	                        <th class="fl">작업지시 순번</th>
	                        <td class="fl"></td>
                  	 	</tr>
                    	<tr>
	                        <th class="fl">오더번호</th>
	                        <td class="fl"></td>
                  	 	</tr>
                    	<tr>
	                        <th class="fl">자재코드</th>
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
	                        <th class="fl">생산일자</th>
	                        <td class="fl"></td>
                  	 	</tr>
                    	<tr>
	                        <th class="fl">작업자</th>
	                        <td class="fl"></td>
                  	 	</tr>
                  	 	
                  	 	<tr>
	               			<td><br></td>
	           	   		</tr>
                  	 	
                    	<tr>
	                        <th class="fl">권치수</th>
	                        <td class="fl"></td>
                  	 	</tr>
                  	 	<tr>
	                        <th class="fl">지관</th>
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
	                        <th class="fl">규격</th>
	                        <td class="fl"></td>
                  	 	</tr>
                    	<tr>
	                        <th class="fl">거래처</th>
	                        <td class="fl"></td>
                  	 	</tr>
                    
                    </tbody>
                </table>
                
                <table class="mg-10 bd-c1">
                    <colgroup>
                        <col width="30%" />
                        <col width="70%" />
                    </colgroup>
                    <tbody id="list2">
                    
                    </tbody>
                </table>
            </div>
        </div>
		
		<dd style="display:none;">
			<input type="text" class="input" id="STCK_STA"/>		<!-- 재고상태 -->
			<input type="text" class="input" id="MATNR"/>			<!-- 자재코드 -->
		</dd>
		
		<div class="footer_4" style="height:100px;">
            <div class="select_box mg-20">
                <table>
                    <colgroup>
                        <col width="120px"/>
                        <col/>
                    </colgroup>
                    <tbody>
                    <tr>
                        <th class="fl">설비</th>
                        <td colspan="3">
							<select class="input" id="MACH_CD" name="MACH_CD" combo="mes,MACH2" style="text-align: center;">
							</select>
						</td>
                    </tr>
                    </tbody>
                </table>
            </div>
        </div>
		
        <!-- end table_body -->
        <div class="footer_5" style="position:fixed;">

            <table>
                <tr>
                    <td class="f_1" onclick ="showMain()" style="width:33%"><label CL='BTN_CLOSE'></label></td>
                    <td  class="f_1" onclick="wrkInput()" width="34%"><label>공정투입</label></td>
                    <td class="f_1" onclick ="inputCancle()" style="width:33%"><label >투입취소</label></td>
                </tr>
            </table>
        </div><!-- end footer_5 -->
    </div>
</div>
</body>