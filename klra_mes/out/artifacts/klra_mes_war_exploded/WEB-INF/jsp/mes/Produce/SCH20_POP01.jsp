<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<style type="text/css">
	.search_wrap{height: 175px;}
	.message span{color: #e86b29;font-size: 12px;font-weight: bold;}
	.title span{
		box-sizing: border-box;
	    display: inline-block;
	    padding: 10px 20px;
	    font-size: 12px;
	    vertical-align: top;
	    height: 100%;
	    font-weight: bold;
	    border-bottom: 2px solid #e86b29;
	}
	.content{width: 100%;height:35px;padding-top: 10px;}
	.content ul li{float: left;}
	.content #searchArea li.th{width: 250px;}
	.content #searchArea li.td{width: calc(100% - 190px);}
	.content #searchArea li.td input{width: 100%;}
	.content #searchArea li.td input[readonly="readonly"]{background-color: #e8e9eb !important;}
	.content#menuGroup ul{width: 100%;}
	.content#menuGroup ul li{height: 30px;border: 1px solid #dadfe2;}
	.content#menuGroup ul li.th{width: 100px;background-color: #e8e9eb;font-weight: bold;padding-left: 5px;line-height: 30px;}
	.content#menuGroup ul li.td{width: calc(100% - 118px);background-color: transparent;}
	.content#menuGroup ul li.td input{width: 100%;height: 100%;border: 0;outline: none;}
	
	.btn_wrap .fl_l{padding: 0;height: 25px;}
	.btn_wrap .fl_l .selectAll{
		width: 25px;
	    height: 25px;
	    border: 2px solid #99a4b1;
	}
	.btn_wrap .fl_l .selectAll.on{
		display: inline-block;
		background: url(/common/theme/webdek/images/save.png) no-repeat;
	    background-size: 14px;
	    background-position: center;
	    margin: 0;
	}
	.btn_wrap .fl_l span{
		height: 100%;
	    line-height: 25px;
	    padding-left: 5px;
	    display: inline-block;
	    vertical-align: top;
	    font-size: 12px;
	}
</style>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>MES</title>
<%@ include file="/common/include/webdek/head.jsp" %>
<script type="text/javascript">
	$(document).ready(function(){
		configData.MENU_ID = "SCH20_POP01";
		
		gridList.setGrid({
	    	id : "gridList",
	    	url : "/mes/Produce/SCH20_POP01/json/datalist.data",
	    	bigdata : false
	    });
		
		// 조회
		searchList()
	});
	
	const searchList = () => {
		var param = new DataMap()
		param.put("P_TYPE","LIST")
		param.put("PLN_YR",$("#PLN_YR").val())
			
		gridList.gridList({
			id : "gridList",
			param : param
		});
	}
	 
	// 저장
	function saveData(){
		// validation(복사할 계획년도 > 계획년도)
		// 계획년도
		const PLN_YR = $("#PLN_YR").val()
		
		// 복사할 계획년도
		const CP_PLN_YR = $("#CP_PLN_YR").val()		
		
		if(Number(CP_PLN_YR) <= Number(PLN_YR)){
			alert("복사할 계획년도가 계획년도 이하입니다.")
			$("#CP_PLN_YR").focus()
			return
		}
		
		// validation(선택된 행)
		const data = gridList.getSelectData("gridList")
		if(data.length < 1){
			alert("선택된 행이 없습니다. 복사할 행을 선택하세요.")
			return
		}
		
		if(!commonUtil.msgConfirm(configData.MSG_MASTER_SAVE_CONFIRM)){
			return;
		}
		
		if(gridList.validationCheck("gridList", "all")){
			var param = new DataMap();
			
			param.put("P_TYPE","SAVE");
			param.put("list", data);
			// 복사할 년도
			param.put("CP_PLN_YR", $("#CP_PLN_YR").val())
			// 계획년도
			param.put("PLN_YR", $("#PLN_YR").val())
			
			var json = netUtil.sendData({
				url : "/mes/Produce/SCH20_POP01/json/datalist.data",
				param : param,
			});
			
			this.close();
		}
	}
	
	// 버튼 클릭(조회, 저장 등)
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
		}else if(btnName === "Save"){
			saveData()
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
		<div class="content_serch">
			<div class="btn_wrap">
				<div class="fl_l">
				</div>
				<div class="fl_r">
					<input type="button" id="button-0-1" CB="Search SEARCH BTN_SEARCH" />
					<input type="button" id="button-0-2" CB="Save SAVE BTN_SAVE"/>
				</div>
			</div>
			<div class="search_inner">
				<div class="search_wrap">
					<div class="message">
						<span>*복사할 년도와 계획년도를 선택 해주세요.</span>
					</div>
					<div class="content">
						<ul id="searchArea">
							<li class="th">
								복사할 년도 : <select class="input" id="CP_PLN_YR" name="CP_PLN_YR" CommonCombo="PLN_YR"></select>
							</li>
							<li class="th">
								계획년도 : <select class="input" id="PLN_YR" name="PLN_YR" CommonCombo="PLN_YR"></select>
							</li>
						</ul>
					</div>
				</div>
			</div>
		</div>
        <div class="search_next_wrap">
			<div class="content_layout tabs">
				<ul class="tab tab_style02">
					<li><a href="#tab1-1"><span CL="STD_GENERAL">일반</span></a></li>
					<li class="btn_zoom_wrap">
						<ul>
							<li>
								<button class="btn btn_bigger">
									<span>확대</span>
								</button>
							</li>
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
										<td GH="100" GCol="text,WERKS" style="text-align:center;">플랜트</td>
										<td GH="100" GCol="text,MACH_CD" style="text-align:center;">설비코드</td>
										<td GH="150" GCol="text,MACH_NM">설비명</td>
										<td GH="100" GCol="text,MGMT_ITEM_CD" style="text-align: center;">관리항목코드</td>
										<td GH="300" GCol="text,MGMT_ITEM_NM">관리항목명</td>
										<td GH="100" GCol="text,UNIT_NM">단위명</td>
										<td GH="100" GCol="text,DEPT_CD">부서코드</td>
										<td GH="100" GCol="text,DEPT_KR_NM">부서명</td>
										<td GH="0" GCol="text,COMPKY">회사코드</td>
										<td GH="0" GCol="text,USE_YN">사용여부</td>
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