<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>MES</title>
<%@ include file="/common/include/webdek/head.jsp" %>



<script src="/common/js/chart/chartJs/Chart.min.js"></script>
<!-- <script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/2.4.0/Chart.min.js"></script> -->




<script type="text/javascript">
	


//차트변수
let chrt1Bar, chrt2Pie, chrt3Line;
let cnfg_chrt1Bar, cnfg_chrt2Pie, cnfg_chrt3Line;

let arr = []

for(let i = 0; i <= 254; i++)

arr[i] = "rgba("+Math.floor(Math.random() * 255)+", "+Math.floor(Math.random() * 255)+", "+Math.floor(Math.random() * 255)+", 1)"

 

let G_chrtBgColor = arr
/* let G_chrtBgColor = [
	 "#3e95cd"
	,"#8e5ea2"
	,"#3cba9f"
	,"#e8c3b9"
	,"#c45850"
	,'rgba(255, 206, 86, 0.2)'
	,'rgba(75, 192, 192, 0.2)'
	,'rgba(153, 102, 255, 0.2)'
	,'rgba(255, 99, 132, 0.2)'
	,'rgba(54, 162, 235, 0.2)'
	,'rgba(255, 99, 132, 1)'
	,'rgba(54, 162, 235, 1)'
	,'rgba(255, 206, 86, 1)'
	,'rgba(75, 192, 192, 1)' 
	,'rgba(153, 102, 255, 1)'
	,'rgba(255, 159, 64, 1)' 
]; */
let G_chrt1DataObj = {}, G_chrt2DataObj = {}, G_chrt3DataObj = {};



$(document).ready(function() {
	
	$('#chrt1Bar, #chrt2Pie, #chrt3Line').hide();
	
	gridList.setGrid({
    	id : "gridList",
    	url : "/mes/Work/WRK01/json/datalist.data",
    	bigdata : false
    });
	
	setChrt1Bar_wrk01();
	setChrt2Pie_wrk01();
	setChrt3Line_wrk01();
});









