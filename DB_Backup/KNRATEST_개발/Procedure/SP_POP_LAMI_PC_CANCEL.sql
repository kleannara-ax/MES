--------------------------------------------------------
--  DDL for Procedure SP_POP_LAMI_PC_CANCEL
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_POP_LAMI_PC_CANCEL" 
(
     P_WERKS     		IN VARCHAR2 	                --플랜트
    ,P_MACH_CD   		IN VARCHAR2 	                --설비코드
    ,P_IND_BCD_LIST     IN CLOB			   	            --개별바코드 리스트
    ,P_CNL_RMK          IN TB_LAMI_PC.SAL_RMK%TYPE      --작업완료 취소사유
    ,P_USERID           IN VARCHAR2                     --USER ID
    ,RS_PRFM_RFCFN      OUT VARCHAR2                    --실적 RFCFN값
    ,RS_DISPO_RFCFN     OUT VARCHAR2                    --폐품 RFCFN값    
    ,RS_INPUT_RFCFN     OUT VARCHAR2                    --투입량 RFCFN값    
    ,RS_SDISPO_RFCFN    OUT VARCHAR2                    --잔량 폐품 RFCFN값    
    ,Lang       		IN VARCHAR2 DEFAULT 'KO'
    ,RS_CODE     		OUT VARCHAR2 
    ,RS_MSG      		OUT VARCHAR2
    ,CUR_1              OUT SYS_REFCURSOR               --실적
    ,CUR_2              OUT SYS_REFCURSOR
    ,CUR_3              OUT SYS_REFCURSOR               --폐품
    ,CUR_4              OUT SYS_REFCURSOR
    ,CUR_5              OUT SYS_REFCURSOR               --투입량
    ,CUR_6              OUT SYS_REFCURSOR    
    ,CUR_7              OUT SYS_REFCURSOR               --영업+잔량 폐품
    ,CUR_8              OUT SYS_REFCURSOR

)
/*==============================================================================
 * PROGRAM ID    : SP_POP_WRK30_I08{호출 프로그램 ID 기술}
 * PROGRAM NAME  : 라미네이팅실적취소 
 * VERSION       : 1.0.0{최종 버전 기술}
 * DESCRIPTION   : .{프로그램에 대한 상세한 내용 기술}
 *                 
 * AUTHOR NAME   : 김수현{최초 작성자 명 기술}
 * CREATE DATE   : 2022/12/12 {최초 작성일자 기술}
 * SYSTEM NAME   : POP
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}  <생략가능>
 * SUB PROCEDURE : {아휘 프로시저 명칭 기술}      <생략가능>
 * SUB PACKAGES  : {하위 패키지 기술}            <생략가능>
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술} <생략가능>
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/12/12    1.0.0   김수현         Initial Version 
 *==============================================================================
 *  관련 테이블
 *       - [TB_LAMI_PC] : (.RU.) 라미네이팅 인쇄코팅 실적 
 *       - [TB_LAMI_PC_RESULT] : (C.U.) 라미네이팅 인쇄코팅 실적 분할  
 *=============================================================================*/

