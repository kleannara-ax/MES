--------------------------------------------------------
--  DDL for Procedure SP_QLT15_S01
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_QLT15_S01" (
	P_TYPE           IN    varchar2, -- LIST,  SAVE
	P_JSON_STR       IN    CLOB,
	P_SUCCESS       OUT    varchar2,
	P_RS_LIST       OUT    SYS_REFCURSOR
)
/*==============================================================================
 * PROGRAM ID    : QLT15{호출 프로그램 ID 기술}
 * PROGRAM NAME  : 부적합 리스트 조회{호출 프로그램 명 기술}
 * VERSION       : 1.0.0{최종 버전 기술}
 * DESCRIPTION   : 부적합으로 판정된 내역을 조회하여 부적합 처리내역을 추가적으로 등록한다. 
 *                  
 *                 
 * AUTHOR NAME   : 김성하{최초 작성자 명 기술}
 * CREATE DATE   : 2022/04/28 {최초 작성일자 기술}
 * SYSTEM NAME   : MES
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}  <생략가능>
 * SUB PROCEDURE : {아휘 프로시저 명칭 기술}      <생략가능>
 * SUB PACKAGES  : {하위 패키지 기술}            <생략가능>
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술} <생략가능>
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * yyyy/mm/dd    1.0.0   김성하         Initial Version 
 *==============================================================================
 *  관련 테이블
 *       - [CMCDV]      : (.R..) 공통코드
 *       - [USRMA]      : (.R..) 사용자 정보     
 *       - [TB_MAS001]  : (.R..) 자재 마스트
 *       - [TB_MAS018]  : (.R..) 부서정보
 *       - [TB_MAS028]  : (.R..) 공정대기 창고 위치정보
 *       - [TB_QLT020]  : (.R..) 품질검사 결과 마스터
 *       - [TB_QLT024]  : (.RU.) 부적합 발생이력
 *=============================================================================*/

AS

    V_PRG_NM          VARCHAR2(100)  := 'SP_QLT15_S01';     -- PROCEDURE NAME

    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD      NUMBER(5)           := 0;
    E_SQL_ERR_MSG     VARCHAR2(4000);


   -- V_RTN_CLOB       CLOB;
   -- V_RTN_CURSOR     SYS_REFCURSOR;
   -- V_ERROR          CLOB;


    -- JSON을 위한 변수선언 영역
    V_JSON           JSON_OBJECT_T;
    V_ARR_LIST       JSON_ARRAY_T;
    V_ARR_HEAD       JSON_OBJECT_T;
    V_OBJ            JSON_OBJECT_T;
    V_OBJ_HEAD       JSON_OBJECT_T;

    -- 세션값 처리용 변수선언 영역
    V_SQL            CLOB;
    V_RUN_SQL        varchar2(1);
    V_RANGE_SQL      varchar2(4000);
    V_DEBUG          varchar2(1);

    -- 세션값 처리용 변수선언 영역
    V_PLT_CD         varchar2(2);
    V_SESS_USER_ID   varchar2(20);

    -- 조건절 처리용 변수선언 영역
    V_WERKS            TB_QLT024.WERKS%TYPE; -- 플랜트코드
    V_REG_YN           VARCHAR2(1);          -- 등록여부


    V_MATNR            TB_QLT024.MATNR%TYPE; -- 자재코드
    
    V_UCFMTY_AMT       TB_QLT024.UCFMTY_AMT%TYPE;
    V_PRC_MTD          TB_QLT024.PRC_MTD%TYPE;
    V_COMPKY           TB_QLT024.COMPKY%TYPE;
    V_DEPT_CD          TB_QLT024.DEPT_CD%TYPE;
    V_RMK              TB_QLT024.RMK%TYPE;

    V_MSRM_DATE        TB_QLT024.MSRM_DATE%TYPE;
    V_PRC_SEQNO        TB_QLT024.PRC_SEQNO%TYPE;
    V_MSRM_DT          VARCHAR2(20) := '';
    V_SDATE            VARCHAR2(30);
    V_EDATE            VARCHAR2(30);


    --기타처리
    V_CREATE_FLG       CHAR(1)  := 'N';
    V_UPDATE_FLG       CHAR(1)  := 'N';

