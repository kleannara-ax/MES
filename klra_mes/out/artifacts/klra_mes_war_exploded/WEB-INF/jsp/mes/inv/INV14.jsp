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
		gridList.setGrid({
			id : "gridList",
			url:"/common/Inv/list/json/INV14.data",
			bigdata : false,
			colHoldType : true,
			colHold : 'MATNR_M'
		})
	});
	
	function searchList(){
		if(validate.check("searchArea")){
			var range = inputList.setRangeParam("searchArea");
			var param = inputList.setRangeParam('searchArea');

			if(range.get('WERKS') == 'P100'){
				alert('HL 생활용품팀이 관리하는 화면입니다.');
				return;
			}
			var param = new DataMap();
			
			param.put("P_TYPE", "LIST");
			param.put("WERKS", range.get('WERKS'));
			param.put("SDATE",$("#REQ_DT").parent().children().eq(1).val().replace(/-/gi,""));
			param.put("EDATE",$("#REQ_DT").parent().children().eq(4).val().replace(/-/gi,""));

			gridList.gridList({
		    	id : "gridList",
		    	param : param
		    });
		}
	}
	
	function commonBtnClick(btnName){
		if(btnName == "Search"){
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
				</div>
			</div>
			<div class="search_inner">
				<div class="search_wrap ">
					<dl>
						<dt CL="STD_WERKS">플랜트</dt>
						<dd>
							<input type="text" class="input"  name="WERKS" id="WERKS" UIInput="S,PLANT" UIFormat="U" validate='required'/>
						</dd>
					</dl>
					<dl>
						<dt>요청일자</dt>
						<dd>
							<input type="text" id="REQ_DT" name="REQ_DT" UIInput="B" UIFORMAT="C M1" />
						</dd>
					</dl>
				</div>
				<div class="btn_tab">
					<input type="button" class="btn_more" value="more" onclick="searchMore()"/>
				</div>
			</div>
		</div>
        <div class="search_next_wrap">
			<div class="content-horizontal-wrap" >	
				<div class="content_layout tabs">
					<ul class="tab tab_style02">
						<li><a href="#tab1-1"><span>입고이력</span></a></li>
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
											<td GH="100" GCol="text,RCVCDS_DT" style="text-align: center;">입고일자</td>
											<td GH="100" GCol="text,STOR_LOC_CD" GF="D" style="text-align:center;">저장위치</td>
											<td GH="140" GCol="text,MATNR" style="text-align: center;" >자재코드</td>
											<td GH="320" GCol="text,MATNR_NM">자재명</td>
											<td GH="100" GCol="text,LOT_NO" style="text-align: center;">LOT_NO</td>
											<td GH="100" GCol="text,IND_BCD">개별바코드</td>
											<td GH="100" GCol="text,RCVGDS_QTY" GF="N 13">입고중량</td>
											<td GH="100" GCol="text,STCK_STA">상태</td>
											<td GH="100" GCol="text,CDESC1">상태명</td>
											<td GH="100" GCol="text,STCK_QTY" GF="N 13">재고중량</td>
										</tr>
									</tbody>
								</table>
							</div>
						</div>
						<jsp:include page="/WEB-INF/jsp/common/commonBtnAuth.jsp">
							<jsp:param name="authCd" value="1" />
							<jsp:param name="showAuthCd" value="1,2,3,7,9,10" />
						</jsp:include>
					</div>
				</div>				
			</div>
		</div>
	</div>
</div>
<!-- // content -->
<%@ include file="/common/include/webdek/bottom.jsp" %>
</body>
</html>