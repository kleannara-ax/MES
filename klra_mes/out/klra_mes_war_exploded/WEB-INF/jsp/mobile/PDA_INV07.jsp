<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
	String procCd = (String)request.getSession().getAttribute(CommonConfig.SES_PROC_CD);
	String machCd = (String)request.getSession().getAttribute(CommonConfig.SES_MACH_CD);
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
    	var prfmDt;
    	
        $(document).ready(function(){
        	gridList.setGrid({
				id : "gridList",
		    	url : "/mobile/Mobile/PDA_INV07/json/datalist.data",
		    	bigdata : false,
		    	gridMobileType : true
			});
        	//새로고침
        	searchList();
        	//실적일자 조회
        	searchList2();
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
        	
			param.put("P_TYPE", "LIST");
			param.put("WERKS", '<%=plant%>');
			param.put("MACH_CD", '<%=machCd%>');
			
			gridList.gridList({
				id : "gridList",
				param : param
			});
		}
        
        function searchList2(){
        	var param = new DataMap();
        	
        	param.put("P_TYPE", "LIST2");
        	
        	var json = netUtil.sendData({
   			   	url : "/mobile/Mobile/PDA_INV07/json/datalist.data",
				param : param
   		   	});
        	
        	if(json.P_SUCCESS = 'Y'){
        		var date = json.data[0].DT.substr(0, 4) + '-' + json.data[0].DT.substr(4, 2) + '-' + json.data[0].DT.substr(6,2); 
        		
        		$("#PRFM_DT").val(date);
        		
        		prfmDt = json.data[0].DT;
        	}
        }
        
        function gridListEventDataBindEnd(gridId, dataLength){
            if(dataLength > 0){
                PlaySound("s");
            }else{
                PlaySound("e");
            }
        }
        //실적일자 수정체크
        function changeDate(){
        	var prfmdt = $("#PRFM_DT").val();
        	
        	var date = commonUtil.replaceAll(prfmdt, "-", "");
        	
        	prfmDt = date;
        }
        
        function gridListEventRowCheck(gridId, rowNum, checkType){
        	if(checkType == true){
        		var stckqty = gridList.getColData(gridId, rowNum, 'STCK_QTY');
        		var unit = gridList.getColData(gridId, rowNum, 'UNIT');
        		
        		$("#STCK_QTY").val(stckqty);
        		$("#UNIT").val(unit);
        		$("#UNIT2").val(unit);
        	}
        }
        
        function unitselect(flag){	// 단위 선택
			mobile.linkPopOpen('/mobile/UNITPOP.page', flag);
        }
        
        function linkPopCloseEvent(data){
        	if(data.get("flag") == "1"){
        		$("#UNIT").val(data.get("UNIT"));
        	}else{
        		$("#UNIT2").val(data.get("UNIT"));
        	}
        }
        
        function changeQty(){
        	var chgqty = $("#CHG_QTY").val();
        	
        	gridList.setColValue("gridList", gridList.getFocusRowNum("gridList"), "CHG_QTY", chgqty);
        }
        
        function showMain() {
            window.top.menuOpen();
        }
        //등록
        function register(){
        	var list = gridList.getSelectData("gridList");
        	
        	if(list.length == 0){
        		commonUtil.msg("잔량보정할 자재를 선택하세요.");
        		return;
        	}
        	
        	for(var i = 0; i < list.length; i++){
        		if(list[i].get('CHG_QTY').trim() == ''){
        			commonUtil.msg('선택한 자재 중 ' + (i + 1) + '번째 보정수량이 입력되어 있지 않습니다.');
        			return;
        		}
        	}
        	
        	var param = new DataMap();
        	
        	param.put("P_TYPE", "SAVE");
        	param.put("WERKS", '<%=plant%>');
			param.put("MACH_CD", '<%=machCd%>');
			param.put("PRFM_DT", prfmDt);
        	
        	param.put("list", list);
        	
        	commonUtil.msgConfirm("등록하시겠습니까?", null, function(){
        		netUtil.send({
      			   	url : "/mobile/Mobile/PDA_INV07/json/datalist.data",
      			   	param : param,
      			   	successFunction : "saveSuccessCallBack"
      		   });
        	});
        }
        
        function saveSuccessCallBack(json){
        	if(json.P_SUCCESS = 'Y'){
        		commonUtil.msgBox("자재보정되었습니다.", null, null, function(){
        			$('#STCK_QTY').val('');
            		$("#CHG_QTY").val('');
        			searchList();
        		});
        	}else{
        		commonUtil.msgBox('VALID_M0002');
        	}
        }
    </script>
</head>
<body>
<div class="main_wrap">
	<div class="main_header">
		<ul>
			<li class="tit" id="title" style="width:100%;">일마감-자재보정</li>
		</ul>
	</div>
    <div class="tem4_content">
        <div class="select_box" id="bindArea">
            <div id="searchArea">
                <table>
                    <colgroup>
                    	<col>
                        <col>
                    </colgroup>
                    <tbody>
                    <tr>
                    	<th>실적일자</th>
						<td>
							<input type="text" class="input" id="PRFM_DT" UIFormat="C" style="padding:4px; margin-top:5px; text-align:center;" onchange = 'changeDate();'/>
						</td>
                        <td>
							<button class="bt" style="height: 36px;" onclick="searchList()">새로고침</button>
						</td>
                    </tr>
                    </tbody>
                </table>
            </div>
            <div class="tableWrap_search">
				<div class="tableHeader">
					<table style="width: 160%">
						<colgroup>
							<col width="10px" />
							<col width="10px" />
							<col width="20px" />
							<col width="30px" />
							<col width="30px" />
							<col width="30px" />
							<col width="15px" />
							<col width="30px" />
						</colgroup>
						<thead>
						<tr>
							<th>No.</th>
							<th>선택</th>
							<th>자재코드</th>
							<th>자재명</th>
							<th>LOT_NO</th>
							<th>잔량</th>
							<th>단위</th>
							<th>보정수량</th>
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
							<col width="30px" />
							<col width="30px" />
							<col width="30px" />
							<col width="15px" />
							<col width="30px" />
						</colgroup>
						<tbody id="gridList">
							<tr CGRow="true">
								<td GCol="rownum"></td>
								<td GCol="rowCheck"></td>
								<td GCol="text,MATNR" style="text-align:center;"></td>		<!-- 자재코드 -->
								<td GCol="text,MATNR_NM"></td>								<!-- 자재명 -->
								<td Gcol="text,LOT_NO"></td>								<!-- LOT 번호 -->
								<td GCol="text,STCK_QTY" GF="N 10,3"></td>					<!-- 잔량 -->
								<td GCol="text,UNIT" style="text-align:center;"></td>		<!-- 단위 -->
								<td GCol="text,CHG_QTY" GF="N 10,3"></td>						<!-- 보정수량 -->
							</tr>
						</tbody>
					</table>
				</div>
        	</div>
        	
        	<div class="tableWrap_search" style="display:none">
				<div class="tableHeader">
					<table style="width: 150%">
						<colgroup>
							<col width='0px'/>
							<col width='0px'/>
							<col width='0px'/>
							<col width='0px'/>
							<col width='0px'/>
						</colgroup>
						<thead>
						<tr>
							<th>개별바코드</th>
							<th>작업지시번호</th>
							<th>작업지시순번</th>
							<th>WMS 속성 키</th>
							<th>WMS LOT속성 키</th>
						</tr>
						</thead>
					</table>
				</div>
				<div class="tableBody">
					<table style="width: 150%;">
						<colgroup>
							<col width='0px'/>
							<col width='0px'/>
							<col width='0px'/>
							<col width='0px'/>
							<col width='0px'/>
						</colgroup>
						<tbody id="gridList">
							<tr CGRow="true">
								<td GCol="text,IND_BCD"></td>								<!-- 개별바코드 -->
								<td GCol="text,WRK_ORDR_NO"></td>							<!-- 작업지시번호 -->
								<td GCol="text,WRK_ORDR_SEQNO"></td>						<!-- 작업지시순번 -->
								<td GCol="text,STCK_KY"></td>								<!-- WMS 속성키 -->
								<td GCol="text,LOT_NUM"></td>								<!-- WMS LOT속성키 -->
							</tr>
						</tbody>
					</table>
				</div>
        	</div>
        </div>
        
        <div class="footer_4" style="height: 135px;">
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
	                    <td class="fl fw">잔량</td>
	                    <td colspan="2">
	                    	<input type="text" class="text" id="STCK_QTY" readonly="readonly" style="text-align:center;"/>
	                    </td>
	                    <td>
	                    	<input type="text" class="text" placeholder="KG" id="UNIT" readonly="readonly" onclick="unitselect(1);" style="text-align:center;"/>
	                    </td>
	                </tr>
	                <tr>
	                    <td class="fl fw">실잔량</td>
	                    <td colspan="2">
	                    	<input type="text" class="text" placeholder="보정할 수량 입력" id="CHG_QTY" onchange="changeQty();" UIFormat='N 5' style="text-align:center;"/>
	                    </td>
	                    <td>
	                    	<input type="text" class="text" placeholder="KG" id="UNIT2" readonly="readonly" onclick="unitselect(2);" style="text-align:center;"/>
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
                    <td class="f_1" onclick ="register()" style="width:50%">등록</td>
                </tr>
            </table>
        </div><!-- end footer_5 -->
    </div>
</div>
</body>