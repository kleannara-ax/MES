<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%
	String procCd = (String)request.getSession().getAttribute(CommonConfig.SES_PROC_CD);
	String machCd = (String)request.getSession().getAttribute(CommonConfig.SES_MACH_CD);
	String plant = (String)request.getSession().getAttribute(CommonConfig.SES_USER_PLANT_KEY);
	String wrkmeth = request.getParameter("WRK_METH");
	String wrkmethnm = request.getParameter("WRK_METH_NM");
	String strTm = request.getParameter("STR_TM");
	String endTm = request.getParameter("END_TM");
	String indbcd = request.getParameter("IND_BCD");
	String inpqty = request.getParameter("INP_QTY");
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
		$('#IND_BCD').focus();
		
		var json = netUtil.sendData({
			url : "/mobile/Mobile/json/gelInvNm.data",
		});
		
		if(json){
			$("#MACH_CD").val('[<%=machCd%>] ' + json.machNm);
		}
		
		if('<%=indbcd%>' != 'null'){
			$('#IND_BCD').val('<%=indbcd%>');
		}
		
		if('<%=inpqty%>' != 'null'){
			$('#INP_QTY').val('<%=inpqty%>');
		}
		
		if('<%=wrkmeth%>' != 'null'){
			$('#WRK_METH').val('<%=wrkmeth%>');
			$('#WRK_METH_NM').val('<%=wrkmethnm%>');
			$('#WRK_TIME').val('<%=strTm%> ~ <%=endTm%>');
			
			if($('#IND_BCD').val() != ''){
				onReadBarcode();
			}
		}
		
	});
	    
	   function linkPopCloseEvent(data){
		   $("#UNIT").val(data.get("UNIT"));
       }
	   
       function showMain() {
           window.top.menuOpen();
       }

       function onReadBarcode(){	// 바코드 스캔
    	   var ind_bcd = $('#IND_BCD').val();
    	   
    	   if($('#IND_BCD').val() == ''){
    		   commonUtil.msgBox('바코드를 스캔하세요', null, null, function(){
        		   $('#IND_BCD').focus();
        	   });
    		   return;
    	   }
    	   
    	   if('<%=plant%>' == 'P100'){
    		   if(ind_bcd.length > 10){
        		   commonUtil.msgBox('존재하지 않는 바코드이므로 다시 스캔하세요.', null, null, function(){
        			  $('#IND_BCD').focus(); 
        		   });
        		   return;
        	   }
    	   }else{
    		   if(ind_bcd.length > 15){
        		   commonUtil.msgBox('존재하지 않는 바코드이므로 다시 스캔하세요.', null, null, function(){
        			  $('#IND_BCD').focus(); 
        		   });
        		   return;
        	   }
    	   }	
       
    	   var param = new DataMap();
    	  	
 		   param.put("P_TYPE","LIST");
 		   param.put("IND_BCD", $("#IND_BCD").val());
 		   param.put("WERKS", '<%=plant%>');
		   param.put("MACH_CD", "<%=machCd%>");

 		   netUtil.send({
 			   url : "/mobile/Mobile/PDA_INV04/json/datalist.data",
 			   param : param,
 			   successFunction : "saveSuccessCallBack2"
 		   });
       }
       
       function saveSuccessCallBack2(json, status){
    	   if(json && json.data){
    		   var param = new DataMap();
               param.put("PROGID", "<%= menuId%>");
               param.put("LGTYPE", "SEARCH");
               var json2 = netUtil.sendData({
                   url: "/mes/system/json/saveLog.data",
                   param : param
               });
    		   
    		   var target1 = $('#list1');
  	 		   var add_data = '';
	     	   
    		   if(json.data.length == 0){
    			   PlaySound("e");
    			   commonUtil.msgBox(configData.MSG_MASTER_ROWEMPTY, null, null, function(){
    				   $("#IND_BCD").focus();
          			   
	   					add_data += '<tr><th class="fl">자재코드</th></tr>';
	   					add_data += '<tr><th class="fl">자재명</th></tr>';	
	   					add_data += '<tr><th class="fl">개별바코드</th></tr>';          	         			
	   					add_data += '<tr><th class="fl">LOT NO</th></tr>';          		        			
	   					add_data += '<tr><th class="fl">저장위치코드</th></tr>';          			        			
	   					add_data += '<tr><th class="fl">재고수량</th></tr>';          			         			
	   					add_data += '<tr><th class="fl">단위</th></tr>';          			
         			   
         			   target1.html(add_data);   
    			   });
      		   } else if(json.data.length == 1){
      			   PlaySound("s");
	    	
		     	   var value = json.data;
		     	    
		     	   $.each(value, function (index, item){
		     		   add_data += '<tr><th class="fl">자재코드</th>';
		       		   add_data += '<td class="fl">' + item.MATNR + '</td></tr>';
		       		   add_data += '<tr><th class="fl">자재명</th>';
		       		   add_data += '<td class="fl">' + item.MATNR_NM + '</td></tr>';	
		       		   add_data += '<tr><th class="fl">개별바코드</th>';          			
		       		   add_data += '<td class="fl">' + item.IND_BCD + '</td></tr>';          			
		       		   add_data += '<tr><th class="fl">LOT NO</th>';          			
		       		   add_data += '<td class="fl">' + item.LOT_NO + '</td></tr>';          			
		       		   add_data += '<tr><th class="fl">저장위치코드</th>';          			
		       		   add_data += '<td class="fl">' + item.STOR_LOC_CD + '</td></tr>';          			
		       		   add_data += '<tr><th class="fl">재고수량</th>';          			
		       		   add_data += '<td class="fl">' + item.STCK_QTY + '</td></tr>';          			
		       		   add_data += '<tr><th class="fl">단위</th>';          			
		       		   add_data += '<td class="fl">' + item.UNIT + '</td></tr>';  
		       		   
		       		   
		       		   $("#MATNR").val(item.MATNR);			
		       		   //$("#MATNR_NM").val(item.MATNR_NM);	
		       	       //$("#INP_QTY").val(item.STCK_QTY);	// 투입수량
		       	       $("#STCK_QTY").val(item.STCK_QTY);	// 재고수량
		       	       $("#STCK_STA").val(item.STCK_STA);
		       	       $("#LOT_NO").val(item.LOT_NO);
		       	       $("#UNIT").val(item.UNIT);
		       	       $('#INP_DATE').val(item.INP_DATE.substr(0,4) + '-' + item.INP_DATE.substr(4,2) + '-' + item.INP_DATE.substr(6,2));	//사용일자
		       	   });
		       		
		       	   target1.html(add_data);
		       	   
		       	   $("#IND_BCD").focus();
      		   }
		   }
	   }
       
       function unitselect(){	// 단위 선택
    	   mobile.linkPopOpen('/mobile/UNITPOP.page');
       }
       
       function Inpselect(){	// 투입이력
    	   <%-- var param = new DataMap();
    		
       		param.put("MACH_CD", "<%=machCd%>");
       		const INP_DATE = $("#INP_DATE").val()
			param.put("INP_DATE", INP_DATE.replace(/-/g,""));
       
    	   mobile.linkPopOpen('/mobile/PDA_INV04_POP02.page', param); --%>
    	   const INP_DATE = $("#INP_DATE").val();
    	   const paramStr = 'INP_DATE=' + INP_DATE.replace(/-/g,"") + '&WRK_METH=' + $('#WRK_METH').val();
    	   
    	   location.href = '/mobile/PDA_INV04_POP02.page?' + paramStr;
       }
       
       function changeQty(){	// 투입량 체크
    	   var stck_qty = $("#STCK_QTY").val();	// 재고수량
    	   var inp_qty = $("#INP_QTY").val();	
    	   
    	   if(Number(inp_qty) > Number(stck_qty)){
    		   PlaySound('e');
    		   commonUtil.msgBox("재고에 있는 수량만큼 사용 가능합나다.", null, null, function(){
    			   $("#INP_QTY").val('');
    			   $('#INP_QTY').focus();
    		   });
    	   }
       }
       
       function matnrInp(){
    	   var ind_bcd = $("#IND_BCD").val();
    	   var inp_qty = $("#INP_QTY").val();
    	   var wrk_meth1 = $("#WRK_METH").val();
    	   
    	   if(ind_bcd == ""){
    		   commonUtil.msgBox("바코드를 스캔 또는 입력하세요.", null, null, function(){
    			   $('#IND_BCD').focus();
    		   });
    		   return;
    	   }
    	   if(inp_qty == ""){
    		   commonUtil.msgBox("수량을 입력하시기 바랍니다.", null, null, function(){
    			  $('#INP_QTY').focus(); 
    		   });
    		   return;
    	   }
    	   if(wrk_meth1 == ""){
    		   commonUtil.msg("작업조를 선택하세요.");
    		   return;
    	   }
    	   
    	   var param = new DataMap();
   	  	
	 		param.put("P_TYPE","SAVE");
	 		param.put("IND_BCD", $("#IND_BCD").val());
	 		param.put("WERKS", '<%=plant%>');
	 		param.put("INPUT_QTY", $("#INP_QTY").val().replace(/,/g,''));	// 투입수량
	 		param.put("MACH_CD", "<%=machCd%>");
	 		param.put("WRK_ORDR_NO", $("#WRK_ORDR_NO").val());
	 		param.put("WRK_ORDR_SEQNO", $("#WRK_ORDR_SEQNO").val());
	 		param.put("MATNR", $("#MATNR").val());
	 		param.put("MATNR_NM", $("#MATNR_NM").val());
	 		param.put("LOT_NO", $("#LOT_NO").val());
	 		param.put("UNIT", $("#UNIT").val());
	 		param.put("WRK_METH", $("#WRK_METH").val());
	 		
	 		const INP_DATE = $("#INP_DATE").val()
			param.put("INP_DATE", INP_DATE.replace(/-/g,""));
    	   
	 		commonUtil.msgConfirm("약품 사용하시겠습니까?", null, function(){
	 			netUtil.send({
	 				url : "/mobile/Mobile/PDA_INV04/json/datalist.data",
	 				param : param,
	 				successFunction : "saveSuccessCallBack3"
	 		   	});
	 		}, function(){
	 			$('#IND_BCD').focus();
	 		});	
       }
       
       function saveSuccessCallBack3(json){
    	   if(json&&json.data){
    		   PlaySound('s');
	 			commonUtil.msgBox("완료되었습니다.", null, null, function(){
	 				reset();
	 			});
	 		}
       }
       
		function reset(){
			$("#WRK_ORDR_NO").val('');
			$("#WRK_ORDR_SEQNO").val('');
			$("#MATNR_NM").val('');
			$("#INP_QTY").val('');
			$("#IND_BCD").val('');
			$("#IND_BCD").focus();
			
			var target1 = $('#list1');
			var add_data = '';
			
			add_data += '<tr><th class="fl">자재코드</th></tr>';
			add_data += '<tr><th class="fl">자재명</th></tr>';	
			add_data += '<tr><th class="fl">개별바코드</th></tr>';          	         			
			add_data += '<tr><th class="fl">LOT NO</th></tr>';          		        			
			add_data += '<tr><th class="fl">저장위치코드</th></tr>';          			        			
			add_data += '<tr><th class="fl">재고수량</th></tr>';          			         			
			add_data += '<tr><th class="fl">단위</th></tr>';          			
			   
			target1.html(add_data);
		}
       
       function fn_onfocus(objId){
     		$("#"+objId).select();
     	   }
       //작업조 선택
       function selectclass(){
    	   //mobile.linkPopOpen('/mobile/PDA_INV04_POP03.page');
    	   location.href = '/mobile/PDA_INV04_POP03.page?' + 'IND_BCD=' + $('#IND_BCD').val() + '&INP_QTY=' + $('#INP_QTY').val();
       }
       
	</script>
