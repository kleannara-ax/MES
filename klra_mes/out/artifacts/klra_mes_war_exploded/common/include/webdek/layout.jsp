<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<div class="deemLayer none" id="contentLoading">
	<img src="/common/theme/webdek/images/Loading_icon.gif" />
</div>
<!-- column edit popup -->
<div id="columnSaveLayer" class="layer_popup" style="left:50%;top:50%;width:584px;margin:-250px 0 0 -350px;display:none;"><!-- 팝업 위치는 알아서 변경해주세요 -->
	<div class="layer_search">
		<div class="layer_left section" style="width:252px;margin-right:54px"><!-- width 맞게 변경, margin-right는 가운데 width 값(layer_leftmargin:10px 포함)  -->
			<strong class="layer_stit">Show</strong>
			<div class="input_list" style="height:280px"><!-- height 맞게 변경 -->
				<div class="scroll tableBody" style="height:252px"><!-- height 맞게 변경  -->
					<table>
						<colgroup>
							<col style="width:250px"/><col style="width:70px"/>
						</colgroup>
						<tbody id="visibleList">
							<tr CGRow="true">
								<td GCol="text,COLTEXT" layoutColName="GRID_COL_COLNAME_*" layoutColWidth="GRID_COL_COLWIDTH_*"></td>
								<td GCol="input,COLWIDTH" GF="N 4,0"></td>
							</tr>
						</tbody>
					</table>
				</div>
			</div>
			<div class="drag_btn_box_s">
				<button class="btn btn_drag_up_all" onclick="layoutSave.moveTop()"><span></span></button>
				<button class="btn btn_drag_up" onclick="layoutSave.moveUp()"><span></span></button>
				<button class="btn btn_drag_down" onclick="layoutSave.moveDown()"><span></span></button>
				<button class="btn btn_drag_down_all" onclick="layoutSave.moveBottom()"><span></span></button>
			</div>
		</div>
		<div class="drag_btn_box">
			<button class="btn btn_drag_right_all" onClick="layoutSave.moveLeft()"><span></span></button>
			<button class="btn btn_drag_right" onClick="layoutSave.moveLeftAll()" ><span></span></button>
			<button class="btn btn_drag_left" onClick="layoutSave.moveRight()"><span></span></button>
			<button class="btn btn_drag_left_all" onClick="layoutSave.moveRightAll()"><span></span></button>
		</div>
		<div class="layer_right section" style="width:216px"><!-- width 맞게 변경 -->
			<strong class="layer_stit">Hidden</strong>
			<div class="input_list scroll tableBody" style="height:280px"><!-- height 맞게 변경 -->
				<table>
					<colgroup>
						<col style="width:220px"/>
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
	<div class="btn_wrap" style="width:540px;margin-left: 20px">
		<div class="fl_l" style="width:65%">
			<input type="button" class="btn_gray" value="clear" onClick="layoutSave.resetLayout()"/>
		</div>
		<div class="fl_r" style="width:35%">
			<input type="button" class="btn_basic" value="confirm" onClick="layoutSave.saveLayout()"/>
			<input type="button" class="btn_gray" value="close" onClick="hideLayoutSave()"/>
		</div>
	</div>
