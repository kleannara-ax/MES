<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!-- 레이어팝업1 시작 -->
<div id="layer_pop1">
    <div class="pop_wrap">
        <dl class="dl_row2">
            <dt>영업</dt>
            <dd>홍길동</dd>
        </dl>
        <p class="btn_s m_b_0">
            <a href="#">SMS 보내기</a>
            <a href="#">EMAIL 보내기</a>
        </p>
        <p class="close_btn">
            <a class="pop_close1" href="#">닫기</a>
        </p>
    </div>
    <div class="pop_bg"></div>
</div>
<!-- 레이어팝업1 끝 -->
<!-- 레이어팝업2 시작 -->
<div id="layer_pop2">            
    <div class="pop_wrap">
        <div class="pop_head">
			<div class="title">VOC 요청 상세</div>        
        </div>
    	<div class="pop_body">
            <dl class="dl_row v4">
                <dt><span>접수번호</span></dt>
                <dd>16051232</dd>
                <dt><span><label for="a27">접수일시</label><em>*</em></span></dt>
                <dd>
                    <span class="calendar_box">
                        <input id="a27" name="" type="text"><a href="#" class="btn">달력</a>
                    </span>
                </dd>
                <dt><span><label for="a28">문의요청사구분</label><em>*</em></span></dt>
                <dd>
                    <span class="calendar_box">
                        <input id="a28" name="" type="text"><a href="#" class="btn">달력</a>
                    </span>
                </dd>
                <dt><span><label for="a29">문의요청사</label><em>*</em></span></dt>
                <dd>
                    <span class="calendar_box">
                        <input id="a29" name="" type="text"><a href="#" class="btn">달력</a>
                    </span>
                </dd>
                <dt><span><label for="a30">문의요청자부서</label></span></dt>
                <dd>
                    <select id="a30" name="">
                    	<option>전체</option>
                    </select>
                </dd>
                <dt><span><label for="a31">문의요청자</label><em>*</em></span></dt>
                <dd>
                    <select id="a31" name="">
                    	<option>전체</option>
                    </select>
                </dd>
                <dt class="n2"><span>접수채널<em>*</em></span></dt>
                <dd class="n2">
                    <select id="a31" name="">
                    	<option>전체</option>
                    </select>
                </dd>
                <dt><span><label for="a35">문의유형1</label><em>*</em></span></dt>
                <dd>
                    <select id="a35" name="">
                    	<option>전체</option>
                    </select>
                </dd>
                <dt><span><label for="a36">문의유형2</label><em>*</em></span></dt>
                <dd>
                    <select id="a36" name="">
                    	<option>전체</option>
                    </select>
                </dd>
                <dt class="n2"><span><label for="a37">문의유형3</label><em>*</em></span></dt>
                <dd class="n2">
                    <select id="a37" name="">
                    	<option>전체</option>
                    </select>
                </dd>
                <dt><span><label for="a38">담당직원</label><em>*</em></span></dt>
                <dd>
                    <select id="a38" name="">
                    	<option>전체</option>
                    </select>
                </dd>
                <dt><span><label for="a39">진행상태</label><em>*</em></span></dt>
                <dd>
                    <select id="a39" name="">
                    	<option>전체</option>
                    </select>
                </dd>
                <dt><span><label for="a38">완료일시</label><em>*</em></span></dt>
                <dd>
                    <select id="a38" name="">
                    	<option>전체</option>
                    </select>
                </dd>
                <dt><span><label for="a39">첨부파일</label><em>*</em></span></dt>
                <dd>
                    <select id="a39" name="">
                    	<option>전체</option>
                    </select>
                </dd>
                <dt class="n4"><span><label for="a40">문의요청 내용</label><em>*</em></span></dt>
                <dd class="n4"><input id="a40" name="" type="text"></dd>
                <dt class="n2 line2"><span><label for="a41">문의처리 내용</label><em>*</em></span></dt>
                <dd class="n2 line2"><textarea id="a41" name="" cols="" rows=""></textarea></dd>
                <dt class="n2 line2"><span><label for="a42">고객통보내용</label><em>*</em></span></dt>
                <dd class="n2 line2"><textarea id="a42" name="" cols="" rows=""></textarea></dd>
                <dt class="n4"><span><label for="a43">비고</label><em>*</em></span></dt>
                <dd class="n4"><input id="a43" name="" type="text"></dd>
            </dl>
            <div class="h4_wrap">
            	<div class="title">
                	<h4>요청 문의 목록</h4>
                    <p class="btn_b">
                        <span class="txt">접수일</span>
                        <span class="calendar_box">
                            <label for="a44" class="skip">시작 날짜</label>
                            <input id="a44" name="" type="text"><a href="#" class="btn">달력</a>
                        </span>
                        <span class="calendar_bar">~</span>
                        <span class="calendar_box">
                            <label for="a45" class="skip">종료 날짜</label>
                            <input id="a45" name="" type="text"><a href="#" class="btn">달력</a>
                        </span>
                        <span class="txt">주문일</span>
                        <span class="calendar_box">
                            <label for="a46" class="skip">시작 날짜</label>
                            <input id="a46" name="" type="text"><a href="#" class="btn">달력</a>
                        </span>
                        <span class="calendar_bar">~</span>
                        <span class="calendar_box">
                            <label for="a47" class="skip">종료 날짜</label>
                            <input id="a47" name="" type="text"><a href="#" class="btn">달력</a>
                        </span>
                        <a href="#">검색</a>
                    </p>
                </div>
                <div class="grid_scroll">
                     <div class="grid_head">
                         <table>
                             <colgroup>
                                 <col width="50" />
                                 <col width="500" />
                                 <col width="500" />
                                 <col width="500" />
                                 <col width="500" />
                                 <col width="500" />
                             </colgroup>
                             <thead>
                                 <tr>
                                     <th scope="col">
                                         <span class="check_box">
                                             <input id="a48" name="" type="checkbox" value="">
                                             <label for="a48" class="skip">전체선택</label>
                                         </span>
                                     </th>
                                     <th scope="col">이름</th>
                                     <th scope="col">전화번호</th>
                                     <th scope="col">주소</th>
                                     <th scope="col">기타</th>
                                     <th scope="col">선택</th>
                                 </tr>
                              </thead>
                         </table>
                     </div>
                     <div class="grid_body list_5">
                         <table>
                             <colgroup>
                                 <col width="50" />
                                 <col width="500" />
                                 <col width="500" />
                                 <col width="500" />
                                 <col width="500" />
                                 <col width="500" />
                             </colgroup>
                             <tbody>
                                 <tr>
                                     <td>
                                         <span class="check_box">
                                             <input id="a49" name="" type="checkbox" value="">
                                             <label for="a49" class="skip">선택</label>
                                         </span>
                                     </td>
                                     <td>
                                         <span class="calendar_box">
                                             <label for="a50" class="skip">시작 날짜</label>
                                             <input id="a50" name="" type="text"><a href="#" class="btn">달력</a>
                                         </span>
                                         <span class="calendar_bar">~</span>
                                         <span class="calendar_box">
                                             <label for="a51" class="skip">종료 날짜</label>
                                             <input id="a51" name="" type="text"><a href="#" class="btn">달력</a>
                                         </span>
                                     </td>
                                     <td>
                                     	<label for="a52" class="skip">선택</label>
                                         <select id="a52" name="">
                                             <option>전체</option>
                                         </select>
                                     </td>
                                     <td>
                                         <span class="search_box">
                                         	<label for="a53" class="skip">날짜검색</label>
                                             <input id="a53" name="" type="text"><a href="#" class="btn">달력</a>
                                         </span>
                                     </td>
                                     <td> </td>
                                     <td> </td>
                                 </tr>
                                 <tr>
                                     <td> </td>
                                     <td>160511</td>
                                     <td>2016-05-20</td>
                                     <td>고객사</td>
                                     <td> </td>
                                     <td> </td>
                                 </tr>
                             </tbody>
                         </table>
                     </div>
                 </div>

            </div>
            <p class="btn_b">
                <a class="on" href="#">확인</a>
                <a href="#">취소</a>
            </p>
        </div>
        <p class="close_btn">
            <a class="pop_close2" href="#">닫기</a>
        </p>
    </div>
    <div class="pop_bg"></div>
