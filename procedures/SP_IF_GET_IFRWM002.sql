
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_IF_GET_IFRWM002" (  
 i_IF_MES_ID        IN    VARCHAR2
,i_IF_MES_KEY       IN    VARCHAR2  
,o_msg_code         OUT   VARCHAR2
,o_msg_msg          OUT   VARCHAR2
) 
/*==============================================================================
 * PROGRAM ID    : SP_IF_GET_IFRWM002{호출 프로그램 ID 기술}
 * PROGRAM NAME  : 인터페이스-자재_완제품 불출 정보
 * VERSION       : 1.0.0{최종 버전 기술}
 * DESCRIPTION   : 자재_완제품 불출 정보
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
 *       - [TB_IFRWM002]  : (.RU.) 자재_완제품 불출 정보
 *=============================================================================*/
IS

  -- 사용자 에러 처리용 변수선언 영역
  E_EXCEPTION_USER  EXCEPTION; 
  V_FLAG      VARCHAR2(10)    DEFAULT ''; 
  
  V_CNT       NUMBER          DEFAULT 0;  
  V_STCKCNT		NUMBER		  DEFAULT 1;
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
 
  V_STCK_QTY    	TB_INV001.STCK_QTY%TYPE;
  V_WRK_ORDR_NO	 	TB_SCH020.WRK_ORDR_NO%TYPE;
  V_WRK_ORDR_SEQNO	TB_SCH020.WRK_ORDR_SEQNO%TYPE;
  V_ORDER_ITM_NO	TB_SCH020.ORDER_ITM_NO%TYPE;
  V_WMS_YN			TB_SCH020.WMS_YN%TYPE;
  V_LOT_NO			TB_SCH020.LOT_NO%TYPE;
  V_I_ORDER_ITM_NO  TB_SCH020.ORDER_ITM_NO%TYPE;
  V_ORDER_DIV		TB_SCH019.ORDER_DIV%TYPE;
  
  V_CHK_DATA    VARCHAR2(100);  
  V_BOM_CNT		NUMBER		 DEFAULT 1;

-- 하나의 개별바코드가 하나의 오더로 나뉘어져 불출이 되는 경우 TB_INV007 테이블을 업데이트하기 위한 변수
	V_WDOC_NO		TB_INV007.WDOC_NO%TYPE;
	V_WDOC_SEQNO	TB_INV007.WDOC_SEQNO%TYPE;
	V_QTYEX			TB_INV007.QTY%TYPE;
	V_IND_BCD		TB_INV007.IND_BCD%TYPE;
	V_ORDER_NO		TB_INV007.ORDER_NO%TYPE;
	V_ORDER_SEQNO	TB_INV007.ORDER_SEQNO%TYPE;
	V_CNTEX		NUMBER;


