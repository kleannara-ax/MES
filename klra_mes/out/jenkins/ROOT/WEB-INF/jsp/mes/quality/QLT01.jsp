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
		var message = '';
		
        $(document).ready(function(){
            gridList.setGrid({
                id : "gridList",
                url : "/mes/Quality/QLT01/json/datalist.data",
                bigdata : false,
                colHoldType : true,
                colHold : "PRC_DIV_NM, WERKS, RCVGDS_DT"
            });
			/* 
            gridList.setGrid({
                id : "gridList2",
                url : "/mes/Quality/QLT01/json/datalist.data",
                bigdata : false,
                colHoldType : true,
                colHold : "INSP_ITEM_GRP_CD,INSP_ITEM_CD,INSP_ITEM_NM,BIG_CAT_NM,MID_CAT_NM"
            });
             */
        });

        function searchList(){
        	if(validate.check("searchArea")){
        		var param = inputList.setRangeParam("searchArea");
                param.put("P_TYPE", "LIST");
                gridList.gridList({
                    id : "gridList",
                    param : param
                });
                
                // gridList.resetGrid("gridList2");
        	}
        }

        function searchSubList(headRowNum){
        	var MATNR = gridList.getColData("gridList", headRowNum, "MATNR");
    		var WERKS = gridList.getColData("gridList", headRowNum, "WERKS");
    		var MSRM_DATE = gridList.getColData("gridList", headRowNum, "MSRM_DATE");
    		var PRC_SEQNO = gridList.getColData("gridList", headRowNum,"PRC_SEQNO");
    		
    		var param = inputList.setRangeParam("searchArea");
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
    	
    	function gridListEventDataBindEnd(gridId, dataLength){
    		if(gridId == "gridList"){
    			var list = gridList.getGridData(gridId);
    			
    			for(var i = 0; i < list.length; i++){
    				var INSP_YN = list[i].get("INSP_YN");
    				
    				if(INSP_YN == "Y"){
    					// 검사가 끝난 항목은 입고수량, 부적합량, 최종판정, 비고 수정불가
    					gridList.setRowReadOnly(gridId, i, true, ["RCVGDS_QTY","SMPL_AMT","UCFMTY_AMT","FNL_JDGM","RMK"])
    				}
    			}
    		} else if(gridId == "gridList2"){
    			var list = gridList.getGridData(gridId);
    			
    			for(var i = 0; i < list.length; i++){
    				var INPT_TYP = list[i].get("INPT_TYP");
    				var regdate = list[i].get("REGDATE");
    				
    				if(INPT_TYP == "문자"){
    					gridList.setRowReadOnly(gridId, i, true, ["RST_VAL", "RST_TXT", "MSRM_INSERT"]);
    				} else if(INPT_TYP == "숫자"){
    					gridList.setRowReadOnly(gridId, i, true, ["RST_SEL", "RST_TXT"]);
    				} else {
    					gridList.setRowReadOnly(gridId, i, true, ["RST_SEL", "RST_VAL", "MSRM_INSERT"]);
    				}
    				
    				if(regdate != ""){
    					gridList.setRowReadOnly(gridId, i, true, ["RST_VAL", "RST_SEL", "RST_TXT", "RMK"]);
    				}
    			}
    		}
    	}
    	
    	function gridListEventRowDblclick(gridId, rowNum){
    		if(gridId == "gridList"){

    			searchSubList(rowNum);
    		}
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
	        			if((rowData[i].get("MATNR") != rowData[i-1].get("MATNR")) && (rowData[i].get("VND_LOT_NO") != rowData[i-1].get("VND_LOT_NO")) 
	        					&& (rowData[i].get("SUPY_CD") != rowData[i-1].get("SUPY_CD"))){
	        				alert("서로 다른 자재코드, LOTNO, 공급업체는 수입검사를 진행할 수 없습니다.");
	        				gridList.setRowState(gridId, configData.GRID_ROW_STATE_READ, rowNum);
	        				gridList.setRowCheck(gridId, rowNum, false);
	        				gridList.setColValue(gridId, rowNum,"UCFMTY_AMT", "");
	        				return;
	        			}
        			}
        		}
    			
    			if(colName == "UCFMTY_AMT"){
    				var rcvgdsqty = gridList.getColData("gridList", rowNum, "RCVGDS_QTY");
    				if(Number(rcvgdsqty) < colValue){
    					alert("입고수량보다 적게 입력할 수 있습니다.");
    					gridList.setRowState(gridId, configData.GRID_ROW_STATE_READ, rowNum);
        				gridList.setRowCheck(gridId, rowNum, false);
        				gridList.setColValue(gridId, rowNum,"UCFMTY_AMT", "");
    				}
    			}
    		} else if(gridId == "gridList2"){
    			var INPT_MTD = gridList.getColData("gridList2", rowNum, "INPT_MTD");
    			var flag = true;
    			var value_length = colValue.substring(colValue.indexOf('.') + 1);
    			
    			if(isNaN(colValue)){	// 숫자 판별
    				flag = false;
    			}
    			
    			var Upp_val = gridList.getColData("gridList2", rowNum, "UPP_VAL");
    			var Low_val = gridList.getColData("gridList2", rowNum, "LOW_VAL");
    			
    			if(colName == "RST_VAL"){
    				if(colValue <= Number(Upp_val) && colValue >= Number(Low_val)){
    					gridList.setColValue(gridId, rowNum, "FIT_YN", "Y");
    				} else{
    					gridList.setColValue(gridId, rowNum, "FIT_YN", "N");
    				}
    				
    				if(flag == true){
    					if(colValue.indexOf('.') > 0){
 							/* if(INPT_MTD == "9"){
   								if(value_length > 0){
   		   	  						gridList.setColValue(gridId, rowNum, colName, "");
   		  							alert("소수점을 입력할 수 없습니다.");
   	   	  						}	
   							} else if(INPT_MTD == "9.9"){
   		  						if(value_length > 9){
   		  							gridList.setColValue(gridId, rowNum, colName, "");
   		  							alert("소숫점 1자리까지 입력할 수 있습니다.");
   		  						}
   							}  */
 							if(INPT_MTD == "9.99"){
	   	  						if(value_length > 99){
	   	  							gridList.setColValue(gridId, rowNum, colName, "");
	   	  							alert("소숫점 2자리까지 입력할 수 있습니다.");
	   	  						}
   							}/*  else if(INPT_MTD == "9.999"){
	   	  						if(value_length > 999){
	   	  							gridList.setColValue(gridId, rowNum, colName, "");
	   	  							alert("소숫점 3자리까지 입력할 수 있습니다.");
	   	  						}
   							} */
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
   					/* if(INPT_MTD == "PASS/FAIL"){
   	        			if(colValue != "PASS" && colValue != "FAIL"){
   	        				gridList.setColValue(gridId, rowNum, colName, "");
   	        				alert("결과값을 다시 입력하세요.");
   	        			} else{
   	        				if(colValue == "PASS"){
   	        					gridList.setColValue(gridId, rowNum, "FIT_YN", "Y");
   	        				} else{
   	        					gridList.setColValue(gridId, rowNum, "FIT_YN", "N");
   	        				}
   	        			}
   	        		} else if(INPT_MTD == "상/중/하"){
   	        			if(colValue != "상" && colValue != "중" && colValue != "하"){
   	        				gridList.setColValue(gridId, rowNum, colName, "");
   	        				alert("결과값을 다시 입력하세요.");
   	        			} else{
   	        				if(colValue == "상" || colValue == "중"){
   	        					gridList.setColValue(gridId, rowNum, "FIT_YN", "Y");
   	        				} else{
   	        					gridList.setColValue(gridId, rowNum, "FIT_YN", "N");
   	        				}
   	        			}
   	        		} else if(INPT_MTD == "YES/NO"){
   	        			if(colValue != "YES" && colValue != "NO"){
   	        				gridList.setColValue(gridId, rowNum, colName, "");
   	        				alert("결과값을 다시 입력하세요.")
   	        			} else{
   	        				if(colValue == "YES"){
   	        					gridList.setColValue(gridId, rowNum, "FIT_YN", "Y");
   	        				} else{
   	        					gridList.setColValue(gridId, rowNum, "FIT_YN", "N");
   	        				}
   	        			}
   	        		} */
   				}
    		}
    	}
    	
    	function gridListEventColBtnClick(gridId, rowNum, colName){
    		if(gridId == "gridList2"){
    			if(colName == "MSRM_INSERT"){
    				var INSP_YN = gridList.getColData("gridList", lastFocusNum, "INSP_YN");
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
    			 	var WERKS = gridList.getColData("gridList", lastFocusNum, "WERKS");
    				var MATNR = gridList.getColData("gridList", lastFocusNum, "MATNR");
    				var INSP_ITEM_GRP_CD = gridList.getColData("gridList", lastFocusNum, "INSP_ITEM_GRP_CD");
    				var MSRM_DATE = gridList.getColData("gridList", lastFocusNum, "MSRM_DATE");
    				var PRC_SEQNO = gridList.getColData("gridList", lastFocusNum, "PRC_SEQNO");
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
    				
    				page.linkPopOpen(url, param, "height=500,width=900");
    			}
    		}
    	}
    	
    	// 저장
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
    		
        	if(gridList.validationCheck("gridList", "select")){
        		const rowData = gridList.getSelectData("gridList")
        		
        		if(rowData.length == 0){
        			alert("등록할 자재를 선택하세요.");
        			return;
        		}
        		
        		for(var i = 0; i < rowData.length; i++){
        			
        			if(i >= 1){
	        			if((rowData[i].get("MATNR") != rowData[i-1].get("MATNR")) && (rowData[i].get("VND_LOT_NO") != rowData[i-1].get("VND_LOT_NO")) 
	        					&& (rowData[i].get("SUPY_CD") != rowData[i-1].get("SUPY_CD"))){
	        				alert("서로 다른 자재코드, LOTNO, 공급업체는 수입검사를 진행할 수 없습니다.");
	        				return;
	        			}
        			}
        			if(rowData[i].get("INSP_YN") == "Y"){
        				alert("이미 검사 판정을 완료한 건이 있습니다.");
        				return;
        			// UCFMTY_AMT : 부적합 수량
        			} else if(rowData[i].get("UCFMTY_AMT") == " " || rowData[i].get("UCFMTY_AMT") == "0.000"){
        				if(rowData[i].get("FNL_JDGM") == "FAIL"){
        					alert("최종판정을 부적합으로 선택하였으나 부적합량을 입력하지 않으셨습니다.")
        					return
        				}
        				/* 
        				if($("#FNL_JDGM").val() == "FAIL"){
        					alert("최종판정을 부적합으로 선택하였으나 부적합량을 입력하지 않으셨습니다.");
        					return;
        				}
        				*/
        			} else if(rowData[i].get("UCFMTY_AMT") != " " || rowData[i].get("UCFMTY_AMT") == "0.000"){
        				if(rowData[i].get("FNL_JDGM") == "PASS"){
        					alert("최종판정을 적합으로 선택하였으나 부적합량을 입력하였습니다.");
        					return;
        				}
        				/* 
        				if($("#FNL_JDGM").val() == "PASS"){
        					alert("최종판정을 적합으로 선택하였으나 부적합량을 입력하였습니다.");
        					return;
        				}
        				*/
        			} 
        			
        			// RCVGDS_QTY : 입고수량
        			// SMPL_AMT : 시료량
        			if(Number(rowData[i].get("RCVGDS_QTY")) < Number(rowData[i].get("SMPL_AMT"))){
        				alert("시료량을 선택한 입고수량보다 적게 입력할 수 있습니다.");
        				return;
        			}
        		}
        		
        		if(!commonUtil.msgConfirm(configData.MSG_MASTER_SAVE_CONFIRM)){
    				return;
    			}
        		
    			// var list = gridList.getSelectData("gridList2");
    			
    			var param = new DataMap();
    			
    			param.put("head", rowData);
    			param.put("P_TYPE", "SUB_SAVE");
    			// param.put("list", list);
    			param.put("INSP_ITEM_GRP_CD", "C1");
    			// param.put("SMPL_AMT", $("#SMPL_AMT").val()); 시료량
    			// param.put("UCFMTY_AMT", $("#UCFMTY_AMT").val()); 부적합량
    			// param.put("FNL_JDGM", $("#FNL_JDGM").val()); 최종판정
    			
		    	netUtil.send({
    				url : "/mes/Quality/QLT01/json/datalist.data",
    				param : param,
    				successFunction : "savesuccessCallBack"
    			});
        	}
        }
        
        function savesuccessCallBack(json){
        	if(json){
				InterfaceSendDoc(json.WDOC_NO);
			}
        }
        
        function InterfaceSendDoc(DOCNO){
   			var ifid = "MES_IF_901";
   			
   			var wdocno = DOCNO.split(',');
   			
   			for(var i = 0; i < wdocno.length; i++){
   				if(wdocno[i] != ''){
   					var json = netUtil.sendData({
   		   				url : "/common/api/json/"+ifid+"/send.data",
   		   				param : 'DOC_NO=' + wdocno[i]
   		   			});
   		   			
	   				if(json.result == 'SUCCESS'){
	   				}else {
	   					message = '(WMS 품질검사 결과 정보 결과) ' + json.result + '\n' + message;
	   				}
   				}
   			}
   			if(message == ''){
   				commonUtil.msgBox(configData.MSG_SYSTEM_SAVEOK);
				// gridList.resetGrid("gridList2");
				//$("#SMPL_AMT").val('');
				searchList();
   			}else{
   				alert(message);
   			}
    	}
        
        function commonBtnClick(btnName){
            //commonUtil.debugMsg("commonBtnClick : ", arguments);
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
            }else if(btnName == "Workwrhs"){
            	var count = gridList.getGridDataCount("gridList");
            	
            	if(count > 0){
           			var url = "/mes/quality/QLT01_POP01.page";
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
                    <input type="button" id="button-0-3" CB="Workwrhs WORKWRHS BTN_WORKWRHS" />
                    <input type="button" id="button-0-2" CB="Save SAVE BTN_SAVE" />
                </div>
            </div>
            <div class="search_inner">
                <div class="search_wrap ">
                   <dl>
						<dt CL="STD_PLANT">플랜트</dt>
						<dd>
							<input type="text" name="WERKS" validate="required" UIInput="S,PLANT" UIFormat="U"/>
						</dd>
					</dl>
                    <dl>
                        <dt CL="STD_RCVGDS_DT">입고일자</dt>
                        <dd><input type="text" name="RCVGDS_DT" UIInput="B" UIFORMAT="C M1"/></dd>
                    </dl>
                    <dl>
                        <dt CL="STD_PRDC_DT">제조일자</dt>
                        <dd><input type="text" name="PRDC_DT" UIInput="B" UIFORMAT="C M1"/></dd>
                    </dl>
                    <dl>
                        <dt CL="STD_MATNR">자재코드</dt>
                        <dd><input type="text" name="Q001.MATNR" UIInput="SR,MATKY" UIFormat="U"/></dd>
                    </dl>
                    <dl>
                        <dt CL="STD_SUPY">공급업체</dt>
                        <dd><input type="text" name="SUPY_CD" UIInput="SR,CUST" UIFormat="U"/></dd>
                    </dl>
                    <dl>
                        <dt CL="STD_INSP_YN">검사여부</dt>
                        <dd>
                            <select name="INSP_YN" class="input">
                                <option value="">All</option>
                                <option value="Y">Y</option>
                                <option value="N">N</option>
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
           <!-- <div class="content_layout tabs top_layout"> -->
            <div class="content_layout tabs">
                <ul class="tab tab_style02">
                    <li><a href="#tab1-1"><span CL="STD_GRD_QLT01">자재 입고정보</span></a></li>
                    <li class="btn_zoom_wrap">
                        <ul>
                            <li><button class="btn btn_bigger"><span>확대</span></button></li>
                        </ul>
                    </li>
                </ul>
                <div class="table_box section" id="tab1-1">
                    <div class="table_list01">
                        <div class="scroll">
                            <table class="table_c">
                                <tbody id="gridList">
	                                <tr CGRow="true">
	                                    <td GH="40" GCol="rownum">1</td>
	                                    <td GH="40" GCol="rowCheck"></td>
	                                    <td GH="0" GCol="text,DOC_ITM">문서아이템</td>
	                                    <td GH="0" GCol="text,REQ_DIV">요청구분</td>
	                                    <td GH="0" GCol="text,REQ_DATE" style="text-align:center;">요청일시</td>
	                                    <td GH="0" GCol="text,REQ_ID">요청자</td>
	                                    <td GH="0" GCol="text,PRC_DIV">처리구분</td>
	                                    <td GH="80" GCol="text,PRC_DIV_NM">처리구분(명)</td>
	                                    <td GH="100" GCol="text,WERKS" style="text-align:center;">플랜트</td>
	                                    <td GH="100" GCol="text,RCVGDS_DT" style="text-align:center;" GF="D">입고일자</td>
	                                    <td GH="140" GCol="text,MATNR" style="text-align:center;">자재코드</td>
	                                    <td GH="320" GCol="text,MATNR_NM">자재명</td>
	                                    <td GH="100" GCol="text,VND_LOT_NO">업체LOT번호</td>
	                                    <td GH="120" GCol="text,SUPY_VND_BCD">공급업체바코드</td>
	                                    <td GH="0" GCol="text,ORDER_NO">오더번호</td>
	                                    <td GH="0" GCol="text,ORDER_SEQNO">오더순번</td>
	                                    <td GH="0" GCol="text,UNIT" style="text-align:center;">단위</td>
	                                    <td GH="100" GCol="text,UNIT_NM">단위(명)</td>
	                                    <td GH="100" GCol="text,RCVGDS_QTY" GF="N 5,3">입고수량</td>
	                                    <td GH="100" GCol="input,SMPL_AMT" GF="N 13,3">시료량</td>
	                                    <td GH="100" GCol="input,UCFMTY_AMT" GF="N 13,3">부적합량</td>
	                                    <td GH="150" GCol="select,FNL_JDGM" validate="required">
											<select class="input" CommonCombo="FNL_JDGM"><!-- 최종판정 -->
												<option value="">선택</option>
											</select>
										</td>
										<td GH="300" GCol="input,RMK" style="text-align:center;" GF="S 100">비고</td>
	                                    <td GH="0" GCol="text,STCK_STA" style="text-align:center;">재고상태</td>
	                                    <td GH="0" GCol="text,STCK_STA_NM">재고상태(명)</td>
	                                    <td GH="0" GCol="text,NTN_CD" style="text-align:center;">국가코드</td>
	                                    <td GH="0" GCol="text,NTN_NM">국가 명</td>
	                                    <td GH="100" GCol="text,PRDC_DT" style="text-align:center;" GF="D">제조일자</td>
	                                    <td GH="0" GCol="text,DSTBT_DDLIN" style="text-align:center;" GF="D">유통기한</td>
	                                    <td GH="100" GCol="text,SUPY_CD" style="text-align:center;">공급업체코드</td>
	                                    <td GH="280" GCol="text,SUPY_NM">공급업체명</td>
	                                    <td GH="0" GCol="text,CRSPD_CD" style="text-align:center;">거래처코드</td>
	                                    <td GH="0" GCol="text,CRSPD_NM">거래처명</td>
	                                    <td GH="100" GCol="text,STOR_LOC_CD" style="text-align:center;">저장위치</td>
	                                    <td GH="100" GCol="text,INSPR_NM">검사자</td>
	                                    <td GH="100" GCol="text,INSP_YN">검사여부(Y/N)</td>
	                                    <td GH="140" GCol="text,INSP_DATE" style="text-align:center;">검사일시</td>
	                                    <td GH="100" GCol="text,UCFMTY_YN">부적합 결과 여부</td>
	                                    <td GH="160" GCol="text,VGBEL">WMS 참조번호</td>
	                                    <td GH="100" GCol="text,VGPOS">WMS 참조아이템</td>
	                                    <td GH="160" GCol="text,LOT_NUM">WMS_LOT_NUM</td>
	                                    <td GH="160" GCol="text,STOR_KY">저장키</td>
	                                    <td GH="0" GCol="text,PRC_SEQNO" style="text-align:right;">처리순번</td>
	                                    <td GH="0" GCol="text,DOC_NO">MES문서번호</td>
	                                    <td GH="0" GCol="text,DOC_SEQNO" style="text-align:right;">MES문서순번</td>
	                                    <td GH="0" GCol="text,INSP_ITEM_GRP_CD" style="text-align:center;">검사항목그룹코드</td>
	                                    <td GH="0" GCol="text,MSRM_DATE" style="text-align:center;">측정일시</td>
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
            <%-- 
            <div class="content_layout tabs bottom_layout">
                <ul class="tab tab_style02">
                    <li><a href="#tab1-1"><span>검사항목</span></a></li>
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
	                                    <td GH="0" GCol="text,INSP_ITEM_GRP_CD" style="text-align:center;">검사항목그룹코드</td>
	                                    <td GH="0" GCol="text,INSP_ITEM_CD" style="text-align:center;">검사항목코드</td>
										<td GH="140" GCol="text,INSP_ITEM_NM">검사항목명</td>
										<td gh="140" GCol="text,BIG_CAT_NM">대분류명</td>
										<td gh="140" GCol="text,MID_CAT_NM">중분류명</td> 
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
										<td GH="100" GCol="btn,MSRM_INSERT" GB="Msrm_Insert MSRM_INSERT BTN_MSRM_INSERT"></td>	<!-- 검사결과 -->
										<td GH="80" GCol="input,RST_VAL" style="text-align:right;">측정값</td>
										<td GH="100" GCol="input,RST_TXT" GF="S 500">결과값(문자열)</td>
										<td GH="100" GCol="select,RST_SEL">
											<select CommonCombo='FNL_JDGM'>판정
												<option value=""></option>
											</select>
										</td>
										<td GH="140" GCol="input,RMK" GF="S 400">특이사항</td>
										<td GH="80" GCol="text,NECSY_YN">필수입력 여부</td>
	                                    <td GH="250" GCol="file,UUID"/>첨부파일</td>
										<td GH="100" GCol="select,FIT_YN">
											<select CommonCombo="FITYN">적합여부
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
						<jsp:param name="authCd" value="2" />
						<jsp:param name="showAuthCd" value="1,2,3,9,10" />
					</jsp:include>
                </div>
            </div>
             --%>
        </div>
    </div>
</div>
<!-- // content -->
<%@ include file="/common/include/webdek/bottom.jsp" %>
</body>
</html>