function setChrt1Bar_wrk01() {
	const ctx = document.getElementById('chrt1Bar').getContext('2d');
	
	cnfg_chrt1Bar = {
	    type: 'bar',
	    data: {
 	        // labels: ['Red', 'Blue', 'Yellow', 'Green', 'Purple', 'Orange'],
// 	        labels: ['점보롤', '밀롤', '재단', '포장'],
	        labels: [],
	        datasets: [{
// 	            label: '',
//  	            labels: ['점보롤', '밀롤', '재단', '포장'],
 	            label: '공정별 비가동현황',
 	            // data: [12, 19, 3, 5, 2, 3],
	            // data: [120, 100, 300, 430],
	            data: [],
	            backgroundColor: G_chrtBgColor,
// 	            backgroundColor: [
// 	                'rgba(255, 99, 132, 0.2)',
// 	                'rgba(54, 162, 235, 0.2)',
// 	                'rgba(255, 206, 86, 0.2)',
// 	                'rgba(75, 192, 192, 0.2)'
//  	                // 'rgba(153, 102, 255, 0.2)',
//  	                // 'rgba(255, 159, 64, 0.2)'
// 	            ],
// 	            borderColor: [
// 	                'rgba(255, 99, 132, 1)',
// 	                'rgba(54, 162, 235, 1)',
// 	                'rgba(255, 206, 86, 1)',
// 	                'rgba(75, 192, 192, 1)'
//  	                // 'rgba(153, 102, 255, 1)',
//  	                // 'rgba(255, 159, 64, 1)'
// 	            ],
	            borderWidth: 1
	        }]
	    },
	    options: {
	    	legend: {
	            display: false
	    		},
	        scales: {
	            y: {
	                beginAtZero: true
	            },
		        yAxes: [{// y축 콤마
	            	ticks: {
	   		    		beginAtZero: true,
	           	    	callback: function(value, index) {
	         		    	return value.toLocaleString("ko-KR");
	           		    }                  		
	                }
	            }]
	        },
 	        title: {
		        display: true,
 		        text: '공정별 비가동현황'
 		    }
	    }
	};
	
	chrt1Bar = new Chart(ctx, cnfg_chrt1Bar);
	
	
	document.getElementById("chrt1Bar").onclick = function(evt) {
		var activePoints = chrt1Bar.getElementsAtEvent(evt);
		
// 		console.log('activePoints =>'+JSON.stringify(activePoints) );
// 		if (!activePoints[0]["_index"]) return;
// 		console.log('activePoints =>'+activePoints[0]["_index"] );
// 		console.log('activePoints =>'+activePoints.toString() );
// 		console.log('activePoints =>'+JSON.stringify(activePoints) );
		
	    if (!activePoints || activePoints.length <= 0) return;
        
	    var clickedElIdx = activePoints[0]["_index"];
        
        // console.log('activePoints[0] => '+JSON.stringify(activePoints[0]) );
        
        var label = chrt1Bar.data.labels[clickedElIdx];
        var value = chrt1Bar.data.datasets[0].data[clickedElIdx];
        
//         console.log('label =>'+label );
//         console.log('value =>'+value );
        
        
        
        hideOrInit_chrt_wrk01('chrt3Line', cnfg_chrt3Line, chrt3Line);
        
// 		$('#chrt2Pie').show();
// 		let labelArr = ["J-평량교체", "J-지합불량", "J-초출폐품", "M-뭉치유형", "M-지관파손", "M-모서리찍힘"];
//         loadChrtData_wrk01(cnfg_chrt2Pie, chrt2Pie, labelArr, [2478,5267,734,784,433,256]);
        
        G_chrt2DataObj.procCd = G_chrt1DataObj.procCdArr[clickedElIdx];
		setChrtData_wrk01('loadChrt2Pie', G_chrt2DataObj.procCd);
	}
	
}







function setChrt2Pie_wrk01() {
	const ctx = document.getElementById('chrt2Pie').getContext('2d');
	
	cnfg_chrt2Pie = {
	    type: 'pie',   // plugins:[ChartDataLabels],
	    data: {
 	      // labels: ["Africa", "Asia", "Europe", "Latin America", "North America"],
// 	      labels: ["J-평량교체", "J-지합불량", "J-초출폐품", "M-뭉치유형", "M-지관파손", "M-모서리찍힘"],
	      labels: [],
	      datasets: [{
// 	        label: "Population (millions)",
// 	        backgroundColor: ["#3e95cd", "#8e5ea2","#3cba9f","#e8c3b9","#c45850",'rgba(255, 206, 86, 0.2)'],
// 	        backgroundColor: ["#3e95cd", "#8e5ea2","#3cba9f","#e8c3b9","#c45850",'rgba(255, 206, 86, 0.2)', 'rgba(75, 192, 192, 0.2)', 'rgba(153, 102, 255, 0.2)', 'rgba(255, 159, 64, 0.2)'],
// 	        backgroundColor: ["#3e95cd", "#8e5ea2","#3cba9f","#e8c3b9","#c45850",'rgba(255, 206, 86, 0.2)', 'rgba(75, 192, 192, 0.2)', 'rgba(153, 102, 255, 0.2)', 'rgba(255, 99, 132, 0.2)'],
	        backgroundColor: G_chrtBgColor,
	         // 'rgba(75, 192, 192, 0.2)'
             // 'rgba(153, 102, 255, 0.2)',
             // 'rgba(255, 159, 64, 0.2)'
// 	        data: [2478,5267,734,784,433,256]
	        data: []
	      }]
	    },
	    options: {
            maintainAspectRatio : true,
            responsive: true,
            // legend: false,
            animation: false
            // pieceLabel: {
            //    mode:"label",
            //    position:"outside",
            //    fontSize: 11,
            //    fontStyle: 'bold'
            // }
	       , title: {
	        display: true,
	        text: '항목별 비가동 비율(%)'
	       },

           legend: {

               display: true,

               position: "bottom",

               align: "start"

           }
	    }
 	    // options: {
 	    //   maintainAspectRatio: true, //true 하게 되면 캔버스 width,height에 따라 리사이징된다.
 	    //   title: {
 	    //     display: true,
 	    //     text: 'Predicted world population (millions) in 2050'
 	    //   }
 	    // }
	};
	
	chrt2Pie = new Chart(ctx, cnfg_chrt2Pie);
	
	
	
	document.getElementById("chrt2Pie").onclick = function(evt) {
		
		var activePoints = chrt2Pie.getElementsAtEvent(evt);
		
// 		console.log('activePoints =>'+activePoints[0]["_index"] );
// 		console.log('activePoints =>'+activePoints.toString() );
// 		console.log('activePoints =>'+JSON.stringify(activePoints) );
		
	    if (!activePoints || activePoints.length <= 0) return;
	    
        var clickedElIdx = activePoints[0]["_index"];
        
        var label = chrt2Pie.data.labels[clickedElIdx];
        var value = chrt2Pie.data.datasets[0].data[clickedElIdx];
        
//         console.log('label =>'+label );
//         console.log('value =>'+value );
        
//         $('#chrt3Line').show();
//         loadChrtData_wrk01(cnfg_chrt3Line, chrt3Line, ['전월', '당월'], [673, 250]);
		
		let abnCd = G_chrt2DataObj.abnCdArr[clickedElIdx];
		setChrtData_wrk01('loadChrt3Line', G_chrt2DataObj.procCd, abnCd);
	}
	
}