</div>
<!-- column edit popup -->
<div id="layerBack" class="deemLayer2" style="display:none;">
</div>
<!-- grid body menu popup -->
<div class="layer_popup" id="gridBodyMenuLayer" style="left:100px;top:100px;width:147px;display:none;"><!-- 팝업 위치는 알아서 변경해주세요 -->
	<div class="right_click_box">
		<ul class="right_click_list" style="display: none">
			<li class="btn_cut_color"><input type="button" class="btn_l btn_cut off" value="Cut" onClick="gridList.contextMenuExec('Cut')"/></li><!-- 회색아이콘은 off 추가 -->
			<li class="btn_copy_color"><input type="button" class="btn_l btn_copy" value="Copy" onClick="gridList.contextMenuExec('Copy')"/></li><!-- 회색아이콘은 off 추가 -->
			<li class="btn_paste_color"><input type="button" class="btn_l btn_paste" value="Paste" onClick="gridList.contextMenuExec('Paste')"/></li>
			<li class="color_no"><input type="button" value="Remove" /></li>
		</ul>
		<ul class="right_click_list" style="display: none">
			<li class="addMenu btn_add_r_color"><input type="button" class="btn_l btn_add_r" value="Add" onClick="gridList.contextMenuExec('Add')"/></li>
			<li class="addMenu btn_insertion_color"><input type="button" class="btn_l btn_insertion" value="Insert" onClick="gridList.contextMenuExec('Insert')"/></li>
			<li class="addMenu btn_cloning_color"><input type="button" class="btn_l btn_cloning" value="Clone" onClick="gridList.contextMenuExec('Clone')" /></li>
			<li class="delMenu color_no"><input type="button" value="Delete" onClick="gridList.contextMenuExec('Delete')"/></li>
		</ul>
		<ul class="right_click_list" style="display: none">
			<li class="btn_filter_color"><input type="button" class="btn_l btn_filter" value="Filter" /></li>
			<li class="btn_fixed_frame_color"><input type="button" class="btn_l btn_fixed_frame" value="Freeze panes" /></li>
		</ul>
		<ul class="right_click_list">
			<li class="btn_copy_color select_srart"><input type="button" class="btn_l btn_copy" value="Select start"  onClick="gridList.contextMenuExec('Select')"/></li>
		</ul>
	</div>
</div>
<!-- grid body menu popup -->
<!-- grid head menu popup -->
<div class="layer_popup" id="gridHeadMenuLayer" style="left:200px;top:200px;width:147px;display:none;"><!-- 팝업 위치는 알아서 변경해주세요 -->
	<div class="right_click_box">
		<ul class="right_click_list" style="display: none">
			<li class="sortMenu btn_ascending_color"><input type="button" class="btn_l btn_ascending" value="Sort(asc)" onClick="gridList.contextMenuExec('SortAsc')"/></li>
			<li class="sortMenu btn_descending_color"><input type="button" class="btn_l btn_descending" value="Sort(desc)" onClick="gridList.contextMenuExec('SortDesc')" /></li>
			<li class="sortMenu btn_sort_del_color"><input type="button" class="btn_l btn_sort_del" value="Sort reset" onClick="gridList.contextMenuExec('SortReset')" /></li>
			<li class="btn_sort_edit_color"><input type="button" class="btn_l btn_sort_edit" value="Sort edit" /></li>
			<li class="btn_hide_color"><input type="button" class="btn_l btn_hide" value="Hidden" /></li>
			<li class="btn_column_w_color"><input type="button" class="btn_l btn_column_w" value="Column width" /></li>
		</ul>
		<ul class="right_click_list" style="display: none">
			<li class="btn_column_edit_color"><input type="button" class="btn_l btn_column_edit" value="Column edit" onClick="gridList.contextMenuExec('ColumnEdit')" /></li>
			<li class="btn_filter_color"><input type="button" class="btn_l btn_filter" value="Filter" /></li>
			<li class="totalMenu btn_sum_r_color"><input type="button" class="btn_l btn_sum_r" value="Total" onClick="gridList.contextMenuExec('Total')" /></li>
			<li class="totalMenu color_no"><input type="button" value="Sub total" onClick="gridList.contextMenuExec('SubTotal')"/></li>
		</ul>
		<ul class="right_click_list" style="display: none">
			<li class="btn_filter_color"><input type="button" class="btn_l btn_filter" value="Filter" /></li>
			<li class="btn_fixed_frame_color"><input type="button" class="btn_l btn_fixed_frame" value="Freeze panes" /></li>
		</ul>
		<ul class="right_click_list" style="display: none">
			<li class="btn_cut_color"><input type="button" class="btn_l btn_cut" value="Cut" /></li>
			<li class="btn_copy_color"><input type="button" class="btn_l btn_copy" value="Copy" /></li>
			<li class="btn_paste_color"><input type="button" class="btn_l btn_paste" value="Paste" /></li>
			<li class="color_no"><input type="button" value="Clear" /></li>
		</ul>
		<ul class="right_click_list">
			<li class="btn_copy_color select_srart"><input type="button" class="btn_l btn_copy" value="Select start"  onClick="gridList.contextMenuExec('Headselect')"/></li>
		</ul>
	</div>
