--------------------------------------------------------
--  DDL for Procedure SP_IF_GET_MAS022
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_IF_GET_MAS022" (  
 i_IF_MES_ID        IN    VARCHAR2
,i_IF_MES_KEY       IN    VARCHAR2 
,o_msg_code         OUT   VARCHAR2
,o_msg_msg          OUT   VARCHAR2
) 
/*==============================================================================
 * PROGRAM ID    : 
 * PROGRAM NAME  : 인터페이스-일자별베일중량정보
 * VERSION       : 1.0.0{최종 버전 기술}
 * DESCRIPTION   : 일자별베일중량정보
 *                  
 *                  
 * AUTHOR NAME   : 강현주{최초 작성자 명 기술}
 * CREATE DATE   : 2022/07/31 {최초 작성일자 기술}
 * SYSTEM NAME   : MES
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}  <생략가능>
 * SUB PROCEDURE : {아휘 프로시저 명칭 기술}      <생략가능>
 * SUB PACKAGES  : {하위 패키지 기술}            <생략가능>
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술} <생략가능>
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/07/31    1.0.0   강현주         Initial Version 
 *==============================================================================
 *  관련 테이블    
 *       - [PULPIN]    : (.RU.) 일자별베일중량정보 I/F
 *       - [TB_MAS022]  : (.RU.) 일자별베일중량
 *=============================================================================*/
IS
  V_CNT   NUMBER  DEFAULT 0;
  
  V_WERKS    VARCHAR(10) DEFAULT '';
  V_STD_DATE VARCHAR(10) DEFAULT '';  
  V_PRE_DATE VARCHAR(10) DEFAULT '';
  
  V_WGT   NUMBER  DEFAULT 0;

