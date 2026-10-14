<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>TMS</title>
<%@ include file="/common/include/head.jsp" %> 

<script type="text/javascript">
	var lastFocusNum = -1;
	var dblIdx = 0;
	var tab_1_grid__SIMKEY = '';
	var tab_2_1_grid__DELORD = '';
	var tab_3_grid__RUTEKY   = '';
	var tab_3_1_grid__DELORD = '';
	var tab_4_grid__RUTEKY   = '';

	$(document).ready(function(){
	  //setTopSize(200);
		changeBtn('init');
		
		//탭1
		gridList.setGrid({
	    	id : "tab_1_grid",
			editable : true,
			pkcol : "MANDT,WAREKY,SIMKEY", 
			module : "TmsAdmin",
			command : "SIMUL",
			emptyMsgType:false
	    });
 
		//탭2
		gridList.setGrid({
	    	id : "tab_2_1_grid",
			editable : false,
			pkcol : "SIMKEY,DELORD,DELITN", 
			module : "TmsAdmin",
			command : "DNTAK_GROUP",
			emptyMsgType:false
	    });

		//탭2_2 
		gridList.setGrid({
	    	id : "tab_2_2_grid",
			editable : false,
			pkcol : "SIMKEY,DELORD,DELITN", 
			module : "TmsAdmin",
			command : "DNTAK_DN_ITEM",
			emptyMsgType:false
	    });
		
		//탭3
		gridList.setGrid({
	    	id : "tab_3_grid",
			editable : true,
			pkcol : "SIMKEY,DELORD,RUTEKY", 
			module : "TmsAdmin",
			command : "DNTAK_RESULT_TEXT",
			emptyMsgType:false
	    });

		//탭3_1
		gridList.setGrid({
	    	id : "tab_3_1_grid",
			editable : false,
			pkcol : "SIMKEY,DELORD,DELITN", 
			module : "TmsAdmin",
			command : "DNTAK_RESULT_GROUP",
			emptyMsgType:false
	    });

		//탭3_2
		gridList.setGrid({
	    	id : "tab_3_2_grid",
			editable : false,
			pkcol : "SIMKEY,DELORD,DELITN", 
			module : "TmsAdmin",
			command : "DNTAK_RESULT_DN_ITEM",
			emptyMsgType:false
	    });
		 

		//탭4
		gridList.setGrid({
	    	id : "tab_4_grid",
			editable : true,
			pkcol : "SIMKEY,DELORD,RUTEKY", 
			module : "TmsAdmin",
			command : "DNTAK_RESULT_TEXT",
			emptyMsgType:false
	    });

		//탭4_1
		gridList.setGrid({
	    	id : "tab_4_1_grid",
			editable : false,
			pkcol : "SIMKEY,RUTEKY,SHPTOP", 
			module : "TmsAdmin",
			command : "DNTAK_RESULT_GROUP_SHPTOP",
			emptyMsgType:false
	    });
		
		userInfoData = page.getUserInfo();
		dataBind.dataNameBind(userInfoData, "searchArea");
		/*
		if(userInfoData.AREA != "PV"){ //메인일경우
			$("#AREA").removeAttr("readonly");
			$("#ZONE").removeAttr("readonly");
			$("#ZONE").val("");
			userInfoData.ZONE = "";
		}else if(userInfoData.AREA == "PV"){
			$("#ZONE").attr("readonly","readonly");
		}*/
		
		//탭4 splitter
		//$("#tabs4").splitter({minAsize:100,maxAsize:600,splitVertical:true,A:$('#leftPane'),B:$('#rightPane'),slave:$("#rightSplitterContainer"),closeableto:0});
		//$('#tabs4').jqxSplitter({ width: 600, height: 700, panels: [{ size: 600 }] });
        //$('#rightSplitterContainer').jqxSplitter({ width: '100%', height: '100%', orientation: 'horizontal', panels: [{ size: '60%', collapsible: false }] });
    
	}); 
	
	var searchType = true;
	
	
	function searchList(){
		searchType = true;
		if(validate.check("searchArea")){
		  //alert('getSelectedTabIndex:'+getSelectedTabIndex());
			var param = inputList.setRangeParam("searchArea");
			var tabSelectedIdx=getSelectedTabIndex();
			if( tabSelectedIdx != null && tabSelectedIdx==0 ){
				gridList.gridList({
			    	id : "tab_1_grid",
			    	param : param
			    });
			}
			
			if( tabSelectedIdx != null && tabSelectedIdx==0 && tab_1_grid__SIMKEY != ''){ 
				param.put("SIMKEY", tab_1_grid__SIMKEY);
				gridList.gridList({
			    	id : "tab_2_1_grid",
			    	param : param
			    });
	
			  //alert(getSelectIndex("tab_2_1_grid"))// :  포커스가 위치한 행 

				var rowVal='';
				try{
					rowVal = gridList.getColData("tab_2_1_grid", gridList.getSelectIndex("tab_2_1_grid"), "DELORD");//getSelectIndex("tab_2_1_grid"))// :  포커스가 위치한 행 
				}catch(e){}
				tab_2_1_grid__DELORD=rowVal; 
			
			    if( tab_2_1_grid__DELORD != ''){
					param.put("DELORD", tab_2_1_grid__DELORD);
					gridList.gridList({
				    	id : "tab_2_2_grid",
				    	param : param
				    });
			    }
			}

			if( tabSelectedIdx != null && tabSelectedIdx==2 && tab_1_grid__SIMKEY != ''){
				//탭 3
				gridList.gridList({
			    	id : "tab_3_grid",
			    	param : param
			    });

				var rowVal='';
				try{
					rowVal = gridList.getColData("tab_3_grid", gridList.getSelectIndex("tab_3_grid"), "RUTEKY");//getSelectIndex("tab_2_1_grid"))// :  포커스가 위치한 행 
				}catch(e){}
				tab_3_grid__RUTEKY=rowVal;

				searchTab_3_List();
			}

			if( tabSelectedIdx != null && tabSelectedIdx==3 && tab_1_grid__SIMKEY != ''){
				//탭 4
				gridList.gridList({
			    	id : "tab_4_grid",
			    	param : param
			    });

				rowVal = gridList.getColData("tab_4_grid", rowNum, "RUTEKY");
				tab_4_grid__RUTEKY=rowVal; 
				
				searchTab_4_1_List();
			} 
		}
	}
	
	
	function gridListEventDataBindEnd(gridId, dataCount){
		if(gridId == "tab_1_grid"){ 
			var rowVal='';
			try{
				rowVal = gridList.getColData("tab_1_grid", gridList.getSelectIndex("tab_1_grid"), "SIMKEY"); // 포커스가 위치한 행 
				tab_1_grid__SIMKEY=rowVal;
			}catch(e){
				;
			}
			//alert(gridList.getGridDataCount("tab_1_grid"));// : 데이터  행  수 
		} 

		if(gridId == "tab_2_1_grid"){  
			if(gridList.getGridDataCount("tab_2_1_grid") == 0){// : 데이터  행  수  
				//상세 초기화.
				gridList.resetGrid("tab_2_2_grid");
			}
		}

		if(gridId == "tab_3_grid"){  
			if(gridList.getGridDataCount("tab_3_grid") == 0){// : 데이터  행  수  
				//상세 초기화.
				gridList.resetGrid("tab_3_1_grid");
			}
		}
		
		if(gridId == "tab_3_1_grid"){  
			if(gridList.getGridDataCount("tab_3_1_grid") == 0){// : 데이터  행  수  
				//상세 초기화.
				gridList.resetGrid("tab_3_2_grid");
			}
		}

		if(gridId == "tab_4_grid"){  
			if(gridList.getGridDataCount("tab_4_grid") == 0){// : 데이터  행  수  
				//상세 초기화.
				gridList.resetGrid("tab_4_1_grid");
			}
		}
	}

	var bCalculatingCst=false; 
	function gridListEventColValueChange(gridId, rowNum, colName, colValue){
		if(gridId == "tab_3_grid" && colName == "FWDCD"){  //운송사
			if(colValue != ""){
				var param = new DataMap();
				param.put("FWDKEY",colValue);
				var json = netUtil.sendData({
					module : "TmsAdmin",
					command : "FWDKEYval",
					sendType : "map",
					param : param
				});
				if(json.data["CNT"] > 0) {
					var param = new DataMap();
					param.put("FWDKEY",colValue);
					var json = netUtil.sendData({
						module : "TmsAdmin",
						command : "FWDKEYnm",
						sendType : "map",
						param : param
					});
					 if(json && json.data){
						gridList.setColValue("tab_3_grid", rowNum, "FWDNME", json.data["FWDNME"]);  
					 } 
					checkValidationType = true;
				 }else if (json.data["CNT"] < 1) {			
					commonUtil.msgBox("VALID_M0227", colValue);					
					gridList.setColValue("tab_3_grid", rowNum, "FWDCD", ""); 
					gridList.setColValue("tab_3_grid", rowNum, "FWDNME", ""); 
					checkValidationType = false;
				 }			
			}else if(colValue==""){
				gridList.setColValue("tab_3_grid", rowNum, "FWDNME", "");
				checkValidationType = true;
			}
		}
		
		if(gridId == "tab_3_grid" 
			      && ( 
			    		colName == "PLNPOT" // 운송계획지점
				      ||colName == "SHPTYP" // 선적유형
				      ||colName == "FWDCD"  // 운송사
				      ||colName == "VHCTYP" // 차량유형(차량제원)
				      ||colName == "ROUTE"  // 선적경로
				      ||colName == "SVCLVL" // 서비스레벨
				      ||colName == "CONRND" // 왕복조건
				      ||colName == "CONSIG" // 독차조건
			         )
		  ){ 
			if(!bCalculatingCst){
				bCalculatingCst=true;//계산시작.여러번 호출방지.
				var PLNPOT = gridList.getColData("tab_3_grid", rowNum, "PLNPOT");
				var SHPTYP = gridList.getColData("tab_3_grid", rowNum, "SHPTYP");
				var FWDCD  = gridList.getColData("tab_3_grid", rowNum, "FWDCD");
				var VHCTYP = gridList.getColData("tab_3_grid", rowNum, "VHCTYP");
				var ROUTE  = gridList.getColData("tab_3_grid", rowNum, "ROUTE");
				var SVCLVL = gridList.getColData("tab_3_grid", rowNum, "SVCLVL");
				var CONRND = gridList.getColData("tab_3_grid", rowNum, "CONRND");
				var CONSIG = gridList.getColData("tab_3_grid", rowNum, "CONSIG");
			
				var param = new DataMap();
				param.put("PLNPOT",PLNPOT);
				param.put("SHPTYP",SHPTYP);
				param.put("FWDCD",FWDCD);
				param.put("VHCTYP",VHCTYP);
				param.put("ROUTE",ROUTE);
				param.put("SVCLVL",SVCLVL);
				param.put("CONRND",CONRND);
				param.put("CONSIG",CONSIG);
				
				var json = netUtil.sendData({
					module : "TmsAdmin",
					command : "FN_CALCST",
					sendType : "map",
					param : param
				});
				
				if(json && json.data){
					gridList.setColValue("tab_3_grid", rowNum, "STDCST", json.data["STDCST"]);//표준운임
					gridList.setColValue("tab_3_grid", rowNum, "CASCST", json.data["CASCST"]);//혼적운임 - 건수
					gridList.setColValue("tab_3_grid", rowNum, "RDTCST", json.data["RDTCST"]);//예상운임(반입/왕복)
					gridList.setColValue("tab_3_grid", rowNum, "SIGCST", json.data["SIGCST"]);//예상운임(독차)
					gridList.setColValue("tab_3_grid", rowNum, "NODCST", json.data["NODCST"]);//예상운임(혼적-구간)
					gridList.setColValue("tab_3_grid", rowNum, "TOTCST", json.data["TOTCST"]);//예상운임(TOTLA)  
				}
				bCalculatingCst=false;//계산시작.여러번 호출방지.
			}//bCalculatingCst
		}
	}
	
	function getSelectedTabIndex() {  
	    return $("#bottomTabs").tabs('option', 'active');
	}
	
	function commonBtnClick(btnName){
		if(btnName == "Search"){
			searchList();
		}else if(btnName == "Save"){  
			saveData();
		}else if(btnName == "SaveSimul"){
			//선택여부 확인.
			if(gridList.getGridBox("tab_2_1_grid").selectRow.size() == 0){ 
				commonUtil.msgBox("VALID_M0006");
				return;
			}
			page.searchHelp($('#RTPCD'),'SHRTPSH'); 
			//saveDataSimul();
		}else if(btnName == "Manual"){
			//선택여부 확인.
			if(gridList.getGridBox("tab_2_1_grid").selectRow.size() == 0){ 
				commonUtil.msgBox("VALID_M0006");
				return;
			}
			page.searchHelp($('#VHCTYP'),'SHVHCTY'); 
			//saveDataSimul();
		}else if(btnName == "Split"){
			openPopForSplitDn();
		}else if(btnName == "SaveVhc"){ //결과탭3- 차량정보 저장. 
			saveDataVhc();
		}else if(btnName == "SaveVhcReq"){ //결과탭3- 차량등록요청. 
			saveDataVhcReq();
		}else if(btnName == "DeleteVhc"){ //결과탭3- 차량정보 할당취소. 
			deleteDataVhc();
		}else if(btnName == "DnCmp"){ //결과탭3- 배차확정. 
			updateData("CMP");
		}else if(btnName == "DnCancel"){ //결과탭3- 배차취소. 
			updateData("FAL");
		}else if(btnName == "Load"){ //결과탭3- 적재 
			load();
		}else if(btnName == "DeleteDn"){ //결과탭2- 미할당- 취소. 
			deleteDn();
		}else if(btnName == "TestMap"){ //다음맵 test. 
			//iframe daum_map
		  //$("#info.route.searchBox.toggleVia").click();//.trigger("click");
			$("#info.route.searchBox.toggleVia").trigger("click");
		} 
	}
	 
	// 시뮬레이션명 저장.
	function saveData(){ 
		if(!commonUtil.msgConfirm(configData.MSG_MASTER_SAVE_CONFIRM)){
			return;
		} 
		

		var tab_1_grid = gridList.getGridData("tab_1_grid");
		
	  //var param = new DataMap(); 
		var param = inputList.setRangeParam("searchArea");
		
		param.put("tab_1_grid", tab_1_grid);  
		param.put("SIMKEY", tab_1_grid__SIMKEY); 

		//alert(param);
		var json = netUtil.sendData({
			url : "/tms/dsp/json/saveMD01.data",
			param : param
		});
		 
		
		//alert(commonUtil.getMsg(json.data));
		if(json){
			if(json.data){
				gridList.resetGrid("tab_1_grid");
				searchList();
			}
		}
	}
	
	// 시뮬레이션 요청.
	function saveDataSimul(rtpcdNm){ 
		if(!commonUtil.msgConfirm(commonUtil.getMsg("TMS_T0007",rtpcdNm))){
			return;
		} 
		 
		//====================================
		//배차시뮬레이션 요청 -capa 채크
		//==================================== 
		var param = inputList.setRangeParam("searchArea");

		var checkRows=gridList.getGridBox("tab_2_1_grid").selectRow.keys();
		var checkDelord;
		var checkDelord_IN="";
		for( i=0;i < checkRows.length;i++ ){
			checkDelord=gridList.getColData("tab_2_1_grid", checkRows[i], "DELORD"); 
			if( i > 0 ){
				checkDelord_IN +=",";
			}
			checkDelord_IN += "'"+checkDelord+"'";
		}
		param.put("DELORD_IN", checkDelord_IN); 
		param.put("SIMKEY", tab_1_grid__SIMKEY);
		param.put("RTPCD", $('#RTPCD').val()); 
		param.put("WAREKY", $('#WAREKY').val()); 

		var json = netUtil.sendData({ 
			url : "/tms/dsp/json/checkMD01Simul.data",
			param : param
		});

		if (json.data != null && json.data["DELORD"] > 0) {
			commonUtil.msgBox("TMS_E0007",json.data["DELORD"]+'['+json.data["UNIT_TYPE"]+']');
			return;
		}
		//====================================
			
			
		var tab_1_grid = gridList.getGridData("tab_1_grid");
		
	  //var param = new DataMap(); 
		var param = inputList.setRangeParam("searchArea");
		
		param.put("tab_1_grid", tab_1_grid);   
		var checkRows=gridList.getGridBox("tab_2_1_grid").selectRow.keys();
		var checkDelord;
		var checkDelord_IN="";
		for( i=0;i < checkRows.length;i++ ){
			checkDelord=gridList.getColData("tab_2_1_grid", checkRows[i], "DELORD"); 
			if( i > 0 ){
				checkDelord_IN +=",";
			}
			checkDelord_IN += "'"+checkDelord+"'";
		}
		param.put("DELORD_IN", checkDelord_IN); 
		param.put("SIMKEY", tab_1_grid__SIMKEY);
		param.put("RTPCD", $('#RTPCD').val());  
		param.put("WAREKY", $('#WAREKY').val()); 

		//alert(param);
		var json = netUtil.sendData({
			url : "/tms/dsp/json/saveMD01Simul.data",
			param : param
		});
		
		//alert(commonUtil.getMsg(json.data)); 
		if(json && json.data){
			var retval = json.data["p_retval"] ;
			if(retval == 'FAIL' ){
				var errinfo = json.data["p_errinfo"] ;
				alert(errinfo);
				//return false; 
			} 
			 
			//결과탭: tabs3 focus 
			$('#bottomTabs').tabs("option", "active", 2); 

			//button 활성화
			changeBtn('tabs3');
			searchTab_3_List();
		}

		//시뮬레이션 요청 - 처리 결과 건수 alert
		if (json.data != null && json.data["DN_TOTAL_CNT"] > 0) {
			commonUtil.msgBox("TMS_S0008",new Array( json.data["DN_TOTAL_CNT"], json.data["SIM_CNT"], json.data["NEW_CNT"] ) );
			return;
		}
	}
	
	// 수동배차.
	function saveManualVhc(vhctyp){ 
		if(!commonUtil.msgConfirm(commonUtil.getMsg("TMS_T0006",vhctyp))){
			return;
		} 
		 
		//====================================
		//수동배차요청
		//==================================== 
		var param = inputList.setRangeParam("searchArea");

		var checkRows=gridList.getGridBox("tab_2_1_grid").selectRow.keys();
		var checkDelord;
		var checkDelord_IN="";
		for( i=0;i < checkRows.length;i++ ){
			checkDelord=gridList.getColData("tab_2_1_grid", checkRows[i], "DELORD"); 
			if( i > 0 ){
				checkDelord_IN +=",";
			}
			checkDelord_IN += "'"+checkDelord+"'";
		}
		param.put("DELORD_IN", checkDelord_IN); 
		param.put("SIMKEY", tab_1_grid__SIMKEY);
		param.put("VHCTYP", $('#VHCTYP').val()); //차량유형코드
		param.put("WAREKY", $('#WAREKY').val()); 

		var json = netUtil.sendData({ 
			url : "/tms/dsp/json/saveMD01ManualVhc.data",
			param : param
		});

		if (json.data != null && json.data["DELORD"] > 0) {
			commonUtil.msgBox("TMS_E0007",json.data["DELORD"]+'['+json.data["UNIT_TYPE"]+']');
			return;
		} 

		if(json && json.data){
			var retval = json.data["p_retval"] ;
			if(retval == 'FAIL' ){
				var errinfo = json.data["p_errinfo"] ;
				alert(errinfo);
				//return false; 
			} 
			 
			//결과탭: tabs3 focus 
			$('#bottomTabs').tabs("option", "active", 2); 

			//button 활성화
			changeBtn('tabs3');
			searchTab_3_List();
		} 
	}
	
	// 탭3:차량정보 저장.
	function saveDataVhc(){ 
		if(!commonUtil.msgConfirm(configData.MSG_MASTER_SAVE_CONFIRM)){
			return;
		} 
		 
		var tab_1_grid = gridList.getGridData("tab_1_grid");

		var tab_3_grid = gridList.getGridData("tab_3_grid");
		
	  //var param = new DataMap(); 
		var param = inputList.setRangeParam("searchArea");
		
		param.put("tab_1_grid", tab_1_grid); 
		param.put("tab_3_grid", tab_3_grid); 
		param.put("SIMKEY", tab_1_grid__SIMKEY); 

		//alert(param);
		var json = netUtil.sendData({
			url : "/tms/dsp/json/saveMD01Vhc.data",
			param : param
		});
		 
		//alert(commonUtil.getMsg(json.data));
		if(json){
			if(json.data){
				gridList.resetGrid("tab_3_grid");
				searchTab_3_List();
			}
		}
	} 
	
	// 탭3:차량등록요청.
	function saveDataVhcReq(){ 
		if(!commonUtil.msgConfirm(configData.MSG_MASTER_SAVE_CONFIRM)){
			return;
		} 
		 
		//채크 row 상태 변경.
		var checkRows=gridList.getGridBox("tab_3_grid").selectRow.keys(); 
		
		for( i=0;i < checkRows.length;i++ ){ 
		  gridList.setColValue("tab_3_grid", checkRows[i], "GRowState", "U"); 
		}
		
		var tab_1_grid = gridList.getGridData("tab_1_grid");

		var tab_3_grid = gridList.getGridData("tab_3_grid");
		
		
	  //var param = new DataMap(); 
		var param = inputList.setRangeParam("searchArea");
		
		param.put("tab_1_grid", tab_1_grid); 
		param.put("tab_3_grid", tab_3_grid); 
		param.put("SIMKEY", tab_1_grid__SIMKEY); 

		
		//alert(param);
		var json = netUtil.sendData({
			url : "/tms/dsp/json/saveMD01VhcReq.data",
			param : param
		});
		 
		//alert(commonUtil.getMsg(json.data));
		if(json){
			if(json.data){
				gridList.resetGrid("tab_3_grid");
				searchTab_3_List();
			}
		}
	} 

	// 탭2:미할당-취소(삭제) .
	function deleteDn(){  
		//선택여부 확인.
		if(gridList.getGridBox("tab_2_1_grid").selectRow.size() == 0){ 
			commonUtil.msgBox("VALID_M0006");
			return;
		}
		
		if(!commonUtil.msgConfirm(configData.MSG_MASTER_SAVE_CONFIRM)){
			return;
		} 
		 
		var tab_1_grid = gridList.getGridData("tab_1_grid");
 
		var tab_2_1_grid = gridList.getGridData("tab_2_1_grid");
		
	  //var param = new DataMap(); 
		var param = inputList.setRangeParam("searchArea");
		
		param.put("tab_1_grid", tab_1_grid); 
		param.put("tab_2_1_grid", tab_2_1_grid); 
		param.put("SIMKEY", tab_1_grid__SIMKEY); 

		var checkRows=gridList.getGridBox("tab_2_1_grid").selectRow.keys();
		var checkDelord;
		var checkDelord_IN="";
		for( i=0;i < checkRows.length;i++ ){
			checkDelord=gridList.getColData("tab_2_1_grid", checkRows[i], "DELORD"); 
			if( i > 0 ){
				checkDelord_IN +=",";
			}
			checkDelord_IN += "'"+checkDelord+"'";
		}
		param.put("DELORD_IN", checkDelord_IN); 
		param.put("SIMKEY", tab_1_grid__SIMKEY);
		
		//alert(param);
		var json = netUtil.sendData({
			url : "/tms/dsp/json/deleteMD01Dn.data",
			param : param
		});
		 
		//alert(commonUtil.getMsg(json.data));
		if(json){
			if(json.data){
				gridList.resetGrid("tab_2_1_grid");
				gridList.resetGrid("tab_2_2_grid");
				searchTab_2_1_List();
			}

			var retval = json.data["p_retval"] ;
			if(retval == 'FAIL' ){
				var errinfo = json.data["p_errinfo"] ;
				alert(errinfo);
				//return false; 
			} else if(retval == 'SUCC' ){
				commonUtil.msgBox("TMS_S0007");//취소하였습니다.
				//return false; 
			}
		}
	} 
	 
	// 탭3:차량정보삭제-할당취소 .
	function deleteDataVhc(){  
		//선택여부 확인.
		if(gridList.getGridBox("tab_3_grid").selectRow.size() == 0){ 
			commonUtil.msgBox("VALID_M0006");
			return;
		}
		
		//취소하시겠습니까?
		if(!commonUtil.msgConfirm(commonUtil.getMsg("TMS_M0005"))){
			return;
		} 
		 
		var tab_1_grid = gridList.getGridData("tab_1_grid");

		//채크 row 상태 변경.
		var checkRows=gridList.getGridBox("tab_3_grid").selectRow.keys(); 
		for( i=0;i < checkRows.length;i++ ){ 
		  gridList.setColValue("tab_3_grid", checkRows[i], "GRowState", "U"); 
		}
		
		
		var tab_3_grid = gridList.getGridData("tab_3_grid");
		
	  //var param = new DataMap(); 
		var param = inputList.setRangeParam("searchArea");
		
		param.put("tab_1_grid", tab_1_grid); 
		param.put("tab_3_grid", tab_3_grid); 
		param.put("SIMKEY", tab_1_grid__SIMKEY); 

		//alert(param);
		var json = netUtil.sendData({
			url : "/tms/dsp/json/deleteMD01Vhc.data",
			param : param
		});
		 
		//alert(commonUtil.getMsg(json.data));
		if(json){
			if(json.data){
				gridList.resetGrid("tab_3_grid");
				searchTab_3_List();
			}
		}
	} 
		
	// 탭3:배차확정/배차취소
	function updateData(STATIT){  
		//선택여부 확인.
		if(gridList.getGridBox("tab_3_grid").selectRow.size() == 0){ 
			commonUtil.msgBox("VALID_M0006");
			return;
		}
		
		if(!commonUtil.msgConfirm(configData.MSG_MASTER_SAVE_CONFIRM)){
			return;
		} 
		 
		var tab_1_grid = gridList.getGridData("tab_1_grid");

		//채크 row 상태 변경.
		var checkRows=gridList.getGridBox("tab_3_grid").selectRow.keys(); 
		for( i=0;i < checkRows.length;i++ ){ 
		  gridList.setColValue("tab_3_grid", checkRows[i], "GRowState", "U"); 
		}
		
		
		var tab_3_grid = gridList.getGridData("tab_3_grid");
		
	  //var param = new DataMap(); 
		var param = inputList.setRangeParam("searchArea");
		
		param.put("tab_1_grid", tab_1_grid); 
		param.put("tab_3_grid", tab_3_grid); 
		param.put("STATIT", STATIT);//변경할 상태  

		//alert(param);
		var json = netUtil.sendData({
			url : "/tms/dsp/json/updateMD01Statit.data",
			param : param
		});
		 
		//alert(commonUtil.getMsg(json.data));
		if(json){
			if(json.data){
				gridList.resetGrid("tab_3_grid");
				searchTab_3_List();
			}
		}
	} 
	
	function searchHelpEventOpenBefore(searchCode, gridType){
		if(searchCode == "SHAREMA"){
			return dataBind.paramData("searchArea");
		}else if(searchCode == "SHWAHMA"){
			return dataBind.paramData("searchArea");
		}else if (searchCode == "SHRTPSH") {
			return dataBind.paramData("searchArea");
		}
		
		if(searchCode == "SHCMCDV"){

			//var param =dataBind.paramData("searchArea");
			var param = inputList.setRangeParam("searchArea");
			
			if($inputObj.name != null){
				if($inputObj.name == "SFRGR"){   //차량유형
					param.put("CMCDKY", "VHCTYP");
				}
			}else{
				if($inputObj.attr("name") == "SFRGR"){
					param.put("CMCDKY", "VHCTYP");	
				}
			}
			return param;
		}
	}

	function gridListEventRowClick(gridId, rowNum, colName){ 
		gridListEventRowDblclick(gridId, rowNum,colName); 
	}
	
	function gridListEventRowDblclick(gridId, rowNum, colName){
		var rowVal;
		if(gridId == "tab_1_grid" && colName !='SHORTX'){
			if(gridList.getColData("tab_1_grid", rowNum, "STATUS") == "C"){
				return false;
			}
 
			rowVal = gridList.getColData("tab_1_grid", rowNum, "SIMKEY");
			tab_1_grid__SIMKEY=rowVal;
			
			lastFocusNum=rowNum;
			searchTab_2_1_List();
		}
		if(gridId == "tab_2_1_grid"){
			if(gridList.getColData("tab_2_1_grid", rowNum, "STATUS") == "C"){
				return false;
			}

			rowVal = gridList.getColData("tab_2_1_grid", rowNum, "DELORD");
			tab_2_1_grid__DELORD=rowVal;
			searchTab_2_2_List();
		}
		

		if(gridId == "tab_3_grid" && colName !='SHORTX'){
			if(gridList.getColData("tab_3_grid", rowNum, "STATUS") == "C"){
				return false;
			}

			rowVal = gridList.getColData("tab_3_grid", rowNum, "RUTEKY");
			tab_3_grid__RUTEKY=rowVal;
			
			searchTab_3_1_List();
		}
		if(gridId == "tab_3_1_grid"){
			if(gridList.getColData("tab_3_1_grid", rowNum, "STATUS") == "C"){
				return false;
			}

			rowVal = gridList.getColData("tab_3_1_grid", rowNum, "DELORD");
			tab_3_1_grid__DELORD=rowVal;
			searchTab_3_2_List();

			//tabs_3_2 focus 
			$('#bottomTabs_3').tabs("option", "active", 1); 
		}
		if(gridId == "tab_4_grid" && colName !='SHORTX'){
			if(gridList.getColData("tab_4_grid", rowNum, "STATUS") == "C"){
				return false;
			}

			rowVal = gridList.getColData("tab_4_grid", rowNum, "RUTEKY");
			tab_4_grid__RUTEKY=rowVal; 
			
			searchTab_4_1_List();
		}
	}
 
	function searchTab_2_1_List(){ 
		var param = inputList.setRangeParam("searchArea");
		param.put("SIMKEY", tab_1_grid__SIMKEY);
		
		gridList.gridList({
			id : "tab_2_1_grid",
			param : param
		});

		//tabs2 focus 
		$('#bottomTabs').tabs("option", "active", 1); 
 
		//button 활성화
		changeBtn('tabs2');
		
		//default 조회(상세 ITEM) 

		var rowVal='';
		try{
			rowVal = gridList.getColData("tab_2_1_grid", gridList.getSelectIndex("tab_2_1_grid"), "DELORD");//getSelectIndex("tab_2_1_grid"))// :  포커스가 위치한 행 
		}catch(e){}
		tab_2_1_grid__DELORD=rowVal;
		
		if( tab_2_1_grid__DELORD != null && tab_2_1_grid__DELORD != ''){
			param.put("DELORD", tab_2_1_grid__DELORD);
			
			gridList.gridList({
				id : "tab_2_2_grid",
				param : param
			}); 
		}
	}
	 
	function searchTab_2_2_List(){ 
		var param = inputList.setRangeParam("searchArea");
		param.put("SIMKEY", tab_1_grid__SIMKEY);
		param.put("DELORD", tab_2_1_grid__DELORD);
		 
		gridList.gridList({
			id : "tab_2_2_grid",
			param : param
		}); 
	}
	 

	function searchTab_3_List(){
		if( tab_1_grid__SIMKEY != '' ){
			var param = inputList.setRangeParam("searchArea");
			param.put("SIMKEY", tab_1_grid__SIMKEY);
			
			gridList.gridList({
				id : "tab_3_grid",
				param : param
			});
		} 
		//tabs3 focus 
		$('#bottomTabs').tabs("option", "active", 2); 
 
		//button 활성화
		changeBtn('tabs3');
		
		var rowVal='';
		try{
		rowVal = gridList.getColData("tab_3_grid", gridList.getSelectIndex("tab_3_grid"), "RUTEKY");//getSelectIndex("tab_2_1_grid"))// :  포커스가 위치한 행 
		}catch(e){}
		
		tab_3_grid__RUTEKY=rowVal;
		if( tab_3_grid__RUTEKY != null && tab_3_grid__RUTEKY != '' ){
			searchTab_3_1_List();
		}
	}
	
	function searchTab_3_1_List(){ 
		var param = inputList.setRangeParam("searchArea");
		param.put("SIMKEY", tab_1_grid__SIMKEY);
	    param.put("RUTEKY", tab_3_grid__RUTEKY);
		
		gridList.gridList({
			id : "tab_3_1_grid",
			param : param
		});
		 
		//button 활성화
		changeBtn('tabs3');
  
		var rowVal='';
		try{
			rowVal = gridList.getColData("tab_3_grid", gridList.getSelectIndex("tab_3_grid"), "DELORD");//getSelectIndex("tab_2_1_grid"))// :  포커스가 위치한 행 
		}catch(e){}
		
		tab_3_1_grid__DELORD=rowVal;
		if( tab_3_1_grid__DELORD != null && tab_3_1_grid__DELORD != '' ){
			searchTab_3_2_List();
		}
	}
	 
	function searchTab_3_2_List(){ 
		var param = inputList.setRangeParam("searchArea");
		param.put("SIMKEY", tab_1_grid__SIMKEY);
		param.put("DELORD", tab_3_1_grid__DELORD);
		 
		gridList.gridList({
			id : "tab_3_2_grid",
			param : param
		}); 
	}
	

	function searchTab_4_List(){  
		if( tab_1_grid__SIMKEY != '' ){
			var param = inputList.setRangeParam("searchArea");
			param.put("SIMKEY", tab_1_grid__SIMKEY);
			
			gridList.gridList({
				id : "tab_4_grid",
				param : param
			});
		}  
		//button 활성화
		//changeBtn('tabs4');

		var rowVal='';
		try{
			rowVal = gridList.getColData("tab_4_grid", gridList.getSelectIndex("tab_4_grid"), "RUTEKY");//getSelectIndex("tab_2_1_grid"))// :  포커스가 위치한 행 
		}catch(e){}
		
		tab_4_grid__RUTEKY=rowVal;
		if( tab_4_grid__RUTEKY != null && tab_4_grid__RUTEKY != '' ){
			searchTab_4_1_List();
		}
	}

	function searchTab_4_1_List(){ 
		var param = inputList.setRangeParam("searchArea");
		param.put("SIMKEY", tab_1_grid__SIMKEY);
	    param.put("RUTEKY", tab_4_grid__RUTEKY);
		
		gridList.gridList({
			id : "tab_4_1_grid",
			param : param
		});
		
		//gridList.gridList({
		//	id : "tab_3_2_grid",
		//	param : param
		//});

		//tabs3 focus 
		//$('#bottomTabs').tabs("option", "active", 2); 
 
		//button 활성화
		//changeBtn('tabs4');
	}

	function openPopForSplitDn(){ 
			var param = inputList.setRangeParam("searchArea");
			param.put("SIMKEY", tab_1_grid__SIMKEY);
			
			/**
			var json = netUtil.sendData({
				url : "/tms/dsp/json/TMD01.data",
				param : param
			});
			
			if(json && json.data){
				commonUtil.popupOpen("/common/lang/view.xml", "500", "500");
			}
			**/
			//commonUtil.popupOpen("/tms/dsp/TMD01_P.data", "1024", "768");

			var rowData = gridList.getRowData("tab_1_grid", lastFocusNum);
			/*
			if(rowData.get("QCTYPE").trim() == ""){
				alert("무검사 상품입니다.");
				return;
			}
			*/
			dataBind.paramData("searchArea", rowData); 
		    page.linkPopOpen("/tms/dsp/TMD01_P.page", rowData); 
			

		  //page.linkPopOpen("/wms/inbound/GR01POP1.page", rowData);
			
	}
	
	function searchHelpEventCloseAfter(menuId, tp, retVal ){
	    //시뮬레이션 요청
		if(menuId == "SHRTPSH" && retVal !='' && retVal !='undefined'){
			saveDataSimul(retVal);
		}//수동배차
		else if(menuId == "SHVHCTY" && retVal !='' && retVal !='undefined'){
			saveManualVhc(retVal);
		}
	}
	
	
	// 탭3:적재 
	function load(){  
		//선택여부 확인.
		if(gridList.getGridBox("tab_3_grid").selectRow.size() == 0){ 
			commonUtil.msgBox("VALID_M0006");
			return;
		}
		
		if(!commonUtil.msgConfirm(configData.MSG_MASTER_SAVE_CONFIRM)){
			return;
		} 
		 
		var tab_1_grid = gridList.getGridData("tab_1_grid");

		//채크 row 상태 변경.
		var checkRows=gridList.getGridBox("tab_3_grid").selectRow.keys();
		var checkRuteky="";
		
		for( i=0;i < checkRows.length;i++ ){ 
			checkRuteky=gridList.getColData("tab_3_grid", checkRows[i], "RUTEKY");
			if( checkRuteky =='' ){
			  alert('시뮬레이션을 먼저 수행하세요![RETEKY없음]');
			  return;
			}
			
		    gridList.setColValue("tab_3_grid", checkRows[i], "GRowState", "U"); 
		}
		
		
		var tab_3_grid = gridList.getGridData("tab_3_grid");
		
	  //var param = new DataMap(); 
		var param = inputList.setRangeParam("searchArea");
		
		param.put("tab_1_grid", tab_1_grid); 
		param.put("tab_3_grid", tab_3_grid);  

		//alert(param);
		var json = netUtil.sendData({
			url : "/tms/dsp/json/saveMO01Load.data",
			param : param
		});
		 
		//alert(commonUtil.getMsg(json.data));
		if(json){
			var retval = json.data["p_retval"] ;
			if(retval == 'false' ){
				//var errinfo = json.data["p_errinfo"] ;
			  //alert(retval);
				commonUtil.msgBox("TMS_E0001");
				return false; 
			} else{ 
			  //alert(retval);
				commonUtil.msgBox("TMS_S0001");
			  //return true; 
				
				//팝업오픈.
				openPopForLoad();
			}
		}
	} 
	
	//적재 팝업 오픈
	function openPopForLoad(){ 
		var param = inputList.setRangeParam("searchArea");
		param.put("SIMKEY", tab_1_grid__SIMKEY);
		
		/**
		var json = netUtil.sendData({
			url : "/tms/dsp/json/TMD01.data",
			param : param
		});
		
		if(json && json.data){
			commonUtil.popupOpen("/common/lang/view.xml", "500", "500");
		}
		**/
		//commonUtil.popupOpen("/tms/dsp/TMD01_P.data", "1024", "768");

		var rowData = gridList.getRowData("tab_1_grid", lastFocusNum);
		/*
		if(rowData.get("QCTYPE").trim() == ""){
			alert("무검사 상품입니다.");
			return;
		}
		*/
		dataBind.paramData("searchArea", rowData); 
	    page.linkPopOpen("/tms/dsp/TMD01L.page", rowData);  
	}
	
	function changeBtn(tabnum){
		if( tabnum == 'tabs1' ){//시뮬레이션 
			uiList.setActive("Search", true);//조회
			uiList.setActive("Save", true);//저장 
			uiList.setActive("SaveSimul", false);//시뮤레이션 요청 
			uiList.setActive("SaveVhc", false);//저장,결과(차량등록후 저장) 
			uiList.setActive("SaveVhcReq", false);//차량등록요청  
			uiList.setActive("Split", false);//분활
			uiList.setActive("Manual", false);//수동배차
			uiList.setActive("Load", false);//적재
			uiList.setActive("DnCmp", false);//배차확정
			uiList.setActive("DnCancel", false);//배차취소
			uiList.setActive("DeleteDn", false);//취소(미할당취소)
		} else if( tabnum == 'tabs2' ){//미할당DN 
			uiList.setActive("Search", true);//조회
			uiList.setActive("Save", false);//저장 
			uiList.setActive("SaveSimul", true);//시뮤레이션 요청 
			uiList.setActive("SaveVhc", false);//저장,결과(차량등록후 저장) 
			uiList.setActive("SaveVhcReq", false);//차량등록요청  
			uiList.setActive("Split", true);//분활
			uiList.setActive("Manual", true);//수동배차
			uiList.setActive("Load", false);//적재
			uiList.setActive("DnCmp", false);//배차확정
			uiList.setActive("DnCancel", false);//배차취소
			uiList.setActive("DeleteDn", true);//취소(미할당취소)
		} else if( tabnum == 'tabs3' ){//결과(TEXT)
			uiList.setActive("Search", true);//조회
			uiList.setActive("Save", false);//저장,결과(차량등록후 저장) 
			uiList.setActive("SaveSimul", false);//시뮤레이션 요청 
			uiList.setActive("SaveVhc", true);//저장,결과(차량등록후 저장) 
			uiList.setActive("SaveVhcReq", true);//차량등록요청  
			uiList.setActive("Split", false);//분활
			uiList.setActive("Manual", false);//수동배차
			uiList.setActive("Load", true);//적재
			uiList.setActive("DnCmp", false);//배차확정
			uiList.setActive("DnCancel", true);//배차취소
			uiList.setActive("DeleteDn", false);//취소(미할당취소)
		} else if( tabnum == 'tabs4' ){//결과(MAP)
			uiList.setActive("Search", true);//조회
			uiList.setActive("Save", false);//저장
			uiList.setActive("SaveSimul", false);//시뮤레이션 요청 
			uiList.setActive("SaveVhc", false);//저장,결과(차량등록후 저장) 
			uiList.setActive("SaveVhcReq", false);//차량등록요청  
			uiList.setActive("Split", false);//분활
			uiList.setActive("Manual", false);//수동배차
			uiList.setActive("Load", false);//적재
			uiList.setActive("DnCmp", false);//배차확정
			uiList.setActive("DnCancel", false);//배차취소
			uiList.setActive("DeleteDn", false);//취소(미할당취소)
		} else if( tabnum == 'init' ){//초기화면
			uiList.setActive("Search", true);//조회
			uiList.setActive("Save", true);//저장,결과(차량등록후 저장)
			uiList.setActive("SaveSimul", false);//시뮤레이션 요청 
			uiList.setActive("SaveVhc", false);//저장,결과(차량등록후 저장)
			uiList.setActive("SaveVhcReq", false);//차량등록요청  
			uiList.setActive("Split", false);//분활
			uiList.setActive("Manual", false);//수동배차
			uiList.setActive("Load", false);//적재
			uiList.setActive("DnCmp", false);//배차확정
			uiList.setActive("DnCancel", false);//배차취소
			uiList.setActive("DeleteDn", false);//취소(미할당취소)
		} 
	}