BEGIN
  DECLARE
    CURSOR  cur_ifrwm002 IS
      SELECT   IF_IFR_NO            				--MES Interface Sequence(수신번호)   
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
							,ORDER_NO					  --오더번호
							,ORDER_SEQNO				  --오더순번
       FROM TB_IFRWM002
      WHERE IF_STATUS  in  ( 'N','E' )           /*  I/F상태, N:신규, S:성공, E:오류            */
        AND IF_MES_KEY =  i_IF_MES_KEY            
      ORDER BY IF_IFR_NO;
      --ORDER BY IF_GET_DATE;
    
  BEGIN
  
    --o_msg_msg       := '실행완료';
    --o_msg_code      := '0' ;    
  
    FOR ifrwm002 in cur_ifrwm002 loop
      BEGIN
      
      --<<***************************************************************************************************************>>
      --필수칼럼체크 추가 22-08-31.. 공백1자리일때 TRIM하면 null이 된다.
      --<<***************************************************************************************************************>> 
      SELECT DECODE(TRIM(ifrwm002.WERKS),null,'X',ifrwm002.WERKS) INTO V_CHK_DATA FROM DUAL;
      IF V_CHK_DATA = 'X' THEN
        o_msg_msg       := '[데이타 확인필요]=>WERKS';
        o_msg_code      := '-1';            
        RAISE E_EXCEPTION_USER;            
      END IF; 
        
      SELECT DECODE(TRIM(ifrwm002.DOC_NO),null,'X',ifrwm002.DOC_NO) INTO V_CHK_DATA FROM DUAL;              
      IF V_CHK_DATA = 'X' THEN
        o_msg_msg       := '[데이타 확인필요]=>DOC_NO';
        o_msg_code      := '-1';            
        RAISE E_EXCEPTION_USER;            
      END IF;  
      
      SELECT DECODE(TRIM(ifrwm002.DOC_SEQNO),null,'X',ifrwm002.DOC_SEQNO) INTO V_CHK_DATA FROM DUAL;      
      IF V_CHK_DATA = 'X' THEN
        o_msg_msg       := '[데이타 확인필요]=>DOC_SEQNO';
        o_msg_code      := '-1';            
        RAISE E_EXCEPTION_USER;            
      END IF;    
      
      SELECT DECODE(TRIM(ifrwm002.STOR_LOC_TO),null,'X',ifrwm002.STOR_LOC_TO) INTO V_CHK_DATA FROM DUAL;       
      IF V_CHK_DATA = 'X' THEN
        o_msg_msg       := '[데이타 확인필요]=>STOR_LOC_TO';
        o_msg_code      := '-1';            
        RAISE E_EXCEPTION_USER;            
      END IF;  
      
      
      SELECT DECODE(TRIM(ifrwm002.VGBEL),null,'X',ifrwm002.VGBEL) INTO V_CHK_DATA FROM DUAL;      
      IF V_CHK_DATA = 'X' THEN
        o_msg_msg       := '[데이타 확인필요]=>VGBEL';
        o_msg_code      := '-1';            
        RAISE E_EXCEPTION_USER;            
      END IF; 
      
      SELECT DECODE(TRIM(ifrwm002.VGPOS),null,'X',ifrwm002.VGPOS) INTO V_CHK_DATA FROM DUAL;        
      IF V_CHK_DATA = 'X' THEN
        o_msg_msg       := '[데이타 확인필요]=>VGPOS';
        o_msg_code      := '-1';            
        RAISE E_EXCEPTION_USER;            
      END IF;
      
      SELECT DECODE(TRIM(ifrwm002.MATNR),null,'X',ifrwm002.MATNR) INTO V_CHK_DATA FROM DUAL;         
      IF V_CHK_DATA = 'X' THEN
        o_msg_msg       := '[데이타 확인필요]=>MATNR';
        o_msg_code      := '-1';            
        RAISE E_EXCEPTION_USER;            
      END IF;       
      
      SELECT DECODE(TRIM(ifrwm002.UNIT),null,'X',ifrwm002.UNIT) INTO V_CHK_DATA FROM DUAL;       
      IF V_CHK_DATA = 'X' THEN
        o_msg_msg       := '[데이타 확인필요]=>UNIT';
        o_msg_code      := '-1';            
        RAISE E_EXCEPTION_USER;            
      END IF;
            
      SELECT DECODE(TRIM(ifrwm002.IND_BCD),null,'X',ifrwm002.IND_BCD) INTO V_CHK_DATA FROM DUAL;     
      IF V_CHK_DATA = 'X' THEN
        o_msg_msg       := '[데이타 확인필요]=>IND_BCD';
        o_msg_code      := '-1';            
        RAISE E_EXCEPTION_USER;            
      END IF;  
      
      SELECT DECODE(TRIM(ifrwm002.STOK_KY),null,'X',ifrwm002.STOK_KY) INTO V_CHK_DATA FROM DUAL;       
      IF V_CHK_DATA = 'X' THEN
        o_msg_msg       := '[데이타 확인필요]=>STOK_KY';
        o_msg_code      := '-1';            
        RAISE E_EXCEPTION_USER;            
      END IF; 
      
      SELECT DECODE(TRIM(ifrwm002.LOT_NUM),null,'X',ifrwm002.LOT_NUM) INTO V_CHK_DATA FROM DUAL;       
      IF V_CHK_DATA = 'X' THEN
        o_msg_msg       := '[데이타 확인필요]=>LOT_NUM';
        o_msg_code      := '-1';            
        RAISE E_EXCEPTION_USER;            
      END IF;  
      
      SELECT DECODE(TRIM(ifrwm002.STCK_STA),null,'X',ifrwm002.STCK_STA) INTO V_CHK_DATA FROM DUAL;        
      IF V_CHK_DATA = 'X' THEN
        o_msg_msg       := '[데이타 확인필요]=>STCK_STA';
        o_msg_code      := '-1';            
        RAISE E_EXCEPTION_USER;            
      END IF;                               
      --<<***************************************************************************************************************>>   
                                            
      
      
      

      --TB_INV002:자재완제품불출요청 Close처리 
      SELECT COUNT(DOC_NO) INTO V_CNT 
      FROM TB_INV002 
      WHERE DOC_NO = ifrwm002.DOC_NO 
      AND DOC_SEQ = ifrwm002.DOC_SEQNO; 
      
      IF V_CNT > 0 THEN
        IF ifrwm002.DLFL = 'D' THEN
--          BEGIN
--          SELECT STCK_QTY INTO V_STCK_QTY
--            FROM TB_INV001
--           WHERE WERKS = ifrwm002.WERKS
--             AND IND_BCD = ifrwm002.IND_BCD;
--          EXCEPTION
--            WHEN NO_DATA_FOUND THEN
--                V_STCK_QTY := 0;
--          END;
--          
--          IF ifrwm002.QTY > V_STCK_QTY OR V_STCK_QTY <= 0 THEN
--            o_msg_msg       := '[가용재고 부족] ' || ifrwm002.MATNR || ' 는  불출요청을 취소할 수 없습니다.';
--            o_msg_code      := '-1' ;            
--            RAISE E_EXCEPTION_USER;     
--          END IF;
          
          UPDATE TB_INV002
          SET IF_STA = 'N'
          WHERE DOC_NO = ifrwm002.DOC_NO 
          AND DOC_SEQ = ifrwm002.DOC_SEQNO;        
        ELSE
          UPDATE TB_INV002
          SET IF_STA = 'Y'
          WHERE DOC_NO = ifrwm002.DOC_NO 
          AND DOC_SEQ = ifrwm002.DOC_SEQNO;
        END IF;             
      END IF;    

      --TB_INV007:자재불출반납이력      
      --KHJ 22-09-07 :WMS문서번호, WMS문서아이템번호 동일하며 개별바코드 틀리게 수신 되는 문제 해결
      --                    삭제시  WMS문서번호, WMS문서아이템번호 모두 'D' 처리하고 나머지는 무조건 등록 처리 하는걸로 변경 함.          
      IF ifrwm002.DLFL = 'D' THEN
         UPDATE TB_INV007
         SET DLFL = 'D'       									  											                      
         WHERE WDOC_NO = ifrwm002.VGBEL
         AND WDOC_SEQNO = ifrwm002.VGPOS
         AND IND_BCD = ifrwm002.IND_BCD;  
      ELSE
