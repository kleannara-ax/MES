<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
 <%
 	request.setCharacterEncoding("UTF-8");
	String SEBELN = request.getParameter("SEBELN");
%>
<!doctype html>
<head>
<meta charset="utf-8">
<meta name="viewport" content="user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, width=device-width, target-densitydpi=medium-dpi" />
<meta name="format-detection" content="telephone=no" />
<title>슈피겐코리아 모바일 WMS</title>
<%@ include file="/mobile/include/head.jsp" %>
<script>	
	$(document).ready(function(){
		gridList.setGrid({
	    	id : "gridList",
			editable : false,
			url : '/IF/list/json/MGR06.data',
			bindArea : "searchArea",
			gridMobileType : true
	    });
		
		gridList.setReadOnly("gridList",true, ['LOTA02','LOTA06','LOTA07','LOTA14']);
		searchList();
		
	});
	
	
	function searchList(){
		var param = new DataMap();
		param.put("SEBELN", "<%=SEBELN%>" );
		gridList.gridList({
	    	id : "gridList",
	    	param : param
	    });
		
		showMain();
	}
	
	function showMain() {
		$("#detailInfo").hide();
		$("#main").show();
	}
	
	function showDetail() {
		$("#main").hide();
		$("#detailInfo").show();
	}
	
	
	function saveData(){//반품 입고 확정 
		if(!commonUtil.msgConfirm(configData.MSG_MASTER_SAVE_CONFIRM)){ //저장하시겠습니까?
			return;
		}
		
		if( gridList.getSelectRowNumList("gridList").length == 0 ){
			// 선택된 데이터가 없습니다.
			commonUtil.msgBox("VALID_M0006");
			return;
		} else{
			var param = new DataMap();
			var list = gridList.getSelectData("gridList");
			param.put("list", list); 
			
			if(!importCheck(list) ){
				alert("Invoiceno,수입통관일,수입통관번호는 필수 입니다.");
				//commonUtil.msgBox("VALID_M0006");
				return;
			}

			var vjson = netUtil.sendData({
				url : "/mobile/Mobile/json/validateMobileDailyCheck.data"
			});

			if(vjson.data != "OK"){
				var msgTxt = vjson.data;
				commonUtil.msg(msgTxt);
				return;
			}	
			
			var json = netUtil.sendData({
				url:"/mobile/Mobile/json/SaveMGR06.data",
				param : param
			});  
			
			if(json && json.data){
				commonUtil.msgBox("IN_M0015", json.data["RECVKY"]);
				searchList();
			}else{
				commonUtil.msgBox("VALID_M0002");
			}
		}
	}
	
	function importCheck(list){
		for(i=0; i<list.length; i++){
			if(list[i].get("SZMBLNO") == "8071014"){
				if(list[i].get("USRID2").trim() == ""  || 
				   list[i].get("DEPTID2").trim() == "" || 
				   list[i].get("USRID3").trim() == ""){
					return false;
				}
			}
		}
		return true;
	}	
	//총괄수량 적용
	function totalApplyAll(){
		var rowCnt = gridList.getSelectRowNumList("gridList");
		if(rowCnt.length==0){
			commonUtil.msgBox("VALID_M0006");
			return;
		}else{
			
			for(var i = 0 ; i < rowCnt.length ; i++){
				var getQtsiwh = gridList.getColData("gridList", rowCnt[i], "ASNQTY");
				gridList.setColValue("gridList", rowCnt[i], "QTYRCV", getQtsiwh);
			}
		}
	}
	
	//LOT 적용
	function totalApply(){
		var param = new DataMap();
		var lota05 = $("#LOTA05").val();
		if(lota05.trim() == ""){
			return;
		}
		param.put("LOTA05", lota05);

		var json = netUtil.sendData({
			url:"/mobile/Mobile/json/checkLota05.data",
			param : param
		});
		
		if(json && json.data){
			$("#LOTA05").val("");
			//var qty = json.data["QTPUOM"];
			var skukey = json.data["SKUKEY"];
			
			var List = gridList.getGridData("gridList") ;          
			for(var i=0;i<List.length;i++){
				if(skukey == gridList.getColData("gridList", i, "SKUKEY") ){
					gridList.setColValue("gridList", i, "QTYRCV", 1);
					gridList.setColFocus("gridList", i, "QTYRCV");
					gridList.setRowCheck("gridList", i, true);
					
					/* var asnqty = gridList.getColData("gridList", i, "ASNQTY");	//입고예정수량
					var qtyrcv = gridList.getColData("gridList", i, "QTYRCV");	//입고수량
					var total = parseInt(qtyrcv)+parseInt(qty) ;
					if(parseInt(asnqty) != parseInt(asnqty)){
						if(parseInt(asnqty) >= parseInt(total) ){
							gridList.setColValue("gridList", i, "QTYRCV", total);
							return;
						}else{
							if(List.length > 1){
								for(var j=i+1;j<List.length;j++){
									var asnqty = gridList.getColData("gridList", j, "ASNQTY");	//가용수량
									var qtyrcv = gridList.getColData("gridList", j, "QTYRCV");	//작업수량
									var checkqty = parseInt(qtyrcv)+parseInt(qty) ;
									if(parseInt(asnqty) >= parseInt(checkqty)){
										break;
									}
									if(j == (List.length-1)){
										alert("해당수량을 적용할 상품이 없습니다. 다른 단위로 적용하여 주세요.");
										return;
									}
								}
							}else{
								alert("해당수량을 적용할 상품이 없습니다. 다른 단위로 적용하여 주세요.");
								return;
							}
						}
					}*/
				} 
				
			} 
		}else{
			$("#LOTA05").val("");
			alert("바코드를 다시 확인해주세요.");
			return;
		}
		//$("#LOTA05").focus();
	}  //LOT적용 end

	function sendData(){
		var param = dataBind.paramData("detailInfo");
		mobile.linkPopOpen('/mobile/MGR06_whyfail.page', param );
 	} 
	
	function gridListEventColValueChange(gridId, rowNum, colName, colValue){
 		/* if(colName == "QTFAIL"){
			var asnqty = parseInt(gridList.getColData("gridList", rowNum, "ASNQTY"));
			var qtfail = parseInt(colValue);
			if( qtfail > asnqty ){
				gridList.setColValue("gridList", rowNum, "QTFAIL", 0);
				alert("불합격 수량이 입고수량을 초과합니다.");
				return;
			}else{
				var comqty = asnqty - qtfail ;
				gridList.setColValue("gridList", rowNum, "QTYRCV", comqty);	
			}
			
		}else */ if(colName == "QTYRCV"){
			if(colValue == "" || colValue == "0" ){
				commonUtil.msgBox("IN_M0125"); //입고수량이 0 입니다.
				//gridList.setRowFocus("gridItemList", rowNum, false);
				//gridList.setColFocus("gridItemList", rowNum,"QTYRCV");
				return;
			}
			else{
				var asnqty = parseInt(gridList.getColData("gridList", rowNum, "ASNQTY"));
				var qtyrcv = parseInt(colValue);
				if(asnqty < qtyrcv ){
					gridList.setColValue("gridList", rowNum, "QTYRCV", 0);
					commonUtil.msgBox("IN_M0131"); //입고예정수량 이하로 입력하세요.
					return;
				}
			}

		}
 	}

	function linkPopupOpen(){
		//var $obj = $("LOCAKY");
		mobile.linkPopOpen('/mobile/MGR06_search2.page');
	}
	
	function linkPopCloseEvent(data){
		var LOCAKY = data.get("LOCAKY");
		$("#LOCAKY").val(LOCAKY);
	 }
	
	
	
	function gridListEventRowCheck(gridId, rowNum, checkType){
 		alert("체크 해제 불가합니다.");
 		gridList.checkAll("gridList", true);
 	 }
	
 	function gridListEventDataBindEnd(gridId, dataLength){
		if( dataLength == 0 ){
			location.href="/mobile/MGR06.page";
		}else{
			gridList.checkAll("gridList", true);
		}
 	}
	
 	function clearText(data){
		if(data!=null||data!=""){
	    	data.value="";
	    }      
	}
