
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_IF_GET_IFRWM005" (  
 i_IF_MES_ID        IN    VARCHAR2
,i_IF_MES_KEY       IN    VARCHAR2  
,o_msg_code         OUT   VARCHAR2
,o_msg_msg          OUT   VARCHAR2
) 
/*==============================================================================
 * PROGRAM ID    : 
 * PROGRAM NAME  : 인터페이스-자재_완제품 반납 정보
 * VERSION       : 1.0.0{최종 버전 기술}
 * DESCRIPTION   : 자재_완제품 반납 정보
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
 *       - [TB_IFRWM005]  : (.RU.) 자재_완제품 반납 정보
 *=============================================================================*/
IS
  -- 사용자 에러 처리용 변수선언 영역
  E_EXCEPTION_USER  EXCEPTION; 
  V_FLAG      VARCHAR2(10)     DEFAULT ''; 
  
  V_CNT       NUMBER          DEFAULT 0;
  
  V_STD_UNIT  VARCHAR2(10);
  V_STD_QTY   NUMBER;  
  
  V_PLT_QTY     NUMBER        DEFAULT 0; 
  V_BOX_QTY     NUMBER        DEFAULT 0; 
  V_BAG_QTY     NUMBER        DEFAULT 0; 
  V_EA_QTY      NUMBER        DEFAULT 0; 
  V_ROLLCNT_QTY NUMBER        DEFAULT 0; 
  V_WGT_QTY     NUMBER        DEFAULT 0;  
  
  V_CHK_DATA  VARCHAR2(100);   
