<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%
	String procCd = (String)request.getSession().getAttribute(CommonConfig.SES_PROC_CD);
	String machCd = (String)request.getSession().getAttribute(CommonConfig.SES_MACH_CD);
	String plant = (String)request.getSession().getAttribute(CommonConfig.SES_USER_PLANT_KEY);
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

    		$("#MACH_CD").val("<%=machCd%>");
    		
		    searchList();	// 작업지시, 작업지시 새로고침 
		});
		
        function searchList(){
  			var param = new DataMap();
  	
  			param.put("P_TYPE","SUB_LIST1");
  			param.put("WERKS", '<%=plant%>');
  			param.put("MACH_CD", "<%=machCd%>");

  			netUtil.send({
  				url : "/mobile/Mobile/PDA_INV05/json/datalist.data",
  				param : param,
  				successFunction : "saveSuccessCallBack1"
  			});
        }
	
	    function saveSuccessCallBack1(json, status){
	    	if(json && json.data){
	    		var value = json.data;
	    		
	    		$.each(value, function (index, item){
		    		$("#WRK_ORDR_NO").val(item.WRK_ORDR_NO);
		    		$("#WRK_ORDR_SEQNO").val(item.WRK_ORDR_SEQNO);
		    		$("#ORDER_NO").val(item.ORDER_NO);
		    		$("#MATNR_NM").val(item.MATNR_NM);
	    		});
	 		    
	    		$("#IND_BCD").focus();
	    		
	    		PlaySound("s");
			} else{
				PlaySound("e");
			}
	   }
	    
	   function linkPopCloseEvent(data){
		   $("#WRK_ORDR_NO").val(data.get("wrk_ordr_no"));
		   $("#WRK_ORDR_SEQNO").val(data.get("wrk_ordr_seqno"));
		   $("#MATNR_NM").val(data.get("matnr_nm"));
		   
		   $("#UNIT").val(data.get("UNIT"));
		   
		   $("#IND_BCD").focus();
       }
	   
       function showMain() {
           window.top.menuOpen();
       }

       function searchList2(){	// 작업지시 검색
    	   var param = new DataMap();

           param.put("MACH_CD", "<%=machCd%>");

           mobile.linkPopOpen('/mobile/PDA_INV05_POP01.page', param);
       }

       function onReadBarcode(){	// 바코드 스캔
    	   var param = new DataMap();
    	  	
 		   param.put("P_TYPE","LIST");
       	   param.put("WRK_ORDR_NO", $("#WRK_ORDR_NO").val());
 		   param.put("WRK_ORDR_SEQNO", $("#WRK_ORDR_SEQNO").val());
 		   param.put("IND_BCD", $("#IND_BCD").val());
 		   param.put("WERKS", '<%=plant%>');

 		   netUtil.send({
 			   url : "/mobile/Mobile/PDA_INV05/json/datalist.data",
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
  	 		   var target2 = $('#list2');
  	 		   var add_data = '';
	     	   var add_data2 = '';
	     	   
    		   if(json.data.length == 0){
    			   PlaySound("e");
    			   commonUtil.msgBox(configData.MSG_MASTER_ROWEMPTY);
      			   $("#IND_BCD").focus();
      			   target1.html(add_data);
	  	       	   target2.html(add_data2);
   			   	   return;
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
		       		  
		       		   add_data2 += '<tr><td class="fl">' + item.STCK_STA + '</td></tr>';
		       		   
		       		   $("#MATNR").val(item.MATNR);			
		       		   $("#MATNR_NM").val(item.MATNR_NM);	
		       	       $("#INP_QTY").val(item.STCK_QTY);	// 투입수량
		       	       $("#STCK_QTY").val(item.STCK_QTY);	// 재고수량
		       	       $("#UNIT").val(item.UNIT);
		       	       $("#STCK_STA").val(item.STCK_STA);
		       	   });
		       		
		       	   target1.html(add_data);
		       	   target2.html(add_data2);
		       	   $("#IND_BCD").focus();
      		   }
		   }
	   }
       
       function unitselect(){	// 단위 선택
    	   mobile.linkPopOpen('/mobile/UNITPOP.page');
       }
       
       function Inpselect(){	// 투입이력
    	   var param = new DataMap();
    		
       		param.put("MACH_CD", "<%=machCd%>");
       
    	   mobile.linkPopOpen('/mobile/PDA_INV05_POP02.page', param);
       }
       
       function changeQty(){	// 투입량 체크
    	   var stck_qty = $("#STCK_QTY").val();	// 재고수량
    	   var inp_qty = $("#INP_QTY").val();	
    	   
    	   if(Number(inp_qty) > Number(stck_qty)){
    		   alert("재고에 있는 수량만큼 투입가능합나다.");
    		   PlaySound('e');
    		   $("#IN_QTY").val('');
    	   }
       }
       
       function matnrInp(){
    	   var ind_bcd = $("#IND_BCD").val();
    	   
    	   if(ind_bcd == ""){
    		   alert("바코드를 스캔 또는 입력하세요.");
    		   return;
    	   }
    	   
		   var stck_sta = $("#STCK_STA").val();
    	   var stck_qty = $("#STCK_QTY").val();
		   
    	   if(Number(stck_qty) <= 0){
			   alert("투입수량을 입력하시기 바랍니다.");
			   PlaySound('e');
			   return;
		   } 
    	   
    	   var param = new DataMap();
   	  	
	 		param.put("P_TYPE","SAVE");
	 		param.put("IND_BCD", $("#IND_BCD").val());
	 		param.put("WERKS", '<%=plant%>');
	 		param.put("INPUT_QTY", $("#INP_QTY").val());	// 투입수량
	 		param.put("MACH_CD", "<%=machCd%>");
	 		param.put("WRK_ORDR_NO", $("#WRK_ORDR_NO").val());
	 		param.put("WRK_ORDR_SEQNO", $("#WRK_ORDR_SEQNO").val());
	 		param.put("MATNR", $("#MATNR").val());
	 		param.put("MATNR_NM", $("#MATNR_NM").val());
    	   
    	   if (stck_sta.indexOf('투입가능') == 0) {
		 		netUtil.send({
	 				url : "/mobile/Mobile/PDA_INV05/json/datalist.data",
	 				param : param,
	 				successFunction : "saveSuccessCallBack3"
	 		   	});	
			} else {	// 투입불가
				if(stck_sta == "투입불가(BOM)"){	// 강제투입
					mobile.linkPopOpen('/mobile/MESSAGEPOP.page', param);
				} else{
					alert("투입을 할 수 없는 상태입니다.");
					PlaySound('e');
				}
			}
       }
       
       function saveSuccessCallBack3(json){
    	   if(json&&json.data){
	 			alert("투입되었습니다.");
	 			PlaySound('s');
	 			
	 			$("#WRK_ORDR_NO").val('');
	 			$("#MATNR_NM").val('');
	 			$("#INP_QTY").val('');
	 			$('#list1').empty();
	 			$('#list2').empty();
        		$("#IND_BCD").focus();
        		$("#IND_BCD").val('');
	 		}
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
					<div style="display: none;">
						<input type="text" class="text" id="FLAG" name="FLAG" />
					</div>
					<table>
						<colgroup>
							<col width="90px" />
							<col />
							<col />
							<col width="100px" />
						</colgroup>
						<tbody>
							<!-- <tr>
								<th class="fl">설비</th>
								<td colspan="3">
									<select class="input" id="MACH_CD" name="MACH_CD" combo="mes,MACH2" style="text-align: center;">
									</select>
								</td>
							</tr> -->
							
							<tr>
								<th class="fl">설비</th>
								<td colspan="2">
									<input type="text" class="text" id="MACH_CD" name="MACH_CD" style="text-align: center;" readonly/></td>
								
							</tr>
							
							<tr>
								<th class="fl">작업지시</th>
								<td colspan="2">
									<input type="text" class="text" id="WRK_ORDR_NO" name="WRK_ORDR_NO" style="text-align: center;" readonly/></td>
								<td onclick="searchList2();">
									<button class="bt" style="height: 36px;">
										<p CL='BTN_FINDDATA'>검색</p>
									</button>
								</td>
							</tr>
							<tr>
								<th class="fl">품목명</th>
								<td colspan="2"><input type="text" class="text" readonly name="MATNR_NM" id="MATNR_NM"></td>
								<td rowspan="2">
									<button class="bt" style="height: 75px;" onclick="searchList()">작업지시<br>새로고침</button>
								</td>
							</tr>
							<tr>
								<th class="fl" CL="STD_BARCOD">바코드</th>
								<td colspan="2"><input type="text" class="text" placeholder="바코드 스캔 및 입력" id="IND_BCD" name="IND_BCD" onfocus="fn_onfocus(this.id)" onkeypress="commonUtil.enterKeyCheck(event, 'onReadBarcode()')" />
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
			
			<div class="footer_4" style=" bottom: 105px; height: 100px;">
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
								<td class="fl fw">투입량 입력</td>
								<td colspan="2">
									<input type="text" class="text" placeholder="자재 투입량 입력" id="INP_QTY" name="INP_QTY" onchange="changeQty();"/>
								</td>
								<td>
									<input type="text" class="text" placeholder="KG" id="UNIT" name="UNIT" readonly="readonly" onclick="unitselect();" style="text-align:center;"/>
								</td>
							</tr>
						</tbody>
					</table>
				</div>
			</div>
			</div>
			<dd style="display:none;">
				<input type="text" class="input" id="WRK_ORDR_SEQNO"/>	<!-- 작업지시순번 -->
				<input type="text" class="input" id="ORDER_NO"/>		<!-- 오더번호 -->
				<input type="text" class="input" id="MATNR"/>			<!-- 자재코드 -->
				<input type="text" class="input" id="MATNR_NM"/>		<!-- 자재명 -->
				<input type="text" class="input" id="STCK_STA"/>		<!-- 재고상태 -->
				<input type="text" class="input" id="STCK_QTY"/>		<!-- 재고수량 -->
			</dd>

			<!-- end table_body -->
			<div class="footer_5" style="position: fixed;">

				<table>
					<tr>
						<td class="f_1 btn-c1" onclick="Inpselect()" style="width: 33%"><label>투입이력</label></td>
						<td class="f_1" onclick="showMain();" style="width: 33%"><label CL='BTN_CLOSE'></label></td>
						<td class="f_1" onclick="matnrInp();" width="34%"><label>투입</label></td>
					</tr>
				</table>
			</div>
			<!-- end footer_5 -->
		</div>
	</div>
</body>