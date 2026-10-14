--------------------------------------------------------
--  DDL for Procedure SP_SCH13_S01
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_SCH13_S01" (
	P_TYPE           IN    varchar2, -- LIST, SAVE
	P_JSON_STR       IN    CLOB,
	P_SUCCESS       OUT    varchar2,
	P_RS_LIST       OUT    SYS_REFCURSOR 
)
/*==============================================================================
 * PROGRAM ID    : SP_SCH13_S01
 * PROGRAM NAME  : 밀롤, 슬리터 작업지시
 * VERSION       : 1.0.0
 * DESCRIPTION   : 밀롤, 슬리터 작업지시 를 관리한다.
 *                 
 * AUTHOR NAME   : 박충식
 * CREATE DATE   : 2022/05/02
 * SYSTEM NAME   : MES
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}  <생략가능>
 * SUB PROCEDURE : {아휘 프로시저 명칭 기술}      <생략가능>
 * SUB PACKAGES  : {하위 패키지 기술}            <생략가능>
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술} <생략가능>
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/05/02    1.0.0   박충식         Initial Version 
 *==============================================================================
 *  관련 테이블
 *        - [TB_SCH016] : (CRUD) 밀롤, 슬리터 작업지시 정보
 * *      
 *=============================================================================*/

AS

    V_PRG_NM          VARCHAR2(100)  := 'SP_SCH13_S01';     -- PROCEDURE NAME

    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD      NUMBER(5)           := 0;
    E_SQL_ERR_MSG     VARCHAR2(4000);

   -- V_RTN_CLOB       CLOB;
   -- V_RTN_CURSOR     SYS_REFCURSOR;
   -- V_ERROR          CLOB;

    -- JSON을 위한 변수선언 영역
    V_JSON           JSON_OBJECT_T;
    V_ARR_LIST       JSON_ARRAY_T;
    V_ARR_HEAD       JSON_ARRAY_T;
    V_OBJ            JSON_OBJECT_T;

    -- 세션값 처리용 변수선언 영역
    V_SQL            CLOB;
    V_RUN_SQL        varchar2(1);
    V_RANGE_SQL      varchar2(4000);
    V_DEBUG          varchar2(1);

    -- 세션값 처리용 변수선언 영역
    V_PLT_CD         varchar2(2);
    V_SESS_USER_ID   varchar2(20);

    -- 조건절 처리용 변수선언 영역
    V_WERKS			TB_SCH008.WERKS%TYPE;		--플랜트
    V_MACHINE       TB_SCH008.MACHINE%TYPE;     --생산호기

    -- 리스트(그리드)의 값을 할당하기 위한 변수선언 영역

    V_WRK_ORDR_NO	       TB_SCH016.WRK_ORDR_NO%TYPE;        --작업지시번호
    V_WRK_ORDR_SEQNO	   TB_SCH016.WRK_ORDR_SEQNO%TYPE;     --작업지시순번
    V_ORDER_NO	           TB_SCH016.ORDER_NO%TYPE;           --오더번호
    V_ORDR_QTY	           TB_SCH016.WRK_ORDR_QTY%TYPE;       --지시수량
    V_ORDR_GEN_DT	       TB_SCH016.ORDR_GEN_DT%TYPE;        --지시생성일자
    V_PRD_REQ_DATE	       TB_SCH016.PRD_REQ_DT%TYPE;         --생산요청일자
    V_WRK_ORDR_REMARK	   TB_SCH016.WRK_ORDR_RMK%TYPE;       --작업지시비고
    V_USE_YN	           TB_SCH016.USE_YN%TYPE;             --사용여부
	V_COMP_YN	           TB_SCH016.COMP_YN%TYPE;            --확정여부
    V_MRLDCK	           TB_SCH016.MRLDCK%TYPE;             --밀롤창고적치여부
    V_CUTTER	           TB_SCH016.CUTTER%TYPE;             --카터
    V_WRK_SEQNO            TB_SCH016.WRK_SEQNO%TYPE;          --작업순서  
    V_SLITER               varchar(2);                        --슬리터  

    V_MATNR	           	   TB_SCH016.MATNR%TYPE;              --자재코드

