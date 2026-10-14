<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%
	String SKUKEY = request.getParameter("SKUKEY");
	String LOCAKY = request.getParameter("LOCAKY");
%>
<!doctype html>
<head>
<meta charset="utf-8">
<meta name="viewport" content="user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, width=device-width, target-densitydpi=medium-dpi" />
<meta name="format-detection" content="telephone=no" />
<title>슈피겐코리아 모바일 WMS</title>
<%@ include file="/mobile/include/head.jsp"%>
<script>	
	$(document).ready(function(){
		
		gridList.setGrid({
			id : "gridList",
			editable : false,
			module : "Mobile",
			command : "MGR09",
			bindArea : "searchArea",
			gridMobileType : true
	    });
	
		searchList();
		
	});
	
	/*// 가용수량에 숫자만 입력되도록
	$(document).on("keyup","#QTTAOR",function(){
		$(this).val($(this).val().replace(/[^0-9]/gi,""));
	}); */
		
	function searchList(){
		showMain();
		// if(validate.check("searchArea")){ 
			var param = new DataMap();
			param.put("SKUKEY", "<%=SKUKEY%>");
			param.put("LOCAKY","<%=LOCAKY%>");
			
			gridList.gridList({
		    	id : "gridList",
		    	param : param
		    });
			
		// } 
		
	}
		
	function clearText(data){
		if(data!=null||data!=""){
	    	data.value="";
	    }      
	}
	
	/* function saveDetail(){
		var $avlqty = $("#AVAILABLEQTY");	//가용수량
		var $qttaor = $("#QTTAOR");			//작업수량
		
		if($avlqty.val() < $qttaor.val()){
			commonUtil.msgBox("VALID_M0923");
			//alert("작업수량은 가용수량을 초과할 수 없습니다.");
			$qttaor.val($avlqty.val());
			return;
		} else{
			var rowNum = gridList.getFocusRowNum("gridList");
			var param = gridList.getRowData("gridList",rowNum);
			
			param.put("LOGSEQ",'1');
			
			var json = netUtil.send({
				id : "detailInfo",
				module : "Mobile",
				command : "MGR09",
				param : param,
				sendType : "insert"
			});
				
			//alert("저장 완료");
			commonUtil.msgBox("VALID_M0001");
			showDetail();
		}
	}  */
	
	//TO지번 Check
	//상품 혼적, LOT혼적 Check
	/* function saveCheck(rowNum){
		var param = new DataMap();
		
		var colValue = gridList.getColData("gridList", rowNum, "LOCATG");
		param.put("LOCAKY", colValue);
		
		if(colValue==" " || colValue==""){
			//alert("TO지번을 입력해주세요.");
			commonUtil.msgBox("COMMON_M0009","TO지번");
			gridList.setColFocus("gridList", rowNum, "LOCATG");
			return false;
		}
		
		var skukey = gridList.getColData("gridList", rowNum, "SKUKEY");
		var lotnum = gridList.getColData("gridList", rowNum, "LOTNUM"); 
		param.put("SKUKEY",skukey);
		param.put("LOTNUM",lotnum);
		
		var json = netUtil.sendData({
			url : "/mobile/Mobile/json/LocakyCheck.data",
			param : param
		});
		
		
		if (json.data == 0){
			//alert("존재하지 않는 지번입니다.");
			commonUtil.msgBox("VALID_M0204", colValue);
			gridList.setColValue("gridList", rowNum, "LOCATG", "");
			gridList.setColFocus("gridList", rowNum, "LOCATG");
			return false;
		}
		else if(json.data == -1){
			alert("["+colValue+"]"+"는 상품 혼적을 할 수 없습니다.");// messegeUtil
			gridList.setColValue("gridList", rowNum, "LOCATG", "");
			gridList.setColFocus("gridList", rowNum, "LOCATG");
			return false;
		} 
		else if (json.data == -2){
			alert("["+colValue+"]"+"는 LOT 혼적을 할 수 없습니다.");// messegeUtil
			gridList.setColValue("gridList", rowNum, "LOCATG", "");
			gridList.setColFocus("gridList", rowNum, "LOCATG");
			return false;
		} 
		
		return true;
	} */
	
	function saveData(){
		var selectList = gridList.getSelectRowNumList("gridList");
		
		if(selectList.length == 0){
			//alert("선택된 데이터가 없습니다.");
			commonUtil.msgBox("VALID_M0006");
			return;
		}  else{
			/* for(var i=0; i<selectList.length; i++){
				var rowNum = selectList[i];
				if(!saveCheck(rowNum)){
					return;
				}
			} */
			var chkList = gridList.getSelectData("gridList");
			
			var param = new DataMap();
			param.put("chkList",chkList);
				
			var json = netUtil.sendData({
				url:"/mobile/Mobile/json/SaveMGR09.data",
				param : param
			});
				
			/* if(json && json.data) */
			if(json.data == 0){
				//alert("저장 완료");
				commonUtil.msgBox("VALID_M0001");
				searchList();
				//showMain();
			}/*  else{
				commonUtil.msgBox("VALID_M0002");
				//alert("저장이 실패하였습니다.");
			} */
		} 
	}

	function showMain() {
		$("#detailInfo").hide();
		$("#main").show();
	}
	
	/* function showDetail(){ 
		var chkCount = gridList.getSelectRowNumList("gridList").length;
		
		if(chkCount == 0){
			//alert("선택된 데이터가 없습니다.");
			commonUtil.msgBox("VALID_M0006");
			return;
		} else{
			showDetailInfo();
		}
	} */
	
	function showDetail(){ 
		$("#main").hide();
		$("#detailInfo").show();
	}

	function reflectData(){
		var $refloc = $("#refloc").val();
		
		if(!$refloc){
			//alert("적치지번을 입력해주세요.");
			commonUtil.msgBox("VALID_M0908");
		} else{
			var selectNumList = gridList.getSelectRowNumList("gridList");
			if(selectNumList.length == 0){
				//alert("선택된 데이터가 없습니다.");
				commonUtil.msgBox("VALID_M0006");
				return;
			}
			for(var i=0;i<selectNumList.length;i++){
				var rowNum = selectNumList[i];
				gridList.setColValue("gridList", rowNum, "LOCATG", $refloc);
			}
		}
	}
	
	function gridListEventInputColFocus(gridId, rowNum, colName){
		if(gridId=="gridList" && colName == "LOCATG"){
			gridList.setColValue(gridId, rowNum, "LOCATG", "");
		}
	}
	
	function gridListEventColValueChange(gridId, rowNum, colName, colValue){
		if(gridId=="gridList" && colName=="QTTAOR"){	//작업수량 column
			var avlqty = parseInt(gridList.getColData("gridList", rowNum, "AVAILABLEQTY"));	//가용수량
			var qttaor = parseInt(colValue);
			
			if(colValue == "" || colValue == null){
				gridList.setColValue("gridList", rowNum, "QTTAOR", "0");
			}
			
			if(avlqty < qttaor){
				alert("작업수량은 가용수량을 초과할 수 없습니다.");
				gridList.setColValue("gridList", rowNum, "QTTAOR", "0");
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
					gridList.setColValue("gridList", i, "QTTAOR", 1);
					gridList.setColFocus("gridList", i, "QTTAOR");
					gridList.setRowCheck("gridList", i, true);
					
					/* var avlqty = gridList.getColData("gridList", i, "AVAILABLEQTY");	//가용수량
					var qttaor = gridList.getColData("gridList", i, "QTTAOR");	//입고수량
					var total = parseInt(qttaor)+parseInt(qty) ;
					if(parseInt(avlqty) != parseInt(qttaor)){
						if(parseInt(avlqty) >= parseInt(total) ){
							gridList.setColValue("gridList", i, "QTTAOR", total);
							return;
						}else{
							if(List.length > 1){
								for(var j=i+1;j<List.length;j++){
									var avlqty = gridList.getColData("gridList", j, "AVAILABLEQTY");	//가용수량
									var qttaor = gridList.getColData("gridList", j, "QTTAOR");	//작업수량
									var checkqty = parseInt(qtyrcv)+parseInt(qty) ;
									if(parseInt(avlqty) >= parseInt(checkqty)){
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
					} */
				}
				
			} 
		}else{
			$("#LOTA05").val("");
			alert("바코드를 다시 확인해주세요.");
			return;
		}
		//$("#LOTA05").focus();
	}  //LOT적용 end
	
	function totalApply_bak(){
		var $lota05 = $("#LOTA05").val();	//LOT
		var $qttaor = $("#QTTAOR").val();	//작업수량
		var cnt;
		
		var param = new DataMap();
		
		param.put("SKUKEY", "<%=SKUKEY%>");
		param.put("LOCAKY","<%=LOCAKY%>");
		var json = netUtil.sendData({
			module : "Mobile",
			command : "MGR09val",
			sendType : "map",
			param : param
		});
		if(json.data){
			cnt = json.data["CNT"];	//총 그리드 개수
		}
		
		for(var i=0;i<cnt;i++){
			//리스트를 돌면서 품번이 같은 제품(skukey)을 찾는다.
			var skukey = new Array();
			skukey[i] = gridList.getColData("gridList", i, "SKUKEY");
		
		}
			
			var id = $lota05.charAt(0);
		
				
			//LOT번호에서 구분자를 따로 꺼내서 O,I,S에 따라 수량 추가할것.
			
			//같은 품번을 가진 상품을 찾아 수량 증가시킬것.
			//수량 증가 후에는 flag값을 변경해서 다음 값으로 넘어갈 것.
			//작업수량이 가용수량을 넘어서는 안됨. => 수량확인하여 작업수량 증가 못하도록.
			
			if(srch = $qttaor){
				gridList.setColValue("gridList", rowNum, "QTTAOR", qttaor);
			}
		
		//gridList.getColModify();
		
	}
	
	function totalApply1(){
		gridList.setColValue("gridList", 0, "QTTAOR" , 111);
	}
	//총괄수량적용
	function totalApply2(){
		var rowCnt = gridList.getSelectRowNumList("gridList");
		if(rowCnt.length==0){
			commonUtil.msgBox("VALID_M0006");
		}else{
			for(var i = 0 ; i < rowCnt.length ; i++){
				var getAvailable = gridList.getColData("gridList", rowCnt[i], "AVAILABLEQTY");
				gridList.setColValue("gridList", rowCnt[i], "QTTAOR", getAvailable);
			}
	}
	
	}
	
	function gridListEventDataBindEnd(gridId, dataLength){
		if( dataLength == 0 ){
			location.href="/mobile/MGR09.page";
		}
 	}