</script>
</head>
<body>
<div class="contentHeader">
	<div class="util">
		<button CB="Search SEARCH BTN_DISPLAY"></button><!-- 조회 -->
		<button CB="Save SAVE STD_SAVE"></button><!-- 저장 -->
		<button CB="SaveSimul SAVE STD_SIMUL"></button><!-- 시뮤레이션 요청 -->
		<button CB="SaveVhc SAVE STD_SAVE"></button><!-- 탭3:차량번호 저장 -->
		<button CB="SaveVhcReq SAVE STD_VHCREQ"></button><!-- 차량등록요청  -->
		<button CB="Split WCANCLE STD_SPLIT"></button><!-- 분활 -->
		<button CB="Manual WORK STD_MANUAL"></button><!-- 수동배차 -->
		<button CB="Load CART STD_LOAD"></button><!-- 적재 -->
		<button CB="DnCmp CHECK STD_DNCMP"></button><!-- 배차확정 -->
		<button CB="DnCancel DELETE STD_DNCANCEL"></button><!-- 배차취소 -->
		<button CB="DeleteDn DELETE STD_CANCEL"></button><!-- 취소(미할당취소) -->
		<button CB="TestMap SAVE STD_SAVE"></button><!-- 저장 -->
	</div>
	<div class="util2">
		<button class="button type2" id="showPop" type="button"><img src="/common/images/ico_btn4.png" alt="List" /></button>
	</div>