-- 하나의 개별바코드가 하나의 오더로 나뉘어져 불출이 되는 경우 TB_INV007 테이블을 업데이트하기 위한 변수
      	V_CNTEX := 0;

      	--YSH 2023.05.22
        IF IFRWM002.WERKS <> 'P100' THEN
            BEGIN
                SELECT	WDOC_NO, WDOC_SEQNO, QTY, IND_BCD, ORDER_NO, ORDER_SEQNO
                        INTO
                        V_WDOC_NO, V_WDOC_SEQNO, V_QTYEX, V_IND_BCD, V_ORDER_NO, V_ORDER_SEQNO
                FROM	TB_INV007
                WHERE 	WDOC_NO = ifrwm002.VGBEL
                AND     WDOC_SEQNO = ifrwm002.VGPOS
                AND     IF_IFR_NO = ifrwm002.IF_IFR_NO
                AND     IND_BCD = ifrwm002.IND_BCD
                AND		ORDER_NO = ifrwm002.ORDER_NO
                AND 	ORDER_SEQNO = ifrwm002.ORDER_SEQNO
                AND 	DLFL = ifrwm002.DLFL;

                V_CNTEX := 1;
            EXCEPTION
                    WHEN NO_DATA_FOUND	THEN
                        V_CNTEX := 0;
            END;
        ELSE
            BEGIN
                SELECT	WDOC_NO, WDOC_SEQNO, QTY, IND_BCD, ORDER_NO, ORDER_SEQNO
                        INTO
                        V_WDOC_NO, V_WDOC_SEQNO, V_QTYEX, V_IND_BCD, V_ORDER_NO, V_ORDER_SEQNO
                FROM	TB_INV007
                WHERE 	IND_BCD = ifrwm002.IND_BCD
                AND		ORDER_NO = ifrwm002.ORDER_NO
                AND 	ORDER_SEQNO = ifrwm002.ORDER_SEQNO
                AND 	DLFL = ifrwm002.DLFL;
            
                V_CNTEX := 1;
            EXCEPTION
                    WHEN NO_DATA_FOUND	THEN
                        V_CNTEX := 0;
            END;
        END IF;
                  DBMS_OUTPUT.PUT_LINE('IF_IFR_NO : ' || ifrwm002.IF_IFR_NO);
		IF V_CNTEX = 0	THEN
                  DBMS_OUTPUT.PUT_LINE('1111');
		     INSERT INTO TB_INV007 
		     (       WDOC_NO    																					--WMS 참조문서 번호                     
		            ,WDOC_SEQNO                     											--WMS 참조문서아이템 
		            ,IF_IFR_NO											                    
		            ,DLFL                           											--삭제 지시자                          
		            ,STOR_LOC_TO                    											--저장위치(TO)                        
		            ,MATNR                          											--자재코드                            
		            ,UNIT                           											--단위                              
		            ,QTY                            											--수량                              
		            ,WERKS                          											--플랜트                             
		            ,LOTA03                         											--포장타입                            
		            ,LOTA04                         											--호기                              
		            ,LOTA05                         											--                                
		            ,STCK_STA                       											--재고상태                            
		            ,LOTA7                          											--주문번호(10)+아이템번호(6)MTO            
		            ,NTN_CD                         											--국가코드                            
		            ,CRSPD_CD                       											--거래처코드                           
		            ,LOTA10                         											--보유사유명                           
		            ,PRDC_DT                        											--제조일자                            
		            ,RCVCDS_DT                      											--입고일자                            
		            ,DSTBT_DDLIN                    											--유통기한(생리대, 기저귀, 물티슈)             
		            ,IND_BCD                        											--개별바코드(협력업체바코드 공용)               
		            ,LOT_NO                         											--LOT번호                           
		            ,LOTA16                         											--평량(PS)                          
		            ,LOTA17                         											--컨테이너 유형(PS)                     
		            ,LOTA18                         											--LOTA18                          
		            ,LOTA19                         											--LOTA19                          
		            ,LOTA20                         											--LOTA20                          
		            ,STOK_KY                        											--Stock key                       
		            ,LOT_NUM                        											--WMS LOT 속성	
		            ,DOC_NO                                               --MES문서번호
		            ,DOC_SEQNO                                            --MES문서순번
		            ,REQ_DIV                                              --요청구분	
		            ,STOR_LOC_FR							                            --저장위치(FROM)
		            ,ORDER_NO													--오더번호
		            ,ORDER_SEQNO												--오더순번
		            ,REGDATE                       			                  --등록일자
		            ,REGID                         			                  --등록자
		            ,UPDDATE                       			                  --수정일자
		            ,UPDID                         			                  --수정자
		     )
		     SELECT  VGBEL																								--WMS 참조문서 번호         
		            ,VGPOS                                    						--WMS 참조문서아이템
		            ,ifrwm002.IF_IFR_NO         
		            ,DLFL                                     						--삭제 지시자              
		            ,case when  LENGTH(STOR_LOC_TO) > 0 then SUBSTR(STOR_LOC_TO,1,4) else '' end --저장위치(TO)                   
		            ,MATNR                                    						--자재코드                
		            ,UNIT                                     						--단위                  
		            ,QTY                                      						--수량                  
		            ,LOTA02                                   						--플랜트                 
		            ,LOTA03                                   						--포장타입                
		            ,LOTA04                                   						--호기                  
		            ,LOTA05                                   						--
		            ,STCK_STA                                 						--재고상태                
		            ,LOTA07                                   						--주문번호(10)+아이템번호(6)MTO
		            ,NTN_CD                                   						--국가코드                
		            ,CRSPD_CD                                 						--거래처코드               
		            ,LOTA10                                   						--보유사유명               
		            ,PRDC_DT                                  						--제조일자                
		            ,RCVGDS_DT                                						--입고일자                
		            ,DSTBT_DDLIN                              						--유통기한(생리대, 기저귀, 물티슈) 
		            ,IND_BCD                                  						--개별바코드(협력업체바코드 공용)   
		            ,LOT_NO                                   						--LOT번호               
		            ,LOTA16                                   						--평량(PS)              
		            ,LOTA17                                   						--컨테이너 유형(PS)         
		            ,LOTA18                                   						--LOTA18              
		            ,LOTA19                                   						--LOTA19              
		            ,LOTA20                                   						--LOTA20              
		            ,STOK_KY                                  						--Stock key           
		            ,LOT_NUM                                  						--WMS LOT 속성 
		            ,DOC_NO                                               --MES문서번호
		            ,DOC_SEQNO                                            --MES문서순번											 										
		            ,'10'                                                  --요청구분->자재불출
		            ,ifrwm002.STOR_LOC_FROM                               --저장위치(FROM)
		            ,ORDER_NO												--오더번호
		            ,ORDER_SEQNO											--오더순번
		            ,sysdate                                              --생성일자
		            ,'IFRWM002'                                             --생성자  
		            ,null                                                 --수정일자
		            ,null                                                 --수정자
		     FROM TB_IFRWM002           
		     WHERE  IF_IFR_NO =  ifrwm002.IF_IFR_NO;                                                   
		ELSE
                  DBMS_OUTPUT.PUT_LINE('2222');
			UPDATE	TB_INV007
				SET QTY = QTY + ifrwm002.QTY
			WHERE 	WDOC_NO = V_WDOC_NO
			AND 	WDOC_SEQNO = WDOC_SEQNO
			AND 	IND_BCD = V_IND_BCD
			AND 	ORDER_NO = V_ORDER_NO
			AND		ORDER_SEQNO = V_ORDER_SEQNO
			AND		DLFL = ifrwm002.DLFL;
		END IF;


