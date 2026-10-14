--------------------------------------------------------
--  DDL for Procedure SP_POP_WRK84_S04_221217
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_POP_WRK84_S04_221217" 
(
    P_WERKS             IN VARCHAR2 --plantcode
    ,P_OPCODE           IN VARCHAR2 --공정정보
    ,P_ORDER_NO			IN VARCHAR2 --오더번호
    ,P_WRK_ORDR_NO      IN VARCHAR2 --작업지시번호
    ,P_WRK_ORDR_SEQNO   IN VARCHAR2 --작업지시순번
    ,P_IND_BCD          IN VARCHAR2 --개별바코드
    ,P_WRK_INFO_01      OUT VARCHAR2 --작업지시 상세정보 1
    ,P_WRK_INFO_02      OUT VARCHAR2 --작업지시 상세정보 2
    ,P_WRK_RMK          OUT VARCHAR2 --작업지시 비고
    ,P_RMK              OUT VARCHAR2 --비고
    ,Lang               IN VARCHAR2 DEFAULT 'KO'
    ,RS_CODE            OUT VARCHAR2 
    ,RS_MSG             OUT VARCHAR2
)
AS 
    --프로그램 ID
    --주작업화면에서 공정정보에 있는 작업지시번호, 순번으로 작업지시 상세보기 정보 전달
    V_PRG_NM         VARCHAR2(100)  := 'SP_POP_WRK84_S04';     -- PROCEDURE NAME
    V_PLT_CD         varchar2(2) := '99'; --PLANTCODE TEST
    V_SESS_USER_ID   varchar2(20) := 'TEST'; --USERID
    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD      NUMBER(5) := 0;
    E_SQL_ERR_MSG     VARCHAR2(4000);
    --parameter변수 처리

    --내부 변수 등록
    V_OPCODE    VARCHAR2(10) := P_OPCODE;
    V_RMK		TB_WRK002.RMK%TYPE;					--비고

    V_RUN_STA_PRFM  TB_WRK002.RUN_STA%TYPE;         --운전상태
    V_RUN_STA_DISPO TB_WRK004.RUN_STA%TYPE;         --운전상태 폐품

    V_RUN_STA       TB_WRK002.RUN_STA%TYPE;         --운전상태
    V_RUN_STA_NM    CMCDV.CDESC1%TYPE;      
   
    V_IN_MR_YN		TB_INV001.IN_MR_YN%TYPE;		--수입밀롤여부
BEGIN
    --예외처리 시작(try)
    BEGIN
        BEGIN
--			dbms_output.put_line(V_OPCODE);
            P_WRK_INFO_01   := ''; --작업지시 상세정보 1
            P_WRK_INFO_02   := ''; --작업지시 상세정보 2
            P_WRK_RMK       := ''; --작업지시 비고
            P_RMK           := ''; --비고

            -- P_IND_BCD
            IF NVL(P_IND_BCD, '0') != '0' THEN
                IF P_WERKS = 'P100' THEN
                    BEGIN
                        SELECT RUN_STA, RMK 
                          INTO V_RUN_STA_PRFM, V_RMK 
                            FROM TB_WRK002 
                            WHERE 1=1
                                AND WERKS = P_WERKS
                                AND IND_BCD = P_IND_BCD;
                     EXCEPTION
                            WHEN NO_DATA_FOUND THEN
                                 V_RUN_STA_PRFM := '';
                                 V_RMK  := '';
                     END ;  

                    BEGIN
                        SELECT RUN_STA
                            INTO V_RUN_STA_DISPO
                        FROM TB_WRK004     --폐품실적
                        WHERE 1=1
                            AND WERKS = P_WERKS
                            AND IND_BCD = P_IND_BCD;
                     EXCEPTION
                            WHEN NO_DATA_FOUND THEN
                                 V_RUN_STA_DISPO := '';
                     END;

                     -- 운전상태 가져오기
                     IF NVL(V_RUN_STA_DISPO, '00') = '02' THEN
                        V_RUN_STA := V_RUN_STA_DISPO;
                     ELSE
                        V_RUN_STA := V_RUN_STA_PRFM;
                     END IF;

                     -- 운전상태명
                     IF NVL(V_RUN_STA, '00') != '00' THEN
                        BEGIN
                            SELECT CDESC1 INTO V_RUN_STA_NM
                            FROM CMCDV
                            WHERE 1=1
                              AND CMCDKY = 'RUN_STA'
                              AND CMCDVL = V_RUN_STA;
                         EXCEPTION
                                WHEN NO_DATA_FOUND THEN
                                     V_RUN_STA_NM := '';
                         END;
                     END IF;