AS 
    --프로그램 ID : 재단 실적취소 
    V_PRG_NM        VARCHAR2(100)  := 'SP_POP_WRK30_I08';     -- PROCEDURE NAME
    V_PLT_CD         varchar2(2) := '99'; --PLANTCODE TEST
    V_SESS_USER_ID   varchar2(20) := P_USERID; --USERID
    V_CNT1                       NUMBER(13,0);
    V_CNT2                       NUMBER(13,0);

    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD      NUMBER(5) := 0;
    E_SQL_ERR_MSG     VARCHAR2(4000);

    -- JSON을 위한 변수선언 영역
    V_JSON           JSON_OBJECT_T;
    V_ARR_LIST       JSON_ARRAY_T;
    V_ARR_HEAD       JSON_OBJECT_T;
    V_OBJ            JSON_OBJECT_T;

    --parameter변수 처리
    V_IND_BCD           TB_WRK002.IND_BCD%TYPE;      -- 개별바코드

    V_WRK_ORDR_NO           TB_SCH015.WRK_ORDR_NO%TYPE;         
    V_WRK_ORDR_SEQNO        TB_SCH015.WRK_ORDR_SEQNO%TYPE;      


    V_ORDER_NO              TB_WRK002.ORDER_NO%TYPE;
    --V_PRE_ORDER_NO              TB_WRK002.ORDER_NO%TYPE;
    V_STA                   TB_WRK002.STA%TYPE;
    V_SDOC_NO               TB_WRK002.SDOC_NO%TYPE;
    V_SDOC_SEQNO            TB_WRK002.SDOC_SEQNO%TYPE;
    V_SAP_WRK_CD            TB_MAS012.SAP_WRK_CD%TYPE;
    V_ROLLCNT	            TB_WRK002.ROLLCNT%TYPE;		    --권치수
    V_DOC_NO                VARCHAR2(20);
    V_DOC_SEQNO             NUMBER;
    V_DOC_NO_INPUT          VARCHAR2(20);
    V_DOC_NO_INPUTSUM          VARCHAR2(500);
    V_DOC_SEQNO_INPUT       NUMBER;
    V_DOC_NO_DISPO          VARCHAR2(20);
    V_DOC_NO_DISPO_S1          VARCHAR2(20);
    V_DOC_NO_DISPO_S2          VARCHAR2(20);
    V_DOC_SEQNO_DISPO       NUMBER;

    V_PRFM_QTY	            TB_WRK002.PRFM_QTY%TYPE;     --실적수량
    V_DISPO_QTY	            TB_WRK004.DISPO_QTY%TYPE;    --폐품수량
    V_DISPO_WGT             TB_WRK004.WGT%TYPE;          --폐품중량
    V_MATNR                 TB_WRK004.MATNR%TYPE;        --자재코드
    V_PRFM_DT               VARCHAR2(20);   
    V_LOT_NO                VARCHAR2(20);   
    V_INP_DT	            TB_INV003.INP_DT%TYPE;        --투입일자
    V_STOR_LOC_CD           TB_INV001.STOR_LOC_CD%TYPE;
    V_SQL                   VARCHAR2(4000);
    V_IND_BCD_M             TB_WRK002.IND_BCD%TYPE;      -- 자재개별바코드
    V_TOT_QTY               NUMBER(13,3);
    V_WGT                   NUMBER(13,3); 
    V_DMY                   VARCHAR2(1);          
    V_GRD_YN                VARCHAR2(5);          
    V_YMCHK                     TB_MAS011.YMCHK%TYPE;   --실적등록 가능 여부    
    V_MACH_CD                VARCHAR2(20);   
BEGIN
  BEGIN

    V_JSON := JSON_OBJECT_T.parse(P_IND_BCD_LIST);

    V_ARR_LIST        := V_JSON.get_array('list');    

    V_DOC_NO_INPUTSUM:= '' ;

    FOR i IN 0..V_ARR_LIST.get_size-1 LOOP    
        V_OBJ               := TREAT (V_ARR_LIST.get (i) AS json_object_t);
        V_OBJ               := TREAT (V_OBJ.get ('map') AS json_object_t);
        V_IND_BCD           := V_OBJ.get_string('IND_BCD');
        V_WRK_ORDR_NO       := V_OBJ.get_string('WRK_ORDR_NO');
        V_WRK_ORDR_SEQNO    := V_OBJ.get_string('WRK_ORDR_SEQNO');
        V_ORDER_NO           := V_OBJ.get_string('ORDER_NO');


        V_DOC_SEQNO        := 0;
        V_DOC_SEQNO_INPUT  := 0;
        V_DOC_SEQNO_DISPO  := 0;


        -- 실적 취소------------------------------------------------------------------------------------------

         SELECT MATNR, ORDER_NO, DOC_NO, PRFM_QTY, MACH_CD
         INTO V_MATNR, V_ORDER_NO, V_DOC_NO, V_PRFM_QTY, V_MACH_CD
         FROM TB_LAMI_PC
         WHERE WRK_ORDR_NO = V_WRK_ORDR_NO  
           AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
           AND IND_BCD = V_IND_BCD;

        SELECT NVL(COUNT(*),0)
        INTO V_CNT1
        FROM TB_LAMI_RESULT
        WHERE 1 = 1
        AND WRK_ORDR_NO = V_WRK_ORDR_NO
        AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
        AND WERKS = P_WERKS
        ;

        SELECT NVL(COUNT(*),0)
        INTO V_CNT2
        FROM TB_LAMI_PC_RESULT
        WHERE 1 = 1
        AND WRK_ORDR_NO = V_WRK_ORDR_NO
        AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
        AND WERKS = P_WERKS
        ;

