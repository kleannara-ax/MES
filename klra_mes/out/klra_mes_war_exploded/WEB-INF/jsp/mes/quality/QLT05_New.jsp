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
	    let hNum = 0
		let flag = 1

		let listType = "LIST-A"
	    let gridType = "gridList_A"

	    let colNum = 0

	    $(document).ready(function(){
	    	// 화장지
	        gridList.setGrid({
	            id : "gridList_A",
	            url : "/mes/quality/qlt05/json/list.data",
	            bigdata : false,
	            // colHoldType : true,
	            // colHold : "PRC_DIV_NM, WERKS",
	            // totalCols : ["WRK_ORDR_QTY"],
	            colorType : true,
                selectRowDeleteType : true
	        })

	        // 생리대
	        gridList.setGrid({
	            id : "gridList_B",
	            url : "/mes/Quality/QLT05/json/datalist.data",
	            bigdata : false,
	            colHoldType : true,
	            colHold : "PRC_DIV_NM, WERKS",
	            colorType : true
	        })

	        // 기저귀
	        gridList.setGrid({
	            id : "gridList_C",
	            url : "/mes/Quality/QLT05/json/datalist.data",
	            bigdata : false,
	            colHoldType : true,
	            colHold : "PRC_DIV_NM, WERKS",
	            colorType : true
	        })

	        // 검사항목
	        gridList.setGrid({
	            id : "gridList2",
	            url:"/mes/Quality/QLT05/json/datalist.data",
	            bigdata:false,
	            colHoldType : true,
	            colHold : "BIG_CAT_NM,MID_CAT_NM,INSP_ITEM_GRP_CD,INSP_ITEM_CD,INSP_ITEM_NM",
	            colGroupCols : "BIG_CAT_NM,MID_CAT_NM"
	        })

            flagSet(1, 'P200');

	        document.getElementById('FNL_JDGM').selectedIndex = '1';
	    });

	    // const flagSet = (플래그,플랜트) => {
	    // 	flag = 플래그
	    // 	$("#WERKS").val(플랜트)
	    //
	    // 	리스트 = flag === 1 ? "LIST-A" : (flag === 2 ? "LIST-B" : "LIST-C")
	    // 	그리드 = flag === 1 ? "gridList_A" : (flag === 2 ? "gridList_B" : "gridList_C")
	    // }

        const flagSet = (flagNum, plant) => {
            // 1. 전역 변수 및 검색 조건 세팅
            flag = flagNum;
            $("#WERKS").val(plant);

            // 2. 탭 번호에 따른 그리드/리스트 ID 매핑
            listType = flag === 1 ? "LIST-A" : (flag === 2 ? "LIST-B" : "LIST-C");
            gridType = flag === 1 ? "gridList_A" : (flag === 2 ? "gridList_B" : "gridList_C");

            // 3. 화장지 탭(1번)일 때 하단 그리드 숨기기 로직
            if (flag === 1) {
                $(".bottom_layout").hide(); // 하단 영역 숨김
                $(".top_layout").css("height", "calc(100% - 77px)"); // 상단 영역 전체 확장
                $('#sIND_BCD').hide();
                // 만약 상단 영역 내부 컨테이너 높이도 조절해야 한다면 추가
                // $(".top_layout .table_box").css("height", "calc(100vh - 200px)");
            } else {
                // 생리대(2번), 기저귀(3번) 탭일 때는 원상복구
                $(".bottom_layout").show();
                $(".top_layout").css("height", ""); // 기존 CSS에 정의된 높이로 복원
                $('#sIND_BCD').show();
                // $(".top_layout .table_box").css("height", "auto");
            }

            // 4. 리사이즈 (GridList 엔진에 맞춘 방식)
            // setTimeout(function() {
            //     if (window.gridList) {
            //         gridList.resize(gridType); // 상단
            //         if (flag !== 1) gridList.resize("gridList2"); // 하단
            //     }
            // }, 200);
        }

        const searchList = () => {
            if (validate.check("searchArea")) {
                gridList.resetGrid("gridList2");

                var param = inputList.setRangeParam("searchArea");

                param.put("P_TYPE", listType);

                gridList.gridList({
                    id: gridType,
                    param: param
                });
            }
        }

        // 2022-09-07(수요일) 안상현, 김성하 총괄님 지시로 생리대, 기저귀 탭 분리
        function searchSubList(num){
        	const MATNR = gridList.getColData(gridType, num, "MATNR");
        	const WERKS = gridList.getColData(gridType, num, "WERKS");
        	const MSRM_DATE = gridList.getColData(gridType, num, "MSRM_DATE");
        	const PRC_SEQNO = gridList.getColData(gridType, num,"PRC_SEQNO");

			var param = new DataMap();

            param.put("P_TYPE", "SUB_LIST");
            param.put("MATNR", MATNR);
    		param.put("WERKS", WERKS);
    		param.put("MSRM_DATE", MSRM_DATE);
    		param.put("PRC_SEQNO", PRC_SEQNO);

            gridList.gridList({
                id : "gridList2",
                param : param
            });

            hNum = num
        }

        // 2022-09-07(수요일) 안상현, 김성하 총괄님 지시로 기저귀, 생리대 탭 분리
        // 그리드 조회 시 데이터 적용 완료된 후 실행
        const gridListEventDataBindEnd = (gridId, dataLength) => {
            console.log("gridListEventDataBindEnd 호출");
        	if(gridId === "gridList2"){
    			const list = gridList.getGridData(gridId);

    			for(let i = 0; i < dataLength; i++){
    				const INPT_TYP = list[i].get("INPT_TYP");	// 입력타입(숫자, 문자, 문자열)
    				const MSRM_ACC = list[i].get("MSRM_ACC");	// 측정차수

    				// INPT_TYP : 공통코드 - 숫자, 문자, 문자열
    				if(INPT_TYP == "문자") gridList.setRowReadOnly(gridId, i, true, ["RST_VAL", "RST_TXT", "MSRM_INSERT"])
    				else if(INPT_TYP == "숫자"){
    					gridList.setRowReadOnly(gridId, i, true, ["RST_SEL", "RST_TXT"])

    					// 2022-09-28(수요일) 안상현, 품질팀 요청사항으로 측정차수가 2이상인 검사항목은 숫자를 입력하지 않는다.
    					if(MSRM_ACC >= 2){
    						gridList.setRowReadOnly(gridId, i, true, ["RST_VAL"])
    					}
    				}
    				else gridList.setRowReadOnly(gridId, i, true, ["RST_SEL", "RST_VAL", "MSRM_INSERT"])
    			}
    		} else if(gridId === "gridList_A"){
                paintAllSpecCells(gridId);

                var list = gridList.getGridData(gridId);
                for(var i = 0; i < list.length; i++) {
                    //todo : 컬럼명 완제품검사서 기준으로 다시 넣기
                    // gridList.setRowReadOnly(gridId, i, true
                    //     , ["MSRM_DATE", "TIME_HOUR", "TIME_MIN", "LOT_NO", "MATNR", "MACH_CD", "MACH_NM", "MACH_CD_TRA", "MACH_NM_TRA"]);
                }
            }
        }

        // 행 더블 클릭
        function gridListEventRowDblclick(gridId, rowNum){
        	if(gridId !== "gridList2" & gridId !== "gridList_A"){
        		searchSubList(rowNum)

        		colNum = rowNum
        	}
        }

     	// 팝업 로직 처리 후 조회
    	const linkPopCloseEvent = () => {
    		searchList();
    	}

        function alertNotice(gridId, rowNum, colName, colValue){
        	if(gridId == "gridList2"){
        		if(colName == "STD_VAL"){
        			if(colValue == ""){
        				return "<img src='/common/theme/webdek/images/icon_alert.png' height='20px' width='auto'/>";
        			}
        		}
        	}
        }

        // 그리드 컬럼 값 변경 시
        function gridListEventColValueChange(gridId, rowNum, colName, colValue){
            console.log("gridListEventColValueChange 호출 " + " rowNum : " + rowNum + " / colName : " + colName + " / colValue : " + colValue);
        	if(gridId == "gridList_A"){
                if (colName === "MATNR") {
                    fetchSpecByMatnr(gridId, rowNum, colValue);
                    return;
                }
                paintSpecCell(gridId, rowNum, colName);
				// var rowData = gridList.getSelectData("gridList_A");
    			//
    			// for(var i = 0; i < rowData.length; i++){
        		// 	if(i >= 1){
	        	// 		if(rowData[i].get("MATNR") != rowData[i-1].get("MATNR")){
	        	// 			alert("서로 다른 자재코드는 완제품검사를 진행할 수 없습니다.");
	        	// 			gridList.setRowState(gridId, configData.GRID_ROW_STATE_READ, rowNum);
	        	// 			gridList.setRowCheck(gridId, rowNum, false);
	        	// 			return;
	        	// 		}
        		// 	}
        		// }
    		} else if(gridId == "gridList_B"){
				var rowData = gridList.getSelectData("gridList_B");

    			for(var i = 0; i < rowData.length; i++){
        			if(i >= 1){
	        			if(rowData[i].get("MATNR") != rowData[i-1].get("MATNR")){
	        				alert("서로 다른 자재코드는 완제품검사를 진행할 수 없습니다.");
	        				gridList.setRowState(gridId, configData.GRID_ROW_STATE_READ, rowNum);
	        				gridList.setRowCheck(gridId, rowNum, false);
	        				return;
	        			}
        			}
        		}
    		} else if(gridId == "gridList2"){
    			var INPT_MTD = gridList.getColData("gridList2", rowNum, "INPT_MTD");
    			var flag = true;
    			var value_length = colValue.substring(colValue.indexOf('.') + 1);

    			if(isNaN(colValue)){
    				flag = false;
    			}

    			var Upp_val = gridList.getColData("gridList2", rowNum, "UPP_VAL");
    			var Low_val = gridList.getColData("gridList2", rowNum, "LOW_VAL");

    			if(colName == "RST_VAL"){
    				if(flag == true){
    					if(colValue <= Number(Upp_val) && colValue >= Number(Low_val)){
        					gridList.setColValue(gridId, rowNum, "FIT_YN", "Y");
        				} else{
        					gridList.setColValue(gridId, rowNum, "FIT_YN", "N");
        				}

    					if(colValue.indexOf('.') > 0){
 							if(INPT_MTD == "9"){
   								if(value_length > 0){
   		   	  						gridList.setColValue(gridId, rowNum, colName, "");
   		  							alert("소수점을 입력할 수 없습니다.");
   	   	  						}
   							} else if(INPT_MTD == "9.9"){
   		  						if(value_length > 9){
   		  							gridList.setColValue(gridId, rowNum, colName, "");
   		  							alert("소숫점 1자리까지 입력할 수 있습니다.");
   		  						}
   							}
   							if(INPT_MTD == "9.99"){
	   	  						if(value_length > 99){
	   	  							gridList.setColValue(gridId, rowNum, colName, "");
	   	  							alert("소숫점 2자리까지 입력할 수 있습니다.");
	   	  						}
   							} else if(INPT_MTD == "9.999"){
	   	  						if(value_length > 999){
	   	  							gridList.setColValue(gridId, rowNum, colName, "");
	   	  							alert("소숫점 3자리까지 입력할 수 있습니다.");
	   	  						}
   							}
   	  					}
    				} else{
   						gridList.setColValue(gridId, rowNum, colName, "");
   						alert("숫자만 입력할 수 있습니다.");
   	   				}
    			}

    			if(colName == "RST_SEL"){
    				if(INPT_MTD == "PASS/FAIL"){
        				if(colValue == "PASS"){
        					gridList.setColValue(gridId, rowNum, "FIT_YN", "Y");
        				} else{
        					gridList.setColValue(gridId, rowNum, "FIT_YN", "N");
        				}
   	        		}
   				}
    		}
        }

        // grid에 button 속성을 준 column에 button을 클릭한 경우
        const gridListEventColBtnClick = (gridId, rowNum, colName) => {
    		if(gridId == "gridList2"){
    			if(colName == "MSRM_INSERT"){

    				const INSP_YN = gridList.getColData(gridType, hNum, "INSP_YN");
    				const WERKS = gridList.getColData(gridType, hNum, "WERKS");
    				const MATNR = gridList.getColData(gridType, hNum, "MATNR");
    				const INSP_ITEM_GRP_CD = gridList.getColData(gridType, hNum, "INSP_ITEM_GRP_CD");
    				const MSRM_DATE = gridList.getColData(gridType, hNum, "MSRM_DATE");
    				const PRC_SEQNO = gridList.getColData(gridType, hNum, "PRC_SEQNO");

    				const rowData = gridList.getRowData("gridList2", rowNum);

    				// MSRM_ACC : 측정차수
    				if(Number(rowData.get("MSRM_ACC")) < 2){
    					alert("추가 측정 결과값을 등록할 수 없습니다.")
    					return
    				}

    				// INSP_YN : 검사여부 - N, Y
    				if(INSP_YN == "N"){
    					alert("검사 완료 후 추가로 결과값을 등록할 수 있습니다.")
    					return
    				}

    				const INSP_ITEM_CD = gridList.getColData("gridList2", rowNum, "INSP_ITEM_CD");
    				const MSRM_ACC = gridList.getColData("gridList2", rowNum, "MSRM_ACC");

    				var param = new DataMap();

    				param.put("WERKS", WERKS);
    				param.put("MATNR", MATNR);
    				param.put("INSP_ITEM_GRP_CD", INSP_ITEM_GRP_CD);
    				param.put("MSRM_DATE", MSRM_DATE);
    				param.put("PRC_SEQNO", PRC_SEQNO);
    				param.put("INSP_ITEM_CD", INSP_ITEM_CD);
    				param.put("MSRM_ACC", MSRM_ACC);

    				param.put("colNum", colNum)

    				page.linkPopOpen("/mes/quality/QLT01_POP02.page", param, "height=500,width=900");
    			}
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

            console.log("saveDate gridType : " + gridType);
            if (gridType == "gridList_A") {
                var rowData = gridList.getModifyData(gridType, "A");

                //수정된 데이터
                if(gridList.getModifyRowCount(gridType) == 0){
                    commonUtil.msgBox("SYSTEM_SAVEEMPTY");
                    return;
                }

                for(var i = 0; i < rowData.length; i++){
                    //MSRM_DATE
                    var targetRow = rowData[i];
                    var map = targetRow.map;
                    var formattedDate = formatDate(map.MSRM_DATE, map.TIME_HOUR == " "? "0" : map.TIME_HOUR, map.TIME_MIN == " "? "0" : map.TIME_MIN);

                    rowData[i].put("MSRM_DATE", formattedDate);
                }

                if (gridList.validationCheck(gridType, "data")) {
                    if(!commonUtil.msgConfirm(configData.MSG_MASTER_SAVE_CONFIRM)){
                        return;
                    }

                    var param = new DataMap();
                    param.put("rowData", rowData);
                    param.put("WERKS", "P200");
                    param.put("INSP_ITEM_GRP_CD", "H3"); // 완제품 검사

                    netUtil.send({
                        url : "/mes/quality/json/save.data",
                        param : param,
                        successFunction : "saveSuccessCallBack"
                    });
                }
            } else {
                if(gridList.validationCheck("gridList2", "all")){

                    var rowData = gridList.getSelectData(gridType);

                    // HEADER 선택
                    if(rowData.length == 0){
                        alert("자재를 선택하세요.");
                        return;
                    }

                    for(var i = 0; i < rowData.length; i++){
                        if(i >= 1){
                            if(rowData[i].get("MATNR") != rowData[i-1].get("MATNR")){
                                alert("서로 다른 자재코드는 완제품검사를 진행할 수 없습니다.");
                                return;
                            }
                        }

                        // 2022-10-16(일요일) 안상현, 완제품검사 기준값이 등록되지 않았을 경우 validation 체크
                        if(rowData[i].get("CHK_CNT") === "0"){
                            alert("완제품 검사(물성) 기준값이 등록되지 않은 행이 존재합니다. \n기준값을 등록하세요.")
                            return
                        }

                        if(rowData[i].get('CHK_PP_YN') == 'N'){
                            alert('생산팀에서 확인요청이 진행하지 않은 제품입니다.생산팀에서 확인하세요.');
                            return;
                        }

                        if(rowData[i].get('STCK_STA') == '70'){
                            alert('이미 WMS에서 출고된 항목이므로 처리할 수 없습니다.');
                            return;
                        }

                        // 2022-08-23(화요일) 안상현, 완제품 입고 요청된 자재에 대해서는 완제품 검사 불가능 하도록 수정
                        if(rowData[i].get("STCK_STA") === "80"){
                            alert((i+1)+"번째 행은 완제품 입고 요청된 자재입니다.");
                            return;
                        }
                    }

                    // gridList.getGridDataCount : 데이터 행 수
                    var subListCnt = gridList.getGridDataCount("gridList2");
                    var list = gridList.getGridData("gridList2");

                    for (var i = 0; i < subListCnt; i++){
                        var NECSY_YN = gridList.getColData("gridList2", i, "NECSY_YN");
                        var Status = gridList.getRowStatus("gridList2", i);
                        var Std_val = gridList.getColData("gridList2", i, "STD_VAL");
                        var Fit_yn = gridList.getColData("gridList2", i, "FIT_YN");
                        var inpt_typ = gridList.getColData("gridList2", i, "INPT_TYP"); // 입력타입(숫자, 문자, 문자열)
                        var std_sel = gridList.getColData("gridList2", i, "STD_SEL");	// 기준값
                        var rstval = gridList.getColData('gridList2', i, 'RST_VAL');	// 측정값
                        var rstTxt = gridList.getColData('gridList2', i, 'RST_TXT');	// 결과값(문자열)
                        var rstsel = gridList.getColData('gridList2', i, 'RST_SEL');	// 판정

                        // 2022-09-28(수요일) 안상현, 품질팀 요청사항으로 측정차수가 2이상인 검사항목은 숫자를 입력하지 않는다.
                        const MSRM_ACC = gridList.getColData("gridList2", i, "MSRM_ACC"); // 측정차수

                        let INSP_STD_1 = gridList.getColData("gridList2", i, "INSP_STD_1");
                        let INSP_STD_2 = gridList.getColData("gridList2", i, "INSP_STD_2");

                        if(NECSY_YN == "Y"){
                            if (inpt_typ == "숫자"){
                                if(MSRM_ACC < 2){
                                    if(!Std_val || Std_val == "0"){
                                        return alert("해당 품목에 등록된 기준값이 없습니다.");
                                    }
                                    if(rstval == ''){
                                        alert("필수 측정항목을 입력하지 않았습니다.");
                                        return;
                                    }
                                }
                            } else if (inpt_typ == "문자"){
                                if(std_sel == ""){
                                    alert("해당 품목에 등록된 기준선택값이 없습니다.");
                                    return;
                                }
                                if(rstsel == ''){
                                    alert("필수 측정항목을 입력하지 않았습니다.");
                                    return;
                                }
                            } else if (inpt_typ == "문자열"){
                                if(!(INSP_STD_1 || INSP_STD_2)){
                                    return alert("검사기준(1)과 검사기준(2) 둘다 없습니다.");
                                }
                                if(rstTxt == ''){
                                    alert("필수 측정항목을 입력하지 않았습니다.");
                                    return;
                                }
                            }

                            if(Fit_yn == ""){
                                alert("입력된 항목에 대해 적합여부를 선택하지 않으셨습니다.");
                                return;
                            }
                        }
                    }

                    if(!commonUtil.msgConfirm(configData.MSG_MASTER_SAVE_CONFIRM)){
                        return;
                    }

                    var param = new DataMap();

                    param.put("head", rowData);
                    param.put("P_TYPE", "SUB_SAVE");
                    param.put("list", list);
                    param.put("INSP_ITEM_GRP_CD", "H3");
                    // SMPL_AMT : 시료량
                    param.put("SMPL_AMT", $("#SMPL_AMT").val());

                    // FNL_JDGM : 최종판정
                    param.put("FNL_JDGM", $("#FNL_JDGM").val());

                    // 2022-11-01(화요일) 안상현, 선택된 처리순번
                    param.put("AN_SEQNO",gridList.getColData(gridType, colNum, "PRC_SEQNO"))

                    netUtil.send({
                        url : "/mes/Quality/QLT05/json/datalist.data",
                        param : param,
                        successFunction : "saveSuccessCallBack"
                    });
                }
            }
        }

        function saveSuccessCallBack(json){
            if (gridType = "gridList_A") {
                if(json.isSuccess){
                    commonUtil.msgBox(configData.MSG_SYSTEM_SAVEOK);
                    jQuery("#warning-bar").fadeOut();
                    searchList();
                } else {
                    commonUtil.msgBox("저장 오류 발생 : " + json.errMsg);
                }
            } else {
                if(json.P_SUCCESS == 'Y'){
                    var message = '';

                    if(json.DOC_NO1 != ''){
                        //WMS에 완제품 출고요청
                        var ifid = "MES_IF_402";

                        var json2 = netUtil.sendData({
                            url : "/common/api/json/"+ifid+"/send.data",
                            param : 'DOC_NO=' + json.DOC_NO1
                        });

                        if(json2.result == 'SUCCESS'){
                        }else{
                            message = 'WMS 완제품출고취소요청 ->' + json2.result + '\n';
                        }
                    }
                    if(json.DOC_NO2 != ''){
                        //WMS에 완제품 출고요청
                        var ifid = "MES_IF_906";

                        var json2 = netUtil.sendData({
                            url : "/common/api/json/"+ifid+"/send.data",
                            param : 'DOC_NO=' + json.DOC_NO2
                        });

                        if(json2.result == 'SUCCESS'){
                        }else{
                            message = 'WMS 검사 결과 ->' + json2.result + '\n';
                        }
                    }

                    if(message == ''){
                        commonUtil.msgBox(configData.MSG_SYSTEM_SAVEOK);
                    }else{
                        alert(message);
                    }
                    gridList.resetGrid("gridList2");
                    $("#SMPL_AMT").val('');
                    searchList();

                }
            }
        }

        // 버튼 클릭(조회, 저장 등등)
		function commonBtnClick(btnName){

            if(btnName == "Search"){
                var param = new DataMap();
                param.put("PROGID", "<%= menuId%>");
                param.put("LGTYPE", "SEARCH");
                var json = netUtil.sendData({
                    url: "/mes/system/json/saveLog.data",
                    param : param
                });

                //todo : 확인필요
                jQuery("#warning-bar").fadeOut();
                searchList();
            } else if(btnName == "Save"){
                saveData();
            }

            else if(btnName == "Workwrhs"){
            	if(count > 0){
           			var url = "/mes/quality/QLT06_POP01.page";

           			var rowData = gridList.getSelectData(gridType);

   	            	if(rowData.length > 1){
   	            		alert("하나의 항목만 선택가능합니다.");
   	            		return;
   	            	}else if(rowData.length == 0){
   	            		alert("공정창고조회할 항목을 선택하시기 바랍니다.");
   	            		return;
   	            	}

   					page.linkPopOpen(url, rowData, "height=950,width=1300");
            	}
            }
        }

     	// 2022-08-25(목요일) 안상현, LOT번호 검색조건 추가
		const LOT = () => {
    		page.linkPopOpen("/common/SEARCH_LOT.page", "", "width=1500, height=600");
    	}

		// 2022-10-16(일요일) 안상현, 완제품 검사 기준값이 등록되지 않았을 경우, 그리드 빨간색으로 표시
	 	function gridListRowColorChange(gridId, rowNum, rowData){
	 		if(gridId !== "gridList2"){
				if(rowData.get("CHK_CNT") === "0"){
					return configData.GRID_COLOR_BG_RED_CLASS;
				}
			}
	 	}

        // afterSaveStaging(staging table insert 이후 화면단 자재체크 로직
        function validateMatnrAfterSave (){
            // console.log("validateMatnrAfterSave 호출");
            //
            // // gridList 객체 내부의 $box(그리드 컨테이너)에서 rowNum 속성을 가진 요소들을 가져옵니다.
            // var gridId = gridList.excelUpGridId;
            // var $rowList = gridList.gridMap.map[gridId].$box.find("[" + configData.GRID_ROW_NUM + "]");
            // var gridBox = gridList.gridMap.map[gridId]; // 현재 그리드 객체 참조
            // var colName = colName || "MATNR"; // 기본값 MATNR
            // var errorCount = 0; // 에러 개수를 담을 변수
            //
            // $rowList.each(function(index, findElement) {
            //     var $row = jQuery(findElement);
            //     var rowNum = $row.attr(configData.GRID_ROW_NUM);
            //
            //     // 해당 행에서 특정 컬럼(td)을 찾습니다.
            //     var $col = $row.find('td[' + configData.GRID_COL_NAME + '=' + colName + ']');
            //
            //     // 실제 데이터 값을 가져옵니다.
            //     var colVal = gridBox.getColValue(rowNum, colName);
            //
            //     // [체크 로직]: 자재번호가 비어있거나 유효하지 않을 때 색상 표시
            //     // 기존 코드와 반대로, '오류'가 있는 경우에 색을 칠하도록 수정했습니다.
            //     if (colVal === " " || colVal === undefined) {
            //         $row.find('td').css("background-color", "rgba(213,84,84,0.14)");
            //         $col.css("background-color", "rgba(213,84,84,0.68)"); // 연한 빨간색
            //         $col.css("color", "#ffffff");            // 글자색 흰색 (가독성)
            //
            //         errorCount++;
            //     } else {
            //         // 정상 데이터라면 색상 초기화 (재검증 대비)
            //         $row.find('td').css("background-color", ""); // 정상일 땐 초기화
            //         $col.css("background-color", "");
            //         $col.css("color", "");
            //     }
            // });
            //
            // var $warningBar = jQuery("#warning-bar");
            //
            // if (errorCount > 0) {
            //     // 빨간 배경이 하나라도 있으면 경고바 유지/표시
            //     $warningBar.fadeIn();
            //     alert("엑셀 업로드 및 자재 검증이 완료되었습니다.");
            // } else {
            //     // 화면에 빨간 배경이 하나도 없으면(errorCount가 0이면) 경고바 숨기기
            //     $warningBar.fadeOut();
            // }
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

            var hh = parseInt(hour || 0, 10);
            var mi = parseInt(min || 0, 10);
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
            if(searchCode == "LOTAA" || searchCode == "LOTRA"){
                param.put("WERKS", "P200");
                param.put("LOT_NO", $inputObj[0].value);
            }
            return param;
        }

        //공통팝업 후
        function searchHelpEventCloseAfter(searchCode, multyType, selectData, rowData){
            console.log("searchHelpEventCloseAfter 호출 searchCode : " + searchCode);
            var gridId = "gridList_A"
            var rowNum = gridList.getFocusRowNum(gridId);
            if (searchCode == "MATKY") {
                // console.log(gridList.getFocusRowNum(gridId), selectData, rowData.map.MATNR_NM);
                gridList.setColValue(gridId, rowNum, "MATNR_NM", rowData.map.MATNR_NM);
                validateMatnrAfterSave();
                fetchSpecByMatnr(gridId, rowNum, rowData.map.MATNR);
            } else if (searchCode == "LOTAA") {
                // gridList.setColValue(gridId, gridList.getFocusRowNum(gridId), "MACH_CD", rowData.map.MACH_CD_TRA);
                // gridList.setColValue(gridId, gridList.getFocusRowNum(gridId), "MACH_NM", rowData.map.MACH_NM_TRA);
            } else if (searchCode == "LOTRA") {
                gridList.setColValue(gridId, gridList.getFocusRowNum(gridId), "MATNR", rowData.map.MATNR);
                gridList.setColValue(gridId, gridList.getFocusRowNum(gridId), "MATNR_NM", rowData.map.MATNR_NM);
                gridList.setColValue(gridId, gridList.getFocusRowNum(gridId), "MACH_NM", rowData.map.MACH_NM);
                validateMatnrAfterSave();
                fetchSpecByMatnr(gridId, rowNum, rowData.map.MATNR);
            }
        }

        //엑셀업로드 후 필요 함수 호출
        function afterExcelUploadStaging() {
            var gridId = "gridList_A";
            convertExcelComboTextToValue(gridId);
            validateMatnrAfterSave();
            loadSpecForAllRows(gridId);
            getMatnrByLot(gridId, "LOT_NO_RA");
        }

        function gridExcelDownloadEventBefore(){
            setDefaultFnlJdgmForExcelOnly("gridList_A");
            return new DataMap();
        }

        function setDefaultFnlJdgmForExcelOnly(gridId) {
            var gridBox = gridList.gridMap.get(gridId);

            if (!gridBox) {
                return;
            }

            var colIndex = gridBox.cols.indexOf("FNL_JDGM");

            if (colIndex < 0) {
                return;
            }

            for (var i = 0; i < gridBox.viewDataList.length; i++) {
                var rowNum = gridBox.viewDataList[i];
                var rowData = gridBox.data[rowNum].split(configData.DATA_COL_SEPARATOR);

                if (rowData[colIndex] == null || rowData[colIndex] == undefined || rowData[colIndex] == "" || rowData[colIndex] == " ") {
                    var $select = $("#" + gridId)
                        .find("tr[GRowNum='" + rowNum + "']")
                        .find("select[commonCombo='FNL_JDGM']");

                    var selectedValue = $select.val();

                    if (selectedValue != null && selectedValue != undefined && selectedValue != "") {
                        rowData[colIndex] = selectedValue;
                        gridBox.data[rowNum] = rowData.join(configData.DATA_COL_SEPARATOR);
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
                    <input type="button" id="button-0-4" CB="Workwrhs SEARCH BTN_WORKWRHS" />
                    <!-- <input type="button" id="button-0-3" CB="Finprostatus FINPROSTATUS BTN_FINPROSTATUS" /> -->
                    <input type="button" id="button-0-2" CB="Save SAVE BTN_SAVE" />
                </div>
            </div>
            <div class="search_inner">
                <div class="search_wrap ">
                    <dl>
						<dt CL="STD_PLANT">플랜트</dt>
						<dd>
							<input type="text" class="input" id="WERKS" name="WERKS" UIFormat="U" value="P200" readonly/>
						</dd>
					</dl>
                    <dl>
                        <dt CL="STD_PRFM_DT">실적일자</dt>
                        <dd><input type="text" name="W001.PRFM_DT" UIInput="B" UIFormat="C M1"/></dd>
                    </dl>
                    <dl>
                        <dt CL="STD_MATNR">자재코드</dt>
                        <dd><input type="text" name="W001.MATNR" UIInput="SR,MATKY" UIFormat="U"/></dd>
                    </dl>
                    <dl>
                        <dt CL="STD_MACH_CD">설비</dt>
                        <dd>
                            <input type="text" name="W001.MACH_CD" UIInput="SR,MACH" UIFormat="U"/>
                        </dd>
                    </dl>
                    <dl>
						<dt CL="STD_LOT_NO">LOT번호</dt>
						<dd style="font-size: 0">
							<input type="text" class="input" id="LOT_NO" name="W001.LOT_NO" UIInput="SR"/>
							<!-- <button type="button" class="btn btn_search" onclick="LOT()">
								<span>search</span>
							</button> -->
						</dd>
					</dl>
                    <dl id="sIND_BCD">
                        <dt CL="STD_IND_BCD">개별바코드</dt>
                        <dd>
                            <input type="text" class="input" name="IND_BCD" UIInput="SR,INDBCD" UIFormat="U" maxlength="15"/>
                        </dd>
                    </dl>
                </div>
                <div class="btn_tab">
                    <input type="button" class="btn_more" value="more" onclick="searchMore()"/>
                </div>
            </div>
        </div>
        <div class="search_next_wrap">
            <div class="content_layout tabs top_layout">
                <ul class="tab tab_style02">
                    <li><a href="#tab1-1" onclick="flagSet(1,`P200`);">화장지</a></li>
                    <!-- 2022-09-07(수요일) 안상현, 김성하 총괄님 지시로 생리대, 기저귀 탭 분리 -->
                    <li><a href="#tab1-2" onclick="flagSet(2,`P300`);">생리대</a></li>
                    <li><a href="#tab1-3" onclick="flagSet(3,`P500`);">기저귀</a></li>
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
                                    <%--2--%>
                                    <col width="40px"/>
                                    <col width="40px"/>

                                    <%--6--%>
                                    <col width="0px"/><%--처리순번 숨김--%>
                                    <col width="80px"/>
                                    <col width="80px"/>
                                    <col width="80px"/>
                                    <col width="80px"/>
                                    <col width="80px"/>

                                    <%--6--%>
                                    <col width="0px"/><%--생산호기_코드 숨김--%>
                                    <col width="80px"/>
                                    <col width="100px"/>
                                    <col width="100px"/>
                                    <col width="120px"/>
                                    <col width="280px"/>

                                    <%--13--%>
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

                                    <%--7--%>
                                    <col width="80px"/>
                                    <col width="80px"/>
                                    <col width="80px"/>
                                    <col width="80px"/>
                                    <col width="80px"/>
                                    <col width="80px"/>
                                    <col width="80px"/>

                                    <%--2--%>
                                    <col width="100px"/>
                                    <col width="80px"/>
                                </colgroup>
                                <thead>
                                    <tr>
                                        <th rowspan="2" GH="40" GCol="rowCheck">
                                            <input type="checkbox" class="GEditBack" onclick="gridList.checkAll('gridList_A', this.checked);">
                                        </th>
                                        <th rowspan="2">번호</th>
                                        <th colspan="6" style="background-color: #DDEBF7;">담당</th>
                                        <th colspan="6" style="background-color: #d3cdde;">제품사양</th>
                                        <th colspan="13" style="background-color: #FFF2CC;">측정값</th>
                                        <th colspan="7" style="background-color: #E2EFDA;">육안검사</th>
                                        <th rowspan="2">최종판정</th>
                                        <th rowspan="2">비고</th>
                                    </tr>
                                    <tr>
                                        <%--6--%>
                                        <th>처리순번</th>
                                        <th>날짜</th>
                                        <th>시</th>
                                        <th>분</th>
                                        <th>검사자</th>
                                        <th>반</th>

                                        <%--6--%>
                                        <th>생산호기_코드</th><%--숨김--%>
                                        <th>생산호기</th>
                                        <th>합지 LOT_NO</th>
                                        <th>가공 LOT_NO</th>
                                        <th>자재코드</th>
                                        <th>품명</th>

                                        <%--13--%>
                                        <th>겹수</th>
                                        <th>롤</th>
                                        <th>지폭</th>
                                        <th>절취간격</th>
                                        <th>직경</th>
                                        <th>감축직경</th><%--타이트니스?--%>
                                        <th>감축율</th><%--타이트?--%>
                                        <th>길이/매수</th>
                                        <th>평량</th>
                                        <th>파강</th>
                                        <th>절취강도</th>
                                        <th>두께평균</th>
                                        <th>테일실강도</th>

                                        <%--7--%>
                                        <th>절취선상태</th>
                                        <th>테일겹분리</th>
                                        <th>이물질혼입</th>
                                        <th>엠보싱상태</th>
                                        <th>포장상태</th>
                                        <th>냄새</th>
                                        <th>형광검출</th>
                                    </tr>
                                </thead>
                            </table>
                        </div>
                        <div class="scroll" style="height: calc(100% - 77px)">
                            <table class="table_b">
                                <tbody id="gridList_A" data-insp-item-grp-cd="H3">
                                    <tr CGRow="true" class="custom-td">
                                        <td GCol="rowCheck"></td>
                                        <td GCol="rownum">1</td>

                                        <td GCol="text,PRC_SEQNO">처리순번</td><%--숨김--%>
                                        <td GCol="add,MSRM_DATE" validate="required" GF="C" class="grid-center"></td>
                                        <td GCol="add,TIME_HOUR" GF="N 2" class="grid-center"></td>
                                        <td GCol="add,TIME_MIN" GF="N 2" class="grid-center"></td>
                                        <td GCol="input,MSRM_NM" class="grid-center"></td>
                                        <td GCol="input,WRK_CLASS" class="grid-center"></td>

                                        <td GCol="text,MACH_CD"></td><%--숨김--%>
                                        <td GCol="text,MACH_NM" class="grid-center"></td>
                                        <td GCol="add,LOT_NO_AA,LOTAA" validate="required" class="grid-center"></td>
                                        <td GCol="add,LOT_NO_RA,LOTRA" validate="required" class="grid-center"></td>
                                        <td GCol="add,MATNR,MATKY" validate="required" class="grid-center"></td>
                                        <td GCol="text,MATNR_NM" class="grid-center"></td>
<%--                                        <td GCol="select,MATNR" validate="required" class="grid-center">--%>
<%--                                            <select class="input" id="MATNR" CommonCombo="QLT_H3_MAT" style="border: 0px">--%>
<%--                                                <option value="">선택</option>--%>
<%--                                            </select>--%>
<%--                                        </td>--%>

<%--                                        <td GCol="input,LAYER_CNT" GF="N 6,0" class="grid-center"></td>       &lt;%&ndash;겹수&ndash;%&gt;--%>
<%--                                        <td GCol="input,ROLL_CNT" GF="N 6,0" class="grid-center"></td>        &lt;%&ndash; 롤수 &ndash;%&gt;--%>
<%--                                        <td GCol="input,WIDTH" GF="N 6,0" class="grid-center"></td>           &lt;%&ndash; 지폭 &ndash;%&gt;--%>
<%--                                        <td GCol="input,CUT_INT" GF="N 6,0" class="grid-center"></td>         &lt;%&ndash; 절취간격 &ndash;%&gt;--%>
<%--                                        <td GCol="input,DIAM" GF="N 6,0" class="grid-center"></td>            &lt;%&ndash; 직경 &ndash;%&gt;--%>
<%--                                        <td GCol="input,RED_DIAM" GF="N 6,0" class="grid-center"></td>        &lt;%&ndash; 감축직경 &ndash;%&gt;--%>
<%--                                        <td GCol="input,RED_RATE" GF="N 6,1" class="grid-center"></td>        &lt;%&ndash; 감축율 &ndash;%&gt;--%>
<%--&lt;%&ndash;                                        <td GCol="input,LEN_CNT" GF="N 6,1" class="grid-center"></td> &lt;%&ndash; 길이/매수 &ndash;%&gt;&ndash;%&gt;--%>
<%--                                        <td GCol="input,BS_WGT" GF="N 6,2" class="grid-center"></td>          &lt;%&ndash; 평량 &ndash;%&gt;--%>
<%--                                        <td GCol="input,BREAK" GF="N 6,0" class="grid-center"></td>           &lt;%&ndash; 파강 &ndash;%&gt;--%>
<%--                                        <td GCol="input,CUT_STR" GF="N 6,0" class="grid-center"></td>         &lt;%&ndash; 절취강도 &ndash;%&gt;--%>
<%--                                        <td GCol="input,THK_AVG" GF="N 6,3" class="grid-center"></td>         &lt;%&ndash; 두께평균 &ndash;%&gt;--%>
<%--                                        <td GCol="input,TAIL_STR" GF="N 6,0" class="grid-center"></td>        &lt;%&ndash; 테일강도 &ndash;%&gt;--%>
<%--                                        <td GCol="input,LENGTH" GF="N 6,1" class="grid-center"></td> &lt;%&ndash; 길이 &ndash;%&gt;--%>
                                        <td GCol="input,LAYER_CNT"
                                            GF="N 6"
                                            class="grid-center spec-check"
                                            data-spec-col="LAYER_CNT"
                                            data-spec-min-col="LAYER_CNT_MIN"
                                            data-spec-max-col="LAYER_CNT_MAX"></td>

                                        <td GCol="input,ROLL_CNT"
                                            GF="N 6"
                                            class="grid-center spec-check"
                                            data-spec-col="ROLL_CNT"
                                            data-spec-min-col="ROLL_CNT_MIN"
                                            data-spec-max-col="ROLL_CNT_MAX"></td>

                                        <td GCol="input,WIDTH"
                                            GF="N 6"
                                            class="grid-center spec-check"
                                            data-spec-col="WIDTH"
                                            data-spec-min-col="WIDTH_MIN"
                                            data-spec-max-col="WIDTH_MAX"></td>

                                        <td GCol="input,CUT_INT"
                                            GF="N 6"
                                            class="grid-center spec-check"
                                            data-spec-col="CUT_INT"
                                            data-spec-min-col="CUT_INT_MIN"
                                            data-spec-max-col="CUT_INT_MAX"></td>

                                        <td GCol="input,DIAM"
                                            GF="N 6"
                                            class="grid-center spec-check"
                                            data-spec-col="DIAM"
                                            data-spec-min-col="DIAM_MIN"
                                            data-spec-max-col="DIAM_MAX"></td>

                                        <td GCol="input,RED_DIAM"
                                            GF="N 6"
                                            class="grid-center spec-check"
                                            data-spec-col="RED_DIAM"
                                            data-spec-min-col="RED_DIAM_MIN"
                                            data-spec-max-col="RED_DIAM_MAX"></td>

                                        <td GCol="input,RED_RATE"
                                            GF="N 6,1"
                                            class="grid-center spec-check"
                                            data-spec-col="RED_RATE"
                                            data-spec-min-col="RED_RATE_MIN"
                                            data-spec-max-col="RED_RATE_MAX"></td>

                                        <td GCol="input,LEN_CNT"
                                            GF="N 6,1"
                                            class="grid-center spec-check"
                                            data-spec-col="LEN_CNT"
                                            data-spec-min-col="LEN_CNT_MIN"
                                            data-spec-max-col="LEN_CNT_MAX"></td>

                                        <td GCol="input,BS_WGT"
                                            GF="N 6,2"
                                            class="grid-center spec-check"
                                            data-spec-col="BS_WGT"
                                            data-spec-min-col="BS_WGT_MIN"
                                            data-spec-max-col="BS_WGT_MAX"></td>

                                        <td GCol="input,BREAK"
                                            GF="N 6"
                                            class="grid-center spec-check"
                                            data-spec-col="BREAK"
                                            data-spec-min-col="BREAK_MIN"
                                            data-spec-max-col="BREAK_MAX"></td>

                                        <td GCol="input,CUT_STR"
                                            GF="N 6"
                                            class="grid-center spec-check"
                                            data-spec-col="CUT_STR"
                                            data-spec-min-col="CUT_STR_MIN"
                                            data-spec-max-col="CUT_STR_MAX"></td>

                                        <td GCol="input,THK_AVG"
                                            GF="N 6,3"
                                            class="grid-center spec-check"
                                            data-spec-col="THK_AVG"
                                            data-spec-min-col="THK_AVG_MIN"
                                            data-spec-max-col="THK_AVG_MAX"></td>

                                        <td GCol="input,TAIL_STR"
                                            GF="N 6"
                                            class="grid-center spec-check"
                                            data-spec-col="TAIL_STR"
                                            data-spec-min-col="TAIL_STR_MIN"
                                            data-spec-max-col="TAIL_STR_MAX"></td>


                                        <td GCol="input,CUT_LINE" class="grid-center"></td>                   <%-- 절취선 이상 유무 --%>
                                        <td GCol="input,TAIL_SPLT" class="grid-center"></td>                  <%-- 테일 겹분리 --%>
                                        <td GCol="input,CONTAM" class="grid-center"></td>                     <%-- 이물질 혼입 유무 --%>
                                        <td GCol="input,EMBOSS" class="grid-center"></td>                     <%-- 엠보싱 상태 --%>
                                        <td GCol="input,PACK_STS" class="grid-center"></td>                   <%-- 포장상태 --%>
                                        <td GCol="input,SMELL" class="grid-center">냄새</td>                      <%-- 냄새 --%>
                                        <td GCol="input,FLUORO" class="grid-center">형광검출</td>                     <%-- 형광 검출 --%>

                                        <td GCol="select,FNL_JDGM" class="grid-center">                       <%-- 최종판정 --%>
                                            <select class="input" id="FNL_JDGM" CommonCombo="FNL_JDGM" style="border: 0px"></select>
                                        </td>
                                        <td GCol="input,RMK" class="grid-center"></td>                        <%-- 비고 --%>
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
                <div class="table_box section" id="tab1-2">
                    <div class="table_list01">
                        <div class="scroll">
                            <table class="table_b">
                                <tbody id="gridList_B">
                                <tr CGRow="true">
                                    <td GH="40" GCol="rowCheck"></td>
                                    <td GH="0" GCol="text,PRC_DIV">처리구분</td>
                                    <td GH="80" GCol="text,PRC_DIV_NM">처리구분(명)</td>
                                    <td GH="100" GCol="text,WERKS" style="text-align:center;">플랜트</td>
                                    <td GH="0" GCol="text,MACH_CD" style="text-align:center;">설비</td>
                                    <td GH="0" GCol="text,MACH_NM">설비(명)</td>
                                    <td GH="140" GCol="text,PRD_PRFM_DT" style="text-align:center;">생산실적일시</td>
                                    <td GH="140" GCol="text,WRK_ORDR_NO" style="text-align:center;">작업지시번호</td>
                                    <td GH="100" GCol="text,WRK_ORDR_SEQNO" style="text-align:center;">작업지시순번</td>
                                    <td GH="100" GCol="text,LOT_NO" style="text-align:center;">LOT번호</td>
                                    <td GH="0" GCol="text,IND_BCD" style="text-align:center;">개별바코드</td>
                                    <td GH="140" GCol="text,MATNR" style="text-align:center;">자재코드</td>
                                    <td GH="320" GCol="text,MATNR_NM">자재코드명</td>
                                    <td GH="0" GCol="text,PLT_QTY" GF='N 10,1'>팔레트수량</td>
                                    <td GH="0" GCol="text,BOX_QTY" GF='N 10'>박스수량</td>
                                    <td GH="80" GCol="text,BAG_QTY" GF='N 10'>백수량</td>
                                    <td GH="0" GCol="text,EA_QTY" GF='N 10'>개수량</td>
                                    <td GH="0" GCol="text,WGT" GF='N 10,3'>중량</td>
                                    <td GH="0" GCol="text,UNIT" style="text-align:center;">단위</td>
                                    <td GH="100" GCol="text,UNIT_NM">단위(명)</td>
                                    <td GH="0" GCol="text,PRD_DT" GF="D" style="text-align:center;">제조일자</td>
                                    <td GH="100" GCol="text,BRAND_DESCR">브랜드</td>
                                    <td GH="0" GCol="text,DOC_NO">MES문서번호</td>
                                    <td GH="0" GCol="text,DOC_SEQNO">MES문서순번</td>
                                    <!-- 2022-08-29(월요일) 안상현, 부적합량 제거 -->
                                    <!-- <td GH="100" GCol="input,UCFMTY_AMT" GF="N 13">부적합량</td>  -->
                                    <td GH="100" GCol="text,INSP_YN">검사여부(Y/N)</td>
                                    <td GH="0" GCol="text,INSP_ITEM_GRP_CD" style="text-align:center;">검사항목그룹코드</td>
                                    <td GH="140" GCol="text,MSRM_DATE" style="text-align:center;">측정일시</td>
                                    <td GH='100' GCol='text,STOR_LOC_CD' style="text-align:center;">저장위치</td>
                                    <td GH='80' GCol='text,CHK_PP_YN' style='text-align:center;'>생산확인</td>
                                    <td GH='0' GCol='text,STCK_STA' style="text-align:center;">재고상태</td>
                                    <td GH='100' GCol='text,STCK_STA_NM'>재고상태(명)</td>
                                    <td GH="0" GCol="text,PRC_SEQNO" style="text-align:right;">처리순번</td>
                                    <td GH="0" GCol="text,UCFMTY_YN">부적합 결과 여부</td>
                                    <td GH="0" GCol="text,REGDATE" style="text-align:center;"></td>
                                    <td GH='0' GCol='text,STCK_KY'>WMS 저장키</td>
                                    <td GH='0' GCol='text,LOT_NUM'>WMS LOTNO속성키</td>
                                    <td GH="100" GCol="text,REGNM"></td>
                                    <td GH="0" GCol="text,CHK_CNT">생리대 완제품검사 기준값 등록 여부</td>
                                </tr>
                                </tbody>
                            </table>
                        </div>
                    </div>
                    <jsp:include page="/WEB-INF/jsp/common/commonBtnAuth.jsp">
                    	<jsp:param name="authCd" value="2"/>
                    	<jsp:param name="showAuthCd" value="1,2,3,7,9,10"/>
                    </jsp:include>
                </div>
                <div class="table_box section" id="tab1-3">
                    <div class="table_list01">
                        <div class="scroll">
                            <table class="table_b">
                                <tbody id="gridList_C">
                                <tr CGRow="true">
                                    <td GH="40" GCol="rowCheck"></td>
                                    <td GH="0" GCol="text,PRC_DIV">처리구분</td>
                                    <td GH="80" GCol="text,PRC_DIV_NM">처리구분(명)</td>
                                    <td GH="100" GCol="text,WERKS" style="text-align:center;">플랜트</td>
                                    <td GH="0" GCol="text,MACH_CD" style="text-align:center;">설비</td>
                                    <td GH="0" GCol="text,MACH_NM">설비(명)</td>
                                    <td GH="140" GCol="text,PRD_PRFM_DT" style="text-align:center;">생산실적일시</td>
                                    <td GH="140" GCol="text,WRK_ORDR_NO" style="text-align:center;">작업지시번호</td>
                                    <td GH="100" GCol="text,WRK_ORDR_SEQNO" style="text-align:center;">작업지시순번</td>
                                    <td GH="100" GCol="text,LOT_NO" style="text-align:center;">LOT번호</td>
                                    <td GH="0" GCol="text,IND_BCD" style="text-align:center;">개별바코드</td>
                                    <td GH="140" GCol="text,MATNR" style="text-align:center;">자재코드</td>
                                    <td GH="320" GCol="text,MATNR_NM">자재코드명</td>
                                    <td GH="0" GCol="text,PLT_QTY" GF='N 10,1'>팔레트수량</td>
                                    <td GH="0" GCol="text,BOX_QTY" GF='N 10'>박스수량</td>
                                    <td GH="80" GCol="text,BAG_QTY" GF='N 10'>백수량</td>
                                    <td GH="0" GCol="text,EA_QTY" GF='N 10'>개수량</td>
                                    <td GH="0" GCol="text,WGT" GF='N 10,3'>중량</td>
                                    <td GH="0" GCol="text,UNIT" style="text-align:center;">단위</td>
                                    <td GH="100" GCol="text,UNIT_NM">단위(명)</td>
                                    <td GH="0" GCol="text,PRD_DT" GF="D" style="text-align:center;">제조일자</td>
                                    <td GH="100" GCol="text,BRAND_DESCR">브랜드</td>
                                    <td GH="0" GCol="text,DOC_NO">MES문서번호</td>
                                    <td GH="0" GCol="text,DOC_SEQNO">MES문서순번</td>
                                    <!-- 2022-08-29(월요일) 안상현, 부적합량 제거 -->
                                    <!-- <td GH="100" GCol="input,UCFMTY_AMT" GF="N 13">부적합량</td>  -->
                                    <td GH="100" GCol="text,INSP_YN">검사여부(Y/N)</td>
                                    <td GH="0" GCol="text,INSP_ITEM_GRP_CD" style="text-align:center;">검사항목그룹코드</td>
                                    <td GH="140" GCol="text,MSRM_DATE" style="text-align:center;">측정일시</td>
                                    <td GH='100' GCol='text,STOR_LOC_CD' style="text-align:center;">저장위치</td>
                                    <td GH='80' GCol='text,CHK_PP_YN' style='text-align:center;'>생산확인</td>
                                    <td GH='0' GCol='text,STCK_STA' style="text-align:center;">재고상태</td>
                                    <td GH='100' GCol='text,STCK_STA_NM'>재고상태(명)</td>
                                    <td GH="0" GCol="text,PRC_SEQNO" style="text-align:right;">처리순번</td>
                                    <td GH="0" GCol="text,UCFMTY_YN">부적합 결과 여부</td>
                                    <td GH="0" GCol="text,REGDATE" style="text-align:center;"></td>
                                    <td GH='0' GCol='text,STCK_KY'>WMS 저장키</td>
                                    <td GH='0' GCol='text,LOT_NUM'>WMS LOTNO속성키</td>
                                    <td GH="100" GCol="text,REGNM"></td>
                                    <td GH="0" GCol="text,CHK_CNT">기저귀 완제품검사 기준값 등록 여부</td>
                                </tr>
                                </tbody>
                            </table>
                        </div>
                    </div>
                    <jsp:include page="/WEB-INF/jsp/common/commonBtnAuth.jsp">
                    	<jsp:param name="authCd" value="3"/>
                    	<jsp:param name="showAuthCd" value="1,2,3,7,9,10"/>
                    </jsp:include>
                </div>
            </div>
            <div class="content_layout tabs bottom_layout">
                <ul class="tab tab_style02">
                    <li><a href="#tab2-1">검사항목</span></a></li>
                    <dt></dt>
                    <li>
                        <dt CL="STD_SMPL_AMT">시료량</dt>
                       	<dd><input type="text" class="input" id="SMPL_AMT" UIFormat="N 5" style="width:100px"/></dd>
                    </li>
                    <li>
                        <dt CL="STD_FNL_JDGM">최종판정</dt>
                        <dd>
                        	<select class="input" id="FNL_JDGM" CommonCombo="FNL_JDGM"></select>
                        </dd>
                    </li>
                    <li class="btn_zoom_wrap">
                        <ul>
                            <li><button class="btn btn_bigger"><span>확대</span></button></li>
                        </ul>
                    </li>
                </ul>
                <div class="table_box section" id="tab2-1" >
                    <div class="table_list01">
                        <div class="scroll">
                            <table class="table_c">
                                <tbody id="gridList2">
                                <tr CGRow="true">
                                    <td GH="40" GCol="rownum">1</td>
                                    <td GH="40" GCol="rowCheck"></td>
									<td GH="140" GCol="text,BIG_CAT_NM">대분류명</td>
									<td GH="140" GCol="text,MID_CAT_NM">중분류명</td>
                                    <td GH="0" GCol="text,INSP_ITEM_GRP_CD" style="text-align:center;">검사항목그룹코드</td>
                                    <td GH="0" GCol="text,INSP_ITEM_CD" style="text-align:center;">검사항목코드</td>
									<td GH="140" GCol="text,INSP_ITEM_NM">검사항목명</td>
									<td GH="100" GCol="text,INPT_TYP">입력타입</td>
									<td GH="100" GCol="text,INPT_MTD">입력방법</td>
									<td GH="100" GCol="text,MSRM_UNIT">측정단위</td>
									<td GH="80" GCol="text,STD_VAL" GF="N 9,2">기준값</td>
									<td GH="80" GCol="text,UPP_VAL" GF="N 9,2">규격상한치</td>
									<td GH="80" GCol="text,LOW_VAL" GF="N 9,2">규격하한치</td>
									<td GH="0" GCol="text,STD_SEL">기준선택값</td>
									<td GH="180" GCol="text,INSP_STD_1">검사기준(1)</td>
									<td GH="180" GCol="text,INSP_STD_2">검사기준(2)</td>
									<td GH="80" GCol="text,MSRM_ACC" GF="N 5">측정차수</td>
									<td GH="100" GCol="btn,MSRM_INSERT" GB="Msrm_Insert MSRM_INSERT BTN_MSRM_INSERT"></td>	<!-- 결과등록 -->
									<td GH="80" GCol="input,RST_VAL" style="text-align:right;">측정값</td>
									<td GH="100" GCol="input,RST_TXT" GF="S 500">결과값(문자열)</td>
									<td GH="100" GCol="select,RST_SEL">
										<select CommonCombo='FNL_JDGM'>판정
											<option value=""></option>
										</select>
									</td>
									<td GH="140" GCol="input,RMK">특이사항</td>
									<td GH="80" GCol="text,NECSY_YN">필수입력 여부</td>
                                    <td GH="250" GCol="file,UUID"/>첨부파일</td>
									<td GH="100" GCol="select,FIT_YN">
										<select CommonCombo="FITYN">적합여부
											<option value=""></option>
										</select>
									</td>
									<td GH="140" GCol="text,REGDATE" style="text-align:center;">등록일시</td>
									<td GH="0" GCol="text,INSP_REP_YN">성적서출력여부</td>
                                </tr>
                                </tbody>
                            </table>
                        </div>
                    </div>
                    <jsp:include page="/WEB-INF/jsp/common/commonBtnAuth.jsp">
                    	<jsp:param name="authCd" value="4"/>
                    	<jsp:param name="showAuthCd" value="1,2,3,9,10"/>
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
