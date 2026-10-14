
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_IF_PUT_IFS023" (
	P_TYPE          IN        VARCHAR2,       --LIST,  SAVE
  P_MDOCNO        IN        VARCHAR2,       --MES문서번호
  P_MDOCSEQ       IN        VARCHAR2,       --MES문서순번
  P_MBLNR         IN        VARCHAR2,       --SAP 확정번호
  P_MJAHR         IN        VARCHAR2,       --SAP 확정카운터  
  P_ZRESULT       IN        VARCHAR2,       --SAP 결과값 Return( S:성공, E:오류 )
  P_ZMESSAGE      IN        VARCHAR2,       --SAP결과 메시지
	P_IF_MES_KEY    IN        VARCHAR2,       --I/F KEY  
	P_SUCCESS       OUT       VARCHAR2,       --작업성공/실패(Y:성공, N:실패)
	P_RS_LIST       OUT       SYS_REFCURSOR
)
/*==============================================================================
 * PROGRAM ID    : 
 * PROGRAM NAME  : 인터페이스-상품밀롤 리프트 출고
 * VERSION       : 1.0.0{최종 버전 기술}
 * DESCRIPTION   : SAP로 상품밀롤 리프트 출고 데이타 전송
 *                  
 *                  
 * AUTHOR NAME   : 강현주{최초 작성자 명 기술}
 * CREATE DATE   : 2022/05/23 {최초 작성일자 기술}
 * SYSTEM NAME   : MES
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}  <생략가능>
 * SUB PROCEDURE : {아휘 프로시저 명칭 기술}      <생략가능>
 * SUB PACKAGES  : {하위 패키지 기술}            <생략가능>
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술} <생략가능>
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/05/23    1.0.0   강현주         Initial Version 
 *==============================================================================
 *  관련 테이블    
 *       - [TB_IFS023]  : (.RU.) 상품밀롤 리프트 출고
 *=============================================================================*/

AS

    V_PLT_CD          VARCHAR2(100)  := 'I/F';                                  -- 단위업무
    V_PRG_NM          VARCHAR2(100)  := 'SP_IF_PUT_IFS023';                     -- PROCEDURE NAME


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
          SELECT  GUBUN														--구분( C. 생성 D. 취소(삭제))   
								 ,BARCO                           --Barcode No.         
                 ,MRLOT                           --M/R LOT Number      
                 ,BUDAT                           --전기일(Lift 출고일/밀롤 실적일)
                 ,ZFCONNO                         --컨테이너 No             
                 ,ZFBLNO                          --B/L 관리번호            
                 ,I_EBELN                         --STO 구매문서번호          
                 ,MATNR                           --자재코드                
                 ,ROLLN                           --Roll no.            
                 ,CPCOD                           --업체 지종               
                 ,ROLLC                           --M/R 권치수             
                 ,CORESIZE                        --지관 인치               
                 ,REMARK                                                    --비고                  
                 ,MDOCNO                          --MES 문서번호            
                 ,MDOCSEQ                         --MES 문서순번
                 ,ZRESULT
                 ,ZMESSAGE
                 ,ZRESULT_DATE
                 ,MAKE_DATE
                 ,MAKER
          FROM TB_IFS023                                              
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
        UPDATE TB_IFS023
        SET  MBLNR        = P_MBLNR
            ,MJAHR        = P_MJAHR
            ,ZRESULT      = P_ZRESULT           --SAP 결과값 Return( S:성공, E:오류 )
            ,ZMESSAGE     = P_ZMESSAGE          --SAP결과 메시지
            ,ZRESULT_DATE = SYSDATE             --SAP 전송 시간
            ,IF_MES_KEY   = P_IF_MES_KEY              
        WHERE MDOCNO    = P_MDOCNO
        AND MDOCSEQ   = P_MDOCSEQ;
        
        --실적전송 성공시 MES운영 테이블에 정보 저장 삽입필수!!          
        IF P_ZRESULT = 'S' THEN         
          UPDATE TB_WRK018
          SET  SDOC_NO      = P_MBLNR
              ,SDOC_SEQNO   = P_MJAHR
              ,UPDDATE = SYSDATE
              --,UPDID   = 'IFS023'
          WHERE DOC_NO = P_MDOCNO
          AND DOC_SEQNO  = P_MDOCSEQ;  
          
          UPDATE TB_WRK021
          SET  SDOC_NO      = P_MBLNR
              ,SDOC_SEQNO   = P_MJAHR
              ,UPDDATE = SYSDATE
              --,UPDID   = 'IFS023'
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
      END;
    END IF;


END

;
/
