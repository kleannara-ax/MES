
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_PDA_QLT01_S01" 
(
    P_TYPE           IN    varchar2, -- LIST, SUB_LIST, SUB_SAVE
	P_JSON_STR       IN    CLOB,
	P_SUCCESS       OUT    varchar2,
	P_RS_LIST       OUT    SYS_REFCURSOR
)
AS 
/*==============================================================================
 * PROGRAM ID    : SP_PDA_QLT01_S01{호출 프로그램 ID 기술}
 * PROGRAM NAME  : PDA 품질검사(포장대기) - PS 완제품{호출 프로그램 명 기술}
 * VERSION       : 1.0.0{최종 버전 기술}
 * DESCRIPTION   : PDA 품질검사(포장대기) - PS 완제품{프로그램에 대한 상세한 내용 기술}
 *                 
 * AUTHOR NAME   : 박충식{최초 작성자 명 기술}
 * CREATE DATE   : 2022/06/03 {최초 작성일자 기술}
 * SYSTEM NAME   : PDA
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}  <생략가능>
 * SUB PROCEDURE : {아휘 프로시저 명칭 기술}      <생략가능>
 * SUB PACKAGES  : {하위 패키지 기술}            <생략가능>
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술} <생략가능>
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/05/04    1.0.0   박충식         Initial Version
 * 2022/08/10    1.0.1   여한진         적합 및 불합격 처리 로직 수정
 *==============================================================================
 *  관련 테이블
 *       - [TB_MAS001] : (.R..) 자재 마스터                                
 *       - [TB_MAS015] : (CRUD) 검사항목별 기준정보 등록 마스트                              
 *       - [TB_MAS016] : (CRUD) 검사항목별 기준값 정보                                
 *=============================================================================*/
    --프로그램 ID
    V_PRG_NM          VARCHAR2(100)  := 'SP_PDA_QLT01_S01';     -- PROCEDURE NAME

    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD      NUMBER(5)           := 0;
    E_SQL_ERR_MSG     VARCHAR2(4000);

    -- JSON을 위한 변수선언 영역
    V_JSON           JSON_OBJECT_T;
    V_ARR_LIST       JSON_ARRAY_T;
    V_ARR_HEAD       JSON_OBJECT_T;
    V_OBJ            JSON_OBJECT_T;
    V_OBJ2           JSON_OBJECT_T;

    -- 세션값 처리용 변수선언 영역
    V_SQL            CLOB;
    V_RUN_SQL        varchar2(1);
    V_RANGE_SQL      varchar2(4000);
    V_DEBUG          varchar2(1);

    -- 세션값 처리용 변수선언 영역
    V_PLT_CD         varchar2(2);
    V_SESS_USER_ID   varchar2(20);

    -- 조건절 처리용 변수선언 영역
    V_WERKS             TB_WRK002.WERKS%TYPE;           -- 플랜트코드
    V_MATNR             TB_WRK002.MATNR%TYPE;           -- 자재코드

    V_IND_BCD           TB_INV001.IND_BCD%TYPE;         -- 업체/개별바코드
    V_FNL_JDGM          TB_INV001.FNL_JDGM%TYPE;        --판정
    V_MSRM_DATE         TB_INV001.MSRM_DATE%TYPE;       --측정일시
    
    V_INSP_ITEM_CD	    varchar2(1000);                 --여러 개의 검사항목코드
    V_DEPT_CD           varchar2(10);                   --부서코드  
    V_INSP_ITEM_CD_NEW  TB_QLT021.INSP_ITEM_CD%TYPE;    --검사항목코드
    
    V_LEN               NUMBER;
