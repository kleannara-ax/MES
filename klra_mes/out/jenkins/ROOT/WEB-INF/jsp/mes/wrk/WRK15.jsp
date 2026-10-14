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
	    	url : "/mes/Work/WRK15/json/datalist.data",
	    	bigdata : false,
	    	colHoldType : true,
	    	colHold : "LOC_NM,MACHINE,PRD_DT,PRD_NO"
	    });
	});

	function comboEventDataBindeBefore(comboAtt){
		if(comboAtt == "Produce,MACHINE"){
			var param = new DataMap();
			
			param.put("WERKS", "P100");
		}
		return param;
	}
	// 조회
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
	
	// 버튼 클릭(저장, 라벨 재발행)
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
	
	// 라벨 재발행
	const reportPrint = () => {
		const list = gridList.getSelectData("gridList")
		
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
		
		// 라벨 초기값(점보롤)
		param.put("LABEL01", "지종")
		param.put("LABEL02", "평량")
		param.put("LABEL03", "길이(M)")
		param.put("LABEL04", "계획권치수 (M)")
		param.put("LABEL05", "실적중량")
		param.put("LABEL06", "J/R호기")
		param.put("LABEL07", "M/R지시호기")
		param.put("LABEL08", "생산시간")
		param.put("LABEL09", "시작")
		param.put("LABEL10", "종료")
		param.put("LABEL11", "가동시간")
		param.put("LABEL12", "생산유형")
		param.put("LABEL13", "생산일시")
		param.put("LABEL14", "반")
		param.put("LABEL15", "작업자")
		param.put("LABEL16", "Lot No.")
		param.put("LABEL17", "생산번호")
		param.put("LABEL18", "선속 (M/분)")
		param.put("LABEL19", "지시사항")
		param.put("LABEL20", "비고")
		
		// 이지젠 파일명 초기값(밀롤, 점보롤)
		let fileName = "KLRA_WRK15_JUM_LABEL.ezg";
		
		// 개별바코드
		const IND_BCD = list[0].get("IND_BCD").substr(9, 2)
		
		// 밀롤 : 바코드 10자리, 나머지 : 바코드 15자리
		const len = list[0].get("IND_BCD").length
		
		if(len === 10){
			fileName = "KLRA_WRK15_MIL_LABEL.ezg";
			
			param.put("LABEL01", "지종")
			param.put("LABEL02", "실적권치수 (M)")
			param.put("LABEL03", "실적중량 (Kg)")
			param.put("LABEL04", "평량")
			param.put("LABEL05", "ReWinder규격")
			param.put("LABEL06", "규격")
			param.put("LABEL07", "Ream/Pallet (R)")
			param.put("LABEL08", "속당매수 (EA) / 속수")
			param.put("LABEL09", "SEQ")
			param.put("LABEL10", "J/R호기")
			param.put("LABEL11", "M/R호기")
			param.put("LABEL12", "재단(슬리터)호기")
			param.put("LABEL13", "포장타입")
			param.put("LABEL14", "거래처 :")
			param.put("LABEL15", "지폭순번")
			param.put("LABEL16", "생산일자")
			param.put("LABEL17", "반")
			param.put("LABEL18", "작업자")
			param.put("LABEL19", "Lot No.")
			param.put("LABEL20", "Sales Order No.")
			param.put("LABEL21", "지시사항")
			param.put("LABEL22", "비고")
			
			param.put("VALUE02","밀롤")
		}else{
			// 점보롤
			if(IND_BCD === "J2" || IND_BCD === "J3"){
				param.put("VALUE02","점보롤")
			// 재단, 수재단
			}else if(IND_BCD === "C9"){
				fileName = "KLRA_WRK15_JAE_LABEL.ezg";
				
				// 라벨(재단, 수재단)
				param.put("LABEL01", "지종")
				param.put("LABEL02", "평량")
				param.put("LABEL03", "규격")
				param.put("LABEL04", "연수 (R)")
				param.put("LABEL05", "중량 (kg)")
				param.put("LABEL06", "Ream/Pallet (R)")
				param.put("LABEL07", "속당매수 (EA) / 속수")
				param.put("LABEL08", "SEQ")
				param.put("LABEL09", "J/R호기")
				param.put("LABEL10", "M/R호기")
				param.put("LABEL11", "재단(슬리터)호기")
				param.put("LABEL12", "포장타입")
				param.put("LABEL13", "거래처")
				param.put("LABEL14", "생산일시")
				param.put("LABEL15", "반")
				param.put("LABEL16", "작업자")
				param.put("LABEL17", "Lot No.")
				param.put("LABEL18", "Sales Order No.")
				param.put("LABEL19", "지시사항")
				param.put("LABEL20", "비고")
				
				param.put("VALUE02", "재단")
			}else{
				alert("파일 형식이 존재하지 않습니다.")
				return
			}
		}
		
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
						<dt CL="STD_MACHINE">생산호기</dt>
						<dd>
							<select class="input" name="MACHINE" Combo="Produce,MACHINE">
								<option value="">All</option>
							</select>
						</dd>
					</dl>
					<dl>
						<dt CL="STD_LOC_CD">로케이션 코드</dt>
						<dd>
							<select class="input" name="LOC_CD" CommonCombo="LOC_CD">
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
					<li><a href="#tab1-1"><span>일반</span></a></li>
					<li class="btn_zoom_wrap">
						<ul>
							<li>
								<button class="btn btn_bigger">
									<span>확대</span>
								</button>
							</li>
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
										<td GH="100" GCol="text,LOC_CD">로케이션코드</td>
										<td GH="200" GCol="text,LOC_NM">로케이션명</td>
										<td GH="80" GCol="text,MACHINE" style="text-align: center;">호기-생산설비(생산호기)</td>
										<td GH="100" GCol="text,PRD_DT" GF="C" style="text-align:center;">작업일</td>
										<td GH="150" GCol="text,PRD_NO" style="text-align: center;">생산번호</td>
										<td GH="150" GCol="text,LOT_NO" style="text-align: center;">LOT번호</td>
										<td GH="150" GCol="text,IND_BCD" style="text-align: center;">개별바코드</td>
										<td GH="100" GCol="text,DOMESTIC_NM" style="text-align: center;">내수구분(명)</td>
										<td GH="100" GCol="text,PCODE" style="text-align: center;">지종</td>
										<td GH="100" GCol="text,PCODE_NM" style="text-align: center;">지종명</td>
										<td GH="100" GCol="text,BS_WGT" GF="N 5">평량</td>
										<td GH="100" GCol="text,WLEN" GF="N 5">가로길이</td>
										<td GH="100" GCol="text,VLEN" GF="N 5">세로길이</td>
										<td GH="100" GCol="text,ROLLCNT" GF="N 5">권치수</td>
										<td GH="100" GCol="text,PCNT" GF="N 5">연수</td>
										<td GH="100" GCol="text,WGT" GF="N 5">중량</td>
										<td GH="100" GCol="text,PRD_PRFM" GF="C" style="text-align:center;">생산실적일자</td>
										<td GH="150" GCol="text,MACH_NM" style="text-align: center;">설비명</td>
										<td GH="200" GCol="text,MATNR" style="text-align: center;">자재코드</td>
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