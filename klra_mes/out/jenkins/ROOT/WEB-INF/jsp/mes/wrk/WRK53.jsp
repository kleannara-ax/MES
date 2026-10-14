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
		var showflag = "자재사용량";
		
		gridList.setGrid({
			id : "gridList",
			url:"/common/Work/list/json/WRK53.data",
			bigdata : false,
			colGroupCols : "PIND_BCD"
		})
	});


	function searchList() {
		if (validate.check("searchArea")) {
			// 2023-03-13(월요일) 안상현, RANGE 검색 추가
			const range = inputList.setRangeParam("searchArea")
			const range_data_param = range.get("RANGE_DATA_PARAM")
			const prfm_dt = range_data_param.get("PRFM_DT_Range")
			const date = prfm_dt.split("↓")
			const SDate = date[1]
			const EDate = date[2]
			
			const param = inputList.setRangeParam("searchArea")
			param.put("SDATE", SDate);
			param.put("EDATE", EDate);
			
			gridList.gridList({
		    	id : "gridList",
		    	param : param
		    })
			/* 
			var range = inputList.setRangeParam("searchArea");
			var range_data_param = range.get("RANGE_DATA_PARAM");
			var prfm_dt = range_data_param.get("PRFM_DT_Range");
			var date = prfm_dt.split('↓');
			var SDate = date[1];
			var EDate = date[2];

			var param = new DataMap();
			param.put("P_TYPE", "LIST");
			param.put("SDATE", SDate);
			param.put("EDATE", EDate);
			
			param.put("PCODE",$("#PCODE").val().toUpperCase());
			param.put("BS_WGT",$("#BS_WGT").val());
			param.put("WLEN",$("#WLEN").val());
			param.put("VLEN",$("#VLEN").val());
			param.put("INOUT_GU",$("#INOUT_GU").val());
			param.put("CNL_YN", $("#CNL_YN").val());
			param.put("IND_BCD", $("#IND_BCD").val());
			param.put("CHKFG", $("#CHKFG").val());
			
			if (document.getElementById('CHKFG').checked) {
				param.put("CHKFG", 'ON');
			} else {
				param.put("CHKFG", 'OFF');
			}
			
			gridList.gridList({
				id : "gridList",
				param : param
			});
			*/
		}
	}
	

	function commonBtnClick(btnName){
		//commonUtil.debugMsg("commonBtnClick : ", arguments);
		if(btnName == "Search"){
			var param = new DataMap();
	        param.put("PROGID", "<%= menuId%>");
	        param.put("LGTYPE", "SEARCH");
	        var json = netUtil.sendData({
	            url: "/mes/system/json/saveLog.data",
	            param : param
	        });
			
			searchList();
		}else if(btnName == "Save"){
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
				</div>
			</div>
			<div class="search_inner">
				<div class="search_wrap ">
				
				  	<dl>
						<dt>포장실적일자</dt>
						<dd><input type="text" name="PRFM_DT" id="PRFM_DT" UIInput="B" UIFORMAT="C M1"/></dd>
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
					<li><a href="#tab1-1"><span CL="STD_GRD_WRK53">일반</span></a></li>
					<li class="btn_zoom_wrap">
						<ul>
							<!-- <li><button class="btn btn_smaller"><span>축소</span></button></li> -->
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
										<td GH="100" GCol="text,PRFM_DT" style="text-align:center;"></td>
										<td GH="100" GCol="text,PPRFM_DT" style="text-align:center;"></td>
										<td GH="70" GCol="text,DOMESTIC" style="text-align:center;"></td>
										<td GH="100" GCol="text,MACHINE" style="text-align:center;"></td>
										<td GH="100" GCol="text,MACH_CD" style="text-align:center;"></td>
										<td GH="150" GCol="text,MACH_NM" style="text-align:center;"></td>
										<td GH="120" GCol="text,IND_BCD" style="text-align:center;"></td>
										<td GH="80" GCol="text,BS_WGT" style="text-align:right;"></td>
										<td GH="80" GCol="text,WIDTH" style="text-align:right;"></td>
										<td GH="180" GCol="text,PRFM_QTY" style="text-align:right;"></td>
										<td GH="100" GCol="text,KUNNR"></td>
										<td GH="320" GCol="text,CUST_NM"></td>
										<td GH="100" GCol="text,PMACH_NM"></td>
										<td GH="100" GCol="text,LAND1"></td>
										<td GH="80" GCol="text,LAND1_NM"></td>
										<td GH="80" GCol="text,CORE" style="text-align:center;"></td>
										<td GH="80" GCol="text,COVER_YN" style="text-align:center;"></td>
										<td GH="80" GCol="text,CORR_YN" style="text-align:center;"></td>
										<td GH="80" GCol="text,PACK_YN" style="text-align:center;"></td>
									</tr>
								</tbody>
							</table>
						</div>
					</div>
					<jsp:include page="/WEB-INF/jsp/common/commonBtnAuth.jsp">
						<jsp:param name="authCd" value="1" />
						<jsp:param name="showAuthCd" value="1,2,3,7,9,10" />
					</jsp:include>		
				</div>
			</div>
			
			
			
				</div>
			</div>
		</div>
	</div>
</div>
<!-- // content -->
<%@ include file="/common/include/webdek/bottom.jsp" %>
</body>
</html>