<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <title>Grid default</title>
    <%@ include file="/common/include/webdek/head.jsp" %>
    <link rel="stylesheet" type="text/css" href="/common/theme/webdek/css/demo_layout.css">
    <script type="text/javascript">
    	var lastFocusNum = 0;
    	
    	let colNum = 0
		
        $(document).ready(function(){
            gridList.setGrid({
                id : "gridList",
                url:"/mes/Quality/QLT06/json/datalist.data",
                bigdata : false,
                colHoldType : true,
	            colHold : "PRC_DIV_NM, WERKS, PRFM_DT",
	            // 2022-08-29(월요일) 안상현, 부적합량 제거
	            // totalCols : ["BAG_QTY","UCFMTY_AMT"]
	            totalCols : ["BAG_QTY"],
	            colorType : true
            })
            
            gridList.setGrid({
                id : "gridList2",
                url:"/mes/Quality/QLT06/json/datalist.data",
                editable : true,
                bigdata:false,
                colHoldType : true,
                colHold : "BIG_CAT_NM,MID_CAT_NM,INSP_ITEM_GRP_CD,INSP_ITEM_CD,INSP_ITEM_NM",
                colGroupCols : "BIG_CAT_NM,MID_CAT_NM"
            })
            document.getElementById('FNL_JDGM').selectedIndex = '1';
        });

        function searchList(){
        	if(validate.check("searchArea")){
	            gridList.resetGrid("gridList2");
	            var param = inputList.setRangeParam("searchArea");
	
	            if(param.get("WERKS") == "P100"){
	            	alert("PS제지는 현장 순회 외관 검사를 진행하지 않습니다.");
	            	return;
	            }
	            
	           	param.put("P_TYPE", "LIST");	
	           	
	           	gridList.gridList({
	                id : "gridList",
	                param : param
	            });
        	}
        }

        function searchSubList(headRowNum){
       		var MATNR = gridList.getColData("gridList", headRowNum, "MATNR");
       		var WERKS = gridList.getColData("gridList", headRowNum, "WERKS");
       		var MSRM_DATE = gridList.getColData("gridList", headRowNum, "MSRM_DATE");
       		var PRC_SEQNO = gridList.getColData("gridList", headRowNum,"PRC_SEQNO");
        	
    		var param = new DataMap();
            
            param.put("P_TYPE", "SUB_LIST");
            param.put("MATNR", MATNR);
    		param.put("WERKS", WERKS);
    		param.put("MSRM_DATE", MSRM_DATE);
    		param.put("PRC_SEQNO", PRC_SEQNO);

            gridList.gridList({
                id : "gridList2",
                param : param
            });

            lastFocusNum = headRowNum;
        }

        var lastFocusNum = -1;

        function gridListEventDataBindEnd(gridId, dataLength){
        	if(gridId == "gridList"){
    			var list = gridList.getGridData(gridId);
    		} else if(gridId == "gridList2"){
    			var list = gridList.getGridData(gridId);
    			
    			for(var i = 0; i < list.length; i++){
    				var INPT_TYP = list[i].get("INPT_TYP");		// 입력타입(숫자, 문자, 문자열)
    				const MSRM_ACC = list[i].get("MSRM_ACC");	// 측정차수
    				
    				if(INPT_TYP == "문자"){
    					gridList.setRowReadOnly(gridId, i, true, ["RST_VAL", "RST_TXT", "MSRM_INSERT"]);
    				} else if(INPT_TYP == "숫자"){
    					gridList.setRowReadOnly(gridId, i, true, ["RST_SEL", "RST_TXT"]);
    					
    					// 2022-09-28(수요일) 안상현, 품질팀 요청사항으로 측정차수가 2이상인 검사항목은 숫자를 입력하지 않는다.
    					if(MSRM_ACC >= 2){
    						gridList.setRowReadOnly(gridId, i, true, ["RST_VAL"])
    					}
    				} else {
    					gridList.setRowReadOnly(gridId, i, true, ["RST_SEL", "RST_VAL", "MSRM_INSERT"]);
    				}
    			}
    		}
        }

        function gridListEventRowDblclick(gridId, rowNum){
            if(gridId == "gridList"){
                searchSubList(rowNum);
                
                colNum = rowNum
            }
        }

     	// 팝업 로직 처리 후 조회
    	function linkPopCloseEvent(){
    		searchList();
    	}
        
        function alertNotice(gridId, rowNum, colName, colValue){
        	if(gridId == "gridList2"){
        		if(colName == "STD_VAL"){
        			if(colValue == ""){
        				return "<img src='/common/theme/webdek/images/icon_alert.png' height='20px' width='auto'/>";
        			}
        		}
        	}
        }
        
        function gridListEventColValueChange(gridId, rowNum, colName, colValue){
        	if(gridId == "gridList"){
				var rowData = gridList.getSelectData("gridList");
    			
    			for(var i = 0; i < rowData.length; i++){
        			if(i >= 1){
	        			if(rowData[i].get("MATNR") != rowData[i-1].get("MATNR")){
	        				alert("서로 다른 자재코드는 현장순회외관검사를 진행할 수 없습니다.");
	        				gridList.setRowState(gridId, configData.GRID_ROW_STATE_READ, rowNum);
	        				gridList.setRowCheck(gridId, rowNum, false);
	        				return;
	        			}
        			}
        		}
    			
    		} else if(gridId == "gridList2"){
    			var INPT_MTD = gridList.getColData("gridList2", rowNum, "INPT_MTD");
    			var flag = true;
    			var value_length = colValue.substring(colValue.indexOf('.') + 1);
    			
    			if(isNaN(colValue)){
    				flag = false;
    			}
    			
    			var Upp_val = gridList.getColData("gridList2", rowNum, "UPP_VAL");
    			var Low_val = gridList.getColData("gridList2", rowNum, "LOW_VAL");
    			
    			if(colName == "RST_VAL"){
    				if(flag == true){
    					if(colValue <= Number(Upp_val) && colValue >= Number(Low_val)){
        					gridList.setColValue(gridId, rowNum, "FIT_YN", "Y");
        				} else{
        					gridList.setColValue(gridId, rowNum, "FIT_YN", "N");
        				}
    					
    					if(colValue.indexOf('.') > 0){
 							if(INPT_MTD == "9"){
   								if(value_length > 0){
   		   	  						gridList.setColValue(gridId, rowNum, colName, "");
   		  							alert("소수점을 입력할 수 없습니다.");
   	   	  						}	
   							} else if(INPT_MTD == "9.9"){
   		  						if(value_length > 9){
   		  							gridList.setColValue(gridId, rowNum, colName, "");
   		  							alert("소숫점 1자리까지 입력할 수 있습니다.");
   		  						}
   							}
   							if(INPT_MTD == "9.99"){
	   	  						if(value_length > 99){
	   	  							gridList.setColValue(gridId, rowNum, colName, "");
	   	  							alert("소숫점 2자리까지 입력할 수 있습니다.");
	   	  						}
   							}else if(INPT_MTD == "9.999"){
	   	  						if(value_length > 999){
	   	  							gridList.setColValue(gridId, rowNum, colName, "");
	   	  							alert("소숫점 3자리까지 입력할 수 있습니다.");
	   	  						}
   							}
   	  					}
    				} else{
   						gridList.setColValue(gridId, rowNum, colName, "");
   						alert("숫자만 입력할 수 있습니다.");
   	   				} 
    			}
    			
    			if(colName == "RST_SEL"){
    				if(INPT_MTD == "PASS/FAIL"){
        				if(colValue == "PASS"){
        					gridList.setColValue(gridId, rowNum, "FIT_YN", "Y");
        				} else{
        					gridList.setColValue(gridId, rowNum, "FIT_YN", "N");
        				}
   	        		}
   				}
    		}
        }
        
        function gridListEventColBtnClick(gridId, rowNum, colName){
    		if(gridId == "gridList2"){
    			if(colName == "MSRM_INSERT"){
   					var INSP_YN = gridList.getColData("gridList", lastFocusNum, "INSP_YN");
   					var WERKS = gridList.getColData("gridList", lastFocusNum, "WERKS");
       				var MATNR = gridList.getColData("gridList", lastFocusNum, "MATNR");
       				var INSP_ITEM_GRP_CD = gridList.getColData(gridId, rowNum, "INSP_ITEM_GRP_CD");
       				var MSRM_DATE = gridList.getColData("gridList", lastFocusNum, "MSRM_DATE");
       				var PRC_SEQNO = gridList.getColData("gridList", lastFocusNum, "PRC_SEQNO");
    				
    				var rowData = gridList.getRowData("gridList2", rowNum);
    				
    				if(INSP_YN == "Y"){
    					if(Number(rowData.get("MSRM_ACC")) < 2){
        					alert("추가 측정 결과값을 등록할 수 없습니다.");
        					return;
        				}
    				} else if(INSP_YN == "N"){
    					if(Number(rowData.get("MSRM_ACC")) < 2){
        					alert("추가 측정 결과값을 등록할 수 없습니다.");
        					return;
        				}
    					alert("검사 완료 후 추가로 결과값을 등록할 수 있습니다.");
    					return;
    				}
    				
    				var url = "/mes/quality/QLT01_POP02.page";
    				var INSP_ITEM_CD = gridList.getColData("gridList2", rowNum, "INSP_ITEM_CD");
    				var MSRM_ACC = gridList.getColData("gridList2", rowNum, "MSRM_ACC");
    				
    				var param = new DataMap();
    				
    				param.put("WERKS", WERKS);
    				param.put("MATNR", MATNR);
    				param.put("INSP_ITEM_GRP_CD", INSP_ITEM_GRP_CD);
    				param.put("MSRM_DATE", MSRM_DATE);
    				param.put("PRC_SEQNO", PRC_SEQNO);
    				param.put("INSP_ITEM_CD", INSP_ITEM_CD);
    				param.put("MSRM_ACC", MSRM_ACC);
    				
    				param.put("colNum", colNum)
    				
    				page.linkPopOpen(url, param, "height=500,width=900");
    			}
    		}
    	}

        function saveData(){
        	var json = netUtil.sendData({
        		module : 'mes',
        		command : 'SYSTEMCHECK',
        		sendType : 'map'
        	});
        	
        	if(json.data.USE_YN == 'Y'){
        		alert('시스템 점검 중입니다. 1 ~ 5분 동안 잠시만 기다려 주세요.');
        		return;
        	}
        	
        	if(gridList.validationCheck("gridList2", "all")){
       			var rowData = gridList.getSelectData("gridList");
        		
        		if(rowData.length == 0){
        			alert("자재를 선택하세요.");
        			return;
        		} 
        		
        		for(var i = 0; i < rowData.length; i++){
        			if(i >= 1){
	        			if(rowData[i].get("MATNR") != rowData[i-1].get("MATNR")){
	        				alert("서로 다른 자재코드는 현장순회외관검사를 진행할 수 없습니다.");
	        				return;
	        			}
        			}
        			
        			// 2022-10-16(일요일) 안상현, 현장순회외관검사 기준값이 등록되지 않았을 경우 validation 체크
        			if(rowData[i].get("CHK_CNT") === "0"){
        				alert("현장 순회 외관검사 기준값이 등록되지 않은 행이 존재합니다. \n기준값을 등록하세요.")
        				return
        			}
        			
        			if(Number(rowData[i].get("BAG_QTY")) < $("#SMPL_AMT").val()){
        				$("#SMPL_AMT").val('');
        				alert("시료량을 선택한 입고수량보다 적게 입력할 수 있습니다.");
        				return;
        			}
        			
        			if(rowData[i].get('CHK_PP_YN') == 'N'){
        				alert('생산팀에서 확인요청이 진행하지 않은 제품입니다.생산팀에서 확인하세요.');
        				return;
        			}
        			
        			if(rowData[i].get('STCK_STA') == '70'){
        				alert('이미 WMS에서 출고된 항목이므로 처리할 수 없습니다.');
        				return;
        			}
        		}
        		
    			var subListCnt = gridList.getGridDataCount("gridList2");
    			var list = gridList.getGridData("gridList2");
    			
    			for (var i = 0; i < subListCnt; i++){
    				var NECSY_YN = gridList.getColData("gridList2", i, "NECSY_YN");
    				var Status = gridList.getRowStatus("gridList2", i);
					var Std_val = gridList.getColData("gridList2", i, "STD_VAL");
					var Fit_yn = gridList.getColData("gridList2", i, "FIT_YN");
					var inpt_typ = gridList.getColData("gridList2", i, "INPT_TYP");	// 입력타입(숫자, 문자, 문자열)
					var std_sel = gridList.getColData("gridList2", i, "STD_SEL");	// 기준값
					var rstval = gridList.getColData('gridList2', i, 'RST_VAL');	// 측정값
					var rstTxt = gridList.getColData('gridList2', i, 'RST_TXT');	// 결과값(문자열)
					var rstsel = gridList.getColData('gridList2', i, 'RST_SEL');	// 판정
					
					let INSP_STD_1 = gridList.getColData("gridList2", i, "INSP_STD_1");
					let INSP_STD_2 = gridList.getColData("gridList2", i, "INSP_STD_2");
					
					// 2022-09-28(수요일) 안상현, 품질팀 요청사항으로 측정차수가 2이상인 검사항목은 숫자를 입력하지 않는다.
					const MSRM_ACC = gridList.getColData("gridList2", i, "MSRM_ACC"); // 측정차수
					
					// NECSY_YN : 필수 입력 여부
    				if(NECSY_YN == "Y"){
    					if (inpt_typ == "숫자"){
    						if(MSRM_ACC < 2){
    							if(!Std_val || Std_val == "0"){
        							return alert("해당 품목에 등록된 기준값이 없습니다.");		
        						}
        						if(rstval == ''){
        							alert("필수 측정항목을 입력하지 않았습니다.");
        							return;
        						}
    						}
    					} else if (inpt_typ == "문자"){
    						if(!std_sel){
    							return alert("해당 품목에 등록된 기준선택값이 없습니다.");
    						}
    						if(rstsel == ''){
    							alert("필수 측정항목을 입력하지 않았습니다.");
    							return;
    						}
    					}
    					else if (inpt_typ == "문자열"){
    						if(!(INSP_STD_1 || INSP_STD_2)){
    							return alert("검사기준(1)과 검사기준(2) 둘다 없습니다.");
    						}
    						if(rstTxt == ''){
    							alert("필수 측정항목을 입력하지 않았습니다.");
    							return;
    						}
    					} 
    					if(Fit_yn == ""){
    						alert("입력된 항목에 대해 적합여부를 선택하지 않으셨습니다.");
    						return;
    					}
    				}
    			}
    			
    			if(!commonUtil.msgConfirm(configData.MSG_MASTER_SAVE_CONFIRM)){
    				return;
    			}
    			
    			var param = new DataMap();
    			
    			param.put("head", rowData);
    			param.put("P_TYPE", "SUB_SAVE");
    			param.put("list", list);
    			param.put("INSP_ITEM_GRP_CD", "H2");
    			param.put("SMPL_AMT", $("#SMPL_AMT").val());
    			param.put("FNL_JDGM", $("#FNL_JDGM").val());
    			
    			// 2022-11-01(화요일) 안상현, 선택된 처리순번
    			param.put("AN_SEQNO",gridList.getColData("gridList", colNum, "PRC_SEQNO"))
    			
                netUtil.send({
                    url : "/mes/Quality/QLT06/json/datalist.data",
                    param : param,
                    successFunction : "saveSuccessCallBack"
                });
            }
        }
        
        function saveSuccessCallBack(json){
        	if(json.P_SUCCESS == 'Y'){
        		var message = '';
        		
        		if(json.DOC_NO1 != ''){
        			//WMS에 완제품 출고요청
        			var ifid = "MES_IF_402";
           			
           			var json2 = netUtil.sendData({
           				url : "/common/api/json/"+ifid+"/send.data",
           				param : 'DOC_NO=' + json.DOC_NO1
           			});
           			
           			if(json2.result == 'SUCCESS'){
           			}else{
           				message = '(WMS 완제품 출고취소요청) ' + json2.result + '\n';
           			}
        		}
        		if(json.DOC_NO2 != ''){
        			//WMS에 순회외관검사 결과
        			var ifid = "MES_IF_906";
           			
           			var json2 = netUtil.sendData({
           				url : "/common/api/json/"+ifid+"/send.data",
           				param : 'DOC_NO=' + json.DOC_NO2
           			});
           			
           			if(json2.result == 'SUCCESS'){
           			}else{
           				message = message + '(WMS 순회외관검사 결과) ' + json2.result;
           			}
        		}
        		if(message == ""){
        			commonUtil.msgBox(configData.MSG_SYSTEM_SAVEOK);
        		}else{
        			alert(message);
        		}
				gridList.resetGrid("gridList2");
        		$("#SMPL_AMT").val('');
                searchList();
        	}
        }
        
        function commonBtnClick(btnName){
            var count = gridList.getGridDataCount("gridList");
            
            if(btnName == "Search"){
                var param = new DataMap();
                param.put("PROGID", "<%= menuId%>");
                param.put("LGTYPE", "SEARCH");
                var json = netUtil.sendData({
                    url: "/mes/system/json/saveLog.data",
                    param : param
                });

                searchList();
            } else if(btnName == "Save"){
                saveData();
            } else if(btnName == "Finprostatus"){
            	if(count > 0){
           			// 2022-05-18(수요일)-안상현, 완제품 검사의 완제품현황 조회 팝업 연결
   	            	var url = "/mes/quality/QLT05_POP01.page";
   	            	var rowData = gridList.getSelectData("gridList");
   	            	
   	            	if(rowData.length > 1){
   	            		alert("하나의 항목만 선택가능합니다.");
   	            		return;
   	            	}else if(rowData.length == 0){
   	            		alert("완제품현황 조회할 항목을 선택하시기 바랍니다.");
   	            		return;
   	            	}
   	            	
   					page.linkPopOpen(url, rowData, "height=950,width=1300");
            	}
            } else if(btnName == "Workwrhs"){
            	if(count > 0){
           			var url = "/mes/quality/QLT06_POP01.page";
   	            	var rowData = gridList.getSelectData("gridList");
   	            	
   	            	if(rowData.length > 1){
   	            		alert("하나의 항목만 선택가능합니다.");
   	            		return;
   	            	}else if(rowData.length == 0){
   	            		alert("공정창고조회할 항목을 선택하시기 바랍니다.");
   	            		return;
   	            	}
   	            	
   	            	page.linkPopOpen(url, rowData, "height=1000,width=1300");
            	}
            }
        }
        
        // 2022-08-25(목요일) 안상현, LOT번호 검색조건 추가
        const LOT = () => {
    		page.linkPopOpen("/common/SEARCH_LOT.page", "", "width=1500, height=600");
    	}
        
     	// 2022-10-16(일요일) 안상현, 현장 순회 외관검사 기준값이 등록되지 않았을 경우, 그리드 빨간색으로 표시
	 	function gridListRowColorChange(gridId, rowNum, rowData){
	 		if(gridId === "gridList"){
				if(rowData.get("CHK_CNT") === "0"){
					return configData.GRID_COLOR_BG_RED_CLASS;
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
                    <input type="button" id="button-0-4" CB="Workwrhs SEARCH BTN_WORKWRHS" />
                    <!-- <input type="button" id="button-0-3" CB="Finprostatus FINPROSTATUS BTN_FINPROSTATUS" /> -->
                    <input type="button" id="button-0-2" CB="Save SAVE BTN_SAVE" />
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
                        <dt CL="STD_PRFM_DT">실적일자</dt>
                        <dd><input type="text" name="W001.PRFM_DT" UIInput="B" UIFormat="C M1"/></dd>
                    </dl>
                    <dl>
                        <dt CL="STD_MATNR">자재코드</dt>
                        <dd><input type="text" name="W001.MATNR" UIInput="SR,MATKY" UIFormat="U"/></dd>
                    </dl>
                    <dl>
                        <dt CL="STD_MACH_CD">설비</dt>
                        <dd>
                            <input type="text" name="W001.MACH_CD" UIInput="SR,MACH" UIFormat="U"/>
                        </dd>
                    </dl>
                    <!-- 2022-08-25(목요일) 안상현, LOT번호 검색조건 추가 -->
                    <dl>
						<dt CL="STD_LOT_NO">LOT번호</dt>
						<dd style="font-size: 0">					
							<input type="text" class="input" id="LOT_NO" name="LOT_NO" UIInput="SR,LOTNO" UIFormat="U"/>
							<!-- <button type="button" class="btn btn_search" onclick="LOT()">
								<span>search</span>
							</button> -->
						</dd>
					</dl>
                    <dl>
                        <dt CL="STD_IND_BCD">개별바코드</dt>
                        <dd>
                            <input type="text" class="input" name="IND_BCD" UIInput="SR,INDBCD" UIFormat="U" maxlength="15"/>
                        </dd>
                    </dl>
                </div>
                <div class="btn_tab">
                    <input type="button" class="btn_more" value="more" onclick="searchMore()"/>
                </div>
            </div>
        </div>
        <div class="search_next_wrap">
            <div class="content_layout tabs top_layout">
                <ul class="tab tab_style02">
                    <li><a href="#tab1-1" >생산실적</span></a></li>
                    <li class="btn_zoom_wrap">
                        <ul>
                            <li><button class="btn btn_bigger"><span>확대</span></button></li>
                        </ul>
                    </li>
                    <dt></dt>
                    <li>
                    	<img src="/common/theme/webdek/images/ico_infor.png" width="15" height="15" style="margin:7px -420px;"/>
                    	<dt style="width:400px;margin:2px;">재고상태가 입고요청인 상태는 WMS로 입고취소처리가 진행됩니다.</dt>
                    </li>
                </ul>
                <div class="table_box section" id="tab1-1">
                    <div class="table_list01">
                        <div class="scroll">
                            <table class="table_b">
                                <tbody id="gridList">
                                <tr CGRow="true">
                                    <td GH="40" GCol="rownum">1</td>
                                    <td GH="40" GCol="rowCheck"></td>
                                    <td GH="0" GCol="text,PRC_DIV">처리구분</td>
                                    <td GH="80" GCol="text,PRC_DIV_NM">처리구분(명)</td>
                                    <td GH="100" GCol="text,WERKS" style="text-align:center;">플랜트</td>
                                    <td GH="0" GCol="text,MACH_CD" style="text-align:center;">설비</td>
                                    <td GH="0" GCol="text,MACH_NM">설비(명)</td>
                                    <td GH="100" GCol="text,PRFM_DT" GF='D' style="text-align:center;">실적일자</td>
                                    <td GH="140" GCol="text,WRK_ORDR_NO">작업지시번호</td>
                                    <td GH="100" GCol="text,WRK_ORDR_SEQNO" style="text-align:center;">작업지시순번</td>
                                    <td GH="100" GCol="text,LOT_NO">LOT번호</td>
                                    <td GH="0" GCol="text,IND_BCD">개별바코드</td>
                                    <td GH="140" GCol="text,MATNR" style="text-align:center;">자재코드</td>
                                    <td GH="320" GCol="text,MATNR_NM">자재코드명</td>
                                    <td GH="0" GCol="text,PLT_QTY" GF='N 10,1'>팔레트수량</td>
                                    <td GH="0" GCol="text,BOX_QTY" GF='N 10'>박스수량</td>
                                    <td GH="80" GCol="text,BAG_QTY" GF='N 10'>백수량</td>
                                    <td GH="0" GCol="text,EA_QTY" GF='N 10'>개수량</td>
                                    <td GH="0" GCol="text,WGT" GF='N 10,3'>중량</td>
                                    <td GH="0" GCol="text,UNIT" style="text-align:center;">단위</td>
                                    <td GH="100" GCol="text,UNIT_NM">단위(명)</td>
                                    <td GH="0" GCol="text,PRD_DT" GF="D" style="text-align:center;">제조일자</td>
                                    <td GH="160" GCol="text,BRAND_DESCR">브랜드</td>
                                    <td GH="0" GCol="text,DOC_NO">MES문서번호</td>
                                    <td GH="0" GCol="text,DOC_SEQNO">MES문서순번</td>
                                    <!-- 2022-08-29(월요일) 안상현, 부적합량 제거 -->
                                    <!-- <td GH="100" GCol="input,UCFMTY_AMT" GF="N 13">부적합량</td>  -->
                                    <td GH="100" GCol="text,INSP_YN">검사여부(Y/N)</td>
                                    <td GH="0" GCol="text,INSP_ITEM_GRP_CD" style="text-align:center;">검사항목그룹코드</td>
                                    <td GH="140" GCol="text,MSRM_DATE" style="text-align:center;">측정일시</td>
                                    <td GH='100' GCol='text,STOR_LOC_CD' style="text-align:center;">저장위치</td>
                                    <td GH='80' GCol='text,CHK_PP_YN' style='text-align:center;'>생산확인</td>
                                    <td GH='0' GCol='text,STCK_STA' style="text-align:center;">재고상태</td>
                                    <td GH='100' GCol='text,STCK_STA_NM'>재고상태</td>
                                    <td GH="0" GCol="text,PRC_SEQNO" style="text-align:right;">처리순번</td>
                                    <td GH="0" GCol="text,UCFMTY_YN">부적합 결과 여부</td>
                                    <td GH="0" GCol="text,REGDATE" style="text-align:center;">수정일시</td>
                                    <td GH="100" GCol="text,REGNM">수정자</td>
                                    <td GH="0" GCol="text,CHK_CNT">현장 순회 외관검사 기준값 등록 여부</td>
                                </tr>
                                </tbody>
                            </table>
                        </div>
                    </div>
                    <jsp:include page="/WEB-INF/jsp/common/commonBtnAuth.jsp">
                    	<jsp:param name="authCd" value="1"/>
                    	<jsp:param name="showAuthCd" value="1,2,3,7,9,10"/>
                    </jsp:include>
                </div>
            </div>
            <div class="content_layout tabs bottom_layout">
                <ul class="tab tab_style02">
                    <li><a href="#tab1-1">검사항목</span></a></li>
                    <dt></dt>
                    <li>
                        <dt CL="STD_SMPL_AMT">시료량</dt>
                       	<dd><input type="text" class="input" id="SMPL_AMT" UIFormat="N 5" style="width:100px"/></dd>
                    </li>
                    <li>
                        <dt CL="STD_FNL_JDGM">최종판정</dt>
                        <dd>
                        	<select class="input" id="FNL_JDGM" CommonCombo="FNL_JDGM"></select>
                        </dd>
                    </li>
                    <li class="btn_zoom_wrap">
                        <ul>
                            <li><button class="btn btn_bigger"><span>확대</span></button></li>
                        </ul>
                    </li>
                </ul>
                <div class="table_box section" id="tab1-1" >
                    <div class="table_list01">
                        <div class="scroll">
                            <table class="table_c">
                                <tbody id="gridList2">
	                                <tr CGRow="true">
	                                    <td GH="40" GCol="rownum">1</td>
	                                    <td GH="40" GCol="rowCheck"></td>
										<td GH="140" GCol="text,BIG_CAT_NM">대분류명</td>
										<td GH="140" GCol="text,MID_CAT_NM">중분류명</td> 
	                                    <td GH="0" GCol="text,INSP_ITEM_GRP_CD" style="text-align:center;">검사항목그룹코드</td>
	                                    <td GH="0" GCol="text,INSP_ITEM_CD" style="text-align:center;">검사항목코드</td>
										<td GH="140" GCol="text,INSP_ITEM_NM">검사항목명</td>
										<td GH="100" GCol="text,INPT_TYP">입력타입</td>
										<td GH="100" GCol="text,INPT_MTD">입력방법	</td>
										<td GH="100" GCol="text,MSRM_UNIT">측정단위</td>
										<td GH="80" GCol="text,STD_VAL" GF="N 9,2">기준값</td>
										<td GH="80" GCol="text,UPP_VAL" GF="N 9,2">규격상한치</td>
										<td GH="80" GCol="text,LOW_VAL" GF="N 9,2">규격하한치</td>
										<td GH="0" GCol="text,STD_SEL">기준선택값</td>
										<td GH="180" GCol="text,INSP_STD_1">검사기준(1)</td>
										<td GH="180" GCol="text,INSP_STD_2">검사기준(2)</td>
										<td GH="80" GCol="text,MSRM_ACC" GF="N 5">측정차수</td>
										<td GH="100" GCol="btn,MSRM_INSERT" GB="Msrm_Insert MSRM_INSERT BTN_MSRM_INSERT"></td>	<!-- 결과등록 -->
										<td GH="80" GCol="input,RST_VAL" GF="N 13,2">측정값</td>
										<td GH="100" GCol="input,RST_TXT" GF="S 500">결과값(문자열)</td>
										<td GH="100" GCol="select,RST_SEL">
											<select CommonCombo="FNL_JDGM"><!-- 판정 -->
												<option value=""></option>
											</select>
										</td>
										<td GH="140" GCol="input,RMK" GF="S 100">비고</td>
										<td GH="80" GCol="text,NECSY_YN">필수입력 여부</td>
	                                    <td GH="250" GCol="file,UUID"/>첨부파일</td>
										<td GH="100" GCol="select,FIT_YN">
											<select CommonCombo="FITYN"><!-- 적합여부 -->
												<option value=""></option>
											</select>
										</td>
										<td GH="140" GCol="text,REGDATE" style="text-align:center;">등록일시</td>
										<td GH="0" GCol="text,INSP_REP_YN">성적서출력여부</td>
	                                </tr>
                                </tbody>
                            </table>
                        </div>
                    </div>
                    <jsp:include page="/WEB-INF/jsp/common/commonBtnAuth.jsp">
                    	<jsp:param name="authCd" value="1"/>
                    	<jsp:param name="showAuthCd" value="1,2,3,9,10"/>
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
