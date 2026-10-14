--------------------------------------------------------
--  DDL for Procedure SP_SCH19_S01
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_SCH19_S01" (
	P_TYPE         IN    varchar2, -- LIST, SUB_LIST-A, SUB_LIST-B
	P_JSON_STR     IN    CLOB,
	P_SUCCESS      OUT    varchar2,
	P_RS_LIST      OUT    SYS_REFCURSOR 
)
/*==============================================================================
 * PROGRAM ID    : SP_SCH19_S01{호출 프로그램 ID 기술}
 * PROGRAM NAME  : 공정투입대비 실적 {호출 프로그램 명 기술}
 * VERSION       : 1.0.0{최종 버전 기술}
 * DESCRIPTION   : 공정투입대비 실적현황 {프로그램에 대한 상세한 내용 기술}
 *                 
 * AUTHOR NAME   : 박성철{최초 작성자 명 기술}
 * CREATE DATE   : 2022/07/18 {최초 작성일자 기술}
 * SYSTEM NAME   : MES
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}  <생략가능>
 * SUB PROCEDURE : {아휘 프로시저 명칭 기술}      <생략가능>
 * SUB PACKAGES  : {하위 패키지 기술}            <생략가능>
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술} <생략가능>
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * yyyy/mm/dd    1.0.0   박성철         Initial Version 
 *==============================================================================
 *  관련 테이블
 *=============================================================================*/

AS

    V_PRG_NM          VARCHAR2(100)  := 'SP_SCH19_S01';     -- PROCEDURE NAME


    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD      NUMBER(5)           := 0;
    E_SQL_ERR_MSG     VARCHAR2(4000);

    -- JSON을 위한 변수선언 영역
    V_JSON           JSON_OBJECT_T;
    V_ARR_LIST       JSON_ARRAY_T;
    V_ARR_HEAD       JSON_ARRAY_T;
    V_OBJ            JSON_OBJECT_T;

    -- 세션값 처리용 변수선언 영역
    V_SQL            CLOB;
    V_RUN_SQL        varchar2(1);
    V_RANGE_SQL      varchar2(4000);
    V_DEBUG          varchar2(1);

    -- 세션값 처리용 변수선언 영역
    V_PLT_CD         varchar2(2);
    V_SESS_USER_ID   varchar2(20);

   -- 조건절 처리용 변수선언 영역
   V_WERKS        	TB_MAS001.WERKS%TYPE;       --플랜트 
   V_MACH_CD    	TB_MAS012.MACH_CD%TYPE; 	--설비코드 
   V_PROC_CD        TB_MAS013.PROC_CD%TYPE;     --공정코드 


    -- 리스트(그리드)의 값을 할당하기 위한 변수선언 영역

