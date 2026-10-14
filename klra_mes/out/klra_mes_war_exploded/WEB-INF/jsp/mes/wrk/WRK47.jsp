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
<script type="text/javascript">
	//차트변수
	let chrt1Bar, chrt2HBar, chrt3Line;
	let cnfg_chrt1Bar, cnfg_chrt2HBar, cnfg_chrt3Line;
	let G_chrtBgColor = [
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
	];
	let G_chrt1DataObj = {}, G_chrt2DataObj = {}, G_chrt3DataObj = {};

	$(document).ready(function() {
		
		$('#chrt1Bar, #chrt2HBar, #chrt3Line').hide();
		
		gridList.setGrid({  // PS 실적
	    	id : "gridList_A",
	    	url : "/mes/Work/WRK47/json/datalist.data",
	    	bigdata : false,
	    });
		
		gridList.setGrid({  // HL 실적
			id : "gridList_B",
	    	url : "/mes/Work/WRK47/json/datalist.data",
	    	bigdata : false,
	    });
		
		setChrt1Bar_wrk47();
		setChrt2HBar_wrk47();
		setChrt3Line_wrk47();
	});

	function setChrt1Bar_wrk47() {
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
	 	            label: '공정별 실적현황(KG)',
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
	 		        text: '공정별 실적현황(KG)'
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
	        
	        
	        
	        hideOrInit_chrt_wrk47('chrt3Line', cnfg_chrt3Line, chrt3Line);
	        
	// 		$('#chrt2HBar').show();
	// 		let labelArr = ["J-평량교체", "J-지합불량", "J-초출폐품", "M-뭉치유형", "M-지관파손", "M-모서리찍힘"];
	//         loadChrtData_wrk47(cnfg_chrt2HBar, chrt2HBar, labelArr, [2478,5267,734,784,433,256]);
	        
	        G_chrt2DataObj.procCd = G_chrt1DataObj.procCdArr[clickedElIdx];
			setChrtData_wrk47('loadChrt2HBar', G_chrt2DataObj.procCd);
		}
		
	}

	function setChrt2HBar_wrk47() {
		const ctx = document.getElementById('chrt2HBar').getContext('2d');
		
		cnfg_chrt2HBar = {
			    type: 'horizontalBar',
			    data: {
		 	        // labels: ['Red', 'Blue', 'Yellow', 'Green', 'Purple', 'Orange'],
	//	 	        labels: ['점보롤', '밀롤', '재단', '포장'],
			        labels: [],
			        datasets: [{
	//	 	            label: '',
	//	  	            labels: ['점보롤', '밀롤', '재단', '포장'],
		 	            label: '설비별 실적현황',
		 	            // data: [12, 19, 3, 5, 2, 3],
			            // data: [120, 100, 300, 430],
			            data: [],
			            backgroundColor: G_chrtBgColor,
	//	 	            backgroundColor: [
	//	 	                'rgba(255, 99, 132, 0.2)',
	//	 	                'rgba(54, 162, 235, 0.2)',
	//	 	                'rgba(255, 206, 86, 0.2)',
	//	 	                'rgba(75, 192, 192, 0.2)'
	//	  	                // 'rgba(153, 102, 255, 0.2)',
	//	  	                // 'rgba(255, 159, 64, 0.2)'
	//	 	            ],
	//	 	            borderColor: [
	//	 	                'rgba(255, 99, 132, 1)',
	//	 	                'rgba(54, 162, 235, 1)',
	//	 	                'rgba(255, 206, 86, 1)',
	//	 	                'rgba(75, 192, 192, 1)'
	//	  	                // 'rgba(153, 102, 255, 1)',
	//	  	                // 'rgba(255, 159, 64, 1)'
	//	 	            ],
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
				        xAxes: [{// y축 콤마
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
		 		        text: '설비별 실적현황(KG)'
		 		    }
			    }
			};
		
		chrt2HBar = new Chart(ctx, cnfg_chrt2HBar);
		
		
		
		document.getElementById("chrt2HBar").onclick = function(evt) {
			
			var activePoints = chrt2HBar.getElementsAtEvent(evt);
			
	// 		console.log('activePoints =>'+activePoints[0]["_index"] );
	// 		console.log('activePoints =>'+activePoints.toString() );
	// 		console.log('activePoints =>'+JSON.stringify(activePoints) );
			
		    if (!activePoints || activePoints.length <= 0) return;
		    
	        var clickedElIdx = activePoints[0]["_index"];
	        
	        var label = chrt2HBar.data.labels[clickedElIdx];
	        var value = chrt2HBar.data.datasets[0].data[clickedElIdx];
	        
	//         console.log('label =>'+label );
	//         console.log('value =>'+value );
	        
	//         $('#chrt3Line').show();
	//         loadChrtData_wrk47(cnfg_chrt3Line, chrt3Line, ['전월', '당월'], [673, 250]);
			
			let abnCd = G_chrt2DataObj.machCdArr[clickedElIdx];
			setChrtData_wrk47('loadChrt3Line', G_chrt2DataObj.procCd, abnCd);
		}
		
	}

	function setChrt3Line_wrk47() {
		const ctx = document.getElementById('chrt3Line').getContext('2d');
		
		cnfg_chrt3Line = {
		    type: 'line',
		    data: {
	// 	        labels: ['1', '2', '3', '4', '5', '6', '7'],
	// 	        labels: ['7/29/2022', '7/30/2022', '7/31/2022', '8/1/2022', '8/2/2022', '8/3/2022', '8/4/2022'],
		        labels: [],
		        datasets: [{
		            label: '기간별 실적현황',
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
	 		        text: '기간별 실적현황(KG)'
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

	function setChrtData_wrk47(flg, chrtPrm, chrtPrm2) {
	// 	let succssFn = '';
	// 	if (flg == 'loadChrt1Bar') succssFn = '';
	// 	else if (flg == '') succssFn = '';
	// 	else if (flg == '') succssFn = '';
		let param = getSrchPrm_wrk47();
		param.put("P_CHRT_TYPE", flg);
		if (chrtPrm) param.put("CHRT_PRM", chrtPrm);
		if (chrtPrm2) param.put("CHRT_PRM2", chrtPrm2);
		netUtil.send({
		   url : "/mes/Work/WRK47/json/datalist.data",
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
			dataArr.push(itm.WGT_SUM);
		});
	// 	console.log('labelArr => '+labelArr );
	// 	console.log('dataArr => '+dataArr );
	// 	G_chrt1DataObj = {procCdArr: procCdArr, labelArr: labelArr, dataArr: dataArr};
		G_chrt1DataObj = {procCdArr: procCdArr};
		$('#chrt1Bar').show();
		loadChrtData_wrk47(cnfg_chrt1Bar, chrt1Bar, labelArr, dataArr);
	}

	function loadChrt2HBar(json, status) {
		if (!json || !json.data || json.data.length <= 0) return;
		
		let machCdArr = [], labelArr = [], dataArr = [];
		$.each(json.data, function(idx, itm) {
			machCdArr.push(itm.MACH_CD);
			labelArr.push(itm.MACH_NM);
			dataArr.push(itm.WGT_SUM);
		});
		G_chrt2DataObj.machCdArr = machCdArr;
		$('#chrt2HBar').show();
		loadChrtData_wrk47(cnfg_chrt2HBar, chrt2HBar, labelArr, dataArr);
	}

	function loadChrt3Line(json, status) {
		if (!json || !json.data || json.data.length <= 0) return;
	// 	let dataArr = [];
	// 	dataArr.push(json.data[0].PRV_MNTH);
	// 	dataArr.push(json.data[0].THIS_MNTH);
		
		let labelArr = [], dataArr = [];
		$.each(json.data, function(idx, itm) {
			labelArr.push(itm.PRFM_DT);
			dataArr.push(itm.WGT_SUM);
		});
		
		$('#chrt3Line').show();
		loadChrtData_wrk47(cnfg_chrt3Line, chrt3Line, labelArr, dataArr);
	}

	function loadChrtData_wrk47(cnfg, chrt, labelArr, dataArr) {
		cnfg.data.labels = labelArr;
		cnfg.data.datasets[0].data = dataArr;
		chrt.update();
	}

	function hideOrInit_chrt_wrk47(chrtSlctr, cnfg, chrt) {
		$('#'+chrtSlctr).hide();
		cnfg.data.datasets[0].data = [];
		chrt.update();
	}

	function hideOrInit_chrtAll_wrk47() {
		hideOrInit_chrt_wrk47('chrt1Bar', cnfg_chrt1Bar, chrt1Bar);
		hideOrInit_chrt_wrk47('chrt2HBar', cnfg_chrt2HBar, chrt2HBar);
		hideOrInit_chrt_wrk47('chrt3Line', cnfg_chrt3Line, chrt3Line);
	}

	function getSrchPrm_wrk47() {
		param = inputList.setRangeParam("searchArea");
		
		// 2023-03-13(월요일) 안상현, RANGE 검색 추가
		/* const range_data_param = param.get("RANGE_DATA_PARAM")
		const prfm_dt = range_data_param.get("PRFM_DT_Range")
		const date = prfm_dt.split("↓")
		const SDate = date[1]
		const EDate = date[2]
		param.put("SDATE", SDate)
		param.put("EDATE", EDate)
		param.put("WERKS", $("#WERKS").val()) // 플랜트 코드
		param.put("MACHINE", $("#MACHINE").val()) // 생산호기*/
		
		param.put("P_TYPE", gridId_G === "gridList_A"? 'LIST_A' : 'LIST_B');
		return param;
	}

	let gridId_G = "gridList_A";  // PS 실적
	
	const tabClick = (gridId) => {  // PS 실적, HL 실적 조회 제어
		hideOrInit_chrtAll_wrk47();
		gridId_G = gridId;
	}

	//20221019 여한진 화장지 같은 경우 생산호기가 합지랑 가공이 구분이 가지 않아서 공정코드로 구분하기 위해
	function procCdcheck(){
		if($('#WERKS').val().toUpperCase() == 'P200'){
			if ($('#PROC_CD').val() == '') {
				$('#PROC_CD').focus();
				return alert('공정코드를 선택 및 입력하세요.');	
			}
		} 
	}
	
	// function searchList(gridId, listFlg) {  // 조회
	function searchList() {  // 조회
		
		if (!validate.check("searchArea")) return;
		
		if($('#WERKS').val().toUpperCase() == 'P100' && gridId_G != 'gridList_A')	return alert('PS(제지)팀은 PS실적 탭에서 조회하세요.');
		if($('#WERKS').val().toUpperCase() != 'P100' && gridId_G == 'gridList_A')	return alert('HL(생활용품)팀은 HL실적 탭에서 조회하세요.');
	
		gridList.gridList({
			id : gridId_G,
			param : getSrchPrm_wrk47()
		});
		
		hideOrInit_chrtAll_wrk47();
		setChrtData_wrk47('loadChrt1Bar');
	}
	
	function commonBtnClick(btnName) {   // 버튼 클릭
		if (btnName == "Search") {
			
			searchList();
			
 			var param = new DataMap();
	        param.put("PROGID", "<%= menuId%>");
 	        param.put("LGTYPE", "SEARCH");
 	        var json = netUtil.sendData({
 	            url: "/mes/system/json/saveLog.data",
 	            param : param
 	        });
			
// 	        if(gridId_G === "gridList_A") searchList("gridList_A","LIST_A");
// 	        else searchList("gridList_B","LIST_B");
		}
	}
	
	function reloadCombo(){
		$comboObj = $("#MACHINE");
		inputList.reloadCombo($comboObj, configData.INPUT_COMBO, "Produce,MACHINE");
	}

	function comboEventDataBindeBefore(comboAtt){
		if(comboAtt == "Produce,MACHINE"){
			var param = new DataMap();
			
			param.put("WERKS", $("#WERKS").val().toUpperCase());
		}
		return param;
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
							<input type="text" class="input" id="WERKS" name="WERKS" UIInput="S,PLANT" UIFormat="U" validate="required" onkeyup="reloadCombo()"/>
						</dd>
					</dl>
					
					<dl>
						<dt CL="STD_MATNR">자재코드</dt>
						<dd>
							<!-- 2023-03-13(월요일) 안상현, 자재코드 RANGE 검색 추가 -->
							<input type="text" class="input" name="WRK002.MATNR" id="MATNR" UIInput="SR,MATKY" UIFormat="U"/>
						</dd>
					</dl>
					
					<dl>
						<dt CL="STD_PRFM_DT">실적일자</dt>
						<dd>
							<input type="text" id="PRFM_DT" name="PRFM_DT" UIInput="B" UIFORMAT="C M1"/>
						</dd>
					</dl>
					<dl>
						<dt CL="STD_PROC_CD">공정</dt>
						<dd>
							<!-- 2023-03-13(월요일) 안상현, 공정코드 RANGE 검색 추가 -->
							<input type="text" id="PROC_CD" name="MAS013.PROC_CD" UIInput="SR,OP" UIFormat="U"/>
						</dd>
					</dl>
					<dl>
						<dt CL="STD_MACHINE">생산호기</dt>
						<dd>
							<select class="input" id="MACHINE" name="MACHINE" Combo="Produce,MACHINE" onclick="procCdcheck();">
								<option value="">All</option>
							</select>
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
					
					<canvas id="chrt2HBar" width="" height=""></canvas>
<!-- 					<canvas id="chrt2HBar" width="30" height="30"></canvas> -->
<!-- 					<canvas id="chrt2HBar" width="10vw" height="10vh"></canvas> -->
<!-- 					<canvas id="chrt2HBar" width="50px" height="50px"></canvas> -->
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
					<li>
						<a href="#tab1-1" onclick="tabClick('gridList_A')">
							<span CL="STD_GRD_WRK47_1">PS 실적</span>
						</a>
					</li>
					<li>
						<a href="#tab1-2" onclick="tabClick('gridList_B')">
							<span CL="STD_GRD_WRK47_2">HL 실적</span>
						</a>
					</li>
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
								<tbody id="gridList_A">
									<tr CGRow="true">
										<td GH="40" GCol="rownum"></td>
										<td GH="70" GCol="text,PLANT" style="text-align: center;">플랜트</td>
										<td GH="90" GCol="text,PRFM_DT" GF="D" style="text-align:center;">실적일자</td>
										<td GH="100" GCol="text,PROC_NM">공정명</td>
										<td GH="100" GCol="text,MACH_CD" style="text-align: center;">설비코드</td>
										<td GH="130" GCol="text,MACH_NM">설비명</td>
										<td GH="100" GCol="text,ORDER_NO" style="text-align: center;">오더번호</td>
										<td GH="130" GCol="text,WRK_ORDR_NO" style="text-align: center;">작업지시번호</td>
										<td GH="80" GCol="text,WRK_ORDR_SEQNO" style="text-align: center;">작업지시순번</td>
										<td GH="90" GCol="text,LOT_NO" style="text-align: center;">LOT번호</td> 
										<td GH="130" GCol="text,IND_BCD" style="text-align: center;">개별바코드</td> 
										<td GH="140" GCol="text,MATNR" style="text-align: center;"></td> 
										<td GH="320" GCol="text,MATNR_NM"></td>
										<td GH='100' GCol='text,PRFM_QTY' GF='N 13,3'>실적수량</td> 
										<td GH="80 실적단위" GCol="text,UNIT" style="text-align: center;"></td>
										<td GH="100 연수" GCol="text,PCNT" GF="N 10,3">연수</td>
										<td GH="80" GCol="text,RUNIT" style="text-align: center;">연수단위</td>
										<td GH="100" GCol="text,SCNT" style="text-align: center;">속수</td>    
										<td GH="100" GCol="text,MCNT" style="text-align: center;"> 매</td>     
										<td GH="100" GCol="text,WIDTH" style="text-align: center;">실지폭</td>   
										<td GH="100" GCol="text,ROLLCNT" GF="N 6">권치수</td>
										<td GH="80" GCol="text,ROLLUNIT" style="text-align:center;">권치수단위</td>
										<td GH="100" GCol="text,WGT" GF="N 10,3">실적중량</td>
										<td GH="80" GCol="text,WUNIT" style="text-align:center;">중량단위</td>
										<td GH="100" GCol="text,MACHINE" style="text-align: center;">생산호기</td>
										<td GH="130" GCol="text,PRD_STR_DATE" style="text-align: center;">시작시간</td>
										<td GH="130" GCol="text,PRD_END_DATE" style="text-align: center;">종료시간</td>
										<td GH="100" GCol="text,PRD_DT" GF="D" style="text-align: center;">생산일자</td>
										<td GH="100" GCol="text,REGNM" style="text-align: center;">등록자명</td> 
										<td GH="100" GCol="text,WRK_SHIFT" style="text-align: center;">작업조</td>
										<td GH="100" GCol="text,WRK_CLASS" style="text-align: center;">반</td>
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
				<div class="table_box section" id="tab1-2">
					<div class="table_list01">
						<div class="scroll">
							<table class="table_b">
								<tbody id="gridList_B">
									<tr CGRow="true">
										<td GH="40" GCol="rownum"></td>
										<td GH="70" GCol="text,PLANT" style="text-align: center;">플랜트</td>
										<td GH="90" GCol="text,PRFM_DT" GF="D" style="text-align:center;">실적일자</td>
										<td GH="100" GCol="text,PROC_NM">공정명</td>
										<td GH="100" GCol="text,MACH_CD" style="text-align: center;">설비코드</td>
										<td GH="130" GCol="text,MACH_NM">설비명</td>
										<td GH="100" GCol="text,ORDER_NO" style="text-align: center;">오더번호</td>
										<td GH="130" GCol="text,WRK_ORDR_NO" style="text-align: center;">작업지시번호</td>
										<td GH="80" GCol="text,WRK_ORDR_SEQNO" style="text-align: center;">작업지시순번</td>
										<td GH="90" GCol="text,LOT_NO" style="text-align: center;">LOT번호</td> 
										<td GH="130" GCol="text,IND_BCD" style="text-align: center;">개별바코드</td> 
										<td GH="140" GCol="text,MATNR" style="text-align: center;"></td> 
										<td GH="320" GCol="text,MATNR_NM" ></td> 
										<td GH="80" GCol="text,UNIT" style="text-align: center;">단위</td>
										<td GH="80" GCol="text,PLT_QTY" GF="N 10,1">PLT</td>    
										<td GH="80" GCol="text,BOX_QTY" GF="N 10">BOX</td>
										<td GH="80" GCol="text,BAG_QTY" GF="N 10">BAG</td>     
										<td GH="80" GCol="text,EA_QTY" GF="N 10">EA</td>   
										<td GH="90" GCol="text,WGT" GF="N 10,3">실적중량</td>
										<td GH="80" GCol="text,ROLLCNT" GF="N 6" style="text-align: right;">권치수</td>
										<td GH="80" GCol="text,WIDTH" GF="N 10,3">실지폭</td>   
										<td GH="130" GCol="text,PRD_STR_DATE" style="text-align: center;">시작시간</td>
										<td GH="130" GCol="text,PRD_END_DATE" style="text-align: center;">종료시간</td>
										<td GH="90" GCol="text,PRD_DT" GF="D" style="text-align: center;">생산일자</td>
										<td GH="100" GCol="text,REGNM" style="text-align: center;">등록자명</td>  
										<td GH="70" GCol="text,WRK_SHIFT" style="text-align: center;">작업조</td>
										<td GH="60" GCol="text,WRK_CLASS" style="text-align: center;">반</td>
									</tr>
								</tbody>
							</table>
						</div>
					</div>
					<jsp:include page="/WEB-INF/jsp/common/commonBtnAuth.jsp">
						<jsp:param name="authCd" value="2" />
						<jsp:param name="showAuthCd" value="1,2,3,7,9,10" />
					</jsp:include>
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