<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Grid default</title>
<%@ include file="/common/include/webdek/head.jsp"%>
<link rel="stylesheet" type="text/css"
	href="/common/theme/webdek/css/demo_layout.css">
<script type="text/javascript">
		var dblIdx = 0;

		$(document).ready(function(){
			gridList.setGrid({
				id : "gridList",
				url:"/mes/Master/MAS01/json/datalist.data",
				editable : false,
				bigdata:false,
				selectRowDeleteType : true
			})

			gridList.setGrid({
				id : "gridListSub",
				url:"/mes/Master/MAS01/json/datalist.data",
				pkcol : "CMCDKY,CMCDVL",
				editable : true,
				bigdata:false,
				selectRowDeleteType : true
			})
		});

		function searchList(){
			gridList.resetGrid("gridListSub");
			var param = inputList.setRangeParam("searchArea");
			
			param.put("P_TYPE", "LIST");
			
			gridList.gridList({		
				id : "gridList",
				param : param
			});
		}

		function searchSubList(headRowNum){
			var rowVal = gridList.getColData("gridList", headRowNum, "CMCDKY");
			var param = inputList.setRangeParam("searchArea");
			param.put("P_TYPE", "SUB_LIST");
			param.put("CMCDKY", rowVal);

			gridList.gridList({
				id : "gridListSub",
				param : param
			});

			lastFocusNum = headRowNum; //2020.04.13 LHJ 오류수정
			dblIdx = headRowNum;
		}

		var lastFocusNum = -1;

		function gridListEventDataBindEnd(gridId, dataLength){

			console.log('gridListEventDataBindEnd', gridId)
			if(gridId == "gridList" && dataLength > 0){
				searchSubList(0);
			}
		}

		function gridListEventRowDblclick(gridId, rowNum){
			if(gridId == "gridList"){
				if(gridList.getColData("gridList", rowNum, "GRowState") == "C"){
					return false;
				}
				dblIdx = rowNum;

				searchSubList(rowNum);
			}
		}

		//그리드 위에 클릭시 아이템 리셋
		function gridListEventRowFocus(gridId, rowNum){
			
			console.log('gridListEventRowFocus')
			if(gridId == "gridList"){
				if(dblIdx != rowNum){
					var modRowCnt = gridList.getModifyRowCount("gridListSub");
					if(modRowCnt == 0){
						if(dblIdx != rowNum){
							gridList.resetGrid("gridListSub");
							dblIdx = -1;
						}
						//저장
					}else{
						if(commonUtil.msgConfirm("COMMON_M0024")){//값이 변화된 데이터가 있습니다. 이동하시겠습니까?
							gridList.resetGrid("gridListSub");
						}else{
							//gridListEventRowFocus("gridList", dblIdx);
							gridList.setRowFocus("gridList", dblIdx, false);
							return;
						}
					}
				}
			}
		}

		function gridListEventRowAddBefore(gridId, rowNum) {
			if(gridId == "gridList"){
				var headCnt = gridList.getModifyRowCount("gridList");
				var listCnt = gridList.getModifyRowCount("gridListSub");
				if(listCnt > 0 || headCnt > 0){
					commonUtil.msgBox("MASTER_M0702");//변경된 row를 저장 후 행추가 하십시오.
					return false;
				}else{
					var newData = new DataMap();
					newData.put("GRowState", "C");

					return newData;
				}
			}else if(gridId == "gridListSub"){
				if(dblIdx == -1){
					var headNum = gridList.getGridDataCount("gridList") - 1;
					var data = gridList.getGridData("gridList");

					if(gridList.getColData("gridList", headNum, "GRowState") == ""){
						//alert(commonUtil.getMsg("MASTER_M0577"));
						commonUtil.msgBox("MASTER_M0577");
						return false;
					}

					var cmcdky = gridList.getColData("gridList", headNum, "CMCDKY");

					if(cmcdky != ""){
						var newData = new DataMap();
						newData.put("CMCDKY",cmcdky);

						return newData;
					}else{
						//alert(commonUtil.getMsg("MASTER_M0128"));
						commonUtil.msgBox("MASTER_M0128");
						return false;
					}
				}else{

					var cmcdky = gridList.getColData("gridList", dblIdx, "CMCDKY");

					var newData = new DataMap();
					newData.put("CMCDKY",cmcdky);

					return newData;
				}
			}
		}

		function gridListEventColValueChange(gridId, rowNum, colName, colValue){
			if(gridId == "gridList" && colName == "CMCDKY"){
				if(colValue != ""){
					var cmcdky = gridList.getColData("gridList", rowNum, "CMCDKY");

					var param = new DataMap();
					param.put("CMCDKY",colValue);

					var json = netUtil.sendData({
						module : "mes",
						command : "CC01CMCDKYval",
						sendType : "map",
						param : param
					});

					if(json.data["CNT"] >= 1) {
						gridList.setColValue("gridList", rowNum, "CMCDKY", "");
						//alert(commonUtil.getMsg("MASTER_M0129",colValue));
						commonUtil.msgBox("MASTER_M0129",colValue);
						return false;
					}
				}
				if(gridList.getGridDataCount("gridListSub") > 0){
					var listCnt = gridList.getGridDataCount("gridList");
					var sublistCnt = gridList.getGridDataCount("gridListSub");
					if(listCnt != 0){
						for(var i = 0; i < sublistCnt; i++){
							gridList.setColValue("gridListSub", i, "CMCDKY", colValue);
						}
					}
				}
			}else if(gridId == "gridListSub" && colName == "CMCDVL"){
				if(colValue != ""){
					var cmcdky = gridList.getColData("gridListSub", rowNum, "CMCDKY");

					var param = new DataMap();
					param.put("CMCDKY",cmcdky);
					param.put("CMCDVL",colValue);

					var json = netUtil.sendData({
						module : "mes",
						command : "CC01CMCDVLval",
						sendType : "map",
						param : param
					});

					//2020.04.16 삭제후 같은 데이터 추가가능
					var validCheck = false;
					if(json.data["CNT"] >= 1) {
						var subListCnt = gridList.getGridDataCount("gridListSub");
						for(var i = 0; i < subListCnt; i++){
							if(gridList.getRowState("gridListSub", i) == "D") {
								var subDataMap = gridList.getRowData("gridListSub", i);
								if(subDataMap.get("CMCDVL") == colValue) {
									validCheck = true;
									break;
								}
							}
						}

						if(validCheck) {
							return;
						}

						gridList.setColValue("gridListSub", rowNum, "CMCDVL", "");
						//alert(commonUtil.getMsg("MASTER_M0318"));
						commonUtil.msgBox("MASTER_M0318");
						return false;
					}
				}
			}
		}

		function saveData(){
			//2020.04.14 ItemList없이 HeadList저장되는 오류 수정
			//var rowNum = 0;
			// 2020.04.16 아이템리스트 없을때 저장되는 오류 재수정
			var dCnt = 0;
			if(gridId = "gridListSub"){
				for(var i = 0; i < gridList.getGridDataCount("gridListSub"); i++) {
					if(gridList.getRowState(gridId, i) == configData.GRID_ROW_STATE_DELETE){
						dCnt++;
					}
				}
				if(gridList.getModifyRowCount("gridList") > 0) {
					if(gridList.getModifyData("gridList")[0].get("GRowState") != configData.GRID_ROW_STATE_DELETE
							&& gridList.getGridDataCount("gridListSub") == dCnt) {
						commonUtil.msgBox("OUT_M0045");
						return;
					}
				}
			}

			if(gridList.getModifyRowCount("gridList") == 0 && gridList.getModifyRowCount("gridListSub") == 0 ){
				commonUtil.msgBox("MASTER_M0545");
				return;
			}
			if(!commonUtil.msgConfirm(configData.MSG_MASTER_SAVE_CONFIRM)){
				return;
			}
			if(gridList.validationCheck("gridList", "modify") && gridList.validationCheck("gridListSub", "modify")){
				var headNum = gridList.getGridDataCount("gridList") -1;

				if(gridList.getRowStatus("gridList",headNum) == "C" && gridList.getGridDataCount("gridListSub") == 0){
					//alert(commonUtil.getMsg("OUT_M0045"));
					commonUtil.msgBox("OUT_M0045");   //처리를 위한 아이템이 존재하지 않습니다.
					return;
				}

				/* var headCnt = gridList.getGridDataCount("gridList");
				for(var i = 0; i < headCnt; i++){
					gridList.setColValue("gridList", i, "GRowState", gridList.getRowStatus("gridList", i));
				} */
				var head = gridList.getModifyData("gridList", "A");

				/* var listCnt = gridList.getGridDataCount("gridListSub");
				for(var i = 0; i < listCnt; i++){
					gridList.setColValue("gridListSub", i, "GRowState", gridList.getRowStatus("gridListSub", i));
				} */

				var list = gridList.getModifyData("gridListSub", "A");
				
				if(list.length >= 100){
					alert("100개 이상의 데이터를 처리할 수 없습니다.");
					return;
				}
				
				var param = new DataMap();
				
				param.put("P_TYPE", "SAVE");
				param.put("head", head);
				param.put("list", list);

				var json = netUtil.sendData({
					url : "/mes/Master/MAS01/json/datalist.data",
					param : param
				});
				
				commonUtil.msgBox(configData.MSG_SYSTEM_SAVEOK);
				gridList.resetGrid("gridListSub");
				searchList();

			}
		}
	function commonBtnClick(btnName){
		if(btnName == "Search"){
			var param = new DataMap();
			
	        param.put("PROGID", "<%=menuId%>");
			param.put("LGTYPE", "SEARCH");
			
			var json = netUtil.sendData({
				url : "/mes/system/json/saveLog.data",
				param : param
			});

			searchList();
		} else if (btnName == "Save") {
			saveData();
		} else if (btnName == "Execute") {
			test3();
		}
	}

	function gridExcelDownloadEventBefore(gridId) {
		var param = inputList.setRangeParam("searchArea");
		if (gridId == "gridListSub") {
			var rowNum = gridList.getFocusRowNum("gridList");
			var cmcdky = gridList.getColData("gridList", rowNum, "CMCDKY");

			param.put("CMCDKY", cmcdky);
		}
		return param;
	}

	//2020.04.14 LHJ HeadList삭제 시 아이템리스트 삭제여부 메시지 추가
	function gridListEventRowRemove(gridId, rowNum) {
		if (gridId == "gridList") {
			var headCnt = gridList.getModifyRowCount("gridList");
			var listCnt = gridList.getModifyRowCount("gridListSub");
			if (listCnt > 0 || headCnt > 0) {
				commonUtil.msgBox("MASTER_M0702");//변경된 row를 저장 후 행추가 하십시오.
				return false;
			}

			var headlist = gridList.getColData("gridList", rowNum, "CMCDKY");

			var param = new DataMap();
			param.put("CMCDKY", headlist);

			var json = netUtil.sendData({
				module : "mes",
				command : "CC01CMCDKYval",
				sendType : "map",
				param : param
			});

			if (json.data["CNT"] > 0) {
				commonUtil.msgBox("VALID_M0016");//아이템리스트도 같이 삭제됩니다.삭제하시겠습니까?
				gridList.resetGrid("gridListSub");
				return;
			}
		}
	}
