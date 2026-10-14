--------------------------------------------------------
--  DDL for Procedure SP_IF_PUT_IFSWC006
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_IF_PUT_IFSWC006" (
   i_IF_MES_ID        IN    VARCHAR2
  ,i_IF_MES_KEY       IN    VARCHAR2
  ,o_msg_code         OUT   VARCHAR2
  ,o_msg_msg          OUT   VARCHAR2
)
/*==============================================================================
 * PROGRAM ID    : 
 * PROGRAM NAME  : 인터페이스-밀롤 Picking 및 출고 지시 (CT 생산 오더) (MES->WCS)
 * VERSION       : 1.0.0{최종 버전 기술}
 * DESCRIPTION   : 밀롤 Picking 및 출고 지시 (CT 생산 오더) (MES->WCS)
 *                  
 *                  
 * AUTHOR NAME   : 강현주{최초 작성자 명 기술}
 * CREATE DATE   : 2022/06/29 {최초 작성일자 기술}
 * SYSTEM NAME   : MES->WCS
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}  <생략가능>
 * SUB PROCEDURE : {아휘 프로시저 명칭 기술}      <생략가능>
 * SUB PACKAGES  : {하위 패키지 기술}            <생략가능>
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술} <생략가능>
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/06/29    1.0.0   강현주         Initial Version 
 *==============================================================================
 *  관련 테이블    
 *       - [TB_IFSWC006]  : (.RU.) 밀롤 Picking 및 출고 지시 (CT 생산 오더)
 *=============================================================================*/
AS

  V_CNT       NUMBER        DEFAULT 0;
  V_IF_SEQ    NUMBER;
  V_SYS_DT    VARCHAR2(20)  DEFAULT TO_CHAR(sysdate,'YYYYMMDD');
