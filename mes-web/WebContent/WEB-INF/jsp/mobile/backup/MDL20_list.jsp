<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%
	request.setCharacterEncoding("UTF-8");
	String PTNRKY = request.getParameter("PTNRKY");
	String BOXNO = request.getParameter("BOXNO");
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
			command : "MDL20",
			bindArea : "searchArea",
			gridMobileType : true
	    });
		gridList.checkAll("gridList", true);
		searchList();
	});
	
	function searchList(){
		var boxno = "<%=BOXNO%>";
		var param = new DataMap();
		param.put("BOXNO", boxno);
		
		gridList.gridList({
	    	id : "gridList",
	    	param : param
	    });
		
		if(boxno == null || boxno == ""){
			var json = netUtil.sendData({
				module : "WmsOutbound",
				command : "BOXNUMSEQ",
				sendType : "map"
			});
			
			var boxnum = json.data["BOXNUM"];
			$('#BOXNO').val(boxnum);
		}else{
			$('#BOXNO').val(boxno);
			$('#BOXQTY').attr("disabled",true);
			$('#BOXNO').attr("disabled",true);
		}
		
		showMain();
	}
	
	function showMain() {
		$("#main_container").show();
	}
	function showDetailInfo() {
		$("#main_container").hide();
	}
	
	function showDetail(){ 
		showDetailInfo();
	}
	
	function savaData(){
		var param = new DataMap();
		var chkList = gridList.getSelectData("gridList");
		var chkListLen = gridList.getSelectRowNumList("gridList").length;
		var boxqty = $("#BOXQTY").val();
		var boxno = $("#BOXNO").val();

		if( chkListLen == 0 ){
			// 선택된 데이터가 없습니다.
			commonUtil.msgBox("VALID_M0006");
			return;
		}else{
			param.put("CHKLIST", chkList); 
			param.put("BOXQTY", boxqty); 
			param.put("BOXNO", boxno); 
			param.put("PTNRKY", '<%=PTNRKY%>');

			var json = netUtil.sendData({
				url:"/mobile/Mobile/json/SaveMDL20.data",
				param : param
			});
			
			if(json && json.data){
				commonUtil.msgBox("저장이 완료되었습니다.");
				$('#BOXNO').val("");
				$('#BOXQTY').val("");
				searchList();
			}else{
				commonUtil.msgBox("VALID_M0002");
			}
		}	
	}
	
 	function gridListEventColValueChange(gridId, rowNum, colName, colValue){
		if(gridId == "gridList" && colName == "SKUKEY01"){
			var param = new DataMap();
			
			param.put("PTNRKY", '<%=PTNRKY%>');
			param.put("SKUKEY",colValue);
			
			if(colValue != ""){
				var json = netUtil.sendData({
					module : "WmsOutbound",
					command : "SKUval",
					sendType : "map",
					param : param
				});
				
				if(json.data["CNT"] < 1){
					commonUtil.msgBox("IN_M0133", colValue);		//존재하지 않는 품번코드입니다.
					gridList.setColValue("gridList", rowNum, "SKUKEY01", "");
				}else if(json.data["CNT"] > 0) {
					var param = new DataMap();
					param.put("SKUKEY", colValue);
					
					json = netUtil.sendData({
						module : "WmsOutbound",
						command : "DL20POPSKU",
						sendType : "map",
						param : param
					});
					if(json && json.data){
						gridList.setColValue("gridList", rowNum, "DESC01", json.data["DESC01"]);
						gridList.setColValue("gridList", rowNum, "SKUKEY02", json.data["CUSTITEMNO"]);
						gridList.setColValue("gridList", rowNum, "DESC02", json.data["CUSTITEMNAME"]);
					}
				}
				
				
			}
		}else if(gridId == "gridList" && colName == "QTY"){
			var skuky = gridList.getColData("gridList", rowNum, "SKUKEY01");
			
			if(skuky == '' || skuky == null){
				alert("품번코드를 입력해주세요.");
				return;
			}
			var param = new DataMap();
			
			param.put("SKUKEY", skuky);
			param.put("TYPE", "O");

			if(colValue != ""){
				var json = netUtil.sendData({
					module : "Mobile",
					command : "FINDQTY",
					sendType : "map",
					param : param
				});
				if(json.data["QTPUOM"] < colValue){
					alert("입수수량을 초과하였습니다.");
					gridList.setColValue("gridList", rowNum, colName, json.data["QTPUOM"]);
					return;
					
				}
			}
		}
 	}
 	
 	function gridListEventRowCheck(gridId, rowNum, checkType){
 		alert("체크 해제 불가합니다.");
 		gridList.checkAll("gridList", true);
 	 }
 	
 	function gridListEventDataBindEnd(gridId, dataLength){
		if( dataLength == 0 ){
			location.href="/mobile/MDL20.page";
		}else{
			gridList.checkAll("gridList", true);
		}
 	}
 	
 	function clearText(data){
		if(data!=null||data!=""){
	    	data.value="";
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
			
			var rowCnt = gridList.getGridDataCount("gridList");
			var skuCnt = gridList.getColData("gridList", 0, "SKUKEY01");

			if(rowCnt == 1 && skuCnt == " "){
				gridList.setColValue("gridList", 0 , "SKUKEY01", skukey);
				gridList.setColValue("gridList", 0 , "QTY", 1);
				gridList.setColFocus("gridList", 0, "QTY");
				gridList.setRowCheck("gridList", rowCnt, true);
			}else{
				var newData = commonUtil.copyMap(json.data);
				var skukey = newData.get("SKUKEY");
				
				gridList.setAddRow("gridList");
				gridList.setColValue("gridList", rowCnt , "SKUKEY01", skukey);
				gridList.setColValue("gridList", rowCnt , "QTY", 1);
				gridList.setRowCheck("gridList", rowCnt, true);
				gridList.setColFocus("gridList", rowCnt, "QTY");
			}	
		}
		else{
			$("#LOTA05").val("");
			alert("바코드를 다시 확인해주세요.");
			return;
		}
		//$("#LOTA05").focus();
	}  //LOT적용 end
