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
	
	function viewInputData(){
		var param = inputList.setRangeDataParam("searchArea");
		alert(param);
	}
	
	function searchList(){
		if(validate.check("gridListSearch")){
			var param = inputList.setRangeParam("gridListSearch");

			gridList.gridList({
		    	id : "gridList",
		    	param : param
		    });
			
			
		}
	}
	
	function saveData(){
		if(gridList.validationCheck("gridList", "all")){
			var json = gridList.gridSave({
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
            <a href="#" class="search">조회</a>
            <a href="#" class="reset">초기화</a>
            <a href="#GetVariant_pop_layout" class="pop_open4">Get Variant</a>
            <a href="#SaveVariant_pop_layout" class="pop_open4">Save Variant</a>
        </p>
        <div class="search_wrap" id="searchArea">
            <!-- 일반검색 시작 -->
            <dl class="search_basics">
                <dt><span>접수일</span></dt>
                <dd>
					<input class="calendar_box start" name="STARTDT" type="text" UIInput="B" UIFormat="C -2">
                </dd>

                <dt><span CL="STD_LANG_CD">고객사</span></dt>
                <dd>
                    <input class="search_box" name="SEARCH" type="text" UIInput="S,SEARCH" IAname="SEARCH" UIFormat="U">
                </dd>
                <dt><span><label for="a5">회원</label></span></dt>
                <dd>
                    <input id="a5" class="search_box" name="" type="text"><button class="search_btn" name="" type="button" value="검색"></button>
                </dd>
                <dt><span>유형</span></dt>
                <dd>
                    <select name="LOCATY" CommonCombo="LOCATY">
                    </select>
                </dd>
                <dt><span><label for="a7">통보채널</label></span></dt>
                <dd>
                    <select id="a7" class="w_auto" name="">
                    	<option>전체</option>
                    </select>
                    <span class="txt red">(다채널 선택)</span>
                </dd>
                <dt><span>지연여부</span></dt>
                <dd>
					<input class="search_box start" name="RANGE" type="text" UIInput="R,SEARCH">
                </dd>
                <dt><span>처리예정일기준</span></dt>
                <dd>
                    <input class="search_box start" name="RANGE1" type="text" UIInput="R" UIFormat="C">
                </dd>
            </dl>
            <div class="btn more">
            	<a href="#">more</a>
            </div>
            <!-- 일반검색 끝 -->
            <!-- 상세검색 시작 -->
            <dl class="search_skip">
                <dt><span>접수일</span></dt>
                <dd>
                    <label for="a11" class="skip">시작 날짜</label>
					<input id="a11" class="calendar_box start" name="" type="text"><button class="calendar_btn" name="" type="button" value="달력"></button>
					<span class="bar_box">~</span>
                    <label for="a12" class="skip">종료 날짜</label>
					<input id="a12" class="calendar_box end" name="" type="text"><button class="calendar_btn" name="" type="button" value="달력"></button>
                </dd>
                <dt><span>언어코드</span></dt>
                <dd>
                    <select name="LANGKY" CommonCombo="C006">
                    </select>
                </dd>
                <dt><span><label for="a14">고객사</label></span></dt>
                <dd>
                    <input id="a14" class="search_box" name="" type="text"><button class="search_btn" name="" type="button" value="검색"></button>
                </dd>
                <dt><span><label for="a15">회원</label></span></dt>
                <dd>
                    <input id="a15" class="search_box" name="" type="text"><button class="search_btn" name="" type="button" value="검색"></button>
                </dd>
                <dt><span><label for="a16">접수채널</label></span></dt>
                <dd>
                    <select id="a16" name="">
                    	<option>전체</option>
                    </select>
                </dd>
                <dt><span><label for="a17">통보채널</label></span></dt>
                <dd>
                    <select id="a17" class="w_auto" name="">
                    	<option>전체</option>
                    </select>
                    <span class="txt red">(다채널 선택)</span>
                </dd>
                <dt><span><label for="a18">지연여부</label></span></dt>
                <dd>
                    <select id="a18" name="">
                    	<option>전체</option>
                    </select>
                </dd>
                <dt><span>처리예정일기준</span></dt>
                <dd>
                    <label for="a19" class="skip">시작 날짜</label>
					<input id="a19" class="calendar_box start" name="" type="text"><button class="calendar_btn" name="" type="button" value="달력"></button>
					<span class="bar_box">~</span>
                    <label for="a20" class="skip">종료 날짜</label>
					<input id="a20" class="calendar_box end" name="" type="text"><button class="calendar_btn" name="" type="button" value="달력"></button>
                </dd>
            </dl>
            <div class="btn hide">
            	<a href="#">close</a>
            </div>
            <!-- 상세검색 끝 -->
        </div>
        <dl class="dl_row n4">
        	<dt class="n2"><span>대내협의비</span></dt>
        	<dd class="n2">
                <div class="divide_wrpa n2 n1_10_n2_20px">
                    <div class="n1">                    	
                        <div class="divide_wrpa n2 n1_5_n2_5">
                            <div class="n1">
                            	<label for="a4" class="skip">대내협의비1</label>
                            	<input class="won" id="a4" name="" type="text">
                            </div>
                            <div class="n2">
                            	<label for="a5" class="skip">대내협의비2</label>
                            	<input class="won" id="a5" name="" type="text">
                            </div>
                        </div>
                    </div>
                    <div class="n2">원</div>
                </div>
            </dd>
        	<dt><span><label for="a6">카드</label></span></dt>
        	<dd>
                <div class="divide_wrpa n2 n1_10_n2_20px">
                    <div class="n1">
                    	<input class="won" id="a6" name="" type="text">
                    </div>
                    <div class="n2">원</div>
                </div>
            </dd>
        	<dt><span><label for="a7">현금</label></span></dt>
        	<dd>
                <div class="divide_wrpa n2 n1_10_n2_20px">
                    <div class="n1">
                    	<input class="won" id="a7" name="" type="text">
                    </div>
                    <div class="n2">원</div>
                </div>
            </dd>
        </dl>
        <dl class="dl_row n2">
            <dt><span>접수번호</span></dt>
            <dd>16051232</dd>
            <dt><span><label for="">접수일시</label><em>*</em></span></dt>
            <dd>
            	<label for="a7" class="skip">날짜</label>
            	<input id="a7" class="calendar_box daytime" disabled name="" type="text"><button class="calendar_btn" name="" type="button" value="달력"></button>
                <select id="a8" class="daytime" name="">
                	<option>24</option>
                </select>
                <label class="daytime" for="a8">시</label>
                <select id="a9" class="daytime" name="">
                	<option>00</option>
                </select>
                <label class="daytime" for="a8">분</label>
            </dd>
            <dt class="n2"><span>접수채널<em>*</em></span></dt>
            <dd class="n2">
                <span class="check_box">
                    <input id="check_1" name="" type="checkbox" value="">
                    <label for="check_1">유형1</label>
                </span>
                <span class="check_box">
                    <input id="check_2" name="" type="checkbox" value="">
                    <label for="check_2">유형2</label>
                </span>
                <span class="check_box">
                    <input id="check_3" name="" type="checkbox" value="">
                    <label for="check_3">유형3</label>
                </span>
            </dd>
        </dl>
        <dl class="dl_row v2 n3">
            <dt><span>접수번호</span></dt>
            <dd>16051232</dd>
            <dt><span><label for="">접수일시</label><em>*</em></span></dt>
            <dd>
                <input id="date_s" class="calendar_box" name="" type="text"><button class="calendar_btn" name="" type="button" value="달력"></button>
            </dd>
            <dt><span><label for="">문의요청사구분</label><em>*</em></span></dt>
            <dd>
                <input id="date_s" class="calendar_box" name="" type="text"><button class="calendar_btn" name="" type="button" value="달력"></button>
            </dd>
            <dt><span><label for="">문의요청자</label><em>*</em></span></dt>
            <dd>
                <select id="select_2" name="">
                    <option>전체</option>
                </select>
            </dd>
            <dt class="n2"><span>접수채널<em>*</em></span></dt>
            <dd class="n2">
                <span class="check_box">
                    <input id="check_1" name="" type="checkbox" value="">
                    <label for="check_1">유형1</label>
                </span>
                <span class="check_box">
                    <input id="check_2" name="" type="checkbox" value="">
                    <label for="check_2">유형2</label>
                </span>
                <span class="check_box">
                    <input id="check_3" name="" type="checkbox" value="">
                    <label for="check_3">유형3</label>
                </span>
            </dd>
        </dl>
        <dl class="dl_row n4">
            <dt><span>접수번호</span></dt>
            <dd>16051232</dd>
            <dt><span><label for="">접수일시</label><em>*</em></span></dt>
            <dd>
                <input id="date_s" disabled class="calendar_box" name="" type="text"><button class="calendar_btn" name="" type="button" value="달력"></button>
            </dd>
            <dt><span><label for="">문의요청사구분</label><em>*</em></span></dt>
            <dd>
                <input id="date_s" class="calendar_box" name="" type="text"><button class="calendar_btn" name="" type="button" value="달력"></button>
            </dd>
            <dt><span><label for="">문의요청사</label><em>*</em></span></dt>
            <dd>
                <input id="search_1" disabled class="search_box" name="" type="text"><button class="search_btn" name="" type="button" value="검색"></button>
            </dd>
            <dt><span><label for="">문의요청자부서</label></span></dt>
            <dd>
                <select id="select_2" name="">
                    <option>전체</option>
                </select>
            </dd>
            <dt><span><label for="">문의요청자</label><em>*</em></span></dt>
            <dd>
                <select id="select_2" name="">
                    <option>전체</option>
                </select>
            </dd>
            <dt class="n2"><span>접수채널<em>*</em></span></dt>
            <dd class="n2">
                <span class="check_box">
                    <input id="check_1" name="" type="checkbox" value="">
                    <label for="check_1">유형1</label>
                </span>
                <span class="check_box">
                    <input id="check_2" name="" type="checkbox" value="">
                    <label for="check_2">유형2</label>
                </span>
                <span class="check_box">
                    <input id="check_3" name="" type="checkbox" value="">
                    <label for="check_3">유형3</label>
                </span>
            </dd>
            <dt class="n3"><span><label for="">접수채널</label><em>*</em></span></dt>
            <dd class="n3">
                <select id="select_2" name="">
                    <option>전체</option>
                </select>
            </dd>
            <dt><span><label for="">문의요청자</label><em>*</em></span></dt>
            <dd>
                <select id="select_2" name="">
                    <option>전체</option>
                </select>
            </dd>
            <dt class="n4"><span><label for="txt_1">접수채널</label><em>*</em></span></dt>
            <dd class="n4"><input id="txt_1" name="" type="text"></dd>
            </dd>
        </dl>
        <dl class="dl_row n2">
            <dt class="line2"><span><label for="txt_1">접수채널</label><em>*</em></span></dt>
            <dd class="line2">
            	<span class="txt">
            		aasf alasdkfj asdnf asldfk asdfn pwen nvknwpen sdn pwen sadn pwqen snv wqpen qwenf kadsnfakdsf;asdf;l asdfnasd nvqpw
            	</span>
            </dd>
            <dt class="line2"><span><label for="txt_1">접수채널</label><em>*</em></span></dt>
            <dd class="line2"><textarea id="txt_1" name="" cols="" rows=""></textarea></dd>
            <dt class="n2 line6"><span><label for="txt_1">접수채널</label><em>*</em></span></dt>
            <dd class="n2 line6"><textarea id="txt_1" name="" cols="" rows=""></textarea></dd>
            <dt class="n2 file_row5"><span>이미지</span></dt>
            <dd class="n2 file_row5">
            	<ul class="img_upload_wrap">
                	<li>
                    	<div class="thumbnail">
                        	<img src="/common/theme/ahcs/images/btn/thumbnail_bg.gif" alt="대표 미리보기 이미지" />
                        </div>
                        <div class="title"><label for="fileName1">대표</label></div>
                        <div class="upload">
                            <span>
                            	<input type="text" id="fileName1" class="file_input_textbox" disabled>
                            </span>
                            <div class="file_input_div">
                                <input type="button" value="이미지첨부" class="file_input_button" />
                                <input type="file" class="file_input_hidden" onchange="javascript: document.getElementById('fileName1').value = this.value" />
                            </div>                        
                        </div>
                    </li>
                	<li>
                    	<div class="thumbnail">
                        	<img src="/common/theme/ahcs/images/btn/thumbnail_bg.gif" alt="서브1 미리보기 이미지" />
                        </div>
                        <div class="title"><label for="fileName2">서브1</label></div>
                        <div class="upload">
                        	<span>
                            	<input type="text" id="fileName2" class="file_input_textbox" disabled>
                            </span>
                            <div class="file_input_div">
                                <input type="button" value="이미지첨부" class="file_input_button" />
                                <input type="file" class="file_input_hidden" onchange="javascript: document.getElementById('fileName2').value = this.value" />
                            </div>                        
                        </div>
                    </li>
                	<li>
                    	<div class="thumbnail">
                        	<img src="/common/theme/ahcs/images/btn/thumbnail_bg.gif" alt="서브2 미리보기 이미지" />
                        </div>
                        <div class="title"><label for="fileName3">서브2</label></div>
                        <div class="upload">
                        	<span>
                            	<input type="text" id="fileName3" class="file_input_textbox" disabled>
                            </span>
                            <div class="file_input_div">
                                <input type="button" value="이미지첨부" class="file_input_button" />
                                <input type="file" class="file_input_hidden" onchange="javascript: document.getElementById('fileName3').value = this.value" />
                            </div>                        
                        </div>
                    </li>
                	<li>
                    	<div class="thumbnail">
                        	<img src="/common/theme/ahcs/images/btn/thumbnail_bg.gif" alt="서브3 미리보기 이미지" />
                        </div>
                        <div class="title"><label for="fileName4">서브3</label></div>
                        <div class="upload">
                        	<span>
                            	<input type="text" id="fileName4" class="file_input_textbox" disabled>
                            </span>
                            <div class="file_input_div">
                                <input type="button" value="이미지첨부" class="file_input_button" />
                                <input type="file" class="file_input_hidden" onchange="javascript: document.getElementById('fileName4').value = this.value" />
                            </div>                        
                        </div>
                    </li>
                	<li>
                    	<div class="thumbnail">
                        	<img src="/common/theme/ahcs/images/btn/thumbnail_bg.gif" alt="상세 미리보기 이미지" />
                        </div>
                        <div class="title"><label for="fileName5">상세</label></div>
                        <div class="upload">
                        	<span>
                            	<input type="text" id="fileName5" class="file_input_textbox" disabled>
                            </span>
                            <div class="file_input_div">
                                <input type="button" value="이미지첨부" class="file_input_button" />
                                <input type="file" class="file_input_hidden" onchange="javascript: document.getElementById('fileName5').value = this.value" />
                            </div>                        
                        </div>
                    </li>
                </ul>
            </dd>
            <dt class="n2 file_row2"><span>파일첨부<a class="btn_s" href="#">업무규정</a></span></dt>
            <dd class="n2 file_row2">
            	<ul class="file_upload_wrap">
                	<li>
                        <div class="title"><label for="fileName6">MSDS</label></div>
                        <div class="upload">
                        	<span>
                            	<input type="text" id="fileName6" class="file_input_textbox" readonly>
                        	</span>
                            <div class="file_input_div">
                                <input type="button" value="파일첨부" class="file_input_button" />
                                <input type="file" class="file_input_hidden" onchange="javascript: document.getElementById('fileName6').value = this.value" />
                            </div>                        
                        </div>
                    </li>
                	<li>
                        <div class="title"><label for="fileName7">상세품목정보</label></div>
                        <div class="upload">
                        	<span>
                            	<input type="text" id="fileName7" class="file_input_textbox" readonly>
                        	</span>
                            <div class="file_input_div">
                                <input type="button" value="파일첨부" class="file_input_button" />
                                <input type="file" class="file_input_hidden" onchange="javascript: document.getElementById('fileName7').value = this.value" />
                            </div>                        
                        </div>
                    </li>
                </ul>
            </dd>
            <dt class="n2 t_row3"><span>테이블</span></dt>
            <dd class="n2 t_row3">
                <table class="table_col">
                	<colgroup>
                    	<col style="width:20%;" />
                    	<col style="width:20%;" />
                    	<col style="width:20%;" />
                    	<col style="width:20%;" />
                    	<col style="width:20%;" />
                    </colgroup>
                    <thead>
                        <tr>
                            <th scope="col">이름</th>
                            <th scope="col">주소</th>
                            <th scope="col">전화번호</th>
                            <th scope="col">핸드폰</th>
                            <th scope="col">기타</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr>
                            <td>이름</th>
                            <td>주소</th>
                            <td>전화번호</th>
                            <td>핸드폰</th>
                            <td>기타</th>
                        </tr>
                        <tr>
                            <td>이름</th>
                            <td>주소</th>
                            <td>전화번호</th>
                            <td>핸드폰</th>
                            <td>기타</th>
                        </tr>
                    </tbody>
                </table>
            </dd>
        </dl>
        <!-- 탭 시작 -->
        <div class="tab_box2 tabs">
        	<!-- 탭 버튼 시작 -->
            <ul class="tab_btn tab type2">
            	<li class="b1"><a href="#tabs1-1">대내협의비</a></li>
            	<li class="b2"><a href="#tabs1-2">대외활동비</a></li>
            	<li class="b3"><a href="#tabs1-3">교통비</a></li>
            	<li class="b4"><a href="#tabs1-4">차량유지비</a></li>
            	<li class="b5"><a href="#tabs1-5">기타</a></li>
            </ul>
        	<!-- 탭 버튼 끝 -->
            <!-- 탭 컨텐츠1 시작 -->
            <div id="tabs1-1" class="tab_con t1">
            	<p class="btn_m">
                    <a href="#" class="b_gray2">초기화</a>
                    <a href="#" class="b_gray2">수정</a>
                    <a href="#" class="on">추가</a>
                </p>
                <dl class="dl_row n3">
                	<dt class="n3"><span><label for="">사용구분</label><em>*</em></span></dt>
                    <dd class="n3">
                    	<select name="">
                        	<option>전체</option>
                        </select>
                    </dd>
                	<dt><span><label for="">금액</label><em>*</em></span></dt>
                    <dd>
                    	<input id="search_1" class="search_box" name="" type="text"><button class="search_btn" name="" type="button" value="검색"></button>
                    </dd>
                	<dt><span><label for="">사용일자</label><em>*</em></span></dt>
                    <dd>
                    	<input id="a7" class="calendar_box" name="" type="text"><button class="calendar_btn" name="" type="button" value="달력"></button>
                    </dd>
                	<dt><span><label for="">사용시간</label></span></dt>
                    <dd>
                    	<input id="a7"  name="" type="text">
                    </dd>
                	<dt><span><label for="">사용업소명</label><em>*</em></span></dt>
                    <dd>
                    	<input id="a7"  name="" type="text">
                    </dd>
                	<dt class="n2"><span><label for="">사용업소명</label></span></dt>
                    <dd class="n2">
                    	<input id="a7"  name="" type="text">
                    </dd>
                	<dt><span><label for="">예상잔액</label><em>*</em></span></dt>
                    <dd>
                    	<input id="search_1" class="search_box" name="" type="text"><button class="search_btn" name="" type="button" value="검색"></button>
                    </dd>
                	<dt><span><label for="">사용목적</label><em>*</em></span></dt>
                    <dd>
                    	<input id="a7"  name="" type="text">
                    </dd>
                	<dt><span><label for="">참석자</label><em>*</em></span></dt>
                    <dd>
                    	<input id="a7"  name="" type="text">
                    </dd>
                	<dt><span>차감액</span></dt>
                    <dd>
                    	<a class="btn_s" href="#">초과시 정보제공</a>
                    </dd>
                	<dt><span><label for="">배부</label></span></dt>
                    <dd>
                    	<input id="search_1" class="search_box" name="" type="text"><button class="search_btn" name="" type="button" value="검색"></button>
                    </dd>
                	<dt><span><label for="">영수증 구분</label></span></dt>
                    <dd>
                    	<select name="">
                        	<option>전체</option>
                        </select>
                    </dd>
                </dl>
                <div class="h4_wrap">
                	<div class="title">
                    	<h4>일반경비청구대상</h4>
                    </div>
                    <div class="grid_scroll gd1">
                        <p class="btn_m">
                            <span class="row_control">
                                <select id="gd1" onChange="grid_list(this)">
                                    <option selected>목록보기</option>
                                    <option value="10">10 보기</option>
                                    <option value="20">20 보기</option>
                                    <option value="50">50 보기</option>
                                    <option value="100">100 보기</option>
                                </select>
                            </span>
                            <a class="b_gray" href="#">삭제</a>
                        </p>
                        <div class="grid_head">
                            <table>
                                <colgroup>
                                    <col style="width:50px;" />
                                    <col style="width:140px;" />
                                    <col style="width:140px;" />
                                    <col style="width:140px;" />
                                    <col style="width:140px;" />
                                    <col style="width:140px;" />
                                    <col style="width:140px;" />
                                    <col style="width:140px;" />
                                    <col style="width:140px;" />
                                    <col style="width:140px;" />
                                </colgroup>
                                <thead>
                                    <tr>
                                        <th scope="col">
                                            <span class="check_box">
                                                <label for="a12" class="skip">전체선택</label>
                                                <input id="a12" name="" type="checkbox" value="">
                                            </span>
                                        </th>
                                        <th scope="col">경비구분</th>
                                        <th scope="col">사용구분</th>
                                        <th scope="col">사용일자</th>
                                        <th scope="col">금액</th>
                                        <th scope="col">사용업소명</th>
                                        <th scope="col">사용목적</th>
                                        <th scope="col">거래처명</th>
                                        <th scope="col">거래처인원</th>
                                        <th scope="col">차량번호</th>
                                    </tr>
                                </thead>
                            </table>
                        </div>
                        <div class="grid_body">
                            <table>
                                <colgroup>
                                    <col style="width:50px;" />
                                    <col style="width:140px;" />
                                    <col style="width:140px;" />
                                    <col style="width:140px;" />
                                    <col style="width:140px;" />
                                    <col style="width:140px;" />
                                    <col style="width:140px;" />
                                    <col style="width:140px;" />
                                    <col style="width:140px;" />
                                    <col style="width:140px;" />
                                </colgroup>
                                <tbody>
                                    <tr>
                                        <td>
                                            <span class="check_box">
                                                <label for="a12" class="skip">선택</label>
                                                <input id="a12" name="" type="checkbox" value="">
                                            </span>
                                        </td>
                                        <td>대외활동비</td>
                                        <td>카드</td>
                                        <td>2016-05-13</td>
                                        <td class="won">50,000</td>
                                        <td>극동회관</td>
                                        <td></td>
                                        <td>삼성전자</td>
                                        <td>5</td>
                                        <td></td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <span class="check_box">
                                                <label for="a12" class="skip">선택</label>
                                                <input id="a12" name="" type="checkbox" value="">
                                            </span>
                                        </td>
                                        <td>교통비</td>
                                        <td>카드</td>
                                        <td>2016-05-13</td>
                                        <td class="won">50,000</td>
                                        <td>극동회관</td>
                                        <td></td>
                                        <td>삼성전자</td>
                                        <td>5</td>
                                        <td></td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <span class="check_box">
                                                <label for="a12" class="skip">선택</label>
                                                <input id="a12" name="" type="checkbox" value="">
                                            </span>
                                        </td>
                                        <td>차량유지비</td>
                                        <td>카드</td>
                                        <td>2016-05-13</td>
                                        <td class="won">50,000</td>
                                        <td>극동회관</td>
                                        <td></td>
                                        <td>삼성전자</td>
                                        <td>5</td>
                                        <td></td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <span class="check_box">
                                                <label for="a12" class="skip">선택</label>
                                                <input id="a12" name="" type="checkbox" value="">
                                            </span>
                                        </td>
                                        <td>기타</td>
                                        <td>카드</td>
                                        <td>2016-05-13</td>
                                        <td class="won">50,000</td>
                                        <td>극동회관</td>
                                        <td></td>
                                        <td>삼성전자</td>
                                        <td>5</td>
                                        <td></td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <span class="check_box">
                                                <label for="a12" class="skip">선택</label>
                                                <input id="a12" name="" type="checkbox" value="">
                                            </span>
                                        </td>
                                        <td>대외활동비</td>
                                        <td>카드</td>
                                        <td>2016-05-13</td>
                                        <td class="won">50,000</td>
                                        <td>극동회관</td>
                                        <td></td>
                                        <td>삼성전자</td>
                                        <td>5</td>
                                        <td></td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>    
                        <div class="grid_control">
                            <div class="left_wrap">총 조회건수<span>9,999,999</span></div>
                            <div class="right_wrap">
                                <div class="page_num"><span>9,999,999</span> / 9,999,999</div>
                                <div class="search_wrap">
                                    <span class="search_box input_skipTitle">
                                        <input class="search_box" type="text"><button class="search_btn" type="button" value="검색"></button>
                                    </span>
                                    <button class="prev" type="button" value="이전"></button>
                                    <button class="next" type="button" value="다음"></button>
                                </div>
                                <div class="util">
                                    <button class="btn1" name="" type="button" value="새로고침"></button>
                                    <button class="btn2 open_grid_pop_layout" name="" type="button" value="레이아웃세이브"></button>
                                    <button class="btn3" name="" type="button" value="합계"></button>
                                    <button class="btn4" name="" type="button" value="다운로드"></button>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <!-- 탭 컨텐츠1 끝 -->
            <!-- 탭 컨텐츠2 시작 -->
            <div id="tabs1-2" class="tab_con t2">
            	2
            </div>
            <!-- 탭 컨텐츠2 끝 -->
            <!-- 탭 컨텐츠3 시작 -->
            <div id="tabs1-3" class="tab_con t3">
            	3
            </div>
            <!-- 탭 컨텐츠3 끝 -->
            <!-- 탭 컨텐츠4 시작 -->
            <div id="tabs1-4" class="tab_con t4">
            	4
            </div>
            <!-- 탭 컨텐츠4 끝 -->
            <!-- 탭 컨텐츠5 시작 -->
            <div id="tabs1-5" class="tab_con t5">
            	5
            </div>
            <!-- 탭 컨텐츠5 끝 -->
        </div>
        <!-- 탭 끝 -->
        <div class="h4_wrap">
            <div class="title">
                <h4>요청 문의 목록</h4>
            </div>
            <div class="grid_scroll section">
                <p class="btn_m tableUtil">
                    <span class="row_control">
						<select GBtn="viewCount"></select>
                        <a href="#" GBtn="add">추가</a>
                        <a href="#" GBtn="delete">삭제</a>
                        <a href="#" GBtn="copy">복사</a>
                    </span>
                    <span class="grid_search" id="gridListSearch">
                        <span class="txt">계약기간적용</span>
                        <label for="" class="skip">시작 날짜</label>
                        <input id="date_s" class="calendar_box start" name="" type="text"><button class="calendar_btn" name="" type="button" value="달력"></button>
                        <span class="bar_box">~</span>
                        <label for="" class="skip">종료 날짜</label>
                        <input id="date_s" class="calendar_box end" name="" type="text"><button class="calendar_btn" name="" type="button" value="달력"></button>
                        <a href="#" onclick="searchList()">조회</a>
                    </span>
                    <a href="#" class="on">저장</a>
                    <a href="#" class="pop_open1">레이어팝업1</a>
                    <a href="#" class="pop_open2">레이어팝업2</a>
                    <a href="#" class="b_gray">비용결제</a>
                    <a href="#" GBtn=excelUpload>업로드</a>
                </p>
                <div class="grid_head">
                    <table class="tableHeader">
                        <colgroup>
                            <col width="60" />
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
                        </colgroup>
                        <thead>
                            <tr>
                            	<th CL='STD_NUMBER'>번호</th>
                            	<th GBtnCheck="true"></th>
                                <th CL='STD_LANG_CD'></th>
								<th CL='STD_LBL_GRP_ID'></th>
								<th CL='STD_LBL_ID'></th>
								<th CL='STD_LBL_CN'></th>
								<th CL='STD_REG_PS_ID'></th>
								<th CL='STD_REG_DTTM'></th>
								<th CL='STD_REG_DTTM_T'></th>
								<th CL='STD_UPD_PS_ID'></th>
								<th CL='STD_UPD_DTTM'></th>
								<th CL='STD_UPD_DTTM_T'></th>
								<th CL='STD_DEL_YN'></th>
                            </tr>
                        </thead>
                    </table>
                </div>
                <div class="grid_body tableBody">
                    <table>
                        <colgroup>
                           <col width="60" />
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
                        </colgroup>
                        <tbody id="gridList">
                            <tr CGRow="true">
                                <td GCol="rownum">1</td>
                                <td GCol="rowCheck"></td>
								<td GCol="select,LANG_CD">
									<select>
										<option value="KO">한국어</option>
										<option value="EN">영어</option>
										<option value="ZH">중국어</option>
									</select>
								</td>
								<td GCol="input,LBL_GRP_ID,SEARCH" GF="U 20" validate="required"></td>
								<td GCol="input,LBL_ID" GF="U 20" validate="required"></td>
								<td GCol="input,LBL_CN" validate="required"></td> 
								<td GCol="text,REG_PS_ID"></td>
								<td GCol="input,REG_DTTM" GF="C"></td>
								<td GCol="text,REG_DTTM_T" GF="T"></td>
								<td GCol="text,UPD_PS_ID"></td>
								<td GCol="text,UPD_DTTM" GF="D"></td>
								<td GCol="text,UPD_DTTM_T" GF="N"></td>
								<td GCol="check,DEL_YN"></td>
                            </tr>
                        </tbody>
                    </table>
                </div>
                <div class="grid_control tableUtil">
                    <div class="left_wrap">총 조회건수<span GInfoArea="true">0</span></div>
                    <div class="right_wrap">
                        <div class="search_wrap" GBtn="find"></div>
                        <div class="util">
                            <a class="btn1" href="#" GBtn="sortReset">새로고침</a>
                            <a class="btn2" href="#" GBtn="layout">레이아웃</a>
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