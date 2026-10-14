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
 
<script type="text/javascript">
 

    var searchType = false;
    $(document).ready(function(){
        
        gridList.setGrid({
            id : "gridList",
            editable : true,
            module : "WmsMobile",
            command : "TE52",
            bindArea: "itemArea",
            gridMobileType : true
        });
        
/*         gridList.setGrid({
            id : "gridSubList",
            editable : true,
            module : "WmsMobile",
            command : "TE52POP",
            gridMobileType : true
        }); */
        
        gridList.setGrid({
            id: "gridThdList",
            editable : true,
            module : "WmsMobile",
            command : "TE52THD",
            gridMobileType : true
        });

 		searchList();
 		searchType = true;
 		//getGPSInfo("getGPSInfo");
        if($.isApp){
            var data = {'callbackFn' : 'getGPSInfo'};
            $.callApp('10', data);
        }
        
        $("#noticeInfo").hide();
        $("#main").show();
        
    }); 

	var gpsInfo;
	function getGPSInfo(data){
		//data = "{\"latitude\":37.51661234,\"longitude\":127.20231234}";

		$('#gpsinfo').val(data);
		var obj = eval("("+data+")");
		gpsInfo =  obj;
		if(data.indexOf("latitude")>-1){
			$('#gpsok').val("GPS OK");
		}else{
			$('#gpsok').val("GPS ERROR");
		}
	}
	
    var subchk = 0;

    function searchList(){
    	alert("searchList()");
    	
    	document.getElementById("main_frame").src = "/wms/mobile/MTE52Detail.data";
        showMain();
        searchType = true;
        var param = dataBind.paramData("searchArea");



        gridList.gridList({
            id : "gridList",
            param : param
        });
        subchk = 0;


    }
    
    function gridListEventDataBindEnd(gridId, dataLength){
		var gridCount = gridList.getGridDataCount("gridList");
        //alert(gridCount);
        $("#TMTOT").text(gridCount);
    }
    
    var gps;

    var rowData;
    var $telObj;

    var param_detail = new DataMap();
    var gpsInfo;
    function gridListEventRowFocus(gridId, rowNum, colName){
    	
    	if(searchType){
            searchType = false;
            $telObj = $("#telNo");
            gridList.setRowFocus(gridId, -1, false);
            showDetail();
            return;
        } 
        
        rowData = gridList.getRowData(gridId, rowNum);
        var shipad = rowData.get("SHIPAD");
                
        var shipad1 = rowData.get("SHIPAD1");
        var shipnm = rowData.get("SHIPNM");
        
        param_detail.put("SHIPAD", shipad)
        param_detail.put("SHIPAD1", shipad1)
        param_detail.put("SHIPNM", shipnm)
        
        if(gridId=="gridSubList"){
            showDetail();
        }       

       	showDetail();
        gridList.setRowFocus(gridId, -1, false);
        subchk = 0;

    }
    
    function getData() {
        return param_detail;
    }
    
    function getGps() {
        gps = $("#gpsinfo").val();
        console.log("gps_main:"+gps)
        return gps;
    }

    var $callBarcodeObj;
    function callBarcode(objId){
        //alert(objId);
        $callBarcodeObj = $("#"+objId);
        var data = {'callbackFn' : 'getBarCode'};
        $.callApp('20', data);
    }
    
    function getBarCode(data){
        var obj = eval("("+data+")");
        $callBarcodeObj.val(obj["SCAN_RESULT"]);
    }
    
    function showMain() {
    	alert("showMain()");
    	
        $("#detailInfo").hide();
        $("#main").show();
        $("#noticeInfo").hide();
        $("#map").hide();
        $("#map_foot").hide();
    }
    
    function showDetail() {
    	alert("showDetail()");
    //	document.getElementById("main_frame").searchSubList();
    	var obj = document.getElementById("main_frame");

    	var objDoc = obj .contentWindow || obj .contentDocument;
    	objDoc.searchSubList(); 
    	
    	
        $("#main").hide();
        $("#detailInfo").show();
        $("#noticeInfo").hide();
        
    }
 
    function openNotice(){
    	document.getElementById("main_frame").src = "";
        var param = dataBind.paramData("searchArea");
 
        gridList.gridList({
            id : "gridThdList",
            command : "TE52THD",
            param : param
        });
        subchk = 0;
        $("#main").hide();
        $("#detailInfo").hide();
        $("#noticeInfo").show();
    	document.getElementById("main_frame").src = "/wms/mobile/MTE52Detail.data";
    }
    
    function noticeShow(){
        $("#main").hide();
        $("#map").hide();
        $("#map_foot").hide();
        $("#detailInfo").hide();
        $("#noticeInfo").show();
    }
    function linkPopCloseEvent(data){
        $("#UUID").val(data);
    }
    
    function photoSave(){
        netUtil.sendForm("saveForm");
    }
    
    function fileSave(){
        netUtil.sendForm("saveForm1");
    }
    
    function netUtilEventSetFormSuccess(formId, data){
        if(data.indexOf("[")){
            var uuid = data.substring(data.indexOf("[")+1,data.indexOf("]"));
            $("#UUID").val(uuid);
        }       
    }
 
