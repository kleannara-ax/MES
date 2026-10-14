<%@ page language="java" contentType="text/html; charset=UTF-8"
		 pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	<title>인터페이스 실적전송</title>
	<%@ include file="/common/include/webdek/head.jsp" %>
	<script type="text/javascript">

		window.resizeTo('1250','600');
		var iftbl;
		var ifid;
		var iflastdat;
		var bwart;
		var rfcfn;
		var sysfr;
		var systo;
		$(document).ready(function(){
			var data = page.getLinkPopData();
			dataBind.dataNameBind(data, "searchArea");

			ifid = data.get("IFID");
			iftbl = data.get("IFTBL");
			bwart = data.get("BWART");
			bwartnm = data.get("BWARTNM");
			rfcfn = data.get("RFCFN");
			sysfr = data.get("SYSFR");
			systo = data.get("SYSTO");

			$("#IFID").val(ifid);
			$("#IFKNM").val(data.get("IFKNM"));
			$("#RFCFN").val(rfcfn);
			$("#IFTBL").val(iftbl);
			$("#BWARTNM").val(bwartnm);
			setHead(iftbl);

			gridList.setGrid({
				id : "gridListSub",
				url : "/ifsend/Erpif/procedure/json/data.data",
				bigdata : false,
			});

			searchList();
		});

		function searchList(){
			var param = new DataMap();
			param.put("P_TYPE","LIST");
			param.put("IFID",ifid);
			
			gridList.gridList({
				id : "gridListSub",
				param : param
			});
		}
		
		function gridListEventDataBindEnd(gridId, dataLength){
			for(var i = 0; i < dataLength; i++){
				gridList.setRowCheck(gridId, i, true);
			}
		}

		/** HEAD 셋팅 및 조회처리 **/
		function setHead(iftbl) {
			$("#resetTable").empty();
			$("#resetUtil").empty();
			//CLEAR
			var html='<table class="table_c">';
			html +='<tbody id="gridListSub">';
			html +='<tr id="appendBodyGrid" CGRow="true">';
			html +='</tr>';
			html +='</tbody>';
			html +='</table>';
// 			html +='</div>';
			$("#resetTable").html(html);

			var util = '<div class="btn_lit tableUtil">';
			util += '<button type="button" GBtn="find"></button>';
			util += '<button type="button" GBtn="sortReset"></button>';
			util += '<button type="button" GBtn="excelUpload" id="excelUpload"></button>';
			util += '<span class="txt_total" >총 건수 : <span GInfoArea="true">0</span></span>';
			util += '</div>';
			$("#resetUtil").html(util);

			var colH;
			var colI;

			if(iftbl == "TB_IFS001") {
				colH = ['오더 번호','LOT 번호','제품번호','플랜트(MES PK)','작업장코드(MES PK)','실적일 ','생산일 ','생산호기','반','반장','작업자 ','와딩티슈 이전 작업자','용도','소프트롤1','소프트롤2','소프트롤3','생산 실적(KG)','가동시간','지폭폐품여부','[PP] 사입 여부 (사입원지)','마지막생산여부','작업시작일자(생산시스템일자)','작업시작시간(생산시스템시간)','작업종료일자(생산시스템일자)','작업종료시간(생산시스템시간)','MES 문서번호','MES 문서순번','SAP 확정번호','SAP 확정카운터','SAP 결과값 Return( S:성공, E:오류 )','SAP결과 메시지','SAP 전송 시간'];
				colI = ['AUFNR','LOTNO','PRDCD','WERKS','WORKCENTERCODE','PRDDT','PRODT','MACHINE','WORKGROUP','LEADER','WORKER','CW_WORKER','PUPOS','SFLOTNO1','SFLOTNO2','SFLOTNO3','PROQTY','RUNTIME','SCPAP','SAIP','CONF','SDATE','STIME','EDATE','ETIME','MDOCNO','MDOCSEQ','RUECK','RMZHL','ZRESULT','ZMESSAGE','ZRESULT_DATE']
			}
			else if(iftbl == "TB_IFS002") {
				colH = ['오더 번호','LOT 번호','제품번호','플랜트(MES PK)','작업장코드(MES PK)','실적일 ','생산일 ','생산호기','합지호기','반','생산 실적','생산 단위','가동시간','작업자','마지막생산여부','작업시작일자(생산시스템일자)','작업시작시간(생산시스템시간)','작업종료일자(생산시스템일자)','작업종료시간(생산시스템시간)','MES 문서번호','MES 문서순번','SAP 확정번호','SAP 확정카운터','SAP 결과값 Return( S:성공, E:오류 )','SAP 결과 메시지','SAP 전송 시간'];
				colI = ['AUFNR','LOTNO','PRDCD','WERKS','WORKCENTERCODE','PRDDT','PRODT','MACHINE','HMACHINE','WORKGROUP','PROQTY','MEINS','RUNTIME','OPNAM','CONF','SDATE','STIME','EDATE','ETIME','MDOCNO','MDOCSEQ','RUECK','RMZHL','ZRESULT','ZMESSAGE','ZRESULT_DATE'];
			}
			else if(iftbl == "TB_IFS003") {
				colH = ['점보롤 오더 번호','점보롤 LOT 번호','플랜트(MES PK)','작업장코드(MES PK)','생산일자(생산일시)(MES PK)','생산일자(생산일시)(MES PK)','생산호기','반','생산 호기','품목코드(MES PK)','J/R 권치수','실적 중량','생산단위','가동시간','마지막생산여부','작업시작일자(생산시스템일자)','작업시작시간(생산시스템시간)','작업종료일자(생산시스템일자)','작업종료시간(생산시스템시간)','MES 문서번호','MES 문서순번','SAP 확정번호','SAP 확정카운터','비계획 생산 오더번호','SAP Return값( S:성공, E:오류 )','SAP결과 메시지','SAP 전송 시간'];
				colI = ['AUFNR','JRLOT','WERKS','WORKCENTERCODE','BUDAT','BUDAT_SAP','MACHINE','WORKGROUP','JVERID','JMATNR','JROLLCNT','JBRGEW','JGEWEI','JRUNTIME','CONF','JSDATE','JSTIME','JEDATE','JETIME','MDOCNO','MDOCSEQ','RUECK','RMZHL','NAUFNR','ZRESULT','ZMESSAGE','ZRESULT_DATE'];
			}
			else if(iftbl == "TB_IFS004") {
				colH = ['밀롤 오더 번호','밀롤 LOT 번호','플랜트(MES PK)','작업장코드(MES PK)','생산일자(생산일시)(MES PK)','생산호기','반','M/R 권치수(실적)','M/R 권치수(폐품량)','페품코드','페품원인','밀롤 원지 수량','밀롤 지관 인지','밀롤 설비','가동시간','마지막생산여부','마지막생산여부','작업시작일자(생산시스템일자)','작업시작시간(생산시스템시간)','작업종료일자(생산시스템일자)','작업종료시간(생산시스템시간)','MES 문서번호','MES 문서순번','SAP 확정번호','SAP 확정카운터','SAP 결과값 Return( S:성공, E:오류 )','SAP결과 메시지','SAP 전송 시간'];
				colI = ['AUFNR','MRLOT','WERKS','WORKCENTERCODE','BUDAT','MACHINE','WORKGROUP','MROLLCNT','MRSCRCNT','SCRAPCODE','SCRAPREASON','RBRGEW','CORESIZE','REWINDER','MRUNTIME','CONFM','CONFJ','MSDATE','MSTIME','MEDATE','METIME','MDOCNO','MDOCSEQ','RUECK','RMZHL','ZRESULT','ZMESSAGE','ZRESULT_DATE'];
			}
			else if(iftbl == "TB_IFS005") {
				colH = ['재단 오더 번호','재단 LOT 번호','플랜트(MES PK)','작업장코드(MES PK)','생산일자(생산일시)(MES PK)','생산호기','반','재단 실적','생산 단위','가동시간','작업자','재단설비','마지막생산여부','작업시작일자(생산시스템일자)','작업시작시간(생산시스템시간)','작업종료일자(생산시스템일자)','작업종료시간(생산시스템시간)','MES 문서번호','MES 문서순번','SAP 확정번호','SAP 확정카운터','SAP 결과값 Return( S:성공, E:오류 )','SAP결과 메시지','SAP 전송 시간'];
				colI = ['AUFNR','CRLOT','WERKS','WORKCENTERCODE','BUDAT','MACHINE','WORKGROUP','PRDQTY','MEINS','CRUNTIME','COPNAM','CUTTER','CONFM','CSDATE','CSTIME','CEDATE','CETIME','MDOCNO','MDOCSEQ','RUECK','RMZHL','ZRESULT','ZMESSAGE','ZRESULT_DATE'];
			}
			else if(iftbl == "TB_IFS006") {
				colH = ['오더 번호','포장 LOT 번호','플랜트(MES PK)','작업장코드(MES PK)','생산일자(생산일시)(MES PK)','생산호기','반','포장 실적','생산 단위','가동시간','작업자','포장설비','마지막생산여부','작업시작일자(생산시스템일자)','작업시작시간(생산시스템시간)','작업종료일자(생산시스템일자)','작업종료시간(생산시스템시간)','MES 문서번호','MES 문서순번','SAP 확정번호','SAP 확정카운터','SAP 결과값 Return( S:성공, E:오류 )','SAP결과 메시지','SAP 전송 시간'];
				colI = ['AUFNR','PKLOT','WERKS','WORKCENTERCODE','BUDAT','MACHINE','WORKGROUP','PCNT','MEINS','PRUNTIME','POPNAM','PACKLOC','CONF','PSDATE','PSTIME','PEDATE','PETIME','MDOCNO','MDOCSEQ','RUECK','RMZHL','ZRESULT','ZMESSAGE','ZRESULT_DATE'];
			}
			else if(iftbl == "TB_IFS007") {
				colH = ['SAP 확정번호','SAP 확정카운터','MES 문서번호','MES 문서순번','SAP 결과값 Return( S:성공, E:오류 )','SAP결과 메시지','SAP 전송 시간','등록일자','등록자','작업장코드(MES PK)','오더번호','권치수','자재 문서 번호'];
				colI = ['RUECK','RMZHL','MDOCNO','MDOCSEQ','ZRESULT','ZMESSAGE','ZRESULT_DATE','MAKE_DATE','MAKER','WORKCENTERCODE','AUFNR','ROLLCNT','MBLNR'];
			}
			else if(iftbl == "TB_IFS008") {
				colH = ['오더번호','오더Item번호','투입일자(전기일)','자재번호(투입자재)','투입량','저장위치','LOT번호','MES 문서번호','MES 문서순번','SAP 문서번호','SAP 문서번호(년도)','SAP 결과값 Return( S:성공, E:오류 )','SAP결과 메시지','SAP 전송 시간','등록일자','등록자','작업장코드(MES PK)','플랜트'];
				colI = ['AUFNR','POSNR','BUDAT','MATNR','MENGE','LGORT','CHARG','MDOCNO','MDOCSEQ','MBLNR','MJAHR','ZRESULT','ZMESSAGE','ZRESULT_DATE','MAKE_DATE','MAKER','WORKCENTERCODE','WERKS'];
			}
			////
			else if(iftbl == "TB_IFS009") {
				colH = ['이동유형','플랜트(From)','플랜트(To)','자재번호(From)','자재번호(To)','저장위치(From)','저장위치(To)','LOT번호(From)','이동량','이동단위','부적합 지시자','MES 문서번호','MES 문서순번','SAP 문서번호','SAP 문서번호(년도)','SAP 결과값','SAP결과 메시지','SAP 전송 시간','등록일자','등록자','MES','LOT번호(To)','변경된비계획오더번호','LOT 변경', '판매문서', '판매문서 항목번호', '판매문서', '판매문서 항목번호'];
				colI = ['BWART','WERKS_FROM','WERKS_TO','MATNR_FROM','MATNR_TO','LGORT_FROM','LGORT_TO','CHARG_FROM','MENGE','MEINS','FAULTY','MDOCNO','MDOCSEQ','MBLNR','MJAHR','ZRESULT','ZMESSAGE','ZRESULT_DATE','MAKE_DATE','MAKER','IF_MES_KEY','CHARG_TO','AUFNR','LTCHG','VBELN_FROM', 'POSNR_FROM', 'VBELN_TO', 'POSNR_TO' ];
			}
			else if(iftbl == "TB_IFS010") {
				colH = ['SAP 문서번호','SAP 문서번호(년도)','MES 문서번호','MES 문서순번','SAP 결과값','SAP결과 메시지','SAP 전송 시간','등록일자','등록자','MES KEY'];
				colI = ['MBLNR','MJAHR','MDOCNO','MDOCSEQ','ZRESULT','ZMESSAGE','ZRESULT_DATE','MAKE_DATE','MAKER','IF_MES_KEY'];
			}
			else if(iftbl == "TB_IFS013") {
				colH = ['플랜트 ','생산 호기','인터폴더 호기','생산일 ','시작시간','실적일 ','종료시간','가동시간(분)','반 ','공정상태','공정상태 내역','공정상태 원인코드','공정상태 원인코드 내역','운휴내역','MES 문서번호','MES 문서순번','SAP 확정번호','SAP 확정카운터','SAP 결과값','SAP결과 메시지','SAP 전송 시간','등록일자','등록자','작업장'];
				colI = ['WERKS','MACHINE','IFMC','BUDAT','STATM','PRODT','ENDTM','RUNTIME','WORKGROUP','STSCODE','STSTEXT','RSNCODE','RSNTEXT','REMARK','MDOCNO','MDOCSEQ','RUECK','RMZHL','ZRESULT','ZMESSAGE','ZRESULT_DATE','MAKE_DATE','MAKER','ARBPL'];
			}
			else if(iftbl == "TB_IFS016") {
				colH = ['플랜트 ','생산 호기','생산일 ','시작시간','인터폴더 호기','실적일 ','종료시간','가동시간(분)','작업장','반 ','작업자','공정상태','공정상태 내역','공정상태 원인코드','공정상태 원인코드 내역','운휴내역','MES 문서번호','MES 문서순번','SAP 결과값','SAP결과 메시지','SAP 전송 시간','등록일자','등록자'];
				colI = ['WERKS','MACHINE','BUDAT','STATM','IFMC','PRODT','ENDTM','RUNTIME','ARBPL','WORKGROUP','WORKER','STSCODE','STSTEXT','RSNCODE','RSNTEXT','REMARK','MDOCNO','MDOCSEQ','ZRESULT','ZMESSAGE','ZRESULT_DATE','MAKE_DATE','MAKER'];
			}
			else if(iftbl == "TB_IFS017") {
				colH = ['운전상태 코드','운전상태 코드명','원인 코드','원인 코드명','SAP 결과값 Return','SAP결과 메시지','SAP 전송 시간','등록일자','등록자'];
				colI = ['STSCODE','STSTEXT','RSNCODE','RSNTEXT','ZRESULT','ZMESSAGE','ZRESULT_DATE','MAKE_DATE','MAKER'];
			}
			else if(iftbl == "TB_IFS018") {
				colH = ['불량 코드','불량 코드 명','SAP 결과값','SAP결과 메시지','SAP 전송 시간','등록일자','등록자'];
				colI = ['FALTCD','FALTXT','ZRESULT','ZMESSAGE','ZRESULT_DATE','MAKE_DATE','MAKER'];
			}
			else if(iftbl == "TB_IFS019") {
				colH = ['오더 번호','LOT 번호','플랜트(MES PK)','생산일자(생산일시)(MES PK)','자재코드','MR 권치수','생산 실적','생산 단위','가동시간','작업자','마지막생산여부','작업시작일자(생산시스템일자)','작업시작시간(생산시스템시간)','작업종료일자(생산시스템일자)','작업종료시간(생산시스템시간)','MES 문서번호','MES 문서순번','SAP 확정번호','SAP 확정카운터','SAP 결과값','SAP 결과 메시지','SAP 전송 시간','등록일자','등록자'];
				colI = ['AUFNR','LOTNO','WERKS','BUDAT','MATNR','MROLLCNT','PROQTY','MEINS','RUNTIME','OPNAM','CONF','SDATE','STIME','EDATE','ETIME','MDOCNO','MDOCSEQ','RUECK','RMZHL','ZRESULT','ZMESSAGE','ZRESULT_DATE','MAKE_DATE','MAKER'];
			}
			else if(iftbl == "TB_IFS020") {
				colH = ['점보롤 LOT 번호','MES 문서번호','MES 문서순번','SAP 결과값 Return( S:성공, E:오류 )','SAP결과 메시지','SAP 전송 시간','등록일자','등록자'];
				colI = ['AUFNR','MDOCNO','MDOCSEQ','ZRESULT','ZMESSAGE','ZRESULT_DATE','MAKE_DATE','MAKER'];
			}
			else if(iftbl == "TB_IFS021") {
				colH = ['Pack Lot Number','Pack Lot Number','전기일','등급변경 연 수량 - From','자재 번호 - To','등급변경 연 수량 - To','팔렛트당 연수','비고','MES 문서번호','MES 문서순번','SAP 문서번호','SAP 문서번호(년도)','SAP 결과값 Return( S:성공, E:오류 )','SAP결과 메시지','SAP 전송 시간','등록일자','등록자'];
				colI = ['LOTNO_FROM','LOTNO_TO','BUDAT','CCNT','MATNR','CTCTN','PCNT','REMARK','MDOCNO','MDOCSEQ','MBLNR','MJAHR','ZRESULT','ZMESSAGE','ZRESULT_DATE','MAKE_DATE','MAKER'];
			}
			else if(iftbl == "TB_IFS022") {
				colH = ['작업장코드(MES PK)','오더번호','오더Item번호','투입일자(전기일)','자재번호(투입자재)','투입량','플랜트','저장위치','LOT번호','MES 문서번호','MES 문서순번','SAP 문서번호','SAP 문서번호(년도)','SAP 결과값','SAP 전송 시간','등록일자','MES Inserface Key','SAP결과 메시지'];
				colI = ['WORKCENTERCODE','AUFNR','POSNR','BUDAT','MATNR','MENGE','WERKS','LGORT','CHARG','MDOCNO','MDOCSEQ','MBLNR','MJAHR','ZRESULT','ZRESULT_DATE','MAKE_DATE','IF_MES_KEY','ZMESSAGE'];
			}
			else if(iftbl == "TB_IFS023") {
				colH = ['구분( C. 생성 D. 취소(삭제))','Barcode No.','M/R LOT Number','전기일(Lift 출고일/밀롤 실적일)','컨테이너 No','B/L 관리번호','STO 구매문서번호','자재코드','Roll no.','업체 지종','M/R 권치수','지관 인치','비고','MES 문서번호','MES 문서순번','SAP 결과값 Return( S:성공, E:오류 )','SAP결과 메시지','SAP 전송 시간','등록일자','등록자'];
				colI = ['GUBUN','BARCO','MRLOT','BUDAT','ZFCONNO','ZFBLNO','I_EBELN','MATNR','ROLLN','CPCOD','ROLLC','CORESIZE','REMARK','MDOCNO','MDOCSEQ','ZRESULT','ZMESSAGE','ZRESULT_DATE','MAKE_DATE','MAKER'];
			}
			else if(iftbl == "TB_IFS015") {
				colH = ['오더번호','평량','코팅','표면','이면','심면','후이면 ','후면','표면(코팅포함)','코팅','표면','이면','심면','후이면 ','후면','검사자','검사일자','검사시간','특이사항','샘플','LOT 번호','MES 문서번호','MES 문서순번','SAP 확정번호','SAP 확정카운터','SAP 결과값','SAP결과 메시지','등록일자','등록자','SAP 전송 시간'];
				colI = ['AUFNR','OVERWEIGHT','T_ZATT_TYPE1','T_ZATT_TYPE2','T_ZATT_TYPE3','T_ZATT_TYPE4','T_ZATT_TYPE5','T_ZATT_TYPE6','ZATT_TYPE0','ZATT_TYPE1','ZATT_TYPE2','ZATT_TYPE3','ZATT_TYPE4','ZATT_TYPE5','ZATT_TYPE6','ZINAME','ZIDATE','ZITIME','ZMEMO','ZSAMPLE','LOTNO','MDOCNO','MDOCSEQ','RUECK','RMZHL','ZRESULT','ZMESSAGE','MAKE_DATE','MAKER','ZRESULT_DATE'];
			}
			///
			else if(iftbl == "TB_IFS011") {
				colH = ['오더 번호','LOT 번호','플랜트(MES PK)','작업장코드(MES PK)','생산일자(생산일시)(MES PK)','생산호기','자재코드','반','생산 실적','생산 단위','가동시간','작업자','마지막생산여부','작업시작일자(생산시스템일자)','작업시작시간(생산시스템시간)','작업종료일자(생산시스템일자)','작업종료시간(생산시스템시간)','MES 문서번호','MES 문서순번','SAP 확정번호','SAP 확정카운터','비계획 생산 오더번호','SAP Return값( S:성공, E:오류 )','SAP결과 메시지','SAP 전송 시간'];
				colI = ['AUFNR','LOTNO','WERKS','WORKCENTERCODE','BUDAT','MACHINE','MATNR','WORKGROUP','PROQTY','MEINS','RUNTIME','OPNAM','CONF','SDATE','STIME','EDATE','ETIME','MDOCNO','MDOCSEQ','RUECK','RMZHL','NAUFNR','ZRESULT','ZMESSAGE','ZRESULT_DATE'];
			}
			else if(iftbl == "TB_IFS012") {
				colH = ['작업장코드(MES PK)','오더번호','오더Item번호','투입일자(전기일)','자재번호(투입자재)','폐품수량','저장위치','LOT번호','MES 문서번호','MES 문서순번','SAP 문서번호','SAP 문서번호(년도)','SAP 결과값 Return( S:성공, E:오류 )','SAP 전송 시간','등록일자','MES Inserface Key(MES->SAP 인 경우만)','SAP결과 메시지'];
				colI = ['WORKCENTERCODE','AUFNR','POSNR','BUDAT','MATNR','SCRQTY','LGORT','CHARG','MDOCNO','MDOCSEQ','MBLNR','MJAHR','ZRESULT','ZRESULT_DATE','MAKE_DATE','IF_MES_KEY','ZMESSAGE'];
			}
			else if(iftbl == "TB_IFS014") {
				colH = ['오더번호','오더Item번호','투입일자(전기일)','자재번호(투입자재)','투입량','플랜트','저장위치','LOT번호','작업장코드(MES PK)','MES 문서번호','MES 문서순번','SAP 문서번호','SAP 문서번호(년도)','SAP 결과값 Return( S:성공, E:오류 )','SAP결과 메시지','SAP 전송 시간','등록일자','등록자'];
				colI = ['AUFNR','POSNR','BUDAT','MATNR','MENGE','WERKS','LGORT','CHARG','WORKCENTERCODE','MDOCNO','MDOCSEQ','MBLNR','MJAHR','ZRESULT','ZMESSAGE','ZRESULT_DATE','MAKE_DATE','MAKER'];
			}
			else if(iftbl == "TB_IFR003") {
				colH = ['수신번호','플랜트','저장위치', '저장위치명' ,'I/F상태'];
				colI = ['IF_IFR_NO' ,'WERKS', 'LGORT','LGOBE','IF_STATUS' ];
			}
			else if(iftbl == "TB_IFR006") {
				colH = ['수신번호','플랜트','플랜트명' ,'작업장(Work Center)','작업장명', '삭제여부','I/F상태'];
				colI = ['IF_IFR_NO' ,'WERKS','ARBPL', 'KTEXT','LVORM','IF_STATUS' ];
			}
			else if(iftbl == "TB_IFR007") {
				colH = ['수신번호','품목코드','공장코드' ,'생산버전','생산버전내용', 'BOM Num','대체BOM', '삭제여부','I/F상태'];
				colI = ['IF_IFR_NO','MATNR', 'WERKS', 'VERID' ,'TEXT1','STLAN','STLAL','LVORM','IF_STATUS' ];
			}
			else if(iftbl == "TB_IFR008") {
				colH = ['수신번호','플랜트','모품목코드' ,'BOM Num','대체bom', '모품목기준수량','모품목기준수량 단위', '자품목항목','자품목자재', '수량', '수량단위', '스크랩', '특별유형', '삭제여부', 'I/F상태'];
				colI = ['IF_IFR_NO','WERKS', 'MATNR', 'STLNR' ,'STLAL','BMENG','BMEIN','POSNR','IDNRK' ,'MENGE','MEINS','AUSCH','ITSOB','LKENZ','IF_STATUS'];
			}
			else if(iftbl == "TB_IFR011") {
				colH = ['수신번호','플랜트','월','실행가능여부','I/F상태'];
				colI = ['IF_IFR_NO','WERKS','YYMM','YMCHK','IF_STATUS'];
			}
			else if(iftbl == "TB_IFR014") {
				colH = ['수신번호','오더번호','오더Item번호','자품목자재','오더BOM 수량','오더BOM 수량단위','LOT번호','저장위치','삭제여부'];
				colI = ['IF_IFR_NO','AUFNR','POSNR','MATNR','BDMNG','MEINS','CHARG','LGORT','XLOEK','IF_STATUS'];
			}
			else if(iftbl == "TB_IFR015") {
				colH = ['수신번호', '오더번호', '플랜트', '시작일자', '종료일자', '오더유형', '오더유형 텍스트', '제품코드', '생산지시량', '생산지시단위', '작업지시자', '가공호기', '가공호기명', '생산호기', '생산호기명', 'BOM Num', '대체Bom', '모품목기준수량', '모품목기준수량 단위', '릴리즈일자', '판매문서번호', '판매문서Item번호', '규격', '폭수', '용도', '용도내역', '생산실적수량', '단위', '생산일', '비고', '오더 삭제 지시자', '반복생산 지시자', 'I/F 상태'];
				colI = ['IF_IFR_NO', 'AUFNR', 'WERKS', 'GSTRP', 'GLTRP', 'AUART', 'AUARTXT', 'MATNR', 'FQTY', 'MEINS', 'AENAM', 'PRCMC', 'PRCMCTXT', 'MACHINE', 'MACHINETXT', 'STLNR', 'STLAL', 'BMENG', 'BMEIN', 'FTRMI', 'VBELN', 'POSNR', 'SPEC1', 'WDTH1', 'PUPOS', 'PUPNM', 'LMNGA', 'MEINS2', 'BUDAT', 'REMRK', 'DLFL', 'REM', 'IF_STATUS'];
			}
			else if(iftbl == "TB_IFR016") {
				colH = ['수신번호', '오더번호', '플랜트', '시작일자', '오더유형', '오더유형 텍스트', '제품코드', '생산지시량', '생산지시단위', 'Work Center', '작업지시자', '생산버전', 'BOM Num', '대체Bom', '모품목기준수량', '모품목기준수량 단위', '릴리즈일자', '작업순서', '오더 삭제 지시자', 'I/F 상태'];
				colI = ['IF_IFR_NO', 'AUFNR', 'WERKS', 'PRDDT', 'AUART', 'AUARTXT', 'MATNR', 'FQTY', 'MEINS', 'ARBPL', 'AENAM', 'PRCMC', 'STLNR', 'STLAL', 'BMENG', 'BMEIN', 'FTRMI', 'SEQ', 'DLFL', 'IF_STATUS'];
			}
			else if(iftbl == "TB_IFR017") {
				colH = ['수신번호', '오더번호', '플랜트', '시작일자', '오더유형', '오더유형 텍스트', '제품코드', '생산지시량', '생산지시단위', 'Work Center', '작업지시자', '생산버전', 'BOM Num', '대체Bom', '모품목기준수량', '모품목기준수량 단위', '릴리즈일자', '작업순서', '생산종료일', '오더 삭제 지시자', 'I/F 상태'];
				colI = ['IF_IFR_NO', 'AUFNR', 'WERKS', 'SDATE', 'AUART', 'AUARTXT', 'MATNR', 'FQTY', 'MEINS', 'ARBPL', 'AENAM', 'PRCMC', 'STLNR', 'STLAL', 'BMENG', 'BMEIN', 'FTRMI', 'SEQ', 'EDATE', 'DLFL', 'IF_STATUS'];
			}
			else if(iftbl == "TB_IFRWM001") {
				colH = ['참조번호(WMS문서번호)','참조번호아이템(WMS문서아이템번호)','삭제지시자(검사요청)(C,D)','오더번호','오더순번','공급처','품목코드','입고수량','단위','Stock key','WMS LOT속성코드','저장위치(WMS 저장위치)','플랜트','포장타입(PS)','호기','재고상태','주문번호(10)+아이템번호(6)MTO','국가코드','거래처코드MTO','보류사유명','제조일자','입고일자(SAP전기일자)','유통기한(생리대,기저귀,물티슈)','개별바코드(협력업체바코드)','LOT번호/SAP배치번호','평량(PS)','컨테이너유형(PS)'];
				colI = ['VGBEL','VGPOS','DLFL','ORDER_NO','ORDER_SEQNO','SUPY_CD','MATNR','QTY','UNIT','STOK_KY','LOT_NUM','STOR_LOC','WERKS','LOTA03','LOTA04','STCK_STA','LOTA07','NTN_CD','CRSPD_CD','LOTA10','PRDC_DT','RCVGDS_DT','DSTBT_DDLIN','IND_BCD','LOT_NO','LOTA16','LOTA17'];
			}
			else if(iftbl == "TB_IFRWM002") {
				colH = ['참조번호(MES문서번호)','참조번호아이템(MES문서아이템번호)','삭제지시자(불출요청)','MES문서순번','MES문서순번','플랜트','품목코드','불출량','단위','저장위치(WMS창고) FROM','저장위치(공정창고) TO','공급업체코드','저장위치','플랜트','포장타입(PS)','호기','LOTA05','재고상태 (00정상 30불용 05품질 50폐기 10보류)','주문번호(10)+아이템번호(6)MTO','국가코드','거래처코드MTO','보류사유명','제조일자','입고일자','유통기한 (생리대,기저귀,물티슈)','개별바코드 (협력업체바코드)','LOT번호','평량(PS)','컨테이너유형(PS)','LOTA18','LOTA19','LOTA20','Stock key','WMS LOT속성코드','I/F상태'];
				colI = ['VGBEL','VGPOS','DLFL','DOC_NO','DOC_SEQNO','WERKS','MATNR','QTY','UNIT','STOR_LOC_FROM','STOR_LOC_TO','SUPY_CD','LOTA01','LOTA02','LOTA03','LOTA04','LOTA05','STCK_STA','LOTA07','NTN_CD','CRSPD_CD','LOTA10','PRDC_DT','RCVGDS_DT','DSTBT_DDLIN','IND_BCD','LOT_NO','LOTA16','LOTA17','LOTA18','LOTA19','LOTA20','STOK_KY','LOT_NUM','IF_STATUS'];
			}
			else if(iftbl == "TB_IFSWM001") {
				colH = ['참조번호(MES문서번호)','참조번호아이템(MES문서아이템번호)','MES문서번호','MES문서순번','플랜트','품목코드','불출량','단위','저장위치(WMS 저장위치)','공급업체코드','플랜트','재고상태 (00정상 30불용 05품질 50폐기 10보류)','주문번호(10)+아이템번호(6)MTO','국가코드','거래처코드MTO','제조일자','입고일자','유통기한 (생리대,기저귀,물티슈)','개별바코드 (협력업체바코드)','LOT번호','Stock key','WMS LOT속성코드','I/F상태'];
				colI = ['VGBEL','VGPOS','DOC_NO','DOC_SEQNO','WERKS','MATNR','QTY','UNIT','STOR_LOC','SUPY_CD','WERKS','STCK_STA','LOTA07','NTN_CD','CRSPD_CD','PRDC_DT','RCVGDS_DT','DSTBT_DDLIN','IND_BCD','LOT_NO','STOK_KY','LOT_NUM','IF_STATUS'];
			}
			else if(iftbl == "TB_IFSWM002") {
				colH = ['MES문서번호','MES문서순번','오더번호','오더순번','공급처','품목코드','입고수량','단위','참조번호(WMS문서번호)','참조번호아이템(WMS문서아이템번호)','Stockkey','WMSLOT속성코드','저장위치(WMS저장위치)','플랜트','재고상태','국가코드','거래처코드MTO','제조일자','입고일자','유통기한(생리대,기저귀,물티슈)','개별바코드(협력업체바코드)','LOT번호/SAP 배치번호','컨테이너유형(PS)','검사진행상태','정상수량','불량수량','불량사유','불량사유명칭','WMS 결과값','MES 등록일시','WMS 전송일시','WMS 결과 메시지'];
				colI = ['DOC_NO','DOC_SEQNO','ORDER_NO','ORDER_SEQNO','SUPY_CD','MATNR','QTY','UNIT','VGBEL','VGPOS','STOK_KY','LOT_NUM','STOR_LOC','WERKS','STCK_STA','NTN_CD','CRSPD_CD','PRDC_DT','RCVGDS_DT','DSTBT_DDLIN','IND_BCD','LOT_NO','CON_TYPE','CHKRST','QTYGOD','QTYBAD','BADRSN','BADRSNNM','IF_STATUS','IF_GET_DATE','IF_SET_DATE','IF_ERR_MESS'];
			}
			else if(iftbl == "TB_IFRWM001") {
				colH = ['참조번호(WMS문서번호)','참조번호아이템(WMS문서아이템번호)','삭제지시자(검사요청)(C,D)','오더번호','오더순번','공급처','품목코드','입고수량','단위','Stock key','WMS LOT속성코드','저장위치(WMS 저장위치)','플랜트','포장타입(PS)','호기','재고상태','주문번호(10)+아이템번호(6)MTO','국가코드','거래처코드MTO','보류사유명','제조일자','입고일자(SAP전기일자)','유통기한(생리대,기저귀,물티슈)','개별바코드(협력업체바코드)','LOT번호/SAP배치번호','평량(PS)','컨테이너유형(PS)'];
				colI = ['VGBEL','VGPOS','DLFL','ORDER_NO','ORDER_SEQNO','SUPY_CD','MATNR','QTY','UNIT','STOK_KY','LOT_NUM','STOR_LOC','WERKS','LOTA03','LOTA04','STCK_STA','LOTA07','NTN_CD','CRSPD_CD','LOTA10','PRDC_DT','RCVGDS_DT','DSTBT_DDLIN','IND_BCD','LOT_NO','LOTA16','LOTA17'];
			}
			else if(iftbl == "TB_IFSWM001") {
				colH = ['참조번호(MES문서번호)','참조번호아이템(MES문서아이템번호)','삭제지시자(불출요청)','MES문서순번','MES문서순번','플랜트','품목코드','불출량','단위','저장위치(WMS창고) FROM','저장위치(공정창고) TO','공급업체코드','저장위치','포장타입(PS)','호기','LOTA05','재고상태 (00정상 30불용 05품질 50폐기 10보류)','주문번호(10)+아이템번호(6)MTO','국가코드','거래처코드MTO','보류사유명','제조일자','입고일자','유통기한 (생리대,기저귀,물티슈)','개별바코드 (협력업체바코드)','LOT번호','평량(PS)','컨테이너유형(PS)','LOTA18','LOTA19','LOTA20','Stock key','WMS LOT속성코드','I/F상태'];
				colI = ['VGBEL','VGPOS','DLFL','DOC_NO','DOC_SEQNO','WERKS','MATNR','QTY','UNIT','STOR_LOC_FROM','STOR_LOC_TO','SUPY_CD','LOTA01','LOTA02','LOTA03','LOTA04','LOTA05','STCK_STA','LOTA07','NTN_CD','CRSPD_CD','LOTA10','PRDC_DT','RCVGDS_DT','DSTBT_DDLIN','IND_BCD','LOT_NO','LOTA16','LOTA17','LOTA18','LOTA19','LOTA20','STOK_KY','LOT_NUM','IF_STATUS'];
			}
			else if(iftbl == "TB_IFRWM002") {
				colH = ['참조번호(MES문서번호)','참조번호아이템(MES문서아이템번호)','삭제지시자(불출요청)','MES문서순번','MES문서순번','플랜트','품목코드','불출량','단위','저장위치(WMS창고) FROM','저장위치(공정창고) TO','공급업체코드','저장위치','플랜트','포장타입(PS)','호기','LOTA05','재고상태 (00정상 30불용 05품질 50폐기 10보류)','주문번호(10)+아이템번호(6)MTO','국가코드','거래처코드MTO','보류사유명','제조일자','입고일자','유통기한 (생리대,기저귀,물티슈)','개별바코드 (협력업체바코드)','LOT번호','평량(PS)','컨테이너유형(PS)','LOTA18','LOTA19','LOTA20','Stock key','WMS LOT속성코드','I/F상태'];
				colI = ['VGBEL','VGPOS','DLFL','DOC_NO','DOC_SEQNO','WERKS','MATNR','QTY','UNIT','STOR_LOC_FROM','STOR_LOC_TO','SUPY_CD','LOTA01','LOTA02','LOTA03','LOTA04','LOTA05','STCK_STA','LOTA07','NTN_CD','CRSPD_CD','LOTA10','PRDC_DT','RCVGDS_DT','DSTBT_DDLIN','IND_BCD','LOT_NO','LOTA16','LOTA17','LOTA18','LOTA19','LOTA20','STOK_KY','LOT_NUM','IF_STATUS'];
			}
			else if(iftbl == "TB_IFSWM002") {
				colH = ['DOC_NO','DOC_SEQNO','DLFL','WERKS','MATNR','QTY','UNIT','STOR_LOC','ORDER_NO','ORDER_SEQNO','STCK_STA','NTN_CD','CRSPD_CD','PRDC_DT','RCVGDS_DT','DSTBT_DDLIN','IND_BCD','LOT_NO','OVBELN','OPOSNR','IF_STATUS'];
				colI = ['DOC_NO','DOC_SEQNO','DLFL','WERKS','MATNR','QTY','UNIT','STOR_LOC','ORDER_NO','ORDER_SEQNO','STCK_STA','NTN_CD','CRSPD_CD','PRDC_DT','RCVGDS_DT','DSTBT_DDLIN','IND_BCD','LOT_NO','OVBELN','OPOSNR','IF_STATUS'];
			}
			else if(iftbl =='TB_IFSWM003'){
				colH = ['DOC_NO','DOC_SEQNO','DLFL','WERKS','MATNR','QTY','UNIT','STOR_LOC','ORDER_NO','ORDER_SEQNO','STCK_STA','NTN_CD','CRSPD_CD','PRDC_DT','RCVGDS_DT','DSTBT_DDLIN','IND_BCD','LOT_NO','STOK_KY','LOT_NUM','IF_STATUS','REQ_DTM','REQ_EXE_DT'];
				colI = ['DOC_NO','DOC_SEQNO','DLFL','WERKS','MATNR','QTY','UNIT','STOR_LOC','ORDER_NO','ORDER_SEQNO','STCK_STA','NTN_CD','CRSPD_CD','PRDC_DT','RCVGDS_DT','DSTBT_DDLIN','IND_BCD','LOT_NO','STOK_KY','LOT_NUM','IF_STATUS','REQ_DTM','REQ_EXE_DT'];
			}
			else if(iftbl =='TB_IFRWM003'){
				colH = ['VGBEL','VGPOS','DLFL','DOC_NO','DOC_SEQ','WERKS','MATNR','QTY','UNIT','STOR_LOC_FROM','STOR_LOC_TO','SUPY_CD','LOTA01','LOTA02','LOTA03','LOTA04','LOTA05','STCK_STA','LOTA07','NTN_CD','CRSPD_CD','LOTA10','PRDC_DT','RCVGDS_DT','DSTBT_DDLIN','IND_BCD','LOT_NO','LOTA16','LOTA17','LOTA18','LOTA19','LOTA20','STOK_KY','LOT_NUM','IF_STATUS'];
				colI = ['VGBEL','VGPOS','DLFL','DOC_NO','DOC_SEQ','WERKS','MATNR','QTY','UNIT','STOR_LOC_FROM','STOR_LOC_TO','SUPY_CD','LOTA01','LOTA02','LOTA03','LOTA04','LOTA05','STCK_STA','LOTA07','NTN_CD','CRSPD_CD','LOTA10','PRDC_DT','RCVGDS_DT','DSTBT_DDLIN','IND_BCD','LOT_NO','LOTA16','LOTA17','LOTA18','LOTA19','LOTA20','STOK_KY','LOT_NUM','IF_STATUS'];
			}
			else if(iftbl =='TB_IFRWM004'){
				colH = ['VGBEL','VGPOS','DLFL','DOC_NO','DOC_SEQNO','WERKS','MATNR','QTY','UNIT','STOR_LOC_FROM','STOR_LOC_TO','SUPY_CD','LOTA01','LOTA02','LOTA03','LOTA04','LOTA05','STCK_STA','LOTA07','NTN_CD','CRSPD_CD','LOTA10','PRDC_DT','RCVGDS_DT','DSTBT_DDLIN','IND_BCD','LOT_NO','LOTA16','LOTA17','LOTA18','LOTA19','LOTA20','STOK_KY','LOT_NUM','IF_STATUS'];
				colI = ['VGBEL','VGPOS','DLFL','DOC_NO','DOC_SEQNO','WERKS','MATNR','QTY','UNIT','STOR_LOC_FROM','STOR_LOC_TO','SUPY_CD','LOTA01','LOTA02','LOTA03','LOTA04','LOTA05','STCK_STA','LOTA07','NTN_CD','CRSPD_CD','LOTA10','PRDC_DT','RCVGDS_DT','DSTBT_DDLIN','IND_BCD','LOT_NO','LOTA16','LOTA17','LOTA18','LOTA19','LOTA20','STOK_KY','LOT_NUM','IF_STATUS'];
			}
			else if(iftbl =='TB_IFSWM004'){
				colH = ['DOC_NO','DOC_SEQNO','DLFL','WERKS','MATNR','QTY','UNIT','STOR_LOC_FROM','STOR_LOC_TO','STCK_STA','STOK_KY','LOT_NUM','NTN_CD','CRSPD_CD','PRDC_DT','RCVGDS_DT','DSTBT_DDLIN','IND_BCD','LOT_NO','IF_STATUS','RTN_DT','LOTA03','LOTA04','LOTA16','LOTA17'];
				colI = ['DOC_NO','DOC_SEQNO','DLFL','WERKS','MATNR','QTY','UNIT','STOR_LOC_FROM','STOR_LOC_TO','STCK_STA','STOK_KY','LOT_NUM','NTN_CD','CRSPD_CD','PRDC_DT','RCVGDS_DT','DSTBT_DDLIN','IND_BCD','LOT_NO','IF_STATUS','RTN_DT','LOTA03','LOTA04','LOTA16','LOTA17'];
			}
			else if(iftbl =='TB_IFSWM005'){
				colH = ['DOC_NO','DOC_SEQNO','DLFL','WERKS','MATNR','QTY','UNIT','STOR_LOC_FROM','STOR_LOC_TO','IND_BCD','LOT_NO','MACHINE','ORDER_NO','ORDER_SEQNO','PCODE','WEIGHT','WLEN','VLEN','CON_TYPE','PACK_TYPE','OVBELN','OPOSNR','SAUART','KUNNR','CORE','EMPLY_NO','EMPLY_NM','NTN_CD','PRDC_DT','RCVGDS_DT','DSTBT_DDLIN','STCK_NO','IF_STATUS'];
				colI = ['DOC_NO','DOC_SEQNO','DLFL','WERKS','MATNR','QTY','UNIT','STOR_LOC_FROM','STOR_LOC_TO','IND_BCD','LOT_NO','MACHINE','ORDER_NO','ORDER_SEQNO','PCODE','WEIGHT','WLEN','VLEN','CON_TYPE','PACK_TYPE','OVBELN','OPOSNR','SAUART','KUNNR','CORE','EMPLY_NO','EMPLY_NM','NTN_CD','PRDC_DT','RCVGDS_DT','DSTBT_DDLIN','STCK_NO','IF_STATUS'];
			}
			else if(iftbl =='TB_IFRWM005'){
				colH = ['VGBEL','VGPOS','DLFL','DOC_NO','DOC_SEQNO','WERKS','MATNR','QTY','UNIT','STOR_LOC_FROM','STOR_LOC_TO','SUPY_CD','LOTA01','LOTA02','LOTA03','LOTA04','LOTA05','STCK_STA','LOTA07','NTN_CD','CRSPD_CD','LOTA10','PRDC_DT','RCVGDS_DT','DSTBT_DDLIN','IND_BCD','LOT_NO','LOTA16','LOTA17','LOTA18','LOTA19','LOTA20','STOK_KY','LOT_NUM','IF_STATUS'];
				colI = ['VGBEL','VGPOS','DLFL','DOC_NO','DOC_SEQNO','WERKS','MATNR','QTY','UNIT','STOR_LOC_FROM','STOR_LOC_TO','SUPY_CD','LOTA01','LOTA02','LOTA03','LOTA04','LOTA05','STCK_STA','LOTA07','NTN_CD','CRSPD_CD','LOTA10','PRDC_DT','RCVGDS_DT','DSTBT_DDLIN','IND_BCD','LOT_NO','LOTA16','LOTA17','LOTA18','LOTA19','LOTA20','STOK_KY','LOT_NUM','IF_STATUS'];
			}
			else if(iftbl =='TB_IFRWM006'){
				colH = ['VGBEL','VGPOS','DLFL','DOC_NO','DOC_SEQNO','WERKS','MATNR','QTY','UNIT','STOR_LOC_FROM','STOR_LOC_TO','SUPY_CD','LOTA01','LOTA02','LOTA03','LOTA04','LOTA05','STCK_STA','LOTA07','NTN_CD','CRSPD_CD','LOTA10','PRDC_DT','RCVGDS_DT','DSTBT_DDLIN','IND_BCD','LOT_NO','LOTA16','LOTA17','LOTA18','LOTA19','LOTA20','STOK_KY','LOT_NUM','IF_STATUS'];
				colI = ['VGBEL','VGPOS','DLFL','DOC_NO','DOC_SEQNO','WERKS','MATNR','QTY','UNIT','STOR_LOC_FROM','STOR_LOC_TO','SUPY_CD','LOTA01','LOTA02','LOTA03','LOTA04','LOTA05','STCK_STA','LOTA07','NTN_CD','CRSPD_CD','LOTA10','PRDC_DT','RCVGDS_DT','DSTBT_DDLIN','IND_BCD','LOT_NO','LOTA16','LOTA17','LOTA18','LOTA19','LOTA20','STOK_KY','LOT_NUM','IF_STATUS'];
			}
			else if(iftbl =='TB_IFSWM006'){
				colH = ['DOC_NO','DOC_SEQNO','ORDER_NO','ORDER_SEQNO','SUPY_CD','MATNR','QTY','UNIT','VGBEL','VGPOS','STOK_KY','LOT_NUM','STOR_LOC','WERKS','STCK_STA','NTN_CD','CRSPD_CD','PRDC_DT','RCVGDS_DT','DSTBT_DDLIN','IND_BCD','LOT_NO','CHKRST','QTYGOD','QTYBAD','BADRSN','BADRSNNM','IF_STATUS'];
				colI = ['DOC_NO','DOC_SEQNO','ORDER_NO','ORDER_SEQNO','SUPY_CD','MATNR','QTY','UNIT','VGBEL','VGPOS','STOK_KY','LOT_NUM','STOR_LOC','WERKS','STCK_STA','NTN_CD','CRSPD_CD','PRDC_DT','RCVGDS_DT','DSTBT_DDLIN','IND_BCD','LOT_NO','CHKRST','QTYGOD','QTYBAD','BADRSN','BADRSNNM','IF_STATUS'];
			}
			else if(iftbl =='TB_IFRWM007'){
				colH = ['VGBEL','VGPOS','DLFL','ORDER_NO','ORDER_SEQNO','SUPY_CD','MATNR','QTY','UNIT','STOK_KY','LOT_NUM','STOR_LOC','WERKS','LOTA03','LOTA04','LOTA05','STCK_STA','LOTA07','NTN_CD','CRSPD_CD','LOTA10','PRDC_DT','RCVGDS_DT','DSTBT_DDLIN','IND_BCD','LOT_NO','LOTA16','LOTA17','LOTA18','LOTA19','LOTA20','IN_DT','IF_STATUS'];
				colI = ['VGBEL','VGPOS','DLFL','ORDER_NO','ORDER_SEQNO','SUPY_CD','MATNR','QTY','UNIT','STOK_KY','LOT_NUM','STOR_LOC','WERKS','LOTA03','LOTA04','LOTA05','STCK_STA','LOTA07','NTN_CD','CRSPD_CD','LOTA10','PRDC_DT','RCVGDS_DT','DSTBT_DDLIN','IND_BCD','LOT_NO','LOTA16','LOTA17','LOTA18','LOTA19','LOTA20','IN_DT','IF_STATUS'];
			}
			else if(iftbl =='TB_IFSWM007'){
				colH = ['DOC_NO','DOC_SEQNO','WERKS','MATNR','QTY','UNIT','STOR_LOC','STCK_STA','IND_BCD','LOT_NO','CHKRST','QTYGOD','QTYBAD','BADRSN','STOK_KY','LOT_NUM','IF_STATUS'];
				colI = ['DOC_NO','DOC_SEQNO','WERKS','MATNR','QTY','UNIT','STOR_LOC','STCK_STA','IND_BCD','LOT_NO','CHKRST','QTYGOD','QTYBAD','BADRSN','STOK_KY','LOT_NUM','IF_STATUS'];
			}
			else if(iftbl =='TB_IFRWM008'){
				colH = ['VGBEL','VGPOS','DLFL','DOC_NO','DOC_SEQNO','WERKS','MATNR','QTY','UNIT','STOR_LOC_FROM','STOR_LOC_TO','SUPY_CD','LOTA01','LOTA02','LOTA03','LOTA04','LOTA05','STCK_STA','LOTA07','NTN_CD','CRSPD_CD','LOTA10','PRDC_DT','RCVGDS_DT','DSTBT_DDLIN','IND_BCD','LOT_NO','LOTA16','LOTA17','LOTA18','LOTA19','LOTA20','STOK_KY','LOT_NUM','IF_STATUS','PTNRKY','CONTNO','BARCNO','ZFBLNO','ROLLID','MRGSM','LENGTH','NETWT','WGTMUL','COREDI','KUNIT','CPCOD','TBRGEW','RBRGEW','LUNIT','DESCRI','WEIGHT','RMK1','RMK2','RMK3','RMK4','RMK5'];
				colI = ['VGBEL','VGPOS','DLFL','DOC_NO','DOC_SEQNO','WERKS','MATNR','QTY','UNIT','STOR_LOC_FROM','STOR_LOC_TO','SUPY_CD','LOTA01','LOTA02','LOTA03','LOTA04','LOTA05','STCK_STA','LOTA07','NTN_CD','CRSPD_CD','LOTA10','PRDC_DT','RCVGDS_DT','DSTBT_DDLIN','IND_BCD','LOT_NO','LOTA16','LOTA17','LOTA18','LOTA19','LOTA20','STOK_KY','LOT_NUM','IF_STATUS','PTNRKY','CONTNO','BARCNO','ZFBLNO','ROLLID','MRGSM','LENGTH','NETWT','WGTMUL','COREDI','KUNIT','CPCOD','TBRGEW','RBRGEW','LUNIT','DESCRI','WEIGHT','RMK1','RMK2','RMK3','RMK4','RMK5'];
			}
			else if(iftbl =='TB_IFSWC004'){
				colH = ['DOC_NO', 'DOC_NOSEQ', 'IND_BCD', 'LOT_NO', 'JRLOT_NO', 'WERKS', 'MACH_NO', 'PROC_CD', 'FCLT_CD', 'ORDER_NO', 'ORDER_NO_SEQ', 'PRFM_DT', 'PROD_SEQ', 'PROD_DT', 'WORK_GRP', 'SAT', 'MTART', 'PCODE', 'PCODE_NM', 'RELIMP', 'STD_SIZE', 'PAPER_BT', 'PAPER_BT_REAL', 'WEIGHT', 'LENGTH', 'SHEET_YN', 'SLITTER_YN', 'PACKING_TP_NM', 'JR_MCHN_CD', 'MR_MCHN_CD', 'CT_MCHN_CD', 'WRKORD', 'SPECIAL_NO', 'BCNC_CD', 'BCNC_NM', 'EXPORT_EXT', 'VOYAGE', 'CNTRY_NM', 'REAM_PER_PALLET', 'NMRS_IN_BUNDLE', 'BUNDLE_CNT', 'ZPPCOD', 'CORE_SIZE', 'BT_SEQ', 'USER_ID', 'USER_NM', 'WORK_DRCT', 'PRD_RMK1', 'MR_STK_YN', 'PLAN_CT_NO', 'REPROD_YN', 'PRE_BARCODE', 'CRAT_DATE', 'CRAT_ID', 'UPDT_DATE', 'UPDT_ID', 'REMARK1', 'REMARK2', 'REMARK3', 'REMARK4', 'REMARK5', 'REMARK6', 'REMARK7', 'REMARK8', 'REMARK9', 'REMARK10', 'IF_STATUS', 'IF_GET_DATE', 'IF_SET_DATE', 'IF_ERR_MESS', 'IF_MES_KEY'];
				colI = ['DOC_NO', 'DOC_NOSEQ', 'IND_BCD', 'LOT_NO', 'JRLOT_NO', 'WERKS', 'MACH_NO', 'PROC_CD', 'FCLT_CD', 'ORDER_NO', 'ORDER_NO_SEQ', 'PRFM_DT', 'PROD_SEQ', 'PROD_DT', 'WORK_GRP', 'SAT', 'MTART', 'PCODE', 'PCODE_NM', 'RELIMP', 'STD_SIZE', 'PAPER_BT', 'PAPER_BT_REAL', 'WEIGHT', 'LENGTH', 'SHEET_YN', 'SLITTER_YN', 'PACKING_TP_NM', 'JR_MCHN_CD', 'MR_MCHN_CD', 'CT_MCHN_CD', 'WRKORD', 'SPECIAL_NO', 'BCNC_CD', 'BCNC_NM', 'EXPORT_EXT', 'VOYAGE', 'CNTRY_NM', 'REAM_PER_PALLET', 'NMRS_IN_BUNDLE', 'BUNDLE_CNT', 'ZPPCOD', 'CORE_SIZE', 'BT_SEQ', 'USER_ID', 'USER_NM', 'WORK_DRCT', 'PRD_RMK1', 'MR_STK_YN', 'PLAN_CT_NO', 'REPROD_YN', 'PRE_BARCODE', 'CRAT_DATE', 'CRAT_ID', 'UPDT_DATE', 'UPDT_ID', 'REMARK1', 'REMARK2', 'REMARK3', 'REMARK4', 'REMARK5', 'REMARK6', 'REMARK7', 'REMARK8', 'REMARK9', 'REMARK10', 'IF_STATUS', 'IF_GET_DATE', 'IF_SET_DATE', 'IF_ERR_MESS', 'IF_MES_KEY'];
			}
			else if(iftbl =='TB_IFSWC005'){
				colH = ['DOC_NO','DOC_NOSEQ','IND_BCD','LOT_NO','DISCARD_CODE','DISCARD_RMK','REGDATE','REGID','UPDDATE','UPDID','REMARK1','REMARK2','REMARK3','REMARK4','REMARK5','REMARK6','REMARK7','REMARK8','REMARK9','REMARK10'];
				colI = ['DOC_NO','DOC_NOSEQ','IND_BCD','LOT_NO','DISCARD_CODE','DISCARD_RMK','REGDATE','REGID','UPDDATE','UPDID','REMARK1','REMARK2','REMARK3','REMARK4','REMARK5','REMARK6','REMARK7','REMARK8','REMARK9','REMARK10'];
			}
			else if(iftbl =='TB_IFSWC003'){
				colH = ['DOC_NO','DOC_NOSEQ', 'CMCDKY',   'CMCDVL',   'USE_YN',    'IF_STATUS'];
				colI = ['DOC_NO','DOC_NOSEQ', 'CMCDKY',    'CMCDVL',   'USE_YN',    'IF_STATUS'];
			}
			else if(iftbl =='TB_IFSWC006'){
				colH = [ 'DOC_NO', 'DOC_NOSEQ', 'BARCODE', 'LOT_ID', 'CT_LOT_ID', 'PLNT_CD', 'MCHN_CD', 'PRCS_CD', 'FCLT_CD', 'WORK_DT', 'WORK_TIME', 'WORK_SEQ', 'CLASS', 'MATERIAL_NO', 'WEIGHT', 'LENGTH', 'WRKORD', 'SPECIAL_NO', 'USER_NM', 'WORK_DRCT', 'CRAT_DATE', 'CRAT_ID', 'UPDT_DATE', 'UPDT_ID', 'REMARK1', 'REMARK2', 'REMARK3', 'REMARK4', 'REMARK5', 'REMARK6', 'REMARK7', 'REMARK8', 'REMARK9', 'REMARK10', 'IF_STATUS'];
				colI = [ 'DOC_NO', 'DOC_NOSEQ', 'BARCODE', 'LOT_ID', 'CT_LOT_ID', 'PLNT_CD', 'MCHN_CD', 'PRCS_CD', 'FCLT_CD', 'WORK_DT', 'WORK_TIME', 'WORK_SEQ', 'CLASS', 'MATERIAL_NO', 'WEIGHT', 'LENGTH', 'WRKORD', 'SPECIAL_NO', 'USER_NM', 'WORK_DRCT', 'CRAT_DATE', 'CRAT_ID', 'UPDT_DATE', 'UPDT_ID', 'REMARK1', 'REMARK2', 'REMARK3', 'REMARK4', 'REMARK5', 'REMARK6', 'REMARK7', 'REMARK8', 'REMARK9', 'REMARK10', 'IF_STATUS'];
			}
			else if(iftbl =='TB_IFSWC007'){
				colH = ['DOC_NO', 'DOC_NOSEQ', 'IND_BCD', 'LOT_NO', 'CT_LOT_NO', 'WERKS', 'MCHN_NO', 'PRCS_NO', 'FCLT_CD', 'WORK_DT', 'STA', 'REGDATE', 'REGID', 'UPDDATE', 'UPDID', 'REMARK1', 'REMARK2', 'REMARK3', 'REMARK4', 'REMARK5', 'REMARK6', 'REMARK7', 'REMARK8', 'REMARK9', 'REMARK10', 'IF_STATUS'];
				colI = ['DOC_NO', 'DOC_NOSEQ', 'IND_BCD', 'LOT_NO', 'CT_LOT_NO', 'WERKS', 'MCHN_NO', 'PRCS_NO', 'FCLT_CD', 'WORK_DT', 'STA', 'REGDATE', 'REGID', 'UPDDATE', 'UPDID', 'REMARK1', 'REMARK2', 'REMARK3', 'REMARK4', 'REMARK5', 'REMARK6', 'REMARK7', 'REMARK8', 'REMARK9', 'REMARK10', 'IF_STATUS'];
			}

			$("#appendBodyGrid").append('<td GH="40" GCol="rownum">1</td>');
			$('#appendBodyGrid').append('<td GH="40" GCol="rowCheck"></td>');

			var typstr = "";
			for(var i=0; i < colH.length; i++){
				var width = colH[i].length > 10 ? 160 : (colH[i].length > 6 ? 130 : 100);
				$("#appendBodyGrid").append('<td GH="'+width+' '+colH[i].replaceAll(' ','')+'" GCol="text,'+colI[i]+'" '+typstr+'></td>');
			}

			$('.closer').click();

		}

		function fn_closing(){
			this.close();
		}

		function commonBtnClick(btnName){
			if(btnName == "Send"){
				send();
			} else if(btnName == "Download"){
				excelDownload();
			} else if(btnName == "Close"){
				fn_closing();
			}
		}

		function excelDownload(){
			gridList.excelUpGridId = "gridListSub";
			gridList.excelUploadTemplateDown();
		}

		var timerId = 0;
		var ingCnt;
		function showCnt() {
			cnt.value = ingCnt;
		}

		function send(){
			var json = netUtil.sendData({
	    		module : 'mes',
	    		command : 'SYSTEMCHECK',
	    		sendType : 'map'
	    	});
	    	
	    	if(json.data.USE_YN == 'Y'){
	    		alert('시스템 점검 중입니다. 1 ~ 5분 동안 잠시만 기다려 주세요.');
	    		return;
	    	}
			
			var list = gridList.getSelectData("gridListSub");
			if( list.length == 0 ){
				commonUtil.msgBox("ITF_M0029"); // 전송할 데이터가 없습니다.
				return;
			}
			var docno = '';
			var message = '';
			// check validation
			if(gridList.validationCheck("gridListSub", "data")) {
				//전송하시겠습니까?
				if(!commonUtil.msgConfirm(commonUtil.getMsg("ITF_M0030"))){
					return;
				}
				for(var i = 0; i < list.length; i++){
					if(iftbl.substr(3,3) == 'IFS'){
						if(list[i].get("MDOCNO") != ''){
							docno = list[i].get('MDOCNO') + ',' + docno;		
						}
					}else{
						if(list[i].get("DOC_NO") != ''){
							docno = list[i].get('DOC_NO') + ',' + docno;
						}
					}
				}

				if("MES" == sysfr && "WMS" == systo) {
					var jsend = netUtil.sendData({
						url : '/common/api/json/'+ifid+'/send.data',
					});
					if(jsend.result == 'SUCCESS') {
						alert(jsend.result)
						// commonUtil.msgBox("ITF_M0031", jsend.data); // 전송 완료했습니다.
					}else {
						alert(jsend.result)
					}
					searchList()
					window.opener.searchList();
				}else {
					docno = docno.split(',');
					
					if(docno == '')	return alert("보내려고 하는 MES문서번호가 없습니다.");

					for(var i = 0; i < docno.length; i++){
						if(docno[i] != ''){
							// 로그순번 채번
							var jsonLOGSEQNO = netUtil.sendData({
								url : "/IF/map/json/IFWMSLOGSEQNO.data",
								param : param
							});

							if(jsonLOGSEQNO && jsonLOGSEQNO.data){
								var param = new DataMap();
								param.put("rfcfn", rfcfn);
								param.put("IFID", ifid);
								param.put("iftbl", iftbl);
								param.put("DOC_NO", docno[i]);
								param.put("ownrky", "<%=ownrky%>");
								param.put("LOGSEQNO", jsonLOGSEQNO.data.LOGSEQNO);
								var jsend = netUtil.sendData({
									url : "/mes/erpif/json/sendIF.data",
									param : param
								});
								
								if(jsend && jsend.data){
									if(jsend.data == "SUCCESS") {
									} else {
										message = jsend.data + message;
									}
								} else {
									// 전송호출 실패
									commonUtil.msgBox("ITF_M0032", jsend.data); // 전송 살패했습니다.
								}
							} else {
								alert('에러')
							}
						}
					}
					if(message == ''){
						commonUtil.msgBox("ITF_M0031", jsend.data); // 전송 완료했습니다.
					}else{
						alert(message);
					}
					searchList()
					window.opener.searchList();
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
					<input type="button" CB="Send SEARCH 데이터전송">
					<input type="button" CB="Close CHECK 닫기">
				</div>
			</div>
			<div class="search_inner">
				<div class="search_wrap">
					<dl>
						<dd>
							<table style="width:1000px;">
								<tr>
									<td style="width:170px;">인터페이스ID : <input type="text" id="IFID" style="width:80px;" readonly></td>
									<td style="width:300px;">인터페이스명 : <input type="text" id="IFKNM" style="width:210px;" readonly></td>
									<td style="width:150px;">IF테이블 : <input type="text" id="IFTBL" style="width:80px;" readonly></td>
									<td style="width:200px;">RFC : <input type="text" id="RFCFN" style="width:150px;" readonly></td>
								</tr>
							</table>
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
					<li><a href="#tabs1-1" CL='STD_LIST'><span>리스트</span></a></li>
				</ul>
				<div class="table_box section" id="tabs1-1">
					<div class="table_list01">
						<div class="scroll">
							<table id="resetTable" class="table_c">
							</table>
						</div>
					</div>

					<div class="btn_lit tableUtil" id="resetUtil">
						<button type='button' GBtn="find"></button>
						<button type='button' GBtn="sortReset"></button>
						<button type='button' GBtn="layout"></button>
						<button type='button' GBtn="excel"></button>
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