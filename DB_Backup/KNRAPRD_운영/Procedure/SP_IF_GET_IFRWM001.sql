--------------------------------------------------------
--  DDL for Procedure SP_IF_GET_IFRWM001
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_IF_GET_IFRWM001" (  
 i_IF_MES_ID        IN    VARCHAR2
,i_IF_MES_KEY       IN    VARCHAR2 
,o_msg_code         OUT   VARCHAR2
,o_msg_msg          OUT   VARCHAR2
) 
/*==============================================================================
 * PROGRAM ID    : 
 * PROGRAM NAME  : 인터페이스-WMS 품질검사 요청 정보(자재입고)
 * VERSION       : 1.0.0{최종 버전 기술}
 * DESCRIPTION   : WMS 품질검사 요청 정보(자재입고)
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
 *       - [TB_IFRWM001]  : (.RU.) 품질검사 요청 정보(자재입고)
 *=============================================================================*/


IS

  -- 사용자 에러 처리용 변수선언 영역
  E_EXCEPTION_USER  EXCEPTION; 
  V_FLAG      VARCHAR2(1)     DEFAULT ''; 
    
  V_CNT       NUMBER          DEFAULT 0;  
   
  
  
BEGIN
  DECLARE
    CURSOR  cur_ifrwm001 IS
      SELECT   IF_IFR_NO            				 --MES Interface Sequence(수신번호)   
							,ORDER_NO                      --오더번호                           
							,ORDER_SEQNO                   --오더순번                           
							,SUPY_CD                       --공급처                            
							,MATNR                         --품목코드                           
							,QTY                           --입고수량                           
							,UNIT                          --단위                             
							,VGBEL                         --참조번호 (WMS 문서번호)                
							,VGPOS                         --참조번호아이템 (WMS 문서아이템번호)          
							,STOK_KY                       --Stock key                      
							,STOR_LOC                      --저장위치(WMS 저장위치)                 
							,WERKS                         --플랜트                            
							,LOTA03                        --포장타입(PS)                       
							,LOTA04                        --호기                             
							,STCK_STA                      --재고상태 (00정상 30불용 05품질 50폐기 10보류)
							,LOTA07                        --주문번호(10)+아이템번호(6)MTO           
							,NTN_CD                        --국가코드                           
							,CRSPD_CD                      --거래처코드MTO                       
							,LOTA10                        --보류사유명                          
							,PRDC_DT                       --제조일자                           
							,RCVGDS_DT                     --입고일자(SAP 전기일자)                 
							,DSTBT_DDLIN                   --유통기한 (생리대,기저귀,물티슈)             
							,IND_BCD                       --개별바코드 (협력업체바코드)                
							,LOT_NO                        --LOT번호/SAP 배치번호                 
							,LOTA16                        --평량(PS)                         
							,LOTA17                        --컨테이너유형(PS)                     
							,LOTA18                        --       
							,LOTA19                        --       
							,LOTA20                        --       
							,LOT_NUM                       --WMS LOT속성코드                    
							,DLFL                          --삭제 지시자(검사요청)(C, D) 
      FROM    TB_IFRWM001
      WHERE   IF_STATUS  in  ( 'N','E' )           /*  I/F상태, N:신규, S:성공, E:오류            */
      AND IF_MES_KEY =  i_IF_MES_KEY            
      ORDER BY IF_GET_DATE;

    
  BEGIN
  
    o_msg_msg       := '실행완료';
    o_msg_code      := '0' ;  
  
    FOR ifrwm001 in cur_ifrwm001 loop
      BEGIN
      
            
      SELECT COUNT(ORDER_NO) INTO V_CNT 
      FROM TB_QLT001 
      WHERE VGBEL = ifrwm001.VGBEL 
      AND VGPOS = ifrwm001.VGPOS;

      IF V_CNT > 0 THEN
            --------------------------------------------------------------------------------
            --삭제가 들어왔을때 검사완료이면 ERROR리턴함.(KHJ:2022-07-22추가)
            -------------------------------------------------------------------------------- 
            SELECT NVL(INSP_YN,'N') INTO V_FLAG 
            FROM TB_QLT001 
            WHERE VGBEL = ifrwm001.VGBEL 
            AND VGPOS = ifrwm001.VGPOS; 
            
