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
	$(document).ready(function() {
		gridList.setGrid({
			id : "gridList",
			url : "/mes/Work/WRK26/json/datalist.data",
			bigdata : false,
			colHoldType : true,
			colHold : "WERKS,WRK_ORDR_NO, WRK_ORDR_SEQNO, MACHINE"
		});
		
		$("#RUN_STA").find("option").map(function(){
			//20230216 여한진 01, 02, 09만 표시 나머지는 점보롤 실적에서 사용하지 않으모로 
			const text = $(this).val()
			
			if(text != '' && text.indexOf("01") == -1 && text.indexOf("02") == -1 && text.indexOf("09") == -1){
				$(this).remove()
			}
		});	
	});

	function comboEventDataBindeBefore(comboAtt){
		if(comboAtt == "Produce,MACHINE"){
			var param = new DataMap();
			
			param.put("WERKS", 'P100');
		}
		return param;
	}

	function searchList() {
		if (validate.check("searchArea")) {
			// 2023-03-13(월요일) 안상현, Range 검색 추가
			const range = inputList.setRangeParam("searchArea")
			const range_data_param = range.get("RANGE_DATA_PARAM")
			const prfm_dt = range_data_param.get("PRFM_DT_Range")
			const date = prfm_dt.split("↓")
			const SDate = date[1]
			const EDate = date[2]
			
			const param = inputList.setRangeParam("searchArea")
			param.put("P_TYPE", "LIST")
			param.put("SDATE", SDate)
			param.put("EDATE", EDate)
			param.put("MACHINE", $("#MACHINE").val())
			param.put("RUN_STA", $("#RUN_STA").val())
			param.put("CNL_YN", $("#CNL_YN").val())
			param.put("MATNR", range.get("MATNR"))
			param.put("ORDER_NO", range.get("ORDER_NO"))
			
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
			param.put("MACHINE", $("#MACHINE").val())
			param.put("RUN_STA", $("#RUN_STA").val())
			param.put("CNL_YN", $("#CNL_YN").val())
			param.put('MATNR', range.get('MATNR'));
			param.put('ORDER_NO', range.get('ORDER_NO'));
			
			gridList.gridList({
				id : "gridList",
				param : param
			});
			*/
		}
	}
	
	// 실적취소
	function Pcancel(){
		var json = netUtil.sendData({
    		module : 'mes',
    		command : 'SYSTEMCHECK',
    		sendType : 'map'
    	});
    	
    	if(json.data.USE_YN == 'Y'){
    		alert('시스템 점검 중입니다. 1 ~ 5분 동안 잠시만 기다려 주세요.');
    		return;
    	}
		
		var list = gridList.getSelectData("gridList");
		
		if(list.length === 0){
			alert("실적을 취소할 바코드를 선택하세요.");
			return;
		}else if(list.length > 1){
			alert("여러 행을 동시에 실적 취소할 수 없습니다.")
			return
		}
		
		for(var i = 0; i < list.length; i++){
			var CNL_YN = list[i].get("CNL_YN");
			
			if(CNL_YN == "취소"){
				alert("이미 취소된 항목입니다.");
				return;
			}
		}
		
		var param = new DataMap();
		
		// 리스트 하나만 실적 취소 가능
		param.put("P_WERKS", list[0].get("WERKS"))
		param.put("P_MACH_CD", list[0].get("MACH_CD"))
		param.put("list", list)
		param.put("P_USERID", "<%=(String)request.getSession().getAttribute(CommonConfig.SES_USER_ID_KEY)%>")
		
		page.linkPopOpen("/mes/wrk/WRK26_POP01.page", param, "height=350,width=1000")
    }
	
	// 팝업 로직 처리 후 조회
	function linkPopCloseEvent(){
		searchList();
	}
	
	//LOT변경
	function Lotchange(){
		var json = netUtil.sendData({
    		module : 'mes',
    		command : 'SYSTEMCHECK',
    		sendType : 'map'
    	});
    	
    	if(json.data.USE_YN == 'Y'){
    		alert('시스템 점검 중입니다. 1 ~ 5분 동안 잠시만 기다려 주세요.');
    		return;
    	}
		
		var list = gridList.getSelectData("gridList");
		
		if(list.length == 0){
			alert("LOT변경할 바코드를 선택하세요.");
			return;
		}
		
		for(var i=0; i<list.length; i++){
			if(list[i].get('ORDER_NO').trim() == ''){
				alert('비계획생산으로 작업하고자 하는 오더번호를 SAP로부터 내려받지 못했습니다. SAP에 문의하세요.');
				searchList();
				return;
			}

			var rmk = list[i].get('ORDER_RMK') || "";
			// 큰따옴표(")를 홑따옴표(')로 치환하여 JSON 구조 깨짐 방지
			list[i].put('ORDER_RMK', rmk.replace(/"/g, "'"));
		}
		
		if(!commonUtil.msgConfirm("LOT변경하시겠습니까?")){
			return;
		}
		
		var param = new DataMap();
		
		param.put("P_TYPE", "SAVE");
		param.put("list", list);

        netUtil.send({
            url : "/mes/Work/WRK26/json/datalist.data",
            param : param,
            successFunction : "saveSuccessCallBack2"
        });
    }

	function saveSuccessCallBack2(json){
		if(json){
			if(json.P_SUCCESS == 'Y'){
				//20220731 여한진 재고이전정보를 SAP에 송신
				var param = new DataMap();
				
				param.put("IFID", "MES_IF_131");
	            param.put("DOC_NO", json.DOC_NO1);
	            
	            var json2 = netUtil.sendData({
	            	url : "/mes/erpif/json/sendIF.data",
	            	param : param
	            });
	            
	            if(json2.data == 'SUCCESS'){
	            	alert("LOT변경되었습니다.");
	            }else{
	            	alert('(SAP 재고이전) ' + json2.data);
	            }
	            searchList();
			}else{
				alert(json.ERR_MSG);
			}
		}
	}
	
	//LOT변경취소
	function Lotchgcancle(){
		var json = netUtil.sendData({
    		module : 'mes',
    		command : 'SYSTEMCHECK',
    		sendType : 'map'
    	});
    	
    	if(json.data.USE_YN == 'Y'){
    		alert('시스템 점검 중입니다. 1 ~ 5분 동안 잠시만 기다려 주세요.');
    		return;
    	}
		
		var list = gridList.getSelectData("gridList");
		
		if(list.length == 0){
			alert("LOT변경취소할 바코드를 선택하세요.");
			return;
		} 
		
		if(!commonUtil.msgConfirm("LOT변경취소하시겠습니까?")){
			return;
		}
		
		var param = new DataMap();
		
		param.put("P_TYPE", "SAVE2");
		param.put("list", list);

        netUtil.send({
            url : "/mes/Work/WRK26/json/datalist.data",
            param : param,
            successFunction : "saveSuccessCallBack3"
        });
    }

	function saveSuccessCallBack3(json){
		if(json){
			if(json.P_SUCCESS == 'Y'){
				//20220731 여한진 LOT변경취소 정보를 SAP에 송신
				var param = new DataMap();
				
				param.put("IFID", "MES_IF_140");
	            param.put("DOC_NO", json.DOC_NO1);
	            
	            var json2 = netUtil.sendData({
	            	url : "/mes/erpif/json/sendIF.data",
	            	param : param
	            });
	            
	            if(json2.data == 'SUCCESS'){
	            	alert("LOT변경취소되었습니다.");
	            }else{
	            	alert('(SAP LOT변경취소) ' + json2.data);
	            }
	            searchList();
			}else{
				alert(json.ERR_MSG);
			}
		}
	}
	
	function commonBtnClick(btnName) {
		if (btnName == "Search") {
			var param = new DataMap();
            param.put("PROGID", "<%= menuId%>");
            param.put("LGTYPE", "SEARCH");
            var json = netUtil.sendData({
                url: "/mes/system/json/saveLog.data",
                param : param
            });

            searchList();
        // 실적취소
		} else if (btnName == "Pcancel") {
			Pcancel();
		// LOT변경
		} else if (btnName == "Lotchange") {
			Lotchange();
		// LOT변경취소	
		} else if(btnName =="Lotchgcancle"){
			Lotchgcancle();
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
						<input type="button" id="button-0-5" CB="Pcancel DELETE BTN_PCANCEL" /> 
						<input type="button" id="button-0-4" CB="Lotchange SAVE BTN_LOTCHANGE" /> 
						<input type="button" id="button-0-3" CB="Lotchgcancle DELETE BTN_LOTCHGCANCLE" /> 
					</div>
				</div>
				<div class="search_inner">
					<div class="search_wrap ">
						<dl>
							<dt CL="STD_MACHINE">생산호기</dt>
							<dd>
								<select class="input" id="MACHINE" name="MACHINE" Combo="Produce,MACHINE">
									<option value="">ALL</option>
								</select>
							</dd>
						</dl>
						<dl>
							<dt CL="STD_PRFM_DT">실적일자</dt>
							<dd>
								<input type="hidden" id="CNL_RMK" name="CNL_RMK" />
								<input type="text" name="PRFM_DT" UIInput="B" UIFORMAT="C M1" />
							</dd>
						</dl>
						<!-- 20230215 여한진 자재코드, 오더번호 검색조건 추가 -->
						<dl>
							<dt CL="STD_MATNR">자재코드</dt>
							<dd>
								<!-- 2023-03-13(월요일) 안상현, 자재코드 RANGE 검색 추가 -->
								<input type="text" name="W000.MATNR" UIInput="SR,MATKY" UIFORMAT="U" />
							</dd>
						</dl>
						<dl>
							<dt CL="STD_ORDER_NO">오더번호</dt>
							<dd>
								<!-- 2023-03-13(월요일) 안상현, 오더번호 RANGE 검색 추가 -->
								<input type="text" class="input" name="ORDER_NO" UIInput="SR" />
							</dd>
						</dl>
						<dl>
							<dt CL="STD_RUN_STA">운전상태</dt>
							<dd>
								<select class="input" id="RUN_STA" name="RUN_STA" CommonCombo="RUNSTA">
									<option value="">ALL</option>
								</select>
							</dd>
						</dl>
						<dl>
							<dt CL="STD_CNL_YN">취소여부</dt>
							<dd>
								<select class="input" id="CNL_YN" name="CNL_YN">
									<option value="N">N</option>
									<option value="Y">Y</option>
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
						<li><a href="#tab1-1"><span CL="STD_GRD_WRK26">일반</span></a></li>
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
											<td GH="100" GCol="text,WERKS" style="text-align:center;">플랜트</td>
											<td GH="130" GCol="text,WRK_ORDR_NO" style="text-align:center;">작업지시번호</td>
											<td GH="100" GCol="text,WRK_ORDR_SEQNO" style="text-align:center;">순번</td>
											<td GH="100" GCol="text,MACHINE" style="text-align: center;">호기</td>
											<td GH="100" GCol="text,PROC_NM" style="text-align:center;">공정명</td>
											<td GH="100" GCol="text,MACH_CD" style="text-align: center;">설비코드</td>
											<td GH="100" GCol="text,MACH_NM" style="text-align:center;">설비명</td>
											<td GH="140" GCol="text,MATNR" style="text-align:center;">자재코드</td>
											<td GH="320" GCol="text,MATNR_NM" style="text-align:center;">자재코드</td>
											<td GH="140" GCol="text,PRD_STR_DATE" style="text-align: center;">시작시간</td>
											<td GH="140" GCol="text,PRD_END_DATE" style="text-align: center;">종료시간</td>
											<td GH="100" GCol="text,TM" GF="N 13" style="text-align: center">생산시간</td>
											<td GH="100" GCol="text,WRK_CLASS" style="text-align: center;">작업반</td>
											<td GH="100" GCol="text,PCODE_NM" style="text-align:center;">지종명</td>
											<td GH="100" GCol="text,BS_WGT" style="text-align:center;">평량</td>
											<td GH="100" GCol="text,PRDTYPETXT" style="text-align:center;">생산라인</td>
											<td GH="100" GCol="text,RSPEED" style="text-align:center;">선속</td>
											<td GH="100" GCol="text,LOT_NO" style="text-align:center;">LOT번호</td>
											<td GH="120" GCol="text,IND_BCD" style="text-align:center;">개별바코드</td>
											<td GH="100" GCol="text,RUN_STA" style="text-align:center;">운전상태</td>
											<td GH="100" GCol="text,PRFM_ROLLCNT" GF="N 6,0">실적권치수</td>
											<td GH="100" GCol="text,PRROLLUNIT" style="text-align: center;">실적권치수단위</td>
									
											<td GH="100" GCol="text,PRFM_WGT" GF="N 13,3">실적중량</td>
											<td GH="100" GCol="text,PRWUNIT" style="text-align: center;">실적중량단위</td>
											
											<td GH="100" GCol="text,DISPO_ROLLCNT" GF="N 6,0">폐품권치수</td>
											<td GH="100" GCol="text,DIROLLUNIT" style="text-align: center;">폐품권치수단위</td>
											
											<td GH="100" GCol="text,DISPO_WGT" GF="N 13,3">폐품중량</td>
											<td GH="100" GCol="text,DIWUNIT" style="text-align: center;">폐품중량단위</td>
											
											<td GH="100" GCol="text,DISPO_CD" style="text-align:center;">폐품코드</td>
											<td GH="100" GCol="text,PRFM_DT" style="text-align:center;" GF='D'>실적일자</td>
											<td GH="140" GCol="text,PRD_DATE" style="text-align:center;">생산일시</td>
											<td GH="120" GCol="text,NAUFNR" style="text-align:center;">비계획생산오더번호</td>
											<td GH="100" GCol="text,LOT_CHG_YN" style="text-align:center;">LOT 변경여부</td>
											<td GH="100" GCol="text,REGNM" style="text-align:center;">작업자</td>
											<td GH="330" GCol="text,ORDER_RMK" style="text-align:center;">오더비고</td>
											<td GH="100" GCol="text,ORDER_NO" style="text-align:center;">생산오더번호</td>
											<td GH="60" GCol="text,CNL_YN" style="text-align:center;">취소여부</td>
											<td GH="140" GCol="text,CNL_RMK" style="text-align:center;">취소비고</td>
											<td GH="100" GCol="text,COMP_YN" style="text-align:center;">완료여부</td>
											<td GH="120" GCol="text,SDOC_NO" style="text-align:center;"></td>
											<td GH="120" GCol="text,SDOC_SEQNO" style="text-align:center;"></td>
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