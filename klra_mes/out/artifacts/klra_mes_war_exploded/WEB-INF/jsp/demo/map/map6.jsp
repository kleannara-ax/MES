<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<head>
	<meta charset="utf-8">
	<meta http-equiv="X-UA-Compatible" content="IE=edge">
	<meta name="viewport" content="initial-scale=1.0, user-scalable=no" />	
	<title>경로조회 예제</title>

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
			<div class="ol-popup-title"></div>
			<div class="ol-popup-content"></div>
		</div>
	</div>
	
	<div id="search" class="search" style="padding-left:0px; position:absolute; bottom:0px; left:50%;">
		<input type="button" id="searchRoute" name="searchRoute" onClick="searchRoute()" value="경로조회">
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
					title = feature.get("title");
					content = feature.get("content");
					$(obj).find(".ol-popup-title").html(title);
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
	    	var eLat;
	    	var eLon;
	    	var sImg = "/map/img/locate_common.png";

			var lineArray = [];
	    	
			for(var i = 0 ; i < list.length; i++)
			{
				var lat = Number(list[i].LAT);
				var lon = Number(list[i].LON);
				var id = list[i].NO;
				var title = list[i].LOCATE_DT;
				var content = "";
					content += "<table cellspacing='0' cellpadding='0'>";
					content += "<tr>";
					content += "<td class='ol-sub-title'>차량번호</td>";
		        	content += "<td class='ol-sub-content'>" + list[i].CAR_NO + "</td>";
		        	content += "</tr>";		  
		        	content += "<tr>";
		        	content += "<td class='ol-sub-title'>수신위치</td>";
		        	content += "<td class='ol-sub-content'>" + list[i].LOCATE_ADDR + "</td>";
		        	content += "</tr>";
					content += "<tr>";
		        	content += "<td class='ol-sub-title'>수신일시</td>";
		        	content += "<td class='ol-sub-content'>" + list[i].LOCATE_DT + "</td>";
		        	content += "</tr>";
		        	content += "</table>";	
		    	
		    	if(i == rownum)
		    	{
		    		sImg = "/map/img/locate_common.png";
		    		sLat = lat;
		    		sLon = lon;
		    		sTitle = title;
		    		sContent = content;
		    	}
		    	else
		    	{
		    		var img = "/map/img/route_common.png";
		    		addMarker(lat, lon, title, content, img);
		    	}

				if(i > 0)
		    	{
			    	lineArray.push(ol.proj.transform([eLon, eLat], 'EPSG:4326', 'EPSG:3857'));
			    	lineArray.push(ol.proj.transform([lon, lat], 'EPSG:4326', 'EPSG:3857'));
				}
		    	eLat = lat;
		    	eLon = lon;
			}
			
			addMarker(sLat, sLon, sTitle, sContent, sImg);
			
		    var polyline = new ol.Feature();
		    polyline.setGeometry(new ol.geom.LineString(lineArray));
		    polyline.setStyle(new ol.style.Style({
				stroke: new ol.style.Stroke({
					color: '#FF0000',
					width: 4
				})
			}));
			featureSource.addFeature(polyline);
			
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
                stroke: new ol.style.Stroke({ color:"#fff", width:4 }),
                fill: new ol.style.Fill({color:"#333"}),
                font: '13px sans-serif'				
	    	});
	    	
			marker.setStyle(new ol.style.Style({
				image: image,
				text : text
			}));

			featureSource.addFeature(marker);
	    }
	    
	    function searchRoute()
	    {
	    	var list = [{"NO":"1","CAR_NO":"10호차","LOCATE_DT":"04\/21 09:00","LOCATE_ADDR":"서울특별시 영등포구 양평동1가","LON":"126.8904793","LAT":"37.5238158"},{"NO":"2","CAR_NO":"10호차","LOCATE_DT":"04\/21 09:05","LOCATE_ADDR":"서울특별시 영등포구 양평동3가","LON":"126.8910815","LAT":"37.5260946"},{"NO":"3","CAR_NO":"10호차","LOCATE_DT":"04\/21 09:10","LOCATE_ADDR":"서울특별시 영등포구 양평동3가","LON":"126.8920555","LAT":"37.5260163"},{"NO":"4","CAR_NO":"10호차","LOCATE_DT":"04\/21 09:15","LOCATE_ADDR":"서울특별시 영등포구 양평동3가","LON":"126.8919785","LAT":"37.5260067"},{"NO":"5","CAR_NO":"10호차","LOCATE_DT":"04\/21 09:20","LOCATE_ADDR":"서울특별시 영등포구 양평동3가","LON":"126.891946","LAT":"37.5260962"},{"NO":"6","CAR_NO":"10호차","LOCATE_DT":"04\/21 09:25","LOCATE_ADDR":"서울특별시 영등포구 양평동3가","LON":"126.892047","LAT":"37.5260471"},{"NO":"7","CAR_NO":"10호차","LOCATE_DT":"04\/21 09:30","LOCATE_ADDR":"서울특별시 영등포구 양평동3가","LON":"126.892047","LAT":"37.5260471"},{"NO":"8","CAR_NO":"10호차","LOCATE_DT":"04\/21 09:35","LOCATE_ADDR":"서울특별시 영등포구 양평동3가","LON":"126.892047","LAT":"37.5260471"},{"NO":"9","CAR_NO":"10호차","LOCATE_DT":"04\/21 09:40","LOCATE_ADDR":"서울특별시 영등포구 양평동3가","LON":"126.892047","LAT":"37.5260471"},{"NO":"10","CAR_NO":"10호차","LOCATE_DT":"04\/21 09:45","LOCATE_ADDR":"서울특별시 영등포구 양평동3가","LON":"126.892047","LAT":"37.5260471"},{"NO":"11","CAR_NO":"10호차","LOCATE_DT":"04\/21 09:50","LOCATE_ADDR":"서울특별시 영등포구 양평동3가","LON":"126.8920434","LAT":"37.526056"},{"NO":"12","CAR_NO":"10호차","LOCATE_DT":"04\/21 09:55","LOCATE_ADDR":"서울특별시 영등포구 양평동3가","LON":"126.8920457","LAT":"37.5260638"},{"NO":"13","CAR_NO":"10호차","LOCATE_DT":"04\/21 10:00","LOCATE_ADDR":"서울특별시 영등포구 양평동3가","LON":"126.8920457","LAT":"37.5260638"},{"NO":"14","CAR_NO":"10호차","LOCATE_DT":"04\/21 10:05","LOCATE_ADDR":"서울특별시 영등포구 양평동3가","LON":"126.8920723","LAT":"37.5260564"},{"NO":"15","CAR_NO":"10호차","LOCATE_DT":"04\/21 10:10","LOCATE_ADDR":"서울특별시 영등포구 양평동3가","LON":"126.8920723","LAT":"37.5260564"},{"NO":"16","CAR_NO":"10호차","LOCATE_DT":"04\/21 10:15","LOCATE_ADDR":"서울특별시 영등포구 양평동3가","LON":"126.8920723","LAT":"37.5260564"},{"NO":"17","CAR_NO":"10호차","LOCATE_DT":"04\/21 10:20","LOCATE_ADDR":"서울특별시 영등포구 양평동3가","LON":"126.8920723","LAT":"37.5260564"},{"NO":"18","CAR_NO":"10호차","LOCATE_DT":"04\/21 10:25","LOCATE_ADDR":"서울특별시 영등포구 양평동3가","LON":"126.8920485","LAT":"37.526057"},{"NO":"19","CAR_NO":"10호차","LOCATE_DT":"04\/21 10:30","LOCATE_ADDR":"서울특별시 영등포구 양평동3가","LON":"126.8920485","LAT":"37.526057"},{"NO":"20","CAR_NO":"10호차","LOCATE_DT":"04\/21 10:35","LOCATE_ADDR":"서울특별시 영등포구 양평동3가","LON":"126.8920493","LAT":"37.5260525"},{"NO":"21","CAR_NO":"10호차","LOCATE_DT":"04\/21 10:40","LOCATE_ADDR":"서울특별시 영등포구 양평동3가","LON":"126.8920512","LAT":"37.5260484"},{"NO":"22","CAR_NO":"10호차","LOCATE_DT":"04\/21 10:45","LOCATE_ADDR":"서울특별시 영등포구 양평동3가","LON":"126.892047","LAT":"37.5260458"},{"NO":"23","CAR_NO":"10호차","LOCATE_DT":"04\/21 10:50","LOCATE_ADDR":"서울특별시 영등포구 양평동3가","LON":"126.892035","LAT":"37.526052"},{"NO":"24","CAR_NO":"10호차","LOCATE_DT":"04\/21 10:55","LOCATE_ADDR":"서울특별시 영등포구 양평동3가","LON":"126.8920268","LAT":"37.5260584"},{"NO":"25","CAR_NO":"10호차","LOCATE_DT":"04\/21 11:00","LOCATE_ADDR":"서울특별시 영등포구 당산동3가","LON":"126.8921971","LAT":"37.5258639"},{"NO":"26","CAR_NO":"10호차","LOCATE_DT":"04\/21 11:05","LOCATE_ADDR":"서울특별시 영등포구 양평동3가","LON":"126.891068","LAT":"37.5261703"},{"NO":"27","CAR_NO":"10호차","LOCATE_DT":"04\/21 11:10","LOCATE_ADDR":"서울특별시 영등포구 양평동3가","LON":"126.8925886","LAT":"37.5293327"},{"NO":"28","CAR_NO":"10호차","LOCATE_DT":"04\/21 11:15","LOCATE_ADDR":"서울특별시 영등포구 양평동3가","LON":"126.8952568","LAT":"37.5325242"},{"NO":"29","CAR_NO":"10호차","LOCATE_DT":"04\/21 11:20","LOCATE_ADDR":"서울특별시 영등포구 양평동4가","LON":"126.8970756","LAT":"37.5348057"},{"NO":"30","CAR_NO":"10호차","LOCATE_DT":"04\/21 11:25","LOCATE_ADDR":"서울특별시 영등포구 양평동4가","LON":"126.8971342","LAT":"37.5349034"},{"NO":"31","CAR_NO":"10호차","LOCATE_DT":"04\/21 11:30","LOCATE_ADDR":"서울특별시 영등포구 당산동6가","LON":"126.9009781","LAT":"37.5370339"},{"NO":"32","CAR_NO":"10호차","LOCATE_DT":"04\/21 11:35","LOCATE_ADDR":"서울특별시 영등포구 양화동","LON":"126.8930126","LAT":"37.5428566"},{"NO":"33","CAR_NO":"10호차","LOCATE_DT":"04\/21 11:40","LOCATE_ADDR":"서울특별시 영등포구 양화동","LON":"126.8830747","LAT":"37.5479744"},{"NO":"34","CAR_NO":"10호차","LOCATE_DT":"04\/21 11:45","LOCATE_ADDR":"서울특별시 영등포구 양화동","LON":"126.8785158","LAT":"37.5531877"},{"NO":"35","CAR_NO":"10호차","LOCATE_DT":"04\/21 11:50","LOCATE_ADDR":"서울특별시 강서구 염창동","LON":"126.8724726","LAT":"37.5566867"},{"NO":"36","CAR_NO":"10호차","LOCATE_DT":"04\/21 11:55","LOCATE_ADDR":"서울특별시 강서구 염창동","LON":"126.862572","LAT":"37.563477"},{"NO":"37","CAR_NO":"10호차","LOCATE_DT":"04\/21 12:00","LOCATE_ADDR":"서울특별시 강서구 가양동","LON":"126.8509644","LAT":"37.5702792"},{"NO":"38","CAR_NO":"10호차","LOCATE_DT":"04\/21 12:05","LOCATE_ADDR":"서울특별시 강서구 가양동","LON":"126.8401367","LAT":"37.5765054"},{"NO":"39","CAR_NO":"10호차","LOCATE_DT":"04\/21 12:10","LOCATE_ADDR":"서울특별시 강서구 마곡동","LON":"126.8269978","LAT":"37.5814125"},{"NO":"40","CAR_NO":"10호차","LOCATE_DT":"04\/21 12:15","LOCATE_ADDR":"서울특별시 강서구 개화동","LON":"126.81371","LAT":"37.5874909"},{"NO":"41","CAR_NO":"10호차","LOCATE_DT":"04\/21 12:20","LOCATE_ADDR":"서울특별시 강서구 개화동","LON":"126.8029795","LAT":"37.593274"},{"NO":"42","CAR_NO":"10호차","LOCATE_DT":"04\/21 12:25","LOCATE_ADDR":"서울특별시 강서구 개화동","LON":"126.796937","LAT":"37.5846239"},{"NO":"43","CAR_NO":"10호차","LOCATE_DT":"04\/21 12:30","LOCATE_ADDR":"서울특별시 강서구 개화동","LON":"126.7983596","LAT":"37.5809373"},{"NO":"44","CAR_NO":"10호차","LOCATE_DT":"04\/21 12:35","LOCATE_ADDR":"서울특별시 강서구 방화동","LON":"126.802941","LAT":"37.5740779"},{"NO":"45","CAR_NO":"10호차","LOCATE_DT":"04\/21 12:40","LOCATE_ADDR":"서울특별시 강서구 방화동","LON":"126.8055564","LAT":"37.5654604"},{"NO":"46","CAR_NO":"10호차","LOCATE_DT":"04\/21 12:45","LOCATE_ADDR":"서울특별시 강서구 방화동","LON":"126.8026652","LAT":"37.5678535"},{"NO":"47","CAR_NO":"10호차","LOCATE_DT":"04\/21 12:50","LOCATE_ADDR":"서울특별시 강서구 방화동","LON":"126.8026652","LAT":"37.5678535"},{"NO":"48","CAR_NO":"10호차","LOCATE_DT":"04\/21 12:55","LOCATE_ADDR":"서울특별시 강서구 방화동","LON":"126.8047564","LAT":"37.5628648"},{"NO":"49","CAR_NO":"10호차","LOCATE_DT":"04\/21 13:00","LOCATE_ADDR":"서울특별시 강서구 방화동","LON":"126.8047564","LAT":"37.5628648"},{"NO":"50","CAR_NO":"10호차","LOCATE_DT":"04\/21 13:05","LOCATE_ADDR":"서울특별시 강서구 방화동","LON":"126.8047564","LAT":"37.5628648"},{"NO":"51","CAR_NO":"10호차","LOCATE_DT":"04\/21 13:10","LOCATE_ADDR":"서울특별시 강서구 방화동","LON":"126.8047564","LAT":"37.5628648"},{"NO":"52","CAR_NO":"10호차","LOCATE_DT":"04\/21 13:15","LOCATE_ADDR":"서울특별시 강서구 방화동","LON":"126.8047564","LAT":"37.5628648"},{"NO":"53","CAR_NO":"10호차","LOCATE_DT":"04\/21 13:20","LOCATE_ADDR":"서울특별시 강서구 방화동","LON":"126.8047564","LAT":"37.5628648"},{"NO":"54","CAR_NO":"10호차","LOCATE_DT":"04\/21 13:25","LOCATE_ADDR":"서울특별시 강서구 방화동","LON":"126.8047564","LAT":"37.5628648"},{"NO":"55","CAR_NO":"10호차","LOCATE_DT":"04\/21 13:30","LOCATE_ADDR":"서울특별시 강서구 방화동","LON":"126.8047564","LAT":"37.5628648"},{"NO":"56","CAR_NO":"10호차","LOCATE_DT":"04\/21 13:35","LOCATE_ADDR":"서울특별시 강서구 방화동","LON":"126.8047564","LAT":"37.5628648"},{"NO":"57","CAR_NO":"10호차","LOCATE_DT":"04\/21 13:40","LOCATE_ADDR":"서울특별시 강서구 방화동","LON":"126.8047564","LAT":"37.5628648"},{"NO":"58","CAR_NO":"10호차","LOCATE_DT":"04\/21 13:45","LOCATE_ADDR":"서울특별시 강서구 방화동","LON":"126.8047564","LAT":"37.5628648"},{"NO":"59","CAR_NO":"10호차","LOCATE_DT":"04\/21 13:50","LOCATE_ADDR":"서울특별시 강서구 방화동","LON":"126.8026652","LAT":"37.5678535"},{"NO":"60","CAR_NO":"10호차","LOCATE_DT":"04\/21 13:55","LOCATE_ADDR":"서울특별시 강서구 방화동","LON":"126.8047564","LAT":"37.5628648"},{"NO":"61","CAR_NO":"10호차","LOCATE_DT":"04\/21 14:00","LOCATE_ADDR":"서울특별시 강서구 방화동","LON":"126.8047565","LAT":"37.5628648"},{"NO":"62","CAR_NO":"10호차","LOCATE_DT":"04\/21 14:05","LOCATE_ADDR":"서울특별시 강서구 방화동","LON":"126.8047564","LAT":"37.5628648"},{"NO":"63","CAR_NO":"10호차","LOCATE_DT":"04\/21 14:10","LOCATE_ADDR":"서울특별시 강서구 방화동","LON":"126.8026652","LAT":"37.5678535"},{"NO":"64","CAR_NO":"10호차","LOCATE_DT":"04\/21 14:15","LOCATE_ADDR":"서울특별시 강서구 방화동","LON":"126.8047532","LAT":"37.5628669"},{"NO":"65","CAR_NO":"10호차","LOCATE_DT":"04\/21 14:20","LOCATE_ADDR":"서울특별시 강서구 방화동","LON":"126.8047564","LAT":"37.5628648"},{"NO":"66","CAR_NO":"10호차","LOCATE_DT":"04\/21 14:25","LOCATE_ADDR":"서울특별시 강서구 방화동","LON":"126.8047564","LAT":"37.5628648"},{"NO":"67","CAR_NO":"10호차","LOCATE_DT":"04\/21 14:30","LOCATE_ADDR":"서울특별시 강서구 방화동","LON":"126.8047594","LAT":"37.562864"},{"NO":"68","CAR_NO":"10호차","LOCATE_DT":"04\/21 14:35","LOCATE_ADDR":"서울특별시 강서구 방화동","LON":"126.8047611","LAT":"37.5628699"},{"NO":"69","CAR_NO":"10호차","LOCATE_DT":"04\/21 14:40","LOCATE_ADDR":"서울특별시 강서구 방화동","LON":"126.804759","LAT":"37.5628702"},{"NO":"70","CAR_NO":"10호차","LOCATE_DT":"04\/21 14:45","LOCATE_ADDR":"서울특별시 강서구 방화동","LON":"126.8026652","LAT":"37.5678535"},{"NO":"71","CAR_NO":"10호차","LOCATE_DT":"04\/21 14:50","LOCATE_ADDR":"서울특별시 강서구 방화동","LON":"126.8047456","LAT":"37.5628566"},{"NO":"72","CAR_NO":"10호차","LOCATE_DT":"04\/21 14:55","LOCATE_ADDR":"서울특별시 강서구 방화동","LON":"126.8026652","LAT":"37.5678535"},{"NO":"73","CAR_NO":"10호차","LOCATE_DT":"04\/21 15:00","LOCATE_ADDR":"서울특별시 강서구 방화동","LON":"126.804756","LAT":"37.5628649"},{"NO":"74","CAR_NO":"10호차","LOCATE_DT":"04\/21 15:05","LOCATE_ADDR":"서울특별시 강서구 방화동","LON":"126.8047564","LAT":"37.5628648"},{"NO":"75","CAR_NO":"10호차","LOCATE_DT":"04\/21 15:10","LOCATE_ADDR":"서울특별시 강서구 방화동","LON":"126.8026652","LAT":"37.5678535"},{"NO":"76","CAR_NO":"10호차","LOCATE_DT":"04\/21 15:15","LOCATE_ADDR":"서울특별시 강서구 방화동","LON":"126.8047568","LAT":"37.5628647"},{"NO":"77","CAR_NO":"10호차","LOCATE_DT":"04\/21 15:20","LOCATE_ADDR":"서울특별시 강서구 방화동","LON":"126.804758","LAT":"37.5628633"},{"NO":"78","CAR_NO":"10호차","LOCATE_DT":"04\/21 15:25","LOCATE_ADDR":"서울특별시 강서구 방화동","LON":"126.8047599","LAT":"37.5628629"},{"NO":"79","CAR_NO":"10호차","LOCATE_DT":"04\/21 15:30","LOCATE_ADDR":"서울특별시 강서구 방화동","LON":"126.8026652","LAT":"37.5678535"},{"NO":"80","CAR_NO":"10호차","LOCATE_DT":"04\/21 15:35","LOCATE_ADDR":"서울특별시 강서구 방화동","LON":"126.8047268","LAT":"37.5637189"},{"NO":"81","CAR_NO":"10호차","LOCATE_DT":"04\/21 15:40","LOCATE_ADDR":"서울특별시 강서구 방화동","LON":"126.8035643","LAT":"37.5626602"},{"NO":"82","CAR_NO":"10호차","LOCATE_DT":"04\/21 15:45","LOCATE_ADDR":"서울특별시 강서구 공항동","LON":"126.8073451","LAT":"37.5607896"},{"NO":"83","CAR_NO":"10호차","LOCATE_DT":"04\/21 15:50","LOCATE_ADDR":"서울특별시 강서구 공항동","LON":"126.8134552","LAT":"37.5541713"},{"NO":"84","CAR_NO":"10호차","LOCATE_DT":"04\/21 15:55","LOCATE_ADDR":"서울특별시 강서구 외발산동","LON":"126.820493","LAT":"37.5477262"},{"NO":"85","CAR_NO":"10호차","LOCATE_DT":"04\/21 16:00","LOCATE_ADDR":"서울특별시 강서구 외발산동","LON":"126.8217075","LAT":"37.5449937"},{"NO":"86","CAR_NO":"10호차","LOCATE_DT":"04\/21 16:05","LOCATE_ADDR":"서울특별시 강서구 외발산동","LON":"126.8241544","LAT":"37.5416118"},{"NO":"87","CAR_NO":"10호차","LOCATE_DT":"04\/21 16:10","LOCATE_ADDR":"서울특별시 양천구 신월동","LON":"126.8251572","LAT":"37.540472"},{"NO":"88","CAR_NO":"10호차","LOCATE_DT":"04\/21 16:15","LOCATE_ADDR":"서울특별시 양천구 신월동","LON":"126.8266995","LAT":"37.5381799"},{"NO":"89","CAR_NO":"10호차","LOCATE_DT":"04\/21 16:20","LOCATE_ADDR":"서울특별시 양천구 신월동","LON":"126.8305586","LAT":"37.5324951"},{"NO":"90","CAR_NO":"10호차","LOCATE_DT":"04\/21 16:25","LOCATE_ADDR":"서울특별시 양천구 신월동","LON":"126.8307794","LAT":"37.5321364"},{"NO":"91","CAR_NO":"10호차","LOCATE_DT":"04\/21 16:30","LOCATE_ADDR":"서울특별시 양천구 신월동","LON":"126.8328273","LAT":"37.529058"},{"NO":"92","CAR_NO":"10호차","LOCATE_DT":"04\/21 16:35","LOCATE_ADDR":"서울특별시 양천구 신월동","LON":"126.835815","LAT":"37.5239451"},{"NO":"93","CAR_NO":"10호차","LOCATE_DT":"04\/21 16:40","LOCATE_ADDR":"서울특별시 양천구 신월동","LON":"126.8367755","LAT":"37.522428"},{"NO":"94","CAR_NO":"10호차","LOCATE_DT":"04\/21 16:45","LOCATE_ADDR":"서울특별시 양천구 신월동","LON":"126.8373327","LAT":"37.5215582"},{"NO":"95","CAR_NO":"10호차","LOCATE_DT":"04\/21 16:50","LOCATE_ADDR":"서울특별시 양천구 신월동","LON":"126.8377781","LAT":"37.5207383"},{"NO":"96","CAR_NO":"10호차","LOCATE_DT":"04\/21 16:55","LOCATE_ADDR":"서울특별시 양천구 신월동","LON":"126.8403891","LAT":"37.5147692"},{"NO":"97","CAR_NO":"10호차","LOCATE_DT":"04\/21 17:00","LOCATE_ADDR":"서울특별시 양천구 신정동","LON":"126.843895","LAT":"37.5069695"},{"NO":"98","CAR_NO":"10호차","LOCATE_DT":"04\/21 17:05","LOCATE_ADDR":"서울특별시 구로구 개봉동","LON":"126.8457596","LAT":"37.5031758"},{"NO":"99","CAR_NO":"10호차","LOCATE_DT":"04\/21 17:10","LOCATE_ADDR":"서울특별시 구로구 개봉동","LON":"126.8460419","LAT":"37.50256"},{"NO":"100","CAR_NO":"10호차","LOCATE_DT":"04\/21 17:15","LOCATE_ADDR":"서울특별시 구로구 개봉동","LON":"126.8481633","LAT":"37.498537"},{"NO":"101","CAR_NO":"10호차","LOCATE_DT":"04\/21 17:20","LOCATE_ADDR":"서울특별시 구로구 개봉동","LON":"126.8559791","LAT":"37.4938005"},{"NO":"102","CAR_NO":"10호차","LOCATE_DT":"04\/21 17:25","LOCATE_ADDR":"서울특별시 구로구 개봉동","LON":"126.8666122","LAT":"37.4926809"},{"NO":"103","CAR_NO":"10호차","LOCATE_DT":"04\/21 17:30","LOCATE_ADDR":"서울특별시 구로구 구로동","LON":"126.8757758","LAT":"37.4894225"},{"NO":"104","CAR_NO":"10호차","LOCATE_DT":"04\/21 17:35","LOCATE_ADDR":"서울특별시 구로구 구로동","LON":"126.8770617","LAT":"37.4874713"},{"NO":"105","CAR_NO":"10호차","LOCATE_DT":"04\/21 17:40","LOCATE_ADDR":"서울특별시 구로구 구로동","LON":"126.8768474","LAT":"37.4867525"},{"NO":"106","CAR_NO":"10호차","LOCATE_DT":"04\/21 17:45","LOCATE_ADDR":"서울특별시 구로구 구로동","LON":"126.8767826","LAT":"37.4866437"},{"NO":"107","CAR_NO":"10호차","LOCATE_DT":"04\/21 17:50","LOCATE_ADDR":"서울특별시 구로구 구로동","LON":"126.8764685","LAT":"37.4858266"},{"NO":"108","CAR_NO":"10호차","LOCATE_DT":"04\/21 17:55","LOCATE_ADDR":"서울특별시 금천구 가산동","LON":"126.8745654","LAT":"37.4852344"},{"NO":"109","CAR_NO":"10호차","LOCATE_DT":"04\/21 18:00","LOCATE_ADDR":"서울특별시 금천구 가산동","LON":"126.8745688","LAT":"37.4852346"},{"NO":"110","CAR_NO":"10호차","LOCATE_DT":"04\/21 18:05","LOCATE_ADDR":"서울특별시 금천구 가산동","LON":"126.8737028","LAT":"37.4851455"},{"NO":"111","CAR_NO":"10호차","LOCATE_DT":"04\/21 18:10","LOCATE_ADDR":"서울특별시 금천구 가산동","LON":"126.877301","LAT":"37.4769961"},{"NO":"112","CAR_NO":"10호차","LOCATE_DT":"04\/21 18:15","LOCATE_ADDR":"서울특별시 금천구 가산동","LON":"126.8825211","LAT":"37.4698339"},{"NO":"113","CAR_NO":"10호차","LOCATE_DT":"04\/21 18:20","LOCATE_ADDR":"서울특별시 금천구 독산동","LON":"126.8872459","LAT":"37.464284"},{"NO":"114","CAR_NO":"10호차","LOCATE_DT":"04\/21 18:25","LOCATE_ADDR":"서울특별시 금천구 독산동","LON":"126.8912299","LAT":"37.4554372"},{"NO":"115","CAR_NO":"10호차","LOCATE_DT":"04\/21 18:30","LOCATE_ADDR":"경기도 광명시 소하동","LON":"126.8963049","LAT":"37.4450949"},{"NO":"116","CAR_NO":"10호차","LOCATE_DT":"04\/21 18:35","LOCATE_ADDR":"경기도 광명시 소하동","LON":"126.8904178","LAT":"37.4318185"},{"NO":"117","CAR_NO":"10호차","LOCATE_DT":"04\/21 18:40","LOCATE_ADDR":"경기도 광명시 소하동","LON":"126.8926959","LAT":"37.4343867"},{"NO":"118","CAR_NO":"10호차","LOCATE_DT":"04\/21 18:45","LOCATE_ADDR":"경기도 광명시 가학동","LON":"126.8647205","LAT":"37.4147962"},{"NO":"119","CAR_NO":"10호차","LOCATE_DT":"04\/21 18:50","LOCATE_ADDR":"경기도 광명시 가학동","LON":"126.8577701","LAT":"37.4143699"},{"NO":"120","CAR_NO":"10호차","LOCATE_DT":"04\/21 18:55","LOCATE_ADDR":"경기도 광명시 가학동","LON":"126.8601037","LAT":"37.4043323"},{"NO":"121","CAR_NO":"10호차","LOCATE_DT":"04\/21 19:00","LOCATE_ADDR":"경기도 시흥시 목감동","LON":"126.8642982","LAT":"37.3933702"}];

	    	drawMap(list, 0);
	    }
	</script>
</body>
</html>