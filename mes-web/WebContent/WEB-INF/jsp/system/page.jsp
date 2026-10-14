<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html xml:lang="ko" lang="ko">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<meta http-equiv="X-UA-Compatible" content="IE=edge" />
<title>Template</title>
<%@ include file="/ahcs/include/head.jsp" %>
<script>
	$(document).ready(function(){
		gridList.setGrid({
	    	id : "gridList",
			url : "/ahcs/json/SQL_COLOBJ_LIST.data",
			bigdata : false,
			defaultRowStatus : configData.GRID_ROW_STATE_INSERT
	    });
	});
	
	function searchList(){
		var param = inputList.setRangeParam("searchArea");
		
		gridList.gridList({
	    	id : "gridList",
	    	param : param
	    });
	}
	
	function saveData(){
		if(gridList.validationCheck("gridList", "all")){
			var list = gridList.getGridAvailData("gridList");
			var param = inputList.setRangeParam("searchArea");
			param.put("list", list);
			var json = netUtil.sendData({
		    	url : "/ahcs/json/SQL_COLOBJ_SAVE.data",
		    	param : param
		    });
			if(json.MSG && json.MSG != 'OK'){
				var msgList = json.MSG.split(" ");
				var msgTxt = commonUtil.getMsg(msgList[0], msgList.pop());
				commonUtil.msg(msgTxt);
			}else if(json.data){
				commonUtil.msgBox("MASTER_M0564");
			}

			commonUtil.popupOpen("/common/tool/pagecreate/grid.page");
		}
	}
