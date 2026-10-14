<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%><!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<title>TMS</title>  
</head>
<body>
<div id="map" style="width:100%;height:350px;"></div>

<!--script                        src="http://apis.daum.net/maps/maps3.js?apikey=07fc774fb6578f1d0b38b30469616c14&libraries=services,clusterer"></script-->
<script src="http://apis.daum.net/maps/maps3.js?apikey=07fc774fb6578f1d0b38b30469616c14&libraries=services,clusterer"></script>
<script>
var mapContainer = document.getElementById('map'), // 지도를 표시할 div  
    mapOption = { 
        center: new daum.maps.LatLng(33.450701, 126.570667), // 지도의 중심좌표
        level: 3 // 지도의 확대 레벨
    };

var map = new daum.maps.Map(mapContainer, mapOption); // 지도를 생성합니다
 
// 마커를 표시할 위치와 title 객체 배열입니다 
var positions = [
    {
        title: '카카오', 
        latlng: new daum.maps.LatLng(33.450705, 126.570677)
    },
    {
        title: '생태연못', 
        latlng: new daum.maps.LatLng(33.450936, 126.569477)
    },
    {
        title: '텃밭', 
        latlng: new daum.maps.LatLng(33.450879, 126.569940)
    },
    {
        title: '근린공원',
        latlng: new daum.maps.LatLng(33.451393, 126.570738)
    }
];

// 마커 이미지의 이미지 주소입니다
var imageSrc = "http://i1.daumcdn.net/localimg/localimages/07/mapapidoc/markerStar.png"; 

//출발이미지.
var startSrc = 'http://i1.daumcdn.net/localimg/localimages/07/mapapidoc/red_b.png', // 출발 마커이미지의 주소입니다    
startSize = new daum.maps.Size(50, 45), // 출발 마커이미지의 크기입니다 
startOption = { 
    offset: new daum.maps.Point(15, 43) // 출발 마커이미지에서 마커의 좌표에 일치시킬 좌표를 설정합니다 (기본값은 이미지의 가운데 아래입니다)
};

//도착이미지.
var arriveSrc = 'http://i1.daumcdn.net/localimg/localimages/07/mapapidoc/blue_b.png', // 도착 마커이미지 주소입니다    
arriveSize = new daum.maps.Size(50, 45), // 도착 마커이미지의 크기입니다 
arriveOption = { 
    offset: new daum.maps.Point(15, 43) // 도착 마커이미지에서 마커의 좌표에 일치시킬 좌표를 설정합니다 (기본값은 이미지의 가운데 아래입니다)
};

for (var i = 0; i < positions.length; i ++) {
    
    // 마커 이미지의 이미지 크기 입니다
    var imageSize = new daum.maps.Size(24, 35); 
    
    // 마커 이미지를 생성합니다    
    var markerImage = new daum.maps.MarkerImage(imageSrc, imageSize); 
    
    if( i == 0){
    	// 출발 마커 이미지를 생성합니다
    	markerImage = new daum.maps.MarkerImage(startSrc, startSize, startOption);	
    }else if( i == positions.length-1){
    	// 출발 마커 이미지를 생성합니다
    	markerImage = new daum.maps.MarkerImage(arriveSrc, arriveSize, arriveOption);	
    }
    
    // 마커를 생성합니다
    var marker = new daum.maps.Marker({
        map: map, // 마커를 표시할 지도
        position: positions[i].latlng, // 마커를 표시할 위치
        title : positions[i].title, // 마커의 타이틀, 마커에 마우스를 올리면 타이틀이 표시됩니다
        image : markerImage // 마커 이미지 
    });
}

//길찾기 화면으로 자동이동.
window.location.href="http://map.daum.net/?sX=506357&sY=1111303&sName=test출발지&eX=506319&eY=1111390&eName=Baekeok+HANU";
</script>
<a href="http://map.daum.net/link/to/카카오판교오피스,37.402056,127.108212">http://map.daum.net/link/to/카카오판교오피스,37.402056,127.108212</a>
</body>
</html>

