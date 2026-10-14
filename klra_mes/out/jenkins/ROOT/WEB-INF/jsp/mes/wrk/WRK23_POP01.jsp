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
        	configData.MENU_ID = "WRK23_POP01";
        	
            gridList.setGrid({
                id : "gridList",
                url : "/mes/Work/WRK23_POP01/json/datalist.data",
                bigdata : false
            })
            
            const IND_BCD = $("#IND_BCD", opener.document).val()
            $("#IND_BCD").val(IND_BCD)
            
            const WERKS = $("#WERKS", opener.document).val()
            $("#WERKS").val(WERKS)
            
            const MACH_CD = $("#MACH_CD", opener.document).val()
            console.log("MACH_CD : "+MACH_CD)
            $("#MACH_CD").val(MACH_CD)
            
            searchList();
        });

        // 조회
        function searchList(){
            var param = inputList.setRangeParam("searchArea");
            param.put("P_TYPE", "LIST");
            gridList.gridList({
                id : "gridList",
                param : param
            });
        }
        
     	// 버튼을 클릭한 경우
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
    		}
    	}
     	
    	// 행 더블 클릭
		function gridListEventRowDblclick(gridId, rowNum){
			const IND_BCD = gridList.getColData(gridId, rowNum, "IND_BCD")
			const WERKS = gridList.getColData(gridId, rowNum, "WERKS")
			const MACH_CD = gridList.getColData(gridId, rowNum, "MACH_CD")
			
			$("#IND_BCD", opener.document).val(IND_BCD)
			$("#WERKS", opener.document).val(WERKS)
			$("#MACH_CD", opener.document).val(MACH_CD)
			
			page.linkPopClose();
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
                </div>
            </div>
            <div class="search_inner">
                <div class="search_wrap ">
                    <dl>
						<dt CL="STD_PLANT">플랜트</dt>
						<dd>
							<input type="text" class="input" id="WERKS" name="WERKS" UIInput="S,PLANT"/>
						</dd>
					</dl>
					
                    <dl>
						<dt>공정</dt>
						<dd>
							<select class="input" name="PROC_GRP_CD" CommonCombo="PROCGRP">
								<option value="">All</option>
							</select>
						</dd>
					</dl>
                    
                    <dl>
						<dt>설비코드</dt>
						<dd>
							<input type="text" class="input" id="MACH_CD" name="MACH_CD" />
						</dd>
					</dl>
					
					<dl>
						<dt>실적일자</dt>
						<dd>
							<input type="text" name="PRFM_DT" id="PRFM_DT" UIInput="B" UIFORMAT="C N"/>
						</dd>
					</dl>
					
					<dl>
						<dt>생산일자</dt>
						<dd>
							<input type="text" name="PRD_DT" id="PRD_DT" UIInput="B" UIFORMAT="C N"/>
						</dd>
					</dl>
					
					<dl>
						<dt>자재코드</dt>
						<dd>
							<input type="text" class="input" id="MATNR" name="MATNR" />
						</dd>
					</dl>
					
					<dl>
						<dt>자재명</dt>
						<dd>
							<input type="text" class="input" id="MATNR_NM" name="MATNR_NM" />
						</dd>
					</dl>
					
					<dl>
						<dt>개별바코드</dt>
						<dd>
							<input type="text" class="input" id="IND_BCD" name="IND_BCD" />
						</dd>
					</dl>
                    
                </div>
                <div class="btn_tab">
                    <input type="button" class="btn_more" value="more" onclick="searchMore()"/>
                </div>
            </div>
        </div>
        <div class="search_next_wrap">
            <div class="content_layout tabs ">
                <ul class="tab tab_style02">
                    <li><a href="#tab1-1" ><span>바코드</span></a></li>
                    <li class="btn_zoom_wrap">
                        <ul>
                            <li><button class="btn btn_bigger"><span>확대</span></button></li>
                        </ul>
                    </li>
                </ul>
                <div class="table_box section" id="tab1-1">
                    <div class="table_list01">
                        <div class="scroll">
                            <table class="table_b">
                                <tbody id="gridList">
	                                <tr CGRow="true">
	                                    <td GH="40" GCol="rownum">1</td>
	                                    <td GH="0" GCol="text,WERKS" style="text-align: center;">플랜트코드</td>
	                                    <td GH="140" GCol="text,PRFM_DT" GF="D" style="text-align: center;">실적일자</td>
	                                    <td GH="80" GCol="text,MACH_CD" style="text-align: center;">설비코드</td>
	                                    <td GH="140" GCol="text,MACH_NM" style="text-align: center;">설비명</td>
	                                    <td GH="140" GCol="text,MATNR" style="text-align: center;">자재코드</td>
	                                    <td GH="280" GCol="text,MATNR_NM">자재명</td>
	                                    <td GH="140" GCol="text,LOT_NO" style="text-align: center;">LOT번호</td>
	                                    <td GH="140" GCol="text,IND_BCD" style="text-align: center;">개별바코드</td>
	                                    <td GH="140" GCol="text,PRD_DT" GF="D" style="text-align: center;">생산일시</td>
	                                    <td GH="60" GCol="text,WRK_CLASS" style="text-align: center;">반</td>
	                                    <td GH="60" GCol="text,WRK_SHIFT" style="text-align: center;">조</td>
	                                    <td GH="100" GCol="text,REGID">작업자</td>
	                                </tr>
                                </tbody>
                            </table>
                        </div>
                    </div>
                    <jsp:include page="/WEB-INF/jsp/common/commonBtnAuth.jsp">
						<jsp:param name="authCd" value="1" />
						<jsp:param name="showAuthCd" value="1,2,3,9,10" />
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
