<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!doctype html>
<html lang="ko">
<head>
<meta charset="utf-8">
<!-- <meta http-equiv="X-UA-Compatible" content="IE=EmulateIE7"> -->
<title>TMS</title> 
<%@ include file="/common/include/head.jsp" %>
<!-- script src="https://maps.googleapis.com/maps/api/js?v=3.exp&sensor=false&key=AIzaSyATTSjgG0Qu-e3zW2gJ0R2HZu-JmjF6mi0" type="text/javascript"></script-->
</head>
<body>
<!-- content -->
 
<!-- maps -->
 
	<style type="text/css">
		 
		#map-canvas, #map_canvas {
		 position:  relative;
		 width:100%;  
		 height: 500px;
		}
 
		#panel_map {
		  position:  relative;		 		 
		  z-index: 5;
		  background-color: #fff;
		  padding: 5px;
		
		}
	</style>

	<script src="https://maps.googleapis.com/maps/api/js?v=3.exp&sensor=false"></script>
	<script>
	var directionsDisplay;
	var directionsService = new google.maps.DirectionsService();
	var map;

	function initialize() {
	  directionsDisplay = new google.maps.DirectionsRenderer();
	  
	  var seoul = new google.maps.LatLng(41.850033, -87.6500523);
	  
	  var mapOptions = {
		zoom:7,
		mapTypeId: google.maps.MapTypeId.ROADMAP,
		center: seoul
	  }
	  map = new google.maps.Map(document.getElementById('map-canvas'), mapOptions);
	  directionsDisplay.setMap(map);
	  
	  directionsDisplay.setPanel(document.getElementById('directionsPanel'));
	  google.maps.event.addListener(directionsDisplay, 'directions_changed', function() {
		computeTotalDistance(directionsDisplay.getDirections());
	  });
		 
	  $("#start_map").val("서울역"); 
	  $("#end_map").val("대구"); 
	  $("#end_map_2").val("울산");  

	  var start = document.getElementById('start_map').value;
	  var end = document.getElementById('end_map').value;
	  var end_2 = document.getElementById('end_map_2').value;
	  //calcRoute(start, end); 
	  //calcRoute(end, end_2);

	  /*
	    "Person 1": ["서울역", "부산" ],
	    "Person 2": ["부산", "울산"],
	    "Person 3": ["울산","대구"],
	    "Person 4": ["대구","상주"],
	    "Person 5": ["상주","구미"],
	    "Person 6": ["구미","대전"],
	    "Person 7": ["대전","광주"]
	  */
	  calcRoute("서울역", "대전");
	  calcRoute("대전","대구");
	  calcRoute("대구","상주");
	  calcRoute("상주","구미");
	  calcRoute("구미","울산");
	  calcRoute("울산","광주"); 
	}

	function calcRoute(_start, _end) {
	  var mode = document.getElementById('mode').value;

	  var request = {
		  origin:_start,
		  destination:_end,
		  travelMode: eval("google.maps.DirectionsTravelMode."+mode)
	  };
	  directionsService.route(request, 
			  /**
			  function(response, status) {
				//alert(status);  // 확인용 Alert..미사용시 삭제
				if (status == google.maps.DirectionsStatus.OK) {
					directionsDisplay.setDirections(response);
				}
			  }
	 		 **/
	 		 /**/
	 		 function(result) {
		       renderDirections(result);
		     }/**/
		     
		     /*
			  function(result, status) {
			    if (status == google.maps.DirectionsStatus.OK)
	            {
	                directionsDisplay.setDirections (result);
	                pointsArray = result.routes[0].overview_path;

	                var i = 0;
	                var j = 0;

	                for (j = 0; j < pointsArray.length; j++)
	                {
	                    var point1 = new google.maps.Marker ({
	                                                    position:pointsArray [j],
	                                                    draggable:false,
	                                                    map:map,
	                                                    flat:true
	                                                    });
	                }
	            }
		  	 }
		     */
	  );
	}
	
	
	function computeTotalDistance(result) {
	  var total = 0;
	  var myroute = result.routes[0];
	  for (var i = 0; i < myroute.legs.length; i++) {
		total += myroute.legs[i].distance.value;
	  }
	  total = total / 1000.0;
	  document.getElementById('total').innerHTML = total + ' km';
	}
	
	function renderDirections(result) {
	  var directionsRenderer = new google.maps.DirectionsRenderer;
	  directionsRenderer.setMap(map);
	  directionsRenderer.setDirections(result);
	  
	  /*
      pointsArray = result.routes[0].overview_path;

      var i = 0;
      var j = 0;

      for (j = 0; j < pointsArray.length; j++)
      {
          var point1 = new google.maps.Marker ({
                                          position:pointsArray [j],
                                          draggable:false,
                                          map:map,
                                          flat:true
                                          });
      }
      */
      
	}
	

	</script>



<div id="panel_map" >
			<b>Start: </b>
			<input type="text" id="start_map" />
			<b>mid: </b>
			<input type="text" id="end_map" />
			<b>End: </b>
			<input type="text" id="end_map_2" />
			<div>
				<strong>Mode of Travel: </strong>
				<select id="mode">
				<option value="DRIVING">Driving</option>
				<option value="WALKING">Walking</option>
				<option value="BICYCLING">Bicycling</option>
				<option value="TRANSIT" selected="selected">Transit</option>
				</select>
				<input type="button" value="길찾기" onclick="Javascript:calcRoute();" />
			</div>
