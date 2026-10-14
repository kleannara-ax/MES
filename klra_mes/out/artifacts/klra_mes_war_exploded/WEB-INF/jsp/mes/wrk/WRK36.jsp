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
			url : "/mes/Work/WRK36/json/datalist.data",
			bigdata : false,
			colHoldType : true,
	        colHold : "LOT_NO,IND_BCD,MR_LOT_NO,JR_LOT_NO"
	    });
	});

	function comboEventDataBindeBefore(comboAtt){
		if(comboAtt == "Produce,MACHINE"){
			var param = new DataMap();
			
			param.put("WERKS", 'P100');
		}
		return param;
	}
	
	// 조회
	function searchList(){
		if(validate.check("searchArea")){
			// 2023-03-13(월요일) 안상현, RANGE 검색 추가
			/*const range = inputList.setRangeParam("searchArea")
			const range_data_param = range.get("RANGE_DATA_PARAM")
			const prfm_dt = range_data_param.get("W002.PRFM_DT_Range")
			const date = prfm_dt.split("↓")
			const SDate = date[1]
			const EDate = date[2]
			
			const param = inputList.setRangeParam("searchArea") */
			
			var param = inputList.setRangeParam("searchArea");
			param.put("P_TYPE", "LIST")
			/* param.put("SDATE", SDate)
			param.put("EDATE", EDate) */
			param.put("MACHINE", $("#MACHINE").val()) // 생산호기
			param.put("STA", $("#STA").val()) // 상태
			
			gridList.gridList({
		    	id : "gridList",
		    	param : param
		    })
			/* 
			var param = inputList.setRangeParam("searchArea");
			param.put("P_TYPE","LIST");
			
			gridList.gridList({
				id : "gridList",
				param : param
			});
			*/
		}
	}
	
	// 버튼을 클릭한 경우
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
				</div>
			</div>
			<div class="search_inner">
				<div class="search_wrap ">
					<dl>
						<dt>재단일자</dt>
						<dd>
							<input type="text" class="input" name="A.PRFM_DT"  UIInput="B" UIFORMAT="C M1"/>
						</dd>
					</dl>
					<dl>
						<dt CL="STD_MACHINE">생산호기</dt>
						<dd>
							<select class="input" id="MACHINE" name="MACHINE" Combo="Produce,MACHINE">
								<option value="">All</option>
							</select>
						</dd>
					</dl>
					<dl>
						<dt CL="STD_PCODE">지종코드</dt>
						<dd>
							<!-- 2023-03-13(월요일) 안상현, 지종코드 RANGE 검색 추가 -->
							<input type="text" class="input" name="S017.PCODE" UIInput="SR,PCODE" UIFormat="U"/>
						</dd>
					</dl>
					<dl>
						<dt CL="STD_BS_WGT">평량</dt>
						<dd>
							<!-- 2023-03-13(월요일) 안상현, 평량 RANGE 검색 추가 -->
							<input type="text" class="input" name="S017.BS_WGT" UIInput="SR" />
						</dd>
					</dl>
					<dl>
						<dt CL="STD_WLEN">가로</dt>
						<dd>
							<!-- 2023-03-13(월요일) 안상현, 가로 RANGE 검색 추가 -->
							<input type="text" class="input" name="S017.WLEN" UIInput="SR" />
						</dd>
					</dl>
					<dl>
						<dt CL="STD_VLEN">세로</dt>
						<dd>
							<!-- 2023-03-13(월요일) 안상현, 세로 RANGE 검색 추가 -->
							<input type="text" class="input" name="S017.VLEN" UIInput="SR" />
						</dd>
					</dl>
					<dl>
						<dt CL="STD_STA">상태</dt>
						<dd>
							<select class="input" id="STA" name="STA" CommonCombo="STCK_STA">
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
					<li><a href="#tab1-1"><span CL="STD_GRD_WRK36">리스트</span></a></li>
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
							<table class="table_b">
								<tbody id="gridList">
									<tr CGRow="true">
										<td GH="40" GCol="rownum">1</td>
										<td GH="100" GCol="text,LOT_NO" style="text-align:center;">재단LOTID</td>
										<td GH="140" GCol="text,IND_BCD" style="text-align:center;">재단바코드</td>
										<td GH="100" GCol="text,MR_LOT_NO" style="text-align:center;">MRLOT</td>
										<td GH="100" GCol="text,JR_LOT_NO" style="text-align:center;">JRLOT</td>
										<td GH="140" GCol="text,MATNR" style="text-align:center;">자재코드</td>
										<td GH="100" GCol="text,PACKTYPE">포장타입</td>
										<td GH="100" GCol="text,PCODE" style="text-align:center;">지종코드</td>
										<td GH="100" GCol="text,BS_WGT" GF='N 13,3'>평량</td>
										<td GH="100 연수" GCol="text,PCNT" GF='N 13,2'>연수</td>
										<td GH="100" GCol="text,CRUNIT" style="text-align: center;">수량단위</td>
										
										<td GH="100" GCol="text,WGT"  GF='N 13,3'>중량</td>
										<td GH="100" GCol="text,WUNIT" style="text-align: center;">중량단위</td>
										
										<td GH="100" GCol="text,PLT_PER_CNT"  GF='N 13'>팔레트연수</td>
										<td GH="100" GCol="text,WLEN" GF="N 4,0">가로</td>
										<td GH="100" GCol="text,VLEN" GF="N 4,0">세로</td>
										<td GH="100" GCol="text,VBELN">판매문서</td>
										<td GH="100" GCol="text,POSNR">판매문서순번</td>
										<td GH="100" GCol="text,KUNNRT">거래처명</td>
										<td GH="100" GCol="text,ROUTE">항차번호</td>
										<td GH="240" GCol="text,RMK">비고</td>
										<td GH="100" GCol="text,STA">상태</td>
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