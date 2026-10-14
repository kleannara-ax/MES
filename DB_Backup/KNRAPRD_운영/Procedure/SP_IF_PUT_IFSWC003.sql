--------------------------------------------------------
--  DDL for Procedure SP_IF_PUT_IFSWC003
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_IF_PUT_IFSWC003" (
   i_IF_MES_ID        IN    VARCHAR2
  ,i_IF_MES_KEY       IN    VARCHAR2
  ,o_msg_code         OUT   VARCHAR2
  ,o_msg_msg          OUT   VARCHAR2
)
/*==============================================================================
 * PROGRAM ID    : 
 * PROGRAM NAME  : 인터페이스-지종평량마스타 정보 (MES->WCS)
 * VERSION       : 1.0.0{최종 버전 기술}
 * DESCRIPTION   : 지종평량마스타 정보 (MES->WCS)
 *                  
 *                  
 * AUTHOR NAME   : 강현주{최초 작성자 명 기술}
 * CREATE DATE   : 2022/06/30 {최초 작성일자 기술}
 * SYSTEM NAME   : MES->WCS
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}  <생략가능>
 * SUB PROCEDURE : {아휘 프로시저 명칭 기술}      <생략가능>
 * SUB PACKAGES  : {하위 패키지 기술}            <생략가능>
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술} <생략가능>
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/06/30    1.0.0   강현주         Initial Version 
 *==============================================================================
 *  관련 테이블    
 *       - [TB_IFSWC003]  : (.RU.) 지종평량마스타 정보
 *=============================================================================*/
AS

  V_CNT       NUMBER  DEFAULT 0;
  V_SYS_DT    VARCHAR2(20)  DEFAULT TO_CHAR(sysdate,'YYYYMMDD');  
