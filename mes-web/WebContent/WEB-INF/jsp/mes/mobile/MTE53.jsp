<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<meta name="viewport" content="user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, width=device-width, target-densitydpi=medium-dpi" />
<meta name="format-detection" content="telephone=no" />
<title>WMS</title>
<%@ include file="/mobile/include/head.jsp" %>
<script type="text/javascript" src="/wms/js/esmart.mobile.js"></script>
<script type="text/javascript">

    var headFocusNum = -1;
    var dblIdx = 0;
    var searchType = 0;
    var mcrow = -1;

    $(document).ready(function(){
      //  setTopSize(300);
        var isMobile = navigator.userAgent.match(/(iPhone|iPod|iPad|Android|BlackBerry)/); 
        //alert(isMobile);
        /*
		if(isMobile != null){
    		document.body.style.zoom = "300%";
        }else{
        	document.body.style.zoom = "150%";
        }
        window.top.sizeToggle();
		*/
        var mangeMap = new DataMap();
        var rangeList = new Array();

        mangeMap.put("OPER", "E");
        mangeMap.put("DATA", "310");
        rangeList.push(mangeMap);


        inputList.setRangeData("TASDH.TASOTY", configData.INPUT_RANGE_TYPE_SINGLE, rangeList);

        rangeList = new Array();

        mangeMap = new DataMap();
        mangeMap.put("OPER", "E");
        mangeMap.put("DATA", "NEW");
        rangeList.push(mangeMap);

        mangeMap = new DataMap();
        mangeMap.put("OPER", "E");
        mangeMap.put("DATA", "PPC");
        rangeList.push(mangeMap);

        inputList.setRangeData("TASDH.STATDO", configData.INPUT_RANGE_TYPE_SINGLE, rangeList);


        gridList.setGrid({
			id : "gridList",
	    	name : "gridList",
			editable : true,
			module : "WmsMobile",
			command : "TE53",
			bindArea: "searchArea"
		
        });
        
		gridList.setRowFocus("gridList", 0, false);

    });

    function gridListEventDataViewEnd(gridId, dataLength)
    {

    }

    function scan_order(obj)
    {
    }   
    
    function scan_pickbox(obj)
    {
    }
    
    function commonBtnClick(btnName){
        if(btnName == "Search"){
            searchList();
        }else if(btnName == "Workwt"){
        	pack_waiting();
        }else if(btnName == "Delete"){
            orderDelete();
        }
        else if(btnName == "Save"){
        	box_upload();
        }
    }
    

    function gridListEventDataBindEnd(gridId, dataLength)
    {
    }

    function box_upload()
    {
    }

    function searchList(){
    	var param = inputList.setRangeParam("searchArea");
    	param.put("SHIPNM",$("#SHIPNM").val());
    	param.put("PGRC03",$("#PGRC03").val());
    	param.put("EXPTNK",$("#EXPTNK").val());
    	param.put("INVNUM",$("#INVNUM").val());
    	
    	gridList.gridList({
    		id : "gridList",
    		param : param
    	});
		gridList.setRowFocus("gridList", 0, false);
    	mcrow = -1;
    }

    function searchSubItemList(rowNum){
        gridList.resetGrid("gridList");

        //var SHPOKY = gridList.getColData("gridHeadList", rowNum, "SHPOKY");
        /* var shpoky = gridList.getColData("gridHeadList", rowNum, "SHPOKY"); */
        //alert(shpoky)
        var param = inputList.setRangeParam("searchArea");

        gridList.gridList({
            id : "gridList",
            command : "TE53",
            param : param
        });

        headFocusNum = rowNum;
    }

