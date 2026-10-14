<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
	String matnr = request.getParameter("MATNR");
	String matnrNm = request.getParameter("MATNR_NM");
	String indbcd = request.getParameter("IND_BCD");
	String machCd = request.getParameter("MACH_CD");
	String WrkOrdrNo = request.getParameter("WRK_ORDR_NO");
	String WrkOrdrSeqno = request.getParameter("WRK_ORDR_SEQNO");
	String inputqty = request.getParameter("INPUT_QTY");
	String stckqty = request.getParameter("STCK_QTY");
	String unit = request.getParameter("UNIT");
	String continflg = request.getParameter("CONTIN_FLG");
%>
<!doctype html>
<head>
	<meta charset="utf-8">
	<meta name="viewport" content="user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, width=device-width, target-densitydpi=medium-dpi" />
	<meta name="format-detection" content="telephone=no" />
	<title>Mobile Mes</title>
	<%@ include file="/mobile/include/head.jsp" %>
	<script>
        function forceInp(){	// 강제투입
        	var paramStr = 
        		"MATNR=<%=matnr%>&MATNR_NM=<%=matnrNm%>&IND_BCD=<%=indbcd%>&MACH_CD=<%=machCd%>&WRK_ORDR_NO=<%=WrkOrdrNo%>&WRK_ORDR_SEQNO=<%=WrkOrdrSeqno%>&INPUT_QTY=<%=inputqty%>&STCK_QTY=<%=stckqty%>&UNIT=<%=unit%>&CONTIN_FLG=<%=continflg%>";
        	
        	location.href = "/mobile/PDA_INV06_01.page?" + paramStr;
        }
	</script>
</head>
<body>
<div class="main_wrap">
	<div class="main_header_pop">
		<ul>
			<li class="tit" id="title">메시지</li>
		</ul>
	</div>
	<div class="tem4_content">
		<ul>
			<br><br>
			<li style="text-align:center;font-size:30px;">투입할 수 없는 자재입니다.</li>
			<li style="text-align:center;font-size:30px;">강제 투입하시겠습니까?</li>
		</ul>
	</div>
		<!-- end table_body -->
		<div class="footer_5" style="position:fixed;">
			<!-- 			<div class="footer_5" "> -->
			<table>
				<tr>
					<td class="f_1 btn-c1" onclick="history.back();" style="width: 50%"><label>닫기</label></td>
					<td class="f_1 btn-c1" onclick="forceInp();" style="width: 50%;"><label >강제투입</label></td>
				</tr>
			</table>
		</div><!-- end footer_5 -->
	</div>
</div>
</body>