</div>

<div id="map-canvas"></div>

<div id="directionsPanel" style=" display:block;  ">
<p>총 거리 : <span id="total"></span></p>



<!-- maps -->
<!-- //content -->
<script type="text/javascript"> 
	  $( document ).ready(function() { 
	    google.maps.event.addDomListener(window, 'load', initialize); 
	  });
</script>
 
 
<!-- All of the script for multiple requests -->
<script type="text/javascript">

//Initialise some variables
var directionsService = new google.maps.DirectionsService();
var num, map, data;
var requestArray = [], renderArray = [];

// A JSON Array containing some people/routes and the destinations/stops
var jsonArray = { 
    "Person 1": ["서울역", "부산" ],
    "Person 2": ["부산", "울산"],
    "Person 3": ["울산","대구"],
    "Person 4": ["대구","상주"],
    "Person 5": ["상주","구미"],
    "Person 6": ["구미","대전"],
    "Person 7": ["대전","광주"]
}
    
// 16 Standard Colours for navigation polylines
var colourArray = ['navy', 'grey', 'fuchsia', 'black', 'white', 'lime', 'maroon', 'purple', 'aqua', 'red', 'green', 'silver', 'olive', 'blue', 'yellow', 'teal'];

// Let's make an array of requests which will become individual polylines on the map.
function generateRequests(){

    requestArray = [];

    for (var route in jsonArray){
        // This now deals with one of the people / routes

        // Somewhere to store the wayoints
        var waypts = [];
        
        // 'start' and 'finish' will be the routes origin and destination
        var start, finish
        
        // lastpoint is used to ensure that duplicate waypoints are stripped
        var lastpoint

        data = jsonArray[route]

        limit = data.length
        for (var waypoint = 0; waypoint < limit; waypoint++) {
            if (data[waypoint] === lastpoint){
                // Duplicate of of the last waypoint - don't bother
                continue;
            }
            
            // Prepare the lastpoint for the next loop
            lastpoint = data[waypoint]

            // Add this to waypoint to the array for making the request
            waypts.push({
                location: data[waypoint],
                stopover: true
            });
        }

        // Grab the first waypoint for the 'start' location
        start = (waypts.shift()).location;
        // Grab the last waypoint for use as a 'finish' location
        finish = waypts.pop();
        if(finish === undefined){
            // Unless there was no finish location for some reason?
            finish = start;
        } else {
            finish = finish.location;
        }

        // Let's create the Google Maps request object
        var request = {
            origin: start,
            destination: finish,
            waypoints: waypts,
            travelMode: google.maps.TravelMode.TRANSIT  //DRIVING
        };

        // and save it in our requestArray
        requestArray.push({"route": route, "request": request});
    }

    processRequests();
}

function processRequests(){

    // Counter to track request submission and process one at a time;
    var i = 0;

    // Used to submit the request 'i'
    function submitRequest(){
        directionsService.route(requestArray[i].request, directionResults);
    }

    // Used as callback for the above request for current 'i'
    function directionResults(result, status) {
        if (status == google.maps.DirectionsStatus.OK) {
            
            // Create a unique DirectionsRenderer 'i'
            renderArray[i] = new google.maps.DirectionsRenderer();
            renderArray[i].setMap(map);

            // Some unique options from the colorArray so we can see the routes
            renderArray[i].setOptions({
                preserveViewport: true,
                suppressInfoWindows: true,
                polylineOptions: {
                    strokeWeight: 4,
                    strokeOpacity: 0.8,
                    strokeColor: colourArray[i]
                },
                markerOptions:{
                    icon:{
                        path: google.maps.SymbolPath.BACKWARD_CLOSED_ARROW,
                        scale: 3,
                        strokeColor: colourArray[i]
                    }
                }
            });

            // Use this new renderer with the result
            renderArray[i].setDirections(result);
            // and start the next request
            nextRequest();
        }

    }

    function nextRequest(){
        // Increase the counter
        i++;
        // Make sure we are still waiting for a request
        if(i >= requestArray.length){
            // No more to do
            return;
        }
        // Submit another request
        submitRequest();
    }

    // This request is just to kick start the whole process
    submitRequest();
}

// Called Onload
function init() {

    // Some basic map setup (from the API docs) 
    var mapOptions = {
        center: new google.maps.LatLng(37.76638086,128.8829475),
        zoom: 8,
        mapTypeControl: false,
        streetViewControl: false,
        mapTypeId: google.maps.MapTypeId.ROADMAP
    };
        
    map = new google.maps.Map(document.getElementById('map-canvas'), mapOptions);

    // Start the request making
    generateRequests()
}
 
//$( document ).ready(function() { 
//	// Get the ball rolling and trigger our init() on 'load'
//	  google.maps.event.addDomListener(window, 'load', init); 
//  });
</script>

<%@ include file="/common/include/bottom.jsp" %>
</body>
</html>