/*     function gridListEventRowFocus(gridId, rowNum){
        if(gridId == "gridHeadList"){
            var modRowCnt = gridList.getModifyRowCount("gridList");
            if(modRowCnt == 0){
                if(dblIdx != rowNum){
                    gridList.resetGrid("gridList");
                    dblIdx = -1;
                }
            }else{
                if(commonUtil.msgConfirm("COMMON_M0462")){
                    gridList.resetGrid("gridList");
                    dblIdx = -1;
                }else{
                    gridList.setRowFocus("gridHeadList", headFocusNum, false);
                    gridList.setColFocus("gridHeadList", headFocusNum, "DOCDAT");
                    return;
                }
            }
            headFocusNum = rowNum;
        }
    } */

    
    function gridListEventRowCheck(gridId, rowNum, checkType){
    }

    function gridListEventRowCheckAll(gridId, checkType){
    }

    function searchHelpEventOpenBefore(searchCode, gridType){
    }


    function saveCheck(){
    }

    function saveData(){
        if(!commonUtil.msgConfirm("OUT_M0154")){
            return;
        }

        var param = saveCheck();
        if(param != null){
           var vjson = validCheck(param);

            if(vjson.data != "OK"){
                var msgList = vjson.data.split(" ");
                var msgTxt = commonUtil.getMsg(msgList[0], msgList.pop());
                commonUtil.msg(msgTxt);
                return false;
            }


            var json = save(param);
           //console.log(JSON.stringify(json))
            if(json && json.data){
                commonUtil.msgBox("OUT_M0153");

                gridList.resetGrid("gridList");
                searchList();
            }

            dblIdx = 0;
        }
    }

    function validCheck(param){
    }


    function save(param){
    }
    
	function gridListEventRowFocus(gridId, rowNum){
/* 		var rowData = gridList.getRowData(gridId, rowNum);
		 dataBind.paramData("searchArea", rowData); 
		if(mcrow!=-1){
			wms.linkPopOpen("/wms/mobile/TE53POP.page", rowData);
		}
		mcrow++;
		gridList.setRowFocus("gridList", headFocusNum, false); */

	}    
	function linkPopCloseEvent(){
		//alert(wms.popData);
		mcrow = -1;
		searchSubItemList(headFocusNum);
	}
	
	function showMain() {
		$("#detailInfo").hide();
		$("#main").show();
	}
	
	function showDetail() {
		$("#main").hide();
		$("#detailInfo").show();
	}
	
	function clearText(data){
		if(data!=null||data!=""){
			data.value="";
		}		
	}
	function reloadPage(){
		location.reload(true);
	}
</script>
</head>
<body>
	<div class="main_wrap" id="main" >
		<div class="tem5_content">
			<div class="searchSection">
				<table>
					<colgroup>
						<col width="70px"  />
						<col />
						<col width="70px"  />
						<col />
					</colgroup>
					<tbody>
						<tr>
							<td>
								<input type="button" value="조회" style="width: 70px; float:left ;" class="bt" onclick="searchList()"/>
							</td>
<!-- 							<td> -->
<!-- 								<input type="button" value="알림" style="width: 70px; float:left ;" class="bt" /> -->
<!-- 							</td> -->
						</tr>
					</tbody>
				</table>
			</div>
		<div class="MGR20_top_search">
				<table>
					<colgroup>
						<col width="70px"  />
						<col />
						<col width="70px"  />
						<col />
					</colgroup>
					<tbody>
						<tr>
							<th>주문번호</th>
							<td>
								<input type="text" class="text" name="PGRC03" id="PGRC03"/>
							</td>
							<th>수령자명</th>
							<td>
								<input type="text" class="text"  name="SHIPNM" id="SHIPNM"/>
							</td>
						</tr>
						<tr class="t_title">
							<th>송장번호</th>
							<td>
								<input type="text" class="text"  name="INVNUM" id="INVNUM"/>
							</td>
							<th>판매처</th>
							<td>
								<input type="text" class="text"  name="EXPTNK" id="EXPTNK"/>
							</td>
<!-- 							<td> -->
<!-- 								<input type="button" value="총괄수량적용" class="bt" onclick="totalApplyAll()"/> -->
<!-- 							</td> -->
						</tr>
					</tbody>
				</table>
			</div>

			<div class="tableWrap_search section" >
				<div class="tableHeader">
					<table style="width: 100%">
						<colgroup>
							<col width="60px" />
<!-- 							<col width="0" /> -->
<!-- 							<col width="0" /> -->
							<col width="150px"/>
							<col width="200px" />	
							<col width="100px" />
							<col width="100px" />
						</colgroup>
						<thead>
							<tr>
								<th>번호</th>
