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
	$(document).ready(function(){
		gridList.setGrid({
	    	id : "gridList",
			editable : false,
			module : "Mobile",
			command : "MDL07TO",
			gridMobileType : true
	    });

		var data = mobile.getLinkPopData();
		dataBind.dataNameBind(data, "searchArea");
		searchList();
	});
	
	var org;	//original value of "LOCATG"
	
	function searchList(){
		if(validate.check("searchArea")){
			var param = dataBind.paramData("searchArea");
			gridList.gridList({
		    	id : "gridList",
		    	param : param
		    });
		}
	}
	
	function saveData(){
		var json = gridList.gridSave({
	    	id : "gridList",
	        module : "Mobile",
	        command : "MDL07TO",
	        gridMobileType : true
	    });
		
		if(json.data){
			//alert("저장이 성공하였습니다.");
			mobile.linkPopClose();
		}
	}	
	
	function gridListEventRowFocus(gridId, rowNum){
		org = gridList.getColData("gridList", rowNum, "LOCATG");
	}
	
	function gridListEventColValueChange(gridId, rowNum, colName, colValue){
		if(gridId="gridList" && colName=="LOCATG"){
			changeLocaky(rowNum,colValue);
		}
	}
	
	function changeLocaky(rowNum,colValue){
		var param = new DataMap();
		
		//var colValue = gridList.getColData("gridList", rowNum, "LOCATG");
		param.put("LOCAKY", colValue);
		
		 if(colValue==" " || colValue==""){
			//alert("TO지번을 입력해주세요.");
			commonUtil.msgBox("COMMON_M0009","TO지번");
			gridList.setColValue("gridList", rowNum, "LOCATG", org);
			gridList.setColFocus("gridList", rowNum, "LOCATG");
			return;
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
			alert("상품 [ "+skukey+" ]의 TO 지번 [ "+colValue+" ]이 존재하지 않습니다.");
			//commonUtil.msgBox("VALID_M0204", colValue);
			gridList.setColValue("gridList", rowNum, "LOCATG", org);
			//gridList.setColFocus("gridList", rowNum, "LOCATG");
			return;
		}
		else if(json.data == -1){
			alert("상품 [ "+skukey+" ]의 지번 [ "+colValue+" ]은 상품 혼적을 할 수 없습니다.");// messegeUtil
			gridList.setColValue("gridList", rowNum, "LOCATG", org);
			//gridList.setColFocus("gridList", rowNum, "LOCATG");
			return;
		} 
		else if (json.data == -2){
			alert("상품 [ "+skukey+" ]의 지번 [ "+colValue+" ]은 LOT 혼적을 할 수 없습니다.");// messegeUtil
			gridList.setColValue("gridList", rowNum, "LOCATG", org);
			//gridList.setColFocus("gridList", rowNum, "LOCATG");
			return;
		} 
		
		return;
	}
</script>
</head>
<body>
	<div class="main_wrap">
		<div class="tem4_content">
			<div class="TO_search">
				<table>
					<colgroup>
						<col width="50px"  />
						<col />
					</colgroup>
					<tbody id="searchArea">
						<tr>
							<th>품번</th>
							<td>
								<input type="hidden" name="STKNUM">
								<input type="text" class="text" name="SKUKEY" />
							</td>
						</tr>
						<tr>
							<th>품명</th>
							<td>
								<input type="text" class="text" name="DESC01" style="height:70px"/>
							</td>
						</tr>
					</tbody>
				</table>
			</div>
				<div class="tableWrap_search section">
					<div class="tableHeader">
					<table>
						<colgroup>
							<col width="20px" />
							<col width="50px" />
							<col width="50px" />
							<col width="50px" />
							<col width="50px" />
							<col width="50px" />
						</colgroup>
						<thead>
							<tr>
								<th>번호</th>
								<th>거래처명</th>
								<th>납품처명</th>
								<th>수취인명</th>
								<th>TO지번</th>
								<th>작업지시번호</th>
							</tr>
						</thead>
					</table>				
				</div>	
				<div class="tableBody">
					<table>
						<colgroup>
							<col width="20px" />
							<col width="50px" />
							<col width="50px" />
							<col width="50px" />
							<col width="50px" />
							<col width="50px" />
						</colgroup>
						<tbody id="gridList">
							<tr CGRow="true">
								<td GCol="rownum"></td>
								<td GCol="text,NAME01"></td>
								<td GCol="text,PTNL02"></td>
								<td GCol="text,DNAME2"></td>
								<td GCol="input,LOCATG"></td>
								<td GCol="text,TASKKY"></td>
							</tr>
						</tbody>
					</table>
				</div>
				<!-- <div class="bottom">
					<input type="button" value="저장" class="bottom_bt" onClick="saveData()"/>
				</div> -->
		</div>	
		 <div class="footer_5">
			<table>
				<tr>
					<td class=f_1 onclick="saveData()">저장</td>
					<td onclick="window.close()">닫기</td>
				</tr>
			</table>
		</div> 
	</div>
	</div>
</body>