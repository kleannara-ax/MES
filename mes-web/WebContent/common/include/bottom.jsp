<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!-- layerPop -->
<div class="layerPopup box_wrapper">
	<button type="button" class="closer" onClick="rangePopClose()">X</button>
	<div class="tabs" id="rangePopupTabs">
		<ul class="selection">
			<li><a href="#tab1" CL="BOTTOM_SINGLEVAL"><img src="/common<%=theme%>/images/ico_t1.png" alt="" /></a></li>
			<li><a href="#tab2" CL="BOTTOM_RANGES"><img src="/common<%=theme%>/images/ico_t2.png" alt="" /></a></li>
		</ul>
		<div id="tab1">
			<div class="table type2 section" >
				<div class="tableHeader tbl_space tbl_small">
					<table>
						<colgroup>
							<col width="40px" />
							<col width="50px" />
							<col width="40px" />
							<col width="200px" />
						</colgroup>
						<thead>
							<tr>
								<th CL='BOTTOM_NUM'></th>
								<th CL='BOTTOM_LOGICAL'></th>
								<th CL='BOTTOM_OPER'></th>
								<th CL='BOTTOM_SINGLE'></th>
							</tr>
						</thead>
					</table>
				</div>
				<div class="tableBody tbl_small">
					<table>
						<colgroup>
							<col width="40px" />
							<col width="50px" />
							<col width="40px" />
							<col width="200px" />
						</colgroup>
						<tbody id="rangeSingleList">
							<tr CGRow="true">
								<td GCol="rownum">1</td>
								<td GCol="select,LOGICAL" class="ico">
									<select>
										<option value="OR">OR</option>
										<option value="AND">AND</option>
									</select>
								</td>
								<td GCol="select,OPER" class="ico">
									<select>
										<option value="E">=</option>
										<option value="N">≠</option>
										<option value="LT">＜</option>
										<option value="GT">＞</option>
										<option value="LE">≤</option>
										<option value="GE">≥</option>
									</select>
								</td>
								<td GCol="input,DATA">DATA</td>
							</tr>						
						</tbody>
					</table>
				</div>
			</div>
			<div class="tableUtil btn_wrap">
				<div class="leftArea">
					<button class="button type2" type="button" onClick="rangeObj.confirmRange()"><img src="/common<%=theme%>/images/ico_confirm.png" alt="" /><label CL="BOTTOM_CONFIRM"></label></button>
					<button class="button type2" type="button" onClick="rangeObj.clearRange('rangeSingleList')"><img src="/common<%=theme%>/images/ico_cancel.png" alt="" /><label CL="BOTTOM_CLEAR"></button>
				</div>
				<div class="rightArea">
				</div>
			</div>
		</div>
		<div id="tab2">
			<div class="table type2 section">
				<div class="tableHeader tbl_space tbl_big">
					<table>
						<colgroup>
							<col width="41px" />
							<col width="41px" />
							<col width="158px"/>
							<col width="174px"/>
						</colgroup>
						<thead>
							<tr>
								<th CL='BOTTOM_NUM'>Num</th>
								<th CL='BOTTOM_OPER'>Oper</th>
								<th CL='BOTTOM_FROM'>From</th>
								<th CL='BOTTOM_TO'>To</th>
							</tr>
						</thead>
					</table>
				</div>
				<div class="tableBody tbl_space tbl_big">
					<table>
						<colgroup>
							<col width="40px" />
							<col width="40px" />
							<col width="155px"/>
							<col width="154px"/>
						</colgroup>
						<tbody id="rangeRangeList">
							<tr CGRow="true">
								<td GCol="rownum">1</td>
								<td GCol="select,OPER" class="ico">
									<select>
										<option value="E">=</option>
										<option value="N">≠</option>
									</select>
								</td>
								<td GCol="input,FROM">FROM</td>
								<td GCol="input,TO">TO</td>
							</tr>						
						</tbody>
					</table>
				</div>
			</div>
			<div class="tableUtil btn_wrap">
				<div class="leftArea">
					<button class="button type2" type="button" onClick="rangeObj.confirmRange()"><img src="/common<%=theme%>/images/ico_confirm.png" alt="" /><label CL="BOTTOM_CONFIRM"></button>
					<button class="button type2" type="button" onClick="rangeObj.clearRange('rangeRangeList')"><img src="/common<%=theme%>/images/ico_cancel.png" alt="" /><label CL="BOTTOM_CLEAR"></button>
				</div>
				<div class="rightArea">
				</div>
			</div>
		</div>		
	</div>
