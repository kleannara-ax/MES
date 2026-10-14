--------------------------------------------------------
--  DDL for Procedure SP_POP_WRK29_I02_DBG
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_POP_WRK29_I02_DBG" 
(
    P_WERKS          IN     VARCHAR2 	            ,        --플랜트    
    P_MACH_CD        IN     VARCHAR2 	            ,        --설비코드    
    P_WRK_ORDR_NO    IN     VARCHAR2                ,        --재단작업지시번호    
    P_WRK_ORDR_SEQNO IN     NUMBER                  ,        --재단작업지시번호순번
    P_WRK_LIST       IN     CLOB                    ,
    P_WRK_CLASS      IN     VARCHAR2                ,
    P_WRK_SHIFT      IN     VARCHAR2                ,
    P_USERID         IN     VARCHAR2                ,        --USER ID    
    RS_PRFM_RFCFN    OUT    VARCHAR2                ,        --실적 RFCFN값
    RS_DISPO_RFCFN   OUT    VARCHAR2                ,        --폐품 RFCFN값    
    RS_INPUT_RFCFN   OUT    VARCHAR2                ,        --투입량 RFCFN값  
    RS_SDISPO_RFCFN  OUT    VARCHAR2                ,        --영업+잔량 폐품 RFCFN값    
    RS_IND_BCD       OUT    VARCHAR2                ,        --개별바코드    
    LANG             IN     VARCHAR2 DEFAULT 'KO'   ,
    RS_CODE          OUT    VARCHAR2                ,
    RS_MSG           OUT    VARCHAR2                ,
    CUR_1            OUT    SYS_REFCURSOR           ,        --실적
    CUR_2            OUT    SYS_REFCURSOR           ,
    CUR_3            OUT    SYS_REFCURSOR           ,        --폐품  
    CUR_4            OUT    SYS_REFCURSOR           ,
    CUR_5            OUT    SYS_REFCURSOR           ,        --투입량
    CUR_6            OUT    SYS_REFCURSOR           ,
    CUR_7            OUT    SYS_REFCURSOR           ,        --투입량
    CUR_8            OUT    SYS_REFCURSOR               
)
/*==============================================================================
 * PROGRAM ID    : WRK26{호출 프로그램 ID 기술}
 * PROGRAM NAME  : 수재단 실적등록
 * VERSION       : 1.0.0{최종 버전 기술}
 * DESCRIPTION   : .{프로그램에 대한 상세한 내용 기술}
 *                 
 * AUTHOR NAME   : 유상호{최초 작성자 명 기술}
 * CREATE DATE   : 2022/05/24 {최초 작성일자 기술}
 * SYSTEM NAME   : POP
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}  <생략가능>
 * SUB PROCEDURE : {아휘 프로시저 명칭 기술}      <생략가능>
 * SUB PACKAGES  : {하위 패키지 기술}            <생략가능>
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술} <생략가능>
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    DATE        VER       NAME          DESCRIPTION      
 * ------------ ------- ------------- ------------------------------------------
 * YYYY/MM/DD    1.0.0   유상호         INITIAL VERSION 
 *==============================================================================
 *  관련 테이블
 *       - [TB_WRK011] : (..U.) 설비별 현재진행사항                            
 *=============================================================================*/
 AS 
    --프로그램 ID : 수재단 실적등록
    V_PRG_NM            VARCHAR2(100) := 'SP_POP_WRK29_I02';     -- PROCEDURE NAME
    V_PLT_CD            VARCHAR2(2) := '99'; --PLANTCODE TEST
    V_SESS_USER_ID      VARCHAR2(20) := P_USERID; --USERID
    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER EXCEPTION;
    E_SQL_ERR_CD        NUMBER(5) := 0;
    E_SQL_ERR_MSG       VARCHAR2(4000);
    -- JSON을 위한 변수선언 영역
    V_JSON              JSON_OBJECT_T;
    V_ARR_LIST          JSON_ARRAY_T;
    V_OBJ               JSON_OBJECT_T;
    --PARAMETER변수 처리
    V_DOC_NO            VARCHAR2(20);
    V_DOC_SEQNO         NUMBER;
    V_DOC_NO_PR         VARCHAR2(20);
    V_DOC_SEQNO_PR      NUMBER;
    V_DOC_NO_SCR        VARCHAR2(20);
    V_DOC_SEQNO_SCR     NUMBER;
    V_DOC_NO_DISPO      VARCHAR2(500) := '';
    V_DOC_NO_PRFM       VARCHAR2(500) := '';
    V_DOC_NO_INPUT      VARCHAR2(500) := '';
    V_DOC_NO_SDISPO     VARCHAR2(500) := '';

    V_PRD_STR_DTM       VARCHAR2(20);
    V_PRD_END_DTM       VARCHAR2(20);
    V_ORD_PRD_STR_DTM   VARCHAR2(20);                       --작업지시 시작일시

    V_TM_SUM            TB_WRK002.TM%TYPE;					--작업시간

    V_PRD_STR_DATE_SUM      TB_WRK002.PRD_STR_DATE%TYPE;		--시작시간
    V_PRD_END_DATE_SUM      TB_WRK002.PRD_END_DATE%TYPE;		--시작시간   

    V_YMCHK             TB_MAS011.YMCHK%TYPE;               --실적등록 가능 여부
    V_SAP_WRK_CD        TB_MAS012.SAP_WRK_CD%TYPE;          --SAP작업장코드
    V_LINE              TB_MAS012.LINE%TYPE;                --라인

    V_WRK_ORDR_NO       TB_WRK002.WRK_ORDR_NO%TYPE;			--작업지시번호
    V_WRK_ORDR_SEQNO    TB_WRK002.WRK_ORDR_SEQNO%TYPE;		--작업지시번호순번
    V_PRFM_QTY          TB_WRK002.PRFM_QTY%TYPE;            --생산갯수
    V_WGT               TB_WRK002.WGT%TYPE;					--생산중량
    V_PCNT              TB_WRK002.PCNT%TYPE;			    --생산연수
    V_PRD_STR_DATE      TB_WRK002.PRD_STR_DATE%TYPE;		--시작시간   
    V_PRD_END_DATE      TB_WRK002.PRD_END_DATE%TYPE;		--시작시간   
    V_RMK               TB_WRK002.RMK%TYPE;					--비고
    V_ORDER_NO          TB_WRK002.ORDER_NO%TYPE;			--오더번호
    V_PRE_ORDER_NO      TB_WRK002.ORDER_NO%TYPE;			--오더번호(투입)
    V_IND_BCD           TB_WRK002.IND_BCD%TYPE;			    --개별바코드 (생성바코드 )
    V_MATNR             TB_WRK002.MATNR%TYPE;				--자재코드
    V_LOT_NO            TB_WRK002.LOT_NO%TYPE;				--LOT NO
    V_LOT_NO2            TB_WRK002.LOT_NO%TYPE;				--LOT NO
    V_IND_BCD_M         TB_WRK002.IND_BCD%TYPE;				--개별바코드 (투입바코드 )
    V_MATNR_M           TB_WRK002.MATNR%TYPE;				--밀롤 자재코드
    V_LOT_NO_M          TB_WRK002.LOT_NO%TYPE;				--밀롤 LOT NO
    V_IND_BCD_MR        TB_WRK002.IND_BCD%TYPE;				--밀롤 개별바코드
    V_MATNR_MR          TB_WRK002.MATNR%TYPE;				--밀롤 자재코드
    V_LOT_NO_MR         TB_WRK002.LOT_NO%TYPE;				--밀롤 LOT NO
    V_WRK_SEQ           TB_WRK002.WRK_SEQ%TYPE;				--생산순번
    V_MACHINE           TB_WRK002.MACHINE%TYPE;				--생산호기
    V_TO_MACHINE        TB_WRK002.TO_MACHINE%TYPE;			--생산호기
    V_PRFM_DT           TB_WRK002.PRFM_DT%TYPE;				--생산실적일
    V_PRFM_DT2           TB_WRK002.PRFM_DT%TYPE;				--생산실적일
    V_PRD_DT            TB_WRK002.PRD_DT%TYPE;				--생산일
    V_DSTBT_DDLIN       TB_WRK002.DSTBT_DDLIN%TYPE;			--유통기간    
    V_TM                TB_WRK002.TM%TYPE;					--작업시간
    V_UNIT              TB_WRK002.UNIT%TYPE;				--단위
    V_PRD_NO            TB_WRK002.PRD_NO%TYPE;				--생산번호

    V_VBELN_M           TB_SCH016.VBELN%TYPE;				--밀롤 판매문서번호
    V_POSNR_M           TB_SCH016.POSNR%TYPE;				--밀롤 판매문서 아이템번호
    V_PCODE             TB_SCH016.PCODE%TYPE;               --지종
    V_MRCNT             TB_SCH016.MRCNT%TYPE;               --밀롤폭수
    V_MWIDTH            TB_SCH016.MWIDTH_INPUT%TYPE;        --밀롤지폭
    V_WRK_ORDR_NO_MR    TB_SCH016.WRK_ORDR_NO%TYPE;
    V_WRK_ORDR_SEQNO_MR TB_SCH016.WRK_ORDR_SEQNO%TYPE;
    V_JR_WRK_ORDR_NO    TB_SCH016.WRK_ORDR_NO%TYPE;			--밀롤작업지시번호(투입)
    V_JR_WRK_ORDR_SEQNO TB_SCH016.WRK_ORDR_SEQNO%TYPE;		--밀롤작업지시번호순번투입)

    V_VBELN             TB_SCH017.VBELN%TYPE;			    --판매문서번호
    V_VBELN_SDISPO      TB_SCH017.VBELN%TYPE;				--영업폐품시 사용할 판매문서번호
    V_POSNR             TB_SCH017.POSNR%TYPE;				--판매문서 아이템번호
    V_POSNR_SDISPO      TB_SCH017.POSNR%TYPE;				--영업폐품시 사용할 판매문서 아이템번호
    V_OVBELN            TB_SCH017.OVBELN%TYPE;				--판매문서번호
    V_OPOSNR            TB_SCH017.OPOSNR%TYPE;				--판매문서 아이템번호
    V_OAUART_DIV        TB_SCH017.OAUART_DIV%TYPE;			--판매문서번호
    V_LOT_BUF           TB_SCH017.LOT_BUF%TYPE;				--이전LOT NO
    V_BS_WGT            TB_SCH017.BS_WGT%TYPE;              --평량
    V_KUNNR             TB_SCH017.KUNNR%TYPE;               --거래처 
    V_VLEN              TB_SCH017.VLEN%TYPE;                --세로길이
    V_WLEN              TB_SCH017.WLEN%TYPE;                --가로길이
    V_PKCNT             TB_SCH017.PKCNT%TYPE;               --재단폭수

    V_PRFM_PLT          NUMBER;                             -- 파렛트 수
    V_WRK_TM            NUMBER;                             --작업시간(분)
    V_ORD_TM            NUMBER;                             --오더 작업시간(분)
    V_ORD_ABN_TIME      NUMBER;                             --비가동 시간(분)
    V_USER_NM           VARCHAR2(20);                       --작업자명
    V_PRFM_GTHR_YN      VARCHAR2(1);                        --실적집계여부
    V_LOC_CD            VARCHAR2(10);                       --로케이션정보
    V_STOR_LOC_CD       VARCHAR2(10);
    V_STOR_LOC_CD_M     VARCHAR2(10);
    V_LOOP_CNT          NUMBER;
    V_DISPO_QTY         NUMBER(13, 3);                      --폐품수량(연수)
    V_DISPO_WGT         NUMBER(13, 3);                      --폐품중량
    V_DISPO_CD          VARCHAR2(10);                       --폐품코드
    V_DISPO_NM          VARCHAR2(50);                       --폐품코드
    V_CACOM_YN          VARCHAR2(1);                        --재단완료여부
    V_SCACOM_YN         VARCHAR2(1);                        --수재단완료여부    
    V_ORD_STR_DATE      VARCHAR2(10);
    V_ORD_STR_TIME      VARCHAR2(10);
    V_ORD_END_DATE      VARCHAR2(10);
    V_ORD_END_TIME      VARCHAR2(10);
    V_CA_WGT            NUMBER;
    V_CA_ROLLCNT        NUMBER;
    V_ORDER_ITM_NO      VARCHAR2(10);    
    V_WGT_RMD           NUMBER(13, 3);                      --잔량(영업폐품) 중량
    V_MWGT              NUMBER(13, 3);                      --밀롤 생산량
    V_SWGT              NUMBER(13, 3);                      --수재단 생산량 
    V_SDISPO_QTY        NUMBER(13, 3);                      --수재단 폐품생산량 
    V_PRFM_PLT_GU       VARCHAR2(1);       
    V_SEQ               NUMBER ; 
    V_DATE              DATE := SYSDATE;
    V_SQL               VARCHAR2(4000);
    V_MSDISPO_TOT       NUMBER(13, 3);                      --수재단 폐품생산량 
    V_JISI_CNT          NUMBER;
    V_DUMMY_KEY         VARCHAR2(20);     

    V_IN_MR_YN          TB_INV001.IN_MR_YN%TYPE;            --수입밀롤 여부
