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
			command : "MGR01_FAIL_SEARCH1",
			gridMobielType : true
	    });

	});
	
	function searchList(){
		if(validate.check("searchArea")){
			console.log($("#SKUKEY").val());

			var param = new DataMap();
			param.put("SKUKEY", $("#SKUKEY").val());
			gridList.gridList({
		    	id : "gridList",
		    	param : param
		    });
		}

	}
</script>	
</head>
<body>
	<div class="main_wrap">
		<div class="whyfail_wrap">
				<div class="search_box">
					<table>
						<colgroup>
							<col />
							<col width="100px"  />
						</colgroup>
						<tbody id="searchArea">
							<tr>
								<td class="second">
									<input type="text" id="SKUKEY" value="SGP00001" class="text" validate="required"/>
								</td>
								<td>
									<input type="button" value="조회" class="bt" onclick="searchList()"/>
								</td>
							</tr>
							
						</tbody>
					</table>
				</div>
				<div class="tem5_content">
					<div class="tableHeader">
<<<<<<< .mine
					<table>
						<colgroup>
								<col width="40px" />
								<col width="36%" />
								<col width="45%" />
						</colgroup>
							<thead>
								<tr>
									<th>번호</th>
									<th>검사항목코드</th>
									<th>검사항목명</th>
								</tr>
							</thead>
					</table>				
				</div>
					
					
				<div class="tableBody">
					<table>
						<colgroup>
								<col width="40px" />
								<col width="36%" />
								<col width="45%" />
						</colgroup>
						<tbody>
								<tr>
									<td>1</td>
									<td>ACCC</td>
									<td>형합검사(CASE류)</td>
								</tr>
								<tr>
									<td>2</td>
									<td>ACC2</td>
									<td>외관검사(CASE류)</td>
								</tr>
								<tr>
									<td>3</td>
									<td>ACC3</td>
									<td>신뢰성검사(CASE류)</td>
								</tr>
								
=======
					<div class="tableHeader">
						<table>
							<colgroup>
									<col width="40px" />
									<col width="36%" />
									<col width="45%" />
							</colgroup>
								<tbody>
									<tr class="thead">
										<th>번호</th>
										<th>검사항목코드</th>
										<th>검사항목명</th>
									</tr>
								</tbody>
						</table>
					</div>
					
					<div class="tableBody">
						<table>
							<colgroup>
								<col width="50px" />
								<col />
								<col />
								<col />
								<col />
							</colgroup>
							<tbody id="gridList">
								<tr CGRow="true">
									<td GCol="rownum"></td>
									<td GCol="text,QCITEM"></td>
									<td GCol="text,ITMENAME"></td>
								</tr>						
>>>>>>> .r6195
							</tbody>
						</table>
					</div>		
				</div>
				<div class="bottom">
					<input type="button" value="선택" class="bottom_bt"/>
				</div>
		</div>	
<<<<<<< .mine
	</div>	
	</div>	
=======
	</div>	
>>>>>>> .r6195
</body>
