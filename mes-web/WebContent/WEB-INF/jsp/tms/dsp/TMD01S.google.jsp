<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!doctype html>
<html lang="ko">
<head>
<meta charset="utf-8">
<meta http-equiv="X-UA-Compatible" content="IE=EmulateIE7">
<title>TMS</title> 
<%@ include file="/common/include/head.jsp" %>
<script src="https://maps.googleapis.com/maps/api/js?key=AIzaSyATTSjgG0Qu-e3zW2gJ0R2HZu-JmjF6mi0" type="text/javascript"></script>
</head>
<body>
<!-- content -->
 
<div id="map-canvas" style="border:1px solid #000; width:100%; height:100%"></div> 
<div>
  <button onclick="testGeocoding();">displayRoute</button>
</div>
<!-- //content -->
<script type="text/javascript">

function initMap() {

	//var pointA = new google.maps.LatLng(51.7519, -1.2578),
	//    pointB = new google.maps.LatLng(50.8429, -0.1313),
	  var pointA = new google.maps.LatLng(37.5675, 126.9773), //37.5675451, 126.9773356
	    pointB = new google.maps.LatLng(37.5098, 127.0527),   //126.9808103,37.5675572
	    myOptions = {
	      zoom: 7,
	      center: pointA
	    },
	    map = new google.maps.Map(document.getElementById('map-canvas'), myOptions),
	    // Instantiate a directions service.
	    directionsService = new google.maps.DirectionsService,
	    directionsDisplay = new google.maps.DirectionsRenderer({
	      map: map
	    }),
	    markerA = new google.maps.Marker({
	      position: pointA,
	      title: "point A",
	      label: "A",
	      map: map
	    }),
	    markerB = new google.maps.Marker({
	      position: pointB,
	      title: "point B",
	      label: "B",
	      map: map
	    });

	  // get route from A to B
	  calculateAndDisplayRoute(directionsService, directionsDisplay, pointA, pointB);

	}



	function calculateAndDisplayRoute(directionsService, directionsDisplay, pointA, pointB) {
	  directionsService.route({
	    origin: pointA,
	    destination: pointB,
	    travelMode: google.maps.TravelMode.DRIVING
	  }, function(response, status) {
	    if (status == google.maps.DirectionsStatus.OK) {
	      directionsDisplay.setDirections(response);
	    } else {
	      window.alert('Directions request failed due to ' + status);
	    }
	  });
	}

	function displayRoute() {

	    var start = new google.maps.LatLng(28.694004, 77.110291);
	    var end = new google.maps.LatLng(28.72082, 77.107241);

	    var directionsDisplay = new google.maps.DirectionsRenderer();// also, constructor can get "DirectionsRendererOptions" object
	    directionsDisplay.setMap(map); // map should be already initialized.

	    var request = {
	        origin : start,
	        destination : end,
	        travelMode : google.maps.TravelMode.DRIVING
	    };
	    var directionsService = new google.maps.DirectionsService(); 
	    directionsService.route(request, function(response, status) {
	        if (status == google.maps.DirectionsStatus.OK) {
	            directionsDisplay.setDirections(response);
	        }
	    });
	}
	
	initMap();
</script>
<%@ include file="/common/include/bottom.jsp" %>
</body>
</html>