</script>
</head>
<body>
	<div class="main_wrap" id="main">
		<div class="tem5_content">
			<div class="top_searchLot">
				<table>
					<colgroup>
						<col width="70px" />
						<col />
						<col width="60px" />
					</colgroup>
					<tbody>
						<tr class="t_title">
							<th>적치지번</th>
							<td><input type="text" class="text" id="refloc" onkeypress="commonUtil.enterKeyCheck(event, 'reflectData()')" onfocus="clearText(this)" /></td>
							<td><input type="button" value="▼" class="bt" onclick="reflectData()" /></td>
						</tr>
						<tr>
							<th>LOT</th>
							<td><input type="text" class="text" id="LOTA05" onkeypress="commonUtil.enterKeyCheck(event, 'totalApply()')" onfocus="clearText(this)" /></td>
							<td><input type="button" value="총괄수량적용" class="bt" onclick="totalApply2()" /></td>
						</tr>
					</tbody>
				</table>
			</div>
			<div class="tableWrap_search section">
				<div class="tableHeader">
					<table style="width: 100%">
						<colgroup>
							<col width="30px" />
							<col width="30px" />
							<col width="100px" />
							<col width="60px" />
							<col width="60px" />
							<col width="100px" />
							<col width="150px" />
							<col width="100px" />
							<col width="90px" />
							<col width="120px" />
						</colgroup>
						<thead>
							<tr>
								<th>번호</th>
								<th GBtnCheck="true"></th>
								<th>품번</th>
								<th>가용수량</th>
								<th>작업수량</th>
								<th>TO지번</th>
								<th>품명</th>
								<th>지번</th>
								<th>입고오더번호</th>
								<th>ASN문서번호</th>
								<!-- 
								<th>예정량</th>
								<th>입고량</th>
								<th>박스수량</th>
								<th>잔량</th>
								<th>검사유형명</th>
								<th>시료수</th>
								<th>불합격수량</th>
								<th>임가공업체코드</th>
								<th>임가공업체명</th>
								<th>발주부서코드</th>
								<th>발주부서명</th>
								<th>발주번호</th>
								<th>생산일자</th>
								<th>포장일자</th>
								 -->
							</tr>
						</thead>
					</table>
				</div>
				<div class="tableBody">
					<table style="width: 100%">
						<colgroup>
							<col width="30px" />
							<col width="30px" />
							<col width="100px" />
							<col width="60px" />
							<col width="60px" />
							<col width="100px" />
							<col width="150px" />
							<col width="100px" />
							<col width="90px" />
							<col width="120px" />
						</colgroup>
						<tbody id="gridList">
							<tr CGRow="true">
								<td GCol="rownum">번호</td>
								<td GCol="rowCheck"></td>
								<td GCol="text,SKUKEY">품번</td>
								<td GCol="text,AVAILABLEQTY">가용수량</td>
								<td GCol="input,QTTAOR" GF="N 5">작업수량</td>
								<td GCol="input,LOCATG" id="LOC">TO지번</td>
								<td GCol="text,DESC01">품명</td>
								<td GCol="text,LOCASR">지번</td>
								<td GCol="text,SEBELN">입고오더번호</td>
								<td GCol="text,ASNDKY">ASN문서번호</td>
							</tr>
						</tbody>
					</table>
				</div>
			</div>
			<!-- end table_body -->
			<div class="footer_5">
				<table>

					<tr>
						<td class=f_1 onclick="saveData()">적치완료</td>
						<td onclick="showDetail()">상세정보</td>
						<td onclick="searchList()">새로고침</td>
					</tr>
				</table>
			</div>
			<!-- end footer_5 -->

		</div>
	</div>
	<div class="detailInfo_wrap" id="detailInfo">
		<h2 class="info_title">상세정보</h2>
		<div class="d_table_wrap">
			<div id="searchArea">
				<table class="info_table">
					<colgroup>
						<col width="90px" />
						<col />
						<col width="50px" />
						<col />
					</colgroup>
					<tbody>
						<tr>
							<th>#입하문서번호</th>
							<td>
								<span class="inp_group"> 
									<input type="text" name="RECVKY" readonly="readonly">
								</span>
							</td>
							<th class="right">Item</th>
							<td>
								<span class="inp_group"> 
									<input type="text" name="RECVIT" readonly="readonly">
								</span>
							</td>
						</tr>
						<tr>
							<th>품번</th>
							<td colspan=3>
								<span class="inp_group"> 
									<input type="text" name="SKUKEY" readonly="readonly">
								</span>
							</td>
						</tr>
						<tr>
							<th>품명</th>
							<td colspan=3>
								<span class="inp_group"> 
									<input type="text" style="height: 70px" name="DESC01" readonly="readonly">
								</span>
							</td>
						</tr>
						<tr>
							<th>가용수량</th>
							<td>
								<span class="inp_group"> 
									<input type="text" class="s" name="AVAILABLEQTY" id="AVAILABLEQTY" readonly="readonly" />
								</span>
							</td>
						</tr>
						<tr>
							<th>작업수량</th>
							<td>
								<span class="inp_group"> 
									<input type="text" name="QTTAOR" id="QTTAOR" />
								</span>
							</td>
							<!-- <td>EA</td> -->
						</tr>
						<!-- <tr>
							<th></th>
							<td>
								<span class="inp_group">
									<input type="text" />
								</span>
							</td>
							<td>BOX</td>
						</tr> -->
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
							<td colspan=3>
								<span class="inp_group"> 
									<input type="text" name="LOCATG" id="LOCATG" />
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
					<!-- <td class=f_1 onclick="saveDetail()">저장</td> -->
					<td class=f_1 onclick="showMain()">닫기</td>
					<td onclick="gridList.setNextRowFocus('gridList')">&gt;</td>
				</tr>
			</table>
		</div>
		<!-- end footer_5 -->
	</div>
</body>