<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>MAP SAMPLE</title>
<link rel="stylesheet" type="text/css" href="/map/ol-4.6.5.css">
<%@ include file="/common/include/webdek/head.jsp" %>
<script type="text/javascript" src="/common/js/bl.js"></script>
<script type="text/javascript" src="/map/ol-4.6.5.js"></script>
<script type="text/javascript" src="/map/gcenmap.js"></script>
<script type="text/javascript">
	var buttomAutoResize = false;
	var map;                // 지도 전역 변수
	var view;               // view 전역 변수
	var markerSource;
	var markerLayer;
	var markerIndex = 0;
	
	$(document).ready(function(){
		gridList.setGrid({
	    	id : "gridList",
	    	module : "MD1000",
			command : "MD1102",
			itemGrid : "gridList2",		/* 아이템 그리드 연결 */
			itemSearch : true,		    /* 아이템 검색 사용 - 자동으로 item grid 조회*/
	    });
		
		gridList.setGrid({
			id : "gridList2",
	    	module : "MD1000",
			command : "MD1102_mappingBizGrid",
			emptyMsgType : false,
			autoCopyRowType : false
	    });
		
		var lon = 127.100426600818;
		var lat = 37.3177715447;
		
		view = new ol.View({
			center: ol.proj.fromLonLat([lon, lat]), // 페이지 시작시 지도 중심 좌표 설정
			zoom: 70,       // 페이지 시작시 지도 레벨 설정(필수)
			minZoom: 5,     // 축소 지도 레벨 설정(필수)
			maxZoom: 18,     // 확대 지도 레벨 설정(필수),
			projection: 'EPSG:3857'	// 좌표계
		});
		
		// 지도 객체 선언
		map = gcen.loadMap("map", view, "vt_maplabel");
		
		var zoomControl = new ol.control.Zoom();
		
		map.addControl(zoomControl);
		
		// marker 소스 생성
		var markerSource = new ol.source.Vector();
		
		// marker 레이어 생성
		markerLayer = new ol.layer.Vector({
			id: "markerLayer",
			source: markerSource
		});
		
		// 지도에 레이어 추가
		map.addLayer(markerLayer);
		
		var zoomControl = new ol.control.Zoom();
		
		map.addControl(zoomControl);
	});

	function searchList(){
		if(validate.check("searchArea")){
			var param = inputList.setRangeParam("searchArea");

			gridList.gridList({
		    	id : "gridList",
		    	param : param
		    });
			
			gridList.gridList({
		    	id : "gridList2",
		    	param : param
		    });
		}
	}
	function saveData(){
		alert("샘플입니다.");
	}

	function commonBtnClick(btnName){
		//commonUtil.debugMsg("commonBtnClick : ", arguments);
		if(btnName == "Search"){
			searchList();
		}else if(btnName == "Save"){
			saveData();
		}
	}

	function addMarkerFeature(lon, lat, makerNm){
		
        var marker = new ol.Feature({
            geometry: new ol.geom.Point(ol.proj.fromLonLat([lat, lon]))
        });
        
        markerIndex++;
        marker.setId("markerFeature"+markerIndex);

        marker.setStyle(new ol.style.Style({
            zIndex: markerIndex==1 ? 100:1,
            image: new ol.style.Icon({
                anchor: [0.5, 1],
                opacity: 1,
                src: "/map/sample.png"
            }),
            text: new ol.style.Text({
                text: makerNm,
                stroke: new ol.style.Stroke({ color:"#fff", width:3.5 }),
                fill: new ol.style.Fill({color:"#333"}),
                font: '15px sans-serif'
            })
        }));

        markerSource.addFeature(marker);
        moveCenter(lon, lat);
    }
	
	function moveCenter(lon, lat) {
		view.animate({
            center: ol.proj.fromLonLat([lon, lat]),
            duration: 200
        });
		
		/*
		view = new ol.View({
	        center: ol.proj.fromLonLat([lon, lat]), // 페이지 시작시 지도 중심 좌표 설정
	        zoom: 10,       // 페이지 시작시 지도 레벨 설정(필수)
	        minZoom: 5,     // 축소 지도 레벨 설정(필수)
	        maxZoom: 18,     // 확대 지도 레벨 설정(필수),
	        projection: 'EPSG:3857'	// 좌표계
	    });
		*/
		
	}
	/*
		공통 itemGrid 조회 및 / 더블 클릭 Event
	*/
	function gridListEventItemGridSearch(gridId, rowNum, itemGridList){
		if( gridId == "gridList" ){
			 
			for(var i = 0; i < itemGridList.length; i++) {
				gridList.resetGrid(itemGridList[i]);
				
				var params = inputList.setRangeParam("searchArea");	// var param = new DataMap();
				var rowData = gridList.getRowData(gridId, rowNum);
				params.putAll(rowData);
				
	           	gridList.gridList({
		            id : itemGridList[i],
		            param : params
				});
			}
	    }
	}
	
	/* 다음 api종료 후 결과 */
	function execDaumPostcodeEnd(areaIdList, zonecode, addr, addr2) {
		gridId = "gridList";
		rowNum = gridList.getFocusRowNum(gridId);
		gridList.setColValue(gridId, rowNum, "BIZPLC_ADDR", addr);
		gridList.setColValue(gridId, rowNum, "POST_NO", zonecode);
		gridList.setColValue(gridId, rowNum, "DTL_ADDR", addr2);
		
		// 주소 보정 데이터
		var map = bl.geocoding(addr);
		gridList.setColValue(gridId, rowNum, "SIDO_CD", map.get("SIDO_CD"), true);
		gridList.setColValue(gridId, rowNum, "LDG_CD", map.get("LDG_CD"), true);
		gridList.setColValue(gridId, rowNum, "LAT", map.get("LAT"), true);
		gridList.setColValue(gridId, rowNum, "LON", map.get("LON"), true);
		gridList.setColValue(gridId, rowNum, "UMTK_X_VAL", map.get("UMTK_X_VAL"), true);
		gridList.setColValue(gridId, rowNum, "UMTK_Y_VAL", map.get("UMTK_Y_VAL"), true);
		gridList.setColValue(gridId, rowNum, "ADDR_CRT_ERR_YN", map.get("ADDR_CRT_ERR_YN"), true);
	}
	
	/* 그리드의 버튼을 클릭하는 이벤트	*/
	function gridListEventColBtnClick(gridId, rowNum, colName) {
		if(gridId == "gridList" && colName == "BTN_ADDR") {
			execDaumPostcode(['addrArea'], 'POST_NO', 'BIZPLC_ADDR', 'DTL_ADDR');
		}else if(gridId == "gridList" && colName == "BTN_MAP") {
			if(bl.isNull(gridList.getColData(gridId, rowNum, "LON"))
				|| bl.isNull(gridList.getColData(gridId, rowNum, "LAT"))
			) {
				commonUtil.msgBox("BL_REQUIREDMAPPOINT");
				return;
			}
			
	    	var lon = gridList.getColData(gridId, rowNum, "LON");
	    	var lat = gridList.getColData(gridId, rowNum, "LAT");
	    	var makerNm = gridList.getColData(gridId, rowNum, "BIZPLC_NM");
	    	
	    	lon = parseFloat(lon);
	    	lat = parseFloat(lat);
	    	addMarkerFeature(lon, lat, makerNm);
		}
	}
