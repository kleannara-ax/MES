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
	$(document).ready(function(){
		gridList.setGrid({
	    	id : "gridList",
	    	url : "/mes/Work/WRK11/json/datalist.data",
	    	bigdata : false,
	    	colHoldType : true,
	    	colHold: "WERKS, PRFM_DT, MACH_CD, MACH_NM"
	    });
	});

	function searchHelpEventCloseAfter(searchCode, multyType, selectData, rowData){
		if(searchCode == "PLANT"){
			reloadCombo();
		}
	}
	
	function reloadCombo(){
		$comboObj = $("#MACHINE");
		inputList.reloadCombo($comboObj, configData.INPUT_COMBO, "Produce,MACHINE");
	}
	
	function comboEventDataBindeBefore(comboAtt){
		if(comboAtt == "Produce,MACHINE"){
			var param = new DataMap();
			
			param.put("WERKS", $('#WERKS').val().toUpperCase());
		}
		return param;
	}
	
	function searchList(){
		if(validate.check("searchArea")){
			var param = inputList.setRangeParam("searchArea");
			
			if(param.get("WERKS") == 'P100'){
				alert("PS제지는 WEB에서 폐품등록하지 않습니다.");
				return;
			}else if(param.get("WERKS") == 'P200'){
				alert("생리대, 음성 플랜트만 조회 가능합니다.");
				return;
			}
			
			param.put("P_TYPE","LIST");
			
			gridList.gridList({
		    	id : "gridList",
		    	param : param
		    });
		}
	}
	//폐품등록
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
		
		if (gridList.getModifyRowCount("gridList") == 0 ) {
			alert('등록할 폐품수량이 변경되지 않았습니다.');
			return;
		} 
		
		if (gridList.validationCheck("gridList", "all")) {
			var list = gridList.getSelectData("gridList");
			
			if(list.length == 0){
				alert('선택한 항목이 없습니다.');
				return;
			}
			
			for(var i = 0; i < list.length; i++){
				if(list[i].get('SAP_YN') == '전송완료'){
					alert('선택한 항목 중 ' + i + 1 + '번재 항목은 이미 폐품을 등록한 이력이 있으므로 취소를 먼저 진행해주시기 바랍니다.');
					return;
				}
			}
			
			var param = new DataMap();
			
			param.put("P_TYPE","SAVE");
			param.put("list", list);
	
			if (!commonUtil.msgConfirm(configData.MSG_MASTER_SAVE_CONFIRM)){
				return;
			}
			
			netUtil.send({
				url : "/mes/Work/WRK11/json/datalist.data",
				param : param,
				successFunction : "saveSuccessCallBack"
			});
		}
	}
	//20220803 여한진 SAP에 송신
	function saveSuccessCallBack(json){
		if(json.P_SUCCESS == 'Y'){
			var param = new DataMap();
           	//SAP에 실적등록 송신
       		param.put("IFID", "MES_IF_133");
            param.put("DOC_NO", json.DOC_NO3);
            
            var json2 = netUtil.sendData({
            	url : "/mes/erpif/json/sendIF.data",
            	param : param
            });
                    
            if(json2.data == 'SUCCESS'){
            	// 2023-02-14(화요일) 안상현, 실적전송 성공 시 프로시저 생성
            	
            	//SAP에 폐품등록 송신
        		param.put("IFID", "MES_IF_134");
                param.put("DOC_NO", json.DOC_NO4);
                
                var json3 = netUtil.sendData({
                	url : "/mes/erpif/json/sendIF.data",
                	param : param
                });
                
                if(json3.data == 'SUCCESS'){
                	// 2023-02-14(화요일) 안상현, 폐품 실적전송 성공 시 프로시저 생성
                	
                	commonUtil.msgBox(configData.MSG_SYSTEM_SAVEOK);
                }else{
                	// 2023-02-14(화요일) 안상현, 실적취소 전송 로직 추가
                	
                	alert("(SAP 폐품등록)  " + json3.data);
                }
            }else{
            	alert("(SAP 실적등록) " + json2.data);
            } 
            searchList();
		}else{
			alert(json.ERR_MSG);
		}
	}
	//2022-08-22 여한진 폐품취소 추가
	function dispoCanle(){
		var json = netUtil.sendData({
    		module : 'mes',
    		command : 'SYSTEMCHECK',
    		sendType : 'map'
    	});
    	
    	if(json.data.USE_YN == 'Y'){
    		alert('시스템 점검 중입니다. 1 ~ 5분 동안 잠시만 기다려 주세요.');
    		return;
    	}
		
		if (gridList.validationCheck("gridList", "all")) {
			var list = gridList.getSelectData("gridList");
			
			if(list.length == 0){
				alert('선택한 항목이 없습니다.');
				return;
			}
			
			for(var i = 0; i < list.length; i++){
				if(list[i].get('SAP_YN') == '미전송'){
					alert('선택한 항목 중 ' + i + 1 + '번재 항목은 폐품을 등록하지 않았습니다.');
					return;
				}
			}
			
			var param = new DataMap();
			
			param.put("P_TYPE","DELETE");
			param.put("list", list);
	
			if (!commonUtil.msgConfirm('폐품취소하시겠습니까?')){
				return;
			}
			
			netUtil.send({
				url : "/mes/Work/WRK11/json/datalist.data",
				param : param,
				successFunction : "saveSuccessCallBack2"
			});
		}
	}

	function saveSuccessCallBack2(json){
		if(json.P_SUCCESS == 'Y'){
			var param = new DataMap();
    		
    		//SAP에 폐품취소 송신
    		param.put("IFID", "MES_IF_144");
            param.put("DOC_NO", json.DOC_NO1);
            
            var json2 = netUtil.sendData({
            	url : "/mes/erpif/json/sendIF.data",
            	param : param
            });
            
            if(json2.data == 'SUCCESS'){
            	//SAP에 실적취소 송신
        		param.put("IFID", "MES_IF_129");
                param.put("DOC_NO", json.DOC_NO2);
                
                var json3 = netUtil.sendData({
                	url : "/mes/erpif/json/sendIF.data",
                	param : param
                });
                
                if(json3.data == 'SUCCESS'){
                	commonUtil.msgBox(configData.MSG_SYSTEM_SAVEOK);
                }else{
                	alert("(SAP 실적취소) " + json3.data);
                }
            }else{
            	alert("(SAP 폐품취소) " + json2.data);
            }
        	searchList();
		}else{
			alert(json.ERR_MSG);
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
		}else{
			dispoCanle();
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
					<input type='button' id='button-0-3' CB='CancleDispo DELETE 폐품취소'/>			
				</div>
			</div>
			<div class="search_inner">
				<div class="search_wrap ">
					<dl>
						<dt CL="STD_PLANT">플랜트</dt>
						<dd>
							<input type="text" class="input" id="WERKS" name="WERKS" validate="required" UIInput="S,PLANT" UIFormat="U" onkeyup="reloadCombo()"/>
						</dd>
					</dl>
					<dl>
						<dt CL="STD_MATNR">자재코드</dt>
						<dd>
							<input type="text" class="input" name="MATNR" id="MATNR" UIInput="SR,MATKY" UIFormat="U"/>
						</dd>
					</dl>
					<dl>
						<dt CL="STD_MACHINE">생산호기</dt>
						<dd>
							<select class="input" id="MACHINE" name="MACHINE" Combo="Produce,MACHINE">
								<option value="">All</option>
							</select>
						</dd>
					</dl>
					<dl>
						<dt CL="STD_PRFM_DT">실적일자</dt>
						<dd>
							<input type="text" class="input" id="PRFM_DT" name="PRFM_DT" UIInput="B" UIFormat="C M1"/>
						</dd>
					</dl>
				</div>
				<div class="btn_tab">
					<input type="button" class="btn_more" value="more" onclick="searchMore()"/>
				</div>
			</div>
		</div>
        <div class="search_next_wrap">
			<div class="content_layout tabs">
				<ul class="tab tab_style02">
					<li><a href="#tab1-1"><span>실적정보</span></a></li>
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
							<table class="table_c">
								<tbody id="gridList">
									<tr CGRow="true">
										<td GH="40" GCol="rownum">1</td>
										<td GH="40" GCol="rowCheck"></td>
										<td GH="100" GCol="text,WERKS" style="text-align:center;"></td>			<!-- 플랜트 -->
										<td GH="100" GCol="text,PRFM_DT" GF='D' style="text-align:center;"></td>	<!-- 실적일자 -->
										<td GH="100" GCol="text,MACH_CD" style="text-align:center;"></td>		<!-- 설비코드 -->
										<td GH="120" GCol="text,MACH_NM"></td>			<!-- 설비명 -->
										<td GH="100" GCol="text,MACH_SHRT_NM"></td>		<!-- 설비명(단축) -->
										<td GH="130" GCol="text,WRK_ORDR_NO"></td>	<!-- 작업지시번호 -->
										<td GH="80" GCol="text,WRK_ORDR_SEQNO" style="text-align:right;"></td>	<!-- 작업지시순번 -->
										<td GH="140" GCol="text,MATNR" style="text-align:center;"></td>			<!-- 자재코드 -->
										<td GH="320" GCol="text,MATNR_NM"></td>		<!-- 자재명 -->
										<td GH="100" GCol="text,TOT_QTY" GF="N 13"></td>		<!-- 총 생산수량A -->
										<td GH="100" GCol="text,PRFM_QTY" GF="N 13"></td>		<!-- 실적수량B -->
										<td GH="100" GCol="input,SCRAP_QTY" validate="required" GF="N 5"></td>	<!-- 폐품수량A-B -->
										<td GH="100" GCol="text,WRK_SHIFT" style="text-align:center;"></td>		<!-- 작업조 -->
										<td GH="100" GCol="text,WRK_CLSS_NM"></td>		<!-- 작업반 -->
										<td GH="100" GCol="text,WRKNM"></td>			<!-- 작업자 -->
										<td GH="100" GCol='text,SAP_YN'></td>			<!-- SAP 전송여부 -->
										<%--
										<td GH="80" GCol="text,REGDATE" GF='D'></td> 	<!-- 생성일자 -->										
										<td GH="80" GCol="text,REGNM"></td> 			<!-- 생성자명 -->
										<td GH="80" GCol="text,UPDDATE"></td> 			<!-- 수정일자 -->
										<td GH="80" GCol="text,UPDNM"></td> 			<!-- 수정자명 -->
										--%>	
									</tr>
								</tbody>
							</table>
						</div>
					</div>
					<jsp:include page="/WEB-INF/jsp/common/commonBtnAuth.jsp">
						<jsp:param name="authCd" value="1" />
						<jsp:param name="showAuthCd" value="1,2,7,9,10" />
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