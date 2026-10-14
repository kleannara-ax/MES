Membership = function(){
	this.tabs = {
		"tabs_id1" : {
			"id" : "applyCodeRegist" ,
			"textObjectIds" : [] ,
			"inputObjetIds" : ["APLCOD"]
	    },
		"tabs_id2" : {
			"id" : "companyDefaultInfomation" ,
			"textObjectIds" : ["COMPNM","BIZNUM","MNGRNM","TELNUM"] ,   
			"inputObjetIds" : ["COMPKY","USERID","PASSWD","PASSRE"]
		},
		"tabs_id3" : {
			"id" : "optionSetting" ,
			"textObjectIds" : [] ,   
			"inputObjetIds" : []
		},
		"tabs_id4" : {
			"id" : "servicePrice" ,
			"textObjectIds" : [] ,   
			"inputObjetIds" : []
		},
		"tabs_id5" : {
			"id" : "registComplate" ,
			"textObjectIds" : [] ,   
			"inputObjetIds" : []
		},
	};
	
	this.setContinue = "N";
	this.companyInfomationData = new DataMap();
	this.defaultInfomationCheckData = new DataMap();
}

Membership.prototype = {
	setPage : function(){
		this.setDefaultInfomationData();
		
		this.unbindTabs("init");
		uiList.UICheck();
		inputList.setInput();
		
		this.setTabsObjectId();
		this.setInputObject();
		this.setButtonEvent();
		this.setOptionSetPage();
		this.setPricePage();
		this.setResultPage();
		$("#"+this.tabs["tabs_id1"]["inputObjetIds"][0]).focus();
	},
	
	setDefaultInfomationData : function(){
		var map1 = new DataMap();
		map1.put("isPass",false);
		map1.put("isAuth",false);
		
		var map2 = new DataMap();
		map2.put("isPass",false);
		map2.put("isAuth",false);
		
		var map3 = new DataMap();
		map3.put("isPass",false);
		
		var map4 = new DataMap();
		map4.put("isPass",false);
		
		this.defaultInfomationCheckData.put("COMPKY",map1);
		this.defaultInfomationCheckData.put("USERID",map2);
		this.defaultInfomationCheckData.put("PASSWD",map3);
		this.defaultInfomationCheckData.put("PASSRE",map4);
	},
	
	getDefaultInfomationData : function(id){
		return this.defaultInfomationCheckData.get(id);
	},
	
	setTabsObjectId : function(){
		var data = membership.tabs;
		
		var $tabs = $(".membership_tab");
		$tabs.each(function(){
			var i = $(this).index() + 1;
			var tabId = data["tabs_id"+i]["id"];
			$(this).attr({"id":tabId});
		});
	},
	
	setInputObject : function(){
		var $tabs = $(".membership_tab");
		
		//Tab1
		var $tab1 = $tabs.eq(0);
		var $tabs1_input = $tab1.find("input");
		var tabs1InputIds = this.tabs["tabs_id1"]["inputObjetIds"];
		for(var i in tabs1InputIds){
			var id = tabs1InputIds[i];
			$tabs1_input.eq(i).attr({"id" : id, "name" : id, "onkeypress":"commonUtil.enterKeyCheck(event, 'membership.checkApplyCode()')"});
		}
		
		//Tab2
		var $tab2 = $tabs.eq(1);
		var $tabs2_text = $tab2.find(".membership_info p span:odd");
		var $tabs2_input = $tab2.find("input");
		
		var tabs1TextIds = this.tabs["tabs_id2"]["textObjectIds"];
		for(var i in tabs1TextIds){
			var id = tabs1TextIds[i];
			$tabs2_text.eq(i).attr({"id" : id});
		}
		
		var tabs2InputIds = this.tabs["tabs_id2"]["inputObjetIds"];
		for(var i in tabs2InputIds){
			var id = tabs2InputIds[i];
			$tabs2_input.eq(i).attr({"id" : id, "name" : id});
			
			var $validationCheckObject = $tabs2_input.eq(i).parent().next();
			$validationCheckObject.attr("id",id+"_RESULT");
			
			if(id == "COMPKY"){
				$tabs2_input.eq(i).keyup(function(e){
					var $obj = $(this).parent().next();
					$obj.text("");
					
					membership.getDefaultInfomationData("COMPKY").put("isAuth",false);
					membership.getDefaultInfomationData("COMPKY").put("isPass",false);
					
					if (!(e.keyCode >= 37 && e.keyCode <= 40)) {
						if(e.keyCode == 13){
							membership.duplicationCompkyCheck();
						}
						
						var inputVal = $(this).val();
						$(this).val(inputVal.replace(/[^a-z0-9]/gi,''));
					}
				});
			}else if(id == "USERID"){
				$tabs2_input.eq(i).keyup(function(e){
					var $obj = $(this).parent().next();
					$obj.text("");
					
					membership.getDefaultInfomationData("USERID").put("isAuth",false);
					membership.getDefaultInfomationData("USERID").put("isPass",false);
					
					if (!(e.keyCode >= 37 && e.keyCode <= 40)) {
						if(e.keyCode == 13){
							membership.duplicationUseridCheck();
						}
						
						var inputVal = $(this).val();
						$(this).val(inputVal.replace(/[^a-z0-9]/gi,''));
					}
				});
			}else if(id == "PASSWD"){
				$tabs2_input.eq(i).keyup(function(e){
					var $obj = $(this).parent().next();
					
					$obj.text("");
					$("#PASSRE_RESULT").text("");
					membership.getDefaultInfomationData("PASSWD").put("isPass",false);
					membership.getDefaultInfomationData("PASSRE").put("isPass",false);
					
					if(e.keyCode == 13){
						var $obj = $(this).parent().next();
						
						var value = $(this).val();
						
						var chkNum = value.search(/[0-9]/g);
					    var chkEng = value.search(/[a-z]/ig);
					    
						if(value.length < 8){
							$obj.text("8자리 이상 입력");
							membership.getDefaultInfomationData("PASSWD").put("isPass",false);
							membership.getDefaultInfomationData("PASSRE").put("isPass",false);
						}else if(chkNum < 0 || chkEng < 0){
							$obj.text("영문/숫자혼용 입력");
							membership.getDefaultInfomationData("PASSWD").put("isPass",false);
							membership.getDefaultInfomationData("PASSRE").put("isPass",false);
						}else{
							$obj.text("사용가능");
							membership.getDefaultInfomationData("PASSWD").put("isPass",true);
							
							$("#PASSRE").focus();
						}
					}
				});
				
				$tabs2_input.eq(i).focusout(function(e){
					var $obj = $(this).parent().next();
					
					var value = $(this).val();
					
					var chkNum = value.search(/[0-9]/g);
				    var chkEng = value.search(/[a-z]/ig);
				    
					if(value.length < 8){
						$obj.text("8자리 이상 입력");
						membership.getDefaultInfomationData("PASSWD").put("isPass",false);
					}else if(chkNum < 0 || chkEng < 0){
						$obj.text("영문/숫자혼용 입력");
						membership.getDefaultInfomationData("PASSWD").put("isPass",false);
					}else{
						$obj.text("사용가능");
						membership.getDefaultInfomationData("PASSWD").put("isPass",true);
					}
				});
			}else if(id == "PASSRE"){
				$tabs2_input.eq(i).keyup(function(e){
					var $obj = $(this).parent().next();
					$obj.text("");
					membership.getDefaultInfomationData("PASSRE").put("isPass",false);
					
					if(e.keyCode == 13){
						var $obj = $(this).parent().next();
						
						var value = $(this).val();
						var target = $("#PASSWD").val();
						
						var chkNum = value.search(/[0-9]/g);
					    var chkEng = value.search(/[a-z]/ig);
					    
						if(value != target){
							$obj.text("비밀번호 불일치");
							membership.getDefaultInfomationData("PASSRE").put("isPass",false);
						}else{
							$obj.text("비밀번호 확인완료");
							membership.getDefaultInfomationData("PASSRE").put("isPass",true);
							$(this).parent().parent().next().find("button").focus();
						}
					}
				});
				
				$tabs2_input.eq(i).focusout(function(e){
					var $obj = $(this).parent().next();
					
					var value = $(this).val();
					var target = $("#PASSWD").val();
					
					var chkNum = value.search(/[0-9]/g);
				    var chkEng = value.search(/[a-z]/ig);
				    
					if(value != target){
						$obj.text("비밀번호 불일치");
						membership.getDefaultInfomationData("PASSRE").put("isPass",false);
					}else{
						$obj.text("비밀번호 확인완료");
						membership.getDefaultInfomationData("PASSRE").put("isPass",true);
					}
				});
			}
		}
	},
	
	setButtonEvent : function(){
		//Tab1 Button
		var $tabs = $(".membership_tab");
		var $tab1_button = $tabs.eq(0).find("button");
		$tab1_button.unbind("click").on("click",function(){
			membership.checkApplyCode();
		});
		
		//Tab2 Button
		var $tab2_buttons = $tabs.eq(1).find("button");
		$tab2_buttons.eq(0).unbind("click").on("click",function(){
			membership.duplicationCompkyCheck();
		});
		$tab2_buttons.eq(1).unbind("click").on("click",function(){
			membership.duplicationUseridCheck();
		});
		$tab2_buttons.eq(2).unbind("click").on("click",function(){
			membership.saveDefaultInformation();
		});
		
		//Tab3 Button
		var $tab3_button = $tabs.eq(2).find("button");
		$tab3_button.unbind("click").on("click",function(){
			membership.saveOptionData();
		});
		
		//Tab4 Button
		var $tab4_button = $tabs.eq(3).find("button");
		$tab4_button.unbind("click").on("click",function(){
			membership.savePriceData();
		});
		
		//Tab5 Button
		var $tab5_button = $tabs.eq(4).find("button");
		$tab5_button.unbind("click").on("click",function(){
			membership.saveResultData();
		});
	},
	
	//event
	checkApplyCode : function(){
		var target = this.tabs["tabs_id1"]["id"];
		var param = dataBind.paramData(target);
		
		var code = param.get("APLCOD");
		if($.trim(code) == ""){
			alert("가입코드를 입력해 주세요.");
			return;
		}
		
		var json = netUtil.sendData({
			url : "/system/json/authMemberShip.data",
			param : param
		});
		
		if(json && json.data){
			var code = json.data["RESULT"];
			if(code == "S"){
				var isContinue = json.data["CONDAT"];
				
				this.setContinue = isContinue;
				
				var data = json.data["DATA"];
				var keys = Object.keys(data);
				if(keys.length > 0){
					for(var i in keys){
						var key = keys[i];
						var value = data[key];
						$("#"+key).text(value);
						
						this.companyInfomationData.put(key,value);
					}
				}
				
				if(isContinue == "Y"){
					if(!confirm("설정 진행 중인 데이터가 있습니다. 이어서 작업 하시겠습니까?\n*[취소]시, 이전 데이터는 초기화 됩니다.")){
						var chk = netUtil.sendData({
							url : "/system/json/deleteAllMemberShip.data",
							param : param
						});
						
						if(chk && chk.data){
							if(chk.data["RESULT"] == "S"){
								this.setContinue = "N";
								this.unbindTabs("1");
								this.moveTab(1);
							}
						}
						return;
			        }
				}
				
				this.unbindTabs("1");
				this.moveTab(1);
			}else if(code == "C"){
				alert("*처리 완료된 가입코드 입니다.\n등록한 관리자 ID로 로그인 해주세요.");
				window.location.href = "/wdscm/index.page";
			}else{
				alert("신청되지 않은 가입 코드 입니다.");
				this.init();
			}
		}
	},
	
	duplicationCompkyCheck : function(){
		var $obj = $("#COMPKY_RESULT");
		
		var target = this.tabs["tabs_id2"]["id"];
		var param = dataBind.paramData(target);
		
		var compky = param.get("COMPKY");
		if(compky.length < 4){
			$obj.text("영문 4자리 이상 입력");
			this.getDefaultInfomationData("COMPKY").put("isPass",false);
			return;
		}
		
		var json = netUtil.sendData({
			module : "System",
			command : "MEMBERSHIP_COMPKY_CHECK",
			sendType : "map",
			param : param
		});
		
		if(json && json.data){
			var cnt = json.data["CNT"];
			if(cnt > 0){
				$obj.text("중복으로 사용불가 ");
				
				this.getDefaultInfomationData("COMPKY").put("isAuth",true);
				this.getDefaultInfomationData("COMPKY").put("isPass",false);
			}else{
				$obj.text("사용가능");
				
				this.getDefaultInfomationData("COMPKY").put("isAuth",true);
				this.getDefaultInfomationData("COMPKY").put("isPass",true);
				
				$("#USERID").focus();
			}
		}
	},
	
	duplicationUseridCheck : function(){
		var $obj = $("#USERID_RESULT");
		
		var target = this.tabs["tabs_id2"]["id"];
		var param = dataBind.paramData(target);
		
		var userid = param.get("USERID");
		if(userid.length < 3){
			$obj.text("영문 3자리 이상 입력");
			this.getDefaultInfomationData("USERID").put("isPass",false);
			return;
		}
		
		var json = netUtil.sendData({
			module : "System",
			command : "MEMBERSHIP_USERID_CHECK",
			sendType : "map",
			param : param
		});
		
		if(json && json.data){
			var cnt = json.data["CNT"];
			if(cnt > 0){
				$obj.text("중복으로 사용불가 ");
				this.getDefaultInfomationData("USERID").put("isAuth",true);
				this.getDefaultInfomationData("USERID").put("isPass",false);
			}else{
				$obj.text("사용가능");
				this.getDefaultInfomationData("USERID").put("isAuth",true);
				this.getDefaultInfomationData("USERID").put("isPass",true);
				
				$("#PASSWD").focus();
			}
		}
	},
	
	saveDefaultInformation : function(){
		var target = this.tabs["tabs_id2"]["id"];
		
		var param = dataBind.paramData(target);
		param.putAll(this.companyInfomationData);
		
		var compky = $.trim(param.get("COMPKY"));
		var userid = $.trim(param.get("USERID"));
		var passwd = $.trim(param.get("PASSWD"));
		var passre = $.trim(param.get("PASSRE"));
		
		if(compky == ""){
			alert("회사코드를 입력 해주세요.");
			$("#COMPKY").focus();
			return;
		}else if(userid == ""){
			alert("관리자ID를 입력 해주세요.");
			$("#USERID").focus();
			return;
		}else if(passwd == ""){
			alert("비밀번호를 입력 해주세요.");
			$("#PASSWD").focus();
			return;
		}else if(passre == ""){
			$("#PASSRE").focus();
			alert("비밀번호 확인을 입력 해주세요.");
			return;
		}
		
		var compkyMap = this.getDefaultInfomationData("COMPKY");
		var compkyPass = compkyMap.get("isPass");
		var compkyAuth = compkyMap.get("isAuth");
		
		if(!compkyAuth){
			alert("회사코드 중복확인이 완료되지 않았습니다. 중복확인 후 진행 해주세요.");
			$("#COMPKY").focus();
			return;
		}else{
			if(!compkyPass){
				alert("유효하지 않은 회사코드 입니다.");
				$("#COMPKY").focus();
				return;
			}
		}
		
		var useridMap = this.getDefaultInfomationData("USERID");
		var useridPass = useridMap.get("isPass");
		var useridAuth = useridMap.get("isAuth");
		
		if(!useridAuth){
			alert("관리자ID 중복확인이 완료되지 않았습니다. 중복확인 후 진행 해주세요.");
			$("#USERID").focus();
			return;
		}else{
			if(!useridPass){
				alert("유효하지 않은 관리자ID 입니다.");
				$("#USERID").focus();
				return;
			}
		}
		
		var passwdMap = this.getDefaultInfomationData("PASSWD");
		var passwdPass = passwdMap.get("isPass");
		if(!passwdPass){
			alert("유효하지 않은 비밀번호 입니다.");
			$("#PASSWD").focus();
			return;
		}
		
		var passreMap = this.getDefaultInfomationData("PASSRE");
		var passrePass = passreMap.get("isPass");
		if(!passrePass){
			alert("비밀번호가 불일치 합니다. 비밀번호 확인을 다시 입력 해주세요.");
			$("#PASSRE").focus();
			return;
		}
		
		netUtil.send({
			url : "/system/json/saveDefaultInfo.data",
			param : param,
			successFunction : "membership.successSaveDefaultInfoCallBack"
		});
	},

	successSaveDefaultInfoCallBack : function(json, status){
		if(json && json.data){
			if(json.data["RESULT"] == "S"){
				this.unbindTabs("2");
				this.moveTab(2);
			}else{
				alert("기본정보를 등록하는데 실패하였습니다.")
			}
		}
	},
	
	//Common event
	unbindTabs : function(type){
		var $tabs = $(".membership_header ul li"); 
		switch (type) {
		case "init":
			for(var i = 1; i < 5; i++){
				$tabs.eq(i).unbind("click");
				this.setTabMoveEvt($tabs.eq(0));
				//this.setTabMoveEvt($tabs.eq(i));
			}
			break;
		case "1":
			if(this.setContinue == "Y"){
				var area = this.tabs["tabs_id1"]["id"];
				var param = dataBind.paramData(area);
				var comp = netUtil.sendData({
					module : "System",
					command : "AC01_COMPKY",
					sendType : "map",
					param : param
				});
				if(comp && comp.data){
					var compid = comp.data["COMPID"];
					param.put("COMPID",compid);
					var json = netUtil.sendData({
						module : "System",
						command : "MEMBERSHIP_RESULT02",
						sendType : "map",
						param : param
					});
					if(json && json.data){
						var compky = json.data["COMPKY"];
						var userid = json.data["USERID"];
						
						var bindMap = new DataMap();
						bindMap.put("COMPKY",compky);
						bindMap.put("USERID",userid);
						
						var bindAreaId = this.tabs["tabs_id2"]["id"];
						dataBind.dataBind(bindMap, bindAreaId);
						dataBind.dataNameBind(bindMap, bindAreaId);
						
						$("#COMPKY").prop("readonly",true);
						$("#COMPKY").css("background-color","#8080801f");
						$("#COMPKY").next().hide();
						$("#USERID").prop("readonly",true);
						$("#USERID").css("background-color","#8080801f");
						$("#USERID").next().hide();
						
						this.getDefaultInfomationData("COMPKY").put("isAuth",true);
						this.getDefaultInfomationData("COMPKY").put("isPass",true);
						this.getDefaultInfomationData("USERID").put("isAuth",true);
						this.getDefaultInfomationData("USERID").put("isPass",true);
					}
				}
			}
			
			$tabs.eq(0).unbind("click");
			this.setTabMoveEvt($tabs.eq(1));
			break;	
		case "2":
			if(this.setContinue == "Y"){
				var area = this.tabs["tabs_id2"]["id"];
				var param = dataBind.paramData(area);
				var json = netUtil.sendData({
					module : "System",
					command : "MEMBERSHIP_OPTION_CHECKED",
					sendType : "list",
					param : param
				});
				if(json && json.data){
					var data = json.data;
					var dataLen = data.length;
					if(dataLen > 0){
						var checkBoxAreaId = this.tabs["tabs_id3"]["id"];
						$("#"+checkBoxAreaId).find("input").prop("checked",false);
						for(var i = 0; i < dataLen; i++){
							var row = data[i];
							var id = row["OPTKEY"];
							$("#"+id).prop("checked",true);
						}
					}
				}
			}
			$tabs.eq(1).unbind("click");
			this.setTabMoveEvt($tabs.eq(2));
			break;
		case "3":
			if(this.setContinue == "Y"){
				var area = this.tabs["tabs_id2"]["id"];
				var param = dataBind.paramData(area);
				var json = netUtil.sendData({
					module : "System",
					command : "MEMBERSHIP_PRICE_CHECKED",
					sendType : "map",
					param : param
				});
				if(json && json.data){
					var data = json.data;
					var gradeid = data["GRADEID"];
					if(gradeid != ""){
						var checkBoxAreaId = this.tabs["tabs_id4"]["id"];
						var id = $("#"+checkBoxAreaId).find("input[value="+ gradeid +"]").attr("id");
						$("#"+id).prop("checked",true);
					}
				}
			}
			this.setTabMoveEvt($tabs.eq(3));
			break;	
		case "4":
			this.setTabMoveEvt($tabs.eq(4),true);
			break;	
		default:
			break;
		}
	},
	
	setTabMoveEvt : function($obj,flag){
		var $wrap = $(".membership_tab");
		var $wrapItem = $(".membership_header ul li");
		var areaId = $(".membership_tab").eq($obj.index()).attr("id"); 
		if(areaId == this.tabs["tabs_id2"]["id"]){
			setTimeout(function(){
				$("#"+areaId).find("input:not([readonly])").eq(0).focus();
			}, 300);
		}
		$obj.click(function(){
		    var i = $(this).index();
		    $wrap.removeClass("on");
		    $wrap.eq(i).addClass("on");
		    $wrapItem.removeClass("on");
		    $(this).addClass("on");
		    
		    if(flag){
		    	membership.selectResultPage();
		    }
		});
	},
	
	moveTab : function(i){
		$(".membership_header ul li").eq(i).trigger("click");
	},
	
	init : function(){
		var tab2CompanyInfomation = this.tabs["tabs_id2"]["textObjectIds"];
		for(var i in tab2CompanyInfomation){
			var key = tab2CompanyInfomation[i];
			$("#"+key).text("");
		}
		
		var tab2DefaultInfomation = this.tabs["tabs_id2"]["inputObjetIds"];
		for(var i in tab2DefaultInfomation){
			var key = tab2DefaultInfomation[i];
			$("#"+key).val("");
		}
		
		this.companyInfomationData.clear();
	},
	
	setOptionSetPage : function(){
		var json = netUtil.sendData({
			url : "/system/json/selectOptionSetData.data",
			sendType : "map"
		});
		
		if(json && json.data){
			var data = json.data;
			var dataLen = data.length;

			if(dataLen > 0){
				var tabId = this.tabs["tabs_id3"]["id"];
				var $tab = $("#"+tabId);
				
				$tab.find(".membership_option").remove();
				
				var $div = $("<div>");
				var $span = $("<span>");
				var $p = $("<p>");
				var $input = $("<input>");
				var $label = $("<label>");
				
				for(var i = 0; i < dataLen; i++){
					var $membership_option = $div.clone().addClass("membership_option");
					var $menu_name = $span.clone().addClass("menu_name");
					
					var head = data[i];
					var headName = head["OPTGNM"];
					var selectType = head["SELTYP"];
					var item = head["item"];
					var itemLen = item.length;
					
					$menu_name.text(headName);
					$membership_option.append($menu_name);
					
					if(itemLen > 0){
						for(var j = 0; j < itemLen; j++){
							var itemRow = item[j];
							
							var groupky = itemRow["OPGKEY"];
							var itemky = groupky+"_"+itemRow["OPTKEY"];
							var itemnm = itemRow["OPTTNM"];
							var shortx = itemRow["SHORTX"];
							
							var $wrap = $p.clone();
							
							var type = "";
							if(selectType == "01"){
								type = "checkbox";
							}else{
								type = "radio";
							}
							
							$wrap.append($input.clone().attr({"type":type,"id":itemky,"name":groupky,"value":itemky}));
							$wrap.append($label.clone().addClass(type).attr({"for":itemky}).text(itemnm));
							if($.trim(shortx) != ""){
								$wrap.append($span.clone().text("(" + shortx + ")"));
							}
							$membership_option.append($wrap);
						}
					}
					
					$tab.find(".code_save").before($membership_option);
				}
				$(".membership_option").each(function(){
				    $(this).find("input").eq(0).prop("checked",true);
				});
			}
		}
	},
	
	saveOptionData : function(){
		var area = this.tabs["tabs_id3"]["id"];
		var data = dataBind.paramData(area);
		var info = dataBind.paramData(this.tabs["tabs_id2"]["id"]);
		
		if(!$("input[name=INBOUND]").is(":checked")){
			alert("입고 옵션을 1개 이상 선택해 주세요.");
			$("html, body").animate({scrollTop : 0});
			return;
		}
		
		if(!$("input[name=INVENTORY]").is(":checked")){
			alert("재고 옵션을 1개 이상 선택해 주세요.");
			var offset = $("input[name=INVENTORY]").eq(0).parent().offset();
			$("html, body").animate({scrollTop : offset.top});
			return;
		}
		
		var param = new DataMap();
		param.put("data",data);
		param.put("COMPKY",info.get("COMPKY"));
		param.put("USERID",info.get("USERID"));
		
		netUtil.send({
			url : "/system/json/saveOptionSetData.data",
			param : param,
			successFunction : "membership.successSaveOptionDataCallBack"
		});
	},
	
	successSaveOptionDataCallBack : function (json, status){
		if(json && json.data){
			if(json.data["RESULT"] == "S"){
				this.unbindTabs("3");
				this.moveTab(3);
			}
		}
	},
	
	setPricePage : function(){
		var json = netUtil.sendData({
			url : "/system/json/selectPriceData.data",
			sendType : "list"
		});
		
		if(json && json.data){
			var data = json.data;
			var dataLen = data.length;
			
			if(dataLen > 0){
				var tabId = this.tabs["tabs_id4"]["id"];
				var $membership_tab = $("#"+tabId);
				
				$membership_tab.find("input,label").remove();
				
				var $input = $("<input>");
				var $label = $("<label>");
				var $span  = $("<span>");
				
				for(var i = 0; i < dataLen; i++){
					var row = data[i];
					var priceId = row["GRADEID"];
					var priceName = row["GRADENAME"];
					var bscamt = this.numbeComma(row["BSCAMT"]);
					var tskcnt = this.numbeComma(row["TSKCNT"]);
					var tskdat = row["TSKDAT"];
					var excdat = row["EXCDAT"];
					var exccnt = this.numbeComma(row["EXCCNT"]);
					var excamt = this.numbeComma(row["EXCAMT"]);
					var crrcod = row["CRRCOD"];
					var cultyp = row["CULTYP"];
					
					var name = "PRICE";
					var id = name + (i + 1);
					
					
					var $radioObject = $input.clone().addClass("membership_charge_radio").attr({"type":"radio","id":id,"name":name,"value":priceId});
					var $labelObject = $label.clone().addClass("membership_charge").attr("for",id);
					var $priceName   = $span.clone().text(priceName);
					var $bscamt      = $span.clone().text("기본료 : " + bscamt + crrcod);
					var $task        = $span.clone().text("Task : " + tskcnt + "건 " + " / " + tskdat + "일");
					var $excamt      = $span.clone().text("초과과금 : " + excdat + "일  " + exccnt + "건 초과당 " + excamt +crrcod+" " + cultyp);
					
					$labelObject.append($priceName).append($bscamt).append($task).append($excamt);
					
					var $code_save = $membership_tab.find(".code_save");
					$code_save.before($radioObject);
					$code_save.before($labelObject);
				}
			}
			
			$membership_tab.find("input").eq(0).prop("checked",true);
		}
	},
	
	savePriceData : function(){
		var area = this.tabs["tabs_id4"]["id"];
		var data = dataBind.paramData(area);
		var info = dataBind.paramData(this.tabs["tabs_id2"]["id"]);
		
		var param = new DataMap();
		param.put("GRADEID",data.get("PRICE"));
		param.put("COMPID",info.get("COMPKY"));
		
		netUtil.send({
			url : "/system/json/savePriceData.data",
			param : param,
			successFunction : "membership.successSavePriceDataCallBack"
		});
	},
	
	successSavePriceDataCallBack : function (json, status){
		if(json && json.data){
			if(json.data["RESULT"] == "S"){
				this.selectResultPage();
				
				this.unbindTabs("4");
				this.moveTab(4);
			}
		}
	},
	
	setResultPage : function(){
		var tabId = this.tabs["tabs_id5"]["id"];
		var $obj = $("#"+tabId+" .membership_info");
		
		$obj.eq(0).attr("id","result_info");
		$obj.eq(1).attr("id","result_code");
		$obj.eq(2).attr("id","result_option");
		$obj.eq(3).attr("id","result_price");
		
		var $rs01 = $obj.eq(0).find("p");
		$rs01.each(function(){
			var i = $(this).index();
			
			var $value = $(this).find("span:odd");
			$value.text("");
			$value.attr("id","result_info" + i);
		});
		
		var $rs02 = $obj.eq(1).find("p");
		$rs02.each(function(){
			var i = $(this).index();
			
			var $value = $(this).find("span:odd");
			$value.text("");
			$value.attr("id","result_code" + i);
		});
		
		var $rs03 = $obj.eq(2).children();
		$rs03.remove();
		
		var $rs04 = $obj.eq(3).find("p");
		$rs04.each(function(){
			var i = $(this).index();
			
			$(this).find("span").text("");
			
			var $value1 = $(this).find("span:even");
			$value1.attr("id","result_price_tag" + i);
			
			var $value2 = $(this).find("span:odd");
			$value2.attr("id","result_price_value" + i);
		});
	},
	
	initResultPage : function(){
		$("#result_info").find("span[id]").each(function(){
			$(this).text("");
		});
		
		$("#result_code").find("span[id]").each(function(){
			$(this).text("");
		});
		
		$("#result_option").children().remove();
		
		$("#result_price").find("span[id]").each(function(){
			$(this).text("");
		});
	},
	
	selectResultPage : function(){
		var info = dataBind.paramData(this.tabs["tabs_id2"]["id"]);
		
		var param = new DataMap();
		param.put("COMPID",info.get("COMPKY"));
		
		var json = netUtil.sendData({
			url : "/system/json/selectResultData.data",
			sendType : "map",
			param : param
		});
		
		if(json && json.data){
			this.initResultPage();
			
			var data = json.data;
			var dataLen = data.length;
			if(data != null){
				var rs01 = data["R01"];
				var compnm = rs01["COMPNM"];
				var biznum = rs01["BIZNUM"];
				var mngrnm = rs01["MNGRNM"];
				var telnum = rs01["TELNUM"];
				
				$("#result_info1").text(compnm);
				$("#result_info2").text(biznum);
				$("#result_info3").text(mngrnm);
				$("#result_info4").text(telnum);
				
				var rs02 = data["R02"];
				var compky = rs02["COMPKY"];
				var userid = rs02["USERID"];
				
				$("#result_code1").text(compky);
				$("#result_code2").text(userid);
				
				var rs03 = data["R03"];
				var rs03Len = rs03.length;
				if(rs03Len > 0){
					var $target = $("#result_option");
					var $p = $("<p>");
					var $span = $("<span>");
					
					$target.append($span.clone().addClass("menu_name").text("옵션"));
					
					for(var i = 0; i < rs03Len; i++){
						var row = rs03[i];
						var optgnm = row["OPTGNM"];
						var opttnm = row["OPTTNM"];
						
						var $wrap = $p.clone();
						var $tag = $span.clone().text(optgnm + " : ");
						var $value = $span.clone().text(" " + opttnm);
						
						$wrap.append($tag).append($value);
						$target.append($wrap);
					}
				}
				
				var rs04 = data["R04"];
				var gradnm = rs04["GRADENAME"];
				var bscamt = this.numbeComma(rs04["BSCAMT"]);
				var tskcnt = this.numbeComma(rs04["TSKCNT"]);
				var tskdat = rs04["TSKDAT"];
				var excdat = rs04["EXCDAT"];
				var exccnt = this.numbeComma(rs04["EXCCNT"]);
				var excamt = this.numbeComma(rs04["EXCAMT"]);
				var crrcod = rs04["CRRCOD"];
				var cultyp = rs04["CULTYP"];
				
				$("#result_price_tag1").text(gradnm + " : ");
				$("#result_price_value1").text("월 " + bscamt + crrcod);
				$("#result_price_tag2").text("Task : ");
				$("#result_price_value2").text(tskcnt + "건 / " + tskdat + "일");
				$("#result_price_tag3").text("초과 과금 : ");
				$("#result_price_value3").text(excdat + "일 " + excamt + "건 초과당 " + excamt + crrcod + " " + cultyp);
			}
		}
	},
	
	saveResultData : function(){
		var info = dataBind.paramData(this.tabs["tabs_id2"]["id"]);
		
		var param = new DataMap();
		param.put("COMPID",info.get("COMPKY"));
		
		var json = netUtil.sendData({
			url : "/system/json/saveResultData.data",
			sendType : "map",
			param : param
		});
		
		if(json && json.data){
			if(json && json.data){
				if(json.data["RESULT"] == "S"){
					alert("*설정이 완료 되었습니다.\n등록한 관리자 ID로 접속해 주세요.");
					window.location.href = "/wdscm/index.page";
				}
			}
		}
	},
	
	numbeComma : function(n) {
	    return n.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
	}
}

var membership = new Membership();