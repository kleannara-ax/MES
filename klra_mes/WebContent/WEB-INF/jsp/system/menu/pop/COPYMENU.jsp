<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Copy Menu</title>
<%@ include file="/common/include/webdek/head.jsp" %>
<%@ include file="/common/include/webdek/tree.jsp" %>
<style type="text/css">
.search_wrap{height: 175px;}
.message span{color: #e86b29;font-size: 12px;font-weight: bold;}
.title span{
	box-sizing: border-box;
    display: inline-block;
    padding: 10px 20px;
    font-size: 12px;
    vertical-align: top;
    height: 100%;
    font-weight: bold;
    border-bottom: 2px solid #e86b29;
}
.content{width: 100%;height:35px;padding-top: 10px;}
.content ul li{float: left;}
.content #searchArea li.th{width: 180px;}
.content #searchArea li.td{width: calc(100% - 190px);}
.content #searchArea li.td input{width: 100%;}
.content #searchArea li.td input[readonly="readonly"]{background-color: #e8e9eb !important;}
.content#menuGroup ul{width: 100%;}
.content#menuGroup ul li{height: 30px;border: 1px solid #dadfe2;}
.content#menuGroup ul li.th{width: 100px;background-color: #e8e9eb;font-weight: bold;padding-left: 5px;line-height: 30px;}
.content#menuGroup ul li.td{width: calc(100% - 118px);background-color: transparent;}
.content#menuGroup ul li.td input{width: 100%;height: 100%;border: 0;outline: none;}

.btn_wrap .fl_l{padding: 0;height: 25px;}
.btn_wrap .fl_l .selectAll{
	width: 25px;
    height: 25px;
    border: 2px solid #99a4b1;
}
.btn_wrap .fl_l .selectAll.on{
	display: inline-block;
	background: url(/common/theme/webdek/images/save.png) no-repeat;
    background-size: 14px;
    background-position: center;
    margin: 0;
}
.btn_wrap .fl_l span{
	height: 100%;
    line-height: 25px;
    padding-left: 5px;
    display: inline-block;
    vertical-align: top;
    font-size: 12px;
}
</style>
<script type="text/javascript">
	var g_treeId = "treeList";
	var gMenuId = "";
	
	$(document).ready(function(){
		$("#tab1-1 ul").attr("id",g_treeId);
		
		treeList.setTree({
	    	id       : g_treeId,
	    	module   : "System",
			command  : "MSTTREEMENU",
			pkCol    : "MENUID",
		    pidCol   : "PMENUID",
		    nameCol  : "MENUNAME",
		    sortCol  : "SORTORDER",
		    editable : false,
		    isCheck  : true,
		    open: true,
		    appendCodeView : true
	    });
		
		$("#tab1-1 .btn_wrap .fl_r button").each(function(){
			var i = $(this).index();
			switch (i) {
			case 0:
				$(this).attr("onclick","treeList.toggleNodeAll('"+g_treeId+"',this);");
				break;
			}
		});
		
		$("[name=MENUGROUPID]").focus();
		
		setInputEvent();
	});
	
	function setInputEvent(){
		var $obj = $("[name=NEW_MENUGROUPID]");
		$obj.focusout(function(){
			var value = $.trim($(this).val());
			if(!isNull(value)){
				var param = new DataMap();
				param.put("MENUGROUPID", value);
				var json = netUtil.sendData({
					module   : "System",
					command  : "MSTMENUG",
					sendType : "count",
					param : param
				});
				
				if(json.data > 0){
					commonUtil.msgBox("[" + value + "] 이미 등록된 메뉴 그룹 ID 입니다.");
					$(this).val("");
					return;
				}else{
					$("[name=NEW_MENUGNAME]").focus();
				}
			}
		});
		
		$obj.keydown(function(e){
			var code = e.keyCode;
			if(code == 13){
				$obj.focusout();
			}
		});
	}

	function searchList(){
		if(validate.check("searchArea")){
			var param = inputList.setRangeParam("searchArea");
			var menuGroupId = param.get("MENUGROUPID");
			if(menuGroupId == gMenuId){
				return;
			}
			
			if(isNull(menuGroupId)){
				param.put("MENUGROUPID", "");
				param.put("MENUGNAME", "");
				dataBind.dataNameBind(param, "searchArea");
				return;
			}
			
			var treeBox = treeList.treeMap.get(g_treeId);
			treeBox.setData([]);
			
			var json = netUtil.sendData({
				module   : "System",
				command  : "MSTMENUG",
				sendType : "count",
				param : param
			});
			
			if(json.data > 0){
				treeList.treeList({
					id : g_treeId,
			    	param : param
				});
			}else{
				commonUtil.msgBox("등록된 메뉴그룹ID가 없습니다.");
				gMenuId = "";
			}
		}
	}
	
	function init(){
		var treeBox = treeList.treeMap.get(g_treeId);
		treeBox.setData([]);
		
		var param = dataBind.paramData("searchArea");
		param.put("MENUGROUPID", "");
		param.put("MENUGNAME", "");
		dataBind.dataNameBind(param, "searchArea");
		
		var data = dataBind.paramData("menuGroup");
		param.put("NEW_MENUGROUPID", "");
		param.put("NEW_MENUGNAME", "");
		dataBind.dataNameBind(param, "menuGroup");
		
		$("[name=MENUGROUPID]").focus();
	}
	
	function searchHelpEventOpenBefore(searchCode, multyType, $inputObj, rowNum){
		var param = new DataMap();
		if(searchCode == "SHMSTMENUG"){
			param.put("MENUGROUPID", "");
			param.put("MENUGNAME", "");
			param.put("DELETEYN", "N");
		}
		return param;
	}
	
	function searchHelpEventCloseAfter(searchCode, multyType, selectData, rowData){
		if(searchCode == "SHMSTMENUG"){
			dataBind.dataNameBind(rowData, "searchArea");
			searchList();
		}
	}
	
	// 저장 
	function saveData(){
		
		// treeList.getCheckData : checked 리스트
		var list = treeList.getCheckData("treeList");
		if(list.length == 0){
			commonUtil.msgBox(configData.SYSTEM_ROWSEMPTY);
			return;
		}
		
		var data = dataBind.paramData("menuGroup");
		var menuGid = $.trim(data.get("NEW_MENUGROUPID"));
		if(isNull(menuGid)){
			commonUtil.msgBox("VALID_required", [uiList.getLabel("STD_MENUGROUPID")]);
			$("[name=NEW_MENUGROUPID]").focus();
			return;
		}
		
		data.put("MENUGROUPID",menuGid);
		data.put("MENUGNAME",data.get("NEW_MENUGNAME"));
		data.put("list",list);
		
		netUtil.send({
			url : "/system/json/saveCopyMenu.data",
			param : data,
			successFunction : "successSaveCallBack"
		});
	}
	
	function successSaveCallBack(json, status){
		if(json && json.data){
			if(json.data > 0){
				commonUtil.msgBox("SYSTEM_SAVEOK");
				
				var data = dataBind.paramData("menuGroup");
				page.linkPopClose(data);
			}else{
				commonUtil.msgBox("EXECUTE_ERROR");
			}
		}
	}

	function commonBtnClick(btnName){
		if(btnName == "Clear"){
			init();
		}else if(btnName == "Save"){
			saveData();
		}
	}
	
	function treeListEventDataBindEnd(gridId, dataLength){
		if(gridId == "treeList"){
			var data = dataBind.paramData("searchArea");
			gMenuId = data.get("MENUGROUPID");
			
			var json = netUtil.sendData({
				module : "System",
				command : "MSTMENUG",
				param : data,
			});
			
			if(json && json.data){
				dataBind.dataNameBind(json.data[0], "searchArea");
			}
			
			var $btn = $("#tab1-1 .fl_r button");
			if($btn.hasClass("node_open")){
				treeList.openNodeAll(gridId);
			}else{
				$btn.trigger("click");
			}
			
			$("[name=NEW_MENUGROUPID]").focus();
		}
	}
	
	function toggleSelectAll(o){
		var treeBox = treeList.treeMap.get("treeList");
		var $obj = $(o);
		if($obj.hasClass("on")){
			$obj.removeClass("on");
			treeBox.treeObj.checkAllNodes(false);
		}else{
			$obj.addClass("on");
			treeBox.treeObj.checkAllNodes(true);
		}
	}
	
	function isNull(sValue) {
		var value = (sValue+"").replace(" ", "");
		
		if( new String(value).valueOf() == "undefined")
			return true;
		if( value == null )
			return true;
		if( value.toString().length == 0 )
			return true;
		
		return false;
	}
</script>
</head>
<body>
<%@ include file="/common/include/webdek/layout.jsp"%>
<!-- content -->
<div class="content_wrap">
	<div class="content_inner contentH_inner">
		<%@ include file="/common/include/webdek/title.jsp" %>
		<div class="content_serch">
			<div class="btn_wrap">
				<div class="fl_l">
				</div>
				<div class="fl_r">
					<input type="button" CB="Clear REFLECT BTN_CLEAR" />
					<input type="button" CB="Save SAVE BTN_SAVE" />
				</div>
			</div>
			<div class="search_inner">
				<div class="search_wrap">
					<div class="message">
						<span>*복사할 메뉴그룹ID를 입력 해주세요.</span>
					</div>
					<div class="content">
						<ul id="searchArea">
							<input type="hidden" name="COMPID"  value="<%=compky%>"/>
							<li class="th"><input type="text" class="input" name="MENUGROUPID" UIInput="S,SHMSTMENUG" UIFormat="U"/></li>
							<li class="td"><input type="text" class="input" name="MENUGNAME" readonly="readonly"/></li>
						</ul>
					</div>
					<div class="title">
						<span>메뉴 그룹 등록</span>
					</div>
					<div class="content" id="menuGroup">
						<ul>
							<li class="th"><span CL="STD_MENUGROUPID"></span></li>
							<li class="td"><input type="text" class="input" name="NEW_MENUGROUPID" UIFormat="U" validate="required"/></li>
						</ul>
						<ul>
							<li class="th"><span CL="STD_MENUGNAME"></span></li>
							<li class="td"><input type="text" class="input" name="NEW_MENUGNAME"/></li>
						</ul>
					</div>
				</div>
			</div>
		</div>
		<div class="search_next_wrap" style="height: calc(100% - 245px);">
			<div class="content_layout tabs">
				<div class="table_box section" id="tab1-1">
					<div class="table_list01" style="height: 100%;">
						<div class="btn_wrap">
							<div class="fl_l">
								<button class="selectAll" onclick="toggleSelectAll(this);"></button>
								<span>전체 선택</span>
							</div>
							<div class="fl_r">
								<button class="btn_basic"><span>전체 node 열기</span></button>
							</div>
						</div>
						<ul style="width:100%;height: calc(100% - 50px);overflow:auto;"></ul>
					</div>
				</div>
			</div>
		</div>
	</div>
</div>
<!-- // content -->
<%@ include file="/common/include/webdek/bottom.jsp" %>
</body>
</html>