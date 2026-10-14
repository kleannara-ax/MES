<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>공정투입</title>
<%@ include file="/common/include/webdek/head.jsp" %>
<link rel="stylesheet" type="text/css" href="/common/theme/webdek/css/demo_layout.css">
<script type="text/javascript">
	var data;
	var werks;
	var matnr;
	var wrk_ordr_no;
	var wrk_ordr_seqno;
	var mach_cd;
	
	$(document).ready(function(){
		gridList.setGrid({
		    id : "gridList",
		    url : "/mes/Work/WRK34_POP01/json/datalist.data",
		    bigdata : false
		})
	      
		data = page.getLinkPopData();
		console.log("## WRK34_POP01 > data = ", data);

		werks = data[0].get("WERKS");
	    matnr = data[0].get("MATNR");
	    wrk_ordr_no = data[0].get("WRK_ORDR_NO");
	    wrk_ordr_seqno = data[0].get("WRK_ORDR_SEQNO");
	    mach_cd = data[0].get("MACH_CD");
	      
	    searchList();
	});

	// 조회
	function searchList() {
	    var param = inputList.setRangeParam("searchArea");
	    param.put("P_TYPE", "LIST");
	    param.put("list", data);
	
		param.put("WERKS",werks)
		param.put("MATNR",matnr)
		param.put("WRK_ORDR_NO",wrk_ordr_no)
		param.put("WRK_ORDR_SEQNO",wrk_ordr_seqno)
		param.put("MACH_CD",mach_cd)
		
		console.log("## searchList() > param = ", param);

	    gridList.gridList({
	        id : "gridList",
	        param : param
	    });
	}
     
	function gridListEventColValueChange(gridId, rowNum, colName, colValue){
		if(gridId == "gridList"){
			if(colName == 'INP_QTY'){
				var stckqty = gridList.getColData(gridId, rowNum, "STCK_QTY");
				if(Number(stckqty) < Number(colValue)){
					alert("재고에 있는 수량만큼 투입가능합나다.");
  	    			gridList.setColValue("gridList", rowNum , "INP_QTY", 0);
  	    			gridList.setRowState(gridId, configData.GRID_ROW_STATE_READ, rowNum);
    				gridList.setRowCheck(gridId, rowNum, false);
  	    		   	return;
				}
			}		
		}
	}

	// 공정투입
	function saveData(){
   		if(gridList.validationCheck("gridList", "all")){
   			if(gridList.getModifyRowCount("gridList") == 0){
   				commonUtil.msgBox("MASTER_M0545");
   				return;
   			} 
   			
   			var rowData = gridList.getSelectData("gridList");
   			for(var i = 0; i < rowData.length; i++){
          			if(rowData[i].get("STCK_QTY") == "0"){
          				alert("투입가능한 재고수량이 없습니다.");
          				gridList.setColValue("gridList", i , "INP_QTY", '');
          				return;
          			}
          			if(Number(rowData[i].get("INP_QTY")) > Number(rowData[i].get("STCK_QTY"))){
						alert("재고에 있는 수량만큼 투입가능합나다.");
      	    			gridList.setColValue("gridList", i , "INP_QTY", '');
      	    		   	return;
      	    	   }
       		}
   			
   			if(confirm("공정투입하시겠습니까?")){
   				var list = gridList.getSelectData("gridList");
   				var param = new DataMap();
   				
   				param.put("P_TYPE", "SAVE");
   				param.put("list", list);

   	        	param.put("WRK_ORDR_NO",wrk_ordr_no);
   	        	param.put("WRK_ORDR_SEQNO",wrk_ordr_seqno);
   	        	param.put("MACH_CD",mach_cd);
   				//20220720 여한진 RFC 호출
   				netUtil.send({
   			    	url : "/mes/Work/WRK34_POP01/json/datalist.data",
   			    	param : param,
   			    	successFunction : "savesuccessCallBack"
   			    });
   			}
   		}
   	}
        
    // 버튼을 클릭한 경우
   	function commonBtnClick(btnName){
		if(btnName == "Save"){
			saveData();
		}
	}
     	
    // 공정 투입 후 실행
   	function savesuccessCallBack(json){
   		if(json){
   			if(json.data){
   				if(json.CODE == 'E'){
   					alert(json.MSG);
   				}else{
   					alert("공정투입 성공");
   					page.linkPopClose();
   				}
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
					<input type="button" id="button-0-2" CB="Save SAVE BTN_PROCINPUT" />
				</div>
			</div>
		</div>
        <div class="search_next_wrap" style="height:95%">
            <div class="content_layout tabs ">
                <ul class="tab tab_style02">
                    <li><a href="#tab1-1" ><span>공정투입</span></a></li>
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
	                                    <!-- <td GH="40" GCol="rownum">1</td> -->
										<td GH="40" GCol="rowCheck"></td>
	                                    <td GH="140" GCol="text,MATNR" style="text-align: center;">자재코드</td>
	                                    <td GH="280" GCol="text,MATNR_NM">자재명</td>
	                                    <td GH="140" GCol="text,STOR_LOC_CD" style="text-align: center;">저장위치</td>
	                                    <td GH="140" GCol="text,STOR_LOC_NM">저장위치명</td>
	                                    <td GH="140" GCol="text,IND_BCD" style="text-align: center;">개별바코드</td>
	                                    <td GH="60" GCol="text,UNIT" style="text-align: center;">단위</td>
										<td GH="100" GCol="text,STCK_QTY" GF='N 13,3' style="text-align:center;">재고수량</td>
										<td GH="100" GCol="input,INP_QTY" GF='N 13,3' style="text-align:center;">투입수량</td>
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
