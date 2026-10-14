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
        	configData.MENU_ID = "SEARCH_LOT";
        	
            gridList.setGrid({
                id : "gridList",
                url : "/mes/Common/SEARCH_LOT/json/datalist.data",
                bigdata : false
            })
			
            // 플랜트 코드
            const WERKS = $("#WERKS", opener.document).val()
            $("#WERKS").val(WERKS)
            
        });

        // 조회
        function searchList(){
        	if(validate.check("searchArea")){
	            var param = inputList.setRangeParam("searchArea");
	            param.put("P_TYPE", "LIST");
	            gridList.gridList({
	                id : "gridList",
	                param : param
	            });
        	}
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
    		
    		// LOT번호
			const LOT_NO = gridList.getColData(gridId, rowNum, "LOT_NO")
			$("#LOT_NO", opener.document).val(LOT_NO)
			
			window.close()
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
							<input type="text" class="input" id="WERKS" name="WERKS" UIInput="S,PLANT" validate="required" />
						</dd>
					</dl>
                    <dl>
						<dt CL="STD_PROCGRP">공정그룹</dt>
						<dd>
							<select class="input" id="PROC_GRP_CD" name="PROC_GRP_CD" CommonCombo="PROCGRP">
								<option value="">All</option>
							</select>
						</dd>
					</dl>
                    <dl>
						<dt CL="STD_MACH_CD">설비코드</dt>
						<dd>
							<input type="text" class="input" id="MACH_CD" name="MACH_CD" />
						</dd>
					</dl>
					<dl>
						<dt CL="STD_PRFM_DT">실적일자</dt>
						<dd>
							<input type="text" name="PRFM_DT" id="PRFM_DT" UIInput="B" UIFORMAT="C M1" />
						</dd>
					</dl>
					<dl>
						<dt CL="STD_PRD_DT">생산일자</dt>
						<dd>
							<input type="text" name="PRD_DT" id="PRD_DT" UIInput="B" UIFORMAT="C M1" />
						</dd>
					</dl>
					<dl>
						<dt CL="STD_MATNR">자재코드</dt>
						<dd>
							<input type="text" class="input" id="MATNR" name="MATNR" />
						</dd>
					</dl>
					<dl>
						<dt CL="STD_MATNR_NM">자재명</dt>
						<dd>
							<input type="text" class="input" id="MATNR_NM" name="MATNR_NM" />
						</dd>
					</dl>
					<dl>
						<dt CL="STD_IND_BCD">개별바코드</dt>
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
                    <li>
                    	<a href="#tab1-1">
                    		<span>LOT</span>
                    	</a>
                    </li>
                    <li class="btn_zoom_wrap">
                        <ul>
                            <li>
                            	<button class="btn btn_bigger">
                            		<span>확대</span>
                            	</button>
                            </li>
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
	                                    <td GH="100" GCol="text,PRFM_DT" GF="D">실적일자</td>
	                                    <td GH="100" GCol="text,MACH_CD">설비코드</td>
	                                    <td GH="150" GCol="text,MACH_NM">설비코드</td>
	                                    <td GH="150" GCol="text,MATNR">자재코드</td>
	                                    <td GH="300" GCol="text,MATNR_NM">자재명</td>
	                                    <td GH="150" GCol="text,LOT_NO">LOT번호</td>
	                                    <td GH="80" GCol="text,PRFM_CNT" GF="N 10">실적건수</td>
	                                    <td GH="100" GCol="text,PRD_DT" GF="D">생산일자</td>
	                                    <td GH="100" GCol="text,WRK_CLASS">작업반</td>
	                                    <td GH="100" GCol="text,WRK_SHIFT">작업조</td>
	                                    <td GH="100" GCol="text,REGNM">등록자명</td>
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