</script>
</head>
<body style="min-width:1267px;">
<%@ include file="/common/include/webdek/layout.jsp" %>
<!-- content -->
<div class="content_wrap">
	<div class="content_inner">
		<%@ include file="/common/include/webdek/title.jsp" %>
		<div class="content_serch" id="searchArea">
			<div class="btn_wrap">
				<div class="fl_l">
				</div>
				<div class="fl_r">
					<input type="button" CB="Search SEARCH BTN_SEARCH" />
					<input type="button" CB="Save SAVE BTN_SAVE" />
				</div>
			</div>
			<div class="search_inner">
				<div class="search_wrap ">
					<dl>
						<dt CL="STD_BIZPLC_NM"></dt>
						<dd>
							<input type="text" class="input" name="A.BIZPLC_NM" IAname="Search" UIInput="SR" maxlength="50"/>
						</dd>
					</dl>
					<dl>
						<dt CL="STD_BIZPLC_ADDR"></dt>
						<dd>
							<input type="text" class="input" name="A.BIZPLC_ADDR" IAname="Search" UIInput="SR"  maxlength="150"/>
						</dd>
					</dl>
					<dl>
						<dt CL="STD_DEL_YN"></dt>
						<dd>
							<select name="DEL_YN" class="input" commonCombo="STATE_YN" ComboCodeView="false" style="width:70px"><option value="">전체</option></select>
						</dd>
					</dl>
				</div>
				<div class="btn_tab">
					<input type="button" class="btn_more" value="more" onclick="searchMore()"/>
				</div>
			</div>
		</div>
		<div class="content_layout tabs" style="height:325px">
			<ul class="tab tab_style02">
				<li><a href="#tab1-1"><span>일반</span></a></li>
				<li class="btn_zoom_wrap">
					<ul>
						<!-- <li><button class="btn btn_smaller"><span>축소</span></button></li> -->
						<li><button class="btn btn_bigger"><span>확대</span></button></li>
					</ul>
				</li>
			</ul>
			<div class="table_box section" id="tab1-1">
				<div class="table_list01">
					<div class="scroll">
						<table class="table_c">
							<tbody id="gridList">
								<tr CGRow="true">
									<td GH="40" 					GCol="rownum">1</td>
									<td GH="40" 					GCol="rowCheck"></td>
									<!-- <td GH="150 STD_BIZPLC_CD" 		GCol="text,BIZPLC_CD"></td> -->
									<td GH="100 STD_BIZPLC_NM" 		GCol="text,BIZPLC_NM" 		 GF="S 50" validate="required"></td>
									<td GH="100 STD_CTTPC" 			GCol="text,CTTPC" 					   validate="tel"></td>
									<td GH="100 BL_BIZ_ADDT_MNG"    GCol="text,BIZ_ADDT_MNG_NM" ></td>
									<td GH="100 STD_POST_NO" 		GCol="text,POST_NO"></td>
									<td GH="200 STD_BIZPLC_ADDR" 	GCol="text,BIZPLC_ADDR"></td> 
									<!-- <td GH="100 STD_ADDR" 			GCol="btn,BTN_ADDR" 		 GB="ZIPCODE SEARCH 검색"></td> --> 
									<td GH="160 STD_DTL_ADDR" 		GCol="text,DTL_ADDR"		 GF="S 150"></td>
									<td GH="100 STD_RMK_CNTS" 		GCol="input,RMK_CNTS" 		 GF="S 1000"></td>
									<td GH="80 STD_LAT" 			GCol="text,LAT" 			 GF="N"></td>
									<td GH="80 STD_LON" 			GCol="text,LON" 			 GF="N" ></td>
									<td GH="80 STD_UMTK_X_VAL" 		GCol="text,UMTK_X_VAL" 		 GF="N"></td>
									<td GH="80 STD_UMTK_Y_VAL" 		GCol="text,UMTK_Y_VAL" 		 GF="N"></td>
									<td GH="100 STD_LOCTN" 			Gcol="btn,BTN_MAP" 			 GB="MAP SEARCH STD_LOCTN"></td>
									<td GH="100 STD_DELIV_GRP_CD" 	GCol="text,DELIV_GRP_CD"></td> 
									<td GH="100 STD_DELIV_GRP_NM"	GCol="text,DELIV_GRP_NM"></td> 			
									<td GH="80 STD_DEL_YN" 			GCol="check,DEL_YN"></td>
									<td GH="80 BL_SIDO_CD"			GCol="text,SIDO_CD"></td>
									<td GH="80" 					GCol="text,LDG_CD"></td>
									<td GH="100 BL_ADDR_CRT_ERR_YN" GCol="text,ADDR_CRT_ERR_YN"></td>
									<td GH="80 STD_UDT_ID" 			GCol="text,UDT_ID"></td>
									<td GH="120 STD_UDT_DT" 		GCol="text,UDT_DT"			 GF="DT"></td>
									<td GH="80 STD_REG_ID" 			GCol="text,REG_ID"></td>
									<td GH="120 STD_REG_DT" 		GCol="text,REG_DT" 			 GF="DT"></td>
								</tr>
							</tbody>
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
		
		<div class="handler_wrap">
			<div class="handler"></div>
		</div>
		
		<div class="content-horizontal-wrap" style="height: calc(100% - 442px);">
			<div class="content_layout tabs content_left" style="height: calc(100% - 20px);margin-top:0px;">
				<ul class="tab tab_style02">
					<li><a href="#tab1-1"><span>일반</span></a></li>
					<li class="btn_zoom_wrap">
						<ul>
							<!-- <li><button class="btn btn_smaller"><span>축소</span></button></li> -->
							<li><button class="btn btn_bigger"><span>확대</span></button></li>
						</ul>
					</li>
				</ul>
				<div class="table_box section" id="tab1-1">
					<div class="table_list01">
						<div class="scroll">
							<table class="table_c">
								<tbody id="gridList2">
									<tr CGRow="true">
										<td GH="40"                GCol="rownum">1</td>
										<td GH="40" 			   GCol="rowCheck"></td>
										<td GH="120"               GCol="select,HQ_CD">
											<select Combo="BLCOMMON,HQCDCOMBO" disabled="disabled"><option value=""> </option></select>
										</td>
										<td GH="150"               GCol="select,SPOT_CD">
											<select Combo="BLCOMMON,SPOTCDCOMBO" disabled="disabled"><option value=""> </option></select>
										</td>
										<td GH="80 STD_BZO_CD"     GCol="text,BZO_CD"></td>
										<td GH="150 STD_BZO_NM"    GCol="text,BZO_NM"></td>
										<td GH="80 STD_CTTPC"      GCol="text,CTTPC"></td>
										<td GH="150 STD_REP_SM_ID" GCol="text,REP_SM_ID"></td>
										<td GH="80 STD_RMK_CNTS"   GCol="text,RMK_CNTS"></td>
										<td GH="80 STD_UDT_ID" 	   GCol="text,UDT_ID"></td>
										<td GH="120 STD_UDT_DT"    GCol="text,UDT_DT"		GF="DT"></td>
										<td GH="80 STD_REG_ID" 	   GCol="text,REG_ID"></td>
										<td GH="120 STD_REG_DT"    GCol="text,REG_DT" 	    GF="DT"></td>								
									</tr>
								</tbody>
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
			
			<div class="handlerH_wrap">
				<div class="handlerH"></div>
			</div>
			
			<div class="content_layout tabs content_right" style="min-width:unset;margin-top:0px;height: calc(100% - 20px);">
				<ul class="tab tab_style02">
					<li><a href="#tab1-1"><span>지도</span></a></li>
					<li class="btn_zoom_wrap">
						<ul>
							<!-- <li><button class="btn btn_smaller"><span>축소</span></button></li> -->
							<li><button class="btn btn_bigger"><span>확대</span></button></li>
						</ul>
					</li>
				</ul>
				<div class="table_box section" id="tab1-1">
					<div class="scroll">
						<div id="map" class="map" style="width: 100%; height: 100%;"></div>
					</div>
				</div>
			</div>
		</div>
	</div>
</div>
<!-- // content -->
<%@ include file="/common/include/webdek/bottom.jsp" %>
</body>
</html>