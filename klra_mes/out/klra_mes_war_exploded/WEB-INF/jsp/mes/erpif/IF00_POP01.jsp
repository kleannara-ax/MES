<%@ page language="java" contentType="text/html; charset=UTF-8"
		 pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	<title>인터페이스 실적전송</title>
	<%@ include file="/common/include/webdek/head.jsp" %>
	<script type="text/javascript">

		window.resizeTo('700','400');
		
		$(document).ready(function(){
			var data = page.getLinkPopData();

			iftbl = data[0].get("IFTBL");
			grpcd = data[0].get("GRP_CD");
			
			$("#IFTBL").val(iftbl);

			gridList.setGrid({
				id : "gridList",
				module : 'Erpif',
				command : 'UnProcess'
			});

			searchList();
		});

		function searchList(){
			var param = new DataMap();
			
			param.put('IFTBL', iftbl);
			
			gridList.gridList({
				id : "gridList",
				param : param
			});
		}

		function fn_closing(){
			window.opener.searchList();
			this.close();
		}

		function commonBtnClick(btnName){
			if(btnName == "Send"){
				send();
			} else if(btnName == "Close"){
				fn_closing();
			}
		}

		function send(){
			var list = gridList.getSelectData("gridList");
			
			if(list.length == 0 )	return alert('처리할 항목을 선택하세요.');
			if(list.length > 1)	return alert('하나의 항목만을 처리할 수 있습니다.');
			// check validation
			if(gridList.validationCheck("gridList", "data")) {
				//전송하시겠습니까?
				if(!commonUtil.msgConfirm('처리하시겠습니까?')){
					return;
				}
				var ifid = list[0].get('IFID');
				var ifmeskey = list[0].get('IF_MES_KEY');
				var param = new DataMap();
				
				param.put('i_IF_MES_ID', ifid);
				param.put('i_IF_MES_KEY', ifmeskey);
				
				if(grpcd == 'A'){
					//기준정보
					netUtil.send({
						url : '/mes/Erpif/SP_MAS_GET_IFR/json/datalist.data',
						param : param,
						successFunction : 'saveSuccessCallBack'
					});
				}else{
					//생산오더
					netUtil.send({
						url : '/mes/Erpif/SP_SCH_GET_IFR/json/datalist.data',
						param : param,
						successFunction : 'saveSuccessCallBack'
					});	
				}
			}
		}
		
		function saveSuccessCallBack(json){
			if(json.o_msg_CODE = '0'){
				alert('처리 완료했습니다.');
				searchList();
			}else{
				alert(json.o_msg_MSG);
			}
			window.opener.searchList();
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
					<input type="button" CB="Send SAVE 데이터처리">
					<input type="button" CB="Close CHECK 닫기">
				</div>
			</div>
		</div>
		<div class="search_next_wrap">
			<div class="content_layout tabs">
				<ul class="tab tab_style02">
					<li><a href="#tabs1-1" CL='STD_LIST'><span>리스트</span></a></li>
				</ul>
				<div class="table_box section" id="tabs1-1">
					<div class="table_list01">
						<div class="scroll">
							<table class="table_c">
								<tbody id='gridList'>
									<tr CGRow='true'>
										<td GH="40" GCol="rownum"></td>
										<td GH="40" GCol="rowCheck"></td>
										<td GH="100" GCol="text,IFID">인터페이스ID</td>
										<td GH="300" GCol="text,IF_MES_KEY">인터페이스KEY</td>
										<td GH='100' GCol='text,CNT'>미처리건수</td> 
									</tr>	
								</tbody>
							</table>
						</div>
					</div>

					<div class="btn_lit tableUtil" id="resetUtil">
						<span class='txt_total' >총 건수 : <span GInfoArea='true'>0</span></span>
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