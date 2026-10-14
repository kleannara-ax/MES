--------------------------------------------------------
--  DDL for Procedure SP_IF_PUT_IFSWC004
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_IF_PUT_IFSWC004" (
   i_IF_MES_ID        IN    VARCHAR2
  ,i_IF_MES_KEY       IN    VARCHAR2
  ,o_msg_code         OUT   VARCHAR2
  ,o_msg_msg          OUT   VARCHAR2
)
/*==============================================================================
 * PROGRAM ID    : 
 * PROGRAM NAME  : 인터페이스-밀롤(LOT/BARCODE) 생성 정보 (MES->WCS)
 * VERSION       : 1.0.0{최종 버전 기술}
 * DESCRIPTION   : 밀롤(LOT/BARCODE) 생성 정보 (MES->WCS)
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
 *       - [TB_IFSWC004]  : (.RU.) 밀롤(LOT/BARCODE) 생성 정보
 *=============================================================================*/
AS

  V_CNT       NUMBER        DEFAULT 0;
  V_IF_SEQ    NUMBER;  
  --V_SYS_DT    VARCHAR2(20)  DEFAULT TO_CHAR(sysdate,'YYYYMMDD');
  V_SYS_DT    VARCHAR2(20)  DEFAULT TO_CHAR(sysdate,'YYYYMMDDHH24MISS');
  
