<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>WMS</title>
<%@ include file="/common/include/head.jsp" %>
<script type="text/javascript" src="/common/js/ezgencontrol.js"></script>
<script type="text/javascript">

	function commonBtnClick(btnName){
		if(btnName == "Print"){	//팔레트 라벨 발행
			reportPrint();
		}else if(btnName == "Print2"){	//팔레트 라벨 재발행
			reportPrint2();
		}else if(btnName == "Reset"){	//초기화
			reset();
		}
	}

	//바코드 라벨 프린트 버튼
	function reportPrint(){
		var skukey =  $('input[name=SKUKEY]').val();	// 품번
		var desc01 =  $('input[name=DESC01]').val();	// 품명
		var skug05 =  $('input[name=SKUG05]').val();	// 품명
		var qtpuom =  $('input[name=QTPUOM]').val();	// 입수량
		var totqty =  $('input[name=TOTQTY]').val();	// 총수량

		var json = saveData();

		if(json && json.data){
			var wherestr = " AND BARCOD IN (" +json.data["BARCOD"]+ ")" ;
			
			var map = new DataMap();
			map.put("OWNRKY","<%=ownrky%>");
			WriteEZgenElement("/ezgen/barcodel.ezg", wherestr, "", "<%=langky%>",map,1100,650);
		}
	}

	//바코드 라벨 재발행 버튼
	function reportPrint2(){
		var wareky = $('input[name=PT_WAREKY]').val(); // 센터
		var pt_barcod = $('input[name=PT_BARCOD]').val(); // 팔렛트 바코드

		// 입력여부 확인 VALIDATION
		if( pt_barcod == '') {
			commonUtil.msgBox("VALID_M0936"); //바코드를 입력해주세요.
			return;
		}else{
			var wherestr = " AND BARCOD IN ('" +pt_barcod+ "')" ;
			
			var map = new DataMap();
			map.put("OWNRKY","<%=ownrky%>");
			WriteEZgenElement("/ezgen/barcodel.ezg", wherestr, "", "<%=langky%>",map,1100,650);
		}
	}

	function saveData(){
		var wareky = "<%=wareky%>";
		var skukey =  $('input[name=SKUKEY]').val();	// 품번코드
		var desc01 =  $('input[name=DESC01]').val();	// 품번명
		var qtpuom =  $('input[name=QTPUOM]').val();	// BOX 입수량
		var boxqty =  $('input[name=BOXQTY]').val();	// 박스 수
		var qtdrem =  $('input[name=QTDREM]').val();	// 잔량
		var totqty =  $('input[name=TOTQTY]').val();	// 총수량
		var prtcnt =  $('input[name=PRTCNT]').val();	// 인쇄수량

		if( skukey == ''){
			commonUtil.msgBox("VALID_M0551"); //품목을 먼저 선택해주세요.
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
				commonUtil.msgBox("VALID_M0554");	//잘못된 품목 코드 입니다.
				return;
			}
		}
		if( prtcnt == 0 ){
			commonUtil.msgBox("VALID_M2023");	//인쇄수량을 입력하세요.
			return;
		}

		var param = new DataMap();
		param.put("WAREKY", wareky);	//센터
		param.put("SKUKEY", skukey);	//품번
		param.put("DESC01", desc01);	//품명
		param.put("QTPUOM", qtpuom);	//입수량
		param.put("BOXQTY", boxqty);	//박스 수
		param.put("QTDREM", qtdrem);	//잔량
		param.put("TOTQTY", totqty);	//총수량
		param.put("PRTCNT", prtcnt);	//인쇄수량

		var json = netUtil.sendData({
			url : "/wms/labal/json/saveLB01.data",
			param : param
		});
		
		return json;
	}

	function searchHelpEventOpenBefore(searchCode, gridType){
		if(searchCode == "SHSKUMA"){
			var param = new DataMap();
			param.put("WAREKY", "<%=wareky%>");
			param.put("OWNRKY", "<%=ownrky%>");
			return param;
		}if(searchCode == "SHBARCOD"){
			var param = new DataMap();
			param.put("WAREKY", "<%=wareky%>");
		}
	}

	function getDesc01(){
		var skukey = $('input[name=SKUKEY]').val();			// 품번
		var pt_skukey = $('input[name=PT_SKUKEY]').val();	// 품번
		var param = new DataMap();
		var desc01 = "";
		var desc02 = "";
		var desc04 = "";
		var skug05 = "";
		var uomkey = "";
		param.put("OWNRKY", "<%=ownrky%>");
		param.put("WAREKY", "<%=wareky%>");
		param.put("SKUKEY", skukey);
		param.put("PT_SKUKEY", pt_skukey);

		var json = netUtil.sendData({
			module : "WmsLabel",
			command : "DESC01VALUE",
			sendType : "map",
			param : param
		});

		$('input[name=DESC01]').val(json.data["DESC01"]);		//품명
		$('input[name=UOMKEY]').val(json.data["UOMKEYBOX"]);	//BOX 입수/단위
		$('input[name=QTPUOM]').val(json.data["QTPUOMBOX"]);	//BOX 입수량
		$('input[name=TOTQTY]').val(json.data["QTPUOM"]);		//PLT 입수량
	}

	function chanagedQty(type){
		//1 : QTPUOM 입수/단위
		//2 : BOXQTY 박스 수
		//3 : QTDREM 잔량
		//4 : TOTQTY 총수량
		var qtipsu = (Number)($('input[name=QTPUOM]').val());	//BOX 입수량
		var boxqty = (Number)($('input[name=BOXQTY]').val());	//박스 수
		var qtdrem = (Number)($('input[name=QTDREM]').val());	//잔량
		var totqty = (Number)($('input[name=TOTQTY]').val());	//총수량
		
		if(type == "2"){	//박스 수 입력시
			totqty = (boxqty*qtipsu)+qtdrem
			$('input[name=TOTQTY]').val(totqty);	//총수량
		}else if(type == "3"){	//잔량 입력시
			totqty = (boxqty*qtipsu)+qtdrem
			$('input[name=TOTQTY]').val(totqty);	//총수량
		}else if(type == "4"){	//총수량 입력시
			boxqty = (totqty-qtdrem)/qtipsu			//박스 수
			qtyrem = totqty-(boxqty*qtipsu)			//잔량
			$('input[name=BOXQTY]').val(boxqty);
			$('input[name=QTDREM]').val(qtyrem);
		}
	}

	function searchHelpEventCloseAfter(searchCode, multyType, selectData, rowData){
		if(searchCode == "SHSKUMA"){
			getDesc01();
		}else if(searchCode == "SHBARCD"){
			getInfoBCD();
		}
	}
	
	//초기화 버튼
	function reset(){
		$('input[name=SKUKEY]').val("");
		$('input[name=DESC01]').val("");
		$('input[name=QTPUOM]').val("0");
		$('input[name=BOXQTY]').val("0");
		$('input[name=QTDREM]').val("0");
		$('input[name=TOTQTY]').val("0");
		$('input[name=PRTCNT]').val("0");
	}
	
	function getInfoBCD(){
		var wareky = $('input[name=PT_WAREKY]').val(); // 센터
		var pt_barcod = $('input[name=PT_BARCOD]').val(); // 팔렛트 바코드
		var param = new DataMap();
		param.put("WAREKY", wareky);
		param.put("PT_BARCOD", pt_barcod);

		var json = netUtil.sendData({
			module : "WmsLabel",
			command : "BARCODVALUE",
			sendType : "map",
			param : param
		});
		
		$('input[name=PT_SKUKEY]').val(json.data["SKUKEY"]);		//품번
		$('input[name=PT_DESC01]').val(json.data["DESC01"]);		//품명
		$('input[name=PT_QTPUOM]').val(json.data["QTDUOM"]);		//BOX 입수
		$('input[name=PT_UOMKEY]').val("BOX");						//BOX 단위
		$('input[name=PT_BOXQTY]').val(json.data["QTDBOX"]);		//박스 수량
		$('input[name=PT_QTDREM]').val(json.data["QTDREM"]);		//잔량
		$('input[name=PT_TOTQTY]').val(json.data["QTDPRT"]);		//총수량
	}

