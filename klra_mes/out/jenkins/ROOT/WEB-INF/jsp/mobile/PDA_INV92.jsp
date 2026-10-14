<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%
	String procCd = (String)request.getSession().getAttribute(CommonConfig.SES_PROC_CD);
	String machCd = (String)request.getSession().getAttribute(CommonConfig.SES_MACH_CD);
	String plant = (String)request.getSession().getAttribute(CommonConfig.SES_USER_PLANT_KEY);
	String stckKey = request.getParameter("STCK_KEY");
	String lotnum = request.getParameter("LOT_NUM");
	String wrkordrno = request.getParameter("WRK_ORDR_NO");
	String wrkordrseqno = request.getParameter("WRK_ORDR_SEQNO");
	String matnrnm = request.getParameter("MATNR_NM");
	String machcd = request.getParameter("MACH_CD");
	String indbcd = request.getParameter("IND_BCD");
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
		var code;
		$(document).ready(function(){
			if('<%=plant%>' == 'P100' && '<%=procCd%>' != 'PB' && '<%=procCd%>' != 'CB' && '<%=procCd%>' != 'SA'){
				PlaySound('e');
				commonUtil.msgBox('PS제지 중에서 포장 공정만 관리하는 화면입니다.', null, null, function(){
					showMain();	
				});
			}
			
			var json = netUtil.sendData({
				url : "/mobile/Mobile/json/gelInvNm.data",
			});
			
			if(json){
				$("#MACH_CD").val('[<%=machCd%>] ' + json.machNm);
			}
		    
		    var stckKey = '<%=stckKey%>';
		    var lotnum = '<%=lotnum%>';
		    var wrkordrno = '<%=wrkordrno%>'; 
		    console.log('wrkordrno = ', wrkordrno);
		    if(wrkordrno != 'null'){
		    	$("#WRK_ORDR_NO").val('<%=wrkordrno%>');
			    console.log('Page Load WRK_ORDR_NO = ', $("#WRK_ORDR_NO").val());
			    $("#WRK_ORDR_SEQNO").val('<%=wrkordrseqno%>');
			    $("#MATNR_NM2").val('<%=matnrnm%>');
			   	$('#IND_BCD').val('');
			    $("#IND_BCD").focus();
			    $('#INPUT_QTY').val('');
		    }
		    
		    if(stckKey == 'null' && wrkordrno == 'null'){
		    	searchList();	// 작업지시, 작업지시 새로고침 
		    }
		    if($("#IND_BCD").val() != ''){
		    	onReadBarcode();	
		    }
		    
		    console.log('stckKey = ', stckKey);
		    console.log('lotnum = ', lotnum);
		    console.log('wrkordrno = ', wrkordrno);
		    if(stckKey != 'null' && lotnum != 'null'){
		    	$("#WRK_ORDR_NO").val('<%=wrkordrno%>');
			    $("#WRK_ORDR_SEQNO").val('<%=wrkordrseqno%>');
			    $("#MATNR_NM2").val('<%=matnrnm%>');
		    	$('#IND_BCD').val('<%=indbcd%>')
		    	onReadBarcode();
		    }
		});
		
        function searchList(){
  			var param = new DataMap();
  	
  			param.put("P_TYPE","SUB_LIST1");
  			param.put("MACH_CD", "<%=machCd%>");
  			param.put("WERKS", '<%=plant%>');

  			netUtil.send({
  				url : "/mobile/Mobile/PDA_INV02/json/datalist.data",
  				param : param,
  				successFunction : "saveSuccessCallBack1"
  			});
        }
	
	    function saveSuccessCallBack1(json){
	    	if(json && json.data){
	    		PlaySound("s");
	    		
	    		var value = json.data;
	    		var wrk_ordr_no;
	    		$.each(value, function (index, item){
	    			wrk_ordr_no = item.WRK_ORDR_NO;
	    			console.log('1111', $("#WRK_ORDR_NO").val());
	    			if ($("#WRK_ORDR_NO").val() == '') {
			    		$("#WRK_ORDR_NO").val(item.WRK_ORDR_NO);
			    		$("#WRK_ORDR_SEQNO").val(item.WRK_ORDR_SEQNO);
			    		$("#ORDER_NO").val(item.ORDER_NO);
			    		$("#MATNR2").val(item.MATNR);
			    		$("#MATNR_NM2").val(item.MATNR_NM);
    				}
	    		});
	 		    
	    		$("#IND_BCD").focus();
			} else{
				PlaySound("e");
			}
	   }
	    
	   function linkPopCloseEvent(data){
		   $("#UNIT").val(data.get("UNIT"));
		   
		   $("#IND_BCD").focus();
       }
	   
       function showMain() {
           window.top.menuOpen();
       }

       function searchList2(){	// 작업지시 검색
    	   //var param = new DataMap();

           //param.put("MACH_CD", $("#MACH_CD").val());

           //mobile.linkPopOpen('/mobile/PDA_INV92_POP01.page', param);
           location.href = "/mobile/PDA_INV92_POP01.page?MACH_CD=<%=machCd%>";
       }
       
	   //자재정보
       function searchList3(){
		   var param = new DataMap();
      	  	
		   var indbcd = $("#IND_BCD").val();
		   //var machCd = $("#MACH_CD").val();
		   var WrkOrdrNo = $("#WRK_ORDR_NO").val();
		   var WrkOrdrSeqno = $("#WRK_ORDR_SEQNO").val();
		   var matnr = $("#MATNR2").val();
		   var matnrNm = $("#MATNR_NM2").val();
   	       
		   var paramStr = "MATNR=" + matnr + "&MATNR_NM=" + matnrNm + "&IND_BCD=" + indbcd + "&MACH_CD=<%=machCd%>&WRK_ORDR_NO=" + WrkOrdrNo + "&WRK_ORDR_SEQNO=" + WrkOrdrSeqno;
       	
       	   location.href = "/mobile/PDA_INV92_POP04.page?" + paramStr;
       }
       
       function fn_onfocus(objId){
   		$("#"+objId).select();
   	   }
       
       function onReadBarcode(){	// 바코드 스캔
    	   var param = new DataMap();
    	   var stckKey = '<%=stckKey%>';
    	   var ind_bcd = $('#IND_BCD').val();
 		   param.put("P_TYPE","LIST");
       	   param.put("WRK_ORDR_NO", $("#WRK_ORDR_NO").val());
 		   param.put("WRK_ORDR_SEQNO", $("#WRK_ORDR_SEQNO").val());
 		   param.put("IND_BCD", $("#IND_BCD").val());
 		   param.put("WERKS", '<%=plant%>');
 		   
		   if(stckKey == 'null'){
			   param.put("STCK_KEY", ' ');
	 		   param.put("LOT_NUM", ' ');
	 		   
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
	 		   
	 		   if($('#IND_BCD').val() == ''){
	 			   commonUtil.msgBox('바코드를 스캔하세요.', null, null, function(){
	 				  $('#IND_BCD').focus(); 
	 			   });
	 			   return;
	 		   }
		   }else{
			   param.put("STCK_KEY", '<%=stckKey%>');
	 		   param.put("LOT_NUM", '<%=lotnum%>');
		   }

 		   netUtil.send({
 			   url : "/mobile/Mobile/PDA_INV02/json/datalist.data",
 			   param : param,
 			   successFunction : "saveSuccessCallBack2"
 		   });
       }
       
       function saveSuccessCallBack2(json){
    	   if(json.P_SUCCESS == 'Y'){
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
				var WrkOrdrNo = $("#WRK_ORDR_NO").val();
				var WrkOrdrSeqno = $("#WRK_ORDR_SEQNO").val();
	     	   
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
    	  	       	   target2.html(add_data2);
    	  	       	   
    	  	       	   $("#INPUT_QTY").val('');	// 투입수량
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
	  	       		   	
						if(item.STCK_STA == '투입가능'){
	  	       		   		add_data2 += '<tr><td class="fl">' + item.STCK_STA + '</td></tr>';	
	  	       		   	}else{
	  	       		   		add_data2 += '<tr><td class="fl" style="background:red; color:white;">' + item.STCK_STA + '</td></tr>';
	  	       		   	}
	  	       		   
	  	       		   	$("#MATNR").val(item.MATNR);			
						$("#MATNR_NM").val(item.MATNR_NM);	
						$("#INPUT_QTY").val(item.STCK_QTY);	// 투입수량
						$("#STCK_QTY").val(item.STCK_QTY);	// 재고수량
						$("#UNIT").val(item.UNIT);
						$("#STCK_STA").val(item.STCK_STA);
						$("#STCK_KEY").val(item.STCK_KEY);
						$("#LOT_NUM").val(item.LOT_NUM);
						$('#LOT_NO').val(item.LOT_NO);
	  	       	   });
	  	       		
	  	       	   target1.html(add_data);
	  	       	   target2.html(add_data2);
	  	       	   
	  	       	   $("#IND_BCD").focus();
	  	       	   
	  	       	   code = json.code;
	  	       	   
	  	       		$('#CONTIN_FLG').prop('checked', true);
		   		
		   			is_checked();
      		   } else {
      			   var paramStr = "IND_BCD=" + $("#IND_BCD").val() + "&MATNR=" + $("#MATNR2").val() + "&MATNR_NM=" + $("#MATNR_NM2").val() + "&WRK_ORDR_NO=" + WrkOrdrNo + "&WRK_ORDR_SEQNO=" + WrkOrdrSeqno;
    			   location.href = "/mobile/PDA_INV92_POP03.page?" + paramStr;
      		   }
		   }else{
			   commonUtil.msg(json.RS_MSG);
		   }
	   }
       
       function unitselect(){	// 단위 선택
    	   mobile.linkPopOpen('/mobile/UNITPOP.page');
       }
       
       function Inpselect(){	// 투입이력
    	   //var param = new DataMap();
    		
       	   //param.put("MACH_CD", $("#MACH_CD").val());
       
    	   //mobile.linkPopOpen('/mobile/PDA_INV92_POP02.page', param);
       	   location.href = "/mobile/PDA_INV92_POP02.page?WERKS=<%=plant%>&MACH_CD=<%=machCd%>";
       }
       
       function changeQty(){	// 투입량 체크
    	   var stck_qty = $("#STCK_QTY").val();	// 재고수량
    	   var inp_qty = $("#INPUT_QTY").val();	
    	   
    	   if(Number(inp_qty) > Number(stck_qty)){
    		   PlaySound('e');
    		   commonUtil.msgBox("재고에 있는 수량만큼 투입가능합나다.", null, null, function(){
    			   $("#INPUT_QTY").val('');
    			   $('#INPUT_QTY').focus();
    		   });
    	   }
    	   if(Number(inp_qty) == 0 || inp_qty == ''){
    		   PlaySound('e');
    		   commonUtil.msgBox("투입량을 입력하세요.", null, null, function(){
    			   $("#INPUT_QTY").val('');
    			   $('#INPUT_QTY').focus();
    		   });
    	   }
    	   if(Number(inp_qty) < 0){
    		   PlaySound('e');
    		   commonUtil.msgBox("0보다 작게 투입할 수 없습니다.", null, null, function(){
    			   $("#INPUT_QTY").val('');
    			   $('#INPUT_QTY').focus();
    		   });
    	   }
       }
       
       //연속투입 체크여부
       function is_checked(){
    	   const checkbox = document.getElementById('CONTIN_FLG');
    	   
    	   const is_checked = checkbox.checked;
    	   
    	   if(is_checked == true){
    		   $("#CONTIN_FLG").val('Y');
    	   }else{
    		   $("#CONTIN_FLG").val('N');
    	   }
       }
       
       //투입
       function matnrInp(){
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
    	   
    	   var ind_bcd = $("#IND_BCD").val();
    	   var werks = '<%=plant%>';
    	   
    	   if(ind_bcd == "" && werks != "P500" && werks != 'P300'){
    		   PlaySound('e');
    		   commonUtil.msgBox("바코드를 스캔 또는 입력하세요.", null, null, function(){
    			   $("#IND_BCD").focus();    				   
    		   });
    		   
    		   return;
    	   }
    	   
    	   if($("#STCK_QTY").val() == ''){
    		   PlaySound('e');
			   commonUtil.msg("투입하려는 자재재고정보가 없습니다.");
			   return;
    	   }
    	   
    	   var stck_qty = $("#INPUT_QTY").val();
		   
    	   if(Number(stck_qty) <= 0){
    		   PlaySound('e');
			   commonUtil.msg("투입수량을 입력하세요.");
			   return;
		   }
    	   
    	   var stck_sta = $("#STCK_STA").val();
    	   
    	   var param = new DataMap();
    	   
    	   if (stck_sta == "투입가능") {
	    		// 공정창고에 재고가 없으면 음성, 생리대일 때 바로  WMS에 자재불출요청하고 나서 투입
	   			if((werks == "P500" || werks =='P300') && code == "U"){
	   				param.put("P_TYPE","SUB_SAVE2");
	   				param.put("WERKS", '<%=plant%>');
	   				param.put("MATNR", $("#MATNR").val());
	   				param.put("STCK_KEY", $("#STCK_KEY").val());
	   				param.put("LOT_NUM", $("#LOT_NUM").val());
	   				param.put("INPUT_QTY", $("#INPUT_QTY").val());	// 투입수량
	   				param.put("UNIT", $("#UNIT").val());
	   				param.put("IND_BCD", $("#IND_BCD").val());
	   				param.put("MACH_CD", "<%=machCd%>");
	   				param.put("WRK_ORDR_NO", $("#WRK_ORDR_NO").val());
	   				param.put("WRK_ORDR_SEQNO", $("#WRK_ORDR_SEQNO").val());
	   				param.put('LOT_NO', $('#LOT_NO').val());
	   				param.put("CONTIN_FLG", $("#CONTIN_FLG").val());
	   				param.put("P_REQ_DT", $("#INP_DT").val().replace(/-/g, ''));
	   				console.log("INP_DT = ", $("#INP_DT").val());
	   				console.log("INP_DT = ", $("#INP_DT").val().replace(/-/g, ''));
	   				
	   				commonUtil.msgConfirm("자재불출요청 및 투입하시겠습니까?", null, function(){
	   					netUtil.send({
		   					url : "/mobile/Mobile/PDA_INV92/json/datalist.data",
		   					param : param,
		   					successFunction : "saveSuccessCallBack4"
		   				});
	   				}, function(){
	   					$('#IND_BCD').focus();
	   				});
	   				
   			   	}else{
   			   		//자재투입
   			   		matnrInput();
   			   	}
    	   }else{
    		   if(stck_sta == "투입가능한 하위자재가 아닙니다."){	// 강제투입
					var paramStr = "MATNR=" + $("#MATNR").val() + "&MATNR_NM=" + $("#MATNR_NM").val() + "&IND_BCD=" + $("#IND_BCD").val() 
								+ "&MACH_CD=<%=machCd%>&WRK_ORDR_NO=" + $("#WRK_ORDR_NO").val() + "&WRK_ORDR_SEQNO=" + $("#WRK_ORDR_SEQNO").val() + "&INPUT_QTY=" + $("#INPUT_QTY").val() 
								+ "&STCK_QTY=" + $("#STCK_QTY").val() + "&UNIT=" + $("#UNIT").val() + '&CONTIN_FLG=' + $("#CONTIN_FLG").val();
					
					//mobile.linkPopOpen('/mobile/MESSAGEPOP.page', param);
					location.href = "/mobile/MESSAGEPOP.page?" + paramStr;
				} else{
					PlaySound('e');
					commonUtil.msgBox("투입을 할 수 없는 상태입니다.", null, null, function(){
						$("#IND_BCD").focus();
					});					
				}
    	   }
		}
       
		function saveSuccessCallBack3(json){
			if(json.P_SUCCESS == 'Y'){
				PlaySound('s');
				commonUtil.msgBox("투입되었습니다.", null, null, function(){
					reset();
	        		searchList();
				});
			}else{
				PlaySound('e');
				commonUtil.msgBox(json.RS_MSG, null, null, function(){
					$('#IND_BCD').focus();
				});
			}
       }
       
		function saveSuccessCallBack4(json){
    	   if(json){
    		   if(json.P_SUCCESS == 'N'){
	   	 			PlaySound('e');
	   	 			commonUtil.msgBox(json.RS_MSG, null, null, function(){
	   	 				$("#IND_BCD").focus();
	   	 			});
   	 			}else{
   	 				var ifid = "MES_IF_203";
	   	 			var json2 = netUtil.sendData({
	   	 				url : "/common/api/json/"+ifid+"/send.data",
	   	 				param : 'DOC_NO=' + json.DOC_NO
	   	 			});
	   	 			
	   	 			if(json2){
	   	 				if(json2.result == 'SUCCESS'){
	   	 					//alert('자재불출완료');
	   	 					matnrInput();
	   	 				}else {
	   	 					commonUtil.msgBox('(WMS 자재 불출 요청) ' + json2.result, null, null, function(){
	   	 						$('#IND_BCD').focus();
	   	 					});
	   	 				}
	   	 			}
   	 			}
    	   }
       }
       //자재투입
       function matnrInput(){
    	   var stck_sta = $("#STCK_STA").val();
    	   var werks = '<%=plant%>';
    	   
    	   var param = new DataMap();
    	   
		   param.put("P_TYPE","SAVE");
			param.put("IND_BCD", $("#IND_BCD").val());
			param.put("WERKS", '<%=plant%>');
			param.put("INPUT_QTY", $("#INPUT_QTY").val());	// 투입수량
			param.put("MACH_CD", "<%=machCd%>");
			param.put("WRK_ORDR_NO", $("#WRK_ORDR_NO").val());
			param.put("WRK_ORDR_SEQNO", $("#WRK_ORDR_SEQNO").val());
			param.put("INMATNR", $("#MATNR").val());
			param.put("MATNR_NM", $("#MATNR_NM").val());
		    param.put("CONTIN_FLG", $("#CONTIN_FLG").val());
		    param.put("UNIT", $("#UNIT").val());
		    
		    if(code == 'U'){
		    	param.put('WMS_FLG', 'Y');
		    }else{
		    	param.put('WMS_FLG', 'N');
		    }
		    
		   	if (stck_sta == "투입가능") {
		   		if(code != 'U'){
		   			commonUtil.msgConfirm("투입하시겠습니까?", null, function(){
			    		netUtil.send({
							url : "/mobile/Mobile/PDA_INV02/json/datalist.data",
							param : param,
							successFunction : "saveSuccessCallBack3"		
			    		});
		   			}, function(){
		   				$('#IND_BCD').focus();
	   				});
	   			}else{
	   				netUtil.send({
						url : "/mobile/Mobile/PDA_INV02/json/datalist.data",
						param : param,
						successFunction : "saveSuccessCallBack3"		
		    		});
	   			}
		   	} else {	// 투입불가
				if(stck_sta == "투입가능한 하위자재가 아닙니다."){	// 강제투입
					var paramStr = "MATNR=" + $("#MATNR").val() + "&MATNR_NM=" + $("#MATNR_NM").val() + "&IND_BCD=" + $("#IND_BCD").val() 
								+ "&MACH_CD=<%=machCd%>&WRK_ORDR_NO=" + $("#WRK_ORDR_NO").val() + "&WRK_ORDR_SEQNO=" + $("#WRK_ORDR_SEQNO").val() + "&INPUT_QTY=" + $("#INPUT_QTY").val() 
								+ "&STCK_QTY=" + $("#STCK_QTY").val() + "&UNIT=" + $("#UNIT").val();
					
					//mobile.linkPopOpen('/mobile/MESSAGEPOP.page', param);
					location.href = "/mobile/MESSAGEPOP.page?" + paramStr;
				} else{
					PlaySound('e');
					commonUtil.msgBox("투입을 할 수 없는 상태입니다.", null, null, function(){
						$("#IND_BCD").focus();
					});					
				}
			}
       }
       	//초기화
		function reset(){
			var target1 = $('#list1');
   			var target2 = $('#list2');
			var add_data = '';
	   		var add_data2 = '';
   
       		console.log('target1', target1);
       		console.log('target2', target2);
       		console.log('WRK_ORDR_NO', $("#WRK_ORDR_NO").val());
			add_data += '<tr><th class="fl">자재코드</th></tr>';
			add_data += '<tr><th class="fl">자재명</th></tr>';	
			add_data += '<tr><th class="fl">개별바코드</th></tr>';          			       			
			add_data += '<tr><th class="fl">LOT NO</th></tr>';          		         			
			add_data += '<tr><th class="fl">저장위치코드</th></tr>';          		          			
			add_data += '<tr><th class="fl">재고수량</th></tr>';          		          			
			add_data += '<tr><th class="fl">단위</th></tr>';          			
 
			target1.html(add_data);
			target2.html(add_data2)
		   
//			$("#WRK_ORDR_NO").val('');
			$("#MATNR_NM").val('');
			$("#INPUT_QTY").val('');
			$("#IND_BCD").val('');
	   		$("#IND_BCD").focus();
	   		
	   		$('#CONTIN_FLG').prop('checked', false);
	   		
       		console.log('WRK_ORDR_NO Step2', $("#WRK_ORDR_NO").val());
	   		is_checked();
	   		
       		console.log('WRK_ORDR_NO Step3', $("#WRK_ORDR_NO").val());
	   		history.replaceState({}, null, location.pathname);
       		console.log('WRK_ORDR_NO Step4', $("#WRK_ORDR_NO").val());
       }
	</script>
