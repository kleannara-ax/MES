<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>인터페이스 상세내역</title>
<%@ include file="/common/include/webdek/head.jsp" %>
<script type="text/javascript">

	window.resizeTo('1250','600');
	var iftbl;
	var ifid;
	var bwart;
	var rfcfn;
	var sysfr;
	var systo;
	var rfctbl;
	var rfcp1;
	var rfcp2;
	
	$(document).ready(function(){
		var data = page.getLinkPopData();
		dataBind.dataNameBind(data, "searchArea");
		
		ifid = data.get("IFID");
		iftbl = data.get("IFTBL");
		bwart = data.get("BWART");
		bwartnm = data.get("BWARTNM");
		rfcfn = data.get("RFCFN");
		rfctbl = data.get("RFCTBL");
		rfcp1 = data.get("RFCP1");
		rfcp2 = data.get("RFCP2");
		sysfr = data.get("SYSFR");
		systo = data.get("SYSTO");;
		
		console.log(data)

		$("#IFID").val(ifid);
		$("#IFKNM").val(data.get("IFKNM"));
		$("#IFTBL").val(iftbl);
		$("#BWARTNM").val(bwartnm);
		$("#RFCFN").val(rfcfn);
		$("#RFCTBL").val(rfctbl);
		$("#RFCP1").val(rfcp1);
		$("#RFCP2").val(rfcp2);
		setHead(iftbl);
	});

	function setHead(iftbl) {
		$("#resetTable").empty();
		$("#resetUtil").empty();
		var html='<table class="table_c">';
			html +='<tbody id="gridListSub">';
			html +='<tr id="appendBodyGrid" CGRow="true">';
			html +='</tr>';
			html +='</tbody>';
			html +='</table>';
		$("#resetTable").html(html);

		var util = '<div class="btn_lit tableUtil">';
			util += '<button type="button" GBtn="find"></button>';
			util += '<button type="button" GBtn="sortReset"></button>';
			util += '<button type="button" GBtn="add"></button>';
			util += '<button type="button" GBtn="excel"></button>';
			util += '<span class="txt_total" >총 건수 : <span GInfoArea="true">0</span></span>';
			util += '</div>';
		$("#resetUtil").html(util);
		

			var colH;
			var colI;

			if(iftbl == "TB_IFR001") {
				colH = ['수신번호','품목코드','공장코드','품명', '품명', '규격', '유형','유형명', '자재그룹', '자재그룹명', '제품군', '제품군명', '유통기한', 'IF_STATUS']
				colI = ['IF_IFR_NO','MATNR','WERKS','MAKTX','MAKTG','GROES','MTART','MTBEZ','MATKL','WGBEZ','SPART','VTEXT', 'MHDHB', 'IF_STATUS'];
			}
			else if(iftbl == "TB_IFR002") {
				colH = ['수신번호','플랜트','플랜트명' ,'I/F상태'];
				colI = ['IF_IFR_NO' ,'WERKS','NAME1','IF_STATUS' ];
			}
			else if(iftbl == "TB_IFR003") {
				colH = ['수신번호','플랜트','저장위치', '저장위치명' ,'I/F상태'];
				colI = ['IF_IFR_NO' ,'WERKS', 'LGORT','LGOBE','IF_STATUS' ];
			}
			else if(iftbl == "TB_IFR005") {
				colH = ['수신번호','품목코드','단위','분자','분모','I/F상태'];
				colI = ['IF_IFR_NO','MATNR','MSEHI','UMREZ','UMREN','IF_STATUS'];
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
			else if(iftbl == "TB_IFR009") {
				colH = ['MES수신번호','납품처','납품처명','우편번호','국가키','전화번호','휴대폰번호','팩스번호','거래처담당자email주소','사업자등록번호','대표자명','도시','번지및상세주소','판매처','판매처명','영업자ID','영업사원명','영업사원휴대폰번호','업태','업종','삭제여부','I/F상태'];
				colI = ['IF_IFR_NO','KUNWE','KUNWET','PSTLZ','LAND1','TELF1','TELF2','TELFX','SMTP_ADDR','STCD2','J_1KFREPRE','ORT01','STRAS','KUNNR','KUNNRT','KUNZP','KUNZPT','TELFZP','J_1KFTIND','J_1KFTBUS','LOEVM','IF_STATUS'];
			}
			else if(iftbl == "TB_IFR010") {
				colH = ['수신번호','거래처코드','거래처명','우편번호','Countrykey','전화번호','휴대폰번호','팩스번호','거래처담당자email주소','사업자등록번호','대표자명','삭제여부','주소1','주소2','거래처담당자명','거래처담당자휴대폰번호1','거래처메모','공급처구분','업태','업종','I/F상태'];
				colI = ['IF_IFR_NO','ZCODE','NAME1','PSTLZ','LAND1','TELF1','TELF2','TELFX','SMTP_ADDR','STCD2','J_1KFREPRE','LOEVM','ADDR1','ADDR2','CNAME','CPHON','PTNG01','PTNL01','PTNL03','PTNL04','IF_STATUS']
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
			else if(iftbl == "TB_LAMI_PC_IFR015") {
				colH = ['수신번호', '오더번호', '플랜트', '시작일자', '오더유형', '오더유형 텍스트', '제품코드', '생산지시량', '생산지시단위', 'Work Center', '작업지시자', '생산버전', 'BOM Num', '대체Bom', '모품목기준수량', '모품목기준수량 단위', '릴리즈일자', '작업순서', '오더 삭제 지시자', 'I/F 상태'];
				colI = ['IF_IFR_NO', 'AUFNR', 'WERKS', 'GSTRP', 'AUART', 'AUARTXT', 'MATNR', 'FQTY', 'MEINS', 'ARBPL', 'AENAM', 'PRCMC', 'STLNR', 'STLAL', 'BMENG', 'BMEIN', 'FTRMI', 'SEQ', 'DLFL', 'IF_STATUS'];
			}
            else if(iftbl == "TB_LAMI_SL_IFR016") {
                colH = ['수신번호', '오더번호', '플랜트', '시작일자', '오더유형', '오더유형 텍스트', '제품코드', '생산지시량', '생산지시단위', 'Work Center', '작업지시자', '생산버전', 'BOM Num', '대체Bom', '모품목기준수량', '모품목기준수량 단위', '릴리즈일자', '작업순서', '오더 삭제 지시자', 'I/F 상태'];
                colI = ['IF_IFR_NO', 'AUFNR', 'WERKS', 'PRDDT', 'AUART', 'AUARTXT', 'MATNR', 'FQTY', 'MEINS', 'ARBPL', 'AENAM', 'PRCMC', 'STLNR', 'STLAL', 'BMENG', 'BMEIN', 'FTRMI', 'SEQ', 'DLFL', 'IF_STATUS'];
            }			
			else if(iftbl == "TB_IFR017") {
				colH = ['수신번호', '오더번호', '플랜트', '시작일자', '오더유형', '오더유형 텍스트', '제품코드', '생산지시량', '생산지시단위', 'Work Center', '작업지시자', '생산버전', 'BOM Num', '대체Bom', '모품목기준수량', '모품목기준수량 단위', '릴리즈일자', '작업순서', '생산종료일', '오더 삭제 지시자', 'I/F 상태'];
				colI = ['IF_IFR_NO', 'AUFNR', 'WERKS', 'SDATE', 'AUART', 'AUARTXT', 'MATNR', 'FQTY', 'MEINS', 'ARBPL', 'AENAM', 'PRCMC', 'STLNR', 'STLAL', 'BMENG', 'BMEIN', 'FTRMI', 'SEQ', 'EDATE', 'DLFL', 'IF_STATUS'];
			}
			else if(iftbl == "TB_IFR018") {
				colH = ['수신번호', '오더번호', '플랜트', '시작일자', '생산라인구분', '생산라인구분명', '제품코드', '지종코드', '평량', 'J/R 지폭', 'J/R 권치수', '총중량', 'J/R 개수', '생산지시단위', '판지구분자', '작업지시자', 'FROM 생산호기', 'BOM Num', '대체Bom', '모품목기준수량', '모품목기준수량 단위', '비계획 생산오더', '오더 삭제 지시자', '반복생산 지시자', '항차', 'I/F 상태'];
				colI = ['IF_IFR_NO', 'AUFNR', 'WERKS', 'BUDAT', 'PRDTYPE', 'PRDTYPETXT', 'MATNR', 'PCODE', 'WEIGHT', 'JWIDTH', 'JROLLCNT', 'JBRGEW', 'JRCNT', 'MEINS', 'SHEET', 'AENAM', 'MACHINE', 'STLNR', 'STLAL', 'BMENG', 'BMEIN', 'NAUFNR', 'DLFL', 'REM', 'ROUTE', 'IF_STATUS'];
			}
			else if(iftbl == "TB_IFR019") {
				colH = ['수신번호', '오더번호', '점보롤 오더 번호', '플랜트', '생산지시 No', '생산지시 seq', '시작일자', '오더유형', '오더유형 텍스트', '생산라인구분', '생산라인구분명', '생산 호기', '생산 호기 명', '밀롤 자재 코드', '생산 호기', '생산 호기 명', '점보롤 자재 코드', '지종코드', '평량', 'M/R 지폭', 'M/R 지폭_INPUT', 'M/R 지폭_SLITER', 'M/R 권치수', 'M/R 폭수', 'M/R 중량', '단위', 'J/R 개수', '판매 문서', '판매 문서 품목 번호', '판매 문서 오더 유형', '판매 문서 오더 유형 텍스트', '판매 문서', '판매 문서 품목 번호', '납품 요청일자', '판매 문서 오더 유형', '판매 문서 오더 유형 텍스트', '비고', '판지 구분자', '슬리터 구분', '밀롤 창고 적치 여부', '카터', 'BOM Num','대체Bom','모품목기준수량','모품목기준수량 단위','밀롤 오더 번호','항차', '오더 삭제 지시자','I/F상태','FROM 생산호기','FROM 생산 호기명','TO 생산호기','TO 생산 호기명','판매처','판매처명','슬리터 구분','이전 오더']
				colI = ['IF_IFR_NO', 'AUFNR', 'JRPO', 'WERKS', 'ORDER_NUM', 'ORDER_SEQ', 'BUDAT', 'AUART', 'AUARTXT', 'PRDTYPE', 'PRDTYPETXT', 'MVERID', 'MVERIDTXT', 'MMATNR', 'VERID', 'VERIDTXT', 'MATNR', 'PCODE', 'WEIGHT', 'MWIDTH', 'MWIDTH_INPUT', 'MWIDTH_SLITER', 'MROLLCNT', 'MRCNT', 'MBRGEW', 'MGEWEI', 'JRCNT', 'OVBELN', 'OPOSNR', 'OAUART', 'OAUARTXT', 'VBELN', 'POSNR', 'VDATU', 'SAUART', 'SAUARTXT', 'REMARK', 'SHEET', 'SLITER_SET', 'MRLDCK', 'CUTTER', 'STLNR', 'STLAL', 'BMENG', 'BMEIN', 'MRPO','ROUTE', 'DLFL', 'IF_STATUS','MACHINE','MACHINETXT','TOMACHINE','TOMACHINETXT','KUNNR','NAME1','SLITER','FRAUFNR'];
			}
			else if(iftbl == "TB_IFR020") {
				colH = ['수신번호','오더번호','밀롤 오더 번호','플랜트','시작일자','오더유형','오더유형 텍스트','FROM 생산호기','FROM 생산 호기명','TO 생산호기','TO 생산 호기명','생산 호기','생산 호기명','재단 자재 코드','지종','평량','가로길','세로길','폭수','수량','총중량','단위','팔레트당연수','속당매수','쌍팔레트','판매문서','판매문서 항목번호','판매문서 유형','판매 문서 오더 유형 텍스트','판매문서','판매문서 항목번호','판매문서 유형','판매 문서 오더 유형 텍스트','카터','BOM Num','대체Bom','모품목기준수량','모품목기준수량 단위','오더 삭제 지시자','항차','I/F상태','재단출고 오더 여부','비고','판매처','판매처명','M/R LOT Number','생산 계획 시간 (HHMM)','IS-M: Production Sequence','반','자재 번호','M/R 권치수','M/ROLL 중량','중량 단위','밀롤 지관 인치(SIZE)','포장타입'];
				colI = ['IF_IFR_NO','AUFNR','MRPO','WERKS','BUDAT','AUART','AUARTXT','MACHINE','MACHINETXT','TOMACHINE', 'TOMACHINETXT', 'CVERID','PVERIDTXT','CMATNR','PCODE','WEIGHT','WLEN','VLEN','CTCNT','CNT','CGEWEW','CGEWEI','ZZATT1','ZZATT2','DOUBLEFLAG','VBELN','POSNR','SAUART','SAUARTXT','OVBELN','OPOSNR','OAUART','OAUARTXT','CUTTER','STLNR','STLAL','BMENG','BMEIN','DLFL','ROUTE','IF_STATUS','ZCOR','REMARK','KUNNR','NAME1','MAUFNR','PTIM','PSEQ','WORKGROUP','MMATNR','MROLLCNT','MBRGEW','MGEWEI','CORESIZE','PACKTYPE'];
			}
			else if(iftbl == "TB_IFR021") {
				colH = ['수신번호','오더번호','오더순번','재단 오더 번호','플랜트','시작일자','오더유형','오더유형 텍스트','FROM 생산호기','FROM 생산 호기명','TO 생산호기','TO 생산 호기명','생산 호기','생산 호기명','재단 자재 코드','지종','평량','가로길','세로길','수량','수량','총중량','단위','팔레트당연수','속당매수','쌍팔레트','팔레트당연수','컨테이너 타입','포장 타입','판매문서','판매문서 항목번호','판매문서 유형','판매 문서 오더 유형 텍스트','판매문서','판매문서 항목번호','판매문서 유형','판매 문서 오더 유형 텍스트','판매처','비고','BOM Num','대체Bom','모품목기준수량','모품목기준수량 단위','오더 삭제 지시자','항차','I/F상태','폭수','매','속','핀매처명','이전 오더'];
				colI = ['IF_IFR_NO','AUFNR','PACKSEQ','CTPO','WERKS','BUDAT','AUART','AUARTXT','MACHINE','MACHINETXT','TOMACHINE','TOMACHINETXT','PVERID','PVERIDTXT','PMATNR','PCODE','WEIGHT','WLEN','VLEN','PTCNT','PCNT','PGEWEW','PGEWEI','ZZATT1','ZZATT2','DOUBLEFLAG','PALETTECNT','CONTYPE','PACKTYPE','VBELN','POSNR','SAUART','SAUARTXT','OVBELN','OPOSNR','OAUART','OAUARTXT','KUNNR','REMARK','STLNR','STLAL','BMENG','BMEIN','DLFL','ROUTE','IF_STATUS','PKCNT','MCNT','SCNT','NAME1','FRAUFNR'];
			}
			else if(iftbl == "TB_IFR022") {
				colH = ['수신번호','오더번호' ,'플랜트','시작일자','오더유형','오더유형 텍스트','제품코드' ,'생산지시량','생산지시단위','Work Center','생산버전','BOM Num' ,'대체Bom','모품목기준수량','모품목기준수량 단위','릴리즈일자','판매문서번호' ,'판매문서Item번호','오더삭제지시자','I/F상태','지종','평량','가로길','세로길','팔레트당연수','속당매수','포장타입','매','속','판매처 코드','판매처'];
				colI = ['IF_IFR_NO','AUFNR', 'WERKS', 'GSTRS', 'AUART', 'AUARTXT', 'MATNR', 'GAMNG', 'GMEIN', 'ARBPL', 'VERID', 'STLNR', 'STLAL', 'BMENG', 'BMEIN', 'FTRMI', 'VBELN', 'POSNR', 'DLFL', 'IF_STATUS','PCODE','WEIGHT','WLEN','VLEN','ZZATT1','ZZATT2','PACKTYPE','MCNT','SCNT','KUNNR','NAME1'];
			}
			else if(iftbl == "TB_IFR012") {
				colH = ['IF_SEQ', 'IF_DATE', 'RECV_FLAG', 'RECV_ERR_MSG', 'RECV_DATE', 'TENANT_ID', 'TENANT_NAME', 'EMP_NO', 'MAIL_ID', 'MAIL_ADDRESS', 'EMP_NAME', 'EMP_ENG_NAME', 'EMP_TYPE', 'WORK_PLACE', 'WORK_TYPE', 'DEPT_CODE', 'JOB_TITLE_CODE', 'JOB_TITLE_NAME', 'JOB_DUTY_CODE', 'JOB_DUTY_NAME', 'COUNTRY_CODE', 'COUNTRY_NAME', 'LANGUAGE_TYPE', 'GRANTER_MAIL_ID', 'MOBILE', 'OFFICE_TEL_NO', 'STATUS', 'RETIRE_YMD', 'UPDT_DATE', 'UPDT_ID', 'NEXTHR_IF_SEQ', 'REMARK1', 'REMARK2', 'REMARK3', 'REMARK4', 'REMARK5', 'REMARK6', 'REMARK7', 'REMARK8', 'REMARK9', 'REMARK10'];
				colI = ['IF_SEQ', 'IF_DATE', 'RECV_FLAG', 'RECV_ERR_MSG', 'RECV_DATE', 'TENANT_ID', 'TENANT_NAME', 'EMP_NO', 'MAIL_ID', 'MAIL_ADDRESS', 'EMP_NAME', 'EMP_ENG_NAME', 'EMP_TYPE', 'WORK_PLACE', 'WORK_TYPE', 'DEPT_CODE', 'JOB_TITLE_CODE', 'JOB_TITLE_NAME', 'JOB_DUTY_CODE', 'JOB_DUTY_NAME', 'COUNTRY_CODE', 'COUNTRY_NAME', 'LANGUAGE_TYPE', 'GRANTER_MAIL_ID', 'MOBILE', 'OFFICE_TEL_NO', 'STATUS', 'RETIRE_YMD', 'UPDT_DATE', 'UPDT_ID', 'NEXTHR_IF_SEQ', 'REMARK1', 'REMARK2', 'REMARK3', 'REMARK4', 'REMARK5', 'REMARK6', 'REMARK7', 'REMARK8', 'REMARK9', 'REMARK10'];
			}
			else if(iftbl == "TB_IFR023") {
				colH = ['IF_SEQ', 'IF_DATE', 'RECV_FLAG', 'RECV_ERR_MSG', 'RECV_DATE', 'TENANT_ID', 'TENANT_NAME', 'DEPT_CODE', 'DEPT_NAME', 'DEPT_ENG_NAME', 'BUSINESS_PLACE', 'DIVISION_CODE', 'DIVISION_NAME', 'PARENT_DEPT_CODE', 'SORT_ORDER', 'USE_YN', 'UPDT_DATE', 'UPDT_ID', 'NEXTHR_IF_SEQ', 'REMARK1', 'REMARK2', 'REMARK3', 'REMARK4', 'REMARK5', 'REMARK6', 'REMARK7', 'REMARK8', 'REMARK9', 'REMARK10'];
				colI = ['IF_SEQ', 'IF_DATE', 'RECV_FLAG', 'RECV_ERR_MSG', 'RECV_DATE', 'TENANT_ID', 'TENANT_NAME', 'DEPT_CODE', 'DEPT_NAME', 'DEPT_ENG_NAME', 'BUSINESS_PLACE', 'DIVISION_CODE', 'DIVISION_NAME', 'PARENT_DEPT_CODE', 'SORT_ORDER', 'USE_YN', 'UPDT_DATE', 'UPDT_ID', 'NEXTHR_IF_SEQ', 'REMARK1', 'REMARK2', 'REMARK3', 'REMARK4', 'REMARK5', 'REMARK6', 'REMARK7', 'REMARK8', 'REMARK9', 'REMARK10'];
			}
			else if(iftbl == "PULPIN") {
				colH = ['IF_SEQ', 'IF_DATE', 'RECV_FLAG', 'RECV_ERR_MSG', 'RECV_DATE', 'IV_EBELN', 'IV_EBELP', 'IV_MBLNR', 'IV_ZEILE', 'IV_MJAHR', 'IV_STATUS', 'IV_WERKS', 'IV_BEDAT', 'IV_LIFNR', 'IV_SEQ', 'IV_MATNR', 'IV_CAR_NUMBER', 'IV_DRIVER', 'IV_WEIGHER', 'IV_BALE_CNT', 'IV_WEIGHT_TIME', 'IV_GR_MENGE', 'IV_MEINS', 'IV_TOTAL_WEIGHT', 'IV_EMPTY_WEIGHT', 'IV_ACTUAL_WEIGHT', 'IV_REGAIN1', 'IV_REGAIN2', 'IV_REGAIN3', 'IV_REGAIN_REASON', 'IV_TOTAL_LOSE_RATIO', 'IV_LOSE_WEIGHT', 'IV_VER1_TIME', 'IV_VER2_TIME', 'IV_VER1_WEIGHT', 'IV_VER2_WEIGHT', 'IV_BIGO1', 'IV_BIGO2', 'IV_BIGO3', 'IV_BIGO4', 'IV_BIGO5', 'IV_MOIST1', 'IV_MOIST2', 'IV_MOIST3', 'IV_MOIST4', 'IV_MOIST5', 'IV_MOIST6', 'IV_MOIST7', 'IV_MOIST8', 'IV_MOIST9', 'IV_MOIST10', 'IF_MES_KEY'];
				colI = ['IF_SEQ', 'IF_DATE', 'RECV_FLAG', 'RECV_ERR_MSG', 'RECV_DATE', 'IV_EBELN', 'IV_EBELP', 'IV_MBLNR', 'IV_ZEILE', 'IV_MJAHR', 'IV_STATUS', 'IV_WERKS', 'IV_BEDAT', 'IV_LIFNR', 'IV_SEQ', 'IV_MATNR', 'IV_CAR_NUMBER', 'IV_DRIVER', 'IV_WEIGHER', 'IV_BALE_CNT', 'IV_WEIGHT_TIME', 'IV_GR_MENGE', 'IV_MEINS', 'IV_TOTAL_WEIGHT', 'IV_EMPTY_WEIGHT', 'IV_ACTUAL_WEIGHT', 'IV_REGAIN1', 'IV_REGAIN2', 'IV_REGAIN3', 'IV_REGAIN_REASON', 'IV_TOTAL_LOSE_RATIO', 'IV_LOSE_WEIGHT', 'IV_VER1_TIME', 'IV_VER2_TIME', 'IV_VER1_WEIGHT', 'IV_VER2_WEIGHT', 'IV_BIGO1', 'IV_BIGO2', 'IV_BIGO3', 'IV_BIGO4', 'IV_BIGO5', 'IV_MOIST1', 'IV_MOIST2', 'IV_MOIST3', 'IV_MOIST4', 'IV_MOIST5', 'IV_MOIST6', 'IV_MOIST7', 'IV_MOIST8', 'IV_MOIST9', 'IV_MOIST10', 'IF_MES_KEY'];
			}
			else if(iftbl == "TB_IFRWC001") {
				colH = ['IF_MES_KEY', 'IF_SEQ', 'IF_DATE', 'RECV_FLAG', 'RECV_ERR_MSG', 'RECV_DATE', 'WCS_KEY_NO', 'WCS_KEY_SEQ', 'MOVE_DT', 'BARCODE', 'LOT_ID', 'FROM_STK', 'FROM_LOC', 'TO_STK','TO_LOC', 'REMARK1', 'REMARK2', 'REMARK3', 'REMARK4', 'REMARK5', 'REMARK6', 'REMARK7', 'REMARK8', 'REMARK9', 'REMARK10'];
				colI = ['IF_MES_KEY', 'IF_SEQ', 'IF_DATE', 'RECV_FLAG', 'RECV_ERR_MSG', 'RECV_DATE', 'WCS_KEY_NO', 'WCS_KEY_SEQ', 'MOVE_DT', 'BARCODE', 'LOT_ID', 'FROM_STK', 'FROM_LOC', 'TO_STK','TO_LOC', 'REMARK1', 'REMARK2', 'REMARK3', 'REMARK4', 'REMARK5', 'REMARK6', 'REMARK7', 'REMARK8', 'REMARK9', 'REMARK10'];
			}
			/** rownum 추가 **/
			$("#appendBodyGrid").append('<td GH="40" GCol="rownum">1</td>');
			/** check box **/
			var typstr = "";
			for(var i=0; i < colH.length; i++){
				var width = colH[i].length > 10 ? 160 : (colH[i].length > 6 ? 130 : 100);
				if(colI[i] == "QTYPRD" || colI[i] == "MENGE" || colI[i] == "MENGE_B" || colI[i] == "QTYGOD"
				|| colI[i] == "QTYBAD" || colI[i] == "QTSHP" || colI[i] == "ZQTSACT" || colI[i] == "QTADJU") {
					typstr = 'GF="N 20,3"';
				} else if(colH[i].search(/일자/) != -1){
					typstr = 'GF="D"';
				} else {
					typstr = "";
				}
				$("#appendBodyGrid").append('<td GH="'+width+' '+colH[i].replaceAll(' ','')+'" GCol="text,'+colI[i]+'" '+typstr+'></td>');
			}

			if(iftbl != 'PULPIN') {
				$("#appendBodyGrid").append('<td GH="400 에러내용" GCol="text,IF_ERR_MESS" ></td>');
				$("#appendBodyGrid").append('<td GH="150 생성일자" GCol="text,IF_GET_DATE" GF="DTS"></td>');
				$("#appendBodyGrid").append('<td GH="150 이관일자" GCol="text,IF_SET_DATE" GF="DTS"></td>');
			}

		$('.closer').click();
			
			gridList.setGrid({
		    	id : "gridListSub",
				module : "Erpif",
				command : "IFRECEIVE",
				colorType : true,
				emptyMsgType : false
			});
	}

	function fn_closing(){
		this.close();
	}
	
	function commonBtnClick(btnName){
		if(btnName == "Search"){
			searchList();
		} else if(btnName == "Close"){
			fn_closing();
		} else if(btnName == "Download"){
			excelDownload();
		}
	}
	
	var timerId = 0;
	var ingCnt;
	function showCnt() {
		cnt.value = ingCnt;
	}

	function searchList(){
		if(!commonUtil.msgConfirm("데이터 수신 요청 하시겠습니까?")){
			return;
		}

		loadingOpen();
		setTimeout(function(){
			
			var param = new DataMap();
			param.put("IFID", ifid);
			param.put("IFTBL", iftbl);
			param.put("BWART", bwart);
			param.put("RFCFN", rfcfn);
			param.put("RFCTBL", rfctbl);
			param.put("RFCP1", rfcp1);
			param.put("RFCP2", rfcp2);
			param.put("SYSFR", sysfr);
			param.put("SYSTO", systo);
			param.put("OWNRKY", "<%=ownrky%>");
			console.log(param);
	

			// 데이터 수신요청
			var url = '/rfc/json/rfcCall.data';
			if(iftbl == 'TB_IFR012' || iftbl == 'TB_IFR023' || iftbl == 'PULPIN' || iftbl == 'TB_IFRWC001') {
				url = "/hr/json/data.data";
			}else {
				var json = netUtil.sendData({
					url : "/IF/map/json/IFRCVMAXPREVSEQ.data",
					param : param
				});

				if(json && json.data){
					param.put("PLOGSEQNO", json.data.LOGSEQNO);
				}
			}
			var json = netUtil.sendData({
				url : url,
				param : param
			});

			if(json && json.data){
				if(json.data.row_count > 0) {
					commonUtil.msgBox("데이터 수신 완료했습니다.");
					// 수신완료 데이터 조회
					gridList.gridList({
						id : "gridListSub",
						param : param
					});
				} else {
					commonUtil.msgBox("데이터 수신 완료했습니다.");
					gridList.gridList({
						id : "gridListSub",
						param : param
					});
				}

				window.opener.searchList();
			} else {
				commonUtil.msgBox("수신된 데이터가 없습니다.");
			}

			loadingClose();
		}, 1);
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
					<input type="button" CB="Search APPLY 수신요청">
					<input type="button" CB="Close CHECK 닫기">
				</div>
			</div>
			<div class="search_inner">
				<div class="search_wrap">
					<dl>
						<dd>
							<table style="width:1000px">
								<tr >
									<td style="width:200px;vertical-align:middle;">인터페이스ID : <input type="text" id="IFID" style="width:80px;" readonly></td>
									<td style="width:300px;">인터페이스명 : <input type="text" id="IFKNM" style="width:210px;" readonly></td>
									<td style="width:150px;">IF테이블 : <input type="text" id="IFTBL" style="width:80px;" readonly></td>
									<td style="width:200px;">RFC : <input type="text" id="RFCFN" style="width:150px;" readonly></td>
								</tr>
							</table>
						</dd>
					</dl>
				</div>
			</div>
		</div>
		<div class="search_next_wrap" style="height:470px;">
			<div class="content_layout tabs">
				<ul class="tab tab_style02">
					<li><a href="#tabs1-1" ><span>수신정보</span></a></li>
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