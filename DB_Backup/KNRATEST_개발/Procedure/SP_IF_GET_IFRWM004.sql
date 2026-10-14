--------------------------------------------------------
--  DDL for Procedure SP_IF_GET_IFRWM004
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_IF_GET_IFRWM004" (  
 i_IF_MES_ID        IN    VARCHAR2
,i_IF_MES_KEY       IN    VARCHAR2  
,o_msg_code         OUT   VARCHAR2
,o_msg_msg          OUT   VARCHAR2
) 
/*==============================================================================
 * PROGRAM ID    : 
 * PROGRAM NAME  : 인터페이스-자재 불출 정보(음성공장)
 * VERSION       : 1.0.0{최종 버전 기술}
 * DESCRIPTION   : 자재 불출 정보(음성공장)
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
 *       - [TB_IFRWM004]  : (.RU.) 자재 불출 정보(음성공장)
 *=============================================================================*/
IS
  -- 사용자 에러 처리용 변수선언 영역
  E_EXCEPTION_USER  EXCEPTION; 
  V_FLAG      VARCHAR2(10)     DEFAULT ''; 
  
  V_CNT   NUMBER  DEFAULT 0;

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
    CURSOR  CUR_IFRWM004 IS
      SELECT   IF_IFR_NO										--MES Interface Sequence(수신번호)   
							,VGBEL                        --참조번호 (MES 문서번호)                
							,VGPOS                        --참조번호아이템 (MES 문서아이템번호)          
							,DLFL                         --삭제 지시자(불출요청)                   
							,STOR_LOC_TO                  --저장위치(공정창고) TO  
							,STOR_LOC_FROM                --KHJ 22-09-08 추가  							                
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
      FROM    TB_IFRWM004
      WHERE   IF_STATUS  in  ( 'N','E' )           /*  I/F상태, N:신규, S:성공, E:오류            */
      AND IF_MES_KEY =  i_IF_MES_KEY           
      ORDER BY IF_GET_DATE;

    
  BEGIN
  
    o_msg_msg       := '실행완료';
    o_msg_code      := '0' ; 
      
    FOR IFRWM004 in CUR_IFRWM004 loop
      BEGIN
      
      --<<***************************************************************************************************************>>
      --필수칼럼체크 추가 22-08-31.. 공백1자리일때 TRIM하면 null이 된다.
      --<<***************************************************************************************************************>>      
      SELECT DECODE(TRIM(IFRWM004.WERKS),null,'X',IFRWM004.WERKS) INTO V_CHK_DATA FROM DUAL;
      IF V_CHK_DATA = 'X' THEN
        o_msg_msg       := '[데이타 확인필요]=>WERKS';
        o_msg_code      := '-1';            
        RAISE E_EXCEPTION_USER;            
      END IF; 
        
