<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>투입대기자재</title>
<%@ include file="/common/include/webdek/head.jsp" %>
<link rel="stylesheet" type="text/css" href="/common/theme/webdek/css/demo_layout.css">
<script type="text/javascript" src="/common/theme/webdek/js/head.js"></script>
	<link rel="stylesheet" type="text/css" href="/common/theme/webdek/css/demo_layout.css">
	<script type="text/javascript">
		var data;
		var werks;
		var matnr;
		var wrk_ordr_no;
		var wrk_ordr_seqno;
		var mach_cd;

		$(document).ready(function(){
			gridList.setGrid({
				id : "waitList",
				url : "/mes/Work/WRK34_POP02/json/datalist.data",
				bigdata : false
			})
			
			gridList.setGrid({
				id : "waitList2",
				url : "/mes/Work/WRK34_POP02/json/datalist.data",
				bigdata : false
			})

			data = page.getLinkPopData();
			console.log("## page.getLinkPopData() = ", data);

			werks = data[0].get("WERKS");
			matnr = data[0].get("MATNR");
			wrk_ordr_no = data[0].get("WRK_ORDR_NO");
			wrk_ordr_seqno = data[0].get("WRK_ORDR_SEQNO");
			mach_cd = data[0].get("MACH_CD");
			
			searchList();

            $("#button-0-2").click(function(event) {
                console.log("## 공정투입 CLICK ##");
                saveData();
            });
		});

		// 공정투입
		function saveData() {
			if (gridList.validationCheck("waitList", "all")) {
				
				var rowData = gridList.getSelectData("waitList");
                console.log("## saveData() > rowData = ", rowData);
				
				// validation
				if ((rowData != null) && (rowData != undefined)) {
					if (rowData.length > 0) {
						if(confirm("공정투입하시겠습니까?")){
							var list = gridList.getSelectData("waitList");

							list = String(list).replace(/"/g, '#');

							var jsonObj = "{";
								jsonObj += "#ORG_WRK_ORDR_NO# : #" + wrk_ordr_no + "#,";  
								jsonObj += "#ORG_WRK_ORDR_SEQNO# : #" + wrk_ordr_seqno + "#,";
								jsonObj += "#ORG_MACH_CD# : #" + mach_cd + "#,";
								jsonObj += "#SES_USER_ID# : #" + $("#SES_USER_ID").val() + "#,";  
								jsonObj += "#INSERT_LIST# : [" + list + "]";  
								jsonObj += "}";

							var param = new DataMap();
							param.put("P_TYPE", "SAVE");
							param.put("P_SEND_PARAM", jsonObj);

							console.log("## saveData() > param = ", param);

							netUtil.send({
								url : "/mes/Work/WRK34_POP02/json/datalist.data",
								param : param,
								successFunction : "savesuccessCallBack"
							});
						}
					} else {
						alert("투입할 자재를 선택해 주세요.");
						return false;
					}
				} else {
					alert("투입할 자재를 선택해 주세요.");
					return false;
				}
			}
		}

		// 공정 투입 후 실행
		function savesuccessCallBack(json){
			console.log("## savesuccessCallBack > json = ", json);

			if(json){
				if(json.data){
					if(json.CODE == 'E'){
						alert(json.MSG);
					}else{
						alert("공정투입 성공");
						page.linkPopClose();
					}
				}
			}
		} 

		// searchList 후 실행
		// function searchListCallBack(json){
		// 	console.log("## searchListCallBack > json = ", json);
		// 	$("#waitList").html(""); // 초기화

		// 	if ((json != null) && (json != undefined)) {
		// 		if ((json.map != null) && (json.map != undefined)) {
		// 			if(json.map.P_CODE == 'S'){
		// 				if ((json.map.P_RS_LIST != null) && (json.map.P_RS_LIST != undefined)) {
		// 					var resultHTML = "";
		// 					for (var i = 0; i < son.map.P_RS_LIST; i++)	{
		// 						resultHTML = resultHTML + '<tr CGRow="true">';
		// 						resultHTML = resultHTML + '		<td GH="50" GCol="rowCheck"></td>';
		// 						resultHTML = resultHTML + '		<td GH="50" GCol="rownum">1</td>';
		// 						resultHTML = resultHTML + '		<td GH="100" GCol="text,STOR_LOC_NM" style="text-align: center;">저장위치명</td>';
		// 						resultHTML = resultHTML + '		<td GH="90" GCol="text,WERKS" style="text-align: center;">플랜트</td>';
		// 						resultHTML = resultHTML + '		<td GH="60" GCol="text,SEQNO" style="text-align: center;">순번</td>';
		// 						resultHTML = resultHTML + '		<td GH="140" GCol="text,MATNR" style="text-align: center;">자재코드</td>';
		// 						resultHTML = resultHTML + '		<td GH="350" GCol="text,MATNR_NM" style="width:380px; text-align: left;">자재명</td>';
		// 						resultHTML = resultHTML + '		<td GH="140" GCol="text,WRK_ORDR_NO" style="width:160px; text-align: center;">작업지시번호</td>';
		// 						resultHTML = resultHTML + '		<td GH="80" GCol="text,WRK_ORDR_SEQNO" style="width:100px; text-align: center;">작업지시순번</td>';
		// 						resultHTML = resultHTML + '		<td GH="140" GCol="text,MACH_CD" style="width:100px; text-align: center;">설비코드</td>';
		// 						resultHTML = resultHTML + '		<td GH="140" GCol="text,IND_BCD" style="width:140px; text-align: center;">개별바코드</td>';
		// 						resultHTML = resultHTML + '		<td GH="100" GCol="text,INP_QTY" style="width:80px; text-align: center;">투입량</td>';
		// 						resultHTML = resultHTML + '		<td GH="100" GCol="text,USE_QTY" style="width:80px; text-align: center;">사용량</td>';
		// 						resultHTML = resultHTML + '		<td GH="100" GCol="text,STCK_QTY" style="width:80px; text-align: center;">재고</td>';
		// 						resultHTML = resultHTML + '		<td GH="60" GCol="text,UNIT" style="width:80px; text-align: center;">단위</td>';
		// 						resultHTML = resultHTML + '</tr>';
		// 					}
		// 				} else {
		// 					alert("조회된 데이터가 없습니다.");
		// 					page.linkPopClose();
		// 				}
		// 			} else {
		// 				alert("조회된 데이터가 없습니다.");
		// 				page.linkPopClose();
		// 			}
		// 		} else {
		// 			alert("조회된 데이터가 없습니다.");
		// 			page.linkPopClose();
		// 		}
		// 	}
		// } 

		// 조회
		function searchList() {
			console.log("## searchList() > START ##");

			var jsonObj = "{";
			jsonObj += "#SES_USER_ID# : #" + $("#SES_USER_ID").val() + "#,";  
			jsonObj += "#P_WERKS# : #" + werks + "#,";  
			jsonObj += "#P_MATNR# : #" + matnr + "#,";  
			jsonObj += "#P_WRK_ORDR_NO# : #" + wrk_ordr_no + "#,";  
			jsonObj += "#P_WRK_ORDR_SEQNO# : #" + wrk_ordr_seqno + "#,";  
			jsonObj += "#P_MACH_CD# : #" + mach_cd + "#";  
			jsonObj += "}";

			var param = new DataMap();
			param.put("P_TYPE", "LIST");
			param.put("P_SEND_PARAM", jsonObj);
			console.log("## searchList() > param = ", param);

			$("#waitList").html(""); // 초기화

			gridList.gridList({
				id : "waitList",
				param : param
			});

			console.log('gridList.jsonData = ', gridList.jsonData);
// 			searchsuccessCallback(grid);
// 			console.log('gridList', gridList);
// 			var wipQty;
// 			var waitQty;
// 			// 공정, 투입대기 수량 확인
// 			for (var i = 0; i < gridList.jsonData.data.length; i++) {
// 				if (gridList.jsonData.data[i]["STOR_LOC_NM"] == "공정재고") {
// 					wipQty++;
// 				} else {
// 					waitQty++;
// 				}
// 			}
// 			console.log('wipQty = ', wipQty);
// 			console.log('waitQty = ', waitQty);
// 			console.log("## searchList() > CLOSE ##");
		}

		// grid 조회 시 data 적용이 완료된 후
		function gridListEventDataBindEnd(gridId, dataLength){
			var wipQty;
			var waitQty;

			if(gridId === "waitList"){
				wipQty = 0;
				waitQty = 0;
				var list = gridList.getGridData(gridId);
				console.log('list = ', list);
				for(var i=0; i < list.length; i++) {
					if(list[i].get("STOR_LOC_NM") == "2000"){
						wipQty = wipQty + parseInt(list[i].get("STCK_QTY"), 10);
					} else if (list[i].get("STOR_LOC_NM") == "투입대기"){
						waitQty = waitQty + parseInt(list[i].get("STCK_QTY"), 10);
					} else {
						if (list[i].get("STOR_LOC_NM") == "투입") {
							gridList.setRowReadOnly("waitList", i, true, ["rowCheck"]);
						}
					}
				}
				
				console.log('waitQty.toFixed(2) = ', numberWithCommas(waitQty));
				console.log('wipQty.toFixed(2) = ', numberWithCommas(wipQty));
				document.getElementById('WAIT_QTY').value = numberWithCommas(waitQty);
				document.getElementById('WIP_QTY').value = numberWithCommas(wipQty);
			}
		}
		// 공정 투입 후 실행
		function searchsuccessCallBack(json){
			console.log("## searchsuccessCallBack > json = ", json);
			console.log('json.data = ', json.data);
			if(json){
			}
		} 

		// 숫자포맷 함수
		function numberWithCommas(x) {
		    return x.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
		}
		
		// 전체 checkbox 선택
		const gridListEventRowCheckAll = (gridId, checkType) => {
			f(gridId)
		}
		
		// 행 개별 checkbox 선택
		const gridListEventRowCheck = (gridId, rowNum, checkType) => {
// 			const data = gridList.getSelectData("waitList");
// 			if (data[0].map.STOR_LOC_NM == "투입") {
// 				return;
// 			}
			f(gridId)
		}
		
		// 체크박스 선택에 따른 함수
		const f = (gridId) => {
			console.log('gridId = ', gridId)
			var dumyobj;
			var cnt;
			var mapArray = [];
			var mapArray2 = [];
			var mapObj = {};
			var list = gridList.getGridData("waitList2");

			cnt = 0;
			if(gridId === "waitList"){
				dumyobj
				//console.log('gridId2 = ', gridId);
				const data = gridList.getSelectData("waitList")
				//console.log('data[0].map = ', data[data.length-1].map);
				//console.log('list = ', data);
				//console.log('data[data.length-1].map.MATNR = ', data[data.length-1].map.MATNR);
				
				gridList.resetGrid("waitList2");

				for (var i = 0; i < data.length; i++) {
					
					/*
					if (map.length == 0 || !map.get("MATNR")) {
						map.put("MATNR", data[i].map.MATNR);
						map.put("MATNR_NM", data[i].map.MATNR_NM);
						map.put("STCK_QTY", data[i].map.STCK_QTY);
						map.put("UNIT", data[i].map.UNIT);
					} else {
						
					}
					*/
					if (!mapArray[data[i].map.MATNR]) {
						mapArray[data[i].map.MATNR] = [];
						mapArray[data[i].map.MATNR][0] = data[i].map.MATNR;
						mapArray[data[i].map.MATNR][1] = data[i].map.STCK_QTY;
						mapArray[data[i].map.MATNR][2] = data[i].map.MATNR_NM;
						mapArray[data[i].map.MATNR][3] = data[i].map.UNIT;
					} else {
						mapArray[data[i].map.MATNR][1] = parseInt(mapArray[data[i].map.MATNR][1], 10) + parseInt(data[i].map.STCK_QTY, 10);
					}
					
					
				}
				
				console.dir(mapArray);
				console.log('for map = ', map);

// 				for (var i = 0; i < mapArray.length; i++) {
// 					map.put("MATNR", mapArray[i][0]);
// 					map.put("STCK_QTY", mapArray[i][1]);
// 					console.log('for map = ', map);
// 					mapArray2.push(map);
// 				}
				for (var i in mapArray) {
					var map = new DataMap();
					map.put("MATNR", mapArray[i][0]);
					map.put("STCK_QTY", mapArray[i][1]);
					map.put("MATNR_NM", mapArray[i][2]);
					map.put("UNIT", mapArray[i][3]);
				    //map["MATNR"] = mapArray[i][0];
				    //map["STCK_QTY"] = mapArray[i][1];
				    console.log('for map = ', map);
				    gridList.appendList('waitList2', [map]);
				}

				console.log('mapArray2 = ', mapArray2);
				

			}
		}
	</script>
</head>
<body>
<%@ include file="/common/include/webdek/layout.jsp" %>
<!-- content -->
<div class="content_wrap">
    <div class="content_inner">
        <div class="content_serch" id="searchArea">
			<input type="hidden" id="SES_USER_ID" value="<%=userid%>" />
            <div class="btn_wrap">
				<div class="fl_l">
				</div>
				<div class="fl_r">
					<input type="button" id="button-0-2" CB="Save SAVE BTN_PROCINPUT" />
				</div>
			</div>
		</div>
        <div class="content-horizontal-wrap bottom_layout" style="height: 95%">
            <div class="content_layout tabs" style="height: 60%;">
                <ul class="tab tab_style02">
                    <li><a href="#tab1-1"><span>투입대기자재 목록</span></a></li>
                    <li class="btn_zoom_wrap">
                        <ul>
                            <li><button class="btn btn_bigger"><span>확대</span></button></li>
                        </ul>
                    </li>
                </ul>
                <div class="table_box section" id="tab1-1">
                    <div class="table_list01">
                        <div class="scroll">
                            <table class="table_b">
								<tbody id="waitList">
									<tr CGRow="true">
										<td GH="50" GCol="rowCheck"></td>
										<td GH="50" GCol="rownum">1</td>
										<td GH="100" GCol="text,STOR_LOC_NM" style="text-align: center;">저장위치명</td>
										<td GH="90" GCol="text,WERKS" style="text-align: center;">플랜트</td>
										<td GH="60" GCol="text,SEQNO" style="text-align: center;">순번</td>
										<td GH="140" GCol="text,MATNR" style="text-align: center;">자재코드</td>
										<td GH="350" GCol="text,MATNR_NM" style="width:380px; text-align: left;">자재명</td>
										<td GH="140" GCol="text,WRK_ORDR_NO" style="width:160px; text-align: center;">작업지시번호</td>
										<td GH="80" GCol="text,WRK_ORDR_SEQNO" style="width:100px; text-align: center;">작업지시순번</td>
										<td GH="140" GCol="text,MACH_CD" style="width:100px; text-align: center;">설비코드</td>
										<td GH="140" GCol="text,IND_BCD" style="width:140px; text-align: center;">개별바코드</td>
										<td GH="100" GCol="text,INP_QTY" style="width:80px; text-align: center;">투입량</td>
										<td GH="100" GCol="text,USE_QTY" style="width:80px; text-align: center;">사용량</td>
										<td GH="100" GCol="text,STCK_QTY" style="width:80px; text-align: center;">재고</td>
										<td GH="60" GCol="text,UNIT" style="width:80px; text-align: center;">단위</td>
	                                </tr>
								</tbody>
                            </table>
                        </div>
                    </div>
                    <jsp:include page="/WEB-INF/jsp/common/commonBtnAuth.jsp">
						<jsp:param name="authCd" value="1" />
						<jsp:param name="showAuthCd" value="1,2,3,9,10" />
					</jsp:include>
                </div>
            </div>
            <br /><br />
            <div class="content_layout tabs" style="height: 30%;">
                <ul class="tab tab_style02">
                    <li><a href="#tab1-1"><span>선택목록</span></a></li>
                    <li class="btn_zoom_wrap">
                        <ul>
                            <li><button class="btn btn_bigger"><span>확대</span></button></li>
                        </ul>
                    </li>
                </ul>
                <div class="table_box section" id="tab1-2">
                    <div class="table_list01">
                        <div class="scroll">
                            <table class="table_b">
								<tbody id="waitList2">
									<tr CGRow="true">
										<td GH="140" GCol="text,MATNR" style="width:200px; text-align: center;">자재코드</td>
										<td GH="350" GCol="text,MATNR_NM" style="width:200px; text-align: left;">자재명</td>
										<td GH="100" GCol="text,STCK_QTY" style="width:200px; text-align: right;" GF='N 13,0'>재고수량</td>
										<td GH="60" GCol="text,UNIT" style="width:200px; text-align: center;">단위</td>
	                                </tr>
								</tbody>
                            </table>
                        </div>
                    </div>
                    <jsp:include page="/WEB-INF/jsp/common/commonBtnAuth.jsp">
						<jsp:param name="authCd" value="1" />
						<jsp:param name="showAuthCd" value="1,2,3,7,9,10" />
					</jsp:include>
                </div>
            </div>
	        <div>
	        	<label style="font-size : 20pt">대기합계</label>
				<input type="text" name="WAIT_QTY" id="WAIT_QTY" UIInput="B" UIFORMAT="C M1" style="font-size : 20pt; text-align: right;" readonly/>
	        	<label style="font-size : 20pt">공정합계</label>
				<input type="text" name="WIP_QTY" id="WIP_QTY" UIInput="B" UIFORMAT="C M1" style="font-size : 20pt; text-align: right;" readonly/>
	        </div>
        </div>
    </div>
</div>
<!-- // content -->
<%@ include file="/common/include/webdek/bottom.jsp" %>
</body>
</html>