</head>
<body>
	<div class="main_wrap">
		<div class="main_header">
			<ul>
				<li class="tit" id="title" style="width:100%;">원부자재 투입(패드)</li>
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
							<col />
							<col width="100px" />
						</colgroup>
						<tbody>
<!-- 							<tr>
								<th class="fl">설비</th>
								<td colspan="3">
									<select class="input" id="MACH_CD" name="MACH_CD" combo="mes,MACH2" style="text-align: center;">
									</select>
								</td>
							</tr>
 -->
							<tr>
								<th class="fl">설비</th>
								<td colspan="3">
									<input type="text" class="text" id="MACH_CD" name="MACH_CD" style="text-align: center;" readonly/>
								</td>
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
								<td colspan="2"><input type="text" class="text" readonly name="MATNR_NM" id="MATNR_NM2"></td>
								<td>
									<button class="bt" style="height: 36px;" onclick="searchList()">새로고침</button>
								</td>
							</tr>
							<tr>
								<th class="fl">투입일자</th>
								<td colspan="3">
									<input type="text" class="text" id="INP_DT" UIFormat="C N" style="width:50%;text-align:center;float:left;"/>
								</td>
							</tr>
							<tr>
								<th class="fl" CL="STD_BARCOD">바코드</th>
								<td colspan="2">
									<input type="text" class="text" placeholder="바코드 스캔 및 입력" id="IND_BCD" name="IND_BCD" 
									style="text-align: center;" onfocus="fn_onfocus(this.id)" onkeypress="commonUtil.enterKeyCheck(event, 'onReadBarcode()')" autocomplete="off"/>
								</td>
								<td>
									<button class="bt" style="height: 36px;" onclick="searchList3()">자재정보</button>
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
						<col width="70%" />
					</colgroup>
					<tbody id="list2">
						
					</tbody>
				</table>
			</div>
			
			<dd style="display:none;">
				<input type="text" class="input" id="WRK_ORDR_SEQNO"/>	<!-- 작업지시순번 -->
				<input type="text" class="input" id="ORDER_NO"/>		<!-- 오더번호 -->
				<input type="text" class="input" id="MATNR"/>			<!-- 투입자재코드 -->
				<input type="text" class="input" id="MATNR2"/>			<!-- 자재코드 -->
				<input type="text" class="input" id="MATNR_NM"/>		<!-- 자재명 -->
				<input type="text" class="input" id="STCK_STA"/>		<!-- 재고상태 -->
				<input type="text" class="input" id="STCK_QTY"/>		<!-- 재고수량 -->
				<input type="text" class="input" id="STCK_KEY"/>		<!-- WMS KEY -->
				<input type="text" class="input" id="LOT_NUM"/>			<!-- WMS LOTNUM -->
				<input type='text' class='input' id='LOT_NO'/>			<!-- LOT_NO -->
			</dd>

			<div class="footer_4" style=" bottom: 105px; height: 120px;">
				<div class="select_box mg-20">
					<input type="checkbox" id="CONTIN_FLG" name="CONTIN_FLG" value='N' onclick='is_checked();'>연속투입
					<table>
						<colgroup>
							<col width="100px" />
							<col />
							<col />
							<col width="80px" />
						</colgroup>
						<tbody>
							<tr>
								<td class="fl fw">투입량 입력</td>
								<td colspan="2">
									<input type="text" class="text" placeholder="자재 투입량 입력" id="INPUT_QTY" name="INPUT_QTY" UIFormat='N 10' onchange="changeQty();"/>
								</td>
								<td>
									<input type="text" class="text" placeholder="KG" id="UNIT" name="UNIT" readonly="readonly" onclick="unitselect();" style="text-align:center;"/>
								</td>
							</tr>
						</tbody>
					</table>
				</div>
			</div>

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