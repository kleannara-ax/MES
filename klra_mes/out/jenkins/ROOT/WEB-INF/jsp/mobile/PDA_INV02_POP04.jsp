<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
	String plant = (String)request.getSession().getAttribute(CommonConfig.SES_USER_PLANT_KEY);
	String matnr = request.getParameter("MATNR");
	String matnrNm = request.getParameter("MATNR_NM");
	String indbcd = request.getParameter("IND_BCD");
	String machCd = request.getParameter("MACH_CD");
	String WrkOrdrNo = request.getParameter("WRK_ORDR_NO");
	String WrkOrdrSeqno = request.getParameter("WRK_ORDR_SEQNO");
%>
<!doctype html>
<head>
    <style type="text/css">
        button {float: right; }
        input:read-only {background-color: #e2e2e2;}
        select:DISABLED {background-color: #e2e2e2;}
        .tem4_content .tableBody tr.gridColorBgBlue td, .tem4_content .tableBody tr td.gridColorBgBlue{background:skyblue !important}
    </style>
    <meta charset="utf-8">
    <meta name="viewport" content="user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, width=device-width, target-densitydpi=medium-dpi" />
    <meta name="format-detection" content="telephone=no" />
    <title>Mobile MES</title>
    <%@ include file="/mobile/include/head.jsp" %>
    <script>
        $(document).ready(function(){
        	gridList.setGrid({
				id : "gridList",
				url : "/mobile/Mobile/PDA_INV02/json/datalist.data",
				bigdata : false,
				//gridMobileType : true,
				colorType : true
			});
            
        	$("#MATNR").val('<%=matnr%>');
        	$("#MATNR_NM").val('<%=matnrNm%>');
        	
            searchList();
        });

        function searchList(){        	
        	var param = new DataMap();
        	
        	param.put("WRK_ORDR_NO", '<%=WrkOrdrNo%>');
        	param.put("WRK_ORDR_SEQNO", '<%=WrkOrdrSeqno%>');
        	param.put("P_TYPE", "SUB_LIST4");
        	
	        gridList.gridList({
	            id : "gridList",
	            param : param
	        });
	        
	        PlaySound('s');
        }
        
        function gridListRowBgColorChange(gridId, rowNum){
    		if(gridId == "gridList"){
    			
    			var useyn = gridList.getColData("gridList", rowNum, "USE_YN");	//자재투입사용여부
    			
    			if(useyn != "N"){
    				return configData.GRID_COLOR_BG_BLUE_CLASS;
    			}
    		}
    	}
    </script>
</head>
<body>
<div class="main_wrap">
	<div class="main_header_pop">
		<ul>
			<li class="tit" id="title">자재정보</li>
		</ul>
	</div>
    <div class="tem4_content">
		<div class="tableWrap_search section">
			<div class="tableHeader">
				<table style="width: 160%">
					<colgroup>
						<col width="10px" />
						<col width="20px" />
						<col width="50px"/>
						<col width="30px"/>
						<col width="10px"/>
					</colgroup>
					<thead>
					<tr>
						<th>No</th>
						<th>자재코드</th>
						<th>자재명</th>
						<th>소요량</th>
						<th>단위</th>
					</tr>
					</thead>
				</table>
			</div>

			<div class="tableBody">
				<table style="width: 160%;">
					<colgroup>
						<col width="10px" />
						<col width="20px" />
						<col width="50px"/>
						<col width="30px"/>
						<col width="10px"/>
					</colgroup>
					<tbody id="gridList">
						<tr CGRow="true">
							<td GCol="rownum">1</td>
							<td GCol="text,MATNR" style="text-align:center;"></td>	<!-- 하위자재코드 -->
							<td GCol="text,MATNR_NM"></td>							<!-- 하위자재명 -->	
							<td GCol="text,ORDER_BOM_QTY" GF="N 13,3"></td>			<!-- 소요량 -->			
							<td GCol="text,UNIT" style="text-align:center;"></td>	<!-- 단위 -->	
						</tr>
					</tbody>
				</table>
			</div>
		</div>
		
		<!-- <div class="select_box mg-20">
            <table>
                <colgroup>
                    <col width="120px"/>
                    <col/>
                    <col/>
                    <col width="120px"/>
                </colgroup>
                <tbody>
	                <tr>
	                    <td class="fl fw">투입량 입력</td>
	                    <td colspan="2">
	                    	<input type="text" class="text" placeholder="자재 투입량 입력" id="IN_BOM_QTY" onchange="changeQty();"/>
	                    </td>
	                    <td>
	                    	<input type="text" class="text" placeholder="KG" id="UNIT" readonly="readonly" onclick="unitselect();"/>
	                    </td>
	                </tr>
                </tbody>
            </table>
        </div> -->
		
        <!-- end table_body -->
        <div class="footer_5" style="position:fixed;">
            <table>
                <tr>
                	<td class=f_1 onclick ="history.back();" style="width:33%"><label CL='BTN_CLOSE'></label></td>
                    <!-- <td class=f_1 onclick ="forcedInp();" style="width:33%">강제 투입</td> -->
                </tr>
            </table>
        </div><!-- end footer_5 -->
    </div>
</div>
</body>