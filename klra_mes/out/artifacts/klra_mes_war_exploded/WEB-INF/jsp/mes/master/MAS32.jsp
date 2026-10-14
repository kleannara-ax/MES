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
	    	url : "/mes/Master/MAS32/json/datalist.data",
	    	bigdata : false
	    });
		
		gridList.setGrid({
			id : "gridList2",
	    	url : "/mes/Master/MAS32/json/datalist.data",
	    	bigdata : false,
	    	colHoldType : true,
	    	colHold : "INSP_ITEM_CD,INSP_ITEM_NM,MID_CAT_NM,BIG_CAT_NM"
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
			gridList.resetGrid("gridList2");
		}
	}
	
	function searchSubList(headRowNum){
		var MATNR = gridList.getColData("gridList", headRowNum, "MATNR");
		var WERKS = gridList.getColData("gridList", headRowNum, "WERKS");
		var param = inputList.setRangeParam("searchArea");
		param.put("P_TYPE", "SUB_LIST");
		param.put("MATNR", MATNR);
		param.put("WERKS", WERKS);
		
		gridList.gridList({
			id : "gridList2",
			param : param
		});

		lastFocusNum = headRowNum; //2020.04.13 LHJ 오류수정
		dblIdx = headRowNum;
		
		$("#MATNR").val(MATNR);
		$("#WERKS").val(WERKS);
	}
	
	function gridListEventRowDblclick(gridId, rowNum){
		if(gridId == "gridList"){
			dblIdx = rowNum;

			searchSubList(rowNum);
		}
	}
	
	function gridListEventDataBindEnd(gridId, dataLength){
		if(gridId == "gridList2"){
			var data = gridList.getGridData(gridId);
			
			for(var i = 0; i < dataLength; i++){
				var inptTyp = data[i].get("INPT_TYP");
				
				if(inptTyp == "숫자"){
					gridList.setRowReadOnly(gridId, i, true, ["STD_SEL", "INSP_STD_1", "INSP_STD_2"]);
				} else if(inptTyp == "문자열"){
					gridList.setRowReadOnly(gridId, i, true, ["STD_VAL", "UPP_VAL", "LOW_VAL", "STD_SEL"]);
				} else{
					gridList.setRowReadOnly(gridId, i, true, ["STD_VAL", "UPP_VAL", "LOW_VAL", "INSP_STD_1", "INSP_STD_2"]);
				}
			}
		}
	}
	
	function saveData(){
		// 2022-08-29(월요일) 안상현, CHECK된 HEAD 리스트
		const head = gridList.getSelectData("gridList")
		if(head.length === 0){
			alert("선택된 자재가 없습니다.")
			return
		}
		
		if(gridList.getModifyRowCount("gridList2") == 0 && gridList.getModifyRowCount("gridList") == 0){
			commonUtil.msgBox("MASTER_M0545");
			
			return;
		}
		if(!commonUtil.msgConfirm(configData.MSG_MASTER_SAVE_CONFIRM)){
			return;
		}
		if(gridList.validationCheck("gridList2", "all")){
			// 2022-08-29(월요일) 안상현, CHECK된 HEAD 리스트
			// var head = gridList.getRowData("gridList", gridList.getFocusRowNum("gridList"));
			var list = gridList.getSelectData("gridList2");
			
			var param = new DataMap();
			
			param.put("P_TYPE","SUB_SAVE");
			param.put("head", head);
			param.put("list", list);
			param.put("INSP_ITEM_GRP_CD","H3");
			
			var json = netUtil.sendData({
				url : "/mes/Master/MAS32/json/datalist.data",
				param : param
			});
			
			if(json){
				if(json.data){
					commonUtil.msgBox(configData.MSG_SYSTEM_SAVEOK);
					gridList.resetGrid("gridList2");
					searchList();
				}
			}
			
		}
	}
	
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
						<dt CL="STD_MATNR">자재코드</dt>
						<dd>
							<input type="text" name="MATNR" UIInput="SR,MATKY" UIFormat="U"/>
						</dd>
					</dl>
					<dl>
						<dt CL="STD_MATNR_NM">자재명</dt>
						<dd>
							<input type="text" class="input" name="MATNR_NM" UIInput="SR"/>
						</dd>
					</dl>
					<dl>
						<dt CL="STD_REG_YN">등록여부(Y/N)</dt>
						<dd>
							<select class="input" name="REG_YN">
								<option value="">All</option>
								<option value="Y">Y</option>
								<option value="N">N</option>
							</select>
						</dd>
					</dl>
					<dl>
						<dt CL="STD_PART_DIV">품목</dt>
						<dd>
							<select class="input" name="PART_DIV" CommonCombo="PART_DIV">
								<option value="">선택</option>
							</select>
						</dd>
					</dl>
				</div>
				<div class="btn_tab">
					<input type="button" class="btn_more" value="more" onclick="searchMore()"/>
				</div>
			</div>
		</div>
        <div class="content-horizontal-wrap" style="height: calc(100% - 85px);">
			<div class="content_layout tabs" style="float: left; width: calc(35% - 10px);">
				<ul class="tab tab_style02">
					<li><a href="#tab1-1"><span CL="STD_GENERAL"></span></a></li>
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
										<td GH="40" GCol="rowCheck"></td>
										<td GH="100" GCol="text,WERKS" style="text-align:center;">플랜트코드</td>
										<td GH="180" GCol="text,MATNR" style="text-align:center;">자재코드</td>
										<td GH="320" GCol="text,MATNR_NM">자재명</td>
										<td GH="0" GCol="text,INSP_ITEM_GRP_CD">검사항목그룹코드</td>
										<td GH="80" GCol="text,REG_YN">등록여부(Y/N)</td>
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
			<div class="content_layout tabs" style="float: right; width: calc(65% - 10px);">
				<ul class="tab tab_style02">
					<li><a href="#tab1-2"><span CL="STD_DETAIL"></span></a></li>
					<li class="btn_zoom_wrap">
						<ul>
							<li><button class="btn btn_bigger"><span>확대</span></button></li>
						</ul>
					</li>
				</ul>
				<div class="table_box section" id="tab1-2">
					<div class="table_list01">
						<div class="scroll">
							<table class="table_c">
								<tbody id="gridList2">
									<tr CGRow="true">
										<td GH="40" GCol="rownum">1</td>
										<td GH="40" GCol="rowCheck"></td>
										<td GH="0" GCol="text,INSP_ITEM_CD" style="text-align:center;">검사항목코드</td>
										<td GH="140" GCol="text,INSP_ITEM_NM">검사항목명</td>
										<td gh="140" GCol="text,MID_CAT_NM">중분류명</td> 
										<td gh="140" GCol="text,BIG_CAT_NM">대분류명</td>
										<td GH="80" GCol="text,MSRM_CYC">측정주기</td>
										<td GH="80" GCol="text,MSRM_ACC">측정차수</td>
										<td GH="80" GCol="text,INPT_TYP">입력타입</td>
										<td GH="80" GCol="text,INPT_MTD">입력방법	</td>
										<td GH="80" GCol="text,MSRM_MTD">측정방법</td>
										<td GH="80" GCol="text,MSRM_UNIT">측정단위</td>
										<td GH="100" GCol="input,STD_VAL" GF="N 9,2">기준값</td>
										<td GH="100" GCol="input,UPP_VAL" GF="N 9,2">규격상한치</td>
										<td GH="100" GCol="input,LOW_VAL" GF="N 9,2">규격하한치</td>
										<td GH="100" GCol="input,STD_SEL">기준 선택값</td>
										<td GH="140" GCol="input,INSP_STD_1">검사기준(1)</td>
										<td GH="140" GCol="input,INSP_STD_2">검사기준(2)</td>
										<td GH="140" GCol="text,REGDATE" style="text-align:center;">등록일시</td>
										<td GH="100" GCol="text,REGNM">등록자</td>
										<td GH="140" GCol="text,UPDDATE" style="text-align:center;">수정일시</td>
										<td GH="100" GCol="text,UPDNM">수정자</td>
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