BEGIN
  DECLARE
    CURSOR  CUR_IFRWM005 IS
      SELECT   IF_IFR_NO										--MES Interface Sequence(수신번호)   
							,VGBEL                        --참조번호 (MES 문서번호)                
							,VGPOS                        --참조번호아이템 (MES 문서아이템번호)          
							,DLFL                         --삭제 지시자(불출요청)
							,WERKS                        --플랜트                   
							,MATNR                        --품목코드                           
							,QTY                          --불출량                            
							,UNIT                         --단위  
							,STOR_LOC_FROM                --저장위치FROM
							,STOR_LOC_TO                  --저장위치TO                           
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
							,DOC_NO                       --오더번호							
							,DOC_SEQNO                    --오더아이템순번							
      FROM    TB_IFRWM005
      WHERE   IF_STATUS  in  ( 'N','E' )           /*  I/F상태, N:신규, S:성공, E:오류            */
      AND IF_MES_KEY =  i_IF_MES_KEY      
      ORDER BY IF_GET_DATE;

    
  BEGIN
    o_msg_msg       := '실행완료';
    o_msg_code      := '0' ;   
      
    FOR IFRWM005 in CUR_IFRWM005 loop
      BEGIN
      
      --<<***************************************************************************************************************>>
      --필수칼럼체크 추가 22-08-31.. 공백1자리일때 TRIM하면 null이 된다.
      --<<***************************************************************************************************************>>      
      SELECT DECODE(TRIM(IFRWM005.WERKS),null,'X',IFRWM005.WERKS) INTO V_CHK_DATA FROM DUAL;
      IF V_CHK_DATA = 'X' THEN
        o_msg_msg       := '[데이타 확인필요]=>WERKS';
        o_msg_code      := '-1';            
        RAISE E_EXCEPTION_USER;            
      END IF; 
        

      SELECT DECODE(TRIM(IFRWM005.DOC_NO),null,'X',IFRWM005.DOC_NO) INTO V_CHK_DATA FROM DUAL;              
      IF V_CHK_DATA = 'X' THEN
        o_msg_msg       := '[데이타 확인필요]=>DOC_NO';
        o_msg_code      := '-1';            
        RAISE E_EXCEPTION_USER;            
      END IF;
 
      
      SELECT DECODE(TRIM(IFRWM005.DOC_SEQNO),null,'X',IFRWM005.DOC_SEQNO) INTO V_CHK_DATA FROM DUAL;      
      IF V_CHK_DATA = 'X' THEN
        o_msg_msg       := '[데이타 확인필요]=>DOC_SEQ';
        o_msg_code      := '-1';            
        RAISE E_EXCEPTION_USER;            
      END IF; 
         
      
      SELECT DECODE(TRIM(IFRWM005.STOR_LOC_TO),null,'X',IFRWM005.STOR_LOC_TO) INTO V_CHK_DATA FROM DUAL;       
      IF V_CHK_DATA = 'X' THEN
        o_msg_msg       := '[데이타 확인필요]=>STOR_LOC_TO';
        o_msg_code      := '-1';            
        RAISE E_EXCEPTION_USER;            
      END IF;  
      
      
      SELECT DECODE(TRIM(IFRWM005.VGBEL),null,'X',IFRWM005.VGBEL) INTO V_CHK_DATA FROM DUAL;      
      IF V_CHK_DATA = 'X' THEN
        o_msg_msg       := '[데이타 확인필요]=>VGBEL';
        o_msg_code      := '-1';            
        RAISE E_EXCEPTION_USER;            
      END IF; 
      
      SELECT DECODE(TRIM(IFRWM005.VGPOS),null,'X',IFRWM005.VGPOS) INTO V_CHK_DATA FROM DUAL;        
      IF V_CHK_DATA = 'X' THEN
        o_msg_msg       := '[데이타 확인필요]=>VGPOS';
        o_msg_code      := '-1';            
        RAISE E_EXCEPTION_USER;            
      END IF;
      
      SELECT DECODE(TRIM(IFRWM005.MATNR),null,'X',IFRWM005.MATNR) INTO V_CHK_DATA FROM DUAL;         
      IF V_CHK_DATA = 'X' THEN
        o_msg_msg       := '[데이타 확인필요]=>MATNR';
        o_msg_code      := '-1';            
        RAISE E_EXCEPTION_USER;            
      END IF;       
      
      SELECT DECODE(TRIM(IFRWM005.UNIT),null,'X',IFRWM005.UNIT) INTO V_CHK_DATA FROM DUAL;       
      IF V_CHK_DATA = 'X' THEN
        o_msg_msg       := '[데이타 확인필요]=>UNIT';
        o_msg_code      := '-1';            
        RAISE E_EXCEPTION_USER;            
      END IF;
            
      SELECT DECODE(TRIM(IFRWM005.IND_BCD),null,'X',IFRWM005.IND_BCD) INTO V_CHK_DATA FROM DUAL;     
      IF V_CHK_DATA = 'X' THEN
        o_msg_msg       := '[데이타 확인필요]=>IND_BCD';
        o_msg_code      := '-1';            
        RAISE E_EXCEPTION_USER;            
      END IF;  