BEGIN
    OPEN P_RS_LIST FOR 
    SELECT NULL FROM DUAL WHERE ROWNUM = 0;    

    V_JSON := JSON_OBJECT_T.parse(P_JSON_STR);
    V_SESS_USER_ID       :=       V_JSON.get_string('SES_USER_ID');
    V_PLT_CD             :=       V_JSON.get_string('SES_WAREKY');

    /* 조건값 할당 */

    V_WERKS              :=       V_JSON.get_string('WERKS');                       -- 플랜트코드
    V_IND_BCD            :=       V_JSON.get_string('IND_BCD');                     -- 업체/개별바코드

    IF P_TYPE = 'LIST' THEN  /* 조회*/
        
        V_SQL := ' SELECT I001.MATNR,              --자재코드
                           M001.MATNR_NM,           --자재명
                           I001.LOT_NO,             --LOT NO
                           M001.PCODE,              --지종
                           M001.PCODE_NM,           --지종명
                           M001.BS_WGT,              --평량
                           TO_CHAR(M001.WLEN) || '' * '' || TO_CHAR(M001.VLEN)              AS MATNR_SPEC,      --규격
                           TO_CHAR(I001.STCK_QTY, ''999,999,999'') || '' '' || I001.UNIT    AS STCK_QTY,      --재고수량
                           CASE WHEN NVL(I001.WGT, 0) > 0 THEN TO_CHAR(I001.WGT, ''999,999,990.009'') || '' KG''
                                ELSE '''' END                                             AS WGT,             --중량 
                           FN_CD_VAL(''PACK_TYPE'', I001.PACK_TYPE)                       AS PACK_TYPE,       --포장타입 
                           FN_CD_VAL(''STCK_STA'', I001.STCK_STA)                         AS STCK_STA         --재고상태
                      FROM TB_INV001 I001,
                           TB_MAS001 M001
                     WHERE I001.WERKS = M001.WERKS(+)
                       AND I001.MATNR = M001.MATNR(+)
                       AND I001.WERKS = ''' || V_WERKS || '''
                       AND I001.IND_BCD = ''' || V_IND_BCD || '''';
        
--        V_SQL := '  SELECT 
--                           WRK002.IND_BCD	                    IND_BCD         --개별바코드
--                         , WRK002.LOT_NO	                    LOT_NO          --LOT_NO
--                         , WRK002.MATNR                         MATNR           --자재코드
--                         , SCH017.PCODE	                        PCODE           --지종
--                         , FN_CMCDV (''PCODE'', SCH017.PCODE)   PCODE_NM        --지종명
--                         , SCH017.BS_WGT                        BS_WGT          --평량
--                         , MAS001.MATNR_SPEC	                SPEC            --규격
--                         , WRK002.SCNT	                        SCNT            --속수
--                         , WRK002.MCNT	                        MCNT            --매
--                         , NVL(WRK002.PCNT, 0)                  PCNT            --연수
--                         , NVL(WRK002.WGT , 0)                  WGT             --중량
--                         , NULL                                 PACK_TYPE       --포장타입
--                         , FN_CMCDV (''PACK_TYPE'', NULL)       PACK_TYPE_NM    --포장타입명
--                      FROM TB_WRK002   WRK002  --실적테이블(PS)
--                         , TB_SCH017   SCH017  --작업지시 재단
--                         , TB_MAS001   MAS001  --플랜트별 제품/자재 마스터 
--                     WHERE WRK002.WRK_ORDR_NO    = SCH017.WRK_ORDR_NO
--                       AND WRK002.WRK_ORDR_SEQNO = SCH017.WRK_ORDR_SEQNO
--                       AND WRK002.MATNR	= MAS001.MATNR(+)  
--                       AND WRK002.WERKS	= MAS001.WERKS(+)                       
--                       '; 
--
--        V_SQL := V_SQL || ' AND WRK002.WERKS   = ''' || V_WERKS|| '''';                  
--        V_SQL := V_SQL || ' AND WRK002.IND_BCD = ''' || V_IND_BCD || '''';                  
        INSERT INTO PROC_LOG(SQL_PARAM1) VALUES(V_SQL);
        BEGIN           
     		OPEN P_RS_LIST FOR V_SQL;

        EXCEPTION           
        WHEN OTHERS THEN 
            P_SUCCESS           := 'N';
            E_SQL_ERR_CD        := SQLCODE;
            E_SQL_ERR_MSG       := 'EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';

            SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);
            RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);           
            RETURN;           
        END;        
    ELSIF P_TYPE = 'SUB_LIST1' THEN  /* 불량항목 검색*/

        V_SQL := 'SELECT 
                        INSP_ITEM_CD	INSP_ITEM_CD  --검사항목코드
                       ,INSP_ITEM_NM	INSP_ITEM_NM  --검사항목명
                from TB_MAS014
                where INSP_ITEM_GRP_CD = ''P2''';

        V_SQL := V_SQL || ' ORDER BY INSP_ITEM_CD'; 

        BEGIN           
     		OPEN P_RS_LIST FOR V_SQL;

        EXCEPTION           
        WHEN OTHERS THEN 
            P_SUCCESS           := 'N';
            E_SQL_ERR_CD        := SQLCODE;
            E_SQL_ERR_MSG       := 'EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';

            SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);
            RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);           
            RETURN;           
        END;                                

    ELSIF P_TYPE = 'SUB_LIST2' THEN  /* 부서정보 검색*/

        V_SQL := ' SELECT 
                          DEPT_CD       --부서코드
                        , DEPT_KR_NM	--부서명
                     FROM TB_MAS018 
                    WHERE COMPKY = ''KN''
                      AND DEPT_CD IN (''D0500520'', ''D2013110'')
                    ORDER BY DEPT_CD '; 
        BEGIN           
     		OPEN P_RS_LIST FOR V_SQL;

        EXCEPTION           
        WHEN OTHERS THEN 
            P_SUCCESS           := 'N';
            E_SQL_ERR_CD        := SQLCODE;
            E_SQL_ERR_MSG       := 'EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';

            SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);
            RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);           
            RETURN;           
        END; 

    ELSIF P_TYPE = 'SAVE' THEN      /* 검사합격*/
        V_MATNR            :=       V_JSON.get_string('MATNR');               --자재코드

        V_INSP_ITEM_CD	   :=       V_JSON.get_string('INSP_ITEM_CD'); --검사항목코드
        V_DEPT_CD        :=       V_JSON.get_string('DEPT_CD'); --부서코드  
        
        SELECT MSRM_DATE INTO V_MSRM_DATE
          FROM TB_INV001
         WHERE WERKS    = V_WERKS
           AND IND_BCD  = V_IND_BCD;
        
        IF NVL(V_MSRM_DATE, SYSDATE) = V_MSRM_DATE THEN
            DELETE 
              FROM TB_QLT020
             WHERE INSP_ITEM_GRP_CD = 'P2'
               AND MATNR            = V_MATNR
               AND WERKS            = V_WERKS
               AND MSRM_DATE        = V_MSRM_DATE
               AND PRC_SEQNO        = 1;
            
            DELETE
              FROM TB_QLT021
             WHERE INSP_ITEM_GRP_CD = 'P2'
               AND MATNR            = V_MATNR
               AND WERKS            = V_WERKS
               AND MSRM_DATE        = V_MSRM_DATE
               AND PRC_SEQNO        = 1;
            
            DELETE
              FROM TB_QLT024
             WHERE MSRM_DATE        = V_MSRM_DATE
               AND PRC_SEQNO        = 1;
        END IF;
           
        MERGE 
            INTO TB_MAS015  M015
           USING DUAL
              ON (M015.INSP_ITEM_GRP_CD = 'P2'
             AND M015.MATNR = V_MATNR
             AND M015.WERKS = V_WERKS)
        WHEN MATCHED THEN
                UPDATE
                   SET M015.UPDDATE = SYSDATE,
                       M015.UPDID = V_SESS_USER_ID
        WHEN NOT MATCHED THEN
                INSERT
                (
                    INSP_ITEM_GRP_CD,
                    MATNR,
                    WERKS,
                    REGDATE,
                    REGID
                )
                VALUES
                (
                    'P2',
                    V_MATNR,
                    V_WERKS,
                    SYSDATE,
                    V_SESS_USER_ID
                );

        UPDATE TB_INV001
           SET LOC_CD       = 'L2600'
             , STCK_STA     = '00'
             , FNL_JDGM     = 'PASS'
             , MSRM_DATE    = SYSDATE
             , UPDDATE      = SYSDATE
             , UPDID        = V_SESS_USER_ID 
         WHERE WERKS        = V_WERKS
           AND IND_BCD      = V_IND_BCD;

        INSERT INTO TB_QLT020     --검사항목별 측정결과 마스터
        (
             INSP_ITEM_GRP_CD	    --검사항목그룹코드
            ,MATNR	                --품목코드
            ,WERKS	                --플랜트코드
            ,MSRM_DATE	            --측정일시
            ,PRC_SEQNO	            --처리순번
            ,MSRM_ID	            --측정자
            ,SMPL_AMT	            --시료량
            ,FNL_JDGM	            --최종판정
            ,LOT_NO	                --로트번호
            ,IND_BCD	            --개별바코드
            ,VND_LOT_NO	            --업체로트번호
            ,SUPY_VND_BCD	        --공급업체바코드
            ,DOC_NO	                --문서번호
            --,DOC_ITM	            --문서아이템
            ,REQ_DIV	            --요청구분(01:국내자재, 02:수입자재, 03:반품입고)
            --,REQ_DT	            --요청일시
            ,DOC_ID	                --문서ID
            ,APVR_STA	            --결재상태
            ,PRN_ACC	            --출력회수
            ,PRN_ID	                --출력자
            ,DRFT_DATE	            --상신일자
            ,DRFT_ID	            --상신자
            ,CFRM_DATE	            --승인일자
            ,CFRM_ID	            --승인자
            ,PRC_DIV                --처리구분(I:개별, M:다중)
            ,REGDATE	            --REGDATE
            ,REGID	                --REGID        
        )
        SELECT 
               'P2'	                        --검사항목그룹코드      --재단실적
              ,WRK002.MATNR	                --품목코드
              ,WRK002.WERKS	                --플랜트코드
              ,SYSDATE	                    --측정일시
              ,1	                        --처리순번
              ,V_SESS_USER_ID	            --측정자
              ,NULL	                        --시료량
              ,'PASS'	                    --최종판정
              ,WRK002.LOT_NO	            --로트번호
              ,WRK002.IND_BCD	            --개별바코드
              ,NULL	                        --업체로트번호
              ,NULL	                        --공급업체바코드
              ,NULL	                        --문서번호
              --,NULL	                    --문서아이템
              ,CASE WHEN MAS001.DOMESTIC= 'Y'  THEN '01'
                    WHEN MAS001.DOMESTIC= 'N'  THEN '02'
                    ELSE                            NULL 
                END                         --요청구분(01:국내자재, 02:수입자재, 03:반품입고)  DOMESTIC	내수구분(내수:'Y', 외자:'N')
              --,NULL	                    --요청일시
              ,NULL	                        --문서ID
              ,'0'	                        --결재상태
              ,NULL	                        --출력회수
              ,NULL	                        --출력자
              ,NULL	                        --상신일자
              ,NULL	                        --상신자
              ,NULL	                        --승인일자
              ,NULL	                        --승인자
              ,'I'                          --처리구분
              ,SYSDATE	                    --REGDATE
              ,V_SESS_USER_ID	            --REGID        
         FROM TB_WRK002   WRK002  --실적테이블(PS)
            , TB_MAS001   MAS001  --플랜트별 제품/자재 마스터 
        WHERE WRK002.MATNR	= MAS001.MATNR(+)  
          AND WRK002.WERKS	= MAS001.WERKS(+)
          AND WRK002.WERKS   = V_WERKS
          AND WRK002.IND_BCD = V_IND_BCD;
        
        SELECT LENGTH(V_INSP_ITEM_CD) - LENGTH(REPLACE(V_INSP_ITEM_CD, ',', '')) INTO V_LEN FROM DUAL;
        
        IF NVL(V_LEN, 0) != 0 THEN        
            FOR CUR IN 0..V_LEN LOOP
                V_INSP_ITEM_CD_NEW := REGEXP_SUBSTR(V_INSP_ITEM_CD,'[^,]+', 1, (CUR + 1));
        
                INSERT INTO TB_QLT021 (INSP_ITEM_GRP_CD, MATNR, WERKS, MSRM_DATE, PRC_SEQNO, INSP_ITEM_CD, INSP_REP_YN, RST_VAL, RST_SEL, RST_TXT, RMK, FIT_YN, REGDATE, REGID) 
                               VALUES ('P2', V_MATNR, V_WERKS, SYSDATE, 1, V_INSP_ITEM_CD_NEW, NULL, NULL, 'FAIL', NULL, NULL, 'N', SYSDATE, V_SESS_USER_ID);
            END LOOP;
        END IF;
           
    ELSIF P_TYPE = 'SUB_SAVE1' THEN  /* 검사불합격*/
        V_MATNR            :=       V_JSON.get_string('MATNR');               --자재코드

        V_INSP_ITEM_CD	   :=       V_JSON.get_string('INSP_ITEM_CD'); --검사항목코드
        V_DEPT_CD          :=       V_JSON.get_string('DEPT_CD'); --부서코드  
        
        SELECT MSRM_DATE INTO V_MSRM_DATE
          FROM TB_INV001
         WHERE WERKS    = V_WERKS
           AND IND_BCD  = V_IND_BCD;
        
        IF NVL(V_MSRM_DATE, SYSDATE) = V_MSRM_DATE THEN
            DELETE 
              FROM TB_QLT020
             WHERE INSP_ITEM_GRP_CD = 'P2'
               AND MATNR            = V_MATNR
               AND WERKS            = V_WERKS
               AND MSRM_DATE        = V_MSRM_DATE
               AND PRC_SEQNO        = 1;
            
            DELETE
              FROM TB_QLT021
             WHERE INSP_ITEM_GRP_CD = 'P2'
               AND MATNR            = V_MATNR
               AND WERKS            = V_WERKS
               AND MSRM_DATE        = V_MSRM_DATE
               AND PRC_SEQNO        = 1;
               
            DELETE
              FROM TB_QLT024
             WHERE MSRM_DATE        = V_MSRM_DATE
             AND PRC_SEQNO        = 1;
        END IF;
        
        MERGE 
            INTO TB_MAS015  M015
           USING DUAL
              ON (M015.INSP_ITEM_GRP_CD = 'P2'
             AND M015.MATNR = V_MATNR
             AND M015.WERKS = V_WERKS)
        WHEN MATCHED THEN
                UPDATE
                   SET M015.UPDDATE = SYSDATE,
                       M015.UPDID = V_SESS_USER_ID
        WHEN NOT MATCHED THEN
                INSERT
                (
                    INSP_ITEM_GRP_CD,
                    MATNR,
                    WERKS,
                    REGDATE,
                    REGID
                )
                VALUES
                (
                    'P2',
                    V_MATNR,
                    V_WERKS,
                    SYSDATE,
                    V_SESS_USER_ID
                );

        INSERT INTO TB_QLT020     --검사항목별 측정결과 마스터
        (
             INSP_ITEM_GRP_CD	    --검사항목그룹코드
            ,MATNR	                --품목코드
            ,WERKS	                --플랜트코드
            ,MSRM_DATE	            --측정일시
            ,PRC_SEQNO	            --처리순번            
            ,MSRM_ID	            --측정자
            ,UCFMTY_AMT	            --부적합량
            ,FNL_JDGM	            --최종판정
            ,LOT_NO	                --로트번호
            ,IND_BCD	            --개별바코드
            ,VND_LOT_NO	            --업체로트번호
            ,SUPY_VND_BCD	        --공급업체바코드
            ,DOC_NO	                --문서번호
            --,DOC_ITM	            --문서아이템
            ,REQ_DIV	            --요청구분(01:국내자재, 02:수입자재, 03:반품입고)
            --,REQ_DT	            --요청일시
            ,DOC_ID	                --문서ID
            ,APVR_STA	            --결재상태
            ,PRN_ACC	            --출력회수
            ,PRN_ID	                --출력자
            ,DRFT_DATE	            --상신일자
            ,DRFT_ID	            --상신자
            ,CFRM_DATE	            --승인일자
            ,CFRM_ID	            --승인자
            ,PRC_DIV                --처리구분(I:개별, M:다중)
            ,REGDATE	            --REGDATE
            ,REGID	                --REGID        
        )
        SELECT 
               'P2'	                        --검사항목그룹코드      --재단실적
              ,WRK002.MATNR	                --품목코드
              ,WRK002.WERKS	                --플랜트코드
              ,SYSDATE	                    --측정일시
              ,1	                        --처리순번              
              ,V_SESS_USER_ID	            --측정자
              ,NULL	                        --부적합량
              ,'FAIL'	                    --최종판정
              ,WRK002.LOT_NO	            --로트번호
              ,WRK002.IND_BCD	            --개별바코드
              ,NULL	                        --업체로트번호
              ,NULL	                        --공급업체바코드
              ,NULL	                        --문서번호
              --,NULL	                    --문서아이템
              ,CASE WHEN MAS001.DOMESTIC= 'Y'  THEN '01'
                    WHEN MAS001.DOMESTIC= 'N'  THEN '02'
                    ELSE                            NULL 
                END                         --요청구분(01:국내자재, 02:수입자재, 03:반품입고)  DOMESTIC	내수구분(내수:'Y', 외자:'N')
              --,NULL	                    --요청일시
              ,NULL	                        --문서ID
              ,'0'	                        --결재상태
              ,NULL	                        --출력회수
              ,NULL	                        --출력자
              ,NULL	                        --상신일자
              ,NULL	                        --상신자
              ,NULL	                        --승인일자
              ,NULL	                        --승인자
              ,'I'                          --처리구분
              ,SYSDATE	                    --REGDATE
              ,V_SESS_USER_ID	            --REGID        
         FROM TB_WRK002   WRK002  --실적테이블(PS)
            , TB_MAS001   MAS001  --플랜트별 제품/자재 마스터 
        WHERE WRK002.MATNR	= MAS001.MATNR(+)  
          AND WRK002.WERKS	= MAS001.WERKS(+)
          AND WRK002.WERKS   = V_WERKS
          AND WRK002.IND_BCD = V_IND_BCD;
        
        INSERT INTO TB_QLT024    --부적합 처리 정보
        (MSRM_DATE, PRC_SEQNO, PRC_MTD, UCFMTY_AMT, LOT_NO, IND_BCD, VND_LOT_NO, SUPY_VND_BCD, COMPKY, DEPT_CD,
        FNL_JDGM, RMK, INSP_ITEM_GRP_CD, MATNR, WERKS, STOR_LOC_CD, REGDATE, REGID
        )
        SELECT SYSDATE, 1, NULL, NULL, W002.LOT_NO, W002.IND_BCD, NULL, NULL, NULL, V_DEPT_CD,
                'FAIL', NULL, 'P2', W002.MATNR, W002.WERKS, '2010', SYSDATE, V_SESS_USER_ID
          FROM TB_WRK002 W002
         WHERE W002.WERKS = V_WERKS
           AND W002.IND_BCD = V_IND_BCD;

       UPDATE TB_INV001
          SET LOC_CD = 'L2500'
             ,STCK_STA = '40'
             ,FNL_JDGM = 'FAIL'
             ,MSRM_DATE = SYSDATE
             ,UPDDATE = SYSDATE
             ,UPDID = V_SESS_USER_ID
        WHERE WERKS = V_WERKS
          AND IND_BCD = V_IND_BCD;
        
        SELECT LENGTH(V_INSP_ITEM_CD) - LENGTH(REPLACE(V_INSP_ITEM_CD, ',', '')) INTO V_LEN FROM DUAL;
        
        IF NVL(V_LEN, 0) != 0 THEN
            FOR CUR IN 0..V_LEN LOOP
                V_INSP_ITEM_CD_NEW := REGEXP_SUBSTR(V_INSP_ITEM_CD,'[^,]+', 1, (CUR + 1));
            
                INSERT INTO TB_QLT021 (INSP_ITEM_GRP_CD, MATNR, WERKS, MSRM_DATE, PRC_SEQNO, INSP_ITEM_CD, INSP_REP_YN, RST_VAL, RST_SEL, RST_TXT, RMK, FIT_YN, REGDATE, REGID) 
                               VALUES ('P2', V_MATNR, V_WERKS, SYSDATE, 1, V_INSP_ITEM_CD_NEW, NULL, NULL, 'FAIL', NULL, NULL, 'N', SYSDATE, V_SESS_USER_ID);
            END LOOP;
        END IF;
    END IF;

    P_SUCCESS := 'Y';

    COMMIT;

--    EXCEPTION
--    WHEN E_EXCEPTION_USER THEN
--
--        -- 에러 내역 SET
--	    P_SUCCESS           := 'N';
--        E_SQL_ERR_CD        := SQLCODE;
--        E_SQL_ERR_MSG       := SUBSTRB(SQLERRM,1,300);
--        SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);
--
--        ROLLBACK;
--
--    WHEN OTHERS THEN
--	    P_SUCCESS           := 'N';
--        E_SQL_ERR_CD        := SQLCODE;
--        E_SQL_ERR_MSG       := 'EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';
--
--        ROLLBACK;
--        RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);
END;
/
