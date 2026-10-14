<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String BARCOD = request.getParameter("BARCOD");
    String TASKKY = request.getParameter("TASKKY");
    String FLAG = request.getParameter("FLAG");

    String proccd = "";
    String machcd = "";
    Object procObj = request.getSession().getAttribute(CommonConfig.SES_PROC_CD);
    Object machObj = request.getSession().getAttribute(CommonConfig.SES_MACH_CD);
    if(procObj != null) proccd = (String)procObj;
    if(machObj != null) machcd= (String)machObj;

    if(BARCOD == null){
        BARCOD = "";
    }
    if(TASKKY == null){
        TASKKY = "";
    }
    if(FLAG == null){
        FLAG = "";
    }
%>
<!doctype html>
<head>
    <style type="text/css">
        button {float: right; }
        input:read-only {background-color: #e2e2e2;}
        select:DISABLED {background-color: #e2e2e2;}
    </style>
    <meta charset="utf-8">
    <meta name="viewport" content="user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, width=device-width, target-densitydpi=medium-dpi" />
    <meta name="format-detection" content="telephone=no" />
    <title>Mobile MES</title>
    <%@ include file="/mobile/include/head.jsp" %>
    <script>

        var col = "";

        $(document).ready(function(){
            gridList.setGrid({
                id : "gridList",
                module : "mes",
                command : "MACH",
                editable : false,
                bigdata:false,
                emptyMsgType:false,
            });
            $("#PROC_CD").val("<%=proccd%>")
            searchList();
            
            PlaySound('s');
        });

        function gridListEventRowClick(gridId, rowNum, colName){
            var rowData = gridList.getRowData(gridId, rowNum);
            console.log(rowData.get('PROC_CD'))
            var param = new DataMap();
            param.put("PROC_CD",rowData.get('PROC_CD'));
            param.put("MACH_CD",rowData.get('MACH_CD'));
            var json = netUtil.sendData({
                url : "/mobile/Mobile/json/selInv.data",
                param : param
            });
            window.top.location.href = '/mobile/main.data';
            
            PlaySound('s');
        }


        function searchList(){
        	var param = new DataMap();
            param.put("PROGID", "<%= menuId%>");
            param.put("LGTYPE", "SEARCH");
            var json2 = netUtil.sendData({
                url: "/mes/system/json/saveLog.data",
                param : param
            });
        	
            var param = inputList.setRangeParam("searchArea");

            gridList.gridList({
                id : "gridList",
                param : param
            });
        }
    </script>
</head>
<body>
<div class="main_wrap">
	<div class="main_header">
		<ul>
			<li class="tit" id="title" style="width:100%;">설비호기 선택</li>
		</ul>
	</div>
    <div class="tem4_content">
        <div class="select_box" id="bindArea">
            <div id="searchArea">
                <div style="display:none;"><input type="text" class="text" id="FLAG" name="FLAG"/>
                </div>
                <table>
                    <colgroup>
                        <col width="120px" />
                        <col/>
                    </colgroup>
                    <tbody>
                    <tr>
                        <th class="fl">공정</th>
                        <td >
                            <select id="PROC_CD" name="PROC_CD" class="input" Combo="mes,PROC" onchange="searchList()">
                                <option value="">선택하세요.</option>
                            </select>
                        </td>
                    </tr>
                    </tbody>
                </table>
            </div>

        </div>

        <div class="tableWrap_search section">
            <div class="tableHeader">
                <table style="width: 100%">
                    <colgroup>
                        <col width="20px" />
                    </colgroup>
                    <thead>
                    <tr>
                        <th CL='STD_NO'>순번</th>
                    </tr>
                    </thead>
                </table>
            </div>

            <div class="tableBody">
                <table style="width: 100%;">
                    <colgroup>
                        <col width="20px" />
                    </colgroup>
                    <tbody id="gridList">
                    
                    
                   <tr CGRow="true">
                        <td GCol="text,MACH_NM" style="text-align: center;"></td>
                    </tr>
                    </tbody>
                </table>
            </div>
        </div>

        <!-- end table_body -->
        <div class="footer_5" style="position:fixed;">

            <table>
                <tr>
                    <td class="f_1"  onclick ="window.top.menuOpen()"  style="width:100%"><label CL='BTN_CLOSE'></label></td>
                </tr>
            </table>
        </div><!-- end footer_5 -->
    </div>
</div>
</body>