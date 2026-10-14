<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Grid default</title>
<%@ include file="/common/include/webdek/head.jsp" %>
<script type="text/javascript" src="/common/js/ezgencontrol.js"></script>
<link rel="stylesheet" type="text/css" href="/common/theme/webdek/css/demo_layout.css">
<script type="text/javascript">
	var message = '';
	var docno = '';
	var machcd;
	
	$(document).ready(function(){
		// 품목별
		gridList.setGrid({
	    	id : "gridList_A",
	    	url : "/mes/Work/WRK14/json/datalist.data",
	    	bigdata : false,
	    	colHoldType : true,
	    	colHold : "WERKS,PRFM_DT"
	    });
		
		// LOT별
		gridList.setGrid({
			id : "gridList_B",
	    	url : "/mes/Work/WRK14/json/datalist.data",
	    	bigdata : false,
	    	colHoldType : true,
	    	colHold : "WERKS,PRFM_DT,MATNR,MATNR_NM"
	    });
	});

	let id = "gridList_A" // 품목별
	
	// 조회
	function searchList(gridId,list){
		id = gridId
		if(validate.check("searchArea")){
			var param = inputList.setRangeParam("searchArea");
			
			if(param.get("WERKS") == "P100"){
				alert("PS에서 관리하는 화면이 아닙니다.");
				return;
			}
			
			param.put("P_TYPE",list);
			
			gridList.gridList({
				id : gridId,
				param : param
			});
		}
	}
	
	// 품목별, LOT별 조회 제어
	const f = (gridId) => {
		id = gridId

		if(gridId === "gridList_A"){
			$("#dl_IND_BCD").hide()
			$("#dl_LOT_NO").hide()
			/* $("#dl_CNL_YN").hide() */
		}else{
			$("#dl_IND_BCD").show()
			$("#dl_LOT_NO").show()
			/* $("#dl_CNL_YN").show() */
		}
	}

	// 실적취소
	function PrfmCancel(){

		// VALIDATION
		// LOT별 TAB에서만 실적취소 가능
		if(id === "gridList_A") alert("LOT 별 조회에서만 실적취소가 가능합니다.")
		else{
			var json = netUtil.sendData({
	    		module : 'mes',
	    		command : 'SYSTEMCHECK',
	    		sendType : 'map'
	    	});
	    	
	    	if(json.data.USE_YN == 'Y'){
	    		alert('시스템 점검 중입니다. 1 ~ 5분 동안 잠시만 기다려 주세요.');
	    		return;
	    	}
			
			const list = gridList.getSelectData("gridList_B")
			
			// 실적취소 바코드 선택
			if(list.length === 0){
				alert("실적취소할 바코드를 선택하세요.")
				return
			}
			
			// 2022-08-24(수요일) 안상현, 실적 취소된 자재가 선택되어 있을 경우 팝업창 띄우지 않기
			for(let i = 0; i < list.length; i++){
				if(list[i].get("CNL_YN") === "Y"){
					alert("선택된 자재 중에서 "+(i+1)+"번째 자재는 취소여부가 Y 입니다.")
					return
				}
			}
			
			const param = new DataMap()
			param.put("P_TYPE", "DELETE")
			param.put("list", list)
			
			// 실적취소사유 INPUT 입력 팝업창 호출
			page.linkPopOpen("/mes/wrk/WRK14_POP01.page", list, "height=350,width=1000")
		}
	}
	
	// 팝업 로직 처리 후 조회
	function linkPopCloseEvent(){
		searchList("gridList_B","LIST_B");
	}
	
	// 버튼 클릭
	function commonBtnClick(btnName){
		if(btnName == "Search"){
			var param = new DataMap();
	        param.put("PROGID", "<%= menuId%>");
	        param.put("LGTYPE", "SEARCH");
	        var json = netUtil.sendData({
	            url: "/mes/system/json/saveLog.data",
	            param : param
	        });
	        
	        if(id === "gridList_A") searchList("gridList_A","LIST_A")
	        else searchList("gridList_B","LIST_B")
		} else if(btnName == "Pcancel"){
			PrfmCancel();
		}else if(btnName == "ReSend"){
			//재전송
			ReSend();
		}else{
			reportPrint()
		}
	}
	
	// 재전송
    function ReSend(){
    	if(id == "gridList_A"){
    		alert("LOT별 조회에서만 실적 재전송이 가능합니다.")
    	}else{
    		var json = netUtil.sendData({
	    		module : 'mes',
	    		command : 'SYSTEMCHECK',
	    		sendType : 'map'
	    	});
	    	
	    	if(json.data.USE_YN == 'Y'){
	    		alert('시스템 점검 중입니다. 1 ~ 5분 동안 잠시만 기다려 주세요.');
	    		return;
	    	}
    		
    		var list = gridList.getSelectData("gridList_B");
       		
       		if(list.length == 0){
       			alert("재전송할 실적을 선택하세요.");
       			return;
       		}
       		
       		for(var i = 0; i < list.length; i++){
       			if(list[i].get("SAP_YN") == '성공'){
       				alert("SAP에 실적을 성공적으로 보냈으므로 다시 재전송할 필요가 없습니다.");
       				searchList("gridList_B","LIST_B");
       				return;
       			}
       			if(list[i].get("DOC_NO").trim() == ''){
       				alert("문서번호가 없어서 전송할 수 없습니다.");
       				searchList("gridList_B","LIST_B");
       				return;
       			}
       			if(i > 0){
       				if(list[i - 1].get("MACH_CD").substr(0, 3) != list[i].get("MACH_CD").substr(0, 3)){
       					alert("같은 설비끼리 처리가능합니다.");
       					searchList("gridList_B","LIST_B");
       					return;
       				}
       			}
       			
       			// 2022-08-23 실적 취소된 자재는 실적 재전송 불가
       			// CNL_YN : 취소여부(Y, N)
       			/* 
       			if(list[i].get("CNL_YN") === "Y"){
       				alert((i+1)+"번째 행은 실적 취소된 자재입니다.")
       				return
       			}
       			*/
       			machcd = list[i].get("MACH_CD").substr(0, 3);
       			docno = list[i].get("DOC_NO") + ',' + docno;	
       		}
       		
       		docno = docno.split(',');
       		
       		if(!commonUtil.msgConfirm("실적을 재전송하시겠습니까?")){
    			return;
    		}
       		
			var param = new DataMap();
       		
       		param.put('P_TYPE', 'SEND');
       		param.put('list', list);
       		
       		netUtil.send({
       			url : "/mes/Work/WRK14/json/datalist.data",
       			param : param,
       			successFunction : "saveSuccessCallBack"
       		});
        }
   	}
     
    function saveSuccessCallBack(json){
    	if(json.P_SUCCESS = 'Y'){
    		for(var i = 0; i < docno.length; i++){
       			if(docno[i] != ''){
       				var param = new DataMap();
       				
           	     	if($('#WERKS').val().toUpperCase() == 'P200'){
           	     		if(machcd == 'TPG'){
           	     			//예외생산
           	     			param.put("IFID", "MES_IF_141");
           	     		}else{
           	     			//화장기 가공
               	     		param.put("IFID", "MES_IF_124");
           	     		}
           	     	}else{
           	     		if(machcd == 'SPF' || machcd == 'BPI'){
           	     			//예외생산
           	     			param.put("IFID", "MES_IF_141");
           	     		}else{
           	     			//기저귀, 생리대
               	     		param.put("IFID", "MES_IF_133");
           	     		}
           	     	}
           	     	
           	   		param.put("DOC_NO", docno[i]);
           	   		
           	        var json2 = netUtil.sendData({
           	   			url : "/mes/erpif/json/sendIF.data",
           	         	param : param
           	        });
           	        
       	    	 	if(json2.data == "SUCCESS"){
            		}else{
            			message = '(SAP 실적전송) ' + (i + 1) + '번째 오류는 ' + json2.data + '\n' + message;
            		}
       			}
       		}
       		if(message == ''){
       			alert("실적 재전송을 성공했습니다.");
       			searchList("gridList_B","LIST_B");
       		}else{
       			alert(message);
       			searchList("gridList_B","LIST_B");
       		}
    	}else{
    		alert("실적재전송실패했습니다.");
    	}
    	message = '';
    	docno = '';
    }
	
	// 출력은 LOT별에서만 출력
	const reportPrint = () => {
		if(id === "gridList_A"){
			alert("LOT별 조회에서만 라벨 출력 가능합니다.")
			return
		}
		
		const list = gridList.getSelectData("gridList_B")
		
		if(list.length !== 1){
			alert("출력 개수는 1개입니다.")
			return
		}
		
		let param = new DataMap()
		param.put("list", list)
		param.put("PRTTYP","MES")
		param.put("LANGKY", "KR")
		param.put("PROGID" , configData.MENU_ID)
		param.put("WAREKY", "<%=wareky%>")
		
		// 이지젠 파일명
		let fileName = "KLRA_WRK15_PRO_LABEL.ezg"
		
		// 라벨
		param.put("LABEL01" , "제 품 정 보")
		param.put("LABEL02" , "생산일자")
		param.put("LABEL03" , "생산호기")
		param.put("LABEL04" , "제품종류")
		param.put("LABEL05" , "제품코드")
		param.put("LABEL06" , "제품명")
		param.put("LABEL07" , "KAN코드")
		param.put("LABEL08" , "기본단위")
		param.put("LABEL09" , "(BAG/BOX)")
		param.put("LABEL10" , "파렛트단위")
		param.put("LABEL11" , "(BOX/PLT)")
		param.put("LABEL12" , "LOT No.")
		param.put("LABEL13" , "개별바코드")
		param.put("LABEL14" , "물류")
		param.put("LABEL15" , "바코드")
		
		// 데이터
		// 개별바코드
		param.put("VALUE02", list[0].get("IND_BCD"))
		
		// 이력 테이블 INSERT
		const json = netUtil.sendData({
			url : "/mes/report/json/savePrtseq_LocBcd.data",
			param : param
		});
		
		param = new DataMap();
		const i_where = "AND PRT.PRTSEQ = '" + json.data + "'";
		
		WriteEZgenElement(fileName, i_where, "", '<%= langky%>', param, 1000, 1000)
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
					<input type="button" id="button-0-4" CB="ReSend APPLY 실적재전송" />
					<input type="button" id="button-0-3" CB="Label PRINT_OUT BTN_LABEL" />
					<input type="button" id="button-0-2" CB="Pcancel DELETE BTN_PCANCEL" />	
				</div>
			</div>
			<div class="search_inner">
				<div class="search_wrap ">
					<dl>
						<dt CL="STD_PLANT">플랜트</dt>
						<dd>
							<input type="text" class="input" id="WERKS" name="WERKS" validate="required" UIInput="S,PLANT" UIFormat="U"/>
						</dd>
					</dl>
					
					<dl>
						<dt CL="STD_PRFM_DT">실적일자</dt>
						<dd>
							<input type="text" id="PRFM_DT" name="PRFM_DT" UIInput="B" UIFORMAT="C M1"/>
						</dd>
					</dl>
					
					<dl>
						<dt CL="STD_MACH_CD">설비코드</dt>
						<dd>
							<input type="text" class="input" name="MACH_CD" UIInput="SR,MACH" UIFormat="U"/>
						</dd>
					</dl>
					<dl>
						<dt CL="STD_MATNR">자재코드</dt>
						<dd>
							<input type="text" id="MATNR" name="MATNR" UIInput="SR,MATKY" UIFormat="U"/>
						</dd>
					</dl>
					<dl>
						<dt CL="STD_WRK_SHIFT">작업조</dt>
						<dd>
							<select class='input' name="WRK_SHIFT" commonCombo='WRKMETH'>
								<option value=''>All</option>
							</select>
						</dd>
					</dl>
					<dl id="dl_IND_BCD" style="display: none;">
						<dt CL="STD_IND_BCD">개별바코드</dt>
						<dd>
							<input type="text" class="input" id="IND_BCD" name="IND_BCD" UIInput="SR,INDBCD" UIFormat="U"/>
						</dd>
					</dl>
					<dl id="dl_LOT_NO" style="display: none;">
						<dt CL="STD_LOT_NO">LOT NO</dt>
						<dd>
							<input type="text" class="input" id="LOT_NO" name="LOT_NO" UIInput="SR" UIFormat="U"/>
						</dd>
					</dl>
					<!-- <dl id="dl_CNL_YN" style="display: none;">
						<dt>실적취소</dt>
						<dd>
							<select class="input" name="CNL_YN" CommonCombo="CNL_YN"></select>
						</dd>
					</dl> -->
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
						<a href="#tab1-1" onclick="f(`gridList_A`)">
							<span>품목별</span>
						</a>
					</li>
					<li>
						<a href="#tab1-2" onclick="f(`gridList_B`)">
							<span>LOT별</span>
						</a>
					</li>
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
								<tbody id="gridList_A">
									<tr CGRow="true">
										<td GH="40" GCol="rownum">1</td>
										<td GH="100" GCol="text,WERKS" style="text-align: center;">플랜트</td>
										<td GH="100" GCol="text,PRFM_DT" GF="D" style="text-align:center;">생산실적일자</td>
										<td GH="140" GCol="text,MATNR" style="text-align: center;" >자재코드</td>
										<td GH="320" GCol="text,MATNR_NM">자재명</td>
										<td GH="100" GCol="text,MACH_CD" style="text-align: center;">설비코드</td>
										<td GH="100" GCol="text,PLT_QTY" GF="N 13,1">PLT</td>
										<td GH="100" GCol="text,BOX_QTY" GF="N 13">BOX</td>
										<td GH="100" GCol="text,BAG_QTY" GF="N 13">BAG</td>
										<td GH="100" GCol="text,EA_QTY" GF="N 13">EA</td>
										<td GH="100" GCol="text,WGT" GF="N 13,3">중량</td>
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
				<div class="table_box section" id="tab1-2">
					<div class="table_list01">
						<div class="scroll">
							<table class="table_b">
								<tbody id="gridList_B">
									<tr CGRow="true">
										<td GH="40" GCol="rownum">1</td>
										<td GH="40" GCol="rowCheck"></td>
										<td GH="100" GCol="text,WERKS" style="text-align: center;">플랜트</td>
										<td GH="100" GCol="text,PRFM_DT" GF="C" style="text-align:center;">생산실적일자</td>
										<td GH="140" GCol="text,MATNR" style="text-align: center;">자재코드</td>
										<td GH="320" GCol="text,MATNR_NM">자재명</td>
										<td GH="100" GCol="text,MACH_CD" style="text-align: center;">설비코드</td>
										<td GH="150" GCol="text,WRK_ORDR_NO">작업지시번호</td>
										<td GH="80" GCol="text,WRK_ORDR_SEQNO" style="text-align: center;">작업지시번호</td>
										<td GH="100" GCol="text,LOT_NO">LOT번호</td>
										<td GH="140" GCol="text,IND_BCD">개별바코드</td>
										<td GH="100" GCol="text,PLT_QTY" GF="N 13,1">PLT</td>
										<td GH="100" GCol="text,BOX_QTY" GF="N 13">BOX</td>
										<td GH="100" GCol="text,BAG_QTY" GF="N 13">BAG</td>
										<td GH="100" GCol="text,EA_QTY" GF="N 13">EA</td>
										<td GH="100" GCol="text,WGT" GF="N 13,3">중량</td>
										<td GH="150" GCol="text,START_DATE" style="text-align: center;">시작일시</td>
										<td GH="150" GCol="text,END_DATE" style="text-align: center;">종료일시</td>
										<td GH="100" GCol="text,WRK_SHIFT" style="text-align: center;">작업조</td>
										<td GH="100" GCol="text,WRK_CLASS" style="text-align: center;">작업반</td>
										<td GH="0" GCol="text,ORDER_NO">오더번호</td>
										<td GH="0" GCol="text,DOC_NO">MES문서번호</td>
										<td GH="0" GCol='text,DOC_SEQNO'>MES문서순번</td>
										<td GH="100" GCol="text,SAP_YN">SAP전송여부</td>
										<td GH="80" GCol="text,CNL_YN" style="text-align: center;">취소여부</td>
										<td GH="140" GCol="text,REGDATE" style="text-align: center;"></td>
										<td GH="100" GCol="text,REGNM" >작업자</td>
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
<%@ include file="/common/include/webdek/bottom.jsp" %>
</body>
</html>