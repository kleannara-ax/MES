<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!doctype html>
<head>
<meta charset="utf-8">
<meta name="viewport" content="user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, width=device-width, target-densitydpi=medium-dpi" />
<meta name="format-detection" content="telephone=no" />
<title>슈피겐코리아 모바일 WMS</title>
<%@ include file="/mobile/include/head.jsp" %>
</head>
<body>
	<div class="main_wrap">
		<div class="whyfail_wrap">
				<div class="search_box">
					<table>
						<colgroup>
							<col />
							<col width="100px"  />
						</colgroup>
						<tbody>
							<tr>
								<td class="second">
									<input type="text" value="SGP00001" class="text"/>
								</td>
								<td>
									<input type="button" value="조회" class="bt"/>
								</td>
							</tr>
							
						</tbody>
					</table>
				</div>
				<div class="tem5_content">
					<div class="info_box">
					<div class="tableHeader">
					<table>
						<colgroup>
								<col width="60px" />
								<col width="36%" />
								<col width="45%" />
						</colgroup>
							<thead>
								<tr>
									<th>번호</th>
									<th>검사항목코드</th>
									<th>검사항목명</th>
								</tr>
						</thead>
					</table>				
				</div>
					
					
				<div class="tableBody">
					<table>
						<colgroup>
								<col width="60px" />
								<col width="36%" />
								<col width="45%" />
						</colgroup>
						<tbody>
								<tr>
									<td>1</td>
									<td>ACCC</td>
									<td>형합검사(CASE류)</td>
								</tr>
								<tr>
									<td>2</td>
									<td>ACC2</td>
									<td>외관검사(CASE류)</td>
								</tr>
								<tr>
									<td>3</td>
									<td>ACC3</td>
									<td>신뢰성검사(CASE류)</td>
								</tr>
								
							</tbody>
					</table>
				</div>
				</div>
				<div class="bottom">
					<input type="button" value="선택" class="bottom_bt"/>
				</div>
		</div>	
	</div>		
	</div>
</body>
