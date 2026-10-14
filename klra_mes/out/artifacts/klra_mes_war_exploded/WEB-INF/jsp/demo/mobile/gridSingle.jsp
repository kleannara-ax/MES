<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8" name="viewport" content="width=device-width, initial-scale=1.0" />
<%@ include file="/mobile/include/mobile_head.jsp" %>
<script type="text/javascript">
	$(document).ready(function(){
		gridList.setGrid({
	    	id : "gridList",
			module : "System",
			command : "SYSLABEL",
			gridMobileType : true
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
		if(gridList.validationCheck("gridList", "all")){
			gridList.gridSave({
		    	id : "gridList",
		    	modifyType : "A"
		    });
		}
	}
</script>

</head>
<body>
	<%@ include file="/mobile/include/msubmenu.jsp" %>
	<div class="mobile_order">
		<%@ include file="/mobile/include/mtop.jsp" %>
		<div class="m_menutitle"><span>퀵 서비스 배송접수</span></div>
		<div class="mobile-data-top">
			<div class="mobile-data-box">
				<div class="content_layout_wrap">
					<table>
						<tbody>
							<tr>
								<th>이름<span class="make">*</span></th>
								<td><input type="text" name="NAME" class="input input-width" value="사용자"></td>
							</tr>
							<tr>
								<th>연락처<span class="make">*</span></th>
								<td><input type="text" name="TEL" class="input input-width" value="010"></td>
							</tr>
						</tbody>
					</table>
				</div>
			</div>
		</div>		
		<div class="mobile-data-inner">
			<div class="mobile-data mobile-departure content_layout" >
				<div class="mobile-data-box section" style="height:calc(100% - 200px);">
					<div class="scroll" style="width:100%;height:95%;overflow:auto;white-space: nowrap;">
						<table>
							<tbody id="gridList">
								<tr CGRow="true">
									<td GH="40" GCol="rownum">1</td>
									<td GH="40" GCol="rowCheck"></td>
									<td GH="80" GCol="text,LABELGID"></td>
									<td GH="150" GCol="input,LABELID,SYSLABEL,multi"></td>
									<td GH="80" GCol="select,LANGCODE">
										<select class="input" CommonCombo="LANGKY">
										</select>
									</td>
									<td GH="150" GCol="input,LABEL"></td>
									<td GH="80" GCol="input,LABELTYPE"></td>
								</tr>
							</tbody>
						</table>
					</div>
					<div class="tableUtil">
						<span class='txt_total' >총 건수 : <span GInfoArea='true'>4</span></span>
					</div>
				</div>
			</div>
			<div class="label-btn">
				<label for="data1" onClick="searchList()">조회</label>
			</div>
		</div>
	</div>

</body>
</html>