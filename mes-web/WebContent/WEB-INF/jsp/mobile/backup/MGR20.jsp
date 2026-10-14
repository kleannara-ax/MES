<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!doctype html>
<head>
<meta charset="utf-8">
<meta name="viewport" content="user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, width=device-width, target-densitydpi=medium-dpi" />
<meta name="format-detection" content="telephone=no" />
<title>슈피겐코리아 모바일 WMS</title>
<%@ include file="/mobile/include/head.jsp" %>

<script>	
	var searchKey;
	var keyword;
	
	var col = "";
	var flag = false;
	var countRow;
	//var colValue;
	var rowNumChkLoc;
	var org;			//original value of "LOCAKY"
	
	$(document).ready(function(){
		gridList.setGrid({
	    	id : "gridList",
			editable : false,
			module : "Mobile",
			command : "MGR20Sub",
			sendType : "map",
			bindArea: "searchArea",
			gridMobileType : true
	    });
		
		//$("#SKUKEY").focus();
	});

	function beforeSetGrid(keyword, searchKey){
		var param = new DataMap();
		param.put(keyword ,searchKey);
		
		gridList.gridList({
	    	id : "gridList",
	    	command : "MGR20Sub",
	    	param : param
	    });
		
		flag = true;
	}
		

	function onChangeEvent(keyword) {
		var skukey = $("#SKUKEY").val();
		var eancod = $("#EANCOD").val();

		if(skukey==""&&eancod==""){
			alert("LOT 또는 88코드를 입력하세요");
			return;
		}else{
			if(keyword=='SKUKEY'){
				addData(keyword, skukey);
			}else if(keyword=='EANCOD'){
				addData(keyword, eancod);
			}
		}
	}
	
	function addData(keyword, searchKey){
		var param = new DataMap();
		param.put(keyword ,searchKey);
		
		if(keyword == 'EANCOD'){
			var json = netUtil.sendData({
				module : "Mobile",
				command : "MGR20CHK",
				sendType : "map",
				param : param
			});

			if(json.data["CNT"] != 1){
				var $obj = $("#EANCOD");
				col = '88';
				var param = new DataMap();
				param.put("COLTEXT", $obj.val());
				mobile.linkPopOpen('/mobile/MGR20_88search.page',param);
				return;
			}
		}
		var json = netUtil.sendData({
			module : "Mobile",
			command : "MGR20Sub",
			sendType : "map",
			bindArea : "searchArea",
			param : param
			
		});
		
		if(json && json.data){
			if(json.data["SKUKEY"]==null || json.data["SKUKEY"]==""){
				$("#SKUKEY").val("");
				commonUtil.msgBox("VALID_M0005");	
			}else{
				/* 
				var newData = new DataMap();
				newData.put("SKUKEY", json.data["SKUKEY"]); 
				newData.put("DESC01", json.data["DESC01"]); 
				newData.put("EANCOD", json.data["EANCOD"]); 
				
				newData.put("LOTA01", json.data["LOTA01"]); 
				newData.put("LOTA02", json.data["LOTA02"]); 
				newData.put("LOTA05", json.data["LOTA05"]); 
				
				newData.put("LOTA06", json.data["LOTA06"]); 
				newData.put("LOTA09", json.data["LOTA09"]); 
				newData.put("LOTA14", json.data["LOTA14"]); 
				newData.put("DOCDAT", json.data["DOCDAT"]); 
				newData.put("CREDAT", json.data["CREDAT"]); 
				newData.put("CUSRNM", json.data["CUSRNM"]); 
				newData.put("LMODAT", json.data["LMODAT"]); 
				newData.put("LMOUSR", json.data["LMOUSR"]); 
				newData.put("LUSRNM", json.data["LUSRNM"]); 
				newData.put("CREUSR", json.data["CREUSR"]); 
				newData.put("ARCPTD", json.data["ARCPTD"]);  */
				 
				if(!flag){
					beforeSetGrid(keyword, searchKey);
				}
				
				var newData = commonUtil.copyMap(json.data); // 함수추가했음 잘 구동되는지 확인 요망
				gridList.setAddRow("gridList", newData);

				var rowNum =  gridList.getFocusRowNum("gridList");

				gridList.setColValue("gridList", rowNum, "QTYRCV", 1);
				gridList.setColFocus("gridList", rowNum, "QTYRCV"); 
				gridList.setRowCheck("gridList", rowNum, true);
				
				dataBind.dataNameBind(newData, "detailInfo", "");
				$("#SKUKEY").val("");
			}
		}else{
			$("#SKUKEY").val("");
			commonUtil.msgBox("VALID_M0005");	
		}
	}
	
	function gridListEventDataBindEnd(gridId, dataLength){
		if( gridId == "gridList" && dataLength > 0 ){
			var rowNum =  gridList.getFocusRowNum("gridList");
			gridList.setColValue("gridList", rowNum, "QTYRCV", 1);
			gridList.setColFocus("gridList", rowNum, "QTYRCV"); 
			gridList.setRowCheck("gridList", rowNum, true);
		}
	}
	
	function deleteData(){
		var flag = false;
		var rowNum = gridList.getSelectRowNumList("gridList");
		for(var i = 0 ; i <rowNum.length ; i++ ){
			if(!flag){
				gridList.deleteRow("gridList", rowNum[i], true);
				flag = true;
			}else{
				gridList.deleteRow("gridList", rowNum[i], false);	
			}
		}
	}	

	function linkPopCloseEvent(data){
		if(col=='EANCOD'){
			var EANCOD = data.get("EANCOD");
			$("#EANCOD").val(EANCOD);
			onChangeEvent(col);
		}else if(col == 'SKUKEY'){
			var SKUKEY = data.get("SKUKEY");
			$("#SKUKEY").val(SKUKEY);
			onChangeEvent(col);
		}else if(col == '88'){
			var SKUKEY = data.get("SKUKEY");

			$("#SKUKEY").val(SKUKEY);
			$("#EANCOD").val("");
			onChangeEvent('SKUKEY');
		}
	 }
	
	function linkPopupOpen(keyword){
		col = keyword;
		if(keyword=='SKUKEY'){
			var $obj = $("SKUKEY");
			mobile.linkPopOpen('/mobile/MGR20_search.page?keyword='+keyword, $obj.val());
		}else if(keyword=='EANCOD'){
			var $obj = $("EANCOD");
			mobile.linkPopOpen('/mobile/MGR20_search.page?keyword='+keyword, $obj.val());
		}
	}
	
	function saveCheck(col){
		var param = new DataMap();
		if(col=="gridList"){
			rowNumChkLoc = gridList.getFocusRowNum("gridList");
			colValue = gridList.getColData("gridList", rowNumChkLoc, "LOCAKY");
			if(colValue==" " || colValue==""){
				commonUtil.msgBox("COMMON_M0009","지번");
				gridList.setColFocus("gridList", rowNumChkLoc, "LOCAKY");
				return false;
			}
		}else if(col=="detail"){
			rowNumChkLoc = gridList.getFocusRowNum("gridList");
			colValue = $("#LOCAKY").val();
			if(colValue==" " || colValue==""){
				commonUtil.msgBox("COMMON_M0009","지번");
				return false;
			}
		}
		param.put("LOCAKY", colValue);
		
		
		var skukey = gridList.getColData("gridList", rowNumChkLoc, "SKUKEY");
	//	var lotnum = gridList.getColData("gridList", rowNumChkLoc, "LOTNUM"); 
		param.put("SKUKEY",skukey);
	//	param.put("LOTNUM",lotnum);
		
		var json = netUtil.sendData({
			url : "/mobile/Mobile/json/LocakyCheck.data",
			param : param
		});
		
		
		if (json.data == 0){
			commonUtil.msgBox("VALID_M0204", colValue);
			gridList.setColValue("gridList", rowNumChkLoc, "LOCAKY", "");
			gridList.setColFocus("gridList", rowNumChkLoc, "LOCAKY");
			return false;
		}
		else if(json.data == -1){
			alert("["+colValue+"]"+"는 상품 혼적을 할 수 없습니다.");// messegeUtil
			gridList.setColValue("gridList", rowNumChkLoc, "LOCAKY", "");
			gridList.setColFocus("gridList", rowNumChkLoc, "LOCAKY");
			return false;
		} 
		else if (json.data == -2){
			alert("["+colValue+"]"+"는 LOT 혼적을 할 수 없습니다.");// messegeUtil
			gridList.setColValue("gridList", rowNumChkLoc, "LOCAKY", "");
			gridList.setColFocus("gridList", rowNumChkLoc, "LOCAKY");
			return false;
		}
		
		return true;
	}
	
	function saveData(){
		countRow = gridList.getGridDataCount("gridList")-1;

		var selectList = gridList.getSelectRowNumList("gridList");
		if(selectList.length == 0){
			commonUtil.msgBox("VALID_M0006");
			return;
		}else{

			if(gridList.validationCheck("gridList", "select")){
				var param = new DataMap();		
				var data = gridList.getSelectData("gridList");
				param.put("list", data);
				param.put("col", col);
				var json = netUtil.sendData({
		            url : "/mobile/Mobile/json/SaveMGR20.data",
		            param : param
		         });  
					
		
				if(json.data && json){
					commonUtil.msgBox("VALID_M0001");
					var flag = false;
					if(countRow<1){
						location.reload();
					}else{
						for(var i = 0 ; i <data.length ; i++ ){
						var rowNum = gridList.getFocusRowNum("gridList");
						gridList.deleteRow("gridList", rowNum, false);	
		

						}
					}
				}else{
					commonUtil.msgBox("VALID_M0002");
				}
			}
		}
	}
	
	function showMain() {
		$("#detailInfo").hide();
		$("#main").show();
	}
	
	function showDetail() {
		$("#main").hide();
		$("#detailInfo").show();
	}
	
	function clearText(data){
		if(data!=null||data!=""){
			data.value="";
		}		
	}
	
	function gridListEventRowFocus(gridId, rowNum){
		org = gridList.getColData("gridList", rowNum, "LOCAKY");
	}
	

	function gridListEventColValueChange(gridId, rowNum, colName, colValue){
		if(gridId == "gridList"){
			if(colName == "LOCAKY"){
				if(colValue != ""){
					var param = new DataMap();
				//	rowNumChkLoc = gridList.getFocusRowNum("gridList");
				//	colValue = gridList.getColData("gridList", rowNumChkLoc, "LOCAKY");
					param.put("LOCAKY", colValue);
					
					var skukey = gridList.getColData("gridList", rowNum, "SKUKEY");
					param.put("SKUKEY",skukey);
					
					var lotnum = gridList.getColData("gridList", rowNum, "LOTNUM");
					param.put("LOTNUM"," ");
					
					//console.log(param);
					
					var json = netUtil.sendData({
						url : "/mobile/Mobile/json/LocakyCheck.data",
						param : param
					});
					
					if (json.data == 0){
						alert("상품 [ "+skukey+" ]의 지번 [ "+colValue+" ]이 존재하지 않습니다.");
						//commonUtil.msgBox("VALID_M0204", colValue);
						gridList.setColValue("gridList", rowNum, "LOCAKY", org);
						//gridList.setColFocus("gridList", rowNum, "LOCAKY");
					}
					else if(json.data == -1){
						alert("상품 [ "+skukey+" ]의 지번 [ "+colValue+" ]은 상품 혼적을 할 수 없습니다.");// messegeUtil
						gridList.setColValue("gridList", rowNum, "LOCAKY", org);
						//gridList.setColFocus("gridList", rowNum, "LOCAKY");
					} 
					else if (json.data == -2){
						alert("상품 [ "+skukey+" ]의 지번 [ "+colValue+" ]은 LOT 혼적을 할 수 없습니다.");// messegeUtil
						gridList.setColValue("gridList", rowNum, "LOCAKY", org);
						//gridList.setColFocus("gridList", rowNum, "LOCAKY");
					}
				}
		
			}
		}
	}
	
	