</script>
</head>
<body>
	<div class="main_wrap" id="main" >
		<div class="tem3_content">
			<div class="searchWrap">
				<table>
					<colgroup>
						<col width="50px"  />
						<col />
						<col width="60px" />
					</colgroup>
					<tbody>
						<tr class="t_title">
							<th>LOT</th>
							<td>
								<input type="text" class="text" id="LOTA05" onkeypress="commonUtil.enterKeyCheck(event, 'totalApply()')" onfocus="clearText(this)"/>
							</td>
							<td>
								<input type="button" value="총괄수량적용" class="bt" onclick="totalApplyAll()"/>
							</td>
						</tr>
					</tbody>
				</table>
			</div>
		</div>
		<div class="tem5_content">
			<div class="tableWrap_search section">
				<div class="tableHeader">
					<table>
						<colgroup>
							<col width="60px" />
								<col width="60px" />
								<col width="80px"/>
								<col width="80px"/>
								<col width="120px"/>
								<col width="120px"/>
								<col width="80px"/>
								<col width="100px"/>
								<col width="100px"/>
								<col width="200px"/>
								<col width="80px"/>
								<col width="80px"/>
								<col width="100px"/>
								<col width="100px"/>
								<col width="80px"/>
								<col width="80px"/>
								<col width="100px"/>
								<col width="100px"/>
								<col width="100px"/>
								<col width="100px"/>
								<col width="100px"/>
								<col width="100px"/>
								<col width="100px"/>
								<col width="100px"/>
								<col width="100px"/>
								<col width="100px"/>
								<col width="100px"/>
								<col width="100px"/>
								<col width="100px"/>
								<col width="100px"/>
								<col width="100px"/>
								<col width="100px"/>
								<col width="100px"/>
								<col width="100px"/>
								<col width="100px"/>
								<col width="100px"/>
								<col width="100px"/>
								<col width="100px"/>
						</colgroup>
						<thead>
							<tr>
								<th CL='STD_NUMBER'></th>
								<th GBtnCheck="true"></th>								
								<th CL='STD_OUTRTNCD'>출고반품입고유형</th>
								<th CL='STD_EBELN'>ERP주문번호</th>
								<th CL='STD_SEBELN'>입고오더번호</th>
								<th CL='STD_REQDAT'>입고요청일자</th>
								<th CL='STD_WAREKYNM'>CenterName</th>
								<th CL='STD_ARCPTD'>입하일자</th>
								<th CL='STD_SKUKEY'>품번코드</th>
								<th CL='STD_DESC01'>품명</th>
								<th CL='STD_ASNQTY'>입고예정수량</th>
								<th CL='STD_QTYRCV'>입고수량</th>
								<th CL='STD_LOCAKY'>Location</th>
								<th CL='STD_TYPENAME'>검사유형</th>
								<th CL='STD_QTSAMP'>시료수</th>
								<th CL='STD_QTFAIL_1'>불량입고수량</th>
								<th CL='STD_RSNCOD'>사유코드</th> 
								<th CL='STD_USRID22'>InvoiceNo</th>
								<th CL='STD_DEPTID22'>수입통관일</th>
								<th CL='STD_USRID33'>수입통관번호</th>
								<th CL='STD_LOTA01'>원산지</th>
								<th CL='STD_LOTA02'>관리부서</th>
								<th CL='STD_LOTA03'>임가공업체</th>			
								<th CL='STD_LOTA05'>박스번호</th>
								<th CL='STD_LOTA06'>재고유형</th>
								<th CL='STD_LOTA07'>발주부서</th>
								<th CL='STD_LOTA08'>생산업체</th>
								<th CL='STD_LOTA11'>생산일자</th>
								<th CL='STD_LOTA13'>포장일자</th>
								<th CL='STD_LOTA14'>재고부서</th>
								<th CL='STD_UOMKEY'>단위</th>
								<th CL='STD_QTYUOM'>입수</th>
								<th CL='STD_BOXQTY'>박스수</th>
								<th CL='STD_REMQTY'>잔량</th>
								<th CL='STD_REQNO'>요청번호</th>
								<th CL='STD_DPTNKY'>업체코드</th>
								<th CL='STD_DPTNKYNM'>업체코드명</th>
								<th CL='STD_DOCTXT'>비고</th>
							</tr>
						</thead>
					</table>				
				</div>					
				<div class="tableBody">
					<table>
						<colgroup>
								<col width="60px" />
								<col width="60px" />
								<col width="80px"/>
								<col width="80px"/>
								<col width="120px"/>
								<col width="120px"/>
								<col width="80px"/>
								<col width="100px"/>
								<col width="100px"/>
								<col width="200px"/>
								<col width="80px"/>
								<col width="80px"/>
								<col width="100px"/>
								<col width="100px"/>
								<col width="80px"/>
								<col width="80px"/>
								<col width="100px"/>
								<col width="100px"/>
								<col width="100px"/>
								<col width="100px"/>
								<col width="100px"/>
								<col width="100px"/>
								<col width="100px"/>
								<col width="100px"/>
								<col width="100px"/>
								<col width="100px"/>
								<col width="100px"/>
								<col width="100px"/>
								<col width="100px"/>
								<col width="100px"/>
								<col width="100px"/>
								<col width="100px"/>
								<col width="100px"/>
								<col width="100px"/>
								<col width="100px"/>
								<col width="100px"/>
								<col width="100px"/>
								<col width="100px"/>
						</colgroup>
						<tbody  id="gridList">
							<tr CGRow="true">
								<td GCol="rownum">1</td>
								<td GCol="rowCheck"></td>
							    <td GCol="text,SZMBLNONM">출고반품입고유형</td>                                              
								<td GCol="text,SEBELN">ERP주문번호</td> 
								<td GCol="text,WMSREQSEQ">입고오더번호</td>                                                   
								<td GCol="text,REQDAT">입고요청일자</td>                                                  
								<td GCol="text,WAREKYNM">CenterName</td>                                              
								<td GCol="text,ARCPTD" GF="C N">입하일자</td>                                           
								<td GCol="text,SKUKEY"></td>                                                          
								<td GCol="text,DESC01"></td>                                                          
								<td GCol="text,ASNQTY"  GF="N 20"></td>                                                 
								<td GCol="input,QTYRCV" GF="N 20"></td>                                                
								<td GCol="input,LOCAKY" GF="S 20"></td>     
								<td GCol="text,TYPENAME"></td>                                                         
								<td GCol="text,QTSAMP"  GF="N 20">시료수</td>                                              
								<td GCol="input,QTFAIL" GF="N 20">불량입고수량</td>                                         
								<td GCol="select,RSNCOD" >
									<select Combo="WmsInbound,GR01RSNCOD" name="RSNCOD">
										<option value="">선택</option>
									</select>
								</td>
								<td GCol="input,USRID2">InvoiceNo</td>
								<td GCol="input,DEPTID2" GF="C N">수입통관일</td>
								<td GCol="input,USRID3">수입통관번호</td>
								<td GCol="select,LOTA01">						
									<select Combo="WmsAdmin,LOTA01COMBO" >
										<option value="">선택</option>
									</select>
								</td>  
								<td GCol="select,LOTA02">
									<select Combo="WmsInventory,ERPWAREHOUSE" >
										<option value="">선택</option>
									</select>
								</td>
								<td GCol="text,LOTA03" GF="S 20"></td>
								<td GCol="text,LOTA05" GF="S 20"></td>
								<td GCol="select,LOTA06">
									<select CommonCombo="LOTA06">
										<option value="">선택</option>
									</select>
								</td>
								<td GCol="select,LOTA07">
									<select Combo="WmsAdmin,LOTA07COMBO" >
										<option value="">선택</option>
									</select>
								</td> 
								<td GCol="input,LOTA08" GF="S 20"></td>
								<td GCol="input,LOTA11" GF="C 8"></td>
								<td GCol="input,LOTA13" GF="C 8"></td>
								<td GCol="select,LOTA14">
                               		<select CommonCombo="LOTA14" >
                                 		<option value=""> </option>
                              		</select>
                              	</td>
								<td GCol="text,UOMKEY"></td>
								<td GCol="text,QTYUOM" GF="N 20"></td>  
								<td GCol="text,BOXQTY" GF="N 20"></td>   
								<td GCol="text,REMQTY" GF="N 20"></td>
								<td GCol="text,REQNO"></td>
								<td GCol="text,DPTNKY"></td>
								<td GCol="text,DPTNKYNM"></td>
								<td GCol="input,DOCTXT" GF="S 255"></td>
							</tr>
						</tbody>
					</table>
				</div>
				</div>
				<!-- end table_body -->
				<div class="footer_5">
					<table>
						<tr>
							<td class=f_1 onclick ="saveData()">입하완료</td>
							<td onclick="showDetail()">상세정보</td>
							<td onclick="searchList()">새로고침</td>
						</tr>
					</table>
				</div><!-- end footer_5 -->	
			</div>
	</div>
	<div class="detailInfo_wrap" id="detailInfo">
		<h2 class="info_title">상세정보</h2>
		<div class="d_table_wrap">
			<div id="searchArea">	
			<table class="info_table">
					<colgroup>
						<col width="100px"/>
						<col />
						<col width="65px"/>
						<col />
					</colgroup>
					<tbody >
						<tr>
							<th>#ERP주문번호</th>
							<td>
								<input type="hidden" name="WAREKY" />
								<input type="hidden" name="JOBTYP" />
							
								<span class="inp_group">
									<input type="text" id="SEBELN" name="SEBELN" readonly="readonly" />
								</span>
							</td>
							<th class="right" style="text-indent: 5px;">ITEM</th>
							<td>
								<span class="inp_group">
									<input type="text" id="SEBELP" name="SEBELP" readonly="readonly" />
								</span>
							</td>
						</tr>
						<tr>
							<th>품번</th>
							<td colspan=3>
								<span class="inp_group">
									<input type="text" id="SKUKEY" name="SKUKEY" readonly="readonly" />
								</span>
							</td>
						</tr>
						<tr>
							<th>품명</th>
							<td colspan=3>
								<span class="inp_group">
									<input type="text" style="height:70px" id="DESC01" name="DESC01" readonly="readonly" />
								</span>
							</td>
						</tr>
						<tr>
							<th>입고예정수량</th>
							<td>
								<span class="inp_group">
								<input type="text" class="s" name="ASNQTY" readonly="readonly" />
								</span>
							</td>
							<th class="right">사유코드</th>
							<td>
								<span class="inp_group">
									<select Combo="WmsInbound,GR01RSNCOD" id="RSNCOD" name="RSNCOD" />
										<option value="">선택</option>
									</select>
								</span>
							</td>
							
							<!-- <td>
								<span class="inp_group">
								<select class="s"></select>
								</span>
							</td> -->
						</tr>
						<tr>
							<th>입하량</th>
							<td>
								<span class="inp_group">
									<input type="text"  name="QTYRCV" />
								</span>
							</td>
							<!-- <td>EA</td> -->
						</tr>
						<!-- <tr>
							<th></th>
							<td>
								<span class="inp_group">
									<input type="text" name="BOXQTY" readonly="readonly">
								</span>
							</td>
							<td>BOX</td>
						</tr> -->
						<tr>
							<th>입하지번</th>
							<td>
								<span class="inp_group">
									<input type="text" class="text" name="LOCAKY" id="LOCAKY" />
								</span>
							</td>
							<td class="nopadding">
								<input type="button" value="p" onclick="linkPopupOpen()"/> 
							</td>
						</tr>
						<tr>
							<th>검사유형</th>
							<td>
								<span class="inp_group">
									<input type="text" name="TYPENAME" readonly="readonly"/>
								</span>
							</td>
							<th>시료수</th>
							<td>
								<span class="inp_group">
									<input type="text" name="QTSAMP" />
								</span>
							</td>
						</tr>
						<tr>
							<th>불합격수량</th>
								<td>
									<span class="inp_group">
										<input type="text" name="QTFAIL" />
									</span>
								</td>
								<td class="nopadding">
									<input type="button" value="P" onclick="sendData()" />
								</td>
						</tr>
						<tr>
							<th>InvoiceNo</th>
							<td>
								<span class="inp_group">
									<input type="text" name="USRID2" />
								</span>
							</td>
						</tr>
						<tr>
							<th>수입통관일</th>
							<td>
								<span class="inp_group">
									<input type="text" name="DEPTID2"  UIFormat="C"/>
								</span>
							</td>
							<th>수입통관번호</th>
							<td>
								<span class="inp_group">
									<input type="text" name="USRID3" />
								</span>
							</td>
						</tr>
						<tr>
							<th>원산지</th>
							<td>
								<span class="inp_group">
									<select Combo="WmsAdmin,LOTA01COMBO" name="LOTA01" >
											<option value="">선택</option>
									</select>
								</span>
							</td>
							<th>생산업체</th>
							<td>
								<span class="inp_group">
									<input type="text" name="LOTA08" />
								</span>
							</td>
						</tr>
						<tr>
							<th>생산일자</th>
							<td>
								<span class="inp_group">
									<input type="text" name="LOTA11" UIFormat="C" />
								</span>
							</td>
							<th>포장일자</th>
							<td>
								<span class="inp_group">
									<input type="text" name="LOTA13" UIFormat="C"/>
								</span>
							</td>
						</tr>
						<tr>
							<th>비고</th>
							<td>
								<span class="inp_group">
									<input type="text" name="DOCTXT" />
								</span>
							</td>
						</tr>
					</tbody>
			</table>
			</div>	
		</div>
		
		<div class="footer_5">
			<table>
				<tr>
					<td onclick="gridList.setPreRowFocus('gridList')">&lt;</td>
					<td class=f_1 onclick="showMain()">닫기</td>
					<td onclick="gridList.setNextRowFocus('gridList')">&gt;</td>
				</tr>
			</table>
		</div><!-- end footer_5 -->
</div>
</body>