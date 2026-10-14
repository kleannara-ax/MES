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
	$(document).ready(function(){
		gridList.setGrid({
			id : "gridList",
			url : "/mes/Work/WRK27/json/datalist.data",
			bigdata : false,
			colHoldType : true,
	        colHold : "PCODE,PCODE_NM,BS_WGT,WLEN,VLEN"
	    });
	});
	
	// 조회
	function searchList() {
		if (validate.check("searchArea")) {
			// 2023-03-13(월요일) 안상현, Range 검색 추가
			const range = inputList.setRangeParam("searchArea")
			const range_data_param = range.get("RANGE_DATA_PARAM")
			const prfm_dt = range_data_param.get("A.PRFM_DT_Range")
			const date = prfm_dt.split("↓")
			const SDate = date[1]
			const EDate = date[2]
			
			const param = inputList.setRangeParam("searchArea")
			param.put("P_TYPE", "LIST")
			param.put("SDATE", SDate)
			param.put("EDATE", EDate)
			//param.put("IND_BCD", $("#IND_BCD").val())
			param.put("CNL_YN", $("#CNL_YN").val())
			//param.put("VBELN", $("#VBELN").val()) // 판매문서번호
			//param.put("POSNR", $("#POSNR").val()) // 판매문서 품목번호
			
			gridList.gridList({
		    	id : "gridList",
		    	param : param
		    })
		}
	}
	
	// 버튼 클릭(조회)
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
		}else{
			reportPrint()
		}
	}
	
	// 재단 라벨 재발행
	const reportPrint = () => {
		
		const list = gridList.getSelectData("gridList")
		for(let i = 0; i < list.length; i++){
			list[i].put("IND_BCD",list[i].get("CIND_BCD"))
		}
		
		if(list.length !== 1){
			alert("라벨 재발행 개수는 1개입니다.")
			return
		}
		
		let param = new DataMap()
		param.put("list", list)
		param.put("PRTTYP","MES")
		param.put("LANGKY", "KR")
		param.put("PROGID" , configData.MENU_ID)
		param.put("WAREKY", "<%=wareky%>")
		
		// 이지젠 파일명
		const fileName = "KLRA_WRK27_JAE_LABEL.ezg";
			
		// 라벨
		param.put("LABEL01" , "지종")
		param.put("LABEL02" , "평량")
		param.put("LABEL03" , "규격")
		param.put("LABEL04" , "연수 (R)")
		param.put("LABEL05" , "중량 (kg)")
		param.put("LABEL06" , "Ream/Pallet (R)")
		param.put("LABEL07" , "속당매수 (EA) / 속수")
		param.put("LABEL08" , "SEQ")
		param.put("LABEL09" , "J/R호기")
		param.put("LABEL10" , "M/R호기")
		param.put("LABEL11" , "재단(슬리터)호기")
		param.put("LABEL12" , "포장타입")
		param.put("LABEL13" , "거래처")
		param.put("LABEL14" , "생산일시")
		param.put("LABEL15" , "반")
		param.put("LABEL16" , "작업자")
		param.put("LABEL17" , "Lot No.")
		param.put("LABEL18" , "Sales Order No.")
		param.put("LABEL19" , "지시사항")
		param.put("LABEL20" , "비고")
		
		// 데이터
		param.put("VALUE02", "재단")
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
					<input type="button" id="button-0-3" CB="Label PRINT_OUT BTN_LABEL" />
				</div>
			</div>
			<div class="search_inner">
				<div class="search_wrap ">
				  	<dl>
						<dt CL="STD_PRFM_DT">실적일자</dt>
						<dd><input type="text" name="A.PRFM_DT" id="PRFM_DT" UIInput='B' UIFORMAT="C M1" /></dd>
					</dl>
					<dl>
						<dt CL="STD_MATNR">자재코드</dt>
						<dd>
							<!-- 2023-03-13(월요일) 안상현, 자재코드 RANGE 검색 추가 -->
							<input type="text" id="MATNR" name="MATNR" UIInput="SR,MATKY" UIFormat="U"/>
						</dd>
					</dl>
					<!-- 20230217 여한진 LOT번호, 개별바코드, 거래처코드, 판매문서번호, 판매문서항목번호 -->
					<dl>
						<dt CL="STD_LOT_NO">LOT번호</dt>
						<dd>
							<!-- 2023-03-13(월요일) 안상현, LOT번호 RANGE 검색 추가 -->
							<input type="text" class="input" id="LOT_NO" name="LOT_NO" UIInput="SR" UIFormat="U"/>
						</dd>
					</dl>
					<dl>
						<dt CL="STD_IND_BCD">개별바코드</dt>
						<dd>
							<input type="text" class="input" id="IND_BCD" name="IND_BCD" UIInput="SR,INDBCD" UIFormat="U"/>
						</dd>
					</dl>
					<dl>
						<dt CL="STD_CUST_CD">거래처코드</dt>
						<dd>
							<!-- 2023-03-13(월요일) 안상현, 거래처코드 RANGE 검색 추가 -->
							<input type="text" id="CUST_CD" name="CUST_CD" UIInput="SR,CUST" UIFormat="U"/>
						</dd>
					</dl>
					<dl>
						<dt CL="STD_VBELN">판매문서번호</dt>
						<dd>
							<input type="text" class="input" id="VBELN" name="VBELN" UIInput="SR"/>
						</dd>
					</dl>
					<dl>
						<dt CL="STD_POSNR">판매문서 품목번호</dt>
						<dd>
							<input type="text" class="input" id="POSNR" name="POSNR" UIInput="SR"/>
						</dd>
					</dl>
					<dl>
						<dt CL="STD_PCODE">지종코드</dt>
						<dd>
							<!-- 2023-03-13(월요일) 안상현, 지종코드 RANGE 검색 추가 -->
							<input type="text" class="input" id="PCODE" name="PCODE" UIInput="SR,PCODE" UIFormat="U"/>
						</dd>
					</dl>
					<dl>
						<dt CL="STD_BS_WGT">평량</dt>
						<dd>
							<!-- 2023-03-13(월요일) 안상현, 평량 RANGE 검색 추가 -->
							<input type="text" class="input" id="BS_WGT" name="BS_WGT" UIInput="SR" />
						</dd>
					</dl>
					
					<dl>
						<dt>설비코드</dt>
						<dd>
							<!-- 2023-03-13(월요일) 안상현, 설비코드 검색 추가 -->
							<input type="text" id="MACH_CD" name="MACH_CD" UIInput="SR,MACH" UIFormat="U"/>
						</dd>
					</dl>
					<!-- 20220928 여한진 취소여부 검색조건 추가 -->
					<dl>
						<dt>취소여부</dt>
						<dd>
							<select class='input' id="CNL_YN" name="CNL_YN">
								<option value='N'>N</option>
								<option value='Y'>Y</option>
							</select>
						</dd>
					</dl>
					
					<!-- <dl>
						<dt CL="STD_WLEN"></dt>
						<dd>
							<input type="text" class="input" name="WLEN"/>
						</dd>
					</dl>
					<dl>
						<dt CL="STD_VLEN"></dt>
						<dd>
							<input type="text" class="input" name="VLEN"/>
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
					<li><a href="#tab1-1"><span CL="STD_GRD_WRK27">일반</span></a></li>
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
										<td GH="100" GCol="text,PCODE" style="text-align:center;">지종코드</td>
										<td GH="100" GCol="text,PCODE_NM" style="text-align:center;">지종명</td>
										<td GH="100" GCol="text,BS_WGT" style="text-align:center;">평량</td>
										<td GH="100" GCol="text,WLEN" style="text-align:center;">가로</td>
										<td GH="100" GCol="text,VLEN" style="text-align:center;">세로</td>
										<td GH="140" GCol="text,MATNR" style="text-align:center;">자재코드</td>
										<td GH="100" GCol="text,PACKTYPE" style="text-align:center;">포장타입</td>
										<td GH="100" GCol="text,DOMESTIC" style="text-align:center;">내수/수출</td>
										<td GH='100' GCol='text,CUST_CD' style='text-align:center;'>거래처코드</td>
										<td GH="200" GCol="text,CUST_NM" style="text-align:center;">거래처</td>
										<td GH="100" GCol="text,NTN_NM" style="text-align:center;">국가</td>
										<td GH="100" GCol="text,MLOT_NO" style="text-align:center;">밀롤LOTID</td>
										<td GH="100" GCol="text,MIND_BCD" style="text-align:center;">밀롤바코드</td>
										<td GH="100" GCol="text,MPRD_DT" GF='D' style="text-align:center;">밀롤생산일</td>
										<td GH="120" GCol="text,MACH_NM" style="text-align:center;">설비명</td>
										<td GH="100" GCol="text,MREGNM" style="text-align:center;">밀롤작업자</td>
										<td GH="100" GCol="text,MROLLCNT" GF='N 13'>밀롤권치수</td>
										<td GH='100' GCol='text,MRUNIT' style='text-align:center';>밀롤권치수단위</td>
										<td GH="100" GCol="text,MWIDTH" GF='N 13'>밀롤지폭</td>
										
										<td GH="100" GCol="text,PLT_PER_CNT" style="text-align:center;">팔레트당연수</td>
										<td GH="100" GCol="text,PLTUNIT" style="text-align: center;">연수단위</td>
										
										<td GH="100" GCol="text,LOC_CD" style="text-align:center;">로케이션</td>
										<!-- 20220920 여한진 필요없는 필드 추석처리 -->
										<!-- <td GH="100" GCol="text,CUTTER_NM">커터설비명</td> -->
										<td GH="100" GCol="text,PRD_DT" style="text-align:center;" GF='D'>생산일자</td>
										<td GH="100" GCol="text,PRFM_DT" style="text-align:center;" GF='D'>실적일자</td>
										<td GH="140" GCol="text,PRD_STR_DT" style="text-align:center;">생산시작일</td>
										<td GH="140" GCol="text,PRD_END_DT" style="text-align:center;">생산종료일</td>
										
										<td GH="100 생산시간(MES)" GCol="text,TM2" style="text-align:center;">생산시간(MES)</td>
										<td GH="100 생산시간(SAP)" GCol="text,TM1" style="text-align:center;">생산시간(SAP)</td>
										
										<td GH="120" GCol="text,CMACH_NM" style="text-align:center;">재단설비명</td>
										<td GH="100" GCol="text,WRK_CLASS" style="text-align:center;">반</td>
										<td GH="100" GCol="text,CREGNM" style="text-align:center;">재단작업자</td>
										<td GH="140" GCol="text,CLOT_NO" style="text-align:center;">재단LOTID</td>
										<td GH="140" GCol="text,CIND_BCD" style="text-align:center;">재단바코드</td>
										<td GH="100" GCol="text,CPRFM_QTY" GF='N 13'>재단실적</td>
										<td GH="100" GCol="text,CUNIT" style="text-align:center;">재단실적단위</td>
										
										<td GH="100" GCol="text,CPCNT" GF='N 13,3'>재단실적연수</td>
										<td GH="100" GCol="text,CRUNIT" style="text-align: center;">재단연수단위</td>
										
										<td GH="100" GCol="text,CWGT" GF='N 13,3'>재단사용중량</td>
										<td GH="100" GCol="text,CWUNIT" style="text-align: center;">재단중량단위</td>
										
										<td GH="100" GCol="text,IN_PER_CNT" GF="N 13,3"></td>
										<td GH="100" GCol="text,CEUNIT" style="text-align: center;">단위</td>
										
										<td GH="140" GCol="text,DISPO_CD" style="text-align:center;"></td>
										<td GH="100" GCol="text,DISPO_PCNT" GF="N 13,3"></td>
										<td GH="100" GCol="text,DIRUNIT" style="text-align: center;">폐품연수단위</td>
										
										<td GH="100" GCol="text,DISPO_WGT" GF="N 13,3"></td>
										<td GH="100" GCol="text,DIWUNIT" style="text-align: center;">폐품중량단위</td>
										
										<td GH="60" GCol="text,CNL_YN" style="text-align:center;">취소여부</td>
										<td GH="100" GCol="text,VBELN" style="text-align:center;">판매문서번호</td>	
										<td GH="100" GCol="text,POSNR" style="text-align:center;">판매문서품목번호</td>
										<td GH="100" GCol="text,SDOC_NO" style="text-align:center;">SAP확정문서번호</td>
										<td GH="100" GCol="text,SDOC_SEQNO" style="text-align:center;">SAP확정문서번호순번</td>
										<td GH="100" GCol="text,RMK">비고</td>
										<td GH="100" GCol="text,CUT_COMP_YN" style="text-align:center;">재단완료여부</td>
										<td GH="100" GCol="text,MIL_COMP_YN" style="text-align:center;">밀롤완료여부</td>
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