/*        
      SELECT DECODE(TRIM(IFRWM005.LOT_NO),null,'X',IFRWM005.LOT_NO) INTO V_CHK_DATA FROM DUAL;     
      IF V_CHK_DATA = 'X' THEN
        o_msg_msg       := '[데이타 확인필요]=>LOT_NO';
        o_msg_code      := '-1';            
        RAISE E_EXCEPTION_USER;            
      END IF;       
      
    
      SELECT DECODE(TRIM(IFRWM005.STOK_KY),null,'X',IFRWM005.STOK_KY) INTO V_CHK_DATA FROM DUAL;       
      IF V_CHK_DATA = 'X' THEN
        o_msg_msg       := '[데이타 확인필요]=>STOK_KY';
        o_msg_code      := '-1';            
        RAISE E_EXCEPTION_USER;            
      END IF; 
      
      SELECT DECODE(TRIM(IFRWM005.LOT_NUM),null,'X',IFRWM005.LOT_NUM) INTO V_CHK_DATA FROM DUAL;       
      IF V_CHK_DATA = 'X' THEN
        o_msg_msg       := '[데이타 확인필요]=>LOT_NUM';
        o_msg_code      := '-1';            
        RAISE E_EXCEPTION_USER;            
      END IF;  

      
      SELECT DECODE(TRIM(IFRWM005.STCK_STA),null,'X',IFRWM005.STCK_STA) INTO V_CHK_DATA FROM DUAL;        
      IF V_CHK_DATA = 'X' THEN
        o_msg_msg       := '[데이타 확인필요]=>STCK_STA';
        o_msg_code      := '-1';            
        RAISE E_EXCEPTION_USER;            
      END IF;      
*/                                   
      --<<***************************************************************************************************************>>           
      
      
      
      
      
      --TB_INV002:자재완제품불출요청 Close처리 
      SELECT COUNT(DOC_NO) INTO V_CNT 
      FROM TB_INV002 
      WHERE DOC_NO = IFRWM005.DOC_NO 
      AND DOC_SEQ = IFRWM005.DOC_SEQNO; 
      
      IF V_CNT > 0 THEN
        IF IFRWM005.DLFL = 'D' THEN
          UPDATE TB_INV002
          SET IF_STA = 'N'
          WHERE DOC_NO = IFRWM005.DOC_NO 
          AND DOC_SEQ = IFRWM005.DOC_SEQNO;        
        ELSE
          UPDATE TB_INV002
          SET IF_STA = 'Y'
          WHERE DOC_NO = IFRWM005.DOC_NO 
          AND DOC_SEQ = IFRWM005.DOC_SEQNO;
        END IF;             
      END IF;       
      
      
      --TB_INV007:자재불출/반납이력 
      --KHJ 22-09-07 :WMS문서번호, WMS문서아이템번호 동일하며 개별바코드 틀리게 수신 되는 문제 해결
      --                    삭제시  WMS문서번호, WMS문서아이템번호 모두 'D' 처리하고 나머지는 무조건 등록 처리 하는걸로 변경 함.    
      IF IFRWM005.DLFL = 'D' THEN
         UPDATE TB_INV007
         SET DLFL = 'D'       									  											                      
         WHERE WDOC_NO = IFRWM005.VGBEL
         AND WDOC_SEQNO = IFRWM005.VGPOS
         AND IND_BCD = IFRWM005.IND_BCD;                                        
      ELSE
         INSERT INTO TB_INV007 
         (       WDOC_NO    																					--WMS 참조문서 번호                  
                ,WDOC_SEQNO 									  											--WMS 참조문서아이템 
                ,IF_IFR_NO										                 
                ,DLFL       									  											--삭제 지시자                       
                ,MATNR      									  											--자재코드                         
                ,QTY        									  											--수량                           
                ,UNIT       									  											--단위                           
                ,WERKS      									  											--플랜트                          
                ,LOTA03     									  											--포장타입                         
                ,LOTA04     									  											--호기                           
                ,LOTA05     									  											--                             
                ,STCK_STA   									  											--재고상태                         
                ,LOTA7      									  											--주문번호(10)+아이템번호(6)MTO         
                ,NTN_CD     									  											--국가코드                         
                ,CRSPD_CD   									  											--거래처코드                        
                ,LOTA10     									  											--보유사유명                        
                ,PRDC_DT    									  											--제조일자                         
                ,RCVCDS_DT  									  											--입고일자                         
                ,DSTBT_DDLIN									  											--유통기한(생리대, 기저귀, 물티슈)          
                ,IND_BCD    									  											--개별바코드(협력업체바코드 공용)            
                ,LOT_NO     									  											--LOT번호                        
                ,LOTA16     									  											--평량(PS)                       
                ,LOTA17     									  											--컨테이너 유형(PS)                  
                ,LOTA18     									  											--LOTA18                       
                ,LOTA19     									  											--LOTA19                       
                ,LOTA20     									  											--LOTA20
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
         SELECT  VGBEL                       													--WMS 참조문서 번호         
                ,VGPOS                       													--WMS 참조문서아이템
                ,IFRWM005.IF_IFR_NO         
                ,DLFL                        													--삭제 지시자              
                ,MATNR                       													--자재코드                
                ,QTY                         													--수량                  
                ,UNIT                        													--단위                  
                ,LOTA02                      													--플랜트                 
                ,LOTA03                      													--포장타입                
                ,LOTA04                      													--호기                  
                ,LOTA05                      													--                  
                ,STCK_STA                    													--재고상태                
                ,LOTA07                      													--주문번호(10)+아이템번호(6)MTO
                ,NTN_CD                      													--국가코드                
                ,CRSPD_CD                    													--거래처코드               
                ,LOTA10                      													--보유사유명               
                ,PRDC_DT                     													--제조일자                
                ,RCVGDS_DT                   													--입고일자                
                ,DSTBT_DDLIN                 													--유통기한(생리대, 기저귀, 물티슈) 
                ,IND_BCD                     													--개별바코드(협력업체바코드 공용)   
                ,LOT_NO                      													--LOT번호               
                ,LOTA16                      													--평량(PS)              
                ,LOTA17                      													--컨테이너 유형(PS)         
                ,LOTA18                      													--LOTA18              
                ,LOTA19                      													--LOTA19              
                ,LOTA20                      													--LOTA20
                ,DOC_NO                                               --MES문서번호
                ,DOC_SEQNO                                            --MES문서순번
                ,'20'                                                  --요청구분->자재반납	
                ,IFRWM005.STOR_LOC_FROM                               --저장위치(FROM)                																														
                ,IFRWM005.STOR_LOC_TO                                 --저장위치(TO)                																														
                
                ,sysdate                                              --생성일자
                ,'IFRWM005'                                             --생성자  
                ,null                                                 --수정일자
                ,null                                                 --수정자
         FROM TB_IFRWM005           
         WHERE  IF_IFR_NO =  IFRWM005.IF_IFR_NO;                                                   
      END IF;
      
      
      --TB_INV001:공정재고
      --기본단위 체크 및 환산 22-07-24
      V_STD_UNIT := '';
       
      SELECT NVL(UNIT,'') INTO V_STD_UNIT
      FROM TB_MAS001 
      WHERE WERKS = IFRWM005.WERKS
      AND MATNR = IFRWM005.MATNR;
      
      IF V_STD_UNIT = '' THEN
        o_msg_msg       := '[환산단위 확인필요]=>자재마스타 기본단위가 없습니다.';
        o_msg_code      := '-1' ;            
        RAISE E_EXCEPTION_USER;      
      END IF;
      
      V_STD_QTY := FN_CHG_UNIT(IFRWM005.MATNR,IFRWM005.WERKS,IFRWM005.UNIT,V_STD_UNIT,IFRWM005.QTY);

      IF V_STD_QTY = 0 THEN
        o_msg_msg       := '[환산단위 확인필요]=>단위환산 수량 없음';
        o_msg_code      := '-1' ;            
        RAISE E_EXCEPTION_USER;                  
      END IF;       
      
      --수량계산추가 22-09-02
      V_PLT_QTY     := FN_CHG_UNIT(IFRWM005.MATNR,IFRWM005.WERKS,IFRWM005.UNIT,'PAL',IFRWM005.QTY); 
      V_BOX_QTY     := FN_CHG_UNIT(IFRWM005.MATNR,IFRWM005.WERKS,IFRWM005.UNIT,'BOX',IFRWM005.QTY); 
      V_BAG_QTY     := FN_CHG_UNIT(IFRWM005.MATNR,IFRWM005.WERKS,IFRWM005.UNIT,'BAG',IFRWM005.QTY); 
      V_EA_QTY      := FN_CHG_UNIT(IFRWM005.MATNR,IFRWM005.WERKS,IFRWM005.UNIT,'EA',IFRWM005.QTY); 
      V_ROLLCNT_QTY := FN_CHG_UNIT(IFRWM005.MATNR,IFRWM005.WERKS,IFRWM005.UNIT,'M',IFRWM005.QTY); 
      V_WGT_QTY     := FN_CHG_UNIT(IFRWM005.MATNR,IFRWM005.WERKS,IFRWM005.UNIT,'KG',IFRWM005.QTY);       
      
      
      --TB_INV001:공정재고(반납수량만큼 마이너스 처리해 줘야 함)
      SELECT COUNT(WERKS) INTO V_CNT 
      FROM TB_INV001 
      WHERE WERKS = IFRWM005.WERKS 
      --AND STOR_LOC_CD = IFRWM005.STOR_LOC_FROM  --KHJ 22-09-07 TB_INV001의 개별바코드는 유일한것으로 업무결정하여 주석처리 됨.  
      AND IND_BCD = IFRWM005.IND_BCD
      AND MATNR = IFRWM005.MATNR;

      --KHJ 22-09-07 TB_INV001의 개별바코드는 유일한것으로 업무결정됨.     
      --KHJ 22-09-15 TB_INV001의 개별바코드 존재여부 체크하면 기존 데이타가 존재시 창고를 변경해버리게 되는 문제점이 존재 한다.         
      IF V_CNT > 1 THEN
        o_msg_msg       := '[데이타 확인필요]=>MES재고에 개별바코드가 1개이상 발견되었습니다.';
        o_msg_code      := '-1' ;            
        RAISE E_EXCEPTION_USER;                  
      END IF;  
      IF V_CNT > 0 THEN
            IF IFRWM005.DLFL = 'D' THEN --삭제된것으로 수신되었을때 처리 추가 22-06-24                          
              UPDATE TB_INV001
              SET STCK_QTY = NVL(STCK_QTY,0) + NVL(V_STD_QTY,0)--NVL(IFRWM005.QTY,0)              --삭제한 재고수량만큼 플러스 처리 함.  
                 ,PLT_QTY   = NVL(PLT_QTY,0) + NVL(V_PLT_QTY,0)
                 ,BOX_QTY   = NVL(BOX_QTY,0) + NVL(V_BOX_QTY,0)
                 ,BAG_QTY   = NVL(BAG_QTY,0) + NVL(V_BAG_QTY,0)
                 ,EA_QTY    = NVL(EA_QTY,0) + NVL(V_EA_QTY,0)
                 ,ROLLCNT   = NVL(ROLLCNT,0) + NVL(V_ROLLCNT_QTY,0)
                 ,WGT       = NVL(WGT,0) + NVL(V_WGT_QTY,0)
                 ,RET_REQ_QTY = NVL(RET_REQ_QTY, 0)
                 ,UPDDATE = sysdate                                             --수정일자
                 ,UPDID = 'IFRWM005'                                              --수정자
                 ,STCK_STA = '90'												--반납요청 상태로 변경
              WHERE WERKS = IFRWM005.WERKS 
              --AND STOR_LOC_CD = IFRWM005.STOR_LOC_FROM  --KHJ 22-09-07 TB_INV001의 개별바코드는 유일한것으로 업무결정하여 주석처리 됨.                                
              AND IND_BCD = IFRWM005.IND_BCD
              AND MATNR = IFRWM005.MATNR;            
            ELSE                  
              UPDATE TB_INV001
              SET STCK_QTY = NVL(STCK_QTY,0) - NVL(V_STD_QTY,0) --NVL(IFRWM005.QTY,0)              --반납한 재고수량만큼 마이너스 처리 함.
                 ,PLT_QTY   = NVL(PLT_QTY,0) - NVL(V_PLT_QTY,0)
                 ,BOX_QTY   = NVL(BOX_QTY,0) - NVL(V_BOX_QTY,0)
                 ,BAG_QTY   = NVL(BAG_QTY,0) - NVL(V_BAG_QTY,0)
                 ,EA_QTY    = NVL(EA_QTY,0) - NVL(V_EA_QTY,0)
                 ,ROLLCNT   = NVL(ROLLCNT,0) - NVL(V_ROLLCNT_QTY,0)
                 ,WGT       = NVL(WGT,0) - NVL(V_WGT_QTY,0)
                 ,RET_REQ_QTY = NVL(RET_REQ_QTY, 0) - NVL(V_STD_QTY, 0)
                 ,UPDDATE = sysdate                                             --수정일자
                 ,UPDID = 'IFRWM005'                                              --수정자
                 ,STCK_STA = '00'												--정상 상태로 변경
              WHERE WERKS = IFRWM005.WERKS 
              --AND STOR_LOC_CD = IFRWM005.STOR_LOC_FROM  --KHJ 22-09-07 TB_INV001의 개별바코드는 유일한것으로 업무결정하여 주석처리 됨.                                
              AND IND_BCD = IFRWM005.IND_BCD
              AND MATNR = IFRWM005.MATNR;
            END IF;        
                                                                                           
      END IF;      
      
                    
      o_msg_msg  :=  '자재_완제품 반납 정보 정보가 수신되었습니다.';

      UPDATE  TB_IFRWM005
      SET     IF_STATUS   =  'S'                                                 --I/F상태, N:신규, S:성공, E:오류               
            , IF_SET_DATE =  sysdate                                            --데이터 처리시간(MES I/F 테이블 → MES 운영테이블) 
            , IF_ERR_MESS =  o_msg_msg                                          --데이터 처리 결과 Message(Oracle)  
            --, IF_MES_KEY =  i_IF_MES_KEY                           
      WHERE  IF_IFR_NO =  IFRWM005.IF_IFR_NO   ;
      

      o_msg_msg       := '자재_완제품 반납 정보가 수신되었습니다.';
      o_msg_code      := '0' ;


      EXCEPTION
            WHEN E_EXCEPTION_USER THEN
                  DBMS_OUTPUT.PUT_LINE(o_msg_msg);
                  ROLLBACK;

                  UPDATE  TB_IFRWM005
                  SET     IF_STATUS   =  'E'                                      --I/F상태, N:신규, S:성공, E:오류               
                        , IF_SET_DATE =  sysdate                                --데이터 처리시간(MES I/F 테이블 → MES 운영테이블) 
                        , IF_ERR_MESS =  o_msg_msg                              --데이터 처리 결과 Message(Oracle)                                    
                  WHERE  IF_IFR_NO =  IFRWM005.IF_IFR_NO   ;
                  Commit ;
                  
                  RETURN;
                        
            WHEN OTHERS THEN
                  o_msg_msg  :=  'SP_IF_GET_IFRWM005=>' || '자재_완제품 반납 정보 수신 중 오류가 발생하였습니다.' || ',' || SQLERRM ;
                  o_msg_code      := '-1' ;
                  DBMS_OUTPUT.PUT_LINE (o_msg_msg );
                  ROLLBACK;

                  UPDATE  TB_IFRWM005
                  SET     IF_STATUS   =  'E'                                      --I/F상태, N:신규, S:성공, E:오류               
                        , IF_SET_DATE =  sysdate                                --데이터 처리시간(MES I/F 테이블 → MES 운영테이블) 
                        , IF_ERR_MESS =  o_msg_msg                              --데이터 처리 결과 Message(Oracle)                                    
                  WHERE  IF_IFR_NO =  IFRWM005.IF_IFR_NO   ;
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
          o_msg_msg       := 'SP_IF_GET_IFRWM005=>' || '자재_완제품 반납 정보 수신 중 MAIN에서 오류가 발생하였습니다.' || ',' || to_char(SQLCODE) || ',' || SQLERRM ;
          DBMS_OUTPUT.PUT_LINE(o_msg_msg);
          rollback ;
        END IF;         

  END; 
END;
/
