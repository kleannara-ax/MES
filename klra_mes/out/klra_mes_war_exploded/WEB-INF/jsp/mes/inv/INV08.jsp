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
			url : "/mes/Inv/INV08/json/datalist.data",
			bigdata : false,
	    	colHoldType : true,
	    	colHold : "DOC_NO, DOC_SEQ, REQ_DIV,REQ_DT, DLFL,IF_STA, WERKS"
	    });
		
		gridList.setGrid({
			id : "gridList2",
			url:"/mes/Inv/INV08/json/datalist.data",
			bigdata : false
		});
	});
	
	// 조회
	function searchList(){
		if(validate.check("searchArea")){
			// 2023-03-13(월요일) 안상현, Range 검색 추가
			/* const range = inputList.setRangeParam("searchArea")
			const range_data_param = range.get("RANGE_DATA_PARAM")
			const req_dt = range_data_param.get("REQ_DT_Range")
			const date = req_dt.split("↓")
			const SDate = date[1]
			const EDate = date[2] */
			
			const param = inputList.setRangeParam("searchArea")
			param.put("P_TYPE", "LIST")
			/* param.put("WERKS", range.get("WERKS"))
			param.put("MATNR", range.get("MATNR"))
			param.put("MATNR_DIV",$("#MATNR_DIV").val())
			param.put("SDATE", SDate)
			param.put("EDATE", EDate)
			param.put("REQ_DIV",$("#REQ_DIV").val()) 	// 요청구분
			param.put("DLFL",$("#DLFL").val()) 			// 삭제구분
			param.put("IF_STA",$("#IF_STA").val()) 		// 전송상태
			param.put("LOT_NO", range.get("LOT_NO"))
			param.put("INOUT_GU", range.get("INOUT_GU")) */
			
			gridList.gridList({
		    	id : "gridList",
		    	param : param
		    });
			/*
			var range = inputList.setRangeParam("searchArea");
			var range_data_param = range.get("RANGE_DATA_PARAM");
			var req_dt = range_data_param.get("REQ_DT_Range");
			var date = req_dt.split('↓');
			var SDate = date[1];
			var EDate = date[2];
			
			var param = new DataMap();
			
			param.put("P_TYPE", "LIST");
			param.put("WERKS", range.get('WERKS'));
			param.put("MATNR", range.get('MATNR'));
			param.put("MATNR_DIV",$("#MATNR_DIV").val());
			param.put("SDATE", SDate);
			param.put("EDATE", EDate);
			
			// 2022-10-17(월요일) 안상현, 검색조건 추가
			param.put("REQ_DIV",$("#REQ_DIV").val()) 	// 요청구분
			param.put("DLFL",$("#DLFL").val()) 			// 삭제구분
			param.put("IF_STA",$("#IF_STA").val()) 		// 전송상태
			
			param.put('LOT_NO', range.get('LOT_NO'));
			param.put('INOUT_GU', range.get('INOUT_GU'));
			
			gridList.gridList({
		    	id : "gridList",
		    	param : param
		    });
			*/
		}
	}
	 
	//요청취소
	function cancel(){
	 	var json = netUtil.sendData({
    		module : 'mes',
    		command : 'SYSTEMCHECK',
    		sendType : 'map'
    	});
    	
    	if(json.data.USE_YN == 'Y'){
    		alert('시스템 점검 중입니다. 1 ~ 5분 동안 잠시만 기다려 주세요.');
    		return;
    	}
	 
		if(gridList.validationCheck("gridList", "all")){
			var list = gridList.getSelectData("gridList");
			if(list.length === 0){
				alert("선택된 항목이 없습니다.")
				return
			}
			
			for(var i = 0; i < list.length; i++){
				if(list[i].get('DLFL') == '삭제'){
					alert((i + 1) + '번째 요청한 항목이 이미 삭제가 되서 처리할 수 없습니다.');
					return;
				}
				if(list[i].get('IF_STA') == '완료'){
					alert((i + 1) + '번째 요청한 항목이 이미 완료처리가 되서 처리할 수 없습니다.');
					return;
				}
				if(i > 0){
					if(list[i - 1].get('REQ_DIV') != list[i].get('REQ_DIV')){
						alert('요청구분이 같은 것만 처리가능합니다.');
						return;
					}
				}
				reqdiv = list[i].get('REQ_DIV');
			}
			
			if(!commonUtil.msgConfirm("요청 취소하시겠습니까?")){
				return;
			}
			
			var list = gridList.getSelectData("gridList");
			var param = new DataMap();
			
			param.put("P_TYPE", "SAVE");
			param.put("list", list);

			netUtil.send({
		    	url : "/mes/Inv/INV08/json/datalist.data",
		    	param : param,
		    	successFunction : 'saveSuccessCallBack'
		    });
		}
	}
	 
	function saveSuccessCallBack(json){
		if(json.P_SUCCESS == 'Y'){
			InterfaceSendDoc(json.DOC_NO1);
		}else{
			alert(json.ERR_MSG);
		}
		searchList();
	}
	
	// 행 더블 클릭
	function gridListEventRowDblclick(gridId, rowNum){
		if(gridId === "gridList") searchSubList(gridId, rowNum)
	}
	
	//상세정보 조회
	function searchSubList(gridId, rowNum){
		var list = gridList.getRowData(gridId, rowNum);
		
		var param = new DataMap();
		
		param.put("P_TYPE", "SUB_LIST");
		param.put("list", list);		
		
		gridList.gridList({
			id : "gridList2",
			param : param
		});
	}
	
	// 버튼을 클릭한 경우
	function commonBtnClick(btnName){
		if(btnName == "Search"){
			searchList();
		}else if(btnName == "Cancel"){
			cancel();
		}
	}
	
	const InterfaceSendDoc = (DOC_NO) => {
		// 헤더(HEADER) 부분의 포커스 행의 플랜트코드 데이터
		const werks = gridList.getColData("gridList", gridList.getFocusRowNum("gridList"), "WERKS")
		
		let ifid = ""
		if(reqdiv == '불출요청'){
			// 음성공장
			if(werks === "P500"){ 
				ifid = "MES_IF_203"
			// 청주공장
			}else{ 
				ifid = "MES_IF_201"
			}
		}else{
			ifid = 'MES_IF_400';
		}
		//const data = datas[0]
		
		var docno = DOC_NO.split(',');
		var message = '';
		
		//20220808 여한진 WMS에 불출요청 로직 수정
		for(i = 0; i < docno.length; i++){
			var json = netUtil.sendData({
				url : "/common/api/json/"+ifid+"/send.data",
				//param : "DOC_NO=" + data["DOC_NO"]
				param : "DOC_NO=" + docno[i]
			});
			
			if(json){
				if(json.result === "SUCCESS"){
					//alert("발송 성공");
				}else {
					if(reqdiv == '불출요청'){
						message = '(WMS 불출 요청취소)' + (i + 1) + '번째 오류는 ' + json.result + '\n' + message;
					}else{
						message = '(WMS 반납 요청취소)' + (i + 1) + '번째 오류는 ' + json.result + '\n' + message;
					}
				}
			}
		}
		if(message == ''){
			alert('요청취소되었습니다.');
		}else{
			alert(message);
			message = '';
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
						<input type="button" id="button-0-1" CB="Cancel DELETE BTN_ORDERCANCEL" />
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
							<dt>요청일자</dt>
							<dd>
								<input type="text" id="REQ_DT" name="REQ_DT" UIInput="B" UIFORMAT="C M1" />
							</dd>
						</dl>
						<dl>
							<dt CL="STD_MATNR">자재코드</dt>
							<dd>
								<!-- 2023-03-13(월요일) 안상현, Range 검색 추가 -->
								<input type="text" id="MATNR" name="MATNR" UIInput="SR,MATKY" UIFormat="U" />
							</dd>
						</dl>
						<dl>
							<dt>자재유형</dt>
							<dd>
								<select class="input" id="MATNR_DIV" name="MATNR_DIV" CommonCombo="MATNR_DIV">
									<option value="">ALL</option>
								</select>
							</dd>
						</dl>
						<!-- 2022-10-17(월요일) 안상현, 요청구분 검색조건 추가 -->
						<dl>
							<dt>요청구분</dt>
							<dd>
								<select class="input" id="REQ_DIV" name="REQ_DIV">
									<option value="ALL">ALL</option>
									<option value="불출요청" selected>불출요청</option>
									<option value="반납요청">반납요청</option>
								</select>
							</dd>
						</dl>
						<!-- 2022-10-17(월요일) 안상현, 삭제구분 검색조건 추가 -->
						<dl>
							<dt>삭제구분</dt>
							<dd>
								<select class="input" id="DLFL" name="DLFL">
									<option value="ALL">ALL</option>
									<option value="정상" selected>정상</option>
									<option value="삭제">삭제</option>
								</select>
							</dd>
						</dl>
						<!-- 2022-10-17(월요일) 안상현, 전송상태 검색조건 추가 -->
						<dl>
							<dt>전송상태</dt>
							<dd>
								<select class="input" id="IF_STA" name="IF_STA">
									<option value="ALL">ALL</option>
									<option value="요청" selected>요청</option>
									<option value="완료">완료</option>
								</select>
							</dd>
						</dl>
						<!-- 20230215 여한진 LOT번호 검색조건 추가 -->
						<dl>
							<dt CL="STD_LOT_NO">LOT번호</dt>
							<dd>
								<!-- 2023-03-13(월요일) 안상현, Range 검색 추가 -->
								<input type="text" class="input" id="LOT_NO" name="LOT_NO" UIInput="SR" UIFormat="U" />
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
			<div class="content_layout tabs top_layout">
				<ul class="tab tab_style02">
					<li><a href="#tab1-1"><span CL="STD_GRD_INV08_1">요청이력</span></a></li>
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
											<td GH="160" GCol="text,DOC_NO" style="text-align: center;">문서번호</td>
											<td GH="80" GCol="text,DOC_SEQ" style="text-align: center;">순번</td>
											<td GH="80" GCol="text,REQ_DIV" style="text-align: center;">구분</td>
											<td GH="100" GCol="text,REQ_DT" GF="D" style="text-align: center;">요청일자</td>
											<td GH="80" GCol="text,DLFL" style="text-align: center;">삭제구분</td>
											<td GH="80" GCol="text,IF_STA" style="text-align: center;">전송상태</td>
											<td GH="80" GCol="text,WERKS" style="text-align: center;">플랜트</td>
											<td GH='100' GCol='text,ORDER_NO' style="text-align: center;">오더번호</td>
											<td GH='100' GCol='text,ORDER_SEQNO' style="text-align: center;">오더순번</td>  
											<td GH="140" GCol="text,MATNR" style="text-align: center;">자재코드</td>
											<td GH="320" GCol="text,MATNR_NM" style="text-align: center;">자재명</td>
											<td GH="100" GCol="text,MATNR_DIV" style="text-align: center;">자재유형</td>
											<td GH="100" GCol="text,QTY" GF="N 13,3">요청수량</td>
											<td GH="80" GCol="text,UNIT" style="text-align: center;">단위</td>
											<td GH="100" GCol="text,STOR_LOC_CD" style="text-align: center;">저장위치코드</td>
											<td GH="80" GCol="text,NTN_CD" style="text-align: center;">국가</td>
											<td GH="100" GCol="text,CRSPD_CD" style="text-align: center;">거래처코드</td>
											<td GH="100" GCol="text,CUST_NM" style="text-align: center;">거래처명</td>
											<!-- 20230215 여한진 하위 컬럼 사용하지 않으므로 주석처리 -->
											<!-- <td GH="140" GCol="text,PRDC_DT" GF="D" style="text-align: center;">제조일자</td>
											<td GH="140" GCol="text,RCVGDS_DT" GF="D" style="text-align: center;">입고일자</td>
											<td GH="140" GCol="text,DSTBT_DDLIN" GF="D" style="text-align: center;">유통기한</td> -->
											<td GH='100' GCol='text,DELIPOT' style="text-align: center;">하역지점</td>
											<!-- <td GH="140" GCol="text,IND_BCD" style="text-align: center;">개별바코드</td> -->
											<td GH="140" GCol="text,LOT_NO" style="text-align: center;">LOT NO</td>
											<td GH="100" GCol="text,OVBELN" style="text-align: center;">판매문서번호</td>
											<td GH="100" GCol="text,OPOSNR" style="text-align: center;">판매문서항목</td>
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
				<div class="content_layout tabs bottom_layout">
				<ul class="tab tab_style02">
					<li><a href="#tab1-1"><span CL="STD_GRD_INV08_2">상세</span></a></li>
					<li class="btn_zoom_wrap">
						<ul>
							<li><button class="btn btn_bigger"><span>확대</span></button></li>
						</ul>
					</li>
				</ul>
				<div class="table_box section" id="tab1-1" >
					<div class="table_list01">
						<div class="scroll">
							<table class="table_b">
								<tbody id="gridList2">
									<tr CGRow="true">
										<td GH='80' GCol='text,DIV' style="text-align: center;">구분</td>	
										<td GH="140" GCol="text,MATNR" style="text-align:center;">자재코드</td>
										<td GH="320" GCol="text,MATNR_NM" style="text-align: center;">자재명</td>
										<td GH="140" GCol="text,IND_BCD" style="text-align:center;">개별바코드</td>
										<td GH="140" GCol="text,LOT_NO" style="text-align:center;">LOT번호</td>
										<td GH="100" GCol="text,QTY" GF="N 13,3">수량</td>
										<td GH="80" GCol="text,UNIT" style="text-align:center;">단위</td>	
										<td GH="100" GCol="text,STOR_LOC_FR" style="text-align:center;">저장위치 From</td>
										<td GH="100" GCol="text,STOR_LOC_TO" style="text-align:center;">저장위치 To</td>
										<td GH="80" GCol="text,STCK_STA" style="text-align: center;">재고상태</td>	
										<td GH="140" GCol="text,PRDC_DT" GF="D" style="text-align:center;">제조일자</td>
										<td GH="140" GCol="text,RCVCDS_DT" GF="D" style="text-align:center;">입고일자</td>	
										<td GH="140" GCol="text,REGDATE" style="text-align:center;">등록일시</td>		
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
<%@ include file="/common/include/webdek/bottom.jsp"%>
</body>
</html>