BEGIN
  DECLARE
    CURSOR  cur_list IS
      SELECT   DOC_NO       								 --문서번호                             
							,DOC_NOSEQ    								 --문서번호 순번   
							,CAST(SUBSTR(DOC_NO,-5) AS NUMBER) IF_SEQ--WCS KEY    							                       
							,BARCODE      								 --밀롤바코드                            
							,LOT_ID       								 --MR LOTID                         
							,CT_LOT_ID    								 --CT LOTID - 필수항목아님                
							,PLNT_CD      								 --플랜트                              
							,MCHN_CD      								 --투입할 Cutter 호기(PM3)               
							,PRCS_CD      								 --공정(C)                            
							,FCLT_CD      								 --설비 (1커터 ~ 9 커터)                  
							,WORK_DT      								 --생산 계획일 (YYYYMMDD)                
							,WORK_TIME    								 --생산 계획 시간 (HHMM)                  
							,WORK_SEQ     								 --생산 계획 순번                         
							,CLASS        								 --반                                
							,MATERIAL_NO  								 --ERP 자재코드 (커터 자재코드)               
							,WEIGHT       								 --중량(KG)                           
							,LENGTH       								 --권치수, 길이(M)                       
							,WRKORD       								 --ERP 생산오더번호                       
							,SPECIAL_NO   								 --ERP 특별재고번호                       
							,USER_NM      								 --작업자명                             
							,WORK_DRCT    								 --생산 작업 지시사항                       
							,CRAT_DATE    								 --생성 일시                            
							,CRAT_ID      								 --생성 아이디                           
							,UPDT_DATE    								 --변경 일시                            
							,UPDT_ID      								 --변경 아이디                           
							,REMARK1      								 --비고1                              
							,REMARK2      								 --비고2                              
							,REMARK3      								 --비고3                              
							,REMARK4      								 --비고4                              
							,REMARK5      								 --비고5                              
							,REMARK6      								 --비고6                              
							,REMARK7      								 --비고7                              
							,REMARK8      								 --비고8                              
							,REMARK9      								 --비고9                              
							,REMARK10     								 --비고10                             
							,IF_STATUS    								 --WCS 결과값 Return( N:대기,S:성공, E:오류 )
							,IF_GET_DATE  								 --MES 등록일시                         
							,IF_SET_DATE  								 --WCS 전송일시                         
							,IF_ERR_MESS  								 --WCS 결과 메시지                       
							,IF_MES_KEY   								 --MES Inserface Key        
      FROM    TB_IFSWC006
      WHERE   NVL(IF_STATUS,'N')  in  ( 'N' )           /*  I/F상태, N:신규, S:성공, E:오류            */
      --WHERE   NVL(IF_STATUS,'N')  in  ( 'N','E' )           /*  I/F상태, N:신규, S:성공, E:오류            */      
      ORDER BY DOC_NO, DOC_NOSEQ;


  BEGIN
    FOR ifrrow in cur_list loop
      BEGIN
      --데이타전송
      --YSH 20221002
       SELECT WCS_4.NEXTVAL INTO V_IF_SEQ FROM DUAL;
       INSERT INTO T_IF_PIS_MR_ISSUE_ORD@LNK_WCS(
               IF_SEQ
							,BARCODE       																				--밀롤바코드          
							,LOT_ID                                               --MR LOTID          
							,CT_LOT_ID                                            --CT LOTID - 필수항목아님 
							,PLNT_CD                                              --플랜트               
							,MCHN_CD                                              --투입할 Cutter 호기(PM3)
							,PRCS_CD                                              --공정(C)             
							,FCLT_CD                                              --설비 (1커터 ~ 9 커터)   
							,WORK_DT                                              --생산 계획일 (YYYYMMDD) 
							,WORK_TIME                                            --생산 계획 시간 (HHMM)   
							,WORK_SEQ                                             --생산 계획 순번          
							,CLASS                                                --반                 
							,MATERIAL_NO                                          --ERP 자재코드 (커터 자재코드)
							,WEIGHT                                               --중량(KG)            
							,LENGTH                                               --권치수, 길이(M)        
							,WRKORD                                               --ERP 생산오더번호        
							,SPECIAL_NO                                           --ERP 특별재고번호        
							,USER_NM                                              --작업자명              
							,WORK_DRCT                                            --생산 작업 지시사항                    
							,REMARK1                                              --비고1               
							,REMARK2                                              --비고2               
							,REMARK3                                              --비고3               
							,REMARK4                                              --비고4               
							,REMARK5                                              --비고5               
							,REMARK6                                              --비고6               
							,REMARK7                                              --비고7               
							,REMARK8                                              --비고8               
							,REMARK9                                              --비고9               
							,REMARK10                                             --비고10     

							,CRAT_DATE                                            --생성 일시                      
							,CRAT_ID                                              --생성 아이디                     
							,UPDT_DATE                                            --변경 일시                      
							,UPDT_ID                                              --변경 아이디 	
       )VALUES(
               V_IF_SEQ            														--KEY      
         			,ifrrow.BARCODE																				--밀롤바코드             
							,ifrrow.LOT_ID                                        --MR LOTID          
							,ifrrow.CT_LOT_ID                                     --CT LOTID - 필수항목아님 
							,ifrrow.PLNT_CD                                       --플랜트               
							,ifrrow.MCHN_CD                                       --투입할 Cutter 호기(PM3)
							,ifrrow.PRCS_CD                                       --공정(C)             
							,ifrrow.FCLT_CD                                       --설비 (1커터 ~ 9 커터)   
							,ifrrow.WORK_DT                                       --생산 계획일 (YYYYMMDD) 
							,ifrrow.WORK_TIME                                     --생산 계획 시간 (HHMM)   
							,ifrrow.WORK_SEQ                                      --생산 계획 순번          
							,ifrrow.CLASS                                         --반                 
							,ifrrow.MATERIAL_NO                                   --ERP 자재코드 (커터 자재코드)
							,ifrrow.WEIGHT                                        --중량(KG)            
							,ifrrow.LENGTH                                        --권치수, 길이(M)        
							,ifrrow.WRKORD                                        --ERP 생산오더번호        
							,ifrrow.SPECIAL_NO                                    --ERP 특별재고번호        
							,ifrrow.USER_NM                                       --작업자명              
							,ifrrow.WORK_DRCT                                     --생산 작업 지시사항                    
							,ifrrow.REMARK1                                       --비고1               
							,ifrrow.REMARK2                                       --비고2               
							,ifrrow.REMARK3                                       --비고3               
							,ifrrow.REMARK4                                       --비고4               
							,ifrrow.REMARK5                                       --비고5               
							,ifrrow.REMARK6                                       --비고6               
							,ifrrow.REMARK7                                       --비고7               
							,ifrrow.REMARK8                                       --비고8               
							,ifrrow.REMARK9                                       --비고9               
							,ifrrow.REMARK10                                      --비고10

              ,TO_DATE(V_SYS_DT,'YYYY-MM-DD')                        --생성일자
              ,'IFSWC006'                                             --생성자  
              ,null                                                 --수정일자
              ,null                                                 --수정자
      );

      COMMIT;      

      o_msg_msg  :=  '밀롤 Picking 및 출고 지시 수신(CT 생산 오더) 정보 전송되었습니다.';

      UPDATE  TB_IFSWC006
      SET     IF_STATUS   =  'S'                                                 --I/F상태, N:신규, S:성공, E:오류               
            , IF_SET_DATE =  sysdate                                              --데이터 처리시간(MES I/F 테이블 → MES 운영테이블) 
            , IF_ERR_MESS =  o_msg_msg                                         --데이터 처리 결과 Message(Oracle)  
            , IF_MES_KEY  =  i_IF_MES_KEY              
      WHERE  DOC_NO  =  ifrrow.DOC_NO   
      AND  DOC_NOSEQ  =  ifrrow.DOC_NOSEQ;


      o_msg_msg       := '밀롤 Picking 및 출고 지시 수신(CT 생산 오더) 정보 전송되었습니다.';
      o_msg_code      := '0' ;

      COMMIT;

      EXCEPTION
            WHEN OTHERS THEN
                  o_msg_msg  :=  'SP_IF_PUT_IFSWC006=>' || '밀롤 Picking 및 출고 지시 수신(CT 생산 오더) 정보 전송 중 오류가 발생하였습니다.' || ',' || SQLERRM ;
                  o_msg_code      := '-1' ;
                  DBMS_OUTPUT.PUT_LINE (o_msg_msg );
                  ROLLBACK;


                  UPDATE  TB_IFSWC006
                  SET     IF_STATUS   =  'E'                                      --I/F상태, N:신규, S:성공, E:오류               
                        , IF_SET_DATE =  sysdate                                --데이터 처리시간(MES I/F 테이블 → MES 운영테이블) 
                        , IF_ERR_MESS =  o_msg_msg                              --데이터 처리 결과 Message(Oracle)  
                        , IF_MES_KEY  =  i_IF_MES_KEY              
                  WHERE  DOC_NO  =  ifrrow.DOC_NO   
                  AND  DOC_NOSEQ  =  ifrrow.DOC_NOSEQ;             

                  Commit ;
      END;
    END LOOP;

    o_msg_msg       := '실행완료';
    o_msg_code      := '0' ;

    EXCEPTION
      WHEN OTHERS THEN
        o_msg_code      := '-1' ;
        o_msg_msg       := 'SP_IF_PUT_IFSWC006=>' || '밀롤 Picking 및 출고 지시 수신(CT 생산 오더) 정보 전송 중 MAIN에서 오류가 발생하였습니다.' || ',' || to_char(SQLCODE) || ',' || SQLERRM ;
        DBMS_OUTPUT.PUT_LINE(o_msg_msg);
        rollback ;

  END; 
END SP_IF_PUT_IFSWC006;

/