</head>
<body>
	<div class="main_wrap">
		<div class="main_header">
			<ul>
				<li class="tit" id="title" style="width:100%;">약품 투입</li>
			</ul>
		</div>
		<div class="tem4_content">
			<div class="select_box" id="bindArea">
				<div id="searchArea">
					<div style="display: none;">
						<input type="text" class="text" id="FLAG" name="FLAG" />
					</div>
					<table>
						<colgroup>
							<col width="90px" />
							<col />
						</colgroup>
						<tbody>
							<tr>
								<th class="fl">설비</th>
								<td colspan="2">
									<input type="text" class="text" id="MACH_CD" name="MACH_CD" style="text-align: center;" readonly/>
								</td>
							</tr>				
							<tr>
		                        <th class="fl" CL="STD_BARCOD">바코드</th>
		                        <td>
		                            <input type="text" class="text" name="IND_BCD" id="IND_BCD" placeholder="바코드스캔 및 입력" style='text-align:center;'
		                            onfocus="fn_onfocus(this.id)" onkeypress="commonUtil.enterKeyCheck(event, 'onReadBarcode()')" autocomplete="off"/>
		                        </td>
                    		</tr>
						</tbody>
					</table>
				</div>
				<table class="mg-10 bd-c1">
					<colgroup>
						<col width="30%" />
						<col width="70%" />
					</colgroup>
					<tbody id="list1">
						
						<tr>
	                        <th class="fl">자재코드</th>
	                        <td class="fl"></td>
	                    </tr>
	                    <tr>
	                        <th class="fl">자재명</th>
	                        <td class="fl"></td>
	                    </tr>
	                    <tr>
	                        <th class="fl">개별바코드</th>
	                        <td class="fl"></td>
	                    </tr>
	                    <tr>
	                        <th class="fl">LOT NO</th>
	                        <td class="fl"></td>
	                    </tr>
	                    <tr>
	                        <th class="fl">저장위치코드</th>
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
						<col width="30%" />
						<col width="70%" />
					</colgroup>
					<tbody id="list2">
						
					</tbody>
				</table>
			
			<div class="footer_4" style=" bottom: 105px; height: 185px;">
				<div class="select_box mg-20">
					<table>
						<colgroup>
							<col width="100px" />
							<col />
							<col />
							<col width="50px" />
						</colgroup>
						<tbody>
							<tr>
								<td class="fl fw">사용량 입력</td>
								<td colspan='2'>
									<input type="text" class="text" placeholder="자재 사용량 입력" id="INP_QTY" name="INP_QTY" onchange="changeQty();" style="text-align:center;" UIFormat='N 10,3'/>
								</td>
								<td>
									<input type="text" class="text"  id="UNIT" name="UNIT" readonly="readonly" placeholder="KG" onclick="unitselect();" style="text-align:center;"/>
								</td>
							</tr>
							<tr>
								<td class="fl fw">작업조</td>
								<td>									
									<input type="text" class="text" placeholder="작업 조 선택" id="WRK_METH" name="WRK_METH" style="text-align:center" readonly />
								</td>
								<td>									
									<input type="text" class="text" id="WRK_TIME" readonly style="text-align:center;"/>
								</td>
								<td>
									<input type="text" class="text" placeholder="선택" readonly="readonly" onclick="selectclass();" style="text-align:center;" />
								</td>
							</tr>
							
							<tr>
								<td class="fl fw">사용일자</td>
								<td colspan='2'>
									<input type="text" class="text" placeholder="사용일자 " style="width: 83%" id="INP_DATE" name="INP_DATE" UIFormat="C N" style="text-align:center;"/>
								</td>
							</tr>
							
						</tbody>
					</table>
				</div>
			</div>
		</div>
			
			<dd style="display:none;">
				<input type="text" class="input" id="WRK_ORDR_NO"/>	<!-- 작업지시순번 -->
				<input type="text" class="input" id="WRK_ORDR_SEQNO"/>	<!-- 작업지시순번 -->
				<input type="text" class="input" id="ORDER_NO"/>		<!-- 오더번호 -->
				<input type="text" class="input" id="MATNR"/>			<!-- 자재코드 -->
				<input type="text" class="input" id="MATNR_NM"/>		<!-- 자재명 -->
				<input type="text" class="input" id="STCK_STA"/>		<!-- 재고상태 -->
				<input type="text" class="input" id="STCK_QTY"/>		<!-- 재고수량 -->
				<input type="text" class="input" id="LOT_NO"/>		<!-- 재고수량 -->
				<input type="text" class="input" id="UNIT"/>		<!-- 재고수량 -->
				<input type="text" class="input" id="INP_DATE"/>		<!-- 재고수량 -->
				<input type="text" class="input" id="WRK_METH"/>		<!-- 재고수량 -->
			</dd>

			<!-- end table_body -->
			<div class="footer_5" style="position: fixed;">

				<table>
					<tr>
						<td class="f_1 btn-c1" onclick="Inpselect()" style="width: 33%"><label>사용이력</label></td>
						<td class="f_1" onclick="showMain();" style="width: 33%"><label CL='BTN_CLOSE'></label></td>
						<td class="f_1" onclick="matnrInp();" width="34%"><label>사용</label></td>
					</tr>
				</table>
			</div>
			<!-- end footer_5 -->
		</div>
	</div>
</body>