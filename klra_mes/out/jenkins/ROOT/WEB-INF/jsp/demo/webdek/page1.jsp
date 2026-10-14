<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>STN Grid default</title>
<%@ include file="/common/include/webdek/head.jsp" %>
<script type="text/javascript">
	
</script>
</head>
<body>
<%@ include file="/common/include/webdek/layout.jsp" %>
<!-- content -->
<div class="content_wrap">
	<div class="content_inner">
		<div class="title-box">
			<h2 class="title">주문접수</h2>
			<div class="location">
				<span class="icon-home">HOME</span><span class="icon-gt">&gt;</span><span>주문접수</span>
			</div>
		</div>
		<div class="title-box2">
			<h3 class="s-title">접수자</h3>
		</div>
		<div class="content_layout">
			<div class="table_list02">
				<table>
					<caption>table list head</caption>
					<colgroup>
						<col width="25%" />
						<col width="25%" />
						<col width="25%" />
						<col width="25%" />
					</colgroup>
					<thead>
						<tr>
							<th>이름</th>
							<th>전화</th>
							<th>부서</th>
							<th>담당</th>
						</tr>
					</thead>
					<tbody>
						<tr>
							<td><input type="text" value="" class="input" value="#롯데하이마트본사" /></td>
							<td><input type="text" value="" class="input" value="010-1234-5555" /></td>
							<td><input type="text" value="" class="input" value="주방가전" /></td>
							<td><input type="text" value="" class="input" value="본사" /></td>
						</tr>
					</tbody>
				</table>
			</div>
		</div>
		<div class="title-box2">
			<h3 class="s-title">출발지</h3>
			<div class="btn-box">
        		<input id="checkbox1" type="checkbox" name="checkbox" value="1" checked="checked"><label for="checkbox1">접수자와 동일</label>
				<input type="button" class="btn_red" value="지점선택" />
			</div>
		</div>
		<div class="content_layout">
			<div class="table_list02">
				<table>
					<caption>table list head</caption>
					<colgroup>
						<col width="25%" />
						<col width="25%" />
						<col width="25%" />
						<col width="25%" />
					</colgroup>
					<thead>
						<tr>
							<th>상호명(고객명)</th>
							<th>담당</th>
							<th>동명</th>
							<th>전화</th>
						</tr>
					</thead>
					<tbody>
						<tr>
							<td><input type="text" value="" class="input" /></td>
							<td><input type="text" value="" class="input" /></td>
							<td><input type="text" value="" class="input" /></td>
							<td><input type="text" value="" class="input" /></td>
						</tr>
					</tbody>
				</table>
			</div>
		</div>
		<div class="title-box2">
			<h3 class="s-title">도착지</h3>
			<div class="btn-box">
        		<input id="checkbox2" type="checkbox" name="checkbox" value="1" checked="checked"><label for="checkbox2">접수자와 동일</label>
				<input type="button" class="btn_red" value="지점선택" />
			</div>
		</div>
		<div class="content_layout">
			<div class="table_list02">
				<table>
					<caption>table list head</caption>
					<colgroup>
						<col width="25%" />
						<col width="25%" />
						<col width="25%" />
						<col width="25%" />
					</colgroup>
					<thead>
						<tr>
							<th>상호명(고객명)</th>
							<th>담당</th>
							<th>동명</th>
							<th>전화</th>
						</tr>
					</thead>
					<tbody>
						<tr>
							<td><input type="text" value="" class="input" /></td>
							<td><input type="text" value="" class="input" /></td>
							<td><input type="text" value="" class="input" /></td>
							<td><input type="text" value="" class="input" /></td>
						</tr>
					</tbody>
				</table>
			</div>
		</div>
		<div class="title-box2">
			<h3 class="s-title">접수내용</h3>
			<div class="btn-box">
        		<input id="checkbox3" type="checkbox" name="checkbox" value="1" checked="checked"><label for="checkbox3">접수자와 동일</label>
				<input type="button" class="btn_red" value="지점선택" />
			</div>
		</div>
		<div class="dl-box">
			<dl>
				<dt><label><span>지급구분</span></label></dt>
				<dd>
        			<input id="pay1" type="radio" name="pay" value="1" checked="checked"><label for="pay1">선불</label>
        			<input id="pay2" type="radio" name="pay" value="1" checked="checked"><label for="pay2">착불</label>
        			<input id="pay3" type="radio" name="pay" value="1" checked="checked"><label for="pay3">신용</label>
				</dd>
			</dl>
			<dl>
				<dt><label><span>배송수단</span></label></dt>
				<dd>
        			<input id="radio1" type="radio" name="radio" value="1" checked="checked"><label for="radio1">오토바이</label>
        			<input id="radio2" type="radio" name="radio" value="1" checked="checked"><label for="radio2">디마스</label>
        			<input id="radio3" type="radio" name="radio" value="1" checked="checked"><label for="radio3">라보</label>
        			<input id="radio4" type="radio" name="radio" value="1" checked="checked"><label for="radio4">트럭</label>
				</dd>
			</dl>
			<dl>
				<dt><label><span>배송방법</span></label></dt>
				<dd>
        			<input id="delivery1" type="radio" name="delivery" value="1" checked="checked"><label for="delivery1">편도</label>
        			<input id="delivery2" type="radio" name="delivery" value="1" checked="checked"><label for="delivery2">왕복</label>
        			<input id="delivery3" type="radio" name="delivery" value="1" checked="checked"><label for="delivery3">경유</label>
				</dd>
			</dl>
			<dl>
				<dt><label><span>예상요금</span></label></dt>
				<dd>
					<input type="text" value="" class="input" value="본사" style="width:120px;" /> 원 
					<input type="button" class="btn_gray_l" value="예상요금확인" />
					<span class="txt">* 정산시 10% 할인된 금액이 적용 청구됩니다.</span>
				</dd>
			</dl>
			<dl>
				<dt><label><span>전표입력</span></label></dt>
				<dd>
					<input type="text" value="" class="input" />
				</dd>
			</dl>
			<dl>
				<dt><label><span>전달 내용</span></label></dt>
				<dd>
					<span class="textarea">
						<textarea rows="8" style="width:100%;"></textarea>
					</span>
				</dd>
			</dl>
		</div>
		<div class="btn-foot">
			<input type="button" class="btn_red_b" value="주문하기" />
			<input type="button" class="btn_gray_b" value="다시쓰기" />
		</div>
	</div>
</div>
<!-- // content -->
<%@ include file="/common/include/webdek/bottom.jsp" %>
</body>
</html>