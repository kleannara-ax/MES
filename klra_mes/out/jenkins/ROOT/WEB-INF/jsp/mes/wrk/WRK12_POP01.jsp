<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>실적취소사유</title>
<%@ include file="/common/include/webdek/head.jsp"%>
<link rel="stylesheet" type="text/css"
	href="/common/theme/webdek/css/demo_layout.css">
<script type="text/javascript">
	// 저장
    function saveData(){
    	if($("#CNL_RMK").val() == ""){
    		alert("취소사유를 입력하십시오.");
    		return;
    	}
    	
    	if(!commonUtil.msgConfirm("실적취소하시겠습니까?")){
			return;
		}
    	
    	var param = new DataMap();
    	param.put("P_TYPE", "DELETE")
    	param.put("list", page.getLinkPopData())
    	param.put("P_CNL_RMK", $("#CNL_RMK").val())
    	
    	netUtil.send({
			url : "/mes/Work/WRK12/json/datalist.data",
			param : param,
			successFunction : "saveSuccessCallBack"
		})
    }
    
    function saveSuccessCallBack(json){
    	if(json){
    		if(json.P_SUCCESS == "Y"){
    			var param = new DataMap();
    			
    			var docno = json.DOC_NO1.split(',');
    			var message = '';
    			
    			const list = page.getLinkPopData()
    			for(var i = 0; i < docno.length; i++){
    				param.put("IFID", "MES_IF_129");
           			param.put("DOC_NO", docno[i]);
           			//실적취소
           			var json2 = netUtil.sendData({
       	            	url : "/mes/erpif/json/sendIF.data",
       	            	async : false,
       	            	param : param
       	            });
           			
           			const array = []
       				if(json2.data == "SUCCESS"){
       					array[0] = list[i]
       					
       					// 2023-01-05(목요일) 안상현, 실적 취소 로직 추가
           				const obj = new DataMap()
           				obj.put("P_TYPE", "실적취소")
           				obj.put("list", array)
           				obj.put("P_CNL_RMK", $("#CNL_RMK").val())
           				
           				const result = netUtil.send({
							url : "/mes/Work/WRK12_RB/json/datalist.data",
							async : false,
							param : obj
						})
						
						if(result.P_SUCCESS === "Y"){
							message = '(SAP 실적취소) ' + (i + 1) + '번째 실적취소 성공 \n\n' + message
						}
       				}else{
       					message = '(SAP 실적취소) ' + (i + 1) + '번째 ' + json2.data + '\n' + message;
       				}
    			}
    			
    			alert(message)
    		}else{
    			alert(json.ERR_MSG);
    		}
    		page.linkPopClose();
    	}
    }
    
    // 버튼 클릭(저장)
    function commonBtnClick(btnName){
    	if(btnName == "Save"){
    		saveData()
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
						<input type="button" id="button-0-3" CB="Save SAVE BTN_SAVE" />
					</div>
				</div>
			</div>
			<div class="search_next_wrap" style="height: 90%;">
				<div class="content_layout tabs">
					<ul class="tab tab_style02">
						<li><a href="#tab1-1"><span>실적취소사유</span></a></li>
						<li class="btn_zoom_wrap">
							<ul>
								<li><button class="btn btn_bigger"><span>확대</span></button></li>
							</ul>
						</li>
					</ul>
					<div class="table_box" id="tab1-1">
						<div class="inner_search_wrap">
							<table class="detail_table" id="detail">
								<colgroup>
									<col width="1%" />
									<col width="7%" />
								</colgroup>
								<tbody>			
									<tr>
										<th>취소사유</th>
										<td>
											<input type="text" class="input" style="width: 100%;" id="CNL_RMK" />
										</td>
									</tr>
								</tbody>
							</table>
						</div>
					</div>
				</div>
			</div>
		</div>
	</div>
	<!-- // content -->
	<%@ include file="/common/include/webdek/bottom.jsp"%>
</body>
</html>