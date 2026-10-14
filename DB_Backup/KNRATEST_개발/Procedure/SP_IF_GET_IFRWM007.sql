--------------------------------------------------------
--  DDL for Procedure SP_IF_GET_IFRWM007
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_IF_GET_IFRWM007" (  
 i_IF_MES_ID        IN    VARCHAR2
,i_IF_MES_KEY       IN    VARCHAR2  
,o_msg_code         OUT   VARCHAR2
,o_msg_msg          OUT   VARCHAR2
) 
/*==============================================================================
 * PROGRAM ID    : 
 * PROGRAM NAME  : 인터페이스-출하반품 검사요청 정보
 * VERSION       : 1.0.0{최종 버전 기술}
 * DESCRIPTION   : 출하반품 검사요청 정보
 *                  
 *                  
 * AUTHOR NAME   : 강현주{최초 작성자 명 기술}
 * CREATE DATE   : 2022/07/29 {최초 작성일자 기술}
 * SYSTEM NAME   : MES
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}  <생략가능>
 * SUB PROCEDURE : {아휘 프로시저 명칭 기술}      <생략가능>
 * SUB PACKAGES  : {하위 패키지 기술}            <생략가능>
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술} <생략가능>
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/07/29    1.0.0   강현주         Initial Version 
 *==============================================================================
 *  관련 테이블    
 *       - [TB_IFRWM007]  : (.RU.) 출하반품 검사요청 정보
 *=============================================================================*/
IS
  V_CNT   NUMBER  DEFAULT 0;