BEGIN
  DECLARE
    CURSOR  cur_pulpin IS
      SELECT   IF_SEQ                   					--Interface Seq   
							,IF_DATE                  					--I/F 데이터 송신일시    
							,RECV_FLAG                					--수신 시스템 처리 Flag  
							,RECV_ERR_MSG             					--수신 시스템 처리 에러 메시지
							,RECV_DATE                					--수신 시스템 처리일시     
							,IV_EBELN                 					--구매문서번호          
							,IV_EBELP                 					--구매문서품목번호        
							,IV_MBLNR                 					--자재문서번호          
							,IV_ZEILE                 					--자재문서품목          
							,IV_MJAHR                 					--자재전표연도          
							,IV_STATUS                					--상태구분(C생성, D취소)  
							,IV_WERKS                 					--플랜트             
							,IV_BEDAT                 					--입고전기일           
							,IV_LIFNR                 					--공급업체            
							,IV_SEQ                   					--PDA 순번          
							,IV_MATNR                 					--자재코드            
							,IV_CAR_NUMBER            					--차량번호            
							,IV_DRIVER                					--운전자             
							,IV_CHECKER               					--검수인             
							,IV_DELIVERER             					--납품인             
							,IV_WEIGHER               					--계근인             
							,IV_BALE_CNT              					--bale수           
							,IV_WEIGHT_TIME           					--계량 일시           
							,IV_GR_MENGE              					--입고수량            
							,IV_MEINS                 					--단위              
							,IV_TOTAL_WEIGHT          					--총중량             
							,IV_EMPTY_WEIGHT          					--공차 중량           
							,IV_ACTUAL_WEIGHT         					--실중량             
							,IV_REGAIN1               					--수분율 (측정치 : 평균)  
							,IV_REGAIN2               					--협잡물 감량율 (추가감량)  
							,IV_REGAIN3               					--HPNA보정 감량율      
							,IV_REGAIN_REASON         					--감량 특이 사항        
							,IV_TOTAL_LOSE_RATIO      					--총감량율            
							,IV_LOSE_WEIGHT           					--감량 중량           
							,IV_VER1_TIME             					--1차 시간           
							,IV_VER2_TIME             					--2차 시간           
							,IV_VER1_WEIGHT           					--1차 중량           
							,IV_VER2_WEIGHT           					--2차 중량           
							,IV_BIGO1                 					--비고1             
							,IV_BIGO2                 					--비고2             
							,IV_BIGO3                 					--비고3             
							,IV_BIGO4                 					--비고4             
							,IV_BIGO5                 					--비고5             
							,IV_MOIST1                					--수분측정상세데이터1      
							,IV_MOIST2                					--수분측정상세데이터2      
							,IV_MOIST3                					--수분측정상세데이터3      
							,IV_MOIST4                					--수분측정상세데이터4      
							,IV_MOIST5                					--수분측정상세데이터5      
							,IV_MOIST6                					--수분측정상세데이터6      
							,IV_MOIST7                					--수분측정상세데이터7      
							,IV_MOIST8                					--수분측정상세데이터8      
							,IV_MOIST9                					--수분측정상세데이터9      
							,IV_MOIST10               					--수분측정상세데이터10 
      FROM    PULPIN
      WHERE   NVL(RECV_FLAG,'N')  in  ( 'N' )           /*  I/F상태, N:신규, S:성공, E:오류            */
      ORDER BY IF_SEQ;

    
  BEGIN
    FOR rowpulpin in cur_pulpin loop
      BEGIN
      
      SELECT COUNT(WERKS) INTO V_CNT 
      FROM TB_INV011 
      WHERE WERKS = rowpulpin.IV_WERKS 
      AND BEDAT = rowpulpin.IV_BEDAT
      AND LIFNR = rowpulpin.IV_LIFNR 
      AND SEQ = rowpulpin.IV_SEQ
      AND MATNR = rowpulpin.IV_MATNR;             

      IF V_CNT > 0 THEN
             UPDATE TB_INV011
             SET(    WERKS            																		--플랜트           
										,BEDAT            																		--입고전기일         
										,LIFNR            																		--공급업체          
										,SEQ              																		--PDA 순번        
										,MATNR            																		--자재코드          
										,CAR_NUMBER       																		--차량번호          
										,DRIVER           																		--운전자           
										,CHECKER          																		--검수인           
										,DELIVERER        																		--납품인           
										,WEIGHER          																		--계근인           
										,BALE_CNT         																		--bale수         
										,WEIGHT_TIME      																		--계량 일시         
										,GR_MENGE         																		--입고수량          
										,MEINS            																		--단위            
										,TOTAL_WEIGHT     																		--총중량           
										,EMPTY_WEIGHT     																		--공차 중량         
										,ACTUAL_WEIGHT    																		--실중량           
										,REGAIN1          																		--수분율 (측정치 : 평균)
										,REGAIN2          																		--협잡물 감량율 (추가감량)
										,REGAIN3          																		--HPNA보정 감량율    
										,REGAIN_REASON    																		--감량 특이 사항      
										,TOTAL_LOSE_RATIO 																		--총감량율          
										,LOSE_WEIGHT      																		--감량 중량         
										,VER1_TIME        																		--1차 시간         
										,VER2_TIME        																		--2차 시간         
										,VER1_WEIGHT      																		--1차 중량         
										,VER2_WEIGHT      																		--2차 중량         
										,BIGO1            																		--비고1           
										,BIGO2            																		--비고2           
										,BIGO3            																		--비고3           
										,BIGO4            																		--비고4           
										,BIGO5            																		--비고5           
										,MOIST1           																		--수분측정상세데이터1    
										,MOIST2           																		--수분측정상세데이터2    
										,MOIST3           																		--수분측정상세데이터3    
										,MOIST4           																		--수분측정상세데이터4    
										,MOIST5           																		--수분측정상세데이터5    
										,MOIST6           																		--수분측정상세데이터6    
										,MOIST7           																		--수분측정상세데이터7    
										,MOIST8           																		--수분측정상세데이터8    
										,MOIST9           																		--수분측정상세데이터9    
										,MOIST10          																		--수분측정상세데이터10 
										,STATUS                                               --상태구분(C생성, D취소)
             )=
             (SELECT IV_WERKS 																						--플랜트                     
                    ,IV_BEDAT                                             --입고전기일         
                    ,IV_LIFNR                                             --공급업체          
                    ,IV_SEQ                                               --PDA 순번        
                    ,IV_MATNR                                             --자재코드          
                    ,IV_CAR_NUMBER                                        --차량번호          
                    ,IV_DRIVER                                            --운전자           
                    ,IV_CHECKER                                           --검수인           
                    ,IV_DELIVERER                                         --납품인           
                    ,IV_WEIGHER                                           --계근인           
                    ,IV_BALE_CNT                                          --bale수         
                    ,IV_WEIGHT_TIME                                       --계량 일시         
                    ,IV_GR_MENGE                                          --입고수량          
                    ,IV_MEINS                                             --단위            
                    ,IV_TOTAL_WEIGHT                                      --총중량           
                    ,IV_EMPTY_WEIGHT                                      --공차 중량         
                    ,IV_ACTUAL_WEIGHT                                     --실중량           
                    ,IV_REGAIN1                                           --수분율 (측정치 : 평균)
                    ,IV_REGAIN2                                           --협잡물 감량율 (추가감량)
                    ,IV_REGAIN3                                           --HPNA보정 감량율    
                    ,IV_REGAIN_REASON                                     --감량 특이 사항      
                    ,IV_TOTAL_LOSE_RATIO                                  --총감량율          
                    ,IV_LOSE_WEIGHT                                       --감량 중량         
                    ,IV_VER1_TIME                                         --1차 시간         
                    ,IV_VER2_TIME                                         --2차 시간         
                    ,IV_VER1_WEIGHT                                       --1차 중량         
                    ,IV_VER2_WEIGHT                                       --2차 중량         
                    ,IV_BIGO1                                             --비고1           
                    ,IV_BIGO2                                             --비고2           
                    ,IV_BIGO3                                             --비고3           
                    ,IV_BIGO4                                             --비고4           
                    ,IV_BIGO5                                             --비고5           
                    ,IV_MOIST1                                            --수분측정상세데이터1    
                    ,IV_MOIST2                                            --수분측정상세데이터2    
                    ,IV_MOIST3                                            --수분측정상세데이터3    
                    ,IV_MOIST4                                            --수분측정상세데이터4    
                    ,IV_MOIST5                                            --수분측정상세데이터5    
                    ,IV_MOIST6                                            --수분측정상세데이터6    
                    ,IV_MOIST7                                            --수분측정상세데이터7    
                    ,IV_MOIST8                                            --수분측정상세데이터8    
                    ,IV_MOIST9                                            --수분측정상세데이터9    
                    ,IV_MOIST10                                           --수분측정상세데이터10
                    ,IV_STATUS                                            --상태구분(C생성, D취소)
              FROM PULPIN
              WHERE  IF_SEQ =  rowpulpin.IF_SEQ
             )
             WHERE WERKS = rowpulpin.IV_WERKS 
             AND BEDAT = rowpulpin.IV_BEDAT
             AND LIFNR = rowpulpin.IV_LIFNR 
             AND SEQ = rowpulpin.IV_SEQ
             AND MATNR = rowpulpin.IV_MATNR;               

      ELSE
             INSERT INTO TB_INV011 
             (       WERKS            																		--플랜트           
										,BEDAT            																		--입고전기일         
										,LIFNR            																		--공급업체          
										,SEQ              																		--PDA 순번        
										,MATNR            																		--자재코드          
										,CAR_NUMBER       																		--차량번호          
										,DRIVER           																		--운전자           
										,CHECKER          																		--검수인           
										,DELIVERER        																		--납품인           
										,WEIGHER          																		--계근인           
										,BALE_CNT         																		--bale수         
										,WEIGHT_TIME      																		--계량 일시         
										,GR_MENGE         																		--입고수량          
										,MEINS            																		--단위            
										,TOTAL_WEIGHT     																		--총중량           
										,EMPTY_WEIGHT     																		--공차 중량         
										,ACTUAL_WEIGHT    																		--실중량           
										,REGAIN1          																		--수분율 (측정치 : 평균)
										,REGAIN2          																		--협잡물 감량율 (추가감량)
										,REGAIN3          																		--HPNA보정 감량율    
										,REGAIN_REASON    																		--감량 특이 사항      
										,TOTAL_LOSE_RATIO 																		--총감량율          
										,LOSE_WEIGHT      																		--감량 중량         
										,VER1_TIME        																		--1차 시간         
										,VER2_TIME        																		--2차 시간         
										,VER1_WEIGHT      																		--1차 중량         
										,VER2_WEIGHT      																		--2차 중량         
										,BIGO1            																		--비고1           
										,BIGO2            																		--비고2           
										,BIGO3            																		--비고3           
										,BIGO4            																		--비고4           
										,BIGO5            																		--비고5           
										,MOIST1           																		--수분측정상세데이터1    
										,MOIST2           																		--수분측정상세데이터2    
										,MOIST3           																		--수분측정상세데이터3    
										,MOIST4           																		--수분측정상세데이터4    
										,MOIST5           																		--수분측정상세데이터5    
										,MOIST6           																		--수분측정상세데이터6    
										,MOIST7           																		--수분측정상세데이터7    
										,MOIST8           																		--수분측정상세데이터8    
										,MOIST9           																		--수분측정상세데이터9    
										,MOIST10          																		--수분측정상세데이터10 
										,STATUS                                               --상태구분(C생성, D취소)
             )
             SELECT  IV_WERKS 																						--플랜트                     
                    ,IV_BEDAT                                             --입고전기일         
                    ,IV_LIFNR                                             --공급업체          
                    ,IV_SEQ                                               --PDA 순번        
                    ,IV_MATNR                                             --자재코드          
                    ,IV_CAR_NUMBER                                        --차량번호          
                    ,IV_DRIVER                                            --운전자           
                    ,IV_CHECKER                                           --검수인           
                    ,IV_DELIVERER                                         --납품인           
                    ,IV_WEIGHER                                           --계근인           
                    ,IV_BALE_CNT                                          --bale수         
                    ,IV_WEIGHT_TIME                                       --계량 일시         
                    ,IV_GR_MENGE                                          --입고수량          
                    ,IV_MEINS                                             --단위            
                    ,IV_TOTAL_WEIGHT                                      --총중량           
                    ,IV_EMPTY_WEIGHT                                      --공차 중량         
                    ,IV_ACTUAL_WEIGHT                                     --실중량           
                    ,IV_REGAIN1                                           --수분율 (측정치 : 평균)
                    ,IV_REGAIN2                                           --협잡물 감량율 (추가감량)
                    ,IV_REGAIN3                                           --HPNA보정 감량율    
                    ,IV_REGAIN_REASON                                     --감량 특이 사항      
                    ,IV_TOTAL_LOSE_RATIO                                  --총감량율          
                    ,IV_LOSE_WEIGHT                                       --감량 중량         
                    ,IV_VER1_TIME                                         --1차 시간         
                    ,IV_VER2_TIME                                         --2차 시간         
                    ,IV_VER1_WEIGHT                                       --1차 중량         
                    ,IV_VER2_WEIGHT                                       --2차 중량         
                    ,IV_BIGO1                                             --비고1           
                    ,IV_BIGO2                                             --비고2           
                    ,IV_BIGO3                                             --비고3           
                    ,IV_BIGO4                                             --비고4           
                    ,IV_BIGO5                                             --비고5           
                    ,IV_MOIST1                                            --수분측정상세데이터1    
                    ,IV_MOIST2                                            --수분측정상세데이터2    
                    ,IV_MOIST3                                            --수분측정상세데이터3    
                    ,IV_MOIST4                                            --수분측정상세데이터4    
                    ,IV_MOIST5                                            --수분측정상세데이터5    
                    ,IV_MOIST6                                            --수분측정상세데이터6    
                    ,IV_MOIST7                                            --수분측정상세데이터7    
                    ,IV_MOIST8                                            --수분측정상세데이터8    
                    ,IV_MOIST9                                            --수분측정상세데이터9    
                    ,IV_MOIST10                                           --수분측정상세데이터10
                    ,IV_STATUS                                            --상태구분(C생성, D취소)
             FROM PULPIN           
             WHERE  IF_SEQ =  rowpulpin.IF_SEQ     
             ;

      END IF;


      --TB_MAS022(고지펄프입고) 현재일부터 일주일전SUM
