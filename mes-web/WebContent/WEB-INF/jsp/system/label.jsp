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
	    	module : "Common",
			command : "LABEL"
	    });
	});
	
	function searchList(){
		if(validate.check("searchArea")){
			var param = inputList.setRangeParam("searchArea");

			gridList.gridList({
		    	id : "gridList",
		    	param : param
		    });
		}
	}
	
	function saveData(){
		if(gridList.validationCheck("gridList", "modify")){
			gridList.gridSave({
		    	id : "gridList"
		    });
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
                <dt><span><label for="LANG_CD">언어코드</label></span></dt>
                <dd>
                    <input id="LANG_CD" class="search_box" name="LANG_CD" type="text">
                </dd>
                <dt><span><label for="LBL_GRP_ID">라벨그룹ID</label></span></dt>
                <dd>
                    <input id="LBL_GRP_ID" class="search_box" name="LBL_GRP_ID" type="text">
                </dd>
                <dt><span><label for="LBL_ID">라벨ID</label></span></dt>
                <dd>
                    <input id="LBL_ID" class="search_box" name="LBL_ID" type="text">
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
						<select name="g1" onChange="grid_list(1)">
							<option value="10">10 보기</option>
							<option value="20">20 보기</option>
							<option value="50">50 보기</option>
							<option value="100">100 보기</option>
						 </select>
                        <a href="#" class="add" GBtn="add">추가</a>
                        <a href="#" class="copy" GBtn="copy">복사</a>
                    </span>
                    <a href="#" class="on" onclick="saveData()">저장</a>
                </p>
                <div class="grid_head tableHeader">
                    <table>
                        <colgroup>
                            <col width="60" />
							<col width="100" />
							<col width="150" />
							<col width="150" />
							<col width="150" />
							<col width="100" />
							<col width="100" />
							<col width="100" />
							<col width="100" />
							<col width="100" />
                        </colgroup>
                        <thead>
                            <tr>
                            	<th>번호</th>
                                <th>언어코드</th>
								<th>딕셔너리명</th>
								<th>라벨ID</th>
								<th>라벨명</th>
								<th>데이터유형코드</th>
								<th>데이터크기</th>
								<th>소수점크기</th>
								<th>정열코드</th>
								<th>출력크기</th>
                            </tr>
                        </thead>
                    </table>
                </div>
                <div class="grid_body list_10 tableBody">
                    <table>
                        <colgroup>
                            <col width="60" />
							<col width="100" />
							<col width="150" />
							<col width="150" />
							<col width="150" />
							<col width="100" />
							<col width="100" />
							<col width="100" />
							<col width="100" />
							<col width="100" />
                        </colgroup>
                        <tbody id="gridList">
                            <tr CGRow="true">
                                <td GCol="rownum">1</td>
                                <td GCol="input,DIC_ID" validate="required"></td>
                                <td GCol="input,DIC_NM" validate="required"></td>
                                <td GCol="input,LBL_ID" validate="required"></td>
                                <td GCol="input,LBL_CN" validate="required"></td>
                                <td GCol="input,DATA_TP_CD" validate="required"></td>
                                <td GCol="input,DATA_SIZE" validate="required"></td>
                                <td GCol="input,DCPT_SIZE" validate="required"></td>
                                <td GCol="input,ALIGN_CD" validate="required"></td>
                                <td GCol="input,OUTP_SIZE" validate="required min(50) max(200)"></td>
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