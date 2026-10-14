
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_POP_WRK27_I03_04" (
        P_WERKS          IN VARCHAR2,  --플랜트    
        P_MACH_CD        IN VARCHAR2,  --설비코드 
        P_WRK_LIST       IN CLOB    ,
        P_WRK_CLASS      IN VARCHAR2,  --작업반
        P_WRK_SHIFT      IN VARCHAR2,  --작업조
        P_SCNT           IN VARCHAR2,  --속수
        P_IN_PER_CNT     IN VARCHAR2,  --속당매수
        P_PRFM_DT        IN VARCHAR2,  --실적일자
        P_PRFM_QTY       IN VARCHAR2,  --실적(연수)
        P_PRFM_WGT       IN VARCHAR2,  --실적(중량)
        P_PRFM_PLT       IN VARCHAR2,  --팔레트수
        P_PART_PRFM_QTY  IN VARCHAR2,  --부분실적(연수)
        P_PART_PRFM_WGT  IN VARCHAR2,  --부분실적(중량)
        P_TOT_REAM       IN VARCHAR2,  --총연수
        P_TOT_WGT        IN VARCHAR2,  --총중량
        P_DISPO_GROUP    IN VARCHAR2,  --폐품그룹 ( 'P' 인경우  SCRQTY_OP, SCRAPCODE_OP, SCRAPREASON_OP, 나머지는 SCRQTY, SCRAPCODE, SCRAPREASON)
        P_DISPO_QTY      IN VARCHAR2,  --폐품연수
        P_DISPO_WGT      IN VARCHAR2,  --폐품중량
        P_DISPO_CD       IN VARCHAR2,  --폐품코드
        P_DISPO_NM       IN VARCHAR2,  --폐품명
        P_RMK            IN VARCHAR2,  --비고
        P_USERID         IN VARCHAR2,  --USER ID
        RS_DISPO_RFCFN   OUT    VARCHAR2                ,        --폐품 RFCFN값    
        RS_INPUT_RFCFN   OUT    VARCHAR2                ,        --투입량 RFCFN값  
        RS_PRFM_RFCFN    OUT    VARCHAR2                ,        --실적 RFCFN값
        RS_SDISPO_RFCFN  OUT    VARCHAR2                ,        --영업폐품 RFCFN값    
        RS_IND_BCD       OUT VARCHAR2,--개별바코드
        LANG             IN VARCHAR2 DEFAULT 'KO',
        RS_CODE          OUT VARCHAR2,
        RS_MSG           OUT VARCHAR2,--JSON 전달 하는 P_WRK_LIST 정보
        CUR_1            OUT    SYS_REFCURSOR           ,        --실적  
        CUR_2            OUT    SYS_REFCURSOR           ,
        CUR_3            OUT    SYS_REFCURSOR           ,        --생산폐품
        CUR_4            OUT    SYS_REFCURSOR           ,
        CUR_5            OUT    SYS_REFCURSOR           ,        --투입량
        CUR_6            OUT    SYS_REFCURSOR           ,
        CUR_7            OUT    SYS_REFCURSOR           ,        --영업폐품
        CUR_8            OUT    SYS_REFCURSOR           
   )
    /*==============================================================================
     * PROGRAM ID    : WRK27{호출 프로그램 ID 기술}
     * PROGRAM NAME  : 포장예외 실적등록
     * VERSION       : 1.0.0{최종 버전 기술}
     * DESCRIPTION   : .{프로그램에 대한 상세한 내용 기술}
     *                 
     * AUTHOR NAME   : 박충식{최초 작성자 명 기술}
     * CREATE DATE   : 2022/06/24 {최초 작성일자 기술}
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
     *=============================================================================*/ AS 
        --프로그램 ID : 포장예외 실적등록
        V_PRG_NM            VARCHAR2(100) := 'SP_POP_WRK27_I03';     -- PROCEDURE NAME
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

        /* 포장 작업지시 정보 */
        ------------------------------------
        T_PRD_STR_DTM       TB_SCH018.PRD_STR_DTM%TYPE;         --생산시작일시
        T_PRD_END_DTM       TB_SCH018.PRD_END_DTM%TYPE;         --생산완료일시
        T_PRFM_QTY          TB_SCH018.PRFM_QTY%TYPE;            --실적수량
        T_MATNR             TB_SCH018.MATNR%TYPE;               --자재 코드
        T_TO_MACHINE        TB_SCH018.TO_MACHINE%TYPE;          --TO 생산호기
        T_ORDER_DIV         TB_SCH018.ORDER_DIV%TYPE;           --오더유형
        T_KUNNR             TB_SCH018.KUNNR%TYPE;               --판매처
        -----------------------------------------------------

        /* 포장 작업입력 정보 */
        ------------------------------------
        --V_PRFM_PLT          NUMBER;                       -- 파렛트 수
        --V_IN_PER_CNT        TB_SCH017.IN_PER_CNT%TYPE;    --속당매수
        --V_SCNT              NUMBER;                       --속수
        --V_TOT_REAM          NUMBER;                       -- 총연수
        --V_TOT_WGT           NUMBER;                       -- 총중량
        V_VLEN              TB_SCH017.VLEN%TYPE;          --세로길이
        V_WLEN              TB_SCH017.WLEN%TYPE;          --가로길이
        V_BS_WGT            TB_SCH017.BS_WGT%TYPE;        --평량
      --  V_DISPO_CD          TB_WRK004.DISPO_CD%TYPE;	  --폐품코드
        V_RMK               TB_WRK002.RMK%TYPE;			  --비고
        ------------------------------------      

        /* 재단 투입 정보 */
        ------------------------------------
      --  V_CA_IND_BCD        VARCHAR2(30);                --재단 개별바코드
      --  V_CA_ABLE_QTY_REAM  NUMBER;                      --재단 가용연수
        ------------------------------------

        /* 임시버퍼 */
        ------------------------------------
        V_LOOP_CNT          NUMBER;                             --포장 작업입력건수
      --  V_LOOP_CNT1         NUMBER;                             --재단 투입 정보건수
        V_LOT_BUF           TB_SCH017.LOT_BUF%TYPE;				--이전LOT NO
        V_LOT_NO            TB_WRK002.LOT_NO%TYPE;				--LOT NO
        V_IND_BCD           TB_WRK002.IND_BCD%TYPE;				--개별바코드
        V_PRD_NO            TB_WRK002.PRD_NO%TYPE;				--생산번호
        V_WRK_SEQ           TB_WRK002.WRK_SEQ%TYPE;				--생산순번
        T_CMATNR             TB_SCH018.MATNR%TYPE;              --자재 코드
        V_CIND_BCD           TB_WRK002.IND_BCD%TYPE;			--개별바코드
        V_CLOT_NO            TB_WRK002.LOT_NO%TYPE;				--LOT NO
        ------------------------------------
        V_GUBUN              VARCHAR2(1);
        V_PLT_NO             NUMBER; 
        V_PLT_NO_PRE         NUMBER;  
        V_IND_BCD_M          TB_WRK002.IND_BCD%TYPE;				--개별바코드
        V_LOT_NO_M           TB_WRK002.LOT_NO%TYPE;				--LOT NO
        V_LOT_NO_M_1           TB_WRK002.LOT_NO%TYPE;				--LOT NO
        V_LOT_NO_M_2           TB_WRK002.LOT_NO%TYPE;				--LOT NO
        V_LOT_NO_M_3           TB_WRK002.LOT_NO%TYPE;				--LOT NO
        V_LOT_NO_M_4           TB_WRK002.LOT_NO%TYPE;				--LOT NO
        V_LOT_NO_M_5           TB_WRK002.LOT_NO%TYPE;				--LOT NO
        V_USE_REAM_M         NUMBER(10, 3);
        V_USE_WGT_M          NUMBER(10, 3);
        V_WRK_ORDR_NO_M      TB_WRK002.WRK_ORDR_NO%TYPE;
        V_WRK_ORDR_SEQNO_M   TB_WRK002.WRK_ORDR_SEQNO%TYPE;
        V_WRK_ORDR_NO        TB_WRK002.WRK_ORDR_NO%TYPE;
        V_WRK_ORDR_SEQNO     TB_WRK002.WRK_ORDR_SEQNO%TYPE;

        V_PRFM_QTY           NUMBER(10, 3);
        V_PART_PRFM_QTY      NUMBER(10, 3);
        V_DISPO_QTY          NUMBER(10, 3);        
        V_PRFM_WGT           NUMBER(10, 3);
        V_PART_PRFM_WGT      NUMBER(10, 3);
        V_DISPO_WGT          NUMBER(10, 3);        

        V_PRFM_QTY_TOT       NUMBER(10, 3);
        V_PART_PRFM_QTY_TOT  NUMBER(10, 3);
        V_DISPO_QTY_TOT      NUMBER(10, 3);        

        V_PRFM_WGT_TOT       NUMBER(10, 3);
        V_PART_PRFM_WGT_TOT  NUMBER(10, 3);
        V_DISPO_WGT_TOT      NUMBER(10, 3);        

        V_PRFM_QTY_INP       NUMBER(10, 3);
        V_PART_PRFM_QTY_INP  NUMBER(10, 3);
        V_DISPO_QTY_INP      NUMBER(10, 3);        

        V_PRFM_WGT_INP       NUMBER(10, 3);
        V_PART_PRFM_WGT_INP  NUMBER(10, 3);
        V_DISPO_WGT_INP      NUMBER(10, 3);        

        V_PRFM_QTY_PLT       NUMBER(10, 3);
        V_PART_PRFM_QTY_PLT  NUMBER(10, 3);
        V_DISPO_QTY_PLT      NUMBER(10, 3);        

        V_PRFM_WGT_PLT       NUMBER(10, 3);
        V_PART_PRFM_WGT_PLT  NUMBER(10, 3);
        V_DISPO_WGT_PLT      NUMBER(10, 3);        

        V_MATNR              TB_SCH018.MATNR%TYPE;              --재단자재 코드  
        V_MATNR_M            TB_SCH018.MATNR%TYPE;              --포장자재 코드  

        V_SEQ                NUMBER;        
        V_MACHINE           TB_SCH018.MACHINE%TYPE;             --FROM 생산호기
        V_PACKTYPE          TB_SCH018.PACKTYPE%TYPE;            --포장 타입
        V_ORDER_NO          TB_SCH018.ORDER_NO%TYPE;            --오더번호
        V_UNIT              TB_SCH018.UNIT%TYPE;                --단위
        V_TO_MACHINE        TB_SCH018.TO_MACHINE%TYPE;          --TO 생산호기        
        V_VBELN	            TB_SCH018.VBELN%TYPE; 
        V_POSNR	            TB_SCH018.POSNR%TYPE; 
        V_KUNNR	            TB_SCH018.KUNNR%TYPE;

        V_DOC_NO            TB_WRK002.DOC_NO%TYPE;
        V_DOC_SEQNO         TB_WRK002.DOC_SEQNO%TYPE;

        V_DOC_NO_PRFM1       TB_WRK002.DOC_NO%TYPE;
        V_DOC_SEQNO_PRFM1    TB_WRK002.DOC_SEQNO%TYPE;

        V_DOC_NO_INPUT      VARCHAR2(500);
        V_DOC_NO_DISPO      VARCHAR2(500);
        V_DOC_NO_PRFM       VARCHAR2(500);
        V_DOC_NO_SDISPO     VARCHAR2(500);
        
        --V_BS_WGT	        TB_SCH018.BS_WGT%TYPE; 
        V_CON_TYPE	        TB_SCH018.CON_TYPE%TYPE;
        V_SEQNO             NUMBER ;
        V_USER_NM           VARCHAR2(20);                               --작업자명
        V_LINE              TB_MAS012.LINE%TYPE;                        --라인
        V_SAP_WRK_CD        TB_MAS012.SAP_WRK_CD%TYPE;                  --SAP작업장코드
        V_SQL               CLOB; 
        V_LIST_IND_BCD      VARCHAR2(500); 
        V_ORDER_ITM_NO          VARCHAR2(10);    
        V_GB            VARCHAR2(1); 
        --CURSOR CUR_1 ;
        V_YMCHK                     TB_MAS011.YMCHK%TYPE;   --실적등록 가능 여부    
        V_USE_REAM_M_1         NUMBER(10, 3); 
        V_USE_REAM_M_2         NUMBER(10, 3); 
        V_USE_REAM_M_3         NUMBER(10, 3); 
        V_USE_REAM_M_4         NUMBER(10, 3); 
        V_USE_REAM_M_5         NUMBER(10, 3); 
        V_PACK_LABEL_TYPE      VARCHAR2(5);     
    
    BEGIN
       BEGIN
            --실적등록 가능 월 검사                
            BEGIN
            SELECT  YMCHK INTO  V_YMCHK
              FROM TB_MAS011
             WHERE WERKS = P_WERKS
               AND YMCHK = 'Y'
               AND YYMM  = SUBSTR(P_PRFM_DT, 1, 6);
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
       
       
            ---  실적  ----------------------------------------
            V_PRFM_QTY       := TO_NUMBER(P_PRFM_QTY) ;         --실적수량(연수)
            V_PART_PRFM_QTY  := TO_NUMBER(P_PART_PRFM_QTY);            
            V_DISPO_QTY      := TO_NUMBER(P_DISPO_QTY);             

            V_PRFM_WGT       := TO_NUMBER(P_PRFM_WGT);         --실적중량
            V_PART_PRFM_WGT  := TO_NUMBER(P_PART_PRFM_WGT);            
            V_DISPO_WGT      := TO_NUMBER(P_DISPO_WGT);             

            V_DOC_NO_INPUT   := '';
            V_DOC_NO_DISPO   := '';
            V_DOC_NO_PRFM    := '';     
            V_DOC_NO_SDISPO  := '';
            
            V_DOC_SEQNO := 0;
            V_DOC_SEQNO_PRFM1 := 0;
            

           --JSON 입력 데이터 수신
           IF V_PRFM_QTY  > 0   OR P_PART_PRFM_QTY > 0   THEN  

               V_JSON := JSON_OBJECT_T.PARSE(P_WRK_LIST);
               V_ARR_LIST := V_JSON.GET_ARRAY('list');
               V_SEQ := 0 ;
               V_PLT_NO_PRE := 0;
               RS_IND_BCD   := '';
               V_LIST_IND_BCD := '';
               V_PRFM_QTY_PLT := 0 ;
               V_PRFM_WGT_PLT := 0 ;
               V_SEQNO           := 0 ;  

               FOR I IN 0..V_ARR_LIST.GET_SIZE - 1 LOOP
                        V_OBJ := TREAT(V_ARR_LIST.GET(I) AS JSON_OBJECT_T);
                        V_OBJ := TREAT(V_OBJ.GET('map') AS JSON_OBJECT_T);

                        V_GUBUN             := V_OBJ.GET_STRING('GUBUN');                       --'1' 은 실적, '2'은 부분실적
                        V_PLT_NO            := TO_NUMBER(V_OBJ.GET_STRING('PLT_NO'));           --팔레트번호
                        V_IND_BCD_M         := V_OBJ.GET_STRING('IND_BCD_M');                   --재단 개별바코드
                        V_LOT_NO_M          := V_OBJ.GET_STRING('LOT_NO_M');                    --재단 LOT_NO
                        V_USE_REAM_M        := TO_NUMBER(V_OBJ.GET_STRING('USE_REAM_M'));       --재단 개별바코드 사용연수
                        V_USE_WGT_M         := TO_NUMBER(V_OBJ.GET_STRING('USE_WGT_M'));        --재단 개별바코드 사용중량
                        V_MATNR_M           := V_OBJ.GET_STRING('MATNR_M');                     --재단 자재
                        V_WRK_ORDR_NO_M     := V_OBJ.GET_STRING('WRK_ORDR_NO_M');               --재단 작업지시번호
                        V_WRK_ORDR_SEQNO_M  := TO_NUMBER(V_OBJ.GET_STRING('WRK_ORDR_SEQNO_M')); --재단 작업지시순번
                        V_WRK_ORDR_NO       := V_OBJ.GET_STRING('WRK_ORDR_NO');                 --포장 작업지시번호
                        V_WRK_ORDR_SEQNO    := TO_NUMBER(V_OBJ.GET_STRING('WRK_ORDR_SEQNO'));   --포장 작업지시순번
                        V_LOT_NO_M_1        := V_OBJ.GET_STRING('LOT_NO_M1');                   --재단 LOT_NO
                        V_LOT_NO_M_2        := V_OBJ.GET_STRING('LOT_NO_M2');                   --재단 LOT_NO
                        V_LOT_NO_M_3        := V_OBJ.GET_STRING('LOT_NO_M3');                   --재단 LOT_NO
                        V_LOT_NO_M_4        := V_OBJ.GET_STRING('LOT_NO_M4');                   --재단 LOT_NO
                        V_LOT_NO_M_5        := V_OBJ.GET_STRING('LOT_NO_M5');                   --재단 LOT_NO
                        V_USE_REAM_M_1      := TO_NUMBER(V_OBJ.GET_STRING('USE_REAM_M1'));       --재단1 개별바코드 사용연수
                        V_USE_REAM_M_2      := TO_NUMBER(V_OBJ.GET_STRING('USE_REAM_M2'));       --재단2 개별바코드 사용연수
                        V_USE_REAM_M_3      := TO_NUMBER(V_OBJ.GET_STRING('USE_REAM_M3'));       --재단3 개별바코드 사용연수
                        V_USE_REAM_M_4      := TO_NUMBER(V_OBJ.GET_STRING('USE_REAM_M4'));       --재단4 개별바코드 사용연수
                        V_USE_REAM_M_5      := TO_NUMBER(V_OBJ.GET_STRING('USE_REAM_M5'));       --재단5 개별바코드 사용연수
                        V_PACK_LABEL_TYPE   := V_OBJ.GET_STRING('PACK_LABEL_TYPE');       


                        IF V_GUBUN  = '1' OR V_GUBUN  = '2' THEN                        

                                IF V_PLT_NO_PRE <> V_PLT_NO THEN

                                    SELECT
                                           GB               GB 
                                         , MATNR            MATNR
                                         , MACHINE          MACHINE
                                        ,  LOT_BUF          LOT_BUF
                                        ,  ORDER_NO         ORDER_NO
                                        ,  UNIT             UNIT
                                        ,  TO_MACHINE       TO_MACHINE 
                                        ,  PACKTYPE         PACKTYPE 
                                        ,  ORDER_RMK        ORDER_RMK 
                                        ,  VLEN	         VLEN
                                        ,  WLEN             WLEN
                                        ,  VBELN	         VBELN  
                                        ,  POSNR	         POSNR  
                                        ,  KUNNR	         KUNNR 
                                        ,  BS_WGT	         BS_WGT   
                                        ,  CON_TYPE	     CON_TYPE 
                                INTO    V_GB 
                                     ,  V_MATNR
                                     ,  V_MACHINE
                                     ,  V_LOT_BUF
                                     ,  V_ORDER_NO
                                     ,  V_UNIT
                                     ,  V_TO_MACHINE
                                     ,  V_PACKTYPE
                                     ,  V_RMK
                                     ,  V_VLEN	
                                     ,  V_WLEN	
                                     ,  V_VBELN	  
                                     ,  V_POSNR	  
                                     ,  V_KUNNR	  
                                     ,  V_BS_WGT	    
                                     ,  V_CON_TYPE	
                                    FROM
                                    (
                                            SELECT   '2'              GB 
                                                 ,  MATNR            MATNR
                                                 ,  NULL          MACHINE
                                                 ,  LOT_BUF          LOT_BUF
                                                 ,  ORDER_NO         ORDER_NO
                                                 ,  UNIT             UNIT
                                                 ,  NULL             TO_MACHINE 
                                                 ,  PACKTYPE         PACKTYPE 
                                                 ,  NULL             ORDER_RMK 
                                                 ,  VLEN	         VLEN
                                                 ,  WLEN             WLEN
                                                 ,  VBELN	         VBELN  
                                                 ,  POSNR	         POSNR  
                                                 ,  KUNNR	         KUNNR 
                                                 ,  BS_WGT	         BS_WGT   
                                                 ,  NULL	         CON_TYPE 
                                            FROM TB_SCH019
                                            WHERE WRK_ORDR_NO      = V_WRK_ORDR_NO
                                              AND WRK_ORDR_SEQNO   = V_WRK_ORDR_SEQNO
                                      )        
                                      ;
                                    --개별바코드
                                    SP_GET_BARCODE_SEQ('IND', P_WERKS, 'Z', V_MATNR, TO_CHAR(SYSDATE,'YYYYMMDDHH24MISS'),
                                                  V_IND_BCD);