function setChrt3Line_wrk01() {
	const ctx = document.getElementById('chrt3Line').getContext('2d');
	
	cnfg_chrt3Line = {
	    type: 'line',
	    data: {
// 	        labels: ['1', '2', '3', '4', '5', '6', '7'],
// 	        labels: ['7/29/2022', '7/30/2022', '7/31/2022', '8/1/2022', '8/2/2022', '8/3/2022', '8/4/2022'],
	        labels: [],
	        datasets: [{
	            label: '기간별 비가동 발생 추이',
	            data: [],
// 	            data: [
// 	                10,
// 	                3,
// 	                30,
// 	                23,
// 	                10,
// 	                5,
// 	                50
// 	            ],
	            borderColor: "rgba(255, 201, 14, 1)",
	            backgroundColor: "rgba(255, 201, 14, 0.5)",
	            fill: false,
	            lineTension: 0
	        }]
	    },
	    options: {
	    	legend: {
	            display: false
	    		},
	        responsive: true,
// 	        title: {
// 	            display: true,
// 	            text: '폐품 전월 대비 당월 현황'
// 	        },
	        tooltips: {
	            mode: 'index',
	            intersect: false,
	        },
	        hover: {
	            mode: 'nearest',
	            intersect: true
	        },
	        scales: {
// 	            xAxes: [{
// 	                display: true,
// 	                scaleLabel: {
// 	                    display: true,
// 	                    labelString: 'x축'
// 	                }
// 	            }],
	            yAxes: [{
	                display: true,
	                ticks: {
	                    suggestedMin: 0,
	                }
// 	                ,scaleLabel: {
// 	                    display: true,
// 	                    labelString: 'y축'
// 	                }
	            }],
		        yAxes: [{// y축 콤마
	            	ticks: {
	   		    		beginAtZero: true,
	           	    	callback: function(value, index) {
	         		    	return value.toLocaleString("ko-KR");
	           		    }                  		
	                }
	            }]
	        },
 	        title: {
 		        display: true,
 		        text: '기간별 비가동 발생추이'
 		      }
	    }
	};
	
	chrt3Line = new Chart(ctx, cnfg_chrt3Line);
	
	
	document.getElementById("chrt3Line").onclick = function(evt) {
		var activePoints = chrt3Line.getElementsAtEvent(evt);
		
// 		console.log('activePoints =>'+activePoints[0]["_index"] );
// 		console.log('activePoints =>'+activePoints.toString() );
// 		console.log('activePoints =>'+JSON.stringify(activePoints) );
		
	    if (!activePoints || activePoints.length <= 0) return;
	    	
        var clickedElementindex = activePoints[0]["_index"];
        
        var label = chrt3Line.data.labels[clickedElementindex];
        var value = chrt3Line.data.datasets[0].data[clickedElementindex];
        
//         console.log('label =>'+label );
//         console.log('value =>'+value );
	}
	
}












