<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>TMS</title>
<%@ include file="/common/include/popHead.jsp"%> 

<script type="text/javascript" src="/common/js/timepicker/jquery.timepicker.js"></script>
<link rel="stylesheet" type="text/css" href="/common/js/timepicker/jquery.timepicker.css" />
  
<style rel="stylesheet" type="text/css">
	img, table, tbody, tfoot, thead, tr, th, td{
		vertical-align:middle;
	}
	
	.type1.table th, .type1.table td  {
		border:1px solid black;
		padding-left : 0px;
	}
	
	.title {
		color:#444; font-weight:bold;
	}
	
</style>
<script type="text/javascript">
  

	$(document).ready(function(){  
		searchList();
	});
	
	function searchList() {   
			var param = new DataMap();
		 	
			param.put("SIMID", "16040700001");
			
			// 1_1 Load Summary 시작
			var json = netUtil.sendData({
				module : "TmsAdmin",
				command : "VMS_SOL_RESULT",
				bindId : "tabs1_1,tabs1_2,tabs1_5,tabs2_1,tabs2_2",
				sendType : "list",
				bindType : "field",
				param : param
			});
			list = json.data;

			tabs_data = new DataMap();

			var addTr=""; 
			var prevTr=""; 
			
			prevTr  = "<tr>";
			prevTr += "  <th colspan='2'><h2 class=\"title\">Load Summary</h2></th>";
			prevTr += "</tr>";
			prevTr += "<tr>";
			prevTr += "  <td>Title</td>";
			prevTr += "  <td>"+list[0].SIMULATION_ID+"</td>";
			prevTr += "</tr>";
			prevTr += "<tr>";
			prevTr += "  <td>Create At</td>";
			prevTr += "  <td>"+list[0].CREATED_AT+"</td>";
			prevTr += "</tr>";
			
			jQuery("#table1_1").empty();
			jQuery("#table1_1").append(prevTr);

			dataBind.dataNameBind(tabs_data, "tabs1_1");
			// 1_1 Load Summary 끝
			
			// 1_2 Summary 시작
			var addTr=""; 
			var prevTr=""; 
			
			prevTr  = "<tr>";
			prevTr += "  <th colspan='4'><h2 class=\"title\">Summary</h2></th>";
			prevTr += "</tr>";
			
			jQuery("#table1_2").empty();
			jQuery("#table1_2").append(prevTr);
			
			$.each(list, function(i, obj) { 
				addTr  = "<tr>";
				addTr += "  <td>Pieces Loaded</td>";
				addTr += "  <td>"+obj.PIECES_QTY+"</td>";
				addTr += "  <td>Volume % Average</td>";
				addTr += "  <td>"+obj.VOLUME_PERCENT+"</td>";
				addTr += "</tr>";
				addTr += "<tr>";
				addTr += "  <td>Pieces Left</td>";
				addTr += "  <td>"+obj.CREATED_AT+"</td>";
				addTr += "  <td>Volume Loaded(ft3)</td>";
				addTr += "  <td>"+obj.LOAD_VOLUME+"</td>";
				addTr += "</tr>";
				addTr += "<tr>";
				addTr += "  <td>Solutions Loaded(Sea Containers)</td>";
				addTr += "  <td>"+obj.CREATED_AT+"</td>";
				addTr += "  <td>Weight Loaded(lb)</td>";
				addTr += "  <td>"+obj.LOAD_WEIGHT+"</td>";
				addTr += "</tr>";
				
				jQuery("#table1_2").append(addTr); 
				
				
			});
			
			dataBind.dataNameBind(tabs_data, "tabs1_2");
			// 1_2 Summary 끝
			
			// 1_5 Solutions 시작
			addTr=""; 
			prevTr=""; 
			
			prevTr  = "<tr>";
			prevTr += "  <th colspan='5'><h2 class=\"title\">Solutions</h2></th>";
			prevTr += "</tr>";
			
			jQuery("#table1_5").empty();
			jQuery("#table1_5").append(prevTr);
			
			$.each(list, function(i, obj) { 
				addTr  = "<tr>";
				addTr += "  <th colspan='5'>"+obj.DESCRIPTION+"</th>";
				addTr += "</tr>";
				addTr += "<tr>";
				addTr += "  <td rowspan='8'><img src='/tms/sol/img/getSolImg.data?simId="+obj.SIMULATION_ID+"&solSeq="+ obj.SOL_SEQ +"' style='width:200px;height:auto;'/></td>";
				addTr += "  <td>Cargoes</td>";
				addTr += "  <td>"+obj.SKU_QTY+"</td>";
				addTr += "  <td>Pieces</td>";
				addTr += "  <td>"+obj.PIECES_QTY+"</td>";
				addTr += "</tr>";
				
				addTr += "<tr>";
				addTr += "  <td>Length %</td>";
				addTr += "  <td>"+obj.LENGTH_PERCENT+"</td>";
				addTr += "  <td>Length Loaded</td>";
				addTr += "  <td>"+obj.LOAD_LENGTH+"</td>";
				addTr += "</tr>";
				
				addTr += "<tr>";
				addTr += "  <td>floor %</td>";
				addTr += "  <td>"+obj.FLOOR_PERCENT+"</td>";
				addTr += "  <td>Pattern Type</td>";
				addTr += "  <td>"+obj.ENUM_VEHICLE_TYPE+"</td>";
				addTr += "</tr>";
				
				addTr += "<tr>";
				addTr += "  <td>volume %</td>";
				addTr += "  <td>"+obj.VOLUME_PERCENT+"</td>";
				addTr += "  <td>volume Loaded</td>";
				addTr += "  <td>"+obj.LOAD_VOLUME+"(ft3)</td>";
				addTr += "</tr>";
				
				addTr += "<tr>";
				addTr += "  <td>Weight Total</td>";
				addTr += "  <td>"+obj.GROSS_WEIGHT+"(lb)</td>";
				addTr += "  <td>Weight Loaded</td>";
				addTr += "  <td>"+obj.LOAD_WEIGHT+"(lb)</td>";
				addTr += "</tr>";
				
				addTr += "<tr>";
				addTr += "  <td>Size Loaded</td>";
				addTr += "  <td>"+obj.IN_LENGTH+ " x " + obj.IN_WIDTH + " x "+obj.IN_HEIGHT+"</td>";
				addTr += "  <td></td>";
				addTr += "  <td></td>";
				addTr += "</tr>";
				
				addTr += "<tr>";
				addTr += "  <td>Center Of Gravity</td>";
				addTr += "  <td>"+obj.COG_LENGTH+ " x " + obj.COG_WIDTH + " x "+obj.COG_HEIGHT+"</td>";
				addTr += "  <td></td>";
				addTr += "  <td></td>";
				addTr += "</tr>";
				
				addTr += "<tr>";
				addTr += "  <td>Sea Container</td>";
				addTr += "  <td>"+obj.CODE_VEHICLE+"</td>";
				addTr += "  <td></td>";
				addTr += "  <td></td>";
				addTr += "</tr>";
				
				jQuery("#table1_5").append(addTr); 
			});
			
			dataBind.dataNameBind(tabs_data, "tabs1_5");
			// 1_5 Solutions 끝
			
			// 2_1 Solution 시작
			list = json.data;

			tabs_data = new DataMap();

			addTr=""; 
			prevTr=""; 

			prevTr  = "<tr>";
			prevTr += "  <th colspan='2'><h2 class=\"title\">Solutions</h2></th>";
			prevTr += "</tr>";
			prevTr += "<tr>";
			prevTr += "  <td>Title</td>";
			prevTr += "  <td>"+list[0].SIMULATION_ID+"</td>";
			prevTr += "</tr>";
			prevTr += "<tr>";
			prevTr += "  <td>Create At</td>";
			prevTr += "  <td>"+list[0].CREATED_AT+"</td>";
			prevTr += "</tr>";
			
			jQuery("#table2_1").empty();
			jQuery("#table2_1").append(prevTr);
			
			dataBind.dataNameBind(tabs_data, "tabs2_1");
			// 2_1 Solution 끝
			
			// 2_2 Solution 시작
			addTr=""; 
			
			jQuery("#table2_2").empty();
			
			$.each(list, function(i, obj) { 
				addTr  = "<tr>";
				addTr += "  <th colspan='5'>"+obj.DESCRIPTION+"</th>";
				addTr += "</tr>";
				addTr += "<tr>";
				
				
				addTr += "  <td rowspan='8'><img src='/tms/sol/img/getSolImg.data?simId="+obj.SIMULATION_ID+"&solSeq="+ obj.SOL_SEQ +"' style='width:200px;height:auto;'/></td>";
				addTr += "  <td>Cargoes</td>";
				addTr += "  <td>"+obj.SKU_QTY +"</td>";
				addTr += "  <td>Pieces</td>";
				addTr += "  <td>"+obj.PIECES_QTY+"</td>";
				addTr += "</tr>";
				
				addTr += "<tr>";
				addTr += "  <td>Length %</td>";
				addTr += "  <td>"+obj.LENGTH_PERCENT+"</td>";
				addTr += "  <td>Length Loaded</td>";
				addTr += "  <td>"+obj.LOAD_LENGTH+"</td>";
				addTr += "</tr>";
				
				addTr += "<tr>";
				addTr += "  <td>floor %</td>";
				addTr += "  <td>"+obj.FLOOR_PERCENT+"</td>";
				addTr += "  <td>Pattern Type</td>";
				addTr += "  <td>"+obj.ENUM_VEHICLE_TYPE+"</td>";
				addTr += "</tr>";
				
				addTr += "<tr>";
				addTr += "  <td>volume %</td>";
				addTr += "  <td>"+obj.VOLUME_PERCENT+"</td>";
				addTr += "  <td>volume Loaded</td>";
				addTr += "  <td>"+obj.LOAD_VOLUME+"(ft3)</td>";
				addTr += "</tr>";
				
				addTr += "<tr>";
				addTr += "  <td>Weight Total</td>";
				addTr += "  <td>"+obj.GROSS_WEIGHT+"(lb)</td>";
				addTr += "  <td>Weight Loaded</td>";
				addTr += "  <td>"+obj.LOAD_WEIGHT+"(lb)</td>";
				addTr += "</tr>";
				
				addTr += "<tr>";
				addTr += "  <td>Size Loaded</td>";
				addTr += "  <td>"+obj.IN_LENGTH+ " x " + obj.IN_WIDTH + " x "+obj.IN_HEIGHT+"</td>";
				addTr += "  <td></td>";
				addTr += "  <td></td>";
				addTr += "</tr>";
				
				addTr += "<tr>";
				addTr += "  <td>Center Of Gravity</td>";
				addTr += "  <td>"+obj.COG_LENGTH+ " x " + obj.COG_WIDTH + " x "+obj.COG_HEIGHT+"</td>";
				addTr += "  <td></td>";
				addTr += "  <td></td>";
				addTr += "</tr>";
				
				addTr += "<tr>";
				addTr += "  <td>Sea Container</td>";
				addTr += "  <td>"+obj.CODE_VEHICLE+"</td>";
				addTr += "  <td></td>";
				addTr += "  <td></td>";
				addTr += "</tr>";
				
				var json = netUtil.sendData({
					module : "TmsAdmin",
					command : "VMS_SOL_MNF_RESULT",
					bindId : "tabs2_2",
					sendType : "list",
					bindType : "field",
					param : param
				});
				
				list1 = json.data;

				tabs_data = new DataMap();
				
				addTr += "<tr><td colspan='5' style='padding:0px'><table class='table type1'><tr>";
				addTr += "  <th>C</th>";
				addTr += "  <th>Seq.</th>";
				addTr += "  <th>Group</th>";
				addTr += "  <th>Cargo</th>";
				addTr += "  <th>Qty</th>";
				addTr += "  <th>Pieces</th>";
				addTr += "  <th>Size<br/>(inch)</th>";
				addTr += "  <th>Net<br/>Volume<br/>(ft3)</th>";
				addTr += "  <th>Gross<br/>Volume<br/>(ft3)</th>";
				addTr += "  <th>Net<br/>Weight<br/>(lb)</th>";
				addTr += "  <th>Gross<br/>Weight<br/>(lb)</th>";
				addTr += "</tr>";

				$.each(list1, function(i, obj) { 
					
					addTr += "<tr>";
					addTr += "  <td style='background-color:#"+obj.COLOR+"'></td>";
					addTr += "  <td>"+obj.MANIFEST_SEQ+"</td>";
					addTr += "  <td>"+obj.GROUPNAME+"</td>";
					addTr += "  <td>"+obj.ITEM+"</td>";
					addTr += "  <td>"+obj.ITEM_QTY+"</td>";
					addTr += "  <td>"+obj.PIECES_QTY+"</td>";
					addTr += "  <td>"+obj.ITEM_LENGTH + " x " + obj.ITEM_WIDTH + " x " + obj.ITEM_HEIGHT +"</td>";
					addTr += "  <td>"+obj.LOAD_VOLUME+"</td>";
					addTr += "  <td>"+obj.GROSS_VOLUME+"</td>";
					addTr += "  <td>"+obj.LOAD_WEIGHT+"</td>";
					addTr += "  <td>"+obj.GROSS_WEIGHT+"</td>";
					addTr += "</tr>";
				});

				addTr += "</table></td></tr>";
				
				jQuery("#table2_2").append(addTr); 
				
			});
			
			dataBind.dataNameBind(tabs_data, "tabs2_2"); 
			
			
			
			// 1_3 Sea Containers 시작
			var json = netUtil.sendData({
				module : "TmsAdmin",
				command : "VMS_CONTAINERS",
				bindId : "tabs1_3",
				sendType : "list",
				bindType : "field",
				param : param
			});
			list = json.data;

			var addTr=""; 
			var prevTr=""; 
			
			tabs_data = new DataMap();
			
			prevTr  = "<tr>";
			prevTr += "  <th colspan='8'><h2 class=\"title\">Sea Containers</h2></th>";
			prevTr += "</tr>";
			prevTr += "<tr>";
			prevTr += "  <th>Name</th>";
			prevTr += "  <th>Description</th>";
			prevTr += "  <th>Length(inch)</th>";
			prevTr += "  <th>Width(inch)</th>";
			prevTr += "  <th>Height(inch)</th>";
			prevTr += "  <th>Weight(lb)</th>";
			prevTr += "  <th>Max Weight(lb)</th>";
			//prevTr += "  <th>Qty</th>";
			prevTr += "</tr>";
			
			jQuery("#table1_3").empty();
			jQuery("#table1_3").append(prevTr);
			
			$.each(list, function(i, obj) { 
				
				addTr = "<tr>";
				addTr += "  <td>"+obj.name+"</td>";
				addTr += "  <td>"+obj.alias+"</td>";
				addTr += "  <td>"+obj.in_length+"</td>";
				addTr += "  <td>"+obj.in_width+"</td>";
				addTr += "  <td>"+obj.in_height+"</td>";
				addTr += "  <td>"+obj.weight+"</td>";
				addTr += "  <td>"+obj.max_weight+"</td>";
				//addTr += "  <td>"+obj.qty+"</td>";
				addTr += "</tr>";
				
				jQuery("#table1_3").append(addTr); 
			});
			
			dataBind.dataNameBind(tabs_data, "tabs1_3");
			// 1_3 Sea Containers 끝

			// 1_4 Cargoes 시작
			var json = netUtil.sendData({
				module : "TmsAdmin",
				command : "VMS_SKUS",
				bindId : "tabs1_4",
				sendType : "list",
				bindType : "field",
				param : param
			});
			list = json.data;

			var addTr=""; 
			var prevTr=""; 
			
			tabs_data = new DataMap();
			
			prevTr  = "<tr>";
			prevTr += "  <th colspan='8'><h2 class=\"title\">Cargoes</h2></th>";
			prevTr += "</tr>";
			prevTr += "<tr>";
			prevTr += "  <th>Name</th>";
			prevTr += "  <th>Length(inch)</th>";
			prevTr += "  <th>Width(inch)</th>";
			prevTr += "  <th>Height(inch)</th>";
			prevTr += "  <th>Weight(lb)</th>";
			prevTr += "  <th>Group</th>";
			prevTr += "  <th>Price(US$)</th>";
			prevTr += "  <th>Qty</th>";
			prevTr += "</tr>";
			
			jQuery("#table1_4").empty();
			jQuery("#table1_4").append(prevTr);
			
			$.each(list, function(i, obj) { 
				
				addTr = "<tr>";
				addTr += "  <td>"+obj.name+"</td>";
				addTr += "  <td>"+obj.length+"</td>";
				addTr += "  <td>"+obj.width+"</td>";
				addTr += "  <td>"+obj.height+"</td>";
				addTr += "  <td>"+obj.weight+"</td>";
				addTr += "  <td>"+obj.groupname+"</td>";
				addTr += "  <td>"+obj.UnitPrice+"</td>";
				addTr += "  <td>"+obj.qty+"</td>";
				addTr += "</tr>";
				
				jQuery("#table1_4").append(addTr); 
			});
			
			dataBind.dataNameBind(tabs_data, "tabs1_4");
			// 1_4 Sea Cargoes 끝
			
			// 3_1 Stacking 시작
			var json = netUtil.sendData({
				module : "TmsAdmin",
				command : "VMS_RST_SPACE_RESULT",
				bindId : "tabs3_1,tabs3_2",
				sendType : "list",
				bindType : "field",
				param : param
			});
			list = json.data;

			tabs_data = new DataMap();

			var addTr=""; 
			var prevTr=""; 
			
			prevTr  = "<tr>";
			prevTr += "  <th colspan='2'><h2 class=\"title\">Stacking</h2></th>";
			prevTr += "</tr>";
			prevTr += "<tr>";
			prevTr += "  <td>Title</td>";
			prevTr += "  <td>"+list[0].SIMULATION_ID+"</td>";
			prevTr += "</tr>";
			prevTr += "<tr>";
			prevTr += "  <td>Create At</td>";
			prevTr += "  <td>"+list[0].CREATED_AT+"</td>";
			prevTr += "</tr>";
				
			jQuery("#table3_1").empty();
			jQuery("#table3_1").append(prevTr);
			dataBind.dataNameBind(tabs_data, "tabs3_1");
			
			
			prevTr = " <tr><td>";
			prevTr = " <div style='float:left'>";
				
			jQuery("#table3_2").empty();
			jQuery("#table3_2").append(prevTr);
			$.each(list, function(i, obj) { 
				addTr  = "  <img src='/tms/sol/img/getSpaceImg.data?simId="+obj.SIMULATION_ID+"&spaceSeq="+ obj.SPACE_SEQ +"' style='width:200px;height:auto;'/>";
				
				jQuery("#table3_2").append(addTr); 
			});
			
			prevTr = " </div></td></tr>";
			
			jQuery("#table3_2").append(prevTr);
			
			dataBind.dataNameBind(tabs_data, "tabs3_2");
			// 3_1 Stacking 끝
			
			
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
		</div>
	</div>
  
	<!-- content -->
	<!-- content -->
	<div class="content">
		<div class="innerContainer" id="content">

			<!-- contentContainer -->
			<div class="contentContainer">
 
				<div class="bottomSect type2" style="top:10px">
					<div class="tabs"  id="bottomTabs">
						<ul class="tab type2">
							<li><a href="#tabs1"><span >Summary</span></a></li>
							<li><a href="#tabs2"><span >Solution</span></a></li>
							<li><a href="#tabs3"><span >Stacking</span></a></li>
						</ul> 
						<div id="tabs1">
							<div class="section type1" style="overflow: scroll">
								<div class="searchInBox">
									<div id="tabs1_1" class="table type1">
										<!-- 	title -->
										<table id="table1_1">
										</table>
									</div>
									<br/>
									<div id="tabs1_2" class="table type1">
										<!-- 	Solutions -->
										<table id="table1_2">
										</table>
									</div>
									<br/>
									<div id="tabs1_3" class="table type1">
										<!-- 	Solutions MNF -->
										<table id="table1_3" class="table type1">
										</table>
									</div>
									<br/>
									<div id="tabs1_4" class="table type1">
										<!-- 	Solutions MNF -->
										<table id="table1_4" class="table type1">
										</table>
									</div>
									<br/>
									<div id="tabs1_5" class="table type1">
										<!-- 	Solutions MNF -->
										<table id="table1_5">
										</table>
									</div>
								</div>
							</div>
						</div>
						
						<div id="tabs2">
							<div class="section type1" style="overflow: scroll">
								<div class="searchInBox">
									<div id="tabs2_1" class="table type1">
										<!-- 	title -->
										<table id="table2_1">
										</table>
									</div>
									<br/>
									<div id="tabs2_2" class="table type1">
										<!-- 	Solutions -->
										<table id="table2_2">
										</table>
									</div>
								</div>
							</div>
						</div>	
						
						<div id="tabs3">
							<div class="section type1" style="overflow: scroll">
								<div class="searchInBox">
									<div id="tabs3_1" class="table type1">
										<!-- 	title -->
										<table id="table3_1">
										</table>
									</div>
									<br/>
									<div id="tabs3_2" class="table type1">
										<!-- 	title -->
										<table id="table3_2">
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