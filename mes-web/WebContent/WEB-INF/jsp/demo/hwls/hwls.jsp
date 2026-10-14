<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Grid default</title>
<style>
	.gridIcon-center{text-align: center;}
	.impflg{display:inline-block; width:23px; height:23px; overflow:hidden; background: url(/common/images/ico_confirm.png) no-repeat 3px 3px; background-size:18px; text-indent:-500em;}
	.regAft{display:inline-block; width:23px; height:23px; overflow:hidden; background: url(/common/images/ico_cancel.png) no-repeat 3px 3px; background-size:18px; text-indent:-500em;}
	.icon_detail {background: url("/common/images/top_icon_11.png") no-repeat;border: none;cursor: pointer;display:inline-block;width:33px;height:21px;text-indent:-500em;overflow:hidden;}
</style>
<%@ include file="/common/include/head.jsp" %>
<!-- CSS -->
<link rel="stylesheet" type="text/css" href="/common/css/innerGridContent.css">
<!-- JS -->
<script language="JavaScript" src="/common/js/pagegrid/gridInnerButton.js"></script>
<script language="JavaScript" src="/common/js/pagegrid/gridDetail.js"></script>
<script language="JavaScript" src="/common/js/pagegrid/sendQueData.js"></script>
<script type="text/javascript">
	$(document).ready(function(){
		gridList.setGrid({
	    	id : "gridList",
			module : "Demo",
			command : "DEMOITEM",
			scrollPageCount : 100
	    });
		
		/* 상세보기 레이어 팝업
		* gridInnerButton.js
		* option : 
			1. gridId : 상세보기에 반영될 grid id (setGrid의 아이디와 일치 해야됨)
		    2. title : 상세보기 레이어 팝업의 제목(라벨 코드를 사용해야된)
			3. move : 상세보기 레이어 팝업 이동 가능 여부 (true / false)
		    4. holder : 사용안한
		    5. reflect : [ 반영 ] 버튼 사용여부(true / false)
		    6. table : 상세보기 레이어 팝업에 그려질 컬럼들을 작성(반드시 grid에 정의된 컬럼만 사용 가능하며 그리드에 정의된 속성값을 그대로 사용한다.)
		    7.gridListEventRowDblclick 이벤트 에서 gridDetail.gridDetailBind(gridId, rowNum) 함수를 호출 하여 사용한다.
		*/
		gridDetail.setGridDetail({
			gridId : "gridList",
			title : "STD_SEARCH",
			move : true,
			holder : false,
			reflect : true,
			table : [
				         [
							[{name : "WAREKY"},{name : "AREAKY"},{name : "ZONEKY"}],
							[{name : "LOCAKY"},{name : "TKZONE"},{name : "INDCPC"}],
							[{selectOption: true,name : "LOCATY"},{selectOption: true,name : "STATUS"},{name : "INDUPA"}],
							[{name : "INDUPK"},{name : "MAXCPC"},{name : "WIDTHW"}],
							[{name : "HEIGHT"},{name : "MIXSKU"},{name : "MIXLOT"}],
							[{name : "CREDAT"},{name : "CREUSR"},{name : "CUSRNM"}],
				         ]
					 ]
		});
		
		/* gridInnerButton.js 그리드 내부 버튼
		* option 
			1.areaId : 버튼이 생성될 위치의 id값 (그리드 아이디와 중복 불가)
		    2.buttonId : 버튼의 id
		    3.buttonType : 버튼의 타입
		    4.gridId : 일괄반영이 적용될 그리드 아이디
		    5.label : 버튼명(반드시 라벨 코드로 작성해야됨)
		    6.icon : 버튼 앞부분의 이미지(gridInnerButton.js 안에 정의된 코드값으로만 사용)
		    7.userFunction : 사용자가 정의할 수 있는 function
		*/    
		gridInnerButton.setGridInnerButton({
			areaId: "gridButtonArea",
			buttonId: "reflect",
			buttonType: "userButton",
			gridId: "gridList",
			label: "STD_ALLREF",
			icon : "reflect",
			userFunction : function(){ 
				gridDetail.showReflectDetail("gridList");
			}	
		});
		
		/* 일괄반영 레이어 팝업
		* gridInnerButton.js
		* option : 
			1. gridId : 상세보기에 반영될 grid id (setGrid의 아이디와 일치 해야됨)
			2. move : 일괄반영 레이어 팝업 이동 가능 여부 (true / false)
		    3. table : 일괄반영 레이어 팝업에 그려질 컬럼들을 작성(반드시 grid에 정의된 컬럼만 사용 가능하며 그리드에 정의된 속성값을 그대로 사용한다.)
			4. 일괄반영 레이어 팝업을 사용하기 위해서는 gridDetail.showReflectDetail(gridId) 함수를 호출하여 사용한다.
		*/
		gridDetail.setGridReflect({
			gridId : "gridList",
			move : true,
			table : [
			            [
							[{name : "ZONEKY"},{name : "LOCAKY"},{name : "CREDAT"}],
							[{selectOption: true,name : "LOCATY"},{selectOption: true,name : "STATUS"},{name : "INDUPA"}],
							[{name : "INDUPK"},{name : "MAXCPC"},{name : "WIDTHW"}],
							[{name : "HEIGHT"},{name : "MIXSKU"},{name : "MIXLOT"}]
						]
			        ]
		});
	});
	
	function searchList(){
		if(validate.check("searchArea")){
			var param = inputList.setRangeParam("searchArea");
			gridList.gridList({
		    	id : "gridList",
		    	param : param,
		    	scrollReset : true
		    });
		}
	}
	
	function saveData(){
		if(gridList.validationCheck("gridList", "all")){
			var param = inputList.setRangeDataParam("searchArea");
			var list = gridList.getSelectData("gridList", true);
			var listLen = list.length;
			if(listLen > 0){
				/* 대용량 데이터 저장 및 저장 시 프로그래스바
				* sendQueData.js
				* option : 
					1. url : 저장 로직 url
					2. queCount : 분할로 저장 시킬 data row 수 (Max. 1000건 씪)
				    3. totalCount :  grid의 총 row 수
				    4. gridList :  저장 할 grid의 id
					5. param : 파라미터(DataMap)
					6. successFunction : callBack 함수 return json
				*/
				sendQueData.directSend({
					url : "/demo/hwls/json/saveDemoItem.data",
					queCount : 500,
					totalCount : listLen,
					gridList : list,
					param : param,
					successFunction : "saveDemoItemCallBack"
		        });
			}
		}		
	}
	
	function saveDemoItemCallBack(json){
		if(json && json.data){
			searchList();
		}
	}
	
	function commonBtnClick(btnName){
		//commonUtil.debugMsg("commonBtnClick : ", arguments);
		if(btnName == "Search"){
			searchList();
		}else if(btnName == "Save"){
			saveData();
		}
	}
	
	function gridListEventRowDblclick(gridId, rowNum){
        if(gridId == "gridList"){
      		gridDetail.gridDetailBind(gridId, rowNum);
        }
    }
	
	/* gridListEventColBtnclick : 그리드 속성이 btn2 일떄 Icon 버튼을 클릭하면 발생 시키는 이벤트
	*  TMS 모듈에서 사용
	*  그리드 안에 Icon 버튼을 클릭하면 해당 함수가 실행 됩니다.(gridId :: 그리드아이디, rowNum :: 클릭한 Icon의 Row 번호, btnName :: Icon name 속성 을 가져옴)
	*/
	function  gridListEventColBtnclick(gridId, rowNum, btnName){
		console.log(gridId, rowNum, btnName);
		var rowData = gridList.getRowData("gridList", rowNum);
		commonUtil.msgBox("gridListEventColBtnclick : " + rowData.get("TKZONE"));
    }
	
	/* gridListColIconRemove : 특정조건에 따라 그리드 안에 Icon을 변경/제거 
	*  scroll event 시, grid.js > setRowViewHtml 에서 html draw 전에  해당 함수 존재 여부에 따라 실행되며,
	*  1.특정 조건에 따라 체크박스 icon html text를 제거(return true 일 경우)
	*  2.특정 조건에 따라 체크박스 icon html text를 변경(return 이미지 class 일 경우)
	*/
	function gridListColIconRemove(gridId, rowNum, colName, colValue){
		if(gridId == "gridList" && colName == "INDCPC"){
			if(colValue == "V"){
				return false;	
			}else{
				return "regAft";
			}
		}
	}
	
	/*gridListCheckBoxDrawBeforeEvent : 특정 조건에 따라 그리드 안에 체크박스 제거 
	* scroll event 시, grid.js > setRowViewHtml 에서 html draw 전에  해당 함수 존재 여부에 따라 실행되며,
	* 특정 조건에 따라 체크박스  checkbox html text를 제거(return true 일 경우)
	*/
	function gridListCheckBoxDrawBeforeEvent(gridId,rowNum){
		if(gridId == "gridList"){
			var data = gridList.getColData(gridId, rowNum, "INDCPC");
			if(data == "V"){
				return true;
			}
		}
	}