/*
      SELECT DECODE(TRIM(IFRWM004.DOC_NO),null,'X',IFRWM004.DOC_NO) INTO V_CHK_DATA FROM DUAL;              
      IF V_CHK_DATA = 'X' THEN
        o_msg_msg       := '[데이타 확인필요]=>DOC_NO';
        o_msg_code      := '-1';            
        RAISE E_EXCEPTION_USER;            
      END IF;
 
      
      SELECT DECODE(TRIM(IFRWM004.DOC_SEQ),null,'X',IFRWM004.DOC_SEQ) INTO V_CHK_DATA FROM DUAL;      
      IF V_CHK_DATA = 'X' THEN
        o_msg_msg       := '[데이타 확인필요]=>DOC_SEQ';
        o_msg_code      := '-1';            
        RAISE E_EXCEPTION_USER;            
      END IF; 
*/          
      
      SELECT DECODE(TRIM(IFRWM004.STOR_LOC_TO),null,'X',IFRWM004.STOR_LOC_TO) INTO V_CHK_DATA FROM DUAL;       
      IF V_CHK_DATA = 'X' THEN
        o_msg_msg       := '[데이타 확인필요]=>STOR_LOC_TO';
        o_msg_code      := '-1';            
        RAISE E_EXCEPTION_USER;            
      END IF;  
      
      
      SELECT DECODE(TRIM(IFRWM004.VGBEL),null,'X',IFRWM004.VGBEL) INTO V_CHK_DATA FROM DUAL;      
      IF V_CHK_DATA = 'X' THEN
        o_msg_msg       := '[데이타 확인필요]=>VGBEL';
        o_msg_code      := '-1';            
        RAISE E_EXCEPTION_USER;            
      END IF; 
      
      SELECT DECODE(TRIM(IFRWM004.VGPOS),null,'X',IFRWM004.VGPOS) INTO V_CHK_DATA FROM DUAL;        
      IF V_CHK_DATA = 'X' THEN
        o_msg_msg       := '[데이타 확인필요]=>VGPOS';
        o_msg_code      := '-1';            
        RAISE E_EXCEPTION_USER;            
      END IF;
      
      SELECT DECODE(TRIM(IFRWM004.MATNR),null,'X',IFRWM004.MATNR) INTO V_CHK_DATA FROM DUAL;         
      IF V_CHK_DATA = 'X' THEN
        o_msg_msg       := '[데이타 확인필요]=>MATNR';
        o_msg_code      := '-1';            
        RAISE E_EXCEPTION_USER;            
      END IF;       
      
      SELECT DECODE(TRIM(IFRWM004.UNIT),null,'X',IFRWM004.UNIT) INTO V_CHK_DATA FROM DUAL;       
      IF V_CHK_DATA = 'X' THEN
        o_msg_msg       := '[데이타 확인필요]=>UNIT';
        o_msg_code      := '-1';            
        RAISE E_EXCEPTION_USER;            
      END IF;
            
      SELECT DECODE(TRIM(IFRWM004.IND_BCD),null,'X',IFRWM004.IND_BCD) INTO V_CHK_DATA FROM DUAL;     
      IF V_CHK_DATA = 'X' THEN
        o_msg_msg       := '[데이타 확인필요]=>IND_BCD';
        o_msg_code      := '-1';            
        RAISE E_EXCEPTION_USER;            
      END IF;  
      
      SELECT DECODE(TRIM(IFRWM004.STOK_KY),null,'X',IFRWM004.STOK_KY) INTO V_CHK_DATA FROM DUAL;       
      IF V_CHK_DATA = 'X' THEN
        o_msg_msg       := '[데이타 확인필요]=>STOK_KY';
        o_msg_code      := '-1';            
        RAISE E_EXCEPTION_USER;            
      END IF; 
      
      SELECT DECODE(TRIM(IFRWM004.LOT_NUM),null,'X',IFRWM004.LOT_NUM) INTO V_CHK_DATA FROM DUAL;       
      IF V_CHK_DATA = 'X' THEN
        o_msg_msg       := '[데이타 확인필요]=>LOT_NUM';
        o_msg_code      := '-1';            
        RAISE E_EXCEPTION_USER;            
      END IF;  
      
      SELECT DECODE(TRIM(IFRWM004.STCK_STA),null,'X',IFRWM004.STCK_STA) INTO V_CHK_DATA FROM DUAL;        
      IF V_CHK_DATA = 'X' THEN
        o_msg_msg       := '[데이타 확인필요]=>STCK_STA';
        o_msg_code      := '-1';            
        RAISE E_EXCEPTION_USER;            
      END IF;                                   
      --<<***************************************************************************************************************>>        
      
      
      
      
      --TB_INV002:자재완제품불출요청 Close처리 
      SELECT COUNT(DOC_NO) INTO V_CNT 
      FROM TB_INV002 
      WHERE DOC_NO = IFRWM004.DOC_NO 
      AND DOC_SEQ = IFRWM004.DOC_SEQNO; 
      
      IF V_CNT > 0 THEN
        IF IFRWM004.DLFL = 'D' THEN
          UPDATE TB_INV002
          SET IF_STA = 'N'
          WHERE DOC_NO = IFRWM004.DOC_NO 
          AND DOC_SEQ = IFRWM004.DOC_SEQNO;        
        ELSE
          UPDATE TB_INV002
          SET IF_STA = 'Y'
          WHERE DOC_NO = IFRWM004.DOC_NO 
          AND DOC_SEQ = IFRWM004.DOC_SEQNO;
        END IF;             
      END IF;       
      
      

      --TB_INV007:자재불출반납이력      
      --KHJ 22-09-07 :WMS문서번호, WMS문서아이템번호 동일하며 개별바코드 틀리게 수신 되는 문제 해결
      --                    삭제시  WMS문서번호, WMS문서아이템번호 모두 'D' 처리하고 나머지는 무조건 등록 처리 하는걸로 변경 함.  
      IF IFRWM004.DLFL = 'D' THEN
         UPDATE TB_INV007
         SET DLFL = 'D'       									  											                      
         WHERE WDOC_NO = IFRWM004.VGBEL
         AND WDOC_SEQNO = IFRWM004.VGPOS
         AND IND_BCD = IFRWM004.IND_BCD;                         
      ELSE
         INSERT INTO TB_INV007 
         (       WDOC_NO    																					--WMS 참조문서 번호         
                ,WDOC_SEQNO                   												--WMS 참조문서아이템      
                ,IF_IFR_NO											                                       
                ,DLFL                         												--삭제 지시자              
                ,STOR_LOC_TO                  												--저장위치(TO)            
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
                
                ,REGDATE                       			                  --등록일자
                ,REGID                         			                  --등록자
                ,UPDDATE                       			                  --수정일자
                ,UPDID                         			                  --수정자
         )
         SELECT  VGBEL                         												--WMS 참조문서 번호         
                ,VGPOS                                      				  --WMS 참조문서아이템
                ,IFRWM004.IF_IFR_NO                          
                ,DLFL                                       				  --삭제 지시자              
                ,case when  LENGTH(STOR_LOC_TO) > 0 then SUBSTR(STOR_LOC_TO,1,4) else '' end --저장위치(TO)             
                ,MATNR                                      				  --자재코드                
                ,UNIT                                       				  --단위                  
                ,QTY                                        				  --수량                  
                ,LOTA02                                     				  --플랜트                 
                ,LOTA03                                     				  --포장타입                
                ,LOTA04                                     				  --호기                  
                ,LOTA05                                     				  -- 
                ,STCK_STA                                   				  --재고상태                
                ,LOTA07                                     				  --주문번호(10)+아이템번호(6)MTO
                ,NTN_CD                                     				  --국가코드                
                ,CRSPD_CD                                   				  --거래처코드               
                ,LOTA10                                     				  --보유사유명               
                ,PRDC_DT                                    				  --제조일자                
                ,RCVGDS_DT                                  				  --입고일자                
                ,DSTBT_DDLIN                                				  --유통기한(생리대, 기저귀, 물티슈) 
                ,IND_BCD                                    				  --개별바코드(협력업체바코드 공용)   
                ,LOT_NO                                     				  --LOT번호               
                ,LOTA16                                     				  --평량(PS)              
                ,LOTA17                                     				  --컨테이너 유형(PS)         
                ,LOTA18                                     				  --LOTA18              
                ,LOTA19                                     				  --LOTA19              
                ,LOTA20                                     				  --LOTA20              
                ,STOK_KY                                    				  --Stock key           
                ,LOT_NUM                                    				  --WMS LOT 속성 
                ,DOC_NO                                               --MES문서번호
                ,DOC_SEQNO                                            --MES문서순번	
                ,'10'                                                   --요청구분->자재불출
                ,IFRWM004.STOR_LOC_FROM                               --저장위치(FROM)	                																													
                
                ,sysdate                                              --생성일자
                ,'IFRWM004'                                             --생성자  
                ,null                                                 --수정일자
                ,null                                                 --수정자
         FROM TB_IFRWM004           
         WHERE  IF_IFR_NO =  IFRWM004.IF_IFR_NO;                                                   
      END IF;
      
      --TB_INV001:공정재고
      --기본단위 체크 및 환산 22-07-24
      V_STD_UNIT := '';
       
      SELECT NVL(UNIT,'') INTO V_STD_UNIT
      FROM TB_MAS001 
      WHERE WERKS = IFRWM004.WERKS
      AND MATNR = IFRWM004.MATNR;
      
      IF V_STD_UNIT = '' THEN
        o_msg_msg       := '[환산단위 확인필요]=>자재마스타 기본단위가 없습니다.';
        o_msg_code      := '-1' ;            
        RAISE E_EXCEPTION_USER;      
      END IF;
      
      V_STD_QTY := FN_CHG_UNIT(IFRWM004.MATNR,IFRWM004.WERKS,IFRWM004.UNIT,V_STD_UNIT,IFRWM004.QTY);

      IF V_STD_QTY = 0 THEN
        o_msg_msg       := '[환산단위 확인필요]=>단위환산 수량 없음';
        o_msg_code      := '-1' ;            
        RAISE E_EXCEPTION_USER;                  
      END IF;  
      
      --수량계산추가 22-09-02
      V_PLT_QTY     := FN_CHG_UNIT(IFRWM004.MATNR,IFRWM004.WERKS,IFRWM004.UNIT,'PAL',IFRWM004.QTY); 
      V_BOX_QTY     := FN_CHG_UNIT(IFRWM004.MATNR,IFRWM004.WERKS,IFRWM004.UNIT,'BOX',IFRWM004.QTY); 
      V_BAG_QTY     := FN_CHG_UNIT(IFRWM004.MATNR,IFRWM004.WERKS,IFRWM004.UNIT,'BAG',IFRWM004.QTY); 
      V_EA_QTY      := FN_CHG_UNIT(IFRWM004.MATNR,IFRWM004.WERKS,IFRWM004.UNIT,'EA',IFRWM004.QTY); 
      V_ROLLCNT_QTY := FN_CHG_UNIT(IFRWM004.MATNR,IFRWM004.WERKS,IFRWM004.UNIT,'M',IFRWM004.QTY); 
      V_WGT_QTY     := FN_CHG_UNIT(IFRWM004.MATNR,IFRWM004.WERKS,IFRWM004.UNIT,'KG',IFRWM004.QTY);       
      
            
      SELECT COUNT(WERKS) INTO V_CNT 
      FROM TB_INV001 
      WHERE WERKS = IFRWM004.WERKS 
      --AND STOR_LOC_CD = IFRWM004.STOR_LOC_TO --KHJ 22-09-07 TB_INV001의 개별바코드는 유일한것으로 업무결정하여 주석처리 됨.
      AND MATNR = IFRWM004.MATNR
      AND IND_BCD = IFRWM004.IND_BCD; 
          

      --자재불출요청(음성)은 TB_INV001에 없으면 저장만 될뿐 수정에는 관여하지 않는다. 바로 투입처리 된다.
      --KHJ 22-09-07 TB_INV001의 개별바코드는 유일한것으로 업무결정됨.    
      --KHJ 22-09-15 TB_INV001의 개별바코드 존재여부 체크하면 기존 데이타가 존재시 창고를 변경해버리게 되는 문제점이 존재 한다.          
      IF V_CNT > 1 THEN
        o_msg_msg       := '[데이타 확인필요]=>MES재고에 개별바코드가 1개이상 발견되었습니다.';
        o_msg_code      := '-1' ;            
        RAISE E_EXCEPTION_USER;                  
      END IF;        
      IF V_CNT > 0 THEN
        IF IFRWM004.DLFL = 'D' THEN --삭제된것으로 수신되었을때 처리 추가 22-06-22
          -------------------------------------------------------------------------------------------
          --삭제가 들어왔을때 재고상태 00이 아니면 ERROR리턴함.(KHJ:2022-07-22추가)
          ------------------------------------------------------------------------------------------- 
          SELECT NVL(STCK_STA,'00') INTO V_FLAG 
          FROM TB_INV001 
          WHERE WERKS = IFRWM004.WERKS 
          --AND STOR_LOC_CD = IFRWM004.STOR_LOC_TO --KHJ 22-09-07 TB_INV001의 개별바코드는 유일한것으로 업무결정하여 주석처리 됨.
          AND MATNR = IFRWM004.MATNR
          AND IND_BCD = IFRWM004.IND_BCD;              
          
          IF V_FLAG != '00' THEN
            o_msg_msg       := '[재고상태 확인필요]=>삭제할수 없습니다.';
            o_msg_code      := '-1' ;            
            RAISE E_EXCEPTION_USER;            
          END IF;
                  
          --자재불출요청(음성)은 WMS의 재고를 보고 요청해서 수신되기 때문에 바코드 유일하게 움직임.          
          UPDATE TB_INV001
          SET STCK_QTY  = NVL(STCK_QTY,0) - NVL(V_STD_QTY,0)              
             ,PLT_QTY   = NVL(PLT_QTY,0) - NVL(V_PLT_QTY,0)
             ,BOX_QTY   = NVL(BOX_QTY,0) - NVL(V_BOX_QTY,0)
             ,BAG_QTY   = NVL(BAG_QTY,0) - NVL(V_BAG_QTY,0)
             ,EA_QTY    = NVL(EA_QTY,0) - NVL(V_EA_QTY,0)
             ,ROLLCNT   = NVL(ROLLCNT,0) - NVL(V_ROLLCNT_QTY,0)
             ,WGT       = NVL(WGT,0) - NVL(V_WGT_QTY,0)       
             ,UPDDATE = sysdate                                        --수정일자
             ,UPDID = 'IFRWM004'                                         --수정자             
          WHERE WERKS = IFRWM004.WERKS 
          --AND STOR_LOC_CD = ifrwm002.STOR_LOC_TO  --22-09-07 TB_INV001의 개별바코드는 유일한것으로 업무결정하여 주석처리 됨.
          AND MATNR = IFRWM004.MATNR
          AND IND_BCD = IFRWM004.IND_BCD;                                                               
        ELSE
          --KHJ 22-09-07 문제점: 동일한 개별바코드로 WMS에서 또 내려올수 있어서 수량을 증가하는것 고려해야 될꺼 같음.
          --                               9/1 수신 받아서 투입된것이 9/7 불출요청해서 또 수신 되는 경우 발생함. ==> 아래 TB_INV003이 문제가 됨!!!!!!!!!!!!!!!!!!            
          UPDATE TB_INV001
          SET STCK_QTY = NVL(STCK_QTY,0) + 0
             ,PLT_QTY   = NVL(PLT_QTY,0) + 0
             ,BOX_QTY   = NVL(BOX_QTY,0) + 0
             ,BAG_QTY   = NVL(BAG_QTY,0) + 0
             ,EA_QTY    = NVL(EA_QTY,0) + 0
             ,ROLLCNT   = NVL(ROLLCNT,0) + 0
             ,WGT       = NVL(WGT,0) + 0                  
             ,STOR_LOC_CD = IFRWM004.STOR_LOC_TO                       --KHJ 22-09-14  추가->기존데이타 저장위치 틀릴경우 기존꺼 같이 변경되어 중복키 발생 가능성 있음(YSH요청)    
             ,WRK_ORDR_NO = ''                                          --KHJ 2022.09.14 (YSH요청)  
             ,WRK_ORDR_SEQNO = 0                                       --KHJ 2022.09.14 (YSH요청)                   
             ,UPDDATE = sysdate                                        --수정일자
             ,UPDID = 'IFRWM004'                                         --수정자             
          WHERE WERKS = IFRWM004.WERKS 
          --AND STOR_LOC_CD = IFRWM004.STOR_LOC_TO  --22-09-07 TB_INV001의 개별바코드는 유일한것으로 업무결정하여 주석처리 됨.
          AND MATNR = IFRWM004.MATNR
          AND IND_BCD = IFRWM004.IND_BCD;
                         
          --o_msg_msg       := '[재고 확인필요]=>동일데이타 수신 되었습니다.';
          --o_msg_code      := '-1' ;            
          --RAISE E_EXCEPTION_USER;                           
        END IF;                            
      ELSE                 
        INSERT INTO TB_INV001 
        (      DLFL                         												--삭제 지시자(C:출고, D:삭제)            
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
        SELECT DLFL                           											--삭제 지시자(C:출고, D:삭제)            
              ,case when  LENGTH(STOR_LOC_TO) > 0 then SUBSTR(STOR_LOC_TO,1,4) else '' end --저장위치(TO) 										                          
              ,MATNR                          											--제품코드                          
              ,V_STD_UNIT                           								--단위                            
              ,0                            											  --재고수량(투입했으므로 재고수량은 0)                          
              ,LOTA02                         											--플랜트코드                         
              ,'10'                       											      --재고상태(투입한것으로 처리함)                          
              ,CRSPD_CD                       											--공급업체코드                        
              ,PRDC_DT                        											--제조(생산)일자                      
              ,IND_BCD                        											--개별바코드                         
              ,LOT_NO                         											--LOT NO                        
              ,STOK_KY                        											--LOTNUM WMS KEY(저장키)           
              ,LOT_NUM                        											--LOTNUM WMS KEY(WMS LOT 속성 KEY 											     										

              ,0
              ,0
              ,0
              ,0
              ,0
              ,0	              																		  
              
              ,sysdate                                              --생성일자
              ,'IFRWM004'                                             --생성자  
              ,null                                                 --수정일자
              ,null                                                 --수정자
        FROM TB_IFRWM004           
        WHERE  IF_IFR_NO =  IFRWM004.IF_IFR_NO;                                                   
      END IF;
      
      
      --TB_INV003:자재투입      
      --22-07-15 KHJ :자재불출(음성)은 POP에서 WMS의 재고를 보고 TB_INV003에 선행 데이타를 등록되어있기 때문에 투입량,사용량,재고량만 처리 추가 
      --22-09-08 KHJ :동일 개별바코드 수신시 아래와 같은 계산로직으로 변경 함.
      --22-09-08 KHJ :여러설비에서 동일 개별바코드 요청할때 현재는 KEY가 없어서 관리가 안되고 있음....
      --                     향후 TB_INV003의 KEY를 요청시(TB_IFSWM003)에 등록하여 데이타 수신될때 TB_INV003의 KEY로 조회해서 데이타를 관리하면 좋을듯 
      SELECT COUNT(WERKS) INTO V_CNT 
      FROM TB_INV003 
      WHERE IND_BCD = IFRWM004.IND_BCD;
      
      IF V_CNT > 0 THEN
        UPDATE TB_INV003
        SET IN_QTY = NVL(IN_QTY,0) + NVL(V_STD_QTY,0)
           ,STCK_QTY = (NVL(IN_QTY,0) + NVL(V_STD_QTY,0)) - NVL(USE_QTY,0) --NVL(V_STD_QTY,0) - NVL(USE_QTY,0)
           ,UPDDATE = sysdate
           ,UPDID = 'IFRWM004' 
        WHERE IND_BCD = IFRWM004.IND_BCD;
      END IF;      
            
      
                     
      o_msg_msg  :=  '자재 불출 정보(음성공장) 정보가 수신되었습니다.';

      UPDATE  TB_IFRWM004
      SET     IF_STATUS   =  'S'                                                 --I/F상태, N:신규, S:성공, E:오류               
            , IF_SET_DATE =  sysdate                                            --데이터 처리시간(MES I/F 테이블 → MES 운영테이블) 
            , IF_ERR_MESS =  o_msg_msg                                          --데이터 처리 결과 Message(Oracle)   
            --, IF_MES_KEY =  i_IF_MES_KEY                       
      WHERE  IF_IFR_NO =  IFRWM004.IF_IFR_NO   ;
      

      o_msg_msg       := '자재 불출 정보(음성공장) 정보가 수신되었습니다.';
      o_msg_code      := '0' ;


      EXCEPTION
            WHEN E_EXCEPTION_USER THEN
                  DBMS_OUTPUT.PUT_LINE(o_msg_msg);
                  ROLLBACK;

                  UPDATE  TB_IFRWM004
                  SET     IF_STATUS   =  'E'                                      --I/F상태, N:신규, S:성공, E:오류               
                        , IF_SET_DATE =  sysdate                                --데이터 처리시간(MES I/F 테이블 → MES 운영테이블) 
                        , IF_ERR_MESS =  o_msg_msg                              --데이터 처리 결과 Message(Oracle)                                  
                  WHERE  IF_IFR_NO =  IFRWM004.IF_IFR_NO   ;
                  Commit ;
                  
                  RETURN;
                        
            WHEN OTHERS THEN
                  o_msg_msg  :=  'SP_IF_GET_IFRWM004=>' || '자재 불출 정보(음성공장)  수신 중 오류가 발생하였습니다.' || ',' || SQLERRM ;
                  o_msg_code      := '-1' ;
                  DBMS_OUTPUT.PUT_LINE (o_msg_msg );
                  ROLLBACK;

                  UPDATE  TB_IFRWM004
                  SET     IF_STATUS   =  'E'                                      --I/F상태, N:신규, S:성공, E:오류               
                        , IF_SET_DATE =  sysdate                                --데이터 처리시간(MES I/F 테이블 → MES 운영테이블) 
                        , IF_ERR_MESS =  o_msg_msg                              --데이터 처리 결과 Message(Oracle)  
                        --, IF_MES_KEY =  i_IF_MES_KEY                                     
                  WHERE  IF_IFR_NO =  IFRWM004.IF_IFR_NO   ;
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
          o_msg_msg       := 'SP_IF_GET_IFRWM004=>' || '자재 불출 정보(음성공장) 수신 중 MAIN에서 오류가 발생하였습니다.' || ',' || to_char(SQLCODE) || ',' || SQLERRM ;
          DBMS_OUTPUT.PUT_LINE(o_msg_msg);
          rollback ;
        END IF;          

  END; 
END SP_IF_GET_IFRWM004;

/
