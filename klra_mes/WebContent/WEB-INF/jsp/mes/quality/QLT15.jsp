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
			url : "/mes/Quality/QLT15/json/datalist.data",
			bigdata : false,
			colHoldType : true,
			colHold : "WERKS, MSRM_DATE, PRC_SEQNO"
	    });
	});

	function searchList(){
		if(validate.check("searchArea")){
			/* var range = inputList.setRangeParam("searchArea");
			var range_data_param = range.get("RANGE_DATA_PARAM");
			var msrm_date = range_data_param.get("MSRM_DATE_Range");
			var date = msrm_date.split('↓');
			var SDate = parse(date[1]);
			var EDate = parse(date[2]);
			
			var matnr = range_data_param.get("MATNR_Single");
			var matnr_str = matnr == undefined ? '' : matnr.split('↓');
			var Matnr = "";
			
			for(var i = 0; i < matnr_str.length; i++){
				if(matnr_str[i].indexOf('E') == 0 || matnr_str[i].indexOf('OR') == 0){
					continue;
				}
				if(matnr_str[i].includes('%')){
					Matnr = Matnr + '^' + matnr_str[i].slice(0,-1) + '|';
				}else{
					Matnr = Matnr + '^' + matnr_str[i] + '|';	
				}
			} */
			
			var param = inputList.setRangeParam("searchArea");
			
			param.put("P_TYPE", "LIST");
			/* param.put("WERKS", $("#WERKS").val().toUpperCase());
			param.put("SDATE", SDate);
			param.put("EDATE", EDate);
			param.put("MATNR", Matnr.replace(',',"")); */
			
			gridList.gridList({
		    	id : "gridList",
		    	param : param
		    });
		}
	}
	
	/* function parse(str){
		var y = str.substr(0, 4);
		var m = str.substr(4, 2);
		var d = str.substr(6, 2);
		var h = "00";
		var mm = "00";
		var s = "00";
		
		return y + '-' + m + '-' + d + ' ' + h + ':' + mm + ':' + s;
	} */
	
	function gridListEventDataBindEnd(gridId, dataLength){
		if(gridId == "gridList"){
			var list = gridList.getGridData(gridId);
			
			for(var i = 0; i < dataLength; i++){
				var upddate = list[i].get("UPDDATE");
				
				if(upddate != ""){
					gridList.setRowReadOnly(gridId, i, true, ["UCFMTY_AMT", "DEPT_CD", "PRC_MTD", "RMK"]);
				}
			}
		}
	}
	
	function gridListEventColValueChange(gridId, rowNum, colName, colValue){
		if(colName === "UCFMTY_AMT"){
			// UCFMTY_AMT : 부적합량
			if(Number(colValue) > Number(gridList.getColData(gridId, rowNum, "PRFM_QTY"))){
				alert("부적합량이 실적량보다 큽니다.")
				gridList.setColValue(gridId, rowNum, "UCFMTY_AMT", '')
     			gridList.setRowCheck(gridId, rowNum, false)
     			gridList.setRowState(gridId, configData.GRID_ROW_STATE_READ, rowNum)
     			gridList.reloadAll(gridId);
				return
			 }
		 }
  	}
	
	function saveData() {
		if(gridList.validationCheck("gridList", "all")){
			/* 
			if(gridList.getModifyRowCount("gridList") == 0 ){
				commonUtil.msgBox("MASTER_M0545");
				return;
			}
			*/
			
			var list = gridList.getSelectData("gridList");
			console.log("## saveData() > list = ", list);

			// validation 추가 - 2024/08/01 김지은 선임 요청, 강지선 작업
			if ((list != null) && (list != undefined)) {
				if (list.length > 0) {
					for(let i = 0; i < list.length; i++){
						// 실적량 = 0인 항목이 있으면 return - 2024/08/01 김지은 선임 요청, 강지선 작업
						if(list[i].get("PRFM_QTY") === "" || list[i].get("PRFM_QTY") === " " || list[i].get("PRFM_QTY") === "0" || list[i].get("PRFM_QTY") === "0.000"){
							alert("> 개별바코드 : " + list[i].get("IND_BCD") + "\r\n\r\n해당 자재는 사용되었습니다.")
							return;
						}

						// 부적합량 CHECK
						if (list[i].get("UCFMTY_AMT") === "" || list[i].get("UCFMTY_AMT") === " " || list[i].get("UCFMTY_AMT") === "0" || list[i].get("UCFMTY_AMT") === "0.000") {
							alert("부적합량을 입력하세요. \n부적합처리 후 품질재검사에서 수정할 수 있습니다.")
							return;
						}
					}

					if(!commonUtil.msgConfirm(configData.MSG_MASTER_SAVE_CONFIRM)){
						return;
					}
					
					var param = new DataMap();
					
					param.put("P_TYPE", "SAVE");
					param.put("list", list);
					
					var json = netUtil.sendData({
						url : "/mes/Quality/QLT15/json/datalist.data",
						param : param
					});
					
					if(json){
						if(json.data){
							commonUtil.msgBox(configData.MSG_SYSTEM_SAVEOK);
							searchList();
						}
					}
				} else {
					alert("처리할 자재를 선택해 주세요.")
					return;
				}
			} else {
				alert("처리할 자재를 선택해 주세요.")
				return;
			}
			return;
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
					<input type="button" id="button-0-2" CB="Save SAVE BTN_SAVE"/>
				</div>
			</div>
			<div class="search_inner">
				<div class="search_wrap ">
				  	<dl>
						<dt CL="STD_PLANT">플랜트</dt>
						<dd>
							<input type="text" id="WERKS" name="WERKS" validate="required" UIInput="S,PLANT" UIFormat="U"/>
						</dd>
					</dl>
					<dl>
						<dt CL="STD_MSRM_DATE">측정일시</dt>
						<dd>
							<input type="text" id="MSRM_DATE" name="MSRM_DATE" UIInput="B" UIFormat="C M1"/>
						</dd>
					</dl>
					<dl>
						<dt CL="STD_MATNR">자재코드</dt>
						<dd>
							<input type="text" name="MATNR" UIInput="SR,MATKY" UIFormat="U"/>
						</dd>
					</dl>
					<dl>
                        <dt CL="STD_REG_YN">등록여부</dt>
                        <dd>
                            <select class="input" name="REG_YN">
                            	<option value="">All</option>
                            	<option value="Y">Y</option>
                            	<option value="N">N</option>
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
					<li><a href="#tab1-1"><span CL="STD_GRD_QLT15">부적합리스트</span></a></li>
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
										<td GH="100" GCol="text,WERKS" style="text-align:center;">플랜트</td>
										<td GH="140" GCol="text,MSRM_DATE" style="text-align:center;">측정일시</td>
										<td GH="0" GCol="text,PRC_SEQNO">처리순번</td>
										<td GH="140" GCol="text,MATNR" style="text-align:center;">자재코드</td>
										<td GH="320" GCol="text,MATNR_NM">자재명</td>
										<td GH="100" GCol="text,LOT_NO" style="text-align:center;">LOT번호</td>
										<td GH="120" GCol="text,IND_BCD" style="text-align:center;">개별바코드</td>
										<td GH="0" GCol="text,VND_LOT_NO" style="text-align:center;">업체LOT번호</td>
                                    	<td GH="0" GCol="text,SUPY_VND_BCD" style="text-align:center;">공급업체바코드</td>
                                    	<td GH="100" GCol="text,UNIT" style="text-align:center;">단위</td>
										<td GH="100" GCol="text,UNIT_NM">단위(명)</td>
										<td GH='100' GCol='text,PRFM_QTY' GF="N 13,3">(재고)실적수량</td>
										<td GH="100" GCol="input,UCFMTY_AMT" GF="N 5,3" validate="required">부적합량</td>
										<td GH="100" GCol="input,DEPT_CD,DEPT" validate="required">부서코드</td>
										<td GH="0" GCol="text,FNL_JDGM_NM">최종판정(명)</td>
										<td GH="110" GCol="select,PRC_MTD">
											<select CommonCombo="PRC_MTD"><!-- 처리방법 -->
												<option value=""></option>
											</select>
										</td>
										<td GH="0" GCol="text,REG_YN">등록여부</td>
										<td GH="200" GCol="input,RMK" GF="S 100">비고</td>
										<td GH="0" GCol="text,STOR_LOC_CD" style="text-align:center;">저장위치</td>
										<td GH="0" GCol="text,STOR_LOC_NM">저장위치명</td>
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
						<jsp:param value="1" name="authCd"/>
						<jsp:param value="1,2,3,7,9,10" name="showAuthCd"/>
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