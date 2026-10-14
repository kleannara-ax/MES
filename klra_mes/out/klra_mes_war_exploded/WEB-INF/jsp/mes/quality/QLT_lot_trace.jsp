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
        $(document).ready(function(){
            gridList.setGrid({
                id : "gridList",
                url:"/mes/quality/lot_trace/json/datalist.data",
                bigdata : false,
	            colorType : true
            })
        });

        function searchList(){
        	if(validate.check("searchArea")){
	            var param = inputList.setRangeParam("searchArea");

	           	gridList.gridList({
	                id : "gridList",
	                param : param
	            });
        	}
        }

        function gridListEventDataBindEnd(gridId, dataLength){
            console.log('gridListEventDataBindEnd');
        	if(gridId == "gridList"){
    			var list = gridList.getGridData(gridId);
    		}
        }

        function gridListEventRowDblclick(gridId, rowNum){
            console.log('gridListEventRowDblclick');
            if(gridId == "gridList"){
            }
        }

        function gridListEventColValueChange(gridId, rowNum, colName, colValue){
            console.log('gridListEventColValueChange');
        	if(gridId == "gridList"){

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

            var list = gridList.getGridData("gridList");
            var param = new DataMap();
            param.put("list", list);

            netUtil.send({
                // url : "/mes/quality/json/visualSave.data",
                param : param,
                successFunction : "saveSuccessCallBack"
            });
        }
        
        function saveSuccessCallBack(json){
            if(json.isSuccess == true){
                commonUtil.msgBox(configData.MSG_SYSTEM_SAVEOK);
                searchList();
            } else {
                alert(json.errMsg);
            }
        }
        
        function commonBtnClick(btnName){
            if(btnName == "Search"){
                var param = new DataMap();
                param.put("PROGID", "<%= menuId%>");
                param.put("LGTYPE", "SEARCH");
                netUtil.sendData({
                    url: "/mes/system/json/saveLog.data",
                    param : param
                });

                searchList();
            } else if(btnName == "Save"){
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
                    <input type="button" id="button-0-1" CB="Search SEARCH BTN_SEARCH" />
                    <input type="button" id="button-0-2" CB="Save SAVE BTN_SAVE" />
                </div>
            </div>
            <div class="search_inner">
                <div class="search_wrap ">
					<dl>
                        <dt CL="STD_PRFM_DT">초지실적일자</dt>
                        <dd><input type="text" name="W001.PRFM_DT" UIInput="B" UIFormat="C M1"/></dd>
                    </dl>
                    <dl>
                        <dt CL="STD_MACH_CD">초지설비</dt>
                        <dd>
                            <input type="text" name="W001.MACH_CD" UIInput="SR,MACH" UIFormat="U"/>
                        </dd>
                    </dl>
                    <dl>
						<dt CL="STD_LOT_NO">초지LOT번호</dt>
						<dd style="font-size: 0">					
							<input type="text" class="input" id="LOT_NO" name="LOT_NO" UIInput="SR,LOTNO" UIFormat="U"/>
						</dd>
					</dl>
                    <dl>
                        <dt CL="STD_PRFM_DT">가공실적일자</dt>
                        <dd><input type="text" name="W001.PRFM_DT" UIInput="B" UIFormat="C M1"/></dd>
                    </dl>
                    <dl>
                        <dt CL="STD_MACH_CD">가공설비</dt>
                        <dd>
                            <input type="text" name="W001.MACH_CD" UIInput="SR,MACH" UIFormat="U"/>
                        </dd>
                    </dl>
                    <dl>
                        <dt CL="STD_MAT_NM">원료명</dt>
                        <dd style="font-size: 0">
                            <input type="text" class="input" id="MAT_NM" name="MAT_NM" UIInput="SR,MAT_NM" UIFormat="U"/>
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
                    <li><a href="#tab1-1" >추적성</a></li>
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

                                <colgroup>
                                    <%--체크박스, 번호--%>
                                    <col width="40px" />
                                    <col width="40px" />

                                    <%--호기, 일자--%>
                                    <col width="80px" />
                                    <col width="80px" />

                                    <%--LBKP--%>
                                    <col width="80px" />
                                    <col width="80px" />
                                    <col width="80px" />
                                    <col width="80px" />
                                    <col width="80px" />
                                    <col width="80px" />
                                    <col width="80px" />
                                    <col width="80px" />

                                    <%--NBKP--%>
                                    <col width="80px" />
                                    <col width="80px" />
                                    <col width="80px" />
                                    <col width="80px" />
                                    <col width="80px" />
                                    <col width="80px" />
                                    <col width="80px" />
                                    <col width="80px" />

                                    <%--총비율--%>
                                    <col width="80px" />

                                    <%--초지LOT--%>
                                    <col width="80px" />

                                    <%--초지정보--%>
                                    <col width="80px" />
                                    <col width="80px" />
                                    <col width="80px" />
                                    <col width="80px" />
                                    <col width="80px" />
                                    <col width="80px" />
                                    <col width="80px" />

                                    <%--가공LOT--%>
                                    <col width="80px" />

                                    <%--가공정보--%>
                                    <col width="80px" />
                                    <col width="80px" />
                                    <col width="80px" />
                                    <col width="80px" />
                                    <col width="80px" />
                                    <col width="80px" />
                                    <col width="80px" />
                                </colgroup>
                                <thead>
                                    <tr>
                                        <th rowspan="2" GH="40" GCol="rowCheck">
                                            <input type="checkbox" gcheckall="true" class="GEditBack">
                                        </th>
                                        <th rowspan="2" GCol="rownum">번호</th>

                                        <th rowspan="2" GCol="MACH_CD">호기</th>
                                        <th rowspan="2" GCol="MSRM_DATE">일자</th>

                                        <th colspan="8" style="background-color: #DDEBF7;">LBKP</th>
                                        <th colspan="8" style="background-color: #d3cdde;">NBKP</th>

                                        <th rowspan="2" GCol="text,FNL_JDGM">총비율</th>

                                        <th rowspan="2" style="background-color: #cdd7be;">초지LOT</th>
                                        <th colspan="7" style="background-color: #cdd7be;">초지정보</th>

                                        <th rowspan="2" style="background-color: #ecdce5;">가공LOT</th>
                                        <th colspan="7" style="background-color: #ecdce5;">가공정보</th>
                                    </tr>
                                    <tr>
                                        <th GCol="text,MAT_NM_1">원료명</th>
                                        <th GCol="text,MIX_RATE_1">비율</th>
                                        <th GCol="text,MAT_NM_2">원료명</th>
                                        <th GCol="text,MIX_RATE_2">비율</th>
                                        <th GCol="text,MAT_NM_3">원료명</th>
                                        <th GCol="text,MIX_RATE_3">비율</th>
                                        <th GCol="text,MAT_NM_4">원료명</th>
                                        <th GCol="text,MIX_RATE_4">비율</th>

                                        <th GCol="text,MAT_NM_5">원료명</th>
                                        <th GCol="text,MIX_RATE_5">비율</th>
                                        <th GCol="text,MAT_NM_6">원료명</th>
                                        <th GCol="text,MIX_RATE_6">비율</th>
                                        <th GCol="text,MAT_NM_7">원료명</th>
                                        <th GCol="text,MIX_RATE_7">비율</th>
                                        <th GCol="text,MAT_NM_8">원료명</th>
                                        <th GCol="text,MIX_RATE_8">비율</th>

                                        <th GCol="text,BS_WGT">평량</th>
                                        <th GCol="text,WHITE">백색도</th>
                                        <th GCol="text,BURST">파열강도</th>
                                        <th GCol="text,MD">MD</th>
                                        <th GCol="text,CD">CD</th>
                                        <th GCol="text,ELONG">신장율</th>
                                        <th GCol="text,THICK">두께</th>

                                        <th GCol="text,DIAM">직경</th>
                                        <th GCol="text,RED_RATE">감축율?</th>
                                        <th GCol="text,BS_WGT">평량</th>
                                        <th GCol="text,BREAK">파강</th>
                                        <th GCol="text,CUT_STR">절취강도</th>
                                        <th GCol="text,THICK">두께</th>
                                        <th GCol="text,TAIL_STR">테일강도</th>
                                    </tr>
                                </thead>
                                <tbody id="gridList">
                                    <tr CGRow="true">
                                        <td GCol="rowCheck"></td>
                                        <td GCol="rownum">1</td>

                                        <td GCol="text,MACH_CD"></td>
                                        <td GCol="text,MSRM_DATE"></td>

                                        <td GCol="text,MAT_NM_1"></td>
                                        <td GCol="text,MIX_RATE_1"></td>
                                        <td GCol="text,MAT_NM_2"></td>
                                        <td GCol="text,MIX_RATE_2"></td>
                                        <td GCol="text,MAT_NM_3"></td>
                                        <td GCol="text,MIX_RATE_3"></td>
                                        <td GCol="text,MAT_NM_4"></td>
                                        <td GCol="text,MIX_RATE_4"></td>

                                        <td GCol="text,MAT_NM_5"></td>
                                        <td GCol="text,MIX_RATE_5"></td>
                                        <td GCol="text,MAT_NM_6"></td>
                                        <td GCol="text,MIX_RATE_6"></td>
                                        <td GCol="text,MAT_NM_7"></td>
                                        <td GCol="text,MIX_RATE_7"></td>
                                        <td GCol="text,MAT_NM_8"></td>
                                        <td GCol="text,MIX_RATE_8"></td>

                                        <td GCol="text,FNL_JDGM"></td>

                                        <td GCol="text,LOT_NO_M"></td>

                                        <td GCol="text,BS_WGT"></td>
                                        <td GCol="text,WHITE"></td>
                                        <td GCol="text,BURST"></td>
                                        <td GCol="text,MD"></td>
                                        <td GCol="text,CD"></td>
                                        <td GCol="text,ELONG"></td>
                                        <td GCol="text,THICK"></td>

                                        <td GCol="text,LOT_NO"></td>

                                        <td GCol="text,DIAM"></td>
                                        <td GCol="text,RED_RATE"></td>
                                        <td GCol="text,BS_WGT_TRA"></td>
                                        <td GCol="text,BREAK"></td>
                                        <td GCol="text,CUT_STR"></td>
                                        <td GCol="text,THK_AVG"></td>
                                        <td GCol="text,TAIL_STR"></td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
                    </div>
                    <jsp:include page="/WEB-INF/jsp/common/commonBtnAuth.jsp">
                    	<jsp:param name="authCd" value="1"/>
                    	<jsp:param name="showAuthCd" value="1,2,3,7,9,10"/>
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