</div>
<!-- //layerPop -->

<!-- 에러창 -->
<div class="alertMessage" id="alertMessage">
	<button type="button" class="closer"><img src="/common<%=theme%>/images/ico_closer.png" alt="" /></button>
	<p class="tit">Message</p>
	<p class="desc">You need to commit or cancel your changes</p>
</div>
<!-- //에러창 -->

<!-- layout Save -->
<div id="layoutSavePop" class="layoutSavePop box_wrap">
	<div>
		<div class="section left box_wrapper">
			<div class="table type3">
				<div class="tableHeader">
					<table>
						<colgroup>
							<col width="200" />
						</colgroup>
						<thead>
							<tr>
								<th CL='BOTTOM_INVISIBLE'></th>
							</tr>
						</thead>
					</table>
				</div>
				<div class="tableBody tbl_wrap">
					<table>
						<colgroup>
							<col />
						</colgroup>
						<tbody id="invisibleList">
							<tr CGRow="true">
								<td GCol="text,COLTEXT" layoutColName="GRID_COL_COLNAME_*" layoutColWidth="GRID_COL_COLWIDTH_*"></td>
							</tr>							
						</tbody>                 
					</table>
				</div>
			</div>
		</div>
		<div class="btnGroup btn_wrap">
			<button type="button" onClick="layoutSave.moveLeftAll()" title="leftAll">
				<img src="/common<%=theme%>/images/btn_first.png" />
			</button>
			</br>
			<button type="button" onClick="layoutSave.moveLeft()" title="left">
				<img src="/common<%=theme%>/images/btn_prev.png" />
			</button>
			</br>
			<button type="button" onClick="layoutSave.moveRight()" title="right">
				<img src="/common<%=theme%>/images/btn_next.png" />
			</button>
			</br>
			<button type="button" onClick="layoutSave.moveRightAll()" title="rightAll">
				<img src="/common<%=theme%>/images/btn_last.png" />
			</button>
		</div>
		<div class="section right box_wrapper">
			<div class="table type3">
				<div class="tableHeader">
					<table>
						<colgroup>
							<col width="250" />
						</colgroup>
						<thead>
							<tr>
								<th CL='BOTTOM_VISIBLE'></th>
							</tr>
						</thead>
					</table>
				</div>
				<div class="tableBody tbl_wrap">
					<table>
						<colgroup>
							<col width="250" />
						</colgroup>
						<tbody id="visibleList">
							<tr CGRow="true">
								<td GCol="text,COLTEXT" layoutColName="GRID_COL_COLNAME_*" layoutColWidth="GRID_COL_COLWIDTH_*"></td>
							</tr>
						</tbody>                 
					</table>
				</div>
			</div>
		</div>
	</div>
	<div class="layoutSaveTableUtil box_wrap">
		<div class="leftArea" >
			<button class="button type6" type="button" onClick="layoutSaveClose()" title="Cancel"><img src="/common<%=theme%>/images/ico_cancel.png" /><label CL="BOTTOM_CANCEL"></button>
			<button class="button type6" type="button" onClick="layoutSave.saveLayout()" title="Save"><img src="/common<%=theme%>/images/ico_confirm.png" /><label CL="BOTTOM_SAVE"></button>
			<button class="button type6" type="button" onClick="layoutSave.resetLayout()" title="Clear"><img src="/common<%=theme%>/images/ico_cancel.png" /><label CL="BOTTOM_CLEAR"></button>
		</div>
		<div class="rightArea">
			<button class="button type4" type="button" GBtnFind="true" title="moveTop" onclick="layoutSave.moveTop()"><img src="/common<%=theme%>/images/btn_up_02.png" /></button>
			<button class="button type4" type="button" GBtnCheck="true" title="moveUp" onclick="layoutSave.moveUp()"><img src="/common<%=theme%>/images/btn_up.png" /></button>									
			<button class="button type4" type="button" GBtnDelete="true" title="moveDown" onclick="layoutSave.moveDown()"><img src="/common<%=theme%>/images/btn_down.png" /></button>
			<button class="button type4" type="button" GBtnAdd="true" title="moveBottom" onclick="layoutSave.moveBottom()"><img src="/common<%=theme%>/images/btn_down_02.png" /></button>
		</div>
	</div>