/*
      SELECT to_char(sysdate-6,'yyyymmdd') INTO V_PRE_DATE FROM DUAL;
      
      SELECT COUNT(WERKS) INTO V_CNT
      FROM TB_MAS022
      WHERE WERKS = rowpulpin.IV_WERKS
      AND DT = to_char(sysdate,'yyyymmdd');
      
      IF V_CNT > 0 THEN
        SELECT NVL(SUM(ACTUAL_WEIGHT),0) INTO V_WGT
        FROM TB_INV011 
        WHERE WERKS = rowpulpin.IV_WERKS
        AND BEDAT BETWEEN V_PRE_DATE AND to_char(sysdate,'yyyymmdd')
        AND STATUS = 'C';       
      
        UPDATE TB_MAS022
        SET WEIGHT_V = V_WGT
           ,UPDDATE = SYSDATE
           ,UPDID = 'IF_MAS022'
        WHERE WERKS = rowpulpin.IV_WERKS
        AND DT = to_char(sysdate,'yyyymmdd');        
      ELSE
        SELECT NVL(SUM(ACTUAL_WEIGHT),0) INTO V_WGT
        FROM TB_INV011 
        WHERE WERKS = rowpulpin.IV_WERKS
        AND BEDAT BETWEEN V_PRE_DATE AND to_char(sysdate,'yyyymmdd')
        AND STATUS = 'C';          
              
        INSERT INTO TB_MAS022(WERKS,DT,WEIGHT_V,REGDATE,REGID,UPDDATE,UPDID)
        VALUES(rowpulpin.IV_WERKS,to_char(sysdate,'yyyymmdd'),V_WGT,sysdate,'IF_MAS022',null,null);      
      END IF;                      
 */     
      o_msg_msg  :=  '고지펄프정보가 수신되었습니다.';

      UPDATE  PULPIN
      SET     RECV_FLAG   =  'S'                                                 --I/F상태, N:신규, S:성공, E:오류               
            , RECV_DATE =  sysdate                                              --데이터 처리시간(MES I/F 테이블 → MES 운영테이블) 
            , RECV_ERR_MSG =  o_msg_msg                                         --데이터 처리 결과 Message(Oracle) 
            , IF_MES_KEY =  i_IF_MES_KEY                         
      WHERE  IF_SEQ  =  rowpulpin.IF_SEQ   ;
      

      o_msg_msg       := '고지펄프정보가 수신되었습니다.';
      o_msg_code      := '0' ;

      COMMIT;

      EXCEPTION
            WHEN OTHERS THEN
                  o_msg_msg  :=  'SP_IF_GET_MAS022=>' || '고지펄프 수신 중 오류가 발생하였습니다.' || ',' || SQLERRM ;
                  o_msg_code      := '-1' ;
                  DBMS_OUTPUT.PUT_LINE (o_msg_msg );
                  ROLLBACK;

                  UPDATE  PULPIN
                  SET     RECV_FLAG   =  'E'                                     --I/F상태, N:신규, S:성공, E:오류               
                        , RECV_DATE =  sysdate                                  --데이터 처리시간(MES I/F 테이블 → MES 운영테이블) 
                        , RECV_ERR_MSG =  o_msg_msg                             --데이터 처리 결과 Message(Oracle)  
                        , IF_MES_KEY =  i_IF_MES_KEY                                    
                  WHERE  IF_SEQ  =  rowpulpin.IF_SEQ   ;
                  Commit ;
      END;
    END LOOP;
    
    
    --------------------------------------------------------------------------------------------------------------------------
    --TB_INV011의 데이타를 기준으로 마지막 일자기준으로 일주일평균을 산출 한다.(220727 변경함)
    --------------------------------------------------------------------------------------------------------------------------
    V_WERKS := 'P100';
    V_STD_DATE := '';
    