</script>
</head>
<body>
	<div class="main_wrap" id="main" >
		<div class="tem5_content">
				<div class="MGR20_top_search">
				<table>
					<colgroup>
						<col width="60px"  />
						<col />
						<col width="60px" />
					</colgroup>
					<tbody>
						<tr>
							<th>LOT</th>
							<td>
<!-- 								<input type="text" class="text" id="SKUKEY" name="SKUKEY" onchange="onChangeEvent('SKUKEY')" onfocus="clearText(this)"/> -->
									<input type="text" class="text" id="SKUKEY" name="SKUKEY" onkeypress="if(event.keyCode==13) javascript:onChangeEvent('SKUKEY')" onfocus="clearText(this)"/> 
									
						
							</td>
							<!-- <td>
								<input type="button" value="P" class="bt" onclick="linkPopupOpen('SKUKEY')"/>
							</td> -->
						</tr>
						<tr>
							<th>88코드</th>
							<td>
<!-- 								<input type="text" class="text" id="EANCOD" name="EANCOD" onchange="onChangeEvent('EANCOD')" onfocus="clearText(this)"/> -->
									<input type="text" class="text" id="EANCOD" name="EANCOD" onkeypress="if(event.keyCode==13) javascript:onChangeEvent('EANCOD')" onfocus="clearText(this)"/> 
							
							</td>
							<td>
								<input type="button" value="P" class="bt" onclick="linkPopupOpen('EANCOD')"/>
							</td>
						</tr>
					</tbody>
				</table>
			</div>
				<div class="tableWrap_search section">
				<div class="tableHeader">
					<table >
						<colgroup>
							<col width="50px" />
							<col width="50px" />
							<col width="80px" />
							<col width="100px" />
							<col width="200px" />
							<col width="80px" />
							<col width="80px"/>
							<col width="80px"/>
							<col width="80px" />
							<col width="80px"/>
							<col width="80px" />
							<col width="80px"/>
							<col width="80px" />
							<col width="80px" />
							<col width="80px" />
							<col width="80px" />
							<col width="80px"/>
							<col width="80px"/>
							<col width="80px"/>
							<col width="80px"/>
							<col width="80px"/>
						</colgroup>
						<thead>
							<tr>
								<th>번호</th>
								<th GBtnCheck="true"></th>
								<th>품번</th>
								<th>88코드</th>
								<th>품명</th>
								<th>입고량</th>
