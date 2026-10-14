<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%-- 
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
 --%>
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
		configData.MENU_ID = "SCH21_POP01";
		
		// 검색 조건 셋팅
		f("")
		
		gridList.setGrid({
	    	id : "gridList",
	    	url : "/mes/Produce/SCH21_POP01/json/datalist.data",
	    	bigdata : false,
	    	colHoldType : true,
	    	colHold : "WERKS,MACH_CD,MACH_NM,MACH_SHRT_NM"
	    });
		
		// 조회
		searchList($("#PLN_MM").val())
	});
	
	// 검색 조건 셋팅
	const f = (obj) => {
		// 옵션 삭제
		$("select#PLN_MM option").remove();
		$("select#CP_PLN_MM option").remove();
		
		// 사업목표가 등록되어있는 계획년월 리스트
		const param = new DataMap()
		param.put("PLN_YR", $("#PLN_YR", opener.document).val())
		const json = netUtil.sendData({
			url : "/common/Produce/list/json/SCH21_POP01_SELECTYM.data",
			param : param,
		});
		
		if(json["data"].length === 0){
			alert("해당년도에 등록되어 있는 사업목표가 존재하지 않습니다.")
			window.close()
		}else{
			const datas = json["data"]
			for(const key in datas){
				const data = datas[key]
				const PLN_MM = data["PLN_MM"]
				const PLN_YR_MM = data["PLN_YR_MM"]
				
				$("#PLN_MM").append("<option value="+PLN_MM+">"+PLN_YR_MM+"</option>")
			}
		}
		
		if(obj) $("#PLN_MM").val(obj)
		
		// 복사할 년월 추가
		for(let i = 1; i <= 12; i++){
			if(Number(i) > Number($("#PLN_MM").val())){
				$("#CP_PLN_MM").append("<option value="+fillZero(i,2)+">["+$("#PLN_YR",opener.document).val()+" "+fillZero(i,2)+"]</option>")	
			}
		}
	}
	
	const searchList = (obj) => {
		var param = new DataMap()
		param.put("P_TYPE","LIST")
		
		param.put("PLN_YR", $("#PLN_YR", opener.document).val())
		param.put("PLN_MM",$("#PLN_MM").val())
			
		gridList.gridList({
			id : "gridList",
			param : param
		});
		
		console.log("value : "+obj)
		f(obj)
	}
	 
	// 저장
	function saveData(){
		
		// validation(선택된 행)
		const data = gridList.getGridData("gridList")
		
		if(!commonUtil.msgConfirm(configData.MSG_MASTER_SAVE_CONFIRM)){
			return;
		}
		
		var param = new DataMap();
		
		param.put("P_TYPE","SAVE");
		param.put("list", data);
		
		// 계획 년
		param.put("PLN_YR", $("#PLN_YR", opener.document).val())
		// 복사할 년월
		param.put("CP_PLN_MM", $("#CP_PLN_MM").val())
		// 계획년월
		param.put("PLN_MM", $("#PLN_MM").val())
		// 데이터를 판별할 구분자
		param.put("YN", "N")
		
		var json = netUtil.sendData({
			url : "/mes/Produce/SCH21_POP01/json/datalist.data",
			param : param,
		});
		
		let tf = true
		if(json["P_SUCCESS"] === "N"){
			if(confirm("복사할 년월에 사업목표 데이터가 존재합니다. \n 데이터 리셋 후 복사하시겠습니까?")){
				tf = true
			}else{
				tf = false
			}
		}
		
		if(tf){
			param.put("YN", "Y")
			var json = netUtil.sendData({
				url : "/mes/Produce/SCH21_POP01/json/datalist.data",
				param : param,
			});
			
			if(json){
				commonUtil.msgBox(configData.MSG_SYSTEM_SAVEOK)
				searchList($("#PLN_MM").val())
			}
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
			
			searchList($("#PLN_MM").val())
		}else if(btnName === "Save"){
			saveData()
		}
	}
	
	// 숫자 자리 수 앞에서부터 0
	function fillZero(n, digits){
		let zero = ""
		n = n.toString()

		if(n.length < digits){
			for(var i = 0; i < digits - n.length; i++){
				zero += "0"
		  	}
		}
			
		return zero + n
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
						<span>*계획년월과 복사할 년월을 선택 해주세요.</span>
					</div>
					<div class="content">
						<ul id="searchArea">
							<li class="th">
								계획년월 : 
								<select class="input" id="PLN_MM" name="PLN_MM" onchange="f(this.value)"></select>
							</li>
							<li class="th">
								복사할 년월 : 
								<select class="input" id="CP_PLN_MM" name="CP_PLN_MM"></select>
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
										<td GH="100" GCol="text,WERKS">플랜트</td>
										<td GH="100" GCol="text,MACH_CD">설비코드</td>
										<td GH="150" GCol="text,MACH_NM">설비명</td>
										<td GH="150" GCol="text,MACH_SHRT_NM">설비명(단축)</td>
										<td GH="100" GCol="text,MGMT_ITEM_CD" style="text-align: center;">관리항목코드</td>
										<td GH="200" GCol="text,MGMT_ITEM_NM">관리항목명</td>
										<td GH="100" GCol="text,UNIT_NM">단위명</td>
										<td GH="200" GCol="text,DEPT_NM">부서명</td>
										<td GH="150" GCol="text,BUSI_PLN_AMT" GF="N 10">사업계획량</td>
										<td GH="150" GCol="text,EXCTN_PLN_AMT" GF="N 10">실행계획량</td>
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