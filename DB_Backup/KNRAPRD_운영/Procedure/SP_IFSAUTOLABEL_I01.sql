--------------------------------------------------------
--  DDL for Procedure SP_IFSAUTOLABEL_I01
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_IFSAUTOLABEL_I01" 
(
  P_WERKS        IN VARCHAR2        --플랜트코드
, P_MACH_CD      IN VARCHAR2        --설비코드
, P_LOT_NO       IN VARCHAR2 
, P_IND_BCD      IN VARCHAR2 
, P_ERR_MSG      OUT VARCHAR2 
) 
/*==============================================================================
 * PROGRAM ID    : SP_IFSINKJET_S01
 * PROGRAM NAME  : 
 * VERSION       : 1.0.0{최종 버전 기술}
 * DESCRIPTION   : 오토라벨러 LOT 정보 수신(PS) 
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
    
    V_DATE          DATE :=SYSDATE;
BEGIN
    
    INSERT INTO TB_WRK019(WERKS, MACH_CD, IF_DATE, LOT_NO, IND_BCD, IF_STATUS, REGDATE, REGID)
                VALUES(P_WERKS, P_MACH_CD, V_DATE, P_LOT_NO, P_IND_BCD, 'N', V_DATE, 'AUTOLABEL');
    
    P_ERR_MSG := 'N';
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        P_ERR_MSG  := 'Y';
        E_SQL_ERR_CD        := -20000;
		E_SQL_ERR_MSG       := SQLCODE || ': V_PLT_CD OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';
        P_ERR_MSG := E_SQL_ERR_MSG;
        --SP_PROC_ERROR('', V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);
        P_ERR_MSG := 'SP_IFSINKJET_S01 : INSERT >>' || CHR(13) || CHR(10) || 'ERRCode : ' || TO_CHAR(SQLCODE);
        RAISE_APPLICATION_ERROR(-20938,SQLERRM);
        RETURN;
END;

/
