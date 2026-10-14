--------------------------------------------------------
--  DDL for Procedure SP_IF_GET_IFRWM006
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_IF_GET_IFRWM006" (  
 i_IF_MES_ID        IN    VARCHAR2
,i_IF_MES_KEY       IN    VARCHAR2  
,o_msg_code         OUT   VARCHAR2
,o_msg_msg          OUT   VARCHAR2
) 
/*==============================================================================
 * PROGRAM ID    : 
 * PROGRAM NAME  : 인터페이스-완제품 입고 정보
 * VERSION       : 1.0.0{최종 버전 기술}
 * DESCRIPTION   : 완제품 입고 정보
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
 * 2022/08/05     1.0.1   강현주         정상입고,출고취소,오류시 Flag값 처리 삽입  
 *==============================================================================
 *  관련 테이블    
 *       - [TB_IFRWM006]  : (.RU.) 완제품 입고 정보
 *=============================================================================*/
IS
  V_CNT   NUMBER  DEFAULT 0;
  
  USR_NOT_FOUND_EX1 exception; --데이타 미존재 에러발생
  USR_NOT_FOUND_EX2 exception; --데이타 미존재 에러발생 
  
  E_EXCEPTION_USER  EXCEPTION; 
  
  V_STD_UNIT  VARCHAR2(10);
  V_STD_QTY   NUMBER;
    
  V_PLT_QTY     NUMBER        DEFAULT 0; 
  V_BOX_QTY     NUMBER        DEFAULT 0; 
  V_BAG_QTY     NUMBER        DEFAULT 0; 
  V_EA_QTY      NUMBER        DEFAULT 0; 
  V_ROLLCNT_QTY NUMBER        DEFAULT 0; 
  V_WGT_QTY     NUMBER        DEFAULT 0;
  V_BS_WGT		NUMBER;
  V_WLEN		NUMBER;
  V_VLEN		NUMBER;
  V_QTY			NUMBER;		  
    
  V_STCK_QTY	TB_INV001.STCK_QTY%TYPE;
 
  V_CHK_DATA  VARCHAR2(100);    
BEGIN
  DECLARE
    CURSOR  CUR_IFRWM006 IS
      SELECT   IF_IFR_NO										--MES Interface Sequence(수신번호)   
							,DOC_NO                       --MES 문서순번                       
							,DOC_SEQNO                    --MES 문서순번                    
							,WERKS                        --플랜트      							   
							,STOR_LOC_FROM                --저장위치(WMS창고) FROM    
							,STOR_LOC_TO                  --저장위치(WMS창고) FROM  							           
							,MATNR                        --품목코드                           
							,QTY                          --불출량                            
							,UNIT                         --단위                             
							,VGBEL                        --참조번호 (MES 문서번호)                
							,VGPOS                        --참조번호아이템 (MES 문서아이템번호)          
							,DLFL                         --삭제 지시자(불출요청)                   
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
							,STOK_KY                      --Stock Key
							,LOT_NUM                      --WMS LOT속성코드
      FROM    TB_IFRWM006
      WHERE IF_STATUS  in  ( 'N','E' )           /*  I/F상태, N:신규, S:성공, E:오류            */
      AND IF_MES_KEY =  i_IF_MES_KEY
      ORDER BY IF_GET_DATE;

    
  BEGIN
    FOR IFRWM006 in CUR_IFRWM006 loop
      BEGIN
      
      --<<***************************************************************************************************************>>
      --필수칼럼체크 추가 22-08-31.. 공백1자리일때 TRIM하면 null이 된다.
      --<<***************************************************************************************************************>>      
      SELECT DECODE(TRIM(IFRWM006.WERKS),null,'X',IFRWM006.WERKS) INTO V_CHK_DATA FROM DUAL;
      IF V_CHK_DATA = 'X' THEN
        o_msg_msg       := '[데이타 확인필요]=>WERKS';
        o_msg_code      := '-1';            
        RAISE E_EXCEPTION_USER;            
      END IF; 
        
