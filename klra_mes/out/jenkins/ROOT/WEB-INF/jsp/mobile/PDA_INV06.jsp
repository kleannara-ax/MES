<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
	String plant = (String)request.getSession().getAttribute(CommonConfig.SES_USER_PLANT_KEY);
	String matnr = request.getParameter("MATNR");
	String matnrNm = request.getParameter("MATNR_NM");
	String indbcd = request.getParameter("IND_BCD");
	String machCd = request.getParameter("MACH_CD");
	String WrkOrdrNo = request.getParameter("WRK_ORDR_NO");
	String WrkOrdrSeqno = request.getParameter("WRK_ORDR_SEQNO");
	String inputqty = request.getParameter("INPUT_QTY");
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
        	gridList.setGrid({
				id : "gridList",
				url : "/mobile/Mobile/PDA_INV02/json/datalist.data",
				bigdata : false,
				gridMobileType : true
			});
            
        	$("#MATNR").val('<%=matnr%>');
        	$("#MATNR_NM").val('<%=matnrNm%>');
        	
            searchList();
        });

        function searchList(){
        	var param = new DataMap();
            param.put("PROGID", "<%= menuId%>");
            param.put("LGTYPE", "SEARCH");
            var json2 = netUtil.sendData({
                url: "/mes/system/json/saveLog.data",
                param : param
            });
        	
        	var param = new DataMap();
        	
        	param.put("WRK_ORDR_NO", '<%=WrkOrdrNo%>');
        	param.put("WRK_ORDR_SEQNO", '<%=WrkOrdrSeqno%>');
        	param.put("P_TYPE", "SUB_LIST4");
        	
	        gridList.gridList({
	            id : "gridList",
	            param : param
	        });
	        
	        PlaySound('s');
        }
        
        function gridListEventRowCheck(gridId, rowNum, checkType){
        	if(gridId == "gridList"){
        		if(checkType == true){
        			var data = gridList.getSelectData("gridList");
        			
        			if(data.length > 1){
               			PlaySound('e');
               			commonUtil.msgBox("대체할 자재를 하나만 선택가능합니다.", null, null, function(){
               				gridList.setRowCheck(gridId, rowNum, false);
               			});
               		}
        			
        			var qty = gridList.getColData(gridId, rowNum, "ORDER_BOM_QTY");
        			var unit = gridList.getColData(gridId, rowNum, "UNIT");
        			
        			$("#IN_BOM_QTY").val(qty);
        			$("#UNIT").val(unit);
        		}
        	}
        }
        
        function changeQty(){	// 투입량 체크
        	var inbomqty = $("#IN_BOM_QTY").val();	// 자재 투입량
			
        	if(Number(inbomqty) > Number('<%=inputqty%>')){
        		PlaySound('e');
        		commonUtil.msgBox("투입한 자재재고량보다 투입하려는 수량이 많습니다.", null, null, function(){
        			$("#IN_BOM_QTY").val('');
        			$('#IN_BOM_QTY').focus();
        		});
        	}
        }
        
        function unitselect(){	// 단위 선택
     	   	mobile.linkPopOpen('/mobile/UNITPOP.page');
        }
        
        function linkPopCloseEvent(data){
        	$("#UNIT").val(data.get("UNIT"));
        }
        
        function forcedInp(){	// 자재투입
       		var data = gridList.getSelectData("gridList");
       		
       		if(data.length < 1){
       			PlaySound('e');
       			commonUtil.msg("투입할 자재를 선택하세요.");
       			return;
       		} else if(data.length > 1){
       			PlaySound('e');
       			commonUtil.msg("하나의 자재만 투입가능합니다.");
       			return;
       		}
       		
       		for(var i = 0; i < data.length; i++){
       			var matnr = data[i].get("MATNR");
       			$("#IN_BOM_QTY").val(data[i].get("ORDER_BOM_QTY"));
       		}
       		
       		if(Number($("#IN_BOM_QTY").val()) == 0){
       			PlaySound('e');
       			commonUtil.msgBox("투입량을 입력하세요.", null, null, function(){
       				$('#IN_BOM_QTY').focus();	
       			});
       			return;
       		}
       		
			var inbomqty = $("#IN_BOM_QTY").val();	// 자재 투입량
			
        	if(Number(inbomqty) > Number('<%=inputqty%>')){
        		PlaySound('e');
        		commonUtil.msgBox("투입한 자재재고량보다 투입하려는 수량이 많습니다.", null, null, function(){
        			$("#IN_BOM_QTY").val('');
        			$('#IN_BOM_QTY').focus();
        		});
        		return;
        	}
       		
       		var param = new DataMap();
       		
       		param.put("P_TYPE", "SAVE");
       		param.put("INMATNR", $("#MATNR").val());			// 투입하위자재
       		param.put("MMATNR", matnr);							// BOM하위자재
	 		param.put("IND_BCD", '<%=indbcd%>');				// 바코드
	 		param.put("WERKS", '<%=plant%>');					// 플랜트
	 		param.put("INPUT_QTY", $("#IN_BOM_QTY").val());		// bom투입수량
	 		param.put("MACH_CD", '<%=machCd%>');				// 설비
	 		param.put("WRK_ORDR_NO", '<%=WrkOrdrNo%>');			// 작업지시번호
	 		param.put("WRK_ORDR_SEQNO", '<%=WrkOrdrSeqno%>');	// 작업지시순번
	 		
	 		netUtil.send({
 				url : "/mobile/Mobile/PDA_INV02/json/datalist.data",
 				param : param,
 				successFunction : "saveSuccessCallBack"
 		   	});
        }
        
        function saveSuccessCallBack(json){
     	   if(json.P_SUCCESS == 'Y'){
 	 			commonUtil.msg("투입되었습니다.");
 	 			PlaySound('s');
 	 			
 	 			var paramStr = "WRK_ORDR_NO=<%=WrkOrdrNo%>&WRK_ORDR_SEQNO=<%=WrkOrdrSeqno%>&MATNR_NM=<%=matnrNm%>";
 	 			
 	 			location.href = "/mobile/PDA_INV02.page?" +paramStr;
 	 		} else{
 	 			PlaySound('e');
 	 			commonUtil.msg(json.ERR_MSG);
 	 		}
        }

    </script>
