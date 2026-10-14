<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Grid default</title>
<%@ include file="/common/include/webdek/head.jsp" %>
<link rel="stylesheet" type="text/css" href="/common/theme/webdek/css/demo_layout.css">
<script type="text/javascript">
	var isAutoUpdating = false;

	$(document).ready(function(){
		gridList.setGrid({
	    	id : "gridList",
	    	url : "/mes/Produce/SCH13/json/datalist.data",
	    	bigdata : false,
	    	pkcol :"WERKS",
	    	colHoldType : true,
	    	colHold : "PRD_REQ_DT,WRK_ORDR_NO,WRK_ORDR_SEQNO,MATNR,MATNR_NM",
	    	colorType : true	    });
		$("#WERKS").val('P100');
	});
	
	/**
	 * 특정 셀의 색상을 변경하는 커스텀 함수
	 * @param gridId  : 그리드 ID
	 * @param rowNum  : 행 번호
	 * @param colName : 컬럼명
	 * @param isChange: 변경 여부 (true면 강조색, false면 원복)
	 */
	 /* function changeCellColor(gridId, rowNum, colName, colValue) {
		 var gridObj = window[gridId];
		    if (!gridObj) return;

		    // 1. 파라미터가 비어있을 경우를 대비한 방어 로직
		    if (!colName) return; 
		    var currentVal = (colValue === undefined || colValue === null) ? gridObj.getColValue(rowNum, colName) : colValue;

		    var sourceVal = "";
		    try {
		        // 2. 원본 데이터 추출 (Map 객체와 일반 Object 모두 대응)
		        if (gridObj.sourceCols) {
		            var rowData = (typeof gridObj.sourceCols.get === 'function') ? gridObj.sourceCols.get(rowNum) : gridObj.sourceCols[rowNum];
		            if (rowData) {
		                sourceVal = (typeof rowData.get === 'function') ? rowData.get(colName) : rowData[colName];
		            }
		        }
		    } catch (e) {
		        sourceVal = ""; 
		    }

		    // 🔍 로그 확인용 (이제 빈 칸이 아니어야 합니다)
		    console.log(`[검사] 컬럼:${colName} | 원본:[${sourceVal}] | 현재:[${currentVal}]`);

		    // 3. DOM 요소 찾기 (속성명은 시스템에 맞게 grid-row-num 등으로 자동 추정)
		    var $gridBox = jQuery("#" + gridId);
		    // 선택자를 최대한 유연하게 잡습니다 (속성 존재 여부로 판단)
		    var $row = $gridBox.find("[" + configData.GRID_ROW_NUM + "='" + rowNum + "']");
		    var $col = $row.find("[" + configData.GRID_COL_NAME + "='" + colName + "']");
		    var $input = $col.find("select, input");

		    // 4. 비교 및 색상 적용
		    var sVal = jQuery.trim(sourceVal);
		    var cVal = jQuery.trim(currentVal);

		    if (sVal !== cVal) {
		        // 다르면 노란색
		        $col.css({"background-color": "#fff9c4", "color": "red", "font-weight": "bold"});
		        $input.css({"background-color": "#fff9c4", "color": "red"});
		    } else {
		        // 같으면 원복
		        $col.css({"background-color": "", "color": "", "font-weight": ""});
		        $input.css({"background-color": "", "color": ""});
		    }
		} */

	function comboEventDataBindeBefore(comboAtt){
		if(comboAtt == "Produce,MACHINE"){
			var param = new DataMap();
			
			param.put("WERKS", 'P100');
		}
		return param;
	}

	// 조회
	function searchList(){
		if(validate.check("searchArea")){
			var param = inputList.setRangeParam("searchArea");

			param.put("P_TYPE","LIST");
			
			gridList.gridList({
		    	id : "gridList",
		    	param : param
		    });
		}
	}
	
	// 저장
	function saveData(){
		if(gridList.getModifyRowCount("gridList") == 0 ){
			commonUtil.msgBox("MASTER_M0545");
			return;
		}
		
		if(!commonUtil.msgConfirm(configData.MSG_MASTER_SAVE_CONFIRM)){
			return;
		}
		
		if(gridList.validationCheck("gridList", "all")){
// 			var list = gridList.getGridData("gridList");
			var modifyList = gridList.getModifyList("gridList", "A");
		
			var param = new DataMap();
			
			param.put("P_TYPE","SAVE");
			param.put("list", modifyList);
		
			var json = netUtil.sendData({
				url : "/mes/Produce/SCH13/json/datalist.data",
				param : param
			});
			if(json){
				if(json.data){
					searchList();
				}
			}
		}
	}

	// 버튼(조회, 저장 등) 클릭
	function commonBtnClick(btnName){
		if(btnName == "Search"){
			var param = new DataMap();
	        param.put("PROGID", "<%= menuId%>");
	        param.put("LGTYPE", "SEARCH");
	        var json = netUtil.sendData({
	            url: "/mes/system/json/saveLog.data",
	            param : param
	        });
			
			searchList();
		}else if(btnName == "Save"){
			saveData();
		}
	}
	
	// 복사
	function gridListEventRowCopyAfter(gridId, rowNum, sourceData) {
		// 컬럼 focus
		gridList.setColFocus(gridId, rowNum, "WRK_ORDR_QTY");
	}
	
	// 조회 완료된 후
	function gridListEventDataBindEnd(gridId, dataLength){
		var list = gridList.getGridData(gridId);
		for(var i=0; i < list.length; i++) {
			if(list[i].get("COMP_YN") != "N"){ // 작업지시상태(N : 대기, I : 진행중, Y : 완료)
				gridList.setRowReadOnly(gridId, i, true, ["WRK_SEQNO","WRK_ORDR_QTY","WRK_ORDR_REMARK","CUTTER","MRLDCK","USE_YN"]); // 작업순서,지시량,작업지시비고,카터,밀롤적치여부,사용여부 수정 안되게
			}
			
			if(list[i].get("USE_YN") != "Y"){ // 사용여부(N : 미사용, Y : 사용)
				gridList.setRowReadOnly(gridId, i, true, ["WRK_SEQNO","WRK_ORDR_QTY","WRK_ORDR_REMARK","CUTTER","MRLDCK"]); // 작업순서,지시량,작업지시비고,카터,밀롤적치여부 수정 안되게
			}	
		}
	}
	
	// 2022-10-18(일요일) 안상현, 사용여부가 "미사용"인 경우 오렌지로 라인 표시
 	function gridListRowColorChange(gridId, rowNum, rowData){
		if(gridId === "gridList" && rowData.get("USE_YN") === "N"){
			return configData.GRID_COLOR_BG_ORANGE_CLASS;
		}
 	}

    function gridListEventColValueChange(gridId, rowNum, colName, colValue) {
        console.log("그리드:", gridId, "행:", rowNum, "컬럼:", colName, "값:", colValue);
        if (isAutoUpdating) return;

        if(gridId === "gridList"){
            if(colName === "CORE_INCH" && colValue === '-'){
                if(commonUtil.msgConfirm('지관사이즈 미선택시 지관마개, 골판지, 포장 여부 초기화 됩니다. 미선택 하시겠습니까?')){
                    isAutoUpdating = true; // [LOCK 시작]

                    // 인자: (gridId, rowNum, colName, value, eventType, viewType)
                    // eventType: false (이벤트 재발생 방지)
                    // viewType: true (화면 값 갱신)
                    // COVER_YN, CORR_YN, PACK_YN 값을 '-'로 변경
                    gridList.setColValue(gridId, rowNum, "COVER_YN", "-");
                    gridList.setColValue(gridId, rowNum, "CORR_YN",  "-");
                    gridList.setColValue(gridId, rowNum, "PACK_YN",  "-");

                    isAutoUpdating = false; // [LOCK 해제]
                }
            }
            else if(colName === "COVER_YN" || colName === "CORR_YN" || colName === "PACK_YN"){
            	var coreInch = gridList.getColData(gridId, rowNum, "CORE_INCH");

            	if(coreInch == "-"){
                    alert("지관사이즈(인치) 먼저 선택해주세요");

                    isAutoUpdating = true; // [LOCK 시작]
                    gridList.setColValue(gridId, rowNum, colName,  "-");
                    isAutoUpdating = false; // [LOCK 해제]

                    return;
                }
            }
		} 
    }
