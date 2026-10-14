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
				url : "/mes/Work/WRK43/json/datalist.data",
				bigdata : false,
				colHoldType : true,
				colHold : 'WERKS, WRK_ORDR_NO, STOR_LOC_CD, STOR_LOC_NM'
			});
		});

		// 조회
		function searchList(){
			if(validate.check("searchArea")){
				//var range = inputList.setRangeParam("searchArea");
				//var date = range.get('RANGE_DATA_PARAM').get('WRK_REQ_DT_Range').split('↓');
				
				var param = inputList.setRangeParam("searchArea");
				
				param.put("P_TYPE","LIST");
				//param.put('WERKS', range.get('WERKS'));
				//param.put('WRK_ORDR_NO', range.get('WRK_ORDR_NO'));
				//param.put('SDATE', date[1]);
				//param.put('EDATE', date[2]);
				
				gridList.gridList({
					id : "gridList",
					param : param
				});
			}
		}

		// 저장
		function saveData(){
			var list = gridList.getSelectData('gridList');
			
			if(list.length == 0){
				return alert('선택한 항목이 없습니다.');
			}
			
			if(gridList.getModifyRowCount("gridList") == 0 ){
				commonUtil.msgBox("MASTER_M0545");
				return;
			}

			if(gridList.validationCheck("gridList", "all")){
				var param = new DataMap();
				
				param.put("P_TYPE","SAVE");
				param.put("list", list);

				if(!commonUtil.msgConfirm(configData.MSG_MASTER_SAVE_CONFIRM)){
					return;
				}
				
				var json = netUtil.sendData({
					url : "/mes/Work/WRK43/json/datalist.data",
					param : param
				});

				if(json.P_SUCCESS == 'Y'){
					commonUtil.msgBox(configData.MSG_SYSTEM_SAVEOK);
					searchList();
				}
			}
		}


		function commonBtnClick(btnName){
			//commonUtil.debugMsg("commonBtnClick : ", arguments);
			if(btnName == "Search"){
				searchList();
			}else if(btnName == "Save"){
				saveData();
			}
		}
		
		function gridListEventDataBindEnd(gridId, dataLength){
			if(gridId == 'gridList'){
				var list = gridList.getGridData(gridId);
				
				for(var i = 0; i < dataLength; i++){
					if(list[i].get('CHG_UNIT_FLG') == 'N'){
						gridList.setRowReadOnly(gridId, i, true, ['CHG_UNIT_QTY','CHG_UNIT']);
					}
				}
			}
		}
		
		function gridListEventColValueChange(gridId, rowNum, colName, colValue){
			if(gridId == 'gridList'){
				if(colName == 'CHG_UNIT_FLG'){
					if(colValue == 'Y'){
						gridList.setRowReadOnly(gridId, rowNum, false, ['CHG_UNIT_QTY','CHG_UNIT']);
					}else{
						gridList.setRowReadOnly(gridId, rowNum, true, ['CHG_UNIT_QTY','CHG_UNIT']);
					}
				}
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
					<input type='button' id='button-0-2' CB='Save SAVE BTN_SAVE'/>
					<input type="button" id="button-0-3" CB="Decide SAVE BTN_DECIDE" />
					<input type="button" id="button-0-4" CB="Aprrove APPLY BTN_APPROVE" />
					<input type="button" id="button-0-5" CB="Cancel DELETE BTN_CANCEL" />
				</div>
			</div>
			<div class="search_inner">
				<div class="search_wrap ">
					<dl>
						<dt CL="STD_PLANT">플랜트</dt>
						<dd>
							<input type="text" class="input" id="WERKS" name="WERKS" UIInput="SR,PLANT" UIFormat="U" validate="required"/>
						</dd>
					</dl>
					<!-- <dl>
						<dt CL="지시일자">지시일자</dt>
						<dd>
							<input type="text" class="input" name="WRK_REQ_DT" UIInput="B" UIFormat="C M1" validate="required"/>
						</dd>
					</dl> -->
					<dl>
						<dt CL="STD_WRK_ORDR_NO">실사지시번호</dt>
						<dd>
							<input class="input" type="text" id="WRK_ORDR_NO" name="WRK_ORDR_NO" UIInput="SR" UIFormat="U" validate="required"/>
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
					<li><a href="#tab1-1"><span CL="STD_GRD_WRK43">리스트</span></a></li>
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
										<td GH="100" GCol="text,WERKS" style="text-align:center;"></td>
										<td GH="100" GCol="text,WRK_ORDR_NO" style="text-align:center;"></td>
										<td GH="100" GCol="text,STOR_LOC_CD" style="text-align:center;">저장위치코드</td>
										<td GH="100" GCol="text,STOR_LOC_NM" style="text-align:center;">저장위치명</td>
										<!-- 20230216 여한진 하위 3개 컬럼 추가-->
										<td GH='100' GCol='text,LOC_CD' style='text-align:center;'>로케이션코드</td>
										<td GH='100' GCol='text,LOC_NM' style='text-align:center;'>로케이션명</td>
										<td GH='100' GCol='text,STCK_STA' style='text-align:center;'>재고상태</td>
										
										<td GH="120" GCol="text,LOT_NO" style="text-align:center;"></td>
										<td GH="140" GCol="text,IND_BCD" style="text-align:center;"></td>
										<td GH="140" GCol="text,MATNR" style="text-align:center;"></td>
										<td GH="320" GCol="text,MATNR_NM" style="text-align:center;"></td>
										
										<td GH="100" GCol="text,UNIT">단위</td>
										
										<td GH="100" GCol="text,STCK_QTY" GF="N 13,3"></td>
										<td GH="100" GCol="text,REAL_INSP_QTY" GF="N 13,3"></td>
										<td GH="100" GCol="text,DIFF_QTY" GF="N 13,3"></td>
										<td GH="100" GCol="input,CHG_STCK_QTY" GF='N 13,3'>수량보정</td>
										<td GH="100" GCol="select,CHG_UNIT_FLG">
											<select style="text-align:center;">대체단위여부
												<option value='N'>N</option>
												<option value='Y'>Y</option>
											</select>
										</td>
										<td GH="100" GCol="input,CHG_UNIT_QTY" GF="N 13,3"></td>
										<td GH="180" GCol="select,CHG_UNIT" style="text-align:center;">
											<select CommonCombo='UNIT' style="text-align:center;"></select>
										</td>
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
<!-- // content -->
<%@ include file="/common/include/webdek/bottom.jsp" %>
</body>
</html>
