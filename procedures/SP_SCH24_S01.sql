
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_SCH24_S01" (
	P_TYPE           IN    varchar2, -- LIST, SAVE
	P_JSON_STR       IN    CLOB,
	P_SUCCESS       OUT    varchar2,
	P_RS_LIST       OUT    SYS_REFCURSOR
)
/*==============================================================================
 * PROGRAM ID    : SP_SCH24_S01
 * PROGRAM NAME  : 예외생산작업지시(PS)
 * VERSION       : 1.0.0
 * DESCRIPTION   : 예외생산작업지시(PS)를 관리한다.
 *
 * AUTHOR NAME   : 안상현
 * CREATE DATE   : 2022/07/27
 * SYSTEM NAME   : MES
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}  <생략가능>
 * SUB PROCEDURE : {아휘 프로시저 명칭 기술}      <생략가능>
 * SUB PACKAGES  : {하위 패키지 기술}            <생략가능>
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술} <생략가능>
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description
 * ------------ ------- ------------- ------------------------------------------
 *  2022-12-22	 1.0.0	    여한진		  규격 정보와 하역지점 정보 추가
 *==============================================================================
 *  관련 테이블
 *        - [TB_SCH018] : (CRUD) 포장(리팩킹) 작업지시 정보
 * 		  - [TB_SCH020] : (.R..) 생산오더 BOM
 *
 *=============================================================================*/

AS
    V_PRG_NM VARCHAR2(100) := 'SP_SCH24_S01'; -- PROCEDURE NAME

    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER EXCEPTION;
    E_SQL_ERR_CD      NUMBER(5) := 0;
    E_SQL_ERR_MSG     VARCHAR2(4000);

    -- JSON을 위한 변수선언 영역
    V_JSON            JSON_OBJECT_T;
    V_ARR_LIST        JSON_ARRAY_T;
    V_ARR_HEAD        JSON_ARRAY_T;
    V_OBJ             JSON_OBJECT_T;

    -- 세션값 처리용 변수선언 영역
    V_SQL             CLOB;
    V_RUN_SQL         varchar2(1);
    V_RANGE_SQL       varchar2(4000);
    V_DEBUG           varchar2(1);

    -- 세션값 처리용 변수선언 영역
    V_PLT_CD          varchar2(2);
    V_SESS_USER_ID    varchar2(20);

    -- 조건절 처리용 변수선언 영역
    V_WERKS           TB_SCH008.WERKS%TYPE; --플랜트
    V_MACHINE         TB_SCH008.MACHINE%TYPE; --생산호기
    --20230213 여한진 오더번호, 오더유형, 변경전 자재코드, 변경후 자재코드, 하역지점, 완료여부 검색조건 추가
    V_ORDER_NO        TB_SCH019.ORDER_NO%TYPE; --오더번호
    V_ORDER_DIV       TB_SCH019.ORDER_DIV%TYPE; --오더유형
    V_PRE_MATNR       TB_SCH020.MATNR%TYPE; --변경 전 자재코드
    V_MATNR           TB_SCH019.MATNR%TYPE; --변경 후 자재코드
    V_DELIPOT         TB_SCH019.DELIPOT%TYPE; --하역지점
    V_COMP_YN         TB_SCH019.COMP_YN%TYPE; --완료여부

    -- 리스트(그리드)의 값을 할당하기 위한 변수선언 영역
    V_WRK_ORDR_NO     TB_SCH017.WRK_ORDR_NO%TYPE; --작업지시번호
    V_WRK_ORDR_SEQNO  TB_SCH017.WRK_ORDR_SEQNO%TYPE; --작업지시순번

    V_CORE_INCH       TB_SCH019.CORE_INCH%TYPE; --지관사이즈(인치)
    V_COVER_YN        TB_SCH019.COVER_YN%TYPE; --지관마개여부
    V_CORR_YN         TB_SCH019.CORR_YN%TYPE; --골판지여부
    V_PACK_YN         TB_SCH019.PACK_YN%TYPE; --포장여부

    R_OLD             TB_SCH019%ROWTYPE;

