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
                url : "/mes/Quality/QLT11/json/datalist.data",
                bigdata : false,
                colorType : true
            })

            gridList.setGrid({
                id : "gridList2",
                url : "/mes/Quality/QLT11/json/datalist.data",
                bigdata : false,
                colHoldType : true,
                colHold : "BIG_CAT_NM,MID_CAT_NM,INSP_ITEM_CD,INSP_ITEM_NM",
                colGroupCols : "BIG_CAT_NM,MID_CAT_NM"
            })
            $("#WERKS").val('P100');
            document.getElementById('FNL_JDGM').selectedIndex = '1';
        });

        function searchList(){
        	var param = inputList.setRangeParam("searchArea");
    		
    		param.put("P_TYPE", "LIST");
    		
    		gridList.gridList({
    	    	id : "gridList",
    	    	param : param
    	    });
    		
    		gridList.resetGrid("gridList2");
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
        
        const gridListEventDataBindEnd = (gridId, dataLength) => {
    		if(gridId == "gridList"){
    			var list = gridList.getGridData(gridId);
    			
    			for(var i = 0; i < list.length; i++){
    				var INSP_YN = list[i].get("INSP_YN");
    				
    				if(INSP_YN == "Y"){
    					gridList.setRowReadOnly(gridId, i, true, ["UCFMTY_AMT"]);
    				}
    			}
    		} else if(gridId == "gridList2"){
    			var list = gridList.getGridData(gridId);
    			
    			for(var i = 0; i < list.length; i++){
    				const INPT_TYP = list[i].get("INPT_TYP"); 	// 입력타입(숫자, 문자, 문자열)
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
    			
    			colNum = rowNum
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
	        			if(rowData[i].get("MATNR") != rowData[i-1].get("MATNR")){
	        				alert("서로 다른 자재코드는 반제품 품질검사를 진행할 수 없습니다.");
	        				gridList.setRowState(gridId, configData.GRID_ROW_STATE_READ, rowNum);
	        				gridList.setRowCheck(gridId, rowNum, false);
	        				gridList.setColValue(gridId, rowNum,"UCFMTY_AMT", "");
	        				return;
	        			}
        			}
        		}
    			
    			if(colName == "UCFMTY_AMT"){
    				var rcvgdsqty = gridList.getColData(gridId, rowNum, "RCVGDS_QTY");
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
    				} else{0
    					gridList.setColValue(gridId, rowNum, "FIT_YN", "N");
    				}
    				
    				if(flag == true){
    					if(colValue.indexOf('.') > 0){
   							if(INPT_MTD == "9.99"){
	   	  						if(value_length > 99){
	   	  							gridList.setColValue(gridId, rowNum, colName, "");
	   	  							alert("소숫점 2자리까지 입력할 수 있습니다.");
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
        	
        	var rowData = gridList.getSelectData("gridList");
    		
    		if(rowData.length == 0){
    			alert("자재를 선택하세요.");
    			return;
    		} 
    		
    		for(var i = 0; i < rowData.length; i++){
    			if(i >= 1){
        			if(rowData[i].get("MATNR") != rowData[i-1].get("MATNR")){
        				alert("서로 다른 자재코드는 반제품 품질검사를 진행할 수 없습니다.");
        				return;
        			}
    			}
    			
    			// 2022-10-16(일요일) 안상현, 반제품검사 기준값이 등록되지 않았을 경우 validation 체크
    			if(rowData[i].get("CHK_CNT") === "0"){
    				alert("반제품검사 기준값이 등록되지 않은 행이 존재합니다. \n기준값을 등록하세요.")
    				return
    			}
    			
    			if(rowData[i].get("INSP_YN") == "Y"){
    				alert("이미 검사 판정을 완료한 건이 있습니다.");
    				return;
    			} else if(rowData[i].get("UCFMTY_AMT") == " " || rowData[i].get("UCFMTY_AMT") == "0"){
    				if($("#FNL_JDGM").val() == "FAIL"){
    					alert("최종판정을 부적합으로 선택하였으나 부적합량을 입력하지 않으셨습니다.");
    					return;
    				}
    			} else if(rowData[i].get("UCFMTY_AMT") != " " || rowData[i].get("UCFMTY_AMT") == "0"){
    				if($("#FNL_JDGM").val() == "PASS"){
    					alert("최종판정을 적합으로 선택하였으나 부적합량을 입력하였습니다.");
    					return;
    				}
    			}
    		}
    		
			var subListCnt = gridList.getGridDataCount("gridList2");
			var list = gridList.getGridData("gridList2");
			
			for (var i = 0; i < subListCnt; i++){
				var NECSY_YN = gridList.getColData("gridList2", i, "NECSY_YN");
				var Status = gridList.getRowStatus("gridList2", i);
				var Std_val = gridList.getColData("gridList2", i, "STD_VAL");
				var Fit_yn = gridList.getColData("gridList2", i, "FIT_YN");
				var inpt_typ = gridList.getColData("gridList2", i, "INPT_TYP");
				var std_sel = gridList.getColData("gridList2", i, "STD_SEL");
				
				if(NECSY_YN == "Y"){
					if(Status == "R" ){
						alert("필수 측정항목을 입력하지 않았습니다.");
						return;
					}
					if(inpt_typ == "숫자"){
						if(Std_val == "0"){
    						alert("해당 품목에 등록된 기준값이 없습니다.");
    						return;
    					}	
					} else if(inpt_typ == "문자"){
						if(std_sel == ""){
							alert("해당 품목에 등록된 기준선택값이 없습니다.");
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
			
        	if(gridList.validationCheck("gridList2", "all")){
    			var param = new DataMap();
    			
    			param.put("head", rowData);
    			param.put("P_TYPE", "SUB_SAVE");
    			param.put("list", list);
    			param.put("INSP_ITEM_GRP_CD", "P2");
    			param.put("FNL_JDGM", $("#FNL_JDGM").val());
    			
    			// 2022-11-01(화요일) 안상현, 선택된 처리순번
    			param.put("AN_SEQNO",gridList.getColData("gridList", colNum, "PRC_SEQNO"))
    			
		    	netUtil.send({
    				url : "/mes/Quality/QLT11/json/datalist.data",
    				param : param,
    				successFunction : "savesuccessCallBack"
    			});
    		}
        }
        
        function savesuccessCallBack(json){
        	if(json){
        		if($("#FNL_JDGM").val() == "FAIL"){
    				var param = new DataMap();
    	            
    	            param.put("IFID", "MES_IF_131");
    	            param.put("DOC_NO", json.SDOC_NO);
    	            
    	            netUtil.send({
    	            	url : "/mes/erpif/json/sendIF.data",
    	            	param : param,
    	            	successFunction : "saveSuccessCallBack2"
    	            });
    			}else{
    				commonUtil.msgBox(configData.MSG_SYSTEM_SAVEOK);
    				gridList.resetGrid("gridList2");
            		$("#SMPL_AMT").val('');
                    searchList();
    			}
       		}
        }
        
        function saveSuccessCallBack2(json){
        	if(json){
        		if(json.data == 'SUCCESS'){
        			commonUtil.msgBox(configData.MSG_SYSTEM_SAVEOK);
    				gridList.resetGrid("gridList2");
                    searchList();
        		}else {
        			alert('(SAP 재고이전) ' + json.data)
        			searchList();
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
		}
	}
	
	// 2022-08-29(월요일) 안상현, LOT번호 검색조건 추가
	const LOT = () => {
		page.linkPopOpen("/common/SEARCH_LOT.page", "", "width=1500, height=600");
	}
	
	// 2022-08-29(월요일) 안상현, 개별바코드 검색조건 추가
	const BARCODE = () => {
		page.linkPopOpen("/mes/wrk/WRK23_POP01.page", "", "height=600,width=850");
	}
	
	// 2022-10-16(일요일) 안상현, 반제품검사 기준값이 등록되지 않았을 경우, 그리드 빨간색으로 표시
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
					<input type="button" id="button-0-2" CB="Save SAVE BTN_SAVE" />
				</div>
			</div>
			<div class="search_inner">
				<div class="search_wrap ">
					<dl>
						<dt CL="STD_PLANT">플랜트</dt>
						<dd>
							<input type="text" class="input" id="WERKS" name="WERKS" readonly="readonly"/>
						</dd>
					</dl>
					<dl>
						<dt CL="STD_PRD_DATE">생산일자</dt>
						<dd><input type="text" name="W002.PRD_DT" UIInput="B" UIFORMAT="C M1"/></dd>
					</dl>
					<dl>
                        <dt CL="STD_MATNR">자재코드</dt>
                        <dd><input type="text" name="W002.MATNR" UIInput="SR,MATKY" UIFormat="U"/></dd>
                    </dl>
                    <!-- 2022-08-29(금요일) 안상현, LOT번호 검색조건 추가 -->
                    <dl>
						<dt CL="STD_LOT_NO">LOT번호</dt>
						<dd style="font-size: 0">					
							<input type="text" class="input" id="LOT_NO" name="LOT_NO" UIInput="SR,LOTNO" UIFormat="U"/>
							<!-- <button type="button" class="btn btn_search" onclick="LOT()">
								<span>search</span>
							</button> -->
						</dd>
					</dl>
					<!-- 2022-08-29(금요일) 안상현, 개별바코드 검색조건 추가 -->
					<dl>
						<dt CL="STD_IND_BCD">개별바코드</dt>
						<dd style="font-size: 0">
							<input type="text" class="input" id="IND_BCD" name="IND_BCD" UIInput="SR,INDBCD" UIFormat="U"/>
							<!-- <button type="button" class="btn btn_search" onclick="BARCODE()">
								<span>search</span>
							</button> -->
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
					<li><a href="#tab1-1"><span CL="STD_GRD_QLT11_1">판정이력</span></a></li>
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
	                                    <td GH="100" GCol="text,PRC_DIV_NM">처리구분(명)</td>
										<td GH="100" GCol="text,WERKS" style="text-align:center;">플랜트</td>
										<td GH="0" GCol="text,PLANTNM">플랜트(명)</td>
										<td GH="100" GCol="text,PRD_DT" style="text-align:center;" GF="D">생산일자</td>
										<td GH="140" GCol="text,MATNR" style="text-align:center;">자재코드</td>
										<td GH="320" GCol="text,MATNR_NM">품목코드명</td>
										<td GH="100" GCol="text,LOT_NO">LOT번호</td>
	                                    <td GH="120" GCol="text,IND_BCD">개별바코드</td>
	                                    <td GH="0" GCol="text,MACH_CD" style="text-align:center;">설비</td>
	                                    <td GH="0" GCol="text,MACH_NM">설비(명)</td>
	                                    <td GH="0" GCol="text,WRK_CLASS">반</td>
	                                    <td GH="0" GCol="text,PCODE" style="text-align:center;">지종코드</td>
	                                    <td GH="0" GCol="text,PCODE_NM">지종명</td>
	                                    <td GH="0" GCol="text,BS_WGT" GF="N 9,3">평량</td>
	                                    <td GH="0" GCol="text,PRDTYPE">생산라인</td>
	                                    <td GH="0" GCol="text,PRDTYPETXT">생산라인명</td>
	                                    <td GH="0" GCol="text,MACHINE">생산호기</td>
	                                    <td GH="0" GCol="text,MACHINETXT">생산호기명</td>
	                                    <td GH="0" GCol="text,RSPEED" GF="N 5,1">선속</td>
	                                    <td GH="0" GCol="text,PRFM_DT" style="text-align:center;" GF="D">실적일자</td>
	                                    <td GH="0" GCol="text,STR_TM" style="text-align:center;" GF="T">시작시간</td>
	                                    <td GH="0" GCol="text,END_TM" style="text-align:center;" GF="T">종료시간</td>
	                                    <td GH="0" GCol="text,TM" style="text-align:center;" GF="T">가동시간</td>
	                                    <td GH="0" GCol="text,JROLLCNT" GF="N 6,0">J/R권치수</td>
	                                    <td GH="100" GCol="text,PRFM_QTY" GF="N 13,3">실적량</td>
	                                    <td GH="0" GCol="text,ROUTE">항차</td>
	                                    <td GH="0" GCol="text,ORDER_RMK">오더비고</td>
	                                    <td GH="0" GCol="text,ORDER_NO">오더번호</td>
										<td GH="0" GCol="text,ORDER_SEQNO">오더순번</td>
										<td GH="0" GCol="text,WRK_ORDR_NO">작업지시번호</td>
										<td GH="0" GCol="text,WRK_ORDR_SEQNO">작업지시번호순번</td>
										<td GH="100" GCol="text,UNIT" style="text-align:center;">단위</td>
										<td GH="100" GCol="text,UNIT_NM">단위(명)</td>
										<td GH="0" GCol="text,STA">상태</td>
										<td GH="0" GCol="text,SDOC_NO">SAP 확정문서번호</td>
	                                    <td GH="0" GCol="text,DOC_NO">MES문서번호</td>
	                                    <td GH="0" GCol="text,DOC_SEQNO">MES문서순번</td>
	                                    <td GH="100" GCol="input,UCFMTY_AMT" GF="N 13">부적합량</td>
	                                    <td GH="0" GCol="text,INSP_YN">검사여부(Y/N)</td>
	                                    <td GH="0" GCol="text,INSP_ITEM_GRP_CD" style="text-align:center;">검사항목그룹코드</td>
	                                    <td GH="0" GCol="text,MSRM_DATE" style="text-align:center;">측정일시</td>
	                                    <td GH="0" GCol="text,PRC_SEQNO" style="text-align:right;">처리순번</td>
	                                    <td GH="0" GCol="text,UCFMTY_YN">부적합 결과 여부</td>
	                                    <td GH="0" GCol="text,REGDATE" style="text-align:center;">등록일시</td>
										<td GH="0" GCol="text,REGNM">등록자</td>
										<td GH="0" GCol="text,UPDDATE" style="text-align:center;">수정일시</td>
										<td GH="0" GCol="text,UPDNM">수정자</td>
										<td GH="0" GCol="text,CHK_CNT">반제품검사 기준값 등록 여부</td>
									</tr>
								</tbody>
							</table>
						</div>
					</div>
					<jsp:include page="/WEB-INF/jsp/common/commonBtnAuth.jsp">
                    	<jsp:param value="1" name="authCd"/>
                    	<jsp:param value="1,2,3,7,9,10" name="showAuthCd"/>
                    </jsp:include>				
				</div>
			</div>
			<div class="content_layout tabs bottom_layout">
				<ul class="tab tab_style02">
					<li><a href="#tab1-1"><span CL="STD_GRD_QLT11_2">검사항목</span></a></li>
					<dt></dt>
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
	                                    <td GH="0" GCol="text,INSP_ITEM_CD" style="text-align:center;">검사항목코드</td>
										<td GH="140" GCol="text,INSP_ITEM_NM">검사항목명</td>
										<td GH="0" GCol="text,INSP_ITEM_GRP_CD" style="text-align:center;">검사항목그룹코드</td>
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
										<td GH="80" GCol="input,RST_VAL" style="text-align:right;">측정값</td>
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
                    	<jsp:param value="2" name="authCd"/>
                    	<jsp:param value="1,2,3,9,10" name="showAuthCd"/>
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