<!-- 								<th>박스수량</th>								 -->
								<th>지번</th>
								<th>발주번호</th>
								<th>원산지</th>
								<th>ERP창고</th>
								<th>박스번호</th>
<!-- 								<th>잔량</th>																 -->
								<th>재고상태</th>
								<th>재고부서</th>
								<th>입고일자</th>
								<th>문서일자</th>
								<th>생성일자</th>
								<th>생성자</th>
								<th>생성자명</th>
								<th>수정일자</th>
								<th>수정자</th>
								<th>수정자명</th>

							</tr>
						</thead>
					</table>				
				</div>					
				<div class="tableBody" id="gridDIV">
					<table>
						<colgroup>
							<col width="50px" />
							<col width="50px" />
							<col width="80px" />
							<col width="100px" />
							<col width="200px" />
							<col width="80px" />
							<col width="80px"/>
							<col width="80px"/>
							<col width="80px" />
							<col width="80px" />
							<col width="80px"/>
							<col width="80px"/>
							<col width="80px" />
							<col width="80px" />
							<col width="80px" />
							<col width="80px" />
							<col width="80px"/>
							<col width="80px"/>
							<col width="80px"/>
							<col width="80px"/>
							<col width="80px"/>
						</colgroup>
						<tbody id="gridList">
							<tr CGRow="true">
								<input type="hidden" id="LOTNUM" name="LOTNUM"/>
								<td GCol="rownum">1</td>