/*
      SELECT DECODE(TRIM(IFRWM006.DOC_NO),null,'X',IFRWM006.DOC_NO) INTO V_CHK_DATA FROM DUAL;              
      IF V_CHK_DATA = 'X' THEN
        o_msg_msg       := '[데이타 확인필요]=>DOC_NO';
        o_msg_code      := '-1';            
        RAISE E_EXCEPTION_USER;            
      END IF;
 
      
      SELECT DECODE(TRIM(IFRWM006.DOC_SEQ),null,'X',IFRWM006.DOC_SEQ) INTO V_CHK_DATA FROM DUAL;      
      IF V_CHK_DATA = 'X' THEN
        o_msg_msg       := '[데이타 확인필요]=>DOC_SEQ';
        o_msg_code      := '-1';            
        RAISE E_EXCEPTION_USER;            
      END IF; 
*/          
      
      SELECT DECODE(TRIM(IFRWM006.STOR_LOC_TO),null,'X',IFRWM006.STOR_LOC_TO) INTO V_CHK_DATA FROM DUAL;       
      IF V_CHK_DATA = 'X' THEN
        o_msg_msg       := '[데이타 확인필요]=>STOR_LOC_TO';
        o_msg_code      := '-1';            
        RAISE E_EXCEPTION_USER;            
      END IF;  
      
      
      SELECT DECODE(TRIM(IFRWM006.VGBEL),null,'X',IFRWM006.VGBEL) INTO V_CHK_DATA FROM DUAL;      
      IF V_CHK_DATA = 'X' THEN
        o_msg_msg       := '[데이타 확인필요]=>VGBEL';
        o_msg_code      := '-1';            
        RAISE E_EXCEPTION_USER;            
      END IF; 
      
      SELECT DECODE(TRIM(IFRWM006.VGPOS),null,'X',IFRWM006.VGPOS) INTO V_CHK_DATA FROM DUAL;        
      IF V_CHK_DATA = 'X' THEN
        o_msg_msg       := '[데이타 확인필요]=>VGPOS';
        o_msg_code      := '-1';            
        RAISE E_EXCEPTION_USER;            
      END IF;
      
      SELECT DECODE(TRIM(IFRWM006.MATNR),null,'X',IFRWM006.MATNR) INTO V_CHK_DATA FROM DUAL;         
      IF V_CHK_DATA = 'X' THEN
        o_msg_msg       := '[데이타 확인필요]=>MATNR';
        o_msg_code      := '-1';            
        RAISE E_EXCEPTION_USER;            
      END IF;       
      
      SELECT DECODE(TRIM(IFRWM006.UNIT),null,'X',IFRWM006.UNIT) INTO V_CHK_DATA FROM DUAL;       
      IF V_CHK_DATA = 'X' THEN
        o_msg_msg       := '[데이타 확인필요]=>UNIT';
        o_msg_code      := '-1';            
        RAISE E_EXCEPTION_USER;            
      END IF;
            
      SELECT DECODE(TRIM(IFRWM006.IND_BCD),null,'X',IFRWM006.IND_BCD) INTO V_CHK_DATA FROM DUAL;     
      IF V_CHK_DATA = 'X' THEN
        o_msg_msg       := '[데이타 확인필요]=>IND_BCD';
        o_msg_code      := '-1';            
        RAISE E_EXCEPTION_USER;            
      END IF;  
      
