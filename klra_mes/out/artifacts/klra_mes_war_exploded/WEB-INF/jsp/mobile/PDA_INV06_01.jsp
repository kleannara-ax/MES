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
	String stckqty = request.getParameter("STCK_QTY");
	String unit = request.getParameter("UNIT");
	String continflg = request.getParameter("CONTIN_FLG");
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
        	PlaySound('s');
        	$("#IND_BCD").val('<%=indbcd%>');
        	$("#MATNR").val('<%=matnr%>');
        	$("#MATNR_NM").val('<%=matnrNm%>');
        	$("#STCK_QTY").val('<%=stckqty%>');
        	$('#UNIT').val('<%=unit%>');
        	$('#UNIT2').val('<%=unit%>');
        	$('#UNIT3').val('<%=unit%>');
        });
        
        function changeQty(){	// 투입량 체크
        	var inbomqty = $("#IN_BOM_QTY").val();	// 자재 투입량
			
        	if(Number(inbomqty) > Number('<%=stckqty%>')){
        		PlaySound('e');
        		commonUtil.msgBox("재고량보다 투입하려는 수량이 많습니다.", null, null, function(){
        			$("#IN_BOM_QTY").val('');
        			$('#IN_BOM_QTY').focus();
        		});
        	}
        }
        
        /* function unitselect(){	// 단위 선택
     	   	mobile.linkPopOpen('/mobile/UNITPOP.page');
        }
        
        function linkPopCloseEvent(data){
        	$("#UNIT").val(data.get("UNIT"));
        } */
        
        function forcedInp(){	// 자재투입
       		if(Number($("#IN_BOM_QTY").val()) == 0){
       			PlaySound('e');
       			commonUtil.msgBox("투입량을 입력하세요.", null, null, function(){
       				$('#IN_BOM_QTY').focus();
       			});
       			return;
       		}
       		if(Number($('#USE_QTY').val()) == 0){
       			PlaySound('e');
       			commonUtil.msgBox("소요량을 입력하세요.", null, null, function(){
       				$('#USE_QTY').focus();
       			});
       			return;
       		}
       		
       		var param = new DataMap();
       		
       		param.put("P_TYPE", "SAVE");
       		param.put("MMATNR", 'Y');							//강제투입
       		param.put("INMATNR", '<%=matnr%>');					// 투입하위자재
	 		param.put("IND_BCD", '<%=indbcd%>');				// 바코드
	 		param.put("WERKS", '<%=plant%>');					// 플랜트
	 		param.put('USE_QTY', $('#USE_QTY').val());			// 소요량
	 		param.put("INPUT_QTY", $("#IN_BOM_QTY").val());		// bom투입수량
	 		param.put("MACH_CD", '<%=machCd%>');				// 설비
	 		param.put("WRK_ORDR_NO", '<%=WrkOrdrNo%>');			// 작업지시번호
	 		param.put("WRK_ORDR_SEQNO", '<%=WrkOrdrSeqno%>');	// 작업지시순번
	 		param.put('CONTIN_FLG','<%=continflg%>');			//연속투입여부
	 		
	 		commonUtil.msgConfirm("투입하시겠습니까?", null, function(){
	 			netUtil.send({
	 				url : "/mobile/Mobile/PDA_INV02/json/datalist.data",
	 				param : param,
	 				successFunction : "saveSuccessCallBack"
	 		   	});
	 		}, function(){
	 			$('#IND_BCD').focus();
	 		});
        }
        
        function saveSuccessCallBack(json){
     	   if(json.P_SUCCESS == 'Y'){
				PlaySound('s');
 	 			commonUtil.msg("투입되었습니다.");
 	 			
 	 			setTimeout(function(){
 	 				var paramStr = "WRK_ORDR_NO=<%=WrkOrdrNo%>&WRK_ORDR_SEQNO=<%=WrkOrdrSeqno%>&MATNR_NM=<%=matnrNm%>";
 	 	 			
 	 	 			location.href = "/mobile/PDA_INV02.page?" +paramStr;
 	 			},1000);
 	 			
 	 		} else{
 	 			PlaySound('e');
 	 			commonUtil.msg(json.ERR_MSG);
 	 		}
        }

    </script>
</head>
<body>
<div class="main_wrap">
	<div class="main_header_pop">
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
                        <col width="80px"/>
                    </colgroup>
	                    <tbody>
		                    <tr>
		                        <th class="fl" CL="STD_IND_BCD">개별바코드</th>
		                        <td colspan="2">
		                            <input type="text" class="text" id="IND_BCD" readonly="readonly"/>
		                        </td>
		                    </tr>
		                    <tr>
		                        <th class="fl" CL="STD_MATNR">자재코드</th>
		                        <td colspan="2">
		                            <input type="text" class="text" id="MATNR" readonly="readonly"/>
		                        </td>
		                    </tr>
		                    <tr>
		                        <th class="fl" CL="STD_MATNR_NM">자재명</th>
		                        <td colspan="2">
		                            <input type="text" class="text" id="MATNR_NM" readonly="readonly"/>
		                        </td>
		                    </tr>
		                    <tr>
		                        <th class="fl" CL="STD_STCK_QTY">재고량</th>
		                        <td>
		                            <input type="text" class="text" id="STCK_QTY" readonly="readonly"/>
		                        </td>
		                        <td>
		                    		<input type="text" class="text" placeholder="KG" id="UNIT" readonly="readonly" onclick="unitselect();" style="text-align:center;"/>
		                    	</td>
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
	                    <col width="80px"/>
	                </colgroup>
	                <tbody>
	                	<tr>
		                    <td class="fl fw">소요량 입력</td>
		                    <td>
		                    	<input type="text" class="text" placeholder="자재 소요량 입력" id="USE_QTY"/>
		                    </td>
		                    <td>
		                    	<input type="text" class="text" placeholder="KG" id="UNIT2" readonly="readonly" onclick="unitselect();" style="text-align:center;"/>
		                    </td>
		                </tr>
		                <tr>
		                    <td class="fl fw">투입량 입력</td>
		                    <td>
		                    	<input type="text" class="text" placeholder="자재 투입량 입력" id="IN_BOM_QTY" onchange="changeQty();"/>
		                    </td>
		                    <td>
		                    	<input type="text" class="text" placeholder="KG" id="UNIT3" readonly="readonly" onclick="unitselect();" style="text-align:center;"/>
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