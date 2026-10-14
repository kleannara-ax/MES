<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
	String plant = (String)request.getSession().getAttribute(CommonConfig.SES_USER_PLANT_KEY);
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
        	$('#IND_BCD').focus();
        	$("#WERKS").val("<%=plant%>");
		    
		    if('<%=indbcd%>' != 'null'){
		    	$('#IND_BCD').val('<%=indbcd%>');
		    	
		    	if('<%=storlocCd%>' != 'null'){
		    		$('#STOR_LOC_CD').val('<%=storlocCd%>');
		    		$('#STOR_LOC_NM').val('<%=storlocnm%>');
		    	}
		    	if('<%=locCd%>' != 'null'){
		    		$('#LOC_CD').val('<%=locCd%>');
		    		$('#LOC_NM').val('<%=locnm%>');
		    	}
		    	onReadBarcode();
		    }
		});

        function showMain() {
            window.top.menuOpen();
        }
        
        function onReadBarcode(){	// 바코드 스캔
        	if($('#IND_BCD').val() == ''){
        		commonUtil.msgBox('바코드를 스캔하세요', null, null, function(){
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
        	
     	   /*var param = new DataMap();
     	  	
  		   param.put("P_TYPE", "LIST");
  		   param.put("IND_BCD", $("#IND_BCD").val());
  		   
  		   netUtil.send({
  			   url : "/mobile/Mobile/PDA_WRK12/json/datalist.data",
  			   param : param,
  			   successFunction : "saveSuccessCallBack"
  		   }); */
  		   
			qtyReg();
        }
        
        function saveSuccessCallBack(json){
			if(json && json.data){
     		   PlaySound("s");
 	    		
     		  var param = new DataMap();
              param.put("PROGID", "<%= menuId%>");
              param.put("LGTYPE", "SEARCH");
              var json2 = netUtil.sendData({
                  url: "/mes/system/json/saveLog.data",
                  param : param
              });
     		   
 	 		   var target1 = $('#list1');
 	     	   var value = json.data;
 	     	   var add_data = '';
 	     	   
				if(json.data.length == 0){
					PlaySound("e");
	  			   	commonUtil.msgBox(configData.MSG_MASTER_ROWEMPTY, null, null, function(){
						$("#IND_BCD").focus();
	    			
				   		add_data += '<tr><th class="fl">플랜트</th></tr>';
						add_data += '<tr><th class="fl">설비코드</th></tr>';
						add_data += '<tr><th class="fl">저장위치</th></tr>';	
						add_data += '<tr><th class="fl">자재코드</th></tr>';          		  
						add_data += '<tr><th class="fl">LOT번호</th></tr>';
						add_data += '<tr><th class="fl">개별바코드</th></tr>';
						add_data += '<tr><th class="fl">오더번호</th></tr>';          		        	     			
						add_data += '<tr><th class="fl">생산호기</th></tr>'; 
						add_data += '<tr><th class="fl">공정</th></tr>'; 
						add_data += '<tr><th class="fl">생산일자</th></tr>';
						add_data += '<tr><th class="fl">제조일자</th></tr>';
						add_data += '<tr><th class="fl">유통기간</th></tr>';
						add_data += '<tr><th class="fl">지종</th></tr>';
						add_data += '<tr><th class="fl">단위</th></tr>';
						add_data += '<tr><th class="fl">실적_권치수/M</th></tr>';
						add_data += '<tr><th class="fl">실적_연수_REAM</th></tr>';
						add_data += '<tr><th class="fl">실적_속당매수/EA</th></tr>';
						add_data += '<tr><th class="fl">실적_속수</th></tr>';
						add_data += '<tr><th class="fl">실적_중량</th></tr>';
						add_data += '<tr><th class="fl">지관</th></tr>';
						add_data += '<tr><th class="fl">평량</th></tr>';
						add_data += '<tr><th class="fl">포장타입</th></tr>';
						add_data += '<tr><th class="fl">컨테이너유형</th></tr>';
						add_data += '<tr><th class="fl">가로길이</th></tr>';
						add_data += '<tr><th class="fl">세로길이</th></tr>';
						add_data += '<tr><th class="fl">지폭</th></tr>';
						add_data += '<tr><th class="fl">판매문서번호</th></tr>';
						add_data += '<tr><th class="fl">판매문서항목번호</th></tr>';
						add_data += '<tr><th class="fl">판매처_MTO</th></tr>';
						add_data += '<tr><th class="fl">라벨병합여부</th></tr>';
						add_data += '<tr><th class="fl">작업반</th></tr>';
						add_data += '<tr><th class="fl">작업조</th></tr>';
		
						target1.html(add_data);
	  			   	});
				}else if(json.data.length == 1){
	   			   	PlaySound("s");
	   			   	
					$.each(value, function (index, item){
						add_data += '<tr><th class="fl">플랜트</th>';
						add_data += '<td class="fl">' + item.WERKS + '</td></tr>';
						add_data += '<tr><th class="fl">설비코드</th>';
						add_data += '<td class="fl">' + item.MACH_CD + '</td></tr>';
						add_data += '<tr><th class="fl">저장위치</th>';	
						add_data += '<td class="fl">' + item.STOR_LOC_CD + '</td></tr>';
						add_data += '<tr><th class="fl">자재코드</th>';         
						add_data += '<td class="fl">' + item.MATNR + '</td></tr>';				
						add_data += '<tr><th class="fl">LOT번호</th>';
						add_data += '<td class="fl">' + item.LOT_NO + '</td></tr>';
						add_data += '<tr><th class="fl">개별바코드</th>';
						add_data += '<td class="fl">' + item.IND_BCD + '</td></tr>';
						add_data += '<tr><th class="fl">오더번호</th>';   
						add_data += '<td class="fl">' + item.ORDER_NO + '</td></tr>';				
						add_data += '<tr><th class="fl">생산호기</th>'; 
						add_data += '<td class="fl">' + item.MACHINE + '</td></tr>';
						add_data += '<tr><th class="fl">공정</th>'; 
						add_data += '<td class="fl">' + item.PROC_CD + '</td></tr>';
						add_data += '<tr><th class="fl">생산일자</th>';
						add_data += '<td class="fl">' + item.PRD_DT + '</td></tr>';
						add_data += '<tr><th class="fl">제조일자</th>';
						add_data += '<td class="fl">' + item.PRFM_DT + '</td></tr>';
						add_data += '<tr><th class="fl">유통기간</th>';
						add_data += '<td class="fl">' + item.DSTBT_DDLIN + '</td></tr>';
						add_data += '<tr><th class="fl">지종</th>';
						add_data += '<td class="fl">' + item.PCODE + '</td></tr>';
						add_data += '<tr><th class="fl">단위</th>';
						add_data += '<td class="fl">' + item.UNIT + '</td></tr>';
						add_data += '<tr><th class="fl">실적_권치수</th>';
						add_data += '<td class="fl">' + item.ROLLCNT + '</td></tr>';
						add_data += '<tr><th class="fl">실적_연수_REAM</th>';
						add_data += '<td class="fl">' + item.PCNT + '</td></tr>';
						add_data += '<tr><th class="fl">실적_속당매수</th>';
						add_data += '<td class="fl">' + item.SCNT + '</td></tr>';
						add_data += '<tr><th class="fl">실적_속수</th>';
						add_data += '<td class="fl">' + item.MCNT + '</td></tr>';
						add_data += '<tr><th class="fl">실적_중량</th>';
						add_data += '<td class="fl">' + item.WGT + '</td></tr>';
						add_data += '<tr><th class="fl">지관</th>';
						add_data += '<td class="fl">' + item.CORE + '</td></tr>';
						add_data += '<tr><th class="fl">평량</th>';
						add_data += '<td class="fl">' + item.BS_WGT + '</td></tr>';
						add_data += '<tr><th class="fl">포장타입</th>';
						add_data += '<td class="fl">' + item.PACKTYPE + '</td></tr>';
						add_data += '<tr><th class="fl">컨테이너유형</th>';
						add_data += '<td class="fl">' + item.CONTYPE + '</td></tr>';
						add_data += '<tr><th class="fl">가로길이</th>';
						add_data += '<td class="fl">' + item.WLEN + '</td></tr>';
						add_data += '<tr><th class="fl">세로길이</th>';
						add_data += '<td class="fl">' + item.VLEN + '</td></tr>';
						add_data += '<tr><th class="fl">지폭</th>';
						add_data += '<td class="fl">' + item.WIDTH + '</td></tr>';
						add_data += '<tr><th class="fl">판매문서번호</th>';
						add_data += '<td class="fl">' + item.VBELN + '</td></tr>';
						add_data += '<tr><th class="fl">판매문서항목번호</th>';
						add_data += '<td class="fl">' + item.POSNR + '</td></tr>';
						add_data += '<tr><th class="fl">판매처_MTO</th>';
						add_data += '<td class="fl">' + item.KUNNR + '</td></tr>';
						add_data += '<tr><th class="fl">라벨병합여부</th>';
						add_data += '<td class="fl">' + item.MRG_YN + '</td></tr>';
						add_data += '<tr><th class="fl">작업반</th>';
						add_data += '<td class="fl">' + item.WRK_CLASS + '</td></tr>';
						add_data += '<tr><th class="fl">작업조</th>';
						add_data += '<td class="fl">' + item.WRK_SHIFT + '</td></tr>';
	 	       		   	
						$('#WERKS').val(item.WERKS);
						$('#MACH_CD').val(item.MACH_CD);
						$('#STOR_LOC_CD').val(item.STOR_LOC_CD);
						
						if('<%=storlocCd%>' != 'null'){
				    		$('#STOR_LOC_CD').val('<%=storlocCd%>');
				    		$('#STOR_LOC_NM').val('<%=storlocnm%>');
				    	}else{
				    		$('#STOR_LOC_NM').val(item.STOR_LOC_NM);
				    	}
				    	if('<%=locCd%>' != 'null'){
				    		$('#LOC_CD').val('<%=locCd%>');
				    		$('#LOC_NM').val('<%=locnm%>');
				    	}else{
				    		$('#LOC_CD').val(item.LOC_CD);
				    	}
						
				    	if($('#STOR_LOC_CD').val() == '2000'){
				    		if($('#LOC_CD').val() == 'L2600'){
								$('#LOC_NM').val('포장대기창고');
							}else if($('#LOC_CD').val() == 'L2800'){
								$('#LOC_NM').val('생산출고 대기창고');
							}else if($('#LOC_CD').val() == 'L2300'){
								$('#LOC_NM').val('원지포장 대기창고');
							}
				    	}
						
						$("#MATNR").val(item.MATNR);	
						$('#LOT_NO').val(item.LOT_NO);
						$('#IND_BCD').val(item.IND_BCD);
						$('#ORDER_NO').val(item.ORDER_NO);
						$('#MACHINE').val(item.MACHINE);
						$('#PROC_CD').val(item.PROC_CD);
						$('#PRD_DT').val(item.PRD_DT);
						$('#PRFM_DT').val(item.PRFM_DT);
						$('#DSTBT_DDLIN').val(item.DSTBT_DDLIN);
						$('#PCODE').val(item.PCODE);
						$('#UNIT').val(item.UNIT);
						$('#ROLLCNT').val(item.ROLLCNT);
						$('#PCNT').val(item.PCNT);
						$('#SCNT').val(item.SCNT);
						$('#MCNT').val(item.MCNT);
						$('#WGT').val(item.WGT);
						$('#CORE').val(item.CORE);
						$('#BS_WGT').val(item.BS_WGT);
						$('#PACKTYPE').val(item.PACKTYPE);
						$('#CONTYPE').val(item.CONTYPE);
						$('#WLEN').val(item.WLEN);
						$('#VLEN').val(item.VLEN);
						$('#WIDTH').val(item.WIDTH);
						$('#VBELN').val(item.VBELN);
						$('#POSNR').val(item.POSNR);
						$('#KUNNR').val(item.KUNNR);
						$('#MRG_YN').val(item.MRG_YN);
						$('#WRK_CLASS').val(item.WRK_CLASS);
						$('#WRK_SHIFT').val(item.WRK_SHIFT);
						
						if($('#UNIT').val() == 'KG'){
							$('#STCK_QTY').val(item.WGT);
							$('#INPUT_QTY').val(item.WGT);
						}else if($('#UNIT').val() == 'M'){
							$('#STCK_QTY').val(item.ROLLCNT);
							$('#INPUT_QTY').val(item.ROLLCNT);
						}else if($('#UNIT').val() == 'EA'){
							$('#STCK_QTY').val(item.SCNT);
							$('#INPUT_QTY').val(item.SCNT);
						}else{
							$('#STCK_QTY').val(item.PCNT);
							$('#INPUT_QTY').val(item.PCNT);
						}
						
						$('#UNIT_REAL').val(item.UNIT);
					});
					target1.html(add_data);
					
					$("#IND_BCD").focus();
				}
 		   	} else{
	   			PlaySound("e");
	   		}
 	    }
        
		function searchList(){	//저장위치 검색
     	   	if($('#IND_BCD').val() == ''){
     	   		commonUtil.msgBox('바코드를 스캔 또는 입력하세요.', null, null, function(){
     	   			$('#IND_BCD').focus();
     	   		});
     	   		return;
     	   	}
			
     	   	var paramStr = 'IND_BCD=' + $('#IND_BCD').val();
		
            location.href = '/mobile/PDA_WRK12_POP01.page?' + paramStr;
        }
		
		function searchList2(){	//로케이션 검색
			if($('#IND_BCD').val() == ''){
				commonUtil.msgBox('바코드를 스캔 또는 입력하세요.', null, null, function(){
     	   			$('#IND_BCD').focus();
     	   		});
     	   		return;
     	   	}
			if($('#STOR_LOC_CD').val() == '' || $('#STOR_LOC_NM').val() == ''){
				commonUtil.msg('저장위치를 먼저 선택하세요.');
				return;
			}
			if('<%=plant%>' != 'P100'){
				commonUtil.msg('제지 관리팀만 로케이션을 관리합니다.');
				return;
			}
			
			var paramStr = 'IND_BCD=' + $('#IND_BCD').val() + '&STOR_LOC_CD=' + $('#STOR_LOC_CD').val() + '&STOR_LOC_NM=' + $('#STOR_LOC_NM').val();
			
            location.href = '/mobile/PDA_WRK12_POP02.page?' + paramStr;
        }
        
		function changeQty(){	// 투입량 체크
    	   var stck_qty = $("#STCK_QTY").val();	// 재고수량
    	   var inp_qty = $("#INPUT_QTY").val();	
    	   
    	   if(Number(inp_qty) > Number(stck_qty)){
    		   PlaySound('e');
    		   commonUtil.msgBox("PIS재고에 있는 수량만큼 재고실사 등록가능합니다.", null, null, function(){
					$("#INPUT_QTY").val('');
					$('#INPUT_QTY').focus();
    		   });
    	   }
    	   if(Number(inp_qty) == 0 || inp_qty == ''){
    		   PlaySound('e');
    		   commonUtil.msgBox("재고실사 등록할 수량을 입력하세요.", null, null, function(){
    			   	$("#INPUT_QTY").val('');
					$('#INPUT_QTY').focus();
    		   });
    	   }
    	   if(Number(inp_qty) < 0){
    		   PlaySound('e');
    		   commonUtil.msgBox("0보다 작게 등록할 수 없습니다.", null, null, function(){
    			   	$("#INPUT_QTY").val('');
					$('#INPUT_QTY').focus();
    		   });
    	   }
       }
		
        //등록
        function qtyReg(){
        	if($('#IND_BCD').val() == ''){
        		commonUtil.msgBox('바코드를 스캔하세요.', null, null, function(){
        			$('#IND_BCD').focus();	
        		});
        		return;
        	}
        	
        	/* if($('#STOR_LOC_CD').val() == '' || $('#STOR_LOC_NM').val() == ''){
				commonUtil.msg('저장위치를 먼저 선택하세요.');
				return;
			} */
        	
        	/* if($('#IND_BCD').val().length < 10 || $('#IND_BCD').val().length >= 20){
        		commonUtil.msgBox('데이터가 없는 바코드이므로 바코드를 다시 스캔하세요.', null, null, function(){
        			$('#IND_BCD').val('');
            		$('#IND_BCD').focus();
        		});
        		return;
        	}  */
        	
   	   		var param = new DataMap();
    	  	
 	 		param.put("P_TYPE", "SAVE");
 	 		param.put("IND_BCD", $("#IND_BCD").val());
 	 		param.put('WERKS', $('#WERKS').val());
			param.put('MACH_CD', $('#MACH_CD').val());
			param.put('STOR_LOC_CD', $('#STOR_LOC_CD').val());
			param.put('LOC_CD', $('#LOC_CD').val());
			param.put('MATNR', $("#MATNR").val());	
			param.put('LOT_NO', $('#LOT_NO').val());
			param.put('ORDER_NO', $('#ORDER_NO').val());
			param.put('MACHINE', $('#MACHINE').val());
			param.put('PROC_CD', $('#PROC_CD').val());
			param.put('PRD_DT', $('#PRD_DT').val());
			param.put('PRFM_DT', $('#PRFM_DT').val());
			param.put('DSTBT_DDLIN', $('#DSTBT_DDLIN').val());
			param.put('PCODE', $('#PCODE').val());
			param.put('UNIT', $('#UNIT').val());
			param.put('PCNT', $('#PCNT').val());
			param.put('MCNT', $('#MCNT').val());
			
			if($('#UNIT').val() == 'KG'){
				param.put('WGT', $("#INPUT_QTY").val());
			}else if($('#UNIT').val() == 'M'){
				param.put('ROLLCNT', $("#INPUT_QTY").val());
			}else if($('#UNIT').val() == 'EA'){
				param.put('SCNT', $("#INPUT_QTY").val());
			}else{
				param.put('PCNT', $("#INPUT_QTY").val());
			}
			param.put('CORE', $('#CORE').val());
			param.put('BS_WGT', $('#BS_WGT').val());
			param.put('PACKTYPE', $('#PACKTYPE').val());
			param.put('CONTYPE', $('#CONTYPE').val());
			param.put('WLEN', $('#WLEN').val());
			param.put('VLEN', $('#VLEN').val());
			param.put('WIDTH', $('#WIDTH').val());
			param.put('VBELN', $('#VBELN').val());
			param.put('POSNR', $('#POSNR').val());
			param.put('KUNNR', $('#KUNNR').val());
			param.put('MRG_YN', $('#MRG_YN').val());
			param.put('WRK_CLASS', $('#WRK_CLASS').val());
			param.put('WRK_SHIFT', $('#WRK_SHIFT').val());
 	 		
 	 		commonUtil.msgConfirm('등록하시겠습니까?', null, function(){
 	 			netUtil.send({
 	 				url : "/mobile/Mobile/PDA_WRK12/json/datalist.data",
 	 				param : param,
 	 				successFunction : "saveSuccessCallBack2"
 	 		   	});
 	 		}, function(){
 	 			$('#IND_BCD').focus();
 	 		});
        }

        function saveSuccessCallBack2(json){
        	if(json.P_SUCCESS == 'Y'){
        		commonUtil.msgBox("재고실사 등록되었습니다.", null, null, function(){
        			$("#IND_BCD").focus();
            		$("#IND_BCD").val('');
            		$('#STCK_QTY').val('');
            		$('#INPUT_QTY').val('');
            		$('#STOR_LOC_CD').val('');
            		$('#STOR_LOC_NM').val('');
            		$('#LOC_CD').val('');
            		$('#LOC_NM').val('');
            		
    				var target1 = $('#list1');
      	     	   	var value = json.data;
      	     	   	var add_data = '';
      	     	   	
      	     	 	add_data += '<tr><th class="fl">플랜트</th></tr>';
    				add_data += '<tr><th class="fl">설비코드</th></tr>';
    				add_data += '<tr><th class="fl">저장위치</th></tr>';	
    				add_data += '<tr><th class="fl">자재코드</th></tr>';          		  
    				add_data += '<tr><th class="fl">LOT번호</th></tr>';
    				add_data += '<tr><th class="fl">개별바코드</th></tr>';
    				add_data += '<tr><th class="fl">오더번호</th></tr>';          		        	     			
    				add_data += '<tr><th class="fl">생산호기</th></tr>'; 
    				add_data += '<tr><th class="fl">공정</th></tr>'; 
    				add_data += '<tr><th class="fl">생산일자</th></tr>';
    				add_data += '<tr><th class="fl">제조일자</th></tr>';
    				add_data += '<tr><th class="fl">유통기간</th></tr>';
    				add_data += '<tr><th class="fl">지종</th></tr>';
    				add_data += '<tr><th class="fl">단위</th></tr>';
    				add_data += '<tr><th class="fl">실적_권치수/M</th></tr>';
    				add_data += '<tr><th class="fl">실적_연수_REAM</th></tr>';
    				add_data += '<tr><th class="fl">실적_속당매수/EA</th></tr>';
    				add_data += '<tr><th class="fl">실적_속수</th></tr>';
    				add_data += '<tr><th class="fl">실적_중량</th></tr>';
    				add_data += '<tr><th class="fl">지관</th></tr>';
    				add_data += '<tr><th class="fl">평량</th></tr>';
    				add_data += '<tr><th class="fl">포장타입</th></tr>';
    				add_data += '<tr><th class="fl">컨테이너유형</th></tr>';
    				add_data += '<tr><th class="fl">가로길이</th></tr>';
    				add_data += '<tr><th class="fl">세로길이</th></tr>';
    				add_data += '<tr><th class="fl">지폭</th></tr>';
    				add_data += '<tr><th class="fl">판매문서번호</th></tr>';
    				add_data += '<tr><th class="fl">판매문서항목번호</th></tr>';
    				add_data += '<tr><th class="fl">판매처_MTO</th></tr>';
    				add_data += '<tr><th class="fl">라벨병합여부</th></tr>';
    				add_data += '<tr><th class="fl">작업반</th></tr>';
    				add_data += '<tr><th class="fl">작업조</th></tr>';       			

    				target1.html(add_data);
        		});
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
    <div class="tem4_content" style='::-webkit-scrollbar {display:none;}'>
        <div class="select_box" id="bindArea">
            <div id="searchArea">
            	<dl style='text-align:center; font-size:30px;'>기초샛업 재고실사</dl>
                <table>
                    <colgroup>
                        <col width="120px" />
                    </colgroup>
                    <tbody>
	                    <tr>
							<th class="fl" CL="STD_BARCOD">바코드</th>
							<td>
								<input type="text" class="text" placeholder="바코드 스캔 및 입력" id="IND_BCD" onfocus="fn_onfocus(this.id)" style="width:100%;text-align: center;" 
								onkeypress="commonUtil.enterKeyCheck(event, 'onReadBarcode()')" autocomplete="off"/>
							</td>
						</tr>
                    </tbody>
                </table>
			</div>
		</div>
		<div style="height: 290px;">
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
	                    	<input type="text" class="text" placeholder="KG" name="UNIT" id="UNIT" readonly="readonly" style="text-align: center;"/>
	                    </td>
	                </tr>
	                <tr>
	                    <td class="fl fw">실사수량</td>
	                    <td colspan="2">
	                    	<input type="text" class="text" placeholder="수정할 수량을 입력" id="INPUT_QTY" onchange="changeQty();"/>
	                    </td>
	                    <td>
	                    	<input type="text" class="text" placeholder="KG" id="UNIT_REAL" readonly="readonly" style="text-align: center;"/>
	                    </td>
	                </tr>
	                <tr>
	                    <td class="fl fw">저장위치</td>
	                    <td colspan="2">
	                    	<input type="text" class="text" id="STOR_LOC_NM"/>
	                    </td>
	                    <td>
	                    	<input type="text" class="text" placeholder="저장위치 검색" style="text-align: center;" readonly="readonly" onclick='searchList();'/>
	                    </td>
	                </tr>
	                <tr>
	                    <td class="fl fw">로케이션</td>
	                    <td colspan="2">
	                    	<input type="text" class="text" id="LOC_NM"/>
	                    </td>
	                    <td>
	                    	<input type="text" class="text" placeholder="로케이션 검색" style="text-align: center;" readonly="readonly" onclick='searchList2();'/>
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
		                 <th class="fl">플랜트</th>
		                 <td class="fl"></td>
		             </tr>
		           		<tr>
		                 <th class="fl">설비코드</th>
		                 <td class="fl"></td>
		             </tr>
		             <tr>
		                 <th class="fl">저장위치</th>
		                 <td class="fl"></td>
		             </tr>
		             <tr>
		                 <th class="fl">자재코드</th>
		                 <td class="fl"></td>
		             </tr>
		             <tr>
		                 <th class="fl">LOT번호</th>
		                 <td class="fl"></td>
		             </tr>
		             <tr>
		                 <th class="fl">개별바코드</th>
		                 <td class="fl"></td>
		             </tr>
		             <tr>
		                 <th class="fl">오더번호</th>
		                 <td class="fl"></td>
		             </tr>
		             <tr>
		                 <th class="fl">생산호기</th>
		                 <td class="fl"></td>
		             </tr>
		             <tr>
		                 <th class="fl">공정</th>
		                 <td class="fl"></td>
		             </tr>
		             <tr>
		                 <th class="fl">생산일자</th>
		                 <td class="fl"></td>
		             </tr>
		             <tr>
		                 <th class="fl">제조일자</th>
		                 <td class="fl"></td>
		             </tr>
		             <tr>
		                 <th class="fl">유통기간</th>
		                 <td class="fl"></td>
		             </tr>
		             <tr>
		                 <th class="fl">지종</th>
		                 <td class="fl"></td>
		             </tr>
		             <tr>
		                 <th class="fl">단위</th>
		                 <td class="fl"></td>
		             </tr>
		             <tr>
		                 <th class="fl">실적_권치수</th>
		                 <td class="fl"></td>
		             </tr>
		             <tr>
		                 <th class="fl">실적_연수_REAM</th>
		                 <td class="fl"></td>
		             </tr>
		             <tr>
		                 <th class="fl">실적_속당매수</th>
		                 <td class="fl"></td>
		             </tr>
		             <tr>
		                 <th class="fl">실적_속수</th>
		                 <td class="fl"></td>
		             </tr>
		             <tr>
		                 <th class="fl">실적_중량</th>
		                 <td class="fl"></td>
		             </tr>
		             <tr>
		                 <th class="fl">지관</th>
		                 <td class="fl"></td>
		             </tr>
		             <tr>
		                 <th class="fl">평량</th>
		                 <td class="fl"></td>
		             </tr>
		             <tr>
		                 <th class="fl">포장타입</th>
		                 <td class="fl"></td>
		             </tr>
		             <tr>
		                 <th class="fl">컨테이너유형</th>
		                 <td class="fl"></td>
		             </tr>
		             <tr>
		                 <th class="fl">가로길이</th>
		                 <td class="fl"></td>
		             </tr>
		             <tr>
		                 <th class="fl">세로길이</th>
		                 <td class="fl"></td>
		             </tr>
		             <tr>
		                 <th class="fl">지폭</th>
		                 <td class="fl"></td>
		             </tr>
		             <tr>
		                 <th class="fl">판매문서번호</th>
		                 <td class="fl"></td>
		             </tr>
		             <tr>
		                 <th class="fl">판매문서항목번호</th>
		                 <td class="fl"></td>
		             </tr>
		             <tr>
		                 <th class="fl">판매처_MTO</th>
		                 <td class="fl"></td>
		             </tr>
		             <tr>
		                 <th class="fl">라벨병합여부</th>
		                 <td class="fl"></td>
		             </tr>
		             <tr>
		                 <th class="fl">작업반</th>
		                 <td class="fl"></td>
		             </tr>
		             <tr>
		                 <th class="fl">작업조</th>
		                 <td class="fl"></td>
		             </tr>
		            </tbody>
		        </table>
        	</div>
		</div>

		<dd style="display:none;">
			<input type='text' class='input' id="WERKS"/> 
			<input type='text' class='input' id="MACH_CD"/>                      		    
			<input type='text' class='input' id="STOR_LOC_CD"/>                  		    
			<input type='text' class='input' id="LOC_CD"/>                       		    
			<input type='text' class='input' id="MATNR"/>                        		    
			<input type='text' class='input' id="LOT_NO"/>                       		           
			<input type='text' class='input' id="ORDER_NO"/>                     		    
			<input type='text' class='input' id="MACHINE"/>                      		    
			<input type='text' class='input' id="PROC_CD"/>                      		    
			<input type='text' class='input' id="PRD_DT"/>                       		    
			<input type='text' class='input' id="PRFM_DT"/>                      		    
			<input type='text' class='input' id="DSTBT_DDLIN"/>                  		    
			<input type='text' class='input' id="PCODE"/>                         		    
			<input type='text' class='input' id="ROLLCNT"/>                      		     
			<input type='text' class='input' id="PCNT"/>                         		    
			<input type='text' class='input' id="SCNT"/>                         		     
			<input type='text' class='input' id="MCNT"/>                         		    
			<input type='text' class='input' id="WGT"/>                          		    
			<input type='text' class='input' id="CORE"/>                         		    
			<input type='text' class='input' id="BS_WGT"/>                       		    
			<input type='text' class='input' id="PACKTYPE"/>                     		    
			<input type='text' class='input' id="CONTYPE"/>                      		     
			<input type='text' class='input' id="WLEN"/>                         		    
			<input type='text' class='input' id="VLEN"/>                         		    
			<input type='text' class='input' id="WIDTH"/>                        		    
			<input type='text' class='input' id="VBELN"/>                        		     
			<input type='text' class='input' id="POSNR"/>                        		      
			<input type='text' class='input' id="KUNNR"/>                        		    
			<input type='text' class='input' id="MRG_YN"/>                       		     
			<input type='text' class='input' id="WRK_CLASS"/>                    		    
			<input type='text' class='input' id="WRK_SHIFT"/>
		</dd>
		
        <!-- end table_body -->
        <div class="footer_5" style="position:fixed;">

            <table>
                <tr>
                    <td class="f_1" onclick ="showMain()" style="width:33%"><label CL='BTN_CLOSE'></label></td>
                    <td class="f_1" onclick ="qtyReg()" style="width:34%"><label>등록</label></td>
                </tr>
            </table>
        </div><!-- end footer_5 -->
    </div>
</div>
</body>