</script>
</head>
<body>
	<%@ include file="/common/include/webdek/layout.jsp"%>
	<!-- content -->
	<div class="content_wrap">
		<div class="content_inner">
			<%@ include file="/common/include/webdek/title.jsp"%>
			<div class="content_serch" id="searchArea">
				<div class="btn_wrap">
					<div class="fl_l"></div>
					<div class="fl_r">
						<input type="button" id="button-0-1" CB="Search SEARCH BTN_SEARCH" />
						<input type="button" id="button-0-2" CB="Save SAVE BTN_SAVE" /> 
						
					</div>
				</div>
				<div class="search_inner">
					<div class="search_wrap ">
						<dl>
							<dt CL="STD_CMCDKY"></dt>
							<dd>
								<input type="text" name="CV.CMCDKY" UIInput="R" UIFormat="U" />
							</dd>
						</dl>
					</div>
					<div class="btn_tab">
						<input type="button" class="btn_more" value="more" onclick="searchMore()" />
					</div>
				</div>
			</div>
			<div class="search_next_wrap">
				<div class="content_layout tabs top_layout">
					<ul class="tab tab_style02">
						<li><a href="#tab1-1" CL="STD_LIST"><span>일반</span></a></li>
						<li class="btn_zoom_wrap">
							<ul>
								<li><button class="btn btn_bigger"><span>확대</span></button></li>
							</ul>
						</li>
					</ul>
					<div class="table_box section" id="tab1-1">
						<div class="table_list01">
							<div class="scroll">
								<table class="table_c">
									<tbody id="gridList">
										<tr CGRow="true">
											<td GH="40" GCol="rownum">1</td>
											<td GH="40" GCol="rowCheck"></td>
											<td GH="100" GCol="input,CMCDKY" validate="required"
												GF="S 20" style="text-align: center;"></td>
											<!-- 공통 코드 키 -->
											<td GH="100" GCol="input,SHORTX" GF="S 180"></td>
											<!-- 설명 -->
											<td GH="130" GCol="input,DBFILD" GF="S 30"></td>
											<!-- DB 필드 이름 -->
											<td GH="100" GCol="input,USARL1" GF="S 30"></td>
											<!-- UA Lbl.1 -->
											<td GH="100" GCol="input,USARL2" GF="S 30"></td>
											<!-- UA Lbl.1 -->
											<td GH="100" GCol="input,USARL3" GF="S 30"></td>
											<!-- UA Lbl.1 -->
											<td GH="100" GCol="input,USARL4" GF="S 30"></td>
											<!-- UA Lbl.1 -->
											<td GH="100" GCol="input,USARL5" GF="S 30"></td>
											<!-- UA Lbl.1 -->
											<td GH="100" GCol="check,SYONLY"></td>
											<!-- 시스템에서만사용 -->
											<td GH="140" GCol="text,REGDATE" style="text-align: center;" GF="DTS"></td>
											<td GH="100" GCol="text,REGNM"></td>
											<td GH="140" GCol="text,UPDDATE" style="text-align: center;" GF="DTS"></td>
											<td GH="100" GCol="text,UPDNM"></td>
										</tr>
									</tbody>
								</table>
							</div>
						</div>
						<jsp:include page="/WEB-INF/jsp/common/commonBtnAuth.jsp">
							<jsp:param name="authCd" value="1" />
							<jsp:param name="showAuthCd" value="1,2,3,4,5,6,9,10" />
						</jsp:include>
					</div>
				</div>
				<div class="content_layout tabs bottom_layout">
					<ul class="tab tab_style02">
						<li><a href="#tab1-1"><span>일반</span></a></li>
						<li class="btn_zoom_wrap">
							<ul>
								<li><button class="btn btn_bigger">
										<span>확대</span>
									</button></li>
							</ul>
						</li>
					</ul>
					<div class="table_box section" id="tab1-1">
						<div class="table_list01">
							<div class="scroll">
								<table class="table_c">
									<tbody id="gridListSub">
										<tr CGRow="true">
											<td GH="40" GCol="rownum">1</td>
											<td GH="40" GCol="rowCheck"></td>
											<td GH="100" GCol="text,CMCDKY" style="text-align: center;"></td>
											<!-- 공통 코드 키 -->
											<td GH="100" GCol="input,CMCDVL" validate="required"
												GF="S 20" style="text-align: center;"></td>
											<!-- 유형코드 -->
											<td GH="100" GCol="input,CDESC1" GF="S 180"></td>
											<!-- 코드 설명 -->
											<td GH="100" GCol="input,CDESC2" GF="S 180"></td>
											<!-- 코드 설명2 -->
											<td GH="130" GCol="input,USARG1" GF="S 40"></td>
											<!-- UA. 1 -->
											<td GH="100" GCol="input,USARG2" GF="S 10"></td>
											<!-- UA. 2 -->
											<td GH="100" GCol="input,USARG3" GF="S 10"></td>
											<!-- UA. 3 -->
											<td GH="100" GCol="input,USARG4" GF="S 10"></td>
											<!-- UA. 4 -->
											<td GH="100" GCol="input,USARG5" GF="S 10"></td>
											<!-- UA. 5 -->
											<td GH="100" GCol="select,USE_YN" validate="required">
												<select CommonCombo="USEYN">
													<option value=""></option>
												</select>
											</td>
											<td GH="140" GCol="text,REGDATE" style="text-align: center;" GF="DTS"></td>
											<td GH="100" GCol="text,REGNM"></td>
											<td GH="140" GCol="text,UPDDATE" style="text-align: center;" GF="DTS"></td>
											<td GH="100" GCol="text,UPDNM"></td>
										</tr>
									</tbody>
								</table>
							</div>
						</div>
						<jsp:include page="/WEB-INF/jsp/common/commonBtnAuth.jsp">
							<jsp:param name="authCd" value="2" />
							<jsp:param name="showAuthCd" value="1,2,3,4,5,6,9,10" />
						</jsp:include>
					</div>
				</div>
			</div>
		</div>
	</div>
	<!-- // content -->
	<%@ include file="/common/include/webdek/bottom.jsp"%>
</body>
</html>