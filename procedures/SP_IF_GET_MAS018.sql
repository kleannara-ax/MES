
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_IF_GET_MAS018" (  
 i_IF_MES_ID        IN    VARCHAR2
,i_IF_MES_KEY       IN    VARCHAR2 
,o_msg_code         OUT   VARCHAR2
,o_msg_msg          OUT   VARCHAR2
) 
/*==============================================================================
 * PROGRAM ID    : 
 * PROGRAM NAME  : 인터페이스-부서마스타
 * VERSION       : 1.0.0{최종 버전 기술}
 * DESCRIPTION   : 부서마스타
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
 *       - [TB_IFR023]    : (.RU.) 부서마스타 I/F
 *       - [TB_MAS018]  : (.RU.) 부서마스타
 *=============================================================================*/
IS
  V_CNT   NUMBER  DEFAULT 0;
BEGIN
  DECLARE
    CURSOR  cur_ifr023 IS
      SELECT   IF_SEQ										--Interface Seq   			
							,IF_DATE                  --I/F 데이터 송신일시    
							,RECV_FLAG                --수신 시스템 처리 Flag  
							,RECV_ERR_MSG             --수신 시스템 처리 에러 메시지
							,RECV_DATE                --수신 시스템 처리일시     
							,DECODE(TENANT_ID,'KNARA','KN',TENANT_ID) TENANT_ID                --회사 코드 'KNARA->KN'           
							,TENANT_NAME              --회사명             
							,DEPT_CODE                --부서 코드           
							,DEPT_NAME                --부서명             
							,DEPT_ENG_NAME            --부서 영문명          
							,BUSINESS_PLACE           --사업장             
							,DIVISION_CODE            --사업부코드           
							,DIVISION_NAME            --사업부명            
							,PARENT_DEPT_CODE         --상위 조직코드         
							,SORT_ORDER               --정렬 순서           
							,USE_YN                   --사용 여부           
							,UPDT_DATE                --변경 일시           
							,UPDT_ID                  --변경 아이디          
							,NEXTHR_IF_SEQ            --Interface Seq   
							,REMARK1                  --비고1             
							,REMARK2                  --비고2             
							,REMARK3                  --비고3             
							,REMARK4                  --비고4             
							,REMARK5                  --비고5             
							,REMARK6                  --비고6             
							,REMARK7                  --비고7             
							,REMARK8                  --비고8             
							,REMARK9                  --비고9             
							,REMARK10                 --비고10 
      FROM    TB_IFR023
      WHERE   NVL(RECV_FLAG,'N')  in  ( 'N','E' )           /*  I/F상태, N:신규, S:성공, E:오류            */
      ORDER BY NEXTHR_IF_SEQ;

    
  BEGIN
    FOR ifr023 in cur_ifr023 loop
      BEGIN
      SELECT COUNT(COMPKY) INTO V_CNT 
      FROM TB_MAS018 
      WHERE COMPKY = ifr023.TENANT_ID 
      AND DEPT_CD = ifr023.DEPT_CODE;

      IF V_CNT > 0 THEN
             UPDATE TB_MAS018
             SET(    DEPT_KR_NM              								              --부서명    
										,DEPT_EN_NM              								              --부서 영문명 
										,UP_DEPT_CD                 								          --상위 조직코드
										,USE_YN                    								            --사용 여부             
                    ,UPDDATE                                              --수정일자
                    ,UPDID                                                --수정자
             )=
             (SELECT DEPT_NAME                   												  --부서명    
										,DEPT_ENG_NAME               												  --부서 영문명 
										,PARENT_DEPT_CODE            												  --상위 조직코드
										,USE_YN                      												  --사용 여부             
                    ,sysdate                      												--수정일자
                    ,'SP_IF_GET_MAS018'                  										--수정자
              FROM TB_IFR023
              WHERE  IF_SEQ =  ifr023.IF_SEQ
             )
             WHERE COMPKY = ifr023.TENANT_ID AND DEPT_CD = ifr023.DEPT_CODE;              

      ELSE
             INSERT INTO TB_MAS018 
             (         COMPKY										 						--회사 코드     
											,DEPT_CD                    					--부서 코드  
											,DEPT_KR_NM              						  --부서명    
											,DEPT_EN_NM              						  --부서 영문명 
											,UP_DEPT_CD                						--상위 조직코드
											,USE_YN                    						--사용 여부
                      ,REGDATE                       			  --등록일자
                      ,REGID                         			  --등록자
                      ,UPDDATE                       			  --수정일자
                      ,UPDID                         			  --수정자
             )
             SELECT    DECODE(TENANT_ID,'KNARA','KN',TENANT_ID) TENANT_ID            			 					--회사 코드     
											,DEPT_CODE                   					--부서 코드  
											,DEPT_NAME                   					--부서명    
											,DEPT_ENG_NAME               					--부서 영문명 
											,PARENT_DEPT_CODE            					--상위 조직코드
											,USE_YN                      					--사용 여부 
                      , sysdate                             --생성일자
                      , 'SP_IF_GET_MAS018'                    --생성자  
                      , null                                --수정일자
                      , null                                --수정자
             FROM TB_IFR023           
             WHERE  IF_SEQ =  ifr023.IF_SEQ     
             ;

      END IF;
    
      
      o_msg_msg  :=  '부서정보가 수신되었습니다.';

      UPDATE  TB_IFR023
      SET     RECV_FLAG   =  'S'                                                 --I/F상태, N:신규, S:성공, E:오류               
            , RECV_DATE =  sysdate                                              --데이터 처리시간(MES I/F 테이블 → MES 운영테이블) 
            , RECV_ERR_MSG =  o_msg_msg                                         --데이터 처리 결과 Message(Oracle) 
            , IF_MES_KEY =  i_IF_MES_KEY                         
      WHERE  IF_SEQ  =  ifr023.IF_SEQ   ;
      

      o_msg_msg       := '부서정보가 수신되었습니다.';
      o_msg_code      := '0' ;

      COMMIT;

      EXCEPTION
            WHEN OTHERS THEN
                  o_msg_msg  :=  'SP_IF_GET_MAS018=>' || '부서정보 수신 중 오류가 발생하였습니다.' || ',' || SQLERRM ;
                  o_msg_code      := '-1' ;
                  DBMS_OUTPUT.PUT_LINE (o_msg_msg );
                  ROLLBACK;

                  UPDATE  TB_IFR023
                  SET     RECV_FLAG   =  'E'                                     --I/F상태, N:신규, S:성공, E:오류               
                        , RECV_DATE =  sysdate                                  --데이터 처리시간(MES I/F 테이블 → MES 운영테이블) 
                        , RECV_ERR_MSG =  o_msg_msg                             --데이터 처리 결과 Message(Oracle)  
                        , IF_MES_KEY =  i_IF_MES_KEY                                    
                  WHERE  IF_SEQ  =  ifr023.IF_SEQ   ;
                  Commit ;
      END;
    END LOOP;

    o_msg_msg       := '실행완료';
    o_msg_code      := '0' ;

    EXCEPTION
      WHEN OTHERS THEN
        o_msg_code      := '-1' ;
        o_msg_msg       := 'SP_IF_GET_MAS018=>' || '부서정보 수신 중 MAIN에서 오류가 발생하였습니다.' || ',' || to_char(SQLCODE) || ',' || SQLERRM ;
        DBMS_OUTPUT.PUT_LINE(o_msg_msg);
        rollback ;

  END; 
END SP_IF_GET_MAS018;
/