</script>
</head>
<body>
<div class="contentHeader">
	<div class="util">
		<button CB="Search SEARCH BTN_DISPLAY"></button>
		<button CB="Save SAVE BTN_SAVE"></button>
	</div>
	<div class="util3">
		<button class="button type2" id="showPop" type="button"><img src="/common/images/ico_btn4.png" alt="List" /></button>
	</div>
</div>

<!-- searchPop -->
<div class="searchPop" id="searchArea">
	<button type="button" class="closer">X</button>
	<div class="searchInnerContainer">
		<p class="util">
			<button CB="Search SEARCH BTN_DISPLAY"></button>
			<button CB="GetVariant GETVARIANT BTN_GETVARIANT"></button>
			<button CB="SaveVariant SAVEVARIANT BTN_SAVEVARIANT"></button>
		</p>
		<div class="searchInBox">
			<h2 class="tit" CL="STD_SELECTOPTIONS"></h2>
			<table class="table type1">
				<colgroup>
					<col width="100" />
					<col />
				</colgroup>
				<tbody>
					<tr>
						<th CL="STD_WAREKY"></th>
						<td>
							<input class="requiredInput" type="text" id="WAREKY" name="WAREKY" UIInput="R,SHAREMA" IAname="WAREKY"/>
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
						<li><a href="#tabs1-1"><span CL='STD_SEARCH'>탭메뉴1</span></a></li>
					</ul>
					<div id="tabs1-1">
						<div class="section type1" id="gridButtonArea">
							<div class="table type2">
								<div class="tableBody">
									<table>
										<tbody id="gridList">
											<tr CGRow="true">
												<td GH="40" GCol="rownum">1</td>
												<td GH="40" GCol="rowCheck"></td>
												<td GH="80" GCol="text,WAREKY"></td>
												<td GH="80" GCol="text,AREAKY"></td>
												<td GH="80" GCol="input,ZONEKY,SHZONMA" GF="U 10" validate="required"></td> 
												<td GH="80" GCol="input,LOCAKY" validate="required" GF="S 20"></td>
												<td GH="80" GCol="btn2,TKZONE" GB="Recommend icon_detail BTN_RECOMD"></td>
												<td GH="80" GCol="icon,INDCPC" GB="impflg"></td>
												<td GH="80" GCol="select,LOCATY">
													<select CommonCombo="LOCATY">
													</select>
												</td>
												<td GH="80" GCol="select,STATUS">
													<select CommonCombo="STATUS">
													</select>
												</td>
												<td GH="80" GCol="check,INDUPA"></td>
												<td GH="80" GCol="check,INDUPK"></td>												
												<td GH="80" GCol="input,MAXCPC" GF="N 5"></td>
												<td GH="80" GCol="input,WIDTHW" GF="N 7,3"></td>
												<td GH="80" GCol="input,HEIGHT" GF="N 20,3"></td>
												<td GH="80" GCol="check,MIXSKU"></td>
												<td GH="80" GCol="check,MIXLOT"></td>
												<td GH="80" GCol="input,CREDAT" GF="C"></td>
												<td GH="80" GCol="text,CRETIM" GF="T"></td>
												<td GH="80" GCol="text,CREUSR"></td>
												<td GH="80" GCol="text,CUSRNM"></td>
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
									<p class="record" GInfoArea="true">0 Record</p>
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
<div class="gridSavePageHolder" id="gridSaveHolder">
	<div class="innerArea">
		<div class="innerInfoBox">
			<p class="innerInfoTxt1"></p>
			<p class="innerInfoTxt2"></p>
		</div>
		<div class="innerGuageBox">
			<div id="innerGuage" class="innerGuage" style="width: 0%;"></div>
			<p id="innerGuageTxt" class="innerGuageTxt">0%</p>
		</div>
	</div>
</div>

<div class="gridSavePageHolder" id="gridExcelLoading">
	<div class="innerArea">
		<div class="innerInfoBox">
			<p class="innerInfoTxt1">엑셀 파일을 내려받는 중입니다.</p>
			<p class="innerInfoTxt2">잠시만 기다려  주세요.</p>
		</div>
		<div class="innerGuageBox">
			<div id="innerGuage" class="innerGuage" style="background-color : #fff;background-image: url(/common/images/login/jqueryui/animated-overlay.gif);"></div>
		</div>
	</div>
</div>

<div class="gridSavePageHolder" id="gridDataSetLoading">
	<div class="innerArea">
		<div class="innerInfoBox">
			<p class="innerInfoTxt1">데이터  취합 중 입니다.</p>
			<p class="innerInfoTxt2">잠시만 기다려  주세요.</p>
		</div>
		<div class="innerGuageBox">
			<div id="innerGuage" class="innerGuage" style="background-color : #fff;background-image: url(/common/images/login/jqueryui/animated-overlay.gif);"></div>
		</div>
	</div>
</div>
<%@ include file="/common/include/bottom.jsp" %>
</body>
</html>