</div>
<!-- layout Save end -->
<!-- clip Save -->
<div id="ClipSavePop" class="clipSavePop box_wrap">
	<div>
		<div class="section left box_wrapper">
			<div class="table type3">
				<div class="tableHeader">
					<table>
						<colgroup>
							<col width="450" />
						</colgroup>
						<thead>
							<tr>
								<th id="ClipSavePopMsg" CL='BOTTOM_CLIPBOARD'>Ctrl+V를 눌러 클립보드의 내용을 붙여넣어주세요.</th>
							</tr>
						</thead>
					</table>
				</div>
				<div class="tableBody tbl_wrap">
					<table>
						<colgroup>
							<col width="450" />
						</colgroup>
						<tbody>
							<tr>
								<td>
									<textarea id="ClipSavePopText" style="width:430px;height:240px;"></textarea>
								</td>
							</tr>							
						</tbody>                 
					</table>
				</div>
			</div>
		</div>
	</div>
	<div class="clipSaveTableUtil box_wrap">
		<div class="leftArea" >
			<!-- button class="button type6" type="button" onClick="layoutSave.confirmLayout()" title="Confirm"><img src="/common<%=theme%>/images/ico_confirm.png" /> Confirm</button-->
			<button class="button type6" type="button" onClick="hideClipSave()" title="Cancel"><img src="/common<%=theme%>/images/ico_cancel.png" /><label CL="BOTTOM_CANCEL"></button>
			<button class="button type6" type="button" onClick="gridList.clipDataView()" title="Save"><img src="/common<%=theme%>/images/ico_confirm.png" /><label CL="BOTTOM_PASTE"></button>
		</div>
	</div>
</div>
<!-- clip Save -->
<!-- excel upload -->
<div id="ExcelUploadPop" class="excelUploadPop box_wrap">
	<div>
		<div class="section left box_wrapper">
			<div class="table type3">
				<div class="tableHeader">
					<table>
						<colgroup>
							<col width="450" />
						</colgroup>
						<thead>
							<tr>
								<th CL='BOTTOM_EXCLUPLOAD'>그리드에 보여줄 엑셍을 업로드 하세요.</th>
							</tr>
						</thead>
					</table>
				</div>
				<div class="tableBody tbl_wrap">
					<table>
						<colgroup>
							<col width="450" />
						</colgroup>
						<tbody>
							<tr>
								<td>
									<form action="/common/grid/excel/fileUp/excel.data" enctype="multipart/form-data" method="post" id="gridExcelUploadForm">
										<input type="file" name="gridExcelUp" accept=".xls" validate="required excel"/>
										<input type="submit" value="upload"/>
									</form>
								</td>
							</tr>							
						</tbody>                 
					</table>
				</div>
			</div>
		</div>
	</div>
	<div class="excelUploadTableUtil box_wrap">
		<div class="leftArea" >
			<button class="button type6" type="button" onClick="hideExcelUpload()" title="Cancel"><img src="/common<%=theme%>/images/ico_cancel.png" /><label CL="BOTTOM_CANCEL"></button>
