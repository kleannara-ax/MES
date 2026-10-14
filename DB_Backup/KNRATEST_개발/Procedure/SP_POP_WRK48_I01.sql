--------------------------------------------------------
--  DDL for Procedure SP_POP_WRK48_I01
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_POP_WRK48_I01" 
(
     P_WERKS     		IN VARCHAR2 	                --플랜트
    ,P_MACH_CD   		IN VARCHAR2 	                --설비코드
    ,P_IND_BCD_LIST     IN CLOB			   	            --개별바코드 리스트
    ,P_USERID           IN VARCHAR2                     --USER ID
    ,Lang       		IN VARCHAR2 DEFAULT 'KO'
    ,RS_CODE     		OUT VARCHAR2 
    ,RS_MSG      		OUT VARCHAR2
)
/*==============================================================================
 * PROGRAM ID    : SP_POP_WRK48_I01{호출 프로그램 ID 기술}
 * PROGRAM NAME  : 실적취소 
 * VERSION       : 1.0.0{최종 버전 기술}
 * DESCRIPTION   : .{프로그램에 대한 상세한 내용 기술}
 *                 
 * AUTHOR NAME   : 박충식{최초 작성자 명 기술}
 * CREATE DATE   : 2022/06/29 {최초 작성일자 기술}
 * SYSTEM NAME   : POP
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}  <생략가능>
 * SUB PROCEDURE : {아휘 프로시저 명칭 기술}      <생략가능>
 * SUB PACKAGES  : {하위 패키지 기술}            <생략가능>
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술} <생략가능>
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/06/20    1.0.0   박충식         Initial Version 
 *==============================================================================
 *  관련 테이블
 *       - [TB_WRK011] : (.RU.) 설비별 현재진행사항 
 *       - [TB_WRK012] : (C.U.) 설비별 현재진행사항 
 *       - [TB_SCH016] : (.R..) 밀롤,슬리터 작업지지서
 *=============================================================================*/

AS 
    --프로그램 ID : 슬리터 실적등록
    V_PRG_NM        VARCHAR2(100)  := 'SP_POP_WRK48_I01';     -- PROCEDURE NAME
    V_PLT_CD         varchar2(2) := '99'; --PLANTCODE TEST
    V_SESS_USER_ID   varchar2(20) := 'TEST'; --USERID

    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD      NUMBER(5) := 0;
    E_SQL_ERR_MSG     VARCHAR2(4000);

    -- JSON을 위한 변수선언 영역
    V_JSON           JSON_OBJECT_T;
    V_ARR_LIST       JSON_ARRAY_T;
    V_ARR_HEAD       JSON_OBJECT_T;
    V_OBJ            JSON_OBJECT_T;

    --parameter변수 처리
    V_WERKS             TB_WRK002.WERKS%TYPE;        -- 플랜트코드    
    V_MACH_CD           TB_WRK002.MACH_CD%TYPE;      -- 설비코드  
    V_IND_BCD           TB_WRK002.MACH_CD%TYPE;      -- 개별바코드

    V_WRK_ORDR_NO           TB_SCH015.WRK_ORDR_NO%TYPE;         
    V_WRK_ORDR_SEQNO        TB_SCH015.WRK_ORDR_SEQNO%TYPE;      
    V_ORDER_NO              TB_WRK002.ORDER_NO%TYPE;
    V_STA                   TB_WRK002.STA%TYPE;
    V_SDOC_NO               TB_WRK002.SDOC_NO%TYPE;
    V_SDOC_SEQNO            TB_WRK002.SDOC_SEQNO%TYPE;
    V_SAP_WRK_CD            TB_MAS012.SAP_WRK_CD%TYPE;
    V_ROLLCNT	            TB_WRK002.ROLLCNT%TYPE;		    --권치수
    V_DOC_NO                VARCHAR2(20);
    V_DOC_SEQNO             NUMBER;

    /*V_MATNR                     TB_WRK002.MATNR%TYPE;
    V_WRK_ORDR_NO               TB_WRK002.WRK_ORDR_NO%TYPE;
    V_WRK_ORDR_SEQNO            TB_WRK002.WRK_ORDR_SEQNO%TYPE;
    V_ORDER_NO                  TB_WRK002.ORDER_NO%TYPE;
    V_ORDER_NO_MR               TB_WRK002.ORDER_NO%TYPE;

    V_REGDATE           DATE := SYSDATE;
    */
