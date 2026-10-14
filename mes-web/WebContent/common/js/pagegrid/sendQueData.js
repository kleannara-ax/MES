SendQueData = function(){
	this.url = null;
	this.procUrl = null;
	this.queCount = 0;
	this.totalCount = 0;
	this.type = null;
	this.gridList = null;
	this.param = null;
	this.successFunction = null;
	
	this.timer = null;
	this.sessionCount = 0;
	this.$pageHolder = $("#gridSaveHolder");
	
	this.upCount = 0;
	
	this.directQueCount = 0;
	this.directListCount = 0;
	this.directUpCount = 0;
	this.directItemUpCount = 0;
	this.executeQue = 0;
	this.executeQueCount = 0;
	this.sendDirectGridData = [];
	this.sendDirectItemArr = [];
	
	this.succGridId = "";
	this.failGridId = "";
	this.errorGridId = "";
	
	this.pageCount = 1000;
	this.totalPageCount = 10000;
	this.layerType = 0;
}

SendQueData.prototype = {
	send : function(option){
		var sendQueData = new SendQueData();
		var opts = $.extend(sendQueData, option);
		
		opts.$pageHolder.show();
		
		var msg1 = commonUtil.getMsg("COMMON_M0500");
		var msg2 = commonUtil.getMsg("COMMON_M0501");
		
		var $span1 = $("<span>").text(msg1 + " ( ");
		var $span2= $("<span>").attr({"id":"infoGuage"}).text("0");
		var $span3 = $("<span>").text("% )");
		
		$("#gridSaveHolder .innerInfoBox .innerInfoTxt1").children().remove();
		$("#gridSaveHolder .innerInfoBox .innerInfoTxt1").append($span1).append($span2).append($span3);
		$("#gridSaveHolder .innerInfoBox .innerInfoTxt2").text(msg2);
		
		$("#gridSaveHolder .innerGuageBox .innerGuageTxt").text("0%");
		$("#gridSaveHolder .innerGuageBox .innerGuage").attr({"style":"width:0%;"});
		
		setTimeout(function(){
			var sendArr = new Array();
			
			var queCount = opts.queCount;
			var totalCount = opts.totalCount;
			
			var list = opts.gridList;
			var listLen = list.length;
			
			if(listLen > 0){
				totalCount = totalCount == 0 ? listLen : totalCount;
				
				var count = Math.ceil(totalCount / queCount);
				if(totalCount < queCount){
					queCount = totalCount;
				}
				
				for(var i = 0; i < count; i++){
					var sendItemArr = new Array();
					
					/* 
					 * 2019.09.05 박지현
					 * 지정한 queCount에서 나머지가 발생하는 경우,
					 * rowNum을 중간부터 가져오는 에러가 있어서 수정함
					 * Modified START */
					if( count == (i + 1) ){
						for(var j = 0; j < queCount; j++){
							var rowNum = (i * queCount) + j;
							
							if( totalCount >= (rowNum + 1) ){
								var row = list[rowNum];
								sendItemArr.push(row);
							}
							else{
								break;
							}
						}
					}
					else{
						for(var j = 0; j < queCount; j++){
							var rowNum = (i * queCount) + j;
							var row = list[rowNum];
							sendItemArr.push(row);
						}
					}
					/* 2019.09.05 박지현    Modified END */
					
					sendArr.push(sendItemArr);
				}
			}
			
			sendQueData.sendRequest(opts,sendArr);
		}, 25);
	},
	
	sendRequest : function(option,data){
		var totalCount = option.totalCount;
		
		var dataList = data;
		var dataLen = dataList.length;
		
		var param;
		if(option.param == null || option.param == undefined){
			param = new DataMap();
		}else{
			param = option.param;
		}
		
		if(dataLen > 0){
			var sessionKey = "";
			var sesssionKeyMap = netUtil.sendData({
				module : "Common",
				command : "PROCS_BTCSEQ",
				sendType : "map",
				param : param
			});
			
			if(sesssionKeyMap && sesssionKeyMap.data){
				sessionKey = sesssionKeyMap.data["BTCSEQ"].toString();
			}
			
			if(sessionKey != ""){
				var map = new DataMap();
				map.put("BTCSEQ", sessionKey);
				
				if(!param.isEmpty()){
					var keys = param.keys();
					for(var i = 0; i < keys.length; i++){
						var key = keys[i];
						map.put(key, param.get(key));
					}
				}
				
				for(var i = 0; i < dataLen; i++){
					var tData = dataList[i];
					var tDataCount = tData.length;
					map.put("list", tData);
					sendQueData.run(option.url, map, sessionKey, totalCount, tDataCount, option.procUrl, option.successFunction);
				}
			}
		}
	},
	
	run : function(url,param,sessionKey,totalCount,count,procUrl,successFunction){
		var paramStr = param.jsonString();
		
		while(paramStr.indexOf("??") != -1){
			paramStr = commonUtil.replaceAll(paramStr, "??", "?");
		}
		
		$.ajax({
			type: "POST",
			url : url,
			async : true,
			data : paramStr,
			dataType : "json",
			contentType: "application/json",
			beforeSend : function(){
				sendQueData.sessionCountTimer(sessionKey,totalCount,count);
			},
			error : function(a, b, c){
	        	clearInterval(sendQueData.timer);
				sendQueData.timer = null;
				
				$("#gridSaveHolder").hide();
		    },
		    success : function (json) {
		    	sendQueData.upCount = (sendQueData.upCount + json.data);
		    	
		    	$("#gridSaveHolder #infoGuage").text(Math.ceil(100/totalCount * sendQueData.upCount));
		    	
		    	if(totalCount <= sendQueData.upCount){
					$("#gridSaveHolder #infoGuage").text(100);
					clearInterval(sendQueData.timer);
					sendQueData.timer = null;
					
					var msg = commonUtil.getMsg("COMMON_M0502");
					$("#gridSaveHolder .innerInfoTxt1").text(msg);
					
					setTimeout(function(){
						sendQueData.procsRun(procUrl,new DataMap(),sessionKey,totalCount,successFunction);
					});
				}
		    },
		    complete : function(){}
		});
	},
	
	removeSessionRun : function(sessionKey){
		var param = new DataMap();
		param.put("sessionKey",sessionKey);
		
		$.ajax({
			type : "post",
			url : "/common/session/json/removeSessionSaveData.data",
			async : true,
			data : param.jsonString(),
			dataType : "json",
			contentType: "application/json",
			error : function(a, b, c){
				$("#gridSaveHolder").hide();
		    },
		    success : function (json) {
		    	//console.log(json);	
		    }
		});    
	},
	
	procsRun : function(url,param,sessionKey,totalCount,successFunction){
		param.put("BTCSEQ",sessionKey);
		$.ajax({
			type : "post",
			url : url,
			async : true,
			data : param.jsonString(),
			dataType : "json",
			contentType: "application/json",
			beforeSend : function(){
				sendQueData.removeSessionRun(sessionKey);
				setTimeout(function(){
					sendQueData.procCountTimer(sessionKey,totalCount);
				},1000);
			},
			error : function(a, b, c){
	        	clearInterval(sendQueData.timer);
				sendQueData.timer = null;
				
				$("#gridSaveHolder").hide();
		    },
		    success : function (json) {
		    	if(json && json.data){
		    		if(json.data["result"] == "S"){
		    			$("#gridSaveHolder .innerGuageBox .innerGuageTxt").text("100%");
						$("#gridSaveHolder .innerGuageBox .innerGuage").attr({"style":"width:100%;"});
		    		}
		    	}
		    	
		    	setTimeout(function(){
	    			sendQueData.upCount = 0;
		    		sendQueData.sessionCount = 0;
		    		sendQueData.queCount = 0;
		    		sendQueData.gridList = null;
		    		
		    		clearInterval(sendQueData.timer);
					sendQueData.timer = null;
					
					$("#gridSaveHolder .innerGuageBox .innerGuageTxt").text("0%");
					$("#gridSaveHolder .innerGuageBox .innerGuage").attr({"style":"width:0%;"});
					
					$("#gridSaveHolder .innerInfoBox .innerInfoTxt1").text("");
					
					var msg1 = commonUtil.getMsg("COMMON_M0500");
					var msg2 = commonUtil.getMsg("COMMON_M0501");
					
					var $span1 = $("<span>").text(msg1 + " ( ");
					var $span2= $("<span>").attr({"id":"infoGuage"}).text("0");
					var $span3 = $("<span>").text("% )");
					
					$("#gridSaveHolder .innerInfoBox .innerInfoTxt1").append($span1).append($span2).append($span3);
					$("#gridSaveHolder .innerInfoBox .innerInfoTxt2").text(msg2);
					
					$("#gridSaveHolder").hide();
					
					setTimeout(function(){
						if(successFunction){
			    			if(commonUtil.checkFn(successFunction)){
			    				eval(successFunction+"(json)");
			    			}
			    		}
					});
				}, 1000);
		    },
		    complete : function(){}
		});
	},
	
	procCountTimer : function(sessionKey,totalCount){
		var param = new DataMap();
		param.put("BTCSEQ",sessionKey);
		/*param.put("MODULE","MDM");
		param.put("PRCFLG","Y");*/
		
		var url = "/common/session/json/procsUpdateDataCount.data";
		
		if(sendQueData.timer != null || sendQueData.timer > 0){
			return;
		}
		
		sendQueData.ajaxProcRequest(url,param,totalCount);
	},
	
	ajaxProcRequest : function(url,param,totalCount){
		sendQueData.timer = setInterval(function(){
			$.ajax({
				type : "post",
				url : url,
				async : true,
				data : param.jsonString(),
				dataType : "json",
				contentType: "application/json",
				error : function(a, b, c){
		        	clearInterval(sendQueData.timer);
					sendQueData.timer = null;
					
					$("#gridSaveHolder").hide();
			    },
			    success : function (json) {
			    	var cnt = json.data;
			    	$("#gridSaveHolder #innerGuageTxt").text(Math.ceil(100/totalCount * cnt) + "%");
			    	$("#gridSaveHolder #innerGuage").css("width",Math.ceil(100/totalCount * cnt) + "%");
					
			    	if(totalCount <= cnt){
			    		$("#gridSaveHolder #innerGuageTxt").text("100%");
				    	$("#gridSaveHolder #innerGuage").css("width","100%");
			    		
						clearInterval(sendQueData.timer);
						sendQueData.timer = null;
					}
			    }
			});
		},100);
	},
	
	sessionCountTimer : function(sessionKey,totalCount,count){
		var param = new DataMap();
		param.put("sessionKey",sessionKey);
		
		var url = "/common/session/json/sessionSaveDataCount.data";
		
		if(sendQueData.timer != null || sendQueData.timer > 0){
			return;
		}
		
		sendQueData.ajaxRequest(url,param,totalCount,count);
	},
	
	ajaxRequest : function(url,param,totalCount,count){
		sendQueData.timer = setInterval(function(){
			$.ajax({
				type : "post",
				url : url,
				async : true,
				data : param.jsonString(),
				dataType : "json",
				contentType: "application/json",
				error : function(a, b, c){
		        	clearInterval(sendQueData.timer);
					sendQueData.timer = null;
					
					$("#gridSaveHolder").hide();
			    },
			    success : function (json) {
			    	var cnt = (sendQueData.upCount + json.data);

			    	$("#gridSaveHolder #infoGuage").text(Math.ceil(100/totalCount * cnt));
					
			    	if(totalCount <= sendQueData.sessionCount){
						$("#gridSaveHolder #infoGuage").text(100);
						clearInterval(sendQueData.timer);
						sendQueData.timer = null;
					}
			    }
			});
		},1000);
	},
	
	directSend : function(option){
		var sendQueData = new SendQueData();
		var opts = $.extend(sendQueData, option);
		
		opts.$pageHolder.show();
		
		$("#gridSaveHolder .innerInfoBox .innerInfoTxt1").children().remove();
		
		var msg1 = commonUtil.getMsg("COMMON_M0500");
		var msg2 = commonUtil.getMsg("COMMON_M0501");
		
		var $span1 = $("<span>").text(msg1 + " ( ");
		var $span2= $("<span>").attr({"id":"infoGuage"}).text("0");
		var $span3 = $("<span>").text("% )");
		
		$("#gridSaveHolder .innerInfoBox .innerInfoTxt1").append($span1).append($span2).append($span3);
		$("#gridSaveHolder .innerInfoBox .innerInfoTxt2").text(msg2);
		
		$("#gridSaveHolder .innerGuageBox .innerGuageTxt").text("0%");
		$("#gridSaveHolder .innerGuageBox .innerGuage").attr({"style":"width:0%;"});
		
		setTimeout(function(){
			var sendArr = new Array();
			
			var queCount = opts.queCount;
			var totalCount = opts.totalCount;
			
			var list = opts.gridList;
			var listLen = list.length;
			if(listLen > 0){
				totalCount = totalCount == 0 ? listLen : totalCount;
				sendQueData.sessionCount = totalCount;
				
				var directQueCount = Math.ceil(totalCount / queCount);
				if(listLen < queCount){
					queCount = listLen;
				}
				
				sendQueData.setSendData(list, totalCount, queCount, directQueCount, sendQueData.directUpCount, option);
			}
		}, 1);
	},
	
	setSendData : function(gridData,totalCount,queCount,totalQueCount,upCount,option){
		var rowCount = (sendQueData.directUpCount * queCount);
		
		if(totalQueCount == (upCount + 1)){
			queCount = totalCount - (queCount * upCount);
		}
		
		sendQueData.setPutData(gridData, totalCount, totalQueCount, queCount, rowCount, option);
	},
	
	setPutData : function(list,totalCount,totalQueCount,queCount,rowCount,option){
		var rowNum = rowCount + sendQueData.directItemUpCount;
		var row = list[rowNum];
		sendQueData.sendDirectItemArr.push(row);
		sendQueData.directItemUpCount++;
		
		if(sendQueData.directItemUpCount < queCount){
			$("#gridSaveHolder #infoGuage").text(Math.ceil(100/totalCount * rowNum));
			setTimeout(function(){
				sendQueData.setPutData(list,totalCount,totalQueCount,queCount,rowCount,option);
			});
		}else{
			sendQueData.sendDirectGridData.push(sendQueData.sendDirectItemArr);
			sendQueData.directItemUpCount = 0;
			sendQueData.sendDirectItemArr = [];
			
			sendQueData.directUpCount++;
			
			if(sendQueData.directUpCount < totalQueCount){
				sendQueData.setSendData(list,totalCount,queCount,totalQueCount,sendQueData.directUpCount,option);
			}else{
				sendQueData.upCount = 0;
				sendQueData.directQueCount = 0;
				sendQueData.directListCount = 0;
				sendQueData.directUpCount = 0;
				sendQueData.directItemUpCount = 0;
				
				setTimeout(function(){
					sendQueData.sendDirectRequest(option);
				}, 25);
			}
		}
	},
	
	sendDirectRequest : function(option){
		var totalCount = option.totalCount;
		
		var dataList = sendQueData.sendDirectGridData;
		var dataLen = dataList.length;
		
		var param;
		if(option.param == null || option.param == undefined){
			param = new DataMap();
		}else{
			//param = new DataMap(option.param);
			param = option.param;
		}
		
		if(dataLen > 0){
			var sessionKey = "";
			var prtseq = "";
			
			var sesssionKeyMap = netUtil.sendData({
    			module : "Common",
                command : "PROCS_BTCSEQ",
                sendType : "map",
                param : param
            });
			
			if(sesssionKeyMap && sesssionKeyMap.data){
				sessionKey = sesssionKeyMap.data["BTCSEQ"].toString();
			}
			
			if(sessionKey != ""){
				var msg = commonUtil.getMsg("COMMON_M0502");
				$("#gridSaveHolder .innerInfoTxt1").text(msg);
				
				if(option.type == "print"){
					var prtMap = netUtil.sendData({
		    			module : "MdmMaterial",
		                command : "MSK_PRTSEQ",
		                sendType : "map",
		                param : param
		            });
					
					if(prtMap && prtMap.data){
						prtseq = prtMap.data["PRTSEQ"].toString();
					}
				}
				
				/*var map = new DataMap();
				map.put("BTCSEQ",sessionKey);
				map.put("dataList",dataList);
				if(!param.isEmpty()){
					var keys = param.keys();
					for(var i = 0; i < keys.length; i++){
						var key = keys[i];
						map.put(key,param.get(key));
					}
				}
				if(prtseq != ""){
					map.put("PRTSEQ",prtseq);
				}*/
				param.put("BTCSEQ",sessionKey);
				param.put("dataList",dataList);
				if(prtseq != ""){
					param.put("PRTSEQ",prtseq);
				}
				
				sendQueData.executeQue = dataLen;
				//sendQueData.executeDirectRun(option.url,map,sessionKey,totalCount,option.successFunction);
				sendQueData.executeDirectRun(option.url,param,sessionKey,totalCount,option.successFunction);
			}
		}
	},
	
	executeDirectRun : function(url,data,sessionKey,totalCount,successFunction){
		var parentData = data;
		var list = parentData.get("dataList");
		var prtseq = parentData.get("PRTSEQ");
		var tData = list[sendQueData.executeQueCount];
		var tDataCount = tData.length;
		
		/*var map = new DataMap();
		map.put("BTCSEQ",sessionKey);
		map.put("list",tData);
		if(prtseq != "" && prtseq != undefined && prtseq != null){
			map.put("PRTSEQ",prtseq);
		}*/
		
		parentData.put("BTCSEQ",sessionKey);
		parentData.put("list",tData);
		if(prtseq != "" && prtseq != undefined && prtseq != null){
			parentData.put("PRTSEQ",prtseq);
		}
		var map = parentData;
		//sendQueData.directRun(url,map,sessionKey,totalCount,tDataCount,successFunction,parentData);
		sendQueData.directRun(url,map,sessionKey,totalCount,tDataCount,successFunction,parentData);
		sendQueData.executeQueCount++;
	},
	
	directRun : function(url,param,sessionKey,totalCount,count,successFunction,parentData){
		$.ajax({
			type : "post",
			url : url,
			async : true,
			data : param.jsonString(),
			dataType : "json",
			contentType: "application/json",
			beforeSend : function(){
				sendQueData.sessionCountDirectTimer(sessionKey,totalCount,count);
			},
			error : function(a, b, c){
	        	clearInterval(sendQueData.timer);
				sendQueData.timer = null;
				
				$("#gridSaveHolder").hide();
		    },
		    success : function (json) {
		    	sendQueData.upCount += commonUtil.parseInt(json.data["CNT"]);
		    	
		    	if(sendQueData.executeQue > sendQueData.executeQueCount){
		    		clearInterval(sendQueData.timer);
					sendQueData.timer = null;
		    		
					sendQueData.executeDirectRun(url,parentData,sessionKey,totalCount,successFunction);
				}else{
					sendQueData.executeQue = 0;
					sendQueData.executeQueCount = 0;
				}
		    	
		    	if(totalCount <= sendQueData.upCount){
		    		sendQueData.removeSessionRun(sessionKey);
		    		
		    		sendQueData.sendDirectGridData = [];
		    		sendQueData.upCount = 0;
		    		sendQueData.sessionCount = 0;
		    		
		    		clearInterval(sendQueData.timer);
					sendQueData.timer = null;
		    		
		    		$("#gridSaveHolder .innerGuageBox .innerGuageTxt").text("0%");
					$("#gridSaveHolder .innerGuageBox .innerGuage").attr({"style":"width:0%;"});
					
					$("#gridSaveHolder .innerInfoBox .innerInfoTxt1").text("");
					$("#gridSaveHolder .innerInfoBox .innerInfoTxt2").text("");
					
					var msg1 = commonUtil.getMsg("COMMON_M0500");
					var msg2 = commonUtil.getMsg("COMMON_M0501");
					
					var $span1 = $("<span>").text(msg1 + " ( ");
					var $span2= $("<span>").attr({"id":"infoGuage"}).text("0");
					var $span3 = $("<span>").text("% )");
					
					$("#gridSaveHolder .innerInfoBox .innerInfoTxt1").append($span1).append($span2).append($span3);
					$("#gridSaveHolder .innerInfoBox .innerInfoTxt2").text(msg2);
					
					$("#gridSaveHolder").hide();
					
					setTimeout(function(){
						if(successFunction){
			    			if(commonUtil.checkFn(successFunction)){
			    				eval(successFunction+"(json)");
			    			}
			    		}
					});
		    	}
		    },
		    complete : function(){}
		});
	},
	
	sessionCountDirectTimer : function(sessionKey,totalCount,count){
		var param = new DataMap();
		param.put("sessionKey",sessionKey);
		
		var url = "/common/session/json/sessionSaveDataCount.data";
		
		if(sendQueData.timer != null || sendQueData.timer > 0){
			return;
		}
		
		sendQueData.ajaxDirectRequest(url,param,totalCount,count);
	},
	
	ajaxDirectRequest : function(url,param,totalCount,count){
		sendQueData.timer = setInterval(function(){
			$.ajax({
				type : "post",
				url : url,
				async : true,
				data : param.jsonString(),
				dataType : "json",
				contentType: "application/json",
				error : function(a, b, c){
		        	clearInterval(sendQueData.timer);
					sendQueData.timer = null;
					
					$("#gridSaveHolder").hide();
			    },
			    success : function (json) {
			    	var cnt = (sendQueData.upCount + json.data);
			    	$("#gridSaveHolder #innerGuageTxt").text(Math.ceil(100/totalCount * cnt)+"%");
			    	$("#gridSaveHolder #innerGuage").css("width",Math.ceil(100/totalCount * cnt)+"%");
			    }
			});
		},1000);
	},
	
	setSaveResultLayer : function(option){
		var $wapper = $(".content");
		var $html = this.setGridDetailDrawHtml(option);
		$wapper.after($html);
		
		var succListId = option[0]["gridId"];
		var succModule = option[0]["module"];
		var succCommand = option[0]["command"];
		
		var failListId = option[1]["gridId"];
		var failModule = option[1]["module"];
		var failCommand = option[1]["command"];
		
		var errorListId = option[2]["gridId"];
		var errorModule = option[2]["module"];
		var errorCommand = option[2]["command"];
		
		gridList.setGrid({
			id : succListId,
			module : succModule,
			command : succCommand,
			scrollPageCount : sendQueData.pageCount,
			emptyMsgType : false
		});
		
		gridList.setGrid({
			id : failListId,
			module : failModule,
			command : failCommand,
			scrollPageCount : sendQueData.pageCount,
			emptyMsgType : false
		});
		
		gridList.setGrid({
			id : errorListId,
			module : errorModule,
			command : errorCommand,
			scrollPageCount : sendQueData.pageCount,
			emptyMsgType : false
		});
		
		this.setResultLayerEvent(succListId,failListId,errorListId);
	},
	
	setGridDetailDrawHtml : function(option){
		var succListId = option[0]["gridId"];
		var failListId = option[1]["gridId"];
		var errorListId = option[2]["gridId"];
		
		sendQueData.succGridId = succListId;
		sendQueData.failGridId = failListId;
		sendQueData.errorGridId = errorListId;
		
		var succCol = option[0]["col"];
		var failCol = option[1]["col"];
		var errorCol = option[2]["col"];
		
		var $html = "<div class='gridDetailLayer' id='result_layer' style='display: none;margin-top: 0;top: 9%;'>"
				  + "	<div class='gridDetailLayer-header'>"
				  + " 		<div class='gridDetailLayer-header-textarea' style='width: 90%;'>" 
				  +	"			<p style='font-size: 20px;padding: 9px 9px 11px 10px;'>" 
				  + "				<span>총 </span> <span id='rTot' style='color: #000;'>(0)</span><span>건이 처리되었습니다.</span>" 
				  + "			</p>" 
				  + "		</div>"
				  + "		<div class='gridDetailLayer-header-buttonarea'style='width: 10%;'><p style='float: left;font-size: 23px;padding-top: 0;' id='resultMin'>_</p><p id='resultClose'>X</p></div>"
				  + "	</div>"
				  + "	<div class='gridDetailLayer-detail-result'>"
				  + "		<div class='gridDetailLayer-detail-notice'>"
				  + "			<dl>"
				  + "				<dt class='box_succ'>성공</dt>  <dd id='rSucc'>0</dd>"
				  + "				<dt class='box_fail'>실패</dt>  <dd id='rFail'>0</dd>"
				  + "				<dt class='box_error'>에러</dt> <dd id='rError'>0</dd>"
				  + "	 		</dl>"
				  + "		</div>"
				  + "		<div class='gridDetailLayer-detail-gridarea'>"
				  + "			<div class='bottomSect' style='top: 160px;'>"
				  + "				<div class='tabs'>"
				  + "					<ul class='tab type2'>"
				  + "						<li><a href='#tabs2-1'><span>성공<span id='succCnt'>(0)</span></span></a></li>"
				  + "						<li><a href='#tabs2-2'><span>실패<span id='failCnt'>(0)</span></span></a></li>"
				  + "						<li><a href='#tabs2-3'><span>에러<span id='errorCnt'>(0)</span></span></a></li>"
				  + "					</ul>"
				  + "					<div id='tabs2-1'>"
				  + "						<div class='section type1'>"
				  + "							<div class='table type2'>"
				  + "								<div class='tableBody'>"
				  + "									<table>"
				  + "										<tbody id='"+succListId+"'>"
				  + "											<tr CGRow='true'>"
				  + "												<td GH='40 STD_NUMBER'  GCol='rownum'>1</td>"
				  +													this.setTableDrawHtml(succCol)
				  + "											</tr>"
				  + "										</tbody>"
				  + "									</table>"
				  + "								</div>"
				  + "							</div>"
				  + "							<div class='tableUtil'>"
				  + "								<div class='leftArea'>"
				  + "									<button type='button' GBtn='find'></button>"
				  + "									<button type='button' GBtn='sortReset'></button>"
				  + "									<button type='button' GBtn='excel'></button>"
				  + "								</div>"
				  + "								<div class='rightArea'>"
				  + "									<p class='record' GInfoArea='true'></p>"
				  + "								</div>"
				  + "							</div>"
				  + "						</div>"
				  + "					</div>"
				  + "					<div id='tabs2-2'>"
				  + "						<div class='section type1'>"
				  + "							<div class='table type2'>"
				  + "								<div class='tableBody'>"
				  + "									<table>"
				  + "										<tbody id='"+failListId+"'>"
				  + "											<tr CGRow='true'>"
				  + "												<td GH='40 STD_NUMBER'  GCol='rownum'>1</td>"
				  +													this.setTableDrawHtml(failCol)
				  + "											</tr>"
				  + "										</tbody>"
				  + "									</table>"
				  + "								</div>"
				  + "							</div>"
				  + "							<div class='tableUtil'>"
				  + "								<div class='leftArea'>"
				  + "									<button type='button' GBtn='find'></button>"
				  + "									<button type='button' GBtn='sortReset'></button>"
				  + "									<button type='button' GBtn='excel'></button>"
				  + "								</div>"
				  + "								<div class='rightArea'>"
				  + "									<p class='record' GInfoArea='true'></p>"
				  + "								</div>"
				  + "							</div>"
				  + "						</div>"
				  + "					</div>"
				  + "					<div id='tabs2-3'>"
				  + "						<div class='section type1'>"
				  + "							<div class='table type2'>"
				  + "								<div class='tableBody'>"
				  + "									<table>"
				  + "										<tbody id='"+errorListId+"'>"
				  + "											<tr CGRow='true'>"
				  + "												<td GH='40 STD_NUMBER'  GCol='rownum'>1</td>"
				  +													this.setTableDrawHtml(errorCol)
				  + "											</tr>"
				  + "										</tbody>"
				  + "									</table>"
				  + "								</div>"
				  + "							</div>"
				  + "							<div class='tableUtil'>"
				  + "								<div class='leftArea'>"
				  + "									<button type='button' GBtn='find'></button>"
				  + "									<button type='button' GBtn='sortReset'></button>"
				  + "									<button type='button' GBtn='excel'></button>"
				  + "								</div>"
				  + "								<div class='rightArea'>"
				  + "									<p class='record' GInfoArea='true'></p>"
				  + "								</div>"
				  + "							</div>"
				  + "						</div>"
				  + "					</div>"
				  + "				</div>"
				  + "			</div>"
				  + "		</div>"
				  + "	</div>"
				  + "</div>";
		return $html;
	},
	
	setTableDrawHtml : function(data){
		var $html = "";
		for(var i = 0; i < data.length; i ++){
		    var aln = "";
			if(data[i]["aln"] != ""){
				aln = ","+data[i]["aln"]+"'></td>";
		    }else{
		    	aln = "'></td>";
		    }
			$html += "<td GH='"+data[i]["width"]+" "+data[i]["label"]+"' GCol='text,"+data[i]["data"] + aln;
				
		}
		return $html
	},
	
	setResultLayerEvent : function(succListId,failListId,errorListId){
		$("#result_layer").draggable();
		$("#result_layer .tabs").tabs();
		
		$("#result_layer .tabs").tabs("option", "active", 0);
		
		$("#resultMin").on("click",function(){
			var $btn = $(".gridDetailLayer-header-buttonarea p").eq(0);
			if(sendQueData.layerType == 0){
				sendQueData.layerType = 1;
				$("#result_layer").css("height","143px");
				$btn.text("");
			    $btn.attr("style","float: left;padding: 7px;border: 2px solid;margin-top: 9px;border-radius: 2px;");
			}else if(sendQueData.layerType == 1){
				sendQueData.layerType = 0;
				$btn.text("_");
				$btn.attr("style","float: left;font-size: 23px;padding-top: 0;");
				$("#result_layer").css("height","800px");
			}
		});
		
		$("#resultClose").on("click",function(){
			$("#rTot").text("(0)");
			$("#rSucc").text(0);
			$("#rFail").text(0);
			$("#rError").text(0);
			
			$("#succCnt").text("(0)");
			$("#failCnt").text("(0)");
			$("#errorCnt").text("(0)");
			
			gridList.resetGrid(succListId);
			gridList.resetGrid(failListId);
			gridList.resetGrid(errorListId);
			
			$("#result_layer").hide();
		});
	},
	
	resultBox : function(data){
		$("#result_layer").show();
		
		var resultData = data["resultData"];
        
        $("#rTot").text("("+sendQueData.numberComma(resultData["TOTAL"])+")");
        $("#rSucc").text(sendQueData.numberComma(resultData["SUCCESS"]));
        $("#rFail").text(sendQueData.numberComma(resultData["FAIL"]));
        $("#rError").text(sendQueData.numberComma(resultData["ERROR"]));
        
        $("#succCnt").text("("+sendQueData.numberComma(resultData["SUCCESS"])+")");
        $("#failCnt").text("("+sendQueData.numberComma(resultData["FAIL"])+")");
        $("#errorCnt").text("("+sendQueData.numberComma(resultData["ERROR"])+")");
        
        var param = new DataMap();
        param.put("BTCSEQ",data["btcseq"]);
        
        var openTab = -1;
        
        if(resultData["SUCCESS"] > 0){
			param.put("STATUS","Y");
			
			if(resultData["SUCCESS"] > sendQueData.totalPageCount){
				gridList.getGridBox(sendQueData.succGridId).scrollPageCount = sendQueData.pageCount;
			}else{
				gridList.getGridBox(sendQueData.succGridId).scrollPageCount = 0;
			}
			
			gridList.gridList({
				id : sendQueData.succGridId,
				param : param,
				scrollReset : true
			});
			
			openTab = 0;
		}
        
		if(resultData["FAIL"] > 0){
			param.put("STATUS","N");
			
			if(resultData["FAIL"] > sendQueData.totalPageCount){
				gridList.getGridBox(sendQueData.failGridId).scrollPageCount = sendQueData.pageCount;
			}else{
				gridList.getGridBox(sendQueData.failGridId).scrollPageCount = 0;
			}
			
			gridList.gridList({
				id : sendQueData.failGridId,
				param : param,
				scrollReset : true
			});
			
			if(openTab < 0){
				openTab = 1;
			}
		}	            
       
		if(resultData["ERROR"] > 0){
            param.put("STATUS","E");
            
            if(resultData["ERROR"] > sendQueData.totalPageCount){
				gridList.getGridBox(sendQueData.errorGridId).scrollPageCount = sendQueData.pageCount;
			}else{
				gridList.getGridBox(sendQueData.errorGridId).scrollPageCount = 0;
			}
            
            gridList.gridList({
				id : sendQueData.errorGridId,
				param : param,
				scrollReset : true
			});
            
            if(openTab < 1){
            	openTab = 2;
            }
		}
		
		$("#result_layer .tabs").tabs("option", "active", openTab);
	},
	
	numberComma : function(num){
		return num.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
	}
}

var sendQueData = new SendQueData();