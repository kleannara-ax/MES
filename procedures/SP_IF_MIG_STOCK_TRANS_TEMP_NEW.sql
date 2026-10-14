
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_IF_MIG_STOCK_TRANS_TEMP_NEW" (   
 i_WERKS            IN    VARCHAR2    /*  Common code key               */
,o_msg_CODE         OUT   VARCHAR2
,o_msg_MSG          OUT   VARCHAR2
) AS
/*==============================================================================
 * PROGRAM ID    : 마이그레이션
 * PROGRAM NAME  : 초기재고 SETUP(ALL)
 * VERSION       : 1.0.0
 * DESCRIPTION   : 초기재고 SETUP(ALL)
 *                 
 * AUTHOR NAME   : 강현주
 * CREATE DATE   : 2022/09/02
 * SYSTEM NAME   : MES
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}	<생략가능>
 * SUB PROCEDURE : {아휘 프로시저 명칭 기술}		<생략가능>
 * SUB PACKAGES  : {하위 패키지 기술}			<생략가능>
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술}	<생략가능>
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/09/02    1.0.0   강현주         Initial Version 
 * 2022/09/13    1.0.1   강현주         작업지시 생성(점보롤,밀롤,재단,포장), 생산실적 생성(PS)
 * 2022/09/14    1.0.2   강현주         재단 단위 'R' -> 'EA'로 계산
 * 2022/09/14    1.0.2   강현주         오더번호,판매문서번호,거래처 SUBSTR 추가
 *==============================================================================
 * 관련 테이블
 * - [TX_BASE_INIT_TEMP] : (.R..)초기재고데이타                                
 * - [TB_SCH015_TEMP] : (.I.U.)작업지시 점보롤
 * - [TB_SCH016_TEMP] : (.I.U.)작업지시 밀롤
 * - [TB_SCH017_TEMP] : (.I.U.)작업지시 재단
 * - [TB_SCH018_TEMP] : (.I.U.)작업지시 포장
 * - [TB_WRK002_TEMP] : (.I.)생산실적(PS)
 * - [TB_INV001_TEMP] : (.I.)공정재고
 *=============================================================================*/
            
  
  E_EXCEPTION_USER  EXCEPTION;                        -- 사용자 에러 처리용 변수선언 영역 
                                                                                   
  V_CNT             NUMBER          := 0;             -- 카운트(존재여부체크)
  
  V_DATA_CNT        NUMBER          := 0;             -- 카운트(존재여부체크)  
  
  V_STD_UNIT  VARCHAR2(10);
  V_STD_QTY   NUMBER;
  
  V_PLT_QTY     NUMBER        DEFAULT 0; 
  V_BOX_QTY     NUMBER        DEFAULT 0; 
  V_BAG_QTY     NUMBER        DEFAULT 0; 
  V_EA_QTY      NUMBER        DEFAULT 0; 
 
  V_WO_NO       VARCHAR2(50)    := '';      -- 작업지시번호 
  V_WO_SEQ      NUMBER          := 1;      --작업지시순번  
   