function setChrtData_wrk01(flg, chrtPrm, chrtPrm2) {
// 	let succssFn = '';
// 	if (flg == 'loadChrt1Bar') succssFn = '';
// 	else if (flg == '') succssFn = '';
// 	else if (flg == '') succssFn = '';
	let param = getSrchPrm_wrk01();
	param.put("P_CHRT_TYPE", flg);
	if (chrtPrm) param.put("CHRT_PRM", chrtPrm);
	if (chrtPrm2) param.put("CHRT_PRM2", chrtPrm2);
	
	netUtil.send({
	   url : "/mes/Work/WRK01/json/datalist.data",
// 	   url : "/mes/Work/wrk21/json/datalist.data",
	   param : param,
	   successFunction : flg
// 	   successFunction : succssFn
	});
}



function loadChrt1Bar(json, status) {
// 	console.log('json => '+JSON.stringify(json) );
	if (!json || !json.data || json.data.length <= 0) return;
	
	let procCdArr = [], labelArr = [], dataArr = [];
	$.each(json.data, function(idx, itm) {
		procCdArr.push(itm.PROC_CD);
		labelArr.push(itm.PROC_NM);
		dataArr.push(itm.ABN_TM_SUM);
	});
// 	console.log('labelArr => '+labelArr );
// 	console.log('dataArr => '+dataArr );
// 	G_chrt1DataObj = {procCdArr: procCdArr, labelArr: labelArr, dataArr: dataArr};
	G_chrt1DataObj = {procCdArr: procCdArr};
	$('#chrt1Bar').show();
	loadChrtData_wrk01(cnfg_chrt1Bar, chrt1Bar, labelArr, dataArr);
}


function loadChrt2Pie(json, status) {
	if (!json || !json.data || json.data.length <= 0) return;
	
	let abnCdArr = [], labelArr = [], dataArr = [];
	$.each(json.data, function(idx, itm) {
		abnCdArr.push(itm.ABN_CD);
		labelArr.push(itm.ABN_NM);
		dataArr.push(itm.ABN_TM_SUM);
	});
	G_chrt2DataObj.abnCdArr = abnCdArr;
	$('#chrt2Pie').show();
	loadChrtData_wrk01(cnfg_chrt2Pie, chrt2Pie, labelArr, dataArr);
}


function loadChrt3Line(json, status) {
	if (!json || !json.data || json.data.length <= 0) return;
// 	let dataArr = [];
// 	dataArr.push(json.data[0].PRV_MNTH);
// 	dataArr.push(json.data[0].THIS_MNTH);
	
	let labelArr = [], dataArr = [];
	$.each(json.data, function(idx, itm) {
		labelArr.push(itm.ABN_DT);
		dataArr.push(itm.ABN_TM_SUM);
	});
	
	$('#chrt3Line').show();
	loadChrtData_wrk01(cnfg_chrt3Line, chrt3Line, labelArr, dataArr);
}




function loadChrtData_wrk01(cnfg, chrt, labelArr, dataArr) {
	cnfg.data.labels = labelArr;
	cnfg.data.datasets[0].data = dataArr;
	chrt.update();
}









