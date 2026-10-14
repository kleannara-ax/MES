<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>체크항목</title>
<%@ include file="/common/include/webdek/head.jsp"%>
<link rel="stylesheet" type="text/css"
	href="/common/theme/webdek/css/demo_layout.css">
<script type="text/javascript">	
	$(document).ready(function(){
		configData.MENU_ID = "MAS24_POP"; 
		
		gridList.setGrid({
			id : "gridList",
            url : "/mes/Master/MAS24/json/datalist.data",
            bigdata : false
        });
         
        var Data = page.getLinkPopData();
        
        searchList(Data); 
   	});
 	
	function searchList(param){
		param.put("P_TYPE", "POP_LIST");
		
		gridList.gridList({
			id : "gridList",
			param : param
		});
	}
    
	function chkitemAdd(){
		var data = gridList.getSelectData("gridList");
		
		page.linkPopClose(data);
	}
	
    function commonBtnClick(btnName){
    	if(btnName == "Search"){
   		    var param = new DataMap();
             
   		    param.put("PROGID", configData.MENU_ID);
		    param.put("LGTYPE", "SEARCH");
		
		    var json = netUtil.sendData({
			    url : "/mes/system/json/saveLog.data",
			    param : param
		    });

		    searchList();
	    } else if (btnName == "Add") {
		    chkitemAdd();
	    }
	}
</script>
</head>
<body>
	<%@ include file="/common/include/webdek/layout.jsp"%>
	<!-- content -->
	<div class="content_wrap">
		<div class="content_inner">
			<%@ include file="/common/include/webdek/title.jsp"%>
			<div class="content_serch" id="searchArea">
				<div class="btn_wrap">
					<div class="fl_l"></div>
					<div class="fl_r">
						<input type="button" id="button-0-2" CB="Add ADD BTN_ADDROW" />
					</div>
				</div>
				<!-- <div class="search_inner">
					<div class="search_wrap ">
						<dl>
							<dt CL="STD_CHK_ITEM_NM">공정체크항목명</dt>
							<dd>
								<input type="text" class="input" name="CHK_ITEM_NM"/>
							</dd>
						</dl>
					</div>
					<div class="btn_tab">
						<input type="button" class="btn_more" value="more" onclick="searchMore()"/>
					</div>
				</div> -->
			</div>
			<div class="search_next_wrap" style="height: 90%;">
				<div class="content_layout tabs">
					<ul class="tab tab_style02">
						<li><a href="#tab1-1"><span>체크항목</span></a></li>
						<li class="btn_zoom_wrap">
							<ul>
								<li><button class="btn btn_bigger"><span>확대</span></button></li>
							</ul>
						</li>
					</ul>
					<div class="table_box section" id="tab1-1 gridList">
						<div class="table_list01">
							<div class="scroll">
								<table class="table_b">
									<tbody id="gridList">
										<tr CGRow="true">
											<td GH="40" GCol="rownum">1</td>
											<td GH="40" GCol="rowCheck"></td>
											<td GH="0" GCol="text,WERKS" style="text-align:center;">플랜트</td>
											<td GH="100" GCol="text,CHK_ITEM_CD" validate="required" style="text-align:center;">공정체크항목코드</td>
											<td GH="100" GCol="text,CHK_ITEM_NM">공정체크항목명</td>
											<td GH="0" GCol="text,MID_CAT_NM">중분류명</td>
											<td GH="100" GCol="text,BIG_CAT_NM">대분류명</td>
											<td GH="100" GCol="text,INSP_STD_1">검사기준1</td>
											<td GH="100" GCol="text,INSP_STD_2">검사기준2</td>
											<td GH="0" GCol="text,INPT_DIV">입력구분</td>
											<td GH="100" GCol="text,INPT_DIV_NM">입력구분(명)</td>
											<td GH="0" GCol="text,MSRM_CYC">측정주기</td>
											<td GH="100" GCol="text,MSRM_CYC_NM">측정주기(명)</td>
											<td GH="0" GCol="text,INPT_TYP">입력타입</td>
											<td GH="100" GCol="text,INPT_TYP_NM">입력타입(명)</td>
											<td GH="0" GCol="text,INPT_MTD">입력방법</td>
											<td GH="100" GCol="text,INPT_MTD_NM">입력방법(명)</td>
											<td GH="100" GCol="text,MSRM_MTD">측정방법</td>
											<td GH="100" GCol="text,MSRM_UNIT">측정단위</td>
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
	<%@ include file="/common/include/webdek/bottom.jsp"%>
</body>
</html>