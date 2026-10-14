
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_IFSINKJET_S01" 
(
  P_WERKS        IN VARCHAR2        --플랜트코드
, P_MACH_CD      IN VARCHAR2        --설비코드
, P_SUCCESS     OUT VARCHAR2 
, P_ERR_MSG     OUT VARCHAR2 
, P_RS_LIST   OUT SYS_REFCURSOR
) 
/*==============================================================================
 * PROGRAM ID    : SP_IFSINKJET_S01
 * PROGRAM NAME  : 
 * VERSION       : 1.0.0{최종 버전 기술}
 * DESCRIPTION   : 잉크젯 프린터로 LOT 정보 전송(HL) 
 *                 
 * AUTHOR NAME   : 유상호{최초 작성자 명 기술}
 * CREATE DATE   : 2022/08/04 {최초 작성일자 기술}
 * SYSTEM NAME   : MES
 * MAIN PROCEDURE: 
 * SUB PROCEDURE : 
 * SUB PACKAGES  : 
 * OLD PROGRAM ID: 
 * REVERSION HISTORY
  구분  플랜트  설비코드  설비명
 화장지	P200	TRA03	가공3호기
                TRA04	가공4호기
                TRA05	가공5호기
                TRA06	가공6호기

생리대	P300	SRB05	생리대5호기
                SRB06	생리대6호기

기저귀	P500	SRC05	기저귀5호기
                SRC06	기저귀6호기

 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/08/04    1.0.0   유상호         Initial Version 
 *=============================================================================*/
AS
    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD      NUMBER(5)           := 0;
    E_SQL_ERR_MSG     VARCHAR2(4000);
BEGIN

    OPEN P_RS_LIST FOR
     SELECT A.WERKS,
        A.MACH_CD,
--        A.LOT_NO,
		'S' || TO_CHAR(SYSDATE, 'yyMMdd') || SUBSTR(A.LOT_NO, 8, 3) AS LOT_NO,
        A.PP_NM,
        A.QC_NM,
        A.USER_NM,
        A.MACHINE,
--        CASE WHEN MOD(EXTRACT(YEAR FROM SYSDATE), 4) = 0 AND	(MOD(EXTRACT(YEAR FROM SYSDATE), 100) != 0 OR MOD(EXTRACT(YEAR FROM SYSDATE), 400) = 0) AND EXTRACT(MONTH FROM SYSDATE) > 2
--        		THEN
--			        CASE WHEN A.MACH_STA = 'N' THEN '' 
--			              ELSE TO_CHAR(TO_DATE(FN_RECDATE(A.RECDATE),'YYYYMMDD') + A.DSTBT_DDLIN - 1,'YYYYMMDD') END
--        		ELSE
--			        CASE WHEN A.MACH_STA = 'N' THEN '' 
--			              ELSE TO_CHAR(TO_DATE(FN_RECDATE(A.RECDATE),'YYYYMMDD') + A.DSTBT_DDLIN,'YYYYMMDD') END
--        END AS DSTBT_DDLIN
        CASE WHEN A.MACH_STA = 'N' THEN '' 
              ELSE TO_CHAR(TO_DATE(FN_RECDATE(A.RECDATE),'YYYYMMDD') + A.DSTBT_DDLIN-1,'YYYYMMDD') END AS DSTBT_DDLIN
      FROM(
             SELECT W011.WERKS,
                     W011.MACH_CD, 
                     CASE WHEN W011.MACH_STA = 'N' THEN '' ELSE W011.LOT_NO END LOT_NO,
                     U000.USER_NM           AS PP_NM,       --생산자 이니셜
                     U000.INSPR_NM          AS QC_NM,       --검수자 이니셜
                     U000.NMLAST            AS USER_NM,      --생산자명
                     TO_CHAR(M012.LINE)     AS MACHINE,      --생산호기(라인호기)
                     NVL(M001.DSTBT_DDLIN,365*3)  AS DSTBT_DDLIN
--                    , CASE WHEN W011.WERKS = 'P200' THEN '20' ||SUBSTR(LOT_NO, 3,2) || CASE WHEN SUBSTR(LOT_NO, 5,1) = 'A' THEN '10'
--                                                            WHEN SUBSTR(LOT_NO, 5,1) = 'B' THEN '11'
--                                                            WHEN SUBSTR(LOT_NO, 5,1) = 'C' THEN '12'
--                                                            ELSE '0' || SUBSTR(LOT_NO, 5, 1) END || SUBSTR(LOT_NO, 6,2) 
--                           ELSE                                 
--                                '20' || SUBSTR(LOT_NO, 2,6)
--                           END                                 AS RECDATE
                    ,TO_CHAR(SYSDATE, 'yyyyMMdd') AS RECDATE
                    ,W011.MACH_STA
                  FROM TB_WRK011 W011,
                       TB_MAS001 M001,
                       TB_MAS012 M012,
                       USRMA U000
                 WHERE W011.WERKS = M001.WERKS(+)
                   AND W011.MATNR = M001.MATNR(+)
                   AND W011.MACH_CD = M012.MACH_CD
                   AND W011.EMPLY_NO = U000.USERID(+) 
                   AND W011.WERKS = P_WERKS
                   AND W011.MACH_CD = P_MACH_CD
                   AND W011.IN_OUT IN('I', 'N')
        ) A;  

--    SELECT W011.WERKS,
--         W011.MACH_CD, 
--         W011.LOT_NO,
--         U000.USER_NM           AS PP_NM,       --생산자 이니셜
--         U000.INSPR_NM          AS QC_NM,       --검수자 이니셜
--         U000.NMLAST            AS USER_NM,      --생산자명
--         TO_CHAR(M012.LINE)     AS MACHINE,      --생산호기(라인호기)
--         TO_CHAR(TO_DATE(FN_RECDATE(SYSDATE),'YYYYMMDD') + NVL(M001.DSTBT_DDLIN,365*3),'YYYYMMDD') AS DSTBT_DDLIN  --유통일자
--      FROM TB_WRK011 W011,
--           TB_MAS001 M001,
--           TB_MAS012 M012,
--           USRMA U000
--     WHERE W011.WERKS = M001.WERKS(+)
--       AND W011.MATNR = M001.MATNR(+)
--       AND W011.MACH_CD = M012.MACH_CD
--       AND W011.EMPLY_NO = U000.USERID(+) 
--       AND W011.WERKS = P_WERKS
--       AND W011.MACH_CD = P_MACH_CD
--       AND W011.IN_OUT IN('I', 'N');

EXCEPTION
    WHEN OTHERS THEN
        P_SUCCESS  := 'N';
        E_SQL_ERR_CD        := -20000;
		E_SQL_ERR_MSG       := SQLCODE || ': V_PLT_CD OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';
        P_ERR_MSG := E_SQL_ERR_MSG;
        --SP_PROC_ERROR('', V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);
        P_ERR_MSG := 'SP_IFSINKJET_S01 : INSERT >>' || CHR(13) || CHR(10) || 'ERRCode : ' || TO_CHAR(SQLCODE);
        RAISE_APPLICATION_ERROR(-20938,SQLERRM);
        RETURN;
END;
/
