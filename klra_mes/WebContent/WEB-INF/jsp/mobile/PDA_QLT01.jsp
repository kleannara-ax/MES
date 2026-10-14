<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
	String plant = (String)request.getSession().getAttribute(CommonConfig.SES_USER_PLANT_KEY);
	String indbcd = request.getParameter("IND_BCD");
	String inspitemcd = request.getParameter("INSP_ITEM_CD");
	String inspitemnm = request.getParameter("INSP_ITEM_NM");
	String deptcd = request.getParameter("DEPT_CD");
	String deptnm = request.getParameter("DEPT_NM");
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
	    if('<%=plant%>' != 'P100'){
	    	commonUtil.msgBox('PS 제지관리팀만 관리하는 화면입니다.', null, function(){
	    		showMain();	
	    	});
	    }
	    
	    $('#IND_BCD').focus();
	    
	    if('<%=indbcd%>' != 'null'){
	    	$('#IND_BCD').val('<%=indbcd%>');
	    	
	    	if('<%=inspitemcd%>' != 'null'){
	    		$("#INSP_ITEM_CD").val('<%=inspitemcd%>');
		    	$("#INSP_ITEM_NM").val('<%=inspitemnm%>');
	    	}
	    	if('<%=deptcd%>' != 'null'){
	    		$('#DEPT_CD').val('<%=deptcd%>');
	    		$('#DEPT_NM').val('<%=deptnm%>');
	    	}
	    	onReadBarcode();
	    }
	});
    
    function linkPopCloseEvent(data){
		   $("#INSP_ITEM_CD").val(data.get("insp_item_cd"));
		   $("#INSP_ITEM_NM").val(data.get("insp_item_nm"));
		   
		   $("#IND_BCD").focus();
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
    
	    if(ind_bcd.length > 10){
   		   commonUtil.msgBox('존재하지 않는 바코드이므로 다시 스캔하세요.', null, null, function(){
   			  $('#IND_BCD').focus(); 
   		   });
   		   return;
   	    }
		
    	var param = new DataMap();
  	  	
		param.put("P_TYPE","LIST");
		
		param.put("IND_BCD", $("#IND_BCD").val());
		param.put("WERKS", '<%=plant%>');
		
		netUtil.send({
			url : "/mobile/Mobile/PDA_QLT01/json/datalist.data",
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
			var value = json.data;
     	    var add_data = '';
	     	   
			if(json.data.length == 0){
				PlaySound("e");
				commonUtil.msgBox(configData.MSG_MASTER_ROWEMPTY, null, null, function(){
					$("#IND_BCD").focus();
					   
					add_data += '<tr><th class="fl">자재코드</th></tr>'; 
					add_data += '<tr><th class="fl">자재명</th></tr>';
					add_data += '<tr><th class="fl">LOT NO</th></tr>';
					add_data += '<tr><th class="fl">지종</th></tr>';
					add_data += '<tr><th class="fl">지종명</th></tr>';   
					add_data += '<tr><th class="fl">평량</th></tr>';
					add_data += '<tr><th class="fl">규격</th></tr>';
					add_data += '<tr><th class="fl">재고수량</th></tr>';  
					add_data += '<tr><th class="fl">중량</th></tr>';          	
					add_data += '<tr><th class="fl">포장타입</th></tr>';          		 
					add_data += '<tr><th class="fl">재고상태</th></tr>';          			
		   		   
				   target1.html(add_data);
				});
   			} else if(json.data.length == 1){
		   		PlaySound("s");
	     	    
	     	   	$.each(value, function (index, item){
					add_data += '<tr><th class="fl">자재코드</th>';          			
       			    add_data += '<td class="fl">' + item.MATNR + '</td></tr>';
	       			add_data += '<tr><th class="fl">자재명</th>';          			
	       		   add_data += '<td class="fl">' + item.MATNR_NM + '</td></tr>';
	       		   add_data += '<tr><th class="fl">LOT NO</th>';          			
	       		   add_data += '<td class="fl">' + item.LOT_NO + '</td></tr>';
	       		   add_data += '<tr><th class="fl">지종</th>';          			
	       		   add_data += '<td class="fl">' + item.PCODE + '</td></tr>';
	       		   add_data += '<tr><th class="fl">지종명</th>';          			
	       		   add_data += '<td class="fl">' + item.PCODE_NM + '</td></tr>';
	     		   add_data += '<tr><th class="fl">평량</th>';
	       		   add_data += '<td class="fl">' + item.BS_WGT + '</td></tr>';
	       		   add_data += '<tr><th class="fl">규격</th>';
	       		   add_data += '<td class="fl">' + item.MATNR_SPEC + '</td></tr>';
	       		   add_data += '<tr><th class="fl">재고수량</th>';          			
	       		   add_data += '<td class="fl">' + item.STCK_QTY + '</td></tr>';
	       		   add_data += '<tr><th class="fl">중량</th>';          			
	       		   add_data += '<td class="fl">' + item.WGT + '</td></tr>';  
	       		   add_data += '<tr><th class="fl">포장타입</th>';          			
	       		   add_data += '<td class="fl">' + item.PACK_TYPE + '</td></tr>';  
	       		   add_data += '<tr><th class="fl">재고상태</th>';          			
	       		   add_data += '<td class="fl">' + item.STCK_STA + '</td></tr>';  
	       		   
	       	       $("#LOT_NO").val(item.LOT_NO);
	       	       $("#MATNR").val(item.MATNR);
	       	   });
	       		
	       	   target1.html(add_data);
   			} 
	   	}
	}
     
	function searchList2(){	// 불량항목 검색
		if($('#IND_BCD').val() == ''){
			PlaySound('e');
			commonUtil.msgBox('바코드를 스캔 및 입력하세요.', null, null, function(){
				$('#IND_BCD').focus();
			});
			return;
		}
	
		var paramStr = 'IND_BCD='+$("#IND_BCD").val() + '&DEPT_CD=' + $('#DEPT_CD').val() + '&DEPT_NM=' + $('#DEPT_NM').val();
		
		location.href = '/mobile/PDA_QLT01_POP01.page?' + paramStr;
	}

	function searchList3(){	// 부서 검색
		if($('#IND_BCD').val() == ''){
			PlaySound('e');
			commonUtil.msgBox('바코드를 스캔 및 입력하세요.', null, null, function(){
				$('#IND_BCD').focus();
			});
			return;
		}
	
		var paramStr = 'IND_BCD='+$("#IND_BCD").val() + '&INSP_ITEM_CD=' + $('#INSP_ITEM_CD').val() + '&INSP_ITEM_NM=' + $('#INSP_ITEM_NM').val();

		location.href = '/mobile/PDA_QLT01_POP02.page?' + paramStr;
	}
	
     function pass(){
     	if($("#IND_BCD").val() == ''){
     		PlaySound('e');
     		commonUtil.msgBox('바코드를 스캔 및 입력하세요.', null, null, function(){
				$('#IND_BCD').focus();
			});
     		return;
     	}
     	
		var param = new DataMap();
 	  	
 		param.put("P_TYPE","SAVE");
 		
 		param.put("IND_BCD", $("#IND_BCD").val());
		param.put("WERKS", '<%=plant%>');
 		param.put("INSP_ITEM_CD", $("#INSP_ITEM_CD").val());
 		param.put('DEPT_CD', $('#DEPT_CD').val());
 		param.put('MATNR', $('#MATNR').val());
		
 		commonUtil.msgConfirm('합격 처리하시겠습니까?', null, function(){
 			netUtil.send({
 				url : "/mobile/Mobile/PDA_QLT01/json/datalist.data",
 				param : param,
 				successFunction : "savesuccessCallBack"
 		   	});
 		}, function(){
 			$('#IND_BCD').focus();
 		});
      }

      function savesuccessCallBack(json){
		if(json.P_SUCCESS == 'Y'){
      		commonUtil.msgBox("합격 처리되었습니다.", null, null, function(){
      			reset();
      		});
   		}
      }
     
      function fail(){
       	if($("#IND_BCD").val() == ''){
       		PlaySound('e');
       		commonUtil.msgBox("바코드를 스캔 또는 입력하세요.", null, null, function(){
       			$('#IND_BCD').focus();
       		});
       		return;
       	}
       	/* if($('#DEPT_CD').val() == ''){
     		PlaySound('e');
     		alert('부서를 선택하세요.');
     		return;
     	}
     	if($('#INSP_ITEM_CD').val() == ''){
     		PlaySound('e');
     		alert('부적합처리할 항목을 선택하세요.');
     		return;
     	} */
	 	var param = new DataMap();
 	  	
 		param.put("P_TYPE","SUB_SAVE1");
 		
 		param.put("IND_BCD", $("#IND_BCD").val());
		param.put("WERKS", '<%=plant%>');
 		param.put("INSP_ITEM_CD", $("#INSP_ITEM_CD").val());
		param.put("MATNR", $("#MATNR").val());
		param.put('DEPT_CD', $('#DEPT_CD').val());
 		
		commonUtil.msgConfirm('불합격 처리하시겠습니까?', null, function(){
			netUtil.send({
				url : "/mobile/Mobile/PDA_QLT01/json/datalist.data",
				param : param,
				successFunction : "savesuccessCallBack2"
		   	});
		}, function(){
			$('#IND_BCD').focus();
		});
     }

     function savesuccessCallBack2(json){
     	if(json.P_SUCCESS == 'Y'){
     		commonUtil.msgBox("불합격 처리되었습니다.", null, null, function(){
     			reset();
     		});
   		}
     }
     //초기화
     function reset(){
     	var target1 = $('#list1');
     	var add_data = '';
     	 
     	add_data += '<tr><th class="fl">자재코드</th></tr>'; 
		add_data += '<tr><th class="fl">자재명</th></tr>';
		add_data += '<tr><th class="fl">LOT NO</th></tr>';
		add_data += '<tr><th class="fl">지종</th></tr>';
		add_data += '<tr><th class="fl">지종명</th></tr>';   
		add_data += '<tr><th class="fl">평량</th></tr>';
		add_data += '<tr><th class="fl">규격</th></tr>';
		add_data += '<tr><th class="fl">재고수량</th></tr>';  
		add_data += '<tr><th class="fl">중량</th></tr>';          	
		add_data += '<tr><th class="fl">포장타입</th></tr>';          		 
		add_data += '<tr><th class="fl">재고상태</th></tr>';          			
		   
  		target1.html(add_data);
  
  		$("#IND_BCD").focus();
		$("#IND_BCD").val('');
		$('#INSP_ITEM_CD').val('');
		$("#INSP_ITEM_NM").val('');
		$('#DEPT_CD').val('');
		$('#DEPT_NM').val('');
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
			<li class="tit" id="title" style="width:100%;">품질검사</li>
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
                            <input type="text" class="text" id="IND_BCD" placeholder="바코드스캔 및 입력" onfocus="fn_onfocus(this.id)" 
                            	onkeypress="commonUtil.enterKeyCheck(event, 'onReadBarcode()')" style='text-align:center;' autocomplete="off"/>
                        </td>
                    </tr>
                    </tbody>
                </table>

                <table class="mg-10 bd-c1">
                    <colgroup>
                        <col width="30%" />
                        <col width="70%" />
                    </colgroup>
                    <tbody  id="list1">
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
	                       <th class="fl">지종</th>
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
	                       <th class="fl">재고수량</th>
	                       <td class="fl"></td>
	                   	</tr>
	                    <tr>
	                       <th class="fl">중량</th>
	                       <td class="fl"></td>
	                   	</tr>
	                    <tr>
	                       <th class="fl">포장타입</th>
	                       <td class="fl"></td>
	                   	</tr>
	                    <tr>
	                       <th class="fl">재고상태</th>
	                       <td class="fl"></td>
	                   	</tr>
                    	
                    </tbody>
                </table>
                
            </div>
        </div>

		<dd style="display:none;">
			<input type="text" class="input" id="INSP_ITEM_CD"/>	<!-- 검사항목 -->
			<input type="text" class="input" id="LOT_NO"/>	<!-- lot no -->
			<input type="text" class='input' id='MATNR'/>
			<input type='text' class='input' id='DEPT_CD'/>
		</dd>


		<div class="footer_4" style="height: 140px;">
			<div class="select_box mg-20">
                <table>
                    <colgroup>
                        <col width="80px"/>
                        <col/>
                        <col width="120px"/>
                    </colgroup>
                    <tbody>
	                    <tr>
	                  	  	<td class="fl fw">부서</td>
	                        <td>
	                            <input type="text" class="text" id='DEPT_NM' readonly="readonly"/>
	                        </td>
	                        <td>
	                        	<button class='bt' style="height:36px;" onclick="searchList3();">부서 검색</button>
	                        </td>
	                    </tr>
	                    <tr>
	                        <td class="fl fw">불량 항목</td>
	                        <td>
	                        	<input type="text" class="text" id="INSP_ITEM_NM" name="INSP_ITEM_NM" readonly/>
	                       	</td>
	                        <td>
								<button class="bt" style="height: 36px;" onclick="searchList2();">불량 검색</button>
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
                    <td class="f_1" onclick ="pass()" style="width:33%">합격</td>
                    <td class="f_1" onclick ="fail()" style="width:33%">불합격</td>
                </tr>
            </table>
        </div><!-- end footer_5 -->
    </div>
</div>
</body>