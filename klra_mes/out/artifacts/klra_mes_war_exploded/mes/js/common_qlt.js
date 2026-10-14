console.log("품질관리 공통 JS 로딩 완료!!! ");

/**
 * 품질 검사 기준값 캐시
 * key: WERKS|INSP_ITEM_GRP_CD|MATNR
 * value: spec.data 응답 객체
 */
var specCache = {};

/**
 * 행별 품질 검사 기준값 저장소
 * rowSpecMap[gridId][rowNum] = specData
 */
var rowSpecMap = {};

/**
 * 문자열/숫자 값을 비교 가능한 Number로 변환한다.
 * 빈값이나 숫자 변환 불가 값은 null 반환
 */
function toNumber(val) {
    if (val === null || val === undefined || val === "") {
        return null;
    }

    var num = Number(String(val).replace(/,/g, ""));
    return isNaN(num) ? null : num;
}

/**
 * 그리드 화면에서 spec-check 대상 컬럼 정의를 읽는다.
 * td.spec-check + data-spec-* 기준으로 비교 메타정보를 구성한다.
 *
 * 반환 예:
 * {
 *   BS_WGT: { valueCol: "BS_WGT", minCol: "BS_WGT_MIN", maxCol: "BS_WGT_MAX" },
 *   MD:     { valueCol: "MD",     minCol: "MD_MIN",     maxCol: "MD_MAX" }
 * }
 */
function getSpecConfigMap(gridId) {
    var configMap = {};
    var gridBox = gridList.gridMap.map[gridId];

    gridBox.$box.find("tr[CGRow='true'] td.spec-check").each(function () {
        var $cell = jQuery(this);
        var specCol = $cell.data("spec-col");
        var minCol = $cell.data("spec-min-col");
        var maxCol = $cell.data("spec-max-col");

        if (specCol) {
            configMap[specCol] = {
                valueCol: specCol,
                minCol: minCol || "",
                maxCol: maxCol || ""
            };
        }
    });

    return configMap;
}

/**
 * 화면에서 검사그룹코드(INSP_ITEM_GRP_CD)를 읽는다.
 * 예: <tbody id="gridList" data-insp-item-grp-cd="H1">
 */
function getInspectionSpecGroupCd(gridId) {
    return jQuery("#" + gridId).data("insp-item-grp-cd") || "";
}

/**
 * MATNR 기준값 캐시용 key를 생성한다.
 * 같은 MATNR이라도 WERKS/검사그룹이 다르면 기준값이 달라질 수 있으므로 함께 포함한다.
 */
function getInspectionSpecCacheKey(gridId, matnr) {
    var werks = jQuery("#WERKS").val() || "";
    var grpCd = getInspectionSpecGroupCd(gridId) || "";

    return werks + "|" + grpCd + "|" + (matnr || "");
}

/**
 * 특정 행에 저장된 기준값(specData)을 가져온다.
 * 신규 입력/엑셀 업로드 후 조회한 기준값은 rowSpecMap에 저장된다.
 */
function getRowSpecData(gridId, rowNum) {
    if (!rowSpecMap[gridId]) {
        return {};
    }

    return rowSpecMap[gridId][rowNum] || {};
}

/**
 * 특정 행에 기준값(specData)을 저장한다.
 * hidden GCol에 넣지 않고 메모리 맵으로만 관리한다.
 */
function applySpecToRow(gridId, rowNum, specData) {
    if (!rowSpecMap[gridId]) {
        rowSpecMap[gridId] = {};
    }

    rowSpecMap[gridId][rowNum] = specData || {};
}

/**
 * 특정 행의 기준값을 초기화한다.
 * MATNR 삭제 시 이전 자재 기준값이 남지 않도록 비워줄 때 사용한다.
 */
function clearSpecValues(gridId, rowNum) {
    if (!rowSpecMap[gridId]) {
        rowSpecMap[gridId] = {};
    }

    rowSpecMap[gridId][rowNum] = {};
}

/**
 * 내부용 성능형 범위 체크 함수
 *
 * 우선순위:
 * 1. rowSpecMap에 저장된 기준값 사용
 * 2. 없으면 조회 결과 rowData에 포함된 *_MIN, *_MAX 사용
 *
 * 이 구조로
 * - 조회된 기존 데이터
 * - 신규 입력 후 기준값 조회 데이터
 * - 엑셀 업로드 후 기준값 조회 데이터
 * 모두 공통 처리한다.
 */