--         INSERT INTO TB_INV007 
--         (       WDOC_NO    																					--WMS 참조문서 번호                     
--                ,WDOC_SEQNO                     											--WMS 참조문서아이템 
--                ,IF_IFR_NO											                    
--                ,DLFL                           											--삭제 지시자                          
--                ,STOR_LOC_TO                    											--저장위치(TO)                        
--                ,MATNR                          											--자재코드                            
--                ,UNIT                           											--단위                              
--                ,QTY                            											--수량                              
--                ,WERKS                          											--플랜트                             
--                ,LOTA03                         											--포장타입                            
--                ,LOTA04                         											--호기                              
--                ,LOTA05                         											--                                
--                ,STCK_STA                       											--재고상태                            
--                ,LOTA7                          											--주문번호(10)+아이템번호(6)MTO            
--                ,NTN_CD                         											--국가코드                            
--                ,CRSPD_CD                       											--거래처코드                           
--                ,LOTA10                         											--보유사유명                           
--                ,PRDC_DT                        											--제조일자                            
--                ,RCVCDS_DT                      											--입고일자                            
--                ,DSTBT_DDLIN                    											--유통기한(생리대, 기저귀, 물티슈)             
--                ,IND_BCD                        											--개별바코드(협력업체바코드 공용)               
--                ,LOT_NO                         											--LOT번호                           
--                ,LOTA16                         											--평량(PS)                          
--                ,LOTA17                         											--컨테이너 유형(PS)                     
--                ,LOTA18                         											--LOTA18                          
--                ,LOTA19                         											--LOTA19                          
--                ,LOTA20                         											--LOTA20                          
--                ,STOK_KY                        											--Stock key                       
--                ,LOT_NUM                        											--WMS LOT 속성	
--                ,DOC_NO                                               --MES문서번호
--                ,DOC_SEQNO                                            --MES문서순번
--                ,REQ_DIV                                              --요청구분	
--                ,STOR_LOC_FR							                            --저장위치(FROM)
--                ,ORDER_NO													--오더번호
--                ,ORDER_SEQNO												--오더순번
--                ,REGDATE                       			                  --등록일자
--                ,REGID                         			                  --등록자
--                ,UPDDATE                       			                  --수정일자
--                ,UPDID                         			                  --수정자
--         )
--         SELECT  VGBEL																								--WMS 참조문서 번호         
--                ,VGPOS                                    						--WMS 참조문서아이템
--                ,ifrwm002.IF_IFR_NO         
--                ,DLFL                                     						--삭제 지시자              
--                ,case when  LENGTH(STOR_LOC_TO) > 0 then SUBSTR(STOR_LOC_TO,1,4) else '' end --저장위치(TO)                   
--                ,MATNR                                    						--자재코드                
--                ,UNIT                                     						--단위                  
--                ,QTY                                      						--수량                  
--                ,LOTA02                                   						--플랜트                 
--                ,LOTA03                                   						--포장타입                
--                ,LOTA04                                   						--호기                  
--                ,LOTA05                                   						--
--                ,STCK_STA                                 						--재고상태                
--                ,LOTA07                                   						--주문번호(10)+아이템번호(6)MTO
--                ,NTN_CD                                   						--국가코드                
--                ,CRSPD_CD                                 						--거래처코드               
--                ,LOTA10                                   						--보유사유명               
--                ,PRDC_DT                                  						--제조일자                
--                ,RCVGDS_DT                                						--입고일자                
--                ,DSTBT_DDLIN                              						--유통기한(생리대, 기저귀, 물티슈) 
--                ,IND_BCD                                  						--개별바코드(협력업체바코드 공용)   
--                ,LOT_NO                                   						--LOT번호               
--                ,LOTA16                                   						--평량(PS)              
--                ,LOTA17                                   						--컨테이너 유형(PS)         
--                ,LOTA18                                   						--LOTA18              
--                ,LOTA19                                   						--LOTA19              
--                ,LOTA20                                   						--LOTA20              
--                ,STOK_KY                                  						--Stock key           
--                ,LOT_NUM                                  						--WMS LOT 속성 
--                ,DOC_NO                                               --MES문서번호
--                ,DOC_SEQNO                                            --MES문서순번											 										
--                ,'10'                                                  --요청구분->자재불출
--                ,ifrwm002.STOR_LOC_FROM                               --저장위치(FROM)
--                ,ORDER_NO												--오더번호
--                ,ORDER_SEQNO											--오더순번
--                ,sysdate                                              --생성일자
--                ,'IFRWM002'                                             --생성자  
--                ,null                                                 --수정일자
--                ,null                                                 --수정자
--         FROM TB_IFRWM002           
--         WHERE  IF_IFR_NO =  ifrwm002.IF_IFR_NO;                                                   
      END IF;
      --TB_INV001:공정재고
      --기본단위 체크 및 환산 22-07-24
      V_STD_UNIT := '';
       
