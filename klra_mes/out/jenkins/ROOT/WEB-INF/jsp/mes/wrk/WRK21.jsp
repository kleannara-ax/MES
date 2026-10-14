<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Grid default</title>
<%@ include file="/common/include/webdek/head.jsp" %>
<link rel="stylesheet" type="text/css" href="/common/theme/webdek/css/demo_layout.css">

<script src="/common/js/chart/chartJs/Chart.min.js"></script>
<!-- <script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/2.4.0/Chart.min.js"></script> -->
<!-- <script src="/common/js/chart.js-3.9.1/package/dist/chart.min.js"></script> -->


<script type="text/javascript">


var flag = false;
var message = '';
var machCd;


// 차트변수
let chrt1Bar, chrt2Pie, chrt3Bar;
let cnfg_chrt1Bar, cnfg_chrt2Pie, cnfg_chrt3Bar;

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
	
	$('#chrt1Bar, #chrt2Pie, #chrt3Bar').hide();
	
	gridList.setGrid({
		id : "gridList",
		url : "/mes/Work/WRK21/json/datalist.data",
		bigdata : false
    });
       
	setChrt1Bar_wrk21();
	setChrt2Pie_wrk21();
	setChrt3Bar_wrk21();
});











function setChrt1Bar_wrk21() {
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
 	            label: '공정별 폐품중량(KG)',
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
 		        text: '공정별 폐품중량(KG)'
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
        
        
        
        hideOrInit_chrt_wrk21('chrt3Bar', cnfg_chrt3Bar, chrt3Bar);
        
// 		$('#chrt2Pie').show();
// 		let labelArr = ["J-평량교체", "J-지합불량", "J-초출폐품", "M-뭉치유형", "M-지관파손", "M-모서리찍힘"];
//         loadChrtData_wrk21(cnfg_chrt2Pie, chrt2Pie, labelArr, [2478,5267,734,784,433,256]);
        
        G_chrt2DataObj.procCd = G_chrt1DataObj.procCdArr[clickedElIdx];
		setChrtData_wrk21('loadChrt2Pie', G_chrt2DataObj.procCd);
	}
	
}







function setChrt2Pie_wrk21() {
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
            //maintainAspectRatio : false,
            responsive: true,
            // legend: false,
            animation: false,
            
             maintainAspectRatio: true,
            // pieceLabel: {
            //    mode:"label",
            //    position:"outside",
            //    fontSize: 11,
            //    fontStyle: 'bold'
            // }
	        title: {
	        display: true,
	        text: '유형별 폐품비율(%)'
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
        
//         $('#chrt3Bar').show();
//         loadChrtData_wrk21(cnfg_chrt3Bar, chrt3Bar, ['전월', '당월'], [673, 250]);
		
		let dispoCd = G_chrt2DataObj.dispoCdArr[clickedElIdx];
		setChrtData_wrk21('loadChrt3Bar', G_chrt2DataObj.procCd, dispoCd);
	}
	
}







