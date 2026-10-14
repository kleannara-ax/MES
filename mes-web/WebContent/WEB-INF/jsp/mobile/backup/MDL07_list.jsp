<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%
	String STKNUM = request.getParameter("STKNUM");
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
			module : "Mobile",
			command : "MDL07",
			bindArea : "searchArea",
			gridMobileType : true
	    });
		
		searchList();	
	});
	
	function searchList(){
		showMain();
		
		var param = new DataMap();
		param.put("STKNUM", "<%=STKNUM%>");
		
		gridList.gridList({
	    	id : "gridList",
	    	param : param
	    });
	}
	
	function showMain() {
		$("#detailInfo").hide();
		$("#main").show();
	}
	function showDetailInfo() {
		$("#main").hide();
		$("#detailInfo").show();
	}
	
	function showDetail(){ 
		showDetailInfo();
	}
	
	function saveAll(){
		var selectList = gridList.getSelectData("gridList");
		if(selectList.length == 0){
			alert("선택된 데이터가 없습니다.");
			return;
		} else{
			var chkList = gridList.getSelectData("gridList");
			
			var inoqty;
			var stknum;
			var skukey;
			var chkList = gridList.getSelectData("gridList");

			for(var i = 0 ; i < chkList.length ; i ++){
				inoqty = gridList.getColData("gridList", i, "INOQTY");
				if(inoqty == 0){
					stknum = gridList.getColData("gridList", i, "STKNUM");
					skukey = gridList.getColData("gridList", i, "SKUKEY");
					
					alert("총괄지시번호/품번 : "+ stknum + "/" + skukey + " 의 작업수량을 입력하세요.");
					return;
				}
				
			}
			
			var param = new DataMap();
			param.put("chkList",chkList);
			
			var json = netUtil.sendData({
				url:"/mobile/Mobile/json/SaveMDL07.data",
				param : param
			});
			
			if(json && json.data){
				alert("저장 완료");
				searchList();
				//showMain();
			}
		}	
	}
	

	
	function linkPopupOpen(){
		var rowNum = gridList.getFocusRowNum('gridList');
		var param = gridList.getRowData('gridList',rowNum);
		mobile.linkPopOpen('/mobile/MDL07_TO.page',param);
	}
	
	function gridListEventColValueChange(gridId, rowNum, colName, colValue){
		if(gridId=="gridList" && colName=="INOQTY"){	//작업수량 column
			var trnqty = parseInt(gridList.getColData("gridList", rowNum, "TRNQTY"));	//가용수량
			var inoqty = parseInt(colValue);	//작업수량
			
			if(trnqty < inoqty){
				alert("작업수량은 가용수량을 초과할 수 없습니다.");
				gridList.setColValue("gridList", rowNum, "INOQTY", "0");
			} else{
				var piece = trnqty-inoqty;//잔량=가용수량-작업수량
				gridList.setColValue("gridList", rowNum, "PIECE", piece);
			}
		}
	}

	
	function gridListEventDataBindEnd(gridId, dataLength){
		if( dataLength == 0 ){
			location.href="/mobile/MDL07.page";
		}
		calcItem();
 	}
	
	function calcItem() {
		var rowNum = gridList.getGridDataCount("gridList");
		var sumTrnqty=0;
		var trnqtyVal=0;
		var	countSku=0;
		var param = new DataMap();
		param.put("STKNUM", "<%=STKNUM%>");
		var json = netUtil.sendData({
			id : "main",
			module : "Mobile",
			command : "MDL07CHK",
			param : param,
			sendType : "map"
		});
		//alert(json.data.CNTSKU);
		
		for (var i = 0 ; i < rowNum ; i++){
		//	countSku =gridList.getColData("gridList", i, "CNTSKU");
			trnqtyVal = Number(gridList.getColData("gridList", i, "TRNQTY"));
			sumTrnqty += trnqtyVal
		//	alert(countSku);
		}
		$("#GRSITEM").html(json.data.CNTSKU);
		$("#SUMITEM").html(sumTrnqty);
	}
	
	//총괄수량적용
	function totalApplyAll(){
		var rowCnt = gridList.getSelectRowNumList("gridList");
		if(rowCnt.length==0){
			commonUtil.msgBox("VALID_M0006");
		}else{
			for(var i = 0 ; i <  rowCnt.length ; i++){
				var getAvailable = gridList.getColData("gridList", rowCnt[i], "TRNQTY");
				gridList.setColValue("gridList", rowCnt[i], "INOQTY", getAvailable);
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
			var qty = json.data["QTPUOM"];
			var skukey = json.data["SKUKEY"];
			
			var List = gridList.getGridData("gridList") ;          
			for(var i=0;i<List.length;i++){
				if(skukey == gridList.getColData("gridList", i, "SKUKEY") ){
					var trnqty = gridList.getColData("gridList", i, "TRNQTY");	//가용수량
					var inoqty = gridList.getColData("gridList", i, "INOQTY");	//작업수량
					var total = parseInt(inoqty)+parseInt(qty) ;
					if(parseInt(inoqty) != parseInt(trnqty)){
						if(parseInt(trnqty) >= parseInt(total) ){
							gridList.setColValue("gridList", i, "INOQTY", total);
							return;
						}else{
							if(List.length > 1){
								for(var j=i+1;j<List.length;j++){
									var trnqty = gridList.getColData("gridList", j, "ASNQTY");	//가용수량
									var inoqty = gridList.getColData("gridList", j, "INOQTY");	//작업수량
									var checkqty = parseInt(inoqty)+parseInt(qty) ;
									if(parseInt(trnqty) >= parseInt(checkqty)){
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
					}
				}
				
			} 
		}else{
			$("#LOTA05").val("");
			alert("바코드를 다시 확인해주세요.");
			return;
		}
		$("#LOTA05").focus();
	}  //LOT적용 end

</script>
</head>

<body>
	<div class="main_wrap" id="main" >
	   <div class="tem3_content">
			<div class="top_search">
			<!-- 
				<table>
					<colgroup>
						<col width="70px"  />
						<col />
						<col width="60px" />
					</colgroup>
					<tbody>
						<tr class="t_title">
							<th>LOT</th>
							<td>
								<input type="text" class="text" id="LOTA05" onkeypress="commonUtil.enterKeyCheck(event, 'totalApply()')"/>
							</td>
							<td>

								<input type="button" value="총괄수량적용" class="bt" onclick="totalApplyAll()"/>

							</td>
						</tr>
					</tbody>
				</table>
			 -->	
				<table style="width: 100%">
					<colgroup>
						<col width="80px"  />
						<col />
						<col width="80px" />
						<col/>
					</colgroup>
					<tbody>
						<tr>
							 <th>&nbsp;총품목수 :</th>
							<td>
	<!-- 								<input type="text" class="text" readonly="readonly" id="GRSITEM" name="GRSITEM"/> -->
								<div id ="GRSITEM" ></div>
							</td>
							<th>총수량 :</th>
							<td>
								<div id ="SUMITEM"></div>
							</td>
						</tr>
					</tbody>	
				</table>
			</div>
		</div>
		<div class="tem5_content">
			<div class="tableWrap_search section">
				<div class="tableHeader">
					<table style="width: 100%">
						<colgroup>
								<col width="60px" />
								<col width="60px" />
								<col width="100px" />
								<col width="200px" />
								<col width="100px" />
								<col width="100px" />
								<col width="100px"/>
								<col width="100px"/>
								<col width="120px"/>
								<!-- <col width="100px"/> -->
						</colgroup>
						<thead>
							<tr class="thead">
								<th>번호</th>
								<th GBtnCheck="true"></th>
								<th>품번</th>
								<th>품명</th>
								<th>가용수량</th>
								<th>작업수량</th>
								<!-- <th>박스수량</th> -->
								<th>잔량</th>
								<th>지번</th>
								<th>총괄지시번호</th>
							</tr>
						</thead>
					</table>				
				</div>			
				<!-- end tableHeader -->
				
						
				<div class="tableBody">
					<table style="width: 100%">
						<colgroup>
								<col width="60px" />
								<col width="60px" />
								<col width="100px" />
								<col width="200px" />
								<col width="100px" />
								<col width="100px" />
								<col width="100px"/>
								<col width="100px"/>
								<col width="120px"/>
							<!-- <col width="100px"/> -->
						</colgroup>
						<tbody id="gridList">
							<tr CGRow="true">
								<input type="hidden" id ="CNTSKU" name="CNTSKU"/>
								<td GCol="rownum"></td>
								<td GCol="rowCheck"></td>
								<td GCol="text,SKUKEY"></td>
								<td GCol="text,DESC01"></td>					
								<td GCol="text,TRNQTY"></td>				
								<td GCol="text,INOQTY" GF="N 5"></td>					
								<!-- <td GCol="text,BOXCNT"></td> -->					
								<td GCol="text,PIECE"></td>
								<td GCol="text,LOCASR"></td>
								<td GCol="text,STKNUM"></td>
							</tr>
						</tbody>
					</table>
				</div>
				<!-- end tableBody -->
				
				
			</div>
			<!-- end tableWrap_search -->
			
			
			<div class="footer_5">
				<table>
					<tr>
						<td onclick="saveAll()" class=f_1>피킹완료</td>
						<td onclick="showDetail()">상세정보</td>
						<td onclick="searchList()">새로고침</td>
					</tr>
				</table>
			</div>
			<!-- end footer_5 -->	
			
			
		</div>
		<!-- end tem5_content -->
		
		
	</div>
	<!-- end main_wrap -->
	
	
	
	<div class="detailInfo_wrap" id="detailInfo">
		<h2 class="info_title">상세정보</h2>
		<div class="d_table_wrap">
			<div id="searchArea">	
				<table class="info_table">
					<colgroup>
						<col width="100px"/>
						<col />
						<col width="50px"/>
						<col />
					</colgroup>
					<tbody >
						<tr>
							<th>#총괄지시번호</th>
							<td colspan=3>
								<span class="inp_group">
									<input type="text" name="STKNUM" readonly="readonly">
								</span>
							</td>
						</tr>
						<tr>
							<th>품번</th>
							<td colspan=3>
								<span class="inp_group">
									<input type="text" name="SKUKEY" readonly="readonly" />
								</span>
							</td>
						</tr>
						<tr>
							<th>품명</th>
							<td colspan=3>
								<span class="inp_group">
									<input type="text" style="height:70px" name="DESC01" readonly="readonly" /> 
								</span>
							</td>
						</tr>
						<tr>
							<th>가용수량</th>
							<td colspan=3>
								<span class="inp_group">
									<input type="text" class="s" name="TRNQTY" readonly="readonly"/>
								</span>
							</td>
						</tr>
						<tr>
							<th>작업수량</th>
							<td>
								<span class="inp_group">
									<input type="text" name="INOQTY" readonly="readonly"/>
								</span>
							</td>
							<!-- <td>EA</td> -->
						</tr>
						<tr>
							<!-- <th>BOX</th>
							<td>
								<span class="inp_group">
									<input type="text" name="BOXCNT" readonly="readonly" />
								</span>
							</td> -->
							<!-- <th class="right">잔량</th> -->
							<th>잔량</th>
							<td>
								<span class="inp_group">
									<input type="text" name="PIECE" readonly="readonly" />
								</span>
							</td>
						</tr>
						<tr>
							<th>FROM지번</th>
							<td colspan=3>
								<span class="inp_group">
									<input type="text" name="LOCASR" readonly="readonly" />
								</span>
							</td>
						</tr>
						<tr>
							<th>TO지번</th>
							<td class="MDL07_nopadding">
								<input type="button" value="P" onclick="linkPopupOpen()">
							</td>
						</tr>
					</tbody>
				</table>
			</div>
		</div>
		<!-- end d_table_wrap -->
		
		
		<div class="footer_5">
			<table>
				<tr>
					<td onclick="gridList.setPreRowFocus('gridList')">&lt;</td>
					<td class=f_1 onclick="showMain()">닫기</td>
					<td onclick="gridList.setNextRowFocus('gridList')">&gt;</td>
				</tr>
			</table>
		</div>
		<!-- end footer_5 -->
		
		
	</div>
	<!-- end detailInfo_wrap -->

</body>