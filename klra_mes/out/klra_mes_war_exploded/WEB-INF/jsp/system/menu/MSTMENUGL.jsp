<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Grid default</title>
<%@ include file="/common/include/webdek/head.jsp" %>
<%@ include file="/common/include/webdek/tree.jsp" %>
<script type="text/javascript">
	var g_treeId = "treeList";
	var gMenuId = "";
	
	$(document).ready(function(){
		$("#tab1-1 ul").attr("id",g_treeId);
		
		treeList.setTree({
	    	id       : g_treeId,
	    	module   : "System",
			command  : "MSTTREEMENU",
			bindArea : "detail",
			pkCol    : "MENUID",
		    pidCol   : "PMENUID",
		    nameCol  : "MENUNAME",
		    sortCol  : "SORTORDER",
		    editable : true,
		    isMove   : true,
		    isCheck  : false,
		    clickBindAll : true,
		    appendCodeView : true,
		    bindArea : "tab2-1"
	    });
		
		$("#tab1-1 .btn_wrap .fl_r button").each(function(){
			var i = $(this).index();
			switch (i) {
			case 0:
				$(this).attr("onclick","treeList.toggleNodeAll('"+g_treeId+"',this);");
				break;
			case 1:
				$(this).attr("onclick","treeList.addNewRow('"+g_treeId+"');");
				break;
			case 2:
				$(this).attr("onclick","treeList.removeRow('"+g_treeId+"');");
				break;	
			default:
				break;
			}
			
		});
	});

	function searchList(){
		if(validate.check("searchArea")){
			var treeBox = treeList.treeMap.get(g_treeId);
			treeBox.setData([]);
			
			var param = inputList.setRangeParam("searchArea");
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
	
	function searchHelpEventOpenBefore(searchCode, multyType, $inputObj, rowNum){
		var param = new DataMap();
		if(searchCode == "SHMSTMENUG"){
			param.put("DELETEYN", "N");
		}
		return param;
	}
	
	function saveData(){
		//데이터 검증 데이터
		//1. isSort : tree 정렬 여부 tree 일 때만 변경전 원천 데이터와 비교
		//2. beforeSortList : 저장 전 원천 데이터
		//tree 구정 저장 데이터
		//1. saveList : [C,U,D] tree 구조 정보를 저장
		//2. sortLIst : [U] tree 정렬 순서를 update
		var list = treeList.getModifyData("treeList");
		if(list.length == 0){
			commonUtil.msgBox(configData.MSG_SYSTEM_SAVEEMPTY);
			return;
		}
		
		var isSort = treeList.isSort("treeList");
		var beforeSortData = treeList.getBeforeSortData("treeList");
		
		var saveList = list.filter(function(data){
			return data.get("isUpdate");
		});
		var sortList = list.filter(function(data){
			return data.get("isSort");
		});
		
		var param = new DataMap();
		param.put("MENUGROUPID",gMenuId);
		param.put("isSort",isSort);
		param.put("beforeSortList", beforeSortData);
		param.put("saveList",saveList);
		param.put("sortList",sortList);
		
		netUtil.send({
			url : "/system/json/saveMenu.data",
			param : param,
			successFunction : "successSaveCallBack"
		});
	}
	
	function successSaveCallBack(json, status){
		if(json && json.data){
			if(json.data > 0){
				commonUtil.msgBox("SYSTEM_SAVEOK");
				searchList();
			}else{
				commonUtil.msgBox("EXECUTE_ERROR");
			}
		}
	}

	function commonBtnClick(btnName){
		if(btnName == "Search"){
			var param = new DataMap();
	        param.put("PROGID", "<%= menuId%>");
	        param.put("LGTYPE", "SEARCH");
	        var json = netUtil.sendData({
	            url: "/mes/system/json/saveLog.data",
	            param : param
	        });
			
			searchList();
		}else if(btnName == "Save"){
			saveData();
		}else if(btnName == "Copy"){
			page.linkPopOpen("/system/menu/pop/COPYMENU.page",null,"height=1000,width=600,resizable=yes");
		}
	}
	
	function treeListEventDataBindEnd(gridId, dataLength){
		if(gridId == "treeList"){
			var data = dataBind.paramData("searchArea");
			gMenuId = data.get("MENUGROUPID");
		}
	}
	
	function treeGridAddRowEventBefore(treeId, parentNode, newNode){
		if(treeId == g_treeId){
			if(gMenuId == ""){
				commonUtil.msgBox("SYSTEM_DATARELOAD");
				return false;
			}
			
			var param = new DataMap();
			<%-- param.put("COMPID","<%=compky%>"); --%>
			param.put("MENUGID",gMenuId);
			param.put("MENUID","");
			param.put("PMENUID","");
			param.put("MENULABEL","");
			param.put("MENUNAME","");
			param.put("URI","");
			param.put("PARAM","");
			param.put("SORTORDER","");
			param.put("MENUTYPE","DIR");
			param.put("DELETEYN","N");
			
			return param;
		}
	}
	
	function treeGridAddRowEventAfter(treeId, parentNode, newNode){
		if(treeId == g_treeId){
			var param = new DataMap();
			if(parentNode != undefined && parentNode != null){
				if(parentNode.children.length > 0){
					var rowNum = parentNode[configData.GRID_ROW_NUM];
					treeList.setColValue(treeId, rowNum, "MENUTYPE", "DIR");
				}
			}
			return param;
		}
	}
	
	function treeGridColValueChangeEvent(treeId, treeNodeId, rowNum, colName, colValue, treeNode){
		if(treeId == "treeList"){
			if(colName == "MENUID"){
				if(isNull(colValue)){
					
				}else{
					var param = new DataMap();
					param.put("COMPID","<%=compky%>");
					param.put("MENUID",colValue);
					
					var json = netUtil.sendData({
						module   : "System",
						command  : "MSTMENU",
						sendType : "list",
						param    : param
					});
					if(json && json.data){
						if(json.data.length > 0){
							//상위 메뉴 ID, 현재 컬럼의 데이터 제외 후, setColValue
							var data = json.data[0];
							var pMenuId = treeList.treeMap.get(treeId).pidCol;
							var sortOrder = treeList.treeMap.get(treeId).sortCol;
							
							var keys = treeList.getBindAreaNameKeyList(treeId);
							for(var i in keys){
								var key = keys[i];
								var value = data[key];
								if(key != colName && key != pMenuId && key != sortOrder){
									treeList.setColValue(treeId, rowNum, key, value);
								}
							}
						}
					}
				}
			}
		}
	}
	
	function linkPopCloseEvent(data){
		var param = new DataMap();
		param.put("MENUGROUPID", data.get("NEW_MENUGROUPID"));
		dataBind.dataNameBind(param, "searchArea");
		searchList();
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
		<div class="content_serch" id="searchArea">
			<input type="hidden" name="COMPID"  value="<%=compky%>"/>
			<div class="btn_wrap">
				<div class="fl_l">
				</div>
				<div class="fl_r">
					<input type="button" CB="Search SEARCH BTN_SEARCH" />
					<input type="button" CB="Save SAVE BTN_SAVE" />
					<input type="button" CB="Copy COPY BTN_MENUCOPY" />
				</div>
			</div>
			<div class="search_inner">
				<div class="search_wrap ">
					<dl>
						<dt CL="STD_MENUGROUPID"></dt>
						<dd>
							<input type="text" class="input" name="MENUGROUPID" UIInput="S,SHMSTMENUG" IAname="Search" UIFormat="U" validate="required"/>
						</dd>
					</dl>
				</div>
				<div class="btn_tab">
					<input type="button" class="btn_more" value="more" onclick="searchMore()"/>
				</div>
			</div>
		</div>
		<div class="content-horizontal-wrap h-wrap-min" style="height: calc(100% - 90px);">
			<div class="content_layout tabs content_left" style="height:100%">
				<ul class="tab tab_style02">
					<li><a href="#tab1-1"><span>일반</span></a></li>
					<li class="btn_zoom_wrap">
						<ul>
							<li><button class="btn btn_bigger"><span>확대</span></button></li>
						</ul>
					</li>
				</ul> 
				<div class="table_box section" id="tab1-1" style="height: calc(100% - 87px);overflow: auto;">
					<div class="btn_wrap">
						<div class="fl_r">
							<button class="btn_basic"><span>전체 node 열기</span></button>
						</div>
					</div>
					<ul style="width:100%; overflow:auto;"></ul>
				</div>
			</div>
			
			<div class="handlerH_wrap">
				<div class="handlerH"></div>
			</div>
			
			<div class="content_layout tabs content_right" style="margin-top:0px;height:100%">
				<ul class="tab tab_style02">
					<li><a href="#tab2-1"><span>상세</span></a></li>
					<li class="btn_zoom_wrap">
						<ul>
							<li><button class="btn btn_bigger"><span>확대</span></button></li>
						</ul>
					</li>
				</ul>
				<div class="table_box section" id="tab2-1">
					<div class="inner_search_wrap">
						<table class="detail_table" id="detail">
							<colgroup>
	                            <col width="20%" />
	                            <col width="80%"/>
	                        </colgroup>
	                        <tbody>         
	                            <tr>
	                                <th CL="STD_MENUID"></th>
	                                <td>
	                                    <input type="text" class="input" name="MENUID" style="width:calc(100% - 26px);height: 100%;border: 0;margin: 0;"/>
	                                </td>
	                            </tr>
	                            <tr>
	                                <th CL="STD_MENUNAME"></th>
	                                <td>
	                                    <input type="text" class="input" name="MENUNAME" style="width: 100%;height: 100%;border: 0;margin: 0;"/>
	                                </td>
	                            </tr> 
	                            <tr>
	                                <th CL="STD_MENULABEL"></th>
	                                <td>
	                                    <input type="text" class="input" name="MENULABEL" style="width:calc(100% - 26px);height: 100%;border: 0;margin: 0;"/>
	                                </td>
	                            </tr> 
	                            <!-- <tr>
	                                <th CL="STD_MENUTYPE"></th>
	                                <td>
										<select name="MENUTYPE" class="input" CommonCombo="MENUTYPE">
											<option value="" CL="STD_SELECT"></option>
										</select>	                                    
	                                </td>
	                            </tr> -->   
	                            <tr>
	                                <th CL="STD_URI"></th>
	                                <td>
	                                    <input type="text" class="input" name="URI" style="width: 100%;height: 100%;border: 0;margin: 0;"/>
	                                </td>
	                            </tr>
	                            <tr>
	                                <th CL="STD_PMENUID"></th>
	                                <td>
	                                    <input type="text" class="input" name="PMENUID" readonly="readonly" style="width: 100%;height: 100%;border: 0;margin: 0;"/>
	                                </td>
	                            </tr>   
	                            <tr>
	                                <th CL="STD_SORTORDER"></th>
	                                <td>
	                                    <input type="text" class="input" name="SORTORDER" UIFormat="NS 20,0" readonly="readonly" style="width: 100%;height: 100%;border: 0;margin: 0;"/>
	                                </td>
	                            </tr>
	                            <tr>
	                                <th CL="STD_DELETEYN"></th>
	                                <td>
										<select class="input" name="DELETEYN" CommonCombo="DELYN" ComboCodeView=false>
											<option value="" CL="STD_SELECT"></option>
										</select>                                   
	                                </td>
	                            </tr>   
	                        </tbody>
						</table>
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