--        SELECT NVL(COUNT(*),0)
--        INTO V_CNT3
--        FROM TB_LAMI_SL_RESULT
--        WHERE 1 = 1
--        AND WRK_ORDR_NO = V_WRK_ORDR_NO
--        AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
--        AND WERKS = P_WERKS
--        ;

        DELETE FROM TB_WRK021 WHERE WRK_ORDR_NO = V_WRK_ORDR_NO AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO AND WERKS = P_WERKS; --문서이력(DELETE)
        DELETE FROM TB_WRK008 WHERE WRK_ORDR_NO = V_WRK_ORDR_NO AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO AND WERKS = P_WERKS; --LOT 추적(DELETE)
        DELETE FROM TB_INV010 WHERE WRK_ORDR_NO = V_WRK_ORDR_NO AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO AND WERKS = P_WERKS; --자재투입이력(DELETE)
        DELETE FROM TB_WRK022 WHERE WRK_ORDR_NO = V_WRK_ORDR_NO AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO AND WERKS = P_WERKS;--영업잔량폐품실적(DELETE)
        DELETE FROM TB_INV001 WHERE WRK_ORDR_NO = V_WRK_ORDR_NO AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO AND WERKS = P_WERKS;--(UPDATE)

        --COMMIT;

		UPDATE TB_LAMI_PC
		   SET LOT_BUF = ''
			  ,IND_BCD = ''
			  ,DOC_NO = ''
			  ,RES_DT = ''
			  ,PRFM_QTY = 0
--			  ,PRFM_QTY = P_WGT(잔량 수량을 SAP에서 허용하지 않으면 이것을 사용한다)
			  ,CYCLE_TIME = 0
			  ,SAPYN = 'N'
			  ,SALCODE = ''
			  ,SALWEIGHT = 0
			  ,PPCODE = ''
			  ,HEIGHT = 0
			  ,EQUIL = 0
			  ,STD = 0
		      ,USE_YN = 'Y'
              ,COMP_YN = 'I'
              ,REMAIN_QTY = WRK_ORDR_QTY
              ,PRD_END_DTM = ''
              ,PRD_END_DT = ''
		 WHERE WRK_ORDR_NO = V_WRK_ORDR_NO  
		   AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
           AND WERKS = P_WERKS
		   AND NVL(USE_YN, 'N') = 'N'
           ;

--		UPDATE TB_LAMI_PC_RESULT
--		   SET USE_YN = 'Y'
--		 WHERE WRK_ORDR_NO = P_WRK_ORDR_NO  
--		   AND WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO
--           AND WERKS = P_WERKS
--		   --AND NVL(DLFL,'N') = 'N'  --삭제지시자 X='삭제' , N=정상오더
--		   AND NVL(USE_YN, 'N') = 'N'
--           ;

        IF V_CNT2 > 0 THEN
            BEGIN
                DELETE FROM TB_LAMI_PC_RESULT
                 WHERE WRK_ORDR_NO = V_WRK_ORDR_NO  
                   AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
                   AND WERKS = P_WERKS
                   --AND NVL(DLFL,'N') = 'N'  --삭제지시자 X='삭제' , N=정상오더
