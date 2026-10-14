<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<style>
    .table_list01 tr.custom-td td.editabled{color: rgb(113, 139, 164); !important;}
    .table_list01 tr.custom-td.focusRow td.editabled{color: rgba(206, 66, 118, 0.71);font-weight: bolder; !important;}
    .grid-center {
        text-align: center !important;
    }
    .spec-out {
        background-color: rgba(213,84,84,0.68) !important;
        color: #ffffff !important;
    }
</style>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <title>Grid default</title>
    <%@ include file="/common/include/webdek/head.jsp" %>
    <link rel="stylesheet" type="text/css" href="/common/theme/webdek/css/demo_layout.css">
    <script type="text/javascript" src="${pageContext.request.contextPath}/mes/js/common_qlt.js"></script>
    <script type="text/javascript">
        var lastFocusNum = 0;
        let colNum = 0

        $(document).ready(function(){
            gridList.setGrid({
                id : "gridList",
                url : "/mes/quality/qlt03/json/list.data",
                bigdata : false,
                colorType : true,
                selectRowDeleteType : true
            })
        });

        // HEADER 조회
        function searchList(){
        	if(validate.check("searchArea")){
	            var param = inputList.setRangeParam("searchArea");
                param.put("MATNR_NM", $("#MATNR_NM").val());

	            gridList.gridList({
	                id : "gridList",
	                param : param
	            });
        	}
        }

        // GRID 조회 시 데이터 적용 후 
        const gridListEventDataBindEnd = (gridId, dataLength) => {
            console.log("gridListEventDataBindEnd 호출");
            if (gridId === "gridList") {
                paintAllSpecCells(gridId);
            }
            // var list = gridList.getGridData(gridId);
            // for(var i = 0; i < list.length; i++) {
            //     gridList.setRowReadOnly(gridId, i, true
            //         , ["MSRM_DATE", "TIME_HOUR", "TIME_MIN", "LOT_NO", "MATNR", "MACH_CD", "MACH_NM", "MACH_CD_TRA", "MACH_NM_TRA"]);
            // }
        }

        // 그리드 컬럼 값 변경 시
        function gridListEventColValueChange(gridId, rowNum, colName, colValue){
            console.log("gridListEventColValueChange 호출 " + " rowNum : " + rowNum + " / colName : " + colName + " / colValue : " + colValue);
            if (colName === "MATNR") {
                fetchSpecByMatnr(gridId, rowNum, colValue);
                return;
            }
            paintSpecCell(gridId, rowNum, colName);
            // var rowData = gridList.getSelectData("gridList");
            // for(var i = 0; i < rowData.length; i++){
            // 	if(i >= 1){
            // 		if(rowData[i].get("MATNR") != rowData[i-1].get("MATNR")){
            // 			alert("서로 다른 자재코드는 합지롤검사를 진행할 수 없습니다.");
            //
            // 			// gridList.setRowState : 행 상태 변경
            // 			gridList.setRowState(gridId, configData.GRID_ROW_STATE_READ, rowNum);
            //
            // 			// gridList.setRowCheck : 지정 행의 행 선택 지정
            // 			gridList.setRowCheck(gridId, rowNum, false);
            // 		}
            // 	}
            // }
        }

        // 저장(추가, 수정, 삭제)
        // 선택된 row 만 추가, 수정 가능
        function saveData(){
            var json = netUtil.sendData({
                module : 'mes',
                command : 'SYSTEMCHECK',
                sendType : 'map'
            });

            if(json.data.USE_YN == 'Y'){
                alert('시스템 점검 중입니다. 1 ~ 5분 동안 잠시만 기다려 주세요.');
                return;
            }

            var rowData = gridList.getModifyData("gridList", "A");

            //수정된 데이터
            if(gridList.getModifyRowCount("gridList") == 0){
                commonUtil.msgBox("SYSTEM_SAVEEMPTY");
                return;
            }

            for(var i = 0; i < rowData.length; i++){
                //MSRM_DATE
                var rowNum = rowData[i].get(configData.GRID_ROW_NUM);

                var dateVal = rowData[i].get("MSRM_DATE");
                var hourVal = rowData[i].get("TIME_HOUR");
                var minVal = rowData[i].get("TIME_MIN");

                var formattedDateTime = formatDate(dateVal, hourVal, minVal);

                rowData[i].put("MSRM_DATE", formattedDateTime);
                gridList.setColValue("gridList", rowNum, "MSRM_DATE", formattedDateTime);
            }

            if (gridList.validationCheck("gridList", "data")) {
                if(!commonUtil.msgConfirm(configData.MSG_MASTER_SAVE_CONFIRM)){
                    return;
                }

                var param = new DataMap();
                param.put("rowData", rowData);
                param.put("WERKS", "P200");
                param.put("INSP_ITEM_GRP_CD", $("#gridList").data("insp-item-grp-cd"));

                netUtil.send({
                    url : "/mes/quality/json/save.data",
                    param : param,
                    successFunction : "saveSuccessCallBack"
                });
            }
        }
        
        function saveSuccessCallBack(json){
       		if(json.isSuccess){
                commonUtil.msgBox(configData.MSG_SYSTEM_SAVEOK);
                jQuery("#warning-bar").fadeOut();
                searchList();
            } else {
                commonUtil.msgBox("저장 오류 발생 : " + json.errMsg);
            }
        }

        //버튼클릭
        function commonBtnClick(btnName){
            //조회
            if(btnName == "Search"){
                var param = new DataMap();
                param.put("PROGID", "<%= menuId%>");
                param.put("LGTYPE", "SEARCH");
                var json = netUtil.sendData({
                    url: "/mes/system/json/saveLog.data",
                    param : param
                });

                jQuery("#warning-bar").fadeOut();
                searchList();
            //저장
            } else if(btnName == "Save"){
                saveData();
            }
        }

        // 2022-08-29(월요일) 안상현, LOT번호 검색조건 추가
    	const LOT = () => {
    		page.linkPopOpen("/common/SEARCH_LOT.page", "", "width=1500, height=600");
    	}

    	// 2022-08-29(월요일) 안상현, 개별바코드 검색조건 추가
    	const BARCODE = () => {
    		page.linkPopOpen("/mes/wrk/WRK23_POP01.page", "", "height=600,width=850");
    	}

        // afterSaveStaging(staging table insert 이후 화면단 자재체크 로직
        function validateMatnrAfterSave (){
            console.log("validateMatnrAfterSave 호출");

            // gridList 객체 내부의 $box(그리드 컨테이너)에서 rowNum 속성을 가진 요소들을 가져옵니다.
            var gridId = gridList.excelUpGridId;
            if(gridId == undefined){
                return;
            }
            var $rowList = gridList.gridMap.map[gridId].$box.find("[" + configData.GRID_ROW_NUM + "]");
            var gridBox = gridList.gridMap.map[gridId]; // 현재 그리드 객체 참조
            var colName = colName || "MATNR"; // 기본값 MATNR
            var errorCount = 0; // 에러 개수를 담을 변수

            $rowList.each(function(index, findElement) {
                var $row = jQuery(findElement);
                var rowNum = $row.attr(configData.GRID_ROW_NUM);

                // 해당 행에서 특정 컬럼(td)을 찾습니다.
                var $col = $row.find('td[' + configData.GRID_COL_NAME + '=' + colName + ']');

                // 실제 데이터 값을 가져옵니다.
                var colVal = gridBox.getColValue(rowNum, colName);

                // [체크 로직]: 자재번호가 비어있거나 유효하지 않을 때 색상 표시
                // 기존 코드와 반대로, '오류'가 있는 경우에 색을 칠하도록 수정했습니다.
                if (colVal === " " || colVal === undefined) {
                    $row.find('td').css("background-color", "rgba(213,84,84,0.14)");
                    $col.css("background-color", "rgba(213,84,84,0.68)"); // 연한 빨간색
                    $col.css("color", "#ffffff");            // 글자색 흰색 (가독성)

                    errorCount++;
                } else {
                    // 정상 데이터라면 색상 초기화 (재검증 대비)
                    $row.find('td').css("background-color", ""); // 정상일 땐 초기화
                    $col.css("background-color", "");
                    $col.css("color", "");
                }
            });

            var $warningBar = jQuery("#warning-bar");

            if (errorCount > 0) {
                // 빨간 배경이 하나라도 있으면 경고바 유지/표시
                $warningBar.fadeIn();
                alert("엑셀 업로드 및 자재 검증이 완료되었습니다.");
            } else {
                // 화면에 빨간 배경이 하나도 없으면(errorCount가 0이면) 경고바 숨기기
                $warningBar.fadeOut();
            }
        }

        /**
         * @param {String} msrmDate  - "MMDD" 형식 (ex: "0318")
         * @param {String} hour      - "HH" 형식 (ex: "24" 또는 "16")
         * @param {String} min       - "MI" 형식 (ex: "40")
         * @returns {String}         - "YYYY-MM-DD HH:MI:SS" 형식
         * 24시로 넘어오는 날짜형식 변형
         */
        function formatDate(msrmDate, hour, min) {
            if (!msrmDate) return "";

            // 1. 숫자만 추출 및 파싱
            var rawDate = msrmDate.replace(/[^0-9]/g, "");
            rawDate = rawDate.slice(-4);
            var mm = parseInt(rawDate.substring(0, 2), 10) - 1; // JS 월은 0부터 시작
            var dd = parseInt(rawDate.substring(2, 4), 10);

            var hhStr = String(hour || "").trim();
            var miStr = String(min || "").trim();

            var hh = hhStr === "" ? 0 : parseInt(hhStr, 10);
            var mi = miStr === "" ? 0 : parseInt(miStr, 10);
            var ss = 0;

            // 2. Date 객체 생성 (24시 입력 시 자동으로 다음 날로 계산됨)
            var calcDate = new Date(new Date().getFullYear(), mm, dd, hh, mi, ss);

            // 3. YYYY-MM-DD HH:MI:SS 포맷으로 변환
            var yyyy = calcDate.getFullYear();
            var MM = (calcDate.getMonth() + 1).toString().padStart(2, '0');
            var DD = calcDate.getDate().toString().padStart(2, '0');
            var HH = calcDate.getHours().toString().padStart(2, '0');
            var MI = calcDate.getMinutes().toString().padStart(2, '0');
            var SS = "00";

            return yyyy + "-" + MM + "-" + DD + " " + HH + ":" + MI + ":" + SS;
        }

        function normalizeMsrmDate(msrmDate) {
            if (!msrmDate) {
                return "";
            }

            var rawDate = String(msrmDate).replace(/[^0-9]/g, "");

            if (rawDate.length >= 8) {
                return rawDate.substring(0, 8);
            }

            return rawDate;
        }

        function comboEventDataBindeBefore(comboAtt){
            var param = new DataMap();

            if(comboAtt == "project.mes.dao.quality.QualityMapper,MACHINE,RA"){
                param.put("WERKS", "P200");
                param.put('PROC_CD', comboAtt[2]);
            } else if(comboAtt == "project.mes.dao.quality.QualityMapper,MACHINE,AA"){
                param.put("WERKS", "P200");
                param.put('PROC_CD', comboAtt[2]);
            }
            return param;
        }

        //공통팝업 전
        function searchHelpEventOpenBefore(searchCode, gridType, $inputObj, rowNum){
            var param = new DataMap();
            if(searchCode == "LOTAA"){
                param.put("WERKS", "P200");
                param.put("LOT_NO", $inputObj[0].value);
            }
            return param;
        }

        //공통팝업 후
        function searchHelpEventCloseAfter(searchCode, multyType, selectData, rowData){
            console.log("searchHelpEventCloseAfter 호출 searchCode : " + searchCode);
            var gridId = "gridList"
            if (searchCode == "MATKY") {
                // console.log(gridList.getFocusRowNum(gridId), selectData, rowData.map.MATNR_NM);
                var rowNum = gridList.getFocusRowNum(gridId);
                gridList.setColValue(gridId, rowNum, "MATNR_NM", rowData.map.MATNR_NM);
                validateMatnrAfterSave();
                fetchSpecByMatnr(gridId, rowNum, rowData.map.MATNR);
            } else if (searchCode == "LOTAA") {
                gridList.setColValue(gridId, gridList.getFocusRowNum(gridId), "MACH_CD", rowData.map.MACH_CD);
                gridList.setColValue(gridId, gridList.getFocusRowNum(gridId), "MACH_NM", rowData.map.MACH_NM);
                gridList.setColValue(gridId, gridList.getFocusRowNum(gridId), "MACH_CD_TRA", rowData.map.MACH_CD_TRA);
                gridList.setColValue(gridId, gridList.getFocusRowNum(gridId), "MACH_NM_TRA", rowData.map.MACH_NM_TRA);
            }
        }

        function gridListEventInputColFocus(gridId,  rowNum,  colName){
            console.log("gridListEventInputColFocus 호출 " + " gridId : " + gridId + " / rowNum : " + rowNum + " / colName : " + colName);

            // //검사 날짜
            // if(colName == "MSRM_DATE"){
            //     var val = gridList.getColData(gridId, rowNum, colName);
            //     var finalResult = formatDate(val, "00", "00");
            //
            //     gridList.setColValue(gridId, rowNum, colName, finalResult);
            // }
        }

        //엑셀업로드 후 필요 함수 호출
        function afterExcelUploadStaging() {
            convertExcelComboTextToValue("gridList");

            validateMatnrAfterSave();
            loadSpecForAllRows("gridList");
        }

        // const gridListEventRowAddBefore = (gridId, rowNum, beforeData) => {
        //     // getFocusRowNum : 포커스가 위치한 행 번호
        //     const row = gridList.getFocusRowNum("gridList")
        //     if(row === -1){
        //         return false
        //     }
        // }

        // 행 추가 후에 실행
        const gridListEventRowAddAfter = (gridId, rowNum) => {
            gridList.setColValue(gridId, rowNum, "FNL_JDGM", "PASS")
        }

        //     	// 2022-10-16(일요일) 안상현, 합지롤검사 기준값이 등록되지 않았을 경우, 그리드 빨간색으로 표시
