<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!doctype html>
<html lang="ko">
<head>
<meta charset="utf-8">
<meta http-equiv="X-UA-Compatible" content="IE=EmulateIE7">
<title>TMS</title> 
<%@ include file="/common/include/head.jsp" %>
<script type="text/javascript" src="https://openapi.map.naver.com/openapi/v2/maps.js?clientId=lxQ97cnrDc24lXlWkXj7"></script>

</head>
<body>
<!-- content -->
 
<div id="map" style="border:1px solid #000; width:100%; height:100%"></div> 
<div>
  <button onclick="testGeocoding();">reversegeocoding get </button>
</div>
<!-- //content -->
<script type="text/javascript">
		var oSeoulCityPoint = new nhn.api.map.LatLng(37.5675451, 126.9773356);
		var defaultLevel = 5; 
		var oMap = new nhn.api.map.Map(document.getElementById('map'), {
			point : oSeoulCityPoint,
			zoom : defaultLevel,
			enableWheelZoom : true,
			enableDragPan : true,
			enableDblClickZoom : false,
			mapMode : 0,
			activateTrafficMap : false,
			activateBicycleMap : false,
			minMaxLevel : [ 1, 14 ],
			size : new nhn.api.map.Size(800, 480)		});
		
		function searcMap (Lat,Lng) {
		    $("#map").html();
		    $("#map").html("");
		    var oPoint = new nhn.api.map.LatLng(Lat,Lng);
			oMap = new nhn.api.map.Map(document.getElementById('map'), {
							point : oPoint,
							zoom : defaultLevel,
							enableWheelZoom : true,
							enableDragPan : true,
							enableDblClickZoom : false,
							mapMode : 0,
							activateTrafficMap : false,
							activateBicycleMap : false,
							minMaxLevel : [ 1, 14 ],
							size : new nhn.api.map.Size(800, 480)		});
		}	
		var oTrafficGuide = new nhn.api.map.TrafficGuide(); // - 교통 범례 선언
        oTrafficGuide.setPosition({
                bottom : 20,
                left : 10
        });  // - 교통 범례 위치 지정.
        oMap.addControl(oTrafficGuide); // - 교통 범례를 지도에 추가.
        
		var oSlider = new nhn.api.map.ZoomControl();
		oMap.addControl(oSlider);
		oSlider.setPosition({
			top : 10,
			left : 10
		});
 
		var oMapTypeBtn = new nhn.api.map.MapTypeBtn();
		oMap.addControl(oMapTypeBtn);
		oMapTypeBtn.setPosition({
			bottom : 10,
			right : 80
		}); 
		
		var oTrafficGuide = new nhn.api.map.TrafficGuide(); // - 교통 범례 선언
		oTrafficGuide.setPosition({
			bottom : 30,
			left : 10
		});  // - 교통 범례 위치 지정.
		oMap.addControl(oTrafficGuide); // - 교통 범례를 지도에 추가.
 
		var oSize = new nhn.api.map.Size(28, 37);
		var oOffset = new nhn.api.map.Size(14, 37);
		var oIcon = new nhn.api.map.Icon('https://static.naver.com/maps2/icons/pin_spot2.png', oSize, oOffset);

		var oInfoWnd = new nhn.api.map.InfoWindow();
		oInfoWnd.setVisible(false);
		oMap.addOverlay(oInfoWnd);

		oInfoWnd.setPosition({
			top : 20,
			left :20
		});

		var oLabel = new nhn.api.map.MarkerLabel(); // - 마커 라벨 선언.
		oMap.addOverlay(oLabel); // - 마커 라벨 지도에 추가. 기본은 라벨이 보이지 않는 상태로 추가됨.

		oInfoWnd.attach('changeVisible', function(oCustomEvent) {
			if (oCustomEvent.visible) {
				oLabel.setVisible(false);
			}
		});

		var oPolyline = new nhn.api.map.Polyline([], {
			strokeColor : '#f00', // - 선의 색깔
			strokeWidth : 5, // - 선의 두께
			strokeOpacity : 0.5 // - 선의 투명도
		}); // - polyline 선언, 첫번째 인자는 선이 그려질 점의 위치. 현재는 없음.
		oMap.addOverlay(oPolyline); // - 지도에 선을 추가함.

		oMap.attach('mouseenter', function(oCustomEvent) {

			var oTarget = oCustomEvent.target;
			// 마커위에 마우스 올라간거면
			if (oTarget instanceof nhn.api.map.Marker) {
				var oMarker = oTarget;
				oLabel.setVisible(true, oMarker); // - 특정 마커를 지정하여 해당 마커의 title을 보여준다.
			}
		});

		oMap.attach('mouseleave', function(oCustomEvent) {

			var oTarget = oCustomEvent.target;
			// 마커위에서 마우스 나간거면
			if (oTarget instanceof nhn.api.map.Marker) {
				oLabel.setVisible(false);
			}
		});

		oMap.attach('click', function(oCustomEvent) {
			var oPoint = oCustomEvent.point;
			var oTarget = oCustomEvent.target;
			oInfoWnd.setVisible(false);
			// 마커 클릭하면
			if (oTarget instanceof nhn.api.map.Marker) {
				// 겹침 마커 클릭한거면
				if (oCustomEvent.clickCoveredMarker) {
					return;
				}
				// - InfoWindow 에 들어갈 내용은 setContent 로 자유롭게 넣을 수 있습니다. 외부 css를 이용할 수 있으며,
				// - 외부 css에 선언된 class를 이용하면 해당 class의 스타일을 바로 적용할 수 있습니다.
				// - 단, DIV 의 position style 은 absolute 가 되면 안되며,
				// - absolute 의 경우 autoPosition 이 동작하지 않습니다.
				oInfoWnd.setContent('<DIV style="border-top:1px solid; border-bottom:2px groove black; border-left:1px solid; border-right:2px groove black;margin-bottom:1px;color:black;background-color:white; width:auto; height:auto;">'+
					'<span style="color: #000000 !important;display: inline-block;font-size: 12px !important;font-weight: bold !important;letter-spacing: -1px !important;white-space: nowrap !important; padding: 2px 5px 2px 2px !important">' +
					'Hello World <br /> ' + oTarget.getPoint()
					+'<span></div>');
				oInfoWnd.setPoint(oTarget.getPoint());
				oInfoWnd.setPosition({right : 15, top : 30});
				oInfoWnd.setVisible(true);
				oInfoWnd.autoPosition();
				return;
			}
			var oMarker = new nhn.api.map.Marker(oIcon, { title : '마커 : ' + oPoint.toString() });
			oMarker.setPoint(oPoint);
			oMap.addOverlay(oMarker);

			var aPoints = oPolyline.getPoints(); // - 현재 폴리라인을 이루는 점을 가져와서 배열에 저장.
			aPoints.push(oPoint); // - 추가하고자 하는 점을 추가하여 배열로 저장함.
			oPolyline.setPoints(aPoints); // - 해당 폴리라인에 배열에 저장된 점을 추가함
		});
		  	 
	    var oIcon = new nhn.api.map.Icon('http://static.naver.com/maps2/icons/pin_spot2.png', oSize, oOffset);
	     
	    var nhnAPI_reversegeocode_1 = "https://openapi.naver.com/v1/map/reversegeocode?encoding=utf-8&coord=latlng&output=json&query=126.9808103,37.5675572";//126.9808103,37.5675572
	    
	    var nhnAPI_reversegeocode_2 = "https://openapi.naver.com/v1/map/reversegeocode?encoding=utf-8&coord=latlng&output=json&query=127.0527883,37.5098753";//126.9808103,37.5675572

	    $.support.cors = true; // jquery로 ajax 사용시 No transport 라는 에러가 발생하는 경우가 있다. 
	    					   // 보통 localhost 로 테스트 시 크로스 도메인 문제로 발생하는 오류
	    var resultList;
	    var _x,_y,_point; 
	    var staticIdx=1;
	    function testGeocoding(){
	    	var nhnAPI_reversegeocode;
	    	if( ( ++staticIdx % 2 ) == 0 ){
	    		nhnAPI_reversegeocode=nhnAPI_reversegeocode_1;
	    	} else {
	    		nhnAPI_reversegeocode=nhnAPI_reversegeocode_2;
	    	}
	    	
	        jQuery.ajax({
	              type:"GET",
	              url:nhnAPI_reversegeocode,
	              dataType:"JSON", // 옵션이므로 JSON으로 받을게 아니면 안써도 됨
	              beforeSend : function(xhr){//=&=
	                  xhr.setRequestHeader("X-Naver-Client-Id", "lxQ97cnrDc24lXlWkXj7"); // 8443
	                  xhr.setRequestHeader("X-Naver-Client-Secret","HwSfSINCYR");
	                //xhr.setRequestHeader("X-Naver-Client-Id", "LiCi9P5cXTczQa1c23Gc"); // 8080
	                //xhr.setRequestHeader("X-Naver-Client-Secret","qqJReUItDl");
	              },
	              success : function(data) {
	                    // 통신이 성공적으로 이루어졌을 때 이 함수를 타게 된다.
	                    // TODO
	                  //alert("success");
					resultList = data.result.items;
	          		$.each(resultList, function(i, obj) { 
	          			_x = obj.point.x;// 
	          			_y = obj.point.y;//  
	          			/**/
	          		  //_point = new nhn.api.map.LatLng(_x, _y);
	          			_point = new nhn.api.map.LatLng(_y, _x);
	          			var oMarker = new nhn.api.map.Marker(oIcon, { title : '도착지 :?' });
	        			oMarker.setPoint(_point);
	        		    oMap.addOverlay(oMarker);
	        		    /**/ 
	        		  //searcMap(_x, _y);
	        		  //searcMap(_y,_x);
	          		});
	              },
	              complete : function(data) {
	                    // 통신이 실패했어도 완료가 되었을 때 이 함수를 타게 된다.
	                    // TODO
	
	                    //alert("complete");
	              },
	              error : function(xhr, status, error) {
	                    alert("에러발생");
	              }
	        }); 
	    }
</script>
<%@ include file="/common/include/bottom.jsp" %>
</body>
</html>