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
        	configData.MENU_ID = "WRK04_POP01";
        	
            gridList.setGrid({
                id : "gridList",
                url : "/mes/Work/WRK04_POP01/json/datalist.data",
                bigdata : false
            })
            
            const DISPO_CD = $("#DISPO_CD", opener.document).val()
            $("#DISPO_CD").val(DISPO_CD)
            
            const WERKS = $("#WERKS", opener.document).val()
            $("#WERKS").val(WERKS)
            
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
			const DISPO_CD = gridList.getColData(gridId, rowNum, "DISPO_CD")
			const DISPO_NM = gridList.getColData(gridId, rowNum, "DISPO_NM")
			const DISPO_DIV = gridList.getColData(gridId, rowNum, "DISPO_DIV")
			
			$("#DISPO_CD", opener.document).val(DISPO_CD)
			$("#DISPO_NM", opener.document).val(DISPO_NM)
			$("#DISPO_DIV", opener.document).val(DISPO_DIV)
			
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
							<input type="text" class="input" id="WERKS" name="WERKS" />
						</dd>
					</dl>
                    <dl>
                        <dt CL="STD_DISPO_CD">폐품코드</dt>
                        <dd>
                            <input type="text" class="input" id='DISPO_CD' name="DISPO_CD" UIFormat="U" />
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
                    <li><a href="#tab1-1" ><span>폐품항목</span></a></li>
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
	                                    <td GH="100" GCol="text,DISPO_CD">폐품코드</td>
	                                    <td GH="100" GCol="text,DISPO_NM">폐품명</td>
	                                    <td GH="100" GCol="text,DISPO_DIV">폐품유형</td>
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