<!-- 							<td GCol="text,RECVKY"></td>	 -->
								<td GCol="rowCheck"></td>
								<td GCol="text,SKUKEY"></td>
								<td GCol="text,EANCOD"></td>
								<td GCol="text,DESC01"></td>
								<td GCol="input,QTYRCV" validate="required,IN_M0062" GF="N 20"></td>
<!-- 								<td GCol="text,QTDUOM"></td> -->
								<td GCol="input,LOCAKY" validate="required,VALID_M0404" GF="S 20"></td>	
								<td GCol="input,LOTA09" validate="required,IN_M0129" GF="S 20"></td>
								<td GCol="select,LOTA01" >
									<select Combo="WmsAdmin,LOTA01COMBO" >
										<option value="">선택</option>
									</select>
<!-- 									<select> -->
<!-- 										<option value="">선택</option> -->
<!-- 										<option value="AM">[AM]미국</option> -->
<!-- 										<option value="CH">[CH]중국</option> -->
<!-- 										<option value="KR">[KR]한국</option> -->
<!-- 										<option value="VT">[VT]베트남</option> -->
<!-- 									</select> -->
								</td>
								<td GCol="select,LOTA02">
									<select Combo="WmsInventory,ERPWAREHOUSE">
									</select>
								</td>								
								<td GCol="input,LOTA05" GF="S 20"></td>
