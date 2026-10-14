<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
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
		    if('<%=plant%>' == 'P100'){
		    	PlaySound('e');
		    	commonUtil.msgBox('PS 제지관리팀이 관리하는 화면이 아닙니다.', null, null, function(){
		    		showMain();
		    	});
		    }
		    $('#IND_BCD').focus();
		});
        
        
        function showMain() {
            window.top.menuOpen();
        }

        function onReadBarcode(){	// 바코드 스캔
        	if($('#IND_BCD').val() == ''){
        		PlaySound('e');
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
      	  	
   		   param.put("P_TYPE","LIST");
   		   param.put("IND_BCD", $("#IND_BCD").val());<%-- 
   		   param.put("WERKS", '<%=plant%>');
   		   param.put("STOR_LOC_CD", $("#STOR_LOC_CD").val()); --%>

   		   netUtil.send({
   			   url : "/mobile/Mobile/PDA_WRK08/json/datalist.data",
   			   param : param,
   			   successFunction : "saveSuccessCallBack2"
   		   });
         }
         
         function saveSuccessCallBack2(json){
      	   if(json && json.data){
      		 var param = new DataMap();
             param.put("PROGID", "<%= menuId%>");
             param.put("LGTYPE", "SEARCH");
             var json2 = netUtil.sendData({
                 url: "/mes/system/json/saveLog.data",
                 param : param
             });
             
  	 		   var target1 = $('#list1');
  	 		   var target2 = $("#list2");
  	     	   var value = json.data;
  	     	   var add_data = '';
  	     	   var add_data2 = '';
  	     	   
	  	     	if(json.data.length == 0){
					PlaySound("e");
					commonUtil.msgBox(configData.MSG_MASTER_ROWEMPTY, null, null, function(){
						$("#IND_BCD").focus();
					   	add_data += '<tr><th class="fl">플랜트코드</th></tr>';
						add_data += '<tr><th class="fl">개별바코드</th></tr>';    
						add_data += '<tr><th class="fl">저장위치</th></tr>';          			
						add_data += '<tr><th class="fl">저장위치명</th></tr>';    
						add_data += '<tr><th class="fl">자재코드</th></tr>';
						add_data += '<tr><th class="fl">자재명</th></tr>';
						add_data += '<tr><th class="fl">LOT NO</th></tr>';    
						add_data += '<tr><th class="fl">재고수량</th></tr>';  
						add_data += '<tr><th class="fl">단위</th></tr>';          		
					   
					   	target1.html(add_data);
					   	target2.html(add_data2);
					});
				} else if(json.data.length == 1){
					PlaySound("s");
  	     	    
	  	     	   $.each(value, function (index, item){
	  	     		   add_data += '<tr><th class="fl">플랜트코드</th>';
	  	       		   add_data += '<td class="fl">' + item.WERKS + '</td></tr>';
	  	       		   
	  	       		   add_data += '<tr><th class="fl">개별바코드</th>';          			
	  	       		   add_data += '<td class="fl">' + item.IND_BCD + '</td></tr>';
	  	       		   
	  	       		   add_data += '<tr><th class="fl">저장위치</th>';          			
	  	       		   add_data += '<td class="fl">' + item.STOR_LOC_CD + '</td></tr>';
	  	       		   add_data += '<tr><th class="fl">저장위치명</th>';          			
	  	       		   add_data += '<td class="fl">' + item.STOR_LOC_NM + '</td></tr>';
	  	       		   
	  	     		   add_data += '<tr><th class="fl">자재코드</th>';
	  	       		   add_data += '<td class="fl">' + item.MATNR + '</td></tr>';
	  	       		   add_data += '<tr><th class="fl">자재명</th>';
	  	       		   add_data += '<td class="fl">' + item.MATNR_NM + '</td></tr>';
	  	       		   
	  	       		   add_data += '<tr><th class="fl">LOT NO</th>';          			
	  	       		   add_data += '<td class="fl">' + item.LOT_NO + '</td></tr>';
	  	       		   
	  	       		   add_data += '<tr><th class="fl">재고수량</th>';          			
	  	       		   add_data += '<td class="fl">' + item.STCK_QTY + '</td></tr>';
	          			
	  	       		   add_data += '<tr><th class="fl">단위</th>';          			
	  	       		   add_data += '<td class="fl">' + item.UNIT + '</td></tr>';  
	  	       		   
	  	       		   add_data2 += '<tr><td class="fl">' + item.APVR_STA_NM + '</td></tr>';
	  	       		   
	  	       		   $("#WERKS").val(item.WERKS);
	  	       		   $("#MATNR").val(item.MATNR);			
	  	       		   $("#MATNR_NM").val(item.MATNR_NM);
	  	       		   $("#STOR_LOC_CD").val(item.STOR_LOC_CD);	
	  	       		   $("#STOR_LOC_NM").val(item.STOR_LOC_NM);	
	  	       	       $("#LOT_NO").val(item.LOT_NO);
	  	       	       $("#STCK_QTY").val(item.STCK_QTY);
	  	       	       //$("#DISPO_QTY").val(item.DISPO_QTY);
	  	       	       $("#UNIT").val(item.UNIT);
	  	       	       $("#APVR_STA").val(item.APVR_STA);
	  	       	   });
	  	       		
	  	       	   target1.html(add_data);
	  	       	   target2.html(add_data2);
	  	 		} 
	   		}
  	    }
		//폐기
        function dispo(){
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
        	 
      	   var param = new DataMap();
     	  	
  	 		param.put("P_TYPE","SAVE");
  	 		
  	 		param.put("IND_BCD", $("#IND_BCD").val());
  	 		param.put("WERKS", $("#WERKS").val());
  	 		param.put("STOR_LOC_CD", $("#STOR_LOC_CD").val());
  	 		param.put("MATNR", $("#MATNR").val());
  	 		param.put('LOT_NO', $("#LOT_NO").val());
  	 		param.put("STCK_QTY", $("#STCK_QTY").val());
  	 		param.put('UNIT', $("#UNIT").val());
  	 		param.put("APVR_STA", $("#APVR_STA").val());
  	 		
  	 		commonUtil.msgConfirm("폐기 처리하시겠습니까?", null, function(){
  	 			netUtil.send({
  	  				url : "/mobile/Mobile/PDA_WRK08/json/datalist.data",
  	  				param : param,
  	  				successFunction : "savesuccessCallBack"
  	  		   	});
  	 		}, function(){
  	 			$('#IND_BCD').focus();
  	 		});
         }

         function savesuccessCallBack(json){
         	if(json){
         		if(json.P_SUCCESS == "Y"){
         			//20220715 여한진 RFC 호출 SAP에 재고이전
       				var param = new DataMap();
       	            
       	            param.put("IFID", "MES_IF_131");
       	            param.put("DOC_NO", json.DOC_NO);
       	            
       	            var json2 = netUtil.sendData({
       	            	url : "/mes/erpif/json/sendIF.data",
       	            	param : param
       	            });
              		
       	            if(json2){
       	            	if(json2.data == "SUCCESS"){
       	            		commonUtil.msgBox("폐기 처리가 완료되었습니다.", null, null, function(){
       	            			reset();
       	            		});	       	          		
       	            	}else{
       	            		PlaySound('e');
       	            		commonUtil.msgBox('(SAP 재고이전) ' + json2.data, null, null, function(){
       	            			$('#IND_BCD').focus();
       	            		});
       	            	}
                	}
         		}else{
         			PlaySound('e');
         			commonUtil.msgBox(json.ERR_MSG, null, null, function(){
         				$('#IND_BCD').focus();
         			});
         		}
       		}
         }
         function fn_onfocus(objId){
        	 $("#"+objId).select();
   	   	 }
         
         function reset(){
        	 PlaySound('s');
        	 
        	 $("#IND_BCD").focus();
			$("#IND_BCD").val('');
        	 
        	 var target1 = $('#list1');
        	 var target2 = $("#list2");
	     	 var add_data = '';
	     	 var add_data2 = '';
        	 
        	 add_data += '<tr><th class="fl">플랜트코드</th></tr>';
       		 add_data += '<tr><th class="fl">개별바코드</th></tr>';    
       		 add_data += '<tr><th class="fl">저장위치</th></tr>';          			
       		 add_data += '<tr><th class="fl">저장위치명</th></tr>';    
     		 add_data += '<tr><th class="fl">자재코드</th></tr>';
       		 add_data += '<tr><th class="fl">자재명</th></tr>';
       		 add_data += '<tr><th class="fl">LOT NO</th></tr>';    
       		 add_data += '<tr><th class="fl">재고수량</th></tr>';  
       		 add_data += '<tr><th class="fl">단위</th></tr>';          		
 			 
 			 target1.html(add_data);
 			 target2.html(add_data2);
         }

    </script>
</head>
<body>
<div class="main_wrap">
	<div class="main_header">
		<ul>
			<li class="tit" id="title" style="width:100%;">폐기처리(HL)</li>
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
                        <td>
                            <input type="text" class="text" name="IND_BCD" id="IND_BCD" placeholder="바코드스캔 및 입력" style='text-align:center;'
                            onfocus="fn_onfocus(this.id)" onkeypress="commonUtil.enterKeyCheck(event, 'onReadBarcode()')" autocomplete="off"/>
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
	                        <th class="fl">플랜트코드</th>
	                        <td class="fl"></td>
	                    </tr>
	                    <tr>
	                        <th class="fl">개별바코드</th>
	                        <td class="fl"></td>
	                    </tr>
	                    <tr>
	                        <th class="fl">저장위치</th>
	                        <td class="fl"></td>
	                    </tr>
	                    <tr>
	                        <th class="fl">저장위치명</th>
	                        <td class="fl"></td>
	                    </tr>
	                    <tr>
	                        <th class="fl">자재코드</th>
	                        <td class="fl"></td>
	                    </tr>
	                    <tr>
	                        <th class="fl">자재명</th>
	                        <td class="fl"></td>
	                    </tr>
	                    <tr>
	                        <th class="fl">LOT NO</th>
	                        <td class="fl"></td>
	                    </tr>
	                    <tr>
	                        <th class="fl">재고수량</th>
	                        <td class="fl"></td>
	                    </tr>
	                    <tr>
	                        <th class="fl">단위</th>
	                        <td class="fl"></td>
	                    </tr>
                    
                    </tbody>
                </table>
                
                <table class="mg-10 bd-c1">
					<colgroup>
						<col width="70%" />
					</colgroup>
					<tbody id="list2">
						
					</tbody>
				</table>
            </div>
        </div>
	
		
		<dd style="display:none;">
				<input type="text" class="input" id="WERKS"/>
				<input type="text" class="input" id="MATNR"/>		
				<input type="text" class="input" id="LOT_NO"/>			
				<input type="text" class="input" id="STOR_LOC_CD"/>			
				<input type="text" class="input" id="STCK_QTY"/>		
				<!-- <input type="text" class="input" id="DISPO_QTY"/>	 -->			
				<input type="text" class="input" id="UNIT"/>
				<input type="text" class="input" id="APVR_STA"/>			
			</dd>
		
        <!-- end table_body -->
        <div class="footer_5" style="position:fixed;">

            <table>
                <tr>
                	<td class="f_1" onclick ="showMain()" style="width:50%"><label CL='BTN_CLOSE'></label></td>
                    <td class="f_1" onclick ="dispo()" style="width:50%">폐기</td>
                </tr>
            </table>
        </div><!-- end footer_5 -->
    </div>
</div>
</body>