</script>
</head>
<body>
<%@ include file="/common/include/webdek/layout.jsp" %>
<!-- content -->
<div class="content_wrap">
	<div class="content_inner">
		<%@ include file="/common/include/webdek/title.jsp" %>
		<div class="content_serch" id="searchArea">
			<div class="btn_wrap">
				<div class="fl_l">
				</div>
				<div class="fl_r">
					<input type="button" id="button-0-1" CB="Search SEARCH BTN_SEARCH" />
					<input type="button" id="button-0-2" CB="Save SAVE BTN_SAVE" />
				</div>
			</div>
			<div class="search_inner">
				<div class="search_wrap">
				  	<dl>
						<dt CL="STD_PLANT">플랜트</dt>
						<dd>							
							<input type="text" class="input" id="WERKS" name="WERKS"  readonly="readonly"/>
						</dd>
					</dl>
					<dl>
						<dt CL="STD_PRD_REQ_DT">생성요청일자</dt>
                        <dd>
                        	<input type="text" name="PRD_REQ_DT" UIInput="B" UIFORMAT="C M1"/>
                        </dd>
					</dl>
					<dl>
						<dt CL="STD_MATNR">자재코드</dt>
						<dd>
							<input type="text" id="MATNR" name="MATNR" UIInput="SR,MATKY" UIFormat="U"/>
						</dd>
					</dl>
					<dl>
						<dt CL="STD_MACHINE">생산호기</dt>
						<dd>
							<select class="input" name="MACHINE" Combo="Produce,MACHINE">
								<option value="">All</option>
							</select>
						</dd>
					</dl>
					<dl>
						<dt CL="STD_ORDR_GEN_DT">작업지시일자</dt>
                        <dd>
                        	<input type="text" name="ORDR_GEN_DT" UIInput="B" UIFORMAT="C"/>
                        </dd>
					</dl>
					<dl>
						<dt CL="STD_AUFNR">생산오더번호</dt>
                        <dd>
                        	<input type="text" name="ORDER_NO" UIInput="SR" UIFORMAT="U" />
                        </dd>
					</dl>
					<dl>
						<dt>밀롤/슬리터 구분</dt>
						<dd>
							<select class="input" name="SLITT">
								<option value="">All</option>
								<option value="M">밀롤</option>
								<option value="S">슬리터</option>
							</select>
						</dd>
					</dl>
				</div>
				<div class="btn_tab">
					<input type="button" class="btn_more" value="more" onclick="searchMore()"/>
				</div>
			</div>
		</div>
        <div class="search_next_wrap">
			<div class="content_layout tabs">
				<ul class="tab tab_style02">
					<li><a href="#tab1-1"><span CL="STD_GRD_SCH13">일반</span></a></li>
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
										<td GH="100" GCol="text,PRD_REQ_DT" GF="C" style="text-align:center;">생산요청일</td>
										<td GH="150" GCol="text,WRK_ORDR_NO" style="text-align: center;">작업지시번호</td>
										<td GH="80" GCol="text,WRK_ORDR_SEQNO" style="text-align:center;">지시순번</td>
										<td GH="140" GCol="text,MATNR" style="text-align: center;">자재코드</td>
										<td GH="320" GCol="text,MATNR_NM" style="text-align: center;">자재명</td>
										<td GH="100" GCol="text,WRK_ORDR_QTY" GF="N 10,3">지시량</td>
										<td GH="80" GCol="text,ORDR_UNIT" style="text-align: center;">지시량단위</td>
										
										<td GH="100" GCol="text,WERKS" style="text-align:center;">플랜트</td>
										<td GH="100" GCol="text,ORDR_GEN_DT" GF="C" style="text-align:center;">작업지시일자</td>
										<td GH="100" GCol="text,TOT_WGT" GF="N 10,3">총중량</td>
										<td GH="80 총중량단위" GCol="text,TWUNIT" style="text-align: center;">총중량단위</td>
										
										<td GH="80" GCol="input,WRK_SEQNO" style="text-align: center;">작업순서</td>
										<td GH="250" GCol="input,WRK_ORDR_REMARK">작업지시비고</td>
										<td GH="80" GCol="input,CUTTER" style="text-align: center;">카터</td>
										<td GH="120" GCol="select,MRLDCK">	<!-- 밀롤창고적치여부 -->
											<select class="input" CommonCombo="LDCK" style="text-align: center;">
											</select>
										</td>
										<td GH="100" GCol="select,USE_YN">
											<select class="input" CommonCombo="USE_YN" style="text-align: center;">	<!-- 사용여부 -->
												<option value="Y">사용</option>
												<option value="N">미사용</option>
											</select>
										</td>
										<td GH="100" GCol="text,MACHINE" style="text-align: center;">생산호기</td>
										<td GH="100" GCol="text,ORDER_NO" style="text-align: center;">오더번호</td>
										<td GH="100" GCol="text,PRE_ORDER_NO" style="text-align: center;">이전오더번호</td>
										<td GH='100' GCol='text,JRLOT_NO' style="text-align: center;">점보롤 Lot No</td>
										<td GH="100" GCol="text,PCODE" style="text-align: center;">지종코드</td>
										<td GH="100" GCol="text,BS_WGT" style="text-align: center;">평량</td>
										<td GH="100" GCol="text,MWIDTH" style="text-align: center;">M/R지폭</td>
										<td GH="100" GCol="text,MROLLCNT" GF="N 10">M/R권치수</td>
										<td GH="80" GCol="text,MROLLUNIT" style="text-align: center;">MR권치수단위</td>
										
										<td GH="100" GCol="text,MBRGEW" GF="N 10">M/R중량</td>
										<td GH="80 M/R중량단위" GCol="text,MWUNIT" style="text-align: center;">MR중량단위</td>
										
										<td GH="100" GCol="text,JRCNT" style="text-align: center;">J/R 개수</td>
										<td GH="100" GCol="text,REWD_SPEC" style="text-align: center;">Rewinder규격</td>
										<td GH="100" GCol="text,MWIDTH_SLITER" style="text-align: center;">슬리터 M/R지폭</td>
										<td GH="100" GCol="text,MRCNT" style="text-align: center;">M/R폭수</td>
										<td GH="100" GCol="text,ZZATT1" GF="N 10,1" style="text-align: center;"">팔레트당연수</td>
										<td GH="100" GCol="text,RUNIT" style="text-align: center;">팔레트당연수 단위</td>
										
										<td GH="100" GCol="text,ZZATT2" GF="N 10" style="text-align: center;">속당매수</td>
										<td GH="100" GCol="text,EAUNIT" style="text-align: center;">속당매수 단위</td>
										
										<td GH="100" GCol="text,WLEN" style="text-align: center;">가로길이</td>
										<td GH="100" GCol="text,VLEN" style="text-align: center;">세로길이</td>
										<!-- 202209026 여한진 컬럼 추가 -->
										<td GH='80' GCol='text,ORDER_DIV' style='text-align:center;'>오더유형</td>
										<td GH='120' GCol='text,ORDER_DIV_NM' style="text-align: center;">오더유형(명)</td>
										<td GH="150" GCol="text,KUNNR" style="text-align: center;">거래처</td>
										<td GH="150" GCol="text,PRD_STR_DTM" style="text-align: center;">생산시작시간</td>
										<td GH="100" GCol="text,VBELN" style="text-align: center;">주문문서번호</td>
										<td GH="100" GCol="text,POSNR" style="text-align: center;">오더Item번호</td>
										<td GH="100" GCol="text,VDATU" GF="C" style="text-align:center;">납품요청일</td>
										<td GH="100" GCol="text,SHEET" style="text-align: center;">판지구분자</td>
										<td GH="100" GCol="text,SLITER_SET" style="text-align: center;">슬리터구분</td>
										<td GH="100" GCol="text,COMP_YN_NM" style="text-align:center;">작업지시상태 (N:대기 I:작업중 Y:완료)</td>
                                        <td GH="100" GCol="select,CORE_INCH">
											<select class="input" CommonCombo="CORE_INCH" style="text-align: center;">	<!-- 지관사이즈(인치) -->
												<option value="-">-</option>
												<option value="3">3</option>
												<option value="6">6</option>
												<option value="12">12</option>
											</select>
										</td>
                                        <td GH="100" GCol="select,COVER_YN">
											<select class="input" CommonCombo="COVER_YN" style="text-align: center;">	<!-- 지관마개여부 -->
												<option value="-">-</option>
												<option value="사용">사용</option>
												<option value="미사용">미사용</option>
											</select>
										</td>
                                        <td GH="100" GCol="select,CORR_YN">
											<select class="input" CommonCombo="CORR_YN" style="text-align: center;">	<!-- 골판지여부 -->
												<option value="-">-</option>
												<option value="사용">사용</option>
												<option value="미사용">미사용</option>
											</select>
										</td>
                                        <td GH="100" GCol="select,PACK_YN">
											<select class="input" CommonCombo="PACK_YN" style="text-align: center;">	<!-- 포장여부 -->
												<option value="-">-</option>
												<option value="사용">사용</option>
												<option value="미사용">미사용</option>
											</select>
										</td>
										<td GH="300" GCol="text,PLN_ORDR_REMARK" GF="S 1000">계획오더비고</td>
										<td GH="150" GCol="text,REGDATE" style="text-align: center;">등록일시</td>
										<!-- <td GH="100" GCol="text,REGNM" style="text-align: center;">등록자</td> -->
										<td GH="150" GCol="text,UPDDATE" style="text-align: center;">수정일시</td>
										<!-- <td GH="100" GCol="text,UPDNM" style="text-align: center;">수정자</td> -->										
									</tr>
								</tbody>
							</table>
						</div>
					</div>
					<jsp:include page="/WEB-INF/jsp/common/commonBtnAuth.jsp">
						<jsp:param name="authCd" value="1" />
						<jsp:param name="showAuthCd" value="1,2,3,5,7,9,10" />
					</jsp:include>			
				</div>
			</div>
		</div>
	</div>
</div>
<!-- // content -->
<%@ include file="/common/include/webdek/bottom.jsp" %>
</body>
</html>