--                   AND NVL(USE_YN, 'N') = 'N'
                   AND NVL(SL_MOVE_YN, 'Y') = 'Y'
                   ;
            END;
        END IF;

--        IF V_CNT3 > 0 THEN
--            BEGIN
--                DELETE FROM TB_LAMI_SL_RESULT
--                 WHERE WRK_ORDR_NO = V_WRK_ORDR_NO  
--                   AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
--                   AND WERKS = P_WERKS
--                   --AND NVL(DLFL,'N') = 'N'  --삭제지시자 X='삭제' , N=정상오더
--                   AND NVL(USE_YN, 'N') = 'N'
--                   ;
--            END;
--        END IF;

        IF V_CNT1 > 0 THEN
            BEGIN
                 DELETE FROM TB_LAMI_RESULT
                 WHERE WRK_ORDR_NO = V_WRK_ORDR_NO  
                   AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
                   AND WERKS = P_WERKS;

                INSERT INTO TB_LAMI_RESULT
                SELECT 
                A.WERKS
                ,A.MACH_CD
                ,A.IND_BCD
                ,A.LOT_NO
                ,A.MATNR
                ,A.ORDER_NO
                ,A.ORDER_SEQNO
                ,A.WRK_ORDR_NO
                ,A.WRK_ORDR_SEQNO
                ,A.PRD_NO
                ,A.UNIT
                ,A.PRFM_QTY
                ,A.PCNT
                ,A.SCNT
                ,A.MCNT
                ,A.WIDTH
                ,A.ROLLCNT
                ,A.WGT
                ,A.RSPEED
                ,A.CORE
                ,A.WIDTH_NO
                ,A.MRLDCK
                ,A.CUTTER
                ,A.MER_YN
                ,A.GRD_YN
                ,A.PRD_STR_DATE
                ,A.PRD_END_DATE
                ,A.TM
                ,A.PRFM_DT
                ,A.PRD_DT
                ,A.DSTBT_DDLIN
                ,A.WRK_CLASS
                ,A.WRK_SHIFT
                ,A.MACHINE
                ,A.TO_MACHINE
                ,A.STA
                ,A.DOC_NO
                ,A.DOC_SEQNO
                ,A.SDOC_NO
                ,A.SDOC_SEQNO
                ,A.RMK
                ,A.CNL_YN
                ,P_CNL_RMK
                ,A.REGDATE
                ,A.REGID
                ,A.UPDDATE
                ,A.UPDID
                ,A.VBELN
                ,A.POSNR
                ,A.KUNNR
                ,A.PACKTYPE
                ,A.RUN_STA
                ,A.WRK_SEQ
                ,A.PRD_SEQ
                ,A.LOT_NO_BUF
                ,A.VLEN
                ,A.WLEN
                ,A.PRFM_GTHR_YN
                ,A.NAUFNR
                ,A.LOT_NO_PRE
                ,A.LOT_CHG_YN
                ,A.RMD_QTY
                ,A.MER_IND_BCD
                ,A.MER_RMK
                ,A.IN_PER_CNT
                ,A.MAN_CUT_YN
                ,A.LOT_NO_M1
                ,A.LOT_NO_M2
                ,A.LOT_NO_M3
                ,A.LOT_NO_M4
                ,A.LOT_NO_M5
                ,A.USE_REAM_M1
                ,A.USE_REAM_M2
                ,A.USE_REAM_M3
                ,A.USE_REAM_M4
                ,A.USE_REAM_M5
                ,A.PACK_LABEL_TYPE
                ,A.JRCOM_YN
                ,A.MRCOM_YN
                ,'X'
                ,A.CACOM_YN
                FROM TB_WRK002 A
                 WHERE A.WRK_ORDR_NO = V_WRK_ORDR_NO  
                   AND A.WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
                   AND A.WERKS = P_WERKS
                   AND A.MACH_CD = V_MACH_CD;

            DELETE FROM TB_WRK002 WHERE WRK_ORDR_NO = V_WRK_ORDR_NO AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO AND WERKS = P_WERKS; --실적(DELETE)

           END;
        ELSIF V_CNT1 = 0 THEN
            BEGIN

