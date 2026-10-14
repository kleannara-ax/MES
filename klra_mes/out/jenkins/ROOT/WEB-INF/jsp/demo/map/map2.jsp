<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	<meta http-equiv="X-UA-Compatible" content="IE=edge">
	<meta name="viewport" content="initial-scale=1.0, user-scalable=no" />	
	<title>위치관제 예제</title>

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
		<input type="button" id="searchLocate" name="searchLocate" onClick="searchLocate()" value="위치조회">
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
		map.on("click", onMarkerClick);
		
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
	    
	    function drawMap(list, rownum)
	    {
	    	featureSource.clear();
	    	
	    	var sTitle;
	    	var sContent;
	    	var sLat;
	    	var sLon;
	    	var sImg = "/map/img/locate_select.png";
	    	
			for(var i = 0 ; i < list.length; i++)
			{
				var lat = Number(list[i].LAT);
				var lon = Number(list[i].LON);
				var id = list[i].CAR_CD;
				var title = list[i].CAR_NO;

				var content = "";
		        	content += "<table cellspacing='0' cellpadding='0'>";
		        	content += "<tr>";
					content += "<td class='ol-sub-title'>차량번호</td>";
		        	content += "<td class='ol-sub-content'>" + list[i].CAR_NO + "</td>";
		        	content += "</tr>";
		        	content += "<tr>";								 
					content += "<td class='ol-sub-title'>기사명</td>";
		        	content += "<td class='ol-sub-content'>" + list[i].DRIVER_NM + "</td>";
		        	content += "</tr>";
		        	content += "<tr>";
		       		content += "<td class='ol-sub-title'>핸드폰번호</td>";
		            content += "<td class='ol-sub-content'>" + list[i].MOBILE_NO + "</td>";
		            content += "</tr>";
		            content += "<tr>";
		            content += "<td class='ol-sub-title'>수신위치</td>";
		            content += "<td class='ol-sub-content'>" + list[i].LAST_LOCATE + "</td>";
		            content += "</tr>";
		            content += "<tr>";
		            content += "<td class='ol-sub-title'>수신일시</td>";
		            content += "<td class='ol-sub-content'>" + list[i].LAST_DATE + "</td>";
		            content += "</tr>";
		        	content += "</table>";	
		    	
		    	if(i == rownum)
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
	    
	    function searchLocate()
	    {
	    	var list = [{"MOBILE_NO":"01200000001","CAR_CD":"10490","CAR_NO":"1호차","LAST_DATE":"03\/23 19:00","LON":"127.7055211","LAST_LOCATE":"전라남도 여수시 미평동","LAT":"34.7704568","DRIVER_NM":"1번기사"},{"MOBILE_NO":"01200000002","CAR_CD":"10466","CAR_NO":"2호차","LAST_DATE":"03\/23 19:00","LON":"126.9753262","LAST_LOCATE":"경기도 양주시 장흥면 부곡리","LAT":"37.7191326","DRIVER_NM":"2번기사"},{"MOBILE_NO":"01200000003","CAR_CD":"10474","CAR_NO":"3호차","LAST_DATE":"03\/23 19:00","LON":"127.3938157","LAST_LOCATE":"대전광역시 중구 태평동","LAT":"36.3233805","DRIVER_NM":"3번기사"},{"MOBILE_NO":"01200000004","CAR_CD":"10447","CAR_NO":"4호차","LAST_DATE":"03\/23 19:00","LON":"126.8756011","LAST_LOCATE":"광주광역시 남구 임암동","LAT":"35.1022639","DRIVER_NM":"4번기사"},{"MOBILE_NO":"01200000005","CAR_CD":"10451","CAR_NO":"5호차","LAST_DATE":"03\/23 19:00","LON":"127.010905","LAST_LOCATE":"서울특별시 성북구 정릉동","LAT":"37.6064543","DRIVER_NM":"5번기사"},{"MOBILE_NO":"01200000006","CAR_CD":"10461","CAR_NO":"6호차","LAST_DATE":"03\/23 19:00","LON":"128.8811902","LAST_LOCATE":"강원도 강릉시 내곡동","LAT":"37.742065","DRIVER_NM":"6번기사"},{"MOBILE_NO":"01200000007","CAR_CD":"10456","CAR_NO":"7호차","LAST_DATE":"03\/23 19:00","LON":"126.6806312","LAST_LOCATE":"인천광역시 미추홀구 주안동","LAT":"37.4655632","DRIVER_NM":"7번기사"},{"MOBILE_NO":"01200000008","CAR_CD":"10468","CAR_NO":"8호차","LAST_DATE":"03\/23 19:00","LON":"126.9276711","LAST_LOCATE":"경기도 평택시 안중읍 현화리","LAT":"36.9839432","DRIVER_NM":"8번기사"},{"MOBILE_NO":"01200000009","CAR_CD":"10448","CAR_NO":"9호차","LAST_DATE":"03\/23 19:00","LON":"126.9103523","LAST_LOCATE":"서울특별시 은평구 신사동","LAT":"37.6004919","DRIVER_NM":"9번기사"},{"MOBILE_NO":"01200000010","CAR_CD":"10457","CAR_NO":"10호차","LAST_DATE":"03\/23 19:00","LON":"126.8642982","LAST_LOCATE":"경기도 시흥시 목감동","LAT":"37.3933702","DRIVER_NM":"10번기사"},{"MOBILE_NO":"01200000011","CAR_CD":"10492","CAR_NO":"11호차","LAST_DATE":"03\/23 19:00","LON":"129.0059557","LAST_LOCATE":"부산광역시 북구 덕천동","LAT":"35.209467","DRIVER_NM":"11번기사"},{"MOBILE_NO":"01200000012","CAR_CD":"10481","CAR_NO":"12호차","LAST_DATE":"03\/23 19:00","LON":"126.9396802","LAST_LOCATE":"광주광역시 동구 월남동","LAT":"35.099911","DRIVER_NM":"12번기사"},{"MOBILE_NO":"01200000013","CAR_CD":"10476","CAR_NO":"13호차","LAST_DATE":"03\/23 19:00","LON":"127.3713529","LAST_LOCATE":"경기도 광주시 곤지암읍 열미리","LAT":"37.3586262","DRIVER_NM":"13번기사"},{"MOBILE_NO":"01200000014","CAR_CD":"10449","CAR_NO":"14호차","LAST_DATE":"03\/23 19:00","LON":"126.7863914","LAST_LOCATE":"경기도 부천시 춘의동","LAT":"37.500705","DRIVER_NM":"14번기사"},{"MOBILE_NO":"01200000015","CAR_CD":"10453","CAR_NO":"15호차","LAST_DATE":"03\/23 19:00","LON":"127.0873559","LAST_LOCATE":"서울특별시 송파구 잠실동","LAT":"37.5087275","DRIVER_NM":"15번기사"},{"MOBILE_NO":"01200000016","CAR_CD":"10464","CAR_NO":"16호차","LAST_DATE":"03\/23 19:00","LON":"126.7310586","LAST_LOCATE":"경기도 시흥시 정왕동","LAT":"37.3684743","DRIVER_NM":"16번기사"},{"MOBILE_NO":"01200000017","CAR_CD":"10459","CAR_NO":"17호차","LAST_DATE":"03\/23 19:00","LON":"128.5510858","LAST_LOCATE":"대구광역시 달서구 송현동","LAT":"35.8298047","DRIVER_NM":"17번기사"},{"MOBILE_NO":"01200000018","CAR_CD":"10470","CAR_NO":"18호차","LAST_DATE":"03\/23 19:00","LON":"128.0615608","LAST_LOCATE":"경상남도 진주시 평거동","LAT":"35.1748508","DRIVER_NM":"18번기사"},{"MOBILE_NO":"01200000019","CAR_CD":"10450","CAR_NO":"19호차","LAST_DATE":"03\/23 19:00","LON":"128.1142051","LAST_LOCATE":"경상남도 진주시 초전동","LAT":"35.2032866","DRIVER_NM":"19번기사"},{"MOBILE_NO":"01200000020","CAR_CD":"10460","CAR_NO":"20호차","LAST_DATE":"03\/23 19:00","LON":"127.0427256","LAST_LOCATE":"경기도 수원시 팔달구 우만동","LAT":"37.2755646","DRIVER_NM":"20번기사"},{"MOBILE_NO":"01200000021","CAR_CD":"10494","CAR_NO":"21호차","LAST_DATE":"03\/23 19:00","LON":"126.4073645","LAST_LOCATE":"전라남도 해남군 황산면 연당리","LAT":"34.5707658","DRIVER_NM":"21번기사"},{"MOBILE_NO":"01200000022","CAR_CD":"10482","CAR_NO":"22호차","LAST_DATE":"03\/23 19:00","LON":"128.8086582","LAST_LOCATE":"경상남도 김해시 부곡동","LAT":"35.202807","DRIVER_NM":"22번기사"},{"MOBILE_NO":"01200000023","CAR_CD":"10478","CAR_NO":"23호차","LAST_DATE":"03\/23 19:00","LON":"128.8736881","LAST_LOCATE":"부산광역시 강서구 미음동","LAT":"35.1438659","DRIVER_NM":"23번기사"},{"MOBILE_NO":"01200000024","CAR_CD":"10475","CAR_NO":"24호차","LAST_DATE":"03\/23 19:00","LON":"127.2574576","LAST_LOCATE":"경기도 광주시 오포읍 양벌리","LAT":"37.3936088","DRIVER_NM":"24번기사"},{"MOBILE_NO":"01200000025","CAR_CD":"10455","CAR_NO":"25호차","LAST_DATE":"03\/23 19:00","LON":"128.596927","LAST_LOCATE":"대구광역시 북구 서변동","LAT":"35.9155325","DRIVER_NM":"25번기사"},{"MOBILE_NO":"01200000026","CAR_CD":"10467","CAR_NO":"26호차","LAST_DATE":"03\/23 19:00","LON":"126.8399552","LAST_LOCATE":"광주광역시 광산구 수완동","LAT":"35.2023222","DRIVER_NM":"26번기사"},{"MOBILE_NO":"01200000027","CAR_CD":"10462","CAR_NO":"27호차","LAST_DATE":"03\/23 19:00","LON":"126.9753034","LAST_LOCATE":"전라남도 담양군 담양읍 양각리","LAT":"35.3186905","DRIVER_NM":"27번기사"},{"MOBILE_NO":"01200000028","CAR_CD":"10471","CAR_NO":"28호차","LAST_DATE":"03\/23 19:00","LON":"126.7743025","LAST_LOCATE":"전라남도 나주시 금천면 석전리","LAT":"35.0223426","DRIVER_NM":"28번기사"},{"MOBILE_NO":"01200000029","CAR_CD":"10452","CAR_NO":"29호차","LAST_DATE":"03\/23 19:00","LON":"129.0611356","LAST_LOCATE":"경상남도 양산시 명곡동","LAT":"35.3406949","DRIVER_NM":"29번기사"},{"MOBILE_NO":"01200000030","CAR_CD":"10463","CAR_NO":"30호차","LAST_DATE":"03\/23 19:00","LON":"126.4246936","LAST_LOCATE":"전라남도 무안군 삼향읍 유교리","LAT":"34.8430022","DRIVER_NM":"30번기사"},{"MOBILE_NO":"01200000031","CAR_CD":"10495","CAR_NO":"31호차","LAST_DATE":"03\/23 19:00","LON":"127.3679682","LAST_LOCATE":"대전광역시 서구 갈마동","LAT":"36.3503984","DRIVER_NM":"31번기사"},{"MOBILE_NO":"01200000032","CAR_CD":"10484","CAR_NO":"32호차","LAST_DATE":"03\/23 19:00","LON":"127.1073733","LAST_LOCATE":"경기도 성남시 분당구 정자동","LAT":"37.3767724","DRIVER_NM":"32번기사"},{"MOBILE_NO":"01200000033","CAR_CD":"10472","CAR_NO":"33호차","LAST_DATE":"03\/23 19:00","LON":"127.2587564","LAST_LOCATE":"경기도 안성시 대덕면 진현리","LAT":"37.0536605","DRIVER_NM":"33번기사"},{"MOBILE_NO":"01200000034","CAR_CD":"10477","CAR_NO":"34호차","LAST_DATE":"03\/23 19:00","LON":"127.6773722","LAST_LOCATE":"충청북도 음성군 음성읍 신천리","LAT":"36.9209624","DRIVER_NM":"34번기사"},{"MOBILE_NO":"01200000035","CAR_CD":"10458","CAR_NO":"35호차","LAST_DATE":"03\/23 19:00","LON":"127.3447531","LAST_LOCATE":"전라남도 보성군 벌교읍 벌교리","LAT":"34.8430632","DRIVER_NM":"35번기사"},{"MOBILE_NO":"01200000036","CAR_CD":"10469","CAR_NO":"36호차","LAST_DATE":"03\/23 19:00","LON":"127.7283024","LAST_LOCATE":"전라남도 여수시 서교동","LAT":"34.7404812","DRIVER_NM":"36번기사"},{"MOBILE_NO":"01200000037","CAR_CD":"10465","CAR_NO":"37호차","LAST_DATE":"03\/23 19:00","LON":"127.4615342","LAST_LOCATE":"충청북도 청주시 서원구 사창동","LAT":"36.6349443","DRIVER_NM":"37번기사"},{"MOBILE_NO":"01200000038","CAR_CD":"10473","CAR_NO":"38호차","LAST_DATE":"03\/23 19:00","LON":"126.888683","LAST_LOCATE":"서울특별시 구로구 구로동","LAT":"37.4900905","DRIVER_NM":"38번기사"},{"MOBILE_NO":"01200000039","CAR_CD":"10454","CAR_NO":"39호차","LAST_DATE":"03\/23 19:00","LON":"128.6171074","LAST_LOCATE":"대구광역시 수성구 수성동2가","LAT":"35.8550068","DRIVER_NM":"39번기사"},{"MOBILE_NO":"01200000040","CAR_CD":"10479","CAR_NO":"40호차","LAST_DATE":"03\/23 19:00","LON":"127.1388507","LAST_LOCATE":"서울특별시 강동구 길동","LAT":"37.5350533","DRIVER_NM":"40번기사"},{"MOBILE_NO":"01200000041","CAR_CD":"10496","CAR_NO":"41호차","LAST_DATE":"03\/23 19:00","LON":"127.0849461","LAST_LOCATE":"서울특별시 광진구 자양동","LAT":"37.5368093","DRIVER_NM":"41번기사"},{"MOBILE_NO":"01200000042","CAR_CD":"10480","CAR_NO":"42호차","LAST_DATE":"03\/23 19:00","LON":"127.1087542","LAST_LOCATE":"충청남도 아산시 배방읍 장재리","LAT":"36.7957805","DRIVER_NM":"42번기사"},{"MOBILE_NO":"01200000043","CAR_CD":"10483","CAR_NO":"43호차","LAST_DATE":"03\/23 19:00","LON":"127.7068138","LAST_LOCATE":"전라남도 여수시 여서동","LAT":"34.7542932","DRIVER_NM":"43번기사"},{"MOBILE_NO":"01200000044","CAR_CD":"10485","CAR_NO":"44호차","LAST_DATE":"03\/23 19:00","LON":"127.0257308","LAST_LOCATE":"서울특별시 강북구 번동","LAT":"37.637804","DRIVER_NM":"44번기사"},{"MOBILE_NO":"01200000045","CAR_CD":"10486","CAR_NO":"45호차","LAST_DATE":"03\/23 19:00","LON":"126.6937109","LAST_LOCATE":"인천광역시 미추홀구 관교동","LAT":"37.4405683","DRIVER_NM":"45번기사"},{"MOBILE_NO":"01200000046","CAR_CD":"10487","CAR_NO":"46호차","LAST_DATE":"03\/23 19:00","LON":"128.754183","LAST_LOCATE":"경상북도 경산시 사동","LAT":"35.8109292","DRIVER_NM":"46번기사"},{"MOBILE_NO":"01200000047","CAR_CD":"10488","CAR_NO":"47호차","LAST_DATE":"03\/23 19:00","LON":"127.0835086","LAST_LOCATE":"충청남도 아산시 음봉면 덕지리","LAT":"36.834241","DRIVER_NM":"47번기사"},{"MOBILE_NO":"01200000048","CAR_CD":"10489","CAR_NO":"48호차","LAST_DATE":"03\/23 19:00","LON":"126.9866915","LAST_LOCATE":"충청남도 아산시 방축동","LAT":"36.7841154","DRIVER_NM":"48번기사"},{"MOBILE_NO":"01200000049","CAR_CD":"10491","CAR_NO":"49호차","LAST_DATE":"03\/23 19:00","LON":"127.2819155","LAST_LOCATE":"경기도 남양주시 화도읍 묵현리","LAT":"37.6554597","DRIVER_NM":"49번기사"},{"MOBILE_NO":"01200000050","CAR_CD":"10493","CAR_NO":"50호차","LAST_DATE":"03\/23 19:00","LON":"127.0878335","LAST_LOCATE":"서울특별시 광진구 중곡동","LAT":"37.5587637","DRIVER_NM":"50번기사"}];
			
			drawMap(list, 0);
	    }
	</script>
</body>
</html>