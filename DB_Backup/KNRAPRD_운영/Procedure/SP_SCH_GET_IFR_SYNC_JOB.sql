--------------------------------------------------------
--  DDL for Procedure SP_SCH_GET_IFR_SYNC_JOB
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_SCH_GET_IFR_SYNC_JOB" 
AS                                                                                     
/*==============================================================================
 * PROGRAM ID    : 마이그레이션
 * PROGRAM NAME  : 테스트
 * VERSION       : 1.0.0
 * DESCRIPTION   : 오라클 JOB 테스트
 *                 
 * AUTHOR NAME   : 강현주
 * CREATE DATE   : 2022/10/05
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/10/05  1.0.0   강현주         Initial Version 
 *==============================================================================
 * 관련 테이블
 * - [XXX] : (.I..)데이타 생성  
 *=============================================================================*/
 
  o_msg_code         VARCHAR2(1000)   := '';
  o_msg_MSG          VARCHAR2(4000)   := '';
   
 
  V_CNT              NUMBER           :=0; 
BEGIN
  
 
  SP_IF_MIG_LOG('SP_SCH_GET_IFR_SYNC_JOB','0','JOB호출.....................');
  COMMIT;                                                                   
                                                                      
       
  EXCEPTION
    WHEN OTHERS THEN   
      SP_IF_MIG_LOG('SP_SCH_GET_IFR_SYNC_JOB','-1',TO_CHAR(sysdate,'YYYY-MM-DD HH24:MI:SS') || '=>' || to_char(SQLCODE));
      COMMIT;       

END;

/
