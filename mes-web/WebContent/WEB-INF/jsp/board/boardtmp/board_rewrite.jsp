<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ include file="/board/include/rewriteHead.jsp" %>
							<div class="searchInBox">
									<div class="table type1">
										<form action="/board/fileUp/boardContentRewrite.data" enctype="multipart/form-data" method="post" id="boardWrite<%=boardId%>">
											<input type="hidden" name="CONTENT_ID" value="<%=data.getString("CONTENT_ID")%>" />
											<input type="hidden" name="PID" value="<%=data.getString("CONTENT_ID")%>" />
											<input type="hidden" name="STEP" value="<%=data.getString("STEP")%>" />
											<input type="hidden" name="DEPT" value="<%=data.getString("DEPT")%>" />
											<table>
												<colgroup>
												<col width="70px" />
												<col width="800px" />
											</colgroup>
												<tr>
													<th>제목</th>
													<td><input type="text" name="TITLE"  size="150"  value="re : <%=data.getString("TITLE")%>" validate="required"/></td>
												</tr>
												<tr>
													<th valign="top">내용</th>
													<td>
														<textarea id="boardContent<%=boardId%>" name="CONTENT" style="width:100%;height:450px;font-size:10pt" validate="required"><%=data.getString("CONTENT")%></textarea>
														<script type="text/javascript" language="javascript">
															var CrossEditor = new NamoSE('boardContent<%=boardId%>');
															CrossEditor.params.Width = "100%";
															CrossEditor.params.UserLang = "auto";
															CrossEditor.params.FullScreen = false;
															CrossEditor.EditorStart();
															function OnInitCompleted(e){
																e.editorTarget.SetBodyValue(document.getElementById("boardContent<%=boardId%>").value);
															}
														</script>
													</td>
												</tr>
												<tr>
													<th onClick="boardList.appendFile('<%=boardId%>')">첨부파일+</th>
													<td id="boardFileListArea<%=boardId%>"><input type="file" name="file"/></td>
												</tr>
											</table>
										</form>
									</div>
								</div>