<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>MES</title>
<%@ include file="/common/include/webdek/head.jsp" %>
<script type="text/javascript">
	$(document).ready(function(){
		gridList.setGrid({
			id : "gridList",
	    	url : "/mes/Work/WRK35/json/datalist.data",
	    	bigdata : false
	    });
	});

	function comboEventDataBindeBefore(comboAtt){
		if(comboAtt == "Produce,MACHINE"){
			var param = new DataMap();
			
			param.put("WERKS", 'P100');
		}
		return param;
	}
	
	//평량, 가로길이, 세로길이
	function searchValue(flag){
		if(flag == 1){
			if(isNaN($('#BS_WGT').val()))
				return $('#BS_WGT').val('');
		}else if(flag == 2){
			if(isNaN($('#WLEN').val()))
				return $('#WLEN').val('');
		}else{
			if(isNaN($('#VLEN').val()))
				return $('#VLEN').val('');
		}
	}
	
	function searchList(){
		if(validate.check("searchArea")){
			var param = inputList.setRangeParam("searchArea");
	
			param.put("P_TYPE","LIST");
			
			gridList.gridList({
		    	id : "gridList",
		    	param : param
		    });
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
					<!-- <dl>
						<dt CL="STD_MACHINE"></dt>
						<dd>
							<select class="input" id="MACHINE" name="MACHINE" Combo="Produce,MACHINE">
								<option value="">ALL</option>
							</select>
						</dd>
					</dl> -->
					<dl>
						<dt CL="STD_PCODE"></dt>
						<dd>
							<!-- 2023-03-13(월요일) 안상현, 지종코드 RANGE 검색 추가 -->
							<input type="text" name="M001.PCODE" UIInput="SR,PCODE" UIFormat="U"/>
						</dd>
					</dl>
					<dl>
						<dt CL="STD_BS_WGT">평량</dt>
						<dd>
							<!-- 2023-03-13(월요일) 안상현, 평량 RANGE 검색 추가 -->
							<input type="text" class="input" id="BS_WGT" name="M001.BS_WGT" UIInput="SR" onchange="searchValue(1);" />
						</dd>
					</dl>
					<dl>
						<dt CL="STD_WLEN">가로</dt>
						<dd>
							<!-- 2023-03-13(월요일) 안상현, 가로 RANGE 검색 추가 -->
							<input type="text" class="input" id="WLEN" name="M001.WLEN" UIInput="SR" onchange="searchValue(2);" />
						</dd>
					</dl>
					<dl>
						<dt CL="STD_VLEN">세로</dt>
						<dd>
							<!-- 2023-03-13(월요일) 안상현, 세로 RANGE 검색 추가 -->
							<input type="text" class="input" id="VLEN" name="S017.VLEN" UIInput="SR" onchange="searchValue(3);" />
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
					<li>
						<a href="#tab1-1"><span CL="STD_GRD_WRK35">리스트</span></a>
						<!-- 
						<span style="color: black">오더(O), 지시삭제(O)</span>
                   		<span style="color: blue">오더(O), 지시삭제(X)</span>
                   		<span style="color: red">오더(X), 지시삭제(X)</span>
                   		 -->
                    		
					</li>
					<li>
						<span style="display: inline-block; width: 100px;"></span>
						<img src="/common/theme/webdek/images/ico_infor.png" width="15" height="15" style="padding: 10px 0px;" />
                   		<span style="color: red; font-weight: bold; display: inline-block; padding: 10px 0px;">2호기</span>&nbsp;&nbsp;&nbsp;&nbsp;
                   		<span style="color: blue; font-weight: bold; display: inline-block; padding: 10px 0px;">3호기</span>&nbsp;&nbsp;&nbsp;&nbsp;
                   		<span style="color: black; font-weight: bold; display: inline-block; padding: 10px 0px;">밀롤창고 출고</span>
					</li>
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
									<tr CGRow="true" ><td GH="40" GCol="rownum">1</td>
										
										<td GH="0" GCol="text,WRKNM" style='text-align:center;'></td>
										<td GH="120" GCol="text,MR01" style='text-align:center;'></td>
										<td GH="120" GCol="text,MR02" style='text-align:center;'></td>
										<td GH="120" GCol="text,MR03" style='text-align:center;'></td>
										<td GH="120" GCol="text,MR04" style='text-align:center;'></td>
										<td GH="120" GCol="text,MR05" style='text-align:center;'></td>
										<td GH="120" GCol="text,MR06" style='text-align:center;'></td>
										<td GH="120" GCol="text,MR07" style='text-align:center;'></td>
										<td GH="120" GCol="text,MR08" style='text-align:center;'></td>
										<td GH="120" GCol="text,MR09" style='text-align:center;'></td>
										<td GH="120" GCol="text,MR10" style='text-align:center;'></td>
										<td GH="120" GCol="text,MR11" style='text-align:center;'></td>
										<td GH="120" GCol="text,MR12" style='text-align:center;'></td>
										<td GH="120" GCol="text,MR13" style='text-align:center;'></td>
										<td GH="120" GCol="text,MR14" style='text-align:center;'></td>
										<td GH="120" GCol="text,MR15" style='text-align:center;'></td>
										<td GH="120" GCol="text,MR16" style='text-align:center;'></td>
										<td GH="120" GCol="text,MR17" style='text-align:center;'></td>
										<td GH="120" GCol="text,MR18" style='text-align:center;'></td>
										<td GH="120" GCol="text,MR19" style='text-align:center;'></td>
										<td GH="120" GCol="text,MR20" style='text-align:center;'></td>
										<td GH="120" GCol="text,MR21" style='text-align:center;'></td>
										<td GH="120" GCol="text,MR22" style='text-align:center;'></td>
										<td GH="120" GCol="text,MR23" style='text-align:center;'></td>
										<td GH="120" GCol="text,MR24" style='text-align:center;'></td>
										<td GH="120" GCol="text,MR25" style='text-align:center;'></td>
										<td GH="120" GCol="text,MR26" style='text-align:center;'></td>
										<td GH="120" GCol="text,MR27" style='text-align:center;'></td>
										<td GH="120" GCol="text,MR28" style='text-align:center;'></td>
										<td GH="120" GCol="text,MR29" style='text-align:center;'></td>
										<td GH="120" GCol="text,MR30" style='text-align:center;'></td>
										<td GH="120" GCol="text,MR31" style='text-align:center;'></td>
										<td GH="120" GCol="text,MR32" style='text-align:center;'></td>
										<td GH="120" GCol="text,MR33" style='text-align:center;'></td>
										<td GH="120" GCol="text,MR34" style='text-align:center;'></td>
										<td GH="120" GCol="text,MR35" style='text-align:center;'></td>
										<td GH="120" GCol="text,MR36" style='text-align:center;'></td>
										<td GH="120" GCol="text,MR37" style='text-align:center;'></td>
										<td GH="120" GCol="text,MR38" style='text-align:center;'></td>
										<td GH="120" GCol="text,MR39" style='text-align:center;'></td>
										<td GH="120" GCol="text,MR40" style='text-align:center;'></td>
										<td GH="120" GCol="text,MR41" style='text-align:center;'></td>
										<td GH="120" GCol="text,MR42" style='text-align:center;'></td>
										<td GH="130" GCol="text,MR43" style='text-align:center;'></td>
										<td GH="130" GCol="text,MR44" style='text-align:center;'></td>
										<td GH="130" GCol="text,MR45" style='text-align:center;'></td>
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