function hideOrInit_chrt_wrk01(chrtSlctr, cnfg, chrt) {
	$('#'+chrtSlctr).hide();
	cnfg.data.datasets[0].data = [];
	chrt.update();
}




function getSrchPrm_wrk01() {
	param = inputList.setRangeParam("searchArea");
	
	// 2023-03-13(월요일) 안상현, RANGE 검색 추가
	const range_data_param = param.get("RANGE_DATA_PARAM")
	const abn_dt = range_data_param.get("WRK003.ABN_DT_Range")
	const date = abn_dt.split("↓")
	const SDate = date[1]
	const EDate = date[2]
	
	param.put("P_TYPE", "LIST")
	param.put("SDATE", SDate)
	param.put("EDATE", EDate)
	param.put("WERKS", $("#WERKS").val().toUpperCase()) // 플랜트 코드
	
	return param;
}









function searchList(){
	if (!validate.check("searchArea")) return;
// 	var param = inputList.setRangeParam("searchArea");
// 	param.put("P_TYPE", "LIST");
	gridList.gridList({
		id : "gridList",
		param : getSrchPrm_wrk01()
	});
	
	hideOrInit_chrt_wrk01('chrt1Bar', cnfg_chrt1Bar, chrt1Bar);
	hideOrInit_chrt_wrk01('chrt2Pie', cnfg_chrt2Pie, chrt2Pie);
	hideOrInit_chrt_wrk01('chrt3Line', cnfg_chrt3Line, chrt3Line);
	
	setChrtData_wrk01('loadChrt1Bar');
}

function commonBtnClick(btnName){
	//commonUtil.debugMsg("commonBtnClick : ", arguments);
	if(btnName == "Search"){
		searchList();
	}else if(btnName == "Save"){
		saveData();
	}
}

function gridListEventDataBindEnd(gridId, dataLength){
	if(gridId == "gridList"){
		var list = gridList.getGridData(gridId);
		
		for(var i = 0; i < dataLength; i++){
			gridList.setRowReadOnly(gridId, i, true, ["RUN_STA"]);
		}
	}
}



</script>



</head>
<body>
<%@ include file="/common/include/webdek/layout.jsp" %>
<!-- content -->
<div class="content_wrap">
	<div class="content_inner">
		<%@ include file="/common/include/webdek/title.jsp" %>
		<div class="content_serch" id="searchArea">
			<div class="btn_wrap">
				<div class="fl_l">
				</div>
				<div class="fl_r">
					<input type="button" id="button-0-1" CB="Search SEARCH BTN_SEARCH" />
				</div>
			</div>
			<div class="search_inner">
				<div class="search_wrap ">
					<dl>
						<dt CL="STD_PLANT">플랜트</dt>
						<dd>
							<input type="text" class="input" id="WERKS" name="WERKS" validate="required" UIInput="S,PLANT" UIFormat="U"/>
						</dd>
					</dl>
					<dl>
						<dt CL="STD_ABN_DT">비가동일자</dt>
						<dd>
							<input type="text" class="input" name="WRK003.ABN_DT" UIInput="B" UIFormat="C M1"/>
						</dd>
					</dl>
					<dl>
						<dt CL="STD_MACH_CD">설비코드</dt>
						<dd>
							<!-- 2023-03-13(월요일) 안상현, 설비코드 RANGE 검색 추가 -->
							<input type="text" class="input" name="WRK003.MACH_CD" UIInput="SR,MACH" UIFormat="U"/>
						</dd>
					</dl>
				</div>
				<div class="btn_tab">
					<input type="button" class="btn_more" value="more" onclick="searchMore()"/>
				</div>
			</div>
		</div>
        <div class="search_next_wrap">
			
			
			
			<div class="content-horizontal-wrap bottom_layout" style="margin-bottom: 10px">
				<div class="content_layout tabs content_first">
					<ul class="tab tab_style02">