function setChrt3Bar_wrk21() {
	const ctx = document.getElementById('chrt3Bar').getContext('2d');
	
	cnfg_chrt3Bar = {
	    type: 'bar',
	    data: {
// 	        labels: ['전월', '당월'],
	        labels: [],
	        datasets: [{
	            label: '',
 	            // labels: [],
 	            label: '폐품 전월 대비 당월 현황',
 	            // data: [12, 19, 3, 5, 2, 3],
	            data: [673, 250],
// 	            data: [],
	            backgroundColor: G_chrtBgColor,
// 	            backgroundColor: [
//  	                // 'rgba(255, 99, 132, 0.2)',
//  	                // 'rgba(54, 162, 235, 0.2)',
//  	                // 'rgba(255, 206, 86, 0.2)',
//  	                // 'rgba(75, 192, 192, 0.2)',
// 	                'rgba(153, 102, 255, 0.2)',
// 	                'rgba(255, 159, 64, 0.2)'
// 	            ],
// 	            borderColor: [
//  	                // 'rgba(255, 99, 132, 1)',
//  	                // 'rgba(54, 162, 235, 1)',
//  	                // 'rgba(255, 206, 86, 1)',
//  	                // 'rgba(75, 192, 192, 1)',
// 	                'rgba(153, 102, 255, 1)',
// 	                'rgba(255, 159, 64, 1)'
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
 		        text: '폐품 전월 대비 당월 현황'
 		      }
	    }
	};
	
	chrt3Bar = new Chart(ctx, cnfg_chrt3Bar);
	
	
	document.getElementById("chrt3Bar").onclick = function(evt) {
		var activePoints = chrt3Bar.getElementsAtEvent(evt);
		
// 		console.log('activePoints =>'+activePoints[0]["_index"] );
// 		console.log('activePoints =>'+activePoints.toString() );
// 		console.log('activePoints =>'+JSON.stringify(activePoints) );
		
	    if (!activePoints || activePoints.length <= 0) return;
	    	
        var clickedElementindex = activePoints[0]["_index"];
        
        var label = chrt3Bar.data.labels[clickedElementindex];
        var value = chrt3Bar.data.datasets[0].data[clickedElementindex];
        
//         console.log('label =>'+label );
//         console.log('value =>'+value );
	}
	
}








/*

function gridListEventRowDblclick(gridId, rowNum, colName) {
	if (gridId != 'gridList') return;
	
	// if (!validate.check("searchArea")) return;
	
// 	var param = inputList.setRangeParam("searchArea");
// 	param.map.WERKS = gridList.getRowData('gridList', gridList.getFocusRowNum('gridList') ).map.WERKS;
// 	param.map.MACH_CD = gridList.getRowData('gridList', gridList.getFocusRowNum('gridList') ).map.MACH_CD;
	
// 	param.put("P_TYPE","SUB_LIST1");
// 	gridList.gridList({
// 		id : "gridListSub1",
// 		param : param
// 	});
	
	
	tstFn();
}




function tstFn() {
	
	let labelArr = ['점보롤', '밀롤', '재단', '포장'];
	let dataArr = [120, 100, 300, 430];
	loadChrtData_wrk21(cnfg_chrt1Bar, chrt1Bar, labelArr, dataArr);
	
// 	loadChrtData_wrk21(cnfg_chrt1Bar, chrt1Bar, ['밀롤','수재단','슬리터','제지 초지'], [40593.502,762.156,665.6,13707.36]);
}



function tstFn_old() {
// 	alert('hideOrInit_chrt_wrk21');
	
// 	$('#chrt1Bar').hide();
// 	cnfg_chrt1Bar.data.datasets = [];
// 	chrt1Bar.update();
	
	hideOrInit_chrt_wrk21('chrt2Pie', cnfg_chrt2Pie, chrt2Pie);
	hideOrInit_chrt_wrk21('chrt3Bar', cnfg_chrt3Bar, chrt3Bar);
	
	
// 	console.log('cnfg.data => '+JSON.stringify(cnfg.data));
	
	$('#chrt1Bar').show();
// 	loadChrtData_wrk21(cnfg_chrt1Bar, chrt1Bar, [120, 100, 300, 430]);
// 	loadChrtData_wrk21(cnfg_chrt1Bar, chrt1Bar, [120.34, 100, 300.098, 430]);
	
// 	alert('let으로 변경');
	let labelArr = ['점보롤', '밀롤', '재단', '포장'];
	let dataArr = [120, 100, 300, 430];
	loadChrtData_wrk21(cnfg_chrt1Bar, chrt1Bar, labelArr, dataArr);
// 	loadChrtData_wrk21(cnfg_chrt1Bar, chrt1Bar, ['점보롤', '밀롤', '재단', '포장'], [120, 100, 300, 430]);
// 	cnfg_chrt1Bar.data.labels = ['점보롤', '밀롤', '재단', '포장'];
// 	cnfg_chrt1Bar.data.datasets[0].data = [120, 100, 300, 430];
// 	chrt1Bar.update();
	
// 	loadChrtData_wrk21(cnfg_chrt2Pie, chrt2Pie, [2478,5267,734,784,433,256]);
// 	loadChrtData_wrk21(cnfg_chrt3Bar, chrt3Bar, [673, 250]);
}



*/













function setChrtData_wrk21(flg, chrtPrm, chrtPrm2) {
// 	let succssFn = '';
// 	if (flg == 'loadChrt1Bar') succssFn = '';
// 	else if (flg == '') succssFn = '';
// 	else if (flg == '') succssFn = '';
	let param = getSrchPrm_wrk21();
	param.put("P_CHRT_TYPE", flg);
	if (chrtPrm) param.put("CHRT_PRM", chrtPrm);
	if (chrtPrm2) param.put("CHRT_PRM2", chrtPrm2);
	
	netUtil.send({
	   url : "/mes/Work/WRK21/json/datalist.data",
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
		dataArr.push(itm.WGT);
	});
// 	console.log('labelArr => '+labelArr );
// 	console.log('dataArr => '+dataArr );
// 	G_chrt1DataObj = {procCdArr: procCdArr, labelArr: labelArr, dataArr: dataArr};
	G_chrt1DataObj = {procCdArr: procCdArr};
	$('#chrt1Bar').show();
	loadChrtData_wrk21(cnfg_chrt1Bar, chrt1Bar, labelArr, dataArr);
}


function loadChrt2Pie(json, status) {
	if (!json || !json.data || json.data.length <= 0) return;
	
	let dispoCdArr = [], labelArr = [], dataArr = [];
	$.each(json.data, function(idx, itm) {
		dispoCdArr.push(itm.DISPO_CD);
		labelArr.push(itm.DISPO_NM);
		dataArr.push(itm.WGT);
	});
	G_chrt2DataObj.dispoCdArr = dispoCdArr;
	$('#chrt2Pie').show();
	loadChrtData_wrk21(cnfg_chrt2Pie, chrt2Pie, labelArr, dataArr);
}


function loadChrt3Bar(json, status) {
	if (!json || !json.data || json.data.length <= 0) return;
	
	let dataArr = [];
	dataArr.push(json.data[0].PRV_MNTH);
	dataArr.push(json.data[0].THIS_MNTH);
	
	$('#chrt3Bar').show();
	loadChrtData_wrk21(cnfg_chrt3Bar, chrt3Bar, ['전월', '당월'], dataArr);
}




function loadChrtData_wrk21(cnfg, chrt, labelArr, dataArr) {
	cnfg.data.labels = labelArr;
	cnfg.data.datasets[0].data = dataArr;
	chrt.update();
}
// function loadChrtData_wrk21(cnfg, chrt, arrData) {
// 	cnfg.data.datasets[0].data = arrData;
// 	chrt.update();
// }





function hideOrInit_chrt_wrk21(chrtSlctr, cnfg, chrt) {
	$('#'+chrtSlctr).hide();
	cnfg.data.datasets[0].data = [];
	chrt.update();
}




function getSrchPrm_wrk21_ORG() {
	param = inputList.setRangeParam("searchArea");
	
	// 2023-03-13(월요일) 안상현, RANGE 검색 추가
	const range = inputList.setRangeParam("searchArea")
	const range_data_param = range.get("RANGE_DATA_PARAM")
	const prfm_dt = range_data_param.get("A.PRFM_DT_Range")
	const date = prfm_dt.split("↓")
	const SDate = date[1]
	const EDate = date[2]
	
	param.put("P_TYPE", "LIST")
	param.put("SDATE", SDate)
	param.put("EDATE", EDate)
	param.put("WERKS", $("#WERKS").val().toUpperCase()) // 플랜트 코드
	//param.put("WERKS", $("#WERKS")) // 플랜트 코드
	
	return param;
}

function getSrchPrm_wrk21() {

	param = inputList.setRangeParam("searchArea");
	param.put("P_TYPE", "LIST")

	return param;		
}





// 조회
function searchList() {
	if (!validate.check("searchArea")) return;
// 	var param = inputList.setRangeParam("searchArea");
// 	param.put("P_TYPE", "LIST");
		
	gridList.gridList({
		id : "gridList",
		param : getSrchPrm_wrk21()
	});
	
	hideOrInit_chrt_wrk21('chrt1Bar', cnfg_chrt1Bar, chrt1Bar);
	hideOrInit_chrt_wrk21('chrt2Pie', cnfg_chrt2Pie, chrt2Pie);
	hideOrInit_chrt_wrk21('chrt3Bar', cnfg_chrt3Bar, chrt3Bar);
	
	setChrtData_wrk21('loadChrt1Bar');
}



	//20220722 여한진 폐품취소 로직 추가
	//폐품취소
	function DispoCancle(){
		var json = netUtil.sendData({
    		module : 'mes',
    		command : 'SYSTEMCHECK',
    		sendType : 'map'
    	});
    	
    	if(json.data.USE_YN == 'Y'){
    		alert('시스템 점검 중입니다. 1 ~ 5분 동안 잠시만 기다려 주세요.');
    		return;
    	}
		
		var list = gridList.getSelectData("gridList");
		
		if(list.length == 0){
			alert("취소하려는 작업지시를 선택하세요.");
			return;
		}
		
		for(var i = 0; i < list.length; i++){
			if(i >= 1){
				if(list[i - 1].get("MACH_CD") != list[i].get("MACH_CD")){
					alert("같은 설비끼리 취소가능합니다.");
					return;
				}
			}
			machCd = list[i].get("MACH_CD").substr(0, 3);
		}
		
		
		
		if(!commonUtil.msgConfirm("폐품취소하시겠습니까?")){
			return;
		}
		
		var param = new DataMap();
		
		param.put("P_TYPE", "DELETE");
		param.put("list", list);
		
		netUtil.send({
			url : "/mes/Work/WRK21/json/datalist.data",
			param : param,
			successFunction : "savesuccessCallBack"
		});
	}
	
	function savesuccessCallBack(json){
		if(json){
			if(json.P_SUCCESS == 'Y'){
				var param = new DataMap();
				//폐품실적취소
				param.put("IFID", "MES_IF_144");
				param.put("DOC_NO", json.DOC_NO1);
				
				debugger
				
				var json2 = netUtil.sendData({
					url : "/mes/erpif/json/sendIF.data",
   	            	param : param
				});
				
				if(json2){
					if(json2.data == 'SUCCESS'){
						DispoCancle2(json);
					}else{
						message = "(SAP 폐품실적취소) " + json2.data + '\n';
					}
				}
				
			}else{
				alert(json.ERR_MSG);
				return;
			}
			if(message != ''){
				alert(message);
				message = '';
			}else{
				alert("폐품취소되었습니다.");
			}
			searchList();
		}
	}
	//실적취소
	function DispoCancle2(json){
		if(json.DOC_NO2 != ''){
			var param = new DataMap();
			
			param.put("IFID", "MES_IF_129");
			param.put("DOC_NO", json.DOC_NO2);
			
			var json3 = netUtil.sendData({
				url : "/mes/erpif/json/sendIF.data",
	           	param : param
			});
			
			if(json3){
				if(json3.data != 'SUCCESS'){
					message = "(SAP 실적취소) " + json3.data + '\n';
				}
			}
		}
	}
	
	// 버튼 클릭(조회)
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
		}else{
			//폐품취소
			DispoCancle();
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
					<input type="button" id="button-0-3" CB="DISPO_CLE DELETE 폐품취소" />
				</div>
			</div>
			<div class="search_inner">
				<div class="search_wrap ">
					
					<dl>
						<dt CL="STD_WERKS">플랜트</dt>
						<dd>
							<input type="text" class="input" id="WERKS" name="WERKS" UIInput="S,PLANT" UIFormat="U" validate="required"/>
						</dd>
					</dl>
				  	<dl>
						<dt CL="STD_PRFM_DT">실적일자</dt>
						<dd>
							<input type="text" id="PRFM_DT" name="A.PRFM_DT" UIInput="B" UIFORMAT="C M1"/>
						</dd>
					</dl>
					<dl>
						<dt CL="STD_PROC_CD">공정코드</dt>
						<dd>
							<!-- 2023-03-13(월요일) 안상현, 공정코드 RANGE 검색 추가 -->
							<input type="text" class="input" id="PROC_CD" name="MAS012.PROC_CD" UIInput="SR,OP" UIFormat="U"/>
						</dd>
					</dl>
					<dl>
						<dt CL="STD_MACH_CD">설비코드</dt>
						<dd>
							<!-- 2023-03-13(월요일) 안상현, 설비코드 RANGE 검색 추가 -->
							<input type="text" class="input" id="MACH_CD" name="A.MACH_CD" UIInput="SR,MACH" UIFormat="U"/>
						</dd>
					</dl>
				</div>
				<div class="btn_tab">
					<input type="button" class="btn_more" value="more" onclick="searchMore()"/>
				</div>
			</div>
		</div>
        <div class="search_next_wrap">
			
			
			
			
<!-- 			<div class="content-horizontal-wrap bottom_layout"> -->
<!-- 			<div class="content-horizontal-wrap bottom_layout" height="400"> -->
<!-- 			<div class="content-horizontal-wrap bottom_layout" style="padding-bottom: 50px"> -->
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
					
					<canvas id="chrt3Bar" width="" height=""></canvas>
					
				</div>
			</div>
			
			
			
			
			
			
			
<!-- 			<div class="content_layout tabs"> -->
			<div class="content_layout tabs top_layout" >
				<ul class="tab tab_style02">
					<li><a href="#tab1-1"><span CL="STD_GRD_WRK21">일반</span></a></li>
					<li class="btn_zoom_wrap">
						<ul>
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
										<td GH="40" GCol="rownum"></td>
										<td GH="40" GCol="rowCheck"></td>
										<td GH="100" GCol="text,WERKS" style="text-align: center;">플랜트</td>
										<td GH="150" GCol="text,PRFM_DT" GF="D" style="text-align: center;">실적일자</td>
										<td GH="0" GCol="text,PROC_CD">공정코드</td>
										<td GH="100" GCol="text,PROC_NM">공정명</td>
										<td GH="150" GCol="text,MACH_CD" style="text-align: center;">설비코드</td>
										<td GH="150" GCol="text,MACH_NM">설비명</td>
										<td GH="100" GCol="text,MACHINE" style="text-align: center;">생산호기</td>
										<td GH="150" GCol="text,ORDER_NO">오더번호</td>
										<td GH="150" GCol="text,WRK_ORDR_NO">작업지시번호</td>
										<td GH="80" GCol="text,WRK_ORDR_SEQNO" GF="N 10">작업지시순번</td>
										<!-- 20220723 여한진 컬럼 추가 및 수정 -->
										<td GH="0" GCol="text,LOT_NO">LOT번호</td>
										<td GH="0" GCol="text,IND_BCD">개별바코드</td>
										<td GH="140" GCol="text,MATNR_M" style="text-align:center;">투입자재코드</td>
										<td GH="0" GCol="text,IND_BCD_M">투입자재 개별바코드</td>
										<td GH="100" GCol="text,LOT_NO_M">투입자재 LOT번호</td>

										<!-- <td GH="100" GCol="text,PRFM_QTY" GF="N 10,3">실적량</td>
										<td GH="100" GCol="text,PRFM_UNIT">실적단위</td> -->
										
<!-- 										<td GH="150" GCol="text,DISPO_QTY" GF="N 10,3">폐품량</td> -->
										<td GH="150" GCol="text,DISPO_CAPA_QTY" GF="N 10,3">폐품량(수량)</td>
										<td GH="100" GCol="text,DISPO_EAUNIT">폐품수량단위</td>
										
										<td GH="150" GCol="text,DISPO_CAPA_WGT" GF="N 10,3">폐품량(중량)</td>
										<td GH="100" GCol="text,DISPO_WUNIT">폐품중량단위</td>
										
										<td GH="0" GCol="text,DISPO_CD" style="text-align: center;">폐품코드</td>
										<td GH="100" GCol="text,DISPO_NM">폐퓸명</td>
										<td GH="100" GCol="text,DISPO_DIV_NM" style="text-align: center;">폐퓸유형</td>
										<td GH="100" GCol="text,REGNM">등록자(명)</td>
										<td GH="100" GCol="text,WRK_SHIFT" style="text-align: center;">작업조</td>
										<td GH="100" GCol="text,WRK_CLASS" style="text-align: center;">작업반</td>
										<td GH="150" GCol="text,REGDATE" style="text-align: center;">등록일시</td>
									</tr>
								</tbody>
							</table>
						</div>
					</div>
					<jsp:include page="/WEB-INF/jsp/common/commonBtnAuth.jsp">
						<jsp:param name="authCd" value="1" />
						<jsp:param name="showAuthCd" value="1,2,3,7,9,10" />
					</jsp:include>
				</div>
			</div>
			
			
			
			
			
			
		</div>
	</div>
</div>
<!-- // content -->
<%@ include file="/common/include/webdek/bottom.jsp" %>
</body>
</html>