</div>

<!-- searchPop -->
<div class="searchPop" id="searchArea">
	<button type="button" class="closer">X</button>
	<div class="searchInnerContainer">
		<p class="util">
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
						<td>
							<input type="text" name="WAREKY" id="WAREKY" UIInput="R,SHWAHMA" value="<%=wareky%>" />
						</td>
					</tr> 
					<tr>
						<th >시뮬레이션ID</th>
						<td>
							<input type="text" name="SIMKEY" id="SIMKEY"  UIInput="R,SIMKEY" />
						</td>
					</tr>
					<tr>
						<th CL="STD_SAEDAT">생성일자</th>
						<td>
							<input type="text" name="CREDAT"  id="CREDAT"  UIInput="R" UIFormat="C Y"/>
						</td>
					</tr>
					<tr>
						<th CL="STD_CREUSR">생성자</th>
						<td>
							<input type="text" name="CREUSR"  id="CREUSR" UIInput="S,CREUSR"  />
						</td>
					</tr>
				</tbody>
			</table>
		</div> 
	</div>
</div>
 
<div id="searchRtpsh" style="display:none"> 
	<div class="searchInnerContainer"> 
		<div class="searchInBox"> 
			<table class="table type1">
				<colgroup>
					<col width="100" />
					<col />
				</colgroup>
				<tbody> 
					<tr> 
						<td> 
							<input type="button" id="RTPCD" name="RTPCD"
								UIInput="S,SHRTPSH" />
							<input type="button" id="VHCTYP" name="VHCTYP"
								UIInput="S,SHVHCTY" />
						</td>
					</tr> 
				</tbody>
			</table>
		</div> 
	</div>
