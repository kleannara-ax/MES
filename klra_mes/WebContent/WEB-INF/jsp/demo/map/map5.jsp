<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<head>
	<meta charset="utf-8">
	<meta http-equiv="X-UA-Compatible" content="IE=edge">
	<meta name="viewport" content="initial-scale=1.0, user-scalable=no" />	
	<title>거래처조회 예제</title>

	<script src="/map/jquery-3.4.1.min.js"></script>
	<script src="/map/ol-4.6.5.js"></script>
	<script src="/map/gcenmap.js"></script>
	<link type="text/css" rel="stylesheet" href="/map/ol-4.6.5.css">

	<style>
	    html, body {
	    	height:100%;
	    	overflow:hidden
	    }
		.ol-popup
		{
			position: absolute;
			background-color: white;
			-webkit-filter: drop-shadow(0 1px 4px rgba(0,0,0,0.2));
			filter: drop-shadow(0 1px 4px rgba(0,0,0,0.2));
			/*padding: 15px;*/
			border-radius: 10px;
			border: 1px solid #cccccc;
			bottom: 12px;
			left: -50px;
			min-width: 400px;
		}
		.ol-popup:after, .ol-popup:before
		{
			top: 100%;
			border: solid transparent;
			content: " ";
			height: 0;
			width: 0;
			position: absolute;
			pointer-events: none;
		}
		.ol-popup:after
		{
			border-top-color: white;
			border-width: 10px;
			left: 48px;
			margin-left: -10px;
		}
		.ol-popup:before
		{
			border-top-color: #cccccc;
			border-width: 11px;
			left: 48px;
			margin-left: -11px;
		}
		.ol-popup-title
		{
			padding: 8px 14px;
			margin: 0;
			font-family: 'Malgun Gothic','맑은 고딕',dotum,'돋움',sans-serif ;
			font-size: 14px;
			background-color: #f7f7f7;
			border-bottom: 1px solid #ebebeb;
			border-radius: 5px 5px 0 0;
		}

		.ol-popup-content
		{
			padding: 9px 14px;
		}
		
		.ol-sub-title
		{
			border: 1px solid;
			border-color: #969696;
			font-family: 'Malgun Gothic','맑은 고딕',dotum,'돋움',sans-serif ;
			font-size: 16px;
			color: #323232;
			text-align: center;
			left: 10px;
			width: 150px;
			height : 26px;
			background-color:#f6f6f6;
			vertical-align:middle;
		}
		
		.ol-sub-content
		{
			border: 1px solid;
			border-color: #969696;
			font-family: 'Malgun Gothic','맑은 고딕',dotum,'돋움',sans-serif ;
			font-size: 14px;
			color: #323232;
			left : 10px;
			width : 400px;
			height : 26px;
			background-color: #ffffff;
			padding-left :5px;
			vertical-align: middle;
		}

	</style>
