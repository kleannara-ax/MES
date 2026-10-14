
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<!doctype html>
<head>
	<style type="text/css">
		.tem5_content .tableWrap_search select	{width:172px;  height:25px; }
		.tem5_content .tableWrap_search .text_2{width:90%; margin-right:3px;height:22px;border:#b8b8b8;}

		.select-editable { position:relative; background-color:white; border:solid 1px #b8b8b8; width:172px; height:25px; }
		.select-editable select { top:0px; left:0px; width:172px; height:25px; font-size:14px;  border:none;  }
		.select-editable input { position:absolute; top:0px; left:0px; width:90%; height:23px; font-size:12px;  border:none;   }
		.select-editable select:focus, .select-editable input:focus { outline:none; }

		.select-editable { position:relative; background-color:white; border:solid 1px #d5d5d5; width:100%; height:35px; }
		.select-editable select { position:absolute; top:0px; left:0px; width:100%; height:35px; font-size:14px;  border:none;  }
		.select-editable input { position:absolute; top:0px; left:0px; width:90%; height:33px; font-size:12px;  border:none;   }
		.select-editable select:focus, .select-editable input:focus { outline:none; }
		/* .tableBody{height: 395px !important;} */

	</style>

	<meta charset="utf-8">
	<meta name="viewport" content="user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, width=device-width, target-densitydpi=medium-dpi" />
	<meta name="format-detection" content="telephone=no" />
	<title>투입단위</title>
	<%@ include file="/mobile/include/head.jsp" %>
	<script>
		var data;
		$(document).ready(function(){
			gridList.setGrid({
				id : "gridList",
				module : "Mobile",
				command : "UNIT",
				gridMobileType : true
			});
			
			data = mobile.getLinkPopData();
			
			searchList();
		});

		function searchList(){
			PlaySound('s');
			
			var param = new DataMap();

			gridList.gridList({
				id : "gridList",
				param : param
			});
		}
		
		function unitCheck(){
			var unit = gridList.getColData("gridList", gridList.getFocusRowNum("gridList"), "UNIT");
			
			var param = new DataMap();
			
			param.put("UNIT", unit);
			param.put("flag", data);
			
			mobile.linkPopClose(param);
		}
	</script>
</head>
<body>
<div class="main_wrap">
	<div class="main_header_pop">
		<ul>
			<li class="tit" id="title">투입단위</li>
		</ul>
	</div>
	<div class="tem4_content">
		<div class="select_box" id="bindArea">
			<div class="searchArea" id="searchArea">
				<table>
				</table>
			</div>
		</div>

		<div class="tableWrap_search section">
			<div class="tableHeader">
				<table>
					<colgroup>
						<col width="10px" />
						<col width="20px" />
						<col width="30px" />
					</colgroup>
					<thead>
						<tr>
							<th>No</th>
							<th>단위</th>
							<th>단위명</th>
						</tr>
					</thead>
				</table>
			</div>

			<div class="tableBody">
				<table>
					<colgroup>
						<col width="10px" />
						<col width="20px" />
						<col width="30px" />
					</colgroup>
					<tbody id="gridList">
						<tr CGRow="true">
							<td GCol="rownum"></td>
							<td GCol="text,UNIT"></td>
							<td GCol="text,UNIT_NM"></td>
						</tr>
					</tbody>
				</table>
			</div>
		</div>

		<!-- end table_body -->
		<div class="footer_5" style="position:fixed;">
			<table>
				<tr>
					<td class=f_1 onclick="mobile.linkPopClose();" style="width: 50%"><label>닫기</label></td>
					<td class=f_1 onclick="unitCheck();" style="width: 50%;"><label >선택</label></td>
				</tr>
			</table>
		</div>
		<!-- end footer_5 -->
	</div>
</div>
</body>