</div>
<!-- //searchPop -->

<!-- content -->
<div class="content">
	<div class="innerContainer">

		<!-- contentContainer -->
		<div class="contentContainer"> 
			<div class="bottomSect type1">
				<button type="button" class="button type2 fullSizer"><img src="/common/images/ico_full.png" alt="Full Size"></button>
				<div class="tabs" id="bottomTabs">
					<ul class="tab type2" >
						<li><a href="#tabs1" onclick="javascript:changeBtn('tabs1');" ><span>시뮬레이션</span></a></li>
						<li><a href="#tabs2" onclick="javascript:changeBtn('tabs2');" ><span>미할당DN</span></a></li>
						<li><a href="#tabs3" onclick="javascript:changeBtn('tabs3');searchTab_3_List();" ><span>결과(TEXT)</span></a></li>
						<li><a href="#tabs4" onclick="javascript:changeBtn('tabs4');searchTab_4_List();" ><span>결과(MAP)</span></a></li>
					</ul>
					<div id="tabs1">
						<div class="section type1">
							<div class="table type2" >
								<div class="tableHeader">
									<table>
										<colgroup>
											<col width="40" /> 
											<col width="100" />
											<col width="200" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
										</colgroup>
										<thead>
											<tr>
												<th CL='STD_NUMBER'>번호</th> 
												<th >시뮬레이션ID</th>
												<th >시뮬레이션명</th>
												<th CL='STD_CREDAT'>생성일자</th>
												<th CL='STD_CRETIM'>생성시간</th>
												<th CL='STD_CREUSR'>생성자</th> 
											</tr>
										</thead>
									</table>
								</div>
								<div class="tableBody">
									<table>
										<colgroup>
											<col width="40" /> 
											<col width="100" />
											<col width="200" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
										</colgroup>
										<tbody id="tab_1_grid">
										<tr CGRow="true">
												<td GCol="rownum">1</td>
												<td GCol="text,SIMKEY" GF="S"></td>
												<td GCol="input,SHORTX" GF="S 200"></td>
												<td GCol="text,CREDAT" GF="S"></td>
												<td GCol="text,CRETIM" GF="S"></td>
												<td GCol="text,CREUSR" GF="S"></td>
											</tr>
										</tbody>
									</table>
								</div>

							</div>
							<div class="tableUtil">
								<div class="leftArea">
									<button type="button" GBtn="find"></button>
									<button type="button" GBtn="sortReset"></button>
									<button type="button" GBtn="layout"></button>
									<button type="button" GBtn="total"></button>
									<button type="button" GBtn="excel"></button>
								</div>
								<div class="rightArea">
									<p class="record" GInfoArea="true"></p>
								</div>
							</div>
						</div>
					</div>
					
				
					<div id="tabs2">			
						<div class="bottomSect top" style="top: 30px;height: 300px">
							<button type="button" class="button type2 fullSizer"><img src="/common/images/ico_full.png" alt="Full Size"></button>
							<div class="tabs" >
								<ul class="tab type2">
									<li><a href="#tabs2"><span >Delivery Note</span></a></li>
								</ul>
								<div >
									<div class="section type1">
										<div class="table type2">
											<div class="tableHeader">
												<table>
													<colgroup>
														<col width="40" /> 
														<col width="40" />
														<col width="60" />
														<col width="60" />
														<col width="100" />
														<col width="80" />
														<col width="80" />
														<col width="80" />
														<col width="80" />
														<col width="80" />
														<col width="80" />
														<col width="80" />
														<col width="80" />
														<col width="80" />
														<col width="80" />
														<col width="80" />
														<col width="80" />
														<col width="100" />
														<col width="80" />
														<col width="80" />
														<col width="80" />
														<col width="80" />
														<col width="80" />
														<col width="80" />
														<col width="80" />
														<col width="80" />
														<col width="80" />
														<col width="80" />
														<col width="80" />
														<col width="80" />
														<col width="80" />
														<col width="80" />
														<col width="80" />
														<col width="80" />
														<col width="80" />
														<col width="80" />
														<col width="80" />
														<col width="80" />
														<col width="80" />
													</colgroup>
													<thead>
														<tr>
															<th CL='STD_NUMBER'>번호</th>
															<th GBtnCheck="true"></th>
															<th >거점</th>
															<th >Plant</th>
															<th >시뮬레이션ID</th>
															<th >시뮬레이션명</th>
															<th >출하지점</th>
															<th >추가출하지점</th>
															<th >원출하지점</th>
															<th >운송계획지점</th>
															<th >출하유형</th>
															<th >선적유형</th>
															<th >판매오더유형</th>
															<th >영업조직</th>
															<th >출하조건</th>
															<th >서비스레벨</th>
															<th >인도조건</th>
															<th >Delivery Note</th>
															<th >도착지코드</th>
															<th >도착지명</th>
															<th >도착지유형</th>
															<th >우편번호</th>
															<th >주소</th>
															<th >배송요청일</th>
															<th >배송요청시간</th>
															<th >판매처</th>
															<th >유통경로</th>
															<th >영업팀</th>
															<th >영업그룹</th>
															<th >출하요청텍스트</th>
															<th >단독배송여부</th>
															<th >톤수제한</th>
															<th >단위1(KG)</th>
															<th >단위2(M2)</th>
															<th >단위3(M3)</th>
															<th >긴급도</th>
															<th >생성일자</th>
															<th >생성시간</th>
															<th >생성자</th>
														</tr>
													</thead>
												</table>
											</div>
											<div class="tableBody" >
												<table>
													<colgroup>
														<col width="40" /> 
														<col width="40" />
														<col width="60" />
														<col width="60" />
														<col width="100" />
														<col width="80" />
														<col width="80" />
														<col width="80" />
														<col width="80" />
														<col width="80" />
														<col width="80" />
														<col width="80" />
														<col width="80" />
														<col width="80" />
														<col width="80" />
														<col width="80" />
														<col width="80" />
														<col width="100" />
														<col width="80" />
														<col width="80" />
														<col width="80" />
														<col width="80" />
														<col width="80" />
														<col width="80" />
														<col width="80" />
														<col width="80" />
														<col width="80" />
														<col width="80" />
														<col width="80" />
														<col width="80" />
														<col width="80" />
														<col width="80" />
														<col width="80" />
														<col width="80" />
														<col width="80" />
														<col width="80" />
														<col width="80" />
														<col width="80" />
														<col width="80" />
													</colgroup>
													<tbody id="tab_2_1_grid">
														<tr CGRow="true">
															<td GCol="rownum">1</td>
															<td GCol="rowCheck" >선택</td>
															<td GCol="text,WAREKY">거점</td> 
															<td GCol="text,WERKS">Plant</td> 
															<td GCol="text,SIMKEY">시뮬레이션ID</td>  
															<td GCol="text,SHORTX">시뮬레이션명</td>
															<td GCol="select,SHPTKY">
																<select CommonCombo="SHPTKY" name="SHPTKY" disabled="disabled"></select>
															</td>
															<td GCol="text,ADDSHP" >추가출하지점</td>  
															<td GCol="text,ORGSHP" >원출하지점</td>
															<td GCol="select,PLNPOT">
																<select CommonCombo="PLNPOT" name="PLNPOT" disabled="disabled"></select>
															</td>
															<td GCol="select,VSART_NM">
																<select CommonCombo="SHMETP" name="VSART_NM" disabled="disabled"></select>
															</td>
															<td GCol="select,SHPTYP">
																<select CommonCombo="DELITP" name="SHPTYP" disabled="disabled"></select>
															</td> 
															<td GCol="text,AUART">판매오더유형</td>
															<td GCol="select,SHTOGB">
																<select CommonCombo="SHTOGB" name="SHTOGB" disabled="disabled"></select>
															</td>
															<td GCol="select,SHPCON">
																<select CommonCombo="SHPCON" name="SHPCON" disabled="disabled"></select>
															</td>
															<td GCol="select,SVCLVL">
																<select CommonCombo="SVCLVL" name="SVCLVL" disabled="disabled"></select>
															</td>															
															<td GCol="text,PAYCON">인도조건</td>
															<td GCol="text,DELORD">Delivery Note</td>
															<td GCol="text,SHPTOP">도착지코드</td>    
															<td GCol="text,SHIPNM">도착지명</td>
															<td GCol="select,SHTOTY_NM">
																<select CommonCombo="STOPTP" name="SHTOTY_NM" disabled="disabled"></select>
															</td>     
															<td GCol="text,SOSTOP">우편번호</td>  
															<td GCol="text,ADDR01">주소</td>  
															<td GCol="text,VDATU">배송요청일</td>  
															<td GCol="text,VTIME">배송요청시간</td>  
															<td GCol="text,KUNAG">판매처</td>
															<td GCol="select,VTWEG">
																<select CommonCombo="VKBUR" name="VTWEG" disabled="disabled"></select>
															</td>															
															<td GCol="text,VKBUR">영업팀</td>  
															<td GCol="text,VKGRP">영업그룹</td>  
															<td GCol="text,GRTXT">출하요청텍스트</td>
															<td GCol="select,MIXLOD">
																<select CommonCombo="MIXLOD" name="MIXLOD" disabled="disabled"></select>
															</td>      
																						<td GCol="select,vhcineq">
																<select CommonCombo="vhcineq" name="vhcineq" disabled="disabled"></select>
															</td>   
															<td GCol="text,UNIT1_KG"  GF="N">단위1(KG)</td>
															<td GCol="text,UNIT2_M2"  GF="N">단위2(M2)</td>
															<td GCol="text,UNIT3_M3"  GF="N">단위3(M3)</td>
															<td GCol="select,URGNT">
																<select CommonCombo="URGNT" name="URGNT" disabled="disabled"></select>
															</td>          
															<td GCol="text,CREDAT" >생성일자</td>      
															<td GCol="text,CRETIM" >생성시간</td>      
															<td GCol="text,CREUSR" >생성자</td>
														</tr>									
													</tbody>
												</table>
											</div>
										</div>
										<div class="tableUtil">
											<div class="leftArea">
												<button type="button" GBtn="find"></button>
												<button type="button" GBtn="sortReset"></button>
												<button type="button" GBtn="layout"></button>
												<button type="button" GBtn="total"></button>
												<button type="button" GBtn="excel"></button>
											</div>
											<div class="rightArea">
												<p class="record" GInfoArea="true"></p>
											</div>
										</div>
									</div>
								</div>					
					        </div>
				        </div> 
					        
					        
						<div class="bottomSect bottom" style="top: 330px">
							<!-- button type="button" class="button type2 fullSizer"><img src="/common/images/ico_full.png" alt="Full Size"></button-->
							<div class="tabs">
								<ul class="tab type2" id="commonMiddleArea"><!-- 탭2 -->
									<li><a href="#tabs2-2"><span >ITEM</span></a></li>
								</ul>
								<div id="tabs2-2">
									<div class="section type1">
										<div class="table type2">
											<div class="tableHeader">
												<table>
													<colgroup>
														<col width="40" /> 
														<col width="100" />
														<col width="80" />
														<col width="80" />
														<col width="80" />
														<col width="80" /> 
														<col width="100" />
														<col width="80" />
														<col width="150" />
														<col width="80" />
														<col width="80" /> 
														<col width="80" />
														<col width="80" />
														<col width="80" />
														<col width="80" />
														<col width="80" /> 
														<col width="80" />
														<col width="80" />
														<col width="80" />
														<col width="80" />
														<col width="80" /> 
														<col width="80" />
														<col width="80" />
														<col width="80" />
														<col width="80" />
														<col width="80" /> 
														<col width="80" />
														<col width="80" />
														<col width="80" />
														<col width="80" />
													</colgroup>
													<thead>
														<tr>
															<th CL='STD_NUMBER'>번호</th>
															<th >Delivery Note</th>
															<th >Delivery Item</th>
															<th >Delivery Detail</th>
															<th >Sales Order No</th>
															<th >Sales Order Item</th>
															<th >Material Group</th>
															<th >Material </th>
															<th >설명</th>
															<th >배치번호</th>
															<th >조장</th>
															<th >조장수</th>
															<th >Delivery Qty</th>
															<th >Delivery UOM</th>
															<th >Gross Weight</th>
															<th >Gross Weight UOM</th>
															<th >Net Weight</th>
															<th >Net Weight UOM</th>
															<th >포장재 유형</th>
															<th >포장재 코드</th>
															<th >포장재 수량</th>
															<th >포장재 수량 단위</th>
															<th >폭</th>
															<th >길이</th>
															<th >높이</th>
															<th >포장재 중량</th>
															<th >적재단수</th>
															<th >생성일자</th>
															<th >생성시간</th>
															<th >생성자</th>
														</tr>
													</thead>
												</table>
											</div>
											<div class="tableBody">
												<table>
													<colgroup>
														<col width="40" /> 
														<col width="100" />
														<col width="80" />
														<col width="80" />
														<col width="80" />
														<col width="80" /> 
														<col width="100" />
														<col width="80" />
														<col width="150" />
														<col width="80" />
														<col width="80" /> 
														<col width="80" />
														<col width="80" />
														<col width="80" />
														<col width="80" />
														<col width="80" /> 
														<col width="80" />
														<col width="80" />
														<col width="80" />
														<col width="80" />
														<col width="80" /> 
														<col width="80" />
														<col width="80" />
														<col width="80" />
														<col width="80" />
														<col width="80" /> 
														<col width="80" />
														<col width="80" />
														<col width="80" />
														<col width="80" />
													</colgroup>
													<tbody id="tab_2_2_grid">
														<tr CGRow="true">
															<td GCol="rownum">1</td>
															<td GCol="text,DELORD" >Delivery Note</td>
															<td GCol="text,DELITN" >Delivery Item</td>
															<td GCol="text,DELIDN" >Delivery Detail</td>
															<td GCol="text,SALORD" >Sales Order No</td>
															<td GCol="text,SALITN" >Sales Order Item</td> 
															<td GCol="text,MATKL" >Material Group</td>
															<td GCol="text,MTLCDE" >Material</td>
															<td GCol="text,MTLTXT" >설명</td>
															<td GCol="text,LOTNUM" >배치번호</td>
															<td GCol="text,JOJANG" >조장</td>
															<td GCol="text,JOJANGSU" >조장수</td>
															<td GCol="text,LFIMG" >Delivery Qty</td>
															<td GCol="text,VRKME" >Delivery UOM</td>
															<td GCol="text,BRGEW" >Gross Weight</td>
															<td GCol="text,BRWEI" >Gross Weight UOM</td>
															<td GCol="text,NTGEW" >Net Weight</td>
															<td GCol="text,NTWEI" >Net Weight UOM</td>
															<td GCol="text,PKTYP" >포장재 유형</td>
															<td GCol="text,PKMATNR" >포장재 코드</td>
															<td GCol="text,MENGE" >포장재 수량</td>
															<td GCol="text,ZMEINS" >포장재 수량 단위</td>
															<td GCol="text,WIDTH"  GF="N">폭</td>
															<td GCol="text,LENGTH" GF="N">길이</td>
															<td GCol="text,HEIGHT" GF="N">높이</td>
															<td GCol="text,PKWEI"  GF="N">포장재 중량</td>
															<td GCol="text,FLTLVL" GF="N">적재단수</td>
															<td GCol="text,CREDAT" >생성일자</td>
															<td GCol="text,CRETIM" >생성시간</td>
															<td GCol="text,CREUSR" >생성자</td>											
														</tr>									
													</tbody>
												</table>
											</div>
										</div>
										<div class="tableUtil"> 
											<div class="leftArea">
												<button type="button" GBtn="find"></button>
												<button type="button" GBtn="sortReset"></button>
												<button type="button" GBtn="layout"></button>
												<button type="button" GBtn="total"></button>
												<button type="button" GBtn="excel"></button>
											</div>
											<div class="rightArea">
												<p class="record" GInfoArea="true"></p>
											</div>
										</div>
									</div>
								</div>					
					        </div>
				        </div> 
			        </div>
					        
					<div id="tabs3">			
						<div class="bottomSect top" style="top: 30px;height: 300px">
							<button type="button" class="button type2 fullSizer"><img src="/common/images/ico_full.png" alt="Full Size"></button>
							<div class="tabs" >
								<ul class="tab type2">
									<li><a href="#tabs3"><span >결과(TEXT)</span></a></li>
								</ul>
								<div >
									<div class="section type1">
										<div class="table type2">
											<div class="tableHeader">
												<table>
													<colgroup>
														<col width="40" /> 
														<col width="40" />
														<col width="50" />
														<col width="100" />
														<col width="100" />
														<col width="120" />
														<col width="100" />
														<col width="100" />
														<col width="100" />
														<col width="100" />
														<col width="100" />
														<col width="80" />
														<col width="80" />
														<col width="80" />
														<col width="80" />
														<col width="80" /> 
														<col width="80" /> 
														<col width="80" />
														<col width="80" />
														<col width="80" />
														<col width="80" />
														<col width="80" />
														<col width="80" />
														<col width="80" />
														<col width="80" /> 
														<col width="80" />
														<col width="80" /> 
														<col width="80" />
														<col width="80" />
														<col width="80" />
														<col width="80" />
														<col width="130" />
														<col width="130" />
														<col width="130" />
														<col width="130" />
														<col width="130" />
														<col width="130" />
														<col width="80" />
														<col width="80" />
														<col width="80" />
													</colgroup>
													<thead>
														<tr>
															<th CL='STD_NUMBER'>번호</th>
															<th GBtnCheck="true"></th>
															<th >거점</th>
															<th >시뮬레이션ID</th>
															<th >시뮬레이션명</th>
															 <th >운송계획지점</th>
															 <th >Doc Section</th>
															 <th >선적유형</th>
															 <th >영업조직</th>
															 <th >왕복조건</th>
															 <th >독차조건</th>
															 <th >회사코드</th>
															 <th >서비스레벨</th> 
															 <th >선적경로</th> 
															 <th >Route ID</th>
															 <th >운송사</th>
															 <th >운송사명</th>
															 <th >차량유형</th>
															 <th >차량유형명</th>
															 <th >차량번호</th>
															 <th >기사명</th>
															 <th >기사전화번호</th>
															 <th >경유지수</th>
															<th >단위1(KG)</th>
															<th >단위2(M2)</th>
															<th >단위3(M3)</th>
															<th >적재율1%(KG)</th>
															<th >적재율2%(M2)</th>
															<th >적재율3%(M3)</th>
															<th >총거리</th>
															<th >총시간</th>
															<th >예상운임(표준)</th>
															<th >예상운임(혼적-건수)</th>
															<th >예상운임(반입/왕복)</th>
															<th >예상운임(독차)</th>
															<th >예상운임(혼적-구간)</th>
															<th >예상운임(TOTLA)</th>
															<th >생성일자</th>
															<th >생성시간</th>
															<th >생성자</th>
														</tr>
													</thead>
												</table>
											</div>
											<div class="tableBody" >
												<table>
													<colgroup>
														<col width="40" /> 
														<col width="40" />
														<col width="50" />
														<col width="100" />
														<col width="100" />
														<col width="120" />
														<col width="100" />
														<col width="100" />
														<col width="100" />
														<col width="100" />
														<col width="100" />
														<col width="80" />
														<col width="80" />
														<col width="80" />
														<col width="80" /> 
														<col width="80" /> 
														<col width="80" />
														<col width="80" />
														<col width="80" />
														<col width="80" />
														<col width="80" />
														<col width="80" />
														<col width="80" />
														<col width="80" /> 
														<col width="80" />
														<col width="80" />
														<col width="80" /> 
														<col width="80" />
														<col width="80" />
														<col width="80" />
														<col width="80" />
														<col width="130" />
														<col width="130" />
														<col width="130" />
														<col width="130" />
														<col width="130" />
														<col width="130" />
														<col width="80" />
														<col width="80" />
														<col width="80" />
													</colgroup>
													<tbody id="tab_3_grid">
														<tr CGRow="true">
															<td GCol="rownum">1</td>
															<td GCol="rowCheck" >선택</td>
															<td GCol="text,WAREKY" >거점</td>  
															<td GCol="text,SIMKEY" >시뮬레이션ID</td> 
															<td GCol="text,SHORTX" >시뮬레이션명</td>
															<td GCol="select,PLNPOT">
																<select CommonCombo="PLNPOT" name="PLNPOT" >운송계획지점</select><!--추가함-->	
															</td>
															<td GCol="select,VGTYP">
																<select CommonCombo="VGTYP" name="VGTYP" disabled="disabled">Doc Section</select>	
															</td>
															<td GCol="select,SHPTYP">
																<select CommonCombo="DELITP" name="SHPTYP" disabled="disabled">선적유형</select>	
															</td>															
															<td GCol="select,SHTOGB">
																<select CommonCombo="SHTOGB" name="SHTOGB" disabled="disabled">영업조직</select>	
															</td>														
															<td GCol="select,CONRND">
																<select CommonCombo="PLYTER" name="CONRND" >왕복조건</select><!--추가함--> 	
															</td>
															<td GCol="select,CONSIG">
																<select CommonCombo="EXCTER" name="CONSIG" >독차조건</select><!--추가함--> 	
															</td>   
															<td GCol="text,LSCNS" >회사코드</td><!--추가함-->															   
															<td GCol="select,SVCLVL">
																<select CommonCombo="SVCLVL" name="SVCLVL" >서비스레벨</select>	
															</td> <!-- 인도조건 아래탭으로 이동함 --> 
															<td GCol="text,ROUTE" >선적경로</td> 
															<td GCol="text,RUTEKY" >Route ID</td> 
															<td GCol="input,FWDCD,SHCPN"  >운송사</td>
															<td GCol="text,FWDNME" >운송사명</td>   
															<td GCol="text,VHCTYP" >차량유형</td>    
															<td GCol="text,VHCSTX" >차량유형명</td>      
															<td GCol="input,VHCFNO" >차량번호</td>     
															<td GCol="input,DRVNM" >기사명</td>       
															<td GCol="input,DRVTL" >기사전화번호</td>       
															<td GCol="text,NUMSTP" >경유지수</td>     
															<td GCol="text,UNIT1_KG"  GF="N">단위1(KG)</td>
															<td GCol="text,UNIT2_M2"  GF="N">단위2(M2)</td>
															<td GCol="text,UNIT3_M3"  GF="N">단위3(M3)</td> 
															<td GCol="text,LOAD_KG"  GF="N">적재율1%(KG)</td>
															<td GCol="text,LOAD_M2"  GF="N">적재율2%(M2)</td>
															<td GCol="text,LOAD_M3"  GF="N">적재율3%(M3)</td>
															<td GCol="text,TOTDIS" GF="N">총거리</td>          
															<td GCol="text,TOTTIM" GF="N">총시간</td>           
															<td GCol="text,STDCST" GF="N">예상운임(표준)</td><!--추가함-->           
															<td GCol="text,CASCST" GF="N">예상운임(혼적-건수)</td><!--추가함-->          
															<td GCol="text,RDTCST" GF="N">예상운임(반입/왕복)</td><!--추가함-->          
															<td GCol="text,SIGCST" GF="N">예상운임(독차)</td><!--추가함-->         
															<td GCol="text,NODCST" GF="N">예상운임(혼적-구간)</td><!--추가함-->          
															<td GCol="text,TOTCST" GF="N">예상운임(TOTLA)</td><!--추가함-->         
															<td GCol="text,CREDAT" >생성일자</td>      
															<td GCol="text,CRETIM" >생성시간</td>      
															<td GCol="text,CREUSR" >생성자</td>												
														</tr>									
													</tbody>
												</table>
											</div>
										</div>
										<div class="tableUtil"> 
											<div class="leftArea">
												<button type="button" GBtn="find"></button>
												<button type="button" GBtn="sortReset"></button>
												<button type="button" GBtn="layout"></button>
												<button type="button" GBtn="total"></button>
												<button type="button" GBtn="excel"></button>
											</div>
											<div class="rightArea">
												<p class="record" GInfoArea="true"></p>
											</div>
										</div>
									</div>
								</div>					
					        </div>
				        </div> 
					        
					        
						<div class="bottomSect bottom" style="top: 330px">
							<!-- button type="button" class="button type2 fullSizer"><img src="/common/images/ico_full.png" alt="Full Size"></button-->
							<div class="tabs" id="bottomTabs_3">
								<ul class="tab type2" id="commonMiddleArea_2"><!-- 탭3 -->
									<li><a href="#tabs3-1"><span >Delivery Note</span></a></li>
									<li><a href="#tabs3-2"><span >ITEM</span></a></li>
								</ul>
								<div id="tabs3-1">
									<div class="section type1">
										<div class="util">
											<button CB="DeleteVhc DELETE STD_UNALLOC"></button><!-- 탭3:차량번호 할당취소 -->
										</div>
										<div class="table type2" style="top:30px;">
											<div class="tableHeader">
												<table>
													<colgroup>
														<col width="40" /> 
														<col width="40" />
														<col width="50" />
														<col width="60" />
														<col width="100" />
														<col width="80" />
														<col width="120" />
														<col width="120" />
														<col width="120" />
														<col width="100" />
														<col width="100" />
														<col width="100" />
														<col width="80" />
														<col width="80" />
														<col width="80" />
														<col width="80" />
														<col width="80" />
														<col width="100" />
														<col width="80" />
														<col width="80" />
														<col width="80" />
														<col width="80" />
														<col width="80" />
														<col width="80" />
														<col width="80" />
														<col width="80" />
														<col width="80" />
														<col width="80" />
														<col width="80" />
														<col width="80" />
														<col width="80" />
														<col width="80" />
														<col width="80" />
														<col width="80" />
														<col width="80" />
														<col width="80" />
														<col width="80" />
														<col width="80" />
													</colgroup>
													<thead>
														<tr>
															<th CL='STD_NUMBER'>번호</th>
															<th GBtnCheck="true"></th>
															<th >거점</th>
															<th >Plant</th>
															<th >시뮬레이션ID</th>
															<th >시뮬레이션명</th>
															<th >출하지점</th>
															<th >추가출하지점</th>
															<th >원출하지점</th><!--아래 운송계획지점 삭제함 -->
															<th >출하유형</th>
															<th >선적유형</th>
															<th >판매오더유형</th>
															<th >영업조직</th>
															<th >출하조건</th>
															<th >서비스레벨</th>
															<th >인도조건</th>
															<th >Delivery Note</th>
															<th >도착지코드</th>
															<th >도착지명</th>
															<th >도착지유형</th>
															<th >우편번호</th>
															<th >주소</th>
															<th >배송요청일</th>
															<th >배송요청시간</th>
															<th >판매처</th>
															<th >유통경로</th>
															<th >영업팀</th>
															<th >영업그룹</th>
															<th >출하요청텍스트</th>
															<th >단독배송여부</th>
															<th >톤수제한</th>
															<th >긴급도</th><!--순서변경함 -->
															<th >단위1(KG)</th>
															<th >단위2(M2)</th>
															<th >단위3(M3)</th>
															<th >생성일자</th>
															<th >생성시간</th>
															<th >생성자</th>
														</tr>
													</thead>
												</table>
											</div>
											<div class="tableBody" >
												<table>
													<colgroup>
														<col width="40" /> 
														<col width="40" />
														<col width="50" />
														<col width="60" />
														<col width="100" />
														<col width="80" />
														<col width="120" />
														<col width="120" />
														<col width="120" />
														<col width="100" />
														<col width="100" />
														<col width="100" />
														<col width="80" />
														<col width="80" />
														<col width="80" />
														<col width="80" />
														<col width="80" />
														<col width="100" />
														<col width="80" />
														<col width="80" />
														<col width="80" />
														<col width="80" />
														<col width="80" />
														<col width="80" />
														<col width="80" />
														<col width="80" />
														<col width="80" />
														<col width="80" />
														<col width="80" />
														<col width="80" />
														<col width="80" />
														<col width="80" />
														<col width="80" />
														<col width="80" />
														<col width="80" />
														<col width="80" />
														<col width="80" />
														<col width="80" />
													</colgroup>
													<tbody id="tab_3_1_grid">
														<tr CGRow="true">
															<td GCol="rownum">1</td>
															<td GCol="rowCheck" >선택</td>
															<td GCol="text,WAREKY" >거점</td> 
															<td GCol="text,WERKS"  >Plant</td> 
															<td GCol="text,SIMKEY" >시뮬레이션ID</td>  
															<td GCol="text,SHORTX" >시뮬레이션명</td>
															<td GCol="select,SHPTKY">
																<select CommonCombo="SHPTKY" name="SHPTKY" disabled="disabled">출하지점</select>	
															</td>
															<td GCol="select,ADDSHP">
																<select CommonCombo="SHPTKY" name="ADDSHP" disabled="disabled">추가출하지점</select>	
															</td>
															<td GCol="select,ORGSHP">
																<select CommonCombo="SHPTKY" name="ORGSHP" disabled="disabled">원출하지점</select><!--아래 운송계획지점 삭제함 -->	
															</td> 
															<td GCol="select,VSART_NM">
																<select CommonCombo="SHMETP" name="VSART_NM" disabled="disabled">출하유형</select>	
															</td>
															<td GCol="select,SHPTYP">
																<select CommonCombo="DELITP" name="SHPTYP" disabled="disabled">선적유형</select>	
															</td>
															<td GCol="select,AUART">
																<select CommonCombo="VTWESA" name="AUART" disabled="disabled">판매오더유형</select>	
															</td>
															<td GCol="select,SHTOGB">
																<select CommonCombo="SHTOGB" name="SHTOGB" disabled="disabled">영업조직</select>	
															</td>
															<td GCol="select,SHPCON">
																<select CommonCombo="SHPCON" name="SHPCON" disabled="disabled">출하조건</select>	
															</td>															
															<td GCol="select,SVCLVL">
																<select CommonCombo="SVCLVL" name="SVCLVL" disabled="disabled">서비스레벨</select>	
															</td>															
															<td GCol="select,PAYCON">
																<select CommonCombo="PAYCON" name="PAYCON" disabled="disabled">인도조건</select>	
															</td>
															<td GCol="text,DELORD" >Delivery Note</td>
															<td GCol="text,SHPTOP" >도착지코드</td>    
															<td GCol="text,SHIPNM" >도착지명</td>
															<td GCol="select,SHTOTY_NM">
																<select CommonCombo="SVCLVL" name="SHTOTY_NM" disabled="disabled">도착지유형</select>	
															</td>   
															<td GCol="text,SOSTOP" >우편번호</td>  
															<td GCol="text,ADDR01" >주소</td>  
															<td GCol="text,VDATU" >배송요청일</td>  
															<td GCol="text,VTIME" >배송요청시간</td>  
															<td GCol="text,KUNAG" >판매처</td>
															<td GCol="select,VTWEG">
																<select CommonCombo="VKBUR" name="VTWEG" disabled="disabled">유통경로</select>	
															</td>  
															<td GCol="text,VKBUR" >영업팀</td>  
															<td GCol="text,VKGRP" >영업그룹</td>  
															<td GCol="text,GRTXT" >출하요청텍스트</td>
															<td GCol="select,MIXLOD">
																<select CommonCombo="MIXLOD" name="MIXLOD" disabled="disabled">단독배송여부</select>	
															</td>
															<td GCol="select,VHCINEQ">
																<select CommonCombo="VHCINEQ" name="VHCINEQ" disabled="disabled">톤수제한</select>	
															</td>
															<td GCol="select,URGNT">
																<select CommonCombo="URGNT" name="VHCINEQ" disabled="disabled">긴급도</select><!--순서변경함 -->	
															</td>
															<td GCol="text,UNIT1_KG"  GF="N">단위1(KG)</td>
															<td GCol="text,UNIT2_M2"  GF="N">단위2(M2)</td>
															<td GCol="text,UNIT3_M3"  GF="N">단위3(M3)</td>         
															<td GCol="text,CREDAT" >생성일자</td>      
															<td GCol="text,CRETIM" >생성시간</td>      
															<td GCol="text,CREUSR" >생성자</td>												
														</tr>									
													</tbody>
												</table>
											</div>
										</div>
										<div class="tableUtil"> 
											<div class="leftArea">
												<button type="button" GBtn="find"></button>
												<button type="button" GBtn="sortReset"></button>
												<button type="button" GBtn="layout"></button>
												<button type="button" GBtn="total"></button>
												<button type="button" GBtn="excel"></button>
											</div>
											<div class="rightArea">
												<p class="record" GInfoArea="true"></p>
											</div>
										</div>
									</div>
								</div>	
								
								<div id="tabs3-2">
									<div class="section type1">
										<div class="table type2">
											<div class="tableHeader">
												<table>
													<colgroup>
														<col width="40" /> 
														<col width="100" />
														<col width="80" />
														<col width="80" />
														<col width="80" />
														<col width="80" /> 
														<col width="100" />
														<col width="80" />
														<col width="150" />
														<col width="80" />
														<col width="80" /> 
														<col width="80" />
														<col width="80" />
														<col width="80" />
														<col width="80" />
														<col width="80" /> 
														<col width="80" />
														<col width="80" />
														<col width="80" />
														<col width="80" />
														<col width="80" /> 
														<col width="80" />
														<col width="80" />
														<col width="80" />
														<col width="80" />
														<col width="80" /> 
														<col width="80" />
														<col width="80" />
														<col width="80" />
														<col width="80" />
													</colgroup>
													<thead>
														<tr>
															<th CL='STD_NUMBER'>번호</th>
															<th >Delivery Note</th>
															<th >Delivery Item</th>
															<th >Delivery Detail</th>
															<th >Sales Order No</th>
															<th >Sales Order Item</th>
															<th >Material Group</th>
															<th >Material </th>
															<th >설명</th>
															<th >배치번호</th>
															<th >조장</th>
															<th >조장수</th>
															<th >Delivery Qty</th>
															<th >Delivery UOM</th>
															<th >Gross Weight</th>
															<th >Gross Weight UOM</th>
															<th >Net Weight</th>
															<th >Net Weight UOM</th>
															<th >포장재 유형</th>
															<th >포장재 코드</th>
															<th >포장재 수량</th>
															<th >포장재 수량 단위</th>
															<th >폭</th>
															<th >길이</th>
															<th >높이</th>
															<th >포장재 중량</th>
															<th >적재단수</th>
															<th >생성일자</th>
															<th >생성시간</th>
															<th >생성자</th>
														</tr>
													</thead>
												</table>
											</div>
											<div class="tableBody">
												<table>
													<colgroup>
														<col width="40" />  
														<col width="100" />
														<col width="80" />
														<col width="80" />
														<col width="80" />
														<col width="80" /> 
														<col width="100" />
														<col width="80" />
														<col width="150" />
														<col width="80" />
														<col width="80" /> 
														<col width="80" />
														<col width="80" />
														<col width="80" />
														<col width="80" />
														<col width="80" /> 
														<col width="80" />
														<col width="80" />
														<col width="80" />
														<col width="80" />
														<col width="80" /> 
														<col width="80" />
														<col width="80" />
														<col width="80" />
														<col width="80" />
														<col width="80" /> 
														<col width="80" />
														<col width="80" />
														<col width="80" />
														<col width="80" />
													</colgroup>
													<tbody id="tab_3_2_grid">
														<tr CGRow="true">
															<td GCol="rownum">1</td>
															<td GCol="text,DELORD" >Delivery Note</td>
															<td GCol="text,DELITN" >Delivery Item</td>
															<td GCol="text,DELIDN" >Delivery Detail</td>
															<td GCol="text,SALORD" >Sales Order No</td>
															<td GCol="text,SALITN" >Sales Order Item</td> 
															<td GCol="text,MATKL" >Material Group</td>
															<td GCol="text,MTLCDE" >Material</td>
															<td GCol="text,MTLTXT" >설명</td>
															<td GCol="text,LOTNUM" >배치번호</td>
															<td GCol="text,JOJANG" >조장</td>
															<td GCol="text,JOJANGSU" >조장수</td>
															<td GCol="text,LFIMG" >Delivery Qty</td>
															<td GCol="text,VRKME" >Delivery UOM</td>
															<td GCol="text,BRGEW" >Gross Weight</td>
															<td GCol="text,BRWEI" >Gross Weight UOM</td>
															<td GCol="text,NTGEW" >Net Weight</td>
															<td GCol="text,NTWEI" >Net Weight UOM</td>
															<td GCol="text,PKTYP" >포장재 유형</td>
															<td GCol="text,PKMATNR" >포장재 코드</td>
															<td GCol="text,MENGE" >포장재 수량</td>
															<td GCol="text,ZMEINS" >포장재 수량 단위</td>
															<td GCol="text,WIDTH"  GF="N">폭</td>
															<td GCol="text,LENGTH" GF="N">길이</td>
															<td GCol="text,HEIGHT" GF="N">높이</td>
															<td GCol="text,PKWEI"  GF="N">포장재 중량</td>
															<td GCol="text,FLTLVL" GF="N">적재단수</td>
															<td GCol="text,CREDAT" >생성일자</td>
															<td GCol="text,CRETIM" >생성시간</td>
															<td GCol="text,CREUSR" >생성자</td>											
														</tr>									
													</tbody>
												</table>
											</div>
										</div>
										<div class="tableUtil"> 
											<div class="leftArea">
												<button type="button" GBtn="find"></button>
												<button type="button" GBtn="sortReset"></button>
												<button type="button" GBtn="layout"></button>
												<button type="button" GBtn="total"></button>
												<button type="button" GBtn="excel"></button>
											</div>
											<div class="rightArea">
												<p class="record" GInfoArea="true"></p>
											</div>
										</div>
									</div>
								</div>					
					        </div>
				        </div> 
			        </div>					        
					         
 					<!-- contentContainer -->
					<div id="tabs4" class="contentContainer">
						<!-- div class="leftGridTopBtnArea">
							<p class="util">
								<button CB="Right SAVE STD_SAVE"></button>
							</p>
						</div -->
						<div class="bottomSect2 top" style="width:63%;">
							<div class="tabs" style="height:100%">
								<ul class="tab type2">
									<li><a href="#tabs1-1"><span>일반</span></a></li>
								</ul>
								<div id="tabs1-1" style="height:100%;top:50px;"> 
									<iframe id="daum_map" src="/tms/dsp/TMD01S.page"  style="HEIGHT: 100%; WIDTH: 100%">
									</iframe>
								</div>
							</div>
						</div>
						<div id="commonMiddleArea3"></div>
						<!-- div class="rightGridTopBtnArea">
							<p class="util">
								<button CB="Left SAVE STD_SAVE"></button>
							</p>
						</div -->
						<div class="bottomSect2 bottom" style="left:52%;top:5px;">
							         
								<div id="tabs4-right">			
									<div class="bottomSect top" style="top: 30px;height: 300px">
										<button type="button" class="button type2 fullSizer"><img src="/common/images/ico_full.png" alt="Full Size"></button>
										<div class="tabs" >
											<ul class="tab type2">
												<li><a href="#tabs4-0"><span >배차계획결과</span></a></li>
											</ul>
											<div >
												<div class="section type1">
													<div class="table type2">
														<div class="tableHeader">
															<table>
																<colgroup>
																	<col width="40" />  
																	<col width="100" /> 
																	<col width="100" /> 
																	<col width="100" />
																	<col width="80" />
																	<col width="80" />
																	<col width="80" />
																</colgroup>
																<thead>
																	<tr>
																		<th CL='STD_NUMBER'>번호</th>
																		 <th >차량유형</th>
																		 <th >차량유형명</th>
																		 <th >차량번호</th>
																		<th >적재율1%(KG)</th>
																		<th >총거리</th>
																		<th >총시간</th>
																	</tr>
																</thead>
															</table>
														</div>
														<div class="tableBody" >
															<table>
																<colgroup>
																	<col width="40" /> 
																	<col width="100" /> 
																	<col width="100" /> 
																	<col width="100" />
																	<col width="80" /> 
																	<col width="80" /> 
																	<col width="80" />
																</colgroup>
																<tbody id="tab_4_grid">
																	<tr CGRow="true">
																		<td GCol="rownum">1</td> 
																		<td GCol="text,VHCTYP" >차량유형</td>    
																		<td GCol="text,VHCSTX" >차량유형명</td>   
																		<td GCol="text,VHCFNO" >차량번호</td>      
																		<td GCol="text,LOAD_KG" GF="N">적재율1%(KG)</td>
																		<td GCol="text,TOTDIS"  GF="N">총거리</td>          
																		<td GCol="text,TOTTIM"  GF="N">총시간</td>   											
																	</tr>									
																</tbody>
															</table>
														</div>
													</div>
													<div class="tableUtil"> 
														<div class="leftArea">
															<button type="button" GBtn="find"></button>
															<button type="button" GBtn="sortReset"></button>
															<button type="button" GBtn="layout"></button>
															<button type="button" GBtn="total"></button>
															<button type="button" GBtn="excel"></button>
														</div>
														<div class="rightArea">
															<p class="record" GInfoArea="true"></p>
														</div>
													</div>
												</div>
											</div>					
								        </div>
							        </div> 
								        
								        
									<div class="bottomSect bottom" style="top: 330px">
										<!-- button type="button" class="button type2 fullSizer"><img src="/common/images/ico_full.png" alt="Full Size"></button-->
										<div class="tabs">
											<ul class="tab type2" id="commonMiddleArea_3">
												<li><a href="#tabs4-1"><span >Simulation & Result</span></a></li>
											</ul>
											<div id="tabs4-1">
												<div class="section type1">
													<div class="table type2">
														<div class="tableHeader">
															<table>
																<colgroup>
																	<col width="40" /> 
																	<col width="100" /> 
																	<col width="100" /> 
																	<col width="100" />
																	<col width="100" />
																</colgroup>
																<thead>
																	<tr>
																		<th CL='STD_NUMBER'>번호</th>
																		<th >도착지</th>
																		<th >도착지명</th>
																		<th >도착거리</th>
																		<th >도착지시간</th>
																	</tr>
																</thead>
															</table>
														</div>
														<div class="tableBody" >
															<table>
																<colgroup>
																	<col width="40" /> 
																	<col width="100" /> 
																	<col width="100" /> 
																	<col width="100" />
																	<col width="100" />
																</colgroup>
																<tbody id="tab_4_1_grid">
																	<tr CGRow="true">
																		<td GCol="rownum">1</td>
																		<td GCol="text,SHPTOP" >도착지코드</td>    
																		<td GCol="text,SHIPNM" >도착지명</td>      
																		<td GCol="text,TOTDIS" >도착거리</td>    
																		<td GCol="text,TOTTIM" >도착시간</td>												
																	</tr>									
																</tbody>
															</table>
														</div>
													</div>
													<div class="tableUtil"> 
														<div class="leftArea">
															<button type="button" GBtn="find"></button>
															<button type="button" GBtn="sortReset"></button>
															<button type="button" GBtn="layout"></button>
															<button type="button" GBtn="total"></button>
															<button type="button" GBtn="excel"></button>
														</div>
														<div class="rightArea">
															<p class="record" GInfoArea="true"></p>
														</div>
													</div>
												</div>
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
	</div>