<!-- 						<li><a href="#tab1-1"><span>일반</span></a></li> -->
						<li class="btn_zoom_wrap">
							<ul>
								<!-- <li><button class="btn btn_smaller"><span>축소</span></button></li> -->
								<li><button class="btn btn_bigger"><span>확대</span></button></li>
							</ul>
						</li>
					</ul>
					
					<canvas id="chrt1Bar" width="" height=""></canvas>
					
				</div>
				
				
				
				<div class="content_layout tabs content_second">
					<ul class="tab tab_style02">
<!-- 						<li><a href="#tab2-1"><span>일반</span></a></li> -->
<!-- 						<li><a href="#tab2-2"><span>상세</span></a></li> -->
						<li class="btn_zoom_wrap">
							<ul>
								<!-- <li><button class="btn btn_smaller"><span>축소</span></button></li> -->
								<li><button class="btn btn_bigger"><span>확대</span></button></li>
							</ul>
						</li>
					</ul>
					
					<canvas id="chrt2Pie" width="" height=""></canvas>
<!-- 					<canvas id="chrt2Pie" width="30" height="30"></canvas> -->
<!-- 					<canvas id="chrt2Pie" width="10vw" height="10vh"></canvas> -->
<!-- 					<canvas id="chrt2Pie" width="50px" height="50px"></canvas> -->
				</div>
				
				
				
				<div class="content_layout tabs content_third">
					<ul class="tab tab_style02">
<!-- 						<li><a href="#tab3-1"><span>일반</span></a></li> -->
<!-- 						<li><a href="#tab3-2"><span>상세</span></a></li> -->
						<li class="btn_zoom_wrap">
							<ul>
								<!-- <li><button class="btn btn_smaller"><span>축소</span></button></li> -->
								<li><button class="btn btn_bigger"><span>확대</span></button></li>
							</ul>
						</li>
					</ul>
					
					<canvas id="chrt3Line" width="" height=""></canvas>
					
				</div>
			</div>
			
			
			<div class="content_layout tabs top_layout" >
<!-- 			<div class="content_layout tabs"> -->
				<ul class="tab tab_style02">
<!-- 					<li><a href="#tab1-1"><span>일반</span></a></li> -->
					<li><a href="#tab1-1"><span CL="STD_GRD_WRK01"></span></a></li>
					<li class="btn_zoom_wrap">
						<ul>
							<!-- <li><button class="btn btn_smaller"><span>축소</span></button></li> -->
							<li><button class="btn btn_bigger"><span>확대</span></button></li>
						</ul>
					</li>
				</ul>
				<div class="table_box section" id="tab1-1">
					<div class="table_list01">
						<div class="scroll">
							<table class="table_b">
								<tbody id="gridList">
									<tr CGRow="true">
										<td GH="100" GCol="text,PLANT" style="text-align:center;">플랜트</td>
										<td GH="100" GCol="text,ABN_DT" GF='D' style="text-align:center;">생산일자</td>
										<td GH="100" GCol="text,PROC_NM" style="text-align:center;">공정명</td>
										<td GH="100" GCol="text,MACH_CD" style="text-align:center;">설비코드</td>
										<td GH="140" GCol="text,MACH_NM" style="text-align:center;">설비명</td>
										<td GH="120" GCol="text,RUN_STA" style="text-align:center;">운전상태</td>
										<td GH="100" GCol="text,ABN_CD" style="text-align:center;">비가동원인코드</td>
										<td GH="140" GCol="text,ABN_NM">비가동원인명</td>
										<td GH="130 비가동시작일시" GCol="text,START_DATE" style="text-align:center;">시작일시</td>
										<td GH="130 비가동종료일시" GCol="text,END_DATE" style="text-align:center;">종료일시</td>
										<td GH="100" GCol="text,ABN_TM" style="text-align:right;">비가동시간(분)</td>
										<td GH="110" GCol="text,RMK">비고</td>
										<td GH="140" GCol="text,REGDATE" style="text-align:center;"></td>
										<td GH="100" GCol="text,REGNM"></td>
										<td GH="140" GCol="text,UPDDATE" style="text-align:center;"></td>
										<td GH="100" GCol="text,UPDNM"></td>
									</tr>
								</tbody>
							</table>
						</div>
					</div>
					<jsp:include page="/WEB-INF/jsp/common/commonBtnAuth.jsp">
						<jsp:param value="1" name="authCd"/>
						<jsp:param value="1,2,3,9,10" name="showAuthCd"/>
					</jsp:include>
				</div>
			</div>
			
			
			
			
