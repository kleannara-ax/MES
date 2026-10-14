--------------------------------------------------------
--  DDL for Procedure SP_IF_MIG_IMPORTED_MR
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_IF_MIG_IMPORTED_MR" (   
 i_CMDKY            IN    VARCHAR2    /*  Common code key               */
,o_msg_CODE         OUT   VARCHAR2
,o_msg_MSG          OUT   VARCHAR2
) AS
/*==============================================================================
 * PROGRAM ID    : 마이그레이션
 * PROGRAM NAME  : PIS 초기재고 SETUP(점보롤)
 * VERSION       : 1.0.0
 * DESCRIPTION   : PIS 초기재고 SETUP(점보롤)
 *                 
 * AUTHOR NAME   : 강현주
 * CREATE DATE   : 2022/08/09
 * SYSTEM NAME   : MES
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}	<생략가능>
 * SUB PROCEDURE : {아휘 프로시저 명칭 기술}		<생략가능>
 * SUB PACKAGES  : {하위 패키지 기술}			<생략가능>
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술}	<생략가능>
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/08/09    1.0.0   강현주         Initial Version 
 *==============================================================================
 * 관련 테이블
 * - [TN_IMPORTED_MR] : (.R..)수입밀롤 실적
 *=============================================================================*/
                                                                                            
  V_CNT             NUMBER          := 0;      -- 카운트(존재여부체크)
   
BEGIN


    

  
  o_msg_code      := '0' ;
  o_msg_msg       := 'OK';
    
EXCEPTION
  WHEN OTHERS THEN
    o_msg_code      := '-1' ;
    o_msg_msg       := 'Error:'||i_CMDKY||' 처리 중 오류가 발생하였습니다.' || ',' || to_char(SQLCODE) || ',' || SQLERRM ;
    DBMS_OUTPUT.PUT_LINE(o_msg_msg);
    --rollback ;

END;

/
