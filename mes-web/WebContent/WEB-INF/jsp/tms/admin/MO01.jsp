<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>TMS</title>
<%@ include file="/common/include/head.jsp"%> 

<script type="text/javascript" src="/common/js/timepicker/jquery.timepicker.js"></script>
<link rel="stylesheet" type="text/css" href="/common/js/timepicker/jquery.timepicker.css" />
  
<script type="text/javascript">
 
    var _SPLITCHAR_ ="↓";
	var flag = "U";
	var rangelist = [ "LOTA01", "LOTA02", "LOTA03", "AREAKY", "ZONEKY",
			"LOCAKY" ];

	$(document).ready(function(){ 
		gridList.setGrid({
	    	id : "gridList",
			editable : true,
			pkcol : "WAREKY,RTPCD",
			module : "TmsAdmin",
			command : "MO01_TAB2_1" //, itemGrid : "gridListItem"
	    }); 
	});
	
	function searchList() {
		flag = "U";
		//var param = dataBind.paramData("searchArea");
		if (validate.check("searchArea")) {
			var param = inputList.setRangeParam("searchArea");
			var rtpcd = param.get("RTPCD");
			var rtpcdChk = new DataMap();

			rtpcdChk.put("RTPCD", rtpcd);

			var json = netUtil.sendData({
				module : "TmsAdmin",
				command : "RTPCDval",
				sendType : "map",
				param : param
			});

			if (json.data["CNT"] > 0) { 
				searchTab(param,"MO01");
				searchOpen(false);
				//dataBind.dataNameBind(map,"tabs2_1")
				//alert(JSON.stringify(map))
			} else {
				commonUtil.msgBox("TMS_M0099", rtpcd);

			}

		}
	}

	function searchTab(param, commandFlg){

		netUtil.send({
			module : "TmsAdmin",
			command : commandFlg,  //commandFlg: MO01TAB_1_1_NEW, MO01
			bindId : "tab1_1",
			sendType : "map",
			bindType : "field",
			param : param
		});
		
		//==========================================
		//자원 탭2_1:GRID
		//==========================================
		
		var param = inputList.setRangeParam("searchArea");
		gridList.gridList({
	    	id : "gridList",
			module : "TmsAdmin",
			command : "MO01_TAB2_1",
	    	param : param
	    });
		 	
		//
		//전략 탭2_2_1 :최초도착지
		//
		var json = netUtil.sendData({
			module : "TmsAdmin",
			command : "MO01_TAB2_2",
			bindId : "tabs2_2_1",
			sendType : "list",
			bindType : "field",
			param : param
		});
		var list = json.data;

		var tabs_data = new DataMap();

		var _KEYSEQ_DATASTR="";
		var _OPTIONS_DATASTR="";
		var _SHORTX_DATASTR="";
		var _SEQNO_DATASTR="";
		var addTr=""; 
		var prevTr=""; 

		prevTr  = "<tr>";
		prevTr += "  <th><h2 class=\"tit\">최초도착지</h2></th>";
		prevTr += "  <td></td>";
		prevTr += "</tr>";
		
		jQuery("#table2_2_1").empty();
		jQuery("#table2_2_1").append(prevTr);
		
		$.each(list, function(i, obj) { 
			var _KEYSEQ  = obj.KEYSEQ;//코드값 :키옵션구분 
			var _OPTIONS = obj.OPTIONS;//코드값 :키옵션
			var _SHORTX  = obj.SHORTX;//코드값 :키옵션    
			var _SEQNO   = obj.SEQNO;//코드값 :순번    
			
			var KEYSEQ_CHKFLG = obj.CHKFLG;//차종 채크여부 
			var KEYSEQ_TAG_CHECKED = "checked";//채크여부 TAG
			if ( KEYSEQ_CHKFLG != 'V'){
				KEYSEQ_TAG_CHECKED ="";
			}   

			addTr  = "<tr>";
			addTr += "  <td>";
			if( i == 0){
			addTr += "      <input type=\"hidden\" name=\"_KEYSEQ\"  value=\""+_KEYSEQ+"\" />";
			addTr += "      <input type=\"hidden\" name=\"_OPTIONS\" value=\""+_OPTIONS+"\" />";
			addTr += "      <input type=\"hidden\" name=\"_SHORTX\"  value=\""+_SHORTX+"\" />";
			addTr += "      <input type=\"hidden\" name=\"_SEQNO\"   value=\""+_SEQNO+"\" />";
			}
			addTr += "      <input type=\"checkbox\" name=\""+_KEYSEQ+"\" value=\"V\" "+KEYSEQ_TAG_CHECKED+"/></td>";
			addTr += "  <td>"+_SHORTX+"</td>";
			addTr += "</tr>";

			
			jQuery("#table2_2_1").append(addTr); 

			_KEYSEQ_DATASTR  += _KEYSEQ  + _SPLITCHAR_; 
			_OPTIONS_DATASTR += _OPTIONS + _SPLITCHAR_; 
			_SHORTX_DATASTR  += _SHORTX  + _SPLITCHAR_;
			_SEQNO_DATASTR   += _SEQNO   + _SPLITCHAR_;
			
		});
		tabs_data.put("_KEYSEQ",  _KEYSEQ_DATASTR );
		tabs_data.put("_OPTIONS", _OPTIONS_DATASTR); 
		tabs_data.put("_SHORTX",  _SHORTX_DATASTR ); 
		tabs_data.put("_SEQNO",   _SEQNO_DATASTR  ); 

		dataBind.dataNameBind(tabs_data, "tabs2_2_1");
		 
		//
		// 전략 탭2_2_2:다음도착지
		// 
		var json = netUtil.sendData({
			module : "TmsAdmin",
			command : "MO01_TAB2_2_2",
			bindId : "tabs2_2_2",
			sendType : "list",
			bindType : "field",
			param : param
		});
		//var 
		list = json.data;

		//var 
		tabs_data = new DataMap();

		//초기화
		_KEYSEQ_DATASTR="";
		_OPTIONS_DATASTR="";
		_SHORTX_DATASTR="";
		_SEQNO_DATASTR="";
		addTr=""; 
		prevTr=""; 

		prevTr  = "<tr>";
		prevTr += "  <th><h2 class=\"tit\">다음도착지</h2></th>";
		prevTr += "  <td></td>";
		prevTr += "</tr>";
		
		jQuery("#table2_2_2").empty();
		jQuery("#table2_2_2").append(prevTr);
		
		$.each(list, function(i, obj) {
			var _KEYSEQ  = obj.KEYSEQ;//코드값 :키옵션구분 
			var _OPTIONS = obj.OPTIONS;//코드값 :키옵션
			var _SHORTX  = obj.SHORTX;//코드값 :키옵션    
			var _SEQNO   = obj.SEQNO;//코드값 :순번    
			
			var KEYSEQ_CHKFLG = obj.CHKFLG;//차종 채크여부 
			var KEYSEQ_TAG_CHECKED = "checked";//채크여부 TAG
			if ( KEYSEQ_CHKFLG != 'V'){
				KEYSEQ_TAG_CHECKED ="";
			}   

			addTr  = "<tr>";
			addTr += "  <td>";
			if( i == 0){
			addTr += "      <input type=\"hidden\" name=\"_KEYSEQ\"  value=\""+_KEYSEQ+"\" />";
			addTr += "      <input type=\"hidden\" name=\"_OPTIONS\" value=\""+_OPTIONS+"\" />";
			addTr += "      <input type=\"hidden\" name=\"_SHORTX\"  value=\""+_SHORTX+"\" />";
			addTr += "      <input type=\"hidden\" name=\"_SEQNO\"   value=\""+_SEQNO+"\" />";
			}
			addTr += "      <input type=\"checkbox\" name=\""+_KEYSEQ+"\" value=\"V\" "+KEYSEQ_TAG_CHECKED+"/></td>";
			addTr += "  <td>"+_SHORTX+"</td>";
			addTr += "</tr>";
 
			jQuery("#table2_2_2").append(addTr); 
			_KEYSEQ_DATASTR  += _KEYSEQ  + _SPLITCHAR_; 
			_OPTIONS_DATASTR += _OPTIONS + _SPLITCHAR_; 
			_SHORTX_DATASTR  += _SHORTX  + _SPLITCHAR_;
			_SEQNO_DATASTR   += _SEQNO   + _SPLITCHAR_;
		});
		tabs_data.put("_KEYSEQ",  _KEYSEQ_DATASTR );
		tabs_data.put("_OPTIONS", _OPTIONS_DATASTR); 
		tabs_data.put("_SHORTX",  _SHORTX_DATASTR ); 
		tabs_data.put("_SEQNO",   _SEQNO_DATASTR  ); 

		dataBind.dataNameBind(tabs_data, "tabs2_2_2");
		
		//
		// 제약 탭2_3
		//
		var json = netUtil.sendData({
			module : "TmsAdmin",
			command : "MO01_TAB2_3",
			bindId : "tabs2_3",
			sendType : "list",
			bindType : "field",
			param : param
		});
		//var 
		list = json.data;

		//var 
		tabs_data = new DataMap();

		//초기화
		_KEYSEQ_DATASTR="";
		_OPTIONS_DATASTR="";
		_SHORTX_DATASTR="";
		_SEQNO_DATASTR="";
		addTr="";
		var _VALUE_DATASTR ="";

		jQuery("#table2_3").empty();
		
		$.each(list, function(i, obj) {
			var _KEYSEQ  = obj.KEYSEQ;//코드값 :키옵션구분 
			var _OPTIONS = obj.OPTIONS;//코드값 :키옵션
			var _SHORTX  = obj.SHORTX;//코드값 :키옵션    
			var _SEQNO   = obj.SEQNO;//코드값 :순번     
			var _VALUE   = obj.VALUE;//값     
			
			var KEYSEQ_CHKFLG = obj.CHKFLG;//차종 채크여부 
			var KEYSEQ_TAG_CHECKED = "checked";//채크여부 TAG
			if ( KEYSEQ_CHKFLG != 'V'){
				KEYSEQ_TAG_CHECKED ="";
			}   
			 
			if(_KEYSEQ != '18' ){ 
				addTr  = "<tr>";
				addTr += "  <td>";
				if( i == 0){
				addTr += "      <input type=\"hidden\" name=\"_KEYSEQ\"  value=\""+_KEYSEQ+"\" />";
				addTr += "      <input type=\"hidden\" name=\"_OPTIONS\" value=\""+_OPTIONS+"\" />";
				addTr += "      <input type=\"hidden\" name=\"_SHORTX\"  value=\""+_SHORTX+"\" />";
				addTr += "      <input type=\"hidden\" name=\"_SEQNO\"   value=\""+_SEQNO+"\" />";
				}
				addTr += "      <input type=\"hidden\" name=\""+_KEYSEQ+"\" value=\"V\" "+KEYSEQ_TAG_CHECKED+"  /></td>";
				 
				if(_KEYSEQ == '15' ){//화면에 안보이게 처리.
				  //addTr += "  <td>"+_SHORTX+"</td>";
					addTr += "  <td><input type=\"hidden\" name=\""+_KEYSEQ+"_VALUE\" value=\"0000\" UIInput=\"N\" UIFormat=\"T 4\"  validate=\"required,VALID_required\" /></td>";
				}else{
					addTr += "  <td>"+_SHORTX+"</td>";
					addTr += "  <td><input type=\"text\" name=\""+_KEYSEQ+"_VALUE\" value=\""+_VALUE+"\" UIInput=\"N\" validate=\"required,VALID_required\" /></td>";
				}
				
				if(_KEYSEQ == '15' ){
				  ;//addTr += "  <td>예)오전 09:00</td>";
				}else if(_KEYSEQ == '16' ){
				addTr += "  <td>예)오후 23:00</td>";
				}else if(_KEYSEQ == '17' ){
				addTr += "  <td>예)9</td>";
				}else {
				addTr += "  <td>&nbsp;</td>";
				}
				addTr += "</tr>";  
			}else {//18인 경우 
				addTr  = "<tr>";
				addTr += "  <td>";
				if( i == 0){
				addTr += "      <input type=\"hidden\" name=\"_KEYSEQ\"  value=\""+_KEYSEQ+"\" />";
				addTr += "      <input type=\"hidden\" name=\"_OPTIONS\" value=\""+_OPTIONS+"\" />";
				addTr += "      <input type=\"hidden\" name=\"_SHORTX\"  value=\""+_SHORTX+"\" />";
				addTr += "      <input type=\"hidden\" name=\"_SEQNO\"   value=\""+_SEQNO+"\" />";
				}
				addTr += "      <input type=\"hidden\" name=\""+_KEYSEQ+"\" value=\"V\" "+KEYSEQ_TAG_CHECKED+"/></td>";
				addTr += "  <td>"+_SHORTX+"</td>";
				addTr += "  <td><input type=\"text\" name=\""+_KEYSEQ+"_VALUE\" value=\""+_VALUE+"\" validate=\"required,VALID_required\" /></td>";
				addTr += "  <td>예)70" ;
				addTr += "      <div id =\"tabs2_3_2\" class=\"section type3\" >";
				addTr += "            <div class=\"searchInBox\">";
				addTr += "                  <div class=\"table type1\" >";
				addTr += "                    <table id=\"table2_3_2\">";
				addTr += "                    </table>";
				addTr += "                  </div>";
				addTr += "            </div>";
				addTr += "      </div>";
				addTr += "  </td>";
				addTr += "</tr>";   
			}
			
			/**
			if(_KEYSEQ == '15' || _KEYSEQ == '16'){
				addTr += "<script type=\"text/javascript\">";
				addTr += "$(function(){";
				addTr += "	$('*[name=\""+_KEYSEQ+"_VALUE\"]').appendDtpicker({";
				addTr += "		\"dateFormat\": \"hh:mm\",";
				addTr += "		\"minuteInterval\": 15,";
				addTr += "		\"minTime\":\"00:00\",";
				addTr += "		\"maxTime\":\"23:59\"";
				addTr += "	});";
				addTr += "});";
				addTr += "<//script>";
			}
			**/
			 
			jQuery("#table2_3").append(addTr);
			

			if(_KEYSEQ == '15' ){  
				$('*[name=15_VALUE]').timepicker({ 'timeFormat': 'H:i', 'step': 15 });
				
				var tmpValue='';
				if( _VALUE.length == 4 ){
					tmpValue+=_VALUE.substring(0,2);	
					tmpValue+=':';
					tmpValue+=_VALUE.substring(2,4);	
				}
				$('*[name=15_VALUE]').val(tmpValue); 
			}

			if(_KEYSEQ == '16' ){ 

				$('*[name=16_VALUE]').timepicker({ 'timeFormat': 'H:i', 'step': 15 });
				
				var tmpValue='';
				if( _VALUE.length == 4 ){
					tmpValue+=_VALUE.substring(0,2);	
					tmpValue+=':';
					tmpValue+=_VALUE.substring(2,4);	
				}
				$('*[name=16_VALUE]').val(tmpValue); 
			}
			
			_KEYSEQ_DATASTR  += _KEYSEQ  + _SPLITCHAR_; 
			_OPTIONS_DATASTR += _OPTIONS + _SPLITCHAR_; 
			_SHORTX_DATASTR  += _SHORTX  + _SPLITCHAR_;
			_SEQNO_DATASTR   += _SEQNO   + _SPLITCHAR_;
			_VALUE_DATASTR   += _VALUE   + _SPLITCHAR_;
		});
		tabs_data.put("_KEYSEQ",  _KEYSEQ_DATASTR );
		tabs_data.put("_OPTIONS", _OPTIONS_DATASTR); 
		tabs_data.put("_SHORTX",  _SHORTX_DATASTR ); 
		tabs_data.put("_SEQNO",   _SEQNO_DATASTR  );
		tabs_data.put("_VALUE",   _VALUE_DATASTR  );

		dataBind.dataNameBind(tabs_data, "tabs2_3");
 
		//
		// 제약 탭2_3_2 :최소적재율::적제재한기준 
		//
		var json = netUtil.sendData({
			module : "TmsAdmin",
			command : "MO01_TAB2_3_2",
			bindId : "tabs2_3_2",
			sendType : "list",
			bindType : "field",
			param : param
		});
		//var 
		list = json.data;

		//var 
		tabs_data = new DataMap();
		 
		//초기화
		_KEYSEQ_DATASTR="";
		_OPTIONS_DATASTR="";
		_SHORTX_DATASTR="";
		_SEQNO_DATASTR="";
		addTr="";
		var _UNITKY_DATASTR="";

		prevTr  = "<tr>";
		prevTr += "  <th><h2 class=\"tit\">적재재한기준</h2></th>";
		prevTr += "  <td></td>";
		prevTr += "</tr>";
		
		jQuery("#table2_3_2").empty(); 
		jQuery("#table2_3_2").append(prevTr);
		
		$.each(list, function(i, obj) {

			var _UNITKY = obj.UNITKY;//코드값 :키옵션구분
			var _SHORTX  = obj.SHORTX;//코드값 :키옵션    
			
			var UNITKY_CHKFLG = obj.CHKFLG;//차종 채크여부 
			var UNITKY_TAG_CHECKED = "checked";//채크여부 TAG
			if ( UNITKY_CHKFLG != 'V'){
				UNITKY_TAG_CHECKED ="";
			}
			var UNITKY_NAME = obj.SHORTX;//코드명 :키옵션구분명 
			
			var addTr ;
 
		    addTr  = "<tr>"
		    addTr += "  <td>";
			if( i == 0){
		    addTr += "      <input type=\"hidden\" name=\"_UNITKY\"  value=\""+_UNITKY+"\" />";
			}
			
			if( _UNITKY != 'EA'){
			addTr += "      <input type=\"checkbox\" id=\""+_UNITKY+"\" name=\""+_UNITKY+"\" value=\"V\" "+UNITKY_TAG_CHECKED+"/></td>"
			addTr += "  <td>"+_SHORTX+"</td>";
		    }else {// EA 안보여줌.
			addTr += "      <input type=\"hidden\" id=\""+_UNITKY+"\" name=\""+_UNITKY+"\" value=\"\" /></td>"
			addTr += "  <td>&nbsp;</td>";
		    }
			addTr += "</tr>";
			 
			jQuery("#table2_3_2").append(addTr); 
			
			_UNITKY_DATASTR  += _UNITKY  + _SPLITCHAR_; 
			_SHORTX_DATASTR  += _SHORTX  + _SPLITCHAR_; 
		});
		tabs_data.put("_UNITKY",  _UNITKY_DATASTR ); 
		tabs_data.put("_SHORTX",  _SHORTX_DATASTR ); 

		dataBind.dataNameBind(tabs_data, "tabs2_3_2");
 
		//
		// 제약고급 탭2_4
		//
		var json = netUtil.sendData({
			module : "TmsAdmin",
			command : "MO01_TAB2_4",
			bindId : "tabs2_4",
			sendType : "list",
			bindType : "field",
			param : param
		});
		//var 
		list = json.data;

		//var 
		tabs_data = new DataMap();

		//초기화
		_KEYSEQ_DATASTR="";
		_OPTIONS_DATASTR="";
		_SHORTX_DATASTR="";
		_SEQNO_DATASTR="";
		addTr=""; 

		jQuery("#table2_4").empty();
		
		$.each(list, function(i, obj) {
			var _KEYSEQ  = obj.KEYSEQ;//코드값 :키옵션구분 
			var _OPTIONS = obj.OPTIONS;//코드값 :키옵션
			var _SHORTX  = obj.SHORTX;//코드값 :키옵션    
			var _SEQNO   = obj.SEQNO;//코드값 :순번    
			
			var KEYSEQ_CHKFLG = obj.CHKFLG;//차종 채크여부 
			var KEYSEQ_TAG_CHECKED = "checked";//채크여부 TAG
			if ( KEYSEQ_CHKFLG != 'V'){
				KEYSEQ_TAG_CHECKED ="";
			}   
			
			addTr  = "<tr>";
			addTr += "  <td>";
			if( i == 0){
			addTr += "      <input type=\"hidden\" name=\"_KEYSEQ\"  value=\""+_KEYSEQ+"\" />";
			addTr += "      <input type=\"hidden\" name=\"_OPTIONS\" value=\""+_OPTIONS+"\" />";
			addTr += "      <input type=\"hidden\" name=\"_SHORTX\"  value=\""+_SHORTX+"\" />";
			addTr += "      <input type=\"hidden\" name=\"_SEQNO\"   value=\""+_SEQNO+"\" />";
			}
			addTr += "      <input type=\"checkbox\" name=\""+_KEYSEQ+"\" value=\"V\" "+KEYSEQ_TAG_CHECKED+"/></td>";
			addTr += "  <td>"+_SHORTX+"</td>";
			addTr += "</tr>";

			jQuery("#table2_4").append(addTr); 
			
			_KEYSEQ_DATASTR  += _KEYSEQ  + _SPLITCHAR_; 
			_OPTIONS_DATASTR += _OPTIONS + _SPLITCHAR_; 
			_SHORTX_DATASTR  += _SHORTX  + _SPLITCHAR_;
			_SEQNO_DATASTR   += _SEQNO   + _SPLITCHAR_;
		});
		tabs_data.put("_KEYSEQ",  _KEYSEQ_DATASTR );
		tabs_data.put("_OPTIONS", _OPTIONS_DATASTR); 
		tabs_data.put("_SHORTX",  _SHORTX_DATASTR ); 
		tabs_data.put("_SEQNO",   _SEQNO_DATASTR  ); 

		dataBind.dataNameBind(tabs_data, "tabs2_4"); 	
		
		//==========================================
		$.each(rangelist, function(num, data) {
			var rangeList = new Array();
			var rngvop = "";
			$.each(list, function(i, obj) { 
				;
			}); 
		});
		
	}
	
	function creatList() {
		flag = "I";
		if (validate.check("searchArea")) {
			var param = inputList.setRangeParam("searchArea");
			var rtpcd = param.get("RTPCD");
			var rtpcdChk = new DataMap();

			rtpcdChk.put("RTPCD", rtpcd);

			var json = netUtil.sendData({
				module : "TmsAdmin",
				command : "RTPCDval",
				sendType : "map",
				param : param
			});

			if (json.data["CNT"] > 0) {
				commonUtil.msgBox("MASTER_M0025", rtpcd);
				return;
			}

			searchTab(param, "MO01TAB_1_1_NEW");
			searchOpen(false);
		}
	}
	
	function saveData() {
		
		//필수항목채크
		//15_VALUE,16_VALUE,17_VALUE,18_VALUE 
		if (validate.check("tabs2_3")) { 
			//적재제한기준 3개중 하나는 필수임. 
			if( $('input:checkbox[name=KG]').is(':checked') == false 
			 && $('input:checkbox[name=M2]').is(':checked') == false
			 && $('input:checkbox[name=M3]').is(':checked') == false){ 
				commonUtil.msgBox(commonUtil.getMsg("VALID_required",'적재제한기준은 ')); 
				
				// 필수 항목탭으로 이동.
				$('#bottomTabs').tabs("option", "active", 2);  
				return;
			}
			
			if(!commonUtil.msgConfirm(configData.MSG_MASTER_SAVE_CONFIRM)){
				return;
			} 
			var tab1_1 = dataBind.paramData("tab1_1");
	
			var tab2_1_Cnt = gridList.getGridDataCount("gridList");
			var rownum=0;
			var seqno=0;
			for(var i = 0; i < tab2_1_Cnt; i++){
		    	gridList.setColValue("gridList", i, "STATUS", gridList.getRowStatus("gridList", i));
	
		    	//순번 재세팅
		    	rownum=gridList.gridMap.map.gridList.getRowNum(i);
		    	//alert('i=='+i+'getSelectType():'+getSelectType("gridList", rownum);
		    	//alert('CHKFLG:'+ gridList.getColData("gridList", rownum, "CHKFLG") );
		    	if( gridList.getColData("gridList", rownum, "CHKFLG") == 'V' ){
		    		seqno++;
		    	}
		    	gridList.setColValue("gridList", rownum, "SEQNO", seqno);
		    }
	
		  //return;
			
			//탭 
			var tab2_1 = gridList.getGridData("gridList");
			
			var tab2_2_1 = dataBind.paramData("tabs2_2_1");
			var tab2_2_2 = dataBind.paramData("tabs2_2_2");
			var tab2_3   = dataBind.paramData("tabs2_3"); 
			var tab2_3_2 = dataBind.paramData("tabs2_3_2"); 
			var tab2_4   = dataBind.paramData("tabs2_4"); 
			
			var param = new DataMap();
			param.put("tab1_1", tab1_1);//일반탭
			
			param.put("tab2_1", tab2_1);//상세 탭 :자원
			param.put("tab2_2_1", tab2_2_1);//상세 탭 :전략 최초 도착지  
			param.put("tab2_2_2", tab2_2_2);//상세 탭 :전략 다음 도착지   
			param.put("tab2_3", tab2_3);//상세 탭 :제약
			param.put("tab2_3_2", tab2_3_2);//상세 탭 :제약-적제제한기준
			param.put("tab2_4", tab2_4);//상세 탭 :제약고급
			param.put("STATUS", flag);
			
		  //return;
			
			var json = netUtil.sendData({
				url : "/wms/admin/json/saveMO01.data",
				param : param
			});
	
			if (json && json.data) {
				commonUtil.msgBox("HHT_T0008");
				searchList();
			}
		}else{ 
			// 필수 항목탭으로 이동.
			$('#bottomTabs').tabs("option", "active", 2);  
		}
	}
	
	function delData(){
		if(!commonUtil.msgConfirm(configData.MSG_MASTER_DELETE_CONFIRM)){
			return;
		}
		var head = dataBind.paramData("tab1_1");//상단 필드셋 
		
		var param = new DataMap();
		param.put("head", head);
		
		var json = netUtil.sendData({
			url : "/wms/admin/json/delMO01.data",
			param : param
		});
	
		if (json && json.data) {
			commonUtil.msgBox("VALID_M0003");
			searchOpen(true);
		}
	}
	
	function searchHelpEventOpenBefore(searchCode, gridType) {
		//commonUtil.debugMsg("searchHelpEventOpenBefore : ", arguments);
		if (searchCode == "SHWAHMA") {
			return dataBind.paramData("searchArea");
		} else if (searchCode == "SHRTPSH") {
			return dataBind.paramData("searchArea");
	 /* } else if (searchCode == "SHRLRRH") {
			return dataBind.paramData("searchArea");
		*/
		} else if (searchCode == "SHAREMA") {
			return dataBind.paramData("searchArea");
		} else if (searchCode == "SHZONMA") {
			return dataBind.paramData("searchArea");
		} else if (searchCode == "SHLOCMA") {
			return dataBind.paramData("searchArea");
		}
	}


	function commonBtnClick(btnName) {
		//commonUtil.debugMsg("commonBtnClick : ", arguments);
		if (btnName == "Search") {
			searchList();
		} else if (btnName == "Save") {
			saveData();
		} else if (btnName == "Delete") {
			delData();
		} else if (btnName == "Create") {
			creatList();
		}
	}
	
	function gridListEventDataViewEnd(gridId, dataLength){
		if(gridId=="gridList"){
			;
		}else {
			;
		}
	}
	
	function gridListEventColValueChange(gridId, rowNum, colName, colValue){
		 
	}
	
	function onInit(){
		
	}
