<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>WMS</title>
<%@ include file="/common/include/head.jsp" %>
<script type="text/javascript">
	$(document).ready(function(){
		gridList.setGrid({
	    	id : "gridList",
			editable : true,
			pkcol : "WAREKY,SKUKEY",
			module : "WmsInventory",
			command : "SD04"
	    });
		
		$("#Opt1").hide();
	});
	
	function searchList(){
		if(validate.check("searchArea")){
			var param = inputList.setRangeParam("searchArea");
		 	
	 		gridList.gridList({
		    	id : "gridList",
		    	param : param
		    });  
		}
	}
	
	function test(value){
		if(value == '1'){
			$("#Opt1").show();
		}else{
			$("#Opt1").hide();
		}
	}

	function commonBtnClick(btnName){
		if(btnName == "Search"){
			searchList();
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
			<button CB="GetVariant GETVARIANT BTN_GETVARIANT"></button>
			<button CB="SaveVariant SAVEVARIANT BTN_SAVEVARIANT"></button>
		</p>
		<div class="searchInBox" id="searchArea">
			<h2 class="tit" CL="STD_SELECTOPTIONS">일반정보</h2>
	
			<table class="table type1">
				<colgroup>
					<col width="100" />
					<col />
				</colgroup>
				<tbody>
					<tr>
						<th CL="STD_WAREKY">거점</th>
						<td>
							<input type="text" name="WAREKY" value="<%=wareky%>" readonly="readonly" />
						</td>
					</tr>
					<!-- <tr>
						<th CL="STD_STKMON"></th>
						<td>
							<input type="text" name="STKMON" UIInput="R" UIFormat="C" />
						</td>
					</tr> -->
					<tr>
						<th CL='STD_DATE'></th>
						<td>
							<input type="text" name="LSHPCDF" UIFormat="C N" validate="required"/> ~
							<input type="text" name="LSHPCDT" UIFormat="C N" validate="required"/>
						</td>
					</tr>
<!-- 					<tr>
						<th CL='STD_FROMDATE' width="50"></th>
						<td width="100">
							<input type="text" name="LSHPCDF" UIFormat="C" />
						</td>
						<th CL='STD_TODATE1' width="100"></th>
						<td>
							<input type="text" name="LSHPCDT" UIFormat="C" />
						</td>
					</tr> -->
					<tr>
						<th CL="STD_SKUKEY"></th>
						<td>
							<input type="text" name="SKUKEY" UIInput="R" />
						</td>
					</tr>
					<tr>
						<th CL="STD_INNDPT">주기</th>
						<td>
							<input type="radio" name="Opt" value="0" checked="checked" onclick="test(0);" />
							<label for="Opt" CL="STD_MONTHLY"></label>
							<input type="radio" name="Opt" onclick="test(1);" />
							<label for="Opt" CL="STD_DAYLY"></label>
							<select name="Opt1" id="Opt1">
								<option value="1" CL='STD_WEEK01'></option>
								<option value="2" CL='STD_WEEK02'></option>
								<option value="3" CL='STD_WEEK03'></option>
								<option value="4" CL='STD_WEEK04'></option>
							</select>
						</td>
					</tr>
				</tbody>
			</table>
		</div>
	</div>
</div>
<!-- //searchPop -->

<div class="content">
	<div class="innerContainer">
		<!-- contentContainer -->
		<div class="contentContainer">
			<div class="bottomSect type1">
				<div class="tabs"  id="bottomTabs">
					<ul class="tab type2">
						<li><a href="#tabs1-1"CL="STD_GENERAL"><span></span></a></li>
					</ul>
					<div id="tabs1-1">
						<div class="section type1">
							<div class="table type2">
								<div class="tableHeader">
									<table>
										<colgroup>
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
											<col width="100" />
											<col width="100" />
											<col width="100" />  
											<col width="100" />  
											<col width="100" />  
											<col width="100" />  
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
												<th CL='STD_NUMBER'>번호</th>
												<th CL='STD_WAREKY'></th>
												<th CL='STD_WSTDAT'></th>
												<th CL='STD_WEDDAT'></th>
												<th CL='STD_STKMON'></th>
												<th CL='STD_WMNDAT'></th>
												<th CL='STD_STKMON'></th>
												<th CL='STD_SKUKEY'></th>
												<th CL='STD_DESC01'></th>
												<th CL='STD_QTSIWH'></th>
												<th CL='STD_QTNREC'></th>
												<th CL='STD_QTYCFM'></th>
												<th CL='STD_QTYAVL'></th>
												<th CL='STD_QTYREQ'></th>
												<th CL='STD_TRMRPL'></th>
												<th CL='STD_QTYSAF'></th>
												<th CL='STD_QTYTAR'></th>
												<th CL='STD_QTYEXP'></th>
												<th CL='STD_CREDAT'></th>
												<th CL='STD_CRETIM'></th>
												<th CL='STD_CREUSR'></th>
												<th CL='STD_LMODAT'></th>
												<th CL='STD_LMOTIM'></th>
												<th CL='STD_LMOUSR'></th>
												<th CL='STD_ERRTXT'></th>
											</tr>
										</thead>
									</table>
								</div>
								<div class="tableBody">
									<table>
										<colgroup>
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
											<col width="100" />
											<col width="100" />
											<col width="100" />  
											<col width="100" />  
											<col width="100" />  
											<col width="100" />  
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
											    <td GCol="text,WAREKY"></td>
											    <td GCol="text,WSTDAT"></td>
											    <td GCol="text,WEDDAT"></td>
											    <td GCol="text,STKMON"></td>
											    <td GCol="text,WISDAT"></td>
											    <td GCol="text,WMNDAT"></td>
											    <td GCol="text,SKUKEY"></td>
											    <td GCol="text,DESC01"></td>
											    <td GCol="text,QTSIWH" GF="N 20,3"></td>
											    <td GCol="text,QTNREC" GF="N 20,3"></td>
											    <td GCol="text,QTYCFM" GF="N 20,3"></td>
											    <td GCol="text,QTYAVL" GF="N 20,3"></td>
											    <td GCol="text,QTYREQ" GF="N 20,3"></td>
											    <td GCol="text,TRMRPL" GF="N 20,3"></td>
											    <td GCol="text,QTYSAF" GF="N 20,3"></td>
											    <td GCol="text,QTYTAR" GF="N 20,3"></td>
											    <td GCol="text,QTYEXP" GF="N 20,3"></td>
											    <td GCol="text,CREDAT" GF="D"></td>
											    <td GCol="text,CRETIM" GF="T"></td>
											    <td GCol="text,CREUSR"></td>
											    <td GCol="text,LMODAT" GF="D"></td>
											    <td GCol="text,LMOTIM" GF="T"></td>
											    <td GCol="text,LMOUSR"></td>
											    <td GCol="text,ERRTXT"></td>
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