</script>
</head>
<body>

<div class="contentHeader">
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
						<li><a href="#tabs1-1" id="tab02" onclick="tabChg(1);"><span CL='STD_BARPRT'>바코드 라벨</span></a></li>
						<li><a href="#tabs1-2" id="tab02" onclick="tabChg(2);"><span CL='STD_PTBCDL'>바코드 라벨 재발행</span></a></li>
					</ul>

					<div id="tabs1-1">
						<div class="section type1" style="overflow-y:scroll;">
							<div class="util">
								<button CB="Reset CLEAR BTN_CLEAR">초기화</button>
								<button CB="Print PRINT BTN_PRINT">발행 프린트</button>
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
												<input type="text" name="WAREKY" validate="required,M0434" readonly="readonly" value="<%=wareky%>" style="width:160px;" />
											</td>
										</tr>
										<tr>
											<th CL="STD_SKUKEY">품번</th>
											<td>
												<input type="text" name="SKUKEY" validate="required" UIInput="S,SHSKUMA" onchange="getDesc01()" />
											</td>
										</tr>
										<tr>
											<th CL="STD_DESC01">품명</th>
											<td>
												<input type="text" name="DESC01" size="70" readonly="readonly" style="width:230px;" />
											</td>
										</tr>
										<tr>
											<th CL="STD_IPSUUOM" >입수/단위</th>
											<td>
												<input type="text" name="QTPUOM" size="10" UIFormat="N 20,3" value="0" readonly />&nbsp;<input type="text" name="UOMKEY" size="5" readonly="readonly" />
											</td>
										</tr>
										<tr>
											<th CL="STD_BOXQTY">박스 수</th>
											<td>
												<input type="text" name="BOXQTY" size="10" UIFormat="N 17" value="0" onchange="chanagedQty('2')"/>
											</td>
										</tr>
										<tr>
											<th CL="STD_REMQTY">잔량</th>
											<td>
												<input type="text" name="QTDREM" size="10" UIFormat="N 20,3" value="0" onchange="chanagedQty('3')"/>
											</td>
										</tr>
										<tr>
											<th CL="STD_TOTQTY">총수량</th>
											<td>
												<input type="text" name="TOTQTY" size="10" UIFormat="N 20,3" value="0" onchange="chanagedQty('4')" readonly />
											</td>
										</tr>
									</tbody>
								</table>
							</div>
							<div class="searchInBox">
 								<h2 class="tit" CL="STD_PRTINF">인쇄정보</h2>
								<table class="table type1">
									<colgroup>
										<col width="100" />
										<col />
									</colgroup>
									<tbody>
										<tr>
											<th CL="STD_PRTCNT">인쇄수량</th>
											<td>
												<input type="text" name="PRTCNT" validate="required,M0434" value="0" />
											</td>
										</tr>
									</tbody>
								</table>
							</div>
						</div>
					</div>

					<div id="tabs1-2">
						<div class="section type1" style="overflow-y:scroll;">
							<div class="util">
								<button CB="Reset CLEAR BTN_CLEAR">초기화</button>
								<button CB="Print2 PRINT BTN_PRINT">재발행 프린트</button>
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
												<input type="text" name="PT_WAREKY" style="width:160px;" validate="required,M0434" readonly="readonly" value="<%=wareky%>"/>
											</td>
										</tr>
										<tr>
											<th CL="STD_BARCOD">PLT 바코드</th>
											<td>
												<input type="text" name="PT_BARCOD" UIInput="S,SHBARCD" validate="required,M0434" onchange="getInfoBCD()" />
											</td>
										</tr>
										<tr>
											<th CL="STD_SKUKEY">품번</th>
											<td>
												<input type="text" name="PT_SKUKEY" style="width:160px;" readonly="readonly" />
											</td>
										</tr>
										<tr>
											<th CL="STD_DESC01">품명</th>
											<td>
												<input type="text" name="PT_DESC01" style="width:229px;" readonly="readonly" />
											</td>
										</tr>
										<th CL="STD_IPSU01">입수</th>
											<td>
												<input type="text" name="PT_QTPUOM" size="10" UIFormat="N" value="0" readonly />&nbsp;<input type="text" name="PT_UOMKEY" size="5" readonly="readonly" />
											</td>
										</tr>
										<tr>
											<th CL="STD_BOXQTY">박스 수</th>
											<td>
												<input type="text" name="PT_BOXQTY" size="10" UIFormat="N" value="0" readonly />
											</td>
										</tr>
										<tr>
											<th CL="STD_REMQTY">잔량</th>
											<td>
												<input type="text" name="PT_QTDREM" size="10" UIFormat="N" value="0" readonly />
											</td>
										</tr>
										<tr> 
											<th CL="STD_TOTQTY">총수량</th>
											<td>
												<input type="text" name="PT_TOTQTY" size="10" UIFormat="N" value="0" readonly />
											</td>
										</tr>
									</tbody>
								</table>
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