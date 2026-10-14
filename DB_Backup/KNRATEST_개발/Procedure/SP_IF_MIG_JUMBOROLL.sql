--------------------------------------------------------
--  DDL for Procedure SP_IF_MIG_JUMBOROLL
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_IF_MIG_JUMBOROLL" (   
 i_CMDKY            IN    VARCHAR2    /*  Common code key               */
,o_msg_CODE         OUT   VARCHAR2
,o_msg_MSG          OUT   VARCHAR2
) AS
/*==============================================================================
 * PROGRAM ID    : 마이그레이션
 * PROGRAM NAME  : PIS 초기재고 SETUP(점보롤)
 * VERSION       : 1.0.0
 * DESCRIPTION   : PIS 초기재고 SETUP(점보롤)
 *                 
 * AUTHOR NAME   : 강현주
 * CREATE DATE   : 2022/08/09
 * SYSTEM NAME   : MES
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}	<생략가능>
 * SUB PROCEDURE : {아휘 프로시저 명칭 기술}		<생략가능>
 * SUB PACKAGES  : {하위 패키지 기술}			<생략가능>
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술}	<생략가능>
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/08/09    1.0.0   강현주         Initial Version 
 *==============================================================================
 * 관련 테이블
 * - [TN_BARCODE] : (.R..)바코드                                
 * - [TN_BARCODE_LOT_ACTRSLT] : (.R..)바코드_LOT별 실적
 * - [TN_JUMBOROLL] : (.R..)점보롤 실적
 *=============================================================================*/
            
  
  E_EXCEPTION_USER  EXCEPTION;                        -- 사용자 에러 처리용 변수선언 영역 
                                                                                   
  V_CNT             NUMBER          := 0;             -- 카운트(존재여부체크)
  
  
   
