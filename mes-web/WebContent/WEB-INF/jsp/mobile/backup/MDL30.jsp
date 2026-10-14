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
			command : "MDL30CAN",
			gridMobileType : true
	    });
	});
	
	function searchList(){
		var opt = $("#COLNAME").val();
		var credat = $("#CREDAT").val();
		
		location.href="/mobile/MDL30_list.page?OPT="+opt+"&CREDAT="+credat;
	}
	
</script>
</head>
<body>
	<div class="main_wrap">
		<div class="tem4_content" id="searchArea">
			<div class="select_box">
				<table>
					<colgroup>
						<col  />
						<col width="100px" />
					</colgroup>
					<tbody>
						<tr>
							<td>
								<input type="text" name="CREDAT" id="CREDAT" class="text" UIFormat="C N" />
							</td>
							<td rowspan="2">
								<a href="#"><input type="button" value="조회" class="bt" onclick="searchList()"/></a>
							</td>
						</tr>
						<tr>
							<td class="first">
								<select name="COLNAME" id="COLNAME">
									<option value="CANREG">취소 송장</option>
									<option value="SELREG">지정 송장</option>
								</select>
							</td>
						</tr>
					</tbody>
				</table>
			</div>
		</div>	
	</div>
</body>