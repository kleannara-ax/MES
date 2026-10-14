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
		$(document).ready(function(){
			/**Tree 생성.
			 setGrid (tree : 1.level, 2.tree구조로 변경 될 컬럼, 3.부모 key, 4.primary key, 5. 정렬순서)
			 td attribute : GCol="tree,컬럼명"
			 */
			gridList.setGrid({
					id : "gridList",
					url : "/mes/Work/WRK17/json/datalist.data",
					bigdata : false,
					colHoldType : true,
					colHold : "",
					tree : "LEVEL,PROC_NM,IN_BCD_M,IN_BCD,1"
			});
		});

		const barcode = () => {
			var url = "/mes/wrk/WRK17_POP01.page";
			page.linkPopOpen(url, "P100", "height=600,width=850");
		}

		function searchList(){
			if(validate.check("searchArea")){
				var param = inputList.setRangeParam("searchArea");
				
				if(param.get("IND_BCD").length != 10){
					$("#IND_BCD").select();
					return alert('바코드 또는 LOT번호를 10자리까지 입력하세요.');
				}
				param.put("P_TYPE", "LIST");
				param.put("IND_BCD", $("#IND_BCD").val().toUpperCase()) // 개별바코드
				gridList.gridList({
					id : "gridList",
					param : param
				});
			}
		}

		function commonBtnClick(btnName){
			//commonUtil.debugMsg("commonBtnClick : ", arguments);
			if(btnName == "Search"){
				searchList();
			}
		}

		function gridListEventDataBindEnd(gridId, dataLength){
			if(gridId == "gridList" && dataLength > 0){
				var list = gridList.getGridData(gridId, true);
				for(var i in list){
					var row = list[i];
					var rowNum = row.get(configData.GRID_ROW_NUM);
					var menuId = row.get("IND_BCD");

					var childrenList = list.filter(function(data){
						var pMenuId = data.get("IND_BCD_M");
						return menuId == pMenuId;
					});
					if(childrenList.length == 0){
						var $row = $("#" + gridId + " tr[" + configData.GRID_ROW_NUM + "=" + rowNum +"]");
						var $treeObj = $row.find("td[" + configData.GRID_COL_TYPE + "=tree]");
						$treeObj.find("span").eq(0).css("background", "none");
					}
				}
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
					<input type="button" CB="Search SEARCH BTN_SEARCH" />
				</div>
			</div>
			<div class="search_inner">
				<div class="search_wrap ">
					<dl>
						<dt>바코드 / LOT번호</dt>
						<dd>
							<input type="text" class="input" id="IND_BCD" name="IND_BCD" validate="required" UIFormat="U"/>
							<button type="button" class="btn btn_search" onclick="barcode()">
								<span>search</span>
							</button>
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
					<li><a href="#tab1-1"><span CL="STD_GRD_WRK17">리스트</span></a></li>
				</ul>
				<div class="table_box section" id="tab1-1">
					<div class="table_list01">
						<div class="scroll">
							<table class="table_b">
								<tbody id="gridList">
								<tr CGRow="true">
									<td GH="40" GCol="rownum">1</td>
									<td GH="200 공정" GCol="tree,PROC_NM" style='text-align:center;'></td>
									<td GH="100 바코드" GCol="text,IND_BCD" style='text-align:center;'></td>
									<td GH="100" GCol="text,LOT_NO" style='text-align:center;'></td>
									<td GH="100 상위바코드" GCol="text,IND_BCD_M" style='text-align:center;'></td>
									<td GH="100 상위LOT번호" GCol="text,LOT_NO_M" style='text-align:center;'></td>
									<td GH="100 상태" GCol="text,STA" style='text-align:center;'></td>
									<td GH="100 비계획" GCol="text,NAUFNR" style='text-align:center;'></td>
									<td GH="100 권치수" GCol="text,ROLLCNT" GF="N 13"></td>
									<td GH="80" GCol="text,ROLLUNIT" style="text-align: center;">권치수단위</td>
									<td GH="100 연수" GCol="text,PCNT" GF="N 13,1"></td>
									<td GH="80" GCol="text,RUNIT" style="text-align: center;">연수단위</td>
									<td GH="100 중량" GCol="text,WGT" GF="N 13,3"></td>
									<td GH="80" GCol="text,WUNIT" style="text-align: center;">중량단위</td>
									<!-- <td GH="100 페품량" GCol="text,DISP_QTY" GF="N 13"></td>
									<td GH="100 페품연수" GCol="text,DISP_ROLLCNT" GF="N 13,1"></td>
									<td GH="100 페품중량" GCol="text,DISP_WGT" GF="N 13,3"></td> -->
									<!-- <td GH="100 CNFRM_NO" GCol="text,CNFRM_NO" style='text-align:center;'></td> -->
									<td GH="130" GCol="text,WRK_ORDR_NO" style='text-align:center;'></td>
									<td GH="100" GCol="text,WRK_ORDR_SEQNO" style='text-align:center;'></td>
									<td GH="140" GCol="text,MATNR" style='text-align:center;'></td>
									<td GH="120 PP에러" GCol="text,PP_ERR" style='text-align:center;'></td>
									<td GH="100 사용자" GCol="text,REGID" style='text-align:center;'></td>
									<td GH="140" GCol="text,REGDATE" style='text-align:center;'></td>
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
<!-- // content -->
<%@ include file="/common/include/webdek/bottom.jsp" %>
</body>
</html>