BEGIN
    BEGIN

        V_DOC_SEQNO_SCR   := 0 ; 
        V_DOC_SEQNO       := 0 ;
        V_DOC_NO_DISPO    := '';
        V_DOC_NO_PRFM     := '';
        V_DOC_NO_INPUT    := '';
        V_DOC_NO_SDISPO   := '';

        --JSON 데이터 수신
        V_JSON := JSON_OBJECT_T.PARSE(P_WRK_LIST); -- 전체 데이터
        V_ARR_LIST := V_JSON.GET_ARRAY('list');

        --작업시작일시, 작업종료일시, 실적연수, 실적중량, 팔레트수량, 가동시간(분), 가로길이, 세로길이, 평량
        --폐품연수, 폐품중량, 폐품코드, 폐품코드명, 비고, 재단완료여부, 수재단완료여부, 재단 개별바코드
        --재단 자재코드, 재단 LOT NO, 수재단작업지시번호, 수재단작업지시번호, 팔레트구분

        V_LOOP_CNT := V_ARR_LIST.GET_SIZE;

        FOR I IN 0..V_ARR_LIST.GET_SIZE - 1 LOOP
            V_OBJ := TREAT(V_ARR_LIST.GET(I) AS JSON_OBJECT_T);
            V_OBJ := TREAT(V_OBJ.GET('map') AS JSON_OBJECT_T);

            V_PRD_STR_DTM       := V_OBJ.GET_STRING('PRD_STR_DATE');            --작업시작일시
            V_PRD_END_DTM       := V_OBJ.GET_STRING('PRD_END_DATE');            --작업종료일시
            V_PCNT              := TO_NUMBER(V_OBJ.GET_STRING('PRFM_QTY'));     --실적연수
            V_WGT               := TO_NUMBER(V_OBJ.GET_STRING('WGT'));          --실적중량
            V_PRFM_PLT          := TO_NUMBER(V_OBJ.GET_STRING('PRFM_PLT'));     --팔레트수량
            V_TM                := V_OBJ.GET_STRING('TM');                      --가동시간(분)
            V_WLEN              := TO_NUMBER(V_OBJ.GET_STRING('WLEN'));         --가로길이
            V_VLEN              := TO_NUMBER(V_OBJ.GET_STRING('VLEN'));         --세로길이
            V_BS_WGT            := V_OBJ.GET_STRING('BS_WGT');                  --평량
            V_DISPO_QTY         := TO_NUMBER(V_OBJ.GET_STRING('DISPO_QTY'));    --폐품연수
            V_DISPO_WGT         := TO_NUMBER(V_OBJ.GET_STRING('DISPO_WGT'));    --폐품중량
            V_DISPO_CD          := V_OBJ.GET_STRING('DISPO_CD');                --폐품코드
            V_DISPO_NM          := V_OBJ.GET_STRING('DISPO_NM');                --폐품코드명
            V_RMK               := V_OBJ.GET_STRING('RMK');                     --비고
            V_CACOM_YN          := V_OBJ.GET_STRING('CACOM_YN');                --재단완료여부
            V_SCACOM_YN         := V_OBJ.GET_STRING('SCACOM_YN');               --수재단완료여부
            V_IND_BCD_M         := V_OBJ.GET_STRING('IND_BCD_M');               --재단개별바코드
            V_MATNR_M           := V_OBJ.GET_STRING('MATRN_M');                 --재단자재코드
            V_LOT_NO_M          := V_OBJ.GET_STRING('LOT_NO_M');                --재단LOT NO
            --V_WRK_ORDR_NO       := V_OBJ.GET_STRING('WRK_ORDR_NO');             --수재단작업지시번호
            --V_WRK_ORDR_SEQNO    := V_OBJ.GET_STRING('WRK_ORDR_SEQNO');          --수재단작업지시순번
            V_PRFM_PLT_GU       := V_OBJ.GET_STRING('PRFM_PLT_GU');             --팔레트구분