BEGIN
  DECLARE
    CURSOR  cur_list IS
      SELECT   IF_IFR_NO                      --KEY
              ,CMCDKY													--코드구분 
							,CMCDKY_NM               			  --코드구분명
							,CMCDVL                   			--코드 코드
							,CMCDVL_NM                			--코드명                    
							,USE_YN                   			--사용유무                               
							,IF_STATUS                    	--WCS 결과값 Return( N: 대기, S:성공, E:오류 )
							,IF_GET_DATE                  	--MES 등록일시                           
							,IF_SET_DATE                  	--WCS 전송일시                           
							,IF_ERR_MESS                  	--WCS 결과 메시지                         
							,IF_MES_KEY                   	--MES Inserface Key(MES->WCS)         
      FROM    TB_IFSWC003
      WHERE   NVL(IF_STATUS,'N')  in  ( 'N' )           /*  I/F상태, N:신규, S:성공, E:오류            */
      --WHERE   NVL(IF_STATUS,'N')  in  ( 'N','E' )           /*  I/F상태, N:신규, S:성공, E:오류            */      
      ORDER BY IF_IFR_NO;


  BEGIN

    --보낼 마스타정보를 I/F테이블(TB_IFSWC003)에 생성 한다.
    INSERT INTO TB_IFSWC003(
       CMCDKY
      ,CMCDKY_NM
      ,CMCDVL
      ,CMCDVL_NM
      ,USE_YN
      ,IF_MES_KEY
    )  
    SELECT K.CMCDKY, K.CMCDKY_NM, K.CMCDVL, K.CM_CDVL_NM, K.USE_YN, i_IF_MES_KEY
    FROM (
      SELECT '00' AS CMCDKY, '플랜트' AS CMCDKY_NM, WERKS AS CMCDVL, PLANTNM AS CM_CDVL_NM, USE_YN AS USE_YN FROM TB_MAS002
      UNION
      SELECT '01' AS CMCDKY, '호기' AS CMCDKY_NM, CMCDVL AS CMCDVL, CDESC1 AS CM_CDVL_NM, USE_YN AS USE_YN FROM CMCDV WHERE CMCDKY = 'MACHINE'
      UNION
      SELECT '02' AS CMCDKY, '공정' AS CMCDKY_NM, PROC_CD AS CMCDVL, PROC_NM AS CM_CDVL_NM, 'Y' AS USE_YN FROM TB_MAS013
      UNION
      SELECT '04' AS CMCDKY, '설비' AS CMCDKY_NM, WCS_WRK_CD AS CMCDVL, WCS_WRK_NM AS CM_CDVL_NM, 'Y' AS USE_YN FROM TB_MAS012
      UNION
      SELECT '05' AS CMCDKY, '포장타입' AS CMCDKY_NM, CMCDVL AS CMCDVL, CDESC1 AS CM_CDVL_NM, USE_YN AS USE_YN FROM CMCDV WHERE CMCDKY = 'PACK_TYPE'
      UNION
      SELECT 'M' AS CMCDKY, '밀롤대기창고LOC' AS CMCDKY_NM, LOC_CD AS CMCDVL, LOC_NM AS CM_CDVL_NM, USE_YN AS USE_YN FROM TB_MAS028 WHERE USE_YN = 'Y'
      UNION
      SELECT '10' CMCDKY, '바코드상태' AS CMCDKY_NM, CMCDVL AS CMCDVL, CDESC1 AS CM_CDVL_NM, USE_YN AS USE_YN FROM CMCDV WHERE CMCDKY = 'BAR_STA'
      UNION      
      SELECT 'PCODE' AS CMCDKY, '지종코드(ERP)' AS CMCDKY_NM, P.PCODE AS CMCDVL, P.PCODE_NM AS CM_CDVL_NM, 'Y' AS USE_YN
      FROM (SELECT DISTINCT PCODE, PCODE_NM FROM TB_MAS001) P
      UNION
      SELECT 'STOCK' AS CMCDKY, '저장위치' AS CMCDKY_NM, WCS_STOR_LOC_CD AS CMCDVL, STOR_LOC_NM AS CM_CDVL_NM, USE_YN AS USE_YN FROM TB_MAS003 WHERE WCS_STOR_LOC_CD IS NOT NULL AND  WCS_STOR_LOC_CD <> ' '      
    ) K
    WHERE LENGTH(RTRIM(CMCDVL)) <> 0     
    ; 
    COMMIT;   


    FOR ifrrow in cur_list loop
      BEGIN
      --데이타전송
       INSERT INTO T_IF_PIS_MASTER_CODE@LNK_WCS(
               IF_SEQ
							,CODE_CLASS																						--코드 구분 
							,CLASS_NAME                   												--코드 구분명
							,PIS_CODE                     												--코드    
							,PIS_NAME                     												--코드명1    
							,USE_YN                       												--사용 여부 

							,UPDT_DATE                                            --변경 일시                      
							,UPDT_ID                                              --변경 아이디 	
       )VALUES(
               ifrrow.IF_IFR_NO
              ,ifrrow.CMCDKY																				--코드구분 
							,ifrrow.CMCDKY_NM               											--코드구분명
							,ifrrow.CMCDVL                   											--코드 코드
							,ifrrow.CMCDVL_NM                											--코드명                    
							,ifrrow.USE_YN                   											--사용유무   

              ,TO_DATE(V_SYS_DT,'YYYY-MM-DD')                         --생성일자
              ,'IFSWC003'                                              --생성자  
      );
      COMMIT;    

      o_msg_msg  :=  '지종평량마스타 정보 전송되었습니다.';

      UPDATE  TB_IFSWC003
      SET     IF_STATUS   =  'S'                                                 --I/F상태, N:신규, S:성공, E:오류               
            , IF_SET_DATE =  sysdate                                              --데이터 처리시간(MES I/F 테이블 → MES 운영테이블) 
            , IF_ERR_MESS =  o_msg_msg                                         --데이터 처리 결과 Message(Oracle)  
            , IF_MES_KEY  =  i_IF_MES_KEY              
      WHERE  IF_IFR_NO  =  ifrrow.IF_IFR_NO;


      o_msg_msg       := '지종평량마스타 정보 전송되었습니다.';
      o_msg_code      := '0' ;

      COMMIT;

      EXCEPTION
            WHEN OTHERS THEN
                  o_msg_msg  :=  'SP_IF_PUT_IFSWC003=>' || '지종평량마스타 정보 전송 중 오류가 발생하였습니다.' || ',' || SQLERRM ;
                  o_msg_code      := '-1' ;
                  DBMS_OUTPUT.PUT_LINE (o_msg_msg );
                  ROLLBACK;


                  UPDATE  TB_IFSWC003
                  SET     IF_STATUS   =  'E'                                      --I/F상태, N:신규, S:성공, E:오류               
                        , IF_SET_DATE =  sysdate                                --데이터 처리시간(MES I/F 테이블 → MES 운영테이블) 
                        , IF_ERR_MESS =  o_msg_msg                              --데이터 처리 결과 Message(Oracle)  
                        , IF_MES_KEY  =  i_IF_MES_KEY              
                  WHERE  IF_IFR_NO  =  ifrrow.IF_IFR_NO;             

                  Commit ;
      END;
    END LOOP;

    o_msg_msg       := '실행완료';
    o_msg_code      := '0' ;

    EXCEPTION
      WHEN OTHERS THEN
        o_msg_code      := '-1' ;
        o_msg_msg       := 'SP_IF_PUT_IFSWC003=>' || '지종평량마스타 정보 전송 중 MAIN에서 오류가 발생하였습니다.' || ',' || to_char(SQLCODE) || ',' || SQLERRM ;
        DBMS_OUTPUT.PUT_LINE(o_msg_msg);
        rollback ;

  END; 
END SP_IF_PUT_IFSWC003;

/