BEGIN
   OPEN P_RS_LIST FOR 
   SELECT NULL FROM DUAL WHERE ROWNUM = 0;

   V_DEBUG := 'N';
   V_RUN_SQL := 'Y';

   V_JSON := JSON_OBJECT_T.parse(P_JSON_STR);

   V_SESS_USER_ID       :=       V_JSON.get_string('SES_USER_ID');
   V_PLT_CD             :=       V_JSON.get_string('SES_PLNTKY');

   /* 조건값 할당 */
   V_WERKS          	:=       V_JSON.get_string('WERKS');	    --플랜트
   V_MACHINE            :=       V_JSON.get_string('MACHINE');      --생산호기
   V_RANGE_SQL 		    :=       V_JSON.get_string('RANGE_SQL');   	--자재코드, 생산요청일자, 지시생성일자

   V_MATNR       		:= 		 V_JSON.get_string('MATNR');		--자재코드
   V_SLITER             :=       V_JSON.get_string('SLITT');		--슬리터구분(M:밀롤 S:슬리터)

   IF P_TYPE = 'LIST' THEN /*상단 조회 리스트*/

 	V_SQL :=  ' SELECT /*+ INDEX(SCH016 TB_SCH016_IDX02) */
                       SCH016.WERKS       		 WERKS            		--플랜트코드
	                 , SCH016.ORDR_GEN_DT 		 ORDR_GEN_DT			--작업지시일자
	                 , SCH016.WRK_ORDR_NO 		 WRK_ORDR_NO			--작업지시번호
                     , SCH016.WRK_ORDR_SEQNO 	 WRK_ORDR_SEQNO			--지시순번
	                 , SCH016.WRK_ORDR_QTY  	 WRK_ORDR_QTY			--지시량
	                 , SCH016.ORDER_NO       	 ORDER_NO				--오더번호
                     , SCH016.WRK_SEQNO          WRK_SEQNO				--작업순서
                     , SCH016.PRE_ORDER_NO	     PRE_ORDER_NO           --이전오더번호
	                 , FN_GET_LOT_HIS(SCH016.WERKS,SCH016.PRE_ORDER_NO)    JRLOT_NO               --점보롤 LOT NO   
                     , SCH016.PRD_REQ_DT 		 PRD_REQ_DT				--생산요청일자
	                 , SCH016.MACHINE     		 MACHINE				--생산호기
	                 , SCH016.MATNR       		 MATNR					--자재코드
	                 , (SELECT MATNR_NM  FROM TB_MAS001 WHERE WERKS = SCH016.WERKS AND MATNR = SCH016.MATNR ) MATNR_NM				--자재명
                     , SCH016.PCODE              PCODE                  --지종
                     , SCH016.BS_WGT             BS_WGT                 --평량
                     , SCH016.MWIDTH             MWIDTH                 --M/R지폭
                     , LTRIM(SUBSTR(SCH016.MATNR, 10, 4), ''0'')    REWD_SPEC              --Rewinder규격
                     , CASE WHEN SCH016.SLITER = ''X'' THEN SCH016.MWIDTH_SLITER
                            ELSE                            NULL
                        END                      MWIDTH_SLITER          --슬리터 M/R지폭  
                     , SCH016.MROLLCNT           MROLLCNT               --M/R권치수
                     , SCH016.MRCNT              MRCNT                  --M/R폭수
                     , SCH016.MBRGEW             MBRGEW                 --M/R중량
                     , SCH016.TOT_WGT            TOT_WGT                --총중량
                     , SCH016.UNIT               UNIT                   --단위
                     , SCH016.JRCNT	             JRCNT                  --J/R개수                     
                     , (SELECT SCH008.ZZATT1 FROM TB_SCH008 SCH008 WHERE SCH016.ORDER_NO = SCH008.FRAUFNR)                      
                                                 ZZATT1	                --팔레트당연수
                     , (SELECT SCH008.ZZATT2 FROM TB_SCH008 SCH008 WHERE SCH016.ORDER_NO = SCH008.FRAUFNR)                      
                                                 ZZATT2	                --속당매수
                     , SCH016.ORDER_DIV
                     , SCH016.ORDER_DIV_NM
                     , NULL                      PACKTYPE	            --포장방법
                     , (SELECT SCH008.WLEN FROM TB_SCH008 SCH008 WHERE SCH016.ORDER_NO = SCH008.FRAUFNR)                      
                                                 WLEN	                --가로길이
                     , (SELECT SCH008.VLEN FROM TB_SCH008 SCH008 WHERE SCH016.ORDER_NO = SCH008.FRAUFNR)                      
                                                 VLEN	                --세로길이
                     , KUNNRT                      KUNNR	                --거래처
                     , TO_DATE(NVL(SCH016.PRD_STR_DTM, SCH016.PRD_END_DTM), ''YYYY-MM-DD HH24:MI:SS'')        PRD_STR_DTM            --생산시작시간
                     , SCH016.VBELN	             VBELN                  --주문문서번호
                     , SCH016.POSNR	             POSNR                  --오더Item번호
                     , SCH016.VDATU	             VDATU                  --납품요청일
                     , SCH016.REMARK	         PLN_ORDR_REMARK        --계획오더비고                     
	                 , SCH016.WRK_ORDR_RMK       WRK_ORDR_REMARK		--작업지시비고
                     , SCH016.SHEET	             SHEET                  --판지구분자
                     , SCH016.SLITER	         SLITER_SET             --슬리터구분    
                     , NVL(SCH016.MRLDCK, ''N'') MRLDCK                 --밀롤창고적치여부
                     , SCH016.CUTTER	         CUTTER                 --카터                     
	                 , NVL(SCH016.COMP_YN,''N'')   COMP_YN				--작업지시완료 (N:대기 I:작업중 Y:완료)
                     , NVL(FN_CMCDV(''COMP_YN'',SCH016.COMP_YN ),''대기'')
                                                 COMP_YN_NM			    --작업지시완료명 (N:대기 I:작업중 Y:완료)                     
	                 , SCH016.REGDATE            REGDATE				--등록일시
	                 , NVL((SELECT NMLAST FROM USRMA WHERE USRMA.USERID = SCH016.REGID),'''')	             REGNM					--등록자
	                 , SCH016.UPDDATE            UPDDATE				--수정일시
	                 , NVL((SELECT NMLAST FROM USRMA WHERE USRMA.USERID = SCH016.UPDID),'''')				 UPDNM					--수정자
                     , NVL(SCH016.USE_YN,''Y'')  USE_YN				    --사용여부
                FROM TB_SCH016   SCH016   -- 작업지시 밀롤,슬리터 
               WHERE 1=1 '
                 ;

        IF  V_WERKS IS NOT NULL OR TRIM(V_WERKS) != '' THEN
            V_SQL := V_SQL || ' AND SCH016.WERKS = ''' || V_WERKS || '''';				   --플랜트   
        END IF;

        IF  V_MACHINE IS NOT NULL OR TRIM(V_MACHINE) != '' THEN
            V_SQL := V_SQL || ' AND SCH016.MACHINE = ''' || V_MACHINE || '''';			   --생산호기
        END IF;

       	IF  V_MATNR IS NOT NULL OR TRIM(V_MATNR) != '' THEN
            V_SQL := V_SQL || ' AND SCH016.MATNR = ''' || V_MATNR || '''';			   	   --자재코드
        END IF;
        
		IF  V_SLITER IS NOT NULL OR TRIM(V_SLITER) != '' THEN
	       	IF  V_SLITER = 'S'    THEN  --슬리터
	            V_SQL := V_SQL || ' AND SCH016.SLITER = ''X'' ';			   	   --슬리터구분
	       	ELSE   					--밀롤
	            V_SQL := V_SQL || ' AND NVL(SCH016.SLITER, ''Y'') != ''X'' ';			   	   --슬리터구분
	        END IF;
	    END IF;
	       

        IF  V_RANGE_SQL IS NOT NULL OR TRIM(V_RANGE_SQL) != '' THEN
            V_SQL := V_SQL || V_RANGE_SQL ;			                       	               --자재코드 ,생산요청일자, 지시생성일자  
        END IF; 

 --       V_SQL := V_SQL || ' ORDER BY SCH016.WRK_ORDR_NO,SCH016.WRK_SEQNO, SCH016.WRK_ORDR_SEQNO';  

        IF (V_DEBUG = 'Y') THEN
            INSERT INTO PROC_LOG(SQL_STR) VALUES (V_SQL);
        END IF;

		OPEN P_RS_LIST FOR V_SQL;

    ELSIF P_TYPE = 'SAVE' THEN

        V_ARR_LIST        := V_JSON.get_array('list');

        FOR i IN 0..V_ARR_LIST.get_size-1 LOOP
            V_OBJ						:= TREAT (V_ARR_LIST.get (i) AS json_object_t);  
            V_OBJ						:= TREAT (V_OBJ.get ('map') AS json_object_t);   

            V_WRK_ORDR_NO	            := V_OBJ.get_string('WRK_ORDR_NO');        --작업지시번호
            V_WRK_ORDR_SEQNO	        := V_OBJ.get_string('WRK_ORDR_SEQNO');     --작업지시순번
            V_WERKS	                    := V_OBJ.get_string('WERKS');              --플랜트코드
            V_ORDER_NO	                := V_OBJ.get_string('ORDER_NO');           --오더번호
            V_ORDR_QTY	                := V_OBJ.get_string('WRK_ORDR_QTY');       --지시수량
            V_ORDR_GEN_DT	            := V_OBJ.get_string('ORDR_GEN_DT');        --지시생성일자
            V_PRD_REQ_DATE	            := V_OBJ.get_string('PRD_REQ_DT');         --생산요청일자
            V_WRK_ORDR_REMARK	        := V_OBJ.get_string('WRK_ORDR_REMARK');    --작업지시비고
            V_USE_YN	                := V_OBJ.get_string('USE_YN');             --사용여부
            V_COMP_YN	                := V_OBJ.get_string('COMP_YN');            --확정여부
            V_MRLDCK	                := V_OBJ.get_string('MRLDCK');             --밀롤창고적치여부
            V_CUTTER	                := V_OBJ.get_string('CUTTER');             --카터                     
            V_WRK_SEQNO	                := V_OBJ.get_string('WRK_SEQNO');          --작업순서

            IF V_OBJ.get_string('GRowState') = 'C'   THEN
                SELECT NVL(MAX(WRK_ORDR_SEQNO) + 1, 1)
                  INTO V_WRK_ORDR_SEQNO
                  FROM TB_SCH016
                 WHERE WRK_ORDR_NO = V_WRK_ORDR_NO ;

                INSERT INTO TB_SCH016 (
                      WRK_ORDR_NO	        --작업지시번호
                    , WRK_ORDR_SEQNO	    --작업지시순번
                    , WERKS	                --플랜트코드
                    , ORDER_NO	            --오더번호
                    , WRK_SEQNO	            --작업순서                    
                    , WRK_ORDR_QTY	        --지시수량
                    , ORDR_GEN_DT	        --지시생성일자
                    , PRD_REQ_DT	        --생산요청일자
                    , WRK_ORDR_RMK   	    --작업지시비고
                    , PRD_STR_DTM	        --생산시작일시
                    , PRD_END_DTM	        --생산완료일시
                    , PRFM_QTY	            --완료수량
                    , COMP_YN	            --완료여부
                    , USE_YN	            --사용여부
                    , PRE_ORDER_NO	        --점보롤 오더 번호
                    , ORDER_NUM	            --생산지시 No
                    , ORDER_SEQ	            --생산지시 seq
                    , ORDER_DIV	            --오더유형
                    , ORDER_DIV_NM	        --오더유형 텍스트
                    , MATNR	                --밀롤 자재 코드
                    , MACHINE	            --FROM 생산호기
                    , MACHINE_NM	        --FROM 생산 호기명
                    , TO_MACHINE            --TO 생산호기
                    , TO_MACHINE_NM	        --TO 생산 호기명
                    , JMATNR	            --점보롤 자재 코드
                    , PCODE	                --지종코드
                    , BS_WGT	            --평량
                    , MWIDTH	            --M/R 지폭
                    , MWIDTH_INPUT	        --M/R 지폭_INPUT
                    , MWIDTH_SLITER	        --M/R 지폭_SLITER
                    , MROLLCNT	            --M/R 권치수
                    , MRCNT	                --M/R 폭수
                    , MBRGEW	            --M/R 중량
                    , UNIT	                --단위
                    , JRCNT	                --J/R 개수
                    , OVBELN	            --판매 문서
                    , OPOSNR	            --판매 문서 품목 번호
                    , OAUART_DIV	        --판매 문서 오더 유형
                    , OAUART_NM	            --판매 문서 오더 유형 텍스트
                    , VBELN	                --판매 문서
                    , POSNR	                --판매 문서 품목 번호
                    , VDATU	                --납품 요청일자
                    , SAUART_DIV	        --판매 문서 오더 유형
                    , SAUART_NM	            --판매 문서 오더 유형 텍스트
                    , REMARK	            --비고
                    , SHEET	                --판지 구분자
                    , SLITER_SET	        --슬리터 구분
                    , MRLDCK	            --밀롤 창고 적치 여부
                    , CUTTER	            --카터
                    , BOM_NO                --BOM Num
                    , ATN_BOM_NO            --대체Bom
                    , PRT_MATNR_QTY         --모품목기준수량
                    , PRT_MATNR_UNIT        --모품목기준수량 단위
                    , DLFL	                --오더 삭제 지시자
                    , REGDATE	            --등록일시
                    , REGID	                --등록자ID
                    , UPDDATE	            --수정일자
                    , UPDID	                --수정자ID
                ) 
                SELECT SCH016.WRK_ORDR_NO	        --작업지시번호
                     , V_WRK_ORDR_SEQNO	            --작업지시순번
                     , V_WERKS	                    --플랜트코드
                     , V_ORDER_NO	                --오더번호
                     , V_WRK_SEQNO    	            --작업순서                     
                     , V_ORDR_QTY	                --지시수량
                     , TO_CHAR(SYSDATE, 'YYYYMMDD')	--지시생성일자
                     , V_PRD_REQ_DATE	            --생산요청일자
                     , V_WRK_ORDR_REMARK	        --작업지시비고
                     , NULL	                        --생산시작일시
                     , NULL	                        --생산완료일시
                     , 0	                        --완료수량
                     , 'N'	                        --완료여부
                     , 'Y'	                        --사용여부
                     , SCH016.PRE_ORDER_NO	        --점보롤 오더 번호
                     , SCH016.ORDER_NUM	            --생산지시 No
                     , SCH016.ORDER_SEQ	            --생산지시 seq
                     , SCH016.ORDER_DIV	            --오더유형
                     , SCH016.ORDER_DIV_NM	        --오더유형 텍스트
                     , SCH016.MATNR	                --밀롤 자재 코드
                     , SCH016.MACHINE	            --FROM 생산호기
                     , SCH016.MACHINE_NM	        --FROM 생산 호기명
                     , SCH016.TO_MACHINE	        --TO 생산호기
                     , SCH016.TO_MACHINE_NM	        --TO 생산 호기명
                     , SCH016.MATNR	                --점보롤 자재 코드
                     , SCH016.PCODE	                --지종코드
                     , SCH016.BS_WGT	            --평량
                     , SCH016.MWIDTH	            --M/R 지폭
                     , SCH016.MWIDTH_INPUT	        --M/R 지폭_INPUT
                     , SCH016.MWIDTH_SLITER	        --M/R 지폭_SLITER
                     , SCH016.MROLLCNT	            --M/R 권치수
                     , SCH016.MRCNT	                --M/R 폭수
                     , SCH016.MBRGEW	            --M/R 중량
                     , SCH016.UNIT	                --단위
                     , SCH016.JRCNT	                --J/R 개수
                     , SCH016.OVBELN	            --판매 문서
                     , SCH016.OPOSNR	            --판매 문서 품목 번호
                     , SCH016.OAUART_DIV            --판매 문서 오더 유형
                     , SCH016.OAUART_NM	            --판매 문서 오더 유형 텍스트
                     , SCH016.VBELN	                --판매 문서
                     , SCH016.POSNR	                --판매 문서 품목 번호
                     , SCH016.VDATU	                --납품 요청일자
                     , SCH016.SAUART_DIV            --판매 문서 오더 유형
                     , SCH016.SAUART_NM	            --판매 문서 오더 유형 텍스트
                     , SCH016.REMARK	            --비고
                     , SCH016.SHEET	                --판지 구분자
                     , SCH016.SLITER_SET	        --슬리터 구분
                     , V_MRLDCK	                    --밀롤 창고 적치 여부
                     , V_CUTTER	                    --카터
                     , SCH016.BOM_NO	            --BOM Num
                     , SCH016.ATN_BOM_NO            --대체Bom
                     , SCH016.PRT_MATNR_QTY         --모품목기준수량
                     , SCH016.PRT_MATNR_UNIT	    --모품목기준수량 단위
                     , SCH016.DLFL	                --오더 삭제 지시자
                     , SYSDATE	                    --등록일시
                     , V_SESS_USER_ID	            --등록자ID
                     , NULL	                        --수정일자
                     , NULL	                        --수정자ID
                  FROM TB_SCH016 SCH016
                 WHERE SCH016.WRK_ORDR_NO = V_WRK_ORDR_NO	                      --작업지시번호
                   AND ROWNUM = 1
                 ;

                 /* DELETE FROM TB_SCH020    --작업지시 BOM
                  WHERE WERKS          = V_WERKS            --플랜트코드
                    AND WRK_ORDR_NO    = V_WRK_ORDR_NO      --작업지시번호
                    AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO   --작업지시번호 순번
                   ;

                  INSERT INTO TB_SCH020    --작업지시 BOM
                  (
                                 WERKS	            --플랜트코드
                                ,WRK_ORDR_NO	    --작업지시번호
                                ,WRK_ORDR_SEQNO	    --작업지시번호 순번
                                ,MATNR	            --자품목자재
                                ,ORDER_NO	        --오더번호
                                ,ORDER_ITM_NO	    --오더Item번호
                                ,ORDER_BOM_QTY	    --오더BOM 수량
                                ,UNIT	            --수량단위
                                ,STOR_LOC_CD	    --저장위치
                                ,LOT_NO	            --LOT NO
                                ,CHGFL	            --대체자재 여부
                                ,EMPLY_NO	        --대체자재 등록자
                                ,DLFL	            --삭제여부
                                ,DOC_NO	            --MES문서번호
                                ,DOC_SEQ	        --MES 문서순번
                                ,REGDATE	        --등록일시
                                ,REGID	            --등록자ID                 
                  ) 
                  SELECT
                                 SCH016.WERKS	        --플랜트코드
                                ,SCH016.WRK_ORDR_NO	    --작업지시번호
                                ,SCH016.WRK_ORDR_SEQNO  --작업지시번호 순번
                                ,SCH001.MATNR	        --자품목자재
                                ,SCH001.AUFNR	        --오더번호
                                ,SCH001.POSNR	        --오더Item번호
                                ,CASE WHEN SCH016.TOT_WGT = 0      THEN  SCH016.WRK_ORDR_QTY
                                      WHEN SCH016.TOT_WGT IS NULL  THEN  SCH016.WRK_ORDR_QTY
                                      ELSE ((SCH016.WRK_ORDR_QTY/SCH016.TOT_WGT) * 100)/100 *  SCH001.BDMNG
                                  END                   --오더BOM 수량  
                                ,SCH001.MEINS	        --수량단위
                                ,SCH001.LGORT	        --저장위치
                                ,NULL	                --LOT NO
                                ,NULL	                --대체자재 여부
                                ,NULL	                --대체자재 등록자
                                ,SCH001.XLOEK	        --삭제여부
                                ,NULL	                --MES문서번호
                                ,NULL    	            --MES 문서순번
                                ,SYSDATE	            --등록일시
                                ,V_SESS_USER_ID	        --등록자ID                                  
                  FROM TB_SCH016  SCH016   --작업지시 밀롤,슬리터
                     , TB_SCH001  SCH001   --생산오더 BOM - 릴리즈된 생산오더
                  WHERE SCH016.WRK_ORDR_NO	   = V_WRK_ORDR_NO            --작업지시번호
                    AND SCH016.WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO	      --작업지시순번 
                    AND SCH016.ORDER_NO       = SCH001.AUFNR              --오더번호
                     ;  
                     */

            ELSIF V_OBJ.get_string('GRowState') = 'U'  THEN

                -- 완료여부 : N:대기 I:작업중 Y:완료
                SELECT COMP_YN
                  INTO V_COMP_YN
                  FROM TB_SCH016
                 WHERE WRK_ORDR_NO     = V_WRK_ORDR_NO 
                   AND WRK_ORDR_SEQNO  = V_WRK_ORDR_SEQNO   ; 

                IF NVL(V_COMP_YN,'N') = 'N' THEN   -- N:대기 경우일때만 변경 실행
                    UPDATE TB_SCH016 
                    SET   WRK_ORDR_QTY      = V_ORDR_QTY                    --지시량
                         ,WRK_SEQNO         = V_WRK_SEQNO    	            --작업순서                     
                         ,MRLDCK	        = V_MRLDCK                      --밀롤창고적치여부
                         ,CUTTER	        = V_CUTTER                      --카터                     
                         ,WRK_ORDR_RMK      = V_WRK_ORDR_REMARK             --작업지시비고
                         ,UPDDATE		    = SYSDATE			            --수정일자
                         ,UPDID			    = V_SESS_USER_ID	            --수정자   
                         ,USE_YN            = V_USE_YN                      --사용여부   (Y:사용 N:미사용)
                    WHERE WRK_ORDR_NO		= V_WRK_ORDR_NO    AND			--작업지시번호
                          WRK_ORDR_SEQNO    = V_WRK_ORDR_SEQNO   ;          --작업지시순번        

                 /* DELETE FROM TB_SCH020    --작업지시 BOM
                  WHERE WERKS          = V_WERKS            --플랜트코드
                    AND WRK_ORDR_NO    = V_WRK_ORDR_NO      --작업지시번호
                    AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO   --작업지시번호 순번
                   ;

                  INSERT INTO TB_SCH020    --작업지시 BOM
                  (
                                 WERKS	            --플랜트코드
                                ,WRK_ORDR_NO	    --작업지시번호
                                ,WRK_ORDR_SEQNO	    --작업지시번호 순번
                                ,MATNR	            --자품목자재
                                ,ORDER_NO	        --오더번호
                                ,ORDER_ITM_NO	    --오더Item번호
                                ,ORDER_BOM_QTY	    --오더BOM 수량
                                ,UNIT	            --수량단위
                                ,STOR_LOC_CD	    --저장위치
                                ,LOT_NO	            --LOT NO
                                ,CHGFL	            --대체자재 여부
                                ,EMPLY_NO	        --대체자재 등록자
                                ,DLFL	            --삭제여부
                                ,DOC_NO	            --MES문서번호
                                ,DOC_SEQ	        --MES 문서순번
                                ,REGDATE	        --등록일시
                                ,REGID	            --등록자ID                 
                  ) 
                  SELECT
                                 SCH016.WERKS	        --플랜트코드
                                ,SCH016.WRK_ORDR_NO	    --작업지시번호
                                ,SCH016.WRK_ORDR_SEQNO  --작업지시번호 순번
                                ,SCH001.MATNR	        --자품목자재
                                ,SCH001.AUFNR	        --오더번호
                                ,SCH001.POSNR	        --오더Item번호
                                ,CASE WHEN SCH016.TOT_WGT = 0      THEN  SCH016.WRK_ORDR_QTY
                                      WHEN SCH016.TOT_WGT IS NULL  THEN  SCH016.WRK_ORDR_QTY
                                      ELSE ((SCH016.WRK_ORDR_QTY/SCH016.TOT_WGT) * 100)/100 *  SCH001.BDMNG
                                  END                   --오더BOM 수량  
                                ,SCH001.MEINS	        --수량단위
                                ,SCH001.LGORT	        --저장위치
                                ,NULL	                --LOT NO
                                ,NULL	                --대체자재 여부
                                ,NULL	                --대체자재 등록자
                                ,SCH001.XLOEK	        --삭제여부
                                ,NULL	                --MES문서번호
                                ,NULL    	            --MES 문서순번
                                ,SYSDATE	            --등록일시
                                ,V_SESS_USER_ID	        --등록자ID                                  
                  FROM TB_SCH016  SCH016   --작업지시 밀롤,슬리터
                     , TB_SCH001  SCH001   --생산오더 BOM - 릴리즈된 생산오더
                  WHERE SCH016.WRK_ORDR_NO	   = V_WRK_ORDR_NO            --작업지시번호
                    AND SCH016.WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO	      --작업지시순번 
                    AND SCH016.ORDER_NO       = SCH001.AUFNR              --오더번호
                     ;                            
                     */     
                END IF;

            ELSIF V_OBJ.get_string('GRowState') = 'D'  THEN
               RETURN ;   
            END IF;
        END LOOP;

    END IF;

    P_SUCCESS := 'Y';

    EXCEPTION
    WHEN E_EXCEPTION_USER THEN

        -- 에러 내역 SET
	    P_SUCCESS           := 'N';
        E_SQL_ERR_CD        := SQLCODE;
        E_SQL_ERR_MSG       := SUBSTRB(SQLERRM,1,300);

        ROLLBACK;
        SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);

    WHEN OTHERS THEN
	    P_SUCCESS           := 'N';
        E_SQL_ERR_CD        := SQLCODE;
        E_SQL_ERR_MSG       := 'EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';

        ROLLBACK;
        RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);
END;

/