</script>
</head>
<body>  
	<div class="contentHeader">
		<div class="util">
			<button CB="Search SEARCH BTN_DISPLAY"></button>
			<button CB="Save SAVE STD_SAVE"></button>
		    <button CB="Delete DELETE BTN_DELETE"></button>
		</div>
		<div class="util3">
			<button class="button type2" id="showPop" type="button">
				<img src="/common/images/ico_btn4.png" alt="List" />
			</button>
		</div>
	</div>


	<!-- searchPop -->
	<div class="searchPop" id="searchArea">
		<button type="button" class="closer">X</button>
		<div class="searchInnerContainer">
			<p class="util">
				<button CB="Create CREATE BTN_CREATE"></button>
				<button CB="Search SEARCH BTN_DISPLAY"></button>
				<button CB="GetVariant GETVARIANT BTN_GETVARIANT"></button>
				<button CB="SaveVariant SAVEVARIANT BTN_SAVEVARIANT"></button>
			</p>
			
			<div class="searchInBox">
				<h2 class="tit" CL="STD_SELECTOPTIONS">검색조건</h2>
				<table class="table type1">
					<colgroup>
						<col width="100" />
						<col />
					</colgroup>
					<tbody>
						<tr>
							<th CL="STD_WAREKY">거점</th>
							<td><input type="text" id="WAREKY" name="WAREKY"
								readonly="readonly" value="<%=wareky%>" /></td>
						</tr>
						<tr>
							<th CL="STD_RTPCD">*</th>
							<td><input type="text" id="RTPCD" name="RTPCD"
								UIInput="S,SHRTPSH" validate="required,VALID_required" /></td>
						</tr>
					</tbody>
				</table>
			</div>
		</div>
	</div>
	<!-- //searchPop -->

	<!-- content -->
	<!-- content -->
	<div class="content">
		<div class="innerContainer" id="content">

			<!-- contentContainer -->
			<div class="contentContainer">

				<div class="foldSect">
					<div class="tabs">
						<ul class="tab type2">
							<li><a href="#tabs1-1"><span value="일반">일반</span></a></li>
						</ul>
						<div id="tab1_1">
							<div class="section type1 hei200">
								<div class="table type1">
									<table>
										<tr> 
											<th CL="STD_WAREKY">거점</th>
											<td><input type="text" name="WAREKY" readonly="readonly" />
											</td>
										</tr>
										<tr>
											<th CL="STD_RTPCD">루트패스코드</th>
											<td><input type="text" name="RTPCD" readonly="readonly" />
											</td>
										</tr>
										<tr>
											<th CL="STD_RTPCDM">루트패스명</th>
											<td><input type="text" name="SHORTX" /></td>
										</tr>
									</table>

								</div>
							</div>
						</div>
					</div>
				</div>
				<!--  -->
				<div class="bottomSect type2">
					<div class="tabs"  id="bottomTabs">
						<ul class="tab type2">
							<li><a href="#tabs2_1"><span >자원</span></a></li>
							<li><a href="#tabs2_2"><span >전략</span></a></li>
							<li><a href="#tabs2_3"><span >제약</span></a></li>
							<li><a href="#tabs2_4"><span >제약고급</span></a></li>
						</ul> 
						
						<div id="tabs2_1">
							<div class="section type1">
								<div class="table type2">
									<div class="tableHeader">
										<table>
											<colgroup>
												<col width="40" />
												<col width="50" /> 
												<col width="100" />
											</colgroup>
											<thead>
												<tr>
													<th CL="STD_NUMBER">번호</th>
													<th CL="STD_SELECT">선택</th> 
													<th >자원</th> 
												</tr>
											</thead>
										</table>
									</div>
									<div class="tableBody">
										<table>
											<colgroup>
												<col width="40" />
												<col width="50" />
												<col width="100" /> 
											</colgroup>
											<tbody id="gridList">
												<tr CGRow="true">
													<td GCol="rownum">1</td>  
													<td GCol="check,CHKFLG"></td>
													<td GCol="text,VHCSTX"></td> 
												</tr>
											</tbody>
										</table>
									</div>
	
								</div>
								<div class="tableUtil">
									<div class="leftArea">
										<button type="button" GBtn="up"></button>
										<button type="button" GBtn="down"></button>
									</div>
									<div class="rightArea">
										<p class="record" GInfoArea="true"></p>
									</div>
								</div>
							</div>
						</div>
						
						<div id="tabs2_2">
							<div class="section type1" style="overflow: scroll">
								<div class="searchInBox">

									<div id="tabs2_2_1" class="table type1">
										<!-- 	전략(최초도착지) -->
										<table id="table2_2_1">
										</table>
									</div>
									<div id="tabs2_2_2" class="table type1">
										<!-- 	전략(다음도착지) -->
										<table id="table2_2_2">
										</table>
									</div>
								</div>
							</div>
						</div>
					    <div id="tabs2_3">
							<div class="section type1" style="overflow: scroll">
								<div class="searchInBox">

									<div class="table type1">
										<!-- 	제약 -->
										<table id="table2_3"> 
										</table>
									</div>
								</div>
							</div>
						</div>
					    <div id="tabs2_4">
							<div class="section type1" style="overflow: scroll">
								<div class="searchInBox">

									<div class="table type1">
										<!-- 	제약고급  -->
										<table id="table2_4"> 
										</table>
									</div>
								</div>
							</div>
						</div>						
					</div>
				</div>
				<!-- //contentContainer -->
			</div>
		</div>
     </div>
		<!-- //content -->
<%@ include file="/common/include/bottom.jsp"%> 
</body>
</html>