<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<script type="text/javascript"> try {document.execCommand('BackgroundImageCache', false, true);} catch(e) {}</script>
<script type="text/javascript" src="http://openapi.map.naver.com/openapi/v2/maps.js?clientId=OUm_ZFDvz2sWswi9UP4t"></script>
<title>WMS</title>
<%@ include file="/common/include/head.jsp" %>
<script type="text/javascript">
	$(document).ready(function(){
		searcMap("37.510933","127.123925")
	});

	function searchList(){
		var param = new DataMap();
		var addr = $('.addr').val();
		param.put("addr",addr);
		
		var json = netUtil.sendData({
			id : "gridList",
			url : "/geocoding/input/json/naverMap.data",
			sendType : "map",		
		    param : param
		});

		if(json.SHPLAT == null && json.SHPLON == null){		
			commonUtil.msgBox("TMS_T0008");
			$('.addr').focus();
		}else{
			var Lat = json.SHPLAT;
            var Lng = json.SHPLON;			
			$('.shplat').val(json.SHPLAT);
			$('.shplon').val(json.SHPLON);
			searcMap(Lat,Lng);
		}
	}
	
 	function saveData(){
 		
	}


	function commonBtnClick(btnName){
		//commonUtil.debugMsg("commonBtnClick : ", arguments);
		if(btnName == "Search"){
			searchList();
		}else if(btnName == "Save"){
			saveData();
		}
	}
	
	
	$(function(){
	    var atms =[
	         {"code":"1","x_grid":"37.5098753","y_grid":"127.0527883","addr":"서울특별시 강남구 삼성동 125"},
	         {"code":"2","x_grid":"37.3661469","y_grid":"127.1066311","addr":"경기도성남시정자1동25-1"},
	         {"code":"3","x_grid":"35.1601803","y_grid":"129.1652071","addr":"부산 해운대구 중동 1408-5"}
	    ]
	    $('select#comboAdd').on('change', function() {
	        var thisCode = $(this).val();
	        var Lat,Lng;
	        for(var i in atms){
	            if(atms[i].code == thisCode){
	                var Lat = atms[i].x_grid;
	                var Lng = atms[i].y_grid;
	                searcMap(Lat,Lng);        
	            }
	        } 
	    });
	});

	function searcMap (Lat,Lng) {
	    $("#map").html();
	    $("#map").html("");
	    var oPoint = new nhn.api.map.LatLng(Lat,Lng);
	    nhn.api.map.setDefaultPoint('LatLng');

	    oMap = new nhn.api.map.Map('map', {
	        point : oPoint,
	        zoom : 10, // - 초기 줌 레벨은 10으로 둔다.
	        enableWheelZoom : false,
	        enableDragPan : true,
	        enableDblClickZoom : false,
	        mapMode : 0,
	        activateTrafficMap : false,
	        activateBicycleMap : false,
	        minMaxLevel : [ 1, 14 ],
	        size : new nhn.api.map.Size(700, 500)
	    });
/* 
	    //고정 주소  마커 표시
        var oSize = new nhn.api.map.Size(28, 37);
	    var oOffset = new nhn.api.map.Size(14, 37);
	    var oIcon = new nhn.api.map.Icon('http://static.naver.com/maps2/icons/pin_spot2.png', oSize, oOffset);
	    var oMarker = new nhn.api.map.Marker(oIcon, { title : '마커 : ' + oPoint.toString() });
	    oMarker.setPoint(oPoint);
	    oMap.addOverlay(oMarker);
	     */
	    
	    //좌표 값 찾기, 마커 표시
        var markerCount = 0;
        var oSize = new nhn.api.map.Size(28, 37);
        var oOffset = new nhn.api.map.Size(14, 37);
        var oIcon = new nhn.api.map.Icon('http://static.naver.com/maps2/icons/pin_spot2.png', oSize, oOffset);
        var mapInfoTestWindow = new nhn.api.map.InfoWindow(); // - info window 생성
        var oLabel = new nhn.api.map.MarkerLabel();           // - 마커 라벨 선언.
        mapInfoTestWindow.setVisible(false);                  // - infowindow 표시 여부 지정.
        oMap.addOverlay(mapInfoTestWindow);                   // - 지도에 추가.     
        oMap.addOverlay(oLabel);                              // - 마커 라벨 지도에 추가.

        mapInfoTestWindow.attach('changeVisible', function(oCustomEvent) {
        	if (oCustomEvent.visible) { oLabel.setVisible(false); }
        });

        oMap.attach('mouseenter', function(oCustomEvent) {
	        var oTarget = oCustomEvent.target;
	        if (oTarget instanceof nhn.api.map.Marker) { // 마커위에 마우스 올라간거면
	         var oMarker = oTarget;
	         oLabel.setVisible(true, oMarker);           // - 특정 마커를 지정하여 해당 마커의 title을 보여준다.
	        }
        });

        oMap.attach('mouseleave', function(oCustomEvent) {
	        var oTarget = oCustomEvent.target;            
	        if (oTarget instanceof nhn.api.map.Marker) { oLabel.setVisible(false); } // 마커위에서 마우스 나간거면
        });

        oMap.attach('click', function(oCustomEvent) {
	        var oPoint = oCustomEvent.point;
	        var oTarget = oCustomEvent.target;
	        mapInfoTestWindow.setVisible(false);
	        if (oTarget instanceof nhn.api.map.Marker) {          // 마커 클릭하면
		        if (oCustomEvent.clickCoveredMarker) { return; }  // 겹침 마커 클릭한거면
		        mapInfoTestWindow.setContent('<DIV style="border-top:1px solid; border-bottom:2px groove black; border-left:1px solid; border-right:2px groove black;margin-bottom:1px;color:black;background-color:white; width:auto; height:auto;">'+
		        '<span style="color: #000000 !important;display: inline-block;font-size: 12px !important;font-weight: bold !important;letter-spacing: -1px !important;white-space: nowrap !important; padding: 2px 2px 2px 2px !important">' + 
		        '좌표(Y,X) <br /> ' + oTarget.getPoint() +'<span></div>');
		        mapInfoTestWindow.setPoint(oTarget.getPoint());
		        mapInfoTestWindow.setVisible(true);
		        mapInfoTestWindow.setPosition({right : 15, top : 30});
		        mapInfoTestWindow.autoPosition();
		        return;
	        }
	        var oMarker = new nhn.api.map.Marker(oIcon, { title : '마커 : ' + oPoint.toString() });
	        oMarker.setPoint(oPoint);
	        oMap.clearOverlay(); //마커 초기화
	        oMap.addOverlay(oMarker);
	
	        var Lat,Lng;
	        Lat = oPoint.getLat(); Lng = oPoint.getLng();
	        $('.Lat').val(Lat);  
	        $('.Lng').val(Lng); 

        });	    

	}

	

