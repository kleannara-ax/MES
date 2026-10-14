--------------------------------------------------------
--  DDL for Procedure SP_WRK04_S01
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_WRK04_S01" (
	P_TYPE           IN    varchar2, -- LIST, SAVE
	P_JSON_STR       IN    CLOB,
	P_SUCCESS       OUT    varchar2,
	P_RS_LIST       OUT    SYS_REFCURSOR,
    RS_DISPO_RFCFN     OUT VARCHAR2 ,                   --폐품 RFCFN값    
    RS_DISPO_I_IF_ID   OUT VARCHAR2,
    RS_DISPO_I_IF_KEY  OUT VARCHAR2,
    RS_DISPO_SQL       OUT VARCHAR2
)
/*==============================================================================
 * PROGRAM ID    : SP_WRK04_S01{호출 프로그램 ID 기술}
 * PROGRAM NAME  : 일괄폐품등록	 {호출 프로그램 명 기술}
 * VERSION       : 1.0.0{최종 버전 기술}
 * DESCRIPTION   : 자재/완제품 불출요청 를 관리한다.{프로그램에 대한 상세한 내용 기술}
 *                 
 * AUTHOR NAME   : 박충식{최초 작성자 명 기술}
 * CREATE DATE   : 2022/04/27 {최초 작성일자 기술}
 * SYSTEM NAME   : MES
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}  <생략가능>
 * SUB PROCEDURE : {아휘 프로시저 명칭 기술}      <생략가능>
 * SUB PACKAGES  : {하위 패키지 기술}            <생략가능>
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술} <생략가능>
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/04/27    1.0.0   박충식         Initial Version 
 *==============================================================================
 *  관련 테이블
 *        - [TB_SCH013] : (CRUD) 작업지시 패드 정보
 * *      
 *=============================================================================*/

AS

    V_PRG_NM          VARCHAR2(100)  := 'SP_WRK04_S01';     -- PROCEDURE NAME


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

   -- 2022-05-10(화요일)-안상현, 하위 쿼리 조건 추가
    V_OUT_SQL      	 CLOB;
    V_DOC_SQL   	 varchar2(1000);


    V_DEBUG          varchar2(1);

    -- 세션값 처리용 변수선언 영역
    V_PLT_CD         varchar2(2);
    V_SESS_USER_ID   varchar2(20);

    -- 조건절 처리용 변수선언 영역
    V_WERKS			TB_SCH008.WERKS%TYPE;		--플랜트
    V_SDATE         VARCHAR(8) ;                --투입시작일자 
    V_EDATE         VARCHAR(8) ;                --투입종료일자 

    V_MACHINE       TB_SCH008.MACHINE%TYPE;     --생산호기 

    -- 리스트(그리드)의 값을 할당하기 위한 변수선언 영역
    V_MACH_CD        TB_SCH013.ORDER_NO%TYPE;              --설비코드
    V_IND_BCD        TB_WRK002.IND_BCD%TYPE;              --업체/개별 바코드            
    V_SEQNO          TB_SCH013.ORDER_NO%TYPE;              --순번          
    V_MATNR	         TB_SCH020.MATNR%TYPE;                 --자재코드
    V_DISPO_CD	     TB_WRK004.DISPO_CD%TYPE;              --폐품코드
    V_DISPO_NM	     varchar(100);                         --폐품명
    V_RMK	         TB_WRK004.RMK%TYPE;                   --비고

    V_ORDER_NO	           TB_SCH013.ORDER_NO%TYPE;           --오더번호
    V_ORDR_QTY	           TB_SCH013.WRK_ORDR_QTY%TYPE;       --지시수량
    V_WRK_SEQNO            TB_SCH013.WRK_SEQNO%TYPE;          --작업순서    
    V_ORDR_GEN_DT	       TB_SCH013.ORDR_GEN_DT%TYPE;        --지시생성일자
    V_PRD_REQ_DATE	       TB_SCH013.PRD_REQ_DT%TYPE;         --생산요청일자
    V_WRK_ORDR_REMARK	   TB_SCH013.WRK_ORDR_RMK%TYPE;       --작업지시비고
    V_USE_YN	           TB_SCH013.USE_YN%TYPE;             --사용여부
	V_COMP_YN	           TB_SCH013.COMP_YN%TYPE;            --확정여부 