--             DELETE FROM TB_LAMI_RESULT
--             WHERE WRK_ORDR_NO = P_WRK_ORDR_NO  
--               AND WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO
--               AND WERKS = P_WERKS;

                INSERT INTO TB_LAMI_RESULT
                SELECT 
                A.WERKS
                ,A.MACH_CD
                ,A.IND_BCD
                ,A.LOT_NO
                ,A.MATNR
                ,A.ORDER_NO
                ,A.ORDER_SEQNO
                ,A.WRK_ORDR_NO
                ,A.WRK_ORDR_SEQNO
                ,A.PRD_NO
                ,A.UNIT
                ,A.PRFM_QTY
                ,A.PCNT
                ,A.SCNT
                ,A.MCNT
                ,A.WIDTH
                ,A.ROLLCNT
                ,A.WGT
                ,A.RSPEED
                ,A.CORE
                ,A.WIDTH_NO
                ,A.MRLDCK
                ,A.CUTTER
                ,A.MER_YN
                ,A.GRD_YN
                ,A.PRD_STR_DATE
                ,A.PRD_END_DATE
                ,A.TM
                ,A.PRFM_DT
                ,A.PRD_DT
                ,A.DSTBT_DDLIN
                ,A.WRK_CLASS
                ,A.WRK_SHIFT
                ,A.MACHINE
                ,A.TO_MACHINE
                ,A.STA
                ,A.DOC_NO
                ,A.DOC_SEQNO
                ,A.SDOC_NO
                ,A.SDOC_SEQNO
                ,A.RMK
                ,A.CNL_YN
                ,P_CNL_RMK
                ,A.REGDATE
                ,A.REGID
                ,A.UPDDATE
                ,A.UPDID
                ,A.VBELN
                ,A.POSNR
                ,A.KUNNR
                ,A.PACKTYPE
                ,A.RUN_STA
                ,A.WRK_SEQ
                ,A.PRD_SEQ
                ,A.LOT_NO_BUF
                ,A.VLEN
                ,A.WLEN
                ,A.PRFM_GTHR_YN
                ,A.NAUFNR
                ,A.LOT_NO_PRE
                ,A.LOT_CHG_YN
                ,A.RMD_QTY
                ,A.MER_IND_BCD
                ,A.MER_RMK
                ,A.IN_PER_CNT
                ,A.MAN_CUT_YN
                ,A.LOT_NO_M1
                ,A.LOT_NO_M2
                ,A.LOT_NO_M3
                ,A.LOT_NO_M4
                ,A.LOT_NO_M5
                ,A.USE_REAM_M1
                ,A.USE_REAM_M2
                ,A.USE_REAM_M3
                ,A.USE_REAM_M4
                ,A.USE_REAM_M5
                ,A.PACK_LABEL_TYPE
                ,A.JRCOM_YN
                ,A.MRCOM_YN
                ,'X'
                ,A.CACOM_YN
                FROM TB_WRK002 A
                 WHERE A.WRK_ORDR_NO = V_WRK_ORDR_NO  
                   AND A.WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
                   AND A.WERKS = P_WERKS;

                DELETE FROM TB_WRK002 WHERE WRK_ORDR_NO = V_WRK_ORDR_NO AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO AND WERKS = P_WERKS; --실적(DELETE)

            END;
        END IF;