<%-- 			<button class="button type6" type="button" onClick="gridList.excelUploadTemplateDown()" title="Template"><img src="/common<%=theme%>/images/ico_confirm.png" /><label CL="BOTTOM_TEMPLATE"></button> --%>
		</div>
	</div>
</div>
<!-- //excel upload -->
<!-- Filter -->
<div id="GridFilterPop" class="gridFilterPop box_wrap">
	<div>
		<div class="section left box_wrapper">
			<div class="table type3">
				<div class="tableHeader">
					<table>
						<colgroup>
							<col width="50" />
							<col width="200" />
						</colgroup>
						<thead>
							<tr>
								<th CL='STD_NUMBER'></th>
								<th CL='BOTTOM_FILTERCOL'></th>
							</tr>
						</thead>
					</table>
				</div>
				<div class="tableBody tbl_wrap">
					<table>
						<colgroup>
							<col width="50" />
							<col width="200" />
						</colgroup>
						<tbody id="filterColList">
							<tr CGRow="true">
								<td GCol="rownum"></td>
								<td GCol="text,COLTEXT"></td>
							</tr>							
						</tbody>                 
					</table>
				</div>
			</div>
		</div>
		<div class="section right box_wrapper">
			<div class="table type3">
				<div class="tableHeader">
					<table>
						<colgroup>
							<col width="50" />
							<col width="40" />
							<col width="200" />
						</colgroup>
						<thead>
							<tr>
								<th CL='STD_NUMBER'></th>
								<th GBtnCheck="true"></th>
								<th CL='BOTTOM_FILTERDATA'></th>
							</tr>
						</thead>
					</table>
				</div>
				<div class="tableBody tbl_wrap">
					<table>
						<colgroup>
							<col width="50" />
							<col width="40" />
							<col width="200" />
						</colgroup>
						<tbody id="filterDataList">
							<tr CGRow="true">
								<td GCol="rownum"></td>
								<td GCol="rowCheck"></td>
								<td GCol="text,COLTEXT"></td>
							</tr>
						</tbody>                 
					</table>
				</div>
			</div>
		</div>
	</div>
	<div class="gridFilterTableUtil box_wrap">
		<div class="leftArea" >
			<button class="button type6" type="button" onClick="hideGridFilter()" title="Cancel"><img src="/common<%=theme%>/images/ico_cancel.png" /><label CL="BOTTOM_CANCEL"></button>
			<button class="button type6" type="button" onClick="gridList.filterDataConfirm()" title="Confirm"><img src="/common<%=theme%>/images/ico_confirm.png" /><label CL="BOTTOM_CONFIRM"></button>
			<button class="button type6" type="button" onClick="gridList.filterDataClear()" title="Clear"><img src="/common<%=theme%>/images/ico_cancel.png" /><label CL="BOTTOM_CLEAR"></button>
		</div>
	</div>