<!-- 			<div class="content_layout tabs"> -->
<!-- 				<ul class="tab tab_style02"> -->
<!-- 					<li><a href="#tab1-1"><span CL="STD_GENERAL"></span></a></li> -->
<!-- 					<li class="btn_zoom_wrap"> -->
<!-- 						<ul> -->
<!-- 							<li><button class="btn btn_smaller"><span>축소</span></button></li> -->
<!-- 							<li><button class="btn btn_bigger"><span>확대</span></button></li> -->
<!-- 						</ul> -->
<!-- 					</li> -->
<!-- 				</ul> -->
<!-- 				<div class="table_box section" id="tab1-1"> -->
<!-- 					<div class="table_list01"> -->
<!-- 						<div class="scroll"> -->
<!-- 							<table class="table_b"> -->
<!-- 								<tbody id="gridList"> -->
<!-- 									<tr CGRow="true"> -->
<!-- 										<td GH="100" GCol="text,PLANT" style="text-align:center;">플랜트</td> -->
<!-- 										<td GH="100" GCol="text,ABN_DT" GF='D' style="text-align:center;">생산일자</td> -->
<!-- 										<td GH="100" GCol="text,PROC_NM" style="text-align:center;">공정명</td> -->
<!-- 										<td GH="140" GCol="text,MACH_NM" style="text-align:center;">설비명</td> -->
<!-- 										<td GH="120" GCol="text,RUN_STA" style="text-align:center;">운전상태</td> -->
<!-- 										<td GH="100" GCol="text,ABN_CD" style="text-align:center;">비가동원인코드</td> -->
<!-- 										<td GH="140" GCol="text,ABN_NM">비가동원인명</td> -->
<!-- 										<td GH="130" GCol="text,START_DATE" style="text-align:center;">시작일시</td> -->
<!-- 										<td GH="130" GCol="text,END_DATE" style="text-align:center;">종료일시</td> -->
<!-- 										<td GH="80" GCol="text,ABN_TM" GF="T" style="text-align:right;">비가동시간(분)</td> -->
<!-- 										<td GH="110" GCol="text,RMK">비고</td> -->
<!-- 										<td GH="140" GCol="text,REGDATE" style="text-align:center;"></td> -->
<!-- 										<td GH="100" GCol="text,REGNM"></td> -->
<!-- 										<td GH="140" GCol="text,UPDDATE" style="text-align:center;"></td> -->
<!-- 										<td GH="100" GCol="text,UPDNM"></td> -->
<!-- 									</tr> -->
<!-- 								</tbody> -->
<!-- 							</table> -->
<!-- 						</div> -->
<!-- 					</div> -->
<%-- 					<jsp:include page="/WEB-INF/jsp/common/commonBtnAuth.jsp"> --%>
<%-- 						<jsp:param value="1" name="authCd"/> --%>
<%-- 						<jsp:param value="1,2,3,9,10" name="showAuthCd"/> --%>
<%-- 					</jsp:include> --%>
<!-- 				</div> -->
<!-- 			</div> -->
			
			
		</div>
	</div>
</div>
<!-- // content -->
<%@ include file="/common/include/webdek/bottom.jsp" %>
</body>
</html>