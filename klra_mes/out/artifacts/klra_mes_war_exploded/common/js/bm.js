$('head').append('<link rel="stylesheet" href="/common/theme/webdek/css/bm.css" type="text/css" />');
	$(document).keydown(function(e){
		if(e.ctrlKey){
			bm.fnOpenSapLog(e.keyCode);
		}
	});
var bm = {
		//화면별 버튼 권한 (DB로 관리해도됨)
		MENU_BTN_AUTH : {
			GCLC : 
				[                                     
				 {MENUID : 'BM1402', MENUGID : 'ALL', AUTH : [{OPER_TRNS:'visible,true'}] }, // KEY -> 버튼 ID값, VALUE -> 속성명,값
				 {MENUID : 'BM1402', MENUGID : 'Admin', AUTH : [{OPER_TRNS:'visible,true'}] },
				 {MENUID : 'BM1402', MENUGID : 'SuperUser', AUTH : [{OPER_TRNS:'visible,true'}] },
				 {MENUID : 'BM1402', MENUGID : 'OTHER', AUTH : [{OPER_TRNS:'remove,true'}] } // 위 권한그룹 사용자 외 사용자의 버튼 권한
				]
			,
			GCCL : []
		},
		/***********************************************************************************
		 * 버튼 권한
		 ***********************************************************************************/
		setButtonAuth : function(coCd,menuId,menugid) {
			var menuAuthList = this.MENU_BTN_AUTH[coCd];
			var menuAuth;
			var auth = [];
			var menuflag = false;
			
			if ( menuAuthList && menuAuthList.length > 0 ) {
				menuAuth = menuAuthList.filter(function(r, i){
					return r['MENUID'] == menuId
				});
				
				if ( menuAuth && menuAuth.length > 0) {
					var roopflag = true;
					menuAuth.forEach(function(r,i){
						if ( roopflag ) {
							if ( r['MENUGID'] == menugid ) {
								auth = [r];
								roopflag = false;
							} else {
								if ( menuAuth.length == (i+1) ) {
									auth = menuAuth.filter(function(w,s){
										return w['MENUGID'] == 'OTHER';
									});
								}
							}
						}
					});
				}
				console.log(auth);
				if ( auth && auth.length > 0 ) {
					var dtlAuth = auth[0];
					var attrArr;
					dtlAuth['AUTH'].forEach(function(r, i){
						$.each(r, function(btnId, attrs){
							attrArr = attrs.split(',');
							if ( attrArr.length > 0 ) {
								var btnObj = $("#"+btnId);
								switch (attrArr[0]) {
									case 'visible' :
										if ( Boolean(attrArr[1]) ) {
											btnObj.show();
										} else {
											btnObj.hide();
										}
										break;
									case 'remove' :
										btnObj.remove();
										break;
								}
							}  
						})
					});
				}
			}
		},
		/***********************************************************************************
		 * 삭제 예정 START
		 ***********************************************************************************/
		createYearCombo : function() {
			var nowYear = new Date().getFullYear();
			
			var innerHtml = "";
			
			for (var i = 0 ; i < 10; i++) {
				innerHtml += "<option value='" + (nowYear - i) + "'>" + (nowYear - i) + "</option>";
			}
			
			return innerHtml;
		},
		/***********************************************************************************
		 * 삭제 예정 END
		 ***********************************************************************************/
		
		/***********************************************************************************
		 * 팝업 호출
		 ***********************************************************************************/
		openBmPop : function(module, pageName, param, option) {
			/* module : module 구분
			 * pageName : 호출할 팝업화면
			 * param : rowData
			 * 		   colId -- 리턴받을 컬럼 			
			 * return : data
			 * callBack : linkPopCloseEvent(data)
			 * option : {
			 *            callback : "linkPopCloseEvent",
			 *            height : 600,
			 *            width : 900,
			 *            resizble : yes
			 *          }
			*/
			//default option 
			var sOption = {
				callback : "linkPopCloseEvent",
				height : 600,
				width : 900,
				resizable : 'yes'
			}
			
			var url = "/"+module+"/BM/BMPOP/"+pageName+".page";
			
			if ( option instanceof Object ) $.extend(sOption, option); // option set
			if ( param == undefined || param == null ) param = new DataMap();
			if ( option && option['addUrl'] ) url = url + option.addUrl; 
			//콜백 set 
			param.put("callbackFunc", sOption.callback);
			// option set
			param.putObject(sOption);
			page.linkPopOpen(url, param, "height="+sOption.height + ",width="+sOption.width + ",resizable="+sOption.resizable);
			return '';
		},
		/***********************************************************************************
		 * 팝업 호출 END 
		 ***********************************************************************************/
		
		/******************************************************************
		 * GCIM <- SAP 거래처정보 I/F
		 * param  : 사업자번호
		 * return : SAP 거래처정보
		 *******************************************************************/
		callback : '',
		callSapClntInfo : function(bzno, callback) {
			if ( commonUtil.isEmpty(bzno) ) { // 사업자번호가 없는 경우
				commonUtil.msgBox("BM_NO_CLNT_CRN");
				return;
			}
			if ( !commonUtil.isEmpty(callback) ) bm.callback = callback;
			var param = new DataMap();
		    param.put("CRN", bzno);//사업자번호
		    //RFC CALL /* SAP 거래처정보 조회 */
		    netUtil.send({
		          url : "/GCCL/BM/BmRfc/json/rfcClntSapInfo.data",
		          param:param,
		          sendType: "list",
		          successFunction : "rfcClntSapInfoCallback"
		    });
		     
		    rfcClntSapInfoCallback = function(json) {
		    	if ( json.data ) {
		    		if ( json.data.length > 0 ) {
		    			//I_KOART
		    			var row = json.data[0];
		    			if(row.CODE == -1){
		    				commonUtil.msgBox(row.MSG);
		    			} else if ( json.data.length == 1 ) {
		    				// 단건의 경우 update 진행
		    				bm.updateClntSapInfo(json.data);
		    			} else {
		    				
		    				var dClintArr = []; // 매출처 D
		    				var kClintArr = []; // 매입처 K
		    				
		    				$.each(json.data, function(i, r){
		    					if ( 'D' == r.KOART ) {
		    						dClintArr.push(r);
		    					} else if ( 'K' == r.KOART ) {
		    						kClintArr.push(r);
		    					}
		    				});
		    				
		    				//매출처, 매입처가 각각 1건 이하 인 경우 update 진행
		    				if ( dClintArr.length < 2 && kClintArr < 2 ) {
		    					bm.updateClntSapInfo(json.data);
		    				} else {
		    					// 그외 매출처 또는 매입처가 복수인 경우 팝업 호출
		    					var param = new DataMap();
			    				param.put("dClintArr", dClintArr);
			    				param.put("kClintArr", kClintArr);
			    				// 복수의 경우
			    				bm.openBmPop("GCCL","BM_SAP_CLNT_INFO", param, {width:1300, height:450 , callback:"bm.callbackExec"})
		    				}
		    			}
		    		} else {
		    			//거래처가 없습니다.
		    			commonUtil.msgBox("BM_NO_SRCH_SAP_CLNT");
		    		}
		    	}
		    }
		},
		sapClntPopCallback : function(jsonList) {
			if ( jsonList ) {
				// 수정
				bm.updateClntSapInfo(jsonList);
			}
		},
		updateClntSapInfo : function(sapClntInfoList) {
			// 단건의 경우
		    if ( sapClntInfoList.length == 1 && !commonUtil.isEmpty(sapClntInfoList[0]['MESSAGE']) ) {
			    alert(sapClntInfo['MESSAGE']);
			    return;
		    }
		   
		    //수정여부
		    if ( commonUtil.msgConfirm("BM_UPT_SAP_CD_CF") ) {
		    	
		    	var param = new DataMap();
		    	
		    	param.put("SAP_INFO_LIST", sapClntInfoList );
		    	/*param.put("CLNT_NM", sapClntInfo['NAME1']) // 거래처이름
		    	param.put("ADDR", sapClntInfo['ORT01']) // 주소
		    	param.put("SAP_BILG_CLNT_CD", sapClntInfo['PARTNER']) // SAP매출거래처코드
		    	param.put("CRN", sapClntInfo['STCD2']) // 사업자등록번호
*/		    	//J_1KFREPRE 담당자
		    	
		    	//운송주체 리스트 조회 
				var res = netUtil.sendData({
					url : "/GCCL/BM/Bm1201/json/updateClntSapInfo.data",
					param : param,
		         });
				
				if ( res.data && res.data > 0) {
		    		//완료 message
			    	commonUtil.msgBox("SYSTEM_UPDATEOK");
			    	if ( !commonUtil.isEmpty(bm.callback) ) {
			    		console.log(sapClntInfoList);
						//부모창의 함수를 실행
						eval(bm.callback)(sapClntInfoList);
					}
		    	} else {
		    		commonUtil.msgBox("BM_NO_UPDATE_BRKDWN");
		    	}
		    }
		},
		callbackExec : function(obj) {
			if ( !commonUtil.isEmpty(bm.callback) ) {
				//부모창의 함수를 실행
				eval(bm.callback)(obj);
			}
		},
		/******************************************************************
		 * SAP 거래처정보 UPDATE 끝
		 *******************************************************************/
		
		/***********************************************************************************
		 * 견적 조회 그리드 Temp
		 ***********************************************************************************/
		estGrdFormTemp : { 
			        //일반 견적 조회
				    1 : "<td GH='50' GCol='rownum'>1</td>"
					+"<td GH='50' GCol='rowCheck'></td>"
					+"<td GH='150 STD_EST_NO' GCol='text,EST_NO2' style='color:blue; cursor:pointer;'></td> <!-- 견적번호 --> "
					+"<td GH='75' GCol='text,EST_DT' GF='C'></td> <!-- 견적일자 --> "
					+"<td GH='100 STD_PRGR_ST' GCol='text,PRGR_ST_NM'></td> <!-- 진행상태 --> "
					+"<td GH='75 STD_CNCS_DT' GCol='text,EST_CNCS_DT' GF='C'></td> <!-- 체결일자 --> "
					+"<td GH='100' GCol='text,EST_AVLB_END_DT' GF='C'></td> <!-- 견적유효종료일자 --> "
					+"<td GH='100 STD_EST_KND' GCol='text,EST_KND_NM'></td> <!-- 견적종류 --> "
					+"<td GH='100' GCol='text,CLNT_CD'></td> <!-- 거래처코드 --> "
					+"<td GH='100' GCol='text,CLNT_NM'></td> <!-- 거래처이름 --> "
					+"<td GH='100 STD_CLNT_MNG' GCol='text,CLNT_MNG_NM'></td> <!-- 거래처담당자이름 --> "
					+"<td GH='100' GCol='text,CTRT_YN'  style='text-align:center'></td> <!-- 계약여부  --> "
					+"<td GH='100' GCol='text,TRS_PM_YN'  style='text-align:center'></td> <!-- PM이관여부  --> "
					+"<td GH='100' GCol='text,FINAL_DCSN_YN'  style='text-align:center'></td> <!-- 최종확정여부  --> "
					+"<td GH='250 STD_CT_TERM_TITLE' GCol='text,PROJT_NM'></td> <!-- 과제명  --> "
					+"<td GH='140' GCol='text,CT_PLAN_DOC_NO'></td> <!-- 프로토콜명  --> "
					+"<td GH='100 STD_EST_DRAW_MNG' GCol='text,EST_DRAW_MNG_NM'></td> <!-- 견적작성자  --> "
					+"<td GH='100' GCol='text,MONEY'></td> <!-- 청구화폐  --> "
					+"<td GH='100' GCol='text,EST_AMT' GF='N'></td> <!-- 견적금액  --> "
					+"<td GH='100' GCol='text,VAT_YN'></td> <!-- VAT여부  --> "
					+"<td GH='100' GCol='text,UN_CNCS_NM'></td> <!-- 미체결사유명  --> "
					+"<td GH='100' GCol='text,RMK'></td> <!-- 비고  --> ",
					//견적 검토건 조회
					2 : "<td GH='50' GCol='rownum'>1</td>"
			   		+"<td GH='50' GCol='rowCheck'></td>"
			   		+"<td GH='60' GCol='text,EXMN_ST'></td>"
			   		+"<td GH='60 STD_EXMN_GB' GCol='text,EXMN_GB_NM'></td>"
			   		+"<td GH='150 STD_EST_NO' GCol='text,EST_NO2' style='color:blue; cursor:pointer;'></td> <!-- 견적번호 --> "
			   		+"<td GH='75' GCol='text,EST_DT' GF='C'></td> <!-- 견적일자 --> "
			   		+"<td GH='100 STD_PRGR_ST' GCol='text,PRGR_ST_NM'></td> <!-- 진행상태 --> "
			   		+"<td GH='75 STD_CNCS_DT' GCol='text,EST_CNCS_DT' GF='C'></td> <!-- 체결일자 --> "
			   		+"<td GH='100' GCol='text,EST_AVLB_END_DT' GF='C'></td> <!-- 견적유효종료일자 --> "
			   		+"<td GH='100 STD_EST_KND' GCol='text,EST_KND_NM'></td> <!-- 견적종류 --> "
			   		+"<td GH='100' GCol='text,CLNT_CD'></td> <!-- 거래처코드 --> "
			   		+"<td GH='100' GCol='text,CLNT_NM'></td> <!-- 거래처이름 --> "
			   		+"<td GH='100 STD_CLNT_MNG' GCol='text,CLNT_MNG_NM'></td> <!-- 거래처담당자이름 --> "
			   		+"<td GH='100' GCol='text,CTRT_YN' style='text-align:center'></td> <!-- 계약여부  --> "
			   		+"<td GH='100' GCol='text,TRS_PM_YN'  style='text-align:center'></td> <!-- PM이관여부  --> "
			   		+"<td GH='100' GCol='text,FINAL_DCSN_YN'  style='text-align:center'></td> <!-- 최종확정여부  --> "
			   		+"<td GH='250 STD_CT_TERM_TITLE' GCol='text,PROJT_NM'></td> <!-- 과제명  --> "
			   		+"<td GH='140' GCol='text,CT_PLAN_DOC_NO'></td> <!-- 프로토콜명  --> "
			   		+"<td GH='100 STD_EST_DRAW_MNG' GCol='text,EST_DRAW_MNG_NM'></td> <!-- 견적작성자  --> "
			   		+"<td GH='100' GCol='text,MONEY'></td> <!-- 청구화폐  --> "
			   		+"<td GH='100' GCol='text,EST_AMT' GF='N'></td> <!-- 견적금액  --> "
			   		+"<td GH='100' GCol='text,VAT_YN'></td> <!-- VAT여부  --> "
			   		+"<td GH='100' GCol='text,UN_CNCS_NM'></td> <!-- 미체결사유명  --> "
			   		+"<td GH='100' GCol='text,RMK'></td> <!-- 비고  --> ",
			   		//견적 결재건 조회       
			   		3 : "<td GH='50' GCol='rownum'>1</td>"
			   		+"<td GH='50' GCol='rowCheck'></td>"
			   		+"<td GH='60 STD_SANC_ST' GCol='text,SANC_ST_NM'></td><!-- 결재상태 -->" 
			   		+"<td GH='150 STD_EST_NO' GCol='text,EST_NO2' style='color:blue; cursor:pointer;'></td> <!-- 견적번호 --> "
			   		+"<td GH='75' GCol='text,EST_DT' GF='C'></td> <!-- 견적일자 --> "
			   		+"<td GH='100 STD_PRGR_ST' GCol='text,PRGR_ST_NM'></td> <!-- 진행상태 --> "
			   		+"<td GH='75 STD_CNCS_DT' GCol='text,EST_CNCS_DT' GF='C'></td> <!-- 체결일자 --> "
			   		+"<td GH='100' GCol='text,EST_AVLB_END_DT' GF='C'></td> <!-- 견적유효종료일자 --> "
			   		+"<td GH='100 STD_EST_KND' GCol='text,EST_KND_NM'></td> <!-- 견적종류 --> "
			   		+"<td GH='100' GCol='text,CLNT_CD'></td> <!-- 거래처코드 --> "
			   		+"<td GH='100' GCol='text,CLNT_NM'></td> <!-- 거래처이름 --> "
			   		+"<td GH='100 STD_CLNT_MNG' GCol='text,CLNT_MNG_NM'></td> <!-- 거래처담당자이름 --> "
			   		+"<td GH='100' GCol='text,CTRT_YN'  style='text-align:center'></td> <!-- 계약여부  --> "
			   		+"<td GH='100' GCol='text,TRS_PM_YN'  style='text-align:center'></td> <!-- PM이관여부  --> "
			   		+"<td GH='100' GCol='text,FINAL_DCSN_YN'  style='text-align:center'></td> <!-- 최종확정여부  --> "
			   		+"<td GH='250' GCol='text,PROJT_NM'></td> <!-- 과제명  --> "
			   		+"<td GH='140' GCol='text,CT_PLAN_DOC_NO'></td> <!-- 과제명  --> "
			   		+"<td GH='100 STD_EST_DRAW_MNG' GCol='text,EST_DRAW_MNG_NM'></td> <!-- 견적작성자  --> "
			   		+"<td GH='100' GCol='text,MONEY'></td> <!-- 청구화폐  --> "
			   		+"<td GH='100' GCol='text,EST_AMT' GF='N'></td> <!-- 견적금액  --> "
			   		+"<td GH='100' GCol='text,VAT_YN'></td> <!-- VAT여부  --> "
			   		+"<td GH='100' GCol='text,UN_CNCS_NM'></td> <!-- 미체결사유명  --> "
			   		+"<td GH='100' GCol='text,RMK'></td> <!-- 비고  --> "
				},
		/***********************************************************************************
		 * 숫자 천자리(3)마다 , 표시
		 * @param {String} x
		 * @returns {String} 
		 ***********************************************************************************/		
		comma : function (x) {
			return x.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
		}
				
		,rsltsDtSet : function(obj) {
			var stdDt = 6; 					// 기준일자
			var date = new Date();
			var yy = date.getFullYear(); 	//현재년
			var mm = date.getMonth()+1;		//현재월
			var dd = date.getDate();		//현재일
			
			/* date set */
			if(dd<10){
				dd = "0"+dd.toString();
			}
			
			var preMm = (mm-1).toString();				// 전달의 1일
			var preYy = (yy-1).toString();				// 전년도
			
			/*Month set*/
			if(Number(preMm)<10){
				preMm = "0"+preMm;
			}
			if(mm<10){
				mm = "0"+mm;
			}
			
			/*날짜세팅*/
			var toDay = yy.toString() + mm.toString() + dd;			// 현재날
			var toDayOne = yy.toString() + mm.toString() + "01";	// 현재달 1일
			var preDay = yy.toString() + preMm + "01";				// 전달 1일
			var preDate = preYy + "1201";							// 전년도의 12/1
			
			inputList.resetRange(obj);
			var rangeDataArray = new Array();
	        var rangeDataMap = new DataMap();
	        
			if(dd > stdDt){ //오늘이 기준일보다 크면 해당월의 1~현재일로 설정
				var fromDate = toDayOne;
				var toDate = toDay;
				
				rangeDataMap.put(configData.INPUT_RANGE_RANGE_FROM,fromDate);
		        rangeDataMap.put(configData.INPUT_RANGE_RANGE_TO,toDate);
		        rangeDataArray.push(rangeDataMap);
		        inputList.setRangeData(obj, configData.INPUT_RANGE_TYPE_RANGE,rangeDataArray);
			}
			//오늘이 기준일보다 작으면 전달의 1~현재일로 설정
			else{ 
				var fromDate = "";
				
				if(mm == 1){	// 현재달이 1월일경우 전년도 12월로 세팅한다.
					fromDate = preDate;
				}
				else{
					fromDate = preDay;
				}
				
				var toDate = yy.toString()+ mm.toString()+ dd.toString();
				
				rangeDataMap.put(configData.INPUT_RANGE_RANGE_FROM,fromDate);
		        rangeDataMap.put(configData.INPUT_RANGE_RANGE_TO,toDate);
		        rangeDataArray.push(rangeDataMap);
		        inputList.setRangeData(obj, configData.INPUT_RANGE_TYPE_RANGE,rangeDataArray);
			}
		},
		//영역 비활성화
		/**
		 * areaId : Node id            ex) 'gridList01'
		 * flag : 비활성화/활성화 여부   ex) true / false    
		 * gridYn : 그리드여부          ex) true / false  
		 */
		setAreaDisable : function (areaId, flag, gridYn) {
			if( typeof flag != "boolean") flag = true;
			if( typeof gridYn != "boolean") gridYn = false;
			
			var compList = gridYn ? ['td', 'input', 'select', 'button' , 'checkbox', 'label'] : ['input', 'select', 'button', 'checkbox', 'label'];
			var areaObj = $("#"+areaId);
			
			for (var i=0; i<compList.length; i++) {
				var inputList = areaObj.find(compList[i]);
				
				$.each(inputList, function(index,obj){
					if ( flag ) {
						$(obj).addClass('disabledArea');
					} else {
						$(obj).removeClass('disabledArea');
					}
				});
			}
		}
		/* 전표 구분 변경  */
		, fn_slipGbChange : function(gridId,rowNum,row,colName){
			var list = gridList.getGridData(gridId);
			var certiColName = "CERTI_NO";
			for(var i=0; i < list.length; i ++){
				var rowData = list[i];
				if(rowData.get("SLIP_GB_NO") == row.get("SLIP_GB_NO") && rowData.get("GRowNum") != row.get("GRowNum")){
					if(rowData.get("CURR_GB_CD") != row.get("CURR_GB_CD")){//통화 구분 코드
						console.log(rowData.get("CURR_GB_CD") + " != " + row.get("CURR_GB_CD"));
						commonUtil.msgBox("BM_SLIP_GB_CHG",uiList.getLabel("STD_CURR_CD"));
						return true;
					}
					else if(rowData.get("CURR_CD") != row.get("CURR_CD")){//통화 코드
						console.log(rowData.get("CURR_CD") + " != " + row.get("CURR_CD"));
						commonUtil.msgBox("BM_SLIP_GB_CHG",uiList.getLabel("STD_CURR_CD"));
						return true;
					}
					else if(rowData.get("TAXN_GB_CD") != row.get("TAXN_GB_CD")){//부가세 코드
						console.log(rowData.get("TAXN_GB_CD") + " != " + row.get("TAXN_GB_CD"));
						commonUtil.msgBox("BM_SLIP_GB_CHG",uiList.getLabel("STD_TAXN_GB"));
						return true;TAXN_GB_CD
					}
					else if(rowData.get(certiColName) != row.get(certiColName)){//거래명세서 번호
						console.log(rowData.get(certiColName) + " != " + row.get(certiColName));
						commonUtil.msgBox("BM_SLIP_GB_CHG",uiList.getLabel("STD_CERTI_NO"));
						return true;
					}
				}
			}
			return false;
		}
		/*같은 거래명세서 벊호 일괄 변경*/
		, fn_certiAllchage : function(gridId, rowNum, colName, certiNo, colValue){
			var list = gridList.getGridData(gridId);
			if(commonUtil.isNotEmpty(certiNo)){
				for(var i = 0; i < list.length; i++){
					var row = list[i];
					if(row.get("CERTI_NO") == certiNo || row.get("PCHS_CERTI_NO") == certiNo){
						gridList.setColValue(gridId, i, colName, colValue, true);
					}
				}
			}else{
				gridList.setColValue(gridId, rowNum, colName, colValue, true);
			}
		}
		/*전표 구분 거래명세서가 다른 같은 번호에 전표 번호가 있는지 체크*/
		, fn_slipGBCnt : function(gridId,No,certiNo){
			var list = gridList.getGridData(gridId);
			for(var i = 0; i < list.length; i++){
				var row = list[i];
				if(row.get("SLIP_GB_NO") == No && (row.get("CERTI_NO") != certiNo || row.get("PCHS_CERTI_NO") != certiNo)){
					return row;
				}
				break;
			}
			return "";
		}
		
		/***********************************************************************************
		 * 그리드 컬럼 width 설정
		 * @param {String} gridId  : 그리드ID
		 * @param {String} colName : 컬럼명
		 * @param {String} width   : 넓이
		 ***********************************************************************************/	
		, setGridColWidth : function(gridId, colName, width) {
			var gridBox = gridList.getGridBox(gridId);
			
			var list = gridBox.visibleLayOutData.split(configData.DATA_ROW_SEPARATOR);
			var visibleLayOutData;
			var cols;
			var modifyFlg = false;
			for(var i = 0; i < list.length; i++){
				cols = list[i].split(configData.DATA_COL_SEPARATOR);
				if(cols[0] == colName){
					cols[1] = width;
					list[i] = cols.join(configData.DATA_COL_SEPARATOR);
					visibleLayOutData = list.join(configData.DATA_ROW_SEPARATOR);
					
					modifyFlg = true;
					break;
				}
			}
			
			if (modifyFlg) {
				gridBox.visibleLayOutData = visibleLayOutData;
				gridBox.setLayout(false);
			}
		}
		
		, fnOpenSapLog : function(key){
			if(key == 113){
				var url = "/GCLC/BM/BMPOP/BMSAPLOG.page";
				page.linkPopOpen(url, "", "height=950,width=1300");
			}else if(key == 114){
				var url = "/GCCL/BM/BM20/BMAPI2.page";
				page.linkPopOpen(url, "", "height=950,width=1300");
			}
		}
		
		/***********************************************************************************
		 * 그리드 View 컬럼 숨김
		 * @param {String} gridId : 그리드id
		 * @param {Array} colName : 컬럼명
		 ***********************************************************************************/
		
		, hideGridViewCol : function(gridId, colName) {
			var gridBox = gridList.getGridBox(gridId);
			
			var list = gridBox.visibleLayOutData.split(configData.DATA_ROW_SEPARATOR);
			var visibleLayOutData;
			var cols;
			var modifyFlg = false;
			
			for(var i = 0; i < list.length; i++){
				cols = list[i].split(configData.DATA_COL_SEPARATOR);
				if(cols[0] == colName){
					list.splice(i, 1);
					visibleLayOutData = list.join(configData.DATA_ROW_SEPARATOR);
					
					modifyFlg = true;
					break;
				}
			}
			
			if (modifyFlg) {
				gridBox.visibleLayOutData = visibleLayOutData;
				gridBox.setLayout(false);
			}
		}
		
		/***********************************************************************************
		 * 그리드 View 컬럼 초기 설정값으로 변경
		 * @param {String} gridId
		 ***********************************************************************************/	
		, setDefaultGridViewCol : function(gridId) {
			var gridBox = gridList.getGridBox(gridId);
			var defaultLayOutData = gridBox.defaultLayOutData;
			
			gridBox.visibleLayOutData = defaultLayOutData;
		}
		
		, callSapClntInfoAll : function() {
			var param = new DataMap();
		    //RFC CALL /* SAP 거래처정보 조회 */
		    netUtil.send({
		    	  //ALL
	        	  url : "/GCCL/BM/BmRfc/json/clntSapInfoAll.data",
		          param:param,
		          sendType: "list"
		    });
		}
}
