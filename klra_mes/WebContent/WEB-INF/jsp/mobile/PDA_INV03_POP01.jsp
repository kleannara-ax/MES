<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%
	String plant = (String)request.getSession().getAttribute(CommonConfig.SES_USER_PLANT_KEY);
	//String machcd = request.getParameter("MACH_CD");
%>

<!doctype html>
<head>
	<meta charset="utf-8">
	<meta name="viewport" content="user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, width=device-width, target-densitydpi=medium-dpi" />
	<meta name="format-detection" content="telephone=no" />
	<title>MObile MES</title>
	<%@ include file="/mobile/include/head.jsp" %>
	<script>
		$(document).ready(function(){
			gridList.setGrid({
				id : "gridList",
		    	url : "/mobile/Mobile/PDA_INV03/json/datalist.data",
		    	bigdata : false,
		    	gridMobileType : true
			});
		});

		function searchList(){			
			var reqdt = $("#REQ_DT").val().replace(/-/g, '');
			var param = new DataMap();
			
			param.put("P_TYPE","LIST2");
			param.put("REQ_DT", reqdt);
			param.put('IF_STA', $('#IF_STA').val());
			param.put("WERKS", '<%=plant%>');
			
			gridList.gridList({
				id : "gridList",
				param : param
			});
			PlaySound('s');
		}

		function fail(){
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
			
			var data = gridList.getSelectData("gridList");
			
			if(data.length == 0){
				commonUtil.msg('반납요청을 취소할 항목을 선택하세요.');
				return;
			}
			
			for(var i = 0; i < data.length; i++){
				if(data[i].get('IF_STA') == 'Y'){
					commonUtil.msg('선택한 항목 중 ' + (i+1) + '번째 이미 완료처리되어 있습니다.');
					return;
				}
			}
			
       	    var param = new DataMap();
      	  	
   	 		param.put("P_TYPE","SAVE1");
   	 		param.put('list', data);
   	 		
	   	 	commonUtil.msgConfirm("반납 요청 취소하시겠습니까?", null, function(){
		   	 	netUtil.send({
	   				url : "/mobile/Mobile/PDA_INV03/json/datalist.data",
	   				param : param,
	   				successFunction : "saveSuccessCallBack"
	   		   	});	
	   	 	}, function(){
	   	 		$('#IND_BCD').focus();
	   	 	});
         }
         
         function saveSuccessCallBack(json){
        	 if(json.P_SUCCESS == 'Y'){
        		//WMS 자재/완제품 반납 요청취소
				var ifid = "MES_IF_400";
        		
        		var docno = json.DOC_NO.split(',');
        		var message = '';
        		
        		if(docno != ''){
        			for(var i = 0; i < docno.length; i++){
            			var json2 = netUtil.sendData({
              				url : "/common/api/json/"+ifid+"/send.data",
              				param : 'DOC_NO=' + docno[i]
              			});
            			
            			if(json2.result != 'SUCCESS'){
           					message = '(WMS 자재/완제품 반납 요청 취소) ' + json2.result + '\n' + message;
           				}
            		}
        		}
        		if(message == ''){
        			commonUtil.msg("반납요청 취소되었습니다.");
        		}else{
        			commonUtil.msg(message);
        			message = '';
        		}
        		searchList()
        	 }else{
        		 commonUtil.msgBox(json.ERR_MSG, null, null, function(){
        			 $('#IND_BCD').focus();
        		 });
        	 }
         }
	</script>
</head>
<body>
<div class="main_wrap">
	<div class="main_header_pop">
		<ul>
			<li class="tit" id="title" style="width:100%;">반납이력</li>
		</ul>
	</div>
	<div class="tem4_content">
		<div class="select_box" id="bindArea">
			<div id="searchArea">
				<table>
					<colgroup>
						<col width="70px"  />
						<col />
						<col width="70px" />
						<col width="65px" />
						<col width="70px" />
					</colgroup>
					<tbody>
						<tr>
							<td>일자</td>
							<td>
								<input type="text" class="text" id="REQ_DT" UIFormat="C N" style="width:50%;text-align:center;float:left;"/>
							</td>
							<td>요청상태</td>
							<td>
								<select class='input' id='IF_STA'>
									<option value='N'>요청</option>
									<option value='Y'>완료</option>
								</select>
							<td>
								<button type='button' class="bt" style="height: 36px" onclick="searchList();">조회</button>
							</td>
						</tr>
					</tbody>
				</table>
			</div>
		</div>

		<div class="tableWrap_search section">
			<div class="tableHeader">
				<table style='width:225%;'>
					<colgroup>
						<col width="1px" />
						<col width="1px" />
						<col width="2px" />
						<col width="6px" />
						<col width="2px" />
						<col width="1px" />
					</colgroup>
					<thead>
					<tr>
						<th>No.</th>
						<th>선택</th>
						<th>자재코드</th>
						<th>자재명</th>
						<th>수량</th>
						<th>단위</th>
					</tr>
					</thead>
				</table>
			</div>

			<div class="tableBody">
				<table style='width:225%;'>
					<colgroup>
						<col width="1px" />
						<col width="1px" />
						<col width="2px" />
						<col width="6px" />
						<col width="2px" />
						<col width="1px" />
					</colgroup>
					<tbody id="gridList">
						<tr CGRow="true">
							<td GCol="rownum"></td>
							<td GCol="rowCheck"></td>
							<td GCol="text,MATNR" style="text-align:center;"></td>	<!-- 자재코드 -->	
							<td GCol="text,MATNR_NM"></td>							<!-- 자재명 -->	
							<td GCol="text,QTY" GF="N 16,3"></td>				<!-- 수량 -->
							<td GCol='text,UNIT' style="text-align:center;"></td>								
						</tr>
					</tbody>
				</table>
			</div>
		</div>
		
		<div class="tableWrap_search section" style='display:none;'>
			<div class="tableHeader">
				<table style="width:150%;">
					<colgroup>
						<col width="5px" />
						<col width="5px" />
						<col width="8px" />
						<col width="8px" />
						<col width='5px' />
					</colgroup>
					<thead>
					<tr>
						<th>No.</th>
						<th>선택</th>
						<th>문서번호</th>
						<th>문서순번</th>
						<th>요청상태</th>
					</tr>
					</thead>
				</table>
			</div>

			<div class="tableBody">
				<table style="width:340%;">
					<colgroup>
						<col width="5px" />
						<col width="5px" />
						<col width="8px" />
						<col width="8px" />
						<col width='5px' />
					</colgroup>
					<tbody id="gridList">
						<tr CGRow="true">
							<td GCol="rownum"></td>
							<td GCol="rowCheck"></td>
							<td GCol="text,DOC_NO"></td>	<!-- 문서번호 -->	
							<td GCol="text,DOC_SEQNO"></td>	<!-- 자재명 -->	
							<td GCol='text,IF_STA'></td>	<!-- 요청상태 -->				
						</tr>
					</tbody>
				</table>
			</div>
		</div>

		<!-- end table_body -->
		<div class="footer_5" style="position:fixed;">
			<!-- <div class="footer_5" "> -->
			<table>
				<tr>
					<td class='f_1 btn-c1' onclick="history.back();" style="width: 50%"><label>닫기</label></td>
					<td class='f_1' onclick='fail();' style="width: 50%;"><label >요청취소</label></td>
				</tr>
			</table>
		</div><!-- end footer_5 -->
	</div>
</div>
</body>