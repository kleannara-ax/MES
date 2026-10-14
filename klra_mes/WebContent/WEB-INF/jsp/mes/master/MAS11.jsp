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
	    	url : "/mes/Master/MAS11/json/datalist.data",
	    	bigdata : false,
	    	colHoldType : true,
	    	colHold : "MACH_CD,MACH_NM,MACH_SHRT_NM",
	    	selectRowDeleteType : true
	    });
	});

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
	function saveData(){
		if(gridList.getModifyRowCount("gridList") == 0 ){
			commonUtil.msgBox("MASTER_M0545");
			
			return;
		}
		if(!commonUtil.msgConfirm(configData.MSG_MASTER_SAVE_CONFIRM)){
			return;
		}
		if(gridList.validationCheck("gridList", "data")){
			var list = gridList.getModifyData("gridList", "A");

			var param = new DataMap();

			param.put("P_TYPE","SAVE");
			param.put("list", list);

			var json = netUtil.sendData({
				url : "/mes/Master/MAS11/json/datalist.data",
				param : param
			});
			if(json){
				if(json.data){
					commonUtil.msgBox(configData.MSG_SYSTEM_SAVEOK);
					searchList();
				}
			}
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
					<input type="button" id="button-0-2" CB="Save SAVE BTN_SAVE" />
				</div>
			</div>
			<div class="search_inner">
				<div class="search_wrap ">
					<dl>
						<dt CL="STD_PLANT">플랜트</dt>
						<dd>
							<input type="text" class="input" name="WERKS" validate="required" UIInput="S,PLANT" UIFormat="U"/>
						</dd>
					</dl>
					<dl>
						<dt CL="STD_MACH_NM">설비명</dt>
						<dd>
							<input type="text" class="input" name="MACH_NM" UIInput="SR"/>
						</dd>
					</dl>
					<dl>
						<dt CL="STD_PROC_NM">공정명</dt>
						<dd>
							<input type="text" class="input" name="PROC_NM" UIInput="SR"/>
						</dd>
					</dl>
					<dl>
						<dt CL="STD_BUSICD">사업부</dt>
						<dd>
							<select class="input" name="BUSICD" CommonCombo="BUSICD">
								<option value="">All</option>
							</select>
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
					<li><a href="#tab1-1"><span CL="STD_GENERAL">일반</span></a></li>
					<li class="btn_zoom_wrap">
						<ul>
							<li><button class="btn btn_bigger"><span>확대</span></button></li>
						</ul>
					</li>
				</ul>
				<div class="table_box section" id="tab1-1">
					<div class="table_list01">
						<div class="scroll">
							<table class="table_c">
								<tbody id="gridList">
									<tr CGRow="true">
										<td GH="40" GCol="rownum">1</td>
										<td GH="40" GCol="rowCheck"></td>
										<td GH="100" GCol="input,MACH_CD" validate="required" style="text-align:center;">설비코드</td>
										<td GH="160" GCol="input,MACH_NM" validate="required">설비명</td>
										<td GH="100" GCol="input,MACH_SHRT_NM">설비명(단축)</td>
										<td GH="60" GCol="input,PROC_CD,OP" validate="required" style="text-align:center;">공정코드</td>
										<td GH="100" GCol="text,PROC_NM" >공정명</td>
										<td GH="60" GCol="text,PROC_GRP_CD" style="text-align:center;">공정그룹코드</td>
										<td GH="100" GCol="text,PROC_GRP_NM">공정그룹명</td>
										<td GH="70" GCol="text,WERKS" style="text-align:center;">플랜트코드</td>
										<td GH="160" GCol="text,PLANTNM">플랜트명</td>
										<td GH="60" GCol="text,BUSICD" style="text-align:center;">사업부</td>
										<td GH="100" GCol="text,BUSINM">사업부명</td>
										<td GH="70" GCol="text,PROD_GRP_CD" style="text-align:center;">제품군코드</td>
										<td GH="100" GCol="text,PROD_GRP_NM">제품군명</td>
										<td GH="100" GCol="input,INST_DT" GF="MS" style="text-align:center;">도입년월</td>
										<td GH="100" GCol="input,LINE" validate="required" GF="N 2">라인/호기</td>
										<td GH="140" GCol="input,IFMC" style="text-align:right;">인터폴더 호기</td>
										<td GH="100" GCol="input,ASST_NO">자산번호</td>
										<td GH="180" GCol="select,PRD_UNIT">
											<select CommonCombo="UNIT"><!-- 생산단위 -->
												<option value="">All</option>
											</select>
										</td>
										<td GH="100" GCol="input,MACHINE" style="text-align:center;">생산호기</td>
										<td GH="100" GCol="input,DISPO_DT" GF="C">폐기일자</td>
										<td GH="100" GCol="input,SAP_WRK_CD" style="text-align:center;">SAP작업장코드</td>
										<td GH="130" GCol="input,SAP_WRK_NM">SAP작업장명</td>
										<td GH="100" GCol="input,SAP_COST_CD" style="text-align:center;">SAP코스트센터</td>
										<td GH="100" GCol="input,WCS_WRK_CD" style="text-align:center;">WCS설비코드</td>
										<td GH="140" GCol="input,WCS_WRK_NM">WCS설비명</td>
										<td GH="100" GCol="select,PRFM_GTHR_YN">
											<select input="text"><!-- 실적수집여부 -->
												<option value="">All</option>
												<option value="Y">Y</option>
												<option value="N">N</option>
											</select>
										</td>
										<td GH="120" GCol="input,ABN_STD_TM" GF="N 6">비가동기준시간</td>
										<td GH="100" GCol="input,CYCLE_TM" GF="N 6,1">싸이클타임</td>
										<!-- 2022-09-20(화요일) 안상현, 김성하 총괄님 지시로 표시순서 컬럼 추가 -->
										<td GH="100" GCol="input,DISP_SEQ" GF="N 10">표시순서</td>
										<td GH="140" GCol="text,REGDATE" style="text-align:center;">등록일시</td>
										<td GH="100" GCol="text,REGNM">등록자(명)</td>
										<td GH="140" GCol="text,UPDDATE" style="text-align:center;">수정일시</td>
										<td GH="100" GCol="text,UPDNM">수정자(명)</td>
									</tr>
								</tbody>
							</table>
						</div>
					</div>
					<jsp:include page="/WEB-INF/jsp/common/commonBtnAuth.jsp">
						<jsp:param name="authCd" value="1" />
						<jsp:param name="showAuthCd" value="1,2,3,4,5,6,9,10" />
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