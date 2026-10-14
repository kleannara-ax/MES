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

    $(document).ready(function(){
        var isMobile = navigator.userAgent.match(/(iPhone|iPod|iPad|Android|BlackBerry)/); 

        gridList.setGrid({
			id : "gridList",
			module : "WmsMobile",
			command : "TE54"
        });
        
    });

	var $callBarcodeObj;
	function callBarcode(objId){
		//alert(objId);
		$callBarcodeObj = $("#"+objId);
		var data = {'callbackFn' : 'getBarCode'};
		$.callApp('20', data);
	}
	
	function getBarCode(data){
		var obj = eval("("+data+")");
		$callBarcodeObj.val(obj["SCAN_RESULT"]);
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
						</tr>
					</tbody>
				</table>
			</div>

			<div class="tableWrap_search section" >
				<div class="tableHeader">
					<table style="width: 100%">
						<colgroup>
							<col width="60px" />
							<col width="150px"/>
							<col width="200px" />	
							<col width="100px" />
							<col width="100px" />
						</colgroup>
						<thead>
							<tr>
								<th>번호</th>
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
							<col width="150px"/>
							<col width="200px" />	
							<col width="100px" />
							<col width="100px" />
						</colgroup>
						<tbody id="gridList">
							<tr CGRow="true">
								<td GCol="rownum">1</td>
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
					<td onclick="gridList.setNextRowFocus('gridList')">&gt;</td>
				</tr>
			</table>
		</div><!-- end footer_5 -->
</div>
</body>
</html>