/*    
    SELECT MAX(BEDAT) INTO V_STD_DATE
    FROM TB_INV011
    WHERE WERKS = V_WERKS
    AND BEDAT BETWEEN TO_CHAR(TO_DATE(V_STD_DATE,'YYYY-MM-DD')-30,'yyyymmdd') AND TO_CHAR(sysdate,'yyyymmdd');
*/
    SELECT MAX(BEDAT) INTO V_STD_DATE
    FROM TB_INV011
    WHERE WERKS = V_WERKS
    AND BEDAT BETWEEN TO_CHAR(sysdate-30,'yyyymmdd') AND TO_CHAR(sysdate,'yyyymmdd');       
    
    IF LENGTH(V_STD_DATE) != 0 THEN
      --TB_MAS022(고지펄프입고) 현재일부터 일주일전SUM
      SELECT to_char(TO_DATE(V_STD_DATE,'YYYY-MM-DD')-6,'yyyymmdd') INTO V_PRE_DATE FROM DUAL;
      
      SELECT COUNT(WERKS) INTO V_CNT
      FROM TB_MAS022
      WHERE WERKS = V_WERKS   
      AND DT = to_char(sysdate,'yyyymmdd');
      
      SELECT AVG(NVL(ACTUAL_WEIGHT, 0)) INTO V_WGT
      FROM TB_INV011 
      WHERE WERKS = V_WERKS
      AND BEDAT BETWEEN V_PRE_DATE AND V_STD_DATE
      AND STATUS = 'C';     
              
      IF V_CNT > 0 THEN      
        UPDATE TB_MAS022
        SET WEIGHT_V = V_WGT
           ,UPDDATE = SYSDATE
           ,UPDID = 'IF_MAS022'
        WHERE WERKS = V_WERKS
        AND DT = to_char(sysdate,'yyyymmdd');        
      ELSE
        INSERT INTO TB_MAS022(WERKS,DT,WEIGHT_V,REGDATE,REGID,UPDDATE,UPDID)
        VALUES(V_WERKS,to_char(sysdate,'yyyymmdd'),V_WGT,sysdate,'IF_MAS022',null,null);      
      END IF;
    END IF;    
    
    --
    V_WERKS := 'P200';
    V_STD_DATE := '';
    