DBMS_OUTPUT.PUT_LINE('2222_11111');
      SELECT NVL(UNIT,'') INTO V_STD_UNIT
      FROM TB_MAS001 
      WHERE WERKS = ifrwm002.WERKS
      AND MATNR = ifrwm002.MATNR;
      
      IF V_STD_UNIT = '' THEN
DBMS_OUTPUT.PUT_LINE('2222_33333333');
        o_msg_msg       := '[환산단위 확인필요]=>자재마스타 기본단위가 없습니다.';
        o_msg_code      := '-1' ;            
        RAISE E_EXCEPTION_USER;      
      END IF;
      
      IF IFRWM002.WERKS <> 'P100' THEN
      	V_STD_QTY := FN_CHG_UNIT(ifrwm002.MATNR,ifrwm002.WERKS,ifrwm002.UNIT,V_STD_UNIT,ifrwm002.QTY);
      ELSE
      	V_STD_QTY	:= IFRWM002.QTY;
	  	V_BS_WGT	:= TO_NUMBER(LTRIM(SUBSTR(IFRWM002.MATNR, 6, 3)));			--평량
	  	V_WLEN		:= TO_NUMBER(LTRIM(SUBSTR(IFRWM002.MATNR, 10, 4), '0'));	--가로
	  	V_VLEN		:= TO_NUMBER(LTRIM(SUBSTR(IFRWM002.MATNR, 14, 4), '0'));	--세로
	  	
	  	IF IFRWM002.UNIT = 'R' THEN
	  		V_QTY := IFRWM002.QTY * 500;	--매수 = 수량 * 500
	  	ELSE 
	  		V_QTY := IFRWM002.QTY;			
	  	END IF;
	  END IF;
	  
      IF V_STD_QTY = 0 THEN
DBMS_OUTPUT.PUT_LINE('2222_4444444');
        o_msg_msg       := '[환산단위 확인필요]=>단위환산 수량 없음';
        o_msg_code      := '-1' ;            
        RAISE E_EXCEPTION_USER;                  
      END IF;      
      
      --수량계산추가 22-09-02
      V_PLT_QTY     := FN_CHG_UNIT(ifrwm002.MATNR,ifrwm002.WERKS,ifrwm002.UNIT,'PAL',ifrwm002.QTY); 
      V_BOX_QTY     := FN_CHG_UNIT(ifrwm002.MATNR,ifrwm002.WERKS,ifrwm002.UNIT,'BOX',ifrwm002.QTY); 
      V_BAG_QTY     := FN_CHG_UNIT(ifrwm002.MATNR,ifrwm002.WERKS,ifrwm002.UNIT,'BAG',ifrwm002.QTY); 
      V_ROLLCNT_QTY := FN_CHG_UNIT(ifrwm002.MATNR,ifrwm002.WERKS,ifrwm002.UNIT,'M',ifrwm002.QTY);
      
      IF IFRWM002.WERKS = 'P100' THEN
      	IF IFRWM002.UNIT = 'KG' THEN
      		V_WGT_QTY	:= FN_CHG_UNIT(ifrwm002.MATNR,ifrwm002.WERKS,ifrwm002.UNIT,'KG',ifrwm002.QTY);  
      	ELSE
      		V_WGT_QTY	:= ROUND(V_QTY * (V_BS_WGT / 1000) * (V_WLEN / 1000) * (V_VLEN / 1000), 3);
      	END IF;
        IF IFRWM002.UNIT = 'R' THEN
        	V_EA_QTY	:= V_QTY;
        ELSE
        	V_EA_QTY	:= FN_CHG_UNIT(IFRWM002.MATNR,IFRWM002.WERKS,IFRWM002.UNIT,'EA',IFRWM002.QTY);
        END IF;
      ELSE
      	V_EA_QTY      := FN_CHG_UNIT(ifrwm002.MATNR,ifrwm002.WERKS,ifrwm002.UNIT,'EA',ifrwm002.QTY); 
      	V_WGT_QTY	:= FN_CHG_UNIT(ifrwm002.MATNR,ifrwm002.WERKS,ifrwm002.UNIT,'KG',ifrwm002.QTY);  
      END IF;  
      
      --20230112 여한진 PS 완제품불출요청시 작업지시 BOM에 LOT정보가 없을 시 추가  
      IF ifrwm002.WERKS = 'P100' THEN
	      BEGIN     
