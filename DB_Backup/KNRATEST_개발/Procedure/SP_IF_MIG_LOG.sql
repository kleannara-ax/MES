--------------------------------------------------------
--  DDL for Procedure SP_IF_MIG_LOG
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_IF_MIG_LOG" (
 i_PROC_ID          IN    VARCHAR2
,i_PROC_CD          IN    VARCHAR2
,i_PROC_MSG         IN    VARCHAR2
) AS                                                                                     
/*==============================================================================
 * PROGRAM ID    : 마이그레이션
 * PROGRAM NAME  : PIS 초기재고 LOG
 * VERSION       : 1.0.0
 * DESCRIPTION   : PIS 초기재고 LOG
 *                 
 * AUTHOR NAME   : 강현주
 * CREATE DATE   : 2022/08/10
 * SYSTEM NAME   : MES
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}	<생략가능>
 * SUB PROCEDURE : {아휘 프로시저 명칭 기술}		<생략가능>
 * SUB PACKAGES  : {하위 패키지 기술}			<생략가능>
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술}	<생략가능>
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/08/10    1.0.0   강현주         Initial Version 
 *==============================================================================
 * 관련 테이블
 * - [TB_MIG_LOG] : (.R..)PIS Migration Log                                
 *=============================================================================*/
 
 
BEGIN

  INSERT INTO TB_MIG_LOG(PROC_ID,PROC_CD,PROC_MSG,PROC_DT)
  VALUES(i_PROC_ID,i_PROC_CD,i_PROC_MSG,sysdate);
       
  EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('Error: SP_IF_MIG_LOG=>' ||to_char(SQLCODE) || '=>' || SQLERRM);

END;

/