BEGIN
  DECLARE
    CURSOR  CUR_DATA IS
      SELECT
         BAR.PLNT_CD          AS PLNT_CD     
        ,NVL((SELECT MAP_LOC_GB_CD FROM TB_MIG_MAP WHERE LOC_GB_CD = BAR.LOC_GB_CD AND LOC_CD = BAR.LOC_CD),'0000') AS LOC_GB_CD
        ,BAR.BARCODE          AS BARCODE      
        ,SIL.MTRIL_NO         AS MTRIL_NO      
        ,NVL((SELECT MAP_LOC_CD FROM TB_MIG_MAP WHERE LOC_GB_CD = BAR.LOC_GB_CD AND LOC_CD = BAR.LOC_CD),'0000') AS LOC_CD      
        ,SIL.LOT_ID           AS LOT_ID       
        ,(SELECT MACH_CD FROM TB_MAS012 WHERE WCS_WRK_CD = BAR.FCLT_CD) AS FCLT_CD       
        ,(SELECT MACHINE FROM TB_MAS012 WHERE WCS_WRK_CD = BAR.FCLT_CD) AS MCHN_CD      
        ,SUBSTR(SIL.WRKORD,-10) AS WRKORD       
        ,'N'                   AS IN_MR_YN          
        ,BAR.WORK_DT          AS WORK_DT      
        ,DECODE(BAR.MAKE_DT,null,BAR.WORK_DT,BAR.MAKE_DT) AS MAKE_DT      
        ,'M'                   AS UNIT       
        ,BARLOT.ACTRSLT_KG    AS TOT_ACTRSLT_KG
        ,BARLOT.ACTRSLT_M     AS ACTRSLT_M   
        ,SIL.RELIMP           AS RELIMP
        ,DECODE(BAR.STATUS,'0','00','1','00','2','00','3','00','4','00','6','00','7','00','9','00','B','00','C','00','00') AS STATUS  
        ,BAR.STATUS           AS MIG_STATUS  
      FROM TN_BARCODE BAR
          ,TN_BARCODE_LOT_ACTRSLT BARLOT
          ,TN_JUMBOROLL SIL
      WHERE BAR.BARCODE = BARLOT.BARCODE
      AND   BARLOT.LOT_ID = SIL.LOT_ID
      AND   BAR.STATUS IN('0','1','2','3','4','6','7','B','C')    
      AND   BAR.IF_STATUS IN ('N','E');

    
  BEGIN

    o_msg_msg       := '실행완료';
    o_msg_code      := '0' ; 
    
    FOR cur_row in CUR_DATA loop
      BEGIN 
      
        o_msg_msg       := '실행완료';
        o_msg_code      := '0' ; 
        
        --바코드,바코드_LOT실적에 구분할수 있는 공정구분자 삽입
        UPDATE TN_BARCODE
        SET IF_WRK_CD = 'JUMBOROLL'
        WHERE BARCODE = cur_row.BARCODE;
        
        UPDATE TN_BARCODE_LOT_ACTRSLT
        SET IF_WRK_CD = 'JUMBOROLL'
          , MIG_STATUS  =  cur_row.MIG_STATUS             
        WHERE BARCODE = cur_row.BARCODE
        AND LOT_ID = cur_row.LOT_ID;
        COMMIT;
                
        
        SELECT COUNT(1) INTO V_CNT FROM TB_INV001
        WHERE IND_BCD = cur_row.BARCODE;
        
        --기존에 재고에 등록되어 있으면 에러처리 함.
        IF V_CNT > 0 THEN
          RAISE E_EXCEPTION_USER;  
        END IF;
            
      
        INSERT INTO TB_INV001(  
           WERKS												 --플랜트코드                   
          ,STOR_LOC_CD                   --저장위치                     
          ,IND_BCD                       --개별바코드                   
          ,MATNR                         --제품코드                     
          ,LOC_CD                        --로케이션                     
          ,LOT_NO                        --LOT NO                       
          ,MACH_CD                       --설비코드                     
          ,MACHINE                       --생산호기                     
          ,ORDER_NO                      --오더번호                     
          ,IN_MR_YN                      --수입밀롤 여부                
          ,PRFM_DT                       --실적일자                     
          ,PRD_DT                        --제조(생산)일자               
          ,UNIT                          --단위                         
          ,STCK_QTY                      --재고수량                     
          ,ROLLCNT                       --권치수(점보롤, 밀롤, 합지기) 
          ,WGT                           --중량
          ,BS_WGT                        --평량  
          ,STCK_STA                      --재고상태                       
          ,REGDATE
          ,REGID
        )VALUES(
           cur_row.PLNT_CD
          ,cur_row.LOC_GB_CD
          ,cur_row.BARCODE
          ,cur_row.MTRIL_NO
          ,cur_row.LOC_CD
          ,cur_row.LOT_ID
          ,cur_row.FCLT_CD
          ,cur_row.MCHN_CD
          ,cur_row.WRKORD
          ,cur_row.IN_MR_YN
          ,cur_row.WORK_DT
          ,cur_row.MAKE_DT
          ,cur_row.UNIT   
          ,cur_row.ACTRSLT_M  
          ,cur_row.ACTRSLT_M
          ,cur_row.TOT_ACTRSLT_KG                     
          ,cur_row.RELIMP
          ,cur_row.STATUS          
          ,sysdate
          ,i_CMDKY                                                                                    
        );
            
        o_msg_msg  :=  '점보롤 정보가 이관되었습니다.';

        UPDATE  TN_BARCODE
        SET     IF_STATUS   =  'S'                                                 --I/F상태, N:신규, S:성공, E:오류               
              , IF_ERR_MESS =  o_msg_msg                                          --데이터 처리 결과 Message(Oracle)                         
        WHERE  BARCODE = cur_row.BARCODE;
        
        UPDATE TN_BARCODE_LOT_ACTRSLT
        SET     IF_STATUS   =  'S'                                                 --I/F상태, N:신규, S:성공, E:오류               
              , IF_ERR_MESS =  o_msg_msg                                          --데이터 처리 결과 Message(Oracle)   
        WHERE BARCODE = cur_row.BARCODE
        AND LOT_ID = cur_row.LOT_ID;       
        

        o_msg_msg       := '점보롤 정보가 이관되었습니다.';
        o_msg_code      := '0' ;
        COMMIT;

        EXCEPTION  
          WHEN E_EXCEPTION_USER THEN
                o_msg_msg  :=  i_CMDKY || '=>' || '점보롤 정보 이관중 기존재고 존재 확인되어 건너뜀 했습니다.' || ',' || SQLERRM ;
                o_msg_code := '-1' ;          
                DBMS_OUTPUT.PUT_LINE(o_msg_msg);
                ROLLBACK;

                UPDATE  TN_BARCODE
                SET     IF_STATUS   =  'E'                                      --I/F상태, N:신규, S:성공, E:오류                
                      , IF_ERR_MESS =  o_msg_msg                              --데이터 처리 결과 Message(Oracle)                                 
                WHERE  BARCODE = cur_row.BARCODE;
                
                UPDATE TN_BARCODE_LOT_ACTRSLT
                SET     IF_STATUS   =  'E'                                                 --I/F상태, N:신규, S:성공, E:오류               
                      , IF_ERR_MESS =  o_msg_msg                                          --데이터 처리 결과 Message(Oracle)                             
                WHERE BARCODE = cur_row.BARCODE
                AND LOT_ID = cur_row.LOT_ID;                  
                COMMIT;
                                          
          WHEN OTHERS THEN
                o_msg_msg  :=  i_CMDKY || '=>' || '점보롤 정보 이관중 오류가 발생 되었습니다.' || ',' || SQLERRM ;
                o_msg_code := '-1' ;
                DBMS_OUTPUT.PUT_LINE (o_msg_msg );
                ROLLBACK;

                UPDATE  TN_BARCODE
                SET     IF_STATUS   =  'E'                                      --I/F상태, N:신규, S:성공, E:오류               
                      , IF_ERR_MESS =  o_msg_msg                              --데이터 처리 결과 Message(Oracle)                                  
                WHERE  BARCODE = cur_row.BARCODE;
                
                UPDATE TN_BARCODE_LOT_ACTRSLT
                SET     IF_STATUS   =  'E'                                                 --I/F상태, N:신규, S:성공, E:오류               
                      , IF_ERR_MESS =  o_msg_msg                                          --데이터 처리 결과 Message(Oracle)                       
                WHERE BARCODE = cur_row.BARCODE
                AND LOT_ID = cur_row.LOT_ID;                
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
          o_msg_msg       := i_CMDKY || '=>' || '점보롤 정보 이관 중 MAIN에서 오류가 발생하였습니다.' || ',' || to_char(SQLCODE) || ',' || SQLERRM ;
          DBMS_OUTPUT.PUT_LINE(o_msg_msg);
          rollback ;
          
          SP_IF_MIG_LOG('SP_IF_MIG_JUMBOROLL','0',o_msg_msg);
          COMMIT;          
        END IF;          
  END;         
END;

/