/*    
    SELECT MAX(BEDAT) INTO V_STD_DATE
    FROM TB_INV011
    WHERE WERKS = V_WERKS
    AND BEDAT BETWEEN TO_CHAR(TO_DATE(V_STD_DATE,'YYYY-MM-DD')-30,'yyyymmdd') AND TO_CHAR(sysdate,'yyyymmdd');  
*/

    SELECT MAX(BEDAT) INTO V_STD_DATE
    FROM TB_INV011
    WHERE WERKS = V_WERKS
    AND BEDAT BETWEEN TO_CHAR(sysdate-30,'yyyymmdd') AND TO_CHAR(sysdate,'yyyymmdd'); 
    
    IF LENGTH(V_STD_DATE) != 0 THEN
      --TB_MAS022(고지펄프입고) 현재일부터 일주일전SUM
      SELECT to_char(TO_DATE(V_STD_DATE,'YYYY-MM-DD')-6,'yyyymmdd') INTO V_PRE_DATE FROM DUAL;
      
      SELECT COUNT(WERKS) INTO V_CNT
      FROM TB_MAS022
      WHERE WERKS = V_WERKS   
      AND DT = to_char(sysdate,'yyyymmdd');
      
      SELECT AVG(NVL(ACTUAL_WEIGHT, 0)) INTO V_WGT
      FROM TB_INV011 
      WHERE WERKS = V_WERKS
      AND BEDAT BETWEEN V_PRE_DATE AND V_STD_DATE
      AND STATUS = 'C';     
              
      IF V_CNT > 0 THEN      
        UPDATE TB_MAS022
        SET WEIGHT_V = V_WGT
           ,UPDDATE = SYSDATE
           ,UPDID = 'IF_MAS022'
        WHERE WERKS = V_WERKS
        AND DT = to_char(sysdate,'yyyymmdd');        
      ELSE
        INSERT INTO TB_MAS022(WERKS,DT,WEIGHT_V,REGDATE,REGID,UPDDATE,UPDID)
        VALUES(V_WERKS,to_char(sysdate,'yyyymmdd'),V_WGT,sysdate,'IF_MAS022',null,null);      
      END IF;
    END IF;   
            
    
    --
    V_WERKS := 'P300';
    V_STD_DATE := '';
    
