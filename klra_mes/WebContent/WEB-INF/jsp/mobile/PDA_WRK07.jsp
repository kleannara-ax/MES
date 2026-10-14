<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
	String plant = (String)request.getSession().getAttribute(CommonConfig.SES_USER_PLANT_KEY);
	String wrkordrno = request.getParameter("WRK_ORDR_NO");
	String indbcd = request.getParameter("IND_BCD");
	String storlocCd = request.getParameter("STOR_LOC_CD");
	String storlocnm = request.getParameter("STOR_LOC_NM");
	String locCd = request.getParameter("LOC_CD");
	String locnm = request.getParameter("LOC_NM");
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
		    $("#WERKS").val("<%=plant%>");
		    
		    if('<%=wrkordrno%>' != 'null'){
		    	$('#WRK_ORDR_NO').val('<%=wrkordrno%>');
		    }
		    if('<%=indbcd%>' != 'null'){
		    	$('#IND_BCD').val('<%=indbcd%>');
		    	onReadBarcode();
		    }
		    if('<%=wrkordrno%>' != 'null'){
		    	$('#WRK_ORDR_NO').val('<%=wrkordrno%>');
		    }
	    	
	    	if('<%=storlocCd%>' != 'null'){
	    		$('#STOR_LOC_CD').val('<%=storlocCd%>');
	    		$('#STOR_LOC_NM').val('<%=storlocnm%>');
	    	}
	    	if('<%=locCd%>' != 'null'){
	    		$('#LOC_CD').val('<%=locCd%>');
	    		$('#LOC_NM').val('<%=locnm%>');
	    	}
		});

        function showMain() {
            window.top.menuOpen();
        }
        
        function searchList(){	// 작업지시 검색
     	   	/* var param = new DataMap();

            param.put("WERKS", $("#WERKS").val());

            mobile.linkPopOpen('/mobile/PDA_WRK07_POP.page', param); */
            location.href = '/mobile/PDA_WRK07_POP01.page?';
        }
        
        function onReadBarcode(){	// 바코드 스캔
        	if($('#IND_BCD').val() == ''){
        		PlaySound("e");
        		commonUtil.msgBox('바코드를 스캔하세요.', null, null, function(){
        			$('#IND_BCD').focus();
        		});
        		return;
        	}
        
        	var ind_bcd = $('#IND_BCD').val();
        	var werks1 = '<%=plant%>';
            
 	        if (werks1 == 'P100'){
	        	if(ind_bcd.length > 10){
	     		   commonUtil.msgBox('존재하지 않는 바코드이므로 다시 스캔하세요.', null, null, function(){
	     			  $('#IND_BCD').focus(); 
	     		   });
	     		   return;
	       	   }
       		 }else
       		 {
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

  		   netUtil.send({
  			   url : "/mobile/Mobile/PDA_WRK07/json/datalist.data",
  			   param : param,
  			   successFunction : "saveSuccessCallBack"
  		   });
        }
        
        function saveSuccessCallBack(json){
        	var param = new DataMap();
            param.put("PROGID", "<%= menuId%>");
            param.put("LGTYPE", "SEARCH");
            var json2 = netUtil.sendData({
                url: "/mes/system/json/saveLog.data",
                param : param
            });
        	
			if(json && json.data){
     		   PlaySound("s");
 	    		
 	 		   var target1 = $('#list1');
 	     	   var value = json.data;
 	     	   var add_data = '';
 	     	    
				if(json.data.length == 0){
					PlaySound("e");
	  			   	commonUtil.msgBox(configData.MSG_MASTER_ROWEMPTY, null, null, function(){
		  			   	$("#IND_BCD").focus();
		 			   
						add_data += '<tr><th class="fl">자재코드</th></tr>';
						add_data += '<tr><th class="fl">자재명</th></tr>';	
						add_data += '<tr><th class="fl">개별바코드</th></tr>';          		  
						add_data += '<tr><th class="fl">저장위치코드</th></tr>';
						add_data += '<tr><th class="fl">저장위치명</th></tr>';
						add_data += '<tr><th class="fl">LOT NO</th></tr>';          		        	     			
						add_data += '<tr><th class="fl">재고수량</th></tr>'; 
						add_data += '<tr><th class="fl">단위</th></tr>'; 
						add_data += '<tr><th class="fl">생산일자</th></tr>';
						add_data += '<tr><th class="fl">실사수량</th></tr>'; 
		
						target1.html(add_data);
	  			   	});
				}else if(json.data.length == 1){
	   			   	PlaySound("s");
	 	     	   
					$.each(value, function (index, item){
						add_data += '<tr><th class="fl">자재코드</th>';
						add_data += '<td class="fl">' + item.MATNR + '</td></tr>';
						add_data += '<tr><th class="fl">자재명</th>';
						add_data += '<td class="fl">' + item.MATNR_NM + '</td></tr>';	
						add_data += '<tr><th class="fl">개별바코드</th>';          			
						add_data += '<td class="fl">' + item.IND_BCD + '</td></tr>';   
						add_data += '<tr><th class="fl">저장위치코드</th>';          			
						add_data += '<td class="fl">' + item.STOR_LOC_CD + '</td></tr>';
						add_data += '<tr><th class="fl">저장위치명</th>';          			
			   		   	add_data += '<td class="fl">' + item.STOR_LOC_NM + '</td></tr>'; 
						add_data += '<tr><th class="fl">LOT NO</th>';          			
						add_data += '<td class="fl">' + item.LOT_NO + '</td></tr>';          	     			
						add_data += '<tr><th class="fl">재고수량</th>';          			
						add_data += '<td class="fl">' + item.STCK_QTY + '</td></tr>';
						add_data += '<tr><th class="fl">단위</th>';          			
						add_data += '<td class="fl">' + item.UNIT + '</td></tr>'; 
						add_data += '<tr><th class="fl">생산일자</th>';          			
						add_data += '<td class="fl">' + item.PRFM_DT + '</td></tr>'; 
						add_data += '<tr><th class="fl">실사수량</th>'; 
						add_data += '<td class="fl">' + item.SIL_QTY + '</td></tr>';  
	 	       		  
	 	       		   	/* add_data2 += '<tr><td class="fl">' + item.STCK_STA + '</td></tr>'; */
	 	       		   
						$("#MATNR").val(item.MATNR);			
						$("#MATNR_NM").val(item.MATNR_NM);	
						//$('#STOR_LOC_CD').val(item.STOR_LOC_CD);
						$('#LOT_NO').val(item.LOT_NO);
						$("#STCK_QTY").val(item.STCK_QTY);	// 재고수량
						$("#REAL_INSP_QTY").val(item.SIL_QTY);	//실사수량
						$("#UNIT").val(item.UNIT);
						$("#UNIT_REAL").val(item.UNIT);
						$("#UNIT_GAP").val(item.UNIT);
						
						if('<%=storlocCd%>' != 'null'){
				    		$('#STOR_LOC_CD').val('<%=storlocCd%>');
				    		$('#STOR_LOC_NM').val('<%=storlocnm%>');
				    	}else{
				    		//$('#STOR_LOC_NM').val(item.STOR_LOC_NM);
				    	}
				    	if('<%=locCd%>' != 'null'){
				    		$('#LOC_CD').val('<%=locCd%>');
				    		$('#LOC_NM').val('<%=locnm%>');
				    	}else{
				    		//$('#LOC_CD').val(item.LOC_CD);
				    	}
						
				    	/* if($('#STOR_LOC_CD').val() == '2000'){
				    		if($('#LOC_CD').val() == 'L2600'){
								$('#LOC_NM').val('포장대기창고');
							}else if($('#LOC_CD').val() == 'L2800'){
								$('#LOC_NM').val('생산출고 대기창고');
							}else if($('#LOC_CD').val() == 'L2300'){
								$('#LOC_NM').val('원지포장 대기창고');
							}
				    	} */
					});
				}
	       	   	
				target1.html(add_data);
				
				$("#IND_BCD").focus();
 		   	} else{
	   			PlaySound("e");
	   		}
 	    }
        
        function searchList2(){	//저장위치 검색
     	   	/* if($('#IND_BCD').val() == ''){
     	   		commonUtil.msgBox('바코드를 스캔 또는 입력하세요.', null, null, function(){
     	   			$('#IND_BCD').focus();
     	   		});
     	   		return;
     	   	} */
			
     	   	var paramStr = 'WRK_ORDR_NO=' + $('#WRK_ORDR_NO').val();
		
            location.href = '/mobile/PDA_WRK07_POP02.page?' + paramStr;
        }
		
		function searchList3(){	//로케이션 검색
			/* if($('#IND_BCD').val() == ''){
				commonUtil.msgBox('바코드를 스캔 또는 입력하세요.', null, null, function(){
     	   			$('#IND_BCD').focus();
     	   		});
     	   		return;
     	   	} */
			if($('#STOR_LOC_CD').val() == '' || $('#STOR_LOC_NM').val() == ''){
				commonUtil.msg('저장위치를 먼저 선택하세요.');
				return;
			}
			if('<%=plant%>' != 'P100'){
				commonUtil.msg('제지 관리팀만 로케이션을 관리합니다.');
				return;
			}
			
			var paramStr = 'STOR_LOC_CD=' + $('#STOR_LOC_CD').val() + '&STOR_LOC_NM=' + $('#STOR_LOC_NM').val() + '&WRK_ORDR_NO=' + $('#WRK_ORDR_NO').val();
			
            location.href = '/mobile/PDA_WRK07_POP03.page?' + paramStr;
        }
        
        function qtyChange(){	// 재고수량 - 실사수량
        	var stck_qty = $("#STCK_QTY").val().replace(/,/g, '');	// 재고수량
        	var real_insp_qty = $("#REAL_INSP_QTY").val();	//실사수량
        	
        	if(!isNaN(Number(real_insp_qty))){
        		var gap_qty = (Number(stck_qty) - Number(real_insp_qty)).toFixed(3);
        		
            	$("#GAP_QTY").val(gap_qty);
        	}else{
        		return $("#REAL_INSP_QTY").val('');
        	}
	   	    if(Number(real_insp_qty) == 0 || real_insp_qty == ''){
				PlaySound('e');
				commonUtil.msgBox("재고실사 등록할 수량을 입력하세요.", null, null, function(){
	   			   	$("#REAL_INSP_QTY").val('');
					$('#REAL_INSP_QTY').focus();
					$("#GAP_QTY").val('');
	   		   	});
	   	   	}
	   	   	if(Number(real_insp_qty) < 0){
	   		   	PlaySound('e');
	   		   	commonUtil.msgBox("0보다 작게 등록할 수 없습니다.", null, null, function(){
	   			   	$("#REAL_INSP_QTY").val('');
					$('#REAL_INSP_QTY').focus();
					$("#GAP_QTY").val('');
	   		   	});
	   	   	}
        }
        //등록
        function qtyReg(){
        	if($('#WRK_ORDR_NO').val() == ''){
				commonUtil.msgBox('재고실사지시번호가 없습니다.', null, null, function(){
     	   			$('#IND_BCD').focus();
     	   		});
     	   		return;
     	   	}
        	
        	if($('#STOR_LOC_CD').val() == ''){
				commonUtil.msgBox('저장위치정보가 없습니다.', null, null, function(){
     	   			$('#IND_BCD').focus();
     	   		});
     	   		return;
     	   	}
        	
        	if($('#IND_BCD').val() == ''){
				commonUtil.msgBox('바코드를 스캔 또는 입력하세요.', null, null, function(){
     	   			$('#IND_BCD').focus();
     	   		});
     	   		return;
     	   	} 
        	
        	var real_insp_qty = $("#REAL_INSP_QTY").val();	//실사수량
        	
        	if(Number(real_insp_qty) <= 0){
        		PlaySound('e');
 			   commonUtil.msgBox("실사수량을 입력하시기 바랍니다.", null, null, function(){
 				  $('#REAL_INSP_QTY').focus(); 
 			   });
 			   return;
 		   }
        	
     	   var param = new DataMap();
    	  	
 	 		param.put("P_TYPE","SAVE");
 	 		param.put("IND_BCD", $("#IND_BCD").val());
 	 		param.put("WERKS", '<%=plant%>');
 	 		param.put("WRK_ORDR_NO", $("#WRK_ORDR_NO").val());
 	 		param.put("MATNR", $("#MATNR").val());
 	 		param.put('STOR_LOC_CD', $('#STOR_LOC_CD').val());
 	 		param.put('LOC_CD', $('#LOC_CD').val());
 	 		param.put('LOT_NO', $('#LOT_NO').val());
 	 		param.put("STCK_QTY", $("#STCK_QTY").val());
 	 		param.put("SIL_QTY", $("#REAL_INSP_QTY").val());		//실사수량
 	 		
 	 		commonUtil.msgConfirm('재고실사 등록하시겠습니까?', null, function(){
 	 			netUtil.send({
 	 				url : "/mobile/Mobile/PDA_WRK07/json/datalist.data",
 	 				param : param,
 	 				successFunction : "saveSuccessCallBack2"
 	 		   	});
 	 		}, function(){
 	 			$('#IND_BCD').focus();
 	 		});
        }

        function saveSuccessCallBack2(json){
        	if(json.P_SUCCESS == 'Y'){
       			$("#IND_BCD").focus();
           		$("#IND_BCD").val('');
           		
   				var target1 = $('#list1');
   	     	   	var value = json.data;
   	     	   	var add_data = '';
   	     	   	
   	     	 	add_data += '<tr><th class="fl">자재코드</th></tr>';
   				add_data += '<tr><th class="fl">자재명</th></tr>';	
   				add_data += '<tr><th class="fl">개별바코드</th></tr>';          		  
   				add_data += '<tr><th class="fl">저장위치코드</th></tr>';
   				add_data += '<tr><th class="fl">저장위치명</th></tr>';
   				add_data += '<tr><th class="fl">LOT NO</th></tr>';          		        	     			
   				add_data += '<tr><th class="fl">재고수량</th></tr>'; 
   				add_data += '<tr><th class="fl">단위</th></tr>'; 
   				add_data += '<tr><th class="fl">생산일자</th></tr>';
   				add_data += '<tr><th class="fl">실사수량</th></tr>';        			

   				target1.html(add_data);
   				
   				$("#STCK_QTY").val('');	// 재고수량
   				$("#REAL_INSP_QTY").val('');	//실사수량
   				$('#GAP_QTY').val('');	//차이수량
        	}else{
        		commonUtil.msgBox(json.ERR_MSG, null, null, function(){
        			$('#IND_BCD').focus();
        		});
        	}
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
			<li class="tit" id="title" style="width:100%;">공정재고실사</li>
		</ul>
	</div>
    <div class="tem4_content">
        <div class="select_box" id="bindArea">
            <div id="searchArea">
                <table>
                    <colgroup>
                        <col width="110px" />
                        <col />
                        <col width='115px'/>
                    </colgroup>
                    <tbody>
                    <tr>
                        <th class="fl" CL='재고실사지시'></th>
                        <td>
                            <input type="text" class="text" id="WRK_ORDR_NO" style="text-align: center;" readonly="readonly"/>
                        </td>
                        <td onclick ="searchList()">
                            <button class="bt" style="height:36px;">
                                <p CL='BTN_FINDDATA'></p>
                            </button>
                        </td>
                    </tr>
                    <tr>
						<th class="fl" CL="STD_BARCOD">바코드</th>
						<td colspan='3'>
							<input type="text" class="text" placeholder="바코드 스캔 및 입력" id="IND_BCD" onfocus="fn_onfocus(this.id)" style="text-align: center;" name="IND_BCD" 
							onkeypress="commonUtil.enterKeyCheck(event, 'onReadBarcode()')" autocomplete="off"/>
						</td>
					</tr>
                    <tr>
	                    <th class="fl" CL='저장위치'>저장위치</th>
	                    <td>
	                    	<input type="text" class="text" id="STOR_LOC_NM" autocomplete="off"/>
	                    </td>
	                    <td>
	                    	<button class='bt' style="text-align: center;height: 36px;" onclick='searchList2();'>
	                    		<p>저장위치</p>
	                    	</button>
	                    </td>
	                </tr>
	                <tr>
	                    <th class="fl" CL='로케이션'>로케이션</th>
	                    <td>
	                    	<input type="text" class="text" id="LOC_NM" autocomplete="off"/>
	                    </td>
	                    <td>
	                    	<button class='bt' placeholder="로케이션" style="text-align: center;height: 36px;" onclick='searchList3();'>
	                    		<p>로케이션</p>
	                    	</button>
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
	                        <th class="fl">저장위치코드</th>
	                        <td class="fl"></td>
	                    </tr>
	                    <tr>
	                        <th class="fl">저장위치명</th>
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
	                    <tr>
	                        <th class="fl">생산일자</th>
	                        <td class="fl"></td>
	                    </tr>
	                    <tr>
	                        <th class="fl">실사수량</th>
	                        <td class="fl"></td>
	                    </tr>
                    </tbody>
                </table>
            </div>
        </div>

		<dd style="display:none;">
			<input type="text" class="input" id="MATNR"/>			<!-- 자재코드 -->
			<input type='text' class='input' id='STOR_LOC_CD' />	<!-- 저장위치코드 -->
			<input type='text' class='input' id='LOC_CD' />			<!-- 로케이션코드 -->
			<input type='text' class='input' id='LOT_NO'/>			<!-- LOT번호 -->
		</dd>

		<div class='footer_4' style="height: 175px;">
			<div class="select_box mg-20">
	            <table>
	                <colgroup>
	                    <col width="120px"/>
	                    <col/>
	                    <col/>
	                    <col width="120px"/>
	                </colgroup>
	                <tbody>
	                <tr>
	                    <td class="fl fw">재고수량</td>
	                    <td colspan="2">
	                    	<input type="text" class="text" placeholder="현재 정상 수량을 조회" id="STCK_QTY" readonly="readonly"/>
	                    </td>
	                    <td>
	                    	<input type="text" class="text" placeholder="KG" id="UNIT" readonly="readonly" style="text-align: center;"/>
	                    </td>
	                </tr>
	                <tr>
	                    <td class="fl fw">실사수량</td>
	                    <td colspan="2">
	                    	<input type="text" class="text" placeholder="수정할 수량을 입력" id="REAL_INSP_QTY" onchange="qtyChange();" autocomplete="off"/>
	                    </td>
	                    <td>
	                    	<input type="text" class="text" placeholder="KG" id="UNIT_REAL" readonly="readonly" style="text-align: center;"/>
	                    </td>
	                </tr>
	                <tr>
	                    <td class="fl fw">차이수량</td>
	                    <td colspan="2">
	                    	<input type="text" class="text" id="GAP_QTY" readonly="readonly"/>
	                    </td>
	                    <td>
	                    	<input type="text" class="text" placeholder="KG" id="UNIT_GAP" readonly="readonly" style="text-align: center;"/>
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
                    <td class="f_1" onclick ="showMain()" style="width:50%"><label CL='BTN_CLOSE'></label></td>
                    <td class="f_1" onclick ="qtyReg()" style="width:50%"><label>등록</label></td>
                </tr>
            </table>
        </div><!-- end footer_5 -->
    </div>
</div>
</body>