--                                    SP_GET_BARCODE_SEQ('IND', P_WERKS, P_MACH_CD, V_MATNR, TO_CHAR(SYSDATE,'YYYYMMDDHH24MISS'),
--                                                  V_IND_BCD);

                                    RS_IND_BCD     := RS_IND_BCD     || V_IND_BCD|| '|';    -- 개별 바코드 구분자 로 여러개 전달
                                    V_LIST_IND_BCD := V_LIST_IND_BCD || V_IND_BCD|| ','; 
                                    
                                    --문서번호
                                    V_DOC_NO_PRFM1    := FN_GET_MDOCNO('M', 'IF141');
                                    V_DOC_SEQNO_PRFM1 :=  V_DOC_SEQNO_PRFM1 + 1;
                                    V_DOC_NO_PRFM := V_DOC_NO_PRFM||V_DOC_NO_PRFM1||',' ;

                                    --생산순번 조회
                                    BEGIN
                                        SELECT
                                            MAX(WRK_SEQ)
                                        INTO V_WRK_SEQ
                                        FROM
                                            TB_WRK002
                                        WHERE
                                                WERKS   = P_WERKS
                                            AND MACH_CD = P_MACH_CD
                                            AND PRFM_DT = TO_CHAR(SYSDATE,'YYYYMMDD')
                                            AND NVL(CNL_YN,'N') = 'N';

                                    EXCEPTION
                                        WHEN NO_DATA_FOUND THEN
                                            V_WRK_SEQ := 0;
                                    END;

                                    V_WRK_SEQ := NVL(V_WRK_SEQ, 0) + 1;


                                    --생산번호
                                    V_PRD_NO := TO_CHAR(SYSDATE, 'YYYY-MM-DD')
                                        || '-'
                                        || V_MACHINE
                                        || '-'
                                        || TO_CHAR(V_WRK_SEQ);

                                    --IF V_LOT_NO IS NULL OR TRIM(V_LOT_NO) = '' THEN
                                        SP_CHK_LOT_NO(V_LOT_BUF, P_WERKS, P_MACH_CD, V_MATNR, TO_CHAR(SYSDATE,'YYYYMMDDHH24MISS'), V_LOT_NO);
                                        V_LOT_BUF := V_LOT_NO ;
                                        
                                            UPDATE TB_SCH019   SET LOT_BUF = V_LOT_NO
                                             WHERE WRK_ORDR_NO      = V_WRK_ORDR_NO
                                               AND WRK_ORDR_SEQNO   = V_WRK_ORDR_SEQNO
                                               ;

                                    --END IF;

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


                                    V_PRFM_QTY_PLT := 0 ;
                                    V_PRFM_WGT_PLT := 0 ;


                                END IF ;

                                V_PRFM_QTY_PLT := V_PRFM_QTY_PLT + V_USE_REAM_M ;
                                V_PRFM_WGT_PLT := V_PRFM_WGT_PLT + V_USE_WGT_M  ;

                                --실적등록
                                BEGIN
                                        INSERT INTO TB_WRK002   --실적테이블(PS)
                                        (
                                                 WERKS	                --플랜트
                                                ,MACH_CD	            --작업장코드(설비코드)
                                                ,IND_BCD	            --개별바코드
                                                ,LOT_NO	                --LOT_NO
                                                ,MATNR	                --자재코드
                                                ,ORDER_NO	            --오더번호
                                                ,ORDER_SEQNO	        --오더번호 순번
                                                ,WRK_ORDR_NO	        --작업지시번호
                                                ,WRK_ORDR_SEQNO	        --작업지시 순번
                                                ,PRD_NO	                --생산번호
                                                ,UNIT	                --실적단위
                                                ,PRFM_QTY	            --실적수량
                                                ,PCNT	                --연수
                                                ,SCNT	                --속수
                                                ,MCNT	                --매
                                                ,WIDTH	                --실 지폭
                                                ,ROLLCNT	            --권치수
                                                ,WGT	                --중량
                                                ,RSPEED	                --선속
                                                ,CORE	                --지관
                                                ,WIDTH_NO	            --지폭순서
                                                ,MRLDCK	                --밀롤창고적치여부
                                                ,CUTTER	                --카타설비
                                                ,MER_YN	                --LOT병합여부
                                                ,GRD_YN	                --등급변경여부
                                                ,PRD_STR_DATE	        --생산시작 일시
                                                ,PRD_END_DATE	        --생산 종료 일시
                                                ,TM	                    --생산시간(분)
                                                ,PRFM_DT	            --실적일자
                                                ,PRD_DT	                --생산일자
                                                ,DSTBT_DDLIN	        --유통기간
                                                ,WRK_CLASS	            --반
                                                ,WRK_SHIFT	            --작업조
                                                ,MACHINE	            --생산호기
                                                ,TO_MACHINE	            --가공호기(투입호기)
                                                ,STA	                --상태
                                                ,DOC_NO	                --MES 문서번호
                                                ,DOC_SEQNO	            --MES 문서번호 순번
                                                ,SDOC_NO	            --SAP 확정문서번호
                                                ,SDOC_SEQNO	
                                                ,RMK	                --비고
                                                ,CNL_YN	                --취소여부
                                                ,CNL_RMK	            --취소사유
                                                ,REGDATE	            --등록일시
                                                ,REGID	                --등록자
                                                ,UPDDATE	            --수정일시
                                                ,UPDID	                --수정자
                                                ,VBELN	                --판매문서번호
                                                ,POSNR	                --판매문서번호순번
                                                ,KUNNR	                --판매처(거래처)
                                                ,PACKTYPE	            --포장타입
                                                ,RUN_STA	            --"운전상태 01:정상생산, 09:비계획생산, 00:
                                                ,WRK_SEQ	            --생산순번
                                                ,PRD_SEQ	            --실적순서(리와인더)
                                                ,LOT_NO_BUF	
                                                ,VLEN	                --세로길이
                                                ,WLEN	                --가로길이
                                                ,PRFM_GTHR_YN	        --실적집계여부
                                                ,NAUFNR	                --비계획생산오더번호
                                                ,LOT_NO_PRE	            --비계획생산 LOT NO
                                                ,LOT_CHG_YN	            --LOT변경여부
                                                ,RMD_QTY	            --영업폐품      
                                                ,IN_PER_CNT             --속당매수
                                                ,LOT_NO_M1
                                                ,LOT_NO_M2
                                                ,LOT_NO_M3
                                                ,LOT_NO_M4
                                                ,LOT_NO_M5
                                                ,USE_REAM_M1
                                                ,USE_REAM_M2
                                                ,USE_REAM_M3
                                                ,USE_REAM_M4
                                                ,USE_REAM_M5
                                                ,PACK_LABEL_TYPE
                                        )
                                        VALUES
                                        (
                                                 P_WERKS	                --플랜트
                                                ,P_MACH_CD	                --작업장코드(설비코드)
                                                ,V_IND_BCD	                --개별바코드
                                                ,V_LOT_NO	                --LOT_NO
                                                ,V_MATNR	                --자재코드
                                                ,V_ORDER_NO	                --오더번호
                                                ,NULL	                    --오더번호 순번
                                                ,V_WRK_ORDR_NO	            --작업지시번호
                                                ,V_WRK_ORDR_SEQNO	        --작업지시 순번
                                                ,V_PRD_NO	                --생산번호
                                                ,'R'	                    --실적단위
                                                ,V_PRFM_QTY_PLT	            --실적수량
                                                ,V_PRFM_QTY_PLT	            --연수
                                                ,TO_NUMBER(NVL(P_SCNT, '0'))	--속수 
                                                ,V_PRFM_QTY_PLT      	    --매
                                                ,NULL	                    --실 지폭
                                                ,NULL	                    --권치수
                                                ,V_PRFM_WGT_PLT	            --중량
                                                ,NULL                       --선속
                                                ,NULL	                    --지관
                                                ,NULL	                    --지폭순서
                                                ,NULL	                    --밀롤창고적치여부
                                                ,NULL	                    --카타설비
                                                ,NULL	                    --LOT병합여부
                                                ,NULL	                    --등급변경여부
                                                ,NULL --T_PRD_STR_DTM	            --생산시작 일시
                                                ,NULL --T_PRD_END_DTM	            --생산 종료 일시
                                                ,NULL	                    --생산시간(분)
                                                ,P_PRFM_DT  	            --실적일자
                                                ,TO_CHAR(SYSDATE,'YYYYMMDD')      --생산일자
                                                ,NULL	                    --유통기간
                                                ,P_WRK_CLASS	            --반
                                                ,P_WRK_SHIFT	            --작업조
                                                ,V_MACHINE	                --생산호기
                                                ,V_TO_MACHINE	            --가공호기(투입호기)
                                                ,'00'	                    --상태
                                                ,V_DOC_NO_PRFM1	                    --MES 문서번호
                                                ,V_DOC_SEQNO_PRFM1	                    --MES 문서번호 순번
                                                ,NULL	                    --SAP 확정문서번호
                                                ,NULL	
                                                ,P_RMK	                    --비고
                                                ,'N'	                    --취소여부
                                                ,NULL	                    --취소사유
                                                ,SYSDATE	                --등록일시
                                                ,P_USERID	                --등록자
                                                ,NULL	                    --수정일시
                                                ,NULL	                    --수정자
                                                ,V_VBELN	                --판매문서번호
                                                ,V_POSNR	                --판매문서번호순번
                                                ,V_KUNNR	                --판매처(거래처)
                                                ,V_PACKTYPE	                --포장타입
                                                ,'01'	                    --운전상태 01:정상생산, 09:비계획생산, 00:
                                                , V_WRK_SEQ	                --생산순번
                                                ,NULL	                    --실적순서(리와인더)
                                                ,NULL	
                                                ,V_VLEN	                    --세로길이
                                                ,V_WLEN	                    --가로길이
                                                ,'Y'	                    --실적집계여부
                                                ,NULL	                    --비계획생산오더번호
                                                ,NULL	                    --비계획생산 LOT NO
                                                ,NULL	                    --LOT변경여부
                                                ,NULL	                    --영업폐품 
                                                ,TO_NUMBER(NVL(P_IN_PER_CNT, '0'))           --속당매수
                                                ,V_LOT_NO_M_1
                                                ,V_LOT_NO_M_2
                                                ,V_LOT_NO_M_3
                                                ,V_LOT_NO_M_4
                                                ,V_LOT_NO_M_5
                                                ,V_USE_REAM_M_1
                                                ,V_USE_REAM_M_2
                                                ,V_USE_REAM_M_3
                                                ,V_USE_REAM_M_4
                                                ,V_USE_REAM_M_5
                                                ,V_PACK_LABEL_TYPE 
                                        )
                                        ;                            

                                EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
                                    UPDATE TB_WRK002  SET
                                           PRFM_QTY  =  V_PRFM_QTY_PLT
                                         , PCNT      =  V_PRFM_QTY_PLT   
                                         , WGT       =  V_PRFM_WGT_PLT 
                                         , MCNT      =  V_PRFM_QTY_PLT
                                         ,PRFM_DT	 =  P_PRFM_DT           --실적일자
                                         ,PRD_DT	 =  TO_CHAR(SYSDATE,'YYYYMMDD')               --생산일자
                                         ,DOC_NO     =  V_DOC_NO_PRFM1	                    --MES 문서번호
                                         ,DOC_SEQNO  =  V_DOC_SEQNO_PRFM1	                    --MES 문서번호 순번
                                    WHERE WERKS	   =   P_WERKS          --플랜트
                                      AND MACH_CD  =   P_MACH_CD        --작업장코드(설비코드)
                                      AND IND_BCD  =   V_IND_BCD        --개별바코드
                                      AND NVL(CNL_YN,'N') = 'N'
                                   ;

                                END;

                                BEGIN
                                    INSERT INTO TB_IFS019 (
                                         AUFNR	                --오더 번호
                                        ,LOTNO	                --LOT 번호
                                        ,WERKS	                --플랜트(MES PK)
                                        ,BUDAT	                --생산일자(생산일시)(MES PK)
                                        ,MATNR	                --자재코드
                                        ,MROLLCNT	            --MR 권치수
                                        ,PROQTY	                --생산 실적
                                        ,MEINS	                --생산 단위
                                        ,RUNTIME	            --가동시간
                                        ,OPNAM	                --작업자
                                        ,CONF	                --마지막생산여부
                                        ,SDATE	                --작업시작일자(생산시스템일자)
                                        ,STIME	                --작업시작시간(생산시스템시간)
                                        ,EDATE	                --작업종료일자(생산시스템일자)
                                        ,ETIME	                --작업종료시간(생산시스템시간)
                                        ,MDOCNO	                --MES 문서번호
                                        ,MDOCSEQ	            --MES 문서순번
                                        ,RUECK	                --SAP 확정번호
                                        ,RMZHL	                --SAP 확정카운터
                                        ,ZRESULT	            --SAP 결과값 Return( S:성공, E:오류 )
                                        ,ZMESSAGE	            --SAP 결과 메시지
                                        ,ZRESULT_DATE	        --SAP 전송 시간
                                        ,MAKE_DATE	            --등록일자
                                        ,MAKER	                --등록자
                                        ,IF_MES_KEY	            --MES         --Inserface Key(MES->SAP 인 경우만)
                                    ) VALUES (
                                         V_ORDER_NO	                                                        --오더 번호
                                        ,V_LOT_NO	                                                        --LOT 번호
                                        ,P_WERKS	                                                        --플랜트(MES PK)
                                        ,P_PRFM_DT	                                                        --생산일자(생산일시)(MES PK)
                                        ,V_MATNR	                                                        --자재코드
                                        ,V_PRFM_QTY_PLT	                                                    --MR 권치수
                                        ,V_PRFM_QTY_PLT	    	                                            --생산 실적
                                        ,'R'	                                                            --생산 단위
                                        ,'0'	                                                        --가동시간
                                        ,V_USER_NM	                                                        --작업자
                                        ,NULL                                                          --마지막생산여부
                                        ,NULL                                                    --작업시작일자(생산시스템일자)
                                        ,NULL	                                                    --작업시작시간(생산시스템시간)
                                        ,NULL	                                                    --작업종료일자(생산시스템일자)
                                        ,NULL	                                                    --작업종료시간(생산시스템시간)
                                        ,V_DOC_NO_PRFM1	                                                        --MES 문서번호
                                        ,V_DOC_SEQNO_PRFM1	                                                    --MES 문서순번
                                        ,NULL	                                                            --SAP 확정번호
                                        ,NULL	                                                            --SAP 확정카운터
                                        ,NULL	                                                            --SAP 결과값 Return( S:성공, E:오류 )
                                        ,NULL	                                                            --SAP 결과 메시지
                                        ,NULL	                                                            --SAP 전송 시간
                                        ,SYSDATE	                                                        --등록일자
                                        ,P_USERID	                                                        --등록자
                                        ,NULL	                                                            --MES Inserface Key(MES->SAP 인 경우만)
                                    );

                                EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
                                
                                   UPDATE TB_IFS019  
                                      SET PROQTY   = V_PRFM_QTY_PLT
                                        , MROLLCNT = V_PRFM_QTY_PLT
                                        , AUFNR    =  V_ORDER_NO
                                   WHERE  /*AUFNR        =  V_ORDER_NO
                                     AND*/  MDOCNO	   =  V_DOC_NO_PRFM1
                                     AND  MDOCSEQ	   =  V_DOC_SEQNO_PRFM1
                                   ;

                                END;

                               /*       
                                BEGIN
                                -- 1=실적, 2=생산폐품, 3=영업폐품, 4=잔량폐품, 5=투입자재 소요량, 6=재고이전(위치), 7=재고이전(자재변경), 8=재고이전(재고실사), 9=LOT변경, 10=등급변경, 11=LOT병합, 12=LIFT출고, 20=오더완료
                        
                                        INSERT INTO TB_WRK021(DOC_NO, DOC_SEQNO, DOC_DIV, WERKS, MACH_CD, WRK_ORDR_NO, WRK_ORDR_SEQNO,
                                                            IND_BCD, LOT_NO, ORDER_NO, CNL_YN, REGDATE, REGID)
                                                    VALUES(V_DOC_NO_PRFM1, V_DOC_SEQNO_PRFM1, 1, P_WERKS, P_MACH_CD, V_WRK_ORDR_NO, V_WRK_ORDR_SEQNO,
                                                            V_IND_BCD, V_LOT_NO, V_ORDER_NO, 'N', SYSDATE, P_USERID);           

                                EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
                                
                                       UPDATE TB_WRK021  SET LOT_NO = V_LOT_NO
                                       WHERE  MDOCNO	   =  V_DOC_NO_PRFM1
                                         AND  MDOCSEQ	   =  V_DOC_SEQNO_PRFM1
                                       ;

                                END;
                            */    



                               --재고등록
                              BEGIN

                                                INSERT INTO TB_INV001 (
                                                         WERKS	                        --플랜트코드
                                                        ,STOR_LOC_CD	                --저장위치
                                                        ,IND_BCD	                    --개별바코드
                                                        ,MATNR	                        --제품코드
                                                        ,LOC_CD	                        --로케이션
                                                        ,LOT_NO	                        --LOT NO
                                                        ,MACH_CD	                    --설비코드
                                                        ,MACHINE	                    --생산호기
                                                        ,WRK_ORDR_NO	                --작업지시번호
                                                        ,WRK_ORDR_SEQNO	                --작업지시번호 순번
                                                        ,ORDER_NO	                    --오더번호
                                                        ,PRD_NO	
                                                        ,IN_MR_YN	                    --수입밀롤 여부
                                                        ,STCK_KY	                    --LOTNUM WMS KEY(저장키)
                                                        ,PRFM_DT	                    --실적일자
                                                        ,PRD_DT	                        --제조(생산)일자
                                                        ,UNIT	                        --단위
                                                        ,STCK_QTY	                    --재고수량
                                                        ,PLT_QTY	                    --PLT 수량
                                                        ,BOX_QTY	                    --BOX 수량
                                                        ,BAG_QTY	                    --BAG 수량
                                                        ,EA_QTY	                        --EA 수량
                                                        ,ROLLCNT	                    --권치수(점보롤, 밀롤, 합지기)
                                                        ,WGT	                        --중량(재단,포장공정)
                                                        ,SUPY_CD	                    --공급업체코드
                                                        ,LOT_NUM	                    --LOTNUM WMS KEY(WMS LOT 속성 KEY)
                                                        ,STCK_STA	                    --재고상태(00:정상, 10:투입, 20:생산실적, 30:불용, 40:부적합, 50:폐기)
                                                        ,VBELN	                        --판매문서
                                                        ,POSNR	                        --판매문서 항목번호
                                                        ,KUNNR	                        --판매처
                                                        ,FNL_JDGM	                    --품질판정
                                                        ,MSRM_DATE	                    --측정일시
                                                        ,PRC_SEQNO	                    --처리순번
                                                        ,INSPR_ID	                    --검사자
                                                        ,CHK_PP_YN	                    --생산확인여부
                                                        ,CHK_PP_DATE	                --생산확인일시
                                                        ,CHK_PP_ID	                    --생산확인자
                                                        ,CHK_QC_YN	                    --품질확인여부
                                                        ,CHK_QC_DATE	                --품질확인일시
                                                        ,CHK_QC_ID	                    --품질확인자
                                                        ,DOC_NO	                        --문서번호
                                                        ,DOC_SEQNO	                    --MES 문서번호순번
                                                        ,WDOC_NO	                    --WMS 참조문서 번호
                                                        ,WDOC_SEQNO	                    --WMS 참조문서아이템
                                                        ,DLFL	                        --삭제 지시자(C:출고, D:삭제)
                                                        ,REGDATE	                    --등록일시
                                                        ,REGID	                        --등록자
                                                        ,UPDDATE	                    --수정일시
                                                        ,UPDID	                        --수정자
                                                        ,RUN_STA	                    --운전상태
                                                        ,APVR_STA  	                    --결재상태   
                                                        ,CFRM_ID	                    --승인자      
                                                        ,CFRM_DATE	                    --승인일시 
                                                        ,PACK_TYPE	 
                                                        ,BS_WGT
                                                        ,CON_TYPE	
                                                        ,PACK_LABEL_TYPE 
                                                ) VALUES (
                                                         P_WERKS	                    --플랜트코드
                                                        ,'2600'	                        --저장위치
                                                        ,V_IND_BCD	                    --개별바코드
                                                        ,V_MATNR	                    --제품코드
                                                        ,'L2800'	                    --로케이션
                                                        ,V_LOT_NO	                    --LOT NO
                                                        ,P_MACH_CD	                    --설비코드
                                                        ,V_MACHINE	                    --생산호기
                                                        ,V_WRK_ORDR_NO	                --작업지시번호
                                                        ,V_WRK_ORDR_SEQNO	            --작업지시번호 순번
                                                        ,V_ORDER_NO	                    --오더번호
                                                        ,V_PRD_NO	
                                                        ,NULL	                        --수입밀롤 여부
                                                        ,NULL	                        --LOTNUM WMS KEY(저장키)
                                                        ,P_PRFM_DT	                    --실적일자
                                                        ,TO_CHAR(SYSDATE,'YYYYMMDD')	--제조(생산)일자
                                                        ,'R'	                        --단위
                                                        ,V_PRFM_QTY_PLT	           --재고수량
                                                        ,NULL	                        --PLT 수량
                                                        ,NULL	                        --BOX 수량
                                                        ,NULL	                        --BAG 수량
                                                        ,NULL	                        --EA 수량
                                                        ,NULL	                        --권치수(점보롤, 밀롤, 합지기)
                                                        ,V_PRFM_WGT_PLT	                --중량(재단,포장공정)
                                                        ,NULL	                        --공급업체코드
                                                        ,NULL	                        --LOTNUM WMS KEY(WMS LOT 속성 KEY)
                                                        ,'00'	                        --재고상태(00:정상, 10:투입, 20:생산실적, 30:불용, 40:부적합, 50:폐기)
                                                        ,V_VBELN	                        --판매문서
                                                        ,V_POSNR	                        --판매문서 항목번호
                                                        ,V_KUNNR	                        --판매처
                                                        ,NULL	                        --품질판정
                                                        ,NULL	                        --측정일시
                                                        ,NULL	                        --처리순번
                                                        ,NULL	                        --검사자
                                                        ,NULL	                        --생산확인여부
                                                        ,NULL	                        --생산확인일시
                                                        ,NULL	                        --생산확인자
                                                        ,NULL	                        --품질확인여부
                                                        ,NULL	                        --품질확인일시
                                                        ,NULL	                        --품질확인자
                                                        ,V_DOC_NO	                        --문서번호
                                                        ,V_DOC_SEQNO	                        --MES 문서번호순번
                                                        ,NULL	                        --WMS 참조문서 번호
                                                        ,NULL	                        --WMS 참조문서아이템
                                                        ,'N'	                        --삭제 지시자(C:출고, D:삭제)
                                                        ,SYSDATE	                    --등록일시
                                                        ,P_USERID	                    --등록자
                                                        ,NULL	                        --수정일시
                                                        ,NULL	                        --수정자
                                                        ,NULL	                        --운전상태
                                                        ,NULL  	                        --결재상태   
                                                        ,NULL	                        --승인자      
                                                        ,NULL	                        --승인일시  
                                                        ,V_PACKTYPE 
                                                        ,V_BS_WGT
                                                        ,V_CON_TYPE	 
                                                        ,V_PACK_LABEL_TYPE 
                                                );

                              EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
                                            UPDATE TB_INV001  SET
                                                   STCK_QTY  =  V_PRFM_QTY_PLT 
                                                  ,PRFM_DT	 =  P_PRFM_DT                   --실적일자
                                                  ,PRD_DT	 =  TO_CHAR(SYSDATE,'YYYYMMDD')                       --제조(생산)일자
                                                  ,WGT       =  V_PRFM_WGT_PLT
                                                  ,VBELN	 =  V_VBELN                        --판매문서
                                                  ,POSNR	 =  V_POSNR                       --판매문서 항목번호  
                                                  ,KUNNR	 =  V_KUNNR                       --판매처
                                                  ,PACK_TYPE =	V_PACKTYPE
                                                  ,BS_WGT    =  V_BS_WGT
                                                  ,CON_TYPE  =	V_CON_TYPE  
                                            WHERE WERKS	        =   P_WERKS          --플랜트
                                              AND STOR_LOC_CD   =   '2000'           --작업장코드(설비코드)
                                              AND IND_BCD       =   V_IND_BCD        --개별바코드
                                              AND MATNR         =   V_MATNR
                                           ;

                              END;

                                        --자재소요량
                              UPDATE TB_INV003                -- 자재투입량 실적
                                 SET USE_QTY  = NVL(USE_QTY, 0)  + (V_USE_REAM_M /* * 500 */ )
                                   , STCK_QTY = NVL(STCK_QTY, 0) - (V_USE_REAM_M /* * 500 */ )
                               WHERE WERKS = P_WERKS
                                 AND MACH_CD = P_MACH_CD
                                 AND IND_BCD = V_IND_BCD_M;                               


                                V_DOC_NO := FN_GET_MDOCNO('M','IF130'); 
                                V_DOC_SEQNO :=   V_DOC_SEQNO +1; 
                                
                                V_DOC_NO_INPUT := V_DOC_NO_INPUT||V_DOC_NO||',' ;
                                  
                                INSERT INTO TB_IFS008(AUFNR, POSNR, BUDAT, MATNR, MENGE, LGORT, CHARG,
                                        MDOCNO, MDOCSEQ, MAKE_DATE, MAKER, WORKCENTERCODE, WERKS)
                                VALUES( V_ORDER_NO, V_POSNR, P_PRFM_DT, V_MATNR_M, V_USE_REAM_M, '2000', V_LOT_NO_M,
                                        V_DOC_NO, V_DOC_SEQNO, SYSDATE, V_SESS_USER_ID, V_SAP_WRK_CD, P_WERKS);
                                
                                V_SEQNO := 0 ;

                                BEGIN
                                    SELECT NVL(MAX(SEQNO), 0)
                                    INTO   V_SEQNO
                                    FROM TB_INV010
                                    WHERE WERKS    = P_WERKS
                                      AND MACH_CD  = P_MACH_CD
                                      AND MATNR    = V_MATNR
                                      AND IND_BCD  = V_IND_BCD
                                      AND NVL(CNL_YN,'N') = 'N'
                                      ;
                                EXCEPTION WHEN NO_DATA_FOUND THEN       
                                    V_SEQNO := 0 ;
                                END;

                                V_SEQNO := V_SEQNO + 1 ;

                                --자재 투입이력
                                INSERT INTO TB_INV010( WERKS, MACH_CD, MATNR, IND_BCD, SEQNO, WRK_ORDR_NO, WRK_ORDR_SEQNO,
                                                    LOT_NO, IND_BCD_M, LOT_NO_M, MATNR_M, INP_DT, PRFM_DT,
                                                    USE_QTY, UNIT, ROLLCNT, WGT, CHG_FLG, STCK_KY, LOT_NUM,
                                                    REGDATE, REGID, USE_DIV, DOC_NO, DOC_SEQNO) 
                                            VALUES(P_WERKS, P_MACH_CD, V_MATNR, V_IND_BCD, V_SEQNO, V_WRK_ORDR_NO, V_WRK_ORDR_SEQNO,
                                                    V_LOT_NO, V_IND_BCD_M, V_LOT_NO_M, V_MATNR_M, P_PRFM_DT, TO_CHAR(SYSDATE,'YYYYMMDD'),
                                                    V_USE_REAM_M , 'R', NULL,V_USE_WGT_M  , 'N', '', '', 
                                                   SYSDATE, P_USERID, '1', V_DOC_NO, V_DOC_SEQNO);   

                                /*  
                                -- 1=실적, 2=생산폐품, 3=영업폐품, 4=잔량폐품, 5=투입자재 소요량, 6=재고이전(위치), 7=재고이전(자재변경), 8=재고이전(재고실사), 9=LOT변경, 10=등급변경, 11=LOT병합, 12=LIFT출고, 20=오더완료
                                INSERT INTO TB_WRK021(DOC_NO, DOC_SEQNO, DOC_DIV, WERKS, MACH_CD, WRK_ORDR_NO, WRK_ORDR_SEQNO,
                                                    IND_BCD, LOT_NO, ORDER_NO, CNL_YN, REGDATE, REGID)
                                            VALUES(V_DOC_NO, V_DOC_SEQNO, 2, P_WERKS, P_MACH_CD, V_WRK_ORDR_NO, V_WRK_ORDR_SEQNO,
                                                    V_IND_BCD, V_LOT_NO, V_ORDER_NO, 'N', SYSDATE, P_USERID);           
                                */


                                V_PLT_NO_PRE := V_PLT_NO ;
                        END IF;                        
               END LOOP;         
           END IF ;

            ---  폐품  ----------------------------------------        
            IF V_DISPO_QTY  > 0      THEN  
               V_JSON := JSON_OBJECT_T.PARSE(P_WRK_LIST);
               V_ARR_LIST := V_JSON.GET_ARRAY('list');
               V_SEQ := 0 ;
               V_PLT_NO_PRE := 0;
               --RS_IND_BCD   := '';
               V_PRFM_QTY_PLT := 0 ;
               V_PRFM_WGT_PLT := 0 ;
               V_DOC_SEQNO    := 0 ; 
               --V_DOC_SEQNO_INPUT := 0 ; 
               V_SEQNO           := 0 ;  

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


               FOR I IN 0..V_ARR_LIST.GET_SIZE - 1 LOOP
                        V_OBJ := TREAT(V_ARR_LIST.GET(I) AS JSON_OBJECT_T);
                        V_OBJ := TREAT(V_OBJ.GET('map') AS JSON_OBJECT_T);

                        V_GUBUN             := V_OBJ.GET_STRING('GUBUN');                       --'1' 은 실적, '2'은 부분실적
                        V_PLT_NO            := TO_NUMBER(V_OBJ.GET_STRING('PLT_NO'));           --팔레트번호
                        V_IND_BCD_M         := V_OBJ.GET_STRING('IND_BCD_M');                   --재단 개별바코드
                        V_LOT_NO_M          := V_OBJ.GET_STRING('LOT_NO_M');                    --재단 LOT_NO
                        V_USE_REAM_M        := TO_NUMBER(V_OBJ.GET_STRING('USE_REAM_M'));       --재단 개별바코드 사용연수
                        V_USE_WGT_M         := TO_NUMBER(V_OBJ.GET_STRING('USE_WGT_M'));        --재단 개별바코드 사용중량
                        V_MATNR_M           := V_OBJ.GET_STRING('MATNR_M');                     --재단 자재
                        V_WRK_ORDR_NO_M     := V_OBJ.GET_STRING('WRK_ORDR_NO_M');               --재단 작업지시번호
                        V_WRK_ORDR_SEQNO_M  := TO_NUMBER(V_OBJ.GET_STRING('WRK_ORDR_SEQNO_M')); --재단 작업지시순번
                        V_WRK_ORDR_NO       := V_OBJ.GET_STRING('WRK_ORDR_NO');                 --포장 작업지시번호
                        V_WRK_ORDR_SEQNO    := TO_NUMBER(V_OBJ.GET_STRING('WRK_ORDR_SEQNO'));   --포장 작업지시순번

                        IF V_GUBUN  = '3'  THEN
                                  SELECT  MATNR            MATNR
                                                 ,  NULL          MACHINE
                                                 ,  LOT_BUF          LOT_BUF
                                                 ,  ORDER_NO         ORDER_NO
                                                 ,  UNIT             UNIT
                                                 ,  NULL             TO_MACHINE 
                                                 ,  PACKTYPE         PACKTYPE 
                                                 ,  NULL             ORDER_RMK 
                                                 ,  VLEN	         VLEN
                                                 ,  WLEN             WLEN
                                                 ,  VBELN	         VBELN  
                                                 ,  POSNR	         POSNR  
                                                 ,  KUNNR	         KUNNR 
                                                 ,  BS_WGT	         BS_WGT   
                                                 ,  NULL	         CON_TYPE 
                                    INTO    V_MATNR
                                         ,  V_MACHINE
                                         ,  V_LOT_BUF
                                         ,  V_ORDER_NO
                                         ,  V_UNIT
                                         ,  V_TO_MACHINE
                                         ,  V_PACKTYPE
                                         ,  V_RMK
                                         ,  V_VLEN	
                                         ,  V_WLEN	
                                         ,  V_VBELN	  
                                         ,  V_POSNR	  
                                         ,  V_KUNNR	  
                                         ,  V_BS_WGT	    
                                         ,  V_CON_TYPE	
                                    FROM TB_SCH019
                                    WHERE WRK_ORDR_NO      = V_WRK_ORDR_NO
                                      AND WRK_ORDR_SEQNO   = V_WRK_ORDR_SEQNO
                                      ;

                                    --개별바코드
                                    IF V_IND_BCD  IS NULL   THEN
                                        SP_GET_BARCODE_SEQ('IND', P_WERKS, 'Z', V_MATNR, TO_CHAR(SYSDATE,'YYYYMMDDHH24MISS'),
                                                      V_IND_BCD);
