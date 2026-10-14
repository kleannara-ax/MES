<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>WMS</title>
<%@ include file="/common/include/head.jsp"%>
<script language="JavaScript" src="/common/js/ezgencontrol.js"> </script>
<script type="text/javascript">
	
	function searchList() {
		var param = inputList.setRangeParam("searchArea");
		param.put("USERID", "<%=userid%>");
		param.put("COMPYN", "A");
		param.put("NOSTCK", "V");
		
		var json = netUtil.sendData({
			module : "WmsInventory",
			command : "IP09PRO",
			sendType : "map",
			param : param
		}); 
		
		var areaky = param.get("AREAKY");
		var rqshpd = param.get("RQSHPD");
		
		if(json && json.map){
			$('#DOCKY1').val(json.map["DOCKY1"]);
			$('#DOCKY2').val(json.map["DOCKY2"]);
			
			var msgMap = new DataMap();
			var msgList = new Array();
			
			msgList.push(rqshpd);
			msgList.push(areaky);
			commonUtil.msgBox("INV_M0702",msgList); /* [{0}] 일자 / 창고 [{1}] 의 재고실사 문서가 생성되었습니다. */
		}
	}

	function commonBtnClick(btnName){
		if(btnName == "Search"){
			searchList();
		}else if(btnName == "Print"){
			printList();
		}
	}
	
	function printList(){
		var docky1 = $('input[name=DOCKY1]').val();
		var docky2 = $('input[name=DOCKY2]').val(); 
		var where;
		var url;
		
		if(docky1 == ' ' || docky1 == null){
			commonUtil.msgBox("VALID_M1566");
			return;
		}
		
		if(docky2 !=  ""){
			where = "AND PH.PHYIKY IN ( '" + docky1 + "')";
		}else{
			where = "AND PH.PHYIKY IN ( '" + docky1 + "', '"+ docky1 + "')";
		}
		 
		url = "/ezgen/physical_count_stock_list.ezg";
				
		var map = new DataMap();
		WriteEZgenElement(url, where, "", '<%= langky%>', map, 900, 650);	
	}
	
	function savedata(){
		var docky1 =  $('input[name=DOCKY1]').val();	// 인쇄수량
		var docky2 =  $('input[name=DOCKY2]').val();	// 입고총수량
		
		var param = new DataMap();
		param.put("DOCKY1", docky1);
		param.put("DOCKY2", docky2);
		
		var json = netUtil.sendData({
			url : "/wms/labal/json/saveLB01.data",
			param : param
		});
		
		return json;
	}
</script>
</head>
<body>

	<!-- searchPop -->
	<div class="searchPop" id="searchArea">
		<button type="button" class="closer">X</button>
		<div class="searchInnerContainer">
			<p class="util">
				<button CB="Search SEARCH BTN_ORDPHY"></button>
				<button CB="Print PRINT BTN_PRINT30"></button>
			</p>
		
			<div class="searchInBox">
				<h2 class="tit" CL="STD_SELECTOPTIONS">검색조건</h2>
				<table class="table type1">
					<colgroup>
						<col width="100" />
						<col />
					</colgroup>
					<tbody>
						<tr>
							<th CL="STD_WAREKY"></th>
							<td><input type="text" name="WAREKY" value="<%=wareky%>" size="8px" readonly="readonly"/></td>
						</tr>
						<tr>
							<th CL="STD_OWNRKY">화주</th>
							<td>
								<select Combo="WmsOrder,OWNRKYCOMBO" name="OWNRKY" id="OWNRKY">
								</select>
							</td>
						</tr>
						<tr>
							<th CL="STD_AREAKY">창고</th>
							<td>
								<input type="text" name="AREAKY" id="AREAKY" UIInput="R,SHAREMA" />
							</td>
						</tr>
						<tr>
							<th CL="STD_RQSHPD">출고요청일자</th>
							<td>
								<input type="text" name="RQSHPD" UIFormat="C N" validate="required"/>  
							</td>
						</tr>
					</tbody>
				</table>
			</div>
			<div class="searchInBox">
				<h2 class="tit" CL="STD_SELECTOPTIONS">검색조건</h2>
				<table class="table type1">
					<colgroup>
						<col width="100" />
						<col />
					</colgroup>
					<tbody>
						<tr>
							<th CL="STD_PHYDOC">재고실사지시문서</th>
							<td>
								<input type="text" name="DOCKY1" id="DOCKY1" readonly="readonly" />
							</td>
						</tr>
						<tr>
							<th CL="STD_PHDOCN">0재고 로케이션 실사문서번호</th>
							<td>
								<input type="text" name="DOCKY2" id="DOCKY2" readonly="readonly" />  
							</td>
						</tr>
					</tbody>
				</table>
			</div>
		</div>
	</div>
	<!-- //searchPop -->

	<!-- content -->
		<!-- //content -->
		<%@ include file="/common/include/bottom.jsp"%>
</body>
</html>