</script>
</head>
<body>
<div class="contentHeader">
	<div class="util">
		<button CB="Search SEARCH BTN_DISPLAY">
		</button>
		<button CB="Save SAVE STD_SAVE">
		</button>	
	</div>
</div>


<!-- content -->
<div class="content">
	<div class="innerContainer">
		<!-- contentContainer -->
		<div class="contentContainer">
			<div class="bottomSect type1">
				<div class="tabs">
					<ul class="tab type2">
						<li><a href="#tabs1-1"><span>탭메뉴1</span></a></li>
					</ul>
					<div id="tabs1-1">
			            <label for="comboAdd">주소</label>
			            <select id="comboAdd">				
			                <option>주소를 선택해 주세요</option>
			                <option value="1">서울특별시 강남구 삼성동 125</option>
			                <option value="2">경기도성남시정자1동25-1</option>
			                <option value="3">부산 해운대구 중동 1408-5</option>
			            </select>
			            <label for="point">위경도</label><input class="Lat" type="text"><input class="Lng" type="text"><P>
			            <label for="addr">주소입력</label><input class="addr" type="text"><button type="button" class="btn_find" title="업종검색" onclick="searchList(); return false;"><span>검색</span></button>
			            <label for="point">위경도</label><input class="shplat" type="text"> <input class="shplon" type="text">

						<div id = "map" style="border:1px solid #000; width:700px; height:500px; margin:20px;"></div>

					    </div>
				    </div>
				</div>
			</div>
		</div>
		<!-- //contentContainer -->
	</div>
</div>
<!-- //content -->
<%@ include file="/common/include/bottom.jsp" %>
</body>
</html>