BEGIN
  DECLARE
    CURSOR  cur_list IS
      SELECT   DOC_NO													--문서번호                               
							,DOC_NOSEQ                    	--문서번호 순번   
							,CAST(SUBSTR(DOC_NO,-5) AS NUMBER) IF_SEQ--WCS KEY                         
							,IND_BCD                      	--밀롤바코드                              
							,LOT_NO                       	--MRLOT NO                           
							,JRLOT_NO                     	--JRLOTID                            
							,WERKS                        	--플랜트                                
							,MACH_NO                      	--호기 (외부 입고는 PO1)                    
							,PROC_CD                      	--공정(M)                              
							,FCLT_CD                      	--설비                                 
							,ORDER_NO                     	--생산 지시 번호                           
							,ORDER_NO_SEQ                 	--생산 지시 번호 SEQ                       
							,PRFM_DT                      	--생산일자, ERP 전기일(YYYYMMDD)            
							,PROD_SEQ                     	--일별 생산 순번                           
							,PROD_DT                      	--실제 작업 일자(YYYYMMDD)                 
							,WORK_GRP                     	--반                                  
							,SAT                          	--상태                                 
							,MTART                        	--ERP 자재코드                           
							,PCODE                        	--지종코드                               
							,PCODE_NM                     	--지종명                                
							,RELIMP                       	--평량                                 
							,STD_SIZE                     	--지시 규격 (가로 * 세로)                    
							,PAPER_BT                     	--지폭                                 
							,PAPER_BT_REAL                	--실지폭 (실폭)                           
							,WEIGHT                       	--중량(KG)                             
							,LENGTH                       	--권치수, 길이(M)                         
							,SHEET_YN                     	--판지/원지 구분                           
							,SLITTER_YN                   	--슬리터 구분 (슬리터 대상 밀롤)                 
							,PACKING_TP_NM                	--포장타입                               
							,JR_MCHN_CD                   	--J/R호기                              
							,MR_MCHN_CD                   	--M/R호기                              
							,CT_MCHN_CD                   	--C/T(슬리터)호기                         
							,WRKORD                       	--ERP 생산오더번호                         
							,SPECIAL_NO                   	--ERP 특별재고번호                         
							,BCNC_CD                      	--거래처코드                              
							,BCNC_NM                      	--거래처명                               
							,EXPORT_EXT                   	--일본향 수출코드                           
							,VOYAGE                       	--항차                                 
							,CNTRY_NM                     	--국가명                                
							,REAM_PER_PALLET              	--Ream/Pallet 팔렛당 연수                 
							,NMRS_IN_BUNDLE               	--속당매수(EA)                           
							,BUNDLE_CNT                   	--속수                                 
							,ZPPCOD                       	--바코드의 ERP 번호                        
							,CORE_SIZE                    	--지관(인치)                             
							,BT_SEQ                       	--지폭순번                               
							,USER_ID                      	--작업자ID                              
							,USER_NM                      	--작업자명                               
							,WORK_DRCT                    	--생산 작업 지시사항                         
							,PRD_RMK1                     	--생산 비고 (REMARK)                     
							,MR_STK_YN                    	--밀롤창고 적치 여부                         
							,PLAN_CT_NO                   	--투입할 Cutter 설비 코드 (생산 지시 기준)        
							,REPROD_YN                    	--취소 후 재실적 여부                        
							,PRE_BARCODE                  	--이전 바코드 번호                          
							,CRAT_DATE                    	--생성 일시                              
							,CRAT_ID                      	--생성 아이디                             
							,UPDT_DATE                    	--변경 일시                              
							,UPDT_ID                      	--변경 아이디                             
							,REMARK1                      	--비고1                                
							,REMARK2                      	--비고2                                
							,REMARK3                      	--비고3                                
							,REMARK4                      	--비고4                                
							,REMARK5                      	--비고5                                
							,REMARK6                      	--비고6                                
							,REMARK7                      	--비고7                                
							,REMARK8                      	--비고8                                
							,REMARK9                      	--비고9                                
							,REMARK10                     	--비고10                               
							,IF_STATUS                    	--WCS 결과값 Return( N: 대기, S:성공, E:오류 )
							,IF_GET_DATE                  	--MES 등록일시                           
							,IF_SET_DATE                  	--WCS 전송일시                           
							,IF_ERR_MESS                  	--WCS 결과 메시지                         
							,IF_MES_KEY                   	--MES Inserface Key(MES->WCS)         
      FROM    TB_IFSWC004
      WHERE   NVL(IF_STATUS,'N')  in  ( 'N' )           /*  I/F상태, N:신규, S:성공, E:오류            */
      --WHERE   NVL(IF_STATUS,'N')  in  ( 'N','E' )           /*  I/F상태, N:신규, S:성공, E:오류            */      
      ORDER BY DOC_NO, DOC_NOSEQ;


  BEGIN

    FOR ifrrow in cur_list loop
      BEGIN
      --데이타전송
       --YSH 20221002
       SELECT WCS_2.NEXTVAL INTO V_IF_SEQ FROM DUAL;
       INSERT INTO T_IF_PIS_MILLROLL_CREATE@LNK_WCS(
               IF_SEQ
							,BARCODE       																				--밀롤바코드                      
							,LOT_ID                                               --MRLOT NO                   
							,JR_LOT_ID                                            --JRLOTID                    
							,PLNT_CD                                              --플랜트                        
							,MCHN_CD                                              --호기 (외부 입고는 PO1)            
							,PRCS_CD                                              --공정(M)                      
							,FCLT_CD                                              --설비                         
							,PLAN_NO                                              --생산 지시 번호                   
							,PLAN_SEQ                                             --생산 지시 번호 SEQ               
							,WORK_DT                                              --생산일자, ERP 전기일(YYYYMMDD)    
							,ACTUAL_SEQ                                           --일별 생산 순번                   
							,MAKE_DT                                              --실제 작업 일자(YYYYMMDD)         
							,CLASS                                                --반                          
							,STATUS                                               --상태                         
							,MATERIAL_NO                                          --ERP 자재코드                   
							,PAPER_CD                                             --지종코드                       
							,PAPER_NM                                             --지종명                        
							,RELIMP                                               --평량                         
							,STD_SIZE                                             --지시 규격 (가로 * 세로)            
							,PAPER_BT                                             --지폭                         
							,PAPER_BT_REAL                                        --실지폭 (실폭)                   
							,WEIGHT                                               --중량(KG)                     
							,LENGTH                                               --권치수, 길이(M)                 
							,SHEET_YN                                             --판지/원지 구분                   
							,SLITTER_YN                                           --슬리터 구분 (슬리터 대상 밀롤)         
							,PACKING_TP_NM                                        --포장타입                       
							,JR_MCHN_CD                                           --J/R호기                      
							,MR_MCHN_CD                                           --M/R호기                      
							,CT_MCHN_CD                                           --C/T(슬리터)호기                 
							,WRKORD                                               --ERP 생산오더번호                 
							,SPECIAL_NO                                           --ERP 특별재고번호                 
							,BCNC_CD                                              --거래처코드                      
							,BCNC_NM                                              --거래처명                       
							,EXPORT_EXT                                           --일본향 수출코드                   
							,VOYAGE                                               --항차                         
							,CNTRY_NM                                             --국가명                        
							,REAM_PER_PALLET                                      --Ream/Pallet 팔렛당 연수         
							,NMRS_IN_BUNDLE                                       --속당매수(EA)                   
							,BUNDLE_CNT                                           --속수                         
							,ZPPCOD                                               --바코드의 ERP 번호                
							,CORE_SIZE                                            --지관(인치)                     
							,BT_SEQ                                               --지폭순번                       
							,USER_ID                                              --작업자ID                      
							,USER_NM                                              --작업자명                       
							,WORK_DRCT                                            --생산 작업 지시사항                 
							,PRD_RMK1                                             --생산 비고 (REMARK)             
							,MR_STK_YN                                            --밀롤창고 적치 여부                 
							,PLAN_CT_NO                                           --투입할 Cutter 설비 코드 (생산 지시 기준)
							,REPROD_YN                                            --취소 후 재실적 여부                
							,PRE_BARCODE                                          --이전 바코드 번호                                      
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
       				,ifrrow.IND_BCD            														--밀롤바코드          				                 
							,ifrrow.LOT_NO                                        --MRLOT NO                   
							,ifrrow.JRLOT_NO                                      --JRLOTID                    
							,ifrrow.WERKS                                         --플랜트                        
							,ifrrow.MACH_NO                                       --호기 (외부 입고는 PO1)            
							,ifrrow.PROC_CD                                       --공정(M)                      
							,ifrrow.FCLT_CD                                       --설비                         
							,ifrrow.ORDER_NO                                      --생산 지시 번호                   
							,ifrrow.ORDER_NO_SEQ                                  --생산 지시 번호 SEQ               
							,ifrrow.PRFM_DT                                       --생산일자, ERP 전기일(YYYYMMDD)    
							,ifrrow.PROD_SEQ                                      --일별 생산 순번                   
							,ifrrow.PROD_DT                                       --실제 작업 일자(YYYYMMDD)         
							,ifrrow.WORK_GRP                                      --반                          
							,ifrrow.SAT                                           --상태                         
							,ifrrow.MTART                                         --ERP 자재코드                   
							,ifrrow.PCODE                                         --지종코드                       
							,ifrrow.PCODE_NM                                      --지종명                        
							,ifrrow.RELIMP                                        --평량                         
							,ifrrow.STD_SIZE                                      --지시 규격 (가로 * 세로)            
							,ifrrow.PAPER_BT                                      --지폭                         
							,ifrrow.PAPER_BT_REAL                                 --실지폭 (실폭)                   
							,ifrrow.WEIGHT                                        --중량(KG)                     
							,ifrrow.LENGTH                                        --권치수, 길이(M)                 
							,ifrrow.SHEET_YN                                      --판지/원지 구분                   
							,ifrrow.SLITTER_YN                                    --슬리터 구분 (슬리터 대상 밀롤)         
							,ifrrow.PACKING_TP_NM                                 --포장타입                       
							,ifrrow.JR_MCHN_CD                                    --J/R호기                      
							,ifrrow.MR_MCHN_CD                                    --M/R호기                      
							,ifrrow.CT_MCHN_CD                                    --C/T(슬리터)호기                 
							,ifrrow.WRKORD                                        --ERP 생산오더번호                 
							,ifrrow.SPECIAL_NO                                    --ERP 특별재고번호                 
							,ifrrow.BCNC_CD                                       --거래처코드                      
							,ifrrow.BCNC_NM                                       --거래처명                       
							,ifrrow.EXPORT_EXT                                    --일본향 수출코드                   
							,ifrrow.VOYAGE                                        --항차                         
							,ifrrow.CNTRY_NM                                      --국가명                        
							,ifrrow.REAM_PER_PALLET                               --Ream/Pallet 팔렛당 연수         
							,ifrrow.NMRS_IN_BUNDLE                                --속당매수(EA)                   
							,ifrrow.BUNDLE_CNT                                    --속수                         
							,ifrrow.ZPPCOD                                        --바코드의 ERP 번호                
							,ifrrow.CORE_SIZE                                     --지관(인치)                     
							,ifrrow.BT_SEQ                                        --지폭순번                       
							,ifrrow.USER_ID                                       --작업자ID                      
							,ifrrow.USER_NM                                       --작업자명                       
							,ifrrow.WORK_DRCT                                     --생산 작업 지시사항                 
							,ifrrow.PRD_RMK1                                      --생산 비고 (REMARK)             
							,ifrrow.MR_STK_YN                                     --밀롤창고 적치 여부                 
							,ifrrow.PLAN_CT_NO                                    --투입할 Cutter 설비 코드 (생산 지시 기준)
							,ifrrow.REPROD_YN                                     --취소 후 재실적 여부                
							,ifrrow.PRE_BARCODE                                   --이전 바코드 번호                                       
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

              --,TO_DATE(V_SYS_DT,'YYYY-MM-DD')                        --생성일자
              ,TO_DATE(V_SYS_DT, 'YYYY-MM-DD HH24:MI:SS')
              ,'IFSWC004'                                             --생성자  
              ,null                                                 --수정일자
              ,null                                                 --수정자
      );
      COMMIT; --ODBC DBLINK일때는 건당 COMMIT을 해야한다.(Transaction 안됨)


      o_msg_msg  :=  '밀롤(LOT/BARCODE) 생성 정보 전송되었습니다.';

      UPDATE  TB_IFSWC004
      SET     IF_STATUS   =  'S'                                                 --I/F상태, N:신규, S:성공, E:오류               
            , IF_SET_DATE =  sysdate                                              --데이터 처리시간(MES I/F 테이블 → MES 운영테이블) 
            , IF_ERR_MESS =  o_msg_msg                                         --데이터 처리 결과 Message(Oracle)  
            , IF_MES_KEY  =  i_IF_MES_KEY              
      WHERE  DOC_NO  =  ifrrow.DOC_NO   
      AND  DOC_NOSEQ  =  ifrrow.DOC_NOSEQ;


      o_msg_msg       := '밀롤(LOT/BARCODE) 생성 정보 전송되었습니다.';
      o_msg_code      := '0' ;

      COMMIT;

      EXCEPTION
            WHEN OTHERS THEN
                  o_msg_msg  :=  'SP_IF_PUT_IFSWC004=>' || '밀롤(LOT/BARCODE) 생성 정보 전송 중 오류가 발생하였습니다.' || ',' || SQLERRM ;
                  o_msg_code      := '-1' ;
                  DBMS_OUTPUT.PUT_LINE (o_msg_msg );
                  ROLLBACK;


                  UPDATE  TB_IFSWC004
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
        o_msg_msg       := 'SP_IF_PUT_IFSWC004=>' || '밀롤(LOT/BARCODE) 생성 정보 전송 중 MAIN에서 오류가 발생하였습니다.' || ',' || to_char(SQLCODE) || ',' || SQLERRM ;
        DBMS_OUTPUT.PUT_LINE(o_msg_msg);
        rollback ;

  END; 
END SP_IF_PUT_IFSWC004;

/
