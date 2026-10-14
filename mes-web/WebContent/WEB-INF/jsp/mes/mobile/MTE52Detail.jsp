<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<meta name="viewport" content="user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, width=device-width, target-densitydpi=medium-dpi" />
<meta name="format-detection" content="telephone=no" />
<title>WMS</title>
<%@ include file="/mobile/include/tmsHead.jsp" %>
<style type='text/css'>

html, body {
    width: 100%;
    height: 100%;
} 

.filebox{background:#000055;color:#fff;font-weight:bold}

.camerafilebox label {
  display: inline-block; 
}
.camerafilebox input[type="file"] {  /* 파일 필드 숨기기 */
  position: absolute;
  width: 1px;
  height: 1px;
  padding: 0;
  margin: -1px;
  overflow: hidden;
  clip:rect(0,0,0,0);
  border: 0;
}
</style>
<!-- 지도API -->
 <script charset='UTF-8' src='http://vapi.dawulmap.com:8000/MapAppServer/DWService?req={%22header%22:{%22format%22:%22JSON%22,%22key%22:%229c9d6f40dcc67734b5f98e633391b224c1fe1bdf%22,%22serviceName%22:%22SDK_REQ%22},%22body%22:{%22sdkType%22:%22AJAX%22,%22version%22:%222.0%22}}}'></script>

<script type="text/javascript"> 
//좌표변환
var Coord_Trans = function(param1, param2){
  initCS(param1.toLowerCase());
  cs_transform(csLeft, csRight, param2);
  return param2;
}

var map = null;
var miniMap = null;
var init = function() {
	map = L.map('map', {
		continuousWorld : true,
		zoomControl : true,
		zoomAnimation : true,
		fadeAnimation : true,
		inertia : true
	});
	map.setView([ 37.5166494, 127.2024799 ], 10);
	BaseMapChange(map, L.Dawul.BASEMAP_GEN);
}//init

function openMap(){
	$("#detailInfo").hide();

	var codex = gridList.getColData("gridSubList", 0, "COORDX");
	var codey = gridList.getColData("gridSubList", 0, "COORDY");
	setPoint(codex, codey);
	$("#map").show();
	$("#map_foot").show();

	
}	

//마커 표현 및 툴팁 샘플
function setPoint(codex, codey) {

	mkClear();
	map.setView([ codey, codex ], 12); // 지도 위치 이동 (좌표, 지도 레벨)
	marker = new L.Marker(new L.LatLng(codey, codex), {
		icon : new L.Icon({ // 마커 찍기
			iconUrl : "/common/images/pin_1.png", // 핀 이미지
			iconAnchor : [ 0, 0 ], // 오프셋 (핀의 끝이 좌표로 매칭하기 위해 적용)
		})
	}).addTo(map);
	var content = "배송지";
	marker.bindPopup(mkContent(content), {
		minWidth : 20,
		offset : [ 0, -30 ]
	});
}	
    var searchType = false;
    $(document).ready(function(){ 
    	init();
         gridList.setGrid({
            id : "gridSubList",
            editable : true,
            module : "WmsMobile",
            command : "TE52POP",
            gridMobileType : true
        });
    });
     
    var subchk = 0;

    function searchList(){
		parent.searchList();
    }
    
    var $telObj;

    function searchSubList(){
    	
    	alert("searchSubList()");
        var param = dataBind.paramData("itemArea");
        var param_detail = parent.getData();
        alert(param_detail);
        gridList.gridList({
            id : "gridSubList",
            param : param_detail
        });
    }
    
 	function gridListEventDataBindEnd(gridId, dataLength){
        var telNo = gridList.getColData("gridSubList", 0, "SHIPTN");
         		$telObj = $("#telNo");
                $telObj.attr("href","tel:"+telNo);
                $telObj.text(telNo);

                var shipad = gridList.getColData("gridSubList", 0, "SHIPAD");
                var shipad1 = gridList.getColData("gridSubList", 0, "SHIPAD1");
                var shipad2 = gridList.getColData("gridSubList", 0, "SHIPAD2");
                var shipad3 = gridList.getColData("gridSubList", 0, "SHIPAD3");
                var shipnm = gridList.getColData("gridSubList", 0, "SHIPNM");
                var coordx = gridList.getColData("gridSubList", 0, "COORDX");
                var coordy = gridList.getColData("gridSubList", 0, "COORDY");
                var usarg1 = gridList.getColData("gridSubList", 0, "USARG1");
                var usarg2 = gridList.getColData("gridSubList", 0, "USARG2");
                var csalrm = gridList.getColData("gridSubList", 0, "CSALRM");
                var csspec = gridList.getColData("gridSubList", 0, "CSSPEC");
                var csstar = gridList.getColData("gridSubList", 0, "CSSTAR");
                var cspass = gridList.getColData("gridSubList", 0, "CSPASS");
                var shipct = gridList.getColData("gridSubList", 0, "SHIPCT");
                var rqshpd = gridList.getColData("gridSubList", 0, "RQSHPD");
                var driver = gridList.getColData("gridSubList", 0, "DRIVER");
                var name01 = gridList.getColData("gridSubList", 0, "NAME01");
                $("#SHIPAD").text(shipad);
                $("#SHIPAD1").text(shipad1);
                $("#SHIPAD2").text(shipad2);
                $("#SHIPAD3").text(shipad3);
                $("#SHIPNM").text(shipnm);
                $("#COORDX").text(coordx);
                $("#COORDY").text(coordy);
                $("#USARG1").text(usarg1);
                $("#USARG2").text(usarg2);
                $("#CSALRM").text(csalrm);
                $("#CSSPEC").text(csspec);
                $("#CSSTAR").text(csstar);
                $("#CSPASS").text(cspass);
                $("#SHIPCT").text(shipct);
                $("#RQSHPD").text(rqshpd);
                $("#DRIVER").text(driver);
                $("#NAME01").text(name01);
                
                $("#main").hide();
                $("#map").hide();
                $("#map_foot").hide();
                $("#detailInfo").show();
                $("#noticeInfo").hide();
                
 	}

    function Clear(){
        //var list = gridList.getModifyList("gridSubList", "A");
        var list = gridList.getGridData("gridSubList");
        
        var param = dataBind.paramData("itemArea");
        
        var rsncod = gridList.getColData("gridSubList", 0, "RSNCOD");
        var tcheck = gridList.getColData("gridSubList", 0, "UPDCHK");
        //var chkpic = gridList.getColData("gridSubList", 0, "INDBZL");
        var chkpic =  document.form.camera.value;
/*      if(tcheck =="1") {
            alert("이미 작업진행하셨습니다");
            return;
        }
 */
        if(chkpic == " " || chkpic == "") {
            alert("사진촬영을 먼저 해주십시요.");
            return;
        }
/*         if(rsncod == "" || rsncod != "V"){
            alert("배송상태를 V로 체크해주십시요.")
            return;
        } */
        
        //var codex = $("#COORDX").val;
        //var codey = $("#COORDY").val;
        var codex = gridList.getColData("gridSubList", 0, "COORDX");
        var codey = gridList.getColData("gridSubList", 0, "COORDY");
        var codex1;
        var codey1;
        
        
        //var gps = parent.$("#gpsinfo").val();
        var gps = parent.getGps();;
        if(gps.indexOf(",")>-1){
            var gpsArr = gps.split(",")
            var gpsArr1 = gpsArr[0].split(":");
            var gpsArr2 = gpsArr[1].split(":");
            if(gpsArr[0].indexOf("latitude")>-1){
                codex1 = gpsArr2[1].substring(0,6);
                codey1 = gpsArr1[1].substring(0,5);
            }else{
                codey1 = gpsArr2[1].substring(0,6);
                codex1 = gpsArr1[1].substring(0,5);
            }
        }
        //var usarg1 = $("#USARG1").val();
        //var usarg2 = $("#USARG2").val();

        var usarg1 = gridList.getColData("gridSubList", 0, "USARG1");
        var usarg2 = gridList.getColData("gridSubList", 0, "USARG2");
        
        Coord_Trans("wgstoutmk", new PT(codex1, codey1));
        var p = Coord_Trans("wgstoutmk", new PT(codex, codey));
        var p1 = Coord_Trans("wgstoutmk", new PT(codex1, codey1));
                  
        var calc = Math.sqrt(Math.pow((p.x - p1.x),2) + Math.pow((p.y - p1.y),2)); //거리구하기
        
        var shiptn = gridList.getColData("gridSubList", 0, "SHIPTN");
        var shipnm = gridList.getColData("gridSubList", 0, "SHIPNM");
        var vhpord = gridList.getColData("gridSubList", 0, "VHPORD");
        var driver = gridList.getColData("gridSubList", 0, "DRIVER");
        var shipky = gridList.getColData("gridSubList", 0, "SHIPKY");
        var rqshpd = gridList.getColData("gridSubList", 0, "RQSHPD");
        var name01 = gridList.getColData("gridSubList", 0, "NAME01");
        //var uuid = $("#UUID").val();
        var sdtime = "201512231800";
        document.form.SHIPTN.value = shiptn;
        document.form.SHIPNM.value = shipnm;
        document.form.VHPORD.value = vhpord;
        document.form.DRIVER.value = driver;
        //document.form.DRIVER.value = "1";
        document.form.SFTYPE.value = "0";
        document.form.RSNCOD.value = "V";
        document.form.RQSHPD.value = rqshpd;
        document.form.SDTIME.value = sdtime;
        document.form.NAME01.value = name01;

        
        param.put("list",list);
        param.put("SHIPTN",shiptn);
        param.put("SHIPKY",shipky);
        //calc = 100;
        if(calc > usarg1 && calc < usarg2){
         	var json = netUtil.sendData({
                url : "/wms/outbound/json/TE52POPSave.data",
                param : param
            });

 			$("#saveForm").submit();

        }else{
            alert("현재 위치와 주소지가 일치하지 않습니다!!.")
            var json = netUtil.sendData({
               url : "/wms/outbound/json/TE52POPHold.data",
               param : param
           	});
            
            $("#saveForm").submit();
        }
    }
    
    function Fail(){
        var list = gridList.getModifyList("gridSubList", "A");
        
        var param = dataBind.paramData("itemArea");
        
        var rsncod = gridList.getColData("gridSubList", 0, "RSNCOD");
        var tcheck = gridList.getColData("gridSubList", 0, "UPDCHK");
        if(rsncod == "00" || rsncod == ' ' || rsncod == "V"){
            alert("V를 제외한 미배송사유를 체크해주십시요.")
            return;
        }
/*      if(tcheck =="1") {
            alert("이미 작업진행하셨습니다");
            return;
        } */
        var chkpic =  document.form.camera.value;
        if(chkpic == " " || chkpic == "") {
            alert("사진촬영을 먼저 해주십시요.");
            return;
        }        

        var rsntxt = jQuery.trim($("#RSNTXT").val());

        if(rsncod == "60") {
        	if(rsntxt == '' || rsntxt == null){
        		$("#RSNTXT").focus();
                $("#RSNTXT").select();
        		alert("기타 사유내용을 사유내용란에 입력해주십시요.");        		
        		return;
        	}
        }else{
        	rsntxt = " ";
        }
        var shiptn = gridList.getColData("gridSubList", 0, "SHIPTN");
        var shipnm = gridList.getColData("gridSubList", 0, "SHIPNM");
        var vhpord = gridList.getColData("gridSubList", 0, "VHPORD");
        var driver = gridList.getColData("gridSubList", 0, "DRIVER");
        var shipky = gridList.getColData("gridSubList", 0, "SHIPKY");
        var rqshpd = gridList.getColData("gridSubList", 0, "RQSHPD");
        var name01 = gridList.getColData("gridSubList", 0, "NAME01");
//var uuid = $("#UUID").val();

		var sdtime = "201512231800";
        document.form.SHIPTN.value = shiptn;
        document.form.SHIPNM.value = shipnm;
        document.form.VHPORD.value = vhpord;
        document.form.DRIVER.value = driver;
        //document.form.DRIVER.value = "1";
        document.form.RSNCOD.value = rsncod;
        document.form.SFTYPE.value = "1";
        document.form.RQSHPD.value = rqshpd;
        document.form.SDTIME.value = sdtime;
        document.form.RSNTXT.value = rsntxt;
        document.form.NAME01.value = name01;

        param.put("list",list);
        
        param.put("RSNTXT", rsntxt); //20151221
        
        var json = netUtil.sendData({
            url : "/wms/outbound/json/TE52POPFail.data",
            param : param
        });

        $("#saveForm").submit();
        
    }
    
    function changeRSN() {
        var rsncod = $("#RSNCOD").val();
		var subCnt = gridList.getGridDataCount("gridSubList");
 		for(var i = 0; i < subCnt; i++){
	 		gridList.setColValue("gridSubList", i, "RSNCOD", rsncod);
	 		if(i==subCnt-1){
	 			return;
	 		}
 		}		
	}
	
</script>
</head>
 <body> 
 	<div id='map' style="width: 100%; height: 90%; margin:auto; overflow:hidden; ">
	</div>
 	<div id="map_foot" class="footer_5" style="height: 10%; margin:auto;">
		<table>
			<tr>
				<td onclick="searchSubList()">닫기</td>
			</tr>
		</table>
	</div>

 <form action="/mobile/image/fileUp/sendMessage.data" enctype="multipart/form-data" method="post" id="saveForm" name="form">
    <div class="detailInfo_wrap" id="detailInfo">
        <h2 class="info_title">상세정보</h2>
        <div class="d_table_wrap">
            <div id="itemArea">
            
                <div class="tableWrap_search section" >
                    <div class="tableHeader">
                        <table>
                            <colgroup>
                                <col width="10%" />
                                <col width="35%" />
                                <col width="15%" />
                                <col width="20%" />
                                <col width="20%" />
                                <col width="0%" />
                            </colgroup>
                            <thead>
                                <tr>
                                    <th CL="STD_NUMBER"></th>
                                    <th CL='STD_VHPORD'></th>
                                    <th CL="STD_TEMPER"></th>
                                    <th CL="STD_VHPCHK"></th>
                                    <th CL="STD_VHFSTS"></th>
                                    <th CL="STD_TCHECK" style="display:none"></th>
                                </tr>
                            </thead>
                        </table>
                    </div>
                    <div class="tableBody">
                        <table>
                            <colgroup>
                                <col width="10%" />
                                <col width="35%" />
                                <col width="15%" />
                                <col width="20%" />
                                <col width="20%" />
                                <col width="0%" />
                            </colgroup>
                            <tbody id="gridSubList">
                                <tr CGRow="true" >
                                    <td GCol="rownum"></td>
                                    <td GCol="text,VHPORD"></td>
                                    <td GCol="text,TEMPER"></td>
                                    <td GCol="select,RSNCOD">
                                        <select name="RSNCOD" onChange="changeRSN()" id="RSNCOD">
                                            <option value="00">선택</option>
                                            <option value="10">공동현관(세대현관)비밀번호 오류</option>
                                            <option value="20">공동현관(세대현관)미기재</option>
                                            <option value="30">통화불가(통화요청 고객)</option>
                                            <option value="40">경비원 부재 시</option>
                                            <option value="50">배송지(주소) 오류</option>
                                            <option value="60">기타 입력</option>
                                            <option value="V">V</option>
                                        </select>
                                    </td> 
                                    <td GCol="text,VHFSTS"></td>                                                
                                    <td GCol="text,UPDCHK" style="display:none"></td>                                                
                                </tr>
                            </tbody>
                        </table>
                    </div>
            	</div>
            	<div class="info_table_wrap">       
                	<table class="info_table">
	                    <colgroup>
	                        <col width="35%"/>
	                        <col width="65%"/>
	                    </colgroup>
                        <tbody>
                        	<tr>
                                <th CL='STD_CSALRM'></th>
                                <td  name="CSALRM" id="CSALRM">
                                </td>
                            </tr>
                            <tr>
                                <th CL='STD_CSSPEC'></th>
                                <td name="CSSPEC"  id="CSSPEC">
                                </td>
                            </tr>
                            <tr>
                                <th CL='STD_SHIPCT'></th>
                                <td  name="SHIPCT"  id="SHIPCT">
                                </td>
                            </tr>
                            <tr>
                                <th CL='STD_CSPASS'></th>
                                <td  name="CSPASS"  id="CSPASS">
                                </td>
                            </tr>
                            <tr>
                                <th CL='STD_CSSTAR'></th>
                                <td  name="CSSTAR"  id="CSSTAR">
                                </td>
                            </tr>
                            <tr>
                                <th CL='STD_SHIPAD'></th>
                                <td name="SHIPAD" id="SHIPAD">
                                </td>
                            </tr>
                            <tr>
                                <th CL='STD_SHIPAD1'></th>
                                <td  name="SHIPAD1" id="SHIPAD1">
                                </td>
                            </tr>
                            <tr>
                                <th></th>
                                <td><input type="button" value="지도보기" class="bt" onclick="openMap()"/>
                                </td>
                            </tr>
                            <tr>
                                <th CL='STD_SHIPAD2'></th>
                                <td  name="SHIPAD2"  id="SHIPAD2">
                                </td>
                            </tr>
                            <tr>
                                <th CL='STD_SHIPAD3'></th>
                                <td  name="SHIPAD3"  id="SHIPAD3">
                                </td>
                            </tr>
                            <tr style="display:none">
                                <th CL='STD_COORDX'></th>
                                <td  name="COORDX"  id="COORDX">
                                </td>
                            </tr>
                            <tr style="display:none">
                                <th CL='STD_COORDY'></th>
                                <td  name="COORDY"  id="COORDY">
                                </td>
                            </tr>
                            <tr style="display:none">
                                <th CL='STD_USARG1'></th>
                                <td  name="USARG1"  id="USARG1">
                                </td>
                            </tr>
                            <tr style="display:none">
                                <th CL='STD_USARG2'></th>
                                <td  name="USARG2"  id="USARG2">
                                </td>
                            </tr>
                            <tr style="display:none">
                                <th CL='STD_RQSHPD'></th>
                                <td  name="RQSHPD"  id="RQSHPD">
                                </td>
                            </tr>
                            <tr style="display:none">
                                <th CL='STD_NAME01'></th>
                                <td  name="NAME01"  id="NAME01">
                                </td>
                            </tr>
                            <tr>
                                <th CL='STD_SHIPNM'></th>
                                <td  name="SHIPNM" id="SHIPNM">
                                </td>
                            </tr>
                            <tr style="display:none">
                                <th CL='STD_DRIVER'></th>
                                <td  name="DRIVER" id="DRIVER">
                                </td>
                            </tr>
                            <tr>
                                <th>사진</th>
                                <td>
                                    <input type="file" id="camera" name="camera" accept="image/*" capture="camera"  />
                           			<input type="hidden" name="imageThumbnailSize" value="300"/>
                                    
                                </td>
                            </tr>
                            <tr>
                                <th>전화걸기</th>
                                <td>
                                    <a href="tel:010" id="telNo"></a>
                                </td>
                            </tr>
                            <tr style="display:none">
                                <th>사진촬영체크</th>
                                <td  name="INDBZL" id="INDBZL">
                                </td>
                            </tr>
                            <tr>
                            	<th>사유코드내용</th>
                            	<td>
                            	<input type="text" id="RSNTXT" name="RSNTXT"/>
                            	</td>
                            </tr>
                    	</tbody>
                	</table>
				</div>   
            </div>      
        </div>
        <div class="footer_5">
            <table>
                <tr>
                    <td class=filebox>
                        <div class="camerafilebox">
                        <label for="camera">사진촬영</label>
                        <input type="hidden" name = "batchtype" />
                        </div>
                    </td>
                    <td class=f_1  onclick="Clear()">배송완료</td>
                    <td onclick="Fail()">배송실패</td>
                    <td onclick="searchList()">닫기</td>
 				</tr>
            </table>
        </div>
    </div>
    <input type="hidden" name="SHIPTN">
    <input type="hidden" name="SHIPNM">
    <input type="hidden" name="VHPORD">
    <input type="hidden" name="DRIVER">
    <input type="hidden" name="RSNCOD">
    <input type="hidden" name="SFTYPE">
    <input type="hidden" name="RQSHPD">
    <input type="hidden" name="SDTIME">
    <input type="hidden" name="RSNTXT">
    <input type="hidden" name="NAME01">
    
</form>

    
</body>
</html>