--            IF V_FLAG = 'Y' THEN
--              o_msg_msg       := '[검사완료 확인필요]=>삭제할수 없습니다.';
--              o_msg_code      := '-1' ;            
--              RAISE E_EXCEPTION_USER;            
--            END IF;            
      
             UPDATE TB_QLT001
             SET(    ORDER_NO                                            --오더번호
                    ,ORDER_SEQNO                                         --오더순번
                    ,SUPY_CD                  								           --공급처코드                          
										,MATNR                    								           --품목코드                           
										,RCVGDS_QTY               								           --입고수량                           
										,UNIT                     								           --단위                                                      
										,STOR_KY                  								           --저장키                            
										,STOR_LOC_CD              								           --저장위치                           
										,WERKS                    								           --플랜트                            
										,STCK_STA                 								           --재고상태 (00정상 30불용 05품질 50폐기 10보류)
										,NTN_CD                   								           --국가코드                           
										,CRSPD_CD                 								           --거래처코드                          
										,PRDC_DT                  								           --제조일자(YYYY-MM-DD)               
										,RCVGDS_DT                								           --입고일자(YYYY-MM-DD)               
										,DSTBT_DDLIN              								           --유통기한(YYYY-MM-DD)               
										,IND_BCD                  								           --공급업체바코드/개별바코드                  
										,VND_LOT_NO               								           --업체LOT번호
                    ,DLFL                                                --삭제지시자(20220722)
     										    
                    ,UPDDATE                                              --수정일자
                    ,UPDID                                                --수정자
             )=
             (SELECT ORDER_NO                                             --오더번호
                    ,ORDER_SEQNO                                          --오더순번
                    ,SUPY_CD               																--공급처코드                          
										,MATNR                 																--품목코드                           
										,QTY                   																--입고수량                           
										,UNIT                  																--단위                                                      
										,STOK_KY               																--저장키                            
										,STOR_LOC              																--저장위치                           
										,WERKS                 																--플랜트                            
										,STCK_STA              																--재고상태 (00정상 30불용 05품질 50폐기 10보류)
										,NTN_CD                																--국가코드                           
										,CRSPD_CD              																--거래처코드                          
										,PRDC_DT               																--제조일자(YYYY-MM-DD)               
										,RCVGDS_DT             																--입고일자(YYYY-MM-DD)               
										,DSTBT_DDLIN           																--유통기한(YYYY-MM-DD)               
										,IND_BCD               																--공급업체바코드/개별바코드                  
										,LOT_NO                																--업체LOT번호 
										,DLFL                                                 --삭제지시자       
										    
                    ,sysdate                      												--수정일자
                    ,'IFRWM001'                  										        --수정자
              FROM TB_IFRWM001
              WHERE  IF_IFR_NO =  ifrwm001.IF_IFR_NO
             )
             WHERE VGBEL = ifrwm001.VGBEL
             AND VGPOS = ifrwm001.VGPOS;              

      ELSE
             INSERT INTO TB_QLT001 
             (       ORDER_NO                 								           --오더번호                           
										,ORDER_SEQNO              								           --오더순번                           
										,SUPY_CD                  								           --공급처코드                          
										,MATNR                    								           --품목코드                           
										,RCVGDS_QTY               								           --입고수량                           
										,UNIT                     								           --단위                             
										,VGBEL                    								           --문서번호                           
										,VGPOS                    								           --문서아이템                          
										,STOR_KY                  								           --저장키                            
										,STOR_LOC_CD              								           --저장위치                           
										,WERKS                    								           --플랜트                            
										,STCK_STA                 								           --재고상태 (00정상 30불용 05품질 50폐기 10보류)
										,NTN_CD                   								           --국가코드                           
										,CRSPD_CD                 								           --거래처코드                          
										,PRDC_DT                  								           --제조일자(YYYY-MM-DD)               
										,RCVGDS_DT                								           --입고일자(YYYY-MM-DD)               
										,DSTBT_DDLIN              								           --유통기한(YYYY-MM-DD)               
										,IND_BCD                  								           --공급업체바코드/개별바코드                  
										,VND_LOT_NO               								           --업체LOT번호
										,REQ_DIV                                             --요청구분(01:국내자재, 02:수입자재, 03:반품입고)
										,REQ_DATE                                            --요청일시
										,REQ_ID                                              --요청자
										,INSP_YN                                             --검사여부(Y/N)
										,LOT_NUM                                             --WMS LOT속성코드
                    ,DLFL  --삭제지시자(20220722)
										
                    ,REGDATE                       			                  --등록일자
                    ,REGID                         			                  --등록자
                    ,UPDDATE                       			                  --수정일자
                    ,UPDID                         			                  --수정자
             )
             SELECT  ORDER_NO              																--오더번호                           
										,ORDER_SEQNO           																--오더순번                           
										,SUPY_CD               																--공급처코드                          
										,MATNR                 																--품목코드                           
										,QTY                   																--입고수량                           
										,UNIT                  																--단위                             
										,VGBEL                 																--문서번호                           
										,VGPOS                 																--문서아이템                          
										,STOK_KY               																--저장키                            
										,STOR_LOC              																--저장위치                           
										,WERKS                 																--플랜트                            
										,STCK_STA              																--재고상태 (00정상 30불용 05품질 50폐기 10보류)
										,NTN_CD                																--국가코드                           
										,CRSPD_CD              																--거래처코드                          
										,PRDC_DT               																--제조일자(YYYY-MM-DD)               
										,RCVGDS_DT             																--입고일자(YYYY-MM-DD)               
										,DSTBT_DDLIN           																--유통기한(YYYY-MM-DD)               
										,IND_BCD               																--공급업체바코드/개별바코드                  
										,LOT_NO                																--업체LOT번호
										,'02'                                                   --요청구분(01:국내자재, 02:수입자재, 03:반품입고)
										,sysdate                                              --요청일시  
										,'IFRWM001'                                             --요청자 
										,'N'                                                   --검사여부(Y/N)
										,LOT_NUM                                              --WMS LOT속성코드
                    ,DLFL
										
                    ,sysdate                                              --생성일자
                    ,'IFRWM001'                                             --생성자  
                    ,null                                                 --수정일자
                    ,null                                                 --수정자
             FROM TB_IFRWM001           
             WHERE  IF_IFR_NO =  ifrwm001.IF_IFR_NO     
             ;

      END IF;
    
      
      o_msg_msg  :=  '품질검사 요청 정보(자재입고)가 수신되었습니다.';

      UPDATE  TB_IFRWM001
      SET     IF_STATUS   =  'S'                                                 --I/F상태, N:신규, S:성공, E:오류               
            , IF_SET_DATE =  sysdate                                            --데이터 처리시간(MES I/F 테이블 → MES 운영테이블) 
            , IF_ERR_MESS =  o_msg_msg                                          --데이터 처리 결과 Message(Oracle)                 
      WHERE  IF_IFR_NO =  ifrwm001.IF_IFR_NO   ;
      

      o_msg_msg       := '품질검사 요청 정보(자재입고)가 수신되었습니다.';
      o_msg_code      := '0' ;

      EXCEPTION
            WHEN E_EXCEPTION_USER THEN
                  DBMS_OUTPUT.PUT_LINE(o_msg_msg);
                  ROLLBACK;

                  UPDATE  TB_IFRWM001
                  SET     IF_STATUS   =  'E'                                      --I/F상태, N:신규, S:성공, E:오류               
                        , IF_SET_DATE =  sysdate                                --데이터 처리시간(MES I/F 테이블 → MES 운영테이블) 
                        , IF_ERR_MESS =  o_msg_msg                              --데이터 처리 결과 Message(Oracle)                                  
                  WHERE  IF_IFR_NO =  ifrwm001.IF_IFR_NO   ;
                  Commit ;
                  
                  RETURN;
              
            WHEN OTHERS THEN
                  o_msg_msg  :=  'SP_IF_GET_IFRWM001=>' || '품질검사 요청 정보(자재입고) 수신 중 오류가 발생하였습니다.' || ',' || SQLERRM ;
                  o_msg_code      := '-1' ;
                  DBMS_OUTPUT.PUT_LINE (o_msg_msg );
                  ROLLBACK;

                  UPDATE  TB_IFRWM001
                  SET     IF_STATUS   =  'E'                                      --I/F상태, N:신규, S:성공, E:오류               
                        , IF_SET_DATE =  sysdate                                --데이터 처리시간(MES I/F 테이블 → MES 운영테이블) 
                        , IF_ERR_MESS =  o_msg_msg                              --데이터 처리 결과 Message(Oracle)                                   
                  WHERE  IF_IFR_NO =  ifrwm001.IF_IFR_NO   ;
                  Commit ;
                  
                  RETURN;
      END;
    END LOOP;

    IF o_msg_code = 0 THEN
      commit;
    END IF;


    EXCEPTION            
      WHEN OTHERS THEN
        IF o_msg_code = 0 THEN
          o_msg_code      := '-1' ;
          o_msg_msg       := 'SP_IF_GET_IFRWM001=>' || '품질검사 요청 정보(자재입고) 수신 중 MAIN에서 오류가 발생하였습니다.' || ',' || to_char(SQLCODE) || ',' || SQLERRM ;
          DBMS_OUTPUT.PUT_LINE(o_msg_msg);
          rollback ;
        END IF;
                

  END; 
END SP_IF_GET_IFRWM001;

/
