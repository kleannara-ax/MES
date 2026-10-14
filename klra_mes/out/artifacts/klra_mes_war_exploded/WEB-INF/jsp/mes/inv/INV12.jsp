<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Grid default</title>
<%@ include file="/common/include/webdek/head.jsp"%>
<link rel="stylesheet" type="text/css"
	href="/common/theme/webdek/css/demo_layout.css">
<script type="text/javascript">
	var reqdiv;	//요청구분
	
	$(document).ready(function(){
		gridList.setGrid({
			id : "gridList",
			url : "/mes/Inv/INV12/json/datalist.data",
			bigdata : false,
	    	colHoldType : true,
	    	colHold : "WDOC_NO, WDOC_SEQNO, WERKS, MATNR"
	    });
	});
	
	// 조회
	function searchList(){
		if(validate.check("searchArea")){
			// 2023-03-13(월요일) 안상현, Range 검색 추가
			/* const range = inputList.setRangeParam("searchArea")
			const range_data_param = range.get("RANGE_DATA_PARAM")
			const rcvcdsDt = range_data_param.get("RCVCDS_DT_Range")
			const date = rcvcdsDt.split("↓")
			const SDate = date[1]
			const EDate = date[2] */
			
			const param = inputList.setRangeParam("searchArea")
			param.put("P_TYPE", "LIST")
			/* param.put("WERKS", range.get("WERKS"))
			param.put("MATNR", range.get("MATNR"))
			param.put("CNL_GU",$("#CNL_GU").val())
			param.put("SDATE", SDate)
			param.put("EDATE", EDate)
			param.put("WDOC_NO", range.get("WDOC_NO")) */
			
			gridList.gridList({
		    	id : "gridList",
		    	param : param
		    })
			/* 
			var range = inputList.setRangeParam("searchArea");
			var range_data_param = range.get("RANGE_DATA_PARAM");
			var rcvcdsDt = range_data_param.get("RCVCDS_DT_Range");
			var date = rcvcdsDt.split('↓');
			var SDate = date[1];
			var EDate = date[2];
			
			var param = new DataMap();
			
			param.put("P_TYPE", "LIST");
			param.put("WERKS", range.get('WERKS'));
			param.put("MATNR", range.get('MATNR'));
			param.put("CNL_GU",$("#CNL_GU").val());
			param.put("SDATE", SDate);
			param.put("EDATE", EDate);
			param.put('WDOC_NO', range.get('WDOC_NO'));
			
			gridList.gridList({
		    	id : "gridList",
		    	param : param
		    });
			*/
		}
	}
	 
	function savedata(){
		if(gridList.validationCheck("gridList", "all")){
			var list = gridList.getSelectData("gridList");
			if(list.length === 0){
				alert("선택된 항목이 없습니다.")
				return
			}
			
			if(!commonUtil.msgConfirm("저장하시겠습니까?")){
				return;
			}
			var param = new DataMap();
			
			param.put("P_TYPE", "SAVE");
			param.put("list", list);

			netUtil.send({
		    	url : "/mes/Inv/INV12/json/datalist.data",
		    	param : param,
		    	successFunction : 'saveSuccessCallBack'
		    });
		}
	}
	
	function saveSuccessCallBack(json){
		if(json.P_SUCCESS == 'Y'){
			alert('저장되었습니다.');
			searchList();
		}else{
			alert(json.MSG);
		}
	}
	
	//요청취소
	function cancel(){
		if(gridList.validationCheck("gridList", "all")){
			var list = gridList.getSelectData("gridList");
			if(list.length === 0){
				alert("선택된 항목이 없습니다.")
				return
			}
			
			if(!commonUtil.msgConfirm("요청 취소하시겠습니까?")){
				return;
			}
			
			var list = gridList.getSelectData("gridList");
			var param = new DataMap();
			
			param.put("P_TYPE", "DELETE");
			param.put("list", list);

			netUtil.send({
		    	url : "/mes/Inv/INV12/json/datalist.data",
		    	param : param,
		    	successFunction : 'saveSuccessCallBack2'
		    });
		}
	}
	
	function saveSuccessCallBack2(json){
		if(json.P_SUCCESS == 'Y'){
			alert('요청 취소되었습니다.');
			searchList();
		}else{
			alert(json.MSG);
		}
	}
	
	// 버튼을 클릭한 경우
	function commonBtnClick(btnName){
		if(btnName == "Search"){
			searchList();
		}else if(btnName == "Save"){
			savedata();
		}else if(btnName == "Cancel"){
			cancel();
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
						<input type="button" id="button-0-1" CB="Search SEARCH BTN_SEARCH" />
						<input type="button" id="button-0-2" CB="Save SAVE BTN_SAVE" />
						<input type="button" id="button-0-3" CB="Cancel DELETE BTN_ORDERCANCEL" />
					</div>
				</div>
				<div class="search_inner">
					<div class="search_wrap">
						<dl>
							<dt CL="STD_PLANT">플랜트</dt>
							<dd>
								<input type="text" class="input" id="WERKS" name="WERKS" UIInput="S,PLANT" UIFormat="U" validate="required" />
							</dd>
						</dl>
						<dl>
							<dt>입고일자</dt>
							<dd>
								<input type="text" id="RCVCDS_DT" name="RCVCDS_DT" UIInput="B" UIFORMAT="C M1" />
							</dd>
						</dl>
						<dl>
							<dt CL="STD_WDOC_NO">WMS 문서번호</dt>
							<dd>
								<!-- 2023-03-13(월요일) 안상현, WMS 문서번호 RANGE 검색 추가 -->
								<input type="text" class="input" id="WDOC_NO" name="WDOC_NO" UIInput="SR" UIFormat="U" />
							</dd>
						</dl>
						<dl>
							<dt CL="STD_MATNR">자재코드</dt>
							<dd>
								<!-- 2023-03-13(월요일) 안상현, 자재코드 RANGE 검색 추가 -->
								<input type="text" id="MATNR" name="MATNR" UIInput="SR,MATKY" UIFormat="U" />
							</dd>
						</dl>
						<dl>
							<dt>취소여부</dt>
							<dd>
								<select class="input" id='CNL_GU' name="CNL_GU">
									<option value="">ALL</option>
									<option value="N">투입</option>
									<option value="R">투입 취소 요청</option>
									<option value="Y">투입 취소 완료</option>
								</select>
							</dd>
						</dl>
					</div>
					<div class="btn_tab">
						<input type="button" class="btn_more" value="more"
							onclick="searchMore()" />
					</div>
				</div>
			</div>
			<div class="search_next_wrap">
			<div class="content_layout tabs">
				<ul class="tab tab_style02">
					<li><a href="#tab1-1"><span>일반</span></a></li>
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
											<td GH="100" GCol="text,WDOC_NO" style="text-align:center;">WMS문서번호</td>
											<td GH="100" GCol="text,WDOC_SEQNO" style="text-align:center;">WMS 문서순번</td>
											<td GH="100" GCol="text,WERKS" style="text-align: center;">플랜트</td>
											<td GH="140" GCol="text,MATNR" style="text-align: center;">자재코드</td>
											<td GH="320" GCol="text,MATNR_NM">자재명</td>
											<td GH="100 입고량" GCol="text,QTY" GF="N 13,3">요청수량</td>
											<td GH="80" GCol="text,UNIT" style="text-align: center;">단위</td>
											<td GH="100" GCol="text,STOR_LOC_FR" style="text-align:center;">저장위치 From</td>
											<td GH="100" GCol="text,STOR_LOC_TO" style="text-align:center;">저장위치 To</td>
											<td GH="100" GCol="text,PRDC_DT" GF="D" style="text-align:center;">제조일자</td>
											<td GH="100" GCol="text,RCVCDS_DT" GF="D" style="text-align:center;">입고일자</td>	
											<td GH="100" GCol="text,DSTBT_DDLIN" GF="D" style="text-align: center;">유통기한</td>
											<td GH="120" GCol="text,IND_BCD" style="text-align: center;">개별바코드</td>
											<td GH="120" GCol="text,LOT_NO" style="text-align: center;">LOT NO</td>
											<td GH="150" GCol="text,STOK_KY" style="text-align: center;">WMS 재고 KEY</td>
											<td GH="150" GCol="text,LOT_NUM" style="text-align: center;">WMS LOT속성</td>
											<td GH="140" GCol="text,REGDATE" style="text-align:center;">등록일시</td>	
											<td GH="0" GCol="text,CNL_YN">취소여부</td>
											<td GH="100" GCol="text,CNL_YN_NM">취소여부(명)</td>
											<td GH="100 투입취소일자" GCol="text,CNL_DT" GF="D" style="text-align:center;"></td>
											<td GH="100 투입취소등록자" GCol="text,CNL_REGID" style="text-align:center;"></td>
											<td GH="140 투입취소등록일시" GCol="text,CNL_REGDATE" style="text-align:center;"></td>
											<td GH="140 투입취소수정일시" GCol="text,CNL_UPDDATE" style="text-align:center;"></td>
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
<!-- // content -->
<%@ include file="/common/include/webdek/bottom.jsp"%>
</body>
</html>