function isOutOfSpec(gridId, rowNum, colName, rowData, configMap) {
    var specConfig = configMap[colName];

    if (!rowData || !specConfig) {
        return false;
    }

    var specData = getRowSpecData(gridId, rowNum);

    var value = toNumber(rowData.get(colName));
    var min = null;
    var max = null;

    if (specConfig.minCol) {
        min = toNumber(specData[specConfig.minCol]);
        if (min === null) {
            min = toNumber(rowData.get(specConfig.minCol));
        }
    }

    if (specConfig.maxCol) {
        max = toNumber(specData[specConfig.maxCol]);
        if (max === null) {
            max = toNumber(rowData.get(specConfig.maxCol));
        }
    }

    if (value === null || value === undefined || value === "" || Number(value) === 0) {
        return false; // spec-out이 아니므로 정상(false)으로 처리하여 색상을 칠하지 않음
    }

    if (min === null && max === null) {
        return false;
    }

    if (min !== null && value < min) {
        return true;
    }

    if (max !== null && value > max) {
        return true;
    }

    return false;
}

/**
 * 외부 단건 호출용 wrapper
 * 내부적으로 configMap을 생성해서 isOutOfSpec을 호출한다.
 * 성능이 중요한 반복문에서는 사용하지 않고, 편의성 위주 단건 체크 시 사용한다.
 */
function isOutOfSpecByConfig(gridId, rowNum, colName, rowData) {
    var configMap = getSpecConfigMap(gridId);
    return isOutOfSpec(gridId, rowNum, colName, rowData, configMap);
}

/**
 * 특정 셀 1개를 기준값 비교 후 색상 반영한다.
 * configMap을 전달하면 반복 시 DOM 재탐색을 줄일 수 있다.
 */
function paintSpecCell(gridId, rowNum, colName, configMap) {
    configMap = configMap || getSpecConfigMap(gridId);

    if (!configMap[colName]) {
        return;
    }

    var gridBox = gridList.gridMap.map[gridId];
    var rowData = gridList.getRowData(gridId, rowNum);
    var $row = gridBox.$box.find("[" + configData.GRID_ROW_NUM + "='" + rowNum + "']");
    var $cell = $row.find("td[" + configData.GRID_COL_NAME + "='" + colName + "']");

    if ($cell.length === 0 || !rowData) {
        return;
    }

    $cell.removeClass("spec-out");

    if (isOutOfSpec(gridId, rowNum, colName, rowData, configMap)) {
        $cell.addClass("spec-out");
    }
}

/**
 * 특정 행의 spec 대상 컬럼 전체를 다시 색칠한다.
 * MATNR 변경 후, 기준값 재조회 후, 기준값 초기화 후 호출하기 좋다.
 */
function repaintRowSpecCells(gridId, rowNum, configMap) {
    configMap = configMap || getSpecConfigMap(gridId);

    for (var colName in configMap) {
        if (!configMap.hasOwnProperty(colName)) {
            continue;
        }

        paintSpecCell(gridId, rowNum, colName, configMap);
    }
}

/**
 * 그리드 전체 행의 spec 대상 컬럼을 다시 색칠한다.
 * searchList 조회 직후 기존 저장 데이터 표시용으로 사용한다.
 */
function paintAllSpecCells(gridId) {
    var list = gridList.getGridData(gridId);
    var configMap = getSpecConfigMap(gridId);

    for (var i = 0; i < list.length; i++) {
        repaintRowSpecCells(gridId, i, configMap);
    }
}

/**
 * MATNR 기준으로 검사 기준값을 조회하여 특정 행에 반영한다.
 *
 * 동작 순서:
 * 1. MATNR 없으면 기준값 초기화 + row 재색칠
 * 2. 캐시에 있으면 캐시 사용
 * 3. 없으면 /mes/quality/json/spec.data 조회
 * 4. rowSpecMap 저장 후 row 재색칠
 */
function fetchSpecByMatnr(gridId, rowNum, matnr, configMap) {
    configMap = configMap || getSpecConfigMap(gridId);

    if (!matnr) {
        clearSpecValues(gridId, rowNum);
        repaintRowSpecCells(gridId, rowNum, configMap);
        return;
    }

    var cacheKey = getInspectionSpecCacheKey(gridId, matnr);

    if (specCache[cacheKey]) {
        applySpecToRow(gridId, rowNum, specCache[cacheKey]);
        repaintRowSpecCells(gridId, rowNum, configMap);
        return;
    }

    var param = new DataMap();
    param.put("WERKS", jQuery("#WERKS").val());
    param.put("MATNR", matnr);
    param.put("INSP_ITEM_GRP_CD", getInspectionSpecGroupCd(gridId));

    var json = netUtil.sendData({
        url: "/mes/quality/json/spec.data",
        param: param
    });

    var specData = (json && json.data) ? json.data : {};
    specCache[cacheKey] = specData;

    applySpecToRow(gridId, rowNum, specData);
    repaintRowSpecCells(gridId, rowNum, configMap);
}

