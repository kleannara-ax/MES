<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
	String BARCOD = request.getParameter("BARCOD");
%>
<!doctype html>
<head>
    <style type="text/css">
        button {float: right; }
        input:read-only {background-color: #e2e2e2;}
        select:DISABLED {background-color: #e2e2e2;}
    </style>
    <meta charset="utf-8">
    <meta name="viewport" content="user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, width=device-width, target-densitydpi=medium-dpi" />
    <meta name="format-detection" content="telephone=no" />
    <title>Mobile MES</title>
<%@ include file="/mobile/include/head.jsp" %>
<script>
	$(document).ready(function () {
		init();

		var param = searchedParam == null ? mobile.getLinkPopData() : searchedParam;
		var module = param.get('module');
		var command = param.get('command');

		if(!module) {
			alert('required module');
			self.close();
			return;
		}

		if(!command) {
			alert('required command');
			self.close();
			return;
		}

		gridList.setGrid({
			id : "gridList",
			editable : false,
			module : module,
			command : command,
			gridMobileType : true,
		});

		searchList(param);
	})

	var searchedParam = null;
	var selectedRowNum = 0;

	function init() {
		searchedParam  = null;
		selectedRowNum = 0;

		$('#AREAKY').val("");
		$('#ZONEKY').val("");
	}

	function searchList(param) {
		gridList.gridList({
			id : "gridList",
			param : param
		});

		searchedParam = new DataMap();
		searchedParam.putObject(structuredClone(param.map));
	}

	// select 태그 변경 이벤트
	function onChangeSelectTag (tagId) {
		var $selectTag = $('#' + tagId);

		if (tagId == 'AREAKY') { // 변경된 태그가 AREAKY인 경우 ZONEKY 재조회
			initZoneCombo();
		}

		if (tagId == 'ZONEKY') { // 변경된 태그가 ZONEKY인 경우 빈값 확인
			if ($selectTag.val() == 'empty') {
				$selectTag.val("");
				return;
			}
		}

		searchedParam.map[tagId] = $selectTag.val();
		searchList(searchedParam);
	}

	// AREAKY 변경 시 zoneCombo 재세팅
	function initZoneCombo () {
		searchedParam.remove('ZONEKY');
		$('#ZONEKY').html("");

		var json = netUtil.sendData({
			module : "WmsInventory",
			command : "ZONECOMBO",
			param : searchedParam
		});

		// 리스트 존재 시 select 태그에 대입
		if(json && json.data) {
			var data = json.data;

			for (var i in data) {
				var obj = data[i];
				var name  = obj['TEXT_COL'];
				var value = obj['VALUE_COL'];
				$('#ZONEKY').append('<option value="' + value + '">' + name + '</option>');
			}
		}

		$('#ZONEKY').val("");
	}

	// 더블클릭 이벤트
	function gridListEventRowDblclick(gridId, rowNum) {
		var data = gridList.getRowData("gridList", rowNum);
		callback(data);
	}

	// 선택버튼 클릭 이벤트
	function onClickChooseBtn() {
		var data = gridList.getRowData("gridList", selectedRowNum);
		callback(data);
	}

	// 그리드 클릭 시 rowNum 변수 저장
	function gridListEventRowClick(gridId, rowNum) {
		selectedRowNum = rowNum;
	}

	function callback (data) {
		if(!data.isEmpty()) {
			data.put('param', mobile.getLinkPopData());
			window.opener.LocPopCallback(data);
			self.close();
		}
	}

	function isSearched() {
		return searchedParam != null;
	}

</script>
</head>
<body>
	<div id="menu-container">
		<div class="menu-item"></div>
	</div>
	<div class="main_wrap" id="paramArea">
		<div class="tem4_content">
			<div class="select_box" id="bindArea">
				<table>
					<tbody>
						<tr>
							<th>작업일자1</th>
							<td colspan="2">
								<input type="text" class="text" name="LOTA11" id="LOTA11" UIFormat="C" style="width:55%; float:left;" onclick="lota1113Check()"/>
								~
							</td>
							<th>~</th>
							<td colspan="2">
								<input type="text" class="text" name="LOTA13" id="LOTA13" UIFormat="C" style="width:55%; float:left;" onclick="lota1113Check()"/>
							</td>
						</tr>
					</tbody>
				</table>
			</div>

			<hr>

			<div class="tableWrap_search section" style="margin-top: 30px;">
				<div class="tableBody">
					<table style="width: 100%">
						<colgroup>
							<col width="10%" />
							<col width="*" />
						</colgroup>
						<thead>
							<tr class="thead">
								<th CL='STD_NO'>순번</th>
								<th>지시번호</th>
								<th>설비</th>
								<th>생산코드</th>
								<th>생산제품</th>
								<th>계획수량</th>
							</tr>
						</thead>
						<tbody id="gridList">
							<tr CGRow="true">
								<td GCol="rownum">1</td>
								<td GCol="text,AREAKY"></td>
								<td GCol="text,ZONEKY"></td>
								<td GCol="text,LOCAKY"></td>
								<td GCol="text,LOCAKY"></td>
								<td GCol="text,LOCAKY"></td>
							</tr>
						</tbody>
					</table>
				</div>
			</div>
			<!-- end table_body -->
			<div class="footer_5" style="position:fixed;">
				<table>
					<tr>
						<td class=f_1 width="50%" onclick="self.close()">
							<label CL='BTN_CLOSE'></label>
						</td>
						<td class=f_1 width="50%" onclick ="onClickChooseBtn()" >
							<label CL='BTN_CHOOSE'></label>
						</td>
					</tr>
				</table>
			</div>
			<!-- end footer_5 -->

		</div>
	</div>
</body>