BEGIN
    OPEN P_RS_LIST FOR 

    SELECT NULL FROM DUAL WHERE ROWNUM = 0;

    V_DEBUG := 'N';
    V_RUN_SQL := 'Y';

    V_JSON := JSON_OBJECT_T.parse(P_JSON_STR);

    V_SESS_USER_ID       :=      V_JSON.get_string('SES_USER_ID');
    V_PLT_CD             :=      V_JSON.get_string('SES_PLNTKY');

   /* 조건값 할당 */
   V_RANGE_SQL 		    :=       V_JSON.get_string('RANGE_SQL');   	--작업지시번호, 작업지시번호 순번

   V_WERKS   		:=       V_JSON.get_string('WERKS');	     --플랜트   
   V_MACH_CD    	:=       V_JSON.get_string('MACH_CD');   	 --설비코드 
   V_PROC_CD  		:=       V_JSON.get_string('PROC_CD');		 --공정코드    


    IF P_TYPE = 'LIST' THEN /*상단 조회 리스트*/
        IF V_WERKS = 'P100' THEN
            V_SQL :=  ' SELECT * 
                          FROM (SELECT 
                                       INV003.WERKS            --플랜트
                                     , MAS013.PROC_CD          --공정코드
                                     , MAS013.PROC_NM          --공정명
                                     , MAS012.MACH_CD          --설비코드
                                     , MAS012.MACH_NM          --설비명
                                     , MAS001.MATNR            --자재코드
                                     , MAS001.MATNR_NM         --자재명
                                     , INV003.IND_BCD          --업체/개별 바코드
                                     , WRK002.ORDER_NO         --오더번호
                                     , WRK002.PRD_DT           --생산일자
                                     , INV003.WRK_ORDR_NO      --작업지시번호
                                     , INV003.WRK_ORDR_SEQNO   --작업지시순번
                                     , INV003.LOT_NO           --LOT_NO
                                     , INV003.UNIT             --단위
                                     , INV003.SEQNO            --순번
                                     , INV003.IN_QTY           --투입량
                                     , INV003.USE_QTY          --사용량
                                     , INV003.STCK_QTY         --재고량
                                     , WRK002.UNIT  RESL_UNIT  --실적단위
                                     , WRK002.PRFM_QTY         --실적수량
                                     , WRK002.PCNT             --연수
                                     , WRK002.SCNT             --속수
                                     , WRK002.MCNT             --매
                                     , WRK002.WIDTH            --실 지폭
                                     , WRK002.ROLLCNT          --권치수
                                     , WRK002.WGT       WGT --중량
                                  FROM TB_INV003 INV003      --자재투입
                                  JOIN TB_MAS012 MAS012      --설비마스터
                                    ON MAS012.MACH_CD = INV003.MACH_CD
                                  LEFT JOIN TB_WRK002 WRK002  --실적테이블(PS)
                                    ON WRK002.WERKS = INV003.WERKS
                            --	   AND WRK002.MACH_CD = INV003.MACH_CD
                                   AND WRK002.IND_BCD = INV003.IND_BCD
                                  LEFT JOIN TB_MAS013 MAS013 --공정마스터
                                    ON MAS013.PROC_CD = MAS012.PROC_CD
                                  LEFT JOIN TB_MAS001 MAS001 --자재마스터
                                    ON MAS001.MATNR = INV003.MATNR
                                   AND MAS001.WERKS = INV003.WERKS
                                )
                          WHERE 1=1
                            AND WERKS = ''P100'' ';
        ELSE
            V_SQL :=  ' SELECT *
                          FROM (SELECT 
                                       INV003.WERKS            --플랜트
                                     , MAS013.PROC_CD          --공정코드
                                     , MAS013.PROC_NM          --공정명
                                     , MAS012.MACH_CD          --설비코드
                                     , MAS012.MACH_NM          --설비명
                                     , MAS001.MATNR            --자재코드
                                     , MAS001.MATNR_NM         --자재명
                                     , INV003.IND_BCD          --업체/개별 바코드
                                     , WRK001.ORDER_NO         --오더번호
                                     , WRK001.ORDER_SEQNO      --오더번호순번
                                     , WRK001.PRD_DT           --생산일자
                                     , INV003.WRK_ORDR_NO      --작업지시번호
                                     , INV003.WRK_ORDR_SEQNO   --작업지시순번
                                     , INV003.LOT_NO           --LOT_NO
                                     , INV003.UNIT             --단위
                                     , INV003.SEQNO            --순번
                                     , INV003.IN_QTY           --투입량
                                     , INV003.USE_QTY          --사용량
                                     , INV003.STCK_QTY         --재고량
                                     , WRK001.UNIT  RESL_UNIT  --실적단위
                                     , WRK001.PLT_QTY          --PLT수량
                                     , WRK001.BOX_QTY          --BOX수량
                                     , WRK001.BAG_QTY          --BAG수량
                                     , WRK001.EA_QTY           --EA수량
                                     , WRK001.WGT       WGT --중량
                                  FROM TB_INV003 INV003      --자재투입
                                  JOIN TB_MAS012 MAS012      --설비마스터
                                    ON MAS012.MACH_CD = INV003.MACH_CD
                                  LEFT JOIN TB_WRK001 WRK001 --실적테이블(HL)
                                    ON WRK001.WERKS = INV003.WERKS
                            --	   AND WRK001.MACH_CD = INV003.MACH_CD
                                   AND WRK001.IND_BCD = INV003.IND_BCD
                                  LEFT JOIN TB_MAS013 MAS013 --공정마스터
                                    ON MAS013.PROC_CD = MAS012.PROC_CD
                                  LEFT JOIN TB_MAS001 MAS001 --자재마스터
                                    ON MAS001.MATNR = INV003.MATNR
                                   AND MAS001.WERKS = INV003.WERKS
                                )
                           WHERE 1=1
                             AND WERKS != ''P100'' ';
        END IF;

		IF  V_WERKS IS NOT NULL OR TRIM(V_WERKS) != '' THEN
            V_SQL := V_SQL || ' AND WERKS = ''' || V_WERKS || '''';	    --플랜트   
        END IF;

		IF  V_MACH_CD IS NOT NULL OR TRIM(V_MACH_CD) != '' THEN
            V_SQL := V_SQL || ' AND MACH_CD LIKE ''%' || V_MACH_CD || '%''';	--설비코드   
        END IF;

		IF  V_PROC_CD IS NOT NULL OR TRIM(V_PROC_CD) != '' THEN
            V_SQL := V_SQL || ' AND PROC_CD LIKE ''%' || V_PROC_CD || '%''';	--공정코드   
        END IF;
        
        IF  V_RANGE_SQL IS NOT NULL OR TRIM(V_RANGE_SQL) != '' THEN
            V_SQL := V_SQL || V_RANGE_SQL ;			        
        END IF;


        V_SQL := V_SQL || ' ORDER BY WERKS, PROC_CD, MACH_CD';  


        V_DEBUG := 'Y';

        IF (V_DEBUG = 'Y') THEN
            INSERT INTO PROC_LOG(SQL_STR) VALUES (V_SQL);
        END IF;


		OPEN P_RS_LIST FOR V_SQL;


--    ELSIF P_TYPE = 'SAVE' THEN
--    	RETURN;


    END IF;


    P_SUCCESS := 'Y';


    EXCEPTION
    WHEN E_EXCEPTION_USER THEN

        -- 에러 내역 SET
	    P_SUCCESS           := 'N';
        E_SQL_ERR_CD        := SQLCODE;
        E_SQL_ERR_MSG       := SUBSTRB(SQLERRM,1,300);

        ROLLBACK;
        SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);

    WHEN OTHERS THEN
	    P_SUCCESS           := 'N';
        E_SQL_ERR_CD        := SQLCODE;
        E_SQL_ERR_MSG       := 'EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';

        ROLLBACK;
        RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);
END;

/