</script>
</head>
<body>
	<div class="main_wrap" >
	<div id="main_container">
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
							<th>BOXNO</th>
							<td>
								<input type="text" class="text" id="BOXNO" readonly="readonly" />
							</td>
							<th>BOX수량</th>
							<td>
								<input type="text" class="text" id="BOXQTY" onkeypress="commonUtil.enterKeyCheck(event, 'savaData()')" onfocus="clearText(this)"/>
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
							<col width="40" />
							<col width="40" />
							<col width="100" />
							<col width="100" />
							<col width="100" />
							<col width="100" />
							<col width="100" />
							<col width="100" />
							<col width="100" />
						</colgroup>
						<thead>
							<tr>
								<th CL='STD_NUMBER'></th>
								<th GBtnCheck="true"></th>
								<th CL='STD_SKUKEY'>품번</th>
								<th>품명</th>
								<th>거래처 품번</th>
								<th>거래처 품명</th>
								<th>원산지</th>
								<th>수량</th>
								<th>무게</th>
							</tr>
						</thead>
					</table>				
				</div>					
				<div class="tableBody">
					<table>
						<colgroup>
							<col width="40" />
							<col width="40" />
							<col width="100" />
							<col width="100" />
							<col width="100" />
							<col width="100" />
							<col width="100" />
							<col width="100" />
							<col width="100" />
						</colgroup>
						<tbody id="gridList">
							<tr CGRow="true">
								<td GCol="rownum">1</td>
								<td GCol="rowCheck"></td>
								<td GCol="input,SKUKEY01" validate="required"></td>
								<td GCol="input,DESC01"></td>
								<td GCol="text,SKUKEY02" GF="S 20"></td>
								<td GCol="text,DESC02" GF="S 200"></td>
								<td GCol="input,LOTL15" GF="S 120"></td>
								<td GCol="input,QTY" validate="required"></td>					
								<td GCol="input,WEIGHT" GF="N 5"></td>
							</tr>
						</tbody>
					</table>
				</div>
				</div>
				<!-- end table_body -->
				<div class="footer_5">
					<table>
						<tr>
							<td class=f_1 onclick ="savaData()">완료</td>
							<td onclick="searchList()">새로고침</td>
						</tr>
					</table>
				</div><!-- end footer_5 -->	
			</div>
	</div>
	</div>
</body>