<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>검사항목</title>
<%@ include file="/common/include/webdek/head.jsp"%>
<link rel="stylesheet" type="text/css"
	href="/common/theme/webdek/css/demo_layout.css">
<script type="text/javascript">
	var WERKS;
	var MATNR;
	var INSP_ITEM_GRP_CD;
	var MSRM_DATE;
	var PRC_SEQNO;
	var INSP_ITEM_CD;
	var MSRM_ACC;
	
	let colNum;
	
	$(document).ready(function(){
		configData.MENU_ID = "QLT01_POP02"; 
		
		gridList.setGrid({
			id : "gridList",
            url : "/mes/Quality/QLT01_POP02/json/datalist.data",
            bigdata : false
        });
         
        var Data = page.getLinkPopData();
        WERKS = Data.get("WERKS");
        MATNR = Data.get("MATNR");
        INSP_ITEM_GRP_CD = Data.get("INSP_ITEM_GRP_CD");
        MSRM_DATE = Data.get("MSRM_DATE");
        PRC_SEQNO = Data.get("PRC_SEQNO");
        INSP_ITEM_CD = Data.get("INSP_ITEM_CD");
        MSRM_ACC = Data.get("MSRM_ACC");
        
        colNum = Data.get("colNum")
        
        searchList(); 
   	});
 	
	function searchList(){
		var param = new DataMap();
		
		param.put("P_TYPE", "LIST");
		param.put("WERKS", WERKS);
		param.put("MATNR", MATNR);
		param.put("INSP_ITEM_GRP_CD", INSP_ITEM_GRP_CD);
		param.put("MSRM_DATE", MSRM_DATE);
		param.put("PRC_SEQNO", PRC_SEQNO);
		param.put("INSP_ITEM_CD", INSP_ITEM_CD);
		param.put("MSRM_ACC", MSRM_ACC);
		
		gridList.gridList({
			id : "gridList",
			param : param
		});
	}
     
	// grid column value 변경 시
    const gridListEventColValueChange = (gridId, rowNum, colName, colValue) => {
    	if(gridId == "gridList"){
			var INPT_MTD = gridList.getColData("gridList", rowNum, "INPT_MTD");
			var flag = true;
			var value_length = colValue.substring(colValue.indexOf('.') + 1);
			
			if(isNaN(colValue)){
				flag = false;
			}
			
			if(INPT_MTD == "9.99"){
				if(flag == true){
					// RST_VAL : 측정 값
					if(colName == "RST_VAL"){
						if(colValue.indexOf('.') > 0){
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
    	}
	}
    
    function saveData(){
    	if(gridList.validationCheck("gridList", "all")){
    		var list = gridList.getSelectData("gridList");
    		if(list.length === 0){
    			alert("선택된 행이 없습니다.")
    			return
    		}
    		
 			if(!commonUtil.msgConfirm(configData.MSG_MASTER_SAVE_CONFIRM)){
 		    	return;
 			}
 			
 			for(var i = 0; i < list.length; i++){
 				if(list[i].get("RST_VAL") == " "){
 					alert("선택한 것 중 " + (i + 1) + "번째 결과값을 입력하지 않았습니다.");
 					return;
 				}
 			}
 			
 			var param = new DataMap();
 			
 			param.put("P_TYPE", "SAVE");
 		    param.put("list", list);
 			
   		    netUtil.send({
   		    	url : "/mes/Quality/QLT01_POP02/json/datalist.data",
 				param : param,
 				successFunction : "saveSuccessCallBack"
 			});
 		}
    }
    
    function saveSuccessCallBack(json, status){
    	if(json && json.data){
			commonUtil.msgBox(configData.MSG_SYSTEM_SAVEOK);
			opener.searchSubList(colNum)
			page.linkPopClose();
    	}
    }
    
    function commonBtnClick(btnName){
    	if(btnName == "Search"){
   		    var param = new DataMap();
             
   		    param.put("PROGID", "<%=menuId%>");
		    param.put("LGTYPE", "SEARCH");
		
		    var json = netUtil.sendData({
			    url : "/mes/system/json/saveLog.data",
			    param : param
		    });

		    searchList();
	    } else if (btnName == "Save") {
		    saveData();
	    }
	}
    
</script>
</head>
<body>
	<%@ include file="/common/include/webdek/layout.jsp"%>
	<!-- content -->
	<div class="content_wrap">
		<div class="content_inner">
			<%@ include file="/common/include/webdek/title.jsp"%>
			<div class="content_serch" id="searchArea">
				<div class="btn_wrap">
					<div class="fl_l"></div>
					<div class="fl_r">
						<input type="button" id="button-0-2" CB="Save SAVE BTN_SAVE" />
					</div>
				</div>
			</div>
			<div class="search_next_wrap" style="height: 90%;">
				<div class="content_layout tabs">
					<ul class="tab tab_style02">
						<li><a href="#tab1-1"><span>검사항목</span></a></li>
						<li class="btn_zoom_wrap">
							<ul>
								<li><button class="btn btn_bigger">
										<span>확대</span>
									</button></li>
							</ul>
						</li>
					</ul>
					<div class="table_box section" id="tab1-1 gridList">
						<div class="table_list01">
							<div class="scroll">
								<table class="table_c">
									<tbody id="gridList">
										<tr CGRow="true">
											<td GH="40" GCol="rownum">1</td>
											<td GH="40" GCol="rowCheck"></td>
											<td GH="0" GCol="text,WERKS" style="text-align:center;">플랜트</td>
											<td GH="0" GCol="text,MATNR" style="text-align: center;">자재코드</td>
											<td GH="0" GCol="text,MSRM_DATE" style="text-align: center;">측정일시</td>
											<td GH="0" GCol="text,PRC_SEQNO" style="text-align: center;">처리순번</td>
											<td GH="0" GCol="text,INSP_ITEM_GRP_CD" style="text-align: center;">검사항목그룹코드</td>
											<td GH="100" GCol="text,INSP_ITEM_CD" style="text-align: center;">검사항목코드</td>
											<td GH="0" GCol="text,INSP_SEQNO" GF="N">검사차수</td>
											<td GH="140" GCol="text,INSP_ITEM_NM">검사항목명</td>
											<td GH="140" GCol="text,MID_CAT_NM">중분류명</td>
											<td GH="140" GCol="text,BIG_CAT_NM">대분류명</td>
											<td GH="100" GCol="text,INPT_TYP">입력타입</td>
											<td GH="100" GCol="text,INPT_MTD">입력방법</td>
											<td GH="80" GCol="input,RST_VAL" style="text-align:right;">측정값</td>
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
	<%@ include file="/common/include/webdek/bottom.jsp"%>
</body>
</html>