</div>
<!-- 레이어팝업2 끝 -->
<!-- 탑 시작 -->
<div id="top_layout">
	<div class="top_wrap">
    	<div class="logo_wrap">
        	<h1><a href="#"><img src="/common/theme/ahcs/images/inc/logo.gif" alt="Allen Care" /></a></h1>
            <p>Healthcare Integrated System</p>
        </div>
        <div class="util_wrap">
        	<ul class="info_wrap">
            	<li class="company">
                    <div class="drop_company drop_select">
                        <div><a href="#">안연케어</a></div>
                        <ul>
                            <li><a href="#">안연케어</a></li>
                            <li><a href="#">test</a></li>
                        </ul>
                    </div>
                </li>
                <li class="name">물류관리팀</li>
            	<li class="company">
                    <div class="drop_company drop_select">
                        <div><a href="#">창고</a></div>
                        <ul>
                            <li><a href="#">창고1</a></li>
                            <li><a href="#">창고2</a></li>
                        </ul>
                    </div>
                </li>
                <li class="name"><span>홍길동</span> 님</li>
                <li class="logout"><a href="#">로그아웃</a></li>
            </ul>
            <div class="drop_lang drop_select">
                <div><a href="#">Korean</a></div>
                <ul>
                    <li><a href="#">Korean1</a></li>
                    <li><a href="#">Korean2</a></li>
                    <li><a href="#">Korean3</a></li>
                </ul>
            </div>
        </div>
    </div>