/**
 * 엑셀 업로드 후 그리드 전체 행에 대해 MATNR 기준값을 보강한다.
 * 업로드 데이터는 측정값만 있고 기준값이 없을 수 있으므로 업로드 직후 1회 호출한다.
 */
function loadSpecForAllRows(gridId) {
    var list = gridList.getGridData(gridId);
    var configMap = getSpecConfigMap(gridId);

    for (var i = 0; i < list.length; i++) {
        var rowData = list[i];

        if (!rowData) {
            continue;
        }

        var matnr = rowData.get("MATNR");

        if (!matnr) {
            clearSpecValues(gridId, i);
            repaintRowSpecCells(gridId, i, configMap);
            continue;
        }

        fetchSpecByMatnr(gridId, i, matnr, configMap);
    }
}

function convertExcelComboTextToValue(gridId) {
    var gridBox = gridList.gridMap.map[gridId];

    if (!gridBox || !gridBox.comboDataMap) {
        return;
    }

    var rowCnt = gridList.getGridDataCount(gridId);

    for (var colName in gridBox.comboDataMap.map) {
        var comboMap = gridBox.comboDataMap.get(colName);
        var reverseMap = {};

        // comboMap: 코드 -> 표시명
        // reverseMap: 표시명 -> 코드
        for (var code in comboMap.map) {
            var label = comboMap.get(code);

            if (label != null && label != undefined) {
                label = String(label).trim();

                reverseMap[label] = code;

                var labelWithoutCode = label.replace(/^\[[^\]]*\]/, "").trim();
                reverseMap[labelWithoutCode] = code;
            }
        }

        for (var rowNum = 0; rowNum < rowCnt; rowNum++) {
            var value = gridList.getColData(gridId, rowNum, colName);

            if (value == null || value == undefined) {
                continue;
            }

            value = String(value).trim();

            if (comboMap.containsKey(value)) {
                continue;
            }

            if (reverseMap[value] != undefined) {
                gridList.setColValue(gridId, rowNum, colName, reverseMap[value]);
            }
        }
    }
}

function getMatnrByLot(gridId, targetLotNo) {
    var lotList = [];
    var rowList = gridList.getGridData(gridId);

    rowList.forEach(function(row) {
        if (row && typeof row.get === 'function') {
            var lotNo = row.get(targetLotNo);
            var matnr = row.get("MATNR");

            if (lotNo && lotNo.trim() !== '' && (!matnr || matnr.trim() === '')) {
                lotList.push(lotNo.trim());
            }
        }
    });

    var param = new DataMap();
    param.put('lotList', lotList);

    if(lotList.length > 0){
        netUtil.send({
            url : "/mes/quality/json/getMatnrList.data",
            param : param,
            successFunction : "setMatnrByLot"
        });
    }
}

function setMatnrByLot(json) {
    console.log("setMatnrByLot");
    if(json.isSuccess == true){
        var gridId = gridList.excelUpGridId;
        var list = gridList.getGridData(gridId);
        if(json.data.length > 0){
            var matnrList = json.data;
            matnrList.forEach(function(matnrRow) {

                // var targetRow = list.find(function(row) {
                //     if (row && row.map) {
                //         var gridLot = row.map["LOT_NO_RA"] ? String(row.map["LOT_NO_RA"]).trim() : "";
                //         var backendLot = matnrRow.LOT_NO ? String(matnrRow.LOT_NO).trim() : "";
                //         return gridLot === backendLot;
                //     }
                //     return false;
                // });

                var targetRows = list.filter(function(row) {
                    if (row && row.map) {
                        var gridLot = row.map["LOT_NO_RA"] ? String(row.map["LOT_NO_RA"]).trim() : "";
                        var backendLot = matnrRow.LOT_NO ? String(matnrRow.LOT_NO).trim() : "";
                        return gridLot === backendLot;
                    }
                    return false;
                });

                // if (targetRow) {
                if (targetRows.length > 0) {
                    targetRows.forEach(function(targetRow) {
                        // 💡 [핵심 수정] 값을 대입할 때도 map 객체 내부에 주입해야 그리드가 인식합니다.
                        targetRow.map.MATNR = matnrRow.MATNR;
                        targetRow.map.MATNR_NM = matnrRow.MATNR_NM;
                        console.log("▶ 매핑 성공:", matnrRow.LOT_NO, "->", matnrRow.MATNR);

                        gridList.setColValue(gridId, targetRow.map.GRowNum, "MATNR", matnrRow.MATNR);
                        gridList.setColValue(gridId, targetRow.map.GRowNum, "MATNR_NM", matnrRow.MATNR_NM);

                        gridListEventDataBindEnd(gridId);
                    })
                } else {
                    console.warn("▶ 매핑 실패 (그리드에서 못 찾음):", matnrRow.LOT_NO);
                }
            });
        }
    } else {
        alert(json.errMsg);
    }
}