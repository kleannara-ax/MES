
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_IF_PUT_IFS019" (
	P_TYPE          IN        VARCHAR2,       --LIST,  SAVE
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
 * PROGRAM NAME  : 인터페이스-생산오더별 실적 TXN-예외생산
 * VERSION       : 1.0.0{최종 버전 기술}
 * DESCRIPTION   : SAP로 생산오더별 실적 TXN-예외생산 데이타 전송
 *                  
 *                  
 * AUTHOR NAME   : 강현주{최초 작성자 명 기술}
 * CREATE DATE   : 2022/05/12 {최초 작성일자 기술}
 * SYSTEM NAME   : MES
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}  <생략가능>
 * SUB PROCEDURE : {아휘 프로시저 명칭 기술}      <생략가능>
 * SUB PACKAGES  : {하위 패키지 기술}            <생략가능>
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술} <생략가능>
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/05/12    1.0.0   강현주         Initial Version 
 *==============================================================================
 *  관련 테이블    
 *       - [TB_IFS019]  : (.RU.) 생산오더별 실적 TXN-예외생산
 *=============================================================================*/

AS

    V_PLT_CD          VARCHAR2(100)  := 'I/F';                                    -- 단위업무
    V_PRG_NM          VARCHAR2(100)  := 'SP_IF_PUT_IFS019';                         -- PROCEDURE NAME


    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD      NUMBER(5)           := 0;
    E_SQL_ERR_MSG     VARCHAR2(4000);

    V_CNT             NUMBER              := 0;

BEGIN
   OPEN P_RS_LIST FOR 
   SELECT NULL FROM DUAL WHERE ROWNUM = 0;


    IF P_TYPE = 'LIST' THEN /*전송데이타 리스트*/
      BEGIN           
      OPEN P_RS_LIST FOR 
          SELECT  AUFNR														--오더 번호             
								 ,LOTNO                           --LOT 번호            
								 ,WERKS                           --플랜트(MES PK)       
								 ,BUDAT                           --생산일자(생산일시)(MES PK)
								 ,MATNR                           --자재코드              
								 ,MROLLCNT                        --MR 권치수            
								 ,PROQTY                          --생산 실적             
								 ,MEINS                           --생산 단위             
								 ,RUNTIME                         --가동시간              
								 ,OPNAM                           --작업자               
								 ,CONF                            --마지막생산여부           
								 ,SDATE                           --작업시작일자(생산시스템일자)   
								 ,STIME                           --작업시작시간(생산시스템시간)   
								 ,EDATE                           --작업종료일자(생산시스템일자)   
								 ,ETIME                           --작업종료시간(생산시스템시간)   
								 ,MDOCNO                          --MES 문서번호          
								 ,MDOCSEQ                         --MES 문서순번 
          			 ,RUECK                           --SAP 확정번호
          			 ,RMZHL               				    --SAP 확정카운터
                 ,ZRESULT
                 ,ZMESSAGE
                 ,ZRESULT_DATE
                 ,MAKE_DATE
                 ,MAKER
          FROM TB_IFS019                                              
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
        UPDATE TB_IFS019
        SET  RUECK        = P_RUECK
            ,RMZHL        = P_RMZHL
            ,ZRESULT      = P_ZRESULT           --SAP Return( S:성공, E:오류 )
            ,ZMESSAGE     = P_ZMESSAGE          --SAP결과 메시지
            ,ZRESULT_DATE = SYSDATE
            ,IF_MES_KEY   = P_IF_MES_KEY              
        WHERE MDOCNO    = P_MDOCNO
        AND   MDOCSEQ   = P_MDOCSEQ;
        
        
        --실적전송 성공시 MES운영 테이블에 정보 저장 삽입필수!!
        IF P_ZRESULT = 'S' THEN   
          SELECT count(WERKS) INTO V_CNT FROM TB_WRK002 WHERE DOC_NO = P_MDOCNO AND DOC_SEQNO  = P_MDOCSEQ; 
          
          IF V_CNT > 0 THEN    
            UPDATE TB_WRK002
            SET  SDOC_NO      = P_RUECK
                ,SDOC_SEQNO   = P_RMZHL
                ,UPDDATE = SYSDATE
                ,UPDID   = 'IFS019'
            WHERE DOC_NO = P_MDOCNO
            AND DOC_SEQNO  = P_MDOCSEQ;
          ELSE
            UPDATE TB_WRK001
            SET  SDOC_NO      = P_RUECK
                ,SDOC_SEQNO   = P_RMZHL
                ,UPDDATE = SYSDATE
                ,UPDID   = 'IFS019'
            WHERE DOC_NO = P_MDOCNO
            AND DOC_SEQNO  = P_MDOCSEQ;          
          END IF;   
          
          UPDATE TB_WRK021
          SET  SDOC_NO      = P_RUECK
              ,SDOC_SEQNO   = P_RMZHL
              ,UPDDATE = SYSDATE
              ,UPDID   = 'IFS019'
          WHERE DOC_NO = P_MDOCNO
          AND DOC_SEQNO  = P_MDOCSEQ;
        ELSE
          --ERROR발생시 'E'추가 작업수행 22-08-02    
          SELECT count(WERKS) INTO V_CNT FROM TB_WRK002 WHERE DOC_NO = P_MDOCNO AND DOC_SEQNO  = P_MDOCSEQ; 
          
          IF V_CNT > 0 THEN               
            UPDATE TB_WRK002
            SET  SDOC_NO      = P_ZRESULT
                ,UPDDATE = SYSDATE
                ,UPDID   = 'IFS019'
            WHERE DOC_NO = P_MDOCNO
            AND DOC_SEQNO  = P_MDOCSEQ; 
          ELSE
            UPDATE TB_WRK001
            SET  SDOC_NO      = P_ZRESULT
                ,UPDDATE = SYSDATE
                ,UPDID   = 'IFS019'
            WHERE DOC_NO = P_MDOCNO
            AND DOC_SEQNO  = P_MDOCSEQ;           
          END IF;  
          
          UPDATE TB_WRK021
          SET  SDOC_NO      = P_ZRESULT
              ,UPDDATE = SYSDATE
              ,UPDID   = 'IFS019'
          WHERE DOC_NO = P_MDOCNO
          AND DOC_SEQNO  = P_MDOCSEQ;                                 
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
        
        --ERROR발생시  'E'추가 작업수행 22-08-02  
        SELECT count(WERKS) INTO V_CNT FROM TB_WRK002 WHERE DOC_NO = P_MDOCNO AND DOC_SEQNO  = P_MDOCSEQ; 
        
        IF V_CNT > 0 THEN                       
          UPDATE TB_WRK002
          SET  SDOC_NO      = 'E'
              ,UPDDATE = SYSDATE
              ,UPDID   = 'IFS019'
          WHERE DOC_NO = P_MDOCNO
          AND DOC_SEQNO  = P_MDOCSEQ;
        ELSE
          UPDATE TB_WRK001
          SET  SDOC_NO      = 'E'
              ,UPDDATE = SYSDATE
              ,UPDID   = 'IFS019'
          WHERE DOC_NO = P_MDOCNO
          AND DOC_SEQNO  = P_MDOCSEQ;
        
        END IF;   
        
        UPDATE TB_WRK021
        SET  SDOC_NO      = 'E'
            ,UPDDATE = SYSDATE
            ,UPDID   = 'IFS019'
        WHERE DOC_NO = P_MDOCNO
        AND DOC_SEQNO  = P_MDOCSEQ;                      
        
      END;
    END IF;


END

;
/