--                                        SP_GET_BARCODE_SEQ('IND', P_WERKS, P_MACH_CD, V_MATNR, TO_CHAR(SYSDATE,'YYYYMMDDHH24MISS'),
--                                                      V_IND_BCD);

                                        RS_IND_BCD := RS_IND_BCD || V_IND_BCD|| '|';    -- 개별 바코드 구분자 로 여러개 전달
                                        V_LIST_IND_BCD := V_LIST_IND_BCD ||V_IND_BCD|| ','; 
                                    END IF;

                                    --문서번호
                                    V_DOC_NO := FN_GET_MDOCNO('M', 'IF134');
                                    V_DOC_SEQNO := V_DOC_SEQNO + 1;
                                    
                                    V_DOC_NO_DISPO := V_DOC_NO_DISPO||V_DOC_NO||',' ;
                                    
                                    --IF V_LOT_NO IS NULL OR TRIM(V_LOT_NO) = '' THEN
                                        SP_CHK_LOT_NO(V_LOT_BUF, P_WERKS, P_MACH_CD, V_MATNR, TO_CHAR(SYSDATE,'YYYYMMDDHH24MISS'), V_LOT_NO);

                                        UPDATE TB_SCH019   SET LOT_BUF = V_LOT_NO
                                         WHERE WRK_ORDR_NO      = V_WRK_ORDR_NO
                                           AND WRK_ORDR_SEQNO   = V_WRK_ORDR_SEQNO
                                            ;
                                    --END IF;

                                  INSERT INTO TB_WRK004   --폐품 실적
                                  (
                                         WERKS	                --플랜트
                                        ,MACH_CD	            --작업장코드(설비코드)
                                        ,IND_BCD	            --개별바코드
                                        ,LOT_NO	                --LOT_NO
                                        ,MATNR	                --자재코드
                                        ,DISPO_CD	            --폐품코드
                                        ,WRK_ORDR_NO	        --작업지시번호
                                        ,WRK_ORDR_SEQNO	        --작업지시 순번
                                        ,MMATNR	                --투입자재의 자재코드
                                        ,IND_BCD_M	            --투입자재의 개별바코드
                                        ,LOT_NO_M	            --투입자재의LOTNO
                                        ,UNIT	                --실적단위
                                        ,ROLLCNT	            --폐품권치수
                                        ,DISPO_QTY	            --폐품수량
                                        ,MACHINE	            --생산호기
                                        ,WGT	                --중량
                                        ,RSPEED	                --선속
                                        ,PRD_STR_DATE	        --생산시작 일시
                                        ,PRD_END_DATE	        --생산 종료 일시
                                        ,TM	                    --생산시간(분)
                                        ,PRFM_DT	            --실적일자
                                        ,WRK_CLASS	            --작업반
                                        ,WRK_SHIFT	            --작업조
                                        ,RUN_STA	            --운전상태
                                        ,DOC_NO	                --문서번호
                                        ,DOC_SEQNO	            --MES문서번호 순번
                                        ,SDOC_NO	            --SAP 확정문서번호
                                        ,SDOC_SEQNO	
                                        ,RMK	                --비고
                                        ,REGDATE	            --등록일시
                                        ,REGID	                --등록자
                                        ,UPDDATE	            --수정일시
                                        ,UPDID	                --수정자 
                                        ,CNL_YN
                                        ,ORDER_NO
                                  ) 
                                  VALUES
                                  (
                                         P_WERKS	            --플랜트
                                        ,P_MACH_CD	            --작업장코드(설비코드)
                                        ,V_IND_BCD	            --개별바코드
                                        ,V_LOT_NO	            --LOT_NO
                                        ,V_MATNR	            --자재코드
                                        ,P_DISPO_CD	            --폐품코드
                                        ,V_WRK_ORDR_NO	        --작업지시번호
                                        ,V_WRK_ORDR_SEQNO	    --작업지시 순번
                                        ,V_MATNR_M	            --투입자재의 자재코드
                                        ,V_IND_BCD_M	        --투입자재의 개별바코드
                                        ,V_LOT_NO_M	            --투입자재의LOTNO
                                        ,'EA'	                --실적단위
                                        ,NULL	                --폐품권치수
                                        ,V_USE_REAM_M * 500	    --폐품수량
                                        ,V_MACHINE	            --생산호기
                                        ,V_USE_WGT_M	        --중량
                                        ,NULL	                --선속
                                        ,NULL	                --생산시작 일시
                                        ,NULL	                --생산 종료 일시
                                        ,NULL	                --생산시간(분)
                                        ,TO_CHAR(SYSDATE,'YYYYMMDD')      --실적일자
                                        ,P_WRK_CLASS	        --작업반
                                        ,P_WRK_SHIFT	        --작업조
                                        ,'02'	                --운전상태
                                        ,V_DOC_NO               --문서번호
                                        ,V_DOC_SEQNO	        --MES문서번호 순번
                                        ,NULL	                --SAP 확정문서번호
                                        ,NULL	
                                        ,P_RMK	                --비고
                                        ,SYSDATE	            --등록일시
                                        ,P_USERID	            --등록자
                                        ,NULL	                --수정일시
                                        ,NULL	                --수정자   
                                        ,'N'
                                        ,V_ORDER_NO
                                  );


                                IF  P_DISPO_GROUP = 'P'  THEN
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
                                                SCRAPCODE_OP,
                                                SCRAPREASON_OP,
                                                SDATE,
                                                STIME,
                                                EDATE,
                                                ETIME
                                            ) VALUES (
                                                V_ORDER_NO,
                                                V_LOT_NO,
                                                TO_CHAR(TO_DATE(P_PRFM_DT, 'YYYY-MM-DD'), 'YYYY-MM-DD'),
                                                V_MATNR_M,
                                                NULL, 
                                                0,
                                                0,
                                                NULL,
                                                NULL,
                                                '2000',                    --'2000',
                                                V_LOT_NO_M,
                                                V_DOC_NO,
                                                V_DOC_SEQNO,
                                                TO_CHAR(SYSDATE,'YYYYMMDD'),
                                                P_USERID,
                                                V_VBELN,
                                                V_POSNR,
                                                V_SAP_WRK_CD,
                                                0,
                                                V_USE_REAM_M * 500,
                                                P_DISPO_CD,
                                                P_DISPO_NM,
                                                NULL, --TO_CHAR(V_PRD_STR_DATE,'YYYY-MM-DD'), 
                                                NULL, --TO_CHAR(V_PRD_STR_DATE,'HH24:MI:SS'),
                                                NULL, --TO_CHAR(V_PRD_END_DATE,'YYYY-MM-DD'), 
                                                NULL  --TO_CHAR(V_PRD_END_DATE,'HH24:MI:SS')
                                            );
                                ELSE
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
                                                SCRAPCODE_OP,
                                                SCRAPREASON_OP,
                                                SDATE,
                                                STIME,
                                                EDATE,
                                                ETIME
                                            ) VALUES (
                                                V_ORDER_NO,
                                                V_LOT_NO,
                                                TO_CHAR(TO_DATE(P_PRFM_DT, 'YYYY-MM-DD'), 'YYYY-MM-DD'),
                                                V_MATNR_M,
                                                V_USE_REAM_M * 500, 
                                                0,
                                                0,
                                                P_DISPO_CD,
                                                P_DISPO_NM,
                                                '2000',                    --'2000',
                                                V_LOT_NO_M,
                                                V_DOC_NO,
                                                V_DOC_SEQNO,
                                                TO_CHAR(SYSDATE,'YYYYMMDD'),
                                                P_USERID,
                                                V_VBELN,
                                                V_POSNR,
                                                V_SAP_WRK_CD,
                                                0,
                                                NULL,
                                                NULL,
                                                NULL,
                                                NULL, --TO_CHAR(V_PRD_STR_DATE,'YYYY-MM-DD'), 
                                                NULL, --TO_CHAR(V_PRD_STR_DATE,'HH24:MI:SS'),
                                                NULL, --TO_CHAR(V_PRD_END_DATE,'YYYY-MM-DD'), 
                                                NULL  --TO_CHAR(V_PRD_END_DATE,'HH24:MI:SS')
                                            );
                               
                                END IF;

                                 UPDATE TB_INV003                -- 자재투입량 폐품 1
                                   SET DISPO_QTY = NVL(DISPO_QTY, 0) + (V_USE_REAM_M /* * 500*/ ),
                                       USE_QTY   = NVL(USE_QTY, 0)   + (V_USE_REAM_M /* * 500*/ ),
                                       STCK_QTY  = NVL(STCK_QTY, 0)  - (V_USE_REAM_M /* * 500*/ )
                                  WHERE WERKS   = P_WERKS
                                    AND MACH_CD = P_MACH_CD
                                    AND IND_BCD = V_IND_BCD_M;

                        END IF;
               END LOOP;         
            END IF ; 

            RS_IND_BCD := SUBSTR(RS_IND_BCD, 1, length(RS_IND_BCD)-1);
            V_LIST_IND_BCD := SUBSTR(V_LIST_IND_BCD, 1, length(V_LIST_IND_BCD)-1);

            V_DOC_NO_DISPO     := SUBSTR(V_DOC_NO_DISPO, 1,LENGTH(V_DOC_NO_DISPO)-1);
            V_DOC_NO_INPUT     := SUBSTR(V_DOC_NO_INPUT, 1,LENGTH(V_DOC_NO_INPUT)-1);
            V_DOC_NO_PRFM      := SUBSTR(V_DOC_NO_PRFM , 1,LENGTH(V_DOC_NO_PRFM)-1);
            V_DOC_NO_SDISPO    := SUBSTR(V_DOC_NO_SDISPO, 1,LENGTH(V_DOC_NO_SDISPO)-1);
            
        IF LENGTH(V_DOC_NO_PRFM) > 0   THEN   --실적

                     --SAP FUNC ID
                     SELECT RFCFN
                       INTO RS_PRFM_RFCFN
                       FROM TB_ITFMA
                      WHERE 1=1
                        AND IFID = 'MES_IF_141';   --생산오더별 실적 취소 TXN

                     --인터페이스 파라미터
                     OPEN CUR_1 FOR
                     SELECT 'MES_IF_141' AS I_IF_ID
                          , 'M' || LTRIM(RTRIM(TO_CHAR(SEQ_GET_IFR_KEY.NEXTVAL, '00000000000000000000000000000'))) AS I_IF_KEY
                       FROM dual;

                     --인터페이스 상세 파라미터
                     V_SQL := FN_IF_QUERY('MES_IF_141', V_DOC_NO_PRFM);
                     OPEN CUR_2 FOR V_SQL;

        END IF ;  


          IF LENGTH(V_DOC_NO_DISPO) > 0   THEN   --폐품
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


        IF LENGTH(V_DOC_NO_INPUT) > 0   THEN   --투입량

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
