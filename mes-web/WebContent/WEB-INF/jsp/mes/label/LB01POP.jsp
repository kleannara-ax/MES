<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="com.common.bean.DataMap,com.common.bean.DataMap,java.util.*"%>
<%@ page import="com.common.bean.DataMap,com.common.bean.CommonConfig"%>

<%
	String wareky = request.getSession().getAttribute(CommonConfig.SES_USER_WHAREHOUSE_KEY).toString();
	String userid = request.getSession().getAttribute(CommonConfig.SES_USER_ID_KEY).toString();
	String username = request.getSession().getAttribute(CommonConfig.SES_USER_NAME_KEY).toString();
	String compky = request.getSession().getAttribute(CommonConfig.SES_USER_COMPANY_KEY).toString();
	String ownrky = request.getSession().getAttribute(CommonConfig.SES_USER_OWNER_KEY).toString();
	String langky = request.getSession().getAttribute(CommonConfig.SES_USER_LANGUAGE_KEY).toString();
	
%>
<%

	String strPrtqty = request.getParameter("strPrtqty");
	String strSkukey = request.getParameter("strSkukey");
	String strDesc01 = request.getParameter("strDesc01");
	
	String strQtduom = request.getParameter("strQtduom");
	String strBoxqty = request.getParameter("strBoxqty");
	String strRemqty = request.getParameter("strRemqty");
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>WMS</title>
<%@ include file="/common/include/searchHead.jsp" %>
<script type="text/javascript" src="/common/js/ezgencontrol.js"></script>
<script type="text/javascript">

	var searchCnt = 0; 
	var dblIdx = -1;
	var sFlag = true;
	
	function reportPrint(){
		var prtCnt =  $('input[name=PRTCNT]').val();	// 인쇄수량
		var prtQty =  $('input[name=PRTQTY]').val();	// 입고총수량
		var skukey =  $('input[name=SKUKEY]').val();	// 품번
		

		
		var json = saveData();
		
		if(json && json.data){
			var wherestr = " AND REFDKY = '" +json.data+ "'";
			//var wherestr = " AND REFDKY BETWEEN '" +json.data+ "' AND '" +json.data+ "'";
			
			if( $("input[name='BARSEC']:checked").val() == 'INDUPK'){
				WriteEZgenElement("/ezgen/barcodel.ezg", wherestr, "", "<%=langky%>" );
			} else {
				WriteEZgenElement("/ezgen/barcodem.ezg", wherestr, "", "<%=langky%>" );
			}
		}
		return;
	}
	
	
	function saveData(){
		
		var wareky = "<%=wareky%>";
		var prtCnt =  $('input[name=PRTCNT]').val();	// 인쇄수량
		var prtQty =  $('input[name=PRTQTY]').val();	// 입고총수량
		var skukey =  $('input[name=SKUKEY]').val();	// 품번코드
		var desc01 =  $('input[name=DESC01]').val();	// 품번명1
		var desc02 =  $('input[name=DESC02]').val();	// 품번명2
		var qtduom =  $('input[name=QTDUOM]').val();	// 입수
		var qtdbox =  $('input[name=QTDBOX]').val();	// 박스
		var qtdrem =  $('input[name=QTDREM]').val();	// 잔량
		var qtdprt =  $('input[name=QTDPRT]').val();	// 총수량

		if( prtCnt == '' ){
			// 인쇄수량은 필수입력입니다.
			commonUtil.msgBox("VALID_M0552");
			return;
		}else if(prtQty == ''){
			// 발행수량은 0 보다 커야합니다.
			commonUtil.msgBox("VALID_M0553");
			return;
		}
		if( skukey == '' ) {
			commonUtil.msgBox("VALID_M0551");
			return;
		} 
		if( skukey != '' ){
			var param = new DataMap();
			param.put("SKUKEY",skukey);
			var json = netUtil.sendData({
				module : "WmsLabel",
				command : "SKUKEYval",
				sendType : "map",
				param : param
			});
			if (json.data["CNT"] < 1) {
				commonUtil.msgBox("VALID_M0554");
				return;
			}
		}
		
		var param = new DataMap();
		param.put("WAREKY", wareky);
		param.put("PRTCNT", prtCnt);
		param.put("SKUKEY", skukey);
		param.put("DESC01", desc01);
		param.put("DESC02", desc02);
		param.put("QTDUOM", qtduom);
		param.put("QTDBOX", qtdbox);
		param.put("QTDREM", qtdrem);
		param.put("QTDPRT", qtdprt);
		
		var json = netUtil.sendData({
			url : "/wms/labal/json/saveLB01.data",
			param : param
		});
		
		return json;
	}
	
	function searchHelpEventOpenBefore(searchCode, gridType){
		//commonUtil.debugMsg("searchHelpEventOpenBefore : ", arguments);
		if(searchCode == "SHWAHMA"){
			var param = new DataMap();
			param.put("COMPKY", "<%=compky%>");
			return param;
	    }else if(searchCode == "SHSKUMABAR"){
			var param = new DataMap();
			param.put("WAREKY", "<%=wareky%>");
			param.put("OWNRKY", "<%=ownrky%>");
			return param;
		}
	}
