<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ include file="/board/include/listHead.jsp" %>
							<div class="table type2">
								<div class="tableHeader">
									<table>
										<colgroup>
											<col width="50" />
											<col width="500" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
										</colgroup>
										<thead>
											<tr>
												<th CL='STD_NUMBER'>번호</th>
												<th CL='제목'>제목</th>
												<th CL='STD_CREUSR'>작성자</th>
												<th CL='STD_CREDAT'>작성일</th>
												<th CL='조회수'>조회수</th>
												<th CL='첨부파일'>첨부파일</th>
											</tr>
										</thead>
									</table>
								</div>
								<div class="tableBody">
									<table>
										<colgroup>
											<col width="50" />
											<col width="500" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
										</colgroup>
										<tbody id="boardList<%=boardId%>">
											<tr CGRow="true">
												<td GCol="rownum">1</td>
												<td GCol="text,TITLE"></td>
												<td GCol="text,CREUSR"></td>
												<td GCol="text,CREDAT"></td>
												<td GCol="text,VISIT"></td>
												<td GCol="text,FILE_COUNT"></td>
											</tr>
										</tbody>
									</table>
								</div>
							</div>
							<div class="tableUtil">
								<div class="leftArea">
									
								</div>
								<div class="rightArea">
									<p class="record" GInfoArea="true"></p>
								</div>