BEGIN
   OPEN P_RS_LIST FOR 
   SELECT NULL FROM DUAL WHERE ROWNUM = 0;

   V_DEBUG := 'N';
   V_RUN_SQL := 'Y';

   V_JSON := JSON_OBJECT_T.parse(P_JSON_STR);

   V_SESS_USER_ID       :=       V_JSON.get_string('SES_USER_ID');
   V_PLT_CD             :=       V_JSON.get_string('SES_WAREKY');

   /* 조건값 할당 */
   V_RANGE_SQL          :=       V_JSON.get_string('RANGE_SQL'); -- 플랜트코드
   V_WERKS              :=       V_JSON.get_string('WERKS');     -- 플랜트코드
   V_SDATE              :=       V_JSON.get_string('SDATE');     -- 측정일시(시작)
   V_EDATE              :=       V_JSON.get_string('EDATE');     -- 측정일시(끝)
   V_MATNR              :=       V_JSON.get_string('MATNR');     -- 자재코드

   IF P_TYPE = 'LIST' THEN /*상단 조회 리스트*/

      V_SQL := 'SELECT  Q024.WERKS     AS "WERKS",       -- 플랜트
                        Q024.MSRM_DATE AS "MSRM_DATE",   -- 측정일시 
                        Q024.MATNR     AS "MATNR",       -- 자재코드
                        M001.MATNR_NM  AS "MATNR_NM",    -- 자재명
                        Q024.PRC_SEQNO AS "PRC_SEQNO",   -- 처리순번(H)
                        M001.UNIT      AS "UNIT",        -- 단위(H)
                       (SELECT CDESC1 FROM CMCDV WHERE CMCDKY = ''UNIT''  AND CMCDVL = M001.UNIT) AS "UNIT_NM",
                        I001.STCK_QTY  AS PRFM_QTY,      -- (재고)실적수량
                        Q024.UCFMTY_AMT                           AS "UCFMTY_AMT",   -- 부적합수량
                        NVL(Q024.LOT_NO, Q024.VND_LOT_NO)         AS "LOT_NO",       -- LOT 번호
                        NVL(Q024.IND_BCD, Q024.SUPY_VND_BCD)      AS "IND_BCD",      -- 개별바코드
                        Q024.VND_LOT_NO                           AS "VND_LOT_NO",   -- 공급업체LOT번호
                        Q024.SUPY_VND_BCD                         AS "SUPY_VND_BCD", -- 공급업체바코드
                        Q024.DEPT_CD                              AS "DEPT_CD",      -- 부서코드(서치팝업)
                        M018.DEPT_KR_NM                           AS "DEPT_CD_NM",   -- 부서명                                
                       (SELECT CDESC1 FROM CMCDV WHERE CMCDKY = ''FNL_JDGM''  AND CMCDVL = Q024.FNL_JDGM) AS "FNL_JDGM_NM",        
                        Q024.PRC_MTD                              AS "PRC_MTD",      -- 콤보박스(선택)
                        DECODE(TRIM(NVL(Q024.PRC_MTD,'''')), '''', ''N'', ''Y'') AS  "REG_YN", 
                        Q024.RMK                                  AS "RMK",       -- 비고
                        M001.LGPRO                             AS "STOR_LOC_CD",  -- 저장위치(H)
                        Q024.REGDATE AS "REGDATE",
                        NVL((SELECT NMLAST FROM USRMA WHERE USRMA.USERID = Q024.REGID),'''') AS "REGNM",
                        Q024.UPDDATE AS "UPDDATE",
                        NVL((SELECT NMLAST FROM USRMA WHERE USRMA.USERID = Q024.UPDID),'''') AS "UPDNM"
                FROM  TB_QLT024 Q024,
                      TB_QLT020 Q020,
                      TB_MAS018 M018,
                      TB_MAS001 M001,
                      TB_INV001 I001
                WHERE Q024.COMPKY     = M018.COMPKY(+)
                  AND Q024.DEPT_CD    = M018.DEPT_CD(+)
                  AND Q024.MATNR      = M001.MATNR(+)
                  AND Q024.WERKS      = M001.WERKS(+)
                  AND Q024.MSRM_DATE  = Q020.MSRM_DATE(+)
                  AND Q024.PRC_SEQNO  = Q020.PRC_SEQNO(+)
                  AND Q024.WERKS      = I001.WERKS(+)
                  AND Q024.IND_BCD    = I001.IND_BCD(+)
                  AND Q024.MATNR      = I001.MATNR(+) ';

        IF  V_WERKS IS NOT NULL OR TRIM(V_WERKS) != '' THEN -- 플랜트
            V_SQL := V_SQL || ' AND Q024.WERKS  = ''' || V_WERKS || '''';             
        END IF;

        IF  ( V_SDATE IS NOT NULL OR TRIM(V_SDATE) != '' ) AND (V_EDATE IS NOT NULL OR TRIM(V_EDATE) != '')THEN -- 자재코드
            V_SQL := V_SQL || ' AND Q024.MSRM_DATE >= TO_DATE(''' || V_SDATE || ''',''YYYY-MM-DD HH24:MI:SS'') AND Q024.MSRM_DATE < TO_DATE(''' || V_EDATE || ''',''YYYY-MM-DD HH24:MI:SS'') + 1 ';  
        END IF;

        IF  V_MATNR IS NOT NULL OR TRIM(V_MATNR) != '' THEN -- 자재코드
            V_SQL := V_SQL || ' AND Q024.MATNR IN(''' || V_MATNR || ''') ''';             
        END IF;

        IF  V_REG_YN IS NOT NULL OR TRIM(V_REG_YN) != '' THEN -- 등록여부
            V_SQL := V_SQL || ' AND DECODE(TRIM(NVL(Q024.PRC_MTD,'')), '''', ''N'', ''Y'') = ''' || V_REG_YN || '''';
        END IF;

		V_SQL := V_SQL || ' ORDER BY Q024.MSRM_DATE ';

        BEGIN           
     		OPEN P_RS_LIST FOR V_SQL;

        EXCEPTION           
        WHEN OTHERS THEN 
            P_SUCCESS           := 'N';
            E_SQL_ERR_CD        := -20000;
			E_SQL_ERR_MSG       := SQLCODE || ': EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';

            SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);
            RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);           
            RETURN;           
        END;    

    ELSIF P_TYPE = 'SUB_LIST' THEN  /* 하단 상세 조회 리스트*/
          RETURN;

    ELSIF P_TYPE = 'SAVE' THEN
        V_ARR_HEAD           := TREAT(V_JSON.get ('head') AS json_object_t);
        V_ARR_LIST           := V_JSON.get_array('list');

        -- 상단의 입력된 맵에서 가져온다.
        FOR i IN 0..V_ARR_LIST.get_size-1 LOOP

                V_OBJ           := TREAT (V_ARR_LIST.get (i) AS json_object_t);
                V_OBJ           := TREAT (V_OBJ.get ('map') AS json_object_t);

                V_MSRM_DATE     := V_OBJ.get_date('MSRM_DATE');          /*측정일시*/                
                V_MSRM_DT       := V_OBJ.get_string('MSRM_DATE');
                V_PRC_SEQNO     := V_OBJ.get_number('PRC_SEQNO');
                V_PRC_MTD       := V_OBJ.get_string('PRC_MTD');
                V_PRC_SEQNO     := V_OBJ.get_number('PRC_SEQNO');

                V_UCFMTY_AMT    := V_OBJ.get_number('UCFMTY_AMT');
                V_COMPKY        := V_OBJ.get_string('COMPKY');
                V_DEPT_CD       := V_OBJ.get_string('DEPT_CD');
                V_RMK           := V_OBJ.get_string('RMK');

                IF V_OBJ.get_string('GRowState') = 'C' THEN  --추가가 있나?
                      RETURN; 

                ELSIF  V_OBJ.get_string('GRowState') = 'U' THEN
                    
                       BEGIN
                            MERGE
                                  INTO  TB_QLT024 Q024
                                 USING  DUAL
                                    ON ( Q024.MSRM_DATE             =  TO_DATE(V_MSRM_DT,'YYYY-MM-DD HH24:MI:SS')
                                   AND   Q024.PRC_SEQNO             =  V_PRC_SEQNO )
                            WHEN MATCHED THEN
                                   UPDATE
                                       SET UCFMTY_AMT              =  V_UCFMTY_AMT
                                         , PRC_MTD                 =  V_PRC_MTD
                                         , COMPKY                  =  'KN' 
                                         , DEPT_CD                 =  V_DEPT_CD
                                         , RMK                     =  V_RMK;
                                         --20220919 여한진 품질 재검사에서 부적합을 조정할 때 수정일시를 업데이트하도록 
                                         --, UPDDATE                 =  SYSDATE
                                         --, UPDID                   =  V_SESS_USER_ID ;             
                            EXCEPTION           
                            WHEN OTHERS THEN 
                                  P_SUCCESS           := 'N';
                                  E_SQL_ERR_CD        := -20000;
								  E_SQL_ERR_MSG       := SQLCODE || ': EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';
                                  ROLLBACK;

                                  SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);
                                  RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);           
                                  RETURN;           
                       END; 

				ELSIF V_OBJ.get_string('GRowState') = 'D' THEN  -- 삭제가 있나?
                      RETURN;              

                END IF;

            END LOOP;

    ELSIF P_TYPE = 'SUB_SAVE' THEN
          RETURN;

    END IF;

    P_SUCCESS := 'Y';

    COMMIT;

    EXCEPTION
    WHEN E_EXCEPTION_USER THEN

        -- 에러 내역 SET
	    P_SUCCESS           := 'N';
        E_SQL_ERR_CD        := -20000;
		E_SQL_ERR_MSG       := SQLCODE || ': EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';
        SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);

        ROLLBACK;

    WHEN OTHERS THEN
	    P_SUCCESS           := 'N';
        E_SQL_ERR_CD        := -20000;
		E_SQL_ERR_MSG       := SQLCODE || ': EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';
        SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);

        ROLLBACK;
        RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);
END

;

/
