<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.common.bean.*,com.common.util.*,com.common.bean.CommonConfig,java.util.*"%>
<%
	User user = (User)request.getSession().getAttribute(CommonConfig.SES_USER_OBJECT_KEY);
%>
<!doctype html>
<head>
<meta charset="utf-8">
<meta name="viewport" content="user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, width=device-width, target-densitydpi=medium-dpi" />
<meta name="format-detection" content="telephone=no" />
<title>IMV Mobile WMS</title>
<%@ include file="/mobile/include/head.jsp" %>
<script>
	$(document).ready(function(){
		$("#USERAREA").val("<%=user.getUserg5()%>");
		$("#CREUSR").val("<%=user.getUserid()%>");
	});
	
	function sendData(){
		if(validate.check("searchArea")){
			var param  = inputList.setRangeParam("searchArea");
			
			var WAREKY = param.get("WAREKY");
			var OWNRKY = param.get("OWNRKY");
			var AREAKY = param.get("AREAKY");
			var RQSHPD = param.get("RQSHPD");
			var SHPOKY = param.get("SHPOKY");
			var SKUKEY = param.get("SKUKEY");
			var DESC01 = param.get("DESC01");
			var CREUSR = param.get("CREUSR");
			
			location.href="/mobile/MOM05_list.page?WAREKY="+WAREKY
												+"&OWNRKY="+OWNRKY
												+"&AREAKY="+AREAKY
												+"&RQSHPD="+RQSHPD
												+"&SHPOKY="+SHPOKY
												+"&SKUKEY="+SKUKEY
												+"&DESC01="+DESC01
												+"&CREUSR="+CREUSR;
		}
	}
	
	function clearText(data){
		if(data != null || data != ""){
		   data.value = "";
		}      
	}
	
	function showMain(){
		window.top.menuOpen();
	}
</script>
</head>
<body>
	<div class="main_wrap">
		<div class="tem3_content">
			<div class="search" id="searchArea">
				<table>
					<colgroup>
						<col width="80px"  />
						<col />
						<col width="60px" />
					</colgroup>
					<tbody>
						<tr>
							<th CL="STD_WAREKY">거점</th>
							<td>
								<input type="text" class="text" name="WAREKY" size="8px" validate="required,VALID_M0401" value="<%=wareky%>" readonly="readonly" />
							</td>
							<td>
								<input type="button" value="Search" class="bt" onclick="sendData()"/>
							</td>
						</tr>
						<tr>
							<th CL="STD_OWNRKY">화주</th>
							<td>
								<input type="text" class="text" name="OWNRKY" value="<%=ownrky%>" validate="required" />
							</td>
						</tr>
						<tr>
							<th CL="STD_AREAKY">창고</th>
							<td>
								<select Combo="WmsAdmin,AREACOMBO" name="AREAKY" id="USERAREA" validate="required"></select>
							</td>
						</tr>
						<tr>
							<th CL="STD_RQSHPD">출고요청일자</th>
							<td>
								<input type="text" class="text" name="RQSHPD" UIFormat="C N" validate="required,VALID_M1555" style="width:95%;" />
							</td>
						</tr>
						<tr>
							<th CL="STD_SHPOKY">출고문서번호</th>
							<td>
								<input type="text" class="text" name="SHPOKY" />
							</td>
						</tr>
						<tr>
							<th CL="STD_SKUKEY">품번코드</th>
							<td>
								<input type="text" class="text" name="SKUKEY" />
							</td>
						</tr>
						<tr>
							<th CL="STD_DESC01">품명</th>
							<td>
								<input type="text" class="text" name="DESC01" />
							</td>
						</tr>
						<tr>
							<th CL="STD_CREUSR">생성자</th>
							<td>
								<input type="text" class="text" name="CREUSR" id="CREUSR" validate="required" />
							</td>
						</tr>
					</tbody>
				</table>
			</div>
			<div class="bottom">
				<a href="#" onClick="showMain()"><input type="button" value="Main" class="bottom_bt" /></a>
			</div>
		</div>
	</div>
</body>