// 	 	function gridListRowColorChange(gridId, rowNum, rowData){
// 	 		if(gridId === "gridList"){
// 				if(rowData.get("CHK_CNT") === "0"){
// 					return configData.GRID_COLOR_BG_RED_CLASS;
// 				}
// 			}
// 	 	}
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
                <div class="search_wrap ">
                    <dl>
						<dt CL="STD_PLANT">플랜트</dt>
						<dd>
							<input type="text" class="input" id="WERKS" name="WERKS" validate="required" UIInput="S,PLANT" UIFormat="U" value="P200"/>
						</dd>
					</dl>
                    <dl>
                        <dt CL="STD_PRFM_DT">생산일자</dt>
                        <dd><input type="text" name="W001.PRFM_DT" UIInput="B" UIFORMAT="C M1"/></dd>
                    </dl>
                    <dl>
                        <dt CL="STD_MACH_CD">설비코드</dt>
                        <dd>
                            <select class="input" name="MACH_CD" CommonCombo="MACH_CD_AA">
                                <option value="">All</option>
                            </select>
                        </dd>
                    </dl>
                    <dl>
                        <dt CL="STD_MATNR_NM">자재명</dt>
                        <dd><input type="text" class="input" id="MATNR_NM"/></dd>
                    </dl>
                    <dl>
						<dt CL="STD_LOT_NO">합지 LOT 번호</dt>
						<dd><input type="text" class="input" name="LOT_NO" UIInput="S"/></dd>
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
                    <li><a href="#tab1-1"><span CL="STD_PRD_PRFM">리스트</span></a></li>
                    <li>
                        <div id="warning-bar" style="display: none; margin-bottom: 10px; padding: 10px; border: 1px solid #d55454; background-color: #fff5f5; color: #d55454; font-weight: bold; text-align: center;">
                            <span class="blink-text">⚠️ 자재번호(MATNR)가 입력되지 않은 항목이 있습니다. 붉은색 행을 확인하세요!</span>
                        </div>
                    </li>
                    <li class="btn_zoom_wrap">
                        <ul>
                            <li><button class="btn btn_bigger"><span>확대</span></button></li>
                        </ul>
                    </li>
                </ul>
                <div class="table_box section" id="tab1-1">
                    <div class="table_list01">
                        <div class="table_thead tableHeader" style="margin-left: 0px;">
                            <table>
                                <colgroup>
                                    <col width="40px"/>
                                    <col width="40px"/>

                                    <col width="0px"/><%--처리순번 숨김--%>
                                    <col width="80px"/>
                                    <col width="80px"/>
                                    <col width="80px"/>
                                    <col width="80px"/>
                                    <col width="80px"/>

                                    <col width="0px"/><%--생산호기코드 숨김--%>
                                    <col width="80px"/>
                                    <col width="0px"/><%--적용호기코드 숨김--%>
                                    <col width="80px"/>
                                    <col width="80px"/>
                                    <col width="120px"/>
                                    <col width="120px"/>
                                    <col width="200px"/>

                                    <col width="80px"/>
                                    <col width="80px"/>
                                    <col width="80px"/>
                                    <col width="80px"/>
                                    <col width="80px"/>
                                    <col width="80px"/>
                                    <col width="80px"/>
                                    <col width="80px"/>
                                    <col width="80px"/>
                                    <col width="80px"/>
                                    <col width="80px"/>

                                    <col width="80px"/>
                                    <col width="80px"/>
                                    <col width="80px"/>

                                    <col width="100px"/>
                                    <col width="80px"/>
                                </colgroup>
                                <thead>
                                    <tr>
                                        <th rowspan="2" GH="40" GCol="rowCheck">
                                            <input type="checkbox" class="GEditBack" onclick="gridList.checkAll('gridList', this.checked);">
                                        </th>
                                        <th rowspan="2">번호</th>
                                        <th colspan="6" style="background-color: #DDEBF7;">담당</th>
                                        <th colspan="8" style="background-color: #d3cdde;">제품사양</th>
                                        <th colspan="11" style="background-color: #FFF2CC;">측정값</th>
                                        <th colspan="3" style="background-color: #E2EFDA;">육안검사</th>
                                        <th rowspan="2">최종판정</th>
                                        <th rowspan="2">비고</th>
                                    </tr>
                                    <tr>
                                        <th>처리순번</th><%--숨김--%>
                                        <th>날짜</th>
                                        <th>시</th>
                                        <th>분</th>
                                        <th>검사자</th>
                                        <th>반</th>

                                        <th>생산호기_코드</th><%--숨김--%>
                                        <th>생산호기</th>
                                        <th>적용호기_코드</th><%--숨김--%>
                                        <th>적용호기</th>
                                        <th>지폭</th>
                                        <th>합지 LOTNO</th>
                                        <th>자재코드</th>
                                        <th>품명</th>

                                        <th>평량</th>
                                        <th>백색도</th>
                                        <th>파열강도</th>
                                        <th>MD</th>
                                        <th>CD</th>
                                        <th>wet-cd</th>
                                        <th>흡수도</th>
                                        <th>신장율</th>
                                        <th>두께</th>
                                        <th>물풀림성</th>
                                        <th>투기도</th>

                                        <th>핀홀상태</th>
                                        <th>반점상태</th>
                                        <th>형광검출</th>
                                    </tr>
                                </thead>
                            </table>
                        </div>
                        <div class="scroll" style="height: calc(100% - 77px)">
                            <table class="table_b">
                                <tbody id="gridList" data-insp-item-grp-cd="H1">
                                    <tr CGRow="true" class="custom-td">
                                        <td GCol="rowCheck"></td>
                                        <td GCol="rownum">1</td>

                                        <td GCol="text,PRC_SEQNO">처리순번</td><%--숨김--%>
                                        <td GCol="add,MSRM_DATE" validate="required" GF="C" class="grid-center">날짜</td>
                                        <td GCol="add,TIME_HOUR" GF="N 2" class="grid-center">시</td>
                                        <td GCol="add,TIME_MIN" GF="N 2" class="grid-center">분</td>
                                        <td GCol="input,MSRM_NM" class="grid-center">검사자</td>
                                        <td GCol="input,WRK_CLASS" GF="N 1" class="grid-center">반</td>

                                        <td GCol="text,MACH_CD">생산설비_코드</td><%--숨김--%>
                                        <td GCol="text,MACH_NM" class="grid-center">생산설비</td>
                                        <td GCol="text,MACH_CD_TRA">적용설비_코드</td><%--숨김--%>
                                        <td GCol="text,MACH_NM_TRA" class="grid-center">적용설비</td>
                                        <td GCol="input,WIDTH" GF="N 6" class="grid-center">지폭</td>
                                        <td GCol="add,LOT_NO,LOTAA" validate="required" class="grid-center">원지 LOTNO</td>
                                        <td GCol="add,MATNR,MATKY" validate="required" class="grid-center">자재코드</td>
                                        <td GCol="text,MATNR_NM" class="grid-center">품명</td>