</script>
</head>
<body>
<%@ include file="/ahcs/include/top.jsp" %>
	<!-- 본문 시작 -->
        <p class="btn_b">
            <a href="#" class="search" onclick="searchList()">조회</a>
            <a href="#" class="reset">초기화</a>
        </p>
        <div class="search_wrap" id="searchArea">
            <!-- 일반검색 시작 -->
            <dl class="search_basics">
                <dt><span><label for="MODULE">MODULE</label></span></dt>
                <dd>
                    <input id="MODULE" class="search_box" name="MODULE" type="text" IAname="MODULE">
                </dd>
                <dt><span><label for="COMMAND">COMMAND</label></span></dt>
                <dd>
                    <input id="COMMAND" class="search_box" name="COMMAND" type="text">
                </dd>
                <dt><span>SQL</span></dt>
                <dd>
                    <textarea rows="10" cols="100" name="sql" validate="required"></textarea>
                </dd>
            </dl>
            <!-- 일반검색 끝 -->
        </div>
        <div class="h4_wrap last">
            <div class="title">
                <h4>딕셔너리 목록</h4>
            </div>
            <div class="grid_scroll g1 section">
                <p class="btn_m tableUtil">
                    <span class="row_control">
                        <a href="#" class="add" GBtn="add">추가</a>
                        <a href="#" class="copy" GBtn="copy">복사</a>
                    </span>
                    <a href="#" class="on" onclick="saveData()">저장</a>
                </p>
                <div class="grid_head">
                    <table class="tableHeader">
                        <colgroup>
                            <col width="40" />
							<col width="100" />
							<col width="100" />
							<col width="100" />
							<col width="100" />
							<col width="100" />
							<col width="100" />
							<col width="100" />
							<col width="100" />
							<col width="100" />
							<col width="100" />
							<col width="100" />
							<col width="100" />
							<col width="100" />
							<col width="100" />
							<col width="100" />
							<col width="100" />
							<col width="100" />
							<col width="100" />
							<col width="100" />
							<col width="100" />
                        </colgroup>
                        <thead>
                            <tr>
                            	<th>번호</th>
								<th>딕셔너리ID</th>
								<th>딕셔너리명</th>
								<th>라벨ID</th>
								<th>라벨명</th>
								<th>데이터유형코드</th>
								<th>데이터크기</th>
								<th>소수점크기</th>
								<th>정열코드</th>
								<th>출력크기</th>
								<th>조회항목코드</th>
								<th>범위조회코드</th>
								<th>조회항목내용</th>
								<th>조회항목순서</th>
								<th>입력불가여부</th>
								<th>검색필수입력여부</th>
								<th>검색기본값</th>
								<th>그리드항목코드</th>
								<th>그리드항목내용</th>
								<th>그리드항목순서</th>
								<th>그리드필수입력여부</th>
                            </tr>
                        </thead>
                    </table>
                </div>
                <div class="grid_body list_20 tableBody">
                    <table>
                        <colgroup>
                            <col width="40" />
							<col width="100" />
							<col width="100" />
							<col width="100" />
							<col width="100" />
							<col width="100" />
							<col width="100" />
							<col width="100" />
							<col width="100" />
							<col width="100" />
							<col width="100" />
							<col width="100" />
							<col width="100" />
							<col width="100" />
							<col width="100" />
							<col width="100" />
							<col width="100" />
							<col width="100" />
							<col width="100" />
							<col width="100" />
							<col width="100" />
                        </colgroup>
                        <tbody id="gridList">
                            <tr CGRow="true">
                                <td GCol="rownum">1</td>
								<td GCol="text,DIC_ID"></td>
								<td GCol="input,DIC_NM" validation="required"></td>
								<td GCol="input,LBL_ID" validation="required"></td>
								<td GCol="input,LBL_CN" validation="required"></td>
								<td GCol="text,DATA_TP_CD"></td>
								<td GCol="input,DATA_SIZE" GF="N" validation="required"></td>
								<td GCol="input,DCPT_SIZE" GF="N"></td>
								<td GCol="select,ALIGN_CD">
									<select>
										<option value="LEFT">LEFT</option>
										<option value="CENTER">CENTER</option>
										<option value="RIGHT">RIGHT</option>
									</select>
								</td>
								<td GCol="input,OUTP_SIZE" GF="N" validation="required min(50) max(300)"></td>
								<td GCol="select,INQ_ATCL_CD">
									<select>
										<option value=""></option>
										<option value="STRING">STRING</option>
										<option value="NUMBER">NUMBER</option>
										<option value="DATE">DATE</option>
										<option value="TIME">TIME</option>
										<option value="SELECT">SELECT</option>
										<option value="CHECK">CHECK</option>
									</select>
								</td>
								<td GCol="select,RNG_INQ_CD">
									<select>
										<option value=""></option>
										<option value="R">R</option>
										<option value="B">B</option>
									</select>
								</td>
								<td GCol="input,INQ_ATCL_CN"></td>
								<td GCol="input,INQ_ATCL_SQNM" GF="N"></td>
								<td GCol="check,ENT_IMPS_YN"></td>
								<td GCol="check,SRH_NSE_YN"></td>
								<td GCol="input,SRH_BAC_VAL"></td>
								<td GCol="select,GRID_ATCL_CD">
									<select>
										<option value="STRING">STRING</option>
										<option value="NUMBER">NUMBER</option>
										<option value="DATE">DATE</option>
										<option value="TIME">TIME</option>
										<option value="SELECT">SELECT</option>
										<option value="CHECK">CHECK</option>
									</select>
								</td>
								<td GCol="input,GRID_ATCL_CN"></td>
								<td GCol="input,GRID_ATCL_SQNM" GF="N"></td>
								<td GCol="check,RSLT_CLUM_YN"></td>
                            </tr>
                        </tbody>
                    </table>
                </div>
                <div class="grid_control tableUtil">
                    <div class="left_wrap">총 조회건수<span GInfoArea="true">9,999,999</span></div>
                    <div class="right_wrap">
                        <div class="page_num"><span>9,999,999</span> / 9,999,999</div>
                        <div class="search_wrap">
                            <span class="search_box input_skipTitle">
                                <label for="grid_search">검색어 입력</label>
                                <input id="grid_search" name="" type="text"><a href="#" class="btn">검색</a>
                            </span>
                            <a class="prev" href="#">이전</a>
                            <a class="next" href="#">다음</a>
                        </div>
                        <div class="util">
                            <a class="btn1" href="#">새로고침</a>
                            <a class="btn2 open_grid_pop_layout" href="#" GBtn="layout">정렬</a>
                            <a class="btn3" href="#" GBtn="total">합계</a>
                            <a class="btn4" href="#" GBtn="excel">다운로드</a>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    <!-- 본문 끝 -->
<%@ include file="/ahcs/include/bottom.jsp" %>
</body>
</html>