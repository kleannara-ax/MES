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
    		return
    	}
    
    	const param = page.getLinkPopData()
		param.put("P_CNL_RMK",$("#CNL_RMK").val())
    	
    	if(confirm("실적취소하시겠습니까?")){
    		// 실적 취소
    		netUtil.send({
                url : "/mes/Work/POP_WRK30/json/datalist.data",
                param : param,
                successFunction : "saveSuccessCallBack"
            });
    	}
    }
	
	function saveSuccessCallBack(json){
		if(json.RS_CODE == "E"){
			alert(json.RS_MSG)
		}else if(json.RS_CODE == "S"){
			rfcRequest(json)
		}
	}
	
	// rfc 폐품취소, 실적취소 요청
	const rfcRequest = (json) => {
		
		// 폐품 취소
		const DISPO_PARAM = new DataMap()
		// 폐품 취소 인터페이스 아이디
		const DISPO_IFID = json.RS_DISPO_I_IF_ID
		const DISPO_DOCNO = json.RS_DISPO_SQL
		
		// 폐품 취소 SAP 오류 메시지
		let DISPO_MSG = ""
		if(DISPO_IFID != ""){
				DISPO_PARAM.put("IFID", DISPO_IFID)
				DISPO_PARAM.put("DOC_NO", DISPO_DOCNO)
				
				const object = netUtil.sendData({
	            	url : "/mes/erpif/json/sendIF.data",
	            	param : DISPO_PARAM
	            })
	            
	            if(object.data != "SUCCESS"){
	            	alert("(SAP 폐품취소)" +object.data);
	            	
	            }else{
	            	// 폐품 취소 후 실적 취소
	        		const PRFM_PARAM = new DataMap()
	        		// 실적 취소 인터페이스 아이디
	        		const PRFM_IFID = json.RS_PRFM_I_IF_ID
	        		const PRFM_DOCNO = json.RS_PRFM_SQL
	        		
	        		
	        		// 실적 취소 SAP 오류 메시지
	        		let PRFM_MSG = ""
	        		if(PRFM_IFID != ""){
	        				PRFM_PARAM.put("IFID", PRFM_IFID)
	        				PRFM_PARAM.put("DOC_NO", PRFM_DOCNO)
	        				
	        				const object = netUtil.sendData({
	        	            	url : "/mes/erpif/json/sendIF.data",
	        	            	param : PRFM_PARAM
	        	            })
	        	            
	        	            if(object.data != "SUCCESS"){
	        	            	alert("(SAP 실적취소)" +object.data);
	        	            	page.linkPopClose();
	        	            }else if(object.data == "SUCCESS"){
	        	            	alert("취소성공.");
	        	            	page.linkPopClose();
	        	            }
	        		}
	            }
		}else if(DISPO_IFID == ""){
			// 폐품 취소없이 실적 취소
    		const PRFM_PARAM = new DataMap()
    		// 실적 취소 인터페이스 아이디
    		const PRFM_IFID = json.RS_PRFM_I_IF_ID
    		const PRFM_DOCNO = json.RS_PRFM_SQL

    		// 실적 취소 SAP 오류 메시지
    		let PRFM_MSG = ""
    		if(PRFM_IFID != ""){
    				PRFM_PARAM.put("IFID", PRFM_IFID)
    				PRFM_PARAM.put("DOC_NO", PRFM_DOCNO)
    				
    				const object = netUtil.sendData({
    	            	url : "/mes/erpif/json/sendIF.data",
    	            	param : PRFM_PARAM
    	            })
    	            
    	            if(object.data != "SUCCESS"){
    	            	alert("(SAP 실적취소)" +object.data);
    	            	page.linkPopClose();
    	            }else if(object.data == "SUCCESS"){
    	            	alert("취소성공.");
    	            	page.linkPopClose();
    	            }
    			}
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