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
        $(document).ready(function () {
            gridList.setGrid({
                id: "gridList",
                url: "/mes/quality/prod_spec/json/list.data",
                bigdata: false,
                colorType: true,
                selectRowDeleteType : true
            })
        });

        function searchList() {
            if (validate.check("searchArea")) {
                var param = inputList.setRangeParam("searchArea");

                param.put("MAT_NM_LB", $("#MAT_NM_LB").val());
                param.put("MAT_NM_NB", $("#MAT_NM_NB").val());
                param.put("TEST", "테스트라구요");

                gridList.gridList({
                    id: "gridList",
                    param: param
                });
            }
        }

        function gridListEventDataBindEnd(gridId, dataLength) {
            console.log('gridListEventDataBindEnd');
            if (gridId == "gridList") {
                var list = gridList.getGridData(gridId);
            }
        }

        function gridListEventRowDblclick(gridId, rowNum) {
            console.log('gridListEventRowDblclick');
            if (gridId == "gridList") {
                searchSubList(rowNum);
                colNum = rowNum
            }
        }

        function gridListEventColValueChange(gridId, rowNum, colName, colValue) {
            console.log('gridListEventColValueChange');
            if (gridId == "gridList") {
                var rowData = gridList.getSelectData("gridList");

                for (var i = 0; i < rowData.length; i++) {
                    if (i >= 1) {
                        if (rowData[i].get("MATNR") != rowData[i - 1].get("MATNR")) {
                            alert("서로 다른 자재코드는 현장순회외관검사를 진행할 수 없습니다.");
                            gridList.setRowState(gridId, configData.GRID_ROW_STATE_READ, rowNum);
                            gridList.setRowCheck(gridId, rowNum, false);
                            return;
                        }
                    }
                }
            }
        }

        function saveData() {
            var json = netUtil.sendData({
                module: 'mes',
                command: 'SYSTEMCHECK',
                sendType: 'map'
            });

            if (json.data.USE_YN == 'Y') {
                alert('시스템 점검 중입니다. 1 ~ 5분 동안 잠시만 기다려 주세요.');
                return;
            }

            var rowData = gridList.getModifyData("gridList", "A");

            var param = new DataMap();
            param.put("rowData", rowData);
            // param.put("WERKS", "P200");
            // param.put("INSP_ITEM_GRP_CD", $("#gridList").data("insp-item-grp-cd"));

            netUtil.send({
                url : "/mes/quality/prod_spec/json/save.data",
                param : param,
                successFunction : "saveSuccessCallBack"
            });
        }

        function saveSuccessCallBack(json) {
            if(json.isSuccess){
                commonUtil.msgBox(configData.MSG_SYSTEM_SAVEOK);
                jQuery("#warning-bar").fadeOut();
                searchList();
            } else {
                commonUtil.msgBox("저장 오류 발생 : " + json.errMsg);
            }
        }

        function commonBtnClick(btnName) {
            if (btnName == "Search") {
                var param = new DataMap();
                param.put("PROGID", "<%= menuId%>");
                param.put("LGTYPE", "SEARCH");
                netUtil.sendData({
                    url: "/mes/system/json/saveLog.data",
                    param: param
                });

                searchList();
            } else if (btnName == "Save") {
                saveData();
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
                    <input type="button" id="button-0-1" CB="Search SEARCH BTN_SEARCH"/>
                    <input type="button" id="button-0-2" CB="Save SAVE BTN_SAVE"/>
                </div>
            </div>
            <div class="search_inner">
                <div class="search_wrap ">
                    <dl>
                        <dt CL="STD_MSRM_DATE">일자</dt>
                        <dd><input type="text" name="A.MSRM_DATE" UIInput="B" UIFormat="C M1"/></dd>
                    </dl>
                    <dl>
                        <dt CL="STD_MAT_NM_LB">원료명(활엽수</dt>
                        <dd>
                            <input type="text" id="MAT_NM_LB" UIInput="S"/>
                        </dd>
                    </dl>
                    <dl>
                        <dt CL="STD_MAT_NM_NB">원료명(침엽수)</dt>
                        <dd>
                            <input type="text" id="MAT_NM_NB" UIInput="S"/>
                        </dd>
                    </dl>
                    <dl>
                        <dt CL="STD_MACH_CD">설비</dt>
                        <dd>
                            <input type="text" name="A.MACH_CD" UIInput="SR,MACH" UIFormat="U"/>
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
                    <li><a href="#tab1-1">생산사양</a></li>
                    <li class="btn_zoom_wrap">
                        <ul>
                            <li>
                                <button class="btn btn_bigger"><span>확대</span></button>
                            </li>
                        </ul>
                    </li>
                    <dt></dt>
                </ul>
                <div class="table_box section" id="tab1-1">
                    <div class="table_list01">
                        <div class="table_thead tableHeader">
                            <table>
                                <colgroup>
                                    <col width="40px"/>
                                    <col width="40px"/>

                                    <col width="130px"/>

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
                                    <col width="80px"/>
                                </colgroup>
                                <thead>
                                    <tr>
                                        <th rowspan="2" GH="40" GCol="rowCheck">
                                            <input type="checkbox" onclick="gridList.checkAll('gridList', this.checked);" class="GEditBack">
                                        </th>
                                        <th rowspan="2">번호</th>
                                        <th rowspan="2">생산사양SEQ</th>
                                        <th rowspan="2">설비</th>
                                        <th rowspan="2">날짜</th>
                                        <th rowspan="2">시간</th>
                                        <th colspan="12" style="background-color: #DDEBF7;">LBKP</th>
                                        <th colspan="12" style="background-color: #d3cdde;">NBKP</th>
                                        <th rowspan="2">총사용량</th>
                                        <th rowspan="2">총비율</th>
                                    </tr>
                                    <tr>
                                        <th GCol="text,MAT_NM_1">원료명</th>
                                        <th GCol="text,USE_QTY_1">사용량</th>
                                        <th GCol="text,MIX_RATE_1">비율</th>
                                        <th GCol="text,MAT_NM_2">원료명</th>
                                        <th GCol="text,USE_QTY_2">사용량</th>
                                        <th GCol="text,MIX_RATE_2">비율</th>
                                        <th GCol="text,MAT_NM_3">원료명</th>
                                        <th GCol="text,USE_QTY_3">사용량</th>
                                        <th GCol="text,MIX_RATE_3">비율</th>
                                        <th GCol="text,MAT_NM_4">원료명</th>
                                        <th GCol="text,USE_QTY_4">사용량</th>
                                        <th GCol="text,MIX_RATE_4">비율</th>

                                        <th GCol="text,MAT_NM_5">원료명</th>
                                        <th GCol="text,USE_QTY_5">사용량</th>
                                        <th GCol="text,MIX_RATE_5">비율</th>
                                        <th GCol="text,MAT_NM_6">원료명</th>
                                        <th GCol="text,USE_QTY_6">사용량</th>
                                        <th GCol="text,MIX_RATE_6">비율</th>
                                        <th GCol="text,MAT_NM_7">원료명</th>
                                        <th GCol="text,USE_QTY_7">사용량</th>
                                        <th GCol="text,MIX_RATE_7">비율</th>
                                        <th GCol="text,MAT_NM_8">원료명</th>
                                        <th GCol="text,USE_QTY_8">사용량</th>
                                        <th GCol="text,MIX_RATE_8">비율</th>
                                    </tr>
                                </thead>
                            </table>
                        </div>
                        <div class="scroll" style="height: calc(100% - 77px)">
                            <table class="table_b">
                                <tbody id="gridList">
                                    <tr CGRow="true" class="custom-td">
                                        <td GCol="rowCheck"></td>
                                        <td GCol="rownum">1</td>

                                        <td GCol="text,PROD_KEY"></td>

                                        <td GCol="text,MACH_CD" style="text-align: center !important"></td>
                                        <td GCol="text,MSRM_DATE" GF="C" style="text-align: center !important"></td>
                                        <td GCol="text,MSRM_TIME" style="text-align: center !important"></td>

                                        <td GCol="input,MAT_NM_1" style="text-align: center !important"></td>
                                        <td GCol="input,USE_QTY_1" GF="N 6" style="text-align: center !important"></td>
                                        <td GCol="input,MIX_RATE_1" GF="N 3,1" style="text-align: center !important"></td>
                                        <td GCol="input,MAT_NM_2" style="text-align: center !important"></td>
                                        <td GCol="input,USE_QTY_2" GF="N 6" style="text-align: center !important"></td>
                                        <td GCol="input,MIX_RATE_2" GF="N 3,1" style="text-align: center !important"></td>
                                        <td GCol="input,MAT_NM_3" style="text-align: center !important"></td>
                                        <td GCol="input,USE_QTY_3" GF="N 6" style="text-align: center !important"></td>
                                        <td GCol="input,MIX_RATE_3" GF="N 3,1" style="text-align: center !important"></td>
                                        <td GCol="input,MAT_NM_4" style="text-align: center !important"></td>
                                        <td GCol="input,USE_QTY_4" GF="N 6" style="text-align: center !important"></td>
                                        <td GCol="input,MIX_RATE_4" GF="N 3,1" style="text-align: center !important"></td>

                                        <td GCol="input,MAT_NM_5" style="text-align: center !important"></td>
                                        <td GCol="input,USE_QTY_5" GF="N 6" style="text-align: center !important"></td>
                                        <td GCol="input,MIX_RATE_5" GF="N 3,1" style="text-align: center !important"></td>
                                        <td GCol="input,MAT_NM_6" style="text-align: center !important"></td>
                                        <td GCol="input,USE_QTY_6" GF="N 6" style="text-align: center !important"></td>
                                        <td GCol="input,MIX_RATE_6" GF="N 3,1" style="text-align: center !important"></td>
                                        <td GCol="input,MAT_NM_7" style="text-align: center !important"></td>
                                        <td GCol="input,USE_QTY_7" GF="N 6" style="text-align: center !important"></td>
                                        <td GCol="input,MIX_RATE_7" GF="N 3,1" style="text-align: center !important"></td>
                                        <td GCol="input,MAT_NM_8" style="text-align: center !important"></td>
                                        <td GCol="input,USE_QTY_8" GF="N 6" style="text-align: center !important"></td>
                                        <td GCol="input,MIX_RATE_8" GF="N 3,1" style="text-align: center !important"></td>

                                        <td GCol="text,TOTAL_USE" GF="N 8,0" style="text-align: center !important"></td>
                                        <td GCol="text,TOTAL_RATE" GF="N 3,1" style="text-align: center !important"></td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
                    </div>
                    <jsp:include page="/WEB-INF/jsp/common/commonBtnAuth.jsp">
                        <jsp:param name="authCd" value="1"/>
                        <jsp:param name="showAuthCd" value="1,2,3,4,5,6,7,9,10,11"/>
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