</div>
<!-- 탑 끝 -->
<!-- 왼쪽메뉴 시작 -->
<div id="left_layout">
	<!-- 네비 시작 -->
	<div class="left_navi">
    	<ul class="count_wrap">
        	<li class="count_box1"><span>메시지</span><a href="#">6</a></li>
            <li class="count_box2"><span>결제함</span><a href="#">23</a></li>
        </ul>
        <ul class="navi_wrap depth1_ul">
        	<li class="n1"><h2><a href="#">고객영업관리</a></h2></li>
        	<li class="n2"><h2><a href="#">MySite판가관리</a></h2></li>
        	<li class="n3"><h2><a href="#">MySite</a></h2></li>
        	<li class="n4 on"><h2><a href="#">제안견적관리제안견적관리</a></h2>
            	<ul class="depth2_ul">
                	<li class="n1"><a href="#">잠재고객 견적진행현황</a></li>
                	<li class="n2"><a href="#">잠재고객 견적</a></li>
                	<li class="n3"><a href="#">신규품목 견적요청서등록견적요청서등록</a></li>
                	<li class="n4 on"><a href="#">계약조건변경품의서</a>
                    	<ul class="depth3_ul">
                        	<li class="n1 on"><a href="#">잠재고객 견적</a></li>
                        	<li class="n2"><a href="#">잠재고객</a></li>
                        	<li class="n3"><a href="#">신규품목견적요청서</a></li>
                        </ul>
                    </li>
                </ul>
            </li>
        	<li class="n5"><h2><a href="#">정수보충</a></h2></li>
        	<li class="n6"><h2><a href="#">주문관리</a></h2></li>
        	<li class="n7"><h2><a href="#">반품관</a></h2></li>
        	<li class="n8"><h2><a href="#">교환관리</a></h2></li>
        	<li class="n9"><h2><a href="#">사후정산</a></h2></li>
        </ul>
        <div class="top_btn">
        	<a href="#">TOP</a>
        </div>
    </div>
	<!-- 네비 끝 -->
    <!-- 메뉴컨트롤 시작 -->
    <div class="left_control">
    	<ul>
        	<li class="btn_2depth left"><a href="#">작은메뉴</a></li>
        	<li class="btn_1depth"><a href="#">메뉴숨기기</a></li>
        	<li class="btn_2depth right" style="display:none;"><a href="#">작은메뉴</a></li>
        	<li class="btn_3depth" style="display:none;"><a href="#">큰메뉴</a></li>
        	<li class="btn_mymenu"><a href="#">나의메뉴</a></li>
        </ul>
    </div>
    <!-- 메뉴컨트롤 끝 -->
    <div class="left_bg">
    </div>