</div>
<!-- grid head menu popup -->
<!-- multiinput popup -->
<div class="layer_popup" id="multiInputLayer" style="left:50%;top:50%;width:485px;margin:-250px 0 0 -350px;display:none;"><!-- 팝업 위치는 알아서 변경해주세요 -->
	<div class="layer_search">
		<div class="grid_list" style="display:none;">
			<table>
				<colgroup>
					<col style="width:64px"/><col style="width:235px"/><col style="width:71px"/><col style="width:50px"/>
				</colgroup>
				<tr>
					<td class="or_and"></td>
					<td>
						<span class="input_box_bg">
							<input type="text" id="input01" class="input_bg ta_c" value="조건1 +(5 item)" />
						</span>
					</td>
					<td>
						<span class="input_box_bg btn1">
							<input type="text" id="input01" class="input_bg" value="IN"/>
							<button type="button" class="btn btn_select"><span>select</span></button>
						</span>
					</td>
					<td class="btn_area"><button type="button" class="btn btn_del2"><span>추가</span></button></td>
				</tr>
				<tr>
					<td class="or_and"><span class="btn_basic">AND</span></td>
					<td>
						<span class="input_box_bg">
							<input type="text" id="input01" class="input_bg ta_c" value="조건1 +(5 item)" />
						</span>
					</td>
					<td>
						<span class="input_box_bg btn1">
							<input type="text" id="input01" class="input_bg" value="IN"/><button type="button" class="btn btn_select"><span>select</span></button>
						</span>
					</td>
					<td class="btn_area"><button type="button" class="btn btn_del2"><span>추가</span></button></td>
				</tr>
				<tr>
					<td class="or_and"><span class="btn_basic">OR</span></td>
					<td>
						<span class="input_box_bg">
							<input type="text" id="input01" class="input_bg ta_c" value="조건1 +(5 item)" />
						</span>
					</td>
					<td>
						<span class="input_box_bg btn1">
							<input type="text" id="input01" class="input_bg" value="IN"/><button type="button" class="btn btn_select"><span>select</span></button>
						</span>
					</td>
					<td class="btn_area"><button type="button" class="btn btn_del2"><span>추가</span></button></td>
				</tr>
			</table>
		</div>
		<div class="table_list01 scroll section" style="height:200px"><!-- 높이값 맞게 변경 -->
			<table class="table_c tableBody" id="multiInputList">
				<colgroup>
					<col width="400px"/>
				</colgroup>
				<tr CGRow="true" class="search_area">
					<td GCol="input,DATA">DATA</td>
				</tr>		
			</table>
		</div>
		<div class="table_list01 scroll section" style="height:200px;display:none;"><!-- 높이값 맞게 변경 -->
			<table class="table_c tableBody" id="multiInputRangeList">
				<colgroup>
					<col width="50%"/>
					<col width="50%"/>
				</colgroup>
				<tr CGRow="true" class="search_area">
					<td GCol="input,FROM">FROM</td>
					<td GCol="input,TO">TO</td>
				</tr>			
			</table>
		</div>
	</div>
	<div class="btn_wrap">
		<div class="fl_l">
			<!-- input type="button" class="btn_basic" value="add" /-->
			<input type="button" class="btn_gray" value="reset" onClick="rangeObj.clearRange('rangeSingleList')"/>
		</div>
		<div class="fl_r">
			<input type="button" class="btn_basic" value="confirm" onClick="rangeObj.confirmRange()"/>
			<input type="button" class="btn_gray" value="close" onclick="rangePopClose()"/>
		</div>
	</div>
