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
		var message = '';
		
        $(document).ready(function(){
        	configData.MENU_ID = "QLT05_POP01";
        	
        	let data = page.getLinkPopData();
        	dataBind.dataNameBind(data, "searchArea");
        	
        	$("#WERKS").val(data[0].get("WERKS"));
        	$("#WRK_ORDR_NO").val(data[0].get("WRK_ORDR_NO"));
    		$("#WRK_ORDR_SEQNO").val(data[0].get("WRK_ORDR_SEQNO"));
        	
            gridList.setGrid({
                id : "gridList",
                url : "/mes/Quality/QLT05_POP01/json/datalist.data",
                bigdata : false,
                colHoldType : true,
                colHold : "WERKS, LOT_NO, IND_BCD"
            })
            
            searchList();
        });

        // 조회
        function searchList(){
            var param = inputList.setRangeParam("searchArea");
            param.put("P_TYPE", "LIST");
            gridList.gridList({
                id : "gridList",
                param : param
            });
        }
        
     	// 버튼을 클릭한 경우
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
    		
    		// 판정값 체크
    		if($("#FNL_JDGM").val() === ""){
				alert("선택된 항목에 대해 판정값을 선택하시기 바랍니다.");
				$("#FNL_JDGM").focus()
				return;
			}
    		
    		// check 된 데이터 체크
    		var list = gridList.getSelectData("gridList");
    		console.log("list : "+list)
    		
			if(list.length === 0){
				alert("저장할 데이터를 선택하세요.");
				return;
			}else{
				for(let i = 0; i < list.length; i++){
					// 최종판정을 한 경우 
					if(list[i].get("FNL_JDGM") != " " && list[i].get("FNL_JDGM") != null){
						alert("최종판정을 이미 실시한 데이터가 존재합니다.")
						return
					}
				}
			}
    		
    		// 유효성 검사 및 저장하시겠습니까 알림
    		if(gridList.validationCheck("gridList", "all")){
    			var param = new DataMap();
    			
    			param.put("P_TYPE","SAVE");
    			param.put("list", list);
    			param.put("FNL_JDGM", $("#FNL_JDGM").val());
    	
    			if(!commonUtil.msgConfirm(configData.MSG_MASTER_SAVE_CONFIRM)){
    				return;
    			}
    			
    			netUtil.send({
    				url : "/mes/Quality/QLT05_POP01/json/datalist.data",
    				param : param,
    				successFunction : "saveSuccessCallBack"
    			});
    		}
    	}
    	
    	function saveSuccessCallBack(json){
    		if(json){
    			if($("#FNL_JDGM").val() == "FAIL"){
    				//SAP에 재고이전 정보 송신
					if(json.SDOC_NO != ""){
						var param = new DataMap();
						
						param.put("IFID", "MES_IF_131");
	    	            param.put("DOC_NO", json.SDOC_NO);
	    	            
	    	            var json2 = netUtil.sendData({
	    	            	url : "/mes/erpif/json/sendIF.data",
	    	            	param : param
	    	            });
	    	            
	    	            if(json2){
	    	            	if(json2.data == 'SUCCESS'){
	    	            		//alert("발송성공");
	    	            	}else{
	    	            		message = message + '(SAP 재고이전) ' + json2.data + '\n';
	    	            	}
	    	            }
					}
					if(json.WDOC_NO != ""){
						//순회 및 완제품 결과 WMS에 송신
						InterfaceSendDoc(json.WDOC_NO);
					}
    			}
    			if(message != ''){
    				alert(message);
    				message = '';
    			}else{
    				commonUtil.msgBox(configData.MSG_SYSTEM_SAVEOK);
    			}
				page.linkPopClose();
			}
        }
        
        function InterfaceSendDoc(DOCNO){
   			var ifid = "MES_IF_906";
   			
   			var json = netUtil.sendData({
   				url : "/common/api/json/"+ifid+"/send.data",
   				param : 'DOC_NO=' + DOCNO
   			});
   			
   			if(json){
   				if(json.result == 'SUCCESS'){
   					//alert("발송성공");
   				}else {
   					message = message + "검사결과 오류는 " + json.result + '\n'; 
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
							<input type="text" class="input" id="WERKS" name="WERKS" readonly />
						</dd>
					</dl>
                    <dl>
                        <dt CL="STD_WRK_ORDR_NO">작업지시번호</dt>
                        <dd>
                            <input type="text" class="input" id="WRK_ORDR_NO" name="WRK_ORDR_NO" UIFormat="U" readonly />
                        </dd>
                    </dl>
                    <dl>
                        <dt CL="STD_WRK_ORDR_SEQNO">지시순번</dt>
                        <dd>
                            <input type="text" class="input" id="WRK_ORDR_SEQNO" name="WRK_ORDR_SEQNO" UIFormat="U" readonly />
                        </dd>
                    </dl>
                    <dl>
                        <dt CL="STD_FNL_JDGM">최종판정</dt>
                        <dd>
                            <select class="input" id="FNL_JDGM" name="FNL_JDGM" CommonCombo="FNL_JDGM">
                            	<option value=""></option>
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
            <div class="content_layout tabs ">
                <ul class="tab tab_style02">
                    <li>
                    	<a href="#tab1-1">
                    		<span>완제품 현황</span>
                    	</a>
                    	<a href="#">
                    		<img src="/common/theme/webdek/images/ico_infor.png" width="15" height="15" />
                    		<span>
                    			제품입고전(3100)에 있는 완제품 재고를 표시합니다.
                    		</span>
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
                                <tbody id="gridList">
	                                <tr CGRow="true">
	                                    <td GH="40" GCol="rownum">1</td>
	                                    <td GH="40" GCol="rowCheck"></td>
	                                    <td GH="100" GCol="text,WERKS">플랜트</td>
	                                    <td GH="150" GCol="text,LOT_NO">LOT번호</td>
	                                    <td GH="150" GCol="text,IND_BCD">개별바코드</td>
	                                    <td GH="0" GCol="text,STOR_LOC_CD">저장위치코드</td>
	                                    <td GH="150" GCol="text,STOR_LOC_NM">저장위치명</td>
	                                    <td GH="150" GCol="text,MATNR">자재코드</td>
	                                    <td GH="200" GCol="text,MATNR_NM">자재명</td>
	                                    <td GH="0" GCol="text,UNIT">단위</td>
	                                    <td GH="100" GCol="text,UNIT_NM">단위명</td>
	                                    <td GH="80" GCol="text,PLT_QTY" GF="N 13,1">실적수량</td>
	                                    <td GH="80" GCol="text,BOX_QTY" GF="N 13,0">박스수량</td>
	                                    <td GH="80" GCol="text,BAG_QTY" GF="N 13,0">백수량</td>
	                                    <td GH="80" GCol="text,EA_QTY" GF="N 13,0">개수량</td>
	                                    <td GH="100" GCol="text,PRFM_DT" GF="D" style="text-align:center;">실적일자</td>
	                                    <td GH="80" GCol="text,STCK_QTY" GF="N 13,3">재고수량</td>
	                                    <td GH="0" GCol="text,STCK_STA">재고상태</td>
	                                    <td GH="100" GCol="text,REQ_STA_NM">생산출고여부</td>
	                                    <td GH="100" GCol="text,STCK_STA_NM">재고상태(명)</td>
	                                    <td GH="0" GCol="text,FNL_JDGM">최종판정</td>
	                                    <td GH="100" GCol="text,FNL_JDGM_NM">최종판정(명)</td>
	                                    <td GH="150" GCol="text,MSRM_DATE" style="text-align:center;">검사일자</td>
	                                    <td GH="0" GCol="text,PRC_SEQNO">검사순번</td>
	                                    <td GH="100" GCol="text,INSPR_NM">검사자</td>
	                                    <td GH="0" GCol="text,STCK_KY">WMS저장키</td>
	                                    <td GH="0" GCol="text,LOT_NUM">WMS LOT_NO</td>
	                                </tr>
                                </tbody>
                            </table>
                        </div>
                    </div>
                    <jsp:include page="/WEB-INF/jsp/common/commonBtnAuth.jsp">
						<jsp:param name="authCd" value="1" />
						<jsp:param name="showAuthCd" value="1,2,3,9,10" />
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
