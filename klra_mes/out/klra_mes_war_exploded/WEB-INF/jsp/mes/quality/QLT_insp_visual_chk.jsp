<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
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
                url:"/mes/quality/insp_visual_chk/json/list.data",
                bigdata : false,
	            colorType : true,
                selectRowDeleteType : true
            })
        });

        function searchList(){
        	if(validate.check("searchArea")){
	            var param = inputList.setRangeParam("searchArea");
                param.put("MACHINE", $("#MACHINE").val());

                gridList.gridList({
                    id : "gridList",
                    param : param
                });
        	}
        }

        var lastFocusNum = -1;

        function gridListEventDataBindEnd(gridId, dataLength){
        	if(gridId == "gridList"){
                var list = gridList.getGridData(gridId);

                for (var i = 0; i < list.length; i++) {
                    var defectQty = gridList.getColData(gridId, i, "DEFECT_QTY")
                    var matnr = gridList.getColData(gridId, i, "MATNR")
                    var qltUnit = gridList.getColData(gridId, i, "QLT_UNIT")

                    // 💡 숫자가 아니고 0도 아닐 때 걸러내는 조건문 호출
                    if (isInvalidDefectQty(defectQty)) {
                        alert((i + 1) + "번째 행의 불량수량 포맷이 잘못되었습니다. 현재 입력값: [" + defectQty + "]");

                        // grid.setFocus(i, "DEFECT_QTY");
                        return false;
                    }

                    if(" " == matnr || " " == qltUnit){
                        // alert((i + 1) + "번째 행의 자재코드가 없습니다. 확인해주세요.");

                        return false;
                    }

                    setEaConvQty(
                        gridId,
                        i,
                        list[i].get("MATNR"),
                        list[i].get("QLT_UNIT"),
                        list[i].get("DEFECT_QTY")
                    );
                    removeFrontOnlyModify(gridId, i, "EA_CONV_QTY");
                }
    		}
        }

        /**
         * 불량수량 유효성 체크 함수
         * 조건: 숫자가 아니고, '0'도 아닐 때 true 리턴 (즉, 에러인 상황)
         */
        function isInvalidDefectQty(value) {
            // 1. null, undefined, 공백 처리 방어
            if (value === null || value === undefined) {
                return false;
            }

            // 문자열 좌우 공백 제거
            var qtyStr = String(value).trim();

            // 값이 아예 비어있다면 패스 (필수값이 아니라면)
            if (qtyStr === "") {
                return false;
            }

            // 2. 자바스크립트 정규식 (정수 및 소수점 포맷 체크)
            var isNumeric = /^-?\d+(\.\d+)?$/.test(qtyStr);

            // 💡 조건: 숫자가 "아니면서" 동시에 "0"도 아닐 때 (오류 상태)
            if (!isNumeric && qtyStr !== "0") {
                return true;  // 유효하지 않은 데이터 패턴
            }

            return false; // 정상 데이터 (숫자이거나 또는 0인 경우)
        }

        function gridListEventRowDblclick(gridId, rowNum){
            if(gridId == "gridList"){
            }
        }

        function gridListEventColValueChange(gridId, rowNum, colName, colValue){
        	if(gridId == "gridList"){
                if(colName == "DEFECT_GRP"){
                    var param = new DataMap();
                    param.put("GRP_CD", "DEFECT_DTL_CD");
                    param.put("DETAIL_CD", colValue);

                    var gridBox = gridList.getGridBox(gridId);
                    var $row = gridBox.$box.find("[" + configData.GRID_ROW_NUM + "=" + rowNum + "]");
                    var $select = $row
                        .find("[" + configData.GRID_COL_NAME + "=DEFECT_DTL]")
                        .find("select");

                    gridList.setColValue(gridId, rowNum, "DEFECT_DTL", "");
                    inputList.reloadCombo(
                        $select,
                        configData.INPUT_COMBO,
                        "project.mes.dao.quality.QualityMapper,DefectDetail",
                        true,
                        param
                    );
                } else if(colName == "QLT_UNIT" || colName == "DEFECT_QTY" || colName == "MATNR"){
                    var defectQty = Number(gridList.getColData(gridId, rowNum, "DEFECT_QTY")) || 0;
                    var qltUnit = gridList.getColData(gridId, rowNum, "QLT_UNIT");
                    var matnr = gridList.getColData(gridId, rowNum, "MATNR");

                    if (!matnr) {
                        alert("자재를 먼저 선택해주세요.");

                        if (colName == "DEFECT_QTY") {
                            gridList.setColValue(gridId, rowNum, "DEFECT_QTY", "");
                        }

                        if (colName == "QLT_UNIT") {
                            gridList.setColValue(gridId, rowNum, "QLT_UNIT", "");
                        }

                        gridList.setColValue(gridId, rowNum, "EA_CONV_QTY", "");
                        return;
                    }
                    setEaConvQty(gridId, rowNum, matnr, qltUnit, defectQty);

                }
    		}
        }

        function setEaConvQty(gridId, rowNum, matnr, unit, defectQty){
            var param = new DataMap();
            param.put("P_MATNR", matnr);
            param.put("P_WERKS", "P200");
            param.put("P_BEF_UNIT", unit.toUpperCase());
            param.put("P_AFT_UNIT", "EA");
            param.put("P_QTY", defectQty);


            var json = netUtil.sendData({
                url : "/mes/quality/insp_visual_chk/json/getEaConvQty.data",
                param : param
            });

            if (json.data != undefined) {
                gridList.setColValue(gridId, rowNum, "EA_CONV_QTY", Number(json.data.EA_CONV_QTY));
            }
        }
        
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

            if (gridList.validationCheck("gridList", "data")) {
                if(!commonUtil.msgConfirm(configData.MSG_MASTER_SAVE_CONFIRM)){
                    return;
                }

                var list = gridList.getModifyList("gridList", "A");
                var param = new DataMap();
                param.put("list", list);

                netUtil.send({
                    url : "/mes/quality/json/visualSave.data",
                    param : param,
                    successFunction : "saveSuccessCallBack"
                });
            }
        }
        
        function saveSuccessCallBack(json){
        	if(json.isSuccess == true){
                commonUtil.msgBox(configData.MSG_SYSTEM_SAVEOK);
                searchList();
        	} else {
                commonUtil.msgBox(configData.MSG_EXECUTE_ERROR);
                alert(json.errMsg);
            }
        }
        
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
            } else if(btnName == "Save"){
                saveData();
            }
        }
        
	 	function gridListRowColorChange(gridId, rowNum, rowData){
	 		if(gridId === "gridList"){
				if(rowData.get("CHK_CNT") === "0"){
					return configData.GRID_COLOR_BG_RED_CLASS;
				}
			}
	 	}

        //공통팝업 전
        function searchHelpEventOpenBefore(searchCode, gridType, $inputObj, rowNum){
            var param = new DataMap();
            if(searchCode == "MACH" || searchCode == "MATKY" ){
                param.put("WERKS", "P200");
            }
            return param;
        }

        //공통팝업 후
        function searchHelpEventCloseAfter(searchCode, multyType, selectData, rowData){
            console.log("searchHelpEventCloseAfter 호출 searchCode : " + searchCode);
            var gridId = "gridList"
            if (searchCode == "MATKY") {
                console.log(gridList.getFocusRowNum(gridId), selectData, rowData.map.MATNR_NM);
                gridList.setColValue(gridId, gridList.getFocusRowNum(gridId), "MATNR_NM", rowData.map.MATNR_NM);
            }  else if (searchCode == "LOTRA") {
                gridList.setColValue(gridId, gridList.getFocusRowNum(gridId), "MATNR", rowData.map.MATNR);
                gridList.setColValue(gridId, gridList.getFocusRowNum(gridId), "MATNR_NM", rowData.map.MATNR_NM);
            }
        }

        function removeFrontOnlyModify(gridId, rowNum, colName) {
            var gridBox = gridList.getGridBox(gridId);
            var modifyColMap = gridBox.modifyCols[rowNum];

            if (!modifyColMap || !modifyColMap.containsKey(colName)) {
                return;
            }

            modifyColMap.remove(colName);

            if (modifyColMap.size() == 0) {
                gridBox.modifyCols[rowNum] = null;
                gridBox.modifyRow.remove(rowNum);

                var $rowObj = gridBox.$box.find("[" + configData.GRID_ROW_NUM + "=" + rowNum + "]");
                var tmpViewRowNum = gridBox.getViewRowNum(rowNum) + 1;

                if (commonUtil.isJObjNotEmpty($rowObj)) {
                    $rowObj
                        .find("[" + configData.GRID_COL_TYPE + "=" + configData.GRID_COL_TYPE_ROWNUM + "]")
                        .text(tmpViewRowNum);
                }

                if (gridBox.rowCheckType && gridBox.modifyRowCheck) {
                    gridBox.setRowCheck(rowNum, false);
                }
            }
        }

        //엑셀업로드 후 필요 함수 호출
        function afterExcelUploadStaging() {
            var gridId = "gridList";
            convertExcelComboTextToValue(gridId);
            getMatnrByLot(gridId, "LOT_NO_RA");
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
                <div class="search_wrap ">
					<dl>
                        <dt CL="STD_PROD_DATE">실적일자</dt>
                        <dd><input type="text" name="PROD_DATE" UIInput="B" UIFormat="C M1"/></dd>
                    </dl>
					<dl>
                        <dt CL="STD_MACHINE">생산호기</dt>
                        <dd><input type="text" class="input" id="MACHINE"/></dd>
                    </dl>
<%--                    <dl>--%>
<%--                        <dt CL="STD_MACH_CD">설비</dt>--%>
<%--                        <dd>--%>
<%--                            <input type="text" name="MACH_CD" UIInput="SR,MACH" UIFormat="U"/>--%>
<%--                        </dd>--%>
<%--                    </dl>--%>
                </div>
                <div class="btn_tab">
                    <input type="button" class="btn_more" value="more" onclick="searchMore()"/>
                </div>
            </div>
        </div>
        <div class="search_next_wrap">
            <div class="content_layout tabs">
                <ul class="tab tab_style02">
                    <li><a href="#tab1-1" >불량검사</a></li>
                    <li class="btn_zoom_wrap">
                        <ul>
                            <li><button class="btn btn_bigger"><span>확대</span></button></li>
                        </ul>
                    </li>
                    <dt></dt>
                </ul>
                <div class="table_box section" id="tab1-1">
                    <div class="table_list01">
                        <div class="scroll">
                            <table class="table_b">
                                <tbody id="gridList">
                                    <tr CGRow="true">
                                        <td GH="40" GCol="rowCheck"></td>
                                        <td GH="40" GCol="rownum">1</td>

                                        <td GH="0" GCol="text,SEQ">seq</td><%--숨김--%>
                                        <td GH="40" GCol="input,PROD_MM" style="text-align: center !important">월</td>
                                        <td GH="40" GCol="input,NO" style="text-align: center !important">No</td>
                                        <td GH="100" GCol="input,PRD_DATE" GF="C" validate="required" style="text-align: center !important">생산일자</td>
                                        <td GH="80" GCol="input,PRD_TIME" GF="S 5" style="text-align: center !important">생산시간</td>
                                        <td GH="80" GCol="input,MACHINE" style="text-align: center !important">호기</td>

                                        <td GH="100" GCol="input,INSP_USER" style="text-align: center !important">검사원</td>
                                        <td GH="140" GCol="add,LOT_NO_RA,LOTRA" validate="required" style="text-align: center !important">LOT NO</td>
                                        <td GH="200" GCol="text,MATNR_NM">품목</td>
                                        <%--불량유형--%>
                                        <td GH="180" GCol="select,DEFECT_GRP" validate="required" style="text-align: center !important">
                                            <select class="input" id="DEFECT_GRP_CD" CommonCombo="DEFECT_GRP_CD" style="border: 0px">
                                                <option value="">선택</option>
                                            </select>
                                        </td>
                                        <%--불량세부유형--%>
                                        <td GH="180" GCol="select,DEFECT_DTL" validate="required" style="text-align: center !important">
                                            <select class="input" id="DEFECT_DTL_CD" CommonCombo="DEFECT_DTL_CD" style="border: 0px">
                                                <option value="">선택</option>
                                            </select>
                                        </td>
                                        <%--불량수량--%>
                                        <td GH="100" GCol="input,DEFECT_QTY" GF="N 6">수량</td>
                                        <%--단위--%>
                                        <td GH="140" GCol="select,QLT_UNIT" validate="required" style="text-align: center !important">
                                            <select class="input" id="QLT_UNIT" CommonCombo="QLT_UNIT" style="border: 0px">
                                                <option value="">선택</option>
                                            </select>
                                        </td>
                                        <%--환산수량--%>
                                        <td GH="100" GCol="text,EA_CONV_QTY" GF="N 6">환산수량(EA)</td>
                                        <%--조치사항--%>
                                        <td GH="180" GCol="select,DEFECT_ACT" validate="required" style="text-align: center !important">
                                            <select class="input" id="DEFECT_ACT_CD" CommonCombo="DEFECT_ACT_CD" style="border: 0px">
                                                <option value="">선택</option>
                                            </select>
                                        </td>
                                        <td GH="200" GCol="input,RMK">비고</td>

                                        <td GH="140" GCol="add,MATNR,MATKY" validate="required" style="text-align: center !important">자재코드</td>
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
