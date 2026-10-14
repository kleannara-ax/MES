--------------------------------------------------------
--  DDL for Procedure SP_IF_GET_IFRWM008
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_IF_GET_IFRWM008" (  
 i_IF_MES_ID        IN    VARCHAR2
,i_IF_MES_KEY       IN    VARCHAR2  
,o_msg_code         OUT   VARCHAR2
,o_msg_msg          OUT   VARCHAR2
) 
/*==============================================================================
 * PROGRAM ID    : 
 * PROGRAM NAME  : 인터페이스-직불출
 * VERSION       : 1.0.0{최종 버전 기술}
 * DESCRIPTION   : 직불출
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
 *       - [TB_IFRWM008]  : (.RU.) 직불출
 *=============================================================================*/
IS
  -- 사용자 에러 처리용 변수선언 영역
  E_EXCEPTION_USER  EXCEPTION; 
  V_FLAG      VARCHAR2(10)     DEFAULT ''; 

  V_CNT     NUMBER  DEFAULT 0;
  V_LIFT_DT VARCHAR2(100) DEFAULT '';

  V_STD_UNIT  VARCHAR2(10);
  V_STD_QTY   NUMBER; 

  V_PLT_QTY     NUMBER        DEFAULT 0; 
  V_BOX_QTY     NUMBER        DEFAULT 0; 
  V_BAG_QTY     NUMBER        DEFAULT 0; 
  V_EA_QTY      NUMBER        DEFAULT 0; 
  V_ROLLCNT_QTY NUMBER        DEFAULT 0; 
  V_WGT_QTY     NUMBER        DEFAULT 0;  
  V_STCK_QTY    TB_INV001.STCK_QTY%TYPE;

  V_MATNR_DIV VARCHAR2(10);
  V_CHK_DATA  VARCHAR2(100);    
BEGIN
  DECLARE
    CURSOR  CUR_IFRWM008 IS
      SELECT   IF_IFR_NO                    --MES Interface Sequence(수신번호)  
							,VGBEL                        --참조번호 (MES 문서번호)         
							,VGPOS                        --참조번호아이템 (MES 문서아이템번호)
							,DLFL                         --삭제 지시자(불출요청)  							 
							,STOR_LOC_TO                  --저장위치(공정창고) TO  
							,STOR_LOC_FROM                --저장위치 FROM 							                
							,MATNR                        --품목코드                           
							,UNIT                         --단위                                                               
							,QTY                          --불출량                            
							,LOTA01                       --저장위치                           
							,LOTA02                       --플랜트                            
							,LOTA03                       --포장타입(PS)                       
							,LOTA04                       --호기                             
							,LOTA05                       --            
							,STCK_STA                     --재고상태 (00정상 30불용 05품질 50폐기 10보류)
							,LOTA07                       --주문번호(10)+아이템번호(6)MTO           
							,NTN_CD                       --국가코드                           
							,CRSPD_CD                     --거래처코드MTO                       
							,LOTA10                       --보류사유명                          
							,PRDC_DT                      --제조일자                           
							,RCVGDS_DT                    --입고일자                           
							,DSTBT_DDLIN                  --유통기한 (생리대,기저귀,물티슈)             
							,IND_BCD                      --개별바코드 (협력업체바코드)                
							,LOT_NO                       --LOT번호                          
							,LOTA16                       --평량(PS)                         
							,LOTA17                       --컨테이너유형(PS)                     
							,LOTA18                       --            
							,LOTA19                       --            
							,LOTA20                       --            
							,STOK_KY                      --Stock key                      
							,LOT_NUM                      --WMS LOT속성코드
							,DOC_NO                       --오더번호							
							,DOC_SEQNO                    --오더아이템순번	
							,WERKS                        --플랜트								
							,PTNRKY 											--공급업체 코드        
							,CONTNO                       --컨테이너 No        
							,BARCNO                       --BARCODE No     
							,ZFBLNO                       --B/L 관리번호       
							,ROLLID                       --ROLL ID        
							,MRGSM                        --GSM - MR지폭     
							,LENGTH                       --길이 - MR권치수     
							,NETWT                        --Net Weight_중량  
							,WGTMUL                       --중량배수           
							,COREDI                       --코어(Inch) - 지관인치
							,KUNIT                        --롤당 중량단위        
							,CPCOD                        --고객지종           
							,TBRGEW                       --M/ROLL 중량      
							,RBRGEW                       --M/ROLL 중량      
							,LUNIT                        --Length 단위      
							,DESCRI                       --업체지종(SAP 지종)   
							,WEIGHT                       --평량             
							,RMK1                         --Remark1        
							,RMK2                         --Remark2        
							,RMK3                         --Remark3        
							,RMK4                         --Remark4        
							,RMK5                         --Remark5	
							,IN_DT	                      --입고전기일
							,STO_DOC_NO                   --STO문서번호																		
      FROM    TB_IFRWM008
      WHERE   IF_STATUS  in  ( 'N','E' )           /*  I/F상태, N:신규, S:성공, E:오류            */
      AND IF_MES_KEY =  i_IF_MES_KEY        
      ORDER BY IF_GET_DATE;


  BEGIN

    o_msg_msg       := '실행완료';
    o_msg_code      := '0' ;    

    FOR IFRWM008 in CUR_IFRWM008 loop
      BEGIN

      --<<***************************************************************************************************************>>
      --필수칼럼체크 추가 22-08-31.. 공백1자리일때 TRIM하면 null이 된다.
      --<<***************************************************************************************************************>>      
      SELECT DECODE(TRIM(IFRWM008.WERKS),null,'X',IFRWM008.WERKS) INTO V_CHK_DATA FROM DUAL;
      IF V_CHK_DATA = 'X' THEN
        o_msg_msg       := '[데이타 확인필요]=>WERKS';
        o_msg_code      := '-1';            
        RAISE E_EXCEPTION_USER;            
      END IF; 