DBMS_OUTPUT.PUT_LINE('2222_222222');
			  SELECT WRK_ORDR_NO, WRK_ORDR_SEQNO, ORDER_ITM_NO, WMS_YN
			    INTO V_WRK_ORDR_NO, V_WRK_ORDR_SEQNO, V_ORDER_ITM_NO, V_WMS_YN
			    FROM TB_SCH020 ts 
			   WHERE WERKS = ifrwm002.WERKS
			     AND MATNR = ifrwm002.MATNR
			     AND ORDER_NO = ifrwm002.ORDER_NO
			     AND LOT_NO = ifrwm002.LOT_NO
			     AND ROWNUM = 1;
                
              V_BOM_CNT := 1;   
		  EXCEPTION
		  	WHEN NO_DATA_FOUND THEN
                BEGIN
                    SELECT WRK_ORDR_NO, WRK_ORDR_SEQNO, LPAD(MAX(ORDER_ITM_NO) + 10, 4, '0')--TO_NUMBER(MAX(ORDER_ITM_NO))
                      INTO V_WRK_ORDR_NO, V_WRK_ORDR_SEQNO, V_I_ORDER_ITM_NO
                      FROM TB_SCH020 ts 
                     WHERE WERKS = ifrwm002.WERKS
                       AND ORDER_NO = ifrwm002.ORDER_NO
                     GROUP BY WRK_ORDR_NO, WRK_ORDR_SEQNO;
                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        V_BOM_CNT := 0;
                END;
                    V_BOM_CNT := 0;
		  END;
          
		  IF V_BOM_CNT = 0 THEN
                  DBMS_OUTPUT.PUT_LINE('3333');
	    	IF ifrwm002.DLFL = 'A' THEN --정상 수신
                INSERT INTO TB_SCH020(WERKS, WRK_ORDR_NO, WRK_ORDR_SEQNO, MATNR, ORDER_NO, ORDER_ITM_NO, ORDER_BOM_QTY, UNIT, STOR_LOC_CD, LOT_NO, DLFL, WMS_YN, REGDATE, REGID)
				  			  SELECT WERKS, V_WRK_ORDR_NO, V_WRK_ORDR_SEQNO, MATNR, ORDER_NO, V_I_ORDER_ITM_NO, QTY, UNIT, STOR_LOC_TO, LOT_NO, 'N', 'Y', SYSDATE, 'IFRWM002'
				  				FROM TB_IFRWM002
				  			   WHERE IF_IFR_NO = ifrwm002.IF_IFR_NO;            
			END IF;
		  ELSE
		  	IF ifrwm002.DLFL = 'D' THEN --삭제 수신
			  	IF V_WMS_YN = 'Y' THEN
			  		DELETE 
			  		  FROM TB_SCH020 ts 
			  		 WHERE WERKS = ifrwm002.WERKS
			  		   AND WRK_ORDR_NO = V_WRK_ORDR_NO
			  		   AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
			     	   AND MATNR = ifrwm002.MATNR
			     	   AND ORDER_NO = ifrwm002.ORDER_NO
			     	   AND ORDER_ITM_NO = V_ORDER_ITM_NO;
			  	END IF;
		  	END IF;
		  END IF;
		 BEGIN
             SELECT ORDER_DIV	INTO V_ORDER_DIV
               FROM TB_SCH019
              WHERE WRK_ORDR_NO = V_WRK_ORDR_NO
                AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO;
         EXCEPTION 
            WHEN NO_DATA_FOUND THEN
                V_ORDER_DIV := '';
         END;
 	  END IF;
 	 
 	  /*--22-09-06 중요!!! TB_INV001에 PK4개로 반드시 존재여부 체크해야함.
      --WERKS,MATNR,IND_BCD로 존재여부 체크했는데 동일바코드가 다른 저장위치로 2개 존재시 UPDATE되면 KEY중복에러 발생된다.      
      SELECT COUNT(WERKS) INTO V_CNT 
      FROM TB_INV001 
      WHERE WERKS = ifrwm002.WERKS 
      --AND STOR_LOC_CD = ifrwm002.STOR_LOC_TO  --22-09-07 TB_INV001의 개별바코드는 유일한것으로 업무결정하여 주석처리 됨.
      AND MATNR = ifrwm002.MATNR
      AND IND_BCD = ifrwm002.IND_BCD; 
                                

      --공정재고가 존재할시 기존재고에 합치는 요청 적용. 22-06-14 
      --KHJ 22-09-07 TB_INV001의 개별바코드는 유일한것으로 업무결정됨.
      --KHJ 22-09-15 TB_INV001의 개별바코드 존재여부 체크하면 기존 데이타가 존재시 창고를 변경해버리게 되는 문제점이 존재 한다.      
      IF V_CNT > 1 THEN
        o_msg_msg       := '[데이타 확인필요]=>MES재고에 개별바코드가 1개이상 발견되었습니다.';
        o_msg_code      := '-1' ;            
        RAISE E_EXCEPTION_USER;                  
      END IF; */
 	 
      BEGIN
	      SELECT STCK_QTY INTO V_STCK_QTY
	        FROM TB_INV001 ti
	       WHERE WERKS = ifrwm002.WERKS 
	         AND MATNR = ifrwm002.MATNR
	         AND IND_BCD = ifrwm002.IND_BCD;
             
          V_STCKCNT := 1;
	  EXCEPTION
	  	WHEN NO_DATA_FOUND THEN
	  		V_STCKCNT := 0;
	  END;
      IF V_STCKCNT = 1 THEN
        IF ifrwm002.DLFL = 'D' THEN --삭제된것으로 수신되었을때 처리 추가 22-06-22
        	IF V_STCK_QTY > 0 THEN 
              UPDATE TB_INV001
                 SET STCK_QTY  = NVL(STCK_QTY,0) - NVL(V_STD_QTY,0)              
                 	,PLT_QTY   = NVL(PLT_QTY,0) - NVL(V_PLT_QTY,0)
                 	,BOX_QTY   = NVL(BOX_QTY,0) - NVL(V_BOX_QTY,0)
                 	,BAG_QTY   = NVL(BAG_QTY,0) - NVL(V_BAG_QTY,0)
                 	,EA_QTY    = NVL(EA_QTY,0) - NVL(V_EA_QTY,0)
                 	,ROLLCNT   = NVL(ROLLCNT,0) - NVL(V_ROLLCNT_QTY,0)
                 	,WGT       = NVL(WGT,0) - NVL(V_WGT_QTY,0)       
                 	,UPDDATE = sysdate                                        --수정일자
                 	,UPDID = 'IFRWM002'                                         --수정자             
               WHERE WERKS = ifrwm002.WERKS 
               --AND STOR_LOC_CD = ifrwm002.STOR_LOC_TO  --22-09-07 TB_INV001의 개별바코드는 유일한것으로 업무결정하여 주석처리 됨.
              	 AND MATNR = ifrwm002.MATNR
              	 AND IND_BCD = ifrwm002.IND_BCD;
            ELSE
