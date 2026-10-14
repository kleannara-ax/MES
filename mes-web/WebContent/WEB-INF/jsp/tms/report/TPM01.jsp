<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>WMS</title>
<%@ include file="/common/include/head.jsp" %>
<script type="text/javascript">
	var searchCnt = 0;
	var dblIdx = -1;
	
	$(document).ready(function(){
		gridList.setGrid({
	    	id : "gridList",
	    	name : "gridList",
			editable : true,
			module : "TmsReport",
			command : "TPM01",
	    });

		dataBind.dataNameBind(userInfoData, "searchArea");

	});
	
	function searchList() {
		var param = inputList.setRangeParam("searchArea");
		gridList.gridList({
			id : "gridList",
			param : param
		});
	}
	
	function commonBtnClick(btnName){
		if(btnName == "Search"){
			searchList();
		}
	}
	
	
	function searchHelpEventOpenBefore(searchCode, gridType, $inputObj){
		if(searchCode == "SHCMCDV"){

			var param = inputList.setRangeParam("searchArea");
			
			if($inputObj.name != null){
				if($inputObj.name == "SFRGR"){         //차량유형
					param.put("CMCDKY", "VHCTYP");
				}else if($inputObj.name == "VKBUTX"){  //제품군
					param.put("CMCDKY", "VKBUTX");
				}
			}else{
				if($inputObj.attr("name") == "SFRGR"){
					param.put("CMCDKY", "VHCTYP");	
				}else if($inputObj.attr("name") == "VKBUTX"){
					param.put("CMCDKY", "VKBUTX");	
				}
			}
			return param;
		}
	}	
	
</script>
</head>
<body>
<div class="contentHeader">
	<div class="util">
		<button CB="Search SEARCH BTN_DISPLAY">
		</button>
	</div>
	<div class="util2">
		<button class="button type2" id="showPop" type="button"><img src="/common/images/ico_btn4.png" alt="List" /></button>
	</div>
</div>

<!-- searchPop -->
<div class="searchPop" id="searchArea" style="overflow-y:scroll;">
	<button type="button" class="closer">X</button>
	<div class="searchInnerContainer">

		<p class="util">
			<button CB="Search SEARCH BTN_DISPLAY"></button>
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
						<th CL="STD_COMPKY">사업장</th>
						<td>
							<input type="text" name="COMPKY" value="100"  readonly="readonly" style="width:110px" />  <!-- UIInput="S,SHCOMMA"   -->
						</td>
					</tr>
					 <tr>
						<th CL="STD_DLVDAT">운송일자</th>
						<td>
							<input type="text" name="DLVDAT" UIInput="R" UIFormat="C Y" />
						</td>
					</tr>
					<tr>
						<th CL="STD_SHPTKY">출하지점</th>
						<td>
							<input type="text" name="SHPTKY" UIInput="R,SHPTKY" />
						</td>
					</tr>
					<tr>
						<th CL="STD_VKBUTX">제품군</th>
						<td>
							<input type="text" name="VKBUTX" UIInput="R,SHCMCDV" />
						</td>
					</tr>					
					<tr>
						<th CL="STD_VHCTYP">차량유형</th>
						<td>
							<input type="text" name="SFRGR" UIInput="R,SHCMCDV" />
						</td>
					</tr>
				</tbody>
			</table>
		</div>
	</div>
</div>
<!-- //searchPop -->

<!-- content -->
<div class="content">
	<div class="innerContainer">

		<!-- contentContainer -->
		<div class="contentContainer">

			<div class="bottomSect type1">
				<div class="tabs">
					<ul class="tab type2">
						<li><a href="#tabs1-1"><span CL='STD_SEARCH'></span></a></li>
					</ul>
					<div id="tabs1-1">
						<div class="section type1">
							<div class="table type2">
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
											<col width="100" />
											<col width="100" />
										</colgroup>
										<thead>
											<tr>
												<th CL='STD_NUMBER' rowspan="2">번호</th>
												<th CL='STD_VKBUTX' rowspan="2">제품군</th>
												<th CL='STD_VKBUTXNM' rowspan="2">제품군내역</th>
												<th CL='STD_CTGAMT' rowspan="2">운송금액</th>
												<th CL='STD_CTGCNT' rowspan="2">운송건수</th>
												<th CL='STD_DNRT01' rowspan="2">통합배차율</th>
												<th CL='STD_AVGVHCTYP' rowspan="2">평균차량톤수</th>
												<th CL='STD_LDRRT' colspan="3">적재율</th>
												<th CL='STD_GUBUN' rowspan="2">구분</th>
											</tr>
											<tr>
												<th CL='STD_LDRRT'>적재율</th>
												<th CL='STD_AVGLDRRT'>평균 적재율</th>
												<th CL='STD_UNBANAMT'>톤당 운반비</th>
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
											<col width="100" />
											<col width="100" />
										</colgroup>
										<tbody id="gridList">
											<tr CGRow="true">
												<td GCol="rownum">1</td>
												<td GCol="text,VKBUTX"></td>
												<td GCol="text,VKBUTXNM"></td>
												<td GCol="text,CTGAMT"></td>
												<td GCol="text,CTGCNT"></td>
												<td GCol="text,DNRT01"></td>
												<td GCol="text,AVGVHCTYP"></td>
												<td GCol="text,LDRRT" ></td>
												<td GCol="text,AVGLDRRT"></td>
												<td GCol="text,UNBANAMT"></td>
												<td GCol="text,GUBUN"></td>
											</tr>									
										</tbody>
									</table>
								</div>
							</div>
							<div class="tableUtil">
								<div class="leftArea">
									<button type="button" GBtn="find"></button>
									<button type="button" GBtn="sortReset"></button>
									<button type="button" GBtn="layout"></button>
									<button type="button" GBtn="total"></button>
									<button type="button" GBtn="excel"></button>
								</div>
								<div class="rightArea">
									<p class="record" GInfoArea="true"></p>
								</div>
							</div>
						</div>
					</div>
		<!-- //contentContainer -->
	</div>
</div>
<!-- //content -->
<%@ include file="/common/include/bottom.jsp" %>
</body>
</html>