/*
      SELECT DECODE(TRIM(IFRWM008.DOC_NO),null,'X',IFRWM008.DOC_NO) INTO V_CHK_DATA FROM DUAL;              
      IF V_CHK_DATA = 'X' THEN
        o_msg_msg       := '[데이타 확인필요]=>DOC_NO';
        o_msg_code      := '-1';            
        RAISE E_EXCEPTION_USER;            
      END IF;


      SELECT DECODE(TRIM(IFRWM008.DOC_SEQ),null,'X',IFRWM008.DOC_SEQ) INTO V_CHK_DATA FROM DUAL;      
      IF V_CHK_DATA = 'X' THEN
        o_msg_msg       := '[데이타 확인필요]=>DOC_SEQ';
        o_msg_code      := '-1';            
        RAISE E_EXCEPTION_USER;            
      END IF; 
*/          

      SELECT DECODE(TRIM(IFRWM008.STOR_LOC_TO),null,'X',IFRWM008.STOR_LOC_TO) INTO V_CHK_DATA FROM DUAL;       
      IF V_CHK_DATA = 'X' THEN
        o_msg_msg       := '[데이타 확인필요]=>STOR_LOC_TO';
        o_msg_code      := '-1';            
        RAISE E_EXCEPTION_USER;            
      END IF;  


      SELECT DECODE(TRIM(IFRWM008.VGBEL),null,'X',IFRWM008.VGBEL) INTO V_CHK_DATA FROM DUAL;      
      IF V_CHK_DATA = 'X' THEN
        o_msg_msg       := '[데이타 확인필요]=>VGBEL';
        o_msg_code      := '-1';            
        RAISE E_EXCEPTION_USER;            
      END IF; 

      SELECT DECODE(TRIM(IFRWM008.VGPOS),null,'X',IFRWM008.VGPOS) INTO V_CHK_DATA FROM DUAL;        
      IF V_CHK_DATA = 'X' THEN
        o_msg_msg       := '[데이타 확인필요]=>VGPOS';
        o_msg_code      := '-1';            
        RAISE E_EXCEPTION_USER;            
      END IF;

      SELECT DECODE(TRIM(IFRWM008.MATNR),null,'X',IFRWM008.MATNR) INTO V_CHK_DATA FROM DUAL;         
      IF V_CHK_DATA = 'X' THEN
        o_msg_msg       := '[데이타 확인필요]=>MATNR';
        o_msg_code      := '-1';            
        RAISE E_EXCEPTION_USER;            
      END IF;       

      SELECT DECODE(TRIM(IFRWM008.UNIT),null,'X',IFRWM008.UNIT) INTO V_CHK_DATA FROM DUAL;       
      IF V_CHK_DATA = 'X' THEN
        o_msg_msg       := '[데이타 확인필요]=>UNIT';
        o_msg_code      := '-1';            
        RAISE E_EXCEPTION_USER;            
      END IF;

      SELECT DECODE(TRIM(IFRWM008.IND_BCD),null,'X',IFRWM008.IND_BCD) INTO V_CHK_DATA FROM DUAL;     
      IF V_CHK_DATA = 'X' THEN
        o_msg_msg       := '[데이타 확인필요]=>IND_BCD';
        o_msg_code      := '-1';            
        RAISE E_EXCEPTION_USER;            
      END IF;  

      SELECT DECODE(TRIM(IFRWM008.STOK_KY),null,'X',IFRWM008.STOK_KY) INTO V_CHK_DATA FROM DUAL;       
      IF V_CHK_DATA = 'X' THEN
        o_msg_msg       := '[데이타 확인필요]=>STOK_KY';
        o_msg_code      := '-1';            
        RAISE E_EXCEPTION_USER;            
      END IF; 

      SELECT DECODE(TRIM(IFRWM008.LOT_NUM),null,'X',IFRWM008.LOT_NUM) INTO V_CHK_DATA FROM DUAL;       
      IF V_CHK_DATA = 'X' THEN
        o_msg_msg       := '[데이타 확인필요]=>LOT_NUM';
        o_msg_code      := '-1';            
        RAISE E_EXCEPTION_USER;            
      END IF;  

      SELECT DECODE(TRIM(IFRWM008.STCK_STA),null,'X',IFRWM008.STCK_STA) INTO V_CHK_DATA FROM DUAL;        
      IF V_CHK_DATA = 'X' THEN
        o_msg_msg       := '[데이타 확인필요]=>STCK_STA';
        o_msg_code      := '-1';            
        RAISE E_EXCEPTION_USER;            
      END IF;    

      --<<***************************************************************************************************************>>       

      --TB_WRK018:수입밀롤일때만 저장됨.
      --IF LENGTH(IFRWM008.BARCNO) > 0 THEN
      IF NVL(LENGTH(TRIM(IFRWM008.BARCNO)),0) > 0 THEN
        IF IFRWM008.DLFL = 'D' THEN
            BEGIN
              SELECT STCK_QTY INTO V_STCK_QTY
                FROM TB_INV001
               WHERE WERKS = IFRWM008.WERKS
                 AND IND_BCD = IFRWM008.IND_BCD;
              EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    V_STCK_QTY := 0;
              END;
              
              IF IFRWM008.QTY > V_STCK_QTY OR V_STCK_QTY <= 0 THEN
                o_msg_msg       := '[가용재고 부족] ' || IFRWM008.MATNR || ' 는  불출요청을 취소할 수 없습니다.';
                o_msg_code      := '-1' ;            
                RAISE E_EXCEPTION_USER;     
              END IF;
            --TB_WRK018에 존재하는지 선행 체크한다.
            SELECT COUNT(SUPY_VND_BCD) INTO V_CNT 
            FROM TB_WRK018 
            WHERE SUPY_VND_BCD = IFRWM008.BARCNO;           

            IF V_CNT = 0 THEN
                o_msg_msg       := '[수입밀롤 존재 확인필요]=>삭제할수 없습니다.';
                o_msg_code      := '-1' ;            
                RAISE E_EXCEPTION_USER;                      
            END IF;


            SELECT NVL(LIFT_DT,'') INTO V_LIFT_DT
            FROM TB_WRK018
            WHERE SUPY_VND_BCD = IFRWM008.BARCNO;

            IF LENGTH(V_LIFT_DT) > 0 THEN
                o_msg_msg       := '[수입밀롤 출고여부 확인필요]=>삭제할수 없습니다.';
                o_msg_code      := '-1' ;            
                RAISE E_EXCEPTION_USER;             

              RETURN;
            ELSE
              DELETE 
                FROM TB_WRK018
               WHERE BARCODE_NO = IFRWM008.BARCNO;
               