BEGIN
  DECLARE
    CURSOR  cur_ifrwm007 IS
      SELECT   IF_IFR_NO            				--MES Interface Sequence(수신번호)   
							,VGBEL      						 			--문서번호                           		
							,VGPOS                   			--문서아이템                          
							,ORDER_NO                			--오더번호                           
							,ORDER_SEQNO             			--오더순번                           
							,SUPY_CD                 			--공급처코드                          
							,MATNR                   			--품목코드                           
							,QTY                     			--입고수량                           
							,UNIT                    			--단위                             
							,STOK_KY                 			--저장키                            
							,STOR_LOC                			--저장위치                           
							,WERKS                   			--플랜트                                         
							,STCK_STA                			--재고상태 (00정상 30불용 05품질 50폐기 10보류)             
							,NTN_CD                  			--국가코드                           
							,CRSPD_CD                			--거래처코드                          
							,PRDC_DT                 			--제조일자(YYYY-MM-DD)               
							,RCVGDS_DT               			--입고일자(YYYY-MM-DD)               
							,DSTBT_DDLIN             			--유통기한(YYYY-MM-DD)               
							,IND_BCD                 			--공급업체바코드/개별바코드                  
							,LOT_NO                  			--업체LOT번호  	
							,LOT_NUM                       --WMS LOT속성코드    			
                            ,DLFL --삭제지시자
      FROM    TB_IFRWM007
      WHERE   IF_STATUS  in  ( 'N','E' )           /*  I/F상태, N:신규, S:성공, E:오류            */
      AND IF_MES_KEY =  i_IF_MES_KEY       
      ORDER BY IF_GET_DATE;

    
  BEGIN
    FOR ifrwm007 in cur_ifrwm007 loop
      BEGIN
      
      SELECT COUNT(ORDER_NO) INTO V_CNT 
      FROM TB_QLT001 
      WHERE VGBEL = ifrwm007.VGBEL 
      AND VGPOS = ifrwm007.VGPOS;

      IF V_CNT > 0 THEN
             UPDATE TB_QLT001
             SET(    ORDER_NO                     					             --오더번호                           
										,ORDER_SEQNO                  					             --오더순번                           
										,SUPY_CD                      					             --공급처코드                          
										,MATNR                        					             --품목코드                           
										,RCVGDS_QTY                   					             --입고수량                           
										,UNIT                         					             --단위                             
										,STOR_KY                      					             --저장키                            
										,STOR_LOC_CD                  					             --저장위치                           
										,WERKS                        					             --플랜트                                         
										,STCK_STA                     					             --재고상태 (00정상 30불용 05품질 50폐기 10보류)             
										,NTN_CD                       					             --국가코드                           
										,CRSPD_CD                     					             --거래처코드                          
										,PRDC_DT                      					             --제조일자(YYYY-MM-DD)               
										,RCVGDS_DT                    					             --입고일자(YYYY-MM-DD)               
										,DSTBT_DDLIN                  					             --유통기한(YYYY-MM-DD)               
										,IND_BCD                      					             --공급업체바코드/개별바코드                  
										,VND_LOT_NO                   					             --업체LOT번호
                                        ,DLFL  --삭제지시자
     										    
                    ,UPDDATE                                              --수정일자
                    ,UPDID                                                --수정자
             )=
             (SELECT ORDER_NO                															--오더번호                           
										,ORDER_SEQNO             															--오더순번                           
										--,SUPY_CD                 															--공급처코드    
                    ,case when  LENGTH(SUPY_CD) > 0 then SUBSTR(SUPY_CD,1,4) else '' end --공급처코드 										                      
										,MATNR                   															--품목코드                           
										,QTY                     															--입고수량                           
										,UNIT                    															--단위                             
										,STOK_KY                 															--저장키                            
										,STOR_LOC                															--저장위치                           
										,WERKS                   															--플랜트                                         
										,STCK_STA                															--재고상태 (00정상 30불용 05품질 50폐기 10보류)             
										,NTN_CD                  															--국가코드                           
										,CRSPD_CD                															--거래처코드                          
										,PRDC_DT                 															--제조일자(YYYY-MM-DD)               
										,RCVGDS_DT               															--입고일자(YYYY-MM-DD)               
										,DSTBT_DDLIN             															--유통기한(YYYY-MM-DD)               
										,IND_BCD                 															--공급업체바코드/개별바코드                  
										,LOT_NO                  															--업체LOT번호
                                        ,DLFL    -- 삭제지시자
										           
                    ,sysdate                      												--수정일자
                    ,'IFRWM007'                  										--수정자
              FROM TB_IFRWM007
              WHERE  IF_IFR_NO =  ifrwm007.IF_IFR_NO
             )
             WHERE VGBEL = ifrwm007.VGBEL
             AND VGPOS = ifrwm007.VGPOS;              

      ELSE
             INSERT INTO TB_QLT001 
             (       VGBEL																							 --문서번호                           		
										,VGPOS                        					             --문서아이템                          
										,ORDER_NO                     					             --오더번호                           
										,ORDER_SEQNO                  					             --오더순번                           
										,SUPY_CD                      					             --공급처코드                          
										,MATNR                        					             --품목코드                           
										,RCVGDS_QTY                   					             --입고수량                           
										,UNIT                         					             --단위                             
										,STOR_KY                      					             --저장키                            
										,STOR_LOC_CD                  					             --저장위치                           
										,WERKS                        					             --플랜트                                         
										,STCK_STA                     					             --재고상태 (00정상 30불용 05품질 50폐기 10보류)             
										,NTN_CD                       					             --국가코드                           
										,CRSPD_CD                     					             --거래처코드                          
										,PRDC_DT                      					             --제조일자(YYYY-MM-DD)               
										,RCVGDS_DT                    					             --입고일자(YYYY-MM-DD)               
										,DSTBT_DDLIN                  					             --유통기한(YYYY-MM-DD)               
										,IND_BCD                      					             --공급업체바코드/개별바코드                  
										,VND_LOT_NO                   					             --업체LOT번호  
										,REQ_DIV                                             --요청구분(01:국내자재, 02:수입자재, 03:반품입고)
										,REQ_DATE                                            --요청일시
										,REQ_ID                                              --요청자	
										,INSP_YN                                             --검사여부(Y/N)	
										,LOT_NUM                                             --WMS LOT속성코드																												  
										,DLFL  --삭제지시자
                    ,REGDATE                       			                  --등록일자
                    ,REGID                         			                  --등록자
                    ,UPDDATE                       			                  --수정일자
                    ,UPDID                         			                  --수정자
             )
             SELECT  VGBEL      						 															--문서번호                           		
										,VGPOS                   															--문서아이템                          
										,ORDER_NO                															--오더번호                           
										,ORDER_SEQNO             															--오더순번                           
										--,SUPY_CD                 															--공급처코드
                    ,case when  LENGTH(SUPY_CD) > 0 then SUBSTR(SUPY_CD,1,4) else '' end --공급처코드 											                          
										,MATNR                   															--품목코드                           
										,QTY                     															--입고수량                           
										,UNIT                    															--단위                             
										,STOK_KY                 															--저장키                            
										,STOR_LOC                															--저장위치                           
										,WERKS                   															--플랜트                                         
										,STCK_STA                															--재고상태 (00정상 30불용 05품질 50폐기 10보류)             
										,NTN_CD                  															--국가코드                           
										,CRSPD_CD                															--거래처코드                          
										,PRDC_DT                 															--제조일자(YYYY-MM-DD)               
										,RCVGDS_DT               															--입고일자(YYYY-MM-DD)               
										,DSTBT_DDLIN             															--유통기한(YYYY-MM-DD)               
										,IND_BCD                 															--공급업체바코드/개별바코드                  
										,LOT_NO                  															--업체LOT번호
										,'03'                                                   --요청구분(01:국내자재, 02:수입자재, 03:반품입고)
										,sysdate                                              --요청일시
										,'IFRWM007'                                             --요청자 
										,'N'                                                   --검사여부(Y/N)	
										,LOT_NUM                                             --WMS LOT속성코드																													
										,DLFL   --삭제지시자
                    ,sysdate                                              --생성일자
                    ,'IFRWM007'                                             --생성자  
                    ,null                                                 --수정일자
                    ,null                                                 --수정자
             FROM TB_IFRWM007           
             WHERE  IF_IFR_NO =  ifrwm007.IF_IFR_NO     
             ;

      END IF;
    
      
      o_msg_msg  :=  '출하반품 검사요청 정보가 수신되었습니다.';

      UPDATE  TB_IFRWM007
      SET     IF_STATUS   =  'S'                                                 --I/F상태, N:신규, S:성공, E:오류               
            , IF_SET_DATE =  sysdate                                            --데이터 처리시간(MES I/F 테이블 → MES 운영테이블) 
            , IF_ERR_MESS =  o_msg_msg                                          --데이터 처리 결과 Message(Oracle) 
            --, IF_MES_KEY =  i_IF_MES_KEY                          
      WHERE  IF_IFR_NO =  ifrwm007.IF_IFR_NO   ;
      

      o_msg_msg       := '출하반품 검사요청 정보가 수신되었습니다.';
      o_msg_code      := '0' ;

      COMMIT;

      EXCEPTION
            WHEN OTHERS THEN
                  o_msg_msg  :=  'SP_IF_GET_IFRWM007=>' || '출하반품 검사요청 정보 수신 중 오류가 발생하였습니다.' || ',' || SQLERRM ;
                  o_msg_code      := '-1' ;
                  DBMS_OUTPUT.PUT_LINE (o_msg_msg );
                  ROLLBACK;

                  UPDATE  TB_IFRWM007
                  SET     IF_STATUS   =  'E'                                      --I/F상태, N:신규, S:성공, E:오류               
                        , IF_SET_DATE =  sysdate                                --데이터 처리시간(MES I/F 테이블 → MES 운영테이블) 
                        , IF_ERR_MESS =  o_msg_msg                              --데이터 처리 결과 Message(Oracle)  
                        --, IF_MES_KEY =  i_IF_MES_KEY                                     
                  WHERE  IF_IFR_NO =  ifrwm007.IF_IFR_NO   ;
                  Commit ;
      END;
    END LOOP;

    o_msg_msg       := '실행완료';
    o_msg_code      := '0' ;

    EXCEPTION
      WHEN OTHERS THEN
        o_msg_code      := '-1' ;
        o_msg_msg       := 'SP_IF_GET_IFRWM007=>' || '출하반품 검사요청 정보 수신 중 MAIN에서 오류가 발생하였습니다.' || ',' || to_char(SQLCODE) || ',' || SQLERRM ;
        DBMS_OUTPUT.PUT_LINE(o_msg_msg);
        rollback ;

  END; 
END SP_IF_GET_IFRWM007;

/