</div>
<!-- //content -->
<%@ include file="/common/include/bottom.jsp" %>
<script type="text/javascript">

var $middleArea = jQuery("#commonMiddleArea_2");
if($middleArea.length > 0){
	$middleArea.draggable({ 
		axis: "y",
		cursor: "n-resize",
		helper: "none",
		//revert: true,
		start: function(event, ui) {
			var $obj = jQuery(event.target);
			//$obj.text(ui.position.left);
		},
		drag: function(event, ui) {
			var $obj = jQuery(event.target);
			if ((Browser.ie6) || (Browser.ie7) || (Browser.ie8)) {

			}else{
				changeMiddleHeight($obj, ui);
			}				
		},
		stop: function(event, ui) {
			var $obj = jQuery(event.target);
			if ((Browser.ie6) || (Browser.ie7) || (Browser.ie8)) {
				changeMiddleHeight($obj, ui);
			}
			setMiddleHeight($obj, ui);
		} 
	});
}


var $middleArea = jQuery("#commonMiddleArea_3");
if($middleArea.length > 0){
	$middleArea.draggable({ 
		axis: "y",
		cursor: "n-resize",
		helper: "none",
		//revert: true,
		start: function(event, ui) {
			var $obj = jQuery(event.target);
			//$obj.text(ui.position.left);
		},
		drag: function(event, ui) {
			var $obj = jQuery(event.target);
			if ((Browser.ie6) || (Browser.ie7) || (Browser.ie8)) {

			}else{
				changeMiddleHeight($obj, ui);
			}				
		},
		stop: function(event, ui) {
			var $obj = jQuery(event.target);
			if ((Browser.ie6) || (Browser.ie7) || (Browser.ie8)) {
				changeMiddleHeight($obj, ui);
			}
			setMiddleHeight($obj, ui);
		} 
	});
}
</script>
</body>
</html>