BEGIN
  BEGIN
    V_JSON := JSON_OBJECT_T.parse(P_IND_BCD_LIST);
    V_SESS_USER_ID       :=       V_JSON.get_string('SES_USER_ID');
    V_WERKS              :=       V_JSON.get_string('WERKS');
    V_MACH_CD              :=       V_JSON.get_string('MACH_CD');

    V_ARR_LIST        := V_JSON.get_array('list');    

    FOR i IN 0..V_ARR_LIST.get_size-1 LOOP    
        V_OBJ           := TREAT (V_ARR_LIST.get (i) AS json_object_t);
        V_OBJ           := TREAT (V_OBJ.get ('map') AS json_object_t);

        V_IND_BCD       := V_OBJ.get_string('IND_BCD');

        SELECT WRK_ORDR_NO, WRK_ORDR_SEQNO, ORDER_NO, STA, SDOC_NO, SDOC_SEQNO, ROLLCNT
          INTO V_WRK_ORDR_NO, V_WRK_ORDR_SEQNO, V_ORDER_NO, V_STA, V_SDOC_NO, V_SDOC_SEQNO, V_ROLLCNT
          FROM TB_WRK002
         WHERE WERKS = P_WERKS
           AND MACH_CD = P_MACH_CD
           AND IND_BCD = V_IND_BCD
           ;

        SELECT SAP_WRK_CD INTO V_SAP_WRK_CD
          FROM TB_MAS012
          WHERE MACH_CD = P_MACH_CD;

        IF V_STA = '00' THEN  

            V_DOC_NO := FN_GET_MDOCNO('M','IF129');
            V_DOC_SEQNO := 1;

             INSERT INTO TB_IFS007(RUECK                        --SAP 확정번호
                                 , RMZHL                        --SAP 확정카운터
                                 , MDOCNO                       --MES 문서번호
                                 , MDOCSEQ                      --MES 문서순번
                                 , MAKE_DATE                    --등록일자 
                                 , MAKER                        --등록자
                                 , WORKCENTERCODE               --작업장코드(MES PK)
                                 , AUFNR                        --오더번호
                                 , ROLLCNT                      --권치수
                                 , MBLNR)                       --MBLNR
             VALUES(               V_SDOC_NO                    --SAP 확정번호
                                 , V_SDOC_SEQNO                 --SAP 확정카운터 
                                 , V_DOC_NO                     --MES 문서번호
                                 , V_DOC_SEQNO                  --MES 문서순번 
                                 , SYSDATE                      --등록일자 
                                 , V_SESS_USER_ID               --등록자
                                 , V_SAP_WRK_CD                 --작업장코드(MES PK)
                                 , V_ORDER_NO                   --오더번호
                                 , V_ROLLCNT                    --권치수
                                 , V_SDOC_NO);                  --MBLNR   

             RS_CODE       := 'E';
             RS_MSG       := '후공정에 투입되어 실적취소를 할 수 없습니다.';
             ROLLBACK;
             RETURN;


        ELSIF V_STA = '10' THEN   
             RS_CODE       := 'E';
             RS_MSG       := '후공정에 투입되어 실적취소를 할 수 없습니다.';
             ROLLBACK;
             RETURN;
        ELSIF V_STA = '20' THEN 
             RS_CODE       := 'E';
             RS_MSG       := '후공정에서 실적완료 되어 실적취소를 할 수 없습니다.';
             ROLLBACK;
             RETURN;
        END IF;   

        --TB_IFS007    --생산오더별실적 취소


        --TB_WRK002    --실적테이블(PS)        
        --TB_INV001    --창고별 재고현황
        --TB_WRK021    --문서이력
        --TB_IFS007   --생산오더별실적 취소
    END LOOP;
    RS_CODE := 'S';
    COMMIT;    

    --예외처리(catch)
    EXCEPTION
    WHEN E_EXCEPTION_USER THEN
        -- 에러 내역 SET
        E_SQL_ERR_CD        := SQLCODE;
        E_SQL_ERR_MSG       := SUBSTRB(SQLERRM,1,300);

        ROLLBACK;
        SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);

        RS_CODE := 'E';
        RS_MSG  := SQLERRM;
        RETURN;
    WHEN OTHERS THEN
        E_SQL_ERR_CD        := SQLCODE;
        E_SQL_ERR_MSG       := 'EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';

        ROLLBACK;
        --RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);
        RAISE;

        RS_CODE := 'E';
        RS_MSG  := SQLERRM;
        RETURN;
    --예외처리 종료
    END;
END;

/