--    V_MATNR	               TB_SCH020.MATNR%TYPE;                      --하위자재코드
    V_STOR_LOC_CD          TB_SCH020.STOR_LOC_CD%TYPE;                --저장위치
    V_STCK_QTY             TB_INV001.STCK_QTY%TYPE;                   --재고수량
    V_ORDER_BOM_QTY        TB_SCH020.ORDER_BOM_QTY%TYPE;              --소요량
    V_UNIT                 TB_SCH020.UNIT%TYPE;                       --기본단위
    V_REQ_QTY              TB_INV002.QTY%TYPE;                        --요청수량
    V_DOC_NO               TB_IFRWM002.DOC_NO%TYPE;                   --MES 문서번호
    V_DOC_NO_SUM           VARCHAR2(500);                   --MES 문서번호
    V_DOC_SEQNO            TB_SCH020.DOC_SEQ%TYPE;                    --MES 문서순번
    V_DLFL                 TB_INV002.DLFL%TYPE;                       --삭제여부
    V_QTY                  TB_INV002.QTY%TYPE;                        --불출요청량

    V_IF_STA               TB_INV002.IF_STA%TYPE;                     --WMS 결과값

    V_IF_MES_ID            TB_IFRWM002.IF_MES_ID%TYPE;                --MES Interface ID
    V_SEQ                  NUMBER(5)    ;                             --MES 문서순번(번호)

    V_IND_BCD_ORG	       TB_WRK004.IND_BCD%TYPE;
    V_LOT_NO_ORG	       TB_WRK004.LOT_NO%TYPE;
    V_MATNR_ORG	           TB_WRK004.MATNR%TYPE;
    V_LOT_NO	           TB_WRK004.LOT_NO%TYPE;
    --V_UNIT	               TB_WRK004.UNIT%TYPE;
    --V_STCK_QTY	           TB_WRK004.DISPO_QTY%TYPE;
    V_INP_DT               TB_INV003.INP_DT%TYPE;
    --V_STOR_LOC_CD          TB_INV001.STOR_LOC_CD%TYPE; 

    V_VBELN                TB_WRK002.VBELN%TYPE; 
    V_POSNR                TB_WRK002.POSNR%TYPE; 
    V_SAP_WRK_CD           VARCHAR2(20);
    V_DISPO_DIV            VARCHAR2(20);