<!-- 								<th CL='STD_VHTKKY'></th> -->
<!-- 								<th CL='STD_VHTKIT'></th> -->
								<th>수령자명</th>
								<th>지번주소(기본)</th>
								<th>배차유형</th>
								<th>배송상태</th>
							</tr>
						</thead>
					</table>				
				</div>					
				<div class="tableBody">
					<table style="width: 100%">
						<colgroup>
							<col width="60px" />
<!-- 							<col width="0" /> -->
<!-- 							<col width="0" /> -->
							<col width="150px"/>
							<col width="200px" />	
							<col width="100px" />
							<col width="100px" />
						</colgroup>
						<tbody id="gridList">
							<tr CGRow="true">
								<td GCol="rownum">1</td>
<!-- 								<td GCol="text,VHTKKY"></td> -->
<!-- 								<td GCol="text,VHTKIT"></td> -->
								<td GCol="text,SHIPNM"></td>
								<td GCol="text,SHIPAD"></td>
								<td GCol="text,DLVTYP"></td>
								<td GCol="text,VHPSTS"></td>
							</tr>
						</tbody>
					</table>
				</div>
				</div><!-- end table_body -->
			</div>
	</div>
	<div class="detailInfo_wrap" id="detailInfo">
	
		
	<h2 class="info_title">상세정보</h2>
		<div class="d_table_wrap">
			<div id="searchArea">
				<input type="hidden" name="VHPNKY" />
				<input type="hidden" name="VHTKKY" />
				<input type="hidden" name="VHTKIT" />
				<input type="hidden" name="USERID" />
			
				<table class="info_table">
					<colgroup>
						<col width="180x"/>
						<col />
						<col width="50px"/>
						<col />
					</colgroup>
						<tbody>
							<tr>
								<th CL='STD_SHIPAD'></th>
								<td colspan=3>
									<span class="inp_group">
										<input type="text" name="SHIPAD" readonly="readonly"  />
									</span>
								</td>
							</tr>
							<tr>
								<th></th>
								<td colspan=3>
									<span class="inp_group">
										<input type="text" name="SHIPAD1"  readonly="readonly"  />
									</span>
								</td>
							</tr>
							<tr>
								<th CL='STD_SHIPAD2'></th>
								<td colspan=3>
									<span class="inp_group">								
										<input type="text" name="SHIPAD2"  readonly="readonly"  />
									</span>
								</td>
							</tr>
							<tr>
								<th></th>
								<td colspan=3>
									<span class="inp_group">								
										<input type="text" name="SHIPAD3"  readonly="readonly"  />
									</span>
								</td>
							</tr>
							<tr>
								<th CL='STD_CSALRM'></th>
								<td colspan=3>
									<span class="inp_group">								
										<input type="text" name="CSALRM"  readonly="readonly"  />
									</span>
								</td>
							</tr>
							<tr>
								<th CL='STD_CSSPEC'></th>
								<td colspan=3>
									<span class="inp_group">								
										<input type="text" name="CSSPEC"  readonly="readonly" />
									</span>
								</td>
							</tr>
							<tr>
								<th></th>
								<td colspan=3>
									<span class="inp_group">								
										<input type="text" name="CSETC1"  readonly="readonly"  />
									</span>
								</td>
							</tr>
							<tr>
								<th></th>
								<td colspan=3>
									<span class="inp_group">								
										<input type="text" name="CSETC2"  readonly="readonly"  />
									</span>
								</td>
							</tr>
							<tr>
								<th CL='STD_SHIPNM'></th>
								<td colspan=3>
									<span class="inp_group">								
										<input type="text" name="SHIPNM"  readonly="readonly" style="width: 200px;" />
									</span>
								</td>
							</tr>
							<tr>
								<th></th>
								<td colspan=3>
									<span class="inp_group">								
										<input type="file" id="camera" name="camera" accept="image/*" capture="camera" />
									</span>
								</td>
							</tr>
					</tbody>
				</table>
			</div>		
		</div>
		
		<div class="footer_5">
			<table>
				<tr>
					<td class=f_1 onclick="gridList.setPreRowFocus('gridList')">&lt;</td>
<!-- 					<td onclick="saveData()">저장</td> -->
					<td onclick="showMain()">닫기</td>
					<td onclick="gridList.setNextRowFocus('gridList')">&gt;</td>
				</tr>
			</table>
		</div><!-- end footer_5 -->
</div>
</body>
</html>