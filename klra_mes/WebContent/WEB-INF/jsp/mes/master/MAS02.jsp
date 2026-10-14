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
	    	url : "/mes/Master/MAS02/json/datalist.data",
	    	bigdata : false,
	    	colHoldType : true,
	    	colHold : "WERKS, MATNR, MATNR_NM, MATNR_SHRT_NM",
	    	colorType : true
	    });
		
 		gridList.setGrid({
			id : "gridList2_A",
	    	url : "/mes/Master/MAS02/json/datalist.data",
	    	bigdata : false
	    });
		
		gridList.setGrid({
			id : "gridList2_B",
	    	url : "/mes/Master/MAS02/json/datalist.data",
	    	bigdata : false
	    });
	});

	function searchList(){
		if(validate.check("searchArea")){
			var param = inputList.setRangeParam("searchArea");

			param.put("P_TYPE", "LIST");
			
			gridList.gridList({
		    	id : "gridList",
		    	param : param
		    });
		}
		
		gridList.resetGrid("gridList2_A");
		gridList.resetGrid("gridList2_B");
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
		}
	}
	
	function gridListEventRowDblclick(gridId, rowNum){
		if(gridId == "gridList"){
			searchSubList(rowNum);
		}
	}
	
	function searchSubList(headRowNum){
		var matnr = gridList.getColData("gridList", headRowNum, "MATNR");
		var param = new DataMap();
		
		param.put("P_TYPE", "SUB_LIST-A");
		param.put("MATNR", matnr);

		gridList.gridList({
			id : "gridList2_A",
			param : param
		});
		
		searchSubList2(matnr);
	}
	
	function searchSubList2(matnr){
		
		var param = new DataMap();
	
		param.put("P_TYPE", "SUB_LIST-B");
		param.put("MATNR", matnr);
		
		gridList.gridList({
			id : "gridList2_B",
			param : param
		});
	}
	
	function gridListRowBgColorChange(gridId, rowNum){
		if(gridId == "gridList"){
			
			var matnrsta = gridList.getColData("gridList", rowNum, "MATNR_STA_NM");
			
			if(matnrsta.trim() != ""){
				return configData.GRID_COLOR_BG_GRAY_CLASS;
			}
		}
	}
	
	/* function saveData(){
		if(gridList.validationCheck("gridList", "data")){
			if(gridList.getModifyRowCount("gridList") == 0){
				commonUtil.msgBox("MASTER_M0545");
				return;
			}
			
			var list = gridList.getSelectData("gridList");
			
			if(!commonUtil.msgConfirm(configData.MSG_MASTER_SAVE_CONFIRM)){
				return;
			}

			var param = new DataMap();

			param.put("P_TYPE", "SAVE");
			param.put("list", list);

			netUtil.send({
				url : "/mes/Master/MAS02/json/datalist.data",
				param : param,
				successFunction : "saveSuccessCallBack"
			});
		}
	} */
	
	function saveSuccessCallBack(json){
		if(json.P_SUCCESS == 'Y'){
			commonUtil.msgBox(configData.MSG_SYSTEM_SAVEOK);
			searchList();
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
					<!-- <input type="button" id="button-0-2" CB="Save SAVE BTN_SAVE" /> -->
				</div>
			</div>
			<div class="search_inner">
				<div class="search_wrap ">
				  	<dl>
						<dt CL="STD_WERKS">플랜트</dt>
						<dd>
							<input type="text" class="input" name="WERKS" UIInput="S,PLANT" UIFormat="U" validate="required"/>
						</dd>
					</dl>
					<dl>
						<dt CL="STD_MATNR">자재코드</dt>
						<dd><input type="text" class="input" name="MATNR" UIInput="SR,MATKY" UIFormat="U"/></dd>
					</dl>
					<dl>
						<dt CL="STD_MATNR_NM">자재명</dt>
						<dd><input type="text" class="input" name="MATNR_NM" UIInput="SR"/></dd>
					</dl>
					<dl>
						<dt CL="STD_MATNR_DIV">자재유형</dt>
						<dd>
							<select class="input" name="MATNR_DIV" CommonCombo="MATNR_DIV" validate="required">
								<option value="">All</option>
							</select>
						</dd>
					</dl>
					<dl>
						<dt CL="STD_MATNR_GRP_CD">자재그룹</dt>
						<dd>
							<select class="input" name="MATNR_GRP_CD" CommonCombo="MATKL">
								<option value="">All</option>
							</select>
						</dd>
					</dl>
					<dl>
						<dt CL="STD_PROD_GRP_CD">제품군</dt>
						<dd>
							<select class="input" name="PROD_GRP_CD" CommonCombo="SPART">
								<option value="">All</option>
							</select>
						</dd>
					</dl>
					<dl>
						<dt CL="STD_BUSICD">사업부</dt>
						<dd>
							<select class="input" name="BUSICD" CommonCombo="BUSICD">
								<option value="">All</option>
							</select>
						</dd>
					</dl>
					<dl>
						<dt CL="STD_KZAUS">단종여부</dt>
						<dd>
							<select class="input" name="KZAUS">
								<option value="N">N</option>
								<option value="Y">Y</option>
							</select>
						</dd>
					</dl>
					<dl>
						<dt>품목구분</dt>
						<dd>
							<select class="input" name="PART_DIV" CommonCombo="PART_DIV">
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
			<div class="content_layout tabs top_layout">
				<ul class="tab tab_style02">
					<li><a href="#tab1-1"><span>일반</span></a></li>
					<li class="btn_zoom_wrap">
						<ul>
							<li><button class="btn btn_bigger"><span>확대</span></button></li>
						</ul>
					</li>
				</ul>
				<div class="table_box section" id="tab1-1" >
					<div class="table_list01" >
						<div class="scroll">
							<table class="table_b">
								<tbody id="gridList">
									<tr CGRow="true">
										<td GH="40" GCol="rownum">1</td>
										<td GH='40' GCol='rowCheck'></td>
										<td GH="100" GCol="text,WERKS" style="text-align:center;">플랜트</td>
										<td GH="140" GCol="text,MATNR" style="text-align:center;">자재코드</td>
										<td GH="320" GCol="text,MATNR_NM">자재명</td>
										<td GH="320" GCol="text,MATNR_SHRT_NM">자재명(LONG)</td>
										<td GH="100" GCol="text,MATNR_SPEC">규격</td>
										<td GH="100" GCol="text,MATNR_DIV" style="text-align:center;">자재유형</td>
										<td GH="160" GCol="text,MATNR_DIV_NM">자재유형명</td>
										<td GH="100" GCol="text,MATNR_GRP_CD" style="text-align:center;">자재그룹</td>
										<td GH="150" GCol="text,MATNR_GRP_NM">자재그룹명</td>
										<td GH="100" GCol="text,PROD_GRP_CD" style="text-align:center;">제품군</td>
										<td GH="100" GCol="text,PROD_GRP_NM">제품군명</td>
										<td GH="100" GCol="text,PART_DIV" style="text-align:center;">품목구분</td>
										<td GH="0" GCol="text,UNIT" style="text-align:center;">단위</td>
										<td GH="100" GCol="text,UNIT_NM">단위(명)</td>
										<td GH="0" GCol="text,RCV_UNIT" style="text-align:center;">입고단위</td>
										<td GH="100" GCol="text,RCV_UNIT_NM">입고단위</td>
										<td GH="0" GCol="text,IN_UNIT" style="text-align:center;">투입단위</td>
										<td GH="100" GCol="text,IN_UNIT_NM">투입단위(명)</td>
										<td GH="0" GCol="text,PROD_UNIT" style="text-align:center;">생산단위</td>
										<td GH="100" GCol="text,PROD_UNIT_NM">생산단위(명)</td>
										<td GH="100" GCol="text,LGFSB">외부입고저장위치</td>
										<td GH="100" GCol="text,LGPRO">투입저장위치</td>
										<td GH="100" GCol="text,BESKZ">조달유형</td>										
										<td GH="100" GCol="text,LOT_YN">LOT관리여부</td>
										<td GH="100" GCol="text,BISMT" style="text-align:center;">기존자재코드</td>
										<td GH="0" GCol="text,MMSTA" style="text-align:center;">고유 자재상태</td>
										<td GH="100" GCol="text,MMSTA_NM">고유 자재상태(명)</td>
										<td GH="100" GCol="text,PRDHA">제품계층구조</td>
										<td GH="100" GCol="text,DISLS">입고Lot크기유형</td>
										<td GH="100" GCol="text,SOBSL">특별조달유형</td>
										<td GH="0" GCol="text,MATNR_STA" style="text-align:center;">자재상태</td>
										<td GH="100" GCol="text,MATNR_STA_NM">자재상태(명)</td>
										<td GH="100" GCol="text,MIN_LOT_SIZE" GF="N 16,3">Lot크기(최소)</td>
										<td GH="100" GCol="text,MAX_LOT_SIZE" GF="N 16,3">Lot크기(최대)</td>
										<td GH="100" GCol="text,FIX_LOT_SIZE" GF="N 16,3">Lot크기(고정)</td>										
										<td GH="100" GCol="text,SV_STCK_QTY" GF="N 16,3">안전재고</td>
										<td GH="0" GCol="text,MATTYPE" style="text-align:center;">HL Lot구분</td>
										<td GH="100" GCol="text,MATTP_NM">HL Lot구분명</td>
										<td GH="100" GCol="text,BUSICD" style="text-align:center;">사업부</td>
										<td GH="100" GCol="text,BUSINM">사업부명</td>										
										<td GH="0" GCol="text,PCODE">지종</td>
										<td GH="100" GCol="text,PCODE_NM">지종(명)</td>
										<td GH="100" GCol="text,BS_WGT" GF="N 9,2">평량</td>
										<td GH="0" GCol="text,TSPEED" GF="N 5,0">목표 선속</td>
										<td GH="100" GCol="text,INSP_MATNR">검사대상여부</td>
										<td GH="100" GCol="text,MSTDE">단종일자</td>
										<td GH="0" GCol="text,BRAND_ID" style="text-align:center;">브랜드</td>
										<td GH="0" GCol="text,BRAND_DESCR">브랜드명</td>
										<td GH="100" GCol="text,DL_YN">삭제여부</td>
										<td GH="0" GCol="text,STRGR">생산전략</td>
										<td GH="0" GCol="text,DOMESTIC" style="text-align:center;">내수구분</td>
										<td GH="0" GCol="text,DOMESTIC_NM">내수구분(명)</td>
										<td GH="0" GCol="text,USE_YN">사용유무</td>
										
										<td GH="100" GCol="text,INSP_YN" style="text-align:center;">품질검사 대상 여부</td>
										<td GH="100" GCol="text,DSTBT_DDLIN" GF='D'>유통기간</td>
										<td GH="100" GCol="text,KAN_NO">KAN 번호</td>
										
										<td GH="140" GCol="text,REGDATE" style="text-align:center;">등록일시</td>
										<td GH="100" GCol="text,REGNM">등록자</td>
										<td GH="140" GCol="text,UPDDATE" style="text-align:center;">수정일시</td>										
										<td GH="100" GCol="text,UPDNM">수정자</td>
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
			<div class="content_layout tabs bottom_layout">
				<ul class="tab tab_style02">
					<li><a href="#tab2-1"><span>단위환산마스터</span></a></li>
					<li><a href="#tab2-2"><span>생산버전(BOM)</span></a></li>
					<li class="btn_zoom_wrap">
						<ul>
							<li><button class="btn btn_bigger"><span>확대</span></button></li>
						</ul>
					</li>
				</ul>
				<div class="table_box section" id="tab2-1">
					<div class="table_list01">
						<div class="scroll">
							<table class="table_b">
								<tbody id="gridList2_A">
									<tr CGRow="true">
										<td GH="40" GCol="rownum">1</td>
										<td GH="0" GCol="text,MATNR" style="text-align:center;">자재코드</td>
										<td GH="100" GCol="text,UNIT" style="text-align:center;">단위</td>
										<td GH="100" GCol="text,UMREZ" GF="N 5,0">분자</td>
										<td GH="100" GCol="text,UMREN" GF="N 5,0">분모</td>
										<td GH="0" GCol="text,USE_YN">사용유무</td>
										<td GH="0" GCol="text,REGDATE" style="text-align:center;">등록일시</td>
										<td GH="0" GCol="text,REGNM">등록자</td>
										<td GH="0" GCol="text,UPDDATE" style="text-align:center;">수정일시</td>										
										<td GH="0" GCol="text,UPDNM">수정자</td>
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
				<div class="table_box section" id="tab2-2">
					<div class="table_list01">
						<div class="scroll">
							<table class="table_b">
								<tbody id="gridList2_B">
									<tr CGRow="true">
										<td GH="40" GCol="rownum">1</td>
										<td GH="0" GCol="text,MATNR" style="text-align:center;">자재코드</td>	
										<td GH="0" GCol="text,WERKS" style="text-align:center;">플랜트</td>
										<td GH="100" GCol="text,PRCMC" style="text-align:center;">생산버전</td>
										<td GH="120" GCol="text,PRCMC_NM">버전내용</td>
										<td GH="100" GCol="text,PRT_MATNR_QTY" GF="N 13,3">모품목기준수량</td>
										<td GH="90" GCol="text,PRT_MATNR_UNIT" style="text-align:center;">모품목기준수량 단위</td>
										<td GH="100" GCol="text,ATN_BOM_NO">대체BOM</td>
										<td GH="100" GCol="text,ITEM_NO">항목 번호</td>
										<td GH="100" GCol="text,BOM_NO">BOM NUM</td>
										<td GH="140" GCol="text,SUB_MATNR" style="text-align:center;">자품목자재</td>
										<td GH="320" GCol="text,SUB_MATNR_NM">자품목자재명</td>
										<td GH="100" GCol="text,SUB_MATNR_QTY" GF="N 13,3">수량</td>
										<td GH="80" GCol="text,SUB_MATNR_UNIT" style="text-align:center;">수량단위</td>
										<td GH="100" GCol="text,AUSCH">스크랩</td>
										<td GH="100" GCol="text,ITSOB">특별유형</td>
										<td GH="100" GCol="text,DL_YN">삭제여부</td>
										<td GH="0" GCol="text,USE_YN">사용유무</td>
										<td GH="0" GCol="text,REGDATE" style="text-align:center;">등록일시</td>
										<td GH="0" GCol="text,REGNM">등록자</td>
										<td GH="0" GCol="text,UPDDATE" style="text-align:center;">수정일시</td>										
										<td GH="0" GCol="text,UPDNM">수정자</td>
									</tr>
								</tbody>
							</table>
						</div>
					</div>
					<jsp:include page="/WEB-INF/jsp/common/commonBtnAuth.jsp">
						<jsp:param name="authCd" value="3" />
						<jsp:param name="showAuthCd" value="1,2,3,7,9,10" />
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