BEGIN
   OPEN P_RS_LIST FOR 
   SELECT NULL FROM DUAL WHERE ROWNUM = 0;

   V_DEBUG := 'Y';
   V_RUN_SQL := 'Y';

   V_DOC_NO     := '' ;           
   V_DOC_SEQNO  := 0 ;
   V_DOC_NO_SUM := '' ; 
   
   V_JSON := JSON_OBJECT_T.parse(P_JSON_STR);

   V_SESS_USER_ID       :=       V_JSON.get_string('SES_USER_ID');
   V_PLT_CD             :=       V_JSON.get_string('SES_PLNTKY');

   /* 조건값 할당 */
   V_WERKS          	:=       V_JSON.get_string('WERKS');	    --플랜트
   V_SDATE              :=       V_JSON.get_string('SDATE');        --투입시작일자 
   V_EDATE              :=       V_JSON.get_string('EDATE');        --투입종료일자 

   V_OUT_SQL			:=		 V_JSON.get_string('OUT_SQL');
   V_DISPO_CD	        :=       V_JSON.get_string('DISPO_CD');     --폐품코드
   V_DISPO_NM	        :=       V_JSON.get_string('DISPO_NM');     --폐품명
   V_DISPO_DIV	        :=       V_JSON.get_string('DISPO_DIV');    --폐품유형

   V_RMK	            :=       V_JSON.get_string('RMK');                  --비고
  


   IF P_TYPE = 'LIST' THEN /*상단 조회 리스트*/

 	V_SQL :=  '
                    SELECT DISTINCT
                     WRK002.PRFM_DT                 PRFM_DT        --실적일자
                    ,WRK002.PRD_DT                  PRD_DT         --생산일자
                    ,INV010.INP_DT                  INP_DT         --투입일자
                    ,INV010.LOT_NO_M                           CLOT_NO         --재단LOT 번호
                    ,SCH018.PACKTYPE                PACKTYPE        --포장타입
                    ,SCH018.PCODE                   PCODE           --지종
                    ,MAS001.PCODE_NM                PCODE_NM        --지종명
                    ,SCH018.BS_WGT                  BS_WGT          --평량
                    ,MAS001.MATNR_SPEC                           SPEC            --규격
                    ,INV003.STCK_QTY                        GCNT            --가용연수
                    ,INV003.STCK_QTY                           G_WGT           --가용중량
                    ,SCH018.OVBELN                  OVBELN          --판매오더
                    ,INV010.MATNR_M                   CMATNR           --재단자재코드
                    ,WRK002.PCNT                    PRFM_PCNT       --실적연수
                    ,SCH018.WRK_ORDR_QTY             PLN_PLT_PER_CNT --계획연수
                    ,WRK002.WGT                     WGT             --실적중량
                    ,SCH018.TOT_WGT                 PLN_WGT         --계획중량
                    ,SCH018.MACHINE_NM              MACHINE_NM      --생산호기명
                    ,SCH018.TO_MACHINE_NM           TO_MACHINE_NM   --이동호기명
                    ,(
                        SELECT SUM(DISPO_QTY)  --SUM(WGT)
                        FROM TB_WRK004  WRK004    --폐품 실적(PS, HL(합지기))
                        WHERE WRK002.WRK_ORDR_NO    = WRK004.WRK_ORDR_NO
                          AND WRK002.WRK_ORDR_SEQNO = WRK004.WRK_ORDR_SEQNO
                     )                             DISPO_WGT       --폐품중량
                    ,INV010.MATNR                   IMATNR           --포장자재번호
                    ,SCH018.ORDER_NO                ORDER_NO         --오더번호
                    ,WRK002.RMK                     RMK              --비고
                    ,NULL                           JLOT_NO         --JR LOT번호 
                    ,(
                        SELECT MAX(SCH016.LOT_BUF)
                          FROM TB_SCH016  SCH016   --작업지시 밀롤,슬리터
                             , TB_SCH017  SCH017   --작업지시 재단
                           --  , TB_WRK002  WRK0021   --실적테이블(PS)
                         WHERE SCH018.PRE_ORDER_NO   = SCH017.ORDER_NO
                           AND SCH017.PRE_ORDER_NO   = SCH016.ORDER_NO
                           --AND SCH016.WRK_ORDR_NO    = WRK0021.WRK_ORDR_NO
                           --AND SCH016.WRK_ORDR_SEQNO = WRK0021.WRK_ORDR_SEQNO    
                     )                              MLOT_NO         --MR LOT번호 
                    ,FN_CHG_UNIT 
                    (
                      INV010.MATNR
                    , INV010.WERKS
                    , INV010.UNIT
                    , ''R''
                    , INV010.USE_QTY
                    )                               USE_CNT         --사용연수
                    ,INV010.WGT                     USE_WGT         --사용중량
                    ,INV010.WERKS                   WERKS           --플랜트 코드
                    ,INV010.MACH_CD                 MACH_CD         --설비코드
                    ,INV003.IND_BCD                 IND_BCD         --업체/개별 바코드
                    ,INV003.SEQNO                   SEQNO           --순번  
                  FROM TB_WRK002     WRK002   --실적테이블(PS)
                    ,  TB_INV010     INV010   --자재투입 
                     , TB_SCH018     SCH018   --작업지시 포장
                     , TB_MAS001     MAS001   --플랜트별 제품/자재 마스터
                     , TB_INV003     INV003
                 WHERE 
                       INV010.WERKS             =  WRK002.WERKS(+)
                   AND INV010.IND_BCD           =  WRK002.IND_BCD(+)
                   AND WRK002.WRK_ORDR_NO       =  SCH018.WRK_ORDR_NO
                   AND WRK002.WRK_ORDR_SEQNO    =  SCH018.WRK_ORDR_SEQNO                   
                   AND INV010.MATNR_M           =  MAS001.MATNR
                   AND INV010.WERKS             =  MAS001.WERKS
                   AND INV010.WERKS             =  INV003.WERKS
                   AND INV010.IND_BCD_M         =  INV003.IND_BCD
                   AND NVL(WRK002.CNL_YN,''N'')  = ''N''
                   AND NVL(INV010.CNL_YN,''N'')  = ''N''
                   AND INV003.STCK_QTY  > 0
                   AND MAS001.MATNR_DIV IN (''FERT'', ''HALB'', ''HAWA'')
              '
                 ;

        IF  V_WERKS IS NOT NULL OR TRIM(V_WERKS) != '' THEN
            V_SQL := V_SQL || ' AND WRK002.WERKS = ''' || V_WERKS || '''';				   --플랜트   
        END IF;

        V_SQL := V_SQL || ' AND WRK002.PRFM_DT BETWEEN ''' || V_SDATE || '''  AND ''' || V_EDATE || '''';			   --투입일자

        V_SQL := V_SQL || ' ORDER BY INV010.MACH_CD,WRK002.PRFM_DT , INV003.IND_BCD ';			   --투입일자

        IF (V_DEBUG = 'Y') THEN
            INSERT INTO PROC_LOG(SQL_STR) VALUES (V_SQL);
        END IF;

		OPEN P_RS_LIST FOR V_SQL;

    ELSIF P_TYPE = 'SUB_LIST' THEN  /* 하부 상세 조회 리스트*/
 	      V_SQL :=  ' SELECT INV003.IND_BCD                     IND_BCD          --업체/개별 바코드
                           , INV003.LOT_NO                      LOT_NO           --LOT_NO
                           , INV003.IN_QTY                      IN_CNT           --투입량
                           , INV003.USE_QTY                     USE_CNT          --사용량
                           , INV003.IN_QTY - INV003.USE_QTY     GCNT         --가용량 
                        FROM TB_INV003    INV003    --자재투입
                     '
                    ;

        IF  V_OUT_SQL IS NOT NULL OR TRIM(V_OUT_SQL) != '' THEN
            V_SQL := V_SQL || '  ' ;
            V_SQL := V_SQL || V_OUT_SQL ;	
        END IF;
        V_SQL := V_SQL || ' AND (INV003.IN_QTY - INV003.USE_QTY)> 0 ' ;
        
        V_SQL := V_SQL || ' ORDER BY INV003.IND_BCD   ';  

        IF (V_DEBUG = 'Y') THEN
            INSERT INTO PROC_LOG(SQL_STR) VALUES (V_SQL);
        END IF;

		OPEN P_RS_LIST FOR V_SQL;

    ELSIF P_TYPE = 'SAVE' THEN

        V_ARR_LIST        := V_JSON.get_array('list');
        V_DOC_SQL := '';
        V_SEQ     := 0 ;

        V_IF_MES_ID := 'MES_IF_134' ;
        --SELECT FN_GET_MDOCNO('M', 'IF134')  INTO V_DOC_NO  FROM DUAL ;   --MES 문서번호

        FOR i IN 0..V_ARR_LIST.get_size-1 LOOP
            V_OBJ						:= TREAT (V_ARR_LIST.get (i) AS json_object_t);  
            V_OBJ						:= TREAT (V_OBJ.get ('map') AS json_object_t);   


            V_WERKS	         := V_OBJ.get_string('WERKS');                --플랜트
            V_MATNR	         := V_OBJ.get_string('CMATNR');                --자재코드
            V_MACH_CD        := V_OBJ.get_string('MACH_CD');              --설비코드
            V_IND_BCD        := V_OBJ.get_string('IND_BCD');              --업체/개별 바코드            
            V_SEQNO          := TO_NUMBER(V_OBJ.get_string('SEQNO'));                --순번          
            --V_DISPO_CD	     := V_OBJ.get_string('DISPO_CD');             --폐품코드
            --V_DISPO_DIV	     := V_OBJ.get_string('DISPO_DIV');             --폐품유형명
            --V_RMK	         := V_OBJ.get_string('RMK');                  --비고

            --IF  V_REQ_QTY  > 0  THEN

             V_DOC_SEQNO := '0' ;
             V_DLFL    := 'C' ;                 
             V_SEQ     := V_SEQ +1 ;

             SELECT
                      V010.IND_BCD	        --개별바코드
                     ,V010.LOT_NO	        --LOT_NO
                     ,V010.MATNR	            --자재코드
                     ,V003.LOT_NO	        --투입자재의LOTNO
                     ,V003.UNIT	            --실적단위
                     ,V003.STCK_QTY	        --폐품수량
                     ,V001.ORDER_NO         --
                     --,V003.STCK_QTY	        --폐품수량
                     ,V003.INP_DT         
                     ,V001.STOR_LOC_CD
                     ,V001.VBELN 
                     ,V001.POSNR 
                INTO  V_IND_BCD_ORG	  
                     ,V_LOT_NO_ORG	  
                     ,V_MATNR_ORG	  
                     ,V_LOT_NO	      
                     ,V_UNIT	          
                     ,V_STCK_QTY	
                     ,V_ORDER_NO
                     ,V_INP_DT  
                     ,V_STOR_LOC_CD
                     ,V_VBELN 
                     ,V_POSNR 
                FROM  TB_INV003  V003
                   ,  TB_INV010  V010
                   ,  TB_INV001  V001
                WHERE V003.WERKS      = V010.WERKS 
                  AND V003.IND_BCD    = V010.IND_BCD_M 
                  AND V010.WERKS      = V001.WERKS 
                  AND V010.IND_BCD    = V001.IND_BCD
                  AND V003.WERKS      = V_WERKS
                  AND V003.MACH_CD    = V_MACH_CD
                  AND V003.MATNR      = V_MATNR
                  AND V003.IND_BCD    = V_IND_BCD
                  AND V003.SEQNO      = V_SEQNO
                  AND V001.ORDER_NO IS NOT NULL
                  AND NVL(V010.CNL_YN,'N')    = 'N'
                  ;

                  SELECT SAP_WRK_CD  INTO V_SAP_WRK_CD
                    FROM TB_MAS012
                   WHERE MACH_CD = V_MACH_CD;


             DELETE FROM TB_WRK004
             WHERE WERKS        = V_WERKS
               AND MACH_CD      = V_MACH_CD
               AND IND_BCD      = V_IND_BCD_ORG
               AND RMK          = '폐품일괄등록'
               AND MATNR	    = V_MATNR_ORG
               AND MMATNR	    = V_MATNR
               AND IND_BCD_M	= V_IND_BCD      
             ;

             V_DOC_NO     := FN_GET_MDOCNO('M','IF134');
             V_DOC_SEQNO  := V_DOC_SEQNO + 1;
             V_DOC_NO_SUM := V_DOC_NO_SUM||V_DOC_NO||',';

             INSERT INTO TB_WRK004	    --폐품 실적
                (
                     WERKS	            --플랜트
                    ,MACH_CD	        --작업장코드(설비코드)
                    ,IND_BCD	        --개별바코드
                    ,LOT_NO	            --LOT_NO
                    ,MATNR	            --자재코드
                    ,DISPO_CD	        --폐품코드
                    ,WRK_ORDR_NO	    --작업지시번호
                    ,WRK_ORDR_SEQNO	    --작업지시 순번
                    ,MMATNR	            --투입자재의 자재코드
                    ,IND_BCD_M	        --투입자재의 개별바코드
                    ,LOT_NO_M	        --투입자재의LOTNO
                    ,UNIT	            --실적단위
                    ,ROLLCNT	        --폐품권치수
                    ,DISPO_QTY	        --폐품수량
                    ,MACHINE	        --생산호기
                    ,WGT	            --중량
                    ,RSPEED	            --선속
                    ,PRD_STR_DATE	    --생산시작 일시
                    ,PRD_END_DATE	    --생산 종료 일시
                    ,TM	                --생산시간(분)
                    ,PRFM_DT	        --실적일자
                    ,WRK_CLASS	        --작업반
                    ,WRK_SHIFT	        --작업조
                    ,RUN_STA	        --운전상태
                    ,DOC_NO	            --MES문서번호
                    ,DOC_SEQNO	        --MES 문서번호 순번
                    ,SDOC_NO	        --SAP 확정문서번호
                    ,SDOC_SEQNO	        --SAP 확정문서번호 순번
                    ,RMK	            --비고
                    ,REGDATE	        --등록일시
                    ,REGID	            --등록자
                    ,UPDDATE	        --수정일시
                    ,UPDID	            --수정자
                    ,CNL_YN	            --취소여부
                    ,CNL_RMK	        --취소사유
                    ,IND_BCD_C	        --재단 개별바코드
                    ,ORDER_NO	        --오더번호
                    ,GRD_YN	            --등급변경여부
                ) VALUES (
                     V_WERKS	            --플랜트
                    ,V_MACH_CD	            --작업장코드(설비코드)
                    ,V_IND_BCD_ORG	        --개별바코드
                    ,V_LOT_NO_ORG	        --LOT_NO
                    ,V_MATNR_ORG	        --자재코드
                    ,V_DISPO_CD	            --폐품코드
                    ,NULL	                --작업지시번호
                    ,NULL	                --작업지시 순번
                    ,V_MATNR	            --투입자재의 자재코드
                    ,V_IND_BCD	            --투입자재의 개별바코드
                    ,V_LOT_NO	            --투입자재의LOTNO
                    ,V_UNIT	                --실적단위
                    ,NULL	                --폐품권치수
                    ,V_STCK_QTY	            --폐품수량
                    ,NULL	                --생산호기
                    ,NULL	                --중량
                    ,NULL	                --선속
                    ,NULL	                --생산시작 일시
                    ,NULL	                --생산 종료 일시
                    ,NULL	                --생산시간(분)
                    ,TO_CHAR(SYSDATE, 'YYYYMMDD')	        --실적일자
                    ,NULL	                --작업반
                    ,NULL	                --작업조
                    ,'02'	                --운전상태
                    ,V_DOC_NO	            --MES 문서번호
                    ,V_DOC_SEQNO	        --MES 문서번호 순번
                    ,NULL	                --SAP 확정문서번호
                    ,NULL	                --SAP 확정문서번호 순번
                    ,'폐품일괄등록'	        --비고
                    ,SYSDATE	            --등록일시
                    ,V_SESS_USER_ID         --등록자
                    ,NULL	                --수정일시
                    ,NULL	                --수정자
                    ,'N'	                --취소여부
                    ,V_RMK	                --취소사유
                    ,NULL	                --재단 개별바코드
                    ,NULL	                --오더번호
                    ,NULL	                --등급변경여부
                );

           IF V_DISPO_DIV = 'P'  THEN
               INSERT INTO   TB_IFS012 
               (
                         AUFNR	            --오더번호
                        ,LOTNO	            --LOT 번호
                        ,BUDAT	            --투입일자(전기일)
                        ,MATNR	            --자재번호(투입자재)
                        ,SCRQTY	            --폐품수량
                        ,RSDQTY	            --잔량
                        ,SCRAPCODE	        --페품코드
                        ,SCRAPREASON	    --페품원인
                        ,FAULT	            --원단 불량
                        ,SCRQTY_OP	        --페품수량(공정)
                        ,SCRAPCODE_OP	    --페품코드(공정)
                        ,SCRAPREASON_OP	    --페품원인(공정)
                        ,LGORT	            --저장위치
                        ,CHARG	            --LOT번호
                        ,SDATE	            --작업시작일자(생산시스템일자)
                        ,STIME	            --작업시작시간(생산시스템시간)
                        ,EDATE	            --작업종료일자(생산시스템일자)
                        ,ETIME	            --작업종료시간(생산시스템시간)
                        ,MDOCNO	            --MES 문서번호
                        ,MDOCSEQ	        --MES 문서순번
                        ,MBLNR	            --SAP 문서번호
                        ,MJAHR	            --SAP 문서번호(년도)
                        ,ZMESSAGE	        --SAP결과 메시지
                        ,ZRESULT_DATE	    --SAP 전송 시간
                        ,MAKE_DATE	        --등록일자
                        ,MAKER	            --등록자
                        ,RUNTIME	        --가동시간
                        ,JSPEED	            --선속
                        ,JREMARK	        --비고
                        ,VBELN	            --판매문서 번호
                        ,POSNR	            --판매문서 항목 번호
                        ,IF_MES_KEY	        --MES Inserface Key(MES->SAP 인 경우만)
                        ,WORKCENTERCODE	    --작업장코드(MES PK)
                        ,SCRQTY_R	        --폐품수량(연수)
                        ,SCRQTY_OP_R	    --폐품수량(연수)
                        ,MRSCQTY	        --밀롤 잔량
               )
               VALUES (
                         V_ORDER_NO	        --오더번호
                        ,V_LOT_NO_ORG /*V_LOT_NO*/	        --LOT 번호
                        ,V_INP_DT	        --투입일자(전기일)
                        ,V_MATNR	        --자재번호(투입자재)
                        ,NULL	        --폐품수량
                        ,0   	            --잔량
                        ,NULL	        --페품코드
                        ,NULL    	    --페품원인
                        ,NULL	            --원단 불량
                        ,V_STCK_QTY	    --페품수량(공정)
                        ,V_DISPO_CD	    --페품코드(공정)
                        ,V_DISPO_NM	    --페품원인(공정)
                        ,V_STOR_LOC_CD       --저장위치
                        ,V_LOT_NO	            --LOT번호
                        ,NULL	            --작업시작일자(생산시스템일자)
                        ,NULL	            --작업시작시간(생산시스템시간)
                        ,NULL	            --작업종료일자(생산시스템일자)
                        ,NULL	            --작업종료시간(생산시스템시간)
                        ,V_DOC_NO	            --MES 문서번호
                        ,V_DOC_SEQNO	        --MES 문서번호 순번
                        ,NULL	            --SAP 문서번호
                        ,NULL	            --SAP 문서번호(년도)
                        ,NULL	        --SAP결과 메시지
                        ,NULL	    --SAP 전송 시간
                        ,SYSDATE	        --등록일자
                        ,V_SESS_USER_ID	            --등록자
                        ,NULL	        --가동시간
                        ,NULL	            --선속
                        ,'폐품일괄등록'	        --비고
                        ,V_VBELN	            --판매문서 번호
                        ,V_POSNR	            --판매문서 항목 번호
                        ,NULL	        --MES Inserface Key(MES->SAP 인 경우만)
                        ,V_SAP_WRK_CD	    --작업장코드(MES PK)
                        ,V_STCK_QTY	        --폐품수량(연수)
                        ,V_STCK_QTY	    --폐품수량(연수)
                        ,NULL	        --밀롤 잔량
               );
           ELSE
               INSERT INTO   TB_IFS012 
               (
                         AUFNR	            --오더번호
                        ,LOTNO	            --LOT 번호
                        ,BUDAT	            --투입일자(전기일)
                        ,MATNR	            --자재번호(투입자재)
                        ,SCRQTY	            --폐품수량
                        ,RSDQTY	            --잔량
                        ,SCRAPCODE	        --페품코드
                        ,SCRAPREASON	    --페품원인
                        ,FAULT	            --원단 불량
                        ,SCRQTY_OP	        --페품수량(공정)
                        ,SCRAPCODE_OP	    --페품코드(공정)
                        ,SCRAPREASON_OP	    --페품원인(공정)
                        ,LGORT	            --저장위치
                        ,CHARG	            --LOT번호
                        ,SDATE	            --작업시작일자(생산시스템일자)
                        ,STIME	            --작업시작시간(생산시스템시간)
                        ,EDATE	            --작업종료일자(생산시스템일자)
                        ,ETIME	            --작업종료시간(생산시스템시간)
                        ,MDOCNO	            --MES 문서번호
                        ,MDOCSEQ	        --MES 문서순번
                        ,MBLNR	            --SAP 문서번호
                        ,MJAHR	            --SAP 문서번호(년도)
                        ,ZMESSAGE	        --SAP결과 메시지
                        ,ZRESULT_DATE	    --SAP 전송 시간
                        ,MAKE_DATE	        --등록일자
                        ,MAKER	            --등록자
                        ,RUNTIME	        --가동시간
                        ,JSPEED	            --선속
                        ,JREMARK	        --비고
                        ,VBELN	            --판매문서 번호
                        ,POSNR	            --판매문서 항목 번호
                        ,IF_MES_KEY	        --MES Inserface Key(MES->SAP 인 경우만)
                        ,WORKCENTERCODE	    --작업장코드(MES PK)
                        ,SCRQTY_R	        --폐품수량(연수)
                        ,SCRQTY_OP_R	    --폐품수량(연수)
                        ,MRSCQTY	        --밀롤 잔량
               )
               VALUES (
                         V_ORDER_NO	        --오더번호
                        ,V_LOT_NO_ORG /*V_LOT_NO*/	        --LOT 번호
                        ,V_INP_DT	        --투입일자(전기일)
                        ,V_MATNR	        --자재번호(투입자재)
                        ,V_STCK_QTY	        --폐품수량
                        ,0   	            --잔량
                        ,V_DISPO_CD	        --페품코드
                        ,V_DISPO_NM	    --페품원인
                        ,NULL	            --원단 불량
                        ,NULL	    --페품수량(공정)
                        ,NULL	    --페품코드(공정)
                        ,NULL	    --페품원인(공정)
                        ,V_STOR_LOC_CD       --저장위치
                        ,V_LOT_NO	            --LOT번호
                        ,NULL	            --작업시작일자(생산시스템일자)
                        ,NULL	            --작업시작시간(생산시스템시간)
                        ,NULL	            --작업종료일자(생산시스템일자)
                        ,NULL	            --작업종료시간(생산시스템시간)
                        ,V_DOC_NO	            --MES 문서번호
                        ,V_DOC_SEQNO	        --MES 문서번호 순번
                        ,NULL	            --SAP 문서번호
                        ,NULL	            --SAP 문서번호(년도)
                        ,NULL	        --SAP결과 메시지
                        ,NULL	    --SAP 전송 시간
                        ,SYSDATE	        --등록일자
                        ,V_SESS_USER_ID	            --등록자
                        ,NULL	        --가동시간
                        ,NULL	            --선속
                        ,'폐품일괄등록'	        --비고
                        ,V_VBELN	            --판매문서 번호
                        ,V_POSNR	            --판매문서 항목 번호
                        ,NULL	        --MES Inserface Key(MES->SAP 인 경우만)
                        ,V_SAP_WRK_CD	    --작업장코드(MES PK)
                        ,V_STCK_QTY	        --폐품수량(연수)
                        ,V_STCK_QTY	    --폐품수량(연수)
                        ,NULL	        --밀롤 잔량
               );
           END IF ;
           UPDATE TB_INV003                -- 자재투입량 폐품
              SET DISPO_QTY = NVL(DISPO_QTY, 0) + (V_STCK_QTY ),
                  USE_QTY   = NVL(USE_QTY, 0)   + (V_STCK_QTY ),
                  STCK_QTY  = NVL(STCK_QTY, 0)  - (V_STCK_QTY )
            WHERE WERKS   = V_WERKS
               AND MACH_CD = V_MACH_CD
               AND IND_BCD = V_IND_BCD;
           
        END LOOP;
        IF LENGTH(V_DOC_NO_SUM) > 0 THEN

                            --SAP FUNC ID
                            SELECT RFCFN
                              INTO RS_DISPO_RFCFN
                              FROM TB_ITFMA
                             WHERE 1=1
                               AND IFID = 'MES_IF_134';

                            --인터페이스 파라미터
                            --OPEN CUR_3 FOR
                            SELECT 'MES_IF_134' AS I_IF_ID
                                 , 'M' || LTRIM(RTRIM(TO_CHAR(SEQ_GET_IFR_KEY.NEXTVAL, '00000000000000000000000000000'))) AS I_IF_KEY
                               INTO  RS_DISPO_I_IF_ID,  RS_DISPO_I_IF_KEY 
                            FROM dual;

                            --인터페이스 상세 파라미터
                            --V_DOC_NO_SUM := SUBSTR(V_DOC_NO_SUM, 1, LENGTH(V_DOC_NO_SUM)-1 );
                            
                            --RS_DISPO_SQL := FN_IF_QUERY('MES_IF_134', V_DOC_NO_SUM);
                            RS_DISPO_SQL := SUBSTR(V_DOC_NO_SUM, 1, LENGTH(V_DOC_NO_SUM)-1 );
                            
                            --OPEN CUR_4 FOR RS_DISPO_SQL;

        END IF ;



/*
        IF (V_DEBUG = 'Y') THEN
            INSERT INTO PROC_LOG(SQL_STR) VALUES (V_DOC_SQL);
        END IF;

        OPEN P_RS_LIST FOR V_DOC_SQL; 
  */

    END IF;

    P_SUCCESS := 'Y';
    COMMIT;
    
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
        --RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);
        RAISE;
END;

/
