<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>인터페이스 로그별 상세내역</title>
<%@ include file="/common/include/webdek/head.jsp" %>
<script type="text/javascript">

	window.resizeTo('1250','600');
	var iftbl;
	var ifid;
	var logseqno;
	var bwart;
	var bwartnm;
	var sysfr;
	var systo;
	$(document).ready(function(){
		var data = page.getLinkPopData();
		dataBind.dataNameBind(data, "searchArea");
		
		logseqno = data.get("SEQNO");
		ifid = data.get("IFID");
		iftbl = data.get("IFTBL");
		bwart = data.get("BWART");
		bwartnm = data.get("BWARTNM");
		sysfr = data.get("SYSFR");
		systo = data.get("SYSTO");

		$("#IFID").val(ifid);
		$("#IFKNM").val(data.get("IFKNM"));
		$("#IFTBL").val(iftbl);
		$("#BWARTNM").val(bwartnm);


		setHead();
		
		searchList();
	});

	/** HEAD 셋팅 및 조회처리 **/
	function setHead() {
		$("#resetTable").empty();
		$("#resetUtil").empty();
		var html='<table class="table_c">';
			html +='<tbody id="gridListSub">';
			html +='<tr id="appendBodyGrid" CGRow="true">';
			html +='</tr>';
			html +='</tbody>';
			html +='</table>';
		$("#resetTable").html(html);

		var util = '<div class="btn_lit tableUtil">';
			util += '<button type="button" GBtn="find"></button>';
			util += '<button type="button" GBtn="sortReset"></button>';
			util += '<button type="button" GBtn="total"></button>';
			util += '<button type="button" GBtn="excel"></button>';
			util += '<span class="txt_total" >총 건수 : <span GInfoArea="true">0</span></span>';
			util += '</div>';
		$("#resetUtil").html(util);
		
			var colH;
			var colI;

			colH = ['인터페이스SEQ','인터페이스ID','인터페이스','송신','수신',sysfr+'필드',systo+'필드','필드SUBLEN','디폴트값','순번','필드사용여부','BIGDICEMALL여부','MES필드','연동시스템필드','날짜길이'];
			colI = ['SEQNO','IFID','IFKNM','SYSFR','SYSTO','MESFLD','TARFLD','SLEN','DFVAL','ORD','USEYN','BIGDECYN','MESFLDNM','TARFLDNM','DATELEN'];

			$("#appendBodyGrid").append('<td GH="40" GCol="rownum">1</td>');
			var typstr = "";
			for(var i=0; i < colH.length; i++){
				var width = colH[i].length > 10 ? 160 : (colH[i].length > 6 ? 130 : 100);
				if(colI[i] == "QTYPRD" || colI[i] == "MENGE" || colI[i] == "MENGE_B" || colI[i] == "QTYGOD"
				|| colI[i] == "QTYBAD" || colI[i] == "QTSHP" || colI[i] == "ZQTSACT" || colI[i] == "QTADJU") {
					typstr = 'GF="N 20,3"';
				} else if(colH[i].search(/일자/) != -1){
					typstr = 'GF="D"';
				} else {
					typstr = "";
				}
				if(i<5) {
					$("#appendBodyGrid").append('<td GH="' + width + ' ' + colH[i] + '" GCol="text,' + colI[i] + '" ' + typstr + '></td>');
				}else {
					$("#appendBodyGrid").append('<td GH="' + width + ' ' + colH[i] + '" GCol="input,' + colI[i] + '" ' + typstr + '></td>');
				}
			}
		$('.closer').click();


		gridList.setGrid({
			id : "gridListSub",
			module : "Erpif",
			command :  "IFMAP",
			colorType : true,
			emptyMsgType : false
		});

	}

	function fn_closing(){
		this.close();
	}

	function saveData(){
		var param = new DataMap();
		var list = gridList.getGridData("gridListSub");
		param.put("list", list);
		param.put("ifid", ifid);
		if(list.length === 0) return

		var json = netUtil.sendData({
			url : "/if/itf/field/json/save.data",
			param : param
		});
		if(json.data == 'SUCCESS') {
			searchList()
		}else {
			alert('저장 실패')
		}
	}
	
	function commonBtnClick(btnName){
		if(btnName == "Search"){
			searchList();
		} else if(btnName == "Close"){
			fn_closing();
		} else if(btnName == "Download"){
			excelDownload();
		}
		else if(btnName == "Save"){
			saveData();
		}
	}
	
	var timerId = 0;
	var ingCnt;
	function showCnt() {
		cnt.value = ingCnt;
	}

	function searchList(){
		var param = new DataMap();
		param.put("LOGSEQNO", logseqno);
		param.put("IFTBL", iftbl);
		param.put("IFID", ifid);

		gridList.gridList({
			id : "gridListSub",
			param : param
		});
	}
</script>
</head>
<body>
<%@ include file="/common/include/webdek/layout.jsp" %>
<!-- content -->
<div class="content_wrap">
	<div class="content_inner">
		<%@ include file="/common/include/webdek/title.jsp" %>
		<div class="content_serch" id="searchArea">
			<div class="btn_wrap">
				<div class="fl_l">
					<input type="button" CB="Save SEARCH 저장">
				</div>
				<div class="fl_r">
					<input type="button" CB="Search SEARCH BTN_DISPLAY">
					<input type="button" CB="Close CHECK 닫기">
				</div>
			</div>
			<div class="search_inner">
				<div class="search_wrap">
					<dl>
						<dd>
							<table style="width:1000px;">
								<tr>
									<td style="width:170px;">인터페이스ID : <input type="text" id="IFID" style="width:80px;" readonly></td>
									<td style="width:300px;">인터페이스명 : <input type="text" id="IFKNM" style="width:210px;" readonly></td>
									<td style="width:150px;">IF테이블 : <input type="text" id="IFTBL" style="width:80px;" readonly></td>
								</tr>
							</table>
						</dd>
					</dl>
				</div>
				<div class="btn_tab">
					<input type="button" class="btn_more" value="more" onclick="searchMore()"/>
				</div>
			</div>
		</div>
		<div class="search_next_wrap">
			<div class="content_layout tabs">
				<ul class="tab tab_style02">
					<li><a href="#tabs1-1" CL='STD_LIST'><span>리스트</span></a></li> 
				</ul>
				<div class="table_box section" id="tabs1-1">
					<div class="table_list01">
						<div class="scroll">
							<table id="resetTable" class="table_c">
							</table>
						</div>
					</div>

					<div class="btn_lit tableUtil">
						<button type='button' GBtn="find"></button>
						<button type='button' GBtn="sortReset"></button>
						<button type='button' GBtn="add"></button>
						<button type='button' GBtn="copy"></button>
						<button type='button' GBtn="delete"></button>
						<button type='button' GBtn="total"></button>
						<button type='button' GBtn="layout"></button>
						<button type='button' GBtn="excel"></button>
						<button type='button' GBtn="excelUpload"></button>
						<span class='txt_total' >총 건수 : <span GInfoArea='true'>4</span></span>
					</div>
				</div>
			</div>
		</div>
	</div>
</div>
<!-- // content -->
</body>
<%@ include file="/common/include/webdek/bottom.jsp" %>
</html>