</div>
<!-- multiinput popup -->
<!-- clipboard popup -->
<div class="layer_popup" id="clipboardLayer" style="left:50%;top:50%;width:585px;margin:-200px 0 0 -300px;display:none;z-index:201;"><!-- 팝업 위치는 알아서 변경해주세요 -->
	<div class="layer_search">
		<div class="table_list01 scroll" style="height:200px"><!-- 높이값 맞게 변경 -->
			<textarea style="width:100%;height:100%" id="clipboardLayerText">			
			</textarea>
		</div>
	</div>
	<div class="btn_wrap" style="width:545px;margin-left: 20px">
		<div class="fl_l">
			<!-- input type="button" class="btn_basic" value="add" /-->
			<input type="button" class="btn_basic" value="Paste" onClick="gridList.clipDataView()" id="clipboardLayerBtn"/>
			<span id="clipboardLayerDesc">Ctrl+C copy clipboard</span>
		</div>
		<div class="fl_r">
			<input type="button" class="btn_gray" value="close" onclick="hideClipSave()"/>
		</div>
	</div>
</div>
<!-- clipboard popup -->
<!-- excelUpload popup -->
<div class="layer_popup" id="excelUploadLayer" style="left:50%;top:50%;width:485px;margin:-250px 0 0 -350px;display:none;"><!-- 팝업 위치는 알아서 변경해주세요 -->
	<div class="layer_search">
		<div class="table_list01 scroll" style="height:70px"><!-- 높이값 맞게 변경 -->
			<form action='/common/grid/excel/fileUp/excel.data' enctype='multipart/form-data' method='post' id='gridExcelUploadForm'>
				<input type='file' name='gridExcelUp' validate='required excel'/>
				<input type='submit' value='upload'/>
			</form>
		</div>
	</div>
	<div class="btn_wrap" style="width:455px;margin-left: 15px">
		<div class="fl_l">
			<input type="button" class="btn_basic" value="Template" onClick="gridList.excelUploadTemplateDown()"/>
		</div>
		<div class="fl_r">
			<input type="button" class="btn_gray" value="close" onclick="hideExcelUpload()"/>
		</div>
	</div>
</div>
<!-- excelUpload popup -->
<!-- fileUpload popup -->
<div class="layer_popup" id="fileUploadLayer" style="left:50%;top:50%;width:485px;margin:-250px 0 0 -350px;display:none;"><!-- 팝업 위치는 알아서 변경해주세요 -->
	<div class="layer_search">
		<div class="table_list01 scroll" style="height:30px"><!-- 높이값 맞게 변경 -->
			<form action='/common/fileUp/file.data' enctype='multipart/form-data' method='post' id='fileUploadForm'>
				<input type='hidden' name='FILE_TYPE'/>
				<input type='file' name='fileUp' validate='required'/>				
				<input type='submit' value='upload'/>
			</form>
		</div>
		<div class="table_list01 scroll" style="height:200px;"><!-- 높이값 맞게 변경 -->
			<span id="fileNameView"></span><br/>
			<img id="fileImageView" src="" height="180px" onClick="gridList.fileDownload()"/>
		</div>
	</div>
	<div class="btn_wrap" style="width:455px;margin-left: 15px">
		<div class="fl_l">
			<input type="button" class="btn_basic" value="Download" onClick="gridList.fileDownload()"/>
		</div>
		<div class="fl_r">
			<input type="button" class="btn_basic" value="delete" onclick="gridList.fileDelete()"/>
			<input type="button" class="btn_gray" value="close" onclick="hideFileUpload()"/>
		</div>
	</div>
