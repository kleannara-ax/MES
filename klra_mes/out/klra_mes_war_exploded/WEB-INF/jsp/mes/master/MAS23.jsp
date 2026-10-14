<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>MES</title>
<%@ include file="/common/include/webdek/head.jsp" %>
<script type="text/javascript">
	$(document).ready(function(){
		gridList.setGrid({
	    	id : "gridList",
	    	url : "/mes/Master/MAS23/json/datalist.data",
	    	bigdata : false,
	    	selectRowDeleteType : true,
	    	colHoldType : true,
	    	colHold : "WERKS,CHK_ITEM_CD,CHK_ITEM_NM,BIG_CAT_NM"
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
	}
	
	function saveData(){
		if(gridList.getModifyRowCount("gridList") == 0 ){
			commonUtil.msgBox("MASTER_M0545");
			
			return;
		}
		if(!commonUtil.msgConfirm(configData.MSG_MASTER_SAVE_CONFIRM)){
			return;
		}
		if(gridList.validationCheck("gridList", "data")){
			var list = gridList.getModifyList("gridList", "A");

			var param = new DataMap();

			param.put("P_TYPE","SAVE");
			param.put("list", list);

			netUtil.send({
				url : "/mes/Master/MAS23/json/datalist.data",
				param : param,
				successFunction : "saveSuccessCallBack"
			});
		}
	}
	
	function saveSuccessCallBack(json){
		if(json&&json.data){
			commonUtil.msgBox(configData.MSG_SYSTEM_SAVEOK);
			searchList();
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
						<dt CL="STD_WERKS">플랜트</dt>
						<dd>
							<input type="text" class="input" name="WERKS" validate="required" UIInput="S,PLANT" UIFormat="U"/>
						</dd>
					</dl>
					
					<dl>
						<dt CL="STD_CHK_ITEM_NM">공정체크항목명</dt>
						<dd>
							<input type="text" class="input" name="CHK_ITEM_NM" UIInput="SR"/>
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
					<li><a href="#tab1-1"><span CL="STD_GENERAL"></span></a></li>
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
										<td GH="100" GCol="add,WERKS,PLANT" validate="required" style="text-align:center;">플랜트</td> 
										<td GH="100" GCol="add,CHK_ITEM_CD" validate="required" style="text-align:center;">공정체크항목코드</td>
										<td GH="100" GCol="input,CHK_ITEM_NM">공정체크항목명</td>
										<td GH="0" GCol="input,MID_CAT_NM">중분류명</td>
										<td GH="100" GCol="input,BIG_CAT_NM">대분류명</td>
										<td GH="130" GCol="input,INSP_STD_1">검사기준1</td>
										<td GH="230" GCol="input,INSP_STD_2">검사기준2</td>
										
										<td GH="100" GCol="select,INPT_DIV" validate="required">
											<select CommonCombo="INPTDIV">입력구분
												<option value=""></option>
											</select>
										</td>
										<td GH="120" GCol="select,MSRM_CYC" validate="required">
											<select CommonCombo="MSRMUNIT">측정주기
												<option value=""></option>
											</select>
										</td>
										<td GH="120" GCol="select,INPT_TYP" validate="required">
											<select CommonCombo="INPTTYP">입력타입
												<option value=""></option>
											</select>
										</td>
										<td GH="140" GCol="select,INPT_MTD" validate="required">
											<select CommonCombo="INPTMTD">입력방법
												<option value=""></option>
											</select>
										</td>
										
										<td GH="100" GCol="input,MSRM_MTD">측정방법</td>
										<td GH="100" GCol="input,MSRM_UNIT">측정단위</td>
										
										<td GH="100" GCol="select,USE_YN">
											<select CommonCombo="USEYN">사용여부
												<option value=""></option>
											</select>
										</td>
										
										<td GH="0" GCol="select,CPK_YN">
											<select CommonCombo="USEYN">CPK계산여부(Y/N)
												<option value=""></option>
											</select>
										</td>
										
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
						<jsp:param name="showAuthCd" value="1,2,3,4,5,6,9,10" />
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