DBMS_OUTPUT.PUT_LINE('2222_555555');
            	o_msg_msg       := '[데이타 확인필요]=>이미 공정에 투입되고 창고에 남아있는 수량이 없습니다.';
		        o_msg_code      := '-1' ;            
		        RAISE E_EXCEPTION_USER;			
            END IF;
        ELSE
                  DBMS_OUTPUT.PUT_LINE('4444');
          UPDATE TB_INV001
             SET STOR_LOC_CD = ifrwm002.STOR_LOC_TO                --YSH 2022.09.14
              --ZP12 = 리커팅->수재단 대기창고(L2400), ZP13 = 리패킹->포장 대기창고(L2600), ZP14 = 판매원지->슬리터 대기창고(L2200)
             ,LOC_CD = DECODE(V_ORDER_DIV, 'ZP12', 'L2400', 'ZP13', 'L2600', 'ZP14', 'L2200', NULL)
             ,STCK_QTY = NVL(STCK_QTY,0) + NVL(V_STD_QTY,0)
             ,PLT_QTY   = NVL(PLT_QTY,0) + NVL(V_PLT_QTY,0)
             ,BOX_QTY   = NVL(BOX_QTY,0) + NVL(V_BOX_QTY,0)
             ,BAG_QTY   = NVL(BAG_QTY,0) + NVL(V_BAG_QTY,0)
             ,EA_QTY    = NVL(EA_QTY,0) + NVL(V_EA_QTY,0)
             ,ROLLCNT   = NVL(ROLLCNT,0) + NVL(V_ROLLCNT_QTY,0)
             ,WGT       = NVL(WGT,0) + NVL(V_WGT_QTY,0)
             ,STCK_KY 	= ifrwm002.STOK_KY
             ,LOT_NUM   = ifrwm002.LOT_NUM
             ,STCK_STA = ifrwm002.STCK_STA
             ,WRK_ORDR_NO = V_WRK_ORDR_NO                                  
             ,WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
             ,ORDER_NO = ifrwm002.ORDER_NO
             ,UPDDATE = sysdate                                        --수정일자
             ,UPDID = 'IFRWM002'                                         --수정자             
          WHERE WERKS = ifrwm002.WERKS 
          --AND STOR_LOC_CD = ifrwm002.STOR_LOC_TO  --22-09-07 TB_INV001의 개별바코드는 유일한것으로 업무결정하여 주석처리 됨.
          AND MATNR = ifrwm002.MATNR
          AND IND_BCD = ifrwm002.IND_BCD;                          
        END IF;                            
      ELSE
                  DBMS_OUTPUT.PUT_LINE('5555');
             INSERT INTO TB_INV001 
             (       DLFL                          												--삭제 지시자(A:출고, D:삭제)             
										,STOR_LOC_CD                   							--저장위치
										,LOC_CD                          						--로케이션	
										,MATNR                         							--제품코드                           
										,UNIT                          							--단위                             
										,STCK_QTY                      							--재고수량                           
										,WERKS                         							--플랜트코드                          
										,STCK_STA                      							--재고상태                           
										,SUPY_CD                       							--공급업체코드                         
										,PRD_DT                       							--제조(생산)일자                       
										,IND_BCD                       							--개별바코드                          
										,LOT_NO                        							--LOT NO                         
										,STCK_KY                       							--LOTNUM WMS KEY(저장키)            
										,LOT_NUM                       							--LOTNUM WMS KEY(WMS LOT 속성 KEY) 		
										,PLT_QTY
										,BOX_QTY
										,BAG_QTY
										,EA_QTY
										,ROLLCNT
										,WGT
										,WRK_ORDR_NO						--작업지시번호
										,WRK_ORDR_SEQNO						--작업지시순번
										,ORDER_NO							--오더번호
										
                    ,REGDATE                       			                  --등록일자
                    ,REGID                         			                  --등록자
                    ,UPDDATE                       			                  --수정일자
                    ,UPDID                         			                  --수정자
             )
             SELECT  DLFL                     														--삭제 지시자(C:출고, D:삭제)                          
                    ,case when  LENGTH(STOR_LOC_TO) > 0 then SUBSTR(STOR_LOC_TO,1,4) else '' end 	--저장위치(TO)
                    ,DECODE(V_ORDER_DIV, 'ZP12', 'L2400', 'ZP13', 'L2600', 'ZP14', 'L2200', NULL) 	--로케이션       										                                        
										,MATNR                    									--제품코드                                        
										,V_STD_UNIT                     							--단위(기본단위적용) 22-07-24                                          
										,V_STD_QTY                      							--재고수량(기본단위적용) 22-07-24                                         
										,LOTA02                   									--플랜트코드                                       
										,STCK_STA                 									--재고상태                                        
										,CRSPD_CD                 									--공급업체코드                                      
										,PRDC_DT                  									--제조(생산)일자                                    
										,IND_BCD                  									--개별바코드                                       
										,LOT_NO                   									--LOT NO                                      
										,STOK_KY                  									--LOTNUM WMS KEY(저장키)                         
										,LOT_NUM                  									--LOTNUM WMS KEY(WMS LOT 속성 KEY)  
										,V_PLT_QTY
										,V_BOX_QTY
										,V_BAG_QTY
										,V_EA_QTY
										,V_ROLLCNT_QTY
										,V_WGT_QTY
										,V_WRK_ORDR_NO						--작업지시번호
										,V_WRK_ORDR_SEQNO					--작업지시순번
										,ORDER_NO							--오더번호
										
                    ,sysdate                                              --생성일자
                    ,'IFRWM002'                                             --생성자  
                    ,null                                                 --수정일자
                    ,null                                                 --수정자
             FROM TB_IFRWM002           
             WHERE  IF_IFR_NO =  ifrwm002.IF_IFR_NO;                                                   
      END IF;

      o_msg_msg       := '자재_완제품 입고(불출) 정보가 수신되었습니다.';
      o_msg_code      := '0' ;
      
      UPDATE  TB_IFRWM002
      SET     IF_STATUS   =  'S'                                                 --I/F상태, N:신규, S:성공, E:오류               
            , IF_SET_DATE =  sysdate                                            --데이터 처리시간(MES I/F 테이블 → MES 운영테이블) 
            , IF_ERR_MESS =  o_msg_msg                                          --데이터 처리 결과 Message(Oracle)      
            --, IF_MES_KEY =  i_IF_MES_KEY                    
      WHERE  IF_IFR_NO =  ifrwm002.IF_IFR_NO   ;

      EXCEPTION
            
            WHEN E_EXCEPTION_USER THEN
                
                  DBMS_OUTPUT.PUT_LINE('6666');
                  DBMS_OUTPUT.PUT_LINE(o_msg_msg);
                  ROLLBACK;

                  UPDATE  TB_IFRWM002
                  SET     IF_STATUS   =  'E'                                      --I/F상태, N:신규, S:성공, E:오류               
                        , IF_SET_DATE =  sysdate                                --데이터 처리시간(MES I/F 테이블 → MES 운영테이블) 
                        , IF_ERR_MESS =  o_msg_msg                              --데이터 처리 결과 Message(Oracle)                                  
                  WHERE  IF_IFR_NO =  ifrwm002.IF_IFR_NO   ;
                  Commit ;
                  
                  RETURN;
                        
            WHEN OTHERS THEN
                 
                  DBMS_OUTPUT.PUT_LINE('ERR_MSG : ' || SQLERRM);
                  DBMS_OUTPUT.PUT_LINE('7777');
                  --o_msg_msg  :=  'SP_IF_GET_IFRWM002=>' || '자재_완제품 입고(불출) 정보 수신 중 오류가 발생하였습니다.' || ',' || SQLERRM ;
                  o_msg_code := '-1' ;
                  DBMS_OUTPUT.PUT_LINE (o_msg_msg );
                  ROLLBACK;

                  UPDATE  TB_IFRWM002
                  SET     IF_STATUS   =  'E'                                      --I/F상태, N:신규, S:성공, E:오류               
                        , IF_SET_DATE =  sysdate                                --데이터 처리시간(MES I/F 테이블 → MES 운영테이블) 
                        , IF_ERR_MESS =  o_msg_msg                              --데이터 처리 결과 Message(Oracle)                                      
                  WHERE  IF_IFR_NO =  ifrwm002.IF_IFR_NO   ;
                  Commit ;
                  
                  RETURN;                  
      END;
    END LOOP;

    IF o_msg_code = 0 THEN
      commit;
    END IF;

    EXCEPTION
      WHEN OTHERS THEN
                  DBMS_OUTPUT.PUT_LINE('ERR_MSG : ' || SQLERRM);
        IF o_msg_code = 0 THEN      
          o_msg_code      := '-1' ;
          o_msg_msg       := 'SP_IF_GET_IFRWM002=>' || '자재_완제품 입고(불출) 정보 수신 중 MAIN에서 오류가 발생하였습니다.' || ',' || to_char(SQLCODE) || ',' || SQLERRM ;
          DBMS_OUTPUT.PUT_LINE(o_msg_msg);
          rollback ;
        END IF;        

  END; 
END;
/
