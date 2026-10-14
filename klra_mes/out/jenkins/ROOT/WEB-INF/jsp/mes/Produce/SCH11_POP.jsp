<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>비계획생산 추가</title>
<%@ include file="/common/include/webdek/head.jsp" %>
<script type="text/javascript">
	// 저장
	function saveData(){
		if(gridList.validationCheck("gridList", "all")){
			gridList.gridSave({
		    	id : "gridList",
		    	modifyType : "A"
		    });
		}
	}
	
	// 버튼(조회, 저장 등) 클릭
	function commonBtnClick(btnName){
		if(btnName == "Save"){
			saveData();
		}else if(btnName="Bom"){
			var url = "/mes/Produce/BOM_POP.page";
			page.linkPopOpen(url, "", "height=900,width=1300");
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
					<input type="button" id="button-0-2" CB="Save SAVE BTN_SAVE" />
				</div>
			</div>
			<div class="search_inner">
				<div class="content_layout tabs">
					<div class="table_box">
						<div class="inner_search_wrap">
							<table class="detail_table">
								<colgroup>
									<col width="10%" />
									<col width="20%" />
									<col width="10%" />
									<col width="20%" />
									<col width="10%" />
									<col width="20%" />
								</colgroup>
								<tbody id="gridList">	
									<tr>
										<th CL="STD_PLANT">플랜트</th>
										<td>
											<input type="text" class="input" name="WERKS" UIInput="S,PLANT" UIFormat="U"/>
										</td>
										<th CL="STD_ORDR_GEN_DT">지시생성일자</th>
										<td>
											<input type="text" class="input" name="ORDR_GEN_DT" UIInput="B" UIFORMAT="C M1" style="width: 30%;"/>
										</td>
										<th CL="STD_PRD_REQ_DT">생산요청일자</th>
										<td>
											<input type="text" class="input" name="PRD_REQ_DT" UIInput="B" UIFORMAT="C M1"/>
										</td>
									</tr>		
									<tr>
										<th CL="STD_MATNR">자재코드</th>
										<td>
											<input type="text" class="input" name="MATNR" UIInput="S,MATKY" UIFormat="U"/>
										</td>
										<th CL="STD_MACHINE">생산호기</th>
										<td>
											<select class="input" name="MACHINE" CommonCombo="MACHINE">
												<option value="">All</option>
											</select>
										</td>
										<th CL="STD_WRK_ORDR_QTY">지시량</th>
										<td>
											<input type="text" class="input" name="WRK_ORDR_QTY" UIFormat="N 5"/>
										</td>
									</tr>
									<tr>
										<th CL="STD_BOM_NO">BOM_Num</th>
										<td>
											<input type="text" class="input" name="BOM_NO" UIFormat="U"/>
											<input type="button" CB="Bom BOM BTN_BOM"/>
										</td>
										<th CL="STD_UNIT">단위</th>
										<td>
											<input type="text" class="input" name="UNIT" UIFormat="U"/>
										</td>
										<th CL="STD_PCODE">지종코드</th>
										<td>
											<input type="text" class="input" name="PCODE" UIFormat="U"/>
										</td>
									</tr>
									<tr>
										<th CL="STD_JRCNT">J/R 개수</th>
										<td>
											<input type="text" class="input" name="JRCNT" UIFormat="N 2"/>
										</td>
										<th CL="STD_JWIDTH">J/R 지폭</th>
										<td>
											<input type="text" class="input" name="JRCNT" UIFormat="N 5"/>
										</td>
										<th CL="STD_JROLLCNT">J/R 권치수</th>
										<td>
											<input type="text" class="input" name="JROLLCNT" UIFormat="N 2"/>
										</td>
									</tr>
									<tr>
										<th CL="STD_BS_WGT">평량</th>
										<td>
											<input type="text" class="input" name="BS_WGT" UIFormat="N 5"/>
										</td>
										<th CL="STD_WRK_ORDR_REMARK">작업지시비고</th>
										<td colspan="3">
											<input type="text" class="input" name="WRK_ORDR_RMK" style="width: 90%;"/>
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
</div>
<!-- // content -->
<%@ include file="/common/include/webdek/bottom.jsp" %>
</body>
</html>