--                ELSE    -- HL 인경우는 운전상태가 없음
--                     BEGIN
--                        SELECT RMK
--                          INTO V_RMK 
--                            FROM TB_WRK001 
--                            WHERE 1=1
--                                AND WERKS = P_WERKS
--                                AND IND_BCD = P_IND_BCD;
--                     EXCEPTION
--                            WHEN NO_DATA_FOUND THEN
--                                 V_RMK  := '';
--                     END;
--
--                     V_RUN_STA_NM := '';
                END IF;
            END IF;

            --밀롤, 슬리터
            IF V_OPCODE = 'MA' OR  V_OPCODE = 'SA' THEN          --밀롤, 슬리터
                BEGIN
                    SELECT WRK_INFO_01, WRK_INFO_02, WRK_RMK, RMK
                    INTO P_WRK_INFO_01, P_WRK_INFO_02, P_WRK_RMK, P_RMK
                    FROM (
                        SELECT '작업지시^' || W002.WRK_ORDR_NO || '-' || W002.WRK_ORDR_SEQNO
                            || '|오더번호^' || W002.ORDER_NO
                            || '|점보롤 LOT번호^' || W002.LOT_NO
                            || '|점보롤 개별바코드^' || W002.IND_BCD                    
                            || '||지종^' || M001.PCODE
                            || '|지종명^' || M001.PCODE_NM
                            || '|평량(g/m²)^' || NVL(RTRIM(TO_CHAR(M001.BS_WGT, 'fm999,999,999,999,990.999'), '.'), '0')
                            || '|지폭(mm)^' || NVL(RTRIM(TO_CHAR(S015.JWIDTH, 'fm999,999,999,999,990.999'), '.'), '0')
                            || '|'
                            || '|운전상태^' || V_RUN_STA_NM     --'01'=정상, '02'=폐품, '09'=비계획생산
                            || '|시작^' || TO_CHAR(W002.PRD_STR_DATE, 'YYYY-MM-DD HH24:MI:SS')
                            || '|종료^' || TO_CHAR(W002.PRD_END_DATE, 'YYYY-MM-DD HH24:MI:SS')
                            || '|가동시간(분)^' || NVL(RTRIM(TO_CHAR(W002.TM, 'fm999,999,999,999,990.999'), '.'), '0')
                            || '|선속^' || NVL(RTRIM(TO_CHAR(W002.RSPEED, 'fm999,999,999,999,990.999'), '.'), '0') WRK_INFO_01
                            ,
                               '계획권치수(M)^' || NVL(RTRIM(TO_CHAR(S015.JROLLCNT, 'fm999,999,999,999,990.999'), '.'), '0')
                            || '|계획중량(Kg)^' || NVL(RTRIM(TO_CHAR(S015.WRK_ORDR_QTY, 'fm999,999,999,999,990.999'), '.'), '0')
                            || '|실적권치수(M)^' || CASE WHEN W002.PRFM_GTHR_YN = 'Y' THEN NVL(RTRIM(TO_CHAR(W002.ROLLCNT, 'fm999,999,999,999,990.999'), '.'), '0') ELSE '0' END  --실적권치수
                            || '|실적중량(Kg)^' || CASE WHEN W002.PRFM_GTHR_YN = 'Y' THEN NVL(RTRIM(TO_CHAR(W002.WGT, 'fm999,999,999,999,990.999'), '.'), '0') ELSE '0' END       --실적중량
                            || '|'
                            || '|폐품코드^' || W004.DISPO_CD
                            || '|폐품원인^' || M023.DISPO_NM
                            || '|폐품량(M)^' || NVL(RTRIM(TO_CHAR(W004.ROLLCNT, 'fm999,999,999,999,990.999'), '.'), '0')
                            || '|폐품중량(Kg)^' || NVL(RTRIM(TO_CHAR(W004.WGT, 'fm999,999,999,999,990.999'), '.'), '0')
                            || '|'
                            || '|생산유형^' || CASE WHEN W002.MACHINE = 'PM2' THEN '라인교체' ELSE '자체생산' END
                            || '|생산호기^' || S015.MACHINE_NM
                            || '|이동호기^' || S015.TO_MACHINE_NM
                            --|| '|상태^' || W002.STA
                            || '|자재번호^' || W002.MATNR
                            || '|반^' || W002.WRK_CLASS
                            || '|작업자^' || USRMA.NMLAST  WRK_INFO_02
                          , S015.ORDER_RMK  WRK_RMK
                          , V_RMK     RMK
                        --INTO P_WRK_INFO_01, P_WRK_INFO_02, P_WRK_RMK, P_RMK
                        FROM TB_WRK002 W002    --PS실적
                           , TB_WRK004 W004    --PS폐품실적
                           , TB_SCH015 S015     -- 점보롤 작업지시
                           , TB_MAS001 M001     --자재코드 마스터
                           , TB_MAS023 M023     --폐품항목관리 마스터
                           , USRMA USRMA
                        WHERE 1=1
                           AND W002.WERKS = S015.WERKS
                           AND W002.WRK_ORDR_NO = S015.WRK_ORDR_NO
                           AND W002.WRK_ORDR_SEQNO = S015.WRK_ORDR_SEQNO
                           AND W002.WERKS = W004.WERKS(+)
                           AND W002.IND_BCD = W004.IND_BCD(+)
                           AND W002.WRK_ORDR_NO = W004.WRK_ORDR_NO(+)
                           AND W002.WRK_ORDR_SEQNO = W004.WRK_ORDR_SEQNO(+)
                           AND W002.WERKS = M001.WERKS(+)
                           AND W002.MATNR = M001.MATNR(+)
                           AND W004.DISPO_CD = M023.DISPO_CD(+)
                           AND W002.REGID = USRMA.USERID(+)
                           AND W002.WERKS = P_WERKS
                           AND W002.IND_BCD = P_IND_BCD
                           AND W002.WRK_ORDR_NO = P_WRK_ORDR_NO
                           AND W002.WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO
                           AND NVL(W002.CNL_YN,'N') = 'N'
                     /*UNION ALL
                        SELECT '작업지시^' || W002.WRK_ORDR_NO || '-' || W002.WRK_ORDR_SEQNO
                            || '|오더번호^' || W002.ORDER_NO
                            || '|점보롤 LOT번호^' || W002.LOT_NO
                            || '|점보롤 개별바코드^' || W002.IND_BCD                    
                            || '||지종^' || M001.PCODE
                            || '|지종명^' || M001.PCODE_NM
                            || '|평량(g/m²)^' || NVL(RTRIM(TO_CHAR(M001.BS_WGT, 'fm999,999,999,999,990.999'), '.'), '0')
                            || '|지폭(mm)^' || NVL(RTRIM(TO_CHAR(0, 'fm999,999,999,999,990.999'), '.'), '0')
                            || '|'
                            || '|운전상태^' || V_RUN_STA_NM     --'01'=정상, '02'=폐품, '09'=비계획생산
                            || '|시작^' || TO_CHAR(W002.PRD_STR_DATE, 'YYYY-MM-DD HH24:MI:SS')
                            || '|종료^' || TO_CHAR(W002.PRD_END_DATE, 'YYYY-MM-DD HH24:MI:SS')
                            || '|가동시간(분)^' || NVL(RTRIM(TO_CHAR(W002.TM, 'fm999,999,999,999,990.999'), '.'), '0')
                            || '|선속^' || NVL(RTRIM(TO_CHAR(W002.RSPEED, 'fm999,999,999,999,990.999'), '.'), '0') WRK_INFO_01
                            ,
                               '계획권치수(M)^' || NVL(RTRIM(TO_CHAR(0, 'fm999,999,999,999,990.999'), '.'), '0')
                            || '|계획중량(Kg)^' || NVL(RTRIM(TO_CHAR(S015.WRK_ORDR_QTY, 'fm999,999,999,999,990.999'), '.'), '0')
                            || '|실적권치수(M)^' || CASE WHEN W002.PRFM_GTHR_YN = 'Y' THEN NVL(RTRIM(TO_CHAR(W002.ROLLCNT, 'fm999,999,999,999,990.999'), '.'), '0') ELSE '0' END  --실적권치수
                            || '|실적중량(Kg)^' || CASE WHEN W002.PRFM_GTHR_YN = 'Y' THEN NVL(RTRIM(TO_CHAR(W002.WGT, 'fm999,999,999,999,990.999'), '.'), '0') ELSE '0' END       --실적중량
                            || '|'
                            || '|폐품코드^' || W004.DISPO_CD
                            || '|폐품원인^' || M023.DISPO_NM
                            || '|폐품량(M)^' || NVL(RTRIM(TO_CHAR(W004.ROLLCNT, 'fm999,999,999,999,990.999'), '.'), '0')
                            || '|폐품중량(Kg)^' || NVL(RTRIM(TO_CHAR(W004.WGT, 'fm999,999,999,999,990.999'), '.'), '0')
                            || '|'
                            || '|생산유형^' || CASE WHEN W002.MACHINE = 'PM2' THEN '라인교체' ELSE '자체생산' END
                            || '|생산호기^' || NULL
                            || '|이동호기^' || NULL
                            --|| '|상태^' || W002.STA
                            || '|자재번호^' || W002.MATNR
                            || '|반^' || W002.WRK_CLASS
                            || '|작업자^' || USRMA.NMLAST  WRK_INFO_02
                          , NULL  WRK_RMK
                          , V_RMK     RMK
                        --INTO P_WRK_INFO_01, P_WRK_INFO_02, P_WRK_RMK, P_RMK
                        FROM TB_WRK002 W002    --PS실적
                           , TB_WRK004 W004    --PS폐품실적
                           , TB_SCH019 S015     -- 점보롤 작업지시
                           , TB_MAS001 M001     --자재코드 마스터
                           , TB_MAS023 M023     --폐품항목관리 마스터
                           , USRMA USRMA
                        WHERE 1=1
                           AND W002.WERKS = S015.WERKS
                           AND W002.WRK_ORDR_NO = S015.WRK_ORDR_NO
                           AND W002.WRK_ORDR_SEQNO = S015.WRK_ORDR_SEQNO
                           AND W002.WERKS = W004.WERKS(+)
                           AND W002.IND_BCD = W004.IND_BCD(+)
                           AND W002.WRK_ORDR_NO = W004.WRK_ORDR_NO(+)
                           AND W002.WRK_ORDR_SEQNO = W004.WRK_ORDR_SEQNO(+)
                           AND W002.WERKS = M001.WERKS(+)
                           AND W002.MATNR = M001.MATNR(+)
                           AND W004.DISPO_CD = M023.DISPO_CD(+)
                           AND W002.REGID = USRMA.USERID(+)
                           AND W002.WERKS = P_WERKS
                           AND W002.IND_BCD = P_IND_BCD
                           AND W002.WRK_ORDR_NO = P_WRK_ORDR_NO
                           AND W002.WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO
                           AND NVL(W002.CNL_YN,'N') = 'N'*/
                     
                   );
                EXCEPTION
                      WHEN NO_DATA_FOUND THEN
                          RS_CODE := 'E';
                          RS_MSG := '작업지시 정보를 찾지 못했습니다.';
                          RETURN;
                END;
                           
            --재단
            ELSIF V_OPCODE = 'CA' /*OR V_OPCODE = 'CB'*/ THEN           --재단, 수재단
                BEGIN
                	SELECT NVL(IN_MR_YN, 'N') INTO V_IN_MR_YN		--수입밀롤인지 체크
                	  FROM TB_INV001 ti
                	 WHERE IND_BCD = P_IND_BCD;
                	
                	IF V_IN_MR_YN = 'N' THEN
                		--수입밀롤이 아니면
                		SELECT WRK_INFO_01, WRK_INFO_02, WRK_RMK, RMK
		                  INTO P_WRK_INFO_01, P_WRK_INFO_02, P_WRK_RMK, P_RMK
		                  FROM (
                                SELECT '작업지시^' || W002.WRK_ORDR_NO || '-' || W002.WRK_ORDR_SEQNO
                                    || '|밀롤오더번호^' || W002.ORDER_NO
                                    || '|점보롤오더번호^' || S016.PRE_ORDER_NO
                                    || '|밀롤 LOT번호^' || W002.LOT_NO
                                    || '|밀롤 개별바코드^' || W002.IND_BCD
                                    || '|'
                                    --|| '|운전상태^' || V_RUN_STA_NM     --'01'=정상, '02'=폐품, '09'=비계획생산                    
                                    || '|지종^' || M001.PCODE
                                    || '|지종명^' || M001.PCODE_NM
                                    || '|평량(g/m²)^' || NVL(RTRIM(TO_CHAR(M001.BS_WGT, 'fm999,999,999,999,990.999'), '.'), '0')
                                    || '|지폭(mm)^' || NVL(RTRIM(TO_CHAR(S016.MWIDTH, 'fm999,999,999,999,990.999'), '.'), '0')
                                    || '|지관(inch)^' || W002.CORE
                                    || '|폭수^' || S016.MRCNT
                                    || '|'
                                    || '|지폭순번^' || W002.WIDTH_NO
                                    || '|실적순서^' || W002.PRD_SEQ
                                    || '|밀롤적치^' || W002.MRLDCK  WRK_INFO_01
                                    --|| '|재단번호^' || W002.CUTTER
                                    --|| '|타입^' || W002.PACKTYPE
                                    ,
                                       '계획권치수(M)^' || NVL(RTRIM(TO_CHAR(S016.MROLLCNT, 'fm999,999,999,999,990.999'), '.'), '0')
                                    || '|계획중량(Kg)^' || NVL(RTRIM(TO_CHAR(S016.MBRGEW, 'fm999,999,999,999,990.999'), '.'), '0')
                                    || '|실적권치수(M)^' || CASE WHEN W002.PRFM_GTHR_YN = 'Y' THEN NVL(RTRIM(TO_CHAR(W002.ROLLCNT, 'fm999,999,999,999,990.999'), '.'), '0') ELSE '0' END  --실적권치수
                                    || '|실적중량(Kg)^' || CASE WHEN W002.PRFM_GTHR_YN = 'Y' THEN NVL(RTRIM(TO_CHAR(W002.WGT, 'fm999,999,999,999,990.999'), '.'), '0') ELSE '0' END       --실적중량
                                    || '|'
                                    || '|폐품코드^' || W004.DISPO_CD
                                    || '|폐품원인^' || M023.DISPO_NM
                                    || '|폐품량(M)^' || NVL(RTRIM(TO_CHAR(W004.ROLLCNT, 'fm999,999,999,999,990.999'), '.'), '0')
                                    || '|폐품중량(Kg)^' || NVL(RTRIM(TO_CHAR(W004.WGT, 'fm999,999,999,999,990.999'), '.'), '0')
                                    || '|'
                                    || '|생산유형^' || CASE WHEN W002.MACHINE = 'PM2' THEN '라인교체' ELSE '자체생산' END
                                    || '|생산호기^' || S016.MACHINE_NM
                                    || '|이동호기^' || S016.TO_MACHINE_NM
                                    --|| '|상태^' || W002.STA
                                    || '|자재번호^' || W002.MATNR
                                    || '|반^' || W002.WRK_CLASS
                                    || '|작업자^' || USRMA.NMLAST
                                    || '|'
                                    || '|거래처^' || S016.KUNNRT
                                    || '|판매오더번호^' || S016.VBELN || '-' || S016.POSNR  WRK_INFO_02
                                  , S016.ORDER_RMK   WRK_RMK
                                  , V_RMK       RMK
                                --INTO P_WRK_INFO_01, P_WRK_INFO_02, P_WRK_RMK, P_RMK
                                FROM TB_WRK002 W002    --PS실적
                                   , TB_WRK004 W004    --PS폐품실적
                                   , TB_SCH016 S016     --밀롤 작업지시
                                   , TB_MAS001 M001     --자재코드 마스터
                                   , TB_MAS023 M023     --폐품항목관리 마스터
                                   , USRMA USRMA
                                WHERE 1=1
                                   AND W002.WERKS = S016.WERKS
                                   AND W002.WRK_ORDR_NO = S016.WRK_ORDR_NO
                                   AND W002.WRK_ORDR_SEQNO = S016.WRK_ORDR_SEQNO
                                   AND W002.WERKS = W004.WERKS(+)
                                   AND W002.IND_BCD = W004.IND_BCD(+)
                                   AND W002.WRK_ORDR_NO = W004.WRK_ORDR_NO(+)
                                   AND W002.WRK_ORDR_SEQNO = W004.WRK_ORDR_SEQNO(+)
                                   AND W002.WERKS = M001.WERKS(+)
                                   AND W002.MATNR = M001.MATNR(+)
                                   AND W004.DISPO_CD = M023.DISPO_CD(+)
                                   AND W002.REGID = USRMA.USERID(+)
                                   AND W002.WERKS = P_WERKS
                                   AND W002.IND_BCD = P_IND_BCD
                                   AND W002.WRK_ORDR_NO = P_WRK_ORDR_NO
                                   AND W002.WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO
                                   AND NVL(W002.CNL_YN,'N') = 'N'
             				);
					ELSE
						--수입밀롤
						SELECT WRK_INFO_01, WRK_INFO_02, WRK_RMK, RMK
	                      INTO P_WRK_INFO_01, P_WRK_INFO_02, P_WRK_RMK, P_RMK
	                      FROM (
                                SELECT '작업지시^' || S016.WRK_ORDR_NO || '-' || S016.WRK_ORDR_SEQNO
                                    || '|밀롤오더번호^' || I001.LOT_NO
                                    --|| '|점보롤오더번호^' || S016.PRE_ORDER_NO
                                    --|| '|밀롤 LOT번호^' || W002.LOT_NO
                                    || '|밀롤 개별바코드^' || I001.IND_BCD
                                    || '|'
                                    --|| '|운전상태^' || V_RUN_STA_NM     --'01'=정상, '02'=폐품, '09'=비계획생산                    
                                    || '|지종^' || M001.PCODE
                                    || '|지종명^' || M001.PCODE_NM
                                    || '|평량(g/m²)^' || NVL(RTRIM(TO_CHAR(M001.BS_WGT, 'fm999,999,999,999,990.999'), '.'), '0')
                                    || '|지폭(mm)^' || NVL(RTRIM(TO_CHAR(S016.MWIDTH, 'fm999,999,999,999,990.999'), '.'), '0')
                                    --|| '|지관(inch)^' || W002.CORE
                                    || '|폭수^' || S016.MRCNT
                                    || '|'
                                    --|| '|지폭순번^' || W002.WIDTH_NO
                                    --|| '|실적순서^' || W002.PRD_SEQ
                                    || '|밀롤적치^' || S016.MRLDCK  WRK_INFO_01
                                    --|| '|재단번호^' || W002.CUTTER
                                    --|| '|타입^' || W002.PACKTYPE
                                    ,
                                       '계획권치수(M)^' || NVL(RTRIM(TO_CHAR(S016.MROLLCNT, 'fm999,999,999,999,990.999'), '.'), '0')
                                    || '|계획중량(Kg)^' || NVL(RTRIM(TO_CHAR(S016.MBRGEW, 'fm999,999,999,999,990.999'), '.'), '0')
                                    --|| '|실적권치수(M)^' || CASE WHEN W002.PRFM_GTHR_YN = 'Y' THEN NVL(RTRIM(TO_CHAR(W002.ROLLCNT, 'fm999,999,999,999,990.999'), '.'), '0') ELSE '0' END  --실적권치수
                                    --|| '|실적중량(Kg)^' || CASE WHEN W002.PRFM_GTHR_YN = 'Y' THEN NVL(RTRIM(TO_CHAR(W002.WGT, 'fm999,999,999,999,990.999'), '.'), '0') ELSE '0' END       --실적중량
                                    || '|'
                                    --|| '|폐품코드^' || W004.DISPO_CD
                                    --|| '|폐품원인^' || M023.DISPO_NM
                                    --|| '|폐품량(M)^' || NVL(RTRIM(TO_CHAR(W004.ROLLCNT, 'fm999,999,999,999,990.999'), '.'), '0')
                                    --|| '|폐품중량(Kg)^' || NVL(RTRIM(TO_CHAR(W004.WGT, 'fm999,999,999,999,990.999'), '.'), '0')
                                    --|| '|'
                                    --|| '|생산유형^' || CASE WHEN W002.MACHINE = 'PM2' THEN '라인교체' ELSE '자체생산' END
                                    || '|생산호기^' || S016.MACHINE_NM
                                    || '|이동호기^' || S016.TO_MACHINE_NM
                                    --|| '|상태^' || W002.STA
                                    || '|자재번호^' || I001.MATNR
                                    --|| '|반^' || W002.WRK_CLASS
                                    --|| '|작업자^' || USRMA.NMLAST
                                    || '|'
                                    || '|거래처^' || S016.KUNNRT
                                    || '|판매오더번호^' || S016.VBELN || '-' || S016.POSNR  WRK_INFO_02
                                  , S016.ORDER_RMK   WRK_RMK
                                  , V_RMK       RMK
                                --INTO P_WRK_INFO_01, P_WRK_INFO_02, P_WRK_RMK, P_RMK
                                FROM --TB_WRK002 W002    --PS실적
                                   --, TB_WRK004 W004    --PS폐품실적
                                	 TB_INV001 I001		--공정재고
                                   , TB_SCH016 S016     --밀롤 작업지시
                                   , TB_MAS001 M001     --자재코드 마스터
                                   --, TB_MAS023 M023     --폐품항목관리 마스터
                                   --, USRMA USRMA
                                WHERE 1=1
                                  AND I001.LOT_NO = S016.ORDER_NO(+)
                                  AND I001.WERKS = M001.WERKS(+)
                                  AND I001.MATNR = M001.MATNR(+)
                                  AND NVL(I001.DLFL, 'N') = 'N'
                                  AND I001.WERKS = P_WERKS
                                  AND I001.IND_BCD = P_IND_BCD
                          	);
       				END IF;
                                   /*AND W002.WERKS = S016.WERKS
                                   AND W002.WRK_ORDR_NO = S016.WRK_ORDR_NO
                                   AND W002.WRK_ORDR_SEQNO = S016.WRK_ORDR_SEQNO
                                   AND W002.WERKS = W004.WERKS(+)
                                   AND W002.IND_BCD = W004.IND_BCD(+)
                                   AND W002.WRK_ORDR_NO = W004.WRK_ORDR_NO(+)
                                   AND W002.WRK_ORDR_SEQNO = W004.WRK_ORDR_SEQNO(+)
                                   AND W002.WERKS = M001.WERKS(+)
                                   AND W002.MATNR = M001.MATNR(+)
                                   AND W004.DISPO_CD = M023.DISPO_CD(+)
                                   AND W002.REGID = USRMA.USERID(+)
                                   AND W002.WERKS = P_WERKS
                                   AND W002.IND_BCD = P_IND_BCD
                                   AND W002.WRK_ORDR_NO = P_WRK_ORDR_NO
                                   AND W002.WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO
                                   AND NVL(W002.CNL_YN,'N') = 'N'*/
                       /*UNION ALL                                   
                                SELECT '작업지시^' || W002.WRK_ORDR_NO || '-' || W002.WRK_ORDR_SEQNO
                                    || '|밀롤오더번호^' || W002.ORDER_NO
                                    || '|점보롤오더번호^' || NULL
                                    || '|밀롤 LOT번호^' || W002.LOT_NO
                                    || '|밀롤 개별바코드^' || W002.IND_BCD
                                    || '|'
                                    --|| '|운전상태^' || V_RUN_STA_NM     --'01'=정상, '02'=폐품, '09'=비계획생산                    
                                    || '|지종^' || M001.PCODE
                                    || '|지종명^' || M001.PCODE_NM
                                    || '|평량(g/m²)^' || NVL(RTRIM(TO_CHAR(M001.BS_WGT, 'fm999,999,999,999,990.999'), '.'), '0')
                                    || '|지폭(mm)^' || NVL(RTRIM(TO_CHAR(0, 'fm999,999,999,999,990.999'), '.'), '0')
                                    || '|지관(inch)^' || W002.CORE
                                    || '|폭수^' || NULL
                                    || '|'
                                    || '|지폭순번^' || W002.WIDTH_NO
                                    || '|실적순서^' || W002.PRD_SEQ
                                    || '|밀롤적치^' || W002.MRLDCK  WRK_INFO_01
                                    --|| '|재단번호^' || W002.CUTTER
                                    --|| '|타입^' || W002.PACKTYPE
                                    ,
                                       '계획권치수(M)^' || NVL(RTRIM(TO_CHAR(0, 'fm999,999,999,999,990.999'), '.'), '0')
                                    || '|계획중량(Kg)^' || NVL(RTRIM(TO_CHAR(0, 'fm999,999,999,999,990.999'), '.'), '0')
                                    || '|실적권치수(M)^' || CASE WHEN W002.PRFM_GTHR_YN = 'Y' THEN NVL(RTRIM(TO_CHAR(W002.ROLLCNT, 'fm999,999,999,999,990.999'), '.'), '0') ELSE '0' END  --실적권치수
                                    || '|실적중량(Kg)^' || CASE WHEN W002.PRFM_GTHR_YN = 'Y' THEN NVL(RTRIM(TO_CHAR(W002.WGT, 'fm999,999,999,999,990.999'), '.'), '0') ELSE '0' END       --실적중량
                                    || '|'
                                    || '|폐품코드^' || W004.DISPO_CD
                                    || '|폐품원인^' || M023.DISPO_NM
                                    || '|폐품량(M)^' || NVL(RTRIM(TO_CHAR(W004.ROLLCNT, 'fm999,999,999,999,990.999'), '.'), '0')
                                    || '|폐품중량(Kg)^' || NVL(RTRIM(TO_CHAR(W004.WGT, 'fm999,999,999,999,990.999'), '.'), '0')
                                    || '|'
                                    || '|생산유형^' || CASE WHEN W002.MACHINE = 'PM2' THEN '라인교체' ELSE '자체생산' END
                                    || '|생산호기^' || NULL
                                    || '|이동호기^' || NULL
                                    --|| '|상태^' || W002.STA
                                    || '|자재번호^' || W002.MATNR
                                    || '|반^' || W002.WRK_CLASS
                                    || '|작업자^' || USRMA.NMLAST
                                    || '|'
                                    || '|거래처^' || S016.KUNNRT
                                    || '|판매오더번호^' || S016.VBELN || '-' || S016.POSNR  WRK_INFO_02
                                  , NULL   WRK_RMK
                                  , V_RMK       RMK
                                --INTO P_WRK_INFO_01, P_WRK_INFO_02, P_WRK_RMK, P_RMK
                                FROM TB_WRK002 W002    --PS실적
                                   , TB_WRK004 W004    --PS폐품실적
                                   , TB_SCH019 S016     --밀롤 작업지시
                                   , TB_MAS001 M001     --자재코드 마스터
                                   , TB_MAS023 M023     --폐품항목관리 마스터
                                   , USRMA USRMA
                                WHERE 1=1
                                   AND W002.WERKS = S016.WERKS
                                   AND W002.WRK_ORDR_NO = S016.WRK_ORDR_NO
                                   AND W002.WRK_ORDR_SEQNO = S016.WRK_ORDR_SEQNO
                                   AND W002.WERKS = W004.WERKS(+)
                                   AND W002.IND_BCD = W004.IND_BCD(+)
                                   AND W002.WRK_ORDR_NO = W004.WRK_ORDR_NO(+)
                                   AND W002.WRK_ORDR_SEQNO = W004.WRK_ORDR_SEQNO(+)
                                   AND W002.WERKS = M001.WERKS(+)
                                   AND W002.MATNR = M001.MATNR(+)
                                   AND W004.DISPO_CD = M023.DISPO_CD(+)
                                   AND W002.REGID = USRMA.USERID(+)
                                   AND W002.WERKS = P_WERKS
                                   AND W002.IND_BCD = P_IND_BCD
                                   AND W002.WRK_ORDR_NO = P_WRK_ORDR_NO
                                   AND W002.WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO
                                   AND NVL(W002.CNL_YN,'N') = 'N'
                  			);*/
                EXCEPTION
                      WHEN NO_DATA_FOUND THEN
                          RS_CODE := 'E';
                          RS_MSG := '작업지시 정보를 찾지 못했습니다.';
                          RETURN;
                END;
            --포장
            ELSIF V_OPCODE = 'PB' OR V_OPCODE = 'PC' OR V_OPCODE = 'PD' OR V_OPCODE = 'CB' THEN        --자동포장, 수축포장, 수작업 포장, 수재단
                --재단 실적 상세보기
                IF NVL(V_RUN_STA_PRFM, '00') = '01' THEN
                    BEGIN
                    SELECT WRK_INFO_01, WRK_INFO_02, WRK_RMK, RMK
                    INTO P_WRK_INFO_01, P_WRK_INFO_02, P_WRK_RMK, P_RMK
                    FROM (
                        SELECT '작업지시^' || W002.WRK_ORDR_NO || '-' || W002.WRK_ORDR_SEQNO
                            || '|재단오더번호^' || S017.ORDER_NO
                            || '|밀롤오더번호^' || S017.PRE_ORDER_NO
                            || '|점보롤오더번호^' || S016.PRE_ORDER_NO
                            || '|재단 LOT번호^' || W002.LOT_NO
                            || '|재단 개별바코드^' || W002.IND_BCD
                            || '|'
                            || '|운전상태^' || V_RUN_STA_NM     --'01'=정상, '02'=폐품, '09'=비계획생산
                            || '|지종^' || M001.PCODE
                            || '|지종명^' || M001.PCODE_NM
                            || '|평량(g/m²)^' || NVL(RTRIM(TO_CHAR(M001.BS_WGT, 'fm999,999,999,999,990.999'), '.'), '0')
                            || '|규격^' || SUBSTR(W002.MATNR, 10, 4) || '*' || SUBSTR(W002.MATNR, 14, 4)  WRK_INFO_01
                            ,
                               '계획연수(R)^' || NVL(RTRIM(TO_CHAR(S017.WRK_ORDR_QTY, 'fm999,999,999,999,990.999'), '.'), '0')
                            || '|계획중량(Kg)^' || NVL(RTRIM(TO_CHAR(ROUND(FN_CHG_UNIT ( S017.MATNR, P_WERKS, 'R', 'KG', NVL(S017.WRK_ORDR_QTY,0)) ,3), 'fm999,999,999,999,990.999'), '.'), '0') 
                            || '|실적연수(R)^' || CASE WHEN W002.PRFM_GTHR_YN = 'Y' THEN NVL(RTRIM(TO_CHAR(ROUND(FN_CHG_UNIT (  W002.MATNR, P_WERKS, W002.UNIT, 'R', NVL(W002.PRFM_QTY,0)) ,3), 'fm999,999,999,999,990.999'), '.'), '0') ELSE '0' END  --실적연수
                            || '|실적중량(Kg)^' || CASE WHEN W002.PRFM_GTHR_YN = 'Y' THEN NVL(RTRIM(TO_CHAR(W002.WGT, 'fm999,999,999,999,990.999'), '.'), '0') ELSE '0' END       --실적중량
                            || '|'
    --                        || '||폐품코드^' || W004.DISPO_CD
    --                        || '|폐품원인^' || M023.DISPO_NM
    --                        || '|폐품량(M)^' || NVL(RTRIM(TO_CHAR(W004.ROLLCNT, 'fm999,999,999,999,990.999'), '.'), '0')
    --                        || '|폐품중량(Kg)^' || NVL(RTRIM(TO_CHAR(W004.WGT, 'fm999,999,999,999,990.999'), '.'), '0')
    
    --                        || '|생산유형^' || CASE WHEN S017.MACHINE = 'PM2' THEN '라인교체' ELSE '자체생산' END
                            || '|생산호기^' || S017.MACHINE_NM
                            || '|이동호기^' || S017.TO_MACHINE_NM
                            --|| '|상태^' || W002.STA
                            || '|자재번호^' || W002.MATNR
                            || '|반^' || W002.WRK_CLASS
                            || '|작업자^' || USRMA.NMLAST
                            || '|'
                            || '|거래처^' || S017.KUNNRT
                            || '|판매오더번호^' || S017.VBELN || '-' || S017.POSNR  WRK_INFO_02
                          , S017.ORDER_RMK   WRK_RMK
                          , V_RMK             RMK
                       -- INTO P_WRK_INFO_01, P_WRK_INFO_02, P_WRK_RMK, P_RMK
                        FROM TB_WRK002 W002    --PS실적
    --                       , TB_WRK004 W004    --PS폐품실적
                           , TB_SCH017 S017     --재단 작업지시
                           , TB_SCH016 S016     --밀롤 작업지시
                           , TB_MAS001 M001     --자재코드 마스터
    --                       , TB_MAS023 M023     --폐품항목관리 마스터
                           , USRMA USRMA
                        WHERE 1=1
                           AND W002.WERKS = S017.WERKS
                           AND W002.WRK_ORDR_NO = S017.WRK_ORDR_NO
                           AND W002.WRK_ORDR_SEQNO = S017.WRK_ORDR_SEQNO
                           AND S017.PRE_ORDER_NO = S016.ORDER_NO(+)
    --                       AND W002.WERKS = W004.WERKS(+)
    --                       AND W002.IND_BCD = W004.IND_BCD(+)
    --                       AND W002.WRK_ORDR_NO = W004.WRK_ORDR_NO(+)
    --                       AND W002.WRK_ORDR_SEQNO = W004.WRK_ORDR_SEQNO(+)
                           AND W002.WERKS = M001.WERKS(+)
                           AND W002.MATNR = M001.MATNR(+)
    --                       AND W004.DISPO_CD = M023.DISPO_CD(+)
                           AND W002.REGID = USRMA.USERID(+)
                           AND W002.WERKS = P_WERKS
                           AND W002.IND_BCD = P_IND_BCD
                           AND W002.WRK_ORDR_NO = P_WRK_ORDR_NO
                           AND W002.WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO
                           AND NVL(W002.CNL_YN,'N') = 'N'
                      UNION ALL
                        SELECT 
                        		--'작업지시^' || W002.WRK_ORDR_NO || '-' || W002.WRK_ORDR_SEQNO
                            --|| '|재단오더번호^' || S017.ORDER_NO
                            --|| '|밀롤오더번호^' || NULL
                            --|| '|점보롤오더번호^' || NULL
                            --|| '|재단 LOT번호^' || W002.LOT_NO
                            --|| '|재단 개별바코드^' || W002.IND_BCD
                        	   '예외 오더번호^' || P_ORDER_NO
                        	|| '|개별바코드^' || I001.IND_BCD
                            || '|'
                            || '|운전상태^' || V_RUN_STA_NM     --'01'=정상, '02'=폐품, '09'=비계획생산
                            || '|지종^' || M001.PCODE
                            || '|지종명^' || M001.PCODE_NM
                            || '|평량(g/m²)^' || NVL(RTRIM(TO_CHAR(M001.BS_WGT, 'fm999,999,999,999,990.999'), '.'), '0')
                            || '|규격^' || SUBSTR(I001.MATNR, 10, 4) || '*' || SUBSTR(I001.MATNR, 14, 4)  WRK_INFO_01
                            ,
                               '계획연수(R)^' || NVL(RTRIM(TO_CHAR(S019.WRK_ORDR_QTY, 'fm999,999,999,999,990.999'), '.'), '0')
                            || '|계획중량(Kg)^' || NVL(RTRIM(TO_CHAR(ROUND(FN_CHG_UNIT (I001.MATNR, P_WERKS, 'R', 'KG', NVL(S019.WRK_ORDR_QTY,0)) ,3), 'fm999,999,999,999,990.999'), '.'), '0') 
                            --|| '|실적연수(R)^' || CASE WHEN W002.PRFM_GTHR_YN = 'Y' THEN NVL(RTRIM(TO_CHAR(ROUND(FN_CHG_UNIT (  W002.MATNR, P_WERKS, W002.UNIT, 'R', NVL(W002.PRFM_QTY,0)) ,3), 'fm999,999,999,999,990.999'), '.'), '0') ELSE '0' END  --실적연수
                            --|| '|실적중량(Kg)^' || CASE WHEN W002.PRFM_GTHR_YN = 'Y' THEN NVL(RTRIM(TO_CHAR(W002.WGT, 'fm999,999,999,999,990.999'), '.'), '0') ELSE '0' END       --실적중량
                            || '|'
    --                        || '||폐품코드^' || W004.DISPO_CD
    --                        || '|폐품원인^' || M023.DISPO_NM
    --                        || '|폐품량(M)^' || NVL(RTRIM(TO_CHAR(W004.ROLLCNT, 'fm999,999,999,999,990.999'), '.'), '0')
    --                        || '|폐품중량(Kg)^' || NVL(RTRIM(TO_CHAR(W004.WGT, 'fm999,999,999,999,990.999'), '.'), '0')
    
    --                        || '|생산유형^' || CASE WHEN S017.MACHINE = 'PM2' THEN '라인교체' ELSE '자체생산' END
                            --|| '|생산호기^' || NULL
                            --|| '|이동호기^' || NULL
                            --|| '|상태^' || W002.STA
                            || '|자재번호^' || I001.MATNR
                            --|| '|반^' || W002.WRK_CLASS
                            --|| '|작업자^' || USRMA.NMLAST
                            || '|'
                            || '|거래처^' || S019.KUNNRT
                            || '|판매오더번호^' || S019.VBELN || '-' || S019.POSNR  WRK_INFO_02
                          , NULL   WRK_RMK
                          , V_RMK             RMK
                       -- INTO P_WRK_INFO_01, P_WRK_INFO_02, P_WRK_RMK, P_RMK
                        FROM --TB_WRK002 W002    --PS실적
    --                       , TB_WRK004 W004    --PS폐품실적
                        	 TB_INV001 I001		--공정재고
                           , TB_SCH020 S020		--생산오더 BOM
                           , TB_SCH019 S019     --예외 작업지시
                           , TB_MAS001 M001     --자재코드 마스터
    --                       , TB_MAS023 M023     --폐품항목관리 마스터
                           --, USRMA USRMA
                        WHERE 1=1
                           /*AND W002.WERKS = S017.WERKS
                           AND W002.WRK_ORDR_NO = S017.WRK_ORDR_NO
                           AND W002.WRK_ORDR_SEQNO = S017.WRK_ORDR_SEQNO*/
    --                       AND W002.WERKS = W004.WERKS(+)
    --                       AND W002.IND_BCD = W004.IND_BCD(+)
    --                       AND W002.WRK_ORDR_NO = W004.WRK_ORDR_NO(+)
    --                       AND W002.WRK_ORDR_SEQNO = W004.WRK_ORDR_SEQNO(+)
                          AND I001.LOT_NO = S020.LOT_NO
                          AND S020.ORDER_NO = S019.ORDER_NO
                          AND I001.WERKS = M001.WERKS(+)
                          AND I001.MATNR = M001.MATNR(+)
    --                       AND W004.DISPO_CD = M023.DISPO_CD(+)
                          --AND W002.REGID = USRMA.USERID(+)
                          AND I001.WERKS = P_WERKS
                          AND I001.IND_BCD = P_IND_BCD
                          AND NVL(I001.DLFL, 'N') = 'N'
                          AND S020.ORDER_NO = P_ORDER_NO
                           --AND W002.WRK_ORDR_NO = P_WRK_ORDR_NO
                           --AND W002.WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO
                          --AND NVL(W002.CNL_YN,'N') = 'N'                      
                     );
                    EXCEPTION
                          WHEN NO_DATA_FOUND THEN
                              RS_CODE := 'E';
                              RS_MSG := '작업지시 정보를 찾지 못했습니다.';
                              RETURN;
                    END;
                           
                ELSE
                    --재단 페품 상세보기
                    BEGIN
                    SELECT WRK_INFO_01, WRK_INFO_02, WRK_RMK, RMK
                    INTO P_WRK_INFO_01, P_WRK_INFO_02, P_WRK_RMK, P_RMK
                    FROM (
                            SELECT '작업지시^' || W004.WRK_ORDR_NO || '-' || W004.WRK_ORDR_SEQNO
                                || '|재단오더번호^' || S017.ORDER_NO
                                || '|밀롤오더번호^' || S017.PRE_ORDER_NO
                                || '|점보롤오더번호^' || S016.PRE_ORDER_NO
                                || '|재단 LOT번호^' || W004.LOT_NO
                                || '|재단 개별바코드^' || W004.IND_BCD
                                || '|'
                                || '|운전상태^' || V_RUN_STA_NM     --'01'=정상, '02'=폐품, '09'=비계획생산
                                || '|지종^' || M001.PCODE
                                || '|지종명^' || M001.PCODE_NM
                                || '|평량(g/m²)^' || NVL(RTRIM(TO_CHAR(M001.BS_WGT, 'fm999,999,999,999,990.999'), '.'), '0')
                                || '|규격^' || SUBSTR(W004.MATNR, 10, 4) || '*' || SUBSTR(W004.MATNR, 14, 4) WRK_INFO_01
        
                                ,  '계획연수(R)^' || NVL(RTRIM(TO_CHAR(S017.WRK_ORDR_QTY, 'fm999,999,999,999,990.999'), '.'), '0')
                                || '|계획중량(Kg)^' || NVL(RTRIM(TO_CHAR(ROUND(FN_CHG_UNIT ( S017.MATNR, P_WERKS, 'R', 'KG', NVL(S017.WRK_ORDR_QTY,0)) ,3), 'fm999,999,999,999,990.999'), '.'), '0') 
                                || '|'
                                || '|폐품코드^' || W004.DISPO_CD
                                || '|폐품원인^' || M023.DISPO_NM
                                || '|폐품량(M)^' || NVL(RTRIM(TO_CHAR(W004.ROLLCNT, 'fm999,999,999,999,990.999'), '.'), '0')
                                || '|폐품중량(Kg)^' || NVL(RTRIM(TO_CHAR(W004.WGT, 'fm999,999,999,999,990.999'), '.'), '0')
                                || '|'
        --                        || '|생산유형^' || CASE WHEN S017.MACHINE = 'PM2' THEN '라인교체' ELSE '자체생산' END
                                || '|생산호기^' || S017.MACHINE_NM
                                || '|이동호기^' || S017.TO_MACHINE_NM
        --                        || '|상태^' || W002.STA
                                || '|자재번호^' || W004.MATNR
                                || '|반^' || W004.WRK_CLASS
                                || '|작업자^' || USRMA.NMLAST
                                || '|'
                                || '|거래처^' || S017.KUNNRT
                                || '|판매오더번호^' || S017.VBELN || '-' || S017.POSNR  WRK_INFO_02
                              , S017.ORDER_RMK   WRK_RMK
                              , V_RMK    RMK
                            --INTO P_WRK_INFO_01, P_WRK_INFO_02, P_WRK_RMK, P_RMK
                            FROM TB_WRK004 W004    --PS폐품실적
                               , TB_SCH017 S017     --재단 작업지시
                               , TB_SCH016 S016     --밀롤 작업지시
                               , TB_MAS001 M001     --자재코드 마스터
                               , TB_MAS023 M023     --폐품항목관리 마스터
                               , USRMA USRMA
                            WHERE 1=1
                               AND W004.WERKS = S017.WERKS(+)
                               AND W004.WRK_ORDR_NO = S017.WRK_ORDR_NO(+)
                               AND W004.WRK_ORDR_SEQNO = S017.WRK_ORDR_SEQNO(+)
                               AND S017.PRE_ORDER_NO = S016.ORDER_NO(+)
                               AND W004.WERKS = M001.WERKS(+)
                               AND W004.MATNR = M001.MATNR(+)
                               AND W004.DISPO_CD = M023.DISPO_CD(+)
                               AND W004.REGID = USRMA.USERID(+)
                               AND W004.WERKS = P_WERKS
                               AND W004.IND_BCD = P_IND_BCD
                               AND W004.WRK_ORDR_NO = P_WRK_ORDR_NO
                               AND W004.WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO
                               AND NVL(W004.CNL_YN,'N') = 'N'
                      /*UNION ALL
                            SELECT '작업지시^' || W004.WRK_ORDR_NO || '-' || W004.WRK_ORDR_SEQNO
                                || '|재단오더번호^' || S017.ORDER_NO
                                || '|밀롤오더번호^' || NULL
                                || '|점보롤오더번호^' || NULL
                                || '|재단 LOT번호^' || W004.LOT_NO
                                || '|재단 개별바코드^' || W004.IND_BCD
                                || '|'
                                || '|운전상태^' || V_RUN_STA_NM     --'01'=정상, '02'=폐품, '09'=비계획생산
                                || '|지종^' || M001.PCODE
                                || '|지종명^' || M001.PCODE_NM
                                || '|평량(g/m²)^' || NVL(RTRIM(TO_CHAR(M001.BS_WGT, 'fm999,999,999,999,990.999'), '.'), '0')
                                || '|규격^' || SUBSTR(W004.MATNR, 10, 4) || '*' || SUBSTR(W004.MATNR, 14, 4) WRK_INFO_01
        
                                ,  '계획연수(R)^' || NVL(RTRIM(TO_CHAR(S017.WRK_ORDR_QTY, 'fm999,999,999,999,990.999'), '.'), '0')
                                || '|계획중량(Kg)^' || NVL(RTRIM(TO_CHAR(ROUND(FN_CHG_UNIT ( S017.MATNR, P_WERKS, 'R', 'KG', NVL(S017.WRK_ORDR_QTY,0)) ,3), 'fm999,999,999,999,990.999'), '.'), '0') 
                                || '|'
                                || '|폐품코드^' || W004.DISPO_CD
                                || '|폐품원인^' || M023.DISPO_NM
                                || '|폐품량(M)^' || NVL(RTRIM(TO_CHAR(W004.ROLLCNT, 'fm999,999,999,999,990.999'), '.'), '0')
                                || '|폐품중량(Kg)^' || NVL(RTRIM(TO_CHAR(W004.WGT, 'fm999,999,999,999,990.999'), '.'), '0')
                                || '|'
        --                        || '|생산유형^' || CASE WHEN S017.MACHINE = 'PM2' THEN '라인교체' ELSE '자체생산' END
                                || '|생산호기^' || NULL
                                || '|이동호기^' || NULL
        --                        || '|상태^' || W002.STA
                                || '|자재번호^' || W004.MATNR
                                || '|반^' || W004.WRK_CLASS
                                || '|작업자^' || USRMA.NMLAST
                                || '|'
                                || '|거래처^' || S017.KUNNRT
                                || '|판매오더번호^' || S017.VBELN || '-' || S017.POSNR  WRK_INFO_02
                              , NULL   WRK_RMK
                              , V_RMK    RMK
                            --INTO P_WRK_INFO_01, P_WRK_INFO_02, P_WRK_RMK, P_RMK
                            FROM TB_WRK004 W004    --PS폐품실적
                               , TB_SCH019 S017     --재단 작업지시
                               , TB_MAS001 M001     --자재코드 마스터
                               , TB_MAS023 M023     --폐품항목관리 마스터
                               , USRMA USRMA
                            WHERE 1=1
                               AND W004.WERKS = S017.WERKS
                               AND W004.WRK_ORDR_NO = S017.WRK_ORDR_NO
                               AND W004.WRK_ORDR_SEQNO = S017.WRK_ORDR_SEQNO
                               AND W004.WERKS = M001.WERKS(+)
                               AND W004.MATNR = M001.MATNR(+)
                               AND W004.DISPO_CD = M023.DISPO_CD(+)
                               AND W004.REGID = USRMA.USERID(+)
                               AND W004.WERKS = P_WERKS
                               AND W004.IND_BCD = P_IND_BCD
                               AND W004.WRK_ORDR_NO = P_WRK_ORDR_NO
                               AND W004.WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO
                               AND NVL(W004.CNL_YN,'N') = 'N'*/
                      
                        );
                        EXCEPTION
                              WHEN NO_DATA_FOUND THEN
                                  RS_CODE := 'E';
                                  RS_MSG := '작업지시 정보를 찾지 못했습니다.';
                                  RETURN;
                        END;
                               
                   END IF;

            --포장
            ELSE
--                dbms_output.put_line('자동포장, 수축포장, 수작업 포장 선택');
				SELECT '', '', '', ''
                    INTO P_WRK_INFO_01, P_WRK_INFO_02, P_WRK_RMK, P_RMK
                FROM DUAL;
            END IF;

            --작업 정상 종료 코드 등록
            RS_CODE := 'S';
        END;
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
        E_SQL_ERR_CD        := -20001;
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
