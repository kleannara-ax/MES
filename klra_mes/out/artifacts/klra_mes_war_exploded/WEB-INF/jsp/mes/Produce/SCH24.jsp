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
	var isAutoUpdating = false;
	
	$(document).ready(function(){
		gridList.setGrid({
			id : "gridList",
	    	url : "/mes/Produce/SCH24/json/datalist.data",
	    	bigdata : false,
	    	pkcol :"WERKS",
	    	colHoldType : true,
	    	colHold : "PRD_REQ_DT,WRK_ORDR_NO,WRK_ORDR_SEQNO,MATNR,MATNR_NM",
	    	colorType : true,
	    	colGroupCols : "WRK_ORDR_NO"
	    });
		
		// 오더유형 select 제어
		$("#ORDER_DIV").find("option").map(function(){
			const text = $(this).text();
			const value = $(this).val();
			
			//제지 중 예외생산 해당 하는 값만 나타내기 ZP12, ZP13, ZP14
			if((text.indexOf("제지") === -1 && text.indexOf("All") === -1) || value == 'ZP11'){
				$(this).remove()
			}
		});
		
		
		// 1. 조회 버튼 클릭 이벤트 핸들러
	    $('#Search').on('click', function() {
	        
	        // [참고] 만약 Ajax로 데이터를 가져온다면, 
	        // 데이터가 화면에 모두 그려진(Append 완료된) 직후에 아래 로직을 실행해야 합니다.
	        setTimeout(function() { 
	            applyOrderDivPolicy();
	        }, 300); // 렌더링 시간을 고려한 미세한 지연 (Ajax 사용 시 콜백에 넣는 것이 베스트)
	    });

	    // 2. 정책 적용 함수 (재사용 가능하도록 분리)
	    function applyOrderDivPolicy() {
	        // 헤더에서 'ORDER_DIV' 컬럼 인덱스 찾기
	        var colIdx = $('#workTable th').filter(function() {
	            return $(this).text().trim() === 'ORDER_DIV';
	        }).index();

	        if (colIdx !== -1) {
	            var childNum = colIdx + 1;

	            $('#workTable tbody tr').each(function() {
	                var $row = $(this);
	                var orderDivValue = $row.find('td:nth-child(' + childNum + ')').text().trim();

	                // 'ZP14'인 경우만 select 활성화
	                if (orderDivValue === 'ZP14') {
	                    $row.find('select').prop('disabled', false);
	                } else {
	                    $row.find('select').prop('disabled', true);
	                }
	            });
	            console.log("ORDER_DIV 정책 적용 완료");
	        }
	    }
	});
	
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
	
	// 버튼(조회, 저장 등) 클릭
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
		}else if(btnName == "Save"){
			saveData();
		}
	}
	
	// 저장
	function saveData(){
		if(gridList.getModifyRowCount("gridList") == 0 ){
			commonUtil.msgBox("MASTER_M0545");
			return;
		}
		
		if(!commonUtil.msgConfirm(configData.MSG_MASTER_SAVE_CONFIRM)){
			return;
		}
		
		if(gridList.validationCheck("gridList", "all")){
			var modifyList = gridList.getModifyList("gridList", "A");
		
			var param = new DataMap();
			
			param.put("P_TYPE","SAVE");
			param.put("list", modifyList);
		
			var json = netUtil.sendData({
				url : "/mes/Produce/SCH24/json/datalist.data",
				param : param
			});
			if(json){
				if(json.data){
					searchList();
				}
			}
		}
	}
	
	// 2022-10-18(일요일) 안상현, 사용여부가 "미사용"인 경우 오렌지로 라인 표시
 	function gridListRowColorChange(gridId, rowNum, rowData){
		if(gridId === "gridList" && rowData.get("USE_YN") === "미사용"){
			return configData.GRID_COLOR_BG_ORANGE_CLASS;
		}
 	}
	
 	function gridListEventColValueChange(gridId, rowNum, colName, colValue) {
        console.log("그리드:", gridId, "행:", rowNum, "컬럼:", colName, "값:", colValue);
        
        if (isAutoUpdating) return;
        if(gridId === "gridList"){
            if(colName === "CORE_INCH" && colValue === '-'){
                if(commonUtil.msgConfirm('지관사이즈 미선택시 지관마개, 골판지, 포장 여부 초기화 됩니다. 미선택 하시겠습니까?')){
                	isAutoUpdating = true; // [LOCK 시작]
                	
                    // 3. COVER_YN, CORR_YN, PACK_YN 값을 '-'로 변경
                    gridList.setColValue(gridId, rowNum, "COVER_YN", "-");
                    gridList.setColValue(gridId, rowNum, "CORR_YN",  "-");
                    gridList.setColValue(gridId, rowNum, "PACK_YN",  "-");
                    
                    isAutoUpdating = false; // [LOCK 해제]
                }
            }
            else if(colName === "COVER_YN" || colName === "CORR_YN" || colName === "PACK_YN"){
                var coreInch = gridList.getColData(gridId, rowNum, "CORE_INCH");
                if(coreInch == "-"){
                    alert("지관사이즈(인치) 먼저 선택해주세요");

                    isAutoUpdating = true; // [LOCK 시작]
                    gridList.setColValue(gridId, rowNum, colName,  "-");
                    isAutoUpdating = false; // [LOCK 해제]

                    return;
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
					<input type="button" id="button-0-2" CB="Save SAVE BTN_SAVE" />
				</div>
			</div>
			<div class="search_inner">
				<div class="search_wrap ">
				  	<dl>
						<dt CL="STD_PLANT">플랜트</dt>
						<dd>							
							<input type="text" class="input" id="WERKS" name="WERKS" value="P100" readonly />
						</dd>
					</dl>
					<dl>
						<dt CL="STD_PRD_REQ_DT">생성요청일자</dt>
                        <dd>
                        	<input type="text" name="PRD_REQ_DT" UIInput="B" UIFORMAT="C M1"/>
                        </dd>
					</dl>
					<!-- 20230213 여한진 오더번호, 오더유형, 변경전 자재코드, 변경후 자재코드, 하역지점, 완료여부 검색조건 추가-->
					<dl>
						<dt CL="STD_ORDER_NO">오더번호</dt>
                        <dd>
                        	<input type="text" class="input" name="ORDER_NO" UIInput="SR" UIFORMAT="U" />
                        </dd>
					</dl>
					<dl>
						<dt CL='STD_ORDER_DIV'>오더유형</dt>
						<dd>
							<select class="input" id='ORDER_DIV' name="ORDER_DIV" CommonCombo='ORDER_DIV'>
								<option value="">All</option>
							</select>
						</dd>
					</dl>
					<dl>
						<dt>변경 전 자재코드</dt>
						<dd>
							<input type="text" name="SCH020.MATNR" UIInput="SR,MATKY" UIFormat="U"/>
						</dd>
					</dl>
					<dl>
						<dt>변경 후 자재코드</dt>
						<dd>
							<input type="text" name="SCH019.MATNR" UIInput="SR,MATKY" UIFormat="U"/>
						</dd>
					</dl>
					<dl>
						<dt CL='STD_DELIPOT'>하역지점</dt>
						<dd>
							<select class="input" name='DELIPOT' CommonCombo='DELIPOT'>
								<option value="">All</option>
							</select>
						</dd>
					</dl>
					<dl>
						<dt>완료여부</dt>
						<dd>
							<select class="input" name='COMP_YN' CommonCombo='COMP_YN'>
								<option value="">All</option>
							</select>
						</dd>
					</dl>
					<dl>
						<dt>지시생성일자</dt>
                        <dd>
                        	<input type="text" name="ORDR_GEN_DT" UIInput="B" UIFORMAT="C"/>
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
					<li><a href="#tab1-1"><span CL="STD_GRD_SCH24">일반</span></a></li>
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
										<td GH="100" GCol="text,PRD_REQ_DT" GF="C" style="text-align: center;">생산요청일</td>
										<td GH="150" GCol="text,WRK_ORDR_NO" style="text-align: center;">작업지시번호</td>
										<td GH="80" GCol="text,WRK_ORDR_SEQNO" style="text-align:center;">지시순번</td>
										<td GH="140" GCol="text,MATNR" style="text-align: center;" >자재코드</td>
										<td GH="320" GCol="text,MATNR_NM" style="text-align: center;">자재명</td>
										<td GH="100" GCol="text,WERKS" style="text-align:center;">플랜트</td>
										<td GH="100" GCol="text,ORDER_NO" style="text-align: center;">오더번호</td>
										<td GH="80" GCol="text,WRK_SEQNO" style="text-align: center;">작업순서</td>
										<td GH='120' Gcol='text,ORDER_DIV' style="text-align: center;">오더유형</td>
										<td GH="100" GCol="text,WRK_ORDR_QTY" GF="N 10,3">지시량</td>
										<td GH="100" GCol="text,ORDR_UNIT" style="text-align:center;">지시량단위</td>
										
										<td GH="250" GCol="text,WRK_ORDR_REMARK">작업지시비고</td>
										<!-- 20221222 여한진 하위 컬럼 3개 추가 -->
										<td GH='100' GCol='text,PRE_CHG_SPEC' style="text-align: center;">변경 전 규격</td>
										<td GH='100' GCol='text,AFTER_CHG_SPEC' style="text-align: center;">변경 후 규격</td>
										<td GH='100' GCol='text,DELIPOT' style="text-align: center;">하역지점</td>
										
										<td GH="100" GCol="text,USE_YN" style="text-align: center;">사용여부</td>
										<td GH="100" GCol="text,COMP_YN" style="text-align: center;">사용여부</td>
										<!-- <td GH="100" GCol="text,MACHINE" style="text-align: center;">생산호기</td> -->
										<td GH="100" GCol="text,ORDR_QTY" GF="N 10,3">오더량</td>
										<td GH="100 오더단위" GCol="text,OORDR_UNIT" style="text-align:center;">오더단위</td>
										
										<td GH="100" GCol="text,ORDR_GEN_DT" GF="C" style="text-align:center;">작업지시일자</td>
										<!-- <td GH="100" GCol="text,COMP_QTY" GF="N 10">완료수량</td> -->
										<!-- <td GH="150" GCol="text,PRD_STR_DTM" style="text-align:center;">생산시작시간</td> -->
										<td GH="150" GCol="text,PRD_END_DTM" style="text-align:center;">생산완료시간</td>
										<td GH="100" GCol="text,PCODE" style="text-align: center;" >지종코드</td>
										<td GH="100" GCol="text,PCODE_NM" style="text-align: center;">지종코드명</td>
										<td GH="100" GCol="text,BS_WGT" style="text-align: center;">평량</td>
										<td GH="100" GCol="text,WLEN" style="text-align: center;">가로길이</td>
										<td GH="100" GCol="text,VLEN" style="text-align: center;">세로길이</td>
										<td GH="100" GCol="text,PLT_PER_CNT" GF="N 10" style="text-align: center;">팔레트당연수</td>
										<td GH="100" GCol="text,IN_PER_CNT" GF="N 10" style="text-align: center;">속당매수</td>
										<td GH="100" GCol="text,MCNT" style="text-align: center;">매</td>
										<td GH="100" GCol="text,SCNT" GF='N 5,1' style="text-align: center;">속</td>
										<td GH="100" GCol="text,KUNNR" style="text-align: center;">판매처코드</td>
										<td GH="140" GCol="text,KUNNRT" style="text-align: center;">판매처</td>
										<td GH="100" GCol="select,CORE_INCH">
											<select class="input" CommonCombo="CORE_INCH" style="text-align: center;">	<!-- 지관사이즈(인치) -->
												<option value="-">-</option>
												<option value="3">3</option>
												<option value="6">6</option>
												<option value="12">12</option>
											</select>
										</td>
                                        <td GH="100" GCol="select,COVER_YN">
											<select class="input" CommonCombo="COVER_YN" style="text-align: center;">	<!-- 지관마개여부 -->
												<option value="-">-</option>
												<option value="사용">사용</option>
												<option value="미사용">미사용</option>
											</select>
										</td>
                                        <td GH="100" GCol="select,CORR_YN">
											<select class="input" CommonCombo="CORR_YN" style="text-align: center;">	<!-- 골판지여부 -->
												<option value="-">-</option>
												<option value="사용">사용</option>
												<option value="미사용">미사용</option>
											</select>
										</td>
                                        <td GH="100" GCol="select,PACK_YN">
											<select class="input" CommonCombo="PACK_YN" style="text-align: center;">	<!-- 포장여부 -->
												<option value="-">-</option>
												<option value="사용">사용</option>
												<option value="미사용">미사용</option>
											</select>
										</td>
										<!-- <td GH="100" GCol="text,MACH_CD" style="text-align: center;">설비코드</td>
										<td GH="140" GCol="text,MACH_NM" style="text-align: center;">설비명</td> -->
										<td GH="150" GCol="text,REGDATE" style="text-align: center;">등록일시</td>
										<!-- <td GH="100" GCol="text,REGNM">등록자</td> -->
										<td GH="150" GCol="text,UPDDATE">수정일시</td>
										<td GH="100" GCol="text,UPDNM">수정자</td>		
									</tr>
								</tbody>
							</table>
						</div>
					</div>
					<jsp:include page="/WEB-INF/jsp/common/commonBtnAuth.jsp">
						<jsp:param name="authCd" value="1" />
						<jsp:param name="showAuthCd" value="1,2,3,5,7,9,10" />
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