</script>
</head>
<body>

<div class="contentHeader">
	<div class="util">
		<button class="button" type="button" onclick="reportPrint()" title="print">
			<span class="top_icon top_icon_09">출력 아이콘</span>
			<span cl="STD_PRINT" class="top_icon_text">출력</span>
		</button>
	</div>
	<div class="util2">
		<button class="button type2" id="showPop" type="button"><img src="/common/images/ico_btn4.png" alt="List" /></button>
	</div>
</div>

<!-- content -->
<div class="content">
	<div class="innerContainer">

		<!-- contentContainer -->
		<div class="contentContainer" id="contentContainer">
			<div class="bottomSect type1">
				<div class="tabs">
					<ul class="tab type2">
						<li><a href="#tabs1-1"><span>바코드생성/인쇄</span></a></li>
					</ul>
										
					<div id="tabs1-1">
						<div class="section type1" style="overflow-y:scroll;">
							<div class="searchInBox">
								<h2 class="tit" CL="STD_PRTINF">인쇄정보</h2>
								<table class="table type1">
									<colgroup>
										<col width="100" />
										<col />
									</colgroup>
									<tbody>
										<tr>
											<th CL="STD_BARSEC">Barcode구분</th>
											<td>
												<input type="radio" name="BARSEC" value="INDUPK" checked />Barcode 130*90 
												<input type="radio" name="BARSEC" value="INDUPA" />Barcode 100*60
											</td>
										</tr>
										
										<tr>
											<th CL="STD_PRTCNT">인쇄수량</th>
											<td>
												<input type="text" name="PRTCNT" validate="required,M0434" value=1 />
											</td>
										</tr>
										<tr>
											<th CL="STD_PRTQTY">입고총수량</th>
											<td>
												<input type="text" name="PRTQTY" value="<%=strPrtqty%>"/>
											</td>
										</tr>
									</tbody>
								</table>
							</div>
							
							<div class="searchInBox">
								<h2 class="tit" CL="STD_BARINF">바코드정보</h2>
								<table class="table type1">
									<colgroup>
										<col width="100" />
										<col />
									</colgroup>
									<tbody>
										<tr>
											<th CL="STD_WAREKY">거점</th>
											<td>
												<input type="text" name="WAREKY" UIInput="S,SHWAHMA" validate="required,M0434" value="<%=wareky%>" />
											</td>
										</tr>
										<tr>
											<th CL="STD_MATNR">품번코드</th>
											<td>
												<input type="text" name="SKUKEY" UIInput="S,SHSKUMABAR" value="<%=strSkukey%>" />
											</td>
										</tr>
										<tr>
											<th CL="STD_MATNRNM">품명</th>
											<td>
												<input type="text" name="DESC01" value="<%=strDesc01%>" />
											</td>
										</tr>
										<tr>
											<th CL="STD_NORMKY">규격</th>
											<td>
												<input type="text" name="DESC02" />
											</td>
										</tr>
										<tr>
											<th CL="STD_QTDUOM">입수</th>
											<td>
												<input type="text" name="QTDUOM" value="<%=strQtduom%>" />
											</td>
										</tr>
										<tr>
											<th CL="STD_BOX">박스</th>
											<td>
												<input type="text" name="QTDBOX" value="<%=strBoxqty%>" />
											</td>
										</tr>
										<tr>
											<th CL="STD_REMQTY">잔량</th>
											<td>
												<input type="text" name="QTDREM" value="<%=strRemqty%>" />
											</td>
										</tr>
										<tr>
											<th CL="STD_TOTQTY">총수량</th>
											<td>
												<input type="text" name="QTDPRT" />
											</td>
										</tr>
									</tbody>
								</table>
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