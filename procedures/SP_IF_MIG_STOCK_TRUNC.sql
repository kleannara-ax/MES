
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_IF_MIG_STOCK_TRUNC" (   
 o_msg_CODE         OUT   VARCHAR2
,o_msg_MSG          OUT   VARCHAR2
) AS
/*==============================================================================
 * PROGRAM ID    : 마이그레이션
 * PROGRAM NAME  : 초기재고 SETUP(ALL)
 * VERSION       : 1.0.0
 * DESCRIPTION   : 초기재고 SETUP(ALL)
 *                 
 * AUTHOR NAME   : 강현주
 * CREATE DATE   : 2022/09/02
 * SYSTEM NAME   : MES
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}	<생략가능>
 * SUB PROCEDURE : {아휘 프로시저 명칭 기술}		<생략가능>
 * SUB PACKAGES  : {하위 패키지 기술}			<생략가능>
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술}	<생략가능>
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/09/02    1.0.0   강현주         Initial Version 
 * 2022/09/13    1.0.1   강현주         작업지시 생성(점보롤,밀롤,재단,포장), 생산실적 생성(PS)
 * 2022/09/14    1.0.2   강현주         재단 단위 'R' -> 'EA'로 계산
 * 2022/09/14    1.0.2   강현주         오더번호,판매문서번호,거래처 SUBSTR 추가
 *==============================================================================
 * 관련 테이블
 * - [TX_BASE_INIT] : (.R..)초기재고데이타                                
 *=============================================================================*/
            
 
   
BEGIN
  
  --execute immediate 'truncate table TX_PIS_INIT';  
  --execute immediate 'truncate table TX_BASE_INIT_TEMP';    

      o_msg_code      := '-1' ;
      o_msg_msg       := 'MAIN에서 오류가 발생하였습니다.' || ',' || to_char(SQLCODE) || ',' || SQLERRM ;

  EXCEPTION
    WHEN OTHERS THEN   
      o_msg_code      := '-1' ;
      o_msg_msg       := 'MAIN에서 오류가 발생하였습니다.' || ',' || to_char(SQLCODE) || ',' || SQLERRM ;
      DBMS_OUTPUT.PUT_LINE(o_msg_msg);

                
         
        
END;
/