/*    
    SELECT MAX(BEDAT) INTO V_STD_DATE
    FROM TB_INV011
    WHERE WERKS = V_WERKS
    AND BEDAT BETWEEN TO_CHAR(TO_DATE(V_STD_DATE,'YYYY-MM-DD')-30,'yyyymmdd') AND TO_CHAR(sysdate,'yyyymmdd');  
*/    
    SELECT MAX(BEDAT) INTO V_STD_DATE
    FROM TB_INV011
    WHERE WERKS = V_WERKS
    AND BEDAT BETWEEN TO_CHAR(sysdate-30,'yyyymmdd') AND TO_CHAR(sysdate,'yyyymmdd'); 

    IF LENGTH(V_STD_DATE) != 0 THEN
      --TB_MAS022(고지펄프입고) 현재일부터 일주일전SUM
      SELECT to_char(TO_DATE(V_STD_DATE,'YYYY-MM-DD')-6,'yyyymmdd') INTO V_PRE_DATE FROM DUAL;
      
      SELECT COUNT(WERKS) INTO V_CNT
      FROM TB_MAS022
      WHERE WERKS = V_WERKS   
      AND DT = to_char(sysdate,'yyyymmdd');
      
      SELECT AVG(NVL(ACTUAL_WEIGHT, 0)) INTO V_WGT
      FROM TB_INV011 
      WHERE WERKS = V_WERKS
      AND BEDAT BETWEEN V_PRE_DATE AND V_STD_DATE
      AND STATUS = 'C';     
              
      IF V_CNT > 0 THEN      
        UPDATE TB_MAS022
        SET WEIGHT_V = V_WGT
           ,UPDDATE = SYSDATE
           ,UPDID = 'IF_MAS022'
        WHERE WERKS = V_WERKS
        AND DT = to_char(sysdate,'yyyymmdd');        
      ELSE
        INSERT INTO TB_MAS022(WERKS,DT,WEIGHT_V,REGDATE,REGID,UPDDATE,UPDID)
        VALUES(V_WERKS,to_char(sysdate,'yyyymmdd'),V_WGT,sysdate,'IF_MAS022',null,null);      
      END IF;
    END IF;     
    
    
    --
    V_WERKS := 'P500';
    V_STD_DATE := '';
    
