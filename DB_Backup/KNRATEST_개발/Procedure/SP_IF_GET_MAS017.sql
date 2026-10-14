--------------------------------------------------------
--  DDL for Procedure SP_IF_GET_MAS017
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_IF_GET_MAS017" (  
 i_IF_MES_ID        IN    VARCHAR2
,i_IF_MES_KEY       IN    VARCHAR2
,o_msg_code         OUT   VARCHAR2
,o_msg_msg          OUT   VARCHAR2
) 
/*==============================================================================
 * PROGRAM ID    : 
 * PROGRAM NAME  : 인터페이스-사원마스타
 * VERSION       : 1.0.0{최종 버전 기술}
 * DESCRIPTION   : 사원마스타
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
 *       - [TB_IFR012]    : (.RU.) 사원마스타 I/F
 *       - [TB_MAS017]  : (.RU.) 사원마스타
 *       - [USRMA]       : (.RU.) 사용자마스타
 *=============================================================================*/
IS
  V_CNT   NUMBER  DEFAULT 0;
BEGIN
  DECLARE
    CURSOR  cur_ifr012 IS
      SELECT   IF_SEQ												 --Interface Seq   
							,IF_DATE                       --I/F 데이터 송신일시    
							,RECV_FLAG                     --수신 시스템 처리 Flag  
							,RECV_ERR_MSG                  --수신 시스템 처리 에러 메시지
							,RECV_DATE                     --수신 시스템 처리일시     
							,DECODE(TENANT_ID,'KNARA','KN',TENANT_ID) TENANT_ID                     --회사 코드           
							,TENANT_NAME                   --회사명             
							,EMP_NO                        --사번              
							,MAIL_ID                       --아이디(메일아이디)      
							,MAIL_ADDRESS                  --메일 주소           
							,EMP_NAME                      --이름              
							,EMP_ENG_NAME                  --영문 이름           
							,EMP_TYPE                      --사원 유형           
							,WORK_PLACE                    --근무지             
							,WORK_TYPE                     --근무 유형           
							,DEPT_CODE                     --부서 코드           
							,JOB_TITLE_CODE                --직위코드            
							,JOB_TITLE_NAME                --직위명             
							,JOB_DUTY_CODE                 --직책코드            
							,JOB_DUTY_NAME                 --직책명             
							,COUNTRY_CODE                  --국가코드            
							,COUNTRY_NAME                  --국가명             
							,LANGUAGE_TYPE                 --언어코드            
							,GRANTER_MAIL_ID               --결재자 아이디(메일 아이디) 
							,MOBILE                        --휴대폰 번호          
							,OFFICE_TEL_NO                 --사무실 전화 번호       
							,STATUS                        --재/퇴직 상태         
							,RETIRE_YMD                    --퇴직일             
							,UPDT_DATE                     --변경일시            
							,UPDT_ID                       --변경 아이디          
							,NEXTHR_IF_SEQ                 --Interface Seq   
							,REMARK1                       --비고1             
							,REMARK2                       --비고2             
							,REMARK3                       --비고3             
							,REMARK4                       --비고4             
							,REMARK5                       --비고5             
							,REMARK6                       --비고6             
							,REMARK7                       --비고7             
							,REMARK8                       --비고8             
							,REMARK9                       --비고9             
							,REMARK10                      --비고10 
      FROM    TB_IFR012
      WHERE   NVL(RECV_FLAG,'N')  in  ( 'N','E' )           /*  I/F상태, N:신규, S:성공, E:오류            */
      ORDER BY NEXTHR_IF_SEQ;

    
  BEGIN
    FOR ifr012 in cur_ifr012 loop
      BEGIN
      --사원정보구성
      SELECT COUNT(EMPLY_NO) INTO V_CNT FROM TB_MAS017 WHERE EMPLY_NO = ifr012.EMP_NO;

      IF V_CNT > 0 THEN
             UPDATE TB_MAS017
             SET(    EMPLY_NO											         								--사원번호     
										,EMAIL                                 								--이메일      
										,EMPLY_KR_NM                           								--사원명(한글)  
										,EMPLY_EN_NM                           								--사원명(영문)  
										,EMPLY_DIV                             								--직원구분     
										,DEPT_CD                               								--부서코드     
										,PST_CD                                								--직위코드     
										,PST_NM                                								--직위명      
										,DUT_CD                                								--직책코드     
										,DUT_NM                                								--직책명      
										,RETR_YN                               								--퇴직여부(Y/N)          
                    ,UPDDATE                                              --수정일자
                    ,UPDID                                                --수정자
             )=
             (SELECT EMP_NO                      													--사원번호     
										,MAIL_ADDRESS                													--이메일      
										,EMP_NAME                    													--사원명(한글)  
										,EMP_ENG_NAME                													--사원명(영문)  
										,WORK_TYPE                   													--직원구분     
										,DEPT_CODE                   													--부서코드     
										,JOB_TITLE_CODE              													--직위코드     
										,JOB_TITLE_NAME              													--직위명      
										,JOB_DUTY_CODE               													--직책코드     
										,JOB_DUTY_NAME               													--직책명      
										,case when STATUS = 'T' then 'Y'
                          else 'N'                                         
                     end                       													  --퇴직여부(Y/N)             
                    ,sysdate                      												--수정일자
                    ,'SP_IF_GET_MAS017'                  										  --수정자
              FROM TB_IFR012
              WHERE  IF_SEQ =  ifr012.IF_SEQ
             )
             WHERE EMPLY_NO = ifr012.EMP_NO;              

      ELSE
             INSERT INTO TB_MAS017 
             (       EMPLY_NO											         								--사원번호     
										,EMAIL                                 								--이메일      
										,EMPLY_KR_NM                           								--사원명(한글)  
										,EMPLY_EN_NM                           								--사원명(영문)  
										,EMPLY_DIV                             								--직원구분     
										,DEPT_CD                               								--부서코드     
										,PST_CD                                								--직위코드     
										,PST_NM                                								--직위명      
										,DUT_CD                                								--직책코드     
										,DUT_NM                                								--직책명      
										,RETR_YN                               								--퇴직여부(Y/N) 
										
                    ,REGDATE                       			                  --등록일자
                    ,REGID                         			                  --등록자
                    ,UPDDATE                       			                  --수정일자
                    ,UPDID                         			                  --수정자
             )
             SELECT  EMP_NO                      		                      --사원번호     
										,MAIL_ADDRESS                													--이메일      
										,EMP_NAME                    													--사원명(한글)  
										,EMP_ENG_NAME                													--사원명(영문)  
										,WORK_TYPE                   													--직원구분     
										,DEPT_CODE                   													--부서코드     
										,JOB_TITLE_CODE              													--직위코드     
										,JOB_TITLE_NAME              													--직위명      
										,JOB_DUTY_CODE               													--직책코드     
										,JOB_DUTY_NAME               													--직책명      
										,case when STATUS = 'T' then 'Y'
                          else 'N'                                         
                     end                      													  --퇴직여부(Y/N)
										     
                    ,sysdate                                              --생성일자
                    ,'SP_IF_GET_MAS017'                                       --생성자  
                    ,null                                                 --수정일자
                    ,null                                                 --수정자
             FROM TB_IFR012           
             WHERE  IF_SEQ =  ifr012.IF_SEQ     
             ;

      END IF;
      
      
      --사용자정보구성
      SELECT COUNT(USERID) INTO V_CNT FROM USRMA WHERE USERID = ifr012.MAIL_ID;

      IF V_CNT > 0 THEN
             UPDATE USRMA
             SET(    EMPLY_DIV                                 						--직원구분      
										,RETR_YN                           								    --퇴사구분  
										,NMLAST                           								    --성명  
										,COMPKY                             								  --회사코드     
										,EMPLID                             								  --사번   
										,DEPART                             								  --부서	
										,NATNKY                             								  --국가코드
										,EMAIL1                                               --EMAIL
                    ,LMODAT                                               --수정일자
                    ,LMOTIM                                               --수정시간
                    ,LMOUSR																		            --수정자
             )=
             (SELECT WORK_TYPE                													  --직원구분      
										,case when STATUS = 'T' then 'Y'
                          else 'N'                                         
                     end                     													  --퇴사구분 
										,EMP_NAME                													    --성명  
										--,TENANT_ID                   													--회사코드  
										,DECODE(TENANT_ID,'KNARA','KN',TENANT_ID) TENANT_ID      --회사코드		
										,EMP_NO                   													  --사번
										,DEPT_CODE                           								  --부서
										,COUNTRY_CODE                           							--국가코드
										,MAIL_ADDRESS                                         --EMAIL
                    ,TO_CHAR(sysdate,'YYYYMMDD')                         --수정일자
                    ,TO_CHAR(sysdate,'HH24MISS')                           --수정시간  
                    ,'SP_IF_GET_MAS017'                                       --수정자                                              
              FROM TB_IFR012
              WHERE  IF_SEQ =  ifr012.IF_SEQ
             )
             WHERE USERID = ifr012.MAIL_ID;              

      ELSE
             INSERT INTO USRMA 
             (       USERID											         								  --ID     
										,EMPLY_DIV                                 						--직원구분      
										,RETR_YN                           								    --퇴사구분  
										,NMLAST                           								    --성명  
										,COMPKY                             								  --회사코드     
										,EMPLID                             								  --사번   
										,DEPART                             								  --부서	
										,NATNKY                             								  --국가코드
										,EMAIL1                                               --EMAIL										
										,CREDAT                                               --등록일자
                    ,CRETIM                                               --등록시간
                    ,CREUSR                                               --등록자
                    ,LMODAT                                               --수정일자
                    ,LMOTIM                                               --수정시간
                    ,LMOUSR																		            --수정자
             )
             SELECT  MAIL_ID                      		                    --ID     
										,WORK_TYPE                													  --직원구분      
										,case when STATUS = 'T' then 'Y'
                          else 'N'                                         
                     end                     													  --퇴사구분 
										,EMP_NAME                													    --성명  
										--,TENANT_ID                   													--회사코드
                    ,DECODE(TENANT_ID,'KNARA','KN',TENANT_ID) TENANT_ID      --회사코드										  
										,EMP_NO                   													  --사번
										,DEPT_CODE                           								  --부서
										,COUNTRY_CODE                           							--국가코드
										,MAIL_ADDRESS                                         --EMAIL										
                    ,TO_CHAR(sysdate,'YYYYMMDD')                         --생성일자
                    ,TO_CHAR(sysdate,'HH24MISS')                           --생성일자                    
                    ,'SP_IF_GET_MAS017'                                       --생성자  
                    ,null                                                 --수정일자
                    ,null                                                 --수정시간	
                    ,null                                                 --수정자                    																																																	   
             FROM TB_IFR012           
             WHERE  IF_SEQ =  ifr012.IF_SEQ     
             ;

      END IF;      
    
      
      o_msg_msg  :=  '사원정보가 수신되었습니다.';

      UPDATE  TB_IFR012
      SET     RECV_FLAG   =  'S'                                                 --I/F상태, N:신규, S:성공, E:오류               
            , RECV_DATE =  sysdate                                              --데이터 처리시간(MES I/F 테이블 → MES 운영테이블) 
            , RECV_ERR_MSG =  o_msg_msg                                         --데이터 처리 결과 Message(Oracle)  
            , IF_MES_KEY =  i_IF_MES_KEY              
      WHERE  IF_SEQ  =  ifr012.IF_SEQ   ;
      

      o_msg_msg       := '사원정보가 수신되었습니다.';
      o_msg_code      := '0' ;

      COMMIT;

      EXCEPTION
            WHEN OTHERS THEN
                  o_msg_msg  :=  'SP_IF_GET_MAS017=>' || '사원정보 수신 중 오류가 발생하였습니다.' || ',' || SQLERRM ;
                  o_msg_code      := '-1' ;
                  DBMS_OUTPUT.PUT_LINE (o_msg_msg );
                  ROLLBACK;

                  UPDATE  TB_IFR012
                  SET     RECV_FLAG   =  'E'                                     --I/F상태, N:신규, S:성공, E:오류               
                        , RECV_DATE =  sysdate                                  --데이터 처리시간(MES I/F 테이블 → MES 운영테이블) 
                        , RECV_ERR_MSG =  o_msg_msg                             --데이터 처리 결과 Message(Oracle)       
                        , IF_MES_KEY =  i_IF_MES_KEY                                  
                  WHERE  IF_SEQ  =  ifr012.IF_SEQ   ;
                  Commit ;
      END;
    END LOOP;

    o_msg_msg       := '실행완료';
    o_msg_code      := '0' ;

    EXCEPTION
      WHEN OTHERS THEN
        o_msg_code      := '-1' ;
        o_msg_msg       := 'SP_IF_GET_MAS017=>' || '사원정보 수신 중 MAIN에서 오류가 발생하였습니다.' || ',' || to_char(SQLCODE) || ',' || SQLERRM ;
        DBMS_OUTPUT.PUT_LINE(o_msg_msg);
        rollback ;

  END; 
END SP_IF_GET_MAS017;

/
