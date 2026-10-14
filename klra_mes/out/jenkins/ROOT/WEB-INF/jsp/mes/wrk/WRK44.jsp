<%@ page language="java" contentType="text/html; charset=UTF-8"
		 pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	<title>MES</title>
	<%@ include file="/common/include/webdek/head.jsp" %>
	<script type="text/javascript">
		$(document).ready(function(){
			gridList.setGrid({
				id : "gridList",
				url : "/mes/Work/WRK44/json/datalist.data",
				bigdata : false
			});
		});

		function comboEventDataBindeBefore(comboAtt){
			if(comboAtt == "Produce,MACHINE"){
				var param = new DataMap();

				param.put("WERKS", 'P100');
			}
			return param;
		}

		function searchList(){
			if (validate.check("searchArea")) {	
				const param = inputList.setRangeParam("searchArea")
				gridList.resetGrid("gridList");
				param.put("P_TYPE","LIST");
				param.put("IND_BCD", $("#IND_BCD").val()) // 개별바코드
				
				gridList.gridList({
			    	id : "gridList",
			    	param : param
			    })
				
				/* var json = netUtil.sendData({
					id : "gridList",
					url : "/mes/Work/WRK44/json/datalist.data",
					param : param
				});
				
				if(json.data.length <= 0) {
					alert('데이터가 없습니다.')
					return;
				}
				var PCB01 = []
				var PCB02 = []
				var PCB03 = []
				var PCB04 = []
				var PPB04 = []
				var PPB05 = []
				var PPB06 = []
				var PPC01 = []
				var PPC02 = []
				var PPC03 = []
				var PSA01 = []
				var PZA01 = []
				var maxLen = 0;
				var newjson = {data:[]}
				if(json && json.data.length > 0 ) {
					for(var i=0;i < json.data.length; i++) {
						var d = json.data[i];
						if(d.PCB01) PCB01.push(d.PCB01);
						if(d.PCB02) PCB02.push(d.PCB02);
						if(d.PCB03) PCB03.push(d.PCB03);
						if(d.PCB04) PCB04.push(d.PCB04);
						if(d.PPB04) PPB04.push(d.PPB04);
						if(d.PPB05) PPB05.push(d.PPB05);
						if(d.PPB06) PPB06.push(d.PPB06);
						if(d.PPC01) PPC01.push(d.PPC01);
						if(d.PPC02) PPC02.push(d.PPC02);
						if(d.PPC03) PPC03.push(d.PPC03);
						if(d.PSA01) PSA01.push(d.PSA01);
						if(d.PZA01) PZA01.push(d.PZA01);
					}
					if(maxLen<PCB01.length) maxLen = PCB01.length;
					if(maxLen<PCB02.length) maxLen = PCB02.length;
					if(maxLen<PCB03.length) maxLen = PCB03.length;
					if(maxLen<PCB04.length) maxLen = PCB04.length;
					if(maxLen<PPB04.length) maxLen = PPB04.length;
					if(maxLen<PPB05.length) maxLen = PPB05.length;
					if(maxLen<PPB06.length) maxLen = PPB06.length;
					if(maxLen<PPC01.length) maxLen = PPC01.length;
					if(maxLen<PPC02.length) maxLen = PPC02.length;
					if(maxLen<PPC03.length) maxLen = PPC03.length;
					if(maxLen<PSA01.length) maxLen = PSA01.length;
					if(maxLen<PZA01.length) maxLen = PZA01.length;
					if(maxLen > 0) {
						for(var j=0;j<maxLen;j++) {
							var data = {
								PCB01:'',
								PCB02:'',
								PCB03:'',
								PCB04:'',
								PPB04:'',
								PPB05:'',
								PPB06:'',
								PPC01:'',
								PPC02:'',
								PPC03:'',
								PSA01:'',
								PZA01:''
							};
							if(PCB01.length > 0 && j<=(PCB01.length-1)) data.PCB01 = PCB01[j];
							if(PCB02.length > 0 && j<=(PCB02.length-1)) data.PCB02 = PCB02[j];
							if(PCB03.length > 0 && j<=(PCB03.length-1)) data.PCB03 = PCB03[j];
							if(PCB04.length > 0 && j<=(PCB04.length-1)) data.PPB04 = PCB04[j];
							if(PPB04.length > 0 && j<=(PPB04.length-1)) data.PPB04 = PPB04[j];
							if(PPB05.length > 0 && j<=(PPB05.length-1)) data.PPB05 = PPB05[j];
							if(PPB06.length > 0 && j<=(PPB06.length-1)) data.PPB06 = PPB06[j];
							if(PPC01.length > 0 && j<=(PPC01.length-1)) data.PPC01 = PPC01[j];
							if(PPC02 .length > 0 && j<=(PPC02.length-1)) data.PPC02 = PPC02[j];
							if(PPC03.length > 0 && j<=(PPC03.length-1)) data.PPC03 = PPC03[j];
							if(PSA01.length > 0 && j<=(PSA01.length-1)) data.PSA01 = PSA01[j];
							if(PZA01.length > 0 && j<=(PZA01.length-1)) data.PZA01 = PZA01[j];
							newjson.data.push(data);
						}
						gridList.appendJson('gridList',newjson)
					}
				} 
				 gridList.appendJson('gridList',json)*/
			}
		}

		const barcode = () => {
			var url = "/mes/wrk/WRK17_POP01.page";
			page.linkPopOpen(url, "P100", "height=600,width=850");
		}

		function commonBtnClick(btnName){
			//commonUtil.debugMsg("commonBtnClick : ", arguments);
			if(btnName == "Search"){
				var param = new DataMap();
				param.put("PROGID", "<%= menuId%>");
				param.put("LGTYPE", "SEARCH");
				var json = netUtil.sendData({
					url: "/mes/system/json/saveLog.data",
					param : param
				});

				searchList();
			}else if(btnName == "Save"){
				saveData();
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
						<dt CL="구분">PACK_PROC</dt>
						<dd>
							<select class="input" id="PACK_PROC" name="PACK_PROC" CommonCombo="PACK_PROC" ComboType="MC">
							</select>
						</dd>
					</dl>
					
					<dl>
						<dt CL="STD_PCODE">지종코드</dt>
						<dd>
							<!-- 2023-03-13(월요일) 안상현, 지종 RANGE 검색 추가 -->
                            <input type="text" id="PCODE" name="PCODE" UIInput="SR,PCODE" UIFormat="U"/>
						</dd>
					</dl>
					<dl>
						<dt CL="STD_BS_WGT">평량</dt>
						<dd>
							<!-- 2023-03-13(월요일) 안상현, 평량 RANGE 검색 추가 -->
							<input type="text" class="input" id="BS_WGT" name="BS_WGT" UIInput="SR" />
						</dd>
					</dl>
					<dl>
						<dt CL="STD_WLEN">가로</dt>
						<dd>
							<!-- 2023-03-13(월요일) 안상현, 가로 RANGE 검색 추가 -->
							<input type="text" class="input" id="WLEN" name="WLEN" UIInput="SR" />
						</dd>
					</dl>
					<dl>
						<dt CL="STD_VLEN">세로</dt>
						<dd>
							<!-- 2023-03-13(월요일) 안상현, 세로 RANGE 검색 추가 -->
							<input type="text" class="input" id="VLEN" name="VLEN" UIInput="SR" />
						</dd>
					</dl>
					<dl>
						<dt CL="STD_IND_BCD">개별바코드</dt>
						<dd>
							<input type="text" class="input" id="IND_BCD" name="IND_BCD" UIInput="SR,INDBCD" UIFormat="U"/>
							<!-- <button type="button" class="btn btn_search" onclick="barcode()">
								<span>search</span>
							</button> -->
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
					<li><a href="#tab1-1"><span CL="STD_GRD_WRK44">리스트</span></a></li>
					<li class="btn_zoom_wrap">
						<ul>
							<li><button class="btn btn_bigger"><span>확대</span></button></li>
						</ul>
					</li>
				</ul>
				<div class="table_box section" id="tab1-1">
					<div class="table_list01">
						<div class="scroll">
							<table class="table_c">
								<tbody id="gridList">
								<tr CGRow="true">
									<td GH="40" GCol="rownum">1</td>
										<td GH='100' GCol="text,PACK_PROC" style="text-align:center;">구분</td>
										<td GH='140' GCol="text,MATNR" style="text-align:center;">자재코드</td>
										<td GH='280' GCol="text,MATNR_NM" style='text-align:center;'>자재명</td>
										<td GH='100' GCol="text,PCODE" style="text-align:center;">지종</td>
										<td GH='100' GCol="text,SPEC" style="text-align:center;">규격</td>
										<td GH='100' GCol="text,BS_WGT" style="text-align:center;">평량</td>
										<td GH='100' GCol="text,DOMESTIC" style="text-align:center;">내수구분</td>
										<td GH='100' GCol="text,LOT_NO" style="text-align:center;">LOT번호</td>
										<td GH='100' GCol="text,IND_BCD" style="text-align:center;">개별바코드</td>
										<td GH='100' GCol="text,ROLLCNT" GF="N 13,3">권치수</td>
										<td GH='100' GCol="text,ROLLUNIT" style="text-align:center;">권치수단위</td>
										<td GH='100 연수' GCol="text,PCNT" GF="N 13,3">연수</td>
										<td GH='100' GCol="text,RUNIT" style="text-align:center;">연수단위</td>
										<td GH='100' GCol="text,WGT" GF="N 13,3">중량</td>
										<td GH='100' GCol="text,WUNIT" style="text-align:center;">중량단위</td>
										<td GH='100' GCol="text,KUNNR" style="text-align:center;">판매처</td>
										<td GH="140" GCol="text,KUNNRT" style="text-align:left;">판매처명</td>
										<td GH="80" GCol="text,LAND1" style="text-align:center;">국가</td>
										<td GH="100" GCol="text,LAND1_NM">국가명</td>
										
								</tr>
								</tbody>
							</table>
						</div>
					</div>
					<jsp:include page="/WEB-INF/jsp/common/commonBtnAuth.jsp">
						<jsp:param name="authCd" value="1" />
						<jsp:param name="showAuthCd" value="1,2,7,9,10" />
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