/*    
    SELECT MAX(BEDAT) INTO V_STD_DATE
    FROM TB_INV011
    WHERE WERKS = V_WERKS
    AND BEDAT BETWEEN TO_CHAR(TO_DATE(V_STD_DATE,'YYYY-MM-DD')-30,'yyyymmdd') AND TO_CHAR(sysdate,'yyyymmdd');  
*/

    SELECT MAX(BEDAT) INTO V_STD_DATE
    FROM TB_INV011
    WHERE WERKS = V_WERKS
    AND BEDAT BETWEEN TO_CHAR(sysdate-30,'yyyymmdd') AND TO_CHAR(sysdate,'yyyymmdd');  
    
    IF LENGTH(V_STD_DATE) != 0 THEN
      --TB_MAS022(고지펄프입고) 현재일부터 일주일전SUM
      SELECT to_char(TO_DATE(V_STD_DATE,'YYYY-MM-DD')-6,'yyyymmdd') INTO V_PRE_DATE FROM DUAL;
      
      SELECT COUNT(WERKS) INTO V_CNT
      FROM TB_MAS022
      WHERE WERKS = V_WERKS   
      AND DT = to_char(sysdate,'yyyymmdd');
      
      SELECT AVG(NVL(ACTUAL_WEIGHT, 0)) INTO V_WGT
      FROM TB_INV011 
      WHERE WERKS = V_WERKS
      AND BEDAT BETWEEN V_PRE_DATE AND V_STD_DATE
      AND STATUS = 'C';     
              
      IF V_CNT > 0 THEN      
        UPDATE TB_MAS022
        SET WEIGHT_V = V_WGT
           ,UPDDATE = SYSDATE
           ,UPDID = 'IF_MAS022'
        WHERE WERKS = V_WERKS
        AND DT = to_char(sysdate,'yyyymmdd');        
      ELSE
        INSERT INTO TB_MAS022(WERKS,DT,WEIGHT_V,REGDATE,REGID,UPDDATE,UPDID)
        VALUES(V_WERKS,to_char(sysdate,'yyyymmdd'),V_WGT,sysdate,'IF_MAS022',null,null);      
      END IF;
    END IF;    

    o_msg_msg       := '실행완료';
    o_msg_code      := '0' ;

    EXCEPTION
      WHEN OTHERS THEN
        o_msg_code      := '-1' ;
        o_msg_msg       := 'SP_IF_GET_MAS022=>' || '고지펄프 수신 중 MAIN에서 오류가 발생하였습니다.' || ',' || to_char(SQLCODE) || ',' || SQLERRM ;
        DBMS_OUTPUT.PUT_LINE(o_msg_msg);
        rollback ;

  END; 
END SP_IF_GET_MAS022;

/