</div>
<!-- fileUpload popup -->
<!-- MFileUpload popup -->
<div class="layer_popup" id="mFileUploadLayer" style="left:50%;top:50%;width:355px;margin:-250px 0 0 -350px;display:none;"><!-- 팝업 위치는 알아서 변경해주세요 -->
	<div class="layer_search scroll" style="width:340px">
		<div class="table_list01"><!-- 높이값 맞게 변경 -->
			<form action='/common/fileUp/mfile.data' enctype='multipart/form-data' method='post' id='mFileUploadForm'>
				<input type='hidden' name='FILE_TYPE'/>
				<input type="hidden" name="GUUID" />				
				<input type='file' name='fileUp0' validate='required'/><br/>				
				<input type="button" class="btn_basic" value="Add" onClick="mFileAdd()" style="margin-bottom: 20px"/><br/>
				<input type='submit' value='upload' style="margin-top: 20px"/>
			</form>
		</div>
		<div class="table_list01">

		</div>
	</div>
	<div class="btn_wrap" style="width:340px">
		<div class="fl_r">
			<input type="button" class="btn_gray" value="close" onclick="hideMFileUpload()"/>
		</div>
	</div>
</div>
<!-- MFileUpload popup -->
<!-- Filter popup -->
<div class="layer_popup" id="filterLayer" style="left:50%;top:50%;width:484px;margin:-250px 0 0 -350px;display:none;"><!-- 팝업 위치는 알아서 변경해주세요 -->
	<div class="layer_search">
		<div class="layer_left section" style="width:213px;"><!-- width 맞게 변경 -->
			<strong class="layer_stit" CL="STD_COLUMN">열</strong>
			<div class="input_list scroll tableBody" style="height:300px"><!-- height 맞게 변경 -->
				<table>
					<colgroup>
						<col width="50" />
						<col width="200" />
					</colgroup>
					<tbody id="filterColList">
						<tr CGRow="true">
							<td GCol="rowCheck"></td>
							<td GCol="text,COLTEXT"></td>
						</tr>
					</tbody>
				</table>				
			</div>
		</div>
		<div class="layer_right section" style="width:200px"><!-- width 맞게 변경 -->
			<input type="checkbox" onClick="gridList.checkAll('filterDataList')" style="position:absolute; top:3px; left:37px;"/>
			<span class="layer_stit" CL="STD_COLDATA">합계항목</span>
			<div class="input_list scroll tableBody" style="height:300px"><!-- height 맞게 변경 -->
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
	<div class="btn_wrap" style="width:440px;margin-left: 20px">
		<div class="fl_l" style="width:65%">
			<input type="button" class="btn_gray" value="clear" onClick="gridList.filterDataClear()" />
		</div>
		<div class="fl_r" style="width:35%">
			<input type="button" class="btn_basic" value="confirm" onClick="gridList.filterDataConfirm()" />
			<input type="button" class="btn_gray" value="close" onClick="hideGridFilter()" />
		</div>
	</div>
</div>
<!-- Filter popup -->
<!-- Sub total popup -->
<div class="layer_popup" id="subTotalLayer" style="left:50%;top:50%;width:484px;margin:-250px 0 0 -350px;display:none;"><!-- 팝업 위치는 알아서 변경해주세요 -->
	<div class="layer_search">
		<div class="layer_left section" style="width:213px;"><!-- width 맞게 변경 -->
			<strong class="layer_stit" CL="STD_COLUMN">열</strong>
			<div class="input_list scroll tableBody" style="height:300px"><!-- height 맞게 변경 -->
				<table>
					<colgroup>
						<col style="width:30px"/><col style="width:170px"/>
					</colgroup>
					<tbody id="subTotalColList">
						<tr CGRow="true">
							<td GCol="rowCheck"></td>
							<td GCol="text,COLTEXT"></td>
						</tr>
					</tbody>
				</table>				
			</div>
		</div>
		<div class="layer_right section" style="width:200px"><!-- width 맞게 변경 -->
			<strong class="layer_stit" CL="STD_TOTCOL">합계항목</strong>
			<div class="input_list scroll tableBody" style="height:300px"><!-- height 맞게 변경 -->
				<table>
					<colgroup>
						<col style="width:30px"/><col style="width:170px"/>
					</colgroup>
					<tbody id="subTotalDataList">
						<tr CGRow="true">
							<td GCol="rowCheck"></td>
							<td GCol="text,COLTEXT"></td>
						</tr>
					</tbody>
				</table>
			</div>
		</div>
	</div>
	<div class="btn_wrap">
		<div class="fl_l" style="width:65%">
			<input type="button" class="btn_gray" value="clear" onClick="gridList.subTotalClear()" />
		</div>
		<div class="fl_r" style="width:35%">
			<input type="button" class="btn_basic" value="confirm" onClick="gridList.subTotalConfirm()" />
			<input type="button" class="btn_gray" value="close" onClick="hideGridSubTotal()" />
		</div>
	</div>
