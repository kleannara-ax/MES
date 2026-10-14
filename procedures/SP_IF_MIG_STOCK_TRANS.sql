
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_IF_MIG_STOCK_TRANS" (   
 i_CMDKY            IN    VARCHAR2    /*  Common code key               */
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
 * - [TX_BASE_INIT] : (.R..)초기재고데이타                                
 * - [TB_SCH015] : (.I.U.)작업지시 점보롤
 * - [TB_SCH016] : (.I.U.)작업지시 밀롤
 * - [TB_SCH017] : (.I.U.)작업지시 재단
 * - [TB_SCH018] : (.I.U.)작업지시 포장
 * - [TB_WRK002] : (.I.)생산실적(PS)
 * - [TB_INV001] : (.I.)공정재고
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
      FROM TX_BASE_INIT                                           
      WHERE IF_YN IN ('N')
      AND MACH_CD IS NOT NULL
      AND ORDER_NO IS NOT NULL; 

    
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
        IF cur_row.PROC_CD = 'CA' THEN
          V_STD_UNIT  := 'EA';
          V_STD_QTY   := cur_row.PCNT * 500;          
        ELSE
          V_STD_UNIT  := cur_row.UNIT;
          V_STD_QTY   := cur_row.STCK_QTY;
        END IF;
        --★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★        



          
        --1.작업지시 생성하기
        --JA:점보롤, MA:밀롤, SA:슬리터, CA:재단, PB:포장
        IF cur_row.PROC_CD = 'JA' THEN 
          --1.1오더번호에 해당하는 작업지시가 존재하는지 체크 함.
          SELECT count(1) INTO V_CNT
          FROM TB_SCH015
          WHERE ORDER_NO = cur_row.ORDER_NO;

          IF V_CNT > 0 THEN
            SELECT WRK_ORDR_NO INTO V_WO_NO 
            FROM TB_SCH015
            WHERE ORDER_NO = cur_row.ORDER_NO;
            
            UPDATE TB_SCH015
            SET PRFM_QTY = NVL(PRFM_QTY,0) + V_STD_QTY
               ,WRK_ORDR_QTY = NVL(WRK_ORDR_QTY,0) + V_STD_QTY            
               ,BS_WGT = NVL(BS_WGT,0) + cur_row.BS_WGT
               ,TOT_WGT = NVL(TOT_WGT,0) + cur_row.WGT                
               ,UPDDATE = sysdate
               ,UPDID = 'STOCK_TRANS'  
            WHERE WRK_ORDR_NO = V_WO_NO
            AND WRK_ORDR_SEQNO = V_WO_SEQ;   
          ELSE 
            SP_GET_DOC_SEQ('WOJA',cur_row.PRD_DT,V_WO_NO);   --점보롤
                    
            INSERT INTO TB_SCH015(
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
             ,'STOCK_TRANS'         
            );
          END IF;
        ELSIF cur_row.PROC_CD = 'MA'  OR cur_row.PROC_CD = 'SA' THEN 
          --1.1오더번호에 해당하는 작업지시가 존재하는지 체크 함.
          SELECT count(1) INTO V_CNT
          FROM TB_SCH016
          WHERE ORDER_NO = cur_row.ORDER_NO;

          IF V_CNT > 0 THEN
            SELECT WRK_ORDR_NO INTO V_WO_NO 
            FROM TB_SCH016
            WHERE ORDER_NO = cur_row.ORDER_NO;
                    
            UPDATE TB_SCH016
            SET PRFM_QTY = NVL(PRFM_QTY,0) + V_STD_QTY
               ,WRK_ORDR_QTY = NVL(WRK_ORDR_QTY,0) + V_STD_QTY            
               ,BS_WGT = NVL(BS_WGT,0) + cur_row.BS_WGT
               ,TOT_WGT = NVL(TOT_WGT,0) + cur_row.WGT                
               ,UPDDATE = sysdate
               ,UPDID = 'STOCK_TRANS'                 
            WHERE WRK_ORDR_NO = V_WO_NO
            AND WRK_ORDR_SEQNO = V_WO_SEQ;   
          ELSE 
            SP_GET_DOC_SEQ('WOMA',cur_row.PRD_DT,V_WO_NO);  --밀롤,슬리터
                    
            INSERT INTO TB_SCH016(
              WRK_ORDR_NO
             ,WRK_ORDR_SEQNO
             ,WERKS
             ,ORDER_NO
             ,WRK_SEQNO
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
             ,'N'  
             ,cur_row.PRD_DT||'000000'   
             ,cur_row.PRD_DT||'000000' 
             ,'ZP11' 
             ,'제지 표준생산오더'  
             ,cur_row.MACHINE 
             ,cur_row.MACHINE                                                   
             ,sysdate
             ,'STOCK_TRANS'                       
            );
          END IF;          
        ELSIF cur_row.PROC_CD = 'CA' THEN  
          --1.1오더번호에 해당하는 작업지시가 존재하는지 체크 함.
          SELECT count(1) INTO V_CNT
          FROM TB_SCH017
          WHERE ORDER_NO = cur_row.ORDER_NO;

          IF V_CNT > 0 THEN
            SELECT WRK_ORDR_NO INTO V_WO_NO 
            FROM TB_SCH017
            WHERE ORDER_NO = cur_row.ORDER_NO;
            
            UPDATE TB_SCH017
            SET PRFM_QTY = NVL(PRFM_QTY,0) + V_STD_QTY
               ,WRK_ORDR_QTY = NVL(WRK_ORDR_QTY,0) + V_STD_QTY            
               ,BS_WGT = NVL(BS_WGT,0) + cur_row.BS_WGT
               ,TOT_WGT = NVL(TOT_WGT,0) + cur_row.WGT                              
               ,UPDDATE = sysdate
               ,UPDID = 'STOCK_TRANS'                 
            WHERE WRK_ORDR_NO = V_WO_NO
            AND WRK_ORDR_SEQNO = V_WO_SEQ;   
          ELSE 
            SP_GET_DOC_SEQ('WOCA',cur_row.PRD_DT,V_WO_NO);   --재단  
                              
            INSERT INTO TB_SCH017(
              WRK_ORDR_NO
             ,WRK_ORDR_SEQNO
             ,WERKS
             ,ORDER_NO
             ,WRK_SEQNO
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
             ,REGDATE
             ,REGID
            )VALUES(
              V_WO_NO
             ,V_WO_SEQ
             ,cur_row.WERKS
             ,cur_row.ORDER_NO
             ,V_WO_SEQ
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
             ,sysdate
             ,'STOCK_TRANS'                    
            );
          END IF;                    
        ELSIF cur_row.PROC_CD = 'PB' THEN 
          --1.1오더번호에 해당하는 작업지시가 존재하는지 체크 함.
          SELECT count(1) INTO V_CNT
          FROM TB_SCH018
          WHERE ORDER_NO = cur_row.ORDER_NO;

          IF V_CNT > 0 THEN
            SELECT WRK_ORDR_NO INTO V_WO_NO 
            FROM TB_SCH018
            WHERE ORDER_NO = cur_row.ORDER_NO;
            
            UPDATE TB_SCH018
            SET PRFM_QTY = NVL(PRFM_QTY,0) + V_STD_QTY
               ,WRK_ORDR_QTY = NVL(WRK_ORDR_QTY,0) + V_STD_QTY            
               ,BS_WGT = NVL(BS_WGT,0) + cur_row.BS_WGT
               ,TOT_WGT = NVL(TOT_WGT,0) + cur_row.WGT                
               ,UPDDATE = sysdate
               ,UPDID = 'STOCK_TRANS'                 
            WHERE WRK_ORDR_NO = V_WO_NO
            AND WRK_ORDR_SEQNO = V_WO_SEQ;   
          ELSE 
            SP_GET_DOC_SEQ('WOPA',cur_row.PRD_DT,V_WO_NO);   --포장              
                              
            INSERT INTO TB_SCH018(
              WRK_ORDR_NO
             ,WRK_ORDR_SEQNO
             ,WERKS
             ,ORDER_NO
             ,WRK_SEQNO
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
             ,REGDATE
             ,REGID
            )VALUES(
              V_WO_NO
             ,V_WO_SEQ
             ,cur_row.WERKS
             ,cur_row.ORDER_NO
             ,V_WO_SEQ
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
             ,sysdate
             ,'STOCK_TRANS'                    
            ); 
          END IF;                   
        END IF;     
                           
        --2.생산실적 생성하기
        SELECT count(1) INTO V_CNT
        FROM TB_WRK002
        WHERE IND_BCD = cur_row.IND_BCD;
        
        IF V_CNT > 0 THEN
          o_msg_msg  := 'TB_WRK002에 이미 존재하는 데이타 입니다. IND_BCD중복 확인필요.';
          o_msg_code := '-1' ; 
          RAISE E_EXCEPTION_USER;
        ELSE
          INSERT INTO TB_WRK002(
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
           ,cur_row.PCNT
           ,cur_row.SCNT
           ,cur_row.MCNT
           ,cur_row.ROLLCNT
           ,cur_row.WGT
           ,cur_row.PRFM_DT
           ,cur_row.PRD_DT
           ,'00'   
           ,sysdate
           ,'STOCK_TRANS'                     
          );
        END IF; 
        
        
        --3.공정재고 생성하기
        --★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★                           
        --####>>FN_CHG_UNIT에서 TB_MAS001에 데이타가 없을시 ERROR발생됨........
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
        --★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★                        
                
        
        SELECT COUNT(1) INTO V_CNT 
        FROM TB_INV001
        WHERE IND_BCD = cur_row.IND_BCD;        
        
        --기존에 재고에 등록되어 있으면 체크 함.
        IF V_CNT > 0 THEN
          UPDATE TB_INV001
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
             ,UPDID       = 'STOCK_TRANS' 
          WHERE IND_BCD = cur_row.IND_BCD;           
        ELSE
          --작업지시번호,작업지시순번을 구해서 TB_INV001에 넣을것!    
          --JA:점보롤, MA:밀롤, SA:슬리터, CA:재단, PB:포장                     
          INSERT INTO TB_INV001(  
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
            ,CON_TYPE
            ,PACK_TYPE 
                                 
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
                     
            ,sysdate
            ,'STOCK_TRANS'                                                                                    
          );         
        END IF;

                        
        o_msg_msg       := '성공';
        o_msg_code      := '0' ;

        UPDATE  TX_BASE_INIT
        SET     IF_YN   =  'S'                                                   --I/F상태, N:신규, S:성공, E:오류               
              , IF_MSG =  o_msg_msg                                             --데이터 처리 결과 Message(Oracle)                         
        WHERE  IND_BCD = cur_row.IND_BCD;                         
        COMMIT;

        EXCEPTION  
          WHEN E_EXCEPTION_USER THEN        
                DBMS_OUTPUT.PUT_LINE(o_msg_msg);
                ROLLBACK;

                UPDATE  TX_BASE_INIT
                SET     IF_YN   =  'E'                                           --I/F상태, N:신규, S:성공, E:오류               
                      , IF_MSG  =  o_msg_msg                                    --데이터 처리 결과 Message(Oracle)                         
                WHERE  IND_BCD = cur_row.IND_BCD;                 
                COMMIT;
                                          
          WHEN OTHERS THEN
                o_msg_msg  :=  i_CMDKY || '=>' || '재고정보 이관중 오류가 발생 되었습니다.' || ',' || SQLERRM ;
                o_msg_code := '-1' ;
                DBMS_OUTPUT.PUT_LINE (o_msg_msg );
                ROLLBACK;

                UPDATE  TX_BASE_INIT
                SET     IF_YN   =  'E'                                           --I/F상태, N:신규, S:성공, E:오류               
                      , IF_MSG  =  o_msg_msg                                    --데이터 처리 결과 Message(Oracle)                         
                WHERE  IND_BCD = cur_row.IND_BCD;                 
                COMMIT;                              
      END;
    END LOOP;
    
      
    IF o_msg_code = 0 THEN
      COMMIT;
    END IF;

    EXCEPTION
      WHEN OTHERS THEN
        IF o_msg_code = 0 THEN       
          o_msg_code      := '-1' ;
          o_msg_msg       := i_CMDKY || '=>' || 'MAIN에서 오류가 발생하였습니다.' || ',' || to_char(SQLCODE) || ',' || SQLERRM ;
          DBMS_OUTPUT.PUT_LINE(o_msg_msg);
          rollback ;
          
          SP_IF_MIG_LOG('STOCK_TRANS','0',o_msg_msg);
          COMMIT;          
        END IF;          
  END;         
END;
/