--		UPDATE TB_INV003                -- 자재투입량 폐품 2
--		   SET IND_BCD = ' '
--		 WHERE WERKS   = P_WERKS
--		   AND MACH_CD = P_MACH_CD
--		   AND WRK_ORDR_NO = P_WRK_ORDR_NO;

			UPDATE TB_INV003                -- 자재투입량 폐품 2
			   SET DISPO_QTY = 0,
				   USE_QTY   = 0,
				   STCK_QTY  = NVL(STCK_QTY, 0)  + (NVL(USE_QTY,0) + NVL(DISPO_QTY,0))
             WHERE WERKS   = P_WERKS
               AND MACH_CD = V_MACH_CD
               AND WRK_ORDR_NO = V_WRK_ORDR_NO
               ;

		UPDATE TB_IFS024                -- I/F 취소
		   SET CONF = 'D'
		 WHERE WERKS   = P_WERKS
		   AND MACHINE = P_MACH_CD
           AND MDOCNO = V_DOC_NO
		   AND AUFNR = V_ORDER_NO;

--            UPDATE TB_WRK011
--                SET PRE_WRK_ORDR_NO = '',
--                    PRE_WRK_ORDR_SEQNO = '',
--                    MATNR = V_MATNR,
--                    WRK_ORDR_NO = P_WRK_ORDR_NO, 
--                    WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO,
--                    ORDER_NO = V_ORDER_NO,
--                    LOT_NO = '',
----                    PRD_STR_DTM = '',
--                    MACH_STA = 'N',
--                    RUN_STA = 'R'
--            WHERE MACH_CD = 'PRD01'; 

--        RS_CODE := 'S';
--        COMMIT;      

        SELECT RFCFN
          INTO RS_PRFM_RFCFN
          FROM TB_ITFMA
         WHERE 1=1
           AND IFID = 'MES_IF_129';   --생산오더별 실적 취소 TXN

        --인터페이스 파라미터
        OPEN CUR_1 FOR
        SELECT 'MES_IF_129' AS I_IF_ID
             , 'M' || LTRIM(RTRIM(TO_CHAR(SEQ_GET_IFR_KEY.NEXTVAL, '00000000000000000000000000000'))) AS I_IF_KEY
          FROM dual;

            V_STOR_LOC_CD := '2020';

            --인터페이스 상세 파라미터
            V_SQL := FN_IF_QUERY('MES_IF_129', V_DOC_NO);
            OPEN CUR_2 FOR V_SQL;


        -- 폐품 취소------------------------------------------------------------------------------------------
             OPEN CUR_3 FOR
             SELECT 'MES_IF_144' AS I_IF_ID
                  , 'M' || LTRIM(RTRIM(TO_CHAR(SEQ_GET_IFR_KEY.NEXTVAL, '00000000000000000000000000000'))) AS I_IF_KEY
               FROM dual;

             --인터페이스 상세 파라미터
             V_SQL := FN_IF_QUERY('MES_IF_144', V_DOC_NO_DISPO);
             OPEN CUR_4 FOR V_SQL;

    END LOOP;

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

    --예외처리(catch)
    EXCEPTION
    WHEN E_EXCEPTION_USER THEN
        -- 에러 내역 SET
        E_SQL_ERR_CD        := SQLCODE;
        E_SQL_ERR_MSG       := SUBSTRB(SQLERRM,1,300);

        ROLLBACK;
        SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);

        RS_CODE := 'E';
        RS_MSG  := SQLERRM;
        RETURN;
    WHEN OTHERS THEN
        E_SQL_ERR_CD        := SQLCODE;
        E_SQL_ERR_MSG       := 'EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';

        ROLLBACK;
        --RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);
        RAISE;

        RS_CODE := 'E';
        RS_MSG  := SQLERRM;
        RETURN;
    --예외처리 종료
    END;
END;

/