</div>
<!-- Sub total popup -->
<!-- multiinput popup -->
<div class="layer_popup" id="rangeLayer" style="left:50%;top:50%;width:400px; transform: translate(-50%, -50%);display:none;"><!-- 팝업 위치는 알아서 변경해주세요 -->
	<div class="tabs content_layout">
		<ul class="tab tab_style02">
			<li><a href="#rangeLayer-tab1"><span>단일값</span></a></li>
			<li><a href="#rangeLayer-tab2"><span>범위값</span></a></li>
		</ul>
		<div id="rangeLayer-tab1">
			<div class="table_box section">
				<div class="table_list01">
					<!-- thead tbody width값 맞춤-->
					<div class="table_thead">
						<table>
							<colgroup>
								<col width="50px" />
								<col width="100px" />
								<col width="50px" />
								<col width="160px" />
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
					<div class="scroll">
						<table class="table_c">
							<colgroup>
								<col width="50px" />
								<col width="100px" />
								<col width="50px" />
								<col width="160px" />
							</colgroup>
							<tbody id="rangeSingleList">
								<tr CGRow="true">
									<td GCol="rownum">1</td>
									<td GCol="select,LOGICAL" class="ico">
										<select>
											<option value="OR" selected="selected">OR</option>
											<option value="AND">AND</option>
										</select>
									</td>
									<td GCol="select,OPER" class="ico">
										<select>
											<option value="E" selected="selected">=</option>
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
				<div class="btn_wrap">
					<div class="fl_l">
						<!-- input type="button" class="btn_basic" value="add" /-->
						<input type="button" class="btn_gray" value="reset" onClick="rangeObj.clearRange('rangeSingleList')"/>
					</div>
					<div class="fl_r">
						<input type="button" class="btn_basic" value="confirm" onClick="rangeObj.confirmRange()"/>
						<input type="button" class="btn_gray" value="close" onclick="rangePopClose()"/>
					</div>
				</div>
			</div>
		</div>
		<div id="rangeLayer-tab2">
			<div class="table_box section">
				<div class="table_list01">
					<!-- thead tbody width값 맞춤-->
					<div class="table_thead">
						<table>
							<caption>table list head</caption>
							<colgroup>
								<col width="50px" />
								<col width="50px" />
								<col width="130px"/>
								<col width="130px"/>
							</colgroup>
							<thead>
								<tr>
									<th CL='BOTTOM_NUM'></th>
									<th CL='BOTTOM_OPER'></th>
									<th CL='BOTTOM_FROM'></th>
									<th CL='BOTTOM_TO'></th>
								</tr>
							</thead>
						</table>
					</div>
					<div class="scroll">
						<table class="table_c">
							<caption>table list head</caption>
							<colgroup>
								<col width="50px" />
								<col width="50px" />
								<col width="130px"/>
								<col width="130px"/>
							</colgroup>
							<tbody id="rangeRangeList">
								<tr CGRow="true">
									<td GCol="rownum">1</td>
									<td GCol="select,OPER" class="ico">
										<select>
											<option value="E" selected="selected">=</option>
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
				<div class="btn_wrap">
					<div class="fl_l">
						<!-- input type="button" class="btn_basic" value="add" /-->
						<input type="button" class="btn_gray" value="reset" onClick="rangeObj.clearRange('rangeRangeList')"/>
					</div>
					<div class="fl_r">
						<input type="button" class="btn_basic" value="confirm" onClick="rangeObj.confirmRange()"/>
						<input type="button" class="btn_gray" value="close" onclick="rangePopClose()"/>
					</div>
				</div>
			</div>
		</div>
	</div>
</div>
<!-- multiinput popup -->