<!-- 								<td GCol="text,REMQTY" GF="N"></td> -->
								<td GCol="select,LOTA06">
									<select CommonCombo="LOTA06">
									</select>
								</td>
								<td GCol="select,LOTA14">
			                         <select Combo="WmsInbound,LOTA14COMBO">
			                          </select>
			                    </td>
								<td GCol="input,ARCPTD" validate="required,IN_M0123" GF="C 8"></td>
								<td GCol="text,DOCDAT"></td>	
								<td GCol="text,CREDAT"></td>
								<td GCol="text,CREUSR"></td>
								<td GCol="text,CUSRNM"></td>
								<td GCol="text,LMODAT"></td>
								<td GCol="text,LMOUSR"></td>
								<td GCol="text,LUSRNM"></td>
								
							</tr>
						</tbody>
					</table>
				</div>
				</div>
				<!-- end table_body -->
				<div class="footer_5">
			<table>
				<tr>
					<td class=f_1 onclick="saveData()">입하완료</td>
					<td onclick="showDetail()">상세정보</td>
<!-- 					<td>새로고침</td> -->
					<td onclick="deleteData()">선택삭제</td>
				</tr>
			</table>
		</div><!-- end footer_5 -->	
					
			</div>
	</div>
	
	<div class="detailInfo_wrap" id="detailInfo">
		<h2 class="info_title">상세정보</h2>
		<div class="d_table_wrap"  id="searchArea">
			<table class="info_table">
					<colgroup>
						<col width="100px"/>
						<col />
						<col width="50px"/>
						<col />
					</colgroup>
					<tbody id="detailList">
						<tr>
							<th>품번</th>
							<td colspan=3>
								<span class="inp_group">
									<input type="text" id="SKUKEY" name="SKUKEY" readonly="readonly">
								</span>
							</td>
						</tr>
						<tr>
							<th>품명</th>
							<td colspan=3>
								<span class="inp_group">
									<input type="text" style="height:70px" id="DESC01" name="DESC01" readonly="readonly">
								</span>
							</td>
						</tr>
						<tr>
							<th>입고량</th>
							<td>
								<span class="inp_group">
									<input type="text" id="QTYRCV" name="QTYRCV" validate="required" GF="N 20" >
								</span>
							</td>
							<td></td>
						</tr>
<!-- 						<tr> -->
<!-- 							<th></th> -->
<!-- 							<td> -->
<!-- 								<span class="inp_group"> -->
<!-- 									<input type="text" id="BOXQTY" name="BOXQTY" > -->
<!-- 								</span> -->
<!-- 							</td> -->
<!-- 							<td>BOX</td> -->
<!-- 						</tr> -->
						<tr>
							<th>입하지번</th>
							<td>
								<span class="inp_group">
									<input type="text" id="LOCAKY" name="LOCAKY" GF="S 20">
								</span>
							</td>
						</tr>
						<tr>
							<th>발주번호</th>
							<td>
								<span class="inp_group">
									<input type="text" id="LOTA09" name="LOTA09"  GF="S 20">
								</span>
							</td>
						</tr>
						<tr>
							<th>원산지</th>
							<td>
								<span class="inp_group">
									<select Combo="WmsAdmin,LOTA01COMBO" id="LOTA01" name="LOTA01" >
										<option value="">선택</option>
									</select>
								</span>
							</td>
						</tr>
						<tr>
							<th>박스번호</th>
							<td>
								<span class="inp_group">
									<input type="text" id="LOTA05" name="LOTA05">
								</span>
							</td>
						</tr>
					</tbody>
			</table>
				
		</div>
		
		<div class="footer_5">
			<table>
				<tr>
					<td class=f_1 onclick="gridList.setPreRowFocus('gridList')">&lt;</td>
<!-- 					<td onclick="saveData('detail')">저장</td> -->
					<td onclick="showMain()">닫기</td>
					<td onclick="gridList.setNextRowFocus('gridList')">&gt;</td>
				</tr>
			</table>
		</div><!-- end footer_5 -->
</div>
</body>
