<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ include file="/board/include/viewHead.jsp" %>
							<div class="searchInBox">
									<div class="table type1">
											<table>
												<colgroup>
												<col width="70px" />
												<col width="800px" />
											</colgroup>
												<tr>
													<th>작성자</th>
													<td><%=data.getString("CREUSR")%></td>
												</tr>
												<tr>
													<th>작성일자</th>
													<td><%=data.getString("CREDAT")%></td>
												</tr>
												<tr>
													<th>제목</th>
													<td><%=data.getString("TITLE")%></td>
												</tr>
												<tr>
													<th valign="top">내용</th>
													<td>
														<iframe src="/board/boardContent.page?CONTENT_ID=<%=data.getString("CONTENT_ID")%>" style="width:100%;height:450px;">
														</iframe>
													</td>
												</tr>
												<tr>
													<th>첨부파일</th>
													<td>
													<%
														List list = data.getList("fileList");
														DataMap row;
														for(int i=0;i<list.size();i++){
															row = (DataMap)list.get(i); 
													%>
														<a href="/common/fileDown/file.data?UUID=<%=row.getString("UUID")%>"><%=row.getString("NAME")%></a><br/>
													<%
														}
													%>													
													</td>
												</tr>
											</table>
									</div>
								</div>