</head>
<body>
<div class="main_wrap">
	<div class="main_header">
		<ul>
			<li class="tit" id="title">강제 투입</li>
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
                        <th class="fl" CL="STD_MATNR">자재코드</th>
                        <td>
                            <input type="text" class="text" id="MATNR" readonly="readonly"/>
                        </td>
                    </tr>
                    <tr>
                        <th class="fl" CL="STD_MATNR_NM">자재명</th>
                        <td>
                            <input type="text" class="text" id="MATNR_NM" readonly="readonly"/>
                        </td>
                    </tr>
                    </tbody>
                </table>
            </div>
        </div>
        
        <ul>
        	<li><br>&nbsp; 대체할 자재코드를 선택하세요</li>
        </ul>

		<div class="tableWrap_search section">
			<div class="tableHeader">
				<table style="width: 160%;">
					<colgroup>
						<col width="10px" />
						<col width="10px" />
						<col width="20px" />
						<col width="50px"/>
						<col width="15px"/>
						<col width="10px"/>
					</colgroup>
					<thead>
					<tr>
						<th>No</th>
						<th>선택</th>
						<th>자재코드</th>
						<th>자재명</th>
						<th>재고량</th>
						<th>단위</th>
					</tr>
					</thead>
				</table>
			</div>

			<div class="tableBody">
				<table style="width: 160%;">
					<colgroup>
						<col width="10px" />
						<col width="10px" />
						<col width="20px" />
						<col width="50px"/>
						<col width="15px"/>
						<col width="10px"/>
					</colgroup>
					<tbody id="gridList">
						<tr CGRow="true">
							<td GCol="rownum"></td>
							<td GCol="rowCheck"></td>	
							<td GCol="text,MATNR" style="text-align:center;"></td>		<!-- 하위자재코드 -->		
							<td GCol="text,MATNR_NM"></td>								<!-- 하위자재명 -->	
							<td GCol="text,ORDER_BOM_QTY" GF="N 13,3"></td>				<!-- 소요량 -->			
							<td GCol="text,UNIT" style="text-align:center;"></td>		<!-- 단위 -->	
						</tr>
					</tbody>
				</table>
			</div>
		</div>
		<div class="footer_4" style=" bottom: 105px; height: 120px;">
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
		                    <td class="fl fw">투입량 입력</td>
		                    <td colspan="2">
		                    	<input type="text" class="text" placeholder="자재 투입량 입력" id="IN_BOM_QTY" onchange="changeQty();"/>
		                    </td>
		                    <td>
		                    	<input type="text" class="text" placeholder="KG" id="UNIT" readonly="readonly" onclick="unitselect();" style="text-align:center;"/>
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
                	<td class=f_1 onclick ="history.go(-2);" style="width:33%"><label CL='BTN_CLOSE'></label></td>
                    <td class=f_1 onclick ="forcedInp();" style="width:33%">강제 투입</td>
                </tr>
            </table>
        </div><!-- end footer_5 -->
    </div>
</div>
</body>