--              UPDATE TB_WRK018
--              SET WRK_STA = 'C'
--              WHERE SUPY_VND_BCD = IFRWM008.BARCNO;              
            END IF;
        ELSE
          /*BEGIN
          SELECT STCK_QTY INTO V_STCK_QTY
            FROM TB_INV001
           WHERE WERKS = IFRWM008.WERKS
             AND MATNR = IFRWM008.MATNR;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
                V_STCK_QTY := 0;
          END;
          
          IF IFRWM008.QTY > V_STCK_QTY OR V_STCK_QTY <= 0 THEN
            o_msg_msg       := '[가용재고 부족] ' || IFRWM008.MATNR || ' 는  불출요청을 취소할 수 없습니다.';
            o_msg_code      := '-1' ;            
            RAISE E_EXCEPTION_USER;     
          END IF;*/

            INSERT INTO TB_WRK018(
               BARCODE_NO									 --업체바코드          
              ,MATNR                       --자재코드           
              ,RCVGDS_DT                   --입고일자           
              ,SUPY_VND_BCD                --개별바코드( IND_BCD->SUPY_VND_BCD)  변경 22-06-30        
              ,SUPY_VND_LOT                --LOT_NO( LOT_NO->SUPY_VND_LOT)  변경 22-06-30      
              ,SUPY_CD                     --공급업체코드         
              ,CON_NO                      --컨테이너No         
              ,ZFBLNO                      --B/L 관리번호       
              ,ROLL_NO                     --ROLL ID        
              ,MWIDTH                      --M/R 지폭         
              ,ROLLCNT                     --M/R 권치수        
              ,NET_WGT                     --Net 중량         
              ,WGT_MUL                     --중량배수           
              ,CORE                        --지관             
              ,UNIT                        --중량단위           
              ,PCODE_SUPPY                 --고객 지종          
              ,TB_WGT                      --M/R중량          
              ,RB_WGT                      --M/R중량(SAP에서 사용)
              ,UNIT_L                      --길이단위           
              ,PCODE                       --지종코드(SAP)      
              ,BS_WGT                      --평량             
              ,RMK_1                       --비고             
              ,RMK_2                       --비고             
              ,RMK_3                       --비고             
              ,RMK_4                       --비고             
              ,RMK_5                       --비고
              ,WRK_STA                     --작업상태(N:대기, Y:출고, C:취소)
              ,IN_DT                       --입고전기일
              ,STO_DOC_NO                  --STO문서번호

              ,REGDATE                     --등록일자
              ,REGID                       --등록자
              ,UPDDATE                     --수정일자
              ,UPDID                       --수정자                    
            )
            SELECT 
               BARCNO             				 --업체바코드          
              ,MATNR                       --자재코드           
              ,RCVGDS_DT                   --입고일자           
              ,NVL(IND_BCD,'*')              --개별바코드          
              ,LOT_NO                      --LOT_NO         
              ,PTNRKY                      --공급업체코드         
              ,CONTNO                      --컨테이너No         
              ,ZFBLNO                      --B/L 관리번호       
              ,ROLLID                      --ROLL ID        
              ,MRGSM                       --M/R 지폭         
              ,LENGTH                      --M/R 권치수        
              ,NETWT                       --Net 중량         
              ,WGTMUL                      --중량배수           
              ,COREDI                      --지관             
              ,KUNIT                       --중량단위           
              ,CPCOD                       --고객 지종          
              ,TBRGEW                      --M/R중량          
              ,RBRGEW                      --M/R중량(SAP에서 사용)
              ,LUNIT                       --길이단위           
              ,DESCRI                      --지종코드(SAP)      
              ,WEIGHT                      --평량             
              ,RMK1                        --비고             
              ,RMK2                        --비고             
              ,RMK3                        --비고             
              ,RMK4                        --비고             
              ,RMK5                        --비고  
              ,'N'      
              ,IN_DT                       --입고전기일
              ,STO_DOC_NO                  --STO문서번호          

              ,sysdate                     --생성일자
              ,'IFRWM008'                    --생성자  
              ,null                        --수정일자
              ,null                        --수정자
            FROM TB_IFRWM008           
            WHERE  IF_IFR_NO =  IFRWM008.IF_IFR_NO     
            ;                
        END IF;                    
      END IF;



      --TB_INV007:자재불출반납이력      
      --KHJ 22-09-07 :WMS문서번호, WMS문서아이템번호 동일하며 개별바코드 틀리게 수신 되는 문제 해결
      --                    삭제시  WMS문서번호, WMS문서아이템번호 모두 'D' 처리하고 나머지는 무조건 등록 처리 하는걸로 변경 함.

      --YSH  2022.09.01
      SELECT MATNR_DIV INTO V_MATNR_DIV
        FROM TB_MAS001
       WHERE WERKS = IFRWM008.WERKS
         AND MATNR = IFRWM008.MATNR;

      IF IFRWM008.DLFL = 'D' THEN
         UPDATE TB_INV007
         SET DLFL = 'D'       									  											                      
         WHERE WDOC_NO = IFRWM008.VGBEL
         AND WDOC_SEQNO = IFRWM008.VGPOS
         AND IND_BCD = DECODE(V_MATNR_DIV, 'ROH6', ' ', 'ROH7', ' ', IFRWM008.IND_BCD);                                
      ELSE 
         INSERT INTO TB_INV007 
         (       WDOC_NO            																	--WMS 참조문서 번호         
                ,WDOC_SEQNO                   												--WMS 참조문서아이템   
                ,IF_IFR_NO											                                          
                ,DLFL                         												--삭제 지시자              
                ,MATNR                        												--자재코드                
                ,UNIT                         												--단위                  
                ,QTY                          												--수량                  
                ,WERKS                        												--플랜트                 
                ,LOTA03                       												--포장타입                
                ,LOTA04                       												--호기                  
                ,LOTA05                       												-- 
                ,STCK_STA                     												--재고상태                
                ,LOTA7                        												--주문번호(10)+아이템번호(6)MTO
                ,NTN_CD                       												--국가코드                
                ,CRSPD_CD                     												--거래처코드               
                ,LOTA10                       												--보유사유명               
                ,PRDC_DT                      												--제조일자                
                ,RCVCDS_DT                    												--입고일자                
                ,DSTBT_DDLIN                  												--유통기한(생리대, 기저귀, 물티슈) 
                ,IND_BCD                      												--개별바코드(협력업체바코드 공용)   
                ,LOT_NO                       												--LOT번호               
                ,LOTA16                       												--평량(PS)              
                ,LOTA17                       												--컨테이너 유형(PS)         
                ,LOTA18                       												--LOTA18              
                ,LOTA19                       												--LOTA19              
                ,LOTA20                       												--LOTA20              
                ,STOK_KY                      												--Stock key           
                ,LOT_NUM                      												--WMS LOT 속성
                ,DOC_NO                                               --MES문서번호
                ,DOC_SEQNO                                            --MES문서순번
                ,REQ_DIV                                              --요청구분
                ,STOR_LOC_FR							                            --저장위치(FROM)                  
                ,STOR_LOC_TO                   												--저장위치(TO)                   																						    								  

                ,REGDATE                       			                  --등록일자
                ,REGID                         			                  --등록자
                ,UPDDATE                       			                  --수정일자
                ,UPDID                         			                  --수정자
         )
         SELECT  VGBEL													        							--WMS 참조문서 번호                         
                ,VGPOS                                            		--WMS 참조문서아이템   
                ,IFRWM008.IF_IFR_NO                                      
                ,DLFL                                             		--삭제 지시자                              
                ,MATNR                                            		--자재코드                                
                ,UNIT                                             		--단위                                  
                ,QTY                                              		--수량                                  
                ,LOTA02                                           		--플랜트                                 
                ,LOTA03                                           		--포장타입                                
                ,LOTA04                                           		--호기                                  
                ,LOTA05                                           		--                                    
                ,STCK_STA                                         		--재고상태                                
                ,LOTA07                                           		--주문번호(10)+아이템번호(6)MTO                
                ,NTN_CD                                           		--국가코드                                
                ,CRSPD_CD                                         		--거래처코드                               
                ,LOTA10                                           		--보유사유명                               
                ,PRDC_DT                                          		--제조일자                                
                ,RCVGDS_DT                                        		--입고일자                                
                ,DSTBT_DDLIN                                      		--유통기한(생리대, 기저귀, 물티슈)                 
                ,DECODE(V_MATNR_DIV, 'ROH6', ' ', 'ROH7', ' ', IND_BCD)                                    		--개별바코드(협력업체바코드 공용)                   
                ,LOT_NO                                           		--LOT번호                               
                ,LOTA16                                           		--평량(PS)                              
                ,LOTA17                                           		--컨테이너 유형(PS)                         
                ,LOTA18                                           		--LOTA18                              
                ,LOTA19                                           		--LOTA19                              
                ,LOTA20                                           		--LOTA20                              
                ,STOK_KY                                          		--Stock key                           
                ,LOT_NUM                                          		--WMS LOT 속성 
                ,DOC_NO                                               --MES문서번호
                ,DOC_SEQNO                                            --MES문서순번	
                ,'40'                                                   --요청구분->직불출
                ,IFRWM008.STOR_LOC_FROM                               --저장위치(FROM)                																														
                ,IFRWM008.STOR_LOC_TO                                 --저장위치(TO)

                ,sysdate                                              --생성일자
                ,'IFRWM008'                                             --생성자  
                ,null                                                 --수정일자
                ,null                                                 --수정자
         FROM TB_IFRWM008           
         WHERE  IF_IFR_NO =  IFRWM008.IF_IFR_NO;
      END IF;

      --TB_INV001:공정재고
      --기본단위 체크 및 환산 22-07-24
      V_STD_UNIT := '';

      SELECT NVL(UNIT,'') INTO V_STD_UNIT
      FROM TB_MAS001 
      WHERE WERKS = IFRWM008.WERKS
      AND MATNR = IFRWM008.MATNR;

      IF V_STD_UNIT = '' THEN
        o_msg_msg       := '[환산단위 확인필요]=>자재마스타 기본단위가 없습니다.';
        o_msg_code      := '-1' ;            
        RAISE E_EXCEPTION_USER;      
      END IF;

      V_STD_QTY := FN_CHG_UNIT(IFRWM008.MATNR,IFRWM008.WERKS,IFRWM008.UNIT,V_STD_UNIT,IFRWM008.QTY);

      IF V_STD_QTY = 0 THEN
        o_msg_msg       := '[환산단위 확인필요]=>단위환산 수량 없음';
        o_msg_code      := '-1' ;            
        RAISE E_EXCEPTION_USER;                  
      END IF; 


      --수량계산추가 22-09-02
      V_PLT_QTY     := FN_CHG_UNIT(IFRWM008.MATNR,IFRWM008.WERKS,IFRWM008.UNIT,'PAL',IFRWM008.QTY); 
      V_BOX_QTY     := FN_CHG_UNIT(IFRWM008.MATNR,IFRWM008.WERKS,IFRWM008.UNIT,'BOX',IFRWM008.QTY); 
      V_BAG_QTY     := FN_CHG_UNIT(IFRWM008.MATNR,IFRWM008.WERKS,IFRWM008.UNIT,'BAG',IFRWM008.QTY); 
      V_EA_QTY      := FN_CHG_UNIT(IFRWM008.MATNR,IFRWM008.WERKS,IFRWM008.UNIT,'EA',IFRWM008.QTY); 
      V_ROLLCNT_QTY := FN_CHG_UNIT(IFRWM008.MATNR,IFRWM008.WERKS,IFRWM008.UNIT,'M',IFRWM008.QTY); 
      V_WGT_QTY     := FN_CHG_UNIT(IFRWM008.MATNR,IFRWM008.WERKS,IFRWM008.UNIT,'KG',IFRWM008.QTY);             


      SELECT COUNT(WERKS) INTO V_CNT 
      FROM TB_INV001 
      WHERE WERKS = IFRWM008.WERKS 
      --AND STOR_LOC_CD = IFRWM008.STOR_LOC_TO --22-09-07 TB_INV001의 개별바코드는 유일한것으로 업무결정하여 주석처리 됨.
      AND MATNR = IFRWM008.MATNR
      AND IND_BCD = DECODE(V_MATNR_DIV, 'ROH6', ' ', 'ROH7', ' ', IFRWM008.IND_BCD);     

      --공정재고가 존재할시 기존재고에 합치는 요청 적용. 22-06-14
      --KHJ 22-09-07 TB_INV001의 개별바코드는 유일한것으로 업무결정됨.      
      --KHJ 22-09-15 TB_INV001의 개별바코드 존재여부 체크하면 기존 데이타가 존재시 창고를 변경해버리게 되는 문제점이 존재 한다.        
      IF V_CNT > 1 THEN
        o_msg_msg       := '[데이타 확인필요]=>MES재고에 개별바코드가 1개이상 발견되었습니다.';
        o_msg_code      := '-1' ;            
        RAISE E_EXCEPTION_USER;                  
      END IF;        
      IF V_CNT > 0 THEN                  
            IF IFRWM008.DLFL = 'D' THEN --삭제된것으로 수신되었을때 처리 추가 22-06-22                          
              UPDATE TB_INV001
              SET STOR_LOC_CD = IFRWM008.STOR_LOC_TO
                 ,STCK_QTY = NVL(STCK_QTY,0) - NVL(V_STD_QTY,0)  
                 ,PLT_QTY   = NVL(PLT_QTY,0) - NVL(V_PLT_QTY,0)
                 ,BOX_QTY   = NVL(BOX_QTY,0) - NVL(V_BOX_QTY,0)
                 ,BAG_QTY   = NVL(BAG_QTY,0) - NVL(V_BAG_QTY,0)
                 ,EA_QTY    = NVL(EA_QTY,0) - NVL(V_EA_QTY,0)
                 ,ROLLCNT   = NVL(ROLLCNT,0) - NVL(V_ROLLCNT_QTY,0)
                 ,WGT       = NVL(WGT,0) - NVL(V_WGT_QTY,0)                        
                 ,UPDDATE = sysdate                                             --수정일자
                 ,UPDID = 'IFRWM008'                                              --수정자             
              WHERE WERKS = IFRWM008.WERKS 
              --AND STOR_LOC_CD = IFRWM008.STOR_LOC_TO --22-09-07 TB_INV001의 개별바코드는 유일한것으로 업무결정하여 주석처리 됨.
              AND MATNR = IFRWM008.MATNR
              AND IND_BCD = DECODE(V_MATNR_DIV, 'ROH6', ' ', 'ROH7', ' ', IFRWM008.IND_BCD);                                                                                                     
            ELSE
              IF V_MATNR_DIV = 'FERT' OR V_MATNR_DIV = 'HALB' THEN
                  UPDATE TB_INV001
                  SET STCK_QTY = NVL(STCK_QTY,0) + NVL(V_STD_QTY,0)
                     ,PLT_QTY   = NVL(PLT_QTY,0) + NVL(V_PLT_QTY,0)
                     ,BOX_QTY   = NVL(BOX_QTY,0) + NVL(V_BOX_QTY,0)
                     ,BAG_QTY   = NVL(BAG_QTY,0) + NVL(V_BAG_QTY,0)
                     ,EA_QTY    = NVL(EA_QTY,0) + NVL(V_EA_QTY,0)
                     ,ROLLCNT   = NVL(ROLLCNT,0) + NVL(V_ROLLCNT_QTY,0)
                     ,WGT       = NVL(WGT,0) + NVL(V_WGT_QTY,0)                  
                     ,STOR_LOC_CD = IFRWM008.STOR_LOC_TO
                     ,STCK_STA = '00'       
                     ,UPDDATE = sysdate                                         --수정일자
                     ,UPDID = 'IFRWM008'                                          --수정자             
                  WHERE WERKS = IFRWM008.WERKS 
                  --AND STOR_LOC_CD = IFRWM008.STOR_LOC_TO --22-09-07 TB_INV001의 개별바코드는 유일한것으로 업무결정하여 주석처리 됨.
                  AND MATNR = IFRWM008.MATNR
                  AND IND_BCD = DECODE(V_MATNR_DIV, 'ROH6', ' ', 'ROH7', ' ', IFRWM008.IND_BCD);                           
              ELSE
                  UPDATE TB_INV001
                  SET STCK_QTY = NVL(STCK_QTY,0) + NVL(V_STD_QTY,0)
                     ,PLT_QTY   = NVL(PLT_QTY,0) + NVL(V_PLT_QTY,0)
                     ,BOX_QTY   = NVL(BOX_QTY,0) + NVL(V_BOX_QTY,0)
                     ,BAG_QTY   = NVL(BAG_QTY,0) + NVL(V_BAG_QTY,0)
                     ,EA_QTY    = NVL(EA_QTY,0) + NVL(V_EA_QTY,0)
                     ,ROLLCNT   = NVL(ROLLCNT,0) + NVL(V_ROLLCNT_QTY,0)
                     ,WGT       = NVL(WGT,0) + NVL(V_WGT_QTY,0)                  
                     ,STCK_STA = '00'           
                     ,STOR_LOC_CD = IFRWM008.STOR_LOC_TO                        --KHJ 22-09-14  추가->기존데이타 저장위치 틀릴경우 기존꺼 같이 변경되어 중복키 발생 가능성 있음(YSH요청)   
                     ,WRK_ORDR_NO = ''                                           --KHJ 2022.09.14 (YSH요청)  
                     ,WRK_ORDR_SEQNO = 0                                        --KHJ 2022.09.14 (YSH요청)                        
                     ,UPDDATE = sysdate                                         --수정일자
                     ,UPDID = 'IFRWM008'                                          --수정자             
                  WHERE WERKS = IFRWM008.WERKS 
                  --AND STOR_LOC_CD = IFRWM008.STOR_LOC_TO --22-09-07 TB_INV001의 개별바코드는 유일한것으로 업무결정하여 주석처리 됨.
                  AND MATNR = IFRWM008.MATNR
                  AND IND_BCD = DECODE(V_MATNR_DIV, 'ROH6', ' ', 'ROH7', ' ', IFRWM008.IND_BCD);                         
              END IF;
            END IF;                                                    
      ELSE
             INSERT INTO TB_INV001 
             (       DLFL                         												--삭제 지시자(C:출고, D:삭제)            
										,STOR_LOC_CD                  												--저장위치                          
										,MATNR                        												--제품코드                          
										,UNIT                         												--단위                            
										,STCK_QTY                     												--재고수량                          
										,WERKS                        												--플랜트코드                         
										,STCK_STA                     												--재고상태                          
										,SUPY_CD                      												--공급업체코드                        
										,PRD_DT                      												  --제조(생산)일자                      
										,IND_BCD                      												--개별바코드                         
										,LOT_NO                       												--LOT NO                        
										,STCK_KY                      												--LOTNUM WMS KEY(저장키)           
										,LOT_NUM                      												--LOTNUM WMS KEY(WMS LOT 속성 KEY) 	

										--,ROLLCNT                                              --권치수 22-08-23
										--,WGT					                                        --중량 22-08-23
										,PLT_QTY
										,BOX_QTY
										,BAG_QTY
										,EA_QTY
										,ROLLCNT
										,WGT										

                    ,REGDATE                       			                  --등록일자
                    ,REGID                         			                  --등록자
                    ,UPDDATE                       			                  --수정일자
                    ,UPDID                         			                  --수정자
             )
             SELECT  DLFL                         												--삭제 지시자(C:출고, D:삭제)             
										--,STOR_LOC_TO                  												--저장위치
										,case when  LENGTH(STOR_LOC_TO) > 0 then SUBSTR(STOR_LOC_TO,1,4) else '' end --저장위치(TO)                           
										,MATNR                        												--제품코드                           
										,V_STD_UNIT                         									--단위(기본단위적용) 22-07-24                             
										,V_STD_QTY                          									--재고수량(기본단위적용) 22-07-24                           
										,LOTA02                       												--플랜트코드                          
										,NVL(STCK_STA, '00')                     												--재고상태                           
										,CRSPD_CD                     												--공급업체코드                         
										,PRDC_DT                      												--제조(생산)일자                       
										,DECODE(V_MATNR_DIV, 'ROH6', ' ', 'ROH7', ' ', IND_BCD)                												--개별바코드                          
										,LOT_NO                       												--LOT NO                         
										,STOK_KY                      												--LOTNUM WMS KEY(저장키)            
										,LOT_NUM                      												--LOTNUM WMS KEY(WMS LOT 속성 KEY)  

										--,LENGTH                                               --권치수
										--,TBRGEW										  										      --중량
										,V_PLT_QTY
										,V_BOX_QTY
										,V_BAG_QTY
										,V_EA_QTY
										,V_ROLLCNT_QTY
										,V_WGT_QTY										

                    ,sysdate                                              --생성일자
                    ,'IFRWM008'                                           --생성자  
                    ,null                                                 --수정일자
                    ,null                                                 --수정자
             FROM TB_IFRWM008           
             WHERE  IF_IFR_NO =  IFRWM008.IF_IFR_NO;                                                   
      END IF;      


      o_msg_msg  :=  '직불출 정보 정보가 수신되었습니다.';

      UPDATE  TB_IFRWM008
      SET     IF_STATUS   =  'S'                                                 --I/F상태, N:신규, S:성공, E:오류               
            , IF_SET_DATE =  sysdate                                            --데이터 처리시간(MES I/F 테이블 → MES 운영테이블) 
            , IF_ERR_MESS =  o_msg_msg                                          --데이터 처리 결과 Message(Oracle)      
            --, IF_MES_KEY =  i_IF_MES_KEY                    
      WHERE  IF_IFR_NO =  IFRWM008.IF_IFR_NO   ;


      o_msg_msg       := '직불출 정보가 수신되었습니다.';
      o_msg_code      := '0' ;


      EXCEPTION
            WHEN E_EXCEPTION_USER THEN
                  DBMS_OUTPUT.PUT_LINE(o_msg_msg);
                  ROLLBACK;

                  UPDATE  TB_IFRWM008
                  SET     IF_STATUS   =  'E'                                      --I/F상태, N:신규, S:성공, E:오류               
                        , IF_SET_DATE =  sysdate                                --데이터 처리시간(MES I/F 테이블 → MES 운영테이블) 
                        , IF_ERR_MESS =  o_msg_msg                              --데이터 처리 결과 Message(Oracle)                                 
                  WHERE  IF_IFR_NO =  IFRWM008.IF_IFR_NO   ;
                  Commit ;

                  RETURN;

            WHEN OTHERS THEN
                  o_msg_msg  :=  'SP_IF_GET_IFRWM008=>' || '직불출 정보 수신 중 오류가 발생하였습니다.' || ',' || SQLERRM ;
                  o_msg_code := '-1' ;
                  DBMS_OUTPUT.PUT_LINE (o_msg_msg );
                  ROLLBACK;

                  UPDATE  TB_IFRWM008
                  SET     IF_STATUS   =  'E'                                      --I/F상태, N:신규, S:성공, E:오류               
                        , IF_SET_DATE =  sysdate                                --데이터 처리시간(MES I/F 테이블 → MES 운영테이블) 
                        , IF_ERR_MESS =  o_msg_msg                              --데이터 처리 결과 Message(Oracle)                                  
                  WHERE  IF_IFR_NO =  IFRWM008.IF_IFR_NO   ;
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
          o_msg_msg       := 'SP_IF_GET_IFRWM008=>' || '직불출 정보 수신 중 MAIN에서 오류가 발생하였습니다.' || ',' || to_char(SQLCODE) || ',' || SQLERRM ;
          DBMS_OUTPUT.PUT_LINE(o_msg_msg);
          rollback ;
        END IF;          

  END; 
END SP_IF_GET_IFRWM008;

/
