<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
	String BARCOD = request.getParameter("BARCOD");
	String TASKKY = request.getParameter("TASKKY");
%>
<!doctype html>
<head>
<style type="text/css">
button {float: right; }
input:read-only {background-color: #e2e2e2;}
select:DISABLED {background-color: #e2e2e2;}
</style>
<meta charset="utf-8">
<meta name="viewport" content="user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, width=device-width, target-densitydpi=medium-dpi" />
<meta name="format-detection" content="telephone=no" />
<title>Mobile WMS</title>
<%@ include file="/mobile/include/head.jsp" %>
<script>
	var gridCommand = ""; //이전 조회 화면에서 조회 형태에 따라 쿼리를 변경해 주기 위한 변수
	var leftChk     = ""; // < 버튼 쿼리 분기 체크용
	var rightChk    = ""; // > 버튼 쿼리 분기 체크용
	var stayChk     = ""; // <> 이동후 조회 내역 존재하지 않을경우 stay 조회
	var completeChk = true; //완료시 종료를 위해 체크
	var itemlist    = [];
	var curIdx      = 0;
	
	$(document).ready(function(){
		gridList.setGrid({
			id : "gridList",
			editable : false,
			module : "WmsMobilePutaway",
			command : "PDPT01",
			gridMobileType : true,
			emptyMsgType:false
		});
		searchList();
	});

	function searchList(){
		var param = new DataMap();
		param.put("TASKKY", "<%=TASKKY%>");
		param.put("WAREKY", "<%=wareky%>");
		
		var json = netUtil.sendData({
			url : "/mobile/MobilePutaway/json/PDPT01.data",
			param : param
		});
		
		if(json && json.data) {
			itemlist = json.data;
			var totalCnt = 0;
			var totalQtt = 0;
			var totalPage = itemlist.length;
			var curCnt = 0;
			var curQtt = 0;
			$("#PAGE").val(totalPage);
			for(var i = 0; i < itemlist.length; i++){
				if(itemlist[i].STATIT == "NEW") {
					totalCnt += 1;
				} else {
					totalCnt += 1;
					curCnt += 1;
				}
				totalQtt += Number(itemlist[i].QTTAOR);
				curQtt += Number(itemlist[i].QTYTOT);
			}
			$("#COMPCNT").val(totalCnt);
			$("#COMPCNT2").val(curCnt);
			$("#QTCOMP_L7141").val(totalQtt);
			$("#QTCOMP_L7141_2").val(curQtt);
			
			if(curCnt == totalCnt) {
				commonUtil.msgBox("IN_M0151");	//해당 작업지시는 모두 적치완료 되었습니다.
				screenClose();
			} else {
				for(var i = 0; i < itemlist.length; i++){
					var data = itemlist[i];
					curIdx = i;
					if(data.STATIT == "NEW"){
						$("#LOCASR").val(data.LOCASR);
						$("#EANCOD").val(data.EANCOD);
						$("#SKUKEY").val(data.SKUKEY);
						$("#DESC01").val(data.DESC01);
						$("#QTTAOR").val(data.QTTAOR);
						$("#UOMKEY").val(data.SUOMKY);
						$("#QTCOMP").val(data.QTTAOR);
						$("#UOMKEY2").val(data.SUOMKY);
						$("#UOMKEY3").val(data.SUOMKY);
						$("#UOMKEY4").val(data.SUOMKY);
						$("#LOCATG").val(data.LOCATG);
						$("#TRNUAC").val(data.TRNUAC);
						$("#LOCATG").focus();
						$("#PAGE2").val(curIdx+1);
						return;
					}
				}
			}
		}
	}

	function showItem(index){
		$("#PAGE2").val(curIdx+1);
		var data = itemlist[index];
		$("#LOCATG").val(data.LOCATG);
		$("#TRNUAC").val(data.TRNUAC);
		$("#LOCASR").val(data.LOCASR);
		$("#EANCOD").val(data.EANCOD);
		$("#SKUKEY").val(data.SKUKEY);
		$("#DESC01").val(data.DESC01);
		$("#QTTAOR").val(data.QTTAOR);
		$("#UOMKEY").val(data.SUOMKY);
		if(data.STATIT == "NEW") {
			$("#QTCOMP").val(data.QTTAOR);
		} else {
			$("#QTCOMP").val(data.QTCOMP);
		}
		$("#UOMKEY2").val(data.SUOMKY);
		if(data.STATIT == "NEW"){
			$("#LOCATG").attr("readonly", false);
			$("#TRNUAC").attr("readonly", false);
			$("#QTCOMP").attr("readonly", false);
			if($("#LOCATG").val().length == 0){
				$("#LOCATG").focus();
			} else {
				$("#LOCATG").select();
			}
		} else {
			$("#LOCATG").attr("readonly", true);
			$("#TRNUTG").attr("readonly", true);
			$("#QTCOMP").attr("readonly", true);
			$("#LOCATG").val($("#LOCASR").val());
			$("#TRNUAC").val($("#EANCOD").val());
		}
	}

	//그리드 data binding 이후 발생 이벤트
	function gridListEventDataBindEnd(gridId, dataCount){
		if(gridId == "gridList"){
			//그리드 카운팅 후 마지막 카운팅일 경우 닫기 이벤트
			if(dataCount == 0 && completeChk){
				PlaySound("e");
				screenClose();
			}else if(dataCount == 0){
				PlaySound("e");
				stayChk = "V";
				leftChk = "";
				rightChk= "";
				searchList();
			}else{
				PlaySound("s");
				stayChk="";
				leftChk = "";
				rightChk= "";
			}
			setData(0);//hidden 그리드 Row=0 데이터 세팅
			
		}
	}

	//하단 버튼 이벤트
	function skipLeft(){
		if(curIdx == 0) {
			curIdx = itemlist.length-1;
		} else {
			curIdx--;
		}
		showItem(curIdx);
	}

	//닫기 버튼 클릭시 기존 조회 정보를 가지고 이전 화면으로 이동 후 조회
	function screenClose(){
		var paramStr = "TASKKY="+<%=TASKKY%>;
		location.href="/mobile/PDPT01.page?"+paramStr+"&FLAG=N";
	}

	//적치완료
	function saveData(){
		if($("#LOCATG").attr("readonly") == "readonly"){
			commonUtil.msgBox("OUT_M0045");   //처리를 위한 아이템이 존재하지 않습니다.
			return;
		} else {
			if(validate.check("searchArea")){
				if($("#LOCATG").val() == ""){
					commonUtil.msgBox("MOBILE_M0026");   //TO지번을 입력해주세요.
				}
				if(Number($("#QTCOMP").val()) > ($("#QTTAOR").val())) {
					commonUtil.msgBox("MOBILE_M0004");   //작업수량(QTCOMP)은 지시수량(QTTAOR)보다 클 수 없습니다.
					$("#QTCOMP").select();
					return;
				}
				if(Number($("#QTCOMP").val()) == 0) {
					commonUtil.msgBox("MOBILE_M0005");   //0보다 큰 수량을 입력해 주세요.
					$("#QTCOMP").select();
					return;
				}
				
				var list = itemlist[curIdx];
				list.LOCAAC = $("#LOCATG").val();
				list.TRNUAC = $("#TRNUAC").val();
				list.LOTA11 = $("#LOTA11").val().replace(".","");
				list.LOTA12 = $("#LOTA12").val().replace(".","");
				list.QTCOMP = Number($("#QTCOMP").val());
				var param = new DataMap();
				param.put("list",list);
				
				
				var json = netUtil.sendData({
					url:"/mobile/MobilePutaway/json/savePDPT01POP.data",
					param : param
				});
				
				if(json && json.data) {
					commonUtil.msgBox("TASK_M0339");   //적치완료되었습니다.
					
					var cnt = json.data["CNT"];
					if(cnt == 0){
						//TASDI.STATIT = 'NEW'가 없으면 적치완료 첫 페이지로 넘어가기
						location.href="/mobile/PDPT01.page?"
					}else{
						//TASDI.STATIT = 'NEW'가 남았으면 next 페이지로 넘어가기
						skipRight();
					}
				}
			}
		}
	}

	// > 버튼 이벤트
	function skipRight(){
		if(curIdx == itemlist.length-1) {
			curIdx = 0;
		} else {
			curIdx++;
		}
		showItem(curIdx);
	}

	//제조일자(LOTA11) 날짜형식 check
	function lota11Check(){
		var slota11 = $('#LOTA11').val().split(".");
		var lota11 = slota11[0]+slota11[1]+slota11[2];
		
		var today = new Date();
		var year = today.getFullYear();
		var month = today.getMonth()+1;
		var date = today.getDate();
		
		if (month < 10){
			month = "0" + month;
		}
		if (date < 10){ 
			date = "0" + date;
		}
		var sysdate = year+month+date;
		
		if(slota11 != ""){
			//제조일자는 과거일자만 가능하도록 체크(미래일자는 x)
			if(lota11 > sysdate){
				commonUtil.msgBox("VALID_M1607");   //제조일자는 오늘/과거일자만 입력 가능합니다.
				$('#LOTA11').val("");
				$("#LOTA11").focus();
				return;
			}
		}
		
		$("#QTCOMP").select();
	} 

	function locatg(){
		$('#TRNUID').select();
	}

	function trnuid(){
		$('#QTCOMP').select();
	}

</script>
</head>
<body>
	<div class="main_wrap" id="searchArea">
		<div class="tem4_content">
			<div class="select_box" id="bindArea">
				<table>
					<colgroup>
						<col width="100px" />
						<col />
						<col width="80px" />
						<col />
					</colgroup>
					<tbody>
						<tr>
							<th CL='STD_PTCOMP' style="font-size:20px">적치완료</th>
							<td colspan="2"></td>
						</tr>
					</tbody>
				</table>
				<table>
					<colgroup>
						<col width="80px" />
						<col width="70px" />
						<col width="40px" />
						<col width="70px" />
						<col />
					</colgroup>
					<tbody>
						<tr>
							<th CL='STD_FROMLOC'>From 지번</th>
							<td colspan="2">
								<input type="text" class="text" name="LOCASR" id="LOCASR" readonly/>
							</td>
							<th CL='STD_BARCOD'>바코드</th>
							<td colspan="2">
								<input type="text" class="text" name="EANCOD" id="EANCOD" readonly/>
							</td>
						</tr>
						<tr>
							<th CL='STD_SKUKEY'>품번</th>
							<td colspan="5">
								<input type="text" class="text" name="SKUKEY" id="SKUKEY" readonly/>
							</td>
						</tr>
						<tr>
							<th CL='STD_DESC01'>품명</th>
							<td colspan="5">
								<input type="text" class="text" name="DESC01" id="DESC01" readonly/>
							</td>
						</tr>
						<tr>
							<th CL='STD_LOCATG'>To 지번</th>
							<td colspan="2">
								<input type="text" class="text" name="LOCATG" id="LOCATG" onkeypress="commonUtil.enterKeyCheck(event, 'locatg()')" validate="required"/>
							</td>
							<th CL='STD_TRNUID'>파렛트</th>
							<td colspan="2">
								<input type="text" class="text" name="TRNUAC" id="TRNUAC" onkeypress="commonUtil.enterKeyCheck(event, 'trnuid()')"/>
							</td>
						</tr>
						<tr>
							<th CL='STD_LOTA11'>To 제조일자</th>
							<td colspan="3">
								<input type="text" class="text" name="LOTA11" id="LOTA11" UIFormat="C" style="width:70%; float:left;" onclick="lota11Check()">
							</td>
						</tr>
						<tr>
							<th CL='STD_LOTA12'>To 입고일자</th>
							<td colspan="3">
								<input type="text" class="text" name="LOTA12" id="LOTA12" UIFormat="C N" style="width:70%; float:left;" validate="required"/>
							</td>
						</tr>
						<tr>
							<th  CL='STD_QTYRCV1'>지시수량</th>
							<td>
								<input type="text" class="text gridColInputNumber" name="QTTAOR" id="QTTAOR" UIFormat="N 10" readonly/>
							</td>
							<td>
								<input type="text" class="text" name="UOMKEY" id="UOMKEY" style="text-align:center" readonly/>
							</td>
							<th  CL='STD_QTWORK'>작업수량</th>
							<td>
								<input type="text" class="text gridColInputNumber" name="QTCOMP" id="QTCOMP" UIFormat="N 10" validate="required"/>
							</td>
							<td>
								<input type="text" class="text" name="UOMKEY2" id="UOMKEY2" style="text-align:center" readonly/>
							</td>
						</tr>
					</tbody>
				</table>
				<hr />
				<table>
					<colgroup>
						<col width="120px"/>
						<col width="50px"/>
						<col width="100px"/>
						<col width="50px"/>
						<col width="50px"/>
						<col width="100px"/>
						<col width="50px"/>
					</colgroup>
					<tbody>
						<tr>
							<th  CL='STD_COMPCNT'>완료건수</th>
							<td>총</td>
							<td>
								<input type="text" class="text gridColInputNumber" name="COMPCNT" id="COMPCNT" readonly/>
							</td>
							<td>건</td>
							<td>중</td>
							<td>
								<input type="text" class="text gridColInputNumber" name="COMPCNT2" id="COMPCNT2" readonly/>
							</td>
							<td>건</td>
						</tr>
						<tr>
							<th CL='STD_QTCOMP_L7141'>완료수량</th>
							<td>총</td>
							<td>
								<input type="text" class="text gridColInputNumber" name="QTCOMP_L7141" id="QTCOMP_L7141" readonly/>
							</td>
							<td>
								<input type="text" class="text" name="UOMKEY3" id="UOMKEY3" style="text-align:center" readonly/>
							</td>
							<td>중</td>
							<td>
								<input type="text" class="text gridColInputNumber" name="QTCOMP_L7141_2" id="QTCOMP_L7141_2" readonly/>
							</td>
							<td>
								<input type="text" class="text" name="UOMKEY4" id="UOMKEY4" style="text-align:center" readonly/>
							</td>
						</tr>
						<tr>
							<th CL='STD_PAGE'>페이지</th>
							<td>총</td>
							<td>
								<input type="text" class="text gridColInputNumber" name="PAGE" id="PAGE" readonly/>
							</td>
							<td>PAGE</td>
							<td>중</td>
							<td>
								<input type="text" class="text gridColInputNumber" name="PAGE2" id="PAGE2" readonly/>
							</td>
							<td>PAGE</td>
						</tr>
					</tbody>
				</table>
				<hr />
				<!-- hidden table -->
				<div class="tableWrap_search section" style="display:none;" >
					<div class="tableHeader">
						<table style="width: 100%"> 
							<colgroup>
								<col width="40px" />
								<col width="80px" />
								<col width="80px" />
								<col width="80px" />
								<col width="80px" />
								<col width="80px" />
								<col width="80px" />
								<col width="80px" />
								<col width="80px" />
								<col width="80px" />
								<col width="80px" />
							</colgroup>
							<thead>
								<tr class="thead">
									<th CL='STD_NO'>순번</th>
									<th>ORTNNO</th>
									<th>EANCOD</th>
									<th>SKUKEY</th>
									<th>DESC01</th>
									<th>QTYORG</th>
									<th>QTPUOM</th>
									<th>SHPOKY</th>
									<th>SHPOIT</th>
									<th>REFDKY</th>
									<th>REFDIT</th>
								</tr>
							</thead>
						</table>				
					</div>
					<div class="tableBody">
						<table style="width: 100%">
							<colgroup>
								<col width="40px" />
								<col width="80px" />
								<col width="80px" />
								<col width="80px" />
								<col width="80px" />
								<col width="80px" />
								<col width="80px" />
								<col width="80px" />
								<col width="80px" />
								<col width="80px" />
								<col width="80px" />
							</colgroup>
							<tbody id="gridList">
								<tr CGRow="true">
									<td GCol="rownum"></td>
									<td GCol="text,ORTNNO"></td>
									<td GCol="text,EANCOD"></td>
									<td GCol="text,SKUKEY"></td>
									<td GCol="text,DESC01"></td>
									<td GCol="text,QTYORG"></td>
									<td GCol="text,QTPUOM"></td>
									<td GCol="text,SHPOKY"></td>
									<td GCol="text,SHPOIT"></td>
									<td GCol="text,REFDKY"></td>
									<td GCol="text,REFDIT"></td>
								</tr>
							</tbody>
						</table>
					</div>
				</div>
			</div>
			<!-- end table_body -->
			<div class="footer_5">
				<table>
					<tr>
						<td class=f_1 onclick ="skipLeft()" width="20%"><label CL='BTN_LEFT'>왼쪽</label></td>
						<td class=f_1 onclick ="screenClose()" width="30%"><label CL='BTN_CLOSE'>닫기</label></td>
						<td class=f_1 onclick ="saveData()" width="30%"><label CL='BTN_PCONFIRM'>적치완료/label></td>
						<td class=f_1 onclick ="skipRight()" width="20%"><label CL='BTN_RIGHT'>오른쪽</label></td>
					</tr>
				</table>
			</div><!-- end footer_5 -->	
		</div>
	</div>
</body>