/*
           SELECT WRK_ORDR_NO , WRK_ORDR_SEQNO
             INTO V_WRK_ORDR_NO,V_WRK_ORDR_SEQNO 
           FROM TB_SCH017
           WHERE WERKS = P_WERKS
             AND DUMMY_KEY = V_IND_BCD_M
             AND NVL(USE_YN, 'Y') = 'Y'
          ;
*/

           SELECT H017.WRK_ORDR_NO , H017.WRK_ORDR_SEQNO
             INTO V_WRK_ORDR_NO,V_WRK_ORDR_SEQNO            
           FROM TB_SCH017  H017, TB_INV003  V003
           WHERE H017.WERKS = V003.WERKS
             AND H017.DUMMY_KEY = V003.IND_BCD
             AND H017.DUMMY_WRK_ORDR_NO = V003.WRK_ORDR_NO
             AND H017.DUMMY_WRK_ORDR_SEQNO = V003.WRK_ORDR_SEQNO
             AND H017.WERKS = P_WERKS
             AND H017.DUMMY_KEY = V_IND_BCD_M
             AND NVL(H017.USE_YN, 'Y') = 'Y'
             ;

            UPDATE TB_INV003 
               SET IN_QTY   = WGT, 
                   STCK_QTY = WGT
             WHERE WERKS = P_WERKS
               AND MACH_CD = P_MACH_CD
               AND IND_BCD = V_IND_BCD_M
               AND USE_QTY = 0 ;

	        -- 수입밀롤 유무 확인
	        SELECT IN_MR_YN
	          INTO V_IN_MR_YN
	          FROM TB_INV001
	         WHERE WERKS = P_WERKS
	           AND IND_BCD = V_IND_BCD_M
	           AND NVL(DLFL, 'N') = 'N';

            --수입밀롤 체크 추가	            
	        IF NVL(V_IN_MR_YN, 'N') = 'N' THEN
	            SELECT  DISTINCT
	                   A.IND_BCD 
	                 , A.MATNR
	                 , A.LOT_NO
	                 , A.WRK_ORDR_NO
	                 , A.WRK_ORDR_SEQNO
	            INTO
	                   V_IND_BCD_MR
	                 , V_MATNR_MR
	                 , V_LOT_NO_MR
	                 , V_WRK_ORDR_NO_MR
	                 , V_WRK_ORDR_SEQNO_MR
	            FROM(
	                  SELECT  DISTINCT
	                           A.IND_BCD_M  IND_BCD
	                         , A.MATNR_M    MATNR
	                         , A.LOT_NO_M   LOT_NO
	                         , B.WRK_ORDR_NO  WRK_ORDR_NO
	                         , B.WRK_ORDR_SEQNO  WRK_ORDR_SEQNO
	                    FROM TB_INV010 A, TB_WRK002 B
	                   WHERE 1 = 1
	                     AND A.IND_BCD_M = B.IND_BCD
	                     AND A.WERKS  = B.WERKS
	                     AND A.IND_BCD = V_IND_BCD_M
	                     AND NVL(B.CNL_YN,'N') = 'N'
	                     AND NVL(A.CNL_YN,'N') = 'N'
	            	) A
	            WHERE 1 = 1
	              AND ROWNUM = 1
	            ORDER BY LOT_NO
	            ;
	        ELSE 
	        	--수입밀롤인 경우
	        	SELECT I010.IND_BCD_M, I010.MATNR_M, I010.LOT_NO_M, S016.WRK_ORDR_NO, S016.WRK_ORDR_SEQNO
	        	  INTO V_IND_BCD_MR, V_MATNR_MR, V_LOT_NO_MR, V_WRK_ORDR_NO_MR, V_WRK_ORDR_SEQNO_MR
	        	  FROM TB_INV010 I010, TB_SCH016 S016
	        	 WHERE I010.LOT_NO_M = S016.ORDER_NO
	        	   AND I010.IND_BCD = V_IND_BCD_M
	        	   AND NVL(I010.CNL_YN, 'N') = 'N'
	              --AND  NVL(S016.USE_YN, 'Y') = 'Y'
                   ;
	        END IF;
	
	        BEGIN
	            SELECT S016.MRCNT, S016.MWIDTH_INPUT
	             INTO V_MRCNT, V_MWIDTH
	             FROM TB_SCH016 S016
	            WHERE  S016.WRK_ORDR_NO    = V_WRK_ORDR_NO_MR
	              AND  S016.WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO_MR
	              --AND  NVL(USE_YN, 'Y') = 'Y'
	              ;                  
	        EXCEPTION
	            WHEN NO_DATA_FOUND THEN
	                SELECT MRCNT, MWIDTH_INPUT
	                 INTO V_MRCNT, V_MWIDTH
	                 FROM TB_SCH017
	                WHERE WRK_ORDR_NO    = V_WRK_ORDR_NO  
	                  AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO  
	                  AND NVL(USE_YN, 'Y') = 'Y'
	                  ;
	        END;              
	            
	        BEGIN 
	        	SELECT
	                   S017.ORDER_NO, S017.PRE_ORDER_NO, S017.MATNR, S017.VBELN, S017.POSNR, S017.OVBELN, S017.OPOSNR,
	                   S017.MACHINE, S017.TO_MACHINE, S017.LOT_BUF, S017.PRD_STR_DTM, S017.UNIT, S017.OAUART_DIV,
	                   S017.PCODE, S017.BS_WGT, S017.KUNNR, S017.VLEN, S017.WLEN, S017.PKCNT,
	                   S016.WRK_ORDR_NO, S016.WRK_ORDR_SEQNO
	           	  INTO
	                   V_ORDER_NO, V_PRE_ORDER_NO, V_MATNR, V_VBELN, V_POSNR, V_OVBELN, V_OPOSNR,
	                   V_MACHINE, V_TO_MACHINE, V_LOT_BUF, V_ORD_PRD_STR_DTM, V_UNIT, V_OAUART_DIV,
	                   V_PCODE, V_BS_WGT, V_KUNNR, V_VLEN, V_WLEN, V_PKCNT,
	                   V_JR_WRK_ORDR_NO, V_JR_WRK_ORDR_SEQNO
	           	  FROM TB_SCH017 S017,    --작업지시 수재단
	                   TB_SCH017 S0171,   --작업지시 재단
	                   TB_SCH016 S016     --작업지시 밀롤
	             WHERE S017.PRE_ORDER_NO   = S0171.ORDER_NO (+)
	               AND S0171.PRE_ORDER_NO  = S016.ORDER_NO (+)
	               AND S017.MAN_CUT_YN     = 'X'
	               AND S0171.MAN_CUT_YN    = 'Y'
	               AND S017.WRK_ORDR_NO    = V_WRK_ORDR_NO
	               AND S017.WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
	               AND NVL(S017.USE_YN, 'Y') = 'Y'
	               AND NVL(S0171.USE_YN, 'Y') = 'Y'
	--             AND NVL(S016.USE_YN, 'Y') = 'Y'
	             ;
	        EXCEPTION
	            WHEN NO_DATA_FOUND THEN
	                RS_CODE := 'E';
	                RS_MSG := '밀롤 작업지시를 확인해주세요';
	                ROLLBACK;
	                RETURN;
	        END;      
	
	       SELECT LINE, SAP_WRK_CD
	         INTO V_LINE, V_SAP_WRK_CD
	         FROM TB_MAS012
	        WHERE MACH_CD = P_MACH_CD ;
	
	        --로케이션 정보
	        BEGIN
	            SELECT LGPRO   --투입저장위치
	            INTO V_STOR_LOC_CD
	            FROM TB_MAS001
	            WHERE WERKS = P_WERKS
	              AND MATNR = V_MATNR;
	        EXCEPTION
	            WHEN NO_DATA_FOUND THEN
	                V_STOR_LOC_CD := '';
	            WHEN OTHERS THEN
	                V_STOR_LOC_CD := '';
	        END;
	
	        IF NVL(V_STOR_LOC_CD, '') = '' THEN
	            RS_CODE := 'E';
	            RS_MSG := '투입저장위치 정보를 확인해주세요'||' '||P_WERKS||' '||V_MATNR;
	            ROLLBACK;
	            RETURN;
	        END IF;
	
	
	        -- 정상처리의 경우는 밀롤창고 에서 재고이전되면 '2700' 으로 전송해야함.
	        V_STOR_LOC_CD_M := '2700';
	        V_LOC_CD := 'L2600';    --포장대기창고
	
	        --작업자명
	        BEGIN
	            SELECT NMLAST
	            INTO V_USER_NM
	            FROM USRMA
	            WHERE USERID = P_USERID;
	
	        EXCEPTION
	            WHEN NO_DATA_FOUND THEN
	                V_USER_NM := '';
	            WHEN OTHERS THEN
	                V_USER_NM := '';
	        END;
	
	        V_PRFM_GTHR_YN := 'Y';
	
	        -- LOT NO 생성
	        SP_CHK_LOT_NO(V_LOT_BUF, P_WERKS, P_MACH_CD, V_MATNR, V_PRD_END_DTM, V_LOT_NO);

            -- 2022년 10월 이전 생산분인경우 실적에서 LOT NO를 가져옴.
            BEGIN
                SELECT PRFM_DT,LOT_NO
                INTO V_PRFM_DT2,V_LOT_NO2
                FROM TB_WRK002
                WHERE 1 = 1
                AND IND_BCD = V_IND_BCD_M
                ;
            END;


            IF SUBSTR(V_IND_BCD_M,6,1) = 'T' AND TO_CHAR(TO_DATE(V_PRFM_DT2, 'YYYYMMDD'), 'YYYYMMDD') < '20221001' THEN
                BEGIN