/*            
      SELECT DECODE(TRIM(IFRWM006.STOK_KY),null,'X',IFRWM006.STOK_KY) INTO V_CHK_DATA FROM DUAL;       
      IF V_CHK_DATA = 'X' THEN
        o_msg_msg       := '[데이타 확인필요]=>STOK_KY';
        o_msg_code      := '-1';            
        RAISE E_EXCEPTION_USER;            
      END IF; 
      
      SELECT DECODE(TRIM(IFRWM006.LOT_NUM),null,'X',IFRWM006.LOT_NUM) INTO V_CHK_DATA FROM DUAL;       
      IF V_CHK_DATA = 'X' THEN
        o_msg_msg       := '[데이타 확인필요]=>LOT_NUM';
        o_msg_code      := '-1';            
        RAISE E_EXCEPTION_USER;            
      END IF;  
      

      SELECT DECODE(TRIM(IFRWM006.STCK_STA),null,'X',IFRWM006.STCK_STA) INTO V_CHK_DATA FROM DUAL;        
      IF V_CHK_DATA = 'X' THEN
        o_msg_msg       := '[데이타 확인필요]=>STCK_STA';
        o_msg_code      := '-1';            
        RAISE E_EXCEPTION_USER;            
      END IF;
*/                                         
      --<<***************************************************************************************************************>>       
      
      
      

      --TB_WRK015:완제품출고요청 존재시 요청상태변경 R(요청)->O(출고)        
      SELECT COUNT(DOC_NO) INTO V_CNT 
      FROM TB_WRK015 
      WHERE DOC_NO = IFRWM006.DOC_NO 
      AND DOC_SEQNO = IFRWM006.DOC_SEQNO;

      IF V_CNT > 0 THEN
        UPDATE TB_WRK015
        SET REQ_STA = 'O'                        --요청상태
           ,VGBEL   = IFRWM006.VGBEL            --
           ,VGPOS   = IFRWM006.VGPOS            --
           ,STCK_KY = IFRWM006.STOK_KY          --
           ,LOT_NUM = IFRWM006.LOT_NUM          --
           ,UPDDATE = sysdate                   --수정일자
           ,UPDID = 'IFRWM006'                    --수정자
        WHERE IND_BCD = IFRWM006.IND_BCD;               
                                        
      ELSE
        RAISE USR_NOT_FOUND_EX1;
                                                   
      END IF;
      
      --TB_INV001:공정재고
      --기본단위 체크 및 환산 22-07-24
      V_STD_UNIT := '';
       
      SELECT NVL(UNIT,'') INTO V_STD_UNIT
      FROM TB_MAS001 
      WHERE WERKS = IFRWM006.WERKS
      AND MATNR = IFRWM006.MATNR;
      
      IF V_STD_UNIT = '' THEN
        o_msg_msg       := '[환산단위 확인필요]=>자재마스타 기본단위가 없습니다.';
        o_msg_code      := '-1' ;            
        RAISE E_EXCEPTION_USER;      
      END IF;
      
      IF IFRWM006.WERKS <> 'P100' THEN
      	V_STD_QTY := FN_CHG_UNIT(IFRWM006.MATNR,IFRWM006.WERKS,IFRWM006.UNIT,V_STD_UNIT,IFRWM006.QTY);
	  ELSE
	  	V_STD_QTY	:= IFRWM006.QTY;
	  	V_BS_WGT	:= TO_NUMBER(LTRIM(SUBSTR(IFRWM006.MATNR, 6, 3)));			--평량
	  	V_WLEN		:= TO_NUMBER(LTRIM(SUBSTR(IFRWM006.MATNR, 10, 4), '0'));	--가로
	  	V_VLEN		:= TO_NUMBER(LTRIM(SUBSTR(IFRWM006.MATNR, 14, 4), '0'));	--세로
	  	
	  	IF IFRWM006.UNIT = 'R' THEN
	  		V_QTY := IFRWM006.QTY * 500;	--매수 = 수량 * 500
	  	ELSE 
	  		V_QTY := IFRWM006.QTY;			
	  	END IF;
      END IF;
       
	  IF V_STD_QTY = 0 THEN
        o_msg_msg       := '[환산단위 확인필요]=>단위환산 수량 없음';
        o_msg_code      := '-1' ;            
        RAISE E_EXCEPTION_USER;                  
      END IF;  
      
      --수량계산추가 22-09-02
      V_PLT_QTY     := FN_CHG_UNIT(IFRWM006.MATNR,IFRWM006.WERKS,IFRWM006.UNIT,'PAL',IFRWM006.QTY); 
      V_BOX_QTY     := FN_CHG_UNIT(IFRWM006.MATNR,IFRWM006.WERKS,IFRWM006.UNIT,'BOX',IFRWM006.QTY); 
      V_BAG_QTY     := FN_CHG_UNIT(IFRWM006.MATNR,IFRWM006.WERKS,IFRWM006.UNIT,'BAG',IFRWM006.QTY); 
      V_ROLLCNT_QTY := FN_CHG_UNIT(IFRWM006.MATNR,IFRWM006.WERKS,IFRWM006.UNIT,'M',IFRWM006.QTY);
     
      IF IFRWM006.WERKS = 'P100' THEN
      	IF IFRWM006.UNIT = 'KG' THEN
      		V_WGT_QTY 	:= FN_CHG_UNIT(IFRWM006.MATNR,IFRWM006.WERKS,IFRWM006.UNIT,'KG',IFRWM006.QTY);
      	ELSE
      		V_WGT_QTY	:= ROUND(V_QTY * (V_BS_WGT / 1000) * (V_WLEN / 1000) * (V_VLEN / 1000), 3);
      	END IF;
        IF IFRWM006.UNIT = 'R' THEN
        	V_EA_QTY	:= V_QTY;
        ELSE
        	V_EA_QTY	:= FN_CHG_UNIT(IFRWM006.MATNR,IFRWM006.WERKS,IFRWM006.UNIT,'EA',IFRWM006.QTY);
        END IF;
      ELSE
      	V_EA_QTY	:= FN_CHG_UNIT(IFRWM006.MATNR,IFRWM006.WERKS,IFRWM006.UNIT,'EA',IFRWM006.QTY); 
      	V_WGT_QTY	:= FN_CHG_UNIT(IFRWM006.MATNR,IFRWM006.WERKS,IFRWM006.UNIT,'KG',IFRWM006.QTY);
      END IF;
      
      --TB_INV001:공정재고=>공정재고에 MES문서번호,MES문서순번이 존재하는지 반드시 체크 해봐야 함.
      SELECT COUNT(WERKS) INTO V_CNT 
      FROM TB_INV001 
      WHERE WERKS = IFRWM006.WERKS 
      --AND STOR_LOC_CD = IFRWM006.STOR_LOC_FROM  --KHJ 22-09-07 TB_INV001의 개별바코드는 유일한것으로 업무결정하여 주석처리 됨.                                                                            
      AND IND_BCD = IFRWM006.IND_BCD
      AND MATNR = IFRWM006.MATNR;

      --KHJ 22-09-07 TB_INV001의 개별바코드는 유일한것으로 업무결정됨.  
      --KHJ 22-09-15 TB_INV001의 개별바코드 존재여부 체크하면 기존 데이타가 존재시 창고를 변경해버리게 되는 문제점이 존재 한다.
      
      SELECT STCK_QTY INTO V_STCK_QTY
        FROM TB_INV001
       WHERE WERKS = IFRWM006.WERKS                                                                        
         AND IND_BCD = IFRWM006.IND_BCD
         AND MATNR = IFRWM006.MATNR;
     
      IF V_CNT > 1 THEN
        o_msg_msg       := '[데이타 확인필요]=>MES재고에 개별바코드가 1개이상 발견되었습니다.';
        o_msg_code      := '-1' ;            
        RAISE E_EXCEPTION_USER;                  
      END IF;  
      IF V_CNT > 0 THEN
            IF IFRWM006.DLFL = 'D' THEN --(출고취소)삭제된것으로 수신되었을때 처리 추가 22-06-24     
              UPDATE TB_WRK015
                 SET REQ_STA = 'R'                        --요청상태
                 	,VGBEL   = NULL           --
           			,VGPOS   = NULL          --
           			,STCK_KY = NULL          --
           			,LOT_NUM = NULL
                  	,UPDDATE = sysdate                   --수정일자
                 	,UPDID = 'IFRWM006'                    --수정자
               WHERE DOC_NO = IFRWM006.DOC_NO 
                 AND DOC_SEQNO = IFRWM006.DOC_SEQNO;              
            
                       
              UPDATE TB_INV001
              	 SET STCK_QTY = NVL(STCK_QTY,0) + NVL(V_STD_QTY,0)--NVL(IFRWM006.QTY,0)                    --재고수량                
                 	,PLT_QTY   = NVL(PLT_QTY,0) + NVL(V_PLT_QTY,0)
                 	,BOX_QTY   = NVL(BOX_QTY,0) + NVL(V_BOX_QTY,0)
                 	,BAG_QTY   = NVL(BAG_QTY,0) + NVL(V_BAG_QTY,0)
                 	,EA_QTY    = NVL(EA_QTY,0) + NVL(V_EA_QTY,0)
                 	,ROLLCNT   = NVL(ROLLCNT,0) + NVL(V_ROLLCNT_QTY,0)
                 	,WGT       = NVL(WGT,0) + NVL(V_WGT_QTY,0)                   
                 	,STCK_KY = IFRWM006.STOK_KY                                          --Stock Key
                 	,LOT_NUM = IFRWM006.LOT_NUM                                          --WMS LOT속성코드  
                 	,STCK_STA = '80'            
                 	,UPDDATE = sysdate                                                   --수정일자
                 	,UPDID = 'IFRWM006'                                                    --수정자
               WHERE WERKS = IFRWM006.WERKS 
              --AND STOR_LOC_CD = IFRWM006.STOR_LOC_FROM --KHJ 22-09-07 TB_INV001의 개별바코드는 유일한것으로 업무결정하여 주석처리 됨.                                                                                                        
                 AND IND_BCD = IFRWM006.IND_BCD
                 AND MATNR = IFRWM006.MATNR;  
            ELSE
              IF V_STCK_QTY > 0 THEN  
	              UPDATE TB_INV001
	              SET STCK_QTY = NVL(STCK_QTY,0) - NVL(V_STD_QTY,0)--NVL(IFRWM006.QTY,0)                    --재고수량
	                 ,PLT_QTY   = NVL(PLT_QTY,0) - NVL(V_PLT_QTY,0)
	                 ,BOX_QTY   = NVL(BOX_QTY,0) - NVL(V_BOX_QTY,0)
	                 ,BAG_QTY   = NVL(BAG_QTY,0) - NVL(V_BAG_QTY,0)
	                 ,EA_QTY    = NVL(EA_QTY,0) - NVL(V_EA_QTY,0)
	                 ,ROLLCNT   = NVL(ROLLCNT,0) - NVL(V_ROLLCNT_QTY,0)
	                 ,WGT       = NVL(WGT,0) - NVL(V_WGT_QTY,0)                 
	                 ,STCK_KY = IFRWM006.STOK_KY                                          --Stock Key
	                 ,STCK_STA = '70'
	                 ,LOT_NUM = IFRWM006.LOT_NUM                                          --WMS LOT속성코드                 
	                 ,UPDDATE = sysdate                                                   --수정일자
	                 ,UPDID = 'IFRWM006'                                                    --수정자
	              WHERE WERKS = IFRWM006.WERKS 
	              --AND STOR_LOC_CD = IFRWM006.STOR_LOC_FROM --KHJ 22-09-07 TB_INV001의 개별바코드는 유일한것으로 업무결정하여 주석처리 됨.                                                                                                        
	              AND IND_BCD = IFRWM006.IND_BCD
	              AND MATNR = IFRWM006.MATNR;
	          ELSE
	          	o_msg_msg       := 'MES 재고에서 더 이상 입고될 수량이 없습니다.';
      			o_msg_code      := '-1' ;
      			RAISE E_EXCEPTION_USER;   
	          END IF;
            END IF;                               
                                        
      ELSE
        RAISE USR_NOT_FOUND_EX2;                                                   
      END IF;      
      
      
      
    
      
      o_msg_msg  :=  '완제품 출고 정보가 수신되었습니다.';

      UPDATE  TB_IFRWM006
      SET     IF_STATUS   =  'S'                                                 --I/F상태, N:신규, S:성공, E:오류               
            , IF_SET_DATE =  sysdate                                            --데이터 처리시간(MES I/F 테이블 → MES 운영테이블) 
            , IF_ERR_MESS =  o_msg_msg                                          --데이터 처리 결과 Message(Oracle)  
            --, IF_MES_KEY =  i_IF_MES_KEY                           
      WHERE  IF_IFR_NO =  IFRWM006.IF_IFR_NO   ;
      

      o_msg_msg       := '완제품 출고 정보가 수신되었습니다.';
      o_msg_code      := '0' ;

      COMMIT;

      EXCEPTION
            WHEN USR_NOT_FOUND_EX1 THEN
                  o_msg_msg  :=  'SP_IF_GET_IFRWM006=>' || 'TB_WRK015 UPDATE 대상이 존재하지 않습니다.';
                  o_msg_code      := '-1' ;
                  DBMS_OUTPUT.PUT_LINE (o_msg_msg );
                  ROLLBACK;
                  
                  --ERROR발생시 TB_INV001에 'E'추가 작업수행 22-08-02
                  UPDATE TB_INV001
                  SET WDOC_NO = 'E' 
                     ,SND_MSG = o_msg_msg                 
                     ,UPDDATE = sysdate                                                   --수정일자
                     ,UPDID = 'IFRWM006'                                                    --수정자
                  WHERE WERKS = IFRWM006.WERKS 
                  AND STOR_LOC_CD = IFRWM006.STOR_LOC_FROM                                                                                                        
                  AND IND_BCD = IFRWM006.IND_BCD
                  AND MATNR = IFRWM006.MATNR;  
                  
                  UPDATE TB_WRK015
                  SET VGBEL = 'E'                        
                     ,UPDDATE = sysdate                   --수정일자
                     ,UPDID = 'IFRWM006'                    --수정자
                  WHERE IND_BCD = IFRWM006.IND_BCD; 
                  
                  IF IFRWM006.WERKS <> 'P100' THEN
                    UPDATE TB_WRK001
                    SET CHK_QC_YN = 'N'
                    WHERE IND_BCD = IFRWM006.IND_BCD;
                  END IF;                  
                        
                  
                  UPDATE  TB_IFRWM006
                  SET     IF_STATUS   =  'E'                                      --I/F상태, N:신규, S:성공, E:오류               
                        , IF_SET_DATE =  sysdate                                --데이터 처리시간(MES I/F 테이블 → MES 운영테이블) 
                        , IF_ERR_MESS =  o_msg_msg                              --데이터 처리 결과 Message(Oracle)      
                        --, IF_MES_KEY =  i_IF_MES_KEY                                   
                  WHERE  IF_IFR_NO =  IFRWM006.IF_IFR_NO   ;
                  Commit ; 
                  
                  RETURN;                    
                  
            WHEN USR_NOT_FOUND_EX2 THEN
                  o_msg_msg  :=  'SP_IF_GET_IFRWM006=>' || 'TB_INV001 UPDATE 대상이 존재하지 않습니다.' ;
                  o_msg_code      := '-1' ;
                  DBMS_OUTPUT.PUT_LINE (o_msg_msg );
                  ROLLBACK;
                  
                  --ERROR발생시 TB_INV001에 'E'추가 작업수행 22-08-02
                  UPDATE TB_INV001
                  SET WDOC_NO = 'E' 
                     ,SND_MSG = o_msg_msg                 
                     ,UPDDATE = sysdate                                                   --수정일자
                     ,UPDID = 'IFRWM006'                                                    --수정자
                  WHERE WERKS = IFRWM006.WERKS 
                  AND STOR_LOC_CD = IFRWM006.STOR_LOC_FROM                                                                                                        
                  AND IND_BCD = IFRWM006.IND_BCD
                  AND MATNR = IFRWM006.MATNR;  
                  
                  UPDATE TB_WRK015
                  SET VGBEL = 'E'                        
                     ,UPDDATE = sysdate                   --수정일자
                     ,UPDID = 'IFRWM006'                    --수정자
                  WHERE IND_BCD = IFRWM006.IND_BCD;  
                  
                  IF IFRWM006.WERKS <> 'P100' THEN
                    UPDATE TB_WRK001
                    SET CHK_QC_YN = 'N'
                    WHERE IND_BCD = IFRWM006.IND_BCD;
                  END IF;                  
                                                 

                  UPDATE  TB_IFRWM006
                  SET     IF_STATUS   =  'E'                                      --I/F상태, N:신규, S:성공, E:오류               
                        , IF_SET_DATE =  sysdate                                --데이터 처리시간(MES I/F 테이블 → MES 운영테이블) 
                        , IF_ERR_MESS =  o_msg_msg                              --데이터 처리 결과 Message(Oracle)      
                        --, IF_MES_KEY =  i_IF_MES_KEY                                   
                  WHERE  IF_IFR_NO =  IFRWM006.IF_IFR_NO   ;
                  Commit ; 
                  
                  RETURN;                   
                  
            WHEN E_EXCEPTION_USER THEN
                  DBMS_OUTPUT.PUT_LINE(o_msg_msg);
                  ROLLBACK;

                  UPDATE  TB_IFRWM006
                  SET     IF_STATUS   =  'E'                                      --I/F상태, N:신규, S:성공, E:오류               
                        , IF_SET_DATE =  sysdate                                --데이터 처리시간(MES I/F 테이블 → MES 운영테이블) 
                        , IF_ERR_MESS =  o_msg_msg                              --데이터 처리 결과 Message(Oracle)                                  
                  WHERE  IF_IFR_NO =  IFRWM006.IF_IFR_NO   ;
                  Commit ;
                  
                  RETURN;                                        
      
            WHEN OTHERS THEN
                  o_msg_msg  :=  'SP_IF_GET_IFRWM006=>' || '완제품 출고 정보 수신 중 오류가 발생하였습니다.' || ',' || SQLERRM ;
                  o_msg_code      := '-1' ;
                  DBMS_OUTPUT.PUT_LINE (o_msg_msg );
                  ROLLBACK;
                  
                  --ERROR발생시 TB_INV001에 'E'추가 작업수행 22-08-02
                  UPDATE TB_INV001
                  SET WDOC_NO = 'E' 
                     ,SND_MSG = o_msg_msg                 
                     ,UPDDATE = sysdate                                                   --수정일자
                     ,UPDID = 'IFRWM006'                                                    --수정자
                  WHERE WERKS = IFRWM006.WERKS 
                  AND STOR_LOC_CD = IFRWM006.STOR_LOC_FROM                                                                                                        
                  AND IND_BCD = IFRWM006.IND_BCD
                  AND MATNR = IFRWM006.MATNR;   
                  
                  UPDATE TB_WRK015
                  SET VGBEL = 'E'                        
                     ,UPDDATE = sysdate                   --수정일자
                     ,UPDID = 'IFRWM006'                    --수정자
                  WHERE IND_BCD = IFRWM006.IND_BCD;  
                  
                  IF IFRWM006.WERKS <> 'P100' THEN
                    UPDATE TB_WRK001
                    SET CHK_QC_YN = 'N'
                    WHERE IND_BCD = IFRWM006.IND_BCD;
                  END IF;                  
                                                  

                  UPDATE  TB_IFRWM006
                  SET     IF_STATUS   =  'E'                                      --I/F상태, N:신규, S:성공, E:오류               
                        , IF_SET_DATE =  sysdate                                --데이터 처리시간(MES I/F 테이블 → MES 운영테이블) 
                        , IF_ERR_MESS =  o_msg_msg                              --데이터 처리 결과 Message(Oracle)      
                        --, IF_MES_KEY =  i_IF_MES_KEY                                   
                  WHERE  IF_IFR_NO =  IFRWM006.IF_IFR_NO   ;
                  Commit ;
                  
                  RETURN;                   
      END;
    END LOOP;

    --o_msg_msg       := '실행완료';
    --o_msg_code      := '0' ;
    IF o_msg_code = 0 THEN
      commit;
    END IF;    

    EXCEPTION
      WHEN OTHERS THEN
        IF o_msg_code = 0 THEN       
          o_msg_code      := '-1' ;
          o_msg_msg       := 'SP_IF_GET_IFRWM006=>' || '완제품 출고 정보 수신 중 MAIN에서 오류가 발생하였습니다.' || ',' || to_char(SQLCODE) || ',' || SQLERRM ;
          DBMS_OUTPUT.PUT_LINE(o_msg_msg);
          rollback ;
        END IF;            

  END; 
END;

/