</div>
<!-- Filter end -->
<!-- SubTotal -->
<div id="GridSubTotalPop" class="gridSubTotalPop box_wrap">
	<div>
		<div class="section left box_wrapper">
			<div class="table type3">
				<div class="tableHeader">
					<table>
						<colgroup>
							<col width="50" />
							<col width="40" />
							<col width="200" />
						</colgroup>
						<thead>
							<tr>
								<th CL='STD_NUMBER'></th>
								<th GBtnCheck="true"></th>
								<th CL='BOTTOM_TOTALGROUPCOL'></th>
							</tr>
						</thead>
					</table>
				</div>
				<div class="tableBody tbl_wrap">
					<table>
						<colgroup>
							<col width="50" />
							<col width="40" />
							<col width="200" />
						</colgroup>
						<tbody id="subTotalColList">
							<tr CGRow="true">
								<td GCol="rownum"></td>
								<td GCol="rowCheck"></td>
								<td GCol="text,COLTEXT"></td>
							</tr>							
						</tbody>                 
					</table>
				</div>
			</div>
		</div>
		<div class="section right box_wrapper">
			<div class="table type3">
				<div class="tableHeader">
					<table>
						<colgroup>
							<col width="50" />
							<col width="40" />
							<col width="200" />
						</colgroup>
						<thead>
							<tr>
								<th CL='STD_NUMBER'></th>
								<th GBtnCheck="true"></th>
								<th CL='BOTTOM_TOTALDATA'></th>
							</tr>
						</thead>
					</table>
				</div>
				<div class="tableBody tbl_wrap">
					<table>
						<colgroup>
							<col width="50" />
							<col width="40" />
							<col width="200" />
						</colgroup>
						<tbody id="subTotalDataList">
							<tr CGRow="true">
								<td GCol="rownum"></td>
								<td GCol="rowCheck"></td>
								<td GCol="text,COLTEXT"></td>
							</tr>
						</tbody>                 
					</table>
				</div>
			</div>
		</div>
	</div>
	<div class="gridSubTotalTableUtil box_wrap">
		<div class="leftArea" >
			<button class="button type6" type="button" onClick="hideGridSubTotal()" title="Cancel"><img src="/common<%=theme%>/images/ico_cancel.png" /><label CL="BOTTOM_CANCEL"></button>
			<button class="button type6" type="button" onClick="gridList.subTotalConfirm()" title="Confirm"><img src="/common<%=theme%>/images/ico_confirm.png" /><label CL="BOTTOM_CONFIRM"></button>
			<button class="button type6" type="button" onClick="gridList.subTotalClear()" title="Clear"><img src="/common<%=theme%>/images/ico_cancel.png" /><label CL="BOTTOM_CLEAR"></button>
		</div>
	</div>
</div>
<!-- SubTotal -->
<!-- fileUpload popup -->
<div id="fileUploadLayer" class="fileUploadPop box_wrap">
	<div>
		<div class="section left box_wrapper">
			<div class="table type3">
				<div class="tableHeader">
					<form action='/common/fileUp/file.data' enctype='multipart/form-data' method='post' id='fileUploadForm'>
						<input type='file' name='fileUp' validate='required'/>
						<input type='submit' value='upload'/>
					</form>
				</div>
				<div class="tableBody tbl_wrap">
					<span id="fileNameView" onClick="gridList.fileDownload()"></span>
				</div>
			</div>
		</div>
	</div>
	<div class="clipSaveTableUtil box_wrap">
		<div class="leftArea" >
			<button class="button type6" type="button" onClick="hideFileUpload()" title="Close"><img src="/common<%=theme%>/images/ico_cancel.png" /><label CL="BOTTOM_CLOSE"></button>
		</div>
	</div>
</div>
<!-- fileUpload popup -->
<!-- MFileUpload popup -->
<div id="mFileUploadLayer" class="mFileUploadPop box_wrap">
	<div>
		<div class="section left box_wrapper">
			<div class="table type3">
				<form action='/common/fileGroupUp/file.data' enctype='multipart/form-data' method='post' id='mFileUploadForm'>
					<input type="hidden" name="GUUID" />
					<input type="button" class="btn_basic" value="Add" onClick="mFileAdd()" /><br/>
					<input type='file' name='fileUp0' validate='required'/>
					<input type='submit' value='upload'/>
				</form>
				<div class="tbl_wrap table_list01">
					
				</div>
			</div>
		</div>
	</div>
	<div class="clipSaveTableUtil box_wrap">
		<div class="leftArea" >
			<button class="button type6" type="button" onClick="hideMFileUpload()" title="Close"><img src="/common<%=theme%>/images/ico_cancel.png" /><label CL="BOTTOM_CLOSE"></button>
		</div>
	</div>
</div>
<!-- MFileUpload popup -->
<div class="contentLoading" id="contentLoading"></div>