<%--                                        <td GCol="input,BS_WGT" GF="N 6,2" class="grid-center"></td>--%>
<%--                                        <td GCol="input,WHITE" GF="N 6,1" class="grid-center"></td>--%>
<%--                                        <td GCol="input,BURST" GF="N 6,0" class="grid-center"></td>--%>
<%--                                        <td GCol="input,MD" GF="N 6,0" class="grid-center"></td>--%>
<%--                                        <td GCol="input,CD" GF="N 6,0" class="grid-center"></td>--%>
<%--                                        <td GCol="input,WET_CD" GF="N 6,0" class="grid-center"></td>--%>
<%--                                        <td GCol="input,ABSORB" GF="N 6,0" class="grid-center"></td>--%>
<%--                                        <td GCol="input,ELONG" GF="N 6,2" class="grid-center"></td>--%>
<%--                                        <td GCol="input,THICK" GF="N 6,3" class="grid-center"></td>--%>
<%--                                        <td GCol="input,WET_SOLVE" GF="N 6,2" class="grid-center"></td>--%>
<%--                                        <td GCol="input,AIR_PERM" GF="N 6,2" class="grid-center"></td>--%>

                                        <td GCol="input,BS_WGT"
                                            class="grid-center spec-check"
                                            data-spec-col="BS_WGT"
                                            data-spec-min-col="BS_WGT_MIN"
                                            data-spec-max-col="BS_WGT_MAX"
                                            GF="N 6,2">평량</td>

                                        <td GCol="input,WHITE"
                                            class="grid-center spec-check"
                                            data-spec-col="WHITE"
                                            data-spec-min-col="WHITE_MIN"
                                            data-spec-max-col="WHITE_MAX"
                                            GF="N 6,1">백색도</td>

                                        <td GCol="input,BURST"
                                            class="grid-center spec-check"
                                            data-spec-col="BURST"
                                            data-spec-min-col="BURST_MIN"
                                            data-spec-max-col="BURST_MAX"
                                            GF="N 6">파열강도</td>

                                        <td GCol="input,MD"
                                            class="grid-center spec-check"
                                            data-spec-col="MD"
                                            data-spec-min-col="MD_MIN"
                                            data-spec-max-col="MD_MAX"
                                            GF="N 6">MD</td>

                                        <td GCol="input,CD"
                                            class="grid-center spec-check"
                                            data-spec-col="CD"
                                            data-spec-min-col="CD_MIN"
                                            data-spec-max-col="CD_MAX"
                                            GF="N 6">CD</td>

                                        <td GCol="input,WET_CD"
                                            class="grid-center spec-check"
                                            data-spec-col="WET_CD"
                                            data-spec-min-col="WET_CD_MIN"
                                            data-spec-max-col="WET_CD_MAX"
                                            GF="N 6">wet-cd</td>

                                        <td GCol="input,ABSORB"
                                            class="grid-center spec-check"
                                            data-spec-col="ABSORB"
                                            data-spec-min-col="ABSORB_MIN"
                                            data-spec-max-col="ABSORB_MAX"
                                            GF="N 6">흡수도</td>

                                        <td GCol="input,ELONG"
                                            class="grid-center spec-check"
                                            data-spec-col="ELONG"
                                            data-spec-min-col="ELONG_MIN"
                                            data-spec-max-col="ELONG_MAX"
                                            GF="N 6,2">신장률</td>

                                        <td GCol="input,THICK"
                                            class="grid-center spec-check"
                                            data-spec-col="THICK"
                                            data-spec-min-col="THICK_MIN"
                                            data-spec-max-col="THICK_MAX"
                                            GF="N 6,3">두께</td>

                                        <td GCol="input,WET_SOLVE"
                                            class="grid-center spec-check"
                                            data-spec-col="WET_SOLVE"
                                            data-spec-min-col="WET_SOLVE_MIN"
                                            data-spec-max-col="WET_SOLVE_MAX"
                                            GF="N 6,2">물풀림성</td>

                                        <td GCol="input,AIR_PERM"
                                            class="grid-center spec-check"
                                            data-spec-col="AIR_PERM"
                                            data-spec-min-col="AIR_PERM_MIN"
                                            data-spec-max-col="AIR_PERM_MAX"
                                            GF="N 6,2">공기투과도</td>


                                        <td GCol="input,PINHOLE" class="grid-center">핀홀상태</td>
                                        <td GCol="input,SPOT" class="grid-center">반점상태</td>
                                        <td GCol="input,FLUORO" class="grid-center">형광검출</td>

                                        <td GCol="select,FNL_JDGM" class="grid-center">                       <%-- 최종판정 --%>
                                            <select class="input" id="FNL_JDGM" CommonCombo="FNL_JDGM" style="border: 0px"></select>
                                        </td>
                                        <td GCol="input,RMK" class="grid-center">비고</td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
                    </div>
                    <jsp:include page="/WEB-INF/jsp/common/commonBtnAuth.jsp">
                    	<jsp:param name="authCd" value="1"/>
                    	<jsp:param name="showAuthCd" value="1,2,3,4,5,6,9,10,11"/>
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