BEGIN
  DECLARE
    CURSOR  CUR_DATA IS
      SELECT
  			 WERKS     						AS WERKS       								--플랜트       
  			,MACH_CD              AS MACH_CD                    --설비코드      
  			,STOR_LOC_CD          AS STOR_LOC_CD                --저장위치      
  			,LOC_CD               AS LOC_CD                     --로케이션      
  			,MATNR                AS MATNR                      --자재코드      
  			,LOT_NO               AS LOT_NO                     --LOT번호     
  			,IND_BCD              AS IND_BCD                    --개별바코드     
  			,SUBSTR(ORDER_NO,-10) AS ORDER_NO                   --오더번호      
  			,MACHINE              AS MACHINE                    --생산호기      
  			,PROC_CD              AS PROC_CD                    --공정        
  			,PRD_DT               AS PRD_DT                     --생산일자      
  			,PRFM_DT              AS PRFM_DT                    --제조일자      
  			,DSTBT_DDLIN          AS DSTBT_DDL                  --유통기간      
  			,PCODE                AS PCODE                      --지종        
  			,UNIT                 AS UNIT                       --단위        
  			,ROLLCNT              AS ROLLCNT                    --실적_권치수    
  			,PCNT                 AS PCNT                       --실적_연수_REAM
  			,SCNT                 AS SCNT                       --실적_속당매수   
  			,MCNT                 AS MCNT                       --실적_속수     
  			,WGT                  AS WGT                        --실적_중량     
  			,CORE                 AS CORE                       --지관        
  			,BS_WGT               AS BS_WGT                     --평량        
  			,PACKTYPE             AS PACKTYPE                   --포장타입      
  			,CONTYPE              AS CONTYPE                    --컨테이너유형    
  			,WLEN                 AS WLEN                       --가로길이      
  			,VLEN                 AS VLEN                       --세로길이      
  			,WIDTH                AS WIDTH                      --지폭        
  			,SUBSTR(VBELN,-8)     AS VBELN                      --판매문서번호    
  			,POSNR                AS POSNR                      --판매문서항목번호  
  			,SUBSTR(KUNNR,-6)     AS KUNNR                      --판매처_MTO   
  			,MRG_YN               AS MRG_YN                     --라벨병합여부    
  			,WRK_CLASS            AS WRK_CLASS                  --작업반       
  			,WRK_SHIFT            AS WRK_SHIFT                  --작업조       
  			,CASE WHEN UNIT = 'KG' THEN WGT
              WHEN UNIT = 'EA' THEN NVL(PCNT,0)*500
              WHEN UNIT = 'R'  THEN NVL(PCNT,0)
              ELSE 0
         END AS STCK_QTY                                    --PLT수량,BOX수량,BAG수량,EA수량 계산하기 위한 수량
        ,STK_FLAG                                           --재고구분                                                   
      FROM TX_BASE_INIT_TEMP                                           
      WHERE IF_YN IN ('N')
      AND WERKS IN(i_WERKS); 


    
  BEGIN

    o_msg_msg       := '실행완료';
    o_msg_code      := '0' ;
    

        
    FOR cur_row in CUR_DATA loop
      BEGIN 
      
        o_msg_msg       := '실행완료';
        o_msg_code      := '0' ;
        
        V_WO_NO         := '';      -- 작업지시번호 초기화 
        
        --★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★           
        --수량 계산 22-09-14 V_STD_UNIT, V_STD_QTY를 먼저 계산한다.(재단공정은 R->EA로 변환 해야 함.)
        --★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★           
        IF cur_row.PROC_CD = 'CA' OR cur_row.PROC_CD = 'CB' THEN
          V_STD_UNIT  := 'EA';
          V_STD_QTY   := cur_row.PCNT * 500;          
        ELSE
          V_STD_UNIT  := cur_row.UNIT;
          V_STD_QTY   := cur_row.STCK_QTY;
        END IF;
        --★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★
        --단위환산
        --####>>FN_CHG_UNIT에서 TB_MAS001에 데이타가 없을시 ERROR발생됨........
        --★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★         
        BEGIN
          V_PLT_QTY     := FN_CHG_UNIT(cur_row.MATNR,cur_row.WERKS,V_STD_UNIT,'PAL',V_STD_QTY); 
          V_BOX_QTY     := FN_CHG_UNIT(cur_row.MATNR,cur_row.WERKS,V_STD_UNIT,'BOX',V_STD_QTY); 
          V_BAG_QTY     := FN_CHG_UNIT(cur_row.MATNR,cur_row.WERKS,V_STD_UNIT,'BAG',V_STD_QTY); 
          V_EA_QTY      := FN_CHG_UNIT(cur_row.MATNR,cur_row.WERKS,V_STD_UNIT,'EA',V_STD_QTY);
        EXCEPTION
        WHEN OTHERS THEN 
          V_PLT_QTY     := 0; 
          V_BOX_QTY     := 0; 
          V_BAG_QTY     := 0; 
          V_EA_QTY      := 0;                
        END;                         
        --★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★                



          
        --1.작업지시 생성하기
        IF cur_row.WERKS = 'P100' THEN
          --JA:점보롤, MA:밀롤, SA:슬리터, CA:재단, PB:포장
          IF cur_row.PROC_CD = 'JA' AND LENGTHB(cur_row.ORDER_NO) > 0 AND LENGTHB(cur_row.MACH_CD) > 0 THEN 
            --1.1오더번호에 해당하는 작업지시가 존재하는지 체크 함.
            SELECT count(1) INTO V_CNT
            FROM TX_SCH015_TEMP
            WHERE ORDER_NO = cur_row.ORDER_NO;

            IF V_CNT > 0 THEN
              SELECT WRK_ORDR_NO INTO V_WO_NO 
              FROM TX_SCH015_TEMP
              WHERE ORDER_NO = cur_row.ORDER_NO;
              
              UPDATE TX_SCH015_TEMP
              SET PRFM_QTY = NVL(PRFM_QTY,0) + V_STD_QTY
                 ,WRK_ORDR_QTY = NVL(WRK_ORDR_QTY,0) + V_STD_QTY
                 ,BS_WGT = NVL(BS_WGT,0) + cur_row.BS_WGT
                 ,TOT_WGT = NVL(TOT_WGT,0) + cur_row.WGT                
                 ,UPDDATE = sysdate
                 ,UPDID = 'STOCK_TRANS_TEMP'  
              WHERE WRK_ORDR_NO = V_WO_NO
              AND WRK_ORDR_SEQNO = V_WO_SEQ;   
            ELSE 
              SP_GET_DOC_SEQ('WOJA',cur_row.PRD_DT,V_WO_NO);   --점보롤
                      
              INSERT INTO TX_SCH015_TEMP(
                WRK_ORDR_NO
               ,WRK_ORDR_SEQNO
               ,WERKS
               ,ORDER_NO
               ,WRK_SEQNO
               ,WRK_ORDR_QTY
               ,ORDR_GEN_DT
               ,PRD_REQ_DT
               ,PRFM_QTY
               ,COMP_YN
               ,USE_YN
               ,MATNR
               ,BS_WGT
               ,UNIT
               ,PCODE
               ,TOT_WGT 
               ,DLFL
               ,PRD_STR_DTM
               ,PRD_END_DTM  
               ,MACHINE  
               ,TO_MACHINE                          
               ,REGDATE
               ,REGID
              )VALUES(
                V_WO_NO
               ,V_WO_SEQ
               ,cur_row.WERKS
               ,cur_row.ORDER_NO
               ,V_WO_SEQ
               ,V_STD_QTY             
               ,cur_row.PRD_DT
               ,cur_row.PRD_DT           
               ,V_STD_QTY
               ,'Y'
               ,'Y'
               ,cur_row.MATNR
               ,cur_row.BS_WGT
               ,V_STD_UNIT
               ,cur_row.PCODE
               ,cur_row.WGT 
               ,'N'
               ,cur_row.PRD_DT||'000000'   
               ,cur_row.PRD_DT||'000000' 
               ,cur_row.MACHINE  
               ,cur_row.MACHINE                             
               ,sysdate
               ,'STOCK_TRANS_TEMP'         
              );
            END IF;
          ELSIF (cur_row.PROC_CD = 'MA'  OR cur_row.PROC_CD = 'SA') AND LENGTHB(cur_row.ORDER_NO) > 0 AND LENGTHB(cur_row.MACH_CD) > 0 THEN 
            --1.1오더번호에 해당하는 작업지시가 존재하는지 체크 함.
            SELECT count(1) INTO V_CNT
            FROM TX_SCH016_TEMP
            WHERE ORDER_NO = cur_row.ORDER_NO;

            IF V_CNT > 0 THEN
              SELECT WRK_ORDR_NO INTO V_WO_NO 
              FROM TX_SCH016_TEMP
              WHERE ORDER_NO = cur_row.ORDER_NO;
                      
              UPDATE TX_SCH016_TEMP
              SET PRFM_QTY = NVL(PRFM_QTY,0) + V_STD_QTY
                 ,WRK_ORDR_QTY = NVL(WRK_ORDR_QTY,0) + V_STD_QTY            
                 ,BS_WGT = NVL(BS_WGT,0) + cur_row.BS_WGT
                 ,TOT_WGT = NVL(TOT_WGT,0) + cur_row.WGT                
                 ,UPDDATE = sysdate
                 ,UPDID = 'STOCK_TRANS_TEMP'                 
              WHERE WRK_ORDR_NO = V_WO_NO
              AND WRK_ORDR_SEQNO = V_WO_SEQ;   
            ELSE 
              SP_GET_DOC_SEQ('WOMA',cur_row.PRD_DT,V_WO_NO);  --밀롤,슬리터
                      
              INSERT INTO TX_SCH016_TEMP(
                WRK_ORDR_NO
               ,WRK_ORDR_SEQNO
               ,WERKS
               ,ORDER_NO
               ,WRK_SEQNO
               ,WRK_ORDR_QTY              
               ,ORDR_GEN_DT
               ,PRD_REQ_DT
               ,PRFM_QTY
               ,COMP_YN
               ,USE_YN
               ,MATNR
               ,BS_WGT
               ,UNIT
               ,PCODE
               ,TOT_WGT 
               ,VBELN
               ,POSNR
               ,KUNNR
               ,DLFL 
               ,PRD_STR_DTM
               ,PRD_END_DTM 
               ,ORDER_DIV
               ,ORDER_DIV_NM   
               ,MACHINE  
               ,TO_MACHINE                                    
               ,REGDATE
               ,REGID
              )VALUES(
                V_WO_NO
               ,V_WO_SEQ
               ,cur_row.WERKS
               ,cur_row.ORDER_NO
               ,V_WO_SEQ
               ,V_STD_QTY               
               ,cur_row.PRD_DT
               ,cur_row.PRD_DT           
               ,V_STD_QTY
               ,'Y'
               ,'Y'
               ,cur_row.MATNR
               ,cur_row.BS_WGT
               ,V_STD_UNIT
               ,cur_row.PCODE
               ,cur_row.WGT
               ,cur_row.VBELN
               ,cur_row.POSNR 
               ,cur_row.KUNNR
               ,'N'  
               ,cur_row.PRD_DT||'000000'   
               ,cur_row.PRD_DT||'000000' 
               ,'ZP11' 
               ,'제지 표준생산오더' 
               ,cur_row.MACHINE 
               ,cur_row.MACHINE                                        
               ,sysdate
               ,'STOCK_TRANS_TEMP'                       
              );
            END IF;          
          ELSIF (cur_row.PROC_CD = 'CA'  OR cur_row.PROC_CD = 'CB') AND LENGTHB(cur_row.ORDER_NO) > 0 AND LENGTHB(cur_row.MACH_CD) > 0 THEN  
            --1.1오더번호에 해당하는 작업지시가 존재하는지 체크 함.
            SELECT count(1) INTO V_CNT
            FROM TX_SCH017_TEMP
            WHERE ORDER_NO = cur_row.ORDER_NO
            AND NVL(MAN_CUT_YN,'@') <> 'X';           

            IF V_CNT > 0 THEN
              SELECT WRK_ORDR_NO INTO V_WO_NO 
              FROM TX_SCH017_TEMP
              WHERE ORDER_NO = cur_row.ORDER_NO
              AND NVL(MAN_CUT_YN,'@') <> 'X';  
              
              
              UPDATE TX_SCH017_TEMP
              SET PRFM_QTY = NVL(PRFM_QTY,0) + V_STD_QTY
                 ,WRK_ORDR_QTY = NVL(WRK_ORDR_QTY,0) + V_STD_QTY            
                 ,BS_WGT = NVL(BS_WGT,0) + cur_row.BS_WGT
                 ,TOT_WGT = NVL(TOT_WGT,0) + cur_row.WGT                              
                 ,UPDDATE = sysdate
                 ,UPDID = 'STOCK_TRANS_TEMP'                 
              WHERE WRK_ORDR_NO = V_WO_NO
              AND WRK_ORDR_SEQNO = V_WO_SEQ;   
            ELSE 
              SP_GET_DOC_SEQ('WOCA',cur_row.PRD_DT,V_WO_NO);   --재단  
                                
              INSERT INTO TX_SCH017_TEMP(
                WRK_ORDR_NO
               ,WRK_ORDR_SEQNO
               ,WERKS
               ,ORDER_NO
               ,WRK_SEQNO
               ,WRK_ORDR_QTY             
               ,ORDR_GEN_DT
               ,PRD_REQ_DT
               ,PRFM_QTY
               ,COMP_YN
               ,USE_YN
               ,MATNR
               ,BS_WGT
               ,UNIT
               ,PCODE
               ,TOT_WGT 
               ,VBELN
               ,POSNR
               ,VLEN
               ,WLEN
               ,KUNNR
               ,PACKTYPE             
               ,DLFL 
               ,PRD_STR_DTM
               ,PRD_END_DTM 
               ,ORDER_DIV
               ,ORDER_DIV_NM
               ,MACHINE  
               ,TO_MACHINE                                         
               ,REGDATE
               ,REGID
              )VALUES(
                V_WO_NO
               ,V_WO_SEQ
               ,cur_row.WERKS
               ,cur_row.ORDER_NO
               ,V_WO_SEQ
               ,V_STD_QTY              
               ,cur_row.PRD_DT
               ,cur_row.PRD_DT           
               ,V_STD_QTY
               ,'Y'
               ,'Y'
               ,cur_row.MATNR
               ,cur_row.BS_WGT
               ,V_STD_UNIT
               ,cur_row.PCODE
               ,cur_row.WGT
               ,cur_row.VBELN
               ,cur_row.POSNR 
               ,cur_row.VLEN
               ,cur_row.WLEN 
               ,cur_row.KUNNR
               ,cur_row.PACKTYPE
               ,'N'   
               ,cur_row.PRD_DT||'000000'   
               ,cur_row.PRD_DT||'000000' 
               ,'ZP11' 
               ,'제지 표준생산오더'   
               ,cur_row.MACHINE  
               ,cur_row.MACHINE                                       
               ,sysdate
               ,'STOCK_TRANS_TEMP'                    
              );
            END IF;                    
          ELSIF (cur_row.PROC_CD = 'PB'  OR cur_row.PROC_CD = 'PC') AND LENGTHB(cur_row.ORDER_NO) > 0 AND LENGTHB(cur_row.MACH_CD) > 0 THEN 
            --1.1오더번호에 해당하는 작업지시가 존재하는지 체크 함.
            SELECT count(1) INTO V_CNT
            FROM TX_SCH018_TEMP
            WHERE ORDER_NO = cur_row.ORDER_NO;

            IF V_CNT > 0 THEN
              SELECT WRK_ORDR_NO INTO V_WO_NO 
              FROM TX_SCH018_TEMP
              WHERE ORDER_NO = cur_row.ORDER_NO;
              
              UPDATE TX_SCH018_TEMP
              SET PRFM_QTY = NVL(PRFM_QTY,0) + V_STD_QTY
                 ,WRK_ORDR_QTY = NVL(WRK_ORDR_QTY,0) + V_STD_QTY            
                 ,BS_WGT = NVL(BS_WGT,0) + cur_row.BS_WGT
                 ,TOT_WGT = NVL(TOT_WGT,0) + cur_row.WGT                
                 ,UPDDATE = sysdate
                 ,UPDID = 'STOCK_TRANS_TEMP'                 
              WHERE WRK_ORDR_NO = V_WO_NO
              AND WRK_ORDR_SEQNO = V_WO_SEQ;   
            ELSE 
              SP_GET_DOC_SEQ('WOPA',cur_row.PRD_DT,V_WO_NO);   --포장              
                                
              INSERT INTO TX_SCH018_TEMP(
                WRK_ORDR_NO
               ,WRK_ORDR_SEQNO
               ,WERKS
               ,ORDER_NO
               ,WRK_SEQNO
               ,WRK_ORDR_QTY             
               ,ORDR_GEN_DT
               ,PRD_REQ_DT
               ,PRFM_QTY
               ,COMP_YN
               ,USE_YN
               ,MATNR
               ,BS_WGT
               ,UNIT
               ,PCODE
               ,TOT_WGT 
               ,VBELN
               ,POSNR
               ,VLEN
               ,WLEN
               ,DLFL 
               ,PRD_STR_DTM
               ,PRD_END_DTM 
               ,ORDER_DIV
               ,ORDER_DIV_NM 
               ,MACHINE  
               ,TO_MACHINE  
               ,CON_TYPE
               ,PACKTYPE                                      
               ,REGDATE
               ,REGID
              )VALUES(
                V_WO_NO
               ,V_WO_SEQ
               ,cur_row.WERKS
               ,cur_row.ORDER_NO
               ,V_WO_SEQ
               ,V_STD_QTY             
               ,cur_row.PRD_DT
               ,cur_row.PRD_DT           
               ,V_STD_QTY
               ,'Y'
               ,'Y'
               ,cur_row.MATNR
               ,cur_row.BS_WGT
               ,V_STD_UNIT
               ,cur_row.PCODE
               ,cur_row.WGT
               ,cur_row.VBELN
               ,cur_row.POSNR 
               ,cur_row.VLEN
               ,cur_row.WLEN 
               ,'N'  
               ,cur_row.PRD_DT||'000000'   
               ,cur_row.PRD_DT||'000000' 
               ,'ZP11' 
               ,'제지 표준생산오더' 
               ,cur_row.MACHINE  
               ,cur_row.MACHINE 
               ,cur_row.CONTYPE
               ,cur_row.PACKTYPE                                           
               ,sysdate
               ,'STOCK_TRANS_TEMP'                    
              ); 
            END IF;                   
          END IF;
        ELSE --HL삽입
          IF cur_row.PROC_CD = 'AA' AND LENGTHB(cur_row.ORDER_NO) > 0 AND LENGTHB(cur_row.MACH_CD) > 0 THEN 
            --1.1오더번호에 해당하는 작업지시가 존재하는지 체크 함.
            SELECT count(1) INTO V_CNT
            FROM TX_SCH011_TEMP
            WHERE ORDER_NO = cur_row.ORDER_NO;

            IF V_CNT > 0 THEN
              SELECT WRK_ORDR_NO INTO V_WO_NO 
              FROM TX_SCH011_TEMP
              WHERE ORDER_NO = cur_row.ORDER_NO;
              
              UPDATE TX_SCH011_TEMP
              SET PRFM_QTY = NVL(PRFM_QTY,0) + V_STD_QTY
                 ,WRK_ORDR_QTY = NVL(WRK_ORDR_QTY,0) + V_STD_QTY                         
                 ,UPDDATE = sysdate
                 ,UPDID = 'STOCK_TRANS_TEMP'                 
              WHERE WRK_ORDR_NO = V_WO_NO
              AND WRK_ORDR_SEQNO = V_WO_SEQ;   
            ELSE 
              SP_GET_DOC_SEQ('WOAA',cur_row.PRD_DT,V_WO_NO);   --포장              
                                
              INSERT INTO TX_SCH011_TEMP(
                WRK_ORDR_NO
               ,WRK_ORDR_SEQNO
               ,WERKS
               ,ORDER_NO
               ,WRK_SEQNO
               ,WRK_ORDR_QTY             
               ,ORDR_GEN_DT
               ,PRD_REQ_DT
               ,PRFM_QTY
               ,COMP_YN
               ,USE_YN
               ,MATNR
               ,UNIT
               ,VBELN
               ,POSNR
               ,DLFL 
               ,PRD_STR_DTM
               ,PRD_END_DTM 
               ,ORDER_DIV
               ,ORDER_DIV_NM 
               ,MACHINE  
               ,TO_MACHINE 
               ,MACH_CD                                      
               ,REGDATE
               ,REGID
              )VALUES(
                V_WO_NO
               ,V_WO_SEQ
               ,cur_row.WERKS
               ,cur_row.ORDER_NO
               ,V_WO_SEQ
               ,V_STD_QTY             
               ,cur_row.PRD_DT
               ,cur_row.PRD_DT           
               ,V_STD_QTY
               ,'Y'
               ,'Y'
               ,cur_row.MATNR
               ,V_STD_UNIT
               ,cur_row.VBELN
               ,cur_row.POSNR  
               ,'N'  
               ,cur_row.PRD_DT||'000000'   
               ,cur_row.PRD_DT||'000000' 
               ,'ZP21' 
               ,'화장지 표준생산오더' 
               ,cur_row.MACHINE  
               ,cur_row.MACHINE 
               ,cur_row.MACH_CD                                           
               ,sysdate
               ,'STOCK_TRANS_TEMP'                    
              ); 
            END IF;
          ELSIF cur_row.PROC_CD = 'RA' AND LENGTHB(cur_row.ORDER_NO) > 0 AND LENGTHB(cur_row.MACH_CD) > 0 THEN 
            --1.1오더번호에 해당하는 작업지시가 존재하는지 체크 함.
            SELECT count(1) INTO V_CNT
            FROM TX_SCH012_TEMP
            WHERE ORDER_NO = cur_row.ORDER_NO;

            IF V_CNT > 0 THEN
              SELECT WRK_ORDR_NO INTO V_WO_NO 
              FROM TX_SCH012_TEMP
              WHERE ORDER_NO = cur_row.ORDER_NO;
              
              UPDATE TX_SCH012_TEMP
              SET PRFM_QTY = NVL(PRFM_QTY,0) + V_STD_QTY
                 ,WRK_ORDR_QTY = NVL(WRK_ORDR_QTY,0) + V_STD_QTY                          
                 ,UPDDATE = sysdate
                 ,UPDID = 'STOCK_TRANS_TEMP'                 
              WHERE WRK_ORDR_NO = V_WO_NO
              AND WRK_ORDR_SEQNO = V_WO_SEQ;   
            ELSE 
              SP_GET_DOC_SEQ('WORA',cur_row.PRD_DT,V_WO_NO);   --포장              
                                
              INSERT INTO TX_SCH012_TEMP(
                WRK_ORDR_NO
               ,WRK_ORDR_SEQNO
               ,WERKS
               ,ORDER_NO
               ,WRK_SEQNO
               ,WRK_ORDR_QTY             
               ,ORDR_GEN_DT
               ,PRD_REQ_DT
               ,PRFM_QTY
               ,COMP_YN
               ,USE_YN
               ,MATNR
               ,UNIT
               ,VBELN
               ,POSNR
               ,DLFL 
               ,PRD_STR_DTM
               ,PRD_END_DTM 
               ,ORDER_DIV
               ,ORDER_DIV_NM 
               ,MACHINE  
               ,TO_MACHINE 
               ,MACH_CD                                      
               ,REGDATE
               ,REGID
              )VALUES(
                V_WO_NO
               ,V_WO_SEQ
               ,cur_row.WERKS
               ,cur_row.ORDER_NO
               ,V_WO_SEQ
               ,V_STD_QTY             
               ,cur_row.PRD_DT
               ,cur_row.PRD_DT           
               ,V_STD_QTY
               ,'Y'
               ,'Y'
               ,cur_row.MATNR
               ,V_STD_UNIT
               ,cur_row.VBELN
               ,cur_row.POSNR  
               ,'N'  
               ,cur_row.PRD_DT||'000000'   
               ,cur_row.PRD_DT||'000000' 
               ,'ZP21' 
               ,'화장지 표준생산오더' 
               ,cur_row.MACHINE  
               ,cur_row.MACHINE 
               ,cur_row.MACH_CD                                           
               ,sysdate
               ,'STOCK_TRANS_TEMP'                    
              ); 
            END IF;   
          ELSIF cur_row.PROC_CD = 'RB' AND LENGTHB(cur_row.ORDER_NO) > 0 AND LENGTHB(cur_row.MACH_CD) > 0 THEN 
            --1.1오더번호에 해당하는 작업지시가 존재하는지 체크 함.
            SELECT count(1) INTO V_CNT
            FROM TX_SCH013_TEMP
            WHERE ORDER_NO = cur_row.ORDER_NO;

            IF V_CNT > 0 THEN
              SELECT WRK_ORDR_NO INTO V_WO_NO 
              FROM TX_SCH013_TEMP
              WHERE ORDER_NO = cur_row.ORDER_NO;
              
              UPDATE TX_SCH013_TEMP
              SET PRFM_QTY = NVL(PRFM_QTY,0) + V_STD_QTY
                 ,WRK_ORDR_QTY = NVL(WRK_ORDR_QTY,0) + V_STD_QTY                        
                 ,UPDDATE = sysdate
                 ,UPDID = 'STOCK_TRANS_TEMP'                 
              WHERE WRK_ORDR_NO = V_WO_NO
              AND WRK_ORDR_SEQNO = V_WO_SEQ;   
            ELSE 
              SP_GET_DOC_SEQ('WORB',cur_row.PRD_DT,V_WO_NO);   --포장              
                                
              INSERT INTO TX_SCH013_TEMP(
                WRK_ORDR_NO
               ,WRK_ORDR_SEQNO
               ,WERKS
               ,ORDER_NO
               ,WRK_SEQNO
               ,WRK_ORDR_QTY             
               ,ORDR_GEN_DT
               ,PRD_REQ_DT
               ,PRFM_QTY
               ,COMP_YN
               ,USE_YN
               ,MATNR
               ,UNIT
               ,VBELN
               ,POSNR
               ,DLFL 
               ,PRD_STR_DTM
               ,PRD_END_DTM 
               ,ORDER_DIV
               ,ORDER_DIV_NM 
               ,MACHINE  
               ,TO_MACHINE 
               ,MACH_CD                                      
               ,REGDATE
               ,REGID
              )VALUES(
                V_WO_NO
               ,V_WO_SEQ
               ,cur_row.WERKS
               ,cur_row.ORDER_NO
               ,V_WO_SEQ
               ,V_STD_QTY             
               ,cur_row.PRD_DT
               ,cur_row.PRD_DT           
               ,V_STD_QTY
               ,'Y'
               ,'Y'
               ,cur_row.MATNR
               ,V_STD_UNIT
               ,cur_row.VBELN
               ,cur_row.POSNR  
               ,'N'  
               ,cur_row.PRD_DT||'000000'   
               ,cur_row.PRD_DT||'000000' 
               ,'ZP31' 
               ,'패드 표준생산오더' 
               ,cur_row.MACHINE  
               ,cur_row.MACHINE 
               ,cur_row.MACH_CD                                           
               ,sysdate
               ,'STOCK_TRANS_TEMP'                    
              ); 
            END IF;  
          ELSIF cur_row.PROC_CD = 'RC' AND LENGTHB(cur_row.ORDER_NO) > 0 AND LENGTHB(cur_row.MACH_CD) > 0 THEN 
            --1.1오더번호에 해당하는 작업지시가 존재하는지 체크 함.
            SELECT count(1) INTO V_CNT
            FROM TX_SCH014_TEMP
            WHERE ORDER_NO = cur_row.ORDER_NO;

            IF V_CNT > 0 THEN
              SELECT WRK_ORDR_NO INTO V_WO_NO 
              FROM TX_SCH014_TEMP
              WHERE ORDER_NO = cur_row.ORDER_NO;
              
              UPDATE TX_SCH014_TEMP
              SET PRFM_QTY = NVL(PRFM_QTY,0) + V_STD_QTY
                 ,WRK_ORDR_QTY = NVL(WRK_ORDR_QTY,0) + V_STD_QTY                        
                 ,UPDDATE = sysdate
                 ,UPDID = 'STOCK_TRANS_TEMP'                 
              WHERE WRK_ORDR_NO = V_WO_NO
              AND WRK_ORDR_SEQNO = V_WO_SEQ;   
            ELSE 
              SP_GET_DOC_SEQ('WORC',cur_row.PRD_DT,V_WO_NO);   --포장              
                                
              INSERT INTO TX_SCH014_TEMP(
                WRK_ORDR_NO
               ,WRK_ORDR_SEQNO
               ,WERKS
               ,ORDER_NO
               ,WRK_SEQNO
               ,WRK_ORDR_QTY             
               ,ORDR_GEN_DT
               ,PRD_REQ_DT
               ,PRFM_QTY
               ,COMP_YN
               ,USE_YN
               ,MATNR
               ,UNIT
               ,VBELN
               ,POSNR
               ,DLFL 
               ,PRD_STR_DTM
               ,PRD_END_DTM 
               ,ORDER_DIV
               ,ORDER_DIV_NM 
               ,MACHINE  
               ,TO_MACHINE 
               ,MACH_CD                                      
               ,REGDATE
               ,REGID
              )VALUES(
                V_WO_NO
               ,V_WO_SEQ
               ,cur_row.WERKS
               ,cur_row.ORDER_NO
               ,V_WO_SEQ
               ,V_STD_QTY             
               ,cur_row.PRD_DT
               ,cur_row.PRD_DT           
               ,V_STD_QTY
               ,'Y'
               ,'Y'
               ,cur_row.MATNR
               ,V_STD_UNIT
               ,cur_row.VBELN
               ,cur_row.POSNR  
               ,'N'  
               ,cur_row.PRD_DT||'000000'   
               ,cur_row.PRD_DT||'000000' 
               ,'ZP31' 
               ,'패드 표준생산오더' 
               ,cur_row.MACHINE  
               ,cur_row.MACHINE 
               ,cur_row.MACH_CD                                           
               ,sysdate
               ,'STOCK_TRANS_TEMP'                    
              ); 
            END IF;                                                      
          END IF; --if of 공정
        END IF; --if of 플랜트     
                                                        
                           
        --2.생산실적 생성하기
        IF cur_row.WERKS = 'P100' THEN --PS삽입
          IF LENGTHB(cur_row.ORDER_NO) > 0 AND LENGTHB(cur_row.MACH_CD) > 0 THEN
            SELECT count(1) INTO V_CNT
            FROM TX_WRK002_TEMP
            WHERE IND_BCD = cur_row.IND_BCD
            AND WERKS IN(i_WERKS);  
            
            IF V_CNT > 0 THEN
              o_msg_msg  := 'TX_WRK002에 이미 존재하는 데이타 입니다. IND_BCD중복 확인필요.';
              o_msg_code := '-1' ; 
              RAISE E_EXCEPTION_USER;
            ELSE
              INSERT INTO TX_WRK002_TEMP(
                WERKS
               ,MACH_CD
               ,IND_BCD
               ,LOT_NO
               ,MATNR
               ,ORDER_NO
               ,WRK_ORDR_NO
               ,WRK_ORDR_SEQNO
               ,UNIT
               ,PRFM_QTY
               ,PCNT
               ,SCNT
               ,MCNT
               ,ROLLCNT
               ,WGT
               ,PRFM_DT
               ,PRD_DT
               ,WRK_CLASS
               ,WRK_SHIFT
               ,MACHINE
               ,TO_MACHINE           
               ,STA 
               ,VBELN
               ,POSNR
               ,KUNNR
               ,PACKTYPE
               ,RUN_STA
               ,VLEN
               ,WLEN
               ,REGDATE
               ,REGID 
              )VALUES(
                cur_row.WERKS
               ,cur_row.MACH_CD
               ,cur_row.IND_BCD
               ,cur_row.LOT_NO
               ,cur_row.MATNR
               ,cur_row.ORDER_NO
               ,V_WO_NO
               ,V_WO_SEQ
               ,V_STD_UNIT
               ,V_STD_QTY
               ,cur_row.PCNT
               ,cur_row.SCNT
               ,cur_row.MCNT
               ,cur_row.ROLLCNT
               ,cur_row.WGT
               ,cur_row.PRFM_DT
               ,cur_row.PRD_DT
               ,cur_row.WRK_CLASS
               ,cur_row.WRK_SHIFT
               ,cur_row.MACHINE
               ,cur_row.MACHINE           
               ,'00' 
               ,cur_row.VBELN
               ,cur_row.POSNR
               ,cur_row.KUNNR
               ,cur_row.PACKTYPE
               ,'99'
               ,cur_row.VLEN
               ,cur_row.WLEN             
               ,sysdate
               ,'STOCK_TRANS_TEMP'                     
              );
            END IF; 
          END IF;
        ELSE --HL삽입
          IF LENGTHB(cur_row.ORDER_NO) > 0 AND LENGTHB(cur_row.MACH_CD) > 0 THEN
            SELECT count(1) INTO V_CNT
            FROM TX_WRK001_TEMP
            WHERE IND_BCD = cur_row.IND_BCD
            AND WERKS IN(i_WERKS); 
            
            IF V_CNT > 0 THEN
              o_msg_msg  := 'TX_WRK001에 이미 존재하는 데이타 입니다. IND_BCD중복 확인필요.';
              o_msg_code := '-1' ; 
              RAISE E_EXCEPTION_USER;
            ELSE
              INSERT INTO TX_WRK001_TEMP(
                WERKS
               ,MACH_CD
               ,IND_BCD
               ,LOT_NO
               ,MATNR
               ,ORDER_NO
               ,WRK_ORDR_NO
               ,WRK_ORDR_SEQNO
               ,UNIT
               ,PRFM_QTY
               ,PLT_QTY
               ,BOX_QTY
               ,BAG_QTY
               ,EA_QTY
               ,ROLLCNT
               ,WGT
               ,PRFM_DT
               ,PRD_DT
               ,WRK_CLASS
               ,WRK_SHIFT          
               ,STA 
               ,REGDATE
               ,REGID 
              )VALUES(
                cur_row.WERKS
               ,cur_row.MACH_CD
               ,cur_row.IND_BCD
               ,cur_row.LOT_NO
               ,cur_row.MATNR
               ,cur_row.ORDER_NO
               ,V_WO_NO
               ,V_WO_SEQ
               ,V_STD_UNIT
               ,V_STD_QTY
               ,V_PLT_QTY
               ,V_BOX_QTY
               ,V_BAG_QTY
               ,V_EA_QTY
               ,cur_row.ROLLCNT
               ,cur_row.WGT
               ,cur_row.PRFM_DT
               ,cur_row.PRD_DT
               ,cur_row.WRK_CLASS
               ,cur_row.WRK_SHIFT          
               ,'00'      
               ,sysdate
               ,'STOCK_TRANS_TEMP'                     
              );
            END IF; 
          END IF;
        END IF; --if of 생산실적
        
        
        --★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★          
        --3.공정재고 생성하기
        --★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★                                                                          
        SELECT COUNT(1) INTO V_CNT 
        FROM TX_INV001_TEMP
        WHERE IND_BCD = cur_row.IND_BCD
        AND WERKS IN(i_WERKS);         
        
        --기존에 재고에 등록되어 있으면 체크 함.
        IF V_CNT > 0 THEN
          UPDATE TX_INV001_TEMP
          SET LOC_CD      = cur_row.LOC_CD                                      --로케이션                     
             ,LOT_NO      = cur_row.LOT_NO                                      --LOT NO                       
             ,MACH_CD     = cur_row.MACH_CD                                     --설비코드                     
             ,MACHINE     = cur_row.MACHINE                                     --생산호기                     
             ,ORDER_NO    = cur_row.ORDER_NO                                    --오더번호                                     
             ,PRFM_DT     = cur_row.PRFM_DT                                     --실적일자                     
             ,PRD_DT      = cur_row.PRD_DT                                      --제조(생산)일자
             
             ,UNIT        = V_STD_UNIT                                          --단위                                     
             ,STCK_QTY    = V_STD_QTY                                           --재고수량  
             ,PLT_QTY     = V_PLT_QTY
             ,BOX_QTY     = V_BOX_QTY
             ,BAG_QTY     = V_BAG_QTY
             ,EA_QTY      = V_EA_QTY                   
             ,ROLLCNT     = cur_row.ROLLCNT                                     --권치수(점보롤, 밀롤, 합지기) 
             ,WGT         = cur_row.WGT                                         --중량            
             ,BS_WGT      = cur_row.BS_WGT                                      --평량
             ,VBELN       = cur_row.VBELN                                       --판매문서
             ,POSNR       = cur_row.POSNR                                       --판매문서항목번호
             ,KUNNR       = cur_row.KUNNR                                       --판매처                                 
             ,CON_TYPE    = cur_row.CONTYPE                                     --컨테이너유형
             ,PACK_TYPE   = cur_row.PACKTYPE                                    --포장타입
             
             ,UPDDATE     = sysdate
             ,UPDID       = 'STOCK_TRANS_TEMP' 
          WHERE IND_BCD = cur_row.IND_BCD
          AND WERKS IN(i_WERKS);            
        ELSE
          --작업지시번호,작업지시순번을 구해서 TB_INV001에 넣을것!    
          --JA:점보롤, MA:밀롤, SA:슬리터, CA:재단, PB:포장 
          INSERT INTO TX_INV001_TEMP(  
             WERKS												 --플랜트코드                   
            ,STOR_LOC_CD                   --저장위치                     
            ,IND_BCD                       --개별바코드                   
            ,MATNR                         --제품코드  
                               
            ,LOC_CD                        --로케이션                     
            ,LOT_NO                        --LOT NO                       
            ,MACH_CD                       --설비코드                     
            ,MACHINE                       --생산호기 
            ,WRK_ORDR_NO                   --작업지시번호
            ,WRK_ORDR_SEQNO                --작업지시순번    
            ,ORDER_NO                      --오더번호                                     
            ,PRFM_DT                       --실적일자                     
            ,PRD_DT                        --제조(생산)일자
                           
            ,UNIT                          --단위                                     
            ,STCK_QTY                      --재고수량  
            ,PLT_QTY
            ,BOX_QTY
            ,BAG_QTY
            ,EA_QTY                   
            ,ROLLCNT                       --권치수(점보롤, 밀롤, 합지기) 
            ,WGT                           --중량            
            ,BS_WGT                        --평량
            ,VBELN                         --판매문서
            ,POSNR                         --판매문서항목번호
            ,KUNNR                         --판매처                                
            ,STCK_STA                      --재고상태 
            ,CON_TYPE                      --컨테이너유형
            ,PACK_TYPE                     --포장타입
            ,STK_FLAG                     
            ,REGDATE
            ,REGID
          )VALUES(
             cur_row.WERKS
            ,cur_row.STOR_LOC_CD
            ,cur_row.IND_BCD
            ,cur_row.MATNR
            
            ,cur_row.LOC_CD
            ,cur_row.LOT_NO
            ,cur_row.MACH_CD
            ,cur_row.MACHINE
            ,V_WO_NO 
            ,V_WO_SEQ 
            ,cur_row.ORDER_NO                        
            ,cur_row.PRFM_DT
            ,cur_row.PRD_DT            
            ,V_STD_UNIT
            ,V_STD_QTY
            ,V_PLT_QTY
            ,V_BOX_QTY
            ,V_BAG_QTY
            ,V_EA_QTY
            ,cur_row.ROLLCNT
            ,cur_row.WGT            
            
            ,cur_row.BS_WGT    
            ,cur_row.VBELN  
            ,cur_row.POSNR            
            ,cur_row.KUNNR
            ,'00'
            ,cur_row.CONTYPE
            ,cur_row.PACKTYPE                              
            ,cur_row.STK_FLAG         
            ,sysdate
            ,'STOCK_TRANS_TEMP'                                                                                    
          );         
        END IF;
        
        
      ----------------------------------------------------------------------------------------------------------------------
      --5.★수재단 작업지시 생성(T바코드이면 수재단 작업지시만 생성 한다.
      ----------------------------------------------------------------------------------------------------------------------
      IF cur_row.STK_FLAG = 'PS_T' AND LENGTHB(cur_row.ORDER_NO) > 0 AND LENGTHB(cur_row.MACH_CD) > 0 THEN  
          SP_GET_DOC_SEQ('WOCA',cur_row.PRD_DT,V_WO_NO);   --재단  
                            
          INSERT INTO TX_SCH017_TEMP(
            WRK_ORDR_NO
           ,WRK_ORDR_SEQNO
           ,WERKS
           ,ORDER_NO
           ,WRK_SEQNO
           ,WRK_ORDR_QTY             
           ,ORDR_GEN_DT
           ,PRD_REQ_DT
           ,PRFM_QTY
           ,COMP_YN
           ,USE_YN
           ,MATNR
           ,BS_WGT
           ,UNIT
           ,PCODE
           ,TOT_WGT 
           ,VBELN
           ,POSNR
           ,VLEN
           ,WLEN
           ,KUNNR
           ,PACKTYPE             
           ,DLFL 
           ,PRD_STR_DTM
           ,PRD_END_DTM 
           ,ORDER_DIV
           ,ORDER_DIV_NM
           ,MACHINE  
           ,TO_MACHINE 
           ,MAN_CUT_YN
           ,DUMMY_KEY                                        
           ,REGDATE
           ,REGID
          )VALUES(
            V_WO_NO
           ,V_WO_SEQ
           ,cur_row.WERKS
           ,cur_row.ORDER_NO
           ,V_WO_SEQ
           ,V_STD_QTY              
           ,cur_row.PRD_DT
           ,cur_row.PRD_DT           
           ,V_STD_QTY
           ,'Y'
           ,'Y'
           ,cur_row.MATNR
           ,cur_row.BS_WGT
           ,V_STD_UNIT
           ,cur_row.PCODE
           ,cur_row.WGT
           ,cur_row.VBELN
           ,cur_row.POSNR 
           ,cur_row.VLEN
           ,cur_row.WLEN 
           ,cur_row.KUNNR
           ,cur_row.PACKTYPE
           ,'N'   
           ,cur_row.PRD_DT||'000000'   
           ,cur_row.PRD_DT||'000000' 
           ,'ZP11' 
           ,'제지 표준생산오더'   
           ,cur_row.MACHINE  
           ,cur_row.MACHINE 
           ,'X'
           ,cur_row.IND_BCD                                      
           ,sysdate
           ,'STOCK_TRANS_TEMP'                    
          );
        END IF;            

                        
        o_msg_msg       := '성공';
        o_msg_code      := '0' ;

        UPDATE  TX_BASE_INIT_TEMP
        SET     IF_YN   =  'S'                                                   --I/F상태, N:신규, S:성공, E:오류               
              , IF_MSG =  o_msg_msg                                             --데이터 처리 결과 Message(Oracle)                         
        WHERE  IND_BCD = cur_row.IND_BCD;                         
        COMMIT;

        EXCEPTION  
          WHEN E_EXCEPTION_USER THEN        
                DBMS_OUTPUT.PUT_LINE(o_msg_msg);
                ROLLBACK;

                UPDATE  TX_BASE_INIT_TEMP
                SET     IF_YN   =  'E'                                           --I/F상태, N:신규, S:성공, E:오류               
                      , IF_MSG  =  o_msg_msg                                    --데이터 처리 결과 Message(Oracle)                         
                WHERE  IND_BCD = cur_row.IND_BCD;                 
                COMMIT;
                                          
          WHEN OTHERS THEN
                o_msg_msg  :=  i_WERKS || '=>' || '재고정보 이관중 오류가 발생 되었습니다.' || ',' || SQLERRM ;
                o_msg_code := '-1' ;
                DBMS_OUTPUT.PUT_LINE (o_msg_msg );
                ROLLBACK;

                UPDATE  TX_BASE_INIT_TEMP
                SET     IF_YN   =  'E'                                           --I/F상태, N:신규, S:성공, E:오류               
                      , IF_MSG  =  o_msg_msg                                    --데이터 처리 결과 Message(Oracle)                         
                WHERE  IND_BCD = cur_row.IND_BCD;                 
                COMMIT;                              
      END;
    END LOOP;
    
        
    --------------------------------------------------------------------------------------------------------------------------
    --작업완료후 TEMP->MES운영으로 이관(옵션이다.....)
    --------------------------------------------------------------------------------------------------------------------------  
/*
             
    INSERT INTO TB_SCH015
    SELECT * FROM TX_SCH015_TEMP;

    INSERT INTO TB_SCH016
    SELECT * FROM TX_SCH016_TEMP;

    INSERT INTO TB_SCH017
    SELECT * FROM TX_SCH017_TEMP;

    INSERT INTO TB_SCH018
    SELECT * FROM TX_SCH018_TEMP;    
              
    --공정재고 옮기기(TX_INV001_TEMP->TB_INV001)                 
    INSERT INTO TB_INV001(
     WERKS
    ,STOR_LOC_CD
    ,IND_BCD
    ,MATNR
    ,LOC_CD
    ,LOT_NO
    ,MACH_CD
    ,MACHINE
    ,WRK_ORDR_NO
    ,WRK_ORDR_SEQNO
    ,ORDER_NO
    ,PRD_NO
    ,IN_MR_YN
    ,STCK_KY
    ,PRFM_DT
    ,PRD_DT
    ,UNIT
    ,STCK_QTY
    ,PLT_QTY
    ,BOX_QTY
    ,BAG_QTY
    ,EA_QTY
    ,ROLLCNT
    ,WGT
    ,SUPY_CD
    ,LOT_NUM
    ,STCK_STA
    ,VBELN
    ,POSNR
    ,KUNNR
    ,FNL_JDGM
    ,MSRM_DATE
    ,PRC_SEQNO
    ,INSPR_ID
    ,CHK_PP_YN
    ,CHK_PP_DATE
    ,CHK_PP_ID
    ,CHK_QC_YN
    ,CHK_QC_DATE
    ,CHK_QC_ID
    ,DOC_NO
    ,DOC_SEQNO
    ,WDOC_NO
    ,WDOC_SEQNO
    ,DLFL
    ,REGDATE
    ,REGID
    ,UPDDATE
    ,UPDID
    ,RUN_STA
    ,APVR_STA
    ,CFRM_ID
    ,CFRM_DATE
    ,BS_WGT
    ,CON_TYPE
    ,PACK_TYPE
    ,DISPO_DT
    ,DISPO_QTY
    ,SDOC_NO
    ,SDOC_SEQNO
    ,DOC_ID
    ,SND_MSG
    ,UCFMTY_AMT
    ,UCFMTY_FLG
    --,MER_STOCK_QTY
    )
    SELECT
     WERKS        
    ,STOR_LOC_CD  
    ,IND_BCD      
    ,MATNR        
    ,LOC_CD       
    ,LOT_NO       
    ,MACH_CD      
    ,MACHINE      
    ,WRK_ORDR_NO  
    ,WRK_ORDR_SEQNO
    ,ORDER_NO     
    ,PRD_NO       
    ,IN_MR_YN     
    ,STCK_KY      
    ,PRFM_DT      
    ,PRD_DT       
    ,UNIT         
    ,STCK_QTY     
    ,PLT_QTY      
    ,BOX_QTY      
    ,BAG_QTY      
    ,EA_QTY       
    ,ROLLCNT      
    ,WGT          
    ,SUPY_CD      
    ,LOT_NUM      
    ,STCK_STA     
    ,VBELN        
    ,POSNR        
    ,KUNNR        
    ,FNL_JDGM     
    ,MSRM_DATE    
    ,PRC_SEQNO    
    ,INSPR_ID     
    ,CHK_PP_YN    
    ,CHK_PP_DATE  
    ,CHK_PP_ID    
    ,CHK_QC_YN    
    ,CHK_QC_DATE  
    ,CHK_QC_ID    
    ,DOC_NO       
    ,DOC_SEQNO    
    ,WDOC_NO      
    ,WDOC_SEQNO   
    ,DLFL         
    ,REGDATE      
    ,REGID        
    ,UPDDATE      
    ,UPDID        
    ,RUN_STA      
    ,APVR_STA     
    ,CFRM_ID      
    ,CFRM_DATE    
    ,BS_WGT       
    ,CON_TYPE     
    ,PACK_TYPE    
    ,DISPO_DT     
    ,DISPO_QTY    
    ,SDOC_NO      
    ,SDOC_SEQNO   
    ,DOC_ID       
    ,SND_MSG      
    ,UCFMTY_AMT   
    ,UCFMTY_FLG   
    --,MER_STOCK_QTY
    FROM TX_INV001_TEMP;        
    

    --실적 옮기기(TX_WRK002_TEMP->TB_WRK002)
    INSERT INTO TB_WRK002(
     WERKS          
    ,MACH_CD        
    ,IND_BCD        
    ,LOT_NO         
    ,MATNR          
    ,ORDER_NO       
    ,ORDER_SEQNO    
    ,WRK_ORDR_NO    
    ,WRK_ORDR_SEQNO 
    ,PRD_NO         
    ,UNIT           
    ,PRFM_QTY       
    ,PCNT           
    ,SCNT           
    ,MCNT           
    ,WIDTH          
    ,ROLLCNT        
    ,WGT            
    ,RSPEED         
    ,CORE           
    ,WIDTH_NO       
    ,MRLDCK         
    ,CUTTER         
    ,MER_YN         
    ,GRD_YN         
    ,PRD_STR_DATE   
    ,PRD_END_DATE   
    ,TM             
    ,PRFM_DT        
    ,PRD_DT         
    ,DSTBT_DDLIN    
    ,WRK_CLASS      
    ,WRK_SHIFT      
    ,MACHINE        
    ,TO_MACHINE     
    ,STA            
    ,DOC_NO         
    ,DOC_SEQNO      
    ,SDOC_NO        
    ,SDOC_SEQNO     
    ,RMK            
    ,CNL_YN         
    ,CNL_RMK        
    ,REGDATE        
    ,REGID          
    ,UPDDATE        
    ,UPDID          
    ,VBELN          
    ,POSNR          
    ,KUNNR          
    ,PACKTYPE       
    ,RUN_STA        
    ,WRK_SEQ        
    ,PRD_SEQ        
    ,LOT_NO_BUF     
    ,VLEN           
    ,WLEN           
    ,PRFM_GTHR_YN   
    ,NAUFNR         
    ,LOT_NO_PRE     
    ,LOT_CHG_YN     
    ,RMD_QTY        
    ,MER_IND_BCD    
    ,MER_RMK        
    ,IN_PER_CNT     
    ,MAN_CUT_YN     
    ,LOT_NO_M1      
    ,LOT_NO_M2      
    ,LOT_NO_M3      
    ,LOT_NO_M4      
    ,LOT_NO_M5      
    ,USE_REAM_M1    
    ,USE_REAM_M2    
    ,USE_REAM_M3    
    ,USE_REAM_M4    
    ,USE_REAM_M5    
    --,PACK_LABEL_TYPE
    )
    SELECT 
     WERKS          
    ,MACH_CD        
    ,IND_BCD        
    ,LOT_NO         
    ,MATNR          
    ,ORDER_NO       
    ,ORDER_SEQNO    
    ,WRK_ORDR_NO    
    ,WRK_ORDR_SEQNO 
    ,PRD_NO         
    ,UNIT           
    ,PRFM_QTY       
    ,PCNT           
    ,SCNT           
    ,MCNT           
    ,WIDTH          
    ,ROLLCNT        
    ,WGT            
    ,RSPEED         
    ,CORE           
    ,WIDTH_NO       
    ,MRLDCK         
    ,CUTTER         
    ,MER_YN         
    ,GRD_YN         
    ,PRD_STR_DATE   
    ,PRD_END_DATE   
    ,TM             
    ,PRFM_DT        
    ,PRD_DT         
    ,DSTBT_DDLIN    
    ,WRK_CLASS      
    ,WRK_SHIFT      
    ,MACHINE        
    ,TO_MACHINE     
    ,STA            
    ,DOC_NO         
    ,DOC_SEQNO      
    ,SDOC_NO        
    ,SDOC_SEQNO     
    ,RMK            
    ,CNL_YN         
    ,CNL_RMK        
    ,REGDATE        
    ,REGID          
    ,UPDDATE        
    ,UPDID          
    ,VBELN          
    ,POSNR          
    ,KUNNR          
    ,PACKTYPE       
    ,RUN_STA        
    ,WRK_SEQ        
    ,PRD_SEQ        
    ,LOT_NO_BUF     
    ,VLEN           
    ,WLEN           
    ,PRFM_GTHR_YN   
    ,NAUFNR         
    ,LOT_NO_PRE     
    ,LOT_CHG_YN     
    ,RMD_QTY        
    ,MER_IND_BCD    
    ,MER_RMK        
    ,IN_PER_CNT     
    ,MAN_CUT_YN     
    ,LOT_NO_M1      
    ,LOT_NO_M2      
    ,LOT_NO_M3      
    ,LOT_NO_M4      
    ,LOT_NO_M5      
    ,USE_REAM_M1    
    ,USE_REAM_M2    
    ,USE_REAM_M3    
    ,USE_REAM_M4    
    ,USE_REAM_M5    
    --,PACK_LABEL_TYPE 
    FROM TX_WRK002_TEMP;       
*/    
      
    IF o_msg_code = 0 THEN
      COMMIT;
    END IF;

    EXCEPTION
      WHEN OTHERS THEN
        IF o_msg_code = 0 THEN       
          o_msg_code      := '-1' ;
          o_msg_msg       := 'SP_IF_MIG_STOCK_TRANS_TEMP_NEW=>' || 'MAIN에서 오류가 발생하였습니다.' || ',' || to_char(SQLCODE) || ',' || SQLERRM ;
          DBMS_OUTPUT.PUT_LINE(o_msg_msg);
          rollback ;
          
          SP_IF_MIG_LOG('STOCK_TRANS_TEMP_NEW','0',o_msg_msg);
          COMMIT;          
        END IF;          
  END;         
END;
/
