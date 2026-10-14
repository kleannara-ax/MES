--------------------------------------------------------
--  DDL for Procedure SP_IF_PUT_IFS007
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_IF_PUT_IFS007" (
	P_TYPE          IN        VARCHAR2,       --LIST,  SAVE
	P_AUFNR         IN        VARCHAR2,       --오더번호
  P_MDOCNO        IN        VARCHAR2,       --MES문서번호
  P_MDOCSEQ       IN        VARCHAR2,       --MES문서순번
  P_RUECK         IN        VARCHAR2,       --SAP 확정번호
  P_RMZHL         IN        VARCHAR2,       --SAP 확정카운터
  P_ZRESULT       IN        VARCHAR2,       --SAP 결과값 Return( S:성공, E:오류 )
  P_ZMESSAGE      IN        VARCHAR2,       --SAP결과 메시지
	P_IF_MES_KEY    IN        VARCHAR2,       --I/F KEY   
	P_SUCCESS       OUT       VARCHAR2,       --작업성공/실패(Y:성공, N:실패)
	P_RS_LIST       OUT       SYS_REFCURSOR
)
/*==============================================================================
 * PROGRAM ID    : 
 * PROGRAM NAME  : 인터페이스-생산오더별 실적 취소 TXN
 * VERSION       : 1.0.0{최종 버전 기술}
 * DESCRIPTION   : SAP로 생산오더별 실적 취소 TXN 데이타 전송
 *                  
 *                  
 * AUTHOR NAME   : 강현주{최초 작성자 명 기술}
 * CREATE DATE   : 2022/05/02 {최초 작성일자 기술}
 * SYSTEM NAME   : MES
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}  <생략가능>
 * SUB PROCEDURE : {아휘 프로시저 명칭 기술}      <생략가능>
 * SUB PACKAGES  : {하위 패키지 기술}            <생략가능>
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술} <생략가능>
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/05/02    1.0.0   강현주         Initial Version 
 *==============================================================================
 *  관련 테이블    
 *       - [TB_IFS007]  : (.RU.) 생산오더별 실적 취소 TXN
 *=============================================================================*/

AS

    V_PLT_CD          VARCHAR2(100)  := 'I/F';                                     -- 단위업무
    V_PRG_NM          VARCHAR2(100)  := 'SP_IF_PUT_IFS007';                           -- PROCEDURE NAME


    V_CNT             NUMBER         := 0;                                      --존재유무 판단 값

    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD      NUMBER(5)           := 0;
    E_SQL_ERR_MSG     VARCHAR2(4000);



BEGIN
   OPEN P_RS_LIST FOR 
   SELECT NULL FROM DUAL WHERE ROWNUM = 0;


    IF P_TYPE = 'LIST' THEN /*전송데이타 리스트*/
      BEGIN           
      OPEN P_RS_LIST FOR 
          SELECT  WORKCENTERCODE                  --작업장코드(MES PK)          
                 ,EXPROD                          --KHJ 9/15추가 초과생산지시자
                 ,MERGECNC                        --KHJ 9/21추가 라벨병합 지시자
                 ,AUFNR                           --오더번호                        
                 ,ROLLCNT                         --권치수                         
                 ,MBLNR                           --자재 문서 번호                                              
                 ,MDOCNO                          --MES 문서번호                    
                 ,MDOCSEQ                         --MES 문서순번     
                 ,RUECK                           --SAP 확정번호
                 ,RMZHL               				    --SAP 확정카운터
                 ,ZRESULT
                 ,ZMESSAGE
                 ,ZRESULT_DATE
                 ,MAKE_DATE
                 ,MAKER
                 ,LOTNO                           --LOT번호
          FROM TB_IFS007                                              
          WHERE ZRESULT = 'N'
          --WHERE ZRESULT IN('N','E')                 --E목록은 제외하고 인터페이스 스케줄이 구동되고 있어야 될꺼 같음. Error발생부분 수정해서 다시 E->N으로 변경후 보내는게 맞는듯.           
      ;

        P_SUCCESS           := 'Y';

      EXCEPTION           
      WHEN OTHERS THEN 
        P_SUCCESS           := 'N';
        
        --E_SQL_ERR_CD        := SQLCODE;
        E_SQL_ERR_CD        := -20000;
        E_SQL_ERR_MSG       := 'EXCEPTION LIST ERROR. [' || SQLCODE || ']' || SUBSTR(SQLERRM,1,500);
        SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_PRG_NM);

        ROLLBACK;
        RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);           
      END;    
    ELSIF P_TYPE = 'SAVE' THEN
      BEGIN
        UPDATE TB_IFS007
        SET  ZRESULT      = P_ZRESULT
            ,ZMESSAGE     = P_ZMESSAGE
            ,ZRESULT_DATE = SYSDATE
            ,IF_MES_KEY   = P_IF_MES_KEY              
        WHERE MDOCNO    = P_MDOCNO
        AND MDOCSEQ   = P_MDOCSEQ;
        
        --실적취소전송 성공시 MES운영 테이블에 정보 삭제 삽입필수!!
        IF P_ZRESULT = 'S' THEN  
          SELECT COUNT(WERKS) INTO V_CNT 
          FROM TB_WRK001
          WHERE DOC_NO = P_MDOCNO
          AND DOC_SEQNO  = P_MDOCSEQ;
          
          IF V_CNT > 0 THEN
            UPDATE TB_WRK001
            SET SDOC_NO = NULL
               ,SDOC_SEQNO = NULL
               ,UPDDATE = SYSDATE
               ,UPDID   = 'IFS007'               
            WHERE DOC_NO = P_MDOCNO
            AND DOC_SEQNO  = P_MDOCSEQ;                
          END IF;

          SELECT COUNT(WERKS) INTO V_CNT 
          FROM TB_WRK002
          WHERE DOC_NO = P_MDOCNO
          AND DOC_SEQNO  = P_MDOCSEQ;
          
          IF V_CNT > 0 THEN
            UPDATE TB_WRK002
            SET SDOC_NO = NULL
               ,SDOC_SEQNO = NULL
               ,UPDDATE = SYSDATE
               ,UPDID   = 'IFS007'                
            WHERE DOC_NO = P_MDOCNO
            AND DOC_SEQNO  = P_MDOCSEQ;        
            
            UPDATE TB_WRK021
            SET SDOC_NO = NULL
               ,SDOC_SEQNO = NULL
               ,UPDDATE = SYSDATE
               ,UPDID   = 'IFS007'                
            WHERE DOC_NO = P_MDOCNO
            AND DOC_SEQNO  = P_MDOCSEQ;                      
          END IF;                                      
        END IF;
        
        P_SUCCESS := 'Y';
        COMMIT;

      EXCEPTION
      WHEN OTHERS THEN
        P_SUCCESS           := 'N';
        
        --E_SQL_ERR_CD        := SQLCODE;
        E_SQL_ERR_CD        := -20001;
        E_SQL_ERR_MSG       := 'EXCEPTION SAVE ERROR. [' || SQLCODE || ']' || SUBSTR(SQLERRM,1,500);
        SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_PRG_NM);

        ROLLBACK;
        RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);        
      END;
    END IF;


END

;

/