</head>
<body oncontextmenu="return false" onselectstart="return false" ondragstart="return false">

	<div id="map" class="map" style="width:100%; top:100px;height:100%;">
		<div id="popup" class="ol-popup">
			<div class="ol-popup-title">상세정보</div>
			<div class="ol-popup-content"></div>
		</div>
	</div>
	
	<div id="search" class="search" style="padding-left:0px; position:absolute; bottom:0px; left:50%;">
		<input type="button" id="searchLocate" name="searchLocate" onClick="searchLocate()" value="거래처조회">
	</div>

	<script>
	    var map;                // 지도 전역 변수
	    var view;               // view 전역 변수
	    var featureSource;
	    var featureLayer;
	    var clickOverlayId = "click-overlay";
	    
	    view = new ol.View({
	        center: ol.proj.fromLonLat([126.898758, 37.484986]), // 페이지 시작시 지도 중심 좌표 설정
	        zoom: 16,       // 페이지 시작시 지도 레벨 설정(필수)
	        minZoom: 5,     // 축소 지도 레벨 설정(필수)
	        maxZoom: 18,     // 확대 지도 레벨 설정(필수),
	        projection: 'EPSG:3857'	// 좌표계
	    });
	
	    // 지도 객체 선언
	    map = gcen.loadMap("map", view, "vt_maplabel");
		var zoomControl = new ol.control.Zoom();
		map.addControl(zoomControl);
	
		var scaleLineControl = new ol.control.ScaleLine();
		map.addControl(scaleLineControl);
		
		var container = $("#popup").get(0);
		var popup = new ol.Overlay({
			id:clickOverlayId,
			element: container,
			positioning: 'bottom-center',
			stopEvent: false,
			offset: [0, -50],
			autoPan: true,
			autoPanAnimation: { duration: 250}
		});
		map.addOverlay(popup);
		
		// feature 소스 생성
		featureSource = new ol.source.Vector();

		// feature 레이어 생성
		featureLayer = new ol.layer.Vector({
			id: "featureLayer",
			source: featureSource
		});

		// 지도에 레이어 추가
		map.addLayer(featureLayer);
		map.on("moveend", getCoordinate);
		map.on("click", onMarkerClick);
		
	    function getCoordinate(evt)
	    {
	        var size = map.getSize();
	        var extent = map.getView().calculateExtent(size);
	        var minXY = ol.proj.transform([extent[0],extent[1]], 'EPSG:3857', 'EPSG:4326');
	        var maxXY = ol.proj.transform([extent[2],extent[3]], 'EPSG:3857', 'EPSG:4326');
	        getAreaCar(minXY[1], minXY[0], maxXY[1], maxXY[0]);
	    }

		function onMarkerClick(evt)
		{
			var feature;
	        var layer;

	        map.forEachFeatureAtPixel(evt.pixel,
	            function(getFeature,getLayer)
	            {
	                feature = getFeature;
	                layer = getLayer;
	            }
	        );

			var popup = map.getOverlayById(clickOverlayId);
			var obj = popup.getElement();

	        if(layer != undefined && layer.get("id") == "featureLayer" && feature)
	        {
	        	var point;
	        	var title;
				var content;

				if(feature.getGeometry() instanceof ol.geom.Point)
				{
					point = feature.getGeometry().getCoordinates();
					content = feature.get("content");
					$(obj).find(".ol-popup-content").html(content);
				}
				popup.setOffset([0,-50]);
				popup.setPosition(point);
			}
	        else
	        {
				popup.setPosition(undefined);
			}
		}
	    
	    function drawMap(list1, list2, seltype, rownum)
	    {
	    	featureSource.clear();
	    	
	    	var sTitle;
	    	var sContent;
	    	var sLat;
	    	var sLon;
	    	var sImg = "";
	    	
			for(var i = 0 ; i < list1.length; i++)
			{
				var lat = Number(list1[i].LAT);
				var lon = Number(list1[i].LON);
				var id = list1[i].CLNT_CD;
				var title = list1[i].CLNT_NM;

				var content = "";
		        	content += "<table cellspacing='0' cellpadding='0'>";
		        	content += "<tr>";
					content += "<td class='ol-sub-title'>거래처명</td>";
		        	content += "<td class='ol-sub-content'>" + list1[i].CLNT_NM + "</td>";
		        	content += "</tr>";
		        	content += "<tr>";
		       		content += "<td class='ol-sub-title'>주소</td>";
		            content += "<td class='ol-sub-content'>" + list1[i].ADDR + "</td>";
		            content += "</tr>";
		            content += "<tr>";
		            content += "<td class='ol-sub-title'>거래처구분</td>";
		            content += "<td class='ol-sub-content'>" + list1[i].CLNT_GB + "</td>";
		            content += "</tr>";
		        	content += "</table>";
		    	
		    	if(i == rownum && seltype == "CLNT")
		    	{
		    		sImg = "/map/img/center_select.png";
		    		sLat = lat;
		    		sLon = lon;
		    		sTitle = title;
		    		sContent = content;
		    	}
		    	else
		    	{
		    		var img = "/map/img/center_common.png";
		    		addMarker(lat, lon, title, content, img);
		    	}
			}
			
			for(var i = 0 ; i < list2.length; i++)
			{
				var lat = Number(list2[i].LAT);
				var lon = Number(list2[i].LON);
				var id = list2[i].CAR_CD;
				var title = list2[i].CAR_NO;

				var content = "";
		        	content += "<table cellspacing='0' cellpadding='0'>";
		        	content += "<tr>";
					content += "<td class='ol-sub-title'>차량번호</td>";
		        	content += "<td class='ol-sub-content'>" + list2[i].CAR_NO + "</td>";
		        	content += "</tr>";
		        	content += "<tr>";
					content += "<td class='ol-sub-title'>기사명</td>";
		        	content += "<td class='ol-sub-content'>" + list2[i].DRIVER_NM + "</td>";
		        	content += "</tr>";
		        	content += "<tr>";
		       		content += "<td class='ol-sub-title'>핸드폰번호</td>";
		            content += "<td class='ol-sub-content'>" + list2[i].MOBILE_NO + "</td>";
		            content += "</tr>";
		            content += "<tr>";
		            content += "<td class='ol-sub-title'>수신위치</td>";
		            content += "<td class='ol-sub-content'>" + list2[i].LAST_LOCATE + "</td>";
		            content += "</tr>";
		            content += "<tr>";
		            content += "<td class='ol-sub-title'>수신일시</td>";
		            content += "<td class='ol-sub-content'>" + list2[i].LAST_DATE + "</td>";
		            content += "</tr>";
		        	content += "</table>";	
		    	
		    	if(i == rownum && seltype == "CAR")
		    	{
		    		sImg = "/map/img/locate_select.png";
		    		sLat = lat;
		    		sLon = lon;
		    		sTitle = title;
		    		sContent = content;
		    	}
		    	else
		    	{
		    		var img = "/map/img/locate_common.png";
		    		addMarker(lat, lon, title, content, img);
		    	}
			}
			
			addMarker(sLat, sLon, sTitle, sContent, sImg);
			view.setCenter(ol.proj.fromLonLat([sLon, sLat]));
		}
	    
	    function addMarker(lat, lon, title, content, img)
	    {
	    	var marker = new ol.Feature({
				geometry: new ol.geom.Point(ol.proj.fromLonLat([lon, lat])),
				title: title,
				content: content,
                division : "marker",
				rainfall: 500
			});			
	    	
	    	var image = new ol.style.Icon({
	    		anchor: [0.5, 1],
	    		opacity: 1,
	    		src: img
	    	});
	    	
	    	var text = new ol.style.Text({
                text: title,
                stroke: new ol.style.Stroke({ color:"#fff", width:2 }),
                fill: new ol.style.Fill({color:"#333"}),
                font: '13px sans-serif'				
	    	});
	    	
			marker.setStyle(new ol.style.Style({
				image: image,
				text : text
			}));

			featureSource.addFeature(marker);
	    }
	    
	    function getAreaCar(minLat, minLon, maxLat, maxLon)
	    {
	    	// 차량 조회시 일반 검색조건에 해당 파라미터를 추가하여 
	    	// 현재 보여지는 지도 영역 내에 존재하는 차량만 조회할 수 있다.  
	    	// minLat : 지도 영역 내 보여지는 left-top에 해당하는 위도
	    	// minLon : 지도 영역 내 보여지는 left-top에 해당하는 경도
	    	// maxLat : 지도 영역 내 보여지는 right-bottom에 해당하는 위도
	    	// maxLon : 지도 영역 내 보여지는 right-bottom에 해당하는 경도
	    }
    
	    function searchLocate()
	    {
	    	var seltype = "CAR"; //거래처 그리드 선택시 CLNT, 차량 그리드 선택시 CAR
	    	var list1 = [{"CLNT_CD":"BL0000000499","LON":"126.80296043","CLNT_NM":"김포공항","LAT":"37.57136985","CLNT_GB":"BL","ADDR":"서울 강서구 하늘길 38"},{"CLNT_CD":"BL0000000045","LON":"126.94082341","CLNT_NM":"신촌세브란스병원","LAT":"37.56140577","CLNT_GB":"BL","ADDR":"서울 서대문구 연세로 50-1"},{"CLNT_CD":"BL0000000046","LON":"127.04751976","CLNT_NM":"아주대학교병원","LAT":"37.27944699","CLNT_GB":"BL","ADDR":"경기도 수원시 영통구 월드컵로 164"},{"CLNT_CD":"BL0000000047","LON":"129.0064659","CLNT_NM":"양산부산대학교병원","LAT":"35.32878666","CLNT_GB":"BL","ADDR":"경상남도 양산시 물금읍 금오로 20"},{"CLNT_CD":"BL0000000048","LON":"127.00102359","CLNT_NM":"에이페이스","LAT":"37.58122433","CLNT_GB":"BL","ADDR":"서울시 종로구 대학로 103"},{"CLNT_CD":"BL0000000049","LON":"126.94082341","CLNT_NM":"연세대학교 세브란스","LAT":"37.56140577","CLNT_GB":"BL","ADDR":"서울시 서대문구 연세로 50-1"},{"CLNT_CD":"BL0000000050","LON":"127.1855331","CLNT_NM":"용마로지스 천안물류","LAT":"36.92909088","CLNT_GB":"BL","ADDR":"충청남도 천안시 서북구 입장면 용정리 240"},{"CLNT_CD":"BL0000000051","LON":"127.15557685","CLNT_NM":"용인정신병원","LAT":"37.25039644","CLNT_GB":"BL","ADDR":"경기도 용인시 기흥구 중부대로 940"},{"CLNT_CD":"BL0000000053","LON":"127.94672333","CLNT_NM":"원주세브란스기독병원","LAT":"37.34911763","CLNT_GB":"BL","ADDR":"강원도 원주시 일산로 20"},{"CLNT_CD":"BL0000000054","LON":"127.38198806","CLNT_NM":"을지대학교병원","LAT":"36.35530057","CLNT_GB":"BL","ADDR":"대전 서구 둔산서로 95"},{"CLNT_CD":"BL0000000055","LON":"126.88674394","CLNT_NM":"이대목동병원","LAT":"37.53698181","CLNT_GB":"BL","ADDR":"서울시 양천구 안양천로 1071"},{"CLNT_CD":"BL0000000057","LON":"127.16788909","CLNT_NM":"이수앱지스 용인공장","LAT":"37.25681946","CLNT_GB":"BL","ADDR":"용인시 기흥구 동백중앙로16번길 16-25"},{"CLNT_CD":"BL0000000058","LON":"126.98866999","CLNT_NM":"인제대학교 서울백병","LAT":"37.56482784","CLNT_GB":"BL","ADDR":"서울특별시 중구 마른내로 9"},{"CLNT_CD":"BL0000000060","LON":"127.10152286","CLNT_NM":"일양약품 용인공장","LAT":"37.2565204","CLNT_GB":"BL","ADDR":"용인시 기흥구 하갈로 110"},{"CLNT_CD":"BL0000000062","LON":"127.14110435","CLNT_NM":"전북대학교병원","LAT":"35.84788531","CLNT_GB":"BL","ADDR":"전주시 덕진구 건지로 20"},{"CLNT_CD":"BL0000000064","LON":"126.92818614","CLNT_NM":"조선대학교병원","LAT":"35.13854857","CLNT_GB":"BL","ADDR":"광주광역시 동구 필문대로 365"},{"CLNT_CD":"BL0000000065","LON":"127.17089513","CLNT_NM":"SG메디칼","LAT":"37.53466064","CLNT_GB":"BL","ADDR":"경기도 하남시 초이로 41"},{"CLNT_CD":"BL0000000066","LON":"126.65161645","CLNT_NM":"바이넥스","LAT":"37.3828457","CLNT_GB":"BL","ADDR":"인천시 연수구 송도동 7-48"},{"CLNT_CD":"BL0000000067","LON":"126.89442998","CLNT_NM":"바이오컴플릿","LAT":"37.48250153","CLNT_GB":"BL","ADDR":"서울시 구로구 디지털로 272"},{"CLNT_CD":"BL0000000069","LON":"126.95929432","CLNT_NM":"㈜셀리드","LAT":"37.46803804","CLNT_GB":"BL","ADDR":"서울시 관악구 관악로 1"},{"CLNT_CD":"BL0000000070","LON":"127.00102359","CLNT_NM":"셀비온","LAT":"37.58122433","CLNT_GB":"BL","ADDR":"서울시 종로구 대학로 103"},{"CLNT_CD":"BL0000000071","LON":"127.10543685","CLNT_NM":"제넥신","LAT":"37.40354815","CLNT_GB":"BL","ADDR":"경기도 성남시 분당구 대왕판교로 700"},{"CLNT_CD":"BL0000000073","LON":"127.11054604","CLNT_NM":"차온사무소","LAT":"37.40366095","CLNT_GB":"BL","ADDR":"경기도 성남시 분당구 판교로 331"},{"CLNT_CD":"BL0000000074","LON":"127.30700852","CLNT_NM":"켐온양지연구소","LAT":"37.22771845","CLNT_GB":"BL","ADDR":"경기도 용인시 처인구 양지면 남평로 240"},{"CLNT_CD":"BL0000000075","LON":"127.09224435","CLNT_NM":"프리즘씨디엑스","LAT":"37.21356195","CLNT_GB":"BL","ADDR":"경기도 화성시 동탄기흥로 593-16"},{"CLNT_CD":"BL0000000077","LON":"127.19466933","CLNT_NM":"한국로슈","LAT":"37.55352567","CLNT_GB":"BL","ADDR":"경기도 하남시 조정대로 150"},{"CLNT_CD":"BL0000000078","LON":"127.46531602","CLNT_NM":"한독","LAT":"36.97056729","CLNT_GB":"BL","ADDR":"충북 음성군 대소면 대풍리 37"},{"CLNT_CD":"BL0000000080","LON":"127.04411904","CLNT_NM":"차움의원","LAT":"37.5233112","CLNT_GB":"BL","ADDR":"서울 강남구 청담동 4-1"},{"CLNT_CD":"BL0000000081","LON":"126.76754373","CLNT_NM":"초당약품공업 안산공","LAT":"37.30685553","CLNT_GB":"BL","ADDR":"경기도 안산시 단원구 별망로 381"},{"CLNT_CD":"BL0000000082","LON":"127.41530384","CLNT_NM":"충남대학교병원","LAT":"36.3168436","CLNT_GB":"BL","ADDR":"대전광역시 중구 문화로 282"},{"CLNT_CD":"BL0000000084","LON":"126.90867389","CLNT_NM":"한림대학교강남성심병","LAT":"37.49324976","CLNT_GB":"BL","ADDR":"서울시 영등포구 신길로 1"},{"CLNT_CD":"BL0000000011","LON":"127.07205577","CLNT_NM":"건국대학교병원","LAT":"37.54123567","CLNT_GB":"BL","ADDR":"서울특별시 광진구 능동로 120-1"},{"CLNT_CD":"BL0000000012","LON":"127.34264674","CLNT_NM":"건양대학교병원","LAT":"36.30778178","CLNT_GB":"BL","ADDR":"대전광역시 서구 관저동로 158"},{"CLNT_CD":"BL0000000013","LON":"127.04344261","CLNT_NM":"경기바이오센터","LAT":"37.29433098","CLNT_GB":"BL","ADDR":"경기도 수원시 영통구 광교로 147"},{"CLNT_CD":"BL0000000014","LON":"128.6043125","CLNT_NM":"경북대학교병원","LAT":"35.86623526","CLNT_GB":"BL","ADDR":"대구광역시 중구 동덕로 130"},{"CLNT_CD":"BL0000000017","LON":"127.02635726","CLNT_NM":"고려대학교의료원안암","LAT":"37.58711096","CLNT_GB":"BL","ADDR":"서울 성북구 고려대로 73"},{"CLNT_CD":"BL0000000015","LON":"126.88463761","CLNT_NM":"고려대학교구로병원","LAT":"37.4911796","CLNT_GB":"BL","ADDR":"서울특별시 구로구 구로동로 148"},{"CLNT_CD":"BL0000000016","LON":"126.82499943","CLNT_NM":"고려대학교안산병원","LAT":"37.31885846","CLNT_GB":"BL","ADDR":"경기도 안산시 단원구 적금로 123"},{"CLNT_CD":"BL0000000018","LON":"129.01451285","CLNT_NM":"고신대학교복음병원","LAT":"35.08107805","CLNT_GB":"BL","ADDR":"부산광역시 서구 감천로 262"},{"CLNT_CD":"BL0000000019","LON":"126.78339766","CLNT_NM":"국립암센터","LAT":"37.66322721","CLNT_GB":"BL","ADDR":"경기도 고양시 일산동구 일산로 323"},{"CLNT_CD":"BL0000000020","LON":"127.08577669","CLNT_NM":"국립정신건강센터","LAT":"37.56508626","CLNT_GB":"BL","ADDR":"서울특별시 광진구 용마산로 127"},{"CLNT_CD":"BL0000000023","LON":"127.06959169","CLNT_NM":"노원을지병원","LAT":"37.63655988","CLNT_GB":"BL","ADDR":"서울특별시 노원구 한글비석로 68"},{"CLNT_CD":"BL0000000024","LON":"126.88463493","CLNT_NM":"녹십자셀","LAT":"37.47949308","CLNT_GB":"BL","ADDR":"서울시 금천구 벚꽃로 278"},{"CLNT_CD":"BL0000000025","LON":"128.80742205","CLNT_NM":"대구가톨릭대학교병원","LAT":"35.90896708","CLNT_GB":"BL","ADDR":"경상북도 경산시 하양읍 하양로 13-13"},{"CLNT_CD":"BL0000000026","LON":"126.80556454","CLNT_NM":"동국대학교일산병원","LAT":"37.67643538","CLNT_GB":"BL","ADDR":"경기도 고양시 일산동구 동국로 27"},{"CLNT_CD":"BL0000000028","LON":"126.89267842","CLNT_NM":"록원바이오","LAT":"37.4808125","CLNT_GB":"BL","ADDR":"서울시 구로구 디지털로 242"},{"CLNT_CD":"BL0000000030","LON":"126.9241826","CLNT_NM":"보라매병원","LAT":"37.49199881","CLNT_GB":"BL","ADDR":"서울특별시 동작구 신대방동 보라매로 5길 20"},{"CLNT_CD":"BL0000000031","LON":"129.01922237","CLNT_NM":"부산대학교병원","LAT":"35.10105496","CLNT_GB":"BL","ADDR":"부산 서구 구덕로 179"},{"CLNT_CD":"BL0000000032","LON":"127.124485","CLNT_NM":"분당서울대학교병원","LAT":"37.3520254","CLNT_GB":"BL","ADDR":"경기 성남시 분당구 구미로173번길 82"},{"CLNT_CD":"BL0000000034","LON":"127.04017054","CLNT_NM":"삼광의료재단","LAT":"37.48292364","CLNT_GB":"BL","ADDR":"서울특별시 서초구 양재동 9-60"},{"CLNT_CD":"BL0000000035","LON":"127.08959014","CLNT_NM":"삼성서울병원","LAT":"37.49034449","CLNT_GB":"BL","ADDR":"서울시 강남구 일원로 81"},{"CLNT_CD":"BL0000000036","LON":"128.5919658","CLNT_NM":"삼성창원병원","LAT":"35.24299639","CLNT_GB":"BL","ADDR":"경남 창원시 마산회원구 팔용로 158"},{"CLNT_CD":"BL0000000037","LON":"127.41167311","CLNT_NM":"삼양바이오팜","LAT":"36.4402539","CLNT_GB":"BL","ADDR":"대전 대덕구 신일동로79"},{"CLNT_CD":"BL0000000039","LON":"127.10952406","CLNT_NM":"서울아산병원","LAT":"37.52515749","CLNT_GB":"BL","ADDR":"서울 송파구 올림픽로43길 88"},{"CLNT_CD":"BL0000000040","LON":"128.19615857","CLNT_NM":"세명대학교부속한방병","LAT":"37.17384234","CLNT_GB":"BL","ADDR":"충청북도 제천시 세명로 65"},{"CLNT_CD":"BL0000000041","LON":"127.43846333","CLNT_NM":"셀트리온제약진천공장","LAT":"36.88154471","CLNT_GB":"BL","ADDR":"충청북도 진천군 이월면 반지길 47-17"},{"CLNT_CD":"BL0000000087","LON":"129.18216393","CLNT_NM":"해운대백병원","LAT":"35.17325949","CLNT_GB":"BL","ADDR":"부산광역시 해운대구 해운대로 875"},{"CLNT_CD":"BL0000000088","LON":"127.00322007","CLNT_NM":"화순전남대학교병원","LAT":"35.06117807","CLNT_GB":"BL","ADDR":"전라남도 화순군 화순읍 서양로 322"},{"CLNT_CD":"BL0000000001","LON":"127.50629562","CLNT_NM":"한국건강관리협회중앙","LAT":"36.59558457","CLNT_GB":"BL","ADDR":"경기도 성남시 분당구 돌마로 172"},{"CLNT_CD":"BL0000000005","LON":"127.42021167","CLNT_NM":"가톨릭대학교대전성모","LAT":"36.32199284","CLNT_GB":"BL","ADDR":"대전 중구 대흥로 64"},{"CLNT_CD":"BL0000000007","LON":"127.02744984","CLNT_NM":"가톨릭대학교성빈센트","LAT":"37.27792354","CLNT_GB":"BL","ADDR":"경기도 수원시 팔달구 중부대로 93"},{"CLNT_CD":"BL0000000008","LON":"126.72520707","CLNT_NM":"가톨릭대학교인천성모","LAT":"37.48413218","CLNT_GB":"BL","ADDR":"인천광역시 부평구 동수로 56"},{"CLNT_CD":"BL0000000009","LON":"127.15696398","CLNT_NM":"강동경희대학교병원","LAT":"37.55317032","CLNT_GB":"BL","ADDR":"서울 강동구 동남로 892"},{"CLNT_CD":"BL0000000010","LON":"126.96781265","CLNT_NM":"강북삼성병원","LAT":"37.56886777","CLNT_GB":"BL","ADDR":"서울시 종로구 새문안로 29"},{"CLNT_CD":"BL0000000453","LON":"127.1009305","CLNT_NM":"녹십자종합연구소","LAT":"37.31600798","CLNT_GB":"BL","ADDR":"경기 용인시 기흥구 이현로30번길 93"},{"CLNT_CD":"BL0000000455","LON":"126.83095076","CLNT_NM":"명지병원","LAT":"37.64219952","CLNT_GB":"BL","ADDR":"경기 고양시 덕양구 화수로14번길 55"},{"CLNT_CD":"BL0000000456","LON":"127.124485","CLNT_NM":"분당서울대병원","LAT":"37.3520254","CLNT_GB":"BL","ADDR":"경기 성남시 분당구 구미로173번길 82"},{"CLNT_CD":"BL0000000457","LON":"127.02744984","CLNT_NM":"성빈센트병원","LAT":"37.27792354","CLNT_GB":"BL","ADDR":"경기도 수원시 팔달구 중부대로 93"},{"CLNT_CD":"BL0000000458","LON":"127.05869118","CLNT_NM":"수원전기부속의원","LAT":"37.26523377","CLNT_GB":"BL","ADDR":"경기도 수원시 영통구 매영로 150"},{"CLNT_CD":"BL0000000459","LON":"127.10543685","CLNT_NM":"제넥신","LAT":"37.40354815","CLNT_GB":"BL","ADDR":"경기도 성남시 분당구 대왕판교로 700"},{"CLNT_CD":"BL0000000460","LON":"126.76754373","CLNT_NM":"초당약품공업","LAT":"37.30685553","CLNT_GB":"BL","ADDR":"경기도 안산시 단원구 별망로 381"},{"CLNT_CD":"BL0000000461","LON":"127.09224435","CLNT_NM":"프리즘씨디엑스","LAT":"37.21356195","CLNT_GB":"BL","ADDR":"경기도 화성시 동탄기흥로 593-16"},{"CLNT_CD":"BL0000000462","LON":"127.19466933","CLNT_NM":"한국로슈","LAT":"37.55352567","CLNT_GB":"BL","ADDR":"경기도 하남시 조정대로 150"},{"CLNT_CD":"BL0000000463","LON":"126.95667271","CLNT_NM":"한국유로핀즈","LAT":"37.35288601","CLNT_GB":"BL","ADDR":"경기 군포시 산본로101번길 13"},{"CLNT_CD":"BL0000000464","LON":"127.37953305","CLNT_NM":"대전대둔산한방병원","LAT":"36.34629399","CLNT_GB":"BL","ADDR":"대전 서구 대덕대로176번길 75"},{"CLNT_CD":"BL0000000465","LON":"127.42021167","CLNT_NM":"대전성모병원","LAT":"36.32199284","CLNT_GB":"BL","ADDR":"대전 중구 대흥로 64"},{"CLNT_CD":"BL0000000466","LON":"127.35698192","CLNT_NM":"카이스트","LAT":"36.36828278","CLNT_GB":"BL","ADDR":"대전 유성구 대학로 291"},{"CLNT_CD":"BL0000000467","LON":"129.01451285","CLNT_NM":"고신대복음병원","LAT":"35.08107805","CLNT_GB":"BL","ADDR":"부산광역시 서구 감천로 262"},{"CLNT_CD":"BL0000000468","LON":"129.02011486","CLNT_NM":"부산백병원","LAT":"35.14608231","CLNT_GB":"BL","ADDR":"부산 부산진구 개금동 633-163"},{"CLNT_CD":"BL0000000470","LON":"127.04631041","CLNT_NM":"강남세브란스병원","LAT":"37.49280603","CLNT_GB":"BL","ADDR":"서울 강남구 언주로 211"},{"CLNT_CD":"BL0000000471","LON":"127.15696398","CLNT_NM":"강동경희대병원","LAT":"37.55317032","CLNT_GB":"BL","ADDR":"서울 강동구 동남로 892"},{"CLNT_CD":"BL0000000473","LON":"126.88463761","CLNT_NM":"고대구로병원","LAT":"37.4911796","CLNT_GB":"BL","ADDR":"서울특별시 구로구 구로동로 148"},{"CLNT_CD":"BL0000000475","LON":"126.88463493","CLNT_NM":"녹십자셀(금천구)","LAT":"37.47949308","CLNT_GB":"BL","ADDR":"서울특별시 금천구 벚꽃로 278 SJ 테크노빌"},{"CLNT_CD":"BL0000000477","LON":"126.89442998","CLNT_NM":"바이오컴플릿","LAT":"37.48250153","CLNT_GB":"BL","ADDR":"서울시 구로구 디지털로 272"},{"CLNT_CD":"BL0000000478","LON":"126.95929432","CLNT_NM":"서울대학교","LAT":"37.46803804","CLNT_GB":"BL","ADDR":"서울특별시 관악구 관악로 1"},{"CLNT_CD":"BL0000000480","LON":"126.90634252","CLNT_NM":"서울재활병원","LAT":"37.60564691","CLNT_GB":"BL","ADDR":"서울 은평구 갈현로11길 30"},{"CLNT_CD":"BL0000000482","LON":"127.13119701","CLNT_NM":"신원약품","LAT":"37.50592068","CLNT_GB":"BL","ADDR":"서울특별시 송파구 마천로 104"},{"CLNT_CD":"BL0000000484","LON":"126.88674394","CLNT_NM":"이대목동병원","LAT":"37.53698181","CLNT_GB":"BL","ADDR":"서울시 양천구 안양천로 1071"},{"CLNT_CD":"BL0000000485","LON":"126.96042177","CLNT_NM":"중앙대학교병원","LAT":"37.506038","CLNT_GB":"BL","ADDR":"서울 동작구 흑석로 102"},{"CLNT_CD":"BL0000000491","LON":"127.00322007","CLNT_NM":"화순전남대병원","LAT":"35.06117807","CLNT_GB":"BL","ADDR":"전라남도 화순군 화순읍 서양로 322"},{"CLNT_CD":"BL0000000493","LON":"127.17327603","CLNT_NM":"단국대학교병원","LAT":"36.84295049","CLNT_GB":"BL","ADDR":"충남 천안시 동남구 망향로 201"},{"CLNT_CD":"BL0000000494","LON":"127.44236318","CLNT_NM":"녹십자오창공장","LAT":"36.72173677","CLNT_GB":"BL","ADDR":"충북 청주시 청원구 오창읍 과학산업2로 586"},{"CLNT_CD":"BL0000000496","LON":"127.3354981","CLNT_NM":"질병관리본부","LAT":"36.64260138","CLNT_GB":"BL","ADDR":"충북 청주시 흥덕구 오송읍 오송생명2로 187"},{"CLNT_CD":"BL0000000498","LON":"127.46531602","CLNT_NM":"한독","LAT":"36.97056729","CLNT_GB":"BL","ADDR":"충북 음성군 대소면 대풍리 37"},{"CLNT_CD":"CL0000000002","LON":"127.94672333","CLNT_NM":"원주세브란스병원","LAT":"37.34911763","CLNT_GB":"CL","ADDR":"강원도 원주시 일산로 20"},{"CLNT_CD":"CL0000000004","LON":"126.78339766","CLNT_NM":"국립암센터","LAT":"37.66322721","CLNT_GB":"CL","ADDR":"경기도 고양시 일산동구 일산로 323"},{"CLNT_CD":"CL0000000005","LON":"126.79304011","CLNT_NM":"국민건강보험공단일산","LAT":"37.64547542","CLNT_GB":"CL","ADDR":"경기도 고양시 일산동구 일산로 100"},{"CLNT_CD":"CL0000000007","LON":"127.1009305","CLNT_NM":"녹십자종합연구소","LAT":"37.31600798","CLNT_GB":"CL","ADDR":"경기 용인시 기흥구 이현로30번길 93"},{"CLNT_CD":"CL0000000009","LON":"126.83095076","CLNT_NM":"명지병원","LAT":"37.64219952","CLNT_GB":"CL","ADDR":"경기 고양시 덕양구 화수로14번길 55"},{"CLNT_CD":"CL0000000010","LON":"127.124485","CLNT_NM":"분당서울대병원","LAT":"37.3520254","CLNT_GB":"CL","ADDR":"경기 성남시 분당구 구미로173번길 82"},{"CLNT_CD":"CL0000000012","LON":"127.02744984","CLNT_NM":"성빈센트병원","LAT":"37.27792354","CLNT_GB":"CL","ADDR":"경기도 수원시 팔달구 중부대로 93"},{"CLNT_CD":"CL0000000014","LON":"127.04751976","CLNT_NM":"아주대학교병원","LAT":"37.27944699","CLNT_GB":"CL","ADDR":"경기도 수원시 영통구 월드컵로 164"},{"CLNT_CD":"CL0000000015","LON":"127.10543685","CLNT_NM":"제넥신","LAT":"37.40354815","CLNT_GB":"CL","ADDR":"경기도 성남시 분당구 대왕판교로 700"},{"CLNT_CD":"CL0000000017","LON":"127.09224435","CLNT_NM":"프리즘씨디엑스","LAT":"37.21356195","CLNT_GB":"CL","ADDR":"경기도 화성시 동탄기흥로 593-16"},{"CLNT_CD":"CL0000000019","LON":"126.95667271","CLNT_NM":"한국유로핀즈","LAT":"37.35288601","CLNT_GB":"CL","ADDR":"경기 군포시 산본로101번길 13"},{"CLNT_CD":"CL0000000020","LON":"129.0064659","CLNT_NM":"양산부산대학교병원","LAT":"35.32878666","CLNT_GB":"CL","ADDR":"경상남도 양산시 물금읍 금오로 20"},{"CLNT_CD":"CL0000000022","LON":"128.6043125","CLNT_NM":"경북대학교병원","LAT":"35.86623526","CLNT_GB":"CL","ADDR":"대구광역시 중구 동덕로 130"},{"CLNT_CD":"CL0000000024","LON":"127.42021167","CLNT_NM":"대전성모병원","LAT":"36.32199284","CLNT_GB":"CL","ADDR":"대전 중구 대흥로 64"},{"CLNT_CD":"CL0000000025","LON":"127.38198806","CLNT_NM":"을지대학교병원","LAT":"36.35530057","CLNT_GB":"CL","ADDR":"대전 서구 둔산서로 95"},{"CLNT_CD":"CL0000000028","LON":"129.01802419","CLNT_NM":"동아대학교병원","LAT":"35.1195459","CLNT_GB":"CL","ADDR":"부산광역시 서구 대신공원로 26"},{"CLNT_CD":"CL0000000029","LON":"129.02011486","CLNT_NM":"부산백병원","LAT":"35.14608231","CLNT_GB":"CL","ADDR":"부산 부산진구 개금동 633-163"},{"CLNT_CD":"CL0000000031","LON":"127.04631041","CLNT_NM":"강남세브란스병원","LAT":"37.49280603","CLNT_GB":"CL","ADDR":"서울 강남구 언주로 211"},{"CLNT_CD":"CL0000000032","LON":"127.15696398","CLNT_NM":"강동경희대병원","LAT":"37.55317032","CLNT_GB":"CL","ADDR":"서울 강동구 동남로 892"},{"CLNT_CD":"CL0000000033","LON":"126.96781265","CLNT_NM":"강북삼성병원","LAT":"37.56886777","CLNT_GB":"CL","ADDR":"서울시 종로구 새문안로 29"},{"CLNT_CD":"CL0000000034","LON":"127.05489092","CLNT_NM":"경희대학교병원","LAT":"37.59394918","CLNT_GB":"CL","ADDR":"서울 동대문구 경희대로 26"},{"CLNT_CD":"CL0000000035","LON":"126.88463761","CLNT_NM":"고대구로병원","LAT":"37.4911796","CLNT_GB":"CL","ADDR":"서울특별시 구로구 구로동로 148"},{"CLNT_CD":"CL0000000036","LON":"127.02635726","CLNT_NM":"고대안암병원","LAT":"37.58711096","CLNT_GB":"CL","ADDR":"서울 성북구 고려대로 73"},{"CLNT_CD":"CL0000000038","LON":"127.11844131","CLNT_NM":"대한정도관리협회","LAT":"37.48476558","CLNT_GB":"CL","ADDR":"서울 송파구 법원로11길 11"},{"CLNT_CD":"CL0000000039","LON":"126.89267842","CLNT_NM":"록원바이오","LAT":"37.4808125","CLNT_GB":"CL","ADDR":"서울시 구로구 디지털로 242"},{"CLNT_CD":"CL0000000041","LON":"126.9241826","CLNT_NM":"보라매병원","LAT":"37.49199881","CLNT_GB":"CL","ADDR":"서울특별시 동작구 신대방동 보라매로 5길 20"},{"CLNT_CD":"CL0000000043","LON":"126.95929432","CLNT_NM":"서울대학교","LAT":"37.46803804","CLNT_GB":"CL","ADDR":"서울특별시 관악구 관악로 1"},{"CLNT_CD":"CL0000000045","LON":"127.00586059","CLNT_NM":"서울성모병원","LAT":"37.50239358","CLNT_GB":"CL","ADDR":"서울 서초구 반포대로 222"},{"CLNT_CD":"CL0000000048","LON":"127.00102359","CLNT_NM":"셀비온","LAT":"37.58122433","CLNT_GB":"CL","ADDR":"서울시 종로구 대학로 103"},{"CLNT_CD":"CL0000000050","LON":"126.94082341","CLNT_NM":"신촌세브란스병원","LAT":"37.56140577","CLNT_GB":"CL","ADDR":"서울시 서대문구 연세로 50-1"},{"CLNT_CD":"CL0000000051","LON":"127.00102359","CLNT_NM":"에이페이스","LAT":"37.58122433","CLNT_GB":"CL","ADDR":"서울시 종로구 대학로 103"},{"CLNT_CD":"CL0000000054","LON":"126.96042177","CLNT_NM":"중앙대학교병원","LAT":"37.506038","CLNT_GB":"CL","ADDR":"서울 동작구 흑석로 102"},{"CLNT_CD":"CL0000000055","LON":"126.85080855","CLNT_NM":"한국건강관리협회 서","LAT":"37.55388666","CLNT_GB":"CL","ADDR":"서울 강서구 화곡로 335"},{"CLNT_CD":"CL0000000058","LON":"126.63416427","CLNT_NM":"인하대학교병원","LAT":"37.458854","CLNT_GB":"CL","ADDR":"인천 중구 인항로 27"},{"CLNT_CD":"CL0000000061","LON":"127.00322007","CLNT_NM":"화순전남대병원","LAT":"35.06117807","CLNT_GB":"CL","ADDR":"전라남도 화순군 화순읍 서양로 322"},{"CLNT_CD":"CL0000000063","LON":"127.13678154","CLNT_NM":"순천향천안병원","LAT":"36.8028116","CLNT_GB":"CL","ADDR":"충남 천안시 동남구 순천향6길 31"},{"CLNT_CD":"CL0000000065","LON":"127.1855331","CLNT_NM":"용마로지스 천안물류","LAT":"36.92909088","CLNT_GB":"CL","ADDR":"충청남도 천안시 서북구 입장면 용정리 240"},{"CLNT_CD":"CL0000000066","LON":"127.44236318","CLNT_NM":"녹십자오창공장","LAT":"36.72173677","CLNT_GB":"CL","ADDR":"충북 청주시 청원구 오창읍 과학산업2로 586"},{"CLNT_CD":"CL0000000068","LON":"127.3354981","CLNT_NM":"질병관리본부","LAT":"36.64260138","CLNT_GB":"CL","ADDR":"충북 청주시 흥덕구 오송읍 오송생명2로 187"},{"CLNT_CD":"CL0000000069","LON":"127.50629562","CLNT_NM":"한국건강관리협회중앙","LAT":"36.59558457","CLNT_GB":"CL","ADDR":"충북 청주시 상당구 단재로 393"},{"CLNT_CD":"BL0000000044","LON":"127.13678154","CLNT_NM":"순천향대학교천안병원","LAT":"36.8028116","CLNT_GB":"BL","ADDR":"\r\r\n충남 천안시 동남구 순천향6길 31\r\r\n"},{"CLNT_CD":"BL0000000006","LON":"127.00586059","CLNT_NM":"가톨릭대학교서울성모","LAT":"37.50239358","CLNT_GB":"BL","ADDR":"서울 서초구 반포대로 222"},{"CLNT_CD":"BL0000000027","LON":"129.01802419","CLNT_NM":"동아대학교병원","LAT":"35.1195459","CLNT_GB":"BL","ADDR":"부산광역시 서구 대신공원로 26"},{"CLNT_CD":"BL0000000033","LON":"127.12597857","CLNT_NM":"분당차병원","LAT":"37.40950295","CLNT_GB":"BL","ADDR":"경기 성남시 분당구 야탑로 64"},{"CLNT_CD":"BL0000000038","LON":"126.99719639","CLNT_NM":"서울대학교병원","LAT":"37.58045234","CLNT_GB":"BL","ADDR":"서울시 종로구 대학로 101"},{"CLNT_CD":"BL0000000043","LON":"127.00387804","CLNT_NM":"순천향대학교서울병원","LAT":"37.53428081","CLNT_GB":"BL","ADDR":"서울시 용산구 대사관로 59"},{"CLNT_CD":"BL0000000056","LON":"126.63547487","CLNT_NM":"이디지씨헬스케어","LAT":"37.37265875","CLNT_GB":"BL","ADDR":"인천광역시 연수구 하모니로 291"},{"CLNT_CD":"BL0000000063","LON":"126.545201","CLNT_NM":"제주대학교병원","LAT":"33.46720852","CLNT_GB":"BL","ADDR":"제주 제주시 아란13길 15"},{"CLNT_CD":"BL0000000079","LON":"128.0960271","CLNT_NM":"진주경상대학교병원","LAT":"35.17538991","CLNT_GB":"BL","ADDR":"경상남도 진주시 강남로 79"},{"CLNT_CD":"BL0000000085","LON":"126.96197217","CLNT_NM":"한림대학교성심병원","LAT":"37.39165123","CLNT_GB":"BL","ADDR":"경기도 안양시 동안구 관평로170번길 22"},{"CLNT_CD":"BL0000000086","LON":"127.74080906","CLNT_NM":"한림대학교춘천성심병","LAT":"37.88413436","CLNT_GB":"BL","ADDR":"강원도 춘천시 삭주로 77"},{"CLNT_CD":"BL0000000451","LON":"127.74080906","CLNT_NM":"한림대춘천성심병원","LAT":"37.88413436","CLNT_GB":"BL","ADDR":"강원도 춘천시 삭주로 77"},{"CLNT_CD":"BL0000000454","LON":"126.80556454","CLNT_NM":"동국대일산병원","LAT":"37.67643538","CLNT_GB":"BL","ADDR":"경기도 고양시 일산동구 동국로 27"},{"CLNT_CD":"BL0000000469","LON":"126.92924114","CLNT_NM":"LG화학","LAT":"37.52792713","CLNT_GB":"BL","ADDR":"서울 영등포구 여의대로 128"},{"CLNT_CD":"BL0000000472","LON":"127.05489092","CLNT_NM":"경희대학교병원","LAT":"37.59394918","CLNT_GB":"BL","ADDR":"서울 동대문구 경희대로 26"},{"CLNT_CD":"BL0000000474","LON":"127.02635726","CLNT_NM":"고대안암병원","LAT":"37.58711096","CLNT_GB":"BL","ADDR":"서울 성북구 고려대로 73"},{"CLNT_CD":"BL0000000476","LON":"127.11844131","CLNT_NM":"대한정도관리협회","LAT":"37.48476558","CLNT_GB":"BL","ADDR":"서울 송파구 법원로11길 11"},{"CLNT_CD":"BL0000000479","LON":"127.00586059","CLNT_NM":"서울성모병원","LAT":"37.50239358","CLNT_GB":"BL","ADDR":"서울 서초구 반포대로 222"},{"CLNT_CD":"BL0000000481","LON":"127.00102359","CLNT_NM":"셀비온","LAT":"37.58122433","CLNT_GB":"BL","ADDR":"서울시 종로구 대학로 103"},{"CLNT_CD":"BL0000000483","LON":"126.91654914","CLNT_NM":"은평성모병원","LAT":"37.63323732","CLNT_GB":"BL","ADDR":"서울 은평구 진관동 93-6"},{"CLNT_CD":"BL0000000486","LON":"126.85080855","CLNT_NM":"한국건강관리협회서부","LAT":"37.55388666","CLNT_GB":"BL","ADDR":"서울 강서구 화곡로 335"},{"CLNT_CD":"BL0000000489","LON":"126.63416427","CLNT_NM":"인하대학교병원","LAT":"37.458854","CLNT_GB":"BL","ADDR":"인천 중구 인항로 27"},{"CLNT_CD":"BL0000000492","LON":"127.13678154","CLNT_NM":"순천향천안병원","LAT":"36.8028116","CLNT_GB":"BL","ADDR":"충남 천안시 동남구 순천향6길 31"},{"CLNT_CD":"BL0000000495","LON":"127.3354981","CLNT_NM":"식품의약품안전처","LAT":"36.64260138","CLNT_GB":"BL","ADDR":"충북 청주시 흥덕구 오송읍 오송생명2로 187"},{"CLNT_CD":"BL0000000497","LON":"127.50629562","CLNT_NM":"한국건강관리협회중앙","LAT":"36.59558457","CLNT_GB":"BL","ADDR":"충북 청주시 상당구 단재로 393"},{"CLNT_CD":"CL0000000003","LON":"127.74080906","CLNT_NM":"한림대춘천성심병원","LAT":"37.88413436","CLNT_GB":"CL","ADDR":"강원도 춘천시 삭주로 77"},{"CLNT_CD":"CL0000000008","LON":"126.80556454","CLNT_NM":"동국대일산병원","LAT":"37.67643538","CLNT_GB":"CL","ADDR":"경기도 고양시 일산동구 동국로 27"},{"CLNT_CD":"CL0000000011","LON":"127.12597857","CLNT_NM":"분당차병원","LAT":"37.40950295","CLNT_GB":"CL","ADDR":"경기 성남시 분당구 야탑로 64"},{"CLNT_CD":"CL0000000013","LON":"127.05869118","CLNT_NM":"수원전기부속의원","LAT":"37.26523377","CLNT_GB":"CL","ADDR":"경기도 수원시 영통구 매영로 150"},{"CLNT_CD":"CL0000000016","LON":"126.76754373","CLNT_NM":"초당약품공업","LAT":"37.30685553","CLNT_GB":"CL","ADDR":"경기도 안산시 단원구 별망로 381"},{"CLNT_CD":"CL0000000018","LON":"127.19466933","CLNT_NM":"한국로슈","LAT":"37.55352567","CLNT_GB":"CL","ADDR":"경기도 하남시 조정대로 150"},{"CLNT_CD":"CL0000000021","LON":"126.92818614","CLNT_NM":"조선대학교병원","LAT":"35.13854857","CLNT_GB":"CL","ADDR":"광주광역시 동구 필문대로 365"},{"CLNT_CD":"CL0000000023","LON":"127.37953305","CLNT_NM":"대전대둔산한방병원","LAT":"36.34629399","CLNT_GB":"CL","ADDR":"대전 서구 대덕대로176번길 75"},{"CLNT_CD":"CL0000000026","LON":"127.35698192","CLNT_NM":"카이스트","LAT":"36.36828278","CLNT_GB":"CL","ADDR":"대전 유성구 대학로 291"},{"CLNT_CD":"CL0000000027","LON":"129.01451285","CLNT_NM":"고신대복음병원","LAT":"35.08107805","CLNT_GB":"CL","ADDR":"부산광역시 서구 감천로 262"},{"CLNT_CD":"CL0000000030","LON":"126.92924114","CLNT_NM":"LG화학","LAT":"37.52792713","CLNT_GB":"CL","ADDR":"서울 영등포구 여의대로 128"},{"CLNT_CD":"CL0000000037","LON":"126.88463493","CLNT_NM":"녹십자셀(금천구)","LAT":"37.47949308","CLNT_GB":"CL","ADDR":"서울특별시 금천구 벚꽃로 278 SJ 테크노빌"},{"CLNT_CD":"CL0000000040","LON":"126.89442998","CLNT_NM":"바이오컴플릿","LAT":"37.48250153","CLNT_GB":"CL","ADDR":"서울시 구로구 디지털로 272"},{"CLNT_CD":"CL0000000042","LON":"127.08959014","CLNT_NM":"삼성서울병원","LAT":"37.49034449","CLNT_GB":"CL","ADDR":"서울시 강남구 일원로 81"},{"CLNT_CD":"CL0000000044","LON":"126.99719639","CLNT_NM":"서울대학교병원","LAT":"37.58045234","CLNT_GB":"CL","ADDR":"서울시 종로구 대학로 101"},{"CLNT_CD":"CL0000000047","LON":"126.90634252","CLNT_NM":"서울재활병원","LAT":"37.60564691","CLNT_GB":"CL","ADDR":"서울 은평구 갈현로11길 30"},{"CLNT_CD":"CL0000000049","LON":"127.13119701","CLNT_NM":"신원약품","LAT":"37.50592068","CLNT_GB":"CL","ADDR":"서울특별시 송파구 마천로 104"},{"CLNT_CD":"CL0000000052","LON":"126.91654914","CLNT_NM":"은평성모병원","LAT":"37.63323732","CLNT_GB":"CL","ADDR":"서울 은평구 진관동 93-6"},{"CLNT_CD":"CL0000000053","LON":"126.88674394","CLNT_NM":"이대목동병원","LAT":"37.53698181","CLNT_GB":"CL","ADDR":"서울시 양천구 안양천로 1071"},{"CLNT_CD":"CL0000000056","LON":"127.04562825","CLNT_NM":"한양대병원","LAT":"37.55863651","CLNT_GB":"CL","ADDR":"서울 성동구 왕십리로 222-1"},{"CLNT_CD":"CL0000000060","LON":"126.96407445","CLNT_NM":"녹십자화순공장","LAT":"35.03616177","CLNT_GB":"CL","ADDR":"전남 화순군 화순읍 산단길 40"},{"CLNT_CD":"CL0000000062","LON":"126.545201","CLNT_NM":"제주대학교병원","LAT":"33.46720852","CLNT_GB":"CL","ADDR":"제주 제주시 아란13길 15"},{"CLNT_CD":"CL0000000064","LON":"127.17327603","CLNT_NM":"단국대학교병원","LAT":"36.84295049","CLNT_GB":"CL","ADDR":"충남 천안시 동남구 망향로 201"},{"CLNT_CD":"CL0000000067","LON":"127.3354981","CLNT_NM":"식품의약품안전처","LAT":"36.64260138","CLNT_GB":"CL","ADDR":"충북 청주시 흥덕구 오송읍 오송생명2로 187"},{"CLNT_CD":"CL0000000070","LON":"127.46531602","CLNT_NM":"한독","LAT":"36.97056729","CLNT_GB":"CL","ADDR":"충북 음성군 대소면 대풍리 37"},{"CLNT_CD":"159040","LON":"127.03725248","CLNT_NM":"일동제약 (주)","LAT":"37.47762304","CLNT_GB":"CL","ADDR":"서울 서초구 바우뫼로27길 2"},{"CLNT_CD":"159298","LON":"127.44709987","CLNT_NM":"(주) 셀트리온제약","LAT":"36.72806317","CLNT_GB":"CL","ADDR":"충북 청주시 청원구 오창읍 2산단로 82"},{"CLNT_CD":"159808","LON":"127.10502496","CLNT_NM":"한국전력공사","LAT":"37.26922349","CLNT_GB":"CL","ADDR":"경기 용인시 기흥구 상갈동 173-1"},{"CLNT_CD":"159795","LON":"128.76995996","CLNT_NM":"테스트거래처","LAT":"35.09465068","CLNT_GB":"CL","ADDR":"경남 창원시 진해구 신항7로 128"},{"CLNT_CD":"159800","LON":"127.1020183","CLNT_NM":"3312312","LAT":"37.31503688","CLNT_GB":"CL","ADDR":"경기 용인시 기흥구 이현로30번길 84"},{"CLNT_CD":"159805","LON":"127.05235352","CLNT_NM":"씨엔알리서치","LAT":"37.50070112","CLNT_GB":"CL","ADDR":"서울 강남구 역삼로 412"},{"CLNT_CD":"159814","LON":"127.1004266","CLNT_NM":"한국네트웍스","LAT":"37.31777154","CLNT_GB":"CL","ADDR":"경기 용인시 기흥구 이현로30번길 107"},{"CLNT_CD":"159802","LON":"127.01165321","CLNT_NM":"대한결핵및호흡기학회","LAT":"37.48595985","CLNT_GB":"CL","ADDR":"서울 서초구 반포대로 58"},{"CLNT_CD":"159803","LON":"127.04661125","CLNT_NM":"한양대학교 산학협력","LAT":"37.55450356","CLNT_GB":"CL","ADDR":"서울 성동구 왕십리로 222"},{"CLNT_CD":"159747","LON":"126.83702088","CLNT_NM":"(주)라파스","LAT":"37.56637489","CLNT_GB":"CL","ADDR":"서울 강서구 마곡중앙8로1길 62"},{"CLNT_CD":"159813","LON":"126.61227422","CLNT_NM":"예원가구","LAT":"37.50912423","CLNT_GB":"CL","ADDR":"인천 서구 로봇랜드로 33"},{"CLNT_CD":"159794","LON":"127.45254894","CLNT_NM":"일이삼","LAT":"36.31841367","CLNT_GB":"CL","ADDR":"대전 동구 판암동 497-7"},{"CLNT_CD":"159796","LON":"127.04417615","CLNT_NM":"녹십자 의료재단","LAT":"37.51075073","CLNT_GB":"CL","ADDR":"서울 강남구 봉은사로 403"},{"CLNT_CD":"159797","LON":"127.1004266","CLNT_NM":"진매트릭스","LAT":"37.31777154","CLNT_GB":"CL","ADDR":"경기 용인시 기흥구 이현로30번길 107"},{"CLNT_CD":"159600","LON":"126.91319808","CLNT_NM":"경동제약(주)","LAT":"37.08903512","CLNT_GB":"CL","ADDR":"경기 화성시 향남읍 발안공단로2길 15"},{"CLNT_CD":"159740","LON":"127.09463978","CLNT_NM":"국가식품클러스터지원","LAT":"35.98894836","CLNT_GB":"CL","ADDR":"전북 익산시 왕궁면 왕궁농공단지길 7-39"},{"CLNT_CD":"159784","LON":"127.09949196","CLNT_NM":"주식회사 지놈앤컴퍼","LAT":"37.40512738","CLNT_GB":"CL","ADDR":"경기 성남시 분당구 판교로255번길 35"},{"CLNT_CD":"118280","LON":"126.94082341","CLNT_NM":"연세의료원","LAT":"37.56140577","CLNT_GB":"CL","ADDR":"서울 서대문구 연세로 50-1"},{"CLNT_CD":"BL0000000523","LON":"126.47651839","CLNT_NM":"전라남도보건환경연구","LAT":"34.81099613","CLNT_GB":"BL","ADDR":"전남 무안군 삼향읍 남악영산길 61"},{"CLNT_CD":"BL0000000524","LON":"128.63212398","CLNT_NM":"대구보건환경연구원","LAT":"35.83041794","CLNT_GB":"BL","ADDR":"대구 수성구 무학로 215"},{"CLNT_CD":"BL0000000539","LON":"127.3354981","CLNT_NM":"질병관리본부","LAT":"36.64260138","CLNT_GB":"BL","ADDR":"충북 청주시 흥덕구 오송읍 오송생명2로 187"},{"CLNT_CD":"BL0000000521","LON":"128.61719129","CLNT_NM":"검단졸음쉼터","LAT":"35.91547433","CLNT_GB":"BL","ADDR":"대구 북구 검단동 543-1"},{"CLNT_CD":"BL0000000021","LON":"126.79304011","CLNT_NM":"국민건강보험공단일산","LAT":"37.64547542","CLNT_GB":"BL","ADDR":"경기도 고양시 일산동구 일산로 100"},{"CLNT_CD":"BL0000000500","LON":"127.01356568","CLNT_NM":"한국건강관리협회경기","LAT":"37.297116","CLNT_GB":"BL","ADDR":"경기 수원시 장안구 경수대로 857"},{"CLNT_CD":"BL0000000501","LON":"127.10061144","CLNT_NM":"한국건강관리협회강남","LAT":"37.51442734","CLNT_GB":"BL","ADDR":"서울 송파구 올림픽로 269"},{"CLNT_CD":"BL0000000502","LON":"127.73262916","CLNT_NM":"한국건강관리협회강원","LAT":"37.86506051","CLNT_GB":"BL","ADDR":"강원 춘천시 남춘로 50"},{"CLNT_CD":"BL0000000504","LON":"126.64368253","CLNT_NM":"한국건강관리협회인천","LAT":"37.46200421","CLNT_GB":"BL","ADDR":"인천 미추홀구 독배로 500"},{"CLNT_CD":"BL0000000505","LON":"127.39105853","CLNT_NM":"한국건강관리협회충남","LAT":"36.34055444","CLNT_GB":"BL","ADDR":"대전 서구 계룡로 611"},{"CLNT_CD":"BL0000000506","LON":"129.07656524","CLNT_NM":"한국건강관리협회부산","LAT":"35.20538342","CLNT_GB":"BL","ADDR":"부산 동래구 충렬대로 145"},{"CLNT_CD":"BL0000000507","LON":"129.3267309","CLNT_NM":"한국건강관리협회울산","LAT":"35.55697418","CLNT_GB":"BL","ADDR":"울산 중구 번영로 360"},{"CLNT_CD":"BL0000000508","LON":"127.03197789","CLNT_NM":"한국건강관리협회동부","LAT":"37.5777111","CLNT_GB":"BL","ADDR":"서울 동대문구 왕산로 78"},{"CLNT_CD":"BL0000000513","LON":"126.88851021","CLNT_NM":"한국건강관리협회전남","LAT":"35.14892741","CLNT_GB":"BL","ADDR":"광주 서구 대남대로 432"},{"CLNT_CD":"BL0000000514","LON":"126.49332188","CLNT_NM":"한국건강관리협회제주","LAT":"33.48209515","CLNT_GB":"BL","ADDR":"제주특별자치도 제주시 연북로 111"},{"CLNT_CD":"BL0000000487","LON":"127.04562825","CLNT_NM":"한양대병원","LAT":"37.55863651","CLNT_GB":"BL","ADDR":"서울 성동구 왕십리로 222-1"},{"CLNT_CD":"CO","LON":"127.1004266","CLNT_NM":"GC녹십자","LAT":"37.31777154","CLNT_GB":"ALL","ADDR":"경기도 용인시 기흥구 보정동 303"},{"CLNT_CD":"CL0000000046","LON":"127.10952406","CLNT_NM":"서울아산병원","LAT":"37.52515749","CLNT_GB":"CL","ADDR":"서울 송파구 올림픽로43길 88"},{"CLNT_CD":"BL0000000002","LON":"127.34711211","CLNT_NM":"BML의원","LAT":"36.35351266","CLNT_GB":"BL","ADDR":"대전광역시 유성구 복명동 544-1"},{"CLNT_CD":"BL0000000522","LON":"127.27825747","CLNT_NM":"전라북도보건환경연구","LAT":"35.60954632","CLNT_GB":"BL","ADDR":"전북 임실군 임실읍 호국로 1601"},{"CLNT_CD":"BL0000000525","LON":"126.87380823","CLNT_NM":"광주광역시보건환경연","LAT":"35.14573538","CLNT_GB":"BL","ADDR":"광주 서구 화정로 149"},{"CLNT_CD":"BL0000000526","LON":"129.27084061","CLNT_NM":"울산광역시보건환경연","LAT":"35.53974528","CLNT_GB":"BL","ADDR":"울산 남구 문수로 157"},{"CLNT_CD":"BL0000000527","LON":"129.03636391","CLNT_NM":"부산광역시보건환경연","LAT":"35.20174264","CLNT_GB":"BL","ADDR":"부산 북구 함박봉로140번길 120"},{"CLNT_CD":"BL0000000528","LON":"128.90573141","CLNT_NM":"경상북도보건환경연구","LAT":"35.95359697","CLNT_GB":"BL","ADDR":"경북 영천시 금호읍 고수골길 22"},{"CLNT_CD":"BL0000000529","LON":"126.63502265","CLNT_NM":"인천광역시보건환경연","LAT":"37.46830446","CLNT_GB":"BL","ADDR":"인천 중구 서해대로 471"},{"CLNT_CD":"BL0000000530","LON":"127.0716818","CLNT_NM":"보건환경연구원북부지","LAT":"37.74753668","CLNT_GB":"BL","ADDR":"경기 의정부시 청사로 1"},{"CLNT_CD":"BL0000000531","LON":"127.74476054","CLNT_NM":"강원도보건환경연구원","LAT":"37.95902037","CLNT_GB":"BL","ADDR":"강원 춘천시 신북읍 신북로 386-1"},{"CLNT_CD":"BL0000000532","LON":"126.66724105","CLNT_NM":"충청남도보건환경연구","LAT":"36.65354858","CLNT_GB":"BL","ADDR":"충남 홍성군 홍북읍 홍예공원로 8"},{"CLNT_CD":"BL0000000533","LON":"127.37384128","CLNT_NM":"대전보건환경연구원","LAT":"36.37238293","CLNT_GB":"BL","ADDR":"대전 유성구 대학로 407"},{"CLNT_CD":"BL0000000534","LON":"126.99947583","CLNT_NM":"경기도보건환경연구원","LAT":"37.31381657","CLNT_GB":"BL","ADDR":"경기 수원시 장안구 파장천로 95"},{"CLNT_CD":"BL0000000535","LON":"127.03203254","CLNT_NM":"서울시보건환경연구원","LAT":"37.46512728","CLNT_GB":"BL","ADDR":"경기 과천시 장군마을3길 30"},{"CLNT_CD":"BL0000000536","LON":"128.12290294","CLNT_NM":"경상남도보건환경연구","LAT":"35.21469804","CLNT_GB":"BL","ADDR":"경남 진주시 월아산로 2026"},{"CLNT_CD":"BL0000000537","LON":"127.28327018","CLNT_NM":"세종시보건환경연구원","LAT":"36.60265974","CLNT_GB":"BL","ADDR":"세종특별자치시 조치원읍 서북부2로 12"},{"CLNT_CD":"BL0000000538","LON":"127.32302271","CLNT_NM":"충청북도보건환경연구","LAT":"36.636163","CLNT_GB":"BL","ADDR":"충북 청주시 흥덕구 오송읍 오송생명1로 184"},{"CLNT_CD":"BL0000000540","LON":"126.49505368","CLNT_NM":"제주특별자치도보건환","LAT":"33.47993957","CLNT_GB":"BL","ADDR":"제주특별자치도 제주시 삼동길 41"},{"CLNT_CD":"BL0000000509","LON":"128.55401724","CLNT_NM":"한국건강관리협회경북","LAT":"35.89224435","CLNT_GB":"BL","ADDR":"대구 북구 팔달로 25"},{"CLNT_CD":"BL0000000510","LON":"128.62451676","CLNT_NM":"한국건강관리협회대구","LAT":"35.86840044","CLNT_GB":"BL","ADDR":"대구 동구 장등로 16-12"},{"CLNT_CD":"BL0000000511","LON":"128.57985658","CLNT_NM":"한국건강관리협회경남","LAT":"35.2243835","CLNT_GB":"BL","ADDR":"경남 창원시 마산회원구 삼호로 107"},{"CLNT_CD":"BL0000000512","LON":"127.12162063","CLNT_NM":"한국건강관리협회전북","LAT":"35.8411588","CLNT_GB":"BL","ADDR":"전북 전주시 덕진구 사평로 40"},{"CLNT_CD":"BL0000000515","LON":"127.46316924","CLNT_NM":"한국건강관리협회충북","LAT":"36.64340982","CLNT_GB":"BL","ADDR":"충북 청주시 흥덕구 직지대로 631"},{"CLNT_CD":"BL0000000516","LON":"126.85080855","CLNT_NM":"한국건강관리협회서부","LAT":"37.55388666","CLNT_GB":"BL","ADDR":"서울 강서구 화곡로 335"},{"CLNT_CD":"BL0000000517","LON":"127.41376832","CLNT_NM":"녹십자랩셀대전창고","LAT":"36.34522838","CLNT_GB":"BL","ADDR":"대전 대덕구 오정동 494-23"},{"CLNT_CD":"BL0000000518","LON":"127.00538163","CLNT_NM":"녹십자아이메드(강남)","LAT":"37.490495","CLNT_GB":"BL","ADDR":"서울 서초구 서초대로38길 12"},{"CLNT_CD":"BL0000000519","LON":"126.99732746","CLNT_NM":"녹십자아이메드(강북)","LAT":"37.56613915","CLNT_GB":"BL","ADDR":"서울 중구 을지로 170"},{"CLNT_CD":"BL0000000520","LON":"127.94992408","CLNT_NM":"원주톨게이트","LAT":"37.39916534","CLNT_GB":"BL","ADDR":"강원 원주시 노하길 26"}];
			var list2 = [{"MOBILE_NO":"01200000001","CAR_CD":"10490","CAR_NO":"1호차","LAST_DATE":"03\/23 19:00","LON":"127.7055211","LAST_LOCATE":"전라남도 여수시 미평동","LAT":"34.7704568","DRIVER_NM":"1번기사"},{"MOBILE_NO":"01200000002","CAR_CD":"10466","CAR_NO":"2호차","LAST_DATE":"03\/23 19:00","LON":"126.9753262","LAST_LOCATE":"경기도 양주시 장흥면 부곡리","LAT":"37.7191326","DRIVER_NM":"2번기사"},{"MOBILE_NO":"01200000003","CAR_CD":"10474","CAR_NO":"3호차","LAST_DATE":"03\/23 19:00","LON":"127.3938157","LAST_LOCATE":"대전광역시 중구 태평동","LAT":"36.3233805","DRIVER_NM":"3번기사"},{"MOBILE_NO":"01200000004","CAR_CD":"10447","CAR_NO":"4호차","LAST_DATE":"03\/23 19:00","LON":"126.8756011","LAST_LOCATE":"광주광역시 남구 임암동","LAT":"35.1022639","DRIVER_NM":"4번기사"},{"MOBILE_NO":"01200000005","CAR_CD":"10451","CAR_NO":"5호차","LAST_DATE":"03\/23 19:00","LON":"127.010905","LAST_LOCATE":"서울특별시 성북구 정릉동","LAT":"37.6064543","DRIVER_NM":"5번기사"},{"MOBILE_NO":"01200000006","CAR_CD":"10461","CAR_NO":"6호차","LAST_DATE":"03\/23 19:00","LON":"128.8811902","LAST_LOCATE":"강원도 강릉시 내곡동","LAT":"37.742065","DRIVER_NM":"6번기사"},{"MOBILE_NO":"01200000007","CAR_CD":"10456","CAR_NO":"7호차","LAST_DATE":"03\/23 19:00","LON":"126.6806312","LAST_LOCATE":"인천광역시 미추홀구 주안동","LAT":"37.4655632","DRIVER_NM":"7번기사"},{"MOBILE_NO":"01200000008","CAR_CD":"10468","CAR_NO":"8호차","LAST_DATE":"03\/23 19:00","LON":"126.9276711","LAST_LOCATE":"경기도 평택시 안중읍 현화리","LAT":"36.9839432","DRIVER_NM":"8번기사"},{"MOBILE_NO":"01200000009","CAR_CD":"10448","CAR_NO":"9호차","LAST_DATE":"03\/23 19:00","LON":"126.9103523","LAST_LOCATE":"서울특별시 은평구 신사동","LAT":"37.6004919","DRIVER_NM":"9번기사"},{"MOBILE_NO":"01200000010","CAR_CD":"10457","CAR_NO":"10호차","LAST_DATE":"03\/23 19:00","LON":"126.8642982","LAST_LOCATE":"경기도 시흥시 목감동","LAT":"37.3933702","DRIVER_NM":"10번기사"},{"MOBILE_NO":"01200000011","CAR_CD":"10492","CAR_NO":"11호차","LAST_DATE":"03\/23 19:00","LON":"129.0059557","LAST_LOCATE":"부산광역시 북구 덕천동","LAT":"35.209467","DRIVER_NM":"11번기사"},{"MOBILE_NO":"01200000012","CAR_CD":"10481","CAR_NO":"12호차","LAST_DATE":"03\/23 19:00","LON":"126.9396802","LAST_LOCATE":"광주광역시 동구 월남동","LAT":"35.099911","DRIVER_NM":"12번기사"},{"MOBILE_NO":"01200000013","CAR_CD":"10476","CAR_NO":"13호차","LAST_DATE":"03\/23 19:00","LON":"127.3713529","LAST_LOCATE":"경기도 광주시 곤지암읍 열미리","LAT":"37.3586262","DRIVER_NM":"13번기사"},{"MOBILE_NO":"01200000014","CAR_CD":"10449","CAR_NO":"14호차","LAST_DATE":"03\/23 19:00","LON":"126.7863914","LAST_LOCATE":"경기도 부천시 춘의동","LAT":"37.500705","DRIVER_NM":"14번기사"},{"MOBILE_NO":"01200000015","CAR_CD":"10453","CAR_NO":"15호차","LAST_DATE":"03\/23 19:00","LON":"127.0873559","LAST_LOCATE":"서울특별시 송파구 잠실동","LAT":"37.5087275","DRIVER_NM":"15번기사"},{"MOBILE_NO":"01200000016","CAR_CD":"10464","CAR_NO":"16호차","LAST_DATE":"03\/23 19:00","LON":"126.7310586","LAST_LOCATE":"경기도 시흥시 정왕동","LAT":"37.3684743","DRIVER_NM":"16번기사"},{"MOBILE_NO":"01200000017","CAR_CD":"10459","CAR_NO":"17호차","LAST_DATE":"03\/23 19:00","LON":"128.5510858","LAST_LOCATE":"대구광역시 달서구 송현동","LAT":"35.8298047","DRIVER_NM":"17번기사"},{"MOBILE_NO":"01200000018","CAR_CD":"10470","CAR_NO":"18호차","LAST_DATE":"03\/23 19:00","LON":"128.0615608","LAST_LOCATE":"경상남도 진주시 평거동","LAT":"35.1748508","DRIVER_NM":"18번기사"},{"MOBILE_NO":"01200000019","CAR_CD":"10450","CAR_NO":"19호차","LAST_DATE":"03\/23 19:00","LON":"128.1142051","LAST_LOCATE":"경상남도 진주시 초전동","LAT":"35.2032866","DRIVER_NM":"19번기사"},{"MOBILE_NO":"01200000020","CAR_CD":"10460","CAR_NO":"20호차","LAST_DATE":"03\/23 19:00","LON":"127.0427256","LAST_LOCATE":"경기도 수원시 팔달구 우만동","LAT":"37.2755646","DRIVER_NM":"20번기사"},{"MOBILE_NO":"01200000021","CAR_CD":"10494","CAR_NO":"21호차","LAST_DATE":"03\/23 19:00","LON":"126.4073645","LAST_LOCATE":"전라남도 해남군 황산면 연당리","LAT":"34.5707658","DRIVER_NM":"21번기사"},{"MOBILE_NO":"01200000022","CAR_CD":"10482","CAR_NO":"22호차","LAST_DATE":"03\/23 19:00","LON":"128.8086582","LAST_LOCATE":"경상남도 김해시 부곡동","LAT":"35.202807","DRIVER_NM":"22번기사"},{"MOBILE_NO":"01200000023","CAR_CD":"10478","CAR_NO":"23호차","LAST_DATE":"03\/23 19:00","LON":"128.8736881","LAST_LOCATE":"부산광역시 강서구 미음동","LAT":"35.1438659","DRIVER_NM":"23번기사"},{"MOBILE_NO":"01200000024","CAR_CD":"10475","CAR_NO":"24호차","LAST_DATE":"03\/23 19:00","LON":"127.2574576","LAST_LOCATE":"경기도 광주시 오포읍 양벌리","LAT":"37.3936088","DRIVER_NM":"24번기사"},{"MOBILE_NO":"01200000025","CAR_CD":"10455","CAR_NO":"25호차","LAST_DATE":"03\/23 19:00","LON":"128.596927","LAST_LOCATE":"대구광역시 북구 서변동","LAT":"35.9155325","DRIVER_NM":"25번기사"},{"MOBILE_NO":"01200000026","CAR_CD":"10467","CAR_NO":"26호차","LAST_DATE":"03\/23 19:00","LON":"126.8399552","LAST_LOCATE":"광주광역시 광산구 수완동","LAT":"35.2023222","DRIVER_NM":"26번기사"},{"MOBILE_NO":"01200000027","CAR_CD":"10462","CAR_NO":"27호차","LAST_DATE":"03\/23 19:00","LON":"126.9753034","LAST_LOCATE":"전라남도 담양군 담양읍 양각리","LAT":"35.3186905","DRIVER_NM":"27번기사"},{"MOBILE_NO":"01200000028","CAR_CD":"10471","CAR_NO":"28호차","LAST_DATE":"03\/23 19:00","LON":"126.7743025","LAST_LOCATE":"전라남도 나주시 금천면 석전리","LAT":"35.0223426","DRIVER_NM":"28번기사"},{"MOBILE_NO":"01200000029","CAR_CD":"10452","CAR_NO":"29호차","LAST_DATE":"03\/23 19:00","LON":"129.0611356","LAST_LOCATE":"경상남도 양산시 명곡동","LAT":"35.3406949","DRIVER_NM":"29번기사"},{"MOBILE_NO":"01200000030","CAR_CD":"10463","CAR_NO":"30호차","LAST_DATE":"03\/23 19:00","LON":"126.4246936","LAST_LOCATE":"전라남도 무안군 삼향읍 유교리","LAT":"34.8430022","DRIVER_NM":"30번기사"},{"MOBILE_NO":"01200000031","CAR_CD":"10495","CAR_NO":"31호차","LAST_DATE":"03\/23 19:00","LON":"127.3679682","LAST_LOCATE":"대전광역시 서구 갈마동","LAT":"36.3503984","DRIVER_NM":"31번기사"},{"MOBILE_NO":"01200000032","CAR_CD":"10484","CAR_NO":"32호차","LAST_DATE":"03\/23 19:00","LON":"127.1073733","LAST_LOCATE":"경기도 성남시 분당구 정자동","LAT":"37.3767724","DRIVER_NM":"32번기사"},{"MOBILE_NO":"01200000033","CAR_CD":"10472","CAR_NO":"33호차","LAST_DATE":"03\/23 19:00","LON":"127.2587564","LAST_LOCATE":"경기도 안성시 대덕면 진현리","LAT":"37.0536605","DRIVER_NM":"33번기사"},{"MOBILE_NO":"01200000034","CAR_CD":"10477","CAR_NO":"34호차","LAST_DATE":"03\/23 19:00","LON":"127.6773722","LAST_LOCATE":"충청북도 음성군 음성읍 신천리","LAT":"36.9209624","DRIVER_NM":"34번기사"},{"MOBILE_NO":"01200000035","CAR_CD":"10458","CAR_NO":"35호차","LAST_DATE":"03\/23 19:00","LON":"127.3447531","LAST_LOCATE":"전라남도 보성군 벌교읍 벌교리","LAT":"34.8430632","DRIVER_NM":"35번기사"},{"MOBILE_NO":"01200000036","CAR_CD":"10469","CAR_NO":"36호차","LAST_DATE":"03\/23 19:00","LON":"127.7283024","LAST_LOCATE":"전라남도 여수시 서교동","LAT":"34.7404812","DRIVER_NM":"36번기사"},{"MOBILE_NO":"01200000037","CAR_CD":"10465","CAR_NO":"37호차","LAST_DATE":"03\/23 19:00","LON":"127.4615342","LAST_LOCATE":"충청북도 청주시 서원구 사창동","LAT":"36.6349443","DRIVER_NM":"37번기사"},{"MOBILE_NO":"01200000038","CAR_CD":"10473","CAR_NO":"38호차","LAST_DATE":"03\/23 19:00","LON":"126.888683","LAST_LOCATE":"서울특별시 구로구 구로동","LAT":"37.4900905","DRIVER_NM":"38번기사"},{"MOBILE_NO":"01200000039","CAR_CD":"10454","CAR_NO":"39호차","LAST_DATE":"03\/23 19:00","LON":"128.6171074","LAST_LOCATE":"대구광역시 수성구 수성동2가","LAT":"35.8550068","DRIVER_NM":"39번기사"},{"MOBILE_NO":"01200000040","CAR_CD":"10479","CAR_NO":"40호차","LAST_DATE":"03\/23 19:00","LON":"127.1388507","LAST_LOCATE":"서울특별시 강동구 길동","LAT":"37.5350533","DRIVER_NM":"40번기사"},{"MOBILE_NO":"01200000041","CAR_CD":"10496","CAR_NO":"41호차","LAST_DATE":"03\/23 19:00","LON":"127.0849461","LAST_LOCATE":"서울특별시 광진구 자양동","LAT":"37.5368093","DRIVER_NM":"41번기사"},{"MOBILE_NO":"01200000042","CAR_CD":"10480","CAR_NO":"42호차","LAST_DATE":"03\/23 19:00","LON":"127.1087542","LAST_LOCATE":"충청남도 아산시 배방읍 장재리","LAT":"36.7957805","DRIVER_NM":"42번기사"},{"MOBILE_NO":"01200000043","CAR_CD":"10483","CAR_NO":"43호차","LAST_DATE":"03\/23 19:00","LON":"127.7068138","LAST_LOCATE":"전라남도 여수시 여서동","LAT":"34.7542932","DRIVER_NM":"43번기사"},{"MOBILE_NO":"01200000044","CAR_CD":"10485","CAR_NO":"44호차","LAST_DATE":"03\/23 19:00","LON":"127.0257308","LAST_LOCATE":"서울특별시 강북구 번동","LAT":"37.637804","DRIVER_NM":"44번기사"},{"MOBILE_NO":"01200000045","CAR_CD":"10486","CAR_NO":"45호차","LAST_DATE":"03\/23 19:00","LON":"126.6937109","LAST_LOCATE":"인천광역시 미추홀구 관교동","LAT":"37.4405683","DRIVER_NM":"45번기사"},{"MOBILE_NO":"01200000046","CAR_CD":"10487","CAR_NO":"46호차","LAST_DATE":"03\/23 19:00","LON":"128.754183","LAST_LOCATE":"경상북도 경산시 사동","LAT":"35.8109292","DRIVER_NM":"46번기사"},{"MOBILE_NO":"01200000047","CAR_CD":"10488","CAR_NO":"47호차","LAST_DATE":"03\/23 19:00","LON":"127.0835086","LAST_LOCATE":"충청남도 아산시 음봉면 덕지리","LAT":"36.834241","DRIVER_NM":"47번기사"},{"MOBILE_NO":"01200000048","CAR_CD":"10489","CAR_NO":"48호차","LAST_DATE":"03\/23 19:00","LON":"126.9866915","LAST_LOCATE":"충청남도 아산시 방축동","LAT":"36.7841154","DRIVER_NM":"48번기사"},{"MOBILE_NO":"01200000049","CAR_CD":"10491","CAR_NO":"49호차","LAST_DATE":"03\/23 19:00","LON":"127.2819155","LAST_LOCATE":"경기도 남양주시 화도읍 묵현리","LAT":"37.6554597","DRIVER_NM":"49번기사"},{"MOBILE_NO":"01200000050","CAR_CD":"10493","CAR_NO":"50호차","LAST_DATE":"03\/23 19:00","LON":"127.0878335","LAST_LOCATE":"서울특별시 광진구 중곡동","LAT":"37.5587637","DRIVER_NM":"50번기사"}];
			drawMap(list1, list2, seltype, 0);
	    }
	</script>
</body>
</html>