<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Grid default</title>
<%@ include file="/common/include/webdek/head.jsp" %>
<script src="https://ssl.daumcdn.net/dmaps/map_js_init/postcode.v2.js"></script>
<script type="text/javascript" src="/common/js/daumpost.js"></script>
<script type="text/javascript">
	$(document).ready(function(){

	});
	
	function execDaumPostcodeEnd(areaIdList, zipCode, addr, extraAddr){
		commonUtil.debugMsg("execDaumPostcodeEnd : ", arguments);
	}
</script>
</head>
<body>
<%@ include file="/common/include/webdek/layout.jsp" %>
<!-- content -->
<div class="content_wrap">
	<div class="content_inner">
		<%@ include file="/common/include/webdek/title.jsp" %>
        <div class="search_next_wrap">
			<div class="content_layout tabs">
				<ul class="tab tab_style02" >
					<li><a href="#tab1-1"><span>주소</span></a></li>
				</ul>
				<div class="table_box" id="tab1-1">
					<div class="inner_search_wrap">
						<table class="detail_table" id="addrArea">
							<colgroup>
								<col width="20%" />
								<col width="80%" />
							</colgroup>
							<tbody>			
								<tr>
									<th CL="ZIPCODE"></th>
									<td>
										<input type="text" class="input" name="ZIPCODE" readonly="readonly"/>
										<input type="button" class="btn_red" value="주소입력"  onClick="execDaumPostcode(['addrArea'], 'ZIPCODE', 'ADDR1', 'ADDR2')"/>
									</td>
								</tr>
								<tr>
									<th CL="ADDR1"></th>
									<td>
										<input type="text" class="input" name="ADDR1" style="width:300px" readonly="readonly"/>
									</td>
								</tr>
								<tr>
									<th CL="ADDR2"></th>
									<td>
										<input type="text" class="input" name="ADDR2" style="width:300px" />
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
<%@ include file="/common/include/webdek/bottom.jsp" %>
</body>
</html>