--                    V_PRFM_DT := V_PRFM_DT2;
                    V_LOT_NO := V_LOT_NO2;
                END;
            END IF;

            -- LOT_NO 작업지시에 LOT_BUF에 UPDATE
            V_LOT_BUF := V_LOT_NO ;

            UPDATE TB_SCH017
               SET LOT_BUF = V_LOT_NO
                 , UPDDATE = SYSDATE
                 , UPDID   = P_USERID
             WHERE WRK_ORDR_NO = V_WRK_ORDR_NO  
               AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
               AND NVL(USE_YN, 'Y') = 'Y'
               ;

            --실적일자, 생산일자, 유통기간
            V_PRFM_DT := FN_RECDATE(TO_DATE(V_PRD_END_DTM, 'YYYYMMDDHH24MISS'));
            V_PRD_DT := TO_CHAR(TO_DATE(V_PRD_END_DTM, 'YYYYMMDDHH24MISS'), 'YYYYMMDD');
            V_DSTBT_DDLIN := ''; --FN_GET_DSTBT_DDLIN_DT(P_WERKS, V_MATNR, V_PRD_DT);

            V_PRD_STR_DATE := TO_DATE(V_PRD_STR_DTM, 'YYYYMMDDHH24MISS');
            V_PRD_END_DATE := TO_DATE(V_PRD_END_DTM, 'YYYYMMDDHH24MISS');

            --실적등록 가능 월 검사                
            BEGIN
                SELECT YMCHK INTO V_YMCHK
                  FROM TB_MAS011
                 WHERE WERKS = P_WERKS
                   AND YMCHK = 'Y'
                   AND YYMM  = SUBSTR(V_PRFM_DT, 1, 6);
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    V_YMCHK := 'N';
            END;

            IF V_YMCHK = 'N' THEN
                RS_CODE := 'E';
                RS_MSG := '실적등록 가능한 월이 아닙니다.';
                ROLLBACK;
                RETURN;
            END IF;

            V_WRK_TM := ROUND(V_TM / V_LOOP_CNT, 1);

            --생산순번 조회
            BEGIN
                SELECT MAX(WRK_SEQ)
                INTO V_WRK_SEQ
                FROM TB_WRK002
                WHERE WERKS   = P_WERKS
                  AND MACH_CD = P_MACH_CD
                  AND PRFM_DT = V_PRFM_DT
                  AND NVL(CNL_YN,'N') = 'N';

            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    V_WRK_SEQ := 0;
            END;

            V_WRK_SEQ := NVL(V_WRK_SEQ, 0) + 1;

            --생산번호
            V_PRD_NO := TO_CHAR(TO_DATE(V_PRFM_DT, 'YYYYMMDD'), 'YYYY-MM-DD')
                        || '-'
                        || V_MACHINE
                        || '-'
                        || TO_CHAR(V_WRK_SEQ);

            IF V_ORD_PRD_STR_DTM IS NULL THEN
                BEGIN
                    V_ORD_STR_DATE := TO_CHAR(TO_DATE(V_PRD_STR_DTM, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD');
                    V_ORD_STR_TIME := TO_CHAR(TO_DATE(V_PRD_STR_DTM, 'YYYY-MM-DD HH24:MI:SS'), 'HH24:MI:SS');
                END;
            ELSE
                BEGIN
                    V_ORD_STR_DATE := TO_CHAR(TO_DATE(V_ORD_PRD_STR_DTM, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD');
                    V_ORD_STR_TIME := TO_CHAR(TO_DATE(V_ORD_PRD_STR_DTM, 'YYYY-MM-DD HH24:MI:SS'), 'HH24:MI:SS');
                END;
            END IF;

            V_ORD_END_DATE := TO_CHAR(TO_DATE(V_PRD_END_DTM, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD');
            V_ORD_END_TIME := TO_CHAR(TO_DATE(V_PRD_END_DTM, 'YYYY-MM-DD HH24:MI:SS'), 'HH24:MI:SS');
            V_WRK_TM := V_TM;

            --수재단완료시
            IF V_SCACOM_YN = 'Y'  THEN

                V_DUMMY_KEY := '' ;
                V_JISI_CNT  := 0 ;
                BEGIN                
                        SELECT H017.DUMMY_KEY, 1
                          INTO V_DUMMY_KEY   , V_JISI_CNT
                          FROM TB_SCH017  H017, TB_INV003  V003
                         WHERE H017.WERKS = V003.WERKS (+)
                           AND H017.DUMMY_KEY = V003.IND_BCD (+)
                           AND H017.WERKS = P_WERKS
                           AND H017.ORDER_NO = V_ORDER_NO
                           AND H017.MAN_CUT_YN    = 'X' 
                           AND NVL(H017.USE_YN, 'Y') = 'Y'
                           AND V003.IND_BCD  IS NULL
                           AND ROWNUM    = 1 
                           ;
                EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                            V_JISI_CNT := 0 ;
                END;
    
                IF V_JISI_CNT = 1   THEN
                        RS_CODE := 'E';
                        RS_MSG := ' 해당 바코드를 공정투입 하세요.  ' ||'( '||V_DUMMY_KEY||' )';
                        ROLLBACK;
                        RETURN;
                END IF ;

            /*
                V_JISI_CNT := 0 ;

                BEGIN                
                    SELECT 1  , DUMMY_KEY
                      INTO V_JISI_CNT, V_DUMMY_KEY
                      FROM TB_SCH017
                     WHERE WERKS = P_WERKS
                       AND ORDER_NO = V_ORDER_NO
                       AND MAN_CUT_YN    = 'X' 
                       AND NVL(USE_YN, 'Y') = 'Y'
                       AND NVL(COMP_YN,'N') <> 'Y'
                       AND DUMMY_KEY    <> V_IND_BCD_M
                       AND ROWNUM    = 1 
                       ;
                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        V_JISI_CNT := 0 ;
                END;
               */    
                /*IF V_JISI_CNT > 0  THEN
                    RS_CODE := 'E';
                    RS_MSG := '사용하지 않는 투입자재가 있습니다. 수재단 완료를 OFF 하세요. ' ||V_DUMMY_KEY;
                    ROLLBACK;
                    RETURN;
                END IF ;
                */
                
                V_ORD_TM := ROUND((V_PRD_END_DATE - TO_DATE(V_ORD_PRD_STR_DTM, 'YYYY-MM-DD HH24:MI:SS')) * 24 * 60);

                --비가동 시간
                SELECT SUM(ABN_TM)
                  INTO V_ORD_ABN_TIME
                  FROM TB_WRK003
                 WHERE WERKS = P_WERKS
                   AND MACH_CD = P_MACH_CD
                   AND WRK_ORDR_NO = V_WRK_ORDR_NO
                   AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO;

                -- 가동시간 (생산가동시간 - 비가동시간 )
                V_ORD_TM := V_ORD_TM - V_ORD_ABN_TIME;

                -- 작업지시 완료 처리
                UPDATE TB_SCH017
                   SET PRD_END_DTM = V_PRD_END_DTM,
                       COMP_YN = 'Y' ,
                       UPDDATE = SYSDATE,
                       UPDID   = P_USERID
                 WHERE WERKS = P_WERKS
                   AND ORDER_NO = V_ORDER_NO
                   --AND WRK_ORDR_NO = V_WRK_ORDR_NO  
                   --AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO                   
                   AND MAN_CUT_YN    = 'X' 
--                   AND DUMMY_KEY = V_IND_BCD_M
                   AND NVL(USE_YN, 'Y') = 'Y' 
                   ;

            END IF;

            -- 재단 중량 = (실적연수(R ) * 500 ) * ( 평량 / 1000) * ( 가로길이 / 1000 ) * (세로 / 1000 )
            --V_WGT := ( V_PCNT ) * 500 * ( V_BS_WGT / 1000 ) * ( V_WLEN / 1000 ) * ( V_VLEN / 1000 );
            V_PRFM_QTY := V_PCNT * 500 ;

            --실적등록
            IF NVL(V_WGT, 0) > 0 THEN
                    IF V_PRFM_PLT_GU = '1' THEN
                        --문서번호
                        V_DOC_NO_PR := '' ;
                        V_DOC_NO_PR := FN_GET_MDOCNO('M', 'IF126');
                        V_DOC_SEQNO_PR := V_DOC_SEQNO + 1;

                        V_DOC_NO_PRFM := V_DOC_NO_PRFM || V_DOC_NO_PR||',';

                        --개별바코드
                        SP_GET_BARCODE_SEQ('IND', P_WERKS, 'C', V_MATNR, V_PRD_END_DTM, V_IND_BCD);

                        RS_IND_BCD := RS_IND_BCD ||V_IND_BCD|| '|';    -- 개별 바코드 구분자 로 여러개 전달

                    END IF ;

                    BEGIN
                        INSERT INTO TB_WRK002 (
                            WERKS,
                            MACH_CD,
                            IND_BCD,
                            LOT_NO,
                            MATNR,
                            ORDER_NO,
                            WRK_ORDR_NO,
                            WRK_ORDR_SEQNO,
                            PRD_NO,
                            UNIT,
                            PRFM_QTY,
                            PCNT,
                            WGT,
                            MER_YN,
                            GRD_YN,
                            PRD_STR_DATE,
                            PRD_END_DATE,
                            TM,
                            PRFM_DT,
                            PRD_DT,
                            DSTBT_DDLIN,
                            WRK_CLASS,
                            WRK_SHIFT,
                            MACHINE,
                            TO_MACHINE,
                            STA,
                            RUN_STA,
                            DOC_NO,
                            DOC_SEQNO,
                            RMK,
                            REGDATE,
                            REGID,
                            VBELN,
                            POSNR,
                            KUNNR,
                            WRK_SEQ,
                            PRFM_GTHR_YN,
                            WLEN,
                            VLEN
                        ) VALUES (
                            P_WERKS,
                            P_MACH_CD,
                            V_IND_BCD,
                            V_LOT_NO,
                            V_MATNR,
                            V_ORDER_NO,
                            V_WRK_ORDR_NO,
                            V_WRK_ORDR_SEQNO,
                            V_PRD_NO,
                            'EA',
                            V_PRFM_QTY,
                            V_PCNT,
                            V_WGT,
                            'N',
                            'N',
                            V_PRD_STR_DATE,
                            V_PRD_END_DATE,
                            V_WRK_TM,
                            V_PRFM_DT,
                            V_PRD_DT,
                            V_DSTBT_DDLIN,
                            P_WRK_CLASS,
                            P_WRK_SHIFT,
                            V_MACHINE,
                            V_TO_MACHINE,
                            '00',
                            '01',
                            V_DOC_NO_PR,
                            V_DOC_SEQNO_PR,
                            V_RMK,
                            V_DATE,
                            P_USERID,
                            V_VBELN,
                            V_POSNR,
                            V_KUNNR,
                            V_WRK_SEQ,
                            V_PRFM_GTHR_YN,
                            V_WLEN,
                            V_VLEN
                         );

                    EXCEPTION
                        WHEN DUP_VAL_ON_INDEX THEN
                           UPDATE TB_WRK002  SET
                                PRFM_QTY = NVL(PRFM_QTY,0) + V_PRFM_QTY
                               ,PCNT     = NVL(PCNT,0)     + V_PCNT
                               ,WGT      = NVL(WGT,0)      + V_WGT
                           WHERE WERKS    =  P_WERKS
                             AND MACH_CD  =  P_MACH_CD
                             AND IND_BCD  =  V_IND_BCD
                           ;
                    END;

                    --실적 I/F

                            SELECT  
                                   MIN(PRD_STR_DATE)
                                 , MAX(PRD_END_DATE)
                                 , SUM(TM)
                            INTO
                                   V_PRD_STR_DATE_SUM
                                 , V_PRD_END_DATE_SUM
                                 , V_TM_SUM
                            FROM
                            (
                                SELECT PRD_STR_DATE  PRD_STR_DATE
                                     , PRD_END_DATE  PRD_END_DATE
                                     , TM                                         TM  
                                  FROM TB_WRK002  K002
                                 WHERE K002.WERKS          = P_WERKS
                                   AND K002.ORDER_NO       =  V_ORDER_NO
                                   AND NVL(CNL_YN, 'N') = 'N'
                                 GROUP BY   TM , PRD_STR_DATE,PRD_END_DATE 
                            )
                            ;

                    BEGIN
                            BEGIN
                                INSERT INTO TB_IFS005 (
                                    AUFNR,
                                    CRLOT,  -- 재단
                                    WERKS,
                                    WORKCENTERCODE,
                                    BUDAT,
                                    MACHINE,
                                    WORKGROUP,
                                    PRDQTY,
                                    MEINS,
                                    CRUNTIME,
                                    COPNAM,
                                    CUTTER,
                                    CONFM,
                                    CONFC,
                                    CSDATE,
                                    CSTIME,
                                    CEDATE,
                                    CETIME,
                                    MDOCNO,
                                    MDOCSEQ,
                                    MAKE_DATE,
                                    MAKER,
                                    MRLOT  --밀롤
                                ) VALUES (
                                    V_ORDER_NO,
                                    V_LOT_NO,  --V_LOT_NO,
                                    P_WERKS,
                                    V_SAP_WRK_CD,
                                    TO_CHAR(TO_DATE(V_PRFM_DT, 'YYYYMMDD'), 'YYYY-MM-DD'),
                                    V_MACHINE,
                                    P_WRK_CLASS,
                                    V_PCNT,         -- 2022-07-14 BMKIM : 실적 전송시 EA -> 연수로 변경하여 전달 하기로 함.
                                    'R',
                                    V_TM_SUM ,  --NVL(V_ORD_TM, '0'),
                                    SUBSTRB(V_USER_NM, 1, 10),
                                    TO_CHAR(V_LINE),
                                    (CASE WHEN V_SCACOM_YN = 'Y' AND V_PRFM_PLT  = (I + 1) THEN 'X' ELSE '' END),          -- SAP 에 마지막생산 전송시 'Y'를 'X', 아닌경우는 빈값으로 전송
                                    (CASE WHEN V_SCACOM_YN = 'Y' AND V_PRFM_PLT  = (I + 1) THEN 'X' ELSE '' END),          -- SAP 에 마지막생산 전송시 'Y'를 'X', 아닌경우는 빈값으로 전송
                                    --'X',
                                    --'X',
                                    --V_ORD_STR_DATE,
                                    --V_ORD_STR_TIME,
                                    --V_ORD_END_DATE,
                                    --V_ORD_END_TIME,
                                    TO_CHAR(V_PRD_STR_DATE_SUM,'YYYY-MM-DD'),
                                    TO_CHAR(V_PRD_STR_DATE_SUM,'HH24:MI:SS'),
                                    TO_CHAR(V_PRD_END_DATE_SUM,'YYYY-MM-DD'),
                                    TO_CHAR(V_PRD_END_DATE_SUM,'HH24:MI:SS'),
                                    V_DOC_NO_PR,
                                    V_DOC_SEQNO_PR,
                                    V_DATE,
                                    P_USERID,
                                    V_LOT_NO_MR
                                );
                            EXCEPTION
                                WHEN DUP_VAL_ON_INDEX  THEN
                                    UPDATE TB_IFS005 SET
                                           PRDQTY = NVL(PRDQTY, 0) + V_PCNT
                                     WHERE MDOCNO  = V_DOC_NO_PR
                                       AND MDOCSEQ = V_DOC_SEQNO_PR
                                       AND AUFNR   = V_ORDER_NO ;

                            END;

                    END;

                    --재고등록
                    BEGIN
                            INSERT INTO TB_INV001 (
                                WERKS,
                                STOR_LOC_CD,
                                IND_BCD,
                                MATNR,
                                LOC_CD,
                                LOT_NO,
                                MACH_CD,
                                MACHINE,
                                WRK_ORDR_NO,
                                WRK_ORDR_SEQNO,
                                ORDER_NO,
                                PRD_NO,
                                IN_MR_YN,
                                PRD_DT,
                                UNIT,
                                STCK_QTY,
                                WGT,
                                STCK_STA,
                                DOC_NO,
                                DOC_SEQNO,
                                DLFL,
                                REGDATE,
                                REGID
                            ) VALUES (
                                P_WERKS,
                                V_STOR_LOC_CD,
                                V_IND_BCD,
                                V_MATNR,
                                V_LOC_CD,
                                V_LOT_NO,
                                P_MACH_CD,
                                V_MACHINE,
                                V_WRK_ORDR_NO,
                                V_WRK_ORDR_SEQNO,
                                V_ORDER_NO,
                                '',
                                'N',
                                V_PRD_DT,
                                'EA',
                                V_PRFM_QTY,
                                V_WGT,
                                '00',
                                V_DOC_NO_PR,
                                V_DOC_SEQNO_PR,
                                'N',
                                V_DATE,
                                P_USERID
                            );
                    EXCEPTION
                        WHEN DUP_VAL_ON_INDEX  THEN
                            UPDATE TB_INV001 
                               SET STCK_QTY = NVL(STCK_QTY,0) + V_PRFM_QTY
                                 , WGT      = NVL(WGT,0)      + V_WGT
                            WHERE WERKS        = P_WERKS
                              AND STOR_LOC_CD  = V_STOR_LOC_CD
                              AND IND_BCD      = V_IND_BCD
                              ;
                    END;

                    -- 문서이력(1=실적)
                    -- 1=실적, 2=생산폐품, 3=영업폐품, 4=잔량폐품, 5=투입자재 소요량, 6=재고이전(위치), 7=재고이전(자재변경), 8=재고이전(재고실사), 9=LOT변경, 10=등급변경, 11=LOT병합, 12=LIFT출고, 20=오더완료
                    BEGIN
                        INSERT INTO TB_WRK021 (
                            DOC_NO,
                            DOC_SEQNO,
                            DOC_DIV,
                            WERKS,
                            MACH_CD,
                            WRK_ORDR_NO,
                            WRK_ORDR_SEQNO,
                            IND_BCD,
                            LOT_NO,
                            ORDER_NO,
                            CNL_YN,
                            REGDATE,
                            REGID
                        ) VALUES (
                            V_DOC_NO_PR,
                            V_DOC_SEQNO_PR,
                            1,
                            P_WERKS,
                            P_MACH_CD,
                            V_WRK_ORDR_NO,
                            V_WRK_ORDR_SEQNO,
                            V_IND_BCD,
                            V_LOT_NO,
                            V_ORDER_NO,
                            'N',
                            V_DATE,
                            P_USERID
                        );
                    EXCEPTION
                        WHEN DUP_VAL_ON_INDEX  THEN
                            V_YMCHK := 'N';
                    END;

                    --자재투입량 업데이트 (사용량, 재고량 -> 중량으로 업데이트 )
                    UPDATE TB_INV003
                       SET USE_QTY  = NVL(USE_QTY, 0) + V_WGT,
                           STCK_QTY = NVL(STCK_QTY, 0) - V_WGT,
                           UPDDATE  = V_DATE,
                           UPDID    = P_USERID
                     WHERE WERKS = P_WERKS
                       AND MACH_CD = P_MACH_CD
                       AND IND_BCD = V_IND_BCD_M;

                    V_DOC_NO := '' ;                   
                    V_DOC_NO := FN_GET_MDOCNO('M','IF130'); 
                    --V_DOC_SEQNO := V_DOC_SEQNO + 1; 

                    V_DOC_NO_INPUT := V_DOC_NO_INPUT||V_DOC_NO||',' ;

                    SELECT NVL(MAX(NVL(SEQNO,0)) + 1, 1)
                      INTO V_SEQ
                      FROM TB_INV010
                     WHERE WERKS    = P_WERKS
                       AND MACH_CD  = P_MACH_CD
                       AND MATNR    = V_MATNR
                       AND IND_BCD  = V_IND_BCD 
                       AND NVL(CNL_YN,'N') = 'N'
                       ;   

                    V_DOC_SEQNO := V_SEQ;

                    --자재 투입이력
                    INSERT INTO TB_INV010( WERKS, MACH_CD, MATNR, IND_BCD, SEQNO, WRK_ORDR_NO, WRK_ORDR_SEQNO,
                                           LOT_NO, IND_BCD_M, LOT_NO_M, MATNR_M, INP_DT, PRFM_DT,
                                           USE_QTY, UNIT, PCNT, WGT, CHG_FLG, STCK_KY, LOT_NUM,
                                           REGDATE, REGID, USE_DIV, DOC_NO, DOC_SEQNO, IND_BCD_C) 
                                VALUES(P_WERKS, P_MACH_CD, V_MATNR, V_IND_BCD, V_SEQ, V_WRK_ORDR_NO, V_WRK_ORDR_SEQNO,
                                        V_LOT_NO, V_IND_BCD_MR, V_LOT_NO_MR, V_MATNR_MR, V_PRD_DT, V_PRFM_DT,
                                        V_WGT, V_UNIT, V_PCNT, V_WGT, 'N', '', '', 
                                        V_DATE, P_USERID, '1', V_DOC_NO, V_DOC_SEQNO, V_IND_BCD_M);   

                    --자재투입이력 전송
                    SELECT SAP_WRK_CD  
                      INTO V_SAP_WRK_CD
                      FROM TB_MAS012
                     WHERE MACH_CD = P_MACH_CD;

                    BEGIN                    
                        SELECT ORDER_ITM_NO 
                          INTO V_ORDER_ITM_NO
                          FROM TB_SCH020
                         WHERE WERKS = P_WERKS
                           AND WRK_ORDR_NO = V_WRK_ORDR_NO
                           AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
                           AND MATNR = V_MATNR_M;

                    EXCEPTION WHEN NO_DATA_FOUND THEN
                        V_ORDER_ITM_NO := ' ';
                    END;

                    BEGIN
                            INSERT INTO TB_IFS008(AUFNR, POSNR, BUDAT, MATNR, MENGE, LGORT, CHARG,
                                                MDOCNO, MDOCSEQ, MAKE_DATE, MAKER, WORKCENTERCODE, WERKS)
                                        VALUES( V_ORDER_NO, V_ORDER_ITM_NO, V_PRFM_DT, V_MATNR_MR, V_WGT, V_STOR_LOC_CD_M, V_LOT_NO_MR,
                                                V_DOC_NO, V_DOC_SEQNO, V_DATE, V_SESS_USER_ID, V_SAP_WRK_CD, P_WERKS);

                            -- 문서이력(5=투입자재 소요량)
                            -- 1=실적, 2=생산폐품, 3=영업폐품, 4=잔량폐품, 5=투입자재 소요량, 6=재고이전(위치), 7=재고이전(자재변경), 8=재고이전(재고실사), 9=LOT변경, 10=등급변경, 11=LOT병합, 12=LIFT출고, 20=오더완료
                    END;

                    INSERT INTO TB_WRK021(DOC_NO, DOC_SEQNO, DOC_DIV, WERKS, MACH_CD,
                                        WRK_ORDR_NO, WRK_ORDR_SEQNO, IND_BCD, LOT_NO, ORDER_NO,
                                        CNL_YN, REGDATE, REGID)
                                VALUES(V_DOC_NO, V_DOC_SEQNO, 5, P_WERKS, P_MACH_CD,
                                        V_WRK_ORDR_NO, V_WRK_ORDR_SEQNO, V_IND_BCD, V_LOT_NO, V_ORDER_NO,
                                        'N', V_DATE, P_USERID);

                    -- LOT Trace
                    INSERT INTO TB_WRK008(WERKS,
                                        IND_BCD,
                                        IND_BCD_M,
                                        SEQNO,
                                        LOT_NO,
                                        MATNR,
                                        LOT_NO_M,
                                        MATNR_M,
                                        UNIT,
                                        PRFM_QTY,
                                        USE_QTY,
                                        WRK_ORDR_NO,
                                        WRK_ORDR_SEQNO,
                                        SUB_WRK_ORDR_NO,
                                        SUB_WRK_ORDR_SEQNO,
                                        MACH_CD,
                                        REGDATE,
                                        REGID)
                               VALUES(P_WERKS,
                                        V_IND_BCD,
                                        V_IND_BCD_M,
                                        1,
                                        V_LOT_NO,
                                        V_MATNR,
                                        V_LOT_NO_M,
                                        V_MATNR_M,
                                        V_UNIT,
                                        V_WGT,
                                        V_WGT,
                                        V_WRK_ORDR_NO,
                                        V_WRK_ORDR_SEQNO,
                                        V_JR_WRK_ORDR_NO,
                                        V_JR_WRK_ORDR_SEQNO,
                                        P_MACH_CD,
                                        V_DATE,
                                        P_USERID);

            END IF;

            --폐품등록
            IF NVL(V_DISPO_QTY, 0) > 0 THEN

                V_DOC_NO_SCR := FN_GET_MDOCNO('M', 'IF134');
                V_DOC_SEQNO_SCR := V_DOC_SEQNO_SCR + 1;

                V_DOC_NO_DISPO := V_DOC_NO_DISPO || V_DOC_NO_SCR||',';  

                IF V_IND_BCD IS NULL  THEN
                    --개별바코드
                    SP_GET_BARCODE_SEQ('IND', P_WERKS, 'C', V_MATNR, V_PRD_END_DTM, V_IND_BCD);
                    --SP_GET_BARCODE_SEQ('IND', P_WERKS, P_MACH_CD, V_MATNR, V_PRD_END_DTM, V_IND_BCD);
                END IF;

                BEGIN
                    INSERT INTO TB_WRK004 (
                        WERKS,
                        MACH_CD,
                        IND_BCD,
                        LOT_NO,
                        MATNR,
                        DISPO_CD,
                        WRK_ORDR_NO,
                        WRK_ORDR_SEQNO,
                        MMATNR,
                        IND_BCD_M,
                        LOT_NO_M,
                        UNIT,
                        DISPO_QTY,
                        MACHINE,
                        WGT,
                        PRD_STR_DATE,
                        PRD_END_DATE,
                        TM,
                        PRFM_DT,
                        WRK_CLASS,
                        WRK_SHIFT,
                        RUN_STA,
                        DOC_NO,
                        DOC_SEQNO,
                        RMK,
                        REGDATE,
                        REGID,
                        IND_BCD_C,
                        ORDER_NO
                    ) VALUES (
                        P_WERKS,
                        P_MACH_CD,
                        V_IND_BCD,
                        V_LOT_NO,
                        V_MATNR,
                        V_DISPO_CD,
                        V_WRK_ORDR_NO,
                        V_WRK_ORDR_SEQNO,
                        V_MATNR_MR,
                        V_IND_BCD_MR,
                        V_LOT_NO_MR,
                        'EA',
                        V_DISPO_QTY ,
                        '',
                        V_DISPO_WGT,
                        V_PRD_STR_DATE,
                        V_PRD_END_DATE,
                        '',
                        V_PRFM_DT,
                        P_WRK_CLASS,
                        P_WRK_SHIFT,
                        '02',
                        V_DOC_NO_SCR,
                        V_DOC_SEQNO_SCR,
                        V_RMK,
                        V_DATE,
                        P_USERID,
                        V_IND_BCD_M,
                        V_ORDER_NO
                    );

                EXCEPTION
                    WHEN DUP_VAL_ON_INDEX  THEN
                        UPDATE TB_WRK004  SET
                              DISPO_QTY = NVL(DISPO_QTY, 0) + V_DISPO_QTY
                             ,WGT       = NVL(WGT, 0)       + V_DISPO_WGT
                             ,IND_BCD_C = V_IND_BCD_M 
                        WHERE WERKS     = P_WERKS
                          AND MACH_CD   = P_MACH_CD
                          AND IND_BCD   = V_IND_BCD
                          AND LOT_NO    = V_LOT_NO
                          AND MATNR     = V_MATNR
                          AND DISPO_CD  = V_DISPO_CD
                          ;
                END;



                BEGIN
                            INSERT INTO TB_IFS012 (
                                    AUFNR,
                                    LOTNO,
                                    BUDAT,
                                    MATNR,
                                    SCRQTY,
                                    RSDQTY,
                                    MRSCQTY,
                                    SCRAPCODE,
                                    SCRAPREASON,
                                    LGORT,
                                    CHARG,
                                    MDOCNO,
                                    MDOCSEQ,
                                    MAKE_DATE,
                                    MAKER,
                                    VBELN,
                                    POSNR,
                                    WORKCENTERCODE,
                                    RUNTIME,
                                    SCRQTY_OP,
                                    SDATE,
                                    STIME,
                                    EDATE,
                                    ETIME
                                ) VALUES (
                                    V_ORDER_NO,
                                    V_LOT_NO,
                                    TO_CHAR(TO_DATE(V_PRFM_DT, 'YYYY-MM-DD'), 'YYYYMMDD'),
                                    V_MATNR_MR,
                                    V_DISPO_WGT, 
                                    0,
                                    0,
                                    V_DISPO_CD,
                                    V_DISPO_NM,
                                    V_STOR_LOC_CD_M,                    --'2000',
                                    V_LOT_NO_MR,
                                    V_DOC_NO_SCR,
                                    V_DOC_SEQNO_SCR,
                                    V_DATE,
                                    P_USERID,
                                    V_VBELN,
                                    V_POSNR,
                                    V_SAP_WRK_CD,
                                    0,
                                    0,
                                    TO_CHAR(V_PRD_STR_DATE,'YYYY-MM-DD'), 
                                    TO_CHAR(V_PRD_STR_DATE,'HH24:MI:SS'),
                                    TO_CHAR(V_PRD_END_DATE,'YYYY-MM-DD'), 
                                    TO_CHAR(V_PRD_END_DATE,'HH24:MI:SS')                    
                            );
                END;

                -- 문서이력(2=생산폐품)
                -- 1=실적, 2=생산폐품, 3=영업폐품, 4=잔량폐품, 5=투입자재 소요량, 6=재고이전(위치), 7=재고이전(자재변경), 8=재고이전(재고실사), 9=LOT변경, 10=등급변경, 11=LOT병합, 12=LIFT출고, 20=오더완료
                INSERT INTO TB_WRK021 (
                    DOC_NO,
                    DOC_SEQNO,
                    DOC_DIV,
                    WERKS,
                    MACH_CD,
                    WRK_ORDR_NO,
                    WRK_ORDR_SEQNO,
                    IND_BCD,
                    LOT_NO,
                    ORDER_NO,
                    CNL_YN,
                    REGDATE,
                    REGID
                ) VALUES (
                    V_DOC_NO_SCR,
                    V_DOC_SEQNO_SCR,
                    2,
                    P_WERKS,
                    P_MACH_CD,
                    V_WRK_ORDR_NO,
                    V_WRK_ORDR_SEQNO,
                    V_IND_BCD,
                    V_LOT_NO,
                    V_ORDER_NO,
                    'N',
                    V_DATE,
                    P_USERID
                );

                -- 자재투입량 업데이트 ( 사용량, 재고량, 폐품수량 -> 중량으로 업데이트)
                UPDATE TB_INV003
                   SET DISPO_QTY = NVL(DISPO_QTY, 0) + V_DISPO_WGT,
                       USE_QTY   = NVL(USE_QTY, 0)   + V_DISPO_WGT,
                       STCK_QTY  = NVL(STCK_QTY, 0)  - V_DISPO_WGT
                 WHERE WERKS   = P_WERKS
                   AND MACH_CD = P_MACH_CD
                   AND IND_BCD = V_IND_BCD_M;

            END IF;

--            --자재사용량 등록/LOT 추적이력
--            SP_REG_LOT_LOG_I01(P_WERKS, P_MACH_CD, V_MATNR, V_LOT_NO, V_IND_BCD, V_WRK_ORDR_NO, V_WRK_ORDR_SEQNO, V_PRFM_DT, V_WGT, '', P_USERID);

            --실적등록 시 영업폐품 계산
            IF V_OAUART_DIV = 'ZCOR' THEN
                IF NVL(V_PKCNT, 0) = 0 THEN
                    RS_CODE := 'E';
                    RS_MSG := '재단폭수 확인해주세요';
                    ROLLBACK;
                    RETURN;
                END IF;

                -- 재단 총 생산M = (실적중량 / 재단 폭수) / ( ( 평량 / 1000 ) * ( 재단 가로길이 / 1000))
                V_CA_ROLLCNT := ( V_WGT / V_PKCNT ) / (( V_BS_WGT / 1000 ) * ( V_WLEN / 1000 ));

                -- 재단영업수량 = ( 재단 평량 / 1000 ) * (M/R 지폭 - ( 재단 가로길이 * 재단 폭수 ) ) * L_CROLLCNT / 1000
                V_CA_WGT := ROUND((V_BS_WGT / 1000) *(V_MWIDTH - (V_WLEN * V_PKCNT)) * V_CA_ROLLCNT / 1000, 3);

                -- 재단 판매 오더 유형이 ZCOR 이면 재단 S/O , ZCOR가 아니면 밀롤 S/O  를 사용함
                V_VBELN_SDISPO := V_VBELN;
                V_POSNR_SDISPO := V_POSNR;
            ELSE
                IF NVL(V_MRCNT, 0) = 0 THEN
                    RS_CODE := 'E';
                    RS_MSG := '밀롤폭수 확인해주세요';
                    ROLLBACK;
                    RETURN;
                END IF;

                -- 재단 총 생산M = (실적중량 / 밀롤 폭수) / ( ( 평량 / 1000 ) * ( 재단 가로길이 / 1000))
                V_CA_ROLLCNT := ( V_WGT / V_MRCNT ) / (( V_BS_WGT / 1000 ) * ( V_WLEN / 1000 ));

                --재단영업수량 = ( 재단 평량 / 1000 ) * (M/R 지폭 - ( 재단 가로길이 * 밀롤 폭수 ) ) * L_CROLLCNT / 1000

                --V_WLEN := V_MWIDTH - 50;        -- 테스트용..
                V_CA_WGT := ROUND((V_BS_WGT / 1000) *(V_MWIDTH - (V_WLEN * V_MRCNT)) * V_CA_ROLLCNT / 1000, 3);

                -- 재단 판매 오더 유형이 ZCOR 이면 재단 S/O , ZCOR가 아니면 밀롤 S/O  를 사용함
                V_VBELN_SDISPO := V_VBELN_M;
                V_POSNR_SDISPO := V_POSNR_M;
            END IF;

            -- 22년 10월 1일 이전 생산은 영업폐품 처리 안함.
            IF SUBSTR(V_IND_BCD_M,6,1) = 'T' AND TO_CHAR(TO_DATE(V_PRFM_DT2, 'YYYYMMDD'), 'YYYYMMDD') < '20221001' THEN
                BEGIN
                    V_CA_ROLLCNT := 0;
                    V_CA_WGT := 0;
                END;
            END IF;

            IF V_CA_WGT > 0 THEN
                V_DOC_NO_SCR := FN_GET_MDOCNO('M', 'IF134');
                V_DOC_SEQNO_SCR := V_DOC_SEQNO_SCR + 1;
                --1:영업폐품, 2:잔량폐품

                V_DOC_NO_SDISPO := V_DOC_NO_SDISPO || V_DOC_NO_SCR||',';  

                INSERT INTO TB_WRK022 (
                        WERKS,
                        MACH_CD,
                        IND_BCD,
                        LOT_NO,
                        MATNR,
                        DISPO_CD,
                        WRK_ORDR_NO,
                        WRK_ORDR_SEQNO,
                        ORDER_NO,
                        MATNR_M,
                        IND_BCD_M,
                        LOT_NO_M,
                        ROLLCNT,
                        UNIT,
                        DISPO_QTY,
                        MACHINE,
                        WGT,
                        PRD_STR_DATE,
                        PRD_END_DATE,
                        TM,
                        PRFM_DT,
                        WRK_CLASS,
                        WRK_SHIFT,
                        RUN_STA,
                        DOC_NO,
                        DOC_SEQNO,
                        RMK,
                        REGDATE,
                        REGID
                    ) VALUES (
                        P_WERKS,
                        P_MACH_CD,
                        V_IND_BCD,
                        V_LOT_NO,
                        V_MATNR,
                        '900',
                        V_WRK_ORDR_NO,
                        V_WRK_ORDR_SEQNO,
                        V_ORDER_NO,
                        V_MATNR_M,
                        V_IND_BCD_M,
                        V_LOT_NO_M,
                        V_CA_ROLLCNT,
                        V_UNIT,
                        V_CA_WGT,
                        '',
                        V_CA_WGT,
                        '',
                        '',
                        '',
                        V_PRFM_DT,
                        P_WRK_CLASS,
                        P_WRK_SHIFT,
                        '02',
                        V_DOC_NO_SCR,
                        V_DOC_SEQNO_SCR,
                        V_RMK,
                        V_DATE,
                        P_USERID
                );


                BEGIN
                            INSERT INTO TB_IFS012 (
                                AUFNR,
                                LOTNO,
                                BUDAT,
                                MATNR,
                                SCRQTY,
                                RSDQTY,
                                MRSCQTY,
                                SCRAPCODE,
                                SCRAPREASON,
                                LGORT,
                                CHARG,
                                MDOCNO,
                                MDOCSEQ,
                                MAKE_DATE,
                                MAKER,
                                VBELN,
                                POSNR,
                                WORKCENTERCODE,
                                RUNTIME,
                                SCRQTY_OP,
                                SDATE,
                                STIME,
                                EDATE,
                                ETIME
                            ) VALUES (
                                V_ORDER_NO,
                                V_LOT_NO,
                                TO_CHAR(TO_DATE(V_PRFM_DT, 'YYYY-MM-DD'), 'YYYYMMDD'),
                                V_MATNR_MR,
                                0,
                                V_CA_WGT,
                                0,
                                '900',
                                '영업폐품',
                                V_STOR_LOC_CD_M,
                                V_LOT_NO_MR,
                                V_DOC_NO_SCR,
                                V_DOC_SEQNO_SCR,
                                V_DATE,
                                P_USERID,
                                V_VBELN_SDISPO,
                                V_POSNR_SDISPO,
                                V_SAP_WRK_CD,
                                0,
                                0,
                                TO_CHAR(V_PRD_STR_DATE,'YYYY-MM-DD'), 
                                TO_CHAR(V_PRD_STR_DATE,'HH24:MI:SS'),
                                TO_CHAR(V_PRD_END_DATE,'YYYY-MM-DD'), 
                                TO_CHAR(V_PRD_END_DATE,'HH24:MI:SS')                    
                            );
                END;

                -- 문서이력(3=영업폐품)
                -- 1=실적, 2=생산폐품, 3=영업폐품, 4=잔량폐품, 5=투입자재 소요량, 6=재고이전(위치), 7=재고이전(자재변경), 8=재고이전(재고실사), 9=LOT변경, 10=등급변경, 11=LOT병합, 12=LIFT출고, 20=오더완료
                INSERT INTO TB_WRK021 (
                    DOC_NO,
                    DOC_SEQNO,
                    DOC_DIV,
                    WERKS,
                    MACH_CD,
                    WRK_ORDR_NO,
                    WRK_ORDR_SEQNO,
                    IND_BCD,
                    LOT_NO,
                    ORDER_NO,
                    CNL_YN,
                    REGDATE,
                    REGID
                ) VALUES (
                    V_DOC_NO_SCR,
                    V_DOC_SEQNO_SCR,
                    3,              --영업폐품
                    P_WERKS,
                    P_MACH_CD,
                    V_WRK_ORDR_NO,
                    V_WRK_ORDR_SEQNO,
                    V_IND_BCD,
                    V_LOT_NO,
                    V_ORDER_NO,
                    'N',
                    V_DATE,
                    P_USERID
                );
            END IF;
        END LOOP;

        -- 수재단 작업완료 플래그 처리 
        IF V_SCACOM_YN = 'Y' THEN

            -- 작업지시가 완료인경우 TB_WRK011(작업장(설비)별 현재 진행현황) 테이블 업데이트 진행
            -- 작업진행중인 작업지시번호 -> 이전작업지시번호, 작업지시순번 -> 이전작업지시순번으로 이동

            UPDATE TB_WRK011
            SET
                MATNR = '',
                WRK_ORDR_NO = '',
                WRK_ORDR_SEQNO = '',
                ORDER_NO = '',
                LOT_NO = '',
                PRD_STR_DTM = V_PRD_END_DTM ,
                MACH_STA = 'N'    --상태(R :가동, S:비가동, N:대기중)
            WHERE
                MACH_CD = P_MACH_CD;

            -- 밀롤 생산량
            V_MWGT:= 0 ;

            SELECT  NVL(SUM(WGT),0)
              INTO  V_MWGT 
              FROM  TB_WRK002
             WHERE  WRK_ORDR_NO    = V_WRK_ORDR_NO_MR
               AND  WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO_MR
               AND  NVL(CNL_YN,'N') = 'N'
            ;   

            -- 수재단 생산량
            V_SWGT:= 0 ;
            SELECT  NVL(SUM(WGT),0)
              INTO  V_SWGT 
              FROM  TB_WRK002
             WHERE  WERKS    = P_WERKS
               AND  MACH_CD  = P_MACH_CD      
               AND  ORDER_NO = V_ORDER_NO
               AND  NVL(CNL_YN,'N')  = 'N'
            ;   

            -- 수재단 폐품생산량
            V_SDISPO_QTY := 0 ;

            SELECT NVL(SUM(WGT), 0) 
              INTO V_SDISPO_QTY
              FROM TB_WRK004
             WHERE WERKS    = P_WERKS
               AND MACH_CD  = P_MACH_CD      
               AND ORDER_NO = V_ORDER_NO
               AND NVL(CNL_YN,'N') = 'N'
               ;

            SELECT NVL(SUM(WGT), 0) 
              INTO V_MSDISPO_TOT
              FROM TB_WRK022
             WHERE WERKS    = P_WERKS
               AND MACH_CD  = P_MACH_CD      
               AND ORDER_NO = V_ORDER_NO
               AND DISPO_CD       = '900'
               AND NVL(CNL_YN,'N') = 'N'
               ;

            V_WGT_RMD := V_MWGT - V_SWGT - V_SDISPO_QTY - V_MSDISPO_TOT;


            --V_WGT_RMD := V_MWGT - V_SWGT - V_SDISPO_QTY;

            IF V_WGT_RMD > 0 THEN   
                V_DOC_NO_SCR    := FN_GET_MDOCNO('M', 'IF134');
                V_DOC_SEQNO_SCR :=  V_DOC_SEQNO_SCR + 1;

                  V_DOC_NO_SDISPO := V_DOC_NO_SDISPO || V_DOC_NO_SCR||',';

                  IF (SUBSTR(V_IND_BCD_M,6,1) = 'T' AND TO_CHAR(TO_DATE(V_PRFM_DT2, 'YYYYMMDD'), 'YYYYMMDD') > '20220930') OR (SUBSTR(V_IND_BCD_M,6,1) <> 'T') THEN
                        BEGIN
                            INSERT INTO TB_IFS012( AUFNR, LOTNO, BUDAT, MATNR, SCRQTY, RSDQTY, MRSCQTY, SCRAPCODE, SCRAPREASON,
                                                     LGORT, CHARG, SDATE, STIME, EDATE, ETIME,
                                                     MDOCNO, MDOCSEQ, MAKE_DATE, MAKER, RUNTIME, VBELN, POSNR, WORKCENTERCODE, SCRQTY_OP)
                                            VALUES( V_ORDER_NO, V_LOT_NO, TO_CHAR(TO_DATE(V_PRFM_DT, 'YYYY-MM-DD'), 'YYYYMMDD'), V_MATNR_MR, 0, 0, V_WGT_RMD, '910', '잔량폐품',
                                                    V_STOR_LOC_CD_M, V_LOT_NO_MR, TO_CHAR(V_PRD_STR_DATE,'YYYY-MM-DD'), TO_CHAR(V_PRD_STR_DATE,'HH24:MI:SS'), TO_CHAR(V_PRD_END_DATE,'YYYY-MM-DD'),  TO_CHAR(V_PRD_END_DATE,'HH24:MI:SS'), 
                                                    V_DOC_NO_SCR, V_DOC_SEQNO_SCR, V_DATE, P_USERID, 0, V_OVBELN /*V_VBELN_SDISPO*/, V_OPOSNR /*V_POSNR_SDISPO*/, V_SAP_WRK_CD, 0);  
                        END;
                  END IF;

                  INSERT INTO TB_WRK022(WERKS, MACH_CD, IND_BCD, LOT_NO, MATNR, DISPO_CD, WRK_ORDR_NO, WRK_ORDR_SEQNO,
                                        ORDER_NO, MATNR_M, IND_BCD_M, LOT_NO_M, UNIT, ROLLCNT, DISPO_QTY, MACHINE, WGT,
                                        PRFM_DT, WRK_CLASS, WRK_SHIFT, RUN_STA, DOC_NO, DOC_SEQNO, RMK, REGDATE, REGID,PRE_ORDER_NO)
                              VALUES   (P_WERKS, P_MACH_CD, V_IND_BCD, V_LOT_NO, V_MATNR, '910', V_WRK_ORDR_NO, V_WRK_ORDR_SEQNO,
                                        V_ORDER_NO, V_MATNR_MR, V_IND_BCD_MR, V_LOT_NO_MR, V_UNIT, 0, V_WGT_RMD, '', V_WGT_RMD,
                                        V_PRFM_DT,P_WRK_CLASS, P_WRK_SHIFT, '02', V_DOC_NO_SCR, V_DOC_SEQNO_SCR, V_RMK, V_DATE, P_USERID,V_PRE_ORDER_NO);

                  -- 문서이력(4=잔량폐품)
                  -- 1=실적, 2=생산폐품, 3=영업폐품, 4=잔량폐품, 5=투입자재 소요량, 6=재고이전(위치), 7=재고이전(자재변경), 8=재고이전(재고실사), 9=LOT변경, 10=등급변경, 11=LOT병합, 12=LIFT출고, 20=오더완료
                  INSERT INTO TB_WRK021(DOC_NO, DOC_SEQNO, DOC_DIV, WERKS, MACH_CD, WRK_ORDR_NO, WRK_ORDR_SEQNO,
                                        IND_BCD, LOT_NO, ORDER_NO, CNL_YN, REGDATE, REGID)
                                VALUES(V_DOC_NO_SCR, V_DOC_SEQNO_SCR, 4, P_WERKS, P_MACH_CD, V_WRK_ORDR_NO, V_WRK_ORDR_SEQNO,
                                        V_IND_BCD, V_LOT_NO, V_ORDER_NO, 'N', V_DATE, P_USERID);                               

            END IF;

--            UPDATE TB_SCH017
--               SET  COMP_YN = 'Y'
--            WHERE WERKS         = P_WERKS
--              AND ORDER_NO      = V_ORDER_NO
--              AND MAN_CUT_YN    = 'X' 
--              ;

        ELSE
            UPDATE TB_WRK011
            SET
                PRD_STR_DTM = V_PRD_END_DTM
            WHERE
                MACH_CD = P_MACH_CD;

        END IF;

        V_DOC_NO_DISPO  := SUBSTR(V_DOC_NO_DISPO, 1,LENGTH(V_DOC_NO_DISPO)-1);
        V_DOC_NO_PRFM   := SUBSTR(V_DOC_NO_PRFM, 1,LENGTH(V_DOC_NO_PRFM)-1);
        V_DOC_NO_INPUT  := SUBSTR(V_DOC_NO_INPUT, 1,LENGTH(V_DOC_NO_INPUT)-1);
        V_DOC_NO_SDISPO := SUBSTR(V_DOC_NO_SDISPO, 1,LENGTH(V_DOC_NO_SDISPO)-1);
        RS_IND_BCD      := SUBSTR(RS_IND_BCD,1,LENGTH(RS_IND_BCD)-1);   

        IF LENGTH(V_DOC_NO_DISPO) > 0   THEN   --폐품
             IF (SUBSTR(V_IND_BCD_M,6,1) = 'T' AND TO_CHAR(TO_DATE(V_PRFM_DT2, 'YYYYMMDD'), 'YYYYMMDD') > '20220930') OR (SUBSTR(V_IND_BCD_M,6,1) <> 'T') THEN
                 BEGIN
                     --SAP FUNC ID
                     SELECT RFCFN
                       INTO RS_DISPO_RFCFN
                       FROM TB_ITFMA
                      WHERE 1=1
                        AND IFID = 'MES_IF_134';   --생산오더별 실적 취소 TXN

                     --인터페이스 파라미터
                     OPEN CUR_3 FOR
                     SELECT 'MES_IF_134' AS I_IF_ID
                          , 'M' || LTRIM(RTRIM(TO_CHAR(SEQ_GET_IFR_KEY.NEXTVAL, '00000000000000000000000000000'))) AS I_IF_KEY
                       FROM dual;

                     --인터페이스 상세 파라미터
                     V_SQL := FN_IF_QUERY('MES_IF_134', V_DOC_NO_DISPO );
                     OPEN CUR_4 FOR V_SQL;
                END;
            END IF;
        END IF ;  

        IF LENGTH(V_DOC_NO_PRFM) > 0   THEN   --실적
             --인터페이스 파라미터
             IF (SUBSTR(V_IND_BCD_M,6,1) = 'T' AND TO_CHAR(TO_DATE(V_PRFM_DT2, 'YYYYMMDD'), 'YYYYMMDD') > '20220930') OR (SUBSTR(V_IND_BCD_M,6,1) <> 'T') THEN
                 BEGIN
                     --SAP FUNC ID
                     SELECT RFCFN
                       INTO RS_PRFM_RFCFN
                       FROM TB_ITFMA
                      WHERE 1=1
                        AND IFID = 'MES_IF_127';   --생산오더별 재단 실적 

                        OPEN CUR_1 FOR
                         SELECT 'MES_IF_127' AS I_IF_ID
                              , 'M' || LTRIM(RTRIM(TO_CHAR(SEQ_GET_IFR_KEY.NEXTVAL, '00000000000000000000000000000'))) AS I_IF_KEY
                           FROM dual;

                     --인터페이스 상세 파라미터
                     V_SQL := FN_IF_QUERY('MES_IF_127', V_DOC_NO_PRFM);
                     OPEN CUR_2 FOR V_SQL;
                END;
            END IF;

        END IF ;  

        IF LENGTH(V_DOC_NO_INPUT) > 0   THEN   --투입량
             --인터페이스 파라미터
             IF (SUBSTR(V_IND_BCD_M,6,1) = 'T' AND TO_CHAR(TO_DATE(V_PRFM_DT2, 'YYYYMMDD'), 'YYYYMMDD') > '20220930') OR (SUBSTR(V_IND_BCD_M,6,1) <> 'T') THEN
                 BEGIN
                     --SAP FUNC ID
                     SELECT RFCFN
                       INTO RS_INPUT_RFCFN
                       FROM TB_ITFMA
                      WHERE 1=1
                        AND IFID = 'MES_IF_130';   --생산오더별 실적 취소 TXN

                     OPEN CUR_5 FOR
                     SELECT 'MES_IF_130' AS I_IF_ID
                          , 'M' || LTRIM(RTRIM(TO_CHAR(SEQ_GET_IFR_KEY.NEXTVAL, '00000000000000000000000000000'))) AS I_IF_KEY
                       FROM dual;

                     --인터페이스 상세 파라미터
                     V_SQL := FN_IF_QUERY('MES_IF_130', V_DOC_NO_INPUT);
                     OPEN CUR_6 FOR V_SQL;
                END;
            END IF;

        END IF ;  

        IF LENGTH(V_DOC_NO_SDISPO) > 0   THEN   --영업폐품
             IF (SUBSTR(V_IND_BCD_M,6,1) = 'T' AND TO_CHAR(TO_DATE(V_PRFM_DT2, 'YYYYMMDD'), 'YYYYMMDD') > '20220930') OR (SUBSTR(V_IND_BCD_M,6,1) <> 'T') THEN
                 BEGIN
                     --SAP FUNC ID
                     SELECT RFCFN
                       INTO RS_SDISPO_RFCFN
                       FROM TB_ITFMA
                      WHERE 1=1
                        AND IFID = 'MES_IF_134';   --생산오더별 실적 취소 TXN

                     --인터페이스 파라미터
                     OPEN CUR_7 FOR
                     SELECT 'MES_IF_134' AS I_IF_ID
                          , 'M' || LTRIM(RTRIM(TO_CHAR(SEQ_GET_IFR_KEY.NEXTVAL, '00000000000000000000000000000'))) AS I_IF_KEY
                       FROM dual;

                     --인터페이스 상세 파라미터
                     V_SQL := FN_IF_QUERY('MES_IF_134', V_DOC_NO_SDISPO );
                     OPEN CUR_8 FOR V_SQL;
                END;
            END IF;
        END IF ;  

            IF CUR_1%ISOPEN = FALSE THEN
                    OPEN CUR_1 FOR SELECT 1 FROM dual;
            END IF;

            IF CUR_2%ISOPEN = FALSE THEN
                    OPEN CUR_2 FOR SELECT 1 FROM dual;
            END IF;

            IF CUR_3%ISOPEN = FALSE THEN
                    OPEN CUR_3 FOR SELECT 1 FROM dual;
            END IF;

            IF CUR_4%ISOPEN = FALSE THEN
                    OPEN CUR_4 FOR SELECT 1 FROM dual;
            END IF;

            IF CUR_5%ISOPEN = FALSE THEN
                    OPEN CUR_5 FOR SELECT 1 FROM dual;
            END IF;

            IF CUR_6%ISOPEN = FALSE THEN
                    OPEN CUR_6 FOR SELECT 1 FROM dual;
            END IF;

            IF CUR_7%ISOPEN = FALSE THEN
                    OPEN CUR_7 FOR SELECT 1 FROM dual;
            END IF;

            IF CUR_8%ISOPEN = FALSE THEN
                    OPEN CUR_8 FOR SELECT 1 FROM dual;
            END IF;

        RS_CODE := 'S';
        COMMIT;
        --예외처리(CATCH)
    EXCEPTION
        WHEN E_EXCEPTION_USER THEN
            -- 에러 내역 SET
            E_SQL_ERR_CD := SQLCODE;
            E_SQL_ERR_MSG := SUBSTRB(SQLERRM, 1, 300);
            ROLLBACK;
            SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);
            RS_CODE := 'E';
            RS_MSG := SQLERRM;
            RETURN;
        WHEN OTHERS THEN
            E_SQL_ERR_CD := SQLCODE;
            E_SQL_ERR_MSG := 'EXCEPTION OTHER ERROR. ['
                             || SUBSTR(SQLERRM, 1, 500)
                             || ']';
            ROLLBACK;
--            RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);
        RAISE;

            RS_CODE := 'E';
            RS_MSG := SQLERRM;
            RETURN;
            --예외처리 종료
    END;
END;

/