</div>
<!-- 왼쪽메뉴 끝 -->
<!-- 컨텐츠 시작 -->
<div id="contents_layout">
	<!-- 롤링 공지사항 시작 -->
	<div class="notice_wrap">
        <div id="srolling" class="rolling_wrap"></div>
        <div id="txt_wrap" style="display:none;">
            <div><a href="#"><strong>[1긴급공지]</strong>롤링 공지사항 입니다.</a><span>2016-05-31</span></div>
            <div><a href="#"><strong>[2긴급공지]</strong>롤링 공지사항 입니다.</a><span>2016-05-31</span></div>
            <div><a href="#"><strong>[3긴급공지]</strong>롤링 공지사항 입니다.</a><span>2016-05-31</span></div>
            <div><a href="#"><strong>[4긴급공지]</strong>롤링 공지사항 입니다.</a><span>2016-05-31</span></div>
            <div><a href="#"><strong>[5긴급공지]</strong>롤링 공지사항 입니다.</a><span>2016-05-31</span></div>
        </div>﻿
        <span id="p_click" class="btn prev"><a href="#">이전</a></span>
        <span id="n_click" class="btn next"><a href="#">다음</a></span>
    </div> 
	<!-- 롤링 공지사항 끝 -->
    <div class="contents_wrap">
    <!-- 타이틀 시작 -->
		<div class="title_wrap">
        	<ul id="lcation_menu" class="location">
            	<li class="home"><a href="#">홈</a></li>
            	<li><a href="#">공급업체관리</a>
                    <div class="drop_menu">
                        <ul>
                            <li><a href="#">고객영업관리</a></li>
                            <li><a href="#">주문관리</a></li>
                            <li class="on"><a href="#">평가결과등록</a></li>
                            <li><a href="#">교환관리</a></li>
                            <li><a href="#">고객영업관리</a></li>
                            <li><a href="#">반품관</a></li>
                        </ul>
                    </div>
                </li>
            	<li><a href="#">등록평가현황</a>
                    <div class="drop_menu">
                        <ul>
                            <li><a href="#">고객영업관리</a></li>
                            <li><a href="#">주문관리</a></li>
                            <li class="on"><a href="#">평가결과등록</a></li>
                            <li><a href="#">교환관리</a></li>
                            <li><a href="#">고객영업관리</a></li>
                            <li><a href="#">반품관</a></li>
                        </ul>
                    </div>
                </li>
            	<li class="last"><a href="#">평가결과등록</a>
                    <div class="drop_menu">
                        <ul>
                            <li><a href="#">고객영업관리</a></li>
                            <li><a href="#">주문관리</a></li>
                            <li class="on"><a href="#">평가결과등록</a></li>
                            <li><a href="#">교환관리</a></li>
                            <li><a href="#">고객영업관리</a></li>
                            <li><a href="#">반품관</a></li>
                        </ul>
                    </div>
                </li>
            </ul>
            <h3>VOC 요청 문의 관리<span class="icon"><a href="#" class="pageInfo">설명</a> <a href="#" class="myPage">마이페이지추가</a></span></h3>
        </div>
    <!-- 타이틀 끝 -->