BEGIN
    OPEN P_RS_LIST FOR
        SELECT NULL FROM DUAL WHERE ROWNUM = 0;

        V_DEBUG := 'N';
        V_RUN_SQL := 'Y';

        V_JSON := JSON_OBJECT_T.parse(P_JSON_STR);

        V_SESS_USER_ID      :=      V_JSON.get_string('SES_USER_ID');
        V_PLT_CD            :=      V_JSON.get_string('SES_PLNTKY');

        /* 조건값 할당 */
        V_WERKS          	:=      V_JSON.get_string('WERKS');         --플랜트
        V_MACHINE           :=      V_JSON.get_string('MACHINE');       --생산호기
        V_RANGE_SQL 		:=      V_JSON.get_string('RANGE_SQL');   	--생산요청일자, 지시생성일자

        V_ORDER_NO			:=      V_JSON.get_string('ORDER_NO');		--오더번호
        V_ORDER_DIV			:=      V_JSON.get_string('ORDER_DIV');		--오더유형
        V_PRE_MATNR			:=      V_JSON.get_string('PRE_MATNR');		--변경 전 자재코드
        V_MATNR				:=      V_JSON.get_string('MATNR');			--변경 후 자재코드
        V_DELIPOT			:=      V_JSON.get_string('DELIPOT');		--하역지점
        V_COMP_YN			:=      V_JSON.get_string('COMP_YN');		--완료여부

   IF P_TYPE = 'LIST' THEN /*상단 조회 리스트*/

 	V_SQL :=  ' SELECT
                       SCH019.WERKS                        WERKS                --플랜트코드
                     , SCH019.ORDR_GEN_DT                  ORDR_GEN_DT          --지시생성일자
                     , SCH019.WRK_ORDR_NO                  WRK_ORDR_NO          --작업지시번호
                     , SCH019.WRK_ORDR_SEQNO               WRK_ORDR_SEQNO       --지시순번
                     , SCH019.WRK_ORDR_QTY                 ORDR_QTY             --오더량
                     , ''R''                               OORDR_UNIT              --오더단위 (추가)
                     , SCH019.UNIT                         UNIT                 --단위
                     , SCH019.WRK_SEQNO                    WRK_SEQNO            --작업순서
                     , SCH019.WRK_ORDR_QTY                 WRK_ORDR_QTY         --작업지시지시량
                     , ''R''                               ORDR_UNIT              --지시량단위 (추가)
                     , SCH019.WRK_ORDR_REMARK              WRK_ORDR_REMARK      --작업지시비고
                     , DECODE(NVL(SCH019.USE_YN,''Y''), ''Y'', ''사용'', ''미사용'')                       USE_YN               --사용여부
                     , FN_CD_VAL(''COMP_YN'', SCH019.COMP_YN)                      COMP_YN              --완료여부
                     --, MAS012.MACHINE                      MACHINE              --생산호기
                     , SCH019.PRD_REQ_DT                   PRD_REQ_DT           --생산요청일자
                     , SCH019.ORDER_NO                     ORDER_NO             --오더번호
                     , REGEXP_REPLACE(SCH019.AUARTXT, ''제지 | 오더 유형'', '''')       AS ORDER_DIV   --오더유형
                     , SCH019.MATNR       		           MATNR			    --자재코드
                     , MAS001.MATNR_NM		               MATNR_NM				--자재명
                     --, SCH019.COMP_QTY                     COMP_QTY             --완료수량
                     /*, DECODE(SCH019.PRD_STR_DTM, NULL, '''', SUBSTR(SCH019.PRD_STR_DTM, 1,4)||''-''
                       ||SUBSTR(SCH019.PRD_STR_DTM, 5,2)||''-''
                       ||SUBSTR(SCH019.PRD_STR_DTM, 7,2)||'' ''
                       ||SUBSTR(SCH019.PRD_STR_DTM, 9,2)||'':''
                       ||SUBSTR(SCH019.PRD_STR_DTM, 11,2))  PRD_STR_DTM          --생산시작시간*/
                     , DECODE(SCH019.PRD_END_DTM, NULL, '''', SUBSTR(SCH019.PRD_END_DTM, 1,4)||''-''
                       ||SUBSTR(SCH019.PRD_END_DTM, 5,2)||''-''
                       ||SUBSTR(SCH019.PRD_END_DTM, 7,2)||'' ''
                       ||SUBSTR(SCH019.PRD_END_DTM, 9,2)||'':''
                       ||SUBSTR(SCH019.PRD_END_DTM, 11,2))  PRD_END_DTM          --생산완료시간
				      , SUBSTR(SCH020.MATNR, 10, 4) || ''*'' || SUBSTR(SCH020.MATNR, 14, 4) PRE_CHG_SPEC	--변경 전 규격
					  , SUBSTR(SCH019.MATNR, 10, 4) || ''*'' || SUBSTR(SCH019.MATNR, 14, 4) AFTER_CHG_SPEC	--변경 후 규격
					  , FN_CD_VAL(''DELIPOT'', SCH019.DELIPOT)	DELIPOT			--하역지점
                      , SCH019.PCODE                       PCODE                --지종코드
                      , MAS001.PCODE_NM  PCODE_NM             --지종명
                      , SCH019.BS_WGT                      BS_WGT               --평량
                      , SCH019.WLEN                        WLEN                 --가로길이
                      , SCH019.VLEN                        VLEN                 --세로길이
                      , SCH019.PLT_PER_CNT                 PLT_PER_CNT          --팔레트당연수
                      , SCH019.IN_PER_CNT                  IN_PER_CNT           --속당매수
                      , SCH019.MCNT                        MCNT                 --매
                      , SCH019.SCNT                        SCNT                 --속
                      , SCH019.KUNNR                       KUNNR                --판매처 코드
                      , SCH019.KUNNRT                      KUNNRT               --판매처
                      --, SCH019.MACH_CD                     MACH_CD              --설비코드
                      --, MAS012.MACH_NM                     MACH_NM              --설비명
                      , SCH019.REGDATE                     REGDATE              --등록일시
                      , NVL((SELECT NMLAST FROM USRMA WHERE USRMA.USERID = SCH019.REGID),'''')
                                                           REGNM                --등록자
                      , SCH019.UPDDATE                     UPDDATE		        --수정일시
                      ,NVL((SELECT NMLAST FROM USRMA WHERE USRMA.USERID = SCH019.UPDID),'''')
                                                           UPDNM                --수정자
                        , CASE
                            WHEN SCH019.CORE_INCH IS NULL   THEN ''-''
                            ELSE SCH019.CORE_INCH
                        END                                                     AS CORE_INCH      --지관인치
                        , CASE
                            WHEN SCH019.CORE_INCH IS NULL   THEN ''-''
                            WHEN SCH019.COVER_YN IS NULL    THEN ''미사용''
                            WHEN SCH019.COVER_YN = ''X''    THEN ''사용''
                        END                                                     AS COVER_YN      --지관마개여부
                        , CASE
                            WHEN SCH019.CORE_INCH IS NULL   THEN ''-''
                            WHEN SCH019.CORR_YN IS NULL     THEN ''미사용''
                            WHEN SCH019.CORR_YN = ''X''     THEN ''사용''
                        END                                                     AS CORR_YN      --골판지여부
                        , CASE
                            WHEN SCH019.CORE_INCH IS NULL   THEN ''-''
                            WHEN SCH019.PACK_YN IS NULL     THEN ''미사용''
                            WHEN SCH019.PACK_YN = ''X''     THEN ''사용''
                        END                                                     AS PACK_YN      --포장여부
                  FROM TB_SCH019 SCH019	--작업지시 예외
                     , TB_MAS001 MAS001 --플랜트별 제품/자재 마스터
                     --, TB_MAS012 MAS012 --설비 마스터
				     , (SELECT WERKS, ORDER_NO, MATNR
                          FROM TB_SCH020
                         WHERE WERKS = ''P100''
                         GROUP BY WERKS, ORDER_NO, MATNR
                        )SCH020	--생산오더 BOM
					 , TB_MAS001 M001	--자재마스터
                 WHERE SCH019.MATNR = MAS001.MATNR(+)
                   AND SCH019.WERKS  = MAS001.WERKS(+)
                   --AND SCH019.MACH_CD = MAS012.MACH_CD(+)
				   AND SCH019.ORDER_NO = SCH020.ORDER_NO(+)
				   AND SCH020.WERKS = M001.WERKS(+)
				   AND SCH020.MATNR = M001.MATNR(+)
				   AND SCH019.ORDER_DIV IN (''ZP12'',''ZP13'',''ZP14'')
				   AND M001.MATNR_DIV IN (''HALB'', ''FERT'', ''HAWA'')	'
                 ;

        IF  V_WERKS IS NOT NULL OR TRIM(V_WERKS) != '' THEN
            V_SQL := V_SQL || ' AND SCH019.WERKS = ''' || V_WERKS || '''';				   --플랜트
        END IF;

        --IF  V_MACHINE IS NOT NULL OR TRIM(V_MACHINE) != '' THEN
        --    V_SQL := V_SQL || ' AND SCH018.MACHINE = ''' || V_MACHINE || '''';			   --생산호기
        --END IF;

        IF  V_RANGE_SQL IS NOT NULL OR TRIM(V_RANGE_SQL) != '' THEN
        	V_RANGE_SQL := REPLACE(V_RANGE_SQL, 'ORDER_NO', 'SCH019.ORDER_NO');	--오더번호
            V_SQL := V_SQL || V_RANGE_SQL ;
        END IF;

        --20230213 여한진 오더번호, 오더유형, 변경전 자재코드, 변경후 자재코드, 하역지점, 완료여부 검색조건 추가

        /*IF  V_ORDER_NO IS NOT NULL OR TRIM(V_ORDER_NO) != '' THEN
            V_SQL := V_SQL || ' AND SCH019.ORDER_NO LIKE ''' || V_ORDER_NO || '%''';			--오더번호
        END IF;*/

        IF  V_ORDER_DIV IS NOT NULL OR TRIM(V_ORDER_DIV) != '' THEN
            V_SQL := V_SQL || ' AND SCH019.ORDER_DIV = ''' || V_ORDER_DIV || '''';			   	--오더유형
        END IF;

        IF  V_PRE_MATNR IS NOT NULL OR TRIM(V_PRE_MATNR) != '' THEN
            V_SQL := V_SQL || ' AND SCH020.MATNR LIKE ''' || V_PRE_MATNR || '%''';			   	--변경 전 자재코드
        END IF;

        IF  V_MATNR IS NOT NULL OR TRIM(V_MATNR) != '' THEN
            V_SQL := V_SQL || ' AND SCH019.MATNR LIKE ''' || V_MATNR || '%''';			   	   --변경 후 자재코드
        END IF;

        IF  V_DELIPOT IS NOT NULL OR TRIM(V_DELIPOT) != '' THEN
            V_SQL := V_SQL || ' AND SCH019.DELIPOT = ''' || V_DELIPOT || '''';			   	   --하역지점
        END IF;

        IF  V_COMP_YN IS NOT NULL OR TRIM(V_COMP_YN) != '' THEN
            V_SQL := V_SQL || ' AND SCH019.COMP_YN = ''' || V_COMP_YN || '''';			   	   --완료여부
        END IF;

        V_SQL := V_SQL || ' ORDER BY SCH019.WRK_ORDR_NO,SCH019.WRK_SEQNO, SCH019.WRK_ORDR_SEQNO';

        IF (V_DEBUG = 'Y') THEN
            INSERT INTO PROC_LOG(SQL_STR, SQL_PARAM1) VALUES (V_SQL, 'SCH24_S01');
        END IF;

		OPEN P_RS_LIST FOR V_SQL;

    ELSIF P_TYPE = 'SAVE' THEN

        V_ARR_LIST        := V_JSON.get_array('list');

        FOR i IN 0..V_ARR_LIST.get_size-1 LOOP
            V_OBJ						:= TREAT (V_ARR_LIST.get (i) AS json_object_t);
            V_OBJ						:= TREAT (V_OBJ.get ('map') AS json_object_t);

            V_WRK_ORDR_NO	            := V_OBJ.get_string('WRK_ORDR_NO');        --작업지시번호
            V_WRK_ORDR_SEQNO	        := V_OBJ.get_string('WRK_ORDR_SEQNO');     --작업지시순번
            V_WERKS	                    := V_OBJ.get_string('WERKS');              --플랜트코드

            V_CORE_INCH	                := V_OBJ.get_string('CORE_INCH');          --지관사이즈(인치)
            V_COVER_YN	                := V_OBJ.get_string('COVER_YN');           --지관마개여부
            V_CORR_YN	                := V_OBJ.get_string('CORR_YN');            --골판지여부
            V_PACK_YN	                := V_OBJ.get_string('PACK_YN');            --포장여부

            IF V_OBJ.get_string('GRowState') = 'C'   THEN
                --저장
                NULL;

            ELSIF V_OBJ.get_string('GRowState') = 'U'  THEN
                --수정
                SELECT *
                INTO R_OLD
                FROM TB_SCH019
                WHERE WRK_ORDR_NO = V_WRK_ORDR_NO
                  AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO;

                -- 완료여부 : N:대기 I:작업중 Y:완료
                IF NVL(R_OLD.COMP_YN, 'N') = 'N' THEN   -- N:대기 경우일때만 변경 실행
                    V_CORE_INCH := CASE WHEN V_CORE_INCH = '-' THEN NULL ELSE V_CORE_INCH END;
                    V_COVER_YN  := CASE WHEN V_COVER_YN = '사용' THEN 'X' ELSE NULL END;
                    V_CORR_YN   := CASE WHEN V_CORR_YN = '사용' THEN 'X' ELSE NULL END;
                    V_PACK_YN   := CASE WHEN V_PACK_YN = '사용' THEN 'X' ELSE NULL END;

                    -- SCH24 원지포장 옵션 변경 이력 저장
                    -- sch24 테이블 별도생성할건지 생성안할거면 공용 명칭으로 변경필요
                    SP_ORDER_PKG_OPT_HIST_LOG(V_WRK_ORDR_NO, V_WRK_ORDR_SEQNO, V_CORE_INCH, V_COVER_YN, V_CORR_YN,
                                              V_PACK_YN, V_SESS_USER_ID, R_OLD.CORE_INCH, R_OLD.COVER_YN, R_OLD.CORR_YN,
                                              R_OLD.PACK_YN, '(예외)TB_SCH19');

                    UPDATE TB_SCH019
                    SET   CORE_INCH         = V_CORE_INCH                   -- 지관사이즈(인치)
                         ,COVER_YN          = V_COVER_YN    	            -- 지관마개여부
                         ,CORR_YN           = V_CORR_YN                     -- 골판지여부
                         ,PACK_YN           = V_PACK_YN                     -- 포장여부

                         ,UPDDATE		    = SYSDATE			            --수정일자
                         ,UPDID			    = V_SESS_USER_ID	            --수정자
                    WHERE 1=1
                        AND WRK_ORDR_NO		= V_WRK_ORDR_NO                 --작업지시번호
                        AND	WRK_ORDR_SEQNO  = V_WRK_ORDR_SEQNO   ;          --작업지시순번
                END IF;
            ELSIF V_OBJ.get_string('GRowState') = 'D'  THEN
                --삭제
                NULL;
            END IF;
        END LOOP;

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
        --RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);
        RAISE;
END;
/
