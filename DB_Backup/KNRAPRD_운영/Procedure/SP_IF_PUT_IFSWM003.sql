--------------------------------------------------------
--  DDL for Procedure SP_IF_PUT_IFSWM003
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_IF_PUT_IFSWM003" (
	P_TYPE          IN        VARCHAR2,       --LIST,  SAVE
  P_DOCNO         IN        VARCHAR2,       --MES문서번호
  P_DOCSEQ        IN        VARCHAR2,       --MES문서순번
  P_IF_STATUS     IN        VARCHAR2,       --결과값 Return( S:성공, E:오류 )
  P_IF_ERR_MESS   IN        VARCHAR2,       --결과 메시지
	P_IF_MES_KEY    IN        VARCHAR2,       --I/F KEY  
	P_SUCCESS       OUT       VARCHAR2,       --작업성공/실패(Y:성공, N:실패)
	P_RS_LIST       OUT       SYS_REFCURSOR
)
/*==============================================================================
 * PROGRAM ID    : 
 * PROGRAM NAME  : 인터페이스-자재 불출 요청(음성공장)
 * VERSION       : 1.0.0{최종 버전 기술}
 * DESCRIPTION   : 자재 불출 요청(음성공장) 정보 데이타 전송
 *                  
 *                  
 * AUTHOR NAME   : 강현주{최초 작성자 명 기술}
 * CREATE DATE   : 2022/05/18 {최초 작성일자 기술}
 * SYSTEM NAME   : MES->WMS
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}  <생략가능>
 * SUB PROCEDURE : {아휘 프로시저 명칭 기술}      <생략가능>
 * SUB PACKAGES  : {하위 패키지 기술}            <생략가능>
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술} <생략가능>
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/05/18    1.0.0   강현주         Initial Version 
 *==============================================================================
 *  관련 테이블    
 *       - [TB_IFSWM003]  : (.RU.) 자재 불출 요청(음성공장)
 *=============================================================================*/

AS

    V_PLT_CD          VARCHAR2(100)  := 'I/F';                                     -- 단위업무
    V_PRG_NM          VARCHAR2(100)  := 'SP_IF_PUT_IFSWM003';                        -- PROCEDURE NAME

    V_IND_BCD           TB_INV003.IND_BCD%TYPE;
    V_CNT               NUMBER;
    
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
          SELECT DOC_NO     											--MES 문서번호                       
                ,DOC_SEQNO                        --MES 문서순번                       
                ,MATNR                            --품목코드                           
                ,QTY                              --불출요청량                          
                ,UNIT                             --단위                             
                ,DLFL                             --삭제 지시자(불출요청)                   
                ,ORDER_NO                         --오더번호(생산작업지시번호)                 
                ,ORDER_SEQNO                      --오더번호 순번(생산작업지시순번)              
                ,STOR_LOC                         --저장위치(공정창고)                     
                ,WERKS                            --플랜트                            
                ,STCK_STA                         --재고상태 (00정상 30불용 05품질 50폐기 10보류)
                ,NTN_CD                           --국가코드                           
                ,CRSPD_CD                         --거래처코드MTO                       
                ,PRDC_DT                          --제조일자                           
                ,RCVGDS_DT                        --입고일자                           
                ,DSTBT_DDLIN                      --유통기한 (생리대,기저귀,물티슈)             
                ,IND_BCD                          --개별바코드 (협력업체바코드)                
                ,LOT_NO                           --LOT번호/SAP 배치번호                 
                ,STOK_KY                          --Stock key                      
                ,LOT_NUM                          --WMS LOT속성코드   				
          FROM TB_IFSWM003
          WHERE IF_STATUS IN('N')
          --WHERE IF_STATUS IN('N','E')            
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
        UPDATE TB_IFSWM003
           SET IF_STATUS    = P_IF_STATUS
              ,IF_ERR_MESS  = P_IF_ERR_MESS
              ,IF_SET_DATE  = SYSDATE
              ,IF_MES_KEY   = P_IF_MES_KEY
         WHERE DOC_NO    = P_DOCNO
           AND DOC_SEQNO = P_DOCSEQ;

        --실적전송 성공시 MES운영 테이블에 정보 저장 삽입필수!!


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
