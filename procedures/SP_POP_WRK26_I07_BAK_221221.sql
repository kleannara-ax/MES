
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_POP_WRK26_I07_BAK_221221" 
(
    P_WERKS          IN     VARCHAR2 	            ,        --플랜트    
    P_MACH_CD        IN     VARCHAR2 	            ,        --설비코드    
    P_WRK_ORDR_NO    IN     VARCHAR2                ,        --재단작업지시번호    
    P_WRK_ORDR_SEQNO IN     NUMBER                  ,        --재단작업지시번호순번
    P_WRK_LIST       IN     CLOB                    ,
    P_WRK_CLASS      IN     VARCHAR2                ,
    P_WRK_SHIFT      IN     VARCHAR2                ,
    P_USERID         IN     VARCHAR2                ,        --USER ID    
    P_IND_BCD        IN     VARCHAR2                ,        --        
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
    CUR_7            OUT SYS_REFCURSOR              ,        --영업+잔량 폐품
    CUR_8            OUT SYS_REFCURSOR
)
/*==============================================================================
 * PROGRAM ID    : WRK26{호출 프로그램 ID 기술}
 * PROGRAM NAME  : 수입밀롤 재단 실적등록
 * VERSION       : 1.0.0{최종 버전 기술}
 * DESCRIPTION   : 수입밀롤 재단 실적등록
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
    --프로그램 ID : 수입밀롤 재단 실적등록
    V_PRG_NM            VARCHAR2(100) := 'SP_POP_WRK26_I07';     -- PROCEDURE NAME
    V_PLT_CD            VARCHAR2(2) := '99'; --PLANTCODE TEST
    V_SESS_USER_ID      VARCHAR2(20) := P_USERID; --USERID
    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER EXCEPTION;
    E_SQL_ERR_CD        NUMBER(5) := 0;
    E_SQL_ERR_MSG       VARCHAR2(4000);
    V_JR_WRK_ORDR_NO    TB_WRK011.WRK_ORDR_NO%TYPE;			--점보롤작업지시번호
    V_JR_WRK_ORDR_SEQNO TB_WRK011.WRK_ORDR_SEQNO%TYPE;		--점보롤작업지시번호순번
    -- JSON을 위한 변수선언 영역
    V_JSON              JSON_OBJECT_T;
    V_ARR_LIST          JSON_ARRAY_T;
    V_OBJ               JSON_OBJECT_T;
    V_WRK_ORDR_NO       TB_WRK002.WRK_ORDR_NO%TYPE;			--작업지시번호
    V_WRK_ORDR_SEQNO    TB_WRK002.WRK_ORDR_SEQNO%TYPE;		--작업지시번호순번
    V_WIDTH             TB_WRK002.WIDTH%TYPE;				--실지폭
    V_ROLLCNT           TB_WRK002.ROLLCNT%TYPE;				--권치수
    V_WGT               TB_WRK002.WGT%TYPE;					--중량
    V_EA                TB_WRK002.WGT%TYPE;					--갯수
    V_DISPO_CD          TB_WRK004.DISPO_CD%TYPE;			--폐품코드
    V_DISPO_WGT         TB_WRK004.WGT%TYPE;					--폐품중량
    V_PRD_STR_DATE      TB_WRK002.PRD_STR_DATE%TYPE;		--시작시간   
    V_PRD_END_DATE      TB_WRK002.PRD_END_DATE%TYPE;		--시작시간   
    V_RMK               TB_WRK002.RMK%TYPE;					--비고
    --PARAMETER변수 처리
    V_DOC_NO            VARCHAR2(20);
    V_DOC_SEQNO         NUMBER;
    V_DOC_NO_SCR        VARCHAR2(20);
    V_DOC_SEQNO_SCR     NUMBER;

    V_DOC_NO_DISPO      VARCHAR2(500) := '';
    V_DOC_NO_SDISPO     VARCHAR2(500) := '';
    V_DOC_NO_PRFM       VARCHAR2(500) := '';
    V_DOC_NO_INPUT      VARCHAR2(500) := '';

    V_ORDER_NO          TB_WRK002.ORDER_NO%TYPE;					--오더번호
    V_PRE_ORDER_NO      TB_WRK002.ORDER_NO%TYPE;					--오더번호
    V_IND_BCD           TB_WRK002.IND_BCD%TYPE;					    --개별바코드
    V_LOT_NO            TB_WRK002.LOT_NO%TYPE;					    --LOT NO
    V_LOT_NO_PRE        TB_WRK002.LOT_NO%TYPE;					    --이전 LOT NO
    V_PRD_STR_DTM       VARCHAR2(20);
    V_PRD_END_DTM       VARCHAR2(20);
    V_ORD_PRD_STR_DTM   VARCHAR2(20);                               --작업지시 시작일시
    V_VBELN             TB_SCH017.VBELN%TYPE;					    --판매문서번호
    V_POSNR             TB_SCH017.POSNR%TYPE;					    --판매문서 아이템번호
    V_OVBELN            TB_SCH017.OVBELN%TYPE;					    --판매문서번호
    V_OPOSNR            TB_SCH017.OPOSNR%TYPE;					    --판매문서 아이템번호
    V_VBELN_M           TB_SCH016.VBELN%TYPE;					    --밀롤 판매문서번호
    V_POSNR_M           TB_SCH016.POSNR%TYPE;					    --밀롤 판매문서 아이템번호
    V_OVBELN_M          TB_SCH016.OVBELN%TYPE;					    --밀롤 판매문서번호
    V_OPOSNR_M          TB_SCH016.OPOSNR%TYPE;					    --밀롤 판매문서 아이템번호
    V_VBELN_SDISPO      TB_SCH017.VBELN%TYPE;					    --영업폐품시 사용할 판매문서번호
    V_POSNR_SDISPO      TB_SCH017.POSNR%TYPE;					    --영업폐품시 사용할 판매문서 아이템번호
    V_OAUART_DIV        TB_SCH017.OAUART_DIV%TYPE;					--판매문서번호
    V_MATNR             TB_WRK002.MATNR%TYPE;					    --자재코드
    V_WRK_SEQ           TB_WRK002.WRK_SEQ%TYPE;					    --생산순번
    V_MACHINE           TB_WRK002.MACHINE%TYPE;					    --생산회기
    V_TO_MACHINE        TB_WRK002.TO_MACHINE%TYPE;					--생산회기
    V_PRFM_DT           TB_WRK002.PRFM_DT%TYPE;					    --생산실적일
    V_PRD_DT            TB_WRK002.PRD_DT%TYPE;					    --생산일
    V_DSTBT_DDLIN       TB_WRK002.DSTBT_DDLIN%TYPE;					--유통기간    
    V_TM                TB_WRK002.TM%TYPE;					        --작업시간
    V_UNIT              TB_WRK002.UNIT%TYPE;					    --단위
    V_PRD_NO            TB_WRK002.PRD_NO%TYPE;					    --생산번호
    V_PRFM_QTY          TB_WRK002.PRFM_QTY%TYPE;
    V_PRFM_PLT          NUMBER;                                     -- 파렛트 수
    V_LOT_BUF           TB_SCH017.LOT_BUF%TYPE;					    --이전LOT NO
    V_IND_BCD_M         TB_WRK002.IND_BCD%TYPE;					    --밀롤 개별바코드
    V_IND_BCD_C         TB_WRK002.IND_BCD%TYPE;					    --밀롤 개별바코드
    V_MATNR_M           TB_WRK002.MATNR%TYPE;					    --밀롤 자재코드
    V_LOT_NO_M          TB_WRK002.LOT_NO%TYPE;					    --밀롤 LOT NO
    V_WRK_TM            NUMBER;                                     --작업시간(분)
    V_ORD_TM            NUMBER;                                     --오더 작업시간(분)
    V_ORD_ABN_TIME      NUMBER;                                     --비가동 시간(분)
    V_SAP_WRK_CD        TB_MAS012.SAP_WRK_CD%TYPE;                  --SAP작업장코드
    V_TT_WLEN           TB_SCH017.VLEN%TYPE;                        --가로길이(실재단규격) 수재단사용
    V_TT_VLEN           TB_SCH017.WLEN%TYPE;                        --세로길이(실재단규격)  수재단사용
    V_QTY               NUMBER;                                     --KG수량

    V_LINE              TB_MAS012.LINE%TYPE;                        --라인
    V_ORDER_NUM         VARCHAR2(10);                               --생산지시번호
    V_ORDER_SEQ         VARCHAR2(10);                               --생산지시순번
    V_PCODE             TB_SCH016.PCODE%TYPE;                       --지종
    V_PCODE_NM          VARCHAR2(50);                               --지종명
    V_BS_WGT            TB_SCH017.BS_WGT%TYPE;                      --평량
    --V_ROUTE             TB_SCH017.ROUTE%TYPE;                       --항차
    V_KUNNR             TB_SCH017.KUNNR%TYPE;                       --거래처
    V_KUNNRT            TB_SCH017.KUNNRT%TYPE;                      --거래처명    
    V_REMARK            TB_SCH017.ORDER_RMK%TYPE;                   --오더비고
    V_VLEN              TB_SCH017.VLEN%TYPE;                        --세로길이
    V_WLEN              TB_SCH017.WLEN%TYPE;                        --가로길이
    V_VLEN_CAL          TB_SCH017.VLEN%TYPE;                        --세로길이 계산용 (수재단 이동인 경우는 수재단 세로길이)
    V_WLEN_CAL          TB_SCH017.WLEN%TYPE;                        --가로길이 계산용 (수재단 이동인 경우는 수재단 가로길이)
    V_PACKTYPE          TB_SCH018.PACKTYPE%TYPE;                    --포장방식
    V_PACKTYPE_NM       VARCHAR2(20);                               --포장방식
    --V_PLT_PER_CNT       TB_SCH017.PLT_PER_CNT%TYPE;                 --팔레트당연수
    --V_IN_PER_CNT        TB_SCH017.IN_PER_CNT%TYPE;                  --속당매수
    --V_IN_CNT            NUMBER;                                     --속수
    V_USER_NM           VARCHAR2(20);                               --작업자명
    V_NTN_NM            VARCHAR2(50);                               --국가명
    V_PRFM_GTHR_YN      VARCHAR2(1);                                --실적집계여부
    V_DATE              DATE := SYSDATE;
    --V_JMACHINE          VARCHAR2(10);                               --점보롤 생산호기
    V_LOC_CD            VARCHAR2(10);                               --로케이션정보
    V_STOR_LOC_CD       VARCHAR2(10);
    V_STOR_LOC_CD_M     VARCHAR2(10);
    V_LOOP_CNT          NUMBER;
    V_WGT_T             NUMBER(13, 3);                              --밀롤 현재생산량  
    V_DISPO_WGT_T       NUMBER(13, 3);                              --밀롤 현재폐품량  
    --V_PRFM_QTY1         NUMBER(13, 3);                              --밀롤 누적생산량
    V_DISPO_QTY1        NUMBER(13, 3);                              --밀롤 폐품수량(연수)
    V_DISPO_WGT1        NUMBER(13, 3);                              --밀롤 폐품중량
    V_DISPO_CD1         VARCHAR2(10);                               --밀롤 폐품코드
    V_DISPO_NM1         VARCHAR2(50);                               --밀롤 폐품코드
    V_DISPO_QTY2        NUMBER(13, 3);                              --밀롤 폐품수량(연수)
    V_DISPO_WGT2        NUMBER(13, 3);                              --밀롤 폐품중량
    V_DISPO_CD2         VARCHAR2(10);                               --밀롤 폐품코드
    V_DISPO_NM2         VARCHAR2(50);                               --밀롤 폐품코드
    V_CACOM_YN          VARCHAR2(1);                                --재단완료여부
    V_LAST_YN           VARCHAR2(1);                                --마지막품목여부
    V_MOVE_YN           VARCHAR2(1);                                --수재단이동여부    
    V_ORD_STR_DATE      VARCHAR2(10);
    V_ORD_STR_TIME      VARCHAR2(10);
    V_ORD_END_DATE      VARCHAR2(10);
    V_ORD_END_TIME      VARCHAR2(10);
    V_WRK_ORDR_NO_M     TB_SCH017.WRK_ORDR_NO%TYPE;
    V_WRK_ORDR_SEQNO_M  TB_SCH017.WRK_ORDR_SEQNO%TYPE;
    V_PKCNT             TB_SCH017.PKCNT%TYPE;                       --재단폭수
    V_MRCNT             TB_SCH016.MRCNT%TYPE;                       --밀롤폭수
    V_MWIDTH            TB_SCH016.MWIDTH_INPUT%TYPE;                --밀롤지폭
    V_CA_WGT            NUMBER;
    V_CA_ROLLCNT        NUMBER;
   -- T_CWGT               NUMBER(13, 3);                             --재단 생산량
   -- T_CDISPO             NUMBER(13, 3);                             --재단 폐품량
   -- T_CSDISPO            NUMBER(13, 3);                             --재단 영업폐품
   -- T_MDISPO             NUMBER(13, 3);                             --밀롤 폐품량
    T_MSDISPO            NUMBER(13, 3);                             --밀롤 영업폐품
    --T_MREST              NUMBER(13, 3);                             --밀롤 잔량
    --T_ALLWGT             NUMBER(13, 3);                             --재단 총생산량
    --T_MWGT               NUMBER(13, 3);                             --밀롤 생산량
    --T_CREST              NUMBER(13, 3);                             --재단 잔량
    V_SQL                VARCHAR2(4000);    
    V_ORDER_ITM_NO          VARCHAR2(10);    
    V_WGT_RMD               NUMBER;                                 --잔량(영업폐품) 중량
    V_DISPO_QTY            NUMBER(13,3);     
    V_WO_NO              TB_SCH017.WRK_ORDR_NO%TYPE;                --수재단 작업지시번호
    V_MWGT                 NUMBER(13,3);
    V_SWGT                 NUMBER(13,3);
    V_SDISPO_QTY           NUMBER(13,3);
    V_YMCHK                     TB_MAS011.YMCHK%TYPE;   --실적등록 가능 여부
    V_CNT                  NUMBER;
BEGIN
    BEGIN
        V_WGT_T := 0;
        V_DISPO_WGT_T := 0;
        V_DOC_SEQNO_SCR   := 0 ; 
        V_DOC_SEQNO       := 0 ;
        V_DOC_NO_DISPO    := '';
        V_DOC_NO_PRFM     := '';
        V_DOC_NO_INPUT    := '';
        V_DOC_NO_SDISPO   := '';

        V_WRK_ORDR_NO := P_WRK_ORDR_NO;
        V_WRK_ORDR_SEQNO := P_WRK_ORDR_SEQNO;

        --JSON 데이터 수신
        V_JSON := JSON_OBJECT_T.PARSE(P_WRK_LIST); -- 전체 데이터

        V_ARR_LIST := V_JSON.GET_ARRAY('list');
        --작업시작일시, 작업종료일시, 가동시간, 가로길이, 세로길이
        --실적수량(연수), 중량, 폐품연수1, 폐품중량1, 폐품사유1, 폐품연수2, 폐품중량2, 폐품사유2
        --비고, 재단완료, 마지막(품목교체), 수재단이동, 밀롤개별바코드, 밀롤자재코드, 밀롤 LOTNO, 밀롤작업지시, 밀롤 작업지시순번

        SELECT
            S017.ORDER_NO,
            S017.MATNR,
            S017.VBELN,
            S017.POSNR,
            S017.OVBELN,
            S017.OPOSNR,
            S017.MACHINE,
            S017.TO_MACHINE,
            S017.LOT_BUF,
            S017.PRD_STR_DTM,
            S017.UNIT,
            --S017.ORDER_DIV,
            S017.OAUART_DIV,
            S017.PCODE,
            S017.BS_WGT,
            S017.KUNNR,
            S017.KUNNRT,
            S017.ORDER_RMK,
            S017.VLEN,
            S017.WLEN,
            S017.PKCNT,
            S009.PACKTYPE,
            S016.WRK_ORDR_NO,
            S016.WRK_ORDR_SEQNO,
            S017.PRE_ORDER_NO
            
        INTO
            V_ORDER_NO,
            V_MATNR,
            V_VBELN,
            V_POSNR,
            V_OVBELN,
            V_OPOSNR,
            V_MACHINE,
            V_TO_MACHINE,
            V_LOT_BUF,
            V_ORD_PRD_STR_DTM,
            V_UNIT,
            V_OAUART_DIV,
            V_PCODE,
            V_BS_WGT,
            V_KUNNR,
            V_KUNNRT,
            V_REMARK,
            V_VLEN,
            V_WLEN,
            V_PKCNT,
            V_PACKTYPE,
            V_JR_WRK_ORDR_NO,
            V_JR_WRK_ORDR_SEQNO,
            V_PRE_ORDER_NO
            
        FROM
            TB_SCH017 S017,    --작업지시 재단
            --TB_SCH018 S018,    --작업지시 포장
            TB_SCH009 S009,    --작업지시 포장
            TB_SCH016 S016     --작업지시 밀롤
        WHERE
                S017.PRE_ORDER_NO  = S016.ORDER_NO (+)
            --AND S017.ORDER_NO      = S018.PRE_ORDER_NO(+)     
            AND S017.ORDER_NO      = S009.FRAUFNR(+)     
            AND S017.WRK_ORDR_NO    = P_WRK_ORDR_NO
            AND S017.WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO
            --AND NVL(S017.DLFL,'N') = 'N'  --삭제지시자 X='삭제' , N=정상오더                      
            --AND NVL(S016.DLFL,'N') = 'N'  --삭제지시자 X='삭제' , N=정상오더
            AND NVL(S017.USE_YN, 'Y') = 'Y'
            --AND NVL(S016.USE_YN, 'Y') = 'Y'
            ;


        V_LOOP_CNT := V_ARR_LIST.GET_SIZE;
        V_CNT  := 0 ;
        FOR I IN 0..V_ARR_LIST.GET_SIZE - 1 LOOP
            V_OBJ := TREAT(V_ARR_LIST.GET(I) AS JSON_OBJECT_T);
            V_OBJ := TREAT(V_OBJ.GET('map') AS JSON_OBJECT_T);
            V_PRD_STR_DTM := V_OBJ.GET_STRING('PRD_STR_DATE');            --작업시작일시
            V_PRD_END_DTM := V_OBJ.GET_STRING('PRD_END_DATE');            --작업종료일시시
            V_PRFM_QTY := V_OBJ.GET_STRING('PRFM_QTY');                --실적수량(연수)
            V_PRFM_PLT := V_OBJ.GET_STRING('PRFM_PLT');                --팔레트수량            
            V_TM := TO_NUMBER(V_OBJ.GET_STRING('TM'));                      --가동시간(분)
            V_WLEN := TO_NUMBER(V_OBJ.GET_STRING('WLEN'));         --가로길이
            V_VLEN := TO_NUMBER(V_OBJ.GET_STRING('VLEN'));         --세로길이
            V_BS_WGT := V_OBJ.GET_STRING('BS_WGT');                  --평량
            V_TT_WLEN := V_OBJ.GET_STRING('TT_WLEN');                 --가로길이(실재단규격) 수재단사용
            V_TT_VLEN := V_OBJ.GET_STRING('TT_VLEN');                 --세로길이(실재단규격)  수재단사용

            V_DISPO_QTY1 := TO_NUMBER(V_OBJ.GET_STRING('DISPO_QTY1'));   --페품연수
            V_DISPO_WGT1 := TO_NUMBER(V_OBJ.GET_STRING('DISPO_WGT1'));   --폐품중량
            V_DISPO_CD1 := V_OBJ.GET_STRING('DISPO_CD1');               --폐품코드 
            V_DISPO_NM1 := V_OBJ.GET_STRING('DISPO_NM1');               --폐품코드명 
            V_DISPO_QTY2 := TO_NUMBER(V_OBJ.GET_STRING('DISPO_QTY2'));   --페품연수
            V_DISPO_WGT2 := TO_NUMBER(V_OBJ.GET_STRING('DISPO_WGT2'));   --폐품중량
            V_DISPO_CD2 := V_OBJ.GET_STRING('DISPO_CD2');               --폐품코드 
            V_DISPO_NM2 := V_OBJ.GET_STRING('DISPO_NM2');               --폐품코드명
            V_RMK := V_OBJ.GET_STRING('RMK');                           --비고
            V_CACOM_YN := V_OBJ.GET_STRING('CACOM_YN');                 --재단완료여부
            V_LAST_YN := V_OBJ.GET_STRING('LAST_YN');                   --마지막품목(품목교체)여부
            V_MOVE_YN := V_OBJ.GET_STRING('MOVE_YN');                   --수재단이동여부
            V_IND_BCD_M := V_OBJ.GET_STRING('IND_BCD_M');               --밀롤 개별바코드
            V_MATNR_M := V_OBJ.GET_STRING('MATRN_M');                   --밀롤자재코드
            V_LOT_NO_M := V_OBJ.GET_STRING('LOT_NO_M');                 --밀롤 LOT NO
            V_WRK_ORDR_NO_M := V_OBJ.GET_STRING('WRK_ORDR_NO_M');       --밀롤작업지시번호
            V_WRK_ORDR_SEQNO_M := V_OBJ.GET_STRING('WRK_ORDR_SEQNO_M'); --밀롤작업지시번호

           /* IF V_TM IS NULL  OR V_TM <= 0 THEN
                RS_CODE := 'E';
                RS_MSG := '작업시간을 등록 하십시오.';
                ROLLBACK;
                RETURN;
            END IF ;
            */
            
            UPDATE TB_SCH017
               SET MAN_CUT_YN   = V_MOVE_YN
            WHERE WRK_ORDR_NO    = P_WRK_ORDR_NO
              AND WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO
              --AND NVL(DLFL,'N') = 'N'  --삭제지시자 X='삭제' , N=정상오더
              AND NVL(USE_YN, 'Y') = 'Y'  --삭제지시자 X='삭제' , N=정상오더
              ;

            IF V_MOVE_YN = 'Y' THEN
                V_WLEN_CAL := V_TT_WLEN;
                V_VLEN_CAL := V_TT_VLEN;
            ELSE
                V_WLEN_CAL := V_WLEN;
                V_VLEN_CAL := V_VLEN;
            END IF;

            SELECT
                PKCNT,  
                /*( SELECT S001.WLEN
                  FROM TB_MAS001 S001
                  WHERE H017.WERKS = S001.WERKS
                    AND H017.MATNR = S001.MATNR
                  
                ),*/ 
                VBELN,        
                POSNR,        
                OVBELN,       
                OPOSNR        
            INTO
                V_MRCNT,
                --V_MWIDTH,
                V_VBELN_M,
                V_POSNR_M,
                V_OVBELN_M,
                V_OPOSNR_M
            FROM
                TB_SCH017  H017
            WHERE
                    WRK_ORDR_NO    = P_WRK_ORDR_NO  /*V_WRK_ORDR_NO_M*/
                AND WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO /*V_WRK_ORDR_SEQNO_M*/
                --AND NVL(H017.DLFL,'N') = 'N'  --삭제지시자 X='삭제' , N=정상오더
                AND NVL(USE_YN, 'Y') = 'Y'  --삭제지시자 X='삭제' , N=정상오더
                ;

            SELECT WLEN
              INTO V_MWIDTH
            FROM TB_MAS001
            WHERE MATNR = V_MATNR_M  ;


            SELECT
                LINE,
                SAP_WRK_CD
            INTO
                V_LINE,
                V_SAP_WRK_CD
            FROM
                TB_MAS012
            WHERE
                MACH_CD = P_MACH_CD;

            --로케이션 정보
            BEGIN
                SELECT
                    LGPRO   --투입저장위치
                INTO V_STOR_LOC_CD
                FROM
                    TB_MAS001
                WHERE
                        WERKS = P_WERKS
                    AND MATNR = V_MATNR;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    V_STOR_LOC_CD := '';
                WHEN OTHERS THEN
                    V_STOR_LOC_CD := '';
            END;

            IF NVL(V_STOR_LOC_CD, '') = '' THEN
                RS_CODE := 'E';
                RS_MSG := '품목마스터의 투입 저장위치 정보를 확인해주세요'||' '||P_WERKS||' '||V_MATNR;
                ROLLBACK;
                RETURN;
            END IF;


            SELECT
                STOR_LOC_CD
            INTO V_STOR_LOC_CD_M
            FROM
                TB_INV001
            WHERE
                    WERKS = P_WERKS
                AND IND_BCD = V_IND_BCD_M;

            IF NVL(V_STOR_LOC_CD, '') = '' THEN
                RS_CODE := 'E';
                RS_MSG := '저장위치 정보를 확인해주세요';
                ROLLBACK;
                RETURN;
            END IF;

            IF V_MOVE_YN = 'Y' THEN
                V_LOC_CD := 'L2400';                --수재단 재고창고
            ELSE
                V_LOC_CD := 'L2600';                --포장대기창고
            END IF;

            --작업자명
            BEGIN
                SELECT
                    NMLAST
                INTO V_USER_NM
                FROM
                    USRMA
                WHERE
                    USERID = P_USERID;

            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    V_USER_NM := '';
                WHEN OTHERS THEN
                    V_USER_NM := '';
            END;

            --포장방식 
            BEGIN
                SELECT
                    NVL(FN_CD_VAL('PACK_TYPE', V_PACKTYPE), ' ')
                INTO V_PACKTYPE_NM
                FROM
                    DUAL;

            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    V_PACKTYPE_NM := '';
                WHEN OTHERS THEN
                    V_PACKTYPE_NM := '';
            END;

            --국가명
            BEGIN
                SELECT
                    NVL(FN_CD_VAL('NATNKY', LAND1), ' ')
                INTO V_NTN_NM
                FROM
                    TB_MAS009
                WHERE
                        CUST_CD = V_KUNNR
                    AND CUST_DIV = 'C';

            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    V_NTN_NM := '';
                WHEN OTHERS THEN
                    V_NTN_NM := '';
            END;

           --지종명
            BEGIN
                SELECT
                    PCODE_NM
                INTO V_PCODE_NM
                FROM
                    TB_MAS001
                WHERE
                        WERKS = P_WERKS
                    AND MATNR = V_MATNR
                    AND PCODE = V_PCODE;

            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    V_PCODE_NM := '';
                WHEN OTHERS THEN
                    V_PCODE_NM := '';
            END; 

            --실적조회 시 수재단이동은 재단실적에서 집계하지 않음
            IF V_MOVE_YN = 'Y' THEN
                V_PRFM_GTHR_YN := 'Y';
            ELSE
                V_PRFM_GTHR_YN := 'Y';
            END IF;

            BEGIN
                SELECT
                    LOT_NO
                INTO V_LOT_NO
                FROM
                    TB_WRK002
                WHERE
                        WRK_ORDR_NO = P_WRK_ORDR_NO
                    AND WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO
                    AND ROWNUM = 1;

            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                     V_LOT_NO := NULL ;      
            END ;

            --IF V_LOT_NO IS NULL OR TRIM(V_LOT_NO) = '' THEN
                SP_CHK_LOT_NO(V_LOT_BUF, P_WERKS, P_MACH_CD, V_MATNR, V_PRD_END_DTM, V_LOT_NO);
            
            UPDATE TB_SCH017 SET LOT_BUF = V_LOT_NO
            WHERE WRK_ORDR_NO    = P_WRK_ORDR_NO
              AND WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO
              --AND NVL(DLFL,'N') = 'N'  --삭제지시자 X='삭제' , N=정상오더
              AND NVL(USE_YN, 'Y') = 'Y'  --삭제지시자 X='삭제' , N=정상오더
              ;
                
            --END IF;
            V_LOT_BUF := V_LOT_NO;
            --실적일자, 생산일자, 유통기간
            V_PRFM_DT := FN_RECDATE(TO_DATE(V_PRD_END_DTM, 'YYYYMMDDHH24MISS'));
            V_PRD_DT := TO_CHAR(TO_DATE(V_PRD_END_DTM, 'YYYYMMDDHH24MISS'), 'YYYYMMDD');
            V_DSTBT_DDLIN := ''; --FN_GET_DSTBT_DDLIN_DT(P_WERKS, V_MATNR, V_PRD_DT);

            V_PRD_STR_DATE := TO_DATE(V_PRD_STR_DTM, 'YYYYMMDDHH24MISS');
            V_PRD_END_DATE := TO_DATE(V_PRD_END_DTM, 'YYYYMMDDHH24MISS');

            --실적등록 가능 월 검사                
            BEGIN
                SELECT  YMCHK INTO  V_YMCHK
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
                SELECT
                    MAX(WRK_SEQ)
                INTO V_WRK_SEQ
                FROM
                    TB_WRK002
                WHERE
                        WERKS = P_WERKS
                    AND MACH_CD = P_MACH_CD
                    AND PRFM_DT = V_PRFM_DT;

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

            V_ORD_STR_DATE := TO_CHAR(TO_DATE(V_ORD_PRD_STR_DTM, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD');
            V_ORD_STR_TIME := TO_CHAR(TO_DATE(V_ORD_PRD_STR_DTM, 'YYYY-MM-DD HH24:MI:SS'), 'HH24:MI:SS');
            V_ORD_END_DATE := TO_CHAR(TO_DATE(V_PRD_END_DTM, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD');
            V_ORD_END_TIME := TO_CHAR(TO_DATE(V_PRD_END_DTM, 'YYYY-MM-DD HH24:MI:SS'), 'HH24:MI:SS');
-- 2022.12.01(김성하) 막음.            V_WRK_TM := V_TM;

            --재단완료시
            IF V_CACOM_YN = 'Y' /*AND V_LOOP_CNT = I*/ THEN
                V_ORD_STR_DATE := TO_CHAR(TO_DATE(V_ORD_PRD_STR_DTM, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD');
                V_ORD_STR_TIME := TO_CHAR(TO_DATE(V_ORD_PRD_STR_DTM, 'YYYY-MM-DD HH24:MI:SS'), 'HH24:MI:SS');
                V_ORD_END_DATE := TO_CHAR(TO_DATE(V_PRD_END_DTM, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD');
                V_ORD_END_TIME := TO_CHAR(TO_DATE(V_PRD_END_DTM, 'YYYY-MM-DD HH24:MI:SS'), 'HH24:MI:SS');
                V_ORD_TM := ROUND((V_PRD_END_DATE - TO_DATE(V_ORD_PRD_STR_DTM, 'YYYY-MM-DD HH24:MI:SS')) * 24 * 60);
                --비가동 시간
                SELECT
                    SUM(ABN_TM)
                INTO V_ORD_ABN_TIME
                FROM
                    TB_WRK003
                WHERE
                        WERKS = P_WERKS
                    AND MACH_CD = P_MACH_CD
                    AND WRK_ORDR_NO = P_WRK_ORDR_NO
                    AND WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO;

                V_ORD_TM := V_ORD_TM - V_ORD_ABN_TIME;
                
                UPDATE TB_SCH017
                SET
                    PRD_END_DTM = V_PRD_END_DTM,
                    COMP_YN = 'Y' 
                WHERE
                        WRK_ORDR_NO    = P_WRK_ORDR_NO
                    AND WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO
                    --AND NVL(DLFL,'N') = 'N'  --삭제지시자 X='삭제' , N=정상오더
                    AND NVL(USE_YN, 'Y') = 'Y'  --삭제지시자 X='삭제' , N=정상오더
                ;


            END IF;

            V_WGT := 0;
            -- 재단 중량 = ( I/F 실적 수량(R ) * 500 ) * ( 평량 / 1000) * ( 가로길이 / 1000 ) * (세로 / 1000 )
            V_WGT := ( V_PRFM_QTY ) * 500 * ( V_BS_WGT / 1000 ) * ( V_WLEN_CAL / 1000 ) * ( V_VLEN_CAL / 1000 );

            -- 재단 매수
            V_EA  := ( V_PRFM_QTY ) * 500 ;

            -- 2022.12.01(김성하 수정) POP에서 계산하여 들어오는 가동시간 무시(개별 팔래트당 중량으로 산정).
            V_TM := ROUND((NVL(V_WGT,0) / 1000) * 17 );
            V_WRK_TM := V_TM;

            IF NVL(V_WGT, 0) > 0 THEN
                FOR J IN 0..V_PRFM_PLT - 1 LOOP
                     V_CNT := V_CNT + 1 ;
                            --문서번호
                    V_DOC_NO := FN_GET_MDOCNO('M', 'IF126');
                    V_DOC_SEQNO := V_DOC_SEQNO + 1;

                    V_DOC_NO_PRFM := V_DOC_NO_PRFM || V_DOC_NO||',';

                    --개별바코드
                    IF V_MOVE_YN = 'Y' THEN
                        SP_GET_BARCODE_SEQ('IND', P_WERKS, 'T', V_MATNR, V_PRD_END_DTM,
                                              V_IND_BCD);
                    ELSE
                        SP_GET_BARCODE_SEQ('IND', P_WERKS, 'C', V_MATNR, V_PRD_END_DTM,
                                              V_IND_BCD);

                    END IF;

                    IF V_CNT = 1     THEN
                        RS_IND_BCD := V_IND_BCD;    -- 개별 바코드 구분자 로 여러개 전달
                    ELSE
                        RS_IND_BCD := RS_IND_BCD
                              || '|'
                              || V_IND_BCD;    -- 개별 바코드 구분자 로 여러개 전달
                    END IF;

                    IF V_PRD_STR_DATE <= SYSDATE - 7 THEN
                        RS_CODE := 'E';
                        RS_MSG := '['|| TO_CHAR(V_PRD_STR_DATE,'YYYY-MM-DD') || '] 은 실적등록 가능한 가동 시작일자가 아닙니다.';
                        ROLLBACK;
                        RETURN;
                    END IF;
                    
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
                        PACKTYPE,
                        RMK,
                        REGDATE,
                        REGID,
                        VBELN,
                        POSNR,
                        KUNNR,
                        WRK_SEQ,
                        PRFM_GTHR_YN,
                        VLEN,
                        WLEN,
                        MAN_CUT_YN
                    ) VALUES (
                        P_WERKS,
                        P_MACH_CD,
                        V_IND_BCD,
                        V_LOT_NO,
                        V_MATNR,
                        V_ORDER_NO,
                        P_WRK_ORDR_NO,
                        P_WRK_ORDR_SEQNO,
                        V_PRD_NO,
                        'EA',
                        V_EA,
                        V_PRFM_QTY,
                        V_WGT,
                        'N',
                        'N',
                        V_PRD_STR_DATE,
                        V_PRD_END_DATE,
--2022.12.01(김성하 수정)V_WRK_TM,
                        V_TM,
                        V_PRFM_DT,
                        V_PRD_DT,
                        V_DSTBT_DDLIN,
                        P_WRK_CLASS,
                        P_WRK_SHIFT,
                        V_MACHINE,
                        V_TO_MACHINE,
                        '00',
                        '01',
                        V_DOC_NO,
                        V_DOC_SEQNO,
                        V_PACKTYPE,
                        V_RMK,
                        V_DATE,
                        P_USERID,
                        V_VBELN,
                        V_POSNR,
                        V_KUNNR,
                        V_WRK_SEQ,
                        V_PRFM_GTHR_YN,
                        V_VLEN_CAL ,
                        V_WLEN_CAL ,
                        V_MOVE_YN          --수재단여부
                    );

                    IF  V_MOVE_YN = 'N'  THEN
                            --실적 I/F
                            INSERT INTO TB_IFS005 (
                                AUFNR,
                                CRLOT,
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
                                MRLOT
                            ) VALUES (
                                V_ORDER_NO,
                                V_LOT_NO,
                                P_WERKS,
                                V_SAP_WRK_CD,
                                TO_CHAR(TO_DATE(V_PRFM_DT, 'YYYYMMDD'), 'YYYY-MM-DD'),
                                V_MACHINE,
                                P_WRK_CLASS,
                                V_PRFM_QTY,         -- 2022-07-14 BMKIM : 실적 전송시 EA -> 연수로 변경하여 전달 하기로 함.
                                'R',
--2022.12.01(김성하 수정)        NVL(V_ORD_TM, '0'),
                                TO_CHAR(NVL(V_TM, 0)),
                                SUBSTRB(V_USER_NM, 1, 10),      --V_USER_NM,                                
                                TO_CHAR(V_LINE),
                                (CASE WHEN V_CACOM_YN = 'Y' AND V_PRFM_PLT  = (J + 1) THEN 'X' ELSE '' END),          -- SAP 에 마지막생산 전송시 'Y'를 'X', 아닌경우는 빈값으로 전송
                                (CASE WHEN V_CACOM_YN = 'Y' AND V_PRFM_PLT  = (J + 1) THEN 'X' ELSE '' END),          -- SAP 에 마지막생산 전송시 'Y'를 'X', 아닌경우는 빈값으로 전송
                                V_ORD_STR_DATE,
                                V_ORD_STR_TIME,
                                V_ORD_END_DATE,
                                V_ORD_END_TIME,
                                V_DOC_NO,
                                V_DOC_SEQNO,
                                V_DATE,
                                P_USERID,
                                V_LOT_NO_M
                            );
                    END IF ;                          

                             --재고등록
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
                        P_WRK_ORDR_NO,
                        P_WRK_ORDR_SEQNO,
                        V_ORDER_NO,
                        '',
                        'Y',        -- 수입밀롤 정보를 'Y'로 변경
                        V_PRD_DT,
                        'EA',
                        V_EA,
                        V_WGT,
                        '00',
                        V_DOC_NO,
                        V_DOC_SEQNO,
                        'N',
                        V_DATE,
                        P_USERID
                    );

                    -- 문서이력(실적)
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
                        V_DOC_NO,
                        V_DOC_SEQNO,
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

                    --자재소요량
                    UPDATE TB_INV003                -- 자재투입량 실적
                       SET USE_QTY = NVL(USE_QTY, 0) + V_WGT,
                           STCK_QTY = NVL(STCK_QTY, 0) - V_WGT
                     WHERE WERKS = P_WERKS
                       AND MACH_CD = P_MACH_CD
                       AND IND_BCD = V_IND_BCD_M;

                    V_DOC_NO := FN_GET_MDOCNO('M','IF130'); 

                    V_DOC_NO_INPUT := V_DOC_NO_INPUT||V_DOC_NO||',' ;

                    --자재 투입이력
                    INSERT INTO TB_INV010( WERKS, MACH_CD, MATNR, IND_BCD, SEQNO, WRK_ORDR_NO, WRK_ORDR_SEQNO,
                                        LOT_NO, IND_BCD_M, LOT_NO_M, MATNR_M, INP_DT, PRFM_DT,
                                        USE_QTY, UNIT, ROLLCNT, WGT, CHG_FLG, STCK_KY, LOT_NUM,
                                        REGDATE, REGID, USE_DIV, DOC_NO, DOC_SEQNO) 
                                VALUES(P_WERKS, P_MACH_CD, V_MATNR, V_IND_BCD, 1, V_WRK_ORDR_NO, V_WRK_ORDR_SEQNO,
                                        V_LOT_NO, V_IND_BCD_M, V_LOT_NO_M, V_MATNR_M, V_PRD_DT, V_PRFM_DT,
                                        V_WGT, V_UNIT, V_ROLLCNT, V_WGT, 'N', '', '', 
                                        V_DATE, P_USERID, '1', V_DOC_NO, V_DOC_SEQNO);   

                    --자재투입이력 전송
                    SELECT SAP_WRK_CD  INTO V_SAP_WRK_CD
                      FROM TB_MAS012
                     WHERE MACH_CD = P_MACH_CD;

                    BEGIN                    
                        SELECT ORDER_ITM_NO INTO V_ORDER_ITM_NO
                          FROM TB_SCH020
                         WHERE WERKS = P_WERKS
                           AND WRK_ORDR_NO = V_WRK_ORDR_NO
                           AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
                           AND MATNR = V_MATNR_M;
                    EXCEPTION WHEN NO_DATA_FOUND THEN
                        V_ORDER_ITM_NO := ' ';
                    END;

                    IF  V_MOVE_YN = 'N'  THEN
                            INSERT INTO TB_IFS008(AUFNR, POSNR, BUDAT, MATNR, MENGE, LGORT, CHARG,
                                                MDOCNO, MDOCSEQ, MAKE_DATE, MAKER, WORKCENTERCODE, WERKS)
                                        VALUES( V_ORDER_NO, V_ORDER_ITM_NO, V_PRFM_DT, V_MATNR_M, V_WGT, V_STOR_LOC_CD_M, V_LOT_NO_M,
                                                V_DOC_NO, V_DOC_SEQNO, V_DATE, P_USERID, V_SAP_WRK_CD, P_WERKS);
                    END IF ;                            

                    -- 문서이력(투입자재 소요량)
                    -- 1=실적, 2=생산폐품, 3=영업폐품, 4=잔량폐품, 5=투입자재 소요량, 6=재고이전(위치), 7=재고이전(자재변경), 8=재고이전(재고실사), 9=LOT변경, 10=등급변경, 11=LOT병합, 12=LIFT출고, 20=오더완료
                    INSERT INTO TB_WRK021(DOC_NO, DOC_SEQNO, DOC_DIV, WERKS, MACH_CD,
                                        WRK_ORDR_NO, WRK_ORDR_SEQNO, IND_BCD, LOT_NO, ORDER_NO,
                                        CNL_YN, REGDATE, REGID)
                                VALUES(V_DOC_NO, V_DOC_SEQNO, 5, P_WERKS, P_MACH_CD,
                                        V_WRK_ORDR_NO, V_WRK_ORDR_SEQNO, V_IND_BCD, V_LOT_NO, V_ORDER_NO,
                                        'N', V_DATE, P_USERID);                                                  

                    --LOT 추적
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

                    IF V_MOVE_YN  = 'Y' THEN
                            UPDATE TB_SCH017
                               SET
                                    MAN_CUT_YN = 'Y'     --수재단여부
                             WHERE
                                   WRK_ORDR_NO    = P_WRK_ORDR_NO
                               AND WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO
                               --AND NVL(DLFL,'N') = 'N'  --삭제지시자 X='삭제' , N=정상오더
                               AND NVL(USE_YN, 'Y') = 'Y'  --삭제지시자 X='삭제' , N=정상오더
                               ;

                            --재단 작업시  수재단 일경우 작업지시생성
                            SP_GET_DOC_SEQ('WOCA',SUBSTR(V_PRD_STR_DTM,1,8),V_WO_NO);

                            INSERT INTO TB_SCH017 
                            (
                                 WRK_ORDR_NO	        --작업지시번호
                                ,WRK_ORDR_SEQNO	        --작업지시순번
                                ,WERKS	                --플랜트코드
                                ,ORDER_NO	            --오더번호
                                ,WRK_SEQNO	            --작업순서
                                ,WRK_ORDR_QTY		    --생산지시량
                                ,ORDR_GEN_DT		    --지시생성일자
                                ,PRD_REQ_DT		        --생산요청일자
                                ,WRK_ORDR_RMK		    --작업지시비고
                                ,PRD_STR_DTM		    --생산시작일시
                                ,PRD_END_DTM		    --생산완료일시
                                ,PRFM_QTY		        --실적수량
                                ,COMP_YN		        --완료여부
                                ,USE_YN		            --사용여부(Y/N)
                                ,PRT_MATNR_UNIT	        --모품목기준수량 단위
                                ,PRT_MATNR_QTY	        --모품목기준수량
                                ,DLFL	                --오더 삭제 지시자
                                ,MATNR	                --자재 코드
                                ,MACHINE	            --FROM 생산호기
                                ,MACHINE_NM	            --FROM 생산 호기명
                                ,ATN_BOM_NO	            --대체Bom
                                ,BOM_NO	                --BOM Num
                                ,TO_MACHINE	            --TO 생산호기
                                ,TO_MACHINE_NM	        --TO 생산 호기명
                                ,BS_WGT	                --평량
                                ,UNIT	                --단위
                                ,PCODE	                --지종
                                ,ORDER_DIV	            --오더유형
                                ,ORDER_DIV_NM	        --오더유형 텍스트
                                ,OVBELN	                --판매문서
                                ,OAUART_DIV	            --판매문서 유형
                                ,OAUART_NM	            --판매 문서 오더 유형 텍스트
                                ,OPOSNR	                --판매문서 항목번호
                                ,VBELN	                --판매문서
                                ,SAUART_DIV	            --판매문서 유형
                                ,SAUART_NM	            --판매 문서 오더 유형 텍스트
                                ,POSNR	                --판매문서 항목번호
                                ,PRE_ORDER_NO	        --이전 오더 번호
                                ,TOT_WGT	            --총중량
                                ,PKCNT	                --폭수
                                ,DBL_FLAG	            --쌍팔레트
                                ,VLEN	                --세로길
                                ,WLEN	                --가로길
                                ,PLT_PER_CNT	        --팔레트당연수
                                ,IN_PER_CNT	            --속당매수
                                ,CUTTER	                --카터
                                ,ZCOR	                --재단출고 오더 여부
                                ,REGDATE	            --등록일시
                                ,REGID	                --등록자ID
                                ,UPDDATE	            --수정일시
                                ,UPDID	                --수정자ID
                                ,ORDER_RMK	            --오더비고
                                ,KUNNR	                --판매처
                                ,ROUTE	                --항차
                                ,KUNNRT	                --판매처명
                                ,LOT_BUF		
                                ,MAUFNR	                --M/R LOT Number
                                ,PTIM	                --생산 계획 시간 (HHMM)
                                ,PSEQ	                --IS-M: Production Sequence
                                ,WORKGROUP	            --반
                                ,MMATNR	                --자재 번호
                                ,MROLLCNT	            --M/R 권치수 
                                ,MBRGEW	                --M/ROLL   중량
                                ,MGEWEI	                --중량 단위
                                ,CORESIZE	            --밀롤 지관 인치(SIZE)
                                ,PACKTYPE	            --포장타입 
                                ,MAN_CUT_YN	            --수재단여부   
                                ,DUMMY_KEY              --수재단일경우만 (실적 등록된 개별바코드)
                                ,DUMMY_WRK_ORDR_NO      --수재단일경우만 (재단 작업지시번호)
                                ,DUMMY_WRK_ORDR_SEQNO   --수재단일경우만 (재단 작업지시 순번)
                                ,MWIDTH_INPUT
                                ,MRCNT
                                ,MCNT
                                ,SCNT
                                ,CONTYPE
                                ,SIZE_VAL
                            )
                            SELECT
                                 V_WO_NO	            --작업지시번호
                                ,1	                    --작업지시순번
                                ,WERKS	                --플랜트코드
                                ,ORDER_NO	            --오더번호
                                ,WRK_SEQNO	            --작업순서
                                ,WRK_ORDR_QTY		    --생산지시량
                                ,ORDR_GEN_DT		    --지시생성일자
                                ,PRD_REQ_DT		        --생산요청일자
                                ,WRK_ORDR_RMK		    --작업지시비고
                                ,NULL		            --생산시작일시
                                ,NULL		            --생산완료일시
                                ,NULL		            --실적수량
                                ,'N'		            --완료여부
                                ,'Y'		            --사용여부(Y/N)
                                ,PRT_MATNR_UNIT	        --모품목기준수량 단위
                                ,PRT_MATNR_QTY	        --모품목기준수량
                                ,DLFL	                --오더 삭제 지시자
                                ,MATNR	                --자재 코드
                                ,MACHINE	            --FROM 생산호기
                                ,MACHINE_NM	            --FROM 생산 호기명
                                ,ATN_BOM_NO	            --대체Bom
                                ,BOM_NO	                --BOM Num
                                ,TO_MACHINE	            --TO 생산호기
                                ,TO_MACHINE_NM	        --TO 생산 호기명
                                ,BS_WGT	                --평량
                                ,UNIT	                --단위
                                ,PCODE	                --지종
                                ,ORDER_DIV	            --오더유형
                                ,ORDER_DIV_NM	        --오더유형 텍스트
                                ,OVBELN	                --판매문서
                                ,OAUART_DIV	            --판매문서 유형
                                ,OAUART_NM	            --판매 문서 오더 유형 텍스트
                                ,OPOSNR	                --판매문서 항목번호
                                ,VBELN	                --판매문서
                                ,SAUART_DIV	            --판매문서 유형
                                ,SAUART_NM	            --판매 문서 오더 유형 텍스트
                                ,POSNR	                --판매문서 항목번호
                                ,ORDER_NO	            --이전 오더 번호
                                ,TOT_WGT	            --총중량
                                ,PKCNT	                --폭수
                                ,DBL_FLAG	            --쌍팔레트
                                ,VLEN	                --세로길
                                ,WLEN	                --가로길
                                ,PLT_PER_CNT	        --팔레트당연수
                                ,IN_PER_CNT	            --속당매수
                                ,CUTTER	                --카터
                                ,ZCOR	                --재단출고 오더 여부
                                ,SYSDATE	            --등록일시
                                ,P_USERID	            --등록자ID
                                ,NULL	                --수정일시
                                ,NULL	                --수정자ID
                                ,ORDER_RMK	            --오더비고
                                ,KUNNR	                --판매처
                                ,ROUTE	                --항차
                                ,KUNNRT	                --판매처명
                                ,LOT_BUF		
                                ,MAUFNR	                --M/R LOT Number
                                ,PTIM	                --생산 계획 시간 (HHMM)
                                ,PSEQ	                --IS-M: Production Sequence
                                ,WORKGROUP	            --반
                                ,MMATNR	                --자재 번호
                                ,MROLLCNT	            --M/R 권치수 
                                ,MBRGEW	                --M/ROLL   중량
                                ,MGEWEI	                --중량 단위
                                ,CORESIZE	            --밀롤 지관 인치(SIZE)
                                ,PACKTYPE	            --포장타입 
                                ,'X'	                --수재단여부
                                ,V_IND_BCD
                                ,P_WRK_ORDR_NO
                                ,P_WRK_ORDR_SEQNO
                                ,MWIDTH_INPUT
                                ,MRCNT
                                ,MCNT
                                ,SCNT
                                ,CONTYPE
                                ,SIZE_VAL
                              FROM TB_SCH017
                             WHERE WRK_ORDR_NO     = P_WRK_ORDR_NO
                               AND WRK_ORDR_SEQNO  = P_WRK_ORDR_SEQNO
                               --AND NVL(DLFL,'N') = 'N'  --삭제지시자 X='삭제' , N=정상오더
                               AND NVL(USE_YN, 'Y') = 'Y'  --삭제지시자 X='삭제' , N=정상오더
                               ;

                     END IF;

                    --실적등록 시 영업폐품 계산
                    IF NVL(V_PKCNT, 0) = 0 THEN
                            RS_CODE := 'E';
                            RS_MSG := '재단폭수를 확인해주세요!(영업폐품 계산불가)';
                            ROLLBACK;
                            RETURN;
                    END IF;
        
                    -- 재단 총 생산M = (실적중량 / 재단 폭수) / ( ( 평량 / 1000 ) * ( 재단 가로길이 / 1000))
                    V_CA_ROLLCNT := ( V_WGT / V_PKCNT ) / (( V_BS_WGT / 1000 ) * ( V_WLEN_CAL / 1000 ));
                    -- 재단영업수량 = ( 재단 평량 / 1000 ) * (M/R 지폭 - ( 재단 가로길이 * 재단 폭수 ) ) * L_CROLLCNT / 1000
                    V_CA_WGT := ROUND((V_BS_WGT / 1000) *(V_MWIDTH - (V_WLEN_CAL * V_PKCNT)) * V_CA_ROLLCNT / 1000, 3);
        
                    -- 재단 판매 오더 유형이 ZCOR 이면 재단 S/O , ZCOR가 아니면 밀롤 S/O  를 사용함
                    V_VBELN_SDISPO := V_VBELN;
                    V_POSNR_SDISPO := V_POSNR;

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
--2022.12.01(김성하 수정)    '',
                            ROUND((NVL(V_CA_WGT,0) / 1000) * 17 ),
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
        
                        IF  V_MOVE_YN = 'N'  THEN
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
                                    V_MATNR_M,
                                    0,
                                    V_CA_WGT,
                                    0,
                                    '900',
                                    '영업폐품',
                                    V_STOR_LOC_CD_M,
                                    V_LOT_NO_M,
                                    V_DOC_NO_SCR,
                                    V_DOC_SEQNO_SCR,
                                    V_DATE,
                                    P_USERID,
                                    V_VBELN_SDISPO,
                                    V_POSNR_SDISPO,
                                    V_SAP_WRK_CD,
--2022.12.01(김성하 수정)            0,
                                    TO_CHAR(ROUND((NVL(V_CA_WGT,0) / 1000) * 17 )),
                                    0,
                                    TO_CHAR(V_PRD_STR_DATE,'YYYY-MM-DD'),
                                    TO_CHAR(V_PRD_STR_DATE,'HH24:MI:SS'),
                                    TO_CHAR(V_PRD_END_DATE,'YYYY-MM-DD'),
                                    TO_CHAR(V_PRD_END_DATE,'HH24:MI:SS')
                                );
                        END IF ;
        
                        -- 문서이력(영업폐품)
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

                        UPDATE TB_INV003                -- 자재투입량 폐품 2
                           SET DISPO_QTY = NVL(DISPO_QTY, 0) + V_CA_WGT,
                               USE_QTY   = NVL(USE_QTY, 0)   + V_CA_WGT,
                               STCK_QTY  = NVL(STCK_QTY, 0)  - V_CA_WGT
                         WHERE WERKS = P_WERKS
                           AND MACH_CD = P_MACH_CD
                           AND IND_BCD = V_IND_BCD_M;
                    END IF;
                END LOOP;
            END IF;

            --폐품등록
            IF NVL(V_DISPO_QTY1, 0) > 0 THEN
                V_DOC_NO_SCR := FN_GET_MDOCNO('M', 'IF134');
                V_DOC_SEQNO_SCR := V_DOC_SEQNO_SCR + 1;

                V_DOC_NO_DISPO := V_DOC_NO_DISPO || V_DOC_NO_SCR||',';  

                SP_GET_BARCODE_SEQ('IND', P_WERKS, 'C', V_MATNR, V_PRD_END_DTM,
                                  V_IND_BCD);
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
                    ORDER_NO
                ) VALUES (
                    P_WERKS,
                    P_MACH_CD,
                    V_IND_BCD,
                    V_LOT_NO,
                    V_MATNR,
                    V_DISPO_CD1,
                    V_WRK_ORDR_NO,
                    V_WRK_ORDR_SEQNO,
                    V_MATNR_M,
                    V_IND_BCD_M,
                    V_LOT_NO_M,
                    'EA',
                    V_DISPO_QTY1 * 500,
                    '',
                    V_DISPO_WGT1,
                    V_PRD_STR_DATE,
                    V_PRD_END_DATE,
--2022.12.01(김성하수정)         '',
                    ROUND((NVL(V_DISPO_WGT1,0) / 1000) * 17 ),
                    V_PRFM_DT,
                    P_WRK_CLASS,
                    P_WRK_SHIFT,
                    '02',
                    V_DOC_NO_SCR,
                    V_DOC_SEQNO_SCR,
                    V_RMK,
                    V_DATE,
                    P_USERID,
                    V_ORDER_NO
                );

                IF  V_MOVE_YN = 'N'  THEN
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
                            V_MATNR_M,
                            V_DISPO_WGT1, 
                            0,
                            0,
                            V_DISPO_CD1,
                            V_DISPO_NM1,
                            V_STOR_LOC_CD_M,                    --'2000',
                            V_LOT_NO_M,
                            V_DOC_NO_SCR,
                            V_DOC_SEQNO_SCR,
                            V_DATE,
                            P_USERID,
                            V_VBELN,
                            V_POSNR,
                            V_SAP_WRK_CD,
--2022.12.01(김성하수정)          0,
                            TO_CHAR(ROUND((NVL(V_DISPO_WGT1,0) / 1000) * 17 )),
                            0,
                            TO_CHAR(V_PRD_STR_DATE,'YYYY-MM-DD'), 
                            TO_CHAR(V_PRD_STR_DATE,'HH24:MI:SS'),
                            TO_CHAR(V_PRD_END_DATE,'YYYY-MM-DD'), 
                            TO_CHAR(V_PRD_END_DATE,'HH24:MI:SS')                    
                        );
                END IF ;

                -- 문서이력(생산폐품)
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

                UPDATE TB_INV003                -- 자재투입량 폐품 1
                   SET DISPO_QTY = NVL(DISPO_QTY, 0) + V_DISPO_WGT1,
                       USE_QTY   = NVL(USE_QTY, 0)   + V_DISPO_WGT1,
                       STCK_QTY  = NVL(STCK_QTY, 0)  - V_DISPO_WGT1
                 WHERE WERKS = P_WERKS
                   AND MACH_CD = P_MACH_CD
                   AND IND_BCD = V_IND_BCD_M;

            END IF;

            IF NVL(V_DISPO_QTY2, 0) > 0 THEN
                V_DOC_NO_SCR := FN_GET_MDOCNO('M', 'IF134');
                V_DOC_SEQNO_SCR := V_DOC_SEQNO_SCR + 1;

                V_DOC_NO_DISPO := V_DOC_NO_DISPO || V_DOC_NO_SCR||',';  

                SP_GET_BARCODE_SEQ('IND', P_WERKS, 'C', V_MATNR, V_PRD_END_DTM,
                                  V_IND_BCD);
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
                    ORDER_NO
                ) VALUES (
                    P_WERKS,
                    P_MACH_CD,
                    V_IND_BCD,
                    V_LOT_NO,
                    V_MATNR,
                    V_DISPO_CD2,
                    V_WRK_ORDR_NO,
                    V_WRK_ORDR_SEQNO,
                    V_MATNR_M,
                    V_IND_BCD_M,
                    V_LOT_NO_M,
                    'EA',
                    V_DISPO_QTY2 *500,
                    '',
                    V_DISPO_WGT2,
                    V_PRD_STR_DATE,
                    V_PRD_END_DATE,
--2022.12.01(김성하수정)          '',
                    ROUND((NVL(V_DISPO_WGT2,0) / 1000) * 17 ),
                    V_PRFM_DT,
                    P_WRK_CLASS,
                    P_WRK_SHIFT,
                    '02',
                    V_DOC_NO_SCR,
                    V_DOC_SEQNO_SCR,
                    V_RMK,
                    V_DATE,
                    P_USERID,
                    V_ORDER_NO
                );

                IF  V_MOVE_YN = 'N'  THEN 
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
                            V_MATNR_M,
                            V_DISPO_WGT2,
                            0,
                            0,
                            V_DISPO_CD2,
                            V_DISPO_NM2,
                            V_STOR_LOC_CD_M,
                            V_LOT_NO_M,
                            V_DOC_NO_SCR,
                            V_DOC_SEQNO_SCR,
                            V_DATE,
                            P_USERID,
                            V_VBELN,
                            V_POSNR,
                            V_SAP_WRK_CD,
--2022.12.01(김성하수정)     0,
                            TO_CHAR(ROUND((NVL(V_DISPO_WGT2,0) / 1000) * 17 )),
                            0,
                            TO_CHAR(V_PRD_STR_DATE,'YYYY-MM-DD'), 
                            TO_CHAR(V_PRD_STR_DATE,'HH24:MI:SS'),
                            TO_CHAR(V_PRD_END_DATE,'YYYY-MM-DD'), 
                            TO_CHAR(V_PRD_END_DATE,'HH24:MI:SS')                    
                        );
                END IF ;

                -- 문서이력(생산폐품)
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

                UPDATE TB_INV003                -- 자재투입량 폐품 2
                   SET DISPO_QTY = NVL(DISPO_QTY, 0) + V_DISPO_WGT2,
                       USE_QTY   = NVL(USE_QTY, 0)   + V_DISPO_WGT2,
                       STCK_QTY  = NVL(STCK_QTY, 0)  - V_DISPO_WGT2
                 WHERE WERKS = P_WERKS
                   AND MACH_CD = P_MACH_CD
                   AND IND_BCD = V_IND_BCD_M;

            END IF;



        END LOOP;

        -- 재단 작업완료 플래그 처리 
        IF V_CACOM_YN = 'Y' THEN
            SELECT
                WRK_ORDR_NO,
                WRK_ORDR_SEQNO  
            INTO
                V_JR_WRK_ORDR_NO,
                V_JR_WRK_ORDR_SEQNO  
            FROM
                TB_WRK011
            WHERE
                MACH_CD = P_MACH_CD; 

            -- 점보롤 완료인경우 TB_WRK011(작업장(설비)별 현재 진행현황) 테이블 업데이트 진행
            -- 작업진행중인 작업지시번호 -> 이전작업지시번호, 작업지시순번 -> 이전작업지시순번으로 이동
            -- 자재번호, 작업지시번호, 작업지시순번 삭제
            UPDATE TB_WRK011
            SET
                MATNR = '',
                WRK_ORDR_NO = '',
                WRK_ORDR_SEQNO = '',
                ORDER_NO = '',
                LOT_NO = '',
                PRD_STR_DTM = V_PRD_END_DTM,
                MACH_STA = 'N'    --상태(R :가동, S:비가동, N:대기중)
            WHERE
                MACH_CD = P_MACH_CD;
/*
            SELECT  SCH016.WRK_ORDR_NO  ,  SCH016.WRK_ORDR_SEQNO
              INTO V_WRK_ORDR_NO_M,V_WRK_ORDR_SEQNO_M  --밀롤 작업지시번호 작업지시번호순번
              FROM TB_SCH017  SCH017 
                 , TB_SCH016  SCH016 
             WHERE SCH017.PRE_ORDER_NO    =  SCH016.ORDER_NO(+)
               AND SCH017.WRK_ORDR_NO     = P_WRK_ORDR_NO
               AND SCH017.WRK_ORDR_SEQNO  = P_WRK_ORDR_SEQNO
               AND ROWNUM = 1
             ;
*/
            V_IND_BCD_M := V_OBJ.GET_STRING('IND_BCD_M');               --밀롤 개별바코드
            V_MATNR_M := V_OBJ.GET_STRING('MATRN_M');                   --밀롤자재코드
            V_LOT_NO_M := V_OBJ.GET_STRING('LOT_NO_M');                 --밀롤 LOT NO

            -- 투입량
            V_MWGT:= 0 ;
            SELECT  NVL(SUM(IN_QTY),0)
              INTO  V_MWGT 
              FROM  TB_INV003
             WHERE  WERKS       = P_WERKS
               AND  IND_BCD       = V_IND_BCD_M
            ;   

            -- 재단 생산량
            V_SWGT:= 0 ;
            SELECT  NVL(SUM(WGT),0)
              INTO  V_SWGT 
              FROM  TB_WRK002
             WHERE  
                    WERKS       = P_WERKS
               AND  MACH_CD     = P_MACH_CD      
               AND  ORDER_NO    = V_ORDER_NO
               AND  NVL(CNL_YN,'N')  = 'N'
            ;   

            -- 재단 폐품생산량
            V_SDISPO_QTY := 0 ;

            SELECT NVL(SUM(WGT), 0) 
            INTO V_SDISPO_QTY
              FROM TB_WRK004
             WHERE  WERKS       = P_WERKS
               AND  MACH_CD     = P_MACH_CD      
               AND  ORDER_NO    = V_ORDER_NO
               AND NVL(CNL_YN,'N')  = 'N'
               ;

            --영업폐품
            T_MSDISPO  := 0 ;         --영업폐품
            SELECT  NVL(SUM(WGT),0)
              INTO  T_MSDISPO 
              FROM  TB_WRK022
             WHERE  WERKS       = P_WERKS
               AND  MACH_CD     = P_MACH_CD      
               AND  ORDER_NO    = V_ORDER_NO
               AND  DISPO_CD       = '900' 
               AND  NVL(CNL_YN,'N') = 'N'
            ;            

           V_WGT_RMD := V_MWGT - V_SWGT - V_SDISPO_QTY - T_MSDISPO;

            IF V_WGT_RMD > 0 THEN
              V_DOC_NO_SCR := FN_GET_MDOCNO('M', 'IF134');
              V_DOC_SEQNO_SCR := V_DOC_SEQNO_SCR + 1;

              IF V_PRFM_GTHR_YN = 'Y' THEN
                    V_DOC_NO_SDISPO := V_DOC_NO_SDISPO || V_DOC_NO_SCR||',';  

                    IF  V_MOVE_YN = 'N'  THEN
                            INSERT INTO TB_IFS012( AUFNR, LOTNO, BUDAT, MATNR, SCRQTY, RSDQTY, MRSCQTY, SCRAPCODE, SCRAPREASON,
                                                     LGORT, CHARG, SDATE, STIME, EDATE, ETIME, 
                                                     MDOCNO, MDOCSEQ, MAKE_DATE, MAKER, RUNTIME, VBELN, POSNR, WORKCENTERCODE, SCRQTY_OP)
                                            VALUES( V_ORDER_NO, V_LOT_NO, TO_CHAR(TO_DATE(V_PRFM_DT, 'YYYY-MM-DD'), 'YYYYMMDD'), V_MATNR_M, 0, 0, V_WGT_RMD, '910', '잔량폐품',
                                                    V_STOR_LOC_CD_M, V_LOT_NO_M, TO_CHAR(V_PRD_STR_DATE,'YYYY-MM-DD'), TO_CHAR(V_PRD_STR_DATE,'HH24:MI:SS'), TO_CHAR(V_PRD_END_DATE,'YYYY-MM-DD'),  TO_CHAR(V_PRD_END_DATE,'HH24:MI:SS'), 
--2022.12.01(김성하 수정)                            V_DOC_NO_SCR, V_DOC_SEQNO_SCR, V_DATE, P_USERID, 0, V_VBELN_SDISPO, V_POSNR_SDISPO, V_SAP_WRK_CD, 0);  
                                                    V_DOC_NO_SCR, V_DOC_SEQNO_SCR, V_DATE, P_USERID, TO_CHAR(ROUND((NVL(V_WGT_RMD, 0) /1000) * 17)), V_VBELN_SDISPO, V_POSNR_SDISPO, V_SAP_WRK_CD, 0);  
                    END IF;                                    
              END IF;
              INSERT INTO TB_WRK022(WERKS, MACH_CD, IND_BCD, LOT_NO, MATNR, DISPO_CD, WRK_ORDR_NO, WRK_ORDR_SEQNO,
                                  ORDER_NO, MATNR_M, IND_BCD_M, LOT_NO_M, UNIT, ROLLCNT, DISPO_QTY, MACHINE, WGT, TM,
                                  PRFM_DT, WRK_CLASS, WRK_SHIFT, RUN_STA, DOC_NO, DOC_SEQNO, RMK, REGDATE, REGID,PRE_ORDER_NO)
                         VALUES( P_WERKS, P_MACH_CD, V_IND_BCD, V_LOT_NO, V_MATNR, '910', V_WRK_ORDR_NO, V_WRK_ORDR_SEQNO,
                                 V_ORDER_NO, V_MATNR_M, V_IND_BCD_M, V_LOT_NO_M, V_UNIT, 0, V_WGT_RMD, '', V_WGT_RMD, TO_CHAR(ROUND((NVL(V_WGT_RMD, 0) /1000) * 17)), 
                                 V_PRFM_DT,P_WRK_CLASS, P_WRK_SHIFT, '02', V_DOC_NO_SCR, V_DOC_SEQNO_SCR, V_RMK, V_DATE, P_USERID,V_PRE_ORDER_NO);

            -- 문서이력(잔량폐품)
            -- 1=실적, 2=생산폐품, 3=영업폐품, 4=잔량폐품, 5=투입자재 소요량, 6=재고이전(위치), 7=재고이전(자재변경), 8=재고이전(재고실사), 9=LOT변경, 10=등급변경, 11=LOT병합, 12=LIFT출고, 20=오더완료
             INSERT INTO TB_WRK021(DOC_NO, DOC_SEQNO, DOC_DIV, WERKS, MACH_CD, WRK_ORDR_NO, WRK_ORDR_SEQNO,
                                IND_BCD, LOT_NO, ORDER_NO, CNL_YN, REGDATE, REGID)
                        VALUES(V_DOC_NO_SCR, V_DOC_SEQNO_SCR, 4, P_WERKS, P_MACH_CD, V_WRK_ORDR_NO, V_WRK_ORDR_SEQNO,
                                V_IND_BCD, V_LOT_NO, V_ORDER_NO, 'N', V_DATE, P_USERID);                               

            END IF ;

            -- 자재투입  Table 업데이트 (중량)
            UPDATE TB_INV003     -- 자재투입량 ( 잔량폐품 )
               SET DISPO_QTY = NVL(DISPO_QTY, 0) + V_WGT_RMD,
                   USE_QTY   = NVL(USE_QTY, 0)   + V_WGT_RMD,
                   STCK_QTY  = NVL(STCK_QTY, 0)  - V_WGT_RMD
             WHERE WERKS   = P_WERKS
               AND MACH_CD = P_MACH_CD
               AND IND_BCD = V_IND_BCD_M;
        ELSE
            UPDATE TB_WRK011
            SET
                PRD_STR_DTM = V_PRD_END_DTM
            WHERE
                MACH_CD = P_MACH_CD;

        END IF;

        V_DOC_NO_DISPO     := SUBSTR(V_DOC_NO_DISPO, 1,LENGTH(V_DOC_NO_DISPO)-1);
        V_DOC_NO_PRFM      := SUBSTR(V_DOC_NO_PRFM, 1,LENGTH(V_DOC_NO_PRFM)-1);
        V_DOC_NO_INPUT     := SUBSTR(V_DOC_NO_INPUT, 1,LENGTH(V_DOC_NO_INPUT)-1);
        V_DOC_NO_SDISPO     := SUBSTR(V_DOC_NO_SDISPO, 1,LENGTH(V_DOC_NO_SDISPO)-1);

        IF LENGTH(V_DOC_NO_DISPO) > 0   AND V_MOVE_YN = 'N' THEN   --폐품
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

        END IF ;  

        IF LENGTH(V_DOC_NO_PRFM) > 0   AND V_MOVE_YN = 'N'  THEN   --실적

                 --SAP FUNC ID
                 SELECT RFCFN
                   INTO RS_PRFM_RFCFN
                   FROM TB_ITFMA
                  WHERE 1=1
                    AND IFID = 'MES_IF_127';   --생산오더별 재단 실적 

                 --인터페이스 파라미터
                 OPEN CUR_1 FOR
                 SELECT 'MES_IF_127' AS I_IF_ID
                      , 'M' || LTRIM(RTRIM(TO_CHAR(SEQ_GET_IFR_KEY.NEXTVAL, '00000000000000000000000000000'))) AS I_IF_KEY
                   FROM dual;

                 --인터페이스 상세 파라미터
                 V_SQL := FN_IF_QUERY('MES_IF_127', V_DOC_NO_PRFM);
                 OPEN CUR_2 FOR V_SQL;

        END IF ;  

        IF LENGTH(V_DOC_NO_INPUT) > 0   AND V_MOVE_YN = 'N'  THEN   --투입량

                     --SAP FUNC ID
                     SELECT RFCFN
                       INTO RS_INPUT_RFCFN
                       FROM TB_ITFMA
                      WHERE 1=1
                        AND IFID = 'MES_IF_130';   --생산오더별 실적 취소 TXN

                     --인터페이스 파라미터
                     OPEN CUR_5 FOR
                     SELECT 'MES_IF_130' AS I_IF_ID
                          , 'M' || LTRIM(RTRIM(TO_CHAR(SEQ_GET_IFR_KEY.NEXTVAL, '00000000000000000000000000000'))) AS I_IF_KEY
                       FROM dual;

                     --인터페이스 상세 파라미터
                     V_SQL := FN_IF_QUERY('MES_IF_130', V_DOC_NO_INPUT);
                     OPEN CUR_6 FOR V_SQL;

        END IF ;  

        IF LENGTH(V_DOC_NO_SDISPO) > 0   AND V_MOVE_YN = 'N' THEN   --영업+잔량 폐품
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