</script>
</head>
 <body>
 <form name="form">

    <div class="main_wrap" id="main" >
        <div class="tem5_content">
            <div class="searchSection" >
                <table>
                    <colgroup>
                        <col width="70px"  />
                        <col width="70px" />
                        <col />
                        <col />
                    </colgroup>
                    <tbody>
                        <tr>
                            <td>
                                <input type="button" value="조회" class="bt" onclick="searchList()"/>
                            </td>
                            <td>
                                <input type="button" value="알림" onclick="openNotice()" style="width: 70px; float:left ;" class="bt" />
                            </td>
                            <td style="padding-left:15px">
                                <input type="text"  id="gpsok" name="gpsok"/>
                                <input type="hidden"  id="gpsinfo" name="gpsinfo"/>
                            </td>
                        </tr>
                    </tbody>
                </table>
            </div>
            <div class="MGR20_top_search" id="searchArea" style="height: 80px;">
                <table>
                    <colgroup>
                        <col width="70px"  />
                        <col />
                        <col width="30px"  />
                        <col width="70px"  />
                        <col />
                    </colgroup>
                    <tbody>
                        <tr>
                            <th>주문번호</th>
                            <td>
                                <input type="text" class="text" name="PGRC03" id="PGRC03"/>
                            </td>
                            <td>
                                <input type="button" value="B" class="bt" onclick="callBarcode('PGRC03')"/>
                            </td>
                            <th>수령자명</th>
                            <td>
                                <input type="text" class="text"  name="SHIPNM"/>
                            </td>
                        </tr>
                        <tr>
                            <th>송장번호</th>
                            <td>
                                <input type="text" class="text"  name="INVNUM" id="INVNUM"/>
                            </td>
                            <td>
                                <input type="button" value="B" class="bt" onclick="callBarcode('INVNUM')"/>
                            </td>
                            <th>판매처</th>
                            <td>
                                <input type="text" class="text"  name="EXPTNK" />
                            </td>
                        </tr>
                        <tr>
                            <th>총배송건:</th>
                            <td  name="TMTOT" id="TMTOT" cospan="3" align="left">
                            </td>
                        </tr>
                    </tbody>
                </table>
            </div>
            <div class="tableWrap_search section" >
                <div class="tableHeader">
                    <table style="width: 100%">
                        <colgroup>
                            <col width="60px" />
                            <col width="100px"/>
                            <col width="200px" />  
                            <col width="130px" />
                            <col width="100px" />
                        </colgroup>
                        <thead>
                            <tr>
                                <th>번호</th>
                                <th>수령자명</th>
                                <th>지번주소(기본)</th>
                                <th>지번주소(상세)</th>
                                <th>배차유형</th>
                            </tr>
                        </thead>
                    </table>                
                </div>                  
                <div class="tableBody">
                    <table style="width: 100%">
                        <colgroup>
                            <col width="60px" />
                            <col width="100px"/>
                            <col width="200px" />  
                            <col width="130px" />
                            <col width="100px" />
                        </colgroup>
                        <tbody id="gridList">
                            <tr CGRow="true">
                                <td GCol="rownum">1</td>
                                <td GCol="text,SHIPNM"></td>
                                <td GCol="text,SHIPAD"></td>
                                <td GCol="text,SHIPAD1"></td>
                                <td GCol="text,DLVTYP"></td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div><!-- end table_body -->
        </div>
    </div>
    
    <div class="detailInfo_wrap" id="detailInfo">
        <div id="itemArea">
        <iframe src = "/wms/mobile/MTE52Detail.data" width="100%" height="500" frameborder="0" border="0" scrolling="yes" bgcolor=#EEEEEE bordercolor="#FF000000" marginwidth="0" marginheight="0" name="main_frame" id="main_frame">
        </iframe>
        </div>
    </div>
    

    <div class="noticeInfo_wrap" id="noticeInfo">
        <div class="tem5_content">
            <div class="searchSection">
                <input type="hidden" name="VHPNKY" />
                <input type="hidden" name="VHTKKY" />
                <input type="hidden" name="VHTKIT" />
                <input type="hidden" name="USERID" />
                <input type="hidden" name="SHPOKY" />
                <input type="hidden" name="SHIPAD" />
                <input type="hidden" name="SHIPAD1" />
                <input type="hidden" name="SHIPNM" />
                
                <table>
                    <colgroup>
                        <col width="70px"  />
                        <col width="70px" />
                        <col />
                        <col />
                    </colgroup>
                    <tbody>
                        <tr>
                            <td>
                                <input type="button" value="조회" class="bt" onclick="searchList()"/>
                            </td>
                            <td>
                                <input type="button" value="닫기" onclick="showMain()" style="width: 70px; float:left ;" class="bt" />
                            </td>
                            <td>
                            </td>
                        </tr>
                    </tbody>
                </table>
            </div>
            
<!--            <div class="MGR20_top_search" id="searchArea"> --> 
<!--            <div class="MGR20_top_search">
                <table>
                    <colgroup>
                        <col width="70px"  />
                        <col />
                        <col width="30px"  />
                        <col width="70px"  />
                        <col />
                    </colgroup>
                    <tbody>
                    </tbody>
                </table>
            </div> -->
            <div class="tableWrap_search section" >
                <div class="tableHeader">
                    <table style="width: 100%">
                        <colgroup>
                            <col width="60px" />
                            <col width="150px"/>
                        </colgroup>
                        <thead>
                            <tr>
                                <th>번호</th>
                                <th>메세지</th>
                            </tr>
                        </thead>
                    </table>                
                </div>                  
                <div class="tableBody">
                    <table style="width: 100%">
                        <colgroup>
                            <col width="60px" />
                            <col width="150px"/>
                        </colgroup>
                        <tbody id="gridThdList">
                            <tr CGRow="true">
                                <td GCol="rownum">1</td>
                                <td GCol="text,CONTEN"></td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div><!-- end table_body -->
        </div>
    </div>
</form>
</body>
</html>