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
			url:"/mes/Work/WRK04/json/datalist.data",
			bigdata : false
			/*pkcol :"WERKS"
	    	colHoldType : true,
	    	colHold : "PRFM_DT,PRD_DT,INP_DT,CLOT_NO,PACKTYPE,PCODE" */
		})
		
		gridList.setGrid({
			id : "gridList2",
			url:"/mes/Work/WRK04/json/datalist.data",
			bigdata : false
		})
		/* 20220928 여한진 PS제지만 관리 */
		$('#WERKS').val('P100');
	});

	function searchList() {
		if (validate.check("searchArea")) {
			/* var range = inputList.setRangeParam("searchArea");
			var range_data_param = range.get("RANGE_DATA_PARAM");
			var prfm_dt = range_data_param.get("PRFM_DT_Range");
			var date = prfm_dt.split('↓');
			var SDate = date[1];
			var EDate = date[2]; */
			
			var param = inputList.setRangeParam("searchArea");
			param.put("P_TYPE", "LIST");
			/* param.put("SDATE", SDate);
			param.put("EDATE", EDate);
			//param.put("WERKS",$("#WERKS").val());
			param.put("WERKS",$("#WERKS").val().toUpperCase()); */
	
			gridList.gridList({
				id : "gridList",
				param : param
			});
	
			//searchSub(param);

			gridList.resetGrid("gridList2");
		}
	}
	
	// 전체 checkbox 선택
	const gridListEventRowCheckAll = (gridId, checkType) => {
		f(gridId)
	}
	
	// 행 개별 checkbox 선택
	const gridListEventRowCheck = (gridId, rowNum, checkType) => {
		f(gridId)
	}
	
	// 체크박스 선택에 따른 함수
	const f = (gridId) => {
		if(gridId === "gridList"){
			const data = gridList.getSelectData("gridList")
			
			if(data.length >= 1){
				let condi = "WHERE (INV003.WERKS,INV003.MATNR,INV003.IND_BCD,INV003.SEQNO) IN ("
				for(let i = 0; i < data.length; i++){
					condi += "(\'" + data[i].get("WERKS") + "\',\'" + data[i].get("CMATNR") + "\',\'" + data[i].get("IND_BCD") + "\',\'" + data[i].get("SEQNO") + "\'),"
				}
				condi = condi.slice(0, -1)
				condi += ")"
				
				const param = inputList.setRangeParam("searchArea");
				param.put("P_TYPE", "SUB_LIST");
				param.put("OUT_SQL", condi);
				
				gridList.gridList({
					id : "gridList2",
					param : param
				});
			}else{
				gridList.resetGrid("gridList2")
			}
		}
	}
	
	
	function saveData(){
		var json = netUtil.sendData({
    		module : 'mes',
    		command : 'SYSTEMCHECK',
    		sendType : 'map'
    	});
    	
    	if(json.data.USE_YN == 'Y'){
    		alert('시스템 점검 중입니다. 1 ~ 5분 동안 잠시만 기다려 주세요.');
    		return;
    	}
    	
		//20230214 여한진 폐기일자, 폐품코드, 폐품명 validate 추가
    	if($('#DISPO_DT').val().trim() == ''){
    		alert('폐기일자를 선택 및 입력하세요.');
    		return;
    	}
    	
    	if($('#DISPO_CD').val().trim() == ''){
    		alert('폐품코드를 선택 및 입력하세요.');
    		$('#DISPO_NM').val('')
    		return;
    	}
    	
    	if($('#DISPO_NM').val().trim() == ''){
    		$('#DISPO_CD').val('');
    		$('#DISPO_CD').focus();
    		alert('잘못된 폐품코드입니다. 다시 폐품코드를 선택 및 입력하세요.');
    		return;
    	}
    	
    	if(gridList.validationCheck("gridList", "data")){
			var list = gridList.getSelectData("gridList");
	    	
	    	if(list.length == 0){
	    		alert('폐품 등록할 재단 LOT번호를 선택하세요.');
	    		return;
	    	}
			
			var param = new DataMap();
			
			param.put("P_TYPE","SAVE");
			param.put("list", list);
			param.put('DISPO_DATE', $('#DISPO_DT').val().replace(/-/g, ''));
			param.put("DISPO_CD",$("#DISPO_CD").val());
			param.put("DISPO_NM",$("#DISPO_NM").val());
			param.put("DISPO_DIV",$("#DISPO_DIV").val());
			param.put("RMK",$("#RMK").val());
			
			if(!commonUtil.msgConfirm(configData.MSG_MASTER_SAVE_CONFIRM)){
				return;
			}
			
			netUtil.send({
				url : "/mes/Work/WRK04/json/datalist.data",
				param : param,
	            successFunction : "savesuccessCallBack"
			});
        }
	}
	
	function savesuccessCallBack(json){
		if(json.P_SUCCESS != 'Y'){
			alert(json.ERR_MSG);
		}else {
			var param = new DataMap();
			
			const DISPO_IFID = json.RS_DISPO_I_IF_ID
  			const DISPO_DOCNO = json.RS_DISPO_SQL
  			var docno = json.RS_DISPO_SQL.split(',');
			var message = '';
			
			for(var i = 0; i < docno.length; i++){
				param.put("IFID", DISPO_IFID);
		    	param.put("DOC_NO", docno[i]);	//SAP문서번호
		    	
				var json = netUtil.sendData({
		        	url : "/mes/erpif/json/sendIF.data",
		        	param : param
		        });
		    	
				if(json.data == 'SUCCESS'){
		    	}else{
		    		message = '(SAP 생산실적) ' + (i + 1) + '번째 오류는 ' + json.data + '\n';
		    	}
			}
			if(message == ''){
				alert("폐품등록되었습니다.");
			}else{
				alert(message);
			}
		}
		searchList();
		gridList.resetGrid("gridList2");
 		$("#RMK").val('');
 		$("#DISPO_CD").val('');
 		$("#DISPO_NM").val('');
 		$("#DISPO_DIV").val('');
	}
	
	
    /* function savesuccessCallBack(json){
    	if(json){
    		if(json.data == 'SUCCESS'){
    			commonUtil.msgBox(configData.MSG_SYSTEM_SAVEOK);    			
    		}else {
    			alert('(SAP 생산실적) ' + (i + 1) + '번째 오류는 ' + json2.data + '\n');
    		}
    	}
    	searchList();
		gridList.resetGrid("gridList2");
 		$("#RMK").val('');
 		$("#DISPO_CD").val('');
 		$("#DISPO_NM").val('');
    } */

	function commonBtnClick(btnName){
		//commonUtil.debugMsg("commonBtnClick : ", arguments);
		if(btnName == "Search"){
			searchList();
		}else if(btnName == "Save"){
			saveData();
		}
	}
	
	const err = () => {
		var url = "/mes/wrk/WRK04_POP01.page";
		page.linkPopOpen(url, '', "height=600,width=550");
	}
	
	function enterkey(){
		if(window.event.keyCode == 13){
			err();
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
					<input type="button" CB="Search SEARCH BTN_SEARCH" />
					<input type="button" CB="Save SAVE BTN_SAVE" />
				</div>
			</div>
			<div class="search_inner">
				<div class="search_wrap ">
					<dl>
						<dt CL="STD_PLANT">플랜트</dt>
						<dd>							
							<input type="text" class="input" id="WERKS" name="WERKS" readonly="readonly"/>
						</dd>
					</dl>
					<dl>
						<dt>투입일자</dt>
                        <dd>
                        	<input type="text" name="W002.PRFM_DT" id="W002.PRFM_DT" UIInput="B" UIFORMAT="C M1"/>
                        </dd>
					</dl>
				</div>
				<div class="btn_tab">
					<input type="button" class="btn_more" value="more" onclick="searchMore()"/>
				</div>
			</div>
		</div>
        <div class="search_next_wrap">
		<div class="content_layout tabs top_layout">
			<ul class="tab tab_style02">
				<li><a href="#tab1-1"><span CL="STD_GRD_WRK04_1">포장 공정 투입정보</span></a></li>
				<li class="btn_zoom_wrap">
					<ul>
						<!-- <li><button class="btn btn_smaller"><span>축소</span></button></li> -->
						<li><button class="btn btn_bigger"><span>확대</span></button></li>
					</ul>
				</li>
			</ul>
			<div class="table_box section" id="tab1-1">
				<div class="table_list01">
					<div class="scroll" style="height: calc(100% - 27px)">
						<table class="table_c">
							<tbody id="gridList">
								<tr CGRow="true">
									<td GH="40" GCol="rowCheck"></td>
									<td GH="100" GCol="text,PRFM_DT" GF='D' style="text-align:center;">실적일자</td>
									<td GH="100" GCol="text,PRD_DT" GF='D' style="text-align:center;">생산일자</td>
									<td GH="100" GCol="text,INP_DT" GF='D' style="text-align:center;">투입일자</td>
									<td GH="100" GCol="text,CLOT_NO" style="text-align:center;">재단 LOT 번호</td>
									<td GH="80" GCol="text,PACKTYPE" style="text-align:center;">포장타입</td>
									<td GH="80" GCol="text,PCODE" style="text-align:center;">지종</td>
									<td GH="100" GCol="text,PCODE_NM">지종명</td>
									<td GH="100" GCol="text,BS_WGT" style="text-align:center;">평량</td>
									<td GH="100" GCol="text,SPEC">규격</td>
									
									<td GH="100" GCol="text,USE_CNT" GF='N 13,3'>사용연수</td>
									<td GH="100" GCol="text,URUNIT" style="text-align:center;">사용연수단위</td>
									
									<td GH="100" GCol="text,USE_WGT" GF='N 13,3'>사용중량</td>
									<td GH="100" GCol="text,UWUNIT" style="text-align:center;">사용중량단위</td>
									
									<td GH="100" GCol="text,GCNT" GF='N 13,3'>가용연수</td>
									<td GH="100" GCol="text,ARUNIT" style="text-align:center;">가용연수단위</td>
									
									<td GH="100" GCol="text,G_WGT" GF='N 13,3'>가용중량</td>
									<td GH="100" GCol="text,AWUNIT" style="text-align:center;">가용중량단위</td>
									
									<td GH="100" GCol="text,OVBELN" style="text-align:center;">판매오더</td>
									<td GH="140" GCol="text,CMATNR" style="text-align:center;">재단자재코드</td>
									<td GH="100" GCol="text,PRFM_PCNT" GF='N 13,3'>실적연수</td>
									<td GH="100" GCol="text,DRUNIT" style="text-align:center;">실적연수단위</td>
									
									<td GH="100" GCol="text,PLN_PLT_PER_CNT" GF='N 13,3'>계획연수</td>
									<td GH="100" GCol="text,PRUNIT" style="text-align:center;">계획연수단위</td>
									
									<td GH="100" GCol="text,WGT" GF='N 13,3'>실적중량</td>
									<td GH="100" GCol="text,DWUNIT" style="text-align:center;">실적중량단위</td>
									
									<td GH="100" GCol="text,PLN_WGT" GF='N 13,3'>계획중량</td>
									<td GH="100" GCol="text,PWUNIT" style="text-align:center;">계획중량단위</td>
									
									<td GH="100" GCol="text,MACHINE_NM">생산호기</td>
									<td GH="100" GCol="text,TO_MACHINE_NM">이동호기</td>
									<td GH="100" GCol="text,DISPO_WGT" GF='N 13,3'>폐품중량</td>
									<td GH="100" GCol="text,DIUNIT" style="text-align:right;">폐품중량단위</td>
									
									<td GH="140" GCol="text,IMATNR" style="text-align:center;">포장자재코드</td>
									<td GH="100" GCol="text,ORDER_NO" style="text-align:center;">오더번호</td>
									<td GH="100" GCol="text,RMK">비고</td>
									<td GH="120" GCol="text,JLOT_NO" style="text-align:center;">JR LOT 번호</td>
									<td GH="120" GCol="text,MLOT_NO" style="text-align:center;">MR LOT 번호</td>
									
									<td GH="100" GCol="text,WERKS" style="text-align:center;">플랜트</td>
									<td GH="100" GCol="text,MACH_CD" style="text-align:center;">설비코드</td>
									<td GH="140" GCol="text,IND_BCD" style="text-align:center;">개별바코드</td>
									<td GH="60" GCol="text,SEQNO" style="text-align:center;">순번</td>						
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
		<div class="content-horizontal-wrap h-wrap-min bottom_layout">
			<div class="content_layout tabs content_left">
				<ul class="tab tab_style02">
					<li><a href="#tab1-1"><span CL="STD_GRD_WRK04_2">재단 바코드 목록</span></a></li>
					
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
							<table class="table_c">
								<tbody id="gridList2">
									<tr CGRow="true">
										<td GH="140" GCol="text,IND_BCD" style="text-align:center;">개별바코드</td>
										<td GH="140" GCol="text,LOT_NO" style="text-align:center;">LOT번호</td>
										<td GH="100" GCol="text,IN_CNT" GF='N 13,3'>투입연수</td>
										<td GH="100" GCol="text,USE_CNT" GF='N 13,3'>사용연수</td>
										<td GH="100" GCol="text,GCNT" GF='N 13,3'>가용연수</td>						
									</tr>
								</tbody>
							</table>
						</div>
					</div>
					<jsp:include page="/WEB-INF/jsp/common/commonBtnAuth.jsp">
						<jsp:param name="authCd" value="2" />
						<jsp:param name="showAuthCd" value="1,2,3,7,9,10" />
					</jsp:include>	
				</div>
				
			</div>
			
			<div class="handlerH_wrap">
				<div class="handlerH"></div>
			</div>
			
			<div class="content_layout tabs content_right">
				<table>
					<colgroup>
						<col width="20%"/>
					</colgroup>
					<tbody>
						<tr>
						<br>
							<th>폐기일자</th>
							<td>
								<input type="text" class="input" id="DISPO_DT" UIFormat="C N" style='text-align:center;' validate='required'/>
							</td>
						</tr>
						<tr>
							<td>
								<br></br>
							</td>
						</tr>
						<tr>
							<th>폐품코드</th>
							<td>
								<input type="text" class="input" name="DISPO_CD" id="DISPO_CD" validate='required' onkeyup = 'enterkey();' UIFormat="U"/>
								<button type="button" class="btn btn_search" onclick="err()">
									<span>search</span>
								</button>
							</td>
						</tr>
						<tr>
							<td>
							</td>
						</tr>
						<tr>
							<th>폐품명</th>
							<td>
								<input type="hidden" id="DISPO_DIV" name="DISPO_DIV"/>
								<input type="text" class="input" name="DISPO_NM" id="DISPO_NM" readonly validate='required' />
							</td>
						</tr>
						<tr>
							<td>
								<br></br>
							</td>
						</tr>
						<tr>
							<th>비고</th>
							<td class="break">
								<textarea class="input" name="RMK" id="RMK" style="width:400px;height:50px;"></textarea>
							</td>
						</tr>
					</tbody>
				</table>
			</div>
		</div>
	</div>
</div>